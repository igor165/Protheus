#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIA070.CH"

Function VEIA070()
	Local oBrowse
	// Instanciamento da Classe de Browse
	oBrowse := BrowseDef()
	oBrowse:Activate()
Return

Static Function BrowseDef()
	Local oBrowse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VV1')
	oBrowse:SetDescription(STR0001) // 'Cadastro Veículo'
Return oBrowse

Static Function ModelDef()

	Local oStruVV1 := FWFormStruct( 1, 'VV1' )
	Local oModel
	Local bAuxRelacao
	Local bAuxWhen
	Local aCpoNaoAlt := VA0700011_CamposNaoAlteraveis() // Campos que nao podem ser alterados no VV1
	Local nCntFor    := 0

	FWMemoVirtual( oStruVV1,{ { 'VV1_OBSMEM' , 'VV1_OBSERV' } } ) 

	bAuxRelacao := FWBuildFeature( STRUCT_FEATURE_INIPAD , 'Posicione("VE1",1,xFilial("VE1")+VV1->VV1_CODMAR,"VE1_DESMAR")' )
	oStruVV1:SetProperty('VV1_DESMAR', MODEL_FIELD_INIT, bAuxRelacao )
	bAuxRelacao := FWBuildFeature( STRUCT_FEATURE_INIPAD , 'Posicione("VV2",1,xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI,"VV2_DESMOD")' )
	oStruVV1:SetProperty('VV1_DESMOD', MODEL_FIELD_INIT, bAuxRelacao )
	bAuxRelacao := FWBuildFeature( STRUCT_FEATURE_INIPAD , 'Posicione("VV7",1,xFilial("VV7")+VV1->VV1_CARROC,"VV7_DESCRI")' )
	oStruVV1:SetProperty('VV1_DESCAR', MODEL_FIELD_INIT, bAuxRelacao )
	bAuxRelacao := FWBuildFeature( STRUCT_FEATURE_INIPAD , 'Posicione("VVC",1,XFILIAL("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORFXA,"VVC_DESCRI")' )
	oStruVV1:SetProperty('VV1_DESCFX', MODEL_FIELD_INIT, bAuxRelacao )
	//bAuxRelacao := FWBuildFeature( STRUCT_FEATURE_INIPAD , 'Posicione("VF0",1,XFILIAL("VF0")+VV1->VV1_CODMAR+VV1->VV1_PLAREV,"VF0_DESPLA")' )
	//oStruVV1:SetProperty('VV1_DESPLA', MODEL_FIELD_INIT, bAuxRelacao )
	bAuxRelacao := FWBuildFeature( STRUCT_FEATURE_INIPAD , 'Posicione("SA1",1,xFilial("SA1")+VV1->VV1_PROATU+VV1->VV1_LJPATU,"A1_NREDUZ")' )
	oStruVV1:SetProperty('VV1_NOMPRO', MODEL_FIELD_INIT, bAuxRelacao )
	bAuxRelacao := FWBuildFeature( STRUCT_FEATURE_INIPAD , 'Posicione("VVN",1,xFilial("VVN")+VV1->VV1_TPGREX+VV1->VV1_CODMAR+VV1->VV1_CODGAR,"VVN_DESCRI")' )
	oStruVV1:SetProperty('VV1_DESCRI', MODEL_FIELD_INIT, bAuxRelacao )

	For nCntFor := 1 to len(aCpoNaoAlt)
		bAuxWhen := FWBuildFeature( STRUCT_FEATURE_WHEN , 'VA0700021_WHEN("' + aCpoNaoAlt[nCntFor] + '")' )
		oStruVV1:SetProperty( aCpoNaoAlt[nCntFor] , MODEL_FIELD_WHEN , bAuxWhen )
	Next

	aAuxTrigger := FwStruTrigger("VV1_PRCADA","VV1_PRUSUA","RetCodUsr()",.F.,"",,,"FWFldGet('VV1_PRCADA')=='1' .AND. Empty(FWFldGet('VV1_PRUSUA'))")
	oStruVV1:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])

	aAuxTrigger := FwStruTrigger("VV1_PRUSUA","VV1_PRNUSA","Left(UsrRetName(FWFldGet('VV1_PRUSUA')),25)",.F.)
	oStruVV1:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])

	// A rotina VEIA140 cria um veiculo com o minimo de informacao 
	If IsInCallStack("VEIA140") .or. IsInCallStack("VEIA162")
		oStruVV1:SetProperty( '*' , MODEL_FIELD_OBRIGAT, .f.)
		oStruVV1:SetProperty( 'VV1_CHASSI' , MODEL_FIELD_WHEN, {|| .t. })
	EndIf

	oModel := MPFormModel():New('VEIA070' )
	oModel:AddFields( 'MODEL_VV1', /*cOwner*/, oStruVV1)
	oModel:SetDescription( STR0002 ) // 'Modelo de dados de Veículo'
	oModel:GetModel( 'MODEL_VV1' ):SetDescription( STR0003 ) // 'Dados do Veículo'

	oModel:SetPrimaryKey( { "VV1_FILIAL", "VV1_CHAINT" } )

	oModel:InstallEvent("DEF",, VEIA070EVDEF():New()) // Eventos de PE - Compatibilidade com o VEIXA010
	oModel:InstallEvent("PE",, VEIA070EVPE():New()) // Eventos de PE - Compatibilidade com o VEIXA010
Return oModel

Static Function ViewDef()
	Local oModel := FWLoadModel( 'VEIA070' )
	Local oStruVV1 := FWFormStruct( 2, 'VV1' )
	Local oView
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_VV1', oStruVV1, 'MODEL_VV1' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_VV1', 'TELA' )
Return oView

Static Function MenuDef()
Return FWMVCMenu("VEIA070")

/*/{Protheus.doc} VA0700011_CamposNaoAlteraveis
Retorna Vetor com os Campos que NAO podem ser Alterados, sera utilizado para montar o WHEN dos campos

@author Andre Luis Almeida
@since 23/04/2020
@version undefined
@type function
/*/
Static Function VA0700011_CamposNaoAlteraveis()
Local aCpoPossiv := FWFormStruct(3,"VV1") // Todos os campos possiveis da Tabela VV1
Local aCpoNaoAlt := {} // Vetor retorno com os Campos que NAO podem ser Alterados
Local cCpoNaoAlt := "" // Campos que NAO podem ser Alterados
Local nCntFor    := 0
//
cCpoNaoAlt += "VV1_CODMAR/VV1_CHASSI/VV1_MODVEI/VV1_SEGMOD/VV1_COMMOD/"
cCpoNaoAlt += "VV1_FABMOD/VV1_CARROC/VV1_CORVEI/VV1_CORFXA/VV1_COMVEI/"
cCpoNaoAlt += "VV1_NUMDIF/VV1_TIPDIF/VV1_RENAVA/VV1_PESBRU/VV1_RELDIF/"
cCpoNaoAlt += "VV1_CAMBIO/VV1_CAPTRA/VV1_SERMOT/VV1_TIPCAB/VV1_QTDCIL/"
cCpoNaoAlt += "VV1_TIPCAM/VV1_NUMLOT/VV1_CILMOT/VV1_TIPMOT/VV1_QTDEIX/"
cCpoNaoAlt += "VV1_POTMOT/VV1_DISEIX/VV1_PRIREV/VV1_PORTAS/VV1_CM3/"
cCpoNaoAlt += "VV1_PESLIQ/VV1_3EIXO/VV1_TANQUE/VV1_PRCADA/VV1_FABMES/"
cCpoNaoAlt += "VV1_FABANO/VV1_DISCAT/VV1_SIMRAV/VV1_LCVM/VV1_NUMCMO/"
cCpoNaoAlt += "VV1_CAPCAR/VV1_NUMMOT/VV1_PROVEI/VV1_ESTVEI/VV1_PLAVEI/"
//
For nCntFor := 1 to len(aCpoPossiv[1])
	If !aCpoPossiv[1,nCntFor,14] .and. aCpoPossiv[1,nCntFor,3]+"/" $ cCpoNaoAlt // Somente campos que existem
		aAdd(aCpoNaoAlt,aCpoPossiv[1,nCntFor,3])
	EndIf
Next
//
Return aCpoNaoAlt

/*/{Protheus.doc} VA0700021_WHEN
Executa o WHEN dos campos validando se o Veiculo 
possui movimentação de Entrada do Tipo Produção 
ou qualquer movimentação de Saida Válida

@author Andre Luis Almeida
@since 23/04/2020
@version undefined
@type function
/*/
Function VA0700021_WHEN(cCampo)
Local aArea    := GetArea()
Local cChassi  := ""
Local lRet     := .T.
Local oModel   := FWModelActive()
Local oModelVV1:= oModel:GetModel('MODEL_VV1')
Local nOper    := oModel:GetOperation()
Local cWhenCpo := GeTSX3Cache(cCampo,"X3_WHEN") // utilizado para manter o WHEN
Local cQuery   := ""
//
If nOper == MODEL_OPERATION_UPDATE
	cChassi := oModelVV1:GetValue('VV1_CHASSI')
	If !Empty(cChassi)
		//
		cQuery += "SELECT VVF.R_E_C_N_O_ AS REC"
		cQuery += "  FROM "+RetSqlName("VVG")+" VVG"
		cQuery += "  JOIN "+RetSqlName("VVF")+" VVF ON ( VVG.VVG_FILIAL=VVF.VVF_FILIAL AND VVG.VVG_TRACPA=VVF.VVF_TRACPA AND VVF.D_E_L_E_T_=' ' ) "
		cQuery += " WHERE VVG.VVG_CHASSI='"+cChassi+"'"
		cQuery += "   AND VVF.VVF_TIPDOC = '3'" // Existe uma Entrada com o TIPDOC = '3' - Tipo Produção
		cQuery += "   AND VVG.D_E_L_E_T_ = ' '"
		//
		cQuery += " UNION "
		//
		cQuery += "SELECT VV0.R_E_C_N_O_ AS REC"
		cQuery += "  FROM "+RetSqlName("VVA")+" VVA"
		cQuery += "  JOIN "+RetSqlName("VV0")+" VV0 ON ( VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND VV0.D_E_L_E_T_=' ' ) "
		cQuery += " WHERE VVA.VVA_CHASSI='"+cChassi+"'"
		cQuery += "   AND VV0.VV0_SITNFI='1'" // Existe uma Saida com SITNFI = '1' - Valida
		cQuery += "   AND VVA.D_E_L_E_T_=' '"
		//
		If FM_SQL(cQuery) > 0 // Possui registro que impede alteracoes nos campos
			cWhenCpo := ".F." // Não deixar alterar o campo
		EndIf
		//
	EndIf
EndIf
//
If !Empty(cWhenCpo)
	lRet := &(cWhenCpo)
EndIf
//
RestArea(aArea)
Return lRet

