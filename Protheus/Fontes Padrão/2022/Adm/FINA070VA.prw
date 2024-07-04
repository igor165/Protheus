#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'FWEDITPANEL.ch'
#Include 'FINA070VA.ch'

Static __lAutoVA := .F.

//-----------------------------------------------------------------------------
/*/{Protheus.doc}ViewDef
Detalhamento dos valores acessórios.
@author Mauricio Pequim Jr
@since  20/08/2015
@version 12
/*/
//-----------------------------------------------------------------------------
Function FINA070VA()
	Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"
	Local nOK := 0
	Local oModelVA := Nil
	Local lFinc040 := FwIsInCallStack("FINC040") .OR. FwIsInCallStack("FC040CON")

	dbSelectArea("SE1")

	//Titulos gerados via integração RM Classis não sofrem alteração dos valores acessórios
	If lFinc040 .Or. (SE1->E1_IDLAN == 1 .And. Alltrim(SE1->E1_ORIGEM) $ Alltrim(GetNewPar("MV_RMORIG","")))
		nOK := FWExecView( STR0003 + " - " + STR0005,"FINA070VA", MODEL_OPERATION_VIEW,/**/,/**/,/**/,,aEnableButtons )	//"Visualizar"
	ElseIf !Type("cOldVA") == 'U' .AND. !Empty(cOldVA)
		oModelVA := FWLoadModel("FINA070VA")
		oModelVA:SetOperation( MODEL_OPERATION_UPDATE )
		oModelVA:Activate()
		oModelVA:LoadXMLData( cOldVA )
		nOK := FWExecView( STR0003 + " - " + STR0001,"FINA070VA", MODEL_OPERATION_UPDATE,/**/,/**/,/**/,,aEnableButtons,/*bCancel*/,/**/,/*cToolBar*/, oModelVA ) //'Valores Acessórios'###'Alteração'
	Else
		nOK := FWExecView( STR0003 + " - " + STR0001,"FINA070VA", MODEL_OPERATION_UPDATE,/**/,/**/,/**/,,aEnableButtons) //'Valores Acessórios'###'Alteração'
	EndIf

	oModelVA := Nil

	Return nOK

	//-----------------------------------------------------------------------------
	/*/{Protheus.doc}ViewDef
	Interface.
	@author Mauricio Pequim Jr
	@since  04/08/2016
	@version 12
	/*/
	//-----------------------------------------------------------------------------
Static Function ViewDef()
	Local oView	 := FWFormView():New()
	Local oModel := FWLoadModel( "FINA070VA" )
	Local oFK7	 := FWFormStruct( 2, 'FK7' )
	Local oSE1	 := FWFormStruct( 2, 'SE1', { |x| ALLTRIM(x) $ 'E1_NUM, E1_PARCELA, E1_PREFIXO, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_EMISSAO, E1_VENCREA, E1_SALDO, E1_VALOR, E1_NATUREZ' } )
	Local oFKD	 := FWFormStruct( 2, 'FKD', { |x| ALLTRIM(x) $ 'FKD_CODIGO, FKD_DESC, FKD_TPVAL,FKD_VALOR,FKD_VLCALC,FKD_VLINFO' } )

	oSE1:AddField("E1_DESCNAT", "10", STR0004, STR0004, {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/) //"Descrição da Natureza"

	oSE1:SetProperty( 'E1_CLIENTE', MVC_VIEW_ORDEM, '06' )
	oSE1:SetProperty( 'E1_LOJA'   , MVC_VIEW_ORDEM, '07' )
	oSE1:SetProperty( 'E1_NOMCLI' , MVC_VIEW_ORDEM, '08' )
	oSE1:SetProperty( 'E1_NATUREZ', MVC_VIEW_ORDEM, '09' )
	oSE1:SetProperty( 'E1_DESCNAT', MVC_VIEW_ORDEM, '10' )

	oSE1:SetNoFolder()

	oFKD:SetProperty( '*'		  , MVC_VIEW_CANCHANGE, .F. )
	oFKD:SetProperty( 'FKD_VLINFO', MVC_VIEW_CANCHANGE, .T. )

	oView:SetModel( oModel )
	oView:AddField( "VIEWSE1", oSE1, "SE1MASTER" )
	oView:AddGrid( "VIEWFKD", oFKD, "FKDDETAIL" )

	oView:SetViewProperty( "VIEWSE1", "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP, 1 } )

	oView:CreateHorizontalBox( 'BOXSE1', 027 )
	oView:CreateHorizontalBox( 'BOXFKD', 073 )

	oView:SetOwnerView( 'VIEWSE1', 'BOXSE1' )
	oView:SetOwnerView( 'VIEWFKD', 'BOXFKD' )

	oView:EnableTitleView( 'VIEWSE1', STR0002 ) //'Contas a Receber'
	oView:EnableTitleView( 'VIEWFKD', STR0003 ) //'Valores Acessórios'
	oView:SetOnlyView( 'VIEWSE1' )

	Return oView

	//-----------------------------------------------------------------------------
	/*/{Protheus.doc}ModelDef
	Modelo de dados.
	@author Mauricio Pequim Jr
	@since  04/08/2016
	@version 12
	/*/
	//-----------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel    := MPFormModel():New( 'FINA070VA',/*Pre*/,/*Pos*/, { |oModel| FN070VAGrv( oModel )} /*Commit*/ )
	Local oSE1      := FWFormStruct( 1, 'SE1' )
	Local oFKD      := FWFormStruct( 1, 'FKD' )
	Local oFK7      := FWFormStruct( 1, 'FK7' )
	Local aAuxFK7   := {}
	Local aAuxFKD   := {}
	Local nTamDNat  := TamSx3("ED_DESCRIC")[1]
	Local bInitDesc := FWBuildFeature( STRUCT_FEATURE_INIPAD, 'IIF( !INCLUI, Posicione("FKC", 1, xFilial("FKC") + FKD->FKD_CODIGO, "FKC_DESC"   ), "" )' )
	Local bInitVal  := FWBuildFeature( STRUCT_FEATURE_INIPAD, 'IIF( !INCLUI, Posicione("FKC", 1, xFilial("FKC") + FKD->FKD_CODIGO, "FKC_TPVAL"  ), "" )' )
	Local bInitPer  := FWBuildFeature( STRUCT_FEATURE_INIPAD, 'IIF( !INCLUI, Posicione("FKC", 1, xFilial("FKC") + FKD->FKD_CODIGO, "FKC_PERIOD" ), "" )' )
	
	oSE1:AddField(			  ;
		STR0004					, ;	// [01] Titulo do campo	//"Descrição da Natureza"
	STR0004					, ;	// [02] ToolTip do campo 	//"Descrição da Natureza"
	"E1_DESCNAT"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	nTamDNat				, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
	, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "Posicione('SED',1,xFilial('SED')+SE1->E1_NATUREZ,'ED_DESCRIC')") ,,,; // [11] Inicializador Padrão do campo
	.T. )						// [14] Virtual


	oSE1:SetProperty( '*', MODEL_FIELD_OBRIGAT, .F. )

	oFKD:AddTrigger( "FKD_CODIGO", "FKD_TPVAL" , {|| .T. }, { |oModel| Posicione( "FKC", 1, xFilial("FKC") + oModel:GetValue("FKD_CODIGO"), "FKC_TPVAL"  ) } )
	oFKD:AddTrigger( "FKD_CODIGO", "FKD_DESC"  , {|| .T. }, { |oModel| Posicione( "FKC", 1, xFilial("FKC") + oModel:GetValue("FKD_CODIGO"), "FKC_DESC"   ) } )
	oFKD:AddTrigger( "FKD_CODIGO", "FKD_PERIOD", {|| .T. }, { |oModel| Posicione( "FKC", 1, xFilial("FKC") + oModel:GetValue("FKD_CODIGO"), "FKC_PERIOD" ) } )
	oFKD:AddTrigger( "FKD_CODIGO", "FKD_VLCALC", {|| .T. }, { |oModel| F70VATrig( oModel ) } )

	oFK7:SetProperty( '*', MODEL_FIELD_OBRIGAT, .F. )
	oFKD:SetProperty( 'FKD_DESC'  , MODEL_FIELD_INIT, bInitDesc )
	oFKD:SetProperty( 'FKD_TPVAL' , MODEL_FIELD_INIT, bInitVal )
	oFKD:SetProperty( 'FKD_VLCALC', MODEL_FIELD_OBRIGAT, .F. )
	oFKD:SetProperty( 'FKD_PERIOD', MODEL_FIELD_INIT, bInitPer )

	oModel:AddFields( "SE1MASTER", /*cOwner*/, oSE1 )
	oModel:AddGrid( "FK7DETAIL", "SE1MASTER", oFK7 )
	oModel:AddGrid( "FKDDETAIL", "SE1MASTER", oFKD )

	oModel:SetPrimaryKey({'E1_FILIAL','E1_PREFIXO','E1_NUM','E1_PARCELA','E1_TIPO','E1_CLIENTE','E1_LOJA'})

	If oModel:GetModel( 'FKDDETAIL' ):HasField( 'FKD_IDFKD' )
		oModel:GetModel( 'FKDDETAIL' ):SetUniqueLine( { 'FKD_CODIGO' , 'FKD_IDFKD' } )
	Else
		oModel:GetModel( 'FKDDETAIL' ):SetUniqueLine( { 'FKD_CODIGO' } )
	EndIf

	aAdd( aAuxFK7, {"FK7_FILIAL","xFilial('FK7')"} )
	aAdd( aAuxFK7, {"FK7_ALIAS","'SE1'"} )
	aAdd( aAuxFK7, {"FK7_CHAVE","SE1->E1_FILIAL + '|' + SE1->E1_PREFIXO + '|' + SE1->E1_NUM + '|' + SE1->E1_PARCELA + '|' + SE1->E1_TIPO + '|' + SE1->E1_CLIENTE + '|' + SE1->E1_LOJA"} )
	oModel:SetRelation( "FK7DETAIL", aAuxFK7, FK7->(IndexKey(2)) )

	aAdd( aAuxFKD, {"FKD_FILIAL", "xFilial('FKD')"} )
	aAdd( aAuxFKD, {"FKD_IDDOC", "FK7_IDDOC"} )
	oModel:SetRelation( "FKDDETAIL", aAuxFKD, FKD->(IndexKey(1)) )

	oModel:GetModel( 'FKDDETAIL' ):SetOptional( .T. )
	oModel:GetModel( 'FK7DETAIL' ):SetOptional( .T. )
	oModel:GetModel( 'FK7DETAIL' ):SetOnlyQuery( .T. ) //Gravação é realizada pela função FINGRVFK7
	oModel:GetModel( 'SE1MASTER' ):SetOnlyQuery( .T. )


	//Se o model for chamado via adapter de baixas.
	If FwIsInCallStack("FINI070")
		oModel:GetModel( "FKDDETAIL" ):SetNoInsertLine(.F.)
		oModel:GetModel( "FKDDETAIL" ):SetNoDeleteLine(.T.)
	Else
		oModel:GetModel( "FKDDETAIL" ):SetNoInsertLine(.T.)
		oModel:GetModel( "FKDDETAIL" ):SetNoDeleteLine(.T.)
	Endif
	
	If !FwIsInCallStack("FC040CON")
		oModel:GetModel( "FKDDETAIL" ):SetLoadFilter( Nil, " ABS(FKD_SALDO) < FKD_VALOR OR ABS(FKD_VLCALC) > 0" ) // Não carrega VA sem saldo (Controle de saldo no VA)
	EndIf
	
	oModel:SetActivate( { |oModel| FN070VAInfo(oModel) } )

	Return oModel

	//-----------------------------------------------------------------------------
	/*/{Protheus.doc}F70VATrig
	Validação do gatilho, retorna se pode ser executado ou não.
	@author Mauricio Pequim Jr
	@since  04/08/2016
	@version 12
	/*/
	//-----------------------------------------------------------------------------
Function F70VATrig( oModel )
	Local lRet := .F.
	Local aArea := GetArea()
	Local cCodVA := oModel:GetValue("FKD_CODIGO")

	dbSelectArea("FKC")
	FKC->( dbSetOrder( 1 ) ) //FKC_FILIAL+FKC_CODIGO
	If dbSeek( FWxFilial("FKC") + cCodVA )
		lRet := .T.
		nVa	:= FValAcess( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_NATUREZ,/*lBaixados*/, cCodVa, "R", dBaixa )
		oModel:LoadValue( "FKD_VLCALC", nVa )
		oModel:LoadValue( "FKD_VLINFO", nVa )
	EndIf
	RestArea( aArea )

	Return lRet

	//-----------------------------------------------------------------------------
	/*/{Protheus.doc}FN070VAGrv
	Gravação do modelo de dados.
	@author Mauricio Pequim Jr
	@since  04/08/2016
	@version 12
	/*/
	//-----------------------------------------------------------------------------
Function FN070VAGrv( oModel )
	Local oAux := oModel:GetModel("FKDDETAIL")
	Local nX := 0

	cOldVA := oModel:GetXMLData(,,,,,.T.) //GetXMLData( lDetail, nOperation, lXSL, lVirtual, lDeleted, lEmpty, lDefinition, cXMLFile, lPK, lPKEncoded, aFilterFields, lFirstLevel, lInternalID )
	nVA := 0
	For nX := 1 To oAux:Length()
		nVA += oAux:GetValue( "FKD_VLINFO", nX )
	Next nX
	Return .T.

	//-----------------------------------------------------------------------------
	/*/{Protheus.doc}FN070VAInfo
	Calculo dos VAs no load do Model da Baixa CR
	@author Mauricio Pequim Jr
	@since  04/08/2016
	@version 12
	/*/
	//-----------------------------------------------------------------------------
Function FN070VAInfo( oModel )
	Local oSubFKD  := oModel:GetModel("FKDDETAIL")
	Local nTamFKD  := oSubFKD:Length()
	Local nX	   := 0
	Local nVlAces  := 0
	Local lRet	   := .F.
	Local aArea	   := GetArea()
	Local cCodVA   := oSubFKD:GetValue("FKD_CODIGO")
	Local lCanBx   := FwIsInCallStack("FA070CAN")
	Local dDtBaixa := Iif( Type("dBaixa") == "U", dDataBase, dBaixa )
	Local nMoedBco := Iif( Type("nMoedaBco") == "U", 1, nMoedaBco )
	Local nTaxMoed := 1
	Local cIdFKD	:= ""
	Local lConsult	:= FwIsInCallStack("FC040CON")

	If Type("nTxMoeda") == "U"
		If SE1->E1_MOEDA > 1
			nTaxMoed := RecMoeda(dDtBaixa,SE1->E1_MOEDA)
		Endif
	Else
		nTaxMoed := nTxMoeda
	Endif

	cOldVA := Iif( Type("cOldVA") == 'U', "", cOldVA )
	
	oSubFKD:SetNoDeleteLine(.F.)
	
	If Empty(cOldVa) .And. !lCanBx

		dbSelectArea("FKC")
		FKC->( dbSetOrder( 1 ) ) //FKC_FILIAL+FKC_CODIGO

		nVA := 0
		For nX := 1 To nTamFKD
			nVlAces := 0
			oSubFKD:GoLine( nX )
			cCodVA	:= oSubFKD:GetValue("FKD_CODIGO")
			If oSubFKD:HasField("FKD_IDFKD") // Proteção campo criado 12.1.25
				cIdFKD	:= oSubFKD:GetValue("FKD_IDFKD")
			EndIf
			If !oSubFKD:IsDeleted() .And. FKC->( MSSeek( FWxFilial("FKC") + cCodVA ) )
				lRet := .T.
				If !__lAutoVA
					nVlAces := FValAcess( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_NATUREZ,/*lBaixados*/, cCodVa, "R", dDTBaixa,/*aValAces*/, SE1->E1_MOEDA, nMoedBco, nTaxMoed, cIdFKD )
					oModel:LoadValue( "FKDDETAIL", "FKD_VLCALC", nVlAces )
					oModel:LoadValue( "FKDDETAIL", "FKD_VLINFO", nVlAces )
				Else
					If Empty( oModel:GetValue( "FKDDETAIL", "FKD_DTBAIX" ) ) .Or. oModel:GetValue( "FKDDETAIL", "FKD_PERIOD" ) <> "1" ; //Se o VA de período único já foi baixado, então não considera novamente no valor de VA da nova baixa
						.Or. (oModel:GetValue( "FKDDETAIL", "FKD_PERIOD" ) == "1" .And. oModel:GetValue( "FKDDETAIL", "FKD_TPVAL" ) == "2") //Periodo único e tipo de valor fixo, o model filtra se já está totalmente baixado.
						nVlAces := oModel:GetValue( "FKDDETAIL", "FKD_VLINFO" )
					EndIf
				EndIf
				If !lConsult
					If !(ABS(oSubFKD:GetValue("FKD_SALDO")) < oSubFKD:GetValue("FKD_VALOR")) .And. oSubFKD:GetValue("FKD_VLCALC") = 0
						oSubFKD:DeleteLine()
					EndIf
				EndIf
				nVA += nVlAces
			EndIf
		Next nX
	EndIf

	oSubFKD:SetNoDeleteLine(.T.)
	
	RestArea( aArea )
	Return lRet

	//-----------------------------------------------------------------------------
	/*/{Protheus.doc}FVAAuto
	Indica que o model está sendo chamado via rotina automatica e com informação
dos valores.

@author Mauricio Pequim Jr
@since  08/09/2016
@version 12
/*/
//-----------------------------------------------------------------------------
Function FVAAuto( lAuto )

	__lAutoVA := lAuto

	Return

	//-----------------------------------------------------------------------------
	/*/{Protheus.doc} FN70VAFKD
	Ajusta os VAs para deixar apenas um com saldo em aberto.

	@type  Function
	@author Renato.ito
	@since 12/06/2019
	@version 12.1.25
	@param	cIdDoc, Character, IDDOC do título (FK7_IDDOC)
	cCodVa, Character, Código do VA
	@return lRet, Logical, True ou False
	/*/
	//-----------------------------------------------------------------------------

Function FN70VAFKD(cIdDoc As Character, cCodVa As Character ) As Logical

	Local oModelVA		As Object
	Local oSubFKD		As Object
	Local aFKDID		As Array
	Local nTotVA		As Numeric
	Local nVACnt		As Numeric
	Local lRet			As Logical
	Local cLog			As Character
	Local nX			As Numeric

	oModelVA	:= Nil
	oSubFKD		:= Nil
	aFKDID		:= {}
	nTotVA		:= 0
	nVACnt		:= 0
	lRet		:= .T.
	cLog		:= ""
	nX			:= 0

	oModelVA := FWLoadModel('FINA040VA')
	oModelVA:SetOperation( 4 ) //Alteração
	oModelVA:GetModel("FKDDETAIL"):SetLoadFilter(,"FKD_CODIGO = '"+ cCodVa +"'")
	oModelVA:AddCalc( 'VATOTAL', 'SE1MASTER', 'FKDDETAIL', 'FKD_VALOR', 'FKD_VATOT', 'SUM',{||.T.},,"Total VA" )
	oModelVA:Activate()
	oSubFKD := oModelVA:GetModel('FKDDETAIL')

	aFKDID := FN040VAID( cIdDoc, cCodVa )
	nTotVA := oModelVA:GetValue( "VATOTAL" , "FKD_VATOT" )

	If aFKDID[1] .And. oSubFKD:Length() > 1 // Se controla saldo (FKC_TPVAL = 2 e FKC_PERIOD = 1)

		For nVACnt := 1 To oSubFKD:Length()
			oSubFKD:GoLine( nVACnt )
			If oSubFKD:GetValue( "FKD_SALDO" ) == 0 //campo FKD_SALDO está armazenando o valor já baixado.
				oSubFKD:DeleteLine()
			ElseIf oSubFKD:GetValue("FKD_VALOR") <> nTotVA .And. nTotVA > 0
				If ( oSubFKD:GetValue("FKD_VALOR") <> oSubFKD:GetValue("FKD_SALDO") ) //Já existe saldo baixado, precisa gerar novo VA para a alteração
					oSubFKD:LoadValue( "FKD_VALOR", ABS(oSubFKD:GetValue("FKD_SALDO")) )
					nTotVA -= oSubFKD:GetValue( "FKD_VALOR" )
				ElseIf ( oSubFKD:GetValue("FKD_VALOR") == oSubFKD:GetValue("FKD_SALDO") ) //VA totalmente baixado
					nTotVA -= oSubFKD:GetValue( "FKD_VALOR" )
				Else // Altera o VA em aberto
					oSubFKD:LoadValue( "FKD_VALOR", nTotVA )
					oSubFKD:LoadValue( "FKD_VLCALC", nTotVA )
					nTotVA := 0
					aLinhasAlt[oSubFKD:GetLine()] := .T.  // Marca a linha como atualizada.
				EndIf
			EndIf
		Next

		If nTotVA > 0
			oSubFKD:AddLine()
			oSubFKD:SetValue( "FKD_CODIGO", cCodVa )
			oSubFKD:SetValue( "FKD_VALOR", nTotVA )
			oSubFKD:SetValue( "FKD_IDFKD", FWUUIDV4() )
		EndIf
		If oModelVA:VldData()
			FWFormCommit( oModelVA )
		Else
			lRet	 := .F.
			cLog := cValToChar(oModelVA:GetErrorMessage()[4]) + ' - '
			cLog += cValToChar(oModelVA:GetErrorMessage()[5]) + ' - '
			cLog += cValToChar(oModelVA:GetErrorMessage()[6])
			Help( ,,"F070VACAN",,cLog, 1, 0 )
		Endif
	EndIf

	oModelVA:Deactivate()
	oModelVA:Destroy()
	oModelVA := NIL

	Return lRet
