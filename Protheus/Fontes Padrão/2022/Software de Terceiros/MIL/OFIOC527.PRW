#include 'protheus.ch'
#include 'tbiconn.ch'
#include 'OFIOC527.ch'

#define STR0001 "" // reutilizar

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/08/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007230_1"

/*/{Protheus.doc} OFINJD31 "Consulta de backorders"
	Tela de consulta de backorder

	Pontos de entrada:

	Parametros:
		cOrcNum: Numero do Orçamento/Pedido que fez a Sugestão, se nulo abre janela para busca geral de Sugestão BackOrder 
		cSugBO: 1-Sugestão BackOrder / 0 - Outras Sugestões (não BackOrder)

	@author Vinicius Gati
	@since  01/10/15
/*/

Function OFIOC527(cOrcNum,cSugBO)
	Private oHlp       := DMS_ArrayHelper():New()
	Private oSqlHlp    := DMS_SqlHelper():New()
	Private oBackOrder := DMS_BackOrder():New()
	Private oUtil      := DMS_Util():New()
	Private aBckOrders := {}
	Private aItensSug  := {}
	Private aSizeAut   := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
	Private oVerm      := LoadBitmap( GetResources() , "BR_VERMELHO" )  // Nada atendido
	Private oAmar      := LoadBitmap( GetResources() , "BR_AMARELO"  )  // Parcialmente atendido
	Private oVerd      := LoadBitmap( GetResources() , "BR_VERDE"    )  // Atendido
	Private cNumOrc    := SPACE(TAMSX3('VS1_NUMORC')[1])
	Private cGrpDe     := SPACE(TAMSX3('B1_GRUPO')[1])
	Private cGrpAte    := SPACE(TAMSX3('B1_GRUPO')[1])
	Private cItemDe    := SPACE(TAMSX3('B1_COD')[1])
	Private cItemAte   := SPACE(TAMSX3('B1_COD')[1])
	Private cStatusPed := SPACE(10)
	Private dDtPedDe   := dDtPedDeP := ddatabase-10
	Private dDtPedAte  := dDtPedAteP := ddatabase
	Default cOrcNum    := ""
	Default cSugBO     := "1" // Sugestão BackOrder

	Private cAtend     := cAtendP := SPACE(100)
	Private cTipo      := cTipoP := SPACE(TAMSX3('VE6_FORPED')[1])
	Private aCbxAtend  := {STR0003 /*"Todos"*/, STR0004 /*"Aguardando"*/, STR0005 /*"Atendidos"*/, STR0006 /*"Atendidos Parc."*/, STR0007 /*"Pedido Cancelado"*/, STR0008 /*"Cancelado"*/}
	Private cGrpDeP    := cGrpDe
	Private cGrpAteP   := cGrpAte
	Private cItemDeP   := cItemDe
	Private cItemAteP  := cItemAte
	Private cGrpDeP    := cGrpDe
	Private cGrpAteP   := cGrpAte
	Private cNumP      := SPACE(TAMSX3('C7_NUM')[1])
	Private oDtPedAte, oDtPedDe, oLbBOs, oLbBoItens
	Private oGtNumOrcP, oGtGrpP, oGtGrpAteP, oGtItemP, oGtItemAteP, oCbxAtendP, oDtPedDeP, oDtPedAteP, oTipoP, oFiltraP

	If ! EMPTY(cOrcNum)
		OC527BosPed(cOrcNum,cSugBO)
	Else
		TelaP()
	EndIf
Return mil_ver()

/*/{Protheus.doc} OC527BosPed
	Cria tela com backorders(sugestão de compras pedido) do pedido do parametro

	Parametros:
		cOrcNum: Numero do Orçamento/Pedido que fez a Sugestão, se nulo abre janela para busca geral de Sugestão BackOrder 
		cSugBO: 1-Sugestão BackOrder / 0 - Outras Sugestões (não BackOrder)

	@author Vinicius Gati
	@since  01/10/15
/*/
Function OC527BosPed(cOrcNum, cSugBO)
	Local aObjects   := {} , aPosObj := {} , aInfo := {}
	Local cTitulo    := ""

	aAcoesRel := {;
	}
	
	If cSugBO == "1" //1-Sugestão BackOrder
		cTitulo := STR0002
		aItensSug := oBackOrder:GetItensBO(cFilAnt,cOrcNum,cSugBO)
	Else // 0 - Outras Sugestões (não BackOrder)
		cTitulo := STR0045
		aItensSug := oBackOrder:GetItensBO(cFilAnt,cOrcNum,cSugBO)
	Endif

	AAdd( aObjects, { 01 , 90 , .T. , .T. } ) // Filtro
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosObj := MsObjSize(aInfo, aObjects,.F.)

	DEFINE MSDIALOG oWindowI TITLE cTitulo FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	aLBHeader := {}
	@ aPosObj[1,1] + 000 , aPosObj[1,2] + 000 LISTBOX oLbBoItens ;
		FIELDS         ;
		HEADER    "", STR0009 /*"Cód.Sug."*/, STR0010 /*"Código(B1)"*/, STR0011 /*"Cód.Item"*/, STR0012 /*"Grupo"*/, STR0013 /*"Sequencial"*/, STR0014 /*"Qtd."*/, STR0015 /*"Qtd.Aten."*/, "";
		COLSIZES  35,         50,           35,         35,      30,           15,     30,          30, 10;
		SIZE aPosObj[1,4]-2 , aPosObj[1,3]-aPosObj[1,1] OF oWindowI PIXEL ;
		ON DBLCLICK FS_ItLog()
	oLbBoItens:SetArray(aItensSug)
	oLbBoItens:bLine        := FS_IValores()

	ACTIVATE MSDIALOG oWindowI ON INIT (EnchoiceBar(oWindowI, {|| lOk:=.t., oWindowI:End() }, { || oWindowI:End() },,aAcoesRel))
Return

/*/{Protheus.doc} FS_IValores

	@author       Vinicius Gati
	@since        05/10/2015
	@description  Indica os valores mostrados em cada coluna do listbox de itens

/*/
Static Function FS_IValores()

Return { || IIF(LEN(oLbBoItens:aArray) < oLbBoItens:nAt, {"", "", "", "", "", "", "", "", "", ""},;
	{ ;
		FS_ISemSts(oLbBoItens:aArray[oLbBoItens:nAt]),;
		oLbBoItens:aArray[oLbBoItens:nAt]:GetValue('VE6_SUGCOM'),;
		oLbBoItens:aArray[oLbBoItens:nAt]:GetValue('B1_COD')    ,;
		oLbBoItens:aArray[oLbBoItens:nAt]:GetValue('VE6_CODITE'),;
		oLbBoItens:aArray[oLbBoItens:nAt]:GetValue('VE6_GRUITE'),;
		oLbBoItens:aArray[oLbBoItens:nAt]:GetValue('VE6_ITEORC'),;
		oLbBoItens:aArray[oLbBoItens:nAt]:GetValue('VE6_QTDITE'),;
		oLbBoItens:aArray[oLbBoItens:nAt]:GetValue('VE6_QTDATE'),;
		"";
	})}

Static Function FS_ILegenSts(oBackOrder)
Return oVerd

/*/{Protheus.doc} OC527BosPed
	Cria tela de consulta de backorders completa

	@author Vinicius Gati
	@since  01/10/15
/*/
Static Function TelaP()
	Local aObjects   := {} , aPosObj := {} , aInfo := {}
	
	aAcoesRel      := {;
	}
	
	AAdd( aObjects, { 01 , 100 , .T. , .F. } ) // Filtro
	AAdd( aObjects, { 01 , 10 , .T. , .T. } ) // ListBox
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosObj := MsObjSize (aInfo, aObjects,.F.)

	DEFINE MSDIALOG oWindow TITLE STR0002 /*Consulta de Backorders*/ FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	//
	@ aPosObj[1,1] + 002 , aPosObj[1,2]     TO aPosObj[1,3] , aPosObj[1,4] / 2   LABEL STR0043 /*"Filtro Orçamento"    */    OF oWindow PIXEL // label bloco
    @ aPosObj[1,1] + 002 , aPosObj[1,4]/2+2 TO aPosObj[1,3] , aPosObj[1,4] - 2   LABEL STR0044 /*"Filtro Pedido Compra"*/    OF oWindow PIXEL // label blocoa
	

	@ aPosObj[1,1] + 010 , aPosObj[1,1] + 008 SAY (STR0025 /* Num Orc */) OF oWindow PIXEL
	@ aPosObj[1,1] + 020 , aPosObj[1,1] + 008 MSGET oGtNumOrc  VAR cNumOrc    PICTURE "@!"      SIZE 15,08 OF oWindow  PIXEL HASBUTTON


	@ aPosObj[1,1] + 010 , aPosObj[1,1] + 045 SAY (STR0026 /*"Grupo de:"*/) OF oWindow PIXEL
	@ aPosObj[1,1] + 020 , aPosObj[1,1] + 045 MSGET oGtGrp     VAR cGrpDe     PICTURE "@!"      SIZE 20,08 OF oWindow  PIXEL HASBUTTON


	@ aPosObj[1,1] + 010 , aPosObj[1,1] + 072 SAY (STR0027 /*"Grupo até:"*/) OF oWindow PIXEL
	@ aPosObj[1,1] + 020 , aPosObj[1,1] + 072 MSGET oGtGrpAte  VAR cGrpAte    PICTURE "@!"      SIZE 30,08 OF oWindow  PIXEL HASBUTTON


	@ aPosObj[1,1] + 035 , aPosObj[1,1] + 008 SAY (STR0028 /*"Item de:"*/) OF oWindow PIXEL
	@ aPosObj[1,1] + 045 , aPosObj[1,1] + 008 MSGET oGtItem    VAR cItemDe    PICTURE "@!"      SIZE 42,08 OF oWindow  PIXEL HASBUTTON


	@ aPosObj[1,1] + 035 , aPosObj[1,1] + 054 SAY (STR0029 /* "Item até:" */) OF oWindow PIXEL
	@ aPosObj[1,1] + 045 , aPosObj[1,1] + 054 MSGET oGtItemAte VAR cItemAte   PICTURE "@!"      SIZE 42,08 OF oWindow  PIXEL HASBUTTON


	@ aPosObj[1,1] + 035 , aPosObj[1,1] + 108 SAY (STR0030 /*"Status:"*/) OF oWindow PIXEL
	@ aPosObj[1,1] + 045 , aPosObj[1,1] + 108 MSCOMBOBOX oCbxAtend VAR cAtend ITEMS aCbxAtend VALID .T. SIZE 48,07 OF oWindow PIXEL COLOR CLR_BLUE


	@ aPosObj[1,1] + 055 , aPosObj[1,1] + 008 SAY (STR0031 /*"Data de:"*/) OF oWindow PIXEL
	@ aPosObj[1,1] + 065 , aPosObj[1,1] + 008 MSGET oDtPedDe   VAR dDtPedDe PICTURE "@D"      SIZE 42,08 OF oWindow  PIXEL HASBUTTON

	@ aPosObj[1,1] + 055 , aPosObj[1,1] + 054 SAY (STR0032 /*"Data até:"*/) OF oWindow PIXEL
	@ aPosObj[1,1] + 065 , aPosObj[1,1] + 054 MSGET oDtPedAte  VAR dDtPedAte PICTURE "@D"      SIZE 42,08 OF oWindow  PIXEL HASBUTTON


	@ aPosObj[1,1] + 055 , aPosObj[1,1] + 110 SAY (STR0033 /*"Tipo:"*/) OF oWindow PIXEL
	@ aPosObj[1,1] + 065 , aPosObj[1,1] + 110 MSGET oTipo  VAR cTipo PICTURE "@!" F3 "VEJ1" SIZE 60,08 OF oWindow PIXEL //TODO: F3 do VE6_FORPED


	@ aPosObj[1,1] + 082 , aPosObj[1,1] + 008 BUTTON oFiltra PROMPT STR0034 /*"Buscar" */ SIZE 50,10  OF oWindow PIXEL ACTION FS_Buscar()

	nDif := aPosObj[1,4]/2+4


	@ aPosObj[1,1] + 010 , aPosObj[1,1] + nDif + 008 SAY (STR0035 /*"Num. Ped."*/) OF oWindow PIXEL
	@ aPosObj[1,1] + 020 , aPosObj[1,1] + nDif + 008 MSGET oGtNumOrcP  VAR cNumP    PICTURE "@!"      SIZE 15,08 OF oWindow  PIXEL HASBUTTON

	@ aPosObj[1,1] + 010 , aPosObj[1,1] + nDif + 045 SAY (STR0026 /*"Grupo de:"*/) OF oWindow PIXEL
	@ aPosObj[1,1] + 020 , aPosObj[1,1] + nDif + 045 MSGET oGtGrpP     VAR cGrpDeP     PICTURE "@!"      SIZE 20,08 OF oWindow  PIXEL HASBUTTON

	@ aPosObj[1,1] + 010 , aPosObj[1,1] + nDif + 072 SAY (STR0027 /*"Grupo até:"*/) OF oWindow PIXEL
	@ aPosObj[1,1] + 020 , aPosObj[1,1] + nDif + 072 MSGET oGtGrpAteP  VAR cGrpAteP    PICTURE "@!"      SIZE 30,08 OF oWindow  PIXEL HASBUTTON

	@ aPosObj[1,1] + 035 , aPosObj[1,1] + nDif + 008 SAY (STR0028 /*"Item de:"*/) OF oWindow PIXEL
	@ aPosObj[1,1] + 045 , aPosObj[1,1] + nDif + 008 MSGET oGtItemP    VAR cItemDeP    PICTURE "@!"      SIZE 42,08 OF oWindow  PIXEL HASBUTTON

	@ aPosObj[1,1] + 035 , aPosObj[1,1] + nDif + 054 SAY (STR0029 /*"Item até:"*/) OF oWindow PIXEL
	@ aPosObj[1,1] + 045 , aPosObj[1,1] + nDif + 054 MSGET oGtItemAteP VAR cItemAteP   PICTURE "@!"      SIZE 42,08 OF oWindow  PIXEL HASBUTTON

	@ aPosObj[1,1] + 035 , aPosObj[1,1] + nDif + 108 SAY (STR0030 /*"Status:"*/) OF oWindow PIXEL
	@ aPosObj[1,1] + 045 , aPosObj[1,1] + nDif + 108 MSCOMBOBOX oCbxAtendP VAR cAtendP ITEMS aCbxAtend VALID .T. SIZE 48,07 OF oWindow PIXEL COLOR CLR_BLUE

	@ aPosObj[1,1] + 060 , aPosObj[1,1] + nDif + 008 SAY (STR0031 /*"Data de:"*/) OF oWindow PIXEL
	@ aPosObj[1,1] + 070 , aPosObj[1,1] + nDif + 008 MSGET oDtPedDeP   VAR dDtPedDeP PICTURE "@D"      SIZE 42,08 OF oWindow  PIXEL HASBUTTON

	@ aPosObj[1,1] + 060 , aPosObj[1,1] + nDif + 054 SAY (STR0032 /*"Data até:"*/) OF oWindow PIXEL
	@ aPosObj[1,1] + 070 , aPosObj[1,1] + nDif + 054 MSGET oDtPedAteP  VAR dDtPedAteP PICTURE "@D"      SIZE 42,08 OF oWindow  PIXEL HASBUTTON

	@ aPosObj[1,1] + 060 , aPosObj[1,1] + nDif + 110 SAY (STR0033 /*"Tipo:"*/) OF oWindow PIXEL
	@ aPosObj[1,1] + 070 , aPosObj[1,1] + nDif + 110 MSGET oTipoP  VAR cTipoP PICTURE "@!" F3 "VEJ1" SIZE 60,08 OF oWindow PIXEL //TODO: F3 do VE6_FORPED

	@ aPosObj[1,1] + 082 , aPosObj[1,1] + nDif + 008 BUTTON oFiltraP PROMPT STR0034 /* "Buscar" */  SIZE 50,10  OF oWindow PIXEL ACTION FS_PedBuscar()

	aLBHeader := {}
	@ aPosObj[2,1] + 000 , aPosObj[2,2] + 000 LISTBOX oLbBOs ;
		FIELDS         ;
		HEADER    "", STR0016 /*"Pior Status"*/, STR0017 /*"Num. Ped."*/, STR0024/*"Nro. Orç."*/,STR0018 /*"Data Ped."*/, STR0019 /*"Data/Horas Sug. Compra"*/, "";
		COLSIZES  "",                        50,                      50,                     50,                     50,                                   70, 20;
		SIZE aPosObj[2,4]-2,aPosObj[2,3]-aPosObj[2,1] OF oWindow PIXEL ;
		ON DBLCLICK FS_DblClick()
	oLbBOs:SetArray(aBckOrders)
	oLbBOs:bLine        := FS_Valores()
	oLbBOs:bHeaderClick := FS_HeaderClick()
	
	ACTIVATE MSDIALOG oWindow ON INIT (EnchoiceBar(oWindow, {|| lOk:=.t., oWindow:End() }, { || oWindow:End() },,aAcoesRel))
Return

/*/{Protheus.doc} FS_Valoresa

	@author       Vinicius Gati
	@since        05/10/2015
	@description  Indica os valores mostrados em cada coluna do listbox

/*/
Static Function FS_Valores()
Return { || IIF(LEN(oLbBOs:aArray) < oLbBOs:nAt, {oVerm, "","","","","",""},;
	{ ;
		FS_SemSts( oLbBOs:aArray[oLbBOs:nAt]:GetValue('STATUS', "") ),;
		FS_SemSts( oLbBOs:aArray[oLbBOs:nAt]:GetValue('STATUS', ""), .T. ),;
		oLbBOs:aArray[oLbBOs:nAt]:GetValue('C7_NUM', ""),;
		oLbBOs:aArray[oLbBOs:nAt]:GetValue('VS1_NUMORC'),;
		DTOC(STOD(oLbBOs:aArray[oLbBOs:nAt]:GetValue('VS1_DATORC'))),;
		DTOC(STOD(oLbBOs:aArray[oLbBOs:nAt]:GetValue('VE6_DATREG'))) + " - " + oUtil:HorToStr(oLbBOs:aArray[oLbBOs:nAt]:GetValue('VE6_HORREG')),;
		"";
	})}

/*/{Protheus.doc} FS_HeaderClick

	@author       Vinicius Gati
	@since        05/10/2015
	@description  Evento header click do grid

/*/
Static Function FS_HeaderClick()
Return { |oObj,nCol| IIf( nCol == 1, FS_MetasLeg(), Nil) }

/*/{Protheus.doc} FS_MetasLeg

	@author       Vinicius Gati
	@since        05/10/2015
	@description  Mostra a legenda dos status dos movimentos de estoque

/*/
Static Function FS_MetasLeg()
	Local aLegenda := {;
		{oVerd  , STR0020 /* "Ok" */                 },;
		{oVerm  , STR0021 /* "Cancelado/Problema" */ },;
		{oAmar  , STR0022 /* "Aguardando" */         } ;
	}

	BrwLegenda( STR0023 /*"Legenda"*/, STR0023, aLegenda ) // Legenda
Return

/*/{Protheus.doc} FS_DblClick

	@author       Vinicius Gati
	@since        05/10/2015
	@description  Clique duplo no listbox

/*/
Static Function FS_DblClick()
	If LEN(oLbBOs:aArray) >= oLbBOs:nAt
	 	OC527BosPed( oLbBOs:aArray[oLbBOs:nAt]:GetValue('VS1_NUMORC') )
	EndIf
Return .T.

/*/{Protheus.doc} FS_SemSts

	@author       Vinicius Gati
	@since        05/10/2015
	@description  Retorna semafaro ou descrição do status

/*/
Static Function FS_SemSts(cStatus, lDes)
	Default lDes := .F.
	DO CASE
		CASE cStatus $ "AGUARDANDO"
			return IIF(ldes, "AGUARDANDO", oAmar)
		CASE cStatus $ "PARCIAL"
			return IIF(ldes, "PARCIAL", oAmar)
		CASE cStatus $ "ATENDIDO"
			return IIF(ldes, "ATENDIDO", oVerd)
		CASE cStatus $ "CANCELADO"
			return IIF(ldes, "CANCELADO", oVerm)
	End Case
Return

/*/{Protheus.doc} FS_ISemSts

	@author       Vinicius Gati
	@since        05/10/2015
	@description  Clique duplo no listbox

/*/
Static Function FS_ISemSts(oItData, lDes)
	Local oBO := DMS_BackOrder():New()
	Default lDes := .F.

	If !Empty(oItData:GetValue('_DELETED'))
		return IIF(ldes, "CANCELADO", oVerm)
	ElseIf oBO:InStarvation(oItData) .AND. oItData:GetValue('VE6_QTDATE') > 0
		return IIF(lDes, "CANCELADO", oVerm)
	ElseIf oItData:GetValue('VE6_QTDATE') >= oItData:GetValue('VE6_QTDITE')
		return IIF(ldes, "ATENDIDO", oVerd)
	ElseIf oItData:GetValue('VE6_QTDATE') == 0
		return IIF(ldes, "AGUARDANDO", oAmar)
	ElseIf oItData:GetValue('VE6_QTDATE') > 0 .AND. oItData:GetValue('VE6_QTDATE') < oItData:GetValue('VE6_QTDITE')
		return IIF(ldes, "PARCIAL", oAmar)
	EndIf
Return IIF(ldes, "CANCELADO", oVerm)

/*/{Protheus.doc} FS_Buscar

	@author       Vinicius Gati
	@since        05/10/2015
	@description  Busca os pedidos pendentes de sugestão de compra

/*/
Static Function FS_Buscar()
	Local aBOs := oBackOrder:QueryAll(cFilAnt, {;
		{ 'VE6_GRUITE_DE'  , cGrpDe            },;
		{ 'VE6_GRUITE_ATE' , cGrpAte           },;
		{ 'VE6_CODITE_DE'  , cItemDe           },;
		{ 'VE6_CODITE_ATE' , cItemAte          },;
		{ 'VS1_DATORC_DE'  , cGrpDe            },;
		{ 'VS1_DATORC_ATE' , cGrpAte           },;
		{ 'VS1_NUMORC'     , cNumOrc           },;
		{ 'STATUS'         , FS_FCVSTS(cAtend) } ;
	})
	oLbBOs:SetArray(aBOs)
	oLbBOs:bLine := FS_Valores()
	oLbBOs:Refresh()
Return .T.


/*/{Protheus.doc} FS_BuscarP

	@author       Vinicius Gati
	@since        18/11/2015
	@description  Busca os pedidos pendentes de sugestão de compra

/*/
Static Function FS_PedBuscar()
	Local aBOs := oBackOrder:QueryAllP(cFilAnt, {;
		{ 'VE6_GRUITE_DE'  , cGrpDeP            },;
		{ 'VE6_GRUITE_ATE' , cGrpAteP           },;
		{ 'VE6_CODITE_DE'  , cItemDeP           },;
		{ 'VE6_CODITE_ATE' , cItemAteP          },;
		{ 'VE6_DATREG_DE'  , cGrpDeP            },;
		{ 'VE6_DATREG_ATE' , cGrpAteP           },;
		{ 'C7_NUM'         , cNumP              },;
		{ 'STATUS'         , FS_FCVSTS(cAtendP) } ;
	})
	oLbBOs:SetArray(aBOs)
	oLbBOs:bLine := FS_Valores()
	oLbBOs:Refresh()
Return .T.

/*/{Protheus.doc} FS_ItLog

	@author       Vinicius Gati
	@since        18/11/2015
	@description  Busca os pedidos pendentes de sugestão de compra

/*/
Static Function FS_ItLog()
	Local cLog    := ""
	Local cQuery  := ""
	Local cAl1    := getnextAlias()
	Local oItem   := oLbBoItens:aArray[oLbBoItens:nAt]
	Local cFilBck := cFilAnt
	cFilAnt := oItem:GetValue('VE6_FILIAL')

	cQuery := " SELECT VQL_DADOS FROM " + oSqlHlp:NoLock('VQL') + " WHERE VQL_AGROUP = 'BO_DELETED' "
	cQuery += "    AND VQL_TIPO = '" + oItem:GetValue('VS1_NUMORC') + "' "
	cQuery += "    AND VQL_FILORI = '"+xFilial('VS1')+"' "
	cQuery += "    AND D_E_L_E_T_ = ' ' " 
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAl1, .F., .T. )

	(cAl1)->(DbGoTop())
	While !(cAl1)->(EOF())
		If Empty(cLog)
			cLog := STR0042 /*"Dados dos cancelamentos:"*/ + chr(10) + chr(13)
		EndIf
		
		oJsonParser := DMS_JsonParse():New( (cAl1)->(VQL_DADOS) )
		oJsonData   := oJsonParser:ParseToObj()
		
		cLog += "=> " + STR0038 /*"Item:"*/ + oJsonData:GetValue('item')
		cLog += STR0039 /*" Sequencial: "*/ + oJsonData:GetValue('seq') + chr(10) + chr(13)
		cLog += STR0040 /*" Usuário:    "*/ + FM_SQL("SELECT VAI_NOMTEC FROM " + oSqlHlp:NoLock('VAI') + " WHERE VAI_CODUSR = '"+oJsonData:GetValue('user')+"' AND D_E_L_E_T_ = ' ' ") + chr(10) + chr(13)
		cLog += STR0041 /*" Motivo:     "*/ + FM_SQL("SELECT VS0_DESMOT FROM " + oSqlHlp:NoLock('VS0') + " WHERE VS0_CODMOT = '"+oJsonData:GetValue('motivo')+"' AND D_E_L_E_T_ = ' ' " )
		
		cLog += chr(10) + chr(13)

		(cAl1)->(DbSkip())
	End
	(cAl1)->(dbCloseArea())

	If !Empty(cLog)
		
		AVISO(STR0036 /*"Log de cancelamento de sugestão"*/, cLog, { "OK" }, 3)
	Else
		Alert(STR0037 /*"Não há itens cancelados neste orçamento."*/)
	End

	cFilAnt := cFilBck
Return

Static Function FS_FCVSTS(cStsSelec)
	If     cStsSelec == STR0003 /*"Todos"*/
		return "TODOS"
	ElseIf cStsSelec == STR0004 /*"Aguardando"*/
		return "AGUARDANDO"
	ElseIf cStsSelec == STR0005 /*"Atendidos"*/
		Return "ATENDIDO"
	ElseIf cStsSelec == STR0006 /*"Atendidos Parc."*/
		Return "PARCIAL"
	ElseIf cStsSelec == STR0007 /*"Pedido Cancelado"*/
		Return "CANCELADO"
	ElseIf cStsSelec == STR0008 /*"Cancelado"*/
		Return "CANCELADO"
	EndIf
Return "TODOS"
