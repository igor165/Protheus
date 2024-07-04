#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA426.CH'

Static cLayNmSpac  := ''
Static lLaySimplif := TAFLayESoc(, .T.)
Static lSimplBeta  := TAFLayESoc("S_01_01_00", .T., .T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA426
Informações do IRRF Consolidadas por contribuinte
Pai/Filho em MVC

@author Daniel Schmidt
@since 29/05/2017
@version P11
/*/
//-------------------------------------------------------------------
Function TAFA426()

	Private oBrowse as object

	oBrowse := Nil
	
	If lLaySimplif .And. !lSimplBeta
		If FindFunction("TAFDesEven")
			TAFDesEven()
		EndIf
	EndIf

	//Função que indica se o ambiente é válido para o eSocial 2.3
	If TafAtualizado()

		oBrowse := FWmBrowse():New()
		oBrowse:SetAlias( 'T0G' )
		oBrowse:SetDescription( STR0006 )
		oBrowse:SetCacheView(.F.)

		If FindFunction('TAFSetFilter')
			oBrowse:SetFilterDefault(TAFBrwSetFilter("T0G","TAFA426","S-5012"))
		Else
			oBrowse:SetFilterDefault( "T0G_ATIVO == '1'" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )
		EndIf

		oBrowse:AddLegend( "T0G_EVENTO == 'I' ", "GREEN" 	, STR0004 ) //"Registro Incluído"
		oBrowse:AddLegend( "T0G_EVENTO == 'A' ", "YELLOW" 	, STR0008 ) //"Registro Alterado"
		oBrowse:AddLegend( "T0G_EVENTO == 'E' ", "RED"   	, STR0005 ) //"Registro Excluído"
		oBrowse:Activate()

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Daniel Schmidt
@since 29/05/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao as array
	Local aRotina as array

	aFuncao := {}
	aRotina := {}

	Aadd( aFuncao, { "" , "TAF426Xml" , "1" } )
	Aadd( aFuncao, { "" , "TAFXmlLote( 'T0G', 'S-5012' , 'evtIrrf' , 'TAF426Xml', , oBrowse )" , "5" } )

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If lMenuDif .Or. ViewEvent('S-5012')
		ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA426' OPERATION 2 ACCESS 0 //"Visualizar"
	Else
		aRotina	:=	xFunMnuTAF( "TAFA426" , , aFuncao)
	EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Daniel Schmidt
@since 29/05/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruT0G as object
	Local oStruT0H as object
	Local oStruV9S as object
	Local oModel   as object

	oStruT0G := Nil
	oStruT0H := Nil
	oStruV9S := Nil
	oModel   := Nil

	oStruT0G := FWFormStruct(1, 'T0G')
	oStruT0H := FWFormStruct(1, 'T0H')

	SetLayout()

	If !lSimplBeta .And. TafColumnPos("T0H_VLCRSU")
		oStruT0H:RemoveField("T0H_VLCRSU")
	ElseIf TafColumnPos("T0H_VLCRSU")
		oStruV9S := FWFormStruct(1, 'V9S')
	EndIf
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'TAFA426',,, {|oModel| SaveModel(oModel)})

	// Modelo de Informações relativas ao Imposto de Renda Retido na Fonte.
	oModel:AddFields( 'MODEL_T0G',, oStruT0G )

	// Informações consolidadas do IRRF por código de Receita - CR. Origem S-5002. (GRID)
	oModel:AddGrid( 'MODEL_T0H', 'MODEL_T0G', oStruT0H )
	oModel:GetModel( 'MODEL_T0H' ):SetDescription( STR0007 )		 // Adiciona a descricao do Modelo de Dados
	oModel:GetModel( 'MODEL_T0H' ):SetUniqueLine( { 'T0H_IDCODR' } ) // Liga o controle de nao repeticao de linha
	oModel:GetModel( 'MODEL_T0H' ):SetOptional(.T.)					 // Indica que é opcional ter dados informados na Grid
	oModel:GetModel( 'MODEL_T0H' ):SetMaxLine(9)					 // Limita o numero máximo de linha da Grid

	If lSimplBeta .and. TafColumnPos("V9S_PERDIA")
		oModel:AddGrid( 'MODEL_V9S', 'MODEL_T0G', oStruV9S )
		oModel:GetModel( 'MODEL_V9S' ):SetDescription( STR0015 )		
		oModel:GetModel( 'MODEL_V9S' ):SetUniqueLine( { 'V9S_PERDIA', 'V9S_CRDIA' } )
		oModel:GetModel( 'MODEL_V9S' ):SetOptional(.T.)
		oModel:GetModel( 'MODEL_V9S' ):SetMaxLine(350)
	EndIf

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation( 'MODEL_T0H', { { 'T0H_FILIAL', 'xFilial( "T0H" )' }, { 'T0H_ID', 'T0G_ID' }, { 'T0H_VERSAO', 'T0G_VERSAO' }, { 'T0H_PERAPU', 'T0G_PERAPU' } }, T0H->( IndexKey( 1 ) ) )
	If lSimplBeta .and. TafColumnPos("V9S_PERDIA")
		oModel:SetRelation( 'MODEL_V9S', { { 'V9S_FILIAL', 'xFilial( "V9S" )' }, { 'V9S_ID', 'T0G_ID' }, { 'V9S_VERSAO', 'T0G_VERSAO' } }, V9S->( IndexKey( 1 ) ) )
	EndIf

	oModel:GetModel('MODEL_T0G'):SetPrimaryKey({ 'T0G_PERAPU' })

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Daniel Schmidt
@since 29/05/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oStruT0Ga as object
	Local oStruT0Gb as object
	Local oStruT0Gc as object
	Local oStruT0H  as object
	Local oStruV9S  as object
	Local oModel    as object
	Local oView     as object
	Local cCmpFil   as character

	oStruT0Ga	:= Nil
	oStruT0Gb	:= Nil
	oStruT0Gc	:= Nil
	oStruT0H 	:= Nil
	oStruV9S	:= Nil
	oModel   	:= Nil
	oView    	:= Nil
	cCmpFil		:= ""

	oStruT0H 	:= FWFormStruct( 2, 'T0H' )

	oModel   	:= FWLoadModel( 'TAFA426' )
	oView    	:= FWFormView():New()

	If !lSimplBeta .And. TafColumnPos("T0H_VLCRSU")
		oStruT0H:RemoveField("T0H_VLCRSU")
	ElseIf TafColumnPos("T0H_VLCRSU")
		oStruV9S := FWFormStruct(2, 'V9S')
	EndIf

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	//Campos do folder da Identificação do Evento
	cCmpFil := 'T0G_ID|T0G_PERAPU|'
	oStruT0Ga := FwFormStruct( 2, 'T0G', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	//Campos do folder das Informações relativas ao Imposto de Renda Retido na Fonte
	cCmpFil := 'T0G_IDARQB|T0G_NRARQB|T0G_INDEXI|'
	oStruT0Gb := FwFormStruct( 2, 'T0G', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	//Campos do folder do Protocolo
	cCmpFil := 'T0G_PROTUL|'
	oStruT0Gc := FwFormStruct( 2, 'T0G', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruT0Gc,"T0G")
	EndIf

	/*--------------------------------------------------------------------------------------------
										Esrutura da View
	---------------------------------------------------------------------------------------------*/
	oView:AddField( 'VIEW_T0Ga', oStruT0Ga, 'MODEL_T0G' )
	oView:EnableTitleView( 'VIEW_T0Ga', STR0010 ) //Identificação do Evento

	oView:AddField( 'VIEW_T0Gb', oStruT0Gb, 'MODEL_T0G' )
	oView:EnableTitleView( 'VIEW_T0Gb', STR0011 ) //Informações do Imposto de Renda Retido na Fonte

	oView:AddField( 'VIEW_T0Gc', oStruT0Gc, 'MODEL_T0G' )

	If FindFunction("TafNmFolder")
		oView:EnableTitleView( 'VIEW_T0Gc', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"
	Else
		oView:EnableTitleView( 'VIEW_T0Gc', STR0012 ) //Protocolo da última Transmissão
	EndIf

	oView:AddGrid(  'VIEW_T0H', oStruT0H, 'MODEL_T0H' )
	oView:EnableTitleView("VIEW_T0H",STR0013) //Informações consolidadas do IRRF por código de Receita - CR

	If lSimplBeta .and. TafColumnPos("V9S_PERDIA")
		oView:AddGrid( 'VIEW_V9S', oStruV9S, 'MODEL_V9S' )
		oView:EnableTitleView("VIEW_V9S", STR0015 )
	EndIf

	/*-----------------------------------------------------------------------------------
									Estrutura do Folder
	-------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox( 'PAINEL_SUPERIOR', 100 )

	oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL_SUPERIOR')

	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0009 ) //Informações do IRRF

	oView:CreateHorizontalBox( 'T0Ga'	,  	15 ,,, 'FOLDER_SUPERIOR', 'ABA01' )
	oView:CreateHorizontalBox( 'T0Gb'	,  	15 ,,, 'FOLDER_SUPERIOR', 'ABA01' )
	
	If lSimplBeta .and. TafColumnPos("V9S_PERDIA")
		oView:CreateHorizontalBox( 'T0H'	,	35 ,,, 'FOLDER_SUPERIOR', 'ABA01' )
		oView:CreateHorizontalBox( 'V9S'	,	35 ,,, 'FOLDER_SUPERIOR', 'ABA01' )
	Else
		oView:CreateHorizontalBox( 'T0H'	,	70 ,,, 'FOLDER_SUPERIOR', 'ABA01' )
	EndIF

	If FindFunction("TafNmFolder")
		oView:AddSheet('FOLDER_SUPERIOR', "ABA02", TafNmFolder("recibo") )   //"Numero do Recibo"
	Else
		oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0014 )  //"Protocolo de Transmissão"
	EndIf

	oView:CreateHorizontalBox( 'T0Gc'	, 100,,.T., 'FOLDER_SUPERIOR', 'ABA02' )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_T0Ga',	'T0Ga' )
	oView:SetOwnerView( 'VIEW_T0Gb',	'T0Gb' )
	oView:SetOwnerView( 'VIEW_T0Gc',	'T0Gc' )
	oView:SetOwnerView( 'VIEW_T0H',		'T0H'  )

	If lSimplBeta .and. TafColumnPos("V9S_PERDIA")
		oView:SetOwnerView( 'VIEW_V9S',	'V9S'  )
	EndIf

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If !lMenuDif
		xFunRmFStr(@oStruT0Ga, 'T0G')
		xFunRmFStr(@oStruT0H, 'T0H')
		If lSimplBeta
			xFunRmFStr(@oStruV9S, 'V9S')
		EndIf
	EndIf

Return oView

///-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@author Daniel Schmidt
@since 29/05/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel as object)

	Local lRetorno   as logical
	Local nOperation as numeric
	Local cLogOpe    as character
	Local cLogOpeAnt as character

	lRetorno   := .T.
	nOperation := 0
	cLogOpe    := ""
	cLogOpeAnt := ""

	nOperation := oModel:GetOperation()

	Begin Transaction

		If nOperation == MODEL_OPERATION_DELETE

			oModel:DeActivate()
			oModel:SetOperation( 5 )
			oModel:Activate()

			FwFormCommit( oModel )

		EndIf

	End Transaction

Return ( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF426Grv

Funcao de gravacao para atender o registro S-5012

@Param:
cLayout - Nome do Layout que esta sendo enviado, existem situacoes onde o mesmo fonte
          alimenta mais de um regsitro do E-Social, para estes casos serao necessarios
          tratamentos de acordo com o layout que esta sendo enviado.
nOpc   -  Opcao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )
cFilEv -  Filial do ERP para onde as informacoes deverao ser importadas
oDados -  Objeto com as informacoes a serem manutenidas ( Outras Integracoes )

@Return
lRet    - Variavel que indica se a importacao foi realizada, ou seja, se as
		  informacoes foram gravadas no banco de dados
aIncons - Array com as inconsistencias encontradas durante a importacao

@author Daniel Schmidt
@since 29/05/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF426Grv( cLayout as Character, nOpc as Numeric, cFilEv as Character, oXML as Object, cOwner as Character,;
 					cFilTran as Character, cPredeces as Character, nTafRecno as Numeric, cComplem as Character, cGrpTran as Character,;
 					cEmpOriGrp as Character, cFilOriGrp as Character, cXmlID as Character, cEvtOri as character, lMigrador as logical,;
 					lDepGPE as logical, cKey as character, cMatrC9V as character, lLaySmpTot as logical, lExclCMJ as logical,;
					oTransf as object, cXML as character )

	Local cCmpsNoUpd  as character
	Local cCabec      as character
	Local cIdFunc     as character
	Local cInconMsg   as character
	Local cPeriodo    as character
	Local cLogOpeAnt  as character
	Local cT0HPath    as character
	Local nI          as numeric
	Local nJ          as numeric
	Local nSeqErrGrv  as numeric
	Local nT0H        as numeric
	Local nV9S        as numeric
	Local aIncons     as array
	Local aRules      as array
	Local aChave      as array
	Local oModel      as object
	Local lRet        as logical

	Private lVldModel as logical
	Private oDados    as object

	Default cLayout    := ""
	Default nOpc       := 1
	Default cFilEv     := ""
	Default oXML       := Nil
	Default cOwner     := ""
	Default cFilTran   := ""
	Default cPredeces  := ""
	Default nTafRecno  := 0
	Default cComplem   := ""
	Default cGrpTran   := ""
	Default cEmpOriGrp := ""
	Default cFilOriGrp := ""
	Default cXmlID     := ""
	Default cEvtOri    := ""
	Default lMigrador  := ""
	Default lDepGPE    := ""
	Default cKey       := ""
	Default cMatrC9V   := ""
	Default lLaySmpTot := ""
	Default lExclCMJ   := ""
	Default oTransf    := ""
	Default cXML       := ""

	lVldModel  := .T.
	oDados     := oXML
	cCmpsNoUpd := "|T0G_FILIAL|T0G_ID|T0G_VERSAO|T0G_PROTUL|T0G_EVENTO|T0G_STATUS|T0G_ATIVO|"
	cCabec     := "/eSocial/evtIrrf/"
	cIdFunc    := ""
	cInconMsg  := ""
	cPeriodo   := ""
	cLogOpeAnt := ""
	cT0HPath   := ""
	cV9SPath   := ""
	nI         := 0
	nJ         := 0
	nSeqErrGrv := 0
	nT0H       := 0
	nV9S       := 0
	aIncons    := {}
	aRules     := {}
	aChave     := {}
	oModel     := Nil
	lRet       := .F.

	cPeriodo  := FTafGetVal(  cCabec + "ideEvento/perApur", "C", .F., @aIncons, .F. )

	If At("-", cPeriodo) > 0
		Aadd( aChave, {"C", "T0G_PERAPU", StrTran(cPeriodo, "-", "" ),.T.} )
	Else
		Aadd( aChave, {"C", "T0G_PERAPU", cPeriodo  , .T.} )
	EndIf

	Begin Transaction

		If Findfunction("TafNameEspace")
			cLayNmSpac := TafNameEspace(cXML)
		EndIf

		//Funcao para validar se a operacao desejada pode ser realizada
		If FTafVldOpe( 'T0G', 2 , @nOpc, cFilEv, @aIncons, aChave, @oModel, 'TAFA426', cCmpsNoUpd )

			If TafColumnPos( "T0G_LOGOPE" )
				cLogOpeAnt := T0G->T0G_LOGOPE
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrego array com os campos De/Para de gravacao das informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aRules := TAF426Rul()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
			//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpc <> 5

				oModel:LoadValue( "MODEL_T0G", "T0G_FILIAL", T0G->T0G_FILIAL )

				If TAFColumnPos( "T0G_LAYOUT" )
					oModel:LoadValue( "MODEL_T0G", "T0G_LAYOUT", cLayNmSpac)
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Rodo o aRules para gravar as informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nI := 1 to Len( aRules )
					oModel:LoadValue( "MODEL_T0G", aRules[ nI, 01 ], FTafGetVal( aRules[ nI, 02 ], aRules[nI, 03], aRules[nI, 04], @aIncons, .F. ) )
				Next nI

				If Findfunction("TAFAltMan")
					If nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T0G', 'T0G_LOGOPE' , '1', '' )
					EndIf
				EndIf

				/*----------------------------------------
				T0H - Identificação Estabelecimento
				------------------------------------------*/
				nT0H := 1

				If lSimplBeta .And. TafColumnPos("T0H_VLCRSU")
					cT0HPath := cCabec + "infoIRRF/infoCRMen"
				Else
					cT0HPath := cCabec + "infoIRRF/infoCRContrib"
				EndIF

				cT0HPath := cT0HPath + "[" + CVALTOCHAR(nT0H) + "]"
				
				While oDados:XPathHasNode(cT0HPath)

					If nT0H > 1
						oModel:GetModel( 'MODEL_T0H' ):LVALID	:= .T.
						oModel:GetModel( 'MODEL_T0H' ):AddLine()
					EndIf

					If lSimplBeta .And. TafColumnPos("T0H_VLCRSU")
						oModel:LoadValue( "MODEL_T0H", "T0H_IDCODR", FGetIdInt( "CRMen","",cT0HPath + "/CRMen",,,,@cInconMsg, @nSeqErrGrv))
						oModel:LoadValue( "MODEL_T0H", "T0H_VRCOCR", FTafGetVal( cT0HPath + "/vrCRMen" 		, "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T0H", "T0H_VLCRSU", FTafGetVal( cT0HPath + "/vrCRMenSusp" 	, "N", .F., @aIncons, .F. ) )
					Else
						oModel:LoadValue( "MODEL_T0H", "T0H_IDCODR", FGetIdInt( "tpCR","",cT0HPath + "/tpCR",,,,@cInconMsg, @nSeqErrGrv))
						oModel:LoadValue( "MODEL_T0H", "T0H_VRCOCR", FTafGetVal( cT0HPath + "/vrCr " , "N", .F., @aIncons, .F. ) )
					EndIf

					nT0H++
					If lSimplBeta .And. TafColumnPos("T0H_VLCRSU")
						cT0HPath := cCabec + "infoIRRF/infoCRMen" + "[" + CVALTOCHAR(nT0H) + "]"
					Else
						cT0HPath := cCabec + "infoIRRF/infoCRContrib" + "[" + CVALTOCHAR(nT0H) + "]"
					EndIf				

				EndDo

				If lSimplBeta .and. TafColumnPos("V9S_PERDIA")

					nV9S := 1
					cV9SPath := cCabec + "infoIRRF/infoCRDia[" + CVALTOCHAR(nV9S) + "]"

					While oDados:XPathHasNode(cV9SPath)

						If nV9S > 1
							oModel:GetModel( 'MODEL_V9S' ):LVALID	:= .T.
							oModel:GetModel( 'MODEL_V9S' ):AddLine()
						EndIf

						oModel:LoadValue( "MODEL_V9S", "V9S_PERDIA", FTafGetVal( cV9SPath + "/perApurDia " , "C", .F., @aIncons, .F. ))
						oModel:LoadValue( "MODEL_V9S", "V9S_CRDIA", FGetIdInt( "CRDia","",cV9SPath + "/CRDia",,,,@cInconMsg, @nSeqErrGrv))
						oModel:LoadValue( "MODEL_V9S", "V9S_VRCRDI", FTafGetVal( cV9SPath + "/vrCRDia " , "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_V9S", "V9S_VLCRSU", FTafGetVal( cV9SPath + "/vrCRDiaSusp " , "N", .F., @aIncons, .F. ) )

						nV9S++
						cV9SPath := cCabec + "infoIRRF/infoCRDia[" + CVALTOCHAR(nV9S) + "]"
						
					EndDo

				EndIf

			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetiva a operacao desejada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(cInconMsg)
				If TafFormCommit( oModel )
					Aadd(aIncons, "ERRO19")
				Else
					lRet := .T.
				EndIf
			Else
				Aadd(aIncons, cInconMsg)
			EndIf

			oModel:DeActivate()

		EndIf

	End Transaction

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Zerando os arrays e os Objetos utilizados no processamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize( aRules, 0 )
	aRules := Nil

	aSize( aChave, 0 )
	aChave := Nil

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF426Rul

Regras para gravacao dos Imposto de Renda Retido na Fonte S-5012 do E-Social

@Param

@Return
aRull - Regras para a gravacao das informacoes

@author Daniel Schmidt
@since 29/05/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF426Rul()

	Local aRull    as array
	Local cCabec   as character
	Local cPeriodo as character

	aRull    := {}
	cCabec   := "/eSocial/evtIrrf/"
	cPeriodo := FTafGetVal("/eSocial/evtIrrf/ideEvento/perApur", "C", .F.,, .F. )

	If At("-", cPeriodo) > 0
		Aadd( aRull, {"T0G_PERAPU", StrTran(cPeriodo, "-", "" ) ,"C",.T.} )
	Else
		Aadd( aRull, {"T0G_PERAPU", cPeriodo ,"C", .T.} )
	EndIf

	Aadd( aRull, {"T0G_NRARQB",  FTafGetVal(cCabec + "infoIRRF/nrRecArqBase", "C", .F.,, .F. ), "C", .T. } )
	Aadd( aRull, {"T0G_INDEXI",  FTafGetVal(cCabec + "infoIRRF/indExistInfo", "C", .F.,, .F. ), "C", .T. } )

Return( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF426Xml
Funcao de geracao do XML para atender o registro S-1200
Quando a rotina for chamada o registro deve estar posicionado

@Param:

@Return:
cXml - Estrutura do Xml do Layout S-5012

@author Daniel Schmidt
@since 29/05/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF426Xml(cAlias as character, nRecno as numeric, nOpc as numeric, lJob as logical )

	Local cXml     as character
	Local cLayout  as character
	Local cReg     as character
	Local cEsocial as character
	Local aMensal  as array

	Default cAlias := "T0G"

	cXml           := ""
	cLayout        := "5012"
	cReg           := "Irrf"
	cEsocial       := ""
	aMensal        := {}

	If TAFColumnPos("T0G_LAYOUT") .And. !Empty(AllTrim(T0G->T0G_LAYOUT))
		cEsocial := AllTrim(T0G->T0G_LAYOUT)
	EndIf

	SetLayout()

	If Len(Alltrim(T0G->T0G_PERAPU)) <= 4
		AADD(aMensal,T0G->T0G_PERAPU)
	Else
		AADD(aMensal,substr(T0G->T0G_PERAPU, 1, 4) + '-' + substr(T0G->T0G_PERAPU, 5, 2) )
	EndIf

	cXml +=	"<infoIRRF>"
	cXml +=		xTafTag("nrRecArqBase",T0G->T0G_NRARQB,,.T.)
	cXml +=		xTafTag("indExistInfo",T0G->T0G_INDEXI)

	T0H->( DbSetOrder( 1 ) )
	If T0H->( MsSeek ( xFilial("T0H")+T0G->(T0G_ID+T0G_VERSAO)))

		While !T0H->(Eof()) .And. AllTrim(T0H->(T0H_ID+T0H_VERSAO)) == AllTrim(T0G->(T0G_ID+T0G_VERSAO))

			If lSimplBeta .and. TafColumnPos("T0H_VLCRSU")
				xTafTagGroup("infoCRMen";
							, {{"CRMen"			, Posicione("C6R",3,xFilial("C6R")+T0H->T0H_IDCODR,"C6R_CODIGO"),.F., .F.};
							,	{"vrCRMen"		, T0H->T0H_VRCOCR, PesqPict("T0H", "T0H_VRCOCR")				,.F., .F.};
							,	{"vrCRMenSusp"	, T0H->T0H_VLCRSU, PesqPict("T0H", "T0H_VLCRSU")				,.T., .F.}};
							, @cXml )
			Else
				xTafTagGroup("infoCRContrib";
							, {{"tpCR", Posicione("C6R", 3, xFilial("C6R")+T0H->T0H_IDCODR, "C6R_CODIGO"),, .F.};
							,	{"vrCr", T0H->T0H_VRCOCR, PesqPict("T0H","T0H_VRCOCR"),, .F.}};
							, @cXml )
			EndIf

		T0H->(DbSkip())

		EndDo

	EndIf

	If lSimplBeta .and. TafColumnPos("V9S_PERDIA")

		V9S->( DbSetOrder( 1 ) )
		C6R->( DbSetOrder( 3 ) )

		If V9S->( MsSeek( xFilial("V9S")+T0G->(T0G_ID+T0G_VERSAO)))

			While !V9S->(Eof()) .And. AllTrim(V9S->(V9S_ID+V9S_VERSAO)) == AllTrim(T0G->(T0G_ID+T0G_VERSAO))

				C6R->(MsSeek(xFilial("C6R") + V9S->V9S_CRDIA))

				xTafTagGroup("infoCRDia";
							, {{"perApurDia" , V9S->V9S_PERDIA,								, .F.};
							,  {"CRDia"		 , C6R->C6R_CODIGO,								, .F.};
							,  {"vrCRDia"	 , V9S->V9S_VRCRDI,	PesqPict("V9S","V9S_VRCRDI"), .F., .F.};
							,  {"vrCRDiaSusp", V9S->V9S_VLCRSU, PesqPict("V9S","V9S_VLCRSU"), .T., .F.}};
							, @cXml )
			V9S->(DbSkip())

			EndDo

		EndIf

	EndIf

	cXml +=	"</infoIRRF>"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Estrutura do cabecalho³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If TAFColumnPos("T0G_LAYOUT")
		cXml := xTafCabXml( cXml, "T0G", cLayout, cReg, aMensal,,, lLaySimplif, cEsocial )
	Else
		cXml := xTafCabXml( cXml, "T0G", cLayout, cReg, aMensal )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa gravacao do registro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lJob
		xTafGerXml(cXml,cLayout)
	EndIf

Return(cXml)

//---------------------------------------------------------------------
/*/{Protheus.doc} SetLayout

@description	Função para alterar variaveis staticas de controle
				de Layout.
@author			Silas Gomes
@since			23/09/2022
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function SetLayout()

	Local cEsocial   as character
	Local lOperation as logical
	Local lTAF426Xml as logical
	Local lTAF426GRV as logical
	Local lXTAFVEXC  as logical

	cEsocial   := ""
	lOperation := .F.
	lTAF426Xml := FWIsInCallStack("TAF426Xml")
	lTAF426GRV := FWIsInCallStack("TAF426GRV")
	lXTAFVEXC  := FWIsInCallStack("XTAFVEXC")

	If lTAF426GRV
		cEsocial := cLayNmSpac
	Else
		If Type("INCLUI") != "U" .And. Type("ALTERA") != "U"
			lOperation := !INCLUI .And. !ALTERA
		EndIf

		If lTAF426Xml .Or. lOperation .Or. lXTAFVEXC
			If TAFColumnPos("T0G_LAYOUT")		
				cEsocial := T0G->T0G_LAYOUT
			Else
				lLaySimplif  := TAFLayESoc(, .T.)
				lSimplBeta   := TAFLayESoc("S_01_01_00", .T., .T.)			
			EndIf
		EndIf
	EndIf

	If !Empty(cEsocial)
		If Findfunction("TAFIsSimpl")
			lLaySimplif := TAFIsSimpl(AllTrim(cEsocial))
		EndIf

		If AllTrim(cEsocial) == "S_01_01_00"
			lSimplBeta  := .T.
		Else
			lSimplBeta  := .F.
		EndIf
	EndIf
	
Return
