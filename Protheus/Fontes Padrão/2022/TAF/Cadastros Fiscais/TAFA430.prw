#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA430.CH"

//Tributos
#DEFINE TRIBUTO_IRPJ		'000019'
#DEFINE TRIBUTO_CSLL		'000018'
//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA430

Cadastro de Tributos.

@Author	Felipe C. Seolin
@Since		07/03/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAFA430()

Local oBrowse	as object

oBrowse	:=	FWmBrowse():New()

If TAFAlsInDic( "T0J" )

	oBrowse:SetDescription( STR0001 ) //"Cadastro de Tributos"
	oBrowse:SetAlias( "T0J" )
	oBrowse:SetCacheView( .F. )
	oBrowse:SetMenuDef( "TAFA430" )

	T0J->( DBSetOrder( 2 ) )

	oBrowse:Activate()
Else
	Aviso( STR0009, TafAmbInvMsg(), { STR0010 }, 2 ) //##"Dicionário Incompatível" ##"Encerrar"
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Função genérica MVC com as opções de menu.

@Return	aRotina - Array com as opções de menu.

@Author	Felipe C. Seolin
@Since		07/03/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

Local nPos		as numeric
Local aRotina	as array

nPos		:=	0
aRotina	:=	xFunMnuTAF( "TAFA430" )

If ( nPos := aScan( aRotina, { |x| AllTrim( x[1] ) == STR0011 } ) ) > 0 //"Visualizar"
	aRotina[nPos,2] := "TAF430Pre( 'Visualizar' )"
EndIf

If ( nPos := aScan( aRotina, { |x| AllTrim( x[1] ) == STR0012 } ) ) > 0 //"Incluir"
	aRotina[nPos,2] := "TAF430Pre( 'Incluir' )"
EndIf

If ( nPos := aScan( aRotina, { |x| AllTrim( x[1] ) == STR0013 } ) ) > 0 //"Alterar"
	aRotina[nPos,2] := "TAF430Pre( 'Alterar' )"
EndIf

If ( nPos := aScan( aRotina, { |x| AllTrim( x[1] ) == STR0014 } ) ) > 0 //"Excluir"
	aRotina[nPos,2] := "TAF430Pre( 'Excluir' )"
EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF430Pre

Executa pré-condições para a operação desejada.

@Param		cOper		-	Indica a operação a ser executada
			cRotina	-	Indica a rotina a ser executada

@Author	Felipe C. Seolin
@Since		23/11/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAF430Pre( cOper, cRotina )

Local nOperation	as numeric
Local aButtons	as array
Local lOk			as logical

Private cIDTrib	as character

Default cRotina	:=	"TAFA430"

nOperation	:=	MODEL_OPERATION_VIEW
aButtons	:=	{}
lOk			:=	.F.

cIDTrib	:=	""

//De-Para de opções do Menu para a operações em MVC
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

If nOperation == MODEL_OPERATION_INSERT

	aAdd( aButtons, { 1, .T., { |x| lOk := .T., x:oWnd:End() } } )
	aAdd( aButtons, { 2, .T., { |x| x:oWnd:End() } } )

	If PergTAF( cRotina, STR0002, { STR0003 }, aButtons, { || .T. },,, .F. ) .and. lOk //##"Parâmetros..." ##"Tributos"
		cIDTrib := MV_PAR01
		If !Empty( cIDTrib )
			
			If ( cIDTrib == TRIBUTO_IRPJ .or. cIDTrib == TRIBUTO_CSLL )
				FWExecView( cOper, cRotina, nOperation )
			Else
				MsgInfo( "Tributo inválido" ) 
			EndIf
			
		Else
				MsgInfo( "Tributo não informado" )
		EndIf
		
	Else
		cIDTrib := "CANCEL"
		MsgInfo( STR0004 ) //"É necessário informar o Tributo para definição das informações a serem exibidas no cadastro."
	EndIf

Else

	cIDTrib := ""
	FWExecView( cOper, cRotina, nOperation )

EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef

Função genérica MVC do modelo.

@Return	oModel - Objeto do modelo MVC

@Author	Felipe C. Seolin
@Since		07/03/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

Local oStruT0J	as object
Local oModel		as object

oStruT0J	:=	FWFormStruct( 1, "T0J" )
oModel		:=	MPFormModel():New( "TAFA430",, { |oModel| ValidModel( oModel ) } )

oModel:AddFields( "MODEL_T0J", /*cOwner*/, oStruT0J )
oModel:GetModel( "MODEL_T0J" ):SetPrimaryKey( { "T0J_CODIGO" } )

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Função genérica MVC da view.

@Return	oView - Objeto da view MVC

@Author	Felipe C. Seolin
@Since		07/03/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

Local oModel		as object
Local oView		as object
Local oStruT0Ja	as object
Local oStruT0Jb	as object
Local cTributo	as character
Local cIRPJ		as character
Local cCSLL		as character
Local cCmpFil		as character
Local aAreaC3S	as array

oModel		:=	FWLoadModel( "TAFA430" )
oView		:=	FWFormView():New()
oStruT0Ja	:=	Nil //Estrutura para campos comuns dos tributos
oStruT0Jb	:=	Nil //Estrutura para campos específicos dos tributos
cTributo	:=	""
cIRPJ		:=	"T0J_ALADIR|T0J_PARCIS|T0J_ALIQL1|T0J_DALIQ1|T0J_ALIQL2|T0J_DALIQ2|T0J_ALIQL3|T0J_DALIQ3|T0J_ALIQL4|T0J_DALIQ4|"
cCSLL		:=	"T0J_ALIQL1|T0J_DALIQ1|T0J_ALIQL2|T0J_DALIQ2|T0J_ALIQL3|T0J_DALIQ3|T0J_ALIQL4|T0J_DALIQ4|"
cCmpFil	:=	cIRPJ + cCSLL //Filtro de campos específicos dos tributos
aAreaC3S	:=	C3S->( GetArea() )

//Inicialização de variáveis Private para não gerar erro em
//chamadas diretas da View, por exemplo via Consulta Padrão
cIDTrib := Iif( Type( "cIDTrib" ) == "U", "", cIDTrib )

If !Empty( cIDTrib )
	If cIDTrib == "CANCEL"
		cTributo := ""
	Else
		C3S->( DBSetOrder( 3 ) )

		If C3S->( MsSeek( xFilial( "C3S" ) + PadR( cIDTrib, TamSX3( "C3S_ID" )[1] ) ) )
			cTributo := C3S->C3S_CODIGO
		EndIf
	EndIf
Else
	C3S->( DBSetOrder( 3 ) )

	If C3S->( MsSeek( xFilial( "C3S" ) + PadR( T0J->T0J_TPTRIB, TamSX3( "C3S_ID" )[1] ) ) )
		cTributo := C3S->C3S_CODIGO
	EndIf
EndIf

RestArea( aAreaC3S )

oView:SetModel( oModel )

oStruT0Ja := FWFormStruct( 2, "T0J", { |x| !( AllTrim( x ) $ cCmpFil ) } ) //Estrutura para campos comuns dos tributos
oView:AddField( "VIEW_T0Ja", oStruT0Ja, "MODEL_T0J" )
oView:EnableTitleView( "VIEW_T0Ja", STR0005 ) //"Dados do Tributo"

If cTributo == "19" //IRPJ
	oStruT0Jb := FWFormStruct( 2, "T0J", { |x| AllTrim( x ) $ cIRPJ } ) //Estrutura para campos específicos do tributo IRPJ
	oView:AddField( "VIEW_T0Jb", oStruT0Jb, "MODEL_T0J" )
	oView:EnableTitleView( "VIEW_T0Jb", STR0006 ) //"Informações de específicas IRPJ"
ElseIf cTributo == "18"  //CSLL
	oStruT0Jb := FWFormStruct( 2, "T0J", { |x| AllTrim( x ) $ cCSLL } ) //Estrutura para campos específicos do tributo CSLL
	oView:AddField( "VIEW_T0Jb", oStruT0Jb, "MODEL_T0J" )
	oView:EnableTitleView( "VIEW_T0Jb", STR0007 ) //"Informações de específicas CSLL"
EndIf

oView:CreateHorizontalBox( "FIELDST0Ja", 40 )
oView:SetOwnerView( "VIEW_T0Ja", "FIELDST0Ja" )

If oStruT0Jb <> Nil
	oView:CreateHorizontalBox( "FIELDST0Jb", 60 )
	oView:SetOwnerView( "VIEW_T0Jb", "FIELDST0Jb" )
EndIf

oStruT0Ja:RemoveField( "T0J_ID" )

Return( oView )

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

Local oModelT0J	as object
Local nOperation	as numeric
Local lRet			as logical

oModelT0J	:=	oModel:GetModel( "MODEL_T0J" )
nOperation	:=	oModel:GetOperation()  
lRet		:=	.T.

If nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE
	If oModelT0J:GetValue( "T0J_TPALIQ" ) == "2" .and. Empty( oModelT0J:GetValue( "T0J_VLALIQ" ) )
		lRet := .F.
		Help( ,, "HELP",, STR0008, 1, 0 ) //"O campo 'Valor Alíq.' é obrigatório quando 'Tipo Alíq' estiver preenchido com '2=Fixa'."
	EndIf
EndIf

Return( lRet )
//---------------------------------------------------------------------
/*/{Protheus.doc} VldAliqT0J()

Validação dos valores dos campos de aliquota, função inserida no X3_VALID.

@Return	lRet - Indica se os valores respeitam as regras.

@Author	Matheus G. Prada
@Since		25/03/2019
@Version	1.0
/*/
//---------------------------------------------------------------------
Function VldAliqT0J() 

Local	nCampo	as numeric
Local	lRet	as logical

lRet	:=	.T.
nCampo	:= &(ReadVar())

If nCampo > 100.0000

	lRet := .F.
	Help(NIL, NIL, "AVISO", NIL, STR0015, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0016})//"O campo 'Valor Aliq.' nao deve possuir um valor maior que 100."  

EndIf

Return( lRet )