#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFA433.CH"

//Grupos do Evento Tribut�rio
#DEFINE GRUPO_RESULTADO_OPERACIONAL	 	1		//Resultado Cont�bil - Operacional
#DEFINE GRUPO_RESULTADO_NAO_OPERACIONAL	2		//Resultado Cont�bil - N�o operacional
#DEFINE GRUPO_RECEITA_BRUTA_ALIQ1	 	 	3		//Receita Bruta - Al�quota 1
#DEFINE GRUPO_RECEITA_BRUTA_ALIQ2	 	 	4		//Receita Bruta - Al�quota 2
#DEFINE GRUPO_RECEITA_BRUTA_ALIQ3	 	 	5		//Receita Bruta - Al�quota 3
#DEFINE GRUPO_RECEITA_BRUTA_ALIQ4			6		//Receita Bruta - Al�quota 4
#DEFINE GRUPO_DEMAIS_RECEITAS	 	 		7		//Demais Receitas
#DEFINE GRUPO_BASE_CALCULO	 				8		//Base de C�lculo
#DEFINE GRUPO_ADICOES_LUCRO		 			9		//Adi��es do Lucro
#DEFINE GRUPO_ADICOES_DOACAO				10		//Adi��es por Doa��o
#DEFINE GRUPO_EXCLUSOES_LUCRO				11		//Exclus�es do Lucro
#DEFINE GRUPO_EXCLUSOES_RECEITA				12		//Exclus�es da Receita
#DEFINE GRUPO_COMPENSACAO_PREJUIZO			13		//Compensa��o de Preju�zo
#DEFINE GRUPO_DEDUCOES_TRIBUTO				14		//Dedu��es do Tributo
#DEFINE GRUPO_COMPENSACAO_TRIBUTO			15		//Compensa��o do Tributo
#DEFINE GRUPO_ADICIONAIS_TRIBUTO			16		//Adicionais do Tributo
#DEFINE GRUPO_RECEITA_LIQUIDA_ATIVIDA		17		//Receita L�quida p/Atividade
#DEFINE GRUPO_LUCRO_EXPLORACAO				18		//Lucro da Explora��o

//Par�metros do Array de Grupos
#DEFINE PARAM_GRUPO_ID					1
#DEFINE PARAM_GRUPO_NOME				2
#DEFINE PARAM_GRUPO_DESCRICAO			3
#DEFINE PARAM_GRUPO_TIPO					4

//Tipo Grupo
#DEFINE TIPO_GRUPO_BASE_CALCULO			1
#DEFINE TIPO_GRUPO_CALCULO_TRIBUTO		2

//Forma de Tributa��o
#DEFINE TRIBUTACAO_LUCRO_REAL						'000001'	//Lucro Real
#DEFINE TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO		'000002'	//Lucro Real - Estimativa por levantamento de balan�o
#DEFINE TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA	'000003'	//Lucro Real - Estimativa por Receita Bruta
#DEFINE TRIBUTACAO_LUCRO_REAL_ATIV_RURAL			'000004'	//Lucro Real - Atividade Rural
#DEFINE TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO			'000005'	//Lucro Real - Lucro da explora��o
#DEFINE TRIBUTACAO_LUCRO_PRESUMIDO					'000006'	//Lucro Presumido
#DEFINE TRIBUTACAO_LUCRO_ARBITRADO					'000007'	//Lucro Arbitrado
#DEFINE TRIBUTACAO_IMUNE								'000008'	//Imune
#DEFINE TRIBUTACAO_ISENTA							'000009'	//Isenta

//Origem
#DEFINE ORIGEM_CONTA_CONTABIL		'1'		//Conta Cont�bil
#DEFINE ORIGEM_LALUR_PARTE_B		'2'		//Lalur - Parte B
#DEFINE ORIGEM_EVENTO_TRIBUTARIO	'3'		//Evento Tribut�rio
#DEFINE ORIGEM_LANCAMENTO_MANUAL	'4'		//Lan�amento Manual
#DEFINE ORIGEM_APURACAO				'5'		//Apura��o

//Tipo de atividade
#DEFINE ATIVIDADE_ISENCAO				'1'		//Isen��o
#DEFINE ATIVIDADE_REDUCAO				'2'		//Redu��o
#DEFINE ATIVIDADE_DEMAIS_ATIVIDADES	'3'		//Demais Atividades

//Tributos
#DEFINE TRIBUTO_IRPJ		'000019'
#DEFINE TRIBUTO_CSLL		'000018'

//Qualifica��o PJ
#DEFINE QUALIFICACAO_PJ_EM_GERAL								'01' //Pessoa Jur�dica em Geral
#DEFINE QUALIFICACAO_PJ_FINANCEIRO								'02' //Pessoa Jur�dica Componente do Sistema Financeiro
#DEFINE QUALIFICACAO_PJ_SOCIEDADE_SEG_PREVIDENCIA_COMPL		'03' //Sociedades Seguradoras, de Capitaliza��o ou Entidade Aberta de Previd�ncia Complementar

//Efeito na parte B do Lalur
#DEFINE EFEITO_NAO_APLICAVEL				"1" //N�o se aplica
#DEFINE EFEITO_CONSTITUIR_SALDO				"2" //Constituir saldo da Conta
#DEFINE EFEITO_BAIXAR_SALDO					"3" //Baixar saldo da Conta
#DEFINE EFEITO_INCLUIR_LANC_AUTOMATICO		"4" //Incluir Lan�amento Autom�tico

//Natureza Conta Lalur Parte B
#DEFINE NATUREZA_ADICAO							'1' //Adi��o
#DEFINE NATUREZA_EXCLUSAO						'2' //Exclus�o
#DEFINE NATUREZA_COMPENSACAO_BASE_NEGATIVA	'3' //Compensa��o de Preju�zo/Base de C�lculo Negativa
#DEFINE NATUREZA_DEDUCAO_COMPENSACAO_TRIBUTO	'4' //Dedu��o/Compensa��o de Tributo
#DEFINE NATUREZA_ADICAO_EXCLUSAO				'5' //Adi��o/Exclus�o

//Tipo de Opera��o
#DEFINE OPERACAO_SOMA		'1'
#DEFINE OPERACAO_SUBTRACAO	'2'

//Par�metros do Array da Simula��o
#DEFINE PARAM_SIMUL_MODEL_EVENTO	1
#DEFINE PARAM_SIMUL_LISTA_PAR		2
#DEFINE LISTA_PAR_MODEL_PERIODO		1
#DEFINE LISTA_PAR_ARRAY_PARAMETRO	2
#DEFINE LISTA_PAR_LOG_PERIODO		3
#DEFINE LISTA_PAR_ARRAY_PAR_RURAL	4

//Par�metros Apura��o
/*
Todos os Defines dos Grupos do Evento Tribut�rio

GRUPO_RESULTADO_OPERACIONAL			1	//Resultado Cont�bil - Operacional
GRUPO_RESULTADO_NAO_OPERACIONAL		2	//Resultado Cont�bil - N�o Operacional
GRUPO_RECEITA_BRUTA_ALIQ1			3	//Receita Bruta - Al�quota 1
GRUPO_RECEITA_BRUTA_ALIQ2			4	//Receita Bruta - Al�quota 2
GRUPO_RECEITA_BRUTA_ALIQ3			5	//Receita Bruta - Al�quota 3
GRUPO_RECEITA_BRUTA_ALIQ4			6	//Receita Bruta - Al�quota 4
GRUPO_DEMAIS_RECEITAS				7	//Demais Receitas
GRUPO_BASE_CALCULO					8	//Base de C�lculo
GRUPO_ADICOES_LUCRO					9	//Adi��es do Lucro
GRUPO_ADICOES_DOACAO					10	//Adi��es por Doa��o
GRUPO_EXCLUSOES_LUCRO				11	//Exclus�es do Lucro
GRUPO_EXCLUSOES_RECEITA				12	//Exclus�es da Receita
GRUPO_COMPENSACAO_PREJUIZO			13	//Compensa��o de Preju�zo
GRUPO_DEDUCOES_TRIBUTO				14	//Dedu��es do Tributo
GRUPO_COMPENSACAO_TRIBUTO			15	//Compensa��o do Tributo
GRUPO_ADICIONAIS_TRIBUTO				16	//Adicionais do Tributo
GRUPO_RECEITA_LIQUIDA_ATIVIDA		17	//Receita L�quida por Atividade
GRUPO_LUCRO_EXPLORACAO				18	//Lucro da Explora��o

Mais os listados abaixo
*/

#DEFINE ALIQUOTA_RECEITA_1					19
#DEFINE ALIQUOTA_RECEITA_2					20
#DEFINE ALIQUOTA_RECEITA_3					21
#DEFINE ALIQUOTA_RECEITA_4					22
#DEFINE ALIQUOTA_IMPOSTO						23
#DEFINE ALIQUOTA_IR_ADICIONAL_IMPOSTO		24
#DEFINE PARCELA_ISENTA						25
#DEFINE INICIO_PERIODO						26
#DEFINE FIM_PERIODO							27
#DEFINE ITENS_PROPORCAO_DO_LUCRO			28

//Par�metros dos Itens da Propor��o do Lucro
#DEFINE PROUNI								1
#DEFINE PERCENTUAL_REDUCAO					2
#DEFINE TIPO_ATIVIDADE						3
#DEFINE VALOR									4
#DEFINE ID_TABELA_ECF						5
#DEFINE ORIGEM								6
#DEFINE ID_TABELA_ECF_DED					7
#DEFINE TIPO_TRIBUTO							29
#DEFINE POEB									30
#DEFINE PERCENTUAL_COMP_PREJU				31
#DEFINE VLR_DEVIDO_PERIODOS_ANTERIORES		32
#DEFINE VLR_PAGO_PERIODOS_ANTERIORES		33
#DEFINE VLR_PREJUIZO_OPERACIONAL			34
#DEFINE VLR_PREJUIZO_NAO_OPERACIONAL		35
#DEFINE VLR_PREJUIZO_COMP_NO_PERIODO		36

STATIC _aGrupos := {}

//Para impress�o da simula��o em Excel
STATIC _aExcRsCnt := {} //AddResCont
STATIC _aExcRsCtR := {} //AddResCont Rural
STATIC _aExcLcRea := {} //AddLucReal
STATIC _aExcLcReR := {} //AddLucReal Rural
STATIC _aExcRAApo := {} //AddLRAposP
STATIC _aExcRAApR := {} //AddLRAposP Rural
STATIC _aExcBCPar := {} //AddBCParci
STATIC _aExcBCPcR := {} //AddBCParci Rural
STATIC _aExcRAlq1 := {} //AddRecAlq1
STATIC _aExcRAlq2 := {} //AddRecAlq2
STATIC _aExcRAlq3 := {} //AddRecAlq3
STATIC _aExcRAlq4 := {} //AddRecAlq4
STATIC _aExcLcEst := {} //AddLucEsti
STATIC _aExcBsCal := {} //AddBaseCal
STATIC _aExcVrImp := {} //AddVlrImpo
STATIC _aExcVrIse := {} //AddVlrIsen
STATIC _aExcVrAdi := {} //AddVlrAdic
STATIC _aExcProIR := {} //AddProIRPJ
STATIC _aExcDvMes := {} //AddDeviMes
STATIC _aExcAdDev := {} //AddDevedor
STATIC _aExcSepar := {} //AddSeparad

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA433

Cadastro de Evento Tribut�rio.

@Author	David Costa
@Since		17/03/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAFA433()

Local oBrw		as object

oBrw	:=	FWmBrowse():New()

If TAFAlsInDic( "T0N" )
	oBrw:SetDescription( STR0001 ) //"Cadastro de Evento Tribut�rio"
	oBrw:SetAlias( "T0N" )
	oBrw:SetMenuDef( "TAFA433" )

	oBrw:SetCacheView( .F. )

	T0N->( DBSetOrder( 1 ) )

	oBrw:Activate()
Else
	Aviso( STR0077, TafAmbInvMsg(), { STR0078 }, 2 ) //##"Dicion�rio Incompat�vel" ##"Encerrar"
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Fun��o gen�rica MVC com as op��es de menu.

@Author	David Costa
@Since		17/03/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local nPos		as numeric
Local aFuncao	as array
Local aRotina	as array

nPos		:=	0
aFuncao	:=	{}
aRotina	:=	{}

aAdd( aFuncao, { STR0067, "TAF433Pre( 'C�pia do Evento Tribut�rio', 'TAFA433Cpy' )" } ) //"C�pia do Evento Tribut�rio"
aAdd( aFuncao, { STR0088, "TAF433Pre( 'Simula��o da Apura��o', 'TAFA433SIM' )" } ) //"Simula��o da Apura��o"

aRotina := xFunMnuTAF( "TAFA433",, aFuncao )

If ( nPos := aScan( aRotina, { |x| AllTrim( x[1] ) == STR0079 } ) ) > 0 //"Visualizar"
	aRotina[nPos,2] := "TAF433Pre( 'Visualizar' )"
EndIf

If ( nPos := aScan( aRotina, { |x| AllTrim( x[1] ) == STR0080 } ) ) > 0 //"Incluir"
	aRotina[nPos,2] := "TAF433Pre( 'Incluir' )"
EndIf

If ( nPos := aScan( aRotina, { |x| AllTrim( x[1] ) == STR0081 } ) ) > 0 //"Alterar"
	aRotina[nPos,2] := "TAF433Pre( 'Alterar' )"
EndIf

If ( nPos := aScan( aRotina, { |x| AllTrim( x[1] ) == STR0082 } ) ) > 0 //"Excluir"
	aRotina[nPos,2] := "TAF433Pre( 'Excluir' )"
EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF433Pre

Executa pr�-condi��es para a opera��o desejada.

@Param		cOper		-	Indica a opera��o a ser executada
			cRotina	-	Indica a rotina a ser executada

@Author	Felipe C. Seolin
@Since		09/12/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAF433Pre( cOper, cRotina, aResult )

Local nOperation	as numeric
Local aButtons	as array
Local lOk			as logical

Private cIDFormTrib	as character
Private cT0N_IDFTRI	as character
Private cT0N_DFTRIB	as character
Private cT0N_IDTRIB	as character
Private cT0N_DTRIBU	as character
Private lCopia		as logical
Private lAutomato	as logical
Private nLinAtu     as numeric
Private aContas 	as array
Private aSintetic 	as array
Private lFoundError as logical
Private lFoundGrid	as logical

Default cRotina		:=	"TAFA433"
Default aResult		:=	{}

nOperation		:=	MODEL_OPERATION_VIEW
aButtons		:=	{}
lOk				:=	.F.

cIDFormTrib	:=	""
cT0N_IDFTRI	:=	""
cT0N_DFTRIB	:=	""
cT0N_IDTRIB	:=	""
cT0N_DTRIBU	:=	""
lCopia		:=	.F.
lAutomato	:= IsBlind()
nLinAtu 	:= 0
aContas		:= {}
aSintetic	:= {}
lFoundError	:= .f.
lFoundGrid	:= .f.

//De-Para de op��es do Menu para a opera��es em MVC
If Upper( cOper ) == Upper( "Visualizar" )
	nOperation := MODEL_OPERATION_VIEW
ElseIf Upper( cOper ) == Upper( "Incluir" )
	nOperation := MODEL_OPERATION_INSERT
ElseIf Upper( cOper ) == Upper( "Alterar" )
	nOperation := MODEL_OPERATION_UPDATE
ElseIf Upper( cOper ) == Upper( "Excluir" )
	nOperation := MODEL_OPERATION_DELETE
ElseIf Upper( cOper ) $ Upper( "|C�pia do Evento Tribut�rio|Simula��o da Apura��o|" )
	nOperation := 0
Else
	nOperation := 0
EndIf

//� permitido o uso do cadastro apenas se for executado em Filial Matriz ou SCP.
//Caso contr�rio, apenas ser� permitido a Visualiza��o do referido cadastro.
If TAFColumnPos( "C1E_MATRIZ" ) .and. TAFColumnPos( "CWX_RURAL" )
	If GrantAccess()

		If Upper( cOper ) $ ( Upper( "|C�pia do Evento Tribut�rio|" ) )
			&cRotina.()
		ElseIf Upper( cOper ) $ ( Upper( "|Simula��o da Apura��o|" ) )
			/*
			C1O_NATURE	--> Dicion�rio do Plano de Contas
			T0T_IDDETA	--> Dicion�rio do Encerramento
			CWX_RURAL	--> Dicionario do Detalhamento
			C0R_VLPAGO	--> Cadastro de Guias
			*/
			If TAFColumnPos( "C1O_NATURE" ) .and. TAFAlsInDic( "CWX" ) .and. TAFColumnPos( "T0T_IDDETA" ) .and. TAFColumnPos( "C0R_VLPAGO" )
				&cRotina.(lAutomato,aResult)
			Else
				MsgInfo( TafAmbInvMsg() )
			EndIf
		ElseIf nOperation == MODEL_OPERATION_INSERT

			aAdd( aButtons, { 1, .T., { |x| lOk := .T., x:oWnd:End() } } )
			aAdd( aButtons, { 2, .T., { |x| x:oWnd:End() } } )

			If PergTAF( cRotina, STR0002, { STR0003 }, aButtons, { || .T. },,, .F. ) .and. lOk //##"Forma de Tributa��o" ##"Forma de Tributa��o do Evento Tribut�rio"
				cIDFormTrib := xFunCh2ID( MV_PAR01, "T0K", 2 )
				FWExecView( cOper, cRotina, nOperation )
			Else
				cIDFormTrib := "CANCEL"
				MsgInfo( STR0083 ) //"� necess�rio informar a Forma de Tributa��o para defini��o das informa��es a serem exibidas no cadastro."
			EndIf

		Else
			FWExecView( cOper, cRotina, nOperation )
		EndIf

	Else

		If nOperation == MODEL_OPERATION_VIEW
			cIDFormTrib := ""
			FWExecView( cOper, cRotina, nOperation )
		Else
			MsgInfo( STR0025 ) //"Apenas Filial Matriz ou Filial SCP possui permiss�o de manipula��o do cadastro."
		EndIf

	EndIf
Else
	MsgInfo( TafAmbInvMsg() )
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Fun��o gen�rica MVC do modelo.

@Return	oModel	- Objeto do Model MVC

@Author	David Costa
@Since		17/03/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruT0N	as object
Local oStruLEC	as object
Local oStruLED	as object
Local oModel		as object
Local nI			as numeric
Local aGrupos		as array

Private lAutomato	:= IsBlind()

oStruT0N	:=	FWFormStruct( 1, "T0N" )
oStruLEC	:=	FWFormStruct( 1, "LEC" )
oStruLED	:=	FWFormStruct( 1, "LED" )
oModel		:=	MPFormModel():New( "TAFA433",,, { |oModel| SaveModel( oModel ) } )
nI			:=	0
aGrupos	:=	GetGrupos( , .T. )

//Inicializa��o de vari�veis Private para n�o gerar erro em
//chamadas diretas da View, por exemplo via Consulta Padr�o
lCopia := Iif( Type( "lCopia" ) == "U", .F., lCopia )

//A Forma de Tributa��o n�o pode ser alterada
oStruT0N:SetProperty( "T0N_CODFTR", MODEL_FIELD_WHEN, { || .F. .or. lCopia .or. lAutomato } )

//Inicializa o ID da Forma de Tributa��o
oStruT0N:SetProperty( "T0N_IDFTRI", MODEL_FIELD_INIT, { |oModel| cIDFormTrib } )

//O Tributo n�o pode ser alterado durante a edi��o
oStruT0N:SetProperty( "T0N_COTRIB", MODEL_FIELD_WHEN, { || ( !( ( Type( "ALTERA" ) <> "U" ) .and. ALTERA ) ) .or. lCopia } )

oStruLEC:AddTrigger( "LEC_CODGRU", "LEC_CODECF",, { || "" } )
oStruLEC:AddTrigger( "LEC_CODGRU", "LEC_DCODEC",, { || "" } )
oStruLEC:AddTrigger( "LEC_CODGRU", "LEC_IDCODE",, { || "" } )
oStruLEC:AddTrigger( "LEC_CODGRU", "LEC_CODLAL",, { || "" } )
oStruLEC:AddTrigger( "LEC_CODGRU", "LEC_DCODLA",, { || "" } )
oStruLEC:AddTrigger( "LEC_CODGRU", "LEC_IDCODL",, { || "" } )
oStruLEC:AddTrigger( "LEC_CODGRU", "LEC_ATIVID",, { || "" } )
oStruLEC:AddTrigger( "LEC_CODGRU", "LEC_PROUNI",, { || "" } )
oStruLEC:AddTrigger( "LEC_CODGRU", "LEC_PERRED",, { || "" } )
oStruLEC:AddTrigger( "LEC_CODGRU", "LEC_CODTDE",, { || "" } )
oStruLEC:AddTrigger( "LEC_CODGRU", "LEC_DCODTD",, { || "" } )
oStruLEC:AddTrigger( "LEC_CODGRU", "LEC_IDCODT",, { || "" } )
oStruLEC:AddTrigger( "LEC_ATIVID", "LEC_PROUNI",, { || "" } )
oStruLEC:AddTrigger( "LEC_ATIVID", "LEC_PERRED",, { || "" } )

oModel:AddFields( "MODEL_T0N", /*cOwner*/, oStruT0N )
oModel:GetModel( "MODEL_T0N" ):SetPrimaryKey( { "T0N_CODIGO" } )

//Cria um model para cada grupo.
For nI := 1 to Len( aGrupos )
	AddModelGr( @oModel, aGrupos[nI] )
Next nI

If TAFAlsInDic( "LEC" ) .and. TAFAlsInDic( "LED" ) .and. !lCopia
	oModel:AddGrid( "MODEL_LEC", "MODEL_T0N", oStruLEC )
	oModel:GetModel( "MODEL_LEC" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_LEC" ):SetUniqueLine( { "LEC_CODLAN" } )
	oModel:SetRelation( "MODEL_LEC",{ { "LEC_FILIAL", "xFilial( 'LEC' )" }, { "LEC_ID", "T0N_ID" } }, LEC->( IndexKey( 1 ) ) )

	oModel:AddGrid( "MODEL_LED", "MODEL_LEC", oStruLED )
	oModel:GetModel( "MODEL_LED" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_LED" ):SetUniqueLine( { "LED_IDPROC" } )
	oModel:SetRelation( "MODEL_LED",{ { "LED_FILIAL", "xFilial( 'LED' )" }, { "LED_ID", "T0N_ID" }, { "LED_CODLAN", "LEC_CODLAN" } }, LED->( IndexKey( 1 ) ) )

EndIf

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Fun��o gen�rica MVC da View.

@Return	oView	- Objeto da View MVC

@Author	David Costa
@Since		17/03/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel		as object
Local oView			as object
Local cFormaTrib	as character
Local nI			as numeric

oModel		:=	FWLoadModel( "TAFA433" )
oView		:=	FWFormView():New()
cFormaTrib	:=	""
_aGrupos	:= {}
//Inicializa��o de vari�veis Private para n�o gerar erro em
//chamadas diretas da View, por exemplo via Consulta Padr�o
cIDFormTrib	:=	Iif( Type( "cIDFormTrib" ) == "U", "", cIDFormTrib )
lCopia			:=	Iif( Type( "lCopia" ) == "U", .F., lCopia )

// Na inclus�o/c�pia ser� solicitado a sele��o da Forma de Tributa��o antes de apresentar a tela de edi��o.
// Na edi��o ser� carregado a Forma de Tributa��o do cadastro.
// A partir da Forma de Tributa��o ser�o definidos quais os campos/abas dever�o ser apresentados.
If lCopia
	CopiarEven( @cFormaTrib, @oModel )
ElseIf !Empty( cIDFormTrib )
	If cIDFormTrib == "CANCEL"
		cFormaTrib := ""
	Else
		cFormaTrib := xFunID2Cd( cIDFormTrib, "T0K", 1 )
	EndIf
Else
	cFormaTrib := xFunID2Cd( T0N->T0N_IDFTRI, "T0K", 1 )
EndIf

oView:SetModel( oModel )
oView:CreateHorizontalBox( "PAINEL_ABAS", 100 )
oView:CreateFolder( "FOLDER_GERAL", "PAINEL_ABAS" )

AbaIndenti( @oView, cFormaTrib )
AbaRegrasT( @oView, cFormaTrib )

If TAFAlsInDic( "LEC" ) .and. TAFAlsInDic( "LED" ) .and. !lCopia
	AbaLancMan( @oView, cFormaTrib )
EndIf
If !lCopia .and. !CanUpdate()
	
	For nI := 1 to Len(_aGrupos) 
		oView:SetOnlyView(_aGrupos[nI])
	Next nI
EndIf

If lCopia
	lCopia := .F.
EndIf

Return( oView )

//---------------------------------------------------------------------
/*/{Protheus.doc} GrantAccess

Fun��o para verificar a permiss�o de manipula��o do cadastro.

@Return	lRet - Indica se possui permiss�o

@Author	Felipe C. Seolin
@Since		09/12/2016
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

//-------------------------------------------------------------------
/*/{Protheus.doc} AbaIndenti
Monta a Aba Identifica��o do Cadastro de Evento Tribut�rio

@Param oView - Objeto da View MVC
cFormaTrib - Forma de Tributa��o do Evento Tribut�rio

@author David Costa
@since 21/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AbaIndenti( oView, cFormaTrib )

Local oStruT0N	as object

oStruT0N	:=	CamposView( "T0N",, cFormaTrib )

oView:AddField( 'VIEW_T0N', oStruT0N, 'MODEL_T0N' )
aAdd(_aGrupos,"VIEW_T0N")

oView:EnableTitleView( 'VIEW_T0N', STR0001 ) //"Cadastro de Evento Tribut�rio"

oView:AddSheet( 'FOLDER_GERAL', 'ABA_IDENTIFICACAO', STR0004 ) //"Identifica��o"
oView:CreateHorizontalBox( 'PAINEL_ABA_IDENTIFICACAO' , 100,,, 'FOLDER_GERAL', 'ABA_IDENTIFICACAO' )

oView:SetOwnerView( 'VIEW_T0N', 'PAINEL_ABA_IDENTIFICACAO' )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} AbaRegrasT
Monta a Aba Regras Tribut�rias do Cadastro de Evento Tribut�rio

@Param oView - Objeto da View MVC
		cFormaTrib - Forma de Tributa��o do Evento Tribut�rio

@author David Costa
@since 21/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AbaRegrasT( oView, cFormaTrib )

oView:AddSheet( 'FOLDER_GERAL', 'ABA_REGRAS_TRIBUTARIAS', STR0005 ) //"Regras Tribut�rias"
oView:CreateHorizontalBox( 'PAINEL_ABAS_REGRAS_TRIBUTARIAS' , 100,,, 'FOLDER_GERAL', 'ABA_REGRAS_TRIBUTARIAS' )
oView:CreateFolder( 'FOLDER_ABAS_REGRAS_TRIBUTARIAS', 'PAINEL_ABAS_REGRAS_TRIBUTARIAS' )

AbaBaseCal( @oView, cFormaTrib )

If cFormaTrib <> TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO .and. cFormaTrib <> TRIBUTACAO_LUCRO_REAL_ATIV_RURAL 
	AbaCalTrib( @oView, cFormaTrib )
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} AbaBaseCal
Monta a Aba Base de Calculo

@Param oView - Objeto da View MVC
		cFormaTrib - Forma de Tributa��o do Evento Tribut�rio
		
@author David Costa
@since 21/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AbaBaseCal( oView, cFormaTrib )

Local cFolder	as character
Local nI		as numeric
Local aGrupos	as array

cFolder	:=	"FOLDER_ABA_BASE_CALCULO"
nI			:=	0
aGrupos	:=	GetGrupos( cFormaTrib )

oView:AddSheet( 'FOLDER_ABAS_REGRAS_TRIBUTARIAS', 'ABA_BASE_CALCULO', STR0006 ) //"Base de C�lculo"
oView:CreateHorizontalBox( 'PAINEL_ABA_BASE_CALCULO' , 100,,, 'FOLDER_ABAS_REGRAS_TRIBUTARIAS', 'ABA_BASE_CALCULO' )
oView:CreateFolder( cFolder, 'PAINEL_ABA_BASE_CALCULO' )

For nI := 1 to Len( aGrupos )
	If aGrupos[nI][PARAM_GRUPO_TIPO] == TIPO_GRUPO_BASE_CALCULO
		AddViewItem( @oView, cFolder, aGrupos[nI], cFormaTrib )
	EndIf
Next nI

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} AddViewItem

Adiciona um Item Tribut�rio na View.

@Param	oView		- Objeto da View MVC
		cFolder	- Folder na qual ser� adicionado o Item Tribut�rio
		aGrupo		- Array do Grupo Tribut�rio ( Gerado pela Fun��o GetGrupos() )
		cFormaTrib	- Forma de Tributa��o do Evento Tribut�rio

@Author	David Costa
@Since		30/03/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function AddViewItem( oView, cFolder, aGrupo, cFormaTrib )

Local oStruT0O	as object
Local oStruT0P	as object
Local oStruT0R	as object

oStruT0O	:=	CamposView( "T0O", aGrupo[PARAM_GRUPO_ID], cFormaTrib )
oStruT0P	:=	CamposView( "T0P", aGrupo[PARAM_GRUPO_ID], cFormaTrib )
oStruT0R	:=	CamposView( "T0R", aGrupo[PARAM_GRUPO_ID], cFormaTrib )

//Aba do Item Tribut�rio
oView:AddSheet( cFolder, "ABA_" + aGrupo[PARAM_GRUPO_NOME], aGrupo[PARAM_GRUPO_DESCRICAO] )

//Item Tribut�rio
oView:CreateHorizontalBox( "PAINEL_" + aGrupo[PARAM_GRUPO_NOME] + "_ITEM", 60,,, cFolder, "ABA_" + aGrupo[PARAM_GRUPO_NOME] )

oView:AddGrid( "VIEW_T0O_" + aGrupo[PARAM_GRUPO_NOME], oStruT0O, "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME] )
oView:EnableTitleView( "VIEW_T0O_" + aGrupo[PARAM_GRUPO_NOME], aGrupo[PARAM_GRUPO_DESCRICAO] )
oView:SetOwnerView( "VIEW_T0O_" + aGrupo[PARAM_GRUPO_NOME], "PAINEL_" + aGrupo[PARAM_GRUPO_NOME] + "_ITEM" )
oView:AddIncrementField( "VIEW_T0O_" + aGrupo[PARAM_GRUPO_NOME], "T0O_SEQITE" )
oView:SetViewProperty('VIEW_T0O_' + aGrupo[PARAM_GRUPO_NOME],'GRIDSEEK', {.t.}) //Adiciona a pesquisa por campos no Grid.
oView:SetViewProperty('VIEW_T0O_' + aGrupo[PARAM_GRUPO_NOME],'CHANGELINE', {{ |oView, cViewID| ChgLineView( oView, cViewID ) }} )
aAdd(_aGrupos,"VIEW_T0O_" + aGrupo[PARAM_GRUPO_NOME])

//Filhos do Item Tribut�rio
oView:CreateHorizontalBox( "PAINEL_" + aGrupo[PARAM_GRUPO_NOME] + "_FILHOS", 40,,, cFolder, "ABA_" + aGrupo[PARAM_GRUPO_NOME] )
oView:CreateFolder( "FOLDER_FILHOS" + aGrupo[PARAM_GRUPO_NOME], "PAINEL_" + aGrupo[PARAM_GRUPO_NOME] + "_FILHOS" )

//Hist�rico Padr�o
oView:AddSheet( "FOLDER_FILHOS" + aGrupo[PARAM_GRUPO_NOME], "ABA_HISTORICO_PADRAO", STR0020 ) //"Hist�rico Padr�o"
oView:CreateHorizontalBox( "PAINEL_HISTORICO_PADRAO" + aGrupo[PARAM_GRUPO_NOME], 100,,, "FOLDER_FILHOS" + aGrupo[PARAM_GRUPO_NOME], "ABA_HISTORICO_PADRAO" )

oView:AddGrid( "VIEW_T0R_HISTORICO_PADRAO" + aGrupo[PARAM_GRUPO_NOME], oStruT0R, "MODEL_T0R_" + aGrupo[PARAM_GRUPO_NOME] )
aAdd(_aGrupos,"VIEW_T0R_HISTORICO_PADRAO" + aGrupo[PARAM_GRUPO_NOME])

oView:EnableTitleView( "VIEW_T0R_HISTORICO_PADRAO" + aGrupo[PARAM_GRUPO_NOME], STR0020 ) //"Hist�rico Padr�o"
oView:SetOwnerView( "VIEW_T0R_HISTORICO_PADRAO" + aGrupo[PARAM_GRUPO_NOME], "PAINEL_HISTORICO_PADRAO" + aGrupo[PARAM_GRUPO_NOME] )
oView:AddIncrementField( "VIEW_T0R_HISTORICO_PADRAO" + aGrupo[PARAM_GRUPO_NOME], "T0R_SEQHIS" )

//Processos Referenciados
oView:AddSheet( "FOLDER_FILHOS" + aGrupo[PARAM_GRUPO_NOME], "ABA_PROCESSO_JUD_ADMIN", STR0021 ) //"Processo Jud./Admin."
oView:CreateHorizontalBox( "PAINEL_PROCESSO_JUD_ADMIN" + aGrupo[PARAM_GRUPO_NOME], 100,,, "FOLDER_FILHOS" + aGrupo[PARAM_GRUPO_NOME], "ABA_PROCESSO_JUD_ADMIN" )

oView:AddGrid( "VIEW_T0P_PROCESSO_JUD_ADMIN" + aGrupo[PARAM_GRUPO_NOME], oStruT0P, "MODEL_T0P_" + aGrupo[PARAM_GRUPO_NOME] )
aAdd(_aGrupos,"VIEW_T0P_PROCESSO_JUD_ADMIN" + aGrupo[PARAM_GRUPO_NOME])
oView:EnableTitleView( "VIEW_T0P_PROCESSO_JUD_ADMIN" + aGrupo[PARAM_GRUPO_NOME], STR0021 ) //"Processo Jud./Admin."
oView:SetOwnerView( "VIEW_T0P_PROCESSO_JUD_ADMIN" + aGrupo[PARAM_GRUPO_NOME], "PAINEL_PROCESSO_JUD_ADMIN" + aGrupo[PARAM_GRUPO_NOME] )
oView:AddIncrementField( "VIEW_T0P_PROCESSO_JUD_ADMIN" + aGrupo[PARAM_GRUPO_NOME], "T0P_SEQPRO" )

If TamSX3("T0O_IDCC")[1] == 36
	oStruT0O:RemoveField( "T0O_IDCC")
EndIf
Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} AbaCalTrib

Monta a Aba C�lculo do Tributo

@Param	oView		- Objeto da View MVC
		cFormaTrib	- Forma de Tributa��o do Evento Tribut�rio

@Author	David Costa
@Since		21/03/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function AbaCalTrib( oView, cFormaTrib )

Local cFolder	as character
Local nI		as numeric
Local aGrupos	as array

cFolder	:=	"FOLDER_ABA_CALCULO_TRIBUTO"
nI			:=	0
aGrupos	:=	GetGrupos( cFormaTrib )

oView:AddSheet( "FOLDER_ABAS_REGRAS_TRIBUTARIAS", "ABA_CALCULO_TRIBUTO", STR0022 ) //"C�lculo do Tributo"
oView:CreateHorizontalBox( "PAINEL_ABA_CALCULO_TRIBUTO", 100,,, "FOLDER_ABAS_REGRAS_TRIBUTARIAS", "ABA_CALCULO_TRIBUTO" )
oView:CreateFolder( cFolder, "PAINEL_ABA_CALCULO_TRIBUTO" )

For nI := 1 to Len( aGrupos )
	If aGrupos[nI][PARAM_GRUPO_TIPO] == TIPO_GRUPO_CALCULO_TRIBUTO
		AddViewItem( @oView, cFolder, aGrupos[nI], cFormaTrib )
	EndIf
Next nI

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} AbaLancMan

Monta a Aba Regras Tribut�rias do Cadastro de Evento Tribut�rio

@Param	oView		- Objeto da View MVC
		cFormaTrib	- Forma de Tributa��o do Evento Tribut�rio

@Author	Felipe C. Seolin
@Since		29/06/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function AbaLancMan( oView, cFormaTrib )

Local oStruLEC	as object
Local oStruLED	as object

oStruLEC	:=	CamposView( "LEC",, cFormaTrib )
oStruLED	:=	CamposView( "LED",, cFormaTrib )

oView:AddGrid( "VIEW_LEC", oStruLEC, "MODEL_LEC" )
aAdd(_aGrupos,"VIEW_LEC")
oView:EnableTitleView( "VIEW_LEC", STR0071 ) //"Lan�amento Manual"
oView:AddIncrementField( "VIEW_LEC", "LEC_CODLAN" )

oView:AddGrid( "VIEW_LED", oStruLED, "MODEL_LED" )
aAdd(_aGrupos,"VIEW_LED")
oView:EnableTitleView( "VIEW_LED", STR0072 ) //"Processo Judicial e Administrativo dos Lan�amentos Manuais"

oView:AddSheet( "FOLDER_GERAL", "ABA_LANCAMENTO_MANUAL", STR0071 ) //"Lan�amento Manual"

oView:CreateHorizontalBox( "PAINEL_ABA_LANCAMENTO_MANUAL_SUPERIOR", 50,,, "FOLDER_GERAL", "ABA_LANCAMENTO_MANUAL" )
oView:CreateHorizontalBox( "PAINEL_ABA_LANCAMENTO_MANUAL_INFERIOR", 50,,, "FOLDER_GERAL", "ABA_LANCAMENTO_MANUAL" )


oView:SetOwnerView( "VIEW_LEC", "PAINEL_ABA_LANCAMENTO_MANUAL_SUPERIOR" )
oView:SetOwnerView( "VIEW_LED", "PAINEL_ABA_LANCAMENTO_MANUAL_INFERIOR" )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} CamposView
Retorna os campos para a View conforme as Regras de cada Grupo tribut�rio

@Param cAlias - Tabela com os campos do Form
		nIdGrupo - Identificador do Grupo Tribut�rio
		cFormaTrib - Forma de Tributa��o do Evento Tribut�rio
		
@return FormStruct

@author David Costa
@since 30/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CamposView( cAlias, nIdGrupo, cFormaTrib )

Local oStruct		as object
Local cIdFilial	as character

oStruct	:=	FWFormStruct( 2, cAlias )
cIdFilial	:=	""

If cAlias $ 'T0O'
	oStruct:RemoveField( 'T0O_ID' )
	oStruct:RemoveField( 'T0O_IDGRUP' )
	oStruct:RemoveField( 'T0O_IDECF' )
	oStruct:RemoveField( 'T0O_IDLAL' )
	oStruct:RemoveField( 'T0O_IDLIDC' )
	oStruct:RemoveField( 'T0O_IDCC' )
	oStruct:RemoveField( 'T0O_IDEVEN' )
	oStruct:RemoveField( 'T0O_IDTDEX' )
	oStruct:RemoveField( 'T0O_IDPARB' )
	
	Do Case
		Case nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ1 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ2 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ3;
		.or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ4 .or. nIdGrupo == GRUPO_DEMAIS_RECEITAS .or. nIdGrupo == GRUPO_BASE_CALCULO;
		.or. nIdGrupo == GRUPO_EXCLUSOES_RECEITA .or. nIdGrupo == GRUPO_ADICIONAIS_TRIBUTO .or. nIdGrupo == GRUPO_LUCRO_EXPLORACAO
			oStruct:RemoveField( 'T0O_PERDED' )
			oStruct:RemoveField( 'T0O_CODLID' )
			oStruct:RemoveField( 'T0O_DLIMDC' )
			oStruct:RemoveField( 'T0O_EFEITO' )
			oStruct:RemoveField( 'T0O_ATIVID' )
			oStruct:RemoveField( 'T0O_PROUNI' )
			oStruct:RemoveField( 'T0O_PERRED' )
			oStruct:RemoveField( 'T0O_CODTDE' )
			oStruct:RemoveField( 'T0O_DTDEXP' )
			oStruct:RemoveField( 'T0O_CODEVE' )
			oStruct:RemoveField( 'T0O_DEVENT' )
			oStruct:RemoveField( 'T0O_CODLAL' )
			oStruct:RemoveField( 'T0O_DTDLAL' )

			If cFormaTrib == TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO
				//Quando a forma de tributa��o for "Lucro Real - Lucro da Explora��o" a Origem dever� ser "Conta Cont�bil"
				oStruct:SetProperty( "T0O_ORIGEM", MVC_VIEW_COMBOBOX, { "1=Conta Cont�bil" } )

				//Quando a forma de tributa��o for "Lucro Real - Lucro da Explora��o" o campo "Conta Lalur � Parte B" n�o estar� dispon�vel.
				oStruct:RemoveField( "T0O_CODPAB" )
				oStruct:RemoveField( "T0O_DPARTB" )
			EndIf

		Case nIdGrupo == GRUPO_DEDUCOES_TRIBUTO
			oStruct:SetProperty( 'T0O_CODCC' , MVC_VIEW_TITULO   , 'Conta Contabil ( Sint�tica / Anal�tica )')
			oStruct:SetProperty( "T0O_EFEITO", MVC_VIEW_COMBOBOX, { "4=Incluir Lan�amento Autom�tico" } )
			oStruct:RemoveField( "T0O_ATIVID" )
			oStruct:RemoveField( "T0O_PROUNI" )
			oStruct:RemoveField( "T0O_PERRED" )
			oStruct:RemoveField( "T0O_CODTDE" )
			oStruct:RemoveField( "T0O_DTDEXP" )
			oStruct:RemoveField( "T0O_CODLAL" )
			oStruct:RemoveField( "T0O_DTDLAL" )

			If cFormaTrib <> TRIBUTACAO_LUCRO_REAL .and. cFormaTrib <> TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA
				//Se a Origem "Evento Tribut�rio" n�o estiver dispon�vel os campos devem ser removidos
				oStruct:RemoveField( 'T0O_CODEVE' )
				oStruct:RemoveField( 'T0O_DEVENT' )
			Else
				//Adicionar a op��o "3=Evento Tribut�rio"
				oStruct:SetProperty( 'T0O_ORIGEM' , MVC_VIEW_COMBOBOX , { "1=Conta Cont�bil", "2=Lalur - Parte B", "3=Evento Tribut�rio" } )
			EndIf
		Case nIdGrupo == GRUPO_ADICOES_LUCRO .or. nIdGrupo == GRUPO_ADICOES_DOACAO .or. nIdGrupo == GRUPO_EXCLUSOES_LUCRO
			oStruct:SetProperty( 'T0O_CODCC' , MVC_VIEW_TITULO   , 'Conta Contabil ( Sint�tica / Anal�tica )')
			oStruct:RemoveField( 'T0O_PERDED' )
			oStruct:RemoveField( 'T0O_CODLID' )
			oStruct:RemoveField( 'T0O_DLIMDC' )
			oStruct:RemoveField( 'T0O_ATIVID' )
			oStruct:RemoveField( 'T0O_PROUNI' )
			oStruct:RemoveField( 'T0O_PERRED' )
			oStruct:RemoveField( 'T0O_CODTDE' )
			oStruct:RemoveField( 'T0O_DTDEXP' )
			oStruct:RemoveField( 'T0O_CODEVE' )
			oStruct:RemoveField( 'T0O_DEVENT' )
			
			If cFormaTrib == TRIBUTACAO_LUCRO_REAL .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL_ATIV_RURAL
				oStruct:RemoveField( 'T0O_CODECF' )
				oStruct:RemoveField( 'T0O_DTDECF' )
			Else
				oStruct:RemoveField( 'T0O_CODLAL' )
				oStruct:RemoveField( 'T0O_DTDLAL' )
			EndIf
			
		Case nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO
			oStruct:SetProperty( 'T0O_CODCC' , MVC_VIEW_TITULO   , 'Conta Contabil ( Sint�tica / Anal�tica )')
			oStruct:SetProperty( "T0O_EFEITO", MVC_VIEW_COMBOBOX, { "4=Incluir Lan�amento Autom�tico" } )
			oStruct:RemoveField( "T0O_ATIVID" )
			oStruct:RemoveField( "T0O_PROUNI" )
			oStruct:RemoveField( "T0O_PERRED" )
			oStruct:RemoveField( "T0O_CODTDE" )
			oStruct:RemoveField( "T0O_DTDEXP" )
			oStruct:RemoveField( "T0O_CODEVE" )
			oStruct:RemoveField( "T0O_DEVENT" )
			oStruct:RemoveField( "T0O_CODLAL" )
			oStruct:RemoveField( "T0O_DTDLAL" )

		Case nIdGrupo == GRUPO_COMPENSACAO_PREJUIZO
			oStruct:SetProperty( "T0O_EFEITO", MVC_VIEW_COMBOBOX, { "4=Incluir Lan�amento Autom�tico" } )
			oStruct:RemoveField( "T0O_ATIVID" )
			oStruct:RemoveField( "T0O_PROUNI" )
			oStruct:RemoveField( "T0O_PERRED" )
			oStruct:RemoveField( "T0O_CODTDE" )
			oStruct:RemoveField( "T0O_DTDEXP" )
			oStruct:RemoveField( "T0O_CODEVE" )
			oStruct:RemoveField( "T0O_DEVENT" )

			//O campo "Conta Cont�bil" s� estar� dispon�vel quando a Origem for "Conta Cont�bil"
			oStruct:RemoveField( 'T0O_CODCC' )
			oStruct:RemoveField( 'T0O_DCONTC' )
			
			//O campo "Centro de Custo" s� estar� dispon�vel quando a Origem for "Conta Cont�bil"
			oStruct:RemoveField( 'T0O_IDCUST' )
			oStruct:RemoveField( 'T0O_DCUSTO' )
			
			If cFormaTrib == TRIBUTACAO_LUCRO_REAL .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL_ATIV_RURAL
				oStruct:RemoveField( 'T0O_CODECF' )
				oStruct:RemoveField( 'T0O_DTDECF' )
			Else
				oStruct:RemoveField( 'T0O_CODLAL' )
				oStruct:RemoveField( 'T0O_DTDLAL' )
			EndIf

		Case nIdGrupo == GRUPO_RECEITA_LIQUIDA_ATIVIDA
			oStruct:RemoveField( 'T0O_PERDED' )
			oStruct:RemoveField( 'T0O_CODLID' )
			oStruct:RemoveField( 'T0O_DLIMDC' )
			oStruct:RemoveField( 'T0O_EFEITO' )
			oStruct:RemoveField( 'T0O_CODEVE' )
			oStruct:RemoveField( 'T0O_DEVENT' )
			oStruct:RemoveField( 'T0O_CODLAL' )
			oStruct:RemoveField( 'T0O_DTDLAL' )

			If cFormaTrib == TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO
				//Quando a forma de tributa��o for "Lucro Real - Lucro da Explora��o" a Origem dever� ser "Conta Cont�bil"
				oStruct:SetProperty( "T0O_ORIGEM", MVC_VIEW_COMBOBOX, { "1=Conta Cont�bil" } )

				//Quando a forma de tributa��o for "Lucro Real - Lucro da Explora��o" o campo "Conta Lalur � Parte B" n�o estar� dispon�vel.
				oStruct:RemoveField( "T0O_CODPAB" )
				oStruct:RemoveField( "T0O_DPARTB" )
			EndIf

		Case nIdGrupo == GRUPO_RESULTADO_OPERACIONAL .or. nIdGrupo == GRUPO_RESULTADO_NAO_OPERACIONAL
			oStruct:SetProperty( 'T0O_CODCC' , MVC_VIEW_TITULO   , 'Conta Contabil ( Sint�tica / Anal�tica )')
			oStruct:SetProperty( "T0O_ORIGEM", MVC_VIEW_COMBOBOX, { "1=Conta Cont�bil" } )
			oStruct:RemoveField( "T0O_CODECF" )
			oStruct:RemoveField( "T0O_DTDECF" )
			oStruct:RemoveField( "T0O_PERDED" )
			oStruct:RemoveField( "T0O_CODLID" )
			oStruct:RemoveField( "T0O_DLIMDC" )
			oStruct:RemoveField( "T0O_EFEITO" )
			oStruct:RemoveField( "T0O_CODEVE" )
			oStruct:RemoveField( "T0O_DEVENT" )
			oStruct:RemoveField( "T0O_ATIVID" )
			oStruct:RemoveField( "T0O_PROUNI" )
			oStruct:RemoveField( "T0O_PERRED" )
			oStruct:RemoveField( "T0O_CODPAB" )
			oStruct:RemoveField( "T0O_DPARTB" )

	EndCase

	cIdFilial := XFUNCh2ID( cFilAnt , 'C1E' , 3, , , , .T. )
	
	If FilialSCP( cIdFilial, Space( 1 ) ) .or. ( FWModeAccess( "C1O" ) == "C" .and. FWModeAccess( "C1P" ) == "C" .and. FWModeAccess( "T0S" ) == "C" )
		oStruct:RemoveField( "T0O_FILITE" )
	EndIf

	If cFormaTrib <> TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO
		oStruct:RemoveField( 'T0O_CODTDE' )
		oStruct:RemoveField( 'T0O_DTDEXP' )
	EndIf

ElseIf cAlias $ 'T0P'
	oStruct:RemoveField( 'T0P_ID' )
	oStruct:RemoveField( 'T0P_IDGRUP' )
	oStruct:RemoveField( 'T0P_SEQITE' )
ElseIf cAlias $ 'T0R'
	oStruct:RemoveField( 'T0R_ID' )
	oStruct:RemoveField( 'T0R_IDGRUP' )
	oStruct:RemoveField( 'T0R_SEQITE' )
	oStruct:RemoveField( 'T0R_IDHIST' )
ElseIf cAlias $ 'T0N'
	oStruct:RemoveField( 'T0N_ID')
	oStruct:RemoveField( 'T0N_IDFTRI' )
	oStruct:RemoveField( 'T0N_IDEVEN' )
	oStruct:RemoveField( 'T0N_IDTRIB' )

	oStruct:SetProperty( "T0N_COTRIB", MVC_VIEW_ORDEM, "09" )
	oStruct:SetProperty( "T0N_DTRIBU", MVC_VIEW_ORDEM, "10" )
	oStruct:SetProperty( "T0N_CODEVE", MVC_VIEW_ORDEM, "12" )
	oStruct:SetProperty( "T0N_DEVENT", MVC_VIEW_ORDEM, "13" )

	//O campo "Evento Tribut�rio para apura��o da atividade rural" estar� dispon�vel somente para as formas 
	//de tributa��o "Lucro Real" e "Lucro Real - estimativa levantamento de balan�o"
	If cFormaTrib <> TRIBUTACAO_LUCRO_REAL .and. cFormaTrib <> TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
		oStruct:RemoveField( 'T0N_CODEVE' )
		oStruct:RemoveField( 'T0N_DEVENT' )
	EndIf
	
	//O campo "Tributo" n�o ser� apresentado quando a Forma de Tributa��o for "Lucro Real - Lucro da Explora��o"
	If cFormaTrib == TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO
		oStruct:RemoveField( 'T0N_COTRIB' )
		oStruct:RemoveField( 'T0N_DTRIBU' )
	EndIf

ElseIf cAlias $ "LEC"

	oStruct:RemoveField( "LEC_IDCODG" )
	oStruct:RemoveField( "LEC_IDCODE" )
	oStruct:RemoveField( "LEC_IDCODL" )
	oStruct:RemoveField( "LEC_IDCODT" )

EndIf

Return( oStruct )

//-------------------------------------------------------------------
/*/{Protheus.doc} AddModelGr

Adiciona o Modelo do Grupo Tribut�rio .

@Param	oModel	- Objeto do Modelo MVC
		aGrupo	- Array do Grupo Tribut�rio ( Gerado pela Fun��o GetGrupos() )

@Author	David Costa
@Since		30/03/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function AddModelGr( oModel, aGrupo )

Local oStruT0O	as object
Local oStruT0P	as object
Local oStruT0R	as object
Local cIdFilial	as character

oStruT0O	:=	FWFormStruct( 1, "T0O" )
oStruT0P	:=	FWFormStruct( 1, "T0P" )
oStruT0R	:=	FWFormStruct( 1, "T0R" )
cIdFilial	:=	""

If aGrupo[PARAM_GRUPO_ID] == GRUPO_COMPENSACAO_PREJUIZO
	//No Grupo "Compensa��o de Preju�zos" s� deve ser poss�vel associar Conta da Parte B do Lalur
	oStruT0O:SetProperty( "T0O_ORIGEM", MODEL_FIELD_INIT, { || ORIGEM_LALUR_PARTE_B } )
	oStruT0O:SetProperty( "T0O_ORIGEM", MODEL_FIELD_WHEN, { || .F. } )
	oStruT0O:SetProperty( "T0O_EFEITO", MODEL_FIELD_VALUES, { "4=Incluir Lan�amento Autom�tico" } )

ElseIf aGrupo[PARAM_GRUPO_ID] == GRUPO_DEDUCOES_TRIBUTO
	//A op��o "Evento Tribut�rio" s� pode ser selecionada no Grupo de Dedu��es do Tributo
	oStruT0O:SetProperty( "T0O_ORIGEM", MODEL_FIELD_VALUES, { "1=Conta Cont�bil", "2=Lalur - Parte B", "3=Evento Tribut�rio" } )
	oStruT0O:SetProperty( "T0O_EFEITO", MODEL_FIELD_VALUES, { "4=Incluir Lan�amento Autom�tico" } )

ElseIf aGrupo[PARAM_GRUPO_ID] == GRUPO_COMPENSACAO_TRIBUTO
	oStruT0O:SetProperty( "T0O_EFEITO", MODEL_FIELD_VALUES, { "4=Incluir Lan�amento Autom�tico" } )
EndIf

cIdFilial := xFunCh2ID( cFilAnt, "C1E", 3,,,, .T. )

//Se a Filial for SCP, o campo ser� carregado automaticamente com a Filial logada, e este campo n�o poder� ser alterado
If FilialSCP( cIdFilial )
	DBSelectArea( "C1E" )
	C1E->( DBSetOrder( 2 ) )
	If C1E->( MsSeek( xFilial( "C1E" ) + cIdFilial ) )
		oStruT0O:SetProperty( "T0O_FILITE", MODEL_FIELD_INIT, { || C1E->C1E_CODFIL } )
		oStruT0O:SetProperty( "T0O_FILITE", MODEL_FIELD_WHEN, { || .F. } )
	EndIf
EndIf

oStruT0O:SetProperty( "T0O_IDGRUP", MODEL_FIELD_INIT, { |oModel| aGrupo[PARAM_GRUPO_ID] } )

oModel:AddGrid( "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME], "MODEL_T0N", oStruT0O, { |oModelGrid, nLine, cAction, cField, xValNew, xValOld| PutcModel( "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME], cField ) }, { |oModelGrid, nLine| VldGridEv(oModelGrid, nLine )} )
oModel:GetModel( "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME] ):SetOptional( .T. )
oModel:GetModel( "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME] ):SetLoadFilter( { { "T0O_IDGRUP", Str( aGrupo[PARAM_GRUPO_ID] ) } } )
oModel:GetModel( "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME] ):SetUniqueLine( { "T0O_IDGRUP", "T0O_SEQITE" } )
oModel:GetModel( "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME] ):SetMaxLine(9999)

oModel:AddGrid( "MODEL_T0P_" + aGrupo[PARAM_GRUPO_NOME], "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME], oStruT0P )
oModel:GetModel( "MODEL_T0P_" + aGrupo[PARAM_GRUPO_NOME] ):SetOptional( .T. )
oModel:GetModel( "MODEL_T0P_" + aGrupo[PARAM_GRUPO_NOME] ):SetUniqueLine( { "T0P_IDGRUP", "T0P_SEQITE", "T0P_SEQPRO" } )

oModel:AddGrid( "MODEL_T0R_" + aGrupo[PARAM_GRUPO_NOME], "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME], oStruT0R, { |oModelGrid, nLine, cAction| VldHistEve( cAction ) } )
oModel:GetModel( "MODEL_T0R_" + aGrupo[PARAM_GRUPO_NOME] ):SetOptional( .T. )
oModel:GetModel( "MODEL_T0R_" + aGrupo[PARAM_GRUPO_NOME] ):SetUniqueLine( { "T0R_IDGRUP", "T0R_SEQITE", "T0R_SEQHIS" } )

oModel:SetRelation( "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME], { { "T0O_FILIAL", "xFilial( 'T0O' )" }, { "T0O_ID", "T0N_ID" } }, T0O->( IndexKey( 1 ) ) )
oModel:SetRelation( "MODEL_T0P_" + aGrupo[PARAM_GRUPO_NOME], { { "T0P_FILIAL", "xFilial( 'T0P' )" }, { "T0P_ID", "T0N_ID" }, { "T0P_IDGRUP", "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME] + ".T0O_IDGRUP" }, { "T0P_SEQITE", "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME] + ".T0O_SEQITE" } }, T0P->( IndexKey( 1 ) ) )
oModel:SetRelation( "MODEL_T0R_" + aGrupo[PARAM_GRUPO_NOME], { { "T0R_FILIAL", "xFilial( 'T0R' )" }, { "T0R_ID", "T0N_ID" }, { "T0R_IDGRUP", "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME] + ".T0O_IDGRUP" }, { "T0R_SEQITE", "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME] + ".T0O_SEQITE" } }, T0R->( IndexKey( 1 ) ) )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCmpEven

Funcao utilizada para consistir os campos do evento tribut�rio

@return cRet - Retorna se o campo est� v�lido

@author David Costa
@since 24/04/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function VldCmpEven()

Local cCmp			as character
Local cOrigem		as character
Local cFilItem	as character
Local cLogValid	as character
Local cFormaTrib	as character
Local cTributo	as character
Local cCodTDECF	as character
Local cEfeito		as character
Local cGrupo		as character
Local nIdGrupo	as numeric
Local aAreaBkp	as array
Local lRet			as logical
Local xValueCmp

cCmp		:=	ReadVar()
cOrigem	:=	""
cFilItem	:=	""
cLogValid	:=	""
cFormaTrib	:=	""
cTributo	:=	""
cCodTDECF	:=	""
cEfeito	:=	""
cGrupo		:=	""
nIdGrupo	:=	0
aAreaBkp	:=	{}
lRet		:=	.T.
xValueCmp	:=	Nil

If !( "LEC_" $ AllTrim( SubStr( cCmp, 4 ) ) )
	cFilItem	:= xFunCh2ID( GetValueCmp( "T0O_FILITE" ), "C1E", 1 )
	cOrigem	:= GetValueCmp( "T0O_ORIGEM" )
	nIdGrupo	:= GetValueCmp( "T0O_IDGRUP" )
EndIf

If AllTrim( SubStr( cCmp , 4 ) ) $ "T0O_FILITE"
	If !Empty( GetValueCmp( "T0O_CODCC" ) ) .or. !Empty( GetValueCmp( "T0O_IDCUST" ) ) .or. !Empty( GetValueCmp( "T0O_CODPAB" ) )
		cLogValid += STR0026 + CRLF + CRLF //"Antes de Alterar o campo T0O_FILITE � necess�rio limpar o conte�do dos campos 'Conta cont�bil' (T0O_CODCC), 'Centro de Custo' (T0O_IDCUST) e 'Conta da Parte B do Lalur' (T0O_CODPAB)"
		lRet := .F.
	EndIf
EndIf

If AllTrim( SubStr( cCmp , 4 ) ) $ "T0O_ORIGEM"
	
	If !VldHistEve( 'ALTERACAO_ORIGEM' )
		lRet := .F.	
		cLogValid := STR0027 + CRLF + CRLF //"Apague o Hist�rico Padr�o antes de alterar a Origem."
	EndIf
EndIf

If AllTrim( SubStr( cCmp , 4 ) ) $ "T0O_OPERAC|T0O_ORIGEM"
	
	xValueCmp := GetValueCmp( "T0O_OPERAC" )
	
	//Quando for selecionada a origem "Evento Tribut�rio" a opera��o deve ser obrigatoriamente SOMA.
	If !Empty( xValueCmp ) .and. xValueCmp <> OPERACAO_SOMA .and. cOrigem == ORIGEM_EVENTO_TRIBUTARIO
		lRet := .F.
		cLogValid := STR0028 + CRLF + CRLF //"Quando for selecionada a origem 'Evento Tribut�rio' a opera��o deve ser obrigatoriamente SOMA."
	EndIf
EndIf

If AllTrim( SubStr( cCmp , 4 ) ) $ "T0O_CODCC|T0O_ORIGEM"

	xValueCmp := GetValueCmp( "T0O_CODCC" )
	
	//O campo "Conta Cont�bil" s� estar� dispon�vel quando a Origem for "Conta Cont�bil" 
	If !Empty( xValueCmp ) .and. ( Empty( cOrigem ) .or. cOrigem <> ORIGEM_CONTA_CONTABIL )
		cLogValid += STR0029 + CRLF + CRLF //"O campo 'Conta Cont�bil' s� pode ser utilizado quando a Origem for 'Conta Cont�bil' "
		lRet := .F.
	EndIf
	
	//A conta cont�bil preenchida precisa ser da Filial selecionada no campo "Filial"
	C1O->( DbSetOrder( 1 ) )
	If !Empty( xValueCmp ) .and. !( C1O->( MsSeek( xFilial( "C1O", cFilItem ) + xValueCmp ) ) )
		cLogValid += STR0030 + CRLF + CRLF //A Conta Cont�bil n�o pertence a Filial informada no campo T0O_FILITE
		lRet := .F.
	EndIf
EndIf

If AllTrim( SubStr( cCmp , 4 ) ) $ "T0O_CODPAB|T0O_ORIGEM|T0O_EFEITO"

	xValueCmp := GetValueCmp( "T0O_CODPAB" )
	
	If !Empty( xValueCmp )
		
		T0S->( DbSetOrder( 2 ) )
		
		//A conta da parte B preenchida precisa ser da Filial selecionada no campo "Filial"
		If !( T0S->( MsSeek( xFilial( "T0S", cFilItem ) + xValueCmp ) ) )
			cLogValid += STR0050 + CRLF + CRLF //"A Conta da Parte B n�o pertence a Filial informada no campo T0O_FILITE"
			lRet := .F.
		
		Else
			LE9->( DbSetOrder( 1 ) )
			//Apenas contas da parte B cujo o tributo seja o mesmo selecionado no evento tribut�rio pode ser informadas.
			If ! ( LE9->( MsSeek( xFilial( "LE9", cFilItem ) + T0S->T0S_ID + FWFldGet( "T0N_IDTRIB" ) ) ) )
				cLogValid += STR0057 + CRLF + CRLF //"A conta dever� ter o mesmo tributo do Evento tribut�rio."
				lRet := .F.
			EndIf
		EndIf
		
		If cOrigem == ORIGEM_CONTA_CONTABIL
			
			cEfeito := GetValueCmp( "T0O_EFEITO" )
			
			If Empty( cEfeito ) .or. cEfeito == EFEITO_NAO_APLICAVEL
				cLogValid += STR0052 + CRLF + CRLF //"� necess�rio selecionar um Efeito antes de selecionar uma conta da parte B do Lalur"
				lRet := .F.
			EndIf
			
			//Nos Grupos de Adi��es do Lucro e Adi��es por Doa��o
			If nIdGrupo == GRUPO_ADICOES_LUCRO .or. nIdGrupo == GRUPO_ADICOES_DOACAO
				
				//Se o efeito for "Constituir saldo na Conta", devem ser apresentadas contas da Parte B com natureza de "Exclus�o".
				If cEfeito == EFEITO_CONSTITUIR_SALDO
					If T0S->T0S_NATURE <> NATUREZA_EXCLUSAO .and. T0S->T0S_NATURE <> NATUREZA_ADICAO_EXCLUSAO
						cLogValid += STR0053 + CRLF + CRLF //"Para o 'Efeito' (T0O_EFEITO) informado, a conta da Parte B dever� ser de natureza de 'Exclus�o'"
						lRet := .F.
					EndIf
				
				//Se o efeito for "Baixar saldo da Conta", devem ser apresentadas contas da Parte B com natureza de "Adi��o".
				ElseIf cEfeito == EFEITO_BAIXAR_SALDO
					If T0S->T0S_NATURE <> NATUREZA_ADICAO .and. T0S->T0S_NATURE <> NATUREZA_ADICAO_EXCLUSAO
						cLogValid += STR0054 + CRLF + CRLF //"Para o 'Efeito' (T0O_EFEITO) informado, a conta da Parte B dever� ser de natureza de 'Adi��o'"
						lRet := .F.
					EndIf
				EndIf
				
			//No Grupo de Exclus�es do Lucro
			ElseIf nIdGrupo == GRUPO_EXCLUSOES_LUCRO
				
				//Se o efeito for "Constituir saldo na Conta", devem ser apresentadas contas da Parte B com natureza de "Adi��o".
				If cEfeito == EFEITO_CONSTITUIR_SALDO
					If T0S->T0S_NATURE <> NATUREZA_ADICAO .and. T0S->T0S_NATURE <> NATUREZA_ADICAO_EXCLUSAO
						cLogValid += STR0054 + CRLF + CRLF //"Para o 'Efeito' (T0O_EFEITO) informado, a conta da Parte B dever� ser de natureza de 'Adi��o'"
						lRet := .F.
					EndIf
				
				//Se o efeito for "Baixar saldo da Conta", devem ser apresentadas contas da Parte B com natureza de "Exclus�o".
				ElseIf cEfeito == EFEITO_BAIXAR_SALDO
					If T0S->T0S_NATURE <> NATUREZA_EXCLUSAO .and. T0S->T0S_NATURE <> NATUREZA_ADICAO_EXCLUSAO
						cLogValid += STR0053 + CRLF + CRLF //"Para o 'Efeito' (T0O_EFEITO) informado, a conta da Parte B dever� ser de natureza de 'Exclus�o'"
						lRet := .F.
					EndIf
				EndIf
			EndIf
			
		ElseIf cOrigem == ORIGEM_LALUR_PARTE_B 
		
			//Grupos de "Adi��es do Lucro" e "Adi��es por Doa��o"
			If nIdGrupo == GRUPO_ADICOES_LUCRO .or. nIdGrupo == GRUPO_ADICOES_DOACAO
				//filtrar contas com Natureza de Adi��o
				If T0S->T0S_NATURE <> NATUREZA_ADICAO .and. T0S->T0S_NATURE <> NATUREZA_ADICAO_EXCLUSAO
					cLogValid += STR0059 + CRLF + CRLF //"Para a 'Origem' informada, a conta da Parte B dever� ser de natureza de 'Adi��o'"
					lRet := .F.
				EndIf
				
			//Grupo de "Exclus�es do Lucro"
			ElseIf nIdGrupo == GRUPO_EXCLUSOES_LUCRO 
				//filtrar contas com Natureza de Exclus�o
				If T0S->T0S_NATURE <> NATUREZA_EXCLUSAO .and. T0S->T0S_NATURE <> NATUREZA_ADICAO_EXCLUSAO
					cLogValid += STR0060 + CRLF + CRLF //"Para a 'Origem' informada, a conta da Parte B dever� ser de natureza de 'Exclus�o'"
					lRet := .F.
				EndIf
				
			//Grupo de "Compensa��o de Preju�zo"
			ElseIf nIdGrupo == GRUPO_COMPENSACAO_PREJUIZO
				 //filtrar contas com Natureza de Compensa��o de Prej./BC Negativa
				If T0S->T0S_NATURE <> NATUREZA_COMPENSACAO_BASE_NEGATIVA 
					cLogValid += STR0061 + CRLF + CRLF //"Para a 'Origem' informada, a conta da Parte B dever� ser de natureza de 'Compensa��o de Prej./BC Negativa'"
					lRet := .F.
				EndIf
				 
			//Grupos de "Dedu��es" e "Compensa��es do Tributo"
			ElseIf nIdGrupo == GRUPO_DEDUCOES_TRIBUTO .or. nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO
				//filtrar contas com Natureza de Dedu��o/Compensa��o de Tributo
				If T0S->T0S_NATURE <> NATUREZA_DEDUCAO_COMPENSACAO_TRIBUTO
					cLogValid += STR0062 + CRLF + CRLF //"Para a 'Origem' informada, a conta da Parte B dever� ser de natureza de 'Dedu��o/Compensa��o de Tributo'"
					lRet := .F.
				EndIf
				 
			EndIf
		Else
			cLogValid += STR0051 + CRLF + CRLF //"A Origem ('T0O_ORIGEM') precisa ser informada antes da conta da parte B do Lalur."
			lRet := .F.
		EndIf
	EndIf
EndIf
	
If AllTrim( SubStr( cCmp , 4 ) ) $ "T0O_IDCUST|T0O_ORIGEM"

	xValueCmp := GetValueCmp( "T0O_IDCUST" )
	
	//O campo "Centro de Custo" s� estar� dispon�vel quando a Origem for "Conta Cont�bil"
	If !Empty( xValueCmp ) .and. ( Empty( cOrigem ) .or. cOrigem <> ORIGEM_CONTA_CONTABIL )
		cLogValid += STR0031 + CRLF + CRLF //"O campo 'Centro de Custo' s� pode ser utilizado quando a Origem for 'Conta Cont�bil' "
		lRet := .F.
	EndIf
	
	//O centro de custo preenchido precisa ser da Filial selecionada no campo "Filial"
	C1P->( DbSetOrder( 3 ) )
	If !Empty( xValueCmp ) .and. !( C1P->( MsSeek( xFilial( "C1P", cFilItem ) + xValueCmp ) ) )
		cLogValid += STR0032 + CRLF + CRLF //"Este Centro de Custo n�o existe na Filial informada no campo T0O_FILITE"
		lRet := .F.
	EndIf
EndIf
	
If AllTrim( SubStr( cCmp , 4 ) ) $ "T0O_TIPOCC|T0O_ORIGEM"

	xValueCmp := GetValueCmp( "T0O_TIPOCC" )
	
	//As op��es "Saldo Anterior" e "Saldo Atual" estar�o dispon�veis somente quando a Origem for "Conta Cont�bil"
	If xValueCmp $ "4|5" .and. ( Empty( cOrigem ) .or. cOrigem <> ORIGEM_CONTA_CONTABIL )
		cLogValid += STR0033 + CRLF + CRLF //"As op��es 'Saldo Anterior' e 'Saldo Atual' s� podem ser utilizadas quando a Origem for 'Conta Cont�bil'"
		lRet := .F.
	EndIf
	
	//Quando a origem for "Lalur � Parte B" a op��o "D�bito" estar� dispon�vel somente nos Grupos "Adi��es do Lucro" e "Adi��es por Doa��o"
	If cOrigem == ORIGEM_LALUR_PARTE_B .and. xValueCmp $ "1|" .and. nIdGrupo <> GRUPO_ADICOES_LUCRO .and. nIdGrupo <> GRUPO_ADICOES_DOACAO
		cLogValid += STR0034 + CRLF + CRLF //"Quando a origem for 'Lalur � Parte B' a op��o 'D�bito' estar� dispon�vel somente nos Grupos 'Adi��es do Lucro' e 'Adi��es por Doa��o'"
		lRet := .F.
	EndIf
	
	//Quando a origem for "Lalur � Parte B" a op��o "Cr�dito" estar� indispon�vel nos Grupos "Adi��es do Lucro" e "Adi��es por Doa��o
	If cOrigem == ORIGEM_LALUR_PARTE_B .and. xValueCmp $ "2|" .and. ( nIdGrupo == GRUPO_ADICOES_LUCRO .or. nIdGrupo == GRUPO_ADICOES_DOACAO )
		cLogValid += STR0035 + CRLF + CRLF //"Quando a origem for 'Lalur � Parte B' a op��o 'Cr�dito' n�o poder� ser utilizada nos Grupos 'Adi��es do Lucro' e 'Adi��es por Doa��o'"
		lRet := .F.
	EndIf 
EndIf

If AllTrim( SubStr( cCmp , 4 ) ) $ "T0O_EFEITO|T0O_ORIGEM"
	
	xValueCmp := GetValueCmp( "T0O_EFEITO" )
	
	//O campo "Efeito na Parte B do Lalur" s� estar� dispon�vel quando a Origem for "Conta Cont�bil"
	If !Empty( xValueCmp ) .and. ( ( Empty( cOrigem ) .or. cOrigem <> ORIGEM_CONTA_CONTABIL ) .and. xValueCmp <> EFEITO_INCLUIR_LANC_AUTOMATICO )
		cLogValid += STR0036 + CRLF + CRLF //"O campo 'Efeito na Parte B do Lalur' s� poder� ser preenchido quando a Origem for 'Conta Cont�bil'"
		lRet := .F.
	EndIf
EndIf

If AllTrim( SubStr( cCmp , 4 ) ) $ "T0O_CODEVE|T0O_ORIGEM"
	
	xValueCmp := GetValueCmp( "T0O_CODEVE" )
	
	If !Empty( xValueCmp )
		//O campo " Evento Tribut�rio" s� estar� dispon�vel quando a Origem for "Evento Tribut�rio"
		If Empty( cOrigem ) .or. cOrigem <> ORIGEM_EVENTO_TRIBUTARIO
			cLogValid += STR0037 + CRLF + CRLF //"O Evento Tribut�rio s� pode ser preenchido quando a Origem for 'Evento Tribut�rio'"
			lRet := .F.
		EndIf

		aAreaBkp := T0N->( GetArea() )
		
		T0N->( DbSetOrder( 2 ) )
		If T0N->( MsSeek( xFilial( "T0N" ) + xValueCmp ) )
			
			T0K->( DbSetOrder( 1 ) )
			If T0K->( DbSeek ( xFilial("T0K") + T0N->T0N_IDFTRI ) )
				cFormaTrib := T0K->T0K_CODIGO
				If cFormaTrib <> TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO
					//Apenas Eventos Tribut�rios que estejam com a forma de tributa��o "Lucro Real - Lucro da explora��o" podem ser selcionados.
					cLogValid += STR0038 + CRLF + CRLF //"Apenas Eventos Tribut�rios que estejam com a forma de tributa��o 'Lucro Real - Lucro da explora��o' podem ser selecionados."
					lRet := .F.
				EndIf
			EndIf
		Else
			cLogValid += STR0039 + CRLF + CRLF //"C�digo inv�lido."
			lRet := .F.
		EndIf
		
		RestArea( aAreaBkp )
	EndIf
EndIf

If AllTrim( SubStr( cCmp , 4 ) ) $ "T0O_PROUNI|T0O_ATIVID"
	
	xValueCmp := GetValueCmp( "T0O_PROUNI" )
	
	//O campo "Prouni" deve ser habilitado se o Tipo de Atividade for "Isen��o"
	If !Empty( xValueCmp ) .and. GetValueCmp( "T0O_ATIVID" ) <> ATIVIDADE_ISENCAO
		cLogValid += STR0040 + CRLF + CRLF //"O campo 'Prouni' somente poder� ser preenchido se o Tipo de Atividade for 'Isen��o'"
		lRet := .F.
	EndIf
EndIf

If AllTrim( SubStr( cCmp , 4 ) ) $ "T0O_PERRED|T0O_ATIVID"
	
	xValueCmp := GetValueCmp( "T0O_PERRED" )
	
	//Este "% de Redu��o" deve ser habilitado se o Tipo de Atividade for "Redu��o"
	If !Empty( xValueCmp ) .and. GetValueCmp( "T0O_ATIVID" ) <> ATIVIDADE_REDUCAO
		cLogValid += STR0041 + CRLF + CRLF //"O campo '% de Redu��o' somente poder� ser preenchido se o Tipo de Atividade for 'Redu��o'"
		lRet := .F.
	EndIf

EndIf

If AllTrim( SubStr( cCmp, 4 ) ) $ "T0O_CODECF|LEC_CODECF"

	If AllTrim( SubStr( cCmp, 4 ) ) $ "T0O_CODECF"
		xValueCmp := GetValueCmp( "T0O_CODECF" )
	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "LEC_CODECF"
		xValueCmp := FWFldGet( "LEC_CODECF" )
	EndIf

	If !Empty( xValueCmp )
		T0K->( DBSetOrder( 1 ) )
		If T0K->( DBSeek( xFilial( "T0K" ) + FWFldGet( "T0N_IDFTRI" ) ) )
			cFormaTrib := T0K->T0K_CODIGO
		EndIf

		T0J->( DBSetOrder( 1 ) )
		If T0J->( DBSeek( xFilial( "T0J" ) + FWFldGet( "T0N_IDTRIB" ) ) )
			cTributo := T0J->T0J_TPTRIB
		EndIf

		//Se nenhum tributo for selecionado nada dever� ser apresentado
		If Empty( cTributo ) .and. cFormaTrib <> TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO
			cLogValid += STR0042 + CRLF + CRLF //"Selecione um tributo antes de selecionar o c�digo da tabela din�mica."
			lRet := .F.
		Else

			If AllTrim( SubStr( cCmp, 4 ) ) $ "LEC_CODECF"
				nIdGrupo := Val( FWFldGet( "LEC_CODGRU" ) )
			EndIf

			cCodTDECF := GetCodECF( cFormaTrib, nIdGrupo, cTributo )

			If !( cCodTDECF $ xValueCmp ) .or. Empty( cCodTDECF )
				cLogValid += STR0039 + CRLF + CRLF //"C�digo inv�lido."
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

If AllTrim( SubStr( cCmp, 4 ) ) $ "T0O_CODLAL|LEC_CODLAL"

	If AllTrim( SubStr( cCmp, 4 ) ) $ "T0O_CODLAL"
		xValueCmp := GetValueCmp( "T0O_CODLAL" )
	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "T0O_CODLAL"
		xValueCmp := FWFldGet( "T0O_CODLAL" )
	EndIf

	If !Empty( xValueCmp )
		T0K->( DBSetOrder( 1 ) )
		If T0K->( DBSeek( xFilial( "T0K" ) + FWFldGet( "T0N_IDFTRI" ) ) )
			cFormaTrib := T0K->T0K_CODIGO
		EndIf

		T0J->( DBSetOrder( 1 ) )
		If T0J->( DBSeek( xFilial( "T0J" ) + FWFldGet( "T0N_IDTRIB" ) ) )
			cTributo := T0J->T0J_TPTRIB
		EndIf

		//Se nenhum tributo for selecionado nada dever� ser apresentado
		If Empty( cTributo ) .and. cFormaTrib <> TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO
			cLogValid += STR0042 + CRLF + CRLF //"Selecione um tributo antes de selecionar o c�digo da tabela din�mica."
			lRet := .F.
		Else
			cCodTDECF := GetCodECF( cFormaTrib, nIdGrupo, cTributo )
			If !( cCodTDECF $ xValueCmp ) .or. Empty( cCodTDECF )
				cLogValid += STR0039 + CRLF + CRLF //"C�digo inv�lido."
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

If AllTrim( SubStr( cCmp , 4 ) ) $ "T0N_CODEVE"
	
	xValueCmp := FWFldGet( "T0N_CODEVE" )
	
	If !Empty( xValueCmp )
		aAreaBkp := T0N->( GetArea() )
		
		T0N->( DbSetOrder( 2 ))
		If T0N->( MsSeek( xFilial( "T0N" ) + xValueCmp ) )
		
			T0K->( DbSetOrder( 1 ) )
			If T0K->( DbSeek ( xFilial( "T0K" ) + T0N->T0N_IDFTRI ) )
				cFormaTrib := T0K->T0K_CODIGO
				If cFormaTrib <> TRIBUTACAO_LUCRO_REAL_ATIV_RURAL
					//Apenas Eventos Tribut�rios que estejam com a forma de tributa��o "Lucro Real - Atividade Rural" podem ser selcionados.
					cLogValid += STR0043 + CRLF + CRLF //"Apenas Eventos Tribut�rios que estejam com a forma de tributa��o 'Lucro Real - Atividade Rural' podem ser selecionados."
					lRet := .F.
				EndIf
			EndIf
			
			If FWFldGet( "T0N_IDTRIB" ) <> T0N->T0N_IDTRIB
				cLogValid += STR0074 + CRLF + CRLF //"Apenas eventos com o mesmo tributo podem ser relacionados"
				lRet := .F.
			EndIf
		Else
			cLogValid += STR0039 + CRLF + CRLF //'C�digo inv�lido.'
			lRet := .F.
		EndIf
		
		RestArea( aAreaBkp )
	EndIf
EndIf

If AllTrim( SubStr( cCmp , 4 ) ) $ "T0N_COTRIB"
	
	xValueCmp := FWFldGet( "T0N_COTRIB" )
	If !Empty( xValueCmp )
		T0J->( DbSetOrder( 2 ) )
		If T0J->( DbSeek ( xFilial( "T0J" ) + xValueCmp ) )
			cTributo := T0J->T0J_TPTRIB
			If cTributo <> TRIBUTO_IRPJ .and. cTributo <> TRIBUTO_CSLL
				cLogValid += STR0039 + CRLF + CRLF //'C�digo inv�lido.'
				lRet := .F.
			EndIf
		Else
			cLogValid += STR0039 + CRLF + CRLF //'C�digo inv�lido.'
			lRet := .F.
		EndIf
	EndIf
EndIf

If AllTrim( SubStr( cCmp , 4 ) ) $ "T0O_CODTDE"

	xValueCmp := GetValueCmp( "T0O_CODTDE" )
	
	If !Empty( xValueCmp )
		If !( "N600" $ xValueCmp )
			cLogValid += STR0039 + CRLF + CRLF //'C�digo inv�lido.'
			lRet := .F.
		 EndIf
	 EndIf
EndIf

If AllTrim( SubStr( cCmp, 4 ) ) $ "LEC_CODGRU"
	xValueCmp := FWFldGet( "LEC_CODGRU" )

	If !Empty( xValueCmp )

		T0K->( DBSetOrder( 1 ) )
		If T0K->( DBSeek( xFilial( "T0K" ) + FWFldGet( "T0N_IDFTRI" ) ) )
			cFormaTrib := T0K->T0K_CODIGO
		EndIf

		cGrupo := GetGrupo( cFormaTrib )

		If !( xValueCmp $ cGrupo )
			cLogValid += STR0039 + CRLF + CRLF //"C�digo inv�lido."
			lRet := .F.
		EndIf
	EndIf

EndIf

If AllTrim( SubStr( cCmp, 4 ) ) $ "LEC_ATIVID|LEC_PROUNI|LEC_PERRED|LEC_CODTDE"

	If Val( FWFldGet( "LEC_CODGRU" ) ) <> GRUPO_RECEITA_LIQUIDA_ATIVIDA
		cLogValid += STR0073 + CRLF + CRLF //"Este campo s� pode ser editado quando o Grupo for 'Receita L�quida p/Atividade'."
		lRet := .F.
	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "LEC_PROUNI" .and. FWFldGet( "LEC_ATIVID" ) <> ATIVIDADE_ISENCAO
		cLogValid += STR0040 + CRLF + CRLF //"O campo 'Prouni' somente poder� ser preenchido se o Tipo de Atividade for 'Isen��o'"
		lRet := .F.
	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "LEC_PERRED" .and. FWFldGet( "LEC_ATIVID" ) <> ATIVIDADE_REDUCAO
		cLogValid += STR0041 + CRLF + CRLF //"O campo '% de Redu��o' somente poder� ser preenchido se o Tipo de Atividade for 'Redu��o'"
		lRet := .F.
	EndIf

EndIf

If !Empty( cLogValid )
	Help( ,, "HELP",, cLogValid, 1, 0 )
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} FilSXBEven

Fun��o respons�vel por gerenciar os filtros que precisam ser
aplicados nas consultas padr�es do cadastro de evento tribut�rio

@Param cCmp - Campo a qual o filtro ser� aplicado
		
@return Nil

@author David Costa
@since 27/04/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function FilSXBEven( cCmp )

Local cRet			as character
Local cTributo	as character
Local cFormaTrib	as character
Local cCodTDECF	as character
Local cGrupo		as character
Local nIdGrupo	as numeric

cRet		:=	""
cTributo	:=	""
cFormaTrib	:=	""
cCodTDECF	:=	""
cGrupo		:=	""
nIdGrupo	:=	0

If "T0N_CODEVE" $ cCmp
	//Dever� apresentar para sele��o, apenas os Eventos Tribut�rios que estejam com a forma de tributa��o "Lucro Real - Atividade Rural"
	cRet := "@# T0N_IDFTRI == 'ebf125bc-3140-9c7b-1e01-de4a61fd16e3' @#"

ElseIf "T0O_CODEVE" $ cCmp	
	//Devem ser listados apenas os Eventos Tribut�rios com a forma de tributa��o "Lucro Real - Lucro da explora��o"
	cRet := "@# T0N_IDFTRI == '1a46ceda-ffae-fa0f-0d9b-693dcb256849' @#"

//Apresentar somente os tributos referentes � IRPJ, CSLL. Listar informa��es da tabela de Tributo.
ElseIf "T0N_COTRIB" $ cCmp
	cRet := "@# T0J_TPTRIB == '" + TRIBUTO_IRPJ + "' .or. T0J_TPTRIB == '" + TRIBUTO_CSLL + "' @#"

//Regras de visibilidade dos itens da tabela din�mica da ECF
ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "T0O_CODECF|LEC_CODECF"

	T0K->( DBSetOrder( 1 ) )
	If T0K->( DBSeek( xFilial( "T0K" ) + FWFldGet( "T0N_IDFTRI" ) ) )
		cFormaTrib := T0K->T0K_CODIGO
	EndIf

	T0J->( DBSetOrder( 1 ) )
	If T0J->( DBSeek( xFilial( "T0J" ) + FWFldGet( "T0N_IDTRIB" ) ) )
		cTributo := T0J->T0J_TPTRIB
	EndIf

	If "T0O_CODECF" $ cCmp
		nIdGrupo := GetValueCmp( "T0O_IDGRUP" )
	ElseIf "LEC_CODECF" $ cCmp
		nIdGrupo := Val( FWFldGet( "LEC_CODGRU" ) )
	EndIf

	cCodTDECF := GetCodECF( cFormaTrib, nIdGrupo, cTributo )

	If Empty( cCodTDECF )
		cRet := "@# 1 == 0 @#" //Nada ser� apresentado
	Else
		cRet := "@# CH6_CODREG == '" + cCodTDECF + "' @#"
	EndIf

//Regras de visibilidade dos itens da tabela din�mica do Lalur
ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "T0O_CODLAL|LEC_CODLAL"

	T0K->( DBSetOrder( 1 ) )
	If T0K->( DBSeek( xFilial( "T0K" ) + FWFldGet( "T0N_IDFTRI" ) ) )
		cFormaTrib := T0K->T0K_CODIGO
	EndIf

	T0J->( DBSetOrder( 1 ) )
	If T0J->( DBSeek( xFilial( "T0J" ) + FWFldGet( "T0N_IDTRIB" ) ) )
		cTributo := T0J->T0J_TPTRIB
	EndIf

	If "T0O_CODLAL" $ cCmp
		nIdGrupo := GetValueCmp( "T0O_IDGRUP" )
	ElseIf "LEC_CODLAL" $ cCmp
		nIdGrupo := Val( FWFldGet( "LEC_CODGRU" ) )
	EndIf

	cCodTDECF := GetCodECF( cFormaTrib, nIdGrupo, cTributo )

	If Empty( cCodTDECF )
		cRet := "@# 1 == 0 @#" //Nada ser� apresentado
	Else
		cRet := "@# CH8_CODREG == '" + cCodTDECF + "' @#"
	EndIf

ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "T0O_CODTDE|LEC_CODTDE"

	T0K->( DBSetOrder( 1 ) )
	If T0K->( DBSeek( xFilial( "T0K" ) + FWFldGet( "T0N_IDFTRI" ) ) )
		cFormaTrib := T0K->T0K_CODIGO
	EndIf

	If cFormaTrib == TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO
		cRet := "@# CH6_CODREG == 'N600 ' @#"
	Else
		cRet := "@# 1 == 0 @#" //Nada ser� apresentado
	EndIf

ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "LEC_CODGRU"

	T0K->( DBSetOrder( 1 ) )
	If T0K->( DBSeek( xFilial( "T0K" ) + FWFldGet( "T0N_IDFTRI" ) ) )
		cFormaTrib := T0K->T0K_CODIGO
	EndIf

	cGrupo := GetGrupo( cFormaTrib )

	cRet := "@#LEE_CODIGO $ '" + cGrupo + "' @#"

elseif 'T0O_FILITE' $ cCmp

	cRet := "@#C1E_ATIVO = '1' @#"

EndIf

Return( cRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} PutcModel
Fun��o respons�vel por alimentar a variavel global cModel com o nome do model em edi��o no momento

@Param cModel - Nome do Model
		cField - Nome do campo que est� em edi��o
		
@return .T.

@author David Costa
@since 28/04/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function PutcModel( cModel, cField  )

If !Empty( cField ) .and. ( cField $ "|T0O_ORIGEM|T0O_FILITE|T0O_CODCC|T0O_OPERAC|T0O_CODCC|T0O_IDCUST|T0O_TIPOCC|T0O_EFEITO|T0O_CODEVE|T0O_PROUNI|T0O_ATIVID|T0O_PERRED|T0O_CODECF|T0O_CODTDE|T0O_CODLAL|T0O_CODPAB|" .or. "T0R_" $ cField )
	PutGlbValue( "cModel" , cModel )
EndIf

Return( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetValueCmp

Retorna um valor de um campo da linha em edi��o no formul�rio.

@Param		cField - Nome do campo que est� em edi��o

@Return	.T.

@Author	David Costa
@Since		28/04/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Function GetValueCmp( cField )

Local cModel		as character
Local oModel		as object
Local oModelEdit	as object
Local xRet

cModel		:=	GetGlbValue( "cModel" )
oModel		:=	FWModelActive()
oModelEdit	:=	oModel:GetModel( cModel )
xRet		:=	Nil

If !Empty( cModel ) .and. Alltrim(FunName()) <> "TAFA444"
	oModelEdit := oModel:GetModel( cModel )
	xRet := oModelEdit:GetValue( cField )
EndIf

Return( xRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} VldHistEve
Valida se o Historico padr�o pode ser inserido conforme regras de negocio

@Param  cAction -> A��o que esta sendo executada

@Return lRet

@Author David Costa
@Since 29/04/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldHistEve( cAcao )

Local oModel		as object
Local oModelHist	as object
Local cLogValid	as character
Local cModel		as character
Local nI			as numeric
Local lRet			as logical

oModel		:=	Nil
oModelHist	:=	Nil
cLogValid	:=	""
cModel		:=	""
nI			:=	0
lRet		:=	.T.

//O campo "Hist�rico Padr�o" s� estar� dispon�vel quando a Origem for "Conta Cont�bil".
If GetValueCmp( "T0O_ORIGEM" ) <> ORIGEM_CONTA_CONTABIL
	
	If cAcao == 'ALTERACAO_ORIGEM'
		
		cModel		:= GetGlbValue( "cModel" )
		oModel		:= FWModelActive()
		cModel		:= StrTran( cModel, "T0O_", "T0R_" )
		oModelHist	:= oModel:GetModel( cModel )
		
		For nI := 1 To oModelHist:Length()
			oModelHist:GoLine( nI )
			If !oModelHist:IsDeleted() .and. !Empty( oModelHist:GetValue( "T0R_IDHIST" ) )
				lRet := .F.
				exit
			EndIf
		Next nI

	ElseIf cAcao <> "DELETE" .and. !lCopia
		cLogValid := STR0044+ CRLF //"O Hist�rico Padr�o s� est� dispon�vel quando a Origem � 'Conta Cont�bil'."
		lRet := .F.
	EndIf
	
EndIf

If !Empty( cLogValid )
	Help( ,, "HELP",, cLogValid, 1, 0 )
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel

Fun��o de grava��o dos dados, chamada no
final, no momento da confirma��o do modelo.

@Param		oModel	- Modelo de dados

@Return	lRet

@Author	David Costa
@Since		29/04/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local oModelT0O	as object
Local oModelT0N	as object
Local cModel		as character
Local cLogSave	as character
Local cFormaTrib	as character
Local nI			as numeric
Local nAux			as numeric
Local nIndiceT0O	as numeric
Local aGrupos		as array
Local lRet			as logical
Local lLucroEx	as logical

oModelT0O	:=	Nil
oModelT0N	:=	Nil
cModel		:=	""
cLogSave	:=	""
cFormaTrib	:=	""
nI			:=	0
nAux		:=	0
nIndiceT0O	:=	0
aGrupos	:=	GetGrupos( , .T. )
lRet		:=	.F.
lLucroEx	:=	.F. //N�o modificar para False dentro do For

//Percorre todos os Grupos Tribut�rios
For nI := 1 to Len( aGrupos )
	cModel := "MODEL_T0O_" + aGrupos[nI][PARAM_GRUPO_NOME]

	oModelT0O := oModel:GetModel( cModel )
	nAux := 0

	//Percorre os Itens do Grupo Tribut�rio
	For nIndiceT0O := 1 to oModelT0O:Length()
		oModelT0O:GoLine( nIndiceT0O )

		If !oModelT0O:IsDeleted()
			Do Case
				Case aGrupos[nI][PARAM_GRUPO_ID] == GRUPO_COMPENSACAO_PREJUIZO

					//No Grupo "Compensa��o de Preju�zo" o percentual limite de compensa��o � �nico para todos os Itens Tribut�rios que forem inclu�dos no Grupo
					If nAux == 0
						nAux := oModelT0O:GetValue( "T0O_PERDED" )
					ElseIf nAux <> oModelT0O:GetValue( "T0O_PERDED" )
						cLogSave += STR0045 + CRLF + CRLF //"No Grupo 'Compensa��o de Preju�zo' o percentual limite de compensa��o precisa ser o mesmo para todos os Itens Tribut�rios."
					EndIf
			EndCase

			//Apenas um Item Tribut�rio pode ser configurado com origem "Evento Tribut�rio"
			If oModelT0O:GetValue( "T0O_ORIGEM" ) == ORIGEM_EVENTO_TRIBUTARIO

				If !lLucroEx
					lLucroEx := .T.
				Else
					cLogSave := STR0046 + CRLF + CRLF //"Apenas um Item Tribut�rio pode ser configurado com a origem 'Evento Tribut�rio'"
				EndIf
			EndIf
		EndIf
	Next nIndiceT0O
Next nI

oModelT0N := oModel:GetModel( "MODEL_T0N" )
cFormaTrib := xFunID2Cd( M->T0N_IDFTRI, "T0K", 1 )
If Empty( oModelT0N:GetValue( "T0N_COTRIB" ) ) .and. cFormaTrib <> TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO

	cLogSave += STR0049 + CRLF + CRLF //"O Tributo n�o foi preenchido."
EndIf

If !Empty( cLogSave )
	Help( ,, "HELP",, cLogSave, 1, 0 )
	lRet := .F.
Else
	FWFormCommit( oModel )
	lRet := .T.
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} ConsC1PA

Consulta Espec�fica para Centro de Custo.

@Return	.T.

@Author	David Costa
@Since		03/05/2016
@Version	1.0

@Altered by Felipe C. Seolin in 28/12/2016 - Alterado de MsSelect para FWMarkBrowse
/*/
//---------------------------------------------------------------------
Function ConsC1PA()

Local cAliasQry	as character
Local cTempTab	as character
Local cCampos	as character
Local cChave	as character
Local cTitle	as character
Local cReadVar	as character
Local cCombo	as character
Local cFilItem	as character
Local cSelect	as character
Local cFrom		as character
Local cWhere	as character
Local cOrderBy	as character
Local nPos		as numeric
Local nI		as numeric
Local aStruct	as array
Local aColumns	as array
Local aAux		as array
Local aIndex	as array
Local aSeek		as array
Local aCombo	as array
Local aID		as array
Local aCodigo	as array
Local aDescri	as array
Local oTmpTab	as object

cAliasQry := GetNextAlias()
cTempTab  := ""
cCampos	  := "C1P_ID|C1P_CODCUS|C1P_CCUS"
cChave	  := "C1P_ID"
cTitle	  := STR0047 //"Centro de Custo"
cReadVar  := ReadVar()
cCombo	  := ""
cFilItem  := xFunCh2ID( GetValueCmp( "T0O_FILITE" ), "C1E", 1 )
cSelect	  := ""
cFrom	  := ""
cWhere	  := ""
cOrderBy  := ""
nPos	  := 0
nI		  := 0
aStruct	  := {}
aColumns  := {}
aAux	  := {}
aIndex	  := {}
aSeek	  := {}
aCombo	  := {}
aID		  := TamSX3( "C1P_ID" )
aCodigo	  := TamSX3( "C1P_CODCUS" )
aDescri	  := TamSX3( "C1P_CCUS" )
oTmpTab	  := Nil

//------------------------------------
// Executa consulta ao banco de dados
//------------------------------------
cSelect	:= "C1P_ID, C1P_CODCUS, C1P_CCUS "
cFrom		:= RetSqlName( "C1P" ) + " C1P "
cWhere		:= "    C1P.C1P_FILIAL = '" + xFilial( "C1P", cFilItem ) + "' "
cWhere		+= "AND C1P.D_E_L_E_T_ = '' "
cOrderBy	:= "C1P.C1P_ID "

cSelect	:= "%" + cSelect 	+ "%"
cFrom  	:= "%" + cFrom   	+ "%"
cWhere		:= "%" + cWhere  	+ "%"
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

//------------------------------------
// Monta array com a estrutura de campos da tabela temporaria
//------------------------------------
aStruct := {  {'MARK'	  	, "C"			, 2				, 0 		},;
			  {'C1P_ID'	   	, aID[3]	  	, aID[1]		, aID[2]	},;
			  {'C1P_CODCUS'	, aCodigo[3]	, aCodigo[1]	, aCodigo[2]},;
			  {'C1P_CCUS'  	, aDescri[3]	, aDescri[1]	, aDescri[2]} }

cTempTab := getNextAlias()

//------------------------------------
// Instancia o objeto Temporary Table
//------------------------------------
oTmpTab := FWTemporaryTable():New(cTempTab, aStruct)

oTmpTab:AddIndex("1", {"C1P_ID"} )
oTmpTab:AddIndex("2", {"C1P_CODCUS"} )
oTmpTab:AddIndex("3", {"C1P_CCUS"} )

oTmpTab:Create()

DbSelectArea(cTempTab)
(cTempTab)->(DbSetOrder(1))
(cTempTab)->(DBGoTop())

//------------------------------------
// Popula arquivo de dados tempor�rio
//------------------------------------
While ( cAliasQry )->( !Eof() )
	If RecLock( ( cTempTab ), .T. )
		( cTempTab )->MARK		 :=	"  "
		( cTempTab )->C1P_ID	 :=	( cAliasQry )->C1P_ID
		( cTempTab )->C1P_CODCUS :=	( cAliasQry )->C1P_CODCUS
		( cTempTab )->C1P_CCUS	 :=	( cAliasQry )->C1P_CCUS
		( cTempTab )->( MsUnLock() )
	EndIf
	( cAliasQry )->( DBSkip() )
EndDo
( cAliasQry )->( DBCloseArea() )

//---------------------------
// Cria estrutura de colunas
//---------------------------
For nI := 1 to Len( aStruct )
	If aStruct[nI,1] $ cCampos
		nPos ++
		aAdd( aColumns, FWBrwColumn():New() )
		aColumns[nPos]:SetData( &( "{ || " + aStruct[nI,1] + " }" ) )
		aColumns[nPos]:SetTitle( RetTitle( aStruct[nI,1] ) )
		aColumns[nPos]:SetDecimal( aStruct[nI,4] )
		aColumns[nPos]:SetPicture( PesqPict( SubStr( aStruct[nI,1], 1, At( "_", aStruct[nI,1] ) - 1 ), aStruct[nI,1] ) )
		aColumns[nPos]:SetType( aStruct[nI,2] )
		aColumns[nPos]:SetAlign( Iif( aStruct[nI,2] == "N", 2, 1 ) )

		If aStruct[nI,2] == "C"
			DBSelectArea( "SX3" )
			SX3->( DBSetOrder( 2 ) )
			If SX3->( MsSeek( aStruct[nI,1] ) )
				cCombo := X3Cbox()
			EndIf
			If !Empty( cCombo )
				aCombo := StrToKarr( cCombo, ";" )
				aColumns[nPos]:SetOptions( aCombo )
			EndIf
		EndIf
		//----------------------------
		// Cria estrutura de pesquisa
		//----------------------------
		aAdd( aIndex, aStruct[nI,1] )
		aAdd( aSeek, { RetTitle( aStruct[nI,1] ), { { "", aStruct[nI,2], aStruct[nI,3], aStruct[nI,4], RetTitle( aStruct[nI,1] ), PesqPict( SubStr( aStruct[nI,1], 1, At( "_", aStruct[nI,1] ) - 1 ), aStruct[nI,1] ), } } } )
	EndIf
Next nI

//---------------------------------
// Executa a montagem da interface
//---------------------------------
TAF433SXB( cTitle, cTempTab, cReadVar, cChave, aColumns, aSeek )

//---------------------------------
//Exclui a tabela e fecha o alias
//---------------------------------
oTmpTab:Delete()
oTmpTab := Nil

Return( .T. )

//---------------------------------------------------------------------
/*/{Protheus.doc} ConsC1OA

Consulta Espec�fica para Conta Cont�bil,
funcional para trabalhar junto a coluna de filial em Grid.

@Return	.T.

@Author	David Costa
@Since		03/05/2016
@Version	1.0

@Altered by Felipe C. Seolin in 28/12/2016 - Alterado de MsSelect para FWMarkBrowse
		 by Denis Souza in 18/12/2019 - Substituicao consulta com Driver ISAM por FwTemporaryTable
/*/
//---------------------------------------------------------------------
Function ConsC1OA() 

Local cAliasQry	:= GetNextAlias()
Local cTempTab	:= ""
Local cCampos	:= "C1O_CODIGO|C1O_DESCRI"
Local cChave	:= "C1O_CODIGO"
Local cTitle	:= STR0048 //"Conta Cont�bil"
Local cReadVar	:= ReadVar()
Local cCombo	:= ""
Local cFilItem	:= xFunCh2ID( GetValueCmp( "T0O_FILITE" ), "C1E", 1 )
Local cSelect	:= ""
Local cFrom		:= ""
Local cWhere	:= ""
Local cOrderBy	:= ""
Local nPos		:= 0
Local nI		:= 0
Local aStruct	:= {}
Local aColumns	:= {}
Local aAux		:= {}
Local aIndex	:= {}
Local aSeek		:= {}
Local aCombo	:= {}
Local aCodigo	:= TamSX3( "C1O_CODIGO" )
Local aDescri	:= TamSX3( "C1O_DESCRI" )
Local oTmpTab	:= Nil

cAliasQry := GetNextAlias()
cTempTab  := ""
cCampos	  := "C1O_CODIGO|C1O_DESCRI"
cChave	  := "C1O_CODIGO"
cTitle	  := STR0048 //"Conta Cont�bil"
cReadVar  := ReadVar()
cCombo	  := ""
cFilItem  := xFunCh2ID( GetValueCmp( "T0O_FILITE" ), "C1E", 1 )
cSelect	  := ""
cFrom	  := ""
cWhere	  := ""
cOrderBy  := ""
nPos	  := 0
nI		  := 0
aStruct	  := {}
aColumns  := {}
aAux	  := {}
aIndex	  := {}
aSeek	  := {}
aCombo	  := {}
aCodigo	  := TamSX3( "C1O_CODIGO" )
aDescri	  := TamSX3( "C1O_DESCRI" )

//------------------------------------
// Executa consulta ao banco de dados
//------------------------------------
cSelect	 := "C1O_CODIGO, C1O_DESCRI "
cFrom	 := RetSqlName( "C1O" ) + " C1O "
cWhere	 := " C1O.C1O_FILIAL = '" + xFilial( "C1O", cFilItem ) + "' "
cWhere	 += "AND C1O.D_E_L_E_T_ = '' "
cOrderBy := "C1O.C1O_CODIGO "

cSelect	 := "%" + cSelect 	+ "%"
cFrom  	 := "%" + cFrom   	+ "%"
cWhere	 := "%" + cWhere  	+ "%"
cOrderBy := "%" + cOrderBy	+ "%"

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

//------------------------------------
// Monta array com a estrutura de campos da tabela temporaria
//------------------------------------
aStruct := { {"MARK"	  	, "C"		, 2			, 0			},;
			 {"C1O_CODIGO"	, aCodigo[3], aCodigo[1], aCodigo[2]},;
			 {"C1O_DESCRI"	, aDescri[3], aDescri[1], aDescri[2]} }

cTempTab := getNextAlias()

//------------------------------------
// Instancia o objeto Temporary Table
//------------------------------------
oTmpTab := FWTemporaryTable():New(cTempTab, aStruct)

oTmpTab:AddIndex("1", {"C1O_CODIGO"} )
oTmpTab:AddIndex("2", {"C1O_DESCRI"} )

oTmpTab:Create()

DbSelectArea(cTempTab)
(cTempTab)->(DbSetOrder(1))
(cTempTab)->(DBGoTop())

//------------------------------------
// Popula arquivo de dados tempor�rio
//------------------------------------
While ( cAliasQry )->( !Eof() )
	If RecLock( ( cTempTab ), .T. )
		( cTempTab )->MARK		 := "  "
		( cTempTab )->C1O_CODIGO := ( cAliasQry )->C1O_CODIGO
		( cTempTab )->C1O_DESCRI := ( cAliasQry )->C1O_DESCRI
		( cTempTab )->( MsUnLock() )
	EndIf
	( cAliasQry )->( DBSkip() )
EndDo
( cAliasQry )->( DBCloseArea() )

//---------------------------
// Cria estrutura de colunas
//---------------------------
For nI := 1 to Len( aStruct )
	If aStruct[nI,1] $ cCampos
		nPos ++
		aAdd( aColumns, FWBrwColumn():New() )
		aColumns[nPos]:SetData( &( "{ || " + aStruct[nI,1] + " }" ) )
		aColumns[nPos]:SetTitle( RetTitle( aStruct[nI,1] ) )
		aColumns[nPos]:SetDecimal( aStruct[nI,4] )
		aColumns[nPos]:SetPicture( PesqPict( SubStr( aStruct[nI,1], 1, At( "_", aStruct[nI,1] ) - 1 ), aStruct[nI,1] ) )
		aColumns[nPos]:SetType( aStruct[nI,2] )
		aColumns[nPos]:SetAlign( Iif( aStruct[nI,2] == "N", 2, 1 ) )

		If aStruct[nI,2] == "C"
			DBSelectArea( "SX3" )
			SX3->( DBSetOrder( 2 ) )
			If SX3->( MsSeek( aStruct[nI,1] ) )
				cCombo := X3Cbox()
			EndIf
			If !Empty( cCombo )
				aCombo := StrToKarr( cCombo, ";" )
				aColumns[nPos]:SetOptions( aCombo )
			EndIf
		EndIf
		//----------------------------
		// Cria estrutura de pesquisa
		//----------------------------
		aAdd( aIndex, aStruct[nI,1] )
		aAdd( aSeek, { RetTitle( aStruct[nI,1] ), { { "", aStruct[nI,2], aStruct[nI,3], aStruct[nI,4], RetTitle( aStruct[nI,1] ), PesqPict( SubStr( aStruct[nI,1], 1, At( "_", aStruct[nI,1] ) - 1 ), aStruct[nI,1] ), } } } )
	EndIf
Next nI

//---------------------------------
// Executa a montagem da interface
//---------------------------------
TAF433SXB( cTitle, cTempTab, cReadVar, cChave, aColumns, aSeek )

//---------------------------------
//Exclui a tabela e fecha o alias
//---------------------------------
oTmpTab:Delete()

Return( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} GatiIDCUST
Gatilho do campo T0O_IDCUST para o Campo T0O_DCUSTO

@Return cValueCmp

@Author David Costa
@Since 03/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function GatiIDCUST( )

Local cValueCmp	as character
Local cFilItem	as character

cValueCmp	:=	&( ReadVar() )
cFilItem	:=	""

If !Empty( cValueCmp )
	
	cFilItem	:= XFUNCh2ID( GetValueCmp( "T0O_FILITE" ) , 'C1E' , 1 )

	DbSelectArea( "C1P" )
	C1P->( DbSetOrder( 3 ) )
	If MsSeek(xFilial( "C1P", cFilItem ) + cValueCmp )
		cValueCmp := Posicione( "C1P", 3, xFilial( "C1P", cFilItem ) + cValueCmp, "C1P->( AllTrim( C1P_CODCUS )+' - '+SubStr( C1P_CCUS, 1, 60 ) )" )
	EndIf
EndIf

Return( cValueCmp )

//-------------------------------------------------------------------
/*/{Protheus.doc} GatiCODCC
Gatilho do campo T0O_CODCC para o campo T0O_IDCC

@Return cValueCmp

@Author David Costa
@Since 03/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function GatiCODCC( )

Local cValueCmp	as character
Local cFilItem	as character

cValueCmp	:=	&( ReadVar() )
cFilItem	:=	""

If !Empty( cValueCmp )
	
	cFilItem	:= XFUNCh2ID( GetValueCmp( "T0O_FILITE" ) , 'C1E' , 1 )

	DbSelectArea( "C1O" )
	C1O->( DbSetOrder( 1 ) )
	If MsSeek( xFilial( "C1O", cFilItem ) + cValueCmp )
		cValueCmp := Posicione( "C1O", 1, xFilial( "C1O", cFilItem ) + cValueCmp, "C1O->C1O_ID" )
	EndIf
EndIf

Return( cValueCmp )
//-------------------------------------------------------------------
/*/{Protheus.doc} GatiCODCC2
Gatilho do campo T0O_CODCC para o campo T0O_DCONTC

@Return cValueCmp

@Author David Costa
@Since 03/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function GatiCODCC2( )

Local cValueCmp	as character
Local cFilItem	as character

cValueCmp	:=	&( ReadVar() )
cFilItem	:=	""

If !Empty( cValueCmp )
	
	cFilItem	:= XFUNCh2ID( GetValueCmp( "T0O_FILITE" ) , 'C1E' , 1 )

	DbSelectArea( "C1O" )
	C1O->( DbSetOrder( 1 ) )
	If MsSeek( xFilial( "C1O", cFilItem ) + cValueCmp )
		cValueCmp := Posicione( "C1O", 1, xFilial( "C1O", cFilItem ) + cValueCmp, "C1O->( AllTrim( C1O_DESCRI ) )" )
	EndIf
EndIf

Return( cValueCmp )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCodECF
Fun��o para cria��o de consultas especificas para o eventro tribut�rio

@Param cFormaTrib -> Forma de tributa��o do Evento tribut�rio
		nIdGrupo -> Id do grupo tribut�rio
		cTributo -> Tributo IRPJ ou CSLL

@Return cCodTDECF

@Author David Costa
@Since 09/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function GetCodECF( cFormaTrib, nIdGrupo, cTributo )

Local cCodTDECF	as character
Local cQualifPJ	as character

cCodTDECF	:=	""
cQualifPJ	:=	""

//Lucro da explora��o n�o apresenta o campo tributo
If cFormaTrib == TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO
	If nIdGrupo == GRUPO_RECEITA_LIQUIDA_ATIVIDA .or. nIdGrupo == GRUPO_LUCRO_EXPLORACAO
		cCodTDECF := "N600"
 	EndIf
Else
	If cTributo == TRIBUTO_IRPJ
		Do Case
			Case cFormaTrib == TRIBUTACAO_LUCRO_PRESUMIDO
				If nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ1 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ2 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ3;
			 		.or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ4 .or. nIdGrupo == GRUPO_DEMAIS_RECEITAS .or. nIdGrupo == GRUPO_EXCLUSOES_RECEITA
			 		cCodTDECF := "P200"
			 	ElseIf nIdGrupo == GRUPO_ADICIONAIS_TRIBUTO .or. nIdGrupo == GRUPO_DEDUCOES_TRIBUTO .or. nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO
			 		cCodTDECF := "P300"
			 	EndIf
			Case cFormaTrib == TRIBUTACAO_LUCRO_ARBITRADO
				If nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ1 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ2 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ3;
			 		.or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ4 .or. nIdGrupo == GRUPO_DEMAIS_RECEITAS .or. nIdGrupo == GRUPO_EXCLUSOES_RECEITA
			 		cCodTDECF := "T120"
			 	ElseIf nIdGrupo == GRUPO_ADICIONAIS_TRIBUTO .or. nIdGrupo == GRUPO_DEDUCOES_TRIBUTO .or. nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO
			 		cCodTDECF := "T150"
			 	EndIf
			Case cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA
				If nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ1 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ2 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ3;
			 		.or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ4 .or. nIdGrupo == GRUPO_DEMAIS_RECEITAS .or. nIdGrupo == GRUPO_EXCLUSOES_RECEITA
			 		cCodTDECF := "N500"
			 	ElseIf nIdGrupo == GRUPO_ADICIONAIS_TRIBUTO .or. nIdGrupo == GRUPO_DEDUCOES_TRIBUTO .or. nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO
			 		cCodTDECF := "N620"
			 	EndIf
			Case cFormaTrib == TRIBUTACAO_IMUNE .or. cFormaTrib == TRIBUTACAO_ISENTA
				If nIdGrupo == GRUPO_BASE_CALCULO .or. nIdGrupo == GRUPO_DEDUCOES_TRIBUTO .or. nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO
			 		cCodTDECF := "U180"
			 	EndIf
			Case cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL_ATIV_RURAL
				
				cQualifPJ := GetQualiPJ()
				
				If nIdGrupo == GRUPO_ADICOES_LUCRO .or. nIdGrupo == GRUPO_EXCLUSOES_LUCRO .or. nIdGrupo == GRUPO_COMPENSACAO_PREJUIZO .or. nIdGrupo == GRUPO_RESULTADO_OPERACIONAL .or. nIdGrupo == GRUPO_RESULTADO_NAO_OPERACIONAL .or. nIdGrupo == GRUPO_ADICOES_DOACAO

					If cQualifPJ == QUALIFICACAO_PJ_EM_GERAL
			 			cCodTDECF := "M300A"
			 		ElseIf cQualifPJ == QUALIFICACAO_PJ_FINANCEIRO
			 			cCodTDECF := "M300B"
			 		ElseIf cQualifPJ == QUALIFICACAO_PJ_SOCIEDADE_SEG_PREVIDENCIA_COMPL
			 			cCodTDECF := "M300C"
			 		EndIf
			 	ElseIf nIdGrupo == GRUPO_ADICIONAIS_TRIBUTO .or. nIdGrupo == GRUPO_DEDUCOES_TRIBUTO .or. nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO
			 		If cQualifPJ == QUALIFICACAO_PJ_EM_GERAL
			 			cCodTDECF := "N630A"
			 		ElseIf cQualifPJ == QUALIFICACAO_PJ_FINANCEIRO
			 			cCodTDECF := "N630B"
			 		EndIf
			 	EndIf
		EndCase
	ElseIf cTributo == TRIBUTO_CSLL
		Do Case
			Case cFormaTrib == TRIBUTACAO_LUCRO_PRESUMIDO
				If nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ1 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ2 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ3;
			 		.or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ4 .or. nIdGrupo == GRUPO_DEMAIS_RECEITAS .or. nIdGrupo == GRUPO_EXCLUSOES_RECEITA
			 		cCodTDECF := "P400"
			 	ElseIf nIdGrupo == GRUPO_ADICIONAIS_TRIBUTO .or. nIdGrupo == GRUPO_DEDUCOES_TRIBUTO .or. nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO
			 		cCodTDECF := "P500"
			 	EndIf
			Case cFormaTrib == TRIBUTACAO_LUCRO_ARBITRADO
				If nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ1 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ2 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ3;
			 		.or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ4 .or. nIdGrupo == GRUPO_DEMAIS_RECEITAS .or. nIdGrupo == GRUPO_EXCLUSOES_RECEITA
			 		cCodTDECF := "T170"
			 	ElseIf nIdGrupo == GRUPO_ADICIONAIS_TRIBUTO .or. nIdGrupo == GRUPO_DEDUCOES_TRIBUTO .or. nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO
			 		cCodTDECF := "T181"
			 	EndIf
			Case cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA
				If nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ1 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ2 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ3;
			 		.or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ4 .or. nIdGrupo == GRUPO_DEMAIS_RECEITAS .or. nIdGrupo == GRUPO_EXCLUSOES_RECEITA
			 		cCodTDECF := "N650"
			 	ElseIf nIdGrupo == GRUPO_ADICIONAIS_TRIBUTO .or. nIdGrupo == GRUPO_DEDUCOES_TRIBUTO .or. nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO
			 		cCodTDECF := "N660"
			 	EndIf
			Case cFormaTrib == TRIBUTACAO_IMUNE .or. cFormaTrib == TRIBUTACAO_ISENTA
				If nIdGrupo == GRUPO_BASE_CALCULO .or. nIdGrupo == GRUPO_DEDUCOES_TRIBUTO .or. nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO
			 		cCodTDECF := "U182"
			 	EndIf
			Case cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL_ATIV_RURAL
				If nIdGrupo == GRUPO_ADICOES_LUCRO .or. nIdGrupo == GRUPO_EXCLUSOES_LUCRO .or. nIdGrupo == GRUPO_COMPENSACAO_PREJUIZO .or. nIdGrupo == GRUPO_ADICOES_DOACAO .or. nIdGrupo == GRUPO_RESULTADO_OPERACIONAL .or. nIdGrupo == GRUPO_RESULTADO_NAO_OPERACIONAL

					cQualifPJ := GetQualiPJ()
					 
					If cQualifPJ == QUALIFICACAO_PJ_EM_GERAL
			 			cCodTDECF := "M350A"
			 		ElseIf cQualifPJ == QUALIFICACAO_PJ_FINANCEIRO
			 			cCodTDECF := "M350B"
			 		ElseIf cQualifPJ == QUALIFICACAO_PJ_SOCIEDADE_SEG_PREVIDENCIA_COMPL
			 			cCodTDECF := "M350C"
			 		EndIf

			 	ElseIf nIdGrupo == GRUPO_ADICIONAIS_TRIBUTO .or. nIdGrupo == GRUPO_DEDUCOES_TRIBUTO .or. nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO
			 		cCodTDECF := "N670"
			 	EndIf
		EndCase
	EndIf
EndIf

Return( cCodTDECF )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetQualiPJ

Retorna o c�digo de Qualifica��o da Pessoa Jur�dica
mais atual dos Par�metros de Abertura da ECF.

@Return	cQualifPJ

@Author	David Costa
@Since		10/05/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function GetQualiPJ()

Local cQualifPJ	as character
Local cAliasQry	as character
Local cSelect		as character
Local cFrom		as character
Local cWhere		as character
Local cOrderBy	as character

cQualifPJ	:=	""
cAliasQry	:=	GetNextAlias()
cSelect	:=	""
cFrom		:=	""
cWhere		:=	""
cOrderBy	:=	""

// cSelect	:= " CHD_CODQUA "
// cFrom		:= RetSqlName( "CHD" ) + " CHD "
// cWhere		:= " CHD_PERFIN = ( SELECT MAX(CHD_PERFIN) FROM " + RetSqlName( "CHD" )
// cWhere		+= " WHERE CHD.D_E_L_E_T_ = '' "
// cWhere		+= " AND CHD_FILIAL = '" + xFilial( "CHD" ) + "' ) "
// cOrderBy	:= " CHD_PERFIN DESC "

cSelect		:= " CHD.CHD_CODQUA "
cFrom		:= RetSqlName( "CHD" ) + " CHD "
cWhere		:= " CHD.CHD_PERFIN = ( SELECT MAX(CHD2.CHD_PERFIN) FROM " + RetSqlName( "CHD" ) + " CHD2 "
cWhere		+= " WHERE CHD2.D_E_L_E_T_ = '' "
cWhere		+= " AND CHD2.CHD_FILIAL = '" + xFilial( "CHD" ) + "' ) "
cWhere      += " AND CHD.D_E_L_E_T_ = '' AND CHD.CHD_FILIAL = '" + xFilial( "CHD" ) + "' "
cOrderBy	:= " CHD.CHD_PERFIN DESC "

cSelect		:= "%" + cSelect 	+ "%"
cFrom  		:= "%" + cFrom   	+ "%"
cWhere 		:= "%" + cWhere  	+ "%"
cOrderBy 	:= "%" + cOrderBy	+ "%"

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

If ( cAliasQry )->( !( Eof() ) )
	cQualifPJ := ( cAliasQry )->CHD_CODQUA
EndIf

Return( cQualifPJ )

//-------------------------------------------------------------------
/*/{Protheus.doc} GatCODPAB
Gatilho do campo T0O_CODPAB para o Campo T0O_DPARTB

@Return cValueCmp

@Author David Costa
@Since 16/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function GatCODPAB( )

Local cValueCmp	as character
Local cFilItem	as character

cValueCmp	:=	&( ReadVar() )
cFilItem	:=	""

If !Empty( cValueCmp )
	
	cFilItem	:= XFUNCh2ID( GetValueCmp( "T0O_FILITE" ) , 'C1E' , 1 )

	DbSelectArea( "T0S" )
	T0S->( DbSetOrder( 2 ) )
	If MsSeek( xFilial( "T0S", cFilItem ) + cValueCmp )
		cValueCmp := Posicione( "T0S", 2, xFilial( "T0S", cFilItem ) + cValueCmp, "T0S->( AllTrim( T0S_DESCRI ) )" )
	EndIf
EndIf

Return( cValueCmp )

//-------------------------------------------------------------------
/*/{Protheus.doc} GatCODPAB2
Gatilho do campo T0O_CODPAB para o campo T0O_IDPARB

@Return cValueCmp

@Author David Costa
@Since 16/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function GatCODPAB2( )

Local cValueCmp	as character
Local cFilItem	as character

cValueCmp	:=	&( ReadVar() )
cFilItem	:=	""

If !Empty( cValueCmp )
	
	cFilItem	:= XFUNCh2ID( GetValueCmp( "T0O_FILITE" ) , 'C1E' , 1 )

	DbSelectArea( "T0S" )
	T0S->( DbSetOrder( 2 ) )
	If MsSeek( xFilial( "T0S", cFilItem ) + cValueCmp )
		cValueCmp := Posicione( "T0S", 2, xFilial( "T0S", cFilItem ) + cValueCmp, "T0S->T0S_ID" )
	EndIf
EndIf

Return( cValueCmp )

//---------------------------------------------------------------------
/*/{Protheus.doc} ConsT0SA

Consulta Espec�fica para Conta da Parte B do Lalur.

@Return	.T.

@Author	David Costa
@Since		17/05/2016
@Version	1.0

@Altered by Felipe C. Seolin in 28/12/2016 - Alterado de MsSelect para FWMarkBrowse
/*/
//---------------------------------------------------------------------
Function ConsT0SA()

Local cAliasQry	as character
Local cTempTab	as character
Local cCampos	as character
Local cChave	as character
Local cTitle	as character
Local cReadVar	as character
Local cCombo	as character
Local cFilItem	as character
Local cSelect	as character
Local cFrom		as character
Local cWhere	as character
Local cOrderBy	as character
Local nPos		as numeric
Local nI		as numeric
Local aStruct	as array
Local aColumns	as array
Local aAux		as array
Local aIndex	as array
Local aSeek		as array
Local aCombo	as array
Local aCodigo	as array
Local aDescri	as array
Local aNature	as array
Local oTmpTab	as object

cAliasQry := GetNextAlias()
cTempTab  := ""
cCampos	  := "T0S_CODIGO|T0S_DESCRI|T0S_NATURE"
cChave	  := "T0S_CODIGO"
cTitle	  := STR0058 //"Conta da Parte B do Lalur"
cReadVar  := ReadVar()
cCombo	  := ""
cFilItem  := xFunCh2ID( GetValueCmp( "T0O_FILITE" ), "C1E", 1 )
cSelect	  := ""
cFrom	  := ""
cWhere	  := ""
cOrderBy  := ""
nPos	  := 0
nI		  := 0
aStruct	  := {}
aColumns  := {}
aAux	  := {}
aIndex	  := {}
aSeek	  := {}
aCombo	  := {}
aCodigo	  := TamSX3( "T0S_CODIGO" )
aDescri	  := TamSX3( "T0S_DESCRI" )
aNature	  := TamSX3( "T0S_NATURE" )
oTmpTab   := Nil

//------------------------------------
// Executa consulta ao banco de dados
//------------------------------------
cSelect	 := "T0S_CODIGO, T0S_DESCRI, T0S_NATURE "
cFrom	 := RetSqlName( "T0S" ) + " T0S "
cWhere	 := "    T0S.T0S_FILIAL = '" + xFilial( "T0S", Iif( Empty( cFilItem ), xFilial( "T0S" ), cFilItem ) ) + "' "
cWhere	 += "AND T0S.D_E_L_E_T_ = '' "
cOrderBy := "T0S.T0S_CODIGO "

cSelect  := "%" + cSelect  + "%"
cFrom  	 := "%" + cFrom    + "%"
cWhere	 := "%" + cWhere   + "%"
cOrderBy := "%" + cOrderBy + "%"

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

//------------------------------------
// Monta array com a estrutura de campos da tabela temporaria
//------------------------------------
aStruct  := { {"MARK"		, "C"		, 2			, 0 		},;
			  {"T0S_CODIGO"	, aCodigo[3], aCodigo[1], aCodigo[2]},;
			  {"T0S_DESCRI"	, aDescri[3], aDescri[1], aDescri[2]},;
			  {"T0S_NATURE"	, aNature[3], aNature[1], aNature[2]} }

cTempTab := getNextAlias()

//------------------------------------
// Instancia o objeto Temporary Table
//------------------------------------
oTmpTab := FWTemporaryTable():New(cTempTab, aStruct)

oTmpTab:AddIndex("1", {"T0S_CODIGO"} )
oTmpTab:AddIndex("2", {"T0S_DESCRI"} )
oTmpTab:AddIndex("3", {"T0S_NATURE"} )
oTmpTab:Create()

DbSelectArea(cTempTab)
(cTempTab)->(DbSetOrder(1))
(cTempTab)->(DBGoTop())

//------------------------------------
// Popula arquivo de dados tempor�rio
//------------------------------------
While ( cAliasQry )->( !Eof() )
	If RecLock( ( cTempTab ), .T. )
		( cTempTab )->MARK		 := "  "
		( cTempTab )->T0S_CODIGO := ( cAliasQry )->T0S_CODIGO
		( cTempTab )->T0S_DESCRI := ( cAliasQry )->T0S_DESCRI
		( cTempTab )->T0S_NATURE := ( cAliasQry )->T0S_NATURE
		( cTempTab )->( MsUnLock() )
	EndIf
	( cAliasQry )->( DBSkip() )
EndDo
( cAliasQry )->( DBCloseArea() )

//---------------------------
// Cria estrutura de colunas
//---------------------------
For nI := 1 to Len( aStruct )
	If aStruct[nI,1] $ cCampos
		nPos ++

		aAdd( aColumns, FWBrwColumn():New() )
		aColumns[nPos]:SetData( &( "{ || " + aStruct[nI,1] + " }" ) )
		aColumns[nPos]:SetTitle( RetTitle( aStruct[nI,1] ) )
		aColumns[nPos]:SetDecimal( aStruct[nI,4] )
		aColumns[nPos]:SetPicture( PesqPict( SubStr( aStruct[nI,1], 1, At( "_", aStruct[nI,1] ) - 1 ), aStruct[nI,1] ) )
		aColumns[nPos]:SetType( aStruct[nI,2] )
		aColumns[nPos]:SetAlign( Iif( aStruct[nI,2] == "N", 2, 1 ) )

		If aStruct[nI,2] == "C"
			DBSelectArea( "SX3" )
			SX3->( DBSetOrder( 2 ) )
			If SX3->( MsSeek( aStruct[nI,1] ) )
				cCombo := X3Cbox()
			EndIf
			If !Empty( cCombo )
				aCombo := StrToKarr( cCombo, ";" )
				aColumns[nPos]:SetOptions( aCombo )
			EndIf
		EndIf
		//----------------------------
		// Cria estrutura de pesquisa
		//----------------------------
		If aStruct[nI,1] <> "T0S_NATURE"
			aAdd( aIndex, aStruct[nI,1] )
			aAdd( aSeek, { RetTitle( aStruct[nI,1] ), { { "", aStruct[nI,2], aStruct[nI,3], aStruct[nI,4], RetTitle( aStruct[nI,1] ), PesqPict( SubStr( aStruct[nI,1], 1, At( "_", aStruct[nI,1] ) - 1 ), aStruct[nI,1] ), } } } )
		EndIf
	EndIf
Next nI

//---------------------------------
// Executa a montagem da interface
//---------------------------------
TAF433SXB( cTitle, cTempTab, cReadVar, cChave, aColumns, aSeek )

//---------------------------------
//Exclui a tabela e fecha o alias
//---------------------------------
oTmpTab:Delete()

Return( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDesNatu
Retorna a descri��o da Natureza da conta parte B

@Param cNat -> C�digo da Natureza

@Return lRet

@Author David Costa
@Since 17/05/2016
@Version 1.0
/*/
//------------------------------------------------------------------------------------------------
Static Function GetDesNatu( cNat )

Local cRet	as character

cRet	:=	""

Do Case
	Case cNat == NATUREZA_ADICAO
		cRet := STR0063 //"Adi��o"
	Case cNat == NATUREZA_EXCLUSAO
		cRet := STR0064 //"Exclus�o"

	Case cNat == NATUREZA_COMPENSACAO_BASE_NEGATIVA
		cRet := STR0065 //"Compensa��o de Preju�zo/Base de C�lculo Negativa"
	
	Case cNat == NATUREZA_DEDUCAO_COMPENSACAO_TRIBUTO
		cRet := STR0066 //"Dedu��o/Compensa��o de Tributo "
   
EndCase

Return( cRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA433Cpy

Fun��o para execu��o da C�pia do Evento Tribut�rio. 

@Author	David Costa
@Since		07/06/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAFA433Cpy()

lCopia := .T.

If Perg433()
	FwExecView( STR0067, "TAFA433", 9,, { || .T. } ) //"C�pia do Evento Tribut�rio"; 9 = C�pia
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} CopiarEven

Fun��o auxilixar para prepara��o do modelo para C�pia.

@Author	David Costa
@Since		07/06/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function CopiarEven( cFTribDest, oModel )

Local oModelT0N	as object
Local cFTribOrig	as character
Local cTribuOrig	as character
Local cTribuDest	as character
Local cIDEvento	as character

oModelT0N	:=	Nil
cFTribOrig	:=	""
cTribuOrig	:=	""
cTribuDest	:=	""
cIDEvento	:=	TAFGeraID( "TAF" )

oModel:SetOperation( MODEL_OPERATION_UPDATE )
oModel:Activate( lCopia )

oModelT0N := oModel:GetModel( "MODEL_T0N" )

//Forma de Tributa��o do Evento de Destino
cFTribDest := cT0N_IDFTRI

//Forma de Tributa��o do Evento de Origem
cFTribOrig := xFunID2Cd( oModelT0N:GetValue( "T0N_IDFTRI" ), "T0K", 1 )

//Tributo do Evento de Destino
cTribuDest := cT0N_IDTRIB

//Tributo do Evento de Origem
cTribuOrig := xFunID2Cd( oModelT0N:GetValue( "T0N_IDTRIB" ), "T0J", 1 )

CopiaIdent( @oModelT0N, cIDEvento )
CopiaItens( @oModel, cIDEvento, cFTribDest, cFTribOrig, cTribuDest, cTribuOrig )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} Perg433

Fun��o para solicitar ao usu�rio a Forma de Tributa��o
e o Tributo do Evento de Destino. 

@Author	David Costa
@Since		07/06/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function Perg433()

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
oFont			:=	TFont():New( "Arial",, -11 )
nLarguraBox	:=	0
nAlturaBox		:=	0
nLarguraSay	:=	0
nTop			:=	0
nAltura		:=	250
nLargura		:=	520
nPosIni		:=	0
lRet			:=	.F.

oDlg := MsDialog():New( 0, 0, nAltura, nLargura, STR0070,,,,,,,,, .T. ) //"Par�metros"

nAlturaBox := ( nAltura - 60 ) / 2
nLarguraBox := ( nLargura - 20 ) / 2

@10,10 to nAlturaBox,nLarguraBox of oDlg Pixel

//Como default ser� carregado os valores do evento de origem
cT0N_IDFTRI := xFunID2Cd( T0N->T0N_IDFTRI, "T0K", 1 )
cT0N_DFTRIB := Posicione( "T0K", 1, xFilial( "T0K" ) + T0N->T0N_IDFTRI, "T0K_DESCRI" )
cT0N_IDTRIB := xFunID2Cd( T0N->T0N_IDTRIB, "T0J", 1 )
cT0N_DTRIBU := Posicione( "T0J", 1, xFilial( "T0J" ) + T0N->T0N_IDTRIB, "T0J_DESCRI" )

nLarguraSay := nLarguraBox - 30
nTop := 20
TGet():New( nTop, 20, { |x| If( PCount() == 0, cT0N_IDFTRI, cT0N_IDFTRI := x ) }, oDlg, 65, 10, "@!", { || ValidPerg( 1 ) },,,,,, .T.,,,,,,,,, "T0KA",,,,,,,, STR0002, 1, oFont ) //"Forma de Tributa��o"
TGet():New( nTop + 8, 90, { |x| If( PCount() == 0, cT0N_DFTRIB, cT0N_DFTRIB := x ) }, oDlg, 152, 10, "@!",,,,,,, .T.,,, { || .F. } )
nTop += 30
TGet():New( nTop, 20, { |x| If( PCount() == 0, cT0N_IDTRIB, cT0N_IDTRIB := x ) }, oDlg, 65, 10, "@!", { || ValidPerg( 2 ) },,,,,, .T.,,,,,,,,, "T0JA", "M->T0N_COTRIB",,,,,,, STR0069, 1, oFont ) //"Tributo"
TGet():New( nTop + 8, 90, { |x| If( PCount() == 0, cT0N_DTRIBU, cT0N_DTRIBU := x ) }, oDlg, 152, 10, "@!",,,,,,, .T.,,, { || .F. } )
nTop += 10

nPosIni := ( ( nLargura - 20 ) / 2 ) - ( 2 * 32 )
   
SButton():New( nAlturaBox + 10, nPosIni, 1, { |x| Iif( lRet := ValidPergOk(), x:oWnd:End(), ) }, oDlg )
SButton():New( nAlturaBox + 10, nPosIni + 32, 2, { |x| x:oWnd:End() }, oDlg )

oDlg:Activate( ,,,.T. )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidPergOk

Valida��o do bot�o para confirmar a entrada de todos os dados dos
par�metros da funcionalidade de C�pia do Evento Tribut�rio.

@Return	lRet - Indica se todas as condi��es foram respeitadas

@Author	Felipe C. Seolin
@Since		09/12/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ValidPergOk()

Local lRet	as logical

lRet	:=	.T.

If !(	ValidPerg( 1 ) .and.;
		ValidPerg( 2 ) )
	lRet := .F.
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidPerg

Valida se os par�metros preenchidos pelo 
usu�rio durante a C�pia s�o v�lidos.

@Return	lRet - Indica se as condi��es foram respeitadas

@Author	David Costa
@Since		07/06/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ValidPerg( nOpc )

Local lRet	as logical

lRet	:=	.T.

If nOpc == 1

	If !Empty( cT0N_IDFTRI )
		If T0K->( DBSetOrder( 2 ), T0K->( MsSeek( xFilial( "T0K" ) + cT0N_IDFTRI ) ) )
			cT0N_IDFTRI := T0K->T0K_CODIGO
			cT0N_DFTRIB := AllTrim( T0K->T0K_DESCRI )
		Else
			MsgInfo( STR0084 ) //"Forma de Tributa��o inv�lida"
			lRet := .F.
		EndIf
	Else
		MsgInfo( STR0085 ) //"Forma de Tributa��o n�o informada"
		lRet := .F.
	EndIf

ElseIf nOpc == 2

	If !Empty( cT0N_IDTRIB )
		If T0J->( DBSetOrder( 2 ), T0J->( MsSeek( xFilial( "T0J" ) + cT0N_IDTRIB ) ) )
			If !Empty( T0J->T0J_TPTRIB ) .and. ( T0J->T0J_TPTRIB == TRIBUTO_IRPJ .or. T0J->T0J_TPTRIB == TRIBUTO_CSLL )
				cT0N_IDTRIB := T0J->T0J_CODIGO
				cT0N_DTRIBU := AllTrim( T0J->T0J_DESCRI )
			Else
				MsgInfo( STR0086 ) //"Tributo inv�lido"
				lRet := .F.
			EndIf
		Else
			MsgInfo( STR0086 ) //"Tributo inv�lido"
			lRet := .F.
		EndIf
	Else
		MsgInfo( STR0087 ) //"Tributo n�o informado"
		lRet := .F.
	EndIf

EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} CopiaIdent

Ajusta os campos da Identifica��o que n�o ser�o copiados

@Return Nil 

@Author David Costa
@Since 07/06/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function CopiaIdent( oModelT0N, cIDEvento )

oModelT0N:SetValue( "T0N_ID", cIDEvento )
oModelT0N:SetValue( "T0N_CODIGO", "" )
oModelT0N:SetValue( "T0N_DESCRI", "" )
oModelT0N:SetValue( "T0N_IDFTRI", xFunCh2ID( cT0N_IDFTRI, "T0K", 2 ) )
oModelT0N:SetValue( "T0N_CODFTR", cT0N_IDFTRI )
oModelT0N:SetValue( "T0N_DFTRIB", Posicione( "T0K", 2, xFilial( "T0K" ) + cT0N_IDFTRI, "AllTrim( T0K_DESCRI )" ) )
oModelT0N:SetValue( "T0N_IDEVEN", "" )
oModelT0N:SetValue( "T0N_CODEVE", "" )
oModelT0N:SetValue( "T0N_DEVENT", "" )
oModelT0N:SetValue( "T0N_IDTRIB", xFunCh2ID( cT0N_IDTRIB, "T0J", 2 ) )
oModelT0N:SetValue( "T0N_COTRIB", cT0N_IDTRIB )
oModelT0N:SetValue( "T0N_DTRIBU", Posicione( "T0J", 2, xFilial( "T0J" ) + cT0N_IDFTRI, "AllTrim( T0J_DESCRI )" ) )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} CopiaItens

Ajusta os campos dos itens tribut�rios removendo os que n�o poder�o ser copiados

@Return Nil 

@Author David Costa
@Since 07/06/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function CopiaItens( oModel, cIDEvento, cFTribDest, cFTribOrig, cTribuDest, cTribuOrig )

Local oModelT0O	as object
Local oModelT0P	as object
Local oModelT0R	as object
Local nIndiceT0O	as numeric
Local nIndiceT0P	as numeric
Local nIndiceT0R	as numeric
Local nIndiceGrup	as numeric
Local aGrupos		as array

oModelT0O		:=	Nil
oModelT0P		:=	Nil
oModelT0R		:=	Nil
nIndiceT0O		:= 0
nIndiceT0P		:= 0
nIndiceT0R		:= 0
nIndiceGrup	:= 0
aGrupos		:= GetGrupos( , .T. )

For nIndiceGrup := 1 To Len( aGrupos )
	
	//Grupo Tribut�rio
	oModelT0O := oModel:GetModel( "MODEL_T0O_" + aGrupos[ nIndiceGrup ][ PARAM_GRUPO_NOME ]  )
	For nIndiceT0O := 1 To oModelT0O:Length()
		
		oModelT0O:GoLine( nIndiceT0O )
		
		If PodeCopiar( aGrupos[ nIndiceGrup ][ PARAM_GRUPO_ID ], cFTribDest, cFTribOrig )

			If !Empty( oModelT0O:GetValue( "T0O_ID" ) )
			
				oModelT0O:SetValue( "T0O_ID", cIDEvento )
				CpyOrigem( @oModelT0O, cFTribDest )
				CpyCodECF( @oModelT0O, cFTribDest, cFTribOrig, cTribuDest, cTribuOrig )
				CpyContaB( @oModelT0O, cTribuDest, cTribuOrig )
				
			EndIf
		Else
			oModelT0O:DeleteLine()
		EndIf
	Next nIndiceT0O
	
	//Processos
	oModelT0P := oModel:GetModel( 'MODEL_T0P_' + aGrupos[ nIndiceGrup ][ PARAM_GRUPO_NOME ] )				
	For nIndiceT0P := 1 To oModelT0P:Length()
		oModelT0P:GoLine( nIndiceT0P )
		If !Empty( oModelT0P:GetValue( "T0P_ID" ) )
			oModelT0P:SetValue( "T0P_ID", cIDEvento )
		EndIf
	Next nIndiceT0P
	
	//Hist�rico Padr�o
	oModelT0R := oModel:GetModel( 'MODEL_T0R_' + aGrupos[ nIndiceGrup ][ PARAM_GRUPO_NOME ] )
	For nIndiceT0R := 1 To oModelT0R:Length()
		oModelT0R:GoLine( nIndiceT0R )
		If !Empty( oModelT0R:GetValue( "T0R_ID" ) )
			oModelT0R:SetValue( "T0R_ID", cIDEvento )
		EndIf
	Next nIndiceT0R
	
Next nIndiceGrup

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} PodeCopiar

Verifica se o Item tribut�rio pode ser levado para o Evento de destino

@Param nIdGrupo -> Id do Grupo do Evento de Destino
		 cFTribDest -> Forma de tributa��o do Evento de destino
		 cFTribOrig -> Forma de tributa��o do Evento de Origem

@Author David Costa
@Since 07/06/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function PodeCopiar( nIdGrupo, cFTribDest, cFTribOrig )

Local aGrupoDest	as array
Local lRet			as logical

aGrupoDest	:=	GetGrupos( cFTribDest )
lRet		:=	.F.

lRet := cFTribDest == cFTribOrig
lRet := lRet .or. ( aScan( aGrupoDest, { |x| x[ PARAM_GRUPO_ID ] == nIdGrupo } ) <> 0 )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetGrupos

Retorna um array com os parametros do grupo do evento tribut�rio
Exemplo:
	aGrupo[x][1] Id do Grupo
	aGrupo[x][2] Nome do Grupo
	aGrupo[x][3] Descri��o do Grupo
	aGrupo[x][4] Tipo do Grupo que pode ser:
					1 - Grupo da Base de Calculo
					2 - Grupo do Calculo do Tributo 

@Param nIdGrupo -> Id do Grupo do Evento de Destino
		 cFTribDest -> Forma de tributa��o do Evento de destino
		 cFTribOrig -> Forma de tributa��o do Evento de Origem

@Author David Costa
@Since 07/06/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetGrupos( cFormaTrib, lTodos )

Local aGruposEve	as array

Default cFormaTrib	:=	""
Default lTodos		:=	.F.

aGruposEve	:=	{}

If cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or. cFormaTrib == TRIBUTACAO_LUCRO_PRESUMIDO .or. cFormaTrib == TRIBUTACAO_LUCRO_ARBITRADO .or. lTodos
	Aadd( aGruposEve, { GRUPO_RECEITA_BRUTA_ALIQ1, 'RECEITA_BRUTA_ALIQ1', STR0007, TIPO_GRUPO_BASE_CALCULO } )		//"Receita Bruta - Aliquota 1"
	Aadd( aGruposEve, { GRUPO_RECEITA_BRUTA_ALIQ2, 'RECEITA_BRUTA_ALIQ2', STR0008, TIPO_GRUPO_BASE_CALCULO } )		//"Receita Bruta - Aliquota 2"
	Aadd( aGruposEve, { GRUPO_RECEITA_BRUTA_ALIQ3, 'RECEITA_BRUTA_ALIQ3', STR0009, TIPO_GRUPO_BASE_CALCULO } )		//"Receita Bruta - Aliquota 3"
	Aadd( aGruposEve, { GRUPO_RECEITA_BRUTA_ALIQ4, 'RECEITA_BRUTA_ALIQ4', STR0010, TIPO_GRUPO_BASE_CALCULO } )		//"Receita Bruta - Aliquota 4"
	Aadd( aGruposEve, { GRUPO_DEMAIS_RECEITAS, 'DEMAIS_RECEITAS', STR0011, TIPO_GRUPO_BASE_CALCULO } )				//"Demais Receitas"
	Aadd( aGruposEve, { GRUPO_EXCLUSOES_RECEITA, 'EXCLUSOES_RECEITA', STR0015, TIPO_GRUPO_BASE_CALCULO } )			//"Exclus�es da Receita"
EndIf

If cFormaTrib == TRIBUTACAO_IMUNE .or. cFormaTrib == TRIBUTACAO_ISENTA .or. lTodos
	Aadd( aGruposEve, { GRUPO_BASE_CALCULO, 'BASE_CALCULO_IMUNE_ISENTA', STR0006, TIPO_GRUPO_BASE_CALCULO } )			//"Base de C�lculo"
EndIf

If cFormaTrib == TRIBUTACAO_LUCRO_REAL .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL_ATIV_RURAL .or. lTodos
	aAdd( aGruposEve, { GRUPO_RESULTADO_OPERACIONAL, "RESULTADO_OPERACIONAL", STR0143, TIPO_GRUPO_BASE_CALCULO } )				//"Resultado Operacional"
	aAdd( aGruposEve, { GRUPO_RESULTADO_NAO_OPERACIONAL, "RESULTADO_NAO_OPERACIONAL", STR0142, TIPO_GRUPO_BASE_CALCULO } )		//"Resultado N�o Operacional"
	aAdd( aGruposEve, { GRUPO_ADICOES_LUCRO, "ADICOES_LUCRO", STR0012, TIPO_GRUPO_BASE_CALCULO } )									//"Adi��es do Lucro"
	aAdd( aGruposEve, { GRUPO_ADICOES_DOACAO, "ADICOES_DOACAO", STR0013, TIPO_GRUPO_BASE_CALCULO } )								//"Adi��es Doa��o"
	aAdd( aGruposEve, { GRUPO_EXCLUSOES_LUCRO, "EXCLUSOES_LUCRO", STR0014, TIPO_GRUPO_BASE_CALCULO } )							//"Exclus�es do Lucro"
	aAdd( aGruposEve, { GRUPO_COMPENSACAO_PREJUIZO, "COMPENSACAO_PREJUIZO", STR0016, TIPO_GRUPO_BASE_CALCULO } )					//"Compensa��o de Preju�zo"
EndIf

If cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or. cFormaTrib == TRIBUTACAO_LUCRO_PRESUMIDO .or. cFormaTrib == TRIBUTACAO_LUCRO_ARBITRADO .or. lTodos
	aAdd( aGruposEve, { GRUPO_ADICIONAIS_TRIBUTO, "ADICIONAIS_TRIBUTO", STR0017, TIPO_GRUPO_CALCULO_TRIBUTO } ) //"Adicionais do Tributo"
EndIf

If cFormaTrib == TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO .or. lTodos
	Aadd( aGruposEve, { GRUPO_RECEITA_LIQUIDA_ATIVIDA, 'RECEITA_LIQ_ATIVIDADE', STR0018, TIPO_GRUPO_BASE_CALCULO } )	//"Receita L�quida por Atividade"
	Aadd( aGruposEve, { GRUPO_LUCRO_EXPLORACAO, 'LUCRO_EXPLORACAO', STR0019, TIPO_GRUPO_BASE_CALCULO } )					//"Lucro da Explora��o"
EndIf

If cFormaTrib <> TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO .and. cFormaTrib <> TRIBUTACAO_LUCRO_REAL_ATIV_RURAL .or. lTodos
	Aadd( aGruposEve, { GRUPO_DEDUCOES_TRIBUTO, 'DEDUCOES_TRIBUTO', STR0023, TIPO_GRUPO_CALCULO_TRIBUTO } )					//"Dedu��es do Tributo"
	Aadd( aGruposEve, { GRUPO_COMPENSACAO_TRIBUTO, 'COMPENSACAO_TRIBUTO', STR0024, TIPO_GRUPO_CALCULO_TRIBUTO } )			//"Compensa��o do Tributo"
EndIf

Return( aGruposEve )

//-------------------------------------------------------------------
/*/{Protheus.doc} CpyOrigem

Aplica as regras de C�pia do campo Origem

@Param oModelT0O -> Model de Itens para validar a c�pia
		 cFTribDest -> Forma de tributa��o do Evento de destino

@Author David Costa
@Since 07/06/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function CpyOrigem( oModelT0O, cFTribDest )

If oModelT0O:GetValue( "T0O_ORIGEM" ) == ORIGEM_EVENTO_TRIBUTARIO
	If cFTribDest <> TRIBUTACAO_LUCRO_REAL .and. cFTribDest <> TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .and.;
	  cFTribDest <>  TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA
		oModelT0O:SetValue( "T0O_IDEVEN", "" )
		oModelT0O:SetValue( "T0O_CODEVE", "" )
		oModelT0O:SetValue( "T0O_DEVENT", "" )
		oModelT0O:SetValue( "T0O_ORIGEM", "" )
	EndIf
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} CpyCodECF

Aplica as regras de C�pia do campo C�digo da Tabela Din�mica.

@Param	oModelT0O	- Modelo de Itens para validar a C�pia
		cFTribDest	- Forma de Tributa��o do Evento de destino
		cFTribOrig	- Forma de Tributa��o do Evento de origem
		cTribuDest	- Tributo do Evento de destino
		cTribuOrig	- Tributo do Evento de origem

@Author	David Costa
@Since		07/06/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function CpyCodECF( oModelT0O, cFTribDest, cFTribOrig, cTribuDest, cTribuOrig )

Local lCopiar	as logical

lCopiar	:=	.F.

lCopiar :=	( cFTribDest == TRIBUTACAO_IMUNE .or. cFTribDest == TRIBUTACAO_ISENTA) .and.; 
			( cFTribOrig == TRIBUTACAO_IMUNE .or. cFTribOrig == TRIBUTACAO_ISENTA) .and.;
			cTribuDest == cTribuOrig
lCopiar := lCopiar .or. ( cFTribDest == cFTribOrig .and. cTribuDest == cTribuOrig )
lCopiar := lCopiar .or. ( cFTribDest == TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO .and. cFTribOrig == TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO )

//Se n�o for para copiar, limpa os campos
If !lCopiar
	oModelT0O:SetValue( "T0O_IDTDEX", "" )
	oModelT0O:SetValue( "T0O_CODTDE", "" )
	oModelT0O:SetValue( "T0O_DTDEXP", "" )
	oModelT0O:SetValue( "T0O_IDECF", "" )
	oModelT0O:SetValue( "T0O_CODECF", "" )
	oModelT0O:SetValue( "T0O_DTDECF", "" )
	oModelT0O:SetValue( "T0O_IDLAL", "" )
	oModelT0O:SetValue( "T0O_CODLAL", "" )
	oModelT0O:SetValue( "T0O_DTDLAL", "" )
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} CpyContaB

Aplica as regras de C�pia do campo C�digo da Conta Parte B do Lalur

@Param oModelT0O -> Model de Itens para validar a c�pia
		 cTribuDest -> Tributo do Evento de destino
		 cTribuOrig -> Tributo do Evento de origem

@Author David Costa
@Since 15/06/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function CpyContaB( oModelT0O, cTribuDest, cTribuOrig )

Local cFilItem 	:= ""
Local cIdContPaB	:= ""
Local cIdTributo	:= ""

If cTribuDest <> cTribuOrig
	DbSelectArea( "LE9" )
	LE9->( DBSetOrder( 1 ) )
	cFilItem := xFunCh2ID( oModelT0O:GetValue( "T0O_FILITE"), "C1E", 1 )
	cIdContPaB := oModelT0O:GetValue( "T0O_IDPARB" )
	cIdTributo := XFUNCh2ID( cTribuDest, "T0J", 2 )
	
	//Se o tributo do evento de destino n�o existir na conta da Parte B ela n�o ser� copiada
	If !LE9->( MsSeek( xFilial( "LE9", cFilItem ) + cIdContPaB + cIdTributo ) )
		oModelT0O:SetValue( "T0O_IDPARB", "" )
		oModelT0O:SetValue( "T0O_CODPAB", "" )
		oModelT0O:SetValue( "T0O_DPARTB", "" )
	EndIf
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} GetGrupo

Rotina para indicar os grupos de acordo com a forma de tributa��o.

@Param		cFormaTrib	- Forma de tributa��o desejada

@Return	cGrupo		- Grupos relacionados a forma de tributa��o

@Author	Felipe de Carvalho Seolin
@Since		07/07/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function GetGrupo( cFormaTrib )

Local cGrupo	as character

cGrupo	:=	""

If cFormaTrib == TRIBUTACAO_LUCRO_REAL .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO

	cGrupo += "|" + StrZero( GRUPO_RESULTADO_OPERACIONAL, 2 )
	cGrupo += "|" + StrZero( GRUPO_RESULTADO_NAO_OPERACIONAL, 2 )
	cGrupo += "|" + StrZero( GRUPO_ADICOES_LUCRO, 2 )
	cGrupo += "|" + StrZero( GRUPO_ADICOES_DOACAO, 2 )
	cGrupo += "|" + StrZero( GRUPO_EXCLUSOES_LUCRO, 2 )
	cGrupo += "|" + StrZero( GRUPO_DEDUCOES_TRIBUTO, 2 )
	cGrupo += "|" + StrZero( GRUPO_COMPENSACAO_TRIBUTO, 2 )
	cGrupo += "|" + StrZero( GRUPO_ADICIONAIS_TRIBUTO, 2 )

ElseIf cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or. cFormaTrib == TRIBUTACAO_LUCRO_PRESUMIDO .or. cFormaTrib == TRIBUTACAO_LUCRO_ARBITRADO

	cGrupo += "|" + StrZero( GRUPO_RECEITA_BRUTA_ALIQ1, 2 )
	cGrupo += "|" + StrZero( GRUPO_RECEITA_BRUTA_ALIQ2, 2 )
	cGrupo += "|" + StrZero( GRUPO_RECEITA_BRUTA_ALIQ3, 2 )
	cGrupo += "|" + StrZero( GRUPO_RECEITA_BRUTA_ALIQ4, 2 )
	cGrupo += "|" + StrZero( GRUPO_DEMAIS_RECEITAS, 2 )
	cGrupo += "|" + StrZero( GRUPO_EXCLUSOES_RECEITA, 2 )
	cGrupo += "|" + StrZero( GRUPO_DEDUCOES_TRIBUTO, 2 )
	cGrupo += "|" + StrZero( GRUPO_COMPENSACAO_TRIBUTO, 2 )
	cGrupo += "|" + StrZero( GRUPO_ADICIONAIS_TRIBUTO, 2 )

ElseIf cFormaTrib == TRIBUTACAO_IMUNE .or. cFormaTrib == TRIBUTACAO_ISENTA

	cGrupo += "|" + StrZero( GRUPO_BASE_CALCULO, 2 )
	cGrupo += "|" + StrZero( GRUPO_DEDUCOES_TRIBUTO, 2 )
	cGrupo += "|" + StrZero( GRUPO_COMPENSACAO_TRIBUTO, 2 )

ElseIf cFormaTrib == TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO

	cGrupo += "|" + StrZero( GRUPO_RECEITA_LIQUIDA_ATIVIDA, 2 )
	cGrupo += "|" + StrZero( GRUPO_LUCRO_EXPLORACAO, 2 )

ElseIf cFormaTrib == TRIBUTACAO_LUCRO_REAL_ATIV_RURAL

	cGrupo += "|" + StrZero( GRUPO_RESULTADO_OPERACIONAL, 2 )
	cGrupo += "|" + StrZero( GRUPO_RESULTADO_NAO_OPERACIONAL, 2 )
	cGrupo += "|" + StrZero( GRUPO_ADICOES_LUCRO, 2 )
	cGrupo += "|" + StrZero( GRUPO_ADICOES_DOACAO, 2 )
	cGrupo += "|" + StrZero( GRUPO_EXCLUSOES_LUCRO, 2 )

EndIf

Return( cGrupo )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF433When

Funcionalidade para atribui��o da propriedade de edi��o do campo.

@Return	lWhen - Indica o modo de edi��o do campo

@Author	Felipe C. Seolin
@Since		07/07/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAF433When()

Local oModel		as object
Local oModelLEC	as object
Local cCampo		as character
Local lWhen		as logical

oModel		:=	FWModelActive()
oModelLEC	:=	oModel:GetModel( "MODEL_LEC" )
cCampo		:=	SubStr( ReadVar(), At( ">", ReadVar() ) + 1 )
lWhen		:=	.T.

If cCampo $ "LEC_ATIVID|LEC_PROUNI|LEC_PERRED|LEC_CODTDE"
	If Val( oModelLEC:GetValue( "LEC_CODGRU" ) ) <> GRUPO_RECEITA_LIQUIDA_ATIVIDA
		lWhen := .F.
	ElseIf cCampo $ "LEC_PROUNI" .and. oModelLEC:GetValue( "LEC_ATIVID" ) <> ATIVIDADE_ISENCAO
		lWhen := .F.
	ElseIf cCampo $ "LEC_PERRED" .and. oModelLEC:GetValue( "LEC_ATIVID" ) <> ATIVIDADE_REDUCAO
		lWhen := .F.
	EndIf
EndIf

Return( lWhen )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF433SXB

Fun��o para execu��o das Consultas Especificas do Evento Tribut�rio.

@Param		cTitle		- T�tulo da Tela de Consulta Espec�fica
			cAlias		- Alias da Tabela Tempor�ria criada
			cReadVar	- Campo em mem�ria que receber� o retorno da Consulta Espec�fica
			cChave		- Campo(s) a serem gravados no campo em mem�ria
			aColuns	- Colunas que ser�o utilizadas na Consulta Espec�fica
			aSeek		- �ndice de pesquisas ser�o utilizadas na Consulta Espec�fica
			lMult		- Indica se a tela permitir� sele��o de m�ltiplos registros

@Author	Felipe C. Seolin
@Since		12/08/2015
@Version	1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF433SXB( cTitle, cAlias, cReadVar, cChave, aColumns, aSeek, lMult )

Local oDlg			as object
Local oMrkBrowse	as object
Local nTop			as numeric
Local nLeft		as numeric
Local aSize		as array
Local bConfirm	as codeblock
Local bClose		as codeblock

Default aSeek		:=	{}
Default lMult		:=	.F.

oDlg		:=	Nil
oMrkBrowse	:=	Nil
nTop		:=	0
nLeft		:=	0
aSize		:=	FWGetDialogSize( oMainWnd )
bConfirm	:=	{ || FConfirm( oMrkBrowse, cReadVar, cChave, lMult ), oDlg:End() }
bClose		:=	{ || oDlg:End() }

nTop	:=	( aSize[1] + aSize[3] ) / 5
nLeft	:=	( aSize[2] + aSize[4] ) / 5

If ( cAlias )->( !Eof() )

	oDlg := MsDialog():New( nTop, nLeft, aSize[3], aSize[4], cTitle,,,,,,,,, .T.,,,, .F. )

	oMrkBrowse := FWMarkBrowse():New()

	oMrkBrowse:SetOwner( oDlg )

	//Tipo de dados
	oMrkBrowse:SetTemporary()
	oMrkBrowse:SetAlias( cAlias )

	//Configura��o de colunas
	oMrkBrowse:SetFieldMark( "MARK" )
	oMrkBrowse:SetColumns( aColumns )
	oMrkBrowse:SetCustomMarkRec( { || FMark( oMrkBrowse, lMult ) } )
	oMrkBrowse:SetAllMark( { || } )

	//Configura��o de op��es
	oMrkBrowse:SetMenuDef( "" )
	oMrkBrowse:DisableReport()
	oMrkBrowse:DisableConfig()
	oMrkBrowse:SetWalkThru( .F. )
	oMrkBrowse:SetAmbiente( .F. )

	If !Empty( aSeek )
		oMrkBrowse:SetSeek( .T., aSeek )
	Else
		oMrkBrowse:SetSeek()
	EndIf

	oMrkBrowse:AddButton( "Sair", bClose ) //"Sair"
	oMrkBrowse:AddButton( "Confirmar", bConfirm ) //"Confirmar"

	oMrkBrowse:Activate()

	oDlg:Activate()

Else
	Help( " ", 1, "RECNO" )
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FMark

Inverte a indica��o de sele��o do registro da Browse.

@Param		oBrowse	- Objeto da Browse
			lMult		- Indica se a tela permitir� sele��o de m�ltiplos registros

@Author	Felipe C. Seolin
@Since		29/12/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FMark( oBrowse, lMult )

Local cAlias	as character
Local cMark		as character
Local nRecno	as numeric

cAlias	:=	oBrowse:Alias()
cMark	:=	oBrowse:Mark()
nRecno	:=	( cAlias )->( Recno() )

If lMult
	If RecLock( cAlias, .F. )
		( cAlias )->MARK := Iif( ( cAlias )->MARK == cMark, "  ", cMark )
		( cAlias )->( MsUnlock() )
	EndIf
Else
	( cAlias )->( DBGoTop() )

	While ( cAlias )->( !Eof() )

		If RecLock( cAlias, .F. )
			( cAlias )->MARK := "  "
			( cAlias )->( MsUnlock() )
		EndIf

		( cAlias )->( DBSkip() )
	EndDo

	( cAlias )->( DBGoTo( nRecno ) )

	If RecLock( cAlias, .F. )
		( cAlias )->MARK := cMark
		( cAlias )->( MsUnlock() )
	EndIf
EndIf

oBrowse:Refresh()

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FConfirm

Executa a grava��o do retorno da Consulta Espec�fica.

@Param		oBrowse	- Objeto da Browse
			cReadVar	- Campo de retorno da Consulta Espec�fica
			cChave		- Campo(s) a serem gravados no retorno da Consulta Espec�fica
			lMult		- Indica se a tela permitir� sele��o de m�ltiplos registros

@Author	Felipe C. Seolin
@Since		29/12/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FConfirm( oBrowse, cReadVar, cChave, lMult )

Local cAlias	as character
Local cMark	as character
Local nRecno	as numeric

cAlias	:=	oBrowse:Alias()
cMark	:=	oBrowse:Mark()
nRecno	:=	( cAlias )->( Recno() )

If Type( "cListKey" ) <> "U"
	cListKey := ""
EndIf

( cAlias )->( DBGoTop() )

While ( cAlias )->( !Eof() )

	If oBrowse:IsMark( cMark )
		If lMult
			cListKey += ( cAlias )->&( cChave ) + "|"
		Else
			SetMemVar( cReadVar, ( cAlias )->&( cChave ) )
			SysRefresh( .T. )
			Exit
		EndIf
	EndIf

	( cAlias )->( DBSkip() )
EndDo

( cAlias )->( DBGoTo( nRecno ) )

oBrowse:Refresh()

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} GrupoEvnto

Retorna um array com todos os grupos pertinentes a Forma de Tributa��o passada.

@Param		cFormaTrib	- Forma de Tributa��o do Evento Tribut�rio
			lTodos		- Indica que todos os Grupos ser�o retornados

@Return	aGruposEve	- Todos os grupos do Evento Tribut�rio e seus par�metros

@Author	David Costa
@Since		17/10/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function GrupoEvnto( cFormaTrib, lTodos )

Local aGruposEve	as array

aGruposEve	:=	GetGrupos( cFormaTrib, lTodos )

Return( aGruposEve )

//---------------------------------------------------------------------
/*/{Protheus.doc} CanUpdate

Verifica se o cadastro pode sofrer altera��es.

@Return	lCan	- Retorna se o cadastro pode ser alterado

@Author	David Costa
@Since		06/12/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function CanUpdate()

Local lCan	as logical

lCan	:=	.T.

//Dicion�rio do cadastro do Per�odo
If TAFAlsInDic( "CWV" ) .and. ( ( Type( "INCLUI" ) <> "U" .and. !INCLUI ) .and. ( Type( "lCopia" ) <> "U" .and. !lCopia ) )
	DBSelectArea( "CWV" )
	CWV->( DBSetOrder( 6 ) )

	//Se o Evento estiver em uso por algum Per�odo de Apura��o, o cadastro n�o pode ser alterado
	If CWV->( MsSeek( xFilial( "CWV" ) + T0N->T0N_ID ) )
		If CWV->( !Eof() )
			lCan := .F.
		EndIf
	EndIf
EndIf

Return( lCan )

/*/{Protheus.doc} TAFA433SIM
Processo de Simula��o da Apura��o
@author david.costa
@since 27/01/2017
@version 1.0
@return ${Nil}, ${Nulo}
@example
TAFA433SIM()
/*/Function TAFA433SIM(lAutomato, aResult)

Local cLogAvisos	as character
Local cLogErros		as character
Local lEnd			as logical
Local aItemsEvt 	as array

Default lAutomato := .F.
Default aResult := {}

cLogAvisos	:=	""
cLogErros	:=	""
lEnd		:=	.F.
aItemsEvt   :=  {}

If !lAutomato
	TelaParSim( @cLogAvisos, @cLogErros, @aItemsEvt )
Else
	Simular( , @cLogAvisos, @cLogErros,lAutomato, @aResult, @aItemsEvt)	
EndIf	

//Limpando a mem�ria
DelClassIntf()

Return( Nil )

/*/{Protheus.doc} ProcSimula
Processa a simula��o
@author david.costa
@since 27/01/2017
@version 1.0
@param aListParam, array, (Descri��o do par�metro)
@return ${Nil}, ${Nulo}
@example
ProcSimula( @aListParam, @cLogAvisos, @cLogErros )
/*/Static Function ProcSimula(oSay, aListParam, lAutomato, aItemsEvt)

Local cAvisosPer	as character
Local cErrosPeri	as character
Local nIndicePar	as numeric
Local nIndicePer	as numeric

Default aItemsEvt := {}
Default lAutomato := .F.

cAvisosPer	:=	""
cErrosPeri	:=	""
nIndicePar	:=	0
nIndicePer	:=	0

//Calcula os valores da simula��o
For nIndicePar := 1 To Len( aListParam )
	For nIndicePer := 1 To Len( aListParam[ nIndicePar ][ PARAM_SIMUL_LISTA_PAR ] )

		If !lAutomato
			oSay:cCaption := STR0103 + ' ' + dtoc(aListParam[ nIndicePar, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_ARRAY_PARAMETRO, INICIO_PERIODO ]) + ' a ' + dtoc(aListParam[ nIndicePar, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_ARRAY_PARAMETRO, FIM_PERIODO ]) //"Periodo"
			ProcessMessages()
		EndIf
		cAvisosPer := ""
		cErrosPeri := ""

		ApuraEvent( aListParam[ nIndicePar, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_MODEL_PERIODO ],;
					aListParam[ nIndicePar, PARAM_SIMUL_MODEL_EVENTO ],;
					@cErrosPeri,;
					@cAvisosPer,;
					aListParam[ nIndicePar, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_ARRAY_PARAMETRO ],;
					.T.,;
					aListParam[ nIndicePar, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_ARRAY_PAR_RURAL ],;
					/*8*/,;
					@aItemsEvt )

		aListParam[ nIndicePar, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_LOG_PERIODO ] := cAvisosPer + CRLF + cErrosPeri
		
	Next nIndicePer
Next nIndicePar

Return( Nil )

/*/{Protheus.doc} SetListPar
Preenche a lista de parametros da simula��o
@author david.costa
@since 27/01/2017
@version 1.0
@param oModelEven, objeto, Passar por refer�ncia o Objeto FWFormModel() do cadastro do Evento Tribut�rio
@param aListParam, array, Paramentros da Simula��o
@return ${Nil}, ${Nulo}
@example
SetListPar( @oModelEven, @aListParam )
/*/Static Function SetListPar( oModelEven, aListParam )
//Carrega o evento principal
If LoadEvento( @oModelEven, XFUNCh2ID( uCampo1, "T0N", 2 ) )
	//Pametros para a simula��o do primeiro evento
	aAdd( aListParam, { oModelEven, ListPerPar( oModelEven ) } )
	
	//Carrega o evento de compara��o
	If LoadEvento( @oModelEven, XFUNCh2ID( uCampo4, "T0N", 2 ) ) .and. uCampo3
		//Pametros para a simula��o do segundo evento
		aAdd( aListParam, { oModelEven, ListPerPar( oModelEven ) } )
	EndIf
EndIf

Return( Nil )

/*/{Protheus.doc} Simular
Simula��o da Apura��o
@author david.costa
@since 27/01/2017
@version 1.0
@param cLogAvisos, character, Log de Avisos do processo
@param cLogErros, character, Log de Erros do processo
@return ${Nil}, ${Nulo}
@example
Simular( @cLogAvisos, @cLogErros )
/*/Static Function Simular( oSay, cLogAvisos, cLogErros, lAutomato, aResult, aItemsEvt )

Local oModelEven	as object
Local aListParam	as array

Default lAutomato := .F.
Default aResult   := {}
Default aItemsEvt := {}

oModelEven	:=	Nil
aListParam	:=	{}

If !Empty( StrTran( cListKey, "|", "" ) )
	cLogAvisos := cLogErros := ""//Os logs precisam ser reiniciados a cada simula��o
	aSize(aItemsEvt,0)
	aItemsEvt := {}
	//Preenche os parametros para a simula��o
	SetListPar( @oModelEven, @aListParam )
	
	//Processa a simul��o conforme a lista de parametros
	ProcSimula(oSay, @aListParam, lAutomato, @aItemsEvt )
	
	//Se existirem itens na lista a mesma ser� exibida
	If Len( aListParam ) > 0
		
		//Exibe os resutlados
		ExibirSimu(aListParam, @cLogAvisos, @cLogErros, lAutomato, @aItemsEvt )
		If lAutomato	
			aResult := 	aListParam
		EndIf	
	EndIf
Else
	Alert( STR0090 )//"Informe os per�odos para simula��o"
EndIf

Return( Nil )

/*/{Protheus.doc} TelaParSim
Tela dos parametros do processo de simula��o
@author david.costa
@since 27/01/2017
@version 1.0
@param cLogAvisos, character, Log de Avisos do processo
@param cLogErros, character, Log de Erros do processo
@return ${return}, ${return_description}
@example
TelaParSim( @cLogAvisos, @cLogErros )
/*/Static Function TelaParSim( cLogAvisos, cLogErros, aItemsEvt )

Local oFont		as object
Local oDlgParam	as object
Local aSizeAuto	as array
Local aHeader	as array
Local aCols		as array
Local oSay		as object

Private oGetDBPer	as object
Private cListKey	as character
Private uCampo1	as character
Private uCampo2	as character
Private uCampo3	as logical
Private uCampo4	as character
Private uCampo5	as character

Default aItemsEvt := {}

oFont		:=	TFont():New( "Arial",, -11 )
oDlgParam	:=	Nil
aSizeAuto	:=	MsAdvSize()
aHeader	:=	{}
aCols		:=	{}

oGetDBPer	:=	Nil
cListKey	:=	""
uCampo1	:=	Space( 6 )
uCampo2	:=	Space( 200 )
uCampo3	:=	.F.
uCampo4	:=	Space( 6 )
uCampo5	:=	Space( 200 )

//Define as Colunas da Grid de Per�odos
GetHeadCols( aHeader )

//Tela dos Parametros da simula��o
oDlgParam := MSDialog():New( 50,50,600,800, Upper( STR0091 ),,,.F.,,,,,,.T.,,,.T. )//"Simula��o da Apura��o"

//Como Default o item posicionado na Grid do Cadastro � carregado como principal
uCampo1 := T0N->T0N_CODIGO
uCampo2 := T0N->T0N_DESCRI

nTop := 5

//Evento tribut�rio 1
TGet():New( nTop, 20, { |x| If( PCount() == 0, uCampo1, uCampo1 := x ) }, oDlgParam, 65, 10, "@!", { || ValidEvent( "1" ) },,,,,, .T.,,,,,,,,, "T0NA",,,,,,,, STR0092 , 1, oFont ) //"Evento Tribut�rio 1"
TGet():New( nTop, 90, { |x| If( PCount() == 0, uCampo2, uCampo2 := x ) }, oDlgParam, 200, 10, "@!",,,,,,, .T.,,, { || .F. },,,,,,,,,,,,,, STR0093, 1, oFont ) //"Descri��o"

//"Simula��o comparativa?"
nTop += 25
TCheckBox():New( nTop, 20, STR0094, { |x| If( PCount() == 0, uCampo3, uCampo3 := x ) }, oDlgParam, 65, 10,,,,,,,,.T.,,,)//"Simula��o comparativa?"

//Evento tribut�rio 2
nTop += 10
TGet():New( nTop, 20, { |x| If( PCount() == 0, uCampo4, uCampo4 := x ) }, oDlgParam, 65, 10, "@!", { || ValidEvent( "2" ) },,,,,, .T.,,,{ || uCampo3 },,,,,, "T0NA",,,,,,,, STR0095, 1, oFont ) //"Evento Tribut�rio 2"
TGet():New( nTop, 90, { |x| If( PCount() == 0, uCampo5, uCampo5 := x ) }, oDlgParam, 200, 10, "@!",,,,,,, .T.,,, { || .F. },,,,,,,,,,,,,, STR0093, 1, oFont ) //"Descri��o"

nTop += 30
TButton():New( nTop, 020, STR0096, oDlgParam, { || AddPeriodo() }, 55,20,,,.F.,.T.,.F.,,.F.,,,.F. )//"Selecionar Per�odos"
nTop += 30

//Grid de per�odos
oGetDBPer := MsNewGetDados():New(nTop, 010, 225, 370, GD_DELETE, "AllwaysTrue", "AllwaysTrue", "", { } ,;
0 , 99, "AllwaysTrue", "", "AllwaysTrue", oDlgParam, aHeader, aCols)

nTop += 150

TButton():New( nTop, 230, STR0097, oDlgParam, { || FWMsgRun(, { |oSay| Simular( oSay, @cLogAvisos, @cLogErros,/*4*/,/*5*/,@aItemsEvt ) } , STR0088, STR0089) } , 55,20,,,.F.,.T.,.F.,,.F.,,,.F. )//"Simula��o da Apura��o" # "Executando simula��o"
TButton():New( nTop, 300, STR0098, oDlgParam, { || EndSimulac(@aItemsEvt) .and. oDlgParam:End() }, 55,20,,,.F.,.T.,.F.,,.F.,,,.F. )//"Fechar"

oDlgParam:lCentered := .T.
oDlgParam:Activate()

Return( Nil )

/*/{Protheus.doc} EndSimulac
Limpas as V�ri�veis dos parametros
@author david.costa
@since 27/01/2017
@version 1.0
@return ${.T.}, ${Verdadeiro}
@example
EndSimulac()
/*/Static Function EndSimulac(aItemsEvt)

Default aItemsEvt := {}

uCampo4 := uCampo1 := Space( 6 )
uCampo5 := uCampo2 := Space( 200 )
uCampo3 := .F.
cListKey := ""
aSize(aItemsEvt,0)
aItemsEvt := {}

Return( .T. )

/*/{Protheus.doc} ListPerPar
Monta a Lista de Per�odo e parametros da apura��o para o evento
@author david.costa
@since 27/01/2017
@version 1.0
@param oModelEven, objeto, Passar por refer�ncia o Objeto FWFormModel() do cadastro do Evento Tribut�rio
@return ${aPerParam}, ${Lista de Parametros do Evento}
@example
ListPerPar( oModelEven )
/*/Static Function ListPerPar( oModelEven )

Local oModelPeri	as object
Local cChave		as character
Local nTamChave	as numeric
Local nPosicao	as numeric
Local aPerParam	as array
Local aParametro	as array
Local aParRural	as array

oModelPeri	:=	Nil
cChave		:=	""
nTamChave	:=	36
nPosicao	:=	1
aPerParam	:=	{}
aParametro	:=	{}
aParRural	:=	{}

If !Empty( StrTran( cListKey, "|", "" ) )
	While nPosicao <= Len( cListKey )
		cChave := SubStr( cListKey, nPosicao, nTamChave )
		
		If LoadPeriod( @oModelPeri, cChave )
			
			//Carrega os parametros da apura��o
			LoadParam( @aParametro, oModelPeri, oModelEven )
			
			//Carrega os parametros da atividade Rural
			LoadParam( @aParRural, oModelPeri, oModelEven )
			
			//Adiciona na lista dos parametros
			aAdd( aPerParam, { oModelPeri, aParametro, "", aParRural } )
		EndIf
		
		nPosicao += nTamChave + 1
	EndDo
	//Ordena os per�odos
	aPerParam := aSort( aPerParam,,,{ |x,y| x[1]:GetValue( "MODEL_CWV", "CWV_INIPER") < y[1]:GetValue( "MODEL_CWV", "CWV_INIPER") } )
EndIf

Return( aPerParam )

/*/{Protheus.doc} ValidEvent
Valida se os parametros passados na tela est�o corretos
@author david.costa
@since 27/01/2017
@version 1.0
@param nOp, num�rico, Op��o do campo para valida��o
@return ${lRet}, ${se o campo est� v�lido ou n�o}
@example
ValidEvent( nOp )
/*/Static Function ValidEvent( nOp )

Local cTributo1	as character
Local cTributo2	as character
Local lRet			as logical

cTributo1	:=	""
cTributo2	:=	""
lRet		:=	.T.

DbSelectArea( "T0N" )
T0N->( DbSetOrder(2) )
If nOp == "1" .and. T0N->( MsSeek( xFilial( "T0N" ) + uCampo1 ) )
	uCampo2 := T0N->T0N_DESCRI
ElseIf nOp == "2" .and. T0N->( MsSeek( xFilial( "T0N" ) + uCampo4 ) )
	uCampo5 := T0N->T0N_DESCRI
ElseIf ( !Empty( uCampo1 ) .and. nOp == "1" ) .or.;
		( !Empty( uCampo4 ) .and. nOp == "2" )
	MsgInfo( STR0099 ) //"C�digo inexistente"
	lRet := .F.
EndIf

If !Empty( uCampo1 ) .and. !Empty( uCampo4 ) .and. uCampo3
	cTributo1 := Posicione( "T0N", 2, xFilial( "T0N" ) + uCampo1, "T0N->T0N_IDTRIB" )
	cTributo2 := Posicione( "T0N", 2, xFilial( "T0N" ) + uCampo4, "T0N->T0N_IDTRIB" )

	If cTributo1 != cTributo2
		MsgInfo( STR0100 ) //"Os Eventos devem ter o mesmo tributo."
		lRet := .F.
	EndIf
EndIf

Return( lRet )

/*/{Protheus.doc} GetHeadCols
Define as colunas da Grid de per�odos
@author david.costa
@since 27/01/2017
@version 1.0
@param aHeader, array, Array que receber� o dicion�rio da Grid
@return ${Nil}, ${Nulo}
@example
GetHeadCols( aHeader )
/*/Static Function GetHeadCols( aHeader )

Aadd(aHeader, {;
              STR0101,;				//X3Titulo() // "In�cio Per�odo"
              "INIPER",;  			//X3_CAMPO
              "@!",;					//X3_PICTURE
              8,;						//X3_TAMANHO
              0,;						//X3_DECIMAL
              "",;					//X3_VALID
              "",;					//X3_USADO
              "D",;					//X3_TIPO
              "",;					//X3_F3
              "V",;					//X3_CONTEXT
              "",;					//X3_CBOX
              "",;					//X3_RELACAO
              .F.})					//X3_WHEN

Aadd(aHeader, {;
              STR0102,;			//X3Titulo()//"Fim Per�odo"
              "FIMPER",;  		//X3_CAMPO
              "@!",;				//X3_PICTURE
              8,;					//X3_TAMANHO
              0,;					//X3_DECIMAL
              "",;				//X3_VALID
              "",;				//X3_USADO
              "D",;				//X3_TIPO
              "",;				//X3_F3
              "V",;				//X3_CONTEXT
              "",;				//X3_CBOX
              "",;				//X3_RELACAO
              .F.})				//X3_WHEN

Aadd(aHeader, {;
              STR0165,;									//X3Titulo()//"Status"
              "STATUS",;  								//X3_CAMPO
              "",;										//X3_PICTURE
              1,;											//X3_TAMANHO
              0,;											//X3_DECIMAL
              "",;										//X3_VALID
              "",;										//X3_USADO
              "C",;										//X3_TIPO
              "",;										//X3_F3
              "V",;										//X3_CONTEXT
              "1=Aberto;2=Encerrado",;					//X3_CBOX
              "",;										//X3_RELACAO
              .F.})	
 
Return( Nil )

//---------------------------------------------------------------------
/*/{Protheus.doc} AddPeriodo

Tela para sele��o dos Per�odos.

@Return	.T.

@Author	David Costa
@Since		27/01/2017
@Version	1.0

@Altered by Felipe C. Seolin in 15/02/2017 - Alterado de MsSelect para FWMarkBrowse
/*/
//---------------------------------------------------------------------
Static Function AddPeriodo()

Local cAliasQry as character
Local cTempTab 	as character
Local cCampos	as character
Local cChave	as character
Local cTitle	as character
Local cReadVar  as character
Local cCombo	as character
Local cSelect	as character
Local cFrom		as character
Local cWhere	as character
Local cOrderBy  as character
Local nPos		as numeric
Local nI		as numeric
Local aStruct	as array
Local aColumns  as array
Local aAux		as array
Local aIndex	as array
Local aSeek		as array
Local aCombo	as array
Local aID		as array
Local aPerIni	as array
Local aPerFim	as array
Local aStatus	as array
Local oTmpTab	as object

cAliasQry := GetNextAlias()
cTempTab  := ""
cCampos	  := "CWV_INIPER|CWV_FIMPER|CWV_STATUS"
cChave	  := "CWV_ID"
cTitle	  := STR0103 //"Per�odo"
cReadVar  := ReadVar()
cCombo	  := ""
cSelect	  := ""
cFrom	  := ""
cWhere	  := ""
cOrderBy  := ""
nPos	  := 0
nI		  := 0
aStruct	  := {}
aColumns  := {}
aAux	  := {}
aIndex	  := {}
aSeek	  := {}
aCombo	  := {}
aID		  := TamSX3( "CWV_ID" )
aPerIni	  := TamSX3( "CWV_INIPER" )
aPerFim	  := TamSX3( "CWV_FIMPER" )
aStatus	  := TamSX3( "CWV_STATUS" )
oTmpTab	  := Nil

//------------------------------------
// Executa consulta ao banco de dados
//------------------------------------
cSelect		:= "CWV_ID, CWV_INIPER, CWV_FIMPER, CWV_STATUS "
cFrom		:= RetSqlName( "CWV" ) + " CWV "
cWhere		:= " CWV.CWV_FILIAL = '" + xFilial( "CWV" ) + "' "
cWhere		+= "AND CWV.CWV_IDTRIB = '" + Posicione( "T0N", 2, xFilial( "T0N" ) + uCampo1, "T0N->T0N_IDTRIB" ) + "' "
cWhere		+= "AND CWV.D_E_L_E_T_ = '' "
cOrderBy	:= "CWV.R_E_C_N_O_ "

cSelect		:= "%" + cSelect  + "%"
cFrom  		:= "%" + cFrom    + "%"
cWhere		:= "%" + cWhere   + "%"
cOrderBy	:= "%" + cOrderBy + "%"

BeginSql Alias cAliasQry
	column CWV_INIPER as Date
	column CWV_FIMPER as Date

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
	ORDER BY
		%Exp:cOrderBy%
EndSql

//------------------------------------
// Monta array com a estrutura de campos da tabela temporaria
//------------------------------------
aStruct := {  {"MARK"	   , "C"	   , 2		   , 0 		 	},;
			  {"CWV_ID"	   , aID[3]	   , aID[1]	   , aID[2]	 	},;
			  {"CWV_INIPER", aPerIni[3], aPerIni[1], aPerIni[2] },;
			  {"CWV_FIMPER", aPerFim[3], aPerFim[1], aPerFim[2] },;
			  {"CWV_STATUS", aStatus[3], aStatus[1], aStatus[2] } }

cTempTab := getNextAlias()

//------------------------------------
// Instancia o objeto Temporary Table
//------------------------------------
oTmpTab := FWTemporaryTable():New(cTempTab, aStruct)
oTmpTab:AddIndex("1", {"CWV_INIPER"} )
oTmpTab:Create()

DbSelectArea(cTempTab)
(cTempTab)->(DbSetOrder(1))
(cTempTab)->(DBGoTop())

//------------------------------------
// Popula arquivo de dados tempor�rio
//------------------------------------
While ( cAliasQry )->( !Eof() )
	If RecLock( ( cTempTab ), .T. )
		( cTempTab )->MARK		 :=	"  "
		( cTempTab )->CWV_ID	 :=	( cAliasQry )->CWV_ID
		( cTempTab )->CWV_INIPER :=	( cAliasQry )->CWV_INIPER
		( cTempTab )->CWV_FIMPER :=	( cAliasQry )->CWV_FIMPER
		( cTempTab )->CWV_STATUS :=	( cAliasQry )->CWV_STATUS
		( cTempTab )->( MsUnLock() )
	EndIf
	( cAliasQry )->( DBSkip() )
EndDo
( cAliasQry )->( DBCloseArea() )

//---------------------------
// Cria estrutura de colunas
//---------------------------
For nI := 1 to Len( aStruct )
	If aStruct[nI,1] $ cCampos
		nPos ++
		aAdd( aColumns, FWBrwColumn():New() )
		aColumns[nPos]:SetData( &( "{ || " + aStruct[nI,1] + " }" ) )
		aColumns[nPos]:SetTitle( RetTitle( aStruct[nI,1] ) )
		aColumns[nPos]:SetDecimal( aStruct[nI,4] )
		aColumns[nPos]:SetPicture( PesqPict( SubStr( aStruct[nI,1], 1, At( "_", aStruct[nI,1] ) - 1 ), aStruct[nI,1] ) )
		aColumns[nPos]:SetType( aStruct[nI,2] )
		aColumns[nPos]:SetAlign( Iif( aStruct[nI,2] == "N", 2, 1 ) )

		If aStruct[nI,2] == "C"
			DBSelectArea( "SX3" )
			SX3->( DBSetOrder( 2 ) )
			If SX3->( MsSeek( aStruct[nI,1] ) )
				cCombo := X3Cbox()
			EndIf
			If !Empty( cCombo )
				aCombo := StrToKarr( cCombo, ";" )
				aColumns[nPos]:SetOptions( aCombo )
			EndIf
		EndIf
	EndIf
Next nI

//---------------------------------
// Executa a montagem da interface
//---------------------------------
TAF433SXB( cTitle, cTempTab, cReadVar, cChave, aColumns,, .T. )

//---------------------------------
//Exclui a tabela e fecha o alias
//---------------------------------
oTmpTab:Delete()

//Preenche a Grid de sele��o dos per�odos
SetGridPer()

Return( .T. )

/*/{Protheus.doc} SetGridPer
Atualiza a Grid dos per�dos a partir do que foi slecionado pelo usu�rio
@author david.costa
@since 27/01/2017
@version 1.0
@return ${.T.}, ${Verdadeiro}
@example
SetGridPer()
/*/Static Function SetGridPer()

Local cChave		as character
Local nTamChave	as numeric
Local nPosicao	as numeric
Local aCols		as array

cChave		:=	""
nTamChave	:=	36
nPosicao	:=	1
aCols		:=	{}

If !Empty( StrTran( cListKey, "|", "" ) )
	While nPosicao <= Len( cListKey )
		cChave := SubStr( cListKey, nPosicao, nTamChave )
		aAdd( aCols, { Posicione( "CWV", 1, xFilial( "CWV" ) + cChave , "CWV->CWV_INIPER" ), ;
			Posicione( "CWV", 1, xFilial( "CWV" ) + cChave , "CWV->CWV_FIMPER" ), ;
			Posicione( "CWV", 1, xFilial( "CWV" ) + cChave , "CWV->CWV_STATUS" ), .F. } )
		nPosicao += nTamChave + 1
	EndDo
	
	//Ordena a Grid pela data inicial do per�odo
	aCols:= aSort( aCols,,,{ |x,y| x[1] < y[1] } )
	oGetDBPer:SetArray( aCols, .T. )
	oGetDBPer:Refresh()
EndIf

Return( .T. )

/*/{Protheus.doc} LoadPeriod
Carrega o Model do Per�odo
@author david.costa
@since 27/01/2017
@version 1.0
@param oModelPeri, objeto, Passar por refer�ncia o objeto FWFormModel() do cadastro do per�odo
@param cIdPeriodo, character, Identificador do per�odo
@return ${lRet}, ${verdadeiro se o model for carregado}
@example
LoadPeriod( @oModelPeri, cIdPeriodo )
/*/Static Function LoadPeriod( oModelPeri, cIdPeriodo )

Local lRet	as logical

lRet	:=	.F.

DbSelectArea( "CWV" )
CWV->( DbSetOrder( 1 ) )

If CWV->( MsSeek( xFilial( "CWV" ) + cIdPeriodo ) )
	oModelPeri := FWLoadModel( 'TAFA444' )
	oModelPeri:SetOperation( MODEL_OPERATION_UPDATE )
	oModelPeri:Activate()
	lRet := .T.
EndIf

Return( lRet )

/*/{Protheus.doc} ExibirSimu
Exibe a Tela com o Resultados da Simula��o
@author david.costa
@since 27/01/2017
@version 1.0
@param aListParam, array, Paramentro da Simula��o
@param cLogAvisos, character, Log de Avisos do Processo
@param cLogErros, character, Log de Erros do Processo
@return ${Nil}, ${Nulo}
@example
ExibirSimu( aListParam, @cLogAvisos, @cLogErros )
/*/Static Function ExibirSimu(aListParam, cLogAvisos, cLogErros, lAutomato, aItemsEvt )

Local oFont			as object
Local oFolderGer	as object
Local cTitulo1		as character
Local cTitulo2		as character
Local cCadastro		as character
Local cDecPer		as character
Local nTopGeral		as numeric
Local nAltGSaldo	as numeric
Local nIndicePer	as numeric
Local aHeader		as array
Local aCols			as array
Local aAbasEvent	as array
Local aSize			as array
Local aButtons		as array
Local lComparar		as logical

Private oMultiGet	as object
Private oTreePerio	as object
Private oDlgSimula	as object
Private oGetDBDet1	as object
Private oGetDBDet2	as object
Private oFolderEve	as object
Private oFolder1	as object
Private oFolder2	as object
Private oScroll1	as object
Private oScroll2	as object
Private oPanel1		as object
Private oPanel2		as object
Private aColsDet1	as array
Private aColsDet2	as array
Private aoGet		as array
Private cDescEve1	as character
Private cDescEve2	as character
Private cDescFTri1	as character
Private cDescFTri2	as character
Private cDescPerio	as character
Private cTribu		as character
Private cLogPerio1	as character
Private cLogPerio2	as character
Private nSaldoEve1	as numeric
Private nSaldoEve2	as numeric
Private nVlrImpost	as numeric
Private nBaseCalcu	as numeric
Private nAliqImpos	as numeric
Private nVlrIsento	as numeric
Private nParcIsent	as numeric
Private nNMesesIse	as numeric
Private nVlrAdicio	as numeric
Private nAliqAdici	as numeric
Private nVlrPrIRPJ	as numeric
Private nSaldoDeve	as numeric
Private nVlrDeduco	as numeric
Private nVlrCompen	as numeric
Private nReceAliq1	as numeric
Private nReceAliq2	as numeric
Private nReceAliq3	as numeric
Private nReceAliq4	as numeric
Private nReceGrup1	as numeric
Private nReceGrup2	as numeric
Private nReceGrup3	as numeric
Private nReceGrup4	as numeric
Private nAliqGrup1	as numeric
Private nAliqGrup2	as numeric
Private nAliqGrup3	as numeric
Private nAliqGrup4	as numeric
Private nLucEstima	as numeric
Private nVlrExclus	as numeric
Private nDemaisRec	as numeric
Private nResulCont	as numeric
Private nResulOper	as numeric
Private nResulNOpe	as numeric
Private nLucroReal	as numeric
Private nVlrAdicoe	as numeric
Private nVlrDoacoe	as numeric
Private nCompPreju	as numeric
Private nImpDevMes	as numeric
Private nDeviAnter	as numeric
Private nAdicTribu	as numeric
Private nVlrImpos2	as numeric
Private nBaseCalc2	as numeric
Private nAliqImpo2	as numeric
Private nVlrIsent2	as numeric
Private nParcIsen2	as numeric
Private nNMesesIs2	as numeric
Private nVlrAdici2	as numeric
Private nAliqAdic2	as numeric
Private nVlrPrIRP2	as numeric
Private nSaldoDev2	as numeric
Private nVlrDeduc2	as numeric
Private nVlrCompe2	as numeric
Private nReceAlq12	as numeric
Private nReceAlq22	as numeric
Private nReceAlq32	as numeric
Private nReceAlq42	as numeric
Private nReceGrp12	as numeric
Private nReceGrp22	as numeric
Private nReceGrp32	as numeric
Private nReceGrp42	as numeric
Private nAliqGrp12	as numeric
Private nAliqGrp22	as numeric
Private nAliqGrp32	as numeric
Private nAliqGrp42	as numeric
Private nLucEstim2	as numeric
Private nVlrExclu2	as numeric
Private nDemaisRe2	as numeric
Private nResulCon2	as numeric
Private nResulOpe2	as numeric
Private nResulNOp2	as numeric
Private nLucroRea2	as numeric
Private nVlrAdico2	as numeric
Private nVlrDoaco2	as numeric
Private nCompPrej2	as numeric
Private nImpDevMe2	as numeric
Private nDeviAnte2	as numeric
Private nAdicTrib2	as numeric
Private nLRAposPj1	as numeric
Private nLRAposPj2	as numeric
Private nBCParcia1	as numeric
Private nBCParcia2	as numeric
Private nPrejRura1	as numeric
Private nPrejRura2	as numeric
Private nResCtbRu1	as numeric
Private nResCtbRu2	as numeric
Private nResOpRur1	as numeric
Private nResOpRur2	as numeric
Private nResNOpRu1	as numeric
Private nResNOpRu2	as numeric
Private nLRealRur1	as numeric
Private nLRealRur2	as numeric
Private nVlrAdRur1	as numeric
Private nVlrAdRur2	as numeric
Private nVlrExRur1	as numeric
Private nVlrExRur2	as numeric
Private nVlrDoaRu1	as numeric
Private nVlrDoaRu2	as numeric
Private nLRApPjRu1	as numeric
Private nLRApPjRu2	as numeric
Private nPrejGera1	as numeric
Private nPrejGera2	as numeric
Private nPjCompGe1	as numeric
Private nPjCompGe2	as numeric
Private nBCParRur1	as numeric
Private nBCParRur2	as numeric
Private nCompPjRu1	as numeric
Private nCompPjRu2	as numeric

Default lAutomato := .F.
Default aItemsEvt := {}

oFont		:=	TFont():New( "Arial",, -11 )
oFolderGer	:=	Nil
cTitulo1	:=	STR0092 //"Evento Tribut�rio 1"
cTitulo2	:=	STR0095 //"Evento Tribut�rio 2"
cCadastro	:=	Upper( STR0088 ) //"Simula��o da Apura��o"
cDecPer		:=	""
nTopGeral	:=	0
nAltGSaldo	:=	0
nIndicePer	:=	0
aHeader		:=	{}
aCols		:=	{}
aAbasEvent	:=	{}
aButtons	:=	{}
aSize		:=	MsAdvSize( .T. )
lComparar	:=	Len( aListParam ) > 1

oMultiGet	:= Nil
oTreePerio	:= Nil
oDlgSimula	:= Nil
oGetDBDet1	:= Nil
oGetDBDet2	:= Nil
oFolderEve	:= Nil
oFolder1	:= Nil
oFolder2	:= Nil
oScroll1	:= Nil
oScroll2	:= Nil
oPanel1		:= Nil
oPanel2		:= Nil
aColsDet1	:= {}
aColsDet2	:= {}
aoGet		:= {}

//Vari�veis com os valores da Tela de Simula��o
cDescEve1	:=	""
cDescEve2	:=	""
cDescFTri1	:=	""
cDescFTri2	:=	""
cDescPerio	:=	""
cTribu		:=	""
cLogPerio1	:=	""
cLogPerio2	:=	""
nSaldoEve1	:=	0
nSaldoEve2	:=	0
nVlrImpost	:=	0
nBaseCalcu	:=	0
nAliqImpos	:=	0
nVlrIsento	:=	0
nParcIsent	:=	0
nNMesesIse	:=	0
nVlrAdicio	:=	0
nAliqAdici	:=	0
nVlrPrIRPJ	:=	0
nSaldoDeve	:=	0
nVlrDeduco	:=	0
nVlrCompen	:=	0
nReceAliq1	:=	0
nReceAliq2	:=	0
nReceAliq3	:=	0
nReceAliq4	:=	0
nReceGrup1	:=	0
nReceGrup2	:=	0
nReceGrup3	:=	0
nReceGrup4	:=	0
nAliqGrup1	:=	0
nAliqGrup2	:=	0
nAliqGrup3	:=	0
nAliqGrup4	:=	0
nLucEstima	:=	0
nVlrExclus	:=	0
nDemaisRec	:=	0
nResulCont	:=	0
nResulOper	:=	0
nResulNOpe	:=	0
nLucroReal	:=	0
nVlrAdicoe	:=	0
nVlrDoacoe	:=	0
nCompPreju	:=	0
nImpDevMes	:=	0
nDeviAnter	:=	0
nAdicTribu	:=	0
nVlrImpos2	:=	0
nBaseCalc2	:=	0
nAliqImpo2	:=	0
nVlrIsent2	:=	0
nParcIsen2	:=	0
nNMesesIs2	:=	0
nVlrAdici2	:=	0
nAliqAdic2	:=	0
nVlrPrIRP2	:=	0
nSaldoDev2	:=	0
nVlrDeduc2	:=	0
nVlrCompe2	:=	0
nReceAlq12	:=	0
nReceAlq22	:=	0
nReceAlq32	:=	0
nReceAlq42	:=	0
nReceGrp12	:=	0
nReceGrp22	:=	0
nReceGrp32	:=	0
nReceGrp42	:=	0
nAliqGrp12	:=	0
nAliqGrp22	:=	0
nAliqGrp32	:=	0
nAliqGrp42	:=	0
nLucEstim2	:=	0
nVlrExclu2	:=	0
nDemaisRe2	:=	0
nResulCon2	:=	0
nResulOpe2	:=	0
nResulNOp2	:=	0
nLucroRea2	:=	0
nVlrAdico2	:=	0
nVlrDoaco2	:=	0
nCompPrej2	:=	0
nImpDevMe2	:=	0
nDeviAnte2	:=	0
nAdicTrib2	:=	0
nLRAposPj1	:=	0
nLRAposPj2	:=	0
nBCParcia1	:=	0
nBCParcia2	:=	0
nPrejRura1	:=	0
nPrejRura2	:=	0
nResCtbRu1	:=	0
nResCtbRu2	:=	0
nResOpRur1	:=	0
nResOpRur2	:=	0
nResNOpRu1	:=	0
nResNOpRu2	:=	0
nLRealRur1	:=	0
nLRealRur2	:=	0
nVlrAdRur1	:=	0
nVlrAdRur2	:=	0
nVlrExRur1	:=	0
nVlrExRur2	:=	0
nVlrDoaRu1	:=	0
nVlrDoaRu2	:=	0
nLRApPjRu1	:=	0
nLRApPjRu2	:=	0
nPrejGera1	:=	0
nPrejGera2	:=	0
nPjCompGe1	:=	0
nPjCompGe2	:=	0
nBCParRur1	:=	0
nBCParRur2	:=	0
nCompPjRu1	:=	0
nCompPjRu2	:=	0
//Limpa variaveis impress�o simula��o em Excel
_aExcRsCnt := {} //AddResCont
_aExcRsCtR := {} //AddResCont Rural
_aExcLcRea := {} //AddLucReal
_aExcLcReR := {} //AddLucReal Rural
_aExcRAApo := {} //AddLRAposP
_aExcRAApR := {} //AddLRAposP Rural
_aExcBCPar := {} //AddBCParci
_aExcBCPcR := {} //AddBCParci Rural
_aExcRAlq1 := {} //AddRecAlq1
_aExcRAlq2 := {} //AddRecAlq2
_aExcRAlq3 := {} //AddRecAlq3
_aExcRAlq4 := {} //AddRecAlq4
_aExcLcEst := {} //AddLucEsti
_aExcBsCal := {} //AddBaseCal
_aExcVrImp := {} //AddVlrImpo
_aExcVrIse := {} //AddVlrIsen
_aExcVrAdi := {} //AddVlrAdic
_aExcProIR := {} //AddProIRPJ
_aExcDvMes := {} //AddDeviMes
_aExcAdDev := {} //AddDevedor
_aExcSepar := {} //AddSeparad

nAltGSaldo := Iif( lComparar, 70, 45 )
If !lAutomato
	//Tela Principal da Simula��o
	oDlgSimula := MSDialog():New( 50, 50, aSize[6], aSize[5], cCadastro,,, .F.,,,,,, .T.,,, .T. )

	//Aba Per�odo
	oFolderGer := TFolder():New( 30, 5, { STR0103 },, oDlgSimula,,,, .T.,, ( oDlgSimula:nWidth / 2.45 / 100 ) * 20, oDlgSimula:nHeight / 2.4 ) //"Per�odo"

	//Grupo Saldo Apurado
	@nTopGeral,5 GROUP oGrupSaldo TO nAltGSaldo, oFolderGer:nWidth / 2.1 PROMPT STR0104 OF oFolderGer:aDialogs[1] PIXEL //"Saldo Apurado"
	nTopGeral += 10

	//Saldo Apurado Evento 1
	aAdd( aoGet, TGet():New( nTopGeral, 10, { || @nSaldoEve1 }, oGrupSaldo, oGrupSaldo:nWidth / 2.2, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,, .T.,, cTitulo1, 1, oFont ) )

	If lComparar
		nTopGeral += 25

		//Saldo Apurado Evento 2
		aAdd( aoGet, TGet():New( nTopGeral, 10, { || @nSaldoEve2 }, oGrupSaldo, oGrupSaldo:nWidth / 2.2, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,, .T.,, cTitulo2, 1, oFont ) )
	EndIf

	nTopGeral += 40

	//Cria a �rvore dos Per�odos
	oTreePerio := DBTree():New( nTopGeral, 5, oFolderGer:nHeight / 2.3, oFolderGer:nWidth / 2.1, oFolderGer:aDialogs[1], { || LoadSimula( aListParam,, @cLogAvisos ) },, .T. )
	oTreePerio:AddTree( STR0105, .T., "FOLDER01", "FOLDER02",,, "001" ) //"Per�odos"
	oTreePerio:TreeSeek( "001" )
EndIf
	//Adiciona os Per�odos na �rvore
For nIndicePer := 1 to Len( aListParam[1,PARAM_SIMUL_LISTA_PAR] )
	cDecPer := DToC( aListParam[1,PARAM_SIMUL_LISTA_PAR,nIndicePer,LISTA_PAR_MODEL_PERIODO]:GetValue( "MODEL_CWV", "CWV_INIPER" ) )

	//Formata para dd/mm/aa
	cDecPer := SubStr( cDecPer, 1, 6 ) + SubStr( cDecPer, 9, 2 )

	If !lAutomato
		oTreePerio:AddItem( cDecPer, AllTrim( Str( nIndicePer + 1 ) ), "FOLDER3",,,, 2 )
	EndIf	
Next nIndicePer

//Abas dos Eventos
aAbasEvent := Iif( lComparar, { cTitulo1, cTitulo2 }, { cTitulo1 } )
If !lAutomato
	oFolderEve := TFolder():New( 30, ( ( oDlgSimula:nWidth / 2.45 / 100 ) * 20 ) + 10, aAbasEvent,, oDlgSimula,,,, .T.,, oDlgSimula:nWidth / 2.45, oDlgSimula:nHeight / 2.4 )

	//Adiciona os dados do Evento 1
	AddDadoEve( oFolderEve:aDialogs[1], oFont, @cDescEve1, @cDescFTri1 )

	If lComparar
		//Adiciona os dados do Evento 2
		AddDadoEve( oFolderEve:aDialogs[2], oFont, @cDescEve2, @cDescFTri2 )
	EndIf

	If lComparar
		//Adiciona os dados da Simula��o e do Detalhamento dos dois Eventos
		AddSimuDet( oFolderEve:aDialogs[1], oFont, aListParam, oFolderEve:aDialogs[2], lComparar )
	Else
		//Adiciona os dados da Simula��o e do Detalhamento
		AddSimuDet( oFolderEve:aDialogs[1], oFont, aListParam,, lComparar )
	EndIf

	aAdd( aButtons, { , { || ImpSimuExc(aListParam, @aItemsEvt) }, , STR0192, { || .T. } } )//Exportar Simula��o Excel"
	aAdd( aButtons, { , { || RelPartA( aListParam ) }, , STR0162, { || .T. } } )//"Relat�rio Parte A - Estimativa por balan�o"
	aAdd( aButtons, { , { || RelPartB( aListParam ) }, , STR0163, { || .T. } } )//"Relat�rio Parte B - Estimativa por balan�o"
	

	oDlgSimula:bInit := EnchoiceBar( oDlgSimula, { || oDlgSimula:End() }, { || oDlgSimula:End() },, @aButtons,,,,,,.F.,.F.,.F.)
	oDlgSimula:lCentered := .T.
EndIf

//Atualiza a Tela da Simula��o com o Resultado da Simula��o do primeiro Per�odo
LoadSimula( aListParam, 1, @cLogAvisos, lAutomato )
If !lAutomato
	oDlgSimula:Activate()
EndIf	

Return()

/*/{Protheus.doc} AddDadoEve
Adiciona os dados de identifica��o do Evento
@author david.costa
@since 27/01/2017
@version 1.0
@param oDlgEve, objeto, Objeto que receber� os campos
@param oFont, objeto, Obejto com a fonte
@param cEvento, character, Passar por ref�ncia a variavel Private que armazenar� a descri��o do Evento
@param cFtrib, character, Passar por ref�ncia a variavel Private que armazenar� a forma te tributa��o do Evento
@return ${Nil}, ${Nulo}
@example
AddDadoEve( oFolderEve:aDialogs[ 2 ], oFont, @cDescEve2, @cDescFTri2 )
/*/Static Function AddDadoEve( oDlgEve, oFont, cEvento, cFtrib )

Local oGrupo	as object
Local nTopEvent	as numeric
Local nWidthGet as numeric
Local nLeftGet	as numeric

oGrupo		:=	Nil
nTopEvent	:=	0
nWidthGet	:=	0
nLeftGet	:=	0

//Grupo Dados da Simula��o
@nTopEvent,5 GROUP oGrupo TO 45,oFolderEve:nWidth / 2.05 PROMPT STR0150 OF oDlgEve PIXEL //"Dados da Simula��o"

nWidthGet := ( oGrupo:nWidth / 2 ) / 4.5

nTopEvent += 10
nLeftGet += 12

//Tributo
aAdd( aoGet, TGet():New( nTopEvent, nLeftGet, { || @cTribu }, oGrupo, nWidthGet, 10, "@!", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,,, STR0069, 1, oFont ) ) //"Tributo"

nLeftGet += nWidthGet + 12

//Per�odo
aAdd( aoGet, TGet():New( nTopEvent, nLeftGet, { |x| @cDescPerio }, oGrupo, nWidthGet, 10, "@!", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,,, STR0103, 1, oFont ) ) //"Per�odo"

nLeftGet += nWidthGet + 12

//Forma de Tributa��o
aAdd( aoGet, TGet():New( nTopEvent, nLeftGet, { || @cFtrib }, oGrupo, nWidthGet, 10, "@!", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,,, STR0002, 1, oFont ) ) //"Forma de Tributa��o"

nLeftGet += nWidthGet + 12

//Evento Tribut�rio
aAdd( aoGet, TGet():New( nTopEvent, nLeftGet, { || @cEvento }, oGrupo, nWidthGet, 10, "@!", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,,, STR0106, 1, oFont ) ) //"Evento Tribut�rio"

Return()

/*/{Protheus.doc} AddSimuDet
Adiciona as Abas de Simula��o e Detalhamento da simula��o do per�odo
@author david.costa
@since 27/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que Receber� os Campos do Evento 1
@param oFont, objeto, Objeto da fonte
@param aListParam, array, Parametros da Simula��o
@param oDlgSimu2, objeto, Objeto que Receber� os Campos do Evento 2
@param lComparar, ${bool}, Informa se trata-se de uma simula��o
@return ${Nil}, ${Nulo}
@example
AddSimuDet( oFolderEve:aDialogs[ 1 ], oFont, aListParam, oFolderEve:aDialogs[ 2 ], lComparar )
/*/Static Function AddSimuDet( oDlgSimu, oFont, aListParam, oDlgSimu2, lComparar )

Local oModelEve1	as object
Local oModelEve2	as object
Local cTitulo1		as character
Local cTitulo2		as character
Local cTitulo3		as character
Local cFormaTri1	as character
Local cFormaTri2	as character
Local cTributo		as character
Local aAbasEve1		as array
Local aAbasEve2		as array
Local lRural1		as logical
Local lRural2		as logical

Private aHeader		as array
Private nTopSimula	as numeric
Private nTopSimul2	as numeric

oModelEve1	:=	Nil
oModelEve2	:=	Nil
cTitulo1	:=	STR0107 //"Simula��o"
cTitulo2	:=	STR0108 //"Detalhamento"
cTitulo3	:=	STR0109 //"Log da Apura��o"
cFormaTri1	:=	""
cFormaTri2	:=	""
cTributo	:=	""
aHeader		:=	{}
aAbasEve1	:=	{}
aAbasEve2	:=	{}
lRural1		:=	.F.
lRural2		:=	.F.

//Posicionamento dos campos na tela
nTopSimula	:=	0
nTopSimul2	:=	0

//Grid do Detalhamento
GetHeadCWX()

//Evento 1
oModelEve1 := aListParam[ 1, PARAM_SIMUL_MODEL_EVENTO ]

//Verifica se o Evento tem atividade Rural
lRural1 := !Empty( aListParam[ 1, 1 ]:GetValue( "MODEL_T0N", "T0N_IDEVEN" ) )

//Tipo do Tributo
cTributo := Posicione( "T0J", 1, xFilial( "T0J" ) + oModelEve1:GetValue( "MODEL_T0N", "T0N_IDTRIB" ), "T0J_TPTRIB" )

//Forma de Tributa��o
cFormaTri1 := XFUNID2Cd( oModelEve1:GetValue( "MODEL_T0N", "T0N_IDFTRI" ), "T0K", 1 )

//Simula��o e Detalhamento
aAbasEve1 := { cTitulo1, cTitulo2, cTitulo3 }
oFolder1 := TFolder():New( 45, 5, aAbasEve1,, oDlgSimu,,,, .T.,, oFolderEve:nWidth / 2.05, oFolderEve:nHeight / 2.9 )
oScroll1 := TScrollArea():New( oFolder1:aDialogs[1], 01, 01, ( oFolder1:nHeight / 2.3 ), oFolder1:nWidth / 2.02, .T. )
@01,01 MSPanel oPanel1 Of oScroll1 Size oFolder1:nWidth / 2.02,( oFolder1:nHeight / 2.3 ) + 250
oScroll1:SetFrame( oPanel1 )

If lComparar
	//Evento 2
	oModelEve2 := aListParam[ 2, PARAM_SIMUL_MODEL_EVENTO ]
	
	//Verifica se o Evento tem atividade Rural
	lRural2 := !Empty( oModelEve2:GetValue( "MODEL_T0N", "T0N_IDEVEN" ) )
	
	//Forma de Tributa��o
	cFormaTri2 := XFUNID2Cd( oModelEve2:GetValue( "MODEL_T0N", "T0N_IDFTRI" ), "T0K", 1 )
	
	//Simula��o e Detalhamento
	aAbasEve2 := { cTitulo1, cTitulo2, cTitulo3 }
	oFolder2 := TFolder():New( 45, 5, aAbasEve2,, oDlgSimu2,,,, .T.,, oFolderEve:nWidth / 2.05, oFolderEve:nHeight / 2.9 )
	oScroll2 := TScrollArea():New( oFolder2:aDialogs[1], 01, 01, oFolder2:nHeight / 2.3, oFolder2:nWidth / 2.02, .T. )
	@01,01 MSPanel oPanel2 Of oScroll2 Size oFolder2:nWidth / 2.02,( oFolder2:nHeight / 2.3 ) + 200
	oScroll2:SetFrame( oPanel2 )

	//Simula��o
	//Campos da Atividade Geral
	If lRural1
		AddSeparad( STR0151, oPanel1, oPanel2, lComparar, lRural2 ) //"Atividade Geral:"
		AddResCont( oPanel1, oFont, cFormaTri1,, oPanel2, cFormaTri2 )
		AddLucReal( oPanel1, oFont, cFormaTri1,, oPanel2, cFormaTri2 )
		AddLRAposP( oPanel1, oFont, cFormaTri1,, oPanel2, cFormaTri2 )
		AddBCParci( oPanel1, oFont, cFormaTri1,, oPanel2, cFormaTri2 )
		
		AddSeparad( STR0152, oPanel1, oPanel2, lComparar, lRural2 ) //"Atividade Rural:"
		If lRural2 
			AddResCont( oPanel1, oFont, cFormaTri1, lRural1, oPanel2, cFormaTri2, lRural2 )
			AddLucReal( oPanel1, oFont, cFormaTri1, lRural1, oPanel2, cFormaTri2, lRural2 )
			AddLRAposP( oPanel1, oFont, cFormaTri1, lRural1, oPanel2, cFormaTri2, lRural2 )
			AddBCParci( oPanel1, oFont, cFormaTri1, lRural1, oPanel2, cFormaTri2, lRural2 )
		Else
			AddResCont( oPanel1, oFont, cFormaTri1, lRural1, oPanel2 )
			AddLucReal( oPanel1, oFont, cFormaTri1, lRural1, oPanel2 )
			AddLRAposP( oPanel1, oFont, cFormaTri1, lRural1, oPanel2 )
			AddBCParci( oPanel1, oFont, cFormaTri1, lRural1, oPanel2 )
		EndIf	
	Else
		AddResCont( oPanel1, oFont, cFormaTri1,, oPanel2, cFormaTri2 )
		AddLucReal( oPanel1, oFont, cFormaTri1,, oPanel2, cFormaTri2 )
	EndIf

	AddRecAlq1( oPanel1, oFont, cFormaTri1, oPanel2, cFormaTri2 )
	AddRecAlq2( oPanel1, oFont, cFormaTri1, oPanel2, cFormaTri2 )
	AddRecAlq3( oPanel1, oFont, cFormaTri1, oPanel2, cFormaTri2 )
	AddRecAlq4( oPanel1, oFont, cFormaTri1, oPanel2, cFormaTri2 )
	AddLucEsti( oPanel1, oFont, cFormaTri1, oPanel2, cFormaTri2 )
	
	//Campos da Apura��o
	If lRural1
		AddSeparad( STR0153, oPanel1, oPanel2, lComparar, lRural2 ) //"Apura��o:"
	EndIf
	
	AddBaseCal( oPanel1, oFont, cFormaTri1, lRural1, oPanel2, cFormaTri2, lRural2 )
	AddVlrImpo( oPanel1, oFont, cFormaTri1, oPanel2, cFormaTri2 )
	
	If cTributo == TRIBUTO_IRPJ
		AddVlrIsen( oPanel1, oFont, cFormaTri1, oPanel2, cFormaTri2 )
		AddVlrAdic( oPanel1, oFont, cFormaTri1, oPanel2, cFormaTri2 )
		AddProIRPJ( oPanel1, oFont, cFormaTri1, oPanel2, cFormaTri2 )
	EndIf
	
	AddDeviMes( oPanel1, oFont, cFormaTri1, cTributo, oPanel2, cFormaTri2 )
	AddDevedor( oPanel1, oFont, cFormaTri1, cTributo, oPanel2, cFormaTri2 )
	
	//Grid dos itens do detalhamento
	oGetDBDet2 := MsNewGetDados():New( 5, 5, oFolder1:nHeight / 2.3, oFolder1:nWidth / 2.05,, "AllwaysTrue", "AllwaysTrue", "", {}, 0, 99, "AllwaysTrue", "", "AllwaysTrue", oFolder2:aDialogs[2], aHeader, {} )
	
	//Log do Per�odo
	oMultiGet2 := TMultiget():New( 5, 5, { || @cLogPerio2 }, oFolder2:aDialogs[3], oFolder1:nWidth / 2.05, oFolder1:nHeight / 2.4,,,,,,.T.,,,,,,,,,,, .T. )
Else
	//Simula��o
	//Campos da Atividade Geral
	If lRural1
		AddSeparad( STR0151, oPanel1 ) //"Atividade Geral:"
		AddResCont( oPanel1, oFont, cFormaTri1 )
		AddLucReal( oPanel1, oFont, cFormaTri1 )
		AddLRAposP( oPanel1, oFont, cFormaTri1 )
		AddBCParci( oPanel1, oFont, cFormaTri1 )
		
		AddSeparad( STR0152, oPanel1 ) //"Atividade Rural:"
		AddResCont( oPanel1, oFont, cFormaTri1, lRural1 )
		AddLucReal( oPanel1, oFont, cFormaTri1, lRural1 )
		AddLRAposP( oPanel1, oFont, cFormaTri1, lRural1 )
		AddBCParci( oPanel1, oFont, cFormaTri1, lRural1 )
	Else
		AddResCont( oPanel1, oFont, cFormaTri1 )
		AddLucReal( oPanel1, oFont, cFormaTri1 )
	EndIf

	AddRecAlq1( oPanel1, oFont, cFormaTri1 )
	AddRecAlq2( oPanel1, oFont, cFormaTri1 )
	AddRecAlq3( oPanel1, oFont, cFormaTri1 )
	AddRecAlq4( oPanel1, oFont, cFormaTri1 )
	AddLucEsti( oPanel1, oFont, cFormaTri1 )
	
	//Campos da Atividade Rural
	//Campos da Apura��o
	If lRural1
		AddSeparad( STR0153, oPanel1 ) //"Apura��o:"
	EndIf
	
	AddBaseCal( oPanel1, oFont, cFormaTri1, lRural1 )
	AddVlrImpo( oPanel1, oFont, cFormaTri1 )
	
	If cTributo == TRIBUTO_IRPJ
		AddVlrIsen( oPanel1, oFont, cFormaTri1 )
		AddVlrAdic( oPanel1, oFont, cFormaTri1 )
		AddProIRPJ( oPanel1, oFont, cFormaTri1 )
	EndIf
	
	AddDeviMes( oPanel1, oFont, cFormaTri1, cTributo )
	AddDevedor( oPanel1, oFont, cFormaTri1, cTributo )
EndIf

//Grid dos itens do detalhamento
oGetDBDet1 := MsNewGetDados():New( 5, 5, oFolder1:nHeight / 2.3, oFolder1:nWidth / 2.05,, "AllwaysTrue", "AllwaysTrue", "", {}, 0, 99, "AllwaysTrue", "", "AllwaysTrue", oFolder1:aDialogs[2], aHeader, {} )

//Log do Per�odo
oMultiGet := TMultiget():New( 5, 5, { || @cLogPerio1 }, oFolder1:aDialogs[3], oFolder1:nWidth / 2.05, oFolder1:nHeight / 2.4,,,,,,.T.,,,,,,,,,,, .T. )

Return( Nil )

/*/{Protheus.doc} AddSeparad
Adiciona uma linha de separa��o para organizar melhor a simula��o
@author david.costa
@since 02/02/2017
@version 1.0
@param cTexto, character, Titulo da separa��o
@param oDlgSimu, objeto, Objeto que receber� os campos do Evento 1
@param oDlgSimu2, objeto, Objeto que receber� os campos do Evento 2
@param lComparar, ${bool}, Informa se trata-se de uma simula��o
@param lRural2, ${bool}, Informa se o Segundo Evento tem Atividade Rural
@return ${Nil}, ${Nulo}
@example
AddSeparad( cTexto, oDlgSimu, oDlgSimu2, lComparar )
/*/Static Function AddSeparad( cTexto, oDlgSimu, oDlgSimu2, lComparar, lRural2 )

Local oFonteLbel	as object

Default lRural2	:=	.F.
Default lComparar	:=	.F.

oFonteLbel	:=	TFont():New( "Arial",, -11 )

oFonteLbel:Bold := .T.

TSay():New( nTopSimula, 2,{ || cTexto }, oDlgSimu,, oFonteLbel,,,,.T., CLR_CYAN, CLR_WHITE, 60, 10 )
nTopSimula += 5

aAdd(_aExcSepar,{UPPER(cTexto),Replicate('=',30), "", 1}) //EXCEL
If lRural2
	aAdd(_aExcSepar,{UPPER(cTexto),Replicate('=',30), "", 2}) //EXCEL
EndIf
TSay():New( nTopSimula, 2,{ || Replicate( "=" , 200 ) }, oDlgSimu,, oFonteLbel,,,,.T., CLR_CYAN, CLR_WHITE, 300, 10 )
nTopSimula += 10

//Segundo Evento
If lComparar .and. lRural2
	TSay():New( nTopSimul2, 2,{ || cTexto }, oDlgSimu2,, oFonteLbel,,,,.T., CLR_CYAN, CLR_WHITE, 60, 10 )
	nTopSimul2 += 5

	aAdd(_aExcSepar,{UPPER(cTexto),Replicate('=',30), "",2}) //EXCEL

	TSay():New( nTopSimul2, 2,{ || Replicate( "=" , 200 ) }, oDlgSimu2,, oFonteLbel,,,,.T., CLR_CYAN, CLR_WHITE, 300, 10 )
	nTopSimul2 += 10
EndIf

Return( Nil )

/*/{Protheus.doc} AddLRAposP
Adiciona os campos do Lucro Real ap�s a compensa��o de preju�zo
@author david.costa
@since 07/02/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receber� os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que ser� utilizada
@param cFormaTri1, character, Forma de tributa��o do Evento 1
@param lRural1, ${bool}, Informa se os campos � para a atividade Rural Evento 1
@param oDlgSimu2, objeto, Objeto que receber� os campos do Evento 2
@param cFormaTri2, character, Forma de tributa��o do Evento 2
@param lRural2, ${bool}, Informa se os campos � para a atividade Rural Evento 2
@return ${Nil}, ${Nulo}
@example
AddLRAposP( oDlgSimu, oFont, cFormaTri1, lRural1, oDlgSimu2, cFormaTri2, lRural2 )
/*/Static Function AddLRAposP( oDlgSimu, oFont, cFormaTri1, lRural1, oDlgSimu2, cFormaTri2, lRural2 )

Local oFonteOper	as object
Local nEspaco		as numeric

Default lRural1	:=	.F.
Default lRural2	:=	.F.

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

//Evento 1
If cFormaTri1 == TRIBUTACAO_LUCRO_REAL .or.; 
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
	
	If lRural1
		//"Lucro Real Ap�s Prej."
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nLRApPjRu1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0156, 1, oFont ) )		//"Lucro Real Ap�s Prej."
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		aAdd(_aExcRAApR,{STR0156,"nLRApPjRu1", "=", 1}) //EXCEL

		//"Lucro Real"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nLRealRur1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0113, 1, oFont ) )		//"Lucro Real"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		aAdd(_aExcRAApR,{STR0113,"nLRealRur1", "-", 1}) //EXCEL

		//"Prej. Ativ. Geral"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nPrejGera1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0158, 1, oFont ) )		//"Prej. Ativ. Geral"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		aAdd(_aExcRAApR,{STR0158,"nPrejGera1", "+", 1}) //EXCEL

		//"Prej. Comp. na Ativ. Geral"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nPrejRura1}, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0161, 1, oFont ) )		//"Prej. Comp. na Ativ. Geral"
		
		aAdd(_aExcRAApR,{STR0161,"nPrejRura1", "", 1}) //EXCEL

		nTopSimula += 25
	Else
		//"Lucro Real Ap�s Prej."
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nLRAposPj1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0156, 1, oFont ) )		//"Lucro Real Ap�s Prej."
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		aAdd(_aExcRAApo,{STR0156,"nLRAposPj1", "=", 1}) //EXCEL

		//"Lucro Real"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nLucroReal }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0113, 1, oFont ) )		//"Lucro Real"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		aAdd(_aExcRAApo,{STR0113,"nLucroReal", "-", 1}) //EXCEL

		//"Prej. Ativ. Rural"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nPrejRura1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0159, 1, oFont ) )		//"Prej. Ativ. Rural"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		aAdd(_aExcRAApo,{STR0159,"nPrejRura1", "+", 1}) //EXCEL

		//"Prej. Comp. na Ativ. Rural"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nPrejGera1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0160, 1, oFont ) )		//"Prej. Comp. na Ativ. Rural"
		
		aAdd(_aExcRAApo,{STR0160,"nPrejGera1", "", 1}) //EXCEL

		nTopSimula += 25
	EndIf
	
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_LUCRO_REAL .or.; 
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
	
	If lRural2
		//"Lucro Real Ap�s Prej."
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nLRApPjRu2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0156, 1, oFont ) )		//"Lucro Real Ap�s Prej."
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		aAdd(_aExcRAApR,{STR0156,"nLRApPjRu2", "=", 2}) //EXCEL

		//"Lucro Real"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nLRealRur2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0113, 1, oFont ) )		//"Lucro Real"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20

		aAdd(_aExcRAApR,{STR0113,"nLRealRur2", "-", 2}) //EXCEL
		
		//"Prej. Ativ. Geral"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nPrejGera2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0158, 1, oFont ) )		//"Prej. Ativ. Geral"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		aAdd(_aExcRAApR,{STR0158,"nPrejGera2", "+", 2}) //EXCEL

		//"Prej. Comp. na Ativ. Geral"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nPrejRura2}, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0161, 1, oFont ) )		//"Prej. Comp. na Ativ. Geral"
		
		aAdd(_aExcRAApR,{STR0161,"nPrejRura2", "", 2}) //EXCEL

		nTopSimul2 += 25
	Else
		//"Lucro Real Ap�s Prej."
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nLRAposPj2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0156, 1, oFont ) )		//"Lucro Real Ap�s Prej."
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		aAdd(_aExcRAApo,{STR0156,"nLRAposPj2", "=", 2}) //EXCEL

		//"Lucro Real"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nLucroRea2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0113, 1, oFont ) )		//"Lucro Real"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		aAdd(_aExcRAApo,{STR0113,"nLucroRea2", "-", 2}) //EXCEL

		//"Prej. Ativ. Rural"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nPrejRura2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0159, 1, oFont ) )		//"Prej. Ativ. Rural"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		aAdd(_aExcRAApo,{STR0159,"nPrejRura2", "+", 2}) //EXCEL

		//"Prej. Comp. na Ativ. Rural"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nPrejGera2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0160, 1, oFont ) )		//"Prej. Comp. na Ativ. Rural"
		
		aAdd(_aExcRAApo,{STR0160,"nPrejGera2", "", 2}) //EXCEL

		nTopSimul2 += 25
	EndIf
	
EndIf

Return( Nil )

/*/{Protheus.doc} AddBCParci
Adiciona os campos da Base de C�lculo Parcial
@author david.costa
@since 07/02/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receber� os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que ser� utilizada
@param cFormaTri1, character, Forma de tributa��o do Evento 1
@param lRural1, ${bool}, Informa se os campos � para a atividade Rural Evento 1
@param oDlgSimu2, objeto, Objeto que receber� os campos do Evento 2
@param cFormaTri2, character, Forma de tributa��o do Evento 2
@param lRural2, ${bool}, Informa se os campos � para a atividade Rural Evento 2
@return ${Nil}, ${Nulo}
@example
AddBCParci( oDlgSimu, oFont, cFormaTri1, lRural1, oDlgSimu2, cFormaTri2, lRural2 )
/*/Static Function AddBCParci( oDlgSimu, oFont, cFormaTri1, lRural1, oDlgSimu2, cFormaTri2, lRural2 )

Local oFonteOper	as object
Local nEspaco		as numeric

Default lRural1	:=	.F.
Default lRural2	:=	.F.

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_LUCRO_REAL .or.; 
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
	
	If lRural1
		//"Base C�lc. Parcial"
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nBCParRur1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0157, 1, oFont ) )		//"Base C�lc. Parcial"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.

		aAdd(_aExcBCPcR,{STR0157,"nBCParRur1", "=", 1}) //EXCEL
		
		//"Lucro Real Ap�s Prej."
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nLRApPjRu1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0156, 1, oFont ) )		//"Lucro Real Ap�s Prej."
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		aAdd(_aExcBCPcR,{STR0156,"nLRApPjRu1", "-", 1}) //EXCEL

		//"Compensa��o Preju�zo"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nCompPjRu1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0114, 1, oFont ) )			//"Compensa��o Preju�zo"
		
		aAdd(_aExcBCPcR,{STR0114,"nCompPjRu1", "", 1}) //EXCEL

		nTopSimula += 25
	Else
		//"Base C�lc. Parcial"
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nBCParcia1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0157, 1, oFont ) )		//"Base C�lc. Parcial"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		aAdd(_aExcBCPar,{STR0157,"nBCParcia1", "=", 1}) //EXCEL

		//Lucro Real Ap�s Prej.
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nLRAposPj1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0156, 1, oFont ) )		//"Lucro Real Ap�s Prej."
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		aAdd(_aExcBCPar,{STR0156,"nLRAposPj1", "-", 1}) //EXCEL

		//"Compensa��o Preju�zo"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nCompPreju }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0114, 1, oFont ) )			//"Compensa��o Preju�zo"
		
		aAdd(_aExcBCPar,{STR0114,"nCompPreju", "", 1}) //EXCEL

		nTopSimula += 25
	EndIf
	
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_LUCRO_REAL .or.; 
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
	
	If lRural2
		//"Base C�lc. Parcial"
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nBCParRur2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0157, 1, oFont ) )		//"Base C�lc. Parcial"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		aAdd(_aExcBCPcR,{STR0157,"nBCParRur2", "=", 2}) //EXCEL

		//"Lucro Real Ap�s Prej."
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nLRApPjRu2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0156, 1, oFont ) )		//"Lucro Real Ap�s Prej."
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		aAdd(_aExcBCPcR,{STR0156,"nLRApPjRu2", "-", 2}) //EXCEL

		//"Compensa��o Preju�zo"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nCompPjRu2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0114, 1, oFont ) )			//"Compensa��o Preju�zo"
		
		aAdd(_aExcBCPcR,{STR0114,"nCompPjRu2", "", 2}) //EXCEL

		nTopSimul2 += 25
	Else
		//"Base C�lc. Parcial"
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nBCParcia2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0157, 1, oFont ) )		//"Base C�lc. Parcial"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		aAdd(_aExcBCPar,{STR0157,"nBCParcia2", "=", 2}) //EXCEL

		//Lucro Real Ap�s Prej.
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nLRAposPj2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0156, 1, oFont ) )		//"Lucro Real Ap�s Prej."
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20

		aAdd(_aExcBCPar,{STR0156,"nLRAposPj2", "-", 2}) //EXCEL
		
		//"Compensa��o Preju�zo"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nCompPrej2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0114, 1, oFont ) )			//"Compensa��o Preju�zo"
		
		aAdd(_aExcBCPar,{STR0114,"nCompPrej2", "", 2}) //EXCEL
		
		nTopSimul2 += 25
	EndIf
	
EndIf

Return( Nil )

/*/{Protheus.doc} AddBaseCal
Adiciona os campos da Base de C�lculo
@author david.costa
@since 27/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receber� os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que ser� utilizada
@param cFormaTri1, character, Forma de tributa��o do Evento 1
@param lRural1, ${bool}, Informa se os campos � para a atividade Rural Evento 1
@param oDlgSimu2, objeto, Objeto que receber� os campos do Evento 2
@param cFormaTri2, character, Forma de tributa��o do Evento 2
@param lRural2, ${bool}, Informa se os campos � para a atividade Rural Evento 2
@return ${Nil}, ${Nulo}
@example
AddBaseCal( oPanel1, oFont, cFormaTri1, lRural1, oPanel2, cFormaTri2, lRural2 )
/*/Static Function AddBaseCal( oDlgSimu, oFont, cFormaTri1, lRural1, oDlgSimu2, cFormaTri2, lRural2 )

Local oFonteOper	as object
Local nEspaco		as numeric

Default lRural1	:=	.F.
Default lRural2	:=	.F.

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_ARBITRADO

	//"Base de C�lculo"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nBaseCalcu }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0110, 1, oFont ) )	//"Base de C�lculo"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	aAdd(_aExcBsCal,{STR0110,"nBaseCalcu", "=", 1}) //EXCEL

	If lRural1
		//"Base Atividade Geral"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nBCParcia1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0155, 1, oFont ) )		//"Base Atividade Geral"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		aAdd(_aExcBsCal,{STR0155,"nBCParcia1", "+", 1}) //EXCEL

		//"Base Atividade Rural"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nBCParRur1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0154, 1, oFont ) )		//"Base Atividade Rural"
		
		aAdd(_aExcBsCal,{STR0154,"nBCParRur1", "", 1}) //EXCEL

		nTopSimula += 25
	
	Else
		If cFormaTri1 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
			cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
			cFormaTri1 == TRIBUTACAO_LUCRO_ARBITRADO
			//"Lucro Estimado"
			aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nLucEstima }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0111, 1, oFont ) )		//"Lucro Estimado"
			nEspaco += 65
			TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
			nEspaco += 20
			
			aAdd(_aExcBsCal,{STR0111,"nLucEstima", "-", 1}) //EXCEL

			//"Exclus�es"
			aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrExclus }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0112, 1, oFont ) )		//"Exclus�es"
			
			aAdd(_aExcBsCal,{STR0112,"nVlrExclus", "", 1}) //EXCEL

			nTopSimula += 25
		
		ElseIf cFormaTri1 == TRIBUTACAO_LUCRO_REAL .or.;
			cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
	
			//"Lucro Real"
			aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nLucroReal }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0113, 1, oFont ) )		//"Lucro Real"
			nEspaco += 65
			TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
			nEspaco += 20
			
			aAdd(_aExcBsCal,{STR0113,"nLucroReal", "-", 1}) //EXCEL

			//"Compensa��o Preju�zo"
			aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nCompPreju }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0114, 1, oFont ) )			//"Compensa��o Preju�zo"
			
			aAdd(_aExcBsCal,{STR0114,"nCompPreju", "", 1}) //EXCEL

			nTopSimula += 25
		EndIf
	EndIf
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_ARBITRADO

	//"Base de C�lculo"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nBaseCalc2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0110, 1, oFont ) )	//"Base de C�lculo"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.

	aAdd(_aExcBsCal,{STR0110,"nBaseCalc2", "=", 2}) //EXCEL

	If lRural2
		//"Base Atividade Geral"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nBCParcia2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0155, 1, oFont ) )		//"Base Atividade Geral"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		aAdd(_aExcBsCal,{STR0155,"nBCParcia2", "+", 2}) //EXCEL

		//"Base Atividade Rural"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nBCParRur2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0154, 1, oFont ) )		//"Base Atividade Rural"
		
		aAdd(_aExcBsCal,{STR0154,"nBCParRur2", "", 2}) //EXCEL

		nTopSimul2 += 25
	
	Else
		If cFormaTri2 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
			cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
			cFormaTri2 == TRIBUTACAO_LUCRO_ARBITRADO
			//"Lucro Estimado"
			aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nLucEstim2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0111, 1, oFont ) )		//"Lucro Estimado"
			nEspaco += 65
			TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
			nEspaco += 20
			
			aAdd(_aExcBsCal,{STR0111,"nLucEstim2", "-", 2}) //EXCEL

			//"Exclus�es"
			aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrExclu2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0112, 1, oFont ) )		//"Exclus�es"
			
			aAdd(_aExcBsCal,{STR0112,"nVlrExclu2", "", 2}) //EXCEL

			nTopSimul2 += 25
		
		ElseIf cFormaTri2 == TRIBUTACAO_LUCRO_REAL .or.;
			cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
	
			//"Lucro Real"
			aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nLucroRea2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0113, 1, oFont ) )		//"Lucro Real"
			nEspaco += 65
			TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
			nEspaco += 20
			
			aAdd(_aExcBsCal,{STR0113,"nLucroRea2", "-", 2}) //EXCEL

			//"Compensa��o Preju�zo"
			aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nCompPrej2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0114, 1, oFont ) )			//"Compensa��o Preju�zo"
			
			aAdd(_aExcBsCal,{STR0114,"nCompPrej2", "", 2}) //EXCEL

			nTopSimul2 += 25
		EndIf
	EndIf
EndIf

Return( Nil )

/*/{Protheus.doc} AddLucEsti
Adiciona os campos do Lucro Estimado
@author david.costa
@since 27/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receber� os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que ser� utilizada
@param cFormaTri1, character, Forma de tributa��o do Evento 1
@param oDlgSimu2, objeto, Objeto que receber� os campos do Evento 2
@param cFormaTri2, character, Forma de tributa��o do Evento 2
@param lComparar, ${bool}, Informa se trata-se de uma simula��o
@return ${Nil}, ${Nulo}
@example
AddLucEsti( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2, lComparar )
/*/Static Function AddLucEsti( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2, lComparar )

Local oFonteOper	as object
Local nEspaco		as numeric

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Lucro Estimado"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nLucEstima }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0111, 1, oFont ) )		//"Lucro Estimado"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	aAdd(_aExcLcEst,{STR0111,"nLucEstima", "=", 1}) //EXCEL

	//"Receita Grupo 1"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nReceGrup1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0116, 1, oFont ) )		//"Receita Grupo 1"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcLcEst,{STR0116,"nReceGrup1", "+", 1}) //EXCEL

	//"Receita Grupo 2"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nReceGrup2 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0117, 1, oFont ) )		//"Receita Grupo 2"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcLcEst,{STR0117,"nReceGrup2", "+", 1}) //EXCEL

	//"Receita Grupo 3"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nReceGrup3 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0118, 1, oFont ) )		//"Receita Grupo 3"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20

	aAdd(_aExcLcEst,{STR0118,"nReceGrup3", "+", 1}) //EXCEL
	
	//"Receita Grupo 4"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nReceGrup4 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0119, 1, oFont ) )		//"Receita Grupo 4"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcLcEst,{STR0119,"nReceGrup4", "+", 1}) //EXCEL

	//"Demais Receitas"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nDemaisRec }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0120, 1, oFont ) )		//"Demais Receitas"
	
	aAdd(_aExcLcEst,{STR0120,"nDemaisRec", "", 1}) //EXCEL

	nTopSimula += 25
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Lucro Estimado"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nLucEstim2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0111, 1, oFont ) )		//"Lucro Estimado"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	aAdd(_aExcLcEst,{STR0111,"nLucEstim2", "=", 2}) //EXCEL
	
	//"Receita Grupo 1"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nReceGrp12 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0116, 1, oFont ) )		//"Receita Grupo 1"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcLcEst,{STR0116,"nReceGrp12", "+", 2}) //EXCEL

	//"Receita Grupo 2"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nReceGrp22 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0117, 1, oFont ) )		//"Receita Grupo 2"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcLcEst,{STR0117,"nReceGrp22", "+", 2}) //EXCEL

	//"Receita Grupo 3"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nReceGrp32 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0118, 1, oFont ) )		//"Receita Grupo 3"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcLcEst,{STR0118,"nReceGrp32", "+", 2}) //EXCEL

	//"Receita Grupo 4"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nReceGrp42 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0119, 1, oFont ) )		//"Receita Grupo 4"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcLcEst,{STR0119,"nReceGrp42", "+", 2}) //EXCEL

	//"Demais Receitas"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nDemaisRe2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0120, 1, oFont ) )		//"Demais Receitas"
	
	aAdd(_aExcLcEst,{STR0120,"nDemaisRe2", "", 2}) //EXCEL

	nTopSimul2 += 25
EndIf

Return( Nil )

/*/{Protheus.doc} AddRecAlq4
Adiciona os campos do Da Receita L�quida Al�quota 4
@author david.costa
@since 27/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receber� os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que ser� utilizada
@param cFormaTri1, character, Forma de tributa��o do Evento 1
@param oDlgSimu2, objeto, Objeto que receber� os campos do Evento 2
@param cFormaTri2, character, Forma de tributa��o do Evento 2
@param lComparar, ${bool}, Informa se trata-se de uma simula��o
@return ${Nil}, ${Nulo}
@example
AddRecAlq4( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2, lComparar )
/*/Static Function AddRecAlq4( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2, lComparar )

Local oFonteOper	as object
Local nEspaco		as numeric

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Receita Grupo 4"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nReceGrup4 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0119, 1, oFont ) )		//"Receita Grupo 4"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	aAdd(_aExcRAlq4,{STR0119,"nReceGrup4", "=", 1}) //EXCEL

	//"Receita Al�quota 4"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nReceAliq4 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0121, 1, oFont ) )		//"Receita Al�quota 4"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "x" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcRAlq4,{STR0121,"nReceAliq4", "X", 1}) //EXCEL

	//"% Estimado Al�quota 4"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nAliqGrup4 }, oDlgSimu, 50, 10, "@E 999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0122, 1, oFont ) )			//"% Estimado Al�quota 4"
	
	aAdd(_aExcRAlq4,{STR0122,"nAliqGrup4", "", 1}) //EXCEL

	nTopSimula += 25
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Receita Grupo 4"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nReceGrp42 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0119, 1, oFont ) )		//"Receita Grupo 4"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	aAdd(_aExcRAlq4,{STR0119,"nReceGrp42", "=", 2}) //EXCEL

	//"Receita Al�quota 4"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nReceAlq42 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0121, 1, oFont ) )		//"Receita Al�quota 4"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "x" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcRAlq4,{STR0121,"nReceAlq42", "X", 2}) //EXCEL

	//"% Estimado Al�quota 4"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nAliqGrp42 }, oDlgSimu2, 50, 10, "@E 999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0122, 1, oFont ) )			//"% Estimado Al�quota 4"
	
	aAdd(_aExcRAlq4,{STR0122,"nAliqGrp42", "", 2}) //EXCEL

	nTopSimul2 += 25
EndIf

Return( Nil )

/*/{Protheus.doc} AddRecAlq3
Adiciona os campos do Da Receita L�quida Al�quota 3
@author david.costa
@since 27/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receber� os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que ser� utilizada
@param cFormaTri1, character, Forma de tributa��o do Evento 1
@param oDlgSimu2, objeto, Objeto que receber� os campos do Evento 2
@param cFormaTri2, character, Forma de tributa��o do Evento 2
@param lComparar, ${bool}, Informa se trata-se de uma simula��o
@return ${Nil}, ${Nulo}
@example
AddRecAlq3( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2, lComparar )
/*/Static Function AddRecAlq3( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2, lComparar )

Local oFonteOper	as object
Local nEspaco		as numeric

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Receita Grupo 3"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nReceGrup3 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0118, 1, oFont ) )			//"Receita Grupo 3"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.

	aAdd(_aExcRAlq3,{STR0118,"nReceGrup3", "=", 1}) //EXCEL

	//"Receita Al�quota 3"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nReceAliq3 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0124, 1, oFont ) )			//"Receita Al�quota 3"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "x" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcRAlq3,{STR0124,"nReceAliq3", "X", 1}) //EXCEL

	//"% Estimado Al�quota 3"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nAliqGrup3 }, oDlgSimu, 50, 10, "@E 999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0125, 1, oFont ) )			//"% Estimado Al�quota 3"
	
	aAdd(_aExcRAlq3,{STR0125,"nAliqGrup3", "", 1}) //EXCEL

	nTopSimula += 25
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Receita Grupo 3"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nReceGrp32 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0118, 1, oFont ) )			//"Receita Grupo 3"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	aAdd(_aExcRAlq3,{STR0118,"nReceGrp32", "=", 2}) //EXCEL

	//"Receita Al�quota 3"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nReceAlq32 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0124, 1, oFont ) )			//"Receita Al�quota 3"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "x" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcRAlq3,{STR0124,"nReceAlq32", "X", 2}) //EXCEL

	//"% Estimado Al�quota 3"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nAliqGrp32 }, oDlgSimu2, 50, 10, "@E 999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0125, 1, oFont ) )			//"% Estimado Al�quota 3"
	
	aAdd(_aExcRAlq3,{STR0125,"nAliqGrp32", "", 2}) //EXCEL

	nTopSimul2 += 25
EndIf

Return( Nil )

/*/{Protheus.doc} AddRecAlq2
Adiciona os campos do Da Receita L�quida Al�quota 2
@author david.costa
@since 27/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receber� os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que ser� utilizada
@param cFormaTri1, character, Forma de tributa��o do Evento 1
@param oDlgSimu2, objeto, Objeto que receber� os campos do Evento 2
@param cFormaTri2, character, Forma de tributa��o do Evento 2
@param lComparar, ${bool}, Informa se trata-se de uma simula��o
@return ${Nil}, ${Nulo}
@example
AddRecAlq2( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2, lComparar )
/*/Static Function AddRecAlq2( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2, lComparar )

Local oFonteOper	as object
Local nEspaco		as numeric

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Receita Grupo 2"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nReceGrup2 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0117, 1, oFont ) )			//"Receita Grupo 2"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.

	aAdd(_aExcRAlq2,{STR0117,"nReceGrup2", "=", 1}) //EXCEL

	//"Receita Al�quota 2"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nReceAliq2 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0123, 1, oFont ) )			//"Receita Al�quota 2"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "x" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcRAlq2,{STR0123,"nReceAliq2", "X", 1}) //EXCEL

	//"% Estimado Al�quota 2"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nAliqGrup2 }, oDlgSimu, 50, 10, "@E 999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0126, 1, oFont ) )				//"% Estimado Al�quota 2"
	
	aAdd(_aExcRAlq2,{STR0126,"nAliqGrup2", "", 1}) //EXCEL

	nTopSimula += 25
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Receita Grupo 2"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nReceGrp22 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0117, 1, oFont ) )			//"Receita Grupo 2"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	aAdd(_aExcRAlq2,{STR0117,"nReceGrp22", "=", 2}) //EXCEL

	//"Receita Al�quota 2"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nReceAlq22 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0123, 1, oFont ) )			//"Receita Al�quota 2"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "x" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcRAlq2,{STR0123,"nReceAlq22", "X", 2}) //EXCEL

	//"% Estimado Al�quota 2"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nAliqGrp22 }, oDlgSimu2, 50, 10, "@E 999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0126, 1, oFont ) )				//"% Estimado Al�quota 2"
	
	aAdd(_aExcRAlq2,{STR0126,"nAliqGrp22", "", 2}) //EXCEL

	nTopSimul2 += 25
EndIf

Return( Nil )

/*/{Protheus.doc} AddRecAlq1
Adiciona os campos do Da Receita L�quida Al�quota 1
@author david.costa
@since 27/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receber� os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que ser� utilizada
@param cFormaTri1, character, Forma de tributa��o do Evento 1
@param oDlgSimu2, objeto, Objeto que receber� os campos do Evento 2
@param cFormaTri2, character, Forma de tributa��o do Evento 2
@return ${Nil}, ${Nulo}
@example
AddRecAlq1( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2, lComparar )
/*/Static Function AddRecAlq1( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2 )

Local oFonteOper	as object
Local nEspaco		as numeric

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Receita Grupo 1"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nReceGrup1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0116, 1, oFont ) )			//"Receita Grupo 1"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.

	aAdd(_aExcRAlq1,{STR0116,"nReceGrup1", "=", 1}) //EXCEL
	
	//"Receita Al�quota 1"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nReceAliq1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0127, 1, oFont ) )			//"Receita Al�quota 1"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "x" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcRAlq1,{STR0127,"nReceAliq1", "X", 1}) //EXCEL
	
	//"% Estimado Al�quota 1"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nAliqGrup1 }, oDlgSimu, 50, 10, "@E 999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0128, 1, oFont ) )			//"% Estimado Al�quota 1"
	
	aAdd(_aExcRAlq1,{STR0128,"nAliqGrup1", "", 1}) //EXCEL

	nTopSimula += 25
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Receita Grupo 1"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nReceGrp12 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0116, 1, oFont ) )			//"Receita Grupo 1"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.

	aAdd(_aExcRAlq1,{STR0116,"nReceGrp12", "=", 2}) //EXCEL
	
	//"Receita Al�quota 1"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nReceAlq12 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0127, 1, oFont ) )			//"Receita Al�quota 1"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "x" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcRAlq1,{STR0127,"nReceAlq12", "X", 2}) //EXCEL

	//"% Estimado Al�quota 1"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nAliqGrp12 }, oDlgSimu2, 50, 10, "@E 999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0128, 1, oFont ) )			//"% Estimado Al�quota 1"
	
	aAdd(_aExcRAlq1,{STR0128,"nAliqGrp12", "", 2}) //EXCEL

	nTopSimul2 += 25
EndIf
		
Return( Nil )

/*/{Protheus.doc} AddDevedor
Adiciona os campos do Slado Devedor
@author david.costa
@since 27/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receber� os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que ser� utilizada
@param cFormaTri1, character, Forma de tributa��o do Evento 1
@param cTributo, character, C�digo do Tributo da Apura��o
@param oDlgSimu2, objeto, Objeto que receber� os campos do Evento 2
@param cFormaTri2, character, Forma de tributa��o do Evento 2
@return ${Nil}, ${Nulo}
@example
AddDevedor( oDlgSimu, oFont, cFormaTri1, cTributo, oDlgSimu2, cFormaTri2 )
/*/Static Function AddDevedor( oDlgSimu, oFont, cFormaTri1, cTributo, oDlgSimu2, cFormaTri2 )

Local oFonteOper	as object
Local nEspaco		as numeric

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_IMUNE .or.;
	cFormaTri1 == TRIBUTACAO_ISENTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL .or.;	
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Saldo Devedor"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nSaldoDeve }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0129, 1, oFont ) )		//"Saldo Devedor"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	aAdd(_aExcAdDev,{STR0129,"nSaldoDeve", "=", 1}) //EXCEL

	If cFormaTri1 != TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .and. cFormaTri1 != TRIBUTACAO_LUCRO_REAL
		If cTributo == TRIBUTO_IRPJ
			//"Provis�o IRPJ"
			aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrPrIRPJ }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0130, 1, oFont ) )			//"Provis�o IRPJ"
			nEspaco += 65
			TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
			nEspaco += 20

			aAdd(_aExcAdDev,{STR0130,"nVlrPrIRPJ", "-", 1}) //EXCEL

		Else
			//"Valor Imposto"
			aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrImpost }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0131, 1, oFont ) )			//"Valor Imposto"
			nEspaco += 65
			TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
			nEspaco += 20

			aAdd(_aExcAdDev,{STR0131,"nVlrImpost", "-", 1}) //EXCEL
		EndIf
		
		//"Dedu��es"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrDeduco }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0132, 1, oFont ) )		//"Dedu��es"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20

		aAdd(_aExcAdDev,{STR0132,"nVlrDeduco", "-", 1}) //EXCEL
	Else
		//"Imposto Devido no M�s"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nImpDevMes }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0133, 1, oFont ) )		//"Imposto Devido no M�s"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20

		aAdd(_aExcAdDev,{STR0133,"nImpDevMes", "-", 1}) //EXCEL
	EndIf
	
	//"Compensa��es"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrCompen }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0134, 1, oFont ) )		//"Compensa��es"
	
	aAdd(_aExcAdDev,{STR0134,"nVlrCompen", "", 1}) //EXCEL

	If cTributo == TRIBUTO_CSLL .and. cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20

		_aExcAdDev[Len(_aExcAdDev)][3] := "+"

		//"Adicionais do Tributo"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nAdicTribu }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0135, 1, oFont ) )		//"Adicionais do Tributo"

		aAdd(_aExcAdDev,{STR0135,"nAdicTribu", "", 1}) //EXCEL
	EndIf
	
	nTopSimula += 25
	
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_IMUNE .or.;
	cFormaTri2 == TRIBUTACAO_ISENTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL .or.;	
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Saldo Devedor"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nSaldoDev2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0129, 1, oFont ) )		//"Saldo Devedor"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.

	aAdd(_aExcAdDev,{STR0129,"nSaldoDev2", "=", 2}) //EXCEL
	
	If cFormaTri1 != TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .and. cFormaTri2 != TRIBUTACAO_LUCRO_REAL
		If cTributo == TRIBUTO_IRPJ
			//"Provis�o IRPJ"
			aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrPrIRP2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0130, 1, oFont ) )			//"Provis�o IRPJ"
			nEspaco += 65
			TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
			nEspaco += 20

			aAdd(_aExcAdDev,{STR0130,"nVlrPrIRP2", "-", 2}) //EXCEL

		Else
			//"Valor Imposto"
			aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrImpos2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0131, 1, oFont ) )			//"Valor Imposto"
			nEspaco += 65
			TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
			nEspaco += 20

			aAdd(_aExcAdDev,{STR0131,"nVlrImpos2", "-", 2}) //EXCEL
		EndIf
		
		//"Dedu��es"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrDeduc2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0132, 1, oFont ) )		//"Dedu��es"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20

		aAdd(_aExcAdDev,{STR0132,"nVlrDeduc2", "-", 2}) //EXCEL
	Else
		//"Imposto Devido no M�s"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nImpDevMe2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0133, 1, oFont ) )		//"Imposto Devido no M�s"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20

		aAdd(_aExcAdDev,{STR0133,"nImpDevMe2", "-", 2}) //EXCEL
	EndIf
	
	//"Compensa��es"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrCompe2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0134, 1, oFont ) )		//"Compensa��es"
	
	aAdd(_aExcAdDev,{STR0134,"nVlrCompe2", "-", 2}) //EXCEL

	If cTributo == TRIBUTO_CSLL .and. cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20

		_aExcAdDev[Len(_aExcAdDev)][3] := "+"  // EXCEL

		//"Adicionais do Tributo"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nAdicTrib2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0135, 1, oFont ) )		//"Adicionais do Tributo"

		aAdd(_aExcAdDev,{STR0135,"nAdicTrib2", "", 2}) //EXCEL
	EndIf
	
	nTopSimul2 += 25
	
EndIf

Return( Nil )

/*/{Protheus.doc} AddProIRPJ
Adiciona os campos da Provis�o de IRPJ
@author david.costa
@since 27/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receber� os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que ser� utilizada
@param cFormaTri1, character, Forma de tributa��o do Evento 1
@param oDlgSimu2, objeto, Objeto que receber� os campos do Evento 2
@param cFormaTri2, character, Forma de tributa��o do Evento 2
@return ${Nil}, ${Nulo}
@example
AddProIRPJ( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2 )
/*/Static Function AddProIRPJ( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2 )

Local oFonteOper	as object
Local nEspaco		as numeric

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_IMUNE .or.;
	cFormaTri1 == TRIBUTACAO_ISENTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Provis�o IRPJ"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrPrIRPJ }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0130, 1, oFont ) )		//"Provis�o IRPJ"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	aAdd(_aExcProIR,{STR0130,"nVlrPrIRPJ", "=", 1}) //EXCEL

	//"Valor Imposto"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrImpost }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0131, 1, oFont ) )		//"Valor Imposto"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcProIR,{STR0131,"nVlrImpost", "+", 1}) //EXCEL

	//"Valor Adicional"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrAdicio }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0136, 1, oFont ) )		//"Valor Adicional"
	
	aAdd(_aExcProIR,{STR0136,"nVlrAdicio", "", 1}) //EXCEL

	nTopSimula += 25
	
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_IMUNE .or.;
	cFormaTri2 == TRIBUTACAO_ISENTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Provis�o IRPJ"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrPrIRP2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0130, 1, oFont ) )		//"Provis�o IRPJ"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	aAdd(_aExcProIR,{STR0130,"nVlrPrIRP2", "=", 2}) //EXCEL

	//"Valor Imposto"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrImpos2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0131, 1, oFont ) )		//"Valor Imposto"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcProIR,{STR0131,"nVlrImpos2", "+", 2}) //EXCEL

	//"Valor Adicional"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrAdici2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0136, 1, oFont ) )		//"Valor Adicional"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcProIR,{STR0136,"nVlrAdici2", "+", 2}) //EXCEL

	//"Adicionais do Tributo"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nAdicTrib2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0135, 1, oFont ) )		//"Adicionais do Tributo"
	
	aAdd(_aExcProIR,{STR0135,"nAdicTrib2", "", 2}) //EXCEL

	nTopSimul2 += 25
	
EndIf

Return( Nil )

/*/{Protheus.doc} AddVlrAdic
Adiciona os campos do valor de adicional do tributo
@author david.costa
@since 30/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receber� os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que ser� utilizada
@param cFormaTri1, character, Forma de tributa��o do Evento 1
@param oDlgSimu2, objeto, Objeto que receber� os campos do Evento 2
@param cFormaTri2, character, Forma de tributa��o do Evento 2
@return ${Nil}, ${Nulo}
@example
AddVlrAdic( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2, lComparar )
/*/Static Function AddVlrAdic( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2 )

Local oFonteOper	as object
Local nEspaco		as numeric

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_IMUNE .or.;
	cFormaTri1 == TRIBUTACAO_ISENTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Valor Adicional"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrAdicio }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0149, 1, oFont ) )		//"Valor Adicional"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "=(" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.

	aAdd(_aExcVrAdi,{STR0149,"nVlrAdicio", "=(", 1}) //EXCEL
	
	//"Base de C�lculo"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nBaseCalcu }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0110, 1, oFont ) )		//"Base de C�lculo"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcVrAdi,{STR0110,"nBaseCalcu", "-", 1}) //EXCEL

	//"Valor Isento"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrIsento }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0147, 1, oFont ) )		//"Valor Isento"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || ")x" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20

	aAdd(_aExcVrAdi,{STR0147,"nVlrIsento", ")X", 1}) //EXCEL
	
	//"Al�quota Adicional"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nAliqAdici }, oDlgSimu, 50, 10, "@E 999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0148, 1, oFont ) )		//"Al�quota Adicional"
	
	aAdd(_aExcVrAdi,{STR0148,"nAliqAdici", "", 1}) //EXCEL

	nTopSimula += 25
	
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_IMUNE .or.;
	cFormaTri2 == TRIBUTACAO_ISENTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Valor Adicional"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrAdici2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0149, 1, oFont ) )		//"Valor Adicional"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "=(" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	aAdd(_aExcVrAdi,{STR0149,"nVlrAdici2", "=(", 2}) //EXCEL

	//"Base de C�lculo"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nBaseCalc2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0110, 1, oFont ) )		//"Base de C�lculo"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcVrAdi,{STR0110,"nBaseCalc2", "-", 2}) //EXCEL

	//"Valor Isento"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrIsent2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0147, 1, oFont ) )		//"Valor Isento"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || ")x" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcVrAdi,{STR0147,"nVlrIsent2", ")X", 2}) //EXCEL

	//"Al�quota Adicional"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nAliqAdic2 }, oDlgSimu2, 50, 10, "@E 999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0148, 1, oFont ) )		//"Al�quota Adicional"
	
	aAdd(_aExcVrAdi,{STR0148,"nAliqAdic2", "", 2}) //EXCEL

	nTopSimul2 += 25
	
EndIf

Return( Nil )

/*/{Protheus.doc} AddVlrIsen
Adiciona os campos do valor de isentos
@author david.costa
@since 30/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receber� os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que ser� utilizada
@param cFormaTri1, character, Forma de tributa��o do Evento 1
@param oDlgSimu2, objeto, Objeto que receber� os campos do Evento 2
@param cFormaTri2, character, Forma de tributa��o do Evento 2
@return ${Nil}, ${Nulo}
@example
AddVlrIsen( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2, lComparar )
/*/Static Function AddVlrIsen( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2 )

Local oFonteOper	as object
Local nEspaco		as numeric

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_IMUNE .or.;
	cFormaTri1 == TRIBUTACAO_ISENTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Valor Isento"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrIsento }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0147, 1, oFont ) )		//"Valor Isento"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	aAdd(_aExcVrIse,{STR0147,"nVlrIsento", "=", 1}) //EXCEL

	//"Valor Parcela Isenta"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nParcIsent }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0146, 1, oFont ) )		//"Valor Parcela Isenta"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "x" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcVrIse,{STR0146,"nParcIsent", "X", 1}) //EXCEL

	//"N�mero de meses"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nNMesesIse }, oDlgSimu, 50, 10, "@E 99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0145, 1, oFont ) )		//"N�mero de meses"
	
	aAdd(_aExcVrIse,{STR0145,"nNMesesIse", "", 1}) //EXCEL

	nTopSimula += 25
	
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_IMUNE .or.;
	cFormaTri2 == TRIBUTACAO_ISENTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Valor Isento"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrIsent2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0147, 1, oFont ) )		//"Valor Isento"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	aAdd(_aExcVrIse,{STR0147,"nVlrIsent2", "=", 2}) //EXCEL

	//"Valor Parcela Isenta"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nParcIsen2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0146, 1, oFont ) )		//"Valor Parcela Isenta"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "x" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcVrIse,{STR0146,"nParcIsen2", "X", 2}) //EXCEL

	//"N�mero de meses"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nNMesesIs2 }, oDlgSimu2, 50, 10, "@E 99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0145, 1, oFont ) )		//"N�mero de meses"
	
	aAdd(_aExcVrIse,{STR0145,"nNMesesIs2", "", 2}) //EXCEL

	nTopSimul2 += 25
	
EndIf

Return( Nil )

/*/{Protheus.doc} AddVlrImpo
Adiciona os campos do valor do imposto
@author david.costa
@since 30/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receber� os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que ser� utilizada
@param cFormaTri1, character, Forma de tributa��o do Evento 1
@param oDlgSimu2, objeto, Objeto que receber� os campos do Evento 2
@param cFormaTri2, character, Forma de tributa��o do Evento 2
@return ${Nil}, ${Nulo}
@example
AddVlrImpo( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2 )
/*/Static Function AddVlrImpo( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2 )

Local oFonteOper	as object
Local nEspaco		as numeric

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_IMUNE .or.;
	cFormaTri1 == TRIBUTACAO_ISENTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//Valor Imposto
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrImpost }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0131, 1, oFont ) )		//"Valor Imposto"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	aAdd(_aExcVrImp,{STR0131,"nVlrImpost", "=", 1}) //EXCEL

	//"Base de C�lculo"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nBaseCalcu }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0110, 1, oFont ) )		//"Base de C�lculo"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "x" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcVrImp,{STR0110,"nBaseCalcu", "X", 1}) //EXCEL

	//"Al�quota"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nAliqImpos }, oDlgSimu, 50, 10, "@E 999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0144, 1, oFont ) )		//"Al�quota"
	
	aAdd(_aExcVrImp,{STR0144,"nAliqImpos", "", 1}) //EXCEL

	nTopSimula += 25
	
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_IMUNE .or.;
	cFormaTri2 == TRIBUTACAO_ISENTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//Valor Imposto
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrImpos2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0131, 1, oFont ) )		//"Valor Imposto"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	aAdd(_aExcVrImp,{STR0131,"nVlrImpos2", "=", 2}) //EXCEL

	//"Base de C�lculo"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nBaseCalc2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0110, 1, oFont ) )		//"Base de C�lculo"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "x" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcVrImp,{STR0110,"nBaseCalc2", "X", 2}) //EXCEL

	//"Al�quota"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nAliqImpo2 }, oDlgSimu2, 50, 10, "@E 999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0144, 1, oFont ) )		//"Al�quota"
	
	aAdd(_aExcVrImp,{STR0144,"nAliqImpo2", "", 2}) //EXCEL

	nTopSimul2 += 25
	
EndIf

Return( Nil )

/*/{Protheus.doc} AddResCont
Adiciona os campos do Resultado Cont�bil
@author david.costa
@since 30/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receber� os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que ser� utilizada
@param cFormaTri1, character, Forma de tributa��o do Evento 1
@param lRural1, ${bool}, Informa se os campos � para a atividade Rural Evento 1
@param oDlgSimu2, objeto, Objeto que receber� os campos do Evento 2
@param cFormaTri2, character, Forma de tributa��o do Evento 2
@param lRural2, ${bool}, Informa se os campos � para a atividade Rural Evento 2
@return ${Nil}, ${Nulo}
@example
AddResCont( oDlgSimu, oFont, cFormaTri1, .F., oDlgSimu2, cFormaTri2, .T. )
/*/Static Function AddResCont( oDlgSimu, oFont, cFormaTri1, lRural1, oDlgSimu2, cFormaTri2, lRural2 )

Local oFonteOper	as object
Local nEspaco		as numeric

Default lRural1	:=	.F.
Default lRural2	:=	.F.

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
	
	If lRural1
		//"Resultado Cont�bil"
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nResCtbRu1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0141, 1, oFont ) )		//"Resultado Cont�bil"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		aAdd(_aExcRsCtR,{STR0141,"nResCtbRu1", "=", 1}) //EXCEL

		//"Resultado Operacional"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nResOpRur1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0143, 1, oFont ) )		//"Resultado Operacional"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20

		aAdd(_aExcRsCtR,{STR0143,"nResOpRur1", "+", 1}) //EXCEL

		//"Resultado N�o Operacional"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nResNOpRu1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0142, 1, oFont ) )		//"Resultado N�o Operacional"
		
		aAdd(_aExcRsCtR,{STR0142,"nResNOpRu1", "", 1}) //EXCEL
		nTopSimula += 25
	Else
		//"Resultado Cont�bil"
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nResulCont }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0141, 1, oFont ) )		//"Resultado Cont�bil"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		aAdd(_aExcRsCnt,{STR0141,"nResulCont", "=", 1}) //EXCEL

		//"Resultado Operacional"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nResulOper }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0143, 1, oFont ) )		//"Resultado Operacional"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		aAdd(_aExcRsCnt,{STR0143,"nResulOper", "+", 1}) //EXCEL

		//"Resultado N�o Operacional"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nResulNOpe }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0142, 1, oFont ) )		//"Resultado N�o Operacional"
		aAdd(_aExcRsCnt,{STR0142,"nResulNOpe", "", 1}) //EXCEL
		nTopSimula += 25
	EndIf
	
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
	
	If lRural2
		//"Resultado Cont�bil"
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nResCtbRu2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0141, 1, oFont ) )		//"Resultado Cont�bil"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		aAdd(_aExcRsCtR,{STR0141,"nResCtbRu2", "=", 2}) //EXCEL

		//"Resultado Operacional"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nResOpRur2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0143, 1, oFont ) )		//"Resultado Operacional"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		aAdd(_aExcRsCtR,{STR0143,"nResOpRur2", "+", 2}) //EXCEL
		
		//"Resultado N�o Operacional"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nResNOpRu2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0142, 1, oFont ) )		//"Resultado N�o Operacional"
		
		aAdd(_aExcRsCtR,{STR0142,"nResNOpRu2", "", 2}) //EXCEL
		nTopSimul2 += 25
	Else
		//"Resultado Cont�bil"
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nResulCon2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0141, 1, oFont ) )		//"Resultado Cont�bil"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		aAdd(_aExcRsCnt,{STR0141,"nResulCon2", "=", 2}) //EXCEL

		//"Resultado Operacional"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nResulOpe2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0143, 1, oFont ) )		//"Resultado Operacional"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20

		aAdd(_aExcRsCnt,{STR0143,"nResulOpe2", "+", 2}) //EXCEL
		
		//"Resultado N�o Operacional"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nResulNOp2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0142, 1, oFont ) )		//"Resultado N�o Operacional"
		aAdd(_aExcRsCnt,{STR0142,"nResulNOp2", "", 2}) //EXCEL
		nTopSimul2 += 25
	
	EndIf
	
EndIf

Return( Nil )

/*/{Protheus.doc} AddLucReal
Adiciona os campos do Lucro Real
@author david.costa
@since 30/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receber� os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que ser� utilizada
@param cFormaTri1, character, Forma de tributa��o do Evento 1
@param lRural1, ${bool}, Informa se os campos � para a atividade Rural Evento 1
@param oDlgSimu2, objeto, Objeto que receber� os campos do Evento 2
@param cFormaTri2, character, Forma de tributa��o do Evento 2
@param lRural2, ${bool}, Informa se os campos � para a atividade Rural Evento 2
@return ${Nil}, ${Nulo}
@example
AddLucReal( oDlgSimu, oFont, cFormaTri1, .F., oDlgSimu2, cFormaTri2, .T. )
/*/Static Function AddLucReal( oDlgSimu, oFont, cFormaTri1, lRural1, oDlgSimu2, cFormaTri2, lRural2 )

Local oFonteOper	as object
Local nEspaco		as numeric

Default lRural1	:=	.F.
Default lRural2	:=	.F.

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_LUCRO_REAL .or.; 
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
	
	If  lRural1
		//"Lucro Real"
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nLRealRur1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0113, 1, oFont ) )		//"Lucro Real"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.

		aAdd(_aExcLcReR,{STR0113,"nLRealRur1", "=", 1}) //EXCEL
		
		//"Resultado Cont�bil"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nResCtbRu1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0141, 1, oFont ) )		//"Resultado Cont�bil"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		aAdd(_aExcLcReR,{STR0141,"nResCtbRu1", "+", 1}) //EXCEL

		//"Adi��es"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrAdRur1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0140, 1, oFont ) )		//"Adi��es"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		aAdd(_aExcLcReR,{STR0140,"nVlrAdRur1", "-", 1}) //EXCEL

		//"Exclus�es"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrExRur1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0112, 1, oFont ) )		//"Exclus�es"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		aAdd(_aExcLcReR,{STR0112,"nVlrExRur1", "+", 1}) //EXCEL

		//"Adi��es por Doa��o"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrDoaRu1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0139, 1, oFont ) )		//"Adi��es por Doa��o"
		
		aAdd(_aExcLcReR,{STR0139,"nVlrDoaRu1", "", 1}) //EXCEL

		nTopSimula += 25
	Else
		//"Lucro Real"
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nLucroReal }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0113, 1, oFont ) )		//"Lucro Real"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		aAdd(_aExcLcRea,{STR0113,"nLucroReal", "=", 1}) //EXCEL

		//"Resultado Cont�bil"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nResulCont }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0141, 1, oFont ) )		//"Resultado Cont�bil"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		aAdd(_aExcLcRea,{STR0141,"nResulCont", "+", 1}) //EXCEL

		//"Adi��es"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrAdicoe }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0140, 1, oFont ) )		//"Adi��es"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		aAdd(_aExcLcRea,{STR0140,"nVlrAdicoe", "-", 1}) //EXCEL

		//"Exclus�es"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrExclus }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0112, 1, oFont ) )		//"Exclus�es"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		aAdd(_aExcLcRea,{STR0112,"nVlrExclus", "+", 1}) //EXCEL

		//"Adi��es por Doa��o"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrDoacoe }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0139, 1, oFont ) )		//"Adi��es por Doa��o"
		
		aAdd(_aExcLcRea,{STR0139,"nVlrDoacoe", "", 1}) //EXCEL

		nTopSimula += 25
	EndIf
	
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_LUCRO_REAL .or.; 
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
	
	If lRural2
		//"Lucro Real"
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nLRealRur2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0113, 1, oFont ) )		//"Lucro Real"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.

		aAdd(_aExcLcReR,{STR0113,"nLRealRur2", "=", 2}) //EXCEL

		//"Resultado Cont�bil"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nResCtbRu2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0141, 1, oFont ) )		//"Resultado Cont�bil"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		aAdd(_aExcLcReR,{STR0141,"nResCtbRu2", "+", 2}) //EXCEL

		//"Adi��es"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrAdRur2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0140, 1, oFont ) )		//"Adi��es"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		aAdd(_aExcLcReR,{STR0140,"nVlrAdRur2", "-", 2}) //EXCEL

		//"Exclus�es"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrExRur2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0112, 1, oFont ) )		//"Exclus�es"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		aAdd(_aExcLcReR,{STR0112,"nVlrExRur2", "+", 2}) //EXCEL

		//"Adi��es por Doa��o"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrDoaRu2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0139, 1, oFont ) )		//"Adi��es por Doa��o"
		
		aAdd(_aExcLcReR,{STR0139,"nVlrDoaRu2", "" ,2 }) //EXCEL

		nTopSimul2 += 25
	Else
		//"Lucro Real"
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nLucroRea2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0113, 1, oFont ) )		//"Lucro Real"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		aAdd(_aExcLcRea,{STR0113,"nLucroRea2", "=", 2}) //EXCEL

		//"Resultado Cont�bil"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nResulCon2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0141, 1, oFont ) )		//"Resultado Cont�bil"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		aAdd(_aExcLcRea,{STR0141,"nResulCon2", "+", 2}) //EXCEL

		//"Adi��es"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrAdico2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0140, 1, oFont ) )		//"Adi��es"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		aAdd(_aExcLcRea,{STR0140,"nVlrAdico2", "-", 2}) //EXCEL

		//"Exclus�es"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrExclu2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0112, 1, oFont ) )		//"Exclus�es"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		aAdd(_aExcLcRea,{STR0112,"nVlrExclu2", "+", 2}) //EXCEL

		//"Adi��es por Doa��o"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrDoaco2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0139, 1, oFont ) )		//"Adi��es por Doa��o"
		
		aAdd(_aExcLcRea,{STR0139,"nVlrDoaco2", "", 2}) //EXCEL
		nTopSimul2 += 25
	EndIf
EndIf

Return( Nil )

/*/{Protheus.doc} AddDeviMes
Adiciona os campos do c�lculo do imposto devido no m�s
@author david.costa
@since 30/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receber� os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que ser� utilizada
@param cFormaTri1, character, Forma de tributa��o do Evento 1
@param cTributo, character, Tipo do tributo
@param oDlgSimu2, objeto, Objeto que receber� os campos do Evento 2
@param cFormaTri2, character, Forma de tributa��o do Evento 2
@return ${Nil}, ${Nulo}
@example
AddDeviMes( oDlgSimu, oFont, cFormaTri1, cTributo, oDlgSimu2, cFormaTri2 )
/*/Static Function AddDeviMes( oDlgSimu, oFont, cFormaTri1, cTributo, oDlgSimu2, cFormaTri2 )

Local oFonteOper	as object
Local nEspaco		as numeric

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
	
	//"Imposto Devido no M�s"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nImpDevMes }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0133, 1, oFont ) )		//"Imposto Devido no M�s"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.

	aAdd(_aExcDvMes,{STR0133,"nImpDevMes", "=", 1}) //EXCEL

	If cTributo == TRIBUTO_IRPJ
		//"Provis�o IRPJ"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrPrIRPJ }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0130, 1, oFont ) )		//"Provis�o IRPJ"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20

		aAdd(_aExcDvMes,{STR0130,"nVlrPrIRPJ", "+", 1}) //EXCEL

	Else
		//"Valor Imposto"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrImpost }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0131, 1, oFont ) )		//"Valor Imposto"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20

		aAdd(_aExcDvMes,{STR0131,"nVlrImpost", "+", 1}) //EXCEL

	EndIf
		
	//"Adicionais do Tributo"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nAdicTribu }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0135, 1, oFont ) )		//"Adicionais do Tributo"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcDvMes,{STR0135,"nAdicTribu", "-", 1}) //EXCEL

	//"Dedu��es"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrDeduco }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0132, 1, oFont ) )		//"Dedu��es"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20

	aAdd(_aExcDvMes,{STR0132,"nVlrDeduco", "-", 1}) //EXCEL
	
	//"Imp. devido meses ant."
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nDeviAnter }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0138, 1, oFont ) )			//"Imp. devido meses ant."
	
	aAdd(_aExcDvMes,{STR0138,"nDeviAnter", "", 1}) //EXCEL

	nTopSimula += 25
	
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
	
	//"Imposto Devido no M�s"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nImpDevMe2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0133, 1, oFont ) )		//"Imposto Devido no M�s"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	aAdd(_aExcDvMes,{STR0133,"nImpDevMe2", "=", 2}) //EXCEL

	If cTributo == TRIBUTO_IRPJ
		//"Provis�o IRPJ"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrPrIRP2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0130, 1, oFont ) )		//"Provis�o IRPJ"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20

		aAdd(_aExcDvMes,{STR0130,"nVlrPrIRP2", "+", 2}) //EXCEL

	Else
		//"Valor Imposto"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrImpos2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0131, 1, oFont ) )		//"Valor Imposto"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20

		aAdd(_aExcDvMes,{STR0131,"nVlrImpos2", "+", 2}) //EXCEL

	EndIf
	
	//"Adicionais do Tributo"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nAdicTrib2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0135, 1, oFont ) )		//"Adicionais do Tributo"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20

	aAdd(_aExcDvMes,{STR0135,"nAdicTrib2", "-", 2}) //EXCEL

	//"Dedu��es"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrDeduc2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0132, 1, oFont ) )		//"Dedu��es"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	aAdd(_aExcDvMes,{STR0132,"nVlrDeduc2", "-", 2}) //EXCEL

	//"Imp. devido meses ant."
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nDeviAnte2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0138, 1, oFont ) )			//"Imp. devido meses ant."
	
	aAdd(_aExcDvMes,{STR0138,"nDeviAnte2", "", 2}) //EXCEL

	nTopSimul2 += 25
	
EndIf

Return( Nil )

/*/{Protheus.doc} LoadSimula
Carregas a tela de simula��o conforme os dados do per�odo selecionado
@author david.costa
@since 30/01/2017
@version 1.0
@param aListParam, array, Parametros da Simula��o
@param nIndicePer, num�rico, Indica o per�odo selecionados
@param cLogAvisos, character, Log de avisos do processo
@return ${lRet}, ${Verdadeiro se a atualiza��o for bem sucedida}
@example
LoadSimula( aListParam, nIndicePer, @cLogAvisos )
/*/Static Function LoadSimula( aListParam, nIndicePer, cLogAvisos, lAutomato )

Local oModelPer	as object
Local cFormaTrib	as character
Local nIndiceGet	as numeric
Local aParametro	as array
Local aParRural	as array
Local lRet			as logical
Local lRural		as logical

Default nIndicePer	:=	Val( oTreePerio:GetCargo() ) - 1
Default lAutomato   := .F.

oModelPer	:=	Nil
cFormaTrib	:=	""
nIndiceGet	:=	0
aParametro	:=	{}
aParRural	:=	{}
lRet		:=	.T.
lRural		:=	.F.

If nIndicePer > 0
	
	oModelPer := aListParam[ 1, PARAM_SIMUL_LISTA_PAR/*1*/, nIndicePer, LISTA_PAR_MODEL_PERIODO ]
	
	//Forma de tributa��o 
	cFormaTrib := xFunID2Cd( aListParam[ 1, 1 ]:GetValue( "MODEL_T0N", "T0N_IDFTRI" ), "T0K", 1 )
	
	//Verifica se o Evento tem atividade Rural
	lRural := !Empty( aListParam[ 1, 1 ]:GetValue( "MODEL_T0N", "T0N_IDEVEN" ) )

	//Atualiza o array da apura��o
	aParametro := aListParam[ 1, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_ARRAY_PARAMETRO ]
	
	//Atualiza o array da apura��o da Atividade Rural
	aParRural := aListParam[ 1, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_ARRAY_PAR_RURAL ]
	
	//Atualiza o Evento 1
	AtualizaEv( @cDescEve1, @cDescFTri1, aListParam[ 1, PARAM_SIMUL_MODEL_EVENTO ] )
	
	//Saldo Evento 1
	nSaldoEve1 := oModelPer:GetValue( "MODEL_CWV", "CWV_APAGAR" )
	
	//Descri��o do per�odo
	cDescPerio := FormatStr( "@1 � @2", { dToc( oModelPer:GetValue( "MODEL_CWV", "CWV_INIPER" ) ),;
		dToc( oModelPer:GetValue( "MODEL_CWV", "CWV_FIMPER" ) ) } )

	//Atualiza os valores da simula��o
	If lRural
		nBaseCalcu	:= VlrLucReal( aParametro, aParRural )
		nVlrImpost	:= Iif( VlrBCxAliq( aParametro, aParRural ) > 0, VlrBCxAliq( aParametro, aParRural ), 0 )
		nVlrAdicio	:= Iif( VlrAdiciIR( aParametro, aParRural ) > 0, VlrAdiciIR( aParametro, aParRural ), 0 )
		nVlrPrIRPJ	:= Iif( VlrProIRPJ( aParametro, aParRural ) > 0, VlrProIRPJ( aParametro, aParRural ), 0 )
		nSaldoDeve	:= Iif( CalcVlrAPg( aParametro, @cLogAvisos, oModelPer, .T., aParRural ) > 0,;
		CalcVlrAPg( aParametro, @cLogAvisos, oModelPer, .T., aParRural ), 0 )
	Else
		nBaseCalcu	:= VlrLucReal( aParametro )
		nVlrImpost	:= Iif( VlrBCxAliq( aParametro ) > 0, VlrBCxAliq( aParametro ), 0 )
		nVlrAdicio	:= Iif( VlrAdiciIR( aParametro ) > 0, VlrAdiciIR( aParametro ), 0 )
		nVlrPrIRPJ	:= Iif( VlrProIRPJ( aParametro ) > 0, VlrProIRPJ( aParametro ), 0 )
		nSaldoDeve	:= Iif( CalcVlrAPg( aParametro, @cLogAvisos, oModelPer, .T. ) > 0, CalcVlrAPg( aParametro, @cLogAvisos, oModelPer, .T. ) , 0 )
	EndIf
	
	nAliqImpos	:= aParametro[ ALIQUOTA_IMPOSTO ]
	nVlrIsento	:= VlrIsento( aParametro )
	nParcIsent	:= aParametro[ PARCELA_ISENTA ]
	nNMesesIse	:= ( DateDiffMonth( aParametro[ INICIO_PERIODO ], aParametro[ FIM_PERIODO ] ) + 1 )
	nAliqAdici	:= aParametro[ ALIQUOTA_IR_ADICIONAL_IMPOSTO ]
	nVlrDeduco	:= aParametro[ GRUPO_DEDUCOES_TRIBUTO ]
	nVlrCompen	:= aParametro[ GRUPO_COMPENSACAO_TRIBUTO ]
	nReceAliq1	:= aParametro[ GRUPO_RECEITA_BRUTA_ALIQ1 ]
	nReceAliq2	:= aParametro[ GRUPO_RECEITA_BRUTA_ALIQ2 ]
	nReceAliq3	:= aParametro[ GRUPO_RECEITA_BRUTA_ALIQ3 ]
	nReceAliq4	:= aParametro[ GRUPO_RECEITA_BRUTA_ALIQ4 ]
	nReceGrup1	:= VlrReAliq1( aParametro )
	nReceGrup2	:= VlrReAliq2( aParametro )
	nReceGrup3	:= VlrReAliq3( aParametro )
	nReceGrup4	:= VlrReAliq4( aParametro )
	nAliqGrup1	:= aParametro[ ALIQUOTA_RECEITA_1 ]
	nAliqGrup2	:= aParametro[ ALIQUOTA_RECEITA_2 ]
	nAliqGrup3	:= aParametro[ ALIQUOTA_RECEITA_3 ]
	nAliqGrup4	:= aParametro[ ALIQUOTA_RECEITA_4 ]
	nLucEstima	:= VlrLucroEs( aParametro )
	nVlrExclus	:= VlrExcluso( aParametro )
	nDemaisRec	:= aParametro [ GRUPO_DEMAIS_RECEITAS ]
	nResulCont	:= VlrResCont( aParametro )
	nResulOper	:= aParametro[ GRUPO_RESULTADO_OPERACIONAL ]
	nResulNOpe	:= aParametro[ GRUPO_RESULTADO_NAO_OPERACIONAL ]
	nLucroReal	:= VlrLRAntes( aParametro )
	nVlrAdicoe	:= VlrAdicoes( aParametro )
	nVlrDoacoe	:= VlrDoacoes( aParametro )
	nCompPreju	:= aParametro[ GRUPO_COMPENSACAO_PREJUIZO ]
	nImpDevMes	:= Iif( VlrDeviMes( aParametro, oModelPer, aParRural, xFunID2Cd( aListParam[ 1, 1 ]:GetValue( "MODEL_T0N", "T0N_IDFTRI" ), "T0K", 1 ) ) > 0,;
	 				VlrDeviMes( aParametro, oModelPer, aParRural, xFunID2Cd( aListParam[ 1, 1 ]:GetValue( "MODEL_T0N", "T0N_IDFTRI" ), "T0K", 1 ) ), 0 )
	nDeviAnter	:= Iif( cFormaTrib == TRIBUTACAO_LUCRO_REAL, aParametro[ VLR_PAGO_PERIODOS_ANTERIORES ], aParametro[ VLR_DEVIDO_PERIODOS_ANTERIORES ] )
	nAdicTribu	:= aParametro[ GRUPO_ADICIONAIS_TRIBUTO ]
	nLRAposPj1	:= VlrLRApoPj( aParametro, aParRural )
	nPrejRura1	:= aParametro[ VLR_PREJUIZO_COMP_NO_PERIODO ]
	nBCParcia1	:= VlrBCParci( aParametro, aParRural )
	nResCtbRu1	:= VlrResCont( aParRural )
	nResOpRur1	:= aParRural[ GRUPO_RESULTADO_OPERACIONAL ]
	nResNOpRu1	:= aParRural[ GRUPO_RESULTADO_NAO_OPERACIONAL ]
	nLRealRur1	:= VlrLRAntes( aParRural )
	nVlrAdRur1	:= VlrAdicoes( aParRural )
	nVlrExRur1	:= VlrExcluso( aParRural )
	nVlrDoaRu1	:= VlrDoacoes( aParRural )
	nLRApPjRu1	:= VlrLRApoPj( aParRural, aParametro )
	nPrejGera1	:= aParRural[ VLR_PREJUIZO_COMP_NO_PERIODO ]
	nPjCompGe1	:= aParametro[ GRUPO_COMPENSACAO_PREJUIZO ]
	nBCParRur1	:= VlrBCParci( aParRural, aParametro )
	nCompPjRu1	:= aParRural[ GRUPO_COMPENSACAO_PREJUIZO ]
	
	If !lAutomato
		//Atualiza Detalhamento
		SetColDet( oModelPer, @aColsDet1, aListParam[ 1, 1 ]:GetValue( "MODEL_T0N", "T0N_ID" ) )
		if Len(aColsDet1) > 0
			oGetDBDet1:SetArray( aColsDet1, .T. )
		endif	
		oGetDBDet1:Refresh()
	EndIf	
	//Atualiza o Log de Erros
	cLogPerio1 := aListParam[ 1, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_LOG_PERIODO ]
	
	If !lAutomato
		oFolderEve:Refresh()
		oFolder1:Refresh()
		oPanel1:Refresh()
	EndIf
	If Len( aListParam ) == 2
		
		//Atualiza o array da apura��o
		aParametro := aListParam[ 2, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_ARRAY_PARAMETRO ]
		
		//Atualiza o array da apura��o da Atividade Rural
		aParRural := aListParam[ 2, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_ARRAY_PAR_RURAL ]
		
		//Per�odo do segundo evento
		oModelPer := aListParam[ 2, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_MODEL_PERIODO ]
		
		//Verifica se o Evento tem atividade Rural
		lRural := !Empty( aListParam[ 2, 1 ]:GetValue( "MODEL_T0N", "T0N_IDEVEN" ) )
	
		//Atualiza o Evento 2
		AtualizaEv( @cDescEve2, @cDescFTri2, aListParam[ 2, PARAM_SIMUL_MODEL_EVENTO ] )
		
		//Saldo Evento 2
		nSaldoEve2 := oModelPer:GetValue( "MODEL_CWV", "CWV_APAGAR" )
		
		//Atualiza os valores da simula��o
		If lRural
			nBaseCalc2	:= VlrLucReal( aParametro, aParRural )
			nVlrImpos2	:= Iif( VlrBCxAliq( aParametro, aParRural ) > 0, VlrBCxAliq( aParametro, aParRural ), 0 )
			nVlrAdici2	:= Iif( VlrAdiciIR( aParametro, aParRural ) > 0, VlrAdiciIR( aParametro, aParRural ), 0 )
			nVlrPrIRP2	:= Iif( VlrProIRPJ( aParametro, aParRural ) > 0, VlrProIRPJ( aParametro, aParRural ), 0 )
			nSaldoDev2	:= Iif( CalcVlrAPg( aParametro, @cLogAvisos, oModelPer, .T., aParRural ) > 0,;
			CalcVlrAPg( aParametro, @cLogAvisos, oModelPer, .T., aParRural ), 0 )
		Else
			nBaseCalc2	:= VlrLucReal( aParametro )
			nVlrImpos2	:= Iif( VlrBCxAliq( aParametro ) > 0, VlrBCxAliq( aParametro ), 0 )
			nVlrAdici2	:= Iif( VlrAdiciIR( aParametro ) > 0, VlrAdiciIR( aParametro ), 0 )
			nVlrPrIRP2	:= Iif( VlrProIRPJ( aParametro ) > 0, VlrProIRPJ( aParametro ), 0 )
			nSaldoDev2	:= Iif( CalcVlrAPg( aParametro, @cLogAvisos, oModelPer, .T. ) > 0, CalcVlrAPg( aParametro, @cLogAvisos, oModelPer, .T. ) , 0 )
		EndIf
	
		//Atualiza os valores da simula��o
		nAliqImpo2	:= aParametro[ ALIQUOTA_IMPOSTO ]
		nVlrIsent2	:= VlrIsento( aParametro )
		nParcIsen2	:= aParametro[ PARCELA_ISENTA ]
		nNMesesIs2	:= ( DateDiffMonth( aParametro[ INICIO_PERIODO ], aParametro[ FIM_PERIODO ] ) + 1 )
		nAliqAdic2	:= aParametro[ ALIQUOTA_IR_ADICIONAL_IMPOSTO ]
		nVlrDeduc2	:= aParametro[ GRUPO_DEDUCOES_TRIBUTO ]
		nVlrCompe2	:= aParametro[ GRUPO_COMPENSACAO_TRIBUTO ]
		nReceAlq12	:= aParametro[ GRUPO_RECEITA_BRUTA_ALIQ1 ]
		nReceAlq22	:= aParametro[ GRUPO_RECEITA_BRUTA_ALIQ2 ]
		nReceAlq32	:= aParametro[ GRUPO_RECEITA_BRUTA_ALIQ3 ]
		nReceAlq42	:= aParametro[ GRUPO_RECEITA_BRUTA_ALIQ4 ]
		nReceGrp12	:= VlrReAliq1( aParametro )
		nReceGrp22	:= VlrReAliq2( aParametro )
		nReceGrp32	:= VlrReAliq3( aParametro )
		nReceGrp42	:= VlrReAliq4( aParametro )
		nAliqGrp12	:= aParametro[ ALIQUOTA_RECEITA_1 ]
		nAliqGrp22	:= aParametro[ ALIQUOTA_RECEITA_2 ]
		nAliqGrp32	:= aParametro[ ALIQUOTA_RECEITA_3 ]
		nAliqGrp42	:= aParametro[ ALIQUOTA_RECEITA_4 ]
		nLucEstim2	:= VlrLucroEs( aParametro )
		nVlrExclu2	:= VlrExcluso( aParametro )
		nDemaisRe2	:= aParametro [ GRUPO_DEMAIS_RECEITAS ]
		nResulCon2	:= VlrResCont( aParametro )
		nResulOpe2	:= aParametro[ GRUPO_RESULTADO_OPERACIONAL ]
		nResulNOp2	:= aParametro[ GRUPO_RESULTADO_NAO_OPERACIONAL ]
		nLucroRea2	:= VlrLRAntes( aParametro )
		nVlrAdico2	:= VlrAdicoes( aParametro )
		nVlrDoaco2	:= VlrDoacoes( aParametro )
		nCompPrej2	:= aParametro[ GRUPO_COMPENSACAO_PREJUIZO ]
		nImpDevMe2	:= Iif( VlrDeviMes( aParametro, oModelPer, aParRural, xFunID2Cd( aListParam[ 1, 1 ]:GetValue( "MODEL_T0N", "T0N_IDFTRI" ), "T0K", 1 ) ) > 0,;
	 				VlrDeviMes( aParametro, oModelPer, aParRural, xFunID2Cd( aListParam[ 1, 1 ]:GetValue( "MODEL_T0N", "T0N_IDFTRI" ), "T0K", 1 ) ), 0 )
		nDeviAnte2	:= Iif( cFormaTrib == TRIBUTACAO_LUCRO_REAL, aParametro[ VLR_PAGO_PERIODOS_ANTERIORES ], aParametro[ VLR_DEVIDO_PERIODOS_ANTERIORES ] )
		nAdicTrib2	:= aParametro[ GRUPO_ADICIONAIS_TRIBUTO ]
		nLRAposPj2	:= VlrLRApoPj( aParametro, aParRural )
		nPrejRura2	:= aParametro[ VLR_PREJUIZO_COMP_NO_PERIODO ]
		nBCParcia2	:= VlrBCParci( aParametro, aParRural )
		nResCtbRu2 := VlrResCont( aParRural )
		nResOpRur2 := aParRural[ GRUPO_RESULTADO_OPERACIONAL ]
		nResNOpRu2 := aParRural[ GRUPO_RESULTADO_NAO_OPERACIONAL ]
		nLRealRur2 := VlrLRAntes( aParRural )
		nVlrAdRur2 := VlrAdicoes( aParRural )
		nVlrExRur2 := VlrExcluso( aParRural )
		nVlrDoaRu2 := VlrDoacoes( aParRural )
		nLRApPjRu2 := VlrLRApoPj( aParRural, aParametro )
		nPrejGera2 := aParRural[ VLR_PREJUIZO_COMP_NO_PERIODO ]
		nPjCompGe2 := aParametro[ GRUPO_COMPENSACAO_PREJUIZO ]
		nBCParRur2 := VlrBCParci( aParRural, aParametro )
		nCompPjRu2 := aParRural[ GRUPO_COMPENSACAO_PREJUIZO ]

		If !lAutomato
			//Atualiza Detalhamento
			SetColDet( oModelPer, @aColsDet2, aListParam[ 2, 1 ]:GetValue( "MODEL_T0N", "T0N_ID" ) )
			oGetDBDet2:SetArray( aColsDet2, .T. )
			oGetDBDet2:Refresh()
		EndIf
		//Atualiza o Log de Erros
		cLogPerio2 := aListParam[ 2, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_LOG_PERIODO ]
		
	EndIf

EndIf
If !lAutomato
	//Refresh em todos os Tget da tela de simula��o
	For nIndiceGet := 1 to Len( aoGet ) 
		aoGet[ nIndiceGet ]:CtrlRefresh()
	Next nIndiceGet
	oMultiGet:Refresh()
EndIf	

Return( lRet )

/*/{Protheus.doc} SetColDet
Atualiza a Grid do Detalhamento com itens simulados
@author david.costa
@since 30/01/2017
@version 1.0
@param oModelPer, objeto, Passar por refer�ncia o objeto FWFormModel() do cadastro do per�odo
@param aColsDet, array, Passar por refer�ncia o array que receber� os dados da Grid
@param cIdEvento, character, Identificador do Evento
@return ${Nil}, ${Nulo}
@example
SetColDet( oModelPer, @aColsDet, cIdEvento )
/*/Static Function SetColDet( oModelPer, aColsDet, cIdEvento )

Local oModelDet	as object
Local oModelEve	as object
Local cTabelaECF	as character
Local cDescGrupo	as character
Local cCodCC		as character
Local cTipoCC		as character
Local cOperacao	as character
Local cRural		as character
Local cChaveT0O	as character
Local cOrigem		as character
Local cAliasQry	as character
Local nIndiceDet	as numeric
Local nIdGrupo	as numeric
Local cEvento as character

oModelDet	:=	oModelPer:GetModel( "MODEL_CWX" )
oModelEve	:=	Nil
cTabelaECF	:=	""
cDescGrupo	:=	""
cCodCC		:=	""
cTipoCC	:=	""
cOperacao	:=	""
cRural		:=	""
cChaveT0O	:=	""
cOrigem	:=	""
cAliasQry	:= ""
nIndiceDet	:=	0
nIdGrupo	:= 0
cEvento 	:= ''

aColsDet := {}
DbSelectArea( "T0O" )
T0O->( DbSetOrder( 1 ) )
For nIndiceDet := 1 to oModelDet:Length()
	oModelDet:GoLine( nIndiceDet )
	cOrigem := oModelDet:GetValue( "CWX_ORIGEM" )
	If !oModelDet:IsDeleted() .and. !Empty( oModelDet:GetValue( "CWX_ORIGEM" ) )
		
		cTipoCC := cCodCC := cOperacao 
		cRural := oModelDet:GetValue( "CWX_RURAL" )
		cEvento := iif( cRural != '1', cIdEvento, GetAdvFVal( 'T0N', 'T0N_IDEVEN', xFilial( 'T0N' ) + cIdEvento, 1 ) )

		If !Empty( oModelDet:GetValue( "CWX_IDECF" ) )
			cTabelaECF := Posicione( "CH6", 1, xFilial("CH6") + oModelDet:GetValue( "CWX_IDECF" ) , "AllTrim( CH6_CODIGO ) + ' ' + AllTrim( CH6_DESCRI )" )
		Else
			cTabelaECF := Posicione( "CH8", 1, xFilial("CH8") + oModelDet:GetValue( "CWX_IDLAL" ) , "AllTrim( CH8_CODIGO ) + ' ' + AllTrim( CH8_DESCRI )" )
		EndIf
		
		cDescGrupo := Posicione( "LEE", 1, xFilial("LEE") + oModelDet:GetValue( "CWX_IDCODG" ) ,"AllTrim( LEE_DESCRI )" )
		
		cChaveT0O := xFilial( "T0O" )
		cChaveT0O += cEvento
		cChaveT0O += STR( Val( Posicione( "LEE", 1, xFilial("LEE") + oModelDet:GetValue( "CWX_IDCODG" ) ,"AllTrim( LEE_CODIGO )" ) ), 2 )
		cChaveT0O += oModelDet:GetValue( "CWX_SEQITE" )
		
		If !Empty( oModelDet:GetValue( "CWX_SEQITE" ) )
			nIdGrupo := Val( Posicione( "LEE", 1, xFilial("LEE") + oModelDet:GetValue( "CWX_IDCODG" ) ,"AllTrim( LEE_CODIGO )" ) )
			cChaveT0O := xFilial( "T0O" )
			If nIdGrupo == GRUPO_RECEITA_LIQUIDA_ATIVIDA .or. nIdGrupo == GRUPO_LUCRO_EXPLORACAO
				cChaveT0O += GetIdEvExp( cEvento )
			Else
				cChaveT0O += Posicione( "T0N", 1, xFilial("T0N") + cEvento ,"AllTrim( T0N_ID )" )
			EndIf
			cChaveT0O += STR( nIdGrupo, 2 )
			cChaveT0O += oModelDet:GetValue( "CWX_SEQITE" )
			T0O->( MsSeek( cChaveT0O ) )
		EndIf

		If cOrigem == ORIGEM_CONTA_CONTABIL
			cCodCC := AllTrim( Posicione( "C1O", 3, xFilial("C1O") + T0O->T0O_IDCC ,"C1O_CODIGO" ) )
			cTipoCC := T0O->T0O_TIPOCC
			cOperacao := T0O->T0O_OPERAC
		ElseIf cOrigem == ORIGEM_LALUR_PARTE_B
			cCodCC := XFUNID2Cd( T0O->T0O_IDPARB, "T0S", 1 )
			cTipoCC := T0O->T0O_TIPOCC
			cOperacao := T0O->T0O_OPERAC
		ElseIf cOrigem == ORIGEM_LANCAMENTO_MANUAL
			cOperacao := Posicione( "LEC", 1, xFilial("LEC") + cEvento + oModelDet:GetValue( "CWX_SEQITE" ), "LEC_TPOPER" )
		EndIf
		
		aAdd( aColsDet, { T0O->T0O_FILITE, cOrigem, cDescGrupo, cCodCC, oModelDet:GetValue( "CWX_VALOR" ), cTabelaECF, cRural, cOperacao, cTipoCC, .F. } )
	EndIf
Next nIndiceDet

Return( Nil )

/*/{Protheus.doc} AtualizaEv
Atualiza os dados do evento que foi simulado
@author david.costa
@since 30/01/2017
@version 1.0
@param cDescEve, character, Passar por refer�ncia a vari�vel global que armazenar� a descri��o do Evento
@param cDescFTri, character, Passar por refer�ncia a vari�vel global que armazenar� a forma de tributa��o do Evento
@param oModelEven, objeto, Objeto FWFormModel() do cadastro do Evento Tribut�rio
@return ${Nil}, ${Nulo}
@example
AtualizaEv( @cDescEve, @cDescFTri, oModelEven )
/*/Static Function AtualizaEv( cDescEve, cDescFTri, oModelEven )

//Descri��o do Evento
cDescEve := AllTrim( oModelEven:GetValue( "MODEL_T0N", "T0N_CODIGO" ) ) + Space(1) + AllTrim( oModelEven:GetValue( "MODEL_T0N", "T0N_DESCRI" ) )

//Forma de tributa��o do Evento
cDescFTri := Posicione( "T0K", 1, xFilial( "T0K" ) + oModelEven:GetValue( "MODEL_T0N", "T0N_IDFTRI" ), "ALLTRIM( T0K_DESCRI )" )

//Descri��o do Tributo
cTribu := Posicione( "T0J", 1, xFilial( "T0J" ) + oModelEven:GetValue( "MODEL_T0N", "T0N_IDTRIB" ), "ALLTRIM( T0J_CODIGO )" )

Return( Nil )

/*/{Protheus.doc} FormatStr
Formata uma string conforme os parametros passados
@author david.costa
@since 23/01/2017
@version 1.0
@param cTexto, character, Mensagem para que ser� formatada
@param aParam, Array, Array com valores para sibstituir variav�is na mensagem, 
	as variaveis na mensagem dever�o iniciar com @ seguido de um sequencial
@return ${cTexto}, ${Mensagem tratada}
@example
AddLogErro( "O valor @1 do campo @2 est� incorreto", @cLog, { 38, "AAA_TESTES" } )
A mensagem ser� gravada assim: "O valor 38 do campo AAA_TESTES est� incorreto"
/*/Static Function FormatStr( cTexto, aParam )

Local nIndice	as numeric

Default aParam	:=	{}
Default cTexto	:=	""

nIndice	:=	0

For nIndice := 1 To Len( aParam )
	If ValType( aParam[ nIndice ] ) == "N"
		aParam[ nIndice ] := Str( aParam[ nIndice ] )
	EndIf

	cTexto := StrTran( cTexto, "@" + AllTrim( Str( nIndice ) ), AllTrim( aParam[ nIndice ] ) )
Next nIndice

Return( cTexto )

/*/{Protheus.doc} GetHeadCWX
Colunas da Grid de detalhamento dos itens na simula��o
@author david.costa
@since 30/01/2017
@version 1.0
@param aHeader, array, Array que receber� as colunas
@return ${Nil}, ${Nulo}
@example
GetHeadCWX( @aHeader )
/*/Static Function GetHeadCWX() 
Local aCpoCWX := {'CWX_ORIGEM','CWX_DCODGR','CWX_VALOR','CWX_TABECF','CWX_RURAL'} //campos da tabela CWX que vao para getdados
Local aCpoT0O := {'T0O_FILITE','T0O_OPERAC','T0O_CODCC','T0O_TIPOCC'} //campos da tabela T0O que vao para getdados
Local aCpoDel := {'alias wt','recno wt'} //Campos que ser�o retirados do aHeader da GetDados
Local aCpoSort := {'T0O_FILITE','CWX_ORIGEM','CWX_DCODGR','T0O_CODCC','CWX_VALOR','CWX_TABECF','CWX_RURAL','T0O_OPERAC','T0O_TIPOCC'}
Local aHeaderT0O := {}
Local aSortHeader := {}
Local nPosCpo := 0
Local i := 0

//Carrega o aHeader com os campos da tabela T0O
FillGetDados(2,'T0O',/*nOrder*/,/*cSeekKey*/,/*bSeekWhile*/,/*uSeekFor*/,/*aNoFields*/,aCpoT0O,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,.T./*lEmpty*/,/*aHeaderAux*/,/*aColsAux*/,/*bafterCols*/,/*bBeforeCols*/,/*bAfterHeader*/,/*cAliasQry*/,/*bCriaVar*/,/*lUserFields*/,/*aYesUsado*/)

//Joga os dados do aHeader da tabela T0O para um array auxiliar e limpa o aHeader
aHeaderT0O := aHeader
aHeader := {}

//Carrega o aHeader com os campos da tabela CWX
FillGetDados(2,'CWX',/*nOrder*/,/*cSeekKey*/,/*bSeekWhile*/,/*uSeekFor*/,/*aNoFields*/,aCpoCWX,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,.T./*lEmpty*/,/*aHeaderAux*/,/*aColsAux*/,/*bafterCols*/,/*bBeforeCols*/,/*bAfterHeader*/,/*cAliasQry*/,/*bCriaVar*/,/*lUserFields*/,/*aYesUsado*/)

//Tira o campos do controle da GetDados do aHeader ( 'alias wt' e 'recno wt' )
for i := 1 to len(aCpoDel)
	nPosCpo := aScan(aHeader, {|x| lower(x[1]) == aCpoDel[i]} )
	if nPosCpo > 0
		aDel(aHeader,nPosCpo)
		aSize(aHeader,len(aHeader)-1)
	endif
next

//Inclui no aHeader os campos da tabela T0O
for i := 1 to len(aHeaderT0O)
	if aScan(aCpoDel, {|x| x == lower(alltrim(aHeaderT0O[i][1])) } ) = 0 
		aadd(aHeader,aHeaderT0O[i])
	endif
next

//Tratamento para reordenar o cabecalho
aSortHeader := aClone( aHeader )
aHeader := {}

for i := 1 to len(aCpoSort)
	nPosCpo := aScan(aSortHeader, {|x| upper(alltrim(x[2])) == aCpoSort[i]} )
	if nPosCpo > 0
		aadd(aHeader,aSortHeader[nPosCpo])
	endif
next i

Return( Nil )

/*/{Protheus.doc} RelPartA
Gera o relatorio do LALUR Parte A
@author david.costa
@since 04/05/2017
@version 1.0
@param aListParam, array, (Descri��o do par�metro)
@return ${Nil}, ${Nulo}
@example
RelPartA( aListParam )
/*/Static Function RelPartA( aListParam )

Local oModelPeri	as object
Local oModelEven	as object
Local cLogErros	as character
Local nIndicePer	as numeric
Local nIndice		as numeric
Local aParametro	as array
Local aParRural	as array

cLogErros	:=	""
nIndicePer	:=	Iif( ( Val( oTreePerio:GetCargo() ) - 1 ) == 0, Val( oTreePerio:GetCargo() ), Val( oTreePerio:GetCargo() ) - 1 )
nIndice	:=	0
aParametro	:= {}
aParRural	:= {}

If nIndicePer > 0
	
	For nIndice := 1 to Len( aListParam )
		//Carrega o Per�odo
		oModelPeri := aListParam[ nIndice, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_MODEL_PERIODO ]
		
		//Carrega os parametros
		aParametro := aListParam[ nIndice, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_ARRAY_PARAMETRO ]
		aParRural	:= aListParam[ nIndice, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_ARRAY_PAR_RURAL ]
		
		//Carrega o Evento
		oModelEven := aListParam[ nIndice, PARAM_SIMUL_MODEL_EVENTO ]
		
		If xFunID2Cd( oModelEven:GetValue( "MODEL_T0N", "T0N_IDFTRI"), "T0K", 1 ) == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or. ;
			xFunID2Cd( oModelEven:GetValue( "MODEL_T0N", "T0N_IDFTRI"), "T0K", 1 ) == TRIBUTACAO_LUCRO_REAL
			RelApuraca( oModelEven, oModelPeri, @cLogErros, aParametro, aParRural )
		Else
			AddLogErro( STR0157, @cLogErros ) //"Este Relat�rio s� pode ser gerado para a forma de tributa��o estimativa por levantamento de balan�o."
		EndIf
	Next nIndice
		
	If !Empty( cLogErros )
		ShowLog( STR0164, cLogErros ) //ATEN��O
	EndIf
EndIf

Return()

/*/{Protheus.doc} RelPartB
Gera o relatorio do LALUR Parte B
@author david.costa
@since 05/05/2017
@version 1.0
@param aListParam, array, (Descri��o do par�metro)
@return ${Nil}, ${Nulo}
@example
RelPartB( aListParam )
/*/Static Function RelPartB( aListParam )

Local oModelPeri	as object
Local oModelEven	as object
Local cLogErros	as character
Local nIndicePer	as numeric

cLogErros	:=	""
nIndicePer	:=	Iif( ( Val( oTreePerio:GetCargo() ) - 1 ) == 0, Val( oTreePerio:GetCargo() ), Val( oTreePerio:GetCargo() ) - 1 )

If nIndicePer > 0 .and. Len( aListParam ) > 0
	oModelPeri := aListParam[ 1, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_MODEL_PERIODO ]
	
	//Carrega o Evento
	oModelEven := aListParam[ 1, PARAM_SIMUL_MODEL_EVENTO ]

	If xFunID2Cd( oModelEven:GetValue( "MODEL_T0N", "T0N_IDFTRI"), "T0K", 1 ) == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or. ;
		xFunID2Cd( oModelEven:GetValue( "MODEL_T0N", "T0N_IDFTRI"), "T0K", 1 ) == TRIBUTACAO_LUCRO_REAL
		TAFR118( oModelPeri, @cLogErros )
	Else
		AddLogErro( STR0157, @cLogErros ) //"Este Relat�rio s� pode ser gerado para a forma de tributa��o estimativa por levantamento de balan�o."
	EndIf
		
	If !Empty( cLogErros )
		ShowLog( STR0164, cLogErros ) //ATEN��O
	EndIf
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ShowLog

Exibe a mensagem de log de ocorr�ncias.

@Param		cTitle	- T�tulo da interface
			cBody	- Corpo da mensagem

@Author		Felipe C. Seolin
@Since		26/12/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ShowLog( cTitle, cBody )

Local oModal	as object

oModal	:=	FWDialogModal():New()

oModal:SetTitle( cTitle )
oModal:SetFreeArea( 250, 150 )
oModal:SetEscClose( .T. )
oModal:SetBackground( .T. )
oModal:CreateDialog()
oModal:AddCloseButton()

TMultiGet():New( 030, 020, { || cBody }, oModal:GetPanelMain(), 210, 100,, .T. ,,,, .T.,,,,,, .T.,,,,, .T. )

oModal:Activate()

Return()

/*/{Protheus.doc} GetIdEvExp
Retorna o Id do Evento da Explora��o
@author david.costa
@since 05/01/2018
@version 1.0
/*/Function GetIdEvExp( cIdEvento )

Local cSelect		as character
Local cFrom		as character
Local cWhere		as character
Local cAliasQry	as character
Local cIdEveExpl	as character

cAliasQry	:=	GetNextAlias()
cIdEveExpl	:= ""

cSelect	:= " T0O.T0O_IDEVEN "
cFrom		:= RetSqlName( "T0O" ) + " T0O "
cWhere		:= " T0O.T0O_FILIAL = '" + xFilial( "T0O" ) + "' "
cWhere		+= " AND T0O.D_E_L_E_T_ = ''"
cWhere		+= " AND T0O.T0O_ORIGEM = '" + ORIGEM_EVENTO_TRIBUTARIO + "' "
cWhere		+= " AND T0O.T0O_ID = '" + cIdEvento + "' "
cWhere		+= " AND T0O.T0O_IDGRUP = " + Str( GRUPO_DEDUCOES_TRIBUTO ) + " "

cSelect	:= "%" + cSelect 	+ "%"
cFrom  	:= "%" + cFrom   	+ "%"
cWhere		:= "%" + cWhere  	+ "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%

EndSql

If ( cAliasQry )->( !Eof() )
	cIdEveExpl := ( cAliasQry )->( T0O_IDEVEN )
EndIf

Return( cIdEveExpl )

//-------------------------------------------------------------------
/*/{Protheus.doc} TafVldCtC
Funcao de validacao utilizando EXISTCPO e chamando o HELP do campo

@param	cAlias  - Alias da tabela para o EXISTCPO
		nOrder  - Caso seja necessario alterar a ordem de pesquisa do EXISTCPO

@return lOk - Estrutura
		.T. Para validacao OK
		.F. Para validacao NAO OK

@author Denis Souza
@since 20/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------

Function TafVldCtC( cAlias , nOrder, cChave )

Local cCmp	  	:= ReadVar()
Local lOk		:= .T.
Local oModel	:= Nil
Local oMdl		:= Nil
Local cNmModel	:= " "
Local cChvBkp	:= " "
Local cFilIte	:= " "

Default	cAlias := 1
Default	nOrder := 1
Default	cChave := &( cCmp )

cChvBkp := cFilAnt

If !Vazio()
	if cAlias == "C1O" .And. Alltrim(FunName()) == "TAFA433" .And. "T0O_CODCC" $ cCmp
		//Verificar ultimo modelo ativo
		oModel := FwModelActive()
		If oModel:IsActive()	

			//Obter Modelo posicionado para o GetValue Funcionar
			if valtype( oModel:AERRORMESSAGE[1] ) == "C"
				cNmModel := oModel:AERRORMESSAGE[1]
				oMdl := oModel:GetModel( cNmModel )
				cFilIte := oMdl:GetValue("T0O_FILITE")

				//Carrega a filial correspondente para o ExistCpo funcionar
				C1E->( DBSetOrder( 1 ) )
				C1E->( DBSeek( xFilial("C1E") + cFilIte ) )
				if !empty(C1E->C1E_FILTAF)
					cFilAnt := C1E->C1E_FILTAF
				endif
			endif
		endif
	endif
	lOk := ExistCpo( cAlias , cChave , nOrder )
Else
	lOk	:= .F.
EndIf

If !lOk
	Help( ,,AllTrim(SubStr(cCmp,4)),,, 1, 0 )
EndIf

cFilAnt := cChvBkp

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} TafRelCtC

Fun��o utilizada no X3_RELAC

cCmpPar: Nome do Campo
nTpRet:  1 - C�digo

@Return	nValor - Retorna o valor de retorno para o X3_RELAC

@Author	Denis Souza
@Since 20/03/2020
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TafRelCtC( cCmpPar, nTpRet )

Local cValor	:= ""
Local cCmpM		:= ReadVar()
Local cFilC1O 	:= ""

Default cCmpPar	:= ""
Default nTpRet  := 1

if "T0O_IDCC" $ cCmpPar .And. nTpRet == 1

	cFilC1O := xFilial("C1O",xFunCh2ID(T0O->T0O_FILITE,"C1E",1))

	If "T0O_CODCC" $ cCmpM //Codigo Conta Contabil
		cValor := IIF(!INCLUI .AND. !EMPTY(T0O->T0O_IDCC),Posicione("C1O",3,cFilC1O+T0O->T0O_IDCC,"AllTrim(C1O->C1O_CODIGO)"),"")
	ElseIf "T0O_DCONTC" $ cCmpM //Descricao Conta Contabil
		cValor := IIF(!INCLUI .AND. !EMPTY(T0O->T0O_IDCC),Posicione("C1O",3,cFilC1O+T0O->T0O_IDCC,"AllTrim(C1O->C1O_DESCRI)"),"")
	Endif
endif

Return( cValor )

//-------------------------------------------------------------------
/*/{Protheus.doc} VldGridEv

Valida o grid dp evento tribut�rio (LinhaOk)

cCmpPar: Nome do Campo
nTpRet:  1 - C�digo

@carlos Eduardo Boy
@Since 03/02/22
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldGridEv(oModelGrid, nLine)
Local lRet       := .t.
Local cFilIte    := padr(alltrim(substr(oModelGrid:GetValue( 'T0O_FILITE' ),3)), GetSx3Cache( 'C1O_FILIAL' , 'X3_TAMANHO' ))
Local cC1OFilial := xFilial( 'C1O' , cFilIte )
Local cTpCC      := GetAdvFVal( 'C1O' , 'C1O_INDCTA' , cC1OFilial + oModelGrid:GetValue( 'T0O_IDCC' ), 3 )
Local cContaID	 := ""
Local lContinua  := .t.

if !FwIsInCallStack('ChgLineView')
	aContas 	:= {}
	aSintetic	:= {}
	lFoundError	:= .f.
	lFoundGrid	:= .f.
else
	nLinAtu := 0
endif

//Se o tipo da conta informada no campo for sintetica
if cTpCC == '0'
	//Apresento tela de YesNo quando n�o forma chamada de rotinas autom�ticas
	If !lAutomato .and. !MsgYesNo(STR0166, STR0048) // 'Voc� informou uma conta sint�tica, deseja incluir as contas anal�ticas que est�o abaixo dela?' #'Conta contabil'
		lContinua  := .f.
			Help(nil, nil, "HELP", nil, STR0167, 1, 0, nil, nil, nil, nil, nil, {STR0168}) //#"N�o � permitido o envio de conta sint�tica para o Bloco M." #"Informe uma conta anal�tica"
	Endif

	if !lContinua
		lRet 	  := .f.
	else
		cSeekFil:= alltrim(oModelGrid:GetValue('T0O_FILITE'))
		cConta 	:= oModelGrid:GetValue('T0O_CODCC')
		cContaID:= oModelGrid:GetValue('T0O_IDCC')

		//Gurada no array aContas todas as contas anal�ticas que est�o abaixo da conta sintetica informada no campo.
		C1OChildren(cContaID,cC1OFilial,cSeekFil,oModelGrid)
	
		//Se existirem contas para serem cadastradas
		if len(aContas) > 0
			lRet 	:= .t.
			nLinAtu := nLine
		ElseIf lFoundGrid .and.  Len(aContas) == 0 
		
			Help(nil, nil, "HELP", nil, STR0170, 1, 0, nil, nil, nil, nil, nil, {STR0171}) //#'Todas as contas anal�ticas j� est�o cadastradas!' #'Escolha uma outra conta Sint�tica/Anal�tica!'
			lRet := .f.
		ElseIf Len(aContas) == 0 .and. lFoundError 
			Help(nil, nil, "HELP", nil, STR0172, 1, 0, nil, nil, nil, nil, nil, {STR0173}) //#'Foram encontrados erros de estrutura na conta sint�tica informada.' #'Corrija o cadastro da conta informando uma conta superior v�lida!'
			lRet := .f.
		ElseIf Len(aContas) == 0 .and. !lFoundError
			Help(nil, nil, "HELP", nil, STR0174, 1, 0, nil, nil, nil, nil, nil, {STR0171}) //#'N�o foram encontradas contas anal�ticas para a conta sint�tica informada.' #'Escolha uma outra conta Sint�tica/Anal�tica!'
			lRet := .f.
	
		endif

	endif
Endif
return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} C1OChildren
Fun��o recursiva para busca as conta cont�beis que est�o abaixo desta conta pai passada por par�metro
@Renan Gomes
@param cContaID, C, ID da conta na tabela C1O
@param cC1OFilial, C, xFilial() da tabela C1O j� tratada a filial, exemplo xFilial("C1O","M PR 01")
@param cSeekFil, C, Conteudo do campo T0O_FILITE para pesquisa na grid
@param oModelGrid, C, Grid da tabela T0O para inser��o de dados
@return return_var, return_type, return_description
@Since 08/02/2022
@Version 1.0
/*/
//-------------------------------------------------------------------
Function C1OChildren(cContaID,cC1OFilial,cSeekFil,oModelGrid)
Local cQryC1O 		:= ""
Local cAlsC1O   	:= GetNextAlias()

Default cContaID	:= ""
Default cC1OFilial  := ""
Default cSeekFil	:= ""
Default oModelGrid  := nil

If Type('aContas') == "U" 
	Private aContas 	:= {}
Endif

If Type('aSintetic') == "U" 
	Private aSintetic	:= {}
Endif

If Type('lFoundError') == "U" 
	Private lFoundError	:= .f.
Endif

cQryC1O := " SELECT C1O.C1O_CODIGO,C1O.C1O_ID,C1O_CTASUP,C1O.C1O_INDCTA FROM "+RetSqlName("C1O")+" C1O "
cQryC1O += " WHERE C1O.D_E_L_E_T_ = ' ' "
cQryC1O += " AND C1O.C1O_FILIAL ='"+cC1OFilial+"' "
cQryC1O += " AND C1O.C1O_CTASUP ='"+cContaID+"' "
cQryC1O += " ORDER BY C1O.C1O_CODIGO "

dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQryC1O) , cAlsC1O , .T. , .F.)

(cAlsC1O)->(dbGoTop())
While !(cAlsC1O)->(EOF())

	if (cAlsC1O)->C1O_INDCTA == '1' 
		If ValType(oModelGrid) == "O"
			If !oModelGrid:SeekLine( { { "T0O_FILITE", cSeekFil }, { "T0O_CODCC", (cAlsC1O)->C1O_CODIGO } },,.f.)
				If aScan(aContas, {|x| AllTrim(Upper(x[1]))+AllTrim(Upper(x[2])) ==  Alltrim((cAlsC1O)->C1O_CODIGO) + Alltrim(cC1OFilial) }) == 0
					aadd(aContas,{ (cAlsC1O)->C1O_CODIGO, cC1OFilial } )
				Endif
			else
				lFoundGrid := .t.
			Endif
		Else
			aadd(aContas,{ (cAlsC1O)->C1O_CODIGO, cC1OFilial } )
		Endif
	Else
		//Verifico se essa conta j� foi referenciada alguma vez,l se sim, significa que existe circularidade no cadastro do plano de contas
		if aScan(aSintetic,(cAlsC1O)->C1O_CODIGO) > 0
			lFoundError := .t.
			//Alert("Conta "+alltrim((cAlsC1O)->C1O_CODIGO)+" com circularidade")
			(cAlsC1O)->(dbSkip())
			Loop
		endif

		aadd(aSintetic, (cAlsC1O)->C1O_CODIGO)
		C1OChildren( (cAlsC1O)->C1O_ID,cC1OFilial,cSeekFil,oModelGrid)
	Endif
	
	(cAlsC1O)->(dbSkip())
End
(cAlsC1O)->(dbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ChgLineView

Inclui linhas automaticamente no grid do evento tribut�rio

@carlos Eduardo Boy
@Since 03/02/22
@Version 1.0
/*/
//-------------------------------------------------------------------
Function ChgLineView(oView, cViewID)
Local oModelGrid	:= oView:GetModel(cViewID)
Local aCposGrv 		:= oView:GetViewStruct(cViewID):GetFields()// retorna os campos que est�o na Grid para serem gravados

//Se existi linha para ser atualizada no grid.
if nLinAtu > 0
	If lAutomato
		IncLine(oModelGrid, aCposGrv, oView, cViewID)
	else
		RptStatus({|| IncLine(oModelGrid, aCposGrv, oView, cViewID)}, STR0175, STR0176) //#"Aguarde..." #"Incluindo contas anal�ticas no cadastro..."
	Endif
endif

if len(aSintetic) > 0
	If len(aContas) > 0 .AND. lFoundError
		MsgInfo(STR0177) //#'Foram encontrados problemas no cadastro do plano de contas em algumas contas sint�ticas. Confirme se todas as contas anal�ticas foram incluidas corretamente no cadastro do Evento Tribut�rio!'
		lFoundError := .f.
	Endif
Endif
nLinAtu := 0

return

//-------------------------------------------------------------------
/*/{Protheus.doc} IncLine

Inclui linhas no grid

@carlos Eduardo Boy/Renan Gomes
@Since 08/02/2022
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function IncLine(oModelGrid, aCposGrv, oView, cViewID)
Local nLine 	:= 0
Local i 		:= 0
Local j 		:= 0
Local cConteudo := ''
Local oHash	  	:= HMNew()
Local lLinAtu 	:= .t.

//Percorre as contas que devem ser cadastradas automaticamente.Variavel aContas esta sendo carregada na fun��o de valida��o( VldGridEv )
If !lAutomato;SetRegua(len(aContas));Endif
//Pega a linha atual e troca para a linha que deve ser atualizada.
nLine := oModelGrid:GetLine()

oModelGrid:GoLine(nLinAtu)
	
For i := 1 to len(aContas)	
	If !lAutomato;IncRegua();Endif
	if lLinAtu .and. GetAdvFVal( 'C1O', 'C1O_INDCTA', aContas[i][2] + oModelGrid:GetValue('T0O_CODCC'), 1 ) == '0' 
		oModelGrid:SetValue('T0O_CODCC',aContas[i][1])//Atualiza o campo da conta contabil da inha posicionada.
		for j := 1 to len(aCposGrv)
			if aCposGrv[j][10] // Campo que pode ser editado.
				//Grava no Hash os dados que devem ser replicados nas linhas do grid.
				hmset(oHash, aCposGrv[j][1], oModelGrid:GetValue(aCposGrv[j][1]))
			endif
		next			
		lLinAtu := .f.
	else
		//Se incluiu uma linha manualmente no grid (seta para baixo)
		if nLine > 0 .and. empty(oModelGrid:GetValue('T0O_ORIGEM',nLine))
			oModelGrid:GoLine(nLine)
			nLine := 0
		else
			oModelGrid:AddLine()
		endif

		//Preenche os campos da linha que foi incluida automaticamente.
		for j := 1 to len(aCposGrv)
			//Se for um campo editavel, grava os valores.
			if aCposGrv[j][10]
				if alltrim(aCposGrv[j][1]) != 'T0O_CODCC' 
					hmget(oHash, aCposGrv[j][1], @cConteudo)
				else
					cConteudo := aContas[i][1]
				endif	
				oModelGrid:SetValue( aCposGrv[j][1], cConteudo )
			endif
		next

		IF lAutomato .and. Empty(oModelGrid:GetValue("T0O_SEQITE"))
			oModelGrid:SetValue("T0O_SEQITE",StrZero(oModelGrid:length(),6))
		Endif

	endif
	//Posiciona o ultimo item e atualiza a View.
	oModelGrid:GoLine( oModelGrid:Length() )
	If !lAutomato;oView:Refresh(cViewID);Endif
	
next

FreeObj(oHash)

return


/*/{Protheus.doc} ImpSimuExc
Imprime a simula��o em planilha Excel

@author Karen Honda
@Since 06/05/2022
@Version 1.0
/*/
Static Function ImpSimuExc(aListParam, aItemsEvt)

Local oExcel		as Object
Local cData         as Character
Local cArquivo      as Character
Local cAba1			as Character
Local cTabela1		as Character
Local cAba2         as Character
Local cTabela2		as Character
Local i				as Numeric
Local cDirXLS		as Character
Local cDefPath		as Character 
Local lSmtHTML		as Logical
Local nFolder		as Numeric
Local cMsg			as Character

Default aItemsEvt := {}

oExcel		:=	FWMSExcel():New()
cData       :=  DToS( MsDate() ) 
cArquivo    := "simula_tafa433_" + cData + "_" + StrTran( Time(), ":", "" ) + ".xml"
cAba1		:= STR0070 //"Par�metros"
cTabela1	:= STR0070 //"Par�metros"
cAba2       := STR0107 //"Simula��o"
cTabela2	:= STR0107 //"Simula��o"
cDirXLS		:= ""
cDefPath	:= GetSrvProfString( "StartPath", "\system\" )
lSmtHTML	:= (GetRemoteType() == 5)
nFolder		:= 1
cMsg		:= ""
If Len(oFolderEve:aDialogs) > 1
	nFolder := oFolderEve:nOption
EndIf
If !Empty(_aExcBsCal)

	If lSmtHTML
		cDirXLS := cDefPath 
	Else
		cDirXLS := cGetFile( "*.xml|*.xml|*.xls|*.xls|*.xlsx|*.xlsx", STR0178/*"Selecione o diret�rio:"*/, 0,, .F., GETF_LOCALHARD+ GETF_RETDIRECTORY , .T.)
	EndIf
	If !Empty(cDirXLS)
		// ABA Par�metros
		oExcel:AddworkSheet(cAba1)
		oExcel:AddTable(cAba1,cTabela1)
		oExcel:SetHeaderBold(.T.)
		oExcel:AddColumn(cAba1,cTabela1,STR0070,1,1) //"Par�metros"
		oExcel:AddColumn(cAba1,cTabela1,STR0179,1,1) //"Conte�do"
		oExcel:AddRow(cAba1,cTabela1,{STR0069,cTribu}) //"Tributo"
		oExcel:AddRow(cAba1,cTabela1,{STR0103,cDescPerio}) //"Per�odo"
		If nFolder == 1
			oExcel:AddRow(cAba1,cTabela1,{STR0002,cDescFTri1}) //"Forma de Tributa��o"
			oExcel:AddRow(cAba1,cTabela1,{STR0106,cDescEve1}) //"Evento Tribut�rio"
		Else
			oExcel:AddRow(cAba1,cTabela1,{STR0002,cDescFTri2}) //"Forma de Tributa��o"
			oExcel:AddRow(cAba1,cTabela1,{STR0106,cDescEve2}) //"Evento Tribut�rio"
		EndIf		

		//ABA Simula��o
		oExcel:AddworkSheet(cAba2)
		oExcel:AddTable(cAba2,cTabela2)
		oExcel:SetHeaderBold(.T.)
		For i := 1 to 7
			oExcel:AddColumn(cAba2,cTabela2," ",3,1)
			oExcel:AddColumn(cAba2,cTabela2," ",2,1)
		Next i

		//Atividade Rural
		If Len(_aExcSepar) > 0
			ExcSimul(oExcel,cAba2,cTabela2, {_aExcSepar[1]}, nFolder)
		EndIf
		ExcSimul(oExcel,cAba2,cTabela2, _aExcRsCnt, nFolder)
		ExcSimul(oExcel,cAba2,cTabela2, _aExcLcRea, nFolder)
		ExcSimul(oExcel,cAba2,cTabela2, _aExcRAApo, nFolder)
		ExcSimul(oExcel,cAba2,cTabela2, _aExcBCPar, nFolder)

		//Apura��o rural
		If Len(_aExcSepar) > 1
			ExcSimul(oExcel,cAba2,cTabela2, {_aExcSepar[2]}, nFolder)
		EndIf
		ExcSimul(oExcel,cAba2,cTabela2, _aExcRsCtR, nFolder)
		ExcSimul(oExcel,cAba2,cTabela2, _aExcLcReR, nFolder)
		ExcSimul(oExcel,cAba2,cTabela2, _aExcRAApR, nFolder)
		ExcSimul(oExcel,cAba2,cTabela2, _aExcBCPcR, nFolder)

		If Len(_aExcSepar) > 2
			ExcSimul(oExcel,cAba2,cTabela2, {_aExcSepar[3]}, nFolder)
		EndIf
		ExcSimul(oExcel,cAba2,cTabela2, _aExcRAlq1, nFolder)
		ExcSimul(oExcel,cAba2,cTabela2, _aExcRAlq2, nFolder)
		ExcSimul(oExcel,cAba2,cTabela2, _aExcRAlq3, nFolder)
		ExcSimul(oExcel,cAba2,cTabela2, _aExcRAlq4, nFolder)
		ExcSimul(oExcel,cAba2,cTabela2, _aExcLcEst, nFolder)
		ExcSimul(oExcel,cAba2,cTabela2, _aExcBsCal, nFolder)
		ExcSimul(oExcel,cAba2,cTabela2, _aExcVrImp, nFolder)
		ExcSimul(oExcel,cAba2,cTabela2, _aExcVrIse, nFolder)
		ExcSimul(oExcel,cAba2,cTabela2, _aExcVrAdi, nFolder)
		ExcSimul(oExcel,cAba2,cTabela2, _aExcProIR, nFolder)
		ExcSimul(oExcel,cAba2,cTabela2, _aExcDvMes, nFolder)
		ExcSimul(oExcel,cAba2,cTabela2, _aExcAdDev, nFolder)

		AddDetails(oExcel, nFolder)

		AddLctCtb(oExcel, nFolder, aListParam, @aItemsEvt)

		oExcel:Activate()
		oExcel:GetXMLFile(cArquivo)

		If lSmtHTML
			nRet := CpyS2TW( cDefPath + cArquivo , .T. )
			cMsg :=  STR0181 //"N�o foi poss�vel gravar o arquivo!"
			If nRet == 0
				cMsg := STR0180+' "' + cArquivo + '" ' //"Arquivo gerado com sucesso:"
			EndIf	
			MsgInfo(cMsg,STR0164 )
			
			If File( cDefPath + cArquivo )
				FErase( cDefPath + cArquivo )
			EndIf

		Else
			If cDefPath != cDirXLS
				__CopyFile( cDefPath + cArquivo, cDirXLS + cArquivo )
				MsgInfo(STR0182+' "' + cArquivo + '" ') //"Arquivo gerado com sucesso:"

				If File( cDefPath + cArquivo )
					FErase( cDefPath + cArquivo )
				EndIf
			EndIf	

		EndIf

	EndIf
Else	
	MsgAlert(STR0191,STR0164) //"Impress�o da simula��o de Atividade Rural n�o dispon�vel! Realize a simula��o do evento tribut�rio principal."
EndIf	
Return 

/*/{Protheus.doc} AddDetails
Imprime a worksheet de Detalhamento da simula��o

@author Karen Honda
@Since 06/05/2022
@Version 1.0
/*/
Static Function AddDetails(oExcel, nFolder)
Local cAbaDet	:= STR0108 //"Detalhamento"
Local cTabDet	:= STR0108 //"Detalhamento"
Local i := 1

Default nFolder := 1

oExcel:AddworkSheet(cAbaDet)
oExcel:AddTable(cAbaDet,cTabDet)
oExcel:SetHeaderBold(.T.)
oExcel:AddColumn(cAbaDet,cTabDet,STR0206,1,1) //"Filial"
oExcel:AddColumn(cAbaDet,cTabDet,STR0183,1,1) //"Origem"
oExcel:AddColumn(cAbaDet,cTabDet,STR0184,1,1) //"Desc Grupo"
oExcel:AddColumn(cAbaDet,cTabDet,STR0189,1,1) //"Conta Contab."
oExcel:AddColumn(cAbaDet,cTabDet,STR0185,3,2) //"Valor"
oExcel:AddColumn(cAbaDet,cTabDet,STR0186,1,1) //"C�d. Tab ECF"
oExcel:AddColumn(cAbaDet,cTabDet,STR0187,1,1) //"Ativ. Rural"
oExcel:AddColumn(cAbaDet,cTabDet,STR0188,1,1) //"Opera��o"
oExcel:AddColumn(cAbaDet,cTabDet,STR0190,1,1) //"Tipo"

If nFolder == 1
	For i:= 1 to len(aColsDet1)
		oExcel:AddRow(cAbaDet,cTabDet,{aColsDet1[i][1],X3Combo("CWX_ORIGEM",aColsDet1[i][2]),aColsDet1[i][3],aColsDet1[i][4],aColsDet1[i][5],aColsDet1[i][6],X3Combo( "CWX_RURAL", aColsDet1[i][7] ),X3Combo( "LEC_TPOPER", aColsDet1[i][8] ),X3Combo( "T0O_TIPOCC", aColsDet1[i][9] ) })
	Next i
Else
	For i:= 1 to len(aColsDet2)
		oExcel:AddRow(cAbaDet,cTabDet,{aColsDet2[i][1],X3Combo("CWX_ORIGEM",aColsDet2[i][2]),aColsDet2[i][3],aColsDet2[i][4],aColsDet2[i][5],aColsDet2[i][6],X3Combo( "CWX_RURAL", aColsDet2[i][7] ),X3Combo( "LEC_TPOPER", aColsDet2[i][8] ),X3Combo( "T0O_TIPOCC", aColsDet2[i][9] ) })
	Next i
EndIf

Return

/*/{Protheus.doc} ExcSimul
Imprime as linhas da simula��o

@author Karen Honda
@Since 06/05/2022
@Version 1.0
/*/
Static Function ExcSimul(oExcel, cAba, cTable,aSimul, nFolder)
Local i 		as Numeric
Local aTitulo 	as Array
Local aValores 	as Array 

Default oExcel := nil
Default cAba := ""
Default cTable := ""
Default aSimul := {}
Default nFolder := 1

If Len(aSimul) > 0
	aTitulo := {}
	aValores := {}
	For i:= 1 to Len(aSimul)
		If aSimul[i][4] == nFolder
			aAdd(aTitulo,aSimul[i][1])
			aAdd(aTitulo,"")
			//aAdd(aValores,&(aSimul[i][2]))
			aAdd(aValores,Iif("="$aSimul[i][2],aSimul[i][2],Transform(&(aSimul[i][2]),"@E 9,999,999,999,999.99")))
			aAdd(aValores,aSimul[i][3])
		EndIf
	Next i
	If Len(aTitulo) > 0
		For i:= len(aTitulo)+1 to 14
			aAdd(aTitulo,"")
			aAdd(aValores,"")
		Next i

		oExcel:AddRow(cAba,cTable,aTitulo)
		oExcel:AddRow(cAba,cTable,aValores)
		oExcel:AddRow(cAba,cTable,{"","","","","","","","","","","","","",""}) // PULA LINHA
	EndIf
EndIf
Return

/*/{Protheus.doc} AddLctCtb
Imprime a worksheet 4 - LctosContabeis

@author Denis Souza
@Since 09/06/2022
@Version 1.0
/*/
Static Function AddLctCtb(oExcel, nFolder, aListParam, aItemsEvt)

Local cAbaDet	:= STR0193 //"Lan�amentos Cont�beis"
Local cTabDet	:= STR0193 //"Lan�amentos Cont�beis"
Local cAliasQry := GetNextAlias()
Local cSGBD  	:= Upper(Alltrim(TCGetDB())) //Banco de dados que esta sendo utilizado 
Local cIniPer   := ''
Local cFimPer   := ''
Local aPer      := Separa( FwNoAccent(cDescperio) , " a " )

Local cFilCta  	:= ''
Local cConta   	:= ''
Local cNatCt   	:= ''
Local cOp      	:= ''
Local cTipoCC  	:= ''
Local cDtLanc  	:= ''
Local cCodLan  	:= ''
Local cIndLan  	:= ''
Local nVlrPart 	:= 0
Local cIndNat  	:= ''
Local cCCCus   	:= ''
Local cNumArq  	:= ''
Local cHistor  	:= ''
Local cT0OId    := ''
Local cEvtRur	:= ''

Default nFolder := 1
Default aItemsEvt := {}

if len( aPer ) > 0
	cIniPer := DtoS(CTod(aPer[1]))
	cFimPer := DtoS(CTod(aPer[2]))
endif

oExcel:AddworkSheet(cAbaDet)
oExcel:AddTable(cAbaDet,cTabDet)
oExcel:SetHeaderBold(.T.)

oExcel:AddColumn(cAbaDet,cTabDet,STR0206,1,1) //01 "Filial"
oExcel:AddColumn(cAbaDet,cTabDet,STR0194,1,1) //02 "Conta Contab."
oExcel:AddColumn(cAbaDet,cTabDet,STR0195,1,1) //03 "Natureza Conta"
oExcel:AddColumn(cAbaDet,cTabDet,STR0196,1,1) //04 "Opera��o"
oExcel:AddColumn(cAbaDet,cTabDet,STR0197,1,1) //05 "Tipo"
oExcel:AddColumn(cAbaDet,cTabDet,STR0198,1,1) //06 "Data Lan�amento"
oExcel:AddColumn(cAbaDet,cTabDet,STR0199,1,1) //07 "C�digo Lan�amento"
oExcel:AddColumn(cAbaDet,cTabDet,STR0200,1,1) //08 "Indicador Lan�amento"
oExcel:AddColumn(cAbaDet,cTabDet,STR0201,3,2) //09 "Valor Partida"
oExcel:AddColumn(cAbaDet,cTabDet,STR0202,1,1) //10 "Indicador Natureza Partida"
oExcel:AddColumn(cAbaDet,cTabDet,STR0203,1,1) //11 "C�digo Centro de Custo"
oExcel:AddColumn(cAbaDet,cTabDet,STR0204,1,1) //12 "Numero Arquivo"

if cSGBD $ "MSSQL7|MSSQL|ORACLE|POSTGRES"
	oExcel:AddColumn(cAbaDet,cTabDet,STR0205,1,1) //13 "Hist�rico Padr�o"
endif


cT0OId := "'" + Right( aItemsEvt[nFolder],36) + "'"
//Verifica se existe atividade rural no evento principal
cEvtRur := TafVerRur(aItemsEvt[nFolder])
If !Empty(cEvtRur)
	cT0OId += ",'" + cEvtRur + "'"
EndIf	
cQuery := TafLctCtb( cIniPer, cFimPer, cT0OId, cSGBD )

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQry, .F., .T. )
( cAliasQry )->( DbGoTop() )

While ( cAliasQry )->( !Eof() )
	//1
	cFilCta  := Alltrim((cAliasQry)->C1E_FILTAF)
	//2
	cConta   := Alltrim((cAliasQry)->C1O_CODIGO) + ' - ' + Alltrim((cAliasQry)->C1O_DESCRI)
	//3
	cNatCt   := X3Combo("C1O_NATURE",(cAliasQry)->C1O_NATURE)
	//4
	cOp      := X3Combo("T0O_OPERAC",(cAliasQry)->T0O_OPERAC)
	//5
	cTipoCC  := X3Combo("T0O_TIPOCC",(cAliasQry)->T0O_TIPOCC)
	//6
	cDtLanc  := Stod( (cAliasQry)->CFS_DTLCTO )
	//7
	cCodLan  := Alltrim((cAliasQry)->CFS_NUMLCT)
	//8
	cIndLan  := X3Combo("CFS_INDLCT",(cAliasQry)->CFS_INDLCT)
	//9
	nVlrPart := (cAliasQry)->CHB_VLPART
	//10
	cIndNat  := X3Combo("CHB_INDNAT",(cAliasQry)->CHB_INDNAT)
	//11
	cCCCus   := Alltrim( (cAliasQry)->CHB_CODCUS ) + ' - ' + Alltrim( (cAliasQry)->C1P_CCUS )
	//12
	cNumArq  := Alltrim( (cAliasQry)->CHB_NUMARQ )
	//13
	cHistor  := Alltrim( (cAliasQry)->CHB_HISTOR )
	oExcel:AddRow(cAbaDet,cTabDet,{cFilCta,cConta,cNatCt,cOp,cTipoCC,cDtLanc,cCodLan,cIndLan,nVlrPart,cIndNat,cCCCus,cNumArq,cHistor})
	( cAliasQry )->( DbSkip() )
EndDo

(cAliasQry)->(DbCloseArea())

Return Nil

/*/{Protheus.doc} TafLctCtb
Consulta os lan�amentos cont�beis

@author Karen Honda / Denis Souza
@Since 10/06/2022
@Version 1.0
/*/
Static Function TafLctCtb( cIniPer, cFimPer, cT0OId, cSGBD )

Local cQuery 	 := ""
Local cIsNullSQL := ""

Local cCompC1O	 := Upper(AllTrim(FWModeAccess("C1O",1)+FWModeAccess("C1O",2)+FWModeAccess("C1O",3)))
Local cCompT0O	 := Upper(AllTrim(FWModeAccess("T0O",1)+FWModeAccess("T0O",2)+FWModeAccess("T0O",3)))
Local cCompC1P	 := Upper(AllTrim(FWModeAccess("C1P",1)+FWModeAccess("C1P",2)+FWModeAccess("C1P",3)))
Local aInfoEUF   := TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
Local cAtuEmp    := Iif(aInfoEUF[1]>0,SUBSTR(cFilAnt,1,aInfoEUF[1]),cFilAnt)

If cSGBD $ "MSSQL7|MSSQL"
	cIsNullSQL := "ISNULL"
ElseIf cSGBD $ "ORACLE"
	cIsNullSQL := "NVL"
ElseIf cSGBD $ "POSTGRES"
	cIsNullSQL := "ENCODE" //COALESCE
EndIf

cQuery += "SELECT "
cQuery += "C1E.C1E_FILTAF, C1O.C1O_CODIGO, C1O.C1O_DESCRI, C1O.C1O_NATURE, "
cQuery += "T0O.T0O_OPERAC, T0O.T0O_TIPOCC, "
cQuery += "CFS.CFS_DTLCTO, CFS.CFS_NUMLCT, CFS.CFS_INDLCT, "
cQuery += "CHB.CHB_VLPART, CHB.CHB_INDNAT, CHB.CHB_CODCUS, C1P.C1P_CCUS, CHB.CHB_NUMARQ, "

If cSGBD $ "MSSQL7|MSSQL"
	cQuery += cIsNullSQL + " (CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), CHB.CHB_HISTOR)),'') CHB_HISTOR "
ElseIf cSGBD $ "ORACLE"
	cQuery += cIsNullSQL + " (UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(CHB.CHB_HISTOR,2000,1)),'') CHB_HISTOR "
ElseIf cSGBD $ "POSTGRES"
	cQuery += cIsNullSQL + " (CHB.CHB_HISTOR,'escape') CHB_HISTOR "
EndIf

//Itens do Evento Tribut�rio
cQuery += "FROM " + RetSqlName( "T0O" ) + " T0O "

//Complemento Cadastral
cQuery += " INNER JOIN " + RetSqlName( "C1E" ) + " C1E ON "
cQuery += " C1E.C1E_CODFIL = T0O.T0O_FILITE "
cQuery += " AND C1E.C1E_ATIVO != '2' AND C1E.D_E_L_E_T_= ' ' "

//Plano de Contas Cont�beis
cQuery += "INNER JOIN " + RetSqlName( "C1O" ) + " C1O ON "

If cCompC1O == "EEE" //exclusivo
	cQuery += " C1O.C1O_FILIAL = C1E.C1E_FILTAF "
ElseIf cCompC1O == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 .And. !(cSGBD $ "INFORMIX|ORACLE") //filial compartilhada EEC
	cQuery += " SUBSTRING(C1O.C1O_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(C1E.C1E_FILTAF, 1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") " 
ElseIf cCompC1O == "ECC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 .And. !(cSGBD $ "INFORMIX|ORACLE") //unidade + filial compartilhada ECC 
	cQuery += " SUBSTRING(C1O.C1O_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(C1E.C1E_FILTAF, 1," + cValToChar(aInfoEUF[1]) + ") "
ElseIf cCompC1O == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 .And. cSGBD $ "INFORMIX|ORACLE" //filial compartilhada EEC
	cQuery += " SUBSTR(C1O.C1O_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTR(C1E.C1E_FILTAF, 1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") " 
ElseIf cCompC1O == "ECC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 .And. cSGBD $ "INFORMIX|ORACLE" //unidade + filial compartilhada ECC 
	cQuery += " SUBSTR(C1O.C1O_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTR(C1E.C1E_FILTAF, 1," + cValToChar(aInfoEUF[1]) + ") "
Else
	cQuery += " C1O.C1O_FILIAL ='" + xFilial("C1O") + "' "
EndIf

cQuery += "AND C1O.C1O_ID = T0O.T0O_IDCC "
cQuery += "AND C1O.C1O_INDCTA = '1' "
cQuery += "AND C1O.C1O_DTCRIA <= '" + cFimPer + "' "
cQuery += "AND C1O.D_E_L_E_T_ = ' ' "

//Partidas do Lan�amento
cQuery += "INNER JOIN " + RetSqlName( "CHB" ) + " CHB ON "
cQuery += "CHB.CHB_FILIAL = C1E.C1E_FILTAF "
cQuery += "AND CHB.CHB_CODCTA = C1O.C1O_ID AND CHB.D_E_L_E_T_= ' ' "

//Lan�amentos Cont�beis
cQuery += "INNER JOIN " + RetSqlName( "CFS" ) + " CFS ON "
cQuery += "CFS.CFS_FILIAL = C1E.C1E_FILTAF "
cQuery += "AND CFS.CFS_ID = CHB.CHB_ID "
cQuery += "AND CFS.CFS_DTLCTO BETWEEN '" + cIniPer + "' AND '" + cFimPer + "' AND CFS.D_E_L_E_T_= ' ' "

//Centro de Custo
cQuery += "LEFT JOIN " + RetSqlName( "C1P" ) + " C1P ON "

If cCompC1P == "EEE" //exclusivo
	cQuery += " C1P.C1P_FILIAL = C1E.C1E_FILTAF "
ElseIf cCompC1P == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 .And. !(cSGBD $ "INFORMIX|ORACLE") //filial compartilhada EEC
	cQuery += " SUBSTRING(C1P.C1P_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(C1E.C1E_FILTAF, 1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") " 
ElseIf cCompC1P == "ECC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 .And. !(cSGBD $ "INFORMIX|ORACLE") //unidade + filial compartilhada ECC 
	cQuery += " SUBSTRING(C1P.C1P_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(C1E.C1E_FILTAF, 1," + cValToChar(aInfoEUF[1]) + ") "
ElseIf cCompC1P == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 .And. cSGBD $ "INFORMIX|ORACLE" //filial compartilhada EEC
	cQuery += " SUBSTR(C1P.C1P_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTR(C1E.C1E_FILTAF, 1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") " 
ElseIf cCompC1P == "ECC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 .And. cSGBD $ "INFORMIX|ORACLE" //unidade + filial compartilhada ECC 
	cQuery += " SUBSTR(C1P.C1P_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTR(C1E.C1E_FILTAF, 1," + cValToChar(aInfoEUF[1]) + ") "
Else
	cQuery += " C1P.C1P_FILIAL = '" + xFilial("C1P") + "' "
EndIf

cQuery += "AND C1P.C1P_ID = CHB.CHB_CODCUS AND C1P.D_E_L_E_T_ = ' ' "

cQuery += "WHERE "
//Regra: Lan�amentos que est�o configurados com a natureza da partida igual a D�bito 
//e contas cont�beis configuradas no evento tribut�rio como cr�dito (ou vice-versa) 
//n�o devem ser apresentados no relat�rio, pois eles n�o ser�o trazidos na apura��o.

cQuery += "(CASE WHEN T0O.T0O_TIPOCC IN ('1','2') THEN CHB.CHB_INDNAT ELSE T0O.T0O_TIPOCC END) = T0O.T0O_TIPOCC "
if at( "," , cT0OId  ) > 0
	cQuery += " AND T0O.T0O_ID IN ( " + cT0OId + " ) "
else
	cQuery += " AND T0O.T0O_ID = " + cT0OId
endif

If cCompT0O <> "CCC" //Se for exclusivo pelo menos por empresa, o campo CHB_FILIAL ficar� preenchido.
	If aInfoEUF[1] > 0 .And. !(cSGBD $ "INFORMIX|ORACLE")
		cQuery += " AND SUBSTRING(T0O.T0O_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = '" + cAtuEmp + "'" 
	ElseIf aInfoEUF[1] > 0  .And. cSGBD $ "INFORMIX|ORACLE" 
		cQuery += " AND SUBSTR(T0O.T0O_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = '" + cAtuEmp + "'"
	Endif
Else
	cQuery += " AND T0O.T0O_FILIAL = '" + xFilial("T0O") + "' "
EndIf

cQuery += "AND T0O.D_E_L_E_T_= ' ' "

cQuery += " ORDER BY C1O.C1O_CODIGO, C1E.C1E_FILTAF, CHB.CHB_INDNAT "

Return cQuery

/*/{Protheus.doc} TafVerRur
Consulta se existe atividade rural no evento tributario

@author Karen Honda / Denis Souza
@Since 10/06/2022
@Version 1.0
/*/
Static Function TafVerRur( cChaveT0N )
Local cChave as Character
Local aArea as Array

aArea := GetArea()
DbSelectArea("T0N")
T0N->( DbSetOrder(1)) //T0N_FILIAL, T0N_ID
If T0N->( DBSeek(cChaveT0N) )
	cChave := T0N->T0N_IDEVEN
EndIf
RestArea(aArea)
Return cChave
