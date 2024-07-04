#INCLUDE "JURA202.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

#DEFINE SIT_CONFERENCIA   "1"  // Conferência
#DEFINE SIT_ANALISE       "2"  // Análise
#DEFINE SIT_ALTERADA      "3"  // Alterada
#DEFINE SIT_EMIFATURA     "4"  // Emitir Fatura
#DEFINE SIT_EMIMINUTA     "5"  // Emitir Minuta
#DEFINE SIT_MINEMITIDA    "6"  // Minuta Emitida
#DEFINE SIT_MINCANCEL     "7"  // Minuta Cancelada
#DEFINE SIT_SUBSTITUIDA   "8"  // Substituída/Cancelada
#DEFINE SIT_MINSOCIO      "9"  // Minuta Sócio
#DEFINE SIT_MINSOCIOEMI   "A"  // Minuta Sócio Emitida
#DEFINE SIT_MINSOCIOCAN   "B"  // Minuta Sócio Cancelada
#DEFINE SIT_EMREVISAO     "C"  // Em Revisão
#DEFINE SIT_REVISADA      "D"  // Revisada
#DEFINE SIT_REVISRESTRI   "E"  // Revisada com Restrições
#DEFINE SIT_SINCRONIZANDO "F"  // Aguardando Sincronização
#DEFINE SIT_FATEMITIDA    "G"  // Fatura Emitida
#DEFINE SIT_CANCREVISAO   "H"  // Cancelada pela Revisão

#DEFINE TB_NVV 1
#DEFINE TB_NX8 2
#DEFINE TB_NT1 3
#DEFINE TB_NX1 4
#DEFINE TB_NUE 5
#DEFINE TB_NVY 6
#DEFINE TB_NV4 7
#DEFINE TB_NX2 8

#DEFINE _RECNO_    1
#DEFINE GRUPO      2
#DEFINE CLIENTE    3
#DEFINE LOJA       4
#DEFINE CASO       5
#DEFINE PREFATURA  6

#DEFINE CAMPOS_TABELA    1
#DEFINE CAMPOS_ADICIONAR 2
#DEFINE CAMPOS_REMOVER   3
#DEFINE CAMPOS_ORDEM     4

#DEFINE POS_NX2_CLTAB  1
#DEFINE POS_NX2_TEMPOR 2
#DEFINE POS_NX2_VALORH 3
#DEFINE POS_NX2_CMOPRE 4
#DEFINE POS_NX2_CMOTBH 5
#DEFINE POS_NX2_HFCLI  6
#DEFINE POS_NX2_UTR    7
#DEFINE POS_NX2_HORAR  8
#DEFINE POS_NX2_UTLANC 9
#DEFINE POS_NX2_HFLANC 10
#DEFINE POS_NX2_HRLANC 11
#DEFINE POS_NX2_UTCLI  12
#DEFINE POS_NX2_HRCLI  13
#DEFINE POS_NX2_VLHTBH 14
#DEFINE POS_NX2_VALOR1 15
#DEFINE POS_NX2_CPART  16
#DEFINE POS_NX2_CCATEG 17
#DEFINE POS_NX2_CODSEQ 18

#DEFINE POS_NUE_CPART2 1
#DEFINE POS_NUE_CCATEG 2
#DEFINE POS_NUE_VALORH 3
#DEFINE POS_NUE_CLTAB  4
#DEFINE POS_NUE_CMOEDA 5
#DEFINE POS_NUE_COD    6
#DEFINE POS_NUE_SITUAC 7
#DEFINE POS_NUE_VALOR  8
#DEFINE POS_NUE_VALOR1 9
#DEFINE POS_NUE_CATIVI 10
#DEFINE POS_NUE_TEMPOR 11
#DEFINE POS_NUE_HORAR  12
#DEFINE POS_NUE_CCLIEN 13
#DEFINE POS_NUE_CLOJA  14
#DEFINE POS_NUE_CCASO  15
#DEFINE POS_NUE_CMOED1 16
#DEFINE POS_NUE_UTR    17
#DEFINE POS_NUE_UTL    18
#DEFINE POS_NUE_TEMPOL 19
#DEFINE POS_NUE_CPREFT 20
#DEFINE POS_NUE_CPART1 21
#DEFINE POS_NUE_TKRET  22

#define POS_NX1_VTS    1
#define POS_NX1_VTAB   2
#define POS_NX1_VTSTAB 3
#define POS_NX1_VDESCO 4
#define POS_NX1_VDESCT 5
#define POS_NX1_CCLIEN 6
#define POS_NX1_CLOJA  7
#define POS_NX1_DCLIEN 8
#define POS_NX1_CCONTR 9
#define POS_NX1_DCONTR 10
#define POS_NX1_CCASO  11
#define POS_NX1_DCASO  12

#define POS_NX0_CMOEDA 1
#define POS_NX0_DMOEDA 2
#define POS_NX0_DTEMI  3
#define POS_NX0_COD    4
#define POS_NX0_ALTPER 5

#define POS_NV4_COD    1
#define POS_NV4_CMOEH  2
#define POS_NV4_VLHFAT 3
#define POS_NV4_CTPSRV 4

Static lCancPre        := .F. //Cancela Pre ao termino da funcao (apos commit)
Static cNX0ObsFat      := ''
Static aAltPend        := {}  //Array com as alterações de período
Static oModelOld       := Nil
Static cAlert          := ""

Static lJURA202        := .F.
Static lAltPerio       := .F.
Static lTelaRat        := .F. //Controla a abertura da tela de rateio (a alteração por perido permite altera o desc sem precisar abrir o rateio)

Static lIntegracao     := .F.
Static lIntRevis       := .F.
Static lRevisLD        := .F.
Static lLibParam       := .T. //Se MV_JCORTE preenchido corretamente

Static aPart           := {}
Static aCasos          := {}
Static aTSheets        := {}
Static aLancDiv        := {} // array para guardar as informações para a funçao de Divisão lançamentos
Static aDespDiv        := {} // array para estruturar as despesas divididas e ajustar o saldo, se necessÃ¡rio (ajuste de arredondamento)
Static cInstanc        := "" // variavel de controle o nivel de alteração de valor na pré-faura (NX0,NX8,NX1,NX2)
Static aRmvLanc        := {} // array para guardar os lançamentos removidos para remover tambem seus respectivos vinculos.

Static lAcumula        := .F. //variável criada devido a rotina de retirar os lançamentos ao salvar
Static lRevisa         := .F.
Static oBrwCasos       := Nil
Static __aGridPos      := {} // Uso no reposicionamento dos GRIDs apos salvar
Static __cLastPFat     := ''
Static __aNX2PosFields := Nil
Static __aNUEPosFields := Nil
Static __aNX1PosFields := Nil
Static __aNX0PosFields := Nil
Static __aNV4PosFields := Nil
Static __InMsgRun      := .F.
Static __lExibeOK      := .T.
Static __lOpera        := .F.
Static oMemo           := Nil // Objeto do campo memo lateral do grid de casos - Só visível quando usada a integração da tela de Revisão LD
Static cMemo           := ""  // Variavel do campo memo lateral do grid de casos - Só visível quando usada a integração da tela de Revisão LD

Static aAtivid         := {} //Array com os tipo de atividade do TS da pré-fatura (por demanda)
Static aParticip       := {} //Array com os participantes da pré-fatura (por demanda)
Static aMoeda          := {} //Array com as moedas da pré-fatura (por demanda)
Static aFaseEbi        := {} //Array com das informações de Fase e-billing (por demanda)

Static __aFieldsOrig   := {} //Estrutura original de campos dos modelos NX0 - NX1 - NUE - NVY - NV4
Static __cLogRest      := "" //Log de alterações via REST

Static __nQtdNX1       := 0
Static __nQtdNUE       := 0
Static __nQtdNVY       := 0
Static __nCountNX1     := 1
Static __nCountNUE     := 1
Static __nCountNVY     := 1

Static __oProcess      := Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA202
Operação da Pré-Fatura

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA202()
Local oFWLayer      := Nil
Local oPanelUp      := Nil
Local oPanelDown    := Nil
Local aCoors        := FwGetDialogSize( oMainWnd )
Local cFiltro       := ""
Local cNTYLegend    := ""
Local aExcetoSeq    := {}
Local cThreadID     := cValToChar(ThreadID())
Local cLojaAuto     := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local cFuncao       := Space(TamSX3("NTY_FUNCAO")[1])
Local oFilaExe      := JurFilaExe():New("JURA202", "", cThreadID)
Local lVldUser      := Iif(FindFunction("JurVldUxP"), JurVldUxP(), .T.) // Valida o participante relacionado ao usuário logado

Private oDlg202     := Nil
Private nOperacao   := 0
Private oRelation   := Nil
Private oMarkUp     := Nil

	// Chamada da tela de NPS
	If !IsBlind() .And. (FindFunction("PFSNPSAPP"))
		PFSNPSAPP(.F.)
	EndIf

	If lVldUser .And. oFilaExe:OpenWindow(.T.) //Indica que a tela está em execução para Thread de relatório
		
		lIntegracao  := (SuperGetMV("MV_JFSINC", .F., '2') == '1') //Adicionado para não afetar a performance da tela quando o parâmetro de fila de integração está desativado
		lIntRevis    := lIntegracao .And. (SuperGetMV("MV_JREVILD", .F., '2') == '1' ) //Controla a integracao da revisão de pré-fatura com o Legal Desk
		
		SetCloseThread(.F.)

		SetJura202(.T.)

		oFilaExe:StartReport() //Inicia a thread emissão do relatório

		Define MsDialog oDlg202 Title STR0001 From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] STYLE nOR( WS_VISIBLE, WS_POPUP ) Pixel //"Operação de Pré-Faturas"

		oFWLayer := FWLayer():New()
		oFWLayer:Init( oDlg202, .F., .T. )

		// Painel Superior
		oFWLayer:AddLine( 'UP', 50, .F. )
		oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )

		oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )

		// MarkBrowse Superior
		oMarkUp := FWMarkBrowse():New()
		oMarkUp:SetOwner( oPanelUp )
		oMarkUp:SetDescription( STR0002 ) //"Pré-Faturas"
		oMarkUp:SetAlias( 'NX0' )
		Iif(cLojaAuto == "1" .And. FindFunction("JurBrwRev"), JurBrwRev(oMarkUp, "NX0", {"NX0_CLOJA "}), ) //Proteção
		oMarkUp:SetMenuDef( 'JURA202' )
		oMarkUp:SetFieldMark( 'NX0_OK' )

		oMarkUp:SetProfileID( '1' ) // Deve ser diferente do ID do browse da JURA203
		oMarkUp:SetCacheView( .F. )
		oMarkUp:SetWalkThru(.F.)
		oMarkUp:SetAmbiente(.F.)
		oMarkUp:ForceQuitButton(.T.)
		oMarkUp:oBrowse:SetBeforeClose( {|| oMarkUp:oBrowse:VerifyLayout(), oBrwCasos:VerifyLayout()} )

		If ExistBlock( 'JA202FS' )
			cFiltro := ExecBlock( 'JA202FS', .F., .F. )
		EndIf

		If ValType( cFiltro ) == 'C'
			If !Empty( cFiltro )
				cFiltro := J202FMinut() + " .And. (" + cFiltro + " )"
			Else
				cFiltro := J202FMinut()
			EndIf
			oMarkUp:SetFilterDefault( cFiltro )
		EndIf

		If lIntRevis
			cNTYLegend := JurGetDados("NTY", 1, xFilial("NTY") + "NX0" + cFuncao + "001", "NTY_LEGEND")

			// Proteção que verifica se a legenda CONFERÊNCIA foi deletada - Isso é feito na função JURPFS7176 - RUP_PFS
			If AllTrim(cNTYLegend) == JurSitGet("1") // Conferência
				aExcetoSeq := {'009', '010', '011'}
			Else
				aExcetoSeq := {'008', '009', '010'}
			EndIf
		EndIf

		JurSetLeg( oMarkUp, 'NX0', , aExcetoSeq)
		oMarkUp:SetSemaphore() // Isto serve para deixar as marcaçõs bloqueadas por usuário.

		J202Filter(oMarkUp, cLojaAuto) // Adiciona filtros padrões no browse
		oMarkUp:Activate()

		// Painel Inferior
		oFWLayer:addLine( 'DOWN', 50, .F. )
		oFWLayer:AddCollumn( 'CASOS',  100, .T., 'DOWN' )
		oPanelDown := oFWLayer:GetColPanel( 'CASOS', 'DOWN' )

		// MarkBrowse de Casos
		oBrwCasos := FWMBrowse():New()
		oBrwCasos:SetOwner( oPanelDown )
		oBrwCasos:SetDescription( STR0004 ) //"Casos"
		oBrwCasos:SetMenuDef( 'JURA201' )   // Referencia uma funcao que nao tem menu para que exiba nenhum
		oBrwCasos:DisableDetails()
		oBrwCasos:SetAlias( 'NX1' )
		Iif(cLojaAuto == "1" .And. FindFunction("JurBrwRev"), JurBrwRev(oBrwCasos, "NX1", {"NX1_CLOJA "}), )//Proteção
		oBrwCasos:SetProfileID( '2' ) // Deve ser diferente do ID do browse da JURA203
		If lIntRevis .And. (NX1->( FieldPos( "NX1_INSREV" )) > 0)
			oBrwCasos:AddLegend( '!Empty(NX1_INSREV)', 'RED'  , STR0280 ) //"Possui instruções de revisão"
			oBrwCasos:AddLegend( 'Empty(NX1_INSREV)' , 'GREEN', STR0281 ) //"Sem instruções de revisão"
		EndIf
		oBrwCasos:Activate()

		oRelation := FWBrwRelation():New()
		oRelation:AddRelation( oMarkUp, oBrwCasos, { { 'NX1_FILIAL', "xFilial( 'NX1' )" }, { 'NX1_CPREFT', 'NX0_COD' } } )
		oRelation:Activate()

		Activate MsDialog oDlg202 Center

		oFilaExe:CloseWindow() // Indica que tela fechada para o client de impressão ser fechado também.

		SetJura202(.F.)

	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J202Filter
Adiciona filtros padrões no browse

@param  oBrowse, objeto, browse da rotina

@author Reginaldo Borges / Cristina Cintra
@since  08/08/2022
/*/
//-------------------------------------------------------------------
Static Function J202Filter(oBrowse, cLojaAuto)
Local cId      := "1"
Local aFilNX01 := {}
Local aFilNX02 := {}
Local aFilNX03 := {}
Local aFilNX04 := {}
Local aFilNX05 := {}

	oBrowse:AddFilter(STR0379, 'NX0_SITUAC $ "%1|2|3|4|5|6|7|9|A|B|C|D|E|F|G%"',,.F.,,,, cId) // "Somente válidas"

	SAddFilPar("NX0_SITUAC", "==", "%NX0_SITUAC0%", @aFilNX01)
	oBrowse:AddFilter(STR0380, 'NX0_SITUAC == "%NX0_SITUAC0%"', .F., .F., , .T., aFilNX01, STR0380) // "Situação"

	SAddFilPar("NX0_DTEMI", ">=", "%NX0_DTEMI0%", @aFilNX02)
	oBrowse:AddFilter(STR0381, 'NX0_DTEMI >= "%NX0_DTEMI0%"', .F., .F., , .T., aFilNX02, STR0381) // "Emissao Maior ou Igual a"

	SAddFilPar("NX0_DTEMI", "<=", "%NX0_DTEMI0%", @aFilNX03)
	oBrowse:AddFilter(STR0382, 'NX0_DTEMI <= "%NX0_DTEMI0%"', .F., .F., , .T., aFilNX03, STR0382) // "Emissao Menor ou Igual a"

	SAddFilPar("NX0_CPART", "==", "%NX0_CPART0%", @aFilNX04)
	oBrowse:AddFilter(STR0383, 'NX0_CPART == "%NX0_CPART0%"', .F., .F., , .T., aFilNX04, STR0383) // "Revisor"

	If cLojaAuto == "2"
		SAddFilPar("NX0_CCLIEN", "==", "%NX0_CCLIEN0%", @aFilNX05)
		SAddFilPar("NX0_CLOJA", "==", "%NX0_CLOJA0%", @aFilNX05)
		oBrowse:AddFilter(STR0384, 'NX0_CCLIEN == "%NX0_CCLIEN0%" .AND. NX0_CLOJA == "%NX0_CLOJA0%"', .F., .F., , .T., aFilNX05, STR0384) // "Cliente"
	Else
		SAddFilPar("NX0_CCLIEN", "==", "%NX0_CCLIEN0%", @aFilNX05)
		oBrowse:AddFilter(STR0384, 'NX0_CCLIEN == "%NX0_CCLIEN0%"', .F., .F., , .T., aFilNX05, STR0384) // "Cliente"
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@Return aRotina - Estrutura
[n, 1] Nome a aparecer no cabecalho
[n, 2] Nome da Rotina associada
[n, 3] Reservado
[n, 4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - SimplesmeNX0 Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n, 5] Nivel de acesso
[n, 6] Habilita Menu Funcional

@author Ernani Forastieri
@since 15/12/09
@version 1.00
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina   := {}
Local aSubSit   := {}
Local aSubRev   := {}
Local aSubTod   := {}
Local aMinuta   := {}
Local aPesq     := {}
Local cSituac2  := JurSitGet(SIT_ANALISE)
Local cSituac4  := JurSitGet(SIT_EMIFATURA)
Local cSituac5  := JurSitGet(SIT_EMIMINUTA)
Local cSituac9  := JurSitGet(SIT_MINSOCIO)
Local cSituacC  := ""
Local lMvAprMin := SuperGetMV("MV_JAPRMIN", .F., .F.)

//SubMenu de Situação da Pré-fatura
aAdd( aSubSit, { cSituac2, "JA202SIT( '" + SIT_ANALISE   + "' ) ", 0, 4, 0, Nil } ) // "Análise"
aAdd( aSubSit, { cSituac5, "JA202SIT( '" + SIT_EMIMINUTA + "' ) ", 0, 4, 0, Nil } ) // "Minuta"
aAdd( aSubSit, { cSituac4, "JA202SIT( '" + SIT_EMIFATURA + "' ) ", 0, 4, 0, Nil } ) // "Definitivo"
If !lIntRevis
	aAdd( aSubSit, { cSituac9, "JA202SIT( '" + SIT_MINSOCIO + "' ) ", 0, 4, 0, Nil } )  // "Minuta Sócio"
EndIf
If lIntRevis
	cSituacC  := JurSitGet(SIT_EMREVISAO)
	aAdd( aSubSit, { cSituacC, "JA202SIT( '" + SIT_EMREVISAO + "' ) ", 0, 4, 0, Nil } ) //"Em Revisão"
EndIf

//SubMenu de Revisão da Pré-fatura
If lIntRevis
	aAdd( aSubRev, { STR0274, 'JUR202Revs()', 0, 6, 0, Nil } ) //"Alterar Revisor"
	aAdd( aSubRev, { STR0279, 'JA202PSinc()', 0, 8, 0, Nil } ) //"Pré-faturas não sincronizadas"
Else
	aAdd( aSubRev, { STR0011, "JA202REV( '1' )", 0, 4, 0, Nil } ) //"Envio"
	aAdd( aSubRev, { STR0012, "JA202REV( '2' )", 0, 4, 0, Nil } ) //"Retorno"
	aAdd( aSubRev, { STR0013, "JA202REV( '3' )", 0, 4, 0, Nil } ) //"Emitir Fatura"
	aAdd( aSubRev, { STR0014, "JA202REV( '4' )", 0, 4, 0, Nil } ) //"Emitir Minuta"
EndIf

aAdd( aSubTod, { STR0201, 'JBrwMarkAll(oMarkUp)', 0, 1, 0, Nil } ) // "Inverter seleção"

aAdd( aMinuta, { STR0104, 'JA203BASS( oMarkUp )', 0, 5, 0, Nil } ) //"Fila"
aAdd( aMinuta, { STR0066, 'J202EmitM( oMarkUp )', 0, 3, 0, Nil } ) //"Emitir"

If lMvAprMin
	aAdd( aMinuta, { STR0353, 'J202AprvM( oMarkUp )', 0, 3, 0, Nil } ) //"Aprovar"
EndIf

aAdd( aPesq,   { STR0017, 'PesqBrw'             , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aPesq,   { STR0152, 'JFiltraCaso( oMarkUp )', 0, 3, 0, .T. } ) //"Filtro por Caso"
If !IsBlind() //Contorno para o erro do FW em não tratar menus com submenu (Array) - ISSUE DFRM1-5989
	aAdd( aRotina, { STR0017, aPesq             , 0, 1, 0, .T. } ) //"Pesquisar"

	aAdd( aRotina, { STR0018, 'VIEWDEF.JURA202', 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0019, 'JA202SBOT( 4 ) ', 0, 4, 0, Nil } ) //"Alterar"

	aAdd( aRotina, { STR0021, aSubSit          , 0, 0, 0, Nil } ) //"Situação"
	aAdd( aRotina, { STR0022, aSubRev          , 0, 0, 0, Nil } ) //"Revisão"
	aAdd( aRotina, { STR0023, aSubTod          , 0, 0, 0, Nil } ) //"Todos"
	aAdd( aRotina, { STR0006, aMinuta          , 0, 0, 0, Nil } ) //"Minuta"
EndIf
aAdd( aRotina, { STR0024, 'JA202CANC()'     , 0, 1, 0, Nil } ) //"Cancelar"
aAdd( aRotina, { STR0025, 'J202RefPre()'    , 0, 6, 0, Nil } ) //"Refazer"
aAdd( aRotina, { STR0200, "JA202VIEW('BROWSE', Nil)", 0, 6, 0, Nil } ) //"Resumo" // exibe os totais da pré"
aAdd( aRotina, { STR0352, "JURA202G( oMarkUp )"              , 0, 4, 0, Nil } ) //"Registro de cobrança"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Pré-Fatura

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local aAux         := {}
Local oModel       := FWLoadModel( 'JURA202' )
Local oStructNT1   := FWFormStruct( 2, 'NT1' )  // Fixo
Local oStructNUE   := FWFormStruct( 2, 'NUE' )  // Time Sheet
Local oStructNV4   := FWFormStruct( 2, 'NV4' )  // Tabelado
Local oStructNVV   := FWFormStruct( 2, 'NVV' )  // Fat. Adicional
Local oStructNVY   := FWFormStruct( 2, 'NVY' )  // Despesas
Local oStructNX0   := FWFormStruct( 2, 'NX0' )  // Pre-fatura
Local bNCalcNX1    := {|xAux| !AllTrim(xAux) $ 'NX1_CONTTS|NX1_CONTDP|NX1_CONTLT|NX1_CIDIO|NX1_INSREV'}
Local oStructNX1   := FWFormStruct( 2, 'NX1', bNCalcNX1 )  // Caso
Local bCalcNX1     := {|xAux| AllTrim(xAux) $ 'NX1_CONTTS|NX1_CONTDP|NX1_CONTLT'}
Local oCalcNX1     := FWFormStruct( 2, 'NX1', bCalcNX1) //Calc do Caso
Local oStructNX2   := FWFormStruct( 2, 'NX2' )  // Participante
Local oStructNX4   := FWFormStruct( 2, 'NX4' )  // Historico de Cobrança
Local oStructNX8   := FWFormStruct( 2, 'NX8' )  // Contrato
Local oStructNXG   := FWFormStruct( 2, 'NXG' )  // Pagadores
Local oStructNVN   := FWFormStruct( 2, 'NVN' )  // Encaminhamento de Fatura
Local oStructNXR   := FWFormStruct( 2, 'NXR' )  // Cotações
Local oStructOHN   := Nil                       // Sócios/Revisores
Local cParam       := AllTrim(SuperGetMv('MV_JDOCUME',, '1'))
Local cLojaAuto    := SuperGetMv( "MV_JLOJAUT", .F., "2", ) // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local lMultRevis   := ( SuperGetMV("MV_JMULTRV",, .F.) .And. (SuperGetMV("MV_JREVILD",, '2') == '1') .And. FWAliasInDic("OHN") ) // Indica se é utilizado o conceito de múltiplos revisores e a revisão de pré-fatura do LD.
Local lApuraTS     := SuperGetMv( "MV_JTSPEND", .F., .F., ) // Indica se no momento da emissão da pré-fatura serão calculados os Time Sheets pendentes e em minuta (.T. ou .F.)
Local lCpoTSNCob   := NX1->(ColumnPos("NX1_VTSNC")) > 0 // @12.1.2210

Local aCampos      := {}
Local aRelation    := {}
Local aStructs     := {}
Local lJA202FLDS   := ExistBlock('JA202FLDS')
Local nX           := 0
Local nY           := 0
Local nZ           := 0
Local nPos         := 0
Local oView        := Nil
Local lTemFat	   := JA201TemFt(NX0->NX0_COD)
Local aLgpd        := {}

Local lProtNX1     := NX1->(ColumnPos("NX1_CONTTS")) > 0 .Or. ;
                      NX1->(ColumnPos("NX1_CONTDP")) > 0 .Or. ;
                      NX1->(ColumnPos("NX1_CONTLT")) > 0 // Proteção - DJURFAT1-3129

//Necessário para possibilitar a chamada fora da JURA202 - Não utilizar nas outras privates pois onera a função.
//_SetOwnerPrvt - Define a varíavel como private na instância acima.
If Type('nOperacao') == "U"
	_SetOwnerPrvt("nOperacao")
	nOperacao := 0
EndIf

If !lIntegracao .And. NX8->(ColumnPos("NX8_CLOJCM")) > 0 //Proteção
	oStructNX8:RemoveField( 'NX8_CCLICM' )
	oStructNX8:RemoveField( 'NX8_CLOJCM' )
	oStructNX8:RemoveField( 'NX8_CCASCM' )
EndIf

If (cLojaAuto == "1") .And. NX8->(ColumnPos("NX8_CLOJCM")) > 0 //Loja automatica //Proteção
	oStructNVV:RemoveField( "NVV_CLOJA" )
	oStructNUE:RemoveField( "NUE_CLOJA" )
	oStructNX2:RemoveField( "NX2_CLOJA" )
	oStructNX8:RemoveField( "NX8_CLOJA" )
	oStructNX1:RemoveField( "NX1_CLOJA" )
	oStructNX0:RemoveField( "NX0_CLOJA" )
	oStructNX8:RemoveField( 'NX8_CLOJCM' )
EndIf

If lCpoTSNCob .And. !SuperGetMV( "MV_JTSNCOB",, .F. ) // Indica se vincula TimeSheet não cobrável na emissão
	oStructNX1:RemoveField( "NX1_VTSNC" )
	oStructNX8:RemoveField( "NX8_VTSNC" )
EndIf

If !lApuraTS .And. NX8->(ColumnPos("NX8_VLTSPD")) > 0
	oStructNX8:RemoveField( "NX8_VLTSPD" )
	oStructNX8:RemoveField( "NX8_VLTSMI" )
EndIf

oStructNV4:RemoveField('NV4_CPART')

oStructNVY:RemoveField('NVY_CPART')
If !SuperGetMV("MV_JURXFIN",, .F.) .And. NVY->(ColumnPos("NVY_ITDPGT")) > 0//Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico //Proteção
	oStructNVY:RemoveField("NVY_CLANC")
	oStructNVY:RemoveField("NVY_CPAGTO")
	oStructNVY:RemoveField("NVY_ITDES")
	oStructNVY:RemoveField("NVY_ITDPGT")
EndIf

oStructNX0:RemoveField( 'NX0_CTPHON' )
oStructNX0:RemoveField( 'NX0_DTPHON' )
oStructNX0:RemoveField( 'NX0_CPART' )
oStructNX0:RemoveField( 'NX0_OK' )
If lIntRevis
	oStructNX0:RemoveField( 'NX0_SITCB' )
	oStructNX0:RemoveField( 'NX0_DSITCB' )
EndIf

oStructNX1:RemoveField( 'NX1_CPART' )
oStructNX1:RemoveField( 'NX1_VHON'  )
If !lIntRevis .And. ( NX1->( FieldPos( "NX1_SITREV" )) > 0 .And. NX1->( FieldPos( "NX1_DESCEX" )) > 0 .And. NX1->( FieldPos( "NX1_RETREV" )) > 0 )
	oStructNX1:RemoveField( 'NX1_SITREV' )
	oStructNX1:RemoveField( 'NX1_DESCEX' )
	oStructNX1:RemoveField( 'NX1_RETREV' )
	oStructNX1:RemoveField( 'NX1_DRETRV' )
	oStructNX1:RemoveField( 'NX1_INSREV' )
	oStructNX1:RemoveField( 'NX1_INSFAT' )
EndIf

If !lIntRevis .And. NT1->( FieldPos( "NT1_ACAOLD" )) > 0
	oStructNT1:RemoveField( 'NT1_ACAOLD' )
	oStructNT1:RemoveField( 'NT1_INSREV' )
	oStructNT1:RemoveField( 'NT1_REVISA' )
EndIf

oStructNX8:RemoveField( 'NX8_CPART' )

oStructNT1:RemoveField( 'NT1_CCLIEN' )    //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
oStructNT1:RemoveField( 'NT1_CLOJA'  )    //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
oStructNT1:RemoveField( 'NT1_CTPHON' )    //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
oStructNT1:RemoveField( 'NT1_DCLIEN' )    //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
oStructNT1:RemoveField( 'NT1_DCONTR' )    //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
oStructNT1:RemoveField( 'NT1_DTPHON' )    //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )

oStructNT1:RemoveField( "NT1_DTAEMI" )  //Campos Virtuais utilizados na rotina JURA203
oStructNVV:RemoveField( "NVV_DTAEMI" )  //Campos Virtuais utilizados na rotina JURA203

oStructNXG:RemoveField( "NXG_CCONTR" )
oStructNXG:RemoveField( "NXG_CFATAD" )
oStructNXG:RemoveField( "NXG_COD" )
oStructNXG:RemoveField( "NXG_DTVENC" )
oStructNXG:RemoveField( "NXG_FILA" )
If NXG->(ColumnPos('NXG_PIRRF')) > 0 .And. NXG->(ColumnPos('NXG_PPIS')) > 0 .And. NXG->(ColumnPos('NXG_PCOFIN')) > 0 ;  //Proteção
	.And. NXG->(ColumnPos('NXG_PCSLL')) > 0 .And. NXG->(ColumnPos('NXG_PINSS')) > 0 .And. NXG->(ColumnPos('NXG_PISS')) > 0  //Proteção
	oStructNXG:RemoveField( "NXG_PIRRF" )
	oStructNXG:RemoveField( "NXG_PPIS" )
	oStructNXG:RemoveField( "NXG_PCOFIN" )
	oStructNXG:RemoveField( "NXG_PCSLL" )
	oStructNXG:RemoveField( "NXG_PINSS" )
	oStructNXG:RemoveField( "NXG_PISS" )
EndIf
oStructNVN:RemoveField( "NVN_CCONTR" )
oStructNVN:RemoveField( "NVN_CFATAD" )
oStructNVN:RemoveField( "NVN_CJCONT" )
oStructNVN:RemoveField( "NVN_CLIPG"  )
oStructNVN:RemoveField( "NVN_LOJPG"  )
oStructNVN:RemoveField( "NVN_CPREFT" )
If NVN->(ColumnPos("NVN_CFIXO")) > 0
	oStructNVN:RemoveField( 'NVN_CFIXO' )
EndIf
If NVN->(ColumnPos("NVN_CFILA")) > 0 //Proteção
	oStructNVN:RemoveField( "NVN_CFILA" )
	oStructNVN:RemoveField( "NVN_CESCR" )
	oStructNVN:RemoveField( "NVN_CFATUR" )
EndIf

oStructNX2:RemoveField( "NX2_CPART" )

If NX4->(FieldPos('NX4_TIPO')) > 0 .And. !lIntRevis
	oStructNX4:RemoveField( "NX4_TIPO" )
EndIf
oStructNX4:RemoveField( "NX4_CPART" )
If NX4->(ColumnPos("NX4_CPART1")) > 0 //Proteção 12.1.33
	oStructNX4:RemoveField( "NX4_USRINC" )
	oStructNX4:RemoveField( "NX4_CPART1" )
EndIf
//Revisão pelo LD desabilita os campos de Revisor
If lIntRevis
	oStructNX4:RemoveField( "NX4_SIGLA" )
	oStructNX4:RemoveField( "NX4_DPART" )
EndIf

oStructNXR:RemoveField( "NXR_ORIGEM")

oStructNUE:RemoveField( "NUE_CCATEG" )
oStructNUE:RemoveField( "NUE_CPART1" )
oStructNUE:RemoveField( "NUE_CPART2" )
oStructNUE:RemoveField( "NUE_CUSERA" )
oStructNUE:RemoveField( "NUE_ANOMES" )

If NUE->(FieldPos( "NUE_FLUREV" )) > 0
	If !lIntRevis
		oStructNUE:RemoveField( 'NUE_FLUREV' )
		oStructNUE:RemoveField( 'NUE_SIGLAR' )
		oStructNUE:RemoveField( 'NUE_DREPRO' )
		oStructNUE:RemoveField( 'NUE_DTREPR' )
	EndIf
	oStructNUE:RemoveField( 'NUE_CREPRO' )
EndIf

If !lIntRevis

	// Para os parâmetros MV_JFSINC = 2 (Não) e MV_JREVILD = 2 (Não),
	// o sistema não exibe os campos de Operações (Ações no LD, Cliente transf.,
	// Loja transf., Caso transf., Part WO, Cod. Motivo WO, Obs WO, Cod WO LD)
	// na operação da pré-fatura

	// Time Sheet
	If NUE->( FieldPos( "NUE_ACAOLD" )) > 0
		oStructNUE:RemoveField("NUE_ACAOLD")
		oStructNUE:RemoveField("NUE_CCLILD")
		oStructNUE:RemoveField("NUE_CLJLD")
		oStructNUE:RemoveField("NUE_CCSLD")
		oStructNUE:RemoveField("NUE_PARTLD")
		oStructNUE:RemoveField("NUE_CMOTWO")
		oStructNUE:RemoveField("NUE_OBSWO")
		oStructNUE:RemoveField("NUE_CDWOLD")
	EndIf

	// Despesa
	If NVY->( FieldPos( "NVY_ACAOLD" )) > 0
		oStructNVY:RemoveField("NVY_ACAOLD")
		oStructNVY:RemoveField("NVY_CCLILD")
		oStructNVY:RemoveField("NVY_CLJLD")
		oStructNVY:RemoveField("NVY_CCSLD")
		oStructNVY:RemoveField("NVY_PARTLD")
		oStructNVY:RemoveField("NVY_CMOTWO")
		oStructNVY:RemoveField("NVY_OBSWO")
		oStructNVY:RemoveField("NVY_CDWOLD")
	EndIf
	
	If NVY->(ColumnPos("NVY_CMOTWR")) > 0
		oStructNVY:RemoveField("NVY_CMOTWR")
		oStructNVY:RemoveField("NVY_DMOTWR")
	EndIf

	// Tabelado
	If NV4->( FieldPos( "NV4_ACAOLD" )) > 0
		oStructNV4:RemoveField("NV4_ACAOLD")
		oStructNV4:RemoveField("NV4_CCLILD")
		oStructNV4:RemoveField("NV4_CLJLD")
		oStructNV4:RemoveField("NV4_CCSLD")
		oStructNV4:RemoveField("NV4_PARTLD")
		oStructNV4:RemoveField("NV4_CMOTWO")
		oStructNV4:RemoveField("NV4_OBSWO")
		oStructNV4:RemoveField("NV4_CDWOLD")
	EndIf

EndIf

If NUE->(ColumnPos('NUE_COTAC')) > 0 //Proteção
	oStructNUE:RemoveField( "NUE_COTAC" )
	oStructNV4:RemoveField( "NV4_COTAC" )
	oStructNVY:RemoveField( "NVY_COTAC" )
	oStructNT1:RemoveField( "NT1_COTAC" )
EndIf

If NUE->(FieldPos( "NUE_CODLD" )) > 0 //Proteção
	oStructNUE:RemoveField( "NUE_CODLD" )
EndIf

If lMultRevis
	oStructOHN := FWFormStruct( 2, "OHN" )
	oStructOHN:RemoveField( "OHN_CCLIEN" )
	oStructOHN:RemoveField( "OHN_CLOJA"  )
	oStructOHN:RemoveField( "OHN_CCASO"  )
	oStructOHN:RemoveField( "OHN_CPREFT" )
	oStructOHN:RemoveField( "OHN_CPART"  )
	If OHN->(ColumnPos("OHN_CCONTR")) > 0 // Proteção
		oStructOHN:RemoveField( "OHN_CCONTR" )
	EndIf
EndIf

JurSetAgrp("NX0",, oStructNX0)

// Retira os campos de relacionamento dos grids
aAux := oModel:GetModel( 'NX0MASTER' ):GetRelation()
aEVal( aAux[1], { | aX | oStructNX0:RemoveField( aX[1] ) } )
aAux := oModel:GetModel( 'NX8DETAIL' ):GetRelation()
aEVal( aAux[1], { | aX | oStructNX8:RemoveField( aX[1] ) } )
aAux := oModel:GetModel( 'NX4DETAIL' ):GetRelation()
aEVal( aAux[1], { | aX | oStructNX4:RemoveField( aX[1] ) } )
aAux := oModel:GetModel( 'NVVDETAIL' ):GetRelation()
aEVal( aAux[1], { | aX | oStructNVV:RemoveField( aX[1] ) } )
aAux := oModel:GetModel( 'NX1DETAIL' ):GetRelation()
aEVal( aAux[1], { | aX | oStructNX1:RemoveField( aX[1] ) } )
aAux := oModel:GetModel( 'NT1DETAIL' ):GetRelation()
aEVal( aAux[1], { | aX | oStructNT1:RemoveField( aX[1] ) } )
aAux := oModel:GetModel( 'NX2DETAIL' ):GetRelation()
aEVal( aAux[1], { | aX | oStructNX2:RemoveField( aX[1] ) } )
aAux := oModel:GetModel( 'NUEDETAIL' ):GetRelation()
aEVal( aAux[1], { | aX | oStructNUE:RemoveField( aX[1] ) } )
aAux := oModel:GetModel( 'NVYDETAIL' ):GetRelation()
aEVal( aAux[1], { | aX | oStructNVY:RemoveField( aX[1] ) } )
aAux := oModel:GetModel( 'NV4DETAIL' ):GetRelation()
aEVal( aAux[1], { | aX | oStructNV4:RemoveField( aX[1] ) } )
aAux := oModel:GetModel( 'NXGDETAIL' ):GetRelation()
aEVal( aAux[1], { | aX | oStructNXG:RemoveField( aX[1] ) } )
aAux := oModel:GetModel( 'NVNDETAIL' ):GetRelation()
aEVal( aAux[1], { | aX | oStructNVN:RemoveField( aX[1] ) } )
aAux := oModel:GetModel( 'NXRDETAIL' ):GetRelation()
aEVal( aAux[1], { | aX | oStructNXR:RemoveField( aX[1] ) } )

//--------------------------------------------------------------------
//PE - Manipulacao dos campos
//--------------------------------------------------------------------
If lJA202FLDS

	aCampos := ExecBlock('JA202FLDS', .F., .F.)

	// Vetor retorno JA202FLDS
	//
	// [1]  C   Tabela
	// [2]  A   Campos a incluir
	//   [n]      Nome do campo
	// [3]  A   Campos a remover
	//   [n]      Nome do campo
	// [4]  A   Campos para trocar a ordem
	//   [n][1]   Nome do campo
	//   [n][2]   Ordem
	//
	// Exemplo:
	//
	//   User Function JA202STRU()
	//   Local aRet    := {}
	//   Local aAux    := {}
	//
	//   aAux := {}
	//   AAdd( aAux, 'NUE' )  				 	 // Tabela
	//   AAdd( aAux, { 'NUE_CCASO' } ) 			 // Campos a incluir
	//   AAdd( aAux, { 'NUE_UTR', 'NUE_UTL'} )   // Campos a remover
	//   AAdd( aAux, { { 'NUE_CCASO', '03'}, { 'NUE_DATATS', '04'}, { 'NUE_SIGLA2', '05'} } ) // Campos para trocar ordem
	//
	//   AAdd( aRet, aAux )
	//
	//   AAdd := {}
	//   AAdd( aAux, 'NX1' ) 					 // Tabela
	//   AAdd( aAux, { 'NX1_CCONTR' } )  		 // Campos a incluir
	//   AAdd( aAux, Nil )  					 // Campos a remover
	//   AAdd( aAux, { { 'NX1_CCONTR','03' } } ) // Campos para trocar ordem
	//
	//   AAdd( aRet, aAux )
	//
	//   Return aRet

	If ValType( aCampos ) == 'A'

		For nX := 1 To Len( aCampos )
			For nY := Len( aCampos[nX] ) + 1 To 4
				aAdd( aCampos[nX], {} )
			Next

			If aCampos[nX][2] == Nil
				aCampos[nX][2]  := {}
			ElseIf aCampos[nX][3] == Nil
				aCampos[nX][3]  := {}
			ElseIf aCampos[nX][4] == Nil
				aCampos[nX][4]  := {}
			EndIf

		Next

		aStructs := { ;
		{ 'NX0', oStructNX0, 'NX0MASTER' },;
		{ 'NT1', oStructNT1, 'NT1DETAIL' },;
		{ 'NUE', oStructNUE, 'NUEDETAIL' },;
		{ 'NV4', oStructNV4, 'NV4DETAIL' },;
		{ 'NVV', oStructNVV, 'NVVDETAIL' },;
		{ 'NVY', oStructNVY, 'NVYDETAIL' },;
		{ 'NX1', oStructNX1, 'NX1DETAIL' },;
		{ 'NX2', oStructNX2, 'NX2DETAIL' },;
		{ 'NX4', oStructNX4, 'NX4DETAIL' },;
		{ 'NX8', oStructNX8, 'NX8DETAIL' },;
		{ 'NXG', oStructNXG, 'NXGDETAIL' },;
		{ 'NVN', oStructNVN, 'NVNDETAIL' },;
		{ 'NXR', oStructNXR, 'NXRDETAIL' } }

		For nZ := 1 To Len( aStructs )

			If ( nPos := aScan( aCampos, { |aX| aX[CAMPOS_TABELA] == aStructs[nZ][1] } ) ) > 0

				//Adiciona Campos
				If Len( aCampos[nPos][CAMPOS_ADICIONAR] ) > 0

					aRelation := oModel:GetModel( aStructs[nZ][3] ):GetRelation()
					aLgpd     := {}

					For nX := 1 To Len( aCampos[nPos][CAMPOS_ADICIONAR] )

						If !aStructs[nZ][2]:HasField( aCampos[nPos][CAMPOS_ADICIONAR][nX] )

							AddCampo( 2, aCampos[nPos][CAMPOS_ADICIONAR][nX], aStructs[nZ][2] )

							aAdd(aLgpd, {aCampos[nPos][CAMPOS_ADICIONAR][nX], aCampos[nPos][CAMPOS_ADICIONAR][nX]})

							If aScan( aRelation[1], { |aX| aX[1] == aCampos[nPos][CAMPOS_ADICIONAR][nX] } ) > 0
								aStructs[nZ][2]:SetProperty( aCampos[nPos][CAMPOS_ADICIONAR][nX], MVC_VIEW_CANCHANGE, .F. )
							EndIf

						EndIf

					Next

					If FindFunction("JPDOfusca")
						JPDOfusca(@aStructs[nZ][2], aLgpd)
					EndIf

				EndIf

				//Remove Campos
				For nX := 1 To Len( aCampos[nPos][CAMPOS_REMOVER] )
					If aStructs[nZ][2]:HasField( aCampos[nPos][CAMPOS_REMOVER][nX] )
						aStructs[nZ][2]:RemoveFields( aCampos[nPos][CAMPOS_REMOVER][nX] )
					EndIf
				Next

				// Ordem
				For nX := 1 To Len( aCampos[nPos][CAMPOS_ORDEM] )
					aStructs[nZ][2]:SetOrder( aCampos[nPos][CAMPOS_ORDEM][nX][1], aCampos[nPos][CAMPOS_ORDEM][nX][2] )
				Next

			EndIf

		Next

	Else

		aCampos := {}

	EndIf

EndIf

oView := FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'JURA202_NX0', oStructNX0, 'NX0MASTER' )
oView:AddGrid(  'JURA202_NT1', oStructNT1, 'NT1DETAIL' )
oView:AddGrid(  'JURA202_NUE', oStructNUE, 'NUEDETAIL' )
oView:AddGrid(  'JURA202_NV4', oStructNV4, 'NV4DETAIL' )
oView:AddGrid(  'JURA202_NVV', oStructNVV, 'NVVDETAIL' )
oView:AddGrid(  'JURA202_NVY', oStructNVY, 'NVYDETAIL' )
oView:AddGrid(  'JURA202_NX1', oStructNX1, 'NX1DETAIL' )

If lProtNX1 // Proteção
	oView:AddField( 'JURA202_CALC1', oCalcNX1, 'NX1CALC' )
EndIf

If lMultRevis
	oView:AddGrid( "JURA202_OHN", oStructOHN, "OHNDETAIL" )
EndIf

oView:AddGrid( 'JURA202_NX2', oStructNX2, 'NX2DETAIL' )
oView:AddGrid( 'JURA202_NX4', oStructNX4, 'NX4DETAIL' )
oView:AddGrid( 'JURA202_NX8', oStructNX8, 'NX8DETAIL' )
oView:AddGrid( 'JURA202_NXG', oStructNXG, 'NXGDETAIL' )
oView:AddGrid( 'JURA202_NVN', oStructNVN, 'NVNDETAIL' )
oView:AddGrid( 'JURA202_NXR', oStructNXR, 'NXRDETAIL' )

oView:CreateHorizontalBox( 'CAPA', 100 )

oView:CreateFolder( 'FOLDER_01', 'CAPA' )
oView:AddSheet( 'FOLDER_01', 'ABA_01', STR0026 ) //"Pré-Fatura"
oView:AddSheet( 'FOLDER_01', 'ABA_02', STR0027 ) //"Fat. Adicional"
oView:AddSheet( 'FOLDER_01', 'ABA_03', STR0028 ) //"Histórico"
oView:AddSheet( 'FOLDER_01', 'ABA_04', STR0103 ) //"Divisão de Pré-Faturas"
oView:AddSheet( 'FOLDER_01', 'ABA_06', STR0191 ) //"Cotações da pré-fatura"
//Cria a aba de Revisão de pré:
If !lIntRevis .And. !(NX0->NX0_SITUAC == SIT_EMIFATURA .And. lTemFat)
	oView:AddSheet( 'FOLDER_01', 'ABA_05', STR0022, {|| ActiveRevisao(oView) } ) //"Revisão de Pré-Fatura"
EndIf
//Box da primeira aba - divididos
oView:CreateHorizontalBox( 'SUPERIOR', 35,,, 'FOLDER_01', 'ABA_01' )
oView:CreateHorizontalBox( 'INFERIOR', 65,,, 'FOLDER_01', 'ABA_01' )
//Box das demais - inteiros:
oView:CreateHorizontalBox( 'FOLDER_NVV', 100,,, 'FOLDER_01', 'ABA_02' )
oView:CreateHorizontalBox( 'FOLDER_NX4', 100,,, 'FOLDER_01', 'ABA_03' )

oView:CreateHorizontalBox( 'FOLDER_NXG', 50,,, 'FOLDER_01', 'ABA_04' ) //Pagadores
oView:CreateHorizontalBox( 'FOLDER_NVN', 50,,, 'FOLDER_01', 'ABA_04' ) //Encaminhamento
oView:EnableTitleView( "JURA202_NVN" )

oView:CreateHorizontalBox( 'FOLDER_NXR', 100,,, 'FOLDER_01', 'ABA_06' )
If !lIntRevis .And. !(NX0->NX0_SITUAC == SIT_EMIFATURA .And. lTemFat)
	oView:CreateHorizontalBox( 'FOLDER_REV', 100,,, 'FOLDER_01', 'ABA_05' )
EndIf
//Vincula os campos ao box superior
oView:SetOwnerView( 'JURA202_NX0', 'SUPERIOR' )

//Vincula os campos aos boxes das demais abas
oView:SetOwnerView( 'JURA202_NVV', 'FOLDER_NVV' )
oView:SetOwnerView( 'JURA202_NX4', 'FOLDER_NX4' )
oView:SetOwnerView( 'JURA202_NXG', 'FOLDER_NXG' )
oView:SetOwnerView( 'JURA202_NVN', 'FOLDER_NVN' )
oView:SetOwnerView( 'JURA202_NXR', 'FOLDER_NXR' )
//Cria as abas da primeira pagina
oView:CreateFolder( 'FOLDER_02', 'INFERIOR' )
oView:AddSheet( 'FOLDER_02', 'ABA_01', STR0003 ) //"Contratos"
oView:AddSheet( 'FOLDER_02', 'ABA_02', STR0029 ) //"Fixo"
oView:AddSheet( 'FOLDER_02', 'ABA_03', STR0004 ) //"Casos"
If lMultRevis
	oView:AddSheet( "FOLDER_02", "ABA_08", STR0304 ) // "Sócios/Revisores"
EndIf
oView:AddSheet( 'FOLDER_02', 'ABA_04', STR0030 ) //"Profissionais"
oView:AddSheet( 'FOLDER_02', 'ABA_05', STR0008 ) //"Time-Sheet"
oView:AddSheet( 'FOLDER_02', 'ABA_06', STR0009 ) //"Despesas"
oView:AddSheet( 'FOLDER_02', 'ABA_07', STR0010 ) //"Lanc.Tabelado"

//Cria os boxes das abas inferiores:
oView:CreateHorizontalBox( 'FOLDER_NX8', 100,,, 'FOLDER_02', 'ABA_01' ) // aba 1 - Contratos
oView:CreateHorizontalBox( 'FOLDER_NT1', 100,,, 'FOLDER_02', 'ABA_02' ) // aba 2 - Fixos
oView:CreateHorizontalBox( 'FOLDER_NX2', 100,,, 'FOLDER_02', 'ABA_04' ) // aba 4 - Profissionais
oView:CreateHorizontalBox( 'FOLDER_NUE', 100,,, 'FOLDER_02', 'ABA_05' ) // aba 5 - Time-Sheets
oView:CreateHorizontalBox( 'FOLDER_NVY', 100,,, 'FOLDER_02', 'ABA_06' ) // aba 6 - Despesas
oView:CreateHorizontalBox( 'FOLDER_NV4', 100,,, 'FOLDER_02', 'ABA_07' ) // aba 7 - Tabelados

//Cria uma área para exibir a instrução de revisor (memo) quando utilizada a integração com o Legal Desk
If lIntRevis .And. (NX1->( FieldPos( "NX1_INSREV" )) > 0)
	oView:CreateHorizontalBox( 'FOLDER_NX1', 100,,, 'FOLDER_02', 'ABA_03' ) // aba 3 - Casos
	oView:AddOtherObject('INSTRUCAO', {|oPainel| J202Memo(oPainel)}, {|| })
	oView:CreateVerticalBox('F_NX1_GRID', 80,'FOLDER_NX1',, 'FOLDER_02', 'ABA_03' ) // aba 3 - Casos: Grid de casos + Contador de lançamentos

	If lProtNX1 // Proteção

		oView:CreateHorizontalBox( 'GRID_NX1', 85, 'F_NX1_GRID',, 'FOLDER_02', 'ABA_03' ) // aba 3 - Casos: Grid de casos
		oView:SetOwnerView('JURA202_NX1', 'GRID_NX1')

		oView:CreateHorizontalBox( 'CALC1_NX1', 15, 'F_NX1_GRID',, 'FOLDER_02', 'ABA_03' ) // aba 3 - Casos: Contador de lançamentos
		oView:SetOwnerView('JURA202_CALC1', 'CALC1_NX1')

	Else

		oView:CreateHorizontalBox( 'GRID_NX1', 100, 'F_NX1_GRID',, 'FOLDER_02', 'ABA_03' ) // aba 3 - Casos: Grid de casos
		oView:SetOwnerView( 'JURA202_NX1', 'GRID_NX1')

	EndIf

	oView:CreateVerticalBox( 'F_NX1_MEMO', 20, 'FOLDER_NX1',, 'FOLDER_02', 'ABA_03' ) // aba 3 - Casos: Other objestcs do Memo
	oView:SetOwnerView( 'INSTRUCAO', 'F_NX1_MEMO')

	oView:SetViewProperty( 'JURA202_NX1', "CHANGELINE", {{ |oView| J202Memo(Nil, oView) }} ) //Refresh do campo Memo Caso
	oView:SetViewProperty( 'JURA202_NX8', "CHANGELINE", {{ |oView| J202Memo(Nil, oView) }} ) //Refresh do campo Memo Contrato
Else

	If lProtNX1 // Proteção

		oView:CreateHorizontalBox( 'FOLDER_NX1', 85,,, 'FOLDER_02', 'ABA_03' ) // aba 3 - Casos: Grid de casos
		oView:SetOwnerView( 'JURA202_NX1', 'FOLDER_NX1')

		oView:CreateHorizontalBox( 'CALC1_NX1', 15,,, 'FOLDER_02', 'ABA_03' ) // aba 3 - Casos: Contador de lançamentos
		oView:SetOwnerView( 'JURA202_CALC1','CALC1_NX1')
	Else

		oView:CreateHorizontalBox( 'FOLDER_NX1', 100,,, 'FOLDER_02', 'ABA_03' ) // aba 3 - Casos: Grid de casos
		oView:SetOwnerView( 'JURA202_NX1', 'FOLDER_NX1')

	EndIf
EndIf

If lMultRevis
	oView:CreateHorizontalBox("GRID_OHN", 100,,, "FOLDER_02", "ABA_08") // "Sócios/Revisores"
	oView:SetOwnerView( "JURA202_OHN", "GRID_OHN" )
EndIf

//Vincula os grids aos boxes das abas:
oView:SetOwnerView( 'JURA202_NX8', 'FOLDER_NX8' )
oView:SetOwnerView( 'JURA202_NT1', 'FOLDER_NT1' )
oView:SetOwnerView( 'JURA202_NX2', 'FOLDER_NX2' )
oView:SetOwnerView( 'JURA202_NUE', 'FOLDER_NUE' )
oView:SetOwnerView( 'JURA202_NVY', 'FOLDER_NVY' )
oView:SetOwnerView( 'JURA202_NV4', 'FOLDER_NV4' )

//Cria a aba de Revisão de pré:
If !lIntRevis .And. !(NX0->NX0_SITUAC == SIT_EMIFATURA .And. lTemFat )
	oView:AddOtherObject('JURA202_REV', {|oPanel| JA207REVPF(oPanel, oView)},,, .T.)
	oView:SetOwnerView('JURA202_REV', 'FOLDER_REV') // Associa ao box que ira exibir os outros objetos
EndIf

If nOperacao == OP_ALTERAR
	oView:SetNoInsertLine( 'JURA202_NX8' )
	oView:SetNoDeleteLine( 'JURA202_NX8' )

	oView:SetNoInsertLine( 'JURA202_NT1' )
	oView:SetNoDeleteLine( 'JURA202_NT1' )

	oView:SetNoInsertLine( 'JURA202_NX1' )
	oView:SetNoDeleteLine( 'JURA202_NX1' )

	oView:SetNoInsertLine( 'JURA202_NUE' )
	oView:SetNoDeleteLine( 'JURA202_NUE' )

	oView:SetNoInsertLine( 'JURA202_NVY' )
	oView:SetNoDeleteLine( 'JURA202_NVY' )

	oView:SetNoInsertLine( 'JURA202_NV4' )
	oView:SetNoDeleteLine( 'JURA202_NV4' )

	oView:SetNoInsertLine( 'JURA202_NX2' )
	oView:SetNoDeleteLine( 'JURA202_NX2' )

	oView:SetNoInsertLine( 'JURA202_NXR' )

	If !(NX0->NX0_SITUAC == SIT_EMIFATURA .And. lTemFat)
		oView:AddUserButton( STR0032, "SALVAR"        , { | oView, oButton | JA202REDA1( oView ) } ) //"Copiar Red. PF."
		oView:AddUserButton( STR0033, "EDITABLE"      , { | oView, oButton | JA202MNURED( oView, oButton ) } ) //"Redação"
		oView:AddUserButton( STR0095, "GCTIMG32_OCEAN", { | oView | JURA144Bt1( oView ) } ) //Botão - "Corrigir TS"
		oView:AddUserButton( STR0137, "EDITABLE"      , { | oView | JA202BTOBS( oView, "NUH", STR0139 ) } ) //Botão - "OBS Cliente" / "Observação de Faturamento do Cliente"
		oView:AddUserButton( STR0096, "EDITABLE"      , { | oView | JA202BTOBS( oView, "NVE", STR0140 ) } ) //Botão - "OBS Caso" / "Observação do Caso"
		oView:AddUserButton( STR0034, "RELOAD_OCEAN"  , { | oView, oButton | JA202MNUORI( oView, oButton ) } ) //"Val. Original"
		oView:AddUserButton( STR0105, "CFGPANEL"      , { | oView | JA202OPERA( oView ) } )  // "Operações"
		oView:AddUserButton( STR0015, "EDITABLE"      , { | oView, oBotao | J202Marcar(oView, oBotao) } ) // "Marcar"
		oView:AddUserButton( STR0020, "CFGPANEL"      , { | oView, oBotao | JA202Novos(oView, oBotao) } ) // "Novos"
		If !(cParam == '1' .And. IsPlugin())
			oView:AddUserButton( STR0145, "CLIPS", { | oView, oBotao | J202Anexo(oBotao) } ) // "Anexos"
		EndIf
    EndIf
	oView:AddUserButton( STR0200, "TK_VERTIT_OCEAN", { | oView | JA202VIEW('BTPREV', oView) } ) // "Resumo" //exibe os totais da pré"

	If (NX0->NX0_SITUAC == SIT_EMIFATURA .And. lTemFat )  //pre-faturas multipayer em situação 4 é permitido alterar somente os pagadores.
		oView:SetNoUpdateLine( 'JURA202_NX4' )
		oView:SetNoUpdateLine( 'JURA202_NX8' )
		oView:SetNoUpdateLine( 'JURA202_NT1' )
		oView:SetNoUpdateLine( 'JURA202_NX1' )
		If lMultRevis
			oView:SetNoUpdateLine( 'JURA202_OHN' )
		EndIf
		oView:SetNoUpdateLine( 'JURA202_NX2' )
		oView:SetNoUpdateLine( 'JURA202_NUE' )
		oView:SetNoUpdateLine( 'JURA202_NVY' )
		oView:SetNoUpdateLine( 'JURA202_NV4' )
	EndIf

EndIf

oView:SetDescription( STR0026 ) //"Pré-Fatura"

oView:SetProgressBar(.T.)

oStructNVV:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

// Habilita a pesquisa no grid.
oView:SetViewProperty( 'JURA202_NX8', "GRIDSEEK" )
oView:SetViewProperty( 'JURA202_NX1', "GRIDSEEK" )
oView:SetViewProperty( 'JURA202_NX2', "GRIDSEEK" )
oView:SetViewProperty( 'JURA202_NUE', "GRIDSEEK" )
oView:SetViewProperty( 'JURA202_NVY', "GRIDSEEK" )
oView:SetViewProperty( 'JURA202_NV4', "GRIDSEEK" )

oView:AddIncrementField( 'NVNDETAIL', 'NVN_COD' )

oView:SetViewAction( 'BUTTONCANCEL', { || JA207SetNil() } )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} J202LdNX1(cCampo)
Função para carregar os campos virtuais da tabela NX1
Melhoria de performance da tela de operação de pré-fatura

@Param cCampo Camopo da NX1

@author Luciano Pereira dos Santos
@since 08/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J202LdNX1(cCampo)
Local aArea    := GetArea()
Local xRet     := ""
Local lIsRest  := Iif(FindFunction("JurIsRest"), JurIsRest(), .F.)

Do Case
Case cCampo == "NX1_CONTTS" .And. !lIsRest
	xRet := J202Count("NUE", NX1->NX1_CCLIEN, NX1->NX1_CLOJA, NX1->NX1_CCASO, NX1->NX1_CPREFT)

Case cCampo == "NX1_CONTDP" .And. !lIsRest
	xRet := J202Count("NVY", NX1->NX1_CCLIEN, NX1->NX1_CLOJA, NX1->NX1_CCASO, NX1->NX1_CPREFT)

Case cCampo == "NX1_CONTLT" .And. !lIsRest
	xRet := J202Count("NV4", NX1->NX1_CCLIEN, NX1->NX1_CLOJA, NX1->NX1_CCASO, NX1->NX1_CPREFT)

Case cCampo == "NX1_CIDIO"
	xRet := Posicione('NVE', 1, xFilial('NVE') + NX1->NX1_CCLIEN + NX1->NX1_CLOJA + NX1->NX1_CCASO, 'NVE_CIDIO')

EndCase

RestArea(aArea)

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202LdNX1(cCampo)
Função para carregar os campos virtuais da tabela NX1
Melhoria de performance da tela de operação de pré-fatura

@Param cCampo Campo da NX1

@author Luciano Pereira dos Santos
@since 16/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202Count(cTab, cClient, cLoja, cCaso, cPreft)
Local cQuery  := ""
Local cResQry := GetNextAlias()
Local nRet    := 0

cQuery := "SELECT COUNT(" + cTab + ".R_E_C_N_O_) NCOUNT FROM " + RetSqlName(cTab) + " " + cTab + " "
cQuery += " WHERE " + cTab + "." + cTab + "_FILIAL = '" + xFilial(cTab) + "' "
cQuery +=   " AND " + cTab + "." + cTab + "_CPREFT = '" + cPreft + "'"
cQuery +=   " AND " + cTab + "." + cTab + "_CCLIEN = '" + cClient + "'"
cQuery +=   " AND " + cTab + "." + cTab + "_CLOJA = '" + cLoja + "'"
cQuery +=   " AND " + cTab + "." + cTab + "_CCASO = '" + cCaso + "'"
cQuery +=   " AND " + cTab + ".D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQry, .T., .T.)

If !(cResQry)->(EOF())
	nRet := (cResQry)->NCOUNT
EndIf

(cResQry)->( dbCloseArea() )

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Pré-Fatura

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := Nil
Local lShowVirt  := !JurIsRest() // Inclui os campos virtuais nos structs somente se não for REST (Necessário já que os inicializadores dos campos virtuais são executados sempre, mesmo sem o uso do header FIELDVIRTUAL = TRUE)
Local oStructNX0 := FWFormStruct( 1, 'NX0',,, lShowVirt)  // Pre-fatura
Local oStructNX8 := FWFormStruct( 1, 'NX8',,, lShowVirt)  // Contrato
Local oStructNT1 := FWFormStruct( 1, 'NT1',,, lShowVirt)  // Fixo

Local bNCalcNX1  := {|xAux| !AllTrim(xAux) $ 'NX1_CONTTS|NX1_CONTDP|NX1_CONTLT'}
Local oStructNX1 := FWFormStruct( 1, 'NX1', bNCalcNX1,, lShowVirt)  // Caso
Local bCalcNX1   := {|xAux| AllTrim(xAux) $ 'NX1_FILIAL|NX1_CPREFT|NX1_CCONTR|NX1_CCLIEN|NX1_CLOJA|NX1_CCASO|NX1_CONTTS|NX1_CONTDP|NX1_CONTLT'}
Local oCalcNX1   := FWFormStruct( 1, 'NX1', bCalcNX1,, lShowVirt) //Calc do Caso
Local oStructNX2 := FWFormStruct( 1, 'NX2',,, lShowVirt)  // Participante
Local oStructNUE := FWFormStruct( 1, 'NUE',,, lShowVirt)  // Time Sheet
Local oStructNV4 := FWFormStruct( 1, 'NV4',,, lShowVirt)  // Tabelado
Local oStructNVY := FWFormStruct( 1, 'NVY',,, lShowVirt)  // Despesas
Local oStructNVV := FWFormStruct( 1, 'NVV',,, lShowVirt)  // Fat. Adicional
Local oStructNX4 := FWFormStruct( 1, 'NX4',,, lShowVirt)  // Historico de cobrança
Local oStructNXG := FWFormStruct( 1, 'NXG',,, lShowVirt)  // Pagadores
Local oStructNVN := FWFormStruct( 1, 'NVN',,, lShowVirt)  // Encaminhamento de Fatura
Local oStructNXR := FWFormStruct( 1, 'NXR',,, lShowVirt)  // Cotações
Local oStructOHN := Nil                       //Sócios/Revisores

Local aCampos    := {}
Local aStructs   := {}
Local bBlock202W := FwBuildFeature( STRUCT_FEATURE_WHEN, 'JURA202W( "FIXO" )' )
Local bBlockFalse:= FwBuildFeature( STRUCT_FEATURE_WHEN, ".F." )
Local lJA202FLDS := ExistBlock('JA202FLDS')
Local nZ         := 0
Local nX         := 0
Local nY         := 0
Local nPos       := 0
Local lTemFat    := JA201TemFt(NX0->NX0_COD)
Local cNumCaso   := SuperGetMV( 'MV_JCASO1',, 2 )  //Seqüencia da numeracao do caso: por cliente (1) ou independente do cliente (2)
Local nIndexNX1  := 1
Local aNX1Calc   := {}
Local nTpApont   := SuperGetMV( 'MV_JURTS2',, 1 )
Local lIsRest    := Iif(FindFunction("JurIsRest"), JurIsRest(), .F.)
Local lIntFinanc := SuperGetMV("MV_JURXFIN",, .F.) //Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico
Local lMultRevis := ( SuperGetMV("MV_JMULTRV",, .F.) .And. (SuperGetMV("MV_JREVILD",, '2') == '1') .And. FWAliasInDic("OHN") ) // Indica se é utilizado o conceito de múltiplos revisores e a revisão de pré-fatura do LD.
Local cJurUser   := JurUsuario(__CUSERID)

Local oCommit    := JA202COMMIT():New()

Local lProtNX1   := NX1->(ColumnPos("NX1_CONTTS")) > 0 .Or. ;
                    NX1->(ColumnPos("NX1_CONTDP")) > 0 .Or. ;
                    NX1->(ColumnPos("NX1_CONTLT")) > 0 // Proteção - DJURFAT1-3129
Local lTempoProd := NUE->(ColumnPos("NUE_UTP")) > 0    // Novos campos para indicar o Tempo Produtivo
Local aRelOHN    := {}
Local lObsRevDes := NVY->(ColumnPos("NVY_CMOTWR")) > 0

lIntegracao  := (SuperGetMV("MV_JFSINC", .F., '2') == '1') //Adicionado para não afetar a performance da tela quando o parâmetro de fila de integração está desativado
lRevisLD     := (SuperGetMV("MV_JREVILD", .F., '2') == '1' ) //Controla a integracao da revisão de pré-fatura com o Legal Desk
lIntRevis    := lIntegracao .And. lRevisLD
SetJura202(.T.)

oStructNT1:RemoveField( 'NT1_CCLIEN' ) //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
oStructNT1:RemoveField( 'NT1_CLOJA'  ) //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
oStructNT1:RemoveField( 'NT1_CTPHON' ) //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
oStructNT1:RemoveField( 'NT1_DCLIEN' ) //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
oStructNT1:RemoveField( 'NT1_DCONTR' ) //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )
oStructNT1:RemoveField( 'NT1_DTPHON' ) //campos virtuais utilizados na tela de emissão de fatura ( JURA203 )

oStructNT1:SetProperty( '*', MODEL_FIELD_NOUPD, .T. )
If lIntRevis .And. lIsRest .And. NT1->( FieldPos( "NT1_ACAOLD" )) > 0
	oStructNT1:SetProperty( 'NT1_ACAOLD', MODEL_FIELD_NOUPD, .F. )
	oStructNT1:SetProperty( 'NT1_INSREV', MODEL_FIELD_NOUPD, .F. )
	oStructNT1:SetProperty( 'NT1_REVISA', MODEL_FIELD_NOUPD, .F. )
EndIf
oStructNT1:SetProperty( 'NT1_SEQUEN', MODEL_FIELD_INIT, Nil ) // CH8022 - Desabilitado inicializador padrão para não desperdiçar numeração de Parcela
oStructNVV:SetProperty( 'NVV_COD', MODEL_FIELD_INIT, Nil ) // CH8022 - Desabilitado inicializador padrão para não desperdiçar numeração de FA.
oStructNUE:SetProperty( 'NUE_COD', MODEL_FIELD_INIT, Nil ) // CH8022 - Desabilitado inicializador padrão para não desperdiçar numeração de TS.
oStructNVY:SetProperty( 'NVY_COD', MODEL_FIELD_INIT, Nil ) // CH8022 - Desabilitado inicializador padrão para não desperdiçar numeração de DP.
oStructNV4:SetProperty( 'NV4_COD', MODEL_FIELD_INIT, Nil ) // CH8022 - Desabilitado inicializador padrão para não desperdiçar numeração de TB.
If(NX4->(FieldPos('NX4_AUTO')) > 0)
	oStructNX4:SetProperty( 'NX4_AUTO', MODEL_FIELD_INIT, {|| "2"} )
EndIf
oStructNXR:SetProperty( 'NXR_CMOEDA', MODEL_FIELD_NOUPD, .T. )

JFldNoUpd("*", oStructNUE, .T.) // Apenas deixa como MODEL_FIELD_NOUPD .T. os camps do sistema (SX3_PROPRI = "" ou "S")
JFldNoUpd("*", oStructNV4, .T.) // Apenas deixa como MODEL_FIELD_NOUPD .T. os camps do sistema (SX3_PROPRI = "" ou "S")
JFldNoUpd("*", oStructNVY, .T.) // Apenas deixa como MODEL_FIELD_NOUPD .T. os camps do sistema (SX3_PROPRI = "" ou "S")
If NX4->(FieldPos('NX4_AUTO')) > 0
	JFldNoUpd("*", oStructNX4, FwBuildFeature( STRUCT_FEATURE_WHEN, '!FwFldGet("NX4_AUTO")=="1"'), MODEL_FIELD_WHEN)
EndIf

If NUE->(ColumnPos('NUE_COTAC')) > 0 //Proteção
	oStructNUE:SetProperty( 'NUE_COTAC', MODEL_FIELD_NOUPD, .T. )
	oStructNV4:SetProperty( 'NV4_COTAC', MODEL_FIELD_NOUPD, .T. )
	oStructNVY:SetProperty( 'NVY_COTAC', MODEL_FIELD_NOUPD, .T. )
	oStructNT1:SetProperty( 'NT1_COTAC', MODEL_FIELD_NOUPD, .T. )
EndIf

oStructNUE:SetProperty( 'NUE_ANOMES', MODEL_FIELD_NOUPD, .F. )

oStructNVV:SetProperty( '*', MODEL_FIELD_NOUPD, .T. )
oStructNX1:SetProperty( '*', MODEL_FIELD_NOUPD, .T. )
oStructNX2:SetProperty( '*', MODEL_FIELD_NOUPD, .T. )
oStructNX8:SetProperty( '*', MODEL_FIELD_NOUPD, .T. )
oStructNXG:SetProperty( '*', MODEL_FIELD_NOUPD, .F. )
oStructNVN:SetProperty( '*', MODEL_FIELD_NOUPD, .F. )
oStructNX1:SetProperty( '*', MODEL_FIELD_OBRIGAT, .F. )
oStructNX8:SetProperty( '*', MODEL_FIELD_OBRIGAT, .F. )

If lMultRevis
	oStructOHN := FWFormStruct( 1, "OHN",,, lShowVirt)
	oStructOHN:SetProperty( '*', MODEL_FIELD_NOUPD, .F. )
EndIf

If !lShowVirt
	// Adiciona os campos virtuais de "TKRET" e sigla novamente nas estruturas, pois foram retirados via lShowVirt,
	// mas precisam existir para execução das operações nos lançamentos via REST
	J202AddCpVir(@oStructNT1, @oStructNUE, @oStructNV4, @oStructNVV, @oStructNVY, @oStructNX0, @oStructNX1, @oStructNX2, @oStructNX4, @oStructNX8, lMultRevis, @oStructOHN)
EndIf

// Libera os campos para a alteracao
oStructNX0:SetProperty( 'NX0_ACRESH', MODEL_FIELD_WHEN, FWBuildFeature( STRUCT_FEATURE_WHEN, "JURA202W('NX0_ACRESH')" ) )
oStructNX0:SetProperty( 'NX0_DESCH' , MODEL_FIELD_WHEN, FWBuildFeature( STRUCT_FEATURE_WHEN, "JURA202W('NX0_DESCH' )" ) )
oStructNX0:SetProperty( 'NX0_PACREH', MODEL_FIELD_WHEN, FWBuildFeature( STRUCT_FEATURE_WHEN, "JURA202W('NX0_PACREH')" ) )
oStructNX0:SetProperty( 'NX0_PDESCH', MODEL_FIELD_WHEN, FWBuildFeature( STRUCT_FEATURE_WHEN, "JURA202W('NX0_PDESCH')" ) )
oStructNX0:SetProperty( 'NX0_TPACRE', MODEL_FIELD_WHEN, FWBuildFeature( STRUCT_FEATURE_WHEN, "JURA202W('NX0_TPACRE')" ) )
oStructNX0:SetProperty( 'NX0_TPDESC', MODEL_FIELD_WHEN, FWBuildFeature( STRUCT_FEATURE_WHEN, "JURA202W('NX0_TPDESC')" ) )
oStructNX0:SetProperty( 'NX0_VTS'   , MODEL_FIELD_WHEN, FWBuildFeature( STRUCT_FEATURE_WHEN, "JURA202W('NX0_VTS'   )" ) )

oStructNX1:SetProperty( 'NX1_PCDESC', MODEL_FIELD_WHEN, FWBuildFeature( STRUCT_FEATURE_WHEN, "JURA202W('NX1_PCDESC')" ) )
oStructNX1:SetProperty( 'NX1_PDESCH', MODEL_FIELD_WHEN, FWBuildFeature( STRUCT_FEATURE_WHEN, "JURA202W('NX1_PDESCH')" ) )
oStructNX1:SetProperty( 'NX1_VLDESC', MODEL_FIELD_WHEN, FWBuildFeature( STRUCT_FEATURE_WHEN, "JURA202W('NX1_VLDESC')" ) )

If lIsRest .Or. !(NX0->NX0_SITUAC == SIT_EMIFATURA .And. lTemFat) // Pre-faturas multipayer em situação 4
	// Fixo
	oStructNT1:SetProperty( 'NT1_DESCRI', MODEL_FIELD_NOUPD, .F. )
	oStructNT1:SetProperty( 'NT1_CTPFTU', MODEL_FIELD_NOUPD, .F. )
	IIf(lShowVirt, oStructNT1:SetProperty( 'NT1_DTPFTU', MODEL_FIELD_NOUPD, .F. ), Nil)
	oStructNT1:SetProperty( 'NT1_SITUAC', MODEL_FIELD_NOUPD, .F. )
	oStructNT1:SetProperty( 'NT1_TKRET' , MODEL_FIELD_NOUPD, .F. )
	// Time Sheet
	If NUE->(ColumnPos("NUE_CESCR")) > 0
		oStructNUE:SetProperty( 'NUE_CESCR', MODEL_FIELD_NOUPD, .F. )
		IIf(lShowVirt, oStructNUE:SetProperty( 'NUE_DESCR', MODEL_FIELD_NOUPD, .F. ), Nil)
	EndIf
	If NUE->(ColumnPos("NUE_CC")) > 0
		oStructNUE:SetProperty( 'NUE_CC'    , MODEL_FIELD_NOUPD, .F. )
		IIf(lShowVirt, oStructNUE:SetProperty( 'NUE_DESCCC', MODEL_FIELD_NOUPD, .F. ), Nil)
	EndIf
	oStructNUE:SetProperty( 'NUE_COBRAR', MODEL_FIELD_NOUPD, .F. )
	oStructNUE:SetProperty( 'NUE_CATIVI', MODEL_FIELD_NOUPD, .F. )
	If lIntRevis 
		If NUE->( FieldPos( "NUE_ACAOLD" )) > 0
			oStructNUE:SetProperty( 'NUE_ACAOLD', MODEL_FIELD_NOUPD, .F. )
			oStructNUE:SetProperty( 'NUE_CCLILD', MODEL_FIELD_NOUPD, .F. )
			oStructNUE:SetProperty( 'NUE_CLJLD', MODEL_FIELD_NOUPD, .F. )
			oStructNUE:SetProperty( 'NUE_CCSLD', MODEL_FIELD_NOUPD, .F. )
			oStructNUE:SetProperty( 'NUE_PARTLD', MODEL_FIELD_NOUPD, .F. )
			oStructNUE:SetProperty( 'NUE_CMOTWO', MODEL_FIELD_NOUPD, .F. )
			oStructNUE:SetProperty( 'NUE_OBSWO', MODEL_FIELD_NOUPD, .F. )
			oStructNUE:SetProperty( 'NUE_CDWOLD', MODEL_FIELD_NOUPD, .F. )
		EndIf
		If NUE->(FieldPos( "NUE_FLUREV" )) > 0
			oStructNUE:SetProperty('NUE_FLUREV', MODEL_FIELD_NOUPD, .F.)
			oStructNUE:SetProperty('NUE_CREPRO', MODEL_FIELD_NOUPD, .F.)
			oStructNUE:SetProperty('NUE_DTREPR', MODEL_FIELD_NOUPD, .F.)
		EndIf
	EndIf
	oStructNUE:SetProperty( 'NUE_CCASO' , MODEL_FIELD_NOUPD, .F. )
	oStructNUE:SetProperty( 'NUE_CCLIEN', MODEL_FIELD_NOUPD, .F. )
	oStructNUE:SetProperty( 'NUE_CLOJA' , MODEL_FIELD_NOUPD, .F. )
	oStructNUE:SetProperty( 'NUE_CMOEDA', MODEL_FIELD_NOUPD, .F. )
	oStructNUE:SetProperty( 'NUE_CPART2', MODEL_FIELD_NOUPD, .F. )
	oStructNUE:SetProperty( 'NUE_CRETIF', MODEL_FIELD_NOUPD, .F. )
	oStructNUE:SetProperty( 'NUE_DATATS', MODEL_FIELD_NOUPD, .F. )
	IIf(lShowVirt, oStructNUE:SetProperty( 'NUE_DATIVI', MODEL_FIELD_NOUPD, .F. ), Nil)
	oStructNUE:SetProperty( 'NUE_DESC'  , MODEL_FIELD_NOUPD, .F. )
	IIf(lShowVirt, oStructNUE:SetProperty( 'NUE_DPART2', MODEL_FIELD_NOUPD, .F. ), Nil)
	IIf(lShowVirt, oStructNUE:SetProperty( 'NUE_DRETIF', MODEL_FIELD_NOUPD, .F. ), Nil)
	oStructNUE:SetProperty( 'NUE_REVISA', MODEL_FIELD_NOUPD, .F. )
	oStructNUE:SetProperty( 'NUE_SIGLA2', MODEL_FIELD_NOUPD, .F. )
	oStructNUE:SetProperty( 'NUE_TKRET' , MODEL_FIELD_NOUPD, .F. )
	oStructNUE:SetProperty( 'NUE_VALOR1', MODEL_FIELD_NOUPD, .F. )
	oStructNUE:SetProperty( 'NUE_VALORH', MODEL_FIELD_NOUPD, .F. )
	If lIsRest
		oStructNUE:SetProperty( 'NUE_CFASE' , MODEL_FIELD_NOUPD, .F. )
		oStructNUE:SetProperty( 'NUE_CTAREB', MODEL_FIELD_NOUPD, .F. )
		oStructNUE:SetProperty( 'NUE_CTAREF', MODEL_FIELD_NOUPD, .F. )
		oStructNUE:SetProperty( 'NUE_UTR'   , MODEL_FIELD_NOUPD, .F. )
		oStructNUE:SetProperty( 'NUE_TEMPOR', MODEL_FIELD_NOUPD, .F. )
		oStructNUE:SetProperty( 'NUE_HORAR' , MODEL_FIELD_NOUPD, .F. )

		oStructNUE:SetProperty( 'NUE_UTR'   , MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, ".T."))
		oStructNUE:SetProperty( 'NUE_TEMPOR', MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, ".T."))
		oStructNUE:SetProperty( 'NUE_HORAR' , MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, ".T."))
	Else
		If nTpApont == 1
			oStructNUE:SetProperty( 'NUE_UTR'    , MODEL_FIELD_NOUPD, .F. )
			If lTempoProd
				oStructNUE:SetProperty( 'NUE_UTP', MODEL_FIELD_NOUPD, .F. )
			EndIf
		ElseIf nTpApont == 2
			oStructNUE:SetProperty( 'NUE_TEMPOR' , MODEL_FIELD_NOUPD, .F. )
			If lTempoProd
				oStructNUE:SetProperty( 'NUE_TEMPOP', MODEL_FIELD_NOUPD, .F. )
			EndIf
		ElseIf nTpApont == 3
			oStructNUE:SetProperty( 'NUE_HORAR'    , MODEL_FIELD_NOUPD, .F. )
			If lTempoProd
				oStructNUE:SetProperty( 'NUE_HORAP', MODEL_FIELD_NOUPD, .F. )
			EndIf
		EndIf
	EndIf
	// Lançamento Tabelado
	oStructNV4:SetProperty( 'NV4_COBRAR', MODEL_FIELD_NOUPD, .F. )
	oStructNV4:SetProperty( 'NV4_DESCRI', MODEL_FIELD_NOUPD, .F. )
	oStructNV4:SetProperty( 'NV4_TKRET' , MODEL_FIELD_NOUPD, .F. )
	oStructNV4:SetProperty( 'NV4_VLHFAT', MODEL_FIELD_NOUPD, .F. )
	If lIntRevis .And. NV4->( FieldPos( "NV4_ACAOLD" )) > 0
		oStructNV4:SetProperty( 'NV4_ACAOLD', MODEL_FIELD_NOUPD, .F. )
		oStructNV4:SetProperty( 'NV4_CCLILD', MODEL_FIELD_NOUPD, .F. )
		oStructNV4:SetProperty( 'NV4_CLJLD', MODEL_FIELD_NOUPD, .F. )
		oStructNV4:SetProperty( 'NV4_CCSLD', MODEL_FIELD_NOUPD, .F. )
		oStructNV4:SetProperty( 'NV4_PARTLD', MODEL_FIELD_NOUPD, .F. )
		oStructNV4:SetProperty( 'NV4_CMOTWO', MODEL_FIELD_NOUPD, .F. )
		oStructNV4:SetProperty( 'NV4_OBSWO', MODEL_FIELD_NOUPD, .F. )
		oStructNV4:SetProperty( 'NV4_CDWOLD', MODEL_FIELD_NOUPD, .F. )
	EndIf
	// Despesa
	oStructNVV:SetProperty( 'NVV_TKRET' , MODEL_FIELD_NOUPD, .F. )
	oStructNVY:SetProperty( 'NVY_COBRAR', MODEL_FIELD_NOUPD, .F. )
	oStructNVY:SetProperty( 'NVY_SIGLA' , MODEL_FIELD_NOUPD, .T. )
	oStructNVY:SetProperty( 'NVY_CPART' , MODEL_FIELD_NOUPD, .T. )
	oStructNVY:SetProperty( 'NVY_CTPDSP', MODEL_FIELD_NOUPD, .T. )
	oStructNVY:SetProperty( 'NVY_DESCRI', MODEL_FIELD_NOUPD, .F. )
	IIf(lShowVirt, oStructNVY:SetProperty( 'NVY_DPART' , MODEL_FIELD_NOUPD, .F. ), Nil)
	IIf(lShowVirt, oStructNVY:SetProperty( 'NVY_DTPDSP', MODEL_FIELD_NOUPD, .F. ), Nil)
	oStructNVY:SetProperty( 'NVY_OBSCOB', MODEL_FIELD_NOUPD, .F. )
	oStructNVY:SetProperty( 'NVY_USRNCB', MODEL_FIELD_NOUPD, .F. )
	oStructNVY:SetProperty( 'NVY_TKRET' , MODEL_FIELD_NOUPD, .F. )
	IIf(lShowVirt, oStructNVY:SetProperty( 'NVY_TPCOB' , MODEL_FIELD_NOUPD, .F. ), Nil)
	oStructNVY:SetProperty( 'NVY_VALOR' , MODEL_FIELD_NOUPD, .T. )
	oStructNVY:SetProperty( 'NVY_ANOMES', MODEL_FIELD_NOUPD, .F. )
	If !lIntFinanc
		oStructNVY:SetProperty( 'NVY_DATA', MODEL_FIELD_NOUPD, .F. )
	EndIf

	If lIntRevis .And. NVY->( FieldPos( "NVY_ACAOLD" )) > 0
		oStructNVY:SetProperty( 'NVY_ACAOLD', MODEL_FIELD_NOUPD, .F. )
		oStructNVY:SetProperty( 'NVY_CCLILD', MODEL_FIELD_NOUPD, .F. )
		oStructNVY:SetProperty( 'NVY_CLJLD', MODEL_FIELD_NOUPD, .F. )
		oStructNVY:SetProperty( 'NVY_CCSLD', MODEL_FIELD_NOUPD, .F. )
		oStructNVY:SetProperty( 'NVY_PARTLD', MODEL_FIELD_NOUPD, .F. )
		oStructNVY:SetProperty( 'NVY_CMOTWO', MODEL_FIELD_NOUPD, .F. )
		oStructNVY:SetProperty( 'NVY_OBSWO', MODEL_FIELD_NOUPD, .F. )
		oStructNVY:SetProperty( 'NVY_CDWOLD', MODEL_FIELD_NOUPD, .F. )
		If lObsRevDes
			oStructNVY:SetProperty('NVY_CMOTWR', MODEL_FIELD_NOUPD, .F. )
		EndIf
	EndIf
	// Cabeçalho
	oStructNX0:SetProperty( 'NX0_ACRESH', MODEL_FIELD_NOUPD, .F. )
	oStructNX0:SetProperty( 'NX0_ALTPER', MODEL_FIELD_NOUPD, .F. )
	oStructNX0:SetProperty( 'NX0_CPART' , MODEL_FIELD_NOUPD, .F. )
	IIf(lShowVirt, oStructNX0:SetProperty( 'NX0_DCONTA', MODEL_FIELD_NOUPD, .F. ), Nil)
	oStructNX0:SetProperty( 'NX0_DESCH' , MODEL_FIELD_NOUPD, .F. )
	IIf(lShowVirt, oStructNX0:SetProperty( 'NX0_DPART' , MODEL_FIELD_NOUPD, .F. ), Nil)
	oStructNX0:SetProperty( 'NX0_OBSFAT', MODEL_FIELD_NOUPD, .F. )
	oStructNX0:SetProperty( 'NX0_OBSRED', MODEL_FIELD_NOUPD, .F. )
	oStructNX0:SetProperty( 'NX0_OBSREV', MODEL_FIELD_NOUPD, .F. )
	oStructNX0:SetProperty( 'NX0_PACREH', MODEL_FIELD_NOUPD, .F. )
	oStructNX0:SetProperty( 'NX0_PDESCH', MODEL_FIELD_NOUPD, .F. )
	oStructNX0:SetProperty( 'NX0_TPDESC', MODEL_FIELD_NOUPD, .F. )
	oStructNX0:SetProperty( 'NX0_VLFATD', MODEL_FIELD_NOUPD, .F. )
	oStructNX0:SetProperty( 'NX0_VTS'   , MODEL_FIELD_NOUPD, .F. )
	If lIsRest
		oStructNX0:SetProperty( 'NX0_SERVIC', MODEL_FIELD_NOUPD, .F. )
	EndIf
	// Caso
	oStructNX1:SetProperty( 'NX1_DSPREV', MODEL_FIELD_NOUPD, .F. )
	oStructNX1:SetProperty( 'NX1_PCDESC', MODEL_FIELD_NOUPD, .F. )
	oStructNX1:SetProperty( 'NX1_PDESCH', MODEL_FIELD_NOUPD, .F. )
	oStructNX1:SetProperty( 'NX1_REDAC' , MODEL_FIELD_NOUPD, .F. )
	oStructNX1:SetProperty( 'NX1_TABREV', MODEL_FIELD_NOUPD, .F. )
	oStructNX1:SetProperty( 'NX1_TKRET' , MODEL_FIELD_NOUPD, .F. )
	oStructNX1:SetProperty( 'NX1_TSREV' , MODEL_FIELD_NOUPD, .F. )
	oStructNX1:SetProperty( 'NX1_VDESCO', MODEL_FIELD_WHEN , bBlockFalse )
	oStructNX1:SetProperty( 'NX1_VDESP' , MODEL_FIELD_NOUPD, .F. )
	oStructNX1:SetProperty( 'NX1_VLDESC', MODEL_FIELD_NOUPD, .F. )
	oStructNX1:SetProperty( 'NX1_VTAB'  , MODEL_FIELD_WHEN , bBlockFalse )
	oStructNX1:SetProperty( 'NX1_VTS'   , MODEL_FIELD_NOUPD, .F. )
	oStructNX1:SetProperty( 'NX1_VTSTAB', MODEL_FIELD_WHEN , bBlockFalse )
	oStructNX1:SetProperty( 'NX1_SIGLA' , MODEL_FIELD_NOUPD, .F. )
	oStructNX1:SetProperty( 'NX1_CPART' , MODEL_FIELD_NOUPD, .F. )
	IIf(lShowVirt, oStructNX1:SetProperty( 'NX1_DPART' , MODEL_FIELD_NOUPD, .F. ), Nil)
	If lIntRevis .And. ( NX1->( FieldPos( "NX1_SITREV" )) > 0 .And. NX1->( FieldPos( "NX1_RETREV" )) > 0 )
		oStructNX1:SetProperty( 'NX1_SITREV', MODEL_FIELD_NOUPD, .F. )
		oStructNX1:SetProperty( 'NX1_RETREV', MODEL_FIELD_NOUPD, .F. )
		IIf(lShowVirt, oStructNX1:SetProperty( 'NX1_DRETRV', MODEL_FIELD_NOUPD, .F. ), Nil)
		oStructNX1:SetProperty( 'NX1_INSREV', MODEL_FIELD_NOUPD, .F. )
		oStructNX1:SetProperty( 'NX1_INSFAT', MODEL_FIELD_NOUPD, .F. )
		oStructNX1:SetProperty( 'NX1_DESCEX', MODEL_FIELD_NOUPD, .F. )
	EndIf
	// Participante
	oStructNX2:SetProperty( 'NX2_HORAR' , MODEL_FIELD_NOUPD, .F. )
	oStructNX2:SetProperty( 'NX2_TEMPOR', MODEL_FIELD_NOUPD, .F. )
	oStructNX2:SetProperty( 'NX2_TKRET' , MODEL_FIELD_NOUPD, .F. )
	oStructNX2:SetProperty( 'NX2_UTR'   , MODEL_FIELD_NOUPD, .F. )
	oStructNX2:SetProperty( 'NX2_VALOR1', MODEL_FIELD_NOUPD, .F. )
	oStructNX2:SetProperty( 'NX2_VALORH', MODEL_FIELD_NOUPD, .F. )
	oStructNX2:SetProperty( 'NX2_VLHTBH', MODEL_FIELD_NOUPD, .F. )
	// Histórico de cobrança
	oStructNX4:SetProperty( 'NX4_CPART' , MODEL_FIELD_NOUPD, .F. )
	IIf(lShowVirt, oStructNX4:SetProperty( 'NX4_DPART' , MODEL_FIELD_NOUPD, .F. ), Nil)
	oStructNX4:SetProperty( 'NX4_DTINC' , MODEL_FIELD_NOUPD, .F. )
	oStructNX4:SetProperty( 'NX4_DTRET' , MODEL_FIELD_NOUPD, .F. )
	oStructNX4:SetProperty( 'NX4_DTSAID', MODEL_FIELD_NOUPD, .F. )
	oStructNX4:SetProperty( 'NX4_HIST'  , MODEL_FIELD_NOUPD, .F. )
	oStructNX4:SetProperty( 'NX4_HRINC' , MODEL_FIELD_NOUPD, .F. )
	oStructNX4:SetProperty( 'NX4_HRRET' , MODEL_FIELD_NOUPD, .F. )
	oStructNX4:SetProperty( 'NX4_HRSAID', MODEL_FIELD_NOUPD, .F. )
	// Contrato
	oStructNX8:SetProperty( 'NX8_TKRET' , MODEL_FIELD_NOUPD, .F. )
	oStructNX8:SetProperty( 'NX8_VDESCO', MODEL_FIELD_WHEN , bBlockFalse )
	oStructNX8:SetProperty( 'NX8_VDESP' , MODEL_FIELD_NOUPD, .F. )
	oStructNX8:SetProperty( 'NX8_VLDESC', MODEL_FIELD_WHEN , bBlockFalse )
	oStructNX8:SetProperty( 'NX8_VTAB'  , MODEL_FIELD_WHEN , bBlockFalse )
	oStructNX8:SetProperty( 'NX8_VTS'   , MODEL_FIELD_NOUPD, .F. )
	oStructNX8:SetProperty( 'NX8_VTSTAB', MODEL_FIELD_WHEN , bBlockFalse )
EndIf

If !lIsRest  .And. NX0->NX0_FIXO == '1'
	oStructNX1:SetProperty( 'NX1_PCDESC', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, 'JURA202W("NX1_PCDESC") .And. JURA202W("FIXO")'))
	oStructNX0:SetProperty( 'NX0_ALTPER', MODEL_FIELD_WHEN, bBlock202W )
	oStructNX0:SetProperty( 'NX0_VTS'   , MODEL_FIELD_WHEN, bBlock202W )
	oStructNX1:SetProperty( 'NX1_PDESCH', MODEL_FIELD_WHEN, bBlock202W )
	oStructNX1:SetProperty( 'NX1_VTS'   , MODEL_FIELD_WHEN, bBlock202W )
	oStructNX2:SetProperty( 'NX2_HORAR' , MODEL_FIELD_WHEN, bBlock202W )
	oStructNX2:SetProperty( 'NX2_TEMPOR', MODEL_FIELD_WHEN, bBlock202W )
	oStructNX2:SetProperty( 'NX2_UTR'   , MODEL_FIELD_WHEN, bBlock202W )
	oStructNX2:SetProperty( 'NX2_VALOR1', MODEL_FIELD_WHEN, bBlock202W )
	oStructNX2:SetProperty( 'NX2_VALORH', MODEL_FIELD_WHEN, bBlock202W )
	oStructNX8:SetProperty( 'NX8_VTS'   , MODEL_FIELD_WHEN, bBlock202W )
EndIf

If !lIsRest .And. NX0->NX0_FATADC == '1'
	oStructNX0:SetProperty( 'NX0_ALTPER', MODEL_FIELD_WHEN, bBlockFalse )
	oStructNX0:SetProperty( 'NX0_PDESCH', MODEL_FIELD_WHEN, bBlockFalse )
	oStructNX0:SetProperty( 'NX0_TPDESC', MODEL_FIELD_WHEN, bBlockFalse )
	oStructNX0:SetProperty( 'NX0_VTS'   , MODEL_FIELD_WHEN, bBlockFalse )
	oStructNX1:SetProperty( 'NX1_PDESCH', MODEL_FIELD_WHEN, bBlockFalse )
	oStructNX1:SetProperty( 'NX1_VLDESC', MODEL_FIELD_WHEN, bBlockFalse )
	oStructNX1:SetProperty( 'NX1_VTS'   , MODEL_FIELD_WHEN, bBlockFalse )
	oStructNX8:SetProperty( 'NX8_VHON'  , MODEL_FIELD_WHEN, bBlockFalse )
	oStructNX8:SetProperty( 'NX8_VLDESC', MODEL_FIELD_WHEN, bBlockFalse )
	oStructNX8:SetProperty( 'NX8_VTS'   , MODEL_FIELD_WHEN, bBlockFalse )
EndIf

If !lIsRest .And. NX0->NX0_VLFATH == 0
	oStructNUE:SetProperty( 'NUE_CCATEG', MODEL_FIELD_WHEN, FwBuildFeature( STRUCT_FEATURE_WHEN, '.T.' ) )
	oStructNUE:SetProperty( 'NUE_HORAR' , MODEL_FIELD_WHEN, bBlockFalse )
	oStructNUE:SetProperty( 'NUE_TEMPOR', MODEL_FIELD_WHEN, bBlockFalse )
	oStructNUE:SetProperty( 'NUE_UTR'   , MODEL_FIELD_WHEN, bBlockFalse )
	oStructNUE:SetProperty( 'NUE_VALOR1', MODEL_FIELD_WHEN, bBlockFalse )
	oStructNUE:SetProperty( 'NUE_VALORH', MODEL_FIELD_WHEN, bBlockFalse )
	oStructNX0:SetProperty( 'NX0_PDESCH', MODEL_FIELD_WHEN, bBlockFalse )
	oStructNX0:SetProperty( 'NX0_TPDESC', MODEL_FIELD_WHEN, bBlockFalse )
	oStructNX0:SetProperty( 'NX0_VTS'   , MODEL_FIELD_WHEN, bBlockFalse )
	oStructNX1:SetProperty( 'NX1_PDESCH', MODEL_FIELD_WHEN, bBlockFalse )
	oStructNX1:SetProperty( 'NX1_VLDESC', MODEL_FIELD_WHEN, bBlockFalse )
	oStructNX1:SetProperty( 'NX1_VTS'   , MODEL_FIELD_WHEN, bBlockFalse )
	oStructNX2:SetProperty( 'NX2_HORAR' , MODEL_FIELD_WHEN, bBlockFalse )
	oStructNX2:SetProperty( 'NX2_TEMPOR', MODEL_FIELD_WHEN, bBlockFalse )
	oStructNX2:SetProperty( 'NX2_UTR'   , MODEL_FIELD_WHEN, bBlockFalse )
	oStructNX2:SetProperty( 'NX2_VALOR1', MODEL_FIELD_WHEN, bBlockFalse )
	oStructNX2:SetProperty( 'NX2_VALORH', MODEL_FIELD_WHEN, bBlockFalse )
	oStructNX8:SetProperty( 'NX8_VLDESC', MODEL_FIELD_WHEN, bBlockFalse )
	oStructNX8:SetProperty( 'NX8_VTS'   , MODEL_FIELD_WHEN, bBlockFalse )
EndIf

If !lIsRest .And. NX0->NX0_VLFATD == 0
	oStructNX0:SetProperty( 'NX0_VLFATD', MODEL_FIELD_WHEN, bBlockFalse )
	oStructNX1:SetProperty( 'NX1_VDESP' , MODEL_FIELD_WHEN, bBlockFalse )
	oStructNX8:SetProperty( 'NX8_VDESP' , MODEL_FIELD_WHEN, bBlockFalse )
EndIf

oStructNX0:SetProperty( 'NX0_CJCONT' , MODEL_FIELD_WHEN, bBlockFalse )
oStructNX0:SetProperty( 'NX0_COD'    , MODEL_FIELD_WHEN, bBlockFalse )
oStructNX0:SetProperty( 'NX0_DESCON' , MODEL_FIELD_WHEN, bBlockFalse )

oStructNUE:SetProperty( 'NUE_CFASE'  , MODEL_FIELD_NOUPD, .F. )
oStructNUE:SetProperty( 'NUE_CTAREB' , MODEL_FIELD_NOUPD, .F. )
oStructNUE:SetProperty( 'NUE_CTAREF' , MODEL_FIELD_NOUPD, .F. )
IIf(lShowVirt, oStructNUE:SetProperty( 'NUE_DFASE'  , MODEL_FIELD_NOUPD, .F. ), Nil)
IIf(lShowVirt, oStructNUE:SetProperty( 'NUE_DTAREB' , MODEL_FIELD_NOUPD, .F. ), Nil)
IIf(lShowVirt, oStructNUE:SetProperty( 'NUE_DTAREF' , MODEL_FIELD_NOUPD, .F. ), Nil)

oStructNXR:SetProperty( 'NXR_CMOEDA' , MODEL_FIELD_WHEN, bBlockFalse )
oStructNXR:SetProperty( 'NXR_COTAC'  , MODEL_FIELD_WHEN, FwBuildFeature( STRUCT_FEATURE_WHEN, '!Empty(FwFldGet("NXR_CMOEDA"))' ) )

oStructNX1:SetProperty( 'NX1_TKRET'  , MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, '.F.' ) )

oStructNX2:SetProperty( 'NX2_TKRET'  , MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, '.F.' ) )

oStructNX8:SetProperty( 'NX8_TKRET'  , MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, '.F.' ) )

If !lIsRest .And. NX0->NX0_SITUAC == SIT_EMIFATURA .And. lTemFat // Pre-faturas multipayer em situação 4 é permitido alterar somente os pagadores.
	JFldNoUpd("*", oStructNX0, bBlockFalse, MODEL_FIELD_WHEN)
	JFldNoUpd("*", oStructNT1, bBlockFalse, MODEL_FIELD_WHEN)
	JFldNoUpd("*", oStructNUE, bBlockFalse, MODEL_FIELD_WHEN)
	JFldNoUpd("*", oStructNV4, bBlockFalse, MODEL_FIELD_WHEN)
	JFldNoUpd("*", oStructNVV, bBlockFalse, MODEL_FIELD_WHEN)
	JFldNoUpd("*", oStructNVY, bBlockFalse, MODEL_FIELD_WHEN)
	JFldNoUpd("*", oStructNX1, bBlockFalse, MODEL_FIELD_WHEN)
	If lMultRevis
		JFldNoUpd("*", oStructOHN, bBlockFalse, MODEL_FIELD_WHEN)
	EndIf
	JFldNoUpd("*", oStructNX2, bBlockFalse, MODEL_FIELD_WHEN)
	JFldNoUpd("*", oStructNX4, bBlockFalse, MODEL_FIELD_WHEN)
	JFldNoUpd("*", oStructNX8, bBlockFalse, MODEL_FIELD_WHEN)
	JFldNoUpd("*", oStructNXR, bBlockFalse, MODEL_FIELD_WHEN)
	oStructNX0:SetProperty( 'NX0_SITCB', MODEL_FIELD_WHEN, bBlockFalse )
	oStructNX0:SetProperty( 'NX0_SIGLA', MODEL_FIELD_WHEN, bBlockFalse )
	oStructNX0:SetProperty( 'NX0_TPEMI', MODEL_FIELD_WHEN, bBlockFalse )
EndIf

// Libera alterações via REST e valida posteriormente nos eventos de GridLinePreVld e FieldPreVld
If lIsRest
	J202YesUpd(@oStructNX0, @oStructNX1, @oStructNUE, @oStructNV4, @oStructNVY, @oStructNT1)
EndIf

//--------------------------------------------------------------------
//PE - Manipulacao dos campos
//--------------------------------------------------------------------
If lJA202FLDS

	aCampos := ExecBlock('JA202FLDS', .F., .F.)

	If ValType( aCampos ) == 'A'

		For nX := 1 To Len( aCampos )
			For nY := Len( aCampos[nX] ) + 1 To 4
				aAdd( aCampos[nX], {} )
			Next

			If aCampos[nX][2] == Nil
				aCampos[nX][2]  := {}
			ElseIf aCampos[nX][3] == Nil
				aCampos[nX][3]  := {}
			ElseIf aCampos[nX][4] == Nil
				aCampos[nX][4]  := {}
			EndIf

		Next

		aStructs := {;
			{ 'NT1', oStructNT1, 'NT1DETAIL' },;
			{ 'NUE', oStructNUE, 'NUEDETAIL' },;
			{ 'NV4', oStructNV4, 'NV4DETAIL' },;
			{ 'NVV', oStructNVV, 'NVVDETAIL' },;
			{ 'NVY', oStructNVY, 'NVYDETAIL' },;
			{ 'NX1', oStructNX1, 'NX1DETAIL' },;
			{ 'NX2', oStructNX2, 'NX2DETAIL' },;
			{ 'NX4', oStructNX4, 'NX4DETAIL' },;
			{ 'NX8', oStructNX8, 'NX8DETAIL' },;
			{ 'NXG', oStructNXG, 'NXGDETAIL' },;
			{ 'NVN', oStructNVN, 'NVNDETAIL' },;
			{ 'NXR', oStructNXR, 'NXRDETAIL' } }

		For nZ := 1 To Len( aStructs )

			If ( nPos := aScan( aCampos, { |aX| aX[CAMPOS_TABELA] == aStructs[nZ][1] } ) ) > 0

				//Adiciona Campos
				For nX := 1 To Len( aCampos[nPos][CAMPOS_ADICIONAR] )
					If !aStructs[nZ][2]:HasField( aCampos[nPos][CAMPOS_ADICIONAR][nX] )
						AddCampo( 1, aCampos[nPos][CAMPOS_ADICIONAR][nX], aStructs[nZ][2] )
					EndIf
				Next

			EndIf
		Next

	Else
		aCampos := {}
	EndIf

EndIf

oModel := MPFormModel():New( 'JURA202', /*Pre-Validacao*/, /*Pos-Validacao*/, , {|| JA202FwCan(Self) } /* Cancel*/ )
oModel:AddFields( 'NX0MASTER', Nil, oStructNX0, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:AddGrid( 'NX8DETAIL', 'NX0MASTER', oStructNX8, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/ )
oModel:AddGrid( 'NX4DETAIL', 'NX0MASTER', oStructNX4, /*bLinePre*/, {|oX, nLine| Jur202LOk(oX, "NX4DETAIL", nLine, cJurUser, .F. )} /*bLinePost*/, /*bPre*/, Iif( NX4->(FieldPos('NX4_AUTO')) > 0, {|oX| J202HisPos()},) /*bPost*/ )
oModel:AddGrid( 'NVVDETAIL', 'NX0MASTER', oStructNVV, /*bLinePre*/, {|oX, nLine| Jur202LOk(oX, "NVVDETAIL", nLine, cJurUser, .F. )}, /*bPre*/, /*bPost*/, /*bLoad*/ )
oModel:AddGrid( 'NT1DETAIL', 'NX8DETAIL', oStructNT1, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/ )
oModel:AddGrid( 'NX1DETAIL', 'NX8DETAIL', oStructNX1, /*bLinePre*/, {|oX, nLine| Jur202LOk(oX, "NX1DETAIL", nLine, cJurUser, .F. )} /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/, /*nLinead*/ )

If lProtNX1 // Proteção
	oModel:AddFields( 'NX1CALC', 'NX1DETAIL', oCalcNX1, /*Pre-Validacao*/, /*Pos-Validacao*/ )
EndIf

If lMultRevis
	oModel:AddGrid( "OHNDETAIL", "NX1DETAIL", oStructOHN, Nil /*bLinePre*/, Nil  /*bLinePost*/, Nil, Nil /*bPosVal*/, Nil /*bLoad*/)
EndIf

oModel:AddGrid( 'NX2DETAIL', 'NX1DETAIL', oStructNX2, /*bLinePre*/, {|oX, nLine| Jur202LOk(oX, "NX2DETAIL", nLine, cJurUser )}, /*bPre*/, /*bPost*/, { |oGrid| LoadNX2(oGrid) } )
oModel:AddGrid( 'NUEDETAIL', 'NX1DETAIL', oStructNUE, /*bLinePre*/, {|oX, nLine| Jur202LOk(oX, "NUEDETAIL", nLine, cJurUser )}, /*bPre*/, /*bPost*/, { |oGrid| LoadLanc(oGrid, 'NUE_FILIAL', 'NUE_DATATS', 'NUE_SIGLA2', lIsRest) } )
oModel:AddGrid( 'NVYDETAIL', 'NX1DETAIL', oStructNVY, /*bLinePre*/, {|oX, nLine| Jur202LOk(oX, "NVYDETAIL", nLine, cJurUser )}, /*bPre*/, /*bPost*/, { |oGrid| LoadLanc(oGrid, 'NVY_FILIAL', 'NVY_DATA'  , 'NVY_SIGLA' , lIsRest) } )
oModel:AddGrid( 'NV4DETAIL', 'NX1DETAIL', oStructNV4, /*bLinePre*/, {|oX, nLine| Jur202LOk(oX, "NV4DETAIL", nLine, cJurUser )}, /*bPre*/, /*bPost*/, { |oGrid| LoadLanc(oGrid, 'NV4_FILIAL', 'NV4_DTCONC', 'NV4_SIGLA' , lIsRest) } )
oModel:AddGrid( 'NXGDETAIL', 'NX0MASTER', oStructNXG, {|| J202VLPAG()}, /*bLinePost*/, /*bPre*/, /*bPost*/ )
oModel:AddGrid( 'NVNDETAIL', 'NXGDETAIL', oStructNVN, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
oModel:AddGrid( 'NXRDETAIL', 'NX0MASTER', oStructNXR, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )

oModel:GetModel('NX8DETAIL'):SetUseOldGrid(.F.)
oModel:GetModel('NX4DETAIL'):SetUseOldGrid(.F.)
oModel:GetModel('NVVDETAIL'):SetUseOldGrid(.F.)
oModel:GetModel('NX1DETAIL'):SetUseOldGrid(.F.)
If lMultRevis
	oModel:GetModel('OHNDETAIL'):SetUseOldGrid(.F.)
EndIf
oModel:GetModel('NT1DETAIL'):SetUseOldGrid(.F.)
oModel:GetModel('NX2DETAIL'):SetUseOldGrid(.F.)
//Liberar estas linhas para execução do Exact Amount
oModel:GetModel('NUEDETAIL'):SetUseOldGrid(.F.)
oModel:GetModel('NVYDETAIL'):SetUseOldGrid(.F.)
oModel:GetModel('NV4DETAIL'):SetUseOldGrid(.F.)
oModel:GetModel('NXGDETAIL'):SetUseOldGrid(.F.)
oModel:GetModel('NVNDETAIL'):SetUseOldGrid(.F.)
oModel:GetModel('NXRDETAIL'):SetUseOldGrid(.F.)

oModel:SetDescription( STR0035 ) //"Modelo de Dados de Pré Fatura"
oModel:GetModel( 'NX0MASTER' ):SetDescription( STR0036 ) //"Dados da Pré-Fatura"
oModel:GetModel( 'NX8DETAIL' ):SetDescription( STR0046 ) //'Dados dos Contratos da Pré-Fatura'
oModel:GetModel( 'NX1DETAIL' ):SetDescription( STR0043 ) //"Dados dos Casos da Pré-Fatura"
oModel:GetModel( 'NX2DETAIL' ):SetDescription( STR0044 ) //"Dados dos Profissionais dos Casos da Pré-Fatura"
oModel:GetModel( 'NUEDETAIL' ):SetDescription( STR0038 ) //"Dados dos Time Sheets dos Casos da Pré-Fatura"
oModel:GetModel( 'NVYDETAIL' ):SetDescription( STR0042 ) //"Dados das Despesas dos Casos da Pré-Fatura"
oModel:GetModel( 'NV4DETAIL' ):SetDescription( STR0040 ) //"Dados dos Lanc. Tabelado dos Casos da Pré-Fatura"
oModel:GetModel( 'NT1DETAIL' ):SetDescription( STR0037 ) //"Dados dos Fixo da Pré-Fatura"
oModel:GetModel( 'NVVDETAIL' ):SetDescription( STR0041 ) //'Dados dos Faturamentos Adicionais'
oModel:GetModel( 'NX4DETAIL' ):SetDescription( STR0045 ) //'Dados dos Historicos da Pré-Fatura'
oModel:GetModel( 'NXGDETAIL' ):SetDescription( STR0103 ) //'Pagadores"
oModel:GetModel( 'NVNDETAIL' ):SetDescription( STR0251 ) //"Encaminhamento de fatura"
oModel:GetModel( 'NXRDETAIL' ):SetDescription( STR0192 ) //"Cotações da Pré-fatura"
If lMultRevis
	oModel:GetModel( 'OHNDETAIL' ):SetDescription( STR0304 ) //"Sócios/Revisores"
EndIf
//Contratos da pré
oModel:SetRelation( 'NX8DETAIL', { { 'NX8_FILIAL', "xFilial( 'NX8' )" },  ;
                                   { 'NX8_CPREFT', 'NX0_COD' } }, NX8->( "NX8_FILIAL + NX8_CPREFT" ) )
//Parcelas fixas do contrato selecionado
oModel:SetRelation( 'NT1DETAIL', { { 'NT1_FILIAL', "xFilial( 'NT1' )" }, ;
                                   { 'NT1_CPREFT', 'NX0_COD' },       ;
                                   { 'NT1_CCONTR', 'NX8_CCONTR' } }, NT1->( "NT1_FILIAL + NT1_CCONTR + NT1_CPREFT" ) )

If cNumCaso $ '1'
	nIndexNX1 := 3  //"NX1_FILIAL + NX1_CPREFT + NX1_CCONTR + NX1_CCLIEN + NX1_CLOJA + NX1_CCASO"
	aNX1Calc  := {{'NX1_FILIAL', "xFilial('NX1')"}, {'NX1_CPREFT', 'NX0_COD'}, {'NX1_CCONTR', 'NX1_CCONTR'},;
                  {'NX1_CCLIEN', 'NX1_CCLIEN'}, {'NX1_CLOJA', 'NX1_CLOJA'}, {'NX1_CCASO', 'NX1_CCASO'}}
Else
	nIndexNX1 := 4  //"NX1_FILIAL + NX1_CPREFT + NX1_CCONTR + NX1_CCASO"
	aNX1Calc  := {{'NX1_FILIAL', "xFilial('NX1')"}, {'NX1_CPREFT', 'NX0_COD'}, {'NX1_CCONTR', 'NX1_CCONTR'},;
                  {'NX1_CCASO', 'NX1_CCASO'}}
EndIf

//Casos do contrato selecionado
oModel:SetRelation( 'NX1DETAIL', { { 'NX1_FILIAL', "xFilial( 'NX1' )" },  ;
                                   { 'NX1_CPREFT', 'NX0_COD'    },        ;
                                   { 'NX1_CCONTR', 'NX8_CCONTR' } }, NX1->( IndexKey(nIndexNX1) ) )

If lProtNX1 // Proteção
	oModel:SetRelation( 'NX1CALC', aNX1Calc, NX1->( IndexKey (nIndexNX1) ) ) //Contador de lancamentos no caso
EndIf

If lMultRevis // Múltiplos Sócios / Revisores
	oModel:GetModel( "OHNDETAIL" ):SetDelAllLine(.T.)
	oModel:GetModel( "OHNDETAIL" ):SetUniqueLine( { "OHN_CPART", "OHN_REVISA" } )
	
	Aadd(aRelOHN, { 'OHN_FILIAL', "xFilial( 'OHN' )" })
	Aadd(aRelOHN, { 'OHN_CPREFT', 'NX1_CPREFT'       })
	
	If OHN->(ColumnPos("OHN_CCONTR")) > 0 // Proteção
		Aadd(aRelOHN, { 'OHN_CCONTR' , 'NX1_CCONTR' } )
	EndIf
	
	Aadd(aRelOHN, { 'OHN_CCLIEN', 'NX1_CCLIEN' })
	Aadd(aRelOHN, { 'OHN_CLOJA' , 'NX1_CLOJA'  })
	Aadd(aRelOHN, { 'OHN_CCASO' , 'NX1_CCASO'  })
	
	oModel:SetRelation( 'OHNDETAIL', aRelOHN, OHN->( IndexKey( 1 ) ) )
EndIf

//Participantes do caso selecionado
oModel:SetRelation( 'NX2DETAIL', { { 'NX2_FILIAL', "xFilial( 'NX2' )" },;
                                   { 'NX2_CPREFT', 'NX0_COD'          },;
                                   { 'NX2_CCONTR', 'NX1_CCONTR'       },;
                                   { 'NX2_CCLIEN', 'NX1_CCLIEN'       },;
                                   { 'NX2_CLOJA' , 'NX1_CLOJA'        },;
                                   { 'NX2_CCASO' , 'NX1_CCASO'        }}, "NX2_FILIAL + NX2_CPREFT + NX2_CCONTR + NX2_CCLIEN + NX2_CLOJA + NX2_CCASO" )


//Time-Sheets do caso selecionado
oModel:SetRelation( 'NUEDETAIL', { { 'NUE_FILIAL', "xFilial( 'NUE' )" },;
										{ "'1'"       , 'NX1_TS'     },;
										{ 'NUE_CPREFT', 'NX0_COD'    },;
										{ 'NUE_CCLIEN', 'NX1_CCLIEN' },;
										{ 'NUE_CLOJA' , 'NX1_CLOJA'  },;
										{ 'NUE_CCASO' , 'NX1_CCASO'  } }, "NUE_FILIAL + NUE_DATATS + NUE_CPART2" )

//Despesas do caso selecionado
oModel:SetRelation( 'NVYDETAIL', { { 'NVY_FILIAL', "xFilial( 'NVY' )" }, ;
										{ "'1'"       , 'NX1_DESP'   },;
										{ 'NVY_CPREFT', 'NX0_COD'    },;
										{ 'NVY_CCLIEN', 'NX1_CCLIEN' },;
										{ 'NVY_CLOJA' , 'NX1_CLOJA'  },;
										{ 'NVY_CCASO' , 'NX1_CCASO'  } }, "NVY_FILIAL + NVY_DATA + NVY_CPART" )
//Tabelados do caso selecionado
oModel:SetRelation( 'NV4DETAIL', { { "NV4_FILIAL", "xFilial( 'NV4' )" }, ;
										{ "'1'"       , 'NX1_LANTAB' },;
										{ 'NV4_CPREFT', 'NX0_COD'    },;
										{ 'NV4_CCLIEN', 'NX1_CCLIEN' },;
										{ 'NV4_CLOJA' , 'NX1_CLOJA'  },;
										{ 'NV4_CCASO' , 'NX1_CCASO'  } },"NV4_FILIAL + NV4_DTLANC + NV4_CPART" )

//Faturas adicionais
oModel:SetRelation( 'NVVDETAIL', { { "NVV_FILIAL", "xFilial( 'NVV' )" },  ;
										{ "NVV_CPREFT", "NX0_COD"    } }, NVV->(IndexKey(2)) )

//Hist Cobrança
oModel:SetRelation( 'NX4DETAIL', { { 'NX4_FILIAL', "xFilial( 'NX4' )" },  ;
										{ 'NX4_CPREFT', 'NX0_COD'    } }, NX4->(IndexKey(1)) )

//Cliente Pagador
oModel:GetModel( 'NXGDETAIL' ):SetUniqueLine( { "NXG_CLIPG", "NXG_LOJAPG" } )
oModel:SetRelation( 'NXGDETAIL', { { "NXG_FILIAL", "xFilial( 'NXG' )"},;
                                   { "NXG_CPREFT", "NX0_COD"         },;
                                   { "NXG_CFATAD", "NX0_CFTADC"      }}, NXG->(IndexKey(2)) )
//Encaminhamento de fatura
oModel:GetModel( 'NVNDETAIL' ):SetUniqueLine( { 'NVN_CCONT'} )
oModel:SetRelation( 'NVNDETAIL', { { 'NVN_FILIAL', "xFilial('NVN')" }, ;
										{ 'NVN_CPREFT', 'NX0_COD' },;
										{ 'NVN_CLIPG', 'NXG_CLIPG' },;
										{ 'NVN_LOJPG', 'NXG_LOJAPG' } }, NVN->( IndexKey( 7 ) ) )

//Cotações da pré
oModel:GetModel( 'NXRDETAIL' ):SetUniqueLine( { "NXR_CMOEDA" } )
oModel:SetRelation( 'NXRDETAIL', { { "NXR_FILIAL", "xFilial( 'NXR' )" },  ;
										{ "NXR_CPREFT",  "NX0_COD"    } }, NXR->(IndexKey(1)) )

oModel:SetOptional( 'NX8DETAIL', .T. )
oModel:SetOptional( 'NT1DETAIL', .T. )
oModel:SetOptional( 'NX1DETAIL', .T. )
oModel:SetOptional( 'NX2DETAIL', .T. )
oModel:SetOptional( 'NUEDETAIL', .T. )
oModel:SetOptional( 'NVYDETAIL', .T. )
oModel:SetOptional( 'NV4DETAIL', .T. )
oModel:SetOptional( 'NVVDETAIL', .T. )
oModel:SetOptional( 'NX4DETAIL', .T. )
oModel:SetOptional( 'NXGDETAIL', .T. )
oModel:SetOptional( 'NXRDETAIL', .T. )
oModel:SetOptional( 'NVNDETAIL', .T. )
If lMultRevis
	oModel:SetOptional( 'OHNDETAIL', .T.)
EndIf

oModel:GetModel( "NX4DETAIL" ):SetDelAllLine( .T. )

If lProtNX1 // Proteção
	oModel:SetOnlyQuery('NX1CALC', .T. )
EndIf

oModel:SetVldActivate( { |oModel| JA202CANAT( oModel ) } )
oModel:SetDeActivate( { |oModel| JA202DeAct( oModel ) } )

oModel:InstallEvent("JA202COMMIT", /*cOwner*/, oCommit)

oModel:SetActivate( { |oModel| JA202Act(oModel, lIsRest) } )

If !lIsRest
	oModel:SetOnDemand()
EndIf

__InitPosNX2(oStructNX2)
__NUEInitPos(oStructNUE)
__NX1InitPos(oStructNX1, lShowVirt)
__NX0InitPos(oStructNX0, lShowVirt)
__NV4InitPos(oStructNV4)

JurSetRules( oModel, 'NVNDETAIL',, 'NVN' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202Act
Função de ativação do modelo.

@param  oModel , Estrutura do modelo de dados de Pré-Fatura
@param  lIsRest, Se a execução está sendo feita via REST

@author Jorge Martins / Jonatas Martins
@since  15/04/2019
@Obs    lCancPre Variável estática declarada no início do fonte
/*/
//-------------------------------------------------------------------
Static Function JA202Act(oModel, lIsRest)

	If !lIsRest
		JA202CPYMD( oModel, .T. )
	EndIf

	cAlert   := ""
	lCancPre := .F.

	If ValType(oModel:Cargo) != "A"
		oModel:Cargo := {}
	EndIf
	aAdd(oModel:Cargo, {"JUR-NX0-TOUNLOCK", NX0->(Recno() ) } )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202SBot
Determinar a acao

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202SBot( nOpc )
Local lConfirmou  := .F.
Local aButtons    := {{.F.,Nil}, {.F.,Nil}, {.F.,Nil}, {.T.,Nil}, {.T.,Nil}, {.T.,Nil}, {.T.,STR0305}, {.T.,STR0306}, {.T.,Nil}, {.T.,Nil}, {.T.,Nil}, {.T.,Nil}, {.T.,Nil}, {.T.,Nil}, {.F.,Nil}} //"Confirmar"#"Fechar"

nOperacao := nOpc
aLancDiv  := {}
aDespDiv  := {}
aRmvLanc  := {}

If nOperacao == 3
	FWExecView( STR0047, 'JURA202', 3,, { || lConfirmou := .T. }, , , aButtons ) //"Operação da Pre-Fatura"

ElseIf nOperacao == 4
    cNX0ObsFat:= NX0->NX0_OBSFAT
	__aGridPos := {}
	FWExecView( STR0047, 'JURA202', 4,, { || lConfirmou := .F. }, , , aButtons ) //"Operação da Pre-Fatura"
EndIf

nOperacao := 0

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J202EmitM(oMarkUp)
Rotina para chamar a emissão de minuta de pré-fatura.

@Params    oMarkUp Objeto do MarkBrowser da Pré-fatura

@Return    Nil

@author Luciano Pereira dos Santos
@since 21/06/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J202EmitM(oMarkUp)
Local lRet := .T.
	If JA202VMark(oMarkUp)
		lRet := JA203BASS( oMarkUp,,,,.T. )
	EndIf

	If lRet 
		JURA203()
		oMarkUp:DeleteFilter(__CUSERID) //Remove o filtro criando pela rotina JA203BASS
		oMarkUp:Refresh(.T.)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202VMark( oMarkUp )
Valida se há algum registro marcado

@params    oMarkUp Objeto do MarkBrowser da Pré-fatura
@return    lRet - T se há marcação ou F se não há marcação

@since 11/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202VMark(oMarkUp)
Local cQuery       := ""
Local cAliasNX0    := ""
Local cMark        := oMarkUp:Mark()
Local lRet         := .T.

	cQuery := " SELECT NX0_OK, NX0_FILIAL, NX0_COD, NX0_SITUAC "
	cQuery += " FROM " + RetSqlName("NX0") + " "
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND NX0_OK = '" + cMark + "' "
	cQuery += " ORDER BY R_E_C_N_O_ DESC "
	cAliasNX0 := GetNextAlias()
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasNX0, .F., .F. )

	If ((cAliasNX0)->( Eof() ))
		lRet := .F.
	EndIf

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202AprvM( oMarkUp )
Rotina para aprovação de Minutas emitidas

@params    oMarkUp Objeto do MarkBrowser da Pré-fatura
@return    Nil

@author Willian Yoshiaki Kazahaya
@since 03/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function J202AprvM( oMarkUp )
Local cMark        := oMarkUp:Mark()
Local cQuery       := ""
Local cAliasNX0    := ""
Local lCmpAprMin   := NX0->(ColumnPos("NX0_APRMIN")) > 0
Local cJurUser     := JurUsuario(__CUSERID)
Local aNX0Erro     := {}

	If !JA202VMark(oMarkUp)
		JurMsgErro(STR0368) //"Não há pré faturas selecionadas para aprovação. Verifique"
	Else 
		If (lCmpAprMin)
			If (ApMsgYesNo(STR0367)) //"Confirma a aprovação da(s) minuta(s) destas pré-faturas?"
				cQuery := "SELECT NX0_OK, NX0_FILIAL, NX0_COD, NX0_SITUAC "
				cQuery += "FROM " + RetSqlName("NX0") + " "
				cQuery += "WHERE D_E_L_E_T_ = ' ' "
				cQuery += "AND NX0_OK = '" + cMark + "' "
				cQuery += "ORDER BY R_E_C_N_O_ DESC "

				cAliasNX0 := GetNextAlias()
				DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasNX0, .F., .F. )

				While ((cAliasNX0)->(!Eof()))
					DbSelectArea("NX0")
					NX0->( DbSetOrder(1) ) 
					If (NX0->( DbSeek((cAliasNX0)->NX0_FILIAL + ;
									(cAliasNX0)->NX0_COD + ;
									(cAliasNX0)->NX0_SITUAC) ))
						If (JURIN(NX0->NX0_SITUAC, {SIT_MINEMITIDA} ))
							RecLock("NX0", .F.)
							NX0->NX0_APRMIN := "2"
							NX0->NX0_OK     := Space(TamSX3("NX0_OK")[1])
							NX0->(MsUnlock())
							NX0->(DbCommit())
						Else
							aAdd(aNX0Erro, NX0->NX0_COD)
						EndIf
						J202HIST('8', NX0->NX0_COD, cJurUser)
					EndIf
					(cAliasNX0)->( dbSkip() )
				End 
 
				If (Len(aNX0Erro) > 0)
					MsgInfo(I18n(STR0369, {AToC(aNX0Erro)})) //"A(s) fatura(s) a seguir não foram aprovada(s) pois não estão em Minuta Emitida: #1"
				Else
					MsgInfo(STR0354) //"As minutas foram aprovadas."
				EndIf
			EndIf
		EndIf
	EndIf
Return Nil
//-------------------------------------------------------------------
/*/ { Protheus.doc } JA202COMMIT
Classe interna implementando o FWModelEvent, para execução de função
durante o commit.

@author Cristina Cintra Santos
@since 23/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA202COMMIT FROM FWModelEvent
	Data aFilaTs
	Data aWoTs
	Data aFilaDp
	Data aWoDp
	Data aFilaTb
	Data aWoTb
	Data aFilaFx
	Data lRevisada
	Data lRestri
	Data lAlterada
	Data lIsRest

	Method New()
	Method BeforeTTS()
	Method InTTS()
	Method AfterTTS()
	Method Destroy()
	Method ModelPosVld()
	Method FieldPreVld()
	Method GridLinePreVld()
End Class

//-------------------------------------------------------------------
Method New() Class JA202COMMIT
	self:aFilaTs   := {}
	self:aWoTs     := {}
	self:aFilaDp   := {}
	self:aWoDp     := {}
	self:aFilaTb   := {}
	self:aWoTb     := {}
	self:aFilaFx   := {}
	self:lRevisada := .F.
	self:lRestri   := .F.
	self:lAlterada := .F.
	self:lIsRest   := IIF(FindFunction("JurIsRest"), JurIsRest(), .F.)

Return

//-------------------------------------------------------------------
Method ModelPosVld(oSubModel, cModelId) Class JA202COMMIT
	Local lRet := .T.

	lRet := JA202TOK(oSubModel:GetModel(), @self:lAlterada )

Return lRet

//-------------------------------------------------------------------
Method BeforeTTS(oSubModel, cModelId) Class JA202COMMIT
	JA202BefCom(oSubModel:GetModel(), @self:aFilaTS, @self:aWoTS, @self:aFilaDp, @self:aWoDp, @self:aFilaTb, @self:aWoTb, @self:aFilaFx, @self:lRevisada, @self:lRestri)
Return

//-------------------------------------------------------------------
Method InTTS(oSubModel, cModelId) Class JA202COMMIT
	J202InTTS(oSubModel:GetModel(), @self:aFilaTS, @self:aWoTS, @self:aFilaDp, @self:aWoDp, @self:aFilaTb, @self:aWoTb, @self:aFilaFx, @self:lRevisada, @self:lRestri, @self:lAlterada)
	J202FSinc(oSubModel:GetModel())
Return

//-------------------------------------------------------------------
Method AfterTTS(oSubModel, cModelId) Class JA202COMMIT
	J202AftCom(oSubModel:GetModel())
	self:New()
Return

//-------------------------------------------------------------------
Method FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) Class JA202COMMIT
	Local lFldPre := .T.

	If self:lIsRest .And. cAction == "SETVALUE"
		lFldPre := J202AVldPre(oSubModel, cModelID, 0, cAction, cId, xValue)
	EndIf

Return (lFldPre)

//-------------------------------------------------------------------
Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) Class JA202COMMIT
	Local lGridPre := .T.

	If self:lIsRest .And. cAction == "SETVALUE"
		lGridPre := J202AVldPre(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue)
	EndIf

Return (lGridPre)

//-------------------------------------------------------------------
Method Destroy() Class JA202COMMIT
	self:aFilaTs   := Nil
	self:aWoTs     := Nil
	self:aFilaDp   := Nil
	self:aWoDp     := Nil
	self:aFilaTb   := Nil
	self:aWoTb     := Nil
	self:aFilaFx   := Nil
	self:lRevisada := Nil
	self:lRestri   := Nil
	self:lAlterada := Nil
	self:lIsRest   := Nil
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202BefCom
Execução antes da execução do commit dos dados do modelo.

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//--------------------------------------------------------------------
Function JA202BefCom(oModel, aFilaTS, aWoTS, aFilaDp, aWoDp, aFilaTb, aWoTb, aFilaFx, lRevisada, lRestri)
Local aArea       := GetArea()
Local nOpc        := oModel:GetOperation()
Local nQtdNX8     := 0
Local nQtdNX1     := 0
Local nQtdNT1     := 0
Local oModelNX0   := oModel:GetModel('NX0MASTER')
Local oModelNX8   := oModel:GetModel('NX8DETAIL')
Local oModelNX1   := oModel:GetModel('NX1DETAIL')
Local oModelNT1   := oModel:GetModel('NT1DETAIL')
Local nLCaso      := 0
Local nLFixo      := 0
Local nCaso       := 0
Local nContr      := 0
Local nFixo       := 0
Local nLContr     := 0
Local nQtdCas     := 0
Local nRevis      := 0
Local lIsRest     :=  Iif(FindFunction("JurIsRest"), JurIsRest(), .F.)

//Adicionado para não afetar a performance da tela quando o parâmetro de fila de integração está desativado
Local lIntegracao := (SuperGetMV("MV_JFSINC", .F., '2') == '1')

//Verifica se houve alteração no modelo de dados
If (nOpc == 4) // Alteração

	If lIntegracao

		lRestri := !Empty(oModelNX0:GetValue("NX0_OBSREV"))
		nLContr := oModelNX8:GetLine()
		nLFixo  := oModelNT1:GetLine()

		nQtdNX8 := oModelNX8:GetQtdLine()
		For nContr := 1 To nQtdNX8
			oModelNX8:GoLine(nContr)

			nQtdNT1 := oModelNT1:GetQtdLine()
			For nFixo := 1 To nQtdNT1
				If !lRestri
					lRestri := !Empty(oModelNT1:GetValue("NT1_INSREV", nFixo))
				EndIf
			Next nFixo

			nLCaso  := oModelNX1:GetLine()
			nQtdNX1 := oModelNX1:GetQtdLine()
			For nCaso := 1 To nQtdNX1
				oModelNX1:GoLine(nCaso)

				If lIntRevis .And. NX0->NX0_SITUAC == SIT_EMREVISAO
					nQtdCas++
					Iif(oModelNX1:GetValue("NX1_SITREV") == '1', nRevis++,) // Verifica a quantidade de casos revisados
					If !Empty(oModelNX1:GetValue("NX1_RETREV")) .And. !lRestri
						lRestri := ( JurGetDados('NSC', 1, xFilial('NSC') + oModelNX1:GetValue("NX1_RETREV"), 'NSC_RESTRI') == "1" .Or. ;
						             !Empty(oModelNX1:GetValue("NX1_INSREV")) .Or. ;
						             oModelNX1:GetValue("NX1_DESCEX") == "1" )
					EndIf
				EndIf

				J202GetLanc(oModel:GetModel('NUEDETAIL'), 'NUE', nCaso, nContr, @aFilaTS, @aWoTS, lIsRest)
				J202GetLanc(oModel:GetModel('NVYDETAIL'), 'NVY', nCaso, nContr, @aFilaDp, @aWoDp, lIsRest)
				J202GetLanc(oModel:GetModel('NV4DETAIL'), 'NV4', nCaso, nContr, @aFilaTb, @aWoTb, lIsRest)
				J202GetLanc(oModel:GetModel('NT1DETAIL'), 'NT1', nCaso, nContr, @aFilaFx, @aWoTb, lIsRest)

			Next nCaso

			oModelNX1:GoLine(nLCaso)
		Next nContr

		oModelNX8:GoLine(nLContr)
		oModelNT1:GoLine(nLFixo)
	EndIf

	__aGridPos  := FwSaveRows()
	__cLastPFat := oModelNX0:GetValue( 'NX0_COD' )
	lRevisada   := nRevis == nQtdCas

EndIf

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J202GetLanc()
Rotina para ler o grid de lançamentos e montar os arrays para as
alterações do LegalDesk.
Melhoria de performace da pré-fatura

@Params oGrid   Modelo de dados do lançamento Ex: oModelNUE
@Params cTab    Tabela do lançamento: Ex: "NUE"
@Params nCaso   Número da linha do caso no modelo
@Params nContr  Número da linha do contrato no modelo
@Params aFila   Array com os registros que deverão ser incluídos na fila
@Params aWo     Array com os registros que deverão sofrer WO
@Params lIsRest Indica se a chamada veio do LegalDesk

@author Luciano Pereira dos Santos
@since 01/01/17
@version 2.0
/*/
//-------------------------------------------------------------------
Static Function J202GetLanc(oGrid, cTab, nCaso, nContr, aFila, aWo, lIsRest)
Local aPosTemp   := {}
Local cAcaoLD    := ""
Local cPartLD    := ""
Local cCodLanc   := ""
Local nDataId    := 0
Local nLine      := 0
Local nQtdLines  := oGrid:GetQtdLine()

// Aponta se houve alterações em time sheet, despesa e tabelado para gravar na fila de sincronização
If oGrid:IsModified() .Or. oGrid:IsInserted()
	For nLine := 1 To nQtdLines

		If !oGrid:IsDeleted(nLine) .And. oGrid:IsUpdated(nLine) .And. !oGrid:IsEmpty(nLine)
			nDataId  := oGrid:GetDataID(nLine)
			If cTab != "NT1"
				cCodLanc := oGrid:GetValue(cTab + "_COD", nLine)
				cPartLD  := oGrid:GetValue(cTab + "_PARTLD", nLine)
			Else
				cCodLanc := oGrid:GetValue(cTab + "_SEQUEN", nLine)
			EndIf
			cAcaoLD  := oGrid:GetValue(cTab + "_ACAOLD", nLine)
			
			If !lIsRest // Se a chamada for via Protheus, simplesmente adiciona o lançamento no array para enviar para a fila de sincronização
				aAdd(aFila, {, cCodLanc})

			ElseIf cAcaoLD $ '2|5' // 2=Transferir;5=Transferir e retirar
				aAdd(aFila, {nDataId, cCodLanc, cAcaoLD, cPartLD, oGrid:GetValue(cTab + "_CCLILD", nLine), oGrid:GetValue(cTab + "_CLJLD", nLine), oGrid:GetValue(cTab + "_CCSLD", nLine)})
				oGrid:GoLine(nLine)
				oGrid:SetValue(cTab + "_TKRET", .T.)

			ElseIf cAcaoLD $ '1|3|4' //1=Retirar;3=WO;4=Lançamento indevido
				aAdd(aFila, {nDataId, cCodLanc, cAcaoLD, cPartLD,,,})

				If cAcaoLD == '3' // 3=WO
					aAdd(aPosTemp, nDataId)
				EndIf
			EndIf
		EndIf

	Next nLine

	If Len(aPosTemp) > 0
		aAdd(aWo, {nContr, nCaso, aPosTemp}) // Array com os lançamentos para WO
	EndIf

EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J202InTTS()
Rotina efetuar o commit da alterações da pré-fatura em transação
Melhoria de performance da pré-fatura

@Params oModel     Modelo de dados da Jura202
@Params aTempTS    Array multidimensional com os arrays de TimeSheets para WO e alteração LD
@Params aTempDP    Array multidimensional com os arrays de Despesas para WO e alteração LD
@Params aTempTB    Array multidimensional com os arrays de Tabelados para WO e alteração LD
@Params aTempFX    Array multidimensional com os arrays de Fixos para alteração LD
@Params lRevisada  Se .T. a pré-fatura foi revisada
@Params lRestri    Se .T. a pré-fatura foi revisada com Restrições
@Params lAlterada  Se .T. a pré-fatura foi alterada para gravar histórico

@author Luciano Pereira dos Santos
@since 01/01/17
@version 2.0
/*/
//-------------------------------------------------------------------
Static Function J202InTTS(oModel, aFilaTS, aWoTS, aFilaDp, aWoDp, aFilaTb, aWoTb, aFilaFx, lRevisada, lRestri, lAlterada)
Local lRet      := .T.
Local oModelNX0 := oModel:GetModel('NX0MASTER')
Local cCodPreFt := oModelNX0:GetValue("NX0_COD")
Local cMarca    := ""
Local lInvert   := .F.
Local lIsRest   := Iif(FindFunction("JurIsRest"), JurIsRest(), .F.)
Local lUpdNX0   := oModelNX0:IsModified()
Local cPartAlt  := JurUsuario(__CUSERID)
Local lTela     := !IsBlind() .And. !lIsRest
Local lWait     := .F.
Local aRetAuto  := {}
Local lPreFxNc  := oModelNX0:HasField("NX0_FXNC") .And. oModelNX0:GetValue("NX0_FXNC") == "1" // Pré de TS de Contratos Fixos/Não Cobrável

If !lIsRest .And. Type("oMarkUp") == "O"
	cMarca  := oMarkUp:Mark()
	lInvert := oMarkUp:IsInvert()
EndIf

Begin Transaction

	If lJura202 .And. !IsInCallStack("JA202CANPF")

		//Retira os lançamentos marcados - TKRET / Desp ou Tab não cobraveis
		If !__lOpera
			FWMsgRun(, {|| __InMsgRun := .T., lRet := JA202LIB(cCodPreFt, oModel), __InMsgRun := .F.}, STR0147, STR0288) //"Retirando lançamentos marcados..."
		Else
			FWMsgRun(, {|| __InMsgRun := .T., lRet := JA202DataID(oModel), __InMsgRun := .F.}, STR0147, STR0167) // "Atualizando lançamentos..."
		EndIf

		If lRet
			If Len(aLancDiv) > 0 .Or. Len(aRmvLanc) > 0 //Efetiva as alteraçoes do periodo
				If lTela
					__oProcess := MsNewProcess():New({|| __InMsgRun := .T., lRet := GravLanc( oModel ), __InMsgRun := .F.}, STR0147, STR0289, .T.) // "Gravando lançamentos divididos..."
					__oProcess:Activate()
				Else
					lRet := GravLanc( oModel )
				EndIf
			EndIf
		EndIf

		If lRet .And. lIsRest .And. lRevisLD .And. (NUE->(FieldPos('NUE_ACAOLD')) > 0) .And. lRevisada
			FWMsgRun(, {|| __InMsgRun := .T., JA202OPLDR(cCodPreFt, aFilaTS, aWoTS, aFilaDp, aWoDp, aFilaTb, aWoTb, aFilaFx, @lRestri), __InMsgRun := .F.}, STR0290, STR0290) //"Efetuando operações de sincronização..."
		EndIf

		If lRet .And. lIntegracao // Executa a inclusão dos registros na fila de sincronização em 2ª instância
			If FindFunction("GetParAuto")
				aRetAuto := GetParAuto("JURA202TestCase")
				If (ValType(aRetAuto) == "A" .And. Len(aRetAuto) == 1 .And. ValType(aRetAuto[1]) == "L")
					lWait := aRetAuto[1]
				EndIf
			EndIf
			StartJob("JA202GFila", GetEnvServer(), lWait, cEmpAnt, cFilAnt, __cUserID, {aFilaTS, aFilaDp, aFilaTb})
		EndIf

		// Verifica se deve cancelar a pre-fatura (caso nao existam mais lancamentos vinculados)
		If lRet .And. lCancPre .And. !lIsRest .And. (NX0->NX0_SITUAC != SIT_SUBSTITUIDA)
			FWMsgRun(, {|| __InMsgRun := .T., lRet := JA202CANPF(cCodPreFt), __InMsgRun := .F.}, STR0147, STR0051) //#"Cancelando a pré-fatura..." //##"Aguarde..."

			RecLock('NX0', .F.)
			NX0->NX0_SITUAC := SIT_SUBSTITUIDA
			NX0->NX0_USRALT := cPartAlt
			NX0->NX0_USRCAN := cPartAlt
			NX0->NX0_DTALT  := Date()
			NX0->NX0_OK     := Iif(lInvert, cMarca, "") // Limpa a marca
			NX0->(MsUnlock())
			NX0->(DbCommit())
			lUpdNX0 := .T.
			cAlert  := STR0156 //"A pré-fatura foi cancelada por não possuir mais lançamentos."
		EndIf

		If lRet .And. lIntRevis .And. lIsRest
			
			//Verifica se todos os casos da pré-fatura foram revisados, se sim, força a alteração da situação da pré-fatura e recalcula
			If (NX0->NX0_SITUAC == SIT_EMREVISAO .And. lRevisada)

				FWMsgRun(, {|| __InMsgRun := .T., JA202Calc(cCodPreFt), __InMsgRun := .F.}, STR0147, STR0202) //#Recalculando Pré-Fatura  //##Aguarde...
				
				If NX0->NX0_SITUAC != SIT_CANCREVISAO
					RecLock("NX0", .F.)
					NX0->NX0_SITUAC := Iif(lRestri .Or. lPreFxNc, "E", "D") // Altera o status da pré-fatura para revisada ou revisada com restriçoes. Se for uma pré de TS de contrato fixo ou não cobrável sempre retorna como revisada com restriçoes
					NX0->NX0_DTLIB  := Date()
					If NX0->(ColumnPos("NX0_HRLIB")) > 0
						NX0->NX0_HRLIB := StrTran(Time(), ":", "")
					EndIf
					NX0->NX0_REVIS  := "1"
					NX0->(MsUnlock())
					NX0->(DbCommit())
					
					J202HIST('99', cCodPreFt, cPartAlt, STR0277, "4") //#Revisão concluída! - Grava no histórico da pré-fatura a conclusão
				EndIf

			//Recalcula quando for retorno de desbloqueio de pré-fatura
			ElseIf NX0->NX0_SITUAC == SIT_REVISRESTRI
			
				FWMsgRun(, {|| __InMsgRun := .T., JA202Calc(cCodPreFt), __InMsgRun := .F.}, STR0147, STR0202) //#Recalculando Pré-Fatura  //##Aguarde...
				
				If NX0->NX0_SITUAC != SIT_CANCREVISAO
					RecLock("NX0", .F.)
					NX0->NX0_SITUAC := "E" //Força a situação após o recálculo
					NX0->(MsUnlock())
					NX0->(DbCommit())
				EndIf
				
			EndIf

		EndIf

		If lAlterada .And. !IsInCallStack("JA202OPERA")
			J202HIST('99', cCodPreFt, cPartAlt, STR0270, "7") //"Alteração de pré-fatura"
		EndIf
		lAlterada := .F.

		If lRet .And. lUpdNX0 .And. !lIntRevis
			J170GRAVA("NX0", xFilial("NX0") + cCodPreFt, "4") //Grava na fila de sincronização a alteração de pré-fatura
		EndIf

		If lRet //Reinicia as variaveis estaticas
			ASize(aAltPend, 0)
			ASize(aLancDiv, 0)
			ASize(aDespDiv, 0)

			While __lSX8
				ConFirmSX8()
			EndDo
		Else
			DisarmTransaction()

			While __lSX8
				RollBackSX8()
			EndDo
		EndIf

	EndIf

End Transaction

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202AftCom(oModel)
Executa ações após a efetivação do commit do modelo.

@author Cristina Cintra
@since 11/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202AftCom(oModel)
Local lIsRest   := Iif(FindFunction("JurIsRest"), JurIsRest(), .F.)
Local oModelNX0 := oModel:GetModel('NX0MASTER')
Local cCodPreFt := oModelNX0:GetValue("NX0_COD")
Local cPartAlt  := JurUsuario(__CUSERID)

oView := FwViewActive()
If oView != Nil .And. oView:oModel:cId == 'JURA202' .And. oView:GetFolderActive("FOLDER_01", 2)[1] == 6 // Aba de Revisão
	If !( (oRev := JA207GetRev()) == Nil) .And. !IsInCallStack("ConfirmRev")
		oRev:Reload(oView)
	EndIf
EndIf

If oBrwCasos != Nil //Para tratar a manipulação via REST
	oBrwCasos:Refresh() //Atualiza o Browser de Casos
EndIf

If __lExibeOK 
	If lCancPre
		If !Empty(cAlert) .And. !lIsRest
			JurErrLog(cAlert, STR0328) // "Cancelamento de Pré-Fatura"
			cAlert := ""
		EndIf
	Else
		If !Empty(cAlert)
			MsgAlert(cAlert, STR0019) //## "Alterar"
			cAlert := ""
		EndIf
	EndIf
EndIf

If !IsInCallStack("JA202TRANS")
	__lExibeOK := .T.
EndIf

If lIsRest
	// Grava Log da integração REST
	If NX4->(ColumnPos("NX4_CDIVER")) > 0
		J202HIST('99', cCodPreFt, cPartAlt, STR0001, "7", __cLogRest)
	Else
		J202Savelog() // Cria arquivo texto quando não existir o campo
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202OPLDR()
Rotina efetuar as operações em lançamentos, tais como transferência,
retirar e WO as alterações do LegalDesk.
Melhoria de performance da pré-fatura.

@Params cCodPreFt Codigo da Pré-fatura
@Params aFilaTS   Array multidimensional com os arrays de TimeSheets para WO e alteração LD
@Params aFilaDp   Array multidimensional com os arrays de Despesas para WO e alteração LD
@Params aFilaTb   Array multidimensional com os arrays de Tabelados para WO e alteração LD
@Params aFilaFX   Array multidimensional com os arrays de Fixos para alteração LD

@author Luciano Pereira dos Santos
@since 01/01/17
@version 2.0
/*/
//-------------------------------------------------------------------
Static Function JA202OPLDR(cCodPreFt, aFilaTS, aWoTS, aFilaDp, aWoDp, aFilaTb, aWoTb, aFilaFx, lRestri)
Local nLine     := 0

Default aFilaTS := {}
Default aWoTS   := {}
Default aFilaDp := {}
Default aWoDp   := {}
Default aFilaTb := {}
Default aWoTb   := {}
Default aFilaFx := {}
Default lRestri := .F.

//WO dos lançamentos pela integração
If Len(aWoTS) > 0 .Or. Len(aWoDp) > 0 .Or. Len(aWoTb) > 0
	JA202WOR( aWoTS, aWoDp, aWoTb, "", {}, {} )
EndIf

//Transferência dos lançamentos pela integração
If aScan(aFilaTS, { |aTS| aTS[3] $ '2|5' }) > 0;
	.Or. aScan(aFilaDp, { |aDP| aDP[3] $ '2|5' }) > 0;
	.Or. aScan(aFilaTb, { |aTB| aTB[3] $ '2|5' }) > 0
	lRet := JA202ETLR(,,,, @lRestri)
EndIf

For nLine := 1 To Len(aFilaTS)
	If !Empty(aFilaTS[nLine][3])
		JA202OPLD("NUE", aFilaTS[nLine][1], cCodPreFt, aFilaTS[nLine][3], aFilaTS[nLine][4], aFilaTS[nLine][5], aFilaTS[nLine][6], aFilaTS[nLine][7])
	EndIf
Next

For nLine := 1 To Len(aFilaDp)
	If !Empty(aFilaDp[nLine][3])
		JA202OPLD("NVY", aFilaDp[nLine][1], cCodPreFt, aFilaDp[nLine][3], aFilaDp[nLine][4], aFilaDp[nLine][5], aFilaDp[nLine][6], aFilaDp[nLine][7])
	EndIf
Next

For nLine := 1 To Len(aFilaTb)
	If !Empty(aFilaTb[nLine][3])
		JA202OPLD("NV4", aFilaTb[nLine][1], cCodPreFt, aFilaTb[nLine][3], aFilaTb[nLine][4], aFilaTb[nLine][5], aFilaTb[nLine][6], aFilaTb[nLine][7])
	EndIf
Next

For nLine := 1 To Len(aFilaFx)
	If !Empty(aFilaFx[nLine][3])
		JA202OPLD("NT1", aFilaFx[nLine][1], cCodPreFt, aFilaFx[nLine][3], aFilaFx[nLine][4], aFilaFx[nLine][5], aFilaFx[nLine][6], aFilaFx[nLine][7])
	EndIf
Next

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J202FSinc
Faz a gravação da Pré-fatura na Fila de Sincronização (NYS).

@author Cristina Cintra
@since 23/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202FSinc(oModel)
Local lIntegracao := (SuperGetMV("MV_JFSINC", .F., '2') == '1')
Local nOpc        := 0

If lIntegracao
	nOpc := oModel:GetOperation()
	If nOpc == 3 //Inclusão
		J170GRAVA("JURA202E", xFilial("NX0") + oModel:GetValue("NX0MASTER", "NX0_COD"), "3" )
	ElseIf nOpc == 5 //Exclusão
		J170GRAVA("JURA202E", xFilial("NX0") + oModel:GetValue("NX0MASTER", "NX0_COD"), "5")
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202GFila
Grava os lançamentos alterados na fila se sincronização.
Melhoria de performace da pré-fatura

@param cEmpAux    - Código da empresa para abrir o ambiente
@param cFilAux    - Código da filial para abrir o ambiente
@param cCodUser   - Código do usuário para abrir o ambiente e o controle de emissão
@param aParams    - Informações para geração da fila 
                    aParams[1] - Array com os TimeSheets para sincronização LD
                    aParams[2] - Array com as Despesas para sincronização LD
                    aParams[3] - Array com os Tabelados para sincronização LD

@author Luciano Pereira dos Santos
@since  01/01/17
/*/
//-------------------------------------------------------------------
Function JA202GFila(cEmpAux, cFilAux, cCodUser, aParams)
Local nLine   := 0
Local aFilaTS := aParams[1]
Local aFilaDP := aParams[2]
Local aFilaLT := aParams[3]
Local nLenTS  := Len(aFilaTS)
Local nLenDP  := Len(aFilaDP)
Local nLenLT  := Len(aFilaLT)
Local cFilNUE := ""
Local cFilNVY := ""
Local cFilNV4 := ""

	If ( !Empty(cEmpAux) .And. !Empty(cFilAux) )
		RPCSetType(3) // Prepara o ambiente e não consome licença
		RPCSetEnv(cEmpAux, cFilAux, , , , 'JA202GFila') // Abre o ambiente

		__cUserID := cCodUser
		cFilNUE   := IIf(nLenTS > 0, xFilial("NUE"), "")
		cFilNVY   := IIf(nLenDP > 0, xFilial("NVY"), "")
		cFilNV4   := IIf(nLenLT > 0, xFilial("NV4"), "")

		// Grava as alterações na fila de sincronização
		For nLine := 1 To nLenTS // TS
			J170GRAVA("NUE", cFilNUE + aFilaTS[nLine][2], "4")
		Next

		For nLine := 1 To nLenDP // DESP
			J170GRAVA("NVY", cFilNVY + aFilaDp[nLine][2], "4")
		Next

		For nLine := 1 To nLenLT // TAB
			J170GRAVA("NV4", cFilNV4 + aFilaLT[nLine][2], "4")
		Next

		RpcClearEnv() // Reseta o ambiente
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202TOK
Pos validação

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA202TOK(oModel, lAlterada)
Local lRet        := .T.
Local oModelNX0   := oModel:GetModel( 'NX0MASTER' )
Local nValorH     := 0
Local nValDesc    := 0
Local oView       := FWViewActive()
Local oRev        := Nil
Local lIsRest     := Iif(FindFunction("JurIsRest"), JurIsRest(), .F.)
Local lMultRevis  := ( SuperGetMV("MV_JMULTRV",, .F.) .And. (SuperGetMV("MV_JREVILD",, '2') == '1') .And. FWAliasInDic("OHN") ) // Indica se é utilizado o conceito de múltiplos revisores e a revisão de pré-fatura do LD.
Local cErro       := IIF(lIsRest, STR0389 + CRLF, "" )  // "Erros na integração com Legal Desk: "
Local aRet        := {}
Default lAlterada := .F.

	If lRet
		aRet := JurVldPag(oModel, .F.) //Validação de pagadores
		lRet  := aRet[1]
		cErro += aRet[2] + CRLF
	EndIf

	// verifica se o desconto foi alterado para abrir a tela de reteio.
	If lRet .And. !IsInCallStack("JA202CANPF") .And. lTelaRat
		lRet := JA203ARat("", "", "1", oModelNX0:GetValue("NX0_COD"), .T., .F. )[1]
		If !lRet
			cErro += STR0178 + CRLF // "Rotina de Rateio cancelada pelo usuário!"
			lRet := .F.
		Else
			lTelaRat := .F.
		EndIf
	EndIf

	If lRet .And. (!JurIn(oModelNX0:GetValue("NX0_SITUAC"), {SIT_ALTERADA, SIT_SUBSTITUIDA, SIT_EMIFATURA, SIT_MINEMITIDA, ;
			SIT_MINCANCEL, SIT_EMREVISAO, SIT_SINCRONIZANDO, SIT_REVISRESTRI, SIT_REVISADA }) .Or.;
			((oModelNX0:GetValue("NX0_SITUAC") == SIT_REVISRESTRI .Or. oModelNX0:GetValue("NX0_SITUAC") == SIT_REVISADA) .And. !lIsRest) );
			.And. JA202Updt(oModel)

		lRet := lRet .And. JurloadValue( oModelNX0, 'NX0_SITUAC',, SIT_ALTERADA )
		lRet := lRet .And. JurloadValue( oModelNX0, 'NX0_USRALT',, JurUsuario(__CUSERID) )
		lRet := lRet .And. JurloadValue( oModelNX0, 'NX0_DTALT',, Date() )
		lRet := lRet .And. J202CanMin(oModelNX0:GetValue("NX0_COD"), STR0270) //Alteração de pré-fatura
		lAlterada := .T.
	EndIf

	If lRet
		aAltPend := {}
	EndIf

	If lRet
		nValorH  := oModelNX0:GetValue("NX0_VLFATH") - oModelNX0:GetValue("NX0_VLFATT")
		nValDesc := oModelNX0:GetValue("NX0_DESCON") + oModelNX0:GetValue("NX0_DESCH")

		If nValDesc > nValorH
			cErro += STR0386 + " (" + cValToChar(nValDesc) + ") "  // "O valor total de desconto (nValDesc)"
			cErro += STR0387 + " (" + cValToChar(nValorH) + ") " + CRLF  // "não pode ser maior que o valor de honorários (nValorH) "
			lRet := .F.
		EndIf
	EndIf

	If lRet
		lRet := J202ValLan(oModel) //Valida as despesas e tabelados alterados.
	EndIf

	If oView <> Nil .And. oView:oModel:cId == 'JURA202'
		If oView:GetFolderActive("FOLDER_01", 2)[1] == 6 // Aba de Revisão

			If !( (oRev := JA207GetRev()) == Nil) .And. !IsInCallStack("ConfirmRev")
				lRet := oRev:ConfirmRev(oView, .F.)
			EndIf

			If lRet .And. !lAltPerio // Em alteração de valores no campo Valor TS não efetuar o JA202TotPre
				Processa({|| lRet := JA202TotPre(Nil) }, STR0147, STR0202) //Aguarde... / Recalculando Pré-Fatura

			EndIf
		EndIf
	EndIf

	If lRet .And. oModel:GetOperation() != 5

		// Validações do revisor
		If Empty(oModelNX0:GetValue("NX0_CPART"))
			cErro += STR0267 + CRLF //"O revisor não foi preenchido. Verifique!
			lRet := .F.

		Else
			cPartAtivo := JURGETDADOS("RD0", 1, xFilial("RD0") + oModelNX0:GetValue("NX0_CPART"), "RD0_MSBLQL" )
			If cPartAtivo == "1"  // Inativo
				cErro += STR0388 + CRLF // "O revisor está inativo. Verifique seu cadastro na rotina de participantes."
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If lRet .And. lMultRevis .And. oModel:GetOperation() != 5
		lRet := JVdMultRev(oModel:GetModel("OHNDETAIL"))
	EndIf

	if !lRet .And. !Empty(cErro)
		If lIsRest

			If !Empty( oModelNX0:GetValue("NX0_OBSREV") )
				cErro := oModelNX0:GetValue("NX0_OBSREV") + CRLF + ;
					" ---------------------------------------------------------- " + CRLF + cErro
			EndIf

			JurloadValue( oModelNX0, 'NX0_SITUAC',, SIT_REVISRESTRI)
			JurloadValue( oModelNX0, "NX0_OBSREV",,cErro)
			JurloadValue( oModelNX0, 'NX0_USRALT',, JurUsuario(__CUSERID) )
			JurloadValue( oModelNX0, 'NX0_DTALT',, Date() )
			lRet := .T.
		Else
			JurMsgErro(cErro) 
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202Updt
Rotina para verificar se a pré fatura foi alterada
Melhoria de performance

@Params		oMoldel modelo de dados da pré-fatura

@Return		lRet - Se o modelo foi alterado retorna .T. caso contrario .F.

@author Luciano Pereira dos santos
@since 27/01/17
@version 2.0
/*/
//-------------------------------------------------------------------
Function JA202Updt(oModel)
Local lRet      := .F.
Local aSaveLn   := FwSaveRows(  )
Local oModelNX0 := oModel:GetModel( 'NX0MASTER' )
Local oModelNX8 := oModel:GetModel( 'NX8DETAIL' )
Local oModelNT1 := oModel:GetModel( 'NT1DETAIL' )
Local oModelNX1 := oModel:GetModel( 'NX1DETAIL' )
Local oModelNUE := oModel:GetModel( 'NUEDETAIL' )
Local oModelNVY := oModel:GetModel( 'NVYDETAIL' )
Local oModelNV4 := oModel:GetModel( 'NV4DETAIL' )
Local oModelNXR := oModel:GetModel( 'NXRDETAIL' )
Local nNX8      := 0
Local nNX1      := 0
Local nLNNX8    := 0
Local nLNNX1    := 0

If !(lRet := oModelNX0:IsModified())
	If !(lRet := oModelNX8:IsModified() .Or. oModelNXR:IsModified())
		nLNNX8 := oModelNX8:GetLine()
		For nNX8 := 1 to oModelNX8:GetQtdLine()
			oModelNX8:GoLine(nNX8)
			If !(lRet := oModelNX1:IsModified() .Or. oModelNT1:IsModified())
				nLNNX1 := oModelNX1:GetLine()
				For nNX1 := 1 to  oModelNX1:GetQtdLine()
					oModelNX1:GoLine(nNX1)
					If (lRet := oModelNUE:IsModified() .Or. oModelNVY:IsModified() .Or. oModelNV4:IsModified())
						Exit
					EndIf
				Next nNX1
				oModelNX1:GoLine(nLNNX1)
			EndIf
			If lRet
				Exit
			EndIf
		Next nNX8
		oModelNX8:GoLine(nLNNX8)
	EndIf
EndIf

FwRestRows(aSaveLn)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202CANC
Cancelamento da Pré-Fatura

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202CANC(cMarca, lAutomato)
Local cRet          := ""

Default cMarca      := ""
Default lAutomato   := .F.

If !lAutomato
	If ApMsgYesNo( STR0048 + CRLF + STR0049 ) //"Confirma  o cancelamento ?"###"Atenção! Todas as pré-faturas marcadas serão canceladas."
		Processa( { || cRet := JA202CAUX(lAutomato) }, STR0050, STR0051, .F. ) //"Aguarde"###"Cancelando..."
   		If !Empty(cRet)
    		JurErrLog(cRet, STR0232) //"Cancelamento de Pré-fatura"
  		EndIf
	EndIf
Else
	Processa( { || cRet := JA202CAUX(cMarca, lAutomato) }, STR0050, STR0051, .F. ) //"Aguarde"###"Cancelando..."
	If !Empty(cRet)
		MsgAlert(cRet, STR0232) //"Cancelamento de Pré-fatura"
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202CAUX
Rotina auxiliar Cancelamento da Pré-Fatura

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA202CAUX(cMarca, lAutomato)
Local lRet        := .T.
Local aArea       := GetArea()
Local aAreaNX0    := NX0->(GetArea())
Local lInvert     := .F.
Local nQdtPF      := 0
Local nI          := 0
Local cRet        := ''
Local cFiltOld    := NX0->( dbFilter() )
Local cFiltTelaA  := ""
Local cMemo       := ""
Local cSituac     := ""
Local cCodReg     := ""
Local lRevLD      := .F.
Local cPartUser   := ""
Local lNx4CPart1  := .F.
Local cNx4Part    := ""
Local cDesmarca   := Space(TamSX3("NX0_OK")[1])
Local cFilNX0     := xFilial("NX0")
Local cFilNX4     := ""
Local cPswChave   := ""
Local cQryCanMin  := "" // Controla a query usada em cache na função J202CanMin
Local cAlsCanMin  := "" // Controla o alias usado em cache na função J202CanMin
Local lBindParam  := __FWLibVersion() >= "20211116" // Na execução do MPSysOpenQuery o parâmetro aBindParam e o conceito de bind de queries só está disponível a partir da lib label 20211116

Default cMarca    := ""
Default lAutomato := .F.

If !lAutomato

	cMarca     := oMarkUp:Mark()
	lInvert    := oMarkUp:IsInvert()

	cFiltTelaA := oMarkUp:FWFilter():GetExprADVPL()

	If !Empty(cFiltTelaA)
		cFiltTelaA := "(" + cFiltTelaA + ") .And. (NX0_OK " + Iif(lInvert, "<>", "==" ) + " '" + cMarca + "')"
		NX0->( dbClearFilter() )
		NX0->( dbSetFilter( IIf( !Empty( cFiltTelaA ), &( ' { || ' + AllTrim( cFiltTelaA ) + ' } ' ), '' ), cFiltTelaA ) )
	EndIf

Else

	cFiltTelaA := "(NX0_OK " + Iif(lInvert, "<>", "==" ) + " '" + cMarca + "')"
	NX0->( dbClearFilter() )
	NX0->( dbSetFilter( IIf( !Empty( cFiltTelaA ) , &( ' { || ' + AllTrim( cFiltTelaA ) + ' } ' ) , '' ), cFiltTelaA ) )
EndIf

NX0->( dbGoTop() )

nQdtPF := 0
NX0->( dbEVal( { || nQdtPF++ },, { || !EOF() } ) )
NX0->( dbGoTop())

lRet := nQdtPF > 0
If lRet
	ProcRegua( nQdtPF )

	cPartUser  := JurUsuario(__CUSERID)
	cPswChave  := PswChave(__CUSERID)
	lRevLD     := (SuperGetMV("MV_JFSINC", .F., '2') == '1') .And. (SuperGetMV("MV_JREVILD", .F., '2') == '1') .And. JurIsRest()
	lNx4CPart1 := NX4->(ColumnPos("NX4_CPART1")) > 0 // Proteção 12.1.33
	cFilNX4    := xFilial("NX4")

	While !NX0->( EOF() )

		IncProc(ni)

		cCodReg := NX0->NX0_COD
		cSituac := NX0->NX0_SITUAC

		If cSituac $ SIT_EMIFATURA +'|'+ SIT_EMIMINUTA +'|'+ SIT_MINEMITIDA +'|'+ SIT_MINSOCIO +'|'+ SIT_MINSOCIOEMI +'|'+ SIT_SUBSTITUIDA +'|'+ SIT_EMREVISAO +'|'+ SIT_SINCRONIZANDO
			cMemo += I18N( STR0226, { cCodReg, JurSitGet(cSituac ) } ) + CRLF //"A pré-fatura #1 esta com o status de #2"
		Else // Fluxo para cancelado da Pre-Fatura

			lConfere := NX0->NX0_SITUAC == '1'

			lRet := JA202CANPF(NX0->NX0_COD, @cMemo, cPartUser, cFilNX0) // Cancela a pré-fatura

			lRet := lRet .And. J202CanMin(NX0->NX0_COD, STR0219, @cQryCanMin, @cAlsCanMin, lBindParam) // Cancelamento da pré-fatura

			cNx4Part := NX0->NX0_CPART

			lRet := lRet .And. J202HIST('5', NX0->NX0_COD, NX0->NX0_CPART, /*cMSG*/, /*cTipoHist*/, /*cDataRest*/, lNx4CPart1, cPartUser, cNx4Part, cPswChave, lRevLD, cFilNX4) // Insere o Histórico na pré-fatura
			If lRet
				// Retira as marcas de seleção do registro escolhido pelo usuario
				RecLock( 'NX0', .F. )
				NX0->NX0_OK := Iif(lInvert, cMarca, cDesMarca) // Limpa a marca
				NX0->(MsUnLock())
				NX0->(DbCommit())

			EndIf

		EndIf

		nI := nI + 1

		NX0->( dbSkip() )

	EndDo

	If Empty(cMemo)
		cRet := STR0233 // "Pré-Fatura(s) cancela(s) com sucesso!"
	Else
		cRet := STR0234 + CRLF + CRLF + cMemo //"Uma ou mais pré-fatura(s) não pode(m) ser cancelada(s): "
	EndIf

Else
	cRet := STR0093  //# "É preciso marcar as pré-faturas em situação válida para a operação de cancelar!"
EndIf

NX0->( dbClearFilter() )
If !Empty(cFiltOld)
	NX0->( dbSetFilter( &( ' { || ' + AllTrim( cFiltOld ) + ' } ' ), cFiltOld ) )
EndIf

RestArea(aAreaNX0)
RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202CANPF
Cancela a Pré-Fatura passada no parÃ¢metro

@param cNumPreFt, Codigo da pre-fatura
@param cMemo    , Campo de observações
@param cJurUser , Usuario logado
@param cFilNX0  , Filial da NX0

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202CANPF(cNumPreFt, cMemo, cJurUser, cFilNX0)
local lRet      := .F.
Local aArea     := GetArea()
Local aAreaNX0  := NX0->(GetArea())
Local IsCancPre := .T.
Local cChave    := ""
Local lFound    := .F.

Default cMemo    := ""
Default cJurUser := ""
Default cFilNX0  := xFilial("NX0")

BEGIN TRANSACTION
	cChave := cFilNX0 + cNumPreFt

	If !(lFound := cChave == NX0->(NX0_FILIAL + NX0_COD))
		NX0->(dbSetOrder(1))
		lFound := NX0->(dbSeek(cChave))
	EndIf
	If lFound
		If (lRet := NX0->NX0_SITUAC $ SIT_ANALISE + SIT_ALTERADA + SIT_EMIFATURA + SIT_MINCANCEL + SIT_SUBSTITUIDA +;
		                              SIT_EMIMINUTA + SIT_MINEMITIDA + SIT_MINSOCIO + SIT_MINSOCIOCAN + SIT_REVISADA + SIT_REVISRESTRI)
			lRet := lRet .And. JA202LIB(cNumPreFt, /*oModel*/, IsCancPre) // Remove os vinculos e atualiza os lançamentos usando Reclok.
			If lRet

				cJurUser := IIf(Empty(cJurUser), JurUsuario(__CUSERID), cJurUser)
				If (lRet := RecLock('NX0', .F.))
					NX0->NX0_SITUAC := SIT_SUBSTITUIDA
					NX0->NX0_USRALT := cJurUser
					NX0->NX0_USRCAN := cJurUser
					NX0->NX0_DTALT  := Date()
					NX0->NX0_OK     := "" // Limpa a marca
					NX0->(MsUnlock())
					NX0->(DbCommit())
					
					// Grava na fila de sincronização o cancelamento da pré-fatura
					J170GRAVA("JURA202E", cFilNX0 + NX0->NX0_COD, "5")
				EndIf
			EndIf
		EndIf
	EndIf

	If !lRet
		DisarmTransaction()
	EndIf

END TRANSACTION

RestArea(aAreaNX0)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202SIT
Cria a barra de processamento para troca situação da Pré-Fatura

@param cNovaSit   , Código da situação
@param lAutomato  , Execução de forma automática
@param cMarcaAuto , Marca para execução de forma automática
@param cFilterAuto, Filtro para execução de forma automática
@param lEmiteMin  , Parametro enviado qual a alteração é feita ao enviar pra fila

@return array  - [1] - Se houve processamento
                 [2] - Quais pré-faturas foram alteradas com sucesso

@author Ernani Forastieri
@since  15/12/09
/*/
//-------------------------------------------------------------------
Function JA202SIT( cNovaSit, lAutomato, cMarcaAuto, cFilterAuto, lEmiteMin )
Local aRet := {.T., {}}

Default cMarcaAuto  := ""
Default cFilterAuto := ""
Default lAutomato   := .F.
Default lEmiteMin   := .F.

	If lAutomato
		aRet := JA202PSIT( cNovaSit, lAutomato, cMarcaAuto, cFilterAuto, lEmiteMin )
	Else
		Processa( { || aRet := JA202PSIT( cNovaSit, lAutomato, cMarcaAuto, cFilterAuto, lEmiteMin ) }, STR0050, STR0372, .F. ) //"Aguarde" - "Alterando situação da(s) pré-fatura(s)"
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202PSIT
Troca situação da Pré-Fatura

@param cNovaSit   , Código da situação
@param lAutomato  , Execução de forma automática
@param cMarcaAuto , Marca para execução de forma automática
@param cFilterAuto, Filtro para execução de forma automática
@param lEmiteMin  , Parametro enviado qual a alteração é feita ao enviar pra fila

@return array  - [1] - Se houve processamento
                 [2] - Quais pré-faturas foram alteradas com sucesso

@author Ernani Forastieri
@since  15/12/09
/*/
//-------------------------------------------------------------------
Static Function JA202PSIT( cNovaSit, lAutomato, cMarcaAuto, cFilterAuto, lEmiteMin )
Local aArea      := GetArea()
Local aAreaNX0   := NX0->(GetArea())
Local cMarca     := ""
Local lInvert    := .F.
Local cLit       := cNovaSit + " - " + JurSitGet(cNovaSit)
Local nQtde      := 0
Local nContador  := 0
Local cFiltOld   := NX0->( dbFilter() )
Local cFiltTelaA := ""
Local lValPosit  := .T.
Local lCancMin   := .F.
Local lRevisado  := .F.
Local lDesbloq   := .F. //Indica se houve o desbloqueio forçado da pré-fatura
Local nCount     := 0
Local cJurUser   := JurUsuario(__CUSERID)
Local cPreSit    := ""
Local cPreFxNc   := ""
Local cPreRevis  := ""
Local cPreCotac  := ""
Local cPreAprMin := ""
Local cMsgErro   := ""
Local lMsgErro   := .F.
Local lMuda      := .T.
Local aRetPE     := {.T., ""}
Local cMsgPE     := ""
Local lJ202Sit	 := ExistBlock("J202Sit")
Local lAprMin    := NX0->(ColumnPos("NX0_APRMIN")) > 0
Local lMvAprMin  := SuperGetMV("MV_JAPRMIN", .F., .F.) .And. lAprMin
Local aRet       := {.T., {}}
Local lNx4CPart1 := .F.
Local cNx4Part   := ""
Local lRevLD     := .F.
Local cFilNX0    := ""
Local cFilNX4    := ""
Local cDesmarca  := Space(TamSX3("NX0_OK")[1])
Local cPswChave  := ""
Local cQryCanMin := "" // Controla a query usada em cache na função J202CanMin
Local cAlsCanMin := "" // Controla o alias usado em cache na função J202CanMin
Local cQrySQLVlP := "" // Controla a query usada em cache na função J202SQLVlP
Local cAlsSQLVlP := "" // Controla o alias usado em cache na função J202SQLVlP
Local cQryPdRev  := "" // Controla a query usada em cache na função JA202PdRev
Local cAlsPdRev  := "" // Controla o alias usado em cache na função JA202PdRev
Local cMoeNac    := "" // Controla a moeda usada na função J202VldCot
Local cTipoConv  := "" // Controla o tipo de cotação utilizada nas conversões usada na função J202VldCot
Local cQryVldCot := "" // Controla a query usada em cache na função J202VldCot
Local cAlsVldCot := "" // Controla o alias usado em cache na função J202VldCot
Local lBindParam := __FWLibVersion() >= "20211116" // Na execução do MPSysOpenQuery o parâmetro aBindParam e o conceito de bind de queries só está disponível a partir da lib label 20211116
Local lCpoFxNc   := NX0->(ColumnPos("NX0_FXNC")) > 0
Local lVldModel  := .F.
Local lNext      := .T.
Local lMostraMsg := .T.
Local oModel     := Nil
Local aErro      := {}
Local aErroAux   := {}
Local nPos       := 0
Local nI         := 0

Default cMarcaAuto  := ""
Default cFilterAuto := ""
Default lAutomato   := .F.
Default lEmiteMin   := .F.

cMarca     := IIF(lAutomato, cMarcaAuto , oMarkUp:Mark())
lInvert    := IIF(lAutomato, .F.        , oMarkUp:IsInvert())
cFiltTelaA := IIF(lAutomato, cFilterAuto, oMarkUp:FWFilter():GetExprADVPL())

// Situacao
// 4 se a atual for 2 ou 6
// 5 se a atual for 2
// 2 se a atual for 4 ou 5
// C se a atual for 2
// 3, 7, 8 nao alteram

If !lAutomato
	If !ApMsgYesNo( STR0080 + cLit + CRLF + STR0081 ) //"Confirma a troca para situação "###"Atenção! Todas as pré-faturas marcadas serão trocadas."
		Return {.F., {}} // Retorna que o usuário cancelou o processo
	EndIf
EndIf

Begin Transaction

	If !Empty(cFiltTelaA)
		cFiltTelaA := "(" + cFiltTelaA + ") .And. (NX0_OK " + Iif(lInvert, "<>", "==" ) + " '" + cMarca + "')"
		NX0->( dbClearFilter() )
		NX0->( dbSetFilter( IIf( !Empty( cFiltTelaA ), &( ' { || ' + AllTrim( cFiltTelaA ) + ' } ' ), '' ), cFiltTelaA ) )
	EndIf
	
	NX0->( dbGoTop() )
	nQtde := 0
	NX0->(dbEVal({ || nQtde++ }))
	
	If nQtde > 0

		lNx4CPart1 := NX4->(ColumnPos("NX4_CPART1")) > 0 // Proteção 12.1.33
		lRevLD    := (SuperGetMV("MV_JFSINC", .F., '2') == '1') .And. (SuperGetMV("MV_JREVILD", .F., '2') == '1' ) .And. JurIsRest()
		cFilNX0   := IIf(lIntRevis, xFilial("NX0"), "")
		cPswChave := PswChave(__CUSERID)
		cFilNX4   := xFilial("NX4")

		IIF(!lAutomato, ProcRegua( nQtde ), )
	
		NX0->( dbGoTop())
		While !NX0->(EOF()) .And. lNext
			nContador++
			IIf(!lAutomato, IncProc(I18n(STR0373, {cValToChar(nContador), cValToChar(nQtde)})), ) // "Alterando Pré-fatura #1 de #2..."

			If !NX0->(SimpleLock())
				Loop
			EndIf
			lCancMin := .F.
			lValPosit := (NX0->NX0_VLFATH + NX0->NX0_VLFATD - NX0->NX0_VDESCT + NX0->NX0_ACRESH) > 0 .And. NX0->NX0_VLFATH >= 0 .And. NX0->NX0_VLFATD >= 0
			Do Case
			Case NX0->NX0_SITUAC == SIT_EMREVISAO .And. cNovaSit <> SIT_EMREVISAO
				If lRevisado .Or. (nCount == 0 .And. (lRevisado := ApMsgYesNo(STR0275))) //"Deseja concluir a revisão de todos os casos da pré-fatura?"
					cNovaSit := SIT_SINCRONIZANDO
					lDesbloq := .T.
					cNx4Part := IIf(lRevLD, NX0->NX0_CPART, cJurUser)
					J202HIST('7', NX0->NX0_COD, cJurUser, /*cMSG*/, /*cTipoHist*/, /*cDataRest*/, lNx4CPart1, cJurUser, cNx4Part, cPswChave, lRevLD, cFilNX4)
				Else
					nCount := 1
				EndIf
				lMuda := lRevisado
			Case cNovaSit == SIT_EMIFATURA
				If lCpoFxNc .And. NX0->NX0_FXNC == "1" // Revisão de TS de Contratos Fixos/Não Cobrável
					lMuda := .F.
					cPreFxNc += IIf(Empty(cPreFxNc), ' ', ', ') + NX0->NX0_COD
				Else
					lMuda := JURIN(NX0->NX0_SITUAC, {SIT_ANALISE, SIT_MINEMITIDA, SIT_MINSOCIOEMI, SIT_REVISADA, SIT_REVISRESTRI}) .And. J202SQLVlP(NX0->NX0_COD, @cQrySQLVlP, @cAlsSQLVlP, lBindParam) .And. lValPosit

					If lMuda .And. lMvAprMin .And. JURIN(NX0->NX0_SITUAC, { SIT_MINEMITIDA } )
						lMuda := NX0->NX0_APRMIN == "2"

						If (!lMuda)
							cPreAprMin += IIf(Empty(cPreAprMin), ' ', ', ') + NX0->NX0_COD
						EndIf
					EndIf
				EndIf

				If lMuda
					//Insere o histórico na pré-fatura
					cNx4Part := IIf(lRevLD, NX0->NX0_CPART, cJurUser)
					J202HIST('2', NX0->NX0_COD, cJurUser, /*cMSG*/, /*cTipoHist*/, /*cDataRest*/, lNx4CPart1, cJurUser, cNx4Part, cPswChave, lRevLD, cFilNX4)
				EndIf
			Case cNovaSit == SIT_EMIMINUTA .Or. cNovaSit == SIT_MINSOCIO
				If lCpoFxNc .And. NX0->NX0_FXNC == "1" // Revisão de TS de Contratos Fixos/Não Cobrável
					lMuda := .F.
					cPreFxNc += IIf(Empty(cPreFxNc), ' ', ', ') + NX0->NX0_COD
				Else
					lMuda := (JURIN(NX0->NX0_SITUAC, {SIT_ANALISE, SIT_REVISADA}) .Or. (lEmiteMin .And. JURIN(NX0->NX0_SITUAC, {SIT_EMIMINUTA} ))) .And. J202SQLVlP(NX0->NX0_COD, @cQrySQLVlP, @cAlsSQLVlP, lBindParam) .And. lValPosit
				EndIf
			Case cNovaSit == SIT_ANALISE
				lMuda := JURIN(NX0->NX0_SITUAC, {SIT_EMIMINUTA, SIT_EMIFATURA, SIT_MINCANCEL, SIT_MINSOCIO, SIT_MINSOCIOEMI, SIT_MINSOCIOCAN, SIT_REVISRESTRI, SIT_MINEMITIDA}) .And. J202SQLVlP(NX0->NX0_COD, @cQrySQLVlP, @cAlsSQLVlP, lBindParam)

				If lMuda .And. (NX0->NX0_SITUAC == SIT_MINEMITIDA)
					lCancMin := ApMsgYesNo(STR0370) // "A pré-fatura está com Minuta emitida. Ao alterar para Análise a minuta será cancelada. Deseja continuar?"
					lMuda := lCancMin
				EndIf
			Case cNovaSit == SIT_EMREVISAO
				lMuda := NX0->NX0_SITUAC == SIT_ANALISE .And. J202SQLVlP(NX0->NX0_COD, @cQrySQLVlP, @cAlsSQLVlP, lBindParam)
				If lMuda .And. lIntRevis
					If JA202PdRev(NX0->NX0_COD, @cQryPdRev, @cAlsPdRev, lBindParam) // Verifica se há casos pendentes de Revisão, caso contrário não deve alterar a situação
						//Insere o histórico na pré-fatura
						cNx4Part := IIf(lRevLD, NX0->NX0_CPART, cJurUser)
						J202HIST('99', NX0->NX0_COD, cJurUser, STR0276, "2", /*cDataRest*/, lNx4CPart1, cJurUser, cNx4Part, cPswChave, lRevLD, cFilNX4) // "Pré-fatura enviada para revisão:"
					Else
						cPreRevis += IIf(Empty(cPreRevis), ' ', ', ') + NX0->NX0_COD
						lMuda  := .F.
					EndIf
				EndIf
			OtherWise
				lMuda := .F.
			End Case

			If lMuda .And. cNovaSit $ SIT_EMIFATURA + "|" + SIT_EMIMINUTA + "|" + SIT_MINSOCIO + "|" + SIT_EMREVISAO
				If !(J202VldCot(@cMoeNac, @cTipoConv, @cQryVldCot, @cAlsVldCot, lBindParam)) // Valida cotação da pré
					cPreCotac += IIf(Empty(cPreCotac), ' ', ', ') + NX0->NX0_COD
					lMuda     := .F.	
				ElseIf (NX0->NX0_SITUAC $ SIT_ANALISE + "|" + SIT_REVISRESTRI  .And. ;
						cNovaSit == SIT_EMIFATURA) .Or. cNovaSit == SIT_EMREVISAO
					lVldModel := .T.
				EndIf
			EndIf

			If lMuda .And. lJ202Sit
				aRetPE := ExecBlock("J202Sit", .F., .F., {NX0->NX0_COD, NX0->NX0_SITUAC, cNovaSit})
				If ValType(aRetPE) == "A" .And. Len(aRetPE) == 2
					lMuda  := IIF(ValType(aRetPE[1]) == "L", aRetPE[1], .F.)
					cMsgPE += IIF(ValType(aRetPE[2]) == "C" .And. !Empty(AllTrim(aRetPE[2])), AllTrim(aRetPE[2]) + CRLF, "") 
				Else
					lMuda  := .F.
					cMsgPE += STR0344 + CRLF // "Retorno inválido no ponto de entrada 'J203BPRE'. Consulta a documentação."
				EndIf
			EndIf
	
			If lMuda
				If lVldModel						
					If oModel == Nil
						oModel := FWLoadModel( 'JURA202' )
					EndIf
					oModel:SetOperation( 4 )
					oModel:Activate()

					oModel:SetValue("NX0MASTER","NX0_SITUAC", cNovaSit)
					oModel:SetValue("NX0MASTER","NX0_USRALT", cJurUser)
					oModel:SetValue("NX0MASTER","NX0_DTALT", Date())
					oModel:SetValue("NX0MASTER","NX0_OK", IIf(lInvert, cMarca, cDesMarca))
					
					If oModel:VldData()
						oModel:CommitData()
					Else
						aErro := oModel:GetErrorMessage()
						If (nPos := aScan(aErroAux, {|x| x[2] $  aErro[6]})) == 0
							aAdd(aErroAux, {NX0->NX0_COD, aErro[6]})
						Else
							aErroAux[nPos][1] :=  aErroAux[nPos][1] + ", " + NX0->NX0_COD
						EndIf

						If nQtde > 1 .And. nContador < nQtde .And. lMostraMsg .And. ;
						    !ApMsgYesNo( I18N(STR0375, {NX0->NX0_COD}), STR0376 )// "Houveram problemas na alteração da pre-fatura #1, deseja continuar o processamento para as demais pré-faturas selecionadas?" - "Deseja alterar as próximas faturas?"
							lNext := .F.
							Exit
						Else
							lMostraMsg := .F.
						EndIf
					EndIf
					oModel:DeActivate()
				Else
					RecLock( "NX0", .F. )
					NX0->NX0_SITUAC := cNovaSit
					NX0->NX0_USRALT := cJurUser
					NX0->NX0_DTALT  := Date()
					NX0->NX0_OK     := IIf(lInvert, cMarca, cDesMarca) // Limpa a marca

					If lAprMin .And. (cNovaSit == SIT_ANALISE)
						NX0->NX0_APRMIN  := "1"
					EndIf

					NX0->(MsUnLock())
					NX0->(DbCommit())
				EndIf

				If lNext
					aAdd(aRet[2], NX0->NX0_COD) // Insere as faturas que foram movimentadas
					
					If lIntRevis .And. NX0->NX0_SITUAC $ SIT_MINEMITIDA + "|" + SIT_MINCANCEL + "|" + SIT_SUBSTITUIDA + "|" + SIT_SINCRONIZANDO + "|" + SIT_FATEMITIDA + "|" .Or. (!lIntRevis .And. NX0->NX0_SITUAC == SIT_FATEMITIDA)
						// Grava na fila de sincronização a alteração de pré-fatura
						J170GRAVA(("JURA202E"), cFilNX0 + NX0->NX0_COD, "4")
					ElseIf lIntRevis .And. NX0->NX0_SITUAC == SIT_EMREVISAO
						J170GRAVA("NX0", cFilNX0 + NX0->NX0_COD, "4")
					ElseIf lCancMin
						J202CanMin(NX0->NX0_COD, STR0371, @cQryCanMin, @cAlsCanMin, lBindParam) //'Pré fatura movimentada para "Em análise"'
					EndIf
				EndIf

			EndIf
			lVldModel := .F.
			NX0->(dbSkip())
		EndDo
	
		NX0->( dbGoTop() )

		lMsgErro := !NX0->(EOF())

		While !NX0->(EOF())
			If !(NX0->NX0_COD $ (cPreCotac + cPreRevis))
				cPreSit += IIf(Empty(cPreSit), ' ', ', ') + NX0->NX0_COD
			EndIf
			NX0->(dbSkip())
		EndDo

		If lMsgErro
			cMsgErro += IIf(Empty(cPreSit)   , "", I18n(STR0342, {cPreSit}  )  + CRLF + CRLF) // "Verifique a situação da(s) pré-fatura(s): #1."
			cMsgErro += IIf(Empty(cPreRevis) , "", I18n(STR0337, {cPreRevis})  + CRLF + CRLF) // "Verifique se há casos pendentes de revisão na(s) pré-fatura(s): #1."
			cMsgErro += IIf(Empty(cPreCotac) , "", I18n(STR0343, {cPreCotac})  + CRLF + CRLF) // "Verifique a cotação da(s) pré-fatura(s): #1."
			cMsgErro += Iif(Empty(cPreAprMin), "", I18n(STR0357, {cPreAprMin}) + CRLF + CRLF) // "A(s) pré-fatura(s) não podem ser movimentada(s) pois a minuta não foi aprovada: #1"
			cMsgErro += Iif(Empty(cPreFxNc)  , "", I18n(STR0374, {cPreFxNc})                ) // "A(s) pré-fatura(s) não podem ser movimentada(s) pois estão disponíveis apenas para revisão de time sheets: #1"

			For nI := 1 To Len(aErroAux)
				cMsgErro += I18N(STR0377, {aErroAux[nI][1], aErroAux[nI][2]}) + CRLF //"Pré-fatura(s): #1."
				cMsgErro += I18N(STR0378, {aErroAux[nI][2]}) + CRLF + CRLF // Erro: #1" 
			Next nI

			If !Empty(cMsgPE)
				cMsgErro += CRLF + cMsgPE
			EndIf
			JurMsgErro(STR0055,, cMsgErro) // "Não foi possível alterar a situação da(s) pré-fatura(s) abaixo."
		EndIf
	
	Else
		JurMsgErro( STR0122 ) // "É preciso marcar as pré-faturas para alterar a situação"
	EndIf
	
	NX0->( dbClearFilter() )
	If !Empty(cFiltOld)
		NX0->( dbSetFilter( &( ' { || ' + AllTrim( cFiltOld ) + ' } ' ), cFiltOld ) )
	EndIf

	If oModel != Nil
		oModel:destroy()
	EndIf

End Transaction

RestArea(aAreaNX0)
RestArea( aArea )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202CANAT
Verifca se pode ativar o model

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA202CANAT( oModel )
Local lRetAtiv   := .F.
Local aArea      := GetArea()
Local aAreaNX0   := NX0->(GetArea())
Local nOpc       := oModel:GetOperation()
Local lIsRest    := Iif(FindFunction("JurIsRest"), JurIsRest(), .F.)
Local cSituac    := NX0->NX0_SITUAC
Local cPreFat    := NX0->NX0_COD
Local cSolucao   := ""
Local lVldUser   := Iif(FindFunction("JurVldUxP"), JurVldUxP(oModel), .T.)

If lVldUser
	If nOpc == MODEL_OPERATION_VIEW // Visualização
		lRetAtiv := .T.
	Else
		If nOpc == MODEL_OPERATION_UPDATE // Alteração
			If lIsRest //Bloco de validação Rest
				If (cSituac $ SIT_EMREVISAO + "|" + SIT_SINCRONIZANDO)
					lRetAtiv := .T.
				Else
					JurSitLoad() //Carrega as situações da pré-fatura
					cSolucao := CRLF + "- " + JurSitGet(SIT_EMREVISAO) + CRLF + "- " + JurSitGet(SIT_SINCRONIZANDO)
					JurMsgErro(I18N(STR0321, {cPreFat}), , I18N(STR0322, {cSolucao})) //#"Não é possível alterar a pré-fatura: #1." ##  "É possivel alterar somente pré-faturas com as situações: #1"
				EndIf
				If lRetAtiv
					If !NX0->(SimpleLock())
						lRetAtiv := .F.
						JurMsgErro(STR0329,, STR0330) // "A pré-fatura está sendo alterada via tela, necessário aguardar a liberação do registro." # "Realize nova tentativa em alguns minutos."
					Else
						RecLock("NX0", .F.) // Colocado o reclock mesmo com o uso do SimpleLock para que o registro seja liberado pelo MsunlockAll
					EndIf
				EndIf
			Else
				If ((cSituac $ SIT_ANALISE + "|" + SIT_ALTERADA + "|" + SIT_REVISADA + "|" + SIT_REVISRESTRI) ; 
				    .Or. (cSituac == SIT_EMIFATURA .And. JA201TemFt(cPreFat))) //Bloco de validação Operações de Pré-fatura
					lRetAtiv := .T.
				Else
					cSolucao := CRLF + "- " + JurSitGet(SIT_ANALISE) + CRLF + "- " + JurSitGet(SIT_ALTERADA) + Iif(lIntRevis, CRLF + "- " + JurSitGet(SIT_REVISADA) + CRLF + "- " + JurSitGet(SIT_REVISRESTRI), "") 
					JurMsgErro(I18N(STR0321, {cPreFat}), , I18N(STR0322, {cSolucao})) //#"Não é possível alterar a pré-fatura: #1." ##  "É possivel alterar somente pré-faturas com as situações: #1"
				EndIf
			EndIf
		Else 
			JurMsgErro(I18N(STR0326, {cPreFat})) // "Operação inválida para a Pré-Fatura: #1"
		EndIf
	EndIf
EndIf

RestArea(aAreaNX0)
RestArea(aArea)

Return lRetAtiv

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202REV
Revisao da Pré-Fatura

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202REV( cOpera )
Local lRet        := .F.
Local aArea       := GetArea()
Local aAreaNX0    := NX0->( GetArea() )
Local aAreaNX4    := NX4->( GetArea() )
Local cHora       := Time()
Local cHist       := CriaVar('NX4_HIST', .F.)
Local cMarca      := oMarkUp:Mark()
Local lInvert     := oMarkUp:IsInvert()
Local cSigla      := CriaVar('NX4_SIGLA', .F.)
Local cSitCob     := CriaVar('NX0_SITCB', .F.)
Local dData       := Date()
Local oDlg        := Nil
Local oGet1       := Nil
Local oGet2       := Nil
Local oGet3       := Nil
Local oGet4       := Nil
Local cFiltOld    := NX0->( dbFilter() )
Local cFiltTelaA  := oMarkUp:FWFilter():GetExprADVPL()
Local oLayer      := FWLayer():New()
Local oMainColl   := Nil
Local cRotina     := ProcName(0)

If !Empty(cFiltTelaA)
	cFiltTelaA := "(" + cFiltTelaA + ") .And. (NX0_OK " + Iif(lInvert, "<>", "==" ) + " '" + cMarca + "')"
	NX0->( dbClearFilter() )
	NX0->( dbSetFilter( IIf( !Empty( cFiltTelaA ), &( ' { || ' + AllTrim( cFiltTelaA ) + ' } ' ), '' ), cFiltTelaA ) )
EndIf
NX0->( dbGoTop() )

If !NX0->(EOF())

	If cOpera == '1'

		DEFINE MSDIALOG oDlg TITLE STR0022 FROM 0, 0 TO 230, 400 PIXEL //"Revisão"

		oLayer:init(oDlg, .F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
		oLayer:addCollumn("MainColl", 100, .F.) //Cria as colunas do Layer
		oMainColl := oLayer:GetColPanel('MainColl')

		oGet1 := TJurPnlCampo():New(05, 05, 50, 22, oMainColl, STR0059, ("NX4_DTSAID"), {|| }, {|| }, dData,,,) //"Data"
		oGet1:oCampo:bValid  := {|| IIf( Empty(dData), JurMsgErro(STR0060, cRotina, STR0285), .T.) } //#"Data não pode estar em branco."  ##"Informe uma data válida antes de confirmar."
		oGet1:SetChange({|| (dData := oGet1:Valor)})

		oGet2 := TJurPnlCampo():New(05, 65, 35, 22, oMainColl, STR0061, ("NX4_HRSAID"), {|| }, {|| }, cHora,,,) //"Hora"
		oGet2:SetChange({|| (cHora := oGet2:Valor)})
		oGet2:oCampo:bValid  := {|| IIf( Empty(StrTran(cHora, ":", "")), JurMsgErro(STR0062, cRotina, STR0284), Iif(J202VldHs(cHora), .T., JurMsgErro(STR0283, cRotina, STR0284)) ) } //#"Hora não pode estar em branco."  ##"A hora informada não é uma hora válida." ###"Informe uma hora válida antes de confirmar."
		oGet2:oCampo:Picture := '99:99:99'

		oGet3 := TJurPnlCampo():New(05, 122, 60, 22, oMainColl, STR0063, ("RD0_SIGLA"), {|| }, {|| },,,, 'RD0REV') //"Revisor"
		oGet3:SetChange({|| (cSigla := oGet3:Valor)})
		oGet3:oCampo:bValid  := {|| ExistCPO('RD0', cSigla, 9) }

		oGet4 := TJurPnlCampo():New(35, 05, 160, 30, oMainColl, STR0028, ("NX4_HIST"), {|| }, {|| },,,,) //"Historico"
		oGet4:SetChange({|| (cHist := oGet4:Valor)})

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| (lRet := .T., oDlg:End()) }, {|| (lRet := .F., oDlg:End())},;
                                                                        , /*aButtons*/, /*nRecno*/, /*cAlias*/, .F., .F., .F., .T., .F. )

	ElseIf cOpera == '2'

		DEFINE MSDIALOG oDlg TITLE STR0022 FROM 0, 0 TO 160, 300 PIXEL //"Revisão"

		oLayer:init(oDlg, .F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
		oLayer:addCollumn("MainColl", 100, .F.) //Cria as colunas do Layer
		oMainColl := oLayer:GetColPanel('MainColl' )

		oGet1 := TJurPnlCampo():New(10, 05, 50, 22, oMainColl, STR0064, ("NX0_SITCB"), {|| }, {|| },,,, 'NSC') //"Sit. Cobrança"
		oGet1:SetChange({|| (cSitCob := oGet1:Valor)})
		oGet1:oCampo:bValid := {|| ExistCpo( 'NSC', cSitCob ) }

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| (lRet := .T., oDlg:End()) }, {||(lRet := .F., oDlg:End())},;
                                                                        , /*aButtons*/, /*nRecno*/, /*cAlias*/, .F., .F., .F., .T., .F. )

	Else
		lRet := .T.
	EndIf

	If lRet

		Processa( { |lEnd| lRet := JA202REVP(cOpera, lInvert, cMarca, cHist, dData, cHora, cSigla, cSitCob, @lEnd) }, STR0022, STR0147, .T. ) // "Revisão" e 'Aguarde...'

		If lRet
			ApMsgInfo(STR0127) // "Operação concluída!"
		Else
			ApMsgInfo(STR0282) // "Operação cancelada pelo usuário."
		EndIf
	EndIf

Else
	ApMsgStop(STR0094) // "É preciso marcar as pré-faturas para Enviar para Revisão"
EndIf

NX0->( dbClearFilter() )
If !Empty(cFiltOld)
	NX0->( dbSetFilter( &( ' { || ' + AllTrim( cFiltOld ) + ' } ' ), cFiltOld ) )
EndIf

RestArea( aAreaNX4 )
RestArea( aAreaNX0 )
RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J202VldHs()
Rotina para validação de Hora.

@author Luciano Pereira dos Santos
@since 18/11/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202VldHs(cHora)
Local lRet := .T.
Local nHor := 0
Local nMin := 0
Local nSeg := 0

cHora := StrTran(cHora, ":", "")

nHor  := Val(Substr(cHora, 1, 2))
nMin  := Val(Substr(cHora, 3, 2))
nSeg  := Val(Substr(cHora, 5, 2))

If (nHor < 0 .Or. nHor > 23)
	lRet := .F.
EndIf

If lRet .And. (nMin < 0 .Or. nMin > 59)
	lRet := .F.
EndIf

If lRet .And. (nSeg < 0 .Or. nSeg > 59)
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202REVP()
Rotina para efetuar o processamento da rotina de revisão JA202REV()

@author Luciano Pereira dos Santos
@since 18/11/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA202REVP(cOpera, lInvert, cMarca, cHist, dData, cHora, cSigla, cSitCob, lEnd)
Local lRet      := .T.
Local nQtde     := 0
Local cSeq      := ""
Local lRevLD    := lIntRevis .AND. JurIsRest()
Local lNX4Part1 := NX4->(ColumnPos("NX4_CPART1")) > 0//Proteção 12.1.33
Local cPart1    := IIF(lNX4Part1, JurUsuario(__cUserId), "")
Local cPart     := IIF(!lRevLD, JurGetDados('RD0', 9, xFilial('RD0') + Alltrim(cSigla), 'RD0_CODIGO'), "")

Default lEnd := .F.

NX0->( dbEVal( { || nQtde++ },, { || !EOF() } ) )
NX0->( dbGoTop() )

ProcRegua( nQtde )

If Empty(cHist)
	cHist := STR0286 //"Envio para revisão."
EndIf

While !NX0->( EOF() )

	If lEnd
		lRet := .F.
		Exit
	EndIf

	IncProc(STR0026 + ": " + NX0->NX0_COD) //"Pré-fatura"

	Begin Transaction
		RecLock( 'NX0', .F. )
		NX0->NX0_OK := Iif(lInvert, cMarca, Space(TamSX3("NX0_OK")[1])) // Limpa flag de marcacao
		NX0->(MsUnLock())

		If cOpera == '1' //envio
			cSeq := JurGetNum('NX4', 'NX4_COD')
			If __lSX8
				ConfirmSX8()
			EndIf
			RecLock('NX4', .T.)
			NX4->NX4_FILIAL  := xFilial( 'NX4' )
			NX4->NX4_COD     := cSeq
			NX4->NX4_CPREFT  := NX0->NX0_COD
			NX4->NX4_DTINC   := Date()
			NX4->NX4_HRINC   := Time()
			NX4->NX4_HIST    := cHist
			NX4->NX4_USRINC  := cUserName
			NX4->NX4_DTSAID  := dData
			NX4->NX4_HRSAID  := cHora
			Iif( NX4->(FieldPos('NX4_AUTO')) > 0, NX4->NX4_AUTO := '2',)

			NX4->NX4_CPART   := IIF(!lRevLD, cPart, NX0->NX0_CPART)
			
			If lNX4Part1
				NX4->NX4_CPART1 := cPart1	
			EndIf
			NX4->(MsUnLock())
			NX4->(DbSkip())

		ElseIf cOpera == '2' //retorno
			NX4->( dbSetOrder( 2 ) ) //NX4_FILIAL + NX4_CPREFT
			NX4->( dbSeek( xFilial( 'NX4' ) + NX0->NX0_COD ) )

			While !NX4->( EOF() ) .And. NX4->(NX4_FILIAL + NX4_CPREFT) == xFilial('NX4') + NX0->NX0_COD

				If !Empty( NX4->NX4_DTSAID ) .And. Empty( NX4->NX4_DTRET )
					RecLock( 'NX4', .F. )
					NX4->NX4_DTRET := Date()
					NX4->NX4_HRRET := Time()
					NX4->(MsUnLock())
				EndIf

				NX4->( dbSkip() )
			EndDo

			RecLock('NX0', .F.)
			NX0->NX0_SITCB := cSitCob
			NX0->(MsUnLock())

		ElseIf cOpera == '3'
			RecLock('NX0', .F.)
			NX0->NX0_TPEMI := '1'
			NX0->(MsUnLock())

		ElseIf cOpera == '4'
			RecLock('NX0', .F. )
			NX0->NX0_TPEMI := '2'
			NX0->(MsUnLock())

		EndIf

	End Transaction

	NX0->( dbSkip() )

EndDo

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202MARCA
Marca todos os filhos quando marca o pai

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202MARCA( oModel )
Local lRet        := .T.
Local nLineNX8
Local nLineNT1
Local nLineNX1
Local nLineNX2
Local nLineNUE
Local nLineNVY
Local nLineNV4
Local nQtdFixo   := 0
Local nQtdPart   := 0
Local nQtdTSheet := 0
Local nQtdDesp   := 0
Local nQtdLanTab := 0

Local nTQtFixo   := 0
Local nTQtTSheet := 0
Local nTQtDesp   := 0
Local nTQtLanTab := 0
Local nTQtContr  := 0

Local oModelNX8
Local oModelNX1
Local oModelNX2
Local oModelNVY
Local oModelNUE
Local oModelNV4
Local oModelNT1
Local oModelNVV

Local lRemCont
Local lRemCaso
Local nSavNX8, nSavNX1, nSavNX2
Local nSavNUE, nSavNVY, nSavNV4

oModelNX8 := oModel:GetModel( 'NX8DETAIL' )
oModelNX1 := oModel:GetModel( 'NX1DETAIL' )
oModelNX2 := oModel:GetModel( 'NX2DETAIL' )
oModelNVY := oModel:GetModel( 'NVYDETAIL' )
oModelNUE := oModel:GetModel( 'NUEDETAIL' )
oModelNV4 := oModel:GetModel( 'NV4DETAIL' )
oModelNT1 := oModel:GetModel( 'NT1DETAIL' )
oModelNVV := oModel:GetModel( 'NVVDETAIL' )

If oModelNVV:GetValue("NVV_TKRET") //Fatura Adicional
	lRet := JurMsgErro(STR0092) //"Para desvincular a fatura adicional é necessário cancelar a pré-fatura"
EndIf

If lRet
	//Contratos
	lRemCont := .F.
	nSavNX8  := oModelNX8:GetLine()
	For nLineNX8 := 1 To oModelNX8:GetQtdLine()
		oModelNX8:GoLine(nLineNX8)
		If oModelNX8:GetValue("NX8_TKRET") //Se remover o contrato, remove tudo
			lRemCont := .T.
		Else
			lRemCont := .F.
		EndIf

		//Parcelas Fixas do contrato (NT1)
		If oModelNX8:GetValue("NX8_FIXO") == '1'
			nQtdFixo := oModelNT1:GetQtdLine()
			For nLineNT1 := 1 To oModelNT1:GetQtdLine()
				oModelNT1:GoLine(nLineNT1)
				If oModelNT1:GetValue("NT1_TKRET") .Or. lRemCont .Or. ( nQtdFixo == 1 .And. oModelNT1:IsEmpty() )
					nQtdFixo --
				EndIf
			Next
		EndIf
		lRemCaso := lRemCont
		nSavNX1 := oModelNX1:GetLine()
		//Casos do contrato
		For nLineNX1 := 1 To oModelNX1:GetQtdLine()
			oModelNX1:GoLine(nLineNX1)
			If oModelNX1:GetValue("NX1_TKRET")
				lRemCaso := .T.
			Else
				lRemCaso := .F.
			EndIf

			If lRemCaso
				//Desvincula todos os lançamentos, sem se preocupar com os vínculos
				nQtdTSheet := oModelNUE:GetQtdLine()
				nSavNUE := oModelNUE:GetLine()
				For nLineNUE := 1 To oModelNUE:GetQtdLine()
					oModelNUE:GoLine(nLineNUE)
					If oModelNUE:GetValue("NUE_TKRET") .Or. lRemCaso .Or. ( nQtdTSheet == 1 .And. oModelNUE:IsEmpty() )
						nQtdTSheet --
					EndIf
				Next nLineNUE
				oModelNUE:GoLine(nSavNUE)

				nQtdLanTab := oModelNV4:GetQtdLine()
				nSavNV4 := oModelNV4:GetLine()
				For nLineNV4 := 1 To oModelNV4:GetQtdLine()
					oModelNV4:GoLine(nLineNV4)
					If oModelNV4:GetValue("NV4_TKRET") .Or. lRemCaso .Or. ( nQtdLanTab == 1 .And. oModelNV4:IsEmpty() )
						nQtdLanTab --
					EndIf
				Next nLineNV4
				oModelNV4:GoLine(nSavNV4)

				nQtdDesp := oModelNVY:GetQtdLine()
				nSavNVY := oModelNVY:GetLine()
				For nLineNVY := 1 To oModelNVY:GetQtdLine()
					oModelNVY:GoLine(nLineNVY)
					If oModelNVY:GetValue("NVY_TKRET") .Or. lRemCaso .Or. ( nQtdDesp == 1 .And. oModelNVY:IsEmpty() )
						nQtdDesp --
					EndIf
				Next nLineNVY
				oModelNVY:GoLine(nSavNVY)
			Else
				//Se não remover todo o caso, verifica os vínculos
				//Participantes do caso
				If oModelNX8:GetValue("NX8_TS") == '1' .And. oModelNX1:GetValue("NX1_TS") == '1'
					nQtdPart := oModelNX2:GetQtdLine()
					nSavNX2 := oModelNX2:GetLine()
					For nLineNX2 := 1 To oModelNX2:GetQtdLine()
						oModelNX2:GoLine(nLineNX2)
						If oModelNX2:GetValue("NX2_TKRET") .Or. lRemCaso .Or. ( nQtdPart == 1 .And. oModelNX2:IsEmpty() )
							nQtdPart --
							//Se o participante estiver marcado, retirar todos os TSs dele para este caso
							nSavNUE := oModelNUE:GetLine()
							For nLineNUE := 1 To oModelNUE:GetQtdLine()
								oModelNUE:GoLine(nLineNUE)

								If Alltrim( oModelNX2:GetValue("NX2_CPART"))  == Alltrim( oModelNUE:GetValue("NUE_CPART2")) .And.;
											oModelNX2:GetValue("NX2_VALORH")  ==          oModelNUE:GetValue("NUE_VALORH") .And.;
									Alltrim(oModelNX2:GetValue("NX2_CCATEG")) == Alltrim( oModelNUE:GetValue("NUE_CCATEG")) .And.;
									Alltrim(oModelNX2:GetValue("NX2_CMOTBH")) == Alltrim( oModelNUE:GetValue("NUE_CMOEDA")) .And.;
									Alltrim(oModelNX2:GetValue("NX2_CLTAB"))  == Alltrim( oModelNUE:GetValue("NUE_CLTAB") ) .And.;
								    !oModelNUE:IsEmpty()

									oModelNUE:SetValue("NUE_TKRET", .T.)
								EndIf
							Next nLineNUE
							oModelNUE:GoLine(nSavNUE)
						EndIf
					Next nLineNX2
					oModelNX2:GoLine(nSavNX2)
				EndIf

				/******Lançamentos do caso***********/
				//Time-Sheets do caso
				If oModelNX8:GetValue("NX8_TS") == '1' .And. oModelNX1:GetValue("NX1_TS") == '1'
					nQtdTSheet := oModelNUE:GetQtdLine()
					nSavNUE := oModelNUE:GetLine()
					For nLineNUE := 1 to oModelNUE:GetQtdLine()
						oModelNUE:GoLine(nLineNUE)
						If oModelNUE:GetValue("NUE_TKRET") .Or. lRemCaso .Or. ( nQtdTSheet == 1 .And. oModelNUE:IsEmpty() )
							nQtdTSheet --
						EndIf
					Next nLineNUE
					oModelNUE:GoLine(nSavNUE)
				EndIf
				//Despesas do caso
				If oModelNX8:GetValue("NX8_DESP") == '1' .And. oModelNX1:GetValue("NX1_DESP") == '1'
					nQtdDesp := oModelNVY:GetQtdLine()
					nSavNVY := oModelNVY:GetLine()
					For nLineNVY := 1 To oModelNVY:GetQtdLine()
						oModelNVY:GoLine(nLineNVY)
						If oModelNVY:GetValue("NVY_TKRET") .Or. lRemCaso .Or. ( nQtdDesp == 1 .And. oModelNVY:IsEmpty() )
							nQtdDesp --
						EndIf
					Next nLineNVY
					oModelNVY:GoLine(nSavNVY)
				EndIf
				//Lanc Tabelados do caso
				If oModelNX8:GetValue("NX8_LANTAB") == '1' .And. oModelNX1:GetValue("NX1_LANTAB") == '1'
					nQtdLanTab := oModelNV4:GetQtdLine()
					nSavNV4 := oModelNV4:GetLine()
					For nLineNV4 := 1 To oModelNV4:GetQtdLine()
						oModelNV4:GoLine(nLineNV4)
						If oModelNV4:GetValue("NV4_TKRET") .Or. lRemCaso .Or. ( nQtdLanTab == 1 .And. oModelNV4:IsEmpty() )
							nQtdLanTab --
						EndIf
						//Remove os Time-Sheets Vinculados
						nSavNUE := oModelNUE:GetLine()
						For nLineNUE := 1 To oModelNUE:GetQtdLine()
							oModelNUE:GoLine(nLineNUE)
							If oModelNV4:GetValue("NV4_COD") == oModelNUE:GetValue("NUE_CLTAB")
								JurSetValue( oModelNUE, "NUE_TKRET",, oModelNV4:GetValue("NV4_TKRET") )
							EndIf
						Next nLineNUE
						oModelNUE:GoLine(nSavNUE)
					Next  nLineNV4
					oModelNV4:GoLine(nSavNV4)
				EndIf
			EndIf

			nTQtTSheet += nQtdTSheet
			nTQtDesp   += nQtdDesp
			nTQtLanTab += nQtdLanTab

		Next nLineNX1
		oModelNX1:GoLine(nSavNX1)

		nTQtFixo += nQtdFixo

		If nTQtTSheet == 0 .And. nTQtDesp == 0 .And. nTQtLanTab == 0 .And. nTQtFixo == 0
			nTQtContr++
			If !oModelNX8:IsEmpty()
				oModelNX8:SetValue("NX8_TKRET", .T.)
			EndIf
		EndIf

	Next nLineNX8
	oModelNX8:GoLine(nSavNX8)

	If oModelNX8:GetQtdLine() == nTQtContr
		lCancPre := .T.
		JA202RET( oModel )
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202REDA2
Redacao da Pre-fatura

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202REDA2( oView, cOpera )
Local aArea     := GetArea()
Local aAreaNX0  := NX0->( GetArea() )
Local cGetFat   := Space(TamSX3("NXA_COD")[1])
Local nRadioGrp := 0
Local oGetEscr
Local oGetFat
Local oRadioGrp
Local oDlg

Private cEscri  := Space(TamSX3("NXA_CESCR")[1])

	DEFINE MSDIALOG oDlg TITLE STR0033 FROM 233,194 TO 603,747 PIXEL //"Redação"

	@ 002,002 TO 045,095 LABEL STR0072 PIXEL OF oDlg //" Origem da Redação "
	@ 012,005 Radio oRadioGrp Var nRadioGrp Items STR0073, STR0074, STR0075 3D Size 100,010 PIXEL OF oDlg //"Descrição dos Time Sheets"###"Fatura"###"Caso"
	oRadioGrp:bChange := { || cEscri := Space(TamSX3("NXA_CESCR")[1]), ;
								cGetFat := Space(TamSX3("NXA_COD")[1]), ;
								IIf( nRadioGrp <> 2, ( oGetEscr:Disable(), oGetFat:Disable() ), ( oGetEscr:Enable(), oGetFat:Enable() ) ), ;
								oGetEscr:Refresh(), ;
								oGetFat:Refresh() , ;
								oGetFat:Refresh() }

	@ 015,097 Say STR0076  Size 030,008 PIXEL OF oDlg //"Escritório"
	@ 025,097 MsGet oGetEscr    Var cEscri Valid ExistCPO("NS7", cEscri) F3 "NS7" Size 060,009 PIXEL OF oDlg HasButton
	oGetEscr:Disable()

	@ 015,160 Say STR0074      Size 018,008 PIXEL OF oDlg //"Fatura"
	@ 025,160 MsGet oGetFat     Var cGetFat Valid ExistCPO('NXA', cEscri + cGetFat) F3 'NXA1' Size 060,009 PIXEL OF oDlg HasButton
	oGetFat:Disable()
	oGetFat:bWhen := {|| !Empty(cEscri)}
	oGetFat:bF3   := {|| JbF3LookUp("NXA1", oGetFat, @cGetFat)}

	@ 007,235 Button STR0077 Size 037,012 PIXEL OF oDlg Action (VldReda2(nRadioGrp, cOpera, cEscri, cGetFat)) //"Ok"

	ACTIVATE MSDIALOG oDlg CENTERED

	oView:Refresh()
	RestArea( aAreaNX0 )
	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} VldReda2
Valida redacao da Pré-Fatura

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldReda2( nRadioGrp, cOpera, cEscrit, cFatura )
	Local lRet := .T.

	If nRadioGrp == 2 .And. Empty( cFatura )
		lRet := JurMsgErro( STR0078 ) //"Informe a fatura."
	EndIf

	If lRet
		SetReda2( nRadioGrp, cOpera, cEscrit, cFatura )
		MsgInfo(STR0127) // "Operação concluída!"
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SetReda2
Seta redacao da pre-fatura

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SetReda2( nRadioGrp, cOpera, cEscrit, cFatura )
Local oModel      := FWModelActive()
Local aArea       := GetArea()
Local aAreaNX1    := NX1->( GetArea() )
Local aSaveLines  := FwSaveRows(  )
Local nI, nJ, nK
Local oModelNX1, oModelNUE, oModelNX8
Local nLnNX8_OLD, nLnNX1_OLD, nLnNUE_OLD

	oModelNX1 := oModel:GetModel('NX1DETAIL')
	oModelNX8 := oModel:GetModel('NX8DETAIL')
	Do Case
		Case nRadioGrp == 1 // Time sheet

			oModelNUE := oModel:GetModel('NUEDETAIL')
			nLnNX8_OLD := oModelNX8:GetLine()
			For nI := 1 To oModelNX8:GetQtdLine()
				oModelNX8:GoLine(nI)

				nLnNX1_OLD := oModelNX1:GetLine()
				For nJ := 1 To oModelNX1:GetQtdLine()

					cReda := ''
					oModelNX1:GoLine(nJ)
					nLnNUE_OLD := oModelNUE:GetLine()
					For nK := 1 To oModelNUE:GetQtdLine()
						oModelNUE:GoLine(nK)
						cReda += AllTrim(oModelNUE:GetValue('NUE_DESC')) + CRLF
					Next nK
					oModelNUE:GoLine(nLnNUE_OLD)
					JurSetValue(oModelNX1, 'NX1_REDAC',, cReda)

				Next nJ
				oModelNX1:GoLine(nLnNX1_OLD)

			Next nI
			oModelNX8:GoLine(nLnNX8_OLD)

		Case nRadioGrp == 2 // Fatura

			NXC->(dbSetOrder(1))
			nLnNX8_OLD := oModelNX8:GetLine()
			For nI := 1 To oModelNX8:GetQtdLine()
				oModelNX8:GoLine(nI)

				nLnNX1_OLD := oModelNX1:GetLine()
				For nJ := 1 To oModelNX1:GetQtdLine()
					oModelNX1:GoLine(nJ)
					//NXC_FILIAL+NXC_CESCR+NXC_CFATUR+NXC_CCLIEN+NXC_CLOJA+NXC_CCONTR+NXC_CCASO
					If NXC->(dbSeek(xFilial('NXC')+cEscrit+cFatura+oModelNX1:GetValue('NX1_CCLIEN')+oModelNX1:GetValue('NX1_CLOJA')+oModelNX8:GetValue('NX8_CCONTR')+oModelNX1:GetValue('NX1_CCASO')))
						JurSetValue(oModelNX1, 'NX1_REDAC',, NXC->NXC_REDAC)
					EndIf

				Next nJ
				oModelNX1:GoLine(nLnNX1_OLD)

			Next nI
			oModelNX8:GoLine(nLnNX8_OLD)

		Case nRadioGrp == 3 // Caso

			nLnNX8_OLD := oModelNX8:GetLine()
			For nI := 1 To oModelNX8:GetQtdLine()
				oModelNX8:GoLine(nI)

				nLnNX1_OLD := oModelNX1:GetLine()
				For nJ := 1 To oModelNX1:GetQtdLine()
					oModelNX1:GoLine(nJ)

					NVE->( dbSetOrder(1) )
					If NVE->( dbSeek( xFilial('NVE')+ oModelNX1:GetValue('NX1_CCLIEN') + oModelNX1:GetValue('NX1_CLOJA') + oModelNX1:GetValue('NX1_CCASO') ) )
						JurSetValue( oModelNX1, 'NX1_REDAC',, NVE->NVE_REDFAT )
					EndIf

				Next nJ
				oModelNX1:GoLine(nLnNX1_OLD)

			Next nI
			oModelNX8:GoLine(nLnNX8_OLD)

	EndCase

	FwRestRows( aSaveLines )

	RestArea( aAreaNX1 )
	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202REDA3
Redacao do Caso

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202REDA3( oView, cOpera, nLine )
Local aArea     := GetArea()
Local aAreaNX0  := NX0->( GetArea() )
Local cGetFat   := Space(TamSX3("NXA_COD")[1])
Local cMemoReda := ""
Local nRadioGrp := 0
Local oGetEscr
Local oGetFat
Local oMemoReda
Local oRadioGrp
Local oDlg
Local oModel    := oView:GetModel() //FWModelActive()
Local aSaveLn   := FwSaveRows()

Private cEscri  := Space(TamSX3("NXA_CESCR")[1])

	oModel:GetModel('NX1DETAIL'):GoLine(nLine)

	Define MsDialog oDlg Title STR0033 FROM 233, 194 To 603, 747 Pixel //"Redação"

	@ 002, 002 To 045, 095 Label STR0072 Pixel Of oDlg //" Origem da Redação "
	@ 012, 005 Radio oRadioGrp Var nRadioGrp Items STR0073, STR0074, STR0075 3D Size 100, 010 Pixel Of oDlg //"Descrição dos Time Sheets"###"Fatura"###"Caso"
	oRadioGrp:bChange := { || cEscri := Space(TamSX3("NXA_CESCR")[1]), ;
								cGetFat := Space(TamSX3("NXA_COD")[1]), ;
								IIf( nRadioGrp <> 2, ( oGetEscr:Disable(), oGetFat:Disable() ), ( oGetEscr:Enable(), oGetFat:Enable() ) ), ;
								cMemoReda := SetReda3( nRadioGrp, cOpera, cEscri, cGetFat ), ;
								oGetEscr:Refresh(), ;
								oGetFat:Refresh(), ;
								oMemoReda:Refresh(), ;
								oGetFat:Refresh() }

	@ 015, 097 Say STR0076 Size 030, 008 Pixel Of oDlg //"Escritório"
	@ 025, 097 MsGet oGetEscr   Var cEscri Valid ExistCPO("NS7", cEscri) F3 "NS7" Size 060, 009 Pixel Of oDlg HasButton
	oGetEscr:Disable()

	@ 015, 160 Say STR0074     Size 018, 008 Pixel Of oDlg //"Fatura"
	@ 025, 160 MsGet oGetFat    Var cGetFat Valid ExistCPO('NXA', cEscri + cGetFat) F3 'NXA1' Size 060, 009 Pixel Of oDlg HasButton
	oGetFat:bChange := {|| IIf( nRadioGrp == 2, cMemoReda := SetReda3( nRadioGrp, cOpera, cEscri, cGetFat ), ), oMemoReda:Refresh()}
	oGetFat:bWhen   := {|| !Empty(cEscri)}
	oGetFat:bF3     := {|| JbF3LookUp("NXA1", oGetFat, @cGetFat), Eval(oGetFat:bChange)}
	oGetFat:Disable()

	@ 047, 004 Say STR0033    Size 032, 008 Pixel Of oDlg //"Redação"
	@ 057, 002 Get oMemoReda    Var  cMemoReda Memo Size 271, 125 Pixel Of oDlg

	@ 007, 235 Button STR0077  Size 037, 012 Pixel Of oDlg  Action ( JurSetValue( oModel, 'NX1DETAIL', 'NX1_REDAC', cMemoReda ), oDlg:End() ) //"Ok"
	@ 025, 235 Button STR0024  Size 037, 012 Pixel Of oDlg  Action oDlg:End() //"Cancelar"

	Activate MsDialog oDlg Centered

	FwRestRows( aSaveLn )
	oView:Refresh()
	RestArea( aAreaNX0 )
	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetReda3
Seta redacao do caso

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SetReda3( nRadioGrp, cOpera, cEscrit, cFatura )
Local aArea       := GetArea()
Local aAreaNX1    := NX1->(GetArea())
Local aAreaNXC    := NXC->(GetArea())
Local cReda       := ''
Local cRet        := ''
Local oModel      := FWModelActive()
Local oModelNX1
Local oModelNUE
Local oModelNX8
Local nSavLineNX1 := oModel:GetModel('NX1DETAIL'):GetLine()
Local nSavLineNUE := oModel:GetModel('NUEDETAIL'):GetLine()
Local nI

	Do Case
		Case nRadioGrp == 1 // Time sheet

			oModelNUE := oModel:GetModel('NUEDETAIL')
			cReda     := ''
			For nI := 1 To oModelNUE:GetQtdLine()

				oModelNUE:GoLine(nI)
				cReda += AllTrim(oModelNUE:GetValue('NUE_DESC')) + CRLF

			Next
			cRet := cReda

		Case nRadioGrp == 2 // Fatura

			oModelNX1 := oModel:GetModel('NX1DETAIL')
			oModelNX8 := oModel:GetModel('NX8DETAIL')

			NXC->(dbSetOrder(1))
			If NXC->(dbSeek(xFilial('NXC') + cEscrit + cFatura + oModelNX1:GetValue('NX1_CCLIEN') + oModelNX1:GetValue('NX1_CLOJA') + oModelNX8:GetValue('NX8_CCONTR') + oModelNX1:GetValue('NX1_CCASO')))
				cRet += NXC->NXC_REDAC + CRLF
			EndIf

		Case nRadioGrp == 3 // Caso

			oModelNX1 := oModel:GetModel('NX1DETAIL')

			NVE->(dbSetOrder(1))
			If NVE->( dbSeek(xFilial('NVE') + oModelNX1:GetValue('NX1_CCLIEN') + oModelNX1:GetValue('NX1_CLOJA') + oModelNX1:GetValue('NX1_CCASO')) )
				cRet := NVE->NVE_REDFAT
			EndIf

	EndCase

	oModel:GetModel( 'NX1DETAIL' ):GoLine( nSavLineNX1 )
	oModel:GetModel( 'NUEDETAIL' ):GoLine( nSavLineNUE )

	RestArea(aAreaNX1)
	RestArea(aAreaNXC)
	RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurSetValue
Faz setvalue de um campo com exibicao de mensagem em caso de erro

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurSetValue( oModel, cRef1, cRef2, xConteudo, lWait)
Local lRet     := .T.
Local lMuda    := .F.

Default oModel := FWModelActive()
Default cRef1  := ''
Default cRef2  := ''
Default lWait  := .F.

If lRet .And. ValType( oModel ) <> 'O'
	lRet := .F.
EndIf

If lRet .And. Empty( cRef1 )
	lRet := .F.
EndIf

If lRet
	If oModel:ClassName() == 'FWFORMGRID' .And. !oModel:CanUpdateLine()
		oModel:SetNoUpdateLine(.F.)
		lMuda := .T.
	EndIf
EndIf

If Empty( cRef2 )
	If lWait
		FWMsgRun(, {|| lRet := oModel:SetValue( cRef1, xConteudo ) }, STR0147, STR0167) // #"Aguarde..." ##"Atualizando Lançamentos"
	Else
		lRet := oModel:SetValue( cRef1, xConteudo )
	EndIf
Else
	If lWait
		FWMsgRun(, {|| lRet := oModel:SetValue( cRef1, cRef2, xConteudo ) }, STR0147, STR0167) // #"Aguarde..." ##"Atualizando Lançamentos"
	Else
		lRet := oModel:SetValue( cRef1, cRef2, xConteudo )
	EndIf
EndIf

If lMuda
	oModel:SetNoUpdateLine(.T.)
EndIf

If !lRet

	If !(Substr(cRef1, 1, 3) == cInstanc)
		JurShowErro( oModel:GetModel():GetErrorMessage(), , , .F. )
	Else
		JurShowErro( oModel:GetModel():GetErrorMessage() )
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202REDA1
Copia da redacao

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA202REDA1(oview)
Local lRet        := .T.
Local oModel      := FWModelActive()
Local aArea       := GetArea()
Local aSaveLines  := FwSaveRows()
Local nI          := 0
Local nJ          := 0
Local oModelNX8   := Nil
Local oModelNX1   := Nil
Local nLnNX8_OLD  := 0
Local nLnNX1_OLD  := 0

	If oView:GetFolderActive("FOLDER_01", 2)[1] <> 1 // Somente na aba de Pré-fatura
		MsgInfo(STR0221) // "Esta ação é permitida somente na aba de Pré-Fatura!"
		lRet := .F.
	EndIf

	If lRet .And. ApMsgYesNo( STR0082 ) //"Confirma o copia da redação para os casos originais ?"

		oModelNX8 := oModel:GetModel( 'NX8DETAIL' )

		nLnNX8_OLD := oModelNX8:GetLine()
		For nI := 1 To oModelNX8:GetQtdLine()

			oModelNX8:GoLine( nI )
			oModelNX1 := oModel:GetModel( 'NX1DETAIL' )
			nLnNX1_OLD := oModelNX1:GetLine()
			For nJ := 1 To oModelNX1:GetQtdLine()

				oModelNX1:GoLine( nJ )
				NVE->( dbSetOrder( 1 ) )
				If NVE->( dbSeek( xFilial('NX1') + oModelNX1:GetValue('NX1_CCLIEN') + oModelNX1:GetValue('NX1_CLOJA') + oModelNX1:GetValue('NX1_CCASO') ) )
					RecLock('NVE', .F.)
					NVE->NVE_REDFAT := oModelNX1:GetValue('NX1_REDAC')
					NVE->(MsUnLock())
					//Grava na fila de sincronização a alteração
					J170GRAVA("NVE", xFilial("NVE") + NVE->NVE_CCLIEN + NVE->NVE_LCLIEN + NVE->NVE_NUMCAS, "4")
					NVE->(DbSkip())
					ApMsgInfo(STR0141) // 'Cópia efetuada!'
				EndIf

			Next nJ
			oModelNX1:GoLine(nLnNX1_OLD)

		Next nI
		oModelNX8:GoLine(nLnNX8_OLD)

		FwRestRows( aSaveLines )
		RestArea( aArea )

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202RET
Retira as amarracoes das tabelas com as pre-faturas

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA202RET( oModel )
Local aArea       := GetArea()
Local lRetNX1     := .F.
Local lRetNX8     := .F.
Local nI          := 0
Local nJ          := 0
Local oModelNX8   := Nil
Local oModelNX1   := Nil
Local oModelNT1   := Nil
Local oModelNUE   := Nil
Local oModelNVY   := Nil
Local oModelNV4   := Nil
Local oModelNX2   := Nil
Local nLineNX8    := 0
Local nLineNX1    := 0

oModelNX8 := oModel:GetModel( 'NX8DETAIL' )
oModelNX1 := oModel:GetModel( 'NX1DETAIL' )
oModelNT1 := oModel:GetModel( 'NT1DETAIL' )

oModelNUE := oModel:GetModel( 'NUEDETAIL' )
oModelNVY := oModel:GetModel( 'NVYDETAIL' )
oModelNV4 := oModel:GetModel( 'NV4DETAIL' )
oModelNX2 := oModel:GetModel( 'NX2DETAIL' )

nLineNX8  := oModelNX8:GetLine()
For nI := 1 To oModelNX8:GetQtdLine()

	oModelNX8:GoLine( nI )

	lRetNX8 := oModelNX8:GetValue( 'NX8_TKRET' )

	If lRetNX8
		JA202RETAX( oModelNX1, 'NX1_TKRET' )
		JA202RETAX( oModelNT1, 'NT1_TKRET' )
	EndIf
	nLineNX1 := oModelNX1:GetLine()
	For nJ := 1 To oModelNX1:GetQtdLine()

		oModelNX1:GoLine( nJ )

		lRetNX1 := oModelNX1:GetValue( 'NX1_TKRET' )

		If lRetNX1
			JA202RETAX( oModelNV4, 'NV4_TKRET' )
			JA202RETAX( oModelNUE, 'NUE_TKRET' )
			JA202RETAX( oModelNVY, 'NVY_TKRET' )
			JA202RETAX( oModelNX2, 'NX2_TKRET' )
		EndIf

	Next
	oModelNX1:GoLine(nLineNX1)
Next

oModelNX8:GoLine(nLineNX8)

RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202RETAX
Marca todas as linhas do grid para serem retiradas

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA202RETAX( oModel, cCampo )
Local aDados    := {}
Local nI        := 0
Local nSavLine  := oModel:GetLine()

If oModel:GetQtdLine() == 1
	oModel:GoLine( 1 )
	aDados := oModel:GetData()
	If !oModel:IsUpdated() .And. aDados[1][MODEL_GRID_ID] == 0
		Return Nil
	EndIf
EndIf

For nI := 1 To oModel:GetQtdLine()
	oModel:GoLine( nI )

	If oModel:CanUpdateLine()
		JurSetValue( oModel, cCampo,, .T. )
	EndIf
Next

oModel:GoLine( nSavLine )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202LIB
Rotina para remover os lançamentos que serão desvinculados da pré-fatura
E Atualizar os Lançamentos que originou as despesas conforme a Despesa

@author TOTVS
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA202LIB(cNumPreFt, oModel, IsCancPre)
Local lRet        := .T.
Local aRetLibMo   :=  {{}, {}}
Local aValores    := { {}, {}, {}, {}, {}, {}, {}, {} } // NVV, NX8, NT1, NX1, NUE, NVY, NV4, NX2
Local aTempFin    := {} // Listas de Lançamentos que originou a despesas para atualização

Default oModel    := Nil
Default IsCancPre := .F.

	If Empty(oModel)
		aValores  := J202LibMe(cNumPreFt)
	Else
		aRetLibMo := J202LibMo(oModel)
		aValores  := aRetLibMo[1]
		aTempFin  := aRetLibMo[2]
	EndIf

	If lRet := !Empty(aValores)
		JA202LIB2(cNumPreFt, aValores, IsCancPre)
	EndIf

	If !Empty(aTempFin)
		J202UpLanc(aTempFin) // Atualiza os lançamentos que originaram as despesas.
	EndIf

	// Cancela a Pré-Fatura quando retirar o último lançamento
	If !IsCancPre .And. !Empty(oModel) .And. JurLancPre(cNumPreFt) == 0 .And. oModel:GetValue("NX0MASTER", "NX0_VLFATH") == 0
		oModel:DeActivate()
		nOperacao := MODEL_OPERATION_VIEW // Variável Private
		oModel:SetOperation(nOperacao)
		oModel:Activate()
		lCancPre := .T. 
		JA202RET( oModel )
	EndIf 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202LibMe
Rotina para remover os lançamentos que serão desvinculados da pré-fatura
E Atualizar os Lançamentos que originou as despesas conforme a Despesa

@author TOTVS
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202LibMe(cNumPreFt)
Local aArea := GetArea()
Local aRet  := { {}, {}, {}, {}, {}, {}, {}, {} } // NVV, NX8, NT1, NX1, NUE, NVY, NV4, NX2

	aRet[TB_NVV] := GetRecSeek(cNumPreFt, "NVV") // Fatura Adicional
//	aRet[TB_NX8] := GetRecSeek(cNumPreFt, "NX8") // Contrato
	aRet[TB_NT1] := GetRecSeek(cNumPreFt, "NT1") // Fixo
//	aRet[TB_NX1] := GetRecSeek(cNumPreFt, "NX1") // Caso
	aRet[TB_NUE] := GetRecSeek(cNumPreFt, "NUE", {"NUE_CGRPCL","NUE_CCLIEN","NUE_CLOJA","NUE_CCASO","NUE_CPREFT"}) // Time-Sheet
	aRet[TB_NVY] := GetRecSeek(cNumPreFt, "NVY", {"NVY_CGRUPO","NVY_CCLIEN","NVY_CLOJA","NVY_CCASO","NVY_CPREFT"}) // Despesa
	aRet[TB_NV4] := GetRecSeek(cNumPreFt, "NV4", {"NV4_CGRUPO","NV4_CCLIEN","NV4_CLOJA","NV4_CCASO","NV4_CPREFT"}) // Tabelado
//	aRet[TB_NX2] := GetRecSeek(cNumPreFt, "NX2") // Participante

	RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202LibMo
Rotina para remover os lançamentos que serão desvinculados da pré-fatura
E Atualizar os Lançamentos que originou as despesas conforme a Despesa

@author TOTVS
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202LibMo(oModel)
Local aArea     := GetArea()
Local aRet      := { {}, {}, {}, {}, {}, {}, {}, {} } // NVV, NX8, NT1, NX1, NUE, NVY, NV4, NX2
Local aSaveRows := FwSaveRows()
Local oModelNX8 := oModel:GetModel("NX8DETAIL")   // Contrato
Local oModelNX1 := oModel:GetModel("NX1DETAIL")   // Caso

Local oModelNVV := oModel:GetModel("NVVDETAIL")   // Fatura Adicional
Local oModelNT1 := oModel:GetModel("NT1DETAIL")   // Fixo
Local oModelNUE := oModel:GetModel("NUEDETAIL")   // TS
Local oModelNVY := oModel:GetModel("NVYDETAIL")   // Despesa
Local oModelNV4 := oModel:GetModel("NV4DETAIL")   // Tabelado
Local oModelNX2 := oModel:GetModel("NX2DETAIL")   // Participante
Local lJurXFin  := SuperGetMv("MV_JURXFIN",, .F.) // Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico

Local aTmp       := {}
Local aTmpNX1    := {}
Local aTmpNUE    := {}
Local aTmpNVY    := {}
Local aTmpNV4    := {}
Local nQtdNX8    := 0
Local nQtdNX1    := 0
Local nI         := 0
Local nY         := 0
Local nLnNX8_OLD := 0
Local nLnNX1_OLD := 0
Local lRemovNX1  := .F.
Local aTempFin   := {}
Local lRemovLim  := .F.
Local lIsRest    := IIF(FindFunction("JurIsRest"), JurIsRest(), .F.)

	aTmp         := GetRecModel(aRet[TB_NVV], oModelNVV, "NVV_TKRET") // Fatura Adicional
	aRet[TB_NVV] := aTmp[1]
	lRemovNX1    := !lIsRest .And. oModelNVV:isempty() //para efeito de rateio, só remove o caso se tambem não houver fatura adicional

	nLnNX8_OLD := oModelNX8:GetLine()
	nQtdNX8 := oModelNX8:Length()
	For nI := 1 To nQtdNX8
		oModelNX8:GoLine(nI)

		aTmp         := GetRecModel(aRet[TB_NT1], oModelNT1, "NT1_TKRET") // Fixo
		aRet[TB_NT1] := aTmp[1]
		aTempNT1     := aTmp[2]
		lRemovNX1    := lRemovNX1 .And. (oModelNT1:IsEmpty() .Or. Len(aTempNT1) == oModelNT1:Length(.T.))  //para efeito de rateio, só remove o caso se não houver Fixo

		aTmp      := GetRecModel(aRet[TB_NX1], oModelNX1, "NX1_TKRET" ) //Caso
		aTmpNX1   := aTmp[2]

		nLnNX1_OLD := oModelNX1:GetLine()
		nQtdNX1 := oModelNX1:Length()
		For nY := 1 To nQtdNX1

			aTmpNUE := {}
			aTmpNVY := {}
			aTmpNV4 := {}

			oModelNX1:GoLine(nY)
			aTmp         := GetRecModel(aRet[TB_NUE], oModelNUE, "NUE_TKRET", {"NUE_CGRPCL", "NUE_CCLIEN", "NUE_CLOJA", "NUE_CCASO", "NUE_CPREFT"}) // Time-Sheet
			aRet[TB_NUE] := aTmp[1]
			aTmpNUE      := aTmp[2]

			aTmp         := GetRecModel(aRet[TB_NVY], oModelNVY, "NVY_TKRET", {"NVY_CGRUPO", "NVY_CCLIEN", "NVY_CLOJA", "NVY_CCASO", "NVY_CPREFT"}, {{'NVY_COBRAR','2'}}, lJurXFin, aTempFin) // Despesa
			aRet[TB_NVY] := aTmp[1]
			aTmpNVY      := aTmp[2]
			aTempFin     := aTmp[3]

			aTmp         := GetRecModel(aRet[TB_NV4], oModelNV4, "NV4_TKRET", {"NV4_CGRUPO", "NV4_CCLIEN", "NV4_CLOJA", "NV4_CCASO", "NV4_CPREFT"}) // Tabelado
			aRet[TB_NV4] := aTmp[1]
			aTmpNV4      := aTmp[2]

			aTmp         := GetRecModel(aRet[TB_NX2], oModelNX2, "NX2_TKRET") // Participante
			aRet[TB_NX2] := aTmp[1]

			lRemovLim    := !lIsRest .And. (oModelNUE:Isempty() .And. oModelNV4:Isempty()) .And. (oModelNX1:GetValue('NX1_VHON') == 0)

			If lRemovNX1 .And. lAcumula .And. !oModelNX1:IsDeleted() .And. !oModelNX1:IsEmpty() .And. oModelNX1:GetValue("NX1_TKRET")
				aAdd( aRet[TB_NX1], oModelNX1:GetDataId() )
			Else  //Se retira tudo que está vinculado no caso.
				If lRemovNX1 .And. (Len(aTmpNUE) == oModelNUE:Length(.T.) .Or. oModelNUE:Isempty()) .And. ;
					(len(aTmpNVY) == oModelNVY:Length(.T.) .Or. oModelNVY:Isempty()) .And. ;
					(len(aTmpNV4) == oModelNV4:Length(.T.) .Or. oModelNV4:Isempty()) .And. lRemovLim
					aAdd( aRet[TB_NX1], oModelNX1:GetDataId() )
					aAdd( aTmpNX1, oModelNX1:GetDataId() )
				EndIf

			EndIf
		Next
		oModelNX1:GoLine(nLnNX1_OLD)

		If lAcumula .And. !oModelNX8:IsDeleted() .And. !oModelNX8:IsEmpty() .And. oModelNX8:GetValue("NX8_TKRET")
			aAdd( aRet[TB_NX8], oModelNX8:GetDataId() )
		Else  //Se retira tudo que está vinculado no contrato.
			If (Len(aTempNT1) == oModelNT1:Length(.T.) .Or. oModelNT1:Isempty()) .And. ;
				(Len(aTmpNX1) == oModelNX1:Length(.T.) .Or. oModelNX1:Isempty())
				aAdd( aRet[TB_NX8], oModelNX8:GetDataId() )
			EndIf

		EndIf

	Next
	oModelNX8:GoLine(nLnNX8_OLD)

	FwRestRows(aSaveRows)
	RestArea(aArea)

Return {aRet, aTempFin}

//-------------------------------------------------------------------
/*/{Protheus.doc} GetRecModel()
Rotina para montar o array para remover os lançamentos que serão desvinculados da pré-fatura por modelo
Melhoria de performace da pré-fatuta (substituição da macro execução e goline )
E
Monta array com as despesas alteradas para atualizar os lançamentos financeiros viculados

@Param  aOld       Array com resultado da busca anterior
@Param  oModelX    Modelo de grid a ser percorrido Ex: oModelNUE
@Param  cTkRet     Campo de marca do modelo Ex: NUE_TKRET
@Param  aCpos      Array de Campos que devem retornar do registro marcado o Ex: "['NUE_CCASO','NUE_CPREFT']"
@Param  aCondicao  Array com os campos e as condiçãos válidas para remoção [['NVY_COBRAR','2']]
@Param  lJurXFin   Lógico para identificar quando montar o array com as despesas para atualizar os lançamentos financeiros vinculados

@author Luciano Pereira dos Santos
@since 27/01/17
@version 2.0
/*/
//-------------------------------------------------------------------
Static Function GetRecModel(aOld, oModelX, cTkRet, aCpos, aCondicao, lJurXFin, aTempFin)
Local aRet        := {}
Local aLNChanged  := oModelX:GetLinesChanged()
Local nQtd        := 0
Local nI          := 0
Local nY          := 0
Local nMax        := 0
Local aRetCas     := {}
Local lCondicao   := .F.
Local nPos        := 0
Local cCodSeek    := ""
Local cDescri     := ""
Local cCobrar     := ""
Local cTabela     := ""

Default aOld      := {}
Default aCpos     := {}
Default aCondicao := {}
Default lJurXFin  := .F.
Default aTempFin  := {}

aRet    := aOld
aRetCas := {}

nQtd := Len(aLNChanged)
If !oModelX:IsEmpty()

	For nI := 1 To nQtd
		nPos := aLNChanged[nI]

		For nY := 1 To Len(aCondicao)
			lCondicao := lCondicao .Or. oModelX:GetValue(aCondicao[nY][1], nPos) == aCondicao[nY][2]
		Next nY

		If (!oModelX:IsDeleted(nPos) .And. oModelX:GetValue(cTkRet,nPos) .And. lAcumula) .Or. lCondicao
			If Empty(aCpos)
				aAdd(aRet,    oModelX:GetDataId(nPos) )
				aAdd(aRetCas, oModelX:GetDataId(nPos) )
			Else
				aAdd(aRet,    {oModelX:GetDataId(nPos)} )
				aAdd(aRetCas, {oModelX:GetDataId(nPos)} )
				nMax := Len(aRet)
				For nY := 1 To Len(aCpos)
					aAdd(aRet[nMax], oModelX:GetValue(aCpos[nY], nPos) )
					aAdd(aRetCas[Len(aRetCas)], oModelX:GetValue(aCpos[nY], nPos) )
				Next nY
			EndIf
		EndIf
		lCondicao := .F.

		If lJurXFin .And. NVY->(ColumnPos("NVY_CPAGTO")) > 0 //Proteção
			If !oModelX:IsDeleted(nPos) .And. (oModelX:IsFieldUpdated('NVY_DESCRI', nPos) .Or. oModelX:IsFieldUpdated('NVY_COBRAR', nPos))
				If !Empty(oModelX:GetValue("NVY_CLANC", nPos))
					cTabela  := "OHB"
					cCodSeek := oModelX:GetValue("NVY_CLANC", nPos)
				ElseIf !Empty(oModelX:GetValue("NVY_CPAGTO", nPos)) .And. !Empty(oModelX:GetValue("NVY_ITDES", nPos))
					cTabela  := "OHF"
					cCodSeek := oModelX:GetValue("NVY_COD", nPos)
				ElseIf !Empty(oModelX:GetValue("NVY_CPAGTO", nPos)) .And. !Empty(oModelX:GetValue("NVY_ITDPGT", nPos))
					cTabela  := "OHG"
					cCodSeek := oModelX:GetValue("NVY_COD", nPos)
				EndIf

				cDescri  := oModelX:GetValue("NVY_DESCRI", nPos)
				cCobrar  := oModelX:GetValue("NVY_COBRAR", nPos)
				aAdd(aTempFin, {cTabela, cCodSeek, cDescri, cCobrar})
			EndIf
		EndIf
	Next nI
EndIf

Return {aRet, aRetCas, aTempFin}

//-------------------------------------------------------------------
/*/{Protheus.doc} GetRecModel()
Rotina para montar o array para remover os lançamentos que serão desvinculados da pré-fatura por query
Melhoria de performace da pré-fatura (substituição do SELECT * FROM )

@Param  cNumPreFt  Numero da pré-fatura
@Param  cTabela    Tabela do modelo Ex: "NUE"
@Param  aCpos      Array de Campos que devem retornar do registro marcado o Ex: "['NUE_CCASO','NUE_CPREFT']"

@author Luciano Pereira dos Santos
@since 27/01/17
@version 2.0
/*/
//-------------------------------------------------------------------
Static Function GetRecSeek(cNumPreFt, cTabela, aCpos)
Local aCpoQyr := {}
Local aRet    := {}
Local cQry    := ""
Local nI      := 0

Default aCpos := {}

	Aadd(aCpoQyr, "R_E_C_N_O_")

	cQry := " SELECT R_E_C_N_O_ "
	For nI := 1 To Len(aCpos)
		cQry += ", " + aCpos[nI]
		Aadd(aCpoQyr, aCpos[nI])
	Next
	cQry +=  " FROM " + RetSqlName(cTabela) + " "
	cQry += " WHERE " + cTabela + "_FILIAL = '" + xFilial(cTabela) + "' "
	cQry +=   " AND " + cTabela + "_CPREFT = '" + cNumPreFt + "' "
	cQry +=   " AND D_E_L_E_T_ = ' ' "

	aSQL := JurSQL(cQry, aCpoQyr)

	For nI := 1 To Len(aSQL)
		If Len(aSQL[nI]) == 1
			aAdd(aRet, aSQL[nI][1] )
		Else
			aRet := aSQL
			Exit
		EndIf
	Next

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202LIB2
Desvincula/Transfere os registros associados da pré-fatura

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA202LIB2(cNumPreFt, aValores, IsRetira)
Local aArea      := GetArea()
Local aAreaNX8   := NX8->( GetArea() )
Local aAreaNX1   := NX1->( GetArea() )
Local aAreaNX2   := NX2->( GetArea() )
Local aAreaNVY   := NVY->( GetArea() )
Local aAreaNUE   := NUE->( GetArea() )
Local aAreaNV4   := NV4->( GetArea() )
Local aAreaNXG   := NXG->( GetArea() )
Local aAreaNT1   := NT1->( GetArea() )
Local aAreaNVV   := NVV->( GetArea() )
Local aAreaNWD   := NWD->( GetArea() )
Local lChkVerLD  := FindFunction('J300ChkVer') .AND. J300ChkVer("1.0.0")
Local nContr    := 0
Local nCaso     := 0
Local nPart     := 0
Local nTSheet   := 0
Local nDesp     := 0
Local nLantab   := 0
Local nFatAd    := 0
Local nFixo     := 0
Local nQtdNVV   := 0
Local nQtdNX8   := 0
Local nQtdNT1   := 0
Local nQtdNX1   := 0
Local nQtdNUE   := 0
Local nQtdNVY   := 0
Local nQtdNV4   := 0
Local nQtdNX2   := 0
Local lAltHr    := NUE->(ColumnPos('NUE_ALTHR')) > 0

Default IsRetira := .F.

lRevisLD := (SuperGetMV("MV_JREVILD", .F., '2') == '1' ) //Controla a integracao da revisão de pré-fatura com o Legal Desk

//Desvincula as parcelas de fatura adicional
nQtdNVV := Len(aValores[TB_NVV])
NWD->(DbSetOrder(1)) // NWD_FILIAL+NWD_CFTADC+NWD_SITUAC+NWD_PRECNF+NWD_CFATUR+NWD_CESCR+NWD_CWO
NXG->(DbSetOrder(4)) //NXG_FILIAL+NXG_CFATAD

For nFatAd := 1 To nQtdNVV

	NVV->( dbGoTo(aValores[TB_NVV][nFatAd]) )
	RecLock('NVV', .F.)
	NVV->NVV_CPREFT := ""
	NVV->(MsUnLock())
	NVV->(DbCommit())

	If NWD->(DbSeek( xFilial("NWD") + NVV->NVV_COD + "1" + cNumPreFt ) )
		RecLock('NWD', .F.)
		NWD->NWD_CANC := "1"
		NWD->(MsUnLock())
		NWD->(DbCommit())
	EndIf

	If NXG->( DbSeek( xFilial('NXG') + NVV->NVV_COD ) )
		While !NXG->(EOF()) .And. NXG->NXG_CFATAD == NVV->NVV_COD
			RecLock('NXG', .F.)
			NXG->NXG_CPREFT := ""
			NXG->(MsUnLock())
			NXG->(DbCommit())
			NXG->(DbSkip())
		EndDo
	EndIf
	NVV->(DbSkip())
Next nFatAd

//Contratos
nQtdNX8 := Len(aValores[TB_NX8])
For nContr := 1 To nQtdNX8

	//Apaga o contrato - os vínculos já foram marcados
	NX8->( dbGoTo(aValores[TB_NX8][nContr]) )
	If !NX8->(Eof())
		RecLock( 'NX8', .F.)
		NX8->( dbDelete() )
		NX8->(MsUnLock())
		NX8->(DbCommit())
	EndIf

Next nContr

//Desvincula as parcelas de FIXO
nQtdNT1 := Len(aValores[TB_NT1])
NWE->( dbSetOrder( 1 ) ) //NWE_FILIAL+NWE_CFIXO+NWE_SITUAC+NWE_PRECNF+NWE_CFATUR+NWE_CESCR+NWE_CWO

For nFixo := 1 To nQtdNT1

	NT1->( dbGoTo(aValores[TB_NT1][nFixo]) )
	RecLock('NT1', .F.)
	NT1->NT1_CPREFT := ""
	NT1->(MsUnLock())
	NT1->(DbCommit())

	//NWE_FILIAL+NWE_CFIXO+NWE_SITUAC+NWE_PRECNF+NWE_CFATUR+NWE_CESCR+NWE_CWO
	If NWE->(dbseek(xFilial('NWE') + NT1->NT1_SEQUEN + "1" + cNumPreFt))
		RecLock('NWE', .F.)
		NWE->NWE_CANC := "1"
		NWE->(MsUnLock())
		NWE->(DbCommit())
	EndIf
	//Grava na fila de sincronização
	If !lRevisLD
		J170GRAVA("NT0", xFilial("NT0") + NT1->NT1_CCONTR, "4")
	EndIf
	NT1->(DbSkip())
Next nFixo

//Casos
nQtdNX1 := Len(aValores[TB_NX1])
For nCaso := 1 To nQtdNX1

	//Apaga o caso - os vínculos já foram marcados
	NX1->( dbGoTo(aValores[TB_NX1][nCaso]) )
	If !NX1->(Eof())
		If FindFunction("J201EDelRv")
			J201EDelRv(NX1->NX1_CPREFT, NX1->NX1_CCONTR, NX1->NX1_CCLIEN, NX1->NX1_CLOJA, NX1->NX1_CCASO) // Remove vínculo de sócios/revisores
		EndIf
		RecLock('NX1', .F.)
		NX1->( dbDelete() )
		NX1->( MsUnLock() )
		NX1->(DbCommit())
	EndIf

Next nCaso

//Apaga os participantes - Os TSs deles já foram marcadas na validação
nQtdNX2 := Len(aValores[TB_NX2])
For nPart := 1 To nQtdNX2

	NX2->( dbGoTo(aValores[TB_NX2][nPart]) )
	RecLock('NX2', .F.)
	NX2->( dbDelete() )
	NX2->( MsUnLock() )
	NX2->(DbCommit())
Next nPart

//Retira os Time-Sheets
nQtdNUE := Len(aValores[TB_NUE])
NW0->( dbSetOrder( 1 ) ) //NW0_FILIAL+NW0_CTS+NW0_SITUAC+NW0_PRECNF+NW0_CFATUR+NW0_CESCR+NW0_CWO

For nTSheet := 1 To nQtdNUE

	NUE->( dbGoTo( aValores[TB_NUE][nTSheet][_RECNO_] ) )
	RecLock('NUE', .F.)
	If IsRetira
		NUE->NUE_CPREFT := ""
		NUE->NUE_VALOR1 := 0
	Else
		If !(NUE->NUE_CPREFT = aValores[TB_NUE][nTSheet][PREFATURA]) // pré-fat
			NUE->NUE_CPREFT := aValores[TB_NUE][nTSheet][PREFATURA]
			If Empty(NUE->NUE_CPREFT)
				NUE->NUE_VALOR1 := 0
			EndIf
		EndIf
		If !(NUE->NUE_CGRPCL = aValores[TB_NUE][nTSheet][GRUPO]) // Grupo
			NUE->NUE_CGRPCL := aValores[TB_NUE][nTSheet][GRUPO]
		EndIf
		If !(NUE->NUE_CCLIEN = aValores[TB_NUE][nTSheet][CLIENTE]) // Cliente
			NUE->NUE_CCLIEN := aValores[TB_NUE][nTSheet][CLIENTE]
		EndIf
		If !(NUE->NUE_CLOJA = aValores[TB_NUE][nTSheet][LOJA]) // Loja
			NUE->NUE_CLOJA := aValores[TB_NUE][nTSheet][LOJA]
		EndIf
		If !(NUE->NUE_CCASO = aValores[TB_NUE][nTSheet][CASO]) // Caso
			NUE->NUE_CCASO := aValores[TB_NUE][nTSheet][CASO]
		EndIf
	EndIf

	NUE->NUE_CUSERA := JurUsuario(__CUSERID)
	NUE->NUE_ALTDT  := Date()
	If lAltHr
		NUE->NUE_ALTHR := Time()
	EndIf

	NUE->( MsUnLock() )
	NUE->(DbCommit())

	If NW0->( dbseek( xFilial('NW0') + NUE->NUE_COD + '1' + cNumPreFt) )
		RecLock('NW0', .F.)
		If !(NUE->NUE_CPREFT == cNumPreFt) .Or. IsRetira
			NW0->NW0_CANC := "1"
		Else
			NW0->NW0_CANC   := "2"
			NW0->NW0_CCLIEN := NUE->NUE_CCLIEN
			NW0->NW0_CLOJA  := NUE->NUE_CLOJA
			NW0->NW0_CCASO  := NUE->NUE_CCASO
			NW0->NW0_CPART1 := NUE->NUE_CPART1
			NW0->NW0_TEMPOL := NUE->NUE_TEMPOL
			NW0->NW0_TEMPOR := NUE->NUE_TEMPOR
			NW0->NW0_VALORH := NUE->NUE_VALORH
			NW0->NW0_CMOEDA := NUE->NUE_CMOEDA
			NW0->NW0_DATATS := NUE->NUE_DATATS
		EndIf
		NW0->(MsUnLock())
		NW0->(DbCommit())
	EndIf

Next nTSheet

//Retira as Despesas
nQtdNVY := Len(aValores[TB_NVY])
NVZ->( dbSetOrder( 1 ) ) //NVZ_FILIAL+NVZ_CDESP+NVZ_SITUAC+NVZ_PRECNF+NVZ_CFATUR+NVZ_CESCR+NVZ_CWO

For nDesp := 1 To nQtdNVY

	NVY->( dbGoTo( aValores[TB_NVY][nDesp][_RECNO_] ) )
	RecLock("NVY", .F.)
	NVY->NVY_CPREFT := ""
	NVY->(MsUnLock())
	NVY->(DbCommit())

	If NVZ->( dbseek( xFilial('NVZ') + NVY->NVY_COD + '1' + cNumPreFt) )
		RecLock('NVZ', .F.)
		If !(NVY->NVY_CPREFT == cNumPreFt) //.Or. IsRetira
			NVZ->NVZ_CANC := "1"
		EndIf
		NVZ->( MsUnLock() )
		NVZ->(DbCommit())
	EndIf

Next nDesp

//Retira os Tabelados - os TSs vinculados já devem ter sido marcados pela
nQtdNV4 := Len(aValores[TB_NV4])
NW4->( dbSetOrder(4) ) //NW4_FILIAL+NW4_CLTAB+NW4_SITUAC+NW4_PRECNF

For nLantab := 1 To nQtdNV4

	NV4->( dbGoTo( aValores[TB_NV4][nLantab][_RECNO_] ) )
	RecLock('NV4', .F.)
	If IsRetira
		NV4->NV4_CPREFT := ""
	Else
		If !(NV4->NV4_CPREFT = aValores[TB_NV4][nLantab][PREFATURA]) // PREFATURA
			NV4->NV4_CPREFT := aValores[TB_NV4][nLantab][PREFATURA]
		EndIf
		If !(NV4->NV4_CGRUPO = aValores[TB_NV4][nLantab][GRUPO]) // Grupo
			NV4->NV4_CGRUPO := aValores[TB_NV4][nLantab][GRUPO]
		EndIf
		If !(NV4->NV4_CCLIEN = aValores[TB_NV4][nLantab][CLIENTE]) // Cliente
			NV4->NV4_CCLIEN := aValores[TB_NV4][nLantab][CLIENTE]
		EndIf
		If !(NV4->NV4_CLOJA = aValores[TB_NV4][nLantab][LOJA]) // Loja
			NV4->NV4_CLOJA := aValores[TB_NV4][nLantab][LOJA]
		EndIf
		If !(NV4->NV4_CCASO = aValores[TB_NV4][nLantab][CASO]) // Caso
			NV4->NV4_CCASO := aValores[TB_NV4][nLantab][CASO]
		EndIf
	EndIf
	NV4->(MsUnLock())
	NV4->(DbCommit())

	If NW4->( dbseek( xFilial('NW4') + NV4->NV4_COD + '1' + cNumPreFt ) )
		RecLock('NW4', .F.)
		If !(NV4->NV4_CPREFT == cNumPreFt) .Or. IsRetira
			NW4->NW4_CANC := "1"
		Else
			NW4->NW4_CANC   := "2"
			NW4->NW4_CCLIEN := NV4->NV4_CCLIEN
			NW4->NW4_CLOJA  := NV4->NV4_CLOJA
			NW4->NW4_CCASO  := NV4->NV4_CCASO
			NW4->NW4_CPART1 := NV4->NV4_CPART
			NW4->NW4_DTCONC := NV4->NV4_DTCONC
			NW4->NW4_CMOEDH := NV4->NV4_CMOEH
			NW4->NW4_VALORH := NV4->NV4_VLHFAT
		EndIf
		NW4->(MsUnLock())
		NW4->(DbCommit())
	EndIf

Next nLantab

RestArea( aAreaNX8 )
RestArea( aAreaNX1 )
RestArea( aAreaNX2 )
RestArea( aAreaNVY )
RestArea( aAreaNUE )
RestArea( aAreaNV4 )
RestArea( aAreaNT1 )
RestArea( aAreaNXG )
RestArea( aAreaNVV )
RestArea( aAreaNWD )
RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202LOAD
Função para padronizar o ajuste dos lançamentos faturados (cancelar o vínculo)

@author David Fernandes
@since 15/02/12
@version 1.0
//-------------------------------------------------------------------------------------------------------------------
Estrutura do array de lançamentos
//[1] Alias_1  | [2] Indice_1 | [3] Chave_1        | [4] Model_1 | [5] aModelPOS      | [6] Alias_2  | [7] Indice_2 | [8] Chave_2                         | [9] W0?  |    [10] retirar   |
//"NUE"        | 1            | "  000000000001"   | oModel      |     {1, 2, 165  }  | "NW0"        |   1          | "  000000000001555556666"           |    .F.   |        .T.        |
//"NVY"        | 1            | "  23434"          | oModel      |     {2, 1,   1  }  | "NVZ"        |   1          | "  23434           1"               |    .F.   |        .T.        |
//"NV4"        | 2            | "  65732"          | oModel      |     {1, 4,   7  }  | "NW4"        |   2          | "  65732     12345     1"           |    .T.   |        .F.        |
//-------------------------------------------------------------------------------------------------------------------
/*/
//-------------------------------------------------------------------
Function JA202LFatu( aLancs )
Local lRet      := .F.
Local aArea     := GetArea()
Local nI        := 0
Local oModelXXX := nil

	For nI := 1 To Len(aLancs)

		If !(aLancs[nI][1] $ "NUE|NVY|NV4|NT1|NVV")     //TS/DP/TB/FX/FA
			Return .F.
		EndIf
		If !(aLancs[nI][6] $ "NW0|NVZ|NW4|NWE|NWD")     //TS/DP/TB/FX/FA
			Return .F.
		EndIf

		If Valtype(aLancs[ni][4]) == "O"
			// Se o lançamento estiver no model, sempre desvincular pelo model, caso contrário o FWCommit vincula novamente

			If IsJura202()
				oModelXXX := aLancs[ni][4]:GetModel("NX8DETAIL")
				oModelXXX:GoLine( aLancs[ni][5][1] )
				oModelXXX := aLancs[ni][4]:GetModel("NX1DETAIL")
				oModelXXX:GoLine( aLancs[ni][5][2] )
				oModelXXX := aLancs[ni][4]:GetModel(aLancs[ni][1]+"DETAIL")
				oModelXXX:GoLine( aLancs[ni][5][3] )
			Else
				Return .F.
			EndIf

			If aLancs[ni][9] .Or. aLancs[ni][10]
				If !JurLoadValue(aLancs[ni][4], aLancs[ni][1] + "DETAIL", aLancs[ni][1] + "_TKRET", .T. ) //Marca .T. para retirar na Libmo()
					Return .F.
				EndIf
				If !JurLoadValue(aLancs[ni][4], aLancs[ni][1] + "DETAIL", aLancs[ni][1] + "_SITUAC", If( aLancs[ni][9], "2", "1" ) )
					Return .F.
				EndIf
				If !JurLoadValue(aLancs[ni][4], aLancs[ni][1] + "DETAIL", aLancs[ni][1] + "_CPREFT", "" )
					Return .F.
				EndIf
			EndIf

		Else
			DbSelectArea( aLancs[ni][1] )
			(aLancs[ni][1])->( dbSetOrder( aLancs[ni][2] ) )
			If (aLancs[ni][1])->( DbSeek( xFilial(aLancs[ni][1]) + aLancs[ni][3] ) )
				Reclock( aLancs[ni][1], .F. )
				//(aLancs[ni][1])->&( aLancs[ni][1] + "_TKRET"  ) := .F.
				If aLancs[ni][9] .Or. aLancs[ni][10]
					(aLancs[ni][1])->&( aLancs[ni][1] + "_SITUAC" ) := If( aLancs[ni][9], "2", "1" )
					(aLancs[ni][1])->&( aLancs[ni][1] + "_CPREFT" ) := ""
				EndIf
				(aLancs[ni][1])->(MsUnlock())
				(aLancs[ni][1])->(DbCommit())
				(aLancs[ni][1])->(DbSkip())
				lRet := .T.
			Else
				Return .F.
			EndIf
		EndIf

		DbSelectArea( aLancs[ni][6] )
		(aLancs[ni][6])->( dbSetOrder( aLancs[ni][7] ) )
		If (aLancs[ni][6])->( DbSeek( aLancs[ni][8] ) )
			Reclock( aLancs[ni][6], .F. )
			(aLancs[ni][6])->&( aLancs[ni][6] + "_CANC" ) := "1"
			(aLancs[ni][6])->(MsUnlock())
			(aLancs[ni][6])->(DbCommit())
			(aLancs[ni][6])->(DbSkip())
			lRet := .T.
		Else
			Return .F.
		EndIf

	Next nI

	lAcumula := .T.

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202VAL
Processa as alterações dos valores dos Time-Sheets

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202Val(cCampo)
Local lRet       := .T.
Local aArea      := GetArea()
Local oModel     := If(oModelOld = Nil, FwModelActive(), oModelOld)
Local oModelNUE  := Nil
Local oModelNX0  := Nil
Local oModelNX1  := Nil
Local oModelNX2  := Nil
Local nValorTS   := 0
Local nValorHTS  := 0
Local aValor1TS  := {}
Local aVlPar1    := {}
Local cJURTS2    := SuperGetMV( 'MV_JURTS2',, 1 )    //Tipo de Apontamento
Local cJURTS3    := SuperGetMV( 'MV_JURTS3',, .F. )  //Pode fracionar
Local nJURTS1    := SuperGetMV( 'MV_JURTS1',, 10 )   //Minutos da UT
Local aRetJUR200 := {}

Local nTempR     := 0
Local nUtRSPart  := 0
Local nUtRCpart  := 0
Local nTempRTot  := 0
Local nValorMPre := 0
Local nValorMTab := 0
Local nValorHTot := 0
Local aValor1Tot := {}
Local nValor1Tot := 0
Local nUtTsNova  := 0
Local nUTNRNova  := 0

Local nI         := 0
Local nTipoOrig  := 0
Local cTempoNX2  := ''
Local aSaveLines := FwSaveRows( oModel )
Local nPos       := 0
Local nSomaTS    := 0
Local nSomaTS1   := 0
Local nQtdNUE    := 0

Local aValTS     := {}
Local nNVT       := 0 //Novo valor Total
Local nVAD       := 0 //Valor sendo adicionado/subtraido
Local nVSP       := 0 //Valor sem participacao direta do cliente
Local nVCP       := 0 //Valos com participacao direta do cliente
Local nVOS       := 0 //Valor do caso (com participacao)
Local nVOI       := 0 //Valor do caso (sem participacao)
Local nADC       := 0 //Valor adicional calculado por caso
Local nNVC       := 0 //Novo valor por caso
Local nRES       := 0 //Residuo de arredondamento
Local cClient    := ""  // cliente da validação NX0_ALTPER $ '2,3'
Local cLoja      := ""  // loja da validaçao NX0_ALTPER $ '2,3'
Local cCaso      := ""  // Caso da validaçao NX0_ALTPER $ '2,3'
Local cContr     := ""  // Contrato da validaçao NX0_ALTPER $ '2,3'

Local oStrucNX2  := Nil
Local oStrucNUE  := Nil
Local nDifVlr    := 0
Local cAMRec     := SubSTR(SuperGetMV( "MV_JRECTS",, "0000-00" ), 0, 4) + SubSTR(SuperGetMV( "MV_JRECTS",, "0000-00" ), 6, 2)
Local nPosAlt    := 0

Local cX2Cli
Local cX2Loja
Local cX2Caso
Local cX2Part
Local nX2Valor
Local cX2CodSeq
Local cX2CLTab
Local cX2Categ
Local cX2MOTBH
Local cNX0Cod
Local cNX0DTEMI
Local nLnNUE_OLD
Local lIsRest    := Iif(FindFunction("JurIsRest"), JurIsRest(), .F.)
Local lIsJURA202 := oModel:GetId() == "JURA202"

If !lIsJURA202 .Or. (lIsRest .And. lIsJURA202) .Or. IsInCallStack("JA145ALT") .Or. IsInCallStack("JA144ETL")
	Return lRet
EndIf

oModelNUE := oModel:GetModel("NUEDETAIL")
oModelNX0 := oModel:GetModel("NX0MASTER")
oModelNX1 := oModel:GetModel("NX1DETAIL")
oModelNX2 := oModel:GetModel("NX2DETAIL")

cNX0Cod   := oModelNX0:GetValue( "NX0_COD" )
cNX0DTEMI := oModelNX0:GetValue("NX0_DTEMI")

If Substr(cCampo, 1, 3) == 'NUE'

	If ValType(oModelNUE:GetValue( cCampo )) == "N"
		If oModelNUE:GetValue( cCampo ) < 0
			lRet := JurMsgErro(STR0169) // "Informe um valor positivo!"
			Return lRet
		EndIf
	EndIf

	//Valida a alteracao em um TS removido ou dividido pelas alteracoes de periodo.
	If Empty(oModelNUE:GetValue("NUE_CPREFT")) .Or. J202VldDiv("NUE_CODPAI", oModelNUE:GetValue("NUE_COD"))
		lRet := JurMsgErro(STR0170) //"Existem alterações de valor pendentes, para efetuar novas alterações confirme ou cancele as anteriores!"
		Return lRet
	EndIf

	nValorTS   := oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALOR])
	nValorHTS  := oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALORH])

	//As conversões dos tempos já foram feitas na JURA144V1()
	If cCampo == 'NUE_VALOR1'
		If nValorHTS == 0 .Or. nJURTS1 == 0
			nUTTSNova   :=  0
		Else

			aValor1TS := JA201FConv(oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CMOEDA]), oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CMOED1] ),;
			                        oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALOR1]), "2", cNX0DTEMI, , cNX0Cod, )

		 	nUTTSNova := (aValor1TS[1] / oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALORH] )) * (60/nJURTS1)
			nDifVlr   := oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALOR1] ) - JA201FConv(oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CMOEDA] ), oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CMOED1] ),;
			                                                                                    oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALOR] ), "2", cNX0DTEMI, , cNX0Cod,  )[1]
		EndIf

		If !cJURTS3   //se não pode fracionar
			nUTTSNova := Round( nUTTSNova, 0 )
		EndIf

		oStrucNUE  := oModelNUE:GetStruct()

	 	If !(cJURTS2 == 1)
			oStrucNUE:SetProperty( 'NUE_UTR', MODEL_FIELD_NOUPD, .F. )
			oStrucNUE:SetProperty( 'NUE_UTR', MODEL_FIELD_WHEN, {|| .T.} )
		EndIf
		//XYZ - passa qdo é ULTIMO
		lRet := lRet .And. JurSetValue(oModelNUE, 'NUE_UTR',, Round(nUTTSNova, TamSX3('NUE_UTR')[2]) ) //Já deve converter os tempos na JURA144V1()

		If !(cJURTS2 == 1)
			oStrucNUE:SetProperty( 'NUE_UTR', MODEL_FIELD_NOUPD, .T. )
			oStrucNUE:SetProperty( 'NUE_UTR', MODEL_FIELD_WHEN, {|| .F.} )
		EndIf

		If !lRet
			Return lRet
		EndIf

	ElseIf cCampo == "NUE_CPART2"

		// Somente recalcula se  estiver após o parâmetro
		If oModelNUE:GetValue("NUE_ANOMES") >= cAMRec
			aRetJUR200    := JURA200( AllTrim( oModelNUE:GetValue("NUE_COD") ), AllTrim( oModelNUE:GetValue("NUE_CPART2") ), AllTrim( oModelNUE:GetValue("NUE_CCLIEN") ), AllTrim( oModelNUE:GetValue("NUE_CLOJA") ), AllTrim( oModelNUE:GetValue("NUE_CCASO") ), AllTrim( oModelNUE:GetValue("NUE_ANOMES") ),, AllTrim( oModelNUE:GetValue("NUE_CATIVI") ) )
		Else
			aRetJUR200    := JURA200( AllTrim( oModelNUE:GetValue("NUE_COD") ), AllTrim( oModelNUE:GetValue("NUE_CPART2") ), AllTrim( oModelNUE:GetValue("NUE_CCLIEN") ), AllTrim( oModelNUE:GetValue("NUE_CLOJA") ), AllTrim( oModelNUE:GetValue("NUE_CCASO") ), AllTrim( oModelNUE:GetValue("NUE_ANOMES") ),, AllTrim( oModelNUE:GetValue("NUE_CATIVI") ) )
			aRetJUR200[1] := oModelNUE:GetValue("NUE_CMOEDA")
			aRetJUR200[2] := oModelNUE:GetValue("NUE_VALORH")
		EndIf

		If Empty(aRetJUR200)
			lRet := JurMsgErro(STR0157) //"Erro ao recuperar o Valor Hora do participante."
		Else

			nTempR := oModelNUE:GetValue( "NUE_TEMPOR" )
		 	IIF(lRet, lRet := JurLoadValue(oModeLNUE, "NUE_CMOEDA" ,, aRetJUR200[1] ), )
		 	IIF(lRet, lRet := JurLoadValue(oModeLNUE, "NUE_VALORH" ,, aRetJUR200[2] ), )
		 	IIF(lRet, lRet := JurLoadValue(oModeLNUE, "NUE_VALOR"  ,, aRetJUR200[2] * nTempR ), )
		 	IIF(lRet, lRet := JurLoadValue(oModeLNUE, "NUE_CCATEG" ,, aRetJUR200[3] ), )

			aValor1TS := JA201FConv(oModelNX0:GetValue( "NX0_CMOEDA" ), oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CMOEDA] ),;
			                        oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALOR] ), "2", cNX0DTEMI, , cNX0Cod, )

			IIF(lRet, lRet := JurLoadValue(oModelNUE, "NUE_VALOR1", , aValor1TS[1] ), )

			lRet := lRet .And. JA202Part(oModelNUE, '*') //Acumula o TS  no participante destino

		EndIf

	EndIf

	nValorTS  := oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALORH] ) * oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_TEMPOR] ) //Calcula o valor do TS

	aValor1TS := JA201FConv(oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CMOED1] ), oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CMOEDA] ),;
	                        nValorTS, "2",cNX0DTEMI, , cNX0Cod, )
	//XYZ - passa qdo é ULTIMO
	IIF(lRet, lRet := JurLoadValue(oModelNUE, "NUE_VALOR" ,, nValorTS ), )
	IIF(lRet, lRet := JurLoadValue(oModelNUE, "NUE_VALOR1",, aValor1TS[1] ), )

	// atualiza o valor de desconto no caso.
	lRet :=  lRet .And. J202DESC(oModel)

ElseIf Substr(cCampo, 1, 3) == 'NX2'

	If ValType(oModelNX2:GetValue( cCampo )) == "N"
		If oModelNX2:GetValue( cCampo ) < 0
			lRet := JurMsgErro(STR0169) // "Informe um valor positivo!"
			Return lRet
		EndIf
	EndIf

	cClient  := oModelNX2:GetValue("NX2_CCLIEN")
	cLoja    := oModelNX2:GetValue("NX2_CLOJA")
	cCaso    := oModelNX2:GetValue("NX2_CCASO")
	cContr   := oModelNX2:GetValue("NX2_CCONTR")

	nPosAlt  := aScan( aAltPend, {|x| x[1] == 'TS' .And. x[2] == cClient .And. x[3] == cLoja .And. x[4] == cCaso .And. x[5] == cContr })

	If nPosAlt > 0
		lRet := JurMsgErro(STR0170) //"Existem alterações de valor pendentes, para efetuar novas alterações cancele as anteriores!"
		Return lRet
	EndIf

	nValorHTot := oModelNX2:GetValue( "NX2_VALORH" )

	If cCampo == "NX2_VALOR1"

		nUtRSPart  := oModelNX2:GetValue( "NX2_UTR" )    //Total de Uts - sem participacao
		nUtRCpart  := oModelNX2:GetValue( "NX2_UTCLI" )  //Total de Uts - com participacao
		nTempRCPar := oModelNX2:GetValue( "NX2_HFCLI" )  //Tempo - com participacao
		nValorMPre := oModelNX2:GetValue( "NX2_VALOR1" ) //Valor do Ts na moeda da pré
    	nValorMTab := oModelNX2:GetValue( "NX2_VLHTBH" ) //Valor do Ts na moeda da tabela de hon

		aValor1Tot := JA201FConv(oModelNX2:GetValue("NX2_CMOPRE"), oModelNX2:GetValue("NX2_CMOTBH"), nValorHTot, "2", oModelNX0:GetValue("NX0_DTEMI"), , oModelNX0:GetValue( "NX0_COD" ), )
		nValor1Tot := aValor1Tot[1]

		nUtRCpart2 := nTempRCPar * (60 / nJURTS1)

		nUTNRNova := (nValorMPre/nValor1Tot) * (60 / nJURTS1)
		nUTNRNova := IIf((nUTNRNova - nUtRCpart2) > 0, (nUTNRNova - nUtRCpart2), 0) // validação para aredondamento de 0 para numero negativo

		If !cJURTS3   //se não pode fracionar, arredonda para +
			If ((nUTNRNova) - Round( nUTNRNova , 0 )) != 0
				nUTNRNova := Round( nUTNRNova , 0 )
				cAlert := (STR0173 + CRLF + STR0174 + Alltrim( Str( nJURTS1 )) + STR0172) //"Sistema esta configurado para UT não fracionada." ###
			Else                                                                          //"O valor será ajustado para um múltiplo de " ### " minutos!"
				cAlert  := ""
			EndIf
		EndIf

		nTempRTot := (nUTNRNova + nUtRCpart2 )/ 60 * nJURTS1

		oStrucNX2 := oModelNX2:GetStruct()

		If !(cJURTS2 == 1)
			oStrucNX2:SetProperty( 'NX2_UTR', MODEL_FIELD_NOUPD, .F. )
			oStrucNX2:SetProperty( 'NX2_UTR', MODEL_FIELD_WHEN, {|| .T.} )
		EndIf
		lRet := JurSetValue(oModelNX2, 'NX2_UTR',, (nUTNRNova) )

		If !(cJURTS2 == 1)
			oStrucNX2:SetProperty( 'NX2_UTR', MODEL_FIELD_NOUPD, .T. )
			oStrucNX2:SetProperty( 'NX2_UTR', MODEL_FIELD_WHEN, {|| .F.} )
		EndIf

		If oModelNX2:GetValue('NX2_HORAR') == "****" .Or. (!lRet .And. oModel:AERRORMESSAGE[5] == "FWNOWIDTH" )
			JurMsgErro(STR0134) //"A quantidade de horas para o TS excede o tamanho do campo, não será possivel
			Return .F.          // alterar o valor do TS. Favor cancelar o procedimento.
		EndIf

		If !lRet
			Return lRet
		EndIf

		lRet := JurLoadValue(oModelNX2, "NX2_VLHTBH", , oModelNX2:GetValue( "NX2_TEMPOR" ) * oModelNX2:GetValue( "NX2_VALORH" ))
		If !cJURTS3 //se nao fraciona, ajusta o valor

			aVlPar1 := JA201FConv(oModelNX2:GetValue("NX2_CMOPRE"), oModelNX2:GetValue("NX2_CMOTBH"), oModelNX2:GetValue("NX2_VLHTBH"), "2", oModelNX0:GetValue("NX0_DTEMI"), , oModelNX0:GetValue( "NX0_COD" ), )
			lRet    := lRet .And. JurLoadValue(oModelNX2, "NX2_VALOR1", , aVlPar1[1] ) // ajusta o valor
		EndIf

	ElseIf cCampo == "NX2_VALORH"

		nTempRSPar := oModelNX2:GetValue( "NX2_TEMPOR" )  //Tempo Rev total - sem particip
		nTempRCPar := oModelNX2:GetValue( "NX2_HFCLI" ) //Tempo Rev. com participação de cliente
		nValorHTot := oModelNX2:GetValue( "NX2_VALORH" )  //Valor hora  na moeda da tab de honorários

		lRet := lRet .And. JurLoadValue(oModelNX2, "NX2_VLHTBH", , (nTempRSPar + nTempRCPar) * nValorHTot )

		aVlPar1 := JA201FConv(oModelNX2:GetValue("NX2_CMOPRE"), oModelNX2:GetValue("NX2_CMOTBH"), oModelNX2:GetValue("NX2_VLHTBH"), "2", oModelNX0:GetValue("NX0_DTEMI"), , oModelNX0:GetValue( "NX0_COD" ), )
		lRet    := lRet .And. JurLoadValue(oModelNX2, "NX2_VALOR1", , aVlPar1[1] ) // ajusta o valor

		cX2Cli    := oModelNX2:GetValue( "NX2_CCLIEN" )
		cX2Loja   := oModelNX2:GetValue( "NX2_CLOJA"  )
		cX2Caso   := oModelNX2:GetValue( "NX2_CCASO"  )
		cX2Part   := oModelNX2:GetValue( "NX2_CPART"  )
		nX2Valor  := oModelNX2:GetValue( "NX2_VALORH"  )
		cX2CodSeq := oModelNX2:GetValue( "NX2_CODSEQ" )
		cX2CLTab  := oModelNX2:GetValue( "NX2_CLTAB"  )
		cX2Categ  := oModelNX2:GetValue( "NX2_CCATEG" )
		cX2MOTBH  := oModelNX2:GetValue( "NX2_CMOTBH" )

		nPos := aScan( aPart, { |x| x[ 1] == cX2Cli .And. ;
					x[ 2] == cX2Loja .And. ;
					x[ 3] == cX2Caso .And. ;
					x[ 4] == cX2Part .And. ;
					x[10] == cX2CodSeq .And. ;
					x[13] == cX2CLTab .And. ;
					x[14] == cX2Categ .And. ;
					x[21] == cX2MOTBH} )

		If nPos > 0
			lAltPerio  := .T. // Altera para não chamar a tot pré varias vezes
			nLnNUE_OLD := oModelNUE:GetLine()
			For nI := 1 To oModelNUE:GetQtdLine()
				If  oModelNUE:GetValue('NUE_CPART2', nI) == oModelNX2:GetValue( "NX2_CPART" ) ;
					.And. oModelNUE:GetValue('NUE_CCASO', nI) == oModelNX2:GetValue( "NX2_CCASO" ) ;
					.And. oModelNUE:GetValue('NUE_VALORH', nI)  == aPart[nPos][5] ;
					.And. oModelNUE:GetValue('NUE_CCATEG', nI)  == cX2Categ ;
					.And. Empty(oModelNUE:GetValue('NUE_CLTAB', nI))

					oModelNUE:GoLine(nI)
					lRet := JurSetValue(oModelNUE, 'NUE_VALORH',, (nValorHTot) )

				EndIf
			Next nI
			lAltPerio := .F. // Altera para não chamar a tot pré varias vezes
			oModelNUE:GoLine(nLnNUE_OLD)
			aPart[nPos][05] := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_VALORH] )
		EndIf

	ElseIf cCampo == 'NX2_UTR' .Or. cCampo == 'NX2_TEMPOR' .Or. cCampo == 'NX2_HORAR'

		Do Case
			Case cCampo == 'NX2_UTR'
				nTipoOrig := 1
				nUTNRNova := oModelNX2:GetValue('NX2_UTR')

				If !cJURTS3
					If (nUTNRNova - Round(nUTNRNova, 0)) = 0
						cTempoNX2 := Str(nUTNRNova)
					Else
						lRet := JurMsgErro(STR0171 + Alltrim( Str( nJURTS1 )) + STR0172) //"Só é permitido apontar tempos múltiplos de "+ Alltrim( Str( nJURTS1 ) ) +" minutos!"
						Return (lRet)
					EndIf
				Else
					cTempoNX2 := Str(nUTNRNova)
				EndIf

				IIF( lRet, lRet := JurLoadValue(oModelNX2, 'NX2_TEMPOR', , VAL( JURA144C1(nTipoOrig, 2, cTempoNX2 ) ) ), )
				IIF( lRet, lRet := JurLoadValue(oModelNX2, 'NX2_HORAR' , , PADL(JURA144C1(nTipoOrig, 3, cTempoNX2 ), TamSX3('NX2_HORAR')[1], '0') ), )

			Case cCampo == 'NX2_TEMPOR'
				nTipoOrig := 2
				cTempoNX2 := Str(oModelNX2:GetValue('NX2_TEMPOR'))

				If !cJURTS3
					nUTNRNova := Val( JURA144C1(nTipoOrig, 1, cTempoNX2 ) )
					If (nUTNRNova - Round(nUTNRNova, 0)) != 0
						lRet := JurMsgErro(STR0171 + Alltrim( Str( nJURTS1 )) + STR0172) //"Só é permitido apontar tempos múltiplos de "+ Alltrim( Str( nJURTS1 ) ) +" minutos!"
						Return (lRet)
					EndIf
				EndIf

				IIF( lRet, lRet := JurLoadValue(oModelNX2, 'NX2_UTR'  , , VAL( JURA144C1(nTipoOrig, 1, cTempoNX2 ) ) ), )//a função JURA144C1 já arredonda qdo precisa
				IIF( lRet, lRet := JurLoadValue(oModelNX2, 'NX2_HORAR', , PADL(JURA144C1(nTipoOrig, 3, cTempoNX2 ), TamSX3('NX2_HORAR')[1], '0') ), )

			Case cCampo == 'NX2_HORAR'
				nTipoOrig := 3
				cTempoNX2 := oModelNX2:GetValue('NX2_HORAR')

				If !cJURTS3
					nUTNRNova := VAL( JURA144C1(nTipoOrig, 1, cTempoNX2 ) )
					If (nUTNRNova - Round(nUTNRNova, 0)) != 0
						lRet := JurMsgErro(STR0171 + Alltrim( Str( nJURTS1 )) + STR0172) //"Só é permitido apontar tempos múltiplos de "+ Alltrim( Str( nJURTS1 ) ) +" minutos!"
						Return (lRet)
					EndIf
				EndIf

				IIF( lRet, lRet := JurLoadValue(oModelNX2, 'NX2_UTR'   , , Val( JURA144C1(nTipoOrig, 1, cTempoNX2 ) ) ), )//a função JURA144C1 já arredonda qdo precisa
				IIF( lRet, lRet := JurLoadValue(oModelNX2, 'NX2_TEMPOR', , Val( JURA144C1(nTipoOrig, 2, cTempoNX2 ) ) ), )

		End Case

		If oModelNX2:GetValue('NX2_HORAR') == "****" .Or. (!lRet .And. oModel:AERRORMESSAGE[5] == "FWNOWIDTH" )
			JurMsgErro(STR0134) //"A quantidade de horas para o TS excede o tamanho do campo, não será possivel
			Return .F.          // alterar o valor do TS. Favor cancelar o procedimento.
		EndIf

		lRet :=  lRet .And. JurLoadValue(oModelNX2, "NX2_VLHTBH", , (oModelNX2:GetValue('NX2_HFCLI') + oModelNX2:GetValue('NX2_TEMPOR')) * oModelNX2:GetValue("NX2_VALORH" ) )

		aVlPar1 := JA201FConv(oModelNX2:GetValue("NX2_CMOPRE"), oModelNX2:GetValue("NX2_CMOTBH"), oModelNX2:GetValue("NX2_VLHTBH"), "2", oModelNX0:GetValue("NX0_DTEMI"), , oModelNX0:GetValue( "NX0_COD" ),  )
		lRet := lRet .And. JurLoadValue(oModelNX2, "NX2_VALOR1", , aVlPar1[1] ) // ajusta o valor

		nUTNRNova := oModelNX2:GetValue('NX2_UTR')
	EndIf

		If !(cCampo == "NX2_VALORH")

		/*
		aPart: {[01] "NX1_CCLIEN", [02] "NX1_CLOJA" , [03] "NX1_CCASO",;
				[04] "NX2_CPART" , [05] "NX2_VALORH", [06] "NX2_VALOR1",;
				[07] "NX2_UTR"   , [08] "NX2_TEMPOR", [09] "NX2_HORAR",;
				[10] "NX2_CODSEQ", [11] oModelNX2:nLine [12] Part Alterado?;
				[13] "NX2_CLTAB",  [14] "NX2_CCATEG", [15] "NX2_UTLANC";
				[16] "NX2_HFLANC", [17] "NX2_HRLANC", [18] "NX2_UTCLI";
				[19] "NX2_HFCLI",  [20] "NX2_HRCLI" , [21] "NX2_CMOTBH" } )
		*/

		cX2Cli    := oModelNX2:GetValue( "NX2_CCLIEN" )
		cX2Loja   := oModelNX2:GetValue( "NX2_CLOJA"  )
		cX2Caso   := oModelNX2:GetValue( "NX2_CCASO"  )
		cX2Part   := oModelNX2:GetValue( "NX2_CPART"  )
		nX2Valor  := oModelNX2:GetValue( "NX2_VALORH"  )
		cX2CodSeq := oModelNX2:GetValue( "NX2_CODSEQ" )
		cX2CLTab  := oModelNX2:GetValue( "NX2_CLTAB"  )
		cX2Categ  := oModelNX2:GetValue( "NX2_CCATEG" )
		cX2MOTBH  := oModelNX2:GetValue( "NX2_CMOTBH" )
		nPos := aScan( aPart, { |x| x[ 1] == cX2Cli .And. ;
									x[ 2] == cX2Loja .And. ;
									x[ 3] == cX2Caso .And. ;
									x[ 4] == cX2Part .And. ;
									x[ 5] == nX2Valor .And. ;
									x[10] == cX2CodSeq .And. ;
									x[13] == cX2CLTab .And. ;
									x[14] == cX2Categ .And. ;
									x[21] == cX2MOTBH} )

		aValTS   := {}

		nNVT     := 0 //Novo valor Total
		nVAD     := 0 //Valor sendo adicionado/subtraido
		nVSP     := 0 //Valor sem participacao direta do cliente
		nVCP     := 0 //Valos com participacao direta do cliente
		nVOS     := 0 //Valor do caso (com participacao)
		nVOI     := 0 //Valor do caso (sem participacao)
		nADC     := 0 //Valor adicional calculado por caso
		nNVC     := 0 //Novo valor por caso
		nRES     := 0 //Residuo de arredondamento

		nNVT := oModelNX2:GetValue('NX2_UTR')

		If nPos > 0
			nQtdNUE := oModelNUE:GetQtdLine()
			For nI := 1 To nQtdNUE
				If  oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CPART2], nI) == cX2Part ;
					.And. oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CCASO], nI) == cX2Caso ;
					.And. oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALORH], nI) ==  aPart[nPos][5] ;
					.And. oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CCATEG], nI) ==  aPart[nPos][14] ;
					.And. Empty(oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CLTAB], nI));
					.And. JA202TEMPO( .F., oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CATIVI], nI ) ) ;
					.And. (J202ATIVID("2", oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CATIVI], nI )) == "1") ;
					.And. oModelNUE:GetValue('NUE_COBRAR', nI) == "1"

					nVSP += oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_UTR], nI )
					AAdd(aValTS, {nI, 0, oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_UTR], nI ), .T.})

				EndIf
			Next nI
		EndIf

		nVAD := nNVT - (nVSP + nVCP)

		nRES := nNVT

		For nI := 1 To Len(aValTS)
			nVOS := aValTS[nI][2]
			nVOI := aValTS[nI][3]

			nADC := nVAD * (nVOI / nVSP)
			nNVC := nADC + nVOI + nVOS

			If cJURTS3 .Or. cJURTS2 == 2
				nRES := nRES - nNVC
			Else
				nRES := Round(nRES - nNVC, 0)
			EndIf

			AAdd(aValTS[nI], nNVC)

		Next nI

		For nI := 1 To Len(aValTS)
			oModelNUE:GoLine(aValTS[nI][1])

			//Ajusta o residuo
			If aValTS[nI][4]
				nNVC := Iif((aValTS[nI][5] + nRES) > 0, (aValTS[nI][5] + nRES), 0) // validação para aredondamento de 0 para numero negativo
				nRES := 0

				If !cJURTS3
					nNVC := Round(nNVC, 0)
				EndIf

			Else
				nNVC := aValTS[nI][5]
			EndIf

			oStrucNUE := oModelNUE:GetStruct()

			If !(cJURTS2 == 1)
				oStrucNUE:SetProperty( 'NUE_UTR', MODEL_FIELD_NOUPD, .F. )
				oStrucNUE:SetProperty( 'NUE_UTR', MODEL_FIELD_WHEN, {|| .T.} )
			EndIf

			lRet := JurSetValue(oModelNUE, 'NUE_UTR',, nNVC )  //Já deve converter os tempos na JURA144V1()

			If !(cJURTS2 == 1)
				oStrucNUE:SetProperty( 'NUE_UTR', MODEL_FIELD_NOUPD, .T. )
				oStrucNUE:SetProperty( 'NUE_UTR', MODEL_FIELD_WHEN, {|| .F.} )
			EndIf

			If oModelNUE:GetValue('NUE_HORAR') == "****"
				JurMsgErro(STR0134) //"A quantidade de horas para o TS excede o tamanho do campo, não será possivel
				Return .F.          // alterar o valor do TS. Favor cancelar o procedimento.
			EndIf

			If !lRet
				FwRestRows(aSaveLines, oModel)
				RestArea(aArea)
				Return lRet
			EndIf

		Next nI

		//Tratamento das diferencas de arredondamento
		If nPos > 0
			nQtdNUE := oModelNUE:GetQtdLine()
			For nI := 1 To nQtdNUE
				If  oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CPART2], nI) == cX2Part ;
					.And. oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CCASO], nI) == cX2Caso ;
					.And. oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALORH], nI) ==  aPart[nPos][5] ;
					.And. oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CCATEG], nI) ==  aPart[nPos][14] ;
					.And. Empty(oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CLTAB], nI))

					nSomaTS  := nSomaTS + oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALOR], nI)
					nSomaTS1 := nSomaTS1 + oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALOR1], nI)

				EndIf
			Next nI
		EndIf

		nNX2Valor := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_VALOR1] )
		nNX2VTabH := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_VLHTBH] )

		nDifTS    := nNX2VTabH - nSomaTS //compatibilizar com o campo NX2_VLHTBH que só tem duas casas decimais
		nDifTS1   := nNX2Valor - nSomaTS1

		If lRet .And. (nDifTS <> 0 .Or. nDifTS1 <> 0) .And. nPos > 0
			nQtdNUE := oModelNUE:GetQtdLine()
			For nI := 1 To nQtdNUE
				oModelNUE:GoLine(nI)
				If  oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CPART2], nI) == cX2Part ;
					.And. oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CCASO], nI) == cX2Caso;
					.And. oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALORH], nI) ==  aPart[nPos][5] ;
					.And. oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CCATEG], nI) ==  aPart[nPos][14] ;
					.And. JA202TEMPO( .F., oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CATIVI], nI )) ;
					.And. Empty(oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CLTAB], nI));
					.And. (oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALOR1], nI) != 0.00000000);
					.And. (J202ATIVID("2", oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CATIVI], nI )) == "1") ;
					.And. oModelNUE:GetValue('NUE_COBRAR', nI) == "1"

					lRet := lRet .And. JurLoadValue(oModelNUE, "NUE_VALOR", , oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALORH], nI ) * oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_TEMPOR], nI ) ) // ajusta o valor

					lRet := lRet .And. JurLoadValue(oModelNUE, "NUE_VALOR1", , oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALOR1], nI) + nDifTS1) // ajusta o valor

					Exit
				EndIf
			Next nI
		EndIf
		//============================================

		If nPos > 0
			aPart[nPos][05] := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_VALORH] )
			aPart[nPos][06] := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_VALOR1] )
			aPart[nPos][07] := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_UTR]    )
			aPart[nPos][08] := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_TEMPOR] )
			aPart[nPos][09] := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_HORAR]  )
		EndIf

	EndIf

	lRet := lRet .And. J202DESC(oModel)
	lRet := lRet .And. J202DivCas("NX1")

ElseIf cCampo == 'NV4_VLHFAT'

	lRet := J202DESC(oModel)
	lRet := lRet .And. J202DivCas("NX1")

EndIf

If !IsInCallStack("JA202ARRETS") // Não executar o tot pré nesse momento quando vier do arredondamento de TSs
	If !lAltPerio // Em alteração de valores no campo Valor TS não efetuar o JA202TotPre
		lRet := lRet .And. JA202TotPre(cCampo)
		If !lIsRest
			oView := FwViewActive()
			oView:Refresh()
		EndIf
	EndIf
EndIf

FwRestRows( aSaveLines, oModel )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202MNURED
Menu de opções para redação

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA202MNURED( oVw, oBotao )
Local lRet    := .T.
Local aParBox := {}
Local aRetPar := {}
Local nTipOpe := 0
Local nLine   := oVw:GetModel('NX1DETAIL'):nLine

	If oVw:GetFolderActive("FOLDER_01", 2)[1] <> 1 // Somente na aba de Pré-fatura
		MsgInfo(STR0221) // "Esta ação é permitida somente na aba de Pré-Fatura!"
		lRet := .F.
	EndIf

	If lRet

		aAdd(aParBox,{3, STR0212, nTipOpe, {STR0026, STR0075}, 60, "", .F.}) //"Destino da Redação"###"Pré-fatura"###"Caso"

		If !ParamBox(aParBox, STR0033, @aRetPar,,,,,,,, .F., .F.) //"Redação"
			Return Nil
		EndIf

		nTipOpe := aRetPar[1]

		Do Case
			Case nTipOpe == 1
				JA202REDA2( oVw, "2" )

			Case nTipOpe == 2
				JA202REDA3( oVw, "3", nLine )
		EndCase

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202MNUORI
Menu de opções para voltar valor original

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA202MNUORI( oView, oBotao )
Local aMenuItem := {}
Local oMenu     := Nil

oMenu := MenuBegin(,,,, .T.,,oBotao)
aAdd(aMenuItem, MenuAddItem(STR0026, STR0085,,,,,, oMenu, {|| MsgRun(STR0050, , {|| JA202ORI1(oView)})},,,,, { || .T. })) // "Pré-Fatura"###"Volta valor original de toda pré-fatura" "Aguarde"
aAdd(aMenuItem, MenuAddItem(STR0075, STR0086,,,,,, oMenu, {|| MsgRun(STR0050, , {|| JA202ORI2(oView)})},,,,, { || .T. })) // "Caso"###"Volta valor original do caso" "Aguarde"
aAdd(aMenuItem, MenuAddItem(STR0191,,,,,,, oMenu, {|| JA202ORI3(oView)},,,,, {|| .T. })) // "Cotações"
MenuEnd()

oMenu:Activate( 10, 10, oBotao )

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202BTOBS
Exibe a janela para alteração da observação e Faturamento do Caso e permite a edição

@author David G. Fernandes
@since 08/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA202BTOBS( oView, cTabela, cTitulo )
Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaNX0 := NX0->( GetArea() )
Local oModel   := oView:GetModel()
Local cClien   := oModel:GetValue('NX1DETAIL', 'NX1_CCLIEN')
Local cLoja    := oModel:GetValue('NX1DETAIL', 'NX1_CLOJA')
Local cCaso    := oModel:GetValue('NX1DETAIL', 'NX1_CCASO')
Local cMemoOBS := ""
Local oMemoOBS
Local oDlg

	If oView:GetFolderActive("FOLDER_01", 2)[1] <> 1 // Somente na aba de Pré-fatura
		MsgInfo(STR0221) // "Esta ação é permitida somente na aba de Pré-Fatura!"
		lRet := .F.
	EndIf

	If lRet
		cMemoOBS := JurGetDados( cTabela, 1, xFilial(cTabela) + cClien + cLoja + cCaso, cTabela + '_OBSFAT' )

		Define MsDialog oDlg Title STR0138 FROM 233, 194 To 603, 747 Pixel // "Observação"

		@ 047, 004 Say cTitulo     Size 100, 008 Pixel Of oDlg //"Redação"
		@ 057, 002 Get oMemoOBS   Var  cMemoOBS Memo Size 271, 125 Pixel Of oDlg

		@ 007, 235 Button STR0077  Size 037, 012 Pixel Of oDlg  Action (J202SetOBS(cTabela, cClien, cLoja, cCaso, cMemoOBS), oDlg:End()) //"Ok"
		@ 025, 235 Button STR0024  Size 037, 012 Pixel Of oDlg  Action oDlg:End() //"Cancelar"

		Activate MsDialog oDlg Centered

		RestArea( aAreaNX0 )
		RestArea( aArea )
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202SetOBS
Exibe a janela para alteração da observaçãod e Faturamento do Caso e permite a edição

@author David G. Fernandes
@since 08/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202SetOBS(cTabela, cClien, cLoja, cCaso, cOBS)
Local aArea    := GetArea()
Local aAreaTAB := &(cTabela)->(GetArea())

	&(cTabela)->(DbSeek(xFilial(cTabela) + cClien + cLoja + cCaso))
	Reclock(cTabela, .F.)
	&(cTabela)->(&(cTabela + "_OBSFAT")) := cOBS
	(cTabela)->(MsUnlock())
	(cTabela)->(DbCommit())
	(cTabela)->(DbSkip())

	If __lSX8
		ConfirmSX8()
	EndIf

	RestArea(aAreaTAB)
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202ORI1
voltar valor original da pre fatura

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA202ORI1(oView)
Local oModel     := FWModelActive()
Local aArea      := GetArea()
Local aSaveLines := FwSaveRows()
Local lError     := .F.
Local nNX8       := 0
Local nNX1       := 0
Local nNUE       := 0
Local nNV4       := 0
Local oModelNX0  := oModel:GetModel('NX0MASTER')
Local oModelNX8  := oModel:GetModel('NX8DETAIL')
Local oModelNX1  := oModel:GetModel('NX1DETAIL')
Local oModelNUE  := oModel:GetModel('NUEDETAIL')
Local oModelNV4  := oModel:GetModel('NV4DETAIL')
Local lAtivNaoC  := SuperGetMV( 'MV_JURTS4',, .F. ) //Zera o tempo revisado de atividades nao cobraveis

Local aParBox   := {}
Local aRetPar   := {}
Local nTipOpe   := 1

Local nValorTS  := 0
Local aValor1TS := {}
Local nVTotTs   := 0
Local nValorLT  := 0
Local nVTotLT   := 0
Local aTabVinc  := {{"", 0}}
Local nPos      := 0
Local nVLTabTmp := 0
Local nVTSTab   := 0
Local nLnNX8_OLD
Local nLnNX1_OLD
Local nLnNUE_OLD
Local nLnNV4_OLD

	aAdd(aParBox,{3, STR0034, nTipOpe, {STR0179, STR0008, STR0010}, 60, "", .F.}) //"Val. Original" # "Ambos" ## "Time-Sheet" ### "Lanc. Tabelado"

	If !ParamBox(aParBox, STR0085, @aRetPar,,,,,,,, .F., .F.)  //"Volta valor original de toda pré-fatura"
		Return Nil
	EndIf

	nTipOpe := aRetPar[1]

	If !ApMsgYesNo( STR0087 + CRLF + STR0088 ) //"Confirma a operação ?"### "Serão restaurados os valores lançados dos lançamentos selecionados de toda a pré-fatura."
		Return Nil
	EndIf

	nLnNX8_OLD := oModelNX8:GetLine()
	For nNX8 := 1 To oModelNX8:GetQtdLine()
		oModelNX8:GoLine( nNX8 )

		nLnNX1_OLD := oModelNX1:GetLine()
		For nNX1 := 1 To oModelNX1:GetQtdLine()

			oModelNX1:GoLine( nNX1 )
			nVTSTab  := 0
			nVTotTS  := 0
			nVTotLT  := 0

			If !oModelNUE:IsEmpty() .And. (nTipOpe == 1 .Or. nTipOpe == 2)
				nLnNUE_OLD := oModelNUE:GetLine()
				For nNUE := 1 To oModelNUE:GetQtdLine()
					oModelNUE:GoLine( nNUE )

					If !oModelNUE:CanUpdateLine()
						oModelNUE:SetNoUpdateLine(.F.)
					EndIf

					If J202TEMPOZ(oModelNUE:GetValue('NUE_CATIVI'))
						J202LoadVl(oModelNUE, "NUE_TEMPOR", oModelNUE:GetValue("NUE_TEMPOL"))
						J202LoadVl(oModelNUE, "NUE_HORAR", oModelNUE:GetValue("NUE_HORAL"))
						J202LoadVl(oModelNUE, "NUE_UTR", oModelNUE:GetValue("NUE_UTL"))

						nValorTS  := oModelNUE:GetValue("NUE_VALORH" ) * oModelNUE:GetValue("NUE_TEMPOL" ) //Calcula o valor do TS

		 				aValor1TS := JA201FConv(oModelNUE:GetValue("NUE_CMOED1"), oModelNUE:GetValue("NUE_CMOEDA"),;
		 							nValorTS, "1", oModelNX0:GetValue("NX0_DTEMI"), /*cCodFImpr*/, /*cCodCont*/, /*cXFilial*/)

						J202LoadVl(oModelNUE, "NUE_VALOR" , nValorTS)
						J202LoadVl(oModelNUE, "NUE_VALOR1", aValor1TS[1])

						If Empty(oModelNUE:GetValue("NUE_CLTAB"))
							nVTotTS := nVTotTS + oModelNUE:GetValue("NUE_VALOR1")
						Else  //guarda os valores do TS para verificar com o seu respectivo tabelado

							nPos := aScan( aTabVinc, { | ax | Alltrim(ax[1]) == Alltrim(oModelNUE:GetValue("NUE_CLTAB")) } )

							If nPos > 0
								aTabVinc[nPos][2] := aTabVinc[nPos][2] + oModelNUE:GetValue("NUE_VALOR1")
							Else
								aAdd(aTabVinc, {oModelNUE:GetValue("NUE_CLTAB"), oModelNUE:GetValue("NUE_VALOR1")})
							EndIf

						EndIf
					ElseIf lAtivNaoC //Não cobrável e zera tempo revisado
						J202LoadVl(oModelNUE, "NUE_TEMPOR", 0)
						J202LoadVl(oModelNUE, "NUE_HORAR" , Transform(PADL("0", TamSX3('NUE_HORAR')[1], '0'), PesqPict("NUE", "NUE_HORAR")))
						J202LoadVl(oModelNUE, "NUE_UTR"   , 0)
					EndIf

					If oModel:GetModel():HasErrorMessage()
						lError := .T.
					EndIf

				Next nNUE
				oModelNUE:GoLine(nLnNUE_OLD)
				J202LoadVl(oModelNX1, "NX1_VTS", nVTotTs)
			EndIf

	 		If !oModelNV4:IsEmpty() .And. (nTipOpe == 1 .Or. nTipOpe == 3)
				nLnNV4_OLD := oModelNV4:GetLine()
				For nNV4 := 1 To oModelNV4:GetQtdLine()
					oModelNV4:GoLine( nNV4 )

					If !oModelNV4:CanUpdateLine()
						oModelNV4:SetNoUpdateLine(.F.)
					EndIf

					nValorLT := oModelNV4:GetValue( 'NV4_VLHTAB' )

					J202LoadVl(oModelNV4, "NV4_VLHFAT", nValorLT)

					nVLTabTmp := JA201FConv(oModelNX0:GetValue("NX0_CMOEDA"), oModelNV4:GetValue("NV4_CMOEH"),;
	 				             nValorLT, "1", oModelNX0:GetValue("NX0_DTEMI"))[1]

	 				// verifica a regra do cobra maior entre Time Sheet	e tabelado vinculado
					If JurGetDados("NRD", 1, xFilial("NRD") + oModelNV4:GetValue('NV4_CTPSRV'), "NRD_COBMAI") == "1"

						nPos := aScan( aTabVinc, { | ax | Alltrim(ax[1]) == Alltrim(oModelNV4:GetValue( 'NV4_COD' )) } )

						If nPos > 0
							If aTabVinc[nPos][2] > nVLTabTmp
								nVLTabTmp := aTabVinc[nPos][2]
							EndIf
							nVTSTab  := nVTSTab + aTabVinc[nPos][2]
						EndIf

					EndIf

					nVTotLT := nVTotLT + nVLTabTmp
					If oModel:GetModel():HasErrorMessage()
						lError := .T.
					EndIf
				Next nNV4
				oModelNV4:GoLine(nLnNV4_OLD)

				J202LoadVl(oModelNX1, "NX1_VTAB"  , nVTotLT)
				J202LoadVl(oModelNX1, "NX1_VTSTAB", nVTSTab)

			EndIf

			If lError
				Exit
			Else
				lError := !JA202VLOCS(oModel) //Volta ao valor orginal de desconto
			EndIf

		Next nNX1
		oModelNX1:GoLine(nLnNX1_OLD)

		If lError
			Exit
		EndIf

	Next nNX8
	oModelNX8:GoLine(nLnNX8_OLD)

	If lError
		oView:ShowLastError()
	Else
		If !lAltPerio // Em alteração de valores no campo Valor TS não efetuar o JA202TotPre
			JA202TotPre("")
		EndIf
		//atualiza o array de informações dos casos
		JA202CPYMD( oModel )
		MsgInfo(STR0136, STR0019) //"Registro alterado com sucesso!" ### "Alterar"
	EndIf

	oView:Refresh()

	FwRestRows( aSaveLines )

	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202ORI2
voltar valor original da caso

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA202ORI2( oView )
Local oModel        := FWModelActive()
Local aArea         := GetArea()
Local aSaveLines    := FwSaveRows(  )
Local lError        := .F.
Local nNUE          := 0
Local nNV4          := 0
Local oModelNX0     := oModel:GetModel( 'NX0MASTER' )
Local oModelNX1     := oModel:GetModel( 'NX1DETAIL' )
Local oModelNUE     := oModel:GetModel( 'NUEDETAIL' )
Local oModelNV4     := oModel:GetModel( 'NV4DETAIL' )

Local aParBox       := {}
Local aRetPar       := {}
Local nTipOpe       := 1

Local nValorTS      := 0
Local aValor1TS     := {}
Local nVTotTs       := 0
Local nValorLT      := 0
Local nVTotLT       := 0
Local aTabVinc      := {{"", 0}}
Local nPos          := 0
Local nVLTabTmp     := 0
Local nVTSTab       := 0
Local nLn_OLD

aAdd(aParBox,{3, STR0034, nTipOpe, {STR0179, STR0008, STR0010}, 60, "", .F.}) //"Val. Original" # "Ambos" ## "Time-Sheet" ### "Lanc. Tabelado"

If !ParamBox(aParBox, STR0086, @aRetPar,,,,,,,, .F., .F.)  //"Volta valor original do caso"
	Return Nil
EndIf

nTipOpe := aRetPar[1]

If !ApMsgYesNo( STR0087 + CRLF + STR0089 + oModelNX1:GetValue( 'NX1_CCASO' ) + '.' ) //"Confirma a operação ?"###"Serão restaurados os valores lançados dos lançamentos selecionados do caso "
	Return Nil
EndIf

If !oModelNUE:IsEmpty() .And. (nTipOpe == 1 .Or. nTipOpe == 2)

	nLn_OLD := oModelNUE:GetLine()
	For nNUE := 1 To oModelNUE:GetQtdLine()

		oModelNUE:GoLine( nNUE )

		If !oModelNUE:CanUpdateLine()
			oModelNUE:SetNoUpdateLine(.F.)
		EndIf

		If J202TEMPOZ(oModelNUE:GetValue('NUE_CATIVI'))

			J202LoadVl(oModelNUE, "NUE_TEMPOR", oModelNUE:GetValue("NUE_TEMPOL"))
			J202LoadVl(oModelNUE, "NUE_HORAR" , oModelNUE:GetValue("NUE_HORAL"))
			J202LoadVl(oModelNUE, "NUE_UTR"   , oModelNUE:GetValue("NUE_UTL"))

			nValorTS  := oModelNUE:GetValue("NUE_VALORH") * oModelNUE:GetValue("NUE_TEMPOL") //Calcula o valor do TS

	 		aValor1TS := JA201FConv(oModelNUE:GetValue("NUE_CMOED1"), oModelNUE:GetValue("NUE_CMOEDA"),;
	 							nValorTS, "1", oModelNX0:GetValue("NX0_DTEMI"), /*cCodFImpr*/, /*cCodCont*/, /*cXFilial*/)

			J202LoadVl(oModelNUE, "NUE_VALOR", nValorTS)
			J202LoadVl(oModelNUE, "NUE_VALOR1", aValor1TS[1])

			If Empty(oModelNUE:GetValue("NUE_CLTAB"))
				nVTotTS := nVTotTS + oModelNUE:GetValue("NUE_VALOR1")
			Else  //guarda os valores do TS para verificar com o seu respectivo tabelado

				nPos := aScan( aTabVinc, { | ax | Alltrim(ax[1]) == Alltrim(oModelNUE:GetValue("NUE_CLTAB")) } )

				If nPos > 0
					aTabVinc[nPos][2] := aTabVinc[nPos][2] + oModelNUE:GetValue("NUE_VALOR1")
				Else
					aAdd(aTabVinc, {oModelNUE:GetValue("NUE_CLTAB"), oModelNUE:GetValue("NUE_VALOR1")})
				EndIf

		    EndIf
		Else //Não cobrável
			J202LoadVl(oModelNUE, "NUE_TEMPOR", 0)
			J202LoadVl(oModelNUE, "NUE_HORAR" , Transform(PADL("0", TamSX3('NUE_HORAR')[1], '0'), PesqPict("NUE", "NUE_HORAR")))
			J202LoadVl(oModelNUE, "NUE_UTR"   , 0)
		EndIf

		If oModel:GetModel():HasErrorMessage()
			lError := .T.
		EndIf

	Next nNUE
	oModelNUE:GoLine(nLn_OLD)

	J202LoadVl(oModelNX1, "NX1_VTS", nVTotTs)

EndIf

If !oModelNV4:IsEmpty() .And. (nTipOpe == 1 .Or. nTipOpe == 3)

	nLn_OLD := oModelNV4:GetLine()
	For nNV4 := 1 To oModelNV4:GetQtdLine()

		oModelNV4:GoLine( nNV4 )

		If !oModelNV4:CanUpdateLine()
			oModelNV4:SetNoUpdateLine(.F.)
		EndIf

		nValorLT := oModelNV4:GetValue( 'NV4_VLHTAB' )

		J202LoadVl(oModelNV4, "NV4_VLHFAT", nValorLT)

		nVLTabTmp := JA201FConv(oModelNX0:GetValue("NX0_CMOEDA" ), oModelNV4:GetValue("NV4_CMOEH"),;
 											nValorLT, "1", oModelNX0:GetValue("NX0_DTEMI"))[1]

		// verifica a regra do cobra maior entre Time Sheet	e tabelado vinculado
		If JurGetDados("NRD", 1, xFilial("NRD") + oModelNV4:GetValue('NV4_CTPSRV'), "NRD_COBMAI") == "1"

			nPos := aScan( aTabVinc, { | ax | Alltrim(ax[1]) == Alltrim(oModelNV4:GetValue( 'NV4_COD' )) } )

			If nPos > 0
				If aTabVinc[nPos][2] > nVLTabTmp
					nVLTabTmp := aTabVinc[nPos][2]
				EndIf
				nVTSTab := nVTSTab + aTabVinc[nPos][2]
			EndIf
		EndIf

		nVTotLT := nVTotLT + nVLTabTmp

		If oModel:GetModel():HasErrorMessage()
			lError := .T.
		EndIf

	Next nNV4
	oModelNV4:GoLine(nLn_OLD)

	J202LoadVl(oModelNX1, "NX1_VTAB", nVTotLT)
	J202LoadVl(oModelNX1, "NX1_VTSTAB", nVTSTab)

EndIf

If !lError
	lError := !JA202VLOCS(oModel) //Volta ao valor orginal de desconto
	JA202CPYMD( oModel ) //Atualiza o array de informações dos casos
EndIf

If lError
	oView:ShowLastError()
Else
	If !lAltPerio // Em alteração de valores no campo Valor TS não efetuar o JA202TotPre
		JA202TotPre("")
	EndIf
	MsgInfo(STR0136, STR0019) //"Registro alterado com sucesso!" ### "Alterar"
EndIf

oView:Refresh()

FwRestRows( aSaveLines )

RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202ORI3
Controle da chamada para função que restaura as cotações

@Param oView   Objeto da View de dados a ser exibida

@author Abner Fogaça de Oliveira
@since 21/03/19
/*/
//-------------------------------------------------------------------
Static Function JA202ORI3(oView)
	Local lRet      := .F.
	Local cTipoConv := SuperGetMv('MV_JTPCONV',, '1' ) // Cotação '1' = Diária / '2' = Mensal
	
	lRet := ApMsgYesNo(STR0323 + Iif(cTipoConv == "1", STR0324, STR0325) + CRLF + STR0087) // "Os valores de cotações serão restaurados para o valor de cotação "#" diária/mensal "##" Confirma Operação? "###" Aguarde"

	If lRet
		MsgRun(STR0050, , {|| J202CotOri(oView)}) // Aguarde
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202CotOri
Restaura os valores originais de cotação diária ou mensal

@Param oView   Objeto da View de dados a ser exibida

@author Abner Fogaça de Oliveira
@since 20/03/19
/*/
//-------------------------------------------------------------------
Static Function J202CotOri(oView)
	Local cMoedaPre := ""
	Local cMoedaCot := ""
	Local dDtEmitPf := CToD( '  /  /  ' )
	Local aCotac    := {}
	Local oModel    := FWModelActive()
	Local oModelNX0 := oModel:GetModel('NX0MASTER')
	Local oGridNXR  := oModel:GetModel('NXRDETAIL')
	Local nLine     := 0
	Local nQtdLines := oGridNXR:GetQtdLine()

	aSaveLn   := FwSaveRows()
	cMoedaPre := oModelNX0:GetValue('NX0_CMOEDA')
	dDtEmitPf := oModelNX0:GetValue('NX0_DTEMI')

	For nLine := 1 To nQtdLines
		oGridNXR:GoLine(nLine)
		If !oGridNXR:IsEmpty() .And. !oGridNXR:IsDeleted()
			cMoedaCot := oGridNXR:GetValue('NXR_CMOEDA')
			aCotac    := JA201FConv(cMoedaPre, cMoedaCot, 1000, '1', dDtEmitPf)
			If oGridNXR:GetValue('NXR_COTAC') != aCotac[2]
				oGridNXR:LoadValue("NXR_COTAC", aCotac[2])
				oGridNXR:LoadValue('NXR_ALTCOT', '2') // Não alterada
			EndIf
		EndIf
	Next nLine
		
	If !oGridNXR:IsEmpty()
		oGridNXR:GoLine(1)
	EndIf
	
	oView:Refresh()

	FwRestRows(aSaveLn)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202VLOCS()
Volta ao valor orginal do desconto nos Casos da pré-fatura

@author Luciano Pereira dos Santos
@since 23/12/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA202VLOCS(oModel)
Local lRet      := .T.
Local oModelNX1 := oModel:GetModel( 'NX1DETAIL' )
Local nVlHon    := oModelNX1:GetValue("NX1_VTS")
Local nDescEsp  := oModelNX1:GetValue( "NX1_VLDESC" )
Local nPDescH   := 0
Local nDescLin  := 0

nPDescH := oModelNX1:GetValue('NX1_PDESCH') 

nDescLin := nVlHon * (nPDescH / 100.00)

IIF(lRet, lRet := J202LoadVl(oModelNX1, "NX1_VDESCO", nDescLin), )
IIF(lRet, lRet := J202LoadVl(oModelNX1, "NX1_PDESCH", nPDescH), )
IIF(lRet, lRet := J202LoadVl(oModelNX1, "NX1_VDESCT", (nDescEsp + nDescLin)), )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202TEMPO
Rotina para verificar se o Ts tem participação do cliente.
Retorna .T. se NÃO tiver participação.

@Param lShowMsg  .T. exibe mensagem
@Param cAtivi    codigo de tipo de atividade

@Return .T. se NÃO tiver participação.

@author Luciano Pereira dos Santos
@since 07/01/17
@version 2.0
/*/
//-------------------------------------------------------------------
Static Function JA202TEMPO( lShowMsg, cAtivi )
Local lRet       := .T.
Default lShowMsg := .T.
Default cAtivi   := ""

If J202ATIVID('1', cAtivi) == "1"
	lRet  := .F.
	If lShowMsg
		JurMsgErro( STR0090 ) //"Não é permitida alteração de tempo para tipo de atividade de participação direta."
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202TEMPOZ
Rotina para verificar se a atividade é cobravel

@Param cAtivi    Código de tipo de atividade

@Return .T. é atividade cobravel.

@author Luciano Pereira dos Santos
@since 07/01/17
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202TEMPOZ(cAtivi)
Local lRet       := .T.

lRet := J202ATIVID('2', cAtivi) == "1"

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202ALTDES
Valida alteracao do valor da despesa

@author Daniel Magalhaes
@since 09/09/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202ALTDES( oModelNVY )
Local lRet := Empty(oModelNVY:GetValue("NVY_CDETRT")) .And. (oModelNVY:GetValue("NVY_SITUAC") == "1")

Return lRet

Static Function JA202CPYMD( oModel, lQuery )
Local aArea    := GetArea()
Local cAlias   := GetNextAlias()
Local cCasoAnt := ""
Local cQuery   := ""
Local nCt      := 0
Local nX       := 0

Local aSaveLines := FwSaveRows()
Local nNX1
Local nNX2
Local nNX8
Local oModelNX0  := oModel:GetModel( 'NX0MASTER' )
Local oModelNX1  := oModel:GetModel( "NX1DETAIL" )
Local oModelNX2  := oModel:GetModel( "NX2DETAIL" )
Local oModelNX8  := oModel:GetModel( "NX8DETAIL" )
Local nLnNX8_OLD
Local nLnNX1_OLD
Local nLnNX2_OLD
Local oAux       := Nil

Local lIsRest    := Iif(FindFunction("JurIsRest"), JurIsRest(), .F.)

Default lQuery   := .F.

If lQuery
	aCasos := {}
	aPart    := {}
	cQuery +=  "SELECT NX8_CCONTR, NX1_FILIAL, NX1_CCLIEN, NX1_CLOJA, NX1_CCASO, NX1_VDESP, NX1_VTAB, NX1_VTS, NX1_PDESCH, "
	cQuery +=        " NX1_VLDESC, NX1_TS, NX2_CPART, NX2_VALORH, NX2_VALOR1, NX2_UTR, NX2_TEMPOR, NX2_HORAR, NX2_CODSEQ, "
	cQuery +=        " NX2_CLTAB, NX2_CCATEG, NX2_UTLANC, NX2_HFLANC, NX2_HRLANC, NX2_UTCLI, NX2_HFCLI, NX2_HRCLI, NX2_CMOTBH"
	cQuery +=   " FROM " + RetSqlName( "NX8" ) + " NX8 "
	cQuery +=  " INNER JOIN " + RetSqlName( "NX1" ) + " NX1 "
	cQuery +=     " ON NX1_FILIAL = '" + xFilial( "NX8 " ) + "'"
	cQuery +=    " AND NX1_CPREFT = NX8_CPREFT"
	cQuery +=    " AND NX1_CCONTR = NX8_CCONTR"
	cQuery +=    " AND NX1.D_E_L_E_T_ = ' '"
	cQuery +=  " LEFT JOIN " + RetSqlName( "NX2" ) + " NX2 "
	cQuery +=     " ON NX2_FILIAL = '" + xFilial( "NX2" ) + "'"
	cQuery +=    " AND NX2_CPREFT = NX8_CPREFT"
	cQuery +=    " AND NX2_CCONTR = NX8_CCONTR"
	cQuery +=    " AND NX2_CCASO  = NX1_CCASO"
	cQuery +=    " AND NX2.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE NX8_FILIAL = '" + xFilial( "NX1" ) + "'"
	cQuery +=    " AND NX8_CPREFT = '" + oModel:GetValue( "NX0MASTER", "NX0_COD" ) + "'"
	cQuery +=    " AND NX8.D_E_L_E_T_ = ' '"

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAlias, .T., .T. )

	While !(cAlias)->( EOF() )

		cCasoAnt := (cAlias)->( NX1_FILIAL + NX1_CCLIEN + NX1_CLOJA + NX1_CCASO )

		AAdd( aCasos, { ;
		(cAlias)->NX1_CCLIEN, (cAlias)->NX1_CLOJA , (cAlias)->NX1_CCASO  , ;
		(cAlias)->NX1_VDESP , (cAlias)->NX1_VTAB  , (cAlias)->NX1_VTS    , ;
		(cAlias)->NX1_PDESCH, (cAlias)->NX1_VLDESC, (cAlias)->NX8_CCONTR } )

		nCt := 0

		While !(cAlias)->( EOF() ) .And. cCasoAnt == (cAlias)->( NX1_FILIAL + NX1_CCLIEN + NX1_CLOJA + NX1_CCASO )
			nCt++
			If (cAlias)->NX1_TS == '1' .And. !Empty( (cAlias)->NX2_CPART )
				AAdd( aPart, { ;
				(cAlias)->NX1_CCLIEN, (cAlias)->NX1_CLOJA , (cAlias)->NX1_CCASO  , ; // [3]
				(cAlias)->NX2_CPART , (cAlias)->NX2_VALORH, (cAlias)->NX2_VALOR1 , ; // [6]
				(cAlias)->NX2_UTR   , (cAlias)->NX2_TEMPOR, (cAlias)->NX2_HORAR  , ; // [9]
				(cAlias)->NX2_CODSEQ, nCt                 , .F.                  , ; //[12]
				(cAlias)->NX2_CLTAB , (cAlias)->NX2_CCATEG, (cAlias)->NX2_UTLANC , ; //[15]
				(cAlias)->NX2_HFLANC, (cAlias)->NX2_HRLANC, (cAlias)->NX2_UTCLI  , ; //[18]
				(cAlias)->NX2_HFCLI , (cAlias)->NX2_HRCLI , (cAlias)->NX2_CMOTBH } ) //[20]
			EndIf

			(cAlias)->( dbSkip() )
		End

	End

	(cAlias)->( dbCloseArea() )

Else

	aCasos := {}
	aPart  := {}

	nLnNX8_OLD := oModelNX8:GetLine()
	For nNX8 := 1 To oModelNX8:Length()

		oModelNX8:GoLine( nNX8 )

		nLnNX1_OLD := oModelNX1:GetLine()
		For nNX1 := 1 To oModelNX1:Length()

			oModelNX1:GoLine( nNX1 )

			AAdd( aCasos, { ;
			oModelNX1:GetValue( "NX1_CCLIEN" ), oModelNX1:GetValue( "NX1_CLOJA" ) , oModelNX1:GetValue( "NX1_CCASO" ), ;
			oModelNX1:GetValue( "NX1_VDESP" ) , oModelNX1:GetValue( "NX1_VTAB" )  , oModelNX1:GetValue( "NX1_VTS" )  , ;
			oModelNX1:GetValue( "NX1_PDESCH" ), oModelNX1:GetValue( "NX1_VLDESC" ), oModelNX1:GetValue( "NX1_CCONTR" ) } )

			If oModelNX1:GetValue( 'NX1_TS' ) == '1'

				nLnNX2_OLD := oModelNX2:GetLine()
				For nNX2 := 1 To oModelNX2:Length()

					oModelNX2:GoLine( nNX2 )

					AAdd( aPart, { ;
					oModelNX1:GetValue( "NX1_CCLIEN" ), oModelNX1:GetValue( "NX1_CLOJA" ) , oModelNX1:GetValue( "NX1_CCASO" )   , ;  // [3]
					oModelNX2:GetValue( "NX2_CPART" ) , oModelNX2:GetValue( "NX2_VALORH" ), oModelNX2:GetValue( "NX2_VALOR1" )  , ;  // [6]
					oModelNX2:GetValue( "NX2_UTR" )   , oModelNX2:GetValue( "NX2_TEMPOR" ), oModelNX2:GetValue( "NX2_HORAR" )   , ;  // [9]
					oModelNX2:GetValue( "NX2_CODSEQ" ), oModelNX2:nLine                   , .F.                                 , ;  //[12]
					oModelNX2:GetValue( "NX2_CLTAB" ) , oModelNX2:GetValue( "NX2_CCATEG" ), oModelNX2:GetValue( "NX2_UTLANC" )  , ;  //[15]
					oModelNX2:GetValue( "NX2_HFLANC" ), oModelNX2:GetValue( "NX2_HRLANC" ), oModelNX2:GetValue( "NX2_UTCLI" )   , ;  //[18]
					oModelNX2:GetValue( "NX2_HFCLI" ) , oModelNX2:GetValue( "NX2_HRCLI" ) , oModelNX2:GetValue( "NX2_CMOTBH" ) } )   //[20]

				Next
				oModelNX2:GoLine(nLnNX2_OLD)
			EndIf
		Next
		oModelNX1:GoLine(nLnNX1_OLD)
	Next
	oModelNX8:GoLine(nLnNX8_OLD)

EndIf

If oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. !lIsRest .And. Len( __aGridPos ) > 0 .And. !ISINCALLSTACK('JA202CM') .And. ( oModelNX0:GetValue( 'NX0_COD' ) == __cLastPFat )
	For nX := 1 To Len( __aGridPos )
		oAux:= __aGridPos[nX][1]
		If __aGridPos[nX][2] <= oAux:Length()
			oAux:GoLine( __aGridPos[nX][2] )
		EndIf
	Next
Else
	FwRestRows( aSaveLines )
EndIf

RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA202
Operação da Pré-Fatura

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202NX2W(cCampo)
Local nTipoApon  := SuperGetMV( 'MV_JURTS2',, 1 )
Local lRet       := .F.

If nTipoApon == 1 .And. Alltrim(cCampo) $ 'NX2_UTL / NX2_UTR'
	lRet := .T.
ElseIf nTipoApon == 2 .And. Alltrim(cCampo) $ 'NX2_TEMPOL / NX2_TEMPOR'
	lRet := .T.
ElseIf nTipoApon == 3 .And. Alltrim(cCampo) $ 'NX2_HORAL / NX2_HORAR'
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202DESCS
Função usada no dicionário para trazer as descrições.

@Param cCampo  Campo de descrição para preenchimento

@author David G. Fernandes
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202DESCS(cCampo)
Local cRet      := ""
Local cIdioma   := ""
Local oModelNX0 := Nil
Local oModelNX1 := Nil

cCampo := AllTrim(cCampo)

	Do Case

		Case "NX0_DTPHON" $ cCampo
			cRet := Posicione("NT0", 1, xFilial("NT0") + NX0->NX0_CCONTR , "NT0_CTPHON" )
			cRet := Posicione("NRA", 1, xFilial("NRA") + cRet            , "NRA_DESC" )

		Case "NX8_CTPHON" $ cCampo
			cRet := Posicione("NT0", 1, xFilial("NT0") + NX8->NX8_CCONTR , "NT0_CTPHON" )

		Case "NX8_DTPHON" $ cCampo
			cRet := Posicione("NT0", 1, xFilial("NT0") + NX8->NX8_CCONTR , "NT0_CTPHON" )
			cRet := Posicione("NRA", 1, xFilial("NRA") + cRet            , "NRA_DESC" )

		Case "NX8_TPCOBH" $ cCampo
			cRet := Posicione("NT0", 1, xFilial("NT0") + NX8->NX8_CCONTR , "NT0_CTPHON" )
			cRet := Posicione("NRA", 1, xFilial("NRA") + cRet            , "NRA_COBRAH" )

		Case "NX8_TPCOBF" $ cCampo
			cRet := Posicione("NT0", 1, xFilial("NT0") + NX8->NX8_CCONTR , "NT0_CTPHON" )
			cRet := Posicione("NRA", 1, xFilial("NRA") + cRet            , "NRA_COBRAF" )

		Case "NX8_TPNCOB" $ cCampo
			cRet := Posicione("NT0", 1, xFilial("NT0") + NX8->NX8_CCONTR , "NT0_CTPHON" )
			cRet := Posicione("NRA", 1, xFilial("NRA") + cRet            , "NRA_NCOBRA" )

		Case "NX1_DCASO" $ cCampo
			cRet := Posicione('NVE', 1, xFilial('NVE') + NX1->(NX1_CCLIEN + NX1_CLOJA + NX1_CCASO), 'NVE_TITULO')

		Case "NX1_DJCONT" $ cCampo
			If !Empty(NX1->NX1_CJCONT)
				cRet := Posicione('NW2', 1, xFilial('NW2') + NX1->NX1_CJCONT, 'NW2_DESC')
			EndIf

		Case "NX1_DTPREL" $ cCampo
			If !Empty(NX1->NX1_CTPREL)
				cRet := Posicione('NRJ', 1, xFilial('NRJ') + NX1->NX1_CTPREL, 'NRJ_DESC')
			EndIf

		Case "NX1_DRETRV" $ cCampo
			If !Empty(NX1->NX1_RETREV)
				cRet := Posicione('NSC', 1, xFilial('NSC') + NX1->NX1_RETREV, 'NSC_DESC')
			EndIf

		Case "NX2_DCATEG" $ cCampo
			cIdioma := Posicione("NT0", 1, xFilial("NT0") + NX2->NX2_CCONTR, "NT0_CIDIO" )
			cRet    := Posicione("NR2", 3, xFilial("NR2") + NX2->NX2_CCATEG + cIdioma, "NR2_DESC" )

		Case "NX2_DCLIEN" $ cCampo
			oModel    := FWModelActive()
			If oModel != Nil .And. oModel:GetId() == "JURA202"
				oModelNX1 := oModel:GetModel('NX1DETAIL')
				cRet      := oModelNX1:GetValue('NX1_DCLIEN')
			Else
				cRet := Posicione("SA1", 1, xFilial("SA1") + NX2->NX2_CCLIEN + NX2->NX2_CLOJA, 'A1_NOME')
			EndIf

		Case "NX2_DCONTR" $ cCampo
			oModel    := FWModelActive()
			If oModel != Nil .And. oModel:GetId() == "JURA202"
				oModelNX1 := oModel:GetModel('NX1DETAIL')
				cRet      := oModelNX1:GetValue('NX1_DCONTR')
			Else
				cRet := Posicione("NT0", 1, xFilial("NT0") + NX2->NX2_CCONTR, "NT0_NOME" )
			EndIf

		Case "NX2_DCASO" $ cCampo
			oModel    := FWModelActive()
			If oModel != Nil .And. oModel:GetId() == "JURA202"
				oModelNX1 := oModel:GetModel('NX1DETAIL')
				cRet      := oModelNX1:GetValue('NX1_DCASO')
			Else
				cRet := Posicione("NVE", 1, xFilial("NVE") + NX2->(NX2_CCLIEN + NX2_CLOJA + NX2_CCASO), "NVE_TITULO" )
			EndIf

		Case "NX2_DMOPRE" $ cCampo
			oModel    := FWModelActive()
			If oModel != Nil .And. oModel:GetId() == "JURA202"
				oModelNX0 := oModel:GetModel('NX0MASTER')
				cRet      := oModelNX0:GetValue('NX0_DMOEDA')
			Else
				cRet := Posicione("CTO", 1, xFilial("CTO") + NX2->NX2_CMOPRE, "CTO_SIMB" )
			EndIf

	Otherwise
		cRet := ""
	End Case

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202Filtro
Filtra os lançamentos pendentes para permitir que sejam associados a pré-fatura

@Param    cAlias     Alias para geração: NUE, NV4 ou NVY
@Param    cCodLanc   Código do Lançamento, caso deseje filtrar por um Lançamento em específico,
                     usado na J202DTTS/JVldVinPre
@Param    cPreFat    Código da Pré-fatura (usado na J202DTTS/JVldVinPre)
@Param    cTabTmpLD  Tabela temporária para geração (usado para vínculo de lanctos na pré via LD)
                     Usada para substituir a tabela padrão de lançamento.
                     A query será realizada na tabela temporária caso tenha sido passada por parâmetro

@Return   aRet Array contendo:
                      [n][1] FWTemporaryTable
                      [n][2] Campos da tabela para o FWFormBrowse e FwMarkBrowse
                      [n][3] Index para o Browse
                      [n][4] Campos da tabela para o FwMarkBrowse

@author David G. Fernandes
@since 25/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J202Filtro(cAlias, cCodLanc, cPreFat, cTabTmpLD)
Local cQry           := ""
Local dDIniTS        := ""
Local dDFimTS        := ""
Local cJContr        := ""
Local lLimExc        := SuperGetMv("MV_JLIMEXC", .F., "2" ) == "1" //Indica se emite pré-fatura para Contratos com o limite geral excedido? (1-Sim; 2-Não)
Local aArea          := GetArea()
Local aAreaNX0       := NX0->(GetArea())
Local cDIniDP        := ""
Local cDFimDP        := ""
Local cDIniTB        := ""
Local cDFimTB        := ""
Local cContr         := ""
Local aRet           := {}
Local cCampos        := JurCmpSelc(cAlias)
Local cCamposJL      := ''
Local aCamposJL      := {}
Local aStruAdic      := {}
Local aCmpNotBrw     := {cAlias + "_ACAOLD", cAlias + "_CCLILD", cAlias + "_CLJLD", cAlias + "_CCSLD", cAlias + "_PARTLD", cAlias + "_CDWOLD", cAlias + "_CMOTWO"}
Local cTabTmpVig     := ""
Local cTabLanc       := ""
Local lCpoFxNc       := NX0->(ColumnPos("NX0_FXNC")) > 0
Local lPreTSFxNc     := lCpoFxNc .And. NX0->NX0_FXNC == "1" // Indica que é uma pré de Ts de contrato fixo ou não cobrável

Default cCodLanc     := ""
Default cPreFat      := ""
Default cTabTmpLD    := ""

dbSelectArea("NX0")

If cPreFat == ""
	cPreFat := NX0->NX0_COD
Else
	NX0->(dbSetOrder(1)) //NX0_FILIAL+NX0_COD+NX0_SITUAC
	NX0->(dbSeek(xFilial('NX0') + cPreFat))
EndIf

dDIniTS := IIF(lPreTSFxNc, NX0->NX0_DIFXNC, NX0->NX0_DINITS)
dDFimTS := IIF(lPreTSFxNc, NX0->NX0_DFFXNC, NX0->NX0_DFIMTS)
cDIniDP := NX0->NX0_DINIDP
cDFimDP := NX0->NX0_DFIMDP
cDIniTB := NX0->NX0_DINITB
cDFimTB := NX0->NX0_DFIMTB
cContr  := NX0->NX0_CCONTR
cJContr := NX0->NX0_CJCONT

cTabTmpVig := J202TmpVig(cPreFat, cJContr) // Cria tabela temporária de controle de vigência de contrato

If cAlias == "NUE"
	cQry := J202FilNUE(cTabTmpLD, cTabTmpVig, cPreFat, cCodLanc, dDIniTS, dDFimTS, lPreTSFxNc)

	AAdd(aCmpNotBrw, "NUE_CRETIF")
	AAdd(aCmpNotBrw, "NUE_CDOC"  )
	AAdd(aCmpNotBrw, "NUE_CFASE" )
	AAdd(aCmpNotBrw, "NUE_CTAREB")

ElseIf cAlias == "NVY"

	cTabLanc := Iif(Empty(cTabTmpLD), RetSqlName( 'NVY' ), cTabTmpLD )
	cCampos  := StrTran(cCampos, "NVY_OK    ,")
	Aadd(aCamposJL,{"ACY.ACY_DESCRI" , "NVY_DGRUPO" })
	Aadd(aCamposJL,{"SA1.A1_NOME"    , "NVY_DCLIEN" })
	Aadd(aCamposJL,{"NVE.NVE_TITULO" , "NVY_DCASO" })
	Aadd(aCamposJL,{"RD0.RD0_SIGLA"  , "NVY_SIGLA" })
	Aadd(aCamposJL,{"NR4.NR4_DESC"   , "NVY_DTPDSP" })
	cCamposJL := JurCaseJL(aCamposJL)

	cQry := "SELECT DISTINCT "+ cCampos + cCamposJL
	cQry += " ' ' NVY_OK"
	cQry +=   " FROM " +cTabLanc+ " NVY "
	cQry += " LEFT JOIN "+ RetSqlName( 'NRH' ) + " NRH "
	cQry +=                                         " ON NRH.NRH_FILIAL = '" + xFilial("NRH") + "' "
	cQry +=                                         " AND NRH.NRH_COD = NVY.NVY_CTPDSP "
	cQry +=                                         " AND NRH.D_E_L_E_T_ = ' ' "
	cQry += " LEFT JOIN "+ RetSqlName( 'ACY' ) + " ACY "
	cQry +=                                         " ON ACY.ACY_FILIAL = '" + xFilial("ACY") + "' "
	cQry +=                                         " AND ACY.ACY_GRPVEN = NVY.NVY_CGRUPO "
	cQry +=                                         " AND ACY.D_E_L_E_T_ = ' ' "
	cQry += " INNER JOIN "+ RetSqlName( 'SA1' ) + " SA1 "
	cQry +=                                         " ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQry +=                                         " AND SA1.A1_COD  = NVY.NVY_CCLIEN "
	cQry +=                                         " AND SA1.A1_LOJA = NVY.NVY_CLOJA "
	cQry +=                                         " AND SA1.D_E_L_E_T_ = ' ' "
	cQry += " INNER JOIN "+ RetSqlName( 'NVE' ) + " NVE "
	cQry +=                                         " ON NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
	cQry +=                                         " AND NVE.NVE_CCLIEN = NVY.NVY_CCLIEN "
	cQry +=                                         " AND NVE.NVE_LCLIEN = NVY.NVY_CLOJA "
	cQry +=                                         " AND NVE.NVE_NUMCAS = NVY.NVY_CCASO "
	cQry +=                                         " AND NVE.NVE_ENCDES = '2' "
	cQry +=                                         " AND NVE.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND NVE.NVE_COBRAV = '1' "
	cQry += " LEFT JOIN "+ RetSqlName( 'RD0' ) + " RD0 "
	cQry +=                                         " ON RD0.RD0_FILIAL = '" + xFilial("RD0") + "' "
	cQry +=                                         " AND RD0.RD0_CODIGO = NVY.NVY_CPART "
	cQry +=                                         " AND RD0.D_E_L_E_T_ = ' ' "
	cQry += " LEFT JOIN "+ RetSqlName( 'NR4' ) + " NR4 "
	cQry +=                                         " ON NR4.NR4_FILIAL = '" + xFilial("NR4") + "' "
	cQry +=                                         " AND NR4.NR4_CTDESP = NVE.NVE_CIDIO "
	cQry +=                                         " AND NR4.NR4_CIDIOM = NVY.NVY_CPART "
	cQry +=                                         " AND NR4.D_E_L_E_T_ = ' ' "
	cQry += " INNER JOIN "+ RetSqlName( 'NUT' ) + " NUT "
	cQry +=                                          " ON NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
	cQry +=                                         " AND NUT.NUT_CCLIEN = NVY.NVY_CCLIEN "
	cQry +=                                         " AND NUT.NUT_CLOJA = NVY.NVY_CLOJA "
	cQry +=                                         " AND NUT.NUT_CCASO = NVY.NVY_CCASO "
	cQry +=                                         " AND NUT.D_E_L_E_T_ = ' ' "
	cQry += J202VigCtr("NVY.NVY_DATA", cDIniDP, cDFimDP, cTabTmpVig, "NVY")

	cQry += " INNER JOIN " + RetSqlName("NT0") + " NT0 "
	cQry +=   " ON NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
	cQry +=   " AND NT0.NT0_COD = NUT_CCONTR "
	cQry +=   " AND NT0.NT0_ATIVO  = '1' "
	cQry +=   " AND NT0.NT0_SIT    = '2' "
	cQry +=   " AND NT0.NT0_ENCD = '2' "
	cQry +=   " AND NT0.NT0_DESPES = '1' "
	cQry +=   " AND NT0.D_E_L_E_T_ = ' ' "

	cQry += " WHERE NVY.NVY_FILIAL = '"+ xFilial("NVY") +"' "
	cQry += Iif(Empty(cCodLanc), "" , " AND NVY.NVY_COD = '" + cCodLanc + "' " )
	cQry +=   " AND NVY.NVY_CPREFT = '"+Space(TamSx3('NVY_CPREFT')[1])+"' "
	cQry +=     " AND NVY.D_E_L_E_T_ = ' ' "
	cQry +=     " AND NVY.NVY_SITUAC = '1' "
	cQry +=     " AND NVY.NVY_COBRAR = '1' "
	cQry +=     " AND NRH.NRH_COD    = NVY.NVY_CTPDSP "
	cQry +=     " AND NRH.NRH_COBRAR = '1' " //Despesas cobravel no Tipo de Despesa

	cQry += " AND NOT EXISTS ( SELECT NTK.R_E_C_N_O_ "   //Despesas cobravel no Contrato
	cQry +=                     " FROM  " + RetSqlName("NTK") + " NTK "
	cQry +=                    " WHERE NTK.NTK_FILIAL = '" + xFilial("NTK") +"' "
	cQry +=                      " AND NTK.NTK_CCONTR = NT0.NT0_COD "
	cQry +=                      " AND NTK.NTK_CTPDSP = NVY.NVY_CTPDSP "
	cQry +=                      " AND NTK.D_E_L_E_T_ = ' ' ) "
	
	If ExistBlock('J201BDPF')
		cQry += " AND " + ExecBlock('J201BDPF', .F., .F.)
	EndIf

ElseIf cAlias == "NV4"

	cTabLanc := Iif(Empty(cTabTmpLD), RetSqlName( 'NV4' ), cTabTmpLD )
	cCampos  := StrTran(cCampos, "NV4_OK    ,")
	Aadd(aCamposJL,{"ACY.ACY_DESCRI" , "NV4_DGRUPO" })
	Aadd(aCamposJL,{"SA1.A1_NOME"    , "NV4_DCLIEN" })
	Aadd(aCamposJL,{"NVE.NVE_TITULO" , "NV4_DCASO"  })
	Aadd(aCamposJL,{"RD0.RD0_SIGLA"  , "NV4_SIGLA"  })
	Aadd(aCamposJL,{"RD0.RD0_NOME"   , "NV4_DPART"  })
	Aadd(aCamposJL,{"CTOH.CTO_SIMB"  , "NV4_DMOEH"  })
	Aadd(aCamposJL,{"CTOD.CTO_SIMB"  , "NV4_DMOED"  })
	Aadd(aCamposJL,{"NR3.NR3_DESCHO" , "NV4_DTPSRV" })

	cCamposJL := JurCaseJL(aCamposJL)

	cQry := "SELECT DISTINCT "+ cCampos + cCamposJL
	cQry += " ' ' NV4_OK"
	cQry +=     " FROM " +cTabLanc+ " NV4 "
	cQry += " LEFT JOIN "+ RetSqlName( 'ACY' ) + " ACY "
	cQry +=                                         " ON ACY.ACY_FILIAL = '" + xFilial("ACY") + "' "
	cQry +=                                         " AND ACY.ACY_GRPVEN = NV4.NV4_CGRUPO "
	cQry +=                                         " AND ACY.D_E_L_E_T_ = ' ' "
	cQry += " INNER JOIN "+ RetSqlName( 'SA1' ) + " SA1 "
	cQry +=                                         " ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQry +=                                         " AND SA1.A1_COD = NV4.NV4_CCLIEN "
	cQry +=                                         " AND SA1.A1_LOJA = NV4.NV4_CLOJA "
	cQry +=                                         " AND SA1.D_E_L_E_T_ = ' ' "
	cQry += " INNER JOIN "+ RetSqlName( 'NVE' ) + " NVE "
	cQry +=                                         " ON NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
	cQry +=                                         " AND NVE.NVE_CCLIEN = NV4.NV4_CCLIEN "
	cQry +=                                         " AND NVE.NVE_LCLIEN = NV4.NV4_CLOJA "
	cQry +=                                         " AND NVE.NVE_NUMCAS = NV4.NV4_CCASO "
	cQry +=                                         " AND NVE.NVE_ENCTAB = '2' "
	cQry +=                                         " AND NVE.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND NVE.NVE_COBRAV = '1' "
	cQry += " INNER JOIN " + RetSqlName( 'NUT' ) + " NUT "
	cQry +=                                     " ON NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
	cQry +=                                     " AND NUT.NUT_CCLIEN = NVE.NVE_CCLIEN "
	cQry +=                                     " AND NUT.NUT_CLOJA = NVE.NVE_LCLIEN "
	cQry +=                                     " AND NUT.NUT_CCASO = NVE.NVE_NUMCAS "
	cQry +=                                     " AND NUT.D_E_L_E_T_ = ' ' "
	cQry += J202VigCtr("NV4.NV4_DTCONC", cDIniTB, cDFimTB, cTabTmpVig, "NV4")
	
	cQry += " INNER JOIN " + RetSqlName("NT0") + " NT0 "
	cQry +=   " ON NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
	cQry +=   " AND NT0.NT0_COD = NUT_CCONTR "
	cQry +=   " AND NT0.NT0_ATIVO  = '1' "
	cQry +=   " AND NT0.NT0_SIT    = '2' "
	cQry +=   " AND NT0.NT0_ENCT = '2' "
	cQry +=   " AND NT0.NT0_SERTAB = '1' "
	cQry +=   " AND NT0.D_E_L_E_T_ = ' ' "

	cQry += " INNER JOIN "+ RetSqlName( 'RD0' ) + " RD0 "
	cQry +=                                         " ON RD0.RD0_FILIAL = '" + xFilial("RD0") + "' "
	cQry +=                                         " AND RD0.RD0_CODIGO = NV4.NV4_CPART "
	cQry +=                                         " AND RD0.D_E_L_E_T_ = ' ' "
	cQry += " INNER JOIN "+ RetSqlName( 'CTO' ) + " CTOH"
	cQry +=                                         " ON CTOH.CTO_FILIAL = '" + xFilial("CTO") + "' "
	cQry +=                                         " AND CTOH.CTO_MOEDA = NV4.NV4_CMOEH "
	cQry +=                                         " AND CTOH.D_E_L_E_T_ = ' ' "
	cQry += " LEFT JOIN "+ RetSqlName( 'CTO' ) + " CTOD"
	cQry +=                                         " ON CTOD.CTO_FILIAL = '" + xFilial("CTO") + "' "
	cQry +=                                         " AND CTOD.CTO_MOEDA = NV4.NV4_CMOED "
	cQry +=                                         " AND CTOD.D_E_L_E_T_ = ' ' "
	cQry += " LEFT JOIN "+ RetSqlName( 'NR3' ) + " NR3 "
	cQry +=                                         " ON NR3.NR3_FILIAL = '" + xFilial("NR3") + "' "
	cQry +=                                         " AND NR3.NR3_CITABE = NV4.NV4_CTPSRV "
	cQry +=                                         " AND NR3.NR3_CIDIOM = NVE.NVE_CIDIO "
	cQry +=                                         " AND NR3.D_E_L_E_T_ = ' ' "
	cQry +=    " WHERE NV4.NV4_FILIAL = '"+ xFilial("NV4") +"' "
	cQry += Iif(Empty(cCodLanc), "" , " AND NV4.NV4_COD = '" + cCodLanc + "' " )
	cQry +=      " AND NV4.D_E_L_E_T_ = ' ' "
	cQry +=      " AND NV4.NV4_CPREFT = '" + Space(TamSx3('NV4_CPREFT')[1]) + "' "
	cQry +=      " AND NV4.NV4_CONC = '1' "
	cQry +=      " AND NV4.NV4_SITUAC = '1' "
	cQry +=      " AND NV4.NV4_COBRAR = '1' "

EndIf

If !Empty(cQry)
	//---------------------------------------------------------------
	// Inclusão de TS via LD não precisa criar tabela temporária mas
	// se a função J202Limite precisar ser executada é necessário
	// criar tabela temporária para avaliar o limite.
	// Observação: FwIsInCallStack("JVldVinPre") -> Caso o vinculo for via LD sempre deverá ser criada a tabela temporária para não ocorrer
	//             o problema de não criar as tabelas de faturamento ('NW0','NVZ','NW4)
	//---------------------------------------------------------------
	If cAlias == "NUE" .And. !Empty(cTabTmpLD) .And. lLimExc .And. !FwIsInCallStack("JVldVinPre")
		aRet := JurSql(cQry, "NUE_COD")
	Else
		aRet := JurCriaTmp(GetNextAlias(), cQry, cAlias, , aStruAdic, , aCmpNotBrw)
	EndIf

	If !lLimExc .And. (cAlias == "NUE" .Or. cAlias == "NV4")
		// Retirada dos TSs e TBs que fazem parte de contratos que excederam o limite geral
		J202Limite(aRet[1], cAlias)
	EndIf
EndIf

RestArea(aAreaNX0)
RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202Limite
Retirada dos TS's e TB's que fazem parte de contratos que excederam o limite geral

@param   oTmpTable, objeto   , Tabela temporária com lançamentos
@param   cNomeTab , caractere, Alias da tabela do lançamento (NUE - NV4)

@author  Luciano Pereira / Jonatas Martins
@since   21/11/2018
@version 1.0
/*/
//--------------------------------------
Static Function J202Limite(oTmpTable, cTab)
	Local cAliasTmp  := ""
	Local cContrAux  := "" //Contratos que estão com limite excedido e devem ser retirados
	Local nSaldo     := 0
	Local aLimite    := {}
	Local lRetira    := .F.
	Local cMoeLm     := ""
	Local nVlrLm     := 0
	Local cLTLim     := ""
	Local cContr     := ""

	cAliasTmp := oTmpTable:GetAlias()
	(cAliasTmp)->(DbGoTop())
	While (cAliasTmp)->(!EOF())
		lRetira := .F.
		aLimite := J202ContrLm((cAliasTmp)->&(cTab + '_CCLIEN'), (cAliasTmp)->&(cTab + '_CLOJA'), (cAliasTmp)->&(cTab + '_CCASO'))
		If Len(aLimite) == 4
			cMoeLm := aLimite[1]
			nVlrLm := aLimite[2]
			cLTLim := aLimite[3]
			cContr := aLimite[4]
		EndIf

		If !(cContr $ cContrAux)
			//Verifica se valida limite para tabelado
			If !Empty(cMoeLm) .And. !Empty(nVlrLm) .And. (cTab == "NUE" .Or. cLTLim == "1")
				nSaldo := J201GSldLm(cContr, '2') //retorna o Valor Disponível
				If nSaldo <= 0
					cContrAux += cContr + "|"
					lRetira := .T.
				EndIf
			EndIf
		Else
			lRetira := .T.
		EndIf

		If lRetira
			RecLock(cAliasTmp, .F.)
			(cAliasTmp)->(DbDelete())
			(cAliasTmp)->(MsUnLock())
			(cAliasTmp)->(DbCommit())
		EndIf
		(cAliasTmp)->(DbSkip())
	EndDo
	(cAliasTmp)->(DbGoTop())

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J202ContrLm
Query para considerar vigência dos contratos da pré-fatura
no vínculo de novos lançamentos

@Param  cCliente  , Código do cliente do lançamento
@Param  cLoja     , Código da loja do cliente do lançamento
@Param  cDacCaso  , Código do caso do lançamento

@Return  aLimite  , array com as informações de limite do contrato do lançamento.

@author  Luciano Pereira / Jonatas Martins
@since   21/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202ContrLm(cCliente, cLoja, cCaso)
	Local aLimite := {}
	Local cContr  := ""

	cContr  := JurGetDados('NUT', 2, xFilial('NUT') + cCliente + cLoja + cCaso, 'NUT_CCONTR')
	aLimite := JurGetDados("NT0", 1, xFilial("NT0") + cContr, {"NT0_CMOELI", "NT0_VLRLI", "NT0_CTBCVL", "NT0_COD"})

Return aLimite

//-------------------------------------------------------------------
/*/{Protheus.doc} J202VigCtr
Query para considerar vigência dos contratos da pré-fatura
no vínculo de novos lançamentos

@Param  cCampo     , Campo de filtro de data do lançamento
@Param  dDataIni   , Data inicial do filtro
@Param  dDataFim   , Data final do filtro
@Param  cTabTmpVig , Nome da Tabela Temp. de controle de vigência
@Param  cTabela    , Alias para geração: NUE, NV4 ou NVY

@Return  cQryVig, caracatere, Query considerando vigência do contrato da pré-fatura

@author  Luciano Pereira / Jonatas Martins
@since   14/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202VigCtr(cCampo, dDataIni, dDataFim, cTabTmpVig, cTabela)
	Local cQryVig   := ""
	Local cSpaceDT  := Space(8)

	Default cTabela := ""

	If !Empty(cTabela)
		cQryVig += " INNER JOIN " + cTabTmpVig + " TMP "
		cQryVig +=    " ON TMP.NX8_FILIAL = '" + xFilial("NUT") + "' "
		cQryVig +=   " AND TMP.NX8_CCONTR = NUT.NUT_CCONTR "
	EndIf

	If NT0->(ColumnPos("NT0_DTVIGI")) > 0
		cQryVig +=   " AND " + cCampo + " >= (CASE WHEN TMP.NX8_DTVIGI > '" + cSpaceDT + "' AND TMP.NX8_DTVIGI > '" + DtoS(dDataIni) + "' THEN TMP.NX8_DTVIGI ELSE '" + DtoS(dDataIni) + "' END) "
		cQryVig +=   " AND " + cCampo + " <= (CASE WHEN TMP.NX8_DTVIGF > '" + cSpaceDT + "' AND TMP.NX8_DTVIGF < '" + DtoS(dDataFim) + "' THEN TMP.NX8_DTVIGF ELSE '" + DtoS(dDataFim) + "' END) "
	Else
		cQryVig +=   " AND " + cCampo + " BETWEEN '" + DtoS(dDataIni) + "' AND '" + DtoS(dDataFim) + "' "
	EndIf

Return (cQryVig)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202REFAZ
Reemite a pré-fatura alterada

@Param  cCPreFt,    Código da pré-fatura a ser refeita
@Param  lResumo,    Indica se a chamada é da rotina de Resumo
@Param  cResult,    Tipo de impressão:
                    1 - Impressora
                    2 - Tela
                    3 - Word
                    4 - Nenhum
@Param  cCrysPath,  Caminho dos arquivos exportados do Crystal
@Param  lAutomato,  Indica se a chamada é feita via automação
@Param  lReport,    Indica se a chamada é apenas para gerar relatório

@author David G. Fernandes
@since 25/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA202REFAZ(cCPreFt, lResumo, cResult, cCrysPath, lAutomato, lReport)
Local aResult     := {}
Local aArea       := GetArea()
Local aAreaNX0    := NX0->(GetArea())
Local cParams     := ""
Local cOptions    := ""
Local lChkNaoImp  := .F.
Local lRet        := .T.
Local cArquivo    := "prefatura_" + cCPreFt
Local dDtEmit     := JurGetDados("NX0", 1, xFilial("NX0") + cCPreFt, "NX0_DTEMI")
Local cMessage    := ""
Local lFltrHH     := !(Empty(NX0->NX0_DINITS) .And. Empty(NX0->NX0_DFIMTS))
Local lExpFSrv    := .T.  //Se for server exporta o arquivo
Local cMsgLog     := ''
Local cMsgRet     := ''
Local cArqRel     := ''  // rpt especifico de pre-fatura
Local cMoeNac     := SuperGetMv('MV_JMOENAC',, '01' )
Local cVincTS     := IF(SuperGetMv('MV_JVINCTS',, .T.), '1', '2')
Local cJurTS8     := IF(SuperGetMv('MV_JURTS8',, .T.), '1', '2')
Local lRecalc     := NX0->NX0_SITUAC == "3"
Local lImgRept    := .F.
Local lCpoFxNc    := NX0->(ColumnPos("NX0_FXNC")) > 0 // Proteção

Default lResumo   := .F.
Default lAutomato := .F.
Default lReport   := .F.

	cDestPath  := JurImgPre(cCPreFt, .T., .F., @cMsgRet)
	If !Empty(cMsgRet)
		cMsgLog := "Ja202Refaz--> " + cMsgRet
	EndIf

	If !lReport
		lRecalc := .T.
	Else
		lImgRept := NX0->NX0_SITUAC $ SIT_SUBSTITUIDA + "|" + SIT_FATEMITIDA  + "|" + SIT_CANCREVISAO + "|" + SIT_SINCRONIZANDO
	EndIf

	ProcRegua( 0 )
	IncProc()
	IncProc()
	IncProc()
	IncProc()
	IncProc()

	If lRecalc

		oParams := TJPREFATPARAM():New()
		oParams:SetCodUser(__CUSERID)

		oParams:SetTpExec("2")
		oParams:SetSituac("2")
		oParams:SetDEmi(dDtEmit)
		oParams:SetCFilaImpr("")
		oParams:SetFltrHH(lFltrHH)
		oParams:SetDIniH( IIF(Empty(NX0->NX0_DINITS), NX0->NX0_DINIFX, NX0->NX0_DINITS) )
		oParams:SetDFinH( IIF(Empty(NX0->NX0_DFIMTS), NX0->NX0_DFIMFX, NX0->NX0_DFIMTS) )
		oParams:SetDIniD( NX0->NX0_DINIDP )
		oParams:SetDFinD( NX0->NX0_DFIMDP )
		oParams:SetDIniT( NX0->NX0_DINITB )
		oParams:SetDFinT( NX0->NX0_DFIMTB )

		If lCpoFxNc
			oParams:SetFltrFxNC(!Empty(NX0->NX0_DIFXNC) .And. !Empty(NX0->NX0_DFFXNC))
			oParams:SetDInIFxNc(NX0->NX0_DIFXNC)
			oParams:SetDFinFxNc(NX0->NX0_DFFXNC)
		EndIf

		BEGIN TRANSACTION
			cMessage := STR0228 + cCPreFt  //"Início - Refazendo a pré-fatura: "
			EventInsert( FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, "054", FW_EV_LEVEL_INFO, ""/*cCargo*/, STR0082, cMessage, .F. ) // "Impressão de Pré-Fatura"
			aResult  := JA202ReImp(oParams, cCPreFt)
			cMessage := STR0229 + cCPreFt //"Final - Refazendo a pré-fatura: "
			EventInsert( FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, "054", FW_EV_LEVEL_INFO, ""/*cCargo*/, STR0082, cMessage, .F. ) // "Impressão de Pré-Fatura"
			If !aResult[1]
				DisarmTransaction()
			EndIf

		END TRANSACTION

		MsUnlockAll()

		If Len(aResult) == 0 .Or. !aResult[1]
			lRet := JurMsgErro(STR0071, aResult[2]) // #"Erro ao refazer a pré-fatura!"
		EndIf

	EndIf

	/*
	CALLCRYS (rpt , params, options), onde:
	rpt = Nome do relatÃ³rio, sem o caminho.
	params = ParÃ¢metros do relatÃ³rio, separados por vírgula ou ponto e vírgula. Caso seja marcado este parÃ¢metro, serão desconsiderados os parÃ¢metros marcados no SX1.
	options = Opções para não se mostrar a tela de configuração de impressão , no formato x;y;z;w ,onde:
	x = Impressão em Vídeo(1), Impressora(2), Impressora(3), Excel (4), Excel Tabular(5), PDF(6) eÂ TextoÂ (7)Â .
	y = Atualiza Dados  ou não(1)
	z = NÃºmero de CÃ³pias, para exportação este valor sempre será 1.
	w =Título do Report, para exportação este será o nome do arquivo sem extensão.
	*/

	If !lAutomato

		If !lResumo
			PtInternal(1, "J202GeraRpt: Print pre invoice " + NX0->NX0_COD )
			If !lImgRept
				Do Case
				Case cResult == '1'  //Impressora
					cOptions := '2'
				Case cResult == '3'  //Word
					cOptions := '8'
				Otherwise //Tela
					cOptions := '1'
				EndCase

				cOptions   := cOptions + ';0;1;'

				lChkNaoImp := .F. //  Obs dos casos no relatórios

				cParams    := NX0->NX0_COD + ';' + IIf( lChkNaoImp, 'N', 'S' ) + ';"X";' + cMoeNac + ;
							';' + cVincTS + ';'/* +';' */ + cJurTS8 +';'

				cArqRel := 'JU201'  // padrao
				If NX0->(FieldPos('NX0_RELPRE')) .And. !Empty(NX0->NX0_RELPRE)  // rpt especifico
					cArqRel := J202RetRel(NX0->NX0_RELPRE)
				EndIf

				If cResult == '3' // Gera relatório de faturamento em Word"
					JCallCrys( cArqRel, cParams, cOptions + cArquivo, .T., .F., lExpFSrv) //"Relatorio de Faturamento"
					cMsgRet := ''
					If JurMvRelat(cArquivo+".doc", cCrysPath, cDestPath, '3', @cMsgRet) //Copia
						cMsgLog += CRLF + "Ja202Refaz--> "+ cMsgRet
					EndIf
				EndIf

				JCallCrys( cArqRel, cParams, '6;0;1;' + cArquivo, .T., .F., lExpFSrv) //Sempre gera em PDF

				cMsgRet := ''
			EndIf

			Do Case
			Case cResult == '1'  //Imprime
				lRet := JurMvRelat(cArquivo+".pdf", cCrysPath, cDestPath, '1', @cMsgRet, lImgRept) //Imprime
			Case cResult == '2'  //Tela
				lRet := JurMvRelat(cArquivo+".pdf", cCrysPath, cDestPath, '2', @cMsgRet, lImgRept) //Tela
			Case cResult $ '3|4' .And. !lImgRept//Word|Nenhum
				lRet := JurMvRelat(cArquivo+".pdf", cCrysPath, cDestPath, '3', @cMsgRet, lImgRept) //Copia
			EndCase

			If !lRet
				cMsgLog += CRLF + "Ja202Refaz--> "+ cMsgRet
			EndIf

		EndIf

		JurCrLog(cMsgLog)

	EndIf

	RestArea( aAreaNX0 )
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202CKDSP
Verifica há despesas marcadas para transferência, para considerar o
parâmetro "MV_JALTDSP"

@author David Fernandes
@since 30/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202CKDSP(oModel)
Local lRet      := .T.
Local nLNNX8    := 0
Local nLNNX1    := 0
Local nNX8      := 0
Local nNX1      := 0
Local oModelNX8 := oModel:GetModel("NX8DETAIL")
Local oModelNX1 := oModel:GetModel("NX1DETAIL")
Local oModelTmp := nil
Local aPosTemp  := {}
Local lAltDesp  := SuperGetMV("MV_JALTDSP", , "2") == "1"  // Permite manipulação de despesas pelo SIGAPFS? "1" = Sim / "2" = Não

If ExistBlock("PNAPFS06")
	lAltDesp := ExecBlock("PNAPFS06", .F., .F., { lAltDesp, oModel} )
EndIf

If !lAltDesp

	nLNNX8 := oModelNX8:GetLine() // Salva a linha do contrato posicionado
	For nNX8 := 1 To oModelNX8:Length()
		oModelNX8:GoLine(nNX8)

		nLNNX1 := oModelNX1:GetLine()
		For nNX1 := 1 To oModelNX1:Length()
			oModelNX1:GoLine(nNX1)

			aPosTemp  := {}
			oModelTmp := oModel:GetModel('NVYDETAIL')
			aPosTemp  := J202FindMd(oModelTmp, "NVY_TKRET", .T., {"POSICAO"})[1]
			If !Empty(aPosTemp)
				lRet := .F.
				Exit
			EndIf

		Next nNX1

		oModelNX1:GoLine(nLNNX1)

		If !lRet
			Exit
		EndIf

	Next nNX8

	oModelNX8:GoLine(nLNNX8)

	If !lRet
		JurMsgErro(STR0222 + CRLF + STR0223, "MV_JALTDSP") // "Não é possível continuar essa operação." / "A manipulação de despesas está desabilitada no SIGAPFS."
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202OPERA
Executa as opções: Retirar, WO, Transferir ou Débito em Excesso nos lançamentos

@param  oView        - Objeto da View de dados a ser exibida
@param  lAutomato    - Indica se a chamada é feita via automação.
@param  aAutomato    - Array com os valores já definidos para a automação de teste.
        aAutomato[1] - oModelAut   -> Modelo Atual (Jura202)
        aAutomato[2] - Simulação do resultado da função ParamBox()
        aAutomato[3] - Simulação do resultado da função JurMotWO()
@return lRet         - Sucesso na operação
@author Jacques Alves Xavier
@since 23/03/2010
/*/
//-------------------------------------------------------------------
Function JA202OPERA(oView, lAutomato, aAutomato)
Local oModel     := Iif(lAutomato, aAutomato[1], oView:GetModel())
Local aSaveLn    := FwSaveRows(oModel)
Local aParBox    := {}
Local aRetPar    := {}
Local nTipOpe    := 0
//Variaveis do WO de Time Sheet
Local aRecnTS    := {}
//Variaveis do WO de Despesas
Local aRecnDP    := {}
//Variaveis do WO de Tabelados
Local aRecnTB    := {}
//Variaveis do WO de Fixo
Local aPosiFX    := {}
Local aRecnFX    := {}
Local lRet       := .T.
Local lCancTmp   := .F.
Local cMsgWO     := 0
Local aObsWO     := {}
Local oModelNX0  := oModel:GetModel('NX0MASTER')
Local cPrefat    := oModelNX0:GetValue("NX0_COD")
Local oModelNX8  := oModel:GetModel('NX8DETAIL')
Local oModelNT1  := oModel:GetModel('NT1DETAIL')
Local oModelNX1  := oModel:GetModel('NX1DETAIL')
Local oModelNX2  := oModel:GetModel('NX2DETAIL')
Local oModelNUE  := oModel:GetModel('NUEDETAIL')
Local oModelNVY  := oModel:GetModel('NVYDETAIL')
Local oModelNV4  := oModel:GetModel('NV4DETAIL')
Local nLinNX8    := 0
Local nLinNX1    := 0
Local lLine      := .F.
Local aRePosic   := {}
Local aRetLanc   := {}
Local nLNNX8     := 0
Local nLNNX1     := 0
Local aTimShePro := {}
Local aTimeSWO	 := {}
Local aNewValTs  := {}

Default lAutomato := .F.
Default aAutomato := {}
Default oView     := nil

If lIntRevis
	aAdd(aParBox,{3, STR0106, nTipOpe, {STR0107,STR0108,STR0109,STR0110,STR0208,STR0214,STR0243,STR0272}, 95, "", .F.}) //"Tipo de Operação"###"Retirar"###"WO"###"Transferir"###"Dividir TS"###"Incluir novo TS"###"TS - Ações em Lote"###"Alterar Casos para não revisados"
Else
	aAdd(aParBox,{3, STR0106, nTipOpe, {STR0107,STR0108,STR0109,STR0110,STR0208,STR0214,STR0243}, 90, "", .F.}) //"Tipo de Operação"###"Retirar"###"WO"###"Transferir"###"Dividir TS"###"Incluir novo TS"###"TS - Ações em Lote"
EndIf

If(!lAutomato)
	If oView:GetFolderActive("FOLDER_01", 2)[1] == 1 // Somente na aba de Pré-fatura

		If !ParamBox(aParBox, STR0106, @aRetPar,,,,,,,, .F., .F.) //"Tipo de Operações"
			Return Nil
			lRet := .F.
		EndIf

		nTipOpe := aRetPar[1]

	ElseIf oView:GetFolderActive("FOLDER_01", 2)[1] == 6 // Aba de Revisão - somente incluir TS
		aAdd(aParBox,{3, STR0106, "1", {STR0208}, 60, "", .F.}) //"Tipo de Operação"###"Retirar"###"WO"###"Transferir"###"Dividir TS"###"Incluir novo TS"###"TS - Ações em Lote"

		If !ParamBox(aParBox, STR0106, @aRetPar,,,,,,,, .F., .F.) //"Tipo de Operações"
			Return Nil
			lRet := .F.
		EndIf

		nTipOpe := 5 // incluir novo TS
	Else
		ApMsgInfo(STR0221) //"Esta ação é permitida somente na aba de Pré-Fatura!"
		lRet := .F.
	EndIf
Else
	nTipOpe := aAutomato[2]
	If nTipOpe == 2
		aObsWO  := aAutomato[3]
	ElseIf nTipOpe == 4
		aNewValTs := aAutomato[3]
	EndIf
EndIf

If lRet
	__lOpera := .T.

	If nTipOpe == 3 //Transferir

		lRet := JA202CKDSP(oModel)

	EndIf

	If lRet .And. (lAutomato .Or. ApMsgYesNo(STR0132, STR0133)) // "Ao realizar esta operação o sistema salvará todas as alterações feitas na tela!" e "ATENÃ‡ÃƒO"

		//Guarda o posionamento do contato [1], caso[2], Participante[3] e TS [4], DP[5], TB[6], FX[7]  atuais
		aRePosic  := {oModelNX8:GetLine(), oModelNX1:GetLine(), oModelNX2:GetLine(),;
						oModelNUE:GetLine(), oModelNVY:GetLine(), oModelNV4:GetLine(), oModelNT1:GetLine()}
		Do Case
		Case nTipOpe == 1 // "Retira"
			lAcumula := .T.

		Case nTipOpe == 2 // "WO"
			lAcumula := .F.

		Case nTipOpe == 3 // "Transferencia"
			__lExibeOK := .F.
			lCancTmp := .T.

		Case nTipOpe == 4 // "Dividir TS"
			lCancTmp := .T.

		Case nTipOpe == 5 // "Incluir novo TS"
			lCancTmp := .F.

		Case nTipOpe == 6 // TS - Alterações em Lote
			lCancTmp := .T.

		Case nTipOpe == 7 // Arredondar horas (e-billing)
			If lRet
				__oProcess := MsNewProcess():New({|| lRet := JA202ARRETS(oModel)}, STR0147, STR0247, .T.) //"Aguarde..." ### "Arredondando as horas dos Time Sheets."
				__oProcess:Activate()
			EndIf

		Case nTipOpe == 8 // "Alterar Casos para não revisados"
			lCancTmp := .F.

		OtherWise // Marca todos os filhos ao selecionar o pai
			JA202RET( oModel ) //Verificar a necessidade dessas funçoes pois ja esta sendo feito nos campos de marca
			JA202MARCA( oModel )
			lCancTmp := lCancPre

		EndCase

		Do Case
		Case nTipOpe == 1 // Retirar

			If !lCancPre
				If lAutomato
					aRetLanc := J202RETLAN(oModel, aRePosic)
				Else
					FWMsgRun(, {|| __InMsgRun := .T., aRetLanc := J202RETLAN(oModel, aRePosic), __InMsgRun := .F.}, STR0147, STR0167) //Aguarde... / Atualizando Lançamentos
				EndIf

				aRePosic := aRetLanc[1]
				aRecnTS  := aRetLanc[2]
				aRecnDP  := aRetLanc[3]
				aRecnTB  := aRetLanc[4]
				aRecnFX  := aRetLanc[5]
				lAcumula := .T.
			Else
				lAcumula := .F.
			EndIf

		Case nTipOpe == 2 // WO

			If lAutomato
				aRetLanc := J202RETLAN(oModel, aRePosic)
			Else
				FWMsgRun(, {|| __InMsgRun := .T. , aRetLanc := J202RETLAN(oModel, aRePosic), __InMsgRun := .F.}, STR0147, STR0167) //Aguarde... / Atualizando Lançamentos
			EndIf

			aRePosic := aRetLanc[1]
			aRecnTS  := aRetLanc[2]
			aRecnDP  := aRetLanc[3]
			aRecnTB  := aRetLanc[4]
			aRecnFX  := aRetLanc[5]
			aPosiFX  := aRetLanc[6] //No WO do Fixo é por posição, os demais são por recno.
			lRet     := aRetLanc[7]

			If !lRet
				(!lAutomato, ApMsgAlert(STR0159, STR0166), ) //"WO não efetuado, nenhum lançamento foi selecionado."###"WO de Lançamentos"
				lCancPre := .F.
			Else

				Do Case 
				Case Len(aRecnTS) > 0 .And. Len(aRecnDP) + Len(aRecnTB) + Len(aPosiFX) == 0
					cTpMot :=  "1"
				Case Len(aRecnDP) > 0 .And. Len(aRecnTS) + Len(aRecnTB) + Len(aPosiFX) == 0
					cTpMot :=  "2"
				Case Len(aRecnTB) > 0 .And. Len(aRecnDP) + Len(aRecnTS) + Len(aPosiFX) == 0
					cTpMot :=  "3"
				Case Len(aPosiFX) > 0 .And. Len(aRecnTS) + Len(aRecnTB) + Len(aRecnDP) == 0
					cTpMot :=  "5"
				OtherWise	
					cTpMot := "6"
				EndCase

				IIf (!lAutomato, aObsWO := JurMotWO('NUF_OBSEMI', STR0166, STR0184, cTpMot ), ) // "WO de Lançamentos" - "Observação - WO"

				If Empty(aObsWO)
					(!lAutomato, ApMsgAlert(STR0158, STR0166), ) //"WO não efetuado."###"WO de Lançamentos"
					aRecnTS := {}
					aRecnDP := {}
					aRecnTB := {}
					aPosiFX := {}

					lCancPre := .F.
					lRet     := .F.
				Else

					cMsgWO := JA202ENVWO( aRecnTS, aRecnDP, aRecnTB, , aPosiFX, aObsWO, @aTimShePro, @aTimeSWO )

					Iif (!lAutomato .And. !Empty(cMsgWO), ApMsgInfo(cMsgWO, STR0166), ) //"WO de Lançamentos"
					//Localiza a Despesa e grava como não processada
					J202UnMrk(oModel, aTimeSWO, @aRecnDP)
				EndIf
			EndIf

			lAcumula := .T.

		Case nTipOpe == 3 // Transferir
			If lRet
				__lExibeOK := .F.
				lRet := JA202TRANS()
				lAcumula := lRet
			EndIf

		Case nTipOpe == 4 // Dividir TS

			__lExibeOK := .F.
			lRet := J202DIVTS(oModel, lAutomato, aNewValTs)

		Case nTipOpe == 5 // Incluir novo TS
			If lRet
				__lExibeOK := .F.
				lRet := JA202NEWTS(oModelNX0, cPrefat)
			EndIf

		Case nTipOpe == 6 // TS - Alterações em Lote
			If lRet
				lRet := J202TSLOTE(oModel, oView, cPrefat )
			EndIf

		Case nTipOpe == 8 // "Alterar Casos para não revisados"
			If lRet
				lRet := J202ALTREV(oModel, oView, cPrefat )
			EndIf

		EndCase

		If lRet .And. !lAltPerio // Em alteração de valores no campo Valor TS não efetuar o JA202TotPre
			If lAutomato
				lRet := JA202TotPre(Nil)
			Else
				FWMsgRun(, {|| __InMsgRun := .T., lRet := JA202TotPre(Nil), __InMsgRun := .F.}, STR0147, STR0202) //Aguarde... / Recalculando Pré-Fatura
			EndIf
		EndIf
		__lOpera := .F.

		If lRet
			If !lAutomato
				FWMsgRun(, {|| __InMsgRun := .T., lRet := oModel:VldData(), __InMsgRun := .F.}, STR0147, STR0167) //Aguarde... / Atualizando Lançamentos
			EndIf

			If lRet

				If lAutomato
					lLine := .T.// O caso de teste realiza o commit
				Else
					FWMsgRun(, {|| __InMsgRun := .T., lLine := oModel:CommitData(), __InMsgRun := .F.}, STR0147, STR0167) //Aguarde... / Atualizando Lançamentos
				EndIf

				J202HIST('99', oModelNX0:GetValue("NX0_COD"), JurUsuario(__CUSERID), STR0001+": " + aParBox[1][4][nTipOpe], "7") //"Operação de Pré-Faturas"

				If !lCancTmp .And. !JGetDisarmWO()
					IIf(!Empty(aRecnTS), JA202LMPE2( "NUE", cPrefat, "NUE_CPREFT", .F., .T., aRecnTS, lCancPre ), Nil )
					IIf(!Empty(aRecnDP), JA202LMPE2( "NVY", cPrefat, "NVY_CPREFT", .F., .F., aRecnDP, lCancPre ), Nil )
					IIf(!Empty(aRecnTB), JA202LMPE2( "NV4", cPrefat, "NV4_CPREFT", .F., .F., aRecnTB, lCancPre ), Nil )
					IIf(!Empty(aRecnFX), JA202LMPE2( "NT1", cPrefat, "NT1_CPREFT", .F., .F., aRecnFX, lCancPre ), Nil )
				EndIf
				JSetDisarmWO(.F.)

				If nTipOpe > 3 //Retira, WO e Transferencia já tem reclock na rotina
					Begin Transaction
						nLNNX8 := oModelNX8:GetLine()
						For nLinNX8 := 1 To oModelNX8:GetQtdLine()
							oModelNX8:GoLine(nLinNX8)
							nLNNX1 := oModelNX1:GetLine()
							For nLinNX1 := 1 To oModelNX1:GetQtdLine()
								oModelNX1:GoLine(nLinNX1)

								GravaGenerico(oModel:getModel("NUEDETAIL"))
								GravaGenerico(oModel:getModel("NVYDETAIL"))
								GravaGenerico(oModel:getModel("NV4DETAIL"))

							Next nLinNX1
						Next nLinNX8

					End Transaction

				EndIf

				oModel:DeActivate()

				If lCancPre
					nOperacao := MODEL_OPERATION_VIEW // Variável Private
					oModel:SetOperation(nOperacao)
				EndIf
				
				oModel:Activate()
			
				If !lAutomato
					FWMsgRun(, {|| __InMsgRun := .T., oView:Refresh(), __InMsgRun := .F.}, STR0147, STR0167) //Aguarde... / Atualizando Lançamentos
				EndIf

				__lExibeOK := .T.

			Else
				JurShowErro( oModel:GetModel():GetErrormessage() )
			EndIf
			lAcumula := .F.

		EndIf

	EndIf

	If lRet .And. !lAutomato .And. oView:GetFolderActive("FOLDER_01", 2)[1] == 6 // Aba de Revisão
		If !( (oRev := JA207GetRev()) == Nil)
			lRet := oRev:Reload(oView)
		EndIf
	EndIf

	If !lLine
		FwRestRows(aSaveLn, oModel)
	Else
		If lAutomato
			ReposModel(oModel, aRePosic )
		Else
			FWMsgRun(, {|| __InMsgRun := .T., ReposModel(oModel, aRePosic ), __InMsgRun := .F.}, STR0147, STR0167) //Aguarde... / Atualizando Lançamentos
		EndIf
	EndIf

	If lRet .And. !lAutomato .And. lIntRevis .And. (NX1->( FieldPos( "NX1_INSREV" )) > 0)
		J202Memo(Nil, oView) // Atualiza campo MEMO NX1_INSREV na divisão da aba de Casos
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202RetLan(oModel, aRePosic)
Rotina para retornar arrays com os lançamentos marcados da pré-fatura e um array com o modelo
reposicionado.

@Obs utilizar essa rotina para lancamentos que 'serão removidos' por Retirar o WO

@author Luciano Pereira dos Santos
@since 31/08/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202RetLan(oModel, aRePosic)
Local aRet      := {}
Local oModelNX0 := oModel:GetModel('NX0MASTER')
Local oModelNX8 := oModel:GetModel('NX8DETAIL')
Local oModelNX1 := oModel:GetModel('NX1DETAIL')
Local oModelNT1 := oModel:GetModel('NT1DETAIL')
Local oModelTmp := Nil
Local nNX1Count := 0
Local nNX8Count := 0
Local lAllTS    := .F.
Local lAllDP    := .F.
Local lAllTB    := .F.
Local lAllFX    := .F.
Local lRemovNX1 := .F.
Local lRemovNX8 := .F.
Local aTmp      := {}
Local aRecFX    := {}
Local aRecTS    := {}
Local aRecDP    := {}
Local aRecTB    := {}
Local aPosFX    := {}
Local aPosTS    := {}
Local aPosDP    := {}
Local aPosTB    := {}
Local aRecnoTS  := {}
Local aRecnoDP  := {}
Local aRecnoTB  := {}
Local aPosiFX   := {}
Local aRecnoFX  := {}
Local nNX8Save  := 0
Local nNT1Save  := 0
Local nNX1Save  := 0
Local nNX8      := 0
Local nNX1      := 0
Local nNT1      := 0
Local lTemLanc  := .F.
Local nI        := 0
Local nRecnoNX1 := 0
Local lFatAdic  := oModelNX0:GetValue("NX0_FATADC") == "1"
Local lDpCaso   := .F.

If lFatAdic
	lDpCaso := JurGetDados("NVV", 1, xFilial("NVV") + oModelNX0:GetValue("NX0_CFTADC"), "NVV_DSPCAS") == "1"
EndIf

nNX8Save := oModelNX8:GetLine()
For nNX8 := 1 To oModelNX8:GetQtdLine()

	oModelNX8:GoLine(nNX8)
	lRemovNX8 := .F.

	aTmp   := J202FindMd(oModelNT1, "NT1_TKRET", .T., {"POSICAO", "RECNO"})
	aPosFX := aTmp[1]
	aRecFX := aTmp[2]
	lAllFX := oModelNT1:IsEmpty() .Or. oModelNT1:GetQtdLine() == Len(aPosFX) //Não tem ou removeu todos os FX

	If !Empty(aPosFX)
		If lAllFX
			If aRePosic[1] == nNX8
				aRePosic[7] := 1 //posiciona no primeiro
			EndIf
		Else
			If aRePosic[1] == nNX8 .And. aRePosic[7] == aPosFX[1]
				aRePosic[7] := Iif(aPosFX[1] == 1, aPosFX[1], aPosFX[1] - 1) //posição do fixo anterior ao removido
			EndIf
		EndIf
		AAdd(aPosiFX , {nNX8, 0, aPosFX}) //O fixo funiciona com o posicionamento para o WO
		AAdd(aRecnoFX, {nNX8, 0, aRecFX})
		lTemLanc := .T.
	EndIf

	nNX1Count := 0
	nNX1Save := oModelNX1:GetLine()
	For nNX1 := 1 To oModelNX1:GetQtdLine()
		oModelNX1:GoLine(nNX1)

		oModelTmp := oModel:GetModel('NUEDETAIL')
		aTmp      := J202FindMd(oModelTmp, "NUE_TKRET", .T., {"POSICAO", "RECNO"})
		aPosTS    := aTmp[1]
		aRecTS    := aTmp[2]
		lAllTS    := oModelTmp:IsEmpty() .Or. oModelTmp:GetQtdLine() == Len(aPosTS) //removeu todos os Time Sheets

		oModelTmp := oModel:GetModel('NVYDETAIL')
		aTmp      := J202FindMd(oModelTmp, "NVY_TKRET", .T., {"POSICAO", "RECNO"})
		aPosDP    := aTmp[1]
		aRecDP    := aTmp[2]
		lAllDP    := oModelTmp:IsEmpty() .Or. oModelTmp:GetQtdLine() == Len(aPosDP) //removeu todos as Despesas

		oModelTmp := oModel:GetModel('NV4DETAIL')
		aTmp      := J202FindMd(oModelTmp, "NV4_TKRET", .T., {"POSICAO", "RECNO"})
		aPosTB    := aTmp[1]
		aRecTB    := aTmp[2]
		lAllTB    := oModelTmp:IsEmpty() .Or. oModelTmp:GetQtdLine() == Len(aPosTB) //removeu todos os lançamentos Tabelados

		lRemovNX1 := lAllTS .And. lAllDP .And. lAllTB .And. lAllFX .And. JA202CasFA(oModelNX1, lFatAdic, lAllDP, lDpCaso) //para efeito de rateio, só remove o caso se não houver Fixo
		nRecnoNX1 := Iif(lRemovNX1, oModelNX1:GetDataID(), 0)

		If !Empty(aPosTS)
			If lAllTS
				If aRePosic[1] == nNX8 .And. aRePosic[2] == nNX1
					aRePosic[4] := 1 //posiciona no primeiro
				EndIf
				If lAllFX
					JurloadValue( oModelNX1, "NX1_VLDESC", , 0) //Se remover todos os TS não tiver FX Tambem remove os desconto especial do caso
					JurloadValue( oModelNX1, "NX1_PCDESC", , 0)
				EndIf
				JurloadValue( oModelNX1, "NX1_VDESCO", , 0) // Remove o desconto Linear
			Else
				If aRePosic[4] == nNX8 .And. aRePosic[2] == nNX1 .And. aRePosic[4] == aPosTS[1]
					aRePosic[4] := Iif(aPosTS[1] == 1, aPosTS[1], aPosTS[1] - 1) //posição do TimeSheet anterior ao removido
				EndIf
			EndIf
			AAdd(aRecnoTS, {nNX8, nRecnoNX1, aRecTS})
			lTemLanc := .T.
		EndIf

		If !Empty(aPosDP)
			If lAllDP
				If aRePosic[1] == nNX8 .And. aRePosic[2] == nNX1
					aRePosic[5] := 1 //posiciona no primeiro
				EndIf
			Else
				If aRePosic[1] == nNX8 .And. aRePosic[2] == nNX1 .And. aRePosic[5] == aPosDP[1]
					aRePosic[5] := Iif(aPosDP[1] == 1, aPosDP[1], aPosDP[1] - 1) //posição anterior da despesa removida ao removido
				EndIf
			EndIf
			AAdd(aRecnoDP, {nNX8, nRecnoNX1, aRecDP})
			lTemLanc := .T.
		EndIf

		If !Empty(aPosTB)
			If lAllTB
				If aRePosic[1] == nNX8 .And. aRePosic[2] == nNX1
					aRePosic[6] := 1 //posiciona no primeiro
				EndIf
			Else
				If aRePosic[1] == nNX8 .And. aRePosic[2] == nNX1 .And. aRePosic[6] == aPosTB[1]
					aRePosic[6] := Iif(aPosTB[1] == 1, aPosTB[1], aPosTB[1] - 1) //posição anterior do tabelado  ao removido
				EndIf
			EndIf
			AAdd(aRecnoTB, {nNX8, nRecnoNX1, aRecTB})
			lTemLanc := .T.
		EndIf

		If lRemovNX1
			JurloadValue( oModelNX1, "NX1_TKRET", , .T.)
			If aRePosic[1] == nNX8 .And. aRePosic[2] == nNX1
				aRePosic[2] := Iif(nNX1 == 1, nNX1, nNX1 - 1) //posição do caso anterior ao removido
				aRePosic[3] := 1
			EndIf
			nNX1Count := nNX1Count + 1
		EndIf

	Next nNX1

	oModelNX1:GoLine(nNX1Save)

	If nNX1Count == oModelNX1:GetQtdLine() //Se todos os casos forem removidos, as parcelas e contrato também serão marcados para retirar
		If !lAllFX
			nNT1Save := oModelNT1:GetLine()
			For nNT1 := 1 To oModelNT1:GetQtdLine()
				If !oModelNT1:IsDeleted(nNT1) .And. !oModelNT1:IsEmpty(nNT1)
					JurloadValue( oModelNT1, "NT1_TKRET", , .T.)
				EndIf
			Next nNT1
			oModelNX1:GoLine(nNT1Save)
		EndIf

		JurloadValue( oModelNX8, "NX8_TKRET", , .T.)
		If aRePosic[1] == nNX8
			aRePosic[1] := Iif(nNX8 == 1, nNX8, nNX8 - 1) //posição do contrato anterior ao removido
		EndIf
		lRemovNX8 := .T.
	EndIf

	If oModelNX8:GetValue( "NX8_TKRET" )
		nNX8Count := nNX8Count + 1
	EndIf

	//Ajusta o recno do contrato para remover ou não o registro
	For nI := 1 To Len(aRecnoTS)
		aRecnoTS[nI][1] := Iif(lRemovNX8 .And. aRecnoTS[nI][1] == nNX8, oModelNX8:GetDataID(), 0)
	Next nI
	For nI := 1 To Len(aRecnoDP)
		aRecnoDP[nI][1] := Iif(lRemovNX8 .And. aRecnoDP[nI][1] == nNX8, oModelNX8:GetDataID(), 0)
	Next nI
	For nI := 1 To Len(aRecnoTB)
		aRecnoTB[nI][1] := Iif(lRemovNX8 .And. aRecnoTB[nI][1] == nNX8, oModelNX8:GetDataID(), 0)
	Next nI
	For nI := 1 To Len(aRecnoFX)
		aRecnoFX[nI][1] := Iif(lRemovNX8 .And. aRecnoFX[nI][1] == nNX8, oModelNX8:GetDataID(), 0)
	Next nI

Next nNX8
oModelNX8:GoLine(nNX8Save)

If nNX8Count == oModelNX8:GetQtdLine()
	lCancPre := .T.
EndIf

aRet := {aRePosic, aRecnoTS, aRecnoDP, aRecnoTB, aRecnoFX, aPosiFX, lTemLanc}

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202CasFA()
Verifica se o caso de uma FA pode ser removido

@Param oModelNX1  Modelo de dados da NX1 posicionada
@Param lFatAdic   .T. Pré-fatura de fatura adicional
@Param lDpCaso    .T. A fatura adicional utiliza o valor de despesas do caso.
@Param lAllDP     .T. Todas as despesas do caso serão removidas

@author Luciano Pereira dos Santos
@since 17/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA202CasFA(oModelNX1, lFatAdic, lAllDP, lDpCaso)
Local lRet := .T.

If lFatAdic
	If lDpCaso .And. lAllDP
		lRet := oModelNX1:GetValue("NX1_VTS") == 0 .And. oModelNX1:GetValue("NX1_VTAB") == 0
	Else
		lRet := oModelNX1:GetValue("NX1_VTS") == 0 .And. oModelNX1:GetValue("NX1_VTAB") == 0 .And.;
				oModelNX1:GetValue("NX1_VDESP") == 0
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202ENVWO
Faz o envio dos lançamentos para WO

@author David Fernandes
@since 25/01/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202ENVWO( aPosiTS, aPosiDS, aPosiTB, cTabFX, aPosiFX, aObsWO, aTimShePro, aTimeSWO )
Local cMsgWO := ""

Default aTimShePro := {}
Default aTimeSWO   := {}

Processa( { || cMsgWO := JA202WOR( aPosiTS, aPosiDS, aPosiTB, cTabFX, aPosiFX, aObsWO,,@aTimShePro, @aTimeSWO ) }, STR0050, STR0203, .F. )  //'Aguarde'###  "Enviando lançamentos para WO"

Return cMsgWO

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202WOR
Faz o envio dos lançamentos para WO

@author David Fernandes
@since 25/01/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202WOR( aPosiTS,  aPosiDS, aPosiTB, cTabFX, aPosiFX, aObsWO, lAutomato, aTimShePro, aTimeSNWO)
Local aArea    := GetArea()
Local nContTS  := 0
Local nContDS  := 0
Local nContTB  := 0
Local nContFX  := 0
Local cMsgWO   := ""
Local cAliasTb := ""
Local aTabTmp  := {}
Local cTabTS   := ""	//cFiltroTS
Local cTabDS   := ""	//cFiltroDS
Local cTabTB   := ""	//cFiltroTB
Local oTabTS   := ""	//cFiltroTS
Local oTabDS   := ""	//cFiltroDS
Local oTabTB   := ""	//cFiltroTB
Local aStruct  := {}
Local cQuery   := ""
Local lObsWO   := NUE->( FieldPos( "NUE_ACAOLD" )) > 0 // Proteção
Local nContNDS := 0 //Contador de Despesas não processadas
Local cMsgNProc := ""

Default aTimShePro := {}
Default aTimeSNWO	:= {}

ProcRegua( 0 )
IncProc()
IncProc()
IncProc()

Default lAutomato := .F.

If !Empty(aPosiTS)
	cAliasTB   := "NUE"
	If lObsWO
		aStruct := {{'NUE_OBSWO', 'NUE_OBSWO', "M", 10, 0, ""}}
	EndIf
	cQuery     := "Select * from " + RetSqlName(cAliasTB) + " Where 1=2"
	aTabTmp    := JurCriaTmp(GetNextAlias(), cQuery, cAliasTB, , aStruct, , , , .F.) //Cria tabela temporária sem incluir registros
	oTabTS     := aTabTmp[1]
	cTabTS     := aTabTmp[1]:GetAlias()
	aStruTmp   := aTabTmp[5]
	aStruVirt  := aTabTmp[6]
	J202FilTmp(aPosiTS, cAliasTB, cTabTS, aStruTmp, aStruVirt)

	nContTS := JAWOLancto(1, aObsWO, "",, cTabTS)
EndIf

If !Empty(aPosiDS)
	cAliasTB  := "NVY"
	If lObsWO
		aStruct := {{'NVY_OBSWO', 'NVY_OBSWO', "M", 10, 0, ""}}
	EndIf
	cQuery    := "Select * from " + RetSqlName(cAliasTB) + " Where 1=2"
	aTabTmp   := JurCriaTmp(GetNextAlias(), cQuery, cAliasTB, , aStruct, , , , .F.)  //Cria tabela temporária sem incluir registros
	oTabDS    := aTabTmp[1]
	cTabDS    := aTabTmp[1]:GetAlias()
	aStruTmp  := aTabTmp[5]
	aStruVirt := aTabTmp[6]
	J202FilTmp(aPosiDS, cAliasTB, cTabDS, aStruTmp, aStruVirt)

	nContDS := JAWOLancto(2, aObsWO, "",, cTabDS, @aTimShePro, @aTimeSNWO)
	nContNDS := Len(aTimeSNWO)
EndIf

If !Empty(aPosiTB)
	cAliasTB  := "NV4"
	If lObsWO
		aStruct := {{'NV4_OBSWO', 'NV4_OBSWO', "M", 10, 0, ""}}
	EndIf
	cQuery    := "Select * from " + RetSqlName(cAliasTB) + " Where 1=2"
	aTabTmp   := JurCriaTmp(GetNextAlias(), cQuery, cAliasTB, , aStruct, , , , .F.)  //Cria tabela temporária sem incluir registros
	oTabTB    := aTabTmp[1]
	cTabTB    := aTabTmp[1]:GetAlias()
	aStruTmp  := aTabTmp[5]
	aStruVirt := aTabTmp[6]
	J202FilTmp(aPosiTB, cAliasTB, cTabTB, aStruTmp, aStruVirt)

	nContTB := JAWOLancto(3, aObsWO, "",, cTabTB)
EndIf

nContFX := IIf(!Empty(aPosiFX), J202WOFixo(aObsWO, aPosiFX), 0)

If (nContTS + nContDS + nContTB + nContFX) > 0
	cMsgWO := STR0160 + CRLF+ CRLF //"Lançamentos enviados para WO:"
	cMsgWO += IIf( nContTS > 0 , Transform(nContTS,'@E 99,999') + STR0161 + CRLF , "") //" Time Sheet(s)"
	cMsgWO += IIf( nContDS > 0 , Transform(nContDS,'@E 99,999') + STR0162 + CRLF , "") //" Despesa(s)"
	cMsgWO += IIf( nContTB > 0 , Transform(nContTB,'@E 99,999') + STR0163 + CRLF , "") //" Lanc. Tabelado(s)"
	cMsgWO += IIf( nContFX > 0 , Transform(nContFX,'@E 99,999') + STR0165 + CRLF , "") //" Parc. Fixo"
EndIf

If nContNDS > 0
	cMsgWO +=  CRLF+ CRLF + STR0346 + CRLF+ CRLF //"Lançamentos NÃO enviados para WO:"
    aEval(aTimeSNWO,{ |t| IIF( !Empty(t[2] ), cMsgNProc := cMsgNProc +  t[2] + CRLF, )})
	cMsgWO += IIf( nContNDS > 0 , Transform(nContNDS,'@E 99,999') + STR0162 + CRLF + cMsgNProc, "") //" Despesa(s)"
EndIf

/*************************************/
// Exclui as tabelas temporárias.
/*************************************/
If !Empty(cTabTS)
	( cTabTS )->( dbCloseArea() )
	oTabTS:Delete()
EndIf

If !Empty( cTabDS )
	( cTabDS )->( dbCloseArea() )
	oTabDS:Delete()
EndIf

If !Empty( cTabTB )
	( cTabTB )->( dbCloseArea() )
	oTabTB:Delete()
EndIf

RestArea( aArea )

Return cMsgWO

//-------------------------------------------------------------------
/*/{Protheus.doc} J202FilTmp()
Popula a tabela temporaria dos laçamentos

@author David Fernandes
@since 25/01/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J202FilTmp(aPos, cAliasTb, cTabTemp, aStruTemp, aStruVirt)
Local lRet        := .T.
Local aArea       := GetArea()
Local aAreaTb     := (cAliasTb)->(GetArea())
Local nI          := 0
Local nY          := 0
Local nZ          := 0
Local xValor      := ""

For nI := 1 To Len(aPos)

	For nY := 1 To Len( aPos[nI][3] )

		(cAliasTb)->( MsGoto( aPos[nI][3][nY] ) )

		RecLock( cTabTemp, .T. )
		For nZ := 1 To Len(aStruTemp)
			If aScan( aStruVirt, { |aX| aX[2] == aStruTemp[nZ][1] } ) == 0
				xValor := (cAliasTb)->( FieldGet( FieldPos( aStruTemp[nZ][1] ) ) )
				( cTabTemp )->( FieldPut( FieldPos( aStruTemp[nZ][1] ),  xValor  )  )
			EndIf
		Next nZ
		( cTabTemp )->(MsUnLock())
		( cTabTemp )->(DbCommit())
	Next nY

Next nI

RestArea( aAreaTb )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202LMPE2
Remove vinculo de registro especifico

@author Daniel Magalhaes
@since 06/05/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA202LMPE2( cAliasTb, cPreFt, cCampo, lDeletar, IsNUE, aPos, lCancPre)
Local aArea      := GetArea()
Local aAreaTb    := (cAliasTb)->(GetArea())
Local aAreaNX1   := NX1->(GetArea())
Local aAreaNX8   := NX8->(GetArea())
Local nI         := 0
Local nY         := 0
Local cFilPai    := ""
Local cFilFilho  := ""

Default IsNUE    := .F.
Default lCancPre := .F.

Do Case
	Case cAliasTb == "NUE"
		NW0->(DbSetOrder(1)) //NW0_FILIAL+NW0_CTS+NW0_SITUAC+NW0_PRECNF+NW0_CFATUR+NW0_CESCR+NW0_CWO
		cFilPai   := xFilial("NUE")
		cFilFilho := xFilial("NW0")

	Case cAliasTb == "NVY"
		NVZ->(DbSetOrder(1)) //NVZ_FILIAL+NVZ_CDESP+NVZ_SITUAC+NVZ_PRECNF+NVZ_CFATUR+NVZ_CESCR+NVZ_CWO
		cFilPai   := xFilial("NVY")
		cFilFilho := xFilial("NVZ")

	Case cAliasTb == "NV4"
		NW4->(DbSetOrder(4)) //NW4_FILIAL + NW4_CLTAB + NW4_SITUAC + NW4_PRECNF
		cFilPai   := xFilial("NV4")
		cFilFilho := xFilial("NW4")

	Case cAliasTb == "NT1"
		NWE->(DbSetOrder(1)) // NWE_FILIAL+NWE_CFIXO+NWE_SITUAC+NWE_PRECNF+NWE_CFATUR+NWE_CESCR+NWE_CWO
		cFilPai   := xFilial("NT1")
		cFilFilho := xFilial("NWE")

	Case cAliasTb == "NVV"
		NWD->(DbSetOrder(1)) // NWD_FILIAL+NWD_CFTADC+NWD_SITUAC+NWD_PRECNF+NWD_CFATUR+NWD_CESCR+NWD_CWO
		cFilPai   := xFilial("NVV")
		cFilFilho := xFilial("NWD")
EndCase

For nI := 1 To Len( aPos )

	For nY := 1 To Len( aPos[nI][3] )

		DbSelectArea(cAliasTb)
		(cAliasTb)->( MsGoto( aPos[nI][3][nY] ) )

		//Cancela lançamento da pré-fatura
		Do Case
		Case cAliasTb == "NUE"

			If (NW0->(MsSeek( cFilFilho + NUE->NUE_COD + "1" + cPreFt ) ))
				RecLock("NW0", .F.)
				NW0->NW0_CANC  := "1"
				NW0->(MsUnlock())
				NW0->(DbCommit())
				//Grava na fila de sincronização
				If !lRevisLD
					J170GRAVA("NUE", cFilPai + NUE->NUE_COD, "4")
				EndIf
				NW0->(DbSkip())
			EndIf

		Case cAliasTb == "NVY"

			If (NVZ->(MsSeek( cFilFilho + NVY->NVY_COD + "1" + cPreFt ) ))
				RecLock("NVZ", .F.)
				NVZ->NVZ_CANC  := "1"
				NVZ->(MsUnlock())
				NVZ->(DbCommit())
				//Grava na fila de sincronização
				If !lRevisLD
					J170GRAVA("NVY", cFilPai + NVY->NVY_COD, "4")
				EndIf
				NVZ->(DbSkip())
			EndIf

		Case cAliasTb == "NV4"

			If (NW4->(MsSeek( cFilFilho + NV4->NV4_COD + "1" + cPreFt ) ))
				RecLock("NW4", .F.)
				NW4->NW4_CANC  := "1"
				NW4->(MsUnlock())
				NW4->(DbCommit())
				NW4->(DbSkip())
				//Grava na fila de sincronização
				If !lRevisLD
					J170GRAVA("NV4", cFilPai + NV4->NV4_COD, "4")
				EndIf
			EndIf

		Case cAliasTb == "NT1"

			If (NWE->(MsSeek( cFilFilho + NT1->NT1_SEQUEN + "1" + cPreFt ) ))
				RecLock("NWE", .F.)
				NWE->NWE_CANC  := "1"
				NWE->(MsUnlock())
				NWE->(DbCommit())
				NWE->(DbSkip())
				//Grava na fila de sincronização
				If !lRevisLD
					J170GRAVA("NT0", xFilial("NT0") + JurGetDados("NT1", 1, cFilPai + NWE->NWE_CFIXO, "NT1_CCONTR"), "4")
				EndIf
			EndIf

		Case cAliasTb == "NVV"

			If (NWD->(MsSeek( cFilFilho + NVV->NVV_COD + "1" + cPreFt ) ))
				RecLock("NWD", .F.)
				NWD->NWD_CANC  := "1"
				NWD->(MsUnlock())
				NWD->(DbCommit())
				NWD->(DbSkip())
			EndIf
		EndCase

		RecLock(cAliasTb, .F.)
		If lDeletar
			(cAliasTb)->( dbDelete() )
		Else
			If IsNUE
				(cAliasTb)->( FieldPut( FieldPos("NUE_VALOR1"), 0 ))
			EndIf
			(cAliasTb)->( FieldPut( FieldPos( cCampo ), ""))
		EndIf
		(cAliasTb)->(MsUnLock())
		(cAliasTb)->(DbCommit())
		(cAliasTb)->(DbSkip())

	Next nY

	//Se tiver o recno do Caso, remove
	If aPos[nI][2] > 0 .And. !lCancPre
		NX1->(MsGoto( aPos[nI][2] ))
		If !(NX1->(EOF()))
			If FindFunction("J201EDelRv")
				J201EDelRv(NX1->NX1_CPREFT, NX1->NX1_CCONTR, NX1->NX1_CCLIEN, NX1->NX1_CLOJA, NX1->NX1_CCASO) // Remove vínculo de sócios/revisores
			EndIf
			RecLock("NX1", .F.)
			NX1->(DbDelete())
			NX1->(MsUnLock())
			NX1->(DbCommit())
		EndIf
	EndIf

	//Se tiver o recno do Contrato, remove
	If aPos[nI][1] > 0 .And. !lCancPre
		NX8->(MsGoto( aPos[nI][1] ))
		If !(NX8->(EOF()))
			RecLock("NX8", .F.)
			NX8->(DbDelete())
			NX8->(MsUnLock())
			NX8->(DbCommit())
		EndIf
	EndIf

Next nI

RestArea( aAreaNX8 )
RestArea( aAreaNX1 )
RestArea( aAreaTb )
RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202TRANS
Tela para informar o novo Cliente/Loja/Caso que irão os lançamentos selecionados

@author Jacques Alves Xavier
@since 24/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202TRANS()
Local lRet         := .F.
Local aArea        := GetArea()
Local aAreaNX0     := NX0->( GetArea() )
Local oGetGrup     := Nil
Local oGetClie     := Nil
Local oGetLoja     := Nil
Local oGetCaso     := Nil
Local oDlg         := Nil

Private cGetGrup   := Criavar( 'NX0_CGRUPO' )
Private cGetClie   := Criavar( 'NX0_CCLIEN' )
Private cGetLoja   := Criavar( 'NX0_CLOJA' )
Private cGetCaso   := Criavar( 'NX2_CCASO' )

	DEFINE MSDIALOG oDlg TITLE STR0113 FROM 233, 194 TO 333, 675 PIXEL // "Transferir o(s) Lançamentos marcados para:"

	oGetGrup := TJurPnlCampo():New(02, 16, 50, 22, oDlg, AllTrim(RetTitle("NX0_CGRUPO")), 'NX0_CGRUPO', {|| }, {|| cGetGrup := oGetGrup:Valor},,,, 'ACY') //"Grupo"
	oGetGrup:oCampo:bValid := {|| JA202VLTRA('1', oGetGrup, oGetClie, oGetLoja, oGetCaso) }

	oGetClie := TJurPnlCampo():New(02, 76, 50, 22, oDlg, AllTrim(RetTitle("NX0_CCLIEN")), 'NX0_CCLIEN', {|| }, {|| cGetClie := oGetClie:Valor},,,, 'SA1NX0') //"Cliente"

	oGetLoja := TJurPnlCampo():New(02, 136, 40, 22, oDlg, AllTrim(RetTitle("NX0_CLOJA")), 'NX0_CLOJA', {|| }, {|| cGetLoja := oGetLoja:Valor},,,,) //"Loja"
	oGetLoja:oCampo:bValid  := {|| JA202VLTRA('2', oGetGrup, oGetClie, oGetLoja, oGetCaso) }

	oGetCaso := TJurPnlCampo():New(02, 186, 50, 22, oDlg, AllTrim(RetTitle("NX2_CCASO")), 'NX2_CCASO',{|| },{|| cGetCaso := oGetCaso:Valor},,,, 'NVENX0') //"Caso"
	oGetCaso:oCampo:bValid  := {|| JA202VLTRA('3', oGetGrup, oGetClie, oGetLoja, oGetCaso) }

	@ 030,124 Button STR0077 Size 050,012 PIXEL OF oDlg  Action ( lRet := JA202ETL(oGetGrup:Valor, oGetClie:Valor, oGetLoja:Valor, oGetCaso:Valor), IIf(lRet, oDlg:End(), Nil) ) //"Ok"
	@ 030,184 Button STR0024 Size 050,012 PIXEL OF oDlg  Action oDlg:End() //"Cancelar"

	ACTIVATE MSDIALOG oDlg CENTERED

	RestArea( aAreaNX0 )
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202F3
Rotina genérica para pesquisa de Cliente/Loja e Caso

@Param   cTipo      Indica qual o tipo de pesquisa: 1 = Cliente e Loja / 2 = Caso
@Param   cGetGrup   Código do grupo para o filtro
@Param   cGetClie   Código do cliente para o filtro
@Param   cGetLoja   Código da loja para o filtro

@author Jacques Alves Xavier
@since 24/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202F3(cTipo)
Local cRet := "@#@#"

	If cTipo == '1'
		cRet := IIF(Empty(cGetGrup), "@#@#", "@#SA1->A1_GRPVEN == '" + cGetGrup + "'@#")
	Else
		If !Empty(cGetClie) .And. !Empty(cGetLoja)
			cRet := "@#NVE->NVE_CCLIEN == '" + cGetClie + "' .And. NVE->NVE_lCLIEN == '" + cGetLoja + "'@#"
		EndIf
  EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202VLTRA()
Rotina de validação e preenchimento dos campos Grupo,Cliente,Loja e Caso na tela de transferÃªncia

@Param    cTipo   Tipo da Ação: 1 = Grupo / 2 = Cliente/Loja / 3 = Caso
@Param    cAliasTb  Alias usado para diferenciar a utilização pelo botão Casos sem Contratos pois ele não possui o oGetCaso (JFiltraCaso)

@author Jacques Alves Xavier
@since 25/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202VLTRA(cTipo, oGetGrup, oGetClie, oGetLoja, oGetCaso, cAlias)
Local lRet    := .T.
Local cCaso   := GETMV('MV_JCASO1')
Local cClien  := ''
Local cLoja   := ''
Local cGrupo  := ''
Local lAltera := .T.

If cTipo == '1' .And. !Empty(oGetGrup:Valor)
	lRet := ExistCPO( 'ACY', oGetGrup:Valor )
	If lRet .And. oGetGrup:IsChanged()
		oGetClie:Limpar()
		oGetLoja:Limpar()
		If Empty(cAlias)
			oGetCaso:Limpar()
		EndIf
	EndIf
EndIf

If cTipo == '2' .And. !Empty(oGetClie:Valor) .And. !Empty(oGetLoja:Valor)
	lRet := ExistCPO( 'SA1', oGetClie:Valor + oGetLoja:Valor) .Or. (Empty(oGetClie:Valor) .And. Empty(oGetLoja:Valor) )
	If lRet
		oGetGrup:Valor := JurGetDados('SA1', 1, xFilial('SA1') + oGetClie:Valor + oGetLoja:Valor, 'A1_GRPVEN')
		oGetGrup:Refresh()
	EndIf
	If Empty(cAlias)
		If lRet .And. !Empty(oGetCaso:Valor)
			lRet := ExistCPO( 'NVE', oGetClie:Valor + oGetLoja:Valor + oGetCaso:Valor, 1)
			If !lRet
				JurMsgErro(STR0118) // "Preencher corretamente as informações"
			EndIf
		EndIf
	EndIf
EndIf

If cTipo == '3' .And. !Empty(oGetCaso:Valor)
	If cCaso == '1' .And. !Empty(oGetClie:Valor) .And. !Empty(oGetLoja:Valor)
		lRet := ExistCPO( 'NVE', oGetClie:Valor + oGetLoja:Valor + oGetCaso:Valor, 1)
	ElseIf cCaso == '2'
		lRet := ExistCPO( 'NVE', oGetCaso:Valor, 3)
		If lRet

			lAltera := (Empty(oGetClie:Valor) .Or. Empty(oGetLoja:Valor)) .Or.;
				Empty(JurGetDados( 'NVE', 1, oGetClie:Valor + oGetLoja:Valor + oGetCaso:Valor))

			If lAltera
				aCliLoj := JCasoAtual(oGetCaso:Valor)

				cClien := aCliLoj[1][1]
				cLoja  := aCliLoj[1][2]
				cGrupo := JurGetDados('SA1', 1, xFilial('SA1') + cClien + cLoja, 'A1_GRPVEN')

				oGetClie:Valor := cClien
				oGetClie:Refresh()
				oGetLoja:Valor := cLoja
				oGetLoja:Refresh()
				oGetGrup:Valor := cGrupo
				oGetGrup:Refresh()
			EndIf
		EndIf
	Else
		oGetCaso:Limpar()
		lRet := JurMsgErro(STR0118) // "Preencher corretamente as informações"
	EndIf
ElseIf cTipo == '3' .And. Empty(oGetCaso:Valor) .And. cCaso == '2'
	oGetClie:Limpar()
	oGetLoja:Limpar()
	oGetGrup:Limpar()
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202ETL
Executa a transferência para o Cliente/Loja/Caso definido

@Param   cGetGrup   Código do grupo para a transferencia
@Param   cGetClie   Código do cliente para a transferencia
@Param   cGetLoja   Código da loja para a transferencia
@Param   cGetCaso   Código do Caso para a transferencia

@author Jacques Alves Xavier
@since 24/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202ETL(cGetGrup, cGetClie, cGetLoja, cGetCaso, lRestri)
Local lRet   := .T.

	If !(Empty(cGetClie) .Or. Empty(cGetLoja) .Or. Empty(cGetCaso))
		FWMsgRun(, {|| __InMsgRun := .T., lRet := JA202ETLR(cGetGrup, cGetClie, cGetLoja, cGetCaso, @lRestri), __InMsgRun := .F.}, STR0147, STR0259) //# Aguarde... / ## "Transferindo os lançamentos"
	Else
		ApMsgAlert(STR0118)
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}  JA202ETLR
Executa o processamento da transferência para o Cliente/Loja/Caso definido

@Param   cGetGrup   Código do grupo para a transferencia
@Param   cGetClie   Código do cliente para a transferencia
@Param   cGetLoja   Código da loja para a transferencia
@Param   cGetCaso   Código do Caso para a transferencia

@author Jacques Alves Xavier
@since 24/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202ETLR(cGetGrup, cGetClie, cGetLoja, cGetCaso, lRestri)
Local lRet        := .T.
Local aArea       := GetArea()
Local oModel      := FwModelActive()
Local oView       := FwViewActive()
Local oModelNX0   := oModel:GetModel( "NX0MASTER" )
Local oModelNX1   := oModel:GetModel( "NX1DETAIL" )
Local oModelNX8   := oModel:GetModel( "NX8DETAIL" )
Local oModelNT1   := oModel:GetModel( "NT1DETAIL" )
local cPreft      := oModelNX0:GetValue('NX0_COD')
Local aTransfTS   := {}
Local aTransfDP   := {}
Local aTransfLT   := {}
Local aNotTransf  := {} // Array com os lançamentos não transferidos
Local aTransf     := {} //Array com o log de alterações na pré-fatura
Local aAltPreft   := {}
Local aJustaNX1   := {}
Local nQtdLanc    := 0
Local nQtdTrans   := 0
Local aEbil       := {}

local nLinNX8     := 0
local nLinNX1     := 0

Local cMsgLog     := ''
Local nSaveNX8    := 0
Local nSaveNX1    := 0
local lTLancNT1   := .F. //Controla se o contrato tem parcela de fixo

Default cGetGrup  := ""
Default cGetClie  := ""
Default cGetLoja  := ""
Default cGetCaso  := ""
Default lRestri   := .F.

nSaveNX8 := oModelNX8:GetLine()
For nLinNX8 := 1 To oModelNX8:Length()
	oModelNX8:GoLine(nLinNX8)

	lTLancNT1 := lTLancNT1 .Or. !oModelNT1:IsEmpty()

	nSaveNX1 := oModelNX1:GetLine()

	For nLinNX1 := 1 To oModelNX1:Length()
		oModelNX1:GoLine(nLinNX1)
		lRet := lRet .And. J202VldTransf('NUE', oModel, cGetGrup, cGetClie, cGetLoja, cGetCaso, @aTransfTS, @aNotTransf, @aAltPreft, @aJustaNX1, @nQtdLanc, @nQtdTrans, @aEbil)
		lRet := lRet .And. J202VldTransf('NVY', oModel, cGetGrup, cGetClie, cGetLoja, cGetCaso, @aTransfDP, @aNotTransf, @aAltPreft, @aJustaNX1, @nQtdLanc, @nQtdTrans)
		lRet := lRet .And. J202VldTransf('NV4', oModel, cGetGrup, cGetClie, cGetLoja, cGetCaso, @aTransfLT, @aNotTransf, @aAltPreft, @aJustaNX1, @nQtdLanc, @nQtdTrans)
		If !lRet
			Exit
		EndIf
	Next nLinNX1

	oModelNX1:GoLine(nSaveNX1)
	If !lRet
		Exit
	EndIf

Next nLinNX8

oModelNX8:GoLine(nSaveNX8)

If lRet .And. !JurIsRest()
	If lRet := oModel:VldData()
		If oModel:lModify   // necessário pois se o modelo não foi alterado o commit retorna .F.
			lRet := oModel:CommitData()  //Confirmar modelo de dados para não perder as alterações anteriores a operação.
		EndIf
	EndIf
EndIf

If lRet .And. (lRet := J202Transf(aTransfTS, aTransfDP, aTransfLT, aJustaNX1, cPreft))
	aTransf := J202AltPF(aAltPreft, cPreft) //Altera as pré-fatura relacionadas ao lançamentos tranferidos
	If !JurIsRest()
		oModel:DeActivate() // Recarrega o modelo para a atualização da J202Totpre()
		dbSelectArea( 'NX0' )
		oModel:Activate()
		If oView != Nil
			oView:Refresh()
		EndIf
	EndIf
EndIf

lCancPre := (nQtdLanc == nQtdTrans) .And. !lTLancNT1 //Altera a variavel estatica para cancelar a pré-fatura no commit se não houverem mais lançamentos
lRestri  := !Empty(aNotTransf)

cMsgLog := J202TrfLog(cPreft, lCancPre, Len(aTransfTS), Len(aTransfDP), Len(aTransfLT), aTransf, aNotTransf)

If !Empty(cMsgLog)
	JurErrLog(cMsgLog, STR0240) //#"Transferência de Lançamentos"
Else
	__lExibeOK := .T.
	If !lRet
		JurMsgErro(STR0250) //#"Não foi possível realizar a transferência!"
	EndIf

EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202VldTransf(cTabLan, oModel, cGrupo, cClient, cLoja, cCaso, aLanTransf, aNotTransf, aAltPreft, nQtdLanc, nQtdTrans, aEbil)
Valida a transferencia do lançamento para o caso de destino

@Param   cTabLan     Tabela do lançamento 'NUE' - time Sheet; 'NVY' - Despesas; 'NV4' - Lançamento Tabelado
@param   oModel      Modelo de dados da Pré-fatura
@Param   cGrupo      Código do Grupo do cliente para a transferencia
@Param   cClient     Código do cliente para a transferencia
@Param   cLoja       Código da loja para a transferencia
@Param   cCaso       Código do Caso para a transferencia

@Param   aLanTransf    Array de lançamentos tranferidos (passado por referência)
         aLanTransf[1] Recno do lançamento a ser transferido
         aLanTransf[2] .T. Indica que o lançaemnto será transferido para um caso da mesma pre-fatura

@Param   aNotTransf    Array com as criticas da operação de tranferencia (passado por referência)
         aNotTransf[1] Recno do caso origem
         aNotTransf[2] Tipo do lançamento 'TS' - time Sheet; 'DP' - Despesas; 'LT' - Lançamento Tabelado
         aNotTransf[3] Indicador da critica: 'EBI' - E-Billing; 'INV' - Casos inválidos; 'ENC' - Casos encerrados; 'PER' - Caso não permite o tipo de lançamento
         aNotTransf[4] Código do cliente para a transferencia
         aNotTransf[5] Código da loja para a transferencia
         aNotTransf[6] Código do Caso para a transferencia

@Param   aAltPreft    Array com os casos dos lançamentos para verificar se podem ser associados a uma outra pré-fatura (passado por referência)
         aAltPreft[1] Tipo do lançamento 'TS' - time Sheet; 'DP' - Despesas; 'LT' - Lançamento Tabelado
         aAltPreft[2] Data do lançaemnto
         aAltPreft[3] Código do cliente destino
         aAltPreft[4] Código da loja destino
         aAltPreft[5] Código do Caso destino
         aAltPreft[6] Código do lançamento a ser transferido

@Param   aJustaNX1    Array com os recnos para fazer o ajuste da flag do caso. (passado por referência)
@Param   nQtdLanc     Quantidade total de lançamentos da pré-fatura (passado por referência)
@Param   nQtdTrans    Quantidade total de lançamentos transferidos para fora da pré-fatura (passado por referência)
@Param   aEbil        Array com a informações de e-blilling. (passado por referência)

@Return lRet          .T. Não houve criticas no processo de validação (O processo só interrompido para interface)

@author Luciano Pereira dos Santos / Jonatas Martins
@since 08/05/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202VldTransf(cTabLan, oModel, cGrupo, cClient, cLoja, cCaso, aLanTransf, aNotTransf, aAltPreft, aJustaNX1, nQtdLanc, nQtdTrans, aEbil)
Local lRet       := .T.
Local cCpoDtLanc := ""
Local oModelNX0  := oModel:GetModel( "NX0MASTER" )
Local cPreft     := oModelNX0:GetValue('NX0_COD')
Local oModelNX1  := oModel:GetModel( "NX1DETAIL" )
Local cCliNX1    := oModelNX1:GetValue('NX1_CCLIEN')
Local cLojNX1    := oModelNX1:GetValue('NX1_CLOJA' )
Local cCasNX1    := oModelNX1:GetValue('NX1_CCASO' )
Local nRecNX1O   := oModelNX1:GetDataID() //Caso origem
Local oModelLanc := oModel:GetModel(cTabLan + 'DETAIL')
Local aLines     := oModelLanc:GetLinesChanged()
Local nLine      := 0
Local nI         := 0
Local lIsRest    := Iif(FindFunction("JurIsRest"), JurIsRest(), .F.)
Local lPermLan   := .F.
Local aPermit    := {} //Verifica no caso se aceita o lançamento
Local lCasPre    := .F.
Local lCasEnc    := .F.
Local dDataLan   := CTod('  /  /  ')
Local dDataEnc   := CTod('  /  /  ')
Local dDtMaxLan  := CTod('  /  /  ')
Local nDtMaxLan  := SuperGetMV('MV_JLANC1', , 0)
Local cTipoLanc  := ""
Local cCasoFlag  := ""
Local cCodLanc   := ""
Local cFase      := ""
Local cTarefa    := ""
Local cAtivid    := ""
Local nRecNX1D   := 0 //Caso destino
Local lTemLanc   := .T.
Local cDocto     := ""
Local lAcaoLd    := NUE->(ColumnPos("NUE_ACAOLD")) > 0

Default aNotTransf := {}  // Lançamentos não transferidos
Default aLanTransf := {}  // Lançamentos transferidos
Default aAltPreft  := {}  // Datas dos lançamentos transferidos para verificar de se podem ser associados a uma outra pré-fatura
Default aJustaNX1  := {}  // Array de casos para ajustar a flag dos casos
Default nQtdLanc   := 0
Default nQtdTrans  := 0
Default aEbil      := {}

Do Case
Case cTabLan == 'NUE'
	cCpoDtLanc := 'NUE_DATATS'
	cCpoLanCas := 'NVE_LANTS'
	cTipoLanc  := 'TS'
	cCasoFlag  := 'NX1_TS'
Case cTabLan == 'NVY'
	cCpoDtLanc := 'NVY_DATA'
	cCpoLanCas := 'NVE_LANDSP'
	cTipoLanc  := 'DP'
	cCasoFlag  := 'NX1_DESP'
Case cTabLan == 'NV4'
	cCpoDtLanc := 'NV4_DTCONC'
	cCpoLanCas := 'NVE_LANTAB'
	cTipoLanc  := 'LT'
	cCasoFlag  := 'NX1_LANTAB'
EndCase

nQtdLanc += IIf(oModelLanc:IsEmpty(), 0, oModelLanc:Length())

For nI := 1 To Len(aLines)
	nLine := aLines[nI]

	If !oModelLanc:IsDeleted(nLine) .And. oModelLanc:GetValue(cTabLan+'_TKRET', nLine) .And. !Empty(oModelLanc:GetValue(cTabLan + "_CPREFT", nLine)) // Valida se o Lanc não sofreu ação de outra operação como alteração de periodo

		cCodLanc := oModelLanc:GetValue(cTabLan + '_COD', nLine) //Código
		dDataLan := oModelLanc:GetValue(cCpoDtLanc)              //Data do lançamento

		If lIsRest
			cClient := oModelLanc:GetValue(cTabLan + '_CCLILD', nLine)
			cLoja   := oModelLanc:GetValue(cTabLan + '_CLJLD', nLine)
			cCaso   := oModelLanc:GetValue(cTabLan + '_CCSLD', nLine)
		EndIf

		If lRet := (cClient + cLoja + cCaso != cCliNX1 + cLojNX1 + cCasNX1) //Verifica se o lançamento esta sendo tranferido para o mesmo caso.
			cGrupo  := JurGetDados('SA1', 1, xFilial('SA1') + cClient + cLoja, 'A1_GRPVEN')
			lCasPre := J202CasPre(cPreft, cClient, cLoja, cCaso, cTipoLanc, @nRecNX1D, @lTemLanc)

			If Len(aPermit := JurGetDados('NVE', 1, xFilial('NVE') + cClient + cLoja + cCaso, {cCpoLanCas, 'NVE_SITUAC', 'NVE_DTENCE'})) >= 3
				lPermLan := aPermit[1] == '1' //Permite o tipo de lançamento
				lCasEnc  := aPermit[2] == '2' //Caso encerrado
				dDataEnc := aPermit[3]        //Data de encerramento
			Else
				aAdd( aNotTransf, {nRecNX1O, cTipoLanc, 'INV', cClient, cLoja, cCaso, cCodLanc, DtoC(dDataLan)} ) //Guarda os casos invalidos na transferencia do lançamento.
				lRet := .F.
			EndIf
		EndIf

		If lRet .And. !lPermLan //Não Permite a digitação do lançamento para o caso
			aAdd( aNotTransf, {nRecNX1O, cTipoLanc, 'PER', cClient, cLoja, cCaso, cCodLanc, DtoC(dDataLan)} ) //Guarda os casos que não permitem a transferência do lançamento.
			lRet := .F.
		EndIf

		If lRet .And. lCasEnc // Caso encerrado
			dDtMaxLan := JRetDtEnc(dDataEnc, nDtMaxLan) //Se o caso estiver encerrado, verifica a data máxima permitida para lançamento

			If !(lRet := dDtMaxLan >= dDataLan) // Verifica se a data do lançamento está no período de dias para lançamento em caso encerrado
				aAdd(aNotTransf, {nRecNX1O, cTipoLanc, 'ENC',cClient, cLoja, cCaso, cCodLanc, DtoC(dDtMaxLan)} ) // Inserir no array dos lançamentos que não foram transferidos
			EndIf
		EndIf

		If lRet .And. cTabLan == 'NUE' .And. JaUsaEbill(cClient, cLoja) //Verifica se é cliente e-Billing e valida as informações de fase, tarefa e atividade

			If lIsRest //Se for Rest valida as informações digitadas
				cFase   := oModelLanc:GetValue('NUE_CFASE', nLine)
				cTarefa := oModelLanc:GetValue('NUE_CTAREF', nLine)
				cAtivid := oModelLanc:GetValue('NUE_CTAREB', nLine)
				lRet    := JAEBILLCPO(cClient, cLoja, cFase, cTarefa, cAtivid, .F., @cDocto)
				aEbil   := {lRet, cCodLanc, cClient, cLoja, cFase, cTarefa, cAtivid, .T., cDocto}
			Else //Se não for Rest abre a tela para digitar
				If Empty(aEbil)
					SA1->(DbsetOrder(1)) //A1_FILIAL + A1_COD + A1_LOJA
					SA1->(DbSeek(xFilial('SA1')+ cClient + cLoja)) //Corrigir consulta padrao na P12
					aEbil := JA148AEbil(cClient, cLoja, , .T.)
				EndIf
			EndIf

			If !Empty(aEbil) .And. !(lRet := aEbil[1])
				aAdd( aNotTransf, {nRecNX1O, cTipoLanc, 'EBI', cClient, cLoja, cCaso, cCodLanc, DtoC(dDataLan)} )
			EndIf
		EndIf

		If lRet // Transfere o lançamento
			aAdd(aLanTransf, {oModelLanc:GetDataID(nLine), lCasPre, cGrupo, cClient, cLoja, cCaso, aEbil}) //Guarda o recno do lançamento para ser transferido
			If !lCasPre
				If aScan( aAltPreft, {|x| x[1] + DtoC(x[2]) + x[3] + x[4] + x[5] == cTipoLanc + DtoC(dDataLan) + cClient + cLoja + cCaso} ) == 0
					aAdd( aAltPreft, {cTipoLanc, dDataLan, cClient, cLoja, cCaso} ) //Guarda as diferentes datas do lançamento para verificar se podem ser associados a uma outra pré-fatura
				EndIf
			Else
				If !lTemLanc .And. aScan( aJustaNX1, {|x| x[1] == nRecNX1D .And. x[2] == cCasoFlag} ) == 0 //Se for a transferência para um caso da mesma pré-fatura, guarda o recno para fazer o ajuste da flag de lançamento no caso.
					aAdd( aJustaNX1, {nRecNX1D, cCasoFlag, '1', .F.} )
				EndIf
			EndIf
			If !lCasPre .Or. Iif(lAcaoLD, oModelLanc:GetValue(cTabLan + '_ACAOLD', nLine) == "5", .F.)
				nQtdTrans++ // Contabiliza lançamentos transferidos para fora da pré-fatura ou cujo AçãoLD força a retirada
			EndIf
		Else
			If !lIsRest //Se não for rest o cliente, loja e caso são sempre os mesmos, a validação serve para todos os lançamentos, então não prossegue a transferência
				Exit
			EndIf
		EndIf

	EndIf

Next nI

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202AltPF()
Rotina para alterar as préfatura cujos os lançamentos tranferidos podem ser vinculados.

@Param  aAltPreft    Código do Caso para a transferencia (passado por referência)
         aAltPreft[1] Tipo do lançamento 'TS'- time Sheet; 'DP'- Despesas; 'LT'- Lançamento Tabelado
         aAltPreft[2] Data do lançaemnto
         aAltPreft[3] Código do cliente destino
		 aAltPreft[4] Código da loja destino
		 aAltPreft[5] Código do Caso destino
@Param cPreft do lançamento transferido

@Return  aTransf       Array com as informações da pré-fatura
         aTransf[n][1] Código da pre-fatura;
         aTransf[n][2] Situação da pré-fatura
         aTransf[n][3] .T. se o caso do lançamento se encontra na pré-fatura.

@author Luciano Pereira dos Santos
@since 04/07/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202AltPF(aAltPreft, cPreft)
Local aArea       := GetArea()
Local aAreaNX0    := NX0->(GetArea())
Local nI          := 0
Local nY          := 0
Local aPreFat     := {}
Local cPartLog    := JurUsuario(__CUSERID)
Local cTpLanc     := ''
Local dDtlanc     := CTod('  /  /  ')
Local cGetClie    := ''
Local cGetLoja    := ''
Local cGetCaso    := ''
Local aTransf     := {}

Default aAltPreft := {}
Default cPreft    := ""

For nI := 1 To Len(aAltPreft)
	cTpLanc  := aAltPreft[nI][1]
	dDtlanc  := aAltPreft[nI][2]
	cGetClie := aAltPreft[nI][3]
	cGetLoja := aAltPreft[nI][4]
	cGetCaso := aAltPreft[nI][5]

	aPreFat  := JA202VERPRE(cGetClie, cGetLoja, cGetCaso, dDtlanc, cTpLanc)

	If !Empty(aPreFat)

		For nY := 1 To Len(aPreFat)
			If (aPreFat[nY][2] $ '2|3|D|E') .And. (aPreFat[nY][1] != cPreft)
				NX0->(dbSetOrder(1)) //NX0_FILIAL+NX0_COD+NX0_SITUAC
				If NX0->(dbSeek(xFilial('NX0') + aPreFat[nY][1]))
					RecLock('NX0', .F.)
					NX0->NX0_SITUAC := SIT_ALTERADA
					NX0->NX0_USRALT := cPartLog
					NX0->NX0_DTALT  := Date()
					NX0->(MsUnlock())
					NX0->(DbCommit())
					NX0->(DbSkip())
				EndIf

				J202HIST('99', aPreFat[nY][1], cPartLog, STR0240, "7")
			EndIf

			If aScan( aTransf, { |x| x[1] == aPreFat[nY][1] } ) == 0
				aAdd(aTransf, { aPreFat[nY][1], aPreFat[nY][2], aPreFat[nY][3]} )
			EndIf

		Next nY
	EndIf

Next nI

RestArea( aAreaNX0 )
RestArea( aArea )

Return aTransf

//-------------------------------------------------------------------
/*/{Protheus.doc} J202Transf()
Rotina para transferir por RecLock os lançamentos marcados no modelo.
@Obs: As validações para a transferencia devem ser feitas a partir do modelo

@param aRecNUE		Array com o recno dos timesheets.
@param aRecNVY		Array com o recno das despesas.
@param aRecNV4		Array com o recno dos serviços tabelados.
@param aRecNX1		Array com o Recno do Caso destino na mesma pré-fatura para ajuste das flags de lançamentos.
@param cPreft		Código da pré-fatura.

@Return lRet		.T. se concluiu operação com êxito

@author Luciano Pereira dos Santos
@since 08/25/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202Transf(aRecNUE, aRecNVY, aRecNV4, aRecNX1, cPreft)
Local lRet      := .T.
Local aArea     := GetArea()
Local aAreaNUE  := NUE->( GetArea() )
Local aAreaNVY  := NVY->( GetArea() )
Local aAreaNV4  := NV4->( GetArea() )
Local aAreaNX1  := NX1->( GetArea())
Local cCodLan   := ''
Local cGetGrup  := ''
Local cGetClie  := ''
Local cGetLoja  := ''
Local cGetCaso  := ''
Local cCliOld   := ''
Local cLojOld   := ''
Local cCasOld   := ''
Local lEbil     := .F.
Local cCobrar   := ""
Local cDescri   := ""
Local cAtiv     := ''
Local cFase     := ''
Local cTaref    := ''
Local cDocto    := ''
Local cOHBLanc  := ''
Local cCodPag   := ''
Local cDesbr    := ''
Local cDesbrPag := ''
Local nFor      := 0
Local lCasPre   := .F.
Local aConvLanc := {}
Local nCot1     := 0
Local nCot2     := 0
Local nVTEMP    := 0
Local cMoedaPf  := NX0->NX0_CMOEDA
Local dDtEmitPf := NX0->NX0_DTEMI
Local lExt202TR := ExistBlock('JA202TR')
Local lJurxFin  := SuperGetMV("MV_JURXFIN",, .F.) //Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico
Local lAcaoLD   := NUE->(ColumnPos("NUE_ACAOLD")) > 0
Local lAltHr    := NUE->(ColumnPos('NUE_ALTHR')) > 0
Local cTabAtu   := ""
Local lFinDesp  := FWAliasInDic("OHB") .And. FWAliasInDic("OHF") .And. FWAliasInDic("OHG") .And. FWAliasInDic("NZQ") // Proteção
Local cJurUser  := JurUsuario(__CUSERID)

BEGIN TRANSACTION

	// Altera apontamentos de honorarios
	For nFor := 1 To Len(aRecNUE)
		NUE->(DbGoTo(aRecNUE[nFor][1]))

		lCasPre  := aRecNUE[nFor][2]
		cGetGrup := aRecNUE[nFor][3]
		cGetClie := aRecNUE[nFor][4]
		cGetLoja := aRecNUE[nFor][5]
		cGetCaso := aRecNUE[nFor][6]
		aEbil    := aRecNUE[nFor][7]

		If !Empty(aEbil) .And. aEbil[1]
			lEbil  := aEbil[1]
			cAtiv  := aEbil[7]
			cFase  := aEbil[5]
			cTaref := aEbil[6]
			cDocto := aEbil[9]
		EndIf

		cCodLan  := NUE->NUE_COD
		cCliOld  := NUE->NUE_CCLIEN
		cLojOld  := NUE->NUE_CLOJA
		cCasOld  := NUE->NUE_CCASO

		RecLock("NUE", .F.)
		NUE->NUE_CGRPCL := cGetGrup
		NUE->NUE_CCLIEN := cGetClie
		NUE->NUE_CLOJA  := cGetLoja
		NUE->NUE_CCASO  := cGetCaso
		If !lCasPre .Or. Iif(lAcaoLD, NUE->NUE_ACAOLD == '5', .F.)
			NUE->NUE_CPREFT := ' '
			NUE->NUE_VALOR1 := 0
		EndIf
		If lEbil
			NUE->NUE_CTAREB := cAtiv
			NUE->NUE_CFASE  := cFase
			NUE->NUE_CTAREF := cTaref
			NUE->NUE_CDOC   := cDocto
		Else
			NUE->NUE_CTAREB := ""
			NUE->NUE_CFASE  := ""
			NUE->NUE_CTAREF := ""
			NUE->NUE_CDOC   := ""
		EndIf

		NUE->NUE_CUSERA := cJurUser
		NUE->NUE_ALTDT  := Date()
		If lAltHr
			NUE->NUE_ALTHR := Time()
		EndIf

		NUE->(MsUnlock())
		NUE->(DbCommit())

		If !lCasPre .Or. Iif(lAcaoLD, NUE->NUE_ACAOLD == '5', .F.)
			NW0->( dbSetOrder(1) ) //Ajusta a tabela de Vínculo
			If NW0->(DbSeek( xFilial("NW0") + cCodLan + "1" + cPreft ) )
				Reclock( "NW0", .F. )
				NW0->NW0_CANC := "1"
				NW0->(MsUnlock())
				NW0->(DbCommit())
			EndIf
		EndIf

		JA144VALTS( cCodLan, .T., .F. ) //revaloriza no timesheet transferido

		If lCasPre
			aConvLanc := JA201FConv(cMoedaPf, NUE->NUE_CMOEDA, NUE->NUE_VALOR, "2", dDtEmitPf, "", cPreft )//revaloriza no timesheet transferido
			nVTemp := aConvLanc[1]
			nCot1  := aConvLanc[2] // Moeda da condição (TS)
			nCot2  := aConvLanc[3] // Moeda da pré

			RecLock("NUE", .F.)
			NUE->NUE_VALOR1 := nVTEMP
			NUE->NUE_COTAC1 := nCot1
			NUE->NUE_COTAC2 := nCot2
			If NUE->(FieldPos('NUE_COTAC')) > 0 //Proteção
				NUE->NUE_COTAC := JurCotac(nCot1, nCot2)
			EndIf
			NUE->NUE_CUSERA := cJurUser
			NUE->NUE_ALTDT  := Date()
			If lAltHr
				NUE->NUE_ALTHR  := Time()
			EndIf
			NUE->(MsUnlock())
		EndIf

		//Grava na fila de sincronização
		If lIntegracao .And. !lRevisLD
			J170GRAVA("NUE", xFilial("NUE") + cCodLan, "4")
		EndIf

		If lExt202TR
			ExecBlock('JA202TR', .F., .F., {cCliOld, cLojOld, cCasOld, cGetClie, cGetLoja, cGetCaso, cCodLan } )
		EndIf
	Next nFor

	// Altera apontamentos de despesa
	For nFor := 1 To Len(aRecNVY)
		NVY->(DbGoTo(aRecNVY[nFor][1]))
		lCasPre   := aRecNVY[nFor][2]
		cGetGrup  := aRecNVY[nFor][3]
		cGetClie  := aRecNVY[nFor][4]
		cGetLoja  := aRecNVY[nFor][5]
		cGetCaso  := aRecNVY[nFor][6]
		cCodLan   := NVY->NVY_COD
		If lJurxFin
			cCobrar   := NVY->NVY_COBRAR
			cDescri   := NVY->NVY_DESCRI
			cOHBLanc  := NVY->NVY_CLANC
			cCodPag   := NVY->NVY_CPAGTO
			cDesbr    := NVY->NVY_ITDES
			cDesbrPag := NVY->NVY_ITDPGT
		EndIf

		RecLock("NVY", .F.)
		NVY->NVY_CGRUPO := cGetGrup
		NVY->NVY_CCLIEN := cGetClie
		NVY->NVY_CLOJA  := cGetLoja
		NVY->NVY_CCASO  := cGetCaso
		If !lCasPre .Or. Iif(lAcaoLD, NVY->NVY_ACAOLD == '5', .F.)
			NVY->NVY_CPREFT := ' '
		EndIf
		NVY->(MsUnlock())
		NVY->(DbCommit())

		If !lCasPre .Or. Iif(lAcaoLD, NVY->NVY_ACAOLD == '5', .F.)
			NVZ->( dbSetOrder(1) ) //Ajusta a tabela de Vínculo
			If NVZ->(DbSeek( xFilial("NVZ")+cCodLan+"1"+cPreft ) )
				Reclock( "NVZ", .F. )
				NVZ->NVZ_CANC := "1"
				NVZ->(MsUnlock())
				NVZ->(DbCommit())
			EndIf
		EndIf

		If lJurxFin .And. lFinDesp // Proteção
			cTabAtu := ""

			If !Empty(cOHBLanc)
				cTabAtu := "OHB"
			EndIf
			If !Empty(cCodPag) .And. !Empty(cDesbr)
				cTabAtu := "OHF"
			EndIf
			If !Empty(cCodPag) .And. !Empty(cDesbrPag)
				cTabAtu := "OHG"
			EndIf
			
			If !Empty(cTabAtu)
				J202DspTrf(cCodLan, cOHBLanc, cCodPag, cGetClie, cGetLoja, cGetCaso, cCobrar, cDescri, cTabAtu)
			EndIf
		EndIf

		//Grava na fila de sincronização
		If lIntegracao .And. !lRevisLD
			J170GRAVA("NVY", xFilial("NVY") + cCodLan, "4")
		EndIf
	Next nFor

	// Altera apontamentos tabelados
	For nFor := 1 To Len(aRecNV4)
		NV4->(DbGoTo(aRecNV4[nFor][1]))
		lCasPre  := aRecNV4[nFor][2]
		cGetGrup := aRecNV4[nFor][3]
		cGetClie := aRecNV4[nFor][4]
		cGetLoja := aRecNV4[nFor][5]
		cGetCaso := aRecNV4[nFor][6]
		cCodLan  := NV4->NV4_COD

		RecLock("NV4", .F.)
		NV4->NV4_CGRUPO := cGetGrup
		NV4->NV4_CCLIEN := cGetClie
		NV4->NV4_CLOJA  := cGetLoja
		NV4->NV4_CCASO  := cGetCaso

		If !lCasPre .Or. Iif(lAcaoLD, NV4->NV4_ACAOLD == '5', .F.)
			NV4->NV4_CPREFT := ' '
		EndIf
		NV4->(MsUnlock())
		NV4->(DbCommit())

		If !lCasPre .Or. Iif(lAcaoLD, NV4->NV4_ACAOLD == '5', .F.)
			NW4->( dbSetOrder(4) ) //Ajusta a tabela de Vínculo
			If NW4->(DbSeek( xFilial("NW4")+cCodLan+"1"+cPreft ) )
				Reclock( "NW4", .F. )
				NW4->NW4_CANC := "1"
				NW4->(MsUnlock())
				NW4->(DbCommit())
			EndIf

		EndIf

		//Grava na fila de sincronização
		If lIntegracao .And. !lRevisLD
			J170GRAVA("NV4", xFilial("NV4") + cCodLan, "4")
		EndIf
	Next nFor

	//Ajuste de flag de lançamentos no caso
	J202GrvNX1(aRecNX1)

	If lRet
		While __lSX8 //Libera os registros usados na transação
			ConfirmSX8()
		EndDo
	Else
		DisarmTransaction()
		While __lSX8 //Libera os registros usados na transação
			RollBackSX8()
		EndDo
		Break
	EndIf

END TRANSACTION

RestArea( aAreaNV4 )
RestArea( aAreaNVY )
RestArea( aAreaNUE )
RestArea( aAreaNX1 )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202TrfLog()
Rotina gerar o log da transferencia de lançamentos

@param cPreft		Codigo da pré-fatura.
@param lCancPre		.T. se prefetura não tem lançamentos e será cancelada
@param nTransfTS	Quantidade de TS tranferidos

@param nTransfDP	Quantidade de DP tranferidas

@param nTransfLT	Quantidade de LT tranferidos
@param aTransf		Array com as pré-faturas alteradas

@Param  aNotTransf    Array com as criticas da operação de tranferencia (passado por referência)
        aNotTransf[1] Tipo do lançamento 'TS' - time Sheet; 'DP' - Despesas; 'LT' - Lançamento Tabelado
        aNotTransf[2] Indicador da critica: 'INV' - Casos inválidos; 'EBI' - E-Billing;  'PER' - Caso não permite o tipo de lançamento ; 'ENC' - Casos encerrados;
        aNotTransf[3 até 5] Chave identificadora do registro ( depende do Indicador da critica )

@Return cMsglog		Mensagem de log da tranferencia

@author Luciano Pereira dos Santos
@since 25/08/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static function J202TrfLog(cPreft, lCancPre, nTransfTS, nTransfDP, nTransfLT, aTransf, aNotTransf)
Local cMsgLog    := ''
Local cMsgAux    := ''
Local cSeparador := CRLF + Replicate( "-", 65 ) + CRLF + CRLF
Local nI         := 0
Local cCliente   := ''
Local cLoja      := ''
Local cCaso      := ''
Local cCodLanc   := ''
Local cTipoLanc  := ''
Local aRecNX1    := {}
Local lIsRest    := Iif(FindFunction("JurIsRest"), JurIsRest(), .F.)

//Log de lançamentos tranferidos com sucesso
cMsgLog += Iif(nTransfTS > 0, cValtoChar(nTransfTS) + STR0161 + STR0241 + cSeparador, '') //#" Time Sheet(s)"  ##" transferido(s) com sucesso!"
cMsgLog += Iif(nTransfDP > 0, cValtoChar(nTransfDP) + STR0162 + STR0242 + cSeparador, '') //#" Despesa(s)"  ##" transferida(s) com sucesso!"
cMsgLog += Iif(nTransfLT > 0, cValtoChar(nTransfLT) + STR0163 + STR0241 + cSeparador, '') //#" Time Sheet(s)"  ##" transferido(s) com sucesso!"

//Log para Lançamentos transferidos não vinculados a pré-faturas (Disponíveis em Novos)
For nI := 1 to Len(aTransf)
	If (aTransf[nI][1] != cPreft) //não gera log para transferências entre caso dentro da pré-fatura
		cMsgAux := IIf(aTransf[nI][3], STR0120, STR0121) //#"O Caso destino está vinculado na pré-fatura '#1' com a situação '#2'." ##"O Caso destino pode ser vinculado à pré-fatura '#1' com a situação '#2'."
		cMsgLog += I18N(cMsgAux, {aTransf[nI][1], JurSitGet(aTransf[nI][2])})
		cMsgAux := IIf(aTransf[nI][2] $ '2|3|D|E', I18N(STR0249, {JurSitGet(SIT_ALTERADA)}), '') //"A pré-fatura passará para a situação '#1'."
		cMsgLog += cMsgAux + CRLF
	EndIf
	cMsgLog += IIf(nI == Len(aTransf), CRLF + STR0248 + cSeparador, '') //# "Obs.: Os lançamentos não foram associados automaticamente à pré-fatura de destino e se encontram disponíveis na opção 'Novos' em Operações de Pré-fatura."
Next nI

cMsgAux := ''

aSort(aNotTransf,,, { |aX,aY| cValtochar(aX[1])+aX[2]+aX[3]+aX[7] > cValtochar(aX[1])+aX[2]+aX[3]+aX[7] })

For nI:= 1 To Len(aNotTransf)

	If nI == 1
		nRecNX1O := aNotTransf[nI][1]
	EndIf
	cCliente    := aNotTransf[nI][4]
	cLoja       := aNotTransf[nI][5]
	cCaso       := aNotTransf[nI][6]
	cCodLanc    := aNotTransf[nI][7]
	dDtMaxLan   := aNotTransf[nI][8]

	Do Case
		Case aNotTransf[nI][2] == 'TS'
			cTipoLanc := I18N(STR0253, {cCodLanc}) //"o timesheet #1"
		Case aNotTransf[nI][2] == 'DP'
			cTipoLanc := I18N(STR0254, {cCodLanc}) //"a despesa #1"
		Case aNotTransf[nI][2] == 'LT'
			cTipoLanc := I18N(STR0255, {cCodLanc}) //"o lançamento tabelado #1"
	End Case

	cMsgAux += I18N(STR0257, {cTipoLanc, cCliente+'-'+cLoja, cCaso}) + CRLF //"Não foi possível transferir #1 para o cliente '#2' e caso '#3'."

	Do Case
		Case aNotTransf[nI][3] == 'INV'
			cMsgAux += STR0237 + cSeparador  //"As informações de cliente e caso não são válidas."
		Case aNotTransf[nI][3] == 'EBI'
			cMsgAux += STR0119 + cSeparador //"As informações de fase, tarefa e atividade e-billing não são válidas."
		Case aNotTransf[nI][3] == 'PER'
			cMsgAux += STR0239 + cSeparador //"O caso não permite digitar esse tipo de lançamento."
		Case aNotTransf[nI][3] == 'ENC'
			cMsgAux += I18N(STR0238, {dDtMaxLan}) + cSeparador //"A data do lançamento é posterior à '#1', data máxima permitida para digitar lançamentos no caso."
	EndCase

	If (nRecNX1O != aNotTransf[nI][1] .Or. Len(aNotTransf) == 1) //Separa as criticas de transferencia por caso de origem
		IIf(lIsRest, aADD(aRecNX1, {nRecNX1O, 'NX1_INSREV', CRLF + STR0240+':'+ CRLF + cMsgAux, .T.}), Nil) //"Transferência de lançamentos"
		nRecNX1O := aNotTransf[nI][1]
		cMsgLog  += cMsgAux
		cMsgAux  := ''

	EndIf

Next nI

J202GrvNX1(aRecNX1) //Grava o log de criticas por caso na instrução de revisão

If lCancPre //Não tem mais lançamentos na pré-fatura e será cancelada
	cMsgLog += I18N(STR0258, {cPreft}) + cSeparador //#"A pré-fatura #1 não possui mais lançamentos e foi cancelada."
EndIf

Return cMsglog

//-------------------------------------------------------------------
/*/{Protheus.doc} J202GrvNX1(aRecNX1)
Rotina para complementar alterações no caso da pré fatura.

@Param   aRecNX1   Array com:
                     [n][1] Recno da NX1;
                     [n][2] Campo da NX1 para alteração
                     [n][3] Informação da alteração
                     [n][4] .T. Adiciona, .F. Sobrescreve

@author Luciano Pereira dos Santos
@since 26/03/10
@version 2.0
/*/
//-------------------------------------------------------------------
Static Function J202GrvNX1(aRecNX1)
Local cCasoCpo  := ''
Local cCasoInf  := ''
Local nFor      := 0

For nFor := 1 To Len(aRecNX1)
	NX1->(DbGoTo(aRecNX1[nFor][1]))
	cCasoCpo := aRecNX1[nFor][2]
	If aRecNX1[nFor][4]
		cCasoInf := NX1->(FieldGet(FieldPos(cCasoCpo))) + aRecNX1[nFor][3]
	Else
		cCasoInf := aRecNX1[nFor][3]
	EndIf
	NX1->(RecLock("NX1", .F.))
	NX1->(FieldPut(FieldPos(cCasoCpo), cCasoInf))
	NX1->(DbCommit())
	NX1->(MsUnlock())
Next nFor

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202VERPRE
Rotina para validar se existe pré-fatura para o Caso.
Alterado query para identificar casos de contratos pertencentes a uma junção
que não estam em pré-fatura.

@Param   cCliente  Cliente a ser verificado
@Param   cLoja     Loja a ser verificada
@Param   cCaso     Caso a ser verificado
@Param   dData     Data do lançamento
@Param   cTipo     Indica o tipo do lançamento: TS = Time Sheet / DP = Despesa / LT = lançamento Tabelado
@Param   cTpDesp   Verifica se e um tipo de despesa cobrável

@Return  aRet      Array com:
                     [n][1] Código da pre-fatura;
                     [n][2] Situação da pré-fatura
                     [n][3] .T. se o caso do lançamento se encontra na pré-fatura.

@author Jacques Alves Xavier
@since 26/03/10
@version 2.0
/*/
//-------------------------------------------------------------------
Function JA202VERPRE(cCliente, cLoja, cCaso, dData, cTipo, cTpDesp)
Local aRet       := {}
Local cQuery     := ''
Local aArea      := GetArea()
Local cResQRY    := GetNextAlias()
Local lVincTS    := SuperGetMv('MV_JVINCTS ',, .T.) //Vinc TS em contrato Fixo
Local cSpcVigenc := ""

Default cTpDesp  := ''

If !Empty(dData)
	dData  := Iif(ValType(dData) == "C", StoD(dData), dData)

	cQuery := " SELECT NX0.NX0_COD, NX0.NX0_SITUAC, NX1.NX1_CPREFT "
	cQuery +=   " FROM " + RetSqlName("NX0") + " NX0 "
	cQuery +=          " INNER JOIN " + RetSqlName("NT0") + " NT0 ON "
	cQuery +=                       "( NT0.NT0_FILIAL = '" + xFilial( "NT0" ) +"' "
	cQuery +=                        " AND NT0.D_E_L_E_T_ = ' ' "
	cQuery +=                        " AND NT0.NT0_ATIVO = '1' "
	cQuery +=                        " AND NT0.NT0_SIT = '2' "

	If NT0->(ColumnPos("NT0_DTVIGI")) > 0
		cSpcVigenc := Space(TamSx3('NT0_DTVIGI')[1])

		cQuery +=                    " AND ((NT0.NT0_DTVIGI <= '" + DtoS(dData) + "' AND NT0.NT0_DTVIGF >= '" + DtoS(dData) + "') "
		cQuery +=                    "      OR (NT0.NT0_DTVIGI = '" + cSpcVigenc + "' AND NT0.NT0_DTVIGF = '" + cSpcVigenc + "')) "
	EndIf
	cQuery +=                      " ) "

	cQuery +=          " INNER JOIN " + RetSqlName("NVE") + " NVE ON "
	cQuery +=                       "( NVE.NVE_FILIAL = '" + xFilial( "NVE" ) +"' "
	cQuery +=                        " AND NVE.D_E_L_E_T_ = ' ' "
	cQuery +=                        " AND NVE.NVE_CCLIEN = '" + cCliente + "' "
	cQuery +=                        " AND NVE.NVE_LCLIEN = '" + cLoja + "' "
	cQuery +=                        " AND NVE.NVE_NUMCAS = '" + cCaso + "' )"

	cQuery +=          " INNER JOIN " + RetSqlName("NUT") + " NUT ON "
	cQuery +=                       "( NUT.NUT_FILIAL = '" + xFilial( "NUT" ) +"' "
	cQuery +=                        " AND NUT.D_E_L_E_T_ = ' ' "
	cQuery +=                        " AND NUT.NUT_CCONTR = NT0.NT0_COD "
	cQuery +=                        " AND NUT.NUT_CCLIEN = NVE.NVE_CCLIEN "
	cQuery +=                        " AND NUT.NUT_CLOJA  = NVE.NVE_LCLIEN "
	cQuery +=                        " AND NUT.NUT_CCASO  = NVE.NVE_NUMCAS ) "

	cQuery +=     " LEFT OUTER JOIN " +RetSqlName("NX1") + " NX1 ON "
	cQuery +=                       "( NX1.NX1_FILIAL = '" + xFilial( "NX1" ) +"' "
	cQuery +=                        " AND NX1.D_E_L_E_T_ = ' ' "
	cQuery +=                        " AND NX1.NX1_CPREFT = NX0.NX0_COD "
	cQuery +=                        " AND NX1.NX1_CCLIEN = NVE.NVE_CCLIEN "
	cQuery +=                        " AND NX1.NX1_CLOJA  = NVE.NVE_LCLIEN "
	cQuery +=                        " AND NX1.NX1_CCASO  = NVE.NVE_NUMCAS ) "

	If cTipo = 'DP' .And. !Empty(cTpDesp)
		cQuery += " LEFT OUTER JOIN " + RetSqlName("NTK") + " NTK ON " //Despesas cobravel no Contrato
		cQuery +=                   "( NTK.NTK_FILIAL = '" + xFilial("NTK") + "' "
		cQuery +=                     " AND NTK.D_E_L_E_T_ = ' ' "
		cQuery +=                     " AND NTK.NTK_CCONTR = NT0.NT0_COD "
		cQuery +=                     " AND NTK.NTK_CTPDSP = '" +cTpDesp+ "' )" 
	EndIf

	cQuery +=   " WHERE NX0.NX0_FILIAL = '" + xFilial( "NX0" ) +"' "
	cQuery +=     " AND NX0.D_E_L_E_T_ = ' ' "
	cQuery +=     " AND NX0.NX0_SITUAC IN ('2','3','4','5','6','7','9','A','B','C','D','E','F') "
	cQuery +=     " AND ( NX0.NX0_CCONTR = NT0.NT0_COD "
	cQuery +=           " OR EXISTS (SELECT NW3.R_E_C_N_O_ "
	cQuery +=                                   " FROM " + RetSqlName("NW3") + " NW3 "
	cQuery +=                                   " WHERE NW3.NW3_FILIAL = '" + xFilial("NW3") + "' "
	cQuery +=                                     " AND NW3.NW3_CJCONT = NX0.NX0_CJCONT "
	cQuery +=                                     " AND NW3.NW3_CCONTR = NT0.NT0_COD "
	cQuery +=                                     " AND NW3.D_E_L_E_T_ = ' ') "
	cQuery +=          " ) "

	If cTipo = 'TS'
		cQuery += " AND '" + DtoS(dData) + "' BETWEEN NX0.NX0_DINITS AND NX0.NX0_DFIMTS "
		cQuery += " AND NT0.NT0_ENCH = '2' "
		cQuery += " AND EXISTS ( SELECT NRA.R_E_C_N_O_ "
		cQuery +=               " FROM  " + RetSqlName("NRA") + " NRA "
		cQuery +=               " WHERE NRA.NRA_FILIAL = '" + xFilial( "NRA" ) +"' "
		cQuery +=                 " AND NRA.NRA_COD = NT0.NT0_CTPHON "
		cQuery +=                 " AND ( NRA.NRA_COBRAH = '1' "
		If lVincTS
			cQuery +=                 " OR ( NRA.NRA_COBRAF = '1'  "
			cQuery +=                   " AND EXISTS (SELECT NT1.R_E_C_N_O_ "
			cQuery +=                                 " FROM " + RetSqlName("NT1") + " NT1 "
			cQuery +=                                " INNER JOIN " + RetSqlName("NTH") + " NTH " 
			cQuery +=                                   " ON NTH.NTH_FILIAL = '" + xFilial("NTH") + "' "
			cQuery +=                                  " AND NTH.NTH_CAMPO = 'NT0_FXABM' "
			cQuery +=                                  " AND NTH.D_E_L_E_T_ = ' ' "
			cQuery +=                                " WHERE NT1.NT1_FILIAL = '" + xFilial("NT1") + "' "
			cQuery +=                                 "  AND NTH.NTH_CTPHON = NT0.NT0_CTPHON "
			cQuery +=                                 "  AND NT1.NT1_CCONTR = NT0.NT0_COD "
			cQuery +=                                 "  AND NT1.NT1_CPREFT = NX0.NX0_COD "
			cQuery +=                                 "  AND NT1.D_E_L_E_T_ = ' ' "
			// Se não for Faixa Qtdade de Casos
			cQuery +=                                  " AND (CASE WHEN NTH.NTH_VISIV = '2' THEN "
			cQuery +=                                          " (CASE WHEN NVE.NVE_SITUAC = '1' THEN (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) ELSE "
			cQuery +=                                             " (CASE WHEN NVE.NVE_DTENCE >= NT1.NT1_DATAIN AND NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) "
			cQuery +=                                          " END) "
			cQuery +=                                       " ELSE "
			// Faixa - Qtdade de Casos - verifica o conteúdo dos campos NT0_FXABM e NT0_FXENCM além da situação do caso
			cQuery +=                                          " (CASE WHEN NTH.NTH_VISIV = '1' THEN "
			cQuery +=                                              " (CASE WHEN NVE.NVE_SITUAC = '1' THEN "
			cQuery +=                                                  " (CASE WHEN NT0.NT0_FXABM = '1' THEN  "
			cQuery +=                                                      " (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) "
			cQuery +=                                                   " ELSE "
			cQuery +=                                                       " (CASE WHEN NVE.NVE_DTENTR < NT1.NT1_DATAIN THEN '1' ELSE '2' END) "
			cQuery +=                                                   " END) " 
			cQuery +=                                               " ELSE "  
			cQuery +=                                                  " (CASE WHEN NT0.NT0_FXABM = '1' THEN "
			cQuery +=                                                      " (CASE WHEN NT0.NT0_FXENCM = '1' THEN "
			cQuery +=                                                          " (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI AND NVE.NVE_DTENCE >= NT1.NT1_DATAIN THEN '1' ELSE '2' END) "
			cQuery +=                                                       " ELSE "
			cQuery +=                                                          " (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI AND NVE.NVE_DTENCE > NT1.NT1_DATAFI THEN '1' ELSE '2' END) "
			cQuery +=                                                       " END ) "
			cQuery +=                                                   " ELSE "
			cQuery +=                                                      " (CASE WHEN NT0.NT0_FXENCM = '1' THEN "
			cQuery +=                                                          " (CASE WHEN NVE.NVE_DTENTR < NT1.NT1_DATAIN AND NVE.NVE_DTENCE >= NT1.NT1_DATAIN THEN '1' ELSE '2' END) "
			cQuery +=                                                       " ELSE  "
			cQuery +=                                                          " (CASE WHEN NVE.NVE_DTENTR < NT1.NT1_DATAIN AND NVE.NVE_DTENCE > NT1.NT1_DATAFI THEN '1' ELSE '2' END) " 
			cQuery +=                                                       " END) "
			cQuery +=                                                   " END) "
			cQuery +=                                               " END) "
			cQuery +=                                           " END) "
			cQuery +=                                        " END) <> '2' ) "
			cQuery +=                                       " ) "
		EndIf
		cQuery +=                      " ) "
		cQuery +=                " AND NRA.D_E_L_E_T_ = ' ' "
		cQuery +=            " ) "
		cQuery += " AND NVE.NVE_ENCHON = '2' "
	EndIf
	
	If cTipo = 'DP'
		cQuery += " AND '" + DtoS(dData) + "' BETWEEN NX0.NX0_DINIDP AND NX0.NX0_DFIMDP "
		cQuery += " AND NT0.NT0_ENCD = '2' "
		cQuery += " AND NT0.NT0_DESPES = '1' "
		cQuery += " AND NVE.NVE_ENCDES = '2' "
		If !Empty(cTpDesp)
			cQuery += "	AND EXISTS ( SELECT NRH.R_E_C_N_O_ "
			cQuery +=                 " FROM " + RetSqlName("NRH") + " NRH " 
			cQuery +=                 " WHERE NRH.NRH_FILIAL = '" + xFilial( "NRH" ) +"' "
			cQuery +=                 "	AND NRH.NRH_COD = '" +cTpDesp+ "'" 
			cQuery +=                 " AND NRH.NRH_COBRAR = '1' "   //Despesas cobravel no Tipo de Despesas
			cQuery +=                 " AND NRH.D_E_L_E_T_ = ' ' "
			cQuery +=             " ) "

			cQuery += " AND IsNull(NTK.R_E_C_N_O_, 0) = 0 "
		EndIf
	EndIf
	If cTipo = 'LT'
		cQuery += " AND '" + DtoS(dData) + "' BETWEEN NX0.NX0_DINITB AND NX0.NX0_DFIMTB "
		cQuery += " AND NT0.NT0_ENCT = '2' "
		cQuery += " AND NT0.NT0_SERTAB = '1' "
		cQuery += " AND NVE.NVE_ENCTAB = '2' "
	EndIf

	cQuery +=     " GROUP BY NX0.NX0_COD, NX0.NX0_SITUAC, NX1.NX1_CPREFT  "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQRY, .T., .T.)

	(cResQRY)->(dbGoTop())
	While !(cResQRY)->(EOF())

		aAdd(aRet, { (cResQRY)->NX0_COD, (cResQRY)->NX0_SITUAC, !Empty((cResQRY)->NX1_CPREFT) } )

		(cResQRY)->( dbSkip() )
	EndDo

	(cResQRY)->( dbcloseArea() )
EndIf

RestArea( aArea )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202F3NXA
Rotina para o F3 NXA1

@author Felipe Bonvicini Conti
@since 31/05/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J202F3NXA()
Local cRet := "@#@#"

If ValType(cEscri) <> 'U'
	cRet := "@#NXA->NXA_CESCR == '" + cEscri + "'" + " .And. NXA->NXA_SITUAC == '1' .And. NXA->NXA_TIPO == 'FT'" + "@#"
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaGenerico()
Rotina para gravar as alterações de NUE, NVY e NV4

@author Jacques Alves Xavier
@since 10/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GravaGenerico(oObjeto)
Local lRet      := .T.
Local aDados    := {}
Local aStruct   := {}
Local aTable    := {}
Local cAlias    := ""
Local nY        := 0
Local nX        := 0

aDados    := oObjeto:GetData()
aStruct   := oObjeto:oFormModelStruct:GetFields()
aTable    := oObjeto:oFormModelStruct:GetTable()

If !Empty(aTable)
	cAlias := aTable[FORM_STRUCT_TABLE_ALIAS_ID]

	BEGIN TRANSACTION
		For nY := 1 To Len(aDados)
			If aDados[nY][MODEL_GRID_ID] > 0
				oObjeto:GoLine(nY)
				If !aDados[nY][MODEL_GRID_DELETE]
					(cAlias)->(MsGoto(aDados[nY][MODEL_GRID_ID]))
					If RecLock(cAlias, .F.)
						For nX := 1 To Len(aStruct)
							If !aStruct[nX][MODEL_FIELD_VIRTUAL]
								If aDados[nY][MODEL_GRID_DATA][MODEL_GRIDLINE_UPDATE][nX] .Or. aDados[nY][MODEL_GRID_ID] == 0
									If (cAlias)->(FieldPos(aStruct[nX][MODEL_FIELD_IDFIELD])) > 0
										(cAlias)->(FieldPut(FieldPos(aStruct[nX][MODEL_FIELD_IDFIELD]), aDados[nY][MODEL_GRID_DATA][MODEL_GRIDLINE_VALUE][nX]))
									EndIf
								EndIf
							EndIf
						Next nX
						(cAlias)->(MsUnlock())
						(cAlias)->(DbCommit())
						(cAlias)->(DbSkip())
					Else
						lRet := .F.
						Exit
					EndIf
				EndIf
			EndIf
		Next nY

		If !lRet
			DISARMTRANSACTION()
		EndIf
	END TRANSACTION

EndIf

If lRet
	oObjeto:GoLine(1)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202TKTDS
Função recursiva para adicionar a marca aos campos das tabelas.

@author Felipe Bonvicini Conti
@since 14/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J202TKTDS(cTabela, lRecur, lMarca, lIsLoad)
Local oModel     := FwModelActive()
Local oView      := Nil
Local aSaveLines := FwSaveRows()
Local lRet       := .T.
Local cCampo     := cTabela+"_TKRET"
Local oGrid      := Nil
Local nQtd       := 0
Local nI         := 0

Default lRecur   := .F.
Default lMarca   := .F.
Default lIsLoad  := .F.

	If IsJura202()

		oGrid  := oModel:GetModel(cTabela + "DETAIL")
		If lRecur .And. !oGrid:IsEmpty()

			nQtd   := oGrid:GetQtdLine()
			For nI := 1 To nQtd
				oGrid:GoLine(nI)
				If !oGrid:CanUpdateLine()
					oGrid:SetNoUpdateLine(.F.)
				EndIf
				If !oGrid:IsDeleted()
					If lIsLoad
						lRet := JurLoadValue( oGrid, cCampo,, lMarca )
					Else
						lRet := JurSetValue( oGrid, cCampo,, lMarca )
					EndIf

					If !lRet
						JurMsgErro(STR0131 + cCampo) // "Não foi possivel atribuir valor via recursividade ao campo: "
						Exit
					EndIf
				EndIf
			Next

		EndIf

		Do Case
			Case cTabela == "NX8" // Contrato

				FWMsgRun( , {|| __InMsgRun:=.T.,;
									lRet := J202TKTDS("NT1", .T., oGrid:GetValue(cCampo), .T.) .And.;  // Fixo
											J202TKTDS("NX1", .T., oGrid:GetValue(cCampo)), ;  // Casos
											__InMsgRun := .F.},;
						STR0147, STR0167) // #"Aguarde..." ##"Atualizando Lançamentos"

			Case cTabela == "NX1" // Casos

				If !oGrid:GetValue(cCampo)
					If oModel:GetModel("NX8DETAIL"):GetValue("NX8_TKRET")
						JurloadValue( oModel:GetModel("NX8DETAIL"), "NX8_TKRET", , .F. )
					EndIf
				EndIf

				FWMsgRun( , {|| __InMsgRun := .T. ,;
									lRet := J202TKTDS("NX2", .T., oGrid:GetValue(cCampo), .T.) .And.; // Profissionais
											J202TKTDS("NUE", .T., oGrid:GetValue(cCampo), .T.) .And.; // TS
											J202TKTDS("NVY", .T., oGrid:GetValue(cCampo), .T.) .And.;// Despesas
											J202TKTDS("NV4", .T., oGrid:GetValue(cCampo), .T.), ;// Lanc Tabelados
											__InMsgRun := .F.},;
						STR0147, STR0167) // #"Aguarde..." ##"Atualizando Lançamentos"

			Case cTabela == "NX2" // Profissionais

				FWMsgRun(, {|| __InMsgRun:=.T. , lRet := J202TKLANC(oGrid:GetValue(cCampo)), __InMsgRun := .F.}, STR0147, STR0167) // #"Aguarde..." ##"Atualizando Lançamentos"

		EndCase

		If !lRecur
			oView := FwViewActive()
			If ValType(oView) == "O"
				oView:Refresh()
			EndIf
		EndIf

	EndIf

	FwRestRows(aSaveLines)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202RTKT
Função para desmarcar o caso e contrato de um lançamento desmarcado.

@author Luciano Pereira dos Santos
@since 14/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J202RTKT(cTabela)
Local lRet       := .T.
Local oModel     := Nil
Local cCampo     := cTabela + "_TKRET"

If IsJura202() .And. !IsInCallStack("J202TKTDS") .And. cTabela $ ("NUE,NVY,NV4,NT1")

 	oModel := FwModelActive()

	If !oModel:GetModel(cTabela + "DETAIL"):GetValue(cCampo)
		If cTabela $ ("NUE,NVY,NV4")
			If oModel:GetModel("NX1DETAIL"):GetValue("NX1_TKRET")
				JurloadValue( oModel:GetModel("NX1DETAIL"), "NX1_TKRET",, .F. )
			EndIf
		EndIf

		If oModel:GetModel("NX8DETAIL"):GetValue("NX8_TKRET")
			JurloadValue( oModel:GetModel("NX8DETAIL"), "NX8_TKRET",, .F. )
		EndIf
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurLoadValue
Faz LoadValue de um campo com exibicao de mensagem em caso de erro

@author Felipe Bonvicini Conti
@since 16/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurLoadValue( oModel, cRef1, cRef2, xConteudo )
	Local lRet      := .T.
	Local lMuda     := .F.
	Local xOldValue := Nil
	Local nLine     := 0
	Local lIsRest   := IIF(FindFunction("JurIsRest"), JurIsRest(), .F.)

	Default oModel  := FWModelActive()
	Default cRef1   := ''
	Default cRef2   := ''

	If lRet .And. ValType(oModel) <> 'O'
		lRet := .F.
	EndIf

	If lRet .And. Empty(cRef1)
		lRet := .F.
	EndIf

	If lRet
		If oModel:ClassName() == 'FWFORMGRID'
			If !oModel:CanUpdateLine()
				oModel:SetNoUpdateLine(.F.)
				lMuda:= .T.
			EndIf
			nLine := oModel:GetLine()
		EndIf
	EndIf

	If Empty(cRef2)
		xOldValue := oModel:GetValue(cRef1)
		lRet      := oModel:LoadValue(cRef1, xConteudo)
	Else
		xOldValue := oModel:GetValue(cRef1, cRef2)
		lRet      := oModel:LoadValue(cRef1, cRef2, xConteudo)
	EndIf

	If lMuda
		oModel:SetNoUpdateLine(.T.)
	EndIf

	If !lRet
		If Type("cInstanc") <> "U" .And. !(Substr(cRef1, 1, 3) == cInstanc)
			JurShowErro( oModel:GetModel():GetErrorMessage(), , , .F. )
		Else
			JurShowErro( oModel:GetModel():GetErrorMessage() )
		EndIf
	EndIf

	If lIsRest
		J202RLog(oModel, oModel:GetID(), nLine, IIF(Empty(cRef1), cRef2, cRef1), xConteudo, xOldValue)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202VSU5
Valida se o contato está ativo e a vinculacao do Contato com o Cliente

@author Juliana Iwayama Velho
@since 01/09/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202VSU5()
Return JURCONTOK('SA1', M->NX0_CCONTA, xFilial("SA1") + M->NX0_CCLIEN + M->NX0_CLOJA, "SU5->U5_ATIVO=='1'")

//-------------------------------------------------------------------
/*/{Protheus.doc} J202CanMin
Valida se a pre-fatura possui minuta emitida ao sofrer alteração na 
situação e cancela a minuta da pre-fatura.

@Param cNumPre   , Numero da pre-fatura
@Param cMotivo   , Motivo do cancelamento
@Param cQryCanMin, Variavel a ser utilizada para montar a query
@Param cAlsCanMin, Alias a ser utilizado pela query
@param lBindParam, Indica se a função MPSysOpenQuery faz o bind de queries

@author Jacques Alves Xavier
@since  21/09/2010
/*/
//-------------------------------------------------------------------
Function J202CanMin(cNumPre, cMotivo, cQryCanMin, cAlsCanMin, lBindParam)
Local lRet         := .T.
Local aArea        := GetArea()
Local aAreaNXA     := NXA->(GetArea())
Local lMinutaPre   := .T.
Local cQuery       := ""

Default cMotivo    := ""
Default cQryCanMin := ""
Default cAlsCanMin := ""
Default lBindParam := __FWLibVersion() >= "20211116" // Na execução do MPSysOpenQuery o parâmetro aBindParam e o conceito de bind de queries só está disponível a partir da lib label 20211116

	If Empty(cAlsCanMin)
		cAlsCanMin := GetNextAlias()
		cQryCanMin := "SELECT NXA.R_E_C_N_O_ NXA_RECNO "
		cQryCanMin +=  " FROM " + RetSqlName("NXA") + " NXA "
		cQryCanMin += " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") + "' "
		cQryCanMin +=   " AND NXA.NXA_CPREFT = ? "
		cQryCanMin +=   " AND NXA.NXA_SITUAC = '1' "
		cQryCanMin +=   " AND NXA.NXA_TIPO IN ('MP','MF','MS') "
		cQryCanMin +=   " AND NXA.D_E_L_E_T_ = ' ' "
	EndIf

	// Quando lBindParam é .F. indica que na lib atual a função MPSysOpenQuery não faz a substituição dos "?" na query.
	// Por isso executamos a função J202QryBind, para fazer essa substuição
	cQuery := IIf(lBindParam, cQryCanMin, J202QryBind(cQryCanMin, {cNumPre}))

	MPSysOpenQuery(cQuery, cAlsCanMin,,, {cNumPre})

	Do While (cAlsCanMin)->(!Eof())
		NXA->(DbGoto((cAlsCanMin)->NXA_RECNO))

		If !JA204CanFa(cMotivo,,,, lMinutaPre)
			lRet := .F.
			Exit
		EndIf
		(cAlsCanMin)->(dbSkip())
	EndDo

	(cAlsCanMin)->(DbCloseArea())

	RestArea(aAreaNXA)
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202TKLANC
Função para marcar os times sheets do participante

@author Luciano Pereira dos Santos
@since 08/01/17
@version 2.0
/*/
//-------------------------------------------------------------------
Function J202TKLANC(lMarca)
Local oModel     := FwModelActive()
Local oGrid      := oModel:GetModel("NUEDETAIL")
Local oModelNX2  := oModel:GetModel("NX2DETAIL")
Local aSaveLines := FwSaveRows()
Local lRet       := .T.
Local nQtd       := oGrid:GetQtdLine()
Local nI         := 0
Local cPart      := oModelNX2:GetValue("NX2_CPART")
Local nValorH    := oModelNX2:GetValue("NX2_VALORH")
Local cCateg     := oModelNX2:GetValue("NX2_CCATEG")
Local cMoTbH     := oModelNX2:GetValue("NX2_CMOTBH")
Local cLTab      := oModelNX2:GetValue("NX2_CLTAB")

If IsJura202()
	If !oGrid:IsEmpty()
		For nI := 1 To nQtd
			If !oGrid:IsDeleted(nI) .And. ;
					cPart == oGrid:GetValueByPos(__aNUEPosFields[POS_NUE_CPART2], nI) .And.;
					cCateg == oGrid:GetValueByPos(__aNUEPosFields[POS_NUE_CCATEG], nI) .And.;
					nValorH == oGrid:GetValueByPos(__aNUEPosFields[POS_NUE_VALORH], nI) .And.;
					cMoTbH == oGrid:GetValueByPos(__aNUEPosFields[POS_NUE_CMOEDA], nI) .And.;
					cLTab == oGrid:GetValueByPos(__aNUEPosFields[POS_NUE_CLTAB], nI)

				oGrid:GoLine(nI)

				If !__JurLoadValue(oGrid, __aNUEPosFields[POS_NUE_TKRET], lMarca, .F. )

					lRet := JurMsgErro(STR0131 + 'NUE_TKRET') // "Não foi possivel atribuir valor via recursividade ao campo: "
					Exit
				EndIf
			EndIf
		Next nI

	EndIf

EndIf

FwRestRows(aSaveLines)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202Anexo

@author Felipe Bonvicini Conti
@since 29/04/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202Anexo(oBotao)
Local oMenuAnexo
Local oMenuItem  := {}

	oMenu := MenuBegin(,,,, .T.,, oBotao, )
	aAdd( oMenuItem, MenuAddItem( STR0146,,, .T.,,,, oMenuAnexo, ;
																{ || IF(!Empty(FwFldGet("NX8_CCONTR")), JURANEXDOC("NT0", "NX8DETAIL", "", "NX8_CCONTR", , , , , , , , , , .T.), ) },,,,, { || .T. } ) ) // "Contrato ""Anexos"
	MenuEnd()

	oMenu:Activate( 10, 10, oBotao )

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} J202Marcar

@author Felipe Bonvicini Conti
@since 04/05/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202Marcar(oView, oBotao)
Local lRet       := .T.
Local oMenuAnexo
Local oMenuItem  := {}

	If oView:GetFolderActive("FOLDER_01", 2)[1] <> 1 // Somente na aba de Pré-fatura
		MsgInfo(STR0221) // "Esta ação é permitida somente na aba de Pré-Fatura!"
		lRet := .F.
	EndIf

	If lRet
		oMenu := MenuBegin(,,,, .T.,, oBotao, )
			/*01*/aAdd( oMenuItem, MenuAddItem( STR0003,,, .T.,,,, oMenuAnexo, { || FWMsgRun( , {|| J202MrkNX8(oView) }, STR0147, STR0167 ) },,,,, { || .T. } ) ) // "Contrato" ##Atualizando Lançamentos
			/*02*/aAdd( oMenuItem, MenuAddItem( STR0029,,, .T.,,,, oMenuAnexo, { || J202MarcALL(oView, 'NT1DETAIL', "NT1_TKRET") },,,,, { || .T. } ) ) // "Fixo"
			/*03*/aAdd( oMenuItem, MenuAddItem( STR0004,,, .T.,,,, oMenuAnexo, { || FWMsgRun( , {|| J202MrkNX1(oView) }, STR0147, STR0167 ) },,,,, { || .T. } ) ) // "Casos"  ##Atualizando Lançamentos
			/*04*/aAdd( oMenuItem, MenuAddItem( STR0030,,, .T.,,,, oMenuAnexo, { || J202MarcALL(oView, 'NX2DETAIL', "NX2_TKRET") },,,,, { || .T. } ) ) // "Profissionais"

			/*05*/aAdd( oMenuItem, MenuAddItem( STR0008,,, .T.,,,, oMenuAnexo, { || },,,,, { || .T. } ) ) // "Time-Sheet"
			/*06*/aAdd( oMenuItem, MenuAddItem( STR0075,,, .T.,,,, oMenuItem[5], { || FWMsgRun( , { || J202MarcALL(oView, 'NUEDETAIL', "NUE_TKRET") }, STR0147, STR0167)},,,,, { || .T. } ) ) // "Time-Sheet - caso"
			/*07*/aAdd( oMenuItem, MenuAddItem( STR0146,,, .T.,,,, oMenuItem[5], { || FWMsgRun( , { || JA202MPre(oView, "NUE", "CONT") }, STR0147, STR0167)},,,,, { || .T. } ) ) // "Time-Sheet - contrato"
			/*08*/aAdd( oMenuItem, MenuAddItem( STR0026,,, .T.,,,, oMenuItem[5], { || FWMsgRun( , { || JA202MPre(oView, "NUE", "PRE" ) }, STR0147, STR0167)},,,,, { || .T. } ) ) // "Time-Sheet - pré"

			/*09*/aAdd( oMenuItem, MenuAddItem( STR0009,,, .T.,,,, oMenuAnexo, { ||  },,,,, { || .T. } ) ) // "Despesas"
			/*10*/aAdd( oMenuItem, MenuAddItem( STR0075,,, .T.,,,, oMenuItem[9], { || FWMsgRun( , { || J202MarcALL(oView, 'NVYDETAIL', "NVY_TKRET") }, STR0147, STR0167)} ,,,,, { || .T. } ) ) // "Despesas - caso"
			/*11*/aAdd( oMenuItem, MenuAddItem( STR0146,,, .T.,,,, oMenuItem[9], { || FWMsgRun( , { || JA202MPre(oView, "NVY", "CONT") }, STR0147, STR0167)} ,,,,, { || .T. } ) ) // "Despesas - contrato"
			/*12*/aAdd( oMenuItem, MenuAddItem( STR0026,,, .T.,,,, oMenuItem[9], { || FWMsgRun( , { || JA202MPre(oView, "NVY", "PRE" ) }, STR0147, STR0167)} ,,,,, { || .T. } ) ) // "Despesas - pré"

			/*13*/aAdd( oMenuItem, MenuAddItem( STR0010,,, .T.,,,, oMenuAnexo, { ||  },,,,, { || .T. } ) ) // "Lanc.Tabelado"
			/*14*/aAdd( oMenuItem, MenuAddItem( STR0075,,, .T.,,,, oMenuItem[13], { || FWMsgRun( , { || J202MarcALL(oView, 'NV4DETAIL', "NV4_TKRET") }, STR0147, STR0167)} ,,,,, { || .T. } ) ) // "Lanc.Tabelado - caso"
			/*15*/aAdd( oMenuItem, MenuAddItem( STR0146,,, .T.,,,, oMenuItem[13], { || FWMsgRun( , { || JA202MPre(oView, "NV4", "CONT") }, STR0147, STR0167)} ,,,,, { || .T. } ) ) // "Lanc.Tabelado - contrato"
			/*16*/aAdd( oMenuItem, MenuAddItem( STR0026,,, .T.,,,, oMenuItem[13], { || FWMsgRun( , { || JA202MPre(oView, "NV4", "PRE" ) }, STR0147, STR0167)} ,,,,, { || .T. } ) ) // "Lanc.Tabelado - pré"

			/*17*/aAdd( oMenuItem, MenuAddItem( STR0231,,, .T.,,,, oMenuAnexo, { || FWMsgRun( , {|| J202DesmarcAll(oView) }, STR0147, STR0167)},,,,, { || .T. } ) ) // "Desmarcar tudo"

		MenuEnd()

		oMenu:Activate( 10, 10, oBotao )

	EndIf

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} J202MarcarNX1
Rotina para marcar todos os casos e lançamentos vinculados do contrato
posicionado na pré-fatura.

@author Luciano Pereira dos Santos
@since 14/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202MrkNX1(oView)
Local oModelNX1  := oView:GetModel():GetModel( "NX1DETAIL" )
Local nQtd       := oModelNX1:GetQtdLine()
Local nSavLine   := oModelNX1:GetLine()
Local nI         := 0
Local lCanUpdate := .F.

If !oModelNX1:IsEmpty()

	If !oModelNX1:CanUpdateLine()
		oModelNX1:SetNoUpdateLine(.F.)
		lCanUpdate := oModelNX1:CanUpdateLine()
	Else
		lCanUpdate := .T.
	EndIf

	If lCanUpdate

		For nI := 1 To nQtd
			oModelNX1:GoLine(nI)
			J202LoadVl(oModelNX1, "NX1_TKRET", .T.)
			J202MarcALL(oView, 'NX2DETAIL', "NX2_TKRET")
			J202MarcALL(oView, 'NUEDETAIL', "NUE_TKRET")
			J202MarcALL(oView, 'NVYDETAIL', "NVY_TKRET")
			J202MarcALL(oView, 'NV4DETAIL', "NV4_TKRET")
		Next

		oModelNX1:GoLine(nSavLine)

		oView:Refresh("NX1DETAIL")
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J202MarcarNX8
Rotina para marcar todos os contratos, casos e lançamentos vinculados
na pré-fatura.

@author Luciano Pereira dos Santos
@since 14/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202MrkNX8(oView)
Local oModelNX8  := oView:GetModel():GetModel( "NX8DETAIL" )
Local nQtd       := oModelNX8:GetQtdLine()
Local nSavLine   := oModelNX8:GetLine()
Local nI         := 0
Local lCanUpdate := .F.

If !oModelNX8:IsEmpty()

	If !oModelNX8:CanUpdateLine()
		oModelNX8:SetNoUpdateLine(.F.)
		lCanUpdate := oModelNX8:CanUpdateLine()
	Else
		lCanUpdate := .T.
	EndIf

	If lCanUpdate
		For nI := 1 To nQtd
			oModelNX8:GoLine(nI)
			J202LoadVl(oModelNX8, "NX8_TKRET", .T.)
			J202MrkNX1(oView)
			J202MarcALL(oView, 'NT1DETAIL', "NT1_TKRET")
		Next
		oModelNX8:GoLine(nSavLine)
		oView:Refresh("NX8DETAIL")
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J202MarcALL
Rotina para marcar todos os lançamentos de um grid

@author Luciano Pereira dos Santos
@since 14/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function J202MarcALL(oView, cDetail, cCpoMrk)
Local oModel     := oView:GetModel():GetModel( cDetail )
Local nQtd       := oModel:GetQtdLine()
Local nSavLine   := oModel:GetLine()
Local nI         := 0
Local lCanUpdate := .F.

If !oModel:IsEmpty()

	If !oModel:CanUpdateLine()
		oModel:SetNoUpdateLine(.F.)
		lCanUpdate := oModel:CanUpdateLine()
	Else
		lCanUpdate := .T.
	EndIf

	If lCanUpdate

		For nI := 1 To nQtd
			oModel:GoLine(nI)
			J202LoadVl(oModel, cCpoMrk, !(oModel:GetValue(cCpoMrk)))
		Next nI

		oModel:GoLine(nSavLine)
		oView:Refresh(cDetail)

	EndIf

EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202MPre
Rotina para marcar todos os lançamentos de uma pré-fatura

@author Luciano Pereira dos Santos
@since 14/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA202MPre(oView, cAlias, cTipo)
Local nLinNX8     := 0
Local nLinNX1     := 0
Local oModel      := FwModelActive()
Local oModelNX8   := oModel:GetModel("NX8DETAIL")
Local oModelNX1   := oModel:GetModel("NX1DETAIL")
Local aSaveLines  := FwSaveRows(  )
Local cDetail     := ''
Local cCpoMrk     := ''

	If cAlias == "NUE"
		cDetail := 'NUEDETAIL'
		cCpoMrk := "NUE_TKRET"
	ElseIf cAlias == "NVY"
		cDetail := 'NVYDETAIL'
		cCpoMrk := "NVY_TKRET"
	ElseIf cAlias == "NV4"
		cDetail := 'NV4DETAIL'
		cCpoMrk := "NV4_TKRET"
	Else
		Return .F.
	EndIf

	If cTipo == "PRE"

		For nLinNX8 := 1 To oModelNX8:GetQtdLine()
			oModelNX8:GoLine(nLinNX8)
			For nLinNX1 := 1 To oModelNX1:GetQtdLine()
				oModelNX1:GoLine(nLinNX1)
				J202MarcALL(oView, cDetail, cCpoMrk)
			Next nLinNX1

		Next nLinNX8

	ElseIf cTipo == "CONT"
		For nLinNX1 := 1 To oModelNX1:GetQtdLine()
			oModelNX1:GoLine(nLinNX1)
			J202MarcALL(oView, cDetail, cCpoMrk)
		Next nLinNX1
	EndIf

	FwRestRows( aSaveLines )
	oView:Refresh()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J202RefPre()
Rotina para refazer a pré-fatura em Lote

@author  TOTVS
@revisor Luciano Pereira dos Santos
@since 28/03/2012
@version 1.1
/*/
//-------------------------------------------------------------------
Function J202RefPre(lAutomato, cAutoCbRes, cAutoMarca)
Local lRet       := .F.
Local aArea      := GetArea()
Local aAreaNX0   := NX0->(GetArea())
Local cMarca     := ""
Local lInvert    := .F.
Local cFiltNX0   := NX0->( dbFilter() )
Local cFiltTelaA := ""
Local cFiltAUX   := ""
Local cCod       := ""
Local oLayer     := FWLayer():new()
Local oMainColl  := Nil
Local cRotina    := ProcName(0)
Local cCbxResult := STR0129
Local aCbxResult := { STR0101, STR0102, STR0126, STR0129} //"Impressora","Tela","Nenhum"
Local oFilaExe   := JurFilaExe():New( "JURA202", "2", cValToChar(ThreadID())) //2=Impressão
Local lPDUserAc  := Iif(FindFunction("JPDUserAc"), JPDUserAc(), .T.) // Indica se o usuário possui acesso a dados sensíveis ou pessoais (LGPD)
Local lProcessa   := .T.
Local cMsgErro   := ""

Default lAutomato  := .F.
Default cAutoMarca := ""

If (!lAutomato)
	cMarca     := oMarkUp:Mark()
	lInvert    := oMarkUp:IsInvert()
	cFiltTelaA := oMarkUp:FWFilter():GetExprADVPL()
Else
	cFiltAUX   := "(NX0_OK == '" + cAutoMarca + "')"
	NX0->( dbClearFilter() )
	NX0->( dbSetFilter( IIf( !Empty( cFiltAUX ), &( ' { || ' + AllTrim( cFiltAUX ) + ' } ' ), '' ), cFiltAUX ) )
EndIf

If !Empty(cFiltTelaA) .And. !lAutomato
	cFiltAUX := "(" + cFiltTelaA + ") .And. (NX0_OK " + Iif(lInvert, "<>", "==" ) + " '" + cMarca + "')"
	NX0->( dbClearFilter() )
	NX0->( dbSetFilter( IIf( !Empty( cFiltAUX ), &( ' { || ' + AllTrim( cFiltAUX ) + ' } ' ), '' ), cFiltAUX ) )
EndIf

NX0->( dbSetOrder(1) )
NX0->(dbGoTop())
If NX0->(EOF())
	lRet := JurMsgErro(STR0144) // "É preciso marcar pré-faturas em situação válida para a operação de refazer!"
Else

	If (!lAutomato)
		DEFINE MSDIALOG oDlg TITLE STR0068 FROM 0, 0 TO 150, 300 PIXEL //"Refazer a pré-fatura: "

		oLayer:init(oDlg, .F.) // Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
		oLayer:addCollumn("MainColl", 100, .F.) // Cria as colunas do Layer
		oMainColl := oLayer:GetColPanel('MainColl' )

		cListItens := AtoC(aCbxResult, ';')
		oCbxResult := TJurPnlCampo():New(10, 10, 60, 25, oMainColl, STR0069, '', {|| }, {|| }, cCbxResult,,,,, cListItens) //"Resultado"
		oCbxResult:SetChange({|| (cCbxResult := oCbxResult:Valor)})
		oCbxResult:SetWhen({|| lPDUserAc })

		oDlg:lEscClose := .F.

		Activate MsDialog oDlg Centered On Init EnchoiceBar(oDlg, {|| Iif(!Empty(cCbxResult), (lRet := .T., oDlg:End()), JurMsgErro(STR0287, cRotina, STR0070)) }, {|| (lRet := .F., oDlg:End())},; //#"O tipo de resultado não foi preenchido." ##"É preciso informar o tipo de resultado para a pré-fartura."
		                                                           , /*aButtons*/, /*nRecno*/, /*cAlias*/, .F., .F., .F., .T., .F. )
	Else
		lRet := .T.
	EndIf

	cCbxResult := Iif(!lAutomato, AllTrim( Str( aScan( aCbxResult, cCbxResult ) ) ), cAutoCbRes )

	oFilaExe:StartReport(lAutomato) //Verifica e abre a Thread de relatório se não estiver aberta

	If lRet
		If FindFunction("JPDLogUser")
			JPDLogUser("J202RefPre") // Log LGPD Relatório de Refazer da Pré-Fatura
		EndIf

		While !NX0->(EOF())

			cCod := NX0->NX0_COD

			lProcessa := !(NX0->NX0_SITUAC == SIT_CONFERENCIA) .And. ( J202ImgPr(@cMsgErro, cCbxResult) .Or.;
				            NX0->NX0_SITUAC $ SIT_ANALISE + "|" + SIT_ALTERADA + "|" + SIT_EMIFATURA + "|" + SIT_EMIMINUTA + "|" +;
			                     SIT_MINEMITIDA + "|" + SIT_MINCANCEL + "|" + SIT_MINSOCIO + "|" +  SIT_MINSOCIOEMI + "|" +;
                                 SIT_MINSOCIOCAN + "|" + SIT_REVISADA + "|" + SIT_REVISRESTRI + "|" + SIT_EMREVISAO ) //Somente refaz as outras situações se for impressora ou tela
			If lProcessa
				Processa( {|| lRet := J202ADDREL(NX0->NX0_COD, cCbxResult, lAutomato)}, STR0147, STR0148 + " " + NX0->NX0_COD, .F.) //"Aguarde..." ### "Refazendo a Pré-Fatura "
			Else
				lRet := .T.
			EndIf

			If lRet .And. NX0->( dBSeek( xFilial("NX0") + cCod ) )
				RecLock("NX0", .F.)
				NX0->NX0_OK := Iif(lInvert, cMarca, Space(TamSX3("NX0_OK")[1])) // Limpa a marca
				NX0->(MsUnLock())
				NX0->(dbCommit())
			EndIf

			NX0->(dbSkip())
		EndDo
	EndIf

EndIf

NX0->( dbClearFilter() )
If !Empty(cFiltNX0)
	NX0->( dbSetFilter( &( ' { || ' + AllTrim( cFiltNX0 ) + ' } ' ), cFiltNX0 ) )
EndIf

RestArea(aAreaNX0)
RestArea(aArea)

NX0->(dBSeek(xFilial("NX0") + cCod) ) // Apenas tento posicionar no novo registro apÃ³s apagar e recriar a pré! Não preciso saber se encontrou!

If !Empty(cMsgErro)
	lRet := JurErrLog(STR0348 + cMsgErro) //"Não é possível refazer as seguintes Pré-Faturas: "
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GravLanc()
Grava no respectivo model os novo lançamentos.

@Return    @lret retono: .T. - Efetuou os lançamentos; .F. - não efetuou os lançamentos

@author Luciano Pereira dos Santos
@since 19/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GravLanc(oModel)
Local nY        := 0
Local nX        := 0
Local aCampos   := {}
Local lRet      := .T.
Local cTab      := ""
Local cCodigo   := ""
Local oModelNX0 := oModel:GetModel("NX0MASTER")
Local cFatAdc   := oModelNX0:GetValue("NX0_FATADC")
Local aArea     := GetArea()
Local cFilTab   := ""
Local nLancDiv  := 0
Local lTela     := !IsBlind()

If (nLancDiv := Len(aLancDiv)) > 0

	If lTela
		__oProcess:SetRegua1(nLancDiv)
		__oProcess:SetRegua2(0)
	EndIf

	For nY := 1 To nLancDiv

		If lTela
			__oProcess:IncRegua1(i18n(STR0333, {nY, nLancDiv} )) // "Gravando lançamentos divididos - #1 de #2."
			__oProcess:IncRegua2(STR0334) // "Preenchendo valores dos lançamentos."
		EndIf

		aCampos := aLancDiv[nY]

		cTab    := Substr((aCampos[1][1]), 1, 3)
		cFilTab := xFilial(cTab)

		If RecLock((cTab), .T.)
			For nX := 1 To Len( aCampos )
				If aCampos[nX][1] == cTab + "_COD"
					cCodigo := GetSxEnum(cTab, cTab + "_COD" )
					(cTab)->(FieldPut( FieldPos( cTab + "_COD" ), cCodigo))
				ElseIf !Empty(aCampos[nX][2])
					(cTab)->(FieldPut( FieldPos( aCampos[nX][1] ), aCampos[nX][2]))
				EndIf
			Next nX
			(cTab)->(MsUnlock())
			(cTab)->(DbCommit())

			If lTela
				__oProcess:IncRegua2(STR0335) // "Sincronizando."
			EndIf
			
			//Grava na fila de sincronização a alteração
			If lIntegracao
				J170GRAVA(cTab, cFilTab + cCodigo, "3")
			EndIf

			(cTab)->(DbSkip())
		Else
			lRet := .F.
			Exit
		EndIf

	Next nY

	aLancDiv := {}
	aDespDiv := {}

EndIf

// Grava fisicamente as alterações nos lançamentos desvinculados da pré-fatura
If lRet
	lRet := GravModel(oModel)
EndIf

// remove os vinculos dos lançamentos retirados da pre-fatura pelo exact amount
If lRet
	lRet := RmvLanc()
EndIf

//Atualiza os descontos na pré-fatura
If lRet .And. cFatAdc != "1"
	lRet := J202DSCPRE(oModel)
EndIf

//atualiza o array de informações dos casos
If lRet
	JA202CPYMD( oModel )
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RmvLanc()
Deleta os vinculos dos registros que foram removidos da pré-fatura.

@Param aRmvLanc  Array do tipo private do model com o alias da tabela
				 do lançamento e a chave para localizar o seu respectivo
				 registro na tabela vinculo.

@Return lRet  	 .F. se não deletou o registro, .T. se deletou ou se não
				 havia dados no array.

@author Luciano Pereira dos Santos
@since 19/10/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RmvLanc()
Local aArea    := GetArea()
Local lRet     := .T.
Local cTab     := ""
Local nI       := 0
Local nRmvLanc := Len(aRmvLanc)
Local lTela    := !IsBlind()

If nRmvLanc > 0

	Do Case
		Case aRmvLanc[1][1] == "NUE"
			cTab := "NW0"
		Case aRmvLanc[1][1] == "NVY"
			cTab := "NVZ"
		Otherwise
			lRet := .F.
	EndCase

	If lRet

		If lTela
			__oProcess:SetRegua1(nRmvLanc)
			__oProcess:SetRegua2(0)
		EndIf
		
		DbSelectArea(cTab)
		(cTab)->(dbSetOrder(1))
		
		For nI := 1 To nRmvLanc

			If lTela
				__oProcess:IncRegua1(i18n(STR0338, {nI, nRmvLanc} )) // "Removendo vínculos de lançamentos - #1 de #2."
				__oProcess:IncRegua2(STR0339) // "Cancelando vínculos."
			EndIf

			cChave := aRmvLanc[nI][2]
			If (cTab)->(DbSeek(cChave))
				If RecLock((cTab), .F.)
					(cTab)->(FieldPut(FieldPos( cTab + "_CANC" ), "1"))
					(cTab)->(MsUnlock())
					(cTab)->(DbCommit())
				Else
					lRet := .F.
				EndIf
			EndIf
		Next nI
		(cTab)->( DbCloseArea() )
	EndIf

	aRmvLanc := {}

EndIf

RestArea( aArea )

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GravModel(oModel)
Deleta os vinculos dos registros que foram removidos da pré-fatura.

@Param oModel    Model com os detail dos lançamentos
				 para localizar o seu respectivo registro na tabela
				 vinculo.

@Return lRet  	 .F. se não deletou o registro, .T. se deletou ou se não
				 havia dados no array.

@author Luciano Pereira dos Santos
@since 19/10/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GravModel(oModel)
Local lRet       := .F.
Local aSaveLines := FwSaveRows( )
Local oModelNX8  := oModel:GetModel( 'NX8DETAIL' )
Local oModelNX1  := oModel:GetModel( 'NX1DETAIL' )
Local oModelNUE  := oModel:GetModel( 'NUEDETAIL' )
Local oModelNVY  := oModel:GetModel( 'NVYDETAIL' )
Local oModelNV4  := oModel:GetModel( 'NV4DETAIL' )
Local nI         := 0
Local nY         := 0
Local nLnNX8_OLD
Local nLnNX1_OLD

nLnNX8_OLD := oModelNX8:GetLine()
nINX8      := oModelNX8:GetQtdLine()
For nI := 1 To nINX8
	oModelNX8:GoLine(nI)
	nLnNX1_OLD := oModelNX1:GetLine()
	nINX1      := oModelNX1:GetQtdLine()
	For nY := 1 To nINX1
		oModelNX1:GoLine(nY)
		lRet := GravaGenerico(oModelNVY)
		If lRet
			lRet := GravaGenerico(oModelNUE)
		EndIf
		If lRet
			lRet := GravaGenerico(oModelNV4)
		EndIf
		If !lRet
			Exit
		EndIf
	Next nY
	oModelNX1:GoLine(nLnNX1_OLD)
Next nI
oModelNX8:GoLine(nLnNX8_OLD)

FwRestRows(aSaveLines)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202VldDiv()
Verifica se array aLancDiv ja foi usado para alterar a pré-fatura atraves
do codigo do lançamento do lançamento pai, em positivo a funçao .F.

@Param cCampo  Campos a ser verificado no Array
@Param cCodPai Código do lançamento pai a ser verificado

@Return lRet  .F. se nao encontrou lançamento igual, .T. se encontrou.

@author Luciano Pereira dos Santos
@since 19/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J202VldDiv(cCampo, uValor)
Local lRet    := .F.
Local nI      := 0

If Len(aLancDiv) > 0 .And. Empty(cInstanc) // as rotinas alteração de periodo podem fazer acerto de saldo em um lançamento dividido

	If (nPos := aScan( aLancDiv[1], { |x| x[1] == cCampo } )) > 0

		For nI := 1 To Len(aLancDiv)
			lRet := aLancDiv[nI][nPos][2] == uValor
			If lRet
				Exit
			EndIf
		Next nI
	EndIf

EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PosFilho()
Retorna a posição do lançamento dividido no array

@Return nCountWO

@author David Fernandes
@since 20/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static function PosFilho(cCpoCli, cClient, cCpoLoj, cLoja, cCpoCas, cCaso, cCpoCoPai, cCodPai, cCpoValor)
Local aPosFilho  := .F.
Local nY         := 0
Local nX         := 0
Local aCampos    := {}
Local lClient    := .F.
Local lLoja      := .F.
Local lCaso      := .F.
Local lPai       := .F.
Local lValor     := .F.
Local nPosValor  := 0

If Len(aLancDiv) > 0
	For nY := 1 To Len(aLancDiv)
		aCampos := aLancDiv[nY]
		lClient := .F.
		lLoja   := .F.
		lCaso   := .F.
		lPai    := .F.
		lValor  := .F.
		For nX := 1 To Len( aCampos )
			Do Case
			Case (cCpoCli == aCampos[nX][1]) .And. (cClient == aCampos[nX][2])
				lClient := .T.
			Case (cCpoLoj == aCampos[nX][1]) .And. (cLoja == aCampos[nX][2])
				lLoja := .T.
			Case (cCpoCas == aCampos[nX][1]) .And. (cCaso == aCampos[nX][2])
				lCaso := .T.
			Case (cCpoCoPai == aCampos[nX][1]) .And. (cCodPai == aCampos[nX][2])
				lPai := .T.
			Case (cCpoValor == aCampos[nX][1])
				lValor := .T.
				nPosValor := nX
			EndCase
			If lClient .And. lLoja .And. lCaso .And. lPai .And. lValor
				aPosFilho := {nY, nPosValor}
				Exit
			EndIf

		Next nX
		If !Empty(aPosFilho)
			Exit
		EndIf

	Next nY
EndIf

Return aPosFilho

//-------------------------------------------------------------------
/*/{Protheus.doc} J202WOFixo
Envia as parcelas de Fixo para WO

@Return nCountWO

@author Daniel Magalhaes
@since 20/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J202WOFixo(aObs, aPos)
Local aArea      := GetArea()
Local aAreaNT1   := NT1->(GetArea())
Local nPos       := 0
Local nI         := 0
Local nY         := 0
Local oMaster    := FwModelActive()
Local oMasterNX1 := oMaster:GetModel( 'NX1DETAIL' )
Local oMasterNX8 := oMaster:GetModel( 'NX8DETAIL' )
Local oMasterNT1 := oMaster:GetModel( 'NT1DETAIL' )
Local nCountWO   := 0
Local nLessPos   := oMasterNT1:GetLine()

For nI := 1 To Len( aPos )

	//Posicao no model NX8 - Contratos
	If aPos[nI][1] > 0
		oMasterNX8:GoLine( aPos[nI][1] )
	EndIf

	//Posicao no model NX1 - Casos
	If aPos[nI][2] > 0
		oMasterNX1:GoLine( aPos[nI][2] )
	EndIf

	For nY := 1 To Len( aPos[nI][3] )

		nPos := aPos[nI][3][nY]

		oMasterNT1:GoLine( nPos )

		nCountWO += J96WOFixo(oMaster, aObs, .T.)

		If nLessPos > nPos
			nLessPos := nPos
		EndIf

	Next nY

Next nI

If nLessPos > 1
	nLessPos := nLessPos - 1
EndIf

oMasterNT1:GoLine( nLessPos )

NT1->( RestArea( aAreaNT1 ) )
RestArea( aArea )

Return nCountWO

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202FwCan
Avalia as condicoes de cancelamento do formulario

@Return .T.

@author Daniel Magalhaes
@since 20/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202FwCan(oObj)

lCancPre    := .F.
aLancDiv    := {}
aDespDiv    := {}
aAltPend    := {}

FWFormCancel(oObj)

__aGridPos  := {}
__cLastPFat := ""

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA202W
Condicoes do Modo de edicao dos campos (X3_WHEN) da tabela NX0

@Return lRet

@author Daniel Magalhaes
@since 26/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA202W(cCampo)
Local lRet      := .T.
Local cTpHon    := ""
Local cCobH     := ""
Local oModel    := FwModelActive()
Local oModelNX0 := oModel:GetModel("NX0MASTER")
Local oModelNX1 := oModel:GetModel("NX1DETAIL")
Local oModelNX8 := oModel:GetModel("NX8DETAIL")

Do Case
	Case cCampo == "NX0_TPDESC"
		lRet := ( oModelNX0:GetValue("NX0_VLFATH") - oModelNX0:GetValue("NX0_VLFATT") ) > 0

		lRet := lRet .And. oModelNX0:GetValue("NX0_DESCH") == 0 .And. oModelNX0:GetValue("NX0_PDESCH") == 0

	Case cCampo == "NX0_TPACRE"
		If ( oModelNX0:GetValue("NX0_VLFATH")  == 0 ) .And. ( oModelNX0:GetValue("NX0_VLFATD")  > 0 )
			lRet := .F.
		Else
			lRet := oModelNX0:GetValue("NX0_ACRESH") == 0 .And. oModelNX0:GetValue("NX0_PACREH") == 0
		EndIf

	Case cCampo == "NX0_DESCH" .Or. cCampo == "NX0_PDESCH"

		lRet := ( oModelNX0:GetValue("NX0_VLFATH") - oModelNX0:GetValue("NX0_VLFATT") ) > 0

		If lRet
			If cCampo == "NX0_DESCH"
				lRet := oModelNX0:GetValue("NX0_TPDESC") == '1'
			Else
				lRet := oModelNX0:GetValue("NX0_TPDESC") == '2'
			EndIf
		EndIf

	Case cCampo == "NX0_ACRESH" .Or. cCampo == "NX0_PACREH"

		lRet := ( oModelNX0:GetValue("NX0_VLFATH") > 0 ) .Or.;
			(( oModelNX0:GetValue("NX0_VLFATH") == 0 ) .And. ( oModelNX0:GetValue("NX0_VLFATD") > 0 ) .And. cCampo == "NX0_ACRESH" )

		If lRet
			If cCampo == "NX0_ACRESH"
				lRet := oModelNX0:GetValue("NX0_TPACRE") == '1'
			Else
				lRet := oModelNX0:GetValue("NX0_TPACRE") == '2'
			EndIf
		EndIf

	Case cCampo == "NX0_ALTPER"
		lRet := !(oModel:IsFieldUpdated('NX0MASTER', 'NX0_VTS') .Or. oModel:IsFieldUpdated('NX0MASTER', 'NX0_VLFATD'))

	Case cCampo == "NX1_VLDESC" .Or. cCampo == "NX1_PCDESC"

		lRet := oModelNX1:GetValue("NX1_VTS") > 0

		If lRet
			If cCampo == "NX1_VLDESC"
				lRet := oModelNX0:GetValue("NX0_TPDESC") == '1'
			Else
				lRet := oModelNX0:GetValue("NX0_TPDESC") == '2'
			EndIf
		EndIf

	Case cCampo == "FIXO"
		//NRA_COBRAF, NRA_COBRAH, NRA_NCOBRA
		cTpHon := JurGetDados("NT0", 1, xFilial("NT0") + oModelNX8:GetValue("NX8_CCONTR"), "NT0_CTPHON")
		cCobH  := JurGetDados("NRA", 1, xFilial("NRA") + cTpHon, "NRA_COBRAH")
		lRet   := (cCobH == "1")

	Case cCampo == "NX0_VTS"
		lRet   := !Empty(oModelNX0:GetValue("NX0_ALTPER"))

	OtherWise
		lRet   := .T.
EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202DSCACR
Valida os campos de Desconto/Acrescimo no valor de honorarios
(NX0_DESCH, NX0_ACRESH, NX0_PACREH)
e atualiza o campo de Valor de Honorarios com Desconto/Acrescimo
(NX0_VFATH2)

@Return lRet
.T. - valido
.F. - invalido
Conforme regra de que o valor de desconto nao pode ser maior que
o valor de honorarios e o percentual de desconto nao pode ser
superior a 100%

@author Daniel Magalhaes
@since 26/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J202DscAcr( cCampo )
Local nVlCampo  := FwFldGet( cCampo )
Local lRet      := .T.
Local oModel    := FWModelActive()
Local oModelNX0 := oModel:GetModel("NX0MASTER")
Local nVlHonor  := oModelNX0:GetValue("NX0_VLFATH") //Valor dos honorarios
Local nDescLin  := oModelNX0:GetValue("NX0_DESCON") //Desc Linear
Local nValorTb  := oModelNX0:GetValue("NX0_VLFATT") //Valor de Tabelados 
Local nPercent  := 0
Local nVlrAcrs  := 0
Local nTam      := 0

Do Case
	Case cCampo == "NX0_DESCH"

		lRet := lRet .And. nVlCampo <= (nVlHonor - nValorTb - nDescLin)
		If lRet
			J202LoadVl(oModelNX0, "NX0_PDESCH", Round( oModelNX0:GetValue( "NX0_DESCH" ) / (nVlHonor - nValorTb - nDescLin) * 100.00  , TamSX3("NX0_PDESCH")[2]))
			J202LoadVl(oModelNX0, "NX0_VDESCT", Round( oModelNX0:GetValue( "NX0_DESCH" ) + oModelNX0:GetValue("NX0_DESCON"), TamSX3("NX0_VDESCT")[2]))
		Else
			JurMsgErro(STR0206, ,STR0345) // "O valor total de descontos não pode ser maior que o valor de honorários." / Solução: O total de descontos na pré-fatura não poderá ser maior que a soma do valor de timesheet e fixo.
		EndIf

		IIF(lRet, lTelaRat := .T.,)

	Case cCampo == "NX0_PDESCH"

		lRet := lRet .And. nVlCampo <= 100.00 .And. nVlCampo >= 0 .And. (nVlHonor - nValorTb - nDescLin - ((nVlHonor - nValorTb - nDescLin) * nVlCampo / 100) >= 0)

		If lRet
			J202LoadVl(oModelNX0, "NX0_DESCH" , Round( oModelNX0:GetValue( "NX0_PDESCH" ) * (nVlHonor - nValorTb - nDescLin) / 100.00, TamSX3("NX0_DESCH")[2] ) )
			J202LoadVl(oModelNX0, "NX0_VDESCT", Round( oModelNX0:GetValue( "NX0_DESCH" ) + oModelNX0:GetValue("NX0_DESCON"), TamSX3("NX0_VDESCT")[2] ) )
		Else
			JurMsgErro(STR0206, ,STR0345) // "O valor total de descontos não pode ser maior que o valor de honorários." / Solução: O total de descontos na pré-fatura não poderá ser maior que a soma do valor de timesheet e fixo.
		EndIf

		IIF(lRet, lTelaRat := .T.,)

	Case cCampo == "NX0_ACRESH"
		nPercent := oModelNX0:GetValue( "NX0_ACRESH" ) / (nVlHonor) * 100.00

		nTam := TamSX3('NX0_PACREH')[1] - (TamSX3('NX0_PACREH')[2] + 1)

		If nPercent > Val(Replicate('9', nTam))
			lRet := JurMsgErro(STR0213) // "O Valor Percentual de acréscimo é maior que o valor máximo suportado pelo campo!"
		Else
			J202LoadVl(oModelNX0, "NX0_PACREH", nPercent)
		EndIf

	Case cCampo == "NX0_PACREH"
		lRet := lRet .And. nVlCampo >= 0 .And. ( (nVlHonor) > 0 )

		If lRet
			nTam := TamSX3('NX0_ACRESH')[1] - (TamSX3('NX0_ACRESH')[2] + 1)

			nVlrAcrs := Round( oModelNX0:GetValue( "NX0_PACREH" ) * (nVlHonor) / 100.00, TamSX3("NX0_ACRESH")[2] )

			If nVlrAcrs > Val(Replicate('9', nTam))
				lRet := JurMsgErro(STR0224) // "O Valor de acréscimo é maior que o valor máximo suportado pelo campo!"
			Else
				J202LoadVl(oModelNX0, "NX0_ACRESH", nVlrAcrs)
			EndIf
		EndIf

EndCase

IIF(lRet, lRet := oModelNX0:GetValue( cCampo ) >= 0, )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202VALCON
Validação do contato por cliente/loja pagador

@author Jacques Alves Xavier
@since 02/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J202VALCON()
Return JURCONTOK('SA1', FwFldGet("NXG_CCONT"), xFilial("SA1") + FwFldGet("NXG_CLIPG") + FwFldGet("NXG_LOJAPG"), "SU5->U5_ATIVO=='1'")

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202ReImp(cCodPre)
Refaz a pré fatura

@author David G. Fernandes
@since 20/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202ReImp(oParams, cCodPre)
Local aRet      := {.F., "JA202Reimp" }
Local cCRELAT   := ""
Local cCMOEDFT  := ""
Local cNT0COD   := ""
Local cNW2COD   := ""
Local cNVVCOD   := ""

//Verificar Escritório e Filial de emissão (se houver junção é da junção)
cCMOEDFT := JurGetDados("NX0", 1, xFilial("NX0") + cCodPre, "NX0_CMOEDA")
cNT0COD  := JurGetDados("NX8", 1, xFilial("NX8") + cCodPre, "NX8_CCONTR")
cNW2COD  := JurGetDados("NX0", 1, xFilial("NX0") + cCodPre, "NX0_CJCONT")
cNVVCOD  := JurGetDados("NX0", 1, xFilial("NX0") + cCodPre, "NX0_CFTADC")

oParams:SetPreFat(cCodPre)
oParams:SetContrato(cNT0COD)

//não precisa - pega dos pagadores
If !Empty(cNW2COD)
	cCRELAT := JurGetDados("NW2", 1, xFilial("NW2") + cNW2COD, "NW2_CRELAT")
Else
	cCRELAT := JurGetDados("NT0", 1, xFilial("NT0") + cNT0COD, "NT0_CRELAT")
EndIf

//Totaliza Caso
aRet := JA201DCaso(oParams, cCodPre, cCMOEDFT, cNVVCOD, cNW2COD, cNT0COD)

//Totaliza Contrato
If aRet[1]
	aRet := JA201ECont(oParams, cCodPre, cCMOEDFT, cNVVCOD, cNW2COD, cNT0COD)
EndIf

//Totaliza Pré
If aRet[1]
	aRet := JA201HPreF(oParams, cCodPre, cCMOEDFT, cNVVCOD, cNW2COD, cNT0COD, cCRELAT)
EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202VDESC()
Manipula as alterações do desconto

@author David G. Fernandes
@since 17/10/2011
@version 1.0
/*/
//-------------------------------------------------------------------
/*
aCasos: {[01] "NX1_CCLIEN", [02] "NX1_CLOJA" , [03] "NX1_CCASO",;
				 [04] "NX1_VDESP" , [05] "NX1_VTAB"  , [06] "NX1_VTS",;
				 [07] "NX1_PDESCH", [08] "NX1_VDESCO" )
*/
Function JA202VDESC(cCampo)
Local lRet       := .T.
Local oModel     := If(oModelOld = Nil, FwModelActive(), oModelOld)
Local oModelNX0  := oModel:GetModel("NX0MASTER")
Local oModelNX8  := oModel:GetModel("NX8DETAIL")
Local oModelNX1  := oModel:GetModel("NX1DETAIL")
Local nPos       := 0
Local nNewDesc   := 0
Local nOldDesc   := 0
Local nVlDif     := 0
Local nValorHon  := 0
Local nValBaseD  := 0 // Base valor para desconto especial (VTS + VFIXO - Desc Linear)

nPos := J202ACSPOS(oModelNX1:GetValue("NX1_CCLIEN"), oModelNX1:GetValue("NX1_CLOJA"),;
                   oModelNX1:GetValue("NX1_CCASO"), oModelNX1:GetValue("NX1_CCONTR") )

nValBaseD   := oModelNX1:GetValue( "NX1_VTS" ) + oModelNX1:GetValue( "NX1_VFIXO" ) - oModelNX1:GetValue( "NX1_VDESCO" )

If cCampo == "NX1_PDESCH"  // Se ajustado o percentual, altera o valor de desconto linear:

	nNewDesc := oModelNX1:GetValue( "NX1_PDESCH" )
	nOldDesc := aCasos[ nPos ] [ 07 ]

	If nNewDesc < 0
		lRet := JurMsgErro(STR0169) // "Informe um valor positivo!"
	EndIf

	If nNewDesc > 100.00
		lRet := JurMsgErro(STR0188) // "O Desconto não pode ser maior que 100%!"
	EndIf

	If lRet .And. (nNewDesc <> nOldDesc )

		If nNewDesc == 0 .And. nOldDesc > 0
			nVlDif := ( oModelNX1:GetValue("NX1_VTS") * (nOldDesc * (-1)) / 100.00 )
		Else
			nVlDif := ( oModelNX1:GetValue("NX1_VTS") * (nNewDesc-nOldDesc) / 100.00 )
		EndIf		

		If lRet .And. (oModelNX1:GetValue("NX1_VDESCT") + nVlDif) > oModelNX1:GetValue("NX1_VTS") + oModelNX1:GetValue("NX1_VFIXO")
			J202LoadVl(oModelNX1, "NX1_PDESCH", nOldDesc)
			lRet := JurMsgErro(STR0189) // "O Desconto não pode ser maior que a soma de Time Sheet e Fixo do caso!"
		EndIf

		IIF(lRet, lRet := J202LoadVl(oModelNX1, "NX1_VDESCO", Round(oModelNX1:GetValue("NX1_VDESCO") + nVlDif, TamSX3("NX1_VDESCO")[2]) ), )
		IIF(lRet, lRet := J202LoadVl(oModelNX1, "NX1_PDESCH", nNewDesc), )

		IIF(lRet, lRet := J202LoadVl(oModelNX8, "NX8_VDESCO", Round(oModelNX8:GetValue("NX8_VDESCO") + nVlDif, TamSX3("NX8_VDESCO")[2]) ), )
		IIF(lRet, lRet := J202LoadVl(oModelNX8, "NX8_VDESCT", oModelNX8:GetValue("NX8_VDESCO") + oModelNX8:GetValue("NX8_VLDESC") ), )

		IIF(lRet, lRet := J202LoadVl(oModelNX0, "NX0_DESCON", Round(oModelNX0:GetValue("NX0_DESCON") + nVlDif, TamSX3("NX0_DESCON")[2]) ), )

		nValBaseD := oModelNX1:GetValue("NX1_VTS") + oModelNX1:GetValue("NX1_VFIXO") - oModelNX1:GetValue("NX1_VDESCO")
		nValorHon := oModelNX0:GetValue("NX0_VTS") + oModelNX0:GetValue("NX0_VLFATF") - oModelNX0:GetValue("NX0_DESCON")

		If lRet .And. oModelNX0:GetValue( "NX0_TPDESC") == "1"
			IIF(lRet, lRet := J202LoadVl(oModelNX1, "NX1_PCDESC", oModelNX1:GetValue("NX1_VLDESC") / nValBaseD * 100), )
			IIF(lRet, lRet := J202LoadVl(oModelNX0, "NX0_PDESCH", oModelNX0:GetValue("NX0_DESCH") / nValorHon * 100), )
		Else
			IIF(lRet, lRet := J202LoadVl(oModelNX1, "NX1_VLDESC", oModelNX1:GetValue("NX1_PCDESC") * nValBaseD / 100), )
			IIF(lRet, lRet := J202LoadVl(oModelNX0, "NX0_DESCH" , oModelNX0:GetValue("NX0_PDESCH" ) * nValorHon / 100.00), )
		EndIf

		IIF(lRet, lRet := J202LoadVl(oModelNX1, "NX1_VDESCT", oModelNX1:GetValue("NX1_VDESCO") + oModelNX1:GetValue("NX1_VLDESC") ), )
		IIF(lRet, lRet := J202LoadVl(oModelNX0, "NX0_VDESCT", oModelNX0:GetValue( "NX0_DESCH" ) + oModelNX0:GetValue("NX0_DESCON") ), )

		aCasos[nPos][07] := oModelNX1:GetValue( "NX1_PDESCH" ) //guarda o novo valor do perc de desconto linear
	EndIf
EndIf

If cCampo == "NX1_VLDESC"  // Valor do desconto Especial

	nNewDesc   := oModelNX1:GetValue( "NX1_VLDESC" )
	If nNewDesc < 0
		lRet := JurMsgErro(STR0169) // "Informe um valor positivo!"
	EndIf

	If nNewDesc > nValBaseD
		lRet := JurMsgErro(STR0189) // "O Desconto não pode ser maior que a soma de Time Sheet e Fixo do caso!"
	EndIf

	nOldDesc   := aCasos[ nPos ] [ 08 ]

	If lRet .And. (nNewDesc <> nOldDesc)
		nVlDif := nNewDesc - nOldDesc

		IIF(lRet, lRet := J202LoadVl(oModelNX1, "NX1_VLDESC", Round(nOldDesc + nVlDif, TamSX3("NX1_VLDESC")[2])), )
		If lRet .And. oModelNX0:GetValue( "NX0_TPDESC") == "1"
			IIF(lRet, lRet := J202LoadVl(oModelNX1, "NX1_PCDESC", oModelNX1:GetValue("NX1_VLDESC") / nValBaseD * 100 ), )
		EndIf
		IIF(lRet, lRet := J202LoadVl(oModelNX1, "NX1_VDESCT", Round(nOldDesc + nVlDif + oModelNX1:GetValue("NX1_VDESCO"), TamSX3("NX1_VDESCT")[2]) ), )

		IIF(lRet, lRet := J202LoadVl(oModelNX8, "NX8_VLDESC", Round(oModelNX8:GetValue( "NX8_VLDESC") + nVlDif, TamSX3("NX8_VLDESC")[2]) ), )
		IIF(lRet, lRet := J202LoadVl(oModelNX8, "NX8_VDESCT", oModelNX8:GetValue("NX8_VDESCO") + oModelNX8:GetValue("NX8_VLDESC") ), )

		IIF(lRet, lRet := J202LoadVl(oModelNX0, "NX0_DESCH", Round(oModelNX0:GetValue( "NX0_DESCH" ) + nVlDif, TamSX3("NX0_DESCH")[2])), )

		nValorHon := oModelNX0:GetValue("NX0_VTS") + oModelNX0:GetValue("NX0_VLFATF") - oModelNX0:GetValue("NX0_DESCON")
		IIF(lRet, lRet := J202LoadVl(oModelNX0, "NX0_PDESCH", oModelNX0:GetValue("NX0_DESCH") / nValorHon * 100 ), )
		IIF(lRet, lRet := J202LoadVl(oModelNX0, "NX0_VDESCT", oModelNX0:GetValue( "NX0_DESCH" ) + oModelNX0:GetValue("NX0_DESCON") ), )

		aCasos[nPos][08] := oModelNX1:GetValue( "NX1_VLDESC" )
	EndIf
EndIf

If cCampo == "NX1_PCDESC"  //Perecentual do desconto especial
	lRet := oModelNX1:GetValue("NX1_PCDESC") <= 100.00 .And. oModelNX1:GetValue("NX1_PCDESC") >= 0
	If !lRet
		JurMsgErro(STR0205) // "Valor de percentual inválido. Verifique!"
	EndIf

	lRet := oModelNX1:GetValue("NX1_PCDESC") * nValBaseD / 100 <= nValBaseD
	If !lRet
		JurMsgErro(STR0189) // "O Desconto não pode ser maior que a soma de Time Sheet e Fixo do caso!"
	EndIf

	If lRet
		J202LoadVl(oModelNX1, "NX1_VLDESC", oModelNX1:GetValue("NX1_PCDESC") * nValBaseD / 100)
		JA202VDESC("NX1_VLDESC")
	EndIf
EndIf

Return ( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} J202ACSPOS()
Retorna a posição da variavel aCasos

@author Luciano Pereira dos Santos
@since 21/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202ACSPOS(cClient, cLoja, cCaso, cContr)
Local nPos := 0

nPos := aScan( aCasos, { |x| x[ 1] == cClient .And. ;
               x[ 2] == cLoja .And. x[ 3] == cCaso .And. x[ 9] == cContr } )

Return nPos

//-------------------------------------------------------------------
/*/{Protheus.doc} J202CasPre(cCodPre, cCliente, cLoja, cCaso, cContr, cTipo, nREcno, lTemLanc)
Verifica se o novo Caso ao qual o lançamento foi transferido está na
pré-fatura para manter o lançamento na pré-fatura

@param cCodPre   Codigo da pré-fatura
@Param cCliente  Codigo do cliente do caso
@Param cLoja     Codigo da loja do cliente do caso
@Param cCaso     Codigo do Caso
@Param cContr    Codigo do Contrato
@param cTipo     Tipo do lançamento 'TS' - Time Sheet; 'DP' - Despesas; 'LT' - Lançamento Tabelado
@param nREcno    nRecno do Caso (se estiver na pré)
@param lTemLanc  Verifica se o caso da pré ja possue lancamentos do tipo transferido.

@author Jacques Alves Xavier
@since 29/10/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202CasPre(cCodPre, cCliente, cLoja, cCaso, cTipo, nRecno, lTemLanc)
Local lRet       := .F.
Local aArea      := GetArea()
Local cQuery     := ''
Local aPrefat    := {}
Local cCasoFlag  := ''
Local cCampoCob  := ''

Default nRecno   := 0
Default lTemLanc := .T.

Do Case
Case cTipo == 'TS'
	cCasoFlag := 'NX1_TS'
	cCampoCob := '' // Time sheet pode vincular em um contrato que não cobra TS - MV_JVINCTS
Case cTipo == 'DP'
	cCasoFlag := 'NX1_DESP'
	cCampoCob := 'NT0_DESPES'
Case cTipo == 'LT'
	cCasoFlag := 'NX1_LANTAB'
	cCampoCob := 'NT0_SERTAB'
EndCase

cQuery := " SELECT NX1.R_E_C_N_O_ RECNO " + ", NX1." + cCasoFlag + " "
cQuery +=     " FROM "+ RetSqlName("NX1") + " NX1 "
If !Empty(cCampoCob)
	cQuery +=     " INNER JOIN " + RetSqlName("NT0") + " NT0 "
	cQuery +=       " ON NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
	cQuery +=       " AND NT0.NT0_COD = NX1.NX1_CCONTR "
	cQuery +=       " AND NT0." + cCampoCob + " = '1' "
	cQuery +=       " AND NT0.D_E_L_E_T_ = ' ' "
EndIf
cQuery +=     " WHERE NX1.NX1_FILIAL = '" + xFilial("NX1") + "' "
cQuery +=       " AND NX1.NX1_CPREFT = '" + cCodPre + "'"
cQuery +=       " AND NX1.NX1_CCLIEN = '" + cCliente + "' "
cQuery +=       " AND NX1.NX1_CLOJA = '" + cLoja + "' "
cQuery +=       " AND NX1.NX1_CCASO = '" + cCaso + "' "
cQuery +=       " AND NX1.D_E_L_E_T_= ' ' "

aPrefat := JurSQL(cQuery, {"RECNO", cCasoFlag})

If (lRet := !Empty(aPrefat))
	nRecno   := aPrefat[1][1]
	lTemLanc := aPrefat[1][2] == '1'
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202VLPAG()
Função para validar a alteração do pagador.

@author Luciano Pereira dos Santos
@since 09/12/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202VLPAG()
Local lRet  := .T.

If !Empty(FwFldGet("NXG_CFATUR")) .Or. !Empty(FwFldGet("NXG_CESCR"))
	lRet := JurMsgErro(STR0180) //"Não é possível alterar um pagador com fatura emitida!"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202DESC(oModel)
Função para replicar a alteração de TimeSheets e lançamento tabelado
para o caso no model.

@author Luciano Pereira dos Santos
@since 15/12/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202DESC(oModel)
Local lRet           := .T.
Local oModelNX0      := oModel:GetModel("NX0MASTER")
Local oModelNX1      := oModel:GetModel("NX1DETAIL")
Local oModelNUE      := oModel:GetModel("NUEDETAIL")
Local oModelNV4      := oModel:GetModel("NV4DETAIL")
Local cMoePref       := oModelNX0:GetValue("NX0_CMOEDA" )
Local dDtPref        := oModelNX0:GetValue("NX0_DTEMI" )
Local nPdescH        := oModelNX1:GetValue( "NX1_PDESCH" )
Local nI             := 0
Local nQtdeNUE       := oModelNUE:GetQtdLine()
Local nQtdeNV4       := oModelNV4:GetQtdLine()
Local nSomaTS        := 0
Local nSomaLT        := 0
Local nVLLTTmp       := 0
Local aTabVinc       := {}
Local nPos           := 0
Local nVTSTab        := 0
Local nDescLin       := 0
Local cNUEclTab      := ""
Local cNX0COD        := oModelNX0:GetValue( "NX0_COD" )
Local nNUESaveLine   := oModelNUE:GetLine()
Local nNV4SaveLine   := oModelNV4:GetLine()
Local cNV4_COD
Local cNV4CMOEH

For nI := 1 To nQtdeNUE
	cNUEclTab := Alltrim(oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CLTAB], nI))
	If Empty(cNUEclTab)
		nSomaTS := nSomaTS + oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALOR1], nI)
	Else  //guarda os valores do TS para verificar com o seu respectivo tabelado

		nPos := aScan( aTabVinc, { |ax| Alltrim(ax[1]) == cNUEclTab} )

		If nPos > 0
			aTabVinc[nPos][2] := aTabVinc[nPos][2] + oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALOR1], nI)
		Else
			aAdd(aTabVinc, {cNUEclTab, oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALOR1], nI)})
		EndIf

	EndIf

Next nI

For nI := 1 To nQtdeNV4
	oModelNV4:GoLine(nI)
	cNV4CMOEH := oModelNV4:GetValueByPos(__aNV4PosFields[POS_NV4_CMOEH])
	If cMoePref != cNV4CMOEH
		nVLLTTmp := JA201FConv(cMoePref, cNV4CMOEH, oModelNV4:GetValueByPos(__aNV4PosFields[POS_NV4_VLHFAT]), "2", dDtPref, , cNX0COD, )[1]
	Else
		nVLLTTmp := oModelNV4:GetValueByPos(__aNV4PosFields[POS_NV4_VLHFAT])
	EndIf

	If JurGetDados("NRD", 1, xFilial("NRD") + oModelNV4:GetValueByPos(__aNV4PosFields[POS_NV4_CTPSRV]), "NRD_COBMAI") == "1"
		cNV4_COD := AllTrim(oModelNV4:GetValueByPos(__aNV4PosFields[POS_NV4_COD]))
		nPos := aScan( aTabVinc, { | ax | Alltrim(ax[1]) == cNV4_COD } )

		If nPos > 0
			If aTabVinc[nPos][2] > nVLLTTmp
				nVLLTTmp := aTabVinc[nPos][2]
			EndIf
			nVTSTab  := nVTSTab + aTabVinc[nPos][2]
		EndIf

	EndIf

	nSomaLT := nSomaLT + nVLLTTmp

Next nI

nDescLin := nSomaTS * (nPDescH / 100.00)

IIF(lRet, lRet := oModelNX1:LdValueByPos( __aNX1PosFields[POS_NX1_VTS], nSomaTS ), )
IIF(lRet, lRet := oModelNX1:LdValueByPos( __aNX1PosFields[POS_NX1_VTAB], nSomaLT ), )
IIF(lRet, lRet := oModelNX1:LdValueByPos( __aNX1PosFields[POS_NX1_VTSTAB], nVTSTab ), )
IIF(lRet, lRet := oModelNX1:LdValueByPos( __aNX1PosFields[POS_NX1_VDESCO], nDescLin ), )

//Atualiza valor/percentual do Desconto Especial
If oModelNX0:GetValue("NX0_TPDESC") == "2" // se por percentual, faz a correção de valor do desconto
	IIF(lRet, lRet := J202LoadVl(oModelNX1, "NX1_VLDESC", Round(oModelNX1:GetValue("NX1_PCDESC") * oModelNX1:GetValue("NX1_VTS") / 100, TamSX3("NX1_VLDESC")[2]) ), )
Else
	IIF(lRet, lRet := J202LoadVl(oModelNX1, "NX1_PCDESC", Round(oModelNX1:GetValue("NX1_VLDESC") / oModelNX1:GetValue("NX1_VTS") * 100, TamSX3("NX1_PCDESC")[2]) ), )
EndIf

IIF(lRet, lRet := oModelNX1:LdValueByPos( __aNX1PosFields[POS_NX1_VDESCT], oModelNX1:GetValue("NX1_VDESCO") + oModelNX1:GetValue("NX1_VLDESC") ), )

oModelNUE:GoLine(nNUESaveLine)
oModelNV4:GoLine(nNV4SaveLine)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}  J202DSCPRE()
Função para Atualizar os descontos na Pre-Fatura

@author Luciano Pereira dos Santos
@since 15/12/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function J202DSCPRE(oModel)
Local lRet      := .T.
Local oModelNX0 := oModel:GetModel( "NX0MASTER" )
Local cMoePref  := oModelNX0:GetValue("NX0_CMOEDA")
Local dDtPref   := oModelNX0:GetValue("NX0_DTEMI")
Local cPreft    := oModelNX0:GetValue("NX0_COD")

cQuery := " SELECT NX1.R_E_C_N_O_ RECNO "
cQuery +=     " FROM  " + RetSqlName( 'NX8' ) + " NX8, "
cQuery +=     " " + RetSqlName( 'NX1' ) + " NX1 "
cQuery +=     " WHERE NX1.NX1_FILIAL = '" + xFilial("NX1") + "' "
cQuery +=       " AND NX8.NX8_FILIAL = '" + xFilial("NX8") + "' "
cQuery +=       " AND NX8.NX8_CPREFT = '" + cPreft + "' "
cQuery +=       " AND NX8.NX8_CCONTR = NX1.NX1_CCONTR "
cQuery +=       " AND NX8.NX8_CPREFT = NX1.NX1_CPREFT "
cQuery +=       " AND NX1.D_E_L_E_T_ = ' ' "
cQuery +=       " AND NX8.D_E_L_E_T_ = ' ' "

aResQry := JurSQL(cQuery, {"RECNO"} )

lRet := J202ADDESC(aResQry, "NX1", cMoePref, dDtPref)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202ADDESC()
Função para Atualizar os descontos na Pre-Fatura quando vinculados novos
lançamentos.

@author Luciano Pereira dos Santos
@since 15/12/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function J202ADDESC(aRecnoNX1, cAlias, cMoePref, dDtPref)
Local lRet      := .T.
Local cQuery    := ""
Local aResQry   := {{0, "01", "", ""}}
Local aArea     := GetArea()
Local nI        := 0
Local nY        := 0
Local nRecno    := 0
Local nSomaTS   := 0
Local nSomaLT   := 0
Local nPdescH   := 0
Local nDescLin  := 0
Local nDescEsp  := 0
Local nVLTSTmp  := 0
Local nVLLTTmp  := 0
Local aTabVinc  := {}
Local nPos      := 0
Local nVTSTab   := 0
Local lCobraH   := .F.

For nI := 1 To Len(aRecnoNX1)

	NX1->( dbgoto( aRecnoNX1[nI][1] ) )
	nRecno   := NX1->(Recno())
	nPdescH  := NX1->NX1_PDESCH
	nDescEsp := NX1->NX1_VLDESC

	cQuery := " SELECT NUE.NUE_VALOR, NUE.NUE_CMOEDA, NUE.NUE_CLTAB, NRA.NRA_COBRAH "
	cQuery +=      " FROM  " + RetSqlName( 'NUE' ) + " NUE, "
	cQuery +=            " " + RetSqlName( 'NX1' ) + " NX1, "
	cQuery +=            " " + RetSqlName( 'NX8' ) + " NX8, "
	cQuery +=            " " + RetSqlName( 'NRA' ) + " NRA "
	cQuery +=      " WHERE NUE.NUE_FILIAL = '" + xFilial("NUE") + "' "
	cQuery +=         " AND NX1.NX1_FILIAL = '" + xFilial("NX1") + "' "
	cQuery +=         " AND NX8.NX8_FILIAL = '" + xFilial("NX8") + "' "
	cQuery +=         " AND NRA.NRA_FILIAL = '" + xFilial("NRA") + "' "
	cQuery +=         " AND NUE.NUE_CPREFT = NX1.NX1_CPREFT "
	cQuery +=         " AND NUE.NUE_CCLIEN = NX1.NX1_CCLIEN "
	cQuery +=         " AND NUE.NUE_CLOJA  = NX1.NX1_CLOJA "
	cQuery +=         " AND NUE.NUE_CCASO  = NX1.NX1_CCASO "
	cQuery +=         " AND NX8.NX8_CPREFT = NX1.NX1_CPREFT "
    cQuery +=         " AND NX8.NX8_CCLIEN = NX1.NX1_CCLIEN "
    cQuery +=         " AND NX8.NX8_CLOJA  = NX1.NX1_CLOJA "
    cQuery +=         " AND NX8.NX8_CTPHON = NRA.NRA_COD "
	cQuery +=         " AND NX1.R_E_C_N_O_ = " + cValToChar(nRecno) + " "
	cQuery +=         " AND NUE.D_E_L_E_T_ = ' ' "
	cQuery +=         " AND NX1.D_E_L_E_T_ = ' ' "
	cQuery +=         " AND NX8.D_E_L_E_T_ = ' ' "
	cQuery +=         " AND NRA.D_E_L_E_T_ = ' ' "

	aResQry := JurSQL(cQuery, {"NUE_VALOR", "NUE_CMOEDA", "NUE_CLTAB", "NRA_COBRAH" })

	If Len(aResQry) == 0
		aResQry := {{0, "01", "", ""}}
	EndIf

	nSomaTS := 0

	For nY := 1 To Len(aResQry)
		lCobraH := aResQry[nY][4] == "1"

		If cMoePref != aResQry[nY][2]
			nVLTSTmp := JA201FConv(cMoePref, aResQry[nY][2], aResQry[nY][1], "1", dDtPref)[1]
		Else
			nVLTSTmp := aResQry[nY][1]
		EndIf

		If Empty(aResQry[nY][3])
			If lCobraH
				nSomaTS := nSomaTS + nVLTSTmp
			EndIf
		Else  //guarda os valores do TS para verificar com o seu respectivo tabelado vinculado
			nPos := aScan( aTabVinc, { |ax| Alltrim(ax[1]) == Alltrim(aResQry[nY][3]) } )

			If nPos > 0
				aTabVinc[nPos][2] := aTabVinc[nPos][2] + nVLTSTmp
			Else
				aAdd(aTabVinc, {aResQry[nY][3], nVLTSTmp }) //guarda os valores do TS para verificar com o seu respectivo tabelado
			EndIf

		EndIf
	Next nY

	cQuery := " SELECT NV4.NV4_VLHFAT, NV4.NV4_CMOEH, NV4.NV4_COD, NRD.NRD_COBMAI "
	cQuery +=      " FROM " + RetSqlName( 'NV4' ) + " NV4, "
	cQuery +=             " " + RetSqlName( 'NX1' ) + " NX1, "
	cQuery +=             " " + RetSqlName( 'NRD' ) + " NRD "
	cQuery +=      " WHERE NV4.NV4_FILIAL = '" + xFilial("NV4") + "' "
	cQuery +=         " AND NX1.NX1_FILIAL = '" + xFilial("NX1") + "' "
	cQuery +=         " AND NRD.NRD_FILIAL = '" + xFilial("NRD") + "' "
	cQuery +=         " AND NV4.NV4_CPREFT = NX1.NX1_CPREFT  "
	cQuery +=         " AND NV4.NV4_CCLIEN = NX1.NX1_CCLIEN  "
	cQuery +=         " AND NV4.NV4_CLOJA  = NX1.NX1_CLOJA   "
	cQuery +=         " AND NV4.NV4_CCASO  = NX1.NX1_CCASO   "
	cQuery +=         " AND NV4.NV4_CTPSRV = NRD_COD "
	cQuery +=         " AND NX1.R_E_C_N_O_ = " + cValToChar(nRecno) + " "
	cQuery +=         " AND NV4.D_E_L_E_T_ = ' ' "
	cQuery +=         " AND NRD.D_E_L_E_T_ = ' ' "

	aResQry := JurSQL(cQuery, {"NV4_VLHFAT", "NV4_CMOEH", "NV4_COD", "NRD_COBMAI" } )

	If Len(aResQry) == 0
		aResQry   := {{0, "01", "", ""}}
	EndIf

	nVTSTab  := 0
	nSomaLT  := 0

	For nY := 1 To Len(aResQry)

		If cMoePref != aResQry[nY][2]
			nVLLTTmp  := JA201FConv(cMoePref, aResQry[nY][2], aResQry[nY][1], "1", dDtPref)[1]
		Else
			nVLLTTmp  := aResQry[nY][1]
		EndIf

		If aResQry[nY][4] == "1"   // verifica a regra do cobra maior entre Time Sheet	e tabelado vinculado

			nPos := aScan( aTabVinc, { | ax | Alltrim(ax[1]) == Alltrim(aResQry[nY][3]) } )

			If nPos > 0
				If aTabVinc[nPos][2] > nVLLTTmp
					nVLLTTmp := aTabVinc[nPos][2]
				EndIf
				nVTSTab  := nVTSTab + aTabVinc[nPos][2]
			EndIf
		EndIf

		nSomaLT := nSomaLT + nVLLTTmp
	Next nY

	nDescLin := nSomaTS * (nPDescH / 100.00)

	If RecLock("NX1")
		NX1->NX1_VDESCO := nDescLin
		NX1->NX1_VTS    := nSomaTS
		NX1->NX1_VTAB   := nSomaLT
		NX1->NX1_VTSTAB := nVTSTab
		NX1->NX1_VDESCT := nDescEsp + nDescLin
		NX1->(msUnlock())
		NX1->(DbCommit())
		NX1->(DbSkip())
 	Else
 		lRet := .F.
	EndIf

Next nI

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}  JA202RCaso()
Verifica se o usuario logado pode revisar a pré-fatura toda.

@author David G. Fernandes
@since 01/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202RCaso(cPreFt, cUser)
Local lRet      := .F.
Local oModel    := FwModelActive()
Local cQuery    := ""
Local cQueryRes := GetNextAlias()
Local aArea     := GetArea()
Local cRevPre   := ""

cRevPre := JurGetDados('NX0', 1, xFilial('NX0') + Alltrim(cPreFt), 'NX0_CPART')

If cUser == cRevPre
	lRet := .T.
Else
	cQuery := "	SELECT A.CONTA_PRE, B.CONTA_CAS " + CRLF
	cQuery += "	FROM " + CRLF
	cQuery += "	( " + CRLF
	cQuery +=    " SELECT COUNT(NX1.R_E_C_N_O_) CONTA_PRE " + CRLF
	cQuery += "		FROM	" + RetSqlName("NX1") + " NX1 " + CRLF
	cQuery += "		WHERE	NX1.NX1_FILIAL = '" + xFilial("NX1") + "' " + CRLF
	cQuery += "		AND		NX1.NX1_CPREFT = '" + cPreFt + "' " + CRLF
	cQuery += "		AND		NX1.NX1_CPART <> '" + cUser + "' " + CRLF
	cQuery += "		AND		NX1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	) A, " + CRLF
	cQuery += "	( " + CRLF
	cQuery +=    " SELECT COUNT(NVE.R_E_C_N_O_) CONTA_CAS " + CRLF
	cQuery += "		FROM	" + RetSqlName("NVE") + " NVE " + CRLF
	cQuery += "		WHERE	NVE.NVE_FILIAL = '" + xFilial("NVE") + "' " + CRLF
	cQuery +=         " AND EXISTS ( SELECT NX1.R_E_C_N_O_" + CRLF
	cQuery += "															FROM	" + RetSqlName("NX1") + " NX1 " + CRLF
	cQuery += "															WHERE	NX1.NX1_FILIAL = '" + xFilial("NX1") + "' " + CRLF
	cQuery += "															AND		NX1.NX1_CPREFT = '" + cPreFt + "' " + CRLF
	cQuery +=                         " AND NX1.NX1_CCLIEN = NVE.NVE_CCLIEN " + CRLF
	cQuery +=                         " AND NX1.NX1_CLOJA = NVE.NVE_LCLIEN " + CRLF
	cQuery +=                         " AND NX1.NX1_CCASO = NVE.NVE_NUMCAS " + CRLF
	cQuery += "															AND		NX1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "														) " + CRLF
	cQuery += "		AND		NVE.NVE_CPART1 <> '" + cUser + "' " + CRLF
	cQuery += "		AND		NVE.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	) B " + CRLF

	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQueryRes, .T., .F. )

	If (cQueryRes)->CONTA_PRE == 0 .Or. (cQueryRes)->CONTA_CAS == 0
		lRet := .T. // o usuário é o único revisor do caso
	Else
		lRet := .F. // há outros revisores no caso
	EndIf

	(cQueryRes)->( dbCloseArea() )

EndIf

If ExistBlock("JA202REVIS")
	lRet := ExecBlock ("JA202REVIS", .F., .F., {oModel, lRet } )
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202When()

@author TOTVS
@since 01/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202When()
Local lRet    := .F.
Local aArea   := GetArea()
Local cUsr    := JurUsuario(__cUserId)
Local oModel  := FwModelActive()

	If ValType(oModel) == 'O'
		lRet := cUsr == AllTrim( oModel:GetValue("NX1DETAIL", "NX1_CPART" ) ) .Or. ;
				cUsr == AllTrim( oModel:GetValue("NX0MASTER", "NX0_CPART" ) ) .Or. ;
				cUsr == AllTrim( JurGetDados("NVE", 1, xFilial("NVE") + oModel:GetValue("NX1DETAIL", "NX1_CCLIEN") + oModel:GetValue("NX1DETAIL", "NX1_CLOJA") + oModel:GetValue("NX1DETAIL", "NX1_CCASO"), "NVE_CPART1") )
	EndIf
	
	If ExistBlock ("JA202REVIS")
		lRet := ExecBlock ("JA202REVIS", .F., .F., {oModel, lRet } )
	EndIf

	RestArea(aArea)
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202InPad()

@author TOTVS
@since 01/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202InPad()
Local cRet := ""
Local cUsr := JurUsuario(__cUserId)

	cRet := " '" + cUsr + "' == AllTrim( NX1->NX1_CPART ) .Or. "
	cRet += " '" + cUsr + "' == AllTrim( NX0->NX0_CPART ) .Or. "
	cRet += " '" + cUsr + "' == AllTrim( JurGetDados('NVE', 1, xFilial('NVE') + NX1->NX1_CCLIEN + NX1->NX1_CLOJA + NX1->NX1_CCASO, 'NVE_CPART1') )"

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202DIVTS()
Rotina para dividir os timesheets marcados na pré-fatura.

@Param  oModel       - Modelo de dados da Pré-fatura
@param  lAutomato    - Indica se a chamada é feita via automação.
@param  aNewValTs    - Array com os valores já definidos para a automação de teste.
        aNewValTs[1] - Valor lançado Novo (conforme o parametro MV_JURTS2)
        aNewValTs[2] - Valor revisado Novo (conforme o parametro MV_JURTS2)

@return lRet         - Validação da função

@author Luciano Pereira dos Santos
@since 10/10/14
/*/
//-------------------------------------------------------------------
Static Function J202DIVTS(oModel, lAutomato, aNewValTs)
Local lRet      := .T.
Local aMarkTS   := {}
Local aDivTSs   := {}
Local aErrTSs   := {}
Local aNewTSs   := {}
Local cMemlog   := ""
Local cCodTS    := ""
Local lLibTudo  := .F.
Local lLibAlter := .F.
Local aRetBlqTS :={}

Begin Sequence
	FWMsgRun(, {|| __InMsgRun := .T., aMarkTS := J202FindMd(oModel:GetModel("NUEDETAIL"), "NUE_TKRET", .T., {"RECNO"}), __InMsgRun := .F.}, STR0147, STR0167) //Aguarde... / Atualizando Lançamentos

	If Len(aMarkTS[2]) == 0
		ApMsgInfo(STR0265) // "Para dividir um Time Sheet, você deve marcá-lo."
		lRet := .F.
		Break
	EndIf

	If !Empty(aMarkTS)
		NUE->(DbGoTo(aMarkTS[2][1]))
		If lLibParam
			aRetBlqTS := JBlqTSheet(NUE->NUE_DATATS) //Esta errado, deve verificar todos os TS!!!
			lLibTudo  := aRetBlqTS[1]
			lLibAlter := aRetBlqTS[3]
			lLibParam := aRetBlqTS[5]
		EndIf

		If !lLibParam
			lRet := .F.
		EndIf

		If !lLibTudo .And. !lLibAlter
			cCodTS += AllTrim(NUE->NUE_COD) + "; "
		EndIf

		If !Empty(cCodTS) .And. lLibParam
			ApMsgInfo(STR0264 + cCodTS)  // "Você não tem permissão para alterar os seguintes Time Sheets: "
			lRet := .F.
			Break
		EndIf

		If lRet := oModel:VldData()
			If oModel:lModify   // Necessário pois se o modelo não foi alterado o commit retorna .F.
				lRet := oModel:CommitData()  //Confirmar modelo de dados para não perder as alterações anteriores a operação.
			EndIf
		EndIf

		If lRet .And. !Empty(aDivTSs := J202DivTsR(aMarkTS[2], lAutomato, aNewValTs)) .And. lLibParam
			aNewTSs := aDivTSs[1]
			aErrTSs := aDivTSs[2]

			cMemlog := JurLogLote(.F.)

			If !Empty(aNewTSs)
				cMemlog += STR0260 + CRLF + AtoC(aNewTSs, CRLF) //"Novo(s) TimeSheet(s) :"
				cMemlog += CRLF + Replicate( "-", 65 ) +CRLF+CRLF
			Else
				lRet := .F. //Se nenhum TS foi dividido não precisa rodar a 202Totpre()
			EndIf

			If !Empty(aErrTSs) .And. lLibParam
				cMemlog += STR0207 + CRLF + AtoC(aErrTSs, CRLF) // "Não foi possivel dividir os segunte(s) TimeSheet(s): "
				cMemlog += CRLF + Replicate( "-", 65 ) +CRLF+CRLF
			EndIf

			If !Empty(cMemlog)
				ApMsgInfo(cMemlog, STR0110) //"Dividir TS"
			Else
				lRet := .F.
			EndIf

		Else
			lRet := .F.
		EndIf

	Else
		lRet := .F.
	EndIf

End Sequence

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}  J202DivTsR()
Rotina de processamento da divisão de TimeSheet.

@param  aPosiTS      - Array com as posições dos recnos do TS
@param  lAutomato    - Indica se a chamada é feita via automação.
@param  aNewValTs    - Array com os valores já definidos para a automação de teste.
        aNewValTs[1] - Valor lançado Novo (conforme o parametro MV_JURTS2)
        aNewValTs[2] - Valor revisado Novo (conforme o parametro MV_JURTS2)

@return aRet         - Array com os códigos dos timesheets divididos ou não.
         aRet[1]     - Array com os Ts divididos
         aRet[2]     - Array com os Ts não divididos

@author Luciano Pereira dos Santos
@since 20/03/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202DivTsR(aPosiTS, lAutomato, aNewValTs)
Local aArea     := (GetArea())
Local aAreaNUE  := NUE->(GetArea())
Local aErrTSs   := {}
Local nI        := 0
Local cCodTS    := ""
Local aNewTSs   := {}
Local oView     := Nil

If !Empty(aPosiTS)

	oModelOld := FwModelActive() //Guarda o Modelo da JURA202
	oView     := FwViewActive()

	Begin Transaction

		For nI := 1 To Len(aPosiTS)

			NUE->(DbGoTo(aPosiTS[nI]))

			//Necessário para o funcionamento das consultas padrão da tela de divisão de TS
			M->NUE_CGRPCL := NUE->NUE_CGRPCL
			M->NUE_CCLIEN := NUE->NUE_CCLIEN
			M->NUE_CLOJA  := NUE->NUE_CLOJA
			M->NUE_CCASO  := NUE->NUE_CCASO

			If lLibParam .And. !lAutomato
				cCodTS := JA144DivTS()
			ElseIf lAutomato
				cCodTS := JA144DivTS({NUE->NUE_CGRPCL, NUE->NUE_CCLIEN, NUE->NUE_CLOJA, NUE->NUE_CCASO, /*cSigla1*/, NUE->NUE_UTL, NUE->NUE_UTR, aNewValTs[1], aNewValTs[2], .F.})
			EndIf

			If cCodTS == ".F."
				Aadd(aErrTSs, NUE->NUE_COD)
			Else
				Aadd(aNewTSs, cCodTS )
			EndIf

		Next nI

		If !Empty(aNewTSs)

			While __lSX8
				ConFirmSX8()
			EndDo

			If !Empty(oModelOld) .And. !lAutomato //Recarrega/Atualiza o modelo para efetuar o recalculo dos TS incluidos na pré-fatura pelo modelo (202totpre).
				FwModelActive(oModelOld)
				oModelOld:Deactivate()
				oModelOld:Activate()
				oView:Refresh()
			EndIf

		Else

			DisarmTransaction()
			While __lSX8
				RollBackSX8()
			EndDo

		EndIf

	End Transaction

Else

	ApMsgStop(STR0204) //Não foi selecionado nenhum TS para divisão! Verifique.

EndIf

RestArea(aAreaNUE)
RestArea(aArea)

Return {aNewTSs, aErrTSs }

//-------------------------------------------------------------------
/*/{Protheus.doc} J202FindMd(oModel, cCpoCond, xCondcao, aCampos, aValor)
Função utilizada para localizar nas linhas alteradas do modelo e trazer
o array com valor do, numero da linha ou recno do registro.

@param oModel     Modelo de dados
@param cCpoCond   Nome do campo que será localizado uscado
@param xCondcao   Valor a ser encontrado
@param aCampo     Array com os nomes dos campo para o conteudo de retorno

@Return aValor    Array com valor do campos

@author Luciano Pereira dos Santos
@since 18/10/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J202FindMd(oModel, cCpoCond, xCondcao, aCampos)
Local aRet   := {}
Local aPosic := {}
Local aRecno := {}
Local aValor := {}
Local nI     := 0
Local nY     := 0
Local aLines := oModel:GetLinesChanged()
Local nQtd   := Len(aLines)

For nI := 1 To nQtd
	nPos := aLines[nI]
	If !oModel:IsDeleted(nPos) .And. oModel:GetValue(cCpoCond, nPos) == xCondcao
		For nY := 1 To Len(aCampos)
			If aCampos[nY] == "POSICAO"
				aAdd(aPosic, nPos)
			ElseIf aCampos[nY] == "RECNO"
				aAdd(aRecno, oModel:GetDataID(nPos))
			Else
				aAdd(aValor, oModel:GetValue(aCampos[nY], nPos))
			EndIf
		Next nY
	EndIf
Next nI

aRet := {aPosic, aRecno, aValor}

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202SQLVlP()
Indica se a pre-fatura ainda nao foi faturada.

@param cCod      , Codigo da pre-fatura
@param cQrySQLVlP, Variavel a ser utilizada para montar a query
@param cAlsSQLVlP, Alias a ser utilizado pela query
@param lBindParam, Indica se a função MPSysOpenQuery faz o bind de queries

@author Totvs
/*/
//-------------------------------------------------------------------
Static Function J202SQLVlP(cCod, cQrySQLVlP, cAlsSQLVlP, lBindParam)
Local lRet   := .F.
Local cQuery := ""

	If Empty(cAlsSQLVlP)
		cAlsSQLVlP := GetNextAlias()
		cQrySQLVlP := " SELECT A.QTD TOTAL, B.QTD PENDENTE "
		cQrySQLVlP +=   " FROM "
		cQrySQLVlP +=      " ( SELECT 'TOT' TIPO, COUNT(1) QTD "
		cQrySQLVlP +=          " FROM " + RetSqlname('NXG') + " NXG "
		cQrySQLVlP +=         " WHERE NXG.NXG_FILIAL = '" + xFilial("NXG") + "' "
		cQrySQLVlP +=           " AND NXG.NXG_CPREFT = ? "
		cQrySQLVlP +=           " AND NXG.D_E_L_E_T_ = ' ' "
		cQrySQLVlP +=      " ) A, "
		cQrySQLVlP +=      " ( SELECT 'PEN' TIPO, COUNT(1) QTD "
		cQrySQLVlP +=          " FROM " + RetSqlname('NXG') + " NXG "
		cQrySQLVlP +=         " WHERE NXG.NXG_FILIAL = '" + xFilial("NXG") + "' "
		cQrySQLVlP +=           " AND NXG.NXG_CPREFT = ? "
		cQrySQLVlP +=           " AND NXG.NXG_CFATUR = '" + Space(TamSx3('NXG_CFATUR')[1]) + "' "
		cQrySQLVlP +=           " AND NXG.NXG_CESCR = '" + Space(TamSx3('NXG_CESCR')[1]) + "' "
		cQrySQLVlP +=           " AND NXG.D_E_L_E_T_ = ' ' "
		cQrySQLVlP +=      " ) B "
		cQrySQLVlP := ChangeQuery(cQrySQLVlP)
	EndIf

	// Quando lBindParam é .F. indica que na lib atual a função MPSysOpenQuery não faz a substituição dos "?" na query.
	// Por isso executamos a função J202QryBind, para fazer essa substuição
	cQuery := IIf(lBindParam, cQrySQLVlP, J202QryBind(cQrySQLVlP, {cCod, cCod}))

	MPSysOpenQuery(cQuery, cAlsSQLVlP,,, {cCod, cCod})

	If (cAlsSQLVlP)->(!Eof())
		lRet := (cAlsSQLVlP)->TOTAL > 0 .And. ((cAlsSQLVlP)->TOTAL - (cAlsSQLVlP)->PENDENTE) == 0
	EndIf

	(cAlsSQLVlP)->(DbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}  JA202VIEW()
Função para Chamada pelo botão preview

@param cOrigem  , Indica o ponto que chamou a rotina
                  "BROWSE" - Botão de resumo no Browse
                  "BTPREV" - Botão de resumo dentro do Modelo
@param oView    , Objeto da View de Pré-Fatura (chamada via modelo)
@param lAutomato, Execução via automação

@author David G. Fernandes
@since 18/04/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202VIEW(cOrigem, oView, lAutomato)
Local aArea     := GetArea()
Local cPreft    := NX0->NX0_COD
Local aValores  := {}
Local oModel    :=  Nil
Local lRet      := .T.
Local cMarca    := ""
Local lInvert   := .F.
Local cMsglog   := ""
Local cCrysPath := JurCrysPath(@cMsglog) //Caminho dos arquivos exportados do Crystal

Default lAutomato := .F.

If !lAutomato
	cMarca    := oMarkUp:Mark()
	lInvert   := oMarkUp:IsInvert()
	JurCrLog(cMsglog)
EndIf

If cOrigem == "BTPREV"
	oModel := FWModelActive()
	If oModel:lModify
		ApMsgStop(STR0193 + CRLF + STR0199) //"Existem alterações não confirmadas, para efetuar esta operação, confirme as alterações."
		lRet := .F.
	EndIf
EndIf

If lRet .And. NX0->NX0_SITUAC == '3'
	Processa( {|| lRet := JA202REFAZ( cPreft, .T., '', cCrysPath, lAutomato)}, STR0147, STR0148 + " " + cPreft, .F. ) //"Aguarde..." ### "Refazendo a Pré-Fatura "
	If lRet .And. NX0->( dBSeek( xFilial("NX0") + cPreft ) )
		RecLock("NX0", .F.)
		NX0->NX0_OK := Iif(lInvert, cMarca, Space(TamSX3("NX0_OK")[1])) // Limpa a marca
		NX0->(MsUnLock())
		NX0->(dbCommit())

		If cOrigem == 'BTPREV'
			oModel := FWModelActive()
			oModel:Deactivate()
			FWMsgRun(, {|| oModel:Activate(), oView:Refresh()}, STR0147, STR0167) // #"Aguarde..." ##"Atualizando Lançamentos"
		EndIf

	Else
		ApMsgStop( STR0071 ) //"Erro ao refazer a pré-fatura!"
		lRet := .F.

	EndIf
EndIf

If lRet
	aValores := JA202AVlrs(cPreft)

	If !lAutomato
		If ExistBlock("J202RESPF")
			ExecBlock( "J202RESPF", .F., .F., {aValores} )
		Else
			JA202PView(aValores)
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202PView()
Função padrão para Mostrar a tela de preview dos valores

@author David G. Fernandes
@since 18/04/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA202PView(aValores)
Local oTela      := Nil
Local cPnlDlg    := Nil
Local cPnlBot    := Nil
Local oPnlTsOri  := Nil
Local oPnlTmp1   := Nil
Local oPnlTsDes  := Nil
Local oTitOrig   := Nil
Local oTitDes    := Nil
Local oTitObs    := Nil
Local oTotal1    := Nil
Local oTotDes1   := Nil
Local oTotal2    := Nil
Local oTotDes2   := Nil
Local nI         := 0
Local aCampos    := {}
Local utemp      := "Tmp"
Local lExibeNac  := !(NX0->NX0_CMOEDA == SuperGetMV( 'MV_JMOENAC',, '01' ))
Local nSoma1     := 0
Local nSoma2     := 0
Local nEsc       := 3
Local oArialB    := TFont():New("Arial",,,, .T.,,,, .F., .F.) // Arial Bold
Local oMainColl  := Nil
Local oLayer     := FWLayer():New()
Local lTSNCobra  := SuperGetMV( 'MV_JTSNCOB',, .F. ) // Indica se vincula TimeSheet não cobrável na emissão

	If Empty(aValores)
		MsgInfo(STR0194) //"É necessário informar os valores a serem exibidos."
		Return .F.
	EndIf

	DEFINE MSDIALOG oDlg TITLE STR0195 FROM 000,000 TO 500, IIf(lExibeNac, 590, 460) PIXEL // "Resumo dos valores da pré-fatura"

	oLayer:init(oDlg,.F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
	oLayer:addCollumn("MainColl",100,.F.) //Cria as colunas do Layer
	oMainColl := oLayer:GetColPanel( 'MainColl' )

	oTela   := TJurPanel():New(0,0,0,0,oMainColl,"",.F.,.F.,CONTROL_ALIGN_ALLCLIENT)
	cPnlDlg := oTela:AddHorizontalPanel( 80 )
	cPnlBot := oTela:AddHorizontalPanel( 20 )

	If lExibeNac
		oPnlTsOri := oTela:AddVerticalPanel( 50, cPnlDlg )
		oPnlTsDes := oTela:AddVerticalPanel( 50, cPnlDlg )

		oTitOrig  := tSay():New( 05, 05, { || STR0196 }, oTela:GetPanel(oPnlTsOri), , , , , , .T., CLR_BLACK, , 100, 10 ) // "Totais da Pré-Fatura"
		oTitDes   := tSay():New( 05, 05, { || STR0197 }, oTela:GetPanel(oPnlTsDes), , , , , , .T., CLR_BLACK, , 100, 10 ) // "Totais da Pré-Fatura na Moeda Nacional"

	Else
		oPnlTmp1  := oTela:AddVerticalPanel( 20, cPnlDlg )
		oPnlTsOri := oTela:AddVerticalPanel( 100, cPnlDlg )
		oTitOrig  := tSay():New( 05, 05, { || STR0196 }, oTela:GetPanel(oPnlTsOri), , , , , , .T., CLR_BLACK, , 100, 10 ) // "Totais da Pré-Fatura"
	EndIf
	nI := 1

	nSoma1  := 0
	nSoma2  := 0
	For nI := 1 To Len(aValores)
		aAdd( aCampos , {"", "", "", ""})

		&( utemp + "_TIT1" ) := TJurPnlCampo():New( nEsc + 10 + ((nI - 1) * 12), 05, 075, 012,;
									oTela:GetPanel(oPnlTsOri),;
												"", "",;
												{ ||  },;
												{ ||  },;
												aValores[ni][3],;
												/*lVisivel*/, /*lEnable*/, )
		aCampos[ni][1] := &( utemp + "_TIT1" )
		aCampos[ni][1]:Valor := aValores[ni][3]
		aCampos[ni][1]:oCampo:bWhen := { || .F. }

		&( utemp + "_VAL1" ) :=  TJurPnlCampo():New( nEsc + 10+((ni-1)*12), 80, 060, 012,;
									oTela:GetPanel(oPnlTsOri),;
												"", "",;
												{ ||  },;
												{ ||  },;
												aValores[ni][4],;
												/*lVisivel*/, /*lEnable*/, )
		aCampos[ni][2] := &( utemp + "_VAL1" )
		aCampos[ni][2]:Valor := aValores[ni][4]
		aCampos[ni][2]:oCampo:bWhen   := { || .F. }
		aCampos[ni][2]:oCampo:Picture := "@E 99,999,999,999.99"

		If aValores[ni][2] != "NX8_VUTFAT" // Desconsira pois o valor já está acumulado no NX8_VTS
			If aValores[ni][1]  == "+"
				nSoma1 := nSoma1 + aValores[ni][4]
			ElseIf aValores[ni][1]  == "-"
				nSoma1 := nSoma1 - aValores[ni][4]
			EndIf
		EndIf

		If lExibeNac
			&( utemp + "_TIT2" ) :=  TJurPnlCampo():New( nEsc + 10+((ni-1)*12), 05, 075, 012,;
										oTela:GetPanel(oPnlTsDes),;
													"", "",;
													{ ||  },;
													{ ||  },;
													aValores[ni][5],;
													/*lVisivel*/, /*lEnable*/, )
			aCampos[ni][3] := &( utemp + "_TIT2" )
			aCampos[ni][3]:Valor := aValores[ni][5]
			aCampos[ni][3]:oCampo:bWhen := { || .F. }

			&( utemp + "_VAL2" ) :=  TJurPnlCampo():New( nEsc + 10+((ni-1)*12), 80, 060, 012,;
										oTela:GetPanel(oPnlTsDes),;
													"", "",;
													{ ||  },;
													{ ||  },;
													aValores[ni][6],;
													/*lVisivel*/, /*lEnable*/, )
			aCampos[ni][4]	:= &( utemp + "_VAL2" )
			aCampos[ni][4]:Valor := aValores[ni][6]
			aCampos[ni][4]:oCampo:bWhen := { || .F. }
			aCampos[ni][4]:oCampo:Picture 	:= "@E 99,999,999,999.99"

			If aValores[ni][1]  == "+"
				nSoma2 := nSoma2 + aValores[ni][6]
			ElseIf aValores[ni][1]  == "-"
				nSoma2 := nSoma2 - aValores[ni][6]
			EndIf
		EndIf

		If aValores[ni][7]
			nEsc += 3
		EndIf

	Next ni

	oTotDes1 :=  TJurPnlCampo():New( nEsc + 10+((ni-1)*12), 05, 075, 012,;
								oTela:GetPanel(oPnlTsOri),;
											"", "",;
											{ ||  },;
											{ ||  },;
											STR0252,;
											/*lVisivel*/, /*lEnable*/, )

	oTotDes1:Valor := STR0252 //"Total: "
	oTotDes1:oCampo:bWhen := { || .F. }
	oTotDes1:oCampo:oFont := oArialB

	oTotal1 :=  TJurPnlCampo():New( nEsc + 10+((ni-1)*12), 80, 060, 012,;
								oTela:GetPanel(oPnlTsOri),;
											"", "",;
											{ ||  },;
											{ ||  },;
											nSoma1,;
											/*lVisivel*/, /*lEnable*/, )

	oTotal1:Valor := nSoma1
	oTotal1:oCampo:bWhen := { || .F. }
	oTotal1:oCampo:Picture := "@E 99,999,999,999.99"
	oTotal1:oCampo:oFont := oArialB

	If lExibeNac
		oTotDes2 := TJurPnlCampo():New( nEsc + 10+((ni-1)*12), 05, 075, 012,;
								oTela:GetPanel(oPnlTsDes),;
											"", "",;
											{ ||  },;
											{ ||  },;
											STR0252,;
											/*lVisivel*/, /*lEnable*/, )

		oTotDes2:Valor := STR0252 //"Total: "
		oTotDes2:oCampo:bWhen := { || .F. }
		oTotDes2:oCampo:oFont := oArialB

		oTotal2 :=  TJurPnlCampo():New(nEsc + 10+((ni-1)*12), 80, 060, 012,;
									oTela:GetPanel(oPnlTsDes),;
												"", "",;
												{ ||  },;
												{ ||  },;
												nSoma2,;
												/*lVisivel*/, /*lEnable*/, )
		oTotal2:Valor := nSoma2
		oTotal2:oCampo:bWhen   := { || .F. }
		oTotal2:oCampo:Picture := "@E 99,999,999,999.99"
		oTotal2:oCampo:oFont   := oArialB
	EndIf

	oTitObs := tSay():New( 05, 05, { || STR0198 }, oTela:GetPanel(cPnlBot), , , , , , .T., CLR_BLACK, , 100, 10 ) //"OBS.: Não dedução de impostos"

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| }, {|| oDlg:End()},, /*aButtons*/, /*nRecno*/, /*cAlias*/, .F., .F., .F., .F., .F. )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202AVlrs
Função gerar o array de valores do resumo da pré-fatura.

@param   cPreft, Código da Pré-Fatura

@return aValores, Estrutura do array aValores:
                  [1] - Tipo (H - honorários / D -  Despesas / L - Limite
                  [2] - Titulo 1 - Título do campo na moeda da pré
                  [3] - Valor 1 -  Valor do campo na moeda da pré
                  [4] - Titulo 2 - Título do campo na moeda nacional
                  [5] - Valor 2 - Valor do campo na moeda nacional

@author David G. Fernandes
@since 18/04/2012
/*/
//-------------------------------------------------------------------
Static Function JA202AVlrs(cPreft)
Local aArea     := GetArea()
Local cTmp      := GetNextAlias()
Local aValores  := {}
Local cCTOSIMB  := ""
Local cCotac    := ""
Local lTemLim   := .F.
Local lFaixa    := .F.
Local cMoeNac   := SuperGetMV( 'MV_JMOENAC',, '01' )
Local lMvVincTS := GetMv('MV_JVINCTS ',, .T.)
Local cQuery    := ""
Local cQueryTs  := ""
Local lDespTrib := NX8->(ColumnPos('NX8_VLREMB')) > 0
Local lTSNCobra := NX8->(ColumnPos("NX8_VTSNC")) > 0 .And. SuperGetMV("MV_JTSNCOB",, .F.) // @12.1.2210

	cQueryTs := " CASE WHEN NX8.NX8_CMOELI > '  ' OR NX8.NX8_VLRLI > 0 OR NX8.NX8_CFTADC > '" + Space(TamSx3('NX8_CFTADC')[1]) + "'  THEN NX8.NX8_VTS " // Se tem limite ou é FA não pode somente somar o valor dos lançamentos
	cQueryTs += " ELSE " 
	cQueryTs +=      " (SELECT SUM(ROUND(NUE.NUE_VALOR * NUE.NUE_COTAC1 / NUE.NUE_COTAC2,"+ cValToChar(TamSX3('NUE_VALOR')[2])+")) " 
	cQueryTs +=         " FROM " + RetSqlName("NUE") + " NUE, " + RetSqlName("NX1") + " NX1 " 
	cQueryTs +=        " WHERE NUE.NUE_FILIAL = '" + xFilial("NUE") + "' " 
	cQueryTs +=          " AND NX1.NX1_FILIAL = '" + xFilial("NX1") + "' " 
	cQueryTs +=          " AND NX1.NX1_CPREFT = NX8.NX8_CPREFT " 
	cQueryTs +=          " AND NX1.NX1_CCONTR = NX8.NX8_CCONTR " 
	cQueryTs +=          " AND NUE.NUE_CPREFT = NX1.NX1_CPREFT " 
	cQueryTs +=          " AND NUE.NUE_CCLIEN = NX1.NX1_CCLIEN " 
	cQueryTs +=          " AND NUE.NUE_CLOJA = NX1.NX1_CLOJA " 
	cQueryTs +=          " AND NUE.NUE_CCASO = NX1.NX1_CCASO " 
	cQueryTs +=          " AND NX1.D_E_L_E_T_ = ' ' " 
	cQueryTs +=          " AND NUE.D_E_L_E_T_ = ' ' )" 
	cQueryTs += " END " 

	cQuery := " SELECT A.NX0_COD, "
	cQuery +=        " A.CTO_SIMB, "
	cQuery +=        " SUM(A.NX8_VTS) VTS, "
	cQuery +=        " SUM(A.NX8_VTAB) VTAB, "
	cQuery +=        " SUM(A.NX8_VDESP) VDESP, "
	If lDespTrib
		cQuery +=    " SUM(A.NX8_VLREMB) VLREMB, "
		cQuery +=    " SUM(A.NX8_VLTRIB) VLTRIB, "
	EndIf
	cQuery +=        " SUM(A.NX8_VLDESC) VLDESC, "
	cQuery +=        " SUM(A.NX8_VDESCO) VDESCO, "
	cQuery +=        " SUM(A.NX8_VDESCT) VDESCT, "
	cQuery +=        " A.NX0_ACRESH ACRESH, "
	cQuery +=        " SUM(A.NX8_VFIXO) VFIXO, "
	If NX8->(ColumnPos("NX8_VFXVIN")) > 0 //Proteção
		cQuery +=    " SUM(A.NX8_VFXVIN) VFXVIN, "
	EndIf
	cQuery	+=       " SUM(A.NX8_VTSVIN) VTSVIN, "
	If lTSNCobra
		cQuery	+=   " SUM(A.NX8_VTSNC) VTSNC, "
	EndIf
	If NX8->(ColumnPos("NX8_VTBVIN")) > 0 //Proteção
		cQuery	+=   " SUM(A.NX8_VTBVIN) VTBVIN, "
	Else
		cQuery	+=   " 0 VTBVIN, "
	EndIf

	cQuery +=        " SUM(A.NX8_VFXFAT) VFAIXA, "
	cQuery +=        " SUM(A.NX8_VEXFX) VEXCFX, "
	cQuery +=        " SUM(A.NX8_VEXHR) VEXCHR, "
	cQuery +=        " SUM(A.NX8_VLTSLM) VLTSLM, "
	cQuery +=        " SUM(A.NX8_VLLTLM) VLLTLM, "
	cQuery +=        " SUM(A.NX8_VLFXLM) VLFXLM, "
	cQuery +=        " SUM(A.NX8_VLFALM) VLFALM, "
	cQuery +=        " SUM(A.NX8_VUTFAT) VUTFAT, "
	cQuery +=        " SUM(A.NX8_VSLDPX) VSLDPX, "
	cQuery +=        " A.COTAC, "
	cQuery +=        " SUM(A.VTS_01 * A.COTAC) VTS_01, "
	cQuery +=        " SUM(A.VTAB_01 * A.COTAC) VTAB_01, "
	cQuery +=        " SUM(A.VDESP_01 * A.COTAC) VDESP_01, "
	If lDespTrib
		cQuery +=    " SUM(A.NX8_VLREMB * A.COTAC) VLREMB_01, "
		cQuery +=    " SUM(A.NX8_VLTRIB * A.COTAC) VLTRIB_01, "
	EndIf
	cQuery +=        " SUM(A.NX8_VLDESC * A.COTAC) VLDESC_01, "
	cQuery +=        " SUM(A.NX8_VDESCO * A.COTAC) VDESCO_01, "
	cQuery +=        " SUM(A.NX8_VDESCT * A.COTAC) VDESCT_01, "
	cQuery +=        " A.NX0_ACRESH * A.COTAC ACRESH_01, "
	cQuery +=        " SUM(A.NX8_VFIXO  * A.COTAC) VFIXO_01, "

	If NX8->(ColumnPos("NX8_VFXVIN")) > 0 // Proteção
		cQuery +=    " SUM(A.NX8_VFXVIN * A.COTAC) VFXVIN_01, "
	EndIf
	
	cQuery	+=       " SUM(A.NX8_VTSVIN * A.COTAC) VTSVIN_01, "

	If lTSNCobra
		cQuery	+=   " SUM(A.NX8_VTSNC * A.COTAC) VTSNC_01, " 
	EndIf

	If NX8->(ColumnPos("NX8_VTBVIN")) > 0 // Proteção
		cQuery	+=   " SUM(A.NX8_VTBVIN * A.COTAC) VTBVIN_01, " 
	Else
		cQuery	+=   " 0 VTBVIN_01, " 
	EndIf

	cQuery +=        " SUM(A.NX8_VFXFAT * A.COTAC) VFAIXA_01, " 
	cQuery +=        " SUM(A.NX8_VEXFX * A.COTAC) VEXCFX_01, " 
	cQuery +=        " SUM(A.NX8_VEXHR * A.COTAC) VEXCHR_01, " 
	cQuery +=        " SUM(A.NX8_VLTSLM * A.COTAC) VLTSLM_01, " 
	cQuery +=        " SUM(A.NX8_VLLTLM * A.COTAC) VLLTLM_01, " 
	cQuery +=        " SUM(A.NX8_VLFXLM * A.COTAC) VLFXLM_01, " 
	cQuery +=        " SUM(A.NX8_VLFALM * A.COTAC) VLFALM_01, " 
	cQuery +=        " SUM(A.NX8_VUTFAT * A.COTAC) VUTFAT_01, " 
	cQuery +=        " SUM(A.NX8_VSLDPX * A.COTAC) VSLDPX_01 " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery +=  " SELECT NX0.NX0_COD, " 
	cQuery +=         " CTO.CTO_SIMB, " 
	If lMvVincTS
		cQuery +=     " CASE WHEN ( NRA.NRA_COBRAH = '2' and NRA.NRA_COBRAF = '1' ) Or (NX8.NX8_VFXFAT > 0) Or (NX8_TPCEXC <> ' ') THEN 0 ELSE NX8.NX8_VTS END AS NX8_VTS, " 
		cQuery +=     " CASE WHEN ( NRA.NRA_COBRAH = '2' and NRA.NRA_COBRAF = '1' ) Or (NX8.NX8_VFXFAT > 0) Or (NX8_TPCEXC <> ' ') THEN 0 ELSE "+cQueryTs+" END AS VTS_01, " 
	Else
		cQuery +=     " CASE WHEN (NX8.NX8_VFXFAT > 0) Or (NX8_TPCEXC <> ' ') THEN 0 ELSE NX8.NX8_VTS END AS NX8_VTS, " 
		cQuery +=     " CASE WHEN (NX8.NX8_VFXFAT > 0) Or (NX8_TPCEXC <> ' ') THEN 0 ELSE "+cQueryTs+" END AS VTS_01, " 
	EndIf
	cQuery +=        " NX8.NX8_VTAB, " 
	cQuery +=        " CASE WHEN NX8.NX8_CMOELI > '  ' OR NX8.NX8_VLRLI > 0 OR NX8.NX8_CFTADC > '"+ Space(TamSx3('NX8_CFTADC')[1]) + "'  THEN "  // Se tem limite ou é FA não pode somente somar o valor dos lançamentos
	cQuery +=            " NX8.NX8_VTAB " 
	cQuery +=        " ELSE " 
	cQuery +=            " (SELECT SUM(ROUND(NV4.NV4_VLHFAT * NV4.NV4_COTAC1 / NV4.NV4_COTAC2 ,"+ cValToChar(TamSX3('NV4_VLHFAT')[2])+")) " 
	cQuery +=                     " FROM " + RetSqlName("NV4") + " NV4, " + RetSqlName("NX1") + " NX1 " 
	cQuery +=                     " WHERE NV4.NV4_FILIAL = '" + xFilial("NV4") + "' " 
	cQuery +=                       " AND NX1.NX1_FILIAL = '" + xFilial("NX1") + "' " 
	cQuery +=                       " AND NX1.NX1_CPREFT = NX8.NX8_CPREFT " 
	cQuery +=                       " AND NX1.NX1_CCONTR = NX8.NX8_CCONTR " 
	cQuery +=                       " AND NV4.NV4_CPREFT = NX1.NX1_CPREFT " 
	cQuery +=                       " AND NV4.NV4_CCLIEN = NX1.NX1_CCLIEN " 
	cQuery +=                       " AND NV4.NV4_CLOJA = NX1.NX1_CLOJA " 
	cQuery +=                       " AND NV4.NV4_CCASO = NX1.NX1_CCASO " 
	cQuery +=                       " AND NV4.D_E_L_E_T_ = ' ' " 
	cQuery +=                       " AND NX1.D_E_L_E_T_ = ' ')" 
	cQuery +=        " END VTAB_01, " 

	cQuery	+=        " NX8.NX8_VDESP, " 
	cQuery	+=        " CASE WHEN NX8.NX8_CFTADC > '"+ Space(TamSx3('NX8_CFTADC')[1])+"' THEN "  // Se é FA não pode somente somar o valor dos lançamentos
	cQuery	+=          " NX8.NX8_VDESP " 
	cQuery	+=        " ELSE " 
	cQuery	+=         " (SELECT SUM(ROUND(NVY.NVY_VALOR * NVY.NVY_COTAC1 / NVY.NVY_COTAC2," + cValToChar(TamSX3('NVY_VALOR')[2]) + ")) " 
	cQuery	+=                " FROM " + RetSqlName("NVY") + " NVY, " + RetSqlName("NX1") + " NX1 " 
	cQuery	+=               " WHERE NVY.NVY_FILIAL = '" + xFilial("NVY") + "' " 
	cQuery +=                 " AND NX1.NX1_CPREFT = NX8.NX8_CPREFT " 
	cQuery +=                 " AND NX1.NX1_CCONTR = NX8.NX8_CCONTR " 
	cQuery +=                 " AND NVY.NVY_CPREFT = NX1.NX1_CPREFT " 
	cQuery +=                 " AND NVY.NVY_CCLIEN = NX1.NX1_CCLIEN " 
	cQuery +=                 " AND NVY.NVY_CLOJA = NX1.NX1_CLOJA " 
	cQuery +=                 " AND NVY.NVY_CCASO = NX1.NX1_CCASO " 
	cQuery +=                 " AND NVY.D_E_L_E_T_ = ' ' " 
	cQuery +=                 " AND NX1.D_E_L_E_T_ = ' ')" 
	cQuery +=        " END VDESP_01, " 

	cQuery	+=       " NX8.NX8_VLDESC, "
	If lDespTrib
		cQuery +=    " NX8.NX8_VLREMB, "
		cQuery +=    " NX8.NX8_VLTRIB, "
	EndIf
	cQuery +=        " NX8.NX8_VDESCO, "
	cQuery +=        " NX8.NX8_VDESCT, "
	cQuery +=        " NX0.NX0_ACRESH, "
	cQuery +=        " CASE WHEN ( NX8.NX8_VFXFAT > 0 ) THEN 0 ELSE NX8.NX8_VFIXO END NX8_VFIXO, " 

	If NX8->(ColumnPos("NX8_VFXVIN")) > 0 //Proteção
		cQuery +=    " NX8.NX8_VFXVIN, "
	Else
		cQuery +=    " 0 NX8_VFXVIN, "
	EndIf
	cQuery +=        " NX8.NX8_VTSVIN, "

	If lTSNCobra
		cQuery +=    " NX8.NX8_VTSNC, " 
	Else
		cQuery +=    " 0 NX8_VTSNC, "
	EndIf

	If NX8->(ColumnPos("NX8_VTBVIN")) > 0 //Proteção
		cQuery +=        " NX8.NX8_VTBVIN, " 
	Else
		cQuery +=        " 0 NX8_VTBVIN, " 
	EndIf

	cQuery +=        " NX8.NX8_VFXFAT, " 
	cQuery +=        " NX8.NX8_VEXFX, " 
	cQuery +=        " NX8.NX8_VEXHR, " 
	cQuery +=        " NX8.NX8_VLTSLM, " 
	cQuery +=        " NX8.NX8_VLLTLM, " 
	cQuery +=        " NX8.NX8_VLFXLM, " 
	cQuery +=        " NX8.NX8_VLFALM, " 
	cQuery +=        " NX8.NX8_VUTFAT, " 
	cQuery +=        " NX8.NX8_VSLDPX, " 
	cQuery +=        " CASE WHEN NXR.NXR_COTAC IS NULL THEN 1 ELSE NXR.NXR_COTAC END COTAC " 
	cQuery +=    " FROM " + RetSqlName("NX0") + " NX0 " 
	cQuery +=    " LEFT OUTER JOIN  " + RetSqlName("NXR") + " NXR ON (NXR.NXR_FILIAL = '" + xFilial("NXR") + "' AND NXR.NXR_CPREFT = NX0.NX0_COD  AND NXR_CMOEDA = NX0.NX0_CMOEDA AND NXR.D_E_L_E_T_ = ' ' ), " 
	cQuery +=                     " " + RetSqlName("CTO") + " CTO, " 
	cQuery +=                     " " + RetSqlName("NX8") + " NX8," 
	cQuery +=                     " " + RetSqlName("NRA") + " NRA " 
	cQuery +=   " WHERE NX0.NX0_FILIAL = '" + xFilial("NX0") + "' " 
	cQuery +=     " AND NX8.NX8_FILIAL = '" + xFilial("NX8") + "' " 
	cQuery +=     " AND CTO.CTO_FILIAL = '" + xFilial("CTO") + "' " 
	cQuery +=     " AND NRA.NRA_FILIAL = '" + xFilial("NRA") + "' " 
	cQuery +=     " AND NX0.NX0_COD    = NX8.NX8_CPREFT " 
	cQuery +=     " AND NX0.NX0_CMOEDA = CTO.CTO_MOEDA " 
	cQuery +=     " AND NRA.NRA_COD    = NX8.NX8_CTPHON " 
	cQuery +=     " AND NX0.NX0_COD    = '" + cPreft + "' " 
	cQuery +=     " AND NX0.D_E_L_E_T_ = ' ' " 
	cQuery +=     " AND NX8.D_E_L_E_T_ = ' ' " 
	cQuery +=     " AND CTO.D_E_L_E_T_ = ' ' " 
	cQuery +=     " AND NRA.D_E_L_E_T_ = ' ' " 
	cQuery += " )A " 
	cQuery += " GROUP BY A.NX0_COD, A.CTO_SIMB, A.COTAC, A.NX0_ACRESH, (A.NX0_ACRESH * A.COTAC) " 

	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cTmp, .T., .F. )

	If !(cTmp)->( EOF() )
		lTemLim  := ( (cTmp)->VLTSLM > 0 .Or. (cTmp)->VLLTLM > 0 .Or. (cTmp)->VLFXLM > 0 )
		lFaixa   := ((cTmp)->VFAIXA > 0)
		If lTemLim
			cSinalLanc := ""
		Else
			cSinalLanc := "+"
		EndIf
		cCTOSIMB  := AllTrim( (cTmp)->CTO_SIMB )
		cCotac    := AllTrim( Transform( (cTmp)->COTAC, X3Picture("NXR_COTAC") ) )
		cSimbMNac := AllTrim(JurGetDados("CTO", 1, xFilial("CTO") + cMoeNac, "CTO_SIMB") )

		If lFaixa
			aAdd( aValores, { cSinalLanc, "NX8_VFXFAT", AllTrim(RetTitle("NX8_VFXFAT"))  + " ("+ cCTOSIMB +"):" ,(cTmp)->VFAIXA   ,AllTrim(RetTitle("NX8_VFXFAT"))  + " ("+ cSimbMNac +" "+ cCotac +"):"  ,(cTmp)->VFAIXA_01,    .F. } )
			If ( (cTmp)->VTS > 0 )
				aAdd( aValores, { cSinalLanc, "NX8_VTS", AllTrim(RetTitle("NX8_VTS"))     + " ("+ cCTOSIMB +"):" ,(cTmp)->VTS     ,AllTrim(RetTitle("NX8_VTS"))  + " ("+ cSimbMNac +" "+ cCotac +"):"  ,(cTmp)->VTS_01,    .F. } )
			EndIf
			If ( (cTmp)->VFIXO > 0 )
				aAdd( aValores, { "+" , "NX8_VFIXO"    , AllTrim(RetTitle("NX8_VFIXO"))  + " ("+ cCTOSIMB +"):" ,(cTmp)->VFIXO   ,AllTrim(RetTitle("NX8_VFIXO"))  + " ("+ cSimbMNac +" "+ cCotac +"):"  ,(cTmp)->VFIXO_01,  .F. } )
			EndIf
		Else  //Situações onde não há contratos com faixa de faturamento. Demonstra excedente com o TS, se houver
			aAdd( aValores, { "+" , "NX8_VTS"   , AllTrim(RetTitle("NX8_VTS"))    + " ("+ cCTOSIMB +"):"  ,( (cTmp)->VEXCFX + (cTmp)->VTS + (cTmp)->VEXCHR ), AllTrim(RetTitle("NX8_VTS"))  + " ("+ cSimbMNac +" "+ cCotac +"):"  , ( (cTmp)->VEXCFX_01 + (cTmp)->VTS_01 + (cTmp)->VEXCHR_01 ),    .F. } )
			aAdd( aValores, { "+" , "NX8_VFIXO" , AllTrim(RetTitle("NX8_VFIXO"))  + " ("+ cCTOSIMB +"):"  ,(cTmp)->VFIXO   ,AllTrim(RetTitle("NX8_VFIXO"))  + " ("+ cSimbMNac +" "+ cCotac +"):"  ,(cTmp)->VFIXO_01,  .F. } )
		EndIf

		aAdd( aValores, { "+" , "NX0_ACRESH"   , AllTrim(RetTitle("NX0_ACRESH"))  + " ("+ cCTOSIMB +"):"  ,(cTmp)->ACRESH  ,AllTrim(RetTitle("NX0_ACRESH")) + " ("+ cSimbMNac +" "+ cCotac +"):"  ,(cTmp)->ACRESH_01, .F. } )
		aAdd( aValores, { " " , "NX8_VLDESC"   , AllTrim(RetTitle("NX8_VLDESC"))  + " ("+ cCTOSIMB +"):"  ,(cTmp)->VLDESC  ,AllTrim(RetTitle("NX8_VLDESC")) + " ("+ cSimbMNac +" "+ cCotac +"):"  ,(cTmp)->VLDESC_01, .F. } )
		aAdd( aValores, { " " , "NX8_VDESCO"   , AllTrim(RetTitle("NX8_VDESCO"))  + " ("+ cCTOSIMB +"):"  ,(cTmp)->VDESCO  ,AllTrim(RetTitle("NX8_VDESCO")) + " ("+ cSimbMNac +" "+ cCotac +"):"  ,(cTmp)->VDESCO_01, .F. } )
		aAdd( aValores, { "-" , "NX8_VDESCT"   , AllTrim(RetTitle("NX8_VDESCT"))  + " ("+ cCTOSIMB +"):"  ,(cTmp)->VDESCT  ,AllTrim(RetTitle("NX8_VDESCT")) + " ("+ cSimbMNac +" "+ cCotac +"):"  ,(cTmp)->VDESCT_01, .T. } )

		If ((cTmp)->VTSVIN != (cTmp)->VTS )  //Valor de Timesheet vinculado
			aAdd( aValores, { " " , "NX8_VTSVIN", AllTrim(RetTitle("NX8_VTSVIN")) + " ("+ cCTOSIMB +"):"   ,(cTmp)->VTSVIN  ,AllTrim(RetTitle("NX8_VTSVIN")) + " ("+ cSimbMNac +" "+ cCotac +"):"  ,(cTmp)->VTSVIN_01, .F. } )
		EndIf

		If NX8->(ColumnPos("NX8_VFXVIN")) > 0  .And. ((cTmp)->VFXVIN != (cTmp)->VFIXO ) //Proteção //Valor de Fixo Vinculado
			aAdd( aValores, { " " , "NX8_VFXVIN", AllTrim(RetTitle("NX8_VFXVIN")) + " ("+ cCTOSIMB +"):"   ,(cTmp)->VFXVIN  ,AllTrim(RetTitle("NX8_VFXVIN")) + " ("+ cSimbMNac +" "+ cCotac +"):"  ,(cTmp)->VFXVIN_01, .F. } )
		EndIf

		If lTSNCobra
			aAdd( aValores, { " " , "NX8_VTSNC", AllTrim(RetTitle("NX8_VTSNC")) + " ("+ cCTOSIMB +"):"   ,(cTmp)->VTSNC  ,AllTrim(RetTitle("NX8_VTSNC")) + " ("+ cSimbMNac +" "+ cCotac +"):"  ,(cTmp)->VTSNC_01, .F. } )
		EndIf

		If NX8->(ColumnPos("NX8_VTBVIN")) > 0  .And. ((cTmp)->VTBVIN != (cTmp)->VTAB ) //Proteção //Valor de Tabelado Vinculado
			aAdd( aValores, { " " , "NX8_VTBVIN", AllTrim(RetTitle("NX8_VTBVIN")) + " ("+ cCTOSIMB +"):"   ,(cTmp)->VTBVIN  ,AllTrim(RetTitle("NX8_VTBVIN")) + " ("+ cSimbMNac +" "+ cCotac +"):"  ,(cTmp)->VTBVIN_01, .F. } )
		EndIf

		If lTemLim .Or. ((cTmp)->VUTFAT > 0 ) //Valor Utilizado Faturas
			aAdd( aValores, { "+" , "NX8_VUTFAT", AllTrim(RetTitle("NX8_VUTFAT")) + " ("+ cCTOSIMB +"):"   ,(cTmp)->VUTFAT  ,AllTrim(RetTitle("NX8_VUTFAT")) + " ("+ cSimbMNac +" "+ cCotac +"):"  ,(cTmp)->VUTFAT_01, .F. } )
		EndIf
		If lTemLim .Or. ((cTmp)->VSLDPX > 0 ) //Valor Saldo Prox Faturas
			aAdd( aValores, { " " , "NX8_VSLDPX" , AllTrim(RetTitle("NX8_VSLDPX"))  + " ("+ cCTOSIMB +"):"   ,(cTmp)->VSLDPX  ,AllTrim(RetTitle("NX8_VSLDPX")) + " ("+ cSimbMNac +" "+ cCotac +"):"  ,(cTmp)->VSLDPX_01, .T. } )
		EndIf

		aAdd( aValores, { "+" , "NX8_VTAB"     , AllTrim(RetTitle("NX8_VTAB")) + " ("+ cCTOSIMB +"):"  ,(cTmp)->VTAB     ,AllTrim(RetTitle("NX8_VTAB")) + " ("+ cSimbMNac +" "+ cCotac +"):"	,(cTmp)->VTAB_01, .F. } )

		If lDespTrib
			If (cTmp)->VLTRIB > 0
				aAdd( aValores, { "" , "NX8_VLTRIB", AllTrim(JURX3INFO( "NX8_VLTRIB", "X3_TITULO" )) + " ("+ cCTOSIMB +"):"	,(cTmp)->VLTRIB		,AllTrim(JURX3INFO( "NX8_VLTRIB"  , "X3_TITULO" )) + " ("+ cSimbMNac +" "+ cCotac +"):"	,(cTmp)->VLTRIB_01, .F.	} )
			EndIf
			If	(cTmp)->VLREMB > 0
				aAdd( aValores, { "" , "NX8_VLREMB",AllTrim(JURX3INFO( "NX8_VLREMB" , "X3_TITULO" )) + " ("+ cCTOSIMB +"):"	,(cTmp)->VLREMB		,AllTrim(JURX3INFO( "NX8_VLREMB"  , "X3_TITULO" )) + " ("+ cSimbMNac +" "+ cCotac +"):"	,(cTmp)->VLREMB_01, .F.	} )
			EndIf
		EndIf
		aAdd( aValores, { "+" , "NX8_VDESP"    , AllTrim(RetTitle("NX8_VDESP")) + " ("+ cCTOSIMB +"):"  ,(cTmp)->VDESP    ,AllTrim(RetTitle("NX8_VDESP")) + " ("+ cSimbMNac +" "+ cCotac +"):"	,(cTmp)->VDESP_01, .T. } )

	EndIf

	(cTmp)->( dbCloseArea() )

	RestArea( aArea )

Return aValores

//-------------------------------------------------------------------
Function JA202RFilt()
Local lRet     := .T.
Local nCurrRec := oMarkUp:At()

	oMarkUp:DeleteFilter( __CUSERID)
	oMarkUp:Refresh()
	oMarkUp:GoTo( nCurrRec, .T. )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202DesmarcAll()
Função que desmarca tudo que foi marcado

@author Jorge Luis Branco Martins Junior
@since 04/05/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202DesmarcAll(oView, oModel)
Local lRet := .T.

Local oModelNX8, oModelNT1, oModelNX1, oModelNX2
Local oModelNUE, oModelNVY, oModelNV4

Local nLineNX8, nLineNT1, nLineNX1, nLineNX2
Local nLineNUE, nLineNVY, nLineNV4

Local nQtdNX8, nQtdNT1, nQtdNX1, nQtdNX2
Local nQtdNUE, nQtdNVY, nQtdNV4

Local cCpoMrkNX8 := "NX8_TKRET"
Local cCpoMrkNT1 := "NT1_TKRET"
Local cCpoMrkNX1 := "NX1_TKRET"
Local cCpoMrkNX2 := "NX2_TKRET"
Local cCpoMrkNUE := "NUE_TKRET"
Local cCpoMrkNVY := "NVY_TKRET"
Local cCpoMrkNV4 := "NV4_TKRET"

Local nINX8 := 0
Local nINT1 := 0
Local nINX1 := 0
Local nINX2 := 0
Local nINUE := 0
Local nINVY := 0
Local nINV4 := 0

Default oView  := Nil
Default oModel := FWModelActive()

	oModelNX8 := oModel:GetModel( 'NX8DETAIL' )
	oModelNT1 := oModel:GetModel( 'NT1DETAIL' )
	oModelNX1 := oModel:GetModel( 'NX1DETAIL' )
	oModelNX2 := oModel:GetModel( 'NX2DETAIL' )
	oModelNUE := oModel:GetModel( 'NUEDETAIL' )
	oModelNVY := oModel:GetModel( 'NVYDETAIL' )
	oModelNV4 := oModel:GetModel( 'NV4DETAIL' )

	nLineNX8 := oModelNX8:GetLine()
	nQtdNX8  := oModelNX8:GetQtdLine()
	For nINX8 := 1 To nQtdNX8
		oModelNX8:GoLine(nINX8)

		If lRet .And. oModelNX8:GetValue(cCpoMrkNX8)
			oModelNX8:SetValue(cCpoMrkNX8, .F.)
		EndIf

		nLineNT1 := oModelNT1:GetLine()
		nQtdNT1  := oModelNT1:GetQtdLine()
		For nINT1 := 1 To nQtdNT1
			oModelNT1:GoLine(nINT1)

			If lRet .And. oModelNT1:GetValue(cCpoMrkNT1)
				oModelNT1:SetValue(cCpoMrkNT1, .F.)
			EndIf

			nLineNX1 := oModelNX1:GetLine()
			nQtdNX1  := oModelNX1:GetQtdLine()
			For nINX1 := 1 To nQtdNX1
				oModelNX1:GoLine(nINX1)

				If lRet .And. oModelNX1:GetValue(cCpoMrkNX1)
					oModelNX1:SetValue(cCpoMrkNX1, .F.)
				EndIf

				nLineNX2 := oModelNX2:GetLine()
				nQtdNX2  := oModelNX2:GetQtdLine()
				For nINX2 := 1 To nQtdNX2
					oModelNX2:GoLine(nINX2)

					If lRet .And. oModelNX2:GetValue(cCpoMrkNX2)
						oModelNX2:SetValue(cCpoMrkNX2, .F.)
					EndIf

					nLineNUE := oModelNUE:GetLine()
					nQtdNUE  := oModelNUE:GetQtdLine()
					For nINUE := 1 To nQtdNUE
						oModelNUE:GoLine(nINUE)

						If lRet .And. oModelNUE:GetValue(cCpoMrkNUE)
							oModelNUE:SetValue(cCpoMrkNUE, .F.)
						EndIf

				 	Next nINUE
					oModelNUE:GoLine(nLineNUE)

					nLineNVY := oModelNVY:GetLine()
					nQtdNVY  := oModelNVY:GetQtdLine()
					For nINVY := 1 To nQtdNVY
						oModelNVY:GoLine(nINVY)

						If lRet .And. oModelNVY:GetValue(cCpoMrkNVY)
							oModelNVY:SetValue(cCpoMrkNVY, .F.)
						EndIf

					Next nINVY
					oModelNVY:GoLine(nLineNVY)

					nLineNV4 := oModelNV4:GetLine()
					nQtdNV4  := oModelNV4:GetQtdLine()
					For nINV4 := 1 To nQtdNV4
						oModelNV4:GoLine(nINV4)

						If lRet .And. oModelNV4:GetValue(cCpoMrkNV4)
							oModelNV4:SetValue(cCpoMrkNV4, .F.)
						EndIf

		 	 		Next nINV4
					oModelNV4:GoLine(nLineNV4)

		 		Next nINX2
				oModelNX2:GoLine(nLineNX2)
	 		Next nINX1
			oModelNX1:GoLine(nLineNX1)
 		Next nINT1
		oModelNT1:GoLine(nLineNT1)
	Next nINX8
	oModelNX8:GoLine(nLineNX8)

	If !Empty(oView)
		oView:Refresh()
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202AltC()
Função para verificar se o valor da cotação alterada pelo usuário é
diferente do valor da cotação do dia. Se a cotação for dirente, grava
"1" no campo "NXR_ALTCOT", caso contrario grava "2".

@Return .T.

@author Luciano Pereira dos Santos
@since 03/05/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function J202AltC()
	Local lRet      := .T.
	Local cMoedaPre := ""
	Local cMoedaCot := ""
	Local aCotac    := {}
	Local aSaveLn   := {}
	Local aArea     := GetArea()
	Local oModel    := Nil
	Local oModelNX0 := Nil
	Local oModelNXR := Nil
	Local dDtEmiss  := CToD( '  /  /  ' )

	If IsJura202()

		oModel    := FwModelActive()
		aSaveLn   := FwSaveRows()
		oModelNX0 := oModel:GetModel('NX0MASTER')
		oModelNXR := oModel:GetModel('NXRDETAIL')
		cMoedaPre := oModelNX0:GetValue('NX0_CMOEDA')
		cMoedaCot := oModelNXR:GetValue('NXR_CMOEDA')

		dDtEmiss  := JURA203G( 'FT', Date(), 'FATEMI' )[1]

		aCotac    := JA201FConv(cMoedaPre, cMoedaCot, 1000, '1', dDtEmiss)

		If oModelNXR:IsFieldUpdated("NXR_COTAC")
			oModelNXR:SetValue('NXR_ALTCOT', '1') // Usuário
		Else
			oModelNXR:SetValue('NXR_ALTCOT', '2') // Não Alterada
		EndIf

		FwRestRows(aSaveLn)

	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202REbil()
Verificação para Clientes Ebilling

@author Jorge Luis Branco Martins Junior
@since 04/06/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202REbil(cTSCod, cFase, cTarefa, cAtivi, oModelNUE)
Local aArea := GetArea()
Local lRet  := .F.

	If J202LoadVl(oModelNUE, "NUE_CFASE", cFase  )
		If J202LoadVl(oModelNUE, "NUE_CTAREF", cTarefa)
			If J202LoadVl(oModelNUE, "NUE_CTAREB", cAtivi )
				lRet := .T.
			EndIf
		EndIf
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}  JA202TotPre()
Varre os registros da pré para totalizar os valores após alterações

@Return lRet - Se totalizou corretamente .T.

@author David Fernandes
@since 24/05/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202TotPre( cCampo )
Local lRet      := .T.
Local oModel    := If(oModelOld = Nil, FwModelActive(), oModelOld)
Local oModelNX0 := oModel:GetModel("NX0MASTER")
Local oModelNX8 := oModel:GetModel("NX8DETAIL")
Local oModelNX1 := oModel:GetModel("NX1DETAIL")
Local oModelNT1 := oModel:GetModel("NT1DETAIL")
Local oModelNX2 := oModel:GetModel("NX2DETAIL")
Local oModelNUE := oModel:GetModel("NUEDETAIL")
Local oModelNVY := oModel:GetModel("NVYDETAIL")
Local oModelNV4 := oModel:GetModel("NV4DETAIL")

Local aSaveLn   := FwSaveRows( oModel )

Local nVlFXPre  := 0
Local nVlTSPre  := 0
Local nVlDPPre  := 0
Local nVlTBPre  := 0
Local nVlTSCon  := 0
Local nVlTSVinCn:= 0
Local nVlDPCon  := 0
Local nVlTBCon  := 0
Local nVlFXCon  := 0
Local nVlTSCas  := 0
Local nVlTSVinCs:= 0
Local nVlDPCas  := 0
Local nVlTBCas  := 0
Local nVDescCas := 0
Local nVDescTot := 0
Local nVDescCon := 0
Local nVDescPre := 0
Local nVDesECas := 0
Local nPDesECas := 0
Local nVDesECon := 0
Local nVDesEPre := 0

Local nINX8     := 0
Local nINX1     := 0
Local nINX2     := 0
Local nINUE     := 0
Local nINVY     := 0
Local nINV4     := 0
Local nINT1     := 0
Local npos      := 0
Local aPartCas  := {}
Local aPosOK    := {}
Local nPosPart  := 0
Local nUTRev    := 0
Local nHrFracRev:= 0
Local nUTLanc   := 0
Local nHrFracL  := 0
Local nUTCli    := 0
Local nHrFracCli:= 0
Local nIPart    := 0
Local lBlock    := .F.
Local nCodSeq   := 0
Local cIdioma   := ""
Local cTpHon    := ""
Local cCobH     := ""
Local nVlTSFatu := 0
Local nPAcres   := 0
Local nVAcres   := 0
Local nQtdNX8	:= 0
Local nQtdNT1	:= 0
Local nQtdNX1	:= 0
Local nQtdNUE	:= 0
Local nQtdNX2	:= 0
Local nQtdNVY	:= 0
Local nQtdNV4	:= 0

Local cX2Part
Local cX2Categ
Local nX2Valor
Local cX2ClTab
Local cX2CMOTBH

Local cNUECOD
Local cNUESITUAC
Local cNX0COD   := oModelNX0:GetValue("NX0_COD")

Local cNUEcPART2
Local cNUEcCateg
Local nNUEVALORH
Local cNUECLTAB
Local cNUECMOEDA
Local nNUEVALOR
Local nNUEVALOR1
Local nTAMNX2CODSEQ := TamSX3('NX2_CODSEQ')[1]
Local cNVYCOD
Local cNVYSITUAC
Local cNV4COD
Local cNV4SITUAC
Local nLNNX8
Local nLNNX1
Local nLNNX2
Local nLNNT1
Local nPosOK    := 0
Local nVlFaixa  := 0

Local nTScaso   := 0
Local nLTcaso   := 0
Local nDPcaso   := 0
Local nTSContr  := 0
Local nDPContr  := 0
Local nTBContr  := 0
Local nTSPre    := 0
Local nDPPre    := 0
Local nTBPre    := 0

Local nDecNX2UTR := 0
Local nDecNX2TpR := 0
Local nDecNX2UTL := 0
Local nDecNX2HFL := 0
Local nDecNX2UTC := 0
Local nDecNX2HFC := 0
Local nDecNX2VTH := 0
Local nDecNX2Vl1 := 0

	nLNNX8  := oModelNX8:GetLine()
	nQtdNX8 := oModelNX8:GetQtdLine()

	For nINX8 := 1 To nQtdNX8
		oModelNX8:GoLine( nINX8 )

		nVlTSCon	:= 0
		nVlDPCon	:= 0
		nVlTBCon	:= 0
		nVlFXCon	:= 0
		nVDescCon	:= 0
		nVDesECon	:= 0

		nTSContr	:= 0
		nDPContr	:= 0
		nTBContr	:= 0

		cTpHon	    := JurGetDados("NT0", 1, xFilial("NT0") + oModelNX8:GetValue("NX8_CCONTR"), "NT0_CTPHON")
		cCobH	    := JurGetDados("NRA", 1, xFilial("NRA") + cTpHon, "NRA_COBRAH")

		nLNNT1 := oModelNT1:GetLine()
		nQtdNT1 := oModelNT1:GetQtdLine()
		For nINT1 := 1 To nQtdNT1

			If !(lAcumula .And. oModelNT1:GetValue("NT1_TKRET", nINT1) )

				If oModelNT1:GetValue('NT1_VALORA', nINT1) == 0
					nVlFXCon += oModelNT1:GetValue('NT1_VALORA', nINT1)
				Else
					nVlFXCon += oModelNT1:GetValue('NT1_VALORB', nINT1)
				EndIf
			EndIf

		Next nINT1
		oModelNT1:GoLine(nLNNT1)

		nLNNX1 := oModelNX1:GetLine()
		nQtdNX1 := oModelNX1:GetQtdLine()
		For nINX1 := 1 To nQtdNX1
			oModelNX1:GoLine( nINX1 )

			nVlTSCas  := 0
			nVlDPCas  := 0
			nVlTBCas  := 0
			nVDescCas := 0
			nVDesECas := 0
			nTScaso   := 0
			nLTcaso   := 0
			nDPcaso   := 0
			nVlTSVinCs:= 0

			aPartCas	:= {}
			aPosOK		:= {}


				nQtdNUE := oModelNUE:GetQtdLine()

				For nINUE := 1 To nQtdNUE

					cNUECOD    := oModelNUE:GetValuebyPos(__aNUEPosFields[POS_NUE_COD], nINUE)
					cNUESITUAC := oModelNUE:GetValuebyPos(__aNUEPosFields[POS_NUE_SITUAC], nINUE)


					npos := ascan( aRmvLanc, {|ax|  ax[1] == 	"NUE" .And.;
												ax[2] == 	xFilial("NVE") +;
															cNUECOD+;
															cNUESITUAC +;
															 cNX0COD})

					If ( nPos == 0 .And. !(lAcumula .And. oModelNUE:GetValue("NUE_TKRET", nINUE) ) ) .And. !Empty( oModelNUE:GetValuebyPos(__aNUEPosFields[POS_NUE_CPREFT], nINUE) ) //Se não for retirado, totaliza no caso.

						If J202TEMPOZ(oModelNUE:GetValuebyPos(__aNUEPosFields[POS_NUE_CATIVI], nINUE)) .And. oModelNUE:GetValue("NUE_COBRAR", nINUE) == "1"
							nVlTSCas  := nVlTSCas + oModelNUE:GetValuebyPos(__aNUEPosFields[POS_NUE_VALOR1], nINUE)
						EndIf
				 		nVlTSVinCs  := nVlTSVinCs + oModelNUE:GetValuebyPos(__aNUEPosFields[POS_NUE_VALOR1], nINUE)

				 		//Verifica se a atividade possui participação do cliente para acumular as horas alteráveis
						If !(JA202TEMPO(.F., oModelNUE:GetValuebyPos(__aNUEPosFields[POS_NUE_CATIVI], nINUE) ))
							nUTRev      := 0
							nHrFracRev  := 0
							nUTLanc     := 0
							nHrFracL    := 0
							nUTCli      := oModelNUE:GetValuebyPos(__aNUEPosFields[POS_NUE_UTR], nINUE)
							nHrFracCli  := oModelNUE:GetValuebyPos(__aNUEPosFields[POS_NUE_TEMPOR], nINUE)
						Else
							nUTLanc     := oModelNUE:GetValuebyPos(__aNUEPosFields[POS_NUE_UTL], nINUE)
							nHrFracL    := oModelNUE:GetValuebyPos(__aNUEPosFields[POS_NUE_TEMPOL], nINUE)
							nUTRev      := oModelNUE:GetValuebyPos(__aNUEPosFields[POS_NUE_UTR], nINUE)
							nHrFracRev  := oModelNUE:GetValuebyPos(__aNUEPosFields[POS_NUE_TEMPOR], nINUE)
							nUTCli      := 0
							nHrFracCli  := 0
						EndIf

					nCodSeq := 1
					cNUEcPART2 := Alltrim(oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CPART2], nINUE))
					For nIPart := 1 To Len(aPartCas)
						If aPartCas[nIPart][1] == cNUEcPART2
							nCodSeq := nCodSeq + 1
						EndIf
					Next nIPart

					cNUEcCateg := Alltrim(oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CCATEG], nINUE))
					nNUEVALORH := oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALORH], nINUE)
					cNUECLTAB  := Alltrim(oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CLTAB], nINUE))
					cNUECMOEDA := Alltrim(oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CMOEDA], nINUE))

					nPosPart := aScan( aPartCas , 	{  |x|  	Alltrim(x[ 1]) == cNUEcPART2	.And. ;
																Alltrim(x[ 2]) == cNUEcCateg  	.And. ;
																		x[ 3]  == nNUEVALORH   	.And. ;
																Alltrim(x[ 4]) == cNUECLTAB  	.And. ;
																Alltrim(x[ 5]) == cNUECMOEDA 	 ;
													};
					)
					nNUEVALOR  := oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALOR], nINUE)
					nNUEVALOR1 := oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALOR1], nINUE)

					If nPosPart > 0
						aPartCas[ nPosPart ][  6 ] := aPartCas[ nPosPart ][  6 ] + nUTRev
						aPartCas[ nPosPart ][  7 ] := aPartCas[ nPosPart ][  7 ] + nHrFracRev
						aPartCas[ nPosPart ][  8 ] := aPartCas[ nPosPart ][  8 ] + nUTLanc
						aPartCas[ nPosPart ][  9 ] := aPartCas[ nPosPart ][  9 ] + nHrFracL
						aPartCas[ nPosPart ][ 10 ] := aPartCas[ nPosPart ][ 10 ] + nUTCli
						aPartCas[ nPosPart ][ 11 ] := aPartCas[ nPosPart ][ 11 ] + nHrFracCli
						aPartCas[ nPosPart ][ 12 ] := aPartCas[ nPosPart ][ 12 ] + nNUEVALOR
						aPartCas[ nPosPart ][ 13 ] := aPartCas[ nPosPart ][ 13 ] + nNUEVALOR1
					ElseIf !Empty(cNUECMOEDA) //Não Insere registro para timeSheet de part. com tabela de hon. sem taabela de honorários.
						aAdd( aPartCas ,  	{	cNUEcPART2	,;
												cNUEcCateg	,;
												nNUEVALORH 	,;
												cNUECLTAB  	,;
												cNUECMOEDA  	,;
												nUTRev						 		,;
												nHrFracRev						 	,;
												nUTLanc						 		,;
												nHrFracL							,;
												nUTCli								,;
												nHrFracCli							,;
												nNUEVALOR						 	,;
												nNUEVALOR1 	,;
												PADL(AllTrim(Str(nCodSeq)), nTAMNX2CODSEQ , '0') 				;
											} ;
							)
					EndIf
					nTScaso++
				EndIf
			Next nINUE

			// Localiza o Participante no resumo e acrescenta o valor
				nQtdNX2 := oModelNX2:GetQtdLine()

				nDecNX2UTR := TamSX3("NX2_UTR")[2]
				nDecNX2TpR := TamSX3("NX2_TEMPOR")[2]
				nDecNX2UTL := TamSX3("NX2_UTLANC")[2]
				nDecNX2HFL := TamSX3("NX2_HFLANC")[2]
				nDecNX2UTC := TamSX3("NX2_UTCLI")[2]
				nDecNX2HFC := TamSX3("NX2_HFCLI")[2]
				nDecNX2VTH := TamSX3("NX2_VLHTBH")[2]
				nDecNX2Vl1 := TamSX3("NX2_VALOR1")[2]

				For nINX2 := 1 To nQtdNX2
					cX2Part    := Alltrim(oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_CPART], nINX2 ) ) //POS_NX2_CPART
					cX2Categ   := Alltrim(oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_CCATEG], nINX2 ))
					nX2Valor   := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_VALORH], nINX2 )
					cX2ClTab   := Alltrim(oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_CLTAB], nINX2 ))
					cX2CMOTBH  := Alltrim(oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_CMOTBH], nINX2 ))

				nPosPart := aScan( aPartCas , 	{  |x|  	Alltrim(x[ 1]) == cX2Part	.And. ;
															Alltrim(x[ 2]) == cX2Categ	.And. ;
																	x[ 3]  == nX2Valor 	.And. ;
															Alltrim(x[ 4]) == cX2ClTab  .And. ;
															Alltrim(x[ 5]) == cX2CMOTBH	 ;
												};
									)
				nPosOK := aScan( aPosOK, { |x| x == nPosPart } )

				If nPosPart > 0 .And. nPosOK == 0 .And. !Empty(cX2CMOTBH)

					oModelNX2:GoLine( nINX2 )

					If oModelNX2:IsDeleted()
						oModelNX2:UnDeleteLine()
					EndIf

					lShowTela := "NX2" == cInstanc

					lRet := lRet .And. __JurLoadValue( oModelNX2, __aNX2PosFields[POS_NX2_UTR]   , Round( aPartCas[nPosPart][ 6], nDecNX2UTR ), lShowTela)
					lRet := lRet .And. __JurLoadValue( oModelNX2, __aNX2PosFields[POS_NX2_TEMPOR], Round( aPartCas[nPosPart][ 7], nDecNX2TpR ), lShowTela )
					lRet := lRet .And. __JurLoadValue( oModelNX2, __aNX2PosFields[POS_NX2_HORAR] , PADL(JURA144C1(2, 3, cValtoChar(oModelNX2:GetValue("NX2_TEMPOR"))), TamSX3('NX2_HORAR')[1], '0') ) //0000:00 )
					lRet := lRet .And. __JurLoadValue( oModelNX2, __aNX2PosFields[POS_NX2_UTLANC], Round( aPartCas[nPosPart][ 8], nDecNX2UTL ), lShowTela )
					lRet := lRet .And. __JurLoadValue( oModelNX2, __aNX2PosFields[POS_NX2_HFLANC], Round( aPartCas[nPosPart][ 9], nDecNX2HFL ), lShowTela)
					lRet := lRet .And. __JurLoadValue( oModelNX2, __aNX2PosFields[POS_NX2_HRLANC], PADL(JURA144C1(2, 3, Str(oModelNX2:GetValue("NX2_HFLANC"))), TamSX3('NX2_HRLANC')[1], '0') ) // 0000:00
					lRet := lRet .And. __JurLoadValue( oModelNX2, __aNX2PosFields[POS_NX2_UTCLI] , Round( aPartCas[nPosPart][ 10], nDecNX2UTC ), lShowTela)
					lRet := lRet .And. __JurLoadValue( oModelNX2, __aNX2PosFields[POS_NX2_HFCLI] , Round( aPartCas[nPosPart][ 11], nDecNX2HFC ), lShowTela)
					lRet := lRet .And. __JurLoadValue( oModelNX2, __aNX2PosFields[POS_NX2_HRCLI] , PADL(JURA144C1(2, 3, Str(oModelNX2:GetValue("NX2_HFCLI"))), TamSX3('NX2_HRCLI')[1], '0') ) // 0000:00
					lRet := lRet .And. __JurLoadValue( oModelNX2, __aNX2PosFields[POS_NX2_VLHTBH], Round( aPartCas[nPosPart][ 12], nDecNX2VTH ), lShowTela)
					lRet := lRet .And. __JurLoadValue( oModelNX2, __aNX2PosFields[POS_NX2_VALOR1], Round( aPartCas[nPosPart][ 13], nDecNX2Vl1 ), lShowTela )

					aPartCas[nPosPart][ 14] := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_CODSEQ])

					aAdd( aPosOK, nPosPart)
				Else

					If !oModelNX2:IsEmpty()
						oModelNX2:GoLine( nINX2 )
						oModelNX2:SetNoDeleteLine(.F.)
						oModelNX2:DeleteLine()
						oModelNX2:SetNoDeleteLine(.T.)
					EndIf

					nIPart := nPosPart + 1

					While (nIPart > 0) .And. (nIPart <= Len(aPartCas) )

						If  aPartCas[nIPart][1] == cX2Part .And. ;
							aPartCas[nIPart][2] == cX2Categ .And. ;
							aPartCas[nIPart][3] == nX2Valor .And. ;
							aPartCas[nIPart][4] == cX2ClTab .And. ;
							aPartCas[nIPart][5] == cX2CMOTBH

							aPartCas := JaRemPos(aPartCas, nIPart)
						Else
							nIPart += 1
						EndIf

					EndDo

				EndIf

			Next nINX2
			oModelNX2:GoLine(nLNNX2)

			For nIPart := 1 To Len(aPartCas)
				nPosPart := aScan( aPosOK , { |x|  x == nIPart } )

				If ( nPosPart  == 0 )
					If !oModelNX2:CanInsertLine()
						oModelNX2:SetNoInsertLine(.F.)
						lBlock := .T.
					EndIf

					oModelNX2:AddLine()

					aPartCas[nIPart][14] := J202SEQPar(aPartCas[nIPart], oModelNX2)

					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_FILIAL"	,	,		xFilial("NX2")	)
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_CPREFT"	,	,		cNX0COD )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_CCLIEN"	,	,		oModelNX1:GetValueByPos( __aNX1PosFields[POS_NX1_CCLIEN]) )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_CLOJA"	,	,		oModelNX1:GetValueByPos( __aNX1PosFields[POS_NX1_CLOJA]) )

					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_DCLIEN"	,	,		oModelNX1:GetValueByPos( __aNX1PosFields[POS_NX1_DCLIEN]) )

					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_CCONTR"	,	,		oModelNX1:GetValueByPos( __aNX1PosFields[POS_NX1_CCONTR]) )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_DCONTR"	,	,		oModelNX1:GetValueByPos( __aNX1PosFields[POS_NX1_DCONTR]) )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_CCASO"	,	,		oModelNX1:GetValueByPos( __aNX1PosFields[POS_NX1_CCASO]) )

					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_DCASO"	,	,		oModelNX1:GetValueByPos( __aNX1PosFields[POS_NX1_DCASO]) )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_CMOPRE"	,	,		oModelNX0:GetValueByPos(__aNX0PosFields[POS_NX0_CMOEDA]) )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_DMOPRE"	,	,		oModelNX0:GetValueByPos(__aNX0PosFields[POS_NX0_DMOEDA]) )

					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_CPART"	,	,		aPartCas[nIPart][1] )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_CCATEG"	,	,		aPartCas[nIPart][2] )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_VALORH"	,	,		aPartCas[nIPart][3] )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_CLTAB"	,	,		aPartCas[nIPart][4] )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_CMOTBH"	,	,		aPartCas[nIPart][5] )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_CODSEQ"	,	,		aPartCas[nIPart][14])

					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_SIGLA"	,	, JA202DPART('1', oModelNX2:GetValueByPos( __aNX2PosFields[POS_NX2_CPART])) )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_DPART"	,	, JA202DPART('2', oModelNX2:GetValueByPos( __aNX2PosFields[POS_NX2_CPART])) )

					cIdioma := JurGetDados("NT0",1,  xFilial("NT0") + oModelNX1:GetValueByPos( __aNX1PosFields[POS_NX1_CCONTR]) , "NT0_CIDIO" )

					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_DCATEG"	,	, JurGetDados("NR2",3, xFilial("NR2") + oModelNX2:GetValueByPos( __aNX2PosFields[POS_NX2_CCATEG]) + cIdioma, "NR2_DESC" ) )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_DMOTBH"	,	, JA202DMOED(oModelNX2:GetValueByPos( __aNX2PosFields[POS_NX2_CMOTBH])) )

					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_UTR"		,	, Round( aPartCas[nIPart][ 6], nDecNX2UTR ) )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_TEMPOR"	,	, Round( aPartCas[nIPart][ 7], nDecNX2TpR ) )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_HORAR"	,	, PADL(JURA144C1(2, 3, cValtoChar(oModelNX2:GetValue("NX2_TEMPOR"))), tamSX3('NX2_HORAR')[1], '0')) //0000:00
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_UTLANC"	,	, Round( aPartCas[nIPart][ 8], nDecNX2UTL ) )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_HFLANC"	,	, Round( aPartCas[nIPart][ 9], nDecNX2HFL ) )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_HRLANC"	,	, PADL(JURA144C1(2, 3, Str(oModelNX2:GetValue("NX2_HFLANC"))), TamSX3('NX2_HRLANC')[1], '0') ) // 0000:00
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_UTCLI"	,	, Round( aPartCas[nIPart][10], nDecNX2UTC ) )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_HFCLI"	,	, Round( aPartCas[nIPart][11], nDecNX2HFC ) )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_HRCLI"	,	, PADL(JURA144C1(2, 3, Str(oModelNX2:GetValue("NX2_HFCLI"))), TamSX3('NX2_HRCLI')[1], '0') ) // 0000:00

					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_VLHTBH"	,	, Round( aPartCas[nIPart][12], nDecNX2VTH ) )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_VALOR1"	,	, Round( aPartCas[nIPart][13], nDecNX2Vl1 ) )

					If lBlock
						oModelNX2:SetNoInsertLine(.T.)
						lBlock := .F.
					EndIf
				EndIf

			Next nIPart

			nQtdNVY := oModelNVY:GetQtdLine()
			For nINVY := 1 To nQtdNVY
				cNVYCOD := oModelNVY:GetValue("NVY_COD", nINVY )
				cNVYSITUAC := oModelNVY:GetValue("NVY_SITUAC", nINVY )

				npos := aScan( aRmvLanc, {|ax| ax[1] == "NVY" .And.;
	                                               ax[2] == xFilial("NVY") + cNVYCOD + cNVYSITUAC + cNX0COD })

				If ( nPos == 0 .And. !(lAcumula .And. oModelNVY:GetValue("NVY_TKRET", nINVY ) ) ) .And. !Empty( oModelNVY:GetValue( "NVY_CPREFT", nINVY ) ) //Se não foi retirado, totaliza no caso
					nVlDPCas := nVlDPCas + oModelNVY:GetValue( "NVY_VALOR", nINVY ) * ( oModelNVY:GetValue( "NVY_COTAC1", nINVY ) / oModelNVY:GetValue( "NVY_COTAC2", nINVY ) )
					nDPcaso++
				EndIf

			Next nINVY

			nQtdNV4 := oModelNV4:GetQtdLine()
			For nINV4 := 1 To nQtdNV4

				cNV4COD    := oModelNV4:GetValue("NV4_COD", nINV4 )
				cNV4SITUAC := oModelNV4:GetValue("NV4_SITUAC", nINV4 )

				npos := aScan( aRmvLanc, {|ax| ax[1] == "NV4" .And.;
	                                                ax[2] == xFilial("NV4") + cNV4COD + cNV4SITUAC + cNX0COD })

				If( nPos == 0 .And. !(lAcumula .And. oModelNV4:GetValue("NV4_TKRET", nINV4 ) ) ) .And. !Empty( oModelNV4:GetValue( "NV4_CPREFT" , nINV4 ) )//Se não foi retirado, totaliza no caso
					nVlTBCas := nVlTBCas + oModelNV4:GetValue( "NV4_VLHFAT", nINV4 ) * ( oModelNV4:GetValue( "NV4_COTAC1", nINV4 ) / oModelNV4:GetValue( "NV4_COTAC2", nINV4 ) )
					nLTcaso++
				EndIf
			Next nINV4

			If cCobH == "1" //Apenas se o tipo de honorários do contrato cobra hora
				lRet := lRet .And. JurloadValue( oModelNX1 , "NX1_VTS",		, Round( nVlTSCas, TamSX3("NX1_VTS")[2] ) )
			EndIf

			If NX1->(FieldPos('NX1_VTSVIN')) > 0
				lRet := lRet .And. JurloadValue( oModelNX1 , "NX1_VTSVIN" ,Nil, Round( nVlTSVinCs, TamSX3("NX1_VTSVIN")[2] ) )
			EndIf

			lRet := lRet .And. JurloadValue( oModelNX1 , "NX1_VDESP" , Nil, Round( nVlDPCas, TamSX3("NX1_VDESP")[2] ) )
			lRet := lRet .And. JurloadValue( oModelNX1 , "NX1_VTAB"  , Nil, Round( nVlTBCas, TamSX3("NX1_VTAB")[2] ) )

			lRet := lRet .And. JurloadValue( oModelNX1 , "NX1_TS"    , Nil, Iif(nVlTSCas == 0 .And. nTScaso == 0, "2", "1") )
			lRet := lRet .And. JurloadValue( oModelNX1 , "NX1_DESP"  , Nil, Iif(nVlDPCas == 0 .And. nDPcaso == 0, "2", "1") )
			lRet := lRet .And. JurloadValue( oModelNX1 , "NX1_LANTAB", Nil, Iif(nVlTBCas == 0 .And. nLTcaso == 0, "2", "1") )

			nVDescCas := Round( (oModelNX1:GetValue( "NX1_PDESCH") * oModelNX1:GetValue("NX1_VTS")) / 100, TamSX3("NX1_VDESCO")[2] )
			lRet := lRet .And. JurloadValue( oModelNX1 , "NX1_VDESCO",	, nVDescCas ) //Desconto Linear
			
			If lRet
				If oModelNX0:GetValue( "NX0_TPDESC") == "1"
					If lTelaRat
						nPDesECas := oModelNX0:GetValue("NX0_PDESCH")
						nVDesECas := Round( (nPDesECas * (oModelNX1:GetValue("NX1_VTS") + oModelNX1:GetValue("NX1_VFIXO") - oModelNX1:GetValue("NX1_VDESCO"))) / 100, TamSX3("NX1_VLDESC")[2] )
					Else
						nVDesECas := oModelNX1:GetValue("NX1_VLDESC")
						nPDesECas := Round( (nVDesECas / (oModelNX1:GetValue("NX1_VTS") + oModelNX1:GetValue("NX1_VFIXO") - oModelNX1:GetValue("NX1_VDESCO"))) * 100, TamSX3("NX1_PCDESC")[2] )
						lRet := lRet .And. JurloadValue( oModelNX1 , "NX1_PCDESC",	, nPDesECas )
					EndIf
				Else
					If lTelaRat
						nPDesECas := oModelNX0:GetValue("NX0_PDESCH")
						nVDesECas := Round( ((nPDesECas * (oModelNX1:GetValue("NX1_VTS") + oModelNX1:GetValue("NX1_VFIXO") - oModelNX1:GetValue("NX1_VDESCO"))) / 100) , TamSX3("NX1_VLDESC")[2] )
					Else
						nPDesECas := oModelNX1:GetValue("NX1_PCDESC")
						nVDesECas := Round( ((nPDesECas * (oModelNX1:GetValue("NX1_VTS") + oModelNX1:GetValue("NX1_VFIXO") - oModelNX1:GetValue("NX1_VDESCO"))) / 100) , TamSX3("NX1_VLDESC")[2] )
						lRet := lRet .And. JurloadValue( oModelNX1 , "NX1_VLDESC",	, nVDesECas ) //Desconto Especial
					EndIf
				EndIf
			EndIf

			nVDescTot := Round( oModelNX1:GetValue("NX1_VDESCO") + nVDesECas, TamSX3("NX1_VDESCT")[2] )
			If !lTelaRat
				lRet := lRet .And. JurloadValue( oModelNX1 , "NX1_VDESCT",	, nVDescTot ) //Desconto Total
			EndIf

			nVDescCon	:= nVDescCon + nVDescCas // Valor do desconto Linear
			nVDesECon	:= nVDesECon + nVDesECas // Valor do desconto Especial
			nVlTSCon	:= nVlTSCon + nVlTSCas
			nVlTSVinCn  := nVlTSVinCn + nVlTSVinCs
			nVlDPCon	:= nVlDPCon + nVlDPCas
			nVlTBCon	:= nVlTBCon + nVlTBCas
			nVlFaixa    += oModelNX8:GetValue("NX8_VFXFAT") //Para guardar o valor de faixa dos contratos e mantê-lo. Para fazer o recálculo será necessário o Refazer

			Iif(nTScaso > 0, nTSContr++, )
			Iif(nDPcaso > 0, nDPContr++, )
			Iif(nLTcaso > 0, nTBContr++, )

		Next nINX1
		oModelNX1:GoLine(nLNNX1)

		If cCobH == "1" //Apenas se o tipo de honorários do contrato cobra hora
			lRet := lRet .And. JurloadValue( oModelNX8 , "NX8_VTS",		, Round( nVlTSCon, TamSX3("NX8_VTS")[2] ) )
		EndIf

		lRet := lRet .And. JurloadValue( oModelNX8 , "NX8_VTSVIN",		, Round( nVlTSVinCn, TamSX3("NX8_VTSVIN")[2] ) )

		lRet := lRet .And. JurloadValue( oModelNX8 , "NX8_VDESP",	, Round( nVlDPCon, TamSX3("NX8_VDESP")[2] ) )
		lRet := lRet .And. JurloadValue( oModelNX8 , "NX8_VTAB",	, Round( nVlTBCon, TamSX3("NX8_VTAB")[2] ) )
		lRet := lRet .And. JurloadValue( oModelNX8 , "NX8_VDESCO",	, Round( nVDescCon, TamSX3("NX8_VDESCO")[2] ) ) // Valor de desconto Linear

		lRet := lRet .And. JurloadValue( oModelNX8 , "NX8_TS"    , Nil, Iif(nVlTSCon == 0 .And. nTSContr == 0, "2" ,"1") )
		lRet := lRet .And. JurloadValue( oModelNX8 , "NX8_DESP"  , Nil, Iif(nVlDPCon == 0 .And. nDPContr == 0, "2" ,"1") )
		lRet := lRet .And. JurloadValue( oModelNX8 , "NX8_LANTAB", Nil, Iif(nVlTBCon == 0 .And. nTBContr == 0, "2" ,"1") )

		If !lTelaRat
			lRet := lRet .And. JurloadValue( oModelNX8 , "NX8_VLDESC",	, Round( nVDesECon, TamSX3("NX8_VLDESC")[2] ) ) // Valor Desconto Especial
			lRet := lRet .And. JurloadValue( oModelNX8 , "NX8_VDESCT",	, Round( oModelNX8:GetValue("NX8_VDESCO") + oModelNX8:GetValue("NX8_VLDESC"), TamSX3("NX8_VDESCT")[2] ) )
		EndIf

		nVlTSPre	:= nVlTSPre + nVlTSCon

		If cCobH == "1"
			nVlTSFatu	:= nVlTSFatu + nVlTSCon
		EndIf

		nVlDPPre	:= nVlDPPre + nVlDPCon
		nVlTBPre	:= nVlTBPre + nVlTBCon
		nVDescPre	:= nVDescPre + nVDescCon
		nVDesEPre	:= nVDesEPre + nVDesECon
		nVlFXPre	:= nVlFXPre + nVlFXCon

		lRet	:= lRet .And. JurloadValue( oModelNX8 , "NX8_VFIXO",    , Round( nVlFXCon, TamSX3("NX8_VFIXO")[2] ) )

		If oModelNX0:GetValue( 'NX0_FATADC' ) != "1" .And. nVlFaixa == 0
			lRet	:= lRet .And. JurloadValue( oModelNX8 , "NX8_VHON",	, Round( nVlTSCon + nVlTBCon + oModelNX8:GetValue("NX8_VFIXO"), TamSX3("NX8_VHON")[2] ) )
		EndIf

		lRet := lRet .And. J202DivCas("NX8") // Ajusta o rateio no campo NX1_VHON

		Iif(nTSContr > 0, nTSPre++, )
		Iif(nDPContr > 0, nDPPre++, )
		Iif(nTBContr > 0, nTBPre++, )

	Next nINX8
	oModelNX8:GoLine(nLNNX8)

	lRet := lRet .And. JurloadValue( oModelNX0 , "NX0_VTS",		, Round( nVlTSPre, TamSX3("NX0_VTS")[2] ) )
	lRet := lRet .And. JurloadValue( oModelNX0 , "NX0_VLFATD",	, Round( nVlDPPre, TamSX3("NX0_VLFATD")[2] ) )

	lRet := lRet .And. JurloadValue( oModelNX0 , "NX0_TS"    , Nil, Iif(nVlTSPre == 0 .And. nTSPre == 0, "2", "1") )
	lRet := lRet .And. JurloadValue( oModelNX0 , "NX0_DESP"  , Nil, Iif(nVlDPPre == 0 .And. nDPPre == 0, "2", "1") )
	lRet := lRet .And. JurloadValue( oModelNX0 , "NX0_LANTAB", Nil, Iif(nVlTBPre == 0 .And. nTBPre == 0, "2", "1") )

	lRet := lRet .And. JurloadValue( oModelNX0 , "NX0_DESCON",	, Round( nVDescPre, TamSX3("NX0_DESCON")[2] ) )
	lRet := lRet .And. JurloadValue( oModelNX0 , "NX0_VDESCT",	, Round( nVDescPre + nVDesEPre , TamSX3("NX0_VDESCT")[2] ) )

	If oModelNX0:GetValue("NX0_TPDESC") == "1" //Valor
		lRet := lRet .And. JurloadValue( oModelNX0 , "NX0_PDESCH",	, Round( nVDesEPre / (nVlTSFatu + nVlFXPre - nVDescPre) * 100, TamSX3("NX0_PDESCH")[2] ) )
	Else // Percentual
		lRet := lRet .And. JurloadValue( oModelNX0 , "NX0_DESCH",	, Round( nVDesEPre, TamSX3("NX0_DESCH")[2] ) )
	EndIf

	If oModelNX0:GetValue( 'NX0_FATADC' ) != "1" .And. nVlFaixa ==  0
		lRet := lRet .And. JurloadValue( oModelNX0 , "NX0_VLFATH", , Round( nVlTSFatu + nVlTBPre + nVlFXPre, TamSX3("NX0_VLFATH")[2] ) )
		lRet := lRet .And. JurloadValue( oModelNX0 , "NX0_VLFATT", , Round( nVlTBPre , TamSX3("NX0_VLFATT")[2] ) )
	EndIf

	If lRet
		If oModelNX0:GetValue( "NX0_TPACRE") == "1" //valor
			nPAcres := (oModelNX0:GetValue("NX0_ACRESH") / oModelNX0:GetValue( "NX0_VLFATH") ) * 100
			lRet := lRet .And. JurloadValue( oModelNX0 , "NX0_PACREH",	, Round( nPAcres, TamSX3("NX0_PACREH")[2] ) )
		Else
			If oModelNX0:GetValue("NX0_VLFATH") == 0 .And. oModelNX0:GetValue("NX0_VLFATD") > 0
				lRet := lRet .And. JurloadValue( oModelNX0 , "NX0_TPACRE",	, "1")
				lRet := lRet .And. JurloadValue( oModelNX0 , "NX0_PACREH",	, 0)
			Else
				nVAcres := (oModelNX0:GetValue( "NX0_PACREH") * oModelNX0:GetValue("NX0_VLFATH")) / 100
				lRet := lRet .And. JurloadValue( oModelNX0 , "NX0_ACRESH",	, Round( nVAcres, TamSX3("NX0_ACRESH")[2] ) )
			EndIf
		EndIf
	EndIf

	If !lRet
		JurShowErro( oModel:GetModel():GetErrormessage() )
	EndIf

	FwRestRows( aSaveLn, oModel )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202SEQPar()
Rotina para retornar o nÃºmero da sequÃªncia do participante

@Params	aPartCas - 	Array com as informaçoes do participante
					aPartCas[1] : Participante
					aPartCas[14]: SequÃªncia

@Params	oModelNX2 - Modelo de dados da tabela de participantes

@Return cCodSeq - Sequência do código do Participante.

@author Luciano Pereira dos Santos
@since 15/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202SEQPar(aPartCas, oModelNX2 )
Local cCodSeq := aPartCas[14]
Local nINX2   := 0
Local cCodAux := cCodSeq
Local nCodSeq := 0

For nINX2 := 1 To oModelNX2:GetQtdLine()
	oModelNX2:GoLine( nINX2 )
	If oModelNX2:GetValue("NX2_CPART") == aPartCas[1]
		If cCodAux < oModelNX2:GetValue("NX2_CODSEQ")
			cCodAux := oModelNX2:GetValue("NX2_CODSEQ")
		EndIf
	EndIf
Next nINX2

If cCodSeq <= cCodAux
	nCodSeq := Val(cCodAux) + 1
	cCodSeq := PADL(AllTrim(Str(nCodSeq)), tamSX3('NX2_CODSEQ')[1], '0')
EndIf

Return cCodSeq

Static Function ActiveRevisao(oView)
Local oOtherObject := oView:GetViewObj("JURA202_REV")[3]

	If !oOtherObject:IsActivate()
		FWMsgRun(, {|| JActRevi(oView, oOtherObject ) }, STR0147, STR0230)  // #"Aguarde..." ##"Iniciando a Revisão..."
	EndIf

Return .T.

Static Function JActRevi(oView, oOtherObject)
Local oRev := Nil

	oOtherObject:Activate()
	If !( (oRev := JA207GetRev()) == Nil)
		oRev:Reload(oView)
	EndIf

Return .T.

Function JA202Part(oModelNUE, cTipo, lAtualiza )
Local lRet          := .T.
Local nUTLanc       := 0
Local nHrFracL      := 0
Local nUTRev        := 0
Local nHrFracRev    := 0
Local nUTCli        := 0
Local nHrFracCli    := 0
Local nCodSeq       := 0
Local nPosPart      := 0
Local oModelNX2     := Nil
Local oModel        := oModelNUE:GetModel()
Local nNX2          := 0

Default lAtualiza   := .F.

	If !lAltPerio

	//Verifica se a atividade possui participação do cliente para acumular as horas alteráveis
		If !(JA202TEMPO(.F., oModelNUE:GetValue("NUE_CATIVI") ))
			nUTRev      := 0
			nHrFracRev  := 0
			nUTLanc     := 0
			nHrFracL    := 0
			nUTCli      := oModelNUE:GetValue("NUE_UTR")
			nHrFracCli  := oModelNUE:GetValue("NUE_TEMPOR")
		Else
			nUTLanc     := oModelNUE:GetValue("NUE_UTL")
			nHrFracL    := oModelNUE:GetValue("NUE_TEMPOL")
			nUTRev      := oModelNUE:GetValue("NUE_UTR")
			nHrFracRev  := oModelNUE:GetValue("NUE_TEMPOR")
			nUTCli      := 0
			nHrFracCli  := 0
		EndIf

		If cTipo == "+"   // Acumula no caso Destino

			//Recalcula o Time-Sheet
			nPosPart := aScan( aPart, { |x| Alltrim(x[ 1]) == Alltrim(oModelNUE:GetValue( "NUE_CCLIEN"))		.And. ;
											Alltrim(x[ 2]) == Alltrim(oModelNUE:GetValue( "NUE_CLOJA"))		.And. ;
											Alltrim(x[ 3]) == Alltrim(oModelNUE:GetValue( "NUE_CCASO")) 		.And. ;
											Alltrim(x[ 4]) == Alltrim(oModelNUE:GetValue( "NUE_CPART2")) 		.And. ;
											        x[ 5]  ==         oModelNUE:GetValue( "NUE_VALORH") 		.And. ;
											Alltrim(x[13]) == Alltrim(oModelNUE:GetValue( "NUE_CLTAB")) 		.And. ;
											Alltrim(x[14]) == Alltrim(oModelNUE:GetValue( "NUE_CCATEG"))		.And. ;
											Alltrim(x[21]) == Alltrim(oModelNUE:GetValue( "NUE_CMOEDA"))	} )

			If nPosPart > 0

				aPart[nPosPart][ 6] := aPart[nPosPart][ 6] + oModelNUE:GetValue( "NUE_VALOR1" )

				aPart[nPosPart][ 7] := aPart[nPosPart][ 7] + nUTRev 							//[07] "NX2_UTR"
				aPart[nPosPart][ 8] := aPart[nPosPart][ 8] + nHrFracRev							//08] "NX2_TEMPOR"
				aPart[nPosPart][ 9] := aPart[nPosPart][ 9] + JURA144C1(2, 3, Str(nHrFracRev)) 	//[09] "NX2_HORAR" //converte a H Frac

				aPart[nPosPart][15] := aPart[nPosPart][15] + nUTLanc			//[15] "NX2_UTLANC"
				aPart[nPosPart][16] := aPart[nPosPart][16] + nHrFracL			//[16] "NX2_HFLANC"
				aPart[nPosPart][17] := JURA144C1(2, 3, Str(aPart[nPosPart][16])) //[17] "NX2_HRLANC" //converte a H Frac

				aPart[nPosPart][18] := aPart[nPosPart][18] + nUTCli				//[18] "NX2_UTCLI"
				aPart[nPosPart][19] := aPart[nPosPart][19] + nHrFracCli			//[19] "NX2_HFCLI"
				aPart[nPosPart][20] := JURA144C1(2, 3, Str(aPart[nPosPart][19])) //[20] "NX2_HRCLI" //converte a H Frac

			Else

				nCodSeq := 1
				For nPosPart := 1 To Len(aPart)
					If aPart[nPosPart][ 1] == oModelNUE:GetValue("NUE_CCLIEN")	.And.;
						aPart[nPosPart][ 2] == oModelNUE:GetValue("NUE_CLOJA")	.And.;
						aPart[nPosPart][ 3] == oModelNUE:GetValue("NUE_CCASO")	.And.;
						aPart[nPosPart][ 4] == oModelNUE:GetValue("NUE_CPART2")
						nCodSeq := nCodSeq + 1
					EndIf
				Next nIPart

				aadd(aPart, {oModelNUE:GetValue( "NUE_CCLIEN")	, oModelNUE:GetValue( "NUE_CLOJA")	, oModelNUE:GetValue( "NUE_CCASO")	,;	//[ 3]
							oModelNUE:GetValue("NUE_CPART2")	, oModelNUE:GetValue("NUE_VALORH")	, oModelNUE:GetValue("NUE_VALOR1")	,;  //[ 6]
							nUTRev								, nHrFracRev						, JURA144C1(2, 3, Str(nHrFracRev))	,;  //[ 9]
							PADL(AllTrim(Str(nCodSeq)), TamSX3('NX2_CODSEQ')[1], '0')			, 0									, .T.								,;	//[12]
							oModelNUE:GetValue("NUE_CLTAB")		, oModelNUE:GetValue("NUE_CCATEG")	, nUTLanc							,; 	//[15]
							nHrFracL							, JURA144C1(2, 3, Str(nHrFracL)	 )	, nUTCli							,; 	//[18]
							nHrFracCli							, JURA144C1(2, 3, Str(nHrFracCli))	, oModelNUE:GetValue("NUE_CMOEDA")})	//[21]
			EndIf

		ElseIf cTipo == "-"   // Subtrai do caso Original

			/*
			aPart: {[01] "NX1_CCLIEN", [02] "NX1_CLOJA" , [03] "NX1_CCASO",;
					[04] "NX2_CPART" , [05] "NX2_VALORH", [06] "NX2_VALOR1",;
					[07] "NX2_UTR"   , [08] "NX2_TEMPOR", [09] "NX2_HORAR",;
					[10] "NX2_CODSEQ", [11] oModelNX2:nLine [12] Part Alterado?;
					[13] "NX2_CLTAB",  [14] "NX2_CCATEG", [15] "NX2_UTLANC";
					[16] "NX2_HFLANC", [17] "NX2_HRLANC", [18] "NX2_UTCLI";
					[19] "NX2_HFCLI",  [20] "NX2_HRCLI" , [21] "NX2_CMOTBH" } )
			*/
			nPosPart := aScan( aPart, { |x| Alltrim(x[ 1]) == Alltrim(oModelNUE:GetValue( "NUE_CCLIEN"))		.And. ;
											Alltrim(x[ 2]) == Alltrim(oModelNUE:GetValue( "NUE_CLOJA"))		.And. ;
											Alltrim(x[ 3]) == Alltrim(oModelNUE:GetValue( "NUE_CCASO")) 		.And. ;
											Alltrim(x[ 4]) == Alltrim(oModelNUE:GetValue( "NUE_CPART2")) 		.And. ;
											        x[ 5]  ==         oModelNUE:GetValue( "NUE_VALORH")  		.And. ;
											Alltrim(x[13]) == Alltrim(oModelNUE:GetValue( "NUE_CLTAB")) 		.And. ;
											Alltrim(x[14]) == Alltrim(oModelNUE:GetValue( "NUE_CCATEG"))		.And. ;
											Alltrim(x[21]) == Alltrim(oModelNUE:GetValue( "NUE_CMOEDA"))	} )

			If nPosPart > 0

				aPart[nPosPart][ 6] := aPart[nPosPart][ 6] - oModelNUE:GetValue( "NUE_VALOR1")

				aPart[nPosPart][ 7] := aPart[nPosPart][ 7] - nUTRev 							//[07] "NX2_UTR"
				aPart[nPosPart][ 8] := aPart[nPosPart][ 8] - nHrFracRev							//08] "NX2_TEMPOR"
				aPart[nPosPart][ 9] := aPart[nPosPart][ 9] - JURA144C1(2, 3, Str(nHrFracRev)) 	//[09] "NX2_HORAR" //converte a H Frac

				aPart[nPosPart][15] := aPart[nPosPart][15] - nUTLanc			//[15] "NX2_UTLANC"
				aPart[nPosPart][16] := aPart[nPosPart][16] - nHrFracL			//[16] "NX2_HFLANC"
				aPart[nPosPart][17] := JURA144C1(2, 3, Str(aPart[nPosPart][16])) //[17] "NX2_HRLANC" //converte a H Frac

				aPart[nPosPart][18] := aPart[nPosPart][18] - nUTCli				//[18] "NX2_UTCLI"
				aPart[nPosPart][19] := aPart[nPosPart][19] - nHrFracCli			//[19] "NX2_HFCLI"
				aPart[nPosPart][20] := JURA144C1(2, 3, Str(aPart[nPosPart][19])) //[20] "NX2_HRCLI" //converte a H Frac

			EndIf
		ElseIf cTipo = '*' //Remove totos os participantes do caso

			While 	(nPosPart := aScan( aPart, { |x| Alltrim(x[ 1]) == Alltrim(oModelNUE:GetValue( "NUE_CCLIEN"))	.And. ;
				  									Alltrim(x[ 2]) == Alltrim(oModelNUE:GetValue( "NUE_CLOJA"))		.And. ;
													Alltrim(x[ 3]) == Alltrim(oModelNUE:GetValue( "NUE_CCASO")) ;
												} )) > 0

				aPart := JaRemPos(aPart, nPosPart)

			End

			nSvLine := oModelNUE:GetLine()
			For nPosPart := 1 To oModelNUE:GetQtdLine()
				oModelNUE:GoLine(nPosPart)
				JA202Part( oModelNUE ,'+')
			Next nPosPart

			oModelNUE:GoLine(nSvLine)

		Else
			lRet := .F.
		EndIf

		If lAtualiza .And. nPosPart > 0

			oModelNX2 := oModel:GetModel("NX2DETAIL")
			nLinNX2   := oModelNX2:nLine

			For nNX2 := 1 To oModelNX2:Length()
				oModelNX2:goLine(nNX2)
				If 	Alltrim(aPart[nPosPart][ 1]) == Alltrim(oModelNX2:GetValue( "NX2_CCLIEN"))		.And. ;
					Alltrim(aPart[nPosPart][ 2]) == Alltrim(oModelNX2:GetValue( "NX2_CLOJA"))		.And. ;
					Alltrim(aPart[nPosPart][ 3]) == Alltrim(oModelNX2:GetValue( "NX2_CCASO")) 		.And. ;
					Alltrim(aPart[nPosPart][ 4]) == Alltrim(oModelNX2:GetValue( "NX2_CPART")) 		.And. ;
					        aPart[nPosPart][ 5]  ==         oModelNX2:GetValue( "NX2_VALORH") 		.And. ;
					Alltrim(aPart[nPosPart][13]) == Alltrim(oModelNX2:GetValue( "NX2_CLTAB")) 		.And. ;
					Alltrim(aPart[nPosPart][14]) == Alltrim(oModelNX2:GetValue( "NX2_CCATEG"))		.And. ;
					Alltrim(aPart[nPosPart][21]) == Alltrim(oModelNX2:GetValue( "NX2_CMOTBH"))

					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_CPART"	,	,	aPart[nPosPart][ 4] )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_CCATEG"	,	,	aPart[nPosPart][14] )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_VALORH"	,	,	aPart[nPosPart][ 5] )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_CLTAB"	,	,	aPart[nPosPart][13] )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_CMOTBH"	,	,	aPart[nPosPart][21] )
				 //	lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_CODSEQ"	,	,	aPart[nPosPart][10] )

					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_UTR"		,	, Round( aPart[nPosPart][ 7], JURX3INFO("NX2_UTR"		,	"X3_DECIMAL") ) )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_TEMPOR"	,	, Round( aPart[nPosPart][ 8], JURX3INFO("NX2_TEMPOR"	,	"X3_DECIMAL") ) )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_HORAR"	,	, JURA144C1(2, 3, Str(oModelNX2:GetValue("NX2_TEMPOR"))) )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_UTLANC"	,	, Round( aPart[nPosPart][15], JURX3INFO("NX2_UTLANC"	,	"X3_DECIMAL") ) )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_HFLANC"	,	, Round( aPart[nPosPart][16], JURX3INFO("NX2_HFLANC"	,	"X3_DECIMAL") ) )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_HRLANC"	,	, JURA144C1(2, 3, Str(oModelNX2:GetValue("NX2_HFLANC"))))
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_UTCLI"	,	, Round( aPart[nPosPart][18], JURX3INFO("NX2_UTCLI"	,	"X3_DECIMAL") ) )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_HFCLI"	,	, Round( aPart[nPosPart][19], JURX3INFO("NX2_HFCLI"	,	"X3_DECIMAL") ) )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_HRCLI"	,	, JURA144C1(2, 3, Str(oModelNX2:GetValue("NX2_HFCLI"))) )

					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_VLHTBH"	,	, Round( oModelNX2:GetValue("NX2_TEMPOR") * oModelNX2:GetValue("NX2_VALORH"), JURX3INFO("NX2_VLHTBH"	,	"X3_DECIMAL") ) )
					lRet := lRet .And. JurloadValue( oModelNX2 , "NX2_VALOR1"	,	, Round( aPart[nPosPart][ 6], JURX3INFO("NX2_VALOR1"	,	"X3_DECIMAL") ) )

					Exit

				EndIf

			Next nNX2
			oModelNX2:goLine(nLinNX2)
		EndIf
	EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} IsJura202()
Função para verificar se está na JURA202

@author Felipe Bonvicini Conti
@since 03/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function IsJura202()
Return lJURA202 // Aqui não preciso do IsMemVar('lJURA202') pois a variável foi inicializada como Static

//-------------------------------------------------------------------
/*/{Protheus.doc} SetJura202()
Função para alterar variavel lJURA202

@author Luciano Pereira dos Santos
@since 25/02/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function SetJura202(lSet)
	lJURA202 := lSet
Return lJURA202

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202NEWTS()
Função para incluir novo TS a pré-fatura

@author Felipe Bonvicini Conti
@since 03/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA202NEWTS(oModelNX0, cCodPre)
Local aArea     := GetArea()
Local aAreaNUE  := NUE->(GetArea())
Local aAreaNX0  := NX0->(GetArea())
Local aAreaNX1  := NX1->(GetArea())
Local lRet      := .F.
Local cCodTS    := ""
Local oModelOLD := FwModelActive(, .T.)
Local oView     := FwViewActive()
Local aValor1TS := {}
Local cMoedPF   := ""
Local lAtivNaoC := SuperGetMV( 'MV_JURTS4',, .F. ) //Zera o tempo revisado de atividades nao cobraveis
Local aCaso     :={}
Local lConf     := .T.   // novo
Local cJunc     := ""
Local cContr    := ""
Local aCampos   := {}
Local aValores  := {}
Local nCountTS  := 0
Local lInsCas   := .F.
Local aAjustPf  := {}
Local cJurUser  := JurUsuario(__CUSERID)
Local lTSNCobra := SuperGetMV( 'MV_JTSNCOB',, .F. ) // Indica se vincula TimeSheet não cobrável na emissão
Local lTsCobra  := .T. // Indica se o TS é cobrável
Local lFxNC     := NX0->(ColumnPos('NX0_FXNC')) > 0 .And. oModelNX0:GetValue("NX0_FXNC") == "1" // @12.1.2210 - Indica se é uma pré de TS de contratos fixos ou não cobráveis

Local cCodTSErr := ''
Local lLiberaTudo
Local lLibAlteracao
Local aRetBlqTS

If !Empty(oModelOld)
	If oModelOLD:lModify .And. (lConf := oModelOLD:VldData()) // Necessário pois se o modelo não foi alterado o commit retorna .F.
		lConf := oModelOLD:CommitData()  //Confirmar modelo de dados para não perder as alterações anteriores a operação.
	EndIf
EndIf

While lConf  // enquanto lConf =.t. não finaliza tela de Inclusão de TS.
	SetJura202(.F.)
	FWMsgRun(, {|| lConf := ( FWExecView(STR0008, "JURA144", 3,, {||.T.} ) == 0) }, STR0147, STR0001) // "Aguarde..." "Operação de Pré-Faturas" "Time-Sheet"
	SetJura202(.T.)
	If lConf
		If lLibParam
			aRetBlqTS := JBlqTSheet(dDatabase)
		EndIf
		lLiberaTudo   := aRetBlqTS[1]
		lLibAlteracao := aRetBlqTS[3]
		lLibParam     := aRetBlqTS[5]

		If !lLiberaTudo .And. !lLibAlteracao
			cCodTSErr += AllTrim(NUE->NUE_COD) + "; "
			Exit
		EndIf

		If J202DTTS(NUE->NUE_COD, cCodPre) //Verifica se a data está dentro do período da pré/parcela e se o caso faz parte
			Begin Transaction
				cCodTS    := NUE->NUE_COD
				cMoedPF   := oModelNX0:GetValue( "NX0_CMOEDA" )
				aValor1TS := JA201FConv(cMoedPF, NUE->NUE_CMOEDA, NUE->NUE_VALOR, "2", oModelNX0:GetValue( "NX0_DTEMI" ), , cCodPre, )

				aCampos   := {"NUE_CPREFT", "NUE_CMOED1", "NUE_VALOR", "NUE_VALOR1", "NUE_COTAC1", "NUE_COTAC2", "NUE_HORAR", "NUE_TEMPOR", "NUE_UTR" }

				If lAtivNaoC .Or. lTSNCobra
					lTsCobra := JurTSCob(NUE->NUE_COD, NUE->NUE_CCLIEN, NUE->NUE_CLOJA, NUE->NUE_CCASO, NUE->NUE_CATIVI, lFxNC)
					If lTsCobra
						aValores := {cCodPre, cMoedPF, NUE->NUE_VALOR, aValor1TS[1], aValor1TS[2], aValor1TS[3], NUE->NUE_HORAR, NUE->NUE_TEMPOR, NUE->NUE_UTR }
					ElseIf lAtivNaoC
						aValores := {cCodPre, cMoedPF, 0             , 0           , aValor1TS[2], aValor1TS[3], '00:00'       , 0              , 0            }
					ElseIf lTSNCobra
						aValores := {cCodPre, cMoedPF, NUE->NUE_VALOR, 0, 0, 0, NUE->NUE_HORAR, NUE->NUE_TEMPOR, NUE->NUE_UTR }
					EndIf
				Else
					aValores := {cCodPre, cMoedPF, NUE->NUE_VALOR, aValor1TS[1], aValor1TS[2], aValor1TS[3], NUE->NUE_HORAR, NUE->NUE_TEMPOR, NUE->NUE_UTR }
				EndIf

				lRet := JurOperacao(MODEL_OPERATION_UPDATE, "NUE", 1, xFilial("NUE") + cCodTS, aCampos, aValores)
				If lRet
					aCampos  := {"NW0_CTS", "NW0_PRECNF", "NW0_SITUAC", "NW0_CANC", "NW0_CODUSR",;
					             "NW0_CCLIEN", "NW0_CLOJA", "NW0_CCASO", "NW0_CPART1", "NW0_TEMPOL",;
					             "NW0_TEMPOR", "NW0_VALORH", "NW0_CMOEDA", "NW0_DATATS"}

					aValores := {cCodTS, cCodPre, "1", "2", __CUSERID,;
						NUE->NUE_CCLIEN, NUE->NUE_CLOJA, NUE->NUE_CCASO, NUE->NUE_CPART1, NUE->NUE_TEMPOL,;
						NUE->NUE_TEMPOR, NUE->NUE_VALORH, NUE->NUE_CMOEDA, NUE->NUE_DATATS}

					// NW0_FILIAL, NW0_CTS, NW0_SITUAC, NW0_PRECNF, NW0_CFATUR, NW0_CESCR, NW0_CWO
					If Empty(JurGetDados("NW0", 1, xFilial("NW0") + cCodTS + "1" + cCodPre, "NW0_CTS"))
						lRet := JurOperacao(MODEL_OPERATION_INSERT, "NW0", , , aCampos, aValores)
					EndIf

					If lRet
						cJunc  := oModelNX0:GetValue( "NX0_CJCONT" )
						cContr := oModelNX0:GetValue( "NX0_CCONTR" )

						aCaso  := J202CasTS(NUE->NUE_CCLIEN, NUE->NUE_CLOJA, NUE->NUE_CCASO, cCodPre, cJunc, NUE->NUE_DATATS)

						If !Empty(aCaso)
							NX1->( dbSetOrder( 1 ) ) //NX1_FILIAL+NX1_CPREFT+NX1_CCLIEN+NX1_CLOJA+NX1_CCONTR+NX1_CCASO
							If NX1->( dbSeek( xFilial( 'NX1' ) + cCodPre + aCaso[1][1] + aCaso[1][2] + aCaso[1][3] + aCaso[1][4] ) )
								If NX1->NX1_TS == "2"
									RecLock( "NX1", .F. )
									NX1->NX1_TS := "1"
									NX1->(MsUnLock())
									NX1->(DBCommit())
								EndIf
							Else
								lInsCas := .T.
							EndIf
						Else
							lInsCas := .T.
							If !Empty(aAjustPf := J202BCntPf(cCodPre, cContr, cJunc, NUE->NUE_CCLIEN, NUE->NUE_CLOJA, NUE->NUE_CCASO, "TS")) //Verifica o codigo do contrato não vinculado a pré-fatura
								aCaso := {aAjustPf}
							EndIf
						EndIf

						If lInsCas .And. !Empty(aCaso) //Se o caso não esta na pré-fatura, insere o caso

							aNVE := JurGetDados("NVE", 1, xFilial("NVE") + NUE->(NUE_CCLIEN + NUE_CLOJA + NUE_CCASO), {"NVE_DESPAD", "NVE_CPART1"})

							RecLock("NX1", .T.)
							NX1->NX1_FILIAL := xFilial("NX1")
							NX1->NX1_CPREFT := cCodPre
							NX1->NX1_CCLIEN := NUE->NUE_CCLIEN
							NX1->NX1_CLOJA  := NUE->NUE_CLOJA
							NX1->NX1_CCONTR := aCaso[1][3]
							NX1->NX1_CCASO  := NUE->NUE_CCASO
							NX1->NX1_TS     := "1"
							NX1->NX1_DESP   := "2"
							NX1->NX1_LANTAB := "2"
							NX1->NX1_VTS    := IIF(lTsCobra, NUE->NUE_VALOR1, 0)
							NX1->NX1_PDESCH := aNVE[1]
							NX1->NX1_CPART  := aNVE[2]
							NX1->NX1_CMOETH := NUE->NUE_CMOEDA
							NX1->NX1_TSREV  := "2"
							NX1->NX1_DSPREV := "2"
							NX1->NX1_TABREV := "2"
							NX1->(MsUnlock())
							NX1->(DbCommit())

							J201EGrvRv(NX1->NX1_CPREFT, NX1->NX1_CCONTR, .F.) // Grava sócios/revisores

							If NX8->( dbSeek( xFilial('NX8') + cCodPre + aCaso[1][3] ))
								If NX8->NX8_TS == "2"
									RecLock("NX8", .F.)
									NX8->NX8_TS  := '1'
									NX8->(msUnlock())
									NX8->(DbCommit())
								EndIf
							Else
								RecLock("NX8", .T.)
								NX8->NX8_FILIAL  := xFilial("NX8")
								NX8->NX8_CPREFT  := cCodPre
								NX8->NX8_CCLIEN  := aCaso[1][1]
								NX8->NX8_CLOJA   := aCaso[1][2]
								NX8->NX8_CCONTR  := aCaso[1][3]
								NX8->NX8_CJCONT  := cJunc
								NX8->NX8_VTS     := IIF(lTsCobra, NUE->NUE_VALOR1, 0)
								NX8->NX8_TSREV   := "2"
								NX8->NX8_DSPREV  := "2"
								NX8->NX8_TABREV  := "2"
								NX8->NX8_FIXO    := "2"
								NX8->NX8_FATADC  := "2"
								NX8->NX8_TS      := "1"
								NX8->NX8_DESP    := "2"
								NX8->NX8_LANTAB  := "2"
								NX8->(MsUnlock())
								NX8->(DbCommit())
							EndIf

						EndIf

						If !JurIn(NX0->NX0_SITUAC, {SIT_ALTERADA, SIT_SUBSTITUIDA, SIT_EMIFATURA, SIT_MINEMITIDA, SIT_MINCANCEL, SIT_EMREVISAO })
							NX0->( dbSetOrder( 1 ) )
							If NX0->( dbSeek( xFilial( 'NX0' ) + cCodPre ) )
								If RecLock( "NX0", .F. )
									NX0->NX0_SITUAC := SIT_ALTERADA
									NX0->NX0_USRALT := cJurUser
									NX0->NX0_DTALT  := Date()
									NX0->(MsUnLock())
									NX0->(DbCommit())
								EndIf
							EndIf
						EndIf

						++nCountTS
					EndIf

				Else
					Alert(STR0211) // "Erro ao salvar o time-sheet!"
					JurOperacao(MODEL_OPERATION_DELETE, "NUE", 1, xFilial("NUE") + cCodTS)
					JurOperacao(MODEL_OPERATION_DELETE, "NW0", 2, xFilial("NW0") + cCodTS)
				EndIf

			End Transaction
		Else
			lRet := .F.
			Alert(STR0209 + STR0210) // "O time-sheet inserido não foi vinculado a pré-fatura pois o cliente, loja e caso do mesmo não está relacionado a pré-fatura, as condições de faturamento não permitem o seu vínculo ou ainda " "a data do mesmo está fora do período de referência da pré-fatura!"
		EndIf

	EndIf //Fim da condição do While

	If !Empty(oModelOld)
		FwModelActive(oModelOld)
	EndIf

EndDo

If ! Empty(cCodTSErr) .And. lLibParam
	JurMsgErro(STR0266 + cCodTSErr)  // "Você não tem permissão para incluir o seguinte timesheet: "
EndIf

lRet := (nCountTS > 0) //Mesmo que algum dos TS tenha retornado .F., a rotina precisa retornar .T. para atualizar os outros TS na pré-fatura

If lRet .And. !Empty(oModelOld) //Recarrega/Atualiza o modelo para efetuar o recalculo dos TS incluidos na pré-fatura pelo modelo (202totpre).
	FwModelActive(oModelOld)
	oModelOld:Deactivate()
	oModelOld:Activate()
	If oView != Nil
		oView:Refresh()
	EndIf
EndIf

RestArea(aAreaNX0)
RestArea(aAreaNX1)
RestArea(aAreaNUE)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}  J202CasTS()
Rotina para retornar o caso da pré-fatura para vincular o TS

@Param cCliente   Código do cliente do TS
@Param cLoja      Código da loja do TS
@Param cCaso      Código do caso do TS
@Param cCodPre    Codigo da Pré-fatura
@Param cJunc      Código da Junção do contrato
@Param dDataTS    Data do Time-Sheet

@Return aCaso     array com as informaçoes do caso para vincular o TS

@author Luciano Pereira dos Santos / Jonatas Martins
@since 21/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202CasTS(cCliente, cLoja, cCaso, cCodPre, cJunc, dDataTS)
	Local lVincTS   := SuperGetMv('MV_JVINCTS ',, .T.)
	Local cQuery    := ""
	Local aCaso     := {}
	Local aVigencia := {}
	Local aCasoVig  := {}
	Local lCpoVig   := NX8->(ColumnPos("NX8_DTVIGI")) > 0
	Local nCas      := 1

	cQuery := "SELECT NX1.NX1_CCLIEN, NX1.NX1_CLOJA, NX1.NX1_CCONTR, NX1.NX1_CCASO " + CRLF
	cQuery += " FROM " + RetSqlName( "NX1" ) + " NX1, " + RetSqlName( "NX8" ) + " NX8, " + CRLF
	cQuery += + RetSqlName( "NT0" ) + " NT0, " + RetSqlName( "NRA" ) + " NRA " + CRLF
	cQuery += " WHERE NX1.NX1_FILIAL = '" + xFilial( "NX1 " ) + "'" + CRLF
	cQuery += " AND NX8.NX8_FILIAL = '" + xFilial( "NX8 " ) + "'" + CRLF
	cQuery += " AND NT0.NT0_FILIAL = '" + xFilial( "NT0 " ) + "'" + CRLF
	cQuery += " AND NRA.NRA_FILIAL = '" + xFilial( "NRA " ) + "'" + CRLF
	cQuery += " AND NX8.NX8_CPREFT = NX1.NX1_CPREFT " + CRLF
	cQuery += " AND NX8.NX8_CCONTR = NT0.NT0_COD " + CRLF
	cQuery += " AND NT0.NT0_CTPHON = NRA.NRA_COD " + CRLF
	cQuery += " AND (NRA.NRA_COBRAH = '1' " + CRLF

	If lVincTS
		cQuery +=        " OR (NRA.NRA_COBRAF = '1' " + CRLF
		If !Empty(cJunc) //Valida se o caso esta em dois o mais contratos em junção na mesma pré-fatura, colocando o TS no caso do contrato que cobre Hora
			cQuery +=    " AND NOT EXISTS ( SELECT NX8.R_E_C_N_O_ " + CRLF
			cQuery +=                      " FROM " + RetSqlName("NX8") + " NX8a, " + CRLF
			cQuery +=                           " " + RetSqlName("NX1") + " NX1a, " + CRLF
			cQuery +=                           " " + RetSqlName("NT0") + " NT0a, " + CRLF
			cQuery +=                           " " + RetSqlName("NRA") + " NRAa, " + CRLF
			cQuery +=                           " " + RetSqlName("NW3") + " NW3a  " + CRLF
			cQuery +=                      " WHERE NX8a.NX8_FILIAL = '" + xFilial("NX8") +"' " + CRLF
			cQuery +=                        " AND NX1a.NX1_FILIAL = '" + xFilial("NX1") +"' " + CRLF
			cQuery +=                        " AND NT0a.NT0_FILIAL = '" + xFilial("NT0") +"' " + CRLF
			cQuery +=                        " AND NW3a.NW3_FILIAL = '" + xFilial("NW3") +"' " + CRLF
			cQuery +=                        " AND NRAa.NRA_FILIAL = '" + xFilial("NRA") +"' " + CRLF
			cQuery +=                        " AND NX8a.NX8_CPREFT = NX8.NX8_CPREFT " + CRLF
			cQuery +=                        " AND NX8a.NX8_CCONTR = NX1a.NX1_CCONTR " + CRLF
			cQuery +=                        " AND NX1a.NX1_CCLIEN = NX1.NX1_CCLIEN " + CRLF
			cQuery +=                        " AND NX1a.NX1_CLOJA  = NX1.NX1_CLOJA " + CRLF
			cQuery +=                        " AND NX1a.NX1_CCASO  = NX1.NX1_CCASO " + CRLF
			cQuery +=                        " AND NX8a.NX8_CCONTR = NT0.NT0_COD " + CRLF
			cQuery +=                        " AND NRAa.NRA_COD    = NT0.NT0_CTPHON " + CRLF
			cQuery +=                        " AND NW3a.NW3_CCONTR = NT0.NT0_COD " + CRLF
			cQuery +=                        " AND NW3a.NW3_CJCONT = '"+cJunc+"' " + CRLF
			cQuery +=                        " AND NRAa.NRA_COBRAH = '1' " + CRLF
			cQuery +=                        " AND NRAa.NRA_COBRAF = '2' " + CRLF
			cQuery +=                        " AND NX8a.D_E_L_E_T_ = ' ' " + CRLF
			cQuery +=                        " AND NX1a.D_E_L_E_T_ = ' ' " + CRLF
			cQuery +=                        " AND NT0a.D_E_L_E_T_ = ' ' " + CRLF
			cQuery +=                        " AND NW3a.D_E_L_E_T_ = ' ' " + CRLF
			cQuery +=                        " AND NRAa.D_E_L_E_T_ = ' ' " + CRLF
			cQuery +=                    " ) " + CRLF
		EndIf
		cQuery +=          " ) " + CRLF
	EndIf
	cQuery +=      " ) " + CRLF
	cQuery += " AND NX1.NX1_CPREFT = '" + cCodPre + "' " + CRLF
	cQuery += " AND NX1.NX1_CCLIEN = '" + cCliente + "' " + CRLF
	cQuery += " AND NX1.NX1_CLOJA = '" + cLoja + "' " + CRLF
	cQuery += " AND NX1.NX1_CCASO = '" + cCaso + "' " + CRLF
	cQuery += " AND NX1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " AND NX8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " AND NT0.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " AND NRA.D_E_L_E_T_ = ' ' "

	//Verifica se o caso do lançamento pertencente uma junção de contrato que não estão na pré-fatura
	cQuery += " UNION " + CRLF
	cQuery += " SELECT NUT.NUT_CCLIEN, NUT.NUT_CLOJA, NUT.NUT_CCONTR, NUT.NUT_CCASO " + CRLF
	cQuery += " FROM " + RetSqlName( "NUT" ) + " NUT, " + RetSqlName( "NW3" ) + " NW3 " + CRLF
	cQuery += " WHERE NUT.NUT_FILIAL = '" + xFilial("NUT") +"' " + CRLF
	cQuery += " AND NW3.NW3_FILIAL = '" + xFilial("NW3") +"' " + CRLF
	cQuery += " AND NUT.NUT_CCONTR = NW3.NW3_CCONTR " + CRLF
	cQuery += " AND NUT.NUT_CCLIEN = '" + cCliente + "' " + CRLF
	cQuery += " AND NUT.NUT_CLOJA = '" + cLoja + "' " + CRLF
	cQuery += " AND NUT.NUT_CCASO = '" + cCaso + "' " + CRLF
	cQuery += " AND NW3.NW3_CJCONT = '"+cJunc+"' " + CRLF
	cQuery += " AND NOT EXISTS ( SELECT NX1.R_E_C_N_O_ " + CRLF
	cQuery +=                   " FROM " + RetSqlName( "NX1" ) + " NX1 " + CRLF
	cQuery +=                   " WHERE NX1.NX1_FILIAL = '" + xFilial("NX1") +"' " + CRLF
	cQuery +=                     " AND NX1.NX1_CCLIEN = NUT.NUT_CCLIEN " + CRLF
	cQuery +=                     " AND NX1.NX1_CLOJA = NUT.NUT_CLOJA " + CRLF
	cQuery +=                     " AND NX1.NX1_CCASO = NUT.NUT_CCASO " + CRLF
	cQuery +=                     " AND NX1.NX1_CPREFT = '" + cCodPre + "' " + CRLF
	cQuery +=                     " AND NX1.D_E_L_E_T_ = ' ' ) " + CRLF
	cQuery += " AND NUT.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " AND NW3.D_E_L_E_T_ = ' ' " + CRLF

	aCaso := JurSQL(cQuery, {"NX1_CCLIEN", "NX1_CLOJA", "NX1_CCONTR", "NX1_CCASO"})

	// Tratamento para vigência de contratos
	If lCpoVig
		For nCas := 1 To Len(aCaso)
			aVigencia := JurGetDados("NX8", 1, xFilial("NX8") + NX0->NX0_COD + aCaso[nCas][3], {"NX8_DTVIGI", "NX8_DTVIGF"})
			If Empty(aVigencia) // Se o contrato não estiver na pré procura direto na NT0
				aVigencia := JurGetDados("NT0", 1, xFilial("NT0") + aCaso[nCas][3], {"NT0_DTVIGI", "NT0_DTVIGF"})
			EndIf
			If !Empty(aVigencia) .And. (Empty(aVigencia[1]) .Or. (dDataTS >= aVigencia[1] .And. dDataTS <= aVigencia[2]))
				Aadd(aCasoVig, aClone(aCaso[nCas]))
			EndIf
		Next nCas
	Else
		aCasoVig := aClone(aCaso)
	EndIf

	JurFreeArr(aCaso)

Return aCasoVig

//-------------------------------------------------------------------
/*/{Protheus.doc}  J202DTTS()
Rotina para validar se a data do TS esta dentro da data de referência da Pré-fatura
considerando também quando o TS for vinculado a uma pré-fatura de fixo

@author Luciano Pereira dos Santos
@since 11/06/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202DTTS(CodTS, cCodPre)
	Local aRet      := {}
	Local oTmpTable := Nil
	Local cAlsTmp   := ""
	Local lRet      := .F.

	aRet      := J202Filtro("NUE", CodTS, cCodPre)
	oTmpTable := aRet[1]
	cAlsTmp   := oTmpTable:GetAlias()
	lRet      := (cAlsTmp)->(! Eof())

	oTmpTable:Delete()
	JurFreeArr(aRet)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}  J202SetCan()
Funcao para setar a variavel estatica lCancPre por funcoes de fora
do fonte JURA202.prw (por exemplo TJurRevPreFat.prw)

@author Daniel Magalhaes
@since 06/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J202SetCan(lSet)
Default lSet := .F.

lCancPre := lSet

Return Nil

//-------------------------------------------------------------------
Function AddCampo( nTipo, cField, oStruct )
Local aArea     := GetArea()
Local aAux      := {}
Local aCombo    := {}
Local bPictVar
Local bRelac
Local bValid
Local bWhen
Local cGSC      := ""
Local nI        := 0
Local nInitCBox := 0
Local nMaxLenCb := 0
Local cCampo    := AllTrim(cField)
Local cValid    := ""
Local cWhen     := ""
Local cRelacao  := ""
Local cTitulo   := Alltrim(RetTitle(cCampo))
Local cDescri   := GetSx3Cache(cCampo, 'X3_DESCRIC')
Local cTipo     := ""
Local nTam      := 0
Local nDecimal  := 0
Local aCbox     := {}
Local lObrigat  := .F.
Local lVirtual  := GetSx3Cache(cCampo, 'X3_CONTEXT') == 'V'
Local cPictVar  := ""
Local cPicture  := ""
Local nOrdem    := 0
Local cF3       := ""
Local lVisual   := .T.
Local cFolder   := ""
Local cIniBrw   := ""

	If nTipo == 1

		cValid   := GetSx3Cache(cCampo, 'X3_VALID')
		cWhen    := GetSx3Cache(cCampo, 'X3_WHEN')
		cRelacao := GetSx3Cache(cCampo, 'X3_RELACAO')
		cTipo    := GetSx3Cache(cCampo, 'X3_TIPO')
		aCbox    := STRTOKARR(JurX3cBox(cCampo), ";")
		lObrigat := X3Obrigat(cCampo)
		nTam     := TamSx3(cCampo)[1]
		nDecimal := TamSx3(cCampo)[2]
		bValid   := FwBuildFeature( STRUCT_FEATURE_VALID , cValid   )
		bWhen    := FwBuildFeature( STRUCT_FEATURE_WHEN  , cWhen    )
		bRelac   := FwBuildFeature( STRUCT_FEATURE_INIPAD, cRelacao )

		oStruct:AddField( ;
		cTitulo         , ;              // [01] Titulo do campo
		cDescri         , ;              // [02] ToolTip do campo
		cCampo          , ;              // [03] Id do Field
		cTipo           , ;              // [04] Tipo do campo
		nTam            , ;              // [05] Tamanho do campo
		nDecimal        , ;              // [06] Decimal do campo
		bValid          , ;              // [07] Code-block de validação do campo
		bWhen           , ;              // [08] Code-block de validação When do campo
		aCbox           , ;              // [09] Lista de valores permitido do campo
		lObrigat        , ;              // [10] Indica se o campo tem preenchimento obrigatório
		bRelac          , ;              // [11] Code-block de inicializacao do campo
		Nil             , ;              // [12] Indica se trata-se de um campo chave
		Nil             , ;              // [13] Indica se o campo pode receber valor em uma operação de update.
		lVirtual        )                // [14] Indica se o campo é virtual

	ElseIf nTipo == 2

		cPictVar  := GetSx3Cache(cCampo, 'X3_PICTVAR')
		cPicture  := GetSx3Cache(cCampo, 'X3_PICTURE')
		nOrdem    := GetSx3Cache(cCampo, 'X3_ORDEM')
		cF3       := GetSx3Cache(cCampo, 'X3_F3')
		lVisual   := GetSx3Cache(cCampo, 'X3_VISUAL') <> 'V'
		cFolder   := GetSx3Cache(cCampo, 'X3_FOLDER')
		cIniBrw   := GetSx3Cache(cCampo, 'X3_INIBRW')

		If !( '_FILIAL' $ cField )
			aCombo := {}

			If !Empty( X3Cbox() )

				nInitCBox := 0
				nMaxLenCb := 0

				aAux := RetSX3Box( X3Cbox(), @nInitCBox, @nMaxLenCb, TamSx3( cField ) )

				For nI := 1 To Len( aAux )
					aAdd( aCombo, aAux[nI][1] )
				Next nI

			EndIf

			bPictVar := FwBuildFeature( STRUCT_FEATURE_PICTVAR, cPictVar )

			cGSC     := IIf( Empty( X3Cbox() ), IIf( cTipo == 'L', 'CHECK', 'GET' ), 'COMBO' )

			oStruct:AddField( ;
			cCampo          , ;                // [01] Campo
			nOrdem          , ;                // [02] Ordem
			cTitulo         , ;                // [03] Titulo
			cDescri         , ;                // [04] Descricao
			Nil             , ;                // [05] Help
			cGSC            , ;                // [06] Tipo do campo   COMBO, Get ou CHECK
			cPicture        , ;                // [07] Picture
			bPictVar        , ;                // [08] PictVar
			cF3             , ;                // [09] F3
			lVisual         , ;                // [10] Editavel
			cFolder         , ;                // [11] Folder
			cFolder         , ;                // [12] Group
			aCombo          , ;                // [13] Lista Combo
			nMaxLenCb       , ;                // [14] Tam Max Combo
			cIniBrw         , ;                // [15] Inic. Browse
			lVirtual     )                     // [16] Virtual

		EndIf
	EndIf

RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} __JurLoadValue
Faz LdValueByPos do campo, imita o comportamento da JurLoadValue,
Porem mais rapido por acessar diretamente os arrays.
@param oModel SubModel
@param nPosField Posição do campo, para determina-la utiliza GetArrayPos,
da estrutura do Model
@param xConteudo
@param lShowTela Mostra erro na tela

@author Rodrigo Antonio
@since 08/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function __JurLoadValue( oModel, nPosID, xConteudo, lShowTela)
Local lRet  := .T.
Local lMuda := .F.

If nPosID <=0
	lRet := .F.
Else
	If oModel:ClassName() == 'FWFORMGRID' .And. !oModel:CanUpdateLine()
		oModel:SetNoUpdateLine(.F.)
		lMuda:= .T.
	EndIf
		lRet := oModel:LdValueByPos( nPosID, xConteudo )
	If lMuda
		oModel:SetNoUpdateLine(.T.)
	EndIf

	If !lRet
		JurShowErro( oModel:GetModel():GetErrorMessage(), , , lShowTela )
	EndIf
EndIf

Return lRet

Static Function __InitPosNX2(oStruct)

If __aNX2PosFields == Nil
	__aNX2PosFields := oStruct:GetArrayPos({"NX2_CLTAB","NX2_TEMPOR","NX2_VALORH","NX2_CMOPRE","NX2_CMOTBH","NX2_HFCLI","NX2_UTR","NX2_HORAR",;
	"NX2_UTLANC","NX2_HFLANC","NX2_HRLANC","NX2_UTCLI","NX2_HRCLI","NX2_VLHTBH","NX2_VALOR1","NX2_CPART","NX2_CCATEG","NX2_CODSEQ"})
EndIf

Return

Static Function __NUEInitPos(oStruct)

If __aNUEPosFields == Nil
	__aNUEPosFields := oStruct:GetArrayPos({"NUE_CPART2","NUE_CCATEG","NUE_VALORH","NUE_CLTAB","NUE_CMOEDA","NUE_COD","NUE_SITUAC","NUE_VALOR",;
	"NUE_VALOR1","NUE_CATIVI","NUE_TEMPOR","NUE_HORAR","NUE_CCLIEN","NUE_CLOJA","NUE_CCASO","NUE_CMOED1","NUE_UTR","NUE_UTL","NUE_TEMPOL","NUE_CPREFT",;
	"NUE_CPART1", "NUE_TKRET" })
EndIf

Return

Static Function __NX1InitPos(oStruct, lShowVirt)

If __aNX1PosFields == Nil
	If lShowVirt
		__aNX1PosFields := oStruct:GetArrayPos({"NX1_VTS","NX1_VTAB","NX1_VTSTAB","NX1_VDESCO","NX1_VDESCT","NX1_CCLIEN","NX1_CLOJA","NX1_DCLIEN","NX1_CCONTR","NX1_DCONTR","NX1_CCASO","NX1_DCASO"})
	Else
		__aNX1PosFields := oStruct:GetArrayPos({"NX1_VTS","NX1_VTAB","NX1_VTSTAB","NX1_VDESCO","NX1_VDESCT","NX1_CCLIEN","NX1_CLOJA","NX1_CCONTR","NX1_CCASO"})
	EndIf
EndIf

Return

Static Function __NV4InitPos(oStruct)

If __aNV4PosFields == Nil
	__aNV4PosFields := oStruct:GetArrayPos({'NV4_COD',"NV4_CMOEH","NV4_VLHFAT",'NV4_CTPSRV'})
EndIf

Return

Static Function __NX0InitPos(oStruct, lShowVirt)

If __aNX0PosFields == Nil
	If lShowVirt
		__aNX0PosFields := oStruct:GetArrayPos({"NX0_CMOEDA","NX0_DMOEDA","NX0_DTEMI","NX0_COD", "NX0_ALTPER"})
	Else
		__aNX0PosFields := oStruct:GetArrayPos({"NX0_CMOEDA","NX0_DTEMI","NX0_COD", "NX0_ALTPER"})
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J202TSLOTE()
Função para abrir a tela de Ações em Lote do TS

@author Jacques Alves Xavier
@since 11/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202TSLOTE(oModel, oView, cCodPre)
Local lRet      := .T.
Local lExibAnt  := __lExibeOK

If lRet := oModel:VldData()
	__lExibeOK := .F.
	If oModel:lModify   // necessário pois se o modelo não foi alterado o commit retorna .F.
		lRet := oModel:CommitData()  //CH THPIZ3 Confirmar modelo de dados para não perder as alterações anteriores a operação
	EndIf
	If lRet
		JURA145(cCodPre)
		dbSelectArea('NX0')
		oModel:Deactivate()
		oModel:Activate()
		oView:Refresh()
	EndIf
	__lExibeOK := lExibAnt
Else
	JurShowErro( oModel:GetModel():GetErrormessage() )
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}  J202HIST()
Função para inserir histórico na pre-fatura

@Param cTipo     , Situacao do historico da pre-fatura
                   1  - Emissao/atualizacao da pre-fatura
                   2  - Alteracao para definitivo
                   3  - Emissao de minuta
                   4  - Emissao de fatura
                   5  - Cancelamento da pre-fatura
                   6  - Reativação da pre-fatura pelo cancelamento da fatura
                   7  - Desbloqueio da pre-fatura em revisao
                   8  - Aprovacao de Minuta
                   99 - Outras situacoes, neste caso passar a mensagem a ser
                        colocada na observacao do historico
@param cCodPre   , Codigo da pre-fatura
@param cCPART    , Codigo do participante
@param cMSG      , Mensagem do historico
@param cTipoHist , Tipo de historico da pre-fatura
                   1 - Emissao/atualizacao
                   2 - Envio p/ revisao
                   3 - Alter. revisor
                   4 - Revisão concluida
                   5 - Cancelam./Subst.
                   6 - Fatura emitida
                   7 - Outras alt.
                   8 - Aprov. de Minuta
@param cDataRest , Informacao do retorno da revisao
@param lNx4CPart1, Indica se existe o campo NX4_CPART1
@param cPart1    , Codigo do participante 1
@param cNx4Part  , Codigo do participante ou usuario logado
@param cPswChave , Nome do usuario logado
@param lRevLD    , Indica se a alteracao esta sendo feita via revisao de pre-fatura no LD
@param cFilNX4   , Filial da NX4

@author Jacques Alves Xavier
@since  22/10/2012
/*/
//-------------------------------------------------------------------
Function J202HIST(cTipo, cCodPre, cCPART, cMSG, cTipoHist, cDataRest, lNx4CPart1, cPart1, cNx4Part, cPswChave, lRevLD, cFilNX4)
Local aArea       := GetArea()
Local cDescri     := ''
Local lRet        := .T.
Local cSeq        := ""

Default cMSG       := ""
Default cTipoHist  := ""
Default cDataRest  := ""
Default lNx4CPart1 := NX4->(ColumnPos("NX4_CPART1")) > 0 //Proteção 12.1.33
Default lRevLD     := (SuperGetMV("MV_JFSINC",.F.,'2') == '1') .And. (SuperGetMV("MV_JREVILD",.F.,'2') == '1' ) .And. JurIsRest()
Default cPart1     := IIf(lNx4CPart1, JurUsuario(__cUserId), "") 
Default cNx4Part   := IIf(lRevLD, JurGetDados('NX0', 1, xFilial('NX0') + cCodPre, 'NX0_CPART'), cCPART)
Default cPswChave  := PswChave(__CUSERID)
Default cFilNX4    := xFilial("NX4")

	Do Case
		Case cTipo == '1'
			cDescri := STR0215 //"Emissão/atualização da pré-fatura"
			cTipoHist := cTipo
		Case cTipo == "2"
			cDescri := STR0216 //"Alteração para definitivo"
			cTipoHist := "7"
		Case cTipo == "3"
			cDescri := STR0217 //"Emissão de minuta"
			cTipoHist := "7"
		Case cTipo == "4"
			If Empty(cMSG)
				cDescri := STR0218 //"Emissão de fatura"
			Else
				cDescri := cMSG   //No. FATURA: 99999999 - conforme modelo usado pelo Legal Desk
			EndIf
			cTipoHist := "6"
		Case cTipo == "5"
			If Empty(cMSG)
				cDescri := STR0219 //"Cancelamento da pré-fatura"
			Else
				cDescri := cMSG
			EndIf
			cTipoHist := cTipo
		Case cTipo == "6"
			cDescri := STR0220 //"Reativação da pré-fatura pelo cancelamento da fatura"
		Case cTipo == "7"
			cDescri := STR0301 // "Desbloqueio da pré-fatura que estava em processo de Revisão."
		Case cTipo == "8"
			cDescri := STR0358 // "Aprovação de minuta"
			cTipoHist := "8"
		Case cTipo == "99"
			cDescri := cMSG
	EndCase

	Iif(Empty(cTipoHist), cTipoHist := "7",)
	cSeq := GetSXENum('NX4', 'NX4_COD')
	If __lSX8
		ConfirmSX8()
	EndIf
	RecLock("NX4", .T.)
	NX4->NX4_FILIAL := cFilNX4
	NX4->NX4_COD    := cSeq
	NX4->NX4_CPREFT := cCodPre
	NX4->NX4_DTINC  := Date()
	NX4->NX4_HRINC  := Time()
	NX4->NX4_HIST   := cDescri
	NX4->NX4_USRINC := cPswChave
	NX4->NX4_CPART  := cNx4Part
	NX4->NX4_AUTO   := "1"
	NX4->NX4_TIPO   := cTipoHist //1=Emissão/atualização;2=Envio p/ revisão;3=Alter. revisor;4=Revisão concluída;5=Cancelam./Subst.;6=Fatura emitida;7=Outras alt.;8=Aprov. de Minuta

	If NX4->(ColumnPos("NX4_CREST")) > 0 //Proteção 12.1.23
		NX4->NX4_CREST  := cDataRest
	EndIf
	If lNx4CPart1 //Proteção 12.1.33
		NX4->NX4_CPART1 := cPart1
	EndIf

	NX4->(MsUnlock())
	NX4->(DbCommit())

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202NX4TIP()
Retorna os Tipos de Histórico que serão utilizados no CBOX do NX4_TIPO

@author Willian Yoshiaki Kazahaya
@since 07/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function J202NX4TIP()
Local cRet := ""
	cRet += STR0359 // 1=Emissão/Atualização;
	cRet += STR0360 // 2=Envio para revisão;
	cRet += STR0361 // 3=Alteração do revisor;
	cRet += STR0362 // 4=Revisão concluída;
	cRet += STR0363 // 5=Cancelam./Substituido;
	cRet += STR0364 // 6=Fatura emitida;
	cRet += STR0365 // 7=Outras alterações;
	cRet += STR0366 // 8=Aprovação de Minuta;
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202ValLan()
Valida se o desdobramento vinculado a despesa é passível de alterações

@author Felipe Bonvicini Conti
@since 29/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202ValLan(oModel)
Local lRet       := .T.
Local aSaveLn    := FwSaveRows()
Local aArea      := GetArea()
Local oModelNX8  := oModel:GetModel('NX8DETAIL') // Contratos
Local oModelNX1  := oModel:GetModel('NX1DETAIL') // Casos
Local oModelNVY  := oModel:GetModel('NVYDETAIL') // Despesas
Local nNX8       := 0
Local nNX1       := 0 
Local aLines     := {}
Local nI         := 0
Local aLancs     := {}
Local lJurxFin   := SuperGetMv("MV_JURXFIN",, .F.) //Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico

	If lJurxFin
		For nNX8 := 1 To oModelNX8:GetQtdLine()
			oModelNX8:GoLine(nNX8)
			For nNX1 := 1 To oModelNX1:GetQtdLine()
				oModelNX1:GoLine(nNX1)

				aLines := oModelNVY:GetLinesChanged()
				For nI := 1 To Len(aLines)
					oModelNVY:GoLine(aLines[nI])
					// Verifica se alguma despesa ou tabelado foi alterado para não cobrar e marca o _TKRET.
					lRet := J202NCobra(oModel, "NVY", aLines[nI], nNX8, nNX1, @aLancs)	

					// Validar o desdobramento vinculado a despesa é passível de alterações
					lRet := J202VlDsdb(oModelNVY, aLines[nI])

					If !lRet
						Exit
					EndIf
				Next

				If !lRet
					Exit
				EndIf
			Next

			If !lRet
				Exit
			EndIf
		Next
	EndIf

	If lRet .And. !Empty(aLancs)
		lRet := JA202LFatu( aLancs )
		If lRet
			lRet := JA202TotPre(Nil)
		EndIf
	EndIf

	FwRestRows(aSaveLn)
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202VlDsdb()
Função para validar o desdobramento vinculado a despesa é passível de alterações

@author bruno.ritter
@since 07/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202VlDsdb(oModelNVY, nLine, lTransLote)
Local lRet         := .T.
Local cChaveSE2    := ""
Local oModelDsdb   := Nil
Local aErro        := {}
Local cTtlNVYCod   := ""
Local cNVYCod      := ""
Local cCdCtaPag    := ""
Local cTitulo      := ""
Local cItem        := ""
Local nRecno       := 0
Local lDespAlter   := .F.

Default lTransLote := .F.

If NVY->(ColumnPos("NVY_CPAGTO")) > 0 .And. FindFunction("JURA246") .And. FindFunction("JURA247")//Proteção
	//Não foi usado o IsFieldUpdated para validar a alteração da linha, pois se o usuário voltar o valor original do campo, o IsFieldUpdated ainda retorna que o campo foi alterado.
	If !oModelNVY:IsDeleted(nLine);
		.And. !Empty(oModelNVY:GetValue("NVY_CPAGTO", nLine));
		.And. (!Empty(oModelNVY:GetValue("NVY_ITDES", nLine)) .Or. !Empty(oModelNVY:GetValue("NVY_ITDPGT", nLine)))

		If lTransLote
			lDespAlter := .T.
		Else
			nRecno := oModelNVY:GetDataId(nLine)
			NVY->(DbGoto(nRecno))
			lDespAlter := NVY->NVY_DESCRI != oModelNVY:GetValue('NVY_DESCRI', nLine);
						.Or. NVY->NVY_COBRAR != oModelNVY:GetValue('NVY_COBRAR', nLine);
						.Or. NVY->NVY_CCLILD != oModelNVY:GetValue('NVY_CCLILD', nLine);
						.Or. NVY->NVY_CLJLD  != oModelNVY:GetValue('NVY_CLJLD' , nLine);
						.Or. NVY->NVY_CCSLD  != oModelNVY:GetValue('NVY_CCSLD' , nLine)
		EndIf

		If lDespAlter //Se a despesa foi alterada ou não é necessário validar a alteração (transferência)
			cChaveSE2   := StrTran(oModelNVY:GetValue("NVY_CPAGTO", nLine), "|", "")
			SE2->(DbSetOrder(1)) // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
			If SE2->(DbSeek( cChaveSE2 ))

				If !Empty(oModelNVY:GetValue("NVY_ITDES", nLine))
					oModelDsdb := FWLoadModel("JURA246") // Desdobramento Financeiro
					cItem      := AllTrim(oModelNVY:GetValue("NVY_ITDES", nLine))
					cTitulo    := AllTrim(RetTitle("OHF_CITEM"))
				Else
					oModelDsdb := FWLoadModel("JURA247") // Desdobramento Pós Pagamento
					cItem      := AllTrim(oModelNVY:GetValue("NVY_ITDPGT", nLine))
					cTitulo    := AllTrim(RetTitle("OHG_CITEM"))
				EndIf
				oModelDsdb:SetOperation(MODEL_OPERATION_UPDATE)

				lRet := oModelDsdb:CanActivate()
				If !lRet .And. !lTransLote
					cTtlNVYCod := AllTrim(RetTitle("NVY_COD"))
					cNVYCod    := AllTrim(oModelNVY:GetValue("NVY_COD", nLine))
					cCdCtaPag  := AllTrim(oModelNVY:GetValue("NVY_CPAGTO", nLine))

					aErro := oModelDsdb:GetErrorMessage()
					// "A despesa '#1' = '#2' não pode ser alterada,  pois não foi possível alterar o desdobramento '#3', '#4' = '#5', que está vinculado na despesa."
					JurMsgErro(i18n(STR0299, {cTtlNVYCod, cNVYCod, cCdCtaPag, cTitulo, cItem }) +;
					                 CRLF + aErro[6],, aErro[7])
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return lRet

/*{Protheus.doc} J202NCobra()
Função para buscar as despesas que foram alteradas
para não cobrar e marcar o TKRET para serem retirados da pré-fatura.

@obs Passar o aLancs como referência

@author Felipe Bonvicini Conti
@since 29/10/2012
@version 1.0
*/
//-------------------------------------------------------------------
Static Function J202NCobra(oModel, cTab, nLine, nNX8, nNX1, aLancs)
Local oModelNVY := oModel:GetModel('NVYDETAIL') // Despesas
Local cCod      := ""
Local cPreft    := ""
Local cSituac   := ""
Local lRet      := .T.

If (oModelNVY:GetValue("NVY_COBRAR", nLine) == "2");
	.And. (lRet := JA049OBS(nLine)) //Retira a despesa cobrar=Não da pré-fatura

	cCod    := oModelNVY:GetValue("NVY_COD")
	cPreft  := oModelNVY:GetValue("NVY_CPREFT")
	cSituac := oModelNVY:GetValue("NVY_SITUAC")

	lRet := J202LoadVl(oModelNVY, "NVY_CPREFT", '' )
	Aadd( aLancs, { "NVY", ;
					1, ;
					cCod, ;
					oModel, ;
					{nNX8, nNX1, nLine},  ;
					"NVZ", ;
					1, ;
					xFilial("NVZ")+cCod+cSituac+cPreft,;
					.F.,;
					.T. /*retirar*/;
					})
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ReposModel
Rotina para devolver o grid ao registro dependendo da operação realizada
na rotina de operações de pré-fatura

@Params		oMoldel  modelo de dados da pré-fatura
@Params		aReposic posisão dos elementos do modelo
				[1] contrato
				[2] caso
				[3] participante
				[4] Time Sheet
				[5] Despesa
				[6] Tabelado
				[7] Fixo

@Return		Nil

@author Luciano Pereira dos santos
@since 31/10/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReposModel(oModel, aReposic )
Local oModelNX8 := oModel:GetModel( 'NX8DETAIL' )
Local oModelNT1 := oModel:GetModel( 'NT1DETAIL' )
Local oModelNX1 := oModel:GetModel( 'NX1DETAIL' )
Local oModelNX2 := oModel:GetModel( 'NX2DETAIL' )
Local oModelNUE := oModel:GetModel( 'NUEDETAIL' )
Local oModelNVY := oModel:GetModel( 'NVYDETAIL' )
Local oModelNV4 := oModel:GetModel( 'NV4DETAIL' )

Default aReposic := Array(7)

If !Empty(aReposic[1]) .And. (aReposic[1] <= oModelNX8:Length())
	oModelNX8:GoLine(aReposic[1])
	If !Empty(aReposic[2]) .And. (aReposic[2] <= oModelNX1:Length())
		oModelNX1:GoLine(aReposic[2])
		If !Empty(aReposic[3]) .And. (aReposic[3] <= oModelNX2:Length())
			oModelNX2:GoLine(aReposic[3])
		EndIf
		If !Empty(aReposic[4]) .And. (aReposic[4] <= oModelNUE:Length())
			oModelNUE:GoLine(aReposic[4])
		EndIf
		If !Empty(aReposic[5]) .And. (aReposic[5] <= oModelNVY:Length())
			oModelNVY:GoLine(aReposic[5])
		EndIf
		If !Empty(aReposic[6]) .And. (aReposic[6] <= oModelNV4:Length())
			oModelNV4:GoLine(aReposic[6])
		EndIf
	EndIf
	If !Empty(aReposic[7]) .And. (aReposic[7] <= oModelNT1:Length())
		oModelNT1:GoLine(aReposic[7])
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JANX0_VTS()
Rotina de chamada para recalculo da alteração por período da Pré-fatura
(Valid do campo NX0_VTS)

@Return		lRet 	.T. se a alteração teve êxito.

@author David Gonsalves Fernandes
@since 01/01/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JANX0_VTS()
Local lRet       := .T.
Local oModel     := FwModelActive()
Local oModelNX0  := oModel:GetModel("NX0MASTER")
Local cAltPer    := oModelNX0:GetValueByPos(__aNX0PosFields[POS_NX0_ALTPER])
Local cPreFat    := oModelNX0:GetValueByPos(__aNX0PosFields[POS_NX0_COD])
Local lTela      := !IsBlind()

	If lTela .And. !Empty(cAltPer)
		J202SCorte(oModel, "NUE", cPreFat) // Seta variáveis estáticas usadas na rotina de corte
	EndIf

	Do Case
		Case cAltPer == "1"
			If lTela
				__oProcess := MsNewProcess():New({|| __InMsgRun := .T., lRet := JANX0_VTS1(oModel, .T.), __InMsgRun := .F.}, STR0147, STR0167, .T.) //  #"Aguarde..." ##"Atualizando Lançamentos"
				__oProcess:Activate()
			Else
				JANX0_VTS1(oModel)
			EndIf

		Case cAltPer == "2"
			If lTela
				__oProcess := MsNewProcess():New({|| __InMsgRun := .T., lRet := JANX0_VTS2(oModel, .T.), __InMsgRun := .F.}, STR0147, STR0167, .T.) //  #"Aguarde..." ##"Atualizando Lançamentos"
				__oProcess:Activate()
			Else
				JANX0_VTS2(oModel)
			EndIf

		Case cAltPer == "3"
			If lTela
				__oProcess := MsNewProcess():New({|| __InMsgRun := .T., lRet := JANX0_VTS3(oModel, .T.), __InMsgRun := .F.}, STR0147, STR0167, .T.) //  #"Aguarde..." ##"Atualizando Lançamentos"
				__oProcess:Activate()
			Else
				JANX0_VTS3(oModel)
			EndIf

		OtherWise
			lRet := JurMsgErro(STR0177) // "Escolha um tipo de ajuste antes de alterar o valor!"

	EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JANX8_VTS()
Rotina de chamada para recalculo da alteração por período dos contratos
da Pré-fatura (Valid do campo NX8_VTS)

@Params	    nil

@Return		lRet 	.T. se a alteração teve Ãªxito.

@author David Gonsalves Fernandes
@since 01/01/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JANX8_VTS()
Local lRet       := .T.
Local oModel     := FwModelActive()
Local oModelNX0  := oModel:GetModel("NX0MASTER")
Local cAltPer    := oModelNX0:GetValueByPos(__aNX0PosFields[POS_NX0_ALTPER])
Local cContr     := oModel:GetModel("NX8DETAIL"):GetValue("NX8_CCONTR")
Local cPreFat    := oModel:GetModel("NX8DETAIL"):GetValue("NX8_CPREFT")
Local lTela      := !IsBlind()

	If !__InMsgRun .And. lTela .And. !Empty(cAltPer)
		J202SCorte(oModel, "NUE", cPreFat, cContr) // Seta variáveis estáticas usadas na rotina de corte
	EndIf

	Do Case
		Case cAltPer == "1"
			If !__InMsgRun .And. lTela
				__oProcess := MsNewProcess():New({|| __InMsgRun := .T., lRet := JANX8_VTS1(oModel, .T., lTela), __InMsgRun := .F.}, STR0147, STR0167, .T.) // #"Aguarde..." ##"Atualizando Lançamentos"
				__oProcess:Activate()
			Else
				lRet := JANX8_VTS1(oModel, .F., lTela)
			EndIf

		Case cAltPer == "2"
			If !__InMsgRun .And. lTela
				__oProcess := MsNewProcess():New({|| __InMsgRun := .T., lRet := JANX8_VTS2(oModel, .T., lTela), __InMsgRun := .F.}, STR0147, STR0167, .T.) // #"Aguarde..." ##"Atualizando Lançamentos"
				__oProcess:Activate()
			Else
				lRet := JANX8_VTS2(oModel, .F., lTela)
			EndIf

		Case cAltPer == "3"
			If !__InMsgRun .And. lTela
				__oProcess := MsNewProcess():New({|| __InMsgRun := .T., lRet := JANX8_VTS3(oModel, .T., lTela), __InMsgRun := .F.}, STR0147, STR0167, .T.) // #"Aguarde..." ##"Atualizando Lançamentos"
				__oProcess:Activate()
			Else
				lRet := JANX8_VTS3(oModel, .F., lTela)
			EndIf

		OtherWise
			lRet := JurMsgErro(STR0177) // "Escolha um tipo de ajuste antes de alterar o valor!"

	EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JANX1_VTS()
Rotina de chamada para recalculo da alteração por período dos casos
da Pré-fatura (Valid do campo NX1_VTS)

@Params	    nil

@Return		lRet 	.T. se a alteração teve Ãªxito.

@author David Gonsalves Fernandes
@since 01/01/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JANX1_VTS()
Local lRet      := .T.
Local oModel    := FwModelActive()
Local oModelNX0 := oModel:GetModel("NX0MASTER")
Local cAltPer   := oModelNX0:GetValueByPos(__aNX0PosFields[POS_NX0_ALTPER])
Local cCliente  := ""
Local cLoja     := ""
Local cCaso     := ""
Local cPreFat   := ""
Local lTela     := !IsBlind()

	If !__InMsgRun .And. lTela .And. !Empty(cAltPer)

		cCliente  := oModel:GetModel("NX1DETAIL"):GetValue("NX1_CCLIEN")
		cLoja     := oModel:GetModel("NX1DETAIL"):GetValue("NX1_CLOJA")
		cCaso     := oModel:GetModel("NX1DETAIL"):GetValue("NX1_CCASO")
		cPreFat   := oModel:GetModel("NX1DETAIL"):GetValue("NX1_CPREFT")

		J202SCorte(oModel, "NUE", cPreFat, "" /*cContr*/, cCliente, cLoja, cCaso) // Seta variáveis estáticas usadas na rotina de corte
	EndIf

	Do Case
		Case cAltPer == "1"
			If !__InMsgRun .And. lTela
				__oProcess := MsNewProcess():New({|| __InMsgRun := .T., lRet := JANX1_VTS1(oModel, .T., lTela), __InMsgRun := .F.}, STR0147, STR0167, .T.) // #"Aguarde..." ##"Atualizando Lançamentos"
				__oProcess:Activate()
			Else
				lRet := JANX1_VTS1(oModel, .F., lTela)
			EndIf

		Case cAltPer == "2"
			If !__InMsgRun .And. lTela
				__oProcess := MsNewProcess():New({|| __InMsgRun := .T., lRet := JANX1_VTS2(oModel, .T., lTela), __InMsgRun := .F.}, STR0147, STR0167, .T.) // #"Aguarde..." ##"Atualizando Lançamentos"
				__oProcess:Activate()
			Else
				lRet := JANX1_VTS2(oModel, .F., lTela)
			EndIf

		Case cAltPer == "3"
			If !__InMsgRun .And. lTela
				__oProcess := MsNewProcess():New({|| __InMsgRun := .T., lRet := JANX1_VTS3(oModel, .T., lTela), __InMsgRun := .F.}, STR0147, STR0167, .T.) // #"Aguarde..." ##"Atualizando Lançamentos"
				__oProcess:Activate()
			Else
				lRet := JANX1_VTS3(oModel, .F., lTela)
			EndIf

		OtherWise
			lRet := JurMsgErro(STR0177) // "Escolha um tipo de ajuste antes de alterar o valor!"

	EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JANX2_VTS()
Rotina de chamada para recalculo da alteração por período dos lançamentos
do participante do caso da Pré-fatura (Valid do campo NX2_VALOR1)

@Params	    nil

@Return		lRet 	.T. se a alteração teve Ãªxito.

@author David Gonsalves Fernandes
@since 01/01/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JANX2_VTS()
Local lRet      := .T.
Local oModel    := FwModelActive()
Local oModelNX0 := oModel:GetModel("NX0MASTER")
Local oModelNX2 := oModel:GetModel("NX2DETAIL")
Local cClient   := oModelNX2:GetValue("NX2_CCLIEN")
Local cLoja     := oModelNX2:GetValue("NX2_CLOJA")
Local cCaso     := oModelNX2:GetValue("NX2_CCASO")
Local cContr    := oModelNX2:GetValue("NX2_CCONTR")
Local nPosAlt   := 0
Local cAltPer   := oModelNX0:GetValueByPos(__aNX0PosFields[POS_NX0_ALTPER])

	nPosAlt := aScan( aAltPend, {|x| x[1] == 'TS' .And. x[2] == cClient .And. x[3] == cLoja .And. x[4] == cCaso .And. x[5] == cContr })

	If nPosAlt > 0
		lRet := JurMsgErro(STR0170) //"Existem alterações de valor pendentes, para efetuar novas alterações cancele as anteriores!"
	EndIf

	If lRet
		Do Case
			Case cAltPer == "1"
				If !__InMsgRun
					FWMsgRun(, {|| __InMsgRun := .T., lRet := JANX2_VTS1(), __InMsgRun := .F.}, STR0147, STR0167) // #"Aguarde..." ##"Atualizando Lançamentos"
				Else
					lRet := JANX2_VTS1()
				EndIf

			Case cAltPer == "2"
				If !__InMsgRun
					FWMsgRun(, {|| __InMsgRun := .T., lRet := JANX2_VTS2(), __InMsgRun := .F.}, STR0147, STR0167) // #"Aguarde..." ##"Atualizando Lançamentos"
				Else
					lRet := JANX2_VTS2()
				EndIf

			Case cAltPer == "3"
				If !__InMsgRun
					FWMsgRun(, {|| __InMsgRun := .T., lRet := JANX2_VTS3(), __InMsgRun := .F.}, STR0147, STR0167) // #"Aguarde..." ##"Atualizando Lançamentos"
				Else
					lRet := JANX2_VTS3()
				EndIf

			OtherWise
				lRet := JurMsgErro(STR0177) // "Escolha um tipo de ajuste antes de alterar o valor!"

		EndCase
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JANUE_VTS()
Rotina de chamada para recalculo da alteração por período dos lançamentos
do caso da Pré-fatura (Valid do campo NUE_VALOR1)

@Params	    nil

@Return		lRet 	.T. se a alteração teve Ãªxito.

@author David Gonsalves Fernandes
@since 01/01/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JANUE_VTS()
Local lRet      := .T.
Local oModel    := FwModelActive()
Local oModelNX0 := Nil
Local oModelNUE := Nil
Local cAltPer   := ""

	If oModel:GetId() == "JURA202"
		oModelNX0   := oModel:GetModel("NX0MASTER")
		oModelNUE   := oModel:GetModel("NUEDETAIL")
		cAltPer     := oModelNX0:GetValueByPos(__aNX0PosFields[POS_NX0_ALTPER])

		//Valida a alteracao em um TS removido ou dividido pelas alteracoes de periodo.
		If Empty(oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CPREFT])) .Or. J202VldDiv("NUE_CODPAI", oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_COD]))
			lRet := JurMsgErro(STR0170) //"Existem alterações de valor pendentes, para efetuar novas alterações confirme ou cancele as anteriores!"
		EndIf

		If lRet .And. __ReadVar $ 'M->NUE_VALOR1'
			If !__InMsgRun
				FWMsgRun(, {|| __InMsgRun := .T., lRet := JANUE_VTS1(), __InMsgRun := .F.}, STR0147, STR0167) // #"Aguarde..." ##"Atualizando Lançamentos"
			Else
				lRet := JANUE_VTS1()
			EndIf
		EndIf

	EndIf

Return lRet

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                FUNÇÕES ALTERAÇÃO POR PERIODO OPÇÃO 1= "TEMPO" - INICIO                               //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Static Function JANX0_VTS1(oModel, lNewProcess)
Local lRet          := .T.
Local nPos          := 0
Local oModelNX0     := Nil
Local oModelNX8     := Nil
Local nVlrPre       := 0
Local nAjuste       := 0
Local nSaldo        := 0
Local nI            := 0
Local nVlrContr     := 0
Local nMaiorVl      := 0
Local nMaiorContr   := 0
Local nLineNX8      := 0
Local nDifVlr       := 0
Local nTotTs        := 0
Local nQtdNX8       := 0
Local nDecNX8VTS    := 0
Local nDecNX8VHn    := 0

Default oModel      := FwModelActive()
Default lNewProcess := .F.

	If lNewProcess
		__oProcess:SetRegua1(__nQtdNX1)
		__oProcess:SetRegua2(__nQtdNUE)
	EndIf

	oModelNX0 := oModel:GetModel("NX0MASTER")
	oModelNX8 := oModel:GetModel("NX8DETAIL")

	For nPos := 1 To Len(aCasos)
		nVlrPre += aCasos[nPos][6]
	Next nPos

	nSaldo      := oModelNX0:GetValue( "NX0_VTS" )
	nAjuste     := nSaldo / nVlrPre

	nLineNX8    := oModelNX8:nLine
	nMaiorVl    := oModelNX8:GetValue("NX8_VTS")
	nMaiorContr := nLineNX8
	nQtdNX8     := oModelNX8:Length()
	nDecNX8VTS  := TamSX3("NX8_VTS")[2]
	nDecNX8VHn  := TamSX3("NX8_VHON")[2]

	For nI := 1 to nQtdNX8

		If oModelNX8:GetValue("NX8_TS", nI) == "1"

			oModelNX8:goLine(nI)

			nVlrContr := oModelNX8:GetValue("NX8_VTS")

			If nVlrContr > nMaiorVl
				nMaiorVl    := nVlrContr
				nMaiorContr := nI
			EndIf
			nDifVlr := (nVlrContr * nAjuste) - nVlrContr
			nTotTs  += (nVlrContr * nAjuste)
			lRet    := lRet .And. JurSetValue( oModelNX8, "NX8_VTS",, Round(nVlrContr * nAjuste, nDecNX8VTS )  )
			nSaldo  := nSaldo - oModelNX8:GetValue("NX8_VTS")

			lRet := lRet .And. JurLoadValue( oModelNX8, "NX8_VHON",, Round(oModelNX8:GetValue("NX8_VHON") + nDifVlr, nDecNX8VHn )  )

			lRet := lRet .And. J202DivCas("NX8") // Ajusta o rateio no campo NX1_VHON
		EndIf

	Next

	If !(nSaldo == 0)
		oModelNX8:goLine(nMaiorContr)
		nVlrContr := oModelNX8:GetValue("NX8_VTS")
		lRet := lRet .And. JurSetValue( oModelNX8, "NX8_VTS",, Round(nVlrContr + nSaldo, nDecNX8VTS )  )
	EndIf

	lRet := lRet .And. JurLoadValue( oModelNX0, "NX0_VLFATH",, Round( oModelNX0:GetValue("NX0_VLFATH") - nVlrPre + nTotTs, (TamSX3("NX0_VLFATH")[2]) )  )

	//Atualiza dos descontos na Pré-Fatura
	lRet := lRet .And. J202DescPre()

	oModelNX8:goLine(nLineNX8)

Return lRet

Static Function JANX8_VTS1(oModel, lNewProcess, lTela)
Local lRet          := .T.
Local nPos          := 0
Local oModelNX0     := Nil
Local oModelNX8     := Nil
Local oModelNX1     := Nil
Local nVlrContr     := 0
Local nAjuste       := 0
Local nSaldoTS      := 0
Local nSomaDesc     := 0
Local nI            := 0
Local nVlCaso       := 0
Local nMaiorVl      := 0
Local nMaiorCont    := 0
Local nLineNX1      := 0
Local nDifVlr       := 0
Local nQtdNX1       := 0
Local nDecNX1VTs    := 0
Local cContr        := ""

Default oModel      := FwModelActive()
Default lNewProcess := .F.
Default lTela       := .F.

	If lNewProcess
		__oProcess:SetRegua1(__nQtdNX1)
		__oProcess:SetRegua2(__nQtdNUE)
	EndIf

	oModelNX0 := oModel:GetModel("NX0MASTER")
	oModelNX8 := oModel:GetModel("NX8DETAIL")
	oModelNX1 := oModel:GetModel("NX1DETAIL")

	cContr := oModelNX8:GetValue("NX8_CCONTR")

	For nPos := 1 To Len(aCasos)
		If aCasos[nPos][9] == cContr
			nVlrContr += aCasos[nPos][6]
		EndIf
	Next nPos

	nSaldoTS    := oModelNX8:GetValue( "NX8_VTS" )
	nAjuste     := nSaldoTS / nVlrContr
	nDifVlr     := nSaldoTS - nVlrContr

	nLineNX1    := oModelNX1:nLine
	nMaiorVl    := oModelNX1:GetValue("NX1_VTS")
	nMaiorCont  := nLineNX1
	nQtdNX1     := oModelNX1:Length()
	nDecNX1VTs  := TamSX3("NX1_VTS")[2]

	For nI := 1 To nQtdNX1

		If lTela
			__oProcess:IncRegua1(i18n(STR0331, {oModelNX1:GetValue("NX1_CCASO", nI), __nCountNX1++, __nQtdNX1} )) // "Atualizando Caso #1 - #2 de #3."
		EndIf

		If oModelNX1:GetValue("NX1_TS", nI) == "1"

			oModelNX1:goLine(nI)

			nVlCaso := oModelNX1:GetValue("NX1_VTS")

			If nVlCaso > nMaiorVl
				nMaiorVl   := nVlCaso
				nMaiorCont := nI
			EndIf

			lRet      := lRet .And. JurSetValue( oModelNX1, "NX1_VTS",, Round(nVlCaso * nAjuste, nDecNX1VTs ) )
			nSaldoTS  := nSaldoTS - oModelNX1:GetValue("NX1_VTS")
			nSomaDesc := oModelNX1:GetValue("NX1_VLDESC")

		EndIf

	Next

	If !(nSaldoTS == 0)
		oModelNX1:goLine(nMaiorCont)
		nVlCaso := oModelNX1:GetValue("NX1_VTS")
		lRet := lRet .And. JurSetValue( oModelNX1, "NX1_VTS",, Round(nVlCaso + nSaldoTS, nDecNX1VTs )  )
	EndIf

	oModelNX1:goLine(nLineNX1)

	lRet := lRet .And. J202DescContr()
	lRet := lRet .And. J202DivCas("NX8") // Ajusta o rateio no campo NX1_VHON

	//Se for a alteração do próximo NX8_VTS
	If !IsInCallStack("JANX0_VTS")
		lRet := lRet .And. JurLoadValue( oModelNX0, "NX0_VTS",, Round( oModelNX0:GetValue("NX0_VTS") + nDifVlr, (TamSX3("NX0_VTS")[2]) ) )
		lRet := lRet .And. JurLoadValue( oModelNX0, "NX0_VLFATH",, Round( oModelNX0:GetValue("NX0_VLFATH") + nDifVlr, (TamSX3("NX0_VLFATH")[2]) ) )
		lRet := lRet .And. JurLoadValue( oModelNX8, "NX8_VHON",, Round(oModelNX8:GetValue("NX8_VHON") + nDifVlr, (TamSX3("NX8_VHON")[2]) ) )
		lRet := lRet .And. J202DescPre()
	EndIf

Return lRet

// Trata a alteração do VALOR TS do caso na pré - Substitui a rotina JA202VAL2("NX1_VTS")
Static Function JANX1_VTS1(oModel, lNewProcess, lTela)
Local lRet      := .T.
Local nPos      := 0
Local oModelNX1 := Nil
Local oModelNX8 := Nil
Local oModelNX0 := Nil
Local oModelNUE := Nil
Local nAjuste   := 0
Local nI        := 0
Local nLineNUE  := 1
Local nMaiorVl  := 0
Local nMaiorTS  := 0
Local nVlTS     := 0
Local nDifVlr   := 0
Local nQtdLnNUE := 0
Local cClient   := ""
Local cLoja     := ""
Local cCaso     := ""
Local cContr    := ""
Local nPosAlt   := 0
Local nSaldo    := 0
Local nTSFora   := 0 //Valor de time sheets que não devem ser considerados na conta.
Local nNX1VTs   := 0

Default oModel      := FwModelActive()
Default lNewProcess := .F.
Default lTela       := .F.

If lNewProcess
	__oProcess:SetRegua1(__nQtdNX1)
	__oProcess:SetRegua2(__nQtdNUE)
EndIf

oModelNX1 := oModel:GetModel("NX1DETAIL")
oModelNX8 := oModel:GetModel("NX8DETAIL")
oModelNX0 := oModel:GetModel("NX0MASTER")

cClient   := oModelNX1:GetValue("NX1_CCLIEN")
cLoja     := oModelNX1:GetValue("NX1_CLOJA")
cCaso     := oModelNX1:GetValue("NX1_CCASO")
cContr    := oModelNX1:GetValue("NX1_CCONTR")

//Verifica se houve alguma alteração de periodo que não foi confirmada
nPosAlt := aScan( aAltPend, {|x| x[1] == 'TS' .And. x[2] == cClient .And. x[3] == cLoja .And. x[4] == cCaso .And. x[5] == cContr })

If nPosAlt > 0
	lRet := JurMsgErro(STR0170) //"Existem alterações de valor pendentes, para efetuar novas alterações confirme ou cancele as anteriores!"
	Return lRet
EndIf

//Retorna a posição da variavel aCasos (encapsulado aScan no vetor aCasos para poder depurar a função)
nPos := J202ACSPOS(cClient, cLoja, cCaso, cContr)

oModelNUE := oModel:GetModel("NUEDETAIL")

If nPos > 0 .And. !oModelNUE:IsEmpty()

	nTSFora := J202NTSFORA(oModelNUE)
	nNX1VTs := oModelNX1:GetValue( "NX1_VTS" )
	nAjuste := (nNX1VTs - nTSFora) / (aCasos[nPos][6] - nTSFora)
	nDifVlr := (nNX1VTs - nTSFora) - (aCasos[nPos][6] - nTSFora)
	nSaldo  := (nNX1VTs - nTSFora)

	If nSaldo < 0
		lRet := JurMsgErro(J202PartCl(oModel, nTSFora))
	EndIf

	If lRet
		nQtdLnNUE := oModelNUE:GetQtdLine()
		//Posiciona na linha válida
		While (nMaiorTS == 0 .And. nLineNUE <= nQtdLnNUE .And.;
		       (oModelNUE:IsDeleted() .Or. !JA202TEMPO( .F., oModelNUE:GetValue( 'NUE_CATIVI', nLineNUE )) .Or. oModelNUE:GetValue("NUE_COBRAR", nLineNUE) == "2" .Or. ;
		        J202ATIVID("2", oModelNUE:GetValue( 'NUE_CATIVI', nLineNUE )) == "2" .Or. oModelNUE:GetValue("NUE_VALOR1", nLineNUE) <= 0 ))
			nLineNUE++
		EndDo

		If nLineNUE > nQtdLnNUE
			lRet := JurMsgErro(STR0293,; //"Não existem Time Sheets passíveis para alteração."
				"JANX1_VTS1()",;
				STR0294+CRLF; //"Não é possível alterar Time Sheets com as seguintes condições:"
				+STR0295+CRLF; //"1) Com participação do cliente;"
				+STR0296+CRLF; //"2) Com o valor 0 (zero);"
				+STR0297+CRLF; //"3) Não cobrável;"
				+STR0298) //"4) Deletado do grid."
		Else
			nMaiorVl   := oModelNUE:GetValue("NUE_VALOR1", nLineNUE)
			nMaiorTS   := nLineNUE
			nDecNUEVl1 := TamSX3("NUE_VALOR1")[2]
		EndIf

		If lRet

			For nI := nLineNUE To nQtdLnNUE
				
				If lTela
					__oProcess:IncRegua2(i18n(STR0332, {__nCountNUE++, __nQtdNUE} )) // "Atualizando valores dos lançamentos - #1 de #2."
				EndIf

				If !oModelNUE:IsDeleted(nI) .And. oModelNUE:GetValue("NUE_VALOR1", nI) > 0 .And. ;
					 JA202TEMPO( .F., oModelNUE:GetValue('NUE_CATIVI', nI) ) .And. ( oModelNUE:GetValue("NUE_COBRAR", nI) == "1" ) .And. ;
					 (J202ATIVID("2", oModelNUE:GetValue( 'NUE_CATIVI', nI )) == "1")

					oModelNUE:goLine(nI)

					nVlTS := oModelNUE:GetValue("NUE_VALOR1")

					If nVlTS > nMaiorVl
						nMaiorVl  := nVlTS
						nMaiorTS  := nI
					EndIf

					If (nVlTS * nAjuste) >= 0
						lRet   := lRet .And. oModelNUE:SetValue("NUE_VALOR1", Round(nVlTS * nAjuste, nDecNUEVl1 ))
						nSaldo := nSaldo - oModelNUE:GetValue("NUE_VALOR1")
					Else
						If nTSFora > 0
							lRet := JurMsgErro(J202PartCl(oModel, nTSFora))
							Exit
						Else
							lRet := JurMsgErro(STR0169) //"informe um valor positivo!"
							Exit
						EndIf
					EndIf
				EndIf
			Next

			If !(nSaldo == 0) .And. lRet
				oModelNUE:goLine(nMaiorTS)
				nVlTS := oModelNUE:GetValue("NUE_VALOR1")
				lRet := lRet .And. JurSetValue( oModelNUE, "NUE_VALOR1",, Round(nVlTS + nSaldo, nDecNUEVl1 )  )
			EndIf

			oModelNUE:goLine(nLineNUE)

			//Atualiza o desconto do caso
			lRet := lRet .And. J202DescCaso()

			//Se for alteração no proprio NX1_VTS
			If  !IsInCallStack("JANX8_VTS") .And. !IsInCallStack("JANX0_VTS")
				lRet := lRet .And. JurLoadValue( oModelNX8 , "NX8_VTS"   ,, Round( oModelNX8:GetValue("NX8_VTS") + nDifVlr, (TamSX3("NX8_VTS")[2]) )  )
				lRet := lRet .And. JurLoadValue( oModelNX8 , "NX8_VHON"  ,, Round(oModelNX8:GetValue("NX8_VHON") + nDifVlr, (TamSX3("NX8_VHON")[2]) )  )
				lRet := lRet .And. JurLoadValue( oModelNX0 , "NX0_VTS"   ,, Round( oModelNX0:GetValue("NX0_VTS") + nDifVlr, (TamSX3("NX0_VTS")[2]) )  )
				lRet := lRet .And. JurLoadValue( oModelNX0 , "NX0_VLFATH",, Round( oModelNX0:GetValue("NX0_VLFATH") + nDifVlr, (TamSX3("NX0_VLFATH")[2]) )  )

				lRet := lRet .And. J202DescContr()
				lRet := lRet .And. J202DescPre()
				lRet := lRet .And. J202DivCas("NX1") // Ajusta o rateio no campo NX1_VHON

			EndIf

			aCasos[nPos][06] := oModelNX1:GetValue( "NX1_VTS" )

		EndIf
	EndIf

Else
	lRet := JurMsgErro(STR0235) // "Caso não ajustado"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202PartCl
Rotina para montar a mensagem de critica ao reduzir o valor de TS em
um caso com timesheet com participação do cliente.

@Param		oModel		Modelo da base de dados
@Param		nVPartCl	valor da soma dos timesheets com participação
						cliente no caso.

@author Luciano Pereira dos Santos
@since 14/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202PartCl(oModel, nVPartCl )
Local oModelNX1 := oModel:GetModel("NX1DETAIL")
Local oModelNX0 := oModel:GetModel("NX0MASTER")
Local cValor    := ""
Local cRet      := ""

cValor := AllTrim(JurGetDados('CTO', 1, xFilial('CTO') + oModelNX0:GetValue("NX0_CMOEDA" ), "CTO_SIMB" )) + AllTrim( Transform(nVPartCl, JURX3INFO("NX1_VTS", "X3_PICTURE") ) )
cRet   := I18N( STR0261, {oModelNX1:GetValue("NX1_CCASO")} ) //"O valor do timesheet no caso '#1' não pode ser inferior a soma dos seus lançamentos com participação do cliente."

If !IsInCallStack("JANX8_VTS") .And. !IsInCallStack("JANX0_VTS")
	cRet += I18N( STR0262, {cValor}) //" Informe um valor igual ou maior que #1."
Else
	cRet += I18N( STR0263, {cValor}) // " O valor do timesheet desse caso pode ser alterado para um valor igual ou maior que #1."
EndIf

Return cRet

// Trata a alteração do VALOR1 do participante na pré - Substitui a rotina JA202VAL( 'NX2_VALOR1' )
Static Function JANX2_VTS1(oModel)
Local lRet      := .T.
Local nPos      := 0
Local oModelNX2 := Nil
Local oModelNX1 := Nil
Local oModelNX8 := Nil
Local oModelNX0 := Nil
Local oModelNUE := Nil
Local cX2Cli    := ""
Local cX2Loja   := ""
Local cX2Caso   := ""
Local cX2Part   := ""
Local nX2Valor  := ""
Local cX2CodSeq := ""
Local cX2CLTab  := ""
Local cX2Categ  := ""
Local cX2MOTBH  := ""
Local nAjuste   := 0
Local nLineNUE  := 1
Local nMaiorTS  := 0
Local nMaiorVl  := 0
Local nDifVlr   := 0
Local nSaldo    := 0
Local nI        := 0
Local nQtdNUE   := 0
Local nDecNUEVl1:= 0
Local lShowTela := .F.
Local nTSFora   := 0

Default oModel  := FwModelActive()

	oModelNUE := oModel:GetModel("NUEDETAIL")
	oModelNX2 := oModel:GetModel("NX2DETAIL")
	oModelNX1 := oModel:GetModel("NX1DETAIL")
	oModelNX8 := oModel:GetModel("NX8DETAIL")
	oModelNX0 := oModel:GetModel("NX0MASTER")

	cX2Cli    := oModelNX2:GetValue( "NX2_CCLIEN" )
	cX2Loja   := oModelNX2:GetValue( "NX2_CLOJA"  )
	cX2Caso   := oModelNX2:GetValue( "NX2_CCASO"  )
	cX2Part   := oModelNX2:GetValue( "NX2_CPART"  )
	nX2Valor  := oModelNX2:GetValue( "NX2_VALORH"  )
	cX2CodSeq := oModelNX2:GetValue( "NX2_CODSEQ" )
	cX2CLTab  := oModelNX2:GetValue( "NX2_CLTAB"  )
	cX2Categ  := oModelNX2:GetValue( "NX2_CCATEG" )
	cX2MOTBH  := oModelNX2:GetValue( "NX2_CMOTBH" )

	nPos := aScan( aPart, { |x| x[ 1] == cX2Cli .And. ;
								x[ 2] == cX2Loja .And. ;
								x[ 3] == cX2Caso .And. ;
								x[ 4] == cX2Part .And. ;
								x[ 5] == nX2Valor .And. ;
								x[10] == cX2CodSeq .And. ;
								x[13] == cX2CLTab .And. ;
								x[14] == cX2Categ .And. ;
								x[21] == cX2MOTBH} )

    If nPos > 0
		nTSFora     := J202NTSFORA(oModelNUE, {cX2Part, nX2Valor, cX2Categ, cX2MOTBH, cX2CLTab})
		nSaldo      := (oModelNX2:GetValue( "NX2_VALOR1" ) - nTSFora)
		nAjuste     := nSaldo / (aPart[nPos][6] - nTSFora)
		nDifVlr     := nSaldo - (aPart[nPos][6] - nTSFora)
		nDecNUEVl1  := TamSX3("NUE_VALOR1")[2]

		nMaiorTS := 0

		If nSaldo < 0
			lRet := JurMsgErro(J202PartCl(oModel, nTSFora))
		EndIf

		oModelNUE := oModel:GetModel("NUEDETAIL")
		nQtdNUE   := oModelNUE:Length()

		If lRet
			//Posiciona em um Time Sheet válido
			While (nMaiorTS == 0 .And. nLineNUE <= oModelNUE:GetQtdLine() .And.;
			       (cX2Part  != oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CPART2], nLineNUE ) .Or.;
			        nX2Valor != oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALORH], nLineNUE ) .Or.;
			        cX2Categ != oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CCATEG], nLineNUE ) .Or.;
			        cX2MOTBH != oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CMOEDA], nLineNUE ) .Or.;
			        cX2CLTab != oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CLTAB] , nLineNUE ) .Or.;
			        !JA202TEMPO( .F., oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CATIVI], nLineNUE )) .Or.;
			        J202ATIVID("2", oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CATIVI], nLineNUE )) == "2" .Or.;
			        oModelNUE:GetValue("NUE_COBRAR") == "2" .Or. ;
			        oModelNUE:IsDeleted() .Or. oModelNUE:GetValue("NUE_VALOR1", nLineNUE) <= 0 ))
				nLineNUE++
			EndDo

			If nLineNUE > oModelNUE:GetQtdLine()
				lRet := JurMsgErro(STR0293,; //"Não existem Time Sheets passíveis para alteração."
					"JANX1_VTS1()",;
					STR0294+CRLF; //"Não é possível alterar Time Sheets com as seguintes condições:"
					+STR0295+CRLF; //"1) Com participação do cliente;"
					+STR0296+CRLF; //"2) Com o valor 0 (zero);"
					+STR0297+CRLF; //"3) Não cobrável;"
					+STR0298) //"4) Deletado do grid."
			Else
				nMaiorVl := oModelNUE:GetValue("NUE_VALOR1", nLineNUE)
				nMaiorTS := nLineNUE
			EndIf
		EndIf

		If lRet

			For nI := 1 To nQtdNUE

				If cX2Part == oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CPART2], nI ) .And. ;
					nX2Valor == oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALORH], nI ) .And. ;
					cX2Categ == oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CCATEG], nI ) .And. ;
					cX2MOTBH == oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CMOEDA], nI ) .And. ;
					cX2CLTab == oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CLTAB], nI  ) .And. ;
					JA202TEMPO( .F., oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CATIVI], nI )) .And.;
					oModelNUE:GetValue("NUE_COBRAR", nI) == "1" .And.;
					J202ATIVID("2", oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CATIVI], nI )) == "1" .And.;
					!oModelNUE:IsDeleted(nI) .And. oModelNUE:GetValue("NUE_VALOR1", nI) > 0

					oModelNUE:goLine(nI)

					nVlTS := oModelNUE:GetValue("NUE_VALOR1")

					If nMaiorTS == 0
						nLineNUE := oModelNUE:nLine
						nMaiorVl := nVlTS
						nMaiorTS := nI
					EndIf

					If nVlTS > nMaiorVl
						nMaiorVl := nVlTS
						nMaiorTS := nI
					EndIf

					lRet   := lRet .And. JurSetValue( oModelNUE, "NUE_VALOR1",, Round(nVlTS * nAjuste, nDecNUEVl1 ) )
					nSaldo := nSaldo - oModelNUE:GetValue("NUE_VALOR1")

				EndIf

			Next

			If !(nSaldo == 0)
				oModelNUE:goLine(nMaiorTS)
				nVlTS := oModelNUE:GetValue("NUE_VALOR1")
				JurSetValue( oModelNUE, "NUE_VALOR1",, Round(nVlTS + nSaldo, nDecNUEVl1 ) )
			EndIf

			oModelNUE:goLine(nLineNUE)
	  		//Se for a alteração do próprio NX2_VTS
			If !IsInCallStack("JANX1_VTS") .And. !IsInCallStack("JANX8_VTS") .And. !IsInCallStack("JANX0_VTS")
				lRet := lRet .And. __JurLoadValue( oModelNX1, __aNX1PosFields[POS_NX1_VTS], Round( oModelNX1:GetValueByPos(__aNX1PosFields[POS_NX1_VTS] ) + nDifVlr, TamSX3("NX1_VTS")[2] ), lShowTela )
				lRet := lRet .And. JurLoadValue( oModelNX8, "NX8_VTS" ,, Round( oModelNX8:GetValue("NX8_VTS")  + nDifVlr, TamSX3("NX8_VTS")[2] ) )
				lRet := lRet .And. JurLoadValue( oModelNX8, "NX8_VHON",, Round( oModelNX8:GetValue("NX8_VHON") + nDifVlr, TamSX3("NX8_VHON")[2] ) )
				lRet := lRet .And. JurLoadValue( oModelNX0, "NX0_VTS" ,, Round( oModelNX0:GetValue("NX0_VTS")  + nDifVlr, TamSX3("NX0_VTS")[2] ) )
				lRet := lRet .And. JurLoadValue( oModelNX0, "NX0_VLFATH",, Round( oModelNX0:GetValue("NX0_VLFATH") + nDifVlr, TamSX3("NX0_VLFATH")[2] ) )

				//Atualiza os descontos superiores
				lRet := lRet .And. J202DescCaso()
				lRet := lRet .And. J202DescContr()
				lRet := lRet .And. J202DescPre()

				lRet := lRet .And. J202DivCas("NX1")
			EndIf

			aPart[nPos][05] := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_VALORH] )
			aPart[nPos][06] := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_VALOR1] )
			aPart[nPos][07] := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_UTR]    )
			aPart[nPos][08] := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_TEMPOR] )
			aPart[nPos][09] := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_HORAR]  )
		EndIf

	Else
		lRet := JurMsgErro(STR0236) // "Participante não ajustado"
	EndIf

Return lRet

// Trata a alteração do VALOR1 do TS na pré - Substitui a rotina JA202VAL( 'NUE_VALOR1' )
Static Function JANUE_VTS1()
Local lRet       := .T.
Local oModel     := If(oModelOld = Nil, FwModelActive(), oModelOld)
Local oModelNUE  := Nil
Local oModelNX0  := Nil
Local oModelNX1  := Nil
Local oModelNX2  := Nil
Local cNX0Cod    := ""
Local cNX0DTEMI  := ""

Local nNUEVALOR1 := 0
Local cNUECPART2 := ""
Local nNUEVALORH := 0
Local nNUETEMPOR := 0
Local cNUECCATEG := ""
Local cNUECLTAB  := ""
Local cNUECMOEDA := ""
Local cNUECMOED1 := ""

Local nUtTsNova  := 0
Local nTempNovo  := 0
Local cHoraNova  := ""
Local nValrNovo  := 0

Local nDecimal   := 0
Local nInteiro   := 0
Local aValor1TS  := {}
Local nDifVlr    := 0
Local nDifVlrTb  := 0
Local nDifUT     := 0
Local nDifTempo  := 0
Local nJURTS1    := SuperGetMV( 'MV_JURTS1',, 10 )  //Minutos da UT
Local lShowTela  := .F.
Local nI         := 0
Local lPodeFrac  := SuperGetMV( 'MV_JURTS3',, .F. ) //Indica se as uts ou o tempo pode ser possuir frações da unidade de tempo
Local nPos       := 0
Local nQtdNX2    := 0
Local nDecNX2UTR := 0
Local nDecNX2TpR := 0
Local nDecNX2VTH := 0
Local nDecNX2Vl1 := 0

Local cNX2Clien  := ""
Local cNX2Loja   := ""
Local cNX2Caso   := ""
Local cNX2Part   := ""
Local cNX2CodSeq := ""
Local cNX2CLTab  := ""
Local cNX2Categ  := ""
Local cNX2MOTBH  := ""

Local nNX2UtR    := 0
Local nNX2TempoR := 0
Local cNX2HoraR  := ""
Local nNX2VLHTBH := 0
Local nNX2VALOR1 := 0
Local fTempNovo  := DEC_CREATE('0', 64, 20)
Local nNX2TamHr  := 0

	If !IsJura202() .Or. IsInCallStack("JA145ALT")
		Return lRet
	EndIf

	oModelNUE   := oModel:GetModel("NUEDETAIL")
	oModelNX0   := oModel:GetModel("NX0MASTER")
	oModelNX8   := oModel:GetModel("NX8DETAIL")
	oModelNX1   := oModel:GetModel("NX1DETAIL")
	oModelNX2   := oModel:GetModel("NX2DETAIL")

	cNX0Cod     := oModelNX0:GetValue( "NX0_COD" )
	cNX0DTEMI   := oModelNX0:GetValue("NX0_DTEMI")

	nNUEVALOR1  := oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALOR1])
	cNUECPART2  := oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CPART2] )
	nNUEVALORH  := oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALORH] )
	nNUETEMPOR  := oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_TEMPOR] )
	cNUECCATEG  := oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CCATEG] )
	cNUECLTAB   := oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CLTAB]  )
	cNUECMOEDA  := oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CMOEDA])
	cNUECMOED1  := oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CMOED1])

	If nNUEVALOR1 < 0
		lRet := JurMsgErro(STR0169) // "Informe um valor positivo!"
		Return lRet
	EndIf

	If nNUEVALORH == 0 .Or. nJURTS1 == 0 .Or. nNUEVALOR1 == 0
		nTempNovo :=  0
	Else

		aValor1TS := JA201FConv(cNUECMOEDA, cNUECMOED1, nNUEVALOR1, "2", cNX0DTEMI, , cNX0Cod, )
		fTempNovo := DEC_DIV(DEC_CREATE(cValToChar(aValor1TS[1]), 64, 20), DEC_CREATE(cValToChar(nNUEVALORH), 64, 20))

		aValor1TS := JA201FConv(cNUECMOED1, cNUECMOEDA, nNUEVALORH * nNUETEMPOR, "2", cNX0DTEMI, , cNX0Cod, )

		nDifVlr   := nNUEVALOR1 - aValor1TS[1]
	EndIf

	nUTTSNova := Val( JURA144C1(2, 1, cValToChar(fTempNovo)) )
	cHoraNova :=      JURA144C1(2, 3, cValToChar(fTempNovo))

	nInteiro  := Int( nUTTSNova )
	nDecimal  := nUTTSNova - nInteiro

	If nDecimal <> 0 .And. !lPodeFrac
		nUTTSNova := Val( JURA144C1(1, 1, cValToChar(Round(nUTTSNova, 0)) ) )
		nTempNovo := Val( JURA144C1(1, 2, cValToChar(Round(nUTTSNova, 0)) ) )
		cHoraNova :=      JURA144C1(1, 3, cValToChar(Round(nUTTSNova, 0)) )
		nValrNovo := nTempNovo * nNUEVALORH
		fTempNovo := DEC_DIV(DEC_CREATE(cValToChar(nValrNovo), 64, 20), DEC_CREATE(cValToChar(nNUEVALORH), 64, 20))
	EndIf

	nDifUT     := oModelNUE:GetValue("NUE_UTR")
	nDifTempo  := oModelNUE:GetValue("NUE_TEMPOR")
	nDifVlrTb  := oModelNUE:GetValue("NUE_VALOR")

	nUTTSNova  := Round(nUTTSNova, TamSX3("NUE_UTR")[2])

	nValrNovo  := Val(cValToChar(DEC_RESCALE(DEC_MUL(fTempNovo, DEC_CREATE(nNUEVALORH, 64, 20)), TamSX3("NUE_VALOR")[2], 0)))
	nTempNovo  := Val(cValToChar(DEC_RESCALE(fTempNovo, TamSX3("NUE_TEMPOR")[2], 0)))

	lRet      := lRet .And. __JurLoadValue( oModelNUE, __aNUEPosFields[POS_NUE_HORAR], cHoraNova, lShowTela)
	lRet      := lRet .And. __JurLoadValue( oModelNUE, __aNUEPosFields[POS_NUE_UTR], nUTTSNova, lShowTela)
	lRet      := lRet .And. __JurLoadValue( oModelNUE, __aNUEPosFields[POS_NUE_TEMPOR], nTempNovo, lShowTela)
	lRet      := lRet .And. __JurLoadValue( oModelNUE, __aNUEPosFields[POS_NUE_VALOR], nValrNovo, lShowTela)

	nDifUT    := nUTTSNova - nDifUT
	nDifTempo := nTempNovo - nDifTempo
	nDifVlrTb := nValrNovo - nDifVlrTb

	If !lRet
		Return lRet
	EndIf

	nPosNX2 := oModelNX2:GetLine()
	nQtdNX2 := oModelNX2:Length()

	nDecNX2UTR := TamSX3("NX2_UTR")[2]
	nDecNX2TpR := TamSX3("NX2_TEMPOR")[2]
	nDecNX2VTH := TamSX3("NX2_VLHTBH")[2]
	nDecNX2Vl1 := TamSX3("NX2_VALOR1")[2]
	nNX2TamHr  := tamSX3('NX2_HORAR')[1]

	For nI := 1 To nQtdNX2

		If !oModelNX2:IsDeleted(ni) .And.;
				(cNX2Part := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_CPART], ni)) == cNUECPART2 .And.;
				(nNX2ValorH := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_VALORH], ni)) == nNUEVALORH .And.;
				(cNX2Categ := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_CCATEG], ni)) == cNUECCATEG .And.;
				(cNX2MOTBH := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_CMOTBH], ni)) == cNUECMOEDA .And.;
				(cNX2CLTab := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_CLTAB], ni)) == cNUECLTAB

			oModelNX2:GoLine(ni)

			nNX2UtR    := Round( oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_UTR] ) + nDifUT, nDecNX2UTR )
			nNX2TempoR := Round( oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_TEMPOR] ) + nDifTempo, nDecNX2TpR )
			cNX2HoraR  := PADL(JURA144C1(2, 3, cValToChar(nNX2TempoR)), nNX2TamHr, '0')
			nNX2VLHTBH := Round( oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_VLHTBH] ) + nDifVlrTb , nDecNX2VTH )
			nNX2VALOR1 := Round( oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_VALOR1] ) + nDifVlr, nDecNX2Vl1 )

			lRet := lRet .And. __JurLoadValue( oModelNX2, __aNX2PosFields[POS_NX2_UTR]   , nNX2UtR   , lShowTela)
			lRet := lRet .And. __JurLoadValue( oModelNX2, __aNX2PosFields[POS_NX2_TEMPOR], nNX2TempoR, lShowTela)
			lRet := lRet .And. __JurLoadValue( oModelNX2, __aNX2PosFields[POS_NX2_HORAR] , cNX2HoraR , lShowTela)
			lRet := lRet .And. __JurLoadValue( oModelNX2, __aNX2PosFields[POS_NX2_VLHTBH], nNX2VLHTBH, lShowTela)

			If !IsInCallStack("JANX2_VTS")
				lRet := lRet .And. __JurLoadValue( oModelNX2, __aNX2PosFields[POS_NX2_VALOR1], nNX2VALOR1, lShowTela )
			EndIf

			cNX2Clien  := oModelNX2:GetValue( "NX2_CCLIEN" )
			cNX2Loja   := oModelNX2:GetValue( "NX2_CLOJA"  )
			cNX2Caso   := oModelNX2:GetValue( "NX2_CCASO"  )
			cNX2CodSeq := oModelNX2:GetValue( "NX2_CODSEQ" )

			nPos := aScan( aPart, { |x| x[ 1] == cNX2Clien .And. ;
				x[ 2] == cNX2Loja 	.And. ;
				x[ 3] == cNX2Caso 	.And. ;
				x[ 4] == cNX2Part 	.And. ;
				x[ 5] == nNX2ValorH 	.And. ;
				x[10] == cNX2CodSeq 	.And. ;
				x[11] == oModelNX2:GetLine()  .And.;
				x[13] == cNX2CLTab 	.And. ;
				x[14] == cNX2Categ 	.And. ;
				x[21] == cNX2MOTBH} )

			If nPos > 0
				aPart[nPos][05] := nNX2ValorH
				aPart[nPos][06] := nNX2VALOR1
				aPart[nPos][07] := nNX2UtR
				aPart[nPos][08] := nNX2TempoR
				aPart[nPos][09] := cNX2HoraR
			EndIf

			Exit //Se encontrou, ajusta e não precisa passar nos demais
		EndIf

	Next ni

	If IsInCallStack("JANX2_VTS") //so reposiciona se o ajuste for a partir do participante
		oModelNX2:GoLine( nPosNX2 )
	EndIf

	//Executa se for alterado diretamente do NUE_VTS
	If !Empty(oModelNX1:GetValue("NX1_VTS")) .And. !IsInCallStack("JANX2_VTS") .And. !IsInCallStack("JANX1_VTS") .And. !IsInCallStack("JANX8_VTS") .And. !IsInCallStack("JANX0_VTS")
		lRet := lRet .And. __JurLoadValue( oModelNX1 , __aNX1PosFields[POS_NX1_VTS], Round( oModelNX1:GetValueByPos(__aNX1PosFields[POS_NX1_VTS] ) + nDifVlr, TamSX3("NX1_VTS")[2] ) ,lShowTela )
		lRet := lRet .And. JurLoadValue( oModelNX8 , "NX8_VTS" ,, Round( oModelNX8:GetValue("NX8_VTS")  + nDifVlr, TamSX3("NX8_VTS")[2] )  )
		lRet := lRet .And. JurLoadValue( oModelNX8 , "NX8_VHON",, Round( oModelNX8:GetValue("NX8_VHON") + nDifVlr, TamSX3("NX8_VHON")[2] )  )
		lRet := lRet .And. JurLoadValue( oModelNX0 , "NX0_VTS" ,, Round( oModelNX0:GetValue("NX0_VTS")  + nDifVlr, TamSX3("NX0_VTS")[2] )  )
		lRet := lRet .And. JurLoadValue( oModelNX0 , "NX0_VLFATH" ,, Round( oModelNX0:GetValue("NX0_VLFATH")  + nDifVlr, TamSX3("NX0_VLFATH")[2] )  )

		//Atualiza os descontos superiores
		lRet := lRet .And. J202DescCaso()
		lRet := lRet .And. J202DescContr()
		lRet := lRet .And. J202DescPre()

		lRet := lRet .And. J202DivCas("NX1") // Ajusta o rateio no campo NX1_VHON

	ElseIf Empty(oModelNX1:GetValue("NX1_VTS")) //TimeSheet apenas vinculados a um contrato de Fixo.
		lRet := lRet .And. JurLoadValue( oModelNX1, "NX1_VTSVIN",, Round( oModelNX1:GetValue("NX1_VTSVIN") + nDifVlr, TamSX3("NX1_VTSVIN")[2] ) )
		lRet := lRet .And. JurLoadValue( oModelNX8, "NX8_VTSVIN",, Round( oModelNX8:GetValue("NX8_VTSVIN") + nDifVlr, TamSX3("NX8_VTSVIN")[2] ) )
	EndIf

	//Se foi executado do participante
	If !IsInCallStack("JANX1_VTS") .And. !IsInCallStack("JANX8_VTS") .And. !IsInCallStack("JANX0_VTS")
		nPos := aScan( aCasos, { |x| 	x[ 1] == oModelNX1:GetValue("NX1_CCLIEN") .And. ;
										x[ 2] == oModelNX1:GetValue("NX1_CLOJA") .And. ;
										x[ 3] == oModelNX1:GetValue("NX1_CCASO") .And. ;
										x[ 9] == oModelNX1:GetValue("NX1_CCONTR") } )
		If nPos > 0
			aCasos[nPos][06] := aCasos[nPos][06] + nDifVlr
		EndIf

	EndIf

Return lRet

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                FUNÇÕES ALTERAÇÃO POR PERIODO OPÇÃO 1 = "TEMPO" - FIM                                  //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                FUNÇÕES ALTERAÇÃO POR PERIODO OPÇÃO 2 = "ULTIMO" - INICIO                              //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//-------------------------------------------------------------------
/*/{Protheus.doc} JANX0_VTS2()
Rotina para recalculo da alteração por período opção 2=Ultimo da pré-fatura

@params    oModel     , Modelo de dados ativo
@params    lNewProcess, Indica se está sendo aberto um novo MsNewProcess

@Return    lRet       , .T. se a alteração teve êxito.

@author Luciano Pereira dos santos
@since 18/01/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JANX0_VTS2(oModel, lNewProcess)
Local lRet          := .T.
Local nPos          := 0
Local oModelNX0     := Nil
Local oModelNX8     := Nil
Local nVlrPre       := 0
Local nAjuste       := 0
Local nSaldo        := 0
Local nI            := 0
Local nVlrContr     := 0
Local nMaiorVl      := 0
Local nMaiorContr   := 0
Local nLineNX8      := 0
Local nDifVlr       := 0
Local nQtdLine      := 0
Local nDecNX8VTs    := 0
Local nDecNX8VHn    := 0
Local cPrefat       := ""

Default oModel      := FwModelActive()
Default lNewProcess := .F.

	If lNewProcess
		__oProcess:SetRegua1(__nQtdNX1)
		__oProcess:SetRegua2(__nQtdNUE)
	EndIf

	oModelNX0 := oModel:GetModel("NX0MASTER")

	For nPos := 1 To Len(aCasos)
		nVlrPre += aCasos[nPos][6]
	Next nPos

	nSaldo      := oModelNX0:GetValue( "NX0_VTS" )
	cPreFat     := oModelNX0:GetValue( "NX0_COD" )

	If nSaldo < 0
		lRet := JurMsgErro(STR0169) //"Informe um valor positivo!"
		Return lRet
	Else
		If nSaldo > nVlrPre
			lRet := JurMsgErro(STR0097) // Não é possível efetuar a alteração, pois o valor novo é maior do que o antigo
			Return lRet
		EndIf
	EndIf

	nAjuste := nSaldo / nVlrPre

	oModelNX8   := oModel:GetModel("NX8DETAIL")
	nLineNX8    := oModelNX8:nLine
	nMaiorVl    := oModelNX8:GetValue("NX8_VTS")
	nMaiorContr := nLineNX8
	nQtdLine    := oModelNX8:Length()

	nDecNX8VTs  := TamSX3("NX8_VTS")[2]
	nDecNX8VHn  := TamSX3("NX8_VHON")[2]

	For nI := 1 To nQtdLine

		If oModelNX8:GetValue("NX8_TS", nI) == "1"

			oModelNX8:goLine(nI)

			nVlrContr := oModelNX8:GetValue("NX8_VTS")

			If nVlrContr > nMaiorVl
				nMaiorVl := nVlrContr
				nMaiorContr := nI
			EndIf

			nDifVlr := nVlrContr - nVlrContr * nAjuste
			lRet    := lRet .And. JurSetValue( oModelNX8, "NX8_VTS",, Round(nVlrContr * nAjuste, nDecNX8VTs ) )
			nSaldo  := nSaldo - oModelNX8:GetValue("NX8_VTS")

			lRet := lRet .And. JurLoadValue( oModelNX8, "NX8_VHON",, Round(oModelNX8:GetValue("NX8_VHON") - nDifVlr, nDecNX8VHn )  )

			lRet := lRet .And. J202DivCas("NX8") // Ajusta o rateio no campo NX1_VHON
		EndIf
	Next

	If !(nSaldo == 0)
		oModelNX8:goLine(nMaiorContr)
		nVlrContr := oModelNX8:GetValue("NX8_VTS")
		cInstanc := "NX0" // controla a instancia de ajuste do saldo
		lRet := lRet .And. JurSetValue( oModelNX8, "NX8_VTS",, Round(nVlrContr + nSaldo, nDecNX8VTs ) )

		//Verifica se preciso atualizar o array dos Ts filhos com o saldo residual
		lRet := lRet .And. J202AtuFilho("TS", nVlrPre, oModelNX0:GetValue( "NX0_VTS" ))

	EndIf

	//Atualiza o valor de honorários
	lRet := lRet .And. JurLoadValue( oModelNX0, "NX0_VLFATH",, Round( oModelNX0:GetValue("NX0_VLFATH") - nDifVlr, TamSX3("NX0_VLFATH")[2] ) )

	//Atualiza dos descontos na Pré-Fatura
	lRet := lRet .And. J202DescPre()

	oModelNX8:goLine(nLineNX8)
	cInstanc := ""

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JANX8_VTS2()
Rotina para recalculo da alteração por período opção 2=Último para os
contratos da pré-fatura

@params    oModel     , Modelo de dados ativo
@params    lNewProcess, Indica se está sendo aberto um novo MsNewProcess
@params    lTela      , Indica se a chamada foi feita via tela

@return    lRet       , .T. se a alteração teve Êxito.

@author Luciano Pereira dos santos
@since 18/01/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JANX8_VTS2(oModel, lNewProcess, lTela)
Local lRet       := .T.
Local nPos       := 0
Local oModelNX0  := Nil
Local oModelNX8  := Nil
Local oModelNX1  := Nil
Local nVlrContr  := 0
Local nAjuste    := 0
Local nSaldo     := 0
Local nI         := 0
Local nVlCaso    := 0
Local nMaiorVl   := 0
Local nMaiorCont := 0
Local nLineNX1   := 0
Local nDifVlr    := 0
Local nQtdNX1    := 0
Local nDecNX1VTs := 0
Local cContr     := ""

Default oModel      := FwModelActive()
Default lNewProcess := .F.
Default lTela       := .F.

If lNewProcess
	__oProcess:SetRegua1(__nQtdNX1)
	__oProcess:SetRegua2(__nQtdNUE)
EndIf

oModelNX0        := oModel:GetModel("NX0MASTER")
oModelNX8        := oModel:GetModel("NX8DETAIL")
oModelNX1        := oModel:GetModel("NX1DETAIL")

cContr           := oModelNX8:GetValue("NX8_CCONTR")
nQtdNX1          := oModelNX1:Length()
nDecNX1VTs       := TamSX3("NX1_VTS")[2]

If Empty(cInstanc)

	For nPos := 1 To Len(aCasos)
		If aCasos[nPos][9] == cContr
			nVlrContr += aCasos[nPos][6]
		EndIf
	Next nPos

	nSaldo := oModelNX8:GetValue( "NX8_VTS" )

	If nSaldo < 0
		lRet := JurMsgErro(STR0169) //"Informe um valor positivo!"
		Return lRet
	Else
		If nSaldo > nVlrContr
			lRet := JurMsgErro(STR0097) // Não é possível efetuar a alteração, pois o valor novo é maior do que o antigo
			Return lRet
		EndIf
	EndIf

	nAjuste     := nSaldo / nVlrContr
	nDifVlr     := nVlrContr - nSaldo

	nLineNX1    := oModelNX1:nLine
	nMaiorVl    := oModelNX1:GetValue("NX1_VTS")
	nMaiorCont  := nLineNX1

	For nI := 1 To nQtdNX1

		If lTela
			__oProcess:IncRegua1(i18n(STR0331, {oModelNX1:GetValue("NX1_CCASO", nI), __nCountNX1++, __nQtdNX1} )) // "Atualizando Caso #1 - #2 de #3."
		EndIf

		If oModelNX1:GetValue("NX1_TS", nI) == "1"

			oModelNX1:goLine(nI)

			nVlCaso := oModelNX1:GetValue("NX1_VTS")

			If nVlCaso > nMaiorVl
				nMaiorVl   := nVlCaso
				nMaiorCont := nI
			EndIf

			lRet   := lRet .And. JurSetValue( oModelNX1, "NX1_VTS",, Round(nVlCaso * nAjuste, nDecNX1VTs ) )
			nSaldo := nSaldo - oModelNX1:GetValue("NX1_VTS")

		EndIf

	Next

	If !(nSaldo == 0)
		oModelNX1:goLine(nMaiorCont)
		nVlCaso := oModelNX1:GetValue("NX1_VTS")
		cInstanc := "NX8" // controla a instancia de ajuste do saldo no caso a apartir do contrato
		lRet := lRet .And. JurSetValue( oModelNX1, "NX1_VTS",, Round(nVlCaso + nSaldo, nDecNX1VTs ) )
	EndIf

	oModelNX1:goLine(nLineNX1)

	If !IsInCallStack("JANX0_VTS")
		lRet := lRet .And. JurLoadValue( oModelNX0, "NX0_VTS" ,, Round( oModelNX0:GetValue("NX0_VTS") - nDifVlr, TamSX3("NX0_VTS")[2] )  )
		lRet := lRet .And. JurLoadValue( oModelNX8, "NX8_VHON",, Round( oModelNX8:GetValue("NX8_VHON") - nDifVlr, TamSX3("NX8_VHON")[2] )  )
		lRet := lRet .And. JurLoadValue( oModelNX0, "NX0_VLFATH",, Round( oModelNX0:GetValue("NX0_VLFATH") - nDifVlr, TamSX3("NX0_VLFATH")[2] )  )

		lRet := lRet .And. J202DivCas("NX8") // Ajusta o rateio no campo NX1_VHON
	EndIf
	cInstanc := ""

ElseIf cInstanc == "NX0" //Tratamento para evitar que o saldo crie novos time sheets filhos com valor ajuste

	For nPos := 1 To Len(aCasos)
		If aCasos[nPos][9] == cContr
			nVlrContr += aCasos[nPos][6]
		EndIf
	Next nPos

	nDifVlr     := oModelNX8:GetValue( "NX8_VTS" ) - nVlrContr
	nSaldo      := oModelNX8:GetValue( "NX8_VTS" )

	nLineNX1    := oModelNX1:nLine
	nMaiorVl    := oModelNX1:GetValue("NX1_VTS")
	nMaiorCont  := nLineNX1

	For nI := 1 To nQtdNX1

		If lTela
			__oProcess:IncRegua1(i18n(STR0331, {oModelNX1:GetValue("NX1_CCASO", nI), __nCountNX1++, __nQtdNX1} )) // "Atualizando Caso #1 - #2 de #3."
		EndIf

		If oModelNX1:GetValue("NX1_TS", nI) == "1"

			nVlCaso := oModelNX1:GetValue("NX1_VTS", nI)

			If nVlCaso > nMaiorVl
				nMaiorVl   := nVlCaso
				nMaiorCont := nI
			EndIf

			nSaldo := nSaldo - nVlCaso

		EndIf

	Next

	If !(nSaldo == 0)
		oModelNX1:goLine(nMaiorCont)
		nVlCaso  := oModelNX1:GetValue("NX1_VTS")
		cInstanc := "NX8" // controla a instancia de ajuste do saldo no caso a partir do contrato
		lRet     := lRet .And. JurSetValue( oModelNX1, "NX1_VTS",, Round(nVlCaso + nSaldo, nDecNX1VTs )  )
	EndIf

	oModelNX1:goLine(nLineNX1)
	cInstanc := ""
EndIf

lRet := lRet .And. J202DescContr() //Atualiza o desconto no contrato

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JANX1_VTS2()
Rotina para recalculo da alteração por período opção 3=Todos para os
contratos da pré-fatura

@params    oModel     , Modelo de dados ativo
@params    lNewProcess, Indica se está sendo aberto um novo MsNewProcess
@params    lTela      , Indica se a chamada foi feita via tela

@Return	   lRet       , .T. se a alteração teve êxito.

@author Luciano Pereira dos santos
@since 18/01/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JANX1_VTS2(oModel, lNewProcess, lTela)
Local lRet       := .T.
Local aArea      := GetArea()
Local oModelNX1  := Nil
Local oModelNX8  := Nil
Local oModelNX0  := Nil
Local oModelNUE  := Nil
Local oStrucNUE  := Nil
Local aStrucNUE  := {}
Local cClient    := ""
Local cLoja      := ""
Local cCaso      := ""
Local cContr     := ""
Local nLineNUE   := 0
Local nPos       := 0
Local nPosAlt    := 0
Local nLinha     := 0
Local nNewVlCaso := 0
Local nVlrCaso   := 0
Local lNUECpart2 := .F.
Local aAuxliar   := {}
Local nVlTSPre   := 0
Local nVlTS      := 0
Local nVlAcumul  := 0
Local lDividido  := .F.
Local nSaldo     := 0
Local nMaiorVl   := 0
Local nMaiorTS   := 0
Local nVlFilho   := 0
Local nUTRFilho  := 0
Local nUTR       := 0
Local nUTL       := 0
Local nUTLFilho  := 0
Local nUTLPai    := 0
Local nDifVlr    := 0
Local nTSFora    := 0 //Valor de time sheets que não devem ser considerados na conta.
Local nDecNUEVl1 := 0
Local nQtdNUE    := 0
Local cJurUser   := JurUsuario(__CUSERID)

Default oModel      := FwModelActive()
Default lNewProcess := .F.
Default lTela       := .F.

If lNewProcess
	__oProcess:SetRegua1(__nQtdNX1)
	__oProcess:SetRegua2(__nQtdNUE)
EndIf

oModelNUE := oModel:GetModel("NUEDETAIL")
oModelNX1 := oModel:GetModel("NX1DETAIL")
oModelNX8 := oModel:GetModel("NX8DETAIL")
oModelNX0 := oModel:GetModel("NX0MASTER")

cClient   := oModelNX1:GetValue("NX1_CCLIEN")
cLoja     := oModelNX1:GetValue("NX1_CLOJA")
cCaso     := oModelNX1:GetValue("NX1_CCASO")
cContr    := oModelNX1:GetValue("NX1_CCONTR")

oStrucNUE := oModelNUE:GetStruct()
aStrucNUE := oStrucNUE:GetFields()

If Empty(cInstanc)
	//Verifica se houve alguma alteração de periodo que não foi confirmada
 	nPosAlt := aScan( aAltPend, {|x| x[1] == 'TS' .And. x[2] == cClient .And. x[3] == cLoja .And. x[4] == cCaso .And. x[5] == cContr })

	If nPosAlt > 0
		lRet := JurMsgErro(STR0170) //"Existem alterações de valor pendentes, para efetuar novas alterações cancele as anteriores!"
		Return lRet
	EndIf

	//Retorna a posição da variável aCasos (encapsulado aScan no vetor aCasos para poder depurar a função)
	nPos := J202ACSPOS(cClient, cLoja, cCaso, cContr)

	If nPos > 0

		nTSFora     := J202NTSFORA(oModelNUE)
		nNewVlCaso  := oModelNX1:GetValue( "NX1_VTS" ) - nTSFora
		nSaldo      := nNewVlCaso
		nVlrCaso    := aCasos[nPos][6] - nTSFora
		nDifVlr     := nVlrCaso - nNewVlCaso

		If nNewVlCaso < 0
			lRet := JurMsgErro(STR0169) //"Informe um valor positivo!"
			Return lRet
		Else
			If nNewVlCaso > nVlrCaso
				lRet := JurMsgErro(STR0097) // Não é possível efetuar a alteração, pois o valor novo é maior do que o antigo
				Return lRet
			EndIf
		EndIf

		lNUECpart2 := oModelNUE:HasField( "NUE_CPART2" )

		nLineNUE   := oModelNUE:nLine
		nQtdNUE    := oModelNUE:Length()

		For nLinha := 1 To nQtdNUE
			If Empty(oModelNUE:GetValue( "NUE_CLTAB", nLinha )) .And. !Empty(oModelNUE:GetValue("NUE_VALOR1", nLinha )) .And.;
				!Empty(oModelNUE:GetValue("NUE_CPREFT", nLinha )) .And. JA202TEMPO( .F., oModelNUE:GetValue( 'NUE_CATIVI', nLinha ) ) .And. ;
				J202ATIVID("2", oModelNUE:GetValue( 'NUE_CATIVI', nLinha )) == "1" .And. (oModelNUE:GetValue("NUE_COBRAR", nLinha) == "1")
				Aadd( aAuxliar, {nLinha, oModelNUE:GetValue("NUE_DATATS", nLinha), oModelNUE:GetValue("NUE_COD", nLinha ), IIf(lNUECpart2, oModelNUE:GetValue("NUE_CPART2", nLinha), "") })
			EndIf
		Next nLinha

		If lNUECpart2
			aSort( aAuxliar,,, { |aX,aY| DtoS(aX[2]) + aX[4] < DtoS(aY[2]) + aY[4] } ) //Ordena pela data e cód do participante
		EndIf

		nDecNUEVl1 := TamSX3("NUE_VALOR1")[2]

		For nLinha := 1 To Len( aAuxliar )  // Varre o array com os time sheets ordenados por data é participante

			If lTela
				__oProcess:IncRegua2(i18n(STR0332, {__nCountNUE++, __nQtdNUE} )) // "Atualizando valores dos lançamentos - #1 de #2."
			EndIf
			
			oModelNUE:goLine(aAuxliar[nLinha][1])

			nVlTSPre   := oModelNUE:GetValue("NUE_VALOR1")
			nVlTS      := oModelNUE:GetValue("NUE_VALOR")
			nUTR       := oModelNUE:GetValue("NUE_UTR")
			nUTL       := oModelNUE:GetValue("NUE_UTL")

			If !lDividido
				nVlAcumul  := nVlAcumul + nVlTSPre
			EndIf

			If nVlAcumul >= nNewVlCaso .And. !lDividido

				Do Case
					Case (nVlAcumul == nNewVlCaso) //Se o ultimo Ts somado é exatamente igual ao novo valor, mantem o TS na Pré e remove os restantes.

						lDividido  := .T.

					Case (nVlAcumul - nNewVlCaso < nVlTSPre ) .And. !lDividido  // Se o valor residual é menor que o TS, mantem o TS na Pré e divide o seu valor.

						If nVlTSPre >= nMaiorVl
							nMaiorVl := nVlTSPre
							nMaiorTS := aAuxliar[nLinha][1]
						EndIf

						lRet := lRet .And. JurSetValue(oModelNUE, "NUE_VALOR1",, Round(nVlTSPre - (nVlAcumul - nNewVlCaso), nDecNUEVl1 ) )

						nVlFilho  := nVlTS - oModelNUE:GetValue("NUE_VALOR")
						nVlFilho1 := nVlTSPre - oModelNUE:GetValue("NUE_VALOR1")
						nUTRFilho := nUTR - oModelNUE:GetValue("NUE_UTR")

						//Divide percentualmente a UTL do Pai, calcula e grava TEMPOL e HORAL
						nUTLPai := (oModelNUE:GetValue("NUE_UTL") * (oModelNUE:GetValue("NUE_UTR") / nUTR) )
						lRet := lRet .And. JurLoadValue(oModelNUE, "NUE_UTL"   ,, nUTLPai)
						lRet := lRet .And. JurLoadValue(oModelNUE, "NUE_TEMPOL",, Val(JURA144C1(1, 2, Str(nUTLPai))))
						lRet := lRet .And. JurLoadValue(oModelNUE, "NUE_HORAL" ,, JURA144C1(1, 3, Str(nUTLPai)))

						nUTLFilho := nUTL - oModelNUE:GetValue("NUE_UTL")

						//grava o array com o lançamento filho (dividido) para serem gravados no commit.
						lRet := lRet .And. J202CriaFilho("NUE", oModelNUE, aStrucNUE, oModelNUE:GetValue("NUE_COD"), aAuxliar[nLinha][1], nVlFilho, nUTRFilho, nUTLFilho, nVlFilho1, cJurUser)

						nVlAcumul := nVlAcumul - nVlFilho1

						lDividido := .T.

					Case lDividido // Remove os timesheets restantes.

						//grava o array para remover os vinculos do Time Sheet no commit da tela.
						aAdd(aRmvLanc, {"NUE", xFilial("NUE") + oModelNUE:GetValue("NUE_COD") +;
						                oModelNUE:GetValue("NUE_SITUAC") + oModelNUE:GetValue("NUE_CPREFT"), oModelNUE:GetValue("NUE_VALOR1") })

						//apaga o codigo da pré-fatura para o TS ser removido no grava generico no commit da tela
						lRet := lRet .And. JurLoadValue(oModelNUE, "NUE_CPREFT",, "")
				EndCase

			ElseIf lDividido
				//grava o array para remover os vinculos do Time Sheet no commit da tela.
				aAdd(aRmvLanc, {"NUE", xFilial("NUE") + oModelNUE:GetValue("NUE_COD") +;
				                oModelNUE:GetValue("NUE_SITUAC") + oModelNUE:GetValue("NUE_CPREFT"), oModelNUE:GetValue("NUE_VALOR1") })

				//apaga o codigo da pré-fatura para o TS ser removido no grava generico no commit da tela
				lRet := lRet .And. JurLoadValue(oModelNUE, "NUE_CPREFT",, "")
			EndIf

		Next nLinha

		nSaldo := nSaldo - nVlAcumul

		If !(nSaldo == 0)
			oModelNUE:goLine(nMaiorTS)
			nVlTSPF := oModelNUE:GetValue("NUE_VALOR1")
			cInstanc := "NX1" // controla a instancia de ajuste do saldo no time sheet a partir do caso
			lRet := lRet .And. JurSetValue( oModelNUE, "NUE_VALOR1",, Round(nVlTSPF + nSaldo, nDecNUEVl1 )  )
		EndIf

		oModelNUE:goLine(nLineNUE)

		If !IsInCallStack("JANX8_VTS") .And. !IsInCallStack("JANX0_VTS")
			lRet := lRet .And. JurLoadValue( oModelNX8, "NX8_VTS",, Round( oModelNX8:GetValue("NX8_VTS") - nDifVlr, TamSX3("NX8_VTS")[2] )  )
			lRet := lRet .And. JurLoadValue( oModelNX8, "NX8_VHON",, Round(oModelNX8:GetValue("NX8_VHON") - nDifVlr, TamSX3("NX8_VHON")[2] )  )
			lRet := lRet .And. JurLoadValue( oModelNX0, "NX0_VTS",, Round( oModelNX0:GetValue("NX0_VTS") - nDifVlr, TamSX3("NX0_VTS")[2] )  )
			lRet := lRet .And. JurLoadValue( oModelNX0, "NX0_VLFATH",, Round( oModelNX0:GetValue("NX0_VLFATH") - nDifVlr, TamSX3("NX0_VLFATH")[2] )  )
			lRet := lRet .And. J202DivCas("NX1")
		EndIf

		aCasos[nPos][06] := oModelNX1:GetValue( "NX1_VTS" )

		//aAltPend [1] Tipo [2] Cliente [3] Loja [4] Caso [5] Contrato
		aAdd(aAltPend, {'TS', cClient, cLoja, cCaso, cContr } )
		cInstanc := ""
	Else
		lRet := JurMsgErro(STR0235) // "Caso não ajustado"
	EndIf

ElseIf cInstanc == "NX8" //Tratamento para evitar que o saldo crie novos time sheets filhos com valor ajuste

	nSaldo    := oModelNX1:GetValue( "NX1_VTS" )
	nMaiorTS  := 0

	nQtdNUE   := oModelNUE:Length()

	For nLinha := 1 To nQtdNUE

			If Empty(oModelNUE:GetValue( "NUE_CLTAB", nLinha )) .And. !Empty(oModelNUE:GetValue("NUE_VALOR1", nLinha )) .And.;
			   !Empty(oModelNUE:GetValue("NUE_CPREFT", nLinha ))

				nVlTSPF := oModelNUE:GetValue("NUE_VALOR1", nLinha )

				If nVlTSPF > nMaiorTS
					nMaiorTS := nLinha
				EndIf

				nSaldo := nSaldo - oModelNUE:GetValue("NUE_VALOR1", nLinha)

			EndIf
	Next nLinha

	If !(nSaldo == 0)
		oModelNUE:goLine(nMaiorTS)
		nVlTSPF := oModelNUE:GetValue("NUE_VALOR1")
		cInstanc := "NX1" // controla a instancia de ajuste do saldo no time sheet a partir do caso
		lRet := lRet .And. JurSetValue( oModelNUE, "NUE_VALOR1",, Round(nVlTSPF + nSaldo, TamSX3("NUE_VALOR1")[2] ) )
	EndIf
	cInstanc := ""

EndIf

lRet := lRet .And. J202DescCaso() //Atuliza os descontos do caso

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JANX2_VTS2()
Rotina para recalculo da alteração por período opção 2=Ultimo*
para os Participantes do caso da pré-fatura
*Obs: A funcionalidade para participante não se aplica a opção 2=Ultimo
o comportamento é igual para a opção 1=Tempo

@param      oModel

@Return		lRet 	.T. se a alteração teve êxito.

@author Luciano Pereira dos santos
@since 15/01/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JANX2_VTS2(oModel)
Local lRet       := .T.
Local nPos       := 0
Local oModelNX2  := Nil
Local oModelNX1  := Nil
Local oModelNX8  := Nil
Local oModelNX0  := Nil
Local oModelNUE  := Nil
Local cX2Cli     := ""
Local cX2Loja    := ""
Local cX2Caso    := ""
Local cX2Part    := ""
Local nX2Valor   := ""
Local cX2CodSeq  := ""
Local cX2CLTab   := ""
Local cX2Categ   := ""
Local cX2MOTBH   := ""
Local nAjuste    := 0
Local nLineNUE   := 0
Local nMaiorTS   := 0
Local nMaiorVl   := 0
Local nDifVlr    := 0
Local nSaldo     := 0
Local nI         := 0
Local nQtdNUE    := 0
Local nDecNUEVl1 := 0
Local lShowTela  := .F.
Local nTSFora    := 0

Default oModel   := FwModelActive()

	oModelNUE	:= oModel:GetModel("NUEDETAIL")
	oModelNX2	:= oModel:GetModel("NX2DETAIL")
	oModelNX1	:= oModel:GetModel("NX1DETAIL")
	oModelNX8	:= oModel:GetModel("NX8DETAIL")
	oModelNX0	:= oModel:GetModel("NX0MASTER")

	cX2Cli 		:= oModelNX2:GetValue( "NX2_CCLIEN" )
	cX2Loja 	:= oModelNX2:GetValue( "NX2_CLOJA"  )
	cX2Caso		:= oModelNX2:GetValue( "NX2_CCASO"  )
	cX2Part		:= oModelNX2:GetValue( "NX2_CPART"  )
	nX2Valor	:= oModelNX2:GetValue( "NX2_VALORH"  )
	cX2CodSeq	:= oModelNX2:GetValue( "NX2_CODSEQ" )
	cX2CLTab	:= oModelNX2:GetValue( "NX2_CLTAB"  )
	cX2Categ	:= oModelNX2:GetValue( "NX2_CCATEG" )
	cX2MOTBH	:= oModelNX2:GetValue( "NX2_CMOTBH" )

	nPos := aScan( aPart, { |x| x[ 1] == cX2Cli .And. ;
								x[ 2] == cX2Loja .And. ;
								x[ 3] == cX2Caso .And. ;
								x[ 4] == cX2Part .And. ;
								x[ 5] == nX2Valor .And. ;
								x[10] == cX2CodSeq .And. ;
								x[13] == cX2CLTab .And. ;
								x[14] == cX2Categ .And. ;
								x[21] == cX2MOTBH} )

    If nPos > 0
		nTSFora  := J202NTSFORA(oModelNUE, {cX2Part, nX2Valor, cX2Categ, cX2MOTBH, cX2CLTab})
		nSaldo   := oModelNX2:GetValue( "NX2_VALOR1" )
		nAjuste  := (nSaldo - nTSFora) / (aPart[nPos][6] - nTSFora)
		nDifVlr  := (nSaldo - nTSFora) - (aPart[nPos][6] - nTSFora)

		nMaiorTS := 0

		If nSaldo < 0
			lRet := JurMsgErro(J202PartCl(oModel, nTSFora))
		EndIf

		If lRet .And. nDifVlr > 0
			lRet := JurMsgErro(STR0097) // Não é possível efetuar a alteração, pois o valor novo é maior do que o antigo
		EndIf

		If lRet

			nQtdNUE     := oModelNUE:Length()
			nDecNUEVl1  := TamSX3("NUE_VALOR1")[2]

			For nI := 1 To nQtdNUE

				If  cX2Part == oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CPART2], nI ) .And. ;
					nX2Valor == oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALORH], nI ) .And. ;
					cX2Categ == oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CCATEG], nI ) .And. ;
					cX2MOTBH == oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CMOEDA], nI ) .And. ;
					cX2CLTab == oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CLTAB], nI  ) .And.;
					JA202TEMPO( .F., oModelNUE:GetValue('NUE_CATIVI', nI)) .And.;
					J202ATIVID( "2", oModelNUE:GetValue('NUE_CATIVI', nI)) == "1" .And.;
					oModelNUE:GetValue("NUE_COBRAR", nI) == "1" .And.;
					!oModelNUE:IsDeleted(nI) .And. oModelNUE:GetValue("NUE_VALOR1", nI) > 0

					oModelNUE:goLine(ni)

					nVlTS :=  oModelNUE:GetValue("NUE_VALOR1")

					If nMaiorTS == 0
						nLineNUE := oModelNUE:nLine
						nMaiorVl := nVlTS
						nMaiorTS := nI
					EndIf

					If nVlTS > nMaiorVl
						nMaiorVl := nVlTS
						nMaiorTS := nI
					EndIf

					lRet   := lRet .And. JurSetValue( oModelNUE, "NUE_VALOR1",, Round(nVlTS * nAjuste, nDecNUEVl1 ) )
					nSaldo := nSaldo - oModelNUE:GetValue("NUE_VALOR1")

				EndIf

			Next

			If !(nSaldo == 0)
				oModelNUE:goLine(nMaiorTS)
				nVlTS := oModelNUE:GetValue("NUE_VALOR1")
				JurSetValue( oModelNUE, "NUE_VALOR1",, Round(nVlTS + nSaldo, nDecNUEVl1 ) )
			EndIf

			oModelNUE:goLine(nLineNUE)

			If !IsInCallStack("JANX1_VTS") .And. !IsInCallStack("JANX8_VTS") .And. !IsInCallStack("JANX0_VTS")
				lRet := lRet .And. __JurLoadValue( oModelNX1, __aNX1PosFields[POS_NX1_VTS], Round( oModelNX1:GetValueByPos(__aNX1PosFields[POS_NX1_VTS] ) + nDifVlr, nDecNUEVl1 ), lShowTela )
				lRet := lRet .And. JurLoadValue( oModelNX8, "NX8_VTS" ,, Round( oModelNX8:GetValue("NX8_VTS")  - nDifVlr, TamSX3("NX8_VTS")[2] )  )
				lRet := lRet .And. JurLoadValue( oModelNX8, "NX8_VHON",, Round( oModelNX8:GetValue("NX8_VHON") - nDifVlr, TamSX3("NX8_VHON")[2] )  )
				lRet := lRet .And. JurLoadValue( oModelNX0, "NX0_VTS" ,, Round( oModelNX0:GetValue("NX0_VTS")  - nDifVlr, TamSX3("NX0_VTS")[2] )  )
				lRet := lRet .And. JurLoadValue( oModelNX0, "NX0_VLFATH",, Round( oModelNX0:GetValue("NX0_VLFATH") - nDifVlr, TamSX3("NX0_VLFATH")[2] )  )

				//Atualiza os descontos superiores
				lRet := lRet .And. J202DescCaso()
				lRet := lRet .And. J202DescContr()
				lRet := lRet .And. J202DescPre()
				lRet := lRet .And. J202DivCas("NX1") // Ajusta o rateio no campo NX1_VHON

			EndIf

			aPart[nPos][05] := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_VALORH] )
			aPart[nPos][06] := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_VALOR1] )
			aPart[nPos][07] := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_UTR]    )
			aPart[nPos][08] := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_TEMPOR] )
			aPart[nPos][09] := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_HORAR]  )
		EndIf
	Else
		lRet := JurMsgErro(STR0236) // "Participante não ajustado"
	EndIf

Return lRet

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                FUNÇÕES ALTERAÇÃO POR PERIODO OPÇÃO 2 = "ULTIMO" - FIM                                 //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                FUNÇÕES ALTERAÇÃO POR PERIODO OPÇÃO 3 = "TODOS" - INICIO                               //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//-------------------------------------------------------------------
/*/{Protheus.doc} JANX0_VTS3()
Rotina para recalculo da alteração por período opção 3=Todos da pré-fatura

@params    oModel     , Modelo de dados ativo
@params    lNewProcess, Indica se está sendo aberto um novo MsNewProcess

@Return    lRet       , .T. se a alteração teve êxito.

@author Luciano Pereira dos Santos
@since 15/01/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JANX0_VTS3(oModel, lNewProcess)
Local lRet          := .T.
Local nPos          := 0
Local oModelNX0     := Nil
Local oModelNX8     := Nil
Local nVlrPre       := 0
Local nAjuste       := 0
Local nSaldo        := 0
Local nI            := 0
Local nVlrContr     := 0
Local nMaiorVl      := 0
Local nMaiorContr   := 0
Local nLineNX8      := 0
Local nDifVlr       := 0
Local nNX8Qtd       := 0
Local nDecNX8VTS    := 0
Local nDecNX8VHN    := 0
Local cPrefat       := ""

Default oModel      := FwModelActive()
Default lNewProcess := .F.

	If lNewProcess
		__oProcess:SetRegua1(__nQtdNX1)
		__oProcess:SetRegua2(__nQtdNUE)
	EndIf

	oModelNX0 := oModel:GetModel("NX0MASTER")

	For nPos := 1 To Len(aCasos)
		nVlrPre += aCasos[nPos][6]
	Next nPos

	nSaldo  := oModelNX0:GetValue( "NX0_VTS" )
	cPreFat := oModelNX0:GetValue( "NX0_COD" )

	If nSaldo < 0
		lRet := JurMsgErro(STR0169) //"Informe um valor positivo!"
	Else
		If nSaldo > nVlrPre
			lRet := JurMsgErro(STR0097) // Não é possível efetuar a alteração, pois o valor novo é maior do que o antigo
		EndIf
	EndIf

	If lRet

		oModelNX8   := oModel:GetModel("NX8DETAIL")

		nAjuste     := nSaldo / nVlrPre

		nLineNX8    := oModelNX8:nLine
		nMaiorVl    := oModelNX8:GetValue("NX8_VTS")
		nMaiorContr := nLineNX8

		nNX8Qtd     := oModelNX8:Length()
		nDecNX8VTS  := TamSX3("NX8_VTS")[2]
		nDecNX8VHN  := TamSX3("NX8_VHON")[2]

		For nI := 1 To nNX8Qtd

			If oModelNX8:GetValue("NX8_TS", nI) == "1"

				oModelNX8:goLine(nI)

				nVlrContr := oModelNX8:GetValue("NX8_VTS")

				If nVlrContr > nMaiorVl
					nMaiorVl    := nVlrContr
					nMaiorContr := nI
				EndIf
				nDifVlr := nVlrContr - nVlrContr * nAjuste
				lRet    := lRet .And. JurSetValue( oModelNX8, "NX8_VTS",, Round(nVlrContr * nAjuste, nDecNX8VTS ) )
				nSaldo  := nSaldo - oModelNX8:GetValue("NX8_VTS")

				lRet := lRet .And. JurLoadValue( oModelNX8, "NX8_VHON",, Round(oModelNX8:GetValue("NX8_VHON") - nDifVlr, nDecNX8VHN ) )

				lRet := lRet .And. J202DivCas("NX8") // Ajusta o rateio no campo NX1_VHON
			EndIf

		Next

		If !(nSaldo == 0)
			oModelNX8:goLine(nMaiorContr)
			nVlrContr := oModelNX8:GetValue("NX8_VTS")
			cInstanc := "NX0" // controla a instancia de ajuste do saldo
			lRet := lRet .And. JurSetValue( oModelNX8, "NX8_VTS",, Round(nVlrContr + nSaldo, nDecNX8VTS ) )

			//Verifica se preciso atualizar o array dos Ts filhos com o saldo residual
			lRet := lRet .And. J202AtuFilho("TS", nVlrPre, oModelNX0:GetValue( "NX0_VTS" ))

		EndIf

		lRet := lRet .And. JurLoadValue( oModelNX0, "NX0_VLFATH",, Round( oModelNX0:GetValue("NX0_VLFATH") - nDifVlr, (TamSX3("NX0_VTS")[2]) ) )

		lRet := lRet .And. J202DescPre() //Atualiza dos descontos na Pré-Fatura

		oModelNX8:GoLine(nLineNX8)
		cInstanc := ""

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JANX8_VTS3()
Rotina para recalculo da alteração por período opção 3=Todos para os
contratos da pré-fatura

@params    oModel     , Modelo de dados ativo
@params    lNewProcess, Indica se está sendo aberto um novo MsNewProcess
@params    lTela      , Indica se a chamada foi feita via tela

@Return    lRet       , .T. se a alteração teve exito.

@author Luciano Pereira dos santos
@since 15/01/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JANX8_VTS3(oModel, lNewProcess, lTela)
Local lRet          := .T.
Local nPos          := 0
Local oModelNX0     := Nil
Local oModelNX8     := Nil
Local oModelNX1     := Nil
Local nVlrContr     := 0
Local nAjuste       := 0
Local nSaldo        := 0
Local nI            := 0
Local nVlCaso       := 0
Local nMaiorVl      := 0
Local nMaiorCont    := 0
Local nLineNX1      := 0
Local nDifVlr       := 0
Local nQtdNX1       := 0
Local cContrNX8     := ""

Default oModel      := FwModelActive()
Default lNewProcess := .F.
Default lTela       := .F.

If lNewProcess
	__oProcess:SetRegua1(__nQtdNX1)
	__oProcess:SetRegua2(__nQtdNUE)
EndIf

oModelNX0  := oModel:GetModel("NX0MASTER")
oModelNX8  := oModel:GetModel("NX8DETAIL")
oModelNX1  := oModel:GetModel("NX1DETAIL")

cContrNX8  := oModelNX8:GetValue("NX8_CCONTR")
nSaldo     := oModelNX8:GetValue( "NX8_VTS" )

nDecNX1VTS := TamSX3("NX1_VTS")[2]
nQtdNX1    := oModelNX1:Length()

If Empty(cInstanc)

	For nPos := 1 To Len(aCasos)
		If aCasos[nPos][9] == cContrNX8
			nVlrContr += aCasos[nPos][6]
		EndIf
	Next nPos

	If nSaldo < 0
		lRet := JurMsgErro(STR0169) //"Informe um valor positivo!"
		Return lRet
	Else
		If nSaldo > nVlrContr
			lRet := JurMsgErro(STR0097) // Não é possível efetuar a alteração, pois o valor novo é maior do que o antigo
			Return lRet
		EndIf
	EndIf

	nAjuste    := nSaldo / nVlrContr
	nDifVlr    := nSaldo - nVlrContr

	nLineNX1   := oModelNX1:nLine
	nMaiorVl   := oModelNX1:GetValue("NX1_VTS")
	nMaiorCont := nLineNX1

	For nI := 1 To nQtdNX1

		If lTela
			__oProcess:IncRegua1(i18n(STR0331, {oModelNX1:GetValue("NX1_CCASO", nI), __nCountNX1++, __nQtdNX1} )) // "Atualizando Caso #1 - #2 de #3."
		EndIf

		If oModelNX1:GetValue("NX1_TS", nI) == "1"

			oModelNX1:goLine(nI)

			nVlCaso := oModelNX1:GetValue("NX1_VTS")

			If nVlCaso > nMaiorVl
				nMaiorVl   := nVlCaso
				nMaiorCont := nI
			EndIf

			lRet   := lRet .And. JurSetValue( oModelNX1, "NX1_VTS",, Round(nVlCaso * nAjuste, nDecNX1VTS ) )
			nSaldo := nSaldo - oModelNX1:GetValue("NX1_VTS")

		EndIf

	Next

	If !(nSaldo == 0)
		oModelNX1:goLine(nMaiorCont)
		nVlCaso  := oModelNX1:GetValue("NX1_VTS")
		cInstanc := "NX8" // controla a instancia de ajuste do saldo no caso a apartir do contrato
		lRet := lRet .And. JurSetValue( oModelNX1, "NX1_VTS",, Round(nVlCaso + nSaldo, nDecNX1VTS ) )
	EndIf

	oModelNX1:goLine(nLineNX1)

	If !IsInCallStack("JANX0_VTS")
		lRet := lRet .And. JurLoadValue( oModelNX0, "NX0_VTS" ,, Round( oModelNX0:GetValue("NX0_VTS") + nDifVlr, (TamSX3("NX0_VTS")[2]) ) )
		lRet := lRet .And. JurLoadValue( oModelNX8, "NX8_VHON",, Round( oModelNX8:GetValue("NX8_VHON") + nDifVlr, (TamSX3("NX8_VHON")[2]) ) )
		lRet := lRet .And. JurLoadValue( oModelNX0, "NX0_VLFATH",, Round( oModelNX0:GetValue("NX0_VLFATH") + nDifVlr, (TamSX3("NX0_VLFATH")[2]) ) )
		lRet := lRet .And. J202DivCas("NX8") // Ajusta o rateio no campo NX1_VHON
	EndIf
	cInstanc := ""

ElseIf cInstanc == "NX0" //Tratamento para evitar que o saldo crie novos time sheets filhos com valor ajuste

	For nPos := 1 To Len(aCasos)
		If aCasos[nPos][9] == cContrNX8
			nVlrContr += aCasos[nPos][6]
		EndIf
	Next nPos

	nDifVlr    := nSaldo - nVlrContr
	nLineNX1   := oModelNX1:nLine
	nMaiorVl   := oModelNX1:GetValue("NX1_VTS")
	nMaiorCont := nLineNX1

	For nI := 1 To nQtdNX1

		If lTela
			__oProcess:IncRegua1(i18n(STR0331, {oModelNX1:GetValue("NX1_CCASO", nI), __nCountNX1++, __nQtdNX1} )) // "Atualizando Caso #1 - #2 de #3."
		EndIf

		If oModelNX1:GetValue("NX1_TS", nI) == "1"

			nVlCaso := oModelNX1:GetValue("NX1_VTS", nI)

			If nVlCaso > nMaiorVl
				nMaiorVl   := nVlCaso
				nMaiorCont := nI
			EndIf

			nSaldo := nSaldo - nVlCaso

		EndIf

	Next

	If !(nSaldo == 0)
		oModelNX1:goLine(nMaiorCont)
		nVlCaso := oModelNX1:GetValue("NX1_VTS")
		cInstanc := "NX8" // controla a instancia de ajuste do saldo no caso a partir do contrato
		lRet := lRet .And. JurSetValue( oModelNX1, "NX1_VTS",, Round(nVlCaso + nSaldo, nDecNX1VTS ) )
	EndIf

	oModelNX1:goLine(nLineNX1)
	cInstanc := ""
EndIf

lRet := lRet .And. J202DescContr() //Atualiza o desconto no contrato

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JANX1_VTS3()
Rotina para recalculo da alteração por período opção 3=Todos para os
contratos da pré-fatura

@params    oModel     , Modelo de dados ativo
@params    lNewProcess, Indica se está sendo aberto um novo MsNewProcess
@params    lTela      , Indica se a chamada foi feita via tela

@Return    lRet       , .T. se a alteração teve êxito.

@author Luciano Pereira dos santos
@since 15/01/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JANX1_VTS3(oModel, lNewProcess, lTela)
Local lRet          := .T.
Local aArea         := GetArea()
Local oModelNX1     := Nil
Local oModelNX8     := Nil
Local oModelNX0     := Nil
Local oModelNUE     := Nil
Local oStrucNUE     := Nil
Local aStrucNUE     := {}
Local cClient       := ""
Local cLoja         := ""
Local cCaso         := ""
Local cContr        := ""
Local nLineNUE      := 1
Local nPos          := 0
Local nPosAlt       := 0
Local nI            := 0
Local nSaldo        := 0
Local nVlrCaso      := 0
Local nVlTSPre      := 0
Local nVlFilho      := 0
Local nUTR          := 0
Local nUTL          := 0
Local nUTLFilho     := 0
Local nUTLPai       := 0
Local nDifVlr       := 0
Local nMaiorVl      := 0
Local nMaiorTS      := 0
Local nTSFora       := 0 //Valor de time sheets que não devem ser considerados na conta.
Local nNUEQtdLn     := 0
Local cJurUser      := JurUsuario(__CUSERID)

Default oModel      := FwModelActive()
Default lNewProcess := .F.
Default lTela       := .F.

If lNewProcess
	__oProcess:SetRegua1(__nQtdNX1)
	__oProcess:SetRegua2(__nQtdNUE)
EndIf

oModelNX0 := oModel:GetModel("NX0MASTER")
oModelNX8 := oModel:GetModel("NX8DETAIL")
oModelNX1 := oModel:GetModel("NX1DETAIL")
oModelNUE := oModel:GetModel("NUEDETAIL")

cClient   := oModelNX1:GetValue("NX1_CCLIEN")
cLoja     := oModelNX1:GetValue("NX1_CLOJA")
cCaso     := oModelNX1:GetValue("NX1_CCASO")
cContr    := oModelNX1:GetValue("NX1_CCONTR")

oStrucNUE := oModelNUE:GetStruct()
aStrucNUE := oStrucNUE:GetFields()

If Empty(cInstanc)
	//Verifica se houve alguma alteração de periodo que não foi confirmada
	nPosAlt := aScan( aAltPend, {|x| x[1] == 'TS' .And. x[2] == cClient .And. x[3] == cLoja .And. x[4] == cCaso .And. x[5] == cContr })

	If nPosAlt > 0
		lRet := JurMsgErro(STR0170) //"Existem alterações de valor pendentes, para efetuar novas alterações cancele as anteriores!"
		Return lRet
	EndIf

	//Retorna a posição da variável aCasos (encapsulado aScan no vetor aCasos para poder depurar a função)
	nPos := J202ACSPOS(cClient, cLoja, cCaso, cContr)

	If nPos > 0

		nTSFora   := J202NTSFORA(oModelNUE)
		nSaldo    := oModelNX1:GetValue( "NX1_VTS" ) - nTSFora
		nVlrCaso  := aCasos[nPos][6] - nTSFora

		If nSaldo < 0
			lRet := JurMsgErro(STR0169)	//"Informe um valor positivo!"
			Return lRet
		Else
			If nSaldo > nVlrCaso
				lRet := JurMsgErro(STR0097)	// Não é possível efetuar a alteração, pois o valor novo é maior do que o antigo
				Return lRet
			EndIf
		EndIf

		nAjuste := nSaldo / (aCasos[nPos][6] - nTSFora)
		nDifVlr := nSaldo - (aCasos[nPos][6] - nTSFora)

		nNUEQtdLn := oModelNUE:GetQtdLine()

		//Posiciona na primeira linha válida
		While (nMaiorTS == 0 .And. nLineNUE < nNUEQtdLn .And. !JA202TEMPO( .F., oModelNUE:GetValue( 'NUE_CATIVI', nLineNUE )) ;
						.And. (oModelNUE:GetValue("NUE_COBRAR", nLineNUE) == "2" .Or. J202ATIVID("2", oModelNUE:GetValue( 'NUE_CATIVI', nLineNUE )) == "2" ) )
			nLineNUE++
		EndDo

		nMaiorVl := oModelNUE:GetValue("NUE_VALOR1", nLineNUE)
		nMaiorTS := nLineNUE

		If !oModelNUE:IsEmpty()

			For nI := nLineNUE To nNUEQtdLn

				If lTela
					__oProcess:IncRegua2(i18n(STR0332, {__nCountNUE++, __nQtdNUE} )) // "Atualizando valores dos lançamentos - #1 de #2."
				EndIf

				If !oModelNUE:IsDeleted(nI) .And. oModelNUE:GetValue( "NUE_VALOR", nI ) > 0 .And. JA202TEMPO( .F., oModelNUE:GetValue( 'NUE_CATIVI', nI ) ) ;
					 .And. oModelNUE:GetValue("NUE_COBRAR", nI) == "1" .And. J202ATIVID("2", oModelNUE:GetValue( 'NUE_CATIVI', nI )) == "1"

					oModelNUE:goLine(nI)

					nVlTSPre := oModelNUE:GetValue("NUE_VALOR1")
					nVlTS    := oModelNUE:GetValue("NUE_VALOR")

					nUTR := oModelNUE:GetValue( "NUE_UTR" )
					nUTL := oModelNUE:GetValue( "NUE_UTL" )
					nDecNUEVL1 := TamSX3("NUE_VALOR1")[2]

					If nVlTSPre >= nMaiorVl
						nMaiorVl := nVlTSPre
						nMaiorTS := nI
					EndIf

					If (nVlTS * nAjuste) > 0
						lRet := lRet .And. JurSetValue( oModelNUE, "NUE_VALOR1",, Round(nVlTSPre * nAjuste, nDecNUEVL1 ) )
						nSaldo := nSaldo - oModelNUE:GetValue("NUE_VALOR1")

						nVlFilho  := nVlTS - oModelNUE:GetValue("NUE_VALOR")
						nUTRFilho := nUTR  - oModelNUE:GetValue("NUE_UTR")
						nVlFilho1 := nVlTSPre - oModelNUE:GetValue("NUE_VALOR1")

						//Divide percentualmente a UTL do Pai
						nUTLPai := (oModelNUE:GetValue("NUE_UTL") * (oModelNUE:GetValue("NUE_UTR") / nUTR) )
						lRet := lRet .And. JurLoadValue(oModelNUE, "NUE_UTL"   ,, nUTLPai)
						lRet := lRet .And. JurLoadValue(oModelNUE, "NUE_TEMPOL",, Val(JURA144C1(1, 2, Str(nUTLPai))))
						lRet := lRet .And. JurLoadValue(oModelNUE, "NUE_HORAL" ,, JURA144C1(1, 3, Str(nUTLPai)))

						nUTLFilho := nUTL - oModelNUE:GetValue("NUE_UTL")

						//grava o array com o lançamento filho para ser gravado no commit.
						lRet := lRet .And. J202CriaFilho("NUE", oModelNUE, aStrucNUE, oModelNUE:GetValue("NUE_COD"), nI, nVlFilho, nUTRFilho, nUTLFilho, nVlFilho1, cJurUser)
					Else
						If nTSFora > 0
							lRet := JurMsgErro(J202PartCl(oModel, nTSFora ))
						Else
							lRet := JurMsgErro(STR0169) //"informe um valor positivo!"
						EndIf
					EndIf

				EndIf

			Next nI

			If !(nSaldo == 0) .And. lRet
				oModelNUE:goLine(nMaiorTS)
				nVlTSPre := oModelNUE:GetValue("NUE_VALOR1")
				cInstanc := "NX1" // controla a instancia de ajuste do saldo no time sheet a partir do caso
				lRet := lRet .And. JurSetValue( oModelNUE, "NUE_VALOR1",, Round(nVlTSPre + nSaldo, nDecNUEVL1 ) )
			EndIf

			oModelNUE:goLine(nLineNUE)

			If !IsInCallStack("JANX8_VTS") .And. !IsInCallStack("JANX0_VTS")
				lRet := lRet .And. JurLoadValue( oModelNX8, "NX8_VTS",, Round( oModelNX8:GetValue("NX8_VTS") + nDifVlr, (TamSX3("NX8_VTS")[2]) )  )
				lRet := lRet .And. JurLoadValue( oModelNX8, "NX8_VHON",, Round(oModelNX8:GetValue("NX8_VHON") + nDifVlr, (TamSX3("NX8_VHON")[2]) )  )
				lRet := lRet .And. JurLoadValue( oModelNX0, "NX0_VTS",, Round( oModelNX0:GetValue("NX0_VTS") + nDifVlr, (TamSX3("NX0_VTS")[2]) )  )
				lRet := lRet .And. JurLoadValue( oModelNX0,  "NX0_VLFATH",, Round( oModelNX0:GetValue("NX0_VLFATH") + nDifVlr, (TamSX3("NX0_VLFATH")[2]) )  )
				lRet := lRet .And. J202DivCas("NX1") // Ajusta o rateio no campo NX1_VHON
			EndIf

			aCasos[nPos][06] := oModelNX1:GetValue( "NX1_VTS" )

			//aAltPend [1] Tipo [2] Cliente [3] Loja [4] Caso [5] Contrato
			aAdd(aAltPend , {'TS', cClient, cLoja, cCaso, cContr } )
			cInstanc := ""

		EndIf
	Else
		lRet := JurMsgErro(STR0235) // "Caso não ajustado"
	EndIf

ElseIf cInstanc == "NX8" //Tratamento para evitar que o saldo crie novos time sheets filhos com valor ajuste

	nSaldo    := oModelNX1:GetValue( "NX1_VTS" )
	nNUEQtdLn := oModelNUE:Length()

	For nI := 1 To nNUEQtdLn

		If oModelNUE:GetValue( "NUE_VALOR", nI ) > 0

			nVlTSPre := oModelNUE:GetValue("NUE_VALOR1", nI)
			nVlTS    := oModelNUE:GetValue("NUE_VALOR", nI)

			If nVlTSPre > nMaiorVl
				nMaiorVl := nVlTSPre
				nMaiorTS := nI
			EndIf

			nSaldo := nSaldo - nVlTSPre

		EndIf
	Next nI

	If !(nSaldo == 0)
		oModelNUE:GoLine(nMaiorTS)
		nVlTSPre := oModelNUE:GetValue("NUE_VALOR1")
		cInstanc := "NX1" // controla a instancia de ajuste do saldo no time sheet a partir do caso
		lRet := lRet .And. JurSetValue( oModelNUE, "NUE_VALOR1",, Round(nVlTSPre + nSaldo, (TamSX3("NUE_VALOR1")[2]) ) )
	EndIf

	cInstanc := ""

EndIf

lRet := lRet .And. J202DescCaso() //Atualiza os descontos do caso

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JANX2_VTS3()
Rotina para recalculo da alteração por período opção 3=Todos*
para os Participantes do caso da pré-fatura

*Obs: A funcionalidade para participante não se aplica a opção 3=Todos
o comportamento é igual para a opção 1=Tempo

@Params	    nil

@Return		lRet 	.T. se a alteração teve êxito.

@author Luciano Pereira dos santos
@since 15/01/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JANX2_VTS3(oModel)
Local lRet       := .T.
Local nPos       := 0
Local oModelNX2  := Nil
Local oModelNX1  := Nil
Local oModelNX8  := Nil
Local oModelNX0  := Nil
Local oModelNUE  := Nil
Local cX2Cli     := ""
Local cX2Loja    := ""
Local cX2Caso    := ""
Local cX2Part    := ""
Local nX2Valor   := ""
Local cX2CodSeq  := ""
Local cX2CLTab   := ""
Local cX2Categ   := ""
Local cX2MOTBH   := ""
Local nAjuste    := 0
Local nLineNUE   := 0
Local nMaiorTS   := 0
Local nMaiorVl   := 0
Local nDifVlr    := 0
Local nSaldo     := 0
Local nI         := 0
Local nQtdNUE    := 0
Local nDecNUEVl1 := 0
Local lShowTela  := .F.
Local nTSFora    := 0

Default oModel   := FwModelActive()

	oModelNUE   := oModel:GetModel("NUEDETAIL")
	oModelNX2   := oModel:GetModel("NX2DETAIL")
	oModelNX1   := oModel:GetModel("NX1DETAIL")
	oModelNX8   := oModel:GetModel("NX8DETAIL")
	oModelNX0   := oModel:GetModel("NX0MASTER")

	cX2Cli      := oModelNX2:GetValue( "NX2_CCLIEN" )
	cX2Loja     := oModelNX2:GetValue( "NX2_CLOJA"  )
	cX2Caso     := oModelNX2:GetValue( "NX2_CCASO"  )
	cX2Part     := oModelNX2:GetValue( "NX2_CPART"  )
	nX2Valor    := oModelNX2:GetValue( "NX2_VALORH"  )
	cX2CodSeq   := oModelNX2:GetValue( "NX2_CODSEQ" )
	cX2CLTab    := oModelNX2:GetValue( "NX2_CLTAB"  )
	cX2Categ    := oModelNX2:GetValue( "NX2_CCATEG" )
	cX2MOTBH    := oModelNX2:GetValue( "NX2_CMOTBH" )

	nPos := aScan( aPart, { |x| x[ 1] == cX2Cli .And. ;
								x[ 2] == cX2Loja .And. ;
								x[ 3] == cX2Caso .And. ;
								x[ 4] == cX2Part .And. ;
								x[ 5] == nX2Valor .And. ;
								x[10] == cX2CodSeq .And. ;
								x[13] == cX2CLTab .And. ;
								x[14] == cX2Categ .And. ;
								x[21] == cX2MOTBH} )

	If nPos > 0
		nTSFora := J202NTSFORA(oModelNUE, {cX2Part, nX2Valor, cX2Categ, cX2MOTBH, cX2CLTab})
		nSaldo  := (oModelNX2:GetValue( "NX2_VALOR1" ) - nTSFora)
		nAjuste := nSaldo / (aPart[nPos][6] - nTSFora)
		nDifVlr := nSaldo - (aPart[nPos][6] - nTSFora)

		nMaiorTS := 0

		If nSaldo < 0
			lRet := JurMsgErro(J202PartCl(oModel, nTSFora ))
		EndIf

		If lRet .And. nDifVlr > 0
			lRet := JurMsgErro(STR0097) // Não é possível efetuar a alteração, pois o valor novo é maior do que o antigo
		EndIf

		If lRet

			nQtdNUE    := oModelNUE:Length()
			nDecNUEVl1 := TamSX3("NUE_VALOR1")[2]

			For nI := 1 To nQtdNUE

				If cX2Part == oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CPART2], nI ) .And. ;
					nX2Valor == oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALORH], nI ) .And. ;
					cX2Categ == oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CCATEG], nI ) .And. ;
					cX2MOTBH == oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CMOEDA], nI ) .And. ;
					cX2CLTab == oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CLTAB], nI ) .And.;
					JA202TEMPO( .F., oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CATIVI], nI)) .And.;
					J202ATIVID("2", oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CATIVI], nI)) == "1" .And.;
					oModelNUE:GetValue("NUE_COBRAR", nI) == "1" .And.;
					!oModelNUE:IsDeleted(nI) .And. oModelNUE:GetValue("NUE_VALOR1", nI) > 0

					oModelNUE:goLine(nI)

					nVlTS :=  oModelNUE:GetValue("NUE_VALOR1")

					If nMaiorTS == 0
						nLineNUE := oModelNUE:nLine
						nMaiorVl := nVlTS
						nMaiorTS := nI
					EndIf

					If nVlTS > nMaiorVl
						nMaiorVl := nVlTS
						nMaiorTS := nI
					EndIf

					lRet   := lRet .And. JurSetValue( oModelNUE, "NUE_VALOR1",, Round(nVlTS * nAjuste, nDecNUEVl1 ) )
					nSaldo := nSaldo - oModelNUE:GetValue("NUE_VALOR1")

				EndIf

			Next

			If !(nSaldo == 0)
				oModelNUE:goLine(nMaiorTS)
				nVlTS := oModelNUE:GetValue("NUE_VALOR1")
				JurSetValue( oModelNUE, "NUE_VALOR1",, Round(nVlTS + nSaldo, nDecNUEVl1 ) )
			EndIf

			oModelNUE:goLine(nLineNUE)

			If !IsInCallStack("JANX1_VTS") .And. !IsInCallStack("JANX8_VTS") .And. !IsInCallStack("JANX0_VTS")
				lRet := lRet .And. __JurLoadValue( oModelNX1, __aNX1PosFields[POS_NX1_VTS], Round( oModelNX1:GetValueByPos(__aNX1PosFields[POS_NX1_VTS] ) + nDifVlr, TamSX3("NX1_VTS")[2]), lShowTela )
				lRet := lRet .And. JurLoadValue( oModelNX8, "NX8_VTS" ,, Round( oModelNX8:GetValue("NX8_VTS")  - nDifVlr, (TamSX3("NX8_VTS")[2]) )  )
				lRet := lRet .And. JurLoadValue( oModelNX8, "NX8_VHON",, Round( oModelNX8:GetValue("NX8_VHON") - nDifVlr, (TamSX3("NX8_VHON")[2]) )  )
				lRet := lRet .And. JurLoadValue( oModelNX0, "NX0_VTS" ,, Round( oModelNX0:GetValue("NX0_VTS")  - nDifVlr, (TamSX3("NX0_VTS")[2]) )  )
				lRet := lRet .And. JurLoadValue( oModelNX0, "NX0_VLFATH",, Round( oModelNX0:GetValue("NX0_VLFATH") - nDifVlr, (TamSX3("NX0_VLFATH")[2]) )  )

				//Atualiza os descontos superiores
				lRet := lRet .And. J202DescCaso()
				lRet := lRet .And. J202DescContr()
				lRet := lRet .And. J202DescPre()
				lRet := lRet .And. J202DivCas("NX1") // Ajusta o rateio no campo NX1_VHON

			EndIf

			aPart[nPos][05] := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_VALORH] )
			aPart[nPos][06] := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_VALOR1] )
			aPart[nPos][07] := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_UTR]    )
			aPart[nPos][08] := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_TEMPOR] )
			aPart[nPos][09] := oModelNX2:GetValueByPos(__aNX2PosFields[POS_NX2_HORAR]  )
		EndIf
	Else
		lRet := JurMsgErro(STR0236) // "Participante não ajustado"
	EndIf

Return lRet

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                FUNÇÕES ALTERAÇÃO POR PERIODO OPÇÃO 3 = "TODOS" - FIM                                  //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//-------------------------------------------------------------------
/*/{Protheus.doc} J202CriaFilho()
Rotina para popular o array aLancDiv estatico com os lançamentos divididos das
operações referentes a ajuste por periodo 2=Ultimo e 3=Todos para
Time Sheets e Despesas.

@Param     cAlias     alias da tabela do lançamento filho "NUE" ou "NVY";
@Param     cCodPai    Código do lançamento pai
@Param     oModelXXX  Modelo do lançaemnto
@Param     aStrucXXX  Modelo do lançaemnto
@Param     nLinha     Número da linha no grid do TS pai
@Param     nVlFilho   Valor dividido do lançamento filho
@Param     nUTFilho   Valor da UT do lançamento Filho (somente TS)
@Param     nVlFilho1  Valor dividido do lançamento filho na Pré-fatura (somente TS)

@Return	lRet .T. o carregamento do array filho teve exito.

@author Luciano Pereira dos santos
@since 15/01/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static function J202CriaFilho(cAlias, oModelXXX, aStrucXXX, cCodPai, nLinha, nVlFilho, nUTRFilho, nUTLFilho, nVlFilho1, cJurUser)
Local lRet        := .T.
Local nI          := 0
Local aCampos     := {}
Local nTmpRFilho  := 0
Local cHrRFilho   := ""
Local nTmpLFilho  := 0
Local cHrLFilho   := ""
Local dDataAlt
Local cStructCpo  := ""
Local cUsuAlt     := ""
Local cHoraAlt    := ""
Local aCpsNRepli  := {}

Default nUTRFilho := 0
Default nUTLFilho := 0
Default nVlFilho1 := 0
Default cJurUser  := ""

//Campos utilizados na rotina:
If cAlias == 'NUE'
	cCpCod     := "NUE_COD"
	cCpValor   := "NUE_VALOR"
	cCpDivid   := "NUE_TSDIV"
	cCpCodPai  := "NUE_CODPAI"
	cCpPrefat  := "NUE_CPREFT"
	nTmpRFilho := Val(JURA144C1( 1, 2, Str(nUTRFilho)))
	cHrRFilho  := JURA144C1( 1, 3, Str(nUTRFilho))
	nTmpLFilho := Val(JURA144C1( 1, 2, Str(nUTLFilho)))
	cHrLFilho  := JURA144C1( 1, 3, Str(nUTLFilho))
	dDataAlt   := Date()
	cUsuAlt    := cJurUser
	cHoraAlt   := Time()
	aCpsNRepli := {'NUE_DATAIN', 'NUE_HORAIN', 'NUE_ALTDT', 'NUE_CUSERA', 'NUE_VTSANT',;
	               'NUE_ALTHR', 'NUE_CODLD', 'NUE_CREPRO', 'NUE_CDWOLD', 'NUE_OBSWO',;
	               'NUE_CMOTWO', 'NUE_PARTLD', 'NUE_ACAOLD', 'NUE_CCLILD', 'NUE_CLJLD',;
	               'NUE_CCSLD', 'NUE_REVISA', 'NUE_FLUREV', 'NUE_DTREPR', 'NUE_CRETIF'}

ElseIf cAlias == 'NVY'
	cCpCod     := "NVY_COD"
	cCpValor   := "NVY_VALOR"
	cCpDivid   := "NVY_DESDIV"
	cCpCodPai  := "NVY_CODPAI"
	cCpPrefat  := "NVY_CPREFT"
	nTmpRFilho := 0
	cHrRFilho  := ""
	nTmpLFilho := 0
	cHrLFilho  := ""
Else
	lRet := .F.
	Return lRet
EndIf

For nI := 1 To Len(aStrucXXX)
	cStructCpo := AllTrim(aStrucXXX[nI][MODEL_FIELD_IDFIELD])
	Do Case
		Case cStructCpo == cCpCod   // Código
			aAdd(aCampos, {cStructCpo , "" } )
		Case cStructCpo == "NUE_VALOR1"
			aAdd(aCampos, {cStructCpo , nVlFilho1 } )
		Case cStructCpo == "NUE_UTL"
			aAdd(aCampos, {cStructCpo , nUTLFilho } )
		Case cStructCpo == "NUE_UTR"
			aAdd(aCampos, {cStructCpo , nUTRFilho } )
		Case cStructCpo == "NUE_TEMPOL"
			aAdd(aCampos, {cStructCpo , nTmpLFilho} )
		Case cStructCpo == "NUE_TEMPOR"
			aAdd(aCampos, {cStructCpo , nTmpRFilho} )
		Case cStructCpo == "NUE_HORAL"
			aAdd(aCampos, {cStructCpo , cHrLFilho } )
		Case cStructCpo == "NUE_HORAR"
			aAdd(aCampos, {cStructCpo , cHrRFilho } )
		Case cStructCpo == cCpValor
			aAdd(aCampos, {cStructCpo , nVlFilho  } )
		Case cStructCpo == cCpPrefat
			aAdd(aCampos, {cStructCpo , ""        } )
		Case cStructCpo == cCpDivid
			aAdd(aCampos, {cStructCpo , "1"       } )
		Case cStructCpo == cCpCodPai
			aAdd(aCampos, {cStructCpo , cCodPai   } )
		Case cStructCpo == "NUE_ALTDT"
			aAdd(aCampos, {cStructCpo , dDataAlt  } )
		Case cStructCpo == "NUE_CUSERA"
			aAdd(aCampos, {cStructCpo, cUsuAlt   } )
		Case cStructCpo == "NUE_ALTHR"
			aAdd(aCampos, {cStructCpo, cHoraAlt  } )
		Otherwise
			If !(aStrucXXX[nI][MODEL_FIELD_VIRTUAL]) // Se não é campo virtual
				If (aScan(aCpsNRepli, {|aY| aY == cStructCpo}) == 0) // Se NÃO for um dos campos não replicáveis
					aAdd(aCampos, {cStructCpo, oModelXXX:GetValue(cStructCpo, nLinha) } )
				ElseIf (aStrucXXX[nI][MODEL_FIELD_INIT]) <> Nil     // Executa o inicializar padrão dos campos não replicáveis
					aAdd(aCampos, {cStructCpo, oModelXXX:InitValue(cStructCpo, nLinha) } )
				EndIf
			EndIf
	EndCase
Next nI

If Len(aCampos) > 0
	aAdd(aLancDiv, aCampos) // Alimenta o array de lançamentos divididos para serem gravados no commit do Browser
Else
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202DescCaso()
Rotina para corrigir os descontos no caso da pré-fatura (alteração por período)

@Param	    Nil

@Return		lRet 	.T. se a alteração teve Ãªxito.

@author Luciano Pereira dos santos
@since 16/01/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202DescCaso()
Local lRet       := .T.
Local aArea      := GetArea()
Local oModel     := If(oModelOld = Nil, FwModelActive(), oModelOld)
Local oModelNX0  := oModel:Getmodel('NX0MASTER')
Local oModelNX1  := oModel:Getmodel('NX1DETAIL')
Local nValBaseD  := 0 // Base de cálculo para o valor de desconto especial (VTS + VFIXO - Desc Linear)
Local cTipoDesc  := ''

//Atualiza o valor do Desc Linear
lRet := JurLoadValue(oModel, "NX1DETAIL", "NX1_VDESCO", Round(oModelNX1:GetValue("NX1_VTS") * oModelNX1:GetValue("NX1_PDESCH") / 100, TamSX3("NX1_VDESCO")[2]) )

cTipoDesc := oModelNX0:GetValue("NX0_TPDESC")

If !Empty(cTipoDesc)
	nValBaseD := oModelNX1:GetValue("NX1_VTS") + oModelNX1:GetValue("NX1_VFIXO") - oModelNX1:GetValue("NX1_VDESCO")
	//Atualiza valor/percentual do Desconto Especial
	If cTipoDesc == "2" // se por percentual, faz a correção de valor do desconto
		IIF(lRet, lRet := J202LoadVl(oModelNX1, "NX1_VLDESC", Round(oModelNX1:GetValue("NX1_PCDESC") * nValBaseD / 100, TamSX3("NX1_VLDESC")[2])), )
	Else
		IIF(lRet, lRet := J202LoadVl(oModelNX1, "NX1_PCDESC", Round(oModelNX1:GetValue("NX1_VLDESC") / nValBaseD * 100, TamSX3("NX1_PCDESC")[2])), )
	EndIf
EndIf

//Atualiza o Desconto Total
IIF(lRet, lRet := J202LoadVl(oModelNX1, "NX1_VDESCT", Round( oModelNX1:GetValue("NX1_VDESCO") + oModelNX1:GetValue("NX1_VLDESC"), TamSX3("NX1_VDESCT")[2]) ), )

If lRet .And. (oModelNX1:GetValue("NX1_VTS") + oModelNX1:GetValue("NX1_VFIXO")) < oModelNX1:GetValue("NX1_VDESCT")
	lRet := JurMsgErro( STR0190 + CRLF +;
	                    JA207TitCamp("NX1_CCONTR") + ': ' + oModelNX1:GetValue("NX1_CCONTR") + CRLF +;
	                    JA207TitCamp("NX1_CCLIEN") + ': ' + oModelNX1:GetValue("NX1_CCLIEN") + CRLF +;
	                    JA207TitCamp("NX1_CLOJA")  + ': ' + oModelNX1:GetValue("NX1_CLOJA")  + CRLF +;
	                    JA207TitCamp("NX1_CCASO")  + ': ' + oModelNX1:GetValue("NX1_CCASO")  + CRLF +;
	                    JA207TitCamp("NX1_VDESCO") + ': ' + Alltrim(Str( oModelNX1:GetValue("NX1_VDESCO"))) + CRLF +;
	                    JA207TitCamp("NX1_VLDESC") + ': ' + Alltrim(Str( oModelNX1:GetValue("NX1_VLDESC"))) + CRLF +;
	                    JA207TitCamp("NX1_VTS")    + ': ' + Alltrim(Str( oModelNX1:GetValue("NX1_VTS")));
	                  ) //"A soma do valor de Time Sheet e Fixo deve ser maior que o valor de desconto total! (contrato-clente-loja-caso):"
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202DescContr()
Rotina para corrigir os descontos no contrato da pré-fatura (alteração por período)
a partir dos casos.

@Return		lRet 	.T. se a alteração teve êxito.

@author Luciano Pereira dos santos
@since 16/01/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202DescContr()
Local lRet       := .T.
Local aArea      := GetArea()
Local oModel     := If(oModelOld = Nil, FwModelActive(), oModelOld)
Local oModelNX1  := oModel:GetModel('NX1DETAIL')
Local oModelNX8  := oModel:GetModel('NX8DETAIL')
Local nLineNX1   := oModelNX1:GetLine()
Local DescLin    := 0
Local DescEspec  := 0
Local nI         := 0

For nI := 1 To oModelNX1:Length()
	DescLin   := DescLin + oModelNX1:GetValue("NX1_VDESCO", nI)   //Desconto Linear
	DescEspec := DescEspec + oModelNX1:GetValue("NX1_VLDESC", nI) //Desconto Especial
Next nI

oModelNX1:GoLine(nLineNX1)

IIF(lRet, lRet := J202LoadVl(oModelNX8, "NX8_VDESCO", Round(DescLin, TamSX3("NX8_VDESCO")[2]) ), )   //Desconto Linear
IIF(lRet, lRet := J202LoadVl(oModelNX8, "NX8_VLDESC", Round(DescEspec, TamSX3("NX8_VLDESC")[2]) ), ) //Desconto Especial
IIF(lRet, lRet := J202LoadVl(oModelNX8, "NX8_VDESCT", Round(oModelNX8:GetValue("NX8_VDESCO") + oModelNX8:GetValue("NX8_VLDESC"), TamSX3("NX8_VDESCT")[2]) ), )  //Desconto Total

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202DescPre()
Rotina para atualizar os descontos da pré-fatura (alteração por período)
a partir dos contratos.

@Return		lRet 	.T. se a alteração teve Ãªxito.

@author Luciano Pereira dos santos
@since 16/01/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202DescPre()
Local lRet       := .T.
Local aArea      := GetArea()
Local oModel     := If(oModelOld = Nil, FwModelActive(), oModelOld)
Local oModelNX0  := oModel:Getmodel('NX0MASTER')
Local oModelNX8  := oModel:Getmodel('NX8DETAIL')
Local oModelNX1  := oModel:Getmodel('NX1DETAIL')
Local DescLin    := 0
Local DescEsp    := 0
Local nINX8      := 0
Local nINX1      := 0
Local nLineNX8   := oModelNX8:GetLine()
Local nLineNX1   := oModelNX1:GetLine()
Local nMaiorVTS  := oModelNX1:GetValue("NX1_VTS")
Local aMaior     := {nLineNX8, nLineNX1 }
Local nSaldo     := 0
Local nVlHonor   := 0 //Valor base para o desconto especial (VTS + VFIXO - Desc Linear)

For nINX8 := 1 To oModelNX8:Length()
	oModelNX8:goLine(nINX8)
	For nINX1 := 1 To oModelNX1:Length()

		DescLin := DescLin + oModelNX1:GetValue("NX1_VDESCO", nINX1)  //Desconto Linear
		DescEsp := DescEsp + oModelNX1:GetValue("NX1_VLDESC", nINX1)  // Desconto Especial

		If oModelNX1:GetValue("NX1_VTS", nINX1) > nMaiorVTS
			nMaiorVTS := oModelNX1:GetValue("NX1_VTS", nINX1)
			aMaior    := { nINX8, nINX1}
		EndIf

	Next nINX1

Next nINX8

IIF(lRet, lRet := J202LoadVl(oModelNX0, "NX0_DESCON", Round(DescLin, JURX3INFO("NX0_DESCON", "X3_DECIMAL")) ), )  //Desconto Linear

nVlHonor := oModelNX0:GetValue("NX0_VTS") + oModelNX0:GetValue("NX0_VLFATF") - oModelNX0:GetValue("NX0_DESCON")

If oModelNX0:GetValue("NX0_TPDESC") == "1" // se por Valor, faz a correção do percentual do desconto com base no valor (NX0_DESCH)

	lRet := lRet .And. JurLoadValue( oModelNX0, "NX0_PDESCH",, Round( oModelNX0:GetValue( "NX0_DESCH" ) / nVlHonor * 100.00, TamSX3("NX0_PDESCH")[2] ) )
	lRet := lRet .And. JurLoadValue( oModelNX0, "NX0_VDESCT",, Round( oModelNX0:GetValue( "NX0_DESCH" ) + oModelNX0:GetValue("NX0_DESCON"), TamSX3("NX0_VDESCT")[2] ) )

ElseIf oModelNX0:GetValue("NX0_TPDESC") == "2" // se por percentual, faz a correção de valor do desconto com base no percentual (NX0_PDESCH)

	lRet := lRet .And. JurLoadValue( oModelNX0, "NX0_DESCH" ,, Round( oModelNX0:GetValue( "NX0_PDESCH" ) * nVlHonor / 100.00, TamSX3("NX0_DESCH")[2] ) )
	lRet := lRet .And. JurLoadValue( oModelNX0, "NX0_VDESCT",, Round( oModelNX0:GetValue( "NX0_DESCH" ) + oModelNX0:GetValue("NX0_DESCON"), TamSX3("NX0_VDESCT")[2] ) )
EndIf

IIF(lRet, lRet := J202LoadVl(oModelNX0, "NX0_VDESCT", Round(oModelNX0:GetValue("NX0_DESCON") + oModelNX0:GetValue("NX0_DESCH"), TamSX3("NX0_VDESCT")[2]) ), )  // Total de Desconto

nSaldo := oModelNX0:GetValue("NX0_DESCH") - DescEsp
If !(nSaldo = 0) .And. !lTelaRat //CH-7825 não corrige o saldo se ainda não foi feito o rateio entre os casos
	oModelNX8:goLine(aMaior[1])
	oModelNX1:goLine(aMaior[2])

	lRet := lRet .And. JurLoadValue( oModelNX1, "NX1_VLDESC",, Round( oModelNX1:GetValue("NX1_VLDESC") + nSaldo, TamSX3("NX1_VLDESC")[2] ) )
	lRet := lRet .And. JurLoadValue( oModelNX8, "NX8_VLDESC",, Round( oModelNX8:GetValue("NX8_VLDESC") + nSaldo, TamSX3("NX8_VLDESC")[2] ) )
EndIf

oModelNX8:GoLine(nLineNX8)
oModelNX1:GoLine(nLineNX1)
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202AtuFilho()
Rotina para atualizar o saldo residual nos time sheets divididos
(alteração por período)

@Params	    cTipo 	"TS" - Ajusta o valor do maior Time sheet filho do
                           array lançamentos divididos aLancDiv
					"DP" - Ajusta o valor da maoir Despesa filha do
                           array lançamentos divididos aLancDiv
@Params	    nVlOld	Valor anterior da Pré-Fatura
@Params	    nVlNew	Valor anterior da Pré-Fatura

@Return		lRet 	.T. se a alteração teve Ãªxito.

@author Luciano Pereira dos santos
@since 20/01/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202AtuFilho(cTipo, nVlOld, nVlNew)
Local lRet       := .T.
Local aArea      := GetArea()
Local oModel     := If(oModelOld = Nil, FwModelActive(), oModelOld)
Local oModelNX0  := oModel:Getmodel('NX0MASTER')
Local nVlFilho1  := 0
Local nMaiorFi   := 0
Local nMaiorVl   := 0
Local nPosVl1    := 0
Local nPosMoe    := 0
Local nPosUTR    := 0
Local nPosUTL    := 0
Local nPosTPR    := 0
Local nPosTPL    := 0
Local nPosHSR    := 0
Local nPosHSL    := 0
Local nPosVlH    := 0
Local cMoedaTS   := ""
Local nValorTS   := 0
Local nTpRFilho  := 0
Local nUTRFilho  := 0
Local cHsRFilho  := ""
Local nTpLFilho  := 0
Local nUTLFilho  := 0
Local cHsLFilho  := ""
Local nI         := 0
Local SomaFilho  := 0
Local SomaRemov  := 0

If Len(aLancDiv) > 0

	If cTipo == "TS"

		For nI := 1 to len (aRmvLanc)
			If aRmvLanc[nI][1] == 'NUE'
				SomaRemov += aRmvLanc[ni][3]
			EndIf
		Next nI

		For nI := 1 To Len(aLancDiv)

			If (nPosVl1 := aScan(  aLancDiv[nI], {|x,y| x[1] == 'NUE_VALOR1' }) ) > 0

				nVlFilho1 := aLancDiv[ni][nPosVl1][2]

				If nVlFilho1 >= nMaiorVl
					nMaiorVl := nVlFilho1
					nMaiorFi := nI
				EndIf

				SomaFilho := SomaFilho + nVlFilho1

			EndIf

		Next nI

		nSaldo := nVlOld - (nVlNew + SomaFilho + SomaRemov)

		If !(nSaldo == 0)

			//Localiza as posiçoes dos campos no Array
			nPosMoe := aScan(  aLancDiv[nMaiorFi], {|x,y| x[1] == 'NUE_CMOEDA' })
			nPosUTR := aScan(  aLancDiv[nMaiorFi], {|x,y| x[1] == 'NUE_UTR'    })
			nPosUTL := aScan(  aLancDiv[nMaiorFi], {|x,y| x[1] == 'NUE_UTL'    })
			nPosTPR := aScan(  aLancDiv[nMaiorFi], {|x,y| x[1] == 'NUE_TEMPOR' })
			nPosTPL := aScan(  aLancDiv[nMaiorFi], {|x,y| x[1] == 'NUE_TEMPOL' })
			nPosHSR := aScan(  aLancDiv[nMaiorFi], {|x,y| x[1] == 'NUE_HORAR'  })
			nPosHSL := aScan(  aLancDiv[nMaiorFi], {|x,y| x[1] == 'NUE_HORAL'  })
			nPosVlH := aScan(  aLancDiv[nMaiorFi], {|x,y| x[1] == 'NUE_VALORH' })

			aLancDiv[nMaiorFi][nPosvl1][2] := Round( aLancDiv[nMaiorFi][nPosVl1][2] + nSaldo, JURX3INFO("NUE_VALOR1", "X3_DECIMAL") )

			cMoedaTS := aLancDiv[nMaiorFi][nPosMoe][2]

			//converte o valor do Time Sheet na moeda ho honorário
			nValorTS := JA201FConv(cMoedaTS, oModelNX0:GetValue("NX0_CMOEDA"), aLancDiv[nMaiorFi][nPosVl1][2], "2",;
									oModelNX0:GetValue("NX0_DTEMI"), , oModelNX0:GetValue("NX0_COD"), )[1]

			//atualiza os valores revisados proporcionalmente no TS filho
			nTpRFilho := (nValorTS / aLancDiv[nMaiorFi][nPosVlH][2])
			nUTRFilho := Val( JURA144C1(2, 1, Str(nTpRFilho)) )
			cHsRFilho :=      JURA144C1(2, 3, Str(nTpRFilho))

			aLancDiv[nMaiorFi][nPosTPR][2] := nTpRFilho
			aLancDiv[nMaiorFi][nPosUTR][2] := nUTRFilho
			aLancDiv[nMaiorFi][nPosHSR][2] := cHsRFilho

			//atualiza os valores lançados proporcionalmente no TS filho
			nUTLFilho := aLancDiv[nMaiorFi][nPosUTL][2] * aLancDiv[nMaiorFi][nPosUTR][2] / nUTRFilho
			nTpLFilho := Val(JURA144C1(1, 2, Str(nUTLFilho)))
			cHsLFilho :=     JURA144C1(1, 3, Str(nUTLFilho))

			aLancDiv[nMaiorFi][nPosTPL][2] := nTpLFilho
			aLancDiv[nMaiorFi][nPosUTL][2] := nUTLFilho
			aLancDiv[nMaiorFi][nPosHSL][2] := cHsLFilho

		EndIf
	EndIf

	If cTipo == "DP"

		For nI := 1 To Len(aRmvLanc)
			If aRmvLanc[nI][1] == 'NVY'
				SomaRemov += JA201FConv(oModelNX0:GetValue("NX0_CMOEDA"), aRmvLanc[ni][4], aRmvLanc[ni][3], "2",;
										oModelNX0:GetValue("NX0_DTEMI"), /*cCodFImpr*/, oModelNX0:GetValue("NX0_COD"), /*cXFilial*/ )[1]
			EndIf
		Next nI

		For nI := 1 To Len(aLancDiv)

			If (nPosVl1 := aScan(  aLancDiv[nI], {|x,y| x[1] == 'NVY_VALOR' }) ) > 0

				nPosMoe := aScan(  aLancDiv[nI], {|x,y| x[1] == 'NVY_CMOEDA' })

				//converte a Despesa na moeda da Pré-Fatura
				nVlFilho1 := JA201FConv(oModelNX0:GetValue("NX0_CMOEDA"), aLancDiv[nI][nPosMoe][2], aLancDiv[nI][nPosVl1][2], "2",;
										oModelNX0:GetValue("NX0_DTEMI"), /*cCodFImpr*/, oModelNX0:GetValue("NX0_COD"), /*cXFilial*/ )[1]

				If nVlFilho1 >= nMaiorVl
					nMaiorVl := nVlFilho1
					nMaiorFi := nI
				EndIf

				SomaFilho := SomaFilho + nVlFilho1

			EndIf

		Next nI

		nSaldo := nVlOld - (nVlNew + SomaFilho + SomaRemov)

		If !(nSaldo == 0)
			//converte o saldo de ajuste no valor da Despesa
			nSaldo := JA201FConv(aLancDiv[nMaiorFi][nPosMoe][2], oModelNX0:GetValue("NX0_CMOEDA"), ( nVlOld - (nVlNew + SomaFilho) ), "2",;
								 oModelNX0:GetValue("NX0_DTEMI"), /*cCodFImpr*/, oModelNX0:GetValue("NX0_COD"), /*cXFilial*/ )[1]

			aLancDiv[nMaiorFi][nPosvl1][2] := Round( aLancDiv[nMaiorFi][nPosVl1][2] + nSaldo, JURX3INFO("NVY_VALOR", "X3_DECIMAL") )
		EndIf

	EndIf

EndIf

RestArea( aArea )

Return lRet

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          FUNÇÕES ALTERAÇÃO POR PERIODO OPÇÃO 2 = "ULTIMO" PARA DESPESAS - INICIO                      //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//-------------------------------------------------------------------
/*/{Protheus.doc} JANX0_VDES()
Rotina de chamada para recalculo da alteração por período dos contratos
da Pré-fatura (Valid do campo NX0_VLFATD)

@Return		lRet 	.T. se a alteração teve êxito.

@author Luciano Pereira dos santos
@since 04/02/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JANX0_VDES()
Local lRet      := .T.
Local oModel    := FwModelActive()
Local oModelNX0 := oModel:GetModel("NX0MASTER")
Local cPreFat   := oModelNX0:GetValueByPos(__aNX0PosFields[POS_NX0_COD])
Local lTela     := !IsBlind()

Do Case
	Case oModelNX0:GetValue("NX0_ALTPER") == "2"
		
		If !__InMsgRun .And. lTela
			J202SCorte(oModel, "NVY", cPreFat) // Seta variáveis estáticas usadas na rotina de corte

			__oProcess := MsNewProcess():New({|| __InMsgRun := .T., lRet := JANX0_VDP2(.T.), __InMsgRun := .F.}, STR0147, STR0167, .T.) // #"Aguarde..." ##"Atualizando Lançamentos"
			__oProcess:Activate()
		Else
			lRet := JANX0_VDP2()
		EndIf

	OtherWise
		lRet := JurMsgErro(STR0177) // "Escolha um tipo de ajuste antes de alterar o valor!"

EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JANX8_VDES()
Rotina de chamada para recalculo da alteração por período dos contratos
da Pré-fatura (Valid do campo NX8_VDESP)

@Return		lRet 	.T. se a alteração teve êxito.

@author Luciano Pereira dos santos
@since 04/02/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JANX8_VDES()
Local lRet       := .T.
Local oModel     := FwModelActive()
Local oModelNX0  := oModel:GetModel("NX0MASTER")
Local cPreFat    := oModelNX0:GetValueByPos(__aNX0PosFields[POS_NX0_COD])
Local cContr     := oModel:GetModel("NX8DETAIL"):GetValue("NX8_CCONTR")
Local lTela      := !IsBlind()

Do Case
	Case oModelNX0:GetValue("NX0_ALTPER") == "2"
		If !__InMsgRun .And. lTela
			J202SCorte(oModel, "NVY", cPreFat, cContr) // Seta variáveis estáticas usadas na rotina de corte
			
			__oProcess := MsNewProcess():New({|| __InMsgRun := .T., lRet := JANX8_VDP2(.T., lTela), __InMsgRun := .F.}, STR0147, STR0167, .T.) // #"Aguarde..." ##"Atualizando Lançamentos"
			__oProcess:Activate()
		Else
			lRet := JANX8_VDP2(.F., lTela)
		EndIf

	OtherWise
		lRet := JurMsgErro(STR0177) // "Escolha um tipo de ajuste antes de alterar o valor!"

EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JANX1_VDES()
Rotina de chamada para recalculo da alteração por período dos contratos
da Pré-fatura (Valid do campo NX1_VDESP)

@Return		lRet 	.T. se a alteração teve êxito.

@author Luciano Pereira dos santos
@since 04/02/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JANX1_VDES()
Local lRet       := .T.
Local oModel     := FwModelActive()
Local oModelNX0  := oModel:GetModel("NX0MASTER")
Local cPreFat    := oModelNX0:GetValueByPos(__aNX0PosFields[POS_NX0_COD])
Local cCliente   := ""
Local cLoja      := ""
Local cCaso      := ""
Local lTela      := !IsBlind()

Do Case
	Case oModelNX0:GetValue("NX0_ALTPER") == "2"
		If !__InMsgRun .And. lTela

			cCliente  := oModel:GetModel("NX1DETAIL"):GetValue("NX1_CCLIEN")
			cLoja     := oModel:GetModel("NX1DETAIL"):GetValue("NX1_CLOJA")
			cCaso     := oModel:GetModel("NX1DETAIL"):GetValue("NX1_CCASO")

			J202SCorte(oModel, "NVY", cPreFat, "" /*cContr*/, cCliente, cLoja, cCaso) // Seta variáveis estáticas usadas na rotina de corte

			__oProcess := MsNewProcess():New({|| __InMsgRun := .T., lRet := JANX1_VDP2(.T., lTela), __InMsgRun := .F.}, STR0147, STR0167, .T.) // #"Aguarde..." ##"Atualizando Lançamentos"
			__oProcess:Activate()
		Else
			lRet := JANX1_VDP2(.F., lTela)
		EndIf

	OtherWise
		lRet := JurMsgErro(STR0177) // "Escolha um tipo de ajuste antes de alterar o valor!"

EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JANX0_VDP2()
Rotina para recalculo da alteração por período opção 2=Ultimo da pré-fatura
para despesas.

@param     lNewProcess, Indica se está sendo aberto um novo MsNewProcess

@Return    lRet       , .T. se a alteração teve êxito.

@author Luciano Pereira dos Santos
@since 02/02/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JANX0_VDP2(lNewProcess)
Local lRet          := .T.
Local nPos          := 0
Local oModel        := FwModelActive()
Local oModelNX0     := oModel:GetModel("NX0MASTER")
Local oModelNX1     := oModel:GetModel("NX1DETAIL")
Local oModelNX8     := oModel:GetModel("NX8DETAIL")
Local oModelNVY     := oModel:GetModel("NVYDETAIL")
Local nVlrPre       := 0
Local nAjuste       := 0
Local nSaldo        := 0
Local nI            := 0
Local nVlrContr     := 0
Local nMaiorVl      := 0
Local nMaiorContr   := 0
Local nLineNX8      := 0

Default lNewProcess := .F.

	If lNewProcess
		__oProcess:SetRegua1(__nQtdNX1)
		__oProcess:SetRegua2(__nQtdNVY)
	EndIf

	For nPos := 1 To Len(aCasos)
		nVlrPre += aCasos[nPos][4]
	Next nPos

	nSaldo := oModelNX0:GetValue("NX0_VLFATD")

	If nSaldo < 0
		lRet := JurMsgErro(STR0169) //"Informe um valor positivo!"
		Return lRet
	Else
		If nSaldo > nVlrPre
			lRet := JurMsgErro(STR0097) // Não é possível efetuar a alteração, pois o valor novo é maior do que o antigo
			Return lRet
		EndIf
	EndIf

	nAjuste  := oModelNX0:GetValue("NX0_VLFATD") / nVlrPre

	nLineNX8 := oModelNX8:nLine

	For nI := 1 To oModelNX8:Length()
	
		oModelNX8:goLine(nI)

		If oModelNX8:GetValue("NX8_DESP") == "1"

			nVlrContr := oModelNX8:GetValue("NX8_VDESP")

			If nVlrContr >= nMaiorVl
				nMaiorVl := nVlrContr
				nMaiorContr	:= nI
			EndIf
			cInstanc := ""

			lRet   := lRet .And. JurSetValue( oModelNX8, "NX8_VDESP",, Round(nVlrContr * nAjuste, JURX3INFO("NX8_VDESP", "X3_DECIMAL") )  )
			nSaldo := nSaldo - oModelNX8:GetValue("NX8_VDESP")

		EndIf

	Next nI

	If !(nSaldo == 0)

		If nSaldo > 0 // tira do filho e adiciona no pai (encontra o maior filho)
			nPosVal := 5 //Valor do Filho
		Else // Tira do pai e adiciona no filho (encontra o maior pai)
			nPosVal := 4 //Valor do Pai
		EndIf
		nMaiorDP := 0
		nPosMaior := 0

		//Localiza a maior despesa dividida
		For nI := 1 To Len(aDespDiv)
			If nMaiorDP < aDespDiv[ni][nPosVal]
				nMaiorDP := aDespDiv[ni][nPosVal]
				nPosMaior := ni
				vDespTot := aDespDiv[ni][4]+aDespDiv[ni][5] //Total: Pai + Filho
			EndIf
		Next ni

		If nPosMaior > 0
			oModelNX8:GoLine(aDespDiv[nPosMaior][1])
			oModelNX1:GoLine(aDespDiv[nPosMaior][2])
			oModelNVY:GoLine(aDespDiv[nPosMaior][3])

			aPosFilho :=  PosFilho("NVY_CCLIEN",	oModelNVY:GetValue("NVY_CCLIEN"),;
									"NVY_CLOJA",	oModelNVY:GetValue("NVY_CLOJA"), ;
									"NVY_CCASO",	oModelNVY:GetValue("NVY_CCASO"), ;
									"NVY_CODPAI", 	oModelNVY:GetValue("NVY_COD"), ;
									"NVY_VALOR")

			If !Empty(aPosFilho)
				nVlDP := oModelNVY:GetValue("NVY_VALOR")
				//Converte o saldo na moeda da despesa
				nSaldoDP := JA201FConv(oModelNVY:GetValue( "NVY_CMOEDA" ), oModelNX0:GetValue("NX0_CMOEDA"), nSaldo , "2",;
				                       oModelNX0:GetValue("NX0_DTEMI"), /*cCodFImpr*/, oModelNX0:GetValue("NX0_COD"), /*cXFilial*/ )[1]

				//Ajusta o Pai
				lRet := lRet .And. JurLoadValue( oModelNVY, "NVY_VALOR",, Round(nVlDP + nSaldoDP, JURX3INFO("NVY_VALOR", "X3_DECIMAL") )  )
				aDespDiv[nPosMaior][4] := oModelNVY:GetValue("NVY_VALOR")
				//Ajusta o Filho
				aLancDiv[aPosFilho[1]][aPosFilho[2]][2] := NoRound(vDespTot - oModelNVY:GetValue("NVY_VALOR"), JURX3INFO("NVY_VALOR", "X3_DECIMAL") )
				aDespDiv[nPosMaior][5] := aLancDiv[aPosFilho[1]][aPosFilho[2]][2]
				//Ajusta o Caso
				lRet := lRet .And. JurLoadValue( oModelNX1, "NX1_VDESP",, Round(oModelNX1:GetValue("NX1_VDESP") + nSaldo, JURX3INFO("NX1_VDESP", "X3_DECIMAL") )  )
				//Ajusta o Contrato
				lRet := lRet .And. JurLoadValue( oModelNX8, "NX8_VDESP",, Round(oModelNX1:GetValue("NX8_VDESP") + nSaldo, JURX3INFO("NX8_VDESP", "X3_DECIMAL") )  )
			EndIf

		EndIf

	EndIf

	oModelNX8:goLine(nLineNX8)
	cInstanc := ""

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JANX8_VDP2()
Rotina para recalculo da alteração por período opção 2=Ultimo para as
despesas dos contratos da pré-fatura

@params    lNewProcess, Indica se está sendo aberto um novo MsNewProcess
@params    lTela      , Indica se a chamada foi feita via tela

@Return    lRet       , .T. se a alteração teve Êxito.

@author Luciano Pereira dos santos
@since 02/02/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JANX8_VDP2(lNewProcess, lTela)
Local lRet          := .T.
Local nPos          := 0
Local oModel        := FwModelActive()
Local oModelNX0     := oModel:GetModel("NX0MASTER")
Local oModelNX8     := oModel:GetModel("NX8DETAIL")
Local oModelNX1     := oModel:GetModel("NX1DETAIL")
Local oModelNVY     := oModel:GetModel("NVYDETAIL")
Local nVlrContr     := 0
Local nAjuste       := 0
Local nSaldo        := 0
Local nSaldoDP      := 0
Local nI            := 0
Local nVlCaso       := 0
Local nMaiorVl      := 0
Local nMaiorCont    := 0
Local nLineNX1      := 0
Local nPosVal       := 0

Default lNewProcess := .F.
Default lTela       := .F.

If lNewProcess
	__oProcess:SetRegua1(__nQtdNX1)
	__oProcess:SetRegua2(__nQtdNVY)
EndIf

If Empty(cInstanc)
	For nPos := 1 To Len(aCasos)
		If aCasos[nPos][9] == oModelNX8:GetValue("NX8_CCONTR")
			nVlrContr += aCasos[nPos][4]
		EndIf
	Next nPos

	nSaldo := oModelNX8:GetValue("NX8_VDESP")

	If nSaldo < 0
		lRet := JurMsgErro(STR0169) //"Informe um valor positivo!"
		Return lRet
	Else
		If nSaldo > nVlrContr
			lRet := JurMsgErro(STR0097) // Não é possível efetuar a alteração, pois o valor novo é maior do que o antigo
			Return lRet
		EndIf
	EndIf

	nAjuste    := oModelNX8:GetValue("NX8_VDESP") / nVlrContr
	nDifVlr    := oModelNX8:GetValue("NX8_VDESP") - nVlrContr

	nLineNX1   := oModelNX1:nLine
	nMaiorVl   := oModelNX1:GetValue("NX1_VDESP")
	nMaiorCont := nLineNX1

	For nI := 1 To oModelNX1:Length()

		If lTela
			__oProcess:IncRegua1(i18n(STR0331, {oModelNX1:GetValue("NX1_CCASO", nI), __nCountNX1++, __nQtdNX1} )) // "Atualizando Caso #1 - #2 de #3."
		EndIf

		oModelNX1:goLine(nI)

		If oModelNX1:GetValue("NX1_DESP") == "1"

			nVlCaso := oModelNX1:GetValue("NX1_VDESP")

			If nVlCaso >= nMaiorVl
				nMaiorVl   := nVlCaso
				nMaiorCont := nI
			EndIf
			cInstanc := ""
			lRet     := lRet .And. JurSetValue( oModelNX1, "NX1_VDESP",, Round(nVlCaso * nAjuste, JURX3INFO("NX1_VDESP", "X3_DECIMAL") ) )
			nSaldo   := nSaldo - oModelNX1:GetValue("NX1_VDESP")

		EndIf

	Next nI

	If !(nSaldo == 0)

		If nSaldo > 0 // tira do filho e adiciona no pai (encontra o maior filho)
			nPosVal := 5 //Valor do Filho
		Else // Tira do pai e adiciona no filho (encontra o maior pai)
			nPosVal := 4 //Valor do Pai
		EndIf
		nMaiorDP  := 0
		nPosMaior := 0

		//Localiza a maior despesa dividida
		For nI := 1 To Len(aDespDiv)
			If aDespDiv[nI][1] == oModelNX8:getLine() //estou ajustando o saldo do contrato. tenho que buscar as despesas do contrato.
				If nMaiorDP < aDespDiv[nI][nPosVal]
					nMaiorDP  := aDespDiv[nI][nPosVal]
					nPosMaior := nI
					vDespTot  := aDespDiv[nI][4] + aDespDiv[nI][5] //Total: Pai + Filho
				EndIf
			EndIf
		Next ni

		If nPosMaior > 0
			oModelNX1:GoLine(aDespDiv[nPosMaior][2])
			oModelNVY:GoLine(aDespDiv[nPosMaior][3])

			aPosFilho := PosFilho("NVY_CCLIEN",  oModelNVY:GetValue("NVY_CCLIEN"),;
									"NVY_CLOJA", oModelNVY:GetValue("NVY_CLOJA"), ;
									"NVY_CCASO", oModelNVY:GetValue("NVY_CCASO"), ;
									"NVY_CODPAI", oModelNVY:GetValue("NVY_COD"), ;
									"NVY_VALOR")

			If !Empty(aPosFilho)
				nVlDP := oModelNVY:GetValue("NVY_VALOR")
				//Converte o saldo na moeda da despesa
				nSaldoDP := JA201FConv(oModelNVY:GetValue( "NVY_CMOEDA" ), oModelNX0:GetValue("NX0_CMOEDA"), nSaldo , "2",;
				                       oModelNX0:GetValue("NX0_DTEMI"), /*cCodFImpr*/, oModelNX0:GetValue("NX0_COD"), /*cXFilial*/ )[1]

				//Ajusta o Pai
				lRet := lRet .And. JurLoadValue( oModelNVY, "NVY_VALOR",, Round(nVlDP + nSaldoDP, JURX3INFO("NVY_VALOR", "X3_DECIMAL") ) )
				aDespDiv[nPosMaior][4] := oModelNVY:GetValue("NVY_VALOR")
				//Ajusta o Filho
				aLancDiv[aPosFilho[1]][aPosFilho[2]][2] := NoRound(vDespTot - oModelNVY:GetValue("NVY_VALOR"), JURX3INFO("NVY_VALOR", "X3_DECIMAL") )
				aDespDiv[nPosMaior][5] := aLancDiv[aPosFilho[1]][aPosFilho[2]][2]
				//Ajusta o Caso
				lRet := lRet .And. JurLoadValue( oModelNX1, "NX1_VDESP",, Round(oModelNX1:GetValue("NX1_VDESP") + nSaldo, JURX3INFO("NX1_VDESP", "X3_DECIMAL") ) )
			EndIf

		EndIf

	EndIf

	oModelNX1:goLine(nLineNX1)

	If !IsInCallStack("JANX0_VDES")
		lRet := lRet .And. JurLoadValue( oModelNX0, "NX0_VLFATD",, Round( oModelNX0:GetValue("NX0_VLFATD") - nDifVlr, TamSX3('NX0_VLFATD')[2] ) )
	EndIf

ElseIf cInstanc == "NX0" //Tratamento para evitar que o saldo crie novas despesas filhas com o valor do ajuste

	For nPos := 1 To Len(aCasos)
		If aCasos[nPos][9] == oModelNX8:GetValue("NX8_CCONTR")
			nVlrContr += aCasos[nPos][6]
		EndIf
	Next nPos

	nDifVlr     := oModelNX8:GetValue( "NX8_VDESP" ) - nVlrContr
	nSaldo      := oModelNX8:GetValue( "NX8_VDESP" )

	nLineNX1    := oModelNX1:nLine
	nMaiorVl    := oModelNX1:GetValue("NX1_VDESP")
	nMaiorCont  := nLineNX1

	cInstanc := "NX8"

	For nI := 1 To oModelNX1:Length()

		If lTela
			__oProcess:IncRegua1(i18n(STR0331, {oModelNX1:GetValue("NX1_CCASO", nI), __nCountNX1++, __nQtdNX1} )) // "Atualizando Caso #1 - #2 de #3."
		EndIf

		oModelNX1:GoLine(nI)

		If oModelNX1:GetValue("NX1_DESP") == "1"

			nVlCaso :=  oModelNX1:GetValue("NX1_VDESP")

			If nVlCaso >= nMaiorVl
				nMaiorVl   := nVlCaso
				nMaiorCont := nI
			EndIf

			nSaldo := nSaldo - oModelNX1:GetValue("NX1_VDESP")

		EndIf

	Next nI

	If !(nSaldo == 0)
		oModelNX1:goLine(nMaiorCont)
		nVlCaso := oModelNX1:GetValue("NX1_VDESP")

		nSaldo := JA201FConv(oModelNVY:GetValue( "NVY_CMOEDA" ), oModelNX0:GetValue("NX0_CMOEDA"), nSaldo, "2",;
							    oModelNX0:GetValue("NX0_DTEMI"), /*cCodFImpr*/, oModelNX0:GetValue("NX0_COD"), /*cXFilial*/ )[1]

		cInstanc := "NX8" // controla a instancia de ajuste do saldo no caso a partir do contrato
		lRet := lRet .And. JurSetValue( oModelNX1, "NX1_VDESP",, Round(nVlCaso + nSaldo, TamSX3("NX1_VDESP")[2] ) )
	EndIf
	cInstanc := "NX0"
	oModelNX1:GoLine(nLineNX1)

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JANX1_VDP2()
Rotina para recalculo da alteração por período opção 2=Ultimo para as
despesas dos casos da pré-fatura

@params    lNewProcess, Indica se está sendo aberto um novo MsNewProcess
@params    lTela      , Indica se a chamada foi feita via tela

@return    lRet       , .T. se a alteração teve êxito.

@author Luciano Pereira dos santos
@since 18/01/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JANX1_VDP2(lNewProcess, lTela)
Local lRet          := .T.
Local aArea         := GetArea()
Local oModel        := If(oModelOld = Nil, FwModelActive(), oModelOld)
Local oModelNX0     := oModel:Getmodel('NX0MASTER')
Local oModelNX8     := oModel:Getmodel('NX8DETAIL')
Local oModelNX1     := oModel:Getmodel('NX1DETAIL')
Local oModelNVY     := oModel:Getmodel('NVYDETAIL')
Local oStrucNVY     := oModelNVY:GetStruct()
Local aStrucNVY     := oStrucNVY:GetFields()
Local cClient       := oModelNX1:GetValue("NX1_CCLIEN")
Local cLoja         := oModelNX1:GetValue("NX1_CLOJA")
Local cCaso         := oModelNX1:GetValue("NX1_CCASO")
Local cContr        := oModelNX1:GetValue("NX1_CCONTR")
Local lNVYCpart     := .F.
Local nLineNVY      := 0
Local nPos          := 0
Local nPosAlt       := 0
Local nLinha        := 0
Local nNewVlCaso    := 0
Local nVlrCaso      := 0
Local aAuxliar      := {}
Local nVlDPPre      := 0
Local nVlAcumul     := 0
Local lDividido     := .F.
Local nSaldo        := 0
Local nMaiorVl      := 0
Local nPosPai       := 0
Local aPosFilho     := 0
Local nVlDPOld      := 0
Local nVlFilho      := 0
Local nPosDesp      := 0

Default lNewProcess := .F.
Default lTela       := .F.

If lNewProcess
	__oProcess:SetRegua1(__nQtdNX1)
	__oProcess:SetRegua2(__nQtdNVY)
EndIf

If Empty(cInstanc)
	//Verifica se houve alguma alteração de periodo que não foi confirmada
	nPosAlt := aScan( aAltPend, {|x| x[1] == 'DP' .And. x[2] == cClient .And. x[3] == cLoja .And. x[4] == cCaso .And. x[5] == cContr })

	If nPosAlt > 0
		lRet := JurMsgErro(STR0170) //"Existem alterações de valor pendentes, para efetuar novas alterações cancele as anteriores!"
		Return lRet
	EndIf

	//Retorna a posição da variável aCasos (encapsulado aScan no vetor aCasos para poder depurar a função)
	nPos := J202ACSPOS(cClient, cLoja, cCaso, cContr)

	If nPos > 0

		nNewVlCaso := oModelNX1:GetValue( "NX1_VDESP" )
		nSaldo      := nNewVlCaso
		nVlrCaso    := aCasos[nPos][4]
		nDifVlr     := nVlrCaso - nNewVlCaso

		If nSaldo < 0
			lRet := JurMsgErro(STR0169) //"Informe um valor positivo!"
			Return lRet
		Else
			If nNewVlCaso > nVlrCaso
				lRet := JurMsgErro(STR0097) // Não é possível efetuar a alteração, pois o valor novo é maior do que o antigo
				Return lRet
			EndIf
		EndIf

		lNVYCpart := oModelNVY:HasField("NVY_CPART")

		nLineNVY  := oModelNVY:nLine

		For nLinha := 1 To oModelNVY:Length()
			Aadd( aAuxliar, {nLinha, oModelNVY:GetValue("NVY_DATA", nLinha), oModelNVY:GetValue("NVY_COD", nLinha ), IIf(lNVYCpart, oModelNVY:GetValue("NVY_CPART", nLinha), "") })
		Next nLinha

		If lNVYCpart
			aSort( aAuxliar,,, { |aX,aY| DtoS(aX[2]) + aX[4] < DtoS(aY[2]) + aY[4] } )  //Ordena pela data e cód do participante
		EndIf

		For nLinha := 1 To Len( aAuxliar )

			If lTela
				__oProcess:IncRegua2(i18n(STR0332, {__nCountNVY++, __nQtdNVY} )) // "Atualizando valores dos lançamentos - #1 de #2."
			EndIf

			nPosDesp := aAuxliar[nLinha][1]

			nVlDPPre  := Round(JA201FConv(oModelNX0:GetValue("NX0_CMOEDA"), oModelNVY:GetValue("NVY_CMOEDA", nPosDesp), oModelNVY:GetValue("NVY_VALOR", nPosDesp), "2",;
										oModelNX0:GetValue("NX0_DTEMI"), /*cCodFImpr*/, oModelNX0:GetValue("NX0_COD"), /*cXFilial*/ )[1], TamSX3("NVY_VALOR")[2] )

			If !lDividido
				nVlAcumul  := nVlAcumul + nVlDPPre
			EndIf

			If nVlAcumul >= nNewVlCaso .And. !lDividido

				oModelNVY:goLine(nPosDesp)

				Do Case
					Case (nVlAcumul == nNewVlCaso) //Se a ultima DP somado é exatamente igual ao novo valor, mantem a DP na Pré e remove as restantes.

						lDividido  := .T.

					Case (nVlAcumul - nNewVlCaso < nVlDPPre ) .And. !lDividido // Se o valor residual é menor que a DP, mantem o DP na Pré e divide o seu valor.

						nPosPai := aAuxliar[nLinha][1]

						nVlDP := Round(JA201FConv(oModelNVY:GetValue( "NVY_CMOEDA" ), oModelNX0:GetValue("NX0_CMOEDA"), ( nVlDPPre - (nVlAcumul - nNewVlCaso) ), "2",;
										    oModelNX0:GetValue("NX0_DTEMI"), /*cCodFImpr*/, oModelNX0:GetValue("NX0_COD"), /*cXFilial*/ )[1], TamSX3("NVY_VALOR")[2] )

						nVlDPOld := oModelNVY:GetValue("NVY_VALOR") //guarda o valor anterior a Despesa

						lRet := lRet .And. JurLoadValue(oModelNVY, "NVY_VALOR",, nVlDP )
						lRet := lRet .And. JurLoadValue(oModelNVY, "NVY_DESDIV",, "1")

						nVlFilho  := Round(nVlDPOld - oModelNVY:GetValue("NVY_VALOR"), TamSX3("NVY_VALOR")[2] )

						//grava o array com o lançamento filho para ser gravado no commit.
						lRet := lRet .And. J202CriaFilho("NVY", oModelNVY, aStrucNVY, oModelNVY:GetValue("NVY_COD"), aAuxliar[nLinha][1], nVlFilho )
						//Armazena a posição na estrutura da despesa dividida
						aAdd( aDespDiv, {oModelNX8:GetLine(), oModelNX1:GetLine(), oModelNVY:GetLine(), oModelNVY:GetValue("NVY_VALOR"), nVlFilho } )

						nVlFilho := Round(JA201FConv( oModelNX0:GetValue("NX0_CMOEDA"), oModelNVY:GetValue( "NVY_CMOEDA" ), nVlFilho, "2",;
											oModelNX0:GetValue("NX0_DTEMI"), /*cCodFImpr*/, oModelNX0:GetValue("NX0_COD"), /*cXFilial*/ )[1], TamSX3("NVY_VALOR")[2] )

						nVlAcumul := nVlAcumul - nVlFilho

						lDividido  := .T.

					Case lDividido // Remove as depesas restantes.

						//grava o array para remover os vinculos do Time Sheet no commit da tela.
						aAdd(aRmvLanc, {"NVY", xFilial("NVY") + oModelNVY:GetValue("NVY_COD") +;
						                 oModelNVY:GetValue("NVY_SITUAC") + oModelNVY:GetValue("NVY_CPREFT"),;
						                 oModelNVY:GetValue("NVY_VALOR"), oModelNVY:GetValue("NVY_CMOEDA")} )

						//apaga o codigo da pré-fatura para o TS ser removido no grava generico no commit da tela
						lRet := lRet .And. JurLoadValue(oModelNVY, "NVY_CPREFT",, "")
				EndCase

			ElseIf lDividido

				oModelNVY:goLine(nPosDesp)
				//grava o array para remover os vinculos do Time Sheet no commit da tela.
				aAdd(aRmvLanc, {"NVY", xFilial("NVY") + oModelNVY:GetValue("NVY_COD") + ;
					   oModelNVY:GetValue("NVY_SITUAC") + oModelNVY:GetValue("NVY_CPREFT"),;
					   oModelNVY:GetValue("NVY_VALOR"), oModelNVY:GetValue("NVY_CMOEDA")} )

				//apaga o codigo da pré-fatura para o TS ser removido no grava generico no commit da tela
				lRet := lRet .And. JurLoadValue(oModelNVY, "NVY_CPREFT",, "")
			EndIf

		Next nLinha

		nSaldo := nSaldo - nVlAcumul

		nSaldo := Round(nSaldo, TamSX3("NVY_VALOR")[2] )

		//DGF: Não pode alterar o valor da despesas. tem que alterar o valor do lançamento didivido (ajustar pai e filho)
		If !(nSaldo == 0)

			//Converte o saldo na moeda da despesa
			nSaldo := JA201FConv(oModelNVY:GetValue( "NVY_CMOEDA" ), oModelNX0:GetValue("NX0_CMOEDA"), nSaldo, "2",;
			                     oModelNX0:GetValue("NX0_DTEMI"), /*cCodFImpr*/, oModelNX0:GetValue("NX0_COD"), /*cXFilial*/ )[1]

			oModelNVY:goLine(nPosPai)

			aPosFilho :=  PosFilho("NVY_CCLIEN",  oModelNVY:GetValue("NVY_CCLIEN"),;
									"NVY_CLOJA",  oModelNVY:GetValue("NVY_CLOJA"), ;
									"NVY_CCASO",  oModelNVY:GetValue("NVY_CCASO"), ;
									"NVY_CODPAI", oModelNVY:GetValue("NVY_COD"), ;
									"NVY_VALOR")

			//Localiza a maior despesa dividida
			For nLinha := 1 To Len(aDespDiv)
				If aDespDiv[nLinha][1] == oModelNX8:getLine() .And. aDespDiv[nLinha][2] == oModelNX1:getLine().And. aDespDiv[nLinha][3] == oModelNVY:getLine()
					nTotDes := aDespDiv[nLinha][4] + aDespDiv[nLinha][5]
					nPosDesp := nLinha
					Exit
				EndIf
			Next nLinha

			If !Empty(aPosFilho)
				nVlDP := oModelNVY:GetValue("NVY_VALOR")
				cInstanc := "NX1" // controla a instancia de ajuste do saldo no time sheet a partir do caso

				//Ajusta o Pai
				lRet := lRet .And. JurLoadValue( oModelNVY, "NVY_VALOR",, Round(nVlDP + nSaldo, TamSX3("NVY_VALOR")[2] ) )
				//Ajusta o Filho
				aLancDiv[aPosFilho[1]][aPosFilho[2]][2] := NoRound(nTotDes - oModelNVY:GetValue("NVY_VALOR"), TamSX3("NVY_VALOR")[2] )

				aDespDiv[nPosDesp][4] := oModelNVY:GetValue("NVY_VALOR")
				aDespDiv[nPosDesp][5] := aLancDiv[aPosFilho[1]][aPosFilho[2]][2]

			EndIf

		EndIf

		oModelNVY:goLine(nLineNVY)

		If !IsInCallStack("JANX8_VDES") .And. !IsInCallStack("JANX0_VDES")
			lRet := lRet .And. JurLoadValue( oModelNX8, "NX8_VDESP",, Round( oModelNX8:GetValue("NX8_VDESP") - nDifVlr, TamSX3("NX8_VDESP")[2] )  )
			lRet := lRet .And. JurLoadValue( oModelNX0, "NX0_VLFATD",, Round( oModelNX0:GetValue("NX0_VLFATD") - nDifVlr, TamSX3("NX0_VLFATD")[2] )  )
		EndIf

  		aCasos[nPos][04] := oModelNX1:GetValue( "NX1_VDESP" )

		//aAltPend [1] Tipo [2] Cliente [3] Loja [4] Caso [5] Contrato
		aAdd(aAltPend , {'DP', cClient, cLoja, cCaso, cContr } )

	Else
		lRet := JurMsgErro(STR0235) // "Caso não ajustado"
	EndIf

ElseIf cInstanc == "NX8" //Tratamento para evitar que o saldo crie novas despesas filhas com valor ajuste
	nPos     := J202ACSPOS(cClient, cLoja, cCaso, cContr)

	nSaldo   := oModelNX1:GetValue( "NX1_VDESP" )

	nLineNVY := oModelNVY:nLine
	nMaiorVl := oModelNVY:GetValue("NVY_VALOR")

	For nLinha := 1 To oModelNVY:Length()

		If oModelNVY:GetValue("NVY_VALOR", nLinha ) > 0  .And. !Empty(oModelNVY:GetValue("NVY_CPREFT", nLinha))

			nVlDPPre  := Round(JA201FConv(oModelNX0:GetValue("NX0_CMOEDA"), oModelNVY:GetValue( "NVY_CMOEDA", nLinha), oModelNVY:GetValue("NVY_VALOR", nLinha), "2",;
								oModelNX0:GetValue("NX0_DTEMI"), /*cCodFImpr*/, oModelNX0:GetValue("NX0_COD"), /*cXFilial*/ )[1], TamSX3("NVY_VALOR")[2])

			If nVlDPPre >= nMaiorVl
				nPosPai := nLinha
			EndIf

			nSaldo := nSaldo - nVlDPPre

		EndIf
	Next nLinha

EndIf

RestArea( aArea )

Return lRet

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          FUNÇÕES ALTERAÇÃO POR PERIODO OPÇÃO 2 = "ULTIMO" PARA DESPESAS - FIM                         //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Static function JA202DataID(oModel)
Local lRet      := .T.
Local aArea     := GetArea()
Local oModelNX8 := oModel:GetModel("NX8DETAIL")
Local oModelNX1 := oModel:GetModel("NX1DETAIL")
Local oModelNX2 := oModel:GetModel("NX2DETAIL")
Local nSavNX8
Local nSavNX1
Local nSavNX2
Local nLinNX8
Local nLinNX1
Local nLinNX2
Local cX2CCLIEN := ""
Local cX2CLOJA  := ""
Local cX2CCONTR := ""
Local cX2CCASO  := ""
Local cX2CODSEQ := ""

nSavNX8 := oModelNX8:GetLine()
NX2->(DbSetOrder(1)) //NX2_FILIAL + NX2_CPREFT + NX2_CPART + NX2_CCLIEN + NX2_CLOJA + NX2_CCONTR + NX2_CCASO + NX2_CODSEQ

For nLinNX8 := 1 To oModelNX8:Length()
	oModelNX8:GoLine(nLinNX8)
	nSavNX1 := oModelNX1:GetLine()
	For nLinNX1 := 1 To oModelNX1:Length()
		oModelNX1:GoLine(nLinNX1)
		nSavNX2 := oModelNX2:GetLine()
		For nLinNX2 := 1 To oModelNX2:Length()

			If oModelNX2:GetDataID(nLinNX2) == 0
				oModelNX2:GoLine(nLinNX2)
				cNX0COD   := oModelNX2:GetValue("NX2_CPREFT")
				cX2Part   := oModelNX2:GetValue("NX2_CPART")
				cX2CCLIEN := oModelNX2:GetValue("NX2_CCLIEN")
				cX2CLOJA  := oModelNX2:GetValue("NX2_CLOJA")
				cX2CCONTR := oModelNX2:GetValue("NX2_CCONTR")
				cX2CCASO  := oModelNX2:GetValue("NX2_CCASO")
				cX2CODSEQ := oModelNX2:GetValue("NX2_CODSEQ")

				If NX2->(MsSeek( xFilial("NX2") + cNX0COD + cX2Part + cX2CCLIEN + cX2CLOJA + cX2CCONTR + cX2CCASO + cX2CODSEQ ) )
					oModelNX2:SetDataID( NX2->( Recno()) )
				EndIf
			EndIf

		Next nLinNX2
		oModelNX2:GoLine(nSavNX2)
	Next nLinNX1
	oModelNX1:GoLine(nSavNX1)
Next nLinNX8
oModelNX8:GoLine(nSavNX8)

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202GeraRpt
Emissão de relatórios por SmartClient secundário.

@author Jacques Alves Xavier
@since 17/03/13
/*/
//-------------------------------------------------------------------
Main Function J202GeraRpt(cParams, lAutomato)
Local lRet        := .T.
Local lExit       := .F.
Local aArea       := GetArea()
Local nVezes      := 0
Local cUser       := ""
Local aParam      := {}
Local nNext       := 0
Local cEmpAux     := ""
Local cFilAux     := ""
Local cCryPath    := ""
Local oFilaExe    := Nil
Local aRetFila    := {}
Local cTIPO       := ""
Local cPRE        := ""
Local cThreadOri  := ""

Default cParams   := ""
Default lAutomato := .F.

If(!lAutomato)
	cParams := StrTran(cParams, Chr(135), " ")
	aParam  := StrTokArr(cParams, "||")

	PtInternal(1, "J202GeraRpt: Start " )

	If (lRet := Len(aParam) >= 4)
		cUser       := aParam[1]
		cEmpAux     := aParam[2]
		cFilAux     := aParam[3]
		cCryPath    := aParam[4]

		If Len(aParam) >= 6
			cThreadOri := aParam[6]
		EndIf

		RpcSetType(3)
		RpcSetEnv(cEmpAux, cFilAux, , , "PFS")
		__cUserId := cUser
	EndIf

EndIf

If lRet

	oFilaExe   := JurFilaExe():New("JURA202", "2", cThreadOri) // 2 = Impressão
	If oFilaExe:OpenReport()

		dbSelectArea("OH1")

		While !KillApp()

			PtInternal(1, "J202GeraRpt: GetNext table OH1" )
			aRetFila   := oFilaExe:GetNext()
			If( Len(aRetFila) > 1 .And. Len(aRetFila[1]) > 1 .And. Len(aRetFila[1][1]) > 1 .And. Len(aRetFila[1][2]) > 1.And. aRetFila[2] > 0)
				cTIPO    := aRetFila[1][1][2] // 1="Impressora"; 2="Tela"; 3="Nenhum"
				cPRE     := aRetFila[1][2][2] // Código da Pré-Fatura
				nNext    := aRetFila[2]
			Else
				nNext := 0
			EndIf

			If nNext > 0
				OH1->(dbGoto(nNext))
				PtInternal(1, "J202GeraRpt: Print pre invoice " + cPRE )

				If NX0->( dBSeek( xFilial("NX0") + cPRE))
					If JA202REFAZ(cPRE, .F., cTIPO, cCryPath, lAutomato, .T.)
						RecLock("NX0", .F.)
						NX0->NX0_OK := Space(TamSX3("NX0_OK")[1]) // Limpa a marca
						NX0->(MsUnLock())
						NX0->(dbCommit())
					EndIf
				EndIf

				oFilaExe:SetConcl(nNext)
				Sleep(500)

			Else
				PtInternal(1, "J202GeraRpt: Idle " )
				lExit := lAutomato .Or. !oFilaExe:IsOpenWindow() //Fim da emissão
				Sleep(1000)
			EndIf
			If lExit
				PtInternal(1, "J202GeraRpt: Out " )
				Exit
			EndIf

			nVezes += 1
		EndDo

		oFilaExe:CloseReport()

		PtInternal(1, "J202GeraRpt: Finish " )

	EndIf

EndIf
RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J202ADDREL
Adiciona a tabela temporária a fatura a ser gerada o relatÃ³rio.

@author Jacques Alves Xavier
@since 17/03/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function J202ADDREL(cCodPre, cResult, lAutomato)
Local lRet     := .F.
Local aArea    := GetArea()
Local nRec     := 0
Local oFilaExe := JurFilaExe():New( "JURA202", "2", cValToChar(ThreadID())) //2=Impressão

	JurLogMsg("J202ADDREL: " + cCodPre)

	ProcRegua( 0 )
	IncProc()

	oFilaExe:StartReport(lAutomato) //Verifica e abre a Thread de relatório se não estiver aberta
	oFilaExe:AddParams(STR0069, cResult) //#Resultado
	oFilaExe:AddParams(STR0026, cCodPre) //#Pré-Fatura
	nRec := oFilaExe:Insert()

	lRet := nRec > 0
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202DivCas
Rotina para calcular os totais da divisão dos honorários para os casos,
gravando no campo NX1_VHON. (ver rotina J201EDivCas)

@Params		cTabela : Atualiza os honorario do caso ou contrato
				(válido apenas para contratos sem parcelas de fixo)
				"NX1" - para atualizar apenas o caso posicionado
				"NX8" - Atualiza os casos do contrato posicionado

@Return		.T. Se efetuou a alteração com exito

@author Luciano Pereira dos Santos
@since 20/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202DivCas(cTabela)
Local lRet        := .T.
Local aArea       := GetArea()
Local oModel      := If(oModelOld = Nil, FwModelActive(), oModelOld)
Local oModelNX8   := oModel:GetModel( 'NX8DETAIL' )
Local oModelNX1   := oModel:GetModel( 'NX1DETAIL' )
Local oModelNT1   := oModel:GetModel( 'NT1DETAIL' )
Local nLineNT1    := 0
Local nLineNX1    := 0
Local nSavlNX1    := 0
Local nSavlNT1    := 0
Local dDtIni      := CToD( '  /  /  ' )
Local dDtFin      := CToD( '  /  /  ' )
Local aNVE        := {}
Local lVincTS     := .F.
Local lCasoAtiv   := .F.
Local lTemAtivo   := .F.
Local lQtdCaso    := .F.
Local nVlTSTot    := 0
Local nVlTBTot    := 0
Local aNX1Del     := {}
Local aNX1Recs    := {}
Local nPesoTot    := 0
Local nQtdCas     := 0
Local nVlTSCas    := 0
Local nVlTBCas    := 0
Local nPercen     := 0
Local nVlCasoH    := 0
Local nVlCasoD    := 0
Local cTemTS      := 0
Local cTemDes     := 0
Local cTemTab     := 0
Local cTpHon      := ""
Local cCobH       := ""
Local cCobF       := ""
Local cTpDiv      := AllTrim(GetMv("MV_JDIVCAS",, "1")) //Padrao "1" - (1=?TS?;2=?Peso do Caso?)
lOCAL nTotFX      := 0
Local nVlTSVin    := 0
Local nVlTSVinTot := 0
Local lJVincTS    := SuperGetMv('MV_JVINCTS ',, .T.)

If oModelNX8:GetValue("NX8_FIXO") == "1" .And. !oModelNT1:IsEmpty()
	nTotFX := oModelNX8:GetValue("NX8_VFIXO")

	dDtIni := oModelNT1:GetValue('NT1_DATAIN')
	dDtFin := oModelNT1:GetValue('NT1_DATAFI')

	nSavlNT1 := oModelNT1:GetLine()
	For nLineNT1 := 1 To oModelNT1:GetQtdLine()

		If oModelNT1:GetValue('NT1_DATAIN', nLineNT1) < dDtIni
			dDtIni := oModelNT1:GetValue('NT1_DATAIN', nLineNT1)
		EndIf
		If oModelNT1:GetValue('NT1_DATAFI', nLineNT1) > dDtFin
			dDtIni := oModelNT1:GetValue('NT1_DATAIN', nLineNT1)
		EndIf

	Next nLineNT1
	oModelNT1:GoLine(nSavlNT1)

	nSavlNX1 := oModelNX1:GetLine()

	For nLineNX1 := 1 To oModelNX1:GetQtdLine()

		If !Empty(dDtIni) .And. !Empty(dDtFin)

			aNVE := JurGetDados("NVE", 1, xFilial("NVE") + oModelNX1:GetValue("NX1_CCLIEN", nLineNX1) +;
								 		 oModelNX1:GetValue("NX1_CLOJA", nLineNX1) + oModelNX1:GetValue("NX1_CCASO", nLineNX1),;
										{"NVE_SITUAC", "NVE_DTENCE", "NVE_DTENTR", "NVE_PESO"} )

			lCasoAtiv := ( aNVE[1] == "1" .And. aNVE[3] <= dDtFin ) ;
			               .Or. ( aNVE[1] == "2" .And. aNVE[2] >= dDtIni .And. aNVE[3] <= dDtFin )

		Else
			lCasoAtiv := .T.
		EndIf

		If lCasoAtiv

			nVlTSTot += oModelNX1:GetValue("NX1_VTS", nLineNX1)
			nVlTSVinTot += oModelNX1:GetValue("NX1_VTSVIN", nLineNX1)
			nVlTBTot += oModelNX1:GetValue("NX1_VTAB", nLineNX1)
			nPesoTot += aNVE[4]

			AAdd(aNX1Recs, {oModelNX1:GetValue("NX1_VTS", nLineNX1), oModelNX1:GetValue("NX1_VTAB", nLineNX1), aNVE[4], nLineNX1,;  //4
							oModelNX1:GetValue("NX1_TS", nLineNX1), oModelNX1:GetValue("NX1_DESP", nLineNX1),;  //6
							oModelNX1:GetValue("NX1_LANTAB", nLineNX1), oModelNX1:GetValue("NX1_VDESP", nLineNX1), oModelNX1:GetValue("NX1_VTSVIN", nLineNX1) } )  //9
		Else

			AAdd(aNX1Del, {oModelNX1:GetValue("NX1_VTS", nLineNX1), oModelNX1:GetValue("NX1_VTAB", nLineNX1), aNVE[4], nLineNX1,;  //4
						   oModelNX1:GetValue("NX1_TS", nLineNX1), oModelNX1:GetValue("NX1_DESP", nLineNX1),;  //6
						   oModelNX1:GetValue("NX1_LANTAB", nLineNX1), oModelNX1:GetValue("NX1_VDESP", nLineNX1), oModelNX1:GetValue("NX1_VTSVIN", nLineNX1) } )  //9
		EndIf

		lTemAtivo := lTemAtivo .Or. lCasoAtiv

	Next nLineNX1

	If !lTemAtivo
		aNX1Recs := aClone( aNX1Del )
	EndIf

	//Calcula o percentual correto e aplica o calculo atualizando a NXC
	nQtdCas := Len(aNX1Recs)

	For nLineNX1 := 1 To nQtdCas
		oModelNX1:GoLine(nLineNX1)

		nPesoCas := aNX1Recs[nLineNX1][3]
		nVlTSCas := aNX1Recs[nLineNX1][1]
		nVlTBCas := aNX1Recs[nLineNX1][2]
		nVlTSVin := aNX1Recs[nLineNX1][9]
		nPercen  := 0
		nVlCasoH := 0
		nVlCasoD := aNX1Recs[nLineNX1][8]
		cTemTS   := aNX1Recs[nLineNX1][5]
		cTemDes  := aNX1Recs[nLineNX1][6]
		cTemTab  := aNX1Recs[nLineNX1][7]

		//Verifica o metodo de calculo do percentual

		//Por Valor TS
		//Agora valida o valor de time sheet vinculado, para tratar tipo de honorário fixo que tiveram ts vinculados.
		If cTpDiv == "1" .And. (nVlTSTot > 0 .Or. nVlTSVinTot > 0) .And. lTemAtivo
			nPercen  := IIF(!Empty(nVlTSCas), nVlTSCas, nVlTSVin) / IIF(!Empty(nVlTSTot), nVlTSTot, nVlTSVinTot)

		//Por Peso de Caso
		ElseIf cTpDiv == "2" .And. nPesoTot > 0 .And. lTemAtivo
			nPercen  := nPesoCas / nPesoTot

		//Valor dividido pela quantidade de casos - se nenhum caso possuir TS, peso ou nenhum estiver em andamento.
		Else
			nPercen  := 1 / nQtdCas
			lQtdCaso := .T.
		EndIf

		//NRA_COBRAF, NRA_COBRAH, NRA_NCOBRA
		cTpHon  := JurGetDados("NT0", 1, xFilial("NT0") + oModelNX8:GetValue("NX8_CCONTR"), "NT0_CTPHON")
		cCobH   := JurGetDados("NRA", 1, xFilial("NRA") + cTpHon, "NRA_COBRAH")
		cCobF   := JurGetDados("NRA", 1, xFilial("NRA") + cTpHon, "NRA_COBRAF")
		lVincTS := (cCobH = "2" .And. cCobF = "1" .And. lJVincTS)

		//Calcula o valor de honorarios
		If lVincTS
			nVlCasoH := nVlTBCas + IIf(Empty(nTotFX), 0, nTotFX * nPercen)
		Else
			nVlCasoH := nVlTSCas +  nVlTBCas + IIf(Empty(nTotFX), 0, nTotFX * nPercen)
		EndIf

		If lQtdCaso .Or. nVlTSCas > 0 .Or. nVlTBCas > 0 .Or.  nVlCasoH > 0 .Or. nVlCasoD > 0;
		   .Or. cTemTS == "1" .Or. cTemDes == "1" .Or. cTemTab == "1"
			lRet := JurLoadValue( oModelNX1, "NX1_VHON",, nVlCasoH )
		EndIf

	Next nLineNX1

	oModelNX1:GoLine(nSavlNX1)

Else
	If cTabela == "NX8"

		nSavlNX1 := oModelNX1:GetLine()

		For nLineNX1 := 1 To oModelNX1:GetQtdLine()
			oModelNX1:GoLine(nLineNX1)

			//Efetuada alteração para considerar o valor da faixa de faturamento nos honorários, quando este tiver valor.
			lRet := JurLoadValue( oModelNX1, "NX1_VHON",, ( Iif(oModelNX1:GetValue("NX1_VFXFAT") == 0, oModelNX1:GetValue("NX1_VTS"), oModelNX1:GetValue("NX1_VFXFAT") ) ) + oModelNX1:GetValue("NX1_VTAB") )

		Next nLineNX1

		oModelNX1:GoLine(nSavlNX1)

	ElseIf cTabela == "NX1"
		lRet := JurLoadValue( oModelNX1, "NX1_VHON",, ( Iif(oModelNX1:GetValue("NX1_VFXFAT") == 0, oModelNX1:GetValue("NX1_VTS"), oModelNX1:GetValue("NX1_VFXFAT") ) ) + oModelNX1:GetValue("NX1_VTAB") )
	EndIf
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202FMinut()
Rotina filtro para remover do browser as minutas enviadas para fila de emissão,
em Conferencia e Minuta cancelada.

@Return cRet  Filtro em ADVPL para o Browser

@author Luciano Pereira dos Santos
@since 20/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202FMinut()
Local aArea     := GetArea()
Local cQryRes   := GetNextAlias()
Local aSequen   := {}
Local cQuery    := ""
Local cRet      := "NX0_SITUAC <> '1'"

cQuery :=" SELECT NX0.NX0_COD "
cQuery += " FROM " + RetSqlName( 'NX0' ) + " NX0, "
cQuery +=      " " + RetSqlName( 'NX5' ) + " NX5 "
cQuery += " WHERE NX0.NX0_FILIAL = '" + xFilial("NX0") + "' "
cQuery +=   " AND NX5.NX5_FILIAL = '" + xFilial("NX5") + "' "
cQuery +=   " AND NX5.NX5_CPREFT = NX0.NX0_COD "
cQuery +=   " AND NX0.NX0_SITUAC IN ('5', '9') "
cQuery +=   " AND NX0.D_E_L_E_T_ = ' ' "
cQuery +=   " AND NX5.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery, .F.)
dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

While !(cQryRes)->(EOF())
	aAdd(aSequen, (cQryRes)->NX0_COD)
	(cQryRes)->(DBSkip())
EndDo

(cQryRes)->(dbCloseArea())

If !Empty(aSequen)
	cRet := cRet + ".And. !(NX0_COD $ '" + AtoC(aSequen, "|") + "')"
EndIf

RestArea( aArea )

Return cRet

//-----------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} JA202ARRETS()
Rotina para fazer o arredondamento dos time sheets vinculados à pré-fatura, devido a não aceitação de horas
fracionadas por parte de alguns clientes e-billing..

@Param		oModel  - Modelo de dados da pré-fatura

@Return		lRet	- .T. para êxito

@author Cristina Cintra Santos
@since 17/07/2013
@version 1.0
/*/
//------------------------------------------------------------------------------------------------------------
Static Function JA202ARRETS(oModel)
Local lRet         := .T.
Local oModelNX0    := oModel:GetModel("NX0MASTER")
Local oStrucNX0    := oModelNX0:GetStruct()
Local oModelNX8    := oModel:GetModel("NX8DETAIL")
Local oStrucNX8    := oModelNX8:GetStruct()
Local oModelNX1    := oModel:GetModel("NX1DETAIL")
Local oStrucNX1    := oModelNX1:GetStruct()
Local oModelNUE    := oModel:GetModel("NUEDETAIL")
Local oStrucNUE    := oModelNUE:GetStruct()
Local lJURTS3      := SuperGetMV('MV_JURTS3',, .T.)  //.T. permite hora fracionada
Local nTipoApon    := SuperGetMV('MV_JURTS2',, 1 )   //1 = UT, 2 = Hora Fracionada, 3 = Tempo (HH:MM)
Local nHrFrac      := 0
Local nSemTS       := 0

Local nNX8         := 0
Local nNX1         := 0
Local nNUE         := 0

Local nLNNUE       := 0

Local nQtdeNX1     := 0
Local nQtdeNX8     := 0
Local nQtdeNUE     := 0
Local nQtdCasos    := 0

Local cCodTS       := ''
Local lLiberaTudo
Local lLibAlteracao
Local aRetBlqTS
Local cCodNX8      := ""
Local lTeveArrend  := .F.

Local cQuery       := ""
Local cAlsRes      := ""
Local lTemTs       := .F.
Local cDtTs        := "        "
Local cPreFat      := oModelNX0:GetValue("NX0_COD")

Local lTela        := !IsBlind()

//Valida o conteúdo do parâmetro MV_JURTS3
If !lJURTS3
	lRet := JurMsgErro(STR0244) //"Não foi possível realizar o arredondamento das horas. Verifique se o parâmetro MV_JURTS3 está como .T., de forma a permitir hora fracionada."
EndIf

//Valida a existência de alterações pendentes de TSs, pois existindo não é possível realizar o arredondamento
If lRet
	If Len(aAltPend) > 0
		lRet := JurMsgErro(STR0170) //"Existem alterações de valor pendentes, para efetuar novas alterações cancele as anteriores!"
	EndIf
EndIf

If lRet

	If lTela
		J202SCorte(oModel, "NUE", cPreFat)
		
		__oProcess:SetRegua1(__nQtdNUE)
		__oProcess:SetRegua2(0)
	EndIf

	cQuery := " SELECT NUE.NUE_COD, NUE.NUE_DATATS, NX1.NX1_CCONTR "
	cQuery +=   " FROM " + RetSqlName('NUE') + " NUE "
	cQuery +=  " INNER JOIN " + RetSqlName('NX1') + " NX1 "
	cQuery +=     " ON NX1.NX1_FILIAL = '" + xFilial('NX1')  + "' "
	cQuery +=    " AND NX1.NX1_CPREFT = NUE.NUE_CPREFT "
	cQuery +=    " AND NX1.NX1_CCLIEN = NUE.NUE_CCLIEN "
	cQuery +=    " AND NX1.NX1_CLOJA  = NUE.NUE_CLOJA "
	cQuery +=    " AND NX1.NX1_CCASO  = NUE.NUE_CCASO "
	cQuery +=    " AND NX1.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE NUE.NUE_FILIAL = '" + xFilial('NUE')  + "' "
	cQuery +=    " AND NUE.NUE_CPREFT = '" + cPreFat + "' "
	cQuery +=    " AND NUE.D_E_L_E_T_ = ' ' "

	cAlsRes := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cAlsRes, .T., .F. )

	While !(cAlsRes)->(EOF())

		If lTela
			__oProcess:IncRegua1(i18n(STR0341, {__nCountNUE++, __nQtdNUE} )) // "Preparando lançamentos - #1 de #2."
			__oProcess:IncRegua2(STR0340) // "Identificando lançamentos para arredondamento."
		EndIf

		lTemTs := .T.

		If lLibParam
			If cDtTs <> (cAlsRes)->NUE_DATATS // Só executa a função JBlqTSheet se a data ainda não foi verificada
				aRetBlqTS := JBlqTSheet(SToD((cAlsRes)->NUE_DATATS))
			EndIf
			lLiberaTudo   := aRetBlqTS[1]
			lLibAlteracao := aRetBlqTS[3]
			lLibParam     := aRetBlqTS[5]
		EndIf

		If !lLibParam
			lRet := .F.
		EndIf

		If !lLiberaTudo .And. !lLibAlteracao
			cCodTS  += AllTrim((cAlsRes)->NUE_COD) + "; "
			cCodNX8 += AllTrim((cAlsRes)->NX1_CCONTR) + "#"
		EndIf

		cDtTs := (cAlsRes)->NUE_DATATS

		(cAlsRes)->(DBSkip())
	EndDo

	(cAlsRes)->(dbCloseArea())
EndIf

If lRet .And. lTemTs

	If lTela
		__nCountNUE := 1
		__nCountNX1 := 1
		
		__oProcess:SetRegua1(__nQtdNX1)
		__oProcess:SetRegua2(__nQtdNUE)
	EndIf

	oStrucNX0:SetProperty( 'NX0_VTSANT', MODEL_FIELD_NOUPD, .F. )
	oStrucNX0:SetProperty( 'NX0_VTSANT', MODEL_FIELD_WHEN, {|| .T.} )
	oStrucNX8:SetProperty( 'NX8_VTSANT', MODEL_FIELD_NOUPD, .F. )
	oStrucNX8:SetProperty( 'NX8_VTSANT', MODEL_FIELD_WHEN, {|| .T.} )
	oStrucNX1:SetProperty( 'NX1_VTSANT', MODEL_FIELD_NOUPD, .F. )
	oStrucNX1:SetProperty( 'NX1_VTSANT', MODEL_FIELD_WHEN, {|| .T.} )
	oStrucNUE:SetProperty( 'NUE_VTSANT', MODEL_FIELD_NOUPD, .F. )
	oStrucNUE:SetProperty( 'NUE_VTSANT', MODEL_FIELD_WHEN, {|| .T.} )

	oModelNX0:SetValue("NX0_VTSANT", oModelNX0:GetValue("NX0_VTS")) //Guarda o valor anterior de TS da pré-fatura

	If !(nTipoApon == 2)
		oStrucNUE:SetProperty( 'NUE_TEMPOR', MODEL_FIELD_NOUPD, .F. )
		oStrucNUE:SetProperty( 'NUE_TEMPOR', MODEL_FIELD_WHEN, {|| .T.} )
	EndIf

	nQtdeNX8 := oModelNX8:GetQtdLine()
	For nNX8 := 1 To nQtdeNX8

		If oModelNX8:GetValue("NX8_CCONTR", nNX8) $ cCodNX8 // O usuário não tem permissão de fazer alteração em algum timesheet, para esta linha.
			Loop
		EndIf

		oModelNX8:GoLine(nNX8)
		oModelNX8:SetValue("NX8_VTSANT", oModelNX8:GetValue("NX8_VTS")) //Guarda o valor anterior de TS do caso
		nQtdeNX1 := oModelNX1:GetQtdLine()

		For nNX1 := 1 To nQtdeNX1

			If lTela
				__oProcess:IncRegua1(i18n(STR0331, {oModelNX1:GetValue("NX1_CCASO", nNX1), __nCountNX1++, __nQtdNX1} )) // "Atualizando Caso #1 - #2 de #3."
			EndIf

			nQtdCasos++
			oModelNX1:GoLine(nNX1)
			If !oModelNX1:GetValue("NX1_TS") == '1'   //Ignora casos que não possuem TSs
				nSemTS++
				Loop
			EndIf
			oModelNX1:SetValue("NX1_VTSANT", oModelNX1:GetValue("NX1_VTS")) //Guarda o valor anterior de TS do caso
			nLNNUE   := oModelNUE:GetLine()
			nQtdeNUE := oModelNUE:GetQtdLine()
			For nNUE := 1 To nQtdeNUE

				If lTela
					__oProcess:IncRegua2(i18n(STR0336, {__nCountNUE++, __nQtdNUE} )) // "Arredondando Time Sheets - #1 de #2."
				EndIf

				oModelNUE:GoLine(nNUE)
				oModelNUE:SetValue("NUE_VTSANT", oModelNUE:GetValue("NUE_VALOR1")) //Guarda o valor anterior do TS na moeda da PF

				nHrFrac  := Round(oModelNUE:GetValue("NUE_TEMPOR"), 1)
				lRet     := JurSetValue(oModelNUE, 'NUE_TEMPOR',, nHrFrac )

				If !lRet
					MsgAlert(STR0245) // "Não foi possível realizar o arredondamento."
					Exit
				Else
					lTeveArrend := .T.
				EndIf

			Next nNUE

		Next nNX1

	Next nNX8

	If !Empty(cCodTS)
		MsgAlert(STR0264 + cCodTS) // "Você não tem permissão para alterar os seguintes Time Sheets: "
		If ! lTeveArrend
			lRet := .F.
		EndIf
	EndIf

	If nSemTS == nQtdCasos
		MsgAlert(STR0246) // "Não há casos com Time Sheets vinculados."
		lRet := .F.
	EndIf

	oStrucNX0:SetProperty( 'NX0_VTSANT', MODEL_FIELD_NOUPD, .T. )
	oStrucNX0:SetProperty( 'NX0_VTSANT', MODEL_FIELD_WHEN, {|| .F.} )
	oStrucNX8:SetProperty( 'NX8_VTSANT', MODEL_FIELD_NOUPD, .T. )
	oStrucNX8:SetProperty( 'NX8_VTSANT', MODEL_FIELD_WHEN, {|| .F.} )
	oStrucNX1:SetProperty( 'NX1_VTSANT', MODEL_FIELD_NOUPD, .T. )
	oStrucNX1:SetProperty( 'NX1_VTSANT', MODEL_FIELD_WHEN, {|| .F.} )
	oStrucNUE:SetProperty( 'NUE_VTSANT', MODEL_FIELD_NOUPD, .T. )
	oStrucNUE:SetProperty( 'NUE_VTSANT', MODEL_FIELD_WHEN, {|| .F.} )

	If !(nTipoApon == 2)
		oStrucNUE:SetProperty( 'NUE_TEMPOR', MODEL_FIELD_NOUPD, .T. )
		oStrucNUE:SetProperty( 'NUE_TEMPOR', MODEL_FIELD_WHEN, {|| .F.} )
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202NOVOS
Menu de operações para vincular novos lançamentos na pré-fatura

@author Cristina Cintra
@since 05/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA202NOVOS( oView, oBotao )
Local aMenuItem  := {}
Local oModel     := oView:GetModel()
Local oMenu      := Nil

oMenu := MenuBegin(,,,, .T.,, oBotao, )
aAdd( aMenuItem, MenuAddItem( STR0008, ,,,,,, oMenu, {|| FWMsgRun( , {|| JA202Add(oModel, oView, "TS")}, STR0147, STR0050) },,,,, { || .T. } ) ) //"Time-Sheet""Aguarde"
aAdd( aMenuItem, MenuAddItem( STR0009, ,,,,,, oMenu, {|| FWMsgRun( , {|| JA202Add(oModel, oView, "DP")}, STR0147, STR0050) },,,,, { || .T. } ) ) //"Despesas""Aguarde"
aAdd( aMenuItem, MenuAddItem( STR0010, ,,,,,, oMenu, {|| FWMsgRun( , {|| JA202Add(oModel, oView, "LT")}, STR0147, STR0050) },,,,, { || .T. } ) ) //"Lanc.Tabelado""Aguarde"
MenuEnd()

oMenu:Activate( 10, 10, oBotao )

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202Add
Rotina para chamada de inclusão de novos lançamentos

@author Luciano Pereira dos Santos
@since 21/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA202Add(oModel, oView, cTpLanc)
Local lExeTotPre := .T.
Local lRet       := .T.

If oModel:lModify
	If ApMsgYesNo(STR0132, STR0133) // "Ao realizar esta operação o sistema salvará todas as alterações feitas na tela!" e "ATENÃ‡ÃƒO"
		__lExibeOK := .F.
		If (lRet := oModel:VldData())
			lRet := oModel:CommitData()
		Else
			JurShowErro( oModel:GetModel():GetErrorMessage() )
		EndIf
		__lExibeOK := .T.
	Else
		lRet := .F.
	EndIf
EndIf

If lRet
	Do Case
		Case cTpLanc == "TS"
			lExeTotPre := JURA202B()
		Case cTpLanc == "DP"
			lExeTotPre := JURA202C()
		Case cTpLanc == "LT"
			lExeTotPre := JURA202D()
	End Case

	If lExeTotPre .And. NX0->NX0_SITUAC == SIT_ALTERADA
	   	oModel:Deactivate()
		oModel:Activate()

		If (lRet := JA202TotPre())
			If (lRet := oModel:VldData())
				lRet := oModel:CommitData()
				oView:Refresh()
				oModel:Deactivate()
				oModel:Activate()
			Else
				JurShowErro( oModel:GetModel():GetErrormessage() )
			EndIf
		EndIf
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadNX2
Load dos dados da NX2 para possibilitar a ordenação também por sigla
na grid de Participantes
Melhoria de performace no carregamento de pré-fatura

@Param  Grid da NX2

@author Luciano Pereira dos Santos
@since 17/01/2017
@version 2.0
/*/
//-------------------------------------------------------------------
Static Function LoadNX2(oGrid)
Local aRet     := FormLoadGrid(oGrid)
Local aStruct  := {}
Local nFilial  := 0
Local nCateg   := 0
Local nSigla   := 0
Local lIsRest  := Iif(FindFunction("JurIsRest"), JurIsRest(), .F.)

If !lIsRest .And. SuperGetMV('MV_JORDPAR',, '1') == '2'

	aStruct  := oGrid:oFormModelStruct:GetFields()

	nFilial := aScan( aStruct, { |e| e[MODEL_FIELD_IDFIELD] == 'NX2_FILIAL' } )
	nSigla  := aScan( aStruct, { |e| e[MODEL_FIELD_IDFIELD] == 'NX2_SIGLA' } )
	nCateg  := aScan( aStruct, { |e| e[MODEL_FIELD_IDFIELD] == 'NX2_CCATEG' } )

	If nFilial > 0 .And. nCateg > 0 .And. nSigla > 0
		aSort( aRet,,, { |aX, aY| aX[2][nFilial] + aX[2][nSigla] + aX[2][nCateg] < aY[2][nFilial] + aY[2][nSigla] + aY[2][nCateg] } )
	EndIf

EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadLanc
Load dos dados da NUE, NVY e NV4 para possibilitar a ordenação 
também por sigla nos grids de Time Sheets, Despesas e Tabelados
Melhoria de performace no carregamento de pré-fatura

@param oGrid    , Grid da NUE, NVY ou NV4
@param cCpoFil  , Campo de Filial da Tabela do Grid
@param cCpoData , Campo de Data da Tabela do Grid
@param cCpoSigla, Campo de Sigla da Tabela do Grid
@param lIsRest  , Se a execução está sendo feita via REST

@author Luciano Pereira dos Santos
@since  17/01/2017
@version 2.0
/*/
//-------------------------------------------------------------------
Static Function LoadLanc(oGrid, cCpoFil, cCpoData, cCpoSigla, lIsRest)
	Local aRet    := {}
	Local aStruct := oGrid:oFormModelStruct:GetFields()
	Local nData   := aScan( aStruct, { |e| e[MODEL_FIELD_IDFIELD] == cCpoData } )
	Local nFilial := 0
	Local nSigla  := 0

	aRet := J202VigLanc(oGrid, nData)

	If !lIsRest .And. SuperGetMV('MV_JORDPAR',, '1') == '2'

		nFilial := aScan( aStruct, { |e| e[MODEL_FIELD_IDFIELD] == cCpoFil   } )
		nSigla  := aScan( aStruct, { |e| e[MODEL_FIELD_IDFIELD] == cCpoSigla } )

		If nFilial > 0 .And. nData > 0 .And. nSigla > 0
			aSort( aRet,,, { |aX, aY| aX[2][nFilial] + DtoS(aX[2][nData]) + aX[2][nSigla] < aY[2][nFilial] + DtoS(aY[2][nData]) + aY[2][nSigla] } )
		EndIf

	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202VigLanc
Filtra lançamentos considerando a vigência do contrato

@param   oGrid     , Modelo do Grid da Pré-Fatura
@param   nPosDtLanc, Data do Lançamento

@return  aLanc     , Dados dos Lançamentos

@author  Luciano Pereira / Jonatas Martins
@since   13/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202VigLanc(oGrid, nPosDtLanc)
	Local aDados    := FormLoadGrid(oGrid)
	Local oModel    := Nil
	Local oModelNX8 := Nil
	Local dDataIni  := Nil
	Local dDataFim  := Nil
	Local aLanc     := {}

	If !Empty(aDados)
		If NT0->(ColumnPos("NT0_DTVIGI")) > 0
			oModel    := oGrid:GetModel()
			oModelNX8 := oModel:GetModel("NX8DETAIL")
			dDataIni  := oModelNX8:GetValue("NX8_DTVIGI")
			dDataFim  := oModelNX8:GetValue("NX8_DTVIGF")
			If !Empty(dDataIni) .And. !Empty(dDataFim)
				aEval(aDados, {|a| IIF(a[2][nPosDtLanc] >= dDataIni .And. a[2][nPosDtLanc] <= dDataFim, Aadd(aLanc, aClone(a)), Nil)})
			Else
				aLanc := aClone(aDados)
			EndIf
		Else
			aLanc := aClone(aDados)
		EndIf

		JurFreeArr(aDados)
	EndIf

Return (aLanc)

//-------------------------------------------------------------------
/*/{Protheus.doc} J202NTSFORA
Função que calcula o valor total de todos os time sheets que estão no grid
e não devem ser considerados nos ajustes de tempo, tais como os TS com
participação do cliente.

@param aParticip - Chave do participante, para efetuar um filtro. (Opcional)
                   aParticip[1] = NX2_CPART,
                   aParticip[2] = NX2_VALORH,
                   aParticip[3] = NX2_CCATEG,
                   aParticip[4] = NX2_CMOTBH,
                   aParticip[5] = NX2_CLTAB

@author André Spirigoni Pinto
@since 01/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J202NTSFORA(oModelNUE, aParticip)
Local nValor      := 0
Local nI          := 0
Local nQtdLine    := 0
Local lEmpPart    := .T.

Default aParticip := {}

If !oModelNUE:IsEmpty()
	lEmpPart := Empty(aParticip)
	nQtdLine := oModelNUE:GetQtdLine()
	For nI := 1 To nQtdLine

		//Filtrar participante se o parâmetro "aParticip" foi passado
		If lEmpPart .Or. (;
			aParticip[1] == oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CPART2], nI) .And.;
			aParticip[2] == oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_VALORH], nI) .And.;
			aParticip[3] == oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CCATEG], nI) .And.;
			aParticip[4] == oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CMOEDA], nI) .And.;
			aParticip[5] == oModelNUE:GetValueByPos(__aNUEPosFields[POS_NUE_CLTAB] , nI) )

			//Filtrar TSs que não devem ser considerados nos ajustes de tempo
			If !oModelNUE:isDeleted(nI) .And. !JA202TEMPO(.F., oModelNUE:GetValue("NUE_CATIVI", nI))
				nValor += oModelNUE:GetValue("NUE_VALOR1", nI)
			EndIf
		EndIf
	Next
EndIf

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} Jur202LOk
Validação de linha:
Não permitir inclusão de linha sem participante preenchido.

@param oGrid    - Objeto do Grid
@param cAliasG  - Alias do Grid
@param nLine    - Linha do Grid
@param cJurUser - Usuário

@Return lRet   .T./.F. As informações são válidas ou não

@author Cristina Cintra
@since 01/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Jur202LOk(oGrid, cAliasG, nLine, cJurUser)
Local lRet       := .T.
Local lSetMsg    := .T.
Local nOperation := oGrid:GetModel():GetOperation()
Local cAba       := ""
Local cMsg       := ""
Local lInvcPart  := .T.

	If nOperation != 5

		If cAliasG == "NUEDETAIL"
			If Empty(oGrid:GetValueByPos(__aNUEPosFields[POS_NUE_CPART1])) .Or. Empty(oGrid:GetValueByPos(__aNUEPosFields[POS_NUE_CPART2]))
				lRet := .F.
				cAba := STR0269 + STR0008 //"Aba" "Time-Sheet"
			EndIf 
			
			If lRet .And. nOperation == 4 .And. oGrid:IsUpdated()
				oGrid:LoadValue("NUE_CUSERA", cJurUser)
				oGrid:LoadValue("NUE_ALTDT", Date())
				If NUE->(ColumnPos('NUE_ALTHR')) > 0
					oGrid:LoadValue("NUE_ALTHR", Time())
				EndIf
			EndIf
		ElseIf cAliasG == "NX4DETAIL"
			If !lIntRevis
				lInvcPart := !Empty(oGrid:GetValue("NX4_CPART"))
			EndIf
			If !lInvcPart
				lRet := .F.
				cAba := STR0269 + STR0028 //"Aba" "Histórico"
			EndIf
		ElseIf cAliasG == "NV4DETAIL" .And. Empty(oGrid:GetValue("NV4_CPART"))
			lRet := .F.
			cAba := STR0269 + STR0010 //"Aba" "Lanc. Tabelado"
		ElseIf cAliasG == "NVYDETAIL" 
			If JurIsRest()
				If oGrid:GetValue("NVY_COBRAR") == "2" .And. Empty(oGrid:GetValue("NVY_USRNCB"))
					lRet := .F.
					cMsg := STR0327 + CRLF + STR0269 + STR0009 // "O Código do Usuário que está alterando o lançamento para não cobrar deve ser preenchido (NVY_USRNCB)." # "Aba" "Despesas"
				Else
					JA49VLDCB(oGrid:GetValue("NVY_USRNCB"), .T., oGrid:GetModel())
				EndIf
			Else
				lRet := JA049OBS(nLine)
				lSetMsg := .F. // A função JA049OBS possui mensagem própria de erro.
			EndIf
		EndIf

	EndIf

	If !lRet .And. lSetMsg
		JurMsgErro(IIf(Empty(cMsg), STR0268 + CRLF + cAba, cMsg))  //"O participante não foi preenchido. Verifique!"
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202RetRel(cTpRel)
Função para retornar o tipo de relatorio de pre-fatura
Busca na NZO pelo tipo de relatorio e retorna o RPT especifico
e caso nao tenha o default JU201

@param 	cTpRel 	==> codigo do tipo de relatorio

@return cRet ==> RPT especifico

@author Mauricio Canalle
@since 28/03/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202RetRel(cTpRel)
Local aArea       := GetArea()
Local cRet        := 'JU201' // Relat Padrao
Local cDirCrystal := GetMV('MV_CRYSTAL')

NZO->(DbSetOrder(1))
If NZO->(Dbseek(xFilial('NZO') + cTpRel))
	cRet := Upper(Alltrim(NZO->NZO_ARQ))
	cRet := StrTran(cRet, '.RPT', '')  // tira o .rpt do nome caso tenha sido cadastrado
	If !File(cDirCrystal + cRet + '.RPT')  // verifica se encontra o arquivo especifico na pasta dos relatorios
		cRet := 'JU201'  // se nao encontra imprime o padrao
	EndIf
EndIf

RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202ALTREV
Função para alteração dos casos marcados na tela de Operação de Pré-fatura
para não revisados (NX1_SITREV = 2-Não).
Limpa também o tipo de retorno da revisão (NX1_RETREV).

Usado para situações em que houve o envio dos casos para Revisão, mas
por algum motivo será necessário o reenvio.

@Return lRet   .T./.F. As informações são válidas ou não

@author Cristina Cintra
@since 22/02/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202ALTREV(oModel, oView, cCodPre)
Local lRet      := .T.
Local oModelNX8 := oModel:GetModel('NX8DETAIL')
Local oModelNX1 := oModel:GetModel('NX1DETAIL')
Local nLNNX8    := 0
Local nLNNX1    := 0
Local nNX8      := 0
Local nNX1      := 0

nLNNX8 := oModelNX8:GetLine()
For nNX8 := 1 To oModelNX8:GetQtdLine()

	oModelNX8:GoLine(nNX8)
	nLNNX1 := oModelNX1:GetLine()
	For nNX1 := 1 To oModelNX1:GetQtdLine()
		oModelNX1:GoLine(nNX1)
		If oModelNX1:GetValue("NX1_TKRET")
			oModelNX1:SetValue("NX1_SITREV", "2")
		EndIf
	Next nNX1
	oModelNX1:GoLine(nLNNX1)

Next nNX8
oModelNX8:GoLine(nLNNX8)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR202Revs
Função para verificação da situação da pré-fatura e posterior chamada
da funcionalidade de alteração de revisor - Integ. Legal Desk.

@Return lRet  .T./.F. As informações são válidas ou não

@author Rafael Telles de Macedo
@since 01/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR202Revs(aAutoParam,lAutomato)
Local lRet         := .T.
Local aArea        := GetArea()
Local aAreaNX0     := NX0->(GetArea())
Local cSituac      := NX0->NX0_SITUAC

Default aAutoParam := {}
Default lAutomato  := .F.

If (cSituac $ ('2|3|C')) //Análise | Alterada | Em Revisão
	SetJura202(.F.)
	JURA202F(aAutoParam, lAutomato)
	SetJura202(.T.)
Else
	lRet := .F.
	MsgInfo(STR0273) //"A operação de Alterar Revisor só está disponível para as pré-faturas em situação 'Análise', 'Em Revisão' ou 'Alterada'. Verifique!"
EndIf

RestArea(aAreaNX0)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202CALC
Recalcula os valores da pré-fatura. Usado após o retorno das alterações
pelo revisor no Legal Desk.

@Param		cCPreFt  - Código da pré-fatura a ser recalculada
@Return		lOk      - .T. para êxito

@author Cristina Cintra
@since 22/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA202CALC(cCPreFt)
Local aArea      := GetArea()
Local aAreaNX0   := NX0->(GetArea())
Local lFltrHH    := !(Empty(NX0->NX0_DINITS) .And. Empty(NX0->NX0_DFIMTS))
Local aResult    := {}
Local oParams    := Nil
Local lCpoFxNc   := NX0->(ColumnPos("NX0_FXNC")) > 0 // Proteção
Local aCampos    := {"NX0_DTEMI", "NX0_DINITS", "NX0_DFIMTS", "NX0_DINITB", "NX0_DFIMTB", "NX0_DINIDP", "NX0_DFIMDP"}
Local aDatasPre  := {}

	If lCpoFxNc // Adiciona os campos de data de TS de contrato fixo ou não cobrável
		Aadd(aCampos, "NX0_DIFXNC")
		Aadd(aCampos, "NX0_DFFXNC")
	EndIf

	aDatasPre := JurGetDados("NX0", 1, xFilial("NX0") + cCPreFt, aCampos)

	oParams := TJPREFATPARAM():New()
	oParams:SetCodUser(__CUSERID)

	oParams:SetTpExec("2")
	oParams:SetSituac("2")
	oParams:SetDEmi(aDatasPre[1]) // Data de emissão da Pré-Fatura
	oParams:SetCFilaImpr("")
	oParams:SetFltrHH(lFltrHH)

	oParams:SetDIniH(aDatasPre[2]) // Referência Inicial de Honorários
	oParams:SetDFinH(aDatasPre[3]) // Referência Final   de Honorários

	oParams:SetDIniT(aDatasPre[4]) // Referência Inicial de Serviços Tabelados
	oParams:SetDFinT(aDatasPre[5]) // Referência Final   de Serviços Tabelados	

	oParams:SetDIniD(aDatasPre[6]) // Referência Inicial de Despesas
	oParams:SetDFinD(aDatasPre[7]) // Referência Final   de Despesas

	If lCpoFxNc
		oParams:SetFltrFxNC(!Empty(aDatasPre[8]) .And. !Empty(aDatasPre[9]))
		oParams:SetDInIFxNc(aDatasPre[8]) // Referência Inicial de TS de Contrato fixo ou não cobrável
		oParams:SetDFinFxNc(aDatasPre[9]) // Referência Final   de TS de Contrato fixo ou não cobrável
	EndIf

	BEGIN TRANSACTION
		cMessage := STR0228 + cCPreFt  //"Início - Refazendo a pré-fatura: "
		EventInsert( FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, "054", FW_EV_LEVEL_INFO, ""/*cCargo*/, STR0082, cMessage, .F. ) // "Impressão de Pré-Fatura"
		aResult  := JA202ReImp(oParams, cCPreFt)
		cMessage := STR0229 + cCPreFt //"Final - Refazendo a pré-fatura: "
		EventInsert( FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, "054", FW_EV_LEVEL_INFO, ""/*cCargo*/, STR0082, cMessage, .F. ) // "Impressão de Pré-Fatura"
		
		If !aResult[1]
			If !JurIsRest() // Quando for REST pode acontecer de retornar False pois não há mais lançamentos, isso deve ser permitido
				DisarmTransaction()
			Else
				//Coloca a situação de "Cancelada pela Revisão" quando forem retirados todos os contratos / lançamentos
				RecLock("NX0", .F.)
				NX0->NX0_SITUAC := "H" //Cancelada pela Revisão
				NX0->(MsUnlock())
				NX0->(DbCommit())
				J202HIST('5', cCPreFt, JurUsuario(__CUSERID), STR0156) //"A pré-fatura foi cancelada por não possuir mais lançamentos."
			EndIf
		EndIf

	END TRANSACTION

	MsUnlockAll()

	RestArea( aAreaNX0 )
	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J202HisPos
Pós-validacão do histórico de pré-fatura (NX4).

@author Cristina Cintra
@since 05/04/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202HisPos()
Local oModel     := FwModelActive()
Local oModelNX4  := oModel:GetModel("NX4DETAIL")
Local aSaveLn    := FwSaveRows()
Local nNX4       := 0
Local lRet       := .T.
Local cTipo      := ""

For nNX4 := 1 To oModelNX4:GetQtdLine()
	oModelNX4:GoLine(nNX4)

	cTipo := oModelNX4:GetValue("NX4_AUTO")

	If oModelNX4:IsDeleted() .And. cTipo == "1"
		lRet := JurMsgErro(STR0278) //"Não é possível excluir históricos incluídos pelo sistema."
		Exit
	EndIf

Next nNX4

FwRestRows(aSaveLn)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202OPLD
Limpa os campos usados nas operações de transferência, retirar/acumular e WO a partir
do Legal Desk (_ACAOLD). Integração tela de Revisão.

@Params		cAliasTab  - Alias da tabela de lançamento (NVY, NUE, NV4)
@Params		nRecno     - Recno para busca do lançamento
@Params		cCodPreFt - Código da pré-fatura que está sendo alterada
@Params		cAcaoLD   - Código da ação efetuada no Legal Desk onde:
                             1=Retirar;2=Transferir;3=WO - para TS há a opção
                             4=Lançamento Indevido;5=Transferir e retirar
@Params		cPart     - Código do participante que está realizando a
                             transferência ou WO no Legal Desk
@Params		cCliLd     - Código do Cliente para onde será feita a transferência
@Params		cLojaLd    - Código da Loja para onde será feita a transferência
@Params		cCasoLd    - Código do Caso para onde será feita a transferência

@author Cristina Cintra
@since 05/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA202OPLD(cAliasTab, nRecno, cCodPreFt, cAcaoLD, cPart, cCliLd, cLojaLd, cCasoLd)
Local aArea      := GetArea()
Local aAreaNUE   := NUE->(GetArea())
Local aAreaNW0   := NW0->(GetArea())
Local aAreaNVY   := NVY->(GetArea())
Local aAreaNVZ   := NVZ->(GetArea())
Local aAreaNV4   := NV4->(GetArea())
Local aAreaNW4   := NW4->(GetArea())
Local aAreaNT1   := NT1->(GetArea())
Local aAreaNWE   := NWE->(GetArea())
Local cLanc      := ""
Local cAliasFat  := ""
Local cPartAlt   := ""
Local nOrder     := 1
Local lAltHr     := NUE->(ColumnPos('NUE_ALTHR')) > 0

Default cPart    := ""
Default cCliLd   := ""
Default cLojaLd  := ""
Default cCasoLd  := ""

If cAliasTab == "NUE"
	cAliasFat := "NW0"
	cPartAlt  := Iif(Empty((cAliasTab)->&(cAliasTab + "_PARTLD")), JurUsuario(__CUSERID), (cAliasTab)->&(cAliasTab + "_PARTLD"))
ElseIf cAliasTab == "NVY"
	cAliasFat := "NVZ"
ElseIf cAliasTab == "NV4"
	cAliasFat := "NW4"
	nOrder := 4
ElseIf cAliasTab == "NT1"
	cAliasFat := "NWE"
EndIf

If cAcaoLD == "1" // Retirar
	(cAliasTab)->(DbGoTo(nRecno))
	If cAliasTab != "NT1"
		cLanc := (cAliasTab)->&(cAliasTab + "_COD")
	Else
		cLanc := (cAliasTab)->&(cAliasTab + "_SEQUEN")
	EndIf
	RecLock(cAliasTab,.F.)
	(cAliasTab)->&(cAliasTab + "_CPREFT") := ""
	(cAliasTab)->&(cAliasTab + "_ACAOLD") := ""

	If cAliasTab != "NT1"
		(cAliasTab)->&(cAliasTab + "_PARTLD") := ""
	EndIf

	If cAliasTab == "NUE"
		(cAliasTab)->&(cAliasTab + "_VALOR1") := 0
		NUE->NUE_CUSERA := cPartAlt
		NUE->NUE_ALTDT  := Date()
		If lAltHr
			NUE->NUE_ALTHR := Time()
		EndIf
	EndIf

	(cAliasTab)->(MsUnLock())
	(cAliasTab)->(DbCommit())

	(cAliasFat)->(DbSetOrder(nOrder))
	If (cAliasFat)->( dbseek( xFilial(cAliasFat) + cLanc + '1' + cCodPreFt) )
		RecLock(cAliasFat, .F.)
		(cAliasFat)->&(cAliasFat + "_CANC") := "1"
		(cAliasFat)->(MsUnLock())
		(cAliasFat)->(DbCommit())
	EndIf

ElseIf cAcaoLD $ "2|5" // Transferir ou Transferir e retirar
	(cAliasTab)->(DbGoTo(nRecno))
	RecLock(cAliasTab, .F.)
	(cAliasTab)->&(cAliasTab + "_ACAOLD") := ""
	(cAliasTab)->&(cAliasTab + "_CCLILD") := ""
	(cAliasTab)->&(cAliasTab + "_CLJLD")  := ""
	(cAliasTab)->&(cAliasTab + "_CCSLD")  := ""
	(cAliasTab)->&(cAliasTab + "_PARTLD") := ""
	If cAliasTab == "NUE"
		NUE->NUE_CUSERA := cPartAlt
		NUE->NUE_ALTDT  := Date()
		If lAltHr
			NUE->NUE_ALTHR := Time()
		EndIf
	EndIf
	(cAliasTab)->(MsUnLock())
	(cAliasTab)->(DbCommit())

ElseIf cAcaoLD == "3" // WO
	(cAliasTab)->(DbGoTo(nRecno))
	RecLock(cAliasTab, .F.)
	(cAliasTab)->&(cAliasTab + "_ACAOLD") := ""
	(cAliasTab)->&(cAliasTab + "_PARTLD") := ""
	(cAliasTab)->&(cAliasTab + "_CMOTWO") := ""
	(cAliasTab)->&(cAliasTab + "_OBSWO")  := " "
	If cAliasTab == "NUE"
		NUE->NUE_CUSERA := cPartAlt
		NUE->NUE_ALTDT  := Date()
		If lAltHr
			NUE->NUE_ALTHR := Time()
		EndIf
	EndIf
	(cAliasTab)->(MsUnLock())
	(cAliasTab)->(DbCommit())
EndIf

RestArea(aAreaNWE)
RestArea(aAreaNT1)
RestArea(aAreaNW4)
RestArea(aAreaNV4)
RestArea(aAreaNVZ)
RestArea(aAreaNVY)
RestArea(aAreaNW0)
RestArea(aAreaNUE)
RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202PSinc
Exibe relação de pré-faturas que ainda não foram sincronizadas com o Legal
Desk a partir da verificação da situação do registro na fila de
sincronização (NYS).

@author Cristina Cintra
@since 25/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202PSinc()
Local nI         := 0
Local cTrab      := GetNextAlias()
Local cQuery     := ""
Local aCampos    := {}
Local aStru      := {}
Local aAux       := {}
Local aFields    := {}
Local oBrw       := Nil
Local oDlg       := Nil
Local oTela      := Nil
Local oPnlBrw    := Nil
Local oPnlRoda   := Nil
Local lObfuscate := FindFunction("FwPDCanUse") .And. FwPDCanUse(.T.) // Indica se trabalha com Dados Protegidos e possui a melhoria de ofuscação de dados habilitada
Local aColumns   := {}

	cQuery := " SELECT NX0.NX0_COD, NYS.NYS_TSTAMP, NYS.NYS_CODIGO "
	cQuery += " FROM " + RetSqlName('NX0') + " NX0, "
	cQuery +=            RetSqlName('NYS') + " NYS "
	cQuery += "  WHERE NX0.NX0_FILIAL = '" + xFilial("NX0") + "' "
	cQuery +=    " AND NYS.NYS_FILIAL = '" + xFilial("NYS") + "' "
	cQuery +=    " AND NYS.NYS_MODELO = 'JURA202' "
	cQuery +=    " AND NX0.NX0_SITUAC = 'C' "
	cQuery +=    " AND (NX0.NX0_FILIAL||NX0.NX0_COD) IN (NYS.NYS_CHAVE) "
	cQuery +=    " AND NX0.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NYS.D_E_L_E_T_ = ' ' "

	Define MsDialog oDlg FROM 0, 0 To 400, 600 Title STR0279 Pixel /*style DS_MODALFRAME*/ //"Pré-faturas não sincronizadas"

	oTela     := FWFormContainer():New(oDlg)
	cIdBrowse := oTela:CreateHorizontalBox(84)
	cIdRodape := oTela:CreateHorizontalBox(16)
	oTela:Activate( oDlg, .F. )
	oPnlBrw   := oTela:GeTPanel( cIdBrowse )
	oPnlRoda  := oTela:GeTPanel( cIdRodape )

	Define FWBrowse oBrw DATA QUERY ALIAS cTrab QUERY cQuery NO LOCATE Of oPnlBrw

	aStru := ( cTrab )->( dbStruct())
	For nI := 1 To Len(aStru)

		aAux    := {}
		aAdd( aAux, aStru[nI][1] )
		If AvSX3( aStru[nI][1],, cTrab, .T. )
			aAdd( aAux, RetTitle( aStru[nI][1] ) )
			aAdd( aAux, AvSX3( aStru[nI][1], 6, cTrab ) )
		Else
			aAdd( aAux, aStru[nI][1] )
			aAdd( aAux, '' )
		EndIf
		aAdd( aCampos, aAux )

		aAux := AvSX3( aStru[nI][1] )
		aAdd( aFields, {aStru[nI][1], ; // X3_CAMPO
		                RetTitle(aStru[nI][1]), ; // X3_TITULO
		                aAux[2], ; // X3_TIPO
		                aAux[3], ; // X3_TAMANHO
		                aAux[4], ; // X3_DECIMAL
		                aAux[7]  ; // X3_PICTURE
		                } )

	Next

	For nI := 1 To Len( aCampos )
		AAdd( aColumns, FWBrwColumn():New() )
		aColumns[nI]:SetData(&( '{ || ' + aCampos[nI][1] + ' }' ))
		aColumns[nI]:SetTitle( aCampos[nI][2] )
		aColumns[nI]:SetPicture( aCampos[nI][3] )
		If lObfuscate
			aColumns[nI]:SetObfuscateCol( Empty(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {aCampos[nI][1]})) )
		EndIf
	Next

	oBrw:SetFieldFilter(aFields)
	oBrw:SetUseFilter(1)
	oBrw:SetColumns(aColumns)

	Activate FWBrowse oBrw

	Activate MsDialog oDlg Centered

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202PdRev
Verifica se ha casos pendentes de Revisao na pre-fatura (NX1_SITREV <> '1').
Integracao com tela de Revisao do Legal Desk.

@param cCodPre   , Codigo da pre-fatura que se deseja verificar se possui
                   casos pendentes de Revisão.
@param cQryPdRev , Variavel a ser utilizada para montar a query
@param cAlsPdRev , Alias a ser utilizado pela query
@param lBindParam, Indica se a função MPSysOpenQuery faz o bind de queries

@author Cristina Cintra
@since  17/08/2016
/*/
//-------------------------------------------------------------------
Static Function JA202PdRev(cCodPre, cQryPdRev, cAlsPdRev, lBindParam)
Local aArea  := GetArea()
Local lRet   := .F.
Local cQuery := ""

	If Empty(cAlsPdRev)
		cAlsPdRev := GetNextAlias()
		cQryPdRev := " SELECT NX1.R_E_C_N_O_ RECNO "
		cQryPdRev +=   " FROM " + RetSqlName("NX1") + " NX1 "
		cQryPdRev +=  " WHERE NX1.NX1_FILIAL = '" + xFilial("NX1") + "' "
		cQryPdRev +=    " AND NX1.D_E_L_E_T_ = ' ' "
		cQryPdRev +=    " AND NX1.NX1_CPREFT = ? "
		cQryPdRev +=    " AND (NX1.NX1_SITREV = '2' OR NX1.NX1_SITREV = '3') "
	EndIf

	// Quando lBindParam é .F. indica que na lib atual a função MPSysOpenQuery não faz a substituição dos "?" na query.
	// Por isso executamos a função J202QryBind, para fazer essa substuição
	cQuery := IIf(lBindParam, cQryPdRev, J202QryBind(cQryPdRev, {cCodPre}))

	MPSysOpenQuery(cQuery, cAlsPdRev,,, {cCodPre})

	lRet := !(cAlsPdRev)->(Eof())

	(cAlsPdRev)->(DbCloseArea())
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202DPART
Função chamada no Inicializador Padrão dos campos de Sigla e Descrição
dos Participantes do Time Sheet.
Para chamadas a partir da pré-fatura, grava e procura num array

@Param		Tipo   1 = Sigla / RD0_SIGLA e 2 = Descrição - Nome / RD0_NOME
			Cód Participante

@author Cristina Cintra
@since 10/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202DPART(cTipo, cCodPart)
Local cRet       := ""
Local cSigAux    := ""
Local cNomAux    := ""
Local nPos       := 0

Default cTipo    := ""
Default cCodPart := ""

If !Empty(cTipo) .And. !Empty(cCodPart)
	If IsJura202()
		If Len(aParticip) > 0 .And. ( ( nPos := aScan( aParticip, { |aX| aX[1] == cCodPart } ) ) > 0 )
			If cTipo == "1"
				cRet := aParticip[nPos][2]
			Else
				cRet := aParticip[nPos][3]
			EndIf
		Else

			RD0->(DbSetOrder(1)) //RD0_FILIAL + RD0_CODIGO
			If RD0->(DbSeek(xFilial('RD0') + cCodPart))
				cSigAux := RD0->RD0_SIGLA
				cNomAux := RD0->RD0_NOME
				aAdd(aParticip, {cCodPart, cSigAux, cNomAux})
			EndIf

			If cTipo == "1"
				cRet := cSigAux
			Else
				cRet := cNomAux
			EndIf
		EndIf
	Else
		If cTipo == "1"
			cRet := Posicione('RD0', 1, xFilial('RD0') + cCodPart, 'RD0_SIGLA')
		Else
			cRet := Posicione('RD0', 1, xFilial('RD0') + cCodPart, 'RD0_NOME')
		EndIf
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202DMOED
Função chamada no Inicializador Padrão dos campos simbolo da moeda
chamados a partir da pré-fatura, grava e procura num array
Melhoria de Performace na pré-fatura.

@Param  cMoeda Codigo da Moeda

@author Luciano pereira dos Santos
@since 13/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202DMOED(cMoeda)
Local cRet   := ""

If !Empty(cMoeda)
	If IsJura202()
		If Len(aMoeda) > 0 .And. ( ( nPos := aScan( aMoeda, { |aX| aX[1] == cMoeda } ) ) > 0 )
			cRet := aMoeda[nPos][2]
		Else
			cRet := Posicione('CTO', 1, xFilial('CTO') + cMoeda, 'CTO_SIMB')
			aAdd(aMoeda, {cMoeda, cRet})
		EndIf
	Else
		cRet := Posicione('CTO', 1, xFilial('CTO') + cMoeda, 'CTO_SIMB')
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202ATIVID()
Carrega os campo NRC_COD,NRC_PART,NRC_TEMPOZ da tabela NRC para a static aAtivid
Melhoria de performace para o ajuste por periodo.

@author Luciano Pereira dos Santos
@since 07/01/17
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202ATIVID(cTipo, cCodAtiv)
Local cRet       := ""
Local cPartic    := ""
Local cTempoZ    := ""
Local nPos       := 0

Default cTipo    := ""
Default cCodAtiv := ""

If !Empty(cTipo) .And. !Empty(cCodAtiv)
	If Len(aAtivid) > 0 .And. ( ( nPos := aScan(aAtivid, {|aX| aX[1] == cCodAtiv}) ) > 0 )
		If cTipo == "1" //Participação do cliente
			cRet := aAtivid[nPos][2]
		ElseIf cTipo == "2" // Atividade Cobravel
			cRet := aAtivid[nPos][3]
		EndIf
	Else
		NRC->(DbSetOrder(1)) //NRC_FILIAL + NRC_COD
		If NRC->(DbSeek(xFilial("NRC") + cCodAtiv ))
			cPartic := NRC->NRC_PART
			cTempoZ := NRC->NRC_TEMPOZ
			aAdd(aAtivid, {cCodAtiv, cPartic, cTempoZ})
		EndIf

		If cTipo == "1"
			cRet := cPartic
		ElseIf cTipo == "2"
			cRet := cTempoZ
		EndIf
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202CodEbi(cFase, cDoc)
Rotina para carrega os campo NRY_COD e NRY_DESC em cache da tabela NRY para a static aFaseEbi
Melhoria de performace para o ajuste por periodo.

@Param  cTipo     Se '1' retorna o codigo e-billing da fase, se '2' retorna a descrição
@Param  cFase     Codigo da fase
@Param  cDoc      Codigo do documento e-biling
@Param  aFaseEbi  Array estatico com [cFase, cDoc, NRY_COD, NRY_DESC]

@Return  cRet    Retorna o codigo e-billing da fase ou a descrição conforme cTipo

@Obs Rotina chamada pela JA144DESFA()

@author Luciano Pereira dos Santos
@since 01/02/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J202FaseEb(cTipo, cFase, cDoc)
Local cRet       := ""
Local cCodEbi    := ""
Local cDecFase   := ""
Local nPos       := 0

Default cTipo    := ""
Default cFase    := ""
Default cDoc     := ""

If !Empty(cTipo) .And. !Empty(cFase) .And. !Empty(cDoc)
	If Len(aFaseEbi) > 0 .And. ( ( nPos := aScan(aFaseEbi, {|aX| aX[1] == cFase .And. aX[2] == cDoc}) ) > 0 )
		If cTipo == "1" //codigo fase e-billing
			cRet := aFaseEbi[nPos][3]
		ElseIf cTipo == "2" // descrição fase e-billing
			cRet := aFaseEbi[nPos][4]
		EndIf
	Else
		NRY->(DbSetOrder(5)) //NRY_FILIAL + NRY_CFASE + NRY_CDOC
		If NRY->(DbSeek(xFilial("NRY") + cFase + cDoc))
			cCodEbi  := NRY->NRY_COD
			cDecFase := NRY->NRY_DESC
			aAdd(aFaseEbi, {cFase, cDoc, cCodEbi, cDecFase})
		EndIf

		cRet := Iif(cTipo == "1", cCodEbi, cDecFase)

	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202Memo
Função para criação e atualização do campo Memo NX1_INSREV em uma
divisão da aba de Casos.

@author Luciano Pereira dos Santos
@since 29/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202Memo(oPainel, oView)
Local lRet      := .T.
Local oModel    := FwModelActive()
Local oModelNX1 := oModel:GetModel("NX1DETAIL")
Local nHeight   := 0
Local nWidth    := 0

cMemo := oModelNX1:GetValue('NX1_INSREV')

If oMemo == Nil
	If oPainel != Nil
		nHeight := oPainel:nClientHeight - 30
		nWidth  := oPainel:nClientWidth - 20

		oMemo := TMultiGet():Create( oPainel, {|u| If( pCount()>0, cMemo := u, cMemo)}, 0, 0, 0, 0, /*oFont*/, /*8*/, /*9*/, /*10*/, /*11*/,;
										/*lPixel*/ .T., /*13*/, /*14*/, /*bWhen*/, /*16*/, /*17*/, /*lReadOnly*/ .T., /*bValid*/, /*20*/, /*21*/,;
										/*lNoBorder*/ .F., /*lVScroll*/, /*cLabelText*/ RetTitle('NX1_INSREV'), 1 /*nLabelPos*/, /*oLabelFont*/, /*RGB(020,070,110)*/ /*nLabelColor*/ )

		oMemo:nTop      := 10  //Seta as propriedades de tamanho no proprio componete conforme o tamanho o painel do Order Objects
		oMemo:nLeft     := 10
		oMemo:nHeight   := nHeight
		oMemo:nWidth    := nWidth
		oMemo:lReadOnly := .T.
		oMemo:SetCss( "QTextEdit {color: BLACK; }" )

	EndIf
Else
	oMemo:Refresh()
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202UpLanc
Atualiza os lançamentos que originaram a despesa via Reclock com as depesas alteradas.

@Param  aTempFin => Array com as despesas alteradas {Tabela para replicar informação, Código para Seek ordem 1, Descrição, Cobrar}

@author bruno.ritter / ricardo.neves
@since 14/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202UpLanc(aTempFin)
Local nI        := 1
Local nQtDesp   := Len(aTempFin)
Local cCodNZQ   := ""
Local cCodOHB   := ""
Local cQuery    := ""
Local aRetDados := {}

If FWAliasInDic("OHB") .And. FWAliasInDic("OHF") .And. FWAliasInDic("OHG") .And. FWAliasInDic("NZQ") //Proteção
	OHB->(DbSetOrder(1)) // OHB_FILIAL+OHB_CODIGO
	OHF->(DbSetOrder(2)) // OHF_FILIAL+OHF_CDESP
	OHG->(DbSetOrder(2)) // OHG_FILIAL+OHG_CDESP
	NZQ->(DbSetOrder(1)) // NZQ_FILIAL + NZQ_COD
	For nI := 1 To nQtDesp
		cCodNZQ := ""
		cCodOHB := ""
		JurFreeArr(aRetDados)

		If aTempFin[nI][1] == "OHF" // Desdobramento
			If OHF->(DbSeek(xFilial("OHF") + aTempFin[nI][2]))
				RecLock("OHF", .F.)
				OHF->OHF_HISTOR := aTempFin[nI][3]
				OHF->OHF_COBRA  := aTempFin[nI][4]
				OHF->(MsUnlock())

				cCodNZQ := Iif(OHF->(ColumnPos("OHF_NZQCOD")) > 0, OHF->OHF_NZQCOD, "")
				cCodOHB := J202Lanc("OHF", OHF->OHF_IDDOC, OHF->OHF_CITEM)
			EndIf

		ElseIf aTempFin[nI][1] == "OHG" // Desdobramento Pós-Pagamento
			If OHG->(DbSeek(xFilial("OHG") + aTempFin[nI][2]))
				RecLock("OHG", .F.)
				OHG->OHG_HISTOR := aTempFin[nI][3]
				OHG->OHG_COBRA  := aTempFin[nI][4]
				OHG->(MsUnlock())

				cCodNZQ := Iif(OHG->(ColumnPos("OHG_NZQCOD")) > 0, OHG->OHG_NZQCOD, "")
				cCodOHB := J202Lanc("OHG", OHG->OHG_IDDOC, OHG->OHG_CITEM)
			EndIf
		EndIf

		// Atualiza Lançamento
		If aTempFin[nI][1] == "OHB" .Or. !Empty(cCodOHB)
			If OHB->(DbSeek(xFilial("OHB") + aTempFin[nI][2])) .Or. OHB->(DbSeek(xFilial("OHB") + cCodOHB))
				RecLock("OHB", .F.)
				OHB->OHB_HISTOR := aTempFin[nI][3]
				OHB->OHB_COBRAD := aTempFin[nI][4]
				OHB->(MsUnlock())

				If Empty(cCodNZQ)
					cQuery := " SELECT NZQ_COD FROM " + RetSqlName("NZQ") + " "
					cQuery += " WHERE NZQ_FILIAL = '" + xFilial("NZQ", OHB->OHB_FILIAL) + "' AND NZQ_CLANC= '" + OHB->OHB_CODIGO + "' AND D_E_L_E_T_ = ' '"
					aRetDados := JurSql(cQuery, "NZQ_COD")

					If !Empty(aRetDados) .And. Len(aRetDados) > 0 .And. !Empty(aRetDados[1]) .And. Len(aRetDados[1]) > 0
						cCodNZQ := aRetDados[1][1]
					EndIf
				EndIf
			EndIf
		EndIf

		If !Empty(cCodNZQ)
			If NZQ->(DbSeek(xFilial("NZQ") + cCodNZQ))
				RecLock("NZQ", .F.)
				NZQ->NZQ_DESC   := aTempFin[nI][3]
				NZQ->NZQ_COBRAR := aTempFin[nI][4]
				NZQ->(MsUnlock())
			EndIf
		EndIf
	Next nI
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J202Lanc
Busca lançamento vinculado ao desdobramento (OHF) ou desdobramento pós
pagamento (OHG)

@param   cAlias  , Tabela do desdobramento (OHF)/desdobramento-pós-pag (OHG)
@param   cIDDoc  , ID do título a pagar
@param   cItemDes, Item do desdobramento/desdobramento-pós-pag

@Return  cCodOHB, Código do lançamento

@author  Abner Fogaça
@since   07/05/2019
/*/
//-------------------------------------------------------------------
Static Function J202Lanc(cAlias, cIDDoc, cItemDes)
	Local cQuery    := ""
	Local cCodOHB   := ""
	Local aRetDados := {}

	cQuery := " SELECT OHB_CODIGO "
	cQuery += "   FROM " + RetSqlName(cAlias) + " " + cAlias + " "
	cQuery += "  INNER JOIN " + RetSqlName("FK7") + " FK7 "
	cQuery += "     ON FK7.FK7_FILIAL = '" + xFilial("FK7") + "' "
	cQuery += "    AND FK7_IDDOC = " + cAlias + "_IDDOC "
	cQuery += "    AND FK7.D_E_L_E_T_ = ' ' "
	cQuery += "  INNER JOIN " + RetSqlName("OHB") + " OHB "
	cQuery += "     ON OHB.OHB_FILIAL = '" + xFilial("OHB") + "' "
	cQuery += "    AND OHB.OHB_CPAGTO = FK7.FK7_CHAVE "
	cQuery += "    AND " + IIF(cAlias == "OHF", "OHB.OHB_ITDES", "OHB.OHB_ITDPGT") + " = '" + cItemDes + "' "
	cQuery += "    AND OHB.D_E_L_E_T_ = ' '
	cQuery += "  WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
	cQuery += "    AND " + cAlias + "_IDDOC = '" + cIDDoc + "' "
	cQuery += "    AND " + cAlias + ".D_E_L_E_T_ = ' '"
	
	aRetDados := JurSql(cQuery, "OHB_CODIGO")
	
	If !Empty(aRetDados) .And. Len(aRetDados) > 0 .And. !Empty(aRetDados[1]) .And. Len(aRetDados[1]) > 0
		cCodOHB := aRetDados[1][1]
	EndIf

Return (cCodOHB)

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA202W
Condicoes do Modo de edicao dos campos (X3_WHEN) dos campos de despesa
para executar o exact amount

@Return lRet

@author bruno.ritter
@since 09/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J202WhDesp(cCampo)
Local lRet      := .T.
Local oModel    := FwModelActive()
Local oModelNX0 := oModel:GetModel("NX0MASTER")
Local oModelNX1 := Nil
Local oModelNX8 := Nil
Local lJurxFin  := SuperGetMV("MV_JURXFIN",, .F.) // Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico

If lJurxFin .Or. oModelNX0:GetValue("NX0_ALTPER") != "2"
	lRet := .F.

Else
	Do Case
		Case cCampo == "NX0_VLFATD"
			lRet := oModelNX0:GetValue("NX0_DESP") == "1"

		Case cCampo == "NX8_VDESP"
			oModelNX8 := oModel:GetModel("NX8DETAIL")
			lRet := oModelNX8:GetValue("NX8_DESP") == "1"

		Case cCampo == "NX1_VDESP"
			oModelNX1 := oModel:GetModel("NX1DETAIL")
			lRet := oModelNX1:GetValue("NX1_DESP") == "1"

		OtherWise
			lRet := .T.
	EndCase
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202DspTrf()
Atualiza as informações de cliente, loja e caso do laçamento, desdobramento,
desdobramento pós-pagamento e aprovação de despesa (conforme cTabAtu)

@param cCodDesp , Código da despesa
@param cCodLanc , Código do lançamento vinculado na despesa (NVY_CLANC)
@param cCodPag  , Chave do contas a pagar vinculado na despesa (NVY_CPAGTO)
@param cGetClie , Código do cliente para atualizar
@param cGetLoja , Loja do cliente para atualizar
@param cGetCaso , Caso da despesa para atulizar
@param cCobrar  , Indica se o lançamento é cobrável
@param cDescri  , Descrição do lançamento
@param cTabAtu  , Tabela para ser atualizada

@author Abner Fogaça de Oliveira
@since 07/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202DspTrf(cCodDesp, cCodLanc, cCodPag, cGetClie, cGetLoja, cGetCaso, cCobrar, cDescri, cTabAtu)
	Local aArea      := GetArea()
	Local aAreaLanc  := (cTabAtu)->(GetArea())
	Local aAreaNZQ   := NZQ->(GetArea())
	Local cFilLanc   := J049FilOri(cCodPag, cCodDesp, cCodLanc)
	Local cCodNZQ    := ""
	Local cCodOHB    := ""
	Local cQuery     := ""
	Local aRetDados  := {}

	Default cCodLanc := ""
	Default cCodPag  := ""

	If cTabAtu == "OHF" // Desdobramento
		OHF->(DbSetOrder(2)) // OHF_FILIAL+OHF_CDESP
		If OHF->(DbSeek(cFilLanc + cCodDesp))
			RecLock("OHF", .F.)
			OHF->OHF_CCLIEN := cGetClie
			OHF->OHF_CLOJA  := cGetLoja
			OHF->OHF_CCASO  := cGetCaso
			OHF->OHF_COBRA  := cCobrar
			OHF->OHF_HISTOR := cDescri
			OHF->(MsUnlock())
			OHF->(DbCommit())

			cCodNZQ := Iif(OHF->(ColumnPos("OHF_NZQCOD")) > 0, OHF->OHF_NZQCOD, "")
			cCodOHB := J202Lanc("OHF", OHF->OHF_IDDOC, OHF->OHF_CITEM)
		EndIf

	ElseIf cTabAtu == "OHG" // Desdobramento Pós-Pagamento
		OHG->(DbSetOrder(2)) // OHG_FILIAL+OHG_CDESP
		If OHG->(DbSeek(cFilLanc + cCodDesp))
			RecLock("OHG", .F.)
			OHG->OHG_CCLIEN := cGetClie
			OHG->OHG_CLOJA  := cGetLoja
			OHG->OHG_CCASO  := cGetCaso
			OHG->OHG_COBRA  := cCobrar
			OHG->OHG_HISTOR := cDescri
			OHG->(MsUnlock())
			OHG->(DbCommit())

			cCodNZQ := Iif(OHG->(ColumnPos("OHG_NZQCOD")) > 0, OHG->OHG_NZQCOD, "")
			cCodOHB := J202Lanc("OHG", OHG->OHG_IDDOC, OHG->OHG_CITEM)
		EndIf
	EndIf

	// Atualiza Lançamento
	If cTabAtu == "OHB" .Or. !Empty(cCodOHB)
		OHB->(DbSetOrder(1)) // OHB_FILIAL+OHB_CODIGO
		If OHB->(DbSeek(cFilLanc + cCodLanc)) .Or. OHB->(DbSeek(xFilial("OHB") + cCodOHB))
			RecLock("OHB", .F.)
			OHB->OHB_CCASOD := cGetCaso
			OHB->OHB_CCLID  := cGetClie
			OHB->OHB_CLOJD  := cGetLoja
			OHB->OHB_COBRAD := cCobrar
			OHB->OHB_HISTOR := cDescri
			OHB->(MsUnlock())
			OHB->(DbCommit())

			cQuery := " SELECT NZQ_COD FROM " + RetSqlName("NZQ") + " "
			cQuery += " WHERE NZQ_FILIAL = '" + xFilial("NZQ", OHB->OHB_FILIAL) + "' AND NZQ_CLANC= '" + OHB->OHB_CODIGO + "' AND D_E_L_E_T_ = ' '"
			aRetDados := JurSql(cQuery, "NZQ_COD")
			If !Empty(aRetDados) .And. Len(aRetDados) > 0 .And. !Empty(aRetDados[1]) .And. Len(aRetDados[1]) > 0
				cCodNZQ := aRetDados[1][1]
			EndIf
		EndIf
	EndIf

	If !Empty(cCodNZQ)
		NZQ->(DbSetOrder(1)) // NZQ_FILIAL + NZQ_COD
		If NZQ->(DbSeek(xFilial("NZQ") + cCodNZQ))
			RecLock("NZQ", .F.)
			NZQ->NZQ_CCLIEN := cGetClie
			NZQ->NZQ_CLOJA  := cGetLoja
			NZQ->NZQ_CCASO  := cGetCaso
			NZQ->NZQ_COBRAR := cCobrar
			NZQ->NZQ_DESC   := cDescri
			NZQ->(MsUnlock())
		EndIf
	EndIf

	RestArea(aAreaNZQ)
	RestArea(aAreaLanc)
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc}  J202LoadVl
Função para executar o loadvalue e gerar log quando for REST

@Param  oSubModel    , objeto   , Modelo de dados que está sofrendo alteração
@Param  cField       , caracater, Nome do Campo
@Param  xValue       , caracater, Novo valor a ser setado
@Param  cID          , caracater, ID do submodelo que está sofrendo alteração

@Return lRet, lógico, Se o loadValue foi executado.

@author Jonatas Martins / Bruno Ritter
@since  26/02/2019
@Obs    Encapsulamento do LoadValue
/*/
//-------------------------------------------------------------------
Static Function J202LoadVl(oSubModel, cField, xValue, cID)
	Local nLine     := 0
	Local xOldValue := Nil
	Local lIsRest   := IIF(FindFunction("JurIsRest"), JurIsRest(), .F.)
	Local lRet      := .F.

	If oSubModel:GetID() == "JURA202"
		oSubModel := oSubModel:GetModel(cID)
	EndIf

	If oSubModel:ClassName() == "FWFORMGRID"
		nLine := oSubModel:GetLine()
	EndIf

	xOldValue := oSubModel:GetValue(cField)
	lRet := oSubModel:LoadValue(cField, xValue)

	If lIsRest
		J202RLog(oSubModel, oSubModel:GetID(), nLine, cField, xValue, xOldValue)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}  J202YesUpd
Faz backup da estrutura de dicionário original para executar as regras
de WHEN e MODEL_FIELD_NOUPD nos eventos de FieldPreVld e GridLinePreVld na 
excução via REST

@Param  oStructNX0, objeto, Estrutura de dicinário do cabeçalho da Pré-fatura
@Param  oStructNX1, objeto, Estrutura de dicinário dos casos da Pré-fatura
@Param  oStructNUE, objeto, Estrutura de dicinário dos TS da Pré-fatura
@Param  oStructNV4, objeto, Estrutura de dicinário dos tabelados da Pré-fatura
@Param  oStructNVY, objeto, Estrutura de dicinário das despesas da Pré-fatura
@Param  oStructNT1, objeto, Estrutura de dicinário das parcelas fixas da Pré-fatura

@author Jonatas Martins / Bruno Ritter
@since  26/02/2019
/*/
//-------------------------------------------------------------------
Static Function J202YesUpd(oStructNX0, oStructNX1, oStructNUE, oStructNV4, oStructNVY, oStructNT1)
Local bWhenTrue := FWBuildFeature(STRUCT_FEATURE_WHEN, ".T.")
	
	// Faz backup da estrutura original dos campos
	JurFreeArr(__aFieldsOrig)
	Aadd(__aFieldsOrig, {"NX0MASTER", aClone(oStructNX0:GetFields())})
	Aadd(__aFieldsOrig, {"NX1DETAIL", aClone(oStructNX1:GetFields())})
	Aadd(__aFieldsOrig, {"NUEDETAIL", aClone(oStructNUE:GetFields())})
	Aadd(__aFieldsOrig, {"NV4DETAIL", aClone(oStructNV4:GetFields())})
	Aadd(__aFieldsOrig, {"NVYDETAIL", aClone(oStructNVY:GetFields())})
	Aadd(__aFieldsOrig, {"NT1DETAIL", aClone(oStructNT1:GetFields())})
	
	// Libera alterações de todos os campos
	oStructNX0:SetProperty("*", MODEL_FIELD_WHEN, bWhenTrue)
	oStructNX0:SetProperty("*", MODEL_FIELD_NOUPD, .F.)
	oStructNX1:SetProperty("*", MODEL_FIELD_WHEN, bWhenTrue)
	oStructNX1:SetProperty("*", MODEL_FIELD_NOUPD, .F.)
	oStructNUE:SetProperty('*', MODEL_FIELD_WHEN, bWhenTrue)
	oStructNUE:SetProperty("*", MODEL_FIELD_NOUPD, .F.)
	oStructNVY:SetProperty('*', MODEL_FIELD_WHEN, bWhenTrue)
	oStructNVY:SetProperty("*", MODEL_FIELD_NOUPD, .F.)
	oStructNV4:SetProperty('*', MODEL_FIELD_WHEN, bWhenTrue)
	oStructNV4:SetProperty("*", MODEL_FIELD_NOUPD, .F.)
	oStructNT1:SetProperty('*', MODEL_FIELD_WHEN, bWhenTrue)
	oStructNT1:SetProperty("*", MODEL_FIELD_NOUPD, .F.)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc}  J202AVldPre
Função para executar WHEN dos campos quando setados via REST.

@Param  oSubModel    , objeto   , Modelo de dados que está sofrendo alteração
@Param  cModelID     , caracater, ID do submodelo que está sofrendo alteração
@Param  nLine        , numerico , Número da linha quando for um grid
@Param  cAction      , caracater, Ação do formulário: "SETVALUE"
@Param  cId          , caracater, Nome do Campo
@Param  xValue       , caracater, Novo valor a ser setado
@Param  xCurrentValue, caracater, Valor atual do campo

@Return lRet         , logico   , Retorna .T. se for permitido a alteração do campo

@author Jonatas Martins / Bruno Ritter
@since  26/02/2019
@Obs    Função executada somente via REST nos eventos: FieldPreVld e GridLinePreVld
/*/
//-------------------------------------------------------------------
Static Function J202AVldPre(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue)
	Local oModel  := oSubModel:GetModel()
	Local lGrid   := oSubModel:ClassName() == "FWFORMGRID"
	Local nPosID  := 0
	Local nPosFld := 0
	Local aFields := {}
	Local lNoUpd  := .F.
	Local bWhen   := Nil
	Local lRet    := .T.
	Local cTipo   := ""

	Default xCurrentValue := IIF(lGrid, "", oModel:GetValue(cModelID, cID))

	nPosID := aScan(__aFieldsOrig, {|x| x[1] == cModelID})
	If nPosID > 0
		If SubStr(cId, AT("_", cId), Len(cId)) == "_FILIAL"
			lRet := JurMsgErro(i18n(STR0316, {"WHEN", AllTrim(cID)})) // "Modo de edição do campo não respeitado. Verifique a propriedade: #1 do campo: #2"
		Else
			aFields := aClone(__aFieldsOrig[nPosID][2])
			nPosFld := aScan(aFields, {|x| x[MODEL_FIELD_IDFIELD] == cID})
			If nPosFld > 0
				lNoUpd  := aFields[nPosFld][MODEL_FIELD_NOUPD]
				bWhen   := aFields[nPosFld][MODEL_FIELD_WHEN]
				If lNoUpd .Or. (ValType(bWhen) == "B" .And. !Eval(bWhen, oSubModel, cId, xValue, xCurrentValue))
					cTipo := IIF(lNoUpd, "'MODEL_FIELD_NOUPD'", "'WHEN'")
					lRet  := JurMsgErro(i18n(STR0316, {cTipo, AllTrim(cID)})) // "Modo de edição do campo não respeitado. Verifique a propriedade: #1 do campo: #2"
				EndIf
			Else
				lRet := JurMsgErro( i18n(STR0315, {AllTrim(cID)})) // "Campo: #1 não encontrado na estrutura!"
			EndIf
		EndIf
	EndIf

	If !lRet
		 __cLogRest := ""
		 oModel:lModify := .T. // Alterado para no REST sempre fazer o VldData do modelo.
	Else
		J202RLog(oSubModel, cModelID, nLine, cId, xValue, xCurrentValue)
	EndIf

	JurFreeArr(aFields)

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc}  J202RLog
Função para montar log de alterações via REST.

@Param  oSubModel    , objeto   , Modelo de dados que está sofrendo alteração
@Param  cModelID     , caracater, ID do submodelo que está sofrendo alteração
@Param  nLine        , numerico , Número da linha quando for um grid
@Param  cAction      , caracater, Ação do formulário: "SETVALUE"
@Param  cId          , caracater, Nome do Campo
@Param  xValue       , caracater, Novo valor a ser setado
@Param  xCurrentValue, caracater, Valor atual do campo

@author Jonatas Martins / Bruno Ritter
@since  26/02/2019
@obs    Variável estática __cLogRest
/*/
//---------------------------------------------------------------------------
Static Function J202RLog(oSubModel, cModelID, nLine, cId, xValue, xCurrentValue)
	Local oModel    := oSubModel:GetModel()
	Local lGrid     := oSubModel:ClassName() == "FWFORMGRID"
	Local cOldValue := AllTrim(IIF(ValType(xCurrentValue) == "C", xCurrentValue, cValToChar(xCurrentValue)))
	Local cNewValue := AllTrim(IIF(ValType(xValue) == "C", xValue, cValToChar(xValue)))

	If !(cOldValue == cNewValue)
		If Empty(__cLogRest)
			__cLogRest += STR0308 + cValToChar(date()) + " - " + cValToChar(Time()) + CRLF // "Log de alteração - "
		EndIf
		__cLogRest += i18n(STR0309, {ProcName(2), cValToChar(ProcLine(2))}) + CRLF // "Função de Origem: #1 - Linha: #2"
		__cLogRest += STR0310 + cModelID + CRLF // "Modelo: "
		__cLogRest += STR0311 + cID + CRLF // "Campo: "
		__cLogRest += STR0312 + cOldValue + CRLF // "Valor atual: "
		__cLogRest += STR0313 + cNewValue + CRLF // "Novo valor: "
		If lGrid
			__cLogRest += i18n(STR0314, {cValToChar(nLine), cValToChar(oModel:GetModel(cModelID):GetDataID())}) + CRLF // "Linha: #1 ID: #2"
		EndIf
		__cLogRest += Replicate("=", 10) + CRLF
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J202Savelog
Função para salvar log de alterações via REST em um arquivo texto.

@author Jonatas Martins / Bruno Ritter
@since  26/02/2019
@obs    Variável estática __cLogRest
/*/
//---------------------------------------------------------------------------
Static Function J202Savelog()
	Local cPath       := "\JURLOGREST\"
	Local cDate       := DtoS(Date())
	Local cTime       := StrTran(Time(), ":", "")
	Local cFileName   := ""
	Local nHandle     := -1
	Local lChangeCase := .F.
	Local lCreated    := .T.
	
	If ! ExistDir(cPath, Nil, lChangeCase)
		lCreated := MakeDir(cPath, Nil, lChangeCase) == 0
	EndIf

	If lCreated
		cFileName := "JURA202_" + NX0->NX0_COD + "_" + cDate + "_" + cTime + ".txt"
		nHandle   := FCreate(cPath + cFileName, Nil, Nil, lChangeCase)
		
		If nHandle == -1 // Erro ao criar arquivo
			JurLogMsg(i18N(STR0317, {cDate, cTime})) // "#1 - #2 - Falha ao criar o arquivo de log!"
		Else
			FWrite(nHandle, __cLogRest)
			FClose(nHandle)
		EndIf
	Else
		JurLogMsg(i18N(STR0318, {cDate, cTime})) // "#1 - #2 - Falha ao criar o dirétorio de log!"
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J202TmpVig
Monta Tabela Temporária com a Vigência dos contratos da pré-fatura.
Caso seja uma junção também considera os contratos que ainda não foram
vinculados na pré-fatura

@Param  cPreFat, Código da Pré-Fatura
@Param  cJuncao, Código da Junção

@return cTabTmpVig, Nome fisico da tabela temporária

@author Jorge Martins
@since  05/06/2019
/*/
//---------------------------------------------------------------------------
Static Function J202TmpVig(cPreFat, cJuncao)
Local aTabTemp   := {}
Local oTmpVig    := Nil
Local cQuery     := ""
Local cTabTmpVig := ""
Local lVigCtr    := NT0->(ColumnPos("NT0_DTVIGI")) > 0
Local cCposNT0   := IIf(lVigCtr, ", NT0.NT0_DTVIGI NX8_DTVIGI, NT0.NT0_DTVIGF NX8_DTVIGF", "")
Local cCposNX8   := IIf(lVigCtr, ", NX8.NX8_DTVIGI NX8_DTVIGI, NX8.NX8_DTVIGF NX8_DTVIGF", "")
Local cIndex     := "NX8_FILIAL+NX8_CCONTR" + IIF(lVigCtr, "+NX8_DTVIGI+NX8_DTVIGF", "")
Local nTamIndex  := TamSX3("NX8_FILIAL")[1] + TamSX3("NX8_CCONTR")[1] + IIF(lVigCtr, TamSX3("NX8_DTVIGI")[1] + TamSX3("NX8_DTVIGF")[1], 0)
Local aIdxAdic   := {}

Aadd(aIdxAdic, {"01", cIndex, nTamIndex})

cQuery := " SELECT DISTINCT QRY.* "
cQuery +=   " FROM ( "
cQuery +=          " SELECT NT0.NT0_FILIAL NX8_FILIAL, NT0.NT0_COD NX8_CCONTR, NT0.NT0_CTPHON NX8_CTPHON" + cCposNT0
cQuery +=            " FROM " + RetSqlName("NT0") + " NT0 "
cQuery +=           " INNER JOIN " + RetSqlName("NW3") + " NW3 "
cQuery +=              " ON NW3.NW3_FILIAL = '" + xFilial("NW3") + "' "
cQuery +=             " AND NW3.NW3_CJCONT = '" + cJuncao + "' "
cQuery +=             " AND NW3.NW3_CCONTR = NT0.NT0_COD "
cQuery +=             " AND NW3.D_E_L_E_T_ = ' ' "
cQuery +=           " WHERE NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
cQuery +=             " AND NT0.D_E_L_E_T_ = ' ' "
cQuery +=             " AND NOT EXISTS ( SELECT NX8.NX8_CCONTR "
cQuery +=                                " FROM " + RetSqlName("NX8") + " NX8 "
cQuery +=                               " WHERE NX8.NX8_FILIAL = '" + xFilial("NX8") + "' "
cQuery +=                                 " AND NX8.NX8_CPREFT = '" + cPreFat + "' "
cQuery +=                                 " AND NX8.NX8_CCONTR = NT0.NT0_COD "
cQuery +=                                 " AND NX8.D_E_L_E_T_ = ' ' "
cQuery +=                            " ) "
cQuery +=          " UNION "
cQuery +=          " SELECT NX8.NX8_FILIAL NX8_FILIAL, NX8.NX8_CCONTR NX8_CCONTR, NX8.NX8_CTPHON NX8_CTPHON " + cCposNX8
cQuery +=            " FROM " + RetSqlName("NX8") + " NX8 "
cQuery +=           " WHERE NX8.NX8_FILIAL = '" + xFilial("NX8") + "' "
cQuery +=             " AND NX8.NX8_CPREFT = '" + cPreFat + "' "
cQuery +=             " AND NX8.D_E_L_E_T_ = ' ' "
cQuery +=        " ) QRY "
cQuery += " ORDER BY NX8_CCONTR "

aTabTemp := JurCriaTmp(GetNextAlias(), cQuery, "NX8", aIdxAdic)

oTmpVig    := aTabTemp[1]
cTabTmpVig := oTmpVig:GetRealName()

Return cTabTmpVig

//-------------------------------------------------------------------
/*/{Protheus.doc} J202FilNUE
Monta Query que filtra Time Sheets que aparecerão na lista da opção NOVOS.
A função gera uma query que busca TSs de contratos por hora (considerando Misto e Mínimo).
Caso exista FIXO na pré é feita outra query e é feito um UNION para agrupar os resultados.

@param    cTabTmpLD   Tabela temporária para geração (usado para vínculo de lanctos na pré via LD)
                      Usada para substituir a tabela padrão de lançamento.
                      A query será realizada na tabela temporária caso tenha sido passada por parâmetro
@param    cTabTmpVig  Tabela temporária com a vigência dos contratos da pré-fatura
@param    cPreFat     Código da Pré-fatura
@param    cCodTS      Código do Time Sheet, caso deseje filtrar por um TS em específico
@param    dDIniTS     Data inicial de TS da pré
@param    dDFimTS     Data final de TS da pré
@param    lPreTSFxNc  Indica que é uma pré de TS de contrato fixo ou não cobrável

@return cQry - Query de Filtro de Time Sheets

@author  Jorge Martins / Jonatas Martins
@since   07/06/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J202FilNUE(cTabTmpLD, cTabTmpVig, cPreFat, cCodTS, dDIniTS, dDFimTS, lPreTSFxNc)
	Local cQry       := "" // Query Completa (Principal)
	Local cSelNUE    := "" // Select e JOIN (Em comum entre query de TS e Fixo)
	Local cQryTS     := "" // Relacionamentos (JOIN) espefícos de TS
	Local cQryFX     := "" // Relacionamentos (JOIN) espefícos de Fixo
	Local cWhereTS   := "" // Where específico para query de TS
	Local cWhereFx   := "" // Where específico para query de Fixo
	Local cCampos    := ""
	Local cCamposJL  := ""
	Local aCamposJL  := {}
	Local lAtivNaoC  := SuperGetMV("MV_JURTS4" ,, .F.) // Zera o tempo revisado de atividades nao cobraveis
	Local lUnion     := SuperGetMV("MV_JVINCTS",, .T.) .And. NX0->NX0_FIXO == '1' // Vinc TS em contrato Fixo / Verifica se a pré tem fixo
	Local lTSNCobra  := SuperGetMV("MV_JTSNCOB",, .F.) // Indica se vincula TimeSheet não cobrável na emissão
	Local aCpoRemove := {"NUE_ACAOLD", "NUE_CCLILD", "NUE_CLJLD", "NUE_CCSLD", "NUE_PARTLD", "NUE_CDWOLD", ;
	                     "NUE_CMOTWO", "NUE_CRETIF", "NUE_CDOC" , "NUE_CFASE", "NUE_CTAREB", "NUE_OK"}

	cCampos    := JurCmpSelc("NUE", aCpoRemove)


	Aadd(aCamposJL,{"ACY.ACY_DESCRI" , "NUE_DGRPCL" })
	Aadd(aCamposJL,{"SA1.A1_NOME"    , "NUE_DCLIEN" })
	Aadd(aCamposJL,{"RD01.RD0_SIGLA" , "NUE_SIGLA1" })
	Aadd(aCamposJL,{"RD01.RD0_NOME"  , "NUE_DPART1" })
	Aadd(aCamposJL,{"RD02.RD0_SIGLA" , "NUE_SIGLA2" })
	Aadd(aCamposJL,{"RD02.RD0_NOME"  , "NUE_DPART2" })
	Aadd(aCamposJL,{"RD03.RD0_SIGLA" , "NUE_SIGLAA" })
	Aadd(aCamposJL,{"RD03.RD0_NOME"  , "NUE_DUSERA" })
	Aadd(aCamposJL,{"CTO1.CTO_SIMB"  , "NUE_DMOEDA" })
	Aadd(aCamposJL,{"CTO2.CTO_SIMB"  , "NUE_DMOED1" })
	Aadd(aCamposJL,{"NVE.NVE_TITULO" , "NUE_DCASO"  })
	
	cCamposJL := JurCaseJL(aCamposJL)

	If Empty(cTabTmpLD)
		cTabNUE := RetSqlName( 'NUE' )
	Else
		cTabNUE := cTabTmpLD
	EndIf

	cSelNUE := "SELECT " + cCampos + cCamposJL + " '' NUE_OK"
	cSelNUE +=  " FROM " + cTabTmpVig + " TMP "
	// FILTRA CONTRATOS DA JUNÇÃO
	cSelNUE +=  " INNER JOIN " + RetSqlName("NUT") + " NUT " 
	cSelNUE +=         "  ON NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
	cSelNUE +=         " AND NUT.NUT_CCONTR = TMP.NX8_CCONTR "
	cSelNUE +=         " AND NUT.D_E_L_E_T_ = ' ' "
	// RELACIONA CABEÇALHO DOS CONTRATOS 
	cSelNUE +=  " INNER JOIN " + RetSqlName("NT0") + " NT0 "
	cSelNUE +=         "  ON NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
	cSelNUE +=         " AND NT0.NT0_COD    = NUT.NUT_CCONTR "
	cSelNUE +=         " AND NT0.NT0_ATIVO  = '1' "
	cSelNUE +=         " AND NT0.NT0_SIT    = '2' "
	cSelNUE +=         " AND NT0.NT0_ENCH   = '2' "
	cSelNUE +=         " AND NT0.D_E_L_E_T_ = ' ' "
	// FILTRA TSs VINCULADOS AO CLIENTE, LOJA E CASO DOS CONTRATOS
	cSelNUE +=  " INNER JOIN " + cTabNUE + " NUE "
	cSelNUE +=         "  ON NUE.NUE_FILIAL = '" + xFilial("NUE") + "' "
	cSelNUE +=         IIf(Empty(cCodTS), "", " AND NUE.NUE_COD = '" + cCodTS + "' ")
	cSelNUE +=         " AND NUE.NUE_CCLIEN = NUT.NUT_CCLIEN "
	cSelNUE +=         " AND NUE.NUE_CLOJA  = NUT.NUT_CLOJA "
	cSelNUE +=         " AND NUE.NUE_CCASO  = NUT.NUT_CCASO "
	cSelNUE +=         " AND NUE.NUE_CPREFT = '" + Space(TamSx3('NUE_CPREFT')[1]) + "' "
	cSelNUE +=         " AND NUE.NUE_SITUAC = '1' "
	If !lTSNCobra // Não vincula TimeSheet não cobrável
		cSelNUE +=         " AND NUE.NUE_COBRAR = '1' "
	EndIf
	cSelNUE +=         J202VigCtr("NUE.NUE_DATATS", dDIniTS, dDFimTS, cTabTmpVig) // FILTRA DATA DE VIGÊNCIA
	
	cSelNUE +=         " AND NUE.D_E_L_E_T_ = ' ' "
	// FILTRA ATIVIDADE COBRÝVEL DO TS
	cSelNUE +=  " INNER JOIN " + RetSqlName("NRC") + " NRC "
	cSelNUE +=          " ON NRC.NRC_FILIAL = '" + xFilial("NRC") + "' "
	cSelNUE +=         " AND NRC.NRC_COD = NUE.NUE_CATIVI "
	cSelNUE +=         IIf(!lAtivNaoC .And. !lTSNCobra, " AND NRC.NRC_TEMPOZ  = '1' ", "") // Traz os TSs não cobráveis quando MV_JURTS4 ou MV_JTSNCOB estiver ativado
	cSelNUE +=         " AND NRC.D_E_L_E_T_ = ' ' "
	// RELACIONA CASOS QUE NÃO ENCERRAM HONORÝRIOS
	cSelNUE +=  " INNER JOIN " + RetSqlName("NVE") + " NVE "
	cSelNUE +=         "  ON NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
	cSelNUE +=         " AND NVE.NVE_CCLIEN = NUE.NUE_CCLIEN "
	cSelNUE +=         " AND NVE.NVE_LCLIEN = NUE.NUE_CLOJA "
	cSelNUE +=         " AND NVE.NVE_NUMCAS = NUE.NUE_CCASO "
	cSelNUE +=         " AND NVE.NVE_ENCHON = '2' "
	cSelNUE +=         " AND NVE.D_E_L_E_T_ = ' ' "
	cSelNUE +=         " AND NVE.NVE_COBRAV = '1' "
	// RELACIONA CLIENTES E LOJAS DOS TS
	cSelNUE +=  " INNER JOIN " + RetSqlName("SA1") + " SA1 "
	cSelNUE +=         "  ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
	cSelNUE +=         " AND SA1.A1_COD  = NUE.NUE_CCLIEN "
	cSelNUE +=         " AND SA1.A1_LOJA = NUE.NUE_CLOJA "
	cSelNUE +=         " AND SA1.D_E_L_E_T_ = ' ' "
	// RELACIONA PARTICIPANTE TS
	cSelNUE +=  " INNER JOIN " + RetSqlName("RD0") + " RD01 "
	cSelNUE +=         "  ON RD01.RD0_FILIAL = '" + xFilial("RD0") + "' "
	cSelNUE +=         " AND RD01.RD0_CODIGO = NUE.NUE_CPART1 "
	cSelNUE +=         " AND RD01.D_E_L_E_T_ = ' ' "
	// RELACIONA SOCIO TS
	cSelNUE +=  " INNER JOIN " + RetSqlName("RD0") + " RD02 "
	cSelNUE +=         "  ON RD02.RD0_FILIAL = '" + xFilial("RD0") + "' "
	cSelNUE +=         " AND RD02.RD0_CODIGO = NUE.NUE_CPART2 "
	cSelNUE +=         " AND RD02.D_E_L_E_T_ = ' ' "
	// RELACIONA GRUPO DE CLIENTE
	cSelNUE +=   " LEFT JOIN " + RetSqlName("ACY") + " ACY "
	cSelNUE +=         "  ON ACY.ACY_FILIAL = '" + xFilial("ACY") + "' "
	cSelNUE +=         " AND ACY.ACY_GRPVEN = NUE.NUE_CGRPCL "
	cSelNUE +=         " AND ACY.D_E_L_E_T_ = ' ' "
	// RELACIONA USUARIO DE ALTERACAO
	cSelNUE +=   " LEFT JOIN " + RetSqlName("RD0") + " RD03 "
	cSelNUE +=         "  ON RD03.RD0_FILIAL = '" + xFilial("RD0") + "' "
	cSelNUE +=         " AND RD03.RD0_CODIGO = NUE.NUE_CUSERA "
	cSelNUE +=         " AND RD03.D_E_L_E_T_ = ' ' "
	// RELACIONA LANÇAMENTO TABELADO VINCULADO AO TS
	cSelNUE +=   " LEFT JOIN " + RetSqlName("NV4") + " NV4 "
	cSelNUE +=         "  ON NV4.NV4_FILIAL = '" + xFilial("NV4") + "' "
	cSelNUE +=         " AND NV4.NV4_COD = NUE.NUE_CLTAB "
	cSelNUE +=         " AND NV4.D_E_L_E_T_ = ' ' "
	// RELACIONA MOEDA DO TS
	cSelNUE +=   " LEFT JOIN " + RetSqlName("CTO") + " CTO1 "
	cSelNUE +=         "  ON CTO1.CTO_FILIAL = '" + xFilial("CTO") + "' "
	cSelNUE +=         " AND CTO1.CTO_MOEDA = NUE.NUE_CMOEDA "
	cSelNUE +=         " AND CTO1.D_E_L_E_T_ = ' ' "
	// RELACIONA MOEDA DA COTACAO
	cSelNUE +=   " LEFT JOIN " + RetSqlName("CTO") + " CTO2 "
	cSelNUE +=         "  ON CTO2.CTO_FILIAL = '" + xFilial("CTO") + "' "
	cSelNUE +=         " AND CTO2.CTO_MOEDA = NUE.NUE_CMOED1 "
	cSelNUE +=         " AND CTO2.D_E_L_E_T_ = ' ' "

	// Monta trecho de query específico para 
	cQryTS += cSelNUE
	// FILTRA TIPO DE HONORARIOS
	cQryTS +=   " INNER JOIN " + RetSqlName("NRA") + " NRA "
	cQryTS +=          "  ON NRA.NRA_FILIAL = '" + xFilial("NRA") + "' "
	cQryTS +=          " AND NRA.NRA_COD    = TMP.NX8_CTPHON "
	If lPreTSFxNc // Pré de TS de contrato fixo não cobrável
		cQryTS +=      " AND (NRA.NRA_NCOBRA = '1' OR (NRA.NRA_COBRAH = '2' AND NRA.NRA_COBRAF = '1')) "
	Else
		cQryTS +=      " AND NRA.NRA_COBRAH = '1' "
	EndIf
	cQryTS +=          " AND NRA.D_E_L_E_T_ = ' ' "
	// VERIFICA CAMPO DO TIPO DE HONORARIOS
	cQryTS +=   " INNER JOIN " + RetSqlName("NTH") + " NTH "
	cQryTS +=          "  ON NTH.NTH_FILIAL = '" + xFilial("NTH") + "' "
	cQryTS +=          " AND NTH.NTH_CTPHON = NRA.NRA_COD "
	cQryTS +=          " AND NTH.NTH_CAMPO = 'NT0_TPCEXC' "
	cQryTS +=          " AND NTH.D_E_L_E_T_ = ' ' "
	// VERIFICA PARCELAS DE FIXO
	cQryTS +=    " LEFT JOIN " + RetSqlName("NT1") + " NT1  "
	cQryTS +=          "  ON NT1.NT1_FILIAL = '" + xFilial("NT1") + "' "
	cQryTS +=          " AND NT1.NT1_CCONTR = NT0.NT0_COD "
	cQryTS +=          " AND NT1.NT1_DATAFI BETWEEN '" + DtoS(dDIniTS) + "' AND '" + DtoS(dDFimTS) + "' " // Não pode simplesmente pegar as parcelas da pré por conta do Misto
	cQryTS +=          " AND NT1.D_E_L_E_T_ = ' ' "

	cWhereTS +=  " WHERE ( CASE WHEN NTH.NTH_VISIV = '1' THEN "
	cWhereTS +=               " ( CASE WHEN NVE.NVE_SITUAC = '1' THEN " 
	cWhereTS +=                        " (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) " 
	cWhereTS +=                 " ELSE "
	cWhereTS +=                        " (CASE WHEN NVE.NVE_DTENCE >= NT1.NT1_DATAIN AND NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) "
	cWhereTS +=                 " END) "
	cWhereTS +=        " ELSE '1' END ) <> '2' "

	// Bloco para filtrar apenas TSs quando houverem casos passíveis de Faturamento - Misto e Mínimo
	cWhereTS +=    " AND ( NT0.NT0_TPCEXC = ' ' " // Só Hora ou Fixo e Hora (sem ser Misto ou Mínimo)
	cWhereTS +=        " OR ( ( ( NT0.NT0_FIXEXC = '1' AND NT1.NT1_CPREFT = '"  + cPreFat + "' ) OR  " // É Mínimo e o fixo está na mesma pré ou
	cWhereTS +=        " ( NT0.NT0_FIXEXC = '2' AND NT1.NT1_CPREFT <> '" + cPreFat + "' ) ) "   // É Misto - sem fixo na mesma pré
	cWhereTS +=        " AND NUE.NUE_DATATS BETWEEN '" + DtoS(dDIniTS) + "' AND '" + DtoS(dDFimTS) + "' " 
	cWhereTS +=             " ) "
	cWhereTS +=    " ) "
	If Empty(dDIniTS) .And. Empty(dDFimTS) // Não adiciona TS em pré de Hora/Fixo desde que não se tenha emitido a parte de Hora
		cWhereTS += " AND NOT EXISTS ( SELECT NT1.R_E_C_N_O_ "
		cWhereTS +=                    " FROM " + RetSqlName("NT1") + " NT1 "
		cWhereTS +=                   " WHERE NT1.NT1_FILIAL = '" + xFilial("NT1") + "' "
		cWhereTS +=                     " AND NT1.NT1_CCONTR = NT0.NT0_COD "
		cWhereTS +=                     " AND NT1.NT1_CPREFT = '" + cPreFat + "' "
		cWhereTS +=                     " AND NT1.D_E_L_E_T_ = ' ' ) "
	EndIf

	If !lTSNCobra // Considera timesheets com atividade não cobrável no contrato caso o parâmetro estiver habilitado.
		cWhereTS +=  " AND NOT EXISTS ( SELECT NTJ.R_E_C_N_O_ "   //Atividades cobravel no Contrato
		cWhereTS +=                     " FROM  " + RetSqlName("NTJ") + " NTJ  "
		cWhereTS +=                    " WHERE NTJ.NTJ_FILIAL = '" + xFilial("NTJ") +"' "
		cWhereTS +=                      " AND NTJ.NTJ_CCONTR = NUT.NUT_CCONTR "
		cWhereTS +=                      " AND NTJ.NTJ_CTPATV = NUE.NUE_CATIVI "
		cWhereTS +=                      " AND NTJ.D_E_L_E_T_ = ' ' ) "
	EndIf
	
	// Monta query completa (Junta Trecho específico de TS com o Where geral)
	cQry += cQryTS + cWhereTS

	// Criada esta query para fazer union com a query da NUE de forma que seja possível
	// vincular TSs em contrato fixo, respeitando as regras de vínculo neste caso, sem
	// afetar o funcionamento para Horas e abrangendo situações em que existe contratos
	// por hora e fixo na mesma pré-fatura.
	// Desta forma, haverá um select apenas para Horas considerando o período de TS da pré
	// e outra para Fixo, considerando as regras das parcelas vinculadas.
	If lUnion
		cQryFx += cSelNUE
		cQryFx +=   " INNER JOIN " + RetSqlName("NT1") + " NT1 "
		cQryFx +=          "  ON NT1.NT1_FILIAL = '" + xFilial("NT1") + "' "
		cQryFx +=          " AND NT1.NT1_CCONTR = NT0.NT0_COD "
		cQryFx +=          " AND NT1.NT1_CPREFT = '" + cPreFat + "' "
		cQryFx +=          " AND NUE.NUE_DATATS >= (CASE WHEN NT1.NT1_DATAIN < '" + DtoS(dDIniTS) + "' THEN '" + DtoS(dDIniTS) + "' ELSE NT1.NT1_DATAIN END)"
		cQryFx +=          " AND NUE.NUE_DATATS <= (CASE WHEN NT1.NT1_DATAFI > '" + DtoS(dDFimTS) + "' THEN '" + DtoS(dDFimTS) + "' ELSE NT1.NT1_DATAFI END)"
		cQryFx +=          " AND NT1.D_E_L_E_T_ = ' ' "
		cQryFx +=   " INNER JOIN " + RetSqlName("NRA") + " NRA "
		cQryFx +=          "  ON NRA.NRA_FILIAL = '" + xFilial("NRA") + "' "
		cQryFx +=          " AND NRA.NRA_COD    = NT0.NT0_CTPHON "
		cQryFx +=          " AND NRA.NRA_COBRAF = '1' "
		cQryFx +=          " AND NRA.NRA_COBRAH = '2' "
		cQryFx +=          " AND NRA.D_E_L_E_T_ = ' ' "
		cQryFx +=   " INNER JOIN " + RetSqlName("NTH") + " NTH "
		cQryFx +=           " ON NTH.NTH_FILIAL = '" + xFilial("NTH") + "' "
		cQryFx +=          " AND NTH.NTH_CTPHON = NT0.NT0_CTPHON "
		cQryFx +=          " AND NTH.NTH_CAMPO = 'NT0_FXABM' "
		cQryFx +=          " AND NTH.D_E_L_E_T_ = ' ' "

		// Se não for Faixa Qtdade de Casos
		cWhereFx += " WHERE (CASE WHEN NTH.NTH_VISIV = '2' THEN "
		cWhereFx +=         " (CASE WHEN NVE.NVE_SITUAC = '1' THEN (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) ELSE "
		cWhereFx +=            " (CASE WHEN NVE.NVE_DTENCE >= NT1.NT1_DATAIN AND NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) "
		cWhereFx +=         " END) "
		cWhereFx +=      " ELSE "
		// Se for Faixa - Qtdade de Casos - verifica o conteúdo dos campos NT0_FXABM e NT0_FXENCM além da situação do caso
		cWhereFx +=         " (CASE WHEN NTH.NTH_VISIV = '1' THEN "
		cWhereFx +=             " (CASE WHEN NVE.NVE_SITUAC = '1' THEN "
		cWhereFx +=                 " (CASE WHEN NT0.NT0_FXABM = '1' THEN "
		cWhereFx +=                     " (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) "
		cWhereFx +=                  " ELSE "
		cWhereFx +=                      " (CASE WHEN NVE.NVE_DTENTR < NT1.NT1_DATAIN THEN '1' ELSE '2' END) "
		cWhereFx +=                  " END) "
		cWhereFx +=              " ELSE "
		cWhereFx +=                 " (CASE WHEN NT0.NT0_FXABM = '1' THEN "
		cWhereFx +=                     " (CASE WHEN NT0.NT0_FXENCM = '1' THEN "
		cWhereFx +=                         " (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI AND NVE.NVE_DTENCE >= NT1.NT1_DATAIN THEN '1' ELSE '2' END) "
		cWhereFx +=                      " ELSE "
		cWhereFx +=                         " (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI AND NVE.NVE_DTENCE > NT1.NT1_DATAFI THEN '1' ELSE '2' END) "
		cWhereFx +=                      " END ) "
		cWhereFx +=                  " ELSE "
		cWhereFx +=                     " (CASE WHEN NT0.NT0_FXENCM = '1' THEN "
		cWhereFx +=                         " (CASE WHEN NVE.NVE_DTENTR < NT1.NT1_DATAIN AND NVE.NVE_DTENCE >= NT1.NT1_DATAIN THEN '1' ELSE '2' END) "
		cWhereFx +=                      " ELSE  "
		cWhereFx +=                         " (CASE WHEN NVE.NVE_DTENTR < NT1.NT1_DATAIN AND NVE.NVE_DTENCE > NT1.NT1_DATAFI THEN '1' ELSE '2' END) " 
		cWhereFx +=                      " END) "
		cWhereFx +=                  " END) "
		cWhereFx +=              " END) "
		cWhereFx +=          " END) "
		cWhereFx +=       " END) <> '2' "

		If !lTSNCobra // Considera timesheets com atividade não cobrável no contrato caso o parâmetro estiver habilitado.
			cWhereFx +=  " AND NOT EXISTS ( SELECT NTJ.R_E_C_N_O_ "   //Atividades cobravel no Contrato
			cWhereFx +=                     " FROM  " + RetSqlName("NTJ") + " NTJ  "
			cWhereFx +=                    " WHERE NTJ.NTJ_FILIAL = '" + xFilial("NTJ") +"' "
			cWhereFx +=                      " AND NTJ.NTJ_CCONTR = NUT.NUT_CCONTR "
			cWhereFx +=                      " AND NTJ.NTJ_CTPATV = NUE.NUE_CATIVI "
			cWhereFx +=                      " AND NTJ.D_E_L_E_T_ = ' ' ) "
		EndIf

		// Adiciona o Union e trecho de Fixo na query completa
		cQry += " UNION "
		cQry += cQryFx + cWhereFx // Ajusta query completa (Junta Trecho específico de Fixo com o Where geral)
	EndIf

	cQry := " SELECT DISTINCT QRY.* FROM ( " + cQry + " ) QRY "
	cQry += " ORDER BY NUE_COD"

Return cQry

//-------------------------------------------------------------------
/*/{Protheus.doc} J202NvAuto
Vinculo de lançamentos (TS, DP, LT) automático dentro da Pré-Fatura (Novos)
Função utilizada nos Casos de Testes (Automação)

@Param  cPreFat   - Código da Pré-Fatura
@Param  cTipoLanc - Tipo do Lançamento
                    TS -> Time Sheet
                    LT -> Lançamento Tabelado
                    DP -> Despesa

@Return lVincLan - Retorna .T. se vinculou os lançamentos com sucesso

@author  Jonatas Martins / Jorge Martins
@since   04/06/2019
@version 1.0
@Obs     Sempre irá vincular todos os lançamentos pendentes relacionados
         aos casos que estão na Pré-Fatura
/*/
//-------------------------------------------------------------------
Function J202NvAuto(cPreFat, cTipoLanc)
	Local oModel    := Nil
	Local lVincLan  := .F.
	Local lAutomato := .T.
	
	NX0->(DbSetOrder(1))
	If NX0->(dbSeek(xFilial("NX0") + cPreFat))
		oModel := FWLoadModel("JURA202")
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()
		If cTipoLanc == "TS"
			lVincLan := JURA202B(lAutomato)
		ElseIf cTipoLanc == "DP"
			lVincLan := JURA202C(lAutomato)
		ElseIf cTipoLanc == "LT"
			lVincLan := JURA202D(lAutomato)
		EndIf
		JA202REFAZ(cPreFat, .F., "", "", lAutomato) // Refaz Pré-Fatura
		oModel:DeActivate()
	Else
		JurMsgErro(STR0011) // "Falha ao carregar a Pré-Fatura"
	EndIf

Return (lVincLan)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202DeAct
Função de desativação do modelo de Pré-fatura.

@Param  oModel  Modelo da JURA202

@Return Nil

@author  Josimar / Cristina Cintra
@since   15/08/2019
/*/
//-------------------------------------------------------------------
Static Function JA202DeAct( oModel )
	Local nPosCargo := 0
	Local nSize     := 0

	If ValType(oModel:Cargo) == "A"
		nPosCargo := aScan(oModel:Cargo, {|x| x[1] == "JUR-NX0-TOUNLOCK" })
		If nPosCargo > 0
			NX0->(DbGoTo( oModel:Cargo[nPosCargo][2] ))
			NX0->(MsUnlock())

			nSize := Len(oModel:Cargo)
			aDel(oModel:Cargo, nPosCargo)
			aSize(oModel:Cargo, nSize - 1)
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J202SCorte
Seta valores das seguintes variáveis estáticas usadas no corte:
__nQtdNX1, __nQtdNUE, __nQtdNVY, __nCountNX1, __nCountNUE, __nCountNVY

@param oModel  , Modelo de dados ativo
@param cTab    , Tabela do lançamento - NUE -> Time Sheet / NVY -> Despesas
@param cPreFat , Código da pré-fatura para busca dos lançamentos
@param cContr  , Código da contrato para busca dos lançamentos
@param cCliente, Código da cliente para busca dos lançamentos
@param cLoja   , Loja/Endereço do cliente para busca dos lançamentos
@param cCaso   , Número do caso para busca dos lançamentos

@author  Jorge Martins
@since   26/09/2019
/*/
//-------------------------------------------------------------------
Static Function J202SCorte(oModel, cTab, cPreFat, cContr, cCliente, cLoja, cCaso)
	Local oModelNX1   := Nil
	Local nQtdLanc    := 0
	Local nNX1        := 0
	
	Default cTab      := ""
	Default cPreFat   := ""
	Default cContr    := ""
	Default cCliente  := ""
	Default cLoja     := ""
	Default cCaso     := ""
	Default cPart     := ""

	__nCountNUE       := 1
	__nCountNVY       := 1
	__nCountNX1       := 1
	__nQtdNUE         := 0
	__nQtdNVY         := 0
	__nQtdNX1         := IIf(Empty(cCaso), J202QtdNX1(cPreFat, cContr), 1)
	
	If !Empty(cContr) .And. Empty(cCaso) // Busca os lançamentos de todos os casos do contrato indicado

		oModelNX1 := oModel:GetModel("NX1DETAIL")

		For nNX1 := 1 To oModelNX1:Length()
			If oModelNX1:GetValue("NX1_CCONTR", nNX1) == cContr
				cCliente  := oModelNX1:GetValue("NX1_CCLIEN", nNX1)
				cLoja     := oModelNX1:GetValue("NX1_CLOJA" , nNX1)
				cCaso     := oModelNX1:GetValue("NX1_CCASO" , nNX1)
				
				nQtdLanc += J202QtdLan(cTab, cPreFat, oModelNX1:GetValue("NX1_CCLIEN", nNX1),;
				                                      oModelNX1:GetValue("NX1_CLOJA" , nNX1),;
				                                      oModelNX1:GetValue("NX1_CCASO" , nNX1))
			EndIf
		Next
	Else
		nQtdLanc := J202QtdLan(cTab, cPreFat, cCliente, cLoja, cCaso)
	EndIf

	If cTab == "NUE"
		__nQtdNUE := nQtdLanc
	ElseIf cTab == "NVY"
		__nQtdNVY := nQtdLanc
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J202QtdNX1
Indica a quantidade de casos na pré-fatura.

@param cPreFat , Código da pré-fatura para busca dos lançamentos
@param cContr  , Código da contrato para busca dos lançamentos

@return nQtdNX1, Quantidade de casos na pré-fatura

@author  Jorge Martins
@since   23/09/2019
/*/
//-------------------------------------------------------------------
Static Function J202QtdNX1(cPreFat, cContr)
	Local cQueryNX1  := ""
	Local nQtdNX1    := 0

	Default cContr   := ""
	Default cCliente := ""
	Default cLoja    := ""
	Default cCaso    := ""

	// Contador de Casos da pré-fatura
	cQueryNX1 :=   " SELECT COUNT(NX1.R_E_C_N_O_) NCOUNT FROM " + RetSqlName("NX1") + " NX1 "
	cQueryNX1 +=    " WHERE NX1.NX1_FILIAL = '" + xFilial("NX1") + "' "
	cQueryNX1 +=      " AND NX1.NX1_CPREFT = '" + cPreFat + "' "
	cQueryNX1 +=      " AND NX1.D_E_L_E_T_ = ' ' "
	If !Empty(cContr)
		cQueryNX1 +=  " AND NX1.NX1_CCONTR = '" + cContr + "' "
	EndIf

	nQtdNX1 := JurSQL(cQueryNX1, "NCOUNT")[1][1]

Return nQtdNX1

//-------------------------------------------------------------------
/*/{Protheus.doc} J202QtdLan
Indica a quantidade de Lançamentos (Time Sheets ou Despesas) na pré-fatura

@param cTab    , Tabela do lançamento - NUE -> Time Sheet / NVY -> Despesas
@param cPreFat , Código da pré-fatura para busca dos lançamentos
@param cCliente, Código da cliente para busca dos lançamentos
@param cLoja   , Loja/Endereço do cliente para busca dos lançamentos
@param cCaso   , Número do caso para busca dos lançamentos

@return nQtd, Quantidade de Lançamentos na pré-fatura

@author  Jorge Martins
@since   23/09/2019
/*/
//-------------------------------------------------------------------
Static Function J202QtdLan(cTab, cPreFat, cCliente, cLoja, cCaso)
	Local cQuery     := ""
	Local nQtd       := 0

	Default cCliente := ""
	Default cLoja    := ""
	Default cCaso    := ""

	cQuery :=   " SELECT COUNT(R_E_C_N_O_) NCOUNT FROM " + RetSqlName(cTab) + " "
	cQuery +=    " WHERE " + cTab + "_FILIAL = '" + xFilial(cTab) + "' "
	cQuery +=      " AND " + cTab + "_CPREFT = '" + cPreFat + "' "
	cQuery +=      " AND " + cTab + "_SITUAC = '1' "
	If !Empty(cCliente) .And. !Empty(cLoja) .And. !Empty(cCaso)
		cQuery +=  " AND " + cTab + "_CCLIEN = '" + cCliente + "' "
		cQuery +=  " AND " + cTab + "_CLOJA  = '" + cLoja    + "' "
		cQuery +=  " AND " + cTab + "_CCASO  = '" + cCaso    + "' "
	EndIf
	cQuery +=      " AND D_E_L_E_T_ = ' ' "

	nQtd := JurSQL(cQuery, "NCOUNT")[1][1]

Return nQtd

//-------------------------------------------------------------------
/*/{Protheus.doc} J202VldCot
Valida cotações da pré-fatura e indica se pode ou não ter sua 
situação alterada.

@param cMoeNac   , Moeda Nacional
@param cTipoConv , Tipo de cotação utilizada nas conversões 
                   '1' = Diária / '2' = Mensal
@param cQryVldCot, Variavel a ser utilizada para montar a query
@param cAlsVldCot, Alias a ser utilizado pela query
@param lBindParam, Indica se a função MPSysOpenQuery faz o bind de queries

@return lRet     , Indica se pode alterar a situação da pré.

@author  Jorge Martins
@since   17/12/2019
/*/
//-------------------------------------------------------------------
Static Function J202VldCot(cMoeNac, cTipoConv, cQryVldCot, cAlsVldCot, lBindParam)
Local lRet      := .T.
Local nCotac    := 0
Local cPreFat   := NX0->NX0_COD
Local dDataEmi  := NX0->NX0_DTEMI
Local aVldCotac := {}
Local cMoeda    := ""
Local cQuery    := ""

	If Empty(cAlsVldCot)
		cMoeNac    := SuperGetMv('MV_JMOENAC',, '01')
		cTipoConv  := SuperGetMv('MV_JTPCONV',, '1' ) // Cotação '1' = Diária / '2' = Mensal
		cAlsVldCot := GetNextAlias()
		cQryVldCot := " SELECT NXR_CMOEDA FROM " + RetSqlName("NXR")
		cQryVldCot +=  " WHERE NXR_FILIAL = '" + xFilial("NXR") + "' "
		cQryVldCot +=    " AND NXR_CPREFT = ? "
		cQryVldCot +=    " AND NXR_ALTCOT = '2' "
		cQryVldCot +=    " AND NXR_COTAC  = 1 "
		cQryVldCot +=    " AND NXR_CMOEDA <> ? "
		cQryVldCot +=    " AND D_E_L_E_T_ = ' ' "
	EndIf

	// Quando lBindParam é .F. indica que na lib atual a função MPSysOpenQuery não faz a substituição dos "?" na query.
	// Por isso executamos a função J202QryBind, para fazer essa substuição
	cQuery := IIf(lBindParam, cQryVldCot, J202QryBind(cQryVldCot, {cPreFat, cMoeNac}))

	MPSysOpenQuery(cQuery, cAlsVldCot,,, {cPreFat, cMoeNac})

	While (cAlsVldCot)->(!Eof())
		cMoeda    := (cAlsVldCot)->NXR_CMOEDA
		aVldCotac := J201FVlCot(cMoeda, dDataEmi, .F.) // Indica se há cotação cadastrada para a moeda e data.
		lRet      := aVldCotac[1]
		nCotac    := aVldCotac[2]

		If lRet
			If cTipoConv == '1'
				lRet := nCotac == 1 // Identifica se a cotação da data da emissão, foi alterada após a emissão da pré (Cotação na pré está como 1, porém na CTP está diferente de 1)
			ElseIf cTipoConv == '2'
				lRet := nCotac == 0 .Or. nCotac == 1 // Identifica se a cotação do mês da data da emissão, foi alterada após a emissão da pré (Cotação na pré está como 1, porém na NXQ está diferente de 0 e 1)
			EndIf
		EndIf

		If !lRet
			Exit
		EndIf
		(cAlsVldCot)->(DbSkip())
	EndDo

	(cAlsVldCot)->(DbCloseArea())

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} J202UnMrk
Função que desmarca os registros de despesas que não processados WO

@author fabiana.silva
@since  11/06/2020
/*/
//-------------------------------------------------------------------
Static Function J202UnMrk(oModel, aChaves, aRecnDP)
Local aArea     := GetArea()
Local aSaveRows := FwSaveRows()
Local oModelNX8 := oModel:GetModel("NX8DETAIL")   // Contrato
Local oModelNX1 := oModel:GetModel("NX1DETAIL")   // Caso
Local nQtdNX8    := 0
Local nQtdNX1    := 0
Local nI         := 0
Local nY         := 0
Local nLnNX8_OLD := 0
Local nLnNX1_OLD := 0
Local aModels	 := {}
Local nC 		 := 1
Local cAliasAnt	  := ""
Local nQtdMod	:= 0
Local nB		:= 0
Local nRecnDP	:= Len(aRecnDP)
Local nPosNVY	:= 0
Local nTamNVY	:= 0
Local nZ		:= 0
	aSort(aChaves,,,{|a,b| a[3] + a[1] < b[3]+b[1]})

	For nC := 1 to Len(aChaves)
		If cAliasAnt <> aChaves[nC, 03]
			If nC > 1
				Atail(aModels)[3] := (nC -1)
			EndIf
			cAliasAnt := aChaves[nC, 03]
			aAdd(aModels, {cAliasAnt+"DETAIL", nC, 0,oModel:GetModel(cAliasAnt+"DETAIL"), cAliasAnt+"_TKRET" })
			nQtdMod++
		EndIf
	Next nC

	If nQtdMod > 0
		aModels[nQtdMod][3] := (nC -1)
	EndIf

	nLnNX8_OLD := oModelNX8:GetLine()
	nQtdNX8 := oModelNX8:Length()

	For nI := 1 To nQtdNX8

		oModelNX8:GoLine(nI)
		nLnNX1_OLD := oModelNX1:GetLine()
		nQtdNX1 := oModelNX1:Length()

		For nY := 1 To nQtdNX1
			oModelNX1:GoLine(nY)
			For nC := 1 to nQtdMod
				For nB := aModels[nC][02] to aModels[nC][03]
					If aModels[nC][04]:SeekLine({{aChaves[nB][04],aChaves[nB][01] }}, .F., .T.) .AND. ;
						aModels[nC][04]:GetValue(aModels[nC][05])

						aModels[nC][04]:SetValue(aModels[nC][05], .F.)
						//Marca para não cancelar a pré-fatura
						lCancPre := .F.

						For nZ := 1 to Len( aRecnDP)
							If ( nPosNVY := aScan( aRecnDP[nZ][3], { |r| r == aModels[nC][04]:GetDataID() }  )) > 0
								nTamNVY := Len(aRecnDP[nZ][3])
								nTamNVY--
								aDel(aRecnDP[nZ][3], nPosNVY)
								If nTamNVY = 0
									nRecnDP--
									aDel(aRecnDP, nZ)
									aSize(aRecnDP, nRecnDP)
								Else									
									aSize(aRecnDP[nZ][3], nTamNVY)
								EndIf

								Exit
							EndIf
						Next nZ												
					EndIf					
				Next nB
			Next nC

		Next nY
		oModelNX1:GoLine(nLnNX1_OLD)

	Next nI
	oModelNX8:GoLine(nLnNX8_OLD)

	FwRestRows(aSaveRows)
	RestArea(aArea)
Return

//------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} J202ImgPr 
Verifica se é possível processar a imagem da pré-fatura

@param cMsgErro        , Mensagem de Erro da Pré-Fatura
@param cCbxResult      , Saída da Pré-Fatura

@return lRet           , É possível processar a imagem da pré-fatura

@obs:

@author fabiana.silva
@since  03/01/2011
/*/
//------------------------------------------------------------------------------------------------------------
Static Function J202ImgPr(cMsgErro, cCbxResult)
Local cArquivo := "prefatura_" + NX0->NX0_COD + IIF(cCbxResult <> "3", ".pdf", ".doc")
Local cRet     := ""
Local lRet     := .T.
Local cSituac  := ""

lRet := cCbxResult $ "1|2"

If NX0->NX0_SITUAC $ SIT_SUBSTITUIDA + "|" + SIT_FATEMITIDA + "|" + SIT_CANCREVISAO + "|" + SIT_SINCRONIZANDO
	cDestPath := JurImgPre(NX0->NX0_COD, .T., .F., @cRet)
	If !Empty(cRet)
		cMsgErro += CRLF + NX0->NX0_COD + STR0350 + cRet //#" não foi possível localizar o arquivo. J202ImgPr--> "#
		lRet := .F.
	ElseIf !File(cDestPath + cArquivo)
		cSituac := JurSitGet(NX0->NX0_SITUAC)
		If Empty(cSituac)
			cSituac := NX0->NX0_SITUAC
		EndIf
		cMsgErro += CRLF + CRLF + NX0->NX0_COD + STR0351 + cSituac //#" não possui arquivo gerado no diretório para refazer, situação "#
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202AddCpVir
Função que adiciona os campos virtuais de marca (TKRET) e sigla 
nas estruturas das tabelas quando for uma execução via LegalDesk.

Isso é necessário pois nas requisições feitas via LegalDeskm os campos 
virtuais são excluídos das estruturas (ver lShowVirt no ModelDef), 
mas os campos de marca e sigla devem ser mantidos, já que durante as
operações (mesmo via LegalDesk) o modelo usa esses campos.

@param oStructNT1, Struct de parcelas fixas (NT1)
@param oStructNUE, Struct de time sheets (NUE)
@param oStructNV4, Struct de lançamentos tabelados (NV4)
@param oStructNVV, Struct de faturas adicionais (NVV)
@param oStructNVY, Struct de despesas (NVY)
@param oStructNX0, Struct de pré-fatura (NX0)
@param oStructNX1, Struct de casos da pré-fatura (NX1)
@param oStructNX2, Struct de participantes da pré-fatura (NX2)
@param oStructNX4, Struct de historico de cobrança da pré-fatura (NX4)
@param oStructNX8, Struct de contratos da pré-fatura (NX8)
@param lOHN      , Indica se existe a estrutura da OHN para adicionar o campo
@param oStructOHN, Struct de sócios/revisores da pré-fatura (OHN)

@author Jorge Martins
@since  28/02/2022
/*/
//-------------------------------------------------------------------
Static Function J202AddCpVir(oStructNT1, oStructNUE, oStructNV4, oStructNVV, oStructNVY, oStructNX0, oStructNX1, oStructNX2, oStructNX4, oStructNX8, lOHN, oStructOHN)

	AddCampo(1, "NT1_TKRET", @oStructNT1)
	AddCampo(1, "NUE_TKRET", @oStructNUE)
	AddCampo(1, "NV4_TKRET", @oStructNV4)
	AddCampo(1, "NVV_TKRET", @oStructNVV)
	AddCampo(1, "NVY_TKRET", @oStructNVY)
	AddCampo(1, "NX1_TKRET", @oStructNX1)
	AddCampo(1, "NX2_TKRET", @oStructNX2)
	AddCampo(1, "NX8_TKRET", @oStructNX8)

	AddCampo(1, "NUE_SIGLA1", @oStructNUE)
	AddCampo(1, "NUE_SIGLA2", @oStructNUE)
	AddCampo(1, "NUE_SIGLAA", @oStructNUE)
	AddCampo(1, "NUE_SIGLAR", @oStructNUE)
	AddCampo(1, "NV4_SIGLA" , @oStructNV4)
	AddCampo(1, "NVV_SIGLA1", @oStructNVV)
	AddCampo(1, "NVY_SIGLA" , @oStructNVY)
	AddCampo(1, "NX0_SIGLA" , @oStructNX0)
	AddCampo(1, "NX1_SIGLA" , @oStructNX1)
	AddCampo(1, "NX2_SIGLA" , @oStructNX2)
	AddCampo(1, "NX4_SIGLA" , @oStructNX4)
	AddCampo(1, "NX4_SIGLA1", @oStructNX4)
	AddCampo(1, "NX8_SIGLA" , @oStructNX8)
	If lOHN
		AddCampo(1, "OHN_SIGLA" , @oStructOHN)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J202QryBind
Faz a substituição dos sinais de "?" na query.

@param cQuery    , Query que será ajustada
@param aBindParam, Parâmetros que substituirão os sinais de "?"

@return cQuery   , Query ajustada

@obs    Essa função será executada SOMENTE quando a lib for inferior a 20211116.
        Pois o parâmetro aBindParam (5º parâmetro) na função MPSysOpenQuery 
        e o conceito de bind de queries só está disponível a partir da lib citada,
        conforme documentação abaixo.
        https://tdn.engpro.totvs.com.br/display/framework/MPSysOpenQuery

@author Jorge Martins / Reginaldo Borges
@since  18/03/2022
/*/
//-------------------------------------------------------------------
Static Function J202QryBind(cQuery, aBindParam)
Local nParam := 0

	For nParam := 1 To Len(aBindParam)
		cQuery := SubStr(cQuery, 1, AT("?", cQuery) - 1) + "'" + aBindParam[nParam] + "'" + SubStr(cQuery, AT("?", cQuery) + 1)
	Next

Return cQuery
