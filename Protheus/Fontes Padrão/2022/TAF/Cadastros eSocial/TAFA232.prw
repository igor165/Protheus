#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA232.CH'
#INCLUDE "TOPCONN.CH"

Static lLaySimplif	:= TafLayESoc("S_01_00_00")
Static __lValidTabRub	:= Nil
Static __aCodRub		:= Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA232
Cadastro MVC para atender o registro S-1010 (Tabela de R�bricas) do e-Social.

@author Leandro Prado
@since 19/08/2013
@version 1.0

/*/
//--------------------------------------------------------------------
Function TAFA232()

	Private oBrw		:= FWmBrowse():New()

	// Vari�vel que indica se o ambiente � v�lido para o eSocial
	If TafAtualizado()

		oBrw:SetDescription( STR0001 ) //Tabela de R�bricas
		oBrw:SetAlias( 'C8R')
		oBrw:SetMenuDef( 'TAFA232' )

		oBrw:SetFilterDefault( "C8R_ATIVO == '1' .Or. (C8R_EVENTO == 'E' .And. C8R_STATUS = '4' .And. C8R_ATIVO = '2')" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )

		oBrw:AddLegend( "C8R_EVENTO == 'I' ", "GREEN" , STR0016 ) //"Registro Inclu�do"
		oBrw:AddLegend( "C8R_EVENTO == 'A' ", "YELLOW", STR0017 ) //"Registro Alterado"
		oBrw:AddLegend( "C8R_EVENTO == 'E' .And. C8R_STATUS <> '4' ", "RED"   , STR0018 ) //"Registro exclu�do n�o transmitido"
		oBrw:AddLegend( "C8R_EVENTO == 'E' .And. C8R_STATUS == '4' .And. C8R_ATIVO = '2' ", "BLACK"   , STR0019 ) //"Registro exclu�do transmitido"

		oBrw:Activate()

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author Leandro Prado
@since 19/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao := {}
	Local aRotina := {}

	If FindFunction('TafXmlRet')
		Aadd( aFuncao, { "" , "TafxmlRet('TAF232Xml','1010','C8R')" , "1" } )
	Else
		Aadd( aFuncao, { "" , "TAF232Xml" , "1" } )
	EndIf

	Aadd( aFuncao, { "" , "xFunHisAlt( 'C8R', 'TAFA232',,,,'TAF232XML','1010' )" , "3" } )
	Aadd( aFuncao, { "" , "TAFXmlLote( 'C8R', 'S-1010' , 'evtTabRubrica' , 'TAF232Xml',, oBrw )" , "5" } )
	Aadd( aFuncao, { "" , "xFunAltRec( 'C8R' )" , "10" } )

	lMenuDIf := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDIf )

	If lMenuDif
		ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA232' OPERATION 2 ACCESS 0
	Else
		aRotina	:=	xFunMnuTAF( "TAFA232" , , aFuncao)
	EndIf

	ADD OPTION aRotina Title "Exclus�o Autom�tica" Action "TAF232ExcAll" OPERATION 5 ACCESS 0

Return( aRotina )  


//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Leandro Prado
@since 19/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruC8R	:= FWFormStruct( 1, 'C8R' )// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruT5N	:= FWFormStruct( 1, 'T5N' )
	Local oStruT5Na	:= FWFormStruct( 1, 'T5N' )

	Local oModel	:= MPFormModel():New('TAFA232',,,{|oModel| SaveModel(oModel)} )
	Local aT5NX2Un	:= FwSX2Util():GetSX2data('T5N', {"X2_UNICO"})

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruC8R:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	EndIf

	If !lLaySimplif
		oStruC8R:SetProperty("C8R_CINTSL",MODEL_FIELD_OBRIGAT,.T.)
	EndIf

	// Inicializa o campo T5N_NINCID com valor de acordo com a Grid
	oStruT5N:SetProperty('T5N_NINCID' , MODEL_FIELD_INIT ,{| oModel |"01"})
	oStruT5Na:SetProperty('T5N_NINCID' , MODEL_FIELD_INIT ,{| oModel | Iif(oModel:Getid()=='MODEL_T5Nb',"02",Iif(oModel:Getid()=='MODEL_T5Nc',"03","04")) })
	oStruT5Na:SetProperty("T5N_EXTDEC",MODEL_FIELD_OBRIGAT,.F.)

	// Adiciona ao modelo um componente de formul�rio
	oModel:AddFields( 'MODEL_C8R', /*cOwner*/, oStruC8R)

	oModel:AddGrid('MODEL_T5Na', 'MODEL_C8R',oStruT5N)
	oModel:GetModel('MODEL_T5Na'):SetOptional( .T. )
	oModel:GetModel('MODEL_T5Na'):SetLoadFilter({{ "T5N_NINCID", "'01'" }})

	If Len(aT5NX2Un) > 0 .And. 'T5N_IDSUSP' $ aT5NX2Un[1][2]
		oModel:GetModel('MODEL_T5Na'):SetUniqueLine({ "T5N_NINCID","T5N_IDPROC","T5N_IDSUSP" } )
	Else
		oModel:GetModel('MODEL_T5Na'):SetUniqueLine({ "T5N_NINCID","T5N_IDPROC" } )
	EndIf

	oModel:AddGrid('MODEL_T5Nb', 'MODEL_C8R',oStruT5Na)
	oModel:GetModel('MODEL_T5Nb'):SetOptional( .T. )
	oModel:GetModel('MODEL_T5Nb'):SetLoadFilter({{ "T5N_NINCID", "'02'" }})

	If Len(aT5NX2Un) > 0 .And. 'T5N_IDSUSP' $ aT5NX2Un[1][2]
		oModel:GetModel('MODEL_T5Nb'):SetUniqueLine({ "T5N_NINCID","T5N_IDPROC","T5N_IDSUSP" } )
	Else
		oModel:GetModel('MODEL_T5Nb'):SetUniqueLine({ "T5N_NINCID","T5N_IDPROC" } )
	EndIf

	oModel:AddGrid('MODEL_T5Nc', 'MODEL_C8R',oStruT5Na)
	oModel:GetModel('MODEL_T5Nc'):SetOptional( .T. )
	oModel:GetModel('MODEL_T5Nc'):SetLoadFilter({{ "T5N_NINCID", "'03'" }})
	oModel:GetModel('MODEL_T5Nc'):SetUniqueLine({ "T5N_NINCID","T5N_IDPROC" } )

	If !lLaySimplif
		oModel:AddGrid('MODEL_T5Nd', 'MODEL_C8R',oStruT5Na)
		oModel:GetModel('MODEL_T5Nd'):SetOptional( .T. )
		oModel:GetModel('MODEL_T5Nd'):SetLoadFilter({{ "T5N_NINCID", "'04'" }})
		oModel:GetModel('MODEL_T5Nd'):SetUniqueLine({ "T5N_NINCID","T5N_IDPROC" } )
	EndIf

	/*--------------------------------------------------------
			Abaixo realiza-se a amarra��o das tabelas
	----------------------------------------------------------*/
	// Define a chave �nica de grava��o das informa��es
	oModel:GetModel( 'MODEL_C8R' ):SetPrimaryKey( { 'C8R_FILIAL' , 'C8R_ID', 'C8R_VERSAO' } )

	oModel:SetRelation( 'MODEL_T5Na', {{'T5N_FILIAL',"xFilial('T5N')" },{'T5N_ID','C8R_ID'},{'T5N_VERSAO','C8R_VERSAO'}}, T5N->( IndexKey(1)))
	oModel:SetRelation( 'MODEL_T5Nb', {{'T5N_FILIAL',"xFilial('T5N')" },{'T5N_ID','C8R_ID'},{'T5N_VERSAO','C8R_VERSAO'}}, T5N->( IndexKey(1)))
	oModel:SetRelation( 'MODEL_T5Nc', {{'T5N_FILIAL',"xFilial('T5N')" },{'T5N_ID','C8R_ID'},{'T5N_VERSAO','C8R_VERSAO'}}, T5N->( IndexKey(1)))

	If !lLaySimplif
		oModel:SetRelation( 'MODEL_T5Nd', {{'T5N_FILIAL',"xFilial('T5N')" },{'T5N_ID','C8R_ID'},{'T5N_VERSAO','C8R_VERSAO'}}, T5N->( IndexKey(1)))
	EndIf

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Leandro Prado
@since 19/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel    := FWLoadModel( 'TAFA232' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oStruC8Ra	:= Nil
	Local oStruC8Rb	:= Nil
	Local oStruT5Na	:= FWFormStruct( 2, 'T5N' )
	Local oStruT5Nb	:= FWFormStruct( 2, 'T5N' )
	Local oStruT5Nc	:= FWFormStruct( 2, 'T5N' )
	Local oStruT5Nd	:= FWFormStruct( 2, 'T5N' )
	Local oView 	:= FWFormView():New()
	Local cCmpFil	:= ""
	Local cIdeRubr	:= ""
	Local cDadosRub	:= ""
	Local cCmpTrans	:= ""
	Local nI		:= 0
	Local aCmpGrp	:= {}

	/*-------------------------------------------
				Esrutura da View
	---------------------------------------------*/
	oStruT5Na:SetProperty( 'T5N_IDPROC', MVC_VIEW_LOOKUP, { || 'C1G' } )
	oStruT5Nb:SetProperty( 'T5N_IDPROC', MVC_VIEW_LOOKUP, { || 'C1G' } )
	oStruT5Nc:SetProperty( 'T5N_IDPROC', MVC_VIEW_LOOKUP, { || 'C1G' } )
	oStruT5Nd:SetProperty( 'T5N_IDPROC', MVC_VIEW_LOOKUP, { || 'C1G' } )

	oStruT5Na:RemoveField('T5N_NINCID')
	oStruT5Nb:RemoveField('T5N_NINCID')
	oStruT5Nc:RemoveField('T5N_NINCID')
	oStruT5Nd:RemoveField('T5N_NINCID')

	oStruT5Na:RemoveField('T5N_ID')
	oStruT5Nb:RemoveField('T5N_ID')
	oStruT5Nc:RemoveField('T5N_ID')
	oStruT5Nd:RemoveField('T5N_ID')

	oStruT5Nb:RemoveField('T5N_EXTDEC')
	oStruT5Nc:RemoveField('T5N_EXTDEC')
	oStruT5Nd:RemoveField('T5N_EXTDEC')

	oStruT5Nc:RemoveField('T5N_CODSUS')
	oStruT5Nd:RemoveField('T5N_CODSUS')

	oStruT5Nc:RemoveField('T5N_IDSUSP')
	oStruT5Nd:RemoveField('T5N_IDSUSP')

	oView:SetModel( oModel )

	//Campos do folder principal
	cIdeRubr	:= "C8R_ID|C8R_CODRUB|C8R_IDTBRU|C8R_DTINI|C8R_DTFIN|"
	cDadosRub	:= "C8R_DESRUB|C8R_NATRUB|C8R_DNATRU|C8R_INDTRB|C8R_CINTPS|C8R_DCINTP|C8R_CINTIR|C8R_DCINTI|C8R_CINTFG|C8R_OBS|"

	If lLaySimplif

		If TAFColumnPos( "C8R_CICPRP" ) .And. TAFColumnPos( "C8R_TEREMU" )
			cDadosRub += "C8R_CICPRP|C8R_TEREMU|"
		EndIf

	Else

		cDadosRub += "C8R_CINTSL|"

	EndIf

	cCmpFil	:= cIdeRubr + cDadosRub
	oStruC8Ra	:= FwFormStruct( 2, "C8R",{|x| AllTrim( x ) + "|" $ cCmpFil } )

	//Ordem dos campos na tela
	oStruC8Ra:SetProperty( "C8R_CODRUB", MVC_VIEW_ORDEM	, "04"	)
	oStruC8Ra:SetProperty( "C8R_DTINI"	, MVC_VIEW_ORDEM	, "05"	)
	oStruC8Ra:SetProperty( "C8R_DTFIN"	, MVC_VIEW_ORDEM	, "06"	)
	oStruC8Ra:SetProperty( "C8R_IDTBRU", MVC_VIEW_ORDEM	, "07"	)

	//Se altera��o, desabilito a edi��o do campo
	If Type( "ALTERA" ) <> "U"
		If ALTERA
			oStruC8Ra:SetProperty( "C8R_CODRUB", MVC_VIEW_CANCHANGE , .F. )
		EndIf
	EndIf

	//-------------------------------------------
	// Campos do folder Protocolo de Transmiss�o
	//-------------------------------------------
	cCmpTrans	:= "C8R_PROTUL|"
	oStruC8Rb	:= FwFormStruct( 2, "C8R",{|x| AllTrim( x ) + "|" $ cCmpTrans } )

	oStruC8Ra:AddGroup( "GRP_RUBRICA_01", STR0012, "", 1 ) //"Informa��es de identifica��o da rubrica"
	oStruC8Ra:AddGroup( "GRP_RUBRICA_02", STR0013, "", 1 ) //"Detalhamento das informa��es da rubrica"

	aCmpGrp := StrToKarr( cIdeRubr, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruC8Ra:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_RUBRICA_01" )
	Next nI

	aCmpGrp := StrToKarr( cDadosRub, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruC8Ra:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_RUBRICA_02" )
	Next nI

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruC8Rb,"C8R")
	EndIf

	//Cabe�alho
	oView:AddField( "VIEW_C8Ra", oStruC8Ra, "MODEL_C8R" )
	oView:EnableTitleView( "VIEW_C8Ra",STR0001 ) //Tabela de R�bricas

	oView:AddField( "VIEW_C8Rb", oStruC8Rb, "MODEL_C8R" )

	If FindFunction("TafNmFolder")
		oView:EnableTitleView( 'VIEW_C8Rb', TafNmFolder("recibo",1) ) // "Recibo da �ltima Transmiss�o"
	EndIf

	// Grid
	oView:AddGrid( "aVIEW_T5N", oStruT5Na, "MODEL_T5Na" )
	oView:AddGrid( "bVIEW_T5N", oStruT5Nb, "MODEL_T5Nb" )
	oView:AddGrid( "cVIEW_T5N", oStruT5Nc, "MODEL_T5Nc" )

	If !lLaySimplif
		oView:AddGrid( "dVIEW_T5N", oStruT5Nd, "MODEL_T5Nd" )
	EndIf
	/*-----------------------------------------
			Estrutura do Folder
	-------------------------------------------*/
	oView:CreateHorizontalBox( "PAINEL_C8R",100 )
	oView:CreateFolder( "FOLDER_C8R","PAINEL_C8R" )

	oView:AddSheet( "FOLDER_C8R","ABA01",STR0014 ) //"Cadastro da Rubrica"
	oView:CreateHorizontalBox( "FIELDSC8R",070,,,"FOLDER_C8R","ABA01" )
	oView:CreateHorizontalBox( "FIELDST5N",030,,,"FOLDER_C8R","ABA01" )

	If FindFunction("TafNmFolder")
	oView:AddSheet( 'FOLDER_C8R','ABA02', TafNmFolder("recibo") )   //"Numero do Recibo"
	Else
	oView:AddSheet( "FOLDER_C8R","ABA02",STR0015 ) //"Protocolo de Transmiss�o"
	EndIf

	oView:CreateHorizontalBox( "PROTULC8R",100,,,"FOLDER_C8R","ABA02" )

	oView:CreateFolder( "FOLDER_T5N","FIELDST5N" ) //T5N - Incid�ncias relativas a R�brica

	oView:AddSheet( "FOLDER_T5N","ABA01",STR0008 ) //"Processo Contrib. Previd.(CP)"
	oView:CreateHorizontalBox( "PAINEL_T5Na",100,,,"FOLDER_T5N","ABA01" )

	oView:AddSheet( "FOLDER_T5N","ABA02",STR0009 ) //"Processo IRRF"
	oView:CreateHorizontalBox( "PAINEL_T5Nb",100,,,"FOLDER_T5N","ABA02" )

	oView:AddSheet( "FOLDER_T5N","ABA03",STR0010 ) //"Processo FGTS"
	oView:CreateHorizontalBox( "PAINEL_T5Nc",100,,,"FOLDER_T5N","ABA03" )

	If !lLaySimplif
		oView:AddSheet( "FOLDER_T5N","ABA04",STR0011 ) //"Processo Contrib. Sindical"
		oView:CreateHorizontalBox( "PAINEL_T5Nd",100,,,"FOLDER_T5N","ABA04" )
	EndIf

	/*-----------------------------------------
	Amarra��o para exibi��o das informa��es
	-------------------------------------------*/
	oView:SetOwnerView( 'VIEW_C8Ra', 'FIELDSC8R' )
	oView:SetOwnerView( 'VIEW_C8Rb', 'PROTULC8R' )

	oView:SetOwnerView( 'aVIEW_T5N', 'PAINEL_T5Na' )
	oView:SetOwnerView( 'bVIEW_T5N', 'PAINEL_T5Nb' )
	oView:SetOwnerView( 'cVIEW_T5N', 'PAINEL_T5Nc' )

	If !lLaySimplif
		oView:SetOwnerView( 'dVIEW_T5N', 'PAINEL_T5Nd' )
	EndIf

	lMenuDIf := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDIf )

	If !lMenuDif

		oStruT5Na:RemoveField('T5N_IDSUSP')
		oStruT5Nb:RemoveField('T5N_IDSUSP')
		oStruT5Nc:RemoveField('T5N_IDSUSP')
		oStruT5Nd:RemoveField('T5N_IDSUSP')

		xFunRmFStr(@oStruC8Ra, 'C8R')
		xFunRmFStr(@oStruC8Rb, 'C8R')

		xFunRmFStr(@oStruT5Na, 'T5N')
		xFunRmFStr(@oStruT5Nb, 'T5N')
		xFunRmFStr(@oStruT5Nc, 'T5N')
		If !lLaySimplif
			xFunRmFStr(@oStruT5Nd, 'T5N')
		EndIf

	EndIf

	If TafColumnPos( "C8R_LOGOPE" )
		oStruC8Rb:RemoveField( "C8R_LOGOPE" )
	EndIf

	If !lLaySimplif
		oStruC8Ra:RemoveField( "C8R_TEREMU" )
		oStruC8Ra:RemoveField( "C8R_CICPRP" )
	EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Leandro Prado
@since 08/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

	Local cVerAnt    := ""
	Local cProtocolo := ""
	Local cVersao    := ""
	Local cEvento    := ""
	Local cChvRegAnt := ""
	Local cLogOpeAnt := ""
	Local nOperation := oModel:GetOperation()
	Local nC8R       := 0
	Local nT5N       := 0
	Local aGrava     := {}
	Local aGravaT5Na := {}
	Local aGravaT5Nb := {}
	Local aGravaT5Nc := {}
	Local aGravaT5Nd := {}
	Local oModelC8R  := Nil
	Local oModelT5Na := Nil
	Local oModelT5Nb := Nil
	Local oModelT5Nc := Nil
	Local oModelT5Nd := Nil
	Local lRetorno   := .T.

	Begin Transaction

	If nOperation == MODEL_OPERATION_INSERT

		TafAjustID( "C8R", oModel)

		oModel:LoadValue( 'MODEL_C8R', 'C8R_VERSAO', xFunGetVer() )
		If Findfunction("TAFAltMan")
			TafAltMan( 3 , 'Save' , oModel, 'MODEL_C8R', 'C8R_LOGOPE' , '2', '' )
		EndIf

		FwFormCommit( oModel )

	ElseIf nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE

		//�����������������������������������������������������������������Ŀ
		//�Seek para posicionar no registro antes de realizar as validacoes,�
		//�visto que quando nao esta pocisionado nao eh possivel analisar   �
		//�os campos nao usados como _STATUS                                �
		//�������������������������������������������������������������������
		C8R->( DbSetOrder( 5 ) )
		If C8R->( MsSeek( xFilial( 'C8R' ) + FwFldGet('C8R_ID')+ '1' ) )

			//��������������������������������Ŀ
			//�Se o registro ja foi transmitido�
			//����������������������������������
			If C8R->C8R_STATUS == "4"

				oModelC8R	:= oModel:GetModel( 'MODEL_C8R' )
				oModelT5Na	:= oModel:GetModel( 'MODEL_T5Na' )
				oModelT5Nb	:= oModel:GetModel( 'MODEL_T5Nb' )
				oModelT5Nc	:= oModel:GetModel( 'MODEL_T5Nc' )
				oModelT5Nd	:= oModel:GetModel( 'MODEL_T5Nd' )

				//�����������������������������������������������������������Ŀ
				//�Busco a versao anterior do registro para gravacao do rastro�
				//�������������������������������������������������������������
				cVerAnt		:= oModelC8R:GetValue( "C8R_VERSAO" )
				cProtocolo	:= oModelC8R:GetValue( "C8R_PROTUL" )
				cEvento		:= oModelC8R:GetValue( "C8R_EVENTO" )

				If TafColumnPos( "C8R_LOGOPE" )
					cLogOpeAnt := oModelC8R:GetValue( "C8R_LOGOPE" )
				EndIf

				If nOperation == MODEL_OPERATION_DELETE .And. cEvento == "E"
					// N�o � poss�vel excluir um evento de exclus�o j� transmitido
					TAFMsgVldOp(oModel,"4")
					lRetorno := .F.
				Else

					//������������������������������������������������������������������Ŀ
					//�Neste momento eu gravo as informacoes que foram carregadas na tela�
					//��������������������������������������������������������������������
					For nC8R := 1 to Len( oModelC8R:aDataModel[ 1 ] )
						aAdd( aGrava, { oModelC8R:aDataModel[ 1, nC8R, 1 ], oModelC8R:aDataModel[ 1, nC8R, 2 ] } )
					Next nC8R

					If !oModel:GetModel('MODEL_T5Na'):IsEmpty()
						For nT5N := 1 To oModel:GetModel( 'MODEL_T5Na' ):Length()
							oModel:GetModel( 'MODEL_T5Na' ):GoLine(nT5N)
							If !oModel:GetModel( 'MODEL_T5Na' ):IsDeleted()
								aAdd (aGravaT5Na, {oModelT5Na:GetValue('T5N_IDPROC'),;
								oModelT5Na:GetValue('T5N_EXTDEC'),;
								oModelT5Na:GetValue('T5N_IDSUSP')} )
							EndIf
						Next nT5N
					EndIf

					If !oModel:GetModel('MODEL_T5Nb'):IsEmpty()
						For nT5N := 1 To oModel:GetModel( 'MODEL_T5Nb' ):Length()
							oModel:GetModel( 'MODEL_T5Nb' ):GoLine(nT5N)
							If !oModel:GetModel( 'MODEL_T5Nb' ):IsDeleted()
								aAdd (aGravaT5Nb, {oModelT5Nb:GetValue('T5N_IDPROC'),;
									oModelT5Nb:GetValue('T5N_IDSUSP')} )
							EndIf
						Next nT5N
					EndIf

					If !oModel:GetModel('MODEL_T5Nc'):IsEmpty()
						For nT5N := 1 To oModel:GetModel( 'MODEL_T5Nc' ):Length()
							oModel:GetModel( 'MODEL_T5Nc' ):GoLine(nT5N)
							If !oModel:GetModel( 'MODEL_T5Nc' ):IsDeleted()
								aAdd (aGravaT5Nc, {oModelT5Nc:GetValue('T5N_IDPROC'),;
								oModelT5Nc:GetValue('T5N_IDSUSP')} )
							EndIf
						Next nT5N
					EndIf

					If !lLaySimplif

						If !oModel:GetModel('MODEL_T5Nd'):IsEmpty()
							For nT5N := 1 To oModel:GetModel( 'MODEL_T5Nd' ):Length()
								oModel:GetModel( 'MODEL_T5Nd' ):GoLine(nT5N)
								If !oModel:GetModel( 'MODEL_T5Nd' ):IsDeleted()
									aAdd (aGravaT5Nd, {oModelT5Nd:GetValue('T5N_IDPROC'),;
										oModelT5Nd:GetValue('T5N_IDSUSP')} )
								EndIf
							Next nT5N
						EndIf

					EndIf

					//�����������������������������������������������������������Ŀ
					//�Seto o campo como Inativo e gravo a versao do novo registro�
					//�no registro anterior                                       �
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//�������������������������������������������������������������
					FAltRegAnt( 'C8R', '2' ,.F.,FwFldGet("C8R_DTFIN"),FwFldGet("C8R_DTINI"),C8R->C8R_DTINI )

					//��������������������������������������������������Ŀ
					//�Neste momento eu preciso setar a operacao do model�
					//�como Inclusao                                     �
					//����������������������������������������������������
					oModel:DeActivate()
					oModel:SetOperation( 3 )
					oModel:Activate()

					//�������������������������������������������������������Ŀ
					//�Neste momento eu realizo a inclusao do novo registro ja�
					//�contemplando as informacoes alteradas pelo usuario     �
					//���������������������������������������������������������

					For nC8R := 1 to Len( aGrava )
						oModel:LoadValue( "MODEL_C8R", aGrava[ nC8R, 1 ], aGrava[ nC8R, 2 ] )
					Next nC8R

					//Necess�rio Abaixo do For Nao Retirar
					If Findfunction("TAFAltMan")
						TafAltMan( 4 , 'Save' , oModel, 'MODEL_C8R', 'C8R_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					For nT5N := 1 To Len( aGravaT5Na )
						If nT5N > 1
							oModel:GetModel( 'MODEL_T5Na' ):AddLine()
						EndIf

						oModel:LoadValue( "MODEL_T5Na", "T5N_IDPROC", aGravaT5Na[nT5N][1])
						oModel:LoadValue( "MODEL_T5Na", "T5N_EXTDEC", aGravaT5Na[nT5N][2])
						oModel:LoadValue( "MODEL_T5Na", "T5N_IDSUSP", aGravaT5Na[nT5N][3])
						oModel:LoadValue( "MODEL_T5Na", "T5N_NINCID", "01")

					Next nT5N

					For nT5N := 1 To Len( aGravaT5Nb )

						If nT5N > 1
							oModel:GetModel( 'MODEL_T5Nb' ):AddLine()
						EndIf

						oModel:LoadValue( "MODEL_T5Nb", "T5N_IDPROC", aGravaT5Nb[nT5N][1])
						oModel:LoadValue( "MODEL_T5Nb", "T5N_IDSUSP", aGravaT5Nb[nT5N][2])
						oModel:LoadValue( "MODEL_T5Nb", "T5N_NINCID", "02")

					Next nT5N

					For nT5N := 1 To Len( aGravaT5Nc )

						If nT5N > 1
							oModel:GetModel( 'MODEL_T5Nc' ):AddLine()
						EndIf

						oModel:LoadValue( "MODEL_T5Nc", "T5N_IDPROC", aGravaT5Nc[nT5N][1])
						oModel:LoadValue( "MODEL_T5Nc", "T5N_IDSUSP", aGravaT5Nc[nT5N][2])
						oModel:LoadValue( "MODEL_T5Nc", "T5N_NINCID", "03")

					Next nT5N

					If !lLaySimplif

						For nT5N := 1 To Len( aGravaT5Nd )

							If nT5N > 1
								oModel:GetModel( 'MODEL_T5Nd' ):AddLine()
							EndIf

							oModel:LoadValue( "MODEL_T5Nd", "T5N_IDPROC", aGravaT5Nd[nT5N][1])
							oModel:LoadValue( "MODEL_T5Nd", "T5N_IDSUSP", aGravaT5Nd[nT5N][2])
							oModel:LoadValue( "MODEL_T5Nd", "T5N_NINCID", "04")

						Next nT5N

					EndIf

					//�������������������������������Ŀ
					//�Busco a versao que sera gravada�
					//���������������������������������
					cVersao := xFunGetVer()

					//�����������������������������������������������������������Ŀ
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//�������������������������������������������������������������
					oModel:LoadValue( 'MODEL_C8R', 'C8R_VERSAO', cVersao )
					oModel:LoadValue( 'MODEL_C8R', 'C8R_VERANT', cVerAnt )
					oModel:LoadValue( 'MODEL_C8R', 'C8R_PROTPN', cProtocolo )
					oModel:LoadValue( 'MODEL_C8R', 'C8R_PROTUL', "" )
					// Tratamento para limpar o ID unico do xml
					cAliasPai := "C8R"
					If TAFColumnPos( cAliasPai+"_XMLID" )
						oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					EndIf

					If nOperation == MODEL_OPERATION_DELETE
						oModel:LoadValue( 'MODEL_C8R', 'C8R_EVENTO', "E" )
					ElseIf cEvento == "E"
						oModel:LoadValue( 'MODEL_C8R', 'C8R_EVENTO', "I" )
					Else
						oModel:LoadValue( 'MODEL_C8R', 'C8R_EVENTO', "A" )
					EndIf
			
					FwFormCommit( oModel )
			
				EndIf

			ElseIf C8R->C8R_STATUS == "2"
				//N�o � poss�vel alterar um registro com aguardando valida��o
				TAFMsgVldOp(oModel,"2")
				lRetorno := .F.

			Else

				//�����������������������������������������������������������������Ŀ
				//�Caso o registro nao tenha sido transmitido ainda, gravo sua chave�
				//�������������������������������������������������������������������
				cChvRegAnt := C8R->( C8R_ID + C8R_VERANT )

				If TafColumnPos( "C8R_LOGOPE" )
					cLogOpeAnt := C8R->C8R_LOGOPE
				EndIf

				//�����������������������������������������������������������������������������Ŀ
				//�No caso de um evento de Exclusao de um registro com status 'Excluido' deve-se�
				//�perguntar ao usuario se ele realmente deseja realizar a inclusao.            �
				//�������������������������������������������������������������������������������
				If C8R->C8R_EVENTO == "E"
					If nOperation == MODEL_OPERATION_DELETE
						If Aviso( xValStrEr("000754"), xValStrEr("000755"), { xValStrEr("000756"), xValStrEr("000757") }, 1 ) == 2 //##"Registro Exclu�do" ##"O Evento de exclus�o n�o foi transmitido. Deseja realmente exclui-lo ou manter o evento de exclus�o para transmiss�o posterior ?" ##"Excuir" ##"Manter"
						cChvRegAnt := ""
						EndIf
					Else
						oModel:LoadValue( "MODEL_C8R", "C8R_EVENTO", "A" )
					EndIf
				EndIf

				//����������������������������Ŀ
				//�Executo a operacao escolhida�
				//������������������������������
				If !Empty( cChvRegAnt )

					//�������������������������������������������������������������Ŀ
					//�Funcao responsavel por setar o Status do registro para Branco�
					//���������������������������������������������������������������
					TAFAltStat( "C8R", " " )
					If nOperation == MODEL_OPERATION_UPDATE .And. Findfunction("TAFAltMan")
						TafAltMan( 4 , 'Save' , oModel, 'MODEL_C8R', 'C8R_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					FwFormCommit( oModel )

					//������������������������������������Ŀ
					//�Caso a operacao seja uma exclusao...�
					//��������������������������������������
					If nOperation == MODEL_OPERATION_DELETE

						//�������������������������������������������������Ŀ
						//�...de um registro com status de alterado/excluido�
						//���������������������������������������������������
						If C8R->C8R_EVENTO == "A" .or. C8R->C8R_EVENTO == "E"

							//������������������������������������������������Ŀ
							//�Funcao para setar o registro anterior como Ativo�
							//��������������������������������������������������
							TAFRastro( "C8R", 1, cChvRegAnt, .T.,, IIF(Type("oBrw") == "U", Nil, oBrw) )
						EndIf

					EndIf

				EndIf

			EndIf

		Elseif TafIndexInDic("C8R", "A", .T.)

			C8R->( DbSetOrder( 10 ) )
			If C8R->( MsSeek( xFilial( 'C8R' ) + FwFldGet('C8R_ID')+ 'E42' ) )

				If nOperation == MODEL_OPERATION_DELETE
					// N�o � poss�vel excluir um evento de exclus�o j� transmitido
					TAFMsgVldOp(oModel,"4")
					lRetorno := .F.
				EndIf

			EndIf

		EndIf
	EndIf

	End Transaction

Return ( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF232Xml
Funcao de geracao do XML para atender o registro S-1010
Quando a rotina for chamada o registro deve estar posicionado


@Param: 
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composi��o da chave ID do XML

@Return:
cXml - Estrutura do Xml do Layout S-1000

@author Leandro Prado
@since 20/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF232Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

	Local cXml      := ""
	Local cLayout   := "1010"
	Local cEvento   := ""
	Local cReg      := "TabRubrica"
	Local cDtIni    := ""
	Local cDtFin    := ""
	Local cId       := ""
	Local cVerAnt   := ""
	Local cCodSusp  := ""
	Local cTpProc   := ""
	
	//-- Processos relativos a r�brica
	Local cProcCP   := "01"
	Local cProcIRRF := "02"
	Local cProcFGTS := "03"
	Local cProcSIND := "04"
	Local nRecnoSM0 := SM0->(Recno())

	Default cSeqXml := ""

	dbSelectArea("C1G")
	C1G->( DBSetOrder(8) )

	dbSelectArea("T5L")
	T5L->( DBSetOrder(1) )

	If C8R->C8R_EVENTO $ "I|A"

		If C8R->C8R_EVENTO == "A"
			cEvento := "alteracao"

			cId := C8R->C8R_ID
			cVerAnt := C8R->C8R_VERANT

			BeginSql alias 'C8RTEMP'
			SELECT C8R.C8R_DTINI,C8R.C8R_DTFIN
			FROM %table:C8R% C8R
			WHERE C8R.C8R_FILIAL= %xfilial:C8R% AND
			C8R.C8R_ID = %exp:cId% AND C8R.C8R_VERSAO = %exp:cVerAnt% AND
			C8R.%notDel%
			EndSql
			cDtIni := Substr(('C8RTEMP')->C8R_DTINI,3,4) +"-"+ Substr(('C8RTEMP')->C8R_DTINI,1,2)
			cDtFin	:= Iif(Empty(('C8RTEMP')->C8R_DTFIN), "", Substr(('C8RTEMP')->C8R_DTFIN,3,4) +"-"+ Substr(('C8RTEMP')->C8R_DTFIN,1,2)) //Fa�o o IIf pois se a data estiver vazia a string recebia '  -  '

			('C8RTEMP')->( DbCloseArea() )
		Else
			cEvento:= "inclusao"
			cDtIni	:= Substr(C8R->C8R_DTINI,3,4) +"-"+ Substr(C8R->C8R_DTINI,1,2)
			cDtFin	:= Iif(Empty(C8R->C8R_DTFIN), "", Substr(C8R->C8R_DTFIN,3,4) +"-"+ Substr(C8R->C8R_DTFIN,1,2)) //Fa�o o IIf pois se a data estiver vazia a string recebia '  -  '
		EndIf

		cXml +=			"<infoRubrica>"
		cXml +=				"<" + cEvento + ">"
		cXml +=					"<ideRubrica>"
		cXml += 						xTafTag("codRubr",C8R->C8R_CODRUB)
		cXml += 						xTafTag("ideTabRubr",C8R->C8R_IDTBRU)
		cXml +=						xTafTag("iniValid",cDtIni)
		cXml +=						xTafTag("fimValid",cDtFin,,.T.)
		cXml +=					"</ideRubrica>"
		cXml +=					"<dadosRubrica>"
		cXml +=						xTafTag("dscRubr",C8R->C8R_DESRUB)
		cXml +=						xTafTag("natRubr",Posicione("C89",1,xFilial("C89") + C8R->C8R_NATRUB,"C89_CODIGO"))
		cXml +=						xTafTag("tpRubr",C8R->C8R_INDTRB)
		cXml +=						xTafTag("codIncCP",Posicione("C8T",1, xFilial("C8T")+C8R->C8R_CINTPS,"C8T_CODIGO"))
		cXml +=						xTafTag("codIncIRRF",Posicione("C8U",1, xFilial("C8U")+C8R->C8R_CINTIR,"C8U_CODIGO"))
		cXml +=						xTafTag("codIncFGTS",C8R->C8R_CINTFG)

		If lLaySimplif
			cXml +=						xTafTag("codIncCPRP",C8R->C8R_CICPRP,,.T.)
			cXml +=						xTafTag("tetoRemun",C8R->C8R_TEREMU ,,.T.)
		Else
			cXml +=						xTafTag("codIncSIND",C8R->C8R_CINTSL)
		EndIf
		cXml +=						xTafTag("observacao",C8R->C8R_OBS,,.T.)


		dbSelectArea("C1G")
		C1G->(dbSetOrder(8))

		T5N->(DbSetOrder(2))
		If T5N->(MsSeek(xFilial("T5N") + cProcCP + C8R->C8R_ID+C8R->C8R_VERSAO ))

			While T5N->( !Eof()) .And. T5N->T5N_NINCID == cProcCP .And. (xFilial("T5N")+T5N->T5N_ID+T5N->T5N_VERSAO == xFilial("C8R")+C8R->C8R_ID+C8R->C8R_VERSAO)

				C1G->(MsSeek(xFilial("C1G") + T5N->T5N_IDPROC + "1"))
				cCodSusp	:= Posicione("T5L",1,xFilial("T5L")+T5N->T5N_IDSUSP,"T5L_CODSUS")

				cXml +=				"<ideProcessoCP>"
				//Inverto os c�digos para atender o layout do eSocial
				cTpProc := C1G->C1G_TPPROC
				If !empty( cTpProc )
					cTpProc := Iif(alltrim(cTpProc) == "1", "2", Iif(alltrim(cTpProc) == "2", "1", cTpProc) )
				EndIf

				cXml +=					xTafTag("tpProc", cTpProc)
				cXml +=					xTafTag("nrProc"		, Alltrim(C1G->C1G_NUMPRO))
				cXml +=					xTafTag("extDecisao"	, T5N->T5N_EXTDEC)
				cXml +=					xTafTag("codSusp", Alltrim(cCodSusp),,.T.)
				cXml +=				"</ideProcessoCP>"

				T5N->( dbSkip() )
			EndDo
		EndIf

		If T5N->(MsSeek(C8R->C8R_FILIAL + cProcIRRF + C8R->C8R_ID+C8R->C8R_VERSAO ))
			While T5N->( !Eof()) .And. T5N->T5N_NINCID == cProcIRRF .And. (T5N->T5N_FILIAL +T5N->T5N_ID+T5N->T5N_VERSAO == C8R->C8R_FILIAL+C8R->C8R_ID+C8R->C8R_VERSAO)

				C1G->(MsSeek(T5N->T5N_FILIAL + T5N->T5N_IDPROC + "1"))
				cCodSusp	:= Posicione("T5L",1,T5N->T5N_FILIAL+T5N->T5N_IDSUSP,"T5L_CODSUS")

				cXml +=				"<ideProcessoIRRF>"
				cXml +=					xTafTag("nrProc", IIF(lLaySimplif,Alltrim(Substr(C1G->C1G_NUMPRO, 1, TamSX3("C1G_NUMPRO")[1]-1)),Alltrim(C1G->C1G_NUMPRO)))
				cXml +=					xTafTag("codSusp", Alltrim(cCodSusp),,.T.)
				cXml +=				"</ideProcessoIRRF>"
				T5N->( dbSkip() )
			EndDo
		EndIf

		If T5N->(MsSeek(C8R->C8R_FILIAL + cProcFGTS + C8R->C8R_ID+C8R->C8R_VERSAO ))
			While T5N->( !Eof()) .And. T5N->T5N_NINCID == cProcFGTS .And. (T5N->T5N_FILIAL+T5N->T5N_ID+T5N->T5N_VERSAO == C8R->C8R_FILIAL+C8R->C8R_ID+C8R->C8R_VERSAO)

				C1G->(MsSeek(xFilial("C1G") + T5N->T5N_IDPROC + "1"))
				cCodSusp	:= Posicione("T5L",1,T5N->T5N_FILIAL+T5N->T5N_IDSUSP,"T5L_CODSUS")

				cXml +=				"<ideProcessoFGTS>"
				cXml +=					xTafTag("nrProc", IIF(lLaySimplif,Alltrim(Substr(C1G->C1G_NUMPRO, 1, TamSX3("C1G_NUMPRO")[1]-1)),Alltrim(C1G->C1G_NUMPRO)))
				cXml +=				"</ideProcessoFGTS>"
				T5N->( dbSkip() )
			EndDo
		EndIf

		// Exclu�do o grupo {ideProcessoSIND} e respectivo campo
		If !lLaySimplif
			If T5N->(MsSeek(C8R->C8R_FILIAL + cProcSIND + C8R->C8R_ID+C8R->C8R_VERSAO ))
				While T5N->( !Eof()) .And. T5N->T5N_NINCID == cProcSIND .And. (T5N->T5N_FILIAL+T5N->T5N_ID+T5N->T5N_VERSAO == C8R->C8R_FILIAL+C8R->C8R_ID+C8R->C8R_VERSAO)

					C1G->(MsSeek(T5N->T5N_FILIAL + T5N->T5N_IDPROC + "1"))
					cCodSusp	:= Posicione("T5L",1,T5N->T5N_FILIAL+T5N->T5N_IDSUSP,"T5L_CODSUS")

					cXml +=				"<ideProcessoSIND>"
					cXml +=					xTafTag("nrProc", Alltrim(C1G->C1G_NUMPRO))
					cXml +=				"</ideProcessoSIND>"

					T5N->( dbSkip() )
				EndDo
			EndIf
		EndIf
		cXml +=					"</dadosRubrica>"

		If C8R->C8R_EVENTO == "A"
			If TafAtDtVld("C8R", C8R->C8R_ID, C8R->C8R_DTINI, C8R->C8R_DTFIN, C8R->C8R_VERANT, .T.)
				cXml +=				"<novaValidade>"
				cXml +=					TafGetDtTab(C8R->C8R_DTINI,C8R->C8R_DTFIN)
				cXml +=				"</novaValidade>"
			EndIf
		EndIf

		cXml +=				"</" + cEvento + ">"
		cXml +=			"</infoRubrica>"

	ElseIf C8R->C8R_EVENTO == "E"
		cXml +=			"<infoRubrica>"
		cXml +=				"<exclusao>"
		cXml +=					"<ideRubrica>"
		cXml += 					xTafTag("codRubr",C8R->C8R_CODRUB)
		cXml +=						xTafTag("ideTabRubr",C8R->C8R_IDTBRU)
		cXml +=						TafGetDtTab(C8R->C8R_DTINI,C8R->C8R_DTFIN)
		cXml +=					"</ideRubrica>"
		cXml +=				"</exclusao>"
		cXml +=			"</infoRubrica>"
	EndIf

	//����������������������Ŀ
	//�Estrutura do cabecalho�
	//������������������������

	If nRecnoSM0 > 0
		SM0->(dbGoto(nRecnoSM0))
	EndIf
	cXml := xTafCabXml(cXml,"C8R", cLayout,cReg,,cSeqXml)

	//����������������������������Ŀ
	//�Executa gravacao do registro�
	//������������������������������
	If !lJob
		xTafGerXml(cXml,cLayout)
	EndIf

Return(cXml)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF232Grv
@type			function
@description	Fun��o de grava��o para atender o registro S-1010.
@author			Leandro Prado
@since			26/09/2013
@version		1.0
@param			cLayout		-	Nome do Layout que est� sendo enviado
@param			nOpc		-	Op��o a ser realizada ( 3 = Inclus�o, 4 = Altera��o, 5 = Exclus�o )
@param			cFilEv		-	Filial do ERP para onde as informa��es dever�o ser importadas
@param			oXML		-	Objeto com as informa��es a serem manutenidas ( Outras Integra��es )
@param			cOwner
@param			cFilTran
@param			cPredeces
@param			nTafRecno
@param			cComplem
@param			cGrpTran
@param			cEmpOriGrp
@param			cFilOriGrp
@param			cXmlID		-	Atributo Id, �nico para o XML do eSocial. Utilizado para importa��o de dados de clientes migrando para o TAF
@return			lRet		-	Vari�vel que indica se a importa��o foi realizada, ou seja, se as informa��es foram gravadas no banco de dados
@param			aIncons		-	Array com as inconsist�ncias encontradas durante a importa��o
/*/
//-------------------------------------------------------------------
Function TAF232Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

	Local cCmpsNoUpd   := "|C8R_FILIAL|C8R_ID|C8R_VERSAO|C8R_DTINI|C8R_DTFIN|C8R_REPDSR|C8R_REPDTE|C8R_REPFER|C8R_REPREC|C8R_FATRUB|C8R_PROCCP|C8R_NPROCC|C8R_TPROCC|C8R_EPROCC|C8R_PROCIR|C8R_NPROCI|C8R_TPROCI|C8R_PROCFG|C8R_NPROCF|C8R_TPROCF|C8R_PROCCS|C8R_NPROCS|C8R_TPROCS|C8R_VERANT|C8R_PROTPN|C8R_EVENTO|C8R_STATUS|C8R_ATIVO|"
	Local cCabec       := "/eSocial/evtTabRubrica/infoRubrica"
	Local cValChv      := ""
	Local cNewDtIni    := ""
	Local cNewDtFin    := ""
	Local cEnter       := Chr( 13 ) + Chr( 10 )
	Local cMensagem    := ""
	Local cInconMsg    := ""
	Local cT5NPath     := ""
	Local cT5NPath2    := ""
	Local cIdProc      := ""
	Local cIdTabRubr   := ""
	Local cDtIniVld    := ""
	Local cDataIni     := ""
	Local cDataFim     := ""
	Local cTpProc      := ""
	Local cNrProc      := ""
	Local dDtIni       := STOD("19000101")
	Local dDtAux       := ""
	Local cCodEvent    := Posicione( "C8E", 2, xFilial( "C8E" ) + "S-" + cLayout, "C8E->C8E_ID" )
	Local cChave       := ""
	Local cPerIni      := ""
	Local cPerFin      := ""
	Local cPerIniOri   := ""
	Local cLogOpeAnt   := ""
	Local nIndChv      := 2
	Local nIndIDVer    := 1
	Local nlI          := 0
	Local nlJ          := 0
	Local nSeqErrGrv   := 0
	Local nT5Na        := 0
	Local nT5Nb        := 0
	Local nT5Nc        := 0
	Local nT5Nd        := 0
	Local nTamModel    := 0
	Local nLinha       := 0
	Local nTamCod      := TamSX3( "C8R_CODRUB" )[1]
	Local nTamIdTbR    := TamSX3( "C8R_IDTBRU" )[1]
	Local lRet         := .F.
	Local lDelLine     := .F.
	Local lEmpty       := .F.
	Local lAddLine     := .T.
	Local aIncons      := {}
	Local aRules       := {}
	Local aChave       := {}
	Local aNewData     :={Nil, Nil}
	Local oModel       := Nil
	Local lNewValid    := .F.

	Private oDados     := Nil
	Private lVldModel  := .T.

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

	// Vari�vel que indica se o ambiente � v�lido para o eSocial
	If !TafVldAmb("2")
		cMensagem := STR0006 + cEnter // #"Dicion�rio Incompat�vel"
		cMensagem += TafAmbInvMsg()

		Aadd(aIncons, cMensagem)

	Else
		oDados := oXML

		If nOpc == 3
			cTagOper := "/inclusao"
		ElseIf nOpc == 4
			cTagOper := "/alteracao"
		ElseIf nOpc == 5
			cTagOper := "/exclusao"
		EndIf

		cIdTabRubr := FGetIdInt( "ideTabRubr", "", cCabec + cTagOper + "/ideRubrica/ideTabRubr",,,,@cInconMsg, @nSeqErrGrv)

		//Verificar se o codigo foi informado para a chave ( Obrigatorio ser informado )
		cValChv := FTafGetVal( cCabec + cTagOper + '/ideRubrica/codRubr', 'C', .F., @aIncons, .F., '', '' )
		If !Empty( cValChv )
			Aadd( aChave, { "C", "C8R_CODRUB", cValChv, .T.} )
			nIndChv := 3
			cChave := Padr(cValChv,nTamCod)
		EndIf

		// --> Verifica se possui data de in�cio
		cValChv  := FTafGetVal( cCabec + cTagOper + '/ideRubrica/iniValid', 'C', .F., @aIncons, .F., '', '' )
		cDataIni := TAF232Format("C8R_DTINI", cValChv)

		// --> Verifica se possui data de t�rmino
		cValChv  := FTafGetVal( cCabec + cTagOper + '/ideRubrica/fimValid', 'C', .F., @aIncons, .F., '', '' )
		cDataFim := TAF232Format("C8R_DTFIN", cValChv)

		If Empty( cIdTabRubr )

			//Verificar se a data inicial foi informado para a chave( Se nao informado sera adotada a database internamente )
			If !Empty( cDataIni )
				Aadd( aChave, { "C", "C8R_DTINI", cDataIni, .T. } )
				nIndChv 	:= 4
				cPerIni 	:= cDataIni
				cPerIniOri	:= cPerIni
			EndIf

			//Verificar se a data final foi informado para a chave( Se nao informado sera adotado vazio )
			If !Empty( cDataFim )
				Aadd( aChave, { "C", "C8R_DTFIN", cDataFim, .T.} )
				nIndChv := 2
				cPerFin := cDataFim
			EndIf
		Else
			If Empty( cDataIni ) .And. Empty( cDataFim )

				Aadd( aChave, { "C", "C8R_IDTBRU", cIdTabRubr, .T. } )
				nIndChv := 6

			ElseIf !Empty( cDataIni ) .And. Empty( cDataFim )

				Aadd( aChave, { "C", "C8R_DTINI" , cDataIni, .T. } )
				cPerIni 	:= cDataIni
				cPerIniOri	:= cPerIni

				Aadd( aChave, { "C", "C8R_IDTBRU", cIdTabRubr, .T. } )
				nIndChv := 7

				cChave += Padr(cIdTabRubr,nTamIdTbR)
				If nOpc == 3
					cChave += StrTran(cDataIni,"-","")
				EndIf

			ElseIf !Empty( cDataIni ) .And. !Empty( cDataFim )

				Aadd( aChave, { "C", "C8R_DTINI" , cDataIni, .T. } )
				cPerIni 	:= cDataIni
				cPerIniOri	:= cPerIni

				Aadd( aChave, { "C", "C8R_DTFIN" , cDataFim, .T. } )
				cPerFin := cDataFim

				Aadd( aChave, { "C", "C8R_IDTBRU", cIdTabRubr, .T. } )
				nIndChv := 8

				cChave += Padr(cIdTabRubr,nTamIdTbR)
				If nOpc == 3
					cChave += StrTran(cDataIni,"-","")
				EndIf
			EndIf
		EndIf

		If nOpc == 4
			If oDados:XPathHasNode( cCabec + cTagOper + "/novaValidade/iniValid", 'C', .F., @aIncons, .F., '', ''  )
				cNewDtIni := TAF232Format("C8R_DTINI", FTafGetVal( cCabec + cTagOper + "/novaValidade/iniValid", 'C', .F., @aIncons, .F., '', '' ))
				aNewData[1]	:= cNewDtIni
				cPerIni 	:= cNewDtIni
				lNewValid	:= .T.
			EndIf

			If oDados:XPathHasNode( cCabec + cTagOper + "/novaValidade/fimValid", 'C', .F., @aIncons, .F., '', ''  )
				cNewDtFin := TAF232Format("C8R_DTFIN", FTafGetVal( cCabec + cTagOper + "/novaValidade/fimValid", 'C', .F., @aIncons, .F., '', '' ))
				aNewData[2]	:= cNewDtFin
				cPerFin		:= cNewDtFin
				lNewValid	:= .T.
			EndIf
		EndIf

		//Valida as regras da nova validade
		If Empty(aIncons)
			VldEvTab( "C8R", 9, cChave, cPerIni, cPerFin, 2, nOpc, @aIncons, cPerIniOri,,, lNewValid )
		EndIf

		If Empty(aIncons)

			Begin Transaction

				//�������������������������������������������������������������Ŀ
				//�Funcao para validar se a operacao desejada pode ser realizada�
				//���������������������������������������������������������������
				If FTafVldOpe( "C8R", nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA232", cCmpsNoUpd, nIndIDVer, .T., aNewData )

					If TafColumnPos( "C8R_LOGOPE" )
						cLogOpeAnt := C8R->C8R_LOGOPE
					EndIf

					//����������������������������������������������������������������Ŀ
					//�Quando se tratar de uma Exclusao direta apenas preciso realizar �
					//�o Commit(), nao eh necessaria nenhuma manutencao nas informacoes�
					//������������������������������������������������������������������
					If nOpc <> 5

						//���������������������������������������������������������������Ŀ
						//Carrego array com os campos De/Para de gravacao das informacoes
						//�����������������������������������������������������������������
						aRules := TAF232Rul( cTagOper, @cInconMsg, @nSeqErrGrv, cCodEvent, cOwner )

						If TAFColumnPos( "C8R_XMLID" )
							oModel:LoadValue( "MODEL_C8R", "C8R_XMLID", cXmlID )
						EndIf

						oModel:LoadValue( "MODEL_C8R", "C8R_FILIAL", C8R->C8R_FILIAL )

						//����������������������������������������Ŀ
						//�Rodo o aRules para gravar as informacoes�
						//������������������������������������������
						For nlI := 1 To Len( aRules )
							oModel:LoadValue( "MODEL_C8R", aRules[ nlI, 01 ], FTafGetVal( aRules[ nlI, 02 ], aRules[nlI, 03], aRules[nlI, 04], @aIncons, .F., , aRules[ nlI, 01 ] ) )
						Next

						If Findfunction("TAFAltMan")
							if nOpc == 3
								TafAltMan( nOpc , 'Grv' , oModel, 'MODEL_C8R', 'C8R_LOGOPE' , '1', '' )
							elseif nOpc == 4
								TafAltMan( nOpc , 'Grv' , oModel, 'MODEL_C8R', 'C8R_LOGOPE' , '', cLogOpeAnt )
							EndIf
						EndIf

						/*----------------------------------------------------------
									Informa��es do registro Filho T5N
						----------------------------------------------------------*/
						//-- ideProcessoCP
						//Deleto todas as linhas do Grid
						nlJ := 1
						cT5NPath := cCabec + cTagOper + "/dadosRubrica/ideProcessoCP"

						//Recebo o tamanho do model
						nTamModel 	:= oModel:GetModel( "MODEL_T5Na" ):Length()
						lAddLine 	:= .T.

						If nOpc == 4 .and. TafXNode( oDados, cCodEvent, cOwner, (cT5NPath + "[1]/nrProc"), cT5NPath + "/nrProc" )

							For nlJ := 1 to nTamModel
								oModel:GetModel( "MODEL_T5Na" ):GoLine(nlJ)
								oModel:GetModel( "MODEL_T5Na" ):DeleteLine()
							Next nlJ

						Else
							lAddLine := .F.
						EndIf

						//Rodo o XML parseado para gravar as novas informacoes no GRID
						nT5Na	:= 1
						While oDados:XPathHasNode(cCabec + cTagOper + "/dadosRubrica/ideProcessoCP[" + cValToChar(nT5Na)+ "]" ) .OR. ( nT5Na <= nTamModel .AND. !lAddLine )

							cT5NPath  := cCabec + cTagOper + "/dadosRubrica/ideProcessoCP[" + cValToChar(nT5Na)+ "]"
							cT5NPath2 := cCabec + cTagOper + "/dadosRubrica/ideProcessoCP"

							If (nOpc == 3 .And. nT5Na > 1 .And. oDados:XPathHasNode( cT5NPath ) ) .OR. (oDados:XPathHasNode( cT5NPath ) .And. lAddLine)

								oModel:GetModel( "MODEL_T5Na" ):lValid:= .T.
								oModel:GetModel( "MODEL_T5Na" ):AddLine()

							EndIf
						
						
							cTpProc := FTafGetVal(cT5NPath + "/tpProc", "C", .F., @aIncons, .F., '', '' )  
							cNrProc := FTafGetVal(cT5NPath + "/nrProc", "C", .F., @aIncons, .F., '', '' )  

							If TafXNode( oDados, cCodEvent, cOwner, (cT5NPath + "/tpProc"), cT5NPath2 + "/tpProc" ) .OR. TafXNode( oDados, cCodEvent, cOwner, (cT5NPath + "/nrProc"), cT5NPath2 + "/nrProc" )
								
								If !Empty(cTpProc) .OR. !Empty(cNrProc)
									
									cTpProc := IIF(cTpProc=="1","2","1")
									
									C1G->(dbSetOrder(9))
								
									If C1G->(MSSeek(xFilial("C1G")+cTpProc+PadR(cNrProc,TamSX3( "C1G_NUMPRO" )[1])+"1"))

										//Itera a tabela para pesquisar o ID do Processo    
										While C1G->(!Eof()) .AND. AllTrim(cNrProc) == AllTrim(C1G->C1G_NUMPRO) .AND. xFilial("C1G") == C1G->C1G_FILIAL
									
											If AllTrim(cTpProc) == AllTrim(C1G->C1G_TPPROC)
					
												//Valida se o registro est� ativo e se faz parte do contexto do e-social
												If C1G->C1G_ATIVO == '1' .AND. C1G->C1G_ESOCIA == '1'
						
													//Verifica se a data do registro posicionado � maior que a data do registro anterior, com a inten��o de encontrar a data mais recente
													dDtAux := STOD(Substr(C1G->C1G_DTINI,3,4)+ Substr(C1G->C1G_DTINI,1,2)+"01")
						
													If (dDtAux >= dDtIni)
							
														dDtIni  := dDtAux
														cIdProc := C1G->C1G_ID    //captura o ID do registro mais recente
			
													EndIf
													
												EndIf
			
											EndIf
						
											C1G->(dbSkip())
										
										EndDo
									
										oModel:LoadValue( "MODEL_T5Na", "T5N_IDPROC",	 cIdProc)
										oModel:LoadValue( "MODEL_T5Na", "T5N_NINCID", "01")
										lDelLine := Iif(lEmpty,.T.,lEmpty)
										
									Else
									
										If !Empty(cInconMsg)
											cInconMsg += CRLF
										EndIf

										cInconMsg +=  "N�mero e tipo de processo administrativo/judicial (S-1070) vinculado � rubrica n�o encontrado na base de dados do TAF."
								
									EndIf
								
								Else

									lDelLine := .T.									
								
								EndIf

							EndIf

							If !Empty(cIdProc)

								If TafXNode( oDados, cCodEvent, cOwner, (cT5NPath + "/codSusp"), cT5NPath2 + "/codSusp" )

									//Busca a data de inicio da validade
									If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + cTagOper + "/ideRubrica/iniValid"))

										cValChv := FTafGetVal(cCabec + cTagOper + "/ideRubrica/iniValid", "C", .F., @aIncons, .F., '', '' )

										cDtIniVld := Substr(cValChv, 6, 2) + Substr(cValChv, 1,4)

									EndIf

									oModel:LoadValue("MODEL_T5Na", "T5N_IDSUSP", FGetIdInt( "codSusp","",FTafGetVal(cT5NPath + "/codSusp", "C", .F., @aIncons, .F., '', '' ), cIdProc, .F.,, @cInconMsg, @nSeqErrGrv,, cDtIniVld ) )
								                                           
								EndIf

							EndIf

							If TafXNode( oDados, cCodEvent, cOwner, (cT5NPath + "/extDecisao"), cT5NPath2 + "/extDecisao" )
								oModel:LoadValue( "MODEL_T5Na", "T5N_EXTDEC", FTafGetVal( cT5NPath + '/extDecisao', 'C', .F., @aIncons, .F., '', '' ) )
							EndIf

							//Deleto a linha do modelo caso um campo chave seja exclu�do
							If lDelLine

								nLinha := Iif(!lAddLine, nT5Na, nTamModel+nT5Na)

								oModel:GetModel( 'MODEL_T5Na' ):GoLine(nLinha)
								oModel:GetModel( 'MODEL_T5Na' ):DeleteLine()

								lDelLine := .F.

							EndIf

							nT5Na++
						EndDo

						//-- ideProcessoIRRF
						//Deleto todas as linhas do Grid
						nlJ := 1
						cT5NPath := cCabec + cTagOper + "/dadosRubrica/ideProcessoIRRF"

						//Recebo o tamanho do model
						nTamModel	:= oModel:GetModel( "MODEL_T5Nb" ):Length()
						lAddLine 	:= .T.

						If nOpc == 4 .and. TafXNode( oDados, cCodEvent, cOwner, (cT5NPath + "[1]/nrProc"), cT5NPath + "/nrProc" )
							For nlJ := 1 to nTamModel
								oModel:GetModel( "MODEL_T5Nb" ):GoLine(nlJ)
								oModel:GetModel( "MODEL_T5Nb" ):DeleteLine()
							Next nlJ
						Else
							lAddLine := .F.
						EndIf

						//Rodo o XML parseado para gravar as novas informacoes no GRID
						nT5Nb	:= 1
					
						While oDados:XPathHasNode(cCabec + cTagOper + "/dadosRubrica/ideProcessoIRRF[" + cValToChar(nT5Nb)+ "]" ) .OR. ( nT5Nb <= nTamModel .AND. !lAddLine )

							cT5NPath  := cCabec + cTagOper + "/dadosRubrica/ideProcessoIRRF[" + cValToChar(nT5Nb)+ "]"
							cT5NPath2 := cCabec + cTagOper + "/dadosRubrica/ideProcessoIRRF"

							If (nOpc == 3 .And. nT5Nb > 1 .And. oDados:XPathHasNode( cT5NPath ) ) .OR. (oDados:XPathHasNode( cT5NPath ) .And. lAddLine)

								oModel:GetModel( "MODEL_T5Nb" ):lValid:= .T.
								oModel:GetModel( "MODEL_T5Nb" ):AddLine()

							EndIf

							If TafXNode( oDados, cCodEvent, cOwner, (cT5NPath + "/nrProc"), cT5NPath2 + "/nrProc" )
								cIdProc := FGetIdInt( "", "nrProc",,cT5NPath + "/nrProc",,,@cInconMsg, @nSeqErrGrv,,, @lEmpty )
								oModel:LoadValue( "MODEL_T5Nb", "T5N_IDPROC",	cIdProc)
								oModel:LoadValue( "MODEL_T5Nb", "T5N_NINCID",	"02")
								lDelLine := Iif(lEmpty,.T.,lEmpty)
							EndIf

							If !Empty(cIdProc)

								If TafXNode( oDados, cCodEvent, cOwner, (cT5NPath + "/codSusp"), cT5NPath2 + "/codSusp" )

									//Busca a data de inicio da validade
									If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + cTagOper + "/ideRubrica/iniValid"))

									cValChv := FTafGetVal(cCabec + cTagOper + "/ideRubrica/iniValid", "C", .F., @aIncons, .F., '', '' )

									cDtIniVld := Substr(cValChv, 6, 2) + Substr(cValChv, 1,4)

									EndIf

								oModel:LoadValue("MODEL_T5Nb", "T5N_IDSUSP", FGetIdInt( "codSusp","",FTafGetVal(cT5NPath + "/codSusp", "C", .F., @aIncons, .F., '', '' ), cIdProc, .F.,, @cInconMsg, @nSeqErrGrv,, cDtIniVld ) )
								
								EndIf

							EndIf

							//Deleto a linha do modelo caso um campo chave seja exclu�do
							If lDelLine

								nLinha := Iif(!lAddLine, nT5Nb, nTamModel+nT5Nb)

								oModel:GetModel( 'MODEL_T5Nb' ):GoLine(nLinha)
								oModel:GetModel( 'MODEL_T5Nb' ):DeleteLine()

								lDelLine := .F.

							EndIf

							nT5Nb++

						EndDo

						//-- ideProcessoFGTS
						//Deleto todas as linhas do Grid
						nlJ := 1
						cT5NPath := cCabec + cTagOper + "/dadosRubrica/ideProcessoFGTS"

						//Recebo o tamanho do model
						nTamModel 	:= oModel:GetModel( "MODEL_T5Nc" ):Length()
						lAddLine 	:= .T.

						If nOpc == 4 .and. TafXNode( oDados, cCodEvent, cOwner, (cT5NPath + "[1]/nrProc"), cT5NPath + "/nrProc" )
							For nlJ := 1 to nTamModel
							oModel:GetModel( "MODEL_T5Nc" ):GoLine(nlJ)
							oModel:GetModel( "MODEL_T5Nc" ):DeleteLine()
							Next nlJ
						Else
							lAddLine := .F.
						EndIf

						//Rodo o XML parseado para gravar as novas informacoes no GRID
						nT5Nc	:= 1
						While oDados:XPathHasNode(cCabec + cTagOper + "/dadosRubrica/ideProcessoFGTS[" + cValToChar(nT5Nc)+ "]" ) .OR. ( nT5Nc <= nTamModel .AND. !lAddLine )

							cT5NPath	:= cCabec + cTagOper + "/dadosRubrica/ideProcessoFGTS[" + cValToChar(nT5Nc)+ "]"
							cT5NPath2 	:= cCabec + cTagOper + "/dadosRubrica/ideProcessoFGTS"

							If (nOpc == 3 .And. nT5Nc > 1 .And. oDados:XPathHasNode( cT5NPath ) ) .OR. (oDados:XPathHasNode( cT5NPath ) .And. lAddLine)

								oModel:GetModel( "MODEL_T5Nc" ):lValid:= .T.
								oModel:GetModel( "MODEL_T5Nc" ):AddLine()

							EndIf

							If TafXNode( oDados, cCodEvent, cOwner, (cT5NPath + "/nrProc"), cT5NPath2 + "/nrProc" )

								cIdProc := FGetIdInt( "", "nrProc",,cT5NPath + "/nrProc",,,@cInconMsg, @nSeqErrGrv,,, @lEmpty )
								oModel:LoadValue( "MODEL_T5Nc", "T5N_IDPROC", cIdProc)
								oModel:LoadValue( "MODEL_T5Nc", "T5N_NINCID", "03")
								lDelLine := Iif(lEmpty,.T.,lEmpty)

							EndIf

							//Deleto a linha do modelo caso um campo chave seja exclu�do
							If lDelLine

								nLinha := Iif(!lAddLine, nT5Nc, nTamModel+nT5Nc)

								oModel:GetModel( 'MODEL_T5Nc' ):GoLine(nLinha)
								oModel:GetModel( 'MODEL_T5Nc' ):DeleteLine()

								lDelLine := .F.

							EndIf

							nT5Nc++
						EndDo

						If !lLaySimplif
							//-- ideProcessoSIND
							//Deleto todas as linhas do Grid
							nlJ := 1
							cT5NPath := cCabec + cTagOper + "/dadosRubrica/ideProcessoSIND"

							//Recebo o tamanho do model
							nTamModel 	:= oModel:GetModel( "MODEL_T5Nd" ):Length()
							lAddLine 	:= .T.

							If nOpc == 4 .and. TafXNode( oDados, cCodEvent, cOwner, (cT5NPath + "[1]/nrProc"), cT5NPath + "/nrProc" )
								For nlJ := 1 to nTamModel
									oModel:GetModel( "MODEL_T5Nd" ):GoLine(nlJ)
									oModel:GetModel( "MODEL_T5Nd" ):DeleteLine()
								Next nlJ
							Else
								lAddLine := .F.
							EndIf

							//Rodo o XML parseado para gravar as novas informacoes no GRID
							nT5Nd	:= 1
							While oDados:XPathHasNode( cCabec + cTagOper + "/dadosRubrica/ideProcessoSIND[" + cValToChar(nT5Nd)+ "]" ) .OR. ( nT5Nd <= nTamModel .AND. !lAddLine )

								cT5NPath	:= cCabec + cTagOper + "/dadosRubrica/ideProcessoSIND[" + cValToChar(nT5Nd)+ "]"
								cT5NPath2	:= cCabec + cTagOper + "/dadosRubrica/ideProcessoSIND"

								If (nOpc == 3 .And. nT5Nd > 1 .And. oDados:XPathHasNode( cT5NPath ) ) .OR. (oDados:XPathHasNode( cT5NPath ) .And. lAddLine)

									oModel:GetModel( "MODEL_T5Nd" ):lValid:= .T.
									oModel:GetModel( "MODEL_T5Nd" ):AddLine()

								EndIf

								If TafXNode( oDados, cCodEvent, cOwner, (cT5NPath + "/nrProc"), cT5NPath2 + "/nrProc" )
									cIdProc := FGetIdInt( "", "nrProc",,cT5NPath + "/nrProc",,,@cInconMsg, @nSeqErrGrv,,, @lEmpty )
									oModel:LoadValue( "MODEL_T5Nd", "T5N_IDPROC", cIdProc)
									oModel:LoadValue( "MODEL_T5Nd", "T5N_NINCID", "04")
									lDelLine := Iif(lEmpty,.T.,lEmpty)

								EndIf

								nT5Nd++
							EndDo

							//Deleto a linha do modelo caso um campo chave seja exclu�do
							If lDelLine

								nLinha := Iif(!lAddLine, nT5Nd, nTamModel+nT5Nd)

								oModel:GetModel( 'MODEL_T5Nd' ):GoLine(nLinha)
								oModel:GetModel( 'MODEL_T5Nd' ):DeleteLine()

								lDelLine := .F.

							EndIf
						EndIf
					EndIf

					//���������������������������Ŀ
					//�Efetiva a operacao desejada�
					//�����������������������������
					If Empty(cInconMsg)
						If TafFormCommit( oModel )
							Aadd(aIncons, "ERRO19")
						Else
							lRet := .T.
						EndIf
					Else
						Aadd(aIncons, cInconMsg)
						DisarmTransaction()
					EndIf

					oModel:DeActivate()
					If FindFunction('TafClearModel')
						TafClearModel(oModel)
					EndIf

				EndIf

				If C8R->C8R_STATUS $ '2|6'
					aAdd( aIncons , '000025' ) //'N�o � permitido a integra��o deste evento, enquanto outro estiver pendente de transmiss�o.'
				EndIf

			End Transaction

		EndIf

		//����������������������������������������������������������Ŀ
		//�Zerando os arrays e os Objetos utilizados no processamento�
		//������������������������������������������������������������
		aSize( aRules, 0 )
		aRules     := Nil

		aSize( aChave, 0 )
		aChave     := Nil

	EndIf

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF232Rul
Regras para gravacao das informacoes do registro S-1010 do E-Social

@Param
nOper      - Operacao a ser realizada ( 3 = Inclusao / 4 = Alteracao / 5 = Exclusao )

@Return
aRull  - Regras para a gravacao das informacoes


@author Leandro Prado
@since 26/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF232Rul( cTagOper, cInconMsg, nSeqErrGrv, cCodEvent, cOwner )

	Local aRull        := {}
	Local cCabec       := "/eSocial/evtTabRubrica/infoRubrica"

	Default cTagOper   := ""
	Default cInconMsg  := ""
	Default nSeqErrGrv := ""
	Default cCodEvent  := ""
	Default cOwner     := ""

	//Regras de Inclusao dos campos da tabela de Rubrica
	If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + cTagOper + "/ideRubrica/codRubr"))
		Aadd( aRull, { "C8R_CODRUB", cCabec + cTagOper + "/ideRubrica/codRubr", "C", .F. } )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + cTagOper + "/ideRubrica/ideTabRubr" ))
		Aadd( aRull, { "C8R_IDTBRU", FGetIdInt( "ideTabRubr", "", cCabec + cTagOper + "/ideRubrica/ideTabRubr",,,,@cInconMsg, @nSeqErrGrv), "C", .T. } )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner,( cCabec + cTagOper + "/dadosRubrica/dscRubr"))
		Aadd( aRull, { "C8R_DESRUB", cCabec + cTagOper + "/dadosRubrica/dscRubr", "C", .F. } )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + cTagOper + "/dadosRubrica/natRubr"))
		Aadd( aRull, { "C8R_NATRUB", FGetIdInt( "natRubr", "",+cCabec + cTagOper + "/dadosRubrica/natRubr",,,,@cInconMsg, @nSeqErrGrv), "C", .T. } )
	EndIf

	If TafXNode(oDados , cCodEvent, cOwner, ( cCabec + cTagOper + "/dadosRubrica/tpRubr"))
		Aadd( aRull, { "C8R_INDTRB", cCabec + cTagOper + "/dadosRubrica/tpRubr", "C", .F. })
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + cTagOper + "/dadosRubrica/codIncCP"))
		Aadd( aRull, { "C8R_CINTPS", FGetIdInt( "codIncCP", "",+cCabec + cTagOper + "/dadosRubrica/codIncCP",,,,@cInconMsg, @nSeqErrGrv), "C", .T. } )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner,  ( cCabec + cTagOper + "/dadosRubrica/codIncIRRF"))
		Aadd( aRull, { "C8R_CINTIR", FGetIdInt( "codIncIRRF", "",+cCabec + cTagOper + "/dadosRubrica/codIncIRRF",,,,@cInconMsg, @nSeqErrGrv), "C", .T. } )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner,  ( cCabec + cTagOper + "/dadosRubrica/codIncFGTS"))
		Aadd( aRull, { "C8R_CINTFG", cCabec + cTagOper + "/dadosRubrica/codIncFGTS", "C", .F. } )
	EndIf

	If lLaySimplif
		If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + cTagOper + "/dadosRubrica/codIncCPRP"))
			Aadd( aRull, { "C8R_CICPRP", cCabec + cTagOper + "/dadosRubrica/codIncCPRP", "C", .F. } )
		EndIf
		If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + cTagOper + "/dadosRubrica/tetoRemun"))
			Aadd( aRull, { "C8R_TEREMU", cCabec + cTagOper + "/dadosRubrica/tetoRemun", "C", .F. } )
		EndIf
	Else
		If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + cTagOper + "/dadosRubrica/codIncSIND"))
			Aadd( aRull, { "C8R_CINTSL", cCabec + cTagOper + "/dadosRubrica/codIncSIND", "C", .F. } )
		EndIf
	EndIf

	If TafXNode(oDados , cCodEvent, cOwner, ( cCabec + cTagOper + "/dadosRubrica/observacao"))
		Aadd( aRull, {"C8R_OBS", cCabec + cTagOper + "/dadosRubrica/observacao", "C", .F. } )
	EndIf

Return ( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF232Format
Formata os campos do registro S-1010 do E-Social

@Param
cCampo 	  - Campo que deve ser formatado
cValorXml - Valor a ser formatado

@Return
cFormatValue - Valor j� formatado

@author Vitor Siqueira
@since 07/10/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF232Format(cCampo, cValorXml)

	Local cFormatValue := ""
	Local cRet         := ""

	Default cCampo     := ""
	Default cValorXml  := ""

	If (cCampo == 'C8R_DTINI' .OR. cCampo == 'C8R_DTFIN')
		cFormatValue := StrTran( StrTran( cValorXml, "-", "" ), "/", "")
		cRet := Substr(cFormatValue, 5, 2) + Substr(cFormatValue, 1,4)
	Else
		cFormatValue := cValorXml
	EndIf

Return( cRet )
//-------------------------------------------------------------------
/*/{Protheus.doc} VldChvRub
Fun��o que chama a valida��o das regras inclus�o e altera��o de eventos de tabelas
do e-social (VldEvTab), para a rotina Tabela de Rubricas

@Param
cCampo		- Campo posicionado na tela

@author Denis R. de Oliveira
@since 28/12/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Function VldChvRub( cCampo )

	Local lRet     := .T.

	Default cCampo := ""

	If cCampo == "C8R_CODRUB"
		lRet	:= VldEvTab("C8R",9,M->C8R_CODRUB+FWFLDGET("C8R_IDTBRU"),FWFLDGET("C8R_DTINI"),FWFLDGET("C8R_DTFIN"),1)
	ElseIf cCampo == "C8R_IDTBRU"
		lRet 	:= VldEvTab("C8R",9,FWFLDGET("C8R_CODRUB")+M->C8R_IDTBRU,FWFLDGET("C8R_DTINI"),FWFLDGET("C8R_DTFIN"),1)
	ElseIf cCampo == "C8R_DTINI"
		lRet	:= VldEvTab("C8R",9,FWFLDGET("C8R_CODRUB")+FWFLDGET("C8R_IDTBRU"),M->C8R_DTINI,FWFLDGET("C8R_DTFIN"),1)
	ElseIf cCampo == "C8R_DTFIN"
		lRet	:= VldEvTab("C8R",9,FWFLDGET("C8R_CODRUB")+FWFLDGET("C8R_IDTBRU"),FWFLDGET("C8R_DTINI"),M->C8R_DTFIN,1)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF232ExcAll
Fun��o que para excluir todas as rubricas
Criada para sanar a necessidade de limpar as rubricas mesmo ap�s uma transmiss�o

@Param

@author Felipe Rossi Moreira
@since 23/02/2018
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF232ExcAll()

	Local oProcessExc := nil
	Local cMensagem := ""

	cMensagem := "Confirma a exclus�o de todas as Rubricas?"+CRLF+CRLF
	cMensagem += "Esse procedimento exclui fisicamente os registro n�o enviados e cria o evento de exclus�o para os registros transmitidos com sucesso."

	If Aviso("Exclus�o Rubricas", cMensagem, {"Sim","N�o"}, 3) == 1
		oProcessExc := TAFProgress():New( { |lEnd| TAF232ExcRegs(@lEnd, @oProcessExc) }, "Execluindo Registros", .F. )
		oProcessExc:Activate()
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF232ExcRegs
La�o para exclus�o de todas as rubricas e intera��o com o TAFProgress

@Param
lEnd 	  - Controle de encerramento do progresso
oProcessExc - objeto de intera��o do progresso

@author Felipe Rossi Moreira
@since 23/02/2018
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF232ExcRegs(lEnd, oProcessExc)

	Local oModel
	Local oDlgMsg := Nil
	Local nQtdReg := 0
	Local cMsgErr := ""

	oProcessExc:Set1Progress(C8R->( RecCount() ))
	oModel := FWLoadModel("TAFA232")

	TAFConOut("Exclus�o de Rubricas")

	C8R->( dbSetOrder(1) )
	C8R->( dbGoTop() )
	C8R->( dbSeek(xFilial("C8R")) )

	while C8R->( !Eof() ) .And. C8R->C8R_FILIAL == xFilial("C8R")

		oProcessExc:Inc1Progress("Rubrica " + C8R->( AllTrim(C8R_CODRUB) +"/"+ AllTrim(C8R_IDTBRU) +" - "+ AllTrim(C8R_DESRUB) ))
		TAFConOut(Space(5)+"Rubrica " + C8R->( AllTrim(C8R_CODRUB) +"/"+ AllTrim(C8R_IDTBRU) +" - "+ AllTrim(C8R_DESRUB) ))

		If C8R->C8R_EVENTO <> 'E' .And. C8R->C8R_ATIVO == '1'

			oProcessExc:Set2Progress(3)
			oProcessExc:Inc2Progress("Abrindo")

			oModel:SetOperation(5)
			oModel:Activate()

			oProcessExc:Inc2Progress("Excluindo")

			If oModel:VldData()
				If oModel:CommitData()
					TAFConOut( Space(5)+Space(5) + "Registro excluido")
					nQtdReg ++
				Else
					TAFConOut( Space(5)+Space(5) + "Erro ao Executar o Commit")
				EndIf
			Else
				cMsgErr += "ID Rubrica:" + C8R->C8R_ID + " - " + AllTrim(oModel:GetErrorMessage()[6]) + Chr(13) + Chr(10)
				TAFConOut( Space(5)+Space(5) + AllTrim(oModel:GetErrorMessage()[6]))
			EndIf

			oModel:DeActivate()
			oProcessExc:Inc2Progress("Exclu�do")

		EndIf
		C8R->( dbSkip() )

	EndDo

	oModel:Destroy()

	oProcessExc:Inc1Progress( "Foram exclu�dos " + AllTrim(Str(nQtdReg)) + " registros." )
	oProcessExc:Inc2Progress( "Conclu�do" )

	MsgInfo( "Foram exclu�dos " + AllTrim(Str(nQtdReg)) + " registros." )

	If Len(cMsgErr) > 0

		oDlgMsg := FWDialogModal():New()
		oDlgMsg:SetTitle( "Motivo Rubricas n�o exclusas" )
		oDlgMsg:SetFreeArea( 250, 250 )
		oDlgMsg:SetEscClose( .T. )
		oDlgMsg:SetBackground( .T. )
		oDlgMsg:CreateDialog()
		oDlgMsg:AddCloseButton()

		TMultiGet():New( 030, 020, { || cMsgErr }, oDlgMsg:GetPanelMain(), 210, 190,, .T. ,,,, .T.,,,,,, .T.,,,,, .T. )

		oDlgMsg:Activate()

	EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCodRub
Posicionar na rubrica de acordo com o per�odo informado e se est� ativa.

@param cCodRub = C�digo da Rubrica.
@param cPerIni = AAAAMM
@param cPerFin = AAAAMM
@param cAtivo = '1' p/ Ativo ou '2' p/ Inativo

@author Caique Ferreira
@since 31/07/2018
@version 1.0

/*/
//--------------------------------------------------------------------

Function TAFCodRub(cCodRub, cPerIni, cPerFin , cAtivo, cIdTRub)

	Local aAreaAt   := getArea()
	Local cQuery    := ""
	Local nRecno    := 0
	Local lConsId   := .F.
	Local cTab      := ""
	Local lComp     := (Empty(xFilial("T3M"))) // Indica se a T3M est� compartilhada.
	Local cAliasC8R := GetNextAlias()

	Default cCodRub := ""
	Default cPerIni := ""
	Default cPerFin := ""
	Default cAtivo  := "1"
	Default cIdTRub := ""

	cPerini:=left(cPerIni, 6)

	If Empty(cPerIni)
		cPerIni := SubS(DTOS(dDatabase),1,6)
	EndIf

	If __lValidTabRub == NIL
		__lValidTabRub := IsDupT3M()
	EndIf

	If __aCodRub == NIL
		__aCodRub := {}
	EndIf

	If lComp .And. __lValidTabRub
		cQuery := "SELECT COUNT(*), C8R_CODRUB FROM " + RetSQLName("C8R") + " T0 "  + CRLF
		cQuery += "WHERE C8R_FILIAL = '" + xFilial("C8R") + "'"                     + CRLF
		cQuery += "AND C8R_ATIVO = '1'"                                             + CRLF
		cQuery += "AND C8R_PROTUL <> '" + Space(TamSX3("C8R_PROTUL")[1]) + "'"      + CRLF
		cQuery += "AND C8R_CODRUB = '" + cCodRub + "'"                              + CRLF
		cQuery += "AND D_E_L_E_T_ = ' '"                                            + CRLF
		cQuery += "GROUP BY C8R_CODRUB"                                             + CRLF
		cQuery += "HAVING COUNT(*) > 1"                                             + CRLF

		cTab := MPSysOpenQuery(ChangeQuery(cQuery))

		If ((cTab)->(!Eof()))
			lConsId := .T.
		EndIf

		(cTab)->(DbCloseArea())

	EndIf

	nPos := aScan(__aCodRub, {|x| (x[2]) == RetSQLName("C8R") + xFilial("C8R") + cCodRub + cIdTRub + cPerIni})

	If nPos > 0
		nRecno := __aCodRub[nPos][1]
	Else

		cQuery := " SELECT C8R.R_E_C_N_O_ C8R_RECONHECIMENTO, " 
		cQuery += " SUBSTRING(C8R.C8R_DTINI, 3,4) || SUBSTRING(C8R.C8R_DTINI, 1,2) AS DTINI, "
		cQuery += " SUBSTRING(C8R.C8R_DTFIN, 3,4) || SUBSTRING(C8R.C8R_DTFIN, 1,2) AS DTFIN, "
		cQuery += " C8R.C8R_CODRUB, C8R.C8R_ATIVO "
		cQuery += " FROM " + RetSqlName( "C8R" ) + " C8R "
		cQuery += " WHERE C8R.C8R_FILIAL ='" + xFilial("C8R") + "' "
		cQuery += " AND C8R.C8R_CODRUB = '" + cCodRub + "' "
		

		If !Empty(cIdTRub) .And. (!lComp .Or. lConsId)
			cQuery += " AND C8R.C8R_IDTBRU = '" + cIdTRub + "' "
		EndIf

		If !Empty(cAtivo)
			cQuery += " AND C8R.C8R_ATIVO = '"+cAtivo+"' "
		EndIf

		
		cQuery += " AND C8R.D_E_L_E_T_ = '' "
		cQuery += " ORDER BY DTINI DESC "

		cQuery := ChangeQuery( cQuery )


		TCQuery cQuery New Alias (cAliasC8R)

		While ( cAliasC8R )->( !Eof() )

			nPosRub := 0

			If (cAliasC8R)->DTINI <= cPerIni .And. ( Empty((cAliasC8R)->DTFIN) .Or. (cAliasC8R)->DTFIN >= cPerIni)
				nRecno := ( cAliasC8R )->C8R_RECONHECIMENTO
				Exit
			EndIf

			( cAliasC8R )->( DbSkip() )
		End

		( cAliasC8R )->( DBCloseArea() )

		aAdd(__aCodRub, {	nRecno;
										,RetSQLName("C8R") + xFilial("C8R") + cCodRub + cIdTRub + cPerIni;
										,lConsId})
	EndIf


	RestArea(aAreaAt)
Return nRecno

//-------------------------------------------------------------------
/*/{Protheus.doc} IsDupT3M
Verifica se a o ID da tabela de rubrica (T3M) est� compartilhada e
possui registros duplicados.

@author almeida.veronica
@since 18/02/2022
@version 1.0

/*/
//--------------------------------------------------------------------
Function IsDupT3M()
Local cQuery 	:= ""
Local cTab		:= ""
Local lRet		:= .F.

If Type('__cFilCache') <> 'C' .Or. (cEmpAnt + cFilAnt != __cFilCache) .Or. __lIsDupT3M == Nil
	
	cQuery := "SELECT COUNT(*), T3M_CODERP FROM " + RetSQLName("T3M") + " T0"   + CRLF
	cQuery += "WHERE T3M_FILIAL = '" + xFilial("T3M") + "'"                     + CRLF
	cQuery += "AND D_E_L_E_T_ = ' '"                                            + CRLF
	cQuery += "GROUP BY T3M_CODERP"                                             + CRLF
	cQuery += "HAVING COUNT(*) > 1"                                             + CRLF

	cTab := MPSysOpenQuery(ChangeQuery(cQuery))

	lRet := ((cTab)->(!Eof()))

	(cTab)->(DbCloseArea())
EndIf
Return lRet
