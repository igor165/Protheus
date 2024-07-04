#INCLUDE "JURA069.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE 'FWMVCDEF.CH'

Static oBrowseDown := Nil // Static para atualizar o grid inferior do browse com os saldos
Static oTmpTable   := Nil
Static aCmpAcBrw   := {"E1_NOMCLI", "E1_SALDO", "NWF_DMOE"}
Static _lUpdSE1His := .F. // Define se atualiza histórico do título RA na SE1

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA069
Controle de Adiantamentos.

@author Fabio Crespo Arruda
@since 12/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA069()
Local oFWLayer    := Nil
Local oPanelUp    := Nil
Local oPanelDown  := Nil
Local aCoors      := FwGetDialogSize( oMainWnd )
Local cLojaAuto   := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local oBrowseUp   := Nil
Local oRelation   := Nil
Local oDlg069     := Nil
Local cQrySaldo   := ""
Local cTABSALDO   := ""
Local aTemp       := {}
Local aFiltro     := {}
Local aFields     := {}
Local aOrder      := {}
Local aCmpNotBrw  := IIF(cLojaAuto == "1", {"E1_LOJA"}, Nil)
Local aTitCpoBrw  := J069TCpoBrw() // Títulos do Browse

Define MsDialog oDlg069 Title STR0007 From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] STYLE nOR( WS_VISIBLE, WS_POPUP ) Pixel // "Controle de Adiantamentos" 

oFWLayer := FWLayer():New()
oFWLayer:Init( oDlg069, .F., .T. )

// Painel Superior
oFWLayer:AddLine( 'UP', 50, .F. )
oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )
oBrowseUp := FWmBrowse():New()
oBrowseUp:SetOwner( oPanelUp )
oBrowseUp:SetDescription( STR0007 ) // "Controle de Adiantamentos"
oBrowseUp:SetAlias( "NWF" )
If FindFunction("JurBrwRev")
	Iif(cLojaAuto == "1", JurBrwRev(oBrowseUp, "NWF", {"NWF_CLOJA"}), Nil)
EndIf
oBrowseUp:SetLocate()
JurSetLeg( oBrowseUp, "NWF" )
JurSetBSize( oBrowseUp )
oBrowseUP:SetProfileID( '1' )
oBrowseUp:DisableDetails()
oBrowseUP:ForceQuitButton( .T. )
oBrowseUP:SetBeforeClose( {|| oBrowseUP:VerifyLayout(), oBrowseDown:VerifyLayout()} )
oBrowseUp:Activate()

// Painel Inferior
oFWLayer:addLine( 'DOWN', 50, .F. )
oFWLayer:AddCollumn( 'CASOS', 100, .T., 'DOWN' )
oPanelDown  := oFWLayer:GetColPanel( 'CASOS', 'DOWN' )
oBrowseDown := FWmBrowse():New()
oBrowseDown:SetOwner( oPanelDown )
oBrowseDown:SetDescription( STR0045 ) //"Saldos de Adiantamentos do Cliente"
oBrowseDown:SetProfileID( '2' )
oBrowseDown:SetMenuDef( '' )
oBrowseDown:DisableDetails()
oBrowseDown:SetUseFilter( .F. )

cQrySaldo := J069Saldo()
aTemp     := JurCriaTmp(GetNextAlias(), cQrySaldo, "SE1",,, aCmpAcBrw, aCmpNotBrw, .T.,, aTitCpoBrw)
oTmpTable := aTemp[1]
aFiltro   := aTemp[2]
aOrder    := aTemp[3]
aFields   := aTemp[4]
cTABSALDO := oTmpTable:GetAlias()

If Len(aTemp) >= 7 .And. !Empty(aTemp[7]) // Tratamento para LGPD verifica os campos que devem ser ofuscados
	oBrowseDown:SetObfuscFields(aTemp[7])
EndIf

oBrowseDown:SetAlias(cTABSALDO)
oBrowseDown:SetTemporary(.T.)
oBrowseDown:SetFields(aFields)
oBrowseDown:Activate()

oRelation := FWBrwRelation():New()
oRelation:AddRelation( oBrowseUp, oBrowseDown, { { 'E1_CLIENTE', 'NWF_CCLIAD' }, { 'E1_LOJA', 'NWF_CLOJAD' } } )
oRelation:Activate()

Activate MsDialog oDlg069 Center

oTmpTable:Delete() // Apaga a Tabela temporária

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

@author Fabio Crespo Arruda
@since 12/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina   := {}
Local aRotUser  := {}
Local lPDUserAc := Iif(FindFunction("JPDUserAc"), JPDUserAc(), .T.) // Indica se o usuário possui acesso a dados sensíveis ou pessoais (LGPD)

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA069", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA069", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA069", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA069", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA069", 0, 8, 0, NIL } ) // "Imprimir"
aAdd( aRotina, { STR0008, 'JA069PFIN()'    , 0, 6, 0, NIL } ) // "Gera Titulo no Financeiro"
aAdd( aRotina, { STR0016, "J069DlgEst()"   , 0, 6, 0, NIL } ) // "Estornar"
If lPDUserAc
	aAdd( aRotina, { STR0023, 'JA069REC()'     , 0, 6, 0, NIL } ) // "Recibo"
EndIf
aAdd( aRotina, { STR0044, 'JA069AExec()'   , 0, 6, 0, NIL } ) // "Títulos Vinculados"

//--------------------------------------------------
// Ponto de entrada - Adiciona rotinas ao aRotina 
//--------------------------------------------------
If ExistBlock("JURA069")
	aRotUser := ExecBlock("JURA069", .F., .F., {Nil, "MENUDEF", "JURA069"})
	If ValType(aRotUser) == "A"
		AEval(aRotUser, {|aX| Aadd(aRotina, aX)})
	EndIf
EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Controle de Adiantamentos.

@author Fabio Crespo Arruda
@since 12/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView     := Nil
Local oModel    := FWLoadModel( "JURA069" )
Local oStruNWF  := FWFormStruct( 2, "NWF" )
Local cLojaAuto := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

JurSetAgrp( 'NWF',, oStruNWF )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA069_VIEW", oStruNWF, "NWFMASTER" )
If cLojaAuto == "1"
	oStruNWF:RemoveField("NWF_CLOJA")
	oStruNWF:RemoveField("NWF_CLOJAD")
EndIf
oView:CreateHorizontalBox( "FORMFIELD" , 100 )
oView:SetOwnerView( "JURA069_VIEW", "FORMFIELD"  )
oView:SetDescription( STR0007 ) // "Controle de Adiantamentos"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Controle de Adiantamentos.

@author Fabio Crespo Arruda
@since 12/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= NIL
Local oStruNWF	:= FWFormStruct( 1, "NWF" )
Local oCommit   := JA069COMMIT():New()

oModel := MPFormModel():New( "JURA069", , , , /*bCancel*/ )
oModel:AddFields( "NWFMASTER", NIL , oStruNWF, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:GetModel( "NWFMASTER" ):SetDescription( STR0007 ) // "Controle de Adiantamentos"

oModel:InstallEvent("JA069COMMIT", /*cOwner*/, oCommit)

JurSetRules( oModel, 'NWFMASTER',, 'NWF' )

oModel:SetVldActivate( { | oX | JA069PREVL( oX ) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA069PFIN
Processa para a função JA069FIN

@author Bruno Ritter
@since 22/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA069PFIN(oModel)
	Processa({|| JA069FIN(oModel) })
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA069FIN
Função para incluir um titulo no contas a Receber.

@param oModel    , Modelo de dados de Adiantamento
@param lCNAB     , Indica se a chamada veio do retorno CNAB.
@param dDtGeraFin, Data de geração do contas a receber (usado via CNAB)
@param cNatFin   , Natureza do contas a receber (usado via CNAB)
@param lShowMsg  , Exibe mensagem
@param cLogErro  , Variável que será armazenado erro do ExecAuto

@author SisJur
@since 01/08/11
/*/
//-------------------------------------------------------------------
Function JA069FIN(oModel, lCNAB, dDtGeraFin, cNatFin, lShowMsg, cLogErro)
Local lRet      := .T.
Local aArea     := GetArea()
Local cPrefixo  := ""
Local cTipo     := ""
Local cParcela  := ""
Local cNatureza := ""
Local aCabItem  := {}
Local cNumTit   := ""
Local cCodNWF   := ""
Local cFil      := ""
Local cFilSE1   := ""
Local cFilSav   := ""
Local cHist     := ""
Local aValConv  := {}
Local cMoedNac  := ""
Local nTamTit   := 0
Local lCpoDtMov := .F.
Local dEmissao  := Nil
Local lCpoCotaca:= .F.
Local nCotac    := 0
Local lInfCotac := .F. //Informa Cotação

//Variaveis para Ponto de Entrada para adicionar campos ao SE1 - Alexandre 10/2010
Local aAux   := {}
Local nLoop  := 0

Default lCNAB       := .F.
Default lShowMsg    := .T.
Default dDtGeraFin  := Nil
Default cNatFin     := ""
Default cLogErro    := ""

Private lMsErroAuto := .F.

If !lShowMsg
	Private lAutoErrNoFile  := .T.
	Private lMsHelpAuto     := .T.
EndIf


If !lCNAB
	ProcRegua(0)
EndIf

cNatureza := IIF(Empty(cNatFin), AvKey(GETMV("MV_JADTNAT",, ""), "ED_CODIGO"), cNatFin) // Quando vem do CNAB a natureza vem definida e não será a do parâmetro MV_JADTNAT

SED->( DbSetOrder(1) )
If !SED->( DbSeek( xFilial("SED") + cNatureza ) )
	MsgAlert(STR0029) // "Não foi possível gerar o título de contas a receber pois a natureza informada no parâmetro MV_JADTNAT não é válida."
	lRet  := .F.
EndIf

If lRet .And. NWF->NWF_SITUAC != '1'
	MsgAlert(STR0015) // "O registro está cancelado."
	lRet  := .F.
EndIf

If lRet .And. NWF->NWF_TITGER != '2'
	MsgAlert(STR0013) //"O título já foi gerado."
	lRet  := .F.
EndIf

If lRet
	cMoedNac   := SuperGetMV( 'MV_JMOENAC',, '01' )
	lCpoDtMov  := NWF->(ColumnPos("NWF_DTMOVI")) > 0 .And. !IsBlind()
	lCpoCotaca := NWF->(ColumnPos("NWF_COTACA")) > 0

	If (lInfCotac :=  lCpoCotaca .AND.  NWF->NWF_CMOE <> cMoedNac)
		nCotac := NWF->NWF_COTACA
	EndIf
	If ValType(dDtGeraFin) == "D"
		dEmissao := dDtGeraFin // Quando vem do CNAB a data já vem definida
	Else
		dEmissao := IIF(lCpoDtMov, J069DtMov(lInfCotac, @nCotac, cMoedNac,  NWF->NWF_CMOE), dDataBase)
	EndIf
	lRet := !Empty(dEmissao)
EndIf

If lRet
	cCodNWF  := NWF->NWF_COD
	cFil     := Posicione("NS7", 1, xFilial("NS7") + NWF->NWF_CESCR, "NS7_CFILIA")
	cFilSE1  := FWxFilial("SE1",cFil)
	nTamTit  := TamSx3("NWF_TITULO")[1]
	cPrefixo := AllTrim(AvKey( GETMV("MV_JADTPRF",, ""), "E1_PREFIXO" ))
	cTipo    := GETMV("MV_JADTTP",, "RA")
	cParcela := GETMV("MV_JADTPAR",, "")

	cNumTit  := cPrefixo + cCodNWF

	If Len(cNumTit) < nTamTit
		nTam := Len(cCodNWF) + Len(AllTrim(cPrefixo))
		nTamStrZero := nTamTit - nTam
		cNumTit := cPrefixo + Replicate("0", nTamStrZero) + cCodNWF
	EndIf

	cHist    := LmpCpoHis( NWF->NWF_HIST )

	aCabItem := {}

	Aadd( aCabItem , { "E1_FILIAL",    cFilSE1,                      NIL } )
	Aadd( aCabItem , { "E1_PREFIXO",   cPrefixo,                     NIL } )
	Aadd( aCabItem , { "E1_NUM",       cNumTit,                      NIL } )
	Aadd( aCabItem , { "E1_PARCELA",   cParcela,                     NIL } )
	Aadd( aCabItem , { "E1_TIPO",      cTipo,                        NIL } )
	Aadd( aCabItem , { "E1_NATUREZ",   cNatureza,                    NIL } )
	Aadd( aCabItem , { "E1_CLIENTE",   NWF->NWF_CCLIAD,              NIL } )
	Aadd( aCabItem , { "E1_LOJA",      NWF->NWF_CLOJAD,              NIL } )
	Aadd( aCabItem , { "E1_EMISSAO",   dEmissao,                     NIL } )
	Aadd( aCabItem , { "E1_VENCTO",    dEmissao,                     NIL } )
	Aadd( aCabItem , { "E1_VENCREA",   DataValida(dEmissao, .T.),    NIL } )
	Aadd( aCabItem , { "E1_HIST",      cHist,                        NIL } )
	Aadd( aCabItem , { "E1_FLUXO",     'S',                          NIL } )
	Aadd( aCabItem , { "CBCOAUTO",     NWF->NWF_BANCO,               NIL } )
	Aadd( aCabItem , { "CAGEAUTO",     NWF->NWF_AGENCI,              NIL } )
	Aadd( aCabItem , { "CCTAAUTO",     NWF->NWF_CONTA,               NIL } )
	Aadd( aCabItem , { "E1_PORTADO",   NWF->NWF_BANCO,               NIL } )
    Aadd( aCabItem , { "E1_AGEDEP",    NWF->NWF_AGENCI,              NIL } )
    Aadd( aCabItem , { "E1_CONTA",     NWF->NWF_CONTA,               NIL } )
	Aadd( aCabItem , { "E1_ORIGEM",    'JURA069' ,                   NIL } )

	If NWF->NWF_CMOE <> cMoedNac
		If nCotac = 0 
			aValConv := JA201FConv(cMoedNac, NWF->NWF_CMOE, NWF->NWF_VALOR, "1", dEmissao)
			nCotac := aValConv[2]
		EndIf
		aAdd( aCabItem , { "E1_MOEDA",     Val(NWF->NWF_CMOE),       NIL } )
		aAdd( aCabItem,  { "E1_TXMOEDA",   nCotac,              NIL } )
	EndIf

	Aadd( aCabItem , { "E1_VALOR",     NWF->NWF_VALOR,               NIL } )

	//Ponto de Entrada para adicionar campos ao SE1 - Alexandre 10/2010
	If ExistBlock('JA069TIT')

		aAux := ExecBlock('JA069TIT', .F., .F.)
		If ValType(aAux) == 'A'

			For nLoop := 1 To Len(aAux)
				aAdd(aCabItem, aClone(aAux[nLoop]))
			Next nLoop

		EndIf

	EndIf

	cFilSav  := cFilAnt
	cFilAnt  := cFil

	If Len( aCabItem ) > 0
		BEGIN TRANSACTION
			lMSErroAuto := .F.
			MSExecAuto( {|x,y| SE1->(Fina040(x,y)) }, aCabItem, 3 )
			If lMSErroAuto
				If lShowMsg
					MostraErro()
				Else
					aEval(GetAutoGRLog(), {|l| cLogErro += l + CRLF})
				EndIf
			Else
				DbSelectArea("NWF")
				DbSetOrder(1)
				If dbSeek( xFilial("NWF") + cCodNWF )
					RecLock("NWF", .F.)
					NWF->NWF_TITGER := "1"
					NWF->NWF_TITULO := cNumTit
						NWF->NWF_SALDO  := SE1->E1_SALDO
						NWF->NWF_VALUTI := 0
						NWF->NWF_VALEST := 0
					If lCpoDtMov
						NWF->NWF_DTMOVI := dEmissao
					EndIf

					If lCpoCotaca
						NWF->NWF_COTACA := nCotac
					EndIf

					NWF->(MsUnlock())

					//Grava na fila de sincronização
					J170GRAVA("NWF", xFilial("NWF") + cCodNWF, "4")

					JA069DPR("1") // deleta o titulo provisório

					If !lCNAB
						If lShowMsg
							APMsgInfo(STR0012) //'Financeiro gerado com sucesso!'
						EndIf
						JA069ATU() // Atualiza o browse dos saldos
					EndIf

				EndIf
			EndIf
		End TRANSACTION
	EndIf
	cFilAnt := cFilSav

EndIf

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J069DTMov
Monta tela para preenchimento da data de movimentação na criação
do título de adiantamento (RA)

@param   lInfCotac - Informa Cotação
@param   nCotaca - Cotação Sugerida
@param   cMoeNac - Moeda Nacional
@param   cMoeAd - Moeda Adicantamento

@author  Jonatas Martins
@since   13/06/2019
@Obs     Ocorre somente na existência do campo NWF_DTMOVI
/*/
//-------------------------------------------------------------------
Static Function J069DTMov(lInfCotac, nCotaca, cMoeNac, cMoeAd)
	Local oLayer    := FWLayer():new()
	Local oMainColl := Nil
	Local oDlgMov   := Nil
	Local oDataMov  := Nil
	Local dDataMov  := CtoD("  /  /    ")
	Local lMoeInfo 	:= !Empty(nCotaca)
	Local nCotaSug 	:= nCotaca
	Local oCotaSug 	:= NIL
	Local dDtAnt 	:=  CtoD("  /  /    ")

	oDlgMov := FWDialogModal():New()
	oDlgMov:SetFreeArea(100, IIF(lInfCotac, 85, 50))
	oDlgMov:SetEscClose(.F.)    // NÃ£o permite fechar a tela com o ESC
	oDlgMov:SetCloseButton(.F.) // NÃ£o permite fechar a tela com o "X"
	oDlgMov:SetBackground(.T.)  // Escurece o fundo da janela
	oDlgMov:SetTitle(IIF(lInfCotac,STR0054,STR0046))   // "Info Adicionais"#"Data do Movimento"
	oDlgMov:CreateDialog()
	oDlgMov:addOkButton({|| dDataMov := oDataMov:GetValue(),;
							IIF(J069VldMov(dDataMov) .AND. (!lInfCotac .OR. J069VldCot(oCotaSug:GetValue())),;
								(IIF(lInfCotac,nCotaca:=oCotaSug:GetValue(),NIL), oDlgMov:oOwner:End()) ,;
							 	.F.)})
	oDlgMov:addCloseButton({|| dDataMov := CtoD("  /  /    "), oDlgMov:oOwner:End()})

	oLayer:init(oDlgMov:GetPanelMain(), .F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
	oLayer:AddCollumn("MainColl", 100, .F.) //Cria as colunas do Layer
	oMainColl := oLayer:GetColPanel("MainColl")
	
	oDataMov  := TJurPnlCampo():New(015, 025, 060, 022, oMainColl, STR0048, ("NWF_DTMOVI"), {|| }, {|| J069StMoe(oDataMov:GetValue(), lMoeInfo, @oCotaSug, cMoeNac, cMoeAd, dDtAnt), dDtAnt := oDataMov:GetValue() },,,,) //"Data da MovimentaÃ§Ã£o"
	dDtAnt := oDataMov:GetValue()
	If lInfCotac
		oCotaSug  := TJurPnlCampo():New(050, 025, 060, 022, oMainColl, RetTitle("NWF_COTACA"), ("NWF_COTACA"), {||  }, {|| IIF(oCotaSug:GetValue() > 0, lMoeInfo := .T., NIL )  },,,,) //"Cotação"
		oCotaSug:SetValue(nCotaSug)
	EndIf
	
	oDlgMov:Activate()

Return (dDataMov)

//-------------------------------------------------------------------
/*/{Protheus.doc} J069VldMov
Função para validar data da movimentação

@param   dDataMov, data, Data da movimentação digitada

@return  lRet, lógico, Retorna .T. se data for válida

@author  Jonatas Martins
@since   13/06/2019
/*/
//-------------------------------------------------------------------
Static Function J069VldMov(dDataMov)
	Local lRet := .F.

	If Empty(dDataMov)
		JurMsgErro(STR0047) //"A data não pode ser vazia!"
	ElseIf dDataMov > dDataBase
		JurMsgErro(STR0049) //"A data do movimento não pode ser maior que data atual!"
	Else
		lRet := .T.
	EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA069TUDOK()
Função para validar o model

@author SisJur
@since 01/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA069TUDOK ( oModel )
Local lRet      := .T.
Local aArea     := GetArea()
Local oModelNWF := oModel:GetModel("NWFMASTER")
Local cParcela  := GETMV("MV_JADTPAR")
Local cNatureza := GETMV("MV_JADTNAT")
Local nOper     := oModel:GetOperation()

If nOper == OP_INCLUIR .Or. nOper == OP_ALTERAR

	If nOper == OP_INCLUIR

		If Len(AllTrim(cParcela)) == TamSX3("E1_PARCELA")[1]

			SED->( DbSetOrder(1) )

			If ValType(cNatureza) == "U" .Or. Empty(cNatureza) .Or. !SED->( DbSeek( xFilial("SED") + AvKey(cNatureza, "ED_CODIGO") ) )
				lRet := JurMsgErro(STR0031) //"Não será possível efetuar a geração de títulos de contas a receber pois o parâmetro MV_JADTNAT está preenchido incorretamente. Operação não realizada."
			EndIf

		Else
			lRet := JurMsgErro(STR0035,, STR0036) //"Não foi possível criar o adiantamento, pois o parâmetro MV_JADTPAR está preenchido incorretamente. -- "Ajuste a parcela no parâmetro de forma que tenha o mesmo tamanho do campo de parcela do título (E1_PARCELA)."
		EndIf

	ElseIf nOper == OP_ALTERAR

		SED->( DbSetOrder(1) )

		If ValType(cNatureza) == "U" .Or. Empty(cNatureza) .Or. !SED->( DbSeek( xFilial("SED") + AvKey(cNatureza, "ED_CODIGO") ) )
			lRet := JurMsgErro(STR0031) //"Não será possível efetuar a geração de títulos de contas a receber pois o parâmetro MV_JADTNAT está preenchido incorretamente. Operação não realizada."
		EndIf

		If lRet
			lRet := JA069VldDt(oModelNWF:GetValue('NWF_VENCTO'), 1, oModel)
		EndIf

		If lRet
			lRet := JA069VldDt(oModelNWF:GetValue('NWF_DATAIN'), 2)
		EndIf

	EndIf

	If lRet
		lRet := J069VldVinPg(oModelNWF) // Verifica se o cliente pagador e o escritório estão relacionados ao cliente do adiantamento
	EndIf

	If lRet
		lRet := JurVldSA6('3') //Validação de bancos
	EndIf

EndIf

If nOper == OP_EXCLUIR
	If oModelNWF:GetValue('NWF_TITGER') == "1" .And. oModelNWF:GetValue('NWF_SITUAC') == "1"
		lRet := JurMsgErro( STR0009 ) // "Não é possível excluir este adiantamento. O título já foi gerado e está em processo de movimentação. Utilizar a operação de Estorno."
	Endif
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA069PREVL()
Função para pre validar o model

@author SisJur
@since 01/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA069PREVL ( oModel )
Local lRet     := .T.
Local aArea    := GetArea()
Local cFil     := ""
Local cFilSE1  := "" //xFilial do SE1 para o escritorio relacionado

cFil    := Posicione("NS7", 1, xFilial("NS7") + NWF->NWF_CESCR, "NS7_CFILIA")
cFilSE1 := FWxFilial("SE1", cFil)

If oModel:GetOperation() == MODEL_OPERATION_DELETE
	If NWF->NWF_TITGER == "1" .And. NWF->NWF_SITUAC == "1"
		lRet := JurMsgErro( STR0009 ) // "Não é possível excluir este adiantamento. O título já foi gerado e está em processo de movimentação. Utilizar a operação de Estorno."
	Endif
Endif

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J069VLDCP()
Função para validar campos da NWF

@author SisJuri
@since 16/09/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J069VLDCP(cCampo)
Local lRet      := .T.
Local oModel    := FWModelActive()
Local cClienAd  := ''
Local cLojaAd   := ''
Local cGrupo    := ''
Local cClien    := ''
Local cLoja     := ''
Local cCaso     := ''

Default cCampo  := StrTran( AllTrim(ReadVar()), "M->", "") //Receber campo da memória

	cClienAd  := oModel:GetValue("NWFMASTER", "NWF_CCLIAD")
	cLojaAd   := oModel:GetValue("NWFMASTER", "NWF_CLOJAD")
	cGrupo    := oModel:GetValue("NWFMASTER", "NWF_CGRPCL")
	cClien    := oModel:GetValue("NWFMASTER", "NWF_CCLIEN")
	cLoja     := oModel:GetValue("NWFMASTER", "NWF_CLOJA")
	cCaso     := oModel:GetValue("NWFMASTER", "NWF_CCASO")

	If(cCampo == "NWF_CGRPCL")
		lRet := JurVldCli(cGrupo, cClien, cLoja,,, "GRP")

	ElseIf(cCampo == "NWF_CCLIEN")
		lRet := JurVldCli(cGrupo, cClien, cLoja,,, "CLI")

	ElseIf(cCampo == "NWF_CLOJA")
		lRet := JurVldCli(cGrupo, cClien, cLoja,,, "LOJ")

	ElseIf(cCampo == "NWF_CCASO")
		If JurGetDados('NVE', 1, xFilial('NVE') + cClien + cLoja + cCaso , 'NVE_SITUAC') == '2' // Não permite caso encerrado
			lRet := JurMsgErro(STR0062,, STR0063) // "Não é possível criar adiantamento para um caso encerrado." - "Indique um caso que está em andamento."
		Else
			lRet := JurVldCli(cGrupo, cClien, cLoja, cCaso, , "CAS")
		EndIf

	ElseIf(cCampo == "NWF_CLOJAD")
		lRet := ExistCpo( "SA1", cClienAd + cLojaAd, 1 )

		If lRet
			If Empty(JurGetDados('NUH', 1, xFilial('NUH') + cClienAd+cLojaAd, 'NUH_PERFIL'))
				lRet := JurMsgErro(STR0032)//"Cadastro de cliente incompleto, verificar preenchimento dos dados complementares pelo módulo Jurídico"
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J069DlgEst()
Função para criar a Dialog de estorno do adiantamento.

@param nEstorno , Valor a ser estornado
@param lAutomato, Rotina Automatizada

@author Bruno Ritter
@since 21/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J069DlgEst(nEstorno, lAutomato)
Local aArea       := GetArea()
Local aAreaM      := M->( GetArea() )
Local aAreaSE1    := SE1->( GetArea() )
Local oLayer      := FWLayer():new()
Local oMainColl   := Nil
Local oDlg        := Nil
Local nSaldo      := 0
Local oSaldo      := Nil
Local oEstorno    := Nil
Local bOk         := {||}

Default nEstorno  := 0
Default lAutomato := .F.

	If J069EDlgAc() //Validação se pode realizar um estorno
		nSaldo := NWF->NWF_SALDO

		If !lAutomato
			DEFINE MSDIALOG oDlg TITLE STR0037 FROM 0,0 TO 150,310 PIXEL // "Estornar Adiantamento"

			oLayer:init(oDlg,.F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
			oLayer:addCollumn("MainColl",100,.F.) //Cria as colunas do Layer
			oMainColl := oLayer:GetColPanel( "MainColl" )

			// "Saldo" //
			oSaldo := TJurPnlCampo():New(010,015,060,022,oMainColl, AllTrim(RetTitle("NWF_SALDO")), ("NWF_SALDO"),{|| },{|| },,,,)
			oSaldo:SetValue(nSaldo)
			oSaldo:SetWhen({|| .F. })

			// "Estornar" //
			oEstorno := TJurPnlCampo():New(010,085,060,022,oMainColl, STR0016,("NWF_SALDO"),{|| },{|| },,,,) // "Estornar"
			oEstorno:SetValid({|| J069VDlgVl(oEstorno:GetValue(), nSaldo)})

			bOk := {||J069DlgOk(oEstorno:GetValue()), oDlg:End()}
			ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar;
					(oDlg,;
					{|| Processa(bOk) },;
					{|| oDlg:End() },,; //"Sair"
					/*aButtons*/,/*nRecno*/,/*cAlias*/, .F., .F.,.F.,.T.,.F. )
		Else
			J069DlgOk(nEstorno, lAutomato)
		EndIf
	EndIf
	
	RestArea( aAreaSE1)
	RestArea( aAreaM)
	RestArea( aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J069EDlgAc()
Função para validar se pode fazer o estorno do adiantamento

@author Bruno Ritter
@since 21/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J069EDlgAc()
Local lRet       := .T.
Local cFil       := ""
Local cFilSE1    := ""
Local cPrefixo   := PadR(SuperGetMV("MV_JADTPRF", .F., ""  ), TamSX3("E1_PREFIXO")[1])
Local cParcela   := PadR(SuperGetMV("MV_JADTPAR", .F., ""  ), TamSX3("E1_PARCELA")[1])
Local cTipo      := PadR(SuperGetMV("MV_JADTTP" , .F., "RA"), TamSX3("E1_TIPO")[1])
Local nSaldo     := 0

If NWF->NWF_TITGER != '1'
	APMsgInfo(STR0018) //"Este adiantamento não possui titulo gerado!"
	lRet := .F.
Else
	cFil     := Posicione("NS7", 1, xFilial("NS7") + NWF->NWF_CESCR, "NS7_CFILIA")
	cFilSE1  := FWxFilial("SE1", cFil)
	cPrefixo := AvKey( cPrefixo, "E1_PREFIXO" )

	SE1->( DbSetOrder(1) )
	If SE1->( DbSeek( cFilSE1 + cPrefixo + NWF->NWF_TITULO + cParcela + cTipo ) )
		nSaldo := SE1->E1_SALDO
	Else
		Alert(STR0021) //"Titulo não encontrado!"
		lRet := .F.
	EndIf
EndIf

If lRet .And. nSaldo <= 0
	APMsgInfo(STR0038) // "O adiantamento não possui saldo para ser estornado."
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J069VDlgVl
Função para validar o valor informado na dialog de estorno

@param nEstorno , Valor a ser estornado
@param lAutomato, Rotina Automatizada

@author Bruno Ritter
@since 21/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J069VDlgVl(nEstorno, nSaldo)
Local lRet        := .T.
Local aTamSaldo   := {}
Local nTamSaldo   := 0
Local nDecSaldo   := 0
Local cSaldo      := ""

	If nEstorno > nSaldo
		aTamSaldo := TamSx3("NWF_SALDO")
		nTamSaldo := aTamSaldo[1]
		nDecSaldo := aTamSaldo[2]
		cSaldo    := AllTrim(Str(nSaldo, nTamSaldo, nDecSaldo))
		lRet      := JurMsgErro(STR0039, "J069EDlgOk()", I18n(STR0040, {cSaldo}))// "O valor para estorno não pode ser maior que o Saldo." / "Informe um valor até '#1'."
	EndIf

	If lRet .And. nEstorno  <= 0
		lRet := JurMsgErro(STR0041, "J069EDlgOk()", STR0042) // "O valor deve ser maior que 0 (zero)." / "Informe um valor positivo."
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J069DlgOk()
Função para Estornar o Titulo

@param nEstorno , Valor a ser estornado
@param lAutomato, Rotina Automatizada

@author Bruno Ritter
@since 21/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J069DlgOk(nEstorno, lAutomato)
Local aTit        := {}
Local cFil        := ""
Local cNRedz      := ""
Local cFilSav     := cFilAnt
Local lEstComplt  := .F.

Default lAutomato := .F.

ProcRegua(0)
cFil := Posicione("NS7", 1, xFilial("NS7") + NWF->NWF_CESCR, "NS7_CFILIA")

// Verifica se existem baixas no contas a receber para o titulo em questão OU
// Se o estorno for igual ao valor do título
If SE1->E1_VALOR == SE1->E1_SALDO .And. nEstorno == SE1->E1_VALOR
	lEstComplt := .T. // Estorno Completo

	//É preciso inicializar as variáveis de memória para usar as funções do financeiro
	M->E1_FILIAL    := SE1->E1_FILIAL
	M->E1_PREFIXO   := SE1->E1_PREFIXO
	M->E1_NUM       := SE1->E1_NUM
	M->E1_PARCELA   := SE1->E1_PARCELA
	M->E1_TIPO      := SE1->E1_TIPO
	M->E1_CLIENTE   := SE1->E1_CLIENTE
	M->E1_LOJA      := SE1->E1_LOJA

	cNRedz := Posicione("SA1", 1, xFilial("SA1") + (SE1->E1_CLIENTE) + (SE1->E1_LOJA), "SA1->A1_NREDUZ" )
	aTit := {}
	AADD(aTit, {"E1_FILIAL"  , SE1->E1_FILIAL  , NIL})
	AADD(aTit, {"E1_PREFIXO" , SE1->E1_PREFIXO , NIL})
	AADD(aTit, {"E1_NUM"     , SE1->E1_NUM     , NIL})
	AADD(aTit, {"E1_PARCELA" , SE1->E1_PARCELA , NIL})
	AADD(aTit, {"E1_TIPO"    , SE1->E1_TIPO    , NIL})
	AADD(aTit, {"E1_CLIENTE" , SE1->E1_CLIENTE , NIL})
	AADD(aTit, {"E1_LOJA"    , SE1->E1_LOJA    , NIL})
	AADD(aTit, {"E1_NOMCLI"  , cNRedz          , NIL})
	Aadd(aTit, {"CBCOAUTO"   , SE1->E1_PORTADO , NIL } )
	Aadd(aTit, {"CAGEAUTO"   , SE1->E1_AGEDEP  , NIL } )
	Aadd(aTit, {"CCTAAUTO"   , SE1->E1_CONTA   , NIL } )

	cFilAnt := cFil   //alterando a variavel Global de filial do Protheus
	lMSErroAuto := .F.
	MSExecAuto( { | x, y | FINA040( x, y ) }, aTit, 5 )
	cFilAnt := cFilSav  // Retornando a variavel Global Protheus de filial original

Else
	lEstComplt := .F. // Estorno Parcial
	aTit := {}

	AADD(aTit , {"E1_FILIAL"    , SE1->E1_FILIAL  , NIL})
	AADD(aTit , {"E1_PREFIXO"   , SE1->E1_PREFIXO , NIL})
	AADD(aTit , {"E1_NUM"       , SE1->E1_NUM     , NIL})
	AADD(aTit , {"E1_PARCELA"   , SE1->E1_PARCELA , NIL})
	AADD(aTit , {"E1_TIPO"      , SE1->E1_TIPO    , NIL})
	AADD(aTit , {"AUTMOTBX"     , "NOR"           , NIL})
	AADD(aTit , {"AUTDTBAIXA"   , Date()          , NIL})
	AADD(aTit , {"AUTDTCREDITO" , Date()          , NIL})
	AADD(aTit , {"AUTHIST"      , STR0043         , NIL}) // "Estorno de adiantamento (JURA069)."
	AADD(aTit , {"AUTVALREC"    , nEstorno        , Nil})

	cFilAnt := cFil   //alterando a variavel Global de filial do Protheus
	lMSErroAuto := .F.
	MSExecAuto({|x,y| Fina070(x,y)},aTit,3)
	cFilAnt := cFilSav  // Retornando a variavel Global Protheus de filial original
EndIf

If lMSErroAuto
	MostraErro()
Else
	If !lAutomato
		APMsgInfo(STR0020) // "Estornado!"
	EndIf

	If lEstComplt // Estorno Completo
		//Atualiza o saldo das duplicatas em clientes, valor acumulado e saldo bancario
		FaAvalSE1( 2, "JURA069" )

		//Limpa as referencias de apuracao de impostos
		FaAvalSE1( 4, "JURA069" )
		FImpExcSFQ( "SE1", SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA )

		RecLock('NWF',.F.)
		NWF->NWF_TITGER := "2"
		NWF->NWF_TITULO := ""
		NWF->NWF_SALDO  := 0
		NWF->NWF_VALUTI := 0
		NWF->NWF_VALEST := 0

		If NWF->(ColumnPos("NWF_DTMOVI")) > 0
			NWF->NWF_DTMOVI := CtoD("  /  /  ")
		EndIf

		NWF->(MsUnLock())

		If !lAutomato .And. MsgYesNo(STR0025) //"Deseja gerar um titulo provisório para esse adiantamento?"
			JA069IPR("1") // gera novo titulo provisório
		Else
			RecLock('NWF',.F.)
			NWF->NWF_SITUAC := "2"  // Estorna, não gerando titulo provisório e cancelando o Adiantamento
			NWF->(MsUnLock())
		EndIf
	EndIf

	//Grava na fila de sincronização
	J170GRAVA("NWF", xFilial("NWF") + NWF->NWF_COD, "4")

	If __lSX8
		ConfirmSX8()
	EndIf

	JA069ATU() // Atualiza o browse dos saldos
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA069REC()
Função que irá imprimir o recibo do Adiantamento (Crystal)

@author Jorge Heitor Toledo de Oliveira
@since 25/10/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA069REC()
Local cIdioma       := Posicione("NUH", 1, xFilial("NUH") + NWF->NWF_CCLIEN + NWF->NWF_CLOJA, "NUH_CIDIO")
Local cEmpresa      := cEmpAnt
Local cEscritorio   := NWF->NWF_CESCR
Local cAdiantamento := NWF->NWF_COD
Local cParams       := cIdioma +";"+ cEscritorio +";"+ cAdiantamento +";"+ cEmpresa
Local cOptions      := '1;0;1;'
Local aTables       := {'AC8','NQ6','NQB','NU3','NWA','SA2','SUA',}
Local cModRel       := SuperGetMV('MV_JMODREL',, '1')  // TIPO DE RELATORIO 1 CRYSTAL, 2 FWMSPRINT

If FindFunction("JPDLogUser")
	JPDLogUser("JURR069") // Log LGPD Relatório de Recibo do Adiantamento
EndIf

If cModRel == '1'  // Crystal
	//Efetua chamada do relatorio
	JCallCrys('JU069', cParams, cOptions + STR0022, .T., .F., .F., aTables ) //"Recibo de Adiantamento"
Else
	// Relatorio FWMSPrinter
	If ExistBlock('JURR069')  // Chamada de função de usuário
		ExecBlock('JURR069', .F., .F.)
	Else
		JURR069()
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA069IPR()
Função para incluir um titulo provisório no contas a Receber

@Param nOpção, se for 1 - posiciona no registro fisico; 2 - posiciona no registro do model

@author Luciano Pereira dos Santos
@since 01/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA069IPR(nOpcao)
Local oModel     := Nil
Local cPrefixo   := GETMV("MV_JADTPRF",, "NWF") // prefixo
Local cTipo      := GETMV("MV_JADTTPR",, "PR")  // titulo provisório
Local cParcela   := GETMV("MV_JADTPAR")
Local cNatureza  := GETMV("MV_JADTNAT")
Local aCabItem   := {}
Local cNumTit    := ""
Local cCodNWF    := ""
Local dDtIncl    := ""
Local dDTvenc    := ""
Local cEscrit    := ""
Local cHist      := ""
Local cClient    := ""
Local cLoja      := ""
Local nVAlor     := ""
Local cMoeda     := ""
Local cBanco     := ""
Local cAgenc     := ""
Local cConta     := ""
Local cFil       := ""
Local cFilSE1    := ""
Local cFilSav    := ""
Local nTamTit    := TamSx3("NWF_TITPRV")[1]
Local nCotac    := 0
Local lCpoCotaca 	:= NWF->(ColumnPos("NWF_COTACA")) > 0

//Variaveis para Ponto de Entrada para adicionar campos ao SE1 - Alexandre 10/2010
Local aAux       := {}
Local nLoop      := 0
Local aValConv   := {}
Local cMoedNac   := SuperGetMV( 'MV_JMOENAC',, '01' )

Default nOpcao   := "1"

SED->( DbSetOrder(1) )

If ValType(cNatureza) == "U" .Or. Empty(cNatureza) .Or. !SED->( DbSeek( xFilial("SED") + AvKey(cNatureza, "ED_CODIGO") ) )
	MsgAlert(STR0030) //"Nao foi possivel gerar o titulo provisorio de contas a receber pois a natureza informada no parametro MV_JADTNAT nao e valida."
	Return
EndIf

If nOpcao == "1"    // informação do endereço fisico
	cCodNWF := NWF->NWF_COD
	dDtIncl := NWF->NWF_DATAIN
	dDTvenc := NWF->NWF_VENCTO
	cEscrit := NWF->NWF_CESCR
	cHist   := NWF->NWF_HIST
	cClient := NWF->NWF_CCLIAD
	cLoja   := NWF->NWF_CLOJAD
	nVAlor  := NWF->NWF_VALOR
	cMoeda  := NWF->NWF_CMOE
	cBanco  := NWF->NWF_BANCO
	cAgenc  := NWF->NWF_AGENCI
	cConta  := NWF->NWF_CONTA

ElseIf nOpcao == "2" // informação do model
	oModel  := FWModelActive()
	cCodNWF := FwFldGet("NWF_COD")
	dDtIncl := FwFldGet("NWF_DATAIN")
	dDTvenc := FwFldGet("NWF_VENCTO")
	cEscrit := FwFldGet("NWF_CESCR")
	cHist   := FwFldGet("NWF_HIST")
	cClient := FwFldGet("NWF_CCLIAD")
	cLoja   := FwFldGet("NWF_CLOJAD")
	nVAlor  := FwFldGet("NWF_VALOR")
	cMoeda  := FwFldGet("NWF_CMOE")
	cBanco  := FwFldGet("NWF_BANCO")
	cAgenc  := FwFldGet("NWF_AGENCI")
	cConta  := FwFldGet("NWF_CONTA")
EndIf

cHist    := LmpCpoHis( cHist )
cFil     := Posicione("NS7",1,xFilial("NS7") + cEscrit, "NS7_CFILIA")
cFilSE1  := FWxFilial("SE1", cFil)
cPrefixo := AllTrim(AvKey( cPrefixo, "E1_PREFIXO" ))

cNumTit := cPrefixo + cCodNWF
If Len(cNumTit) < nTamTit
	nTam := Len(cCodNWF) + Len(cPrefixo)
	nTamStrZero := nTamTit - nTam
	cNumTit := cPrefixo + Replicate("0", nTamStrZero) + cCodNWF
EndIf

DbSelectArea("SE1")
SE1->( DbSetOrder(1) )
If !SE1->( dbSeek( cFilSE1 + cPrefixo + cNumTit + cParcela + cTipo ) )

	Aadd( aCabItem , { "E1_FILIAL",    cFilSE1,                      NIL } )
	Aadd( aCabItem , { "E1_PREFIXO",   cPrefixo,                     NIL } )
	Aadd( aCabItem , { "E1_NUM",       cNumTit,                      NIL } )
	Aadd( aCabItem , { "E1_PARCELA",   cParcela,                     NIL } )
	Aadd( aCabItem , { "E1_TIPO",      cTipo,                        NIL } )
	Aadd( aCabItem , { "E1_NATUREZ",   cNatureza,                    NIL } )
	Aadd( aCabItem , { "E1_CLIENTE",   cClient,                      NIL } )
	Aadd( aCabItem , { "E1_LOJA",      cLoja,                        NIL } )
	Aadd( aCabItem , { "E1_EMISSAO",   dDtIncl,                      NIL } )
	Aadd( aCabItem , { "E1_VENCTO",    dDTvenc,                      NIL } )
	Aadd( aCabItem , { "E1_VENCREA",   DataValida(dDTvenc, .T. ),    NIL } )
	Aadd( aCabItem , { "E1_HIST",      cHist,                        NIL } )
	Aadd( aCabItem , { "E1_FLUXO",     'S',                          NIL } )
	Aadd( aCabItem , { "CBCOAUTO",     cBanco ,                      NIL } )
	Aadd( aCabItem , { "CAGEAUTO",     cAgenc,                       NIL } )
	Aadd( aCabItem , { "CCTAAUTO",     cConta,                       NIL } )
	Aadd( aCabItem , { "E1_ORIGEM",    'JURA069' ,                   NIL } )

	If cMoeda <> cMoedNac
		If lCpoCotaca
			nCotac := NWF->NWF_COTACA
		EndIf
		
		If nCotac == 0
			aValConv   := JA201FConv(cMoedNac, cMoeda, nVAlor, "1", dDatabase )
			nCotac := aValConv[2]
		EndIf
		
		aAdd( aCabItem , { "E1_MOEDA",     Val(cMoeda),              NIL } )
		aAdd( aCabItem,  { "E1_TXMOEDA",   nCotac,              NIL } )
	EndIf

	Aadd( aCabItem , { "E1_VALOR",     nVAlor,                       NIL } )

	//Ponto de Entrada para adicionar campos ao SE1 - Alexandre 10/2010
	If ExistBlock('JA069TIT')

		aAux := ExecBlock('JA069TIT',.F.,.F.)
		If ValType(aAux) == 'A'

			For nLoop := 1 To Len(aAux)
				aAdd(aCabItem, aClone(aAux[nLoop]))
			Next nLoop

		EndIf

	EndIf

	cFilSav := cFilAnt
	cFilAnt := cFil   //alterando a variavel Global de filial do Protheus

	If Len( aCabItem ) > 0
		BEGIN TRANSACTION
			lMSErroAuto := .F.
			MSExecAuto( {|x,y| SE1->(Fina040(x,y)) }, aCabItem, 3 )
			If lMSErroAuto
				MostraErro()

			Else
				If nOpcao == "1"    // informação do endereço fisico
					DbSelectArea("NWF")
					NWF->(DbSetOrder(1))
					If NWF->(dbSeek( xFilial("NWF") + cCodNWF ))
						RecLock("NWF", .F.)
						NWF->NWF_TITPRV := cNumTit
						NWF->NWF_SALDO  := SE1->E1_SALDO
						NWF->NWF_VALUTI := 0
						NWF->NWF_VALEST := 0
						NWF->(MsUnlock())
						//Grava na fila de sincronização
						J170GRAVA("NWF", xFilial("NWF") + cCodNWF, "4")
					EndIf
				ElseIf nOpcao == "2" // informação do model
					oModel:LoadValue( "NWFMASTER", "NWF_TITPRV", cNumTit )
				EndIf
			EndIf
		End TRANSACTION
	EndIf
	cFilAnt := cFilSav  // Retornando a variavel de filial original

Else

	If nOpcao == "1"    // informação do endereço fisico
		DbSelectArea("NWF")
		NWF->(DbSetOrder(1))
		If NWF->(dbSeek( xFilial("NWF") + cCodNWF ))
			RecLock("NWF", .F.)
			NWF->NWF_TITPRV := cNumTit
			NWF->NWF_SALDO  := SE1->E1_SALDO
			NWF->NWF_VALUTI := 0
			NWF->NWF_VALEST := 0
			NWF->(MsUnlock())
			//Grava na fila de sincronização
			J170GRAVA("NWF", xFilial("NWF") + cCodNWF, "4")
		EndIf
	ElseIf nOpcao== "2" // informação do model
		oModel:LoadValue( "NWFMASTER", "NWF_TITPRV", cNumTit )
	EndIf

	MsgAlert(STR0024) //"Já existe um título provisório para esse adiantamento"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA069APR()
Função para atualizar um titulo provisório no contas a Receber

@Param nOpção, se for 1 - posiciona no registro fisico; 2 - posiciona no registro do model

@author Luciano Pereira dos Santos
@since 02/08/11
@version 1.1 (removido processo de alteração de titulo e incluido rotina de excluir e incluir titulo)
/*/
//-------------------------------------------------------------------
Function JA069APR(nOpcao)
Local aArea    := GetArea()
Local cTitGer  := FwFldGet("NWF_TITGER")
Local cSituac  := FwFldGet("NWF_SITUAC")
Local cPrefixo := ""
Local cParcela := ""
Local cTipo    := ""
Local cNumTit  := ""
Local cEscrit  := ""
Local cFil     := ""
Local cFilSE1  := ""

If cTitGer == "2"  // não foi gerado

	If cSituac == "1"
		cEscrit  := FwFldGet("NWF_CESCR")
		cFil     := Posicione("NS7", 1, xFilial("NS7") + cEscrit, "NS7_CFILIA")
		cFilSE1  := FWxFilial("SE1", cFil)
		cPrefixo := AvKey( GETMV("MV_JADTPRF",,"NWF"), "E1_PREFIXO" )
		cParcela := GETMV("MV_JADTPAR")
		cTipo    := GETMV("MV_JADTTPR",,"PR") // titulo provisório
		cNumTit  := FwFldGet("NWF_TITPRV")

		DbSelectArea("SE1")
		SE1->( DbSetOrder(1) )
		If (SE1->( dbSeek( cFilSE1 + cPrefixo + cNumTit + cParcela + cTipo ) ))
			If JA069DPR(nOpcao) // Remove o titulo provisorio
				JA069IPR(nOpcao) // Inclue o novo titulo alterado
			EndIf
		Else
			JA069IPR(nOpcao)  // Se não existir, inclui o titulo provisório
		EndIf

		SE1->( DbCloseArea() )

	ElseIf cSituac == "2" // Se cancelar o adiantamento

		JA069DPR(nOpcao) // Remove o titulo provisorio

	EndIf
EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA069DPR()
Função para deletar um titulo provisório no contas a Receber

@Param nOpcao, se for 1 - posiciona no registro fisico; 2 - posiciona no registro do model

@author Luciano Pereira dos Santos
@since 01/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA069DPR(nOpcao)
Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaSE1 := SE1->( GetArea() )
Local aAreaM   := M->( GetArea() )
Local cPrefixo := GETMV("MV_JADTPRF",, "NWF") // prefixo
Local cTipo    := GETMV("MV_JADTTPR",, "PR")  // titulo provisório
Local cParcela := GETMV("MV_JADTPAR")
Local cNumTit  := ""
Local cCodNWF  := ""
Local aTitPrv  := {}
Local oModel   := Nil
Local cNRedz   := ""

If nOpcao == "1"     // informação do endereço fisico
	cNumTit := NWF->NWF_TITPRV
	cCodNWF := NWF->NWF_COD
	cEscrit := NWF->NWF_CESCR
ElseIf nOpcao == "2" // informação do model
	oModel  := FWModelActive()
	cNumTit := FwFldGet("NWF_TITPRV")
	cCodNWF := FwFldGet("NWF_COD")
	cEscrit := FwFldGet("NWF_CESCR")
EndIf

cFil     := Posicione("NS7", 1, xFilial("NS7") + cEscrit, "NS7_CFILIA")
cFilSE1  := FWxFilial("SE1", cFil)
cPrefixo := AvKey( cPrefixo, "E1_PREFIXO" )

DbSelectArea("SE1")
SE1->( DbSetOrder(1) )
If (SE1->( dbSeek( cFilSE1 + cPrefixo + cNumTit + cParcela + cTipo ) )) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

	cNRedz := Posicione("SA1", 1, xFilial("SA1") + (SE1->E1_CLIENTE) + (SE1->E1_LOJA), "SA1->A1_NREDUZ" )

	cFilSav := cFilAnt
	cFilAnt := cFil

	//É preciso inicializar as variáveis de memoria para usar as funções do financeiro
	M->E1_FILIAL   := SE1->E1_FILIAL
	M->E1_PREFIXO  := SE1->E1_PREFIXO
	M->E1_NUM      := SE1->E1_NUM
	M->E1_PARCELA  := SE1->E1_PARCELA
	M->E1_TIPO     := SE1->E1_TIPO
	M->E1_CLIENTE  := SE1->E1_CLIENTE
	M->E1_LOJA     := SE1->E1_LOJA

   	AADD(aTitPrv , {"E1_FILIAL"  , cFilSE1         , NIL})
	AADD(aTitPrv , {"E1_PREFIXO" , SE1->E1_PREFIXO , NIL})
	AADD(aTitPrv , {"E1_NUM"     , SE1->E1_NUM     , NIL})
	AADD(aTitPrv , {"E1_PARCELA" , SE1->E1_PARCELA , NIL})
	AADD(aTitPrv , {"E1_TIPO"    , SE1->E1_TIPO    , NIL})
	AADD(aTitPrv , {"E1_CLIENTE" , SE1->E1_CLIENTE , NIL})
	AADD(aTitPrv , {"E1_LOJA"    , SE1->E1_LOJA    , NIL})
	AADD(aTitPrv , {"E1_NOMCLI"  , cNRedz          , NIL})

	If Len( aTitPrv ) > 0
		BEGIN TRANSACTION
			lMSErroAuto := .F.
			MSExecAuto( { | x, y | FINA040( x, y ) }, aTitPrv, 5 )
			If lMSErroAuto
				MostraErro()
			Else
				DbSelectArea("NWF")
				NWF->(DbSetOrder(1))
				If NWF->(dbSeek( xFilial("NWF") + cCodNWF ))
					RecLock("NWF", .F.)
					NWF->NWF_TITPRV := " "
					NWF->(MsUnlock())
					//Grava na fila de sincronização
					J170GRAVA("NWF", xFilial("NWF") + cCodNWF, "4")
				Endif
			EndIf
		END TRANSACTION
	EndIf

	//Atualiza o saldo das duplicatas em clientes, valor acumulado e saldo bancario
	FaAvalSE1( 2, "JURA069" )

	//Limpa as referencias de apuracao de impostos
	FaAvalSE1( 4, "JURA069" )
	FImpExcSFQ( "SE1", SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA )

	cFilAnt := cFilSav

EndIf

SE1->( DbCloseArea() )

RestArea( aAreaSE1)
RestArea( aAreaM)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LmpCpoHis()
Função para remove/converte caracteres não permitidos no histórico do financeiro

@Param cCpoLmp conteudo do campo há ser tratado

@author Adaptação da função original JurLmpCpo
@since 02/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function LmpCpoHis( cCpoLmp )
Local cAcentos  := "çÇ€áéíóúÝÉÝÓÚâêîôûÂÊÎÔÛàéíóúÝÉÝÓÚäëïöüÄËÝÖÜãõÃÕŽÀÅ… „¦åÈˆ‚èÌ¡ÒÖ“”¢§ðÙ£ùÑñ%$þ÷Ý°ºª¬"
Local cAcSubst  := "cCCcaeiouAEIOUaeiouAEIOUaeiouAEIOUaeiouAEIOUaoAOAAAAaaaaaaEEeeeIiiOOooooooUuuuNnPScoiooaq"
Local nI        := 0
Local nPos      := 0

cCpoLmp := AllTrim( cCpoLmp )

// Troca Acentos
For nI := 1 To Len( cCpoLmp )
	If ( nPos := At( SubStr( cCpoLmp, nI, 1 ), cAcentos ) ) > 0
		cCpoLmp := SubStr( cCpoLmp, 1, nI - 1 ) + SubStr( cAcSubst, nPos, 1 ) +  SubStr( cCpoLmp, nI + 1 )
	EndIf
Next

Return cCpoLmp

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144DESCS
Funções para retorna a descrição dos título do caso

@Return cRet	 	Informação da descrição caso

@author Luciano Pereira dos Santos
@since 03/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA069DESC()
Local cRet     := ""
Local aArea    := GetArea()

cRet := Posicione('NVE', 1, xFilial('NVE') + NWF->NWF_CCLIEN + NWF->NWF_CLOJA + NWF->NWF_CCASO, 'NVE_TITULO')

RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J069FCasF
Filtro Caso para tabela NWF

@author Luciano Pereira dos Santos
@since 03/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function J069FCasF()
Local cRet  := "@#@#"

If GetMV('MV_JCASO1') == '1' .And. Empty(FwFldGet('NWF_CCLIEN'))
	cRet := "@#'1'=='2'@#"
Else
	cRet := "@# .T."
	If !Empty(FwFldGet('NWF_CCLIEN'))
		cRet += " .AND. NVE->NVE_CCLIEN == '" + FwFldGet('NWF_CCLIEN') + "'"
	EndIf

	If !Empty(FwFldGet('NWF_CLOJA'))
		cRet += " .AND. NVE->NVE_LCLIEN == '" + FwFldGet('NWF_CLOJA') + "'"
	EndIf

	If !Empty(FwFldGet('NWF_CGRPCL'))
		cRet += " .AND. NVE->NVE_CGRPCL == '" + FwFldGet('NWF_CGRPCL') + "'"
	EndIf
	cRet += "@#"
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA069VldDt()
Valid data de vencimento.

@param 	cDate  Data a ser validada
@param 	nOp		 1 = < / 2 = >
@param  oModel Modelo de dados Controle de Adiantamento
@Return lRet 	.T./.F.

@author Jorge Luis Branco Martins Junior
@since 31/05/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA069VldDt(cDate, nOp, oModel)
	Local lRet    := .T.
	Local cTitGer := ""

	Default oModel := FwModelActive()

	If nOp == 1
		If FwIsInCallStack("JA069FIN") // Se tiver sendo chamado pelo botão do browse (Gerar Financeiro)
			cTitGer := NWF->NWF_TITGER
		ElseIf Valtype(oModel) == "O" .And. oModel:GetId() == "JURA069"
			cTitGer := oModel:GetValue("NWFMASTER","NWF_TITGER")
		EndIf

		If cDate < dDataBase .And. cTitGer == "2"
			lRet := JurMsgErro(STR0050,,STR0027)// Data de vencimento inválida. # Data de vencimento não pode ser menor que a data base
		EndIf
	ElseIf nOp == 2
		If cDate > dDataBase
			lRet := JurMsgErro(STR0051,,STR0028)// Data de inclusão inválida. # Data de inclusão não pode ser maior que a data base
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J069WHEN
Função genérica para o WHEN do programa JURA069.PRW

@param cCampo nome do campo que chamou a função J069WHEN.

@author Julio de Paula Paz
@since 20/10/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J069WHEN(cCampo)
Local oModel    := FWModelActive()
Local oModelNWF := oModel:GetModel("NWFMASTER")
Local lRet      := .T.

Do Case
	Case cCampo $ "NWF_EXCLUS|NWF_TPADI|NWF_CGRPCL|NWF_CCLIEN|NWF_CLOJA|NWF_CCASO|NWF_HIST"
		lRet := INCLUI .Or. (oModelNWF:GetValue("NWF_VALUTI") == 0)

	Case cCampo == "NWF_SITUAC"
		lRet := !INCLUI .And.(Empty(oModelNWF:GetValue("NWF_TITULO")) .And. oModelNWF:GetValue("NWF_TITGER") == "2")

	Case cCampo $ "NWF_DATAIN|NWF_CCLIAD|NWF_CLOJAD|NWF_CMOE|NWF_CMOE|NWF_VALOR|NWF_HIST|NWF_VENCTO|NWF_BANCO|NWF_AGENCI|NWF_CONTA"
		lRet := INCLUI .Or. Empty(oModelNWF:GetValue("NWF_TITULO"))

		If lRet .And. cCampo $ "NWF_BANCO|NWF_AGENCI|NWF_CONTA"
			lRet := !Empty(oModelNWF:GetValue("NWF_CESCR"))
		EndIf

	Case cCampo == "NWF_CESCR"
		lRet := INCLUI .Or.(Empty(oModelNWF:GetValue("NWF_TITULO")) .And. Empty(oModelNWF:GetValue("NWF_TITPRV")))

	Case cCampo == "NWF_COTACA"
		lRet :=  oModelNWF:GetValue("NWF_CMOE") <> SuperGetMV('MV_JMOENAC',,'01') .And. (Empty(oModelNWF:GetValue("NWF_TITULO")) .And. oModelNWF:GetValue("NWF_TITGER") == "2")

EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J069ClxCa()
Rotina para verificar se o cliente/loja pertece ao caso.
Utilizado para condição de gatilho

@Return - lRet  .T. quando o cliente PERTENCE ao caso informado OU
                .F. quando o cliente NÃO pertence ao caso informado

@author Bruno Ritter
@since 22/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J069ClxCa()
Local lRet    := .F.
Local oModel  := FWModelActive()
Local cClien  := ""
Local cLoja   := ""
Local cCaso   := ""

cClien := oModel:GetValue("NWFMASTER", "NWF_CCLIEN")
cCaso  := oModel:GetValue("NWFMASTER", "NWF_CCASO")
cLoja  := oModel:GetValue("NWFMASTER", "NWF_CLOJA")

lRet   := JurClxCa(cClien, cLoja, cCaso)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J069TRESCR()
Validação para preencher o escritório via gatilho.

@author bruno.ritter
@since  29/05/2017
@obs    Função mantida por compatibilidade (Excluir após release @12.1.37)
/*/
//-------------------------------------------------------------------
Function J069TRESCR()
Local lRet      := .T.
Local oModel    := FWModelActive()
Local cTITULO   := oModel:GetValue("NWFMASTER", "NWF_TITULO")
Local cTITPRV   := oModel:GetValue("NWFMASTER", "NWF_TITPRV")

lRet := Empty(cTITULO) .And. Empty(cTITPRV)

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA069COMMIT
Classe interna implementando o FWModelEvent, para execução de função
durante o commit.

@author Cristina Cintra Santos
@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA069COMMIT FROM FWModelEvent
	Method New()
	Method Before()
	Method InTTS()
	Method ModelPosVld()
End Class

//--------------------------------------------------------------------------
Method New() Class JA069COMMIT
Return

//--------------------------------------------------------------------------
Method ModelPosVld(oSubModel, cModelId) Class JA069COMMIT
Local lRet := .T.
	lRet := JA069TUDOK(oSubModel:GetModel() )
Return lRet

//--------------------------------------------------------------------------
Method Before(oSubModel, cModelId, cAlias, lNewRecord) Class JA069COMMIT
	JA069CMBEF(oSubModel:GetModel())
Return

//--------------------------------------------------------------------------
Method InTTS(oSubModel, cModelId) Class JA069COMMIT
	JA069CMAFT(oSubModel:GetModel())
	JFILASINC(oSubModel:GetModel(), "NWF", "NWFMASTER", "NWF_COD") // Fila de sincronização
	J069SE1His(oSubModel:GetModel()) // Atualiza histórico do título vinculado ao adiantamento
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA069CMAFT
Funções do método InTTS

@author Luciano Pereira dos Santos
@since 01/03/12
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function JA069CMAFT( oModel )
Local aArea  := GetArea()
Local nOper  := oModel:GetOperation()

// Inclusão e alteração de título provisório para o Controle de Adiantamento
If (nOper == 3) .And. oModel:GetValue("NWFMASTER", "NWF_SITUAC") == "1"
	JA069IPR("1")
ElseIf (nOper == 4)
	JA069APR("1")
EndIf

RestArea( aArea )

Return Nil

///-------------------------------------------------------------------
/*/{Protheus.doc} JA069CMBEF
Funções do método BEFORE

@author Luciano Pereira dos Santos
@since 01/03/12
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function JA069CMBEF( oModel )
Local aArea  := GetArea()
Local nOper  := oModel:GetOperation()

// Deleção do título provisório relacionado ao Controle de Adiantamento.
If (nOper == 5)
	JA069DPR("1")
EndIf

// Variável estática para definir se atualiza histórico do título RA na SE1
_lUpdSE1His := nOper == MODEL_OPERATION_UPDATE .And. NWF->NWF_TITGER == "1" .And.;
			NWF->NWF_HIST <> oModel:GetValue("NWFMASTER", "NWF_HIST")

RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J069ValAdi
Atualiza valores de Saldo (NWF_SALDO), Valor Utilizado (NWF_VALUTI)
e Valor Estornado (NWF_VALEST) no adiantamento

@param nRecnoSE1  Recno do título da SE1 (Contas a receber)

@author Jorge Luis Branco Martins Junior
@since 15/02/18
@version 1.0
/*/
//--------------------------------------------------------------------
Function J069ValAdi(nRecnoSE1)
Local cPrefixo := PadR(SuperGetMv("MV_JADTPRF", .F., ""), TamSX3("E1_PREFIXO")[1]) // prefixo
Local cTipo    := PadR(SuperGetMv("MV_JADTTP", .F., "RA"), TamSX3("E1_TIPO")[1])   // tipo
Local aValSE5  := {}
Local nSaldo   := 0 // Saldo do título
Local nValUti  := 0 // Valor Utilizado
Local nValEst  := 0 // Valor estornado sem ser por compensação

	SE1->(dbGoTo(nRecnoSE1))

	If SE1->( ! Eof() ) .And. SE1->( ! Deleted() ) .And. SE1->E1_TIPO == cTipo .And. SE1->E1_PREFIXO == cPrefixo // Títulos tratados
		nSaldo  := SE1->E1_SALDO
		aValSE5 := J069ValSE5()
		nValUti := aValSE5[1]
		nValEst := aValSE5[2]

		J069GrvNWF(nSaldo, nValUti, nValEst)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J069ValSE5
Retorna os cálculos de Valor Utilizado (NWF_VALUTI) e
Valor Estornado (NWF_VALEST) no adiantamento com base nas baixas
efetuadas (SE5)

@param aRet     Array com os valores para preenchimento dos campos:
                NWF_VALUTI e NWF_VALEST

@author Jorge Luis Branco Martins Junior
@since 15/02/18
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function J069ValSE5()
Local aArea    := GetArea()
Local aAreaSE5 := SE5->( GetArea() )
Local nValUti  := 0 // Valor Utilizado
Local nValEst  := 0 // Valor estornado sem ser por compensação
Local nBAComp  := 0 // Baixa Compensação
Local nESComp  := 0 // Estorno Compensação
Local aRet     := {}

	SE5->(dbSetOrder(7))
	SE5->(DbGoTop())
	If SE5->(dbSeek(xFilial("SE5", SE1->E1_FILORIG) + SE1->E1_PREFIXO + SE1->E1_NUM  + ;
	                                                  SE1->E1_PARCELA + SE1->E1_TIPO + ;
	                                                  SE1->E1_CLIENTE + SE1->E1_LOJA ) )

		While !SE5->(Eof()) .And. SE5->E5_FILIAL  == SE1->E1_FILORIG .And. ;
		                          SE5->E5_PREFIXO == SE1->E1_PREFIXO .And. ;
		                          SE5->E5_NUMERO  == SE1->E1_NUM     .And. ;
		                          SE5->E5_PARCELA == SE1->E1_PARCELA .And. ;
		                          SE5->E5_TIPO    == SE1->E1_TIPO    .And. ;
		                          SE5->E5_CLIFOR  == SE1->E1_CLIENTE .And. ;
		                          SE5->E5_LOJA    == SE1->E1_LOJA

			If AllTrim(SE5->E5_RECPAG) == 'R' .And. AllTrim(SE5->E5_TIPODOC) == 'BA' .And. AllTrim(SE5->E5_MOTBX) == 'CMP'
				nBAComp += SE5->E5_VALOR
			ElseIf AllTrim(SE5->E5_RECPAG) == 'P' .And. AllTrim(SE5->E5_TIPODOC) == 'ES' .And. AllTrim(SE5->E5_MOTBX) == 'CMP'
				nESComp += SE5->E5_VALOR
			ElseIf AllTrim(SE5->E5_RECPAG) == 'P' .And. (AllTrim(SE5->E5_TIPODOC) == 'BA' .Or. AllTrim(SE5->E5_TIPODOC) == 'VL') .And. ;
			       AllTrim(SE5->E5_MOTBX) == 'NOR' .And. AllTrim(SE5->E5_SITUACA) <> 'C'
				nValEst += SE5->E5_VALOR
			EndIf

			SE5->(dbSkip())
		EndDo

		nValUti := nBAComp - nESComp

	EndIf

	aRet := {nValUti, nValEst}

RestArea( aAreaSE5 )
RestArea( aArea )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J069GrvNWF
Grava os valores de Saldo (NWF_SALDO), Valor Utilizado (NWF_VALUTI)
e Valor Estornado (NWF_VALEST) no adiantamento

@param nSaldo    Valor a ser gravado no campo NWF_SALDO
@param nValUti   Valor a ser gravado no campo NWF_VALUTI
@param nValEst   Valor a ser gravado no campo NWF_VALEST

@author Jorge Luis Branco Martins Junior
@since 15/02/18
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function J069GrvNWF(nSaldo, nValUti, nValEst)
Local aArea      := GetArea()
Local aAreaNWF   := NWF->( GetArea() )
Local cCodNWF    := ""
Local cQuery     := ""
Local cQryRes    := GetNextAlias()
Local nRecnoNWF  := 0

	cQuery := " SELECT R_E_C_N_O_ RECNO "
	cQuery +=   " FROM " + RetSqlName('NWF') + " NWF "
	cQuery +=   " WHERE NWF.NWF_FILIAL = '" + xFilial("NWF") + "' "
	cQuery +=     " AND NWF.NWF_CCLIAD = '" + SE1->E1_CLIENTE + "' "
	cQuery +=     " AND NWF.NWF_CLOJAD = '" + SE1->E1_LOJA + "' "
	cQuery +=     " AND NWF.NWF_TITULO = '" + SE1->E1_NUM + "' "
	cQuery +=     " AND NWF.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQryRes,.T.,.T.)

	If !(cQryRes)->(EOF()) .And. !Empty( (cQryRes)->RECNO )
		nRecnoNWF := (cQryRes)->RECNO
	EndIf

	(cQryRes)->( dbCloseArea() )

	If nRecnoNWF > 0
		NWF->(dbGoTo(nRecnoNWF))
		cCodNWF := NWF->NWF_COD

		RecLock("NWF", .F.)
		NWF->NWF_SALDO  := nSaldo
		NWF->NWF_VALUTI := nValUti
		NWF->NWF_VALEST := nValEst
		NWF->(MsUnLock())

		//Grava na fila de sincronização
		J170GRAVA("NWF", xFilial("NWF") + cCodNWF, "4")
	EndIf

	RestArea( aAreaNWF )
	RestArea( aArea )

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} JA069AExec
Chamada do modelo de dados do títulos de adiantamentos e compensação.

@author     Jonatas Martins
@since      19/02/2018
@version    12
/*/
//------------------------------------------------------------------------------
Function JA069AExec()
	Local aArea     := GetArea()
	Local aAreaSE1  := SE1->(GetArea())
	Local cModelo   := "JURA069A"
	Local cTitulo   := STR0044 //"Títulos Vinculados"
	Local cNumTit   := ""
	Local cPrefixo  := ""
	Local cParcela  := ""
	Local cTipo     := ""

	If NWF->NWF_TITGER == "2"
		JurMsgErro(STR0018) //"Este adiantamento não possui título gerado!"
	Else
		SE1->(DbSetOrder(1)) //E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO

		cNumTit   := NWF->NWF_TITULO
		cPrefixo  := PadR(SuperGetMv("MV_JADTPRF", .F., ""), TamSX3("E1_PREFIXO")[1])
		cParcela  := PadR(GETMV("MV_JADTPAR",, ""), TamSX3("E1_PARCELA")[1])
		cTipo     := PadR(GETMV("MV_JADTTP",, "RA"), TamSX3("E1_TIPO")[1])

		If SE1->(DbSeek(xFilial("SE1") + cPrefixo + cNumTit + cParcela + cTipo))
			FWExecView(cTitulo, cModelo, MODEL_OPERATION_VIEW) //"Visualizar"
		Else
			JurMsgErro(STR0021) //"Titulo não encontrado!"
		EndIf
	EndIf

	RestArea(aArea)
	RestArea(aAreaSE1)

Return Nil

//----------------------------------------------------------------------
/*/{Protheus.doc} J069Saldo
Query do Saldo de Adiantamento

@author Luciano Pereira dos Santos
@since 23/02/2018
@version 1.0
/*/
//----------------------------------------------------------------------
Static Function J069Saldo()
Local cPrefixo  := PadR(SuperGetMv("MV_JADTPRF", .F., ""), TamSX3("E1_PREFIXO")[1]) // prefixo
Local cTipo     := PadR(SuperGetMv("MV_JADTTP" , .F., "RA"), TamSX3("E1_TIPO")[1])  // tipo
Local cQuery    := ""

cQuery := " SELECT SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_NOMCLI, CTO.CTO_SIMB NWF_DMOE, SUM(E1_SALDO) E1_SALDO, "
cQuery += " " + JurCaseCB({"NWF_TPADI"})
cQuery += " NWF.NWF_CCLIEN, NWF.NWF_CLOJA, NWF.NWF_CCASO, NVE.NVE_TITULO "
cQuery += " FROM " + RetSqlName('NWF') + " NWF "
cQuery += " INNER JOIN " + RetSqlName('SE1') + " SE1 "
cQuery += " ON ( SE1.E1_PREFIXO = '" +cPrefixo+ "' "
cQuery +=      " AND SE1.E1_TIPO = '" +cTipo+ "' "
cQuery +=      " AND SE1.E1_NUM = NWF.NWF_TITULO "
cQuery +=      " AND SE1.E1_CLIENTE = NWF.NWF_CCLIAD "
cQuery +=      " AND SE1.E1_LOJA = NWF.NWF_CLOJAD "
cQuery +=      " AND SE1.E1_ORIGEM = 'JURA069' "
cQuery +=      " AND SE1.E1_SALDO > 0 "
cQuery +=      " AND SE1.D_E_L_E_T_ = ' ' )"
cQuery += " LEFT OUTER JOIN " + RetSqlName('NVE') + " NVE "
cQuery += " ON ( NVE.NVE_FILIAL = '" + xFilial("NVE") + "'"
cQuery +=      " AND NVE.NVE_LCLIEN = NWF.NWF_CLOJA "
cQuery +=      " AND NVE.NVE_CCLIEN = NWF.NWF_CCLIEN "
cQuery +=      " AND NVE.NVE_NUMCAS = NWF.NWF_CCASO "
cQuery +=      " AND NVE.D_E_L_E_T_ = ' ' )"
cQuery += " LEFT OUTER JOIN "+ RetSqlName("CTO") +" CTO"
cQuery += " ON (CTO.CTO_FILIAL = '" + xFilial("CTO") +"'"
cQuery +=     " AND CAST(CTO_MOEDA AS DECIMAL) = SE1.E1_MOEDA"
cQuery +=     " AND CTO.D_E_L_E_T_ = ' ')"
cQuery += " WHERE NWF.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_MOEDA, CTO.CTO_SIMB, NWF.NWF_CCLIEN, NWF.NWF_CLOJA, NWF_CCASO, NVE_TITULO, NWF_TPADI "

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JA069ATU()
Atualiza o grid inferior do browse.

@author Bruno Ritter
@since 26/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA069ATU()
Local cAliasTmp   := ""
Local cQrySaldo   := ""
Local aTitCpoBrw  := J069TCpoBrw() // Títulos do Browse

If !Empty(oBrowseDown) .And. !Empty(oTmpTable)
	cAliasTmp := oTmpTable:GetAlias()
	oTmpTable:Delete()

	cQrySaldo := J069Saldo()
	oTmpTable := JurCriaTmp(cAliasTmp, cQrySaldo, "SE1",,, aCmpAcBrw,, .T.,, aTitCpoBrw)[1]

	oBrowseDown:Refresh()
	oBrowseDown:GoTop(.T.)
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J069ClxGr()
Rotina para verificar se o cliente/loja pertence ao grupo.
Usado nos gatilhos de Grupo

@Return - lRet  .T. quando o cliente PERTENCE ao grupo informado OU
                .F. quando o cliente NÃO pertence ao grupo informado

@author Bruno Ritter
@since 17/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J069ClxGr()
Local lRet    := .F.
Local oModel  := FwModelActive()
Local cGrupo  := oModel:GetValue("NWFMASTER", "NWF_CGRPCL")
Local cClien  := oModel:GetValue("NWFMASTER", "NWF_CCLIEN")
Local cLoja   := oModel:GetValue("NWFMASTER", "NWF_CLOJA")

	lRet := JurClxGr(cClien, cLoja, cGrupo)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J069TCpoBrw
Monta array para considerar títulos de campos diferentes do SX3

@return aTitCpoBrw, array, Títulos a serem considerados no browse

@author  Jorge Martins
@since   17/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J069TCpoBrw()
	Local aTitCpoBrw := {}

	Aadd(aTitCpoBrw, {"E1_CLIENTE", AllTrim(RetTitle("NWF_CCLIAD"))}) // "Cód Cli Adi"
	Aadd(aTitCpoBrw, {"E1_LOJA"   , AllTrim(RetTitle("NWF_CLOJAD"))}) // "Cód End Adi"

Return ( aTitCpoBrw )

//-------------------------------------------------------------------
/*/{Protheus.doc} J069StMoe
Altera a cotação da Moeda ao alterar a data

@param dDataMov - Data da Movimentação do Título
@param lMoeInfo - Moeda informada no cadastro (não altera a cotação)
@param oCotaSug - Cotação Sugerida
@param cMoedNac - Moeda Nacional
@param cMoeda - Moeda  Adiantamento
@param dDtAnt - Data da Movimentação Anterior

@author  fabiana.silva
@since  23/11/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J069StMoe(dDataMov, lMoeInfo, oCotaSug, cMoedNac, cMoeda, dDtAnt)
Local nCotac := 0
	If oCotaSug <> NIL .AND. (!lMoeInfo  .AND. (dDataMov <> dDtAnt .OR. oCotaSug:GetValue() = 0))	
		nCotac := JA201FConv(cMoedNac, cMoeda, 1, "1", dDataMov)[2]
		oCotaSug:SetValue(nCotac)
	EndIf
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} J069VldCot
Rotina para validar a cotação informada
Usado nos gatilhos de Grupo

@param nCotac - Valor da cotação
@Return - lRet cotação Válida

@author  fabiana.silva
@since  23/11/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J069VldCot(nCotac)
Local lRet := .T.

If nCotac < 0
	lRet := JurMsgErro(STR0052,,STR0053)//"Cotação inválida"#"Cotação não pode ser negativa"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J069SE1His
Atualiza histórico do título RA vinculado ao adiantamento

@param  oModel, Estrutura do modelo de dados

@author Jonatas Martins
@since  02/02/2021
/*/
//-------------------------------------------------------------------
Static Function J069SE1His(oModel)
Local aArea     := {}
Local cTitulo   := ""
Local cPrefixo  := ""
Local cParcela  := ""
Local cTipo     := ""
Local cHist     := ""

	If _lUpdSE1His // Variável estática utilizada na função JA069CMBEF do método BEFORE
		aArea     := GetArea()
		cTitulo   := NWF->NWF_TITULO
		cPrefixo  := SuperGetMV("MV_JADTPRF",, "")
		cParcela  := SuperGetMV("MV_JADTPAR",, "")
		cTipo     := PadR(SuperGetMv("MV_JADTTP", .F., "RA"), TamSX3("E1_TIPO")[1])
		
		SE1->(DbSetOrder(1)) //E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
		If SE1->(DbSeek(xFilial("SE1") + cPrefixo + cTitulo + cParcela + cTipo))
			cHist := LmpCpoHis(oModel:GetValue("NWFMASTER", "NWF_HIST"))

			RecLock("SE1")
			SE1->E1_HIST := cHist
			SE1->(MsUnLock())

			J069UpdLanc() // Atualiza lançamento vinculado ao título RA
		EndIf

		RestArea(aArea)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J069UpdLanc
Atualiza lançamento vinculado ao título RA

@author Jonatas Martins
@since  02/02/2021
/*/
//-------------------------------------------------------------------
Static Function J069UpdLanc()
	Local cQuery    := ""
	Local aLancRA   := {}
	Local cHistLanc := ""
	
	cQuery := "SELECT R_E_C_N_O_ "
	cQuery +=  " FROM " + RetSqlName("OHB")
	cQuery += " WHERE OHB_CRECEB = '" + SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + "' "
	cQuery +=   " AND D_E_L_E_T_ = ' ' "
	
	aLancRA := JurSql(cQuery, "*")

	If !Empty(aLancRA) .And. Len(aLancRA[1]) > 0
		OHB->(DbGoTo(aLancRA[1][1])) // Atualiza histórico lançamento vinculado ao título RA
		cHistLanc := J241HisOHB(AllTrim(SE1->E1_HIST), "", SE1->E1_CLIENTE, SE1->E1_LOJA, STR0055, .T.) // "Recebimento Antecipado - "
		RecLock("OHB")
		OHB->OHB_HISTOR := cHistLanc
		OHB->(MsUnLock())
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J069F3CLI
Filtra Cliente/Loja pagador de Contratos, Junções e Faturas 
Adicionais pendentes que tenham vínculo com o caso do Adiantamento.

@Return lResult, Retorna o filtro conforme a consulta passada no filtro

@author Reginaldo Borges / Jorge Martins
@since  22/10/2021
@obs    Função usada na consulta padrão NWFPAG
/*/
//-------------------------------------------------------------------
Function J069F3CLI()
Local aQryFil  := J069QryFil(.F., "1") // Cliente
Local cSQL     := aQryFil[1]
Local cGroupBy := aQryFil[2]
Local cTab     := "SA1"
Local aCampos  := {{"SA1", "A1_COD"}, {"SA1", "A1_LOJA"}, {"SA1", "A1_NOME"}}
Local nResult  := 0
Local lResult  := .F.

	nResult := JurF3SXB(cTab, aCampos, "", .T., .F., "", cSQL, , , , cGroupBy)
	lResult := nResult > 0

	If lResult
		DbSelectArea(cTab)
		&(cTab)->(dbgoTo(nResult))
	EndIf

Return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} J069F3ESCR
Filtra Escritório de Contratos, Junções e Faturas 
Adicionais pendentes que tenham vínculo com o caso do Adiantamento.

@Return lResult, Retorna o filtro conforme a consulta passada no filtro

@author Reginaldo Borges / Jorge Martins
@since  22/10/2021
@obs    Função usada na consulta padrão NS7NWF
/*/
//-------------------------------------------------------------------
Function J069F3ESCR()
Local aQryFil  := J069QryFil(.F., "2") // Escritório
Local cSQL     := aQryFil[1]
Local cGroupBy := aQryFil[2]
Local cTab     := "NS7"
Local aCampos  := {{"NS7", "NS7_COD"}, {"NS7", "NS7_NOME"}}
Local nResult  := 0
Local lResult  := .F.

	nResult := JurF3SXB(cTab, aCampos, "", .T., .F., "", cSQL, , , , cGroupBy)
	lResult := nResult > 0

	If lResult
		DbSelectArea(cTab)
		&(cTab)->(dbgoTo(nResult))
	EndIf

Return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} J069VldVinPg
Valida cliente pagador e código do escritório analisando vínculo
com contrato, junção e fatura adicional.

@param oModelNWF, Modelo de dados do adiantamento

@Return lRet, Se verdadeiro o cliente pagador e o escritório são válidos

@author Reginaldo Borges / Jorge Martins
@since  22/10/2021
/*/
//-------------------------------------------------------------------
Static Function J069VldVinPg(oModelNWF)
Local lRet    := .T.
Local cSQL    := ""
Local aDados  := {}

	cSQL    := J069QryFil(.T., "1", oModelNWF)[1] // Query que valida Cliente Pagador do adiantamento
	aDados  := JurSql(cSQL, "*")

	If Empty(aDados) // Valida Cliente Pagador
		If oModelNWF:GetValue("NWF_EXCLUS") == "1"
			lRet := JurMsgErro(I18N(STR0056, {oModelNWF:GetValue("NWF_CCLIAD") + " - " + oModelNWF:GetValue("NWF_CLOJAD")}),, STR0060) // "Cliente pagador #1 inválido!" -- "Cliente pagador inexistente ou não relacionado aos contratos, junções e/ou faturas adicionais vinculados ao caso do cliente do adiantamento."
		Else
			lRet := JurMsgErro(I18N(STR0056, {oModelNWF:GetValue("NWF_CCLIAD") + " - " + oModelNWF:GetValue("NWF_CLOJAD")}),, STR0057) // "Cliente pagador #1 inválido!" -- "Cliente pagador inexistente ou não relacionado aos contratos, junções e/ou faturas adicionais do cliente do adiantamento."
		EndIf
	Else
		cSQL    := J069QryFil(.T., "2", oModelNWF)[1] // Query que valida Escritório do adiantamento
		aDados  := JurSql(cSQL, "*")
	
		If Empty(aDados)
			If oModelNWF:GetValue("NWF_EXCLUS") == "1"
				lRet := JurMsgErro(I18N(STR0058, {oModelNWF:GetValue("NWF_CESCR")}),, STR0061) // "Escritório #1 inválido!" -- "Escritório inexistente ou não relacionado aos contratos, junções e/ou faturas adicionais vinculados ao caso do cliente do adiantamento."
			Else
				lRet := JurMsgErro(I18N(STR0058, {oModelNWF:GetValue("NWF_CESCR")}),, STR0059) // "Escritório #1 inválido!" -- "Escritório inexistente ou não relacionado aos contratos, junções e/ou faturas adicionais do cliente do adiantamento."
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J069QryFil
Filtra Cliente/Loja pagador de Contratos, Junções e Faturas 
Adicionais pendentes que tenham vínculo com o caso do Adiantamento.

@param  lValid   , Se .T. chamada vem do valid do campo, se não do F3
@param  cTipo    , Informa se filtra o cliente ou escritório
                   1 - Cliente
                   2 - Escritório
@param  oModelNWF, Modelo de dados do adiantamento (usado quando lValid = .T.)

@return aRet     , aRet[1] - Query de filtro
                   aRet[2] - GroupBy separado da query em caso de F3

@author Reginaldo Borges / Jorge Martins
@since  22/10/2021
/*/
//-------------------------------------------------------------------
Static Function J069QryFil(lValid, cTipo, oModelNWF)
Local cSQL        := ""
Local cSQLPE      := ""
Local cGroupBy    := ""
Local lExclusivo  := IIf(lValid, oModelNWF:GetValue("NWF_EXCLUS") == "1", FwFldGet("NWF_EXCLUS") == "1") // GetValue usado para Valid. E FwFldGet usado para F3
Local cCpos       := IIf(cTipo == "1", "SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.R_E_C_N_O_", "NS7.NS7_COD, NS7.NS7_NOME, NS7.R_E_C_N_O_")

Default oModelNWF := Nil

	If cTipo == "1" // Cliente
		cSQL :=       " SELECT SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.R_E_C_N_O_ SA1RECNO "
		cSQL +=         " FROM " + RetSqlName("SA1") + " SA1 "
		cSQL +=        " WHERE SA1.D_E_L_E_T_ = ' ' "
	Else // Escritório
		cSQL :=       " SELECT NS7.NS7_COD, NS7.NS7_NOME, NS7.R_E_C_N_O_ NS7RECNO "
		cSQL +=         " FROM " + RetSqlName("NS7") + " NS7 "
		cSQL +=        " WHERE NS7.D_E_L_E_T_ = ' ' "
		cSQL +=          " AND NS7.NS7_ATIVO = '1' "
		If lValid // Quando for validação, faz a busca do escritório digitado nos registros
			cSQL +=      " AND NS7.NS7_COD = '" + oModelNWF:GetValue("NWF_CESCR") + "' "
		EndIf
	EndIf

	cSQL += J069SubQry(cTipo, lValid, lExclusivo, oModelNWF) // Query com filtros nos contratos, junções e faturas adicionais

	// Ponto de Entrada para complementar regras da query para adicionar clientes/escritórios no filtro/valid.
	If ExistBlock("J069QRY")
		cSQLPE := ExecBlock("J069QRY", .F., .F., {cSQL, cTipo})
		If ValType(cSQLPE) == 'C'
			cSQL += cSQLPE
		EndIf
	EndIf

	If lValid // Se for validação, o group by fica na mesma query
		cSQL += " GROUP BY " + cCpos
	Else // Em caso de F3, fica em outra variável, para que seja usado na função JurF3SXB
		cGroupBy := " GROUP BY " + cCpos
	EndIf

Return ({cSQL, cGroupBy})

//-------------------------------------------------------------------
/*/{Protheus.doc} J069SubQry
Query base de filtro dos dados de cliente ou escritório do 
Cliente pagador de Contratos, Junções e Faturas Adicionais 
pendentes que tenham vínculo com o caso do Adiantamento.

@param  cTipo     , Informa se filtra o cliente ou escritório
                    1 - Cliente
                    2 - Escritório
@param  lValid    , Se .T. chamada vem do valid do campo, se .F. vem do F3
@param  lExclusivo, Se .T. indica que é um adiantamento exclusivo
@param  oModelNWF , Modelo de dados do adiantamento (usado quando lValid = .T.)

@Return cSQL, Retorna a query para a tabela informada

@author Jorge Martins / Jacques Xavier
@since  10/06/2022
/*/
//-------------------------------------------------------------------
Static Function J069SubQry(cTipo, lValid, lExclusivo, oModelNWF)
Local cSQL      := ""
Local cCliAdt   := IIf(lValid, oModelNWF:GetValue("NWF_CCLIAD"), FwFldGet("NWF_CCLIAD")) // GetValue usado para Valid. E FwFldGet usado para F3
Local cLojaAdt  := IIf(lValid, oModelNWF:GetValue("NWF_CLOJAD"), FwFldGet("NWF_CLOJAD"))
Local cCliCaso  := IIf(lValid, oModelNWF:GetValue("NWF_CCLIEN"), FwFldGet("NWF_CCLIEN"))
Local cLojaCaso := IIf(lValid, oModelNWF:GetValue("NWF_CLOJA") , FwFldGet("NWF_CLOJA"))
Local cCaso     := IIf(lValid, oModelNWF:GetValue("NWF_CCASO") , FwFldGet("NWF_CCASO"))

	cSQL :=          " AND EXISTS( SELECT 1 " // VALIDA CONTRATO
	cSQL +=                        " FROM " + RetSqlName("NT0") + " NT0 "
	cSQL +=                       " INNER JOIN " + RetSqlName("NXP") + " NXP "
	cSQL +=                          " ON NXP.NXP_FILIAL = NT0.NT0_FILIAL "
	cSQL +=                         " AND NXP.NXP_CCONTR = NT0.NT0_COD "
	cSQL +=                       " INNER JOIN " + RetSqlName("NUT") + " NUT "
	cSQL +=                          " ON NUT.NUT_FILIAL = NT0.NT0_FILIAL "
	cSQL +=                         " AND NUT.NUT_CCONTR = NT0.NT0_COD "
	cSQL +=                       " INNER JOIN " + RetSqlName("NVE") + " NVE "
	cSQL +=                          " ON NVE.NVE_FILIAL = NUT.NUT_FILIAL "
	cSQL +=                         " AND NVE.NVE_CCLIEN = NUT.NUT_CCLIEN "
	cSQL +=                         " AND NVE.NVE_LCLIEN = NUT.NUT_CLOJA "
	cSQL +=                         " AND NVE.NVE_NUMCAS = NUT.NUT_CCASO "
	cSQL +=                       " WHERE NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
	// Sempre filtra o cliente do adiantamento quando o tipo for escritório
	// Se for cliente, só filtra no valid, já que no F3 deve mostrar todos os clientes
	If cTipo == "2" .Or. lValid
		cSQL +=                     " AND NXP.NXP_CLIPG  = '" + cCliAdt + "' "
		cSQL +=                     " AND NXP.NXP_LOJAPG = '" + cLojaAdt + "' "
	EndIf
	cSQL +=                         " AND NVE.NVE_CCLIEN = '" + cCliCaso + "' "
	cSQL +=                         " AND NVE.NVE_LCLIEN = '" + cLojaCaso  + "' "
	If lExclusivo // Quando o adiantamento for exclusivo, procura pelos contratos, junções e faturas adicionais relacionadas ao caso do adiantamento
		cSQL +=                     " AND NVE.NVE_NUMCAS = '" + cCaso  + "' "
	EndIf
	cSQL +=                         " AND NVE.NVE_SITUAC = '1' "
	cSQL +=                         " AND NT0.NT0_SIT    = '2' "
	cSQL +=                         " AND NVE.D_E_L_E_T_ = ' ' "
	cSQL +=                         " AND NUT.D_E_L_E_T_ = ' ' "
	cSQL +=                         " AND NT0.D_E_L_E_T_ = ' ' "
	cSQL +=                         " AND NXP.D_E_L_E_T_ = ' ' "
	
	If cTipo == "1" // Filtro do exists para cliente
		cSQL +=                     " AND SA1.A1_COD = NXP.NXP_CLIPG "
		cSQL +=                     " AND SA1.A1_LOJA = NXP.NXP_LOJAPG "
	Else // Filtro do exists para escritório
		cSQL +=                     " AND NT0.NT0_CESCR = NS7.NS7_COD "
	EndIf

	cSQL +=                       " UNION "

	cSQL +=                      " SELECT 1 " // VALIDA FATURA ADICIONAL
	cSQL +=                        " FROM " + RetSqlName("NVV") + " NVV "
	cSQL +=                       " INNER JOIN " + RetSqlName("NXG") + " NXG "
	cSQL +=                          " ON NXG.NXG_FILIAL = NVV.NVV_FILIAL "
	cSQL +=                         " AND NXG.NXG_CFATAD = NVV.NVV_COD "
	cSQL +=                       " INNER JOIN " + RetSqlName("NVW") + " NVW "
	cSQL +=                          " ON NVW.NVW_FILIAL = NVV.NVV_FILIAL "
	cSQL +=                         " AND NVW.NVW_CODFAD = NVV.NVV_COD "
	cSQL +=                       " INNER JOIN " + RetSqlName("NVE") + " NVE "
	cSQL +=                          " ON NVE.NVE_FILIAL = NVW.NVW_FILIAL "
	cSQL +=                         " AND NVE.NVE_CCLIEN = NVW.NVW_CCLIEN "
	cSQL +=                         " AND NVE.NVE_LCLIEN = NVW.NVW_CLOJA "
	cSQL +=                         " AND NVE.NVE_NUMCAS = NVW.NVW_CCASO "
	cSQL +=                       " WHERE NVV.NVV_FILIAL = '" + xFilial("NVV") + "' "
	// Sempre filtra o cliente do adiantamento quando o tipo for escritório
	// Se for cliente, só filtra no valid, já que no F3 deve mostrar todos os clientes
	If cTipo == "2" .Or. lValid
		cSQL +=                     " AND NXG.NXG_CLIPG  = '" + cCliAdt + "' "
		cSQL +=                     " AND NXG.NXG_LOJAPG = '" + cLojaAdt + "' "
	EndIf
	cSQL +=                         " AND NVE.NVE_CCLIEN = '" + cCliCaso + "' "
	cSQL +=                         " AND NVE.NVE_LCLIEN = '" + cLojaCaso  + "' "
	If lExclusivo // Quando o adiantamento for exclusivo, procura pelos contratos, junções e faturas adicionais relacionadas ao caso do adiantamento
		cSQL +=                     " AND NVE.NVE_NUMCAS = '" + cCaso  + "' "
	EndIf
	cSQL +=                         " AND NVE.NVE_SITUAC = '1' "
	cSQL +=                         " AND NVV.NVV_SITUAC = '1' "
	cSQL +=                         " AND NVV.D_E_L_E_T_ = ' ' "
	cSQL +=                         " AND NVW.D_E_L_E_T_ = ' ' "
	cSQL +=                         " AND NVE.D_E_L_E_T_ = ' ' "
	cSQL +=                         " AND NXG.D_E_L_E_T_ = ' ' "

	If cTipo == "1" // Filtro do exists para cliente
		cSQL +=                     " AND SA1.A1_COD = NXG.NXG_CLIPG "
		cSQL +=                     " AND SA1.A1_LOJA = NXG.NXG_LOJAPG "
	Else // Filtro do exists para escritório
		cSQL +=                     " AND NVV.NVV_CESCR = NS7.NS7_COD "
	EndIf

	cSQL +=                       " UNION "

	cSQL +=                      " SELECT 1 " // VALIDA JUNÇÃO
	cSQL +=                        " FROM " + RetSqlName("NW2") + " NW2 "
	cSQL +=                       " INNER JOIN " + RetSqlName("NXP") + " NXP "
	cSQL +=                          " ON NXP.NXP_FILIAL = NW2.NW2_FILIAL "
	cSQL +=                         " AND NXP.NXP_CJCONT = NW2.NW2_COD "
	cSQL +=                       " INNER JOIN " + RetSqlName("NW3") + " NW3 "
	cSQL +=                          " ON NW3.NW3_FILIAL = NW2.NW2_FILIAL "
	cSQL +=                         " AND NW3.NW3_CJCONT = NW2.NW2_COD "
	cSQL +=                       " INNER JOIN " + RetSqlName("NT0") + " NT0 "
	cSQL +=                          " ON NT0.NT0_FILIAL = NW3.NW3_FILIAL "
	cSQL +=                         " AND NT0.NT0_COD    = NW3.NW3_CCONTR "
	cSQL +=                       " INNER JOIN " + RetSqlName("NUT") + " NUT "
	cSQL +=                          " ON NUT.NUT_FILIAL = NT0.NT0_FILIAL "
	cSQL +=                         " AND NUT.NUT_CCONTR = NT0.NT0_COD "
	cSQL +=                       " INNER JOIN " + RetSqlName("NVE") + " NVE "
	cSQL +=                          " ON NVE.NVE_FILIAL = NUT.NUT_FILIAL "
	cSQL +=                         " AND NVE.NVE_CCLIEN = NUT.NUT_CCLIEN "
	cSQL +=                         " AND NVE.NVE_LCLIEN = NUT.NUT_CLOJA "
	cSQL +=                         " AND NVE.NVE_NUMCAS = NUT.NUT_CCASO "
	cSQL +=                       " WHERE NW2.NW2_FILIAL = '" + xFilial("NW2") + "' "
	// Sempre filtra o cliente do adiantamento quando o tipo for escritório
	// Se for cliente, só filtra no valid, já que no F3 deve mostrar todos os clientes
	If cTipo == "2" .Or. lValid
		cSQL +=                     " AND NXP.NXP_CLIPG  = '" + cCliAdt + "' "
		cSQL +=                     " AND NXP.NXP_LOJAPG = '" + cLojaAdt + "' "
	EndIf
	cSQL +=                         " AND NVE.NVE_CCLIEN = '" + cCliCaso + "' "
	cSQL +=                         " AND NVE.NVE_LCLIEN = '" + cLojaCaso  + "' "
	If lExclusivo // Quando o adiantamento for exclusivo, procura pelos contratos, junções e faturas adicionais relacionadas ao caso do adiantamento
		cSQL +=                     " AND NVE.NVE_NUMCAS = '" + cCaso  + "' "
	EndIf
	cSQL +=                         " AND NVE.NVE_SITUAC = '1' "
	cSQL +=                         " AND NT0.NT0_SIT    = '2' "
	cSQL +=                         " AND NW2.D_E_L_E_T_ = ' ' "
	cSQL +=                         " AND NW3.D_E_L_E_T_ = ' ' "
	cSQL +=                         " AND NVE.D_E_L_E_T_ = ' ' "
	cSQL +=                         " AND NUT.D_E_L_E_T_ = ' ' "
	cSQL +=                         " AND NT0.D_E_L_E_T_ = ' ' "
	cSQL +=                         " AND NXP.D_E_L_E_T_ = ' ' "
	
	If cTipo == "1" // Filtro do exists para cliente
		cSQL +=                     " AND SA1.A1_COD = NXP.NXP_CLIPG "
		cSQL +=                     " AND SA1.A1_LOJA = NXP.NXP_LOJAPG "
	Else // Filtro do exists para escritório
		cSQL +=                     " AND NW2.NW2_CESCR = NS7.NS7_COD "
	EndIf
	
	cSQL +=                    " ) "

Return cSQL