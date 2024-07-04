#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFA436.CH"

#DEFINE ORIGEM_MANUAL					"1"
#DEFINE ORIGEM_AUTOMATICO				"2"
#DEFINE ORIGEM_RECLASSIFICACAO_PREJ	"3"

Static cQualif := space(2)

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA436

Cadastro de Conta da Parte B.

@Author	Felipe C. Seolin 
@Since		07/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAFA436()

Local oBrowse	as object

oBrowse	:=	FWmBrowse():New()

If TAFAlsInDic( "T0S" )
	oBrowse:SetDescription( STR0001 ) //"Cadastro de Conta da Parte B"
	oBrowse:SetAlias( "T0S" )
	oBrowse:SetCacheView( .F. )
	oBrowse:SetMenuDef( "TAFA436" )

	T0S->( DBSetOrder( 2 ) )

	oBrowse:Activate()
Else
	Aviso( STR0100, TafAmbInvMsg(), { STR0101 }, 2 ) //##"Dicionário Incompatível" ##"Encerrar"
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Função genérica MVC com as opções de menu.

@Return	aRotina - Array com as opções de menu.

@Author	Felipe C. Seolin
@Since		07/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

Local nPos		as numeric
Local aRotina	as array
Local aFuncao	as array

nPos		:=	0
aRotina	:=	{}
aFuncao	:=	{}

aAdd( aFuncao, { STR0002, "TAF436Pre( 'Lançamentos em Lote', 'TAF436Lote' )" } ) //"Lançamentos em Lote"
aAdd( aFuncao, { STR0003, "TAF436Pre( 'Reclassificação do Prejuízo Fiscal', 'TAF436RPF' )" } ) //"Reclassificação do Prejuízo Fiscal"

aRotina := xFunMnuTAF( "TAFA436",, aFuncao )

If ( nPos := aScan( aRotina, { |x| AllTrim( x[1] ) == STR0096 } ) ) > 0 //"Visualizar"
	aRotina[nPos,2] := "TAF436Pre( 'Visualizar' )"
EndIf

If ( nPos := aScan( aRotina, { |x| AllTrim( x[1] ) == STR0097 } ) ) > 0 //"Incluir"
	aRotina[nPos,2] := "TAF436Pre( 'Incluir' )"
EndIf

If ( nPos := aScan( aRotina, { |x| AllTrim( x[1] ) == STR0098 } ) ) > 0 //"Alterar"
	aRotina[nPos,2] := "TAF436Pre( 'Alterar' )"
EndIf

If ( nPos := aScan( aRotina, { |x| AllTrim( x[1] ) == STR0099 } ) ) > 0 //"Excluir"
	aRotina[nPos,2] := "TAF436Pre( 'Excluir' )"
EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF436Pre

Executa pré-condições para a operação desejada.

@Param		cOper		-	Indica a operação a ser executada
			cRotina	-	Indica a rotina a ser executada

@Author	Felipe C. Seolin
@Since		23/11/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAF436Pre( cOper, cRotina )

Local nOperation	as numeric

Default cRotina	:=	"TAFA436"

nOperation	:=	MODEL_OPERATION_VIEW

//De-Para de opções do Menu para a operações em MVC
If Upper( cOper ) == Upper( "Visualizar" )
	nOperation := MODEL_OPERATION_VIEW
ElseIf Upper( cOper ) == Upper( "Incluir" )
	nOperation := MODEL_OPERATION_INSERT
ElseIf Upper( cOper ) == Upper( "Alterar" )
	nOperation := MODEL_OPERATION_UPDATE
ElseIf Upper( cOper ) == Upper( "Excluir" )
	nOperation := MODEL_OPERATION_DELETE
ElseIf Upper( cOper ) == Upper( "Lançamentos em Lote" )
	nOperation := 0
ElseIf Upper( cOper ) == Upper( "Reclassificação do Prejuízo Fiscal" )
	nOperation := 0
Else
	nOperation := 0
EndIf

If TAFColumnPos( "C1E_MATRIZ" ) .and. TAFColumnPos( "T0T_RURAL" )
	//É permitido o uso do cadastro apenas se for executado em Filial Matriz ou SCP.
	//Caso contrário, apenas será permitido a Visualização do referido cadastro.
	If GrantAccess()

		If cOper $ ( Upper( "Lançamentos em Lote" ) + "|" + Upper( "Reclassificação do Prejuízo Fiscal" ) )
			&cRotina.()
		ElseIf nOperation == MODEL_OPERATION_INSERT
			If Perg436()
				FWExecView( cOper, cRotina, nOperation )
			Else
				MsgInfo( STR0018 ) //"Ao não informar a Identificação da Pessoa Jurídica, não será possível identificar a tabela dinâmica referente ao código de lançamento na Parte A de origem."
			EndIf
		Else
			FWExecView( cOper, cRotina, nOperation )
		EndIf
	Else

		If nOperation == MODEL_OPERATION_VIEW
			FWExecView( cOper, cRotina, nOperation )
		Else
			MsgInfo( STR0004 ) //"Apenas Filial Matriz ou Filial SCP possui permissão de manipulação do cadastro."
		EndIf

	EndIf
Else
	MsgInfo( TafAmbInvMsg() )
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef

Função genérica MVC do modelo.

@Return	oModel - Objeto do modelo MVC

@Author	Felipe C. Seolin
@Since		07/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

Local oStruT0S	as object
Local oStruLE9	as object
Local oStruT0T	as object
Local oStruT0U	as object
Local oModel	as object
Local bValidT0S	as codeblock
Local bValidLE9	as codeblock
Local bValidT0T	as codeblock
Local bValidT0U	as codeblock
Local bLinOKLE9	as codeblock

oStruT0S	:=	FWFormStruct( 1, "T0S" )
oStruLE9	:=	FWFormStruct( 1, "LE9" )
oStruT0T	:=	FWFormStruct( 1, "T0T" )
oStruT0U	:=	FWFormStruct( 1, "T0U" )
oModel		:=	MPFormModel():New( "TAFA436",, { |oModel| ValidModel( oModel ) }, { |oModel| SaveModel( oModel ) } )
bValidT0S	:=	{ |oModelT0S, cAction, cIDField, xValue| ValidT0S( oModelT0S, cAction, cIDField, xValue ) }
bValidLE9	:=	{ |oModelLE9, nLine, cAction, cIDField, xValue, xCurrentValue| ValidLe9( oModelLE9, nLine, cAction, cIDField, xValue, xCurrentValue ) }
bValidT0T	:=	{ |oModelT0T, nLine, cAction, cIDField, xValue, xCurrentValue| ValidT0T( oModelT0T, nLine, cAction, cIDField, xValue, xCurrentValue ) }
bValidT0U	:=	{ |oModelT0U| ValidT0U( oModelT0U ) }
bLinOKLE9	:=  { |oModelLE9, nLine | LinOKLE9( oModelLE9,nLine) }

oStruLE9:AddTrigger( "LE9_CODTBT", "LE9_CODLAN",, { || "" } )
oStruLE9:AddTrigger( "LE9_CODTBT", "LE9_DCODLA",, { || "" } )
oStruLE9:AddTrigger( "LE9_CODTBT", "LE9_IDCODL",, { || "" } )

oModel:AddFields( "MODEL_T0S", /*cOwner*/, oStruT0S, bValidT0S )
oModel:GetModel( "MODEL_T0S" ):SetPrimaryKey( { "T0S_CODIGO" } )

oModel:AddGrid( "MODEL_LE9", "MODEL_T0S", oStruLE9, bValidLE9, bLinOKLE9)
oModel:GetModel( "MODEL_LE9" ):SetOptional( .T. )
oModel:GetModel( "MODEL_LE9" ):SetUniqueLine( { "LE9_CODTBT" } )

oModel:AddGrid( "MODEL_T0T", "MODEL_LE9", oStruT0T, bValidT0T )
oModel:GetModel( "MODEL_T0T" ):SetOptional( .T. )
oModel:GetModel( "MODEL_T0T" ):SetUniqueLine( { "T0T_CODLAN" } )

oModel:AddGrid( "MODEL_T0U", "MODEL_T0T", oStruT0U,, bValidT0U )
oModel:GetModel( "MODEL_T0U" ):SetOptional( .T. )
oModel:GetModel( "MODEL_T0U" ):SetUniqueLine( { "T0U_IDPROC" } )

oModel:SetRelation( "MODEL_LE9",{ { "LE9_FILIAL", "xFilial( 'LE9' )" }, { "LE9_ID", "T0S_ID" } }, LE9->( IndexKey( 1 ) ) )
oModel:SetRelation( "MODEL_T0T",{ { "T0T_FILIAL", "xFilial( 'T0T' )" }, { "T0T_ID", "T0S_ID" }, { "T0T_IDCODT", "LE9_IDCODT" } }, T0T->( IndexKey( 1 ) ) )
oModel:SetRelation( "MODEL_T0U",{ { "T0U_FILIAL", "xFilial( 'T0U' )" }, { "T0U_ID", "T0S_ID" }, { "T0U_IDCODT", "LE9_IDCODT" }, { "T0U_CODLAN", "T0T_CODLAN" } }, T0U->( IndexKey( 1 ) ) )

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Função genérica MVC da view.

@Return	oView - Objeto da view MVC

@Author	Felipe C. Seolin
@Since		07/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

Local oModel		as object
Local oView		as object
Local oStruT0S	as object
Local oStruLE9	as object
Local oStruT0T	as object
Local oStruT0U	as object

oModel		:=	FWLoadModel( "TAFA436" )
oView		:=	FWFormView():New()
oStruT0S	:=	FWFormStruct( 2, "T0S" )
oStruLE9	:=	FWFormStruct( 2, "LE9" )
oStruT0T	:=	FWFormStruct( 2, "T0T" )
oStruT0U	:=	FWFormStruct( 2, "T0U" )

oView:SetModel( oModel )

oView:AddField( "VIEW_T0S", oStruT0S, "MODEL_T0S" )
oView:EnableTitleView( "VIEW_T0S", STR0005 ) //"Conta da Parte B"

oView:AddGrid( "VIEW_LE9", oStruLE9, "MODEL_LE9" )
oView:EnableTitleView( "VIEW_LE9", STR0015 ) //"Tributos da Conta da Parte B"

oView:AddGrid( "VIEW_T0T", oStruT0T, "MODEL_T0T" )
oView:EnableTitleView( "VIEW_T0T", STR0006 ) //"Lançamentos na Conta da Parte B"

oView:AddGrid( "VIEW_T0U", oStruT0U, "MODEL_T0U" )
oView:EnableTitleView( "VIEW_T0U", STR0007 ) //"Processo Judicial e Administrativo dos Lançamentos na Conta da Parte B"

oView:CreateHorizontalBox( "FIELDT0S", 25 )
oView:CreateFolder( "FOLDER_SUPERIOR", "FIELDT0S" )

oView:CreateHorizontalBox( "GRIDLE9", 25 )
oView:CreateFolder( "FOLDER_INTERMEDIARIO1", "GRIDLE9" )

oView:CreateHorizontalBox( "GRIDT0T", 30 )
oView:CreateFolder( "FOLDER_INTERMEDIARIO2", "GRIDT0T" )

oView:CreateHorizontalBox( "GRIDT0U", 20 )
oView:CreateFolder( "FOLDER_INFERIOR", "GRIDT0U" )

oView:SetOwnerView( "VIEW_T0S", "FIELDT0S" )
oView:SetOwnerView( "VIEW_LE9", "GRIDLE9" )
oView:SetOwnerView( "VIEW_T0T", "GRIDT0T" )
oView:SetOwnerView( "VIEW_T0U", "GRIDT0U" )

oView:AddIncrementField( "VIEW_T0T", "T0T_CODLAN" )

oStruT0S:RemoveField( "T0S_ID" )
if TafColumnPos('T0S_IDCODP')
	oStruT0S:RemoveField('T0S_IDCODP')
endif
oStruLE9:RemoveField( "LE9_IDCODT" )
oStruLE9:RemoveField( "LE9_REGECF" )
oStruLE9:RemoveField( "LE9_IDCODL" )
oStruT0T:RemoveField( "T0T_CTDEST" )

If TAFColumnPos( "T0T_IDDETA" )
	oStruT0T:RemoveField( "T0T_IDDETA" )
EndIf

//Altera a posicao dos campos no Grid
If TAFColumnPos( "LE9_ISLDIN" ) .and. TAFColumnPos( "LE9_ISLDAT" )
	oStruLE9:SetProperty( 'LE9_ISLDIN', MVC_VIEW_ORDEM, '06' )
	oStruLE9:SetProperty( 'LE9_ISLDAT', MVC_VIEW_ORDEM, '09' )
endif

Return( oView )

//---------------------------------------------------------------------
/*/{Protheus.doc} GrantAccess

Função para verificar a permissão de manipulação do cadastro.

@Return	lRet - Indica se possui permissão

@Author	Felipe C. Seolin
@Since		31/05/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function GrantAccess()

Local lRet	as logical

lRet	:=	.F.

DBSelectArea( "C1E" )
C1E->( DBSetOrder( 3 ) )
If C1E->( MsSeek( xFilial( "C1E" ) + cFilAnt + "1" ) )
	If C1E->C1E_MATRIZ .or. FilialSCP( C1E->C1E_ID )
		lRet := .T.
	EndIf
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidModel

Validação dos dados, executado no momento da confirmação do modelo.

@Param		oModel - Modelo de dados

@Return	lRet - Indica se todas as condições foram respeitadas

@Author	Felipe C. Seolin
@Since		07/03/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ValidModel( oModel )

Local oModelLE9	as object
Local oModelT0T	as object
Local cChave		as character
Local nOperation	as numeric
Local nI			as numeric
Local nJ			as numeric
Local aAreaT0S	as array
Local aAreaLE9	as array
Local aAreaT0T	as array
Local lRet			as logical

oModelLE9	:=	oModel:GetModel( "MODEL_LE9" )
oModelT0T	:=	oModel:GetModel( "MODEL_T0T" )
cChave		:=	""
nOperation	:=	oModel:GetOperation()
nI			:=	0
nJ			:=	0
aAreaT0S	:=	T0S->( GetArea() )
aAreaLE9	:=	LE9->( GetArea() )
aAreaT0T	:=	T0T->( GetArea() )
lRet		:=	.T.

If nOperation == MODEL_OPERATION_DELETE

	For nI := 1 to oModelLE9:Length()
		oModelLE9:GoLine( nI )

		If !oModelLE9:IsEmpty()
			For nJ := 1 to oModelT0T:Length()
				oModelT0T:GoLine( nJ )

				If !oModelT0T:IsEmpty() .and. oModelT0T:GetValue( "T0T_ORIGEM", nJ ) == "3"
					T0T->( DBSetOrder( 1 ) )
					If T0T->( MsSeek( xFilial( "T0T" ) + oModelT0T:GetValue( "T0T_CTDEST", nJ ) ) )
						cChave := T0T->T0T_ID

						T0S->( DBSetOrder( 1 ) )
						If T0S->( MsSeek( xFilial( "T0S" ) + cChave ) )
							cChave := T0T->( T0T_ID + T0T_IDCODT )

							LE9->( DBSetOrder( 1 ) )
							If LE9->( MsSeek( xFilial( "LE9" ) + cChave ) )

								nSaldo := LE9->LE9_VLSDIN

								If T0T->( MsSeek( xFilial( "T0T" ) + LE9->( LE9_ID + LE9_IDCODT ) ) )
									While T0T->( !Eof() ) .and. T0T->( T0T_FILIAL + T0T_ID + T0T_IDCODT ) == xFilial( "T0T" ) + LE9->( LE9_ID + LE9_IDCODT )
										If T0T->( T0T_ID + T0T_IDCODT + T0T_CODLAN ) <> oModelT0T:GetValue( "T0T_CTDEST", nJ )
											nSaldo := RetSaldo( nSaldo, T0S->T0S_NATURE, T0T->T0T_TPLANC, T0T->T0T_VLLANC )
										EndIf
										T0T->( DBSkip() )
									EndDo

									If nSaldo < 0
										lRet := .F.
										Help( ,, "HELP",, STR0082, 1, 0 ) //"O saldo da conta de origem/destino ficará negativo com a efetivação deste lançamento."
									EndIf
								Else
									lRet := .F.
									Help( ,, "HELP",, STR0083, 1, 0 ) //"Não foi possível encontrar o lançamento de origem/destino da reclassificação."
								EndIf
							Else
								lRet := .F.
								Help( ,, "HELP",, STR0051, 1, 0 ) //"Não foi possível encontrar o tributo da conta referente ao lançamento de origem/destino da reclassificação."
							EndIf

						Else
							lRet := .F.
							Help( ,, "HELP",, STR0084, 1, 0 ) //"Não foi possível encontrar a conta referente ao lançamento de origem/destino da reclassificação."
						EndIf

					Else
						lRet := .F.
						Help( ,, "HELP",, STR0083, 1, 0 ) //"Não foi possível encontrar o lançamento de origem/destino da reclassificação."
					EndIf

				EndIf

				//Se foi um lançamento gerado pelo encerramento do Período, o mesmo não poderá ser alterado
				If !Empty( oModelT0T:GetValue( "T0T_IDDETA", nJ ) )
					lRet := .F.
					Help( ,, "HELP",, STR0107, 1, 0 ) //"Existem lançamentos gerados automaticamente pelo Encerramento do Período de Apuração e não podem ser excluídos."
					Exit
				EndIf

			Next nJ

		EndIf

	Next nI

EndIf

RestArea( aAreaT0S )
RestArea( aAreaLE9 )
RestArea( aAreaT0T )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} SaveModel

Função de gravação dos dados, no momento da confirmação do modelo.

@Param		oModel	- Modelo de dados

@Return	.T.

@Author	Felipe C. Seolin
@Since		03/05/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function SaveModel( oModel )

Local oModelLE9	as object
Local oModelT0T	as object
Local cChave		as character
Local nOperation	as numeric
Local nSaldo		as numeric
Local nI			as numeric
Local nJ			as numeric
Local aAreaT0S	as array
Local aAreaLE9	as array
Local aAreaT0T	as array

oModelLE9	:=	oModel:GetModel( "MODEL_LE9" )
oModelT0T	:=	oModel:GetModel( "MODEL_T0T" )
cChave		:=	""
nOperation	:=	oModel:GetOperation()
nSaldo		:=	0
nI			:=	0
nJ			:=	0
aAreaT0S	:=	T0S->( GetArea() )
aAreaLE9	:=	LE9->( GetArea() )
aAreaT0T	:=	T0T->( GetArea() )

If nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE .or. nOperation == MODEL_OPERATION_DELETE

	For nI := 1 to oModelLE9:Length()
		oModelLE9:GoLine( nI )

		If !oModelLE9:IsEmpty()

			For nJ := 1 to oModelT0T:Length()
				oModelT0T:GoLine( nJ )
				If !oModelT0T:IsEmpty() .and. oModelT0T:GetValue( "T0T_ORIGEM", nJ ) == "3"

					If oModelLE9:IsDeleted() .or. oModelT0T:IsDeleted() .or. nOperation == MODEL_OPERATION_DELETE

						T0T->( DBSetOrder( 1 ) )
						If T0T->( MsSeek( xFilial( "T0T" ) + oModelT0T:GetValue( "T0T_CTDEST", nJ ) ) )

							cChave := T0T->( T0T_ID + T0T_IDCODT )

							If RecLock( "T0T", .F. )
								T0T->( DBDelete() )
								T0T->( MsUnlock() )
							EndIf

							LE9->( DBSetOrder( 1 ) )
							If LE9->( MsSeek( xFilial( "LE9" ) + cChave ) )

								cChave := LE9->LE9_ID

								T0S->( DBSetOrder( 1 ) )
								If T0S->( MsSeek( xFilial( "T0S" ) + cChave ) )
									nSaldo := LE9->LE9_VLSDIN

									If T0T->( MsSeek( xFilial( "T0T" ) + LE9->( LE9_ID + LE9_IDCODT ) ) )
										While T0T->( !Eof() ) .and. T0T->( T0T_FILIAL + T0T_ID + T0T_IDCODT ) == xFilial( "T0T" ) + LE9->( LE9_ID + LE9_IDCODT )
											If T0T->( T0T_ID + T0T_IDCODT + T0T_CODLAN ) <> oModelT0T:GetValue( "T0T_CTDEST", nJ )
												nSaldo := RetSaldo( nSaldo, T0S->T0S_NATURE, T0T->T0T_TPLANC, T0T->T0T_VLLANC )
											EndIf
											T0T->( DBSkip() )
										EndDo
									EndIf

									If RecLock( "LE9", .F. )
										LE9->LE9_VLSDAT := nSaldo
										LE9->( MsUnlock() )
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			Next nI
		EndIf
	Next nI
EndIf

RestArea( aAreaT0S )
RestArea( aAreaLE9 )
RestArea( aAreaT0T )

FwFormCommit( oModel )

Return( .T. )

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidT0S

Validação das informações do formulário referente
a tabela T0S, indicado pela conta da parte B.

@Param		oModelT0S	- Objeto de modelo da tabela T0S
			cAction	- Ação origem da causa da validação
			cIDField	- Campo posicionado referente ao objeto oModelT0S
			xValue		- Valor a ser inserido na ação

@Return	lRet		- Informa se a ação foi validada

@Author	Felipe C. Seolin
@Since		19/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ValidT0S( oModelT0S, cAction, cIDField, xValue )

Local oModelLE9	as object
Local oModelT0T	as object
Local oModelT0U	as object
Local nSaldo		as numeric
Local nI			as numeric
Local nJ			as numeric
Local nK			as numeric
Local nLineLE9	as numeric
Local nLineT0T	as numeric
Local nLineT0U	as numeric
Local lRet     	as logical
Local lIndSld	as logical

oModelLE9	:=	oModelT0S:GetModel( "MODEL_LE9" ):GetModel( "MODEL_LE9" )
oModelT0T	:=	oModelLE9:GetModel( "MODEL_T0T" ):GetModel( "MODEL_T0T" )
oModelT0U	:=	oModelT0T:GetModel( "MODEL_T0U" ):GetModel( "MODEL_T0U" )
nSaldo		:=	0
nI			:=	0
nJ			:=	0
nK			:=	0
nLineLE9	:=	oModelLE9:GetLine()
nLineT0T	:=	oModelT0T:GetLine()
nLineT0U	:=	oModelT0U:GetLine()
lRet     	:=	.T.
lIndSld		:= TAFColumnPos( "LE9_ISLDIN" ) .and. TAFColumnPos( "LE9_ISLDAT" )

If cAction == "SETVALUE"

	If cIDField $ "T0S_NATURE" .and. xValue <> "4"
		For nI := 1 to oModelLE9:Length()
			oModelLE9:GoLine( nI )

			If !oModelLE9:IsEmpty() .and. !oModelLE9:IsDeleted()
				For nJ := 1 to oModelT0T:Length()
					oModelT0T:GoLine( nJ )

					If !oModelT0T:IsEmpty() .and. !oModelT0T:IsDeleted()
						oModelT0U := oModelT0T:GetModel( "MODEL_T0U" ):GetModel( "MODEL_T0U" )

						For nK := 1 to oModelT0U:Length()
							If !oModelT0U:IsEmpty() .and. !oModelT0U:IsDeleted()
								lRet := .F.
								Help( ,, "HELP",, STR0008, 1, 0 ) //"O Processo Judicial e Administrativo pode ser informado apenas quando a natureza da conta possuir o valor 'Dedução/Compensação do Tributo'."
								Exit
							EndIf
						Next nK

						If !lRet
							Exit
						EndIf
					EndIf
				Next nJ
			EndIf
		Next nI
	EndIf

	If cIDField $ "T0S_NATURE" .and. lRet
		For nI := 1 to oModelLE9:Length()
			oModelLE9:GoLine( nI )

			If !oModelLE9:IsEmpty() .and. !oModelLE9:IsDeleted()
				nSaldo := CalcSldAtu( oModelT0S, oModelLE9, oModelT0T, nI,, cAction, cIDField, xValue )
				If nSaldo < 0 .and. xValue != '5'
					lRet := .F.
					Help( ,, "HELP",, STR0009, 1, 0 ) //"O saldo da conta ficará negativo com a efetivação deste lançamento."
				Else
					oModelLE9:SetValue( "LE9_VLSDAT", nSaldo )
				EndIf
				If !lRet; exit; endif

			EndIf
		Next nI
	EndIf

	If  cIDField $ "T0S_NATURE" .AND. xValue <> FwFldGet("T0S_NATURE") 
		if TafColumnPos("LE9_ISLDAT") .and. TafColumnPos("LE9_ISLDIN") 
			For nI := 1 to oModelLE9:Length()
				oModelLE9:GoLine( nI )
				oModelLE9:ClearField("LE9_ISLDAT",nI)
				oModelLE9:ClearField("LE9_ISLDIN",nI)
			Next nI
		Endif
	Endif

EndIf

oModelLE9:GoLine( nLineLE9 )
oModelT0T:GoLine( nLineT0T )
oModelT0U:GoLine( nLineT0U )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidLE9

Validação das informações da grid referente a tabela
LE9, indicado pelos tributos da conta da parte B.

@Param		oModelLE9		- Objeto de modelo da tabela LE9
			nLine			- Linha posicionada referente ao objeto oModelLE9
			cAction		- Ação origem da causa da validação
			cIDField		- Campo posicionado referente ao objeto oModelLE9
			xValue			- Valor a ser inserido na ação
			xCurrentValue	- Valor contido no atualmente no campo

@Return	lRet		- Informa se a ação foi validada

@Author	Felipe C. Seolin
@Since		06/06/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ValidLE9( oModelLE9, nLine, cAction, cIDField, xValue, xCurrentValue )

Local oModelT0S	as object
Local oModelT0T	as object
Local cLogErro	as character
Local nSaldo		as numeric
Local nI			as numeric
Local nLineT0T	as numeric
Local aAreaT0S	as array
Local aAreaLE9	as array
Local aAreaT0T	as array
Local lPerg		as logical
Local lRet     	as logical

oModelT0S	:=	oModelLE9:GetOwner()
oModelT0T	:=	oModelLE9:GetModel( "MODEL_T0T" ):GetModel( "MODEL_T0T" )
cLogErro	:=	""
nSaldo		:=	0
nI			:=	0
nLineT0T	:=	oModelT0T:GetLine()
aAreaT0S	:=	T0S->( GetArea() )
aAreaLE9	:=	LE9->( GetArea() )
aAreaT0T	:=	T0T->( GetArea() )
lPerg		:=	.F.
lRet     	:=	.T.

If cAction == "DELETE"

	For nI := 1 to oModelT0T:Length()

		If !oModelT0T:IsEmpty() .and. oModelT0T:GetValue( "T0T_ORIGEM", nI ) == "3"

			If !lPerg .and. !MsgYesNo( STR0085, STR0086 ) //##"Esta operação irá excluir os lançamentos de Reclassificação do Prejuízo Fiscal tanto na conta de origem quanto na conta de destino. Deseja confirmar a execução?" ##"Exclusão de Reclassificação do Prejuízo Fiscal"
				lRet := .F.
				cLogErro += STR0087 + CRLF //"Operação de exclusão do lançamento não efetuada."
			EndIf

			lPerg := .T.

			If lRet
				T0T->( DBSetOrder( 1 ) )
				If T0T->( MsSeek( xFilial( "T0T" ) + oModelT0T:GetValue( "T0T_CTDEST", nI ) ) )

					LE9->( DBSetOrder( 1 ) )
					If LE9->( MsSeek( xFilial( "LE9" ) + T0T->( T0T_ID + T0T_IDCODT ) ) )

						T0S->( DBSetOrder( 1 ) )
						If T0S->( MsSeek( xFilial( "T0S" ) + T0T->T0T_ID ) )
							nSaldo := LE9->LE9_VLSDIN

							If T0T->( MsSeek( xFilial( "T0T" ) + LE9->( LE9_ID + LE9_IDCODT ) ) )
								While T0T->( !Eof() ) .and. T0T->( T0T_FILIAL + T0T_ID + T0T_IDCODT ) == xFilial( "T0T" ) + LE9->( LE9_ID + LE9_IDCODT )
									If T0T->( T0T_ID + T0T_IDCODT + T0T_CODLAN ) <> oModelT0T:GetValue( "T0T_CTDEST", nI )
										nSaldo := RetSaldo( nSaldo, T0S->T0S_NATURE, T0T->T0T_TPLANC, T0T->T0T_VLLANC )
									EndIf
									T0T->( DBSkip() )
								EndDo
							EndIf

							If nSaldo < 0
								lRet := .F.
								cLogErro += STR0082 + CRLF //"O saldo da conta de origem/destino ficará negativo com a efetivação deste lançamento."
								Exit
							EndIf
						Else
							lRet := .F.
							cLogErro += STR0084 + CRLF //"Não foi possível encontrar a conta referente ao lançamento de origem/destino da reclassificação."
							Exit
						EndIf
					Else
						lRet := .F.
						cLogErro += STR0051 + CRLF //"Não foi possível encontrar o tributo da conta referente ao lançamento de origem/destino da reclassificação."
						Exit
					EndIf
				Else
					lRet := .F.
					cLogErro += STR0083 + CRLF //"Não foi possível encontrar o lançamento de origem/destino da reclassificação."
					Exit
				EndIf
			EndIf

		EndIf

		//Se foi um lançamento gerado pelo encerramento do Período, o mesmo não poderá ser alterado
		If !Empty( oModelT0T:GetValue( "T0T_IDDETA", nI ) )
			lRet := .F.
			cLogErro += STR0107 + CRLF //"Existem lançamentos gerados automaticamente pelo Encerramento do Período de Apuração e não podem ser excluídos."
			Exit
		EndIf

	Next nI

ElseIf cAction == "SETVALUE"

	If cIDField $ "LE9_VLSDIN|LE9_ISLDIN"
		nSaldo	:= CalcSldAtu( oModelT0S, oModelLE9, oModelT0T, nLine,, cAction, cIDField, xValue )
		
		lRet := VldSldLE9(oModelLE9, nSaldo)
		if !lRet	
			cLogErro += STR0009 + CRLF //"O saldo da conta ficará negativo com a efetivação deste lançamento."
		else
			oModelLE9:SetValue( "LE9_VLSDAT", abs(nSaldo) )
		endif

	EndIf

EndIf

If !Empty( cLogErro )
	Help( ,, STR0105,, cLogErro, 1, 0 ) //"Atenção"
EndIf

oModelT0T:GoLine( nLineT0T )

RestArea( aAreaT0S )
RestArea( aAreaLE9 )
RestArea( aAreaT0T )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidT0T

Validação das informações da grid referente a tabela
T0T, indicado pelos lançamentos na conta da parte B.

@Param		oModelT0T		- Objeto de modelo da tabela T0T
			nLine			- Linha posicionada referente ao objeto oModelT0T
			cAction		- Ação origem da causa da validação
			cIDField		- Campo posicionado referente ao objeto oModelT0T
			xValue			- Valor a ser inserido na ação
			xCurrentValue	- Valor contido no atualmente no campo

@Return	lRet			- Informa se a ação foi validada

@Author	Felipe C. Seolin
@Since		15/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ValidT0T( oModelT0T, nLine, cAction, cIDField, xValue, xCurrentValue )

Local oModelLE9	as object
Local oModelT0S	as object
Local cLogErro	as character
Local cSolucao	as character
Local nSaldo	as numeric
Local nLineLE9	as numeric
Local aAreaT0S	as array
Local aAreaLE9	as array
Local aAreaT0T	as array
Local lRet		as	logical
Local lLancAut	as logical

oModelLE9	:=	oModelT0T:GetOwner()
oModelT0S	:=	oModelLE9:GetOwner()
cLogErro	:=	""
cSolucao	:= ''
nSaldo		:=	0
nLineLE9	:=	oModelLE9:GetLine()
aAreaT0S	:=	T0S->( GetArea() )
aAreaLE9	:=	LE9->( GetArea() )
aAreaT0T	:=	T0T->( GetArea() )
lRet		:=	.T.
lLancAut	:= IsInCallStack('ADDLANPARB')

//Se foi um lançamento gerado pelo encerramento do Período, o mesmo não poderá ser alterado
If !Empty( oModelT0T:GetValue( "T0T_IDDETA", nLine ) ) .and. !IsInCallStack( "TAF444Open" ) .and. !IsInCallStack( "TAFA444ALTE" ) .and.;
	!IsInCallStack( "AddLanPrej" ) .and. !IsInCallStack( "TAFA444Enc" ) .and. !IsInCallStack( "TAF444ELTE" ) .and.  !IsInCallStack( "TAF433Pre" ) 
	lRet := .F.
	cLogErro += STR0106 + CRLF //"Este lançamento foi gerado pelo Encerramento do Período e só poderá ser modificado através do Período de Apuração"
EndIf

If lRet .and. (cAction == "DELETE" .or. cAction == "UNDELETE")

	If cAction == "DELETE" .and. oModelT0T:GetValue( "T0T_ORIGEM", nLine ) == "3"
		If MsgYesNo( STR0085, STR0086 ) //##"Esta operação irá excluir os lançamentos de Reclassificação do Prejuízo Fiscal tanto na conta de origem quanto na conta de destino. Deseja confirmar a execução?" ##"Exclusão de Reclassificação do Prejuízo Fiscal"

			T0T->( DBSetOrder( 1 ) )
			If T0T->( MsSeek( xFilial( "T0T" ) + oModelT0T:GetValue( "T0T_CTDEST", nLine ) ) )

				LE9->( DBSetOrder( 1 ) )
				If LE9->( MsSeek( xFilial( "LE9" ) + T0T->( T0T_ID + T0T_IDCODT ) ) )

					T0S->( DBSetOrder( 1 ) )
					If T0S->( MsSeek( xFilial( "T0S" ) + T0T->T0T_ID ) )
						nSaldo := LE9->LE9_VLSDIN

						If T0T->( MsSeek( xFilial( "T0T" ) + LE9->( LE9_ID + LE9_IDCODT ) ) )
							While T0T->( !Eof() ) .and. T0T->( T0T_FILIAL + T0T_ID + T0T_IDCODT ) == xFilial( "T0T" ) + LE9->( LE9_ID + LE9_IDCODT )
								If T0T->( T0T_ID + T0T_IDCODT + T0T_CODLAN ) <> oModelT0T:GetValue( "T0T_CTDEST", nLine )
									nSaldo := RetSaldo( nSaldo, T0S->T0S_NATURE, T0T->T0T_TPLANC, T0T->T0T_VLLANC )
								EndIf
								T0T->( DBSkip() )
							EndDo
						EndIf

						If nSaldo < 0
							lRet := .F.
							cLogErro += STR0082 + CRLF //"O saldo da conta de origem/destino ficará negativo com a efetivação deste lançamento."
						EndIf
					Else
						lRet := .F.
						cLogErro += STR0084 + CRLF //"Não foi possível encontrar a conta referente ao lançamento de origem/destino da reclassificação."
					EndIf
				Else
					lRet := .F.
					cLogErro += STR0051 + CRLF //"Não foi possível encontrar o tributo da conta referente ao lançamento de origem/destino da reclassificação."
				EndIf
			Else
				lRet := .F.
				cLogErro += STR0083 + CRLF //"Não foi possível encontrar o lançamento de origem/destino da reclassificação."
			EndIf
		Else
			lRet := .F.
			cLogErro += STR0087 + CRLF //"Operação de exclusão do lançamento não efetuada."
		EndIf
	EndIf

	If lRet
		nSaldo := CalcSldAtu( oModelT0S, oModelLE9, oModelT0T, nLineLE9, nLine, cAction )

		lRet := VldSldLE9(oModelLE9, nSaldo)
		if !lRet
			cLogErro += STR0009 + CRLF //"O saldo da conta ficará negativo com a efetivação deste lançamento."
		else
			oModelLE9:SetValue( "LE9_VLSDAT", abs(nSaldo) )
		endif

	EndIf

ElseIf cAction == "SETVALUE" .and. cIDField $ "T0T_VLLANC|T0T_TPLANC"

	if !lLancAut .and. cIDField == 'T0T_TPLANC' .and.  xValue == '3' 
	
		lRet := .f.
		cLogErro := 'A opção: "3-Constituição de Saldo" não deve ser usada em lançamentos manuais.'
		cSolucao := 'Utilize as opções: "1-Débito" ou "2-Crédito".'

	else
	
		nSaldo := CalcSldAtu( oModelT0S, oModelLE9, oModelT0T, nLineLE9, nLine, cAction, cIDField, xValue )
		
		lRet := VldSldLE9(oModelLE9, nSaldo)
		
		if !lRet
			cLogErro += STR0009 + CRLF //"O saldo da conta ficará negativo com a efetivação deste lançamento."
		else
			oModelLE9:SetValue( "LE9_VLSDAT", abs(nSaldo) )
		endif
	
	endif	

EndIf

If !Empty( cLogErro )
	Help( ,, STR0105,, cLogErro, 1, 0,,,,,, {cSolucao} ) //"Atenção"
EndIf

RestArea( aAreaT0S )
RestArea( aAreaLE9 )
RestArea( aAreaT0T )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidT0U

Validação das informações da grid referente a tabela T0U, indicado pelos
processos judidiciais e administrativos dos lançamentos na conta da parte B

@Param		oModelT0U		- Objeto de modelo da tabela T0U

@Return	lRet			- Informa se a ação foi validada

@Author	Felipe C. Seolin
@Since		19/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ValidT0U( oModelT0U )

Local oModelT0S	as object
Local cNatureza	as character
Local lRet     	as logical

oModelT0S	:=	oModelT0U:GetOwner():GetOwner():GetOwner()
cNatureza	:=	oModelT0S:GetValue( "T0S_NATURE" )
lRet     	:= .T.

If cNatureza <> "4"
	lRet := .F.
	Help( ,, "HELP",, STR0008, 1, 0 ) //"O Processo Judicial e Administrativo pode ser informado apenas quando a natureza da conta possuir o valor 'Dedução/Compensação do Tributo'."
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} LinOKLE9

Validação das informações da grid referente a tabela LE9

@Param		oModelLE9	- Objeto de modelo da tabela LE9

@Return	lRet			- Informa se a ação foi validada

@Author	Carlos Silva Nonato / Renan Gomes
@Since		11/05/2021
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function LinOKLE9( oModelLE9, nLinha )

Local oModelT0S	as object
Local lRet     	as logical
Local lIndSld	as logical

oModelT0S	:=	oModelLE9:GetOwner()
cNatureza	:=	oModelT0S:GetValue( "T0S_NATURE" )
lRet     	:= .T.
lIndSld 	:= TafColumnPos("LE9_ISLDIN")

if lIndSld
	If cNatureza == "5" .and. Empty(oModelLE9:GetValue("LE9_ISLDIN"))
		lRet := .F.
		Help( ,, "HELP",, "Informe o campo Ind Sld Ini da linha posicionada", 1, 0 ) 
	EndIf
Endif

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} Perg436

Tela de entrada de dados prévia a interface cadastral.

@Return	lRet - Indica se todas as condições foram respeitadas

@Author	Felipe C. Seolin
@Since		08/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function Perg436()

Local oDlg			as object
Local oFont		as object
Local nLarguraBox	as numeric
Local nAlturaBox	as numeric
Local nLarguraSay	as numeric
Local nTop			as numeric
Local nAltura		as numeric
Local nLargura	as numeric
Local nPosIni		as numeric
Local lRet			as logical

oDlg			:=	Nil
oFont			:=	Nil
nLarguraBox	:=	0
nAlturaBox		:=	0
nLarguraSay	:=	0
nTop			:=	0
nAltura		:=	250
nLargura		:=	520
nPosIni		:=	0
lRet			:=	.F.

oFont := TFont():New( "Arial",, -11 )

oDlg := MsDialog():New( 0, 0, nAltura, nLargura, STR0010,,,,,,,,, .T. ) //"Parâmetros"

nAlturaBox := ( nAltura - 60 ) / 2
nLarguraBox := ( nLargura - 20 ) / 2

@10,10 to nAlturaBox,nLarguraBox of oDlg Pixel

nLarguraSay := nLarguraBox - 30
nTop := 20
TComboBox():New( nTop, 20, { |x| If( PCount() == 0, cQualif, cQualif := x ) }, { "", "01=" + STR0102, "02=" + STR0103, "03=" + STR0104 }, 200, 10, oDlg,, { || oDlg:Refresh() }, { || ValidPerg() },,, .T.,,,,,,,,,, STR0012, 1, oFont ) //##"PJ em Geral" ##"PJ Financeiro" ##"Sociedades Seguradoras ou Entidade Aberta de Previdência Complementar" ##"Identificação da Pessoa Jurídica"
nTop += 10

nPosIni := ( ( nLargura - 20 ) / 2 ) - ( 2 * 32 )

SButton():New( nAlturaBox + 10, nPosIni, 1, { |x| Iif( lRet := ValidPerg(), x:oWnd:End(), ) }, oDlg )
SButton():New( nAlturaBox + 10, nPosIni + 32, 2, { |x| x:oWnd:End() }, oDlg )

oDlg:Activate( ,,,.T. )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidPerg

Validação da entrada de dados prévia a interface cadastral.

@Return	lRet - Indica se todas as condições foram respeitadas

@Author	Felipe C. Seolin
@Since		08/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ValidPerg()

Local lRet	as logical

lRet	:=	.T.

If Empty( cQualif )
	MsgInfo( STR0016 ) //"Identificação da Pessoa Jurídica não informada."
	lRet := .F.
ElseIf !( cQualif $ "01|02|03" )
	MsgInfo( STR0017 ) //"Conteúdo inválido selecionado para Identificação da Pessoa Jurídica."
	lRet := .F.
EndIf


Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} CalcSldAtu

Executa o cálculo do saldo atual da conta de acordo
com o saldo inicial e os lançamentos informados.

@Param		oModelT0S	- Modelo MVC da tabela T0S
			oModelLE9	- Modelo MVC da tabela Le9
			oModelT0T	- Modelo MVC da tabela T0T
			nLineLE9	- Indica a linha posicionada da tabela LE9 em caso de chamada por validação da tabela LE9
			nLineT0T	- Indica a linha posicionada da tabela T0T em caso de chamada por validação da tabela T0T
			cAction	- Indica a ação em caso de chamada por validação
			cIDField	- Campo posicionado na ação em caso de chamada por validação
			xValue		- Valor a ser inserido na ação em caso de chamada por validação

@Return	nSaldo - Saldo atual da conta

@Author	Felipe C. Seolin
@Since		14/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function CalcSldAtu( oModelT0S, oModelLE9, oModelT0T, nLineLE9, nLineT0T, cAction, cIDField, xValue )

Local cNatureza		as character
Local cTpLanc		as character
Local nSaldo		as numeric
Local nVlLanc		as numeric
Local nI			as numeric
Local nCalcVlr		as numeric
Local cIndIni		as character
Local lIndSld		as logical
Local lCondCalc		as logical
Local lGrpAdic		as logical

Default nLineLE9	:=	0
Default nLineT0T	:=	0
Default cAction	:=	""
Default cIDField	:=	""
Default xValue	:=	Nil

cNatureza	:=	oModelT0S:GetValue( "T0S_NATURE" )
cTpLanc		:=	""
nSaldo		:=	oModelLE9:GetValue( "LE9_VLSDIN", nLineLE9 )
nVlLanc		:=	0
nI			:=	0
nCalcVlr	:=	0
lIndSld		:= TAFColumnPos( "LE9_ISLDIN" ) .and. TAFColumnPos( "LE9_ISLDAT" )
if lIndSld; cIndIni := FwFldGet('LE9_ISLDIN',); endif
lCondCalc	:= Nil
lGrpAdic	:= .f.

If cAction == "SETVALUE"
	If cIDField == "LE9_VLSDIN"
		nSaldo := xValue
	ElseIf cIDField == "T0S_NATURE"
		cNatureza := xValue
	EndIf
EndIf

For nI := 1 to oModelT0T:Length()
	If !( cAction == "DELETE" .and. nLineT0T == nI )
		If !oModelT0T:IsDeleted( nI ) .or. ( cAction == "UNDELETE" .and. nLineT0T == nI )

			If cAction == "SETVALUE" .and. nI == nLineT0T
				If cIDField == "T0T_VLLANC"
					cTpLanc := oModelT0T:GetValue( "T0T_TPLANC", nI )
					nVlLanc := xValue
				ElseIf cIDField == "T0T_TPLANC"
					cTpLanc := xValue
					nVlLanc := oModelT0T:GetValue( "T0T_VLLANC", nI )
				EndIf
			Else
				cTpLanc := oModelT0T:GetValue( "T0T_TPLANC", nI )
				nVlLanc := oModelT0T:GetValue( "T0T_VLLANC", nI )
			EndIf

			if cNatureza != '5'
				nSaldo := RetSaldo( nSaldo, cNatureza, cTpLanc, nVlLanc ) 
			else
				if lIndSld

					if cTpLanc == '3' 
						lGrpAdic := GrpConsSld( alltrim(oModelT0T:GetValue('T0T_IDDETA',nI)) ) == '09' //Grupo de adicao
					endif	
					
					lCondCalc := (cIndIni == '2' .and. cTpLanc == '1') .or. /*Se saldo inicial for crédito(considera como adição a conta) e o lançamento for débito, subtrai o valor */;
							(cIndIni == '1' .and. cTpLanc == '2') .or. /*Se saldo inicial for débito(considera como exclusão a conta) e o lançamento for credito, subtrai o valor */;
							(cTpLanc == '3' .and. ( ( cIndIni == '2' .and. !lGrpAdic)  .or. ( cIndIni == '1' .and. lGrpAdic) ) ) 
							/*Se tipo de lançamento for constituição de saldo e o saldo inicial for crédito(considerar como adição a conta) e o lançamento não for do grupo Adição, considerar como débito e subtrair o valor
							Se tipo de lançamento for constituição de saldo e o saldo inicial for débito(considerar como exclusão a conta) e o lançamento for do grupo Adição, considerar como debito e subtrair o valor*/

				else
					lCondCalc := cTpLanc == '1' //debito
				endif
				
				if lCondCalc
					nCalcVlr -= nVlLanc
				elseif !empty(cTpLanc)
					nCalcVlr += nVlLanc
				endif	
			endif	

		EndIf
	EndIf
Next nI

//Se a natureza for diferente de '5', a variavel nCalcVlr sempre terá o valor 0(Zero)
nSaldo += nCalcVlr

Return( nSaldo )

//---------------------------------------------------------------------
/*/{Protheus.doc} RetSaldo

Executa o cálculo do saldo atual da conta
de acordo com o lançamento informado.

@Param		nSaldo		- Indica o saldo atual da conta
			cNatureza	- Informa a natureza da conta
			cTpLanc	- Indica o tipo de lançamento executado
			nVlLanc	- Informa o valor do lançamento executado

@Return	nRet - Saldo da conta após o lançamento

@Author	Felipe C. Seolin
@Since		22/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function RetSaldo( nSaldo, cNatureza, cTpLanc, nVlLanc )

Local nRet	as numeric

nRet	:=	nSaldo

If cNatureza $ "1"
	If cTpLanc $ "2|3"
		nRet += nVlLanc
	ElseIf cTpLanc $ "1"
		nRet -= nVlLanc
	EndIf
ElseIf cNatureza $ "2|3|4"
	If cTpLanc $ "1|3"
		nRet += nVlLanc
	ElseIf cTpLanc $ "2"
		nRet -= nVlLanc
	EndIf
EndIf

Return( nRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA436RetSaldo

Executa o cálculo do saldo atual da conta
de acordo com o lançamento informado.

@Param		nSaldo		- Indica o saldo atual da conta
			cNatureza	- Informa a natureza da conta
			cTpLanc	- Indica o tipo de lançamento executado
			nVlLanc	- Informa o valor do lançamento executado

@Return	nRet - Saldo da conta após o lançamento

@Author	David Costa
@Since		08/05/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAFA436RetSaldo( nSaldo, cNatureza, cTpLanc, nVlLanc, cTpSaldo, cGrpDet 	 )

Local nRet	as numeric
Local lGrpAdic	:= .f.

Default cTpSaldo := ""
Default cGrpDet	 := ""

nRet	:=	nSaldo

If cNatureza $ "1"
	If Empty(cTpSaldo)
		cTpSaldo := "C"
	Endif
	If cTpLanc $ "2|3"
		nRet += nVlLanc
	ElseIf cTpLanc $ "1"
		nRet -= nVlLanc
	EndIf
ElseIf cNatureza $ "2|3|4"
	If Empty(cTpSaldo)
		cTpSaldo := "D"
	Endif
	If cTpLanc $ "1|3"
		nRet += nVlLanc
	ElseIf cTpLanc $ "2"
		nRet -= nVlLanc
	EndIf
elseIf cNatureza $ "5"
	
	if !Empty(cTpSaldo)
		if cTpLanc == '3'
			lGrpAdic := GrpConsSld( cGrpDet )   == '09' //Grupo de adicao
		endif
	
		lCondCalc := (cTpSaldo == 'C' .and. cTpLanc == '1') .or. /*Se saldo inicial for crédito(considera como adição a conta) e o lançamento for débito, subtrai o valor */;
						(cTpSaldo == 'D' .and. cTpLanc == '2') .or. /*Se saldo inicial for débito(considera como exclusão a conta) e o lançamento for credito, subtrai o valor */;
						(cTpLanc == '3' .and. ( ( cTpSaldo == 'C' .and. !lGrpAdic)  .or. ( cTpSaldo == 'D' .and. lGrpAdic) ) ) 
						/*Se tipo de lançamento for constituição de saldo e o saldo inicial for crédito(considerar como adição a conta) e o lançamento não for do grupo Adição, considerar como débito e subtrair o valor
						Se tipo de lançamento for constituição de saldo e o saldo inicial for débito(considerar como exclusão a conta) e o lançamento for do grupo Adição, considerar como debito e subtrair o valor*/

	else
		lCondCalc := cTpLanc == '1' //debito
	endif
	
	if lCondCalc
		nRet -= nVlLanc
	elseif !empty(cTpLanc)
		nRet += nVlLanc
	endif	

	//Se saldo ficou negativo, mudo indicativo do saldo
	if nRet < 0
		nRet 	 := ABS(nRet)
		cTpSaldo := IIF(cTpSaldo == "C","D","C")
	endif

EndIf

Return( nRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF436Trig

Função para atribuição de gatilho do campo.

@Return	cTrigger - Conteúdo do gatilho do campo

@Author	Felipe C. Seolin
@Since		03/06/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAF436Trig()

Local oModel		as object
Local oModelLE9	as object
Local cCampo		as character
Local cAux			as character
Local cTributo	as character
Local cTrigger	as character

oModel		:=	FWModelActive()
oModelLE9	:=	oModel:GetModel( "MODEL_LE9" )
cCampo		:=	SubStr( ReadVar(), At( ">", ReadVar() ) + 1 )
cAux		:=	""
cTributo	:=	""
cTrigger	:=	""

If cCampo == "LE9_CODTBT"
	T0J->( DBSetOrder( 2 ) )
	If T0J->( MsSeek( xFilial( "T0J" ) + PadR( FWFldGet( cCampo ), TamSX3( "T0J_CODIGO" )[1] ) ) )
		C3S->( DBSetOrder( 3 ) )
		If C3S->( MsSeek( xFilial( "C3S" ) + PadR( T0J->T0J_TPTRIB, TamSX3( "C3S_ID" )[1] ) ) )
			cTributo := C3S->C3S_CODIGO
		EndIf
	EndIf

	If Empty( cQualif )
		If !oModelLE9:IsEmpty()
			cAux := oModelLE9:GetValue( "LE9_REGECF", 1 )

			If AllTrim( cAux ) $ "1|4"
				cQualif := "01"
			ElseIf AllTrim( cAux ) $ "2|5"
				cQualif := "02"
			ElseIf AllTrim( cAux ) $ "3|6"
				cQualif := "03"
			EndIf
		EndIf
	EndIf

	If cTributo == "19"
		If cQualif == "01"
			cTrigger := "1"
		ElseIf cQualif == "02"
			cTrigger := "2"
		ElseIf cQualif == "03"
			cTrigger := "3"
		EndIf
	ElseIf cTributo == "18"
		If cQualif == "01"
			cTrigger := "4"
		ElseIf cQualif == "02"
			cTrigger := "5"
		ElseIf cQualif == "03"
			cTrigger := "6"
		EndIf
	EndIf
EndIf

Return( cTrigger )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF436When

Funcionalidade para atribuição da propriedade de edição do campo.

@Return	lWhen - Indica o modo de edição do campo

@Author	Felipe C. Seolin
@Since		11/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAF436When()

Local oModel	as object
Local oModelT0T	as object
Local oModelLE9	as object
Local cCampo	as character
Local lWhen		as logical
Local lIndSld	as logical
local lValidInd		as logical

oModel		:= FWModelActive()
oModelT0T	:= oModel:GetModel( "MODEL_T0T" )
oModelLE9	:= oModel:GetModel( "MODEL_LE9" )
cCampo		:= SubStr( ReadVar(), At( ">", ReadVar() ) + 1 )
lWhen		:= .T.
lIndSld		:= TAFColumnPos( "LE9_ISLDIN" ) .and. TAFColumnPos( "LE9_ISLDAT" )
lValidInd	:= FwFldGet('T0S_NATURE') <> "5"

If cCampo == "LE9_VLSDIN"
	If ( Type( "ALTERA" ) <> "U" ) .and. ALTERA .and. !oModelT0T:IsEmpty() 
		lWhen := .F.
	EndIf
elseif lIndSld .and. cCampo == 'LE9_ISLDIN'
	if ( lValidInd .OR. ( ( Type( "ALTERA" ) <> "U" ) .and. ALTERA .and. !oModelT0T:IsEmpty() .and. !empty(oModelLE9:GetValue('LE9_ISLDIN'))  )   )
		lWhen := .f.
	endif
ElseIf cCampo $ "T0T_DTLANC|T0T_VLLANC|T0T_TPLANC|T0T_INDDIF|T0T_HISTOR"
	If ( oModelT0T:GetValue( "T0T_ORIGEM" ) == ORIGEM_AUTOMATICO .and. !IsInCallStack( "AddLanPrej" ) .AND. !IsInCallStack( "TAFA444Enc" )  .and. !IsInCallStack( "TAF444ELTE" ) .and.  !IsInCallStack( "TAF433Pre" )  ) .or.;
		oModelT0T:GetValue( "T0T_ORIGEM" ) == ORIGEM_RECLASSIFICACAO_PREJ 
		lWhen := .F.
	EndIf
EndIf

Return( lWhen )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF436Valid

Funcionalidade para validação do campo.

@Return	lRet - Indica se todas as condições foram respeitadas

@Author	Felipe C. Seolin
@Since		12/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAF436Valid()

Local oModel		as object
Local oModelLE9	as object
Local oModelT0T	as object
Local cCampo		as character
Local cAux			as character
Local nLineLE9	as numeric
Local nLineT0T	as numeric
Local nI			as numeric
Local nJ			as numeric
Local lRet			as logical

oModel		:=	FWModelActive()
oModelLE9	:=	oModel:GetModel( "MODEL_LE9" )
oModelT0T	:=	oModel:GetModel( "MODEL_T0T" )
cCampo		:=	SubStr( ReadVar(), At( ">", ReadVar() ) + 1 )
cAux		:=	""
nLineLE9	:=	oModelLE9:GetLine()
nLineT0T	:=	oModelT0T:GetLine()
nI			:=	0
nJ			:=	0
lRet		:=	.T.

If cCampo == "T0S_NATURE"

	If M->T0S_NATURE <> "3"
		For nI := 1 to oModelLE9:Length()
			oModelLE9:GoLine( nI )

			If !oModelLE9:IsEmpty() .and. !oModelLE9:IsDeleted()
				oModelT0T := oModelLE9:GetModel( "MODEL_T0T" ):GetModel( "MODEL_T0T" )

				For nJ := 1 to oModelT0T:Length()
					If !oModelT0T:IsEmpty() .and. !oModelT0T:IsDeleted()
						If !Empty( oModelT0T:GetValue( "T0T_ORIGEM", nJ ) ) .and. oModelT0T:GetValue( "T0T_ORIGEM", nJ ) == "3"
							Help( ,, "HELP",, STR0092, 1, 0 ) //"A conta possui lançamento de origem 'Reclassificação do Prejuízo', não será possível alterar a natureza."
							lRet := .F.
							Exit
						EndIf
					EndIf
				Next nJ

				If !lRet
					Exit
				EndIf
			EndIf
		Next nI
	EndIf

ElseIf cCampo == "LE9_CODTBT"

	If !Empty( M->LE9_CODTBT )
		DBSelectArea( "C3S" )
		C3S->( DBSetOrder( 1 ) )
		If C3S->( MsSeek( xFilial( "C3S" ) + "18" ) )
			cAux += "|" + C3S->C3S_ID
		EndIf

		If C3S->( MsSeek( xFilial( "C3S" ) + "19" ) )
			cAux += "|" + C3S->C3S_ID
		EndIf

		DBSelectArea( "T0J" )
		T0J->( DBSetOrder( 2 ) )
		If T0J->( MsSeek( xFilial( "T0J" ) + M->LE9_CODTBT ) )
			If !( T0J->T0J_TPTRIB $ cAux )
				Help( ,, "HELP",, STR0013, 1, 0 ) //"Tributo não permitido para este cadastro."
				lRet := .F.
			EndIf
		Else
			Help( ,, "HELP",, STR0014, 1, 0 ) //"Tributo não cadastrado."
			lRet := .F.
		EndIf
	EndIf

ElseIf cCampo == "T0S_DTFINA"

	If !Empty( M->T0S_DTFINA )
		If !Empty( FWFldGet( "T0S_DTLIMI" ) ) .and. M->T0S_DTFINA > FWFldGet( "T0S_DTLIMI" )
			Help( ,, "HELP",, STR0019, 1, 0 ) //"A Data Final não pode ser maior que a Data Limite."
			lRet := .F.
		Else
			For nI := 1 to oModelLE9:Length()
				oModelLE9:GoLine( nI )

				If !oModelLE9:IsEmpty() .and. !oModelLE9:IsDeleted()
					oModelT0T := oModelLE9:GetModel( "MODEL_T0T" ):GetModel( "MODEL_T0T" )

					For nJ := 1 to oModelT0T:Length()
						If !oModelT0T:IsEmpty() .and. !oModelT0T:IsDeleted()
							If !Empty( oModelT0T:GetValue( "T0T_DTLANC", nJ ) ) .and. M->T0S_DTFINA > oModelT0T:GetValue( "T0T_DTLANC", nJ )
								Help( ,, "HELP",, STR0020, 1, 0 ) //"A Data Final não pode ser maior que a Data de Lançamento na Conta da Parte B."
								lRet := .F.
								Exit
							EndIf
						EndIf
					Next nJ

					If !lRet
						Exit
					EndIf
				EndIf
			Next nI
		EndIf
	EndIf

ElseIf cCampo == "T0S_DTLIMI"

	If !Empty( M->T0S_DTLIMI )
		If !Empty( FWFldGet( "T0S_DTFINA" ) ) .and. M->T0S_DTLIMI < FWFldGet( "T0S_DTFINA" )
			Help( ,, "HELP",, STR0021, 1, 0 ) //"A Data Limite não pode ser menor que a Data Final."
			lRet := .F.
		Else
			For nI := 1 to oModelLE9:Length()
				oModelLE9:GoLine( nI )

				If !oModelLE9:IsEmpty() .and. !oModelLE9:IsDeleted()
					oModelT0T := oModelLE9:GetModel( "MODEL_T0T" ):GetModel( "MODEL_T0T" )

					For nJ := 1 to oModelT0T:Length()
						If !oModelT0T:IsEmpty() .and. !oModelT0T:IsDeleted()
							If !Empty( oModelT0T:GetValue( "T0T_DTLANC", nJ ) ) .and. M->T0S_DTLIMI < oModelT0T:GetValue( "T0T_DTLANC", nJ )
								Help( ,, "HELP",, STR0022, 1, 0 ) //"A Data Limite não pode ser menor que a Data de Lançamento na Conta da Parte B."
								lRet := .F.
								Exit
							EndIf
						EndIf
					Next nJ

					If !lRet
						Exit
					EndIf
				EndIf
			Next nI
		EndIf
	EndIf

ElseIf cCampo == "T0T_DTLANC"

	If !Empty( M->T0T_DTLANC )
		If ( !Empty( FWFldGet( "T0S_DTFINA" ) ) .and. M->T0T_DTLANC < FWFldGet( "T0S_DTFINA" ) ) .or. ( !Empty( FWFldGet( "T0S_DTLIMI" ) ) .and. M->T0T_DTLANC > FWFldGet( "T0S_DTLIMI" ) )
			Help( ,, "HELP",, STR0023, 1, 0 ) //"A Data de Lançamento na Conta da Parte B deve estar compreendida entre a Data Final e a Data Limite."
			lRet := .F.
		ElseIf !VldPerOpen( M->T0T_DTLANC, oModel:GetValue( "MODEL_LE9", "LE9_IDCODT" ) )
			Help( ,, "HELP",, STR0108, 1, 0 ) //"O lançamento não pode ser inserido em um Período Encerrado."
			lRet := .F.
		EndIf
	EndIf

EndIf

oModelLE9:GoLine( nLineLE9 )
oModelT0T:GoLine( nLineT0T )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF436Lote

Funcionalidade para geração de lançamentos em
lote a partir de entrada de dados indicadas.

@Author	Felipe C. Seolin
@Since		20/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAF436Lote()

Local oDlg			as object
Local oFont		as object
Local cIDPos		as character
Local nAlturaBox	as numeric
Local nLarguraBox	as numeric
Local nTop			as numeric
Local nAltura		as numeric
Local nLargura	as numeric
Local nPosIni		as numeric
Local aArea		as array

Local cTributo	as character
Local cDescTrib	as character
Local dDataIni	as date
Local dDataFin	as date
Local cPeriod		as character
Local cTipoValor	as character
Local cTipoLanc	as character
Local cDiferido	as character
Local cHistorico	as character
Local nValor		as numeric
Local nPercent	as numeric

Private cCodTribut	as character

cCodTribut		:=	Space( TamSX3( "T0J_CODIGO" )[1] )

oDlg			:=	Nil
oFont			:=	Nil
cIDPos			:=	T0S->T0S_ID
nAlturaBox		:=	0
nLarguraBox	:=	0
nTop			:=	0
nAltura		:=	570
nLargura		:=	520
nPosIni		:=	0
aArea			:=	T0S->( GetArea() )

cTributo	:=	Space( TamSX3( "T0J_ID" )[1] )
cDescTrib	:=	""
dDataIni	:=	SToD( "  /  /    " )
dDataFin	:=	SToD( "  /  /    " )
cPeriod	:=	""
cTipoValor	:=	""
cTipoLanc	:=	""
cDiferido	:=	""
cHistorico	:=	""
nValor		:=	0
nPercent	:=	0

oFont := TFont():New( "Arial",, -11 )

oDlg := MsDialog():New( 0, 0, nAltura, nLargura, STR0002,,,,,,,,, .T. ) //"Lançamentos em Lote"

nAlturaBox := ( nAltura - 60 ) / 2
nLarguraBox := ( nLargura - 20 ) / 2

@10,10 to nAlturaBox,nLarguraBox of oDlg Pixel

nTop := 20
TGet():New( nTop, 20, { |x| If( PCount() == 0, cCodTribut, cCodTribut := x ) }, oDlg, 65, 10, "@!", { || ValidLote( 1, @cTributo, @cDescTrib, cIDPos ) },,,,,, .T.,,,,,,,,, "T0J", "M->LE9_TGET_T0J_A",,,,,,, STR0011, 1, oFont ) //"Tributo"
TGet():New( nTop, 90, { || cDescTrib }, oDlg, 130, 10, "@!",,,,,,, .T.,,, { || .F. },,,,,,, "cDescTrib",,,,,,, STR0026, 1, oFont ) //"Descrição"
nTop += 30
TGet():New( nTop, 20, { |x| If( PCount() == 0, dDataIni, dDataIni := x ) }, oDlg, 65, 10,, { || ValidLote( 2, dDataIni, dDataFin ) },,,,,, .T.,,,,,,,,,, "dDataIni",,,,,,, STR0024, 1, oFont ) //"Data Inicial"
TGet():New( nTop, 90, { |x| If( PCount() == 0, dDataFin, dDataFin := x ) }, oDlg, 65, 10,, { || ValidLote( 3, dDataFin, dDataIni ) },,,,,, .T.,,,,,,,,,, "dDataFin",,,,,,, STR0025, 1, oFont ) //"Data Final"
nTop += 30
TComboBox():New( nTop, 20, { |x| If( PCount() == 0, cPeriod, cPeriod := x ) }, { "", "1=" + STR0027, "2=" + STR0028 }, 65, 10, oDlg,, { || oDlg:Refresh() }, { || ValidLote( 4, cPeriod ) },,, .T.,,,,,,,,, "cPeriod", STR0029, 1, oFont ) //##"Mensal" ##"Trimestral" ##"Periodicidade"
nTop += 30
TComboBox():New( nTop, 20, { |x| If( PCount() == 0, cTipoValor, cTipoValor := x ) }, { "", "1=" + STR0030, "2=" + STR0031, "3=" + STR0032 }, 65, 10, oDlg,, { || nValor := 0, nPercent := 0, oDlg:Refresh() }, { || ValidLote( 5, cTipoValor, cTipoLanc ) },,, .T.,,,,,,,,, "cTipoValor", STR0033, 1, oFont ) //##"Valor Fixo" ##"Quotas Fixas" ##"Percentual" ##"Tipo de Valor"
TGet():New( nTop, 90, { |x| If( PCount() == 0, nValor, nValor := x ) }, oDlg, 65, 10, PesqPict( "T0T", "T0T_VLLANC" ), { || ValidLote( 6, nValor, cTipoValor ) },,,,,, .T.,,, { || cTipoValor == "1" },,,,,,, "nValor",,,,,,, STR0034, 1, oFont ) //"Valor"
TGet():New( nTop, 160, { |x| If( PCount() == 0, nPercent, nPercent := x ) }, oDlg, 65, 10, "@E 99.99", { || ValidLote( 7, nPercent, cTipoValor ) },,,,,, .T.,,, { || cTipoValor == "3" },,,,,,, "nPercent",,,,,,, STR0032, 1, oFont ) //"Percentual"
nTop += 30
TComboBox():New( nTop, 20, { |x| If( PCount() == 0, cTipoLanc, cTipoLanc := x ) }, { "", "1=" + STR0035, "2=" + STR0036, "3=" + STR0037 }, 65, 10, oDlg,, { || oDlg:Refresh() }, { || ValidLote( 8, cTipoLanc, cTipoValor ) },,, .T.,,,,,,,,, "cTipoLanc", STR0038, 1, oFont ) //##"Débito" ##"Crédito" ##"Constituição de Saldo" ##"Tipo do Lançamento"
nTop += 30
TComboBox():New( nTop, 20, { |x| If( PCount() == 0, cDiferido, cDiferido := x ) }, { "", "1=" + STR0039, "2=" + STR0040 }, 65, 10, oDlg,, { || oDlg:Refresh() }, { || ValidLote( 9, cDiferido ) },,, .T.,,,,,,,,, "cDiferido", STR0041, 1, oFont ) //##"Sim" ##"Não" ##"Realização de Valores Diferidos"
nTop += 30
TMultiGet():New( nTop, 20, { |x| If( PCount() == 0, cHistorico, cHistorico := x ) }, oDlg, 220, 40,,,,,, .T.,,,,,,,,,,, .T., STR0042, 1, oFont ) //"Histórico"
nTop += 20

nPosIni := ( ( nLargura - 20 ) / 2 ) - 64
SButton():New( nAlturaBox + 10, nPosIni, 1, { || Iif( VldLoteOk( cTributo, cDescTrib, cIDPos, dDataIni, dDataFin, cPeriod, cTipoValor, nValor, nPercent, cTipoLanc, cDiferido, cHistorico ), ( Processa( { || GravaLote( cTributo, cDescTrib, cIDPos, dDataIni, dDataFin, cPeriod, cTipoValor, nValor, nPercent, cTipoLanc, cDiferido, cHistorico ), STR0043, STR0044 } ), oDlg:End() ), "" ) }, oDlg ) //##"Processando" ##"Gravando Lote"
nPosIni += 32

SButton():New( nAlturaBox + 10, nPosIni, 2, { || oDlg:End() }, oDlg )

oDlg:Activate( ,,,.T. )

RestArea( aArea )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} VldLoteOk

Validação do botão para confirmar a entrada de todos os dados
dos parâmetros da funcionalidade de lançamento em lote.

@Param		cTributo	- Código do Tributo da Conta da Parte B
			cDescTrib	- Descrição do Tributo da Conta da Parte B
			cIDPos		- ID posicionado na Browse
			dDataIni	- Data Inicial
			dDataFin	- Data Final
			cPeriod	- Periodicidade
			cTipoValor	- Tipo do Valor
			nValor		- Valor ( em caso do Tipo do Valor "Valor Fixo" )
			nPercent	- Percentual ( em caso do Tipo do Valor "Percentual" )
			cTipoLanc	- Tipo do Lançamento
			cDiferido	- Realização de Valores Diferidos
			cHistorico	- Histórico

@Return	lRet - Indica se todas as condições foram respeitadas

@Author	Felipe C. Seolin
@Since		22/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function VldLoteOk( cTributo, cDescTrib, cIDPos, dDataIni, dDataFin, cPeriod, cTipoValor, nValor, nPercent, cTipoLanc, cDiferido, cHistorico )

Local lRet	as logical

lRet	:=	.T.

If !(	ValidLote( 1, @cTributo, @cDescTrib, cIDPos, .T. ) .and.;
		ValidLote( 2, dDataIni, dDataFin,, .T. ) .and.;
		ValidLote( 3, dDataFin, dDataIni,, .T. ) .and.;
		ValidLote( 4, cPeriod,,, .T. ) .and.;
		ValidLote( 5, cTipoValor, cTipoLanc,, .T. ) .and.;
		ValidLote( 6, nValor, cTipoValor,, .T. ) .and.;
		ValidLote( 7, nPercent, cTipoValor,, .T. ) .and.;
		ValidLote( 8, cTipoLanc, cTipoValor,, .T. ) .and.;
		ValidLote( 9, cDiferido,,, .T. ) )
	lRet := .F.
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidLote

Validação da entrada de dados dos parâmetros
da funcionalidade de lançamento em lote.

@Param		nOpc		- Indica a opção de validação a ser executada
			xConteudo	- Conteúdo do campo a ser validado
			xConteudo2	- Conteúdo do campo a ser comparado
			cIDPos		- ID posicionado na Browse
		lVldEmpty	- Informa se deve validar campo vazio

@Return	lRet - Indica se todas as condições foram respeitadas

@Author	Felipe C. Seolin
@Since		22/04/2016
@Version	1.0

@Altered by David Costa in 06/11/2017 - Alterado para melhorar a usabilidade da tela
/*/
//---------------------------------------------------------------------
Static Function ValidLote( nOpc, xConteudo, xConteudo2, cIDPos, lVldEmpty )

Local cID	as character
Local lRet	as logical

cID		:=	""
lRet	:=	.T.

Default	lVldEmpty := .F.

If nOpc == 1

	xConteudo := cCodTribut
	
	If !Empty( xConteudo )
		If Len( AllTrim( xConteudo ) ) <> 36
			cID := xFunCh2ID( xConteudo, "T0J", 2 )
			If !Empty( cID )
				xConteudo := cID
			EndIf
		EndIf

		DBSelectArea( "LE9" )
		LE9->( DBSetOrder( 1 ) )
		If LE9->( MsSeek( xFilial( "LE9" ) + cIDPos + xConteudo ) )
			xConteudo2 := AllTrim( T0J->( T0J_DESCRI ) )
		Else
			MsgInfo( STR0093 ) //"Tributo da Conta da Parte B não cadastrado."
			lRet := .F.
			xConteudo2 := ""
		EndIf
	Else
		MsgInfo( STR0094 ) //"Tributo da Conta da Parte B não informado."
		lRet := .F.
		xConteudo2 := ""
	EndIf

ElseIf nOpc == 2

	If !Empty( xConteudo ) .or. lVldEmpty
		If Empty( xConteudo )
			MsgInfo( STR0045 ) //"Data Inicial não informada."
			lRet := .F.
		ElseIf !Empty( xConteudo2 ) .and. xConteudo > xConteudo2
			MsgInfo( STR0046 ) //"Data Inicial não pode ser maior que a Data Final."
			lRet := .F.
		ElseIf xConteudo < T0S->T0S_DTFINA .or. ( !Empty( T0S->T0S_DTLIMI ) .and. xConteudo > T0S->T0S_DTLIMI )
			MsgInfo( STR0047 ) //"A Data Inicial deve estar compreendida entre a Data Final e a Data Limite cadastrada para a conta."
			lRet := .F.
		EndIf
	EndIf

ElseIf nOpc == 3

	If !Empty( xConteudo ) .or. lVldEmpty
		If Empty( xConteudo )
			MsgInfo( STR0048 ) //"Data Final não informada."
			lRet := .F.
		ElseIf !Empty( xConteudo2 ) .and. xConteudo < xConteudo2
			MsgInfo( STR0049 ) //"Data Final não pode ser menor que a Data Inicial."
			lRet := .F.
		ElseIf xConteudo < T0S->T0S_DTFINA .or. ( !Empty( T0S->T0S_DTLIMI ) .and. xConteudo > T0S->T0S_DTLIMI )
			MsgInfo( STR0050 ) //"A Data Final deve estar compreendida entre a Data Final e a Data Limite cadastrada para a conta."
			lRet := .F.
		EndIf
	EndIf
	
ElseIf nOpc == 4
	
	If !Empty( xConteudo ) .or. lVldEmpty
		If Empty( xConteudo )
			MsgInfo( STR0052 ) //"Periodicidade não informada."
			lRet := .F.
		ElseIf !( xConteudo $ "1|2" )
			MsgInfo( STR0053 ) //"Conteúdo inválido selecionado para Periodicidade."
			lRet := .F.
		EndIf
	EndIf

ElseIf nOpc == 5

	If !Empty( xConteudo ) .or. lVldEmpty
		If Empty( xConteudo )
			MsgInfo( STR0054 ) //"Tipo de Valor não informado."
			lRet := .F.
		ElseIf !( xConteudo $ "1|2|3" )
			MsgInfo( STR0055 ) //"Conteúdo inválido selecionado para Tipo de Valor."
			lRet := .F.
		ElseIf xConteudo == "2"
			If LE9->LE9_VLSDAT == 0
				MsgInfo( STR0088 ) //"Para o Tipo de Valor 'Quotas Fixas', o saldo atual da conta deve ser maior que zero."
				lRet := .F.
			ElseIf !Empty( xConteudo2 )
				If T0S->T0S_NATURE == "1" .and. xConteudo2 <> "1"
					MsgInfo( STR0089 ) //"Para o Tipo de Valor 'Quotas Fixas', apenas são permitidos lançamentos que reduzam o saldo atual da conta."
					lRet := .F.
				ElseIf T0S->T0S_NATURE $ "2|3|4" .and. xConteudo2 <> "2"
					MsgInfo( STR0089 ) //"Para o Tipo de Valor 'Quotas Fixas', apenas são permitidos lançamentos que reduzam o saldo atual da conta."
					lRet := .F.
				EndIf
			EndIf
		ElseIf xConteudo == "3"
			If LE9->LE9_VLSDAT == 0
				MsgInfo( STR0090 ) //"Para o Tipo de Valor 'Percentual', o saldo atual da conta deve ser maior que zero."
				lRet := .F.
			EndIf
		EndIf
	EndIf

ElseIf nOpc == 6

	If xConteudo != 0  .or. lVldEmpty
		If xConteudo <= 0 .and. xConteudo2 == "1"
			MsgInfo( STR0056 ) //"O campo Valor não pode ser preenchido com valor negativo ou zero."
			lRet := .F.
		EndIf
	EndIf

ElseIf nOpc == 7

	If xConteudo != 0 .or. lVldEmpty
		If xConteudo <= 0 .and. xConteudo2 == "3"
			MsgInfo( STR0057 ) //"O campo Percentual não pode ser preenchido com valor negativo ou zero."
			lRet := .F.
		EndIf
	EndIf

ElseIf nOpc == 8

	If !Empty( xConteudo ) .or. lVldEmpty
		If Empty( xConteudo )
			MsgInfo( STR0058 ) //"Tipo do Lançamento não informado."
			lRet := .F.
		ElseIf !( xConteudo $ "1|2|3" )
			MsgInfo( STR0059 ) //"Conteúdo inválido selecionado para Tipo do Lançamento."
			lRet := .F.
		ElseIf !Empty( xConteudo2 )
			If xConteudo2 == "2"
				If LE9->LE9_VLSDAT == 0
					MsgInfo( STR0088 ) //"Para o Tipo de Valor 'Quotas Fixas', o saldo atual da conta deve ser maior que zero."
					lRet := .F.
				ElseIf T0S->T0S_NATURE == "1" .and. xConteudo <> "1"
					MsgInfo( STR0089 ) //"Para o Tipo de Valor 'Quotas Fixas', apenas são permitidos lançamentos que reduzam o saldo atual da conta."
					lRet := .F.
				ElseIf T0S->T0S_NATURE $ "2|3|4" .and. xConteudo <> "2"
					MsgInfo( STR0089 ) //"Para o Tipo de Valor 'Quotas Fixas', apenas são permitidos lançamentos que reduzam o saldo atual da conta."
					lRet := .F.
				EndIf
			ElseIf xConteudo2 == "3"
				If LE9->LE9_VLSDAT == 0
					MsgInfo( STR0090 ) //"Para o Tipo de Valor 'Percentual', o saldo atual da conta deve ser maior que zero."
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf nOpc == 9

	If !Empty( xConteudo ) .or. lVldEmpty
		If Empty( xConteudo )
			MsgInfo( STR0091 ) //"Realização de Valores Diferidos não informado."
			lRet := .F.
		ElseIf !( xConteudo $ "1|2" )
			MsgInfo( STR0060 ) //"Conteúdo inválido selecionado para Realização de Valores Diferidos."
			lRet := .F.
		EndIf
	EndIf

EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GravaLote

Funcionalidade para gravar lançamentos em lote.

@Param		cTributo	- Código do Tributo da Conta da Parte B
			cDescTrib	- Descrição do Tributo da Conta da Parte B
			cIDPos		- ID posicionado na Browse
			dDataIni	- Data Inicial
			dDataFin	- Data Final
			cPeriod	- Periodicidade
			cTipoValor	- Tipo do Valor
			nValor		- Valor ( em caso do Tipo do Valor "Valor Fixo" )
			nPercent	- Percentual ( em caso do Tipo do Valor "Percentual" )
			cTipoLanc	- Tipo do Lançamento
			cDiferido	- Realização de Valores Diferidos
			cHistorico	- Histórico

@Author	Felipe C. Seolin
@Since		22/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function GravaLote( cTributo, cDescTrib, cIDPos, dDataIni, dDataFin, cPeriod, cTipoValor, nValor, nPercent, cTipoLanc, cDiferido, cHistorico )

Local cAliasQry	as character
Local cQuery		as character
Local cMonth		as character
Local cYear		as character
Local cCodLan		as character
Local dData		as date
Local nYear		as numeric
Local nQtdLanc	as numeric
Local nSaldo		as numeric
Local nVlrLanc	as numeric
Local nI			as numeric
Local aDates		as array
Local aLogOk		as array
Local aLogErro	as array

cAliasQry	:=	""
cQuery		:=	""
cMonth		:=	""
cYear		:=	""
cCodLan	:=	""
dData		:=	SToD( "  /  /    " )
nYear		:=	0
nQtdLanc	:=	0
nSaldo		:=	0
nVlrLanc	:=	0
nI			:=	0
aDates		:=	{}
aLogOk		:=	{}
aLogErro	:=	{}

For nYear := Year( dDataIni ) to Year( dDataFin )
	If nYear == Year( dDataIni ) .and. nYear == Year( dDataFin )
		nQtdLanc += Month( dDataFin ) - Month( dDataIni ) + 1
	ElseIf nYear == Year( dDataIni )
		nQtdLanc += 12 - Month( dDataIni ) + 1
	ElseIf nYear == Year( dDataFin )
		nQtdLanc += Month( dDataFin )
	Else
		nQtdLanc += 12
	EndIf
Next nYear

cMonth := StrZero( Month( dDataIni ), 2 )
cYear := StrZero( Year( dDataIni ), 4 )

For nI := 1 to nQtdLanc
	If cPeriod == "1"
		dData := CToD( "01" + "/" + cMonth + "/" + cYear )
		aAdd( aDates, LastDay( dData ) )
	ElseIf cPeriod == "2"
		If ( cMonth $ "03|06|09|12" )
			dData := CToD( "01" + "/" + cMonth + "/" + cYear )
			aAdd( aDates, LastDay( dData ) )
		ElseIf nI + 1 > nQtdLanc
			If cMonth >= "01" .and. cMonth <= "03"
				dData := CToD( "01" + "/" + "03" + "/" + cYear )
			ElseIf cMonth >= "04" .and. cMonth <= "06"
				dData := CToD( "01" + "/" + "06" + "/" + cYear )
			ElseIf cMonth >= "07" .and. cMonth <= "09"
				dData := CToD( "01" + "/" + "09" + "/" + cYear )
			ElseIf cMonth >= "10" .and. cMonth <= "12"
				dData := CToD( "01" + "/" + "12" + "/" + cYear )
			EndIf

			aAdd( aDates, LastDay( dData ) )
		EndIf
	EndIf

	cMonth := StrZero( Val( cMonth ) + 1, 2 )

	If cMonth > "12"
		cMonth := "01"
		cYear := StrZero( Val( cYear ) + 1, 4 )
	EndIf
Next nI

If !Empty( aDates )

	If LE9->( MsSeek( xFilial( "LE9" ) + cIDPos + cTributo ) )

		cAliasQry := GetNextAlias()

		BeginSql Alias cAliasQry
			SELECT MAX( T0T.T0T_CODLAN ) T0T_CODLAN
			FROM %table:T0T% T0T
			WHERE T0T.T0T_FILIAL = %xFilial:T0T%
			  AND T0T.T0T_ID = %Exp:cIDPos%
			  AND T0T.T0T_IDCODT = %Exp:cTributo%
			  AND T0T.%notDel%
		EndSql

		cCodLan := ( cAliasQry )->T0T_CODLAN

		( cAliasQry )->( DBCloseArea() )

		If cTipoValor == "1"
			nVlrLanc := nValor
		ElseIf cTipoValor == "2"
			nVlrLanc := NoRound( LE9->LE9_VLSDAT / Len( aDates ), 2 )
		EndIf

		For nI := 1 to Len( aDates )
			If cTipoValor == "2" .and. nI == Len( aDates )
				nVlrLanc := nVlrLanc + ( LE9->LE9_VLSDAT - nVlrLanc )
			ElseIf cTipoValor == "3"
				nVlrLanc := ( ( LE9->LE9_VLSDAT / 100 ) * nPercent )
			EndIf

			cCodLan := Soma1( cCodLan )

			If aDates[nI] < T0S->T0S_DTFINA .or. ( !Empty( T0S->T0S_DTLIMI ) .and. aDates[nI] > T0S->T0S_DTLIMI )
				aAdd( aLogErro, { T0S->T0S_CODIGO, cTributo, cCodLan, aDates[nI], nVlrLanc, cTipoLanc, STR0023 } ) //"A Data de Lançamento na Conta da Parte B deve estar compreendida entre a Data Final e a Data Limite."
			Else

				nSaldo := RetSaldo( LE9->LE9_VLSDAT, T0S->T0S_NATURE, cTipoLanc, nVlrLanc )

				If nSaldo < 0
					aAdd( aLogErro, { T0S->T0S_CODIGO, cTributo, cCodLan, aDates[nI], nVlrLanc, cTipoLanc, STR0009 } ) //"O saldo da conta ficará negativo com a efetivação deste lançamento."
				Else
					aAdd( aLogOk, { T0S->T0S_CODIGO, cTributo, cCodLan, aDates[nI], nVlrLanc, cTipoLanc } )

					If RecLock( "LE9", .F. )
						LE9->LE9_VLSDAT := nSaldo
						LE9->( MsUnlock() )
					EndIf

					If RecLock( "T0T", .T. )
						T0T->T0T_FILIAL	:=	xFilial( "T0T" )
						T0T->T0T_ID		:=	T0S->T0S_ID
						T0T->T0T_IDCODT	:=	cTributo
						T0T->T0T_CODLAN	:=	cCodLan
						T0T->T0T_DTLANC	:=	aDates[nI]
						T0T->T0T_VLLANC	:=	nVlrLanc
						T0T->T0T_TPLANC	:=	cTipoLanc
						T0T->T0T_INDDIF	:=	cDiferido
						T0T->T0T_HISTOR	:=	cHistorico
						T0T->T0T_ORIGEM	:=	"2"
						T0T->( MsUnlock() )
					EndIf
				EndIf

			EndIf
		Next nI
	EndIf
EndIf

If !Empty( aLogOk ) .or. !Empty( aLogErro )
	ShowLog( aLogOk, aLogErro )
Else
	MsgInfo( STR0061 ) //"Não foram processados lançamentos!"
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} ShowLog

Exibe o log com as os lançamentos confirmados e lançamentos
com inconsistências encontrados durante o processamento.

@Param		aLogOk - Array contendo os lançamentos confirmados:
					1 - Código da Conta
					2 - Tributo da Conta
					3 - Código do Lançamento
					4 - Data do Lançamento
					5 - Valor do Lançamento
					6 - Tipo do Lançamento

			aLogErro - Array contendo os lançamentos com inconsistências:
						1 - Código da Conta
						2 - Tributo da Conta
						3 - Código do Lançamento
						4 - Data do Lançamento
						5 - Valor do Lançamento
						6 - Tipo do Lançamento
						7 - Mensagem de ocorrência de erro

@Author	Felipe C. Seolin
@Since		22/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ShowLog( aLogOk, aLogErro )

Local oModal		as object
Local cConta		as character
Local cMensagem	as character
Local cPicture	as character
Local nI			as numeric

oModal		:=	Nil
cConta		:=	""
cMensagem	:=	""
cPicture	:=	PesqPict( "T0T", "T0T_VLLANC" )
nI			:=	0

oModal := FWDialogModal():New()
oModal:SetTitle( STR0062 ) //"Log de Processamento"
oModal:SetFreeArea( 250, 250 )
oModal:SetEscClose( .T. )
oModal:SetBackground( .T. )
oModal:CreateDialog()

If !Empty( aLogOk )
	cMensagem += "*************************************************************************************************"
	cMensagem += Chr( 13 ) + Chr( 10 )
	cMensagem += Upper( STR0063 ) //"Lançamentos Confirmados"
	cMensagem += Chr( 13 ) + Chr( 10 )
	cMensagem += "*************************************************************************************************"
	cMensagem += Chr( 13 ) + Chr( 10 )

	For nI := 1 to Len( aLogOk )

		cMensagem += Chr( 13 ) + Chr( 10 )

		If cConta <> aLogOk[nI,1]
			cConta := aLogOk[nI,1]
	
			cMensagem += STR0064 + " " + AllTrim( aLogOk[nI,1] ) + " - " + STR0011 + " " + Posicione( "T0J", 1, xFilial( "T0J" ) + aLogOk[nI,2], AllTrim( "T0J_CODIGO" ) ) //##"Conta" ##"Tributo"
			cMensagem += Chr( 13 ) + Chr( 10 )
		EndIf

		cMensagem += "- " + STR0065 + ": " + AllTrim( aLogOk[nI,3] ) + " - " //"Lançamento"
		cMensagem += STR0066 + ": " + DToC( aLogOk[nI,4] ) + " - " //"Data"
		cMensagem += STR0034 + ": " + AllTrim( Transform( aLogOk[nI,5], cPicture ) ) + " - " //"Valor"
		cMensagem += STR0067 + ": " + Iif( aLogOk[nI,6] == "1", STR0035, Iif( aLogOk[nI,6] == "2", STR0036, STR0037 ) ) //##"Tipo" ##"Débito" ##"Crédito" ##"Constituição de Saldo"
		cMensagem += Chr( 13 ) + Chr( 10 )
	Next nI

	cConta := ""
EndIf

If !Empty( aLogErro )
	If !Empty( cMensagem )
		cMensagem += Chr( 13 ) + Chr( 10 )
		cMensagem += Chr( 13 ) + Chr( 10 )
		cMensagem += Chr( 13 ) + Chr( 10 )
	EndIf

	cMensagem += "*************************************************************************************************"
	cMensagem += Chr( 13 ) + Chr( 10 )
	cMensagem += Upper( STR0068 ) //"Lançamentos com Inconsistências"
	cMensagem += Chr( 13 ) + Chr( 10 )
	cMensagem += "*************************************************************************************************"
	cMensagem += Chr( 13 ) + Chr( 10 )

	For nI := 1 to Len( aLogErro )
		cMensagem += Chr( 13 ) + Chr( 10 )

		If cConta <> aLogErro[nI,1]
			cConta := aLogErro[nI,1]
	
			cMensagem += STR0064 + " " + AllTrim( aLogErro[nI,1] ) + " - " + STR0011 + " " + Posicione( "T0J", 1, xFilial( "T0J" ) + aLogErro[nI,2], AllTrim( "T0J_CODIGO" ) ) //##"Conta" ##"Tributo"
			cMensagem += Chr( 13 ) + Chr( 10 )
		EndIf

		cMensagem += "- " + STR0065 + ": " + AllTrim( aLogErro[nI,3] ) + " - " //"Lançamento"
		cMensagem += STR0066 + ": " + DToC( aLogErro[nI,4] ) + " - " //"Data"
		cMensagem += STR0034 + ": " + AllTrim( Transform( aLogErro[nI,5], cPicture ) ) + " - " //"Valor"
		cMensagem += STR0067 + ": " + Iif( aLogErro[nI,6] == "1", STR0035, Iif( aLogErro[nI,6] == "2", STR0036, STR0037 ) ) //##"Tipo" ##"Débito" ##"Crédito" ##"Constituição de Saldo"
		cMensagem += Chr( 13 ) + Chr( 10 )
		cMensagem += aLogErro[nI,7]
		cMensagem += Chr( 13 ) + Chr( 10 )
	Next nI

	cConta := ""
EndIf

TMultiGet():New( 030, 020, { || cMensagem }, oModal:GetPanelMain(), 210, 190,,,,,, .T.,,,,,, .T.,,,,, .T. )

oModal:Activate()

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF436RPF

Funcionalidade para Reclassificação do Prejuízo Fiscal.

@Author	Felipe C. Seolin
@Since		22/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAF436RPF()

Local oDlg			as object
Local oFont		as object
Local cIDPos		as character
Local nAlturaBox	as numeric
Local nLarguraBox	as numeric
Local nTop			as numeric
Local nAltura		as numeric
Local nLargura	as numeric
Local nPosIni		as numeric
Local aArea		as array
Local lOk			as logical

Local cTributo	as character
Local cDescTrib	as character
Local cContaDest	as character
Local cDescConta	as character
Local dData		as date
Local nValor		as numeric
Local cHistorico	as character

oDlg			:=	Nil
oFont			:=	Nil
cIDPos			:=	T0S->T0S_ID
nAlturaBox		:=	0
nLarguraBox	:=	0
nTop			:=	0
nAltura		:=	400
nLargura		:=	520
nPosIni		:=	0
aArea			:=	T0S->( GetArea() )
lOk				:=	.T.

cTributo	:=	Space( TamSX3( "T0J_ID" )[1] )
cDescTrib	:=	""
cContaDest	:=	Space( TamSX3( "T0S_CODIGO" )[1] )
cDescConta	:=	""
dData		:=	SToD( "  /  /    " )
nValor		:=	0
cHistorico	:=	""

If T0S->T0S_NATURE <> "3"
	MsgInfo( STR0069 ) //"Conta da Parte B de origem não permitida para este processo. Selecione uma conta com a natureza 'Compensação de Prejuízo/Base de Cálculo Negativa'."
	lOk := .F.
EndIf

If lOk
	oFont := TFont():New( "Arial",, -11 )

	oDlg := MsDialog():New( 0, 0, nAltura, nLargura, STR0003,,,,,,,,, .T. ) //"Reclassificação do Prejuízo Fiscal"

	nAlturaBox := ( nAltura - 60 ) / 2
	nLarguraBox := ( nLargura - 20 ) / 2

	@10,10 to nAlturaBox,nLarguraBox of oDlg Pixel

	nTop := 20
	TGet():New( nTop, 20, { |x| If( PCount() == 0, cTributo, cTributo := x ) }, oDlg, 65, 10, "@!", { || ValidRPF( 1, @cTributo, @cDescTrib,, cIDPos ) },,,,,, .T.,,,,,,,,, "T0J", "M->LE9_TGET_T0J_B",,,,,,, STR0011, 1, oFont ) //"Tributo"
	TGet():New( nTop, 90, { || cDescTrib }, oDlg, 130, 10, "@!",,,,,,, .T.,,, { || .F. },,,,,,, "cDescTrib",,,,,,, STR0026, 1, oFont ) //"Descrição"
	nTop += 30
	TGet():New( nTop, 20, { |x| If( PCount() == 0, cContaDest, cContaDest := x ) }, oDlg, 65, 10, "@!", { || ValidRPF( 2, @cContaDest, @cDescConta, cTributo, cIDPos ) },,,,,, .T.,,,,,,,,, "T0S", "cContaDest",,,,,,, STR0071, 1, oFont ) //"Conta de Destino"
	TGet():New( nTop, 90, { || cDescConta }, oDlg, 130, 10, "@!",,,,,,, .T.,,, { || .F. },,,,,,, "cDescConta",,,,,,, STR0026, 1, oFont ) //"Descrição"
	nTop += 30
	TGet():New( nTop, 20, { |x| If( PCount() == 0, dData, dData := x ) }, oDlg, 65, 10,, { || ValidRPF( 3, dData, cContaDest ) },,,,,, .T.,,,,,,,,,, "dData",,,,,,, STR0072, 1, oFont ) //"Data do Lançamento"
	TGet():New( nTop, 90, { |x| If( PCount() == 0, nValor, nValor := x ) }, oDlg, 65, 10, PesqPict( "T0T", "T0T_VLLANC" ), { || ValidRPF( 4, nValor ) },,,,,, .T.,,,,,,,,,, "nValor",,,,,,, STR0034, 1, oFont ) //"Valor"
	nTop += 30
	TMultiGet():New( nTop, 20, { |x| If( PCount() == 0, cHistorico, cHistorico := x ) }, oDlg, 220, 40,,,,,, .T.,,,,,,,,,,, .T., STR0042, 1, oFont ) //"Histórico"
	nTop += 20

	nPosIni := ( ( nLargura - 20 ) / 2 ) - 64
	SButton():New( nAlturaBox + 10, nPosIni, 1, { || Iif( VldRPFOk( cTributo, cDescTrib, cIDPos, cContaDest, cDescConta, dData, nValor, cHistorico ), ( Processa( { || GravaRPF( cTributo, cDescTrib, cIDPos, cContaDest, cDescConta, dData, nValor, cHistorico ), STR0043, STR0073 } ), oDlg:End() ), "" ) }, oDlg ) //##"Processando" ##"Gravando Lançamento de Reclassificação do Prejuízo Fiscal"
	nPosIni += 32
	SButton():New( nAlturaBox + 10, nPosIni, 2, { || oDlg:End() }, oDlg )

	oDlg:Activate( ,,,.T. )
EndIf

RestArea( aArea )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} VldRPFOk

Validação do botão para confirmar a entrada de todos os dados dos
parâmetros da funcionalidade de reclassificação do prejuízo fiscal.

@Param		cTributo	- Código do Tributo da Conta da Parte B
			cDescTrib	- Descrição do Tributo da Conta da Parte B
			cIDPos		- ID posicionado na Browse
			cContaDest	- Código da Conta da Parte B de destino
			cDescConta	- Descrição da Conta da Parte B de destino
			dData		- Data do Lançamento
			nValor		- Valor do Lançamento
			cHistorico	- Histórico do Lançamento

@Return	lRet - Indica se todas as condições foram respeitadas

@Author	Felipe C. Seolin
@Since		25/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function VldRPFOk( cTributo, cDescTrib, cIDPos, cContaDest, cDescConta, dData, nValor, cHistorico )

Local lRet	as logical

lRet	:=	.T.

If !(	ValidRPF( 1, @cTributo, @cDescTrib,, cIDPos ) .and.;
		ValidRPF( 2, @cContaDest, @cDescConta, cTributo, cIDPos ) .and.;
		ValidRPF( 3, dData, cContaDest ) .and.;
		ValidRPF( 4, nValor ) )
	lRet := .F.
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidRPF

Validação da entrada de dados dos parâmetros da
funcionalidade de reclassificação do prejuízo fiscal.

@Param		nOpc		- Indica a opção de validação a ser executada
			xConteudo	- Conteúdo do campo a ser validado
			xConteudo2	- Conteúdo do campo a ser comparado
			xConteudo3	- Conteúdo do campo a ser comparado
			cIDPos		- ID posicionado na Browse

@Return	lRet - Indica se todas as condições foram respeitadas

@Author	Felipe C. Seolin
@Since		25/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ValidRPF( nOpc, xConteudo, xConteudo2, xConteudo3, cIDPos )

Local cID		as character
Local aArea	as array
Local lRet		as logical

cID		:=	""
aArea	:=	{}
lRet	:=	.T.

If nOpc == 1

	If !Empty( xConteudo )
		If Len( AllTrim( xConteudo ) ) <> 36
			cID := xFunCh2ID( xConteudo, "T0J", 2 )
			If !Empty( cID )
				xConteudo := cID
			EndIf
		EndIf

		DBSelectArea( "LE9" )
		LE9->( DBSetOrder( 1 ) )
		If LE9->( MsSeek( xFilial( "LE9" ) + cIDPos + xConteudo ) )

			If C3S->( DBSetOrder( 3 ), C3S->( MsSeek( xFilial( "C3S" ) + PadR( T0J->T0J_TPTRIB, TamSX3( "C3S_ID" )[1] ) ) ) )
				If C3S->C3S_CODIGO $ "19"
					xConteudo2 := T0J->( AllTrim( T0J_CODIGO ) + " - " + AllTrim( T0J_DESCRI ) )
				Else
					MsgInfo( STR0070 ) //"A Reclassificação do Prejuízo Fiscal é aplicável apenas a Contas da Parte B do Tributo IRPJ."
					lRet := .F.
					xConteudo2 := ""
				EndIf
			EndIf
		Else
			MsgInfo( STR0093 ) //"Tributo da Conta da Parte B não cadastrado."
			lRet := .F.
			xConteudo2 := ""
		EndIf
	Else
		MsgInfo( STR0094 ) //"Tributo da Conta da Parte B não informado."
		lRet := .F.
		xConteudo2 := ""
	EndIf

ElseIf nOpc == 2

	aArea := T0S->( GetArea() )

	If !Empty( xConteudo )
		If Len( AllTrim( xConteudo ) ) <> 36
			cID := xFunCh2ID( xConteudo, "T0S", 2 )
			If !Empty( cID )
				xConteudo := cID
			EndIf
		EndIf

		T0S->( DBSetOrder( 1 ) )
		If T0S->( MsSeek( xFilial( "T0S" ) + PadR( xConteudo, TamSX3( "T0S_ID" )[1] ) ) )
			If T0S->T0S_ID == cIDPos
				MsgInfo( STR0081 ) //"Informe uma Conta da Parte B de destino diferente da Conta da Parte B de origem."
				lRet := .F.
				xConteudo2 := ""
			ElseIf T0S->T0S_NATURE <> "3"
				MsgInfo( STR0074 ) //"Conta da Parte B de destino não permitida para este processo. Selecione uma conta com a natureza 'Compensação de Prejuízo/Base de Cálculo Negativa'."
				lRet := .F.
				xConteudo2 := ""
			Else
				If LE9->( MsSeek( xFilial( "LE9" ) + T0S->T0S_ID + PadR( xConteudo3, TamSX3( "LE9_IDCODT" )[1] ) ) )
					xConteudo2 := T0S->( AllTrim( T0S_CODIGO ) + " - " + AllTrim( T0S_DESCRI ) )
				Else
					MsgInfo( STR0095 ) //"Conta da Parte B de destino selecionada não possui o Tributo escolhido."
					lRet := .F.
					xConteudo2 := ""
				EndIf
			EndIf
		Else
			MsgInfo( STR0075 ) //"Conta da Parte B de destino não cadastrada."
			lRet := .F.
			xConteudo2 := ""
		EndIf
	Else
		MsgInfo( STR0076 ) //"Conta da Parte B de destino não informada."
		lRet := .F.
		xConteudo2 := ""
	EndIf

	RestArea( aArea )

ElseIf nOpc == 3

	aArea := T0S->( GetArea() )

	If Empty( xConteudo )
		MsgInfo( STR0077 ) //"Data do Lançamento não informada."
		lRet := .F.
	ElseIf xConteudo < T0S->T0S_DTFINA .or. ( !Empty( T0S->T0S_DTLIMI ) .and. xConteudo > T0S->T0S_DTLIMI )
		MsgInfo( STR0078 ) //"A Data do Lançamento deve estar compreendida entre a Data Final e a Data Limite cadastrada para a Conta da Parte B de origem."
		lRet := .F.
	Else
		T0S->( DBSetOrder( 1 ) )
		If T0S->( MsSeek( xFilial( "T0S" ) + PadR( xConteudo2, TamSX3( "T0S_ID" )[1] ) ) )
			If xConteudo < T0S->T0S_DTFINA .or. ( !Empty( T0S->T0S_DTLIMI ) .and. xConteudo > T0S->T0S_DTLIMI )
				MsgInfo( STR0079 ) //"A Data do Lançamento deve estar compreendida entre a Data Final e a Data Limite cadastrada para a Conta da Parte B de destino."
				lRet := .F.
			EndIf
		EndIf
	EndIf

	RestArea( aArea )

ElseIf nOpc == 4

	If xConteudo <= 0
		MsgInfo( STR0056 ) //"O campo Valor não pode ser preenchido com valor negativo ou zero."
		lRet := .F.
	EndIf

EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GravaRPF

Funcionalidade para gravar a reclassificação do prejuízo fiscal.

@Param		cTributo	- Código do Tributo da Conta da Parte B
			cDescTrib	- Descrição do Tributo da Conta da Parte B
			cIDPos		- ID posicionado na Browse
			cContaDest	- Código da Conta da Parte B de destino
			cDescConta	- Descrição da Conta da Parte B de destino
			dData		- Data do Lançamento
			nValor		- Valor do Lançamento
			cHistorico	- Histórico do Lançamento

@Author	Felipe C. Seolin
@Since		25/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function GravaRPF( cTributo, cDescTrib, cIDPos, cContaDest, cDescConta, dData, nValor, cHistorico )

Local cAliasQry	as character
Local cQuery		as character
Local cCodLan		as character
Local cCodLanOri	as character
Local cCodLanDes	as character
Local cTipoLanc	as character
Local nI			as numeric
Local nSaldo		as numeric
Local aDados		as array
Local aGrava		as array
Local aLogOk		as array
Local aLogErro	as array
Local aAreaT0S	as array
Local aAreaLE9	as array

cAliasQry	:=	""
cQuery		:=	""
cCodLan	:=	""
cCodLanOri	:=	""
cCodLanDes	:=	""
cTipoLanc	:=	""
nI			:=	0
nSaldo		:=	0
aDados		:=	{}
aGrava		:=	{}
aLogOk		:=	{}
aLogErro	:=	{}
aAreaT0S	:=	T0S->( GetArea() )
aAreaLE9	:=	LE9->( GetArea() )

aAdd( aDados, { "ORIGEM"		, cIDPos		, cContaDest } )
aAdd( aDados, { "DESTINO"	, cContaDest	, cIDPos } )

DBSelectArea( "T0S" )
T0S->( DBSetOrder( 1 ) )

For nI := 1 to Len( aDados )

	cTipoLanc := Iif( aDados[nI,1] == "ORIGEM", "2", "1" )

	If T0S->( MsSeek( xFilial( "T0S" ) + aDados[nI,2] ) )

		If LE9->( MsSeek( xFilial( "LE9" ) + T0S->T0S_ID + cTributo ) )

			cAliasQry := GetNextAlias()

			BeginSql Alias cAliasQry
				SELECT MAX( T0T.T0T_CODLAN ) T0T_CODLAN
				FROM %table:T0T% T0T
				WHERE T0T.T0T_FILIAL = %xFilial:T0T%
					AND T0T.T0T_ID = %Exp:T0S->T0S_ID%
					AND T0T.T0T_IDCODT = %Exp:cTributo%
					AND T0T.%notDel%
			EndSql

			cCodLan := ( cAliasQry )->T0T_CODLAN

			( cAliasQry )->( DBCloseArea() )

			cCodLan := Soma1( cCodLan )

			If aDados[nI,1] == "ORIGEM"
				cCodLanOri := cCodLan
			Else
				cCodLanDes := cCodLan
			EndIf

			nSaldo := RetSaldo( LE9->LE9_VLSDAT, "4", cTipoLanc, nValor )

			If nSaldo < 0
				aAdd( aLogErro, { T0S->T0S_CODIGO, cTributo, cCodLan, dData, nValor, cTipoLanc, STR0009 } ) //"O saldo da conta ficará negativo com a efetivação deste lançamento."
				Exit
			Else
				aAdd( aGrava, { aDados[nI,1], T0S->T0S_CODIGO, T0S->T0S_ID, cCodLan, cTipoLanc, aDados[nI,3], LE9->( Recno() ), nSaldo } )
			EndIf

		EndIf

	Else
		aAdd( aLogErro, { aDados[nI,2], cTributo, "XXXXXX", dData, nValor, cTipoLanc, STR0080 } ) //"Conta da Parte B não cadastrada."
		Exit
	EndIf

Next nI

For nI := 1 to Len( aGrava )

	LE9->( DBGoTo( aGrava[nI,7] ) )
	If RecLock( "LE9", .F. )
		LE9->LE9_VLSDAT := aGrava[nI,8]
		LE9->( MsUnlock() )
	EndIf

	If RecLock( "T0T", .T. )
		T0T->T0T_FILIAL	:=	xFilial( "T0T" )
		T0T->T0T_ID		:=	aGrava[nI,3]
		T0T->T0T_IDCODT	:=	cTributo
		T0T->T0T_CODLAN	:=	aGrava[nI,4]
		T0T->T0T_DTLANC	:=	dData
		T0T->T0T_VLLANC	:=	nValor
		T0T->T0T_TPLANC	:=	aGrava[nI,5]
		T0T->T0T_INDDIF	:=	"2"
		T0T->T0T_HISTOR	:=	cHistorico
		T0T->T0T_ORIGEM	:=	"3"
		T0T->T0T_CTDEST	:=	aGrava[nI,6] + cTributo + Iif( aGrava[nI,1] == "ORIGEM", cCodLanDes, cCodLanOri )
		T0T->( MsUnlock() )
	EndIf

	aAdd( aLogOk, { aGrava[nI,2], cTributo, aGrava[nI,4], dData, nValor, aGrava[nI,5] } )
Next nI

If !Empty( aLogOk ) .or. !Empty( aLogErro )
	ShowLog( aLogOk, aLogErro )
Else
	MsgInfo( STR0061 ) //"Não foram processados lançamentos!"
EndIf

RestArea( aAreaT0S )
RestArea( aAreaLE9 )

Return()

/*/{Protheus.doc} TAFA436SaldoAnt
Retorna o Saldo anterior de uma conta da Parte B do LALUR
@author david.costa
@since 08/05/2017
@version 1.0
@param cIdTributo, caracter, Id do Tributo
@param cIdConta, caracter, Id da Conta da Parte B
@param dData, date, Data de referência para o saldo
@return ${nSaldo}, ${Saldo da Conta}
@example
TAFA436SaldoAnt( cIdTributo, cIdConta, dData )
/*/Function TAFA436SaldoAnt( cIdTributo, cIdConta, dData )

Local nSaldo		as numeric

nSaldo := Posicione( "LE9", 1, xFilial( "LE9" ) + cIdConta + cIdTributo, AllTrim( "LE9_VLSDIN" ) )

Return( nSaldo )

/*/{Protheus.doc} GetMovConta
Realiza uma consulta no Banco de Dados com os dados de movimentação de uma determinada conta
@author david.costa
@since 08/05/2017
@version 1.0
@param cIdTributo, caracter, Id do Tributo
@param cIdConta, caracter, Id da Conta da Parte B
@param dData, date, Data de referência para o saldo
@return ${cAliasQry}, ${Resultado da consulta no banco}
@example
GetMovConta( cIdTributo, cIdConta, dData )
/*/Static Function GetMovConta( cIdTributo, cIdConta, dData )

Local cAliasQry	as character
Local cSelect		as character
Local cFrom		as character
Local cWhere		as character
Local cGroupBy	as character

cAliasQry	:= GetNextAlias()
cGroupBy	:= ""
cWhere		:= ""
cFrom		:= ""
cSelect	:= ""

cSelect	:= " SUM(T0T.T0T_VLLANC) VALOR, T0T.T0T_TPLANC, T0S.T0S_NATURE, LE9.LE9_VLSDIN SALDO_INICIAL "
cFrom		:= RetSqlName( "T0S" ) + " T0S "
cFrom		+= " JOIN " + RetSqlName( "LE9" ) + " LE9 "
cFrom		+= " 	ON LE9.LE9_ID = T0S.T0S_ID AND LE9.D_E_L_E_T_ = '' "
cFrom		+= " JOIN " + RetSqlName( "T0T" ) + " T0T "
cFrom		+= " 	ON T0T.T0T_ID = T0S_ID AND T0T.T0T_IDCODT = LE9.LE9_IDCODT AND T0T.D_E_L_E_T_ = '' "
cWhere		:= " T0S.D_E_L_E_T_ = '' "
cWhere		+= " AND T0S.T0S_FILIAL = '" + xFilial( "T0S" ) + "' "
cWhere		+= " AND LE9.LE9_IDCODT ='" + cIdTributo + "' "
cWhere		+= " AND T0S.T0S_ID ='" + cIdConta + "' "
cWhere		+= " AND T0T.T0T_DTLANC < '" + DToS( dData ) + "' "
cGroupBy	:= " T0T.T0T_TPLANC, T0S.T0S_NATURE, LE9.LE9_VLSDIN "

cSelect	:= "%" + cSelect 	+ "%"
cFrom  	:= "%" + cFrom   	+ "%"
cWhere 	:= "%" + cWhere  	+ "%"
cGroupBy 	:= "%" + cGroupBy	+ "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
	GROUP BY
		%Exp:cGroupBy%
EndSql

DBSelectArea( cAliasQry )
( cAliasQry )->( DbGoTop() )
		
Return( cAliasQry )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF436Saldo

Calcula saldo inicial da conta de acordo com parâmetros indicados

@Param	cIDConta	-	ID Código da Conta
		cIDTributo	-	ID Tributo da Conta
		dIniPer		-	Início do Período para referência
		cNatureza	-	Natureza da Conta
		nSaldoIni	-	Saldo Inicial da Conta 

@Return	nSaldo		-	Saldo da conta de acordo com datas de referência

@Author		Felipe C. Seolin
@Since		06/06/2017
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAF436Saldo( cIDConta, cIDTributo, dIniPer, cNatureza, nSaldoIni, cQryAux, cTamPer )

Local cAliasQry	as character
Local cSelect	as character
Local cFrom		as character
Local cWhere	as character
Local cOrderBy	as character
Local nSaldo	as numeric

cAliasQry	:=	GetNextAlias()
cSelect		:=	""
cFrom		:=	""
cWhere		:=	""
cOrderBy	:=	""
nSaldo		:=	0

cSelect		:= "T0T.T0T_TPLANC, T0T.T0T_VLLANC "

cFrom		:= RetSqlName( "T0S" ) + " T0S "

cFrom		+= "INNER JOIN " + RetSqlName( "LE9" ) + " LE9 " 
cFrom		+= "   ON LE9.LE9_FILIAL = T0S.T0S_FILIAL "
cFrom		+= "  AND LE9.LE9_ID = T0S.T0S_ID "
cFrom		+= "  AND LE9.LE9_IDCODT = '" + cIDTributo + "' "
cFrom		+= "  AND LE9.D_E_L_E_T_ = '' "

cFrom		+= "INNER JOIN " + RetSqlName( "T0T" ) + " T0T "
cFrom		+= "   ON T0T.T0T_FILIAL = LE9.LE9_FILIAL "
cFrom		+= "  AND T0T.T0T_ID = LE9.LE9_ID "
cFrom		+= "  AND T0T.T0T_IDCODT = LE9.LE9_IDCODT "
cFrom 		+= "  AND " + cQryAux + "( T0T.T0T_DTLANC, 1, " + cTamPer + " ) < '" + left(dtos(dIniPer),val(cTamPer)) + "' "

/*
If Upper( AllTrim( TCGetDB() ) ) == "ORACLE"
	cFrom		+= "  AND SUBSTR( T0T.T0T_DTLANC, 1, 4 ) < '" + AllTrim( Str( Year( dIniPer ) ) ) + "' "
Else
	cFrom		+= "  AND SUBSTRING( T0T.T0T_DTLANC, 1, 4 ) < '" + AllTrim( Str( Year( dIniPer ) ) ) + "' "
EndIf
*/

cFrom		+= "  AND T0T.D_E_L_E_T_ = ' ' "

cWhere		:= "    T0S.T0S_FILIAL = '" + xFilial( "T0S" ) + "' "
cWhere		+= "AND T0S.T0S_ID = '" + cIDConta + "' "
cWhere		+= "AND T0S.D_E_L_E_T_ = '' "

cOrderBy	:= "T0T.T0T_DTLANC "

cSelect		:= "%" + cSelect	+ "%"
cFrom		:= "%" + cFrom		+ "%"
cWhere		:= "%" + cWhere		+ "%"
cOrderBy	:= "%" + cOrderBy	+ "%"

BeginSql Alias cAliasQry
	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
	ORDER BY
		%Exp:cOrderBy%
EndSql

nSaldo := nSaldoIni

While ( cAliasQry )->( !Eof() ) 
	nSaldo := RetSaldo( nSaldo, cNatureza, ( cAliasQry )->T0T_TPLANC, ( cAliasQry )->T0T_VLLANC )
	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return( nSaldo )


/*---------------------------------------------------------------------
{Protheus.doc} VldSldLE9

Valida e grava o indice do saldo atual dos tributos da parte B

@Param		cTributo	- Model do Tributo LE9
			cDescTrib	- Saldo do tributo
@Author	Carlos Eduardo Silva
@Since		04/05/2021
@Version	1.0
---------------------------------------------------------------------*/
Static function VldSldLE9(oModelLE9, nSaldo)
Local lRet 		:= .t.
Local cNature	:= FwFldGet('T0S_NATURE')
Local cIndIni 	:= ""
Local lIndSld	:= TAFColumnPos( "LE9_ISLDIN" ) .and. TAFColumnPos( "LE9_ISLDAT" ) //Proteção do fonte - DSERTAF2-12189

if lIndSld; cIndIni := FwFldGet('LE9_ISLDIN',); endif

if nSaldo < 0
	if !lIndSld .or. cNature != '5'
		lRet := .F.
	else
		cIndAtu := iif( cIndIni == '1','2','1') 
		oModelLE9:SetValue('LE9_ISLDAT',cIndAtu)
	endif	
else
	if lIndSld; oModelLE9:SetValue('LE9_ISLDAT', cIndIni ); endif
endif 		

return lRet


/*---------------------------------------------------------------------
{Protheus.doc} GrpConsSld

Retorna qual foi o grupo que gerou a constituicao de saldo na conta PB

@Param		cIdDet	- ID + SEQUENCIA da tabela CWX

@Author	Carlos Eduardo Silva
@Since		16/07/2021
@Version	1.0
---------------------------------------------------------------------*/
Function GrpConsSld(cIdDet)
Local cRet 		:= ''
Local cIdCWX	:= substr( cIdDet, 1, len(cIdDet)-6 ) 
Local cSeqItCWX	:= right( cIdDet, 6)
Local cQuery	:= ''
Local cAliasQry := GetNextAlias()

cQuery += " SELECT "
cQuery += " 	LEE.LEE_CODIGO "
cQuery += " FROM " + RetSqlName('CWX') + " CWX "
cQuery += " 	INNER JOIN " + RetSqlName('LEE') + " LEE ON LEE.LEE_FILIAL = '" + xFilial('LEE') + "' AND LEE.LEE_ID = CWX.CWX_IDCODG AND LEE.D_E_L_E_T_ = ' ' "
cQuery += " WHERE CWX.D_E_L_E_T_ = ' ' "
cQuery += "		AND CWX_FILIAL = '" + xFilial('CWX') + "' "
cQuery += " 	AND CWX.CWX_ID = '" + cIdCWX + "'	"
cQuery += " 	AND CWX.CWX_SEQDET = '" + cSeqItCWX + "' " 
dbUseArea( .t.,'TOPCONN', TcGenQry(,,cQuery ),cAliasQry,.f.,.t.)
if (cAliasQry)->(!eof()); cRet := (cAliasQry)->LEE_CODIGO; endif
(cAliasQry)->(DbCloseArea())

return cRet
