#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA438.CH"

//Forma de Tributa��o
#DEFINE TRIBUTACAO_LUCRO_REAL						"000001" //Lucro Real
#DEFINE TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO		"000002" //Lucro Real - Estimativa por Levantamento de Balan�o
#DEFINE TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA	"000003" //Lucro Real - Estimativa por Receita Bruta
#DEFINE TRIBUTACAO_LUCRO_REAL_ATIV_RURAL			"000004" //Lucro Real - Atividade Rural
#DEFINE TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO			"000005" //Lucro Real - Lucro da Explora��o
#DEFINE TRIBUTACAO_LUCRO_PRESUMIDO					"000006" //Lucro Presumido
#DEFINE TRIBUTACAO_LUCRO_ARBITRADO					"000007" //Lucro Arbitrado
#DEFINE TRIBUTACAO_IMUNE								"000008" //Imune
#DEFINE TRIBUTACAO_ISENTA							"000009" //Isenta

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA438

Cadastro de Vig�ncia do Evento Tribut�rio.

@Author	Felipe C. Seolin
@Since		21/07/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAFA438()

Local oBrowse	as object

Private cLEL_DCODEV	as character
Private cLEL_IDCODE	as character

oBrowse	:=	FWmBrowse():New()

cLEL_DCODEV	:=	""
cLEL_IDCODE	:=	""

If TAFAlsInDic( "LEL" )
	oBrowse:SetDescription( STR0001 ) //"Cadastro de Vig�ncia do Evento Tribut�rio"
	oBrowse:SetAlias( "LEL" )
	oBrowse:SetCacheView( .F. )
	oBrowse:SetMenuDef( "TAFA438" )

	LEL->( DBSetOrder( 2 ) )

	oBrowse:Activate()
Else
	Aviso( STR0002, TafAmbInvMsg(), { STR0003 }, 2 ) //##"Dicion�rio Incompat�vel" ##"Encerrar"
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Fun��o gen�rica MVC com as op��es de menu.

@Return	aRotina - Array com as op��es de menu.

@Author	Felipe C. Seolin
@Since		21/07/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

Local nPos		as numeric
Local aRotina	as array

nPos		:=	0
aRotina	:=	xFunMnuTAF( "TAFA438" )

If ( nPos := aScan( aRotina, { |x| AllTrim( x[1] ) == STR0008 } ) ) > 0 //"Visualizar"
	aRotina[nPos,2] := "TAF438Pre( 'Visualizar' )"
EndIf

If ( nPos := aScan( aRotina, { |x| AllTrim( x[1] ) == STR0009 } ) ) > 0 //"Incluir"
	aRotina[nPos,2] := "TAF438Pre( 'Incluir' )"
EndIf

If ( nPos := aScan( aRotina, { |x| AllTrim( x[1] ) == STR0010 } ) ) > 0 //"Alterar"
	aRotina[nPos,2] := "TAF438Pre( 'Alterar' )"
EndIf

If ( nPos := aScan( aRotina, { |x| AllTrim( x[1] ) == STR0011 } ) ) > 0 //"Excluir"
	aRotina[nPos,2] := "TAF438Pre( 'Excluir' )"
EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF438Pre

Executa pr�-condi��es para a opera��o desejada.

@Param		cOper		-	Indica a opera��o a ser executada
			cRotina	-	Indica a rotina a ser executada

@Author	Felipe C. Seolin
@Since		28/11/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAF438Pre( cOper, cRotina )

Local nOperation	as numeric

Default cRotina	:=	"TAFA438"

nOperation	:=	MODEL_OPERATION_VIEW

//De-Para de op��es do Menu para a opera��es em MVC
If Upper( cOper ) == Upper( "Visualizar" )
	nOperation := MODEL_OPERATION_VIEW
ElseIf Upper( cOper ) == Upper( "Incluir" )
	nOperation := MODEL_OPERATION_INSERT
ElseIf Upper( cOper ) == Upper( "Alterar" )
	nOperation := MODEL_OPERATION_UPDATE
ElseIf Upper( cOper ) == Upper( "Excluir" )
	nOperation := MODEL_OPERATION_DELETE
Else
	nOperation := 0
EndIf

//� permitido o uso do cadastro apenas se for executado em Filial Matriz ou SCP.
//Caso contr�rio, apenas ser� permitido a Visualiza��o do referido cadastro.
If TAFColumnPos( "C1E_MATRIZ" ) .and. GrantAccess()

	FWExecView( cOper, cRotina, nOperation )

Else

	If nOperation == MODEL_OPERATION_VIEW
		FWExecView( cOper, cRotina, nOperation )
	Else
		MsgInfo( STR0006 ) //"Apenas Filial Matriz ou Filial SCP possui permiss�o de manipula��o do cadastro."
	EndIf

EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef

Fun��o gen�rica MVC do modelo.

@Return	oModel - Objeto do modelo MVC

@Author	Felipe C. Seolin
@Since		21/07/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

Local oStruLEL	as object
Local oModel		as object

oStruLEL	:=	FWFormStruct( 1, "LEL" )
oModel		:=	MPFormModel():New( "TAFA438",, { |oModel| ValidModel( oModel ) } )

If !CanUpdate()
	oStruLEL:SetProperty( "*", MODEL_FIELD_WHEN, { || .F. } )
	oStruLEL:SetProperty( "LEL_DTFIN", MODEL_FIELD_WHEN, { || .T. } )
EndIf

oModel:AddFields( "MODEL_LEL", /*cOwner*/, oStruLEL )
oModel:GetModel( "MODEL_LEL" ):SetPrimaryKey( { "LEL_DTINI", "LEL_DTFIN", "LEL_CODTBT" } )

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Fun��o gen�rica MVC da view.

@Return	oView - Objeto da view MVC

@Author	Felipe C. Seolin
@Since		21/07/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

Local oModel		as object
Local oView		as object
Local oStruLEL	as object

oModel		:=	FWLoadModel( "TAFA438" )
oView		:=	FWFormView():New()
oStruLEL	:=	FWFormStruct( 2, "LEL" )

oView:SetModel( oModel )

oView:AddField( "VIEW_LEL", oStruLEL, "MODEL_LEL" )
oView:EnableTitleView( "VIEW_LEL", STR0001 ) //"Cadastro de Vig�ncia do Evento Tribut�rio"

oView:CreateHorizontalBox( "FIELDSLEL", 100 )
oView:SetOwnerView( "VIEW_LEL", "FIELDSLEL" )

oStruLEL:RemoveField( "LEL_ID" )
oStruLEL:RemoveField( "LEL_IDCODE" )
oStruLEL:RemoveField( "LEL_IDCODT" )

Return( oView )

//---------------------------------------------------------------------
/*/{Protheus.doc} GrantAccess

Fun��o para verificar a permiss�o de manipula��o do cadastro.

@Return	lRet - Indica se possui permiss�o

@Author	Felipe C. Seolin
@Since		30/09/2016
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
/*/{Protheus.doc} TAF438Chave

Funcionalidade para valida��o do campo.

@Return	lRet - Indica se todas as condi��es foram respeitadas

@Author	Felipe C. Seolin
@Since		22/07/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAF438Chave()

Local oModel		as object
Local cCampo		as character
Local cAliasQry	as character
Local cSelect		as character
Local cFrom		as character
Local cWhere		as character
Local cDtIni		as character
Local cDtFin		as character
Local cTributo	as character
Local cFTrib		as character
Local cFTribAux	as character
Local lRet			as logical

oModel		:=	FWModelActive()
cCampo		:=	SubStr( ReadVar(), At( ">", ReadVar() ) + 1 )
cAliasQry	:=	""
cSelect	:=	""
cFrom		:=	""
cWhere		:=	""
cDtIni		:=	""
cDtFin		:=	""
cTributo	:=	""
cFTrib		:=	""
cFTribAux	:=	""
lRet		:=	.T.

cLEL_DCODEV := Iif( Type( "cLEL_DCODEV" ) == "U", "", cLEL_DCODEV )
cLEL_IDCODE := Iif( Type( "cLEL_IDCODE" ) == "U", "", cLEL_IDCODE )

If Type( "cLEL_IDCODE" ) <> "U"
	cFTrib := xFunID2Cd( Posicione( "T0N", 1, xFilial( "T0N" ) + FWFldGet( "LEL_IDCODE" ), "T0N_IDFTRI" ), "T0K", 1 )
EndIf

If cCampo == "LEL_DTINI"
	cDtIni		:=	DToS( M->LEL_DTINI )
	cDtFin		:=	DToS( FWFldGet( "LEL_DTFIN" ) )
	cTributo	:=	Posicione( "T0J", 2, xFilial( "T0J" ) + FWFldGet( "LEL_CODTBT" ), "T0J_ID" )
ElseIf cCampo == "LEL_DTFIN"
	cDtIni		:=	DToS( FWFldGet( "LEL_DTINI" ) )
	cDtFin		:=	DToS( M->LEL_DTFIN )
	cTributo	:=	Posicione( "T0J", 2, xFilial( "T0J" ) + FWFldGet( "LEL_CODTBT" ), "T0J_ID" )
ElseIf cCampo == "LEL_CODTBT"
	cDtIni		:=	DToS( FWFldGet( "LEL_DTINI" ) )
	cDtFin		:=	DToS( FWFldGet( "LEL_DTFIN" ) )
	cTributo	:=	Posicione( "T0J", 2, xFilial( "T0J" ) + M->LEL_CODTBT, "T0J_ID" )
EndIf

If !Empty( cDtIni ) .and. !Empty( cDtFin ) .and. !Empty( cTributo )

	cSelect := " LEL_DTINI, LEL_DTFIN, LEL_DESCRI, LEL_IDCODE "

	cFrom := RetSqlName( "LEL" ) + " LEL "

	cWhere := "      LEL.LEL_FILIAL = '" + xFilial( "LEL" ) + "' "
	cWhere += "  AND LEL_IDCODT = '" + cTributo + "' "
	If !INCLUI
		cWhere += "  AND LEL.R_E_C_N_O_ <> '" + AllTrim( Str( LEL->( Recno() ) ) ) + "' "
	EndIf
	cWhere += "  AND LEL.D_E_L_E_T_ = '' "

	cSelect  := "%" + cSelect  + "%"
	cFrom    := "%" + cFrom    + "%"
	cWhere   := "%" + cWhere   + "%"

	cAliasQry := GetNextAlias()

	BeginSql Alias cAliasQry

		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%

	EndSql

	While ( cAliasQry )->( !Eof() )

		cFTribAux := xFunID2Cd( Posicione( "T0N", 1, xFilial( "T0N" ) + ( cAliasQry )->LEL_IDCODE, "T0N_IDFTRI" ), "T0K", 1 )

		If	(;
				(;
					( ( cAliasQry )->LEL_DTINI >= cDtIni .and. ( cAliasQry )->LEL_DTINI <= cDtFin ) .or.;
					( ( cAliasQry )->LEL_DTFIN >= cDtIni .and. ( cAliasQry )->LEL_DTFIN <= cDtFin ) .or.;
					( cDtIni >= ( cAliasQry )->LEL_DTINI .and. cDtIni <= ( cAliasQry )->LEL_DTFIN ) .or.;
					( cDtFin >= ( cAliasQry )->LEL_DTINI .and. cDtFin <= ( cAliasQry )->LEL_DTFIN );
				) .and.;
				(;
					( cFTrib == cFTribAux ) .or.;
					( cFTribAux <> TRIBUTACAO_LUCRO_REAL .and. cFTribAux <> TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .and. cFTribAux <> TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA );
				);
			)

			Help( ,, "HELP",, STR0004, 1, 0 ) //"J� existe um cadastro na base de dados para o per�odo e tributo informados."
			lRet := .F.
		EndIf
		( cAliasQry )->( DBSkip() )
	EndDo

	( cAliasQry )->( DBCloseArea() )

EndIf

If cCampo == "LEL_CODEVE"
	cLEL_DCODEV := oModel:GetValue( "MODEL_LEL", "LEL_DCODEV" )
	cLEL_IDCODE := oModel:GetValue( "MODEL_LEL", "LEL_IDCODE" )
ElseIf cCampo == "LEL_CODTBT" .and. !lRet
	oModel:LoadValue( "MODEL_LEL", "LEL_DCODEV", cLEL_DCODEV )
	oModel:LoadValue( "MODEL_LEL", "LEL_IDCODE", cLEL_IDCODE )
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF438Valid

Funcionalidade para valida��o do campo.

@Return	lRet - Indica se todas as condi��es foram respeitadas

@Author	Felipe C. Seolin
@Since		22/07/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAF438Valid()

Local cCampo	as character
Local lRet		as logical

cCampo	:=	SubStr( ReadVar(), At( ">", ReadVar() ) + 1 )
lRet	:=	.T.

If cCampo == "LEL_CODEVE"

	//Filtro para n�o ser exibido os c�digos "000004" e "000005" referentes a Atividade Rural e Lucro da Explora��o
	DBSelectArea( "T0N" )
	T0N->( DBSetOrder( 2 ) )
	If T0N->( MsSeek( xFilial( "T0N" ) + M->LEL_CODEVE ) )
		DBSelectArea( "T0K" )
		T0K->( DBSetOrder( 1 ) )
		If T0K->( MsSeek( xFilial( "T0K" ) + T0N->T0N_IDFTRI ) )
			If T0K->T0K_CODIGO $ "000004|000005"
				Help( ,, "HELP",, STR0005, 1, 0 ) //"Evento Tribut�rio n�o permitido para este cadastro."
				lRet := .F.
			EndIf
		EndIf
	EndIf

EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} CanUpdate

Verifica se o cadastro pode ser sofrer altera��es.

@Return	lCan - Indica se o cadastro pode ser alterado

@Author	David Costa
@Since		06/12/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function CanUpdate()

Local lCan	as logical

lCan	:=	.T.

//Dicion�rio do cadastro do Per�odo
If TAFAlsInDic( "CWV" ) .and. ( Type( "INCLUI" ) <> "U" .and. !INCLUI )
	DBSelectArea( "CWV" )
	CWV->( DBSetOrder( 6 ) )
	//Se o Evento relacionado na Vig�cia estiver em uso por algum Per�odo de Apura��o, o Cadastro de Vig�ncia n�o pode ser alterado
	If CWV->( MsSeek( xFilial( "CWV" ) + LEL->LEL_IDCODE ) )
		While CWV->( !Eof() ) .and. CWV->( CWV_FILIAL + CWV_IDEVEN ) == ( xFilial( "CWV" ) + LEL->LEL_IDCODE )
			If CWV->CWV_INIPER >= LEL->LEL_DTINI .and. CWV->CWV_FIMPER <= LEL->LEL_DTFIN .and. ( ProcName( 1 ) == "MODELDEF" .or. FWFldGet( "LEL_DTFIN" ) < CWV->CWV_FIMPER )
				lCan := .F.
			EndIf
			CWV->( DBSkip() )
		EndDo
	EndIf
EndIf

Return( lCan )

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidModel

Fun��o de valida��o dos dados do modelo.

@Param		oModel	- Modelo de dados

@Return	lRet	- Indica se o modelo � v�lido para grava��o

@Author	David Costa
@Since		06/12/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ValidModel( oModel )

Local cLogValid	as character
Local lRet			as logical

cLogValid	:=	""
lRet		:=	.T.

If !CanUpdate() .and. oModel:GetOperation() <> MODEL_OPERATION_VIEW
	MsgInfo( STR0007 ) //"Este cadastro est� em uso por um ou mais Per�odos de Apura��o e n�o pode ser modificado com o Per�odo encerrado."
	lRet := .F.
EndIf

Return( lRet )