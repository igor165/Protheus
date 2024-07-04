// ษออออออออหออออออออป
// บ Versao บ 26     บ
// ศออออออออสออออออออผ

#INCLUDE "protheus.ch"
#INCLUDE "DbTree.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OFIXA120.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Rubens Takahashi
    @since  25/07/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007771_1"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFIXA120   | Autor |  Takahashi            | Data | 28/02/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Painel de Oficina                                            |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIXA120()

	// Objeto de Tamanho de Tela
	Local oSize

	// Objetos da Tela
	Local oMenuTree
	Private oDlgPanOfi
	//

	Private cXA120FIlAnt := cFilAnt
	Private cXA120EmpAnt := cEmpAnt

	Private oLayer
	Private cAliasAtu

	Private aCBoxBrw := {}
	Private oBrwPainel	// MBrowse do Painel

	Private lLIBVOO := ( VOO->(FieldPos("VOO_LIBVOO")) <> 0 )

	Private aRotina := MenuDef()

	Private cXA120DefFilter := "" // Filtro Padrao da Rotina, deve ser utilizado pois em alguns pontos o FWMBrowse perdia o filtro

	// Compatibilidade com o OFIOM350
	Private cAgParam
	Private cFilBox  := ""
	Private nAgeMax  := 1
	Private cOrdVet
	VAI->(DbSetOrder(4))
	If VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
		nAgeMax := VAI->VAI_AGEMAX
		cFilBox := VAI->VAI_BOXAGE
	EndIf

	Private lMultiFil := VerSenha(115)
	Private lBarra    := FindFunction("FMX_MDIBar")

	SetStartMod(.t.) // Variavel interna para funcionamento correto dos campos MEMOS na Visualizacao por outras Rotinas

	cAgParam := Left(GetNewPar("MV_AGPARAM",("0"+"2"+"1"+"07"+"08"+"18"+" XXXXX 1"))+space(17),17) // (0=SemControleHoras/1=ComControleHoras)(1=1Hr/2=30min) (1=Filial/2=Todas) (QtdDias) (HrIni) (HrFin) (Dom) (2a.) (3a.) (4a.) (5a.) (6a.) (Sab) (Ordem Vetor)
	If Empty(Alltrim(cAgParam))
		cAgParam := "0"+"2"+"1"+"07"+"08"+"18"+" XXXXX 1" // (0=SemControleHoras/1=ComControleHoras) (1=1Hr/2=30min) (1=Filial/2=Todas) (QtdDias) (HrIni) (HrFin) (Dom) (2a.) (3a.) (4a.) (5a.) (6a.) (Sab) (Ordem Vetor)
	EndIf
	cOrdVet  := IIf(!Empty(substr(cAgParam,17,1)),substr(cAgParam,17,1),"1") // Ordem do Vetor
	//

	oSize := FwDefSize():New(.f.)

	cAliasAtu := ""

	DEFINE MSDIALOG oDlgPanOfi TITLE STR0001 PIXEL ;
		FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] // "Painel de Oficina"

	//Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botใo de fechar
	oLayer := FWLayer():new()
	oLayer:Init(oDlgPanOfi,.f.)

	//Cria as colunas do Layer
	oLayer:addCollumn('Menu',20,.T.)
	oLayer:addCollumn('Browse',80,.F.)

	//Adiciona Janelas as colunas
	oLayer:addWindow('Menu','Menu_W01',STR0002,100,.F.,.F., /* bAction */ ,, /* bGotFocus */ )		// "Menu Painel Oficina"
	oLayer:addWindow('Browse','Browse_W01',STR0003,100,.F.,.F., /* bAction */ ,, /* bGotFocus */ )	// "Ordem de Servi็o"

	//Coloca o botใo de split na coluna
	oLayer:setColSplit('Menu',CONTROL_ALIGN_RIGHT)

	// Cria Menu Lateral //
	OXA120CMENU(oMenuTree)

	OXA120CBROWSE("VO1")

	oDlgPanOfi:Activate()

	OX120SETKEY("D") // Desativa Teclas de Atalho

	cFilAnt := cXA120FIlAnt
	cEmpAnt := cXA120EmpAnt

Return



/*
===============================================================================
###############################################################################
##+----------+-------------+-------+----------------------+------+----------+##
##|Funcao    | OXA120CMENU | Autor |  Takahashi           | Data | 28/02/13 |##
##+----------+-------------+-------+----------------------+------+----------+##
##|Descricao | Cria Menu do Painel                                          |##
##+----------+--------------------------------------------------------------+##
##|Parametro | oMenuTree -> Objeto do Menu                                  |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OXA120CMENU(oMenuTree)

Local nCont
Local aMenu := {}
//Local aCustomMenu := {}

oMenuTree := Xtree():New(0, 0, 0, 0, oLayer:getWinPanel('Menu','Menu_W01'))
oMenuTree:Align := CONTROL_ALIGN_ALLCLIENT

/*
  Estrutura da Matriz aMenu

  [01] - Nome do Menu
  [02] - Nome do Pai
  [03] - Descricao (Menu)
  [04] - Tabela para Browse
  [05] - Funcao para analisar no Acesso no Menu (XNU)
  [06] - Funcao executada ao selecionar opcao do menu
  [07] - nOpc da Rotina
  [08] - Indica se ้ uma opcao de Inclusao (utilizado so para reposicionar browse)
*/

// Menu de Ordem de Servico //
AADD( aMenu , { "OFICINA"                       ,""                    ,STR0006,"VO1",""        ,""        ,0,.f.,".t."                     , NIL } ) // "Oficina"
AADD( aMenu , { "OFICINA_ABERTURA"              ,"OFICINA"             ,STR0007,"VO1","OFIOM010",""        ,0,.f.,".t."                     , NIL } ) // "Abertura"
AADD( aMenu , { "OFICINA_ABERTURA_INCLUIR"      ,"OFICINA_ABERTURA"    ,STR0008,"VO1","OFIOM010","OFIOM010",2,.t.,".t."                     , NIL } ) // "Abrir"
AADD( aMenu , { "OFICINA_ABERTURA_ALTERAR"      ,"OFICINA_ABERTURA"    ,STR0009,"VO1","OFIOM010","OFIOM010",3,.f.,"!Empty(VO1->VO1_NUMOSV)" , NIL } ) // "Alterar"
AADD( aMenu , { "OFICINA_PECA"                  ,"OFICINA"             ,STR0010,"VO1","OFIOM020",""        ,0,.f.,".t."                     , NIL } ) // "Req. Pe็a"
AADD( aMenu , { "OFICINA_PECA_REQUISITAR"       ,"OFICINA_PECA"        ,STR0011,"VO1","OFIOM020","OFIOM020",2,.f.,"!Empty(VO1->VO1_NUMOSV)" , NIL } ) // "Requisitar"
AADD( aMenu , { "OFICINA_PECA_DEVOLVER"         ,"OFICINA_PECA"        ,STR0012,"VO1","OFIOM020","OFIOM020",3,.f.,"!Empty(VO1->VO1_NUMOSV)" , NIL } ) // "Devolver"
AADD( aMenu , { "OFICINA_PECA_REQ_OUTRAS_OSs"   ,"OFICINA_PECA"        ,STR0074,"VO1","OFIOM020","OM0200131_Requisitar_Pecas_de_outras_OSs",4,.f.,"!Empty(VO1->VO1_NUMOSV)" , NIL } ) // Req.Pe็as de outras OSs
AADD( aMenu , { "OFICINA_PECA_ALTERAR"          ,"OFICINA_PECA"        ,STR0009,"VO1","OFIOM020","OFIOM020",5,.f.,"!Empty(VO1->VO1_NUMOSV)" , NIL } ) // "Alterar"
AADD( aMenu , { "OFICINA_PECA_HISTORICOR"       ,"OFICINA_PECA"        ,STR0070,"VO1","OFIOM020","OM020HRD",13,.f.,"!Empty(VO1->VO1_NUMOSV)" , NIL } ) // "Hist๓rico Req/Dev"
If FindFunction("OM020REM")
	AADD( aMenu , { "OFICINA_PECA_NFREMESSA"    ,"OFICINA_PECA"        ,STR0034,"VO1","OFIOM020","OFIOM020",6,.f.,"!Empty(VO1->VO1_NUMOSV)" , NIL } ) // "Rem. Atend. Externo"
	AADD( aMenu , { "OFICINA_PECA_NFRETORNO"    ,"OFICINA_PECA"        ,STR0035,"VO1","OFIOM020","OFIOM020",7,.f.,"!Empty(VO1->VO1_NUMOSV)" , NIL } ) // "Ret. Rem. Atend. Ext."
	AADD( aMenu , { "OFICINA_PECA_NFCANCELA"    ,"OFICINA_PECA"        ,STR0054,"VO1","OFIOM020","OM020CAN",8,.f.,"!Empty(VO1->VO1_NUMOSV)" , NIL } ) // "Canc.NF Rem. Atend. Ext."
EndIf
If FindFunction("OM020001_CancNFRetRem")
	AADD( aMenu , { "OFICINA_PECA_NFCANCELA"    ,"OFICINA_PECA"        ,STR0065,"VO1","OFIOM020","OM020001_CancNFRetRem",9,.f.,"!Empty(VO1->VO1_NUMOSV)" , NIL } ) // "Canc. NF Retorno Rem. Atend. Ext."
EndIf
If FindFunction("OM020VSJMANUAL") .and. VSJ->(FieldPos("VSJ_CODIGO")) > 0
	AADD( aMenu , { "OFICINA_PECA_VSJMANUAL"    ,"OFICINA_PECA"        ,STR0055,"VO1","OFIOM020","OFIOM020",10,.f.,"!Empty(VO1->VO1_NUMOSV)" , NIL } ) // "Pe็as da OS"
EndIf
AADD( aMenu , { "OFICINA_SERVICO"               ,"OFICINA"             ,STR0013,"VO1","OFIOM030",""        ,0,.f.,".t."                     , NIL } ) // "Req. Servi็o"
AADD( aMenu , { "OFICINA_SERVICO_REQUISITAR"    ,"OFICINA_SERVICO"     ,STR0014,"VO1","OFIOM030","OFIOM030",2,.f.,"!Empty(VO1->VO1_NUMOSV)" , NIL } ) // "Requisitar"
AADD( aMenu , { "OFICINA_SERVICO_ALTERAR"       ,"OFICINA_SERVICO"     ,STR0009,"VO1","OFIOM030","OFIOM030",3,.f.,"!Empty(VO1->VO1_NUMOSV)" , NIL } ) // "Alterar"
If FindFunction("OFA1100056_RelacionaCampanha") .And. VOU->(FieldPos("VOU_SERINT")) > 0
	AADD( aMenu , { "OFICINA_SERVICO_RELACIONAR","OFICINA_SERVICO"     ,STR0073,"VO1","OFIOM030","OFIOM030",5,.f.,"!Empty(VO1->VO1_NUMOSV)" , NIL } ) // "Relacionar Campanha"
EndIf
AADD( aMenu , { "OFICINA_LIBERAR"               ,"OFICINA"             ,STR0016,"VO1","OFIOM140",""        ,0,.f.,".t."                     , NIL } ) // "Libera็ใo"
AADD( aMenu , { "OFICINA_LIBERAR_LIBERAR"       ,"OFICINA_LIBERAR"     ,STR0017,"VO1","OFIOM140","OFIOM140",2,.f.,"!Empty(VO1->VO1_NUMOSV)" , NIL } ) // "Liberar"
AADD( aMenu , { "OFICINA_FECHAR"                ,"OFICINA"             ,STR0018,"VO1","OFIXA100",""        ,0,.f.,".t."                     , NIL } ) // "Fechamento"
AADD( aMenu , { "OFICINA_FECHAR_FECHAR"         ,"OFICINA_FECHAR"      ,STR0019,"VO1","OFIXA100","OFIXA100",2,.f.,"!Empty(VO1->VO1_NUMOSV)" , NIL } ) // "Fechar"
AADD( aMenu , { "OFICINA_CANCELAR"              ,"OFICINA"             ,STR0020,"VO1","OFIOM150",""        ,0,.f.,".t."                     , NIL } ) // "Cancelamento"
AADD( aMenu , { "OFICINA_CANCELAR_CANCELAR"     ,"OFICINA_CANCELAR"    ,STR0021,"VO1","OFIOM150","OFIOM150",2,.f.,"!Empty(VO1->VO1_NUMOSV)" , NIL } ) // "Cancelar"
AADD( aMenu , { "OFICINA_CONSULTAR"             ,"OFICINA"             ,STR0031,"VO1","OFIOC060",""        ,0,.f.,".t."                     , NIL } ) // "Consulta OS"
AADD( aMenu , { "OFICINA_CONSULTAR_CONSULTAR"   ,"OFICINA_CONSULTAR"   ,STR0032,"VO1","OFIOC060","OFIOC060",2,.f.,"!Empty(VO1->VO1_NUMOSV)" , NIL } ) // "Consultar"
AADD( aMenu , { "OFICINA_CONSULTARNF"           ,"OFICINA"             ,STR0036,"VO1","OFIOC060",""        ,0,.f.,".t."                     , NIL } ) // "NF's da OS""
AADD( aMenu , { "OFICINA_CONSULTARNF_CONSULTAR" ,"OFICINA_CONSULTARNF" ,STR0032,"VO1","OFIOC060","OXA120NFCONS",2,.f.,"!Empty(VO1->VO1_NUMOSV)" , NIL } ) // "Consultar"
If FindFunction("OM010BCO")
	AADD( aMenu , { "OFICINA_BASECONHE"         ,"OFICINA"             ,STR0048,"VO1","OFIOM010",""        ,0,.f.,".t."                     , NIL } ) // Banco de Conhecimento
	AADD( aMenu , { "OFICINA_BASECONHE_CONSULTA","OFICINA_BASECONHE"   ,STR0048,"VO1","OFIOM010","OM010BCO",3,.f.,"!Empty(VO1->VO1_NUMOSV)" , NIL } ) // Banco de Conhecimento
EndIf
If FindFunction("OFIOM470")
	AADD( aMenu , { "OFICINA_INCONVENIENTE"             ,"OFICINA"     ,STR0056 ,"VO1","OFIOM470",""       ,0,.f.,".t."                     , NIL } )  // "Reparo/Incoveniente"
	AADD( aMenu , { "OFICINA_INCONVENIENTE_VISUALIZAR"  ,"OFICINA_INCONVENIENTE",STR0022,"VO1","OFIOM470","OFIOM470",2,.f.,"!Empty(VO1->VO1_NUMOSV)" , NIL } ) // "Visualizar"
	AADD( aMenu , { "OFICINA_INCONVENIENTE_ALTERAR"     ,"OFICINA_INCONVENIENTE",STR0009,"VO1","OFIOM470","OFIOM470",3,.f.,"!Empty(VO1->VO1_NUMOSV)" , NIL } ) // "Alterar"
Endif
If FindFunction("OFIOC330")
	AADD( aMenu , { "OFICINA_HISTORICO"          ,"OFICINA"            ,STR0057 ,"VO1","OFIOC330",""        ,0,.f.,".t."                     , NIL } ) // "Hist๓rico do Veํculo"
	AADD( aMenu , { "OFICINA_HISTORICO_CONSULTAR","OFICINA_HISTORICO"  ,STR0058 ,"VO1","OFIOC330","OFIOC330",2,.f.,"!Empty(VO1->VO1_NUMOSV)" , NIL } ) // "Consultar"
Endif
AADD( aMenu , { "OFICINA_NODE_IM"                ,"OFICINA"            ,STR0049,"VO1","OFIXA120",""        ,0,.f.,".t."                     , NIL } ) // Impressใo
AADD( aMenu , { "OFICINA_NODE_IM_R"              ,"OFICINA_NODE_IM"    ,STR0050,"VO1","OFIXA120","OX120IMP",2,.f.,"!Empty(VO1->VO1_NUMOSV)" , NIL } ) // "Impressใo da OS

// Menu de Agendamento //
AADD( aMenu , { "AGENDAMENTO"                    ,""           ,STR0004,"VSO","OFIOM350",""        , 0,.f.,"t."                      , NIL } ) // "Agendamento"
AADD( aMenu , { "AGENDAMENTO_VISUALIZAR"         ,"AGENDAMENTO",STR0022,"VSO","OFIOM350","OFIOM350", 2,.f.,"!Empty(VSO->VSO_NUMIDE)" , NIL } ) // "Visualizar"
AADD( aMenu , { "AGENDAMENTO_INCLUIR"            ,"AGENDAMENTO",STR0023,"VSO","OFIOM350","OFIOM350", 3,.t.,"!Empty(VSO->VSO_NUMIDE)" , NIL } ) // "Incluir"
AADD( aMenu , { "AGENDAMENTO_ALTERAR"            ,"AGENDAMENTO",STR0009,"VSO","OFIOM350","OFIOM350", 4,.f.,"!Empty(VSO->VSO_NUMIDE)" , NIL } ) // "Alterar"
AADD( aMenu , { "AGENDAMENTO_CANCELAR"           ,"AGENDAMENTO",STR0021,"VSO","OFIOM350","OFIOM350", 5,.f.,"!Empty(VSO->VSO_NUMIDE)" , NIL } ) // "Cancelar"
AADD( aMenu , { "AGENDAMENTO_ORCAMENTO"          ,"AGENDAMENTO",STR0005,"VSO","OFIOM350","OFIOM350", 8,.f.,"!Empty(VSO->VSO_NUMIDE)" , NIL } ) // "Orcamento"
AADD( aMenu , { "AGENDAMENTO_CONFAGENDA"         ,"AGENDAMENTO",STR0024,"VSO","OFIOM350","OFIOM350",10,.f.,"!Empty(VSO->VSO_NUMIDE)" , NIL } ) // "Confirma Agendam."
AADD( aMenu , { "AGENDAMENTO_CONFPRESENCA"       ,"AGENDAMENTO",STR0033,"VSO","OFIXC006","OFIXC006",10,.f.,"!Empty(VSO->VSO_NUMIDE)" , NIL } ) // "Confirma Presen็a"
If FindFunction("OFIOC330")
	AADD( aMenu , { "AGENDAEMENTO_HISTORICO"     ,"AGENDAMENTO",STR0057,"VSO","OFIOC330","OFIOC330_1",2,.f.,"!Empty(VSO->VSO_NUMIDE)" , NIL } ) // "Hist๓rio do Veํculo"
Endif

// Menu de Or็amento //
AADD( aMenu , { "ORCAMENTO"                     ,""         ,STR0005,"VS1","OFIXA011",""          , 0,.f.,".t."                     , NIL } ) // "Or็amento"
AADD( aMenu , { "ORCAMENTO_VISUALIZAR"          ,"ORCAMENTO",STR0022,"VS1","OFIXA011","OFIXA011"  , 2,.f.,"!Empty(VS1->VS1_NUMORC)" , NIL } ) // "Visualizar"
AADD( aMenu , { "ORCAMENTO_INCLUIR"             ,"ORCAMENTO",STR0023,"VS1","OFIXA011","OFIXA011"  , 3,.t.,".t."                     , NIL } ) // "Incluir"
AADD( aMenu , { "ORCAMENTO_ALTERAR"             ,"ORCAMENTO",STR0009,"VS1","OFIXA011","OFIXA011"  , 4,.f.,"!Empty(VS1->VS1_NUMORC)" , NIL } ) // "Alterar"
AADD( aMenu , { "ORCAMENTO_CANCELAR"            ,"ORCAMENTO",STR0021,"VS1","OFIXA011","OFIXA011"  , 5,.f.,"!Empty(VS1->VS1_NUMORC)" , NIL } ) // "Cancelar"
AADD( aMenu , { "ORCAMENTO_FATURAR"             ,"ORCAMENTO",STR0025,"VS1","OFIXA011","OFIXA011"  , 6,.f.,"!Empty(VS1->VS1_NUMORC)" , NIL } ) // "Faturar"
AADD( aMenu , { "ORCAMENTO_CLONAR"              ,"ORCAMENTO",STR0026,"VS1","OFIXA011","OFIXA011"  , 7,.f.,"!Empty(VS1->VS1_NUMORC)" , NIL } ) // "Clonar"
AADD( aMenu , { "ORCAMENTO_CLONARPOROS"         ,"ORCAMENTO",STR0027,"VS1","OFIXA011","OFIXA011"  , 8,.f.,".t."                     , NIL } ) // "Clonar por OS"
AADD( aMenu , { "ORCAMENTO_LIBERAR"             ,"ORCAMENTO",STR0071,"VS1","OFIXA011","OFIXA011"  , 9,.f.,"!Empty(VS1->VS1_NUMORC)" , NIL } ) // "Liberar Itens com Saldo"
If FindFunction("OFIOC430") //se existir a pesquisa avancada exibe na tela
	AADD( aMenu , { "ORCAMENTO_PESQAVAN"        ,"ORCAMENTO",STR0028,"VS1","OFIXA011","OFIOC430"  ,10,.f.,".t."                     , NIL } ) // "Pesquisa Avan็ada"
EndIF
if GetNewPar("MV_VERIORC","1") $ "2"
	If FindFunction("OFIXC008")
		AADD( aMenu , { "ORCAMENTO_CONSULTAPECA","ORCAMENTO",STR0029,"VS1","OFIXA011","OFIXC008"  ,01,.f.,".t."                     , NIL } ) // "Consulta de Pe็a"
	EndIF
Elseif GetNewPar("MV_VERIORC","1") $ "M_CONSPEC"
	If FindFunction("U_M_CONSPEC")
		AADD( aMenu , { "ORCAMENTO_CONSULTAPECA","ORCAMENTO",STR0029,"VS1","OFIXA011","M_CONSPEC" ,01,.f.,".t."                     , NIL } ) // "Consulta de Pe็a"
	Endif
Else
	If FindFunction("OFIXC001")
		AADD( aMenu , { "ORCAMENTO_CONSULTAPECA","ORCAMENTO",STR0029,"VS1","OFIXA011","OFIXC001"  ,01,.f.,".t."                     , NIL } ) // "Consulta de Pe็a"
	EndIF
Endif
If FindFunction("U_ORCAMTO")
	AADD( aMenu , { "ORCAMENTO_NODE_IM_R"       ,"ORCAMENTO",STR0059 ,"VS1","OFIXA120","OX120IMPO",02,.f.,"!Empty(VS1->VS1_NUMORC)" , NIL } ) // "Impressใo da Or็amento"
Endif

// Adiciona itens no menu por customiza็ใo
OXA120ROT(@aMenu)
//

For nCont := 1 to Len(aMenu)
	If Empty(aMenu[nCont,2])
		OXA120ADDM(aMenu[nCont],aMenu,oMenuTree)
	EndIf
Next nCont

// Adiciona opcao SAIR
oMenuTree:AddTree ( "Sair" , "final", "FINAL", "NODE_SAIR", { || oDlgPanOfi:End() } , /*bRClick*/, /* */ )
oMenuTree:EndTree()
//

Return

/*
===============================================================================
###############################################################################
##+----------+-------------+-------+----------------------+------+----------+##
##|Funcao    | OXA120ROT   | Autor |  Takahashi           | Data | 26/04/16 |##
##+----------+-------------+-------+----------------------+------+----------+##
##|Descricao | Adiciona item customizado ao Menu                            |##
##+----------+--------------------------------------------------------------+##
##|Parametro | aMenu   -> Matriz com opcoes do menu                         |##
##+----------+--------------------------------------------------------------+##
##|Retorno   | aNovBot -> Matriz com opcoes customizadas que serao          |##
##|          |            adicionadas ao menu                               |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OXA120ROT(aMenu)

Local aNovBot := {}
Local nCont
Local nPos
Local nPosMenu

If ExistBlock("OX120ROT")
	If ValType( aNovBot := ExecBlock("OX120ROT",.f.,.f.) ) == "A"
		For nCont := 1 to Len(aNovBot)

			// Validacao para execucao da funcao
			If Len(aNovBot[nCont]) <= 8
				AADD(aNovBot[nCont], .t. )
			endif
			//

			// Parametro passado para MPUserHasAccess para validacao de SUB-MENU
			If Len(aNovBot[nCont]) <= 9
				AADD(aNovBot[nCont], NIL )
			endif
			//

			If Empty(aNovBot[nCont,2])
				AADD(aMenu, aClone( aNovBot[nCont]))
				Loop
			EndIf
			nPosMenu := aScan( aMenu , { |x| x[2] == aNovBot[nCont,2] } )

			If nPosMenu == 0
				nPosMenu := aScan( aMenu , { |x| x[1] == aNovBot[nCont,2] } )
			EndIf

			If nPosMenu == 0
				Loop
			EndIf

			For nPos := nPosMenu to Len(aMenu)
				If aMenu[nPos,2] <> aNovBot[nCont,2] .or. nPos == Len(aMenu)
					If nPos == Len(aMenu)
						nPos++
						AADD( aMenu , {} )
					Else
						AADD( aMenu , {} )
						AINS( aMenu , nPos )
					EndIf
					aMenu[nPos] := aClone( aNovBot[ nCont ])
					Exit
				EndIf
			Next nPos
		Next nCont
	Else
		aNovBot := {}
	EndIf
Endif

Return aNovBot


/*
===============================================================================
###############################################################################
##+----------+-------------+-------+----------------------+------+----------+##
##|Funcao    | OXA120ADDM  | Autor |  Takahashi           | Data | 28/02/13 |##
##+----------+-------------+-------+----------------------+------+----------+##
##|Descricao | Adiciona Item no Menu                                        |##
##+----------+--------------------------------------------------------------+##
##|Parametro | aParMenu  -> Linha da aMenu a ser Adicionada                 |##
##|          | aMenu     -> Matriz com opcoes do menu                       |##
##|          | oMenuTree -> Objeto do Menu                                  |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OXA120ADDM(aParMenu,aMenu,oMenuTree)

Local nCont

If !Empty(aParMenu[6])

	//Valida acessos do usuแrio, incluindo grupos e previlegios
	If MPUserHasAccess( aParMenu[5],aParMenu[7],,.F.,,,aParMenu[10],,1)
	
		iF aParMenu[9] == Nil
			aParMenu[9] := ".t."
		endif

		If At("(",aParMenu[6]) > 0
			cNomeFuncao := Left(aParMenu[6], At("(",aParMenu[6]) - 1)
			cChamadaFuncao := aParMenu[6]
		Else
			cNomeFuncao := aParMenu[6]
			cChamadaFuncao := ""
		EndIf

		cOXA120EXEC := "{ || OXA120EXEC('" +;
			aParMenu[4] + "','" + ;                // cAlias
			cNomeFuncao + "'," + ;                 // cAuxRotina
			Str(aParMenu[7],2) + "," +;            // nAuxOpc
			IIf(aParMenu[8],".t.",".f.") + "," +;  // lInclusao
			"'" + aParMenu[9] + "'," +;            // cValidExec
			"'" + cChamadaFuncao + "'," +;         // cChamadaFuncao
			"'" + aParMenu[5] +"'," +;             // cRotPrin
			IIf(aParMenu[10]== nil,"nil",Str(aParMenu[10],1)) +;                 // Validacao de Sub-Menu na funcao MPUserHasAccess
			" ) }"

		oMenuTree:AddTreeItem ( ;
			aParMenu[3]      ,;
			"PMSTASK4"       ,;
			aParMenu[1]      ,;
			&( cOXA120EXEC ) ,;
			/*bRClick*/      ,;
			&( cOXA120EXEC ) )

	Else
		oMenuTree:AddTreeItem ( aParMenu[3] , "PMSTASK1", aParMenu[1] , &("{ || Help(,1,'SEMPERM',,'"+aParMenu[5]+"',4,1) }") )
	EndIf
Else
	oMenuTree:AddTree ( aParMenu[3], "folder5", "FOLDER6", aParMenu[1], &("{ || OXA120CBROWSE('" + aParMenu[4] + "','" + aParMenu[5] + "' ) }") , /*bRClick*/, /* */ )
	For nCont := 1 to Len(aMenu)
		If aMenu[nCont,2] == aParMenu[1]
			OXA120ADDM(aMenu[nCont],aMenu,oMenuTree)
		EndIf
	Next nCont
	oMenuTree:EndTree()
EndIf

Return

/*
===============================================================================
###############################################################################
##+----------+----------------+-------+-------------------+------+----------+##
##|Funcao    | OXA120CBROWSE  | Autor |  Takahashi        | Data | 28/02/13 |##
##+----------+----------------+-------+-------------------+------+----------+##
##|Descricao | Cria Objeto de Browse                                        |##
##+----------+--------------------------------------------------------------+##
##|Parametro | cAuxAlias  -> Alias do Browse                                |##
##|          | cAuxRotina -> Nome da Rotina do Menu para configuracao do    |##
##|          |               ambiente                                       |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXA120CBROWSE(cAuxAlias,cAuxRotina)

Default cAuxRotina := ""

OX120SETKEY("A",cAuxRotina,cAuxAlias) // Ativa Teclas de Atalho

// Se o Alias atual for igual ao Alias selecionado no Menu, nao precisa fazer nada ...
If cAliasAtu == cAuxAlias
	Return
EndIf
//

FWMsgRun( ,{|| OXA120CBRW(cAuxAlias)},STR0030)

Return


/*
===============================================================================
###############################################################################
##+----------+----------------+-------+-------------------+------+----------+##
##|Funcao    | OXA120CBRW     | Autor |  Takahashi        | Data | 28/02/13 |##
##+----------+----------------+-------+-------------------+------+----------+##
##|Descricao | Func. auxiliar para criacao do objeto de Browse              |##
##+----------+--------------------------------------------------------------+##
##|Parametro | cAuxAlias  -> Alias do Browse                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OXA120CBRW(cAuxAlias)

Local oAuxPanel
Local nPos
Local cAuxCBlock
Local aAuxLeg
Local cCadastro

Private cFilVend := ""
Private cFilFase := ""

cAliasAtu := cAuxAlias

oAuxPanel := oLayer:getWinPanel('Browse','Browse_W01')
oAuxPanel:FreeChildren()

VAI->(DbSetOrder(4))
VAI->(MsSeek( xFilial("VAI") + __CUSERID ))

cXA120DefFilter := ""

Do Case
Case cAuxAlias == "VO1"
	cCadastro := STR0003 // Ordem de Servi็o
	aAuxLeg := OXA100LEG()

	dbSelectArea("VO1")
	dbSetOrder(1)

	// Filtro
	If VAI->VAI_TIPTEC == "4"
		cXA120DefFilter += IIf( !Empty(cXA120DefFilter) , " .AND. " , " " ) + "VO1->VO1_FUNABE = '" + VAI->VAI_CODTEC + "'"
	EndIf
	//

Case cAuxAlias == "VSO"
	cCadastro := STR0004 // Agendamento
	aAuxLeg := OM350L()

	dbSelectArea("VSO")
	dbSetOrder(1)

	// Filtro
	nAgeMax := VAI->VAI_AGEMAX
	cFilBox := VAI->VAI_BOXAGE

	If Empty(VAI->VAI_STAAGE)
		If !Empty(cFilBox)
			cXA120DefFilter += IIf( !Empty(cXA120DefFilter) , " .AND. " , " " ) + "VSO->VSO_NUMBOX = '" + cFilBox + "'"
		EndIf
	Else
		cXA120DefFilter := ""
		If !Empty(cFilBox)
			cXA120DefFilter += IIf( !Empty(cXA120DefFilter) , " .AND. " , " " ) + "VSO->VSO_NUMBOX = '" + cFilBox + "' .AND. "
		EndIf
		If !Empty(VAI->VAI_STAAGE)
			cXA120DefFilter += IIf( !Empty(cXA120DefFilter) , " .AND. " , " " ) + "VSO->VSO_STATUS $ '"+Alltrim(VAI->VAI_STAAGE)+"'"
		EndIf
	EndIf
	//


Case cAuxAlias == "VS1"
	cCadastro := STR0005 // Or็amento
	aAuxLeg := OXA011LEG()

	dbSelectArea("VS1")
	dbSetOrder(1)

	// Filtro
	cFilVend := ""
	cFilFase := ""
	If VAI->VAI_TIPTEC == "4"
		cFilVend := "VS1->VS1_CODVEN == '" + VAI->VAI_CODVEN + "'"
	EndIf
	If Alltrim(VAI->VAI_FASORC) != ""
		cFilFase += "VS1->VS1_STATUS $ '" + Alltrim(VAI->VAI_FASORC) + "'"
	EndIf
	//
	cXA120DefFilter := ""
	If ExistBlock("POA011FT") // Ponto de Entrada para Filtro no Browse
		cXA120DefFilter += IIf( !Empty(cXA120DefFilter) , " .AND. " , " " ) + ExecBlock("POA011FT",.f.,.f.,{.t.})
	Else

		cXA120DefFilter += IIf( !Empty(cFilVend) , IIf ( !Empty(cXA120DefFilter) , " .AND. " , " " ) + cFilVend , "" )
		cXA120DefFilter += IIf( !Empty(cXA120DefFilter) , " .AND. " , " " ) + "VS1->VS1_TIPORC $ '12'"
		cXA120DefFilter += IIf( !Empty(cFilFase) , IIf ( !Empty(cXA120DefFilter) , " .AND. " , "" ) + cFilFase , "" )

		If ExistBlock("POXA011FBR") // Ponto de Entrada para Filtro no Browse
			cXA120DefFilter += IIf( !Empty(cXA120DefFilter) , " .AND. " , " " ) + ExecBlock("POXA011FBR",.f.,.f.,{.t.})
		EndIf

	EndIf
	//


Otherwise
	cCadastro := ""
	aAuxLeg := {}
End

// Acerta o Titulo da Janela
oLayer:setWinTitle ( 'Browse', 'Browse_W01', cCadastro )

If oBrwPainel <> Nil
	oBrwPainel:DeActivate() // Destruir Browse anterior para limpar filtros 
	oBrwPainel := Nil
EndIf

//------------------
// Define o Browse
//------------------

aRotina := {}
oBrwPainel:= FWMBrowse():New() 
oBrwPainel:SetOwner(oAuxPanel)  
oBrwPainel:SetAlias(cAliasAtu)
oBrwPainel:DisableLocate()
oBrwPainel:DisableDetails()
oBrwPainel:SetAmbiente(.F.)
oBrwPainel:SetWalkthru(.F.)
oBrwPainel:SetInsert(.f.)
oBrwPainel:SetUseFilter()
If !Empty(cXA120DefFilter)
	oBrwPainel:SetFilterDefault(cXA120DefFilter)
EndIf
oBrwPainel:lOptionReport := .f.

If Len(aAuxLeg) > 0
	cAuxCBlock := ""
	lAspasS := AT("'",aAuxLeg[1,1]) > 0
	For nPos := 1 to Len(aAuxLeg)
		If lAspasS	// Se a condicao for com aspas simples
			cAuxCBlock += "IIf ( " + aAuxLeg[nPos,1] + " , '" + aAuxLeg[nPos,2] + "' , "
		Else		// Se a condicao for com aspas duplas
			cAuxCBlock += 'IIf ( ' + aAuxLeg[nPos,1] + ' , "' + aAuxLeg[nPos,2] + '" , '
		EndIf
	Next nPos
	cAuxCBlock += aAuxLeg[1,2] + Replicate(")",Len(aAuxLeg))

	//----------------------------
	// Adiciona legenda no Browse
	//----------------------------
	For nPos := 1 to Len(aAuxLeg)
		oBrwPainel:AddLegend(aAuxLeg[nPos,1],aAuxLeg[nPos,2],aAuxLeg[nPos,3])
	Next nPos
	oBrwPainel:AddLegend(aAuxLeg[1,1]+" .or. "+aAuxLeg[2,1],"",aAuxLeg[1,3]+" / "+aAuxLeg[2,3])
EndIf

//-------------------------------------------------------------------
// Ativa็ใo do Browse
//-------------------------------------------------------------------
oBrwPainel:Activate()

Return


/*
===============================================================================
###############################################################################
##+----------+----------------+-------+-------------------+------+----------+##
##|Funcao    | OXA120EXEC     | Autor |  Takahashi        | Data | 28/02/13 |##
##+----------+----------------+-------+-------------------+------+----------+##
##|Descricao | Func. auxiliar para criacao do objeto de Browse              |##
##+----------+--------------------------------------------------------------+##
##|Parametro | cAuxAlias  -> Alias do Browse                                |##
##|          | cAuxRotina -> Rotina a ser executada                         |##
##|          | nAuxOpc    -> nOpc da rotina                                 |##
##|          | lInclusao  -> Indica se ้ inclusao (Para reposicionar browse)|##
##|          | cValidExec -> Valida็ใo executada antes de iniciar a Op็ใo   |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXA120EXEC( cAlias , cAuxRotina , nAuxOpc , lInclusao , cValidExec , cChamadaFuncao, cRotPrin , nSubMenuMPUserHasAc )

Local cBkpFunName := FunName()
Local nRegAtu := 0
Local cAuxFilAnt
Local cNumOrcAtu := ""

Default cValidExec := ".t."
Default cChamadaFuncao := ""

VISUALIZA := ( nAuxOpc == 2 )
INCLUI    := ( nAuxOpc == 3 )
ALTERA    := ( nAuxOpc == 4 )
EXCLUI    := ( nAuxOpc == 5 )

If !MPUserHasAccess( cRotPrin, nAuxOpc, , .t.,,,nSubMenuMPUserHasAc,,1) //Fun็ใo que efetua a checagem de privil้gios do usuแrio
	Return
EndIf

If cAlias <> cAliasAtu
	OXA120CBROWSE(cAlias, cAuxRotina)
	Return
EndIf

If !&(cValidExec) // Valida se pode Executar a Op็ใo
	ShowHelpDlg("OXA120EXEC", {STR0072} ) // Nใo ้ possivel executar a Op็ใo.
	Return
EndIf

If lInclusao
	If lMultiFil
		cAuxFilAnt := FWPesqSM0("M0_CODFIL", cEmpAnt, , , , .t. )
		If !Empty(cAuxFilAnt)
			cFilAnt := cAuxFilAnt
		EndIf
	EndIf
Else
	nRegAtu := Recno()
	cAuxFilAnt := &(cAlias+"->" + cAlias + "_FILIAL")
	If lMultiFil
		If !Empty(cAuxFilAnt)
			cFilAnt := cAuxFilAnt
		EndIf
	Else
		If cFilAnt <> cAuxFilAnt
			ShowHelpDlg("OXA120MFIL", {STR0066} ) // "Usuแrio nใo estแ habilitado a modificar registro de outra filial."
			Return
		EndIf
	EndIf
	If cAliasAtu == "VS1"
		cNumOrcAtu := VS1->VS1_NUMORC
	Endif
EndIf

oBrwPainel:CleanExFilter()

// Fun็ใo para retornar os dados corretamente na barra
If lBarra
	FMX_MDIBar()
EndIf

OX120SETKEY("D") // Desativa Teclas de Atalho

Do Case
Case cAuxRotina == "OFIOM010"
	SetFunName("OFIOM010")

	nOpc := nAuxOpc

	dbSelectArea("VO1")
	OFIOM010(,,,, .t.)

Case cAuxRotina == "OFIOM020"
	SetFunName("OFIOM020")

	nOpc := nAuxOpc

	dbSelectArea("VO1")
	OFIOM020(, .t.)

Case cAuxRotina == "OFIOM030"
	SetFunName("OFIOM030")

	nOpc := nAuxOpc

	dbSelectArea("VO1")
	OFIOM030(, .t.)

Case cAuxRotina == "OFIOM140"
	SetFunName("OFIOM140")

	nOpc := nAuxOpc

	dbSelectArea("VO1")
	OFIOM140(.t.)

Case cAuxRotina == "OFIOM150"
	SetFunName("OFIOM150")

	nOpc := nAuxOpc

	dbSelectArea("VO1")
	OFIOM150(.t.)

Case cAuxRotina == "OFIXA100"
	SetFunName("OFIXA100")

	nOpc := nAuxOpc

	dbSelectArea("VO1")
	OFIXA100(.T.)

Case cAuxRotina == "OFIOC060"
	SetFunName("OFIOC060")

	nOpc := nAuxOpc

	dbSelectArea("VO1")
	OFIOC060(.T.)

Case cAuxRotina == "OFIOM350"
	SetFunName("OFIOM350")

	nOpc := nAuxOpc

	dbSelectArea("VSO")
	OFIOM350(.F., .T.)

Case cAuxRotina == "OFIXA011"
	SetFunName("OFIXA011")
	
	nOpc := nAuxOpc

	dbSelectArea("VS1")
	OFIXA011(,.T.)

Case cAuxRotina == "OFIXC006"
	dbSelectArea("VSO")
	OFIXC006()

Case cAuxRotina == "OFIXC001"
	SetFunName("OFIXA011")

	nOpc := nAuxOpc
	aBkpRotina := aClone(aRotina)

	dbSelectArea("VS1")

	aRotina := StaticCall(OFIXA011, MENUDEF)

	dbSelectArea("VS1")
	SetFunName("OFIXA120")

	nOpc := 2

	OFIXC001()

	aRotina := aClone(aBkpRotina)

Case cAuxRotina == "OFIOC430"
	SetFunName("OFIXA011")

	nOpc := nAuxOpc

	dbSelectArea("VS1")
	OFIOC430()

Case cAuxRotina == "M_CONSPEC"
	SetFunName("M_CONSPEC")

	nOpc := nAuxOpc
	aBkpRotina := aClone(aRotina)

	dbSelectArea("VS1")

	aRotina := StaticCall(OFIXA011, MENUDEF)

	U_M_CONSPEC()

	aRotina := aClone(aBkpRotina)

Case cAuxRotina == "OFIXC008"
	SetFunName("OFIXA011")

	nOpc := nAuxOpc
	aBkpRotina := aClone(aRotina)

	dbSelectArea("VS1")

	aRotina := StaticCall(OFIXA011, MENUDEF)

	OFIXC008()

	aRotina := aClone(aBkpRotina)

Case cAuxRotina == "OXA120NFCONS"
	OXA120NFCONS()

Case cAuxRotina == "OM020CAN"
	SetFunName("OFIOM020")

	nOpc := nAuxOpc

	dbSelectArea("VO1")
	OM020CAN()

Case cAuxRotina == "OM020HRD"
	SetFunName("OFIOM020")

	nOpc := 2

	dbSelectArea("VO1")
	OM020HRD()

Case cAuxRotina == "OM0200131_Requisitar_Pecas_de_outras_OSs"
	SetFunName("OFIOM020")

	nOpc := 2

	dbSelectArea("VO1")
	OM0200131_Requisitar_Pecas_de_outras_OSs()

Case cAuxRotina == "OM010BCO"
	aBkpRotina := aClone(aRotina)
	aRotina := StaticCall(OFIOM010, MENUDEF)

	dbSelectArea("VO1")
	OM010BCO()

	aRotina := aClone(aBkpRotina)

Case cAuxRotina == "OX120IMP"
	aBkpRotina := aClone(aRotina)
	aRotina := StaticCall(OFIOR010, MENUDEF)

	dbSelectArea("VO1")
	OX120IMP()

	aRotina := aClone(aBkpRotina)

Case cAuxRotina == "OX120IMPO"
	aBkpRotina := aClone(aRotina)
	aRotina := StaticCall(OFIXA011, MENUDEF)

	dbSelectArea("VO1")

	If ExistBlock("ORCAMTO") // Executa RdMake de Impressao do Orcamento
		ExecBlock("ORCAMTO", .f., .f., {VS1->VS1_NUMORC})
	EndIf

	aRotina := aClone(aBkpRotina)

Case cAuxRotina == "OFIOM470"
	SetFunName("OFIOM470")

	nOpc := nAuxOpc

	dbSelectArea("VO1")
	OFIOM470(.t.)

Case cAuxRotina == "OFIOC330"
	SetFunName("OFIOC330")

	nOpc := nAuxOpc

	OFIOC330(VO1->VO1_CHAINT)

Case cAuxRotina == "OFIOC330_1"
	SetFunName("OFIOC330")

	nOpc := nAuxOpc

	dbSelectArea("VV1")
	dbSetOrder(2)

	dbSeek(xFilial("VV1") + VSO->VSO_GETKEY)
	OFIOC330(VV1->VV1_CHAINT)

Otherwise
	If FindFunction(cAuxRotina)
		nOpc := nAuxOpc
		dbSelectArea(cAlias)
		If Empty(cChamadaFuncao)
			&(cAuxRotina + "()")
		Else
			&(cChamadaFuncao)
		EndIf
	EndIf

EndCase

OX120SETKEY("A", cAuxRotina, cAlias) // Ativa Teclas de Atalho

// Volta o Alias
dbSelectArea(cAliasAtu)

// Inclusใo ou Apontamento Or็amentos (VS1)
If lInclusao .Or. cAuxRotina == "OFIOC430"
	nRegAtu := Recno()
EndIf

If cAliasAtu == "VS1" .and. !Empty(cNumOrcAtu)
	cQuery := "SELECT R_E_C_N_O_ " +;
		 " FROM " + RetSQLName("VS1") + " VS1" +;
		" WHERE VS1.VS1_FILIAL = '" + cFilAnt + "'" +;
		  " AND VS1.VS1_NUMORC = '" + cNumOrcAtu + "'" +;
		  " AND VS1.D_E_L_E_T_ = ' ' "
	nRegAtu := FM_SQL(cQuery)
EndIf

oBrwPainel:SetUseFilter()
If !Empty(cXA120DefFilter)
	oBrwPainel:SetFilterDefault(cXA120DefFilter)
EndIf
oBrwPainel:ExecuteFilter(.T.)
oBrwPainel:Refresh()

If nRegAtu <> 0
	oBrwPainel:GoTo(nRegAtu, .t.)
EndIf

SetFunName(cBkpFunName)

Return

/*
===============================================================================
###############################################################################
##+----------+----------------+-------+-------------------+------+----------+##
##|Funcao    | OXA120CBOX     | Autor |  Takahashi        | Data | 28/02/13 |##
##+----------+----------------+-------+-------------------+------+----------+##
##|Descricao | Retorna string de um combo referente ao seu valor no BD      |##
##+----------+--------------------------------------------------------------+##
##|Parametro | cAuxCampo  -> Nome do Campo                                  |##
##|          | cAuxValor  -> Valor do Campo                                 |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXA120CBOX( cAuxCampo , cAuxValor )

Local cRetorno
Local nPos

nPos := aScan( aCBoxBrw , { |x| x[1] == AllTrim(cAuxCampo) + AllTrim(cAuxValor) } )
If nPos > 0
	cRetorno := aCBoxBrw[nPos,2]
Else
	cRetorno := cAuxValor
EndIf

Return cRetorno



/*
===============================================================================
###############################################################################
##+----------+----------------+-------+-------------------+------+----------+##
##|Funcao    | MenuDef        | Autor |  Takahashi        | Data | 28/02/13 |##
##+----------+----------------+-------+-------------------+------+----------+##
##|Descricao | Menu da Rotina                                               |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function MenuDef()
Return {} //"Painel de Oficina"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณFS_CNOTAFIบ Autor ณ Renato Vinicius    บ Data ณ  13/07/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Mostra as Notas Fiscais vinculadas a OS selecionada        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OXA120NFCONS()

Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cTitulo  := STR0046 // Notas Fiscais

Private aVisulNf := {} // Array com as Notas Fiscais mostradas na Tela

SF2->(DbSetOrder(1))

cQuery := "SELECT VOO.VOO_NUMNFI,VOO.VOO_SERNFI,VOO.VOO_FATPAR,VOO.VOO_LOJA,VOO.VOO_NUMOSV,VOO.VOO_TIPTEM,VOO.VOO_LIBVOO "
cQuery += "FROM "+RetSqlName("VOO")+" VOO "
cQuery += "WHERE VOO.VOO_FILIAL='"+xFilial("VOO")+"' AND VOO.VOO_NUMOSV='"+VO1->VO1_NUMOSV+"' AND VOO.VOO_NUMNFI<>' ' AND VOO.D_E_L_E_T_=' '"
TcQuery cQuery New Alias "TMPVOO"

While !TMPVOO->(Eof())
	nPosVet := aScan(aVisulNf,{|x| x[1]+x[2]+x[3]+x[4] == TMPVOO->VOO_NUMNFI+TMPVOO->VOO_SERNFI+TMPVOO->VOO_FATPAR+TMPVOO->VOO_LOJA})
	If nPosVet == 0
		SF2->(DbSeek(xFilial("SF2")+TMPVOO->VOO_NUMNFI+TMPVOO->VOO_SERNFI+TMPVOO->VOO_FATPAR+TMPVOO->VOO_LOJA))
		aAdd(aVisulNf,{TMPVOO->VOO_NUMOSV,TMPVOO->VOO_TIPTEM,TMPVOO->VOO_LIBVOO,TMPVOO->VOO_NUMNFI,;
							TMPVOO->VOO_SERNFI,SF2->F2_EMISSAO,TMPVOO->VOO_FATPAR,TMPVOO->VOO_LOJA,SF2->F2_VALBRUT})
	EndIf
	TMPVOO->(DbSkip())
EndDo

TMPVOO->(DbCloseArea())
DbSelectArea("VO1")

If Empty(aVisulNf)
	MsgInfo(STR0047)// Nใo existem notas fiscais vinculadas a essa OS
	Return
EndIf

//Monta tela com as Notas fiscais
DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL

@ 10,10 LISTBOX oLbox FIELDS HEADER OemToAnsi(STR0037),; // Numero OS
	OemToAnsi(STR0038),; // Tipo Tempo
	OemToAnsi(STR0039),; // Nro Liberacao
	OemToAnsi(STR0040),; // Nota Fiscal
	OemtoAnsi(STR0041),; // Serie
	OemToAnsi(STR0042),; // Data Emissao
	OemtoAnsi(STR0043),; // Faturar Para
	OemtoAnsi(STR0044),; // Loja
	OemToAnsi(STR0045); // Valor
	COLSIZES 40,20,40,40,20,40,30,20,40;
	SIZE 100,100 OF oDlg PIXEL ON DBLCLICK (nPos:=oLbox:nAt,FS_VISUALNF(aVisulNf[oLbox:nAt,04],aVisulNf[oLbox:nAt,05]),oLbox:Refresh(),oLbox:nAt:=nPos)
oLbox:Align := CONTROL_ALIGN_ALLCLIENT

oLbox:SetArray(aVisulNf)
oLbox:bLine := { || { aVisulNf[oLbox:nAt,01],;
	aVisulNf[oLbox:nAt,02],;
	aVisulNf[oLbox:nAt,03],;
	aVisulNf[oLbox:nAt,04],;
	aVisulNf[oLbox:nAt,05],;
	aVisulNf[oLbox:nAt,06],;
	aVisulNf[oLbox:nAt,07],;
	aVisulNf[oLbox:nAt,08],;
	Transform(aVisulNf[oLbox:nAt,09],"@E 999,999.99")}}

ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg, { || oDlg:End() }, { || oDlg:End() } )

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณFS_VISUALNบ Autor ณ Renato Vinicius    บ Data ณ  13/07/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Chama a Consulta de MATC090 (Notas Fiscais de Saida)       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VISUALNF(cNF,cSer)

Default cNf  := ""
Default cSer := ""

If !Empty(cNf)
	OC060_NF( Nil, Nil, cNF, cSer) // Chama tela de detalhes da nota
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณOX120IMP  บ Autor ณ Thiago				  บ Data ณ  12/11/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Chamada da Impressao da OS (OFIOR010)					        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OX120IMP()
Local nOpca  := 1
Local nCkImp := 1

DEFINE MSDIALOG oDlgImp TITLE STR0051 FROM  08,10 TO 15,40 OF oMainWnd

@ 005,005 RADIO oRadio VAR nCkImp 3D SIZE 80,10 PROMPT STR0052,STR0053 OF oDlgImp PIXEL

DEFINE SBUTTON FROM 40,40 TYPE 1 ACTION ( nOpca := 1, oDlgImp:End() ) ENABLE OF oDlgImp
DEFINE SBUTTON FROM 40,80 TYPE 2 ACTION ( nOpca := 0, oDlgImp:End() ) ENABLE OF oDlgImp

ACTIVATE MSDIALOG oDlgImp CENTER

if nOpca == 1
   if nCkImp == 1
		OFIOR010N()
   Else
		OFIOR010E("VO1",VO1->(RECNO()),2)
   Endif
Endif

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณOXA120FilProVei บ Autor ณ Manoel Filho บ Data ณ  19/05/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Chamada da Filtro pelo Nome do Proprietแrio                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OXA120FilPV()

Local cAuxFilter:= ""
Local cQry      := ""
Local cQAlSA1   := "SQLSA1"
Local aParamBox := {}
Local aRetFilPV := {}
Local aSA1      := {}
Local aTipFil   := {"1="+STR0060,"2="+STR0061,"3="+STR0062}
Local cTipFil   := "1" // Tipo de Filtro

AADD(aParamBox,{2,STR0063,cTipFil,aTipFil,90,"",.t.})    // Tipo de Origem
AADD(aParamBox,{1,STR0064,Space(TamSx3("A1_NOME")[1]),"@!",'',"",".T.",120,.T.}) // 3 - Descricao
If ParamBox(aParamBox,RetTitle("VO1_PROVEI"),@aRetFilPV,,,,,,,,.f.)
	//////////////////////////////////////////
	// Pesquisa pelo Nome Reduzido do Cliente        //
	//////////////////////////////////////////
	cQry := "SELECT A1_COD, A1_LOJA,  A1_NREDUZ, A1_CGC, A1_END, "
	cQry += "A1_MUN CIDADE, A1_EST UF "
	cQrY += "FROM "+RetSQLName("SA1")+" SA1 "
	cQry += " WHERE A1_FILIAL='" + xFilial("SA1") + "' "

	If aRetFilPV[1] == "1" // Por Razao Social (A1_NOME)
		 cQry += " AND (A1_NOME LIKE '"+Alltrim(aRetFilPV[2])+"%')"
	Elseif aRetFilPV[1] == "2" // por Nome Fantasia (A1_NREDUZ)
		 cQry += " AND (A1_NREDUZ LIKE '"+Alltrim(aRetFilPV[2])+"%')"
	Else
		 cQry += " AND ( (A1_NOME LIKE '"+Alltrim(aRetFilPV[2])+"%') OR (A1_NREDUZ LIKE '"+Alltrim(aRetFilPV[2])+"%') )"
	Endif
	cQry += " AND SA1.D_E_L_E_T_ = ' '"
	cQry += " ORDER BY SA1.A1_NOME"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry ), cQAlSA1, .F., .T. )
	Do While !( cQAlSA1 )->( Eof())
		Aadd(aSA1,{;
			( cQAlSA1 )->( A1_COD ),;
			( cQAlSA1 )->( A1_LOJA ),;
			AllTrim(( cQAlSA1 )->( A1_NREDUZ )),;
			Transform(( cQAlSA1 )->( A1_CGC ),IIf(Len(Alltrim(( cQAlSA1 )->( A1_CGC )))>12,"@R 99.999.999/9999-99","@R 999.999.999-99")),;
			AllTrim(( cQAlSA1 )->( A1_END )),;
			AllTrim(( cQAlSA1 )->( CIDADE )),;
			( cQAlSA1 )->( UF )})
		( cQAlSA1 )->( DbSkip() )
	EndDo
	If len(aSA1)==1
		cAuxFilter := "VO1_PROVEI == '" + aSA1[1,1] + "' .AND. VO1_LOJPRO == '" + aSA1[1,2] + "'"
	ElseIf len(aSA1)>1
		If FG_POSSA1(aSA1)
			cAuxFilter := "VO1_PROVEI == '" + SA1->A1_COD + "' .AND. VO1_LOJPRO == '" + SA1->A1_LOJA + "'"
		EndIf
	EndIf
	( cQAlSA1 )->( dbCloseArea() )
	If Empty(cAuxFilter)
		MsgInfo(STR0067, STR0068) // "Cliente nใo encontrado para o nome informado."
	EndIf
Endif

oBrwPainel:DeleteFilter( "OXA120FF11" )
If ! Empty(cAuxFilter)
	//
	oBrwPainel:AddFilter( "F11 - " + AllTrim(STR0069), ; // cFilter	Caracter	Tํtulo que serแ exibido no filtro
							cAuxFilter, ; // cExpAdvPL	Caracter	Expressใo do filtro em formato AdvPL.
							.f. , ; // lNoCheck	L๓gico	Indica que o filtro nใo poderแ ser marcado/desmarcado.	
							.t. , ; //lSelected	L๓gico	Indica que o filtro deverแ ser apresentado como marcado/desmarcado.	
							, ; // cAlias	Caracter	Indica que o filtro ้ de relacionamento entre as tabelas e a expressใo AdvPL deve ser informado obrigatoriamente com express๕es SQL.	
							.f., ; // lFilterAsk	L๓gico	Indica se o filtro pergunta as informa็๕es na execu็ใo.	
							, ; //aFilParser	Array of Record	Array contendo informa็๕es parseadas do filtro.	
							"OXA120FF11" ) //cID	Caracter	Nome do identificador do filtro
	//
EndIf
If !Empty(cXA120DefFilter)
	oBrwPainel:SetFilterDefault(cXA120DefFilter)
EndIf
oBrwPainel:ExecuteFilter(.T.)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณOX120SETKEY บ Autor ณ Manoel Filho	  บ Data ณ  19/05/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Ativa็ใo e Desativa็ใo das Teclas de Atalho                บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Parametroณ cAcao = A (Ativa)                                          บฑฑ
ฑฑบ          ณ cAcao = D (Desativa)                                       บฑฑ
ฑฑบ          ณ cAuxRotina - Rotina utilizada na hora da Chamada           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OX120SETKEY(cAcao,cAuxRotina,cAuxAlias) // Ativa Teclas de Atalho

Default cAcao      := "A"
Default cAuxRotina := ""


If cAcao == "A" // Ativa

	If cAuxAlias == "VO1"
		SetKey(VK_F11,{|| OXA120FilPV()}) // Filtro por Proprietแrio de Veiculo
	Else
		SetKey(VK_F11,Nil)
	Endif

	If cAuxRotina == "OFIOM140"
		If lLIBVOO
			SetKey(VK_F12,{||Pergunte( "OFIM140" , .T. )})
		Else
			SetKey(VK_F12,Nil)
		Endif
	ElseIf cAuxRotina == "OFIXA100"
		SetKey(VK_F12,{ || Pergunte( "OXA100" , .T. ,,,,.f.)})
	ElseIf cAuxRotina == "OFIXA011"
		SetKey(VK_F12,{ || Pergunte("OF011F12",.t.) } )
	Else
		SetKey(VK_F12,Nil)
	EndIf

	If cAuxRotina == "OFIOM350"
		SetKey(VK_F7,{|| OM350DTHRA(0) })
	Else
		SetKey(VK_F7,Nil)
	EndIf

Else // Desativa

	SetKey(VK_F7,Nil)
	SetKey(VK_F11,Nil)
	SetKey(VK_F12,Nil)

Endif

Return
