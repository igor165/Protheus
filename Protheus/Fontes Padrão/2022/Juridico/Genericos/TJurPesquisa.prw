#INCLUDE "FWBROWSE.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TJurPesquisa.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWCALENDARWIDGET.CH"
#INCLUDE "FWTABLEATTACH.CH"
#INCLUDE "fwlibversion.ch"

//-------------------------------------------------------------------
Function __TJurPesquisa() // Function Dummy
	ApMsgInfo( 'TJurPesquisa -> Utilizar Classe ao inves da funcao' )
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JurPesquisa
	CLASS TJurPesquisa

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS TJurPesquisa

	DATA cTitulo //Titulo da janela
	DATA oMenu
	DATA oDesk
	DATA oLstPesq
	DATA cTipoPesq
	DATA aObj 		 //Array com os Objetos de campos de filtro.
	DATA oCmbConfig  //Combo que contém as configurações de Layout.
	DATA aConfPesq
	DATA cUser
	DATA cThread
	DATA cTabPadrao
	DATA oDescCount //Objeto label das informações dos resultados da pesquisa
	DATA cSQLFeito
	DATA oVerde
	DATA oVermelho
	DATA oCinza
	DATA oAzul
	DATA oAmarelo
	DATA oBranco
	DATA aCampGrid
	DATA cGrpRest
	DATA aFiltros
	DATA lAnoMes
	DATA aTables
	DATA oPnlCfgFila
	DATA oFila //Fila de Impressão
	DATA xVarTAJ // Variavel Static do Código do Tipo de assunto juridico para passagem de valores entre funções
	DATA aRestMenu
	DATA lPesqGeral
	DATA aBConfig // Array com a lista de ações que devem ser executadas quando uma pesquisa é selecionada.
	DATA oPnlPrinc //Panel Principal que vai conter o combo de configuração.
	DATA oPesqGeral
	DATA aXML
	DATA llayout
	DATA oUrl
	DATA cQtdSec
	DATA cCmbOpc1
	DATA cCmbOpc2
	DATA cCmbPerc
	DATA cCmbVis1
	DATA cCmbVis2
	DATA cCmbTp1
	DATA cCmbTp2
	DATA cURL1
	DATA cURL2
	DATA lSecUnica
	DATA lBack
	DATA aTecAtalho
	DATA cAlQry //Alias utilizado para fazer as consultas
	DATA nMaxQry //número máximo de registros
	DATA cCurRec //recno posicionado no alias
	DATA nQtdReg // quantidade de registros da pesquisa
	DATA nPagDados //página de dados, para controlar a paginação
	DATA bLegenda

	METHOD New (cTitulo) CONSTRUCTOR
	METHOD Activate()
	METHOD Sair()
	METHOD loadAreaCampos(oPanel)
	METHOD loadGrid(oPanel)
	METHOD JA162Assjur(cCampo, nLinha)
	METHOD SetTipoPesq (cTipo)
	METHOD JA162Menu(nOpc,oLstPesq,aObj,oCmbConfig)
	METHOD MostraSQL()
	METHOD GetNomesConf()
	METHOD JA162ScrAr(oPnl,oCmbConfig)
	METHOD DelAll(aObj, aPosTela)
	METHOD SetCpoMemory(aObj)
	METHOD ListaHead(oLstPesq)
	METHOD SetFocusCpo(aObj)
	METHOD RefazTela(oWnd, aObj, oCmbConfig, aPosTela, nSelect)
	METHOD setCmpFull(aCampos)
	METHOD getAllCampos()
	METHOD SetTabPadrao (cTabela)
	METHOD ListaCol(aHead, cSQL, oCmbConfig)
	METHOD JQryPesq(cSql, cTabPadrao, aManual)
	METHOD AtuCount(nQtd)
	METHOD GetCposNVH()
	METHOD JGetPesq(nTipo)
	METHOD PosTela(aPosTela, nSelect, nColunas)
	METHOD AddAll(oWnd,aObj,aDadosCmps,nSelect,aPosTela, cDescConf)
	METHOD ZeraLista(oLstPesq)
	METHOD AtuFilaImp(oLstFila, cUser, cThread)
	METHOD GetEXISTS(cTabela, cWhere)
	METHOD GetCondicao(aSQL, cNSZName)
	METHOD Pesquisar(aObj, oLstPesq, cSQL, oCmbConfig)
	METHOD MontaSQL(aObj,oCmbConfig, xFiltro)
	METHOD TrocaWhere(oObj,aCampos)
	METHOD TransValor(Valor, cTipo, cAspas)
	METHOD GetGrupos(cCodPai)
	METHOD GetRelaGrupos(aTDCods, cCod)
	METHOD JGEmpr(cCodPai)
	METHOD getPosCmp(cCampo)
	METHOD setMenuPadrao(oMenu, aAcoes, aOpera, aRelat, aEspec, cRotina)
	METHOD LimpaPesq(aObj)
	METHOD JAltLote()
	METHOD getExcecaoLote()
	METHOD JurProc(cFil,cCod,cCajur, nOper, nTela, oModel, lModelo, lFecha, lFazPesquisa)
	METHOD getLegAnexo(cGaran, cCajuri)
	METHOD JA162SetTAJ(xConteudo)
	METHOD SelTipoAj(cPesq)
	METHOD Legenda(cNum)
	METHOD MostraLegAnex(oLstPesq, cTitulo)
	METHOD JA162Cod(oLstPesq)
	METHOD JA162BCorr(oLstPesq,aTables, nOp, lRecalculo)
	METHOD MenuCorr(oLstPesq, oObj, aTables)
	METHOD OpcAddFila(cCajur, cUser, cThread, oLstFila, cOpcFila, lDes, lVinc, cFili, cTipoAs)
	METHOD J162RemCas(aObj)
	METHOD befActivate()
	METHOD befAction()
	METHOD setMenRest()
	METHOD loadCmbConfig(oPanel)
	METHOD bActPesquisa()
	METHOD loadLayout()
	METHOD confLayout()
	METHOD bNewPanel()
	METHOD msgpanel()
	METHOD bvldpanel1()
	METHOD crialayout()
	METHOD criaXML()
	METHOD bVldNext()
	METHOD bVldFinish(lRestore)
	METHOD getXML()
	METHOD vldUrl()
	METHOD limpacombo()
	METHOD getGrafico( oPanel, cAliasEnt, cFonte, cType, cVision, cChart)
	METHOD montalayout()
	METHOD getCfg(nSecao)
	METHOD loadurl(oPanel)
	METHOD vldloadurl()
	METHOD getQtdReg()
	METHOD getFiltro()
	METHOD getTipoAs()
	METHOD getComplLote()
	METHOD VlAltLote()
	METHOD setFilial(oLstPesq, nOpc, aEnvBkp)
	METHOD Destroy(oObjeto)
	METHOD JHabLote()
	METHOD JTecAtalho(lSetAtalho)
	METHOD fillGrid()
	METHOD refreshLegenda()
	METHOD resetLay(oWizard)
	METHOD menuAnexos()
	METHOD getComplExc()
	METHOD getTelaExtr()
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New
		CLASS TJurPesquisa

@author André Spirigoni Pinto
@since 22/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD New (cTitulo) CLASS TJurPesquisa
	Public c162TipoAs := ''
	Private lPesquisa

	//Inicializador dos objetos
	Self:aConfPesq  := {}
	Self:aObj       := {}
	Self:aFiltros   := {}
	Self:oCmbConfig := NIL
	Self:cUser      := RetCodUsr()
	Self:cThread    := SubStr(AllTrim(Str(ThreadId())),1,4)
	Self:oVerde     :="BR_VERDE"
	Self:oVermelho  :="BR_VERMELHO"
	Self:oCinza     :="BR_CINZA"
	Self:oAmarelo   :="BR_AMARELO"
	Self:oAzul      :="BR_AZUL"
	Self:oBranco    :="BR_BRANCO"
	Self:cGrpRest   := JurGrpRest()
	Self:lAnoMes    := (SuperGetMV('MV_JVLHIST',, '2') == '1')
	Self:oFila      := Nil
	Self:aRestMenu  := {}
	Self:aTables    := JURRELASX9('NSZ', .F.)
	Self:lPesqGeral := .F.
	Self:aBConfig   := {}
	Self:lSecUnica  := .F.
	Self:lBack      := .F.
	Self:cSQLFeito  := ''
	Self:aTecAtalho := {}
	Self:nMaxQry	:= 100
	Self:cCurRec	:= ""
	Self:cTitulo	:= cTitulo
	Self:nQtdReg	:= 0
	Self:nPagDados	:= 1
	Self:bLegenda	:= Nil

	Self:oDesk := TJurAreaTrabalho():New(cTitulo,Self, {|| Self:befActivate()} /*Bloco que deve ser executado antes de ativar*/)

	Self:oDesk:aSizeDlg := FWGetDialogSize( oMainWnd )
	Self:oDesk:oMainDlg := MSDialog():New( Self:oDesk:aSizeDlg[1], Self:oDesk:aSizeDlg[2], Self:oDesk:aSizeDlg[3], Self:oDesk:aSizeDlg[4], cTitulo, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )
	//instancia a propriedade da area de trabalho
	Self:oDesk:oWorkarea := FWUIWorkArea():New( Self:oDesk:oMainDlg )

	//reserva o box vertical esquerdo para o menu
	Self:oDesk:oWorkarea:SetMenuWidth( 150 )

	//monta o menu lateral
	oMenu := FWMenu():New()
	oMenu:Init()

	oMenu := Self:getMenu(oMenu) //menu da classe filha

	Self:oDesk:oWorkarea:SetMenu( oMenu )

Return nil

	//-------------------------------------------------------------------
	/*/{Protheus.doc} SetTipoPesq (cTipo)
	Função que guarda o tipo de pesquisa em uso, para diferenciar ações
	nos fontes.
	1 - Assuntos Jurídicos
	2 - Follow Ups
	3 - Andamentos
	4 - Garantias
	5 - Despesas e Custas

	@author André Spirigoni Pinto
	@since 22/01/15
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD SetTipoPesq (cTipo) CLASS TJurPesquisa
	Self:cTipoPesq := cTipo
Return nil

	//-------------------------------------------------------------------
	/*/{Protheus.doc} SetTabPadrao (cTabela)
	Função que guarda o tipo de pesquisa em uso, para diferenciar ações
	nos fontes.
	1 - Assuntos Jurídicos
	2 - Follow Ups
	3 - Andamentos
	4 - Garantias
	5 - Despesas e Custas

	@author André Spirigoni Pinto
	@since 22/01/15
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD SetTabPadrao (cTabela) CLASS TJurPesquisa
	Self:cTabPadrao := cTabela
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} loadAreaCampos
	CLASS TJurPesquisa

Função que vai carregar a área onde os campos configurados são exibidos

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD loadAreaCampos (oPanel) CLASS TJurPesquisa
	Local oSplPesqC
	Local oPnlScrA
	Local cStyle := "QFrame{ background-color:#FFFFFF }"

	//Painel principal
	oSplPesqC := TScrollArea():New(oPanel,0,0,oPanel:nHeight,oPanel:nWidth,.T.,.T.,.T.)
	oSplPesqC:Align := CONTROL_ALIGN_ALLCLIENT
	oSplPesqC:nCLRPANE := RGB(255,255,255)
	oSplPesqC:ReadClientCoors(.T.,.T.)

	oPnlScrA := tPanelCSS():New(0,0,'',oSplPesqC,,,,,,0,0)
	oSplPesqC:SetFrame( oPnlScrA )
	oPnlScrA:setCSS(cStyle)
	oPnlScrA:nWidth  := oPanel:nWidth
	oPnlScrA:nHeight  := oPanel:nHeight
	oPnlScrA:ReadClientCoors(.T.,.T.)

	aAdd(Self:aBConfig, {||Self:JA162ScrAr(@oPnlScrA,Self:oCmbConfig)})
	aAdd(Self:aBConfig, {||Self:setMenRest()})
	aAdd(Self:aBConfig, {||Self:RefazTela(oPnlScrA, Self:aObj, Self:oCmbConfig)})
	aAdd(Self:aBConfig, {||Self:SetCpoMemory(Self:aObj)})

Return nil

	//-------------------------------------------------------------------
	/*/{Protheus.doc} loadGrid(oPanel)
	CLASS TJurPesquisa

		Função que vai carregar a área onde os campos configurados são exibidos

		@author André Spirigoni Pinto
		@since 29/01/15
		@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD loadGrid (oPanel) CLASS TJurPesquisa
	//*************** Panel Lista (oSplPesqL) ***************

	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	oPanel:nCLRPANE := RGB(240,240,240)

	//************** Fim Botoões Fila de Impressão *********

	Self:oLstPesq := TJurBrowse():New(oPanel)
	Self:oLstPesq:SetDataArray()
	Self:oLstPesq:Activate()

	Self:SetMEBrowse(Self:oLstPesq) //adiciona os eventos de click no Browse

	Self:oLstPesq:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	Self:oPnlCfgFila := tPanel():New(0,0,'',oPanel,,,,,,60,15)
	Self:oPnlCfgFila:Align := CONTROL_ALIGN_TOP
	Self:oPnlCfgFila:nCLRPANE := RGB(240,240,240)

	Self:oDescCount := tSay():New(10,01,{||''},Self:oPnlCfgFila,,,,,,.T.,,RGB(240,240,240),100,10)
	Self:oDescCount:Align := CONTROL_ALIGN_RIGHT
	Self:oDescCount:lWordWrap    := .T.
	Self:oDescCount:lTransparent := .T.
	Self:oDescCount:brClicked := {|| Self:MostraSQL()}

	aAdd(Self:aBConfig, {||Self:ZeraLista(Self:oLstPesq,Self:aObj)})
	aAdd(Self:aBConfig, {||IIF(Self:oFila!=Nil,Self:oFila:DelAllReg(),),Self:ListaHead(Self:oLstPesq),.T.})

	//***************  Fim Lista (oSplPesqL) ****************

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA162Menu
Menu de operações
Uso Geral.
@param      nOper   	Código da operação do Protheus
@param		oLstPesq	Lista de registros
@Param		aObj		Array que contem todos os campo de filtro.
@Param  	oCmbConfig	Combo que contém as configurações de Layout.
@author Juliana Iwayama Velho
@since 29/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD JA162Menu(nOpc,oLstPesq,aObj,oCmbConfig,lModelo) CLASS TJurPesquisa
	Local lRet      := .T.
	Local lMenuBrow := ExistBlock("J162MEN")
	Local cCod      := Self:getCodigo()
	Local cCajur    := Self:getCajuri()
	Local cFil      := Self:getFilial()
	Local lFecha    := .T.
	Local nLinha    := 0 // Linha Atual
	Local aEnvBkp   := {}
	Local lFilial   := FWModeAccess("NSZ",1) == "E" .And. FWModeAccess("NSZ",2) == "E" .And. FWModeAccess("NSZ",3) == "E"

	Default nOpc     := 3
	Default aObj     := {}
	Default lModelo  := .F.

	If lFilial //Valida se a tabela NSZ está exclusiva

		//Muda a filial para a filial correta. Se for inclusão, será apresentada a tela para que o usuário escolha a filial
		aEnvBkp := JURSM0FIL(self:cTabPadrao,Nil,(nOpc==3),cFil)

		//Valida se o usuário tem acesso a filial
		if !Self:setFilial(oLstPesq,nOpc,aEnvBkp)
			//se o usuário não tiver acesso, a rotina deve ser interrompida
			Return .T.
		Endif
	Endif //Fim valida NSZ Exclusiva.

	If nOpc <> 3 .And. !Empty(cCod)
		Do While lRet
			nLinha := Self:oLstPesq:nAt // Linha Atual

			cCod   := Self:getCodigo()
			cCajur := Self:getCajuri()
			cFil   := Self:getFilial()

			//chama a operação
			lRet := Self:JurProc(cFil,cCod,cCajur,nOpc,,,, lFecha)

			If lRet .And. lMenuBrow .And. Self:cTipoPesq == "2"
				lRet:=ExecBlock("J162MEN", .F., .F. )
			Else
				If lRet .And. nOpc > 3 //confirmou a operação e fez alteração
					if nOpc == 4 .And. Self:getQtdReg() > nLinha .And. SuperGetMV('MV_JALTPRX',, '2')=='1' //valida parâmetro se está habilitado o próximo
						if (lRet := ApMsgYesNo(STR0089))	//"Deseja alterar o próximo registro ?"
							Self:oLstPesq:oBrowse:scrollLines(1)
							Self:oLstPesq:nAt := nLinha + 1
						Endif
					Else
						lRet:= .F.
					Endif

					if !lRet .And. Self:cTipoPesq $ SuperGetMV('MV_JATUPE',, '2') //Valida se a pesquisa deve ser refeita
						Self:Pesquisar(Self:aObj,Self:oLstPesq,,Self:oCmbConfig)
					Endif
				Else
					lRet:= .F.
				EndIf
			Endif
		End
	Else
		Do While lRet
			if lFilial //se a filial for exclusiva, valida se o usuário tem acesso
				Self:setFilial(oLstPesq,nOpc,aEnvBkp)
			Endif

			lRet:= Self:JurProc(cFil,cCod,cCajur,nOpc,,,lModelo)

			If lRet .And. lMenuBrow .And. Self:cTipoPesq == "2"
				lRet:=ExecBlock("J162MEN", .F., .F. )
			Else
				lRet:=.F.
			Endif
		End
	EndIf

//volta a filial anterior, caso tenha mudado de filial
	If Len(aEnvBkp) > 0
		JURRESTFIL( aEnvBkp )
	Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MostraSQL
Função utilizada para mostrar o SQL que será utilizado na pesquisa.
Uso Geral.

@Param	aObj 		Array com os Objetos de campos de filtro.
@Param	oLstPesq	Grid.
@Param  oCmbConfig	Combo que contém as configurações de Layout.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD MostraSQL() CLASS TJurPesquisa
	Local oGet
	Local oDlgSQL
	Local oPnlSQL
	Local oPnlBtn

	Define MsDialog oDlgSQL Title 'SQL' From 0, 0 To 320, 840 Pixel
	oPnlSQL := tPanel():New(0,0,'',oDlgSQL,,,,,,097,70)
	oPnlBtn := tPanel():New(0,0,'',oDlgSQL,,,,,,10,20)
	oPnlSQL:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlBtn:Align := CONTROL_ALIGN_BOTTOM

	@ 001, 001 Get oGet Var Self:cSQLFeito Memo Size 097, 070 Pixel Of oPnlSQL
	oGet:Align := CONTROL_ALIGN_ALLCLIENT

	Define SButton From 005, 200 Type 1 Enable Of oPnlBtn Action oDlgSQL:End()

	Activate MsDialog oDlgSQL Center

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JA162Assjur
Retorna o CAJURI da garantia posicionada no grid

@Param		oLstPesq		Objeto com o grid da pesquisa
@Param		cCampo		Nome do campo do grid que deve ser retornado
@Param		nLinha		Número da linha

@author André Spirigoni Pinto
@since 07/05/14
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD JA162Assjur(cCampo, nLinha) CLASS TJurPesquisa
	Local nColuna := 0
	Local cRet        := ""
	Default cCampo := "NSZ_COD"

	Default nLinha := IIF(Valtype(Self:oLstPesq) <> "U",Self:oLstPesq:nAt,0)

	If Valtype(Self:oLstPesq) <> "U"

		nColuna := Self:getPosCmp(cCampo)

		If nColuna > 0 .And. !Empty(Self:oLstPesq:aCols)
			cRet := Self:oLstPesq:aCols[nLinha][nColuna]
		EndIf

	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Activate()
Método que inicializa o componente na tela

@author André Spirigoni Pinto
@since 22/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD Activate() CLASS TJurPesquisa

	lPesquisa  := .T.

	//valida se existe apenas uma configuração de pesquisa, seleciona a mesma
	if (Self:oCmbConfig != NIL)
		IIF(LEN(Self:oCmbConfig:aItems) == 2, Self:oCmbConfig:Select(1), )
	endif

	Self:oDesk:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GetNomesConf()
Função utilizada para pegar as configurações de layout de campos
referenciado ao usuário logado.
Uso Geral.

@Return		aRet	configurações relacionadas

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetNomesConf() CLASS TJurPesquisa
	Local aArea := GetArea()
	Local cConfigs := GetNextAlias()
	Local aRet := {}
	Local cCodPart := __CUSERID
	Local cQuery := ""

	Self:aConfPesq := {}

	cQuery := "SELECT TBUni.NVK_CPESQ, TBUni.NVG_DESC FROM ( "

	cQuery += "SELECT NVK.NVK_CPESQ,NVG.NVG_DESC "
	cQuery += "FROM " + RetSqlName("NVK") + " NVK JOIN " + RetSqlName("NVG") + " NVG "
	cQuery += "ON (NVK.NVK_CPESQ = NVG.NVG_CPESQ) "
	cQuery += "WHERE NVG.NVG_FILIAL = '" + xFilial("NVG") + "' "
	cQuery += "AND NVK.NVK_FILIAL = '" + xFilial("NVK") + "' "
	cQuery += "AND NVG.NVG_TPPESQ = '" + Self:cTipoPesq + "' "
	cQuery += "AND NVK.NVK_CUSER = '" + cCodPart + "' "
	cQuery += "AND NVG.D_E_L_E_T_=' ' AND NVK.D_E_L_E_T_=' '"

	cQuery += " UNION "

	cQuery += "SELECT NVK.NVK_CPESQ,NVG.NVG_DESC "
	cQuery += "FROM " + RetSqlName("NVK") + " NVK JOIN " + RetSqlName("NVG") + " NVG "
	cQuery += "ON (NVK.NVK_CPESQ = NVG.NVG_CPESQ) "
	cQuery += " JOIN " + RetSqlName("NZY") + " NZY "
	cQuery += "ON (NVK.NVK_CGRUP = NZY.NZY_CGRUP "
	cQuery += "AND NZY.NZY_CUSER = '"+ cCodPart + "') "
	cQuery += "WHERE NVG.NVG_FILIAL = '" + xFilial("NVG") + "' "
	cQuery += "AND NVK.NVK_FILIAL = '" + xFilial("NVK") + "' "
	cQuery += "AND NZY.NZY_FILIAL = '" + xFilial("NZY") + "' "
	cQuery += "AND NVG.NVG_TPPESQ = '" + Self:cTipoPesq + "' "
	cQuery += "AND NVG.D_E_L_E_T_=' ' "
	cQuery += "AND NVK.D_E_L_E_T_=' ' "
	cQuery += "AND NZY.D_E_L_E_T_=' ' "

	cQuery += ") TBUni "
	cQuery += " ORDER BY TBUni.NVG_DESC, TBUni.NVK_CPESQ"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQuery ) , cConfigs, .T., .F.)
	(cConfigs)->(dbGoTop())

	While (cConfigs)->(!Eof())
		aAdd(aRet,(cConfigs)->NVG_DESC)
		aAdd(Self:aConfPesq, {(cConfigs)->NVK_CPESQ, (cConfigs)->NVG_DESC})

		(cConfigs)->(dbSkip())
	End

	If Empty(aRet) .Or. aScan(aRet,PADR('', LEN(NVK->NVK_CPESQ))) == 0
		aAdd(aRet, '')
		aAdd(Self:aConfPesq, {'',''})
	EndIF

	(cConfigs)->( dbcloseArea() )
	RestArea(aArea)

Return aRet

	//-------------------------------------------------------------------
	/*/{Protheus.doc} DelAll(aObj, aPosTela)
	Função utilizada para remover todos os campos da tela.
	Uso Geral.

	@Param		aObj			Array que contem todos os campo de filtro.
	@Param		aPosTela	Matriz que controla a posição dos campos na tela.

	@author Felipe Bonvicini Conti
	@since 19/10/09
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD DelAll(aObj, aPosTela) CLASS TJurPesquisa
	Local nI

	For nI := 1 to LEN(aObj)
		If !(aObj[nI] == NIL)
			aObj[nI]:Destroy()
		EndIf
	Next

	//zera o array.
	aSize(aObj,0)
	aSize(aPosTela,0)

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JA162ScrAr
Verifica a quantidade de campos e linhas para montagem do tamanho da
barra de rolagem

@Param		oPnl		Objeto tela.
@Param		oCmbConfig	Combo que contém as configurações de Layout.

@author Juliana Iwayama Velho
@since 12/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD JA162ScrAr(oPnl,oCmbConfig) CLASS TJurPesquisa
	Local nTam       := 0
	Local nItem      := 0
	Local aDados     := {}
	Local aPos       := {}
	Local aPosTela   := {}
	Local nI         := 0
	Local nPesqGeral := 0
	Local nCt        := 0
	Local aTipoAss   := Str2Arr(allTrim(StrTran(JurSetTAS(.F.), "'", "")),",")

	For nCt := 1 to len(aTipoAss)
		If Self:cTipoPesq == "1"
			Self:lPesqGeral := JGetParTpa(aTipoAss[nCt], "MV_JPESPEC", '2' ) == "1"
			If Self:lPesqGeral
				Exit
			EndIf
		EndIf
	Next

	nItem := oCmbConfig:GetnAt()

	if LEN(oCmbConfig:aItems) > 0 .And. nItem > 0
		aDados := Self:GetCposNVH()

		For nI := 1 to LEN(aDados)
			aPOS := Self:PosTela(@aPosTela,nI,Int(oPnl:nWidth/130) )
		Next

		If Self:lPesqGeral
			nPesqGeral := 1
		EndIf

		If Len(aPosTela) > 0
			nTam := (Len(aPosTela) + nPesqGeral) * 27.375
		EndIf

		aPosTela := {}
		aPos     := {}

	EndIf

	If nTam * 2 > 0
		oPnl:nHeight := nTam * 2
	EndIf

Return .T.

	//-------------------------------------------------------------------
	/*/{Protheus.doc} SetCpoMemory(aObj)
	Função utilizada para setar todos as variáveis de memória referente
	aos campos de filtro da tela.
	Uso Geral.

	@Param	aObj	Array que contem todos os campo de filtro.

	@author Felipe Bonvicini Conti
	@since 19/10/09
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD SetCpoMemory(aObj) CLASS TJurPesquisa
	Local nI

	For nI := 1 to LEN(aObj)
		If !(aObj[nI] == NIL)
			M->&(aObj[nI]:cNomeCampo) := aObj[nI]:Valor
		EndIf
	Next

Return .T.

	//-------------------------------------------------------------------
	/*/{Protheus.doc} ListaHead()
	Função utilizada para configurar o cabeçalho da lista
	Uso Geral.

	@Return		aHead	Array com o cabeçalho

	@author Felipe Bonvicini Conti
	@since 19/10/09
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD ListaHead(oLstPesq) CLASS TJurPesquisa
	Local aArea		:= GetArea()
	Local cAliasQry	:= GetNextAlias()
	Local aHead		:= {{" ","cMostra","@BMP",2,0,".F.","","C","","V","","","","V","","","",""}}
	Local aCampos	:= {}
	Local cSQL		:= ''
	Local cPesq		:= Self:JGetPesq()
	Local aCampAux  := Self:getBrHeader()

	cSQL := " SELECT NYG.NYG_CAMPO,NYG.NYG_DCAMPO, NYH.NYH_ORDEM, NYF.NYF_TABELA, NYF.NYF_APELID, NYF.NYF_FILTRO, NYE.NYE_TABELA, NYE.NYE_APELID "+CRLF
	cSQL += " FROM "+RetSQlName('NYE')+" NYE "+ CRLF
	cSQL += " JOIN "+RetSqlName("NYF")+" NYF ON (NYF.NYF_CTABPR = NYE.NYE_COD) " + CRLF
	cSQL += " JOIN "+RetSqlName("NYG")+" NYG ON (NYG.NYG_CTABRE = NYF.NYF_COD AND NYG.NYG_CTABPR = NYE.NYE_COD) " + CRLF
	cSQL += "  LEFT JOIN "+RetSQlName('NYH')+" NYH "+ CRLF
	cSQL += "  ON ( NYH.NYH_CPESQ = NYE.NYE_CPESQ AND NYH.NYH_CAMPO = NYG.NYG_CAMPO "+CRLF
	cSQL += "  AND NYH.NYH_APELID = NYF.NYF_APELID AND NYH.NYH_FILIAL = '" + xFilial('NYH') + "' AND NYH.D_E_L_E_T_ = ' ' ) "+CRLF
	cSQL += " WHERE NYE.NYE_FILIAL = '"+ xFilial('NYE') +"' AND NYF.NYF_FILIAL = '"+ xFilial('NYF') +"'"+CRLF
	cSQL += " AND NYG.NYG_FILIAL = '" + xFilial('NYG') +"' AND NYE.D_E_L_E_T_ = ' ' AND NYF.D_E_L_E_T_ = ' ' AND NYG.D_E_L_E_T_ = ' ' AND "+CRLF
	cSQL += " NYE.NYE_CPESQ = '"+ cPesq +"'"+CRLF
	cSQL += " ORDER BY NYH.NYH_ORDEM "

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAliasQry, .T., .F.)

	If !Empty(cPesq)

		While !(cAliasQry)->( EOF())
			If __Language == "PORTUGUESE"
				aAdd(aCampos, {(cAliasQry)->NYG_CAMPO,(cAliasQry)->NYG_DCAMPO, (cAliasQry)->NYF_TABELA, (cAliasQry)->NYF_APELID, (cAliasQry)->NYF_FILTRO, (cAliasQry)->NYE_TABELA, (cAliasQry)->NYE_APELID,AllTrim((cAliasQry)->NYF_APELID)+AllTrim((cAliasQry)->NYG_CAMPO)} )
			Else
				aAdd(aCampos, {(cAliasQry)->NYG_CAMPO,RetTitle((cAliasQry)->NYG_CAMPO), (cAliasQry)->NYF_TABELA, (cAliasQry)->NYF_APELID, (cAliasQry)->NYF_FILTRO, (cAliasQry)->NYE_TABELA, (cAliasQry)->NYE_APELID,AllTrim((cAliasQry)->NYF_APELID)+AllTrim((cAliasQry)->NYG_CAMPO)} )
			EndIf
			(cAliasQry)->(DbSkip())
		End

		(cAliasQry)->(dbCloseArea())

		oLstPesq:setHeaderSX3(aCampos,aHead)
		//Campos adicionais
		aEval(aCampAux,{|x| aAdd(aCampos,{x[1],x[2],x[3]})})

		RestArea(aArea)

		Self:setCmpFull(aCampos)

		oLstPesq:Activate()

	Endif //fim valida cpesq preenchido

Return

	//-------------------------------------------------------------------
	/*/{Protheus.doc} RefazTela(oWnd, aObj, oCmbConfig, aPosTela, nSelect)
	Função utilizada para refazer o layout de tela.
	Uso Geral.

	@Param		oWnd				Objeto tela.
	@Param		aObj				Array que contem todos os campo de filtro.
	@Param		oCmbConfig	Combo que contém as configurações de Layout.
	@Param		aPosTela		Matriz que controla a posição dos campos na tela.
	@Param		nSelect			Variavél que controla qual objeto esta em foco.

	@author Felipe Bonvicini Conti
	@since 19/10/09
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD RefazTela(oWnd, aObj, oCmbConfig, aPosTela, nSelect) CLASS TJurPesquisa
	Local nItem, aDadosCmps, aPOS, nCt

	Default aPosTela := {}

	Self:DelAll(@aObj, @aPosTela)
	nItem := oCmbConfig:GetnAt()

	If LEN(oCmbConfig:aItems) > 0 .And. nItem > 0

		MsgRun(STR0037,Self:cTitulo,{|| }) //"Carregando..." e "Assunto Jurídico"
		aDadosCmps := Self:GetCposNVH()

		If	Self:lPesqGeral
			aPOS := Self:PosTela(@aPosTela,1,Int(oWnd:nWidth/130))
			aAdd(aObj, TJurPnlCampo():New(aPOS[1],aPOS[2],120,22,oWnd,STR0043,'NT9_NOME',{|| },{|| }) )
			For nCt := 2 to len(aPosTela[1])
				aPosTela[1][nCt] := '0'
			Next
		EndIf

		Self:AddAll(oWnd, aObj, aDadosCmps, @nSelect, @aPosTela, oCmbConfig:cValor)

		If (SuperGetMV('MV_JRSTCAD',, '2') == '1')
			FwSetFilterLookup( { |cAlias| JurFiltRst(cAlias) } )
		EndIf

		c162TipoAs := JurSetTAS(.F.)

		Self:SetFocusCpo(aObj)
	EndIf

Return .T.

	//-------------------------------------------------------------------
	/*/{Protheus.doc} SetFocusCpo(aObj)
	Função utilizada para setar o foco no primeiro campo da tela.
	Uso Geral

	@Param	aObj	Array com os objetos de campos da tela.

	@author Felipe Bonvicini Conti
	@since 24/10/09
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD SetFocusCpo(aObj) CLASS TJurPesquisa
	Local nI
	For nI:=1 to LEN(aObj)
		If !aObj[nI] == NIL
			aObj[nI]:oCampo:SetFocus()
			Exit
		EndIf
	Next
Return Nil

	//-------------------------------------------------------------------
	/*/{Protheus.doc} ListaCol(aHead, cSQL)
	Função utilizada para preencher a lista.
	Uso Geral.

	@Param		aHead Array com o cabeçalho da lista.
	@Param		cSQL	SQL para do filtro da pesquisa.
	@Return		aCol	Array com o registros.

	@author Felipe Bonvicini Conti
	@since 19/10/09
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD ListaCol(aHead, cSQL, oCmbConfig) CLASS TJurPesquisa
	Local aCol     := {}
	Local cCampos	 := ""
	Local nCt
	Local aAllCampos := Self:getAllCampos()
	Local cTmp
	Local nTemp
	Local aHeader := Self:oLstPesq:getHeader()

	Default oCmbConfig := NIL

	//Carrega a variável cCampos
	For nCt := 1 to Len(aAllCampos)
		nTemp := aScan(aHeader,{|x| x[16] == aAllCampos[nCt][1]},2)
		If nTemp == 0 .Or. aHeader[nTemp][10] <> "V" //valida se o campo é virtual.
			If Len(aAllCampos[nCt])>3 //valida se não é o campo NSZ_COD que é padrão
				cTmp := IIF(aAllCampos[nCt][3]==Self:cTabPadrao,AllTrim(aAllCampos[nCt][1]),AllTrim(aAllCampos[nCt][4])+"."+AllTrim(aAllCampos[nCt][1]))
			Else
				cTmp :=  AllTrim(aAllCampos[nCt][1])
			Endif
			cCampos += cTmp + ','
		Endif
	Next nCt

	If cCampos != "" //valida se existem campos.

		//Retira a vírgula
		cCampos := Left(cCampos,Len(cCampos)-1)

		aCol := Self:getBrCols(cSQL, cCampos, aHead)

	Endif //valida de existem campos

Return aCol

	//-------------------------------------------------------------------
	/*/{Protheus.doc} J162QryPesq(cSql, cTabPadrao, aManual)
	Função utilizada para montar a parte do FROM da consulta SQL de acordo
	com os campos escolhidos e a tabela padrão informada.
	Uso Geral.

	@Param		cSQL Parte SELECT da query com o FROM da tabela padrão
	@Param		cTabPadrao	Tabela padrão, Ex. NSZ, NT4, NTA, NT2 e NT3
	@Param		aManual	Tabelas obrigatórias que devem ser incluídas.
	@Return	cRet	Consulta SQL completa.

	@author André Spirigoni Pinto
	@since 10/11/13
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD JQryPesq(cSql, cTabPadrao, aManual) CLASS TJurPesquisa
Local cRet	:= ''
Local aTmp	:= {}
Local cTmp	:= ''
Local nCt
Local nPos        := 1
Local nI
Local cTmpTabela
Local cTmpApelido
Local aSX9	      := {}
Local aTmpTab1    := {}
Local aTmpTab2    := {}
Local nCtr
Local cApTab1
Local cApTab2
Local aAllCampos  := Self:getAllCampos()
Local nTemp
Local aHeader     := Self:oLstPesq:getHeader()

Default aManual := {} //caso necessário incluir alguma tabela manualmente. pos1 - tabelapai, pos2 - tabelafilha, pos3 - apelido.

	/*
	pos1 -> Tabela Pai
	pos2 -> Apelido Pai
	pos3 -> Tabela Filha
	pos4 -> Apelido
	pos5 -> Filtro
	*/

	//Corrige problema com SX9 da NUQ e campo de instância da NT4 que faz a query ficar errada. Se achar a NUQ, força o relacionamento abaixo
	if aScan(aAllCampos,{|x| x[3] == "NUQ"}) > 0
		if aScan(aManual,{|x| x[3] == "NUQ"}) == 0
			AAdd(aManual,{"NSZ", "NSZ001", "NUQ", "NUQ001", "NUQ001.NUQ_INSATU = '1'"})
		Endif
	Endif

	//<- Valida tabelas manuais ->
	For nCt := 1 to Len(aManual)

		//valida tabela
		cTmpTabela  := Alltrim( RetSqlName(aManual[nCt][3]) )
		cTmpApelido := AllTrim( aManual[nCt][4] )

		If (At(cTmpTabela + " " + cTmpApelido,cRet) == 0 .And. cTmpTabela != cTabPadrao)//valida a tabela

			aSx9 := JURSX9(aManual[nCt][1],aManual[nCt][3])

			If  (Len(aSx9) <= 0)  //Tratamento de Erro por nao ter encontrado o relacionamento

				//não é a primeira ocorrência, assim, será preciso adicionar a tabela no sql
				cTmp += "         INNER JOIN "+cTmpTabela+" "+cTmpApelido+" ON " + CRLF
				cTmp += "                ( 1 = 2 ) " + CRLF

				Aviso(STR0038,STR0039 + CRLF + ; //"Mensagem de Erro"##"Tabela SX9 desatualizada! "
				STR0040 + aAllCampos[nCt][6] + "," + aAllCampos[nCt][3] + ")." + CRLF + ; //"Não encontrado o relacionamento dos alias ("
				STR0041, {STR0042}) //"Nenhuma informação será retornada!"##"Voltar"
			Else

				aTmpTab1 := STRToArray(aSX9[1][1], '+')
				aTmpTab2 := STRToArray(aSX9[1][2], '+')

				//não é a primeira ocorrência, assim, será preciso adicionar a tabela no sql
				cRet += "         LEFT JOIN "+cTmpTabela+" "+cTmpApelido+" ON " + CRLF
				cRet += "                ("

				For nCtr := 1 to Len(aTmpTab1)
					//Determina o apelido que deve ser usado. A função IIF valida se a tabela é do tipo SA1, onde o nome do campo é A1_ por exemplo
					If IIf(At('_',Left(aTmpTab1[nCtr],3))>0,'S'+Left(aTmpTab1[nCtr],2),Left(aTmpTab1[nCtr],3)) == aManual[nCt][3]
						cApTab1 := aManual[nCt][4]
						cApTab2 := aManual[nCt][2]
					Else
						cApTab1 := aManual[nCt][2]
						cApTab2 := aManual[nCt][4]
					Endif

					cRet += IIF(Left(AllTrim(aTmpTab1[nCtr]),3)==cTabPadrao,AllTrim(aTmpTab1[nCtr]),cApTab1 + "." + AllTrim(aTmpTab1[nCtr])) + ;
						" = " + IIF(Left(AllTrim(aTmpTab2[nCtr]),3)==cTabPadrao,AllTrim(aTmpTab2[nCtr]),cApTab2 + "." + AllTrim(aTmpTab2[nCtr])) + " AND "
				Next nCtr

				cRet := Left(cRet,Len(cRet)-5) + CRLF
				cRet += "               AND "+ cTmpApelido +".D_E_L_E_T_ = ' ' " + CRLF

				//valida se existe filtro
				If !Empty(aManual[nCt][5])
					cRet += "               AND " + STRTRAN(AllTrim(aManual[nCt][5]),cTabPadrao+"001.","")
				Endif

				//-- Relacionamento a partir da exclusividade das tabelas.
				cTmp += "               AND " + JQryFilial(aManual[nCt][1], aManual[nCt][3], aManual[nCt][2], aManual[nCt][4]) //-- cTabPai, cTabFilha, cApPai, cApFilha
				cTmp += " )" + CRLF

				cRet += cTmp
				cTmp := ''
			EndIf

			aSX9 := {}
		Endif //valida tabela

	Next

	//Campos selecionados do grid

	For nCt := 1 to Len(aAllCampos)
		//valida tabela
		//valida se são os campos padrões
		nTemp := aScan(aHeader,{|x| x[16] == aAllCampos[nCt][1]},2)

		If ( len(aAllCampos[nCt]) > 3 ) .And. (nTemp == 0 .Or. aHeader[nTemp][10] <> "V") //valida se o campo é virtual.

			cTmpTabela := Alltrim(RetSqlName(aAllCampos[nCt][3]))
			cTmpApelido := AllTrim(aAllCampos[nCt][4])

			If (At(cTmpTabela + " " + cTmpApelido,cRet) == 0 .And. cTmpTabela != cTabPadrao)//valida a tabela

				aSx9 := JURSX9( aAllCampos[nCt][6] , aAllCampos[nCt][3] )

				If  (Len(aSx9) <= 0)  //Tratamento de Erro por nao ter encontrado o relacionamento
					//não é a primeira ocorrência, assim, será preciso adicionar a tabela no sql
					cTmp += "         INNER JOIN "+cTmpTabela+" "+cTmpApelido+" ON " + CRLF
					cTmp += "                ( 1 = 2 ) " + CRLF

					Aviso(STR0038,STR0039 + CRLF + ;  //"Mensagem de Erro"##"Tabela SX9 desatualizada! "
					STR0040 + aAllCampos[nCt][6] + "," + aAllCampos[nCt][3] + ")." + CRLF + ; //"Não encontrado o relacionamento dos alias ("
					STR0041, {STR0042}) //"Nenhuma informação será retornada!"##"Voltar"
				Else
					aTmpTab1 := STRToArray(aSX9[1][1], '+')

					nPos := 1

					For nI := 1 to Len(aSx9)
						If Alltrim(aSX9[nI][2]) $ AllTrim(aAllCampos[nCt][5])
							nPos := nI
						EndIf
					Next

					aTmpTab2 := STRToArray(aSX9[nPos][2], '+')

					//não é a primeira ocorrência, assim, será preciso adicionar a tabela no sql
					cTmp += "         LEFT JOIN "+cTmpTabela+" "+cTmpApelido+" ON " + CRLF
					cTmp += "                ("

					For nCtr := 1 to Len(aTmpTab1)
						//Determina o apelido que deve ser usado. A função IIF valida se a tabela é do tipo SA1, onde o nome do campo é A1_ por exemplo
						If IIf(At('_',Left(aTmpTab1[nCtr],3))>0,'S'+Left(aTmpTab1[nCtr],2),Left(aTmpTab1[nCtr],3)) == aAllCampos[nCt][3]
							cApTab1 := aAllCampos[nCt][4]
							cApTab2 := aAllCampos[nCt][7]
						Else
							cApTab1 := aAllCampos[nCt][7]
							cApTab2 := aAllCampos[nCt][4]
						Endif

						cTmp += IIF(Left(AllTrim(aTmpTab1[nCtr]),3)==cTabPadrao,AllTrim(aTmpTab1[nCtr]),cApTab1 + "." + AllTrim(aTmpTab1[nCtr])) + ;
							" = " + IIF(Left(AllTrim(aTmpTab2[nCtr]),3)==cTabPadrao,AllTrim(aTmpTab2[nCtr]),cApTab2 + "." + AllTrim(aTmpTab2[nCtr])) + " AND "
					Next nCtr

					cTmp := Left(cTmp,Len(cTmp)-5) + CRLF

					cTmp += "               AND "+ cTmpApelido +".D_E_L_E_T_ = ' ' " + CRLF
					//valida se existe filtro
					If !Empty(aAllCampos[nCt][5])
						cTmp += "               AND " + STRTRAN(AllTrim(aAllCampos[nCt][5]),cTabPadrao+"001.","")
					Endif

					//-- Relacionamento a partir da exclusividade das tabelas.
					cTmp += "               AND " + JQryFilial(aAllCampos[nCt][6], aAllCampos[nCt][3], aAllCampos[nCt][7], aAllCampos[nCt][4]) //-- cTabPai, cTabFilha, cApPai, cApFilha
					cTmp += " )" + CRLF

				EndIf

				aSX9 := {}

				If At(cApTab2+" ",cRet) == 0 .And. cApTab2 != cTabPadrao .And. cApTab1 != cTabPadrao //valida se a tabela do join ja existe.
					aAdd(aTmp,cTmp)
				Else
					cRet += cTmp
				Endif

				cTmp := ''
			Endif //valida tabela
		Endif //valida se é um campo padrão
	Next nCt

	//<- Inclui os relacionamentos que devem ficar por último ->
	For nCt := 1 to Len(aTmp)
		If At(aTmp[nCt],cRet) == 0
			cRet += aTmp[nCt]
		Endif
	Next nCt

Return cSql + CRLF + cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuCount(nQtd)
Função utilizada para informar a quantidade de registros a pesquisa
retornou.
Uso Geral.

@Param	nQtd	Quantidade de resistros.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD AtuCount(nQtd) CLASS TJurPesquisa
	Self:oDescCount:cCaption := ' '+STR0001+' '+Alltrim(Str(nQtd)) //"Quantidade de Registros:"
	Self:oDescCount:Refresh()
	Self:nQtdReg := nQtd
	Self:nPagDados := 1
Return NIL

	//-------------------------------------------------------------------
	/*/{Protheus.doc} getAllCampos()
	Função utilizada para retornar a posição do campo do array de campos
	montado com todos os campos do grid
	Uso Geral.

	@Return	_aCampGrid Retorna o array

	@author André Spirigoni Pinto
	@since 10/11/13
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD getAllCampos() CLASS TJurPesquisa
Return Self:aCampGrid

	//-------------------------------------------------------------------
	/*/{Protheus.doc} GetCposNVH()
	Função utilizada para pegar todos os campos da tabela NVH refrente a
	configuração de layout.
	Uso Geral.

	@Param		cDescConf	Nome da configuração de layout.
	@Return		aCampos		Array com os campos ca configuração de layout(Codigo e Descrição).

	@author Felipe Bonvicini Conti
	@since 19/10/09
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD GetCposNVH() CLASS TJurPesquisa
	Local aArea := GetArea()
	Local cCampos := GetNextAlias()
	Local aCampos := {}
	Local cPesq := Self:JGetPesq()
	Local cQuery := ""

	cQuery := "SELECT NVH.NVH_COD,NVH.NVH_DESC,NVH.NVH_CAMPO " + CRLF
	cQuery += "FROM " + RetSqlName("NVH") + " NVH JOIN " + RetSqlName("NVG") + " NVG "
	cQuery += "ON (NVG.NVG_CCAMPO = NVH.NVH_COD) " + CRLF
	cQuery += "WHERE NVG.NVG_FILIAL = '" + xFilial("NVG") + "' " + CRLF
	cQuery += "AND NVH.NVH_FILIAL = '" + xFilial("NVH") + "' " + CRLF
	cQuery += "AND NVG.NVG_CPESQ = '" + cPesq + "' " + CRLF
	cQuery += "AND NVG.NVG_TPPESQ = '" + Self:cTipoPesq + "' " + CRLF
	cQuery += "AND NVG.D_E_L_E_T_='' AND NVH.D_E_L_E_T_=''" + CRLF
	cQuery += "ORDER BY NVG.NVG_COD"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQuery ) , cCampos, .T., .F.)

	While (cCampos)->(!Eof())
		If __Language == 'PORTUGUESE'
			aADD( aCampos, { (cCampos)->NVH_COD, (cCampos)->NVH_DESC } )
		Else
			aADD( aCampos, { (cCampos)->NVH_COD, JA160X3Des((cCampos)->NVH_CAMPO) } )
		EndIf

		(cCampos)->(dbSkip())
	End

	(cCampos)->( dbcloseArea() )
	RestArea(aArea)

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetPesq
Retorna se a tela está ativa

@author Jorge Luis Branco Martins Junior
@since 28/10/13
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD JGetPesq(nTipo) CLASS TJurPesquisa
	Local cPesq := ""
	Local nAt   := 0
	Local nLen  := Len(Self:aConfPesq)

	Default nTipo := 1

	If  Self:oCmbConfig != NIL
		nAt := Self:oCmbConfig:GetnAt()
	EndIf

	If nLen > 0 .And. (nAt > 0 .And. nAt <= nLen) .And. (nTipo == 1 .Or. nTipo == 2)
		cPesq := Self:aConfPesq[nAt][nTipo]
	EndIf

Return cPesq

	//-------------------------------------------------------------------
	/*/{Protheus.doc} PosTela(aPosTela, nSelect)
	Função utilizada para determinar aonde serão colocados os objetos de campos na tela.
	Uso Geral.

	@Param		aPosTela	Matriz que controla a posição dos campos na tela.
	@Param		nSelect		Variavél com a posição do objeto no array aOBJ.
	@Return		aRet			Array com as posições para o objeto(Top, Left)

	@author Felipe Bonvicini Conti
	@since 19/10/09
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD PosTela(aPosTela, nSelect, nColunas) CLASS TJurPesquisa
	Local nX,nY
	Local lLivre := .F.
	Local aRet := {,}
	Local nI := 0
	Local nPos

	Default aPosTela := {}
	Default nColunas := len(aPosTela[1])

	For nX:=1 to LEN(aPosTela)
		For nY := 1 to len(aPosTela[nX])
			if aPosTela[nX][nY] == ''
				lLivre := .T.
				aRet[1] := (nX*25)-20
				aRet[2] := (nY*60)-55
				aPosTela[nX][nY] := AllTrim(STR(nSelect))
				Exit
			EndIf
		Next
		IF lLivre
			Exit
		EndIf
	Next

	IF !(lLivre)
		aAdd(aPosTela,{Nil})
		nPos := len(aPosTela)
		aSize(aPosTela[nPos],nColunas)
		For nI := 1 to nColunas
			if nI == 1
				aPosTela[nPos][nI] := AllTrim(STR(nSelect))
			else
				aPosTela[nPos][nI] := ''
			Endif
			//aAdd( aPosTela, {AllTrim(STR(nSelect)),'','','','',''} )
		Next

		aRet[1] := (LEN(aPosTela)*25)-20
		aRet[2] := 5

	EndIF

Return aRet

	//-------------------------------------------------------------------
	/*/{Protheus.doc} AddAll(oWnd,aObj,aDadosCmps,nSelect,aPosTela, cDescConf)
	Função utilizada para adicionar os campos na tela.
	Uso Geral.

	@Param		oWnd				Objeto tela.
	@Param		aObj				Array que contem todos os campo de filtro.
	@Param		aDadosCmps  Array que contem todos os dados dos campos de filtro.
	@Param		nSelect			Variavél que controla qual objeto esta em foco.
	@Param		aPosTela		Matriz que controla a posição dos campos na tela.
	@Param		cDescConf		Nome da configuração de Layout.

	@author Felipe Bonvicini Conti
	@since 19/10/09
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD AddAll(oWnd,aObj,aDadosCmps,nSelect,aPosTela, cDescConf) CLASS TJurPesquisa
	Local nI, nPos, aPOS

	If Len(aDadosCmps)>0

		For nI := 1 to LEN(aDadosCmps)
			NVG->(DBSetOrder(1))
			NVG->( DBSeek(XFILIAL('NVG') + Self:JGetPesq() + aDadosCmps[nI][1]) )

			nPos := LEN(aObj)+1
			aPOS := Self:PosTela(@aPosTela,nPos,Int(oWnd:nWidth/130))

			aAdd(aObj, TJurPnlCampo():New(aPOS[1],aPOS[2],52,22,oWnd,aDadosCmps[nI][2],aDadosCmps[nI][1],;
				{|| nSelect := nPos },;
				{|| Self:SetCpoMemory(aObj)},;
				NVG->NVG_SUGEST,NVG->NVG_VISIVE,NVG->NVG_ENABLE) )
			If aObj[nPos]:IsF3Multi()
				aObj[nPos]:Valor := IIF(Empty(NVG->NVG_SUGEST) .AND. !Empty(aObj[nPos]:cNomeCampo) , PADL(" ", 200), TransCpo(NVG->NVG_SUGEST, aObj[nPos]:aInfoCampo[2], aObj[nPos]:aInfoCampo[3]))
				aObj[nPos]:EnableF3Multi()
			EndIf

			aObj[nPos]:SetbF3()

		Next

	EndIf

Return NIL

	//-------------------------------------------------------------------
	/*/{Protheus.doc} ZeraLista(oLstPesq)
	Função utilizada para zerar a lista(Grid).
	Uso Geral.

	@Param	oLstPesq	Lista dos registros(Grid).

	@author Felipe Bonvicini Conti
	@since 19/10/09
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD ZeraLista(oLstPesq) CLASS TJurPesquisa
	oLstPesq:clearData()

	If select(Self:cAlQry)>0
		(Self:cAlQry)->( dbcloseArea() )
	Endif
Return .T.

	//-------------------------------------------------------------------
	/*/{Protheus.doc} AtuFilaImp(oLstFila, cUser, cThread, oPanel, oPanelPai)
	Função utilizada para atualizar a fila de impressão
	Uso Geral.
	@param oLstFila	Lista da fila de impressão
	@Param cUser	   Objeto de criação do menu
	@Param cThread   Posição da linha do Grid
	@Param oLstFila  ListBox da fila de impressão
	@Param oPanel    Objeto contendo o panel da fila de impressão
	@Param oPanelPai Objeto contendo o panel da pesquisa de processo
	@Return Nil
	@author Clóvis Eduardo Teixeira
	@since 06/01/10
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD AtuFilaImp(oLstFila, cUser, cThread) CLASS TJurPesquisa

	oLstFila:SetArray(Self:ListaColImp(oLstFila:aHeader, cUser, cThread))
	oLstFila:Refresh()

	if LEN(oLstFila:ACOLS) == 0
		oLstFila:Disable()
	Else
		oLstFila:Enable()
		Self:oFila:PnlFila(.T.)
	Endif

Return Nil

	//-------------------------------------------------------------------
	/*/{Protheus.doc} setCmpFull(aCampos)
	Função utilizada para armazenar a variável aCampos de forma que ela
	seja usada em outros lugares do fonte
	Uso Geral.

	@Param		cCampo Nome do campo
	@Return	nRet	Posição do mesmo no Array

	@author André Spirigoni Pinto
	@since 10/11/13
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD setCmpFull(aCampos) CLASS TJurPesquisa
	Local lRet := .T.

	If Len(aCampos)>0
		Self:aCampGrid := aCampos
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Sair
Função usada para fechar a tela

@author André Spirigoni Pinto
@since 10/11/13
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD Sair() CLASS TJurPesquisa

	//Valida se existe fila
	if Self:oFila != NIl
		Self:oFila:DeActivate()
	endif

	//valida se o alias ainda está ativo
	If select(Self:cAlQry)>0
		(Self:cAlQry)->( dbcloseArea() )
	Endif

	lPesquisa := .F.

	Self:oDesk:Sair()

Return NIl

//-------------------------------------------------------------------
/*/{Protheus.doc} Pesquisar
Função utilizada para efetuar a pesquisa.
Uso Geral.

@Param	aObj		Array que contem todos os campo de filtro.
@Param	oLstPesq	Lista dos registros(Grid).
@Param  cSQL		SQL
@Param  oCmbConfig	Combo que contém as configurações de Layout.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD Pesquisar(aObj, oLstPesq, cSQL, oCmbConfig) CLASS TJurPesquisa
	Local lOk       := .T.
	Local aFiltro   := {}

	If select(Self:cAlQry)>0
		(Self:cAlQry)->( dbcloseArea() )
	Endif

	If oCmbConfig:GetnAt() >= 0 .And. Empty(oCmbConfig:cValor)
		lOk := .F.
		Alert(STR0002) //"É necessário selecionar uma configuração de pesquisa"
	Endif

	If (Valtype(Self:oLstPesq) == "U" .Or. (Len(Self:oLstPesq:aHeader) <= 1)) .And. lOk
		lOk	:= .F.
		Alert(STR0003)//"É necessário configurar o grid de pesquisa.")
	Endif

	aFiltro := aClone(Self:getFiltro())
	If (Len(aFiltro) == 1 .Or. ( Len(aFiltro) == 2 .And. aFiltro[2][2] == 'AND 1 = 1' )) .AND. lOk
		If !ApMsgNoYes(STR0091) //"Você não informou nenhum filtro para a pesquisa. A pesquisa pode demorar. Deseja continuar ?"
			lOk	:= .F.
		Endif
	Endif

	If lOK

		aObj := Self:J162RemCas(aObj) //Verifica o remanejamento do caso

		cSQL := Self:MontaSQL(aObj,oCmbConfig)

		//limpa o grid
		Self:oLstPesq:SetArray({})

		//Faz a atribuição do array de dados ao browse
		MsgRun(STR0004,I18N(STR0005,{Self:cTitulo}),{|| Self:oLstPesq:SetArray(Self:ListaCol(Self:oLstPesq:getHeader(),cSQL,oCmbConfig:cValor)) }) //"Pesquisando..." e "Pesquisa de #1"

		If LEN(Self:oLstPesq:aCols) == 0
			Alert(STR0006) //"Nenhum registro encontrado."
		EndIf

	endif

	aSize(aFiltro,0)

Return NIL

	//-------------------------------------------------------------------
	/*/{Protheus.doc} GetCondicao(aSQL, cNSZName)
	Função utilizada para pegar todas as condições refernte a tabela a
	ser utilizada para a montagem do SQL da pesquisa.
	Uso Geral.

	@Param	aSQL				Array com todas as condições dos campso a serem
	utilizados no filtro.
	@Param	cNSZName		Nome da tabela NSZ.
	@Return	cCondicao	todas as condições referente a tabela.

	@author Felipe Bonvicini Conti
	@since 19/10/09
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD GetCondicao(aSQL, cNSZName) CLASS TJurPesquisa
	Local nI, cCondicao := " "
	Local nQtd, aAux := {}
	Local nFound := 0

	nQtd := LEN(aSQL)
	For nI := 1 to nQtd

		IF nI == 1
			aAdd(aAux, {aSQL[nI][1], aSQL[nI][2]} )
		Else
			nFound := aScan(aAux, { |aX| ALLTRIM(aX[1]) == ALLTRIM(aSQL[nI][1]) })
			If nFound > 0
				aAux[nFound][2] += " " + aSQL[nI][2] + " "
			Else
				aAdd(aAux, {aSQL[nI][1], aSQL[nI][2]})
			EndIF
		EndIF
	Next

	nQtd := LEN(aAux)
	For nI := 1 to nQtd
		IF aAux[nI][1] == cNSZName
			cCondicao += aAux[nI][2] +" "
		Else
			cCondicao += Self:GetEXISTS(aAux[nI][1], aAux[nI][2])
		EndIf
	Next

Return cCondicao

	//-------------------------------------------------------------------
	/*/{Protheus.doc} GetEXISTS(cTabela, cWhere)
	Função utilizada para montar a condição de EXISTS.
	Uso Geral.

	@Param	cTabela	Nome da tabela.
	@Param	cWhere	Condição referente a tabela.
	@Return	cExists	Condição de EXISTS.

	@author Felipe Bonvicini Conti
	@since 19/10/09
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD GetEXISTS(cTabela, cWhere) CLASS TJurPesquisa
	Local cExists := '', cCondicao := '', cCampo := '*'
	Local aEXPDOM, aEXPCDOM
	Local nI

	If !Empty(cWhere)
		SX9->(dbsetorder(2))
		IF SX9->(DBSeek(SUBSTRING(cTabela,1,3)+'NSZ'))

			aEXPDOM  := STRToArray(SX9->X9_EXPDOM, '+')
			aEXPCDOM := STRToArray(SX9->X9_EXPCDOM, '+')
			IF LEN(aEXPDOM) == LEN(aEXPCDOM)
				For nI := 1 to LEN(aEXPDOM)
					If nI > 1
						cCondicao += " AND "
					Endif
					cCondicao += aEXPDOM[nI] +" = "+ aEXPCDOM[nI]+" "
					cCampo := aEXPCDOM[nI]
				NEXT
			EndIF

			cExists := " AND EXISTS( SELECT "+cCampo+" FROM "+cTabela+" WHERE " + CRLF
			cExists += cCondicao + CRLF
			cExists += " AND "+SUBSTRING(cTabela,1,3)+"_FILIAL = NSZ_FILIAL"+ CRLF
			cExists += " AND "+cTabela+".D_E_L_E_T_ = ' ' " + CRLF
			cWhere := STRTRAN(cWhere, SUBSTRING(cTabela,1,3)+"001", cTabela)
			cExists += cWhere + ' ) '
		Else
			cExists += cWhere
		EndIf

	EndIf

Return cExists

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaSQL
Função utilizada para montar o SQL da pesquisa.
Uso Geral.

@Param	aObj	    Array com todos os campos de filtro da tela.
@Param  oCmbConfig	Combo que contém as configurações de Layout.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD MontaSQL(aObj,oCmbConfig, xFiltro) CLASS TJurPesquisa
	Local aArea := GetArea()
	Local cSQL := ''
	Local nCt := 1
	Local cTmp
	Local aManual := {}
	Local aAllCampos := Self:getAllCampos()
	Local cCampos	 := ""
	Local aTroca   := {}
	Local nTemp
	Local aHeader := Self:oLstPesq:getHeader()

	Default xFiltro = {}
	Default aObj := Self:aObj
	Default oCmbConfig := Self:oCmbConfig

	aManual := {}

	For nCt := 1 to Len(aAllCampos)
		nTemp := aScan(aHeader,{|x| x[16] == aAllCampos[nCt][1]},2)
		If nTemp == 0 .Or. aHeader[nTemp][10] <> "V" //valida se o campo é virtual.

			If Len(aAllCampos[nCt])>3 //valida se não não são campos padrões
				cTmp := IIF(aAllCampos[nCt][3]==Self:cTabPadrao,AllTrim(aAllCampos[nCt][1]),AllTrim(aAllCampos[nCt][4])+"."+AllTrim(aAllCampos[nCt][1])) + ;
					IIF(!Empty(aAllCampos[nCt][8])," "+AllTrim(aAllCampos[nCt][8]),"")
			Else
				cTmp :=  AllTrim(aAllCampos[nCt][1])
			Endif

			cCampos += cTmp + ','

			If  (Len(aAllCampos[nCt]) >= 4) .And. (Ascan(aTroca, {|x| x[1] == aAllCampos[nCt][3]}) <= 0)
				aadd(aTroca, {aAllCampos[nCt][3], aAllCampos[nCt][4]})
			EndIf
		EndIf
	Next

	If  (Ascan(aTroca, {|x| x[1] == "NSZ"}) <= 0)
		aadd(aTroca, {"NSZ", "NSZ001"})
	EndIf

	//retira a vírgula do final
	cCampos := Left(cCampos,Len(cCampos)-1)

	cSQL := Self:getSQLPesq(aObj,oCmbConfig, cCampos, aManual, aTroca, xFiltro)

	RestArea(aArea)

Return cSQL

	//-------------------------------------------------------------------
	/*/{Protheus.doc} TrocaWhere(oObj)
	Função utilizada para trocar os nomes reservado (entre ##) pelos dados.
	Uso Geral

	@Param	oObj	Objeto campo de filtro.
	@Param aCampos Array que contém campos, tabelas e o apelido que deve
	ser usado para cada tabela.
	@Return cRet	Condição do campo.

	@author Felipe Bonvicini Conti
	@since 03/11/09
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD TrocaWhere(oObj,aCampos) CLASS TJurPesquisa
	Local cRet      := oObj:GetWhere()
	Local cType     := oObj:GetTypeField()
	Local xVal      := oObj:Valor
	Local cVariavel := ""
	Local aPos      := {}
	Local cTabela   := Substring(cRet,At(".",cRet)-6,6)
	Local nTab      := 0

	Default aCampos := {}
	//Tratativa, para que se a pesquisa for pelo campo NUQ_NUMPRO, Retirar os '.','-' e ',' para a consultar retornar corretamente
	cRet := StrTran( oObj:GetWhere(), "(NUQ_NUMPRO)", " (REPLACE(REPLACE(REPLACE(NUQ_NUMPRO,'.',''),'-',''),',',''))" )

	nTab := aScan(aCampos,{ |aX| AllTrim(Upper( RetSqlName(aX[1]) )) == AllTrim(Upper(cTabela)) })
	//substitui a tabela pelo apelido
	If (nTab>0)
		cRet := StrTran(cRet,cTabela+'.',aCampos[nTab][2]+'.')
	Endif

	If ValType(xVal) == 'C'
		xVal := StrTran(xVal,"'","")
	EndIf

	// "DADO"
	If oObj:IsF3Multi()
		xVal := Trim(xVal)
		cRet := StrTran(cRet, '#'+STR0009+'#', "'"+AtoC( strtokarr(xVal, ";") , "','" )+"'") //"DADO"
	Else
		cRet := StrTran(cRet, '#'+STR0009+'#', Self:TransValor(xVal, cType)) //"DADO"
	EndIf

	// "DADO_LIKE"
	If at(STR0010,cRet) > 0
		cRet := StrTran(cRet, '#'+STR0010+'#', StrTran(JurLmpCpo( Self:TransValor(xVal, cType, .T.) ),'#','')) //"DADO_LIKE"
	Endif

	// "DADO_GRUPO"
	If at(STR0011,cRet) > 0
		cRet := StrTran(cRet, '#'+STR0011+'#', Self:GetGrupos(xVal)) //"DADO_GRUPO"
	Endif

	// "DADO_GRUPOEMP"
	If at(STR0012,cRet) > 0
		cRet := StrTran(cRet, '#'+STR0012+'#', Self:JGEmpr(xVal)) //"DADO_GRUPOEMP"
	Endif

	aPos := JurAtAll("#", cRet)
	If LEN(aPos)%2 = 0

		While Len(aPos) > 0

			If SubString(cRet, aPos[1], 1) == '#' .And. SubString(cRet, aPos[2], 1) == '#'
				cVariavel := SubString(cRet, aPos[1]+1, aPos[2]-aPos[1]-1)
				If cVariavel == SubString(cVariavel, 1, At('_', cVariavel))+'FILIAL'
					cRet := StrTran(cRet, '#'+cVariavel+'#', Self:TransValor(xFILIAL(cVariavel), 'C') )
				Else
					cRet := StrTran(cRet, '#'+cVariavel+'#', Self:TransValor( M->&(cVariavel), ValType(M->&(cVariavel)) ))
				EndIf
			EndIf
			aPos := JurAtAll("#", cRet)

		End

	Else
		Alert(STR0007+oObj:GetNameField()+STR0008) // "Montagem da clausula do campo " e " esta incorreta!(Falta #)"
	EndIf

Return cRet

	//-------------------------------------------------------------------
	/*/{Protheus.doc} TransValor(Valor, cTipo)
	Função utilizada para transformar o valor em string para que seja
	possível montar a Query.
	Uso Geral.

	@Param	Valor	Valor.
	@Param	cTipo	Tipo do do valor.
	@Return	cRet	Valor da convertida para ser rodada na Query.

	@author Felipe Bonvicini Conti
	@since 19/10/09
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD TransValor(Valor, cTipo, cAspas) CLASS TJurPesquisa
	Local cRet := ''

	Default cAspas := .F.

	Do case
	Case cTipo == 'D'
		cRet := CHR(39)+AllTrim(DToS(Valor))+CHR(39)
	Case cTipo == 'N'
		cRet := AllTrim(STR(Valor))
	Case cTipo == 'C' .Or. cTipo == 'M'
		if cAspas
			IIF(!Empty(Valor), cRet := AllTrim(Valor), cRet := Valor )
		Else
			IIF(!Empty(Valor), cRet := CHR(39)+AllTrim(Valor)+CHR(39), cRet := CHR(39)+Valor+CHR(39) )
		Endif
	EndCase

Return cRet

	//-------------------------------------------------------------------
	/*/{Protheus.doc} GetGrupos(cCodPai)
	Função utilizada para retornar os grupos relacionado ao grupo informado.
	Uso Geral

	@Param	cCodPai	Codigo do grupo pai.
	@Return String	Contem todos os codigos de grupos relacionado.

	@author Felipe Bonvicini Conti
	@since 03/11/09
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD GetGrupos(cCodPai) CLASS TJurPesquisa
	Local aCods := {}

	ACY->(DBSetOrder(2))
	ACY->(dbGoTop())

	While !ACY->(EOF())
		aAdd(aCods, {ACY->ACY_GRPVEN, ACY->ACY_GRPSUP})
		ACY->(dbSkip())
	End

	ACY->(dbCloseArea())

	aSort(aCods, , , {|x,y| x[2] < y[2]})

Return "("+Self:GetRelaGrupos(aCods, cCodPai)+")"

	//-------------------------------------------------------------------
	/*/{Protheus.doc} GetRelaGrupos(aTDCods, cCod)
	Função recursiva utilizada para buscar todos os grupos relacionados ao grupo pai.
	Uso Geral

	@Param	aTDCods		Todos os grupos da tabela ACY.
	@Param	cCod			Codigo do grupo q será buscado o relacionamento.
	@Return cRet			Codigos dos grupos relacionados.

	@author Felipe Bonvicini Conti
	@since 03/11/09
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD GetRelaGrupos(aTDCods, cCod) CLASS TJurPesquisa
	Local cRet := "'"+cValToChar(cCod)+"'"
	Local nTd

	For nTd := 1 to LEN(aTDCods)

		If cValToChar(aTDCods[nTd][2]) == cValToChar(cCod)
			cRet += ", "+Self:GetRelaGrupos(aTDCods, aTDCods[nTd][1])
		EndIf

	Next

Return cRet

	//-------------------------------------------------------------------
	/*/{Protheus.doc} JA162GEmpr(cCodPai)
	Função utilizada para retornar os grupos de empresa relacionados ao grupo
	informado.
	Uso Geral

	@Param	cCodPai	Codigo do grupo pai.
	@Return String	Contem todos os codigos de grupos relacionado.

	@author Juliana Iwayama Velho
	@since 17/03/10
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD JGEmpr(cCodPai) CLASS TJurPesquisa
	Local aArea := GetArea()
	Local aCods := {}

	NST->(DBSetOrder(3))
	NST->(dbGoTop())

	While !NST->(EOF())
		aAdd(aCods, {NST->NST_COD, NST->NST_CEMPM})
		NST->(dbSkip())
	End

	NST->(dbCloseArea())

	aSort(aCods, , , {|x,y| x[2] < y[2]})

	RestArea(aArea)

Return "("+Self:GetRelaGrupos(aCods, cCodPai)+")"

	//-------------------------------------------------------------------
	/*/{Protheus.doc} getPosCmp(cCampo)
	Função utilizada para retornar a posição do campo do array de campos
	montado com todos os campos do grid
	Uso Geral.

	@Param		cCampo Nome do campo
	@Return	nRet	Posição do mesmo no Array

	@author André Spirigoni Pinto
	@since 10/11/13
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD getPosCmp(cCampo) CLASS TJurPesquisa
	Local nRet := 0
	Local aTemp := Self:getAllCampos()

	nRet := aScan(aTemp,{|aX| AllTrim(aX[1]) == AllTrim(cCampo)}) + 1 //Desconsidera a legenda

Return nRet

	//-------------------------------------------------------------------
	/*/{Protheus.doc} setMenuPadrao()
	Função que monta o menu lateral principal com informações padrão.

	Estrutura dos arrays que possui a estrutura:
	Ex: aAcoes {"Título","Ação"}

	@author André Spirigoni Pinto
	@since 29/01/15
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD setMenuPadrao(oMenu, aAcoes, aOpera, aRelat, aEspec, cRotina) CLASS TJurPesquisa
	Local oMenuItem
	Local cMenuItem
	Local nCt
	Local aRelEnt := {}
	Local aJPesqOut := {}

	Default aEspec  := {}
	Default aAcoes  := Nil
	Default aOpera  := Nil
	Default cRotina := ""

	//opções padrão
	If aOpera == Nil
		aOpera := {}
		aAdd(aOpera, {STR0013,{|| IIF(Self:befAction(),Self:JA162Menu(1,Self:oLstPesq,,Self:oCmbConfig),)},{|| ((Self:cGrpRest $ 'CORRESPONDENTES/CLIENTES/MATRIZ' .And. JA162AcRst(cRotina, 2)) .Or. Empty(Self:cGrpRest)) }}) //"Visualizar"
		aAdd(aOpera, {STR0014,{|| Self:JA162Menu(3,Self:oLstPesq,Self:aObj,Self:oCmbConfig)}, {|| ((Self:cGrpRest $ 'CORRESPONDENTES/CLIENTES/MATRIZ' .And. JA162AcRst(cRotina, 3)) .Or. Empty(Self:cGrpRest))},K_ALT_I }) //"Incluir"//incluido parâmetro de tecla de atalho
		aAdd(aOpera, {STR0015,{|| IIF(Self:befAction(), ( Self:JA162Menu(4,Self:oLstPesq,Self:aObj,Self:oCmbConfig) ),)}, {|| ((Self:cGrpRest $ 'CORRESPONDENTES/CLIENTES/MATRIZ' .And. JA162AcRst(cRotina, 4)) .Or. Empty(Self:cGrpRest))},K_ALT_A }) //"Alterar"//incluido parâmetro de tecla de atalho
		aAdd(aOpera, {STR0016,{|| IIF(Self:befAction(),Self:JA162Menu(5,Self:oLstPesq,Self:aObj,Self:oCmbConfig),)}, {|| ((Self:cGrpRest $ 'CORRESPONDENTES/CLIENTES/MATRIZ' .And. JA162AcRst(cRotina, 5)) .Or. Empty(Self:cGrpRest)) },K_ALT_E }) //"Excluir"//incluido parâmetro de tecla de atalho
	EndIf

	//Menu alteração em lote.
	If (aScan(JurGetMethods(Self),{|x| x[1] == "OPALTLOTE"}) > 0 .And. aScan(aOpera,{|x| At("lote",x[1]) > 0}) == 0 )
		If aOpera == Nil
			aOpera := {}
		EndIf
		aAdd(aOpera, {STR0017,{|| IIF(Self:befAction(),(Self:JAltLote(),Self:Pesquisar(Self:aObj, Self:oLstPesq, ,Self:oCmbConfig)),)}, {|| (Self:JHabLote() .AND. ((Self:cGrpRest $ 'CORRESPONDENTES/CLIENTES/MATRIZ' .And. JA162AcRst('18', 3)) .Or. Empty(Self:cGrpRest))) } }) //"Alteração em Lote"
	Endif

	//opções padrão
	if aAcoes == Nil
		aAcoes := {}
		aAdd(aAcoes,{STR0018,{|| Self:Pesquisar(Self:aObj, Self:oLstPesq, ,Self:oCmbConfig)},K_ALT_P}) //"Pesquisar"
		aAdd(aAcoes,{STR0019,{|| Self:LimpaPesq(Self:aObj)} }) //"Limpar"
	endif

	cMenuItem := oMenu:AddContent(STR0020, "E", "" )	// "Assuntos Jurídicos"

	cMenuItem := oMenu:AddContent(STR0080, "E", { || Self:confLayout() } )	// "Configurar"

	cMenuItem := oMenu:AddFolder(STR0021, "E" ) //"Ações"
	oMenuItem := oMenu:GetItem( cMenuItem )

	For nCt := 1 to len(aAcoes)
		cMenuItem := oMenuItem:AddContent(aAcoes[nCt][1], "E", aAcoes[nCt][2])
	Next

	For nCt := 1 to len(aAcoes)
		If (len(aAcoes[nCt]) > 2)
			aAdd(Self:aTecAtalho,{aAcoes[nCt][3], {|| Self:Pesquisar(Self:aObj, Self:oLstPesq, ,Self:oCmbConfig)}})
			SetKEY(K_ALT_P,{|| Self:Pesquisar(Self:aObj, Self:oLstPesq, ,Self:oCmbConfig)})//Tecla de atalho do botão pesquisar
		EndIf
	Next nCt

	//Padrão - Sair
	cMenuItem := oMenuItem:AddContent( STR0022, "E", {|| Self:Sair()} )	// "Sair"

	oMenu:AddSeparator()

	cMenuItem := oMenu:AddFolder( STR0023, "E" ) //"Operações"
	oMenuItem := oMenu:GetItem( cMenuItem )

	For nCt := 1 to len(aOpera)
		cMenuItem := oMenuItem:AddContent(aOpera[nCt][1], "E", aOpera[nCt][2])
		If (len(aOpera[nCt]) > 2) //valida se existem restrições
			if (!Empty(aOpera[nCt][3]))
				If len (aOpera[nCt]) > 3
					aAdd(Self:aRestMenu,{cMenuItem,aOpera[nCt][3],aOpera[nCt][2],aOpera[nCt][4]})
				Else
					aAdd(Self:aRestMenu,{cMenuItem,aOpera[nCt][3]})
				EndIf
			Endif
		endif
	neXT

	aAdd(aEspec,{})
	aIns(aEspec,1)

	aEspec[1] := {STR0094/*'Anexos'*/,{|| IIF(Self:befAction(),self:menuAnexos(),)}, {|| (JA162AcRst('03')) } }

	If len(aEspec) > 0
		oMenu:AddSeparator()

		cMenuItem := oMenu:AddFolder( STR0024, "E" ) //"Outros"
		oMenuItem := oMenu:GetItem( cMenuItem )

		If ExistBlock("JPESQOUT")  // Ponto de Entrada incluido no Menu Outros da area de trabalho
			aAdd(aJPesqOut,{ {|| Self:getFilial()} }) 	//-- Filial do Processo
			aAdd(aJPesqOut,{ {|| self:getCajuri()} })	//-- Cajuri
			aAdd(aJPesqOut,{ {|| Self:cTabPadrao } })	//-- Tabela filha de NSZ
			aAdd(aJPesqOut,{ {|| Self:getFilial() + Self:getCodigo() } })	//-- Filial + Código da tabela filha de NSZ
			aAdd(aJPesqOut,{ aEspec })
			aRelEnt := ExecBlock("JPESQOUT", .F.,.F.,aJPesqOut)

			If Valtype(aRelEnt) == "A"´
				//Substitui o menu padrão pelo menou customizado
				aEspec := {}
				aEval(aRelEnt,{|aX|aAdd(aEspec,aX)})
			EndIf

		EndIf

		For nCt := 1 to len(aEspec)
			cMenuItem := oMenuItem:AddContent(aEspec[nCt][1], "E", aEspec[nCt][2])
			If (len(aEspec[nCt]) > 2) //valida se existem restrições
				aAdd(Self:aRestMenu,{cMenuItem,aEspec[nCt][3]})
			EndIf
		Next
	EndIf

	oMenu:AddSeparator()

	cMenuItem := oMenu:AddFolder( STR0025, "E" ) //"Relatórios"
	oMenuItem := oMenu:GetItem( cMenuItem )

	If ExistBlock("JUATREL1")  // Ponto de Entrada incluido no Menu do Relatorio da area de trabalho
		aRelEnt := ExecBlock("JUATREL1", .F.,.F.)

		If Valtype(aRelEnt) == "A"
			aEval(aRelEnt,{|aX|aAdd(aRelat,aX)})
		EndIf

	EndIf

	For nCt := 1 to len(aRelat)
		cMenuItem := oMenuItem:AddContent(aRelat[nCt][1], "E", aRelat[nCt][2])
		if (len(aRelat[nCt]) > 2) //valida se existem restrições
			aAdd(Self:aRestMenu,{cMenuItem,aRelat[nCt][3]})
		endif
	Next

	//Padrão
	cMenuItem := oMenuItem:AddContent( STR0026, "E", {|| Self:fillGrid(), Self:oLstPesq:Report()} )		//"Exportar Resultados"

	cMenuItem := oMenuItem:AddContent( STR0085, "E", {|| IIF(Self:befAction(),JURA108(Self,Self:getTipoAs(), Self:getFiltro(),.F. /*lFila*/),)} )		//"Exportação Personalizada"
	aAdd(Self:aRestMenu,{cMenuItem,{|| Self:oFila == Nil .And. JA162AcRst('12', 2)}}) //restrição exportação personalizada
	If Findfunction('FWLibVersion') .And. FWLibVersion() < "20200214"
		//Adicionados itens em branco para ativar a barra de rolagem
		oMenuItem:AddContent( "", "E", "" )
		oMenuItem:AddContent( "", "E", "" )
		oMenuItem:AddContent( "", "E", "" )
		oMenuItem:AddContent( "", "E", "" )
		oMenuItem:AddContent( "", "E", "" )
		oMenuItem:AddContent( "", "E", "" )
		oMenuItem:AddContent( "", "E", "" )
		oMenuItem:AddContent( "", "E", "" )
		oMenuItem:AddContent( "", "E", "" )
		oMenuItem:AddContent( "", "E", "" )
		oMenuItem:AddContent( "", "E", "" )
		oMenuItem:AddContent( "", "E", "" )
		oMenuItem:AddContent( "", "E", "" )
		oMenuItem:AddContent( "", "E", "" )
		oMenuItem:AddContent( "", "E", "" )
		oMenuItem:AddContent( "", "E", "" )
		oMenuItem:AddContent( "", "E", "" )
		oMenuItem:AddContent( "", "E", "" )
		oMenuItem:AddContent( "", "E", "" )
		oMenuItem:AddContent( "", "E", "" )
		oMenuItem:AddContent( "", "E", "" )
		oMenuItem:AddContent( "", "E", "" )
	EndIf

Return oMenu

	//-------------------------------------------------------------------
	/*/{Protheus.doc} LimpaPesq(aObj)
	Função utilizada para limpar todos os campos de filtro e voltar o
	valor padrão se tiver.
	Uso Geral.

	@Param	aObj			Array que contem todos os campo de filtro.

	@author Felipe Bonvicini Conti
	@since 19/10/09
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD LimpaPesq(aObj) CLASS TJurPesquisa
	Local nI

	For nI := 1 to LEN(aObj)
		If !(aObj[nI] == NIL)
			aObj[nI]:Limpar()
			M->&(aObj[nI]:cNomeCampo) := aObj[nI]:Valor
			If aObj[nI]:IsF3Multi()
				aObj[nI]:Valor := PADL(" ", 200)
			EndIf
		EndIf
	Next nI

Return NIL

//---------------------------------------------------------------------------
/*/{Protheus.doc} JAltLote

Funcao que realiza a chamada da rotina de inclusao de atividades

@param dDate - Dia da atividade
cTimeIni - Hora inicial da atividade
cTimeFim - Hora final da atividade

@author	André Spirigoni Pinto
@since		26/01/2015
/*/
//---------------------------------------------------------------------------
METHOD JAltLote() CLASS TJurPesquisa
Local oDlgLote   := Nil
Local aObjAux    := {}
Local nPos       := 0
Local nPos1      := 0
Local aPOS       := {}
Local aPosTela   := {}
Local aPosTela1  := {}
Local oDesc      := Nil
Local nI         := 0
Local nJ         := 0
Local aExcecao   := Self:getExcecaoLote()
Local aComplCpo  := Self:getComplLote()
Local aImpedAlt  := {}
Local aImpedAux  := {}
Local aCampDe    := {}
Local cNome      := ""
Local cNomeCompl := ""
Local cNomeExce  := ""
Local oSplPesqC  := Nil
Local oPnlScrA   := Nil
Local oPnlCposAb := Nil
Local oSplPesqD  := Nil
Local oPnlScrB   := Nil
Local oPnlCposAc := Nil
Local lFiltro    := .F.
Local cPesq      := Self:JGetPesq()
Local cMsgErro   := STR0028 //"Preencha os campos que deverão ser alterados:"
Local cStyle     := "QFrame{ background-color:#FFFFFF }"
Local cAlias     := GetNextAlias()
Local cSQL       := Self:MontaSQL()
Local nOrderBy   := AT('ORDER BY', cSQL)-1
Local nQtdReg    := 0
Local oMessage   := Nil
Local oFont      := TFont():New("Arial",,14,,.T.,,,,,.T.)
Local nPosCpo    := 0
Local cLabelCpo  := ""
Local nHeight    := 0
Local aObjOld    := {}

Private lAbortPrint := .F. //Indica se a operação foi cancelada. Usada para controlar a opção de cancelar da funcionalidade PROCESSA

	If nOrderBy > 0
		cSQL  := SUBSTR(cSQL, 1, nOrderBy) 
	EndIf

	cSQL :="SELECT COUNT(1) QTDREG FROM (" + cSQL + ") CONTAGEM"
	cSQL := ChangeQuery(cSQL)
	
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAlias, .T., .F.)
		nQtdReg := (cAlias)->QTDREG
	(cAlias)->( dbcloseArea() )

	If nQtdReg > 0

		If Existblock( 'J162NALT' )
			aImpedAux := Execblock('J162NALT', .F., .F., {cPesq})

			If ( !Empty(aImpedAux) .And. Valtype( aImpedAux ) == 'A' .And. Len(aImpedAux) >= 1 )
				For nI := 1 to Len(aImpedAux)
					aAdd(aImpedAlt,{aImpedAux[nI][1]})
				Next nI
			EndIf

		EndIf

		oDlgLote := MSDialog():New(0,0,400,567,STR0027,,,,,CLR_BLACK,CLR_WHITE,,,.T.) //"Alteração em lote"

		oFWLayer := FWLayer():New()
		oFWLayer:Init(oDlgLote, .F., .F.)

		// Painel Superior
		oFWLayer:AddLine('ACIMA', 40, .F.)
		oFWLayer:AddCollumn('ALL', 100, .T., 'ACIMA')
		oPnlACima := oFWLayer:GetColPanel( 'ALL', 'ACIMA' )
		oPnlACima:Align := CONTROL_ALIGN_ALLCLIENT
		oPnlACima:nCLRPANE := RGB(255,255,255)

		oPnlCposAc          := tPanel():New(0,0,'',oPnlACima,,,,,,60,15)
		oPnlCposAc:Align    := CONTROL_ALIGN_TOP
		oPnlCposAc:nCLRPANE := RGB(255,255,255)

		oSplPesqD          := TScrollArea():New(oPnlACima,0,0,oPnlACima:nHeight-oPnlCposAc:nHeight,oPnlACima:nWidth,.T.,.T.,.T.)
		oSplPesqD:Align    := CONTROL_ALIGN_ALLCLIENT
		oSplPesqD:nCLRPANE := RGB(255,255,255)
		oSplPesqD:ReadClientCoors(.T.,.T.)

		oPnlScrB := tPanelCSS():New(0,0,'',oSplPesqD,,,,,,0,0)
		oSplPesqD:SetFrame( oPnlScrB )
		oPnlScrB:setCSS(cStyle)
		oPnlScrB:nWidth   := oPnlACima:nWidth
		oPnlScrB:nHeight  := oPnlACima:nHeight-oPnlCposAc:nHeight
		oPnlScrB:ReadClientCoors(.T.,.T.)

		oDesc := TSay():New(5,5,{|| STR0028 },oPnlCposAc,,oFont,,,,.T.,,,200,20) //"Preencha os campos que deverão ser alterados"

		// Painel Inferior
		oFWLayer:AddLine('ABAIXO', 45, .F. )
		oFWLayer:AddCollumn('ALL' , 100, .T., 'ABAIXO')
		oPanelABaixo          := oFWLayer:GetColPanel('ALL' , 'ABAIXO')
		oPanelABaixo:Align    := CONTROL_ALIGN_ALLCLIENT
		oPanelABaixo:nCLRPANE := RGB(255,255,255)

		oPnlCposAb          := tPanel():New(0,0,'',oPanelABaixo,,,,,,60,15)
		oPnlCposAb:Align    := CONTROL_ALIGN_TOP
		oPnlCposAb:nCLRPANE := RGB(255,255,255)

		oSplPesqC          := TScrollArea():New(oPanelABaixo,0,0,oPanelABaixo:nHeight-oPnlCposAb:nHeight,oPanelABaixo:nWidth,.T.,.T.,.T.)
		oSplPesqC:Align    := CONTROL_ALIGN_ALLCLIENT
		oSplPesqC:nCLRPANE := RGB(255,255,255)
		oSplPesqC:ReadClientCoors(.T.,.T.)

		oPnlScrA := tPanelCSS():New(0,0,'',oSplPesqC,,,,,,0,0)
		oSplPesqC:SetFrame( oPnlScrA )
		oPnlScrA:setCSS(cStyle)
		oPnlScrA:nWidth  := oPanelABaixo:nWidth
		oPnlScrA:nHeight := oPanelABaixo:nHeight-oPnlCposAb:nHeight
		oPnlScrA:ReadClientCoors(.T.,.T.)

		oDesc := TSay():New(5,5,{|| STR0097 },oPnlCposAb,,oFont,,,,.T.,,,200,20)

		// Painel Cabeçalho
		oFWLayer:AddLine('ROD', 10, .F.)
		oFWLayer:AddCollumn('ALL', 100, .T., 'ROD')
		oPnlRod := oFWLayer:GetColPanel( 'ALL', 'ROD' )

		oPnlScrB:nHeight := 0

		For nI := 1 to LEN(Self:aObj)
			cNome := Self:aObj[nI]:cNomeCampo
			If !Empty(Self:aObj[nI]:Valor)
				lFiltro := .T.

				//valida a tabela e se a operação é de igualdade ou contem no caso de  Alteração de campos de multipla pesquisa
				If ( (LEFT(Self:aObj[nI]:cNomeTab,3) == Self:cTabPadrao .OR. ;
						( Self:cTabPadrao == 'NTA' .AND. Alltrim(cNome) == 'NTE_SIGLA')) .And.;
						( At(" = ",Self:aObj[nI]:cWhere) > 0 .Or. At("IN",Self:aObj[nI]:cWhere) > 0) .And.;
						!Empty(Self:aObj[nI]:Valor) ) .And. ;
						!(AllTrim(cNome) $ StrTran(AllTrim(InfoSX2(Self:cTabPadrao,'X2_UNICO') ),"+","/"))

					If Ascan(aImpedAlt, {|x| AllTrim(x[1]) == AllTrim(cNome) } ) == 0
						//Verifica se o campo ja foi incluido
						If Ascan(aCampDe, {|x| AllTrim(x[1]) == AllTrim(cNome) } ) == 0

							// Insere Campos "Antes"
							aAdd(aObjOld, '')
							nPos := (LEN(aObjOld) + LEN(aObjAux) + 1)
							aPOS := Self:PosTela(@aPosTela,nPos,Int(oPnlScrB:nWidth/130))
							nPosCpo :=Iif(aPOS[2] > 5, aPOS[2] + 20,aPOS[2])
							nHeight :=Iif(nPosCpo = 5, nHeight := nHeight + 60, nHeight)
							// Seta Label
							cLabelCpo := AllTrim(subStr(Self:aObj[nI]:aDadosCpoNVH[3],1,14))
							oDesc := TSay():New(aPOS[1],nPosCpo,{|| '' },oPnlScrB,,/*oFont*/,,,,.T.,,,60,20)
							oDesc:SetText(cLabelCpo + STR0101) 
							// Seta Valor
							oDesc:= TSay():New(aPOS[1]+10,nPosCpo,{|| '' },oPnlScrB,,oFont,,,,.T.,,RGB(224,229,234),60,8)						 
							oDesc:SetText(AllTrim(AllToChar(Self:aObj[nI]:VALOR)))

							// Insere Campos "Depois"
							nPos := (LEN(aObjOld) + LEN(aObjAux) + 1)
							aPOS := Self:PosTela(@aPosTela,nPos,Int(oPnlScrB:nWidth/130))
							nPosCpo := Iif(aPOS[2] > 65, aPOS[2] + 30, aPOS[2] +10)

							aAdd(aObjAux, TJurPnlCampo():New(;
								aPOS[1],; //nRow
								nPosCpo,; //nCol
								65,; //nWidth
								22,; //nHeight
								oPnlScrB,; //oWnd
								cLabelCpo + STR0102,; //'Depois'
								Self:aObj[nI]:aDadosCpoNVH[2],; //cCodCampo
								{|| },; //bGotFocus
								{|| },;//bLostFocus
								,;// xSugestao
								,) ) // lVisible, lEnable, cF3, nAlign, cListItens, lAltLote, lCboxEmpty, lObfuscate

							aAdd(aCampDe,{cNome,Self:aObj[nI]:Valor})

							aObjAux[Len(aObjAux)]:SetbF3(.T.)
						EndIf

						If len(aComplCpo) > 0 .And. (nCpl := aScan(aComplCpo,{|x| AllTrim(x[1]) == AllTrim(cNome)})) > 0
							For nJ := 1 to LEN(aComplCpo[nCpl][2])

								If aScan(Self:aObj, {|x| Self:aObj[nI]:cNomeCampo == "NSZ_SITUAC"}) > 0
									If Self:aObj[nI]:valor == "2"
										If aScan(aComplCpo[nCpl][2], {|ax| ax == "NSZ_CMOENC" } ) > 0 .AND. aScan(aComplCpo[nCpl][2], {|ax| ax == "NSZ_DETENC" } ) > 0
											aComplCpo[nCpl][2][aScan(aComplCpo[nCpl][2], {|ax| ax == "NSZ_CMOENC" } )] := nil
											aComplCpo[nCpl][2][aScan(aComplCpo[nCpl][2], {|ax| ax == "NSZ_DETENC" } )] := nil
										EndIf
									ElseIf Self:aObj[nI]:valor == "1"
										If aScan(aComplCpo[nCpl][2], {|ax| ax == "NUV_CMOTIV" } ) > 0 .AND. aScan(aComplCpo[nCpl][2], {|ax| ax == "NUV_JUSTIF" } ) > 0
											aComplCpo[nCpl][2][aScan(aComplCpo[nCpl][2], {|ax| ax == "NUV_CMOTIV" } )] := nil
											aComplCpo[nCpl][2][aScan(aComplCpo[nCpl][2], {|ax| ax == "NUV_JUSTIF" } )] := nil
										EndIf
									EndIf
								EndIf

								cNomeCompl := aComplCpo[nCpl][2][nJ]

								If cNomeCompl != nil
									//Verifica se o campo ja foi incluido
									If Ascan(aCampDe, {|x| AllTrim(x[1]) == AllTrim(cNomeCompl) } ) == 0

										nPos := LEN(aObjAux)+1
										nPos1:= nPos - LEN(aObjAux)
										aPOS := Self:PosTela(@aPosTela1,nPos1,Int(oPnlScrA:nWidth/130))

										aAdd(aObjAux, TJurPnlCampo():New(aPOS[1],aPOS[2],aComplCpo[nCpl][3][nJ],aComplCpo[nCpl][4][nJ],oPnlScrA,RetTitle(cNomeCompl),cNomeCompl,;
											{|| },;
											{|| },,,) )

										aAdd(aCampDe,{cNomeCompl,Space(TamSx3(cNomeCompl)[1]) })

										aObjAux[nPos]:SetbF3(.T.)
									EndIf
								Endif
							Next
						EndIf
						//Ajusta o tamanho (Height) da janelala de campos
						If (oPnlScrA:nHeight < Round(oPnlScrA:nWidth/130,0) * 32.4)
							oPnlScrA:nHeight  := Round(oPnlScrA:nWidth/130,0) * 32.4
						EndIf

					EndIf

				Else
					//Define as mensagens de erro
					Do Case
					Case LEFT(Self:aObj[nI]:cNomeTab,3) <> Self:cTabPadrao
						cMsgErro := I18N(STR0090, {Self:cTabPadrao})	//"Apenas campos da tabela #1 podem ser alterados em lote."

					OTherWise
						cMsgErro := STR0028								//"Preencha os campos que deverão ser alterados:"
					End Case
				EndIf
			EndIf

		Next

		//Insere campos de Excecao independente de estar na pesquisa ou nao
		If Len(aCampDe) > 0 .or. lFiltro

			For nI:=1 To Len(aExcecao)

				cNomeExce := aExcecao[nI]

				//Verifica se o campo pode ser alterado
				If Ascan(aImpedAlt, {|x| AllTrim(x[1]) == AllTrim(cNomeExce) } ) == 0
					//Verifica se o campo ja foi incluido
					If Ascan(aCampDe, {|x| AllTrim(x[1]) == AllTrim(cNomeExce) } ) == 0

						// Insere Campos "Antes"
						aAdd(aObjOld, '')
						nPosField := Ascan(Self:aObj, {|x| AllTrim(x:cNomeCampo) == AllTrim(cNomeExce) } )
						nPos := (LEN(aObjOld) + LEN(aObjAux) + 1)
						aPOS := Self:PosTela(@aPosTela, nPos, Int(oPnlScrB:nWidth / 130) )
						nPosCpo := Iif(aPOS[2] > 5 , aPOS[2] + 20,aPOS[2])
						nHeight :=Iif(nPosCpo = 5, nHeight := nHeight + 60, nHeight)

						// Seta Label
						oDesc := TSay():New(aPOS[1],nPosCpo,{|| '' },oPnlScrB,,/*oFont*/,,,,.T.,,,60,20)
						oDesc:SetText(AllTrim(RetTitle(cNomeExce)) + STR0101) 
						// Seta Valor
						oDesc:= TSay():New(aPOS[1]+10,nPosCpo,{|| '' },oPnlScrB,,oFont,,,,.T.,,RGB(224,229,234),60,8)						 
						oDesc:SetText(AllTrim(AllToChar(Self:aObj[nPosField]:Valor)))

						nPos := LEN(aObjAux)+1
						aPOS := Self:PosTela(@aPosTela,nPos,Int(oPnlScrB:nWidth/130))
						nPosCpo := Iif(aPOS[2] > 65, aPOS[2] + 30, aPOS[2] +10)

						Aadd(aObjAux, TJurPnlCampo():New(;
							aPOS[1],;
							nPosCpo,;
							65,;
							22,;
							oPnlScrB,;
							AllTrim(RetTitle(cNomeExce))  + STR0102,; //"Depois"
							cNomeExce,;
							{|| },;
							{|| },;
							,;
							,;
							.T.) )

						Aadd(aCampDe, {cNomeExce, Space( TamSx3(cNomeExce)[1] ) } )

						aObjAux[Len(aObjAux)]:SetbF3(.T.)
					EndIf
				EndIf
			Next nI
		EndIf

		//Ajusta o tamanho (Height) da janelala de campos
		If (nHeight  < oPnlACima:nHeight-oPnlCposAc:nHeight)
			oPnlScrB:nHeight  := oPnlACima:nHeight-oPnlCposAc:nHeight
		Else
			oPnlScrB:nHeight  := nHeight
		Endif

		oMessage := TSay():New(5,5,{|| I18N(STR0100, {cValToChar(nQtdReg)}) },oPnlRod,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20) //"Atenção, ao confirmar a operação, serão alterados #1 registros!."

		// Botões de Ações   
		DEFINE SBUTTON FROM 5,225 TYPE 1 ENABLE OF oPnlRod ;
			ACTION ( Iif(ConfAltLot(nQtdReg) .And. Self:VlAltLote(aObjAux,aCampDe),;
						(Processa({|| Self:OpAltLote(aObjAux,aCampDe)}),;
						oDlgLote:End()),))//OK

		DEFINE SBUTTON FROM 5,255 TYPE 2 ENABLE OF oPnlRod ;
			ACTION (oDlgLote:End())//CANCELA

		If len(aObjAux)>0
			oDlgLote:Activate( , , , , , , ) //ativa a janela apenas se tiverem campos na mesma.
		Else
			oDlgLote:End()
			JurMsgErro(cMsgErro, "JAltLote")
		Endif

		lPesquisa := .T.

	Endif

	aSize(aExcecao,0)
	aSize(aComplCpo,0)
	FWFreeObj(oFont)
	aExcecao := Nil
	aComplCpo := Nil
	oFont := Nil

Return 

//---------------------------------------------------------------------------
/*/{Protheus.doc} getExcecaoLote

Função que retorna execção de tabelas que devem aparecer na alteração em lote

@param		aCampos

@author	André Spirigoni Pinto
@since		09/02/2015
/*/
//---------------------------------------------------------------------------
METHOD getExcecaoLote() CLASS TJurPesquisa
Return {}

//-------------------------------------------------------------------
/*/{Protheus.doc} JurProc
Função genérica para criação do oModel com os campos correpondentes
ao tipo de assunto jurídico, follow up ou garantia.
Uso Geral.
@param  cCod    	    Código do assunto jurídico / follow up /garantia
@param  nOper   	    Código da operação do Protheus
@Param	 aObj 		    Array com os Objetos de campos de filtro.
@Param	 oLstPesq	  Grid.
@Param  oCmbConfig	Combo que contém as configurações de Layout.
@Param  cRotina    	Nome da Rotina que será aberta

@author Clóvis Teixeira
@since 02/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD JurProc(cFil,cCod,cCajur,nOper, nTela, oModel, lModelo, lFecha, lFazPesquisa) CLASS TJurPesquisa
	Local lRet	 := .F.
	Local nRet	 := 1
	Local cMsg	 := ""

	Default nTela := 0
	Default oModel := Nil
	Default lFecha	:= .F.
	Default lFazPesquisa := .T. // Usado na rotina de Follow-up. Indica se realiza a pesquisa após o Fup ser alterado e houver confirmação (essa alteração dita é quando o Fup é reaberto em modo de alteração após a inclusão) e a tela for fechada.

	//Veriaveis agora sao declaradas no JURA162
	cTipoAJ	:= IIF(nOper == 3 .And. Self:oCmbConfig <> NIL, JurSetTAS(.T.), '')
	cTipoAsJ:= ""

	lPesquisa       := .F.

	Self:JA162SetTAJ(cTipoAJ)

	//Volta ao default da variavel static lF3AssuJu do JURA095
	Ja095F3Asj( .F. )

	//Valida se existe operação e se foi selecionado algum assunto jurídico caso exista mais de um assunto jurídico vinculado a pesquisa.
	//Caso o usuário clique em cancelar, nada é executado.
	If (!Empty(cTipoAJ) .Or. nOper !=3) .And. !Empty(nOper)

		Do case
		Case nOper == 3
			cMsg := STR0014 //Incluir
		Case nOper == 4
			cMsg := STR0015 //Alterar
		Case nOper == 5
			cMsg := STR0016 //Excluir
		Otherwise
			cMsg := STR0013 //"Visualizar"
		End Case

		Self:JTecAtalho(/*lSetAtalho*/.F.) //Limpa as teclas de atalho

		nRet := Self:LoadRotina(cFil,cCod,cCajur,nOper, cMsg, nTela, oModel, lModelo, lFecha, lFazPesquisa)

		Self:JTecAtalho(/*lSetAtalho*/.T.) //Seta as teclas de atalho

		lPesquisa := .T.

		If nRet==0
			lRet:=.T.
		Else
			lRet:=.F.
		Endif

	Endif

	//Volta ao default da variavel static lF3AssuJu do JURA095
	Ja095F3Asj( .F. )

Return lRet

	//-------------------------------------------------------------------
	/*/{Protheus.doc} GetLegGaran(cGaran, cCajuri)
	Função utilizada para retornar a cor se tiver anexo ou não.
	Uso Geral.

	@Param	cGaran		Código da Garantia.
	@Return	cImagem		Nome do BMP da cor.

	@author Jorge Luis Branco Martins Junior
	@since 24/01/12
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD getLegAnexo(cCodigo, cCajuri) CLASS TJurPesquisa
	Local cImagem
	Local cAnexo := ''
	Local cParam := AllTrim( SuperGetMv('MV_JDOCUME',,'1'))
	Local lJurChave := IIF(self:cTabPadrao $ 'NT2/NT3',.T.,.F.) //indica se o cajuri faz parte da chave única

	If cParam $ '1/3' //se for fluig ou worksite
		If !EMPTY(JurGetDados( 'NUM', 3, XFILIAL('NUM') + Self:cTabPadrao + cCajuri+cCodigo, 'NUM_DOC'))
			cAnexo := '01'
		Else
			cAnexo := '02'
		Endif
	Else
		If !EMPTY(JurGetDados( 'NUM', 3, XFILIAL('NUM') + Self:cTabPadrao + xFilial(Self:cTabPadrao) + IIF(lJurChave,cCajuri,'') + cCodigo, 'NUM_DOC'))
			cAnexo := '01'
		Else
			cAnexo := '02'
		Endif
	EndIf

	Do Case
	Case cAnexo == '01'
		cImagem := 'BR_VERDE.PNG'
	Case cAnexo == '02'
		cImagem := 'BR_VERMELHO.PNG'
	End Case

Return cImagem

//-------------------------------------------------------------------
/*/{Protheus.doc} JA162SetTAJ
Guarda o valor do Codigo do tipo de assunto selecionado na inclusão
de Garantia.

@Param xConteudo	 	Codigo do tipo de assunto

@author Jorge Luis Branco Martins Junior
@since 30/01/12
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD JA162SetTAJ(xConteudo) CLASS TJurPesquisa
	Self:xVarTAJ := ''
	Self:xVarTAJ := xConteudo
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} SelTipoAj
Função utilizada para o usuário selecionar o tipo de assunto jurídico
Uso Geral.
@param  cUser Código do Usuário
@author Clóvis Teixeira
@since 02/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SelTipoAj(cPesq) CLASS TJurPesquisa
	Local aArea 	 := GetArea()
	Local cIdBrowse  := ''
	Local cIdRodape  := ''
	Local cQuery     := ''
	Local nI         := 0
	Local nAt        := 0
	Local cTrab      := GetNextAlias()
	Local aCampos    := {}
	Local aStru      := {}
	Local aAux       := {}
	Local aTipoAj    := {}
	Local cRotina    := 'JA095Tela'
	Local cTipoAj    := ''
	Local oBrowse, oColumn
	Local oDlgTpAS, oTela
	Local oPnlBrw, oPnlRoda
	Local oBtnOk, oBtnCancel

	cQuery += " SELECT NVJ.NVJ_CASJUR, NYB.NYB_DESC "
	cQuery += "   FROM "+RetSqlName("NVJ")+" NVJ,"+RetSqlName("NYB")+" NYB"
	cQuery += "  WHERE NVJ.NVJ_CPESQ = '"+cPesq+"'"
	cQuery += "    AND NVJ.NVJ_FILIAL = '"+xFilial("NVJ")+"'"
	cQuery += "    AND NYB.NYB_FILIAL = '"+xFilial("NYB")+"'"
	cQuery += "    AND NVJ.NVJ_CASJUR = NYB.NYB_COD "
	cQuery += "    AND NVJ.D_E_L_E_T_ = ' '"
	cQuery += "    AND NYB.D_E_L_E_T_ = ' '"

	Define MsDialog oDlgTpAS FROM 0, 0 To 400, 600 Title STR0029 Pixel style DS_MODALFRAME //"Selecione o Tipo de Assunto Jurídico"

	nAt := aScan(aTipoAj, {|aX|  aX[1] == PadR( cRotina, 10 ) } )

	oTela     := FWFormContainer():New( oDlgTpAS )
	cIdBrowse := oTela:CreateHorizontalBox( 84 )
	cIdRodape := oTela:CreateHorizontalBox( 16 )
	oTela:Activate( oDlgTpAS, .F. )
	oPnlBrw   := oTela:GeTPanel( cIdBrowse )
	oPnlRoda  := oTela:GeTPanel( cIdRodape )

	If !Empty( cRotina )
		If nAt == 0
			aAdd( aTipoAj, { PadR( cRotina, 10 ) , cQuery, {} } )
		Else
			cQuery := aTipoAj[nAt][2]
		EndIf
	EndIf

	//-------------------------------------------------------------------
	// Define o Browse
	//-------------------------------------------------------------------
	Define FWBrowse oBrowse DATA QUERY ALIAS cTrab QUERY cQuery DOUBLECLICK {||cTipoAj := AllTrim((cTrab)->(FieldGet(1))),oDlgTpAS:End()} NO LOCATE Of oPnlBrw

	If !Empty( cRotina )

		If nAt == 0

			aStru := ( cTrab )->( dbStruct() )

			For nI := 1 To Len( aStru )
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
			Next

			If !Empty( cRotina )
				aTipoAj[Len( aTipoAj ) ][3] := aCampos
			EndIf
		Else
			aCampos := aClone( aTipoAj[nAt][3] )
		EndIf

	EndIf

	//-------------------------------------------------------------------
	// Adiciona as colunas do Browse
	//-------------------------------------------------------------------
	For nI := 1 To Len( aCampos )
		ADD COLUMN oColumn DATA &( ' { || ' + aCampos[nI][1] + ' } ' ) Title aCampos[nI][2]  PICTURE aCampos[nI][3] Of oBrowse
	Next

	//-------------------------------------------------------------------
	// Ativação do Browse
	//-------------------------------------------------------------------
	Activate FWBrowse oBrowse

	//Botão Ok
	@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 221 Button oBtnOk  Prompt STR0030 ; //'Ok'
	Size 25 , 12 Of oPnlRoda Pixel Action ( cTipoAj := AllTrim( (cTrab)->(FieldGet(1)) ), oDlgTpAS:End())

	//Botão Cancelar
	@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 273 Button oBtnCancel Prompt STR0031; //"Cancelar"
	Size 25 , 12 Of oPnlRoda Pixel Action ( oDlgTpAS:End() )

	//-------------------------------------------------------------------
	// Ativação do janela
	//-------------------------------------------------------------------

	Activate MsDialog oDlgTpAS Centered

	//(cTrab)->( dbcloseArea() )

	RestArea(aArea)

Return cTipoAj

	//-------------------------------------------------------------------
	/*/{Protheus.doc} MostraLegGar(oLstPesq)
	Função utilizada para mostrar uma tela com a legenda das cores dos
	tipos de Garantia.
	Uso Geral.

	@Param	oLstPesq		Lista de registros(Grid).

	@author Jorge Luis Branco Martins Junior
	@since 23/01/12
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD MostraLegAnex(oLstPesq, cTitulo) CLASS TJurPesquisa
	Local oDlg, nI, aBmp := {}, aSay := {}
	Local oPnlOK, oPnlImg, oPnlDesc, oBtnOK
	Local cCor
	Local nEscolhida

	If !LEN(oLstPesq:aCols) == NIL

		cCor := oLstPesq:aCols[oLstPesq:NAT][1]
		oDlg := MSDialog():New(0,0,100,250,cTitulo,,,,,CLR_BLACK,CLR_WHITE,,,.T.) //"Legenda da Garantia"

		oPnlOK   := tPanel():New(0,0,'',oDlg,,,,,,10,10)
		oPnlImg  := tPanel():New(20,20,'',oDlg,,,,,,10,10)
		oPnlDesc := tPanel():New(20,30,'',oDlg,,,,,,90,10)
		oPnlOK:Align   := CONTROL_ALIGN_BOTTOM
		oPnlImg:Align  := CONTROL_ALIGN_LEFT
		oPnlDesc:Align := CONTROL_ALIGN_ALLCLIENT

		For nI := 1 to 2
			aAdd(aBmp, TBitmap():New(0,0,10,10,,Self:Legenda(PADL(nI,2,'0')),.T.,oPnlImg,{|| },,.F.,.F.,,,.F.,,.T.,,.F.) )
			aBmp[nI]:Align := CONTROL_ALIGN_TOP
			If aBmp[nI]:CBMPFILE == cCor
				nEscolhida := nI
			EndIf
		Next

		NTY->(DBSetOrder(1))
		IF NTY->( DBSeek(XFILIAL('NTY')+'NT2'+'          '+'001') )
			nI := 001
			While !NTY->(Eof()) .And. NTY->NTY_TABELA = 'NT2'
				aAdd(aSay, tSay():New(01,01,{|| ''},oPnlDesc,,,,,,.T.,,,10,10))
				aSay[LEN(aSay)]:Align := CONTROL_ALIGN_TOP
				aSay[LEN(aSay)]:SetText(AllTrim(NTY->NTY_LEGEND)+IIF(nEscolhida == nI, '	* ', ''))
				aSay[LEN(aSay)]:lWordWrap  := .T.
				aSay[LEN(aSay)]:lTransparent := .T.
				NTY->(dbSkip())
				nI += 001
			End

		EndIf

		oBtnOK := SButton():New( 01,01,1,{|| oDlg:End()},oPnlOK,.T.,,)
		oBtnOK:Align := CONTROL_ALIGN_LEFT

		oDlg:Activate(,,,.T.,,,)

	EndIF

Return NIL

	//-------------------------------------------------------------------
	/*/{Protheus.doc} Legenda(cNum)
	Função utilizada para retornar a legenda.
	Uso Geral.

	@Param	cNum		  Lista.
	@Return	cImagem		Nome do BMP da cor.

	@author Jorge Luis Branco Martins Junior
	@since 24/01/12
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD Legenda(cNum) CLASS TJurPesquisa
	Local cImagem

	Do Case
	Case cNum == '01'
		cImagem := 'BR_VERDE.PNG'
	Case cNum == '02'
		cImagem := 'BR_VERMELHO.PNG'
	End Case

Return cImagem

//-------------------------------------------------------------------
/*/{Protheus.doc} JA162BCorr
Verifica se a opção correção de valores pode ser executada. Verifica
restrições de acessos.

@author Jorge Luis Branco Martins Junior
@since 06/11/12
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD JA162BCorr(oLstPesq,aTables, nOp, lRecalculo) CLASS TJurPesquisa
Local aAux    := {}

Default aTables := {}
Default lRecalculo := .F.

	If nOp == 1 // Processos
		If Empty(oLstPesq:aCols)
			JurMsgErro(STR0032,'JURA162') //"É necessário realizar a pesquisa dos registros a serem corrigidos"
		Else
			If JA162AcRst('16', 2) .Or. Empty(Self:cGrpRest)
				aAux := Self:JA162Cod(oLstPesq)
				If Len(aTables) == 0
					aTables := JURRELASX9('NSZ', .F.)
				EndIf
				Processa( {|| JURA002( aAux,aTables,.T.,,,,lRecalculo) } ,STR0092, STR0093, .F.) // "Aguarde" - "Iniciando correção de valores"
				aSize(aAux,0)
			Else
				JurMsgErro(STR0033,'JURA162')//'Operação não permitida.'
			EndIf
		EndIf
	ElseIf nOp == 3 // Garantias
		If !Empty(oLstPesq:aCols)
			If JA162AcRst('16', 2) .Or. Empty(Self:cGrpRest)
				Processa( {|| JA162CorPesq('NT2', oLstPesq:aCols, lRecalculo, Self) } ,STR0092, STR0093, .F.) // "Aguarde" - "Iniciando correção de valores"
			Else
				JurMsgErro(STR0033,'JURA162')//'Operação não permitida.'
			Endif
		Else
			Alert(STR0034)//"Configuração inválida ou perfil de pesquisa não está vinculado a nenhum tipo de assunto jurídico. Operação cancelada!"
		EndIf
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA162CorPesq(cTabela, aDados, lRecalculo, Self)
Função para aplicaR correção monetária em determinado assunto jurídico

@Param  cTabela:    Tabela que será aplicada a correção
@Param  aDados:     Dados dos registros que serão corrigidos
@Param  lRecalculo: Define se é recalculo?
@Param  Self:       Objeto da classe de pesquisa

@since 18/11/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA162CorPesq(cTabela, aDados, lRecalculo, Self)
Local nI       := 1
Local nCount   := 1
Local cCajuri  := ''
Local cTemp    := ''
Local cFilGar  := ''

	For nI := 1 to Len(aDados)
		cCajuri := Self:getCajuri(nI)
		cFilGar := Self:getFilial(nI)
		
		If (cFilGar + cCajuri) != cTemp
			IncProc(I18N(STR0098, { alltrim(str(nCount)), alltrim(str(Len(aDados))) })) //"Atualizando #1 de #2"

			lRet   := JURCORVLRS(cTabela, cCajuri, lRecalculo, , .T.)

			cTemp  := cFilGar + cCajuri
			nCount += 1
		EndIf
	Next

	If !JurAuto()
		MsgAlert(STR0099, STR0035) //Correção de valores finalizada com sucesso. //Correção Monetária
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA162Cod()
Função para retornar array com códigos dos processos retornados na
pesquisa

@Return aCodigos   Array com códigos e filiais
@Param  oLstPesq   Grid de Pesquisa

@author André Spirigoni Pinto
@since 05/09/14
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD JA162Cod(oLstPesq) CLASS TJurPesquisa
	Local nI
	Local aCodigos := {}

	If oLstPesq <> NIL
		Self:fillGrid() //garantir que todos os registros estejam no grid
		For nI:= 1 to Len(oLstPesq:aCols)
			aAdd(aCodigos,{Self:getCajuri(nI),Self:getFilial(nI)})
		Next
	EndIf

Return aCodigos

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuCorr
Monta o menu de opções de correção monetária

@author André Spirigoni Pinto
@since 09/06/14
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD MenuCorr(oLstPesq, oObj, aTables) CLASS TJurPesquisa
	Local oMenu
	Local oMenuItem	 := {}

	MENU oMenu POPUP of oObj:oSay
	aAdd(oMenuItem, MenuAddItem(STR0035,,, .T.,,,,oMenu,{||	Self:JA162BCorr(Self:oLstPesq,Self:aTables,val(Self:cTipoPesq),.F.)},,,,,{||.T.} )) //"Correção Monetária"
	aAdd(oMenuItem, MenuAddItem(STR0036,,, .T.,,,,oMenu,{||	Self:JA162BCorr(Self:oLstPesq,Self:aTables,val(Self:cTipoPesq),.T.)},,,,,{||.T.} )) //"Recálculo"
ENDMENU

Activate POPUP oMenu AT 40, 20 of oObj:oSay

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} J162RemCas()
Função utilizada para trazer o ultimo cliente/loja/caso do remanejamento.

@Param	aObj	Array que contem todos os objetos com os campo do filtro.

@Return aObj	Array que contem todos os objetos com os campo do filtro com
a atualização do cliente/loja/caso remanejado

@author Luciano Pereira dos Santos
@since 01/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD J162RemCas(aObj) CLASS TJurPesquisa
	Local nPosCli    := 0
	Local nPosLoj    := 0
	Local nPosCas    := 0
	Local cClient    := ''
	Local cLoja      := ''
	Local cCaso      := ''
	Local aCaso      := {}

	Default aObj := {}

	If !Empty(aObj)

		nPosCli := aScan(aObj, { |aX| !Empty(aX) .AND. aX:CNOMECAMPO == 'NSZ_CCLIEN' .AND. !Empty(aX:VALOR) })
		If nPosCli > 0
			cClient := aObj[nPosCli]:VALOR
		EndIf

		nPosLoj:= aScan(aObj, { |aX| !Empty(aX) .AND. aX:CNOMECAMPO == 'NSZ_LCLIEN' .AND. !Empty(aX:VALOR) })
		If nPosLoj > 0
			cLoja   := aObj[nPosLoj]:VALOR
		EndIf

		nPosCas:= aScan(aObj, { |aX| !Empty(aX) .AND. aX:CNOMECAMPO == 'NSZ_NUMCAS' .AND. !Empty(aX:VALOR) })
		If nPosCas > 0
			cCaso   := aObj[nPosCas]:VALOR
		EndIf

		aCaso := J162CasNew(cClient, cLoja, cCaso)

		If !Empty(aCaso)
			Iif(nPosCli > 0, aObj[nPosCli]:VALOR := aCaso[1], )
			Iif(nPosLoj > 0, aObj[nPosLoj]:VALOR := aCaso[2], )
			Iif(nPosCas > 0, aObj[nPosCas]:VALOR := aCaso[3], )
		EndIf

	EndIf

Return aObj

//-------------------------------------------------------------------
/*/{Protheus.doc} befActivate
Executa ações logo antes de ativar a área de trabalho.

@author André Spirigoni Pinto
@since 09/06/14
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD befActivate() CLASS TJurPesquisa
	//Self:setbRFiltro()
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} befAction
Executa validações/ações antes de determinado evento. Atualmente
é utilizado antes das operações do menu.

@author André Spirigoni Pinto
@since 09/06/14
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD befAction() CLASS TJurPesquisa
	Local lRet := .T.

	//Valida se existem linhas no grid
	If Valtype(Self:oLstPesq) <> "U"
		If len(Self:oLstPesq:aCols) == 0
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} setMenRest
trata as restrições de itens do menu, caso existam.

@author André Spirigoni Pinto
@since 09/06/14
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD setMenRest() CLASS TJurPesquisa
	Local nMenu
	Local nCt

	For nCt := 1 to len(Self:aRestMenu)
		nMenu := aScan(Self:oDesk:oWorkArea:oMenuNav:OuiMenuNav:aItem, {|x| x:cID == Self:aRestMenu[nCt][1]})
		if nMenu > 0 //caso tenha encontrado o menu pelo ID, prossegue
			if !Eval(Self:aRestMenu[nCt][2]) //caso o bloco tenha retornado False, esconde o menu
				Self:oDesk:oWorkArea:oMenuNav:OuiMenuNav:aItem[nMenu]:oSay:Hide()
			else //caso o bloco tenha retornado True, mostrar o menu.
				Self:oDesk:oWorkArea:oMenuNav:OuiMenuNav:aItem[nMenu]:oSay:Show()
				If Len (Self:aRestMenu[nCt]) > 2
					SetKEY(Self:aRestMenu[nCt][4],Self:oDesk:oWorkArea:oMenuNav:OuiMenuNav:aItem[nMenu]:oClickobservable:aObs[2][2]:bAction)//Ativa tecla de atalho para botões padrão que são exibidos na tela
					//Seta as teclas de atalho
					aAdd(Self:aTecAtalho,{Self:aRestMenu[nCt][4], Self:oDesk:oWorkArea:oMenuNav:OuiMenuNav:aItem[nMenu]:oClickobservable:aObs[2][2]:bAction})
					//Guarda as teclas de atalho
				EndIf
			endif
		endif
	Next

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} loadCmbConfig
Carrega o combo de configuração de pesqisa.

@author André Spirigoni Pinto
@since 09/06/14
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD loadCmbConfig(oPanel) CLASS TJurPesquisa
	Local oPnlCampos
	Local oSplPesqC

	//Painel principal
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	oPanel:nCLRPANE := RGB(255,255,255)

	oPnlCampos := tPanel():New(0,0,'',oPanel,,,,,,60,15)
	oPnlCampos:Align := CONTROL_ALIGN_TOP
	oPnlCampos:nCLRPANE := RGB(224,229,234)

	oSplPesqC := tPanel():New(0,0,'',oPanel,,,,,,0,0)
	oSplPesqC:Align := CONTROL_ALIGN_ALLCLIENT
	oSplPesqC:nCLRPANE := RGB(255,255,255)
	oSplPesqC:ReadClientCoors(.T.,.T.)

	Self:oCmbConfig := TJurCmbBox():New(1,1,110,10,oPnlCampos,Self:GetNomesConf(),{|| Self:bActPesquisa()},.F. /*lPanel*/)

	Self:oCmbConfig:SetAlign(CONTROL_ALIGN_LEFT)

Return oSplPesqC

//-------------------------------------------------------------------
/*/{Protheus.doc} bActPesquisa
método que executa as ações que devem ser executadas quando é alterado
o item do combo de configuração de pesquisa.

@author André Spirigoni Pinto
@since 09/06/14
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD bActPesquisa() CLASS TJurPesquisa
	Local lRet := .T.
	Local nCt

	For nCt := 1 to len(Self:aBConfig)
		if lRet
			lRet := Eval(Self:aBConfig[nCt])
		Endif
	Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} loadLayout
Método responsável por construir o layout da tela.

@author André Spirigoni Pinto
@since 09/06/14
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD loadLayout() CLASS TJurPesquisa
	Local cError   		:= ""
	Local cWarning 		:= ""
	Local oXml 	 		:= NIL
	local nTotalRecurso	:= 0
	local i

	oXml := XmlParser( getXmlTest(), "_", @cError, @cWarning )

	If (oXml == NIL )
		MsgStop("Falha ao gerar Objeto XML : "+cError+" / "+cWarning)
		Return
	Endif

	if ValType(oXml:_EQUIPE:_RECURSO) != 'O'

		nTotalRecurso := Len(oXml:_EQUIPE:_RECURSO)

		if nTotalRecurso > 0
			For i := 1 To nTotalRecurso
				MsgAlert(oXml:_EQUIPE:_RECURSO[i]:_NOME:Text)
			Next i
		endif

	else

		MsgAlert(oXml:_EQUIPE:_RECURSO:_NOME:Text)

	endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ConfLayout
Método responsável por configurar o layout da tela.

@author Jorge Luis Branco Martins Junior
@since 24/04/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD confLayout() CLASS TJurPesquisa
	Local aSizeD     := FWGetDialogSize( oMainWnd )
	Local cWizTitle  := STR0081			// "Configurador da Área de Trabalho"
	Local cHMsg      := STR0044			// "Wizard utilizado para a configuração da Área de Trabalho."
	Local cTitle     := STR0045			// "Configuração da Área de Trabalho"
	Local oQtdSec    := Nil
	Local cUser 	 := __CUSERID
	Local cRotina    := self:cRotina

	self:cQtdSec := "  "
	self:aXML := {}

	// ------------------------------------------------ TEXTO TELA 1 - WIZARD --------------------------------------------
	cText := STR0046 + Chr( 10 ) + Chr( 10 )  // "Como Configurar a Área de Trabalho."
	cText += STR0047 + Chr( 10 )              // "A Área de Trabalho permite que você tenha visões dos dados com mais praticidade em uma única tela. Assim, é possível concentrar as "
	cText += STR0048 + Chr( 10 ) + Chr( 10 )  // "informações pertinentes à sua rotina de trabalho."
	cText += STR0049 + Chr( 10 ) + Chr( 10 )  // "Este assistente auxiliará na formatação da sua área de trabalho. Escolha um layout de sua preferência e adicione gráficos e tabelas para cada divisão do layout."
	cText += STR0050 + Chr( 10 )              // "As divisões podem receber os seguintes componentes:"
	cText += STR0051 + Chr( 10 )              // "      Grid: Fornece resultados da pesquisa efetuada."
	cText += STR0052 + Chr( 10 )              // "      Campos: Fornece campos para filtro para efetuar pesquisas."
	cText += STR0053 + Chr( 10 )              // "      Calendário: Disponibiliza um calendário com seus compromissos (Utilizado somente para Follow-Up)."
	cText += STR0054 + Chr( 10 )              // "      Gráfico: Viabiliza a representação gráfica dos dados."
	cText += STR0055 + Chr( 10 ) + Chr( 10 )  // "      WebBrowser: disponibiliza um página da internet."
	cText += STR0056 + Chr( 10 )              // "Criação do Layout"
	cText += STR0057 + Chr( 10 )              // "      Defina a quantidade de sessões que serão exibidas e as proporções(vertical) que elas utilizarão em sua exibição."
	cText += STR0058                          // "      Indique para cada sessão se serão exibidos um ou dois componentes e informe quais componentes serão usados."

	// ------------------------------------------------ WIZARD - TELA 1 --------------------------------------------
	oWizard := ApWizard():New( cWizTitle, ;
		cHMsg, ;
		cTitle, ;
		cText, ;
		{ || .T. }, ;
		{ || .T. }, ;
		.T., ;
	 						   /*cResHead*/, ;
	 						   /*bExecute*/, ;
		.F., ;
		{ aSizeD[1]*0.80, aSizeD[2]*0.90, aSizeD[3]*0.90, aSizeD[4]*0.80 } ;
		) // "Wizard utilizado para a configuração customizada da Área de Trabalho."



	oWizard:newPanel( cWizTitle, ;
		STR0056, ;
		{ || .T. }, ;
		{ || self:bvldpanel1(oWizard, ;
		Val(self:cQtdSec);
		), ;
		self:bnewpanel(oWizard, ;
		Val(self:cQtdSec) ;
		) }, ;
		{ ||.T.}, ;
		.T., ;
		{ || self:GetCfg() } ;
		)		// "Escolha do Layout:"

	oPnlPos := oWizard:GeTPanel( 2 )
	oLayerMain := FWLayer():New()                 // instanciado layer principal
	oLayerMain:Init( oPnlPos, .F. )               // inicializado layer principal
	oLayerMain:AddCollumn( "BOX_FULL", 100, .F. ) // adicionado box esquerdo

	oColFULL := oLayerMain:getColPanel( "BOX_FULL",  Nil )		// instanciado box esquerdo
	oColFULL:Align := CONTROL_ALIGN_ALLCLIENT

	// campo para digitar a quantidade de seções
	DEFINE FONT oBold NAME "Arial" SIZE 0, -11 BOLD
	@ oColFULL:nTop+60,      ;
		oColFULL:nLeft+115     ;
		SAY STR0071 FONT oBold ;
		OF oColFULL            ;
		PIXEL SIZE 95,10				// 'Indique a quantidade de sessões:'

	oQtdSec := TGet():New( oColFULL:nTop+58,        	/* nRow        */;
		oColFULL:nLeft+215,          /* nCol        */;
		{ |u| If( PCount() > 0,      				 ;
		self:cQtdSec := u, 			     ;
		self:cQtdSec       				 ;
		)                    				 ;
		},                           /* bSetGet     */;
		oColFULL,                    /* oWnd        */;
		50,                          /* nWidth      */;
		10,                          /* nHeight     */;
		"99",                        /* cPict       */;
		,                            /* bValid      */;
		,                            /* nClrFore    */;
		,                            /* nClrBack    */;
		,                            /* oFont       */;
		.F.,                         /* uParam12    */;
		,                            /* uParam13    */;
		.T.,                         /* lPixel      */;
		,                            /* uParam15    */;
		.F.,                         /* uParam16    */;
		,                            /* bWhen       */;
		.F.,                         /* uParam18    */;
		.F.,                         /* uParam19    */;
		,                            /* bChange     */;
		.F.,                         /* lReadOnly   */;
		.F.,                         /* lPassword   */;
		,                            /* uParam23    */;
		self:cQtdSec                 /* cReadVar    */;
		)

    /*Verifica se já existe um Layout de área de trabalho customizado para então exibir o botão de "Redefinir Layout"*/
	If( NZE->(dbSeek(xFilial('NZE') + cUser + cRotina)))
		@ oWizard:oModal:nFreeHeight-100, 7  BUTTON STR0095 SIZE 50 ,18 ACTION self:resetLay(@oWizard) OF oColFULL PIXEL
	EndIf

	// "Configurador da Área de Trabalho" / "Seção"
	oWizard:newPanel( STR0081,                            /* cTitle   */ ;
		STR0072 + '1',                      /* cMsg     */ ;
		{ || .T. },                         /* bBack    */ ;
		{ || self:bVldNext( 1, oPnlPos ) }, /* bNext    */ ;
		{ || .F.},                          /* bFinish  */ ;
		.T.,                                /* lPanel   */ ;
		{ || self:GetCfg("1") }             /* bExecute */ ;
		)

	oPnlPos := oWizard:GeTPanel( 3 )
	self:crialayout( oPnlPos )

	oWizard:Activate( .T. , { ||.T.} )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} bnewpanel
Método responsável por criar novo panel

@author Jorge Luis Branco Martins Junior
@since 24/04/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD bnewpanel(oWizard, nQtdSec) CLASS TJurPesquisa
	Local lRet := .T.
	Local nI   := 0

	If nQtdSec < 1
		lRet := self:msgpanel( 1 )
	Else
		If nQtdSec == 1
			Self:cCmbPerc  := '100'
			self:lSecUnica := .T.
		EndIf

		For nI := 2 to nQtdSec //Começa em 2 porque a sessão 1 já foi criada.
			oWizard:newPanel( STR0081, STR0072 + cValToChar(nI), /*{ || .T. }*/ &('{ || self:GetCfg('+ str(nI-1) +', 1, .F.) }' ), &('{ || self:bVldNext( '+AllTrim(str(nI))+', oPnlPos ) }' ), { || .F. }, .T., &('{ || self:GetCfg('+ str(nI) +') }' ) )   		// "Configurador da Área de Trabalho" / "Seção"
			oPnlPos := oWizard:GeTPanel( nI + 2 )
			self:crialayout( oPnlPos )
		Next
	EndIf

	oWizard:newPanel( STR0073, STR0074, { || .T. }, { ||.F.}, { || self:bVldFinish( .F. ), .T. }, .T., { ||.T.} )		// "Pronto!"      "Para concluir a configuração clique em Finalizar"

Return lRet

//------------------------------------------------------------------------------------
/*/{Protheus.doc} msgpanel

Função para exibir mensagem de alerta dos blocos de validações BACK NEXT FINISH EXEC

@sample		msgpanel( 1 )

@param			nMsg - Mensagem a ser exibida

@return		ExpL - Falso

@author		Jorge Luis Branco Martins Junior
@since			27/04/2015
@version		P12
/*/
//-------------------------------------------------------------------------------------
METHOD msgpanel( nMsg ) CLASS TJurPesquisa

	Local aMsgs := { STR0059, ; // 1 // "Informe a quantidade de sessões."
	STR0060, ; // 2 // "Favor selecionar uma opção."
	STR0061, ; // 3 // "Por Favor, é preciso digitar uma URL válida"
	STR0062, ; // 4 // "É preciso informar a proporção"
	STR0063, ; // 5 // "É preciso informar a visão e o tipo do gráfico"
	STR0064, ; // 6 // "Não foi possível validar a página digitada"
	STR0083, ; // 7 // "A opção GRID já foi indicada nesta ou em outra seção. Selecione outro componente."
	STR0084, ; // 8 // "A opção CAMPOS já foi indicada nesta ou em outra seção. Selecione outro componente."
	STR0087, ; // 9 // "A opção WEBBROWSER já foi indicada nesta ou em outra seção. Selecione outro componente."
	STR0088  } // 10 //"A opção CALENDÁRIO já foi indicada nesta ou em outra seção. Selecione outro componente."

	Msgalert( aMsgs[nMsg] )

Return ( .F. )

//-------------------------------------------------------------------
/*/{Protheus.doc} bvldpanel1
Método responsável por validar panel de quantidade de sessões

@author Jorge Luis Branco Martins Junior
@since 27/04/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD bvldpanel1(oWizard, nQtdSec) CLASS TJurPesquisa
	Local lRet := .T.

	If nQtdSec < 1
		lRet := self:msgpanel( 1 )
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} crialayout
Método responsável por criar o layout usados nas sessões

@author Jorge Luis Branco Martins Junior
@since 27/04/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD crialayout(oPanel) CLASS TJurPesquisa

	Local aCmbPerc := {'','25','35','50','65','75','100'}
	Local aCmbOpc1 := {}
	Local aCmbOpc2 := {}
	Local aCmbVis1 := {''}
	Local aCmbVis2 := {''}
	Local aCmbTp1  := {''}
	Local aCmbTp2  := {''}
	Local aVisao   := {}
	Local aTipo    := {}
	Local oCmbPerc
	Local oCmbOpc1
	Local oCmbOpc2
	Local oCmbVis1
	Local oCmbVis2
	Local oCmbTp1
	Local oCmbTp2
	Local oURL1
	Local oURL2
	Local oTableAttach := FWGetAttSrc( self:cRotina )

	self:cURL1 := SPACE(150)
	self:cURL2 := SPACE(150)

	If oTableAttach <> nil
		aVisao := oTableAttach:aViews
		aTipo  := oTableAttach:aCharts

		aEval(aVisao, { |x| aAdd( aCmbVis1, x:cName ) } )
		aEval(aVisao, { |x| aAdd( aCmbVis2, x:cName ) } )
		aEval(aTipo,  { |x| aAdd( aCmbTp1,  x:cName ) } )
		aEval(aTipo,  { |x| aAdd( aCmbTp2,  x:cName ) } )
	EndIf

	If aScan(JurGetMethods(Self),{|x| UPPER(x[1]) == "GETCALENDARIO"}) > 0
		aCmbOpc1 := {'',STR0065,STR0066,STR0067,STR0068,STR0069}//'Grid','Campos','Gráfico','Calendário','WebBrowser'
		aCmbOpc2 := {'',STR0065,STR0066,STR0067,STR0068,STR0069}//'Grid','Campos','Gráfico','Calendário','WebBrowser'
	Else
		aCmbOpc1 := {'',STR0065,STR0066,STR0067,STR0069}//'Grid','Campos','Gráfico','WebBrowser'
		aCmbOpc2 := {'',STR0065,STR0066,STR0067,STR0069}//'Grid','Campos','Gráfico','WebBrowser'
	EndIf

	oGroup1:= TGroup():New(42,20,250,215, STR0070 +' 01',oPanel,,,.T.) //Coluna
	oGroup1:oFont:bold := .T.
	oGroup1:oFont:name := 'Arial'
	oGroup1:Refresh()

	oGroup2:= TGroup():New(42,250,250,445, STR0070 +' 02',oPanel,,,.T.) //Coluna
	oGroup2:oFont:bold := .T.
	oGroup2:oFont:name := 'Arial'
	oGroup2:Refresh()

	@ 10, 20 Say STR0075 FONT oBold Of oPanel PIXEL SIZE 80, 10 //'Proporção vertical (%)'
	oCmbPerc := TComboBox():New(20,25,{|u|if(PCount()>0,Self:cCmbPerc:=u,Self:cCmbPerc)},aCmbPerc,50,10,oPanel,,{|| .T. },,,,.T.,,,,{ || !(self:lSecUnica) },,,,,'Self:cCmbPerc')

	@ 60, 25 Say STR0076 FONT oBold Of oGroup1 PIXEL SIZE 80, 10 //'Opção:'
	oCmbOpc1 := TComboBox():New(58,47,{|u|if(PCount()>0,Self:cCmbOpc1:=u,Self:cCmbOpc1)},aCmbOpc1,50,10,oGroup1,,{|| IIF(Empty(AllTrim(Self:cCmbOpc1)),Self:cCmbOpc2 := "",),Self:cCmbVis1 := "", Self:cCmbTp1 := "", Self:cURL1 := SPACE(150), .T. },,,,.T.,,,,,,,,,'Self:cCmbOpc1')

	@ 102, 35 Say STR0077 FONT oBold Of oGroup1 PIXEL SIZE 80, 10 //'Visão:'
	oCmbVis1 := TComboBox():New(100,57,{|u|if(PCount()>0,Self:cCmbVis1:=u,Self:cCmbVis1)},aCmbVis1,150,10,oGroup1,,{|| .T. },,,,.T.,,,,{|| oCmbOpc1:aItems[oCmbOpc1:nAt] == STR0067},,,,,'Self:cCmbVis1')//'Gráfico'

	@ 144, 35 Say STR0078 FONT oBold Of oGroup1 PIXEL SIZE 80, 10 //'Tipo:'
	oCmbTp1 := TComboBox():New(142,57,{|u|if(PCount()>0,Self:cCmbTp1:=u,Self:cCmbTp1)},aCmbTp1,150,10,oGroup1,,{|| .T. },,,,.T.,,,,{|| oCmbOpc1:aItems[oCmbOpc1:nAt] == STR0067},,,,,'Self:cCmbTp1')//'Gráfico'

	@ 186, 35 Say STR0079 FONT oBold Of oGroup1 PIXEL SIZE 80, 10 //'URL:'
	oURL1 := TGet():New( 184, 57, { |u| If( PCount() > 0, Self:cURL1 := u, Self:cURL1 ) }, oGroup1, 150, 10, "@X", , , , , .F., , .T., , .F., { || oCmbOpc1:aItems[oCmbOpc1:nAt] == STR0069}, .F., .F., , .F., .F., , 'Self:cURL1' )//'WebBrowser'

	@ 60, 255 Say STR0076 FONT oBold Of oGroup2 PIXEL SIZE 80, 10 //'Opção:'
	oCmbOpc2 := TComboBox():New(58,277,{|u|if(PCount()>0,Self:cCmbOpc2:=u,Self:cCmbOpc2)},aCmbOpc2,50,10,oGroup2,,{|| Self:cCmbVis2 := "", Self:cCmbTp2 := "", Self:cURL2 := SPACE(150), .T. },,,,.T.,,,,{|| !Empty(AllTrim(oCmbOpc1:aItems[oCmbOpc1:nAt])) },,,,,'Self:cCmbOpc2')

	@ 102, 265 Say STR0077 FONT oBold Of oGroup2 PIXEL SIZE 80, 10 //'Visão:'
	oCmbVis2 := TComboBox():New(100,287,{|u|if(PCount()>0,Self:cCmbVis2:=u,Self:cCmbVis2)},aCmbVis2,150,10,oGroup2,,{|| .T. },,,,.T.,,,,{|| !Empty(AllTrim(oCmbOpc1:aItems[oCmbOpc1:nAt])), oCmbOpc2:aItems[oCmbOpc2:nAt] == STR0067},,,,,'Self:cCmbVis2')//'Gráfico'

	@ 144, 265 Say STR0078 FONT oBold Of oGroup2 PIXEL SIZE 80, 10 //'Tipo:'
	oCmbTp2 := TComboBox():New(142,287,{|u|if(PCount()>0,Self:cCmbTp2:=u,Self:cCmbTp2)},aCmbTp2,150,10,oGroup2,,{|| .T. },,,,.T.,,,,{|| !Empty(AllTrim(oCmbOpc1:aItems[oCmbOpc1:nAt])), oCmbOpc2:aItems[oCmbOpc2:nAt] == STR0067},,,,,'Self:cCmbTp2')//'Gráfico'

	@ 186, 265 Say STR0079 FONT oBold Of oGroup2 PIXEL SIZE 80, 10 //'URL:'
	oURL2 := TGet():New( 184, 287, { |u| If( PCount() > 0, Self:cURL2 := u, Self:cURL2 ) }, oGroup2, 150, 10, "@X", , , , , .F., , .T., , .F., { || !Empty(AllTrim(oCmbOpc1:aItems[oCmbOpc1:nAt])), oCmbOpc2:aItems[oCmbOpc2:nAt] == STR0069}, .F., .F., , .F., .F., , 'Self:cURL2' )//'WebBrowser'

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} bVldNext
Método responsável validar o botão de avançar do Wizard

@author Jorge Luis Branco Martins Junior
@since 27/04/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD bVldNext(nSec, oPanel) CLASS TJurPesquisa
	Local lRet   := .T.
	Local nI     := 0
	Local nJ     := 0

	If Empty(AllTrim(self:cCmbPerc))
		lRet := self:msgpanel( 4 )
	ElseIf Empty(AllTrim(self:cCmbOpc1))
		lRet := self:msgpanel( 2 )
	ElseIf ( AllTrim(self:cCmbOpc1) == STR0067 .And. ( Empty(AllTrim(self:cCmbVis1)) .Or. Empty(AllTrim(self:cCmbTp1)) ) ) .Or. ( AllTrim(self:cCmbOpc2) == STR0067 .And. ( Empty(AllTrim(self:cCmbVis2)) .Or. Empty(AllTrim(self:cCmbTp2)) ) ) //'Gráfico'
		lRet := self:msgpanel( 5 )
	ElseIf (( AllTrim(self:cCmbOpc1)) == STR0069 .And. Empty(AllTrim(self:cURL1)) ) .Or. ( ( AllTrim(self:cCmbOpc2)) == STR0069 .And. Empty(AllTrim(self:cURL2)) )//'WebBrowser'
		lRet := self:msgpanel( 3 )
	EndIf

	If lRet
		If !Empty(AllTrim(self:cURL1))
			lRet := self:vldUrl( self:cURL1 )
		EndIf
	EndIf

	If lRet
		If !Empty(AllTrim(self:cURL2))
			lRet := self:vldUrl( self:cURL2 )
		EndIf
	EndIf

	If lRet .And. !Empty(AllTrim(self:cCmbOpc1)) .And. AllTrim(self:cCmbOpc1) == AllTrim(self:cCmbOpc2)
		If self:cCmbOpc1 == STR0065 //GRID
			lRet := self:msgpanel( 7 ) //"A opção GRID já foi indicada nesta ou em outra seção. Selecione outro componente."
		ElseIf self:cCmbOpc1 == STR0066 //CAMPOS
			lRet := self:msgpanel( 8 ) //"A opção CAMPOS já foi indicada nesta ou em outra seção. Selecione outro componente."
		ElseIf self:cCmbOpc1 == STR0069 //WEBBROWSER
			lRet := self:msgpanel( 9 ) // "A opção WEBBROWSER já foi indicada nesta ou em outra seção. Selecione outro componente."
		ElseIf self:cCmbOpc1 == STR0068 //CALENDÁRIO
			lRet := self:msgpanel( 10 )//"A opção CALENDÁRIO já foi indicada nesta ou em outra seção. Selecione outro componente."
		EndIf
	EndIf

	If lRet .And. Len(self:aXML) > 0
		For nI := 1 To Len(self:aXML)
			If lRet
				For nJ := 1 To Len(self:aXML[nI])
					If self:aXML[nI][nJ][1] == self:cCmbOpc1
						If nSec > nI
							If self:cCmbOpc1 == STR0065 //GRID
								lRet := self:msgpanel( 7 ) //"A opção GRID já foi indicada nesta ou em outra seção. Selecione outro componente."
								Exit
							ElseIf self:cCmbOpc1 == STR0066 //CAMPOS
								lRet := self:msgpanel( 8 ) //"A opção CAMPOS já foi indicada nesta ou em outra seção. Selecione outro componente."
								Exit
							ElseIf self:cCmbOpc1 == STR0069 //WEBBROWSER
								lRet := self:msgpanel( 9 ) // "A opção WEBBROWSER já foi indicada nesta ou em outra seção. Selecione outro componente."
								Exit
							ElseIf self:cCmbOpc1 == STR0068 //CALENDÁRIO
								lRet := self:msgpanel( 10 )//"A opção CALENDÁRIO já foi indicada nesta ou em outra seção. Selecione outro componente."
								Exit
							EndIf
						EndIf
					EndIf

					If self:aXML[nI][nJ][1] == self:cCmbOpc2
						If nSec > nI
							If self:cCmbOpc2 == STR0065 //GRID
								lRet := self:msgpanel( 7 ) //"A opção GRID já foi indicada nesta ou em outra seção. Selecione outro componente."
								Exit
							ElseIf self:cCmbOpc2 == STR0066 //CAMPOS
								lRet := self:msgpanel( 8 ) //"A opção CAMPOS já foi indicada nesta ou em outra seção. Selecione outro componente."
								Exit
							ElseIf self:cCmbOpc1 == STR0069 //WEBBROWSER
								lRet := self:msgpanel( 9 ) // "A opção WEBBROWSER já foi indicada nesta ou em outra seção. Selecione outro componente."
								Exit
							ElseIf self:cCmbOpc1 == STR0068 //CALENDÁRIO
								lRet := self:msgpanel( 10 )//"A opção CALENDÁRIO já foi indicada nesta ou em outra seção. Selecione outro componente."
								Exit
							EndIf
						EndIf
					EndIf
				Next
			EndIf
		Next
	EndIf

	If lRet
		If Len(self:aXML) >= nSec
			self:aXML[nSec][1] := {self:cCmbOpc1,self:cCmbVis1,self:cCmbTp1,self:cURL1,self:cCmbPerc}
			If !Empty(AllTrim(self:cCmbOpc2))
				If Len(self:aXML[nSec]) == 2
					self:aXML[nSec][2] := {self:cCmbOpc2,self:cCmbVis2,self:cCmbTp2,self:cURL2,self:cCmbPerc}
				Else
					aAdd(self:aXML[nSec],{ self:cCmbOpc2,self:cCmbVis2,self:cCmbTp2,self:cURL2,self:cCmbPerc})
				EndIf
			Else
				If Len(self:aXML[nSec]) == 2
					aDel(self:aXML[nSec],Len(self:aXML[nSec]))
					aSize(self:aXML[nSec],1)
				EndIf
			EndIf
		Else
			aAdd(self:aXML      ,{{self:cCmbOpc1,self:cCmbVis1,self:cCmbTp1,self:cURL1,self:cCmbPerc}})
			If !Empty(AllTrim(self:cCmbOpc2))
				aAdd(self:aXML[nSec],{ self:cCmbOpc2,self:cCmbVis2,self:cCmbTp2,self:cURL2,self:cCmbPerc})
			EndIf
		EndIf

		//aXML[SECAO]
		//aXML[SECAO][1][1] -> Opção da 1ª coluna
		//aXML[SECAO][1][2] -> Visão da 1ª coluna
		//aXML[SECAO][1][3] -> Tipo da 1ª coluna
		//aXML[SECAO][1][4] -> URL da 1ª coluna
		//aXML[SECAO][1][5] -> Proporção
		//aXML[SECAO][2][1] -> Opção da 2ª coluna
		//aXML[SECAO][2][2] -> Visão da 2ª coluna
		//aXML[SECAO][2][3] -> Tipo da 2ª coluna
		//aXML[SECAO][2][4] -> URL da 2ª coluna

	EndIf

	If lRet
		self:limpacombo()
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} limpacombo
Método responsável por limpar os combos para troca das seções

@author Jorge Luis Branco Martins Junior
@since 27/04/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD limpacombo() CLASS TJurPesquisa
	self:cCmbOpc1 := ""
	self:cCmbVis1 := ""
	self:cCmbTp1  := ""
	self:cURL1    := SPACE(150)
	self:cCmbPerc := ""
	self:cCmbOpc2 := ""
	self:cCmbVis2 := ""
	self:cCmbTp2  := ""
	self:cURL2    := SPACE(150)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} bVldFinish
Método responsável validar o botão de Finalizar do Wizard

@author Jorge Luis Branco Martins Junior
@since 27/04/15
@version 1.0
@param lRestore: Valida se deve ser recuperado a configuração Default
/*/
// Willian - 31/03/17 - Criação do Parâmetro lRestore
//-------------------------------------------------------------------
METHOD bVldFinish(lRestore) CLASS TJurPesquisa
	Local cXMLreg    := self:criaXML()
	Local cUserId    := __CUSERID
	Local cRotinaAtu := self:cRotina
	local lReturn    := .F.

	dbSelectArea('NZE')
	NZE->(dbSetOrder(1))

	If (lRestore)
		If NZE->(dbSeek(xFilial('NZE') + cUserId + cRotinaAtu))
			RecLock("NZE", .F.)
			NZE->(DbDelete())
			NZE->(MsUnLock())
			MsgInfo("Configuração redefinida. Para visualizar a nova Área de Trabalho finalize o wizard, feche a tela e entre novamente.")
			lReturn := .T.
		EndIf
	Else
		If !NZE->(dbSeek(xFilial('NZE') + cUserId + cRotinaAtu))
			RecLock("NZE", .T.)
			NZE->NZE_FILIAL := FWxFilial('NZE')
			NZE->NZE_USER   := cUserId
			NZE->NZE_ROTINA := cRotinaAtu
			NZE->NZE_LAYOUT := cXMLreg
			NZE->(MsUnLock())
		Else
			RecLock("NZE", .F.)
			NZE->NZE_LAYOUT := cXMLreg
			NZE->(MsUnLock())
		EndIf
		MsgInfo(STR0082)//"Configuração realizada com sucesso. Para visualizar sua nova Área de Trabalho saia e entre novamente nessa tela"
	EndIf
Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} getXML
Método responsável por buscar o XML existente para alteração ou consulta

@author Jorge Luis Branco Martins Junior
@since 27/04/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getXML() CLASS TJurPesquisa

	Local aPanel    := {}
	Local aLayout   := {}
	Local cXML      := ""
	Local cUser     := __CUSERID
	Local cRotina   := self:cRotina
	Local cError    := ""
	Local cWarning  := ""
	Local oXml      := NIL
	local nSec      := 0
	Local nProp     := 0
	Local nItem     := 0
	local nI
	local nJ
	Local aVisao
	Local aTipo
	Local lLinhaInteira
	Local lRet := .F.

	Local cId    := ""
	Local cOpcao := ""
	Local cVisao := ""
	Local cTipo  := ""
	Local cFonte := ""
	Local cUrl   := ""

	Local oTableAttach := FWGetAttSrc( self:cRotina )

	If oTableAttach <> nil
		aVisao := oTableAttach:aViews
		aTipo  := oTableAttach:aCharts
	EndIf

	dbSelectArea('NZE')
	NZE->(dbSetOrder(1))
	If NZE->(dbSeek(xFilial('NZE') + cUser + cRotina))
		cXML := NZE->NZE_LAYOUT
		self:llayout := .T.
		lRet := .T.
	EndIf

	oXml := XmlParser( cXML, "_", @cError, @cWarning )

	If (oXml == NIL )
		lRet := .F.
	EndIf

	If lRet .And. ValType(oXml:_LAYOUT:_SESSAO) != 'O'

		nSec := Len(oXml:_LAYOUT:_SESSAO)

		If nSec > 0
			For nI := 1 To nSec

				nProp := Val(oXml:_LAYOUT:_SESSAO[nI]:_PROPORCAO:Text)

				If ValType(oXml:_LAYOUT:_SESSAO[nI]:_ITEM) == 'O'
					cId     := oXml:_LAYOUT:_SESSAO[nI]:_ITEM:_ID:Text
					cOpcao  := oXml:_LAYOUT:_SESSAO[nI]:_ITEM:_OPCAO:Text

					lLinhaInteira := .T.

					aAdd(aLayout,{cId,nProp,lLinhaInteira})

					If cOpcao == STR0067 //'Gráfico'
						cVisao := oXml:_LAYOUT:_SESSAO[nI]:_ITEM:_GRAFICO:_VISAO:Text
						cTipo  := oXml:_LAYOUT:_SESSAO[nI]:_ITEM:_GRAFICO:_TIPO:Text
						cFonte := oXml:_LAYOUT:_SESSAO[nI]:_ITEM:_GRAFICO:_FONTE:Text
					ElseIf cOpcao == STR0069 //'WebBrowser'
						cUrl   :=  oXml:_LAYOUT:_SESSAO[nI]:_ITEM:_URL:_PATH:Text
					EndIf

					aAdd(aPanel ,{cId,cOpcao,cVisao,cTipo,cFonte,cUrl,nI,1,nProp,nSec})

				ElseIf ValType(oXml:_LAYOUT:_SESSAO[nI]:_ITEM) == 'A'

					nItem := Len(oXml:_LAYOUT:_SESSAO[nI]:_ITEM)

					For nJ := 1 To nItem

						cId     := oXml:_LAYOUT:_SESSAO[nI]:_ITEM[nJ]:_ID:Text
						cOpcao  := oXml:_LAYOUT:_SESSAO[nI]:_ITEM[nJ]:_OPCAO:Text

						If nItem == 1
							lLinhaInteira := .T.
						Else
							lLinhaInteira := .F.
						EndIf

						aAdd(aLayout,{cId,nProp,lLinhaInteira})

						If cOpcao == STR0067 //'Gráfico'
							cVisao := oXml:_LAYOUT:_SESSAO[nI]:_ITEM[nJ]:_GRAFICO:_VISAO:Text
							cTipo  := oXml:_LAYOUT:_SESSAO[nI]:_ITEM[nJ]:_GRAFICO:_TIPO:Text
							cFonte := oXml:_LAYOUT:_SESSAO[nI]:_ITEM[nJ]:_GRAFICO:_FONTE:Text
						ElseIf cOpcao == STR0069 //'WebBrowser'
							cUrl   :=  oXml:_LAYOUT:_SESSAO[nI]:_ITEM[nJ]:_URL:_PATH:Text
						EndIf

						aAdd(aPanel ,{cId,cOpcao,cVisao,cTipo,cFonte,cUrl,nI,nJ,nProp,nSec})
					Next
				EndIf
			Next
		EndIf

	ElseIf lRet .And. ValType(oXml:_LAYOUT:_SESSAO) != 'A'

		nProp := Val(oXml:_LAYOUT:_SESSAO:_PROPORCAO:Text)

		If ValType(oXml:_LAYOUT:_SESSAO:_ITEM) == 'O'
			cId     := oXml:_LAYOUT:_SESSAO:_ITEM:_ID:Text
			cOpcao  := oXml:_LAYOUT:_SESSAO:_ITEM:_OPCAO:Text

			lLinhaInteira := .T.

			aAdd(aLayout,{cId,nProp,lLinhaInteira})

			If cOpcao == STR0067 //'Gráfico'
				cVisao := oXml:_LAYOUT:_SESSAO:_ITEM:_GRAFICO:_VISAO:Text
				cTipo  := oXml:_LAYOUT:_SESSAO:_ITEM:_GRAFICO:_TIPO:Text
				cFonte := oXml:_LAYOUT:_SESSAO:_ITEM:_GRAFICO:_FONTE:Text
			ElseIf cOpcao == STR0069 //'WebBrowser'
				cUrl   :=  oXml:_LAYOUT:_SESSAO:_ITEM:_URL:_PATH:Text
			EndIf

			aAdd(aPanel ,{cId,cOpcao,cVisao,cTipo,cFonte,cUrl,1,1,nProp,1})

		ElseIf ValType(oXml:_LAYOUT:_SESSAO:_ITEM) == 'A'

			nItem := Len(oXml:_LAYOUT:_SESSAO:_ITEM)

			For nJ := 1 To nItem

				cId     := oXml:_LAYOUT:_SESSAO:_ITEM[nJ]:_ID:Text
				cOpcao  := oXml:_LAYOUT:_SESSAO:_ITEM[nJ]:_OPCAO:Text

				If nItem == 1
					lLinhaInteira := .T.
				Else
					lLinhaInteira := .F.
				EndIf

				aAdd(aLayout,{cId,nProp,lLinhaInteira})

				If cOpcao == STR0067 //'Gráfico'
					cVisao := oXml:_LAYOUT:_SESSAO:_ITEM[nJ]:_GRAFICO:_VISAO:Text
					cTipo  := oXml:_LAYOUT:_SESSAO:_ITEM[nJ]:_GRAFICO:_TIPO:Text
					cFonte := oXml:_LAYOUT:_SESSAO:_ITEM[nJ]:_GRAFICO:_FONTE:Text
				ElseIf cOpcao == STR0069 //'WebBrowser'
					cUrl   :=  oXml:_LAYOUT:_SESSAO:_ITEM[nJ]:_URL:_PATH:Text
				EndIf

				aAdd(aPanel ,{cId,cOpcao,cVisao,cTipo,cFonte,cUrl,1,nJ,nProp,1})
			Next
		EndIf

	EndIf

Return {aLayout,aPanel}

//-------------------------------------------------------------------
/*/{Protheus.doc} montalayout
Método responsável por montar o layout com base no XML

@author Jorge Luis Branco Martins Junior
@since 04/05/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD montalayout() CLASS TJurPesquisa
	Local lRet := .T.
	Local cId    := ""
	Local cOpcao := ""
	Local cVisao := ""
	Local cTipo  := ""
	Local cFonte := ""
	Local cUrl   := ""
	Local cIdVisao := ""
	Local cIdChart := ""
	Local nP     := 0

	Local oPnl
	Local aLayout
	Local aPanel

	Local aGetXML := self:getXML()

	Local oTableAttach := FWGetAttSrc( self:cRotina )

	If oTableAttach <> nil
		aVisao := oTableAttach:aViews
		aTipo  := oTableAttach:aCharts
	EndIf

	aLayout := aGetXML[1]
	aPanel  := aGetXML[2]

	If Len(aLayout) == Len(aPanel)
		If Len(aLayout) > 0
			Self:oDesk:SetLayout(aLayout) //layout da tela.
		Else
			lRet := .F.
		EndIf

		If Len(aPanel) > 0
			For nP := 1 to Len(aPanel)

				cId    := aPanel[nP][1]
				cOpcao := UPPER(aPanel[nP][2])
				cVisao := UPPER(aPanel[nP][3])
				cTipo  := UPPER(aPanel[nP][4])
				cFonte := UPPER(aPanel[nP][5])
				cUrl   := UPPER(aPanel[nP][6])

				If nP == 1
					oPnl := self:loadCmbConfig(Self:oDesk:getPanel(cId))
				Else
					oPnl := Self:oDesk:getPanel(cId)
				EndIf

				oPnl:Align := CONTROL_ALIGN_ALLCLIENT
				oPnl:ReadClientCoors(.T.,.T.)

				Do Case
				Case cOpcao == UPPER(STR0065)//Opção GRID
					Self:loadGrid(oPnl)
					If self:cRotina == 'JURA095'
						Self:oFila := TJurFilaImpressao():New(oPnl,Self,Self:oPnlCfgFila,Self:oLstPesq)
					EndIf
				Case cOpcao == UPPER(STR0066)//Opção CAMPOS
					Self:loadAreaCampos(oPnl)
				Case cOpcao == UPPER(STR0067)//Opção GRÁFICO
					cIdVisao := aVisao[aScan(aVisao,{|x| UPPER(x:cname) == cVisao})]:cId
					cIdChart := aTipo[aScan(aTipo,{|x| UPPER(x:cname) == cTipo})]:cId
					aAdd(Self:aGraficos,Self:getGrafico(oPnl, Self:cTabPadrao, cFonte, MODE_VIEW_CHART, cIdVisao,cIdChart ) )
				Case cOpcao == UPPER(STR0068)//Opção CALENDÁRIO
					Self:getCalendario(oPnl)
				Case cOpcao == UPPER(STR0069)//Opção WEBBROWSER
					Self:loadurl(oPnl,cUrl)
				End Case
			Next
		Else
			lRet := .F.
		EndIf
	EndIf

Return lRet

//------------------------------------------------------------------------------------
/*/{Protheus.doc} vldUrl

Valida a URL

@sample		vldUrl( cUrl )

@param			cUrl - URL a ser validada

@return		ExpL - Verdadeiro / Falso

@author		Jorge Luis Branco Martins Junior
@since			29/04/2015
@version		1.0
/*/
//-------------------------------------------------------------------------------------
METHOD vldUrl( cUrl ) CLASS TJurPesquisa
	Local lRet  := .T.
	Local cResponse

	Default cUrl := ""

	If !Empty(cUrl)
		cResponse := HTTPGet( AllTrim( cUrl ) )
		If ValType( cResponse ) <> "C"
			lRet := .F.
			self:msgpanel( 6 )		// "Não foi possível validar a página digitada!"
		EndIf
	Else
		lRet := .F.
		self:msgpanel( 3 )
	EndIf

Return ( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} criaXML
Método responsável por criar o XML usado para salvar os layouts criados

@author Jorge Luis Branco Martins Junior
@since 27/04/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD criaXML() CLASS TJurPesquisa
	Local cScript := ""
	Local cSecao  := ""
	Local aDados  := self:aXML
	Local nI      := 0
	Local nJ      := 0
	Local nId     := 0
	Local cProp   := ""
	Local cTamanho:= ""
	Local cOpcao  := ""
	Local cVisao  := ""
	Local cTipo   := ""
	Local cUrl    := ""

	//aXML[SECAO]
	//aXML[SECAO][OPCAO1][1] -> Opção da 1ª coluna
	//aXML[SECAO][OPCAO1][2] -> Visão da 1ª coluna
	//aXML[SECAO][OPCAO1][3] -> Tipo da 1ª coluna
	//aXML[SECAO][OPCAO1][4] -> URL da 1ª coluna
	//aXML[SECAO][OPCAO1][5] -> Proporção
	//aXML[SECAO][OPCAO2][1] -> Opção da 2ª coluna
	//aXML[SECAO][OPCAO2][2] -> Visão da 2ª coluna
	//aXML[SECAO][OPCAO2][3] -> Tipo da 2ª coluna
	//aXML[SECAO][OPCAO2][4] -> URL da 2ª coluna

	nId := 1

	For nI := 1 to Len(aDados)

		If Len(aDados[nI]) > 1
			cTamanho := '50'
		Else
			cTamanho := '100'
		EndIf

		cProp   := aDados[nI][1][5]
		cSecao += '<sessao>'
		cSecao += '<proporcao>'+cProp+'</proporcao>'

		For nJ := 1 to Len(aDados[nI])

			cOpcao := aDados[nI][nJ][1]
			cVisao := aDados[nI][nJ][2]
			cTipo  := aDados[nI][nJ][3]
			cUrl   := aDados[nI][nJ][4]

			cSecao += '<item>'
			cSecao +=   '<id>'+PADL(ALLTRIM(STR(nId++)),2,"0")+'</id>'
			cSecao +=   '<tamanho>'+cTamanho+'</tamanho>'
			cSecao +=   '<opcao>'+cOpcao+'</opcao>'
			If cOpcao == STR0067 //'Gráfico'
				cSecao += '<grafico>'
				cSecao +=   '<visao>'+cVisao+'</visao>'
				cSecao +=   '<tipo>'+cTipo+'</tipo>'
				cSecao +=   '<fonte>'+self:cRotina+'</fonte>'
				cSecao += '</grafico>'
			ElseIf cOpcao == STR0069 //'WebBrowser'
				cSecao += '<url>'
				cSecao +=   '<path>'+cUrl+'</path>'
				cSecao += '</url>'
			EndIf
			cSecao += '</item>'
		Next
		cSecao += '</sessao>'
	Next

	cScript := '<?xml version="1.0" encoding="ISO-8859-1"?>'
	cScript += "<layout>"
	cScript += cSecao
	cScript += "</layout>"

return cScript

static function getXmlTest()
	local cScript

	cScript := '<?xml version="1.0" encoding="ISO-8859-1"?>'
	cScript += "<equipe>"
	cScript += "	<recurso>"
	cScript += "    <nome>Raphael Zei</nome>"
	cScript += "	</recurso>"
	cScript += "</equipe>"

return cScript

//---------------------------------------------------------------------------
/*/{Protheus.doc} getGrafico

Monta GRAFICO de follow-up

@sample  getGrafico( oPanel, cAliasEnt, cFonte, cType, cVision, cChart )

@param   oPanel     - Objeto onde será montada a GRID
cAliasEnt - Entidade para qual sera montada a grid
cFonte    - Nome do Fonte para busca das VISOES e GRAFICOS
cType     - Tipo de exibição
cVision   - Visão do gráfico
cChart    - Tipo do gráfico

@return	ExpO - Panel

@author	André Spirigoni Pinto
@since		05/02/2015
@version	1.0
/*/
//---------------------------------------------------------------------------
METHOD getGrafico( oPanel, cAliasEnt, cFonte, cType, cVision, cChart ) CLASS TJurPesquisa
	Local oWidget      := FWTableAttachWidget():New()
	Local oTableAttach := FWGetAttSrc( cFonte )
	Local aVisions     := {}
	Local aCharts      := {}
	Local oMBrowse     := oWidget:GetBrowse()
	Local nVis         := 1
	Local nCht         := 1

	Default cVision := Nil
	Default cChart  := Nil

	If oTableAttach <> nil

		oMBrowse:SetMenuDef( cFonte )

		aVisions := oTableAttach:aViews
		aCharts  := oTableAttach:aCharts

		oWidget:setVisions( aVisions )
		oWidget:setCharts( aCharts )
		oWidget:setAlias( cAliasEnt )

		if (cVision != NIl)
			nVis := aScan(aVisions,{|x| x:getID() == cVision})
			if nVis == 0
				nVis := 1
			Endif
		Endif

		if (cChart != NIl)
			nCht := aScan(aCharts,{|x| x:getID() == cChart})
			if nCht == 0
				nCht := 1
			Endif
		Endif

		oWidget:setVisionDefault( aVisions[nVis] )
		oWidget:setChartDefault( aCharts[nCht] )
		oWidget:setDisplayMode( cType )
		oWidget:setOwner( oPanel )
		oWidget:setOpenChart( .T. )
		oWidget:Activate()

	EndIf

Return oWidget

//-------------------------------------------------------------------
/*/{Protheus.doc} getCfg
Busca a configuração já criada para carrega-la quando clicar em
configuração no Menu

@author Jorge Luis Branco Martins Junior
@since 04/05/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getCfg(nSecao, nBack, lbChange) CLASS TJurPesquisa
	Local lRet := .T.
	Local aLayout
	Local aPanel
	Local aGetXML := self:getXML()
	Local cOpcao, cVisao, cTipo, cUrl, nItem, nProp
	Local aXml   := {}
	Local nP
	Local nSec

	Default nSecao   := '0'
	Default nBack    := 0
	Default lbChange := .T.

	If ValType(nSecao) == 'C'
		nSecao := val(nSecao)
	EndIf

	If nBack == 1 .And. !self:lBack

		nSec := nSecao+1
		If Len(self:aXML) >= (nSec)
			self:aXML[nSec][1] := {self:cCmbOpc1,self:cCmbVis1,self:cCmbTp1,self:cURL1,self:cCmbPerc}
			If !Empty(AllTrim(self:cCmbOpc2))
				If Len(self:aXML[nSec]) == 2
					self:aXML[nSec][2] := {self:cCmbOpc2,self:cCmbVis2,self:cCmbTp2,self:cURL2,self:cCmbPerc}
				Else
					aAdd(self:aXML[nSec],{ self:cCmbOpc2,self:cCmbVis2,self:cCmbTp2,self:cURL2,self:cCmbPerc})
				EndIf
			Else
				If Len(self:aXML[nSec]) == 2
					aDel(self:aXML[nSec],Len(self:aXML[nSec]))
					aSize(self:aXML[nSec],1)
				EndIf
			EndIf
		Else
			aAdd(self:aXML      ,{{self:cCmbOpc1,self:cCmbVis1,self:cCmbTp1,self:cURL1,self:cCmbPerc}})
			If !Empty(AllTrim(self:cCmbOpc2))
				aAdd(self:aXML[nSec],{ self:cCmbOpc2,self:cCmbVis2,self:cCmbTp2,self:cURL2,self:cCmbPerc})
			EndIf
		EndIf

		self:lBack := .T.
		aXml := self:aXML[nSecao]

		self:cCmbPerc := Alltrim(aXml[1][5])
		self:cCmbOpc1 := Alltrim(aXml[1][1])
		self:cCmbVis1 := Alltrim(aXml[1][2])
		self:cCmbTp1  := Alltrim(aXml[1][3])
		self:cURL1    := Alltrim(aXml[1][4])

		If Len(aXml) == 1
			self:cCmbOpc2 := ""
			self:cCmbVis2 := ""
			self:cCmbTp2  := ""
			self:cURL2    := SPACE(150)
		ElseIf Len(aXml) == 2
			self:cCmbOpc2 := Alltrim(aXml[2][1])
			self:cCmbVis2 := Alltrim(aXml[2][2])
			self:cCmbTp2  := Alltrim(aXml[2][3])
			self:cURL2    := Alltrim(aXml[2][4])
		EndIf

	Else

		If self:lBack .And. lbChange
			self:lBack := .F.
		Else

			If Len(self:aXML) >= nSecao .And. nSecao >= 1
				aXml := self:aXML[nSecao]

				self:cCmbPerc := Alltrim(aXml[1][5])
				self:cCmbOpc1 := Alltrim(aXml[1][1])
				self:cCmbVis1 := Alltrim(aXml[1][2])
				self:cCmbTp1  := Alltrim(aXml[1][3])
				self:cURL1    := Alltrim(aXml[1][4])

				If Len(aXml) == 1
					self:cCmbOpc2 := ""
					self:cCmbVis2 := ""
					self:cCmbTp2  := ""
					self:cURL2    := SPACE(150)
				ElseIf Len(aXml) == 2
					self:cCmbOpc2 := Alltrim(aXml[2][1])
					self:cCmbVis2 := Alltrim(aXml[2][2])
					self:cCmbTp2  := Alltrim(aXml[2][3])
					self:cURL2    := Alltrim(aXml[2][4])
				EndIf
			Else

				aLayout := aGetXML[1]
				aPanel  := aGetXML[2]

				If Len(aLayout) == Len(aPanel)
					If Len(aPanel) > 0

						If nSecao > 0
							self:cCmbOpc2 := ""
							self:cCmbVis2 := ""
							self:cCmbTp2  := ""
							self:cURL2    := SPACE(150)
						EndIf

						For nP := 1 to Len(aPanel)
							If nSecao == 0 .and. nP == 1
								self:cQtdSec := cValToChar(aPanel[nP][10])
							ElseIf nSecao == aPanel[nP][7]
								cOpcao := UPPER(aPanel[nP][2])
								cVisao := aPanel[nP][3]
								cTipo  := aPanel[nP][4]
								cUrl   := aPanel[nP][6]
								nItem  := aPanel[nP][8]
								If self:cQtdSec == '1'
									nProp  := 100
									self:lSecUnica := .T.
								Else
									nProp  := aPanel[nP][9]
									self:lSecUnica := .F.
								EndIf

								self:cCmbPerc := str(nProp)

								Do Case
								Case cOpcao == UPPER(STR0065)//Opção GRID
									If nItem == 1
										self:cCmbOpc1 := STR0065
									ElseIf nItem == 2
										self:cCmbOpc2 := STR0065
									EndIf
								Case cOpcao == UPPER(STR0066)//Opção CAMPOS
									If nItem == 1
										self:cCmbOpc1 := STR0066
									ElseIf nItem == 2
										self:cCmbOpc2 := STR0066
									EndIf
								Case cOpcao == UPPER(STR0067)//Opção GRÁFICO
									If nItem == 1
										self:cCmbOpc1 := STR0067
										self:cCmbVis1 := cVisao
										self:cCmbTp1  := cTipo
									ElseIf nItem == 2
										self:cCmbOpc2 := STR0067
										self:cCmbVis2 := cVisao
										self:cCmbTp2  := cTipo
									EndIf
								Case cOpcao == UPPER(STR0068)//Opção CALENDÁRIO
									If nItem == 1
										self:cCmbOpc1 := STR0068
									ElseIf nItem == 2
										self:cCmbOpc2 := STR0068
									EndIf
								Case cOpcao == UPPER(STR0069)//Opção WEBBROWSER
									If nItem == 1
										self:cCmbOpc1 := STR0069
										self:cURL1    := cUrl
									ElseIf nItem == 2
										self:cCmbOpc2 := STR0069
										self:cURL2    := cUrl
									EndIf
								End Case
							EndIf
						Next
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet

	//-------------------------------------------------------------------
	/*/{Protheus.doc} loadurl(oPanel)

	Função que vai carregar a área onde será exibida a página web

	@author Jorge Luis Branco Martins Junior
	@since 04/05/15
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD loadurl(oPanel,cUrl) CLASS TJurPesquisa

	If self:vldloadurl()
		Self:oUrl := Nil
		Self:oUrl := TIBrowser():New( 0, 0, oPanel:nWidth, oPanel:nHeight, cUrl, oPanel )
		Self:oUrl:Align := CONTROL_ALIGN_ALLCLIENT
	EndIf

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} vldloadurl

Verifica se a Navegador de Internet está configurado no SmartClient do usuario.

@sample 	vldloadurl()

@param		Nenhum

@return   	ExpL - Verdadeiro / Falso

@author	Jorge Luis Branco Martins Junior
@since		05/05/2014
@version	1.0
/*/
//------------------------------------------------------------------------------
METHOD vldloadurl() CLASS TJurPesquisa

	Local lRetorno 	:= .F.
	Local cClientIni	:= GetRemoteIniName()
	Local cRetorno	:= "0"

	cRetorno := GetPvProfString( "Config" , "BrowserEnabled" , cRetorno, cClientIni )

	If cRetorno == "1"
		lRetorno := .T.
	EndIf

Return ( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} getQtdReg
Função utilizada para informar a quantidade de registros estão na fila de impressão.
Uso Geral.

@Param	nQtd	Quantidade de resistros.

@author André Spirigoni Pinto
@since 10/05/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getQtdReg() CLASS TJurPesquisa
Return Self:nQtdReg

//-------------------------------------------------------------------
/*/{Protheus.doc} getFiltro
Método utilizado para retornar os filtros realizados na tela de pesquisa

@Param	nQtd	Quantidade de resistros.

@author André Spirigoni Pinto
@since 10/05/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getFiltro() CLASS TJurPesquisa
	Local aSQL := {}
	Local nX
	Local aTroca := {}
	Local cTpAJ := AllTrim( JurSetTAS(.F.) )

	AAdd(aTroca,{Self:cTabPadrao, RetSqlName(Self:cTabPadrao)})
	AAdd(aTroca,{"NSZ", "NSZ001"})

	//Campos da tela
	For nX := 1 to Len(Self:aObj)
		If !(Self:aObj[nX] == NIL) .And. !(Empty(Self:aObj[nX]:Valor))
			aAdd(aSQL, {Self:aObj[nX]:GetTable(),Self:TrocaWhere(Self:aObj[nX],aTroca)})// Tabela  Where
		Endif
	Next

	aAdd(aSQL,{RetSqlName("NSZ"),"AND NSZ001.NSZ_TIPOAS IN (" + cTpAJ + ")"})

	if (Self:cTabPadrao != "NSZ")
		aAdd(aSQL,{RetSQlName(Self:cTabPadrao), "AND 1 = 1"})
	Endif

return aSQL

//-------------------------------------------------------------------
/*/{Protheus.doc} getTipoAs
Função que retorna o tipo de assunto posicionado no Grid ou na linha escolhida

@author André Spirigoni Pinto
@since 08/05/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getTipoAs() CLASS TJurPesquisa
Return JurGetDados('NSZ',1,Self:getFilial() + Self:getCajuri(),'NSZ_TIPOAS')

//---------------------------------------------------------------------------
/*/{Protheus.doc} getComplLote

Função que retorna campos que contenham campos complementares de tabelas que devem aparecer na alteração em lote

@author	André Lago
@since		04/05/2015
/*/
//---------------------------------------------------------------------------
METHOD getComplLote() CLASS TJurPesquisa
Return {}

//---------------------------------------------------------------------------
/*/{Protheus.doc} VlAltLote

Função que valida os campos complementares de tabelas que devem aparecer na alteração em lote

@author	André Lago
@since		06/08/2015
/*/
//---------------------------------------------------------------------------
METHOD VlAltLote() CLASS TJurPesquisa
Return .T.

//---------------------------------------------------------------------------
/*/{Protheus.doc} setFilial

Função que altera a filial corrente para a selecionada pelo usuário.
@author	Clóvis Eduardo Teixeira
@since		11/05/2015
/*/
//---------------------------------------------------------------------------
METHOD setFilial(oLstPesq, nOpc,aEnvBkp) Class TJurPesquisa

	Local lAcessa := .F.
	Local lRet    := .T.

	Default nOpc  := 3

	lAcessa := JURVLDEDIT ( nOpc, IIf (nOpc == 3,aEnvBkp[1],self:getFilial() ),aEnvBkp )

	If !lAcessa
		// Não permite o acesso
		JurMsgErro(STR0086 ,'JURA162')//"Usuário não possui acesso para editar Múltiplas Filiais"
		//Restaura a Filial Corrente
		If Len(aEnvBkp) > 0
			JURRESTFIL( aEnvBkp )
		Endif
		lRet := .F.
	Endif

Return lRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Destroy objeto da memoria

@author	Rafael Tenorio da Costa
@since	08/10/2015
/*/
//---------------------------------------------------------------------------
METHOD Destroy( oObjeto ) CLASS TJurPesquisa

	If (oObjeto != Nil)
		oObjeto:Destroy()
		FreeObj( oObjeto )
		oObjeto := Nil
	Endif

Return Nil

	//-------------------------------------------------------------------
	/*/{Protheus.doc} JHabLote()
	Função utilizada para habilitar a exibição do botão de Alteração em Lote
	Uso Geral.

	@author Wellington Coelho
	@since 09/12/15
	@version 1.0
	/*/
//-------------------------------------------------------------------
METHOD JHabLote() CLASS TJurPesquisa
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} setMenRest
Função para setar e limpar as teclas de atalho

@author Wellington Coelho
@since 30/03/16
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD JTecAtalho(lSetAtalho) CLASS TJurPesquisa
	Local nI

	For nI := 1 to len(Self:aTecAtalho)
		If lSetAtalho
			SetKEY(Self:aTecAtalho[nI][1],Self:aTecAtalho[nI][2])
		Else
			SetKEY(Self:aTecAtalho[nI][1],{||})
		EndIf
	Next nI

Return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} fillGrid
Retorna o restante das linhas do grid.
  
@author	André Spirigoni Pinto
@since	22/06/2016
/*/
//---------------------------------------------------------------------------
METHOD fillGrid() CLASS TJurPesquisa

	if !Empty(Self:cCurRec) //valida se existem registros pendentes
		Self:getMoreRows()
	Endif

Return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} refreshLegenda
Faz a atualização da coluna de legenda da linha posicionada.
  
@author	André Spirigoni Pinto
@since	09/02/2017
/*/
//---------------------------------------------------------------------------
METHOD refreshLegenda() CLASS TJurPesquisa

	if self:bLegenda != Nil
		self:oLstPesq:aCols[self:oLstPesq:nAt][1] := Eval(self:bLegenda)
	Endif

Return .T.

//---------------------------------------------------------------------------
/*/{Protheus.doc} resetLay(oWizard)
Ação do botão "Redefinir padrão" do Wizard de Customização da área de trabalho

@param oWizard - Wizard para habilitar o botão de finish  
@author	Willian Yoshiaki Kazahaya
@since	04/04/2017
/*/
//---------------------------------------------------------------------------
METHOD resetLay(oWizard) CLASS TJurPesquisa
	Local lSetFim := .F.
	lSetFim := self:bVldFinish(.T.)
	// Se ocorreu a exclusão, troca o botão de "Avançar" pelo botão de "Finalizar"
	If (lSetFim)
		oWizard:SetFinish()
	EndIf
return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} menuAnexos
Chamada da tela de anexos
  
@author Willian.Kazahaya
@since	01/03/2018
/*/
//---------------------------------------------------------------------------
METHOD menuAnexos() CLASS TJurPesquisa

	JurAnexos(Self:cTabPadrao, Self:getCodigo(), 1, Self:getFilial() )
	self:refreshLegenda()

Return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} getComplExc

Função que retorna campos complementares de campos presentes na Excecao que devem aparecer na alteração em lote 

@author Breno Gomes
@since 27/12/2019
/*/
//---------------------------------------------------------------------------
METHOD getComplExc() CLASS TJurPesquisa
Return {}


//---------------------------------------------------------------------------
/*/{Protheus.doc} getComplExc

Abre tela com campo complementar diferente diferente dos campos de motivo de encerramento

@author Breno Gomes
@since 30/12/2019
/*/
//---------------------------------------------------------------------------
METHOD getTelaExtr() CLASS TJurPesquisa
Return {}


//---------------------------------------------------------------------------
/*/{Protheus.doc} ConfAltLot
Confirma alteralçao de registros

@param nQtdReg - Quantidade de registros
@since 11/02/2021
/*/
Static Function ConfAltLot(nQtdReg) 
Local lRet      := .T.
Default nQtdReg := 0

	If nQtdReg > 100
		lRet := ApMsgYesNo(I18N(STR0100, {cValToChar(nQtdReg)}))
	EndIf

Return lRet
