#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA027.CH"

//Modelos de Documento de Arrecadação
#DEFINE MODELO_DA_ESTADUAL	"0"
#DEFINE MODELO_GNRE			"1"
#DEFINE MODELO_DARF			"2"

//Status do Pagamento da Guia
#DEFINE STATUS_EM_ABERTO	"1"
#DEFINE STATUS_PAGO		"2"

Static aCmpsAlts	:=	{}

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA027

Cadastro MVC de Documento de Arrecadação.

@Author	Fabio V. Santana
@Since		10/07/2012
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAFA027()

Local oBrw	as object

oBrw	:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Cadastro de Documento de Arrecadação"
oBrw:SetAlias( "C0R" )
oBrw:SetCacheView( .F. )
oBrw:SetMenuDef( "TAFA027" )
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Função genérica MVC com as opções de menu.

@Author		Fabio V. Santana
@Since		10/07/2012
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao	as array
Local aRotina	as array

aFuncao	:=	{}
aRotina	:=	{}

aAdd( aFuncao, { "", "TAF027Vld", "2" } )
aAdd( aFuncao, { STR0006, "TAF027Pre( 'Baixa/Estorno', 'TAF027Bxa' )" } ) //"Baixa/Estorno"

aRotina := xFunMnuTAF( "TAFA027",, aFuncao )

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF027Pre

Executa pré-condições para a operação desejada.

@Param		cOper	-	Indica a operação a ser executada
			cRotina	-	Indica a rotina a ser executada

@Author		Felipe C. Seolin
@Since		28/03/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAF027Pre( cOper, cRotina )

Local nOperation	as numeric

Default cRotina		:=	"TAFA027"

nOperation		:=	MODEL_OPERATION_VIEW

//De-Para de opções do Menu para a operações em MVC
If Upper( cOper ) $ Upper( "|Baixa/Estorno|" )
	nOperation := 0
EndIf

lAutomato := IsBlind()

If Upper( cOper ) $ ( Upper( "|Baixa/Estorno|" ) )
	If TAFColumnPos( "C0R_VLPAGO" ) .and. TAFColumnPos( "C0R_STPGTO" )
		&cRotina.(lAutomato)
	Else
		MsgInfo( TafAmbInvMsg() )
	EndIf
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Função genérica MVC do Model.

@Return	oModel	- Objeto do modelo MVC

@Author	Fabio V. Santana
@Since		10/07/2012
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruC0R	as object
Local oStruC6Q	as object
Local oModel		as object

oStruC0R	:=	FWFormStruct( 1, "C0R" )
oStruC6Q	:=	FWFormStruct( 1, "C6Q" )
oModel		:=	MPFormModel():New( "TAFA027",, { |oModel| ValidModel( oModel ) }, { |oModel| SaveModel( oModel ) } )

aCmpsAlts := {}

oModel:AddFields( "MODEL_C0R", /*cOwner*/, oStruC0R )
oModel:GetModel( "MODEL_C0R" ):SetPrimaryKey( { "C0R_PERIOD", "C0R_UF", "C0R_CODDA", "C0R_NUMDA" } )

oModel:AddGrid( "MODEL_C6Q", "MODEL_C0R", oStruC6Q )
oModel:GetModel( "MODEL_C6Q" ):SetUniqueLine( { "C6Q_CODIGO" } )
oModel:GetModel( "MODEL_C6Q" ):SetOptional( .T. )

oModel:SetRelation( "MODEL_C6Q", { { "C6Q_FILIAL", "xFilial( 'C6Q' )" }, { "C6Q_ID", "C0R_ID" } }, C6Q->( IndexKey( 1 ) ) )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Função genérica MVC da View.

@Return	oView	- Objeto da view MVC

@Author	Fabio V. Santana
@Since		10/07/2012
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel		as object
Local oStruC0R	as object
Local oStruC6Q	as object
Local oView		as object
Local cModelo		as character
Local cOrdem		as character
Local nI			as numeric
Local aGrpArrec	as array
Local aGrpBanc	as array
Local aGrpComp	as array

oModel		:=	FWLoadModel( "TAFA027" )
oStruC0R	:=	FWFormStruct( 2, "C0R" )
oStruC6Q	:=	FWFormStruct( 2, "C6Q" )
oView		:=	FWFormView():New()
cModelo	:=	""
cOrdem		:=	"02"
nI			:=	0
aGrpArrec	:=	{ "C0R_ID", "C0R_CODDA", "C0R_PERIOD", "C0R_UF", "C0R_DUF", "C0R_NUMDA", "C0R_DESDOC", "C0R_VLRPRC","C0R_ATUMON", "C0R_JUROS", "C0R_MULTA", "C0R_VLDESC", "C0R_VLCOMP", "C0R_VLDA", "C0R_VLPAGO", "C0R_STPGTO", "C0R_DTVCT", "C0R_DTPGT", "C0R_CODREC", "C0R_DCODRE", "C0R_TPREC", "C0R_TPIMPO", "C0R_NRPROC", "C0R_DNRPRO" }
aGrpBanc	:=	{ "C0R_CODAUT", "C0R_CODBAN", "C0R_DCODBA", "C0R_CODAGE", "C0R_DIGAGE", "C0R_NUMCC", "C0R_VLDEV", "C0R_VLRES" }
If TamSX3("C0R_CDPART")[1] == 36
	aGrpComp	:=	{ "C0R_DETREC", "C0R_DDETRE", "C0R_CODPRD", "C0R_DCODPR", "C0R_TIPDOC", "C0R_DTIPDO", "C0R_DOCORI", "C0R_CONVEN", "C0R_NUMPAR", "C0R_REFERE", "C0R_CPARTI", "C0R_DCDPAR", "C0R_CODOBR", "C0R_DCODOB" }
Else
	aGrpComp	:=	{ "C0R_DETREC", "C0R_DDETRE", "C0R_CODPRD", "C0R_DCODPR", "C0R_TIPDOC", "C0R_DTIPDO", "C0R_DOCORI", "C0R_CONVEN", "C0R_NUMPAR", "C0R_REFERE", "C0R_CDPART", "C0R_DCDPAR", "C0R_CODOBR", "C0R_DCODOB" }
EndIf

//Tratamento para diferenciar a inclusão das outras manutenções
If ( Type( "INCLUI" ) <> "U" ) .and. INCLUI .and. AllTrim( FunName() ) == "TAFA027"
	Perg027()
	cModelo := MV_PAR01
Else
	cModelo := C0R->C0R_CODDA
EndIf

oView:SetModel( oModel )

oStruC0R:AddGroup( "GRP_ARRECADACAO", STR0002, "", 1 ) //"Informações do Documento de Arrecadação"
oStruC0R:AddGroup( "GRP_COMPLEMENTO", STR0003, "", 1 ) //"Informações Complementares para a emissão da GNRE Online"
oStruC0R:AddGroup( "GRP_BANCARIA", STR0005, "", 1 ) //"Informações Bancárias"

For nI := 1 to Len( aGrpArrec )
	If TAFColumnPos( aGrpArrec[nI] ) .or.;
	( aGrpArrec[nI] == "C0R_DUF" .and. TAFColumnPos( "C0R_UF" ) ) .or.;
	( aGrpArrec[nI] == "C0R_DCODRE" .and. TAFColumnPos( "C0R_CODREC" ) ) .or.;
	( aGrpArrec[nI] == "C0R_DNRPRO" .and. TAFColumnPos( "C0R_NRPROC" ) )
		oStruC0R:SetProperty( aGrpArrec[nI], MVC_VIEW_GROUP_NUMBER, "GRP_ARRECADACAO" )
		oStruC0R:SetProperty( aGrpArrec[nI], MVC_VIEW_ORDEM, cOrdem )
		cOrdem := StrZero( Val( cOrdem ) + 1, 2 )
	EndIf
Next nI

For nI := 1 to Len( aGrpBanc )
	If TAFColumnPos( aGrpBanc[nI] ) .or.;
	( aGrpBanc[nI] == "C0R_DCODBA" .and. TAFColumnPos( "C0R_CODBAN" ) )
		oStruC0R:SetProperty( aGrpBanc[nI], MVC_VIEW_GROUP_NUMBER, "GRP_BANCARIA" )
		oStruC0R:SetProperty( aGrpBanc[nI], MVC_VIEW_ORDEM, cOrdem )
		cOrdem := StrZero( Val( cOrdem ) + 1, 2 )
	EndIf
Next nI

For nI := 1 to Len( aGrpComp )
	If TAFColumnPos( aGrpComp[nI] ) .or.;
	( aGrpComp[nI] == "C0R_DDETRE" .and. TAFColumnPos( "C0R_DETREC" ) ) .or.;
	( aGrpComp[nI] == "C0R_DCODPR" .and. TAFColumnPos( "C0R_CODPRD" ) ) .or.;
	( aGrpComp[nI] == "C0R_DTIPDO" .and. TAFColumnPos( "C0R_TIPDOC" ) ) .or.;
	( aGrpComp[nI] == "C0R_CPARTI" .and. TAFColumnPos( "C0R_CDPART" ) ) .or.;	
	( aGrpComp[nI] == "C0R_DCDPAR" .and. TAFColumnPos( "C0R_CDPART" ) ) .or.;	
	( aGrpComp[nI] == "C0R_DCODOB" .and. TAFColumnPos( "C0R_CODOBR" ) )	
	
		oStruC0R:SetProperty( aGrpComp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_COMPLEMENTO" )
		oStruC0R:SetProperty( aGrpComp[nI], MVC_VIEW_ORDEM, cOrdem )
		cOrdem := StrZero( Val( cOrdem ) + 1, 2 )
	EndIf	
		
Next nI

oView:AddField( "VIEW_C0R", oStruC0R, "MODEL_C0R" )
oView:EnableTitleView( "VIEW_C0R", STR0001 ) //"Cadastro de Documento de Arrecadação"

If cModelo == MODELO_DARF

	oStruC0R:RemoveField( "C0R_UF" )
	oStruC0R:RemoveField( "C0R_DUF" )
	oStruC0R:RemoveField( "C0R_TPREC" )
	oStruC0R:RemoveField( "C0R_TPIMPO" )
	oStruC0R:RemoveField( "C0R_NRPROC" )
	oStruC0R:RemoveField( "C0R_DNRPRO" )

	For nI := 1 to Len( aGrpBanc )
		If TAFColumnPos( aGrpBanc[nI] ) .or.;
		( aGrpBanc[nI] == "C0R_DCODBA" .and. TAFColumnPos( "C0R_CODBAN" ) )
			oStruC0R:RemoveField( aGrpBanc[nI] )
		EndIf
	Next nI

	For nI := 1 to Len( aGrpComp )
		If TAFColumnPos( aGrpComp[nI] ) .or.;
		( aGrpComp[nI] == "C0R_DDETRE" .and. TAFColumnPos( "C0R_DETREC" ) ) .or.;
		( aGrpComp[nI] == "C0R_DCODPR" .and. TAFColumnPos( "C0R_CODPRD" ) ) .or.;
		( aGrpComp[nI] == "C0R_DTIPDO" .and. TAFColumnPos( "C0R_TIPDOC" ) ) .or.;
		( aGrpComp[nI] == "C0R_DCDPAR" .and. TAFColumnPos( "C0R_CPARTI" ) ) .or.;
		( aGrpComp[nI] == "C0R_DCODOB" .and. TAFColumnPos( "C0R_CODOBR" ) )
			oStruC0R:RemoveField( aGrpComp[nI] )
		EndIf
	Next nI

	oView:CreateHorizontalBox( "FIELDSC0R", 100 )

	oView:SetOwnerView( "VIEW_C0R", "FIELDSC0R" )
Else
	oView:AddGrid( "VIEW_C6Q", oStruC6Q, "MODEL_C6Q" )

	oView:CreateHorizontalBox( "FIELDSC0R", 70 )
	oView:CreateHorizontalBox( "PANFOLDER1", 30 )

	oView:CreateFolder( "FOLDER1", "PANFOLDER1" )
	oView:AddSheet( "FOLDER1", "ABA01", STR0004 ) //"Campos Extras ( GNRE Online )"
	oView:CreateHorizontalBox( "GRIDC6Q", 100,,, "FOLDER1", "ABA01" )

	oView:SetOwnerView( "VIEW_C0R", "FIELDSC0R" )
	oView:SetOwnerView( "VIEW_C6Q", "GRIDC6Q" )
EndIf

If TamSX3("C0R_CDPART")[1] == 36
	oStruC0R:RemoveField("C0R_CDPART")		
EndIf  

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel

Função de validação da inclusão dos dados, chamada
no final, no momento da gravação do modelo.

@Param		oModel	- Modelo de dados

@Return	.T. ou .F.

@Author	Gustavo G. Rueda
@Since		01/08/2012
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ValidModel( oModel )

Local nOperation	as numeric

nOperation	:=	oModel:GetOperation()

Return( xFunReflex( nOperation, aCmpsAlts, "TAFA027" ) )

//-------------------------------------------------------------------
/*/{Protheus.doc} A027LogAlt

Função utilizada para atualizar uma variável STATIC tratada no SAVE
no modelo. Tratamento passado por framework para podermos identificar
os campos alterados no modelo para podermos exibir alguns alertas.

@Return	.T.

@Author	Gustavo G. Rueda
@Since		01/08/2012
@Version	1.0
/*/
//-------------------------------------------------------------------
Function A027LogAlt()

If ValType( aCmpsAlts ) == "A" .and. aScan( aCmpsAlts, ReadVar() ) == 0
	aAdd( aCmpsAlts, ReadVar() )
EndIf

Return( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel

Função de gravação dos dados, chamada no
final, no momento da confirmação do modelo.

@Param		oModel	- Modelo de dados

@Return	.T.

@Author	Anderson Costa
@Since		28/04/2014
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation	as numeric

nOperation	:=	oModel:GetOperation()

Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
		TAFAltStat( "C0R", " " )
	EndIf

	FWFormCommit( oModel )

End Transaction

Return( .T. )

//---------------------------------------------------------------------
/*/{Protheus.doc} Perg027

Tela de entrada de dados prévia a interface cadastral.

@Return	lRet	- Indica se todas as condições foram respeitadas

@Author	Felipe C. Seolin
@Since		12/09/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function Perg027()

Local oDlg			as object
Local oFont		as object
Local cTitModelo	as character
Local nLarguraBox	as numeric
Local nAlturaBox	as numeric
Local nLarguraSay	as numeric
Local nTop			as numeric
Local nAltura		as numeric
Local nLargura	as numeric
Local nPosIni		as numeric
Local aModelos	as array

oDlg			:=	Nil
oFont			:=	Nil
cTitModelo		:=	Eval( { || SX3->( DBSetOrder( 2 ) ), SX3->( MsSeek( "C0R_CODDA" ) ), X3Titulo() } )
nLarguraBox	:=	0
nAlturaBox		:=	0
nLarguraSay	:=	0
nTop			:=	0
nAltura		:=	180
nLargura		:=	300
nPosIni		:=	0
aModelos		:=	{}

SX3->( DBSetOrder( 2 ) )
If SX3->( MsSeek( "C0R_CODDA" ) ) 
	aModelos := StrToKarr( X3Cbox(), ";" )
EndIf

aSize( aModelos, Len( aModelos ) + 1 )
aIns( aModelos, 1 )
aModelos[1] := ""

oFont := TFont():New( "Arial",, -11 )

oDlg := MsDialog():New( 0, 0, nAltura, nLargura, STR0007,,,,,,,,, .T. ) //"Parâmetros"

nAlturaBox := ( nAltura - 60 ) / 2
nLarguraBox := ( nLargura - 20 ) / 2

@10,10 to nAlturaBox,nLarguraBox of oDlg Pixel

MV_PAR01 := Space( 1 )

nLarguraSay := nLarguraBox - 30
nTop := 20
TComboBox():New( nTop, 20, { |x| If( PCount() == 0, MV_PAR01, MV_PAR01 := x ) }, aModelos, 65, 10, oDlg,, { || oDlg:Refresh() }, { || ValidPerg( 1 ) },,, .T.,,,,,,,,,, cTitModelo, 1, oFont )
nTop += 10

nPosIni := ( ( nLargura - 20 ) / 2 ) - 32

SButton():New( nAlturaBox + 10, nPosIni, 1, { |x| Iif( VldPergOk(), x:oWnd:End(), ) }, oDlg )

oDlg:Activate( ,,,.T. )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} VldPergOk

Validação do botão para confirmar a entrada de todos
os dados dos parâmetros prévios a interface cadastral.

@Return	lRet	- Indica se todas as condições foram respeitadas

@Author	Felipe C. Seolin
@Since		12/09/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function VldPergOk()

Local lRet	as logical

lRet	:=	.T.

If !(	ValidPerg( 1 ) )
	lRet := .F.
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidPerg

Validação da entrada de dados prévia a interface cadastral.

@Param		nOpc	- Indica a opção de validação a ser executada

@Return	lRet	- Indica se todas as condições foram respeitadas

@Author	Felipe C. Seolin
@Since		12/09/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ValidPerg( nOpc )

Local cModelos	as character
Local nI			as numeric
Local aModelos	as array
Local lRet			as logical

cModelos	:=	""
nI			:=	0
aModelos	:=	{}
lRet			:=	.T.

SX3->( DBSetOrder( 2 ) )
If SX3->( MsSeek( "C0R_CODDA" ) ) 
	aModelos := StrToKarr( X3Cbox(), ";" )
EndIf

For nI := 1 to Len( aModelos )
	cModelos += SubStr( aModelos[nI], 1, At( "=", aModelos[nI] ) - 1 ) + "|"
Next nI

If nOpc == 1

	If Empty( MV_PAR01 )
		MsgInfo( STR0008 ) //"Modelo de Documento de Arrecadação não informado."
		lRet := .F.
	ElseIf !( MV_PAR01 $ cModelos )
		MsgInfo( STR0009 ) //"Conteúdo inválido selecionado para Modelo de Documento de Arrecadação."
		lRet := .F.
	EndIf

EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF027Init

Função para atribuição da propriedade de inicialização padrão do campo.

@Return	cInit	- Conteúdo da inicialização padrão do campo

@Author	Felipe C. Seolin
@Since		12/09/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAF027Init()

Local cCampo	as character
Local cInit	as character

cCampo	:=	SubStr( ReadVar(), At( ">", ReadVar() ) + 1 )
cInit	:=	""

If cCampo == "C0R_CODDA"
	cInit := MV_PAR01
ElseIf cCampo == "C0R_STPGTO"
	cInit := STATUS_EM_ABERTO
ElseIf cCampo == "C0R_DCODRE"
	cInit := Iif( !INCLUI .and. !Empty( C0R->C0R_CODREC ), Posicione( "C6R", 3, xFilial( "C6R" ) + C0R->C0R_CODREC, "AllTrim( C6R_CODIGO ) + ' - ' + AllTrim( C6R_DESCRI )" ), "" )
EndIf

If !Empty( cInit ) .and. AllTrim( cInit ) == "-"
	cInit := ""
EndIf

Return( cInit )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF027Trig

Função para atribuição do gatilho do campo.

@Return	cTrigger	- Conteúdo do gatilho do campo

@Author	Felipe C. Seolin
@Since		13/09/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAF027Trig( cDestino )

Local cCampo		as character
Local cTrigger	as character

cCampo		:=	SubStr( ReadVar(), At( ">", ReadVar() ) + 1 )
cTrigger	:=	""

If cCampo == "C0R_VLRPRC" .and. cDestino == "C0R_VLDA"
	cTrigger := M->C0R_VLRPRC + FWFldGet( "C0R_MULTA" ) + FWFldGet( "C0R_JUROS" ) + FWFldGet( "C0R_ATUMON" ) - FWFldGet( "C0R_VLDESC" ) - FWFldGet( "C0R_VLCOMP" )
ElseIf cCampo == "C0R_ATUMON" .and. cDestino == "C0R_VLDA"
	cTrigger := FWFldGet( "C0R_VLRPRC" ) + FWFldGet( "C0R_MULTA" ) + FWFldGet( "C0R_JUROS" ) + M->C0R_ATUMON - FWFldGet( "C0R_VLDESC" ) - FWFldGet( "C0R_VLCOMP" )
ElseIf cCampo == "C0R_JUROS" .and. cDestino == "C0R_VLDA"
	cTrigger := FWFldGet( "C0R_VLRPRC" ) + FWFldGet( "C0R_MULTA" ) + M->C0R_JUROS + FWFldGet( "C0R_ATUMON" ) - FWFldGet( "C0R_VLDESC" ) - FWFldGet( "C0R_VLCOMP" )
ElseIf cCampo == "C0R_MULTA" .and. cDestino == "C0R_VLDA"
	cTrigger := FWFldGet( "C0R_VLRPRC" ) + M->C0R_MULTA + FWFldGet( "C0R_JUROS" ) + FWFldGet( "C0R_ATUMON" ) - FWFldGet( "C0R_VLDESC" ) - FWFldGet( "C0R_VLCOMP" )
ElseIf cCampo == "C0R_VLDESC" .and. cDestino == "C0R_VLDA"
	cTrigger := FWFldGet( "C0R_VLRPRC" ) + FWFldGet( "C0R_MULTA" ) + FWFldGet( "C0R_JUROS" ) + FWFldGet( "C0R_ATUMON" ) - M->C0R_VLDESC - FWFldGet( "C0R_VLCOMP" )
ElseIf cCampo == "C0R_VLCOMP" .and. cDestino == "C0R_VLDA"
	cTrigger := FWFldGet( "C0R_VLRPRC" ) + FWFldGet( "C0R_MULTA" ) + FWFldGet( "C0R_JUROS" ) + FWFldGet( "C0R_ATUMON" ) - FWFldGet( "C0R_VLDESC" ) - M->C0R_VLCOMP
EndIf

Return( cTrigger )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF027Valid

Funcionalidade para validação do campo.

@Return	lRet	- Indica se todas as condições foram respeitadas

@Author	Felipe C. Seolin
@Since		12/09/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAF027Valid()

Local cCampo	as character
Local lRet		as logical

cCampo	:=	SubStr( ReadVar(), At( ">", ReadVar() ) + 1 )
lRet	:=	.T.

If cCampo == "C0R_VLDA"

	If FWFldGet( "C0R_VLRPRC" ) + FWFldGet( "C0R_MULTA" ) + FWFldGet( "C0R_JUROS" ) + FWFldGet( "C0R_ATUMON" ) - FWFldGet( "C0R_VLDESC" ) - FWFldGet( "C0R_VLCOMP" ) <> M->C0R_VLDA
		Help( ,, "HELP",, STR0010, 1, 0 ) //"'Valor DA' difere da soma de 'Vl.Principal' + 'Multa' + 'Juros' + 'Atual.Monet.' - 'Desconto' - 'Compensado'."
		lRet := .F.
	EndIf

EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF027Vld

Função que valida os dados do registro posicionado,
verificando se há inconsistências nas informações.

@Param		cAlias
			nRecno
			nOpc
			lJob	- Informa se foi chamado por Job

@Return	aLogErro

@Author	Anderson Costa
@Since		28/04/2014
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAF027Vld( cAlias, nRecno, nOpc, lJob )

Local cStatus		as character
Local cChave		as character
Local cC6QKey		as character
Local aLogErro	as array

Default lJob	:=	.F.

cStatus	:=	""
cChave		:=	""
cC6QKey	:=	""
aLogErro	:=	{}

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C0R->( Recno() )

If C0R->C0R_STATUS $ ( " |1" )

	//---------------------
	// Campos obrigatórios
	//---------------------
	If Empty( C0R->C0R_PERIOD )
		aAdd( aLogErro, { "C0R_PERIOD", "000010", "C0R", nRecno } ) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty( C0R->C0R_CODDA )
		aAdd( aLogErro,{ "C0R_CODDA", "000010", "C0R", nRecno } ) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty( C0R->C0R_DESDOC )
		aAdd( aLogErro, { "C0R_DESDOC", "000010", "C0R", nRecno } ) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty( C0R->C0R_VLRPRC )
		aAdd( aLogErro,{ "C0R_VLRPRC", "000010", "C0R", nRecno } ) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty( C0R->C0R_VLDA )
		aAdd( aLogErro, { "C0R_VLDA", "000010", "C0R", nRecno } ) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty( C0R->C0R_DTVCT )
		aAdd( aLogErro, { "C0R_DTVCT", "000010", "C0R", nRecno } ) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty( C0R->C0R_CODREC )
		aAdd( aLogErro, { "C0R_CODREC", "000010", "C0R", nRecno } ) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	//------------------
	// Consultas padrão
	//------------------
	If !Empty( C0R->C0R_UF )
		//Chave de busca na Tabela Filho ou Consulta Padrão
		cChave := C0R->C0R_UF
		xValRegTab( "C09", cChave, 3,, @aLogErro,, { "C0R", "C0R_UF", nRecno } )
	EndIf

	If !Empty( C0R->C0R_CODREC )
		//Chave de busca na Tabela Filho ou Consulta Padrão
		cChave := C0R->C0R_CODREC
		xValRegTab( "C6R", cChave, 3,, @aLogErro,, { "C0R", "C0R_CODREC", nRecno } )
	EndIf

	If !Empty( C0R->C0R_DETREC )
		//Chave de busca na Tabela Filho ou Consulta Padrão
		cChave := C0R->C0R_DETREC
		xValRegTab( "C6S", cChave, 3,, @aLogErro,, { "C0R", "C0R_DETREC", nRecno } )
	EndIf

	If !Empty( C0R->C0R_CODPRD )
		//Chave de busca na Tabela Filho ou Consulta Padrão
		cChave := C0R->C0R_CODPRD
		xValRegTab( "C6U", cChave, 3,, @aLogErro,, { "C0R", "C0R_CODPRD", nRecno } )
	EndIf

	If !Empty( C0R->C0R_TIPDOC )
		//Chave de busca na Tabela Filho ou Consulta Padrão
		cChave := C0R->C0R_TIPDOC
		xValRegTab( "C6T", cChave, 3,, @aLogErro,, { "C0R", "C0R_TIPDOC", nRecno } )
	EndIf

	If !Empty( C0R->C0R_CDPART )
		//Chave de busca na Tabela Filho ou Consulta Padrão
		cChave := C0R->C0R_CDPART
		xValRegTab( "C1H", cChave, 5,, @aLogErro,, { "C0R", "C0R_CDPART", nRecno } )
	EndIf

	If !Empty( C0R->C0R_CODBAN )
		//Chave de busca na Tabela Filho ou Consulta Padrão
		cChave := C0R->C0R_CODBAN
		xValRegTab( "C1V", cChave, 3,, @aLogErro,, { "C0R", "C0R_CODBAN", nRecno } )
	EndIf

	//--------
	// Combos
	//--------
	If !C0R->C0R_CODDA $ ( "0|1|2" )
		aAdd( aLogErro, { "C0R_CODDA", "000006", "C0R", nRecno } ) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
	EndIf

	If !Empty( C0R->C0R_STPGTO ) .and. !C0R->C0R_STPGTO $ ( "1|2" )
		aAdd( aLogErro, { "C0R_STPGTO", "000006", "C0R", nRecno } ) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
	EndIf

	If !Empty( C0R->C0R_REFERE ) .and. !C0R->C0R_REFERE $ ( "0|1|2|3|4|5" )
		aAdd( aLogErro, { "C0R_REFERE", "000006", "C0R", nRecno } ) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
	EndIf

	//--------
	// Regras
	//--------
	If C0R->( C0R_VLRPRC + C0R_MULTA + C0R_JUROS + C0R_ATUMON - C0R_VLDESC - C0R_VLCOMP ) <> C0R->C0R_VLDA
		aAdd( aLogErro, { "C0R_VLDA", "000912", "C0R", nRecno } ) //STR0912 - "'Valor DA' difere da soma de 'Vl.Principal' + 'Multa' + 'Juros' + 'Atual.Monet.' - 'Desconto' - 'Compensado'."
	EndIf

	//Seto tabela para consulta
	C6Q->( DBSetOrder( 1 ) )

	cC6QKey := C0R->C0R_ID
	If C6Q->( MsSeek( xFilial( "C6Q" ) + cC6QKey ) )

		While C6Q->( !Eof() ) .and. cC6QKey == C6Q->C6Q_ID

			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty( C6Q->C6Q_CODIGO )
				aAdd( aLogErro, { "C6Q_CODIGO", "000010", "C0R", nRecno } ) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty( C6Q->C6Q_TIPO )
				aAdd( aLogErro, { "C6Q_TIPO", "000010", "C0R", nRecno } ) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty( C6Q->C6Q_VLRCMP )
				aAdd( aLogErro, { "C6Q_VLRCMP", "000010", "C0R", nRecno } ) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			C6Q->( DBSkip() )
		EndDo

	EndIf

	//Atualizo o Status do Registro
	cStatus := Iif( Len( aLogErro ) > 0, "1", "0" )
	TAFAltStat( "C0R", cStatus )

Else

	aAdd( aLogErro,{ "C0R_ID", "000305", "C0R", nRecno } ) //Registros que já foram transmitidos ao Fisco, não podem ser validados

EndIf

//Não apresento o Alert quando utilizo o Job para validar
If !lJob
	xValLogEr( aLogErro )
EndIf

Return( aLogErro )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF027Bxa

Funcionalidade para Baixa do Documento de Arrecadação.

@Author	Felipe C. Seolin
@Since		13/09/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAF027Bxa(lAutomato)

Local oDlg			as object
Local oFont		as object
Local nAlturaBox	as numeric
Local nLarguraBox	as numeric
Local nTop			as numeric
Local nAltura		as numeric
Local nLargura	as numeric
Local nPosIni		as numeric
Local cTitData	as character
Local cTitValor	as character
Local nValor		as numeric
Local dData		as date

Default lAutomato := .F.

oDlg			:=	Nil
oFont			:=	Nil
nAlturaBox		:=	0
nLarguraBox	:=	0
nTop			:=	0
nAltura		:=	180
nLargura		:=	380
nPosIni		:=	0
cTitData		:=	Eval( { || SX3->( DBSetOrder( 2 ) ), SX3->( MsSeek( "C0R_DTPGT" ) ), X3Titulo() } )
cTitValor		:=	Eval( { || SX3->( DBSetOrder( 2 ) ), SX3->( MsSeek( "C0R_VLPAGO" ) ), X3Titulo() } )
nValor			:=	0
dData			:=	SToD( "  /  /    " )

If Empty( C0R->C0R_STPGTO ) .or. C0R->C0R_STPGTO == STATUS_EM_ABERTO 

	If !lAutomato

		dData := dDataBase

		oFont := TFont():New( "Arial",, -11 )

		oDlg := MsDialog():New( 0, 0, nAltura, nLargura, STR0011,,,,,,,,, .T. ) //"Baixa"

		nAlturaBox := ( nAltura - 60 ) / 2
		nLarguraBox := ( nLargura - 20 ) / 2

		@10,10 to nAlturaBox,nLarguraBox of oDlg Pixel

		//Carrega como default o Valor do documento para o campo de valor pago no processo da baixa 
		nValor	:= C0R->C0R_VLDA

		nTop := 20
		TGet():New( nTop, 20, { |x| If( PCount() == 0, dData, dData := x ) }, oDlg, 65, 10,, { || ValidBxa( 1, dData ) },,,,,, .T.,,,,,,,,,, "dData",,,,,,, cTitData, 1, oFont )
		TGet():New( nTop, 90, { |x| If( PCount() == 0, nValor, nValor := x ) }, oDlg, 65, 10, PesqPict( "C0R", "C0R_VLPAGO" ), { || ValidBxa( 2, nValor ) },,,,,, .T.,,,,,,,,,, "nValor",,,,,,, cTitValor, 1, oFont )
		nTop += 20

		nPosIni := ( ( nLargura - 20 ) / 2 ) - 64
		SButton():New( nAlturaBox + 10, nPosIni, 1, { || Iif( ValidBxaOk( dData, nValor ), ( Processa( { || GravaBxa( dData, nValor, STATUS_PAGO ), STR0012, STR0013 } ), oDlg:End() ), "" ) }, oDlg ) //##"Processando" ##"Gravando Baixa"
		nPosIni += 32
		SButton():New( nAlturaBox + 10, nPosIni, 2, { || oDlg:End() }, oDlg )

		oDlg:Activate( ,,,.T. )
	Else
		dData := dDataBase
		nValor := C0R->C0R_VLDA
		GravaBxa( dData, nValor, STATUS_PAGO )
	Endif
ElseIf C0R->C0R_STPGTO == STATUS_PAGO
	If !lAutomato
	
		If Aviso( STR0014, STR0015, { STR0016, STR0017 }, 2 ) == 1 //##"Estorno" ##"O status atual da guia é 'Pago'. Deseja realizar o estorno desta operação?" ##"Sim" ##"Não"
			Processa( { || GravaBxa( dData, nValor, STATUS_EM_ABERTO ), STR0012, STR0018 } ) //##"Processando" ##"Gravando Estorno"
		EndIf
	Else
		dData  := SToD( "  /  /    " )
		nValor := 0
		GravaBxa( dData, nValor, STATUS_EM_ABERTO) 
	Endif
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidBxaOk

Validação do botão para confirmar a entrada de todos os dados dos
parâmetros da funcionalidade de baixa do documento de arrecadação.

@Param		dData	- Data de Pagamento
			nValor	- Valor Pago

@Return	lRet	- Indica se todas as condições foram respeitadas

@Author	Felipe C. Seolin
@Since		13/09/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ValidBxaOk( dData, nValor )

Local lRet	as logical

lRet	:=	.T.

If !(	ValidBxa( 1, dData ) .and.;
		ValidBxa( 2, nValor ) )
	lRet := .F.
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidBxa

Validação da entrada de dados dos parâmetros da
funcionalidade de baixa do documento de arrecadação.

@Param		nOpc		- Indica a opção de validação a ser executada
			xConteudo	- Conteúdo do campo a ser validado

@Return	lRet 		- Indica se todas as condições foram respeitadas

@Author	Felipe C. Seolin
@Since		13/09/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ValidBxa( nOpc, xConteudo )

Local cTitData	as character
Local cTitValor	as character
Local lRet			as logical

cTitData	:=	Eval( { || SX3->( DBSetOrder( 2 ) ), SX3->( MsSeek( "C0R_DTPGT" ) ), X3Titulo() } )
cTitValor	:=	Eval( { || SX3->( DBSetOrder( 2 ) ), SX3->( MsSeek( "C0R_VLPAGO" ) ), X3Titulo() } )
lRet		:=	.T.

If nOpc == 1

	If Empty( xConteudo )
		MsgInfo( STR0019 + " '" + AllTrim( cTitData ) + "' " + STR0022 ) //##O campo" ##"não foi informado."
		lRet := .F.
	EndIf

ElseIf nOpc == 2

	If xConteudo <= 0
		MsgInfo( STR0019 + " '" + AllTrim( cTitValor ) + "' " + STR0021 ) //##"O campo" ##"não pode ser preenchido com valor negativo ou zero."
		lRet := .F.
	EndIf

EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GravaBxa

Funcionalidade para gravar a baixa do documento de arrecadação.

@Param		dData		- Data de Pagamento
			nValor		- Valor Pago
			cStatus	- Status do Pagamento

@Author	Felipe C. Seolin
@Since		13/09/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function GravaBxa( dData, nValor, cStatus )

If RecLock( "C0R", .F. )
	C0R->C0R_DTPGT	:=	dData
	C0R->C0R_VLPAGO	:=	nValor
	C0R->C0R_STPGTO	:=	cStatus
	C0R->( MsUnlock() )
EndIf

MsgInfo( STR0020 ) //"Processo finalizado!"

Return()
