#INCLUDE "JURA146.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA146
Consulta de WO / WO por caso.

@author David Gonçalves Fernandes
@since 29/12/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA146()
Local oRelation     := Nil
Local oFWLayer      := Nil
Local oPanelDown    := Nil
Local oPanelUp      := Nil
Local cLojaAuto     := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local aCoors        := FwGetDialogSize( oMainWnd )
Local lVldUser      := Iif(FindFunction("JurVldUxP"), JurVldUxP(), .T.)

Private oDlg        := Nil
Private nOperacao   := 0
Private oBrowseNUF  := Nil
Private oBrowseNUG  := Nil

If lVldUser
	Define MsDialog oDlg Title STR0001 From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] STYLE nOR(WS_VISIBLE, WS_POPUP) Pixel //"Operação de Pré-Faturas"
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlg, .F., .T. )
	
	// Painel Superior
	oFWLayer:AddLine( 'UP', 50, .F. )
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
	oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )
	
	oBrowseNUF := FWMBrowse():New()
	oBrowseNUF:SetOwner( oPanelUp )
	oBrowseNUF:SetDescription( STR0007 ) // "Consulta de WO"
	oBrowseNUF:SetAlias( "NUF" )
	oBrowseNUF:SetLocate()
	oBrowseNUF:SetMenuDef( 'JURA146' )
	oBrowseNUF:DisableDetails()
	oBrowseNUF:SetProfileID('1')
	oBrowseNUF:SetCacheView(.F.)
	oBrowseNUF:SetWalkThru(.F.)
	oBrowseNUF:SetAmbiente(.F.)
	oBrowseNUF:ForceQuitButton(.T.)
	oBrowseNUF:SetBeforeClose({|| oBrowseNUF:VerifyLayout(), oBrowseNUG:VerifyLayout()})
	JurSetLeg( oBrowseNUF, "NUF" )
	JurSetBSize( oBrowseNUF )
	oBrowseNUF:Activate()
	
	// Painel Inferior
	oFWLayer:addLine( 'DOWN', 50, .F. )
	oFWLayer:AddCollumn( 'ALL',  100, .T., 'DOWN' )
	oPanelDown  := oFWLayer:GetColPanel( 'ALL', 'DOWN'  )
	
	oBrowseNUG := FWMBrowse():New()
	oBrowseNUG:SetOwner( oPanelDown )
	oBrowseNUG:SetDescription( STR0007 )
	oBrowseNUG:SetAlias( "NUG" )
	Iif(cLojaAuto == "1", JurBrwRev(oBrowseNUG, "NUG", {"NUG_CLOJA"}), )
	oBrowseNUG:SetMenuDef( 'JURA201' )
	oBrowseNUG:DisableDetails()
	oBrowseNUG:SetProfileID('2')
	JurSetLeg( oBrowseNUG, "NUG" )
	JurSetBSize( oBrowseNUG )
	oBrowseNUG:Activate()
	
	// Relacionamento entre os Paineis
	oRelation := FWBrwRelation():New()
	oRelation:AddRelation( oBrowseNUF, oBrowseNUG, { { "NUG_FILIAL", "xFilial( 'NUG' )" }, {"NUG_CWO", "NUF_COD" } } )
	oRelation:Activate()
	
	Activate MsDialog oDlg Center
EndIf

Return Nil

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

@author Felipe Bonvicini Conti
@since 17/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0024, "J146FltCs()"    , 0, 1, 0, .T. } ) // "Pesq. por Caso"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA146", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0011, "JA146SET()"     , 0, 6, 0, NIL } ) // "Cancelar WO"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Consulta WO

@author Felipe Bonvicini Conti
@since 17/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView      := Nil
Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local oModel     := FWLoadModel( "JURA146" )
Local oStructNUF := FWFormStruct( 2, "NUF" )
Local oStructNW0 := FWFormStruct( 2, "NW0" ) // "WO - Time-Sheet"
Local oStructNVZ := FWFormStruct( 2, "NVZ" ) // "WO - Despesa"
Local oStructNWZ := FWFormStruct( 2, "NWZ" ) // "Resumo de Despesas por Tipo"
Local oStructNW4 := FWFormStruct( 2, "NW4" ) // "WO - Tabelado"
Local oStructNWC := FWFormStruct( 2, "NWC" ) // "WO - Êxito"
Local oStructNWD := FWFormStruct( 2, "NWD" ) // "WO - Fat Adic"
Local oStructNWE := FWFormStruct( 2, "NWE" ) // "WO - Fixo"

	// Adiciona o campo de Tracker Contábil à View
	oStructNWZ := J146CpoCTB(oStructNWZ, "NWZ", "V")

	If NUF->(ColumnPos("NUF_DTCEMI")) > 0
		oStructNUF:RemoveField( "NUF_DTCEMI" )
		oStructNUF:RemoveField( "NUF_DTCCAN" )
	EndIf

	If( cLojaAuto == "1")
		oStructNW0:RemoveField( "NW0_CLOJA" )
		oStructNVZ:RemoveField( "NVZ_CLOJA" )
		oStructNWZ:RemoveField( "NWZ_CLOJA" )
		oStructNW4:RemoveField( "NW4_CLOJA" )
		oStructNWC:RemoveField( "NWC_CLOJA" )
		oStructNWD:RemoveField( "NWD_CLOJA" )
	EndIf

	oStructNW0:RemoveField( "NW0_CWO" )
	oStructNW0:RemoveField( "NW0_CPART1" )
	oStructNVZ:RemoveField( "NVZ_CWO" )
	oStructNWZ:RemoveField( "NWZ_CODWO" )
	oStructNW4:RemoveField( "NW4_CWO" )
	oStructNW4:RemoveField( "NW4_CPART1" )
	oStructNWC:RemoveField( "NWC_CWO" )
	oStructNWD:RemoveField( "NVD_CWO" )
	oStructNWE:RemoveField( "NWE_CWO" )

	oStructNW0:RemoveField("NW0_SITUAC")
	oStructNW0:RemoveField("NW0_PRECNF")
	oStructNW0:RemoveField("NW0_CFATUR")
	oStructNW0:RemoveField("NW0_CESCR")
	oStructNW0:RemoveField("NW0_CANC")
	oStructNW0:RemoveField("NW0_CODUSR")
	oStructNW0:RemoveField("NW0_COTAC1")
	oStructNW0:RemoveField("NW0_COTAC2")
	oStructNW0:RemoveField("NW0_CPART2")

	oStructNVZ:RemoveField( "NVZ_SITUAC" )
	oStructNVZ:RemoveField( "NVZ_PRECNF" )
	oStructNVZ:RemoveField( "NVZ_CFATUR" )
	oStructNVZ:RemoveField( "NVZ_CESCR" )
	oStructNVZ:RemoveField( "NVZ_CANC" )
	oStructNVZ:RemoveField( "NVZ_CODUSR" )
	oStructNVZ:RemoveField( "NVZ_COTAC1" )
	oStructNVZ:RemoveField( "NVZ_COTAC2" )

	oStructNW4:RemoveField( "NW4_SITUAC" )
	oStructNW4:RemoveField( "NW4_PRECNF" )
	oStructNW4:RemoveField( "NW4_CFATUR" )
	oStructNW4:RemoveField( "NW4_CESCR" )
	oStructNW4:RemoveField( "NW4_CANC" )
	oStructNW4:RemoveField( "NW4_CODUSR" )
	oStructNW4:RemoveField( "NW4_COTAC1" )
	oStructNW4:RemoveField( "NW4_COTAC2" )

	oStructNWD:RemoveField( "NWD_SITUAC" )
	oStructNWD:RemoveField( "NWD_PRECNF" )
	oStructNWD:RemoveField( "NWD_CFATUR" )
	oStructNWD:RemoveField( "NWD_CESCR" )
	oStructNWD:RemoveField( "NWD_CWO" )
	oStructNWD:RemoveField( "NWD_CANC" )
	oStructNWD:RemoveField( "NWD_CODUSR" )
	oStructNWD:RemoveField( "NWD_COTAC1" )
	oStructNWD:RemoveField( "NWD_COTAC2" )
	oStructNWD:RemoveField( "NWD_COTAC3" )
	oStructNWD:RemoveField( "NWD_COTAC4" )

	oStructNWE:RemoveField( "NWE_SITUAC" )
	oStructNWE:RemoveField( "NWE_PRECNF" )
	oStructNWE:RemoveField( "NWE_CFATUR" )
	oStructNWE:RemoveField( "NWE_CESCR" )
	oStructNWE:RemoveField( "NWE_CANC" )
	oStructNWE:RemoveField( "NWE_CODUSR" )
	oStructNWE:RemoveField( "NWE_COTAC1" )
	oStructNWE:RemoveField( "NWE_COTAC2" )

	JurSetAgrp( 'NUF',, oStructNUF ) // Ativa o agrupamento de campos da tabela NUF definido no cadastro de agrupamentos.

	oView := FWFormView():New()
	oView:SetModel( oModel )

	oView:AddField( "JURA146_NUF", oStructNUF, "NUFMASTER" )

	oView:AddGrid(  "JURA146_NW0", oStructNW0, "NW0DETAIL" ) //TS
	oView:AddGrid(  "JURA146_NVZ", oStructNVZ, "NVZDETAIL" ) //Desp
	oView:AddGrid(  "JURA146_NWZ", oStructNWZ, "NWZDETAIL" ) //Resumo Desp
	oView:AddGrid(  "JURA146_NW4", oStructNW4, "NW4DETAIL" ) //Tab
	oView:AddGrid(  "JURA146_NWD", oStructNWD, "NWDDETAIL" ) //Adicional
	oView:AddGrid(  "JURA146_NWE", oStructNWE, "NWEDETAIL" ) //Fixo

	oView:CreateHorizontalBox( 'PRINCIPAL', 100 )

	oView:CreateFolder("FOLDER_01", 'PRINCIPAL')
	oView:AddSheet("FOLDER_01", "ABA_01", STR0007 ) //"Consulta de WO"
	oView:AddSheet("FOLDER_01", "ABA_02", STR0013 ) //"WO - Time-Sheet"
	oView:AddSheet("FOLDER_01", "ABA_03", STR0014 ) //"WO - Despesas"
	oView:AddSheet("FOLDER_01", "ABA_04", STR0015 ) //"WO - Tabelado"
	oView:AddSheet("FOLDER_01", "ABA_05", STR0020 ) //"WO - Parc. Adicional"
	oView:AddSheet("FOLDER_01", "ABA_06", STR0021 ) //"WO - Parc. Fixo"

	oView:CreateHorizontalBox("BOX_01_F01_A01",100,,,"FOLDER_01","ABA_01") //"WO"
	oView:CreateHorizontalBox("BOX_01_F01_A02",100,,,"FOLDER_01","ABA_02") //"WO - Time-Sheet"
	oView:CreateHorizontalBox("BOX_01_F01_A03", 50,,,"FOLDER_01","ABA_03") //"WO - Despesas"
	oView:CreateHorizontalBox("BOX_01_F01_A08", 50,,,"FOLDER_01","ABA_03") //"Resumo por Tipo"
	oView:EnableTitleView( "JURA146_NWZ" )
	oView:CreateHorizontalBox("BOX_01_F01_A04",100,,,"FOLDER_01","ABA_04") //"WO - Tabelado"
	oView:CreateHorizontalBox("BOX_01_F01_A06",100,,,"FOLDER_01","ABA_05") //"WO - Parc. Adicional"
	oView:CreateHorizontalBox("BOX_01_F01_A07",100,,,"FOLDER_01","ABA_06") //"WO - Parc. Fixo"

	oView:SetOwnerView( "JURA146_NUF", "BOX_01_F01_A01" )
	oView:SetOwnerView( "JURA146_NW0", "BOX_01_F01_A02" )
	oView:SetOwnerView( "JURA146_NVZ", "BOX_01_F01_A03" )
	oView:SetOwnerView( "JURA146_NWZ", "BOX_01_F01_A08" )
	oView:SetOwnerView( "JURA146_NW4", "BOX_01_F01_A04" )
	oView:SetOwnerView( "JURA146_NWD", "BOX_01_F01_A06" )
	oView:SetOwnerView( "JURA146_NWE", "BOX_01_F01_A07" )

	oView:SetViewProperty("NWZDETAIL", "GRIDDOUBLECLICK", {{|oFormulario, cFieldName, nLineGrid, nLineModel| Iif(Alltrim(cFieldName) == "NWZ__CTB", JA146Tracker(oView), .T.) }})

	oView:SetDescription( STR0007 ) // "Consulta de WO"
	oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Consulta WO

@author Felipe Bonvicini Conti
@since 17/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNUF := FWFormStruct( 1, "NUF" )

Local oStructNW0 := FWFormStruct( 1, "NW0" ) // "WO - Time-Sheet"
Local oStructNVZ := FWFormStruct( 1, "NVZ" ) // "WO - Despesa"
Local oStructNWZ := FWFormStruct( 1, "NWZ" ) // "Resumo de Despesas por Tipo"
Local oStructNW4 := FWFormStruct( 1, "NW4" ) // "WO - Tabelado"
Local oStructNWC := FWFormStruct( 1, "NWC" ) // "WO - Êxito"
Local oStructNWD := FWFormStruct( 1, "NWD" ) // "WO - Fat Adic"
Local oStructNWE := FWFormStruct( 1, "NWE" ) // "WO - Fixo"

// Adiciona o campo de Tracker Contábil ao Model
oStructNWZ := J146CpoCTB(oStructNWZ, "NWZ", "M")

oStructNUF:SetProperty("NUF_OBSCAN", MODEL_FIELD_OBRIGAT, .F.) // Tira obrigatoriedade do campo de Observação do Cancelamento
oStructNUF:SetProperty("NUF_CMOTCA", MODEL_FIELD_OBRIGAT, .F.) // Tira obrigatoriedade do campo de Motivo do Cancelamento

oModel:= MPFormModel():New( "JURA146", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NUFMASTER", NIL, oStructNUF, /*Pre-Validacao*/, /*Pos-Validacao*/ )

oModel:AddGrid( "NW0DETAIL", "NUFMASTER" /*cOwner*/, oStructNW0, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ ) 
oModel:AddGrid( "NVZDETAIL", "NUFMASTER" /*cOwner*/, oStructNVZ, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ ) 
oModel:AddGrid( "NWZDETAIL", "NVZDETAIL" /*cOwner*/, oStructNWZ, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ ) 
oModel:AddGrid( "NW4DETAIL", "NUFMASTER" /*cOwner*/, oStructNW4, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ ) 
oModel:AddGrid( "NWCDETAIL", "NUFMASTER" /*cOwner*/, oStructNWC, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ ) 
oModel:AddGrid( "NWDDETAIL", "NUFMASTER" /*cOwner*/, oStructNWD, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ ) 
oModel:AddGrid( "NWEDETAIL", "NUFMASTER" /*cOwner*/, oStructNWE, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ ) 

oModel:SetDescription( STR0008 ) // "Modelo de Dados de Consulta de WO"
oModel:GetModel( "NUFMASTER" ):SetDescription( STR0009 ) // "Dados de Consulta de WO"

oModel:GetModel( "NW0DETAIL" ):SetDescription( STR0013 ) // "Dados de WO - Time-Sheet"
oModel:GetModel( "NVZDETAIL" ):SetDescription( STR0014 ) // "Dados de WO - Despesas"
oModel:GetModel( "NWZDETAIL" ):SetDescription( STR0038 ) // "Resumo de Despesas por Tipo"
oModel:GetModel( "NW4DETAIL" ):SetDescription( STR0015 ) // "Dados de WO - Tabelado"

oModel:GetModel( "NWCDETAIL" ):SetDescription( STR0019 ) // "WO - Parc. Êxito"
oModel:GetModel( "NWDDETAIL" ):SetDescription( STR0020 ) // "WO - Parc. Adicional"
oModel:GetModel( "NWEDETAIL" ):SetDescription( STR0021 ) // "WO - Parc. Fixo"

oModel:SetRelation( "NW0DETAIL", { { "NW0_FILIAL", "xFilial( 'NW0' ) " }, { "NW0_CWO", "NUF_COD" } } , NW0->( IndexKey( 8 ) ) )
oModel:SetRelation( "NVZDETAIL", { { "NVZ_FILIAL", "xFilial( 'NVZ' ) " }, { "NVZ_CWO", "NUF_COD" } } , NVZ->( IndexKey( 8 ) ) )
oModel:SetRelation( "NWZDETAIL", { { "NWZ_FILIAL", "xFilial( 'NWZ' ) " }, { "NWZ_CODWO", "NVZ_CWO" } }, NWZ->( IndexKey( 1 ) ) )
oModel:SetRelation( "NW4DETAIL", { { "NW4_FILIAL", "xFilial( 'NW4' ) " }, { "NW4_CWO" , "NUF_COD" } } , NW4->( IndexKey( 3 ) ) )

oModel:SetRelation( "NWCDETAIL", { { "NWC_FILIAL", "xFilial( 'NWC' ) " }, { "NWC_CWO" , "NUF_COD" } }, NWC->( IndexKey( 6 ) ) )
oModel:SetRelation( "NWDDETAIL", { { "NWD_FILIAL", "xFilial( 'NWD' ) " }, { "NWD_CWO" , "NUF_COD" } }, NWD->( IndexKey( 6 ) ) )
oModel:SetRelation( "NWEDETAIL", { { "NWE_FILIAL", "xFilial( 'NWE' ) " }, { "NWE_CWO" , "NUF_COD" } }, NWE->( IndexKey( 6 ) ) )

oModel:GetModel( "NW0DETAIL" ):SetUniqueLine( { "NW0_CTS"   } )
oModel:GetModel( "NVZDETAIL" ):SetUniqueLine( { "NVZ_CDESP" } )
oModel:GetModel( "NWZDETAIL" ):SetUniqueLine( { "NWZ_CTPDSP" } )
oModel:GetModel( "NW4DETAIL" ):SetUniqueLine( { "NW4_CLTAB" } )
oModel:GetModel( "NWCDETAIL" ):SetUniqueLine( { "NWC_CEXITO" } )
oModel:GetModel( "NWDDETAIL" ):SetUniqueLine( { "NWD_CFTADC" } )
oModel:GetModel( "NWEDETAIL" ):SetUniqueLine( { "NWE_CFIXO " } )

JurSetRules( oModel, "NUFMASTER",, "NUF",, )
JurSetRules( oModel, "NW0DETAIL",, "NW0",, )
JurSetRules( oModel, "NVZDETAIL",, "NVZ",, )
JurSetRules( oModel, "NWZDETAIL",, "NWZ",, )
JurSetRules( oModel, "NW4DETAIL",, "NW4",, )
JurSetRules( oModel, "NWCDETAIL",, "NWC",, )
JurSetRules( oModel, "NWDDETAIL",, "NWD",, )
JurSetRules( oModel, "NWEDETAIL",, "NWE",, )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA146SET
Cancela o WO: volta os lançamentos para 'Pendente'

@author David Gonçalves Fernandes
@since 04/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA146SET()
Local lRet      := .T.
Local aArea     := GetArea()
Local cWOCodig  := NUF->NUF_COD
Local aObs      := {}
Local nLanctos  := 0
Local cMsg      := ''

	If NUF->NUF_SITUAC == '1'
		aOBS := JurMotWO('NUF_OBSCAN', STR0011, ) 
		If !Empty(aOBS)
			nLanctos := JACANCWO(cWOCodig, aObs)
			If nLanctos >= 0
				cMsg := Replicate('-', 65) + CRLF + STR0016 + Alltrim(Str(nLanctos)) + STR0017 // "WO Cancelado:" / " Lançamentos restaurados"
				AutoGrLog(cMsg)
			Else
				cMsg := STR0022 //"Problema para cancelar o WO"
			EndIf
		EndIf
	Else
		cMsg := STR0018 //"O WO já está cancelado"
		lRet := .F.
	EndIf
	
	If nLanctos >= 0
		JurLogLote()
	Else
		JurMsgErro( cMsg )
	EndIf
	
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J146FltCs()
Tela de parametros para fazer filtro por caso. 

@param oModel  Estrutura da tela de operações de pré-fatura que sofre ação do filtro 

@author Luciano Pereira dos Santos
@since 24/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J146FltCs()
Local oGetClie   := Nil
Local oGetLoja   := Nil
Local oGetCaso   := Nil
Local oDtIni     := Nil
Local oDtFim     := Nil
Local oDlg       := Nil
Local lRet       := .T.
Local cFiltro    := "1 = 1"
Local dDtIni     := Date() - 30
Local dDtFim     := Date()
Local oFilDt     := Nil
Local cFilDt     := STR0030 // "Emissão"
Local lLojaAuto  := SuperGetMv( "MV_JLOJAUT", .F., "2", ) == "1" //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local oLayer     := FWLayer():New()
Local oMainColl  := Nil
Local nLocLj     := 0
Local aButtons   := {}

Private cGetGrup := Criavar( 'A1_GRPVEN', .F. )
Private cGetClie := Criavar( 'A1_COD', .F.) 
Private cGetLoja := Criavar( 'A1_LOJA', .F. ) 
Private cGetCaso := Criavar( 'NUG_CCASO', .F. )

If lLojaAuto .And. FindFunction("J146VLDFL") //Proteção 12.1.19
	DEFINE MSDIALOG oDlg TITLE STR0025 FROM 0,0 TO 190,420 PIXEL // "Pesquisa por caso"
	oLayer:init(oDlg,.F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
	oLayer:addCollumn("MainColl",100,.F.) //Cria as colunas do Layer
	oMainColl := oLayer:GetColPanel( 'MainColl' )

	oGetClie := TJurPnlCampo():New(05,05,60,22,oMainColl, , 'NUG_CCLIEN',{|| },{||},,,,'SA1NUH') //"Cliente"
	oGetClie:SetValid( {||JurVldCli(, oGetClie:GetValue(), oGetLoja:GetValue(),,, "CLI") } )
	oGetClie:SetChange( {|| J146Gatil(@oGetClie, @oGetLoja, @oGetCaso, "CLI")} )

	oGetLoja := TJurPnlCampo():New(05,75,40,22,oMainColl, , 'NUG_CLOJA',{|| },{||},,,,) //"Loja"
	oGetLoja:SetValid(  {|| JurVldCli(, oGetClie:GetValue(), oGetLoja:GetValue(),,, "LOJ") })
	oGetLoja:SetChange( {|| J146Gatil(@oGetClie, @oGetLoja, @oGetCaso, "LOJ")} )
	If lLojaAuto
		oGetLoja:Visible(.F.)
		nLocLj := 70
	EndIf

	oGetCaso := TJurPnlCampo():New(05, 145-nLocLj, 60, 22, oMainColl,, 'NUG_CCASO', {|| }, {|| },,,, 'NVELOJ') //"Caso"
	oGetCaso:SetValid( {|| JurVldCli(, oGetClie:GetValue(), oGetLoja:GetValue(), oGetCaso:GetValue(),, "CAS") })
	oGetCaso:SetChange( {|| J146Gatil(@oGetClie, @oGetLoja, @oGetCaso, "CAS")} )
	oGetCaso:oCampo:bWhen := {|| JWhenCaso(oGetClie, oGetLoja, oGetCaso) }

	oFilDt := TJurPnlCampo():New(35,05,60,22,oMainColl, STR0029, '',{|| },{|| cFilDt:= oFilDt:Valor }, STR0030,,,,,(STR0030+';'+STR0031) ) //"Filtra Por" ## "Emissão" ### "Cancelamento"
	
	oDtIni := TJurPnlCampo():New(35,75,60,22,oMainColl, STR0032, 'NUF_DTEMI',{|| },{|| dDtIni := oDtIni:Valor },DtoC(dDtIni),,,) //"Data Início"
	oDtFim := TJurPnlCampo():New(35,145,60,22,oMainColl, STR0033, 'NUF_DTEMI',{|| },{|| dDtFim := oDtFim:Valor },DtoC(dDtFim),,,) //"Data Fim"

	Aadd( aButtons, {"FilterRemover", {|| oBrowseNUF:SetFilterDefault(cFiltro)}, STR0026+"...", STR0026 , {|| .T.}} ) // STR0026 "Remover Filtro"

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar;
				(oDlg,;
				{|| ( lRet := (J146GetFlt(cGetClie, cGetLoja, cGetCaso, dDtIni, dDtFim, cFilDt )), IIf(lRet == .T.,oDlg:End(),.F.) )},;
				{|| (lRet := .T.), oDlg:End() },; //"Sair"
				, aButtons,/*nRecno*/,/*cAlias*/, .F., .F.,.F.,.T.,.F. )

Else //12.1.17
	DEFINE MSDIALOG oDlg TITLE STR0025 FROM 0,0 TO 180,420 PIXEL // "Pesquisa por caso"
	
		oGetClie := TJurPnlCampo():New(05,05,60,22,oDlg, , 'NUG_CCLIEN',{|| },{|| cGetClie := oGetClie:Valor},,,,'SA1NUH') //"Cliente"

		oGetLoja := TJurPnlCampo():New(05,75,35,22,oDlg, , 'NUG_CLOJA',{|| },{|| cGetLoja := oGetLoja:Valor},,,,) //"Loja"
		oGetLoja:oCampo:bValid  := {|| J146VLDFL('1', oGetClie, oGetLoja, oGetCaso) }
	
		oGetCaso := TJurPnlCampo():New(05,145,60,22,oDlg, ,'NUG_CCASO',{|| },{|| cGetCaso := oGetCaso:Valor},,,,'NVELOJ') //"Caso"
		oGetCaso:oCampo:bValid  := {|| J146VLDFL('2', oGetClie, oGetLoja, oGetCaso) }
	
		oFilDt := TJurPnlCampo():New(35,05,60,22,oDlg, STR0029, '',{|| },{|| cFilDt:= oFilDt:Valor }, STR0030,,,,,(STR0030+';'+STR0031) ) //"Filtra Por" ## "Emissão" ### "Cancelamento"
		
		oDtIni := TJurPnlCampo():New(35,75,60,22,oDlg, STR0032, 'NUF_DTEMI',{|| },{|| dDtIni := oDtIni:Valor },DtoC(dDtIni),,,) //"Data Início"
		oDtFim := TJurPnlCampo():New(35,145,60,22,oDlg, STR0033, 'NUF_DTEMI',{|| },{|| dDtFim := oDtFim:Valor },DtoC(dDtFim),,,) //"Data Fim"
		
		
		@ 070,005 Button STR0001 Size 050,012 PIXEL OF oDlg  Action ( lRet := (J146GetFlt(cGetClie, cGetLoja, cGetCaso, dDtIni, dDtFim, cFilDt )), IIf(lRet == .T.,oDlg:End(),.F.) ) //"Pesquizar"
		@ 070,075 Button STR0026 Size 050,012 PIXEL OF oDlg  Action (oBrowseNUF:SetFilterDefault(cFiltro)) //"Remover Filtro"
		@ 070,145 Button STR0023 Size 050,012 PIXEL OF oDlg  Action ((lRet := .T.), oDlg:End()) //"Sair"
		
	ACTIVATE MSDIALOG oDlg CENTERED 
EndIf

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } J146VLDFL
Rotina de validação e preenchimento dos campos Grupo,Cliente,Loja e Caso 
para filtrar por caso

@Param  cTipo   	Tipo da Ação: 1 = Cliente/Loja;  2 = Caso
@Param	oGetClie    Objeto da classe TJurPnlCampo contendo cliente
@Param	oGetLoja    Objeto da classe TJurPnlCampo contendo loja
@Param	oGetCaso    Objeto da classe TJurPnlCampo contendo Caso

@author Luciano Pereira dos Santos
@since 24/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J146VLDFL(cTipo, oGetClie, oGetLoja, oGetCaso)
Local lRet    := .T.
Local cMvCaso := GETMV('MV_JCASO1') 
Local cClie   := oGetClie:Valor 
Local cLoja   := oGetLoja:Valor
Local cCaso   := oGetCaso:Valor
Local aArea   := GetArea()

DbSelectArea("NVE")
DbSetOrder(1)

If cTipo == '1'
	If !Empty( cClie ) .And. !Empty( cLoja ) 
		lRet := DbSeek(xFilial('NVE') + cClie + cLoja)
	EndIf
ElseIf cTipo == '2' .And. !Empty(cCaso) 
	If (Len(Alltrim(cCaso)) < (TamSX3('NVE_NUMCAS')[1]))
		lRet := .F.
	ElseIf cMvCaso == '1'
		DbSetOrder(1)
		If !Empty( cClie ) .And. !Empty( cLoja ) 
			lRet := DbSeek(xFilial('NVE') + cClie + cLoja + cCaso)
		Else
			lRet := .F.
		EndIf
	ElseIf cMvCaso == '2'
		DbSetOrder(3)
		If DbSeek(xFilial('NVE') + cCaso )
			oGetClie:Valor := Posicione('NVE', 3, xFilial('NVE') + cCaso, 'NVE_CCLIEN')
			oGetLoja:Valor := Posicione('NVE', 3, xFilial('NVE') + cCaso, 'NVE_LCLIEN')
			cGetClie       := oGetClie:Valor // variável private da função "J146FltCs"
			cGetLoja       := oGetLoja:Valor // variável private da função "J146FltCs"
		EndIf
	EndIf
EndIf

If !lRet
	JurMsgErro(STR0027) // "Preencher corretamente as informações"
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J146GetFlt()
Função que devolve o filtro para a dialog de pesquisa de casos. 

@Param oGetClie		Objeto contendo o método "valor" com Código do cliente
@Param oGetLoja		Objeto contendo o método "valor" com Código da loja
@Param oGetCaso		Objeto contendo o método "valor" com Código do Caso

@Return    @lret retono com exito ou fracaço ao realizar o filtro.

@author Luciano Pereira dos Santos
@since 24/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J146GetFlt(cGetClie, cGetLoja, cGetCaso, dDtIni, dDtFim, cFilDt)
Local aArea   := GetArea()
Local cQuery  := " "
Local cQryRes := GetNextAlias()
Local cRet    := ""
Local lRet    := .T.
Local cFiltro := "1 = 1"

If lRet
	If Empty(cGetClie) .Or. Empty(cGetLoja)
		lRet := JurMsgErro(STR0027) // "Preencher corretamente as informações"
	EndIf
EndIf

If lRet
	If Empty(cFilDt)
		lRet := JurMsgErro(STR0034) // "Escolha um filtro por Data!"
	EndIf
EndIf

If lRet
	If dDtIni > dDtFim
		lRet := JurMsgErro(STR0035) // "A data início não pode ser maior que a data fim!"
	EndIf
EndIf

If (lRet)
	
	cQuery := " SELECT NUF.NUF_COD "
	cQuery += " FROM " + RetSqlName("NUF") + " NUF, "
	cQuery +=      " " + RetSqlName("NUG") + " NUG "
	cQuery +=     " WHERE NUF.NUF_FILIAL = '" + xFilial("NUF") + "' "
	cQuery +=         " AND NUG.NUG_FILIAL = '" + xFilial("NUG") + "' "
	If Alltrim(cFilDt) == STR0030 //"Emissão"
		cQuery +=     " AND NUF.NUF_DTEMI >= '" + DtoS(dDtIni) + "' "
		cQuery +=     " AND NUF.NUF_DTEMI <= '" + DtoS(dDtFim) + "' "
	ElseIf Alltrim(cFilDt) == STR0031 //"Cancelamento"
		cQuery +=     " AND NUF.NUF_DTCAN >= '" + DtoS(dDtIni) + "' "
		cQuery +=     " AND NUF.NUF_DTCAN <= '" + DtoS(dDtFim) + "' "
	EndIf
	cQuery +=         " AND NUG.NUG_CWO = NUF.NUF_COD "
	If !Empty(cGetCaso)
		cQuery += " AND NUG.NUG_CCASO = '" + cGetCaso + "' "
	EndIf
	If !Empty(cGetClie) .And. !Empty(cGetLoja)
		cQuery += " AND NUG.NUG_CCLIEN = '" + cGetClie + "' "
		cQuery += " AND NUG.NUG_CLOJA  = '" + cGetLoja + "' "
	EndIf
	cQuery += " AND NUF.D_E_L_E_T_ = ' ' "
	cQuery += " AND NUG.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY NUF.NUF_COD "
	
	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )
	
	If !(cQryRes)->( EOF() )
		
		cRet +=  "(NUF_COD $ '"
		While !(cQryRes)->( EOF() )
			cRet += (cQryRes)->NUF_COD + "|"
			(cQryRes)->( dbskip() )
		End
		cRet += "')"
		
	EndIf
	
	(cQryRes)->( DbCloseArea() )
	
	If Len(cRet) > 0
		
		If Len(cRet) < 2000 // proteção para o limite do filtro
			oBrowseNUF:SetFilterDefault( cRet )
		Else
			lRet := JurMsgErro(STR0036 + CRLF + STR0037) //"O intervalo de tempo informado excedeu o retorno maxímo de registros!" ## "Por favor, selecione um intervalo de tempo menor"
			oBrowseNUF:SetFilterDefault( cFiltro )
		EndIf
		
	Else
		lRet := JurMsgErro(STR0028) // "Não foram encontrados WO para o filtro informado!"
		oBrowseNUF:SetFilterDefault( cFiltro )
	EndIf
	
EndIf

RestArea( aArea )

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} J146Gatil(oGetClie, oGetLoja, oGetCaso, cVal)
Gatilhos para clien/loja/Caso

@author Bruno Ritter
@since 03/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J146Gatil(oGetClie, oGetLoja, oGetCaso, cVal)
Local cNumCaso  := SuperGetMV('MV_JCASO1',, '1') //Defina a sequência da numeração do Caso. (1- Por cliente;2- Independente do cliente.)
Local aCliLoj   := {}
Local cLojaAuto := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

If (Upper(cVal) == "CLI")
	cGetClie := oGetClie:GetValue()
	If(cLojaAuto == "1" .And. !Empty(cGetClie))
		cGetLoja := JurGetLjAt()
		oGetLoja:SetValue(JurGetLjAt())
	Else
		cGetLoja := Criavar( 'A1_LOJA', .F. ) 
		oGetLoja:SetValue(Criavar( 'A1_LOJA', .F. ))
	EndIf
	J146Gatil(oGetClie, oGetLoja, oGetCaso, "LOJ")

ElseIf (Upper(cVal) == "LOJ" .And. !Empty(cGetCaso))
	cGetLoja := oGetLoja:GetValue()
	If (!JurClxCa(cGetClie, cGetLoja, cGetCaso)) //Se caso NÃO pertence ao cliente
		cGetCaso := Criavar( 'NUG_CCASO', .F. )
		oGetCaso:SetValue( Criavar( 'NUG_CCASO', .F. ) )
	EndIf

ElseIf (Upper(cVal) == "CAS")
	cGetCaso := oGetCaso:GetValue()
	If (cNumCaso == "2" .And. Empty(cGetClie) .And. Empty(cGetLoja))
		aCliLoj := JCasoAtual(cGetCaso)
		If (!Empty(aCliLoj))
			cGetClie := aCliLoj[1][1]
			oGetClie:SetValue( aCliLoj[1][1] )
			cGetLoja := aCliLoj[1][2]
			oGetLoja:SetValue( aCliLoj[1][2] )
		EndIf
	EndIf
EndIf

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} Ja146WoCan
Prepara e envia os WO para cancelamento.

@param  aCodWO     - WOs que serão cancelados.
@param  cCodMotWo  - Código de Motivo WO
@param  cObsMotWo  - Observação de WO
@param  cCodPart   - Código do Participante

@return aRetorno   - {Código do WO, Situação, Observação)

@author  fabiana.silva
@since   19/04/2021
/*/
//-------------------------------------------------------------------
Function Ja146WoCan(aCodWO, cCodMotWo, cObsMotWo, cCodPart)
Local aArea        := GetArea()
Local aAreaNXV     := NXV->(GetArea())
Local aAreaNUF     := {}
Local nCont        := 0
Local aObs         := {}
Local aRetorno     := {}

Default aCodWO     := {}
Default cCodMotWo  := ""
Default cObsMotWo  := ""
Default cCodPart   := __cUserId

	If ValType(aCodWO) == "A"
		aAreaNUF := NUF->(GetArea())
		// Carrega observação de WO
		aObs := {cObsMotWo, cCodMotWo, cCodPart} // Observação de WO, Código de Motivo WO, Código do Participante
		NUF->(DbSetOrder(1)) // NUF_FILIAL + NUF_COD

		// Processa time sheets recebidos
		For nCont := 1 To Len(aCodWO)
			If NUF->(DbSeek(xFilial("NUE") + aCodWO[nCont]))
				
				// Pré validações
				If NUF->NUF_SITUAC == "2"
					Aadd(aRetorno, {aCodWO[nCont], "", STR0042, "06"}) // "WO já cancelado."
				Else
					// Realiza o cancelamento do WO
					If JaCancWO(aCodWO[nCont], aObs) > 0 // Sucesso
						Aadd(aRetorno, {aCodWO[nCont], NUF->NUF_SITUAC, "", ""})
					Else
						Aadd(aRetorno, {aCodWO[nCont], "", STR0022, "07"}) // "Problema para cancelar o WO"
					EndIf
				EndIf
			Else
				Aadd(aRetorno, {aCodWO[nCont], "", STR0043, "05"}) // "WO não localizado."
			EndIf
		Next nCont

		RestArea(aAreaNUF)
	EndIf

	RestArea(aAreaNXV)
	RestArea(aArea)

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} JA146Tracker()
Executa a função de Tracker Contábil CTBC662().

@author Reginaldo Borges
@since  01/04/2022
/*/
//-------------------------------------------------------------------
Static Function JA146Tracker(oModel)
Local aAreas    := {NWZ->(GetArea()), GetArea()}
Local oModelNWZ := oModel:GetModel("NWZDETAIL")

	CTBC662("NWZ", oModelNWZ:GetDataId())
	AEval(aAreas, {|aArea| RestArea(aArea)})

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J146CpoCTB()
Adiciona o campo de Tracker Contábil ao model e à View

@param oStruct, Estrutura na qual será adicionado o campo de anexo
@param cTabela, Tabela da Estrutura
@param cTipo  , Indica se a Estrutura é do Model ("M") ou da View ("V")

@return oStruct, Estrutura da tabela com o novo campo

@author Reginaldo Borges
@since  01/04/2022
/*/
//-------------------------------------------------------------------
Function J146CpoCTB(oStruct, cTabela, cTipo)
Local cCampo := cTabela+'__CTB'

	If cTipo == "M" 
		              // Titulo , Descricao, Campo , Tipo do campo, Tamanho, Decimal, bValid, bWhen, Lista, lObrigat, bInicializador     , é chave, é editável, é virtual
		oStruct:AddField(STR0047, STR0046  , cCampo, 'BT'         , 1      , 0      , Nil   ,      , Nil  , Nil     , {|| "ANALITIC_MDI"},        ,           , .T.      ) // "Tracker", "Tracker Contábil"
	Else
		               // Campo, Ordem, Titulo , Descricao, Help, Tipo do campo,  Picture, PictVar, F3,  When, Folder, Group, Lista Combo, Tam Max Combo, Inic. Browse, Virtual
		oStruct:AddField(cCampo, '00' , STR0047, STR0046  , {}  , 'BT'         , '@BMP'  ,        ,   ,  .F. ,       ,      , {}         ,              ,             , .T.    ) // "Tracker", "Tracker Contábil"
	EndIf

Return oStruct
