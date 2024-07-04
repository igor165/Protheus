#Include "jura203.ch"
#Include "fwmbrowse.ch"
#Include "fwmvcdef.ch"
#Include "PROTHEUS.CH"
#Include "FWEVENTVIEWCONSTS.CH"

Static LOG        := .F.
Static _aFilaFx   := {}  // Controla a atualização da fila em faturas de Fixo de multiplos pagadores.
Static _lAdtPE    := .F. // Define se utiliza apenas adiantamentos informados via ponto de entrada
Static _aAdtAuto  := {}  // Armazena adiantamentos utilizados automaticamente
Static _lTelaAuto := .F. // Controla se a tela de adiantamentos utilizados automaticamente será exibida
Static _cContMDia := ""  // Variável para controle do contrato usado na função J203MDIAEM
Static _dDataMDia := ctod('  /  /  ') // Variável para controle da data usada na função J203MDIAEM

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA203
Emissão de Faturas.

@author David G. Fernandes
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA203()
Local oRelation      := Nil
Local oFWLayer       := Nil
Local oPanelUp       := Nil
Local oPanelMidle    := Nil
Local aArrCoo        := {}
Local cLojaAuto      := ""
Local oFilaExe       := JurFilaExe():New("JURA203")
Local lVldUser       := Iif(FindFunction("JurVldUxP"), JurVldUxP(), .T.)        // Valida o participante relacionado ao usuário logado
Local lFluxoNFAut    := SuperGetMV("MV_JFATXNF", .F., .F.)                      // Parâmetro habilita o fluxo de emissão e cancelamento de NF a partir da fatura
Local lDiverg        := lFluxoNFAut .And. SuperGetMV("MV_JNFSCOT",, "1") == "3" // Define qual cotação será utilizada na emissão da NFS - 3 - Cotação da última baixa

Private nOperacao    := 0
Private oBrowseUp    := Nil
Private oBrowseMidle := Nil
Private oDlgFat      := Nil

If lDiverg
	JurMsgErro(I18N(STR0304, {"MV_JFATXNF", "MV_JNFSCOT"}), , I18N(STR0305, {"MV_JFATXNF", "MV_JNFSCOT"})) // "Divergência na configuração dos pâmetros #1 e #2 e a emissão automática de Nota Fiscal não irá funcionar!" # "Desabilite o fluxo automátco de emissão de NF (#1) ou altere o tipo de cotação (#2)."
EndIf

If lVldUser .And. oFilaExe:OpenWindow(.T.) //Indica que a tela está em execução para Thread de relatório
	
	aArrCoo   := FwGetDialogSize(oMainWnd)
	cLojaAuto := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

	SetCloseThread(.F.)

	SetKEY(VK_F11, {|| J203F11()       })
	SetKEY(VK_F12, {|| J203TelaAd(.T.) })

	J203TelaAd(.F.) // Carrega variável _lTelaAuto

	If !IsInCallStack('JURA202')
		JA203DLNX5()
	EndIf

	oFilaExe:StartReport() //Inicia a thread emissão do relatório

	Define MsDialog oDlgFat Title Iif(!IsInCallStack('JURA202'), STR0001, STR0196) From aArrCoo[1], aArrCoo[2] To aArrCoo[3], aArrCoo[4] STYLE nOR( WS_VISIBLE, WS_POPUP ) Pixel // Emissao de Faturas / Emissao de Minutas

	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlgFat, .F., .T.)

	// Painel Superior
	oFWLayer:AddLine('UP', 50, .F.)
	oFWLayer:AddCollumn('ALL', 100, .T., 'UP')
	oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )
	// MarkBrowse Superior
	oBrowseUp := FWMBrowse():New()
	oBrowseUp:SetOwner( oPanelUp )
	oBrowseUp:SetDescription( Iif(!IsInCallStack('JURA202'), STR0002, STR0197) ) // Faturas para Gerar / Minutas para Gerar
	oBrowseUp:SetAlias( 'NX5' )
	Iif(cLojaAuto == "1", JurBrwRev(oBrowseUp, "NX5", {"NX5_CLOJA "}), )
	oBrowseUp:SetMenuDef('JURA203')
	oBrowseUp:DisableDetails()
	oBrowseUp:SetProfileID( '2031' ) // O identificar deve ser diferente da JURA202
	oBrowseUp:SetCacheView(.F.)
	oBrowseUp:SetFilterDefault( "NX5_CODUSR == '" + __CUSERID + "' " )
	oBrowseUp:SetWalkThru(.F.)
	oBrowseUp:SetAmbiente(.F.)
	oBrowseUp:ForceQuitButton(.T.)
	oBrowseUp:SetBeforeClose({ || oBrowseUp:VerifyLayout(), oBrowseMidle:VerifyLayout()})
	JurSetLeg(oBrowseUp, 'NX5')
	oBrowseUp:Activate()

	// Painel inferior
	oFWLayer:AddLine('MIDLE', 50, .F. )
	oFWLayer:AddCollumn('ALL', 100, .T., 'MIDLE')
	oPanelMidle  := oFWLayer:GetColPanel('ALL', 'MIDLE')
	// Browse inferior
	oBrowseMidle  := FWMBrowse():New()
	oBrowseMidle:SetOwner( oPanelMidle )
	oBrowseMidle:SetDescription(STR0160) // Casos
	oBrowseMidle:SetMenuDef('JURA201')   // Referencia uma funcao que nao tem menu para que exiba nenhum
	oBrowseMidle:DisableDetails()
	oBrowseMidle:SetAlias('NX7')
	Iif(cLojaAuto == "1", JurBrwRev(oBrowseMidle, "NX7", {"NX7_CLOJA "}), )
	oBrowseMidle:SetProfileID( '2032' ) // O identificar deve ser diferente da JURA202
	oBrowseMidle:Activate()

	// Relacionamento entre os Paineis
	oRelation := FWBrwRelation():New()
	oRelation:AddRelation( oBrowseUp, oBrowseMidle, { {'NX7_FILIAL', 'xFilial("NX7")' }, { 'NX7_CFILA', 'NX5_COD' } } )
	oRelation:Activate()

	Activate MsDialog oDlgFat Center

	JA203DLNX5()

	oFilaExe:CloseWindow() // Indica que tela fechada para o client de impressão ser fechado também.

EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Cria o menu com as opções específicas do browse de Fila de geração de Faturas

@author David G. Fernandes
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
Local aSubInc := {}

aAdd(aRotina, {STR0007, 'PesqBrw'      , 0, 1, 0, .T. } ) //'Pesquisar'
aAdd(aRotina, {STR0053, "J203Altera(4)", 0, 4, 0, NIL } ) // "Alterar"
aAdd(aRotina, {STR0059, "J203Exclui()" , 0, 5, 0, NIL } ) // "Excluir"

If !IsInCallStack( 'JURA202' )
	aAdd(aSubInc, {STR0055, 'JURA203B(oBrowseUp)' , 0, 3, 0, NIL } ) //'Pré-Fatura'
	aAdd(aSubInc, {STR0056, 'JURA203C(oBrowseUp)', 0, 3, 0, NIL } ) //'Fixo'
	aAdd(aSubInc, {STR0057, 'JURA203D(oBrowseUp)', 0, 3, 0, NIL } ) //'Fatura Adicional'
	aAdd(aRotina, {STR0060, aSubInc              , 0, 3, 0, NIL } ) //'Incluir na Fila'
EndIf

aAdd(aRotina, {STR0100, 'JA203Emi()'    , 0, 4, 0, NIL } ) //'Emitir'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Time Sheet da Pré-Fatura

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView        := Nil
Local oModel       := FWLoadModel( 'JURA203' )
Local oStructNX5   := FWFormStruct( 2, 'NX5' )
Local oStructNX6   := FWFormStruct( 2, 'NX6' )
Local oStructNXG   := FWFormStruct( 2, 'NXG' )
Local oStructNVN   := FWFormStruct( 2, 'NVN' )
Local cLojaAuto    := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

If (cLojaAuto == "1") //Loja automatica
	oStructNX5:RemoveField( "NX5_CLOJA" )
EndIf

oStructNX6:RemoveField("NX6_CFILA")
oStructNX6:RemoveField("NX6_ORIGEM")
oStructNXG:RemoveField("NXG_COD")
oStructNXG:RemoveField("NXG_FILA")
oStructNXG:RemoveField("NXG_CPREFT")
oStructNXG:RemoveField("NXG_CCONTR")
If NXG->(ColumnPos('NXG_PIRRF')) > 0 .AND. NXG->(ColumnPos('NXG_PPIS')) > 0 .AND. NXG->(ColumnPos('NXG_PCOFIN')) > 0 ;  //Proteção
	.And. NXG->(ColumnPos('NXG_PCSLL')) > 0 .AND. NXG->(ColumnPos('NXG_PINSS')) > 0 .AND. NXG->(ColumnPos('NXG_PISS')) > 0  //Proteção
	oStructNXG:RemoveField( "NXG_PIRRF" )
	oStructNXG:RemoveField( "NXG_PPIS" )
	oStructNXG:RemoveField( "NXG_PCOFIN" )
	oStructNXG:RemoveField( "NXG_PCSLL" )
	oStructNXG:RemoveField( "NXG_PINSS" )
	oStructNXG:RemoveField( "NXG_PISS" )
EndIf
oStructNXG:RemoveField("NXG_CFIXO")
oStructNXG:RemoveField("NXG_CFATAD")
oStructNVN:RemoveField("NVN_CFATAD")
oStructNVN:RemoveField("NVN_CJCONT")
oStructNVN:RemoveField("NVN_CCONTR")
oStructNVN:RemoveField("NVN_CLIPG")
oStructNVN:RemoveField("NVN_LOJPG")
oStructNVN:RemoveField("NVN_CPREFT")
If NVN->(ColumnPos("NVN_CFIXO")) > 0 //Proteção
	oStructNVN:RemoveField( 'NVN_CFIXO' )
EndIf

If NVN->(ColumnPos("NVN_CFILA")) > 0 //Proteção
	oStructNVN:RemoveField( 'NVN_CFILA' )
	oStructNVN:RemoveField( 'NVN_CESCR' )
	oStructNVN:RemoveField( 'NVN_CFATUR' )
EndIf

If !Empty(NX5->NX5_CPREFT)
	oStructNX5:RemoveField("NX5_PDESCH")
EndIf

JurSetAgrp( 'NX5',, oStructNX5 )
JurSetAgrp( 'NX6',, oStructNX6 )
JurSetAgrp( 'NXG',, oStructNXG )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:SetDescription( STR0003 ) //"Time Sheet da Pré-Fatura"
oView:AddField('NX5FIELD', oStructNX5, 'NX5MASTER'  )
oView:AddGrid( 'NXGGRID', oStructNXG, 'NXGDETAIL'  )
oView:AddGrid( 'NX6GRID', oStructNX6, 'NX6DETAIL'  )
oView:AddGrid( 'NVNGRID', oStructNVN, 'NVNDETAIL' )

oView:CreateHorizontalBox( 'BOX_FIELD', 50) //Fila de emissão
oView:SetOwnerView('NX5FIELD', 'BOX_FIELD')

oView:CreateHorizontalBox( 'BOX_GRID1', 25) //Pagadores
oView:SetOwnerView('NXGGRID', 'BOX_GRID1')
oView:EnableTitleView('NXGGRID' )

oView:CreateHorizontalBox( 'BOX_GRID2', 25) //Cambios da fatura / Encaminhamento da fatura

oView:CreateVerticalBox( 'BOX_NVN', 75, 'BOX_GRID2' ) //Encaminhamento
oView:CreateVerticalBox( 'BOX_NX6', 25, 'BOX_GRID2' ) //Cambios

oView:SetOwnerView('NX6GRID', 'BOX_NX6')
oView:SetOwnerView('NVNGRID', 'BOX_NVN')
oView:AddIncrementField( 'NVNDETAIL', 'NVN_COD' )

oView:EnableTitleView('NX6GRID' )
oView:EnableTitleView('NVNGRID' )

oView:SetNoInsertLine( 'NX6GRID' )
oView:SetNoDeleteLine( 'NX6GRID' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados da Fila de Geração de Faturas

@author David G. Fernandes
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNX5 := FWFormStruct( 1, 'NX5' ) //Fila de impressão
Local oStructNX6 := FWFormStruct( 1, 'NX6' ) //Câmbio da Fatura
Local oStructNXG := FWFormStruct( 1, 'NXG' ) //Pagadores
Local oStructNVN := FWFormStruct( 1, 'NVN' )

oModel:= MPFormModel():New( 'JURA203', /*Pre-Validacao*/, {|oX| JU203TUDOK(oX)}/*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( 'NX5MASTER', NIL, oStructNX5, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:AddGrid( 'NXGDETAIL' , 'NX5MASTER'   /*cOwner*/, oStructNXG, {|oX, nLine, cAction| J203VLPAG(oX, nLine, cAction)}, /*bLinePost*/, /*bPre*/,/*bPost*/ )
oModel:AddGrid( 'NVNDETAIL' , 'NXGDETAIL'   /*cOwner*/, oStructNVN, {|oX, nLine, cAction| J203VLPAG(oX, nLine, cAction)}, /*bLinePost*/, /*bPre*/, /*bPost*/ )
oModel:AddGrid( 'NX6DETAIL' , 'NX5MASTER'   /*cOwner*/, oStructNX6, {|oX| JA203VLDM(oX)}, /*bLinePost*/, /*bPre*/, /*bPost*/ )

oStructNX5:SetProperty( 'NX5_PACREH' , MODEL_FIELD_WHEN, {|| J203HABCPO('NX5_PACREH')} )
oStructNX5:SetProperty( 'NX5_ACRESH' , MODEL_FIELD_WHEN, {|| J203HABCPO('NX5_ACRESH')} )

oModel:SetDescription( STR0004 ) //"Modelo de Dados de Time Sheet Pré-Fatura"
oModel:GetModel( 'NX5MASTER' ):SetDescription( STR0061 ) //"Dados da Fatura"
oModel:GetModel( 'NX6DETAIL' ):SetDescription( STR0062 ) //"Câmbio da Fatura"
oModel:GetModel( 'NXGDETAIL' ):SetDescription( STR0204 ) //"Pagadores"
oModel:GetModel( 'NVNDETAIL' ):SetDescription( STR0282 ) //"Encaminhamento de fatura"

oModel:SetRelation( 'NX6DETAIL', { { "NX6_FILIAL", "xFilial('NX6')" } , { "NX6_CFILA", "NX5_COD" } } , NX6->( IndexKey( 1 ) ) )
oModel:SetRelation( 'NXGDETAIL', { { "NXG_FILIAL", "xFilial('NXG')" } , { "NXG_FILA",  "NX5_COD" } , { "NXG_CPREFT", "NX5_CPREFT" }, { "NXG_CFATAD", "NX5_CFATAD" }, { "NXG_CFIXO", "NX5_CFIXO" } }, NXG->(IndexKey(2)) )

If NVN->(ColumnPos("NVN_CFILA")) > 0 //Proteção 
	oModel:SetRelation( 'NVNDETAIL', { { 'NVN_FILIAL', "xFilial('NVN')" }, { 'NVN_CLIPG', 'NXG_CLIPG' }, { 'NVN_LOJPG', 'NXG_LOJAPG' }, { "NVN_CFILA", "NXG_FILA" } }, NVN->(IndexKey(3)) )
Else //quando remover a proteção, remover o bloco do else
	If !Empty(NX5->NX5_CPREFT)
		oModel:SetRelation( 'NVNDETAIL', { { 'NVN_FILIAL', "xFilial('NVN')" }, { 'NVN_CLIPG', 'NXG_CLIPG' }, { 'NVN_LOJPG', 'NXG_LOJAPG' }, { "NVN_CPREFT", "NXG_CPREFT" } }, NVN->( IndexKey( 2 ) ) )
	
	ElseIf !Empty(NX5->NX5_CFATAD)
		oModel:SetRelation( 'NVNDETAIL', { { 'NVN_FILIAL', "xFilial('NVN')" }, { 'NVN_CLIPG', 'NXG_CLIPG' }, { 'NVN_LOJPG', 'NXG_LOJAPG' }, { "NVN_CFATAD", "NXG_CFATAD" } }, NVN->( IndexKey( 2 ) ) )
	
	ElseIf !Empty(NX5->NX5_CFIXO) .And. NVN->(ColumnPos("NVN_CFIXO")) > 0 //Proteção 
		oModel:SetRelation( 'NVNDETAIL', { { 'NVN_FILIAL', "xFilial('NVN')" }, { 'NVN_CLIPG', 'NXG_CLIPG' }, { 'NVN_LOJPG', 'NXG_LOJAPG' }, { "NVN_CFIXO", "NXG_CFIXO" } }, NVN->( IndexKey( 2 ) ) )
	
	Else // Proteção NX5_CFIXO
		oModel:SetRelation( 'NVNDETAIL', { { 'NVN_FILIAL', "xFilial('NVN')" }, { 'NVN_CLIPG', 'NXG_CLIPG' }, { 'NVN_LOJPG', 'NXG_LOJAPG' } }, NVN->( IndexKey( 7 ) ) )
	EndIf
EndIf

oModel:GetModel( 'NX6DETAIL' ):SetUniqueLine( { "NX6_CMOEDA" } )
oModel:GetModel( 'NXGDETAIL' ):SetUniqueLine( { "NXG_CLIPG", "NXG_LOJAPG" } )
oModel:GetModel( 'NVNDETAIL' ):SetUniqueLine( { 'NVN_CCONT'} )
oModel:GetModel( 'NX6DETAIL' ):SetDelAllLine( .T. )
oModel:SetOptional( 'NX6DETAIL', .T. )
oModel:SetOptional( 'NXGDETAIL', .T. )
oModel:SetOptional( 'NVNDETAIL', .T. )

JurSetRules( oModel, 'NX5MASTER',, 'NX5',, )
JurSetRules( oModel, 'NX6DETAIL',, 'NX6',, )
JurSetRules( oModel, 'NXGDETAIL',, 'NXG',, )
JurSetRules( oModel, 'NVNDETAIL',, 'NVN',, )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203VLDM(oModelNX6)
Função especifica para desabilitar o campo de moeda do pagador no
grid de cotaçoes da fila de emissão de fatura.

@Param	oModelNX6 	modelo de dados do grid de cotações

@author Luciano Pereira dos Santos
@since 01/11/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA203VLDM(oModelNX6)
Local lRet      := .T.
Local oStrucNX6 := oModelNX6:GetStruct()

oStrucNX6:SetProperty( 'NX6_CMOEDA', MODEL_FIELD_NOUPD, .T. )
oStrucNX6:SetProperty( 'NX6_CMOEDA', MODEL_FIELD_WHEN, {|| .F.} )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JU203TUDOK
Valida os campos na hora de salvar

@author Fabio Crespo Arruda
@since 22/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JU203TUDOK(oModel)
Local lRet      := .T.
Local oModelNXG := oModel:GetModel('NXGDETAIL')
Local nQtdNXG   := oModelNXG:GetQtdLine()
Local aSaveLn   := FWSaveRows(  )
Local nI        := 0
Local cMoedaNac := SuperGetMv('MV_JMOENAC',, 01)
Local cParam    := ""

For nI := 1 To nQtdNXG 

	If oModelNXG:GetValue("NXG_CMOE", nI) == cMoedaNac
		cParam  := "MV_JCPGNAC"
	Else
		cParam  := "MV_JCPGINT"
	EndIf

	If lRet
		If oModelNXG:IsDeleted( nI ) .And. (!Empty(oModelNXG:GetValue('NXG_CFATUR', nI)) .Or. !Empty(oModelNXG:GetValue('NXG_CFATUR', nI)))
			lRet := JurMsgErro(STR0207) //"Não é possível excluir um pagador com fatura emitida!"
			Exit
		EndIf
	EndIf

	If lRet
		If oModelNXG:IsUpdated(nI) .And. (!Empty(oModelNXG:GetValue('NXG_CFATUR', nI)) .Or. !Empty(oModelNXG:GetValue('NXG_CFATUR', nI)))
			lRet := JurMsgErro(STR0208) //"Não é possível alterar um pagador com fatura emitida!"
			Exit
		EndIf
	EndIf

	If lRet
		If Empty(oModelNXG:GetValue("NXG_DTVENC", nI))
			JA203VENC()
		EndIf
	EndIf

Next nI

If lRet
	lRet := JurVldPag(oModel) //Validação de pagadores
EndIf

If lRet .And. ( NX5->(FieldPos('NX5_DSPFIX')) > 0 )
	If oModel:GetValue("NX5MASTER", "NX5_DSPFIX") == '1'
		lRet := (oModel:GetValue("NX5MASTER", "NX5_DREFID") <> CToD( '  /  /  ' )) .And. (oModel:GetValue("NX5MASTER", "NX5_DREFFD") <> CToD( '  /  /  ' ))
	EndIf
EndIf

FWRestRows( aSaveLn )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203Emi
Rotina que irá emitir as Faturas dos itens que estão na fila
@param lAutomato       , Execução em automação
@param aAutoParams      , Parâmetros de Emissão da Fatura
@param lMinutaPre      , Emissão de Minuta (origem JURA202)

@return lRet           , Emissão realizada com sucesso
@author David G. Fernandes
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA203Emi(lAutomato, aAutoParams, lMinutaPre)
Local aArea         := GetArea()
Local bFiltro       := Nil
Local lFat          := .F.
Local cFiltro       := ""
Local cFiltOld      := NX5->( dbFilter() )
Local lRet          := .T.
Local aRetorno      := {}

Default lAutomato   := .F.
Default aAutoParams := {}
Default lMinutaPre  := IsInCallStack('JURA202')

cFiltro  := Iif( lAutomato, "", oBrowseUp:oFWFilter:GetExprADVPL())

//Verifica presença de registros
NX5->(dbGoTop())
lFat := !(NX5->(Eof()))

//Restaura posicionamento da NX5 para uso posterior
RestArea(aArea)

//Restaura filtros anteriores
If !Empty( cFiltOld )
	bFiltro  := &('{||' + cFiltOld + '}')
	NX5->(dbSetFilter(bFiltro, cFiltOld))
Else
	NX5->(dbClearFilter())
EndIf

//Se existirem registros, emite minuta
If lFat
	//Utilizar o array aParams com as 21 posições descritas na rotina JA203PARAM()
	If ExistBlock('J203EMISS')
		aRetorno := ExecBlock('J203EMISS', .F., .F.)
		lRet     := aRetorno[1]
		aParams  := aRetorno[2]
	Else
		aRetorno := JA203PARAM(lAutomato, aAutoParams)
		lRet     := aRetorno[1]
		aParams  := aRetorno[2]
	EndIf

	If lRet
		If FindFunction("JPDLogUser")
			JPDLogUser("JA203Emi") // Log LGPD Relatório de Refazer da Pré-Fatura
		EndIf

		Processa( {|| JA203Emite(aParams, /*lEnd*/, lAutomato, lMinutaPre) }, STR0111, STR0112, .F. ) //#"Aguarde..." ## "Emitindo..."
	Else
		ApMsgStop(STR0229) // "Operação cancelada"
	EndIf
Else
	ApMsgStop(Iif(!IsInCallStack('JURA202'), STR0195, STR0199)) // Não há fatura na fila / Não há minuta na fila
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203PARAM
Cria a tela de parâmetros para emissão de Faturas

aParams[ 1] -	caracter	-	Opções de emissão(Crystal): cOptions + ';0;1;'
cOption - '2' = Impressora
cOption - '8' = Word
cOption - '1' = Tela
aParams[ 2] -	caracter	-	código do usuário do protheus (__CUSERID)
aParams[ 3] -	caracter	-	Número da fatura
aParams[ 4] -	caracter	-	Escritório
aParams[ 5] -	caracter	-	Nome do Sócio da Fatura
aParams[ 6] -	caracter	-	Código do Cliente
aParams[ 7] -	lógico		-	Minuta de pré? ('S' / 'N')
aParams[ 8] -	lógico		-	Exibe logotipo? ('S' / N)
aParams[ 9] -	lógico		-	Utiliza dados de depósito? 	 ('S' / 'N')
aParams[10] -	lógico		-	Utiliza contra apresentação (substitui o vencimento por 'contra-apresentação')  ('S' / 'N')
aParams[11] -	lógico		-	Fatura Rateada? ('S' / 'N')
aParams[12] -	caracter	-	Nome do relatório a ser emitido (sem extensão .RPT)
aParams[13] -				-	Recibo
aParams[14] -				-	Boleto
aParams[15] -	lógico		-	Utilizar Redação ('S' / 'N')
aParams[16] -	lógico		-	Ocultar despesas no Relatório ('S' / 'N')
aParams[17] -	lógico		-	Exibir Assinatura Eletronica ('S' / 'N')
aParams[18] -	caracter	-	Redator - Nome do participante de emissão
aParams[19] -	caracter	-	Resultado do relatório - char: '1' - Impressora / '3' - Word / outros - Tela
aParams[20] -	caracter	-	Command - Para adição de parâmetros customizados na carta - separados com ';' e terminado com ';'
aParams[21] -	caracter	-	Command - Para adição de parâmetros customizados no relatório - separados com ';' e terminado com ';'

@author David G. Fernandes
@since 06/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA203PARAM(lAutomato, aAutoParams)
Local lRet          := .F.
Local oDlg          := Nil

Local lChkAssEle    := .T.
Local cSigla        := Criavar( 'RD0_SIGLA', .F. )
Local cNome         := Criavar( 'RD0_NOME', .F. )
Local oCkNomeRes    := Nil
Local oCkMinuta     := Nil
local oCkBoleto     := Nil
Local oCkAssinat    := Nil
Local oCkRedacao    := Nil
Local oCkContApr    := Nil
Local oCkLogo       := Nil
Local oCkAdicDep    := Nil
Local oCkNoDesps    := Nil
Local oGetNome      := Nil
Local lCkNomeRes    := .F.
Local lCkRedacao    := .F.
Local lCkContApr    := .F.
Local lCkLogo       := .F.
Local lCkAdicDep    := .F.
Local lCkNoDesps    := .F.
Local lCkMinuta     := .F.
Local lCkBoleto     := .T.
Local lIsJURA202    := IsInCallStack( 'JURA202' )

Local oGetResp      := Nil
Local aCbResult     := { STR0015, STR0016, STR0185, STR0186 } //"Impressora" "Tela", "Word", "Nenhum"
Local cCbResult     := Space( 25 )
Local cOptions      := ''
Local cCommand      := ''
Local aParams       := Array(22)
Local lPDUserAc     := Iif(FindFunction("JPDUserAc"), JPDUserAc(), .T.) // Indica se o usuário possui acesso a dados sensíveis ou pessoais (LGPD)

Private lCkRecibo   := .F.
Private oCkRecibo   := Nil

Default lAutomato   := .F.
Default aAutoParams := {}

If lAutomato

	cOptions   := aAutoParams[1]
	lCkNomeRes := aAutoParams[5]
	lCkMinuta  := aAutoParams[7]
	lCkLogo    := aAutoParams[8]
	lCkAdicDep := aAutoParams[9]
	lCkContApr := aAutoParams[10]
	lCkRecibo  := aAutoParams[13]
	lCkRedacao := aAutoParams[15]
	lCkNoDesps := aAutoParams[16]
	lChkAssEle := aAutoParams[17]
	cCbResult  := aAutoParams[19]
	cCommand   := aAutoParams[20]
	lCkBoleto  := aAutoParams[21]
	lRet       := .T.

Else

	If !lPDUserAc
		cCbResult := aCbResult[4] // Nenhum
	EndIf

	DEFINE MSDIALOG oDlg TITLE Iif(!lIsJURA202, STR0088, STR0198) FROM 0,0 TO 230,430  PIXEL // Confirmar emissão das faturas / Confirmar emissão das minutas
	
	@ 010, 005 CheckBox oCkMinuta  Var lCkMinuta  Prompt STR0300 Size 100, 008 Pixel Of oDlg ; // "Minuta Fatura / Conferência"
	On Change (J203Cmp(lCkMinuta))																						
	If lIsJURA202
		oCkMinuta:cCaption := STR0091 //"Minuta"
		lCkMinuta := .T.
		oCkMinuta:Disable()
	EndIf
	
	@ 020, 005 CheckBox oCkRedacao Var lCkRedacao Prompt STR0092 Size 100, 008 Pixel Of oDlg // "Utilizar Redação"
	@ 030, 005 CheckBox oCkContApr Var lCkContApr Prompt STR0093 Size 100, 008 Pixel Of oDlg // "Contra Apresentação"
	@ 040, 005 CheckBox oCkNomeRes Var lCkNomeRes Prompt STR0097 Size 100, 008 Pixel Of oDlg // "Incluir nome do Sócio"
	@ 050, 005 CheckBox oCkRecibo  Var lCkRecibo  Prompt STR0089 Size 100, 008 Pixel Of oDlg // "Emitir Recibo"
	If lIsJURA202
		lCkRecibo := .F.
		oCkRecibo:Disable()
	EndIf
	
	@ 060,005 Say STR0098 Size 035,008  PIXEL OF oDlg //"Responsável"
	@ 070,005 MsGet oGetResp Var cSigla Valid ;
	IIf(!Empty(cSigla), ;
	IIf( ExistCPO( 'RD0', cSigla, 9), cNome := JurGetDados('RD0', 9, xFilial('RD0') + cSigla, 'RD0_NOME' ), cNome := '') ;
	,.T.) F3 'RD0REV' HasButton Size 100,009 PIXEL OF oDlg
	@ 085,005 MsGet oGetNome Var cNome  Size 205,009 PIXEL OF oDlg
	
	@ 010,110 CheckBox oCkLogo    Var lCkLogo    Prompt STR0094 Size 100, 008 Pixel Of oDlg // "Exibir Logotipo"
	lCkLogo := .T.
	@ 020,110 CheckBox oCkAdicDep Var lCkAdicDep Prompt STR0095 Size 100, 008 Pixel Of oDlg // "Adicionar Depósito"
	@ 030,110 CheckBox oCkNoDesps Var lCkNoDesps Prompt STR0096 Size 100, 008 Pixel Of oDlg // "Ocultar despesas no Relatório"
	@ 040,110 CheckBox oCkAssinat Var lChkAssEle Prompt STR0045 Size 100, 008 Pixel Of oDlg // "Exibir Assinatura Eletronica"
	If !lIsJURA202
		@ 050,110 CheckBox oCkBoleto Var lCkBoleto Prompt STR0046 Size 100, 008 Pixel Of oDlg // "Emitir Boleto"
	EndIf
	@ 060,110 Say STR0099 Size 030,008 PIXEL OF oDlg //"Resultado:"
	@ 070,110 ComboBox cCbResult Items aCbResult When lPDUserAc Size 100, 010 Pixel Of oDlg
	
	@ 100,130 Button STR0100 Size 037,012 PIXEL OF oDlg  Action (lRet := .T., oDlg:End() )  //"Emitir"
	@ 100,173 Button STR0084 Size 037,012 PIXEL OF oDlg  Action (lRet := .F., oDlg:End() )  //"Cancelar"

	ACTIVATE MSDIALOG oDlg CENTERED
EndIf

If Len(cCbResult) > 1
	cCbResult := AllTrim( Str( aScan( aCbResult, cCbResult ) ) )
EndIf

If lRet
	Do Case
		Case cCbResult = '1'  //Impressora
			cOptions := '2'
		Case cCbResult = '3'  //Word
			cOptions := '8'
		Otherwise //Tela
			cOptions := '1'
	EndCase
	cOptions := cOptions + ';0;1;'  // "Relatorio de Faturamento"

	aParams[ 1] := cOptions

	aParams[ 2] := __CUSERID//vpiCodUser
	aParams[ 3] := ' '//vpiNumFatura
	aParams[ 4] := ' '//vpiOrganizacao
	aParams[ 5] := IIf( lCkNomeRes , cNome, ' ' )//vpcNoSocioFatura
	aParams[ 6] := ' '//vpiCliente
	aParams[ 7] := IIf( lCkMinuta  , 'S', 'N' ) //vpcPreFaturaMinuta
	aParams[ 8] := IIf( lCkLogo    , 'S', 'N' ) //vpcExibirLogo
	aParams[ 9] := IIf( lCkAdicDep , 'S', 'N' ) //vpcDadosDeposito
	aParams[10] := IIf( lCkContApr , 'S', 'N' ) //vpcContraApresentacao
	aParams[11] := ' '//cContApr
	aParams[12] := ' '//cRelatorio
	aParams[13] := IIf( lCkRecibo , 'S', 'N' )
	aParams[14] := IIf( lCkBoleto , 'S', 'N' )
	aParams[15] := IIf( lCkRedacao, 'S', 'N' )
	aParams[16] := IIf( lCkNoDesps, 'S', 'N' )
	aParams[17] := IIf( lChkAssEle, 'S', 'N' )
	aParams[18] := JurGetDados("RD0", 1, xFilial("RD0") + JurUsuario(__CUSERID), "RD0_NOME")
	aParams[19] := cCbResult	//Resultado do relatório: '1' - Impressora / '2' - Tela / '3' - Word / '4' - Nenhum
	aParams[20] := cCommand
	aParams[21] := cCommand
	aParams[22] := cCommand
EndIf

Return {lRet, aParams}

//-------------------------------------------------------------------
/*/{Protheus.doc} J203Cmp
habilita o campo recibo conforme opção de emissão (fatura ou minuta)

@author TOTVS
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203Cmp(lCkMinuta)

If lCkMinuta
	lCkRecibo := .F.
	oCkRecibo:Disable()
Else
	oCkRecibo:Enable()
	lCkRecibo := .F.
EndIf

oCkRecibo:Refresh()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203Emite
Emite os relatórios da Fatura
@param aParams         , Parâmetros de Emissão da Fatura
@param lEnd            , Obsoleto
@param lAutomato       , Execução em automação
@param lMinutaPre      , Emissão de Minuta (origem JURA202)

@return lRet           , Emissão realizada com sucesso

@author David G. Fernandes
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA203Emite(aParams, lEnd, lAutomato, lMinutaPre)
Local lRet        := .T.
Local aArea       := GetArea()
Local aAreaPE     := {}
Local cQuery      := ""
Local cQryRes     := ""
Local cQuery2     := ""
Local cQryRes2    := ""
Local aRet        := {}
Local cTpRel      := ""
Local cCarta      := ""
Local cTipo       := "" //1 - Fatura / 2 - Minuta de Fatura / 3 - Minuta de Pré-fatura
Local aRecsE1     := {}
Local cChavE1     := ""

Local cFila       := ""
Local cCCLIEN     := ""
Local cCLOJA      := ""
Local cCCONTR     := ""
Local cCJCONT     := ""
Local cCPREFT     := ""
Local cCFIXO      := ""
Local cCFATAD     := ""
Local TEMTS       := ""
Local TEMDP       := ""
Local TEMLT       := ""
Local TEMFX       := ""
Local TEMFA       := ""
Local nNX5Recno   := 0
Local oParams     := TJPREFATPARAM():New()
Local nSaveSX8    := GetSx8Len()  // guarda a quantidade de registro não confirmados antes da emissão
Local dDtEmit
Local cCPART      := ""
Local cSituac     := ""
Local cMsg        := ""
Local cMoedaFat   := ""
Local lDspFix     := .F.
Local dIniDsp
Local dFimDsp
Local cDirCrystal := GetMV('MV_CRYSTAL')
Local cArqRel     := ''
Local cPreFat     := GetMV( 'MV_JPREFAT',, 'PFS' )
Local cTipFat     := GetMV( 'MV_JTIPFAT',, 'FT ' )
Local cMemoLog    := ""
Local cMemoNFLog  := ""
Local a203G       := {}
Local aFaturas    := {}
Local nFat        := 0
Local cRotina     := "JURA203"
Local oFilaExe    := JurFilaExe():New( cRotina, "2" ) //2=Impressão
Local lPortador   := SuperGetMV( 'MV_JUSAPOR', .F., .T. ) //Utiliza dados do portador da fatura/contrato
Local lExt203GRV  := ExistBlock("JA203GRV")
Local lExt203BOL  := ExistBlock("JA203BOL")
Local aFilFxOld   := J203FlFxOld()
Local lFalcIss    := FindFunction("FCalcISS")
Local lIntegracao := (SuperGetMV("MV_JFSINC", .F., '2') == '1') //Sincronização com o Legal Desk.
Local lDesp       := .F.

Default lEnd      := .F.
Default lAutomato := .F.

If !lFalcIss
	lRet := JurMsgErro(STR0302, , STR0303) // "Não localizada a rotina FCalcISS", , "Por favor, atualize o fonte FINXIMP para uma versão igual ou superior a 29/11/2019."
EndIf

If lRet
	a203G := JURA203G( 'FT', Date(), 'FATEMI' )
	If a203G[2]
		dDtEmit := a203G[1]
	Else
		lRet := a203G[2]
	EndIf
EndIf

If lRet

	ProcRegua( 0 )

	cQuery := "SELECT NX5.NX5_COD, "
	cQuery +=       "NX5.NX5_CCLIEN, "
	cQuery +=       "NX5.NX5_CLOJA, "
	cQuery +=       "NX5.NX5_CCONTR, "
	cQuery +=       "NX5.NX5_CJCONT, "
	cQuery +=       "NX5.NX5_CPREFT, "
	cQuery +=       "NX5.NX5_CFIXO, "
	cQuery +=       "NX5.NX5_CFATAD, "
	cQuery +=       "NX5.NX5_TS TEMTS, "
	cQuery +=       "NX5.NX5_DES TEMDP, "
	cQuery +=       "NX5.NX5_TAB TEMLT, "
	cQuery +=       "NX5.NX5_FIXO TEMFX, "
	cQuery +=       "NX5.NX5_FATADC TEMFA, "
	If NX5->(FieldPos('NX5_DSPFIX')) > 0
		cQuery +=   "NX5.NX5_DSPFIX DSPFIX, " //Para indicar se despesas serão vinculadas a fatura de fixo pela fila
	EndIf
	cQuery +=       "NX5.NX5_DREFID DINIDSP, "
	cQuery +=       "NX5.NX5_DREFFD DFIMDSP, "
	cQuery +=       "NX5.NX5_CMOEFT MOEDAFAT, "
	cQuery +=       "(NX5.NX5_VLFATH - NX5.NX5_DESCH + NX5.NX5_ACRESH) + NX5.NX5_VLFATD VALOR, "
	cQuery +=       "NX5.R_E_C_N_O_ NX5RECNO "
	cQuery += " FROM " + RetSqlName( 'NX5' ) + " NX5 "
	cQuery += " WHERE NX5.D_E_L_E_T_ = ' ' "
	cQuery += " AND NX5.NX5_FILIAL = '"+ xFilial("NX5") +"' "
	cQuery += " AND NX5.NX5_CODUSR = '"+ __CUSERID  +"' "

	cQryRes := GetNextAlias()

	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

	While !(cQryRes)->(EOF())

		lRet      := .T.
		cFila     := (cQryRes)->NX5_COD
		cCCLIEN   := (cQryRes)->NX5_CCLIEN
		cCLOJA    := (cQryRes)->NX5_CLOJA
		cCCONTR   := (cQryRes)->NX5_CCONTR
		cCJCONT   := (cQryRes)->NX5_CJCONT
		cCPREFT   := (cQryRes)->NX5_CPREFT
		cCFIXO    := (cQryRes)->NX5_CFIXO
		cCFATAD   := (cQryRes)->NX5_CFATAD
		TEMTS     := (cQryRes)->TEMTS
		TEMDP     := (cQryRes)->TEMDP
		TEMLT     := (cQryRes)->TEMLT
		TEMFX     := (cQryRes)->TEMFX
		TEMFA     := (cQryRes)->TEMFA
		lDspFix   := (cQryRes)->DSPFIX == "1"
		dIniDsp   := StoD((cQryRes)->DINIDSP)
		dFimDsp   := StoD((cQryRes)->DFIMDSP)
		cMoedaFat := (cQryRes)->MOEDAFAT
		VALOR     := (cQryRes)->VALOR
		nNX5Recno := (cQryRes)->NX5RECNO

		IncProc(STR0112 +" ("+ STR0276 + cFila +")" ) //Emitindo ... ## Fila:

		// TpExec:
		// 3 - Minuta Pré
		// 4 - Minuta Fatura
		// 5 - Emissão de Fatura
		// 6 - Reemitir Fatura
		// 7 - Minuta Sócio

		//cTipo:
		//1 - Fatura / 2 - Minuta de Fatura / 3 - Minuta de Pré-fatura / 4 - Minuta Sócio

		If lMinutaPre
			cSituac := JurGetDados('NX0', 1, xFilial('NX0') + cCPREFT, 'NX0_SITUAC')
			Do Case
			case cSituac == "5" // Minuta de pré
				cTipo := "3"
			case cSituac == "9" // Minuta Sócio
				cTipo := "4"
			EndCase
		Else
			cTipo :=  IIf( aParams[7] == 'S', '2', '1')
		EndIf

		If VALOR <= 0 // Não possui valores a faturar
			If Empty(cCPREFT) // Não possui pré-fatura portanto é emissão de fixo ou fatura adicional direto na fila
				lDesp := J203VlDesp(cCFATAD, cCFIXO, lDspFix, dIniDsp, dFimDsp ) // Busca o total das despesas quando for parcela de fixo que foi zerada por desconto
				If !lDesp
					lRet := JurMsgErro(STR0210, , STR0235 + AllTrim(cFila)) // #"A soma de Honorários - Desconto + Acréscimo - Despesas, deve ser maior que zero! " ##"Verifique registro do código de fila: "
				EndIf
			Else // Possui pré-fatura sem valores a faturar
				lRet := JurMsgErro(STR0210, , STR0235 + AllTrim(cFila)) //#"A soma de Honorários - Desconto + Acréscimo - Despesas, deve ser maior que zero! " ##"Verifique registro do código de fila: "
			EndIf
		EndIf

		If lRet .And. !J203VldPg(cFila, cCPREFT, cCFATAD, cCFIXO, lAutomato)
			lRet := .F.
		EndIf

		If lRet .And. !J203VlDesc(cCPREFT, cFila)
			lRet := .F.
		EndIf

		If lRet .And. !J203VlCota(cFila, dDtEmit, cCPREFT)
			lRet := .F.
		EndIf

		If lRet
			lRet := J203CanMin(cCPREFT, cCFATAD, cCFIXO) //Verifica o periodo de cancelamento das Minutas para validar se será possível cancelar
		EndIf
		
		/*
		Bloco criado para efetuar a atualização do valor de despesas e peencher as cotações
		quando se tratar de emissão de fixo direto pela fila, com vínculo de despesas.
		*/
		If lRet .And. lDspFix
			JA203COTLC(cFila, .F., .T., .F., cCCONTR, cCCLIEN, cCLOJA, dIniDsp, dFimDsp, cMoedaFat, .T. )
		EndIf

		If lRet

			// TpExec:
			// 3 - Minuta Pré
			// 4 - Minuta Fatura
			// 5 - Emissão de Fatura
			// 6 - Reemitir Fatura
			// 7 - Minuta Sócio

			//cTipo:
			//1 - Fatura / 2 - Minuta de Fatura / 3 - Minuta de Pré-fatura / 4 - Minuta Sócio
			Do Case
			Case cTipo == "1"
				oParams:SetTpExec("5")
			Case cTipo == "2"
				oParams:SetTpExec("4")
			Case cTipo == "4"
				oParams:SetTpExec("MS")
			OtherWise
				oParams:SetTpExec("3")
			EndCase

			oParams:SetCodUser( __CUSERID)
			oParams:SetDEmi(dDtEmit)
			oParams:SetCFilaImpr(cFila)
			oParams:SetcTipoFat(cTipo)
			oParams:SetParams(aParams)

			BEGIN TRANSACTION
				aRet := JA203FEmi(oParams, cCPREFT, cCFATAD, cCFIXO, cCJCONT, cCCONTR, cCCLIEN, cCLOJA)
				If Len(aRet) >= 2
					lRet       := aRet[1]
					cMsg       := aRet[2]
					cMemoNFLog := IIF(Len(aRet) == 3, aRet[3], "")
				Else
					lRet := .F.
				EndIf

				If !lRet
					DisarmTransaction()
					Break
				EndIf

			END TRANSACTION

			If lRet
				While (GetSx8Len() > nSaveSX8) // confirma os registros usados na transação
					ConfirmSX8()
				EndDo
				MsUnlockAll()
				DbCommitAll()
			Else
				While (GetSx8Len() > nSaveSX8)  //Libera os registros usados na transação
					RollBackSX8()
				EndDo
				If !Empty(cMsg)
					cMemoLog += STR0220 + cFila + CRLF //"Código da fila: "
					cMemoLog += cMsg
				EndIf
			EndIf

			If lRet
				aFaturas := oParams:GetFatEmite()

				For nFat := 1 To Len(aFaturas)

					NXA->(DBGoTo(aFaturas[nFat]))

					If !Empty(cCPREFT)
						cMsg += STR0272 + NXA->NXA_CESCR + NXA->NXA_COD + CRLF //"No. FATURA: "
					EndIf

					//Ponto de Entrada para complementar gravação das Faturas antes da geração dos relatórios
					If lExt203GRV
						aAreaPE := NXA->(GetArea())
						ExecBlock("JA203GRV", .F., .F., { cTipo, NXA->NXA_CESCR, NXA->NXA_COD} )
						RestArea( aAreaPE )
					EndIf

					//Gera os relatórios da Fatura
					aParams[ 3] := NXA->NXA_COD
					aParams[ 4] := NXA->NXA_CESCR

					cTpRel := Alltrim(JurGetDados("NRJ", 1, xFilial("NRJ") + NXA->NXA_TPREL, "NRJ_ARQ"))

					If Empty(cTpRel)
						aParams[12] := 'JU203'
					Else
						// Valida se o arquivo RPT existe na pasta de relatorios Crystal
						cArqRel := Upper(alltrim(cTpRel))
						cArqRel := StrTran(cArqRel, '.RPT', '')  // tira o .rpt do nome caso tenha sido cadastrado

						If File(cDirCrystal + cArqRel + '.RPT')  // verifica se encontra o arquivo especifico na pasta dos relatorios
							aParams[12] := IIF(At( '.', cTpRel ) > 0, Substr(cTpRel, 1, At( '.', cTpRel ) - 1 ), cTpRel)
						Else
							aParams[12] := 'JU203'  // arquivo padrao
						EndIf
					EndIf
					// Gera o relatório de Faturamento
					J203ADDREL("F", aParams, , cRotina, lAutomato)

					cCarta := alltrim(JurGetDados("NRG", 1, xFilial("NRG") + NXA->NXA_CCARTA, "NRG_ARQ"))

					If Empty(cCarta)
						aParams[12] := 'JU203A'
					Else
						aParams[12] := IIF(At( '.', cCarta ) > 0, Substr(cCarta, 1, At( '.', cCarta ) - 1 ), cCarta)
					EndIf

					//Gera a Carta de Cobrança
					J203ADDREL("C", aParams, , cRotina, lAutomato)

					If aParams[13] == 'S' .And. aParams[ 7] == 'N'
						aParams[12] := 'JU203b'

						//Gera o Recibo
						J203ADDREL("R", aParams, , cRotina, lAutomato)
					EndIf

					//Executa o ponto de entrada somente se o resultado da impressão for diferente de Nenhum e se for do tipo Fatura
					If NXA->NXA_TIPO == "FT"
						If lExt203BOL
							NS7->( DbSetOrder(1) )
							If NS7->( dbSeek( xFilial('NS7') + NXA->NXA_CESCR ) )

								aRecsE1 := {}
								cChavE1 := AvKey(NS7->NS7_CFILIA, "E1_FILIAL") + AvKey(cPreFat, "E1_PREFIXO") + AvKey(NXA->NXA_COD, "E1_NUM")

								SE1->( DbSetOrder(1) )
								SE1->( DbSeek( cChavE1 ) )

								While !SE1->(Eof()) .And. cChavE1 == SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM
									//Somente titulos de fatura
									If SE1->E1_TIPO == AvKey(cTipFat,"E1_TIPO")
										AAdd( aRecsE1, SE1->(Recno()) )
									EndIf
									SE1->( DbSkip() )
								EndDo

								ExecBlock("JA203BOL",.F.,.F.,{ aRecsE1, aParams } )

							EndIf
						Else
							If FindFunction("U_FINX999") .And. aParams[14] == 'S' .And. NXA->NXA_FPAGTO == "2" .And. lPortador // Emite boleto
								J203ADDREL("B", aParams, , cRotina, lAutomato)
							EndIf
						EndIf
					EndIf

					J203ADDREL("D", aParams, , cRotina, lAutomato)

					If lRet .And. NXA->NXA_FIXO == '1'

						cQuery2 := " SELECT NWE.NWE_CFIXO, NT1.NT1_CCONTR "
						cQuery2 += " FROM " + RetSqlName( 'NWE' ) + " NWE, "
						cQuery2 +=      " " + RetSqlName( 'NT1' ) + " NT1 "
						cQuery2 += " WHERE NWE.NWE_FILIAL = '" + xFilial("NWE") +"' "
						cQuery2 +=   " AND NT1.NT1_FILIAL = '" + xFilial("NT1") +"' "
						cQuery2 +=   " AND NWE.NWE_CFATUR = '" + NXA->NXA_COD +"' "
						cQuery2 +=   " AND NWE.NWE_CESCR = '" + NXA->NXA_CESCR +"' "
						cQuery2 +=   " AND NT1.NT1_SEQUEN = NWE.NWE_CFIXO "
						cQuery2 +=   " AND NWE.D_E_L_E_T_ = ' ' "
						cQuery2 +=   " AND NT1.D_E_L_E_T_ = ' ' "
						cQuery2 +=   " ORDER BY NWE.NWE_CFIXO "

						cQryRes2    := GetNextAlias()

						cQuery2 := ChangeQuery(cQuery2, .F.)
						dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery2 ), cQryRes2, .T., .F. )

						While !(cQryRes2)->(EOF())

							J203NParc((cQryRes2)->NT1_CCONTR, (cQryRes2)->NWE_CFIXO, .T. ) //Transferido ponto de entrada JA203NT1 para rotina J203NParc por ser dependente do posicionamento da NT1

							(cQryRes2)->(Dbskip())
						EndDo

						(cQryRes2)->(DbCloseArea())

					EndIf

					If oParams:GetTpExec() == "5" .And. !Empty(cCFIXO) .And. (nPos := aScan(aFilFxOld, {|a| a[1] == cFila})) > 0
						J203FatFX(cCFIXO, aFilFxOld[nPos][1], aFilFxOld[nPos][2]) //No caso de Reemissão de fixo, atualiza o código da fila nas demais faturas e limpa a fila antiga.
					EndIf

				Next nFat

				//Insere o Histórico na pré-fatura
				If !Empty(cCPREFT)
					cCPART  := JurGetDados('NX0', 1, xFilial('NX0') + cCPREFT, 'NX0_CPART')
					If cTipo == '1' // Fatura
						J202HIST('4', cCPREFT, cCPART, cMsg) // Emissão de fatura

						If NX0->(FieldPos('NX0_FATURA')) > 0
							NX0->( DbSetOrder(1) ) //NX0_FILIAL+NX0_COD
							If (NX0->( DbSeek(xFilial("NX0") + cCPREFT)))
								RecLock("NX0",.F.)
								NX0->NX0_FATURA := Iif(J203IsFat(cCPREFT), "1", "2")
								NX0->(MsUnlock())
								NX0->(DbCommit())
							EndIf
						EndIf
						
						If lIntegracao
							J170GRAVA("NX0", xFilial("NX0") + cCPREFT, "4")
						EndIf
						
					EndIf

					If cTipo == '3' // Minuta de Pré-fatura
						J202HIST('3', cCPREFT, cCPART) // Emissão de minuta
					EndIf

				EndIf

				If cTipo != '2'  //1 - Fatura / 2 - Minuta de Fatura / 3 - Minuta de Pré-fatura
					JA203Apag(nNX5Recno, .T.)
				EndIf

			EndIf

		EndIf

		(cQryRes)->(Dbskip())

	EndDo

	(cQryRes)->(DbCloseArea())

	If lRet .And. Empty(cMemoLog)
		If lMinutaPre
			ApMsgInfo(STR0119 )// "Geração das Minutas concluída"
			JA203DLNX5()
			If !lAutomato
				oBrowseMidle:refresh(.T.)
				oBrowseMidle:goTop()
			EndIf
		Else
			ApMsgInfo(STR0110) // "Geração das Faturas concluída"
			oFilaExe:StartReport(lAutomato) //Verifica e abre a Thread de relatório se não estiver aberta
		EndIf
	ElseIf !lRet .Or. (lRet .And. !Empty(cMemoLog))
		If !lAutomato
			Iif(!Empty(cMemoLog), JurErrLog(cMemoLog, Iif(cTipo == '1', STR0110, STR0119)), Nil) // #
		EndIf
	EndIf

	// Exibe mensagens de erro da emissão da NF
	If !Empty(cMemoNFLog)
		If lAutomato
			JurConOut(STR0017 + cMemoNFLog) //"Erro: "
		Else
			Iif(!Empty(cMemoNFLog), JurErrLog(cMemoNFLog, Iif(cTipo == '1', STR0110, STR0119)), Nil) // #
		EndIf
	EndIf

EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203RELAT
Emite os relatórios da Fatura

@Param aParams    Parametros do relatorio
@Param cCrysExp   Diretório para recuperar os arquivos exportados do Crystal

@author David G. Fernandes
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA203RELAT(aParams, cCrysExp)
Local cParams   := ''
Local cArquivo  := STR0232 + "_(" + Trim(aParams[4]) + "-" + Trim(aParams[3]) + ")" // Relatorio_
Local lExpFSrv  := .T. //Fatura sempre Exporta  o arquivo
Local cMessage  := ''
Local cMsgRet   := ''
Local cMsgLog   := ''
Local cDestPath := JurImgFat(aParams[4], aParams[3], .T., .F., @cMsgRet)

If !Empty(cMsgRet)
	cMsgLog := "Ja203Relat--> " + cMsgRet
EndIf

cParams += aParams[3] + ';' //vpiNumFatura
cParams += aParams[4] + ';' //vpiOrganizacao
cParams += 'N' + ';'        // Conferencia
cParams += aParams[16] + ';'
cParams += aParams[15] + ';' // Utiliza Redação?

cParams += SuperGetMv('MV_JMOENAC',, '01' ) + ';' // Moeda Nacional
cParams += aParams[18] + ';'//vpcRedator
cParams += If(SuperGetMv('MV_JVINCTS ',, .T.), '1', '2') +';'

If !Empty(aParams[21])
	If (Substr(aParams[21], Len(aParams[21]), Len(aParams[21]) - 1 ) == ';')
		cParams += aParams[21]
	EndIf
EndIf

If aParams[19] == '3' // Gera relatorio de faturamento em Word"
	JCallCrys( aParams[12], cParams, aParams[1] + cArquivo, .T., .F., lExpFSrv)
	cMsgRet := ''
	If !JurMvRelat(cArquivo + ".doc", cCrysExp, cDestPath, '3', @cMsgRet) //Copia
		cMsgLog += CRLF + "Ja203Relat--> " + cMsgRet
	EndIf
EndIf

JCallCrys( aParams[12], cParams, '6;0;1;' + cArquivo, .T., .F., lExpFSrv) //Sempre gera em PDF

cMsgRet := ''
If !JurMvRelat(cArquivo + ".pdf", cCrysExp, cDestPath, aParams[19], @cMsgRet) //Arquivo, destino, 1-Imprime-2-Exibe
	cMsgLog += CRLF + "Ja203Relat--> " + cMsgRet
	If IsInCallStack("JURA204")
		cMessage := STR0237 + "-" + STR0240 + ": " + aParams[4] + "-" + aParams[3] //"Reimprimir Fatura - Gravar Relatório"
		EventInsert( FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, "055", FW_EV_LEVEL_INFO, ""/*cCargo*/, STR0238 + "-" + STR0240, cMessage, .F. ) // "Erro-Gravar Relatório"
	EndIf
	J203GrvFil("2", aParams[4], aParams[3], cArquivo + ".pdf")
EndIf

If ExistBlock('J203CRYS')
	ExecBlock('J203CRYS', .F., .F., { aParams, cParams, aParams[19] } )
EndIf

JurCrLog(cMsgLog)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203CARTA
Emite a carta da Fatura

@Param aParams    Parametros da carta
@Param cCrysExp   Diretório para recuperar os arquivos exportados do Crystal

@author David G. Fernandes
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA203CARTA(aParams, cCrysExp)
Local cParams   := ''
Local cArquivo  := STR0035 + "_(" + Trim(aParams[4]) + "-" + Trim(aParams[3]) + ")" // Carta_
Local cMessage  := ''
Local lExpFSrv  := .T. //Fatura sempre Exporta  o arquivo
Local cMsgRet   := ''
Local cMsgLog   := ''
Local cDestPath := JurImgFat(aParams[4], aParams[3], .T., .F., @cMsgRet)
Local lRetImp   := NXA->(ColumnPos("NXA_FATACU")) > 0 // @12.1.2210

If !Empty(cMsgRet)
	cMsgLog := "Ja203Carta--> " + cMsgRet
EndIf

cParams := aParams[02] + ';'	//vpiCodUser
cParams += aParams[03] + ';'	//vpiNumFatura
cParams += aParams[04] + ';'	//vpiOrganizacao
cParams += aParams[05] + ';'	//vpcNoSocioFatura
cParams += aParams[06] + ';'	//vpiCliente
cParams += aParams[07] + ';'	//vpcPreFaturaMinuta
cParams += aParams[08] + ';'	//vpcExibirLogo
cParams += aParams[09] + ';'	//vpcDadosDeposito
cParams += aParams[10] + ';'	//vpcContraApresentacao
cParams += aParams[11] + ';'	//vpcFaturaRateada
cParams += aParams[17] + ';'	//vpcAssinaturaEletron
cParams += aParams[18] + ';'	//vpcRedator
If lRetImp // @12.1.2210
	cParams += cValToChar(SuperGetMV("MV_VCPCCR", .F., "1")) + ';' // Data que será considerada para a cumulatividade do PCC (1 = Emissão / 2 = Vencto Real / 3 = Data Contab)
	cParams += SuperGetMV("MV_ACMIRPJ", .F., "1") + ';'            // Data que será considerada para a cumulatividade do IRPJ (1 = Emissão / 2 = Vencto Real / 3 = Data Contab)
	cParams += SuperGetMV("MV_ACMIRPF", .F., "1") + ';'            // Data que será considerada para a cumulatividade do IRPF (1 = Emissão / 2 = Vencto Real / 3 = Data Contab)
EndIf

If !Empty(aParams[20]) .AND. (Substr(aParams[20], Len(aParams[20]), Len(aParams[20]) - 1 ) == ';')
	cParams += aParams[20]
EndIf

If aParams[19] == '3' // Gera relatorio de faturamento em Word"
	JCallCrys( aParams[12], cParams, aParams[ 1] + cArquivo, .T., .F., lExpFSrv) //"Carta de Cobrança"
	cMsgRet := ''
	If !JurMvRelat(cArquivo + ".doc", cCrysExp, cDestPath, '3', @cMsgRet) //Copia
		cMsgLog += CRLF + "Ja203Carta--> " + cMsgRet
	EndIf
EndIf

JCallCrys( aParams[12], cParams, '6;0;1;' + cArquivo, .T., .F., lExpFSrv) //Sempre gera em PDF

cMsgRet := ''
If !JurMvRelat(cArquivo + ".pdf", cCrysExp, cDestPath, aParams[19], @cMsgRet)
	cMsgLog += CRLF + "Ja203Carta--> " + cMsgRet
	If IsInCallStack("JURA204")
		cMessage := STR0237 + "-" + STR0239 + ": " + aParams[4] + "-" + aParams[3] //"Reimprimir Fatura - Gravar Carta"
		EventInsert( FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, "055", FW_EV_LEVEL_INFO, ""/*cCargo*/, STR0238 + "-" + STR0239, cMessage, .F. ) // "Erro-Gravar carta"
	EndIf

	//Realiza a Gravação do Arquivo
	J203GrvFil("1", aParams[4], aParams[3], cArquivo + ".pdf")
EndIf

If ExistBlock('J203CRT')
	ExecBlock('J203CRT', .F., .F., { aParams, cParams, aParams[19] } )
EndIf

JurCrLog(cMsgLog)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203RECIB
Emite o Recibo da Fatura

@Param aParams    Parametros do recibo
@Param cCrysExp   Diretório para recuperar os arquivos exportados do Crystal

@author Jacques Alves Xavier
@since 22/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA203RECIB(aParams, cCrysExp)
Local cParams   := ''
Local cArquivo  := STR0042 + "_(" + Trim(aParams[4]) + "-" + Trim(aParams[3]) + ")"  // Recibo_
Local cMessage  := ''
Local lExpFSrv  := .T. //Fatura sempre Exporta  o arquivo
Local cMsgRet   := ''
Local cMsgLog   := ''
Local cDestPath := JurImgFat(aParams[4], aParams[3], .T., .F., @cMsgRet)

If !Empty(cMsgRet)
	cMsgLog := "Ja203Recib--> " + cMsgRet
EndIf

cParams := aParams[ 3] + ';'	//vpiNumFatura
cParams += aParams[ 4] + ';'	//vpiOrganizacao
cParams += aParams[ 5] + ';'	//vpcNoSocioFatura

If aParams[19] == '3' // Word
	JCallCrys( aParams[12], cParams, aParams[ 1] + cArquivo, .T., .F., lExpFSrv) //"Recibo"
	cMsgRet   := ''
	If !JurMvRelat(cArquivo+".doc", cCrysExp, cDestPath, '3', @cMsgRet) //Copia
		cMsgLog += CRLF + "Ja203Recib--> " + cMsgRet
	EndIf
EndIf

JCallCrys( aParams[12], cParams, '6;0;1;'    + cArquivo, .T., .F., lExpFSrv)

cMsgRet   := ''
If !JurMvRelat(cArquivo+".pdf", cCrysExp, cDestPath, aParams[19], @cMsgRet)
	cMsgLog += CRLF + "Ja203Recib--> " + cMsgRet
	If IsInCallStack("JURA204")
		cMessage		:= STR0237 + "-" + STR0242 +": "+ aParams[4]+"-" + aParams[3] //"Reimprimir Fatura - Gravar Recibo"
		EventInsert( FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, "055", FW_EV_LEVEL_INFO, ""/*cCargo*/, STR0238 +"-"+STR0242, cMessage, .F. ) // "Erro-Gravar Recibo"
	EndIf
	J203GrvFil("3", aParams[4], aParams[3], cArquivo + ".pdf")
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J203Filtro
Filtra os itens que serão incluídos na fila de impressão de Faturas

@Param  aIndEsp  Array contendo os dados de índices especiais, ou seja,
					não existentes no Alias.
					Ex.: Aadd(aIndEsp, {"NT1_CCLIEN+NT1_CLOJA|","Cliente + Loja"})

@author David G. Fernandes
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203Filtro(cTab, aIndEsp, cCliente, cLoja, cContrato, cTipHon, cGrClien, lAutomato)
Local aRet        := {}
Local cQry        := ""
Local dDataNac    := dDataBase + SuperGetMv('MV_JVENNAC',, 0)
Local dDataInt    := dDataBase + SuperGetMv('MV_JVENINT',, 0)
Local aFilCpo     := J203FilCpo(cTab)
Local cCampos     := JurCmpSelc(cTab, aFilCpo)
Local cCamposJL   := ''
Local aCamposJL   := {}
Local aCmpNotBrw  := {IIf(cTab == "NX0", "NX0_SITUAC", Nil)}

Default aIndEsp   := {}
Default lAutomato := .F.

//MV_JMOENAC --Moeda Nacional
//MV_JVENINT --Vencimento de faturas internacionais
//MV_JVENNAC --Vendimento de Faturas nacionais

	//Filtra os itens pendentes
	If cTab == "NX0"

		Aadd(aCamposJL,{"NS7_NOME"       , "NX0_DESCR" })
		Aadd(aCamposJL,{"NT0_NOME"       , "NX0_DCONTR"})
		Aadd(aCamposJL,{"NT0_CTPHON"     , "NX0_CTPHON"})
		Aadd(aCamposJL,{"NRA_DESC"       , "NX0_DTPHON"})
		Aadd(aCamposJL,{"RD0_P.RD0_SIGLA", "NX0_SIGLA" })
		Aadd(aCamposJL,{"RD0_P.RD0_NOME" , "NX0_DPART" })
		Aadd(aCamposJL,{"ACY_DESCRI"     , "NX0_DGRUPO"})
		Aadd(aCamposJL,{"A1_NOME"        , "NX0_DCLIEN"})
		Aadd(aCamposJL,{"NSC_DESC"       , "NX0_DSITCB"})
		Aadd(aCamposJL,{"RD0_E.RD0_NOME" , "NX0_DUSUEM"})
		Aadd(aCamposJL,{"RD0_A.RD0_NOME" , "NX0_DUSRAL"})
		Aadd(aCamposJL,{"RD0_C.RD0_NOME" , "NX0_DUSRCA"})
		Aadd(aCamposJL,{"NR1_DESC"       , "NX0_DIDIO" })
		Aadd(aCamposJL,{"NZO_DESC"       , "NX0_DRELPR"})
		cCamposJL := JurCaseJL(aCamposJL)

		//Filtra os itens que já estão na fila de geração de Faturas
		cQry := "SELECT "+ cCampos + cCamposJL
		cQry +=       " CTO_SIMB NX0_DMOEDA "
		cQry += " FROM "+ RetSqlName( 'NX0' ) + " NX0 "
		cQry +=       " LEFT JOIN "+ RetSqlName( 'CTO' ) + " CTO "
		cQry +=                                               " ON CTO.CTO_MOEDA = NX0.NX0_CMOEDA "
		cQry +=                                               " AND CTO.D_E_L_E_T_ = ' ' "
		cQry +=                                               " AND CTO.CTO_FILIAL = '" + xFilial("CTO") + "' "
		cQry +=       " LEFT JOIN "+ RetSqlName( 'NS7' ) + " NS7 "
		cQry +=                                               " ON NS7.NS7_COD = NX0.NX0_CESCR "
		cQry +=                                               " AND NS7.D_E_L_E_T_ = ' ' "
		cQry +=                                               " AND NS7.NS7_FILIAL = '" + xFilial("NS7") + "' "
		cQry +=       " LEFT JOIN "+ RetSqlName( 'NT0' ) + " NT0 "
		cQry +=                                               " ON NT0.NT0_COD = NX0.NX0_CCONTR "
		cQry +=                                               " AND NT0.D_E_L_E_T_ = ' ' "
		cQry +=                                               " AND NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
		cQry +=       " LEFT JOIN "+ RetSqlName( 'NRA' ) + " NRA "
		cQry +=                                               " ON NRA.NRA_COD = NT0.NT0_CTPHON "
		cQry +=                                               " AND NRA.D_E_L_E_T_ = ' ' "
		cQry +=                                               " AND NRA.NRA_FILIAL = '" + xFilial("NRA") + "' "
		cQry +=       " LEFT JOIN "+ RetSqlName( 'RD0' ) + " RD0_P "
		cQry +=                                               " ON RD0_P.RD0_CODIGO = NX0.NX0_CPART "
		cQry +=                                               " AND RD0_P.D_E_L_E_T_ = ' ' "
		cQry +=                                               " AND RD0_P.RD0_FILIAL = '" + xFilial("RD0") + "' "
		cQry +=       " LEFT JOIN "+ RetSqlName( 'RD0' ) + " RD0_E "
		cQry +=                                                " ON RD0_E.RD0_CODIGO = NX0.NX0_USUEMI "
		cQry +=                                                " AND RD0_E.D_E_L_E_T_ = ' ' "
		cQry +=                                                " AND RD0_E.RD0_FILIAL = '" + xFilial("RD0") + "' "
		cQry +=       " LEFT JOIN "+ RetSqlName( 'RD0' ) + " RD0_A "
		cQry +=                                                " ON RD0_A.RD0_CODIGO = NX0.NX0_USRALT "
		cQry +=                                                " AND RD0_A.D_E_L_E_T_ = ' ' "
		cQry +=                                                " AND RD0_A.RD0_FILIAL = '" + xFilial("RD0") + "' "
		cQry +=       " LEFT JOIN "+ RetSqlName( 'RD0' ) + " RD0_C "
		cQry +=                                               " ON RD0_C.RD0_CODIGO = NX0.NX0_USRCAN "
		cQry +=                                               " AND RD0_C.D_E_L_E_T_ = ' ' "
		cQry +=                                               " AND RD0_C.RD0_FILIAL = '" + xFilial("RD0") + "' "
		cQry +=       " LEFT JOIN "+ RetSqlName( 'ACY' ) + " ACY "
		cQry +=                                               " ON ACY.ACY_GRPVEN = NX0.NX0_CGRUPO "
		cQry +=                                               " AND ACY.D_E_L_E_T_ = ' ' "
		cQry +=                                               " AND ACY.ACY_FILIAL = '" + xFilial("ACY") + "' "
		cQry +=       " LEFT JOIN "+ RetSqlName( 'SA1' ) + " SA1 "
		cQry +=                                               " ON SA1.A1_COD = NX0.NX0_CCLIEN "
		cQry +=                                               " AND SA1.A1_LOJA = NX0.NX0_CLOJA "
		cQry +=                                               " AND SA1.D_E_L_E_T_ = ' ' "
		cQry +=                                               " AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
		cQry +=       " LEFT JOIN "+ RetSqlName( 'NSC' ) + " NSC "
		cQry +=                                               " ON NSC.NSC_COD = NX0.NX0_SITCB "
		cQry +=                                               " AND NSC.D_E_L_E_T_ = ' ' "
		cQry +=                                               " AND NSC.NSC_FILIAL = '" + xFilial("NSC") + "' "
		cQry +=       " LEFT JOIN "+ RetSqlName( 'NR1' ) + " NR1 "
		cQry +=                                               " ON NR1.NR1_COD = NX0.NX0_CIDIO "
		cQry +=                                               " AND NR1.D_E_L_E_T_ = ' ' "
		cQry +=                                               " AND NR1.NR1_FILIAL = '" + xFilial("NR1") + "' "
		cQry +=       " LEFT JOIN "+ RetSqlName( 'NZO' ) + " NZO "
		cQry +=                                               " ON NZO.NZO_COD = NX0.NX0_RELPRE "
		cQry +=                                               " AND NZO.D_E_L_E_T_ = ' ' "
		cQry +=                                               " AND NZO.NZO_FILIAL = '" + xFilial("NZO") + "' "

		cQry +=       " WHERE NX0.NX0_FILIAL = '" + xFilial("NX0") + "' "
		Do Case
			Case IsInCallStack('JURA202')
				cQry += " AND NX0.NX0_SITUAC IN ('2', '5', '9') "  // Análise / Emitir Minuta / minuta Sócio
			Case IsInCallStack('JURA203B')
				cQry += " AND NX0.NX0_SITUAC = '4' "  // Emitir Fatura /
		EndCase

		If !Empty(cCliente) .Or. !Empty(cLoja) .Or. !Empty(cContrato) .Or. !Empty(cTipHon) .Or. !Empty(cGrClien)
			cQry +=     " AND EXISTS (SELECT NX8.R_E_C_N_O_ "
			cQry +=                   " FROM "+ RetSqlName( 'NX8' ) + " NX8 "
			cQry +=         " INNER JOIN "+ RetSqlName( 'NT0' ) + " NT0 "
			cQry +=         " ON NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
			cQry +=                    " AND NT0.NT0_COD = NX8.NX8_CCONTR "
			cQry +=                    " AND NT0.D_E_L_E_T_ = ' ' "

			If !Empty(cGrClien)
				cQry +=                " AND NT0.NT0_CGRPCL = '" + cGrClien + "' "
			EndIf

			If !Empty(cCliente)
				cQry +=                " AND NT0.NT0_CCLIEN = '" + cCliente + "' "
			EndIf

			If !Empty(cLoja)
				cQry +=                " AND NT0.NT0_CLOJA = '" + cLoja + "' "
			EndIf

			If !Empty(cContrato)
				cQry +=     " AND NT0.NT0_COD = '" + cContrato + "' "
			EndIf

			If !Empty(cTipHon)
				cQry +=                " AND NT0.NT0_CTPHON = '" + cTipHon + "' "
			EndIf

			cQry +=                  " WHERE NX8.NX8_FILIAL = '" + xFilial("NX8") + "' "
			cQry +=         " AND NX8.NX8_CPREFT = NX0.NX0_COD "
			cQry +=                    " AND NX8.D_E_L_E_T_ = ' ')"
		EndIf
		cQry += 		" AND NX0.D_E_L_E_T_ = ' '"
		cQry += 		" AND NOT EXISTS (SELECT NX5.NX5_CPREFT "
		cQry += 							" FROM "+ RetSqlName( 'NX5' ) + " NX5 "
		cQry += 							" WHERE NX5.D_E_L_E_T_ = ' ' "
		cQry += 							  " AND NX5.NX5_FILIAL = '" + xFilial("NX5") + "' "
		cQry +=                           " AND NX5.NX5_CPREFT = NX0.NX0_COD )"

		If !IsInCallStack( 'JURA202' )  // Para gerar minuta de pré-fatura o filtro deve ser mesmo do browser da JURA202.
			If ExistBlock('J203FILT')
				cQry += ExecBlock('J203FILT', .F., .F., {cTab, cQry})
			EndIf
		EndIf

	ElseIf cTab == "NT1"

		Aadd(aCamposJL,{"NR9.NR9_COD", "NT1_DTPFTU" })
		cCamposJL := JurCaseJL(aCamposJL)

		//Filtra somente as parcelas de fixo com moeda, data de vencimento
		//de contrato com fixo, e cujo contrato não é do tipo Fixo e Hora - Mínimo (NT0_FIXEXC <> '1')

		cQry += "SELECT "+ cCampos + cCamposJL
		cQry +=         "NT0.NT0_NOME NT1_DCONTR, NT0.NT0_CCLIEN NT1_CCLIEN, NT0.NT0_CLOJA NT1_CLOJA, "
		cQry +=         "SA1.A1_NOME  NT1_DCLIEN, NT0.NT0_CTPHON NT1_CTPHON, CTO.CTO_DESC  NT1_DMOEDA "
		cQry += " FROM " + RetSqlName('NT1') + " NT1 "
		cQry +=        " INNER JOIN "+ RetSqlName( 'NT0' ) + " NT0 "
		cQry +=                                               " ON NT0.NT0_COD = NT1.NT1_CCONTR "
		cQry +=                                               " AND NT0.NT0_ATIVO = '1' "
		cQry +=                                               " AND NT0.NT0_SIT = '2' "
		cQry +=                                               " AND NT0.D_E_L_E_T_ = ' ' "
		cQry +=                                               " AND NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
		cQry +=        " INNER JOIN " + RetSqlName("NRA") + " NRA "
		cQry +=                                               " ON (NRA.NRA_FILIAL = '" + xFilial("NRA") +"' AND "
		cQry +=                                               " NRA.NRA_COD = NT0.NT0_CTPHON AND "
		cQry +=                                               " NRA.NRA_COBRAF = '1' AND "
		cQry +=                                               " NRA.D_E_L_E_T_ = ' ') "
		cQry +=       " INNER JOIN " + RetSqlName("NTH") + " NTH "
		cQry +=                                               " ON (NTH.NTH_FILIAL = '" + xFilial("NTH") +"' AND "
		cQry +=                                               " NTH.NTH_CTPHON = NRA.NRA_COD AND "
		cQry +=                                               " NTH.NTH_CAMPO = 'NT0_FXABM' AND "
		cQry +=                                               " NTH.D_E_L_E_T_ = ' ') "
		cQry +=       " INNER JOIN " + RetSqlName('SA1') + " SA1 "
		cQry +=                                               " ON  SA1.A1_COD  = NT0.NT0_CCLIEN "
		cQry +=                                               " AND SA1.A1_LOJA = NT0.NT0_CLOJA "
		cQry +=                                               " AND SA1.D_E_L_E_T_ = ' ' "
		cQry +=                                               " AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
		cQry +=       " INNER JOIN " + RetSqlName('CTO') + " CTO "
		cQry +=                                               " ON  CTO.CTO_MOEDA  = NT1.NT1_CMOEDA "
		cQry +=                                               " AND CTO.D_E_L_E_T_ = ' ' "
		cQry +=                                               " AND CTO.CTO_FILIAL = '" + xFilial("CTO") + "' "
		cQry +=       " LEFT JOIN " + RetSqlName('NR9') + " NR9 "
		cQry +=                                               " ON  NR9.NR9_COD  = NT1.NT1_CTPFTU "
		cQry +=                                               " AND NR9.D_E_L_E_T_ = ' ' "
		cQry +=                                               " AND NR9.NR9_FILIAL = '" + xFilial("NR9") + "' "
		cQry += " WHERE NT1.NT1_FILIAL = '"+ xFilial("NT1") +"' "
		cQry +=   " AND NT0.NT0_FILIAL = '"+ xFilial("NT0") +"' "
		cQry +=   " AND NT1.D_E_L_E_T_ = ' ' "
		cQry +=   " AND NT1.NT1_VALORB > 0 "
		cQry +=   " AND NT1.NT1_DATAIN <> ' ' "
		cQry +=   " AND NT0.D_E_L_E_T_ = ' ' "
		cQry +=   " AND NT0.NT0_COD = NT1.NT1_CCONTR "
		cQry +=   " AND NT0.NT0_SIT = '2' "
		cQry +=   " AND NT0.NT0_FIXEXC = '2' "
		If NT0->(ColumnPos("NT0_FIXREV")) > 0
			cQry +=   " AND NT0.NT0_FIXREV = '2' "
		EndIf
		cQry +=   " AND NT1.NT1_DATAVE <= (CASE WHEN NT0.NT0_CMOE = '" + AllTrim(SuperGetMv('MV_JMOENAC',,'01')) + "' "
		cQry += 								" THEN '" + DToS(dDataNac) + "'  "
		cQry += 								" ELSE '" + DToS(dDataInt) + "'  "
		cQry += 							"END) "
		cQry +=   " AND ( NT1.NT1_SITUAC = '1' OR EXISTS ( SELECT SUM(NXA.NXA_PERFAT) NXA_PERFAT "
		cQry +=                                            " FROM " + RetSqlName( 'NXA' ) + " NXA "
		cQry +=                                            " LEFT OUTER JOIN "+ RetSqlname('NUF') +" NUF " 
		cQry +=                                                       " ON ( NUF.NUF_FILIAL = '" + xFilial("NUF") + "' " 
		cQry +=                                                            " AND NXA.NXA_COD = NUF.NUF_CFATU " 
		cQry +=                                                            " AND NXA.NXA_CESCR = NUF.NUF_CESCR " 
		cQry +=                                                            " AND NUF.D_E_L_E_T_ = ' ') " 
		cQry +=                                           " WHERE NXA.NXA_FILIAL = '"+ xFilial("NXA") +"' "
		cQry +=                                             " AND NXA.NXA_CFIXO = NT1.NT1_SEQUEN "
	    cQry +=                                             " AND NXA.NXA_TIPO = 'FT' " 
		cQry +=                                             " AND (NXA.NXA_SITUAC = '1' " 
		cQry +=                                                  " OR (NXA_SITUAC = '2' AND NUF.NUF_SITUAC = '1' ) ) "  //Fatura de Wo Ativo
		cQry +=                                             " AND NXA.D_E_L_E_T_ = ' ' "
		cQry +=                                          " HAVING SUM(NXA.NXA_PERFAT) < 100 ) "
		cQry +=                                        " ) "
		cQry +=   " AND NT1.NT1_CPREFT = '"+ Space(TamSx3('NT1_CPREFT')[1])+ "' "
		cQry +=   " AND EXISTS ( SELECT NT0.R_E_C_N_O_  "
		cQry += 							" FROM " + RetSqlName( 'NT0' ) + " NT0 "
		cQry += 							" WHERE NT0.NT0_FILIAL = '"+ xFilial("NT0") +"' "
		cQry += 								" AND NT0.D_E_L_E_T_ = ' ' "
		cQry += 								" AND NT0.NT0_ENCH = '2' "
		cQry += 								" AND NT0.NT0_COD = NT1.NT1_CCONTR "
		cQry += 								" AND (NT0.NT0_DTVENC > '"+ Space(TamSx3('NT0_DTVENC')[1])+ "' OR  NT1.NT1_DATAVE > '"+ Space(TamSx3('NT1_DATAVE')[1])+ "') "
		cQry += 								" AND NT0.NT0_FIXEXC = '2' " //SÓ OS QUE NÃO COBRAM FIXO E EXECENTE JUNTOS
		If NT0->(ColumnPos("NT0_FIXREV")) > 0
			cQry +=                             " AND NT0.NT0_FIXREV = '2' "
		EndIf

		If !Empty(cCliente) .Or. !Empty(cLoja) .Or. !Empty(cContrato) .Or. !Empty(cTipHon) .Or. !Empty(cGrClien)
			If !Empty(cGrClien)
				cQry +=     " AND NT0.NT0_CGRPCL = '" + cGrClien + "' "
			EndIf

			If !Empty(cCliente)
				cQry +=     " AND NT0.NT0_CCLIEN = '" + cCliente + "' "
			EndIf

			If!Empty(cLoja)
				cQry +=     " AND NT0.NT0_CLOJA = '" + cLoja + "' "
			EndIf

			If !Empty(cContrato)
				cQry +=  " AND NT0.NT0_COD = '" + cContrato + "' "
			EndIf

			If !Empty(cTipHon)
				cQry +=  " AND NT0.NT0_CTPHON = '" + cTipHon + "' "
			EndIf

		EndIf

		/*Bloco criado para exibir na fila apenas as parcelas cujo contrato possui casos válidos.*/
		cQry +=                   " AND EXISTS ( SELECT NVE.R_E_C_N_O_ FROM " + RetSqlName("NVE") + " NVE, "
		cQry += 								                                 " " + RetSqlName("NUT") + " NUT "
		cQry +=                                       " WHERE NVE.NVE_FILIAL = '"+ xFilial("NVE") +"' "
		cQry +=                                         " AND NUT.NUT_FILIAL = '"+ xFilial("NUT") +"' "
 		cQry +=                                         " AND NVE.NVE_CCLIEN = NUT.NUT_CCLIEN "
		cQry +=                                         " AND NVE.NVE_LCLIEN = NUT.NUT_CLOJA "
		cQry +=                                         " AND NUT.NUT_CCONTR = NT0.NT0_COD "
		cQry +=                                         " AND NVE.NVE_ENCHON = '2' "
		cQry +=                                         " AND NVE.NVE_NUMCAS = NUT.NUT_CCASO "
		cQry +=                                         " AND NVE.D_E_L_E_T_ = ' ' "
		cQry +=                                         " AND NUT.D_E_L_E_T_ = ' ' "
		//Se não for Faixa - Qtdade de Casos - verifica regra para considerar apenas casos abertos
		cQry +=                                         " AND (CASE WHEN NTH.NTH_VISIV = '2' THEN "
		cQry +=                  			"(CASE WHEN NVE.NVE_SITUAC = '1' THEN (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) ELSE "
		cQry += 																						          							"(CASE WHEN NVE.NVE_DTENCE >= NT1.NT1_DATAIN AND NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) "
		cQry +=         		          " END) "
		cQry +=                  	" ELSE "
		//Se for Faixa - Qtdade de Casos - verifica o conteúdo dos campos NT0_FXABM e NT0_FXENCM além da situação do caso
		If SuperGetMV("MV_JQTDAUT", .F., "1") == "1" // Calcula a quantidade de casos automáticamente
			cQry +=                  			" (CASE WHEN NTH.NTH_VISIV = '1' THEN "
			cQry +=                                                    " (CASE WHEN NVE.NVE_SITUAC = '1' THEN "
			cQry +=                                                        " (CASE WHEN NT0.NT0_FXABM = '1' THEN "
			cQry +=                                                            " (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI THEN '1' ELSE '2' END) "
			cQry +=        												          														" ELSE "
			cQry +=        																		          								" (CASE WHEN NVE.NVE_DTENTR < NT1.NT1_DATAIN THEN '1' ELSE '2' END) "
			cQry += 																												          		" END) "
			cQry +=                                                     " ELSE (CASE WHEN NT0.NT0_FXABM = '1' THEN "
			cQry +=                                                              " (CASE WHEN NT0.NT0_FXENCM = '1' THEN "
			cQry +=                                                                  " (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI AND NVE.NVE_DTENCE >= NT1.NT1_DATAIN THEN '1' ELSE '2' END) "
			cQry +=																								          						    	" ELSE (CASE WHEN NVE.NVE_DTENTR <= NT1.NT1_DATAFI AND NVE.NVE_DTENCE >= NT1.NT1_DATAIN THEN '1' ELSE '2' END) "
			cQry +=																									         						    " END ) "
			cQry +=                                                           " ELSE (CASE WHEN NT0.NT0_FXENCM = '1' THEN "
			cQry +=                                                                    "(CASE WHEN NVE.NVE_DTENTR < NT1.NT1_DATAIN AND NVE.NVE_DTENCE >= NT1.NT1_DATAIN THEN '1' ELSE '2' END) "
			cQry += 																									         										   	" ELSE (CASE WHEN NVE.NVE_DTENTR < NT1.NT1_DATAIN AND NVE.NVE_DTENCE > NT1.NT1_DATAFI THEN '1' ELSE '2' END) "
			cQry += 																																		         		  " END) "
			cQry += 								         					" END) "
			cQry +=							         		" END) "
			cQry +=					        		" END) "
			cQry +=				         	"	END ) <> '2' "
		Else
			cQry +=                        " (CASE WHEN NTH.NTH_VISIV = '1' THEN (CASE WHEN NT1.NT1_QTDADE > 0 THEN '1' ELSE '2' END) END) END) <> '2' "
		EndIf
		cQry += 	  " AND NOT EXISTS ( SELECT NX5.NX5_CFIXO "
		cQry += 							" FROM "+ RetSqlName( 'NX5' ) + " NX5 "
		cQry += 							" WHERE NX5.D_E_L_E_T_ = ' ' "
		cQry += 							  " AND NX5.NX5_FILIAL = '" + xFilial("NX5") + "' "
		cQry += 							  " AND NX5.NX5_CFIXO  = NT1.NT1_SEQUEN "
		cQry +=                                                            " AND NX5.NX5_CODUSR = '"+ __CUSERID +"') "
		cQry += 					   ") "
		cQry += " ) "

		If ExistBlock('J203FILT')
			cQry += ExecBlock('J203FILT',.F.,.F.,{cTab,cQry})
		EndIf

	ElseIf cTab == "NVV"
	
		Aadd(aCamposJL,{"CTO1.CTO_SIMB"  , "NVV_DMOE1"  })
		Aadd(aCamposJL,{"CTO2.CTO_SIMB"  , "NVV_DMOE2"  })
		Aadd(aCamposJL,{"CTO4.CTO_SIMB"  , "NVV_DMOE4"  })
		Aadd(aCamposJL,{"NS7.NS7_NOME"   , "NVV_DESCR"  })
		Aadd(aCamposJL,{"NT0.NT0_NOME"   , "NVV_DCONTR" })
		Aadd(aCamposJL,{"RD0.RD0_SIGLA"  , "NVV_SIGLA1" })
		Aadd(aCamposJL,{"RD0.RD0_NOME"   , "NVV_DPART1" })
		Aadd(aCamposJL,{"ACY.ACY_DESCRI" , "NVV_DGRUPO" })
		Aadd(aCamposJL,{"SA1.A1_NOME"    , "NVV_DCLIEN" })
		Aadd(aCamposJL,{"NR1.NR1_DESC"   , "NVV_DIDIO1" })
		Aadd(aCamposJL,{"NR9.NR9_DESC"   , "NVV_DTPFAT" })
		cCamposJL := JurCaseJL(aCamposJL)

		//Filta somente as parcelas de fatura adicional pendentes
		//com data de vencimento e moeda da fatura preenchidos
		//cujos contratos não fazem parte de juntção de contratos
		cQry += "SELECT "+ cCampos + cCamposJL
		cQry +=         " CTO3.CTO_SIMB NVV_DMOE3 "
		cQry +=" FROM " + RetSqlName( 'NVV' ) + "  NVV "
		cQry +=       " LEFT JOIN "+ RetSqlName( 'CTO' ) + " CTO1 "
		cQry +=                                               " ON  CTO1.CTO_MOEDA = NVV.NVV_CMOE1 "
		cQry +=                                               " AND CTO1.D_E_L_E_T_ = ' ' "
		cQry +=                                               " AND CTO1.CTO_FILIAL = '" + xFilial("CTO") + "' "
		cQry +=       " LEFT JOIN "+ RetSqlName( 'CTO' ) + " CTO2 "
		cQry +=                                               " ON  CTO2.CTO_MOEDA = NVV.NVV_CMOE2 "
		cQry +=                                               " AND CTO2.D_E_L_E_T_ = ' ' "
		cQry +=                                               " AND CTO2.CTO_FILIAL = '" + xFilial("CTO") + "' "
		cQry +=       " INNER JOIN "+ RetSqlName( 'CTO' ) + " CTO3 "
		cQry +=                                               " ON  CTO3.CTO_MOEDA = NVV.NVV_CMOE3 "
		cQry +=                                               " AND CTO3.D_E_L_E_T_ = ' ' "
		cQry +=                                               " AND CTO3.CTO_FILIAL = '" + xFilial("CTO") + "' "
		cQry +=       " LEFT JOIN "+ RetSqlName( 'CTO' ) + " CTO4 "
		cQry +=                                               " ON  CTO4.CTO_MOEDA = NVV.NVV_CMOE4 "
		cQry +=                                               " AND CTO4.D_E_L_E_T_ = ' ' "
		cQry +=                                               " AND CTO4.CTO_FILIAL = '" + xFilial("CTO") + "' "
		cQry +=       " LEFT JOIN "+ RetSqlName( 'NS7' ) + " NS7 "
		cQry +=                                               " ON  NS7.NS7_COD = NVV.NVV_CESCR "
		cQry +=                                               " AND NS7.D_E_L_E_T_ = ' ' "
		cQry +=                                               " AND NS7.NS7_FILIAL = '" + xFilial("NS7") + "' "
		cQry +=       " INNER JOIN "+ RetSqlName( 'NT0' ) + " NT0 "
		cQry +=                                               " ON  NT0.NT0_FILIAL = '" + xFilial("NT0") + "'"
		cQry +=                                               " AND NT0.NT0_COD = NVV.NVV_CCONTR  "
		cQry +=                                               " AND NT0.NT0_ATIVO = '1' "
		cQry +=                                               " AND NT0.NT0_SIT = '2' "
		cQry +=                                               " AND NT0.D_E_L_E_T_ = ' ' "
		cQry +=       " LEFT JOIN "+ RetSqlName( 'RD0' ) + " RD0 "
		cQry +=                                               " ON  RD0.RD0_CODIGO = NVV.NVV_CPART1 "
		cQry +=                                               " AND RD0.D_E_L_E_T_ = ' ' "
		cQry +=                                               " AND RD0.RD0_FILIAL = '" + xFilial("RD0") + "' "
		cQry +=       " LEFT JOIN "+ RetSqlName( 'ACY' ) + " ACY "
		cQry +=                                               " ON ACY.ACY_GRPVEN = NVV.NVV_CGRUPO "
		cQry +=                                               " AND ACY.D_E_L_E_T_ = ' ' "
		cQry +=                                               " AND ACY.ACY_FILIAL = '" + xFilial("ACY") + "' "
		cQry +=       " LEFT JOIN "+ RetSqlName( 'SA1' ) + " SA1 "
		cQry +=                                               " ON  SA1.A1_COD  = NVV.NVV_CCLIEN "
		cQry +=                                               " AND SA1.A1_LOJA = NVV.NVV_CLOJA "
		cQry +=                                               " AND SA1.D_E_L_E_T_ = ' ' "
		cQry +=                                               " AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
		cQry +=       " LEFT JOIN "+ RetSqlName( 'NR1' ) + " NR1 "
		cQry +=                                               " ON  NR1.NR1_COD    = NVV.NVV_CIDIO1 "
		cQry +=                                               " AND NR1.D_E_L_E_T_ = ' ' "
		cQry +=                                               " AND NR1.NR1_FILIAL = '" + xFilial("NR1") + "' "
		cQry +=       " LEFT JOIN " + RetSqlName('NR9') + " NR9 "
		cQry +=                                               " ON  NR9.NR9_COD  = NVV.NVV_CTPFAT "
		cQry +=                                               " AND NR9.D_E_L_E_T_ = ' ' "
		cQry +=                                               " AND NR9.NR9_FILIAL = '" + xFilial("NR9") + "' "

		cQry +=    " WHERE NVV.NVV_FILIAL = '"+ xFilial("NVV") +"' "
		cQry +=    " AND NVV.D_E_L_E_T_ = ' ' "

		If !Empty(cCliente) .or. !Empty(cLoja) .or. !Empty(cContrato) .or. !Empty(cGrClien)
			If !Empty(cGrClien)
				cQry +=     " AND NVV.NVV_CGRUPO = '" + cGrClien + "' "
			EndIf

			If !Empty(cCliente)
				cQry +=     " AND NVV.NVV_CCLIEN = '" + cCliente + "' "
			EndIf

			If !Empty(cLoja)
				cQry +=     " AND NVV.NVV_CLOJA = '" + cLoja + "' "
			EndIf

			If !Empty(cContrato)
				cQry +=     " AND NVV.NVV_CCONTR = '" + cContrato + "' "
			EndIf

		EndIf

		If NVV->(ColumnPos("NVV_MSBLQL")) > 0 // Proteção
			cQry +=         " AND NVV.NVV_MSBLQL <> '1' " // Campo de bloqueio da fatura adicional
		EndIf

		cQry += 	" AND (NVV.NVV_SITUAC = '1' "
		cQry += 		  " OR EXISTS ( SELECT NXG.NXG_CFATAD "
		cQry += 						" FROM " +RetSqlName( 'NXG' )+ " NXG "
		cQry += 						" WHERE NXG.D_E_L_E_T_ = ' ' "
		cQry += 						  " AND NXG.NXG_FILIAL = '"+ xFilial("NXG") +"' "
		cQry += 						  " AND NXG.NXG_CFATAD = NVV.NVV_COD "
		cQry += 						  " AND NXG.NXG_CFATUR = '"+ Space(TamSx3('NXG_CFATUR')[1])+ "' "
		cQry += 						  " AND NXG.NXG_CESCR = '"+ Space(TamSx3('NXG_CESCR')[1])+ "' "
		cQry += 					  ") "
		cQry += 		  ") "
		cQry += 	" AND NVV.NVV_CPREFT = '"+ Space(TamSx3('NVV_CPREFT')[1])+ "' "
		cQry += 	" AND NVV.NVV_DTBASE > '"+ Space(TamSx3('NVV_DTBASE')[1])+ "' "
		cQry += 	" AND NVV.NVV_DTBASE <= (CASE WHEN NVV.NVV_CMOE3 = '" + AllTrim(SuperGetMv('MV_JMOENAC',,'01')) + "' "
		cQry += 							    " THEN '" + DToS(dDataNac) + "' "
		cQry += 								" ELSE '" + DToS(dDataInt) + "' "
		cQry +=                             " END) "
		cQry += 	" AND NOT EXISTS (SELECT NX5.NX5_CFATAD "
		cQry += 						" FROM "+ RetSqlName( 'NX5' ) + " NX5 "
		cQry += 						" WHERE NX5.D_E_L_E_T_ = ' ' "
		cQry += 						  " AND NX5.NX5_FILIAL = '" + xFilial("NX5") + "' "
		cQry += 						  " AND NX5.NX5_CFATAD = NVV.NVV_COD "
		cQry += 						  " AND NX5.NX5_CODUSR = '"+ __CUSERID +"' "
		cQry += 					 ") "

		If ExistBlock('J203FILT')
			cQry += ExecBlock('J203FILT',.F.,.F.,{cTab,cQry})
		EndIf

	Else
		Return .F.
	EndIf

	aRet := JurCriaTmp(GetNextAlias(), cQry, cTab, aIndEsp, , , aCmpNotBrw)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203DESC
Retorna as descrições para os campos virtuais utilizados na rotina

@author David G. Fernandes
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA203DESC( cCampo )
Local cRet   := ""
Local cClien := ""
Local cLoja  := ""
Local cTpHon := ""

Do Case
Case 'NT1_DCONTR' $ cCampo
	cRet := JurGetDados('NT0', 1, xFilial('NT0') + NT1->NT1_CCONTR, 'NT0_NOME')
Case 'NT1_CCLIEN' $ cCampo
	cRet := JurGetDados('NT0', 1, xFilial('NT0') + NT1_CCONTR, 'NT0_CCLIEN')
Case 'NT1_CLOJA' $ cCampo
	cRet := JurGetDados('NT0', 1, xFilial('NT0') + NT1_CCONTR, 'NT0_CLOJA')
Case 'NT1_DCLIEN' $ cCampo
	cClien := JurGetDados('NT0', 1, xFilial('NT0') + NT1_CCONTR, 'NT0_CCLIEN')
	cLoja  := JurGetDados('NT0', 1, xFilial('NT0') + NT1_CCONTR, 'NT0_CLOJA')
	cRet   := GetAdvfVal("SA1", "A1_NOME", xFilial("SA1") + cClien + cLoja, 1)
Case 'NT1_CTPHON' $ cCampo
	cRet := JurGetDados('NT0', 1, xFilial('NT0') + NT1->NT1_CCONTR, 'NT0_CTPHON')
Case 'NT1_DTPHON' $ cCampo
	cTpHon := JurGetDados('NT0', 1, xFilial('NT0') + NT1->NT1_CCONTR, 'NT0_CTPHON')
	cRet   := JurGetDados('NRA', 1, xFilial('NRA') + cTpHon, 'NRA_DESC')
Case 'NX7_DCLIEN'  $ cCampo
	cRet := JurGetDados("SA1", 1, xFilial("SA1") + NX7->NX7_CCLIEN+NX7->NX7_CLOJA, "A1_NOME" )
Case 'NX7_DCASO'  $ cCampo
	cRet := JurGetDados("NVE", 1, xFilial("NVE") + NX7->NX7_CCLIEN + NX7->NX7_CLOJA + NX7->NX7_CCASO, "NVE_TITULO" )
Case 'NX5_TEMADI'  $ cCampo
	If J203ADIANT(NX5->NX5_CCLIEN, NX5->NX5_CLOJA, NX5->NX5_CESCR)
		cRet := STR0101 // "Sim"
	Else
		cRet := STR0102 // "Não"
	EndIf
Otherwise
	cRet := ""
EndCase

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203COTPF
Grava as cotaçoes da moedas usadas na pré-fatura na fila de emissão
de fatura.

@author David G. Fernandes
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA203COTPF(cPreFat, cFila)
Local aArea     := GetArea()
Local aRet      := {.T., "JA203COTPF"}
Local nCotac    := 0
Local dDtEmit   := CToD( '  /  /  ' )
Local cMoedaNac := SuperGetMv('MV_JMOENAC',, '01')
Local cCotSuger := SuperGetMv('MV_JCOTSUG',, '1') // cotação sugerida na fila de emissão: 1=Cotação da Data de emissão da fatura; 2=Cotação da pré-fatura
Local a203G     := {}

If !Empty(cPreFat)
	NXR->(DbSetOrder(1))
	NXR->(DbGoTop())
	If NXR->(DbSeek( xFilial("NXR") + cPreFat))

		While NXR->NXR_CPREFT == cPreFat

			NX6->( dbSetOrder( 1 ) )
			If !( NX6->( dbSeek(xFilial('NX6') + cFila + NXR->NXR_CMOEDA ) ) ) //se não tem a cotação da moeda, inclui

				If cCotSuger == '1' //Cotação da Data de emissão da fatura
					If NXR->NXR_ALTCOT == '2' .And. aRet[1] == .T. // Se a cotação não foi alterada pelo usuário ou canc de Fatura, é atualiza para a data de emissão da fatura.
						a203G := JURA203G( 'FT', Date(), 'FATEMI'  )
						If a203G[2] == .T.
							dDtEmit := a203g[1]
						Else
							aRet    := {.F., "JA203COTPF"}
						EndIf
						If aRet[1] == .T.
							dDtEmit := JURA203G( 'FT', Date(), 'FATEMI' )[1]
							nCotac  := JA201FConv(cMoedaNac, NXR->NXR_CMOEDA, 1000, '1', dDtEmit)[2]
						EndIf
					Else
						nCotac := NXR->NXR_COTAC
					EndIf
				Else
					nCotac := NXR->NXR_COTAC
				EndIf

				If aRet[1] == .T.
					RecLock("NX6", .T.)
					NX6->NX6_FILIAL := xFilial('NX6')
					NX6->NX6_CFILA  := cFila
					NX6->NX6_CMOEDA := NXR->NXR_CMOEDA
					NX6->NX6_COTAC1 := nCotac
					NX6->NX6_ORIGEM := NXR->NXR_ORIGEM
					NX6->(MsUnLock())
					NX6->(DbCommit())
				EndIf
			EndIf

			NXR->(DbSkip())

		EndDo

		While __lSX8
			ConfirmSX8()
		EndDo

	Else
		aRet := {.F., "JA203COTPF"}
	EndIf

EndIf

RestArea( aArea )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203CotFat()
Retorna as moedas e cotações de lançamentos viculados posteriormente a emissão 
da fatura de pré-fatura ou de parcela de fixo.

@param   cCodPre   Codigo da pré-fatura 
@param   cCodFixo  Codigo da parcela de fixo
@param   aCotac    Array com as cotaçoes para encrementar

@return  aCotac    Array com a moeda e cotação adicionadas posteriormente

@author Luciano Pereira dos Santos
@since 09/11/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203CotFat(cCodPre, cCodFixo, aCotac)
	Local aArea      := GetArea()
	Local cQryRes    := GetNextAlias()
	Local cQry       := ""

	Default cCodPre  := ""
	Default cCodFixo := ""
	Default aCotac   := {}

	cQry := "SELECT DISTINCT NXF.NXF_CMOEDA, NXF.NXF_COTAC1 "
	cQry += " FROM " + RetSqlName( 'NXA' ) + " NXA, "
	cQry +=      " " + RetSqlName( 'NXF' ) + " NXF  "
	cQry +=   " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") + "' "
	cQry +=     " AND NXF.NXF_FILIAL = '" + xFilial("NXF") + "' "
	cQry +=     " AND NXF.NXF_CFATUR = NXA.NXA_COD "
	cQry +=     " AND NXF.NXF_CESCR = NXA.NXA_CESCR "
	If !Empty(cCodFixo)
		cQry += " AND NXA.NXA_CFIXO = '" + cCodFixo + "' "
	EndIf
	If !Empty(cCodPre)
		cQry += " AND NXA.NXA_CPREFT = '" + cCodPre + "' "
	EndIf
	cQry +=     " AND NOT EXISTS (SELECT NX6.R_E_C_N_O_ "
	cQry +=                      " FROM " + RetSqlName( 'NX6' ) + " NX6 "
	cQry +=                     " WHERE NX6.NX6_FILIAL = '" + xFilial("NX6") + "' "
	cQry +=                       " AND NX6.NX6_CMOEDA = NXF.NXF_CMOEDA "
	cQry +=                       " AND NX6.D_E_L_E_T_ = ' ') "
	cQry +=     " AND NXA.NXA_SITUAC = '1' "
	cQry +=     " AND NXA.D_E_L_E_T_ = ' ' "
	cQry +=     " AND NXF.D_E_L_E_T_ = ' ' "

	cQry := ChangeQuery(cQry, .F.)
	DbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry), cQryRes, .T., .T.)

	While !(cQryRes)->(EOF())
		If (aScan(aCotac, {|x| x[1] == (cQryRes)->NXF_CMOEDA}) == 0)
			aAdd( aCotac, {(cQryRes)->NXF_CMOEDA, (cQryRes)->NXF_COTAC1 } )
		EndIf
		(cQryRes)->(dbSkip())
	EndDo

	(cQryRes)->( dbCloseArea() )

	RestArea( aArea )

Return aCotac

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203COTPG
Retorna as moedas da cotação dos pagadores da pré-fatura

@author Luciano Pereira dos Santos
@since 14/02/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA203COTPG( cCodPre )
Local aRet      := {}
Local aArea     := GetArea()
Local aResult   := {}
Local cMoedaNac := SuperGetMv('MV_JMOENAC',,'01')
Local dDtEmit   := CToD( '  /  /  ' )

If !Empty(cCodPre)
	DbselectArea("NXG")
	NXG->(DbSetOrder(2)) //NXG_FILIAL+NXG_CPREFT+NXG_CLIPG+NXG_LOJAPG+NXG_CFATAD

	If NXG->(DbSeek( xFilial("NXG") + cCodPre ))
		dDtEmit := JURA203G( 'FT', Date(), 'FATEMI' )[1]

		While xFilial("NXG") + NXG->NXG_CPREFT == xFilial("NXG") + cCodPre
			If cMoedaNac != NXG->NXG_CMOE
				aResult  := JA201FConv(cMoedaNac, NXG->NXG_CMOE, 1000, "1", dDtEmit)
				aAdd( aRet, {NXG->NXG_CMOE, aResult[2] } )
			EndIf
			NXG->(DbSkip())
		EndDo

	EndIf

	aRet := J203CotFat(cCodPre, , aRet)

EndIf

RestArea( aArea )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203COTTS
Retorna as moedas com a cotação atual dos time-sheets no período

@author David G. Fernandes
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA203COTTS( cContrato, cCliente, cLoja, dDataIni, dDataFim, cMoedaFat, dTEmit )
Local aRet      := {}
Local aArea     := GetArea()
Local cCmd2     := ''
Local cQryRes2  := GetNextAlias()
Local aResult   := {}
Local cEscr     := ''
Local cFil      := ''
Local cJuncao   := ''

cJuncao := JurGetDados('NW3', 2, xFilial('NW3') + cContrato, 'NW3_CJCONT' )
If Empty(cJuncao)
	cEscr := JurGetDados('NT0', 1, xFilial('NT0') + cContrato, 'NT0_CESCR')
Else
	cEscr := JurGetDados('NW2', 1, xFilial('NW2') + cJuncao, 'NW2_CESCR')
EndIf
cFil    := JurGetDados('NS7', 1, xFilial('NS7') + cEscr, 'NS7_CFILIA' )

cCmd2 := " SELECT NTV.NTV_CMOEDA "
cCmd2 +=   " FROM "+ RetSqlName( 'NUE' ) + " NUE, "+ RetSqlName( 'NUU' ) + " NUU, "
cCmd2 +=        " "+ RetSqlName( 'NTV' ) + " NTV "
cCmd2 +=   " WHERE NUE.D_E_L_E_T_ = ' ' "
cCmd2 +=     " AND NUU.D_E_L_E_T_ = ' ' "
cCmd2 +=     " AND NTV.D_E_L_E_T_ = ' ' "
cCmd2 +=     " AND NUE.NUE_FILIAL =  '"+ xFilial("NUE") +"' "
cCmd2 +=     " AND NUU.NUU_FILIAL =  '"+ xFilial("NUU") +"' "
cCmd2 +=     " AND NTV.NTV_FILIAL =  '"+ xFilial("NTV") +"' "
cCmd2 +=     " AND NUE.NUE_SITUAC = '1' "
cCmd2 +=     " AND NUE.NUE_CPREFT = '" + Space(TamSx3('NUE_CPREFT')[1]) + "' "
cCmd2 +=     " AND NUE.NUE_CCLIEN = '" + cCliente + "' "
cCmd2 +=     " AND NUE.NUE_CLOJA  = '" + cLoja + "' "
cCmd2 +=     " AND NUE.NUE_DATATS BETWEEN '" + dtos(dDataIni) +"' AND '" + dtos(dDataFim) +"' "
cCmd2 +=     " AND EXISTS ( SELECT NUT.R_E_C_N_O_ "
cCmd2 +=                             " FROM "+ RetSqlName( 'NUT' ) + " NUT "
cCmd2 +=                             " WHERE NUT.NUT_FILIAL = '"+ xFilial("NUT") +"' "
cCmd2 +=                             " AND NUT.D_E_L_E_T_ = ' ' "
cCmd2 +=                             " AND NUT.NUT_CCLIEN = NUE.NUE_CCLIEN "
cCmd2 +=                             " AND NUT.NUT_CLOJA  = NUE.NUE_CLOJA "
cCmd2 +=                             " AND NUT.NUT_CCASO = NUE.NUE_CCASO "
cCmd2 +=                             " AND NUT.NUT_CCONTR = '"+cContrato + "') "
cCmd2 +=     " AND NUU.NUU_CCLIEN = NUE.NUE_CCLIEN "
cCmd2 +=     " AND NUU.NUU_CLOJA = NUE.NUE_CLOJA "
cCmd2 +=     " AND NUU.NUU_CCASO = NUE.NUE_CCASO "
cCmd2 +=     " AND ((SUBSTRING(NUE.NUE_DATATS,1,6) >= NUU.NUU_AMINI AND NUU.NUU_AMFIM = '"+ Space(TamSx3('NUU_AMFIM')[1])+"' ) OR "
cCmd2 +=          " (SUBSTRING(NUE.NUE_DATATS,1,6) BETWEEN NUU.NUU_AMINI AND NUU.NUU_AMFIM)) "
cCmd2 +=     " AND NTV.NTV_CTAB = NUU.NUU_CTABH "
cCmd2 +=     " AND ((SUBSTRING(NUE.NUE_DATATS,1,6) >= NTV.NTV_AMINI AND NTV.NTV_AMFIM = '"+ Space(TamSx3('NTV_AMFIM')[1])+"' ) OR    "
cCmd2 +=          " (SUBSTRING(NUE.NUE_DATATS,1,6) BETWEEN NTV.NTV_AMINI AND NTV.NTV_AMFIM)) "
cCmd2 += " GROUP BY NTV.NTV_CMOEDA "

cCmd2 := ChangeQuery(cCmd2, .F.)
dbUseArea(.T., "TOPCONN", TcGenQry(,, cCmd2), cQryRes2, .T., .T.)
(cQryRes2)->(dbgoTop())

While !(cQryRes2)->(EOF())

	If cMoedaFat <> (cQryRes2)->NTV_CMOEDA //Moeda das Despeas diferente da fatura
		aResult := JA201FConv(cMoedaFat, (cQryRes2)->NTV_CMOEDA, 1000, "1", dTEmit , "", cContrato, cFil )

		If !Empty(aResult)
			aadd(aRet, { (cQryRes2)->NTV_CMOEDA, aResult[2], aResult[3] } )
		EndIf
	EndIf

	(cQryRes2)->(dbSkip())

EndDo

(cQryRes2)->( dbCloseArea() )
RestArea( aArea )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203COTDP
Retorna as moedas com a cotação atual das despesas do período

@author David G. Fernandes
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA203COTDP(cContrato, cCliente, cLoja, dDataIni, dDataFim, cMoedaFat, dDtEmit)
Local aRet      := {}
Local aArea     := GetArea()
Local cCmd2     := ''
Local cQryRes2  := GetNextAlias()
Local aResult   := {}
Local cEscr     := ''
Local cFil      := ''
Local cJuncao   := ''

cJuncao := JurGetDados('NW3', 2, xFilial('NW3') + cContrato, 'NW3_CJCONT')
If Empty(cJuncao)
	cEscr := JurGetDados('NT0', 1, xFilial('NT0') + cContrato, 'NT0_CESCR')
Else
	cEscr := JurGetDados('NW2', 1, xFilial('NW2') + cJuncao, 'NW2_CESCR')
EndIf
cFil      := JurGetDados('NS7', 1, xFilial('NS7') + cEscr, 'NS7_CFILIA' )

cCmd2 := " SELECT NVY.NVY_CMOEDA "
cCmd2 +=      " FROM " + RetSqlName( 'NVY' ) + " NVY "
cCmd2 +=     " WHERE NVY.D_E_L_E_T_ = ' ' "
cCmd2 +=       " AND NVY.NVY_FILIAL = '" + xFilial("NVY") +"' "
cCmd2 +=       " AND NVY.NVY_SITUAC = '1' "
cCmd2 +=       " AND NVY.NVY_CPREFT = '" + Space(TamSx3('NVY_CPREFT')[1]) + "' "
cCmd2 +=       " AND NVY.NVY_CCLIEN = '" + cCliente + "' "
cCmd2 +=       " AND NVY.NVY_CLOJA  = '" + cLoja + "' "
cCmd2 +=       " AND NVY.NVY_DATA BETWEEN '" + DToS(dDataIni) + "' AND '" + DToS(dDataFim) +"' "
cCmd2 +=       " AND EXISTS ( SELECT NUT.R_E_C_N_O_ "
cCmd2 +=                      " FROM " + RetSqlName( 'NUT' ) + " NUT "
cCmd2 +=                     " WHERE NUT.NUT_FILIAL = '"+ xFilial("NUT") +"' "
cCmd2 +=                       " AND NUT.D_E_L_E_T_ = ' ' "
cCmd2 +=                       " AND NUT.NUT_CCLIEN = NVY.NVY_CCLIEN "
cCmd2 +=                       " AND NUT.NUT_CLOJA  = NVY.NVY_CLOJA "
cCmd2 +=                       " AND NUT.NUT_CCASO = NVY.NVY_CCASO "
cCmd2 +=                       " AND NUT.NUT_CCONTR = '" + cContrato + "') "
cCmd2 += " GROUP BY NVY.NVY_CMOEDA "

cCmd2 := ChangeQuery(cCmd2, .F.)
dbUseArea(.T., "TOPCONN", TcGenQry(,, cCmd2), cQryRes2, .T., .T.)
(cQryRes2)->(dbgoTop())

While !(cQryRes2)->(EOF())

	If cMoedaFat <> (cQryRes2)->NVY_CMOEDA //Moeda das Despeas diferente da fatura
		aResult := JA201FConv(cMoedaFat, (cQryRes2)->NVY_CMOEDA, 1000, "1", dDtEmit, "", cContrato, cFil )

		If !Empty(aResult)
			Aadd(aRet, { (cQryRes2)->NVY_CMOEDA, aResult[2], aResult[3] } )
		EndIf
	EndIf

	(cQryRes2)->(dbSkip())

EndDo

(cQryRes2)->( dbCloseArea() )
RestArea( aArea )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203COTTB
Retorna as moedas com a cotação atual dos tabelados do período

@author David G. Fernandes
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA203COTTB(cContrato, cCliente, cLoja, dDataIni, dDataFim, cMoedaFat, dDtEmit)
Local aRet      := {}
Local aArea     := GetArea()
Local cCmd2     := ''
Local cQryRes2  := GetNextAlias()
Local aResult   := {}
Local cEscr     := ''
Local cFil      := ''
Local cJuncao   := ''

cJuncao := JurGetDados('NW3', 2, xFilial('NW3') + cContrato, 'NW3_CJCONT' )
If Empty(cJuncao)
	cEscr := JurGetDados('NT0', 1, xFilial('NT0') + cContrato, 'NT0_CESCR')
Else
	cEscr := JurGetDados('NW2', 1, xFilial('NW2') + cJuncao, 'NW2_CESCR')
EndIf
cFil      := JurGetDados('NS7', 1, xFilial('NS7') + cEscr, 'NS7_CFILIA' )

cCmd2 := " SELECT NV4.NV4_CMOEH, NV4.NV4_CMOED "
cCmd2 +=    " FROM " + RetSqlName( 'NV4' ) + " NV4 "
cCmd2 +=     " WHERE NV4.NV4_FILIAL = '"+ xFilial("NV4") +"' "
cCmd2 +=       " AND NV4.D_E_L_E_T_ = ' ' "
cCmd2 +=       " AND NV4.NV4_SITUAC = '1' "
cCmd2 +=       " AND NV4.NV4_CPREFT = '" + Space(TamSx3('NV4_CPREFT')[1]) + "' "
cCmd2 +=       " AND NV4.NV4_CCLIEN = '" + cCliente + "' "
cCmd2 +=       " AND NV4.NV4_CLOJA  = '" + cLoja + "' "
cCmd2 +=       " AND NV4.NV4_DTLANC BETWEEN '" + DToS(dDataIni) + "' AND '" + DToS(dDataFim) + "' "
cCmd2 +=       " AND EXISTS ( SELECT NUT.R_E_C_N_O_ "
cCmd2 +=                     " FROM " + RetSqlName( 'NUT' ) + " NUT "
cCmd2 +=                           " WHERE NUT.NUT_FILIAL = '"+ xFilial("NUT") +"' "
cCmd2 +=                             " AND NUT.D_E_L_E_T_ = ' ' "
cCmd2 +=                             " AND NUT.NUT_CCLIEN = NV4.NV4_CCLIEN "
cCmd2 +=                             " AND NUT.NUT_CLOJA  = NV4.NV4_CLOJA "
cCmd2 +=                             " AND NUT.NUT_CCASO  = NV4.NV4_CCASO "
cCmd2 +=                             " AND NUT.NUT_CCONTR =  '" + cContrato + "') "
cCmd2 +=  " GROUP BY NV4.NV4_CMOEH, NV4.NV4_CMOED "

cCmd2 := ChangeQuery(cCmd2, .F.)
dbUseArea(.T., "TOPCONN", TcGenQry(,, cCmd2), cQryRes2, .T., .T.)
(cQryRes2)->(dbgoTop())

While !(cQryRes2)->(EOF())

	If (cMoedaFat <> (cQryRes2)->NV4_CMOEH) .And. (aScan( aRet, { |aX| aX[1] == (cQryRes2)->NV4_CMOEH } ) == 0)	//Moeda das Despeas diferente da fatura
		aResult := JA201FConv(cMoedaFat, (cQryRes2)->NV4_CMOEH, 1000, "1", dDtEmit, "", cContrato, cFil )

		If !Empty(aResult)
			aadd(aRet, { (cQryRes2)->NV4_CMOEH, aResult[2], aResult[3] } )
		EndIf

	EndIf

	If !Empty((cQryRes2)->NV4_CMOED) .And. (cMoedaFat <> (cQryRes2)->NV4_CMOED) .And. (aScan( aRet, { |aX| aX[1] == (cQryRes2)->NV4_CMOED } ) == 0)	//Moeda das Despeas diferente da fatura
		aResult := JA201FConv(cMoedaFat, (cQryRes2)->NV4_CMOED, 1000, "1", dDtEmit, "", cContrato, cFil )

		If !Empty(aResult)
			aadd(aRet, { (cQryRes2)->NV4_CMOED, aResult[2], aResult[3] } )
		EndIf

	EndIf

	(cQryRes2)->(dbSkip())

EndDo

(cQryRes2)->( dbCloseArea() )
RestArea( aArea )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203COTLC
Retorna as moedas com a cotação atual dos lançamentos do período

@Params lForce  Força a mudança da origem da cotação existente para o tipo 2 = Lançamento.
									Usado apenas para despesas na emissão direto pela fila junto com o fixo.

@author David G. Fernandes
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA203COTLC(cFila, lTs, lDesp, lTab, cContrato, cCliente, cLoja, dDataIni, dDataFim, cMoedaFat, lForce)
Local aResult   := {}
Local aArea     := GetArea()
Local dDtEmit   := JURA203G( 'FT', Date(), 'FATEMI' )[1]

Default lForce  := .F.

If lTs
	aResult := JA203COTTS( cContrato, cCliente, cLoja, ;
	                       dDataIni, dDataFim, cMoedaFat, dDtEmit )
	If !Empty(aResult)
		JA203INNX6(cFila, aResult )
	EndIf
EndIf

If lDesp
	aResult := JA203COTDP( cContrato, cCliente, cLoja, ;
	                       dDataIni, dDataFim, cMoedaFat, dDtEmit )
	If !Empty(aResult)
		JA203INNX6(cFila, aResult, "2", lForce )
	EndIf
EndIf

If lTab
	aResult := JA203COTTB( cContrato, cCliente, cLoja, ;
	                       dDataIni, dDataFim, cMoedaFat, dDtEmit )
	If !Empty(aResult)
		JA203INNX6(cFila, aResult)
	EndIf
EndIf

RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203INNX6
Grava as cotações na tabela NX6.

@author David G. Fernandes
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA203INNX6(cFila, aCotac, cOrigem, lForce)
Local ni         := 0
Local aArea      := GetArea()
Local oModel     := Nil
Local oModelNX6  := Nil
Local lMoeda     := .F.
Local nY         := 0
Local nSavLine   := 0
Local lUsaModel  := .F.
Local cMoeda     := ""
Local nCotac     := 0

Default lForce   := .F.
Default cOrigem  := "2"

For ni := 1 To Len(aCotac)

	cMoeda := aCotac[ni][1]
	nCotac := aCotac[ni][2]
	lMoeda := .F.

	If !Empty(oModel := FWModelActive(, .T.))
		If oModel:lActivate .And. oModel:GetID() $ "JURA202|JURA203"
			lUsaModel := .T.
		EndIf
	EndIf

	If !lUsaModel
		NX6->( dbSetOrder( 1 ) )
		If !( NX6->( dbSeek(xFilial('NX6') + cFila + cMoeda ) ) ) //se não incluiu, inclui
			RecLock("NX6", .T.)
			NX6->NX6_FILIAL := xFilial('NX6')
			NX6->NX6_CFILA  := cFila
			NX6->NX6_CMOEDA := cMoeda
			NX6->NX6_COTAC1 := nCotac
			NX6->NX6_ORIGEM := cOrigem
			NX6->(MsUnLock())
			NX6->(DbCommit())

			If __lSX8
				ConfirmSX8()
			EndIf

		ElseIf lForce //Força a gravação da cotação com origem de lanç. (usado em situações multipayer de fixo com despesas onde trata-se de cotação de lanç e de pag)

			RecLock("NX6", .F.)
			NX6->NX6_ORIGEM := cOrigem
			NX6->(MsUnLock())
			NX6->(DbCommit())

			If __lSX8
				ConfirmSX8()
			EndIf

		EndIf
	Else
		oModelNX6 := oModel:GetModel("NX6DETAIL")

		For nY := 1 To oModelNX6:GetQtdLine()
			If oModelNX6:GetValue("NX6_CMOEDA", nY) == cMoeda .And. !oModelNX6:IsDeleted(nY)
				lMoeda := .T.
				Exit
			EndIf
		Next nY

		If !lMoeda
			nSavLine  := oModelNX6:GetLine()
			If !oModelNX6:IsEmpty()
				oModelNX6:AddLine(.T.)
			EndIf
			oModelNX6:LoadValue('NX6_CFILA' , cFila )
			oModelNX6:LoadValue('NX6_CMOEDA', cMoeda )
			oModelNX6:LoadValue('NX6_DMOEDA', JurGetDados('CTO', 1, xFilial('CTO') + cMoeda, 'CTO_SIMB' ) )
			oModelNX6:LoadValue('NX6_COTAC1', nCotac )
			oModelNX6:LoadValue('NX6_ORIGEM', "1" )
			oModelNX6:GoLine( nSavLine )
		ElseIf lForce
			oModelNX6:LoadValue('NX6_ORIGEM', cOrigem )
			oModelNX6:GoLine( nSavLine )
		EndIf
	EndIf

Next ni

RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203DTREF
Retorna as moedas com a cotação atual dos tabelados do período

@author David G. Fernandes
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA203DTREF( cCampo )
	Local lRet        := .T.
	Local cFila       := NX5->NX5_COD
	Local lTs         := (NX5->NX5_TS  == '1')
	Local lDesp       := (NX5->NX5_DES == '1')
	Local lTab        := (NX5->NX5_TAB == '1')
	Local cContrato   := NX5->NX5_CCONTR
	Local cCliente    := NX5->NX5_CCLIEN
	Local cLoja       := NX5->NX5_CLOJA
	Local cMoedaFat   := NX5->NX5_CMOEFT
	Local dDataIni
	Local dDataFim

	If Empty(NX5->NX5_CPREFT)
		If (cCampo == 'NX5_DREFIH' .OR. cCampo == 'NX5_DREFFH') .AND. lTs
			dDataIni := M->NX5_DREFIH
			dDataFim := M->NX5_DREFFH
			If dDataIni > dDataFim
				lRet := JurMsgErro(STR0067) //"A Data Final deve ser maior do que a Final"
			Else
				JA203COTLC(cFila, lTs, .F., .F., cContrato, cCliente, cLoja, dDataIni, dDataFim, cMoedaFat )
			EndIf
		EndIf

		If (cCampo == 'NX5_DREFID' .OR. cCampo == 'NX5_DREFFD' ) .AND. lDesp
			dDataIni := M->NX5_DREFID
			dDataFim := M->NX5_DREFFD
			If dDataIni > dDataFim
				lRet := JurMsgErro(STR0067) //"A Data Final deve ser maior do que a Final"
			Else
				JA203COTLC(cFila, .F., lDesp, .F., cContrato, cCliente, cLoja, dDataIni, dDataFim, cMoedaFat )
			EndIf
		EndIf

		If (cCampo == 'NX5_DREFIT' .OR. cCampo == 'NX5_DREFFT') .AND. lTab
			dDataIni := M->NX5_DREFIT
			dDataFim := M->NX5_DREFFT
			If dDataIni > dDataFim
				lRet := JurMsgErro(STR0067) //"A Data Final deve ser maior do que a Final"
			Else
				JA203COTLC(cFila, .F., .F., lTab, cContrato, cCliente, cLoja, dDataIni, dDataFim, cMoedaFat )
			EndIf
		EndIf

	Else
		lRet := JurMsgErro(STR0054) //"Não é possível alterar a Referência de Pré-Fatura"
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203DLNX5
Limpa a Fila de Geração de Faturas do usuário conectado

@author David G. Fernandes
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA203DLNX5()
	Local aArea     := GetArea()
	Local cCmd2     := ''
	Local cQryRes2  := GetNextAlias()

	cCmd2 := " SELECT NX5.R_E_C_N_O_  NX5RECNO "
	cCmd2 +=   " FROM "+ RetSqlName( 'NX5' ) + " NX5 "
	cCmd2 +=  " WHERE NX5.D_E_L_E_T_ = ' ' "
	cCmd2 +=    " AND NX5.NX5_FILIAL = '" + xFilial("NX5") + "' "
	cCmd2 +=    " AND NX5.NX5_CODUSR = '" + __CUSERID + "' "

	cCmd2 := ChangeQuery(cCmd2, .F.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cCmd2),cQryRes2,.T.,.T.)
	(cQryRes2)->(dbgoTop())

	If !(cQryRes2)->(EOF())
		While !(cQryRes2)->(EOF())
			JA203Apag((cQryRes2)->NX5RECNO)
			(cQryRes2)->(dbSkip())
		EndDo
	EndIf

	(cQryRes2)->( dbCloseArea() )

	RestArea( aArea )

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203VLDIN
Valida se a pré-fatura, parcela adicional ou fixa
 pode ser incluída na fila de geração de faturas

@Param @cCodigo - código do item da Fila
				@cTipo - tipo do Item: 'PF' - Pré-Fatura
				                       'FX' - Fixo
				                       'FA' - Fatura Adicional

@author David G. Fernandes
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA203VLDIN( cContr, cCodigo, cTipo, cMarca, lAutomato )
Local lRet       := .T.
Local aArea      := GetArea()
Local aAreaNUH   := NUH->( GetArea() )
Local cCliente   := ''
Local cLoja      := ''
Local cCaso      := ''
Local cEscrit    := ''
Local cMoeda     := ''
Local aEmiteF    := {}
Local cCEmp      := ''
Local cEmiteF    := ''
Local cParcela   := ''
Local cCmd2      := ''
Local cCmd3      := ''
Local cQryRes2   := GetNextAlias()
Local cQryRes3   := GetNextAlias()
Local cCodJunc   := ''
Local aCliente   := {}
Local nPercenNX0 := 0
Local nValorH    := 0
Local nValorDesc := 0
Local nValorD    := 0
Local nNX0VLRHFA := 0
Local nNX0VLRDFA := 0
Local cContrato  := ""
Local aNX0       := {}
Local aNT0       := {}
Local aNVV       := {}
Local lPEVlDin   := ExistBlock("J203VLIN")
Local aRetPE	 := {}

Default lAutomato := .F.

Do Case
Case cTipo == 'PF'
	aNX0 := JurGetDados('NX0', 1, xFilial('NX0') + cCodigo, ;
	        {'NX0_CESCR', 'NX0_CMOEDA', 'NX0_CJCONT', 'NX0_PERFAT', 'NX0_VLFATH', 'NX0_DESCON', 'NX0_VLFATD', 'NX0_VLRHFA', 'NX0_VLRDFA'})

	If !Empty(aNX0)
		cEscrit    := aNX0[1] //JurGetDados('NX0',1,xFilial('NX0')+cCodigo, 'NX0_CESCR')
		cMoeda     := aNX0[2] //JurGetDados('NX0',1,xFilial('NX0')+cCodigo, 'NX0_CMOEDA')
		cCodJunc   := aNX0[3] //JurGetDados('NX0',1,xFilial('NX0')+cCodigo, 'NX0_CJCONT')
		nPercenNX0 := aNX0[4] //JurGetDados('NX0',1,xFilial('NX0')+cCodigo,'NX0_PERFAT')
		nValorH    := aNX0[5] //JurGetDados('NX0',1,xFilial('NX0')+cCodigo,'NX0_VLFATH')
		nValorDesc := aNX0[6] //JurGetDados('NX0',1,xFilial('NX0')+cCodigo,'NX0_DESCON')
		nValorD    := aNX0[7] //JurGetDados('NX0',1,xFilial('NX0')+cCodigo,'NX0_VLFATD')
		nNX0VLRHFA := aNX0[8] //JurGetDados('NX0',1,xFilial('NX0')+cCodigo,'NX0_VLRHFA')
		nNX0VLRDFA := aNX0[9] //JurGetDados('NX0',1,xFilial('NX0')+cCodigo,'NX0_VLRDFA')
	EndIf

	aNT0 := JurGetDados('NT0', 1, xFilial('NT0') + cContr, {'NT0_CCLIEN', 'NT0_CLOJA'})
	If !Empty(aNT0)
		cCliente  := aNT0[1] //JurGetDados('NT0',1,xFilial('NT0')+cContr, 'NT0_CCLIEN')
		cLoja     := aNT0[2] //JurGetDados('NT0',1,xFilial('NT0')+cContr, 'NT0_CLOJA')
	EndIf

	If nPercenNX0 > 0 .And. nPercenNX0 < 100

		If !( ((nValorH - nValorDesc) * (0.01 * nPercenNX0)) == nNX0VLRHFA .And. ((nValorD) * (0.01 * nPercenNX0)) == nNX0VLRDFA )
			lRet := JurMsgErro(STR0151+"(Cod: " + AllTRim(cCodigo) + ")") // "Valores da fatura cancelada foram alterados. Verifique!"
		EndIf
	EndIf
	cStrTipo := STR0055 //"Pré-Fatura"

	If lRet
		lRet :=J203VldCasRev(cCodigo)
	EndIf

Case cTipo == 'FA'
	aNVV := JurGetDados('NVV', 1, xFilial('NVV') + cCodigo, {'NVV_CESCR', 'NVV_CMOE3', 'NVV_PARC', 'NVV_CCLIEN', 'NVV_CLOJA'})
	If !Empty(aNVV)
		cEscrit   := aNVV[1] //JurGetDados('NVV',1,xFilial('NVV')+cCodigo, 'NVV_CESCR')
		cMoeda    := aNVV[2] //JurGetDados('NVV',1,xFilial('NVV')+cCodigo, 'NVV_CMOE3')
		cParcela  := aNVV[3] //JurGetDados('NVV',1,xFilial('NVV')+cCodigo, 'NVV_PARC')
		cCliente  := aNVV[4] //JurGetDados('NVV',1,xFilial('NVV')+cCodigo, 'NVV_CCLIEN')
		cLoja     := aNVV[5] //JurGetDados('NVV',1,xFilial('NVV')+cCodigo, 'NVV_CLOJA')
	EndIf

	cStrTipo  := STR0057 //"Fatura Adicional"
Case cTipo == 'FX'
	aNT0 := JurGetDados('NT0', 1, xFilial('NT0') + cContr, {'NT0_CESCR', 'NT0_CMOEF', 'NT0_CCLIEN', 'NT0_CLOJA'})
	If !Empty(aNT0)
		cEscrit   := aNT0[1] //JurGetDados('NT0',1,xFilial('NT0')+cContr,  'NT0_CESCR')
		cMoeda    := aNT0[2] //JurGetDados('NT0',1,xFilial('NT0')+cContr,  'NT0_CMOEF')
		cCliente  := aNT0[3] //JurGetDados('NT0',1,xFilial('NT0')+cContr,  'NT0_CCLIEN')
		cLoja     := aNT0[4] //JurGetDados('NT0',1,xFilial('NT0')+cContr,  'NT0_CLOJA')
	EndIf
	cParcela  := JurGetDados('NT1', 1, xFilial('NT1') + cCodigo, 'NT1_PARC')
	cStrTipo  := STR0056 // "Fixo"
OtherWise
	cMsg := STR0068 //"Tipo Inválido"
	lRet := JurMsgErro( cMsg )
EndCase

If lRet

	//Validar Escritório Emite Fat - NS7
	aEmiteF := JurGetDados('NS7', 1, xFilial('NS7') + cEscrit + cMoeda, {'NS7_EMITEF', 'NS7_CEMP'} )
	cEmiteF := aEmiteF[1]
	cCEmp   := aEmiteF[2]

	If cEmiteF == '2'
		cMsg := STR0069 + CRLF // "O escritório não permite a emissão de Faturas:"
		cMsg := cMsg + STR0070 + " (" + cStrTipo + ") " + STR0271 + cEscrit + " - " + cCodigo + " - " + cContr + CRLF  //"Escritório - Código ( tipo do cod)" " - Contrato "
		lRet := JurMsgErro( cMsg )
	EndIf

	//Valida se a empresa do escritório é a mesma que o usuário está logado
	If lRet .And. cCEmp != cEmpAnt
		cMsg := STR0269 + " (" + FWEmpName(cEmpAnt) + ")" + STR0270 + CRLF // "Só é permitido faturar os registros relacionados a empresa atual " "! Verifique o escritório de faturamento do Contrato/Junção de Contratos."
		cMsg := cMsg + STR0070 + " (" + cStrTipo + ") " + STR0271 + cEscrit + " - " + cCodigo + " - " + cContr + CRLF  //"Escritório - Código ( tipo do cod)" " - Contrato "
		lRet := JurMsgErro( cMsg )
	EndIf

	If lRet
		//Validar Moeda bloqueada - NTN
		dbSelectArea( 'NTN' )
		NTN->(dbSetOrder( 4 ))
		If NTN->(dbSeek( xFilial('NTN') + cEscrit + cMoeda ))
			cMsg := STR0071 +  CRLF // "O escritório não permite a emissão de Faturas:"
			cMsg := cMsg + STR0072 + " ( " + cStrTipo + "): " + cEscrit + " - " + cCodigo + CRLF  //"Moeda - Código ( tipo do cod): "
			lRet := JurMsgErro( cMsg )
		EndIf
	EndIf

	If lRet .And. cTipo == 'FX'

		cCmd3 := "SELECT COUNT(NUT_CCONTR) QUANT "
		cCmd3 +=   " FROM " + RetSqlName( 'NUT' ) + " NUT "
		cCmd3 +=   " WHERE NUT.D_E_L_E_T_ = ' ' "
		cCmd3 +=     " AND NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
		cCmd3 +=     " AND NUT.NUT_CCONTR = '" + cContr + "' "

		cCmd3 := ChangeQuery(cCmd3, .F.)
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cCmd3), cQryRes3, .T., .T.)

		While !(cQryRes3)->( EOF() )
			If (cQryRes3)->QUANT = 0
				lRet := JurMsgErro( STR0188 ) //Não existe caso para este contrato. Verifique.
			EndIf
			(cQryRes3)->( dbSkip() )
		End
		(cQryRes3)->( dbCloseArea() )

	EndIf

	If lRet .And. cTipo == 'PF'

		cCmd2 := "SELECT NXG.NXG_CLIPG, NXG.NXG_LOJAPG "
		cCmd2 +=    " FROM " + RetSqlName( 'NXG' ) + " NXG "
		cCmd2 +=   " WHERE NXG.NXG_FILIAL = '" + xFilial("NXG") + "' "
		cCmd2 +=     " AND NXG.NXG_CPREFT  = '" + cCodigo + "' "
		cCmd2 +=     " AND NXG.D_E_L_E_T_ = ' ' "

		aCliente := JurSQL(cCmd2, {"NXG_CLIPG", "NXG_LOJAPG"})

		lRet := J203ValEnd(aCliente, lAutomato)

	EndIf

	//Verificar Parcelas Ateriores
	If lRet .AND. !(cTipo == 'PF')
		If cTipo == 'FA'
			cCmd2 := "SELECT MIN( NVV.NVV_COD ) COD, MIN( NVV.NVV_PARC ) PARC"
			cCmd2 += 		" FROM "+ RetSqlName( 'NVV' ) + " NVV "
			cCmd2 += 		" WHERE NVV.D_E_L_E_T_ = ' ' "
			cCmd2 += 		  " AND NVV.NVV_FILIAL = '" + xFilial("NVV") + "' "
			cCmd2 += 		  " AND NVV.NVV_PARC > '"+Space(TamSx3('NVV_PARC')[1])+"' "
			cCmd2 += 		  " AND NVV.NVV_CCLIEN = '" + cCliente + "' "
			cCmd2 += 		  " AND NVV.NVV_CLOJA  = '" + cLoja + "' "
			cCmd2 += 		  " AND NVV.NVV_OK <> '" + cMarca + "' "
			cCmd2 += 		  " AND NVV.NVV_SITUAC = '1' "
			cCmd2 += 		  " AND NOT EXISTS ( SELECT NX5.R_E_C_N_O_ "
			cCmd2 += 								" FROM "+ RetSqlName( 'NX5' ) + "  NX5 "
			cCmd2 += 								" WHERE NX5.D_E_L_E_T_ = ' ' "
			cCmd2 += 								  " AND NX5.NX5_FILIAL = '" + xFilial("NX5") + "' "
			cCmd2 += 								  " AND NX5.NX5_CFATAD = NVV.NVV_COD "
			cCmd2 += 						  " ) "

		ElseIf cTipo == 'FX'
			cCmd2 := "SELECT MIN(NT1.NT1_SEQUEN ) COD, MIN(NT1.NT1_PARC ) PARC "
			cCmd2 += 		" FROM "+ RetSqlName( 'NT1' ) + " NT1 "
			cCmd2 += 		" WHERE NT1.D_E_L_E_T_ = ' ' "
			cCmd2 += 		  " AND NT1.NT1_FILIAL = '" + xFilial("NT1") + "' "
			cCmd2 += 		  " AND NT1.NT1_PARC  > '"+Space(TamSx3('NT1_PARC')[1])+"' "
			cCmd2 += 		  " AND NT1.NT1_CCONTR = '" + cContr + "' "
			cCmd2 += 		  " AND NT1.NT1_OK <> '" + cMarca + "' "
			cCmd2 += 		  " AND NOT EXISTS ( SELECT NX5.R_E_C_N_O_ "
			cCmd2 += 							" FROM "+ RetSqlName( 'NX5' ) + "  NX5 "
			cCmd2 += 							" WHERE NX5.D_E_L_E_T_ = ' ' "
			cCmd2 += 							  " AND NX5.NX5_FILIAL = '" + xFilial("NX5") + "' "
			cCmd2 += 							  " AND NX5.NX5_CFIXO = NT1.NT1_SEQUEN "
			cCmd2 += 						  " ) "

		EndIf

		cCmd2 := ChangeQuery(cCmd2, .F.)
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cCmd2), cQryRes2, .T., .T.)

		If !Empty( (cQryRes2)->PARC) .AND. (cQryRes2)->PARC < cParcela
			cMsg := STR0076 +  CRLF // "Existe Parcelas anteriores não faturadas, deseja incluir a parcela abaixo na fila assim mesmo?"
			If cTipo == 'FA'
				cContrato := JurGetDados("NVV", 1, xFilial("NVV") + (cQryRes2)->COD + (cQryRes2)->PARC, "NVV_CCONTR")

				cMsg := cMsg + STR0075 + "( " + cStrTipo + " ): " + cContrato + ' - ' + (cQryRes2)->COD + CRLF  //"Parcela - Código ( tipo do cod): xxxx - yyyy "
			Else
				If cTipo == 'FX'
					cContrato := JurGetDados("NT1", 1, xFilial("NT1") + (cQryRes2)->COD + (cQryRes2)->PARC, "NT1_CCONTR")

					cMsg := cMsg + STR0075 + "( " + cStrTipo + " ): " + cContrato + ' - ' + (cQryRes2)->COD + CRLF  //"Parcela - Código ( tipo do cod): xxxx - yyyy "
				Else
					cMsg := cMsg + STR0200 + "( " + cStrTipo + " ): " + cCliente + ' - ' + cLoja + ' - ' + cCaso + ' - ' + (cQryRes2)->COD + CRLF  // Cód. Cliente - Cód. Loja - Cód. Caso - Parcela
				EndIf
			EndIf
			If ExistBlock('J203PARC')
				lRet := ExecBlock('J203PARC', .F., .F., { cTipo, (cQryRes2)->COD, (cQryRes2)->PARC } )
			EndIf
			If !lRet
				lRet := ApMsgYesNo( cMsg  ) //"Existe Parcelas anteriores não faturadas, deseja incluir a parcela abaixo na fila assim mesmo?"
			EndIf
		EndIf
		(cQryRes2)->( dbCloseArea() )

	EndIf
	If lRet .And. lPEVlDin
		aRetPE := ExecBlock('J203VLIN', .F., .F., {cContr, cCodigo, cTipo})
		cMsg := ""
		If ValType(aRetPE) == "A" .And. Len(aRetPE) == 2
			lRet := IIF(ValType(aRetPE[1]) == "L", aRetPE[1], .F.)
			cMsg := IIF(ValType(aRetPE[2]) == "C", aRetPE[2], "")
		Else
			lRet := .F.
			cMsg := STR0299  // "Retorno inválido no ponto de entrada 'J203VLIN'. Consulte a documentação."
		EndIf
		If !lRet .And. !Empty(cMsg)
			JurMsgErro( cMsg )
		EndIf
	EndIf
EndIf

RestArea(aAreaNUH)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203INEND
Abre a tela para completar o endereço do cliente.

@author David G. Fernandes
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA203INEND(cClien, cLoja, lAutomato)
Local lRet      := .F.
Local aArea     := GetArea()
Local oDlg      := Nil
Local cA1END    := CriaVar( 'A1_END', .F. )
Local cA1EST    := CriaVar( 'A1_EST', .F. )
Local cA1CEP    := CriaVar( 'A1_CEP', .F. )
Local cA1PAIS   := CriaVar( 'A1_PAIS', .F. )
Local cA1CGC    := CriaVar( 'A1_CGC', .F. )
Local cA1TIPO   := CriaVar( 'A1_TIPO', .F. )
Local cA1NOME   := CriaVar( 'A1_NOME', .F. )
Local cNUHENDI  := CriaVar( 'NUH_ENDI', .F. )
Local cA1Pessoa := CriaVar( 'A1_PESSOA', .F. )
Local oGetEnd
Local oGetEst
Local oGetPai
Local oGetCEP
Local oGetCGC
Local oGetCli
Local oGetLoja
Local oGetNome

Private A1_COD    := ""
Private A1_LOJA   := ""

Default lAutomato := .F.

dbSelectArea('SA1')
SA1->( dbSetOrder(1) )
If SA1->( dbSeek(xFilial("SA1") + cClien + cLoja	) )
	NUH->( dbSetOrder(1) )
	NUH->( dbSeek(xFilial("NUH") + cClien + cLoja	) )

	cA1END    := SA1->A1_END
	cA1EST    := SA1->A1_EST
	cA1PAIS   := SA1->A1_PAIS
	cA1CEP    := SA1->A1_CEP
	cA1CGC    := SA1->A1_CGC
	cA1NOME   := SA1->A1_NOME
	cA1TIPO   := SA1->A1_TIPO
	cA1Pessoa := SA1->A1_PESSOA
	cNUHENDI  := NUH->NUH_ENDI

	If lAutomato
		cA1PAIS := '105'
		lRet    := J203GRVCPO(cClien, cLoja, cA1TIPO,cNUHENDI,cA1END,cA1EST,cA1CEP,cA1PAIS,cA1CGC,cA1Pessoa)
	Else
		DEFINE MSDIALOG oDlg TITLE STR0078 FROM 300,300 TO 650,620  PIXEL //"Completar Endereço"

		@ 005,005 Say STR0121 Size 030,008 PIXEL OF oDlg //Cliente
		@ 013,005 MsGet oGetCli Var cClien When .F. Size 030,009 PIXEL OF oDlg

		@ 005,060 Say STR0122 Size 030,008 PIXEL OF oDlg //Loja
		@ 013,060 MsGet oGetLoja Var cLoja When .F. Size 020,009 PIXEL OF oDlg

		@ 025,005 Say STR0123 Size 150,008 PIXEL OF oDlg //Razão Social
		@ 033,005 MsGet oGetNome Var cA1NOME When .F. Size 150,009 PIXEL OF oDlg

		@ 045,005 Say alltrim(RETTITLE('A1_END')) Size 030,008 PIXEL OF oDlg //"Endereço"
		@ 053,005 MsGet oGetEnd Var cA1END When Empty(cA1END).or.Empty(SA1->A1_END)  Size 150,009 PIXEL OF oDlg

		@ 065,005 Say alltrim(RETTITLE('A1_EST') ) Size 030,008 PIXEL OF oDlg //"Estado"
		@ 073,005 MsGet oGetEst Var cA1EST  When Empty(cA1EST).or.Empty(SA1->A1_EST) Valid  (Empty(cA1EST) .Or. ExistCpo('SX5','12'+ cA1EST)) F3 '12'  HasButton Size 030,009 PIXEL OF oDlg

		@ 065,060 Say alltrim(RETTITLE('A1_PAIS')) Size 030,008  PIXEL OF oDlg //"País"
		@ 073,060 MsGet oGetPai Var cA1PAIS When Empty(cA1PAIS).or.Empty(SA1->A1_PAIS) Valid (Empty(cA1PAIS) .Or. ExistCPO('SYA', cA1PAIS)) F3 'SYA' HasButton Size 030,009 PIXEL OF oDlg

		@ 085,005 Say alltrim(RETTITLE('A1_CEP')) Size 040,008  PIXEL OF oDlg //"CEP"
		@ 093,005 MsGet oGetCEP Var cA1CEP When Empty(cA1CEP).or.Empty(SA1->A1_CEP) Picture '@R 99999-999' Size 040,009 PIXEL OF oDlg

		@ 085,060 Say alltrim(RETTITLE('A1_CGC')) Size 060,008  PIXEL OF oDlg //"CGC"
		@ 093,060 MSGet oGetCGC Var cA1CGC When Empty(cA1CGC).or.Empty(SA1->A1_CGC) .or. !J203TpPess(cA1Pessoa,cA1CGC,.F.);
			HasButton Picture '@R 99.999.999/9999-99' Size 060,009 PIXEL OF oDlg

		oGetCGC:PictVar := PicPes(SA1->A1_PESSOA)

		@ 105,005 Say alltrim(RETTITLE('NUH_ENDI')) Size 030,008 PIXEL OF oDlg //"Endereço Internac"
		@ 113,005 Get oGetEndI  Var cNUHENDI When Empty(cNUHENDI) Memo  Size 150,039 PIXEL OF oDlg

		If cA1TIPO == 'X'
			oGetEndI:Enable()
			oGetEnd:Disable()
			oGetEst:Disable()
			oGetPai:Disable()
			oGetCEP:Disable()
			oGetCGC:Disable()
		Else
			oGetEndI:Disable()
			oGetEnd:Enable()
			oGetEst:Enable()
			oGetPai:Enable()
			oGetCEP:Enable()
			oGetCGC:Enable()
		EndIf

		@ 160,080 Button STR0192 Size 037,012 PIXEL OF oDlg  ;
			Action ( lRet := J203GRVCPO(cClien, cLoja, cA1TIPO,cNUHENDI,cA1END,cA1EST,cA1CEP,cA1PAIS,cA1CGC,cA1Pessoa) ,;
			Iif(lRet, oDlg:End(), ) ) //"Ok"

		@ 160,120 Button STR0084 Size 037,012 PIXEL OF oDlg  Action  (lRet := .F. , oDlg:End()) //"Cancelar"

		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf

Else
	lRet := JurMsgErro( STR0087 + " ('" + cClien +" / " + cLoja + " ) ") //"Cliente / Loja Inválidos:"
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203TpPess()
Rotina para Validar se o CNPJ/CPF condiz com o tipo de pesssoa

@Params 	cTipPes 	Condição de pagamento
			cCNPJ		CNPJ/CPF
			lExibe		Exibe Mesagem de erro

@author Luciano Pereira dos Santos
@since 21/03/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203TpPess(cTipPes,cCNPJ,lExibe)
Local lRet := .T.

If cTipPes == "F" .AND. !(Len(AllTrim(cCNPJ)) == 11)
	lRet := .F.
ElseIf cTipPes == "J" .AND. !(Len(AllTrim(cCNPJ)) == 14)
	lRet := .F.
EndIf

If lRet
	lRet := CGC(cCNPJ,, lExibe)
Else
	If lExibe
		lRet := A030CGC(cTipPes, cCNPJ)
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203GRVCPO
Grava os campos da tela de correção de endereço

@author David G. Fernandes
@since 24/02/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203GRVCPO(cClien, cLoja, cA1TIPO, cNUHENDI, cA1END, cA1EST, cA1CEP, cA1PAIS, cA1CGC, cA1Pessoa)
Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaSA1 := SA1->(GetArea())
Local aAreaNUH := NUH->(GetArea())

If (cA1TIPO == 'X' .AND. Empty( cNUHENDI ))
	lRet := JurMsgErro(STR0085 + " - " + Alltrim(RetTitle('NUH_ENDI')) + " ('NUH_ENDI')", STR0085 )  //"Campo obrigatório"

ElseIf (cA1TIPO != 'X')

	If Empty(cA1END)
		lRet := JurMsgErro(STR0085 + " - " + Alltrim(RetTitle('A1_END')) + " ('A1_END')", STR0085 )  //"Campo obrigatório"
	EndIf

	If lRet .and. Empty(cA1EST)
		lRet := JurMsgErro( STR0085 + " - " + Alltrim(RetTitle('A1_EST') ) + "( A1_EST)" , STR0085 ) //"Campo obrigatório"
	EndIf

	If lRet .and. Empty(cA1PAIS)
		lRet := JurMsgErro( STR0085 + " - " + Alltrim(RetTitle('A1_PAIS')) + " (A1_PAIS)", STR0085 ) //"Campo obrigatório"
	EndIf

	If lRet .and. Empty(cA1CEP)
		lRet := JurMsgErro( STR0085  + " - " +  Alltrim(RetTitle('A1_CEP')) + " (A1_CEP)", STR0085) //"Campo obrigatório"
	EndIf

	If lRet
		If Empty(cA1CGC)
			lRet := JurMsgErro( STR0085 + " - " + Alltrim(RetTitle('A1_CGC')) + " (A1_CGC)", STR0085 ) //"Campo obrigatório"
		Else
			lRet := J203TpPess(cA1Pessoa, cA1CGC, .T.)
		EndIf
	EndIf

EndIf

If lRet
	If cA1TIPO == 'X'
		dbSelectArea('NUH')
		NUH->( dbSetOrder(1) )
		If NUH->( dbSeek(xFilial("NUH") + cClien + cLoja ) )
			Reclock('NUH',.F.)
			NUH->NUH_ENDI  := cNUHENDI
			NUH->(MsUnLock())
			NUH->(DbCommit())
		EndIf
	Else
		dbSelectArea('SA1')
		SA1->( dbSetOrder(1) )
		If SA1->( dbSeek(xFilial("SA1") + cClien + cLoja ) )
			Reclock('SA1',.F.)
			SA1->A1_END    := cA1END
			SA1->A1_EST    := cA1EST
			SA1->A1_CEP    := cA1CEP
			SA1->A1_PAIS   := cA1PAIS
			SA1->A1_CGC    := cA1CGC
			SA1->(MsUnLock())
			SA1->(DbCommit())
		EndIf
	EndIf
	//Grava na fila de sincronização
	J170GRAVA("SA1", xFilial("SA1") + cClien + cLoja, "4")
EndIf

RestArea( aArea )
RestArea( aAreaSA1 )
RestArea( aAreaNUH )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203HABCPO
Habilita os campos conforme o tipo de da fatura

@author David G. Fernandes
@since 08/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203HABCPO(cCampos)
Local lRet := .F.

cCampos := AllTrim(cCampos)

Do Case
	Case cCampos == "NX5_DSPFIX"
		lRet := !Empty(NX5->NX5_DSPFIX)

	Case cCampos $ "NX5_DREFIH|NX5_DREFFH|NX5_DREFIT|NX5_DREFFT"
		lRet := !Empty(NX5->NX5_CEXITO)

	Case cCampos $ "NX5_DREFID|NX5_DREFFD"
		lRet := !Empty(NX5->NX5_CEXITO) .Or. Iif(NX5->(FieldPos('NX5_DSPFIX')) > 0, M->NX5_DSPFIX == '1', .F.)

	Case cCampos $ "NX5_VLFATD"
		lRet := .F.

	Case cCampos == "NX5_CALDIS"
		lRet := !Empty(NX5->NX5_VLFATH)

	Case cCampos == "NX5_DESCH"
		lRet := Empty(NX5->NX5_ACRESH) .And. Empty(NX5->NX5_PACREH) .And. Empty(NX5->NX5_CPREFT)

	Case cCampos == "NX5_PDESCH"
		lRet := Empty(NX5->NX5_ACRESH) .And. Empty(NX5->NX5_PACREH) .And. Empty(NX5->NX5_CPREFT)

	Case cCampos == "NX5_ACRESH"
		lRet := .F.

	Case cCampos == "NX5_PACREH"
		lRet := .F.

	OtherWise
		lRet := .F.
EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203VENCLI
Retorna a data de vencimento do cliente

@Params 	cCond 	Condição de pagamento
			cMoeda  Código da Moeda da Fatura
			dParc	Data da Parcela

@author David G. Fernandes
@since 08/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203VENCLI(cCond, cMoeda, dParc)
Local cDataAgend := SuperGetMv('MV_JDTAGEN',, .F.)
Local cMoedaNac  := SuperGetMv('MV_JMOENAC',, 01)
Local nQdtDiaInt := SuperGetMv('MV_JVENINT',, 30)
Local nQdtDiaNac := SuperGetMv('MV_JVENNAC',, 30)
Local cCndPgInt  := SuperGetMv('MV_JCPGINT')
Local cCndPgNac  := SuperGetMv('MV_JCPGNAC')
Local dVencFat   := CToD( '  /  /  ' )
Local aParcHon   := {}
Local dtEmisao   := JURA203G( 'FT', Date(), 'FATEMI' )[1]

Default dParc    := CToD( '  /  /  ' )

If cDataAgend .And. !Empty(dParc)
	dVencFat := dParc
Else
	If Empty(cCond)
		If cMoeda == cMoedaNac
			cCond := cCndPgNac
		Else
			cCond := cCndPgInt
		EndIf
	EndIf

	dbSelectArea('SE4')
	aParcHon := Condicao( 1000, cCond,, dtEmisao )

	If Len(aParcHon) > 0
		dVencFat := aParcHon[1][1]
	EndIf
EndIf

If Empty(dVencFat)
	If cMoeda == cMoedaNac
		dVencFat := msDate() + nQdtDiaNac
	Else
		dVencFat := msDate() + nQdtDiaInt
	EndIf
EndIf

Return dVencFat

//-------------------------------------------------------------------
/*/{Protheus.doc} J203ADIANT
Retorna para validar se o cliente possui adiantamentos gerados pelo PFS

@Params cClien 	Código do Cliente
		cLoja	Código da Loja

@author David G. Fernandes
@since 08/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203ADIANT( cCliente, cLoja, cEscrit )
Local lRet       := .F.
Local aArea      := GetArea()
Local aAreaNS7   := NS7->( GetArea() )
Local cCmd2      := ""
Local cQryRes2   := GetNextAlias()
Local cTpAdiant  := SuperGetMv('MV_JADTTP',, 'RA')
Local cFiliaLNS7 := ""

	If !Empty(cCliente) .And. !Empty(cLoja) .And. !Empty(cEscrit)

		cFiliaLNS7 := JurGetDados('NS7', 1, xFilial('NS7') + cEscrit, 'NS7_CFILIA')

		cCmd2 := " SELECT COALESCE(SUM(SE1.E1_SALDO),0) SALDO "
		cCmd2 +=   " FROM " + RetSQLName("SE1") + " SE1, "
		cCmd2 +=        " " + RetSqlName('NWF') + " NWF "
		cCmd2 +=   " WHERE SE1.E1_FILIAL = '" + FWxFilial("SE1", cFilialNS7) + "' "
	   	cCmd2 +=     " AND NWF.NWF_FILIAL = '" + xFilial("NWF") + "'"
		cCmd2 +=     " AND SE1.E1_CLIENTE = '" + cCliente  + "' "
		cCmd2 +=     " AND SE1.E1_LOJA = '" + cLoja + "' "
		cCmd2 +=     " AND SE1.E1_TIPO = '" + cTpAdiant + "' "
		cCmd2 +=     " AND SE1.E1_NUM = NWF.NWF_TITULO "
		cCmd2 +=     " AND SE1.E1_ORIGEM  = 'JURA069'"
		cCmd2 +=     " AND SE1.D_E_L_E_T_ = ' ' "
		cCmd2 +=     " AND NWF.D_E_L_E_T_ = ' ' "

		cCmd2 := ChangeQuery(cCmd2, .F.)
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cCmd2), cQryRes2, .T., .T.)

		If !(cQryRes2)->(EOF()) .And. !Empty( (cQryRes2)->SALDO )
			lRet := .T.
		EndIf

		(cQryRes2)->( dbCloseArea() )

		RestArea( aAreaNS7 )
		RestArea( aArea )
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203SLDAD
Retorna todo o saldo do adiantamento convertido na moeda da fatura

@Params cClien 	Código do Cliente
		cLoja	Código da Loja
		cEscrit	Código do Escritório
		cMoeda	Moeda da Fatura

@author David G. Fernandes
@since 08/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203SLDAD( cCliente, cLoja, cEscrit, cMoeda, dData, cContr )
Local aArea      := GetArea()
Local aAreaNS7   := NS7->( GetArea() )
Local cCmd2      := ''
Local cQryRes2   := GetNextAlias()
Local cTpAdiant  := SuperGetMv('MV_JADTTP',, 'RA')
Local cFiliaLNS7 := ""
Local aVlr       := {}
Local nRet       := 0

Default cMoeda   := '01'

	If !Empty(cCliente) .And. !Empty(cLoja) .And. !Empty(cEscrit)

		cFiliaLNS7 := JurGetDados('NS7', 1, xFilial('NS7') + cEscrit, 'NS7_CFILIA')

		cCmd2 := " SELECT SE1.E1_MOEDA, COALESCE(SUM(SE1.E1_SALDO),0) SALDO "
		cCmd2 +=   " FROM " + RetSQLName("SE1") + " SE1 "
		cCmd2 += " WHERE SE1.D_E_L_E_T_ = ' ' "
		cCmd2 +=   " AND SE1.E1_FILIAL = '" + FWxFilial("SE1", cFilialNS7) + "' "
		cCmd2 +=   " AND SE1.E1_CLIENTE = '" + cCliente  + "' "
		cCmd2 +=   " AND SE1.E1_LOJA = '" + cLoja + "' "
		cCmd2 +=   " AND SE1.E1_TIPO = '" + cTpAdiant + "' "
		cCmd2 +=   " AND SE1.E1_ORIGEM = 'JURA069' "
		cCmd2 +=   " GROUP BY SE1.E1_MOEDA "

		cCmd2 := ChangeQuery(cCmd2, .F.)
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cCmd2), cQryRes2, .T., .T.)

		If !(cQryRes2)->(EOF()) .AND. !Empty( (cQryRes2)->SALDO )

			While !(cQryRes2)->(EOF())

				aVlr := JA201FConv(cMoeda, StrZero((cQryRes2)->E1_MOEDA,2), (cQryRes2)->SALDO, "1", dData , '', cContr )
				nRet := nRet + aVlr[1]
				(cQryRes2)->(dbSkip())
			EndDo

		EndIf

		(cQryRes2)->( dbCloseArea() )

		RestArea( aAreaNS7 )
		RestArea( aArea )
	EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203MDIAEM
Calcula o dia máximo para emissão da fatura com base no Contrato / Cliente

@params cClien Código do cliente
@params cLoja  Loja do cliente
@params cContr Contrato

@return dRet   Data máxima para emissão

@obs    Função utilizada no X3_RELACAO dos campos NT1_DTAEMI e NVV_DTAEMI

@author David G. Fernandes
@since  09/03/10
/*/
//-------------------------------------------------------------------
Function J203MDIAEM(cClien, cLoja, cContr)
Local dRet     := ctod('  /  /  ')
Local nDiaNT0  := 0
Local nDiaNUH  := 0
Local nDiaTMP  := 0
Local nDia     := 0
Local aArea    := GetArea()
Local cCmd2    := ''
Local cQryRes2 := Nil
Local cConj    := ""

If _cContMDia == cContr // Se forem parcelas do mesmo contrato
	dRet := _dDataMDia  // a data será sempre a mesma. Então usa o que já estava na variável _dDataMDia
Else

	cConj := JurGetDados('NW3', 2, xFilial('NW3') + cContr, 'NW3_CJCONT')

	If !Empty(cClien) .And. !Empty(cLoja) .And. !Empty(cContr)
		If Empty(cConj)
			nDiaNT0 := JurGetDados('NT0', 1, xFilial('NT0') + cContr, 'NT0_DIAEMI')
		Else
			nDiaNT0 := JurGetDados('NW2', 1, xFilial('NT0') + cConj, 'NW2_DIAEMI')
		EndIf
		nDiaNUH := JurGetDados('NUH', 1, xFilial('NUH') + cClien + cLoja, 'NUH_DIAEMI')

	ElseIf Empty(cClien) .And. Empty(cLoja) .And. !Empty(cContr)
		If Empty(cConj)
			nDiaNT0 := JurGetDados('NT0', 1, xFilial('NT0') + cContr, 'NT0_DIAEMI')
		Else
			nDiaNT0 := JurGetDados('NW2', 1, xFilial('NT0') + cConj, 'NW2_DIAEMI')
		EndIf

		If Empty(nDiaNT0)

			cCmd2 := " SELECT NUT.NUT_CCLIEN, NUT.NUT_CLOJA "
			cCmd2 +=    " FROM " + RetSQLName("NUT") + " NUT "
			cCmd2 +=   " WHERE NUT.D_E_L_E_T_ = ' ' "
			cCmd2 +=     " AND NUT.NUT_FILIAL = '" + xFilial('NUT') + "' "
			cCmd2 +=     " AND NUT.NUT_CCONTR = '" + cContr + "' "
			cCmd2 +=   " GROUP BY NUT.NUT_CCLIEN, NUT.NUT_CLOJA "

			cQryRes2 := GetNextAlias()
			dbUseArea(.T., "TOPCONN", TcGenQry(,, cCmd2), cQryRes2, .T., .T.)

			While !(cQryRes2)->(EOF())
				If Empty(nDiaNUH)
					nDiaNUH := JurGetDados('NUH', 1, xFilial('NUH') + (cQryRes2)->NUT_CCLIEN + (cQryRes2)->NUT_CLOJA, 'NUH_DIAEMI')
				Else
					nDiaTMP := JurGetDados('NUH', 1,xFilial('NUH') + (cQryRes2)->NUT_CCLIEN + (cQryRes2)->NUT_CLOJA, 'NUH_DIAEMI')
					If !Empty(nDiaTMP) .And. (nDiaTMP < nDiaNUH)
						nDiaNUH := nDiaTMP
					EndIf
				EndIf
				(cQryRes2)->(dbSkip())
			EndDo

			(cQryRes2)->( dbCloseArea() )

		EndIf
	EndIf

	If Empty(nDiaNT0)
		nDia := nDiaNUH
	Else
		nDia := nDiaNT0
	EndIf

	If Empty(nDia)
		dRet := ctod('  /  /  ')
	Else
		If nDia > 28
			If Month(MsDate()) == 2
				nDia := 28
			ElseIf (Month( MsDate() ) == 4 .OR. ;
				Month( MsDate() ) == 6 .OR. ;
				Month( MsDate() ) == 9 .OR. ;
				Month( MsDate() ) == 11 ) .AND. nDia > 30
				nDia := 30
			EndIf
		Else
			If day( MsDate() ) > nDia
				If nDia > 28
					If Month( MsDate() ) + 1 == 2
						nDia := 28
					ElseIf (Month( MsDate() ) + 1 == 4 .OR. ;
						Month( MsDate() ) + 1 == 6 .OR. ;
						Month( MsDate() ) + 1 == 9 .OR. ;
						Month( MsDate() ) + 1 == 11 ) .AND. nDia > 30
						nDia := 30
					EndIf
				EndIf
				dRet := stod( AnoMes(MsSomaMes(MsDate(), 1)) + PADL(AllTrim(str(nDia)), 2, '0') )
			Else
				dRet := stod( AnoMes(MsDate()) + PADL(AllTrim(str(nDia)), 2, '0') )
			EndIf
		EndIf
	EndIf

	If AllTrim(ReadVar()) == "M->NT1_DTAEMI" // Somente se for o campo NT1_DTAEMI (essa função é usada em outros campos que não precisam desse tratamento)
		_cContMDia := cContr // Armazena o contrato na primeira execução da função para o contrato
		_dDataMDia := dRet   // Armazena a data na primeira execução da função para o contrato
	EndIf

EndIf

RestArea(aArea)

Return dRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203UTIADI
Executa ao emitir uma fatura para verificar se existe adiantamento, se deve compensar automaticamente
e abre a janela para o usuário compensar quando necessário.

@Params cEscrit, Escritório da Fatura
@Params cNumFat, Numero da Fatura
@Params cTpExec, Tipo de execução
@Params cFila  , Fila de emissão

@author Bruno Ritter
@since 01/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203UTIADI( cEscrit, cNumFat, cTpExec, cFila )
	Local cCliente   := ""
	Local cLoja      := ""
	Local cMoeda     := ""
	Local lJAutAdt   := .F.
	Local lTemAdt    := .T.
	Local lRet       := .T.
	Local aRet       := {}
	Local nVlFatura  := 0
	Local nVlRestan  := 0
	Local nVlGrsHon  := 0

	NXA->( dbSetOrder(1) ) // NXA_FILIAL + NXA_CESCR + NXA_COD
	If (NXA->( DbSeek( xFilial("NXA") + cEscrit + cNumFat ) ))
		nVlGrsHon := IIF(NXA->(ColumnPos("NXA_VGROSH")) > 0, NXA->NXA_VGROSH, 0) // @12.1.2310
		nVlFatura := NXA->NXA_VLFATH + NXA->NXA_VLFATD + nVlGrsHon - NXA->NXA_VLDESC - NXA->NXA_IRRF - NXA->NXA_PIS - NXA->NXA_COFINS - NXA->NXA_CSLL - NXA->NXA_INSS - NXA->NXA_ISS
		nVlRestan := nVlFatura
		cCliente  := NXA->NXA_CLIPG
		cLoja     := NXA->NXA_LOJPG
		cMoeda    := NXA->NXA_CMOEDA
		lJAutAdt  := SuperGetMv("MV_JAUTADT", .F., "2") == "1" .And. NWF->(ColumnPos("NWF_EXCLUS")) > 0 // Compensa automaticamente os adiantamentos exclusivos na emissão de fatura - 1="Sim";2="Não"

		// Ponto de entrada para utilização automática de adiantamento
		If ExistBlock("J203Adt")
			lRet := J203AdtUser(cEscrit, cNumFat, cCliente, cLoja, cMoeda, cFila, cTpExec, nVlFatura, @nVlRestan)
		EndIf

		If lRet .And. lJAutAdt .And. nVlRestan > 0
			aRet      := J203AutCmp(cEscrit, cNumFat, cCliente, cLoja, cTpExec, cFila, cMoeda, @nVlRestan, nVlGrsHon)
			lRet      := aRet[1]
			lTemAdt   := aRet[2]
		EndIf

		If lRet .And. !IsBlind()
			If lTemAdt .And. nVlRestan > 0
				lRet := J203DlgAdi(cEscrit, cNumFat, cTpExec, cFila, nVlRestan)
			ElseIf _lTelaAuto .And. !Empty(_aAdtAuto)
				J203AdiExc(_aAdtAuto)
			EndIf
		EndIf
	Else
		lRet := .F.
	EndIf

	_lAdtPE := .F. // Desabilita o uso de adiantamentos somente do ponto de entrada
	JurFreeArr(_aAdtAuto) // Variável estática de adiantamentos utilizados automaticamente

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203AutCmp
Compensa automaticamente os adiantamento exclusivos

@param cEscrit  , Escritório da Fatura
@param cNumFat  , Numero da Fatura
@param cCliente , Código do Cliente
@param cLoja    , Numero da Fatura
@param cTpExec  , Tipo de execução
@param cFila    , Fila de emissão
@param cMoeda   , cMoeda da Fatura
@param nVlRestan, Valor residual da Fatura
@param nVlGrsHon, Valor de Gross up de Honorários

@Return aRet, [1]lRet     , Se executou corretamente a função.
              [2]lAdtAComp, Se sobrou algum adiantamento para ser usado e se a fatura ainda tem saldo.
              [2]nVlRestan, Valor da fatura que restou para ser compensado.

@author Bruno Ritter
@since 01/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203AutCmp(cEscrit, cNumFat, cCliente, cLoja, cTpExec, cFila, cMoeda, nVlRestan, nVlGrsHon)
	Local aArea      := GetArea()
	Local cFiliaLNS7 := JurGetDados("NS7", 1, xFilial("NS7") + cEscrit, "NS7_CFILIA")
	Local cQuery     := J203QryAdt(cFilialNS7, cCliente, cLoja, cNumFat, .T.)
	Local cAliasQry  := GetNextAlias()
	Local lAdtAComp  := .F.
	Local lRet       := .F.
	Local nVlAUtiliz := 0
	Local nSaldoAdia := 0
	Local aUtiliza   := {}
	Local aRet       := {}
	Local aStruAdic  := {}
	Local aTemp      := {}
	Local lAdtNoExc  := .F.
	Local lCpoCota   := NWF->(ColumnPos("NWF_COTACA")) > 0
	Local nCotaca    := 0
	Local oTempTable := Nil

	aStruAdic  := {{"SALDESCAS", "SALDESCAS", "N", GetSx3CaChe("NWF_SALDO" , "X3_TAMANHO"), GetSx3CaChe("NWF_SALDO", "X3_DECIMAL"), GetSx3CaChe("NWF_SALDO", "X3_PICTURE"), "NWF_SALDO"},;
	               {"SALHONCAS", "SALHONCAS", "N", GetSx3CaChe("NWF_SALDO" , "X3_TAMANHO"), GetSx3CaChe("NWF_SALDO", "X3_DECIMAL"), GetSx3CaChe("NWF_SALDO", "X3_PICTURE"), "NWF_SALDO"},;
	               {"CODTPADI" , "CODTPADI" , "C", 1, 0, "", "NWF_TPADI" },;
	               {"CODEXCL"  , "CODEXCL"  , "C", 1, 0, "", "NWF_EXCLUS"},;
	               {"DATAADI"  , "DATAADI"  , "C", 8, 0, "", "NWF_DTMOVI"},;
	               {"TEMDESP"  , "TEMDESP"  , "C", 1, 0, "", "NWF_TPADI" },;
	               {"TEMHON"   , "TEMHON"   , "C", 1, 0, "", "NWF_TPADI" },;
	               {"NWFRECNO" , "NWFRECNO" , "N", 100, 0, ""},;
	               {"SE1RECNO" , "SE1RECNO" , "N", 100, 0, ""}}

	aTemp      := JurCriaTmp(cAliasQry, cQuery, "NWF",, aStruAdic)
	oTempTable := aTemp[1]
	cAliasQry  := oTempTable:GetAlias()

	While (cAliasQry)->(!EOF()) .And. nVlRestan > 0
		nCotaca := IIF(lCpoCota,(cAliasQry)->NWF_COTACA , 0)
		If (cAliasQry)->CODEXCL == "1" // Exclusivo
			nSaldoAdia := J203ConvAdi(cMoeda, (cAliasQry)->NWF_CMOE, (cAliasQry)->E1_SALDO, StoD((cAliasQry)->DATAADI), cTpExec, cFila, nCotaca)[1]
			nVlAUtiliz := J203VlUtil(nSaldoAdia, nVlRestan, cAliasQry)

			Aadd(aUtiliza, {'', (cAliasQry)->E1_NUM, "", Transform( nVlAUtiliz, "@E 99,999,999.99" ),;
							(cAliasQry)->SE1RECNO, (cAliasQry)->E1_HIST, StoD((cAliasQry)->DATAADI), (cAliasQry)->NWF_CMOE,;
							nVlAUtiliz, .T., nSaldoAdia, nCotaca})

			nVlRestan -= nVlAUtiliz

			// Atualiza saldos exclusivo do caso
			J203SldExc(cAliasQry, nVlAUtiliz, .T.)
		Else
			lAdtNoExc := .T.
		EndIf

		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())
	oTempTable:Delete()
	JurFreeArr(aStruAdic)
	JurFreeArr(aTemp)

	lRet := IIF(Len(aUtiliza) > 0, J203GrvAdt(cEscrit, cNumFat, cTpExec, cFila, aUtiliza, .T.), .T.)

	lAdtAComp := lAdtNoExc .And. nVlRestan > 0

	aRet := {lRet, lAdtAComp}
	
	RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203DlgAdi
Cria a Tela para informar a utilização do adiantamento na emissão
 da fatura

@Params cEscrit  , Escritório da Fatura
@Params cNumFat  , Numero da Fatura
@Params cTpExec  , Tipo de execução
@Params cFila    , Fila de emissão
@Params nVlRestan, Valor que pode ser utilizado para ser compensado

@author David G. Fernandes
@since 09/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203DlgAdi( cEscrit, cNumFat, cTpExec, cFila, nVlRestan )
Local lRet       := .F.
Local aArea      := GetArea()
Local cCliente   := ''
Local cLoja      := ''
Local cDClien    := ''
Local nVlFatH    := 0
Local nVlFatD    := 0
Local dDtVenc    := Date()

Local cNumTitulo := ''
Local cMoedaTitu := ''
Local nSE1Recno  := 0
Local cSE1Hist   := ''

Local nVlFatura  := 0
Local nVlAUtiliz := 0
Local nTotUtiliz := 0
Local nSaldoAdia := 0
Local dDtUtiliz  := msDate()
Local nI         := 0
Local oGetFatura := Nil
Local oGetEscrit := Nil
Local oGetVlFatH := Nil
Local oGetVlFatD := Nil
Local oGetVlTot  := Nil
Local oDlg       := Nil
Local oPnlDet    := Nil
Local oPnlUtil   := Nil
Local oPnlBrw    := Nil
Local oBrowse    := Nil
Local oLbxUtiliz := Nil
Local oGetVlUti  := Nil
Local oGetVlRes  := Nil
Local oGetTotUti := Nil
Local oGetCClien := Nil
Local oGetCLoja  := Nil
Local oGetDClien := Nil
Local oGetDtUti  := Nil
Local oGetDtVenc := Nil
Local oGetMoeFat := Nil
Local lOk        := .F.
Local cTrab      := GetNextAlias()
Local cQuery     := ""
Local cCpoRecno  := "SE1RECNO"
Local nHeigth    := 0
Local nWidth     := 0
Local cMoeda     := ""
Local cFiliaLNS7 := ""
Local cFilAtu    := cFilAnt
Local aUtiliza   := {}
Local aAux       := {}
Local aStru      := {}
Local aCampos    := {}
Local aButtons   := {}

Local lRetExcQry := SuperGetMV("MV_JAUTADT", .F., "2") == "2" // Compensa automaticamente os adiantamentos exlusivos na emissão de fatura - 1="Sim";2="Não"
Local lCpoExclus := NWF->(ColumnPos("NWF_EXCLUS")) > 0
Local cNoBrwCpo  := IIF(lCpoExclus, "CODEXCL|CODTPADI|TEMDESP|TEMHON|NXC_VLDFAT|NXC_VLHFAT", "")

Local aSize      := {}
Local nLargura   := 393
Local nTamDialog := 0
Local nAltPnl1   := 0
Local nAltPnl2   := 0
Local nAltPnl3   := 0
Local lObfuscate := FindFunction("FwPDCanUse") .And. FwPDCanUse(.T.) // Indica se trabalha com Dados Protegidos e possui a melhoria de ofuscação de dados habilitada
Local aColumns   := {}
Local lCpoDtMov  := NWF->(ColumnPos("NWF_DTMOVI")) > 0
Local lCpoCota   := NWF->(ColumnPos("NWF_COTACA")) > 0
Local nVlGrsHon  := 0

Default cEscrit  := ''
Default cNumFat  := ''
Default cTpExec  := ''
Default cFila    := ''

	NXA->( dbSetOrder(1) ) // NXA_FILIAL + NXA_CESCR + NXA_COD
	If (NXA->( DbSeek( xFilial("NXA") + cEscrit + cNumFat ) ))
		cCliente   := NXA->NXA_CLIPG
		cLoja      := NXA->NXA_LOJPG
		cMoeda     := NXA->NXA_CMOEDA
		nVlGrsHon  := IIF(NXA->(ColumnPos("NXA_VGROSH")) > 0, NXA->NXA_VGROSH, 0)
		nVlFatH    := NXA->NXA_VLFATH + nVlGrsHon
		nVlFatD    := NXA->NXA_VLFATD
		dDtVenc    := NXA->NXA_DTVENC
		nVlFatura  := nVlFatH + nVlFatD - NXA->NXA_VLDESC - NXA->NXA_IRRF - NXA->NXA_PIS - NXA->NXA_COFINS - NXA->NXA_CSLL - NXA->NXA_INSS - NXA->NXA_ISS
		nTotUtiliz := nVlFatura - nVlRestan
	EndIf

	cDClien    := JurGetDados('SA1', 1, xFilial('SA1') + cCliente + cLoja, 'A1_NOME')
	cDMoeda    := JurGetDados('CTO', 1, xFilial('CTO') + cMoeda, 'CTO_SIMB')
	cFiliaLNS7 := JurGetDados('NS7', 1, xFilial('NS7') + cEscrit, 'NS7_CFILIA')
	cFilAnt    := cFiliaLNS7 //Filial de trabalho do titulo

	aAdd(aUtiliza, {'', '', '' ,'', '', '', '', '', '','','', 0} )

	// Define da Tela
	aSize      := MsAdvSize(.F.) // Retorna o tamanho da tela
	nTamDialog := ((aSize[6] / 2) * 0.85) // Diminui 15% da altura.
	JurFreeArr(aSize)

	oDlg := FWDialogModal():New()
	oDlg:SetFreeArea(nLargura, nTamDialog)
	oDlg:SetTitle(STR0120)   // "Utilização de Adiantamento"
	oDlg:CreateDialog()
	oDlg:AddOkButton({|| IIf( J203ACTBT1( nVlFatura, nTotUtiliz, aUtiliza), (lOk := .T., oDlg:oOwner:End()), lOk := .F. ) })
	oDlg:AddCloseButton({|| IIf( J203ACTBT2(), (lOk := .F., oDlg:oOwner:End()), lOk := .F. ) }) //"Cancelar"

	If !Empty(_aAdtAuto)
		aAdd(aButtons, {,STR0298,{|| J203AdiExc(_aAdtAuto) },,, .T., .T.} ) // "Utilizados"
		oDlg:addButtons(aButtons)
	EndIf

	nAltPnl2 := 80
	nAltPnl1 := (nTamDialog - nAltPnl2) * 0.60
	nAltPnl3 := (nTamDialog - nAltPnl2) * 0.40

	@ 000,000 MSPANEL oPnlBrw OF oDlg:GetPanelMain() SIZE nLargura, nAltPnl1
	@ nAltPnl1,000 MSPANEL oPnlDet OF oDlg:GetPanelMain() SIZE nLargura, nAltPnl2
	@ nAltPnl2+nAltPnl1,000 MSPANEL oPnlUtil OF oDlg:GetPanelMain() SIZE nLargura, nAltPnl3

	@ 005,005 Say AllTrim(RetTitle("NXA_CCLIEN")) Size 040,008 PIXEL OF oPnlDet //"Cód Cliente"
	@ 013,005 MsGet oGetCClien Var cCliente Size 040,009 PIXEL OF oPnlDet
	oGetCClien:Disable()

	@ 005,050 Say AllTrim(RetTitle("NXA_CLOJA")) Size 025,008 PIXEL OF oPnlDet //"Cód Loja"
	@ 013,050 MsGet oGetCLoja Var cLoja Size 025,009 PIXEL OF oPnlDet
	oGetCLoja:Disable()

	@ 005,080 Say AllTrim(RetTitle("NXA_RAZSOC")) Size 295,008 PIXEL OF oPnlDet //"Razão Social"
	@ 013,080 MsGet oGetDClien Var cDClien Size 295,009 PIXEL OF oPnlDet
	oGetDClien:Disable()

	@ 029,005 Say STR0113 Size 030,008 PIXEL OF oPnlDet //"Escritório"
	@ 037,005 MsGet oGetEscrit Var cEscrit Size 030,009 PIXEL OF oPnlDet
	oGetEscrit:Disable()

	@ 029,040 Say STR0114 Size 035,008 PIXEL OF oPnlDet //"Fatura"
	@ 037,040 MsGet oGetFatura Var cNumFat Size 035,009 PIXEL OF oPnlDet
	oGetFatura:Disable()

	@ 029,080 Say STR0126 Size 045,008  PIXEL OF oPnlDet //"Dt Vencimento"
	@ 037,080 MsGet oGetDtVenc Var dDtVenc HasButton Size 045,009 PIXEL OF oPnlDet
	oGetDtVenc:Disable()

	@ 029,130 Say STR0127 Size 030,008 PIXEL OF oPnlDet // "Moeda Fat"
	@ 037,130 MsGet oGetMoeFat Var cDMoeda  Size 030,009 PIXEL OF oPnlDet
	oGetMoeFat:Disable()

	@ 029,165 Say STR0128 Size 050,008 PIXEL OF oPnlDet // "Valor Honorários"
	@ 037,165 MsGet oGetVlFatH Var nVlFatH  Picture '@E 99,999,999.99' Size 050,009 PIXEL OF oPnlDet
	oGetVlFatH:Disable()

	@ 029,220 Say STR0129 Size 050,008  PIXEL OF oPnlDet //"Valor Despesas"
	@ 037,220 MsGet oGetVlFatD Var nVlFatD Picture '@E 99,999,999.99' Size 050,009 PIXEL OF oPnlDet
	oGetVlFatD:Disable()

	@ 029,275 Say STR0130 Size 050,008  PIXEL OF oPnlDet //"Valor Líquido"
	@ 037,275 MsGet oGetVlTot Var nVlFatura Picture '@E 99,999,999.99' Size 050,009 PIXEL OF oPnlDet
	oGetVlTot:Disable()

	@ 029,330 Say STR0131 Size 055,008  PIXEL OF oPnlDet //"Valor Restante"
	@ 037,330 MsGet oGetVlRes Var nVlRestan Picture '@E 99,999,999.99' HasButton Size 055,009 PIXEL OF oPnlDet
	oGetVlRes:Disable()

	@ 053,080 Say STR0132 Size 045,008  PIXEL OF oPnlDet //"Dt Utilização"
	@ 061,080 MsGet oGetDtUti Var dDtUtiliz HasButton Size 045,009 PIXEL OF oPnlDet
	oGetDtUti:Disable()

	@ 053,165 Say STR0133 Size 040,008  PIXEL OF oPnlDet //"Valor a utilizar"
	@ 061,165 MsGet oGetVlUti Var nVlAUtiliz Picture '@E 99,999,999.99' HasButton Size 050,009 PIXEL OF oPnlDet

	@ 060,220 Button oBtnADD Prompt STR0134 Size 042, 12 Of oPnlDet Pixel ;  // "Adiciona"
			Action ( J203ACTBT3(nSE1Recno, cNumTitulo, cMoedaTitu, nSaldoAdia,;
								 @nVlAUtiliz, @nVlFatura, @nVlRestan, @nTotUtiliz, ;
								 @oLbxUtiliz, @aUtiliza, cSE1Hist, cDMoeda, ;
								 cTrab) )

	@ 060,275 Button oBtnREM Prompt STR0135 Size 042, 12 Of oPnlDet Pixel ; // "Remove"
	Action (	Iif(Len(aUtiliza) == 0, JurMsgErro(STR0136, "J203UTIAD"), ; // "Não há itens para remover"
							(J203SldExc(cTrab, 0, .F., aUtiliza[oLbxUtiliz:nAt]),;
							nTotUtiliz := nTotUtiliz - Iif(Empty(aUtiliza[oLbxUtiliz:nAt, 4]), 0, GETDTOVAL(StrTran(aUtiliza[oLbxUtiliz:nAt, 4], '.', ''))),;
							nVlRestan := nVlFatura - nTotUtiliz,;
							aUtiliza := JaRemPos(aUtiliza, oLbxUtiliz:nAt),;
							oLbxUtiliz:SetArray( aUtiliza ),;
							oLbxUtiliz:bLine := {|| {;
							aUtiliza[oLbxUtiliz:nAt, 1],;
							aUtiliza[oLbxUtiliz:nAt, 2],;
							aUtiliza[oLbxUtiliz:nAt, 3],;
							aUtiliza[oLbxUtiliz:nAt, 4],;
							aUtiliza[oLbxUtiliz:nAt, 5]}},;
							oLbxUtiliz:Refresh();
							);
						);
	)

	@ 053,330 Say STR0137 Size 055,008 PIXEL OF oPnlDet //"Total Utilizado"
	@ 061,330 MsGet oGetTotUti Var nTotUtiliz Picture '@E 99,999,999.99' HasButton Size 055,009 PIXEL OF oPnlDet
	oGetTotUti:Disable()

	nHeigth := 80
	nWidth  := 393
	@ 000, 000 ListBox oLbxUtiliz Fields Header '', STR0138, STR0139, STR0140, STR0194 Size nWidth, nHeigth Of oPnlUtil Pixel
	oLbxUtiliz:Align := CONTROL_ALIGN_ALLCLIENT 

	oLbxUtiliz:SetArray( aUtiliza )
	oLbxUtiliz:bLine := { || {;
	aUtiliza[oLbxUtiliz:nAt, 1], ;
	aUtiliza[oLbxUtiliz:nAt, 2], ;
	aUtiliza[oLbxUtiliz:nAt, 3], ;
	aUtiliza[oLbxUtiliz:nAt, 4], ;
	aUtiliza[oLbxUtiliz:nAt, 5]  } }

	oLbxUtiliz:Refresh()

	// Define o Browse
	cQuery := J203QryAdt(cFilialNS7, cCliente, cLoja, cNumFat, lRetExcQry)
	Define FWBrowse oBrowse DATA QUERY ALIAS cTrab QUERY cQuery ;
		DOUBLECLICK { || cNumTitulo := ( cTrab )->E1_NUM,;
											cMoedaTitu := ( cTrab )->NWF_CMOE,;
											nSaldoAdia := J203ConvAdi(cMoeda, (cTrab)->NWF_CMOE, (cTrab)->E1_SALDO, StoD((cTrab)->DATAADI),;
											 						  cTpExec, cFila, IIF(lCpoCota, (cTrab)->NWF_COTACA, 0))[1],;
											nSE1Recno  := ( cTrab )->SE1RECNO,;
											cSE1Hist   := ( cTrab )->E1_HIST,;
											nVlAUtiliz := J203VlUtil(nSaldoAdia, nVlRestan, cTrab)} of oPnlBrw
	oBrowse:DisableReport()

	aStru := ( cTrab )->( dbStruct() )

	For nI := 1 To Len( aStru )
		If !(aStru[nI][1] $ cNoBrwCpo) .And. !(aStru[nI][1] $ "NWFRECNO|SALHONCAS|SALDESCAS") // Campos da query que não serão exibidos no browse
			aAux  := {}
			aAdd( aAux, aStru[nI][1] )

			If AvSX3( aStru[nI][1],, cTrab, .T. )
				aAdd( aAux, RetTitle( aStru[nI][1] ) )
				aAdd( aAux, AvSX3( aStru[nI][1], 6, cTrab ) )
			Else
				aAdd( aAux, aStru[nI][1] )
				aAdd( aAux, '' )
			EndIf

			aAdd( aCampos, aAux )
		EndIf
	Next

	// Adiciona as colunas do Browse
	For nI := 1 To Len( aCampos )
		If PadR( cCpoRecno, 15 ) <> PadR( aCampos[nI][1], 15 )
			AAdd( aColumns, FWBrwColumn():New() )
			If aCampos[nI][1] == "DATAADI"
				aColumns[nI]:SetTitle(IIf(lCpoDtMov, RetTitle("NWF_DTMOVI"), RetTitle("NWF_DATAIN")))
				aColumns[nI]:SetType("D")
				aColumns[nI]:SetSize(8)
				aColumns[nI]:SetData(&('{ || StoD(DATAADI) }'))
			Else
				aColumns[nI]:SetTitle(aCampos[nI][2])
				aColumns[nI]:SetPicture(aCampos[nI][3])
				aColumns[nI]:SetData(&('{ || ' + aCampos[nI][1] + ' }'))
			EndIf
			If lObfuscate
				aColumns[nI]:SetObfuscateCol( Empty(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {aCampos[nI][1]})) )
			EndIf
		EndIf
	Next

	oBrowse:SetColumns(aColumns)
	oBrowse:SetDescription(STR0120) //"Utilização de Adiantamento"
	Activate FWBrowse oBrowse
	oDlg:Activate()

	//Baixa Total/ Parcialmente o compromisso utilizado
	If lOk
		lRet := J203GrvAdt(cEscrit, cNumFat, cTpExec, cFila, aUtiliza, .F.)
	EndIf

	cFilAnt := cFilAtu

	// Comentado pois quando o Dlg é fechado a Área "cTrab" é fechada ao mesmo tempo fazendo não necessário o DbCloseArea 
	//(cTrab)->(DbCloseArea()) 
	
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203GrvAdt
Compensa os adiantamentos

@param cEscrit , Escritório da Fatura
@param cNumFat , Numero da Fatura
@param cTpExec , Tipo de execução
@param cFila   , Fila de emissão
@param aUtiliza, [nI][1]:vazio
                  [nI][2]:documento
                  [nI][3]:Desc Moeda RA
                  [nI][4]:VLR utilizado
                  [nI][5]:Recno Titulo
                  [nI][6]:Hist
                  [nI][7]:Data Adiant
                  [nI][8]:Moeda Titulo
                  [nI][9]:VLR utilizado com precisão decimal
                  [nI][10]:Desconsiderar adiantamentos que foram utilizados 
                  via ponto de entrada e não devem ter o saldo residual consumido

@param lAdtAuto, Se verdadeiro indica que é utilização automática

@return  cQuery, Query com filtro de adiantamentos.

@author  Bruno Ritter
@since   10/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203GrvAdt(cEscrit, cNumFat, cTpExec, cFila, aUtiliza, lAdtAuto)
	Local lRet       := .F.
	Local cFilAtu    := cFilAnt
	Local cFatJur    := ""
	Local cQuery     := ""
	Local cFiliaLNS7 := JurGetDados('NS7', 1, xFilial('NS7') + cEscrit, 'NS7_CFILIA')
	Local cAliasSE1  := GetNextAlias()
	Local aRecSE1    := {}
	Local aTxMoeda   := {}
	Local nTxMoeda   := 0
	Local cMoedaNac  := SuperGetMv('MV_JMOENAC',, 01)
	Local dDtEmit    := Date()
	Local aRecRA     := {}
	Local nRecBX     := 0
	Local nValorBX   := 0
	Local aRecRABX   := {}
	Local nY         := 0
	Local nI         := 0
	Local nValores   := 0
	Local nTaxaBX    := 0
	Local cMoedaFat  := ""
	Local nTotUtiliz := 0
	Local lCtbOnLine := .F.
	Local nPosCodAdt := 2 // Código do Adiantamento
	Local nPosRecTit := 5 // Recno Titulo
	Local nPosHisAdt := 6 // Histórico
	Local nPosDtAdt  := 7 // Data Adiant
	Local nPosMoeTit := 8 // Moeda Titulo
	Local nPosVlDec  := 9 // VLR utilizado com precisão decimal
	Local nPosResid  := 10 // Lógico para utilização do resíduo
	Local nPosSaldo  := 11 // Saldo do adiantamento no momento da emissão
	Local nPosCotaca := 12 //Posicao da Cotação
	Local nSaldoAd   := 0
	Local lJA203CMP  := ExistBlock( 'JA203CMP' )
	Local nCotaca    := 0

	Default lAdtAuto := .F.

	cFilAnt := cFiliaLNS7 //Filial de trabalho do titulo
	NXA->( dbSetOrder(1) ) // NXA_FILIAL + NXA_CESCR + NXA_COD
	If (NXA->( DbSeek( xFilial("NXA") + cEscrit + cNumFat  ) ))
		cMoedaFat := NXA->NXA_CMOEDA
		dDtEmit   := NXA->NXA_DTEMI
	EndIf

	BEGIN TRANSACTION
		//Chave de busca da tabela SE1, campo E1_JURFAT utilizada na query abaixo
		cFatJur := xFilial( 'NXA' ) + '-' + cEscrit + '-' + cNumFat + '-' + cFilAnt

		//Seleciona os titulos da fatura ativa
		cQuery := " SELECT SE1.R_E_C_N_O_ SE1RECNO, SE1.E1_MOEDA "
		cQuery += " FROM " + RetSQLName("SE1") + " SE1 "
		cQuery += " WHERE SE1.D_E_L_E_T_ = ' ' "
		cQuery +=   " AND SE1.E1_FILIAL = '" + FWxFilial("SE1",cFilialNS7) + "' "
		cQuery +=   " AND SE1.E1_JURFAT = '" + cFatJur + "' "
		cQuery +=   " AND SE1.E1_SALDO > 0 "

		cQuery := ChangeQuery( cQuery, .F.)
		dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cAliasSE1, .T., .F. )

		(cAliasSE1)->( Dbgotop() )
		Do While ! (cAliasSE1)->( Eof() )
			//Adiciona os recnos dos titulos da fatura ativa
			aAdd( aRecSE1, (cAliasSE1)->SE1RECNO )
			(cAliasSE1)->( DbSkip() )
		EndDo

		For ni := 1 To Len(aUtiliza)

			nVlrUtilRA := aUtiliza[ni][nPosVlDec]  // Valor utilizado do RA na moeda da Fatura
			cMoedaRA   := aUtiliza[ni][nPosMoeTit] // Moeda RA
			dDtAdiant  := aUtiliza[ni][nPosDtAdt]  // Data do adiantamento
			nCotaca    := aUtiliza[ni][nPosCotaca] // Cotação do adiantamento

			nTotUtiliz += nVlrUtilRA

			//as compensações são feitas na moeda 1. é preciso passar o valor com a mesma conversão para que o título seja compensado e o saldo seja abatido corretamente.
			If cMoedaFat != cMoedaNac
				// Conversão do valor do RA para moeda nacial com base na data do parâmetro de compensação de RA (MV_JDTCVAD)
				aConvBX   := J203ConvAdi(cMoedaNac, cMoedaFat, nVlrUtilRA, dDtAdiant, ;
										cTpExec, cFila, nCotaca)
				nValorBX  := aConvBX[1] // Valor a compensar Moeda Nacional
				nTaxaBX   := aConvBX[2] // Taxa para compensar
				aAdd( aTxMoeda, {Val(cMoedaFat), nTaxaBX } )
			Else
				nValorBX  := nVlrUtilRA // Valor a compensar
				nTaxaBX   := IIF(cMoedaRA == cMoedaNac, 1, nCotaca) // Taxa para compensar Moeda Nacional
				aAdd( aTxMoeda, {Val(cMoedaFat),IIF(cMoedaFat == cMoedaNac, 1, nTaxaBX) } )		
			EndIf	

			// Taxa da moeda do RA para moeda nacional
			If (aScan( aTxMoeda,{|x| x[1] == Val(cMoedaRA)}) == 0)
				nTxMoeda := J203ConvAdi(cMoedaNac, cMoedaRA, nVlrUtilRA, dDtAdiant, ;
										cTpExec, cFila, nCotaca)[2]			
				aAdd( aTxMoeda, {Val(cMoedaRA), nTxMoeda } )
			EndIf

			aAdd(aRecRA, {aUtiliza[ni][nPosRecTit], nVlrUtilRA, nValorBX, nTaxaBX, aClone(aTxMoeda), ;
			              aUtiliza[ni][nPosCodAdt], aUtiliza[ni][nPosHisAdt], aUtiliza[ni][nPosMoeTit],;
			              IIF(lAdtAuto, aUtiliza[ni][nPosResid], lAdtAuto), aUtiliza[ni][nPosSaldo]})

			JurFreeArr(aTxMoeda)
		Next ni
		
		//MaIntBxCR( nCaso -> Tipo da Operação - 3: Compensação de títulos da mesma carteira (RA / NCC)
		//                   aSE1     -> Array com os 'Recnos' dos título a ser baixado (Fatura)
		//                   aBaixa,  ->
		//                   aNCC_RA, -> Array com os 'Recnos' dos títulos a serem compensados (RA's)
		//                   aLiquidacao
		//                   aParam,
		//                   bBlock,  -> Bloco de codigo executado Bloco de codigo a ser executado apos o processamento da rotina, recebe como parametros
		//                                [1] Recno do titulo baixado
		//                                [2] Codigo a ser informado para cancelamento futuro.
		//                   aEstorno,
		//                   aSE1Dados,
		//                   aNewSE1,
		//                   nSaldoComp,
		//                   aCpoUser,
		//                   aNCC_RAvlr -> Array com os valores parciais (?) dos títulos a serem compensados
		//                   nSomaCheque
		//                   aTxmoeda, Array com as taxas das moedas utilizadas

		//Efetua a compensacao do(s) titulo(s) com o adiantamento  MaIntBxCR(3,aRecSe1,,aRecNcc,,{lCtbOnLine,.F.,.F.,.F.,.F.,.T.})
		aRecRABX := aClone(aRecRA)
		For nI := 1 To Len(aRecSE1)
			SE1->(MsGoto(aRecSE1[nI]))

			nValTitulo := SE1->E1_VALOR
			If Len(aRecSE1) > 1 // Usando somente em caso de parcelamento
				nValTitulo -= SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, "R", 1,,SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_FILIAL, SE1->E1_EMISSAO, SE1->E1_TIPO)
			EndIf

			For nY := 1 To Len(aRecRABX)
				nRecBX     := aRecRABX[nY][1] // Recno do RA
				nVlrUtilRA := aRecRABX[nY][2] // Valor utilizado do RA na moeda do Título
				nValorBX   := aRecRABX[nY][3] // Valor utilizado do RA na moeda Nacional
				nTaxaBX    := aRecRABX[nY][4] // Taxa utilizada para compensar o RA
				aTxMoeda   := aRecRABX[nY][5] // Taxa das moedas e taxas do RA e do Título
				nSaldoAd   := aRecRABX[nY][10] // Saldo do adiantamento no momento da emissão da fatura

				If nVlrUtilRA > 0
					lRet := MaIntBxCR( 3, {aRecSE1[nI]}, , {nRecBX}, , { lCtbOnLine, .F., .F., .F., .F., .F. },;
					                   IIf( lJA203CMP, { |x,y| ExecBlock( 'JA203CMP', .F., .F., { x, y } ) },),; // Ponto de entrada
					                   , , , nValorBX, , {nValorBX}, , nTaxaBX /*nTaxaCM*/, aTxMoeda )

					If lRet
						nValores        := Min(nVlrUtilRA, nValTitulo)
						nSaldoAd        -= nValores
						aRecRABX[nY][2] -= nValores
						aRecRABX[nY][3] -= nValores * nTaxaBX
						nValTitulo      -= nValores
						If lAdtAuto
							Aadd(_aAdtAuto, {aRecRABX[nY][6], cMoedaFat, nVlrUtilRA, nSaldoAd, aRecRABX[nY][7], aRecRABX[nY][9]})
						EndIf

						If nValTitulo <= 0
							Exit
						EndIf
					Else
						Exit
					EndIf
				EndIf
			Next nY

			If !lRet
				Exit
			EndIf
		Next nI

		JurFreeArr(aRecRA)
		JurFreeArr(aUtiliza)

		//Verifica se a compensacao foi efetuada com sucesso e finaliza o restante da gravacao
		If lRet
			NXA->( dbSeek(xFilial('NXA') + cEscrit + cNumFat) )
			RecLock('NXA', .F.)
			NXA->NXA_VUADIA := nTotUtiliz
			NXA->(MsUnLock())
			//Grava na fila de sincronização
			J170GRAVA("NXA", xFilial("NXA") + NXA->NXA_CESCR + NXA->NXA_COD, "4")
		EndIf

		//Ponto de entrada para complementar gravação de dados - Alexandre 10/2010
		If ExistBlock("JA203ADI")
			ExecBlock("JA203ADI", .F., .F., { aRecRA } )
		EndIf
	End Transaction

	(cAliasSE1)->(DbCloseArea())
	cFilAnt := cFilAtu

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203QryAdt
Query para filtrar adiantamentos

@param   cFilialNS7 , caractere, Filial do escritório
@param   cCliente   , caractere, Código do cliente
@param   cLoja      , caractere, Loja do cliente
@param   cNumFat    , caractere, Número da fatura
@param   lRetExeclu , caractere, Se verdadeiro a query deve retorna os adiantamento exclusivos

@return  cQuery     , caractere, Query com filtro de adiantamentos.
@author  Jorge Martins / Jonatas Martins / Abner Fogaça
@since   10/09/2018
@Obs     Não mudar a ordem dos campos na query, pois reflete na posição do array 'aUtiliza' da tela (função J203DlgAdi)
/*/
//-------------------------------------------------------------------
Static Function J203QryAdt(cFilialNS7, cCliente, cLoja, cNumFat, lRetExeclu)
	Local cQuery     := ""
	Local cPrefAdi   := PadR(SuperGetMV("MV_JADTPRF", .F., ""  ), TamSX3("E1_PREFIXO")[1])
	Local cTipoAdi   := PadR(SuperGetMV("MV_JADTTP" , .F., "RA"), TamSX3("E1_TIPO")[1])
	Local cParcAdi   := PadR(SuperGetMV("MV_JADTPAR", .F., ""  ), TamSX3("E1_PARCELA")[1])
	Local lCpoExclus := NWF->(ColumnPos("NWF_EXCLUS")) > 0
	Local lJ203Adt   := ExistBlock("J203Adt")
	Local lCpoDtMov  := NWF->(ColumnPos("NWF_DTMOVI")) > 0
	Local lCpoCota   := NWF->(ColumnPos("NWF_COTACA")) > 0
	Local lCpoGrsH   := NXC->(ColumnPos("NXC_VGROSH")) > 0 // @12.1.2310

	Default lRetExeclu := .T.

	cQuery := " SELECT SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_NATUREZ, CTO.CTO_SIMB, SE1.E1_VALOR, SE1.E1_SALDO, SE1.E1_HIST, "
	cQuery += " NWF.NWF_CCLIEN, NWF.NWF_CLOJA, NWF.NWF_CCASO, NVE_TITULO, "
	If lCpoExclus
		cQuery += "NWF.NWF_EXCLUS CODEXCL, (CASE WHEN NWF_EXCLUS = '1' THEN '" + STR0101 + "' ELSE '" + STR0102 + "' END) NWF_EXCLUS, NWF.NWF_TPADI CODTPADI, " // "Sim" # "Não"
	EndIf
	If lCpoCota
		cQuery += "NWF.NWF_COTACA, "
	EndIf
	If lCpoGrsH
		cQuery += "0 NXC_VGROSH, "
	EndIf	
	cQuery += " (CASE WHEN NWF.NWF_TPADI ='1' THEN '" + STR0226 + "' ELSE " // "Despesas"
	cQuery += " (CASE WHEN NWF.NWF_TPADI ='2' THEN '" + STR0227 + "' ELSE '" + STR0228 + "' END) END) NWF_TPADI, " // "Honorários" # "Ambos"
	cQuery += " NWF.NWF_CMOE," + IIF(lCpoDtMov, " (CASE WHEN NWF.NWF_DTMOVI = ' ' THEN NWF.NWF_DATAIN ELSE NWF.NWF_DTMOVI END) DATAADI, ", " NWF.NWF_DATAIN DATAADI, ")
	cQuery += IIF(lCpoExclus, "'1' TEMDESP, '2' TEMHON, 0 NXC_VLHFAT, 0 NXC_VLDFAT, ", "") + " SE1.R_E_C_N_O_ SE1RECNO, NWF.R_E_C_N_O_ NWFRECNO "
	cQuery += " , 0 SALHONCAS, 0 SALDESCAS "
	cQuery +=   " FROM " + RetSqlName('SE1') + " SE1, "
	cQuery +=        " " + RetSqlName('NWF') + " NWF, "
	cQuery +=        " " + RetSqlName('NVE') + " NVE, "
	cQuery +=        " " + RetSqlName('CTO') + " CTO "
	cQuery +=   " WHERE  NVE.NVE_FILIAL = '" + xFilial("NVE") + "'"
	cQuery +=    " AND NWF.NWF_FILIAL = '" + xFilial("NWF") + "'"
	cQuery +=    " AND CTO.CTO_FILIAL = '" + xFilial("CTO") + "'"
	cQuery +=    " AND SE1.E1_FILIAL = '" + FWxFilial("SE1", cFilialNS7) + "' "
	cQuery +=    " AND SE1.E1_CLIENTE = '" + cCliente + "' "
	cQuery +=    " AND SE1.E1_LOJA = '" + cLoja + "' "
	cQuery +=    " AND SE1.E1_PREFIXO = '" + cPrefAdi + "' "
	cQuery +=    " AND SE1.E1_NUM = NWF.NWF_TITULO "
	cQuery +=    " AND SE1.E1_PARCELA = '" + cParcAdi + "' "
	cQuery +=    " AND SE1.E1_TIPO = '" + cTipoAdi + "'  "
	cQuery +=    " AND SE1.E1_ORIGEM = 'JURA069'"
	cQuery +=    " AND SE1.E1_SALDO > 0 "
	cQuery +=    " AND SE1.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NVE.NVE_LCLIEN = NWF.NWF_CLOJA "
	cQuery +=    " AND NVE.NVE_CCLIEN = NWF.NWF_CCLIEN "
	cQuery +=    " AND NVE.NVE_NUMCAS = NWF.NWF_CCASO "
	cQuery +=    " AND NVE.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NWF.NWF_CMOE = CTO.CTO_MOEDA "
	cQuery +=    " AND NWF.D_E_L_E_T_ = ' ' "

	If lCpoExclus
		cQuery += " AND NWF.NWF_EXCLUS = '2' " // Adiantamentos não exclusivos
	EndIf

	// Verifica se existem adiantamentos utilizados via PE que não devem ser utilizados novamente
	If lJ203Adt
		cQuery += J203FilAdt()
	EndIf

	If lCpoExclus .And. lRetExeclu
		cQuery += " UNION "
		cQuery += " SELECT * FROM "
		cQuery += " ( SELECT SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_NATUREZ, CTO.CTO_SIMB, SE1.E1_VALOR, SE1.E1_SALDO, SE1.E1_HIST,  NWF.NWF_CCLIEN, "
		cQuery += " NWF.NWF_CLOJA, NWF.NWF_CCASO, NVE_TITULO, NWF.NWF_EXCLUS CODEXCL, "
		cQuery += " (CASE WHEN NWF_EXCLUS = '1' THEN '" + STR0101 + "' ELSE '" + STR0102 + "' END) NWF_EXCLUS, NWF.NWF_TPADI CODTPADI, " // "Sim" # "Não"
		If lCpoCota
			cQuery += "NWF.NWF_COTACA, "
		EndIf
		If lCpoGrsH
			cQuery += "SUM(NXC.NXC_VGROSH) NXC_VGROSH, "
		EndIf
		cQuery += " (CASE WHEN NWF.NWF_TPADI ='1' THEN '" + STR0226 + "'   ELSE " // "Despesas"
		cQuery += " (CASE WHEN NWF.NWF_TPADI ='2' THEN '" + STR0227 + "' ELSE 'Ambos' END) END) NWF_TPADI, " // "Honorários"
		cQuery += " NWF.NWF_CMOE, "
		cQuery += IIF(lCpoDtMov, " (CASE WHEN NWF.NWF_DTMOVI = ' ' THEN NWF.NWF_DATAIN ELSE NWF.NWF_DTMOVI END) DATAADI, ", " NWF.NWF_DATAIN DATAADI, ")
		cQuery += " CASE WHEN SUM(NXC.NXC_VLDFAT) > 0 THEN '1' ELSE '0' END TEMDESP, "
		cQuery += " CASE WHEN SUM(NXC.NXC_VLHFAT) > 0 THEN '2' ELSE '0' END TEMHON, "
		cQuery += " SUM(NXC.NXC_VLHFAT) NXC_VLHFAT, SUM(NXC.NXC_VLDFAT) NXC_VLDFAT, SE1.R_E_C_N_O_ SE1RECNO, NWF.R_E_C_N_O_ NWFRECNO "
		cQuery += " , SUM(NXC.NXC_VLHFAT)" + IIF(lCpoGrsH, " + SUM(NXC.NXC_VGROSH)", "") + " SALHONCAS, SUM(NXC.NXC_VLDFAT) SALDESCAS "
		cQuery += " FROM " + RetSqlName("SE1") + " SE1, " + RetSqlName("NWF") + " NWF, " + RetSqlName("NVE") + " NVE, " + RetSqlName("CTO") + " CTO, " + RetSqlName("NXC") + " NXC "
		cQuery += " WHERE NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
		cQuery += " AND NWF.NWF_FILIAL = '" + xFilial("NWF") + "' "
		cQuery += " AND CTO.CTO_FILIAL = '" + xFilial("CTO") + "' "
		cQuery += " AND SE1.E1_FILIAL  = '" + FWxFilial("SE1", cFilialNS7) + "' " //Filial Escritório
		cQuery += " AND SE1.E1_TIPO    = '" + cTipoAdi + "' "
		cQuery += " AND SE1.E1_CLIENTE = '" + cCliente + "' "
		cQuery += " AND SE1.E1_LOJA    = '" + cLoja + "' "
		cQuery += " AND SE1.E1_SALDO > 0 "
		cQuery += " AND SE1.E1_NUM = NWF.NWF_TITULO "
		// Verifica se existem adiantamentos utilizados via PE que não devem ser utilizados novamente
		If lJ203Adt
			cQuery += J203FilAdt()
		EndIf
		cQuery += " AND NXC.NXC_CFATUR = '" + cNumFat + "' "
		cQuery += " AND NXC.NXC_CCLIEN = NWF.NWF_CCLIEN "
		cQuery += " AND NXC.NXC_CLOJA = NWF.NWF_CLOJA "
		cQuery += " AND NXC.NXC_CCASO = NWF.NWF_CCASO "
		cQuery += " AND NVE.NVE_CCLIEN = NXC.NXC_CCLIEN "
		cQuery += " AND NVE.NVE_LCLIEN = NXC.NXC_CLOJA "
		cQuery += " AND NVE.NVE_NUMCAS = NXC.NXC_CCASO "
		cQuery += " AND SE1.E1_ORIGEM = 'JURA069' "
		cQuery += " AND NWF.NWF_CMOE = CTO.CTO_MOEDA "
		cQuery += " AND SE1.D_E_L_E_T_ = ' ' "
		cQuery += " AND NWF.D_E_L_E_T_ = ' ' "
		cQuery += " AND NVE.D_E_L_E_T_ = ' ' "
		cQuery += " AND NXC.D_E_L_E_T_ = ' ' "
		cQuery += " AND NWF.NWF_EXCLUS = '1' " // Adianatamento Exclusivo
		cQuery += " GROUP BY SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_NATUREZ, CTO.CTO_SIMB, SE1.E1_VALOR, SE1.E1_SALDO, SE1.E1_HIST, NWF.NWF_CCLIEN, "
		cQuery += "  NWF.NWF_CLOJA, NWF.NWF_CCASO, NVE_TITULO, NWF.NWF_EXCLUS, NWF.NWF_TPADI, NWF.NWF_CMOE, " + IIF(lCpoDtMov, " (CASE WHEN NWF.NWF_DTMOVI = ' ' THEN NWF.NWF_DATAIN ELSE NWF.NWF_DTMOVI END), ", " NWF.NWF_DATAIN, ") + IIF(lCpoCota, "NWF.NWF_COTACA, ", "") + IIF(lCpoGrsH, "NXC.NXC_VGROSH, ", "") + " SE1.R_E_C_N_O_, NWF.R_E_C_N_O_ ) QRYEXC " 
		cQuery += " WHERE QRYEXC.CODTPADI = QRYEXC.TEMDESP "
		cQuery += "  OR QRYEXC.CODTPADI = QRYEXC.TEMHON "
		cQuery += "  OR (QRYEXC.CODTPADI = '3' AND (QRYEXC.TEMDESP = '1' OR QRYEXC.TEMHON = '2')) "
	EndIf

	cQuery := ChangeQuery(cQuery)

Return (cQuery)

//-------------------------------------------------------------------
/*/{Protheus.doc} J203FilAdt
Monta filtro para desconsiderar adiantamentos que foram utilizados
via ponto de entrada e não devem ter o saldo residual consumido.

@return  cNotInAdt, caractere, Expressão de filtro da query de adiantamentos

@author  Jonatas Martins
@since   10/09/2018
/*/
//-------------------------------------------------------------------
Static Function J203FilAdt()
	Local cExpFiltro := ""
	Local cExcAdt    := ""
	Local cFiltroSql := ""
	
	If _lAdtPE // Permite o uso somento dos adiantamentos do PE
		cExpFiltro := "IN"
		AEval(_aAdtAuto, {|x| cExcAdt += IIF(x[6], ",'" + x[1] + "'", '')})
	Else
		cExpFiltro := "NOT IN"
		AEval(_aAdtAuto, {|x| cExcAdt += IIF(x[6], '', ",'" + x[1] + "'")})
	EndIf
	
	cFiltroSql += " AND SE1.E1_NUM " + cExpFiltro + " (" + IIF(Empty(cExcAdt), "''", SubStr(cExcAdt, 2)) + ")"

Return (cFiltroSql)

//-------------------------------------------------------------------
/*/{Protheus.doc} J203ConvAdi
Função utilizada para converter o valor do saldo do titulo RA na moeda
da fatura ou retornar ao valor da moeda do adiantamento

@Params  cMoefat	- Moeda da fatura
@Params  cMoeAdi	- Moeda do adiantamento
@Params  nValor		- Moeda da fatura
@Params  nRecAdi	- Recno do adiantamento
@Params  cTpExec	- Tipo de execução
@Params  cFila		- Fila de impressão
@params	 nCotac		- Cotação do Adiantamentos

@Retuns	 nValorConv	- Valor convertido

@author Luciano Pereira dos Santos
@since 11/05/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203ConvAdi(cMoeFat, cMoeAdi, nValor, dDtCotAdi,;
 							cTpExec, cFila, nCotac )
Local aArea      := GetArea()
Local cDtConvAd  := SuperGetMv('MV_JDTCVAD',, "1") // 1 - Data de inclusão do Adiantamento / 2 - Data de emissão da Fatura
Local aValorConv := {}
Local cMoedNac  := SuperGetMV( 'MV_JMOENAC',, '01' )
Local nTaxaFat  := 1 //Taxa da Moeda da Fatura

If cMoeFat != cMoeAdi
	If cDtConvAd == "1"
		If nCotac > 0
			If cMoeFat != cMoedNac 
				nTaxaFat := JA201FConv(cMoedNac, cMoeFat, 1, "1", dDtCotAdi)[2]
			EndIf
	
			aValorConv := JA201FConv(cMoeFat, cMoeAdi, nValor, "A", ;
									dDtCotAdi,,,,;
									,,,,;
									nCotac, nTaxaFat)
		Else
			
			aValorConv := JA201FConv(cMoeFat, cMoeAdi, nValor, "1", dDtCotAdi)
		EndIf
	Else
		dDtCotAdi  := JURA203G('FT', Date(), 'FATEMI')[1]
		aValorConv := JA201FConv(cMoeFat, cMoeAdi, nValor, cTpExec, dDtCotAdi, cFila)
	EndIf
Else
	aValorConv := {nValor, 1, 1, "", 1}
EndIf

RestArea(aArea)

Return aValorConv

//-------------------------------------------------------------------
/*/{Protheus.doc} JaRemPos
Remove itens do array (cria um novo array sem o item excluído)
Pois a Função ADEL() exclui o item mas mantém a posição vazia.

@param aArray, nPos

@author David G. Fernandes
@since 18/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JaRemPos(aArray, nPos)
Local ni
Local aRet := {}

	If !Empty(aArray)
		For ni := 1 To Len(aArray)
			If !Empty(aArray[ni]) .And. ni <> nPos
				aAdd(aRet, aArray[ni] )
			EndIf
		Next
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203ACTBT1
Confirma a utilização dos Adiantamentos

@param nVFatura, Valor liquído da Fatura
@param nVAdiant, Vaor utilizado de adiantamentos
                 (adiantamento utilizados automaticamente são somados junto com os utilizados manualmente)
@param aUtiliza, Array de adiantamentos utilizados manualmente
@author David G. Fernandes
@since 18/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203ACTBT1(nVFatura, nVAdiant, aUtiliza)
Local lRet       := .T.
Local nI         := 1
Local lTemAdt    := .F.

	For nI := 1 to Len(aUtiliza)
		If !Empty(aUtiliza[nI][2]) // Numero da SE1 do RA
			lTemAdt := .T.
			exit
		EndIf
	Next nI

	If !lTemAdt
		lRet := JurMsgErro(STR0144) //"Não foi utilizado nenhum adiantamento"
	Else
		If nVFatura == nVAdiant
			lRet := ApMsgYesNo(STR0145) //"Confirma a utilização dos Adiantamentos na baixa Total da Fatura?"
		Else
			lRet := ApMsgYesNo(STR0146) //"Confirma a utilização dos Adiantamentos na baixa Parcial da Fatura?"
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203ACTBT2
Cancela a utilização dos Adiantamentos

@author David G. Fernandes
@since 18/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203ACTBT2()
Local lRet := .T.

	lRet := ApMsgYesNo( STR0147 ) //"Deseja sair sem utilizar os Adiantamentos?"

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203ACTBT3
Valida e Adiciona adiantamentos para serem baixados na emissão da Fatura

@Params cTitulo, cMoeTitulo ,nSaldoAd,  nVUtilizar, nVFatura, nVRestante, nTotal, oListBox, aLista

@author David G. Fernandes
@since 18/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203ACTBT3( nRecnoSE1, cTitulo, cMoeTitulo, nSaldoAd, ;
							nVUtilizar, nVFatura, nVRestante, nTotal, ;
							oListBox, aLista, cSE1Hist, cDMoeda, ;
							cTrab)
Local lRet     := .T.
Local cMsg     := ""
Local cMsgSol  := ""
Local nPos     := ascan( aLista, {|ax| ax[2] == cTitulo} )
Local dDtAdi   := SToD((cTrab)->DATAADI)
Local lAdtExcl := NWF->(ColumnPos("NWF_EXCLUS")) > 0 .And. (cTrab)->CODEXCL == "1"
Local cPicture := PesqPict("NXC", "NXC_VLDFAT")
Local lRetPE   := .T.
Local aArea    := {}
Local lCpoCota := NWF->(ColumnPos("NWF_COTACA")) > 0
Local nCotaca  := IIF(lCpoCota, (cTrab)->NWF_COTACA, 0)

If Empty(nRecnoSE1) .Or. Empty(cTitulo)
	lRet := .F.
	cMsg := STR0187 // "Favor dar um duplo clique sobre o titulo que deseja utilizar no adiantamento"
Else

	If Empty(aLista)
		Aadd(aLista, {'', '', '' ,'', '', '', '', '', '','','', 0} )
	EndIf

	If Empty(nVUtilizar)
		lRet := .F.
		cMsg := STR0148 // "É preciso informar o Valor a utilizar."
	EndIf

	If lRet .And. (nVRestante - nVUtilizar) < 0
		lRet    := .F.
		cMsg    := STR0150                                                    // "O valor utilizado não pode ser maior do que o valor da fatura"
		cMsgSol := I18N(STR0286, {cDMoeda, Transform(nVRestante, cPicture)}) // "Informe um valor menor que #1#2."
	EndIf

	If lRet .And. !Empty(aLista[1][2])
		If (ascan( aLista, { |ax| ax[2] == cTitulo } ) > 0)
			lRet := .F.
			cMsg := STR0189 // "Titulo já utilizado, favor verifique"
		EndIf
	EndIf

	If lRet .And. (nVUtilizar > nSaldoAd)
		lRet    := .F.
		cMsg    := STR0149                                                  // "Não é possivel utilizar um valor maior do que o saldo."
		cMsgSol := I18N(STR0286, {cDMoeda, Transform(nSaldoAd, cPicture)}) // "Informe um valor menor que #1#2."
	EndIf

	// Valida valores de adiantamentos exclusivos
	If lRet .And. lAdtExcl
		lRet := J203VAdtEx(cTrab, nVUtilizar, cDMoeda, cPicture, @cMsg, @cMsgSol)
	EndIf

	// Ponte de entrada para validação ao clicar no botão de adicionar o adiantamento
	If lRet .And. ExistBlock("J203AdiB")
		aArea := GetArea()
		NWF->(DbGoTo((cTrab)->NWFRECNO))
		lRetPE := ExecBlock("J203AdiB", .F., .F.)
		lRet   := IIF(ValType(lRet) <> "L", .F., lRetPE)
		RestArea(aArea)
	EndIf

	If lRet
		If (nPos := ascan( aLista, {|ax| ax[2] == cTitulo} )) > 0
			nValor := GETDTOVAL(aLista[nPos][4])
			aLista[nPos][4] := Transform( nValor + nVUtilizar, "@E 99,999,999.99" )
			aLista[nPos][6] := cSE1Hist
		Else
			Aadd(aLista, {'', cTitulo, cDMoeda, Transform( nVUtilizar, "@E 99,999,999.99" ),;
						 nRecnoSE1,cSE1Hist, dDtAdi, cMoeTitulo, ;
						 nVUtilizar, .F., nSaldoAd, nCotaca})
		EndIf

		If aScan( aLista, { |ax| Empty(ax[2]) } ) > 0
			aLista := JaRemPos(aLista, ascan( aLista, { |ax| Empty(ax[2])  }  ))
		EndIf

		oListBox:SetArray( aLista )
		oListBox:bLine := { || {;
			aLista[oListBox:nAt, 1], ;
			aLista[oListBox:nAt, 2], ;
			aLista[oListBox:nAt, 3], ;
			aLista[oListBox:nAt, 4], ;
			aLista[oListBox:nAt, 6] } }
		oListBox:refresh()
		nTotal := nTotal + nVUtilizar
		nVRestante := nVFatura - nTotal

		If lAdtExcl
			J203SldExc(cTrab, nVUtilizar, .T.) // Atualiza saldo exclusivo de honorários ou despesa do caso
		EndIf
		
		nVUtilizar := 0
	EndIf
EndIf

If !lRet .And. lRetPE
	JurMsgErro(cMsg, , cMsgSol)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203VAdtEx
Validação de adiantamentos exclusivos

@param   cTrab     , caractere, Alias temporário da tabela de adiantamentos
@param   nVUtilizar, numerico , Valor do adiantamento digitado pelo usuário
@param   cSimbMoe  , caractere, Simbolo da moeda
@param   cPicture  , caractere, Máscara do campo de valor
@param   cMsg      , caractere, Mesnagem de erro da validação
@param   cMsgSol   , caractere, Mesnagem de solução da validação

@return  lRet      , logico   , Se verdadeiro permite a utilização do adiantamento

@author  Abner Fogaça / Jonatas Martins
@since   12/09/2018
@version 1.0
@obs     Variável cMsg e cMsgSol são passadas por referência na função J203ACTBT3
/*/
//-------------------------------------------------------------------
Static Function J203VAdtEx(cTrab, nVUtilizar, cSimbMoe, cPicture, cMsg, cMsgSol)
Local cTpAdt    := (cTrab)->CODTPADI
Local nValDCaso := (cTrab)->SALDESCAS
Local nValHCaso := (cTrab)->SALHONCAS
Local nTotCas   := nValDCaso + nValHCaso
Local lRet      := .T.

	If cTpAdt == "1" .And. nVUtilizar > nValDCaso // Despesas
		cMsg    := STR0283                                                   // "Valor utilizado do adiantamento é maior que o valor de despesas do caso!"
		cMsgSol := I18N(STR0286, {cSimbMoe, Transform(nValDCaso, cPicture)}) // "Informe um valor menor que #1#2."

	ElseIf cTpAdt == "2" .And. nVUtilizar > nValHCaso //Honorários
		cMsg    := STR0284                                                   // "Valor utilizado do adiantamento é maior que o valor de honorários do caso!"
		cMsgSol := I18N(STR0286, {cSimbMoe, Transform(nValHCaso, cPicture)}) // "Informe um valor menor que #1#2."
		
	ElseIf cTpAdt == "3" .And. nVUtilizar > nTotCas // Ambos
		cMsg    := STR0285                                                 // "Valor utilizado do adiantamento é maior que o valor do caso!"
		cMsgSol := I18N(STR0286, {cSimbMoe, Transform(nTotCas, cPicture)}) // "Informe um valor menor que #1#2."
	EndIf

	If ! Empty(cMsg)
		lRet := .F.
	EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203TIT
Geracao dos titulos Financeiros a partir da Fatura

@author Ernani Forastieri
@since 15/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA203TIT(cEscrit, cFatura, cTipoEmi)
Local aArea       := GetArea()
Local aAreaNS7    := NS7->( GetArea() )
Local aAreaSA1    := SA1->( GetArea() )
Local aAreaSE4    := SE4->( GetArea() )
Local aAreaSED    := {}
Local aImpostos   := { 0, 0, 0, 0, 0, 0 }
Local aParcDes    := {}
Local aParcHon    := {}
Local aParcelas   := {}
Local aSE1        := {}
Local cFatJur     := ""
Local cFilAtu     := cFilAnt
Local cHist       := ""
Local cFilEscr    := JurGetDados("NS7", 1, xFilial("NS7") + cEscrit, "NS7_CFILIA")
Local cNatHon     := PadR(SuperGetMV("MV_JNATFAT",, "", cFilEscr), TamSX3("ED_CODIGO")[1])
Local cNatDes     := PadR(SuperGetMV("MV_JNDESPE",, "", cFilEscr), TamSX3("ED_CODIGO")[1])
Local cNatureza   := ""
Local cParcela    := ""
Local cPrefixo    := PadR(SuperGetMV("MV_JPREFAT",, "PFS"), TamSX3("E1_PREFIXO")[1])
Local cTipo       := PadR(SuperGetMV("MV_JTIPFAT",, "FT"), TamSX3("E1_TIPO")[1])
Local cUltNum     := ""
Local lRet        := .T.
Local aRet        := {lRet, "" }
Local lValorDesp  := .F.
Local lValorHon   := .F.
Local nI          := 0
Local nValorDesp  := 0
Local nValorTotal := 0
Local cMoedNac    := SuperGetMV("MV_JMOENAC",, "01")
Local lPortador   := SuperGetMV("MV_JUSAPOR", .F., .T.) //Utiliza dados do portador da fatura/contrato
Local lParcUni    := SuperGetMv("MV_JPACUNI", .F., .T.) //Identif.se a o tit.unico tera o campo parcela prreenchido
Local lMultNat    := SuperGetMV("MV_MULNATR",, .F., cFilEscr)
Local lJA203SE1   := ExistBlock("JA203SE1")
Local nRecCli     := 0
Local cFileLog    := ""
Local aPercent    := {}
Local dDtBaseAux  := dDataBase
Local cMoedPre    := ""
Local nVlCruz     := 0
Local nVlCruzDv   := 0
Local nVlCruzSm   := 0
Local aAuxSEV     := {}
Local aRatSEV     := {}
Local nPercHon    := 0
Local nPercDsp    := 0
Local nValorHon   := 0
Local nValorDsp   := 0
Local nTotImpBas  := 0
Local nBaseCalc   := 0
Local nValIRF     := 0
Local nVlrInss    := 0
Local nVlrIss     := 0
Local xParcelas   := {}  //Variavel auxiliar para o retorno do ponto de entrada
Local aValTit     := {}
Local cMemoTit    := ""
Local cMemoLog    := ""
Local lServReinf  := NXA->(FieldPos("NXA_TPSERV")) > 0
Local aFKF        := Nil
Local lDespTrib   := NXA->(ColumnPos("NXA_VLREMB")) > 0
Local cBoleto     := ""
Local lProtJuros  := NXA->(ColumnPos("NXA_TXPERM")) > 0
Local aChaveSE1   := {}
Local lProtNatPg  := NXG->(ColumnPos("NXG_CNATPG")) > 0
Local lDistrImp   := .T.
Local cNatPag     := ""
Local cNatDesPE   := ""

Private lMsErroAuto := .F.

SA1->( dbSetOrder(1) ) //A1_FILIAL + A1_COD + A1_LOJA
NS7->( dbSetOrder(1) ) //NS7_FILIAL + NS7_COD
NXA->( dbSetOrder(1) ) //NXA_FILIAL + NXA_CESCR + NXA_COD
SE4->( DbSetOrder(1) ) //E4_FILIAL E4_CODIGO

ProcRegua(0)
IncProc()
IncProc()
IncProc()
IncProc()
IncProc()

If !(lRet := NXA->( DbSeek( xFilial("NXA") + cEscrit + cFatura ) ))
	cMemoLog += I18N(STR0268, {AllTrim(cEscrit + "|" + cFatura)}) //Não foi possível localizar a fatura '#1'.
EndIf

// Posiciona no escritorio da fatura para se identificar a filial de geracao correta
If lRet .And. !(lRet := NS7->( DbSeek( xFilial( 'NS7' ) + NXA->NXA_CESCR ) ))
	cMemoLog += (STR0287 + CRLF + STR0277 + cEscrit + cFatura) // "Não foi possível encontrar o escritório da fatura.  ""#"Escritório/Fatura: "#"."
EndIf

//Posiciona no Cliente para dar prosseguimento na geração
If lRet .And. !(lRet := SA1->( DbSeek( xFilial( 'SA1' ) + NXA->NXA_CLIPG + NXA->NXA_LOJPG ) ))
	cMemoLog += STR0087 + NXA->NXA_CLIPG + " / " + NXA->NXA_LOJPG  //#Cliente / Loja Inválidos:
EndIf

If lRet .And. !(SE4->(DbSeek( xFilial("SE4") + NXA->NXA_CCDPGT)))
	cMemoLog += I18N(STR0274, {AllTrim(NXA->NXA_CCDPGT)}) //"A condição de pagamento #1 não é válida."
EndIf

nRecCli := SA1->(Recno())

aValTit     := J203VlrTit(cEscrit, cFatura, cMoedNac)
nValorHon   := aValTit[1]
nValorDesp  := aValTit[2]
nTaxa       := aValTit[3]
cMoedPre    := aValTit[4]

lValorHon   := (nValorHon != 0)  // Sobre o valor de honorarios serão calculados os impostos
lValorDesp  := (nValorDesp != 0) // Sobre o valor de despesas nao incide impostos

nValorTotal := nValorHon + nValorDesp

cNatPag := IIf(lProtNatPg, JurGetDados("NXG", 3, xFilial("NXG") + NXA->NXA_CFILA + NXA->NXA_CLIPG + NXA->NXA_LOJPG, "NXG_CNATPG"), "") // Natureza do Pagador
If !Empty(cNatPag)
	cNatHon := cNatPag
ElseIf !Empty(SA1->A1_NATUREZ) // Natureza do Cliente
	cNatHon := SA1->A1_NATUREZ
EndIf

// Ponto de entrada para informar natureza de despesa
If lValorDesp .And. ExistBlock("J203NDes")
	cNatDesPE := ExecBlock("J203NDes", .F., .F., {cEscrit, cFatura, cNatDes})
	If ValType(cNatDesPE) == "C" .And. !Empty(cNatDesPE)
		cNatDes := cNatDesPE
	EndIf
EndIf

If lValorHon //Valida natureza para fatura
	If !Empty(cNatHon)

		SED->( DbSetOrder( 1 ) ) //ED_FILIAL+ED_CODIGO
		If !(SED->(DbSeek( xFilial("SED") + cNatHon)))
			cMemoLog += STR0244 + "'" + AllToChar(cNatHon) + "'" + STR0245 + CRLF + STR0246 //"O código de natureza de operação " ## " não é válido!" ### "Verifique o cadastro do cliente e o parametro MV_JNATFAT."
			lRet := .F.
		Else
			cNatureza := cNatHon
		EndIf
	Else
		cMemoLog += STR0243 + CRLF + STR0246 //"Natureza não preenchida, a fatura não será emitida." ## "Verifique o cadastro do cliente e o parametro MV_JNATFAT."
		lRet := .F.
	EndIf
Else //Valida natureza para faturas somente de despesas
	If !Empty(cNatDes)

		SED->( DbSetOrder( 1 ) ) //ED_FILIAL+ED_CODIGO
		If !(SED->(DbSeek( xFilial("SED") + cNatDes)))
			cMemoLog += STR0244 + "'" + AllToChar(cNatDes) + "'" + STR0245 + CRLF + STR0247 //"O código de natureza de operação " ## " não é válido!" ## "Verifique o parametro MV_JNDESPE.
			lRet := .F.
		Else
			cNatureza := cNatDes
		EndIf
	Else
		cMemoLog += STR0243 + CRLF + STR0247 //"Natureza não preenchida, a fatura não será emitida."  ## "Verifique o parametro MV_JNDESPE."
		lRet := .F.
	EndIf
EndIf

If Empty(NXA->NXA_DTEMI)
	cMemoLog += I18N(STR0275, {AllTrim(NXA->NXA_DTEMI)}) //"A data de emissão #1 não é válida."
	lRet := .F.
EndIf

If lRet

	aParcHon := Condicao( nValorHon , NXA->NXA_CCDPGT,, NXA->NXA_DTEMI )
	aParcDes := Condicao( nValorDesp, NXA->NXA_CCDPGT,, NXA->NXA_DTEMI )

	//Ponto de Entrada para possibilitar a alteração dos vencimentos das parcelas.
	If ExistBlock( 'JA203CN1' )
		If (Len(aParcHon) > 0)
			xParcelas := ExecBlock('JA203CN1', .F., .F., {"1", aParcHon})  //Honorarios

			If (ValType(xParcelas) == "A") .And. (Len(xParcelas) == Len(aParcHon))
				aParcHon := AClone(xParcelas)
			EndIf
		EndIf

		If (Len(aParcDes) > 0)
			xParcelas := ExecBlock('JA203CN1', .F., .F., {"2", aParcDes})  //Despesas

			If (ValType(xParcelas) == "A") .And. (Len(xParcelas) == Len(aParcDes))
				aParcDes := AClone(xParcelas)
			EndIf
		EndIf
	EndIf

	aParcelas := {}

	Do Case
	Case lValorHon .And. lValorDesp
		For nI := 1 To Len( aParcHon )
			//                  [1]Valor do titulo               , [2]Valor da base , [3]Vencimento   , [4]Honorarios  , [5]Despesas
			aAdd( aParcelas,  { aParcHon[nI][2] + aParcDes[nI][2], aParcHon[nI][2]  , aParcHon[nI][1] , aParcHon[nI][2], aParcDes[nI][2] } )
		Next
	Case lValorHon .And. !lValorDesp
		For nI := 1 To Len( aParcHon )
			//                  Valor do titulo , Valor da base  , Vencimento     , Honorarios     , Despesas
			aAdd( aParcelas,  { aParcHon[nI][2] , aParcHon[nI][2], aParcHon[nI][1], aParcHon[nI][2], 0.00 } )
		Next
	Case !lValorHon .And. lValorDesp
		For nI := 1 To Len( aParcDes )
			//                  Valor do titulo , Valor da base  , Vencimento     , Honorarios     , Despesas
			aAdd( aParcelas,  { aParcDes[nI][2] , 0.00           , aParcDes[nI][1], 0.00           , aParcDes[nI][2] } )
		Next
	Case !lValorHon .And. !lValorDesp
		aRet := {.F., STR0210 + CRLF + STR0235 + AllTrim(NXA->NXA_CFILA) }
		lErro := .T.
	EndCase

	cHist   := STR0125 + ': ' + NXA->NXA_CESCR + '|' + NXA->NXA_COD  //Fatura

	//Utilizado para incluir o titulo na filial correspondente do escritorio.
	cFilAnt := NS7->NS7_CFILIA
	cUltNum := NXA->NXA_COD
	cFatJur := xFilial( 'NXA' ) + '-' + NXA->NXA_CESCR + '-' + NXA->NXA_COD + '-' + cFilAnt

	Begin Transaction

		If cTipoEmi == "1" //Fatura -> Gera o(s) titulo(s) financeiros

			cParcela  := GetMv("MV_1DUP")
			nVlCruz   := 0
			nVlCruzDv := 0
			nVlCruzSm := 0
				
			AEVal(aParcelas, {|p| nTotImpBas += p[2]})

			For nI := 1 To Len( aParcelas )
				If nI != 1
					cParcela := Soma1( cParcela, TamSX3( 'E1_PARCELA' ) [1] )
				Else
					//Verifica se nao deve preencher o campo parcela caso seja apenas 1 titulo para a fatura
					If Len( aParcelas ) == 1 .and. ! lParcUni
						cParcela := Space( TamSx3( "E1_PARCELA" )[ 1 ] )
					EndIf

				EndIf

				IncProc(STR0117 + IIf(!Empty(cParcela), " (" + STR0221 + cParcela + ")", "") ) //Gerando Financeiro... #"Parcela: "

				// quando for apenas um parcela o valor pode ser alterado na fila de emissão
				If Len(aParcelas) == 1
					aParcelas[nI][3] := NXA->NXA_DTVENC
				EndIf

				//Reposiciona no cadastro de clientes
				SA1->( Dbgoto( nRecCli ) )

				// Gravacao do Titulo
				cMemoTit := ( STR0216                                 ) + CRLF //"Divergência na geração do título da fatura:"
				cMemoTit += ( Replicate('-',90)                       ) + CRLF
				cMemoTit += ( STR0217 + cFilAnt                       ) + CRLF //"Filial: "
				cMemoTit += ( STR0218 + SA1->(A1_COD + '-' + A1_LOJA) ) + CRLF //"Cliente: "
				cMemoTit += ( STR0219 + SA1->A1_NOME                  ) + CRLF //"Nome: "

				If !Empty(NXA->NXA_CPREFT)
					cMemoTit += (STR0055 + ": " + NXA->NXA_CPREFT     ) + CRLF //"Pré-Fatura"
				ElseIf !Empty(NXA->NXA_CFIXO)
					cMemoTit += (STR0056 + ": " + NXA->NXA_CFIXO      ) + CRLF //"Fixo"
				ElseIf !Empty(NXA->NXA_CFTADC)
					cMemoTit += (STR0057 + ": " + NXA->NXA_CFTADC     ) + CRLF //"Fatura Adicional"
				EndIf
				cMemoTit += ( STR0221 + cParcela                      ) + CRLF //"Parcela: "
				cMemoTit += ( Replicate('-', 90)                      ) + CRLF

				aSE1    := {}
				aRatSEV := {}
				aAdd(aChaveSE1, FWxFilial("SE1", NS7->NS7_CFILIA) + ;
				                 PadR(cPrefixo, TamSX3("E1_PREFIXO")[1]) +;
								 PadR(cUltNum , TamSX3("E1_NUM")[1]) +;
								 PadR(cParcela, TamSX3("E1_PARCELA")[1]) +;
								 PadR(cTipo, TamSX3("E1_TIPO")[1]))

				//*** Atenção: A mudança na ordem afeta a rotina de calculo na moeda estrangeira ***//
				aAdd( aSE1, { 'E1_PREFIXO', cPrefixo         , NIL } )
				aAdd( aSE1, { 'E1_NUM    ', cUltNum          , NIL } )
				aAdd( aSE1, { 'E1_PARCELA', cParcela         , NIL } )
				aAdd( aSE1, { 'E1_TIPO   ', cTipo            , NIL } )
				aAdd( aSE1, { 'E1_EMISSAO', NXA->NXA_DTEMI   , NIL } )
				aAdd( aSE1, { 'E1_VENCTO ', aParcelas[nI][3] , NIL } )
				aAdd( aSE1, { 'E1_NATUREZ', cNatureza        , NIL } )
				aAdd( aSE1, { 'E1_CLIENTE', SA1->A1_COD      , NIL } )
				aAdd( aSE1, { 'E1_LOJA   ', SA1->A1_LOJA     , NIL } )
				aAdd( aSE1, { 'E1_HIST   ', cHist            , NIL } )
				aAdd( aSE1, { 'E1_VEND1  ', SA1->A1_VEND     , NIL } )
				aAdd( aSE1, { 'E1_ORIGEM ', 'JURA203'        , NIL } )
				aAdd( aSE1, { 'E1_JURFAT ', cFatJur          , NIL } )

				dDataBase := NXA->NXA_DTEMI // Alteramos a data base do sistema para que seja gerado o financeiro com a mesma data que a fatura.

				//Verifica se serao herdados os dados bancarios da fatura/contrato
				If lPortador
					aAdd( aSE1, { 'E1_PORTADO', NXA->NXA_CBANCO , NIL } )
					aAdd( aSE1, { 'E1_AGEDEP ', NXA->NXA_CAGENC , NIL } )
					aAdd( aSE1, { 'E1_CONTA  ', NXA->NXA_CCONTA , NIL } )
				EndIf

				If NXA->NXA_FPAGTO == "1" // Depósito
					cBoleto := "2"
				ElseIf NXA->NXA_FPAGTO == "2" // Boleto
					cBoleto := "1"
				EndIf

				If SE1->(ColumnPos('E1_BOLETO')) > 0 //Proteção
					aAdd( aSE1, { 'E1_BOLETO ', cBoleto          , NIL } )
				EndIf

				// Calcula o Percentual do Rateio de Honorarios
				nValorHon := aParcelas[nI][4]
				nValorDsp := aParcelas[nI][5]

				nPercHon := ((nValorHon / (nValorHon + nValorDsp)) * 100.00) 
				nPercDsp := (100.00 - nPercHon)

				If nTotImpBas > 0
					aAreaSED := SED->(GetArea())
					RegToMemory("SE1", .T.,, .T.) // Cria variaveis do SE1 para chamada da rotina padrao
					SED->(DbSetOrder(1)) // ED_FILIAL + ED_CODIGO
					SED->(DbSeek(xFilial("SED") + cNatureza))
					// Faz a carga de valores para a chamada
					M->E1_NATUREZ := cNatureza
					M->E1_CLIENTE := SA1->A1_COD
					M->E1_LOJA    := SA1->A1_LOJA
					M->E1_MOEDA   := Val(NXA->NXA_CMOEDA)
					M->E1_TXMOEDA := nTaxa
					M->E1_VENCREA := aParcelas[nI][3]
					M->E1_TIPO    := cTipo
					M->E1_VALOR   := aParcelas[nI][1]
					M->E1_BASEIRF := nTotImpBas
					
					nValIRF       := F040CalcIr(nTotImpBas,,.T.)
					nVlrInss      := CalcINSS(nTotImpBas)
					nVlrIss       := IIf(JurGetDados("SED", 1, xFilial("SED") + cNatureza, "ED_CALCISS") == "S", FCalcISS( "R", /*dRefISS */, nTotImpBas, , SA1->A1_COD, SA1->A1_LOJA, .F.)[1][1], 0)

					M->E1_NATUREZ := Space(TamSX3("E1_NATUREZ")[1])
					M->E1_CLIENTE := Space(TamSX3("E1_CLIENTE")[1])
					M->E1_LOJA    := Space(TamSX3("E1_LOJA")[1])
					M->E1_MOEDA   := Space(TamSX3("E1_MOEDA")[1])
					M->E1_TXMOEDA := Space(TamSX3("E1_TXMOEDA")[1])
					M->E1_VENCREA := Space(TamSX3("E1_VENCREA")[1])
					M->E1_TIPO    := Space(TamSX3("E1_TIPO")[1])
					M->E1_VALOR   := Space(TamSX3("E1_VALOR")[1])
					M->E1_BASEIRF := Space(TamSX3("E1_BASEIRF")[1])
					RestArea(aAreaSED)
				EndIf

				If lMultNat
					// Considerar Múltiplas Naturezas devido a base dos Impostos
					aAdd( aSE1, { 'E1_MULTNAT', '1', NIL } )

					If cNatHon == cNatDes // Agrupra os valores quando for a mesma natureza para honorários e despesas
						aAuxSEV := {}
						// Vetor Referente a Valores de Honorários e Despesas
						aAdd( aAuxSEV, {"EV_NATUREZ" , cNatHon              , Nil }) // Natureza de Honorarios
						aadd( aAuxSEV, {"EV_VALOR"   , nValorHon + nValorDsp, Nil }) // Valor do rateio na natureza
						aadd( aAuxSEV, {"EV_PERC"    , nPercHon  + nPercDsp , Nil }) // Percentual do rateio na natureza
						aadd( aAuxSEV, {"EV_RATEICC" , "2"                  , Nil }) // Indicando que não há rateio por centro de custo
						aadd( aRatSEV, aAuxSEV)
					Else
						//Adicionando o vetor da natureza
						If lValorHon
							aAuxSEV := {}
							// Vetor Referente a Valores de Honorários
							aAdd( aAuxSEV, {"EV_NATUREZ" , cNatHon  , Nil })//natureza de Honorarios
							aadd( aAuxSEV, {"EV_VALOR"   , nValorHon, Nil })//valor do rateio na natureza
							aadd( aAuxSEV, {"EV_PERC"    , nPercHon , Nil })//percentual do rateio na natureza
							aadd( aAuxSEV, {"EV_RATEICC" , "2"      , Nil })//indicando que não há rateio por centro de custo
							aadd( aRatSEV, aAuxSEV)
						EndIf

						If lValorDesp
							aAuxSEV := {}
							// Vetor Referente a Valores de Despesas
							aAdd( aAuxSEV , {"EV_NATUREZ" , cNatDes  , Nil })//natureza de Depesa
							aAdd( aAuxSEV , {"EV_VALOR"   , nValorDsp, Nil })//valor do rateio na natureza
							aAdd( aAuxSEV , {"EV_PERC"    , nPercDsp , Nil })//percentual do rateio na natureza
							aAdd( aAuxSEV , {"EV_RATEICC" , "2"      , Nil })//indicando que não há rateio por centro de custo
							aAdd( aRatSEV, aAuxSEV)
						EndIf
					EndIf
				EndIf

				lDistrImp := J203ImpSE1(Len(aParcelas) > 1, aParcelas[nI][1], aParcelas[nI][2], nTotImpBas, @nBaseCalc, nValIRF, nVlrInss, nVlrIss, cNatureza, @cMemoLog, aParcelas[nI][3], nI) // Distribui os impostos IRF/INSS/ISS para primeira parcela do título.

				If lRet .And. !Empty(cMemoLog)
					lRet := .F.
				EndIf

				If lRet
					aAdd( aSE1, { 'E1_VALOR  ', aParcelas[nI][1], NIL } )

					If NXA->NXA_CMOEDA != cMoedNac
						aAdd( aSE1, { 'E1_MOEDA  ', Val( NXA->NXA_CMOEDA ) , NIL } )

						If cMoedPre  == cMoedNac //Ajuste de saldo para moeda nacional

							If lDespTrib
								nVlCruz   := (NXA->NXA_FATHMN + NXA->NXA_FATDMN + NXA->NXA_ACREMN - NXA->NXA_DESCMN + NXA->NXA_TXADMN + NXA->NXA_GROSMN)
							Else
								nVlCruz   := (NXA->NXA_FATHMN + NXA->NXA_FATDMN + NXA->NXA_ACREMN - NXA->NXA_DESCMN)
							EndIf
							nVlCruzDv := Round(nVlCruz / Len(aParcelas), TamSX3("E1_VLCRUZ")[2])
							nVlCruzSm += nVlCruzDv
							If nI == Len( aParcelas ) .AND. (nVlCruz - nVlCruzSm <> 0)
								nVlCruzDv += (nVlCruz - nVlCruzSm)
							EndIf
							aAdd( aSE1, { 'E1_VLCRUZ ', nVlCruzDv, ".T." } )
						EndIf

						aAdd( aSE1, { 'E1_TXMOEDA', nTaxa      , NIL } )

					EndIf

					aPercent  := J203PerNat(cNatHon, NXA->NXA_CLIPG, NXA->NXA_LOJPG)

					If aPercent[1] > 0.00
						If nI == 1 .And. lDistrImp // Se for a primeira parcela distribui todo o valor base dos impostos IRRF/INSS/ISS
							aAdd( aSE1, { 'E1_BASEIRF', nBaseCalc, ".T." } )
							aAdd( aSE1, { 'E1_BASEINS', nBaseCalc, ".T." } )
							aAdd( aSE1, { 'E1_BASEISS', nBaseCalc, ".T." } )
						Else
							aAdd( aSE1, { 'E1_BASEIRF', 0, ".T." } )
							aAdd( aSE1, { 'E1_BASEINS', 0, ".T." } )
							aAdd( aSE1, { 'E1_BASEISS', 0, ".T." } )
						EndIf
					EndIf
					If aPercent[2] > 0.00
						aAdd( aSE1, { 'E1_BASEPIS', aParcelas[nI][2], ".T." } )
					EndIf
					If aPercent[3] > 0.00
						aAdd( aSE1, { 'E1_BASECOF', aParcelas[nI][2], ".T." } )
					EndIf
					If aPercent[4] > 0.00
						aAdd( aSE1, { 'E1_BASECSL', aParcelas[nI][2], ".T." } )
					EndIf

					If lServReinf
						If !Empty(NXA->NXA_TPSERV)
							aFKF := {{ "FKF_TPSERV", NXA->NXA_TPSERV, NIL }}
						EndIf
					EndIf

					If lProtJuros
						aAdd( aSE1, { 'E1_VALJUR' , NXA->NXA_TXPERM , NIL } )
						aAdd( aSE1, { 'E1_PORCJUR', NXA->NXA_PJUROS , NIL } )
						aAdd( aSE1, { 'E1_DESCFIN', NXA->NXA_DESFIN , NIL } )
						aAdd( aSE1, { 'E1_DIADESC', NXA->NXA_DIADES , NIL } )
						aAdd( aSE1, { 'E1_TIPODES', NXA->NXA_TPDESC , NIL } )
					EndIf

					dbSelectArea( 'SE1' )
					SE1->( dbSetOrder( 1 ) )

					lMsErroAuto := .F.

					If lServReinf .And. aFKF != Nil
						MsExecAuto( { |a,b,c,d,e,f,g| FINA040(a,b,c,d,e,f,g)}, aSE1, 3,, aRatSEV,, aFKF,)
					Else
						MSExecAuto( { |x,y,z,a| FINA040(x,y,z,a) }, aSE1, 3, , aRatSEV )
					EndIf

					If lMsErroAuto
						lRet := .F.
						cFileLog := NomeAutoLog()
						cMemoTit += MemoRead(cFileLog) + CRLF
						cMemoTit +=( Replicate('-',90)) + CRLF + CRLF
						
						DisarmTransaction()

						If !Empty(cFileLog)
							FErase( cFileLog )
						EndIf

						cMemoLog += cMemoTit
						Exit

					Else

						aRet := J203VerImp(aSE1, cTipoEmi, @aImpostos, cFilAnt, NXA->NXA_CMOEDA) //Verifica os impostos e alimenta o array aImpostos
						If aRet[1]
							If __lSX8
								ConFirmSX8()
							EndIf

							If lJA203SE1
								ExecBlock( "JA203SE1", .F., .F. )
							EndIf


						Else
						
							lRet := .F.
							cMemoTit += aRet[2] + CRLF
							cMemoTit += ( Replicate('-', 90)) + CRLF + CRLF
							cMemoLog += cMemoTit
							
							DisarmTransaction()
							Exit
						EndIf
					EndIf
				EndIf
			Next nI

			If FWAliasInDic("OHT") .And. FindFunction("JurTitFat")
				JurTitFat(aChaveSE1, NXA->(Recno()))
			EndIf

		ElseIf cTipoEmi $ "2|3|4" //Minuta de Fatura/Pre Fatura/Minuta de Sócio -> Gera Simulacao de impostos

			For nI := 1 To Len( aParcelas )

				aSE1 := {}

				aAdd( aSE1, { "E1_TIPO"      , AvKey("FT", "E1_TIPO"), NIL } )
				aAdd( aSE1, { "E1_NATUREZ"   , cNatureza             , NIL } )
				aAdd( aSE1, { "E1_CLIENTE"   , SA1->A1_COD           , NIL } )
				aAdd( aSE1, { "E1_LOJA"      , SA1->A1_LOJA          , NIL } )
				aAdd( aSE1, { "E1_MULTNAT"   , "2"                   , NIL } )
				aAdd( aSE1, { "E1_VALOR"     , aParcelas[nI][1]      , NIL } )
				aAdd( aSE1, { "E1_IRRF"      , 0                     , NIL } )
				aAdd( aSE1, { "E1_ISS"       , 0                     , NIL } )
				aAdd( aSE1, { "E1_INSS"      , 0                     , NIL } )
				aAdd( aSE1, { "E1_PIS"       , 0                     , NIL } )
				aAdd( aSE1, { "E1_COFINS"    , 0                     , NIL } )
				aAdd( aSE1, { "E1_CSLL"      , 0                     , NIL } )
				aAdd( aSE1, { "E1_VENCTO"    , aParcelas[nI][3]      , NIL } )
				aAdd( aSE1, { "E1_VENCREA"   , aParcelas[nI][3]      , NIL } )
				If NXA->NXA_CMOEDA != cMoedNac
					aAdd( aSE1, { "E1_MOEDA"  , Val(NXA->NXA_CMOEDA), NIL } )
					aAdd( aSE1, { "E1_TXMOEDA", nTaxa               , NIL } )
				EndIf
				aAdd( aSE1, { "E1_BASEIRF"   , aParcelas[nI][2]    , NIL  } )
				aAdd( aSE1, { 'E1_BASEPIS'   , aParcelas[nI][2]    , NIL  } )
				aAdd( aSE1, { 'E1_BASECOF'   , aParcelas[nI][2]    , NIL  } )
				aAdd( aSE1, { 'E1_BASECSL'   , aParcelas[nI][2]    , NIL  } )

				//Verifica os impostos e alimenta o array aImpostos
				aRet := J203VerImp(aSE1, cTipoEmi, @aImpostos, cFilAnt, NXA->NXA_CMOEDA)

				If !aRet[1]
					lRet := .F.
					cMemoTit += aRet[2] + CRLF
					cMemoTit += ( Replicate('-', 90)) + CRLF + CRLF
					cMemoLog += cMemoTit
					
					DisarmTransaction()
				EndIf

			Next nI

		Else
			lRet := .F.
		EndIf

		If lRet

			aPercent := J203PerNat(cNatHon, NXA->NXA_CLIPG, NXA->NXA_LOJPG)

			RecLock('NXA', .F.)
			NXA->NXA_TITGER := '1'
			NXA->NXA_IRRF   := aImpostos[1]
			NXA->NXA_ISS    := aImpostos[2]
			NXA->NXA_INSS   := aImpostos[3]
			NXA->NXA_PIS    := aImpostos[4]
			NXA->NXA_COFINS := aImpostos[5]
			NXA->NXA_CSLL   := aImpostos[6]
			NXA->NXA_PIRRF  := Iif (aImpostos[1] > 0.00, aPercent[1], 0)
			NXA->NXA_PPIS   := Iif (aImpostos[4] > 0.00, aPercent[2], 0)
			NXA->NXA_PCOFIN := Iif (aImpostos[5] > 0.00, aPercent[3], 0)
			NXA->NXA_PCSLL  := Iif (aImpostos[6] > 0.00, aPercent[4], 0)
			NXA->NXA_PINSS  := Iif (aImpostos[3] > 0.00, aPercent[5], 0)
			NXA->NXA_DOC    := " "  //
			NXA->NXA_SERIE  := " "  // Campos de associacao a notas fiscais (SD2)

			NXA->(MsUnLock())
			NXA->(DbCommit())

			J170GRAVA("NXA", xFilial("NXA") + NXA->NXA_CESCR + NXA->NXA_COD, "4")

		EndIf

	End Transaction

EndIf

cFilAnt   := cFilAtu
dDataBase := dDtBaseAux

aRet := {lRet, "" + Iif(!Empty(cMemoLog ), CRLF + cMemoLog, "") }

RestArea( aAreaSE4 )
RestArea( aAreaSA1 )
RestArea( aAreaNS7 )
RestArea( aArea    )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203VlrTit
Função utilizada retornar o valor usados para emitir o titulo e a moeda da
Pré-fatura, fatura adicional ou Fixo.

@Param  cEscrit   - Escritório da Fatura
@Param  cFatura   - Código da fatura
@Param  cMoedNac  - Moeda nacional

@return array(4) - array[1] Valor de honorários do titulo
                 - array[2] Valor de despesas do titulo
                 - array[3] Taxa de conversão usada no titulo
                 - array[4] Moeda da Pré-fatura, Fatura Adicional ou Fixo

@author Luciano Pereira dos Santos
@since  04/08/2015
/*/
//-------------------------------------------------------------------
Function J203VlrTit(cEscrit, cFatura, cMoedNac)
Local aArea     := GetArea()
Local aAreaNXA  := NXA->( GetArea() )
Local cTpConF   := SuperGetMv('MV_JTPCONF',, '1') // Cotação usada nos titulos '1' = Mesma da Fatura / '2' = Cotação Diária
Local aValConv  := {}
Local nTaxa     := 0
Local nValorHon := 0
Local nValorDes := 0
Local cMoedPre  := ''
Local lDespTrib := NXA->(ColumnPos('NXA_VLTRIB')) > 0
Local nValGrosH := IIF(NXA->(ColumnPos("NXA_VGROSH")) > 0, NXA->NXA_VGROSH, 0) // @12.1.2310

Default cEscrit  := ""
Default cFatura  := ""
Default cMoedNac := ""

NXA->(dbSetOrder(1))
If (NXA->( dbSeek( xFilial("NXA") + cEscrit + cFatura  ) ))

	If !Empty(NXA->NXA_CPREFT)
		cMoedPre := JurGetDados("NX0", 1, xFilial("NX0") + NXA->NXA_CPREFT, "NX0_CMOEDA")
	ElseIf !Empty(NXA->NXA_CFTADC)
		cMoedPre := JurGetDados("NVV", 1, xFilial("NVV") + NXA->NXA_CFTADC, "NVV_CMOE3")
	ElseIf !Empty(NXA->NXA_CFIXO)
		cMoedPre := JurGetDados("NT0", 1, xFilial("NT0") + NXA->NXA_CCONTR, "NT0_CMOE")
	Else
		cMoedPre := NXA->NXA_CMOEDA
	EndIf

	If cTpConF == '1' // Mesma cotação da fatura (usa o mesmo valor convertido da fatura)
		If lDespTrib
			nValorDes := Round(NXA->NXA_VLREMB, TamSX3("E1_VALOR")[2])
			nValorHon := Round(NXA->(NXA_VLFATH - NXA_VLDESC + NXA_VLACRE + NXA_VLTOTD + nValGrosH), TamSX3("E1_VALOR")[2])
		Else
			nValorDes := Round(NXA->NXA_VLFATD, TamSX3("E1_VALOR")[2])
			nValorHon := Round(NXA->(NXA_VLFATH - NXA_VLDESC + NXA_VLACRE + nValGrosH), TamSX3("E1_VALOR")[2])
		EndIf

		aValConv  := JA201FConv(cMoedNac, NXA->NXA_CMOEDA, 1000, "8", NXA->NXA_DTEMI, NXA->NXA_CFILA,/*cpreft*/, /*cXfilial*/ , NXA->NXA_CESCR, NXA->NXA_COD)	//Utilizado a opção '8' para considerar a mesmas cotações negociadas na fatura - o 'cpreft' é o código da fatura + escritório
		nTaxa     := aValConv[2]

	ElseIf cTpConF == '2' // Cotação do titulo diária (faz a conversão do valor na moeda nacional para a cotação diária na moeda do titulo)
		If lDespTrib
			nValorHon := NXA->(NXA_FATHMN - NXA_DESCMN + NXA_ACREMN + NXA_TXADMN + NXA_GROSMN + NXA_TRIBMN + nValGrosH)
			nValorDes := NXA->NXA_REMBMN
		Else
			nValorHon := NXA->(NXA_FATHMN - NXA_DESCMN + NXA_ACREMN + nValGrosH)
			nValorDes := NXA->NXA_FATDMN
		EndIf

		aValConv  := JA201FConv(NXA->NXA_CMOEDA, cMoedNac, nValorHon, "8", NXA->NXA_DTEMI, NXA->NXA_CFILA,/*cpreft*/, /*cXfilial*/ , NXA->NXA_CESCR, NXA->NXA_COD)	//Utilizado a opção '8' para considerar a mesmas cotações negociadas na fatura - o 'cpreft' é o código da fatura + escritório
		nValorHon := Round(aValConv[1], TamSX3("E1_VALOR")[2])
		If nValorHon > 0
			nTaxa  := aValConv[3]
		EndIf

		aValConv  := JA201FConv(NXA->NXA_CMOEDA, cMoedNac, nValorDes, "8", NXA->NXA_DTEMI, NXA->NXA_CFILA,/*cpreft*/, /*cXfilial*/ , NXA->NXA_CESCR, NXA->NXA_COD)	//Utilizado a opção '8' para considerar a mesmas cotações negociadas na fatura - o 'cpreft' é o código da fatura + escritório
		nValorDes := Round(aValConv[1], TamSX3("E1_VALOR")[2])
		If nValorDes > 0
			nTaxa  := aValConv[3]
		EndIf
	EndIf

EndIf

RestArea( aAreaNXA )
RestArea( aArea    )

Return {nValorHon, nValorDes, nTaxa, cMoedPre}

//-------------------------------------------------------------------
/*/{Protheus.doc} J203CtrAdi
Função utilizada para inserir o valor de adiantamento no controle de adiantamentos.

@author Felipe Bonvicini Conti
@since 17/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203CtrAdi(cNXA_CLIPG, cNXA_LOJPG, cNXA_CMOEDA, cNXA_CBANCO, cNXA_CAGENC, cNXA_CCONTA, cNXA_VSADIA, cEscr, cDtVenc, cFatura)
Local lRet       := .T.
Local lAux       := .T.
Local oModel     := Nil
Local aCampos    := {}
Local aErro      := {}
Local nI         := 1
Local cHistorico := Substr(SuperGetMV("MV_JHSTCTR",, ""), 1, TamSX3("NWF_HIST")[1])
Local cCliCas    := ""
Local cLojCas    := ""
Local cCaso      := ""

DbSelectArea("NXC")
NXC->( dbSetOrder( 1 ) ) // NXC_FILIAL+NXC_CESCR+NXC_CFATUR+NXC_CCLIEN+NXC_CLOJA+NXC_CCONTR+NXC_CCASO
If NXC->( dbSeek( xFilial("NXC") + cEscr + cFatura ) )
	cCliCas := NXC->NXC_CCLIEN
	cLojCas := NXC->NXC_CLOJA
	cCaso   := NXC->NXC_CCASO
EndIf

oModel := FWLoadModel("JURA069")
oModel:SetOperation(3)
oModel:Activate()

oAux    := oModel:GetModel("NWFMASTER")
oStruct := oAux:GetStruct()
aAux    := oStruct:GetFields()

aAdd(aCampos, {"NWF_DATAIN", Date()     })
aAdd(aCampos, {"NWF_CCLIEN", cCliCas    })
aAdd(aCampos, {"NWF_CLOJA",  cLojCas    })
aAdd(aCampos, {"NWF_CCASO",  cCaso      })
aAdd(aCampos, {"NWF_CCLIAD", cNXA_CLIPG })
aAdd(aCampos, {"NWF_CLOJAD", cNXA_LOJPG })
aAdd(aCampos, {"NWF_TPADI",  "3"        }) // 3-Ambos - Despesas e Honorários
aAdd(aCampos, {"NWF_CMOE",   cNXA_CMOEDA})
aAdd(aCampos, {"NWF_VALOR",  cNXA_VSADIA})
aAdd(aCampos, {"NWF_HIST",   cHistorico })
aAdd(aCampos, {"NWF_VENCTO", StoD(cDtVenc)})
aAdd(aCampos, {"NWF_BANCO",  cNXA_CBANCO})
aAdd(aCampos, {"NWF_AGENCI", cNXA_CAGENC})
aAdd(aCampos, {"NWF_CONTA",  cNXA_CCONTA})
aAdd(aCampos, {"NWF_CESCR",  cEscr})

For nI := 1 To Len(aCampos)
	If !(lAux := oModel:SetValue("NWFMASTER", aCampos[nI][1], aCampos[nI][2] ) )
		lRet := .F.
		Exit
	Endif
Next nI

If lRet .And. oModel:VldData()
	oModel:CommitData()
Else
	lRet  := .F.
	aErro := oModel:GetErrorMessage()
EndIf

If !lRet
	JurMsgErro(STR0118 + CRLF + STR0277 + cEscr + cFatura, , STR0278 ) //"O Controle de Adiantamento não foi inserido!"#"Escritório/Fatura: "#"Necessário fazer a criação manual do Controle de Adiantamento."
EndIf

oModel:DeActivate()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203Exc()
Função para excluir registro da fila de impressão.

@author Luciano Pereira dos Santos
@since 19/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203Exclui()
Local aArea  := GetArea()

If ApMsgYesNo(STR0206) // "Deseja excluir o registro da fila de impressão?"
	JA203Apag()
EndIf

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203Apag()
Função para excluir registro da fila e seus vínculos.

@Param nNX5Recno Registro da NX5
@Param lEmissao  .T. A rotina esta sendo chamada pela emissão e não apaga os 
                     Os pagadores e encaminhamentos de fatura de parcela de fixo

@author Luciano Pereira dos Santos
@since 05/11/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA203Apag(nNX5Recno, lEmissao)
Local aArea       := GetArea()

Default nNX5Recno := NX5->(Recno())
Default lEmissao  := .F.

NX5->(DbGoto(nNX5Recno))

If !NX5->(Eof())

	J203DelPag(NX5->NX5_COD, lEmissao) // Remover os pagadores e encaminhamentos de fatura da fila de impressão

	NX6->(DbSetOrder(1)) //NX6_FILIAL+NX6_CFILA+NX6_CMOEDA
	While NX6->(DbSeek(xFilial('NX6') + NX5->NX5_COD))
		If RecLock("NX6", .F.)
			NX6->( dbdelete() )
			NX6->( MsUnLock() )
		EndIf
	EndDo

	NX7->(DbSetOrder(1)) //NX7_FILIAL+NX7_CFILA+NX7_CCLIEN+NX7_CLOJA+NX7_CCASO
	While NX7->(DbSeek( xFilial('NX7') + NX5->NX5_COD))
		If RecLock("NX7", .F.)
			NX7->( dbdelete() )
			NX7->( MsUnLock() )
		EndIf
	EndDo

	If RecLock("NX5", .F.)
		NX5->( dbDelete() )
		NX5->( MsUnLock() )
	EndIf

EndIf

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J203DelPag
Rotina para Remover os pagadores e encaminhamento de fatura da fila de impressão

@Param cFila     Codigo da fila de emissão
@Param cOperacao Operação para o registro: 'A'- Adiciona; 'R'-Remove; 'D' deleta o registro

@author Luciano Pereira dos Santos
@since  28/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203DelPag(cFila, lEmissao)
	Local aArea      := GetArea()
	Local cQuery     := ""
	Local aNXG       := {}
	Local nI         := 0

	Default lEmissao := .F.

	cQuery := " SELECT NXG.R_E_C_N_O_ NXGRECNO "
	cQuery +=   " FROM " + RetSqlName("NXG") + " NXG "
	cQuery +=  " WHERE NXG.NXG_FILIAL = '" + xFilial("NXG") + "' "
	cQuery +=    " AND NXG.NXG_FILA = '" + cFila + "' "
	cQuery +=    " AND NXG.D_E_L_E_T_ = ' ' "

	aNXG := JurSQL(cQuery, {"NXGRECNO"})

	For nI := 1 To Len(aNXG)
		NXG->(DBGoto(aNXG[nI][1]))
		If !Empty(NXG->NXG_CFIXO) .And. !lEmissao // Remove o fixo da fila ou fecha a fila de emissão
			J203EncFila(NXG->NXG_FILA, , , NXG->NXG_CFIXO, NXG->NXG_CLIPG, NXG->NXG_LOJAPG, "D") // Deleta o encaminhamento da fila quando fixo
			RecLock("NXG", .F.)
			NXG->(dbdelete())
			NXG->(MsUnLock())
		ElseIf !Empty(NXG->NXG_CPREFT) .Or. !Empty(NXG->NXG_CFATAD) // Pré-fatura e Fatura Adicional, somente limpa a fila
			J203EncFila(NXG->NXG_FILA, NXG->NXG_CPREFT, NXG->NXG_CFATAD, , NXG->NXG_CLIPG, NXG->NXG_LOJAPG, "R") // Remove o encaminhamento da fila
			RecLock("NXG", .F.)
			NXG->NXG_FILA := ""
			NXG->(MsUnLock())
		EndIf
	Next nI

	JurFreeArr(@aNXG)

	RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J203EncFila
Rotina para Adiciona/Remover da fila de impressão os encaminhamento de fatura

@Param cFila     Codigo da fila de emissão
@Param cCodPre   Codigo da pré-fatura
@Param cFatAdic  Codigo do fatura adicional
@Param cFixo     Codigo do Fixo
@Param cCliePag  Codigo do cliente pagador
@Param cLojaPag  Codigo da loja do cliente pagador
@Param cOperacao Operação para o registro: 'A'- Adiciona; 'R'-Remove; 'D' deleta o registro

@author Luciano Pereira dos Santos
@Date 28/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203EncFila(cFila, cCodPre, cFatAdic, cFixo, cCliePag, cLojaPag, cOperacao)
Local aArea     := GetArea()
Local cSQL      := ""
Local aNVN      := {}
Local nI        := 0
Local lFila     := NVN->(ColumnPos("NVN_CFILA")) > 0 // Proteção
Local lNVNVinc  := .T.

If lFila
	cSQL :=      " SELECT NVN.R_E_C_N_O_ NVNRECNO "
	cSQL +=        " FROM " + RetSqlName("NVN") + " NVN "
	cSQL +=       " WHERE NVN.NVN_FILIAL = '" + xFilial("NVN") + "' "
	If cOperacao == "A" // Quando for exclusão (R/D) não aplicar esses filtros, somente o de fila
		If !Empty(cCodPre)
			cSQL += " AND NVN.NVN_CPREFT = '" + cCodPre  + "' "
		ElseIf !Empty(cFatAdic)
			cSQL += " AND NVN.NVN_CFATAD = '" + cFatAdic + "' "
		ElseIf !Empty(cFixo) .And. NVN->(ColumnPos("NVN_CFIXO")) > 0 // Regra + Proteção
			cSQL += " AND NVN.NVN_CFIXO = '" + cFixo + "' "
		EndIf
	EndIf
	cSQL +=         " AND NVN.NVN_CLIPG = '" + cCliePag + "' "
	cSQL +=         " AND NVN.NVN_LOJPG = '" + cLojaPag + "' "
	If cOperacao $ "R|D"
		cSQL +=     " AND NVN.NVN_CFILA = '" + cFila + "' "
	EndIf
	cSQL +=         " AND NVN.D_E_L_E_T_ = ' ' "

	aNVN := JurSQL(cSQL, {"NVNRECNO"})

	For nI := 1 To Len(aNVN)
		NVN->(DBGoto(aNVN[nI][1]))
		lNVNVinc := IIf(cOperacao == "R", J203NVNVin(cFila), .T.)
		RecLock('NVN', .F.)
		If cOperacao $ "A|R"
			If lNVNVinc
				NVN->NVN_CFILA  := IIF(cOperacao == "A", cFila, "")
			Else // Se o registro não possuir vínculo será excluído ao invés de limpar a fila
				NVN->(dbDelete())
			EndIf
		ElseIf cOperacao == "D"
			NVN->(dbDelete())
		EndIf
		NVN->(MsUnlock())
		NVN->(DbCommit())
	Next nI

	RestArea(aArea)
EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203VDESC()
Validacao dos campos de desconto da fila de impressao

@author TOTVS
@since 19/09/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA203VDESC(cCampo)
Local lRet      := .F.
Local oModel    := FWModelActive()
Local oModelNX5 := oModel:GetModel("NX5MASTER")

Do Case
Case cCampo == "NX5_DESCH"
	If oModelNX5:GetValue("NX5_DESCH") > oModelNX5:GetValue("NX5_VLFATH") .Or. oModelNX5:GetValue("NX5_DESCH") < 0
		lRet := JurMsgErro(STR0222) // "O valor de Desconto não pode ser maior que o valor de Honorários ou menor que zero! "
	Else
		lRet := oModelNX5:LoadValue( "NX5_PDESCH", oModelNX5:GetValue("NX5_DESCH") / oModelNX5:GetValue("NX5_VLFATH") * 100 )
	EndIf
Case cCampo == "NX5_PDESCH"
	If oModelNX5:GetValue("NX5_PDESCH") > 100 .Or. oModelNX5:GetValue("NX5_PDESCH") < 0
		lRet := JurMsgErro(STR0222) // "O valor de Desconto não pode ser maior que o valor de Honorários ou menor que zero! "
	Else
		lRet := oModelNX5:LoadValue( "NX5_DESCH", oModelNX5:GetValue("NX5_VLFATH") * oModelNX5:GetValue("NX5_PDESCH") / 100 )
	EndIf
OtherWise
	lRet := .F.
EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203VACRS()
Validacao dos campos de acrescimo da fila de impressao

@author Daniel Magalhaes
@since 19/11/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA203VACRS(cCampo)
Local lRet      := .F.
Local oModel    := FWModelActive()
Local oModelNX5 := oModel:GetModel("NX5MASTER")

If oModelNX5:GetValue("NX5_ACRESH") < 0 .Or. oModelNX5:GetValue("NX5_PACREH") < 0
	lRet := JurMsgErro(STR0223) // "O valor de Acréscimo não pode ser menor que zero! "
Else
	Do Case
	Case cCampo == "NX5_ACRESH"
		lRet := oModelNX5:LoadValue( "NX5_PACREH", oModelNX5:GetValue("NX5_ACRESH") / oModelNX5:GetValue("NX5_VLFATH") * 100 )
	Case cCampo == "NX5_PACREH"
		lRet := oModelNX5:LoadValue( "NX5_ACRESH", oModelNX5:GetValue("NX5_VLFATH") * oModelNX5:GetValue("NX5_PACREH") / 100 )
	OtherWise
		lRet := .F.
	EndCase
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203COT()
Função para ajustar cotação a partir da alteração da moeda do pagador
na fila de impressão acionada pelo campo

@author Luciano Pereira dos Santos
@since 31/10/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA203COT()
Local lRet      := .T.
Local oModel    := Nil
Local oModelNX5 := Nil
Local oModelNXG := Nil
Local oModelNX6 := Nil
Local oModelNXR := Nil
Local oModelNX0 := Nil
Local nQtdNXR   := 0
Local nINXG     := 0
Local nINX6     := 0
Local nINXR     := 0
Local lMoeda    := .F.
Local aConv     := {}
Local aCotac    := {}
Local cFila     := ""
Local cMoedaNac := SuperGetMv('MV_JMOENAC',,'01' )
Local cPreFat   := ""
Local aSaveLns  := {}
Local aDelet    := {}
Local dDtEmiss  := CToD( '  /  /  ' )

If IsInCallStack( 'JURA203' )

	oModel    := FWModelActive()
	oModelNX5 := oModel:GetModel("NX5MASTER")
	oModelNXG := oModel:GetModel('NXGDETAIL')
	oModelNX6 := oModel:GetModel('NX6DETAIL')
	aSaveLns  := FWSaveRows()
	dDtEmiss  := JURA203G( 'FT', Date(), 'FATEMI' )[1]

	For nINXG := 1 To oModelNXG:GetQtdLine()
		oModelNXG:GoLine( nINXG )
		lMoeda := .F.
		For nINX6 := 1 To oModelNX6:GetQtdLine()
			oModelNX6:GoLine( nINX6 )
			If oModelNXG:GetValue("NXG_CMOE") == oModelNX6:GetValue("NX6_CMOEDA")
				If oModelNX6:IsDeleted()
					oModelNX6:UnDeleteLine()
				EndIf
				lMoeda := .T.
				Exit
			EndIf
		Next nINX6

		If !lMoeda
			cMoePag := oModelNXG:GetValue("NXG_CMOE", nINXG)
			cMoeFat := oModelNX5:GetValue("NX5_CMOEFT")
			cFila   := oModelNX5:GetValue("NX5_COD")

			aConv := JA201FConv(cMoeFat, cMoePag, 1000, "1", dDtEmiss, /*cFila*/ , /*cCodCont*/, /*cXFilial*/ )

			If cMoePag <> cMoedaNac
				aConv[1] := cMoePag
				aAdd(aCotac,aConv)
				JA203INNX6(cFila, aCotac)
			EndIf
		EndIf
		
		//atualiza a data de vencimento em caso de alteração de moeda e/ou condição de pagamento
		If oModelNXG:IsFieldUpdated('NXG_CMOE') .Or. oModelNXG:IsFieldUpdated('NXG_CCDPGT')
			JA203VENC()
		EndIf

	Next nINXG

	For nINX6 := 1 To oModelNX6:GetQtdLine()
		lMoeda := .F.

		If oModelNX6:GetValue("NX6_ORIGEM", nINX6) == "1"  // Só pode apagar cotações dos pagadores origem = '2'

			For nINXG := 1 To oModelNXG:GetQtdLine()
				If !oModelNXG:IsDeleted( nINXG ) .And. (oModelNXG:GetValue("NXG_CMOE", nINXG) == oModelNX6:GetValue("NX6_CMOEDA", nINX6);
						.Or. oModelNXG:GetValue("NXG_CMOE", nINXG) <> oModelNX5:GetValue("NX5_CMOEFT"))
					lMoeda := .T.
					Exit
				EndIf
			Next nINXG
		Else
			lMoeda := .T.
		EndIf

		If !lMoeda
			aAdd(aDelet, nINX6 )
		EndIf
	Next nINX6

	If !Empty(aDelet)
		oModelNX6:SetNoDeleteLine( .F. )
		For nINX6 := 1 To Len(aDelet)
			oModelNX6:GoLine(aDelet[nINX6])
			oModelNX6:DeleteLine()
		Next nINX6
		oModelNX6:SetNoDeleteLine( .T. )
	EndIf

	FWRestRows( aSaveLns )

ElseIf IsInCallStack( 'JURA202' )
	oModel    := FWModelActive()
	oModelNXG := oModel:GetModel('NXGDETAIL')
	oModelNXR := oModel:GetModel('NXRDETAIL')
	oModelNX0 := oModel:GetModel('NX0MASTER')
	dDtEmiss  := JURA203G( 'FT', Date(), 'FATEMI' )[1]

	nQtdNXG   := oModelNXG:GetQtdLine()
	nQtdNXR   := oModelNXR:GetQtdLine()

	cPreFat   := oModel:GetModel('NX0MASTER'):GetValue("NX0_COD")
	aSaveLns  := FWSaveRows()

	For nINXG := 1 To nQtdNXG
		oModelNXG:GoLine( nINXG )
		lMoeda := .F.
		For nINXR := 1 To nQtdNXR
			oModelNXR:GoLine( nINXR )
			If oModelNXG:GetValue("NXG_CMOE") == oModelNXR:GetValue("NXR_CMOEDA")
				If oModelNXR:IsDeleted()
					oModelNXR:UnDeleteLine()
				EndIf
				lMoeda := .T.
				Exit
			EndIf
		Next nINXR

		If !lMoeda
			cMoePag := oModelNXG:GetValue("NXG_CMOE", nINXG)

			aConv := JA201FConv(cMoedaNac, cMoePag, 1000, "1", dDtEmiss, /*cFila*/ , /*cCodCont*/, /*cXFilial*/ )

			If cMoedaNac != cMoePag

				If !JMdlNewLine(oModelNXR)
					oModelNXR:AddLine(.T.)
				EndIf

				oModelNXR:LoadValue('NXR_CPREFT', cPreFat)
				oModelNXR:LoadValue('NXR_CMOEDA', cMoePag )
				oModelNXR:LoadValue('NXR_DMOEDA', JurGetDados('CTO',1,xFilial('CTO')+cMoePag,'CTO_SIMB' ) )
				oModelNXR:LoadValue('NXR_COTAC' , aConv[2] )
				oModelNXR:LoadValue('NXR_ORIGEM', "1" )
				oModelNXR:LoadValue('NXR_ALTCOT', "2" )

			EndIf
		Else
			If oModelNXR:GetValue('NXR_ALTCOT') == "2" // Se a cotação não foi alterada pelo usuário ou por canc de fatura, é atualiza pelo sistema.
				cMoePag := oModelNXG:GetValue("NXG_CMOE",nINXG)
				aConv := JA201FConv(cMoedaNac, cMoePag, 1000, "1", dDtEmiss, /*cFila*/ , /*cCodCont*/, /*cXFilial*/ )
				oModelNXR:LoadValue('NXR_COTAC' , aConv[2] )
			EndIf
		EndIf
	Next nINXG

	For nINXR := 1 To oModelNXR:GetQtdLine()
		lMoeda := .F.
		If oModelNXR:GetValue("NXR_ORIGEM",nINXR) == "1"
			For nINXG := 1 To oModelNXG:GetQtdLine()
				If oModelNXG:GetValue("NXG_CMOE", nINXG) == oModelNXR:GetValue("NXR_CMOEDA", nINXR);
						.And. !oModelNXG:IsDeleted( nINXG )
					lMoeda := .T.
					Exit
				EndIf
			Next nINXG

			If !lMoeda
				aAdd(aDelet, nINXR )
			EndIf
		EndIf
	Next nINXR

	If !Empty(aDelet)
		oModelNXR:SetNoDeleteLine( .F. )
		For nINXR := 1 To Len(aDelet)
			oModelNXR:GoLine(aDelet[nINXR])
			oModelNXR:DeleteLine()
		Next nINXR
		oModelNXR:SetNoDeleteLine( .T. )
	EndIf

	FWRestRows( aSaveLns )

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203VldPg()
Função para validar os pagadores

@Param cFila   Código da fila de emissão
@Param cPreFt  Código da pré-fatura
@Param cFatAd  Código da fatura adicional
@Param cFatAd  Código da parecela de fixo
@Param lAutomato Emissão executada via automação

@author Luciano Pereira dos Santos
@since 08/12/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203VldPg(cFila, cPreFt, cFatAd, cFixo, lAutomato)
Local aArea    := GetArea()
Local lRet     := .T.
Local cQry     := ""
Local aSQL     := {}
Local nPerc    := 0
Local nPag     := 0
Local dtEmisao := CtoD("")
Local lDtMenor := .F.

cQry += " SELECT NXG.NXG_CLIPG, NXG.NXG_LOJAPG, NXG.NXG_PERCEN, NXG.NXG_DTVENC, NXG.NXG_CFATUR "
cQry +=   " FROM " + RetSqlName( "NXG" ) + " NXG "
cQry +=  " WHERE NXG.NXG_FILIAL = '" + xFilial( "NXG" ) + "' "
cQry +=    " AND NXG.NXG_FILA = '" + cFila + "'"
If !Empty(cPreFt)
	cQry += " AND NXG.NXG_CPREFT = '" + cPreFt + "'"
ElseIf !Empty(cFatAd)
	cQry += " AND NXG.NXG_CFATAD = '" + cFatAd + "'"
ElseIf !Empty(cFixo)
	cQry += " AND NXG.NXG_CFIXO = '" + cFixo + "'"
EndIf
cQry +=    " AND NXG.D_E_L_E_T_ = ' ' "

aSQL := JurSQL(cQry, {"NXG_CLIPG", "NXG_LOJAPG", "NXG_PERCEN", "NXG_DTVENC", "NXG_CFATUR"})

aEval(aSQL, {|aX| nPerc += aX[3]})

If Round(nPerc, TamSX3("NXG_PERCEN")[2]) != 100.00
	lRet := JurMsgErro(STR0209, , STR0235 + AllTrim(cFila)) //#"A soma dos pagadores deve ser igual a 100%." ##"Verifique registro do código de fila: "
EndIf

If lRet
	dtEmisao := JURA203G('FT', Date(), 'FATEMI')[1]
	For nPag := 1 To Len(aSQL)
		If Empty(AllTrim(aSQL[nPag][5])) .And. !Empty(aSQL[nPag][4]) .And. SToD(aSQL[nPag][4]) < dtEmisao
			lDtMenor := .T.
			Exit
		EndIf
	Next
	If lDtMenor
		lRet := JurMsgErro(STR0190, , STR0235 + AllTrim(cFila)) //#"A Data de vencimento não pode ser menor que a data de emissão! " ##"Verifique registro do código de fila: "
	EndIf
EndIf

If lRet
	lRet := J203ValEnd(aSQL, lAutomato)
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203VerImp()
Funcao para alimentar o array de impostos da fatura com base no
titulo a receber posicionado (SE1)

@Param aTitulo    Array com a informacao do titulo gerado
@Param cTipoEmi   Tipo de emissão  -->  "1" // Fatura -> Gera o(s) titulo(s) financeiros
                                   -->  "2,3,4" // Minuta de Fatura/Pre Fatura/Minuta de Sócio -> Gera Simulacao de impostos
@Param aImpostos  Valores de impostos para abatimento
@Param cFil       Filial do escritório da fatura
@Param cMoeFat    Moeda da fatura

@Return aRet      aRet[1] .T.

@author Daniel Magalhaes
@since 07/11/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203VerImp(aTitulo, cTipoEmi, aImpostos, cfil, cMoeFat)
Local aArea       := GetArea()
Local cAliasQry   := GetNextAlias()
Local cQuery      := ""
Local aRet        := {.T., ""}
Local cMoedNac    := SuperGetMV( 'MV_JMOENAC',, '01' )
Local cTipo       := PadR("FT", TamSX3("E1_TIPO")[1])
Local nImpost     := 0
Local nPosClient  := aScan( aTitulo, { |aX| AllTrim(aX[1]) == "E1_CLIENTE" } )
Local nPosLojaCl  := aScan( aTitulo, { |aX| AllTrim(aX[1]) == "E1_LOJA"    } )
Local nPosPrefix  := aScan( aTitulo, { |aX| AllTrim(aX[1]) == "E1_PREFIXO" } )
Local nPosNumero  := aScan( aTitulo, { |aX| AllTrim(aX[1]) == "E1_NUM"     } )
Local nPosParcel  := aScan( aTitulo, { |aX| AllTrim(aX[1]) == "E1_PARCELA" } )
Local nPosNaturz  := aScan( aTitulo, { |aX| AllTrim(aX[1]) == "E1_NATUREZ" } )
Local nI          := 0
Local cValidCpo   := GetSx3Cache("E1_VALOR", 'X3_VALID')

Default aTitulo   := {}
Default aImpostos := { 0, 0, 0, 0, 0, 0 }
Default cMoeFat   := cMoedNac

If cTipoEmi == "1" // Efetua o calculo para gravacao na Fatura

	If nPosClient == 0 .Or. nPosLojaCl == 0 .Or. nPosPrefix == 0;
	   .Or. nPosNumero == 0 .Or. nPosParcel == 0 .Or. nPosNaturz == 0 // Verifica os dados do titulo a receber

		aRet := {.F., "J203VerImp"} //Titulo sem informacoes
	Else

		cQuery := "Select SE1.E1_IRRF, SE1.E1_ISS, SE1.E1_INSS, SE1.E1_PIS, SE1.E1_COFINS, SE1.E1_CSLL"
		cQuery += " from " + RetSqlName("SE1") + " SE1"
		cQuery += " where SE1.E1_FILIAL = '"  + FWxFilial("SE1",cfil) + "'"
		cQuery +=   " and SE1.E1_CLIENTE = '" + aTitulo[nPosClient][02] + "'"
		cQuery +=   " and SE1.E1_LOJA = '"    + aTitulo[nPosLojaCl][02] + "'"
		cQuery +=   " and SE1.E1_PREFIXO = '" + aTitulo[nPosPrefix][02] + "'"
		cQuery +=   " and SE1.E1_NUM = '"     + aTitulo[nPosNumero][02] + "'"
		cQuery +=   " and SE1.E1_PARCELA = '" + aTitulo[nPosParcel][02] + "'"
		cQuery +=   " and SE1.E1_TIPO = '" + cTipo + "'"
		cQuery +=   " and SE1.D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery(cQuery, .F.)
		dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cAliasQry, .T., .F. )

		While !(cAliasQry)->(Eof())

			aImpostos[1] += (cAliasQry)->E1_IRRF
			aImpostos[2] += (cAliasQry)->E1_ISS
			aImpostos[3] += (cAliasQry)->E1_INSS
			aImpostos[4] += (cAliasQry)->E1_PIS
			aImpostos[5] += (cAliasQry)->E1_COFINS
			aImpostos[6] += (cAliasQry)->E1_CSLL

			(cAliasQry)->(DbSkip())
		EndDo

		(cAliasQry)->(DbCloseArea())

	EndIf

ElseIf cTipoEmi $ "2|3|4"  // Minuta de Fatura/Pre Fatura/Minuta de Sócio -> Gera Simulacao de impostos

	If nPosClient == 0 .Or. nPosLojaCl == 0 .Or. nPosNaturz == 0 // Verifica os dados do titulo a receber

		aRet := {.F., "J203VerImp"} //Titulo sem informacoes
	Else

		Private lF040Auto := .F.
		Private lAltera   := .F.
		Private Altera    := .F.
		Private Inclui    := .T.
		Private nIndexSE1 := ""
		Private cIndexSE1 := ""
		Private aDadosRet := Array(6)
		Private nVlRetPis := 0
		Private nVlRetCof := 0
		Private nVlRetCsl := 0
		Private nVlRetIRF := 0
		Private nVlOriCof := 0
		Private nVlOriCsl := 0
		Private nVlOriPis := 0

		RegToMemory("SE1", .T.,, .T.) // Cria variaveis do SE1 para chamada da rotina padrao

		SED->(DbSetOrder(1)) //ED_FILIAL + ED_CODIGO
		SED->(DbSeek(xFilial("SED") + aTitulo[nPosNaturz][2])) //Faz a carga de valores para a chamada

		For nI := 1 To Len(aTitulo)
			M->&(aTitulo[nI][1]) := aTitulo[nI][2]
		Next nI

		lRet := fa040natur() .And. fa040valor() //Execução do valid do campo E1_VALOR
		If !lRet
			aRet := {.F., cValidCpo}

		Else

			IIf(M->E1_IRRF   != 0, aImpostos[1] += M->E1_IRRF  , Nil)
			IIf(M->E1_ISS    != 0, aImpostos[2] += M->E1_ISS   , Nil)
			IIf(M->E1_INSS   != 0, aImpostos[3] += M->E1_INSS  , Nil)
			IIf(M->E1_PIS    != 0, aImpostos[4] += M->E1_PIS   , Nil)
			IIf(M->E1_COFINS != 0, aImpostos[5] += M->E1_COFINS, Nil)
			IIf(M->E1_CSLL   != 0, aImpostos[6] += M->E1_CSLL  , Nil)

		EndIf

	EndIf

EndIf

If cMoedNac != cMoeFat
	aEval(aImpostos, {|aX| nImpost += aX})
	If nImpost > 0
		aEval(aImpostos, {|a,n| aImpostos[n] := 0})
		aRet := {.F., STR0264} //"Títulos em moeda estrangeira não devem gerar impostos. Verifique a natureza no cadastro do cliente pagador e nos parametros MV_JNATFAT e MV_JNDESPE."
	EndIf
EndIf

RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J202VLPAG()
Função para validar a alteração do pagador.

@Param oModelX Modelo do grid relacionado ao pagador alterado.
@Param nLine   Posição da linha alterada
@Param cAction Ação executada no grid

@author Luciano Pereira dos Santos
@since 09/12/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203VLPAG(oModelX, nLine, cAction)
Local lRet      := .T.
Local oModel    := oModelX:GetModel()
Local oModelNXG := oModel:GetModel('NXGDETAIL')

If (!Empty(oModelNXG:GetValue("NXG_CFATUR")) .OR. !Empty(oModelNXG:GetValue("NXG_CESCR")))
	If cAction == "DELETE"
		oModel:SetErrorMessage( , , oModel:GetId(), , "J203VLPAG", STR0208, STR0288,, ) //#"Não é possível realizar alterações em um pagador com fatura emitida ou em WO." ##"Selecine um pagador da fila que não tenha fatura emitida."
	Else
		ApMsgInfo(STR0208) //"Não é possível realizar alterações em um pagador com fatura emitida ou em WO."
		oModelNXG:GetModel():GetErrorMessage(.T.)
	EndIf
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203GeraRpt
Emissão de relatórios por SmartClient secundário.

@author Felipe Bonvicini Conti
@since 25/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Main Function J203GeraRpt(cParams)
Local lRet        := .F.
Local aAux        := {}
Local lExit       := .F.
Local nVezes      := 0
Local cUser       := ""
Local aParam      := {}
Local nNext       := 0
Local nI          := 1
Local cEmpAux     := ''
Local cFilAux     := ''
Local cCrysPath   := ""
Local oFilaExe    := Nil
Local aRetFila    := {}
Local cTIPO       := ""
Local cOpera      := ""
Local cRotina     := ""
Local lLog        := .F.
Local cRptFunc    := ""
Local lUnif       := .F. //Arquivo Unificado
Local cNewArq     := ""
Local lAjuOrd     := .T.

cParams := StrTran(cParams, Chr(135), " ")
aParam  := StrToArray(cParams, "||")

If (lRet := Len(aParam) >= 5)
	cUser      := aParam[1]
	cEmpAux    := aParam[2]
	cFilAux    := aParam[3]
	cCrysPath  := aParam[4]
	cRotina    := aParam[5]
EndIf

If lRet
	RpcSetType(3)
	RpcSetEnv(cEmpAux, cFilAux, , , "PFS")

	__cUserId  := cUser
	oFilaExe   := JurFilaExe():New(cRotina, "2") // 2 = Impressão
	If oFilaExe:OpenReport()

		cRptFunc   := oFilaExe:GetRptFunc()

		PtInternal(1, cRptFunc + ": Start " )

		DbSelectArea("OH1")

		While !KillApp()

			PtInternal(1, cRptFunc + ": GetNext table OH1" )

			aRetFila   := oFilaExe:GetNext()
			If( Len(aRetFila) > 1 .And. aRetFila[2] > 0)
				nI   := 1
				aAux := {}
				For nI := 1 To Len(aRetFila[1])
					Aadd(aAux, aRetFila[1][nI][2])
				Next nI
				If Len(aAux) >= 24
					cTIPO    := AllTrim(aAux[23])
					cOpera   := aAux[24]
					nNext    := aRetFila[2]
				EndIf
			Else
				nNext := 0
			EndIf

			// Verificando o lockByName para saber quando está ativo o Log (F11)
			If LockByName("J203F11" + __cUserID, .T., .F.)
				lLog := .F.
				UnLockByName("J203F11" + __cUserID, .T., .F.)
			Else
				lLog := .T.
			EndIf

			IIF(lLog, JurLogMsg(cRptFunc + ": On KillApp() / TIME() == " + TIME() + " / cNext == " + AllTrim(Str(nNext))), )
			If nNext > 0

				PtInternal(1, cRptFunc + ": Print " + aAux[4] + "|" + aAux[3] + "|" + cTIPO + " type invoice file")
				Do Case
					Case cTIPO == "F" // Relat. Fatura
						JA203RELAT( aAux, cCrysPath)
					Case cTIPO == "C" // Carta
						JA203CARTA( aAux, cCrysPath)
					Case cTIPO == "R" // Recibo
						JA203RECIB( aAux, cCrysPath)
					Case cTIPO == "B" // Boleto
						JurBoleto( aAux[4], aAux[3], aAux[19], , .T., .T.)
					Case cTIPO == "D" // Gera Documentos NXM
						cNewArq := ""
						If NUH->(ColumnPos("NUH_UNIREL")) > 0 // Proteção
							lUnif := J203UNIFI(aAux[4], aAux[3], aAux[19], @cNewArq) // Unifica documentos na emissão/refazer da fatura
						EndIf
						J204GetDocs( aAux[4], aAux[3], aAux, cOpera, , .T., Upper(cNewArq), lAjuOrd ) // Vincula arquivos no Docs. Relacionados
				EndCase

				oFilaExe:SetConcl(nNext)
				Sleep(500)
			Else
				PtInternal(1, cRptFunc + ": Idle" )
				lExit := !oFilaExe:IsOpenWindow() //Fim da emissão
				Sleep(5000)
			EndIf

			If lExit
				PtInternal(1, cRptFunc + ": Out" )
				Exit
			EndIf

			nVezes += 1
			IIF(lLog, JurLogMsg(cRptFunc+ ": On KillApp() / nVezes == " + Str(nVezes)), )
		EndDo

		OH1->(dbCloseArea())

		oFilaExe:CloseReport()

		PtInternal(1, cRptFunc + ": Finish " )

	EndIf

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J203ADDREL
Adiciona o registro para fila de processamento OH1

@author Felipe Bonvicini Conti
@since 23/11/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203ADDREL(cTipo, aParams, cCodOpr, cRotina, lAutomato)
Local lRet        := .F.
Local nRec        := 0
Local oFilaExe    := Nil

Default cCodOpr   := ""
Default cRotina   := "JURA203"
Default lAutomato := .F.

oFilaExe := JurFilaExe():New( cRotina, "2" ) //2=Impressão

oFilaExe:StartReport(lAutomato) //Verifica e abre a Thread de relatório se não estiver aberta

oFilaExe:AddParams("Opcao de Emissao"      ,aParams[1], .F.)
oFilaExe:AddParams("Cod Usuario"           ,aParams[2], .F.)
oFilaExe:AddParams(STR0114                 ,aParams[3]) //#Fatura
oFilaExe:AddParams(STR0113                 ,aParams[4]) //#Escritório
oFilaExe:AddParams(STR0098                 ,aParams[5]) //#Responsável
oFilaExe:AddParams(STR0121                 ,aParams[6]) //#Cod Cliente
oFilaExe:AddParams(STR0225                 ,aParams[7]) //#Visualizar
oFilaExe:AddParams(STR0094                 ,aParams[8]) //#Exibir Logotipo
oFilaExe:AddParams(STR0095                 ,aParams[9]) //#Adicionar Depósito
oFilaExe:AddParams(STR0093                 ,aParams[10]) //#Contra Apresentação
oFilaExe:AddParams(STR0109                 ,aParams[11]) //#Carta de Cobrança
oFilaExe:AddParams(STR0034                 ,aParams[12]) //#Relatório
oFilaExe:AddParams(STR0089                 ,aParams[13]) //#Emitir Recibo
oFilaExe:AddParams("Boleto"                ,aParams[14]) //#Boleto
oFilaExe:AddParams(STR0092                 ,aParams[15]) //#Utilizar Redação
oFilaExe:AddParams(STR0096                 ,aParams[16]) //#Ocultar despesas no Relatório
oFilaExe:AddParams(STR0045                 ,aParams[17]) //#Exibir Assinatura Eletronica
oFilaExe:AddParams("Redator"               ,aParams[18], .F.) //Nome do Usuário
oFilaExe:AddParams(STR0099                 ,aParams[19]) //#Resultado
oFilaExe:AddParams("Custom Parameters 1"   ,aParams[20], .F.) // Customização Relatório Fatura
oFilaExe:AddParams("Custom Parameters 2"   ,aParams[21], .F.) // Customização Relatório Carta
oFilaExe:AddParams("Custom Parameters 3"   ,aParams[22], .F.) // Customização Parâmetros Tela
oFilaExe:AddParams("Tipo"                  ,cTipo, .F.)
oFilaExe:AddParams("Operacao"              ,cCodOpr, .F.)

If lAutomato
	lRet := .T.
Else
	nRec := oFilaExe:Insert(,,)
	lRet := nRec > 0
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203CorrNil
Substitui Nil por " " em um array unidimensional

@author Totvs
@since 23/11/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203CorrNil(aArray)
Local aRet := {}
Local nI   := 0

	If !Empty(aArray)
		For nI := 1 To Len(aArray)
			aAdd(aRet, aArray[nI])
			If aRet[nI] == Nil
				aRet[nI] := " "
			EndIf
		Next
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203VENC()
Rotina para atualizar data de Vencimento do pagador em caso de alteração
de moeda ou condição de pagamento

@author Luciano Pereira dos Santos
@since 25/01/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA203VENC()
Local aArea     := GetArea()
Local lRet      := .T.
Local oModel    := Nil
Local oModelNX5 := Nil
Local oModelNXG := Nil
Local dPart     := ctod ('  /  /  ')
Local dDtVenc   := ctod ('  /  /  ')
Local cCndPgInt := SuperGetMv('MV_JCPGINT')
Local cCndPgNac := SuperGetMv('MV_JCPGNAC')
Local cMoedaNac := SuperGetMv('MV_JMOENAC',, 01)
Local cCond     := ""
Local cParam    := ""
Local aCond     := {}

If IsInCallStack( 'JURA203' )

	oModel     := FWModelActive()
	oModelNXG  := oModel:GetModel('NXGDETAIL')
	oModelNX5  := oModel:GetModel('NX5MASTER')
	cCond      := oModelNXG:GetValue("NXG_CCDPGT")
	cMoeda     := oModelNXG:GetValue("NXG_CMOE")

	If Empty(cCond) .Or. (__ReadVar == 'M->NXG_CMOE' .And. Empty(cCond))
		If cMoeda == cMoedaNac
			cCond   := cCndPgNac
			cParam  := "MV_JCPGNAC"
		Else
			cCond   := cCndPgInt
			cParam  := "MV_JCPGINT"
		EndIf

		aCond := JurGetDados("SE4", 1, xFilial("SE4") + cCond, {"E4_CODIGO", "E4_DESCRI"})
		If Empty(aCond)
			lRet := JurMsgErro(STR0212 + cParam + STR0213 ) //"A condição de pagamento usada no parametro "+ cParam +" não é válida!"
		Else
			lRet := lRet .And. oModelNXG:LoadValue( "NXG_CCDPGT", aCond[1] )
			lRet := lRet .And. oModelNXG:LoadValue( "NXG_DCDPGT", aCond[2] )

			If !lRet
				JurMsgErro(STR0214 + cParam) //"Não foi possível usar a condição especificada no parametro " + cParam
			EndIf
		EndIf
	EndIf

	If lRet
		If !Empty(oModelNX5:GetValue("NX5_CPREFT")) .Or. !Empty(oModelNX5:GetValue("NX5_CFATAD"))
			dDtVenc := J203VENCLI(cCond, cMoeda)

		ElseIf !Empty(oModelNX5:GetValue("NX5_CFIXO"))
			dPart := JurGetDados("NT1", 1, xFilial("NT1") + oModelNX5:GetValue("NX5_CFIXO"), "NT1_DATAVE")
			dDtVenc := J203VENCLI(cCond, cMoeda, dPart )

		EndIf

		lRet := oModelNXG:LoadValue( "NXG_DTVENC", dDtVenc )

		If !lRet
			JurMsgErro(STR0211) //"Não foi possível atualizar a data de vencimento!"
		EndIf
	EndIf

EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203WVenc()
Função para habilitar o campo NXG_DTVENC para edição caso a condição
tenha apenas uma parcela

@Params		cFila Fila de emissão

@Returns	.F. se a condição retornar mais de uma parcela.

@author Luciano Pereira dos Santos
@since 25/01/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203WVenc()
Local aArea     := GetArea()
Local lRet      := .T.
Local aParcela  := {}
Local oModel    := Nil
Local oModelNXG := Nil
Local dtEmisao  := CtoD("  /  /    ")
Local cCond     := ""
Local cCndPgInt := SuperGetMv('MV_JCPGINT')
Local cCndPgNac := SuperGetMv('MV_JCPGNAC')
Local cMoedaNac := SuperGetMv('MV_JMOENAC',, '01')
Local cMoeda    := ""

If IsInCallStack( 'JURA203' )
	oModel    := FWModelActive()
	oModelNXG := oModel:GetModel('NXGDETAIL')
	dtEmisao  := JURA203G( 'FT', Date(), 'FATEMI' )[1]
	cCond     := oModelNXG:GetValue("NXG_CCDPGT")
	cMoeda    := oModelNXG:GetValue("NXG_CMOE")

	If Empty(cCond)
		If cMoeda == cMoedaNac
			cCond := cCndPgNac
		Else
			cCond := cCndPgInt
		EndIf

		cCond := JurGetDados("SE4", 1, xFilial("SE4") + cCond, "E4_CODIGO")
		If Empty(cCond)
			lRet := .F.
		EndIf
	EndIf

	If lRet
		aParcela := Condicao( 1000, cCond,, dtEmisao )

		If Len(aParcela) > 1
			lRet := .F.
		EndIf
	EndIf

ElseIf IsInCallStack( 'JURA033' )
	lRet := __ReadVar == 'M->NXG_DTVENC'

Else
	lRet := .F.
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203WVenc()
Função para validar os endereços

@param  aCliente Array de Cliente e Loja

@return lRet

@author Jacques Alves Xavier
@since 05/03/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203ValEnd(aCliente, lAutomato)
Local lRet    := .T.
Local A1END   := ''
Local A1EST   := ''
Local A1CEP   := ''
Local A1PAIS  := ''
Local A1CGC   := ''
Local NUHENDI := ''
Local A1TIPO  := ''
Local nI      := 0
Local aSA1    := {}

Default lAutomato := .F.

	For nI := 1 To Len(aCliente)
		//Validar Endereço - SA1
		aSA1 := JurGetDados('SA1', 1, xFilial('SA1') + aCliente[ni][1] + aCliente[ni][2], ;
									{'A1_END', 'A1_EST', 'A1_CEP', 'A1_PAIS', 'A1_CGC', 'A1_TIPO', 'A1_PESSOA'} )
		If !Empty(aSA1)
			A1END   := aSA1[1]
			A1EST   := aSA1[2]
			A1CEP   := aSA1[3]
			A1PAIS  := aSA1[4]
			A1CGC   := aSA1[5]
			A1TIPO  := aSA1[6]
			A1PESS  := aSA1[7]
		EndIf

		NUHENDI := JurGetDados('NUH', 1, xFilial('NUH') + aCliente[ni][1] + aCliente[ni][2], 'NUH_ENDI')

		If A1TIPO == 'X' .AND. Empty(NUHENDI)
			lRet := JA203INEND( aCliente[ni][1], aCliente[ni][2], lAutomato )

		ElseIf A1TIPO != 'X' .AND. (Empty(A1END) .OR. Empty(A1EST) .OR. Empty(A1CEP) .OR. ;
		                            Empty(A1PAIS) .OR. Empty(A1CGC) .OR. !J203TpPess(A1PESS, A1CGC, .T.) )
			lRet := JA203INEND( aCliente[ni][1], aCliente[ni][2], lAutomato )
		EndIf

		If !lRet
			Exit
		EndIf

	Next nI

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203PerNat()
Função para buscar os percentuais de impostos

@Param  cNatureza Natureza

@author Felipe Bonvicini Conti
@since 28/03/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203PerNat(cNatureza, cCliPag, cLojPag)
Local aRet   := {0,0,0,0,0}
Local cQry   := ""
Local aSQL   := {}
Local nCliIR := 0

	cQry += "SELECT ED_PERCIRF, ED_PERCPIS, ED_PERCCOF, ED_PERCCSL, ED_PERCINS "
	cQry +=     " FROM " + RetSqlName("SED") + ""
	cQry +=    " WHERE D_E_L_E_T_ = ' '"
	cQry +=      " AND ED_FILIAL = '" + xFilial("SED") + "'"
	cQry +=      " AND ED_CODIGO = '" + cNatureza + "'"

	aSql := JurSQL(cQry, {"ED_PERCIRF", "ED_PERCPIS", "ED_PERCCOF", "ED_PERCCSL", "ED_PERCINS"})

	If !Empty(aSql)
		aRet[1] := IIF(Empty(aSql[1][1]), 0, Val(AVKEY(aSql[1][1], "NXA_PIRRF")) )
		aRet[2] := IIF(Empty(aSql[1][2]), 0, Val(AVKEY(aSql[1][2], "NXA_PPIS")) )
		aRet[3] := IIF(Empty(aSql[1][3]), 0, Val(AVKEY(aSql[1][3], "NXA_PCOFIN")) )
		aRet[4] := IIF(Empty(aSql[1][4]), 0, Val(AVKEY(aSql[1][4], "NXA_PCSLL")) )
		aRet[5] := IIF(Empty(aSql[1][5]), 0, Val(AVKEY(aSql[1][5], "NXA_PINSS")) )
	EndIf

	nCliIR := JurGetDados('SA1', 1, xFilial('SA1') + cCliPag + cLojPag, 'A1_ALIQIR')

	If nCliIR > 0.00
		aRet[1] := nCliIR
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203VlDt()
Função para validar data de vencimento.

@author Luciano Pereira dos Santos

@since 08/05/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203VlDt()
Local lRet   := .T.
Local dData  := M->NXG_DTVENC
Local dDtMin := JURA203G( 'FT', Date(), 'FATEMI' )[1]

If dData < dDtMin
	lRet := JurMsgErro(STR0224) // "Data de vencimento menor que máxima data de emissão!"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203GetPFat()
Função para retornar o caminho da pasta dos relatórios da fatura

@Param cEscr    Escritorio da fatura
@Param cfatura  Código da fatura
@Param cMsgLog  Log da rotina, passada por referência

@author Felipe Bonvicini Conti

@since 02/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203GetPFat(cEsc, cFatura, cMsgLog)
Local cPastaDest := JurFixPath(SuperGetMV("MV_JPASFAT",, ""), 2, 1)
Local cMsgRet    := ''
Local cPathImg   := JurImgFat(cEsc, cFatura, .F., .F., @cMsgRet )

Default cMsgLog  := ''

If !Empty(cMsgRet)
	cMsgLog += CRLF + "J203GetPFat-> "+ cMsgRet
EndIf

If !ExistDir(cPathImg + cPastaDest) // Se não existir o diretorio MV_JPASFAT, cria o diretório antes de adicionar a estrutura do MV_JPASGRF
	If (MakeDir(cPathImg + cPastaDest)!= 0)
		cMsgLog += CRLF + "J203GetPFat.: " + I18N(STR0266, {cPathImg+cPastaDest} ) //# "Não foi possível criar o diretório '#1'."
	EndIf
EndIf

cMsgRet    := ''
cPastaDest := cPastaDest + J203GetPGrp(cEsc, cFatura, @cMsgRet)
If !Empty(cMsgRet)
	cMsgLog += CRLF + "J203GetPFat-> "+ cMsgRet
EndIf

If !ExistDir(cPathImg + cPastaDest) // Se não existir o diretorio cria o diretório da estrutura do MV_JPASGRF
	If (MakeDir(cPathImg + cPastaDest)!= 0)
		cMsgLog += CRLF + "J203GetPFat.: " + I18N(STR0266, {cPathImg+cPastaDest} ) //# "Não foi possível criar o diretório '#1'."
	EndIf
EndIf

Return cPastaDest

//-------------------------------------------------------------------
/*/{Protheus.doc} J203GetPGrp(cEscr, cFatura, @cMsgLog)
Função para montar a estrutura de grupo da pasta dos relatórios da fatura

@Param cEscr   Escritorio da fatura
@Param cfatura Código da fatura
@Param cMsgLog  Log da rotina, passada por referência

@author Felipe Bonvicini Conti

@since 02/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203GetPGrp(cEscr, cFatura, cMsgLog)
Local aAreaNXA  := NXA->(GetArea())
Local cPasta    := Alltrim(SuperGetMV("MV_JPASGRF",, ""))
Local cRet      := ""
Local aCampos   := JurSToA( cPasta , "+", .T. )
Local ni        := 0
Local nMax      := 0
Local aStrcNXA  := {}

If !Empty(cPasta) .AND. !Empty(cEscr) .AND. !Empty(cFatura)
	NXA->( dbSetOrder(1) )
	If (NXA->( DbSeek( xFilial("NXA") + cEscr + cFatura ) ))
		nMax     := Len(aCampos)
		aStrcNXA := NXA->(DbStruct())

		For ni := 1 To nMax
			If aScan(aStrcNXA, {|x| x[1] == aCampos[nI]}) > 0
				cRet := cRet + NXA->&( aCampos[ni] )
				If ni < nMax
					cRet := cRet + "_"
				EndIf
			Else
				cMsgLog += CRLF + "J203GetPGrp.: " + I18N(STR0106, {aCampos[nI], 'NXA'} ) //# "Não foi possível localizar o campo '#1' na estrutura da tabela '#2'."
			EndIf

		Next ni

		cRet := JurFixPath(cRet, 2, 1)
	Else
		cMsgLog += CRLF + "J203GetPFat.: " + I18N(STR0105, {cPathImg+cPastaDest} ) //# "Não foi possível localizar a pré-fatura '#1'."
	EndIf
EndIf

RestArea(aAreaNXA)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203VldCasRev(cPreft)
Função utilizada para validar se algum caso da pré-fatura não esta revisado.

@author Jacques Alves Xavier
@since 11/11/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203VldCasRev(cPreft)
Local aArea   := GetArea()
Local lRet    := .T.
Local cQry    := ""
Local aCasos  := {}
Local nI      := 0

	If !Empty(cPreft)
		cQry := " SELECT  NX1.NX1_CCLIEN, NX1.NX1_CLOJA, NX1.NX1_CCASO "
		cQry +=   " FROM " + RetSqlName("NX1") + " NX1 "
		cQry +=  " INNER JOIN " + RetSqlName("NVE") + " NVE  ON (NVE.NVE_FILIAL = '" + xFilial("NVE") +"' AND "
		cQry +=                                                        " NVE.NVE_CCLIEN = NX1.NX1_CCLIEN AND "
		cQry +=                                                        " NVE.NVE_LCLIEN = NX1.NX1_CLOJA AND "
		cQry +=                                                        " NVE.NVE_NUMCAS = NX1.NX1_CCASO AND "
		cQry +=                                                        " NVE.NVE_REVISA = '2' AND " // Casos não revisados
		cQry +=                                                        " NVE.D_E_L_E_T_ = ' ') "
		cQry +=  " WHERE NX1.NX1_FILIAL = '" + xFilial("NX1") +"' "
		cQry +=    " AND NX1.NX1_CPREFT = '" + cPreft + "' "
		cQry +=    " AND NX1.D_E_L_E_T_ = ' ' "

		aCasos := JurSQL(cQry, {"NX1_CCLIEN", "NX1_CLOJA", "NX1_CCASO"})

		If Len(aCasos) > 0
			lRet := MsgYesNo(STR0233 + CRLF + STR0055 + ": " + cPreft)// "Existem Casos nesta pré-fatura que foram Remanejados, mas ainda não foram revisados. Deseja prosseguir assim mesmo?"
			If lRet
				For nI := 1 To Len(aCasos)

					NVE->(dbSetOrder(1))
					NVE->(dbSeek(xFilial('NVE') + aCasos[nI][1] + aCasos[nI][2] + aCasos[nI][3] )) // Cliente + Loja + Caso
					RecLock('NVE', .F.)
					NVE->NVE_OBSREV := STR0055 + ": " + cPreft + STR0234 // Pré-Fatura + <Pré-fatura> + enviada para fila com o Caso remanejado não revisado."
					NVE->(MsUnLock())
					//Grava na fila de sincronização
					J170GRAVA("NVE", xFilial("NVE") + aCasos[nI][1] + aCasos[nI][2] + aCasos[nI][3], "4")
				Next nI
				If __lSX8
					ConfirmSX8()
				EndIf
			EndIf
		EndIf

	EndIf

	RestArea(aArea)

Return lRet

Function JurSToA( cString, cDiv, lTiraEsp )
Local aRet  := {}
Local cTemp := ""
Local aTemp := {}

	If lTiraEsp
		aRet := J203CorrNil(StrToArray(cString, cDiv)) //Caracter de divisão de array
	Else
		cTemp := Replace( cString, " ", "|$%|") //troca os espaços para não perder na função strtoarray
		aTemp := J203CorrNil(StrToArray(cTemp, cDiv))
		aEVal( aTemp, { | aX | aadd( aRet, Replace( aX, "|$%|", " " ) ) }) // Volta os espaços
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203DtIni()
Função utilizada para calcular data inicial da parcela de fixo a partir
da data final e do intervalo entre as parcelas.

@Param	dDtFim	- Data Final
@Param	nQtd	- Quantidade de meses para retroagir.

@author Luciano Pereira dos Santos
@since 28/02/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203DtIni(cDtFim, nQtd)
Local cDtRet := ""
Local nMes   := 0
Local nAno   := 0

nMes := Month(StoD(cDtFim))
nAno := Year(StoD(cDtFim))

If (nMes >= nQtd)
	cDtRet := StrZero(nAno, 4) + StrZero(nMes + 1 - nQtd, 2) + "01"

ElseIf (nQtd > nMes)

	cDtRet := StrZero(nAno - 1, 4) + StrZero((nMes + 13) - nQtd, 2) + "01"
EndIf

Return cDtRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203VlDesc()
Função para validar os descontos da pré-fatura

@author Luciano Pereria dos Santos
@since 31/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203VlDesc(cPreFt, cCodFila)
Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaNX0 := NX0->(GetArea())
Local aAreaNX1 := NX1->(GetArea())
Local nDescLin := 0
Local nDescEsp := 0
Local aDescPF  := {}

If !Empty(cPreFt)
	aDescPF := JurGetDados('NX0', 1, xFilial('NX0') + cPreFt, {'NX0_DESCON', 'NX0_DESCH'})
	NX1->(DbSetOrder(1))
	If (NX1->( DbSeek( xFilial("NX1") + cPreFt )))
		While NX1->NX1_FILIAL + NX1->NX1_CPREFT == xFilial("NX1") + cPreFt
			nDescLin += NX1->NX1_VDESCO
			nDescEsp += NX1->NX1_VLDESC
			NX1->(DbSkip())
		EndDo
	EndIf
	If nDescLin != aDescPF[1] //linear
		lRet := .F.
		JurMsgErro(STR0248,, STR0235 + AllTrim(cCodFila))  // "A somatória do desconto linear dos casos é diferente do valor no total da pré-fatura." ## "Verifique registro do código de fila: "
	EndIf
	If lRet
		If nDescEsp != aDescPF[2] //Especial
			lRet := .F.
			JurMsgErro(STR0249,, STR0235 + AllTrim(cCodFila))  // "A somatória do desconto especial dos casos é diferente do valor no total da pré-fatura." ## "Verifique registro do código de fila: "
		EndIf
	EndIf
EndIf

RestArea(aAreaNX0)
RestArea(aAreaNX1)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203Altera()
Função de chamada da View de Dados, permitindo habilitar a inclusão, alteração, exclusão do modelo de dados.

@param nOpc numero da operação: 3=Inclusão, 4=Alteração, 5=Exclusão.
@author Julio de Paula Paz
@since 02/09/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203Altera(nOpc)
Local lRet
Local lConfirmou := .F.
Local aButtons   := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,STR0289},{.T.,STR0290},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil}} //"Confirmar"#"Fechar"

Begin Sequence
	nOperacao := nOpc
	If nOperacao == 4 // Alteração
		FWExecView( STR0001, 'JURA203', 4,, { || lConfirmou := .F. }, , , aButtons ) // "Emissão de Faturas"
	EndIf
	nOperacao := 0

End Sequence

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203NParc(cContrato)
Rotina para inserir nova parcela para o contrato na emissão de
fatura (JA203Emite) e WO (JURA96).

@param cContrato  Contrato com as parcelas de Fixo
@param cSequenc   Sequencia da parcela que está sendo faturada
@param lJa203NT1  Habilita a execução do ponto de entrada JA203NT1

@author Luciano Pereira dos Santos
@since 18/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203NParc(cContrato, cSequenc, lJA203NT1)
Local aArea       := GetArea()
Local cQuery      := ""
Local cQryRes     := GetNextAlias()
Local lRet        := .F.
Local cTipoHon    := ""
Local nPerFix     := 0
Local lExcede     := .F.
Local lEncHon     := .F.
Local lNT0Parce   := .F.
Local lParcAut    := .F.
Local cDataFim    := ""
Local cDataVen    := ""
Local cDataIni    := ""
Local nValorA     := 0
Local nValorB     := 0
Local cTpFat      := ""
Local cDescPar    := ""
Local cMoeda      := ""
Local aNT0        := {}

Default cSequenc  := ""
Default lJA203NT1 := .F.

// Cria nova parcela quando não houver mais parcelas pendentes ou se existir mas já estiver em processo de faturamento, de forma 
// a possibilitar iniciar o fluxo de faturamento das novas parcelas
cQuery := "SELECT R_E_C_N_O_ AS RECNO "
cQuery +=     " FROM " + RetSqlName( 'NT1' ) + " NT1 "
cQuery +=     " WHERE NT1.D_E_L_E_T_ = ' '"
cQuery +=      " AND NT1.NT1_FILIAL = '" + xFilial("NT1") + "'"
cQuery +=      " AND NT1.NT1_CCONTR = '" + cContrato + "'"
cQuery +=      " AND NT1.NT1_SITUAC = '1' "
cQuery +=      " AND NOT EXISTS (SELECT NWE.R_E_C_N_O_ "
cQuery +=                         " FROM " + RetSqlName("NWE") + " NWE " 
cQuery +=                        " WHERE NWE.NWE_FILIAL = '" + xFilial("NWE") +"' "
cQuery +=                           "AND NWE.NWE_CFIXO = NT1.NT1_SEQUEN "
cQuery +=                           "AND NWE.NWE_CANC = '2' "
cQuery +=                           "AND NWE.D_E_L_E_T_ = ' ')"

cQuery := ChangeQuery(cQuery, .F.)
dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

lRet := (cQryRes)->(EOF())

(cQryRes)->(dbCloseArea())

If lRet

	aNT0      := JurGetDados("NT0", 1, xFilial("NT0") + cContrato, {"NT0_CTPHON", "NT0_PERFIX", "NT0_FIXEXC", "NT0_ENCH", "NT0_PARCE"})
	cTipoHon  := aNT0[1]
	nPerFix   := aNT0[2]
	lExcede   := aNT0[3] == '1'
	lEncHon   := aNT0[4] == '1'
	lNT0Parce := aNT0[5] == '2'

	lParcAut  := JurGetDados("NRA", 1, xFilial("NRA") + cTipoHon, "NRA_PARCAT") == '1'

	If lParcAut .And. !lEncHon .And. lNT0Parce

		cParcela := J203ULTPAR(cContrato) //Busca a parcela mais recente do contrato para se basear na criação da próxima

		NT1->(dbSetOrder(2)) //NT1_FILIAL+NT1_CCONTR+NT1_PARC
		NT1->(dbSeek(xFilial('NT1') + cContrato + cParcela))

		cDataFim := JurDtAdd( DToS(NT1->NT1_DATAFI), 'M', nPerFix )
		cDataVen := JurDtAdd( DToS(NT1->NT1_DATAVE), 'M', nPerFix )
		cDataIni := J203DtIni(cDataFim, nPerFix)

		nValorA  := NT1->NT1_VALORA
		nValorB  := NT1->NT1_VALORB
		cTpFat   := NT1->NT1_CTPFTU
		cMoeda   := NT1->NT1_CMOEDA

		NT0->(dbSetOrder(1))
		If NT0->( dbSeek(xFilial('NT0') + cContrato ) )
			If !Empty(NT0->NT0_DESPAR) .And. !Empty(NT0->NT0_CIDIO)
				cDescPar := JA096DePar(NT0->NT0_DESPAR, NT0->NT0_CIDIO)
			EndIf
			If Empty(cDescPar)
				cDescPar := NT1->NT1_DESCRI // Descrição da última parcela
			EndIf
		EndIf

		RecLock( 'NT1', .T. )
		NT1->NT1_FILIAL  := xFilial('NT1')
		NT1->NT1_CCONTR  := cContrato
		NT1->NT1_SEQUEN  := JurGetNum("NT1", "NT1_SEQUEN")
		NT1->NT1_PARC    := StrZero(Val(cParcela) + 1, TamSx3('NT1_PARC')[1])
		NT1->NT1_DATAIN  := SToD(cDataIni)
		NT1->NT1_DATAFI  := LastDay(SToD(cDataFim))
		NT1->NT1_DATAAT  := Date()
		NT1->NT1_VALORB  := nValorB
		NT1->NT1_VALORA  := nValorA
		NT1->NT1_DATAVE  := SToD(cDataVen)
		NT1->NT1_DESCRI  := cDescPar
		NT1->NT1_SITUAC  := '1'
		NT1->NT1_CTPFTU  := cTpFat
		NT1->NT1_CMOEDA  := cMoeda
		NT1->(MsUnlock())

		If lJA203NT1 .And. ExistBlock('JA203NT1')
			ExecBlock('JA203NT1', .F., .F.)
		EndIf

		If __lSX8
			ConfirmSX8()
		EndIf

		If lExcede // Valor Minimo
			NT0->(dbSetOrder(1))
			If NT0->(dbSeek(xFilial('NT0') + cContrato))
				RecLock( 'NT0', .F. )
				NT0->NT0_DTREFI := SToD(cDataIni)
				NT0->NT0_DTREFF := SToD(cDataFim)
				NT0->NT0_DTVENC := SToD(cDataVen)
				NT0->(MsUnlock())
			EndIf
		EndIf

		//Grava na fila de sincronização a alteração
		J170GRAVA("NT0", xFilial("NT0") + cContrato, "4")

	EndIf

EndIf

RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J203ULTPAR()
Retorna a última parcela (mais recente) do contrato informado.

@param cContrato  Contrato com as parcelas de Fixo.

@author Cristina Cintra Santos
@since 09/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203ULTPAR(cContrato)
Local aArea    := GetArea()
Local cQryRes  := ""
Local cQuery1  := ""
Local cParcela := ""

If !Empty(cContrato)
	cQuery1 := " SELECT MAX(NT1.NT1_PARC) ULTPARC "
	cQuery1 +=     " FROM " + RetSqlName( 'NT1' ) + " NT1 "
	cQuery1 +=     " WHERE NT1.D_E_L_E_T_  = ' ' "
	cQuery1 +=      " AND NT1.NT1_FILIAL = '" + xFilial("NT1") + "' "
	cQuery1 +=      " AND NT1.NT1_CCONTR = '" + cContrato + "' "

	cQryRes  := GetNextAlias()
	cQuery1  := ChangeQuery(cQuery1, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery1 ), cQryRes, .T., .F. )

	cParcela := (cQryRes)->ULTPARC

	(cQryRes)->(dbCloseArea())
EndIf

RestArea( aArea )

Return cParcela

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203DTDSP()
Rotina para apagar / preencher a data inicial e final de despesas da
fila de geração de fatura, de acordo com o conteúdo do NX5_DSPFIX (Vincula
despesas a parcela fixa ou não).

@author Cristina Cintra Santos
@since 18/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA203DTDSP()
Local cRefDspFx := SuperGetMv('MV_JRFDPFX',, "1")

	If M->NX5_DSPFIX == '1'
		If cRefDspFx == '1'
			M->NX5_DREFID := M->NX5_DREFIH
			M->NX5_DREFFD := M->NX5_DREFFH
		Else
			M->NX5_DREFID := StoD('19000101')
			M->NX5_DREFFD := dDatabase
		EndIf
	Else
		M->NX5_DREFID := CtoD ('  /  /  ')
		M->NX5_DREFFD := CtoD ('  /  /  ')
		J203HABCPO("NX5_DREFID")
		J203HABCPO("NX5_DREFFD")
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J203FilUsr()
Rotina para fazer filtro de Cliente/Loja/Contrato/Tipo de Honorario.

@Param cTab  Alias da tabela do filtro

@author Rafael Telles de Macedo
@since 28/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203FilUsr( cTab )
Local aRet       := {}
Local oPanel     := NIL
Local oContrato  := Nil
Local oTipHon    := Nil
Local cF3Fixo    := IIf(cTab == "NT1", "NRAFX", "NRA")
Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local nLoc       := Iif(cLojaAuto == "2", 0, 45)
Local nColSemLj  := Iif(cLojaAuto == "2", 525, 445)
Local oLayer     := FWLayer():New()
Local oMainColl  := Nil
Local lHtml      := GetRemoteType() == 5 // Valida se o ambiente é SmartClientHtml
Local nAltTela   := Iif(lHtml, 173, 150)

Private oGrClien := Nil //por causa do filtro da consulta padrao do contrato
Private oCliente := Nil
Private oLoja    := Nil

Inclui := .F. //Alteração para o botão do EnchoiceBar mudar de "Salvar" para "Confirmar"

DEFINE MSDIALOG oDlg TITLE STR0253 FROM 0, 0 TO nAltTela, nColSemLj PIXEL // "Filtro"

oLayer:init(oDlg,.F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
oLayer:addCollumn("MainColl",100,.F.) //Cria as colunas do Layer
oMainColl := oLayer:GetColPanel( 'MainColl' )

oPanel := tPanel():New(0,0,'',oMainColl,,,,,,0,0,.F.,.F.)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

oGrClien := TJurPnlCampo():Initialize(10, 10, 50, 22, oPanel, AllTrim(RetTitle("NT0_CGRPCL")), "A1_GRPVEN") // "Cód Gr. Cliente"
oGrClien:SetF3 ("ACY")
oGrClien:SetChange  ( {|| J203VlFlUs("GrpCli", oGrClien, oCliente, oLoja, oContrato, oTipHon)} )
oGrClien:Activate()

oCliente := TJurPnlCampo():Initialize(10, 60, 50, 22, oPanel, AllTrim(RetTitle("NUE_CCLIEN")), "A1_COD" ) // "Cód. Cliente"
oCliente:SetF3 ("SA1NUH")
If(cLojaAuto == "2")
	oCliente:SetChange  ( {|| J203VlFlUs("Cliente", oGrClien, oCliente, oLoja, oContrato, oTipHon)} )
Else
	oCliente:SetChange  ( {|| J203VlFlUs("Cliente", oGrClien, oCliente, oLoja, oContrato, oTipHon),;
	                          oLoja:SetValue(JurGetLjAt()),;
	                          J203VlFlUs("Loja", oGrClien, oCliente, oLoja, oContrato, oTipHon)} )
EndIf
oCliente:Activate()

oLoja := TJurPnlCampo():Initialize(10, 110, 40, 22, oPanel, AllTrim(RetTitle("NX1_CLOJA")), "A1_LOJA") // "Cód. Loja"
oLoja:SetChange ( {|| J203VlFlUs("Loja" , oGrClien, oCliente, oLoja, oContrato, oTipHon)} )
oLoja:Activate()
oLoja:Visible(cLojaAuto == "2")

oContrato := TJurPnlCampo():Initialize(10, 160 - nLoc, 50, 22, oPanel, AllTrim(RetTitle("NX0_CCONTR")), "NT0_COD") // "Cód. Contrato"
oContrato:SetF3("J96NT0")
oContrato:SetChange ( {|| J203VlFlUs("Contrato", oGrClien, oCliente, oLoja, oContrato, oTipHon)} )
oContrato:Activate()

oTipHon := TJurPnlCampo():Initialize(10, 210 - nLoc, 50, 22, oPanel, AllTrim(RetTitle("NX0_CTPHON")), "NT0_CTPHON") // "Cód. Tipo Honorário"
oTipHon:SetF3(cF3Fixo)
oTipHon:Activate()

oLoja:SetWhen     ( {|| !Empty(oCliente:GetValue()) } )
oContrato:SetWhen ( {|| Iif(Empty(oContrato:GetValue()),Empty(oTipHon:GetValue()), .T.) } )
oTipHon:SetWhen   ( {|| Iif(cTab != "NVV", Empty(oContrato:GetValue()), .F. ) } )

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar;
	(oDlg, {||Iif(J203VFilUr(oGrClien:GetValue(), oCliente:GetValue(), oLoja:GetValue(), oContrato:GetValue(), oTipHon:GetValue(), cTab),; 
	       (aRet := {oCliente:GetValue(), oLoja:GetValue(), oContrato:GetValue(), oTipHon:GetValue(), oGrClien:GetValue()}, oDlg:End()), .F.)},; // "Ok"
	       {|| (oDlg:End())}, .F., /*aButtons*/,/*nRecno*/,/*cAlias*/, .F., .F.,.F.,.T.,.F. )

Return aRet



//-------------------------------------------------------------------
/*/{Protheus.doc} J203VFilUr
Rotina para validar os campos Cliente/Loja/Contrato/Tipo de Honorario.

@author Rafael Telles de Macedo
@since 28/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203VFilUr( cGrClien, cCCliente, cCLoja, cCContrato, cCTipHon, cTab)
Local lRet     := .T.
Local aValor   := {}
Local cCliente := ""
Local cLoja    := ""

Begin Sequence

	If !Empty(cGrClien)
		If !(lRet := !Empty(JurGetDados("ACY", 1, xFilial("ACY") + cGrClien, "ACY_GRPVEN")))
			ApMsgAlert(STR0263) //"Código de Grupo de Cliente não encontrado!"
			Break
		EndIf
	EndIf

	If !Empty(cCCliente) .And. Empty(cCLoja)
		If !(lRet := !Empty(JurGetDados("SA1", 1, xFilial("SA1") + cCCliente, "A1_COD")))
			ApMsgAlert(STR0251) //"Código de Cliente/ Loja não encontrado!"
			Break
		EndIf
	EndIf

	If !Empty(cCLoja) .And. !Empty(cCCliente)
		If lRet := !Empty(JurGetDados("SA1", 1, xFilial("SA1") + cCCliente + cCLoja, "A1_COD" ))
			If NUH->NUH_PERFIL != "1"
				lRet := .F.
				ApMsgAlert(STR0252) //"Cliente cadastrado como somente pagador!"
				Break
			EndIf
		Else
			ApMsgAlert(STR0251) //"Código de Cliente/ Loja não encontrado!"
			Break
		EndIf
	EndIf

	If !Empty(cCContrato)
		If lRet := !Empty(JurGetDados("NT0", 1, xFilial("NT0") + cCContrato, "NT0_COD"))
			If cTab == "NT1" .And. JurGetDados("NRA", 1, xFilial("NRA") + cCTipHon, {"NRA_COBRAF"} ) == "2"
				lRet := .F.
				ApMsgAlert(STR0265) // "Contrato inválido para este tipo de faturamento!"
				Break
			ElseIf !Empty(cCLoja) .And. !Empty(cCCliente)
				aValor   := JurGetDados("NT0", 1, xFilial("NT0") + cCContrato, {"NT0_CCLIEN", "NT0_CLOJA"} )
				cCliente := aValor[1]
				cLoja    := aValor[2]

				If !(lRet := cCliente == cCCliente .And. cLoja == cCLoja)
					ApMsgAlert(STR0259) //"O Contrato não pertence ao Cliente / Loja selecionado!"
					Break
				EndIf
			EndIf
		Else
			ApMsgAlert(STR0260) //"Código de Contrato não encontrado!"
			Break
		EndIf
	EndIf

	If !Empty(cCTipHon)
		If lRet := !Empty(JurGetDados("NRA", 1, xFilial("NRA") + cCTipHon, "NRA_COD"))
			If cTab == "NT1"
				If JurGetDados("NRA", 1, xFilial("NRA") + cCTipHon, "NRA_COBRAF") == "2"
					lRet := .F.
					ApMsgAlert(STR0256) //"Código de Honorário invalido para essa forma de Faturamento!"
					Break
				EndIf
			EndIf
		Else
			ApMsgAlert(STR0261) //"Código de Honorário não encontrado!"
			Break
		EndIf
	EndIf

End Sequence

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203VlFlUs()
Campo que dispara esse gatilho: CLiente, Loja, Contrato e Grupo de Cliente

@author Rafael Telles de Macedo
@since 06/10/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203VlFlUs(cCampo, oGrupo, oClien, oLoja, oContrato, oTipHon)
Local cRet       := ""
Local aValor     := {}

Local cVGrupo    := oGrupo:GetValue()
Local cVClien    := oClien:GetValue()
Local cVLoja     := oLoja:GetValue()
Local cVContrato := oContrato:GetValue()

//Validacao do campo Grupo
If cCampo  == "GrpCli"
	If !Empty(JurGetDados("ACY", 1, xFilial("ACY") + cVGrupo, "ACY_GRPVEN"))
		If !Empty(cVClien) .And. !Empty(cVLoja) .And. JurGetDados('SA1', 1, xFilial('SA1') + cVClien + cVLoja, 'A1_GRPVEN') != cVGrupo
			oClien:Clear()
			oLoja:Clear()
			oContrato:Clear()
			oTipHon:Clear()
		EndIf
	EndIf
EndIf

//Validacao do campo Cliente
If cCampo == "Cliente"
	oLoja:Clear()
	oContrato:Clear()
	oTipHon:Clear()
EndIf

//Validacao do campo Loja
If cCampo == "Loja"
	oGrupo:SetValue (JurGetDados('SA1', 1, xFilial('SA1') + cVClien + cVLoja, 'A1_GRPVEN'), cVGrupo)
	oContrato:Clear()
	oTipHon:Clear()
EndIf

//Validacao do campo Contrato
If cCampo == "Contrato"
	aValor := JurGetDados("NT0", 1, xFilial("NT0") + cVContrato, {"NT0_CGRPCL", "NT0_CCLIEN", "NT0_CLOJA", "NT0_CTPHON"} )
	If !Empty(aValor)
		oGrupo:SetValue ( aValor[1], cVGrupo )
		oClien:SetValue ( aValor[2], cVClien )
		oLoja:SetValue  ( aValor[3], cVLoja  )
		oTipHon:SetValue( aValor[4], cVLoja  )
	Else
		oTipHon:Clear()
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203IsFat()
Verifica se todos os pagadores da pré-fatura foram faturados

@Param   cPreFat   Código da pré-fatura

@Return  lRet      .T. se todos os pagadores estão faturados

@author Luciano Pereira dos Santos
@since 16/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203IsFat(cPreFat)
Local lRet    := .T.
Local aArea   := GetArea()

NXG->(dbSetOrder(2)) //NXG_FILIAL, NXG_CPREFT, NXG_CLIPG, NXG_LOJAPG, NXG_CFATAD, NXG_CFIXO
If NXG->(dbSeek(xFilial('NXG') + cPreFat))
	Do While (NXG->NXG_FILIAL + NXG->NXG_CPREFT == xFilial("NXG") + cPreFat)
		If Empty(NXG->NXG_CFATUR) .Or. Empty(NXG->NXG_CESCR)
			lRet  := .F.
			Exit
		EndIf
		NXG->(DbSkip())
	EndDo
Else
	lRet  := .F.
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203CanMin()
Rotina que verifica se existem minutas para cancelar e
valida o periodo de cancelamento.

@Param   cCodPre  - pré-fatura a ser analisada
@Param   cFatAdic - fatura adicional a ser analisada
@Param   cFixo    - fixo a ser analisado

@Return  lRet     - .F. Não possui periodo de cancelamento válido.

@author Luciano Pereira dos Santos
@since 08/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203CanMin(cCodPre, cFatAdic, cFixo)
Local lRet       := .T.
Local aRet       := {}
Local aArea      := GetArea()
LoCal cQuery     := ""
Local aMinutas   := {}
Local cSolucao   := ""

Default cCodPre  := ""
Default cFatAdic := ""
Default cFixo    := ""

cQuery := " SELECT NXA.R_E_C_N_O_ NXA_RECNO "
cQuery +=   " FROM " + RetSqlname('NXA') + " NXA "
cQuery +=   " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") + "' "
If !Empty(cCodPre)
	cQuery += " AND NXA.NXA_CPREFT = '" + cCodPre + "' "
ElseIf !Empty(cFatAdic)
	cQuery += " AND NXA.NXA_CFTADC = '" + cFatAdic + "' "	
ElseIf !Empty(cFixo)
	cQuery += " AND NXA.NXA_CFIXO = '" + cFixo + "' "
EndIf
cQuery +=     " AND NXA.NXA_SITUAC = '1' "
cQuery +=     " AND NXA.NXA_TIPO IN ('MP','MF','MS') "
cQuery +=     " AND NXA.NXA_NFGER = '2' "
cQuery +=     " AND NXA.D_E_L_E_T_ = ' ' "

aMinutas := JurSQL(cQuery, {'NXA_RECNO'})

If Len(aMinutas) > 0
	aRet := JURA203G( 'FT', Date(), 'FATCAN',, .F.)

	If !(lRet := aRet[2]) .And. Len(aRet) == 4
		cSolucao := aRet[4]
	EndIf
EndIf

If !lRet
	JurMsgErro(STR0273,, cSolucao) //"As minutas de pré-fatura não podem ser canceladas sem um periodo de cancelamento aberto."
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203F11()
Função chamada atalho F11, para verificar lockByName para a thread
de emisão de relatório saber quando está ativo o Log (F11)

@author Abner Fogaça De Oliveira
@since 27/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203F11()
	If LOG
		UnLockByName("J203F11" + __cUserID, .T., .F.)
		LOG := .F.
		Alert(STR0280) //"O log está desativado."
	Else
		LockByName("J203F11"+__cUserID, .T., .F.)
		LOG := .T.
		Alert(STR0279) //"O log está ativo."
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J203VlUtil
Função para sugerir o valor a utilizar quando selecionar o adiantamento

@param   nSaldoAdia, numérico , Saldo do Adiantamento
@param   nVlRestan , numérico , Valor residual
@param   cTrab     , caractere, Alias temporário dos Adiantamentos
@param   aDadosPE  , array    , Valores recebidos através do ponto de entrada
	    aDadosPE[1], logico   , Se verdadeiro o adiantamento é exclusivo
	    aDadosPE[2], caractere, Tipo do adiantamento: 1-Honorários; 2-Despesas;3-Ambos
	    aDadosPE[3], numerico , Valor de despesas faturado nos casos da fatura
	    aDadosPE[4], numerico , Valor de honorários faturado nos casos da fatura

@return  nValUtil  , numérico, Sugestão do valor a utilizar

@author  Jonatas Martins
@since   14/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203VlUtil(nSaldoAdia, nVlRestan, cTrab, aDadosPE)
Local lCpoExclus  := .F.
Local cTpAdt      := ""
Local nValCas     := 0
Local nValUtil    := 0
Local lPE         := .F.

Default aDadosPE  := {}

	lPE        := Len(aDadosPE) == 4 // Ponto de entrada J203Adt
	lCpoExclus := NWF->(ColumnPos("NWF_EXCLUS")) > 0 .And. IIF(lPE, aDadosPE[1], (cTrab)->CODEXCL == "1")

	If lCpoExclus
		cTpAdt := IIF(lPE, aDadosPE[2], (cTrab)->CODTPADI)

		If cTpAdt == "1" // Despesas
			nValCas := IIF(lPE, aDadosPE[3], (cTrab)->SALDESCAS) // Saldo de despesa do caso
		ElseIf cTpAdt == "2" // Honorários
			nValCas  := IIF(lPE, aDadosPE[4], (cTrab)->SALHONCAS) // Saldo de honorários do caso
		ElseIf cTpAdt == "3" // Ambos
			nValCas  := IIF(lPE, aDadosPE[3] + aDadosPE[4], (cTrab)->SALDESCAS + (cTrab)->SALHONCAS)
		EndIf

		nValUtil := IIF(nSaldoAdia >= nValCas, Min(nValCas, nVlRestan), Min(nSaldoAdia, nVlRestan))
	Else
		nValUtil := Min(nSaldoAdia, nVlRestan)
	EndIf

Return (nValUtil)

//-------------------------------------------------------------------
/*/{Protheus.doc} J203FatFX
Função para atualizar o código da fila nas faturas de pagadores e 
limpar a fila antiga.

@param   cFixo      Código da parcela de Fixo
@param   cFilaOld   Codigo da fila antiga
@param   cFila      Codigo da fila nova

@return  Nil

@author  Luciano Pereira dos Santos
@since   06/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203FatFX(cFixo, cFilaNew, cFilaOld)
	Local aFatura := {}
	Local cQuery  := ""
	Local nI      := 0

	If !Empty(cFixo) .And. !Empty(cFilaOld)
		cQuery := " SELECT NXA.R_E_C_N_O_ RECNO"
		cQuery +=     " FROM " + RetSqlname('NXA') + " NXA "
		cQuery +=     " LEFT OUTER JOIN " + RetSqlname('NUF') + " NUF "
		cQuery +=                    " ON ( NUF.NUF_FILIAL = '" + xFilial("NUF") + "' "
		cQuery +=                           " AND NXA.NXA_COD = NUF.NUF_CFATU "
		cQuery +=                           " AND NXA.NXA_CESCR = NUF.NUF_CESCR "
		cQuery +=                           " AND NUF.D_E_L_E_T_ = ' ') "
		cQuery +=     " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") + "' "
		cQuery +=         " AND NXA.NXA_CFIXO = '" + cFixo + "' "
		cQuery +=         " AND NXA.NXA_CFILA = '" + cFilaOld + "' "
		cQuery +=         " AND (NXA.NXA_SITUAC = '1' "
		cQuery +=              " OR (NXA_SITUAC = '2' AND NUF.NUF_SITUAC = '1' ) ) " //Fatura de Wo Ativo
		cQuery +=         " AND NXA.NXA_TIPO = 'FT' "
		cQuery +=         " AND NXA.D_E_L_E_T_ = ' ' "

		aFatura := JurSQL(cQuery, {'RECNO'})

		For nI := 1 To Len(aFatura)
			NXA->(DBGoto(aFatura[nI][1]))
			RecLock("NXA", .F.)
			NXA->NXA_CFILA := cFilaNew
			NXA->(MsUnlock())
			NXA->(DbCommit())
		Next nI

		J203DelPag(cFilaOld)
	EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} J203SetFFx
Função para atualizar o código da fila nas faturas de pagadores e 
limpar a fila antiga.

@param   cFilaNew   Codigo da fila atual da parcela de fixo
@param   cFilaOld   Codigo da fila antiga da parcela de fixo

@return  _aFilaFx   Array contendo as filas fixo Nova e Antiga 

@author  Luciano Pereira dos Santos / Jorge Martins 
@since   06/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203FlFxOld(cFilaNew, cFilaOld)

If !Empty(cFilaNew) .And. !Empty(cFilaOld)
	Aadd(_aFilaFx, {cFilaNew, cFilaOld})
EndIf

Return _aFilaFx

//-------------------------------------------------------------------
/*/{Protheus.doc} J203UNIFI
Unifica documentos na emissão/refazer fatura

@param   cEscrit  Codigo do escritório
@param   cCodFat  Codigo da fatura

@return  lUnif    Se .T. o arquivo de unificação foi gerado com sucesso

@author  Jonatas Martins
@since   22/04/2019
@Obs     Para o funcionamento dessa rotina necessário existir os arquivos:
         "pdftk.exe" e "libiconv2.dll" na pasta system do servidor
/*/
//-------------------------------------------------------------------
Static Function J203UNIFI(cEscrit, cCodFat, cResult, cNewArq)
	Local cTpUnif    := ""
	Local cFatId     := ""
	Local cPastaDest := ""
	Local cNomCarta  := ""
	Local cNomRelat  := ""
	Local cNomBolet  := ""
	Local nArq       := 0
	Local lCarta     := .F.
	Local lRelat     := .F.
	Local lBolet     := .F.
	Local lUnif      := .F.
	Local aCliPag    := {}
	Local aDirPdf    := {}
	Local aArqOrdem  := {}
	Local aArqUnif	 := {}
	Local aCarta  := {}
	Local aRelat  := {}
	Local aBoleto := {}
	Local lJ204NomCm := FindFunction("J204NomCmp")
	Local cNomFile := ""

	Default cEscrit  := ""
	Default cCodFat  := ""
	Default cResult  := ""
	Default cNewArq  := "" 

	aCliPag := JurGetDados("NXA", 1, xFilial("NXA") + cEscrit + cCodFat, {"NXA_CLIPG", "NXA_LOJPG"}) 
	cTpUnif := JurGetDados("NUH", 1, xFilial("NUH") + aCliPag[1] + aCliPag[2], "NUH_UNIREL")
	
	If cTpUnif $ "23" // Unifica
		cPastaDest := JurImgFat(cEscrit, cCodFat, .T., .F., /*@cMsgRet*/)

		cNomCarta := J204STRFile("C", "2", cEscrit, cCodFat, @aCarta) //"Carta"
		cNomRelat := J204STRFile("F", "2", cEscrit, cCodFat, @aRelat) //"Relatorio"
		cNomBolet := J204STRFile("B", "2", cEscrit, cCodFat, @aBoleto) //"Boleto"

		If ExistDir(cPastaDest)
			cFatId    := Alltrim(cEscrit) + '-' + Alltrim(cCodFat)
			aDirPdf   := Directory(cPastaDest + "*" + cFatId + "*" + "PDF", Nil, Nil, .T.)

			If FindFunction("J204FlExDi")
				//Verifica os arquivos de nomes alterados e adiciona no array de arquivos
				J204FlExDi(cPastaDest, aCarta, aDirPdf )
				J204FlExDi(cPastaDest, aRelat, aDirPdf )
				J204FlExDi(cPastaDest, aBoleto, aDirPdf )
			EndIf
		EndIf

		If Len(aDirPdf) > 0


			For nArq := 1 To Len(aDirPdf)
				cNomFile := AllTrim(Upper(aDirPdf[nArq][1]))
					//Nova função para comparar aquivo
				If !lJ204NomCm
					lCarta := cNomCarta $ cNomFile
					lRelat := cNomRelat $ cNomFile
					lBolet := cNomBolet $ cNomFile
				Else
					lCarta := J204NomCmp(cNomCarta, cNomFile)
					lRelat := J204NomCmp(cNomRelat , cNomFile)
					lBolet := J204NomCmp(cNomBolet , cNomFile)
				EndIf

				If lCarta .Or. lRelat .Or. (lBolet .And. cTpUnif == "3")
					AAdd(aArqOrdem, {aDirPdf[nArq][1], IIF(lBolet, 99, nArq)})
				EndIf

				lCarta := .F.
				lRelat := .F.
				lBolet := .F.
			Next nArq

			//Cria arquivo unificado
			If Len(aArqOrdem) > 0
				aSort(aArqOrdem, , , {|x, y| x[2] < y[2]}) //Ordena arquivos
				aEval(aArqOrdem, {|x| Aadd(aArqUnif, x[1])}) //Monta array apenas com os nomes de arquivos
				lOpenFile := cResult == "2" // Resultado do relatório: '1' - Impressora / '2' - Tela / '3' - Word / '4' - Nenhum
				lUnif     := J204JOIN(cEscrit, cCodFat, aArqUnif, @cNewArq, lOpenFile, cPastaDest, .T.)
				If !lUnif
					JurLogMsg(STR0291) // "Falha ao criar arquivo unificado!"
				EndIf
			EndIf
			JurFreeArr(aCarta)
			JurFreeArr(aRelat)
			JurFreeArr(aBoleto)
			JurFreeArr(aDirPdf)
			JurFreeArr(aArqUnif)
		EndIf 

	EndIf

Return (lUnif)

//-------------------------------------------------------------------
/*/{Protheus.doc} J203VlCota
Valida cotações da pré-fatura e indica se pode ou não ter sua 
situação alterada.

@param cFila   , Código da fila de emissão
@param dDataEmi, Data da emissão
@param cCodPre , Código da pré-fatura

@return lRet   , Indica se a cotação é válida ou não

@author  Jorge Martins / Cristina Cintra
@since   17/12/2019
/*/
//-------------------------------------------------------------------
Static Function J203VlCota(cFila, dDataEmi, cCodPre)
	Local lRet      := .T.
	Local nI        := 0
	Local nCotac    := 0
	Local nCotacNXR := 0
	Local cQuery    := ""
	Local cMoeda    := ""
	Local aRetDados := {}
	Local aInfoNXR  := {}
	Local aVldCotac := {}
	Local cMoeNac   := SuperGetMv("MV_JMOENAC",, "01")
	Local cCotSuger := SuperGetMv("MV_JCOTSUG",, "1" ) // Cotação sugerida na fila de emissão: 1=Cotação da Data de emissão da fatura; 2=Cotação da pré-fatura
	Local cTipoConv := IIf(SuperGetMv("MV_JTPCONV",, "1" ) == "1" , STR0292, STR0293) // "Diária" - "Mensal"

	If cCotSuger == "2" .And. !Empty(cCodPre)
		dDataEmi := JurGetDados("NX0", 1, xFilial("NX0") + cCodPre, "NX0_DTEMI")
	EndIf

	cQuery := " SELECT NX6_CMOEDA FROM " + RetSqlName("NX6")
	cQuery +=  " WHERE NX6_FILIAL = '" + xFilial("NX6") + "' "
	cQuery +=    " AND NX6_CFILA  = '" + cFila + "' "
	cQuery +=    " AND NX6_COTAC1 = 1 "
	cQuery +=    " AND NX6_CMOEDA <> '" + cMoeNac + "' "
	cQuery +=    " AND D_E_L_E_T_ = ' ' "

	aRetDados := JurSql(cQuery, "NX6_CMOEDA")

	For nI := 1 To Len(aRetDados)
		cMoeda    := aRetDados[nI][1]

		aVldCotac := J201FVlCot(cMoeda, dDataEmi) // Indica se há cotação cadastrada para a moeda e data.
		lRet      := aVldCotac[1]
		nCotac    := aVldCotac[2]

		If lRet 
			If cCotSuger == "2" .And. !Empty(cCodPre)
				aInfoNXR := JurGetDados("NXR", 1, xFilial("NXR") + cCodPre + cMoeda, {"NXR_COTAC", "NXR_ALTCOT"})

				If !Empty(aInfoNXR) .And. aInfoNXR[2] == "2" // Cotação do Sistema
					nCotacNXR := aInfoNXR[1]
					lRet := nCotacNXR == nCotac // Verifica se a pré foi emitida com a cotação diária/mensal cadastrada.
				EndIf
			Else
				lRet := nCotac == 1
			EndIf

			If !lRet
				JurMsgErro(I18n(STR0294, {cFila, cMoeda, cTipoConv}),, STR0295) // "Não é possível realizar a emissão para a fila '#1', pois a cotação da moeda '#2' está como 1 e é diferente da cotação #3." # "Ajuste a cotação na fila e realize a emissão novamente."
			EndIf
		EndIf

		If !lRet
			Exit
		EndIf
	Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203AdtUser
Executa ponto de entrada de utilização de adiantamentos

@param   cEscrit   , caracter, Escritório da Fatura
@param   cNumFat   , caracter, Numero da Fatura
@param   cCliPag   , caracter, Código do cliente pagador da fatura
@param   cLojaPag  , caracter, Loja do cliente pagador da fatura
@param   cMoedaFat , caracter, Moeda da fatura
@param   cFila     , caracter, Código fila de emissão da fatura
@param   cTpExec   , caracter, Tipo de execução
@param   nVlFatura , numérico, Valor líquido da fatura
@param   nVlRestan , numérico, Valor residual da Fatura

@return  lRet      , numérico, Se verdadeiro os adiantamentos foram utilizados

@author  Jonatas Martins
@since   10/09/2018
/*/
//-------------------------------------------------------------------
Static Function J203AdtUser(cEscrit, cNumFat, cCliPag, cLojaPag, cMoedaFat, cFila, cTpExec, nVlFatura, nVlRestan)
	Local aArea       := GetArea()
	Local aAreaSE1    := SE1->(GetArea())
	Local aAreaNWF    := NWF->(GetArea())
	Local aDadosPE    := {}
	Local aAdtUser    := {}
	Local aUtiliza    := {}
	Local aConvBx     := {}
	Local nSaldoAdia  := 0
	Local nRecnoSE1   := 0
	Local nRecnoNWF   := 0
	Local cTipoAdt    := ""
	Local nValUtiliza := 0
	Local nValDespCas := 0
	Local nValHonCas  := 0
	Local nAdt        := 0
	Local nTaxaBX     := 0
	Local nSaldoConv  := 0
	Local lExistPos   := .F.
	Local lExclusivo  := .F.
	Local lUsaResiduo := .F.
	Local lRet        := .F.
	Local lCpoDtMov   := NWF->(ColumnPos("NWF_DTMOVI")) > 0
	Local lCpoCota    := NWF->(ColumnPos("NWF_COTACA")) > 0

	aDadosPE := ExecBlock("J203Adt", .F., .F., {cEscrit, cNumFat, cFila, nVlFatura})
	
	If ValType(aDadosPE) == "A" .And. Len(aDadosPE) == 2
		_lAdtPE  := IIF(ValType(aDadosPE[1]) == "L", aDadosPE[1], _lAdtPE)
		aAdtUser := IIF(ValType(aDadosPE[2]) == "A", aDadosPE[2], aAdtUser)

		For nAdt := 1 To Len(aAdtUser)
			lExistPos := Len(aAdtUser[nAdt]) == 4

			If lExistPos .And. nVlRestan > 0
				nRecnoNWF  := IIF(ValType(aAdtUser[nAdt][1]) == "N", aAdtUser[nAdt][1], 0)
				nRecnoSE1  := IIF(ValType(aAdtUser[nAdt][2]) == "N", aAdtUser[nAdt][2], 0)
				
				SE1->(DbGoTo(nRecnoSE1))
				NWF->(DbGoTo(nRecnoNWF))

				If SE1->(!EOF()) .And. NWF->(!EOF()) .And. nVlRestan != 0 .And. SE1->E1_SALDO > 0;
				   .And. SE1->E1_CLIENTE == cCliPag  .And. SE1->E1_LOJA == cLojaPag .And. AllTrim(SE1->E1_ORIGEM) == 'JURA069'

					nValUtiliza := IIF(ValType(aAdtUser[nAdt][3]) == "N", aAdtUser[nAdt][3], SE1->E1_SALDO)
					lUsaResiduo := IIF(ValType(aAdtUser[nAdt][4]) == "L", aAdtUser[nAdt][4], .F.)
					lExclusivo  := NWF->NWF_EXCLUS == "1"
					cTipoAdt    := NWF->NWF_TPADI
					aConvBx     := J203ConvAdi(cMoedaFat, NWF->NWF_CMOE, nValUtiliza, IIf(lCpoDtMov, NWF->NWF_DTMOVI, NWF->NWF_DATAIN),;
												cTpExec, cFila, IIF(lCpoCota,NWF->NWF_COTACA , 0))
					nSaldoAdia  := aConvBx[1]
					nTaxaBX     := aConvBx[2]
					nSaldoConv  := SE1->E1_SALDO * nTaxaBX
					nValDespCas := IIF(lExclusivo, J203ValCas(cEscrit, cNumFat, NWF->NWF_CCLIEN, NWF->NWF_CLOJA, NWF->NWF_CCASO, "NXC_VLDFAT"), 0)
					nValHonCas  := IIF(lExclusivo, J203ValCas(cEscrit, cNumFat, NWF->NWF_CCLIEN, NWF->NWF_CLOJA, NWF->NWF_CCASO, "NXC_VLHFAT"), 0)
					
					nValUtiliza := J203VlUtil(nSaldoAdia, nVlRestan, '', {lExclusivo, cTipoAdt, nValDespCas, nValHonCas})

					nVlRestan -= nValUtiliza

					Aadd(aUtiliza, {'', SE1->E1_NUM, "", Transform( nValUtiliza, "@E 99,999,999.99" ),;
									nRecnoSE1,SE1->E1_HIST, IIf(lCpoDtMov, NWF->NWF_DTMOVI, NWF->NWF_DATAIN), NWF->NWF_CMOE,;
									nValUtiliza, lUsaResiduo, nSaldoConv, IIF(lCpoCota, NWF->NWF_COTACA, 0)})
				EndIf
			EndIf
		Next nAdt

		lRet := IIF(Len(aUtiliza) > 0, J203GrvAdt(cEscrit, cNumFat, cTpExec, cFila, aUtiliza, .T.), .T.)

		JurFreeArr(aDadosPE)
		JurFreeArr(aAdtUser)
		JurFreeArr(aUtiliza)

	EndIf

	RestArea(aAreaNWF)
	RestArea(aAreaSE1)
	RestArea(aArea)
	
Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} J203ValCas
Calcula a soma de valores de despesas ou honorários do caso

@param cEscrit   , caracter, Escritório da Fatura
@param cNumFat   , caracter, Numero da Fatura
@param cCliente  , caracter, Código do cliente
@param cLoja     , caracter, Loja do cliente
@param cCaso     , caracter, Código do caso
@param cCampo    , caracter, Campo do caso que terá o valor somado

@return	 nValCaso, numérico, Valor de honorários ou despesas do caso

@author  Jonatas Martins
@since   10/09/2018
/*/
//-------------------------------------------------------------------
Static Function J203ValCas(cEscrit, cNumFat, cCliente, cLoja, cCaso, cCampo)
	Local cQuery   := ""
	Local nValCaso := 0

	cQuery := "SELECT SUM(" + cCampo + ") TOTAL"
	cQuery +=   "FROM " + RetSqlName("NXC") + " NXC "
	cQuery +=  "WHERE NXC.NXC_FILIAL = '" + xFilial("NXC") + "' "
	cQuery +=    "AND NXC.NXC_CESCR  = '" + cEscrit + "' "
	cQuery +=    "AND NXC.NXC_CFATUR = '" + cNumFat + "' "
	cQuery +=    "AND NXC.NXC_CCLIEN = '" + cCliente + "' "
	cQuery +=    "AND NXC.NXC_CLOJA  = '" + cLoja + "' "
	cQuery +=    "AND NXC.NXC_CCASO  = '" + cCaso + "' "
	cQuery +=    "AND NXC.D_E_L_E_T_ = ' '"

	nValCaso := JurSql(cQuery, "*")[1][1]

Return (nValCaso)

//-------------------------------------------------------------------
/*/{Protheus.doc} J203TelaAd
Pergunte que define se será exibida tela com lista dos adiantamentos 
exclusivos utilizados na emissão da fatura

@param lAsk, Indica se o pergunte será aberto em tela

@author  Jorge Martins
@since   23/03/2020
/*/
//-------------------------------------------------------------------
Static Function J203TelaAd(lAsk)

	Pergunte('JURA203ADT', lAsk)

	_lTelaAuto := cValtoChar(MV_PAR01) == "1"

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J203AdiExc
Exibe tela com lista dos adiantamentos exclusivos utilizados na 
emissão da fatura

@param _aAdtAuto, Array com dados dos adiantamentos exclusivos utilizados

@author  Jorge Martins
@since   19/03/2020
/*/
//-------------------------------------------------------------------
Function J203AdiExc(_aAdtAuto)
	Local nLargura   := 450
	Local nAltura    := 200
	Local nTamDialog := 0
	Local nSizeTela  := 0
	Local nI         := 0
	Local nPosDoc    := 0
	Local aSize      := {}
	Local aDados     := {}
	Local aCampos    := {}
	Local aCposLGPD  := {}
	Local aNoAccLGPD := {}
	Local aDisabLGPD := {}
	Local cPicture   := ""
	Local cMoeda     := ""
	Local oDlg       := Nil
	Local oScroll    := Nil
	Local oLayer     := Nil
	Local oMainColl  := Nil
	Local oBrowse    := Nil
	Local lObfuscate := FindFunction("FwPDCanUse") .And. FwPDCanUse(.T.) // Indica se trabalha com Dados Protegidos e possui a melhoria de ofuscação de dados habilitada

	// Retorna o tamanho da tela
	aSize     := MsAdvSize(.F.)
	nSizeTela := ((aSize[6]/2) * 0.85) // Diminui 15% da altura.

	If nAltura > 0 .And. nSizeTela < nAltura
		nTamDialog := nSizeTela
	Else
		nTamDialog := nAltura
	EndIf

	oDlg := FWDialogModal():New()
	oDlg:SetFreeArea(nLargura, nTamDialog)
	oDlg:SetEscClose(.F.)    // Não permite fechar a tela com o ESC
	oDlg:SetCloseButton(.F.) // Não permite fechar a tela com o "X"
	oDlg:SetBackground(.T.)  // Escurece o fundo da janela
	oDlg:SetTitle(STR0297)   // "Adiantamentos utilizados automaticamente"
	oDlg:CreateDialog()
	oDlg:addCloseButton({|| oDlg:oOwner:End() }) //"Cancelar" // "O preenchimento dos detalhes do título é obrigatório. Por favor, verifique!"

	// Cria objeto Scroll
	oScroll := TScrollArea():New(oDlg:GetPanelMain(),01,01,365,545)
	oScroll:Align := CONTROL_ALIGN_ALLCLIENT

	@ 000,000 MSPANEL oPanel OF oScroll SIZE nLargura, nAltura

	oLayer := FwLayer():New()
	oLayer:Init(oPanel, .F.)
	oLayer:addCollumn("MainColl",100,.F.) // Cria as colunas do Layer
	oMainColl := oLayer:GetColPanel( 'MainColl' )

	// Define objeto painel como filho do scroll
	oScroll:SetFrame( oPanel )

	For nI := 1 To Len(_aAdtAuto)
		nPosDoc := aScan(aDados, {|aDocs| aDocs[1] == _aAdtAuto[nI][1]})
		
		If nPosDoc == 0
			cMoeda := AllTrim(JurGetDados('CTO', 1, xFilial('CTO') + _aAdtAuto[nI][2], 'CTO_SIMB'))
			aAdd(aDados, {_aAdtAuto[nI][1], cMoeda, _aAdtAuto[nI][3], _aAdtAuto[nI][4], _aAdtAuto[nI][5]})
		Else
			aDados[nPosDoc][3] += _aAdtAuto[nI][3] // Valor Utilizado
			aDados[nPosDoc][4] := _aAdtAuto[nI][4] // Saldo
		EndIf
	Next

	If lObfuscate // Tratamentos LGPD
		aCposLGPD  := {"NWF_HIST"}
		aNoAccLGPD := FwProtectedDataUtil():UsrNoAccessFieldsInList(aCposLGPD)
		AEval(aNoAccLGPD, {|x| AAdd( aDisabLGPD, x:CFIELD)})

		cPicture := IIf(aScan(aDisabLGPD,"NWF_HIST") > 0, "*********", GetSx3Cache("NWF_HIST" ,"X3_PICTURE"))
	EndIf

	aAdd(aCampos,{STR0138, "NWF_TITULO", GetSx3Cache("NWF_TITULO","X3_PICTURE"), TamSx3('NWF_TITULO')[1], 0                    ,,, 'C',, 'R',,,,,,,,}) // "Documento"
	aAdd(aCampos,{STR0139, "CTO_SIMB"  , GetSx3Cache("CTO_SIMB"  ,"X3_PICTURE"), TamSx3('CTO_SIMB')[1]  , 0                    ,,, 'C',, 'R',,,,,,,,}) // "Moeda Fat"
	aAdd(aCampos,{STR0140, "E1_VALOR"  , GetSx3Cache("E1_VALOR"  ,"X3_PICTURE"), TamSx3('E1_VALOR')[1]  , TamSx3('E1_VALOR')[2],,, 'N',, 'R',,,,,,,,}) // "Valor Utilizado"
	aAdd(aCampos,{STR0296, "E1_SALDO"  , GetSx3Cache("E1_SALDO"  ,"X3_PICTURE"), TamSx3('E1_SALDO')[1]  , TamSx3('E1_SALDO')[2],,, 'N',, 'R',,,,,,,,}) // "Saldo"
	aAdd(aCampos,{STR0194, "NWF_HIST"  , cPicture                              , TamSx3('NWF_HIST')[1]  , 0                    ,,, 'C',, 'R',,,,,,,,}) // "Histórico"

	oBrowse := TJurBrowse():New(oMainColl)
	oBrowse:SetDataArray()
	oBrowse:SetHeader(aCampos)
	oBrowse:Activate()
	oBrowse:SetArray(aDados)
	oBrowse:Refresh()

	oDlg:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J203NVNVin
Indica se o encaminhamento possui vínculo com algum registro 
(pré-fatura, contrato, junção, fatura adicional, fixo ou fatura).

Obs: Registros adicionados diretamente pela fila de emissão de fatura 
não ficam vinculados a nenhuma pré-fatura, contrato, junção, 
fatura adicional ou fixo. Somente na fatura se for emitida.

@param cFila, Código da Fila para identificação do registro

@return lRet, Indica se o encaminhamento está vinculado a algum registro

@author Jorge Martins
@since  29/04/2020
/*/
//-------------------------------------------------------------------
Static Function J203NVNVin(cFila)
	Local lRet := .T.

	If NVN->NVN_CFILA  == cFila .And. ;
	   NVN->NVN_CJCONT == Space(TamSx3('NVN_CJCONT')[1]) .And. ;
	   NVN->NVN_CCONTR == Space(TamSx3('NVN_CCONTR')[1]) .And. ;
	   NVN->NVN_CPREFT == Space(TamSx3('NVN_CPREFT')[1]) .And. ;
	   NVN->NVN_CFATAD == Space(TamSx3('NVN_CFATAD')[1]) .And. ;
	   NVN->NVN_CFATUR == Space(TamSx3('NVN_CFATUR')[1]) .And. ;
	   NVN->NVN_CESCR  == Space(TamSx3('NVN_CESCR ')[1])
	
		If NVN->(ColumnPos("NVN_CFIXO")) > 0 // Proteção
			If NVN->NVN_CFIXO == Space(TamSx3('NVN_CFIXO')[1])
				lRet := .F.
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203GrvFil
Realiza a gravação do nome do arquivo gerado nos docs relacionados

@param cTpArq   , Tipo do Arquivo
@param cEscr    , Código do Escritório
@param cFila    , Código da Fatura
@param cNomArq  , Nome do Arquivo
@param nOrdem   , Ordem do arquivo
@param cFilSE1  , Filial do Título
@param cPreFix  , Prefixo do Título
@param cNumTit  , Numero do Título
@param cParcela , Parcela do Título
@param cTipo    , Tipo do Título
@param cEmail   , Envia e-mail

@author fabiana.silva	
@since  19/10/2020
/*/
//-------------------------------------------------------------------
Function J203GrvFil(cTpArq, cEscr, cCodFat, cNomArq, nOrdem, cFilSE1, cPreFix, cNumTit, cParcela, cTipo, cEmail)
Local aAliasNXM := {}

Default nOrdem   := 0
Default cFilSE1  := ""
Default cPreFix  := ""
Default cNumTit  := "" 
Default cParcela := "" 
Default cTipo    := "" 
Default cEmail   := "1"

	If NXM->(ColumnPos("NXM_CTPARQ")) > 0
		cNomArq := Upper(cNomArq)
		aAliasNXM := NXM->(GetArea())
		NXM->(DbSetOrder(2)) // NXM_FILIAL+NXM_NOMARQ
		If !NXM->( DbSeek(xFilial("NXM") + AvKey(cNomArq, "NXM_NOMARQ") ) )
		
			cEscr   :=  AvKey(cEscr, "NXM_CESCR" )
			cCodFat := AvKey(cCodFat, "NXM_CFATUR")
			Reclock("NXM", .T.)
			NXM->NXM_FILIAL := xFilial("NXM")
			NXM->NXM_TKRET  := .F.
			NXM->NXM_NOMARQ := AvKey(cNomArq, "NXM_NOMARQ")
			NXM->NXM_EMAIL  := IIF(cTpArq <> "6", cEmail, "2")
			NXM->NXM_ORDEM  := IIF(nOrdem > 0, nOrdem, Val(cTpArq))
			NXM->NXM_CESCR  := cEscr
			NXM->NXM_CFATUR := cCodFat
			NXM->NXM_CTIPO  := "1"
			NXM->NXM_NOMORI := AvKey(cNomArq, "NXM_NOMORI")
			NXM->NXM_CPATH  := ""
			NXM->NXM_CTPARQ := cTpArq
			If NXM->(ColumnPos("NXM_TITNUM")) > 0 //@12.1.33
				NXM->NXM_FILTIT := cFilSE1
				NXM->NXM_PREFIX := cPreFix
				NXM->NXM_TITNUM := cNumTit
				NXM->NXM_TITPAR := cParcela
				NXM->NXM_TITTPO := cTipo
			EndIf
			NXM->(MsUnlock())
		EndIf

		RestArea(aAliasNXM)
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J203AjuOrd
Ajusta ordenação dos documentos gravados pela J203GrvFil

@param cEscr  , Código do Escritório
@param cFila  , Código da Fatura

@author Jorge Martins / Jonatas Martins
@since  14/05/2021
/*/
//-------------------------------------------------------------------
Function J203AjuOrd(cEscr, cCodFat)
Local aArea    := GetArea()
Local aAreaNXM := NXM->(GetArea())
Local nOrdem   := 0

	NXM->(DbSetOrder(4)) // NXM_FILIAL + NXM_CESCR + NXM_CFATUR + NXM_CTPARQ
	If NXM->(DbSeek(xFilial("NXM") + cEscr + cCodFat))
		While NXM->(!Eof()) .And. cEscr == NXM->NXM_CESCR .And. cCodFat == NXM->NXM_CFATUR .And. NXM->NXM_CTPARQ <> "6"
			nOrdem += 1
			Reclock("NXM", .F.)
			NXM->NXM_ORDEM := nOrdem
			NXM->(MsUnlock())
			NXM->(DbSkip())
		EndDo
	EndIf

	RestArea(aAreaNXM)
	RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J203FilCpo
Função para informar os campos que não devem ser considerados no SELECT
da query de filtro

@param  cTab    , Alias da tabela que será filtrada

@return aNoField, Array simples com os campos que devem ser remodidos

@author Jonatas Martins
@since  04/03/2021
/*/
//-------------------------------------------------------------------
Static Function J203FilCpo(cTab)
Local aNoField := {}

	If cTab == "NVV" .And. NVV->(ColumnPos("NVV_MSBLQL")) > 0
		Aadd(aNoField, "NVV_MSBLQL")
	EndIf

Return (aNoField)

//-------------------------------------------------------------------
/*/{Protheus.doc} J203ImpSE1
Define o valor da base de cálculo do imposto de IRF (E1_BASEIRF) e se
deve ou não ser retido o imposto.

@param  lFatParcel - Se a fatura é parcelada
@param  nValParc   - Valor da parcela
@param  nBasePCC   - Base de imposto para PIS / COFINS / CSLL
@param  nTotImpBas - Valor total da base de imposto IRF / INSS / ISS
@param  nBaseCalc  - Base de imposto que será considerada para o cálculo
@param  nTotImpIRF - Valor total de IRPF
@param  nTotImpINS - Valor total de INSS
@param  nTotImpISS - Valor total de ISS
@param  cNatureza  - Natureza utilizada na emissão de fatura (MV_JNATFAT)
@param  cMemoLog   - Mensagem de crítica (quando o valor de imposto for maior
                                          do que o valor da primeira parcela)
@param  dDtVencRea - Data de vencimento real do título (E1_VENCREA)

@return lRet Se .T. retém o imposto, .F. não deve ser retido.

@author Abner Fogaça
@since 18/06/2021
/*/
//-------------------------------------------------------------------
Static Function J203ImpSE1(lFatParcel, nValParc, nBasePCC, nTotImpBas, nBaseCalc, nTotImpIRF, nTotImpINS, nTotImpISS, cNatureza, cMemoLog, dDtVencRea, nParcela)
Local lRet      := .T.
Local nTotImp   := 0
Local nValPIS   := 0
Local nValCOF   := 0
Local nValCSLL  := 0
Local nVencto   := SuperGetMv("MV_VCPCCR",.T.,1) // Qual a data que será considerada para a cumulatividade do PCC na Emissão. 1=Emissao, 2=Venc.Real, 3=Dt Contab.
Local nCont     := 0
Local cImpostos := ""
Local aPcc      := {}
Local aImpostos := {}

	If nVencto == 2
		dRef := dDtVencRea
	Else
		dRef := NXA->NXA_DTEMI
	Endif

	aPcc := newMinPcc(dRef, nBasePCC, cNatureza, "R", SA1->A1_COD + SA1->A1_LOJA)

	If Len(aPCC) > 4
		nValPIS  := aPcc[2]
		nValCOF  := aPcc[3]
		nValCSLL := aPcc[4]
	EndIf

	If nParcela == 1
		nTotImp := nTotImpIRF + nTotImpINS + nTotImpISS + nValPIS + nValCOF + nValCSLL
	Else
		nTotImp := nValPIS + nValCOF + nValCSLL
	EndIf

	aImpostos := {{nTotImpIRF, "IRRF"}, {nTotImpINS, "INSS"}, {nTotImpISS, "ISS"}, {nValPIS, "PIS"}, {nValCOF, "COFINS"}, {nValCSLL, "CSLL"}}

	For nCont := 1 To Len(aImpostos)
		If aImpostos[nCont][1] > 0
			cImpostos += aImpostos[nCont][2] + ","
		EndIf
	Next nCont

	If lFatParcel .And. nTotImp > nValParc
		cMemoLog += I18N(STR0301, {AllTrim(NXA->NXA_COD), nTotImp, cImpostos, nValParc, nParcela, AllTrim(NXA->NXA_CCDPGT), AllTrim(cNatureza)}) + CRLF // "A somatória de #2, dos impostos #3 ultrapassa o valor #4 da parcela #5. Verificar a condição de pagamento #6 e natureza #7."
		cMemoLog += (Replicate('-', 90)) + CRLF + CRLF
		lRet     := .F.
	Else
		nBaseCalc := nTotImpBas
	EndIf
	
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} J203VlDesp
Função que valida se existem despesas a cobrar para o Contrato Fixo ou Fatura Adicional

@param   cCFATAD   , caracatere, Código da Fatura Adicional
@param   cCFIXO    , caracatere, Código do Fixo
@param   lVincDspFx, caracatere, Vincula Despesa no Contrato Fixo?
@param   dDtIniDsp , date      , Data Inicial do Filtro de Despesas no Filtro

@return  lDesp     , boolean   , Existem despesas cobráveis?

@author  fabiana.silva
@since   13/12/2021
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function J203VlDesp(cCFATAD, cCFIXO, lVincDspFx, dDtIniDsp, dDtFimDsp)
Local cAliasCs  := GetNextAlias()
Local cAliasDsp := GetNextAlias()
Local lDesp     := .T.
Local cCodCaso  := ""
Local cCCLIEN   := ""
Local cCLOJA    := ""
Local dDIniD    := NIL
Local dDFinD    := NIL

	If FindFunction("J201BQDsp") .And. FindFunction("J203FCsAd")
		lDesp := .F.
		J203FCsAd(cCFATAD, , cCFIXO, cAliasCs)

		Do While !lDesp .And. !(cAliasCs)->(Eof())
			If !Empty(cCFATAD)
				cCodCaso := (cAliasCs)->NVW_CCASO
				cCCLIEN  := (cAliasCs)->NVW_CCLIEN
				cCLOJA   := (cAliasCs)->NVW_CLOJA
				cCCONTR  := (cAliasCs)->NVV_CCONTR
				dDIniD   := StoD((cAliasCs)->NVV_DTINID)
				dDFinD   := StoD((cAliasCs)->NVV_DTFIMD)
			Else
				cCCLIEN  := (cAliasCs)->NUT_CCLIEN
				cCLOJA   := (cAliasCs)->NUT_CLOJA
				cCodCaso := (cAliasCs)->NUT_CCASO
				cCCONTR  := (cAliasCs)->NT1_CCONTR
				cCodCaso := (cAliasCs)->NUT_CCASO
			EndIf
			cQry := "SELECT COUNT(1) CONTA "+ J201BQDsp(cCCLIEN, cCLOJA, cCodCaso, cCCONTR, lVincDspFx, dDtIniDsp, dDtFimDsp, , dDIniD, dDFinD, "2")
			cQry := ChangeQuery(cQry, .F.)
			dbUseArea( .T., 'TOPCONN', TcGenQry(,, cQry), cAliasDsp, .T., .F.)

			lDesp := (cAliasDsp)->(!Eof() .And. FIELD->CONTA > 0)
			(cAliasDsp)->(DbCloseArea())
			(cAliasCs)->(DbSkip())
		EndDo
		(cAliasCs)->(DbCloseArea())
	EndIf
Return lDesp

//--------------------------------------------------------------------
/*/{Protheus.doc} J203SldExc
Função para atualizar saldo exclusivo de honorários ou despesas do caso

@param   cTrab    , Alias da tabela que contém os cliente e casos da fatura
@param   nValorAdt, Valor do adiantamento disponível para uso na compensação
@param   lSubtrai , Se verdadeiro abate o valor do adiantamento exclusivo
         do saldo do caso.
@param   aUtiliza , Array com dados do adiantamento utilizado (Grid inferior)

@author  Jonatas Martins
@since   05/09/2021
/*/
//--------------------------------------------------------------------
Static Function J203SldExc(cTrab, nValorAdt, lSubtrai, aUtiliza)
Local cChave     := ""
Local cTipoAdt   := ""
Local nRecnoTrab := 0
Local nValor     := 0
Local aDadosAdt  := {}
Local lAdtExcl   := .T.

Default aUtiliza := {}

	If !Empty(cTrab)
		If nValorAdt > 0 // Inclusão de adiantamento via tela ou via compensação automática
			cChave     := (cTrab)->NWF_CCLIEN + (cTrab)->NWF_CLOJA + (cTrab)->NWF_CCASO
			cTipoAdt   := (cTrab)->CODTPADI
		ElseIf !Empty(aUtiliza) // Remoção de adiantamento via tela (Botão Remover)
			aDadosAdt := JurGetDados("NWF", 3, xFilial("NWF") + aUtiliza[2], {"NWF_CCLIEN", "NWF_CLOJA", "NWF_CCASO", "NWF_TPADI", "NWF_EXCLUS"})
			nValorAdt := aUtiliza[9]
			cChave    := aDadosAdt[1] + aDadosAdt[2] + aDadosAdt[3]
			cTipoAdt  := aDadosAdt[4]
			lAdtExcl  := aDadosAdt[5] == "1"
		EndIf

		If lAdtExcl
			nRecnoTrab := (cTrab)->(Recno())
			(cTrab)->(DbGoTop())
			
			While (cTrab)->(! Eof())
				nValor := nValorAdt
				If (cChave == (cTrab)->NWF_CCLIEN + (cTrab)->NWF_CLOJA + (cTrab)->NWF_CCASO) .And. (cTrab)->CODEXCL == "1"
					RecLock(cTrab, .F.)
					If cTipoAdt == "1" // Abate/devolve saldo exclusivo de despesas do caso
						(cTrab)->SALDESCAS += IIF(lSubtrai, nValor * - 1, nValor)
					ElseIf cTipoAdt == "2" // Abate/devolve saldo exclusivo de honorários do caso
						(cTrab)->SALHONCAS += IIF(lSubtrai, nValor * - 1, nValor)
					ElseIf cTipoAdt == "3" // Abate/devolve saldo exclusivo de ambos no caso
						If lSubtrai
							If (cTrab)->SALDESCAS > 0
								If nValor >= (cTrab)->SALDESCAS
									nValor -= (cTrab)->SALDESCAS
									(cTrab)->SALDESCAS := 0
								Else
									(cTrab)->SALDESCAS -= nValor
									nValor := 0
								EndIf
							EndIf

							If nValor > 0
								(cTrab)->SALHONCAS -= IIF((cTrab)->SALHONCAS > nValor, nValor, (cTrab)->SALHONCAS)
							EndIf
						Else
							If (cTrab)->NXC_VLDFAT > 0
								If nValor >= ((cTrab)->NXC_VLDFAT - (cTrab)->SALDESCAS) // Diferença
									nValor -= ((cTrab)->NXC_VLDFAT - (cTrab)->SALDESCAS)
									(cTrab)->SALDESCAS := (cTrab)->NXC_VLDFAT
								Else
									(cTrab)->SALDESCAS += nValor
									nValor := 0
								EndIf
							EndIf

							If nValor > 0 .And. (cTrab)->NXC_VLHFAT > 0
								(cTrab)->SALHONCAS += nValor
							EndIf
						EndIf
					EndIf
					(cTrab)->(MsUnLock())
				EndIf
				(cTrab)->(DbSkip())
			EndDo

			(cTrab)->(DbGoTo(nRecnoTrab))
		EndIf
	EndIf

Return Nil