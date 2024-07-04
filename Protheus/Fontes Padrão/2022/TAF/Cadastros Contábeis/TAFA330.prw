#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA330.CH"

//------------------------------------------------------------------
/*/{Protheus.doc} TAFA330

Identificação da Conta na Parte B do e-Lalur e do e-Lacs

@Author		Evandro dos Santos Oliveira 
@Since		10/06/2014
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAFA330()

Local oBrowse	as object

oBrowse	:=	FWmBrowse():New()

oBrowse:SetDescription( STR0001 ) //"Identificação da Conta na Parte B do e-Lalur e do e-Lacs"
oBrowse:SetAlias( "CFR" )
oBrowse:SetCacheView( .F. )

CFR->( DBSetOrder( 2 ) )

oBrowse:SetMenuDef( "TAFA330" )
oBrowse:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Função genérica MVC com as opções de menu.

@Author		Evandro dos Santos Oliveira
@Since		10/06/2014
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao	as array
Local aRotina	as array

aFuncao	:=	{}
aRotina	:=	{}

aAdd( aFuncao, { "", "TAF330Vld", "2" } )
aAdd( aFuncao, { STR0004, "TAF330Cpy" } ) //"Cópia das Contas da Parte B do e-Lalur para e-Lacs"

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title STR0014 Action "VIEWDEF.TAFA330" OPERATION 2 ACCESS 0 //"Visualizar"
Else
	aRotina := xFunMnuTAF( "TAFA330",, aFuncao )
EndIf

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef

Função genérica MVC do Model

@Author		Evandro dos Santos Oliveira
@Since		10/06/2014
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel	as object
Local oStruCFR	as object

oModel		:=	MPFormModel():New( "TAFA330",, { |oModel| ValidModel( oModel ) }, { |oModel| SaveModel( oModel ) } )
oStruCFR	:=	FWFormStruct( 1, "CFR" )

lVldModel := IIf( Type( "lVldModel" ) == "U", .F., lVldModel )

If lVldModel
	oStruCFR:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
EndIf

oModel:AddFields( "MODEL_CFR", /*cOwner*/, oStruCFR )
oModel:GetModel( "MODEL_CFR" ):SetPrimaryKey( { "CFR_PERIOD", "CFR_CODCTA", "CFR_TRIBUT" } )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Função genérica MVC da View

@Return		oView - Objeto da View MVC

@Author		Evandro dos Santos Oliveira
@Since		10/06/2014
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel	as object
Local oView		as object
Local oStruCFR	as object

oModel		:=	FWLoadModel( "TAFA330" )
oView		:=	FWFormView():New()
oStruCFR	:=	FWFormStruct( 2, "CFR" )

//Tratamento para diferenciar a inclusão das outras manutenções
If ( Type( "INCLUI" ) <> "U" ) .and. INCLUI .and. AllTrim( FunName() ) == "TAFA330"
	Perg330()
EndIf

oView:SetModel( oModel )

oView:AddField( "VIEW_CFR", oStruCFR, "MODEL_CFR" )
oView:EnableTitleView( "VIEW_CFR", STR0001 ) //"Identificação da Conta na Parte B do e-Lalur e do e-Lacs"

oView:CreateHorizontalBox( "FIELDSCFR", 100 )

oView:SetOwnerView( "VIEW_CFR", "FIELDSCFR" )

oStruCFR:RemoveField( "CFR_ID" )
oStruCFR:RemoveField( "CFR_REGECF" )
oStruCFR:RemoveField( "CFR_IDCODL" )
If TAFColumnPos( "CFR_ORIGEM" )
	oStruCFR:RemoveField( "CFR_ORIGEM" )
EndIf
if aScan(oStruCFR:aFields,{ |x| x[1] == "CFR_IDCODP" }) > 0
	oStruCFR:RemoveField( "CFR_IDCODP" )
endif	

Return( oView )

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidModel

Validação dos dados, executado no momento da confirmação do modelo.

@Param		oModel	- Modelo de dados

@Return		lRet	- Indica se todas as condições foram respeitadas

@Author		Felipe C. Seolin
@Since		27/05/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ValidModel( oModel )

Local nOperation	as numeric
Local lRet			as logical

nOperation	:=	oModel:GetOperation()
lRet		:=	.T.

If nOperation == MODEL_OPERATION_UPDATE .or. nOperation == MODEL_OPERATION_DELETE
	If AllTrim( oModel:GetValue( "MODEL_CFR", "CFR_ORIGEM" ) ) == "A" .and. FunName() <> "TAFA444"
		lRet := .F.
		Help( ,, "HELP",, STR0026, 1, 0 ) //"Não é permitido edição de um registro calculado pela apuração."
	EndIf
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel

Função de gravação dos dados, executado na confirmação do modelo.

@Param 		oModel - Modelo de dados

@Return		.T.

@Author		Evandro dos Santos Oliveira
@Since		10/06/2014
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation	as numeric

nOperation	:=	oModel:GetOperation()

Begin Transaction
	If nOperation == MODEL_OPERATION_UPDATE
		TAFAltStat( "CFR", " " )
	EndIf

	FWFormCommit( oModel )
End Transaction

Return( .T. )

//---------------------------------------------------------------------
/*/{Protheus.doc} Perg330

Tela de entrada de dados prévia a interface cadastral.

@Return		lRet - Indica se todas as condições foram respeitadas

@Author		Felipe C. Seolin
@Since		11/05/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function Perg330()

Local oDlg			as object
Local oFont			as object
Local nLarguraBox	as numeric
Local nAlturaBox	as numeric
Local nLarguraSay	as numeric
Local nTop			as numeric
Local nAltura		as numeric
Local nLargura		as numeric
Local nPosIni		as numeric

oDlg			:=	Nil
oFont			:=	Nil
nLarguraBox		:=	0
nAlturaBox		:=	0
nLarguraSay		:=	0
nTop			:=	0
nAltura			:=	250
nLargura		:=	520
nPosIni			:=	0

oFont := TFont():New( "Arial",, -11 )

oDlg := MsDialog():New( 0, 0, nAltura, nLargura, STR0016,,,,,,,,, .T. ) //"Parâmetros"

nAlturaBox := ( nAltura - 60 ) / 2
nLarguraBox := ( nLargura - 20 ) / 2

@10,10 to nAlturaBox,nLarguraBox of oDlg Pixel

MV_PAR01 := Space( 1 )
MV_PAR02 := Space( TamSX3( "CHD_ID" )[1] )
MV_PAR03 := Space( 220 )

nLarguraSay := nLarguraBox - 30
nTop := 20
TComboBox():New( nTop, 20, { |x| If( PCount() == 0, MV_PAR01, MV_PAR01 := x ) }, { "", "1=" + STR0017, "2=" + STR0018 }, 115, 10, oDlg,, { || oDlg:Refresh() }, { || ValidPerg( 1 ) },,, .T.,,,,,,,,,, STR0019, 1, oFont ) //##"Imposto de Renda Pessoa Jurídica" ##"Contribuição Social sobre o Lucro Líquido" ##"Tributo"
nTop += 30
TGet():New( nTop, 20, { |x| If( PCount() == 0, MV_PAR02, MV_PAR02 := x ) }, oDlg, 65, 10, "@", { || ValidPerg( 2 ) },,,,,, .T.,,,,,,,,, "CHD",,,,,,,, STR0020, 1, oFont ) //"Identificação da Pessoa Jurídica"
TGet():New( nTop + 8, 90, { |x| If( PCount() == 0, MV_PAR03, MV_PAR03 := x ) }, oDlg, 152, 10, "@!",,,,,,, .T.,,, { || .F. } )
nTop += 10

nPosIni := ( ( nLargura - 20 ) / 2 ) - 32

SButton():New( nAlturaBox + 10, nPosIni, 1, { |x| Iif( VldPergOk(), x:oWnd:End(), ) }, oDlg )

oDlg:Activate( ,,,.T. )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} VldPergOk

Validação do botão para confirmar a entrada de todos
os dados dos parâmetros prévios a interface cadastral.

@Return		lRet - Indica se todas as condições foram respeitadas

@Author		Felipe C. Seolin
@Since		11/05/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function VldPergOk()

Local lRet	as logical

lRet	:=	.T.

If !(	ValidPerg( 1 ) .and.;
		ValidPerg( 2 ) )
	lRet := .F.
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidPerg

Validação da entrada de dados prévia a interface cadastral.

@Param		nOpc - Indica a opção de validação a ser executada

@Return		lRet - Indica se todas as condições foram respeitadas

@Author		Felipe C. Seolin
@Since		11/05/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ValidPerg( nOpc )

Local lRet	as logical

lRet	:=	.T.

If nOpc == 1

	If Empty( MV_PAR01 )
		MsgInfo( STR0021 ) //"Tributo não informado."
		lRet := .F.
	ElseIf !( MV_PAR01 $ "1|2" )
		MsgInfo( STR0022 ) //"Conteúdo inválido selecionado para Tributo."
		lRet := .F.
	EndIf

ElseIf nOpc == 2

	If !Empty( MV_PAR02 )
		If CHD->( DBSetOrder( 1 ), CHD->( MsSeek( xFilial( "CHD" ) + PadR( MV_PAR02, TamSX3( "CHD_ID" )[1] ) ) ) )
			If !Empty( CHD->CHD_CODQUA )
				MV_PAR02 := CHD->CHD_ID
				MV_PAR03 := DToC( CHD->CHD_PERINI ) + " - " + DToC( CHD->CHD_PERFIN )
			Else
				MsgInfo( STR0023 ) //"Identificação da Pessoa Jurídica informada não possui qualificação da Pessoa Jurídica cadastrada."
				lRet := .F.
			EndIf
		Else
			MsgInfo( STR0024 ) //"Identificação da Pessoa Jurídica não cadastrada."
			lRet := .F.
		EndIf
	Else
		MsgInfo( STR0025 ) //"Identificação da Pessoa Jurídica não informada."
		lRet := .F.
	EndIf

EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF330Init

Função para atribuição da propriedade de inicialização padrão do campo.

@Return		cInit - Conteúdo da inicialização padrão do campo

@Author		Felipe C. Seolin
@Since		11/05/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAF330Init()

Local cCampo	as character
Local cTributo	as character
Local cQualif	as character
Local cInit		as character

cCampo		:=	SubStr( ReadVar(), At( ">", ReadVar() ) + 1 )
cTributo	:=	""
cQualif		:=	""
cInit		:=	""

If cCampo == "CFR_TRIBUT"
	cInit := MV_PAR01
ElseIf cCampo == "CFR_REGECF"
	If MV_PAR01 == "1"
		cTributo := "19"
	Else
		cTributo := "18"
	EndIf

	CHD->( DBSetOrder( 1 ) )
	If CHD->( MsSeek( xFilial( "CHD" ) + PadR( MV_PAR02, TamSX3( "CHD_ID" )[1] ) ) )
		cQualif := CHD->CHD_CODQUA
	EndIf

	If cTributo == "19"
		If cQualif == "01"
			cInit := "1"
		ElseIf cQualif == "02"
			cInit := "2"
		ElseIf cQualif == "03"
			cInit := "3"
		EndIf
	ElseIf cTributo == "18"
		If cQualif == "01"
			cInit := "4"
		ElseIf cQualif == "02"
			cInit := "5"
		ElseIf cQualif == "03"
			cInit := "6"
		EndIf
	EndIf
EndIf

Return( cInit )

//-------------------------------------------------------------------
/*{Protheus.doc} TAF330Vld

Funcao que valida os dados do registro posicionado, verificando se ha 
incoerencias nas informacões caso seja necessario gerar um XML

@Param		lJob - Informa se foi chamado por Job

@Return		.T.

@Author		Evandro dos Santos Oliveira
@Since		10/06/2014
@Version	1.0
*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF330Vld( cAlias, nRecno, nOpc, lJob )

Local cStatus	as character
Local cChave	as character
Local aLogErro	as array

Default lJob	:=	.F.

cStatus		:=	""
cChave		:=	""
aLogErro	:=	{}

If (CFR->CFR_STATUS $ (' 1'))
		
	//---------------------
	// Campos obrigatórios
	//---------------------
	If Empty(CFR->CFR_PERIOD)
		Aadd(aLogErro,{"CFR_PERIOD","000001","CFR",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
	EndIf

	If Empty(CFR->CFR_CODCTA)
		Aadd(aLogErro,{"CFR_CODCTA","000001","CFR",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
	EndIf

	If Empty( CFR->CFR_DCODCT )
		aAdd( aLogErro, { "CFR_DCODCT", "000001", "CFR", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
	EndIf
	
	If Empty(CFR->CFR_DTLAL)
		Aadd(aLogErro,{"CFR_DTLAL","000003","CFR",nRecno}) //STR0003 - "Data inconsistente ou vazia."
	EndIf

	//------------------
	// Consultas padrão
	//------------------	
	If !Empty( CFR->CFR_IDCODL )
		cChave := CFR->CFR_IDCODL
		xVldECFTab("CH8",cChave,1,,@aLogErro,{ "CFR" , "CFR_CODLAN" , nRecno })
	Endif

	//--------
	// Combos
	//--------		 		
	If Empty(CFR->CFR_TRIBUT)
		Aadd(aLogErro,{"CFR_TRIBUT","000001","CFR",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
	Else
		If !(CFR->CFR_TRIBUT $ "1|2")
			aAdd(aLogErro,{"CFR_TRIBUT","000002","CFR", nRecno }) 	//STR0002 "Conteúdo do campo não condiz com as opções possíveis."
		EndIf
	EndIf
				    
	If Empty(CFR->CFR_INDSAL)
		Aadd(aLogErro,{"CFR_INDSAL","000001","CFR",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
	Else
		If !(CFR->CFR_INDSAL $ "1|2")
			aAdd(aLogErro,{"CFR_INDSAL","000002","CFR", nRecno }) 	//STR0002 "Conteúdo do campo não condiz com as opções possíveis."
		EndIf
	EndIf

	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "CFR", cStatus )
		
Else
	
	AADD(aLogErro,{"CFR_ID","000017","CFR", nRecno }) //STR0017 - "Registro já validado."

EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF330Cpy

Executa a cópia de uma Conta da Parte B do e-Lalur para uma Conta da
Parte B do e-Lacs, identificando se será uma inclusão ou alteração.

@Author		Felipe C. Seolin
@Since		12/08/2015
@Version	1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF330Cpy()

Local oDlg		 as object
Local oMrkBrowse as object
Local oTmpTab	 as object
Local cAlias	 as character
Local nTop		 as numeric
Local nLeft		 as numeric
Local aSize		 as array
Local aAlias	 as array
Local aColumns	 as array
Local lEnd		 as logical
Local bReply	 as codeblock

oDlg	    := Nil
oMrkBrowse  := Nil
oTmpTab	 	:= Nil
cAlias		:= ""
nTop		:= 0
nLeft		:= 0
aSize		:= FWGetDialogSize( oMainWnd )
aAlias		:= {}
aColumns	:= {}
lEnd		:= .F.
bReply		:= { || Processa( { || lEnd := Reply( oMrkBrowse ) }, STR0002 ), Iif( lEnd, oDlg:End(), MsgInfo( STR0003 ) ) } //##"Replicando Contas do e-Lalur para e-Lacs" ##"Selecione algum registro para cópia!"

nTop	:=	( aSize[1] + aSize[3] ) / 5
nLeft	:=	( aSize[2] + aSize[4] ) / 5

Processa( { || aAlias := GetStruct( @oTmpTab ) }, STR0013 ) //"Construindo Interface"

cAlias := aAlias[1]
aColumns := aAlias[2]

If ( cAlias )->( !Eof() )

	oDlg := MsDialog():New( nTop, nLeft, aSize[3], aSize[4], STR0004,,,,,,,,, .T.,,,, .F. ) //"Cópia das Contas da Parte B do e-Lalur para e-Lacs"

	oMrkBrowse := FWMarkBrowse():New()

	oMrkBrowse:SetOwner( oDlg )

	//Tipo de dados
	oMrkBrowse:SetDataTable()
	oMrkBrowse:SetAlias( cAlias )

	//Configuração de colunas
	oMrkBrowse:SetFieldMark( "MARK" )
	oMrkBrowse:SetAllMark( { || MarkAll( oMrkBrowse ) } )
	oMrkBrowse:SetColumns( aColumns )

	//Configuração de opções
	oMrkBrowse:SetMenuDef( "" )
	oMrkBrowse:DisableReport()
	oMrkBrowse:DisableConfig()
	oMrkBrowse:SetWalkThru( .F. )
	oMrkBrowse:SetAmbiente( .F. )
	oMrkBrowse:AddButton( STR0005, bReply ) //"Replicar"

	oMrkBrowse:Activate()

	oDlg:Activate()

Else
	Help( " ", 1, "RECNO" )
EndIf

//---------------------------------
//Exclui a tabela e fecha o alias
//---------------------------------
oTmpTab:Delete()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} GetStruct

Monta a consulta ao banco de dados a ser executado para buscar as
Contas da Parte B do e-Lalur ( IRPJ ) para carregamento na interface.

@Return	ExpA	- Array[1] - Alias da Tabela Temporária
				- Array[2] - Colunas da Tabela

@Author		Felipe C. Seolin
@Since		12/08/2015
@Version	1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Static Function GetStruct( oTmpTab )

Local cAlias		as character
Local cTempTab		as character
Local cTable		as character
Local cCampos		as character
Local cCombo		as character
Local nPos			as numeric
Local nI			as numeric
Local aStructCFR	as array
Local aStruct		as array
Local aColumns		as array
Local aCombo		as array

Default oTmpTab := Nil

cAlias		:= GetNextAlias()
cTempTab	:= ""
cTable		:= RetSqlName( "CFR" )
cCampos		:= "CFR_CODCTA|CFR_DCODCT|CFR_VLSALD|CFR_INDSAL"
cCombo		:= ""
nPos		:= 0
nI			:= 0
aStructCFR 	:= CFR->( DBStruct() )
aStruct		:= {}
aColumns	:= {}
aCombo		:= {}

//----------------------------------------------------
// Contas da Parte B do e-Lalur ( Tributo '1' - IRPJ )
//----------------------------------------------------
BeginSQL alias cAlias
	column CFR_PERIOD as DATE
	column CFR_DTLAL as DATE
	column CFR_DTLIM as DATE

	SELECT
		CFR_FILIAL, CFR_ID, CFR_PERIOD, CFR_CODCTA, CFR_DCODCT, CFR_DTLAL, CFR_REGECF,;
		CFR_IDCODL, CFR_DTLIM, CFR_TRIBUT, CFR_VLSALD, CFR_INDSAL, CFR_CNPJ
	FROM
		%table:CFR% cTable
	WHERE
			cTable.CFR_FILIAL = %xFilial:CFR%
		AND
			cTable.CFR_TRIBUT = "1"
		AND
			cTable.%notDel%
EndSql

//----------------------------------
// Cria arquivo de dados temporário
//----------------------------------
aAdd( aStruct, { "MARK", "C", 2, 0 } )
For nI := 1 to Len( aStructCFR )
	aAdd( aStruct, aStructCFR[nI] )
Next nI

cTempTab := getNextAlias()

//------------------------------------
// Instancia o objeto Temporary Table
//------------------------------------
oTmpTab := FWTemporaryTable():New(cTempTab, aStruct)
oTmpTab:AddIndex("1", { "CFR_CODCTA" } )
oTmpTab:Create()

DbSelectArea(cTempTab)
(cTempTab)->(DbSetOrder(1))
(cTempTab)->(DBGoTop())

//------------------------------------
// Popula arquivo de dados temporário
//------------------------------------
While ( cAlias )->( !Eof() )
	If RecLock( ( cTempTab ), .T. )
		( cTempTab )->MARK		 :=	"  "
		( cTempTab )->CFR_FILIAL :=	( cAlias )->CFR_FILIAL
		( cTempTab )->CFR_ID	 :=	( cAlias )->CFR_ID
		( cTempTab )->CFR_PERIOD :=	( cAlias )->CFR_PERIOD
		( cTempTab )->CFR_CODCTA :=	( cAlias )->CFR_CODCTA
		( cTempTab )->CFR_DCODCT :=	( cAlias )->CFR_DCODCT
		( cTempTab )->CFR_DTLAL	 :=	( cAlias )->CFR_DTLAL
		( cTempTab )->CFR_REGECF :=	( cAlias )->CFR_REGECF
		( cTempTab )->CFR_IDCODL :=	( cAlias )->CFR_IDCODL
		( cTempTab )->CFR_DTLIM	 :=	( cAlias )->CFR_DTLIM
		( cTempTab )->CFR_TRIBUT :=	( cAlias )->CFR_TRIBUT
		( cTempTab )->CFR_VLSALD :=	( cAlias )->CFR_VLSALD
		( cTempTab )->CFR_INDSAL :=	( cAlias )->CFR_INDSAL
		( cTempTab )->CFR_CNPJ	 :=	( cAlias )->CFR_CNPJ
		( cTempTab )->( MsUnLock() )
	EndIf
	( cAlias )->( DBSkip() )
EndDo
( cAlias )->( DBCloseArea() )

//---------------------------
// Cria estrutura de colunas
//---------------------------
For nI := 1 to Len( aStruct )
	If aStruct[nI,1] $ cCampos
		nPos++
		aAdd( aColumns, FWBrwColumn():New() )
		aColumns[nPos]:SetData( &( "{ || " + aStruct[nI,1] + " }" ) )
		aColumns[nPos]:SetTitle( RetTitle( aStruct[nI,1] ) )
		aColumns[nPos]:SetSize( aStruct[nI,3] )
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

Return( { cTempTab, aColumns } )

//-------------------------------------------------------------------
/*/{Protheus.doc} MarkAll

Inverte a indicação de seleção de todos registros da MarkBrowse.

@Param		oMrkBrowse -	MarkBrowse com as informações	

@Return		Nil

@Author		Felipe C. Seolin
@Since		04/09/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function MarkAll( oMrkBrowse )

Local cAlias	as character
Local cMark		as character
Local nRecno	as numeric

cAlias	:=	oMrkBrowse:Alias()
cMark	:=	oMrkBrowse:Mark()
nRecno	:=	( cAlias )->( Recno() )

( cAlias )->( DBGoTop() )
While ( cAlias )->( !Eof() )

	If RecLock( cAlias, .F. )
		( cAlias )->MARK := Iif( ( cAlias )->MARK == cMark, "  ", cMark )
		( cAlias )->( MsUnlock() )
	EndIf

	( cAlias)->( DBSkip() )
EndDo

( cAlias )->( DBGoto( nRecno ) )

oMrkBrowse:Refresh()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} Reply

Identifica os registros selecionados para réplica das informações e
Inclui/Altera uma Conta da Parte B do e-Lalur para o e-Lacs.

@Param		oMrkBrowse -	MarkBrowse com as informações 

@Return		lRet		-	Indica se houve registro selecionado

@Author		Felipe C. Seolin
@Since		04/09/2015
@Version	1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Static Function Reply( oMrkBrowse )

Local cRegEcf	as character
Local cCodLal	as character
Local cIDCodL	as character
Local cInsert	as character
Local cUpdate	as character
Local cError	as character
Local cEspaco	as character
Local cAlias	as character
Local cMark		as character
Local nRecno	as numeric
Local nI		as numeric
Local aResumo	as array
Local aArea		as array
Local lRet		as logical

cRegEcf	:=	""
cCodLal	:=	""
cIDCodL	:=	""
cInsert	:=	""
cUpdate	:=	""
cError	:=	""
cEspaco	:=	Chr( 13 ) + Chr( 10 )
cAlias	:=	oMrkBrowse:Alias()
cMark	:=	oMrkBrowse:Mark()
nRecno	:=	( cAlias )->( Recno() )
nI		:=	0
aResumo	:=	{}
aArea	:=	CFR->( GetArea() )
lRet	:=	.F.

DBSelectArea( "CFR" )
CFR->( DBSetOrder( 2 ) )

( cAlias )->( DBGoTop() )
While ( cAlias )->( !Eof() )

	If ( cAlias )->MARK == cMark

		lRet := .T.

		If ( cAlias )->CFR_REGECF == "1"
			cRegEcf := "4"
			cCodLal := Posicione( "CH8", 1, xFilial( "CH8" ) + ( cAlias )->CFR_IDCODL, "CH8_CODIGO" )
			cIDCodL := Posicione( "CH8", 2, xFilial( "CH8" ) + "M350A" + cCodLal, "CH8_ID" )

			If Empty( cIDCodL )
				aAdd( aResumo, { "ERROR", AllTrim( ( cAlias )->CFR_CODCTA ), AllTrim( ( cAlias )->CFR_DCODCT ), STR0006 } ) //"Código de Lançamento no e-Lalur não existente para e-Lacs."
			EndIf

		ElseIf ( cAlias )->CFR_REGECF == "2"
			cRegEcf := "5"
			cCodLal := Posicione( "CH8", 1, xFilial( "CH8" ) + ( cAlias )->CFR_IDCODL, "CH8_CODIGO" )
			cIDCodL := Posicione( "CH8", 2, xFilial( "CH8" ) + "M350B" + cCodLal, "CH8_ID" )

			If Empty( cIDCodL )
				aAdd( aResumo, { "ERROR", AllTrim( ( cAlias )->CFR_CODCTA ), AllTrim( ( cAlias )->CFR_DCODCT ), STR0006 } ) //"Código de Lançamento no e-Lalur não existente para e-Lacs."
			EndIf

		ElseIf ( cAlias )->CFR_REGECF == "3"
			cRegEcf := "6"
			cCodLal := Posicione( "CH8", 1, xFilial( "CH8" ) + ( cAlias )->CFR_IDCODL, "CH8_CODIGO" )
			cIDCodL := Posicione( "CH8", 2, xFilial( "CH8" ) + "M350C" + cCodLal, "CH8_ID" )

			If Empty( cIDCodL )
				aAdd( aResumo, { "ERROR", AllTrim( ( cAlias )->CFR_CODCTA ), AllTrim( ( cAlias )->CFR_DCODCT ), STR0006 } ) //"Código de Lançamento no e-Lalur não existente para e-Lacs."
			EndIf

		Else
			cRegEcf := ""
			cCodLal := ""
			cIDCodL := ""

			aAdd( aResumo, { "ERROR", AllTrim( ( cAlias )->CFR_CODCTA ), AllTrim( ( cAlias )->CFR_DCODCT ), STR0007 } ) //"Configuração da Conta difere do Tributo selecionado."

		EndIf

		If !Empty( cIDCodL )

			If CFR->( MsSeek( xFilial( "CFR" ) + DToS( ( cAlias )->CFR_PERIOD ) + ( cAlias )->CFR_CODCTA + "2" ) )

				If RecLock( "CFR", .F. )
					CFR->CFR_DCODCT	:=	AllTrim( ( cAlias )->CFR_DCODCT )
					CFR->CFR_DTLAL	:=	( cAlias )->CFR_DTLAL
					CFR->CFR_REGECF	:=	cRegEcf
					CFR->CFR_IDCODL	:=	cIDCodL
					CFR->CFR_DTLIM	:=	( cAlias )->CFR_DTLIM
					CFR->CFR_VLSALD	:=	( cAlias )->CFR_VLSALD
					CFR->CFR_INDSAL	:=	( cAlias )->CFR_INDSAL
					CFR->CFR_CNPJ	:=	( cAlias )->CFR_CNPJ

					CFR->( MsUnlock() )

					aAdd( aResumo, { "UPDATE", AllTrim( ( cAlias )->CFR_CODCTA ), AllTrim( ( cAlias )->CFR_DCODCT ) } )

				EndIf

			Else

				If RecLock( "CFR", .T. )
					CFR->CFR_FILIAL	:=	xFilial( "CFR" )
					CFR->CFR_ID		:=	TAFGeraID( "TAF" )
					CFR->CFR_PERIOD	:=	( cAlias )->CFR_PERIOD 
					CFR->CFR_CODCTA	:=	AllTrim( ( cAlias )->CFR_CODCTA )
					CFR->CFR_DCODCT	:=	AllTrim( ( cAlias )->CFR_DCODCT )
					CFR->CFR_DTLAL	:=	( cAlias )->CFR_DTLAL
					CFR->CFR_REGECF	:=	cRegEcf
					CFR->CFR_IDCODL	:=	cIDCodL
					CFR->CFR_DTLIM	:=	( cAlias )->CFR_DTLIM
					CFR->CFR_TRIBUT	:=	"2"
					CFR->CFR_VLSALD	:=	( cAlias )->CFR_VLSALD
					CFR->CFR_INDSAL	:=	( cAlias )->CFR_INDSAL
					CFR->CFR_CNPJ	:=	( cAlias )->CFR_CNPJ

					If TAFColumnPos( "CFR_ORIGEM" )
						CFR->CFR_ORIGEM	:=	"M"
					EndIf

					CFR->( MsUnlock() )

					aAdd( aResumo, { "INSERT", AllTrim( ( cAlias )->CFR_CODCTA ), AllTrim( ( cAlias )->CFR_DCODCT ) } )

				EndIf

			EndIf

		EndIf

	EndIf

	( cAlias )->( DBSkip() )
EndDo

If !Empty( aResumo )

	For nI := 1 to Len( aResumo )

		If aResumo[nI,1] == "INSERT"
			cInsert += cEspaco + "     " + aResumo[nI,2] + " - " + aResumo[nI,3]
		ElseIf aResumo[nI,1] == "UPDATE"
			cUpdate += cEspaco + "     " + aResumo[nI,2] + " - " + aResumo[nI,3]
		ElseIf aResumo[nI,1] == "ERROR"
			cError += cEspaco + "     " + aResumo[nI,2] + " - " + aResumo[nI,3] + " - " + aResumo[nI,4]
		EndIf

	Next nI

	Aviso( STR0008, Iif( !Empty( cInsert ), STR0009 + cInsert + cEspaco + cEspaco, "" ) + Iif( !Empty( cUpdate ), STR0010 + cUpdate + cEspaco + cEspaco, "" ) + Iif( !Empty( cError ), STR0011 + cError, "" ), { STR0012 }, 3 ) //##"Log de processos efetuados" ##"Contas Incluídas: " ##"Contas Alteradas: " ##"Falha para as Contas: " ##"Fechar"

EndIf

( cAlias )->( DBGoTo( nRecno ) )

RestArea( aArea )

Return( lRet )