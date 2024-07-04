#INCLUDE "Protheus.ch"
#INCLUDE "Colors.ch"
#INCLUDE "FINI010.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPxCMonit  บAutor  ณ Alberto Deviciente บ Data ณ 19/Mai/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera Interface de grafica da rotina "Monitor de Transa็๕es" บฑฑ
ฑฑบ          ณda integracao Protheus x Classis                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integracao Protheus x RM Classis Net (RM Sistemas)         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบOBS:	  	 ณFuncao antiga chamava-se InWinConfl 						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function FINI010()
Local oDlgKco
Local cCadastro 	:= STR0001 //"Integra็ใo Protheus x RM Classis Net - Monitor de Transa็๕es"
Local aSize 		:= MsAdvSize(,.F.,430)
Local oGprFilttbl,oGprFiltros,oGprFilTbs
Local nMeter		:= 0
Local oExit,oVisualiza,oConfirma
Local nInd 			:= 0
Local oFiltro
Local nMinAtTela 	:= 0
Local nFilTabela	:= 1 //Todas Tabelas

Private aTabelas 	:= {}
Private aObjects  	:= {}
Private aPosObj   	:= {}
Private aInfo       := {}
Private oReguaProc
Private oTabsINT
Private aTabsINT    := {}
Private oVerde		:= LoadBitmap( GetResources(), "BR_VERDE" )
Private oVermelho	:= LoadBitmap( GetResources(), "BR_VERMELHO" )
Private oAmarelo	:= LoadBitmap( GetResources(), "BR_AMARELO" )
Private oPreto		:= LoadBitmap( GetResources(), "BR_PRETO" )
Private oAzul		:= LoadBitmap( GetResources(), "BR_AZUL" )
Private oCinza		:= LoadBitmap( GetResources(), "BR_CINZA" )
Private lMSSQL	    := "MSSQL"$Upper(TCGetDB())							//Variaveis para tratamento de Banco de dados
Private lOracle	    := "ORACLE"$Upper(TCGetDB())
Private nHRes		:=	GetScreenRes()[1]	//Resolucao Horizontal do monitor
Private nVRes		:=	GetScreenRes()[2]	//Resolucao Vertical do monitor
Private aCamposAlt  := {}
Private cSQLVersao  := ""
Private oSay
Private cCmpBloq 	:= "_COLIGADA/_FILIAL/_ID/_DATAGRAVA/_HORAGRAVA/_USUGRAVA/_PROCIMPORT/_STATUSIMPORT/_OBSIMPORT/_ROTIMPORT/_ROTGRAVA" //Campos bloqueados para edicao

//Valor inicial do Timer para Atualizacao automatica (Refresh) da tela
nMinAtTela := GetNewPar("MV_FNTIMER", 1)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBusca a Versao do Banco de Dados SQL Server Utilizadoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
if lMSSQL
	if Select("INFOSQL") > 0
		INFOSQL->( dbCloseArea() )
	endif
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,"SELECT @@version as VERSAO"), "INFOSQL", .F., .T.)
	cSQLVersao := INFOSQL->VERSAO
	INFOSQL->( dbCloseArea() )
	for nInd:=1 to 3
		cSQLVersao := AllTrim(SubStr(cSQLVersao,At(" ",cSQLVersao)))
	next nInd
	cSQLVersao := AllTrim(SubStr(cSQLVersao,1,At(" ",cSQLVersao)))
endif


AAdd( aObjects, {  50,  70, .T., .F. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

oDlgKco:= MSDIALOG():Create()
oDlgKco:cName     		:= "ODlgKco"
oDlgKco:cCaption  		:= cCadastro
oDlgKco:nLeft     		:= 0
oDlgKco:nTop      		:= 0
oDlgKco:nWidth    		:= 973
oDlgKco:nHeight   		:= 560
oDlgKco:lShowHint 		:= .F.
oDlgKco:lCentered 		:= .T.

oSay:= TSay():New( 160/*<nRow>*/, 005/*<nCol>*/, {|| STR0002 } /*<{cText}>*/, oDlgKco/*[<oWnd>]*/, /*[<cPict>]*/, /*<oFont>*/, /*<.lCenter.>*/, /*<.lRight.>*/, /*<.lBorder.>*/, .T./*<.lPixel.>*/, CLR_HBLUE/*<nClrText>*/, /*<nClrBack>*/, 200/*<nWidth>*/, 8/*<nHeight>*/, /*<.design.>*/, /*<.update.>*/, /*<.lShaded.>*/, /*<.lBox.>*/, /*<.lRaised.>*/, /*<.lHtml.>*/ )
oSay:LVISIBLECONTROL := .F.

//Regua de processamento de atualizacao da tela
oReguaProc:= tMeter():New(170,005,{|u|if(Pcount()>0,nMeter:=u,nMeter)},0,oDlgKco,iif(nHRes==800,250,390),010,,.T.) //Cria a regua de progressao

oTimer:= TTimer():New(PxCTimer(nMinAtTela),{|| PxCListTbl(nFilTabela) },oDlgKco)	// Ativa timer

oGprFilttbl := TGROUP():Create(oDlgKco)
oGprFilttbl:cName := "oGprFiltros"
oGprFilttbl:cCaption := STR0003 //"Tabelas de Integra็ใo"
oGprFilttbl:nLeft := 2
oGprFilttbl:nTop := 10
oGprFilttbl:nWidth := aSize[5]-iif(nHRes==800,156,200)
oGprFilttbl:nHeight := aSize[6]-iif(nHRes==800,115,270)
oGprFilttbl:lShowHint := .F.
oGprFilttbl:lReadOnly := .F.
oGprFilttbl:Align := 0
oGprFilttbl:lVisibleControl := .T.

//Listagem por tabela de Integracao
if len(aTabsINT) == 0
	aAdd( aTabsINT, { "2", Space(20), Space(150), ctod("  /  /  "), Space(5), 0, 0 }  )
endif
oTabsINT := VCBrowse():New( 013 , 004, 390, 120,,{"",STR0004,STR0005,STR0006,STR0007,STR0008,STR0009},{1,55,140,35,35,55,55}, oDlgKco, ,,,,{|| .t.},,,,,,,.F.,,.T.,,.F.,,, )
oTabsINT:SetArray(aTabsINT)
oTabsINT:bLine := {|| {  PxCStatTab(aTabsINT[oTabsINT:nAt,01]),;
									aTabsINT[oTabsINT:nAt,02],;
									aTabsINT[oTabsINT:nAt,03],;
									aTabsINT[oTabsINT:nAt,04],;
									aTabsINT[oTabsINT:nAt,05],;
									aTabsINT[oTabsINT:nAt,06],;
									aTabsINT[oTabsINT:nAt,07] } }
oTabsINT:bLDblClick := {|| oTabsINT:DrawSelect()}
oTabsINT:bChange := {|| iif(aTabsINT[oTabsINT:nAt,01]=="2",oConfirma:Disable(),oConfirma:Enable()) }

//Listagem de tabelas disponํveis para Integra็ใo Protheus / RM Sistemas
PxCListTbl(nFilTabela)

oGprFilTbs := TGROUP():Create(oDlgKco)
oGprFilTbs:cName := "oGprFilTbs"
oGprFilTbs:cCaption := STR0010  //"Filtrar Tabelas"
oGprFilTbs:nLeft := iif(nHRes==800,620,820)
oGprFilTbs:nTop := 20
oGprFilTbs:nWidth := 150
oGprFilTbs:nHeight := 125
oGprFilTbs:lShowHint := .F.
oGprFilTbs:lReadOnly := .F.
oGprFilTbs:Align := 0
oGprFilTbs:lVisibleControl := .T.

oFiltro := TRADMENU():Create(oDlgKco)
oFiltro:cName := "oFiltro"
oFiltro:nLeft := (iif(nHRes==800,620,820)+10)
oFiltro:nTop := 40
oFiltro:nWidth := 130
oFiltro:nHeight := 40
oFiltro:lShowHint := .F.
oFiltro:Align := 0
oFiltro:cVariable := "nFilTabela"
oFiltro:bSetGet := {|u| If(PCount()>0,nFilTabela:=u,nFilTabela) }
oFiltro:lVisibleControl := .T.
oFiltro:aItems := {STR0011, STR0012, STR0013, STR0014}
oFiltro:nOption := nFilTabela
oFiltro:bChange := {|| PxCListTbl(nFilTabela) }

oConfirma := TBUTTON():Create(oDlgKco)
oConfirma:cName := "oConfirma"
oConfirma:cCaption := STR0015 //"Detalhar Inconsist๊ncias >>"
oConfirma:nLeft := oGprFilTbs:nLeft
oConfirma:nTop := 175
oConfirma:nWidth := 132
oConfirma:nHeight := 23
oConfirma:lShowHint := .F.
oConfirma:lReadOnly := .F.
oConfirma:Align := 0
oConfirma:lVisibleControl := .T.
oConfirma:bAction := {|| MsgRun(STR0016,{|| PxCAltCon(aTabsINT[oTabsINT:nAt,2],nFilTabela)}),.t. }

oLegend := TBUTTON():Create(oDlgKco)
oLegend:cName := "oLegend"
oLegend:cCaption := STR0097//"Legenda"
oLegend:nLeft := oConfirma:nLeft
oLegend:nTop := oConfirma:nTop+35
oLegend:nWidth := 50
oLegend:nHeight := 23
oLegend:lShowHint := .F.
oLegend:lReadOnly := .F.
oLegend:Align := 0
oLegend:lVisibleControl := .T.
oLegend:bAction := {|| PxCLegTab() }

oExit := TBUTTON():Create(oDlgKco)
oExit:cName := "oExit"
oExit:cCaption := STR0098//"Sair"
oExit:nLeft := oConfirma:nLeft
oExit:nTop := oLegend:nTop+35
oExit:nWidth := 50
oExit:nHeight := 23
oExit:lShowHint := .F.
oExit:lReadOnly := .F.
oExit:Align := 0
oExit:lVisibleControl := .T.
oExit:bAction := {|| .T.,oDlgKco:End() }

TSay():New( 140, 005, {|| STR0017 } , oDlgKco,,,,,, .T.,,, 100, 008,,,,,, ) // "Atualiza tela a cada:"
@138,055 MSGET oMinAtTela Var nMinAtTela Picture "@E 999.99" SIZE 20,7 Valid PxCParTime(nMinAtTela) OF oDlgKco PIXEL WHEN .T.
TSay():New( 140, 090, {|| STR0018 } , oDlgKco,,,,,, .T.,,, 100, 008,,,,,, )

oTimer:Activate() //Ativa o Timer de Atualizacao (Refresh) da Tela

ACTIVATE MSDIALOG oDlgKco VALID (oTimer:End(),.T.)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPxCListTblบAutor  ณ Alberto Deviciente บ Data ณ 20/Mai/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que efetua filtragem de todas tabelas relativas a    บฑฑ
ฑฑบ          ณIntegracao Protheus x Classis Net                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integracao Protheus x RM Classis Net (RM Sistemas)         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบOBS:	  	 ณFuncao antiga chamava-se IntListTbl 						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PxCListTbl(nTipo)
Local cQuery 	:= ""
Local nCount    := 0
Local aArrayTbl := {}
Local cTabela 	:= ""
Local cPrfxTab 	:= ""
Local cDescTab  := ""
Local nInd 		:= 0
Local dData
Local cHora  	:= ""
Local nQtdIncons:= 0
Local nQtdPenden:= 0
Local cSituacTab:= ""
Local nTotProg  := 0
Local nContador := 0

aTabelas := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFiltro a Qual grupo a tabela pertence:	ณ
//ณ		2=Tabelas de Recursos Humanos;      ณ
//ณ		3=Tabelas de Financeiro             ณ
//ณ		4=Tabelas de LOG                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

// 				 Filtro 	Tabela				Prefixo 	Descricao
aAdd( aTabelas, { 2, 		"INT_FUNC"			, "FUN", 	 STR0019 } ) //"Funcionแrios/Professores"
aAdd( aTabelas, { 2,		"INT_TAREFA"		, "TAR", 	 STR0020 } ) //"Tarefas - Folha de Pagamento"
aAdd( aTabelas, { 3,		"INT_CLIENTE"		, "CLI", 	 STR0021 } ) //"Clientes"
aAdd( aTabelas, { 3,		"INT_TITULO"		, "TIT", 	 STR0022 } ) //"Tํtulos - Financeiro"
aAdd( aTabelas, { 4,		"INT_CCUSTOLOG"		, "CCT", 	 STR0023 } ) //"Centro de Custo - LOG"
aAdd( aTabelas, { 4,		"INT_MOEDALOG"		, "MOE", 	 STR0024 } ) //"Moeda - LOG"
aAdd( aTabelas, { 4,		"INT_TITULACAOLOG"	, "TTL", 	 STR0025 } ) //"Titula็ใo - LOG"
aAdd( aTabelas, { 4,		"INT_TIPODOCLOG"	, "TOD", 	 STR0026 } ) //"Tipo de Documento - LOG"
aAdd( aTabelas, { 4,		"INT_CONTACXALOG"	, "CXA", 	 STR0027 } ) //"Conta Caixa - LOG"

CursorWait()

if nTipo == 1 //1=Todas as Tabelas
	nTotProg := len(aTabelas)
else
	aEval( aTabelas, { |x| nTotProg += iif( x[1]==nTipo, 1, 0 ) } )
endif

//Atribui a regua de progressao, o total de passos que serao progredidos
oReguaProc:NTOTAL := nTotProg
oSay:LVISIBLECONTROL := .T.

//Inicia a regua de progressao
oReguaProc:Set(0)

for nInd := 1 to len(aTabelas)

	//Filtra as tabelas de acordo com o Filtro selecinado
	if nTipo == aTabelas[nInd][1] .or. nTipo == 1 //1=Todas as Tabelas

		//Atualiza regua de progressao
		nContador++
		oReguaProc:Set(nContador)

		cTabela	:= aTabelas[nInd][2]
		cPrfxTab:= aTabelas[nInd][3]
		cDescTab:= aTabelas[nInd][4]

		//Verifica qual a ultima data de insercao de registro na tabela de integracao
		if lMSSQL
			cQuery := "max(convert(varchar(10),"+cPrfxTab+"_DATAGRAVA,103)+convert(varchar(8),"+cPrfxTab+"_HORAGRAVA,108)) DtHrMax"
		else
			cQuery := "max(to_char("+cPrfxTab+"_DATAGRAVA,'DD/MM/YYYY')||"+cPrfxTab+"_HORAGRAVA) DtHrMax"
		endif

		cQuery := "select "+cQuery+" from "+cTabela+" "
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "_TMX", .F., .F. )

		if empty(_TMX->DtHrMax) .or. _TMX->DtHrMax == Nil
			dData := ctod("  /  /  ")
			cHora := Space(5)
		else
			dData := ctod(substr(_TMX->DtHrMax,1,10))
			cHora := substr(_TMX->DtHrMax,11,5)
		endif
		_TMX->( dbclosearea() )

		//Verifica a qtde. de registros INCONSISTENTES na tabela de integracao
		cQuery := "select count(*) QTDINCONS from "+cTabela+" where "+cPrfxTab+"_STATUSIMPORT in ('3','4')" //3=Registros com problemas; 4=Gravacao Incompleta
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "_TMX", .F., .F. )
		nQtdIncons := _TMX->QTDINCONS
		_TMX->( dbclosearea() )

		//Verifica a qtde. de registros PENDENTES na tabela de integracao
		cQuery := "select count(*) QTDPENDENTE from "+cTabela+" where "+cPrfxTab+"_STATUSIMPORT = '1'" //1=Registros Pendentes
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "_TMX", .F., .F. )
		nQtdPenden := _TMX->QTDPENDENTE
		_TMX->( dbclosearea() )

		if nQtdIncons > 0 .and. nQtdPenden > 0
			cSituacTab := "4" //Tabela c/ Inconsistencia e c/ Registro Pendente
		elseif nQtdIncons > 0
			cSituacTab := "3" //Tabela Inconsistente
		elseif nQtdPenden > 0
			cSituacTab := "1" //Tabela c/ Registro Pendente de Processamento
		else
			cSituacTab := "2" //Tabela Consistente
		endif

		aAdd( aArrayTbl, { cSituacTab, cTabela, cDescTab, dData, cHora, nQtdIncons, nQtdPenden }  )

	endif
next nInd

if len(aArrayTbl) == 0
	aAdd( aArrayTbl, { "2", Space(20), Space(150), ctod("  /  /  "), Space(5), 0, 0 }  )
endif

aTabsINT := aClone(aArrayTbl)
oTabsINT:SetArray(aTabsINT)
oTabsINT:bLine := {||{   PxCStatTab(aTabsINT[oTabsINT:nAt,01]),;
									aTabsINT[oTabsINT:nAt,02],;
									aTabsINT[oTabsINT:nAt,03],;
									aTabsINT[oTabsINT:nAt,04],;
									aTabsINT[oTabsINT:nAt,05],;
									aTabsINT[oTabsINT:nAt,06],;
									aTabsINT[oTabsINT:nAt,07] } }
oTabsINT:Refresh()

//Zera a regua de progressao
oReguaProc:Set(0)
oSay:LVISIBLECONTROL := .F.

CursorArrow()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPxCStatTabบAutor  ณ Alberto Deviciente บ Data ณ 20/Mai/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o Status (cor da legenda) da tabela de Integracao. บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ  AMARELO: Tabela c/ Registro Pendente de Processamento     บฑฑ
ฑฑบ          ณ  VERDE: Tabela Consistente                                 บฑฑ
ฑฑบ          ณ  VERMELHO: Tabela c/ Inconsistencia                        บฑฑ
ฑฑบ          ณ  PRETO: Tabela c/ Inconsistencia e c/ Registro Pendente    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integracao Protheus x RM Classis Net (RM Sistemas)         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบOBS:	  	 ณFuncao antiga chamava-se IntStatTab 						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PxCStatTab(cStatus)
Local oRet

if cStatus == "1" //Tabela c/ Registro Pendente de Processamento
	oRet := oAmarelo
elseif cStatus == "2" //Tabela Consistente
	oRet := oVerde
elseif cStatus == "3" //Tabela Inconsistente
	oRet := oVermelho
elseif cStatus == "4" //Tabela c/ Inconsistencia e c/ Registro Pendente
	oRet := oPreto
endif

Return oRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPxCStatRegบAutor  ณ Alberto Deviciente บ Data ณ 20/Mai/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o Status (cor da legenda) do registro da tabela de บฑฑ
ฑฑบ          ณ Integracao.                                                บฑฑ
ฑฑบ          ณ  AMARELO: Registro Pendente de Processamento               บฑฑ
ฑฑบ          ณ  VERMELHO: Registro Inconsistente                          บฑฑ
ฑฑบ          ณ  AZUL: Registro Pendente                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integracao Protheus x RM Classis Net (RM Sistemas)         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบOBS:	  	 ณFuncao antiga chamava-se IntStatReg 						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PxCStatReg(cStatus)
Local oRet

if cStatus == "1" //Registro Pendente de Processamento
	oRet := oAmarelo
elseif cStatus == "3" //Registro Inconsistente
	oRet := oVermelho
elseif cStatus == "4" //Registro Pendente
	oRet := oAzul
else
	oRet := oCinza
endif

Return oRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPxCLegTab บAutor  ณ Alberto Deviciente บ Data ณ 20/Mai/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Legendas da Tabela (Tela Principal).                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integracao Protheus x RM Classis Net (RM Sistemas)         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบOBS:	  	 ณFuncao antiga chamava-se IntLegTab 						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PxCLegTab()
Local aLegenda	:= {{"BR_AMARELO"	, STR0099},; //	"Tabela c/ Registro Pendente"
					{"BR_VERDE"		, STR0100},; //"Tabela Consistente"
					{"BR_VERMELHO"	, STR0101},; //"Tabela c/ Inconsist๊ncia"
					{"BR_PRETO"		, STR0102 }} //"Tabela c/ Inconsist. e c/ Registro Pendente"

BrwLegenda(STR0028,STR0029,aLegenda) //"Integra็๕es - Status"

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PxCTimer บAutor  ณ Alberto Deviciente บ Data ณ 20/Mai/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza o Timer de Atualizacao (Refresh) da tela.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integracao Protheus x RM Classis Net (RM Sistemas)         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบOBS:	  	 ณFuncao antiga chamava-se IntTimer 						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PxCTimer(nMinutos)
Local nRet := 0

nRet := 60000*nMinutos

Return nRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPxCParTimeบAutor  ณ Alberto Deviciente บ Data ณ 21/Mai/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza o Parametro MV_FNTIMER.                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Neste parametro fica armazenado o tempo de intervalo para  บฑฑ
ฑฑบ          ณ atualizacao da tela de Monitor de Transacoes da Integracao.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integracao Protheus x RM Classis Net (RM Sistemas)         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบOBS:	  	 ณFuncao antiga chamava-se IntParTimer						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PxCParTime(nValor)

dbSelectArea("SX6")
PutMv("MV_FNTIMER", alltrim(str(nValor)))

//Atualiza o Timer da Tela
oTimer:NINTERVAL := PxCTimer(nValor)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPxCAltCon บAutor  ณ Alberto Deviciente บ Data ณ 21/Mai/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Interface para Visualizacao de Inconsistencias existentes  บฑฑ
ฑฑบ          ณ na tabela de Integracao.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integracao Protheus x RM Classis Net (RM Sistemas)         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบOBS:	  	 ณFuncao antiga chamava-se InAltInCon						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PxCAltCon(cTabela,nFilTabela)
Local oDlgInt,oGprFilt,oGetTable,oGetDescri,oGetData,oGetHora,oCancel,oConfirma,oGprFilttbl,oDetalhe,oLegend
Local aSize 		:= MSADVSIZE(.F.,,)
Local nPosLinIni 	:= aSize[1] //Linha inicial area trabalho
Local nPosColIni 	:= aSize[2] //Coluna inicial area trabalho
Local nPosLinFim 	:= aSize[3] //Linha final area trabalho
Local nPosColFim 	:= aSize[4] //Coluna final area trabalho
Local nColFimJan 	:= aSize[5] //Coluna final dialog (janela)
Local nLinFimJan 	:= aSize[6] //Linha final dialog (janela)
Local nLinIniJan 	:= aSize[7] //Linha inicial dialog (janela)
Local cGetTable		:= Space(25)
Local cGetDescri	:= Space(150)
Local cGetData      := Space(25)
Local cGetHora		:= Space(25)
Local cPrfxTab		:= ""
Local cDescric		:= ""
Local cData			:= aTabsINT[oTabsINT:nAt,04]
Local cHora			:= aTabsINT[oTabsINT:nAt,05]
Local aCStatus		:= {STR0030,STR0031,STR0032,STR0033}//{"0=Todos", "1=Somente Pendentes", "3=Somente Inconsistentes", "4=Grava็ใo Incompleta"}
Local nPosTab		:= 0
Local cTitle    	:= STR0034 //"Inconsist๊ncias - Integra็ใo Protheus x RM Classis Net - Alterar"

Private oRegsTbINT,oCStatus,oHelp
Private aRegsTbINT  := {}
Private cCStatus    := "1" //Todos
Private cHelp 		:= Space(500)

nPosTab := Ascan( aTabelas, {|x| x[2] == cTabela } )
cPrfxTab := aTabelas[nPosTab][3]
cDescric := aTabelas[nPosTab][4]

//Montagem de Interface
DEFINE MSDIALOG oDlgInt TITLE cTitle From nLinIniJan,0 To nLinFimJan,nColFimJan OF oMainWnd PIXEL
oDlgInt:lMaximized := .T.

oGprFilt := TGROUP():Create(oDlgInt)
oGprFilt:cName := "oGprFilt"
oGprFilt:cCaption := STR0035 //"Informa็๕es Primแrias"
oGprFilt:nLeft := 2
oGprFilt:nTop := 5
oGprFilt:nWidth := nColFimJan
oGprFilt:nHeight := 108
oGprFilt:lShowHint := .F.
oGprFilt:lReadOnly := .F.
oGprFilt:Align := 0
oGprFilt:lVisibleControl := .T.

TSay():New( oGprFilt:nTop+05, 008, {|| STR0036  }	, oDlgInt, , , , , , .T., , , 200, 08, , , , , , ) //"Tabela Integra็ใo"
TSay():New( oGprFilt:nTop+05, 110, {|| STR0037  }	, oDlgInt, , , , , , .T., , , 200, 08, , , , , , ) //"Descri็ใo"
TSay():New( oGprFilt:nTop+28, 008, {|| STR0038  }	, oDlgInt, , , , , , .T., , , 200, 08, , , , , , ) //"Dt. ฺltima Integra็ใo"
TSay():New( oGprFilt:nTop+28, 110, {|| STR0039  }	, oDlgInt, , , , , , .T., , , 200, 08, , , , , , ) //"Hr. ฺltima Integra็ใo"

cGetTable 	:= upper(cTabela)
cGetDescri  := cDescric
cGetData    := cData
cGetHora	:= alltrim(cHora)

oGetTable := TGET():Create(oDlgInt)
oGetTable:cName := "oGetTable"
oGetTable:nLeft := 15
oGetTable:nTop := oGprFilt:nTop+iif(nHRes==800,30,30)
oGetTable:nWidth := 100
oGetTable:nHeight := 19
oGetTable:lShowHint := .F.
oGetTable:lReadOnly := .F.
oGetTable:Align := 0
oGetTable:cVariable := "cGetTable"
oGetTable:bSetGet := {|u| If(PCount()>0, cGetTable:=u, cGetTable) }
oGetTable:lVisibleControl := .T.
oGetTable:lPassword := .F.
oGetTable:lHasButton := .F.
oGetTable:bWhen  := {|| .f. }

oGetDescri := TGET():Create(oDlgInt)
oGetDescri:cName := "oGetDescri"
oGetDescri:nLeft := oGetTable:nWidth+117
oGetDescri:nTop := oGetTable:nTop
oGetDescri:nWidth := 250
oGetDescri:nHeight := 19
oGetDescri:lShowHint := .F.
oGetDescri:lReadOnly := .F.
oGetDescri:Align := 0
oGetDescri:cVariable := "cGetDescri"
oGetDescri:bSetGet := {|u| If(PCount()>0, cGetDescri:=u, cGetDescri) }
oGetDescri:lVisibleControl := .T.
oGetDescri:lPassword := .F.
oGetDescri:lHasButton := .F.
oGetDescri:bWhen  := {|| .f. }

oGetData := TGET():Create(oDlgInt)
oGetData:cName := "oGetData"
oGetData:nLeft := oGetTable:nLeft
oGetData:nTop  := oGetTable:nTop+iif(nHRes==800,50,50)
oGetData:nWidth := oGetTable:nWidth-20
oGetData:nHeight := 19
oGetData:lShowHint := .F.
oGetData:lReadOnly := .F.
oGetData:Align := 0
oGetData:cVariable := "cGetData"
oGetData:bSetGet := {|u| If(PCount()>0, cGetData:=u, cGetData) }
oGetData:lVisibleControl := .T.
oGetData:lPassword := .F.
oGetData:lHasButton := .F.
oGetData:bWhen  := {|| .f. }

oGetHora := TGET():Create(oDlgInt)
oGetHora:cName := "oGetHora"
oGetHora:nLeft := oGetDescri:nLeft
oGetHora:nTop  := oGetData:nTop
oGetHora:nWidth := oGetTable:nWidth-8
oGetHora:nHeight := 19
oGetHora:lShowHint := .F.
oGetHora:lReadOnly := .F.
oGetHora:Align := 0
oGetHora:cVariable := "cGetHora"
oGetHora:bSetGet := {|u| If(PCount()>0, cGetHora:=u, cGetHora) }
oGetHora:lVisibleControl := .T.
oGetHora:lPassword := .F.
oGetHora:lHasButton := .F.
oGetHora:bWhen  := {|| .f. }

oGprFilttbl := TGROUP():Create(oDlgInt)
oGprFilttbl:cName := "oGprFilt"
oGprFilttbl:cCaption := STR0040 //"Registros Inconsistentes"
oGprFilttbl:nLeft := 2
oGprFilttbl:nTop := oGprFilt:nTop+iif(nHres==800,115,125)
oGprFilttbl:nWidth := nColFimJan
oGprFilttbl:nHeight := 330
oGprFilttbl:lShowHint := .F.
oGprFilttbl:lReadOnly := .F.
oGprFilttbl:Align := 0
oGprFilttbl:lVisibleControl := .T.

TSay():New( iif(nHres==800,70,75), iif(nHres==800,250,368), {|| STR0041 }, oDlgInt, , , , , , .T., , , 200, 08, , , , , , )

//Combo - Filtro por Legenda
oCStatus := TCOMBOBOX():Create(oDlgInt)
oCStatus:cName := "oCStatus"
oCStatus:nLeft := oGprFilttbl:nWidth-iif(nHres==800,155,163)
oCStatus:nTop := oGprFilttbl:nTop+iif(nHres==800,18,18)
oCStatus:nWidth := 155
oCStatus:nHeight := 21
oCStatus:lShowHint := .F.
oCStatus:lReadOnly := .F.
oCStatus:Align := 0
oCStatus:cVariable := "cCStatus"
oCStatus:bSetGet := {|u| If(PCount()>0, cCStatus:=u, cCStatus) }
oCStatus:aItems := aCStatus
oCStatus:lVisibleControl := .T.
oCStatus:nAt := 0
oCStatus:bChange := {|| PxcLstReg(cPrfxTab,cTabela,aRegsTbINT,cCStatus),PxCObserva(cPrfxTab,cTabela) }

//Listagem por tabela de Integracao
if len(aRegsTbINT) == 0
	AAdd(aRegsTbINT ,{ "", 0, Space(35), Space(35), Space(10), Space(10), Space(70), Space(30) } )
endif
oRegsTbINT := VCBrowse():New( 90, 003, iif(nHRes=1024,490,615),iif(nHRes=1024,140,240),,{'',STR0042,STR0043,STR0044,STR0045,STR0046,STR0047,STR0048},{1,25,35,35,10,35,70,30},oDlgInt,,,,,{|| .t.},,,,,,,.F.,,.T.,,.F.,,, )
oRegsTbINT:SetArray(aRegsTbINT)
oRegsTbINT:bLine := {||{ PxCStatReg(aRegsTbINT[oRegsTbINT:nAt,01]),;
								aRegsTbINT[oRegsTbINT:nAt,03],;
								aRegsTbINT[oRegsTbINT:nAt,04],;
								aRegsTbINT[oRegsTbINT:nAt,05],;
								aRegsTbINT[oRegsTbINT:nAt,06],;
								aRegsTbINT[oRegsTbINT:nAt,07],;
								aRegsTbINT[oRegsTbINT:nAt,08]} }
oRegsTbINT:bChange	:= {|| PxCObserva(cPrfxTab,cTabela) }

oCancel := TBUTTON():Create(oDlgInt)
oCancel:cName := "oCancel"
oCancel:cCaption := STR0049 //"Sair"
oCancel:nLeft := nColFimJan-50
oCancel:nTop := (oRegsTbINT:nHeight+200)
oCancel:nWidth := 50
oCancel:nHeight := 21
oCancel:lShowHint := .F.
oCancel:lReadOnly := .F.
oCancel:Align := 0
oCancel:lVisibleControl := .T.
oCancel:bAction := {|| .T.,oDlgInt:End() }

oConfirma := TBUTTON():Create(oDlgInt)
oConfirma:cName := "oConfirma"
oConfirma:cCaption :=  STR0050 //"Reprocessar"
oConfirma:nLeft := oCancel:nLeft-100
oConfirma:nTop := oCancel:nTop
oConfirma:nWidth := 85
oConfirma:nHeight := 21
oConfirma:lShowHint := .F.
oConfirma:lReadOnly := .F.
oConfirma:Align := 0
oConfirma:lVisibleControl := .T.
oConfirma:bAction := {|| iif(PxCVldProc(),MsgRun(STR0051,STR0052,{|| PxCReProces(cGetTable) } ),nil) }

oLegend := TBUTTON():Create(oDlgInt)
oLegend:cName := "oLegend"
oLegend:cCaption := STR0029 //"Legenda"
oLegend:nLeft := oConfirma:nLeft-60
oLegend:nTop := oCancel:nTop
oLegend:nWidth := 45
oLegend:nHeight := 21
oLegend:lShowHint := .F.
oLegend:lReadOnly := .F.
oLegend:Align := 0
oLegend:lVisibleControl := .T.
oLegend:bAction := {|| PxCLegReg() }

oDetalhe := TBUTTON():Create(oDlgInt)
oDetalhe:cName := "oDetalhe"
oDetalhe:cCaption := STR0053//"Detalhes Item"
oDetalhe:nLeft := oLegend:nLeft-105
oDetalhe:nTop := oCancel:nTop
oDetalhe:nWidth := 85
oDetalhe:nHeight := 21
oDetalhe:lShowHint := .F.
oDetalhe:lReadOnly := .F.
oDetalhe:Align := 0
oDetalhe:lVisibleControl := .T.
oDetalhe:bAction := {|| PxCDetalhe(cPrfxTab,cTabela) }

//Efetuando listagem dos registro da tabela de integracao selecionada
PxcLstReg(cPrfxTab,cTabela,aRegsTbINT,"0")

oHelp := TMultiGet():New( iif(nHRes=1024,240,350), 003, {|u| If( PCount() > 0, cHelp := u, cHelp ) }/*bSETGET(<uVar>)*/, oDlgInt, iif(nHRes==800,180,240), 25, /*<oFont>*/, .t./*<.hscroll.>*/, CLR_BLACK/*<nClrFore>*/, /*<nClrBack>*/, /*<oCursor>*/, .T./*<.pixel.>*/, /*<cMsg>*/, /*<.update.>*/,, /*<.lCenter.>*/, /*<.lRight.>*/, .T./*<.readonly.>*/, /*<{uValid}>*/, /*[\{|nKey, nFlags, Self| <uChange>\}]*/, /*<.lDesign.>*/, .f./*[<.lNoBorder.>]*/, .F./*[<.lNoVScroll.>]*/ )

ACTIVATE MSDIALOG oDlgInt

//Atualiza legendas das Tabelas de Integracao
PxCListTbl(nFilTabela)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPxcLstReg บAutor  ณ Alberto Deviciente บ Data ณ 22/Mai/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Lista os registros inconsistentes da tabela de Integracao  บฑฑ
ฑฑบ          ณ selecionada.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integracao Protheus x RM Classis Net (RM Sistemas)         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบOBS:	  	 ณFuncao antiga chamava-se InLstRegTbl						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PxcLstReg(cPrfxTab,cTabela,aRegsTbINT,cCStatus1)
Local cQuery 	:= ""
Local cProcesso := ""
Local cDescStat := ""
Local cWhere    := ""

Default cCStatus1 := "0" //Todos

if cCStatus1 == "0" //Todos
	cWhere := "('1','3','4')" //1=Pendente; 3=Inconsistente; 4=Gravacao Incompleta
else
	cWhere := "('"+cCStatus1+"')"
endif

if lMSSQL //SQL Server
	cQuery := "select "+cPrfxTab+"_ID ID,convert(varchar(10),"+cPrfxTab+"_DATAGRAVA,103)DATAI,"+cPrfxTab+"_HORAGRAVA HORAI,"+cPrfxTab+"_USUGRAVA USERI,"+cPrfxTab+"_STATUSIMPORT STATUSIMP, "
	cQuery += " "+cPrfxTab+"_ROTIMPORT ROTINA,"+cPrfxTab+"_PROCIMPORT PROCESSO from "+upper(cTabela)+" where "+cPrfxTab+"_STATUSIMPORT in "+cWhere
else //Oracle
	cQuery := "select "+cPrfxTab+"_ID ID,to_char("+cPrfxTab+"_DATAGRAVA,'DD/MM/YYYY') DATAI,"+cPrfxTab+"_HORAGRAVA HORAI,"+cPrfxTab+"_USUGRAVA USERI,"+cPrfxTab+"_STATUSIMPORT STATUSIMP, "
	cQuery += " "+cPrfxTab+"_ROTIMPORT ROTINA,"+cPrfxTab+"_PROCIMPORT PROCESSO from "+upper(cTabela)+" where "+cPrfxTab+"_STATUSIMPORT in "+cWhere
endif
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "TIN", .F., .F. )

aRegsTbINT := {}
while TIN->( !eof() )
	Do Case
		Case TIN->STATUSIMP == "1" ; cDescStat := STR0054 //"Pendente"
		Case TIN->STATUSIMP == "3" ; cDescStat := STR0055 //"Inconsistente"
		Case TIN->STATUSIMP == "4" ; cDescStat := STR0056 //"Grav. Incompleta"
	EndCase
	Do Case
		Case TIN->PROCESSO == "I" ; cProcesso := STR0057 //"Inclusใo"
		Case TIN->PROCESSO == "U" ; cProcesso := STR0058 //"Atualiza็ใo"
		Case TIN->PROCESSO == "D" ; cProcesso := STR0059 //"Exclusใo"
	EndCase
	AAdd(aRegsTbINT ,{ TIN->STATUSIMP,TIN->ID,ctod(TIN->DATAI),TIN->HORAI,TIN->USERI,cDescStat,TIN->ROTINA,cProcesso } )
	TIN->( dbskip() )
end

if len(aRegsTbINT) == 0
	AAdd(aRegsTbINT ,{ "", 0, Space(10), Space(8), Space(25), Space(25), Space(35), Space(45) } )
endif

oRegsTbINT:SetArray(aRegsTbINT)
oRegsTbINT:bLine := {||{ PxCStatReg(aRegsTbINT[oRegsTbINT:nAt,01]),;
								aRegsTbINT[oRegsTbINT:nAt,02],;
								aRegsTbINT[oRegsTbINT:nAt,03],;
								aRegsTbINT[oRegsTbINT:nAt,04],;
								aRegsTbINT[oRegsTbINT:nAt,05],;
								aRegsTbINT[oRegsTbINT:nAt,06],;
								aRegsTbINT[oRegsTbINT:nAt,07],;
								aRegsTbINT[oRegsTbINT:nAt,08]} }

oRegsTbINT:nAt := 1 //Posiciona na primeira linha
oRegsTbINT:Refresh()
TIN->( dbclosearea() )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPxCLegReg บAutor  ณ Alberto Deviciente บ Data ณ 25/Mai/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Legendas do registros (Tela de detalhes da tabela).        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integracao Protheus x RM Classis Net (RM Sistemas)         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบOBS:	  	 ณFuncao antiga chamava-se IntLegReg						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PxCLegReg()
Local aLegenda	:= {{"BR_AMARELO", 	STR0060 },; //"Registro Pendente"
					{"BR_VERMELHO",	STR0061 },; //"Registro Inconsistente"
					{"BR_AZUL",		STR0062 }} //"Grava็ใo Incompleta"

BrwLegenda(STR0063,STR0029,aLegenda)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPxCDetalheบAutor  ณ Alberto Deviciente บ Data ณ 25/Mai/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de Detalhes do Registros selecionado.                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integracao Protheus x RM Classis Net (RM Sistemas)         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบOBS:	  	 ณFuncao antiga chamava-se IntDetalhe						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PxCDetalhe(cPrfxTab,cTabela)
Local oDlgDetl,oConfirma,oCancel
Local cTitle		:= ""
Local cQuery  		:= ""
Local nCount        := 0
Local aSize1 		:= MsAdvSize()					// Array contendo Tamanho da Tela
Local aInfo1		:= {}							// Array Auxiliar do Tamanho da Tela
Local aInfo2		:= {}							// Array Auxiliar do Tamanho da Tela
Local aPosObj1		:= {}							// Array Coordenadas da Janela
Local aObjects1		:= {} 							// Array Coordenadas dos Objetos
Local aObjects2		:= {} 							// Array Coordenadas dos Objetos
Local i				:= 0
Local aTypes		:= {}
Local cCampo		:= ""
Local lRet			:= .T.
Local cIdTable 		:= ""
Local cValid 		:= "{|| .T. }"
Local cPicture 		:= ""
Local cPicCmpDec 	:= ""

Private oRegDetalhe
Private aRegDetalhe    := {}

//Campos das tabelas de integraco que utilizarao marcara "@E 99,999,999.99"
cPicCmpDec := "TIT_VALOR/TIT_VALORBAIXADO/TIT_DESCONTO/TIT_VALORBOLSA/TIT_MULTA/TIT_JUROS/TIT_VALORCANCELADOBAIXA/TIT_VALORBOLSAPONT/TIT_VALORFIES"

if empty(aRegsTbINT[oRegsTbINT:nAt,02])
	Return .F.
endif

//******************************************************************************************************************
// Adiciona Objetos para Calculo da Area com base no Resultado da MsAdvSize()
//******************************************************************************************************************
aAdd( aObjects1, { 100, 100, .T., .T. } )     		// Objeto Central
aAdd( aObjects1, { 120, 100, .F., .T. } )			// Obejto Lateral

aSize1[2]	:= aSize1[2] - 12						// Desconsidera a ToolBar Default do Protheus
aInfo1		:= { aSize1[ 1 ], aSize1[ 2 ], aSize1[ 3 ], aSize1[ 4 ], 2, 2 }
aPosObj1	:= MsObjSize( aInfo1, aObjects1,, .T. )

//******************************************************************************************************************
// Adiciona Objetos para Calculo da Area com base no Resultado do Objeto Central
//******************************************************************************************************************
aInfo2		:= { aPosObj1[1,2], aPosObj1[1,1], aPosObj1[1,4], aPosObj1[1,3], 0, 0 }
aAdd( aObjects2, { 100, 060, .T., .F. } )
aAdd( aObjects2, { 100, 018, .T., .F. } )
aAdd( aObjects2, { 100, 050, .T., .T. } )
aAdd( aObjects2, { 100, 050, .T., .T. } )
aPosObj2	:= MsObjSize( aInfo2, aObjects2, .T. )

cTitle := STR0064 +alltrim(cTabela)+STR0065

cIdTable := alltrim(str(aRegsTbINT[oRegsTbINT:nAt,02]))

/* Pega Detalhamento da Tabela */
if lMSSQL
	if cSQLVersao == "2000" //Tratamento para SQL Server 2000
		cQuery := "SELECT a.name,a.length max_length,b.name typename "
		cQuery += "	from syscolumns a,systypes b "
		cQuery += "	   where id = object_id('"+alltrim(cTabela)+"') "
		cQuery += "		 and a.xtype = b.xtype "
		cQuery += "	order by a.id "
	else
		cQuery := "SELECT a.name,a.max_length,b.name typename "
		cQuery += "	from sys.columns a,sys.types b "
		cQuery += "	   where object_id = object_id('"+alltrim(cTabela)+"') "
		cQuery += "		 and a.system_type_id = b.system_type_id "
		cQuery += "	order by a.column_id "
	endif
else //Oracle
	cQuery := "select column_name name,data_length max_length,data_type typename"
    cQuery += "	 from sys.all_tab_cols t"
    cQuery += "	where table_name='"+alltrim(upper(cTabela))+"' "
    cQuery += "order by column_id"
endif
dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "ITD", .F., .F. )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณListagem dos campos da tabela de Integracao  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ITD->( dbgotop() )
while ITD->( !eof() )

	if alltrim(UPPER(ITD->typename)) $ "INT/FLOAT/NUMERIC/NUMBER"
		if alltrim(UPPER(alltrim(ITD->name))) $ cPicCmpDec
			cPicture := "@E 99,999,999.99"
		else
			cPicture := "9999999999"
		endif
	else
		cPicture := ""
	endif

	aAdd( aRegDetalhe, { alltrim(UPPER(alltrim(ITD->name))), iif(alltrim(UPPER(ITD->typename))$"INT/FLOAT/NUMERIC/NUMBER",0,""), alltrim(UPPER(ITD->typename)), ITD->max_length, cValid, cPicture } )
	ITD->( dbskip() )
end
ITD->( dbCloseArea() )

///////////////////////////////////////////////////////////////////////////////////////////////*
//Montagem de Interface - Window
//////////////////////////////////////////////////////////////////////////////////////////////*/
DEFINE MSDIALOG oDlgDetl TITLE cTitle From aSize1[7],0 TO aSize1[6]+iif(nHres==800,50,20),aPosObj2[3,4]+iif(nHres==800,15,5) OF oMainWnd PIXEL

for i := 1 to len(aRegDetalhe)

	if alltrim(aRegDetalhe[i][3]) $ "DATE/DATETIME"
		if lMSSQL //SQL Server
			cCampo := "convert(varchar(8),"+alltrim(aRegDetalhe[i][1])+",112)"
		else //Oracle
			cCampo := "to_char("+alltrim(aRegDetalhe[i][1])+",'YYYYMMDD')"
		endif
	else
		cCampo := alltrim(aRegDetalhe[i][1])
	endif


	//Pegando respectivos valores dos campos da tabela de integracao
	cQuery := "select "+cCampo+" COLUMNTABLE from "+alltrim(cTabela)+" where "+cPrfxTab+"_id = "+cIdTable+" "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "ITC", .F., .F. )
	if ITC->( !EoF() )

		if alltrim(aRegDetalhe[i][3]) $ "DATE/DATETIME"
			aRegDetalhe[i][2] := sTod(ITC->COLUMNTABLE)
/*		elseif alltrim(aRegDetalhe[i][3]) $ "INT/FLOAT/NUMERIC/NUMBER"
			aRegDetalhe[i][2] := ITC->COLUMNTABLE*/
		else
			aRegDetalhe[i][2] := ITC->COLUMNTABLE
		endif

	endif
	ITC->( dbCloseArea() )
next i

oRegDetalhe := TWBrowse():New( aPosObj2[2,1]-60, aPosObj2[2,2]+2, aPosObj2[3,3], aPosObj2[3,4]-120,,{"Coluna","Valor"},{50,50},oDlgDetl,,,,,{|| .t.},,,,,,,.F.,,.T.,,.F.,,, )
oRegDetalhe:SetArray(aRegDetalhe)
oRegDetalhe:bLine := {||{ 	aRegDetalhe[oRegDetalhe:nAt,01],;
							aRegDetalhe[oRegDetalhe:nAt,02] } }
oRegDetalhe:bLDblClick := {|| iif(PxCCanEdit(aRegDetalhe[oRegDetalhe:nAt,01]),(lEditCell(@aRegDetalhe,oRegDetalhe,aRegDetalhe[oRegDetalhe:nAt,06],2,PxCCampAlt(aRegDetalhe,oRegDetalhe),,&(aRegDetalhe[oRegDetalhe:nAt,05])),),.t.) }

oConfirma := TBUTTON():Create(oDlgDetl)
oConfirma:cName := "oConfirma"
oConfirma:cCaption := STR0066 //"Confirmar Altera็๕es >>"
oConfirma:nLeft := 4
oConfirma:nTop := oRegDetalhe:nHeight+iif(nHres==800,18,8)
oConfirma:nWidth := 142
oConfirma:nHeight := 21
oConfirma:lShowHint := .F.
oConfirma:lReadOnly := .F.
oConfirma:Align := 0
oConfirma:lVisibleControl := .T.
oConfirma:bAction := {|| Processa( { || lRet:=PxCGrvGrid(cPrfxTab,cTabela,oRegDetalhe,aRegDetalhe) }, STR0067 ),iif(lRet,(aCamposAlt:={},oDlgDetl:End()),) }

oCancel := TBUTTON():Create(oDlgDetl)
oCancel:cName := "oCancel"
oCancel:cCaption := STR0049 //"Sair"
oCancel:nLeft := oConfirma:nLeft+oConfirma:nWidth+7
oCancel:nTop := oConfirma:nTop
oCancel:nWidth := 50
oCancel:nHeight := 21
oCancel:lShowHint := .F.
oCancel:lReadOnly := .F.
oCancel:Align := 0
oCancel:lVisibleControl := .T.
oCancel:bAction := {|| aCamposAlt:={},oDlgDetl:End() }

ACTIVATE MSDIALOG oDlgDetl

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPxCCanEditบAutor  ณ Alberto Deviciente บ Data ณ 25/Mai/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se pode editar o campo.                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integracao Protheus x RM Classis Net (RM Sistemas)         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบOBS:	  	 ณFuncao antiga chamava-se IntCanEdit						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PxCCanEdit(cCampo)
Local lRet 		:= .T.
Local cPrfTab 	:= SubStr(cCampo,1,3) //Prefixo da tabela
Local aTabCmps 	:= {}
Local cCmpNaoEdit:= ""

//               Tabela             Prefixo tabela  Campos que nao podem ser editados
aAdd( aTabCmps, { "INT_FUNC"		, "FUN"			,cCmpBloq+"/FUN_MAT/FUN_CODPESSOA/FUN_DTEMISSAORG/" } )
aAdd( aTabCmps, { "INT_TAREFA"		, "TAR"			,cCmpBloq+"/TAR_CODSIMULACAO/TAR_CODPROF/TAR_DATAINI/TAR_DATAFIM/TAR_AULASEMANA/TAR_VALORFIXO/TAR_VALORHORA/TAR_QTDHORA/TAR_CODGRUPOATIV/TAR_IDATIVIDADE/TAR_TIPOFALTA/TAR_QTDFALTA/TAR_TIPOTAREFA/" } )
aAdd( aTabCmps, { "INT_CLIENTE"		, "CLI"			,cCmpBloq+"/CLI_CODIGO/CLI_PESSOA" } )
aAdd( aTabCmps, { "INT_TITULO"		, "TIT"			,cCmpBloq+"/TIT_PAGREC/TIT_COLIGADACLI/TIT_ORIGEM/TIT_FLAGSCONTA/TIT_RECNOSE1/TIT_NOSSONUMERO/TIT_IDBOLETO/TIT_NUMEROINSC/TIT_PROCEL/" } )
aAdd( aTabCmps, { "INT_CCUSTOLOG"	, "CCT"			,cCmpBloq+"/CCT_CODCUSTO/CCT_PERMITELANC/CCT_STATUS/CCT_CODREDUZI/" } )
aAdd( aTabCmps, { "INT_MOEDALOG"	, "MOE"			,cCmpBloq+"/MOE_MOEDA/MOE_TIPO/" } )
aAdd( aTabCmps, { "INT_TITULACAOLOG", "TTL"			,cCmpBloq+"/TTL_CODIGO/" } )
aAdd( aTabCmps, { "INT_TIPODOCLOG"	, "TOD"			,cCmpBloq+"/TOD_CODIGO/TOD_PAGREG/TOD_EDEVOLUCAO" } )
aAdd( aTabCmps, { "INT_CONTACXALOG"	, "CXA"			,cCmpBloq+"/CXA_CODCXA/" } )

cCampo := SubStr(cCampo,4)

cCmpNaoEdit := aTabCmps[Ascan(aTabCmps,{|x| x[2]==cPrfTab})][3]

if cCampo $ cCmpNaoEdit
	Aviso(STR0068, STR0069, {STR0070}) //"Nใo ้ permitida a edi็ใo deste campo."
	lRet := .F.
endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPxCGrvGridบAutor  ณ Alberto Deviciente บ Data ณ 25/Mai/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava o detalhamento do registro alterado.                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integracao Protheus x RM Classis Net (RM Sistemas)         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบOBS:	  	 ณFuncao antiga chamava-se IntGrvGrid						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PxCGrvGrid(cPrfxTab,cTabela,oRegDetalhe,aRegDetalhe)
Local cQuery		:= ""
Local i		   		:= 0
Local cCamptbl 		:= ""
Local cCampAlGrv    := "" //Concatena Campos Alterados
Local cValoAlGrv    := "" //Concatena Valores Alterados
Local cIdTabela 	:= ""
Local nPosCmp 		:= 0
Local cVlrAtu 		:= ""

cIdTabela := alltrim(str(aRegsTbINT[oRegsTbINT:nAt][02]))

ProcRegua( len(aCamposAlt) )

//Percorre todos os campos alterados para efetivar a gravacao na tabela de Integracao
for i := 1 to len(aCamposAlt)
	cCamptbl 	:= SubStr(aCamposAlt[i][1],4)
	if cCamptbl $ cCmpBloq
		loop
	endif
	cCamptbl := cPrfxTab+cCamptbl
	IncProc(STR0071+cCamptbl) //"Executando grava็ใo - campo "

	nPosCmp := Ascan( aRegDetalhe, {|x| x[1] == cCamptbl } )
	cValorAtu 	:= aRegDetalhe[nPosCmp][2]

	if aRegDetalhe[nPosCmp][3] $ "DATE/DATETIME" //Tratamento para campo tipo DATA
		cVlrAtu := " '"+alltrim(dToS(cValorAtu))+"' "
	elseif aRegDetalhe[nPosCmp][3] $ "INT/FLOAT/NUMBER/NUMERIC" //Tratamento para campo tipo Numerico
		cVlrAtu := alltrim(str(cValorAtu))
	else
		cVlrAtu := "'"+cValorAtu+"'"
	endif

	cQuery := "update "+alltrim(cTabela)+" set "+cCamptbl+" = "+cVlrAtu+" where "+cPrfxTab+"_ID = "+cIdTabela
	if TcSqlExec(cQuery) < 0
		MsgStop(STR0072+alltrim(cTabela)+Chr(10)+Chr(10)+STR0073+TcSqlError()) //"Ocorreu erro ao tentar atualizar a tabela "
		conout(TcSqlError())
	else
		TcSqlExec("COMMIT")
	endif

	//Concatena campos e respectivos valores alterados na tabela de Integracao
	cCampAlGrv 	+= cCamptbl+"/"
	cValoAlGrv	+= alltrim(cValorAtu)+"/"
next i

cCampAlGrv := substr(cCampAlGrv,1,len(cCampAlGrv)-1)
cValoAlGrv := substr(cValoAlGrv,1,len(cValoAlGrv)-1)
oRegDetalhe:Refresh()

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPxCObservaบAutor  ณ Alberto Deviciente บ Data ณ 26/Mai/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza o conteudo do campo Observacao.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integracao Protheus x RM Classis Net (RM Sistemas)         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบOBS:	  	 ณFuncao antiga chamava-se IntObserva						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PxCObserva(cPrfxTab,cTabela)
Local cQuery  	:= ""
Local cObserv 	:= ""
Local cIdTabl 	:= ""

cIdTabl := alltrim(str(aRegsTbINT[oRegsTbINT:nAt,02]))

if !empty(cIdTabl)
	cQuery := "SELECT "+cPrfxTab+"_OBSIMPORT OBSERVACAO FROM "+alltrim(cTabela)+" WHERE "+cPrfxTab+"_ID = "+cIdTabl+" "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "TBS", .F., .F. )
	if TBS->( !eof() )
		cObserv := alltrim(TBS->OBSERVACAO)
	endif
    cHelp := cObserv
//    oHelp:Refresh()
	TBS->( dbclosearea() )
endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPxCVldprocบAutor  ณ Alberto Deviciente บ Data ณ 28/Mai/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz validacao antes de executar o ReProcessamento.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integracao Protheus x RM Classis Net (RM Sistemas)         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบOBS:	  	 ณFuncao antiga chamava-se InVldproc						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PxCVldproc()
Local lRet := .T.

if empty(aRegsTbINT[oRegsTbINT:nAt,02])
	lRet := .F.
endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPxCReProceบAutor  ณ Alberto Deviciente บ Data ณ 28/Mai/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua chamada de ReProcessamento do Registro de Integracao.บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integracao Protheus x RM Classis Net (RM Sistemas)         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบOBS:	  	 ณFuncao antiga chamava-se InReProces						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PxCReProce(cTable)
Local cQuery 	:= ""
Local cQuery1 	:= ""
Local cPrefix  	:= ""
Local nPos 		:= 0
Local cID  		:= ""
Local lProcess 	:= .T.
Local cMsgError := ""
Local lContinua := .T.
Local cEmpINT  	:= ""
Local cFilINT  	:= ""
Local cTipProc  := ""
Local cRotGrava := ""
Local cUsr 		:= ""
Local cCmd 		:= ""
//Variaveis Financeiro (INT_TITULO)
Local cFilCTO 		:= ""
Local cFilSE1 		:= ""
Local nE1_Saldo 	:= 0
Local nE1_MOEDA 	:= 0
Local cSimbMoe 		:= ""
Local cE1_PREFIXO 	:= ""
Local cE1_NUM     	:= ""
Local cE1_NRDOC   	:= ""
Local cE1_PARCELA 	:= ""
Local cE1_TIPO    	:= ""
Local cE1_NATUREZ 	:= ""
Local cE1_EMISSAO 	:= ""
Local cE1_VENCTO  	:= ""
Local cE1_VENCREA 	:= ""
Local nE1_IDLAN   	:= 0
Local nE1_IDAPLIC 	:= 0
Local cE1_CLIENTE 	:= ""
Local cE1_NOMCLI  	:= ""
Local cE1_NUMRA   	:= ""
Local cE1_BAIXA   	:= ""
Local nE1_VALOR   	:= 0
Local nE1_VALLIQ  	:= 0
Local nE1_DESCONT 	:= 0
Local nE1_MULTA   	:= 0
Local nE1_JUROS   	:= 0
Local nE1_PORCJUR 	:= 0
Local nE1_MULTDIA 	:= 0
Local nE1_VLBOLSA 	:= 0
Local cE1_STATUS  	:= ""
Local cE1_HIST    	:= ""
Local cE1_CCD     	:= ""
Local cE1_ORIGEM  	:= ""
Local nRecnoSE1		:= 0
Local nVlrCanc 		:= 0
Local cE1_ITEMD 	:= ""
Local cE1_CLVLDB 	:= ""
Local nE1_VLBOLP 	:= 0
Local cE1_PORTADO 	:= ""
Local cE1_AGEDEP  	:= ""
Local cE1_CONTA   	:= ""
Local cE1_NUMBCO  	:= ""
Local cE1_SERVICO 	:= ""
Local nE1_IDBOLET 	:= 0
Local nE1_NUMINSC 	:= 0
Local nE1_PROCEL 	:= 0
Local nE1_VLFIES 	:= 0

Local cBlocked 		:= ""


nPos := Ascan( aTabelas, {|x| x[2] == cTable } )
cPrefix := aTabelas[nPos][3]
cID := alltrim(str(aRegsTbINT[oRegsTbINT:nAt,02]))


if cTable == "INT_FUNC" //Integracao de Funcionarios/Professores

	MsgAlert(STR0074)  //"Para executar o Reprocessamento deste registro, basta acessar a rotina [Professores] atrav้s do sistema RM ClassisNet."
	lContinua := .F.

elseif cTable == "INT_TAREFA" //Integracao de Folha de Pagamento - Professores

	MsgAlert(STR0075) //"Para executar o Reprocessamento deste registro, basta acessar a rotina [Folha Pagto Integr.] atrav้s do sistema Protheus."
	lContinua := .F.

elseif cTable == "INT_CLIENTE" //Integracao de Clientes

	//Verifica possiveis erros no registro gravado na tabela de integracao
	cQuery := " select CLI_CODIGO, CLI_FILIAL"
	cQuery += "  from "	+cTable
	cQuery += " where "+cPrefix+"_ID = "+cID
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "_QRYREPROC", .F., .F. )

	if _QRYREPROC->CLI_FILIAL == "-1"
		MsgStop(STR0076+alltrim(_QRYREPROC->CLI_FILIAL)) //"O c๓digo da filial nใo pode ser "
		lProcess := .F.
	elseif val(_QRYREPROC->CLI_CODIGO) <= 0
		MsgStop(STR0077+alltrim(_QRYREPROC->CLI_CODIGO)) //"O c๓digo do cliente nใo pode ser "
		lProcess := .F.
	endif
	_QRYREPROC->( dbCloseArea() )

	//Executa UPDATE na tabela INT_CLIENTE para disparar a Trigger novamente
	if lProcess
		cQuery := " update " +cTable+ " set "+cPrefix+"_OBSIMPORT = ' ', "+cPrefix+"_STATUSIMPORT = '1'" //Atualiza para "1"=Pendente para que seja reprocessado
		cQuery += "  where " +cPrefix+"_ID = "+cID
		if TcSqlExec(cQuery) < 0
			cMsgError := STR0078 + Chr(10)+Chr(10)+alltrim(TcSqlError()) //"Ocorreu o seguinte erro ao tentar executar o reprocessamento: "
		else
			TcSqlExec("COMMIT")
		endif
	endif

elseif cTable == "INT_TITULO" //Integracao Financeira

	cQuery := " select "
	cQuery += " TIT_TIPOPROC,TIT_COLIGADA,TIT_FILIAL,TIT_PREFIXO,TIT_IDTITULO,TIT_NRDOC,TIT_PARCELA,TIT_TIPO"
	cQuery += ",TIT_NATUREZA,TIT_IDLAN,TIT_IDHABILITACAOFILIAL,TIT_CLIENTE,TIT_NOMECLI,TIT_NUMRA,TIT_VALOR"
	cQuery += ",TIT_VALORBAIXADO,TIT_DESCONTO,TIT_MULTA,TIT_JUROS,TIT_JUROSDIA,TIT_MULTADIA,TIT_VALORBOLSA"
	cQuery += ",TIT_STATUS,TIT_HISTORICO,TIT_MOEDA,TIT_CENTROCUSTO,TIT_ORIGEM,TIT_ROTGRAVA,TIT_RECNOSE1,TIT_USUGRAVA"
	cQuery += ",TIT_VALORCANCELADOBAIXA,TIT_ITEMCONTABIL,TIT_CLASSEVALOR,TIT_VALORBOLSAPONT,TIT_BANCO,TIT_AGENCIA"
	cQuery += ",TIT_CONTABCO,TIT_NOSSONUMERO,TIT_SERVICO,TIT_IDBOLETO,TIT_NUMEROINSC,TIT_PROCEL"
	
	//Converte os campos tipo date para YYYYMMDD
	if lMSSQL //SQL Server
		cQuery += ",Convert(varchar(8), TIT_EMISSAO, 112) as TIT_EMISSAO"
		cQuery += ",Convert(varchar(8), TIT_VENCIMENTO, 112) as TIT_VENCIMENTO"
		cQuery += ",Convert(varchar(8), TIT_DATABAIXA, 112) as TIT_DATABAIXA"
	else
		cQuery += ",to_char(TIT_EMISSAO,'YYYYMMDD') as TIT_EMISSAO"
		cQuery += ",to_char(TIT_VENCIMENTO,'YYYYMMDD') as TIT_VENCIMENTO"
		cQuery += ",to_char(TIT_DATABAIXA,'YYYYMMDD') as TIT_DATABAIXA"
	endif

	cQuery += "  from "	+cTable
	cQuery += " where "+cPrefix+"_ID = "+cID
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "_QRYREPROC", .F., .F. )

	cTipProc := _QRYREPROC->TIT_TIPOPROC
	cEmpINT	 := StrZero(_QRYREPROC->TIT_COLIGADA,2)
	cFilINT  := StrZero(val(_QRYREPROC->TIT_FILIAL),2)

	//Verifica se os campos chaves estao preenchidos
	if empty(_QRYREPROC->TIT_FILIAL)
		MsgStop(STR0079) //"O campo TIT_FILIAL deve ser preenchido."
		lProcess := .F.
	elseif empty(_QRYREPROC->TIT_IDTITULO)
		MsgStop(STR0080) //"O campo TIT_IDTITULO deve ser preenchido."
		lProcess := .F.
	elseif empty(_QRYREPROC->TIT_PARCELA)
		MsgStop(STR0081) //"O campo TIT_PARCELA deve ser preenchido."
		lProcess := .F.
	elseif empty(_QRYREPROC->TIT_TIPO)
		MsgStop(STR0082) //"O campo TIT_TIPO deve ser preenchido."
		lProcess := .F.
	endif

	if lProcess
		//Verifica possiveis erros no registro gravado na tabela de integracao
		if SubStr(_QRYREPROC->TIT_ROTGRAVA,1,3) <> 'FIN' //Registro incluido pelo sistema RM (Classis ou Biblios)
			if !(alltrim(_QRYREPROC->TIT_ROTGRAVA) $ "S/L") //S=Boleto gerado pelo RM Classis; L=Boleto Gerado pelo RM Biblios
				MsgStop(STR0083) //"Para este registro ser reprocessado, o campo TIT_ROTGRAVA deve ter valor: S=Classis ou L=Biblios"
				lProcess := .F.
			else
				//Verifica se os campos chaves estao preenchidos
				if empty(_QRYREPROC->TIT_NUMRA)
					MsgStop(STR0084) //"O campo TIT_NUMRA deve ser preenchido."
					lProcess := .F.
				endif

				//Executa UPDATE na tabela INT_TITULO para disparar a Trigger novamente
				if lProcess
					cQuery := " update " +cTable+ " set "+cPrefix+"_OBSIMPORT = ' ', "+cPrefix+"_STATUSIMPORT = '1'" //Atualiza para "1"=Pendente para que seja reprocessado
					cQuery += "  where " +cPrefix+"_ID = "+cID
					if TcSqlExec(cQuery) < 0
						cMsgError := STR0078 +Chr(10)+Chr(10)+alltrim(TcSqlError())
					else
						TcSqlExec("COMMIT")
					endif
				endif
			endif
		else //Registro incluido pelo Protheus na tabela INT_TITULO


			if lProcess
				//Busca a filial correta da tabela SE1 (Exclusiva ou Compratilhada)
				cFilSE1 := PxCXFilial(cEmpINT, "SE1", cFilINT)

				//Posiciona na SE1 para pegar o valor do Saldo (E1_SALDO)
				cQuery1 := "select E1_SALDO from SE1"+cEmpINT+"0 "
				cQuery1 += " where E1_FILIAL  = '"+cFilSE1+"' "
				cQuery1 += "   and E1_PREFIXO = '"+_QRYREPROC->TIT_PREFIXO+"' "
				cQuery1 += "   and E1_NUM     = '"+_QRYREPROC->TIT_IDTITULO+"' "
				cQuery1 += "   and E1_PARCELA = '"+_QRYREPROC->TIT_PARCELA+"' "
				cQuery1 += "   and E1_TIPO    = '"+_QRYREPROC->TIT_TIPO+"' "
				cQuery1 += "   and D_E_L_E_T_ = ' '"
				dbUseArea( .T., "TopConn", TCGenQry(,,cQuery1), "_QRY1", .F., .F. )

				if _QRY1->( !EoF() )
					nE1_Saldo := _QRY1->E1_SALDO
				else
					if cTipProc == "EXC" //Exclusao
						nE1_Saldo := 0
					else
						MsgStop(STR0085) //"Nใo foi encontrado o registro equivalente na tabela SE1. Nใo serแ possํvel efetuar o reprocessamento."
						lProcess := .F.
					endif
				endif
				_QRY1->( dbCloseArea() )
			endif

			if lProcess
				cSimbMoe := _QRYREPROC->TIT_MOEDA

				//Busca a filial correta da tabela CTO (Exclusiva ou Compratilhada)
				cFilCTO := PxCXFilial(cEmpINT, "CTO", cFilINT)

				//Busca o codigo da Moeda de acordo com o Simbolo
				cQuery1 := "select CTO_MOEDA from CTO"+cEmpINT+"0 "
				cQuery1 += " where CTO_FILIAL = '"+cFilCTO+"' "
				cQuery1 += "   and CTO_SIMB   = '"+cSimbMoe+"' "
				cQuery1 += "   and D_E_L_E_T_ = ' '"
				dbUseArea( .T., "TopConn", TCGenQry(,,cQuery1), "_QRY1", .F., .F. )

				if _QRY1->( !EoF() )
					nE1_MOEDA := val(_QRY1->CTO_MOEDA)
				else
					MsgStop(STR0086+cSimbMoe+STR0087) //"Nใo foi encontrado o c๓digo da Moeda para o sํmbolo ## ". Nใo serแ possํvel efetuar o reprocessamento."
					lProcess := .F.
				endif
				_QRY1->( dbCloseArea() )
			endif

			if lProcess
				cE1_PREFIXO := _QRYREPROC->TIT_PREFIXO
				cE1_NUM     := _QRYREPROC->TIT_IDTITULO
				cE1_NRDOC   := _QRYREPROC->TIT_NRDOC
				cE1_PARCELA := _QRYREPROC->TIT_PARCELA
				cE1_TIPO    := _QRYREPROC->TIT_TIPO
				cE1_NATUREZ := _QRYREPROC->TIT_NATUREZA
				cE1_EMISSAO := _QRYREPROC->TIT_EMISSAO
				cE1_VENCTO  := _QRYREPROC->TIT_VENCIMENTO
				cE1_VENCREA := _QRYREPROC->TIT_VENCIMENTO
				nE1_IDLAN   := val(_QRYREPROC->TIT_IDLAN)
				nE1_IDAPLIC := _QRYREPROC->TIT_IDHABILITACAOFILIAL
				cE1_CLIENTE := _QRYREPROC->TIT_CLIENTE
				cE1_NOMCLI  := _QRYREPROC->TIT_NOMECLI
				cE1_NUMRA   := _QRYREPROC->TIT_NUMRA
				cE1_BAIXA   := _QRYREPROC->TIT_DATABAIXA
				nE1_VALOR   := _QRYREPROC->TIT_VALOR
				nE1_VALLIQ  := _QRYREPROC->TIT_VALORBAIXADO
				nE1_DESCONT := _QRYREPROC->TIT_DESCONTO
				nE1_MULTA   := _QRYREPROC->TIT_MULTA
				nE1_JUROS   := _QRYREPROC->TIT_JUROS
				nE1_PORCJUR := _QRYREPROC->TIT_JUROSDIA
				nE1_MULTDIA := _QRYREPROC->TIT_MULTADIA
				nE1_VLBOLSA := _QRYREPROC->TIT_VALORBOLSA
				cE1_STATUS  := _QRYREPROC->TIT_STATUS
				cE1_HIST    := _QRYREPROC->TIT_HISTORICO
				cE1_CCD     := _QRYREPROC->TIT_CENTROCUSTO
				cE1_ORIGEM  := _QRYREPROC->TIT_ORIGEM
				cRotGrava   := _QRYREPROC->TIT_ROTGRAVA
				cUsr	 	:= _QRYREPROC->TIT_USUGRAVA
				nRecnoSE1	:= _QRYREPROC->TIT_RECNOSE1
				nVlrCanc 	:= _QRYREPROC->TIT_VALORCANCELADOBAIXA
				cE1_ITEMD 	:= _QRYREPROC->TIT_ITEMCONTABIL
				cE1_CLVLDB 	:= _QRYREPROC->TIT_CLASSEVALOR
				nE1_VLBOLP 	:= _QRYREPROC->TIT_VALORBOLSAPONT
				cE1_PORTADO := _QRYREPROC->TIT_BANCO
				cE1_AGEDEP  := _QRYREPROC->TIT_AGENCIA
				cE1_CONTA   := _QRYREPROC->TIT_CONTABCO
				cE1_NUMBCO  := _QRYREPROC->TIT_NOSSONUMERO
				cE1_SERVICO := _QRYREPROC->TIT_SERVICO
				nE1_IDBOLET := _QRYREPROC->TIT_IDBOLETO
				nE1_NUMINSC := _QRYREPROC->TIT_NUMEROINSC
				nE1_PROCEL 	:= _QRYREPROC->TIT_PROCEL               
			endif
		endif
	endif
	_QRYREPROC->( dbCloseArea() )

elseif cTable == "INT_CCUSTOLOG" //Integracao de Centro de Custos

	cQuery := "select CCT_PROCIMPORT, CCT_COLIGADA, CCT_FILIAL, CCT_CODCUSTO, CCT_DESCRICAO, CCT_PERMITELANC, CCT_CODREDUZI"
	cQuery += "  from "	+cTable
	cQuery += " where "+cPrefix+"_ID = "+cID
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "_QRYREPROC", .F., .F. )

	cEmpINT	 := StrZero(_QRYREPROC->CCT_COLIGADA,2)
	cFilINT  := StrZero(val(_QRYREPROC->CCT_FILIAL),2)		

	_QRYREPROC->( dbCloseArea() )

elseif cTable == "INT_MOEDALOG" //Integracao de Moedas

	cQuery := "select MOE_PROCIMPORT, MOE_COLIGADA, MOE_FILIAL, MOE_MOEDA, MOE_SIMBOLO, MOE_DESCRICAO, MOE_DECIMAL"
	cQuery += "  from "	+cTable
	cQuery += " where "+cPrefix+"_ID = "+cID
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "_QRYREPROC", .F., .F. )

	cEmpINT	 := StrZero(_QRYREPROC->MOE_COLIGADA,2)
	cFilINT  := StrZero(val(_QRYREPROC->MOE_FILIAL),2)
	
	_QRYREPROC->( dbCloseArea() )

elseif cTable == "INT_TITULACAOLOG" //Integracao de Titulacao de Professores

	cQuery := "select TTL_PROCIMPORT, TTL_COLIGADA, TTL_FILIAL, TTL_CODIGO, TTL_DESCRICAO"
	cQuery += "  from "	+cTable
	cQuery += " where "+cPrefix+"_ID = "+cID
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "_QRYREPROC", .F., .F. )

	cEmpINT	 := StrZero(_QRYREPROC->TTL_COLIGADA,2)
	cFilINT  := StrZero(val(_QRYREPROC->TTL_FILIAL),2)
	
	_QRYREPROC->( dbCloseArea() )

elseif cTable == "INT_TIPODOCLOG" //Integracao de Tipos de Documentos

	cQuery := "select TOD_PROCIMPORT, TOD_COLIGADA, TOD_FILIAL, TOD_CODIGO, TOD_DESCRICAO"
	cQuery += "  from "	+cTable
	cQuery += " where "+cPrefix+"_ID = "+cID
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "_QRYREPROC", .F., .F. )

	cEmpINT	 := StrZero(_QRYREPROC->TOD_COLIGADA,2)
	cFilINT  := StrZero(val(_QRYREPROC->TOD_FILIAL),2)
		
	_QRYREPROC->( dbCloseArea() )

elseif cTable == "INT_CONTACXALOG" //Integracao de Banco, Agencia e Conta (Conta Caixa)

	cQuery := "select CXA_PROCIMPORT,CXA_COLIGADA,CXA_FILIAL,CXA_ROTGRAVA,CXA_BANCO,CXA_DESCRICAO,CXA_NREDUZ,CXA_AGENCIA,"
	cQuery += "CXA_NOMEAGE,CXA_END,CXA_BAIRRO,CXA_MUN,CXA_EST,CXA_CEP,CXA_TEL,CXA_PAIS,CXA_CONTA,CXA_DIGCONTA,CXA_CEDENTE,"
	cQuery += "CXA_CODCEDENTE,CXA_TIPOCARTEIRA,CXA_CARTEIRA,CXA_CODCXA,CXA_SALATU,CXA_ATIVA"
	cQuery += "  from "	+cTable
	cQuery += " where "+cPrefix+"_ID = "+cID
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "_QRYREPROC", .F., .F. )

	cEmpINT	 := StrZero(_QRYREPROC->CXA_COLIGADA,2)
	cFilINT  := StrZero(val(_QRYREPROC->CXA_FILIAL),2)
	cBlocked := iif(_QRYREPROC->CXA_ATIVA==2,"1","2")	

endif

if lContinua
	if !empty(cMsgError) //Ocorreu erro
		conout(cMsgError)
		MsgStop(cMsgError)
	else
		//Verifica se o registro ainda ficou inconsistente
		cQuery := "select "+cPrefix+"_STATUSIMPORT, "+cPrefix+"_OBSIMPORT from "+cTable+" where "+cPrefix+"_ID = "+cID+" and "+cPrefix+"_STATUSIMPORT <> '2' "
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "ITN", .F., .F. )
		if !ITN->( EoF() )
			cMsgError := STR0090 +Chr(10)+ STR0091 +Chr(10)+Chr(10)
			cMsgError += cPrefix+"_STATUSIMPORT: " + alltrim(ITN->&(cPrefix+"_STATUSIMPORT"))+Chr(10)
			cMsgError += cPrefix+"_OBSIMPORT: " + alltrim(ITN->&(cPrefix+"_OBSIMPORT"))+Chr(10)
		endif
		ITN->( dbClosearea() )
	endif


	if !empty(cMsgError)
		DEFINE MSDIALOG oDlgErr TITLE STR0068 From 3,0 to 340,417 PIXEL //"Aviso"
		TSay():New( 010, 005, {|| STR0092 } , oDlgErr,,,,,, .T.,CLR_HRED,, 100, 008,,,,,, ) //"Problema:"
		@ 25,5 GET oMemoErr  VAR cMsgError MEMO SIZE 200,125 OF oDlgErr PIXEL
		oMemoErr:bRClicked := {||AllwaysTrue()}
		oMemoErr:LREADONLY := .T.
		DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlgErr:End() ENABLE OF oDlgErr PIXEL //OK
		ACTIVATE MSDIALOG oDlgErr CENTER
	endif

	//Atualizando na tela a lista de registros da tabela de integracao selecionada
	PxcLstReg(cPrefix,cTable,@aRegsTbINT,cCStatus)
	PxCObserva(cPrefix,cTable)
endif

Return .F.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPxCCampAltบAutor  ณ Denis D. Almeida   บ Data ณ  08/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCampos que foram alterados na tela de Detalhamento          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integracao Protheus x RM Classis Net (RM Sistemas)         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบOBS:	  	 ณFuncao antiga chamava-se IntCampAlt						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PxCCampAlt(aRegDetalhe,oRegDetalhe)
Local cCmp := UPPER(alltrim(aRegDetalhe[oRegDetalhe:nAt,01]))

if Ascan( aCamposAlt, {|x| x[1] == cCmp } ) == 0
	Aadd(aCamposAlt,{ cCmp })
endif

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPxCXFilialบAutor  ณ Alberto Deviciente บ Data ณ  19/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a Filial Correta de acordo como Configurada a      บฑฑ
ฑฑบ          ณtabela (Exclusiva ou Compartilada).                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integracao Protheus x RM Classis Net (RM Sistemas)         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบOBS:	  	 ณFuncao antiga chamava-se IntXFilial						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PxCXFilial(cEmpr, cTabl, cFilCorr)
Local cFilRet := ""
Local cQuery := ""

cQuery := "SELECT COUNT(*) QTD "
cQuery += "  FROM SX2"+cEmpr+"0 "
cQuery += " WHERE X2_CHAVE = '"+cTabl+"'"
dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "QRYFIL", .F., .F. )

if QRYFIL->QTD > 0
	cFilRet := cFilCorr //Filial Exclusiva
else
	cFilRet := "  " //Filial Compartilhada
endif

QRYFIL->( dbCloseArea() )

Return cFilRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPxCRMCanExบAutor  ณAlberto Deviciente  บ Data ณ 29/Jul/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o registro pode ser excluido de acordo com a   บฑฑ
ฑฑบ          ณ integracao.                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcTblRM   = Tabela do RM a ser buscado o registro            บฑฑ
ฑฑบ          ณaCpsRM   = Array c/ os campos a serem considerados no filtroบฑฑ
ฑฑบ          ณ  Exemplo: {campo1, campo2}                                 บฑฑ
ฑฑบ          ณaValores = Array c/ os valores a serem filtrados            บฑฑ
ฑฑบ          ณ  Exemplo: {valor1, valor2}                                 บฑฑ
ฑฑบ          ณcMsg     = Mensagem a ser exibida caso o regisro nao exista.บฑฑ
ฑฑบ          ณ A Mensagem eh opcional. Se nao for passada sera exibida umaบฑฑ
ฑฑบ          ณ mensagem padrao.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ .T.     = Qdo. permitir a exclusao                         บฑฑ
ฑฑบ          ณ .F.     = Qdo. bloquear a Exclusao                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integra็ใo Protheus X RM Sistemas                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบOBS:	  	 ณFuncao antiga chamava-se IntRMCanEx						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function PxCRMCanEx( cTblRM, aCpsRM, aValores, cMsg )
Local aArea 		:= GetArea()
Local lTopOk 		:= .T.
Local lRet   		:= .T.
Local cAlias 		:= GetNextAlias()
Local cQuery 		:= ""
Local cFiltro 		:= ""
Local nX  			:= 0
Local nAmbCLASSIS 	:= 0
Local nAmbTOP		:= 0

Default cMsg 		:= ""

if empty(cTblRM) .or. ( len(aCpsRM) <> len(aValores) )
	MsgStop(STR0093 + STR0094) //"Erro ao verificar se o registro pode ser excluํdo. "foi identificado que os parโmetros passados para verificacao sใo invแlidos na fun็ใo [PxCRMCanEx]."
	Return .F.
endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida as conexoes com as bases Protheus e Classisณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

if lTopOk

	// Alterna o TOP para o ambiente do CLASSIS.NET (RM)
	TCSetConn( nAmbCLASSIS )

	if TCCanOpen(cTblRM) //Somente verifica se a tabela existir criada na base

		//Monta a query para verificar se o registro existe na tabela na base de dados do CLASSIS.NET (RM)
		for nX:=1 to len(aCpsRM)
			if empty(cFiltro)
				cFiltro += aCpsRM[nX]+" = '"+Rtrim(aValores[nX])+"'"
			else
				cFiltro += " AND "+aCpsRM[nX]+" = '"+Rtrim(aValores[nX])+"'"
			endif
		next nX

		cQuery := "SELECT COUNT(*) AS CONT"
		cQuery += "  FROM "+cTblRM
		cQuery += " WHERE "+cFiltro
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAlias, .F., .T.)

		if (cAlias)->( !EoF() ) .and. (cAlias)->CONT > 0
			if empty(cMsg)
				MsgSTop(STR0092+Chr(13)+Chr(10)+STR0095+cTblRM+STR0096)
			else
				MsgSTop(cMsg)
			endif
			lRet := .F.
		endif
		(cAlias)->( dbCloseArea() )

	endif

	// Alterna o TOP para o ambiente padrao
	TCSetConn( nAmbTOP )

	TCUNLINK(nAmbCLASSIS) // Finaliza a conexao do TOP com o ambiente CLASSIS.NET [nAmbCLASSIS]
else
	//Ocorreu algum erro e nao conseguiu fazer conexao com o TOP
	lRet := .F.
endif

RestArea( aArea )

Return lRet
