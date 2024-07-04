#Include "Protheus.CH"
#Include "FWMVCDef.CH"
#Include "TAFA396.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA396

Cadastro de Declaração de Informações de Operações Relevantes ( DIOR ).

@Param 

@Return

@Author	Felipe C. Seolin
@Since		18/09/2015
@Version	1.0
/*/                                                                                                                                          
//------------------------------------------------------------------
Function TAFA396()

Local oBrw	:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Declaração de Informações de Operações Relevantes ( DIOR )"
oBrw:SetAlias( "T27" )
oBrw:SetMenuDef( "TAFA396" )
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Função genérica MVC com as opções de menu.

@Param 

@Return	aRotina - Array com as opções de Menu

@Author	Felipe C. Seolin
@Since		18/09/2015
@Version	1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina	:=	{}
Local aFuncao	:=	{ { "", "TAF396Vld", "2" } }

aRotina := xFunMnuTAF( "TAFA396",, aFuncao )

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Função genérica MVC do Model.

@Param 

@Return	oModel - Objeto da Model MVC

@Author	Felipe C. Seolin
@Since		18/09/2015
@Version	1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStructT27	:=	FWFormStruct( 1, "T27" )
Local oStructT28	:=	FWFormStruct( 1, "T28" )
Local oModel		:=	MPFormModel():New( "TAFA396",,, { |oModel| SaveModel( oModel ) } )

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

If lVldModel
	oStructT27:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
	//oStructT28:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
EndIf

oModel:AddFields( "MODEL_T27", /*cOwner*/, oStructT27 )
oModel:GetModel( "MODEL_T27" ):SetPrimaryKey( { "T27_PERIOD", "T27_NUMDOS" } )

oModel:AddGrid( "MODEL_T28", "MODEL_T27", oStructT28 )
oModel:GetModel( "MODEL_T28" ):SetOptional( .T. )
oModel:GetModel( "MODEL_T28" ):SetUniqueLine( { "T28_IDCODT", "T28_ANOTRB" } )

oModel:GetModel( "MODEL_T27" ):SetPrimaryKey( { "T27_ID" } )

oModel:SetRelation( "MODEL_T28", { { "T28_FILIAL", "xFilial( 'T28' )" }, { "T28_ID", "T27_ID" } }, T28->( IndexKey( 1 ) ) )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Função genérica MVC da View.

@Param 

@Return	oView - Objeto da View MVC

@Author	Felipe C. Seolin
@Since		18/09/2015
@Version	1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel		:=	FWLoadModel( "TAFA396" )
Local oStructT27	:=	FWFormStruct( 2, "T27" )
Local oStructT28	:=	FWFormStruct( 2, "T28" )
Local oView		:=	FWFormView():New()

oView:SetModel( oModel )

oView:AddField( "VIEW_T27", oStructT27, "MODEL_T27" )
oView:EnableTitleView( "VIEW_T27", STR0001 ) //"Declaração de Informações de Operações Relevantes ( DIOR )"

oView:AddGrid( "VIEW_T28", oStructT28, "MODEL_T28" )
oView:EnableTitleView( "VIEW_T28", STR0002 ) //"Tributos Vinculados a DIOR"

oView:CreateHorizontalBox( "FIELDST27", 60 )
oView:CreateHorizontalBox( "GRIDT28", 40 )

oView:SetOwnerView( "VIEW_T27", "FIELDST27" )
oView:SetOwnerView( "VIEW_T28", "GRIDT28" )

oStructT27:RemoveField( "T27_ID" )
oStructT28:RemoveField( "T28_IDCODT" )

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel

Gravação dos dados, executado no momento da confirmação do modelo.

@Param		oModel - Objeto da Model MVC

@Return	.T.

@Author	Felipe C. Seolin
@Since		18/09/2015
@Version	1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation	:=	oModel:GetOperation()

Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
		TAFAltStat( "T27", " " )
	EndIf

	FWFormCommit( oModel )

End Transaction

Return( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF396Vld

Validação dos registros de acordo com as regras de integridade e
regras do manual da ECF.

@Param		cAlias	-	Alias da tabela
			nRecno	-	Recno do registro corrente
			nOpc	-	Operação a ser realizada
			lJob	-	Indica se foi chamado por Job

@Return	aLogErro - Array com o log de erros da validação

@Author	Felipe C. Seolin
@Since		18/09/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAF396Vld( cAlias, nRecno, nOpc, lJob )

Local cStatus		:=	""
Local cPerFin		:=	""
Local aLogErro	:=	{}

Default lJob	:=	.F.

If T27->T27_STATUS $ ( " 1" )

	If TAFSeekPer( DToS( T27->T27_PERIOD ), DToS( T27->T27_PERIOD ) )
		cPerFin := DToS( CHD->CHD_PERFIN )
	EndIf

	If Empty( T27->T27_PERIOD )
		aAdd( aLogErro, { "T27_PERIOD", "000003", "T27", nRecno } ) //STR0003 - "Data inconsistente ou vazia."
	EndIf

	If Empty( T27->T27_DTINAT )
		aAdd( aLogErro, { "T27_DTINAT", "000003", "T27", nRecno } ) //STR0003 - "Data inconsistente ou vazia."
	EndIf

	If Empty( T27->T27_DTFNAT )
		aAdd( aLogErro, { "T27_DTFNAT", "000003", "T27", nRecno } ) //STR0003 - "Data inconsistente ou vazia."
	EndIf

	If Empty( T27->T27_ANOINI )
		aAdd( aLogErro, { "T27_ANOINI", "000001", "T27", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
	EndIf

	If Empty( T27->T27_ANOFIN )
		aAdd( aLogErro, { "T27_ANOFIN", "000001", "T27", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
	EndIf

	If Empty( T27->T27_INDODB )
		aAdd( aLogErro, { "T27_INDODB", "000001", "T27", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
	Else
		If !( T27->T27_INDODB $ ( "1|2" ) )
			aAdd( aLogErro, { "T27_INDODB", "000002", "T27", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
		EndIf
	EndIf

	If Empty( T27->T27_INDODE )
		aAdd( aLogErro, { "T27_INDODE", "000001", "T27", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
	Else
		If !( T27->T27_INDODE $ ( "1|2" ) )
			aAdd( aLogErro, { "T27_INDODE", "000002", "T27", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
		EndIf
	EndIf

	If Empty( T27->T27_INDOER )
		aAdd( aLogErro, { "T27_INDOER", "000001", "T27", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
	Else
		If !( T27->T27_INDOER $ ( "1|2" ) )
			aAdd( aLogErro, { "T27_INDOER", "000002", "T27", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
		EndIf
	EndIf

	If Empty( T27->T27_INDOIB )
		aAdd( aLogErro, { "T27_INDOIB", "000001", "T27", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
	Else
		If !( T27->T27_INDOIB $ ( "1|2" ) )
			aAdd( aLogErro, { "T27_INDOIB", "000002", "T27", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
		EndIf
	EndIf

	If Empty( T27->T27_INDOIE )
		aAdd( aLogErro, { "T27_INDOIE", "000001", "T27", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
	Else
		If !( T27->T27_INDOIE $ ( "1|2" ) )
			aAdd( aLogErro, { "T27_INDOIE", "000002", "T27", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
		EndIf
	EndIf

	If Empty( T27->T27_INDOID )
		aAdd( aLogErro, { "T27_INDOID", "000001", "T27", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
	Else
		If !( T27->T27_INDOID $ ( "1|2" ) )
			aAdd( aLogErro, { "T27_INDOID", "000002", "T27", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
		EndIf
	EndIf

	If Empty( T27->T27_INDGAF )
		aAdd( aLogErro, { "T27_INDGAF", "000001", "T27", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
	Else
		If !( T27->T27_INDGAF $ ( "1|2" ) )
			aAdd( aLogErro, { "T27_INDGAF", "000002", "T27", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
		EndIf
	EndIf

	If Empty( T27->T27_INDRSO )
		aAdd( aLogErro, { "T27_INDRSO", "000001", "T27", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
	Else
		If !( T27->T27_INDRSO $ ( "1|2" ) )
			aAdd( aLogErro, { "T27_INDRSO", "000002", "T27", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
		EndIf
	EndIf

	If Empty( T27->T27_INDGPT )
		aAdd( aLogErro, { "T27_INDGPT", "000001", "T27", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
	Else
		If !( T27->T27_INDGPT $ ( "1|2" ) )
			aAdd( aLogErro, { "T27_INDGPT", "000002", "T27", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
		EndIf
	EndIf

	If Empty( T27->T27_INDBGP )
		aAdd( aLogErro, { "T27_INDBGP", "000001", "T27", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
	Else
		If !( T27->T27_INDBGP $ ( "1|2|3" ) )
			aAdd( aLogErro, { "T27_INDBGP", "000002", "T27", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
		EndIf
	EndIf

	If Empty( T27->T27_INDRBT )
		aAdd( aLogErro, { "T27_INDRBT", "000001", "T27", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
	Else
		If !( T27->T27_INDRBT $ ( "1|2" ) )
			aAdd( aLogErro, { "T27_INDRBT", "000002", "T27", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
		EndIf
	EndIf

	If Empty( T27->T27_INDRAT )
		aAdd( aLogErro, { "T27_INDRAT", "000001", "T27", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
	Else
		If !( T27->T27_INDRAT $ ( "1|2" ) )
			aAdd( aLogErro, { "T27_INDRAT", "000002", "T27", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
		EndIf
	EndIf

	If Empty( T27->T27_DSCSUM )
		aAdd( aLogErro, { "T27_DSCSUM", "000001", "T27", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
	EndIf

	If Empty( T27->T27_FUNJUR )
		aAdd( aLogErro, { "T27_FUNJUR", "000001", "T27", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
	EndIf

	If Empty( T27->T27_JSTSUM )
		aAdd( aLogErro, { "T27_JSTSUM", "000001", "T27", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
	EndIf

	//REGRA_DATA_MENOR_DATA_FIN_ESC
	If DToS( T27->T27_DTINAT ) > cPerFin
		aAdd( aLogErro, { "T27_DTINAT", "000240", "T27", nRecno } ) //STR0240 - "O campo 'Data de Início de Ato' deve ser menor ou igual ao campo 'Período Final' da Escrituração( TAFA372 - Parâmetros de Abertura ECF )."
	EndIf

	//REGRA_DATA_MENOR_DT_FIN_ATO
	If DToS( T27->T27_DTINAT ) > DToS( T27->T27_DTFNAT )
		aAdd( aLogErro, { "T27_DTINAT", "000241", "T27", nRecno } ) //STR0241 - "O campo 'Data de Início de Ato' deve ser menor ou igual ao campo 'Data Final de Ato'."
	EndIf

	//REGRA_DATA_MENOR_DATA_FIN_ESC
	If DToS( T27->T27_DTFNAT ) > cPerFin
		aAdd( aLogErro, { "T27_DTFNAT", "000242", "T27", nRecno } ) //STR0242 - "O campo 'Data Final de Ato' deve ser menor ou igual ao campo 'Período Final' da Escrituração( TAFA372 - Parâmetros de Abertura ECF )."
	EndIf

	//REGRA_MENOR_ANO_FIN
	If T27->T27_ANOINI > T27->T27_ANOFIN
		aAdd( aLogErro, { "T27_ANOINI", "000243", "T27", nRecno } ) //STR0243 - "O campo 'Ano-calendário Inicial' deve ser menor ou igual ao campo 'Ano-calendário Final'."
	EndIf

	//REGRA_PREENCHIMENTO_OBRIG_SUB_SEQ
	If T27->T27_INDGPT == "1" .and. Empty( T27->T27_INDBGP )
		aAdd( aLogErro, { "T27_INDBGP", "000244", "T27", nRecno } ) //STR0244 - "O campo 'Beneficiários Ger Pas Ter' deve estar preenchido quando o campo 'Geração Passivo Terceiros' estiver preenchido com '1 - Sim'."
	EndIf

	//REGRA_PREENCHIMENTO_OBRIG_SUB_SEQ
	If T27->T27_INDRAT == "1" .and. Empty( T27->T27_PERCRA )
		aAdd( aLogErro, { "T27_PERCRA", "000245", "T27", nRecno } ) //STR0245 - "O campo 'Percentual Redução Ativos' deve estar preenchido quando o campo 'Redução de Ativos' estiver preenchido com '1 - Sim'."
	EndIf

	//REGRA_PERC_MAIOR_ZERO	
	If !Empty( T27->T27_PERCRA ) .and. T27->T27_PERCRA <= 0
		aAdd( aLogErro, { "T27_PERCRA", "000246", "T27", nRecno } ) //STR0246 - "O campo 'Percentual Redução Ativos' deve ser preenchido com um valor maior que zero."
	EndIf

	T28->( DBSetOrder( 1 ) )

	If T28->( MsSeek( xFilial( "T28" ) + T27->T27_ID ) )

		While T28->( !Eof() ) .and. T28->( T28_FILIAL + T28_ID ) == xFilial( "T28" ) + T27->T27_ID

			If Empty( T28->T28_IDCODT )
				aAdd( aLogErro, { "T28_IDCODT", "000001", "T27", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
			Else
				xVldECFTab( "T26", T28->T28_IDCODT, 1,, @aLogErro,{ "T27", "T28_IDCODT", nRecno } )
			EndIf

			If Empty( T28->T28_ANOTRB )
				aAdd( aLogErro, { "T28_ANOTRB", "000001", "T27", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
			EndIf

			T28->( DbSkip() )
		EndDo

	EndIf

	//Atualizo o Status do Registro
	cStatus := Iif( Len( aLogErro ) > 0, "1", "0" )
	TAFAltStat( "T27", cStatus )

Else

	If !lJob
		aAdd( aLogErro, { "T27_ID", "000017", "T27", nRecno } ) //STR0017 - Registro já validado.
	EndIf

EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	VldECFLog( aLogErro )
EndIf

Return( aLogErro )