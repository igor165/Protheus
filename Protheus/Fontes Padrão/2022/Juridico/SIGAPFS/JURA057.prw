#INCLUDE "JURA057.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA057
Documento padrão E-billing

@author David Gonçalves Fernandes
@since 07/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA057()
Local oBrowse  := Nil

oBrowse := FWMBrowse():New()
oBrowse:SetDescription(STR0007)
oBrowse:SetAlias("NRW")
oBrowse:SetLocate()
JurSetLeg(oBrowse, "NRW")
JurSetBSize(oBrowse)
oBrowse:Activate()

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

@author David Gonçalves Fernandes
@since 07/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA057", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA057", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA057", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA057", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA057", 0, 8, 0, NIL } ) // "Imprimir"
aAdd( aRotina, { STR0032, "VIEWDEF.JURA057", 0, 9, 0, NIL } ) // "Copiar"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Codigos de Sistema E-billing

@author David Gonçalves Fernandes
@since 07/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel     := FWLoadModel( "JURA057" )
Local oStructNRW := FWFormStruct( 2, "NRW" ) // Doc padrão ebilling
Local oStructNRY := FWFormStruct( 2, "NRY" ) // Fase E-Billing

Local oStructNRZ := FWFormStruct( 2, "NRZ" ) // Tarefa E-Billing
Local oStructNRV := FWFormStruct( 2, "NRV" ) // Categoria E-Billing
Local oStructNS2 := FWFormStruct( 2, "NS2" ) // Categoria E-Billing (De-Para)
Local oStructNS0 := FWFormStruct( 2, "NS0" ) // Tipo de Atividade E-Billing
Local oStructNS1 := FWFormStruct( 2, "NS1" ) // Tipo de Atividade E-Billing (De-Para)
Local oStructNS3 := FWFormStruct( 2, "NS3" ) // Tipo de Despesa E-Billing
Local oStructNS4 := FWFormStruct( 2, "NS4" ) // Tipo de Despesa E-Billing (De-Para)

Local oStructNXN := FWFormStruct( 2, "NXN" ) // Tipo de Tabelados E-Billing
Local oStructNXO := FWFormStruct( 2, "NXO" ) // Tipo de Tabelados E-Billing (De-Para)

oStructNRY:RemoveField("NRY_COD")
oStructNRY:RemoveField("NRY_CDOC")
oStructNRV:RemoveField("NRV_COD")
oStructNRV:RemoveField("NRV_CDOC")
oStructNRZ:RemoveField("NRZ_COD")
oStructNRZ:RemoveField("NRZ_CFASE")
oStructNRZ:RemoveField("NRZ_CDOC")
oStructNS0:RemoveField("NS0_COD")
oStructNS0:RemoveField("NS0_CDOC")
oStructNS1:RemoveField("NS1_COD")
oStructNS1:RemoveField("NS1_CDOC")
oStructNS1:RemoveField("NS1_CATIV")
oStructNS2:RemoveField("NS2_COD")
oStructNS2:RemoveField("NS2_CDOC")
oStructNS2:RemoveField("NS2_CCATE")
oStructNS3:RemoveField("NS3_COD")
oStructNS3:RemoveField("NS3_CDOC")
oStructNS4:RemoveField("NS4_COD")
oStructNS4:RemoveField("NS4_CDOC")
oStructNS4:RemoveField("NS4_CDESP")

oStructNXN:RemoveField("NXN_COD")
oStructNXN:RemoveField("NXN_CDOC")
oStructNXO:RemoveField("NXO_COD")
oStructNXO:RemoveField("NXO_CDOC")
oStructNXO:RemoveField("NXO_CSRVTB")

JurSetAgrp( "NRW",, oStructNRW )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA057_NRW", oStructNRW, "NRWMASTER"  )

oView:AddGrid( "JURA057_NRY", oStructNRY, "NRYDETAIL"  )
oView:AddGrid( "JURA057_NRZ", oStructNRZ, "NRZDETAIL"  )
oView:AddGrid( "JURA057_NRV", oStructNRV, "NRVDETAIL"  )
oView:AddGrid( "JURA057_NS2", oStructNS2, "NS2DETAIL"  )
oView:AddGrid( "JURA057_NS0", oStructNS0, "NS0DETAIL"  )
oView:AddGrid( "JURA057_NS1", oStructNS1, "NS1DETAIL"  )
oView:AddGrid( "JURA057_NS3", oStructNS3, "NS3DETAIL"  )
oView:AddGrid( "JURA057_NS4", oStructNS4, "NS4DETAIL"  )

oView:AddGrid( "JURA057_NXN", oStructNXN, "NXNDETAIL"  )
oView:AddGrid( "JURA057_NXO", oStructNXO, "NXODETAIL"  )

oView:CreateHorizontalBox( "FORMFIELD", 20 )
oView:CreateHorizontalBox( "FORFOLDER", 80 )

oView:CreateFolder("FOLDER_01","FORFOLDER")
oView:AddSheet("FOLDER_01", "ABA_01_01", STR0010 )  //"Fase / Tarefa"
oView:AddSheet("FOLDER_01", "ABA_01_02", STR0012 )  //"Tipo de Atividade"
oView:AddSheet("FOLDER_01", "ABA_01_03", STR0011 )  //"Categoria"
oView:AddSheet("FOLDER_01", "ABA_01_04", STR0013 )  //"Tipo de Despesa"
oView:AddSheet("FOLDER_01", "ABA_01_05", STR0025 )  //"Tipo de Serviço Tabelado"

oView:createVerticalBox("NRYGRID", 40,,,"FOLDER_01","ABA_01_01") //Fase
oView:createVerticalBox("NRZGRID", 60,,,"FOLDER_01","ABA_01_01") //Tarefa

oView:createVerticalBox("NS0GRID", 60,,,"FOLDER_01","ABA_01_02") //Tipo de Atividade
oView:createVerticalBox("NS1GRID", 40,,,"FOLDER_01","ABA_01_02") //Tipo de Atividade (De-Para)

oView:createVerticalBox("NRVGRID", 40,,,"FOLDER_01","ABA_01_03") //Categoria
oView:createVerticalBox("NS2GRID", 60,,,"FOLDER_01","ABA_01_03") //Categoria (De-Para)

oView:createVerticalBox("NS3GRID", 40,,,"FOLDER_01","ABA_01_04") //Tipo de Despesa
oView:createVerticalBox("NS4GRID", 60,,,"FOLDER_01","ABA_01_04") //Tipo de Despesa (De-Para)

oView:createVerticalBox("NXNGRID", 40,,,"FOLDER_01","ABA_01_05") //Tipo de Serviço Tabelado
oView:createVerticalBox("NXOGRID", 60,,,"FOLDER_01","ABA_01_05") //Tipo de Serviço Tabelado (De-Para)

oView:SetOwnerView( "JURA057_NRW", "FORMFIELD"  )
oView:SetOwnerView( "JURA057_NRY", "NRYGRID" )

oView:SetOwnerView( "JURA057_NRZ", "NRZGRID" )
oView:SetOwnerView( "JURA057_NRV", "NRVGRID" )
oView:SetOwnerView( "JURA057_NS2", "NS2GRID" )
oView:SetOwnerView( "JURA057_NS0", "NS0GRID" )
oView:SetOwnerView( "JURA057_NS1", "NS1GRID" )
oView:SetOwnerView( "JURA057_NS3", "NS3GRID" )
oView:SetOwnerView( "JURA057_NS4", "NS4GRID" )

oView:SetOwnerView( "JURA057_NXN", "NXNGRID" )
oView:SetOwnerView( "JURA057_NXO", "NXOGRID" )

oView:SetDescription( STR0007 ) // "Codigos de Sistema E-billing"
oView:EnableControlBar( .T. )

oView:EnableTitleView( "JURA057_NRY" )
oView:EnableTitleView( "JURA057_NRZ" )

oView:EnableTitleView( "JURA057_NRV" )
oView:EnableTitleView( "JURA057_NS2" )

oView:EnableTitleView( "JURA057_NS0" )
oView:EnableTitleView( "JURA057_NS1" )

oView:EnableTitleView( "JURA057_NS3" )
oView:EnableTitleView( "JURA057_NS4" )

oView:EnableTitleView( "JURA057_NXN" )
oView:EnableTitleView( "JURA057_NXO" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Codigos de Sistema E-billing

@author David Gonçalves Fernandes
@since 07/05/09
@version 1.0

@obs NRWMASTER - Dados do Codigos de Sistema E-billing
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNRW := FWFormStruct( 1, "NRW" ) //Doc padrão ebilling
Local oStructNRY := FWFormStruct( 1, "NRY" ) // Fase E-Billing
Local oStructNRZ := FWFormStruct( 1, "NRZ" ) // Tarefa E-Billing

Local oStructNRV := FWFormStruct( 1, "NRV" ) // Categoria E-Billing
Local oStructNS2 := FWFormStruct( 1, "NS2" ) // Categoria E-Billing (De-Para)
Local oStructNS0 := FWFormStruct( 1, "NS0" ) // Tipo de Atividade E-Billing
Local oStructNS1 := FWFormStruct( 1, "NS1" ) // Tipo de Atividade E-Billing (De-Para)
Local oStructNS3 := FWFormStruct( 1, "NS3" ) // Tipo de Despesa E-Billing
Local oStructNS4 := FWFormStruct( 1, "NS4" ) // Tipo de Despesa E-Billing (De-Para)

Local oStructNXN := FWFormStruct( 1, "NXN" ) // Tipo de Tabelados E-Billing
Local oStructNXO := FWFormStruct( 1, "NXO" ) // Tipo de Tabelados E-Billing (De-Para)

Local oCommit    := JA057COMMIT():New()

oModel:= MPFormModel():New( "JURA057", /*Pre-Validacao*/, {|oModel| JA057TOK(oModel)}, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NRWMASTER", NIL, oStructNRW, /*Pre-Validacao*/, /*Pos-Validacao*/ )

oModel:AddGrid( "NRYDETAIL", "NRWMASTER" /*cOwner*/, oStructNRY, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
oModel:AddGrid( "NRZDETAIL", "NRYDETAIL" /*cOwner*/, oStructNRZ, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
oModel:AddGrid( "NRVDETAIL", "NRWMASTER" /*cOwner*/, oStructNRV, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
oModel:AddGrid( "NS2DETAIL", "NRVDETAIL" /*cOwner*/, oStructNS2, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
oModel:AddGrid( "NS0DETAIL", "NRWMASTER" /*cOwner*/, oStructNS0, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
oModel:AddGrid( "NS1DETAIL", "NS0DETAIL" /*cOwner*/, oStructNS1, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
oModel:AddGrid( "NS3DETAIL", "NRWMASTER" /*cOwner*/, oStructNS3, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
oModel:AddGrid( "NS4DETAIL", "NS3DETAIL" /*cOwner*/, oStructNS4, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )

oModel:AddGrid( "NXNDETAIL", "NRWMASTER" /*cOwner*/, oStructNXN, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
oModel:AddGrid( "NXODETAIL", "NXNDETAIL" /*cOwner*/, oStructNXO, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )

oModel:SetRelation( "NRYDETAIL", { { "NRY_FILIAL", "xFilial('NRY')" } , { "NRY_CDOC"   , "NRW_COD" } } , NRY->( IndexKey( 1 ) ) )
oModel:SetRelation( "NRZDETAIL", { { "NRZ_FILIAL", "xFilial('NRZ')" } , { "NRZ_CDOC"   , "NRW_COD" } , { "NRZ_CFASE"   , "NRY_COD" } } , NRZ->( IndexKey( 2 ) ) )
oModel:SetRelation( "NRVDETAIL", { { "NRV_FILIAL", "xFilial('NRV')" } , { "NRV_CDOC"   , "NRW_COD" } } , NRV->( IndexKey( 1 ) ) )
oModel:SetRelation( "NS2DETAIL", { { "NS2_FILIAL", "xFilial('NS2')" } , { "NS2_CDOC"   , "NRW_COD" } , { "NS2_CCATE"   , "NRV_COD" } } , NS2->( IndexKey( 3 ) ) )
oModel:SetRelation( "NS0DETAIL", { { "NS0_FILIAL", "xFilial('NS0')" } , { "NS0_CDOC"   , "NRW_COD" } } , NS0->( IndexKey( 1 ) ) )
oModel:SetRelation( "NS1DETAIL", { { "NS1_FILIAL", "xFilial('NS1')" } , { "NS1_CDOC"   , "NRW_COD" } , { "NS1_CATIV"   , "NS0_COD" } } , NS1->( IndexKey( 1 ) ) )
oModel:SetRelation( "NS3DETAIL", { { "NS3_FILIAL", "xFilial('NS3')" } , { "NS3_CDOC"   , "NRW_COD" } } , NS3->( IndexKey( 1 ) ) )
oModel:SetRelation( "NS4DETAIL", { { "NS4_FILIAL", "xFilial('NS4')" } , { "NS4_CDOC"   , "NRW_COD" } , { "NS4_CDESP"   , "NS3_COD" } } , NS4->( IndexKey( 3 ) ) )

oModel:SetRelation( "NXNDETAIL", { { "NXN_FILIAL", "xFilial('NXN')" } , { "NXN_CDOC"   , "NRW_COD" } } , NXN->( IndexKey( 1 ) ) )
oModel:SetRelation( "NXODETAIL", { { "NXO_FILIAL", "xFilial('NXO')" } , { "NXO_CDOC"   , "NRW_COD" } , { "NXO_CSRVTB"  , "NXN_COD" } } , NXO->( IndexKey( 3 ) ) )

oModel:GetModel( "NRYDETAIL" ):SetUniqueLine( { "NRY_CFASE" } )
oModel:GetModel( "NRZDETAIL" ):SetUniqueLine( { "NRZ_CTAREF" } )
oModel:GetModel( "NRVDETAIL" ):SetUniqueLine( { "NRV_CCATE" } )
oModel:GetModel( "NS2DETAIL" ):SetUniqueLine( { "NS2_CCATEJ" } )
oModel:GetModel( "NS0DETAIL" ):SetUniqueLine( { "NS0_CATIV" } )
oModel:GetModel( "NS1DETAIL" ):SetUniqueLine( { "NS1_CATIVJ" } )
oModel:GetModel( "NS3DETAIL" ):SetUniqueLine( { "NS3_CDESP" } )
oModel:GetModel( "NS4DETAIL" ):SetUniqueLine( { "NS4_CDESPJ" } )

oModel:GetModel( "NXNDETAIL" ):SetUniqueLine( { "NXN_CSRVTB" } )
oModel:GetModel( "NXODETAIL" ):SetUniqueLine( { "NXO_CSRVTJ" } )

oModel:SetDescription( STR0008 ) // "Modelo de Dados de Codigos de Sistema E-billing"
oModel:GetModel( "NRWMASTER" ):SetDescription( STR0009 ) // "Dados de Codigos de Sistema E-billing"

oModel:GetModel( "NRYDETAIL" ):SetDescription( STR0014 ) // "Fase E-billing"
oModel:GetModel( "NRZDETAIL" ):SetDescription( STR0015 ) // "Tarefa E-billing"
oModel:GetModel( "NRVDETAIL" ):SetDescription( STR0016 ) // "Categoria E-Billing"
oModel:GetModel( "NS2DETAIL" ):SetDescription( STR0017 ) // "Categorias do Jurídico"
oModel:GetModel( "NS0DETAIL" ):SetDescription( STR0018 ) // "Tipo de Atividade E-Billing"
oModel:GetModel( "NS1DETAIL" ):SetDescription( STR0019 ) // "Tipos de Atividade do Jurídico"
oModel:GetModel( "NS3DETAIL" ):SetDescription( STR0020 ) // "Tipo de Despesa E-Billing"
oModel:GetModel( "NS4DETAIL" ):SetDescription( STR0021 ) // "Tipos de Despesa do Jurídico"

oModel:GetModel( "NXNDETAIL" ):SetDescription( STR0023 ) // "Tipo de Serviço Tabelado E-Billing"
oModel:GetModel( "NXODETAIL" ):SetDescription( STR0024 ) // "Tipos de Serviço Tabelado do Jurídico"

oModel:GetModel( "NRYDETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NRZDETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NRVDETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NS2DETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NS0DETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NS1DETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NS3DETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NS4DETAIL" ):SetDelAllLine( .T. )

oModel:GetModel( "NXNDETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NXODETAIL" ):SetDelAllLine( .T. )

oModel:SetOptional( "NRYDETAIL" , .T. )
oModel:SetOptional( "NRZDETAIL" , .T. )

oModel:SetOptional( "NRVDETAIL" , .T. )
oModel:SetOptional( "NS2DETAIL" , .T. )

oModel:SetOptional( "NS0DETAIL" , .T. )
oModel:SetOptional( "NS1DETAIL" , .T. )

oModel:SetOptional( "NS3DETAIL" , .T. )
oModel:SetOptional( "NS4DETAIL" , .T. )

oModel:SetOptional( "NXNDETAIL" , .T. )
oModel:SetOptional( "NXODETAIL" , .T. )

oModel:InstallEvent("JA057COMMIT", /*cOwner*/, oCommit)

JurSetRules( oModel, "NRWMASTER",, 'NRW' )
JurSetRules( oModel, "NRYDETAIL",, 'NRY' )
JurSetRules( oModel, "NRZDETAIL",, 'NRZ' )
JurSetRules( oModel, "NRVDETAIL",, 'NRV' )
JurSetRules( oModel, "NS2DETAIL",, 'NS2' )
JurSetRules( oModel, "NS0DETAIL",, 'NS0' )
JurSetRules( oModel, "NS1DETAIL",, 'NS1' )
JurSetRules( oModel, "NS3DETAIL",, 'NS3' )
JurSetRules( oModel, "NS4DETAIL",, 'NS4' )

JurSetRules( oModel, "NXNDETAIL",, 'NS3' )
JurSetRules( oModel, "NXODETAIL",, 'NS4' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA057CHAV
Valida se o campo editado já existe em outro registro, do mesmo tipo,
para o mesmo documento.

@param  cCampo,  Campo que está sendo editado, para chamada pelo dicionário
@return lRet,    Indica se a validação foi bem sucedida ou não
@sample JA057CHAV('NS1_CATIVJ')

@author David Gonçalves Fernandes
@since 03/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA057CHAV(cCampo)
	Local aArea       := GetArea()
	Local lRet        := .T.
	Local oModel      := FwModelActive()
	Local nPos        := 0
	Local nI          := 0
	Local oGrid1      := Nil
	Local oGrid2      := Nil
	Local nQtdLine    := 0
	Local nQtdLine2   := 0
	Local nLinha      := 0
	Local nGrid1Ln    := 0
	Local nGrid2Ln    := 0
	Local cTabela     := ''
	Local cValor      := ''
	Local lCodTarVaz  := .F.

	Default cCampo    := ''

	If cCampo == "NRZ_CTAREF"
		oGrid1  := oModel:GetModel("NRYDETAIL") //Fase
		oGrid2  := oModel:GetModel("NRZDETAIL") //Tarefa
	ElseIf cCampo == "NS1_CATIVJ" .Or. cCampo == "NS0_CFASE" .Or. cCampo == "NS0_CTAREF"
		oGrid1  := oModel:GetModel("NS0DETAIL") //Atividade
		oGrid2  := oModel:GetModel("NS1DETAIL") //Atividade (de-para)
	ElseIf cCampo == "NS2_CCATEJ"
		oGrid1 := oModel:GetModel("NRVDETAIL")  //Categoria
		oGrid2 := oModel:GetModel("NS2DETAIL")  //Categoria (de-para)
	ElseIf cCampo == "NXO_CSRVTJ"
		oGrid1 := oModel:GetModel('NXNDETAIL')  //Serviços tabelado
		oGrid2 := oModel:GetModel('NXODETAIL')  //Serviços tabelado (de-para)
	ElseIf cCampo == "NS4_CDESPJ"
		oGrid1 := oModel:GetModel("NS3DETAIL")  //Despesa
		oGrid2 := oModel:GetModel("NS4DETAIL")  //Despesa (de-para)
	Else
		cCampo := ''
	EndIf

	If !Empty(cCampo)
		cTabela := SUBSTR(cCampo, 1, 3)
		cValor  := FWFldGet(cCampo)
	EndIf

	nGrid1Ln := oGrid1:GetLine()
	nGrid2Ln := oGrid2:GetLine()

	If lRet .And. cCampo <> ''

		If cTabela <> 'NS0'
			nQtdLine := oGrid1:GetQtdLine()
			For nLinha := 1 To nQtdLine
				oGrid1:GoLine(nLinha)

				nQtdLine2 := oGrid2:GetQtdLine()
				For nI := 1 To nQtdLine2
					If !oGrid2:IsEmpty(nI) .And. (oGrid2:GetValue(cCampo, nI) == cValor) .And. nLinha <> nGrid1Ln
						nPos := nI
						Exit
					EndIf
				Next

				If nPos > 0
					lRet := .F.
					Exit
				EndIf
			Next
		EndIf

	EndIf

	oGrid1:GoLine(nGrid1Ln)
	oGrid2:GoLine(nGrid2Ln)

	If lRet .And. cTabela == "NRZ" .And. Empty(oGrid1:GetValue("NRY_CFASE"))
		lCodTarVaz := .T.
		lRet := .F.
	EndIf

	If !lRet
		If lCodTarVaz
			JurMsgErro( STR0026 + " " + STR0014 ) // "É necessário preencher as informações de" ## "Fase E-Billing"
		Else
			JurMsgErro( STR0022 ) //"Já existe registo com este código"
		EndIf
	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA057TOK
Pós-validação do modelo de dados

@Param  oModel  Campo que está sendo editado, para chamada pelo dicionário
@return lRet    Indica se a velidação foi bem sucedida

@author Luciano Pereira dos Santos
@since 12/08/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA057TOK(oModel)
	Local lRet       := .T.
	Local aModel     := {{"NRY","NRZ"}, {"NS0",""}, {"NRV","NS2"}, {"NS3","NS4"}, {"NXN","NXO"}}
	Local cMsg       := ""
	Local oGrid1     := Nil
	Local oGrid2     := Nil
	Local nGrid1Ln   := 0
	Local nI         := 0
	Local nY         := 0
	Local lAllGrdNil := .T.

	If oModel:GetOperation() != MODEL_OPERATION_DELETE
		For nI := 1 To Len(aModel)  //Percorre os modelos Pai/Filho
			oGrid1 := oModel:GetModel(aModel[nI][1] + "DETAIL")
			If !oGrid1:IsEmpty()
				lAllGrdNil := .F.
				nGrid1Ln := oGrid1:GetLine()

				// Validações executadas no Grid Pai
				If aModel[nI][1] $ "NRY|NS0|NRV" // Validação para obrigar a preencher Fase/Atividade/Categoria
					Do Case
						Case aModel[nI][1] == "NRY" .And. J057DelGrd(oGrid1)
							cMsg += STR0026 + STR0014 // "É necessário preencher as informações de " ## "Fase E-billing"
							lRet := .F.
						Case aModel[nI][1] == "NS0" .And. J057DelGrd(oGrid1)
							cMsg += STR0026 + STR0018 // "É necessário preencher as informações de " ## "Tipo de Atividade E-Billing"
							lRet := .F.
						Case aModel[nI][1] == "NRV" .And. J057DelGrd(oGrid1)
							cMsg += STR0026 + STR0016 // "É necessário preencher as informações de " ## "Categoria E-Billing"
							lRet := .F.
					EndCase
				EndIf
				
				If !lRet
					Exit
				EndIf

				For nY := 1 to oGrid1:GetQtdLine()  //Percorre os pais
					oGrid1:GoLine(nY)
	
					If lRet .And. aModel[nI][1] == "NS0"
						// Valida se a fase e tarefa da NS0 ainda são válidas.
						If !JA057VALID()
							lRet := .F.
							Exit
						EndIf
					EndIf

					If !oGrid1:IsDeleted() .And. !Empty(aModel[nI][2])
						oGrid2 := oModel:GetModel(aModel[nI][2]+"DETAIL")
						If oGrid2:IsEmpty() .Or. J057DelGrd(oGrid2)
							Do Case
								Case aModel[nI][2] == "NRZ"
									cMsg += STR0014+","+STR0027+Alltrim(str(nY))+":"+CRLF+CRLF +STR0026+STR0015  //#"Fase E-billing" ##" linha " ###"É necessário preencher as informções de "  ###"Tarefa E-billing"
								Case aModel[nI][2] == "NS2"
									cMsg += STR0016+","+STR0027+Alltrim(str(nY))+":"+CRLF+CRLF +STR0026+STR0017  //#"Categoria E-Billing" ##" linha " ###"É necessário preencher as informções de " #### "Categorias do Jurídico"
								Case aModel[nI][2] == "NS4"
									cMsg += STR0020+","+STR0027+Alltrim(str(nY))+":"+CRLF+CRLF +STR0026+STR0021  //#"Tipo de Despesa E-Billing" ##" linha " ###"É necessário preencher as informções de " #### "Tipos de Despesa do Jurídico"
								Case aModel[nI][2] == "NXO"
									cMsg += STR0023+","+STR0027+Alltrim(str(nY))+":"+CRLF+CRLF +STR0026+STR0024  //#"Tipo de Serviço Tabelado E-Billing" ##" linha " ###"É necessário preencher as informções de " #### "Tipos de Serviço Tabelado do Jurídico"
							EndCase
							lRet := .F.
							Exit
						EndIf
					EndIf
				Next nY
				oGrid1:GoLine(nGrid1Ln)
			EndIf

			If !lRet
				Exit
			EndIf
		Next nI

		If !Empty(cMsg)
			JurMsgErro( cMsg )
		EndIf

		If lRet .And. lAllGrdNil  // validação para não permitir a inclusão apenas do cabeçalho dos Documentos Padrões Ebilling.
			JurMsgErro( STR0028 ) // 'O preenchimento das pastas do "Documento Padrão E-Billing" é obrigatório.'
			lRet := .F.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J057DelGrd()
Valida se todas as linhas do grid estao deletadas

@Param  oGrid	Grid a ser verificado
@return lRet 	.T. se todas as linhas do grid estao deletadas

@author Luciano Pereira dos Santos
@since 12/08/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J057DelGrd(oGrid)
	Local lRet     := .T.
	Local nGridLn  := 0
	Local nI       := 0

	nGridLn := oGrid:nLine

	For nI := 1 to oGrid:GetQtdLine()
		If !oGrid:IsDeleted(nI)
	    	lRet := .F.
	    	Exit
	    EndIf
	Next nI

	oGrid:GoLine(nGridLn)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J057Pesc
Filtra os registros da pesquisa de categoria juridica (NRN1), para que apresente apenas os registros validos.

@param 	oGrid1   	Grid NRV
@param 	oGrid2 		Grid NS2

@author Wellington Coelho
@since 21/08/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J057Pesc()
	Local oModel    := FwModelActive()
	Local oGrid1    := oModel:GetModel("NRVDETAIL")
	Local oGrid2    := oModel:GetModel("NS2DETAIL")
	Local nQtdLine1 := oGrid1:GetQtdLine()
	Local nI        := 0
	Local nJ        := 0
	Local nCont     := 0
	Local cRet      := "@#@#"
	Local nGrid1Line := oGrid1:GetLine()
	Local nGrid2Line := oGrid2:GetLine()

	For nI := 1 To nQtdLine1
		oGrid1:GoLine(nI)
		For nJ := 1 To oGrid2:GetQtdLine()
			If !oGrid2:IsDeleted(nJ)
				If nCont == 0
					cRet := "@#NRN->NRN_COD <> '" + oGrid2:Getvalue("NS2_CCATEJ",nJ) + "'"
					nCont++
				Else
					cRet += " .AND. NRN->NRN_COD <> '" + oGrid2:Getvalue("NS2_CCATEJ",nJ) + "'"
				EndIf
			EndIf
		Next
	Next

	If nCont > 0
		cRet += "@#"
	EndIf

	oGrid1:GoLine(nGrid1Line)
	oGrid2:GoLine(nGrid2Line)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J057PescA
Filtra os registros da pesquisa de atividade juridica (NRC1), para que
apresente apenas os registros validos.

@param oGrid1   Grid NS0
@param oGrid2   Grid NS1

@return         Retorna os tipos de atividades que ainda não foram utilizadas

@author Nivia Ferreira
@since 22/11/2018
/*/
//-------------------------------------------------------------------
Function J057PescA()
	Local oModel     := FwModelActive()
	Local oGrid1     := oModel:GetModel("NS0DETAIL")
	Local oGrid2     := oModel:GetModel("NS1DETAIL")
	Local nQtdLine1  := oGrid1:GetQtdLine()
	Local nI         := 0
	Local nJ         := 0
	Local nCont      := 0
	Local cRet       := "@#@#"
	Local nGrid1Line := oGrid1:GetLine()
	Local nGrid2Line := oGrid2:GetLine()

	For nI := 1 To nQtdLine1
		oGrid1:GoLine(nI)
		For nJ := 1 To oGrid2:GetQtdLine()
			If !oGrid2:IsDeleted(nJ)
				If nCont == 0
					cRet := "@# NRC->NRC_COD <> '" + oGrid2:GetValue("NS1_CATIVJ", nJ) + "'"
					nCont++
				Else
					cRet += " .AND. NRC->NRC_COD <> '" + oGrid2:Getvalue("NS1_CATIVJ",nJ) + "'"
				EndIf
			EndIf
		Next
	Next

	If nCont > 0
		cRet += "@#"
	EndIf

	oGrid1:GoLine(nGrid1Line)
	oGrid2:GoLine(nGrid2Line)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J057PescB
Filtra os registros da pesquisa de categoria juridica (NRH3 e NRD1),
para que apresente apenas os registros validos.

@param 	cConsulta  Consulta que chamou a função (NRH3 ou NRD1).

@author Julio de Paula Paz
@since 13/10/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J057PescB(cConsulta)
	Local oModel       := FwModelActive()
	Local oGridNS3     := oModel:GetModel("NS3DETAIL")
	Local oGridNS4     := oModel:GetModel("NS4DETAIL")
	Local oGridNXO     := oModel:GetModel("NXODETAIL")
	Local oGridNXN     := oModel:GetModel("NXNDETAIL")
	Local nQtdLinNS3   := oGridNS3:GetQtdLine()
	Local nQtdLinNXN   := oGridNXN:GetQtdLine()
	Local nI           := 0
	Local nJ           := 0
	Local nCont        := 0
	Local cRet         := "@#@#"
	Local nGrid1Line   := 0
	Local nGrid2Line   := 0

	Begin Sequence
		If cConsulta == "NRH3"
			nGrid1Line := oGridNS3:GetLine()
			nGrid2Line := oGridNS4:GetLine()
			For nI := 1 To nQtdLinNS3
				oGridNS3:GoLine(nI)
				For nJ := 1 To oGridNS4:GetQtdLine()
					oGridNS4:GoLine(nJ)
					If !oGridNS4:IsDeleted()
						If nCont == 0
							cRet := "@#NRH->NRH_COD <> '" + oGridNS4:Getvalue("NS4_CDESPJ") + "' "
							nCont++
						Else
							cRet += " .AND. NRH->NRH_COD <> '" + oGridNS4:Getvalue("NS4_CDESPJ") + "' "
						EndIf
					EndIf
				Next
			Next
			oGridNS3:GoLine(nGrid1Line)
			oGridNS4:GoLine(nGrid2Line)
		ElseIf cConsulta == "NRD1"
			nGrid1Line := oGridNXN:GetLine()
			nGrid2Line := oGridNXO:GetLine()
			For nI := 1 To nQtdLinNXN
				oGridNXN:GoLine(nI)
				For nJ := 1 To oGridNXO:GetQtdLine()
					oGridNXO:GoLine(nJ)
					If !oGridNXO:IsDeleted()
						If nCont == 0
							cRet := "@#NRD->NRD_COD <> '" + oGridNXO:Getvalue("NXO_CSRVTJ") + "' "
							nCont++
						Else
							cRet += " .AND. NRD->NRD_COD <> '" + oGridNXO:Getvalue("NXO_CSRVTJ") + "' "
						EndIf
					EndIf
				Next
			Next
			oGridNXN:GoLine(nGrid1Line)
			oGridNXO:GoLine(nGrid2Line)
		EndIf

		If nCont > 0
			cRet += "@#"
		EndIf

	End Sequence

Return cRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA057COMMIT
Classe interna implementando o FWModelEvent, para execução de função
durante o commit.

@author Cristina Cintra Santos
@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA057COMMIT FROM FWModelEvent
    Method New()
    Method InTTS()
End Class

Method New() Class JA057COMMIT
Return

Method InTTS(oSubModel, cModelId) Class JA057COMMIT
	JFILASINC(oSubModel:GetModel(), "NRW", "NRWMASTER", "NRW_COD")
Return

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA057VALID
Validação da fase/tarefa na Atividade (NS0) posicionada

@return lRet, Se é válido a fase e tarefa na NS0 posicionada

@author Bruno Ritter
@since 28/11/2018
/*/
//-------------------------------------------------------------------
Function JA057VALID()
	Local lRet      := .T.
	Local oModel    := FwModelActive()
	Local oGridNRY  := oModel:GetModel("NRYDETAIL")
	Local oGridNRZ  := oModel:GetModel("NRZDETAIL")
	Local cDoc      := AllTrim(oModel:GetValue("NRWMASTER", "NRW_COD"))
	Local cCodAtiv  := AllTrim(oModel:GetValue("NS0DETAIL", "NS0_CATIV"))
	Local cFase     := ""
	Local cTaref    := ""
	Local nLinhaNRY := oGridNRY:GetLine()
	Local nLinhaNRZ := oGridNRZ:GetLine()

	If NS0->(ColumnPos("NS0_CFASE")) > 0 .And. NS0->(ColumnPos("NS0_CTAREF")) > 0 // Proteção
		cFase  := oModel:GetValue("NS0DETAIL", "NS0_CFASE")
		cTaref := oModel:GetValue("NS0DETAIL", "NS0_CTAREF")
	EndIf

	If !Empty(cFase)
		If oGridNRY:SeekLine({{"NRY_CFASE",cFase}})
			If !Empty(cTaref) .And. !oGridNRZ:SeekLine({{"NRZ_CTAREF",cTaref}})
				lRet := .F.
				JurMsgErro(I18n(STR0029, {AllTrim(cTaref), AllTrim(cFase)}), ,; // "Não existe Tarefa válida com o código '#1' para a Fase '#2'."
				           I18n(STR0030, {cDoc, cCodAtiv})) // "Verifique se o registro existe no Documento '#1', ou altere o Tipo de Ativida '#2'."
			EndIf
		Else
			lRet := .F.
			JurMsgErro(I18n(STR0031, {AllTrim(cFase)}), ,; // "Não existe Fase válida com o código '#1'."
			           I18n(STR0030, {cDoc, cCodAtiv})) // "Verifique se o registro existe no Documento '#1', ou altere o Tipo de Ativida '#2'."
		EndIf
	EndIf

	oGridNRY:GoLine(nLinhaNRY)
	oGridNRZ:GoLine(nLinhaNRZ)

Return(lRet)

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA057DTARE
Validação da fase/tarefa

@param cDoc    codigo do documento
@param cFase   codigo da fase
@param cTaref  codigo da tarefa

@return cRet   descrição da tarefa

@author Nivia Ferreira
@since 20/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA057DTARE(cDoc, cFase, cTaref)
Local cRet := ''

DbSelectArea("NRY")
NRY->(dbSetOrder(5)) //NRY_FILIAL+NRY_FASE+NRY_CDOC
If NRY->( dbSeek( xFilial('NRY') + cFase + cDoc))

	DbSelectArea("NRZ")
	NRZ->(dbSetOrder(2)) //NRZ_FILIAL+NRZ_CDOC+NRZ_CFASE+NRZ_CTAREF
	If NRZ->( dbSeek( xFilial('NRZ') + cDoc + NRY->NRY_COD + cTaref))
		cRet := NRZ->NRZ_DESC
	EndIf
EndIf

Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} J057PescT
Filtra os registros da pesquisa de atividade juridica (NRZNS0), para que apresente apenas os registros validos.

@return cFiltro, filtro da consulta

@obs Usada no filtro da consulta padrão NRZNS0

@author Bruno Ritter
@since 22/11/2018
/*/
//-------------------------------------------------------------------
Function J057PescT()
	Local oModel    := FwModelActive()
	Local oGridNS0  := oModel:GetModel("NS0DETAIL")
	Local oModelNRW := oModel:GetModel("NRWMASTER")
	Local cFase     := ""
	Local cDoc      := oModelNRW:GetValue("NRW_COD")
	Local cFiltro   := ""
	Local cCodFase  := ""

	If NS0->(ColumnPos("NS0_CFASE")) > 0 // Proteção
		cFase := oGridNS0:GetValue("NS0_CFASE")
	EndIf

	cCodFase := JurGetDados("NRY", 5, xFilial("NRY")+ cFase + cDoc, "NRY_COD") // NRY_FILIAL + NRY_CFASE + NRY_CDOC
	cFiltro  := "@#NRZ->NRZ_CDOC == '" + cDoc + "' .AND. NRZ->NRZ_CFASE == '" + cCodFase + "'@#"

Return cFiltro

//-------------------------------------------------------------------
/*/ { Protheus.doc } J057DTaref
Função para preencher a descrição da tarefa(NRZ) no tipo de atividade (NS0)

@return cRet, Descrição da tarefa

@obs Usada em gatilho SX7

@author Bruno Ritter
@since 30/11/2018
/*/
//-------------------------------------------------------------------
Function J057DTaref()
	Local cRet      := ""
	Local oModel    := FwModelActive()
	Local oGridNRY  := oModel:GetModel("NRYDETAIL")
	Local oGridNRZ  := oModel:GetModel("NRZDETAIL")
	Local cFase     := ""
	Local cTaref    := ""
	Local nLinhaNRY := oGridNRY:GetLine()
	Local nLinhaNRZ := oGridNRZ:GetLine()

	If NS0->(ColumnPos("NS0_CFASE")) > 0 .And. NS0->(ColumnPos("NS0_CTAREF")) > 0 // Proteção
		cFase  := oModel:GetValue("NS0DETAIL", "NS0_CFASE")
		cTaref := oModel:GetValue("NS0DETAIL", "NS0_CTAREF")
	EndIf

	If !Empty(cFase) .And. !Empty(cTaref)
		If oGridNRY:SeekLine({{"NRY_CFASE", cFase}}) .And. oGridNRZ:SeekLine({{"NRZ_CTAREF", cTaref}})

			cRet := oGridNRZ:GetValue("NRZ_DESC")
		EndIf
	EndIf

	oGridNRY:GoLine(nLinhaNRY)
	oGridNRZ:GoLine(nLinhaNRZ)

Return cRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } J057DFase
Função para preencher a descrição da fase(NRY) no tipo de atividade (NS0)

@return cRet, Descrição da fase

@obs Usada em gatilho SX7

@author Bruno Ritter
@since 30/11/2018
/*/
//-------------------------------------------------------------------
Function J057DFase()
	Local cRet      := ""
	Local oModel    := FwModelActive()
	Local oGridNRY  := oModel:GetModel("NRYDETAIL")
	Local cFase     := ""
	Local nLinhaNRY := oGridNRY:GetLine()

	If NS0->(ColumnPos("NS0_CFASE")) > 0 // Proteção
		cFase := oModel:GetValue("NS0DETAIL", "NS0_CFASE")
	EndIf

	If !Empty(cFase) .And. oGridNRY:SeekLine({{"NRY_CFASE", cFase}})
		cRet := oGridNRY:GetValue("NRY_DESC")
	EndIf

	oGridNRY:GoLine(nLinhaNRY)

Return cRet
