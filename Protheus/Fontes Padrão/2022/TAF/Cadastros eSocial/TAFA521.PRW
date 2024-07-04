#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA521.CH"
#INCLUDE "TOPCONN.CH"
 
Static lLaySimplif := taflayEsoc("S_01_00_00")

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA521
@type			function
@description	Informações do FGTS Consolidadas por Contribuinte - S-5013.
@author			Ricardo Lovrenovic
@since			26/12/2018
@version		1.0
/*/
//---------------------------------------------------------------------
Function TAFA521()

	Local cMessage	:=	""
	Private oBrowse	:=	FWMBrowse():New()

	If TAFAlsInDic( "V2Z" )

		oBrowse:SetDescription( STR0001 ) //"Informações do FGTS Consolidadas por Contribuinte"
		oBrowse:SetAlias( "V2Z" )
		oBrowse:SetMenuDef( "TAFA521" )

		oBrowse:SetFilterDefault( "V2Z_ATIVO == '1'" )

		oBrowse:Activate()

	Else

		cMessage := STR0002 //"Ambiente desatualizado com a versão do programa existente no repositório de dados."
		cMessage += Chr( 13 ) + Chr( 10 )
		cMessage += Chr( 13 ) + Chr( 10 )
		cMessage += STR0003 //"Execute a atualização do dicionário do Layout 2.5 do eSocial por meio do compatibilizador UPDDISTR."
		Aviso( STR0004, cMessage, { STR0005 }, 2 ) //##"Dicionário Incompatível" ##"Encerrar"
		
	EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@type			function
@description	Função genérica MVC do menu.
@author			Ricardo Lovrenovic
@since			26/12/2018
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina	:=	{}
	Local aFuncao	:=	{}

	aAdd( aFuncao, { "", "TAF521Xml", "1" } )
	aAdd( aFuncao, { "", "xFunHisAlt( 'V2Z', 'TAFA521' )", "3" } )
	aAdd( aFuncao, { "", "TAFXmlLote( 'V2Z', 'S-5013', 'evtFGTS', 'TAF521Xml' , , oBrowse )", "5" } )

	//Variável Private utilizada para controle do menu na chamada da View na operação de Histórico de Alterações
	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If lMenuDif
		ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TAFA521" OPERATION 2 ACCESS 0 //"Visualizar"
	Else
		aRotina := xFunMnuTAF( "TAFA521",, aFuncao )
	EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@type			function
@description	Função genérica MVC do modelo.
@author			Ricardo Lovrenovic
@since			26/12/2018
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStruV6N	:=	Nil
	Local oStruV6O	:=	Nil
	Local oStruV2Z	:=	FWFormStruct( 1, "V2Z" )
	Local oStruV20	:=	FWFormStruct( 1, "V20" )
	Local oStruV21	:=	FWFormStruct( 1, "V21" )
	Local oStruV22	:=	FWFormStruct( 1, "V22" )
	Local oStruV23	:=	FWFormStruct( 1, "V23" )
	Local oStruV24	:=	FWFormStruct( 1, "V24" )
	Local oStruV25	:=	FWFormStruct( 1, "V25" )
	Local oModel	:=	MPFormModel():New( "TAFA521",,, { |oModel| SaveModel( oModel ) } )

	If FWIsInCallStack("VldLayReg")
		lLaySimplif := Iif(Type("lLaySimV") == "U", lLaySimplif, lLaySimV)
	EndIf
	
	//Variável Private utilizada para controle do modelo na operação de integração via TAFAINTEG
	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If !lLaySimplif
		oStruV2Z:RemoveField( "V2Z_INDAPU" )
		oStruV20:RemoveField( "V20_INDINC" )
		oStruV20:RemoveField( "V20_VRFGTS" )
		oStruV22:RemoveField( "V22_INDINE" )
		oStruV22:RemoveField( "V22_VRFGTE" )
	Else
		oStruV6N :=	FWFormStruct( 1, "V6N" )
		oStruV6O :=	FWFormStruct( 1, "V6O" )
	EndIf

	If lVldModel
		oStruV2Z:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
		oStruV20:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
		oStruV21:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
		oStruV22:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
		oStruV23:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
		oStruV24:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
		oStruV25:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )

		If lLaySimplif
			oStruV6N:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
			oStruV6O:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
		EndIf
	EndIf

	oModel:AddFields( "MODEL_V2Z", /*cOwner*/, oStruV2Z )

	If lLaySimplif

		//Identificação do estabelecimento
		oModel:AddGrid( "MODEL_V6N", "MODEL_V2Z", oStruV6N )
		oModel:GetModel( "MODEL_V6N" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V6N" ):SetUniqueLine( { "V6N_TPINSC", "V6N_NRINSC" } )

		//Identificação da lotação tributária
		oModel:AddGrid( "MODEL_V6O", "MODEL_V6N", oStruV6O )
		oModel:GetModel( "MODEL_V6O" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V6O" ):SetUniqueLine( {  "V6O_CODLOT", "V6O_TPLOT", "V6O_TPINSC", "V6O_NRINSC" } )

		//Informações Consolidadas das Bases de Cálculo do FGTS do Período de Apuração e de Períodos Anteriores
		oModel:AddGrid( "MODEL_V20", "MODEL_V6O", oStruV20 )
		oModel:GetModel( "MODEL_V20" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V20" ):SetUniqueLine( { "V20_IDTPVL", "V20_INDINC" } )
		oModel:GetModel( "MODEL_V20" ):SetMaxLine( 99 )

		//Informações Referentes a Bases de Cálculo do FGTS de Períodos Anteriores
		oModel:AddGrid( "MODEL_V21", "MODEL_V6O", oStruV21 )
		oModel:GetModel( "MODEL_V21" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V21" ):SetUniqueLine( { "V21_PERREF", "V21_TPCONV" } )
		oModel:GetModel( "MODEL_V21" ):SetMaxLine( 180 )

		//Informações Consolidadas das Bases de Cálculo do FGTS de Períodos Anteriores
		oModel:AddGrid( "MODEL_V22", "MODEL_V21", oStruV22 )
		oModel:GetModel( "MODEL_V22" ):SetUniqueLine( { "V22_IDTPVL", "V22_INDINE" } )
		oModel:GetModel( "MODEL_V22" ):SetMaxLine( 99 )

	Else

		//Informações Consolidadas das Bases de Cálculo do FGTS do Período de Apuração e de Períodos Anteriores
		oModel:AddGrid( "MODEL_V20", "MODEL_V2Z", oStruV20 )
		oModel:GetModel( "MODEL_V20" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V20" ):SetUniqueLine( { "V20_IDTPVL" } )
		oModel:GetModel( "MODEL_V20" ):SetMaxLine( 21 )

		//Informações Referentes a Bases de Cálculo do FGTS de Períodos Anteriores
		oModel:AddGrid( "MODEL_V21", "MODEL_V2Z", oStruV21 )
		oModel:GetModel( "MODEL_V21" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V21" ):SetUniqueLine( { "V21_PERREF" } )
		oModel:GetModel( "MODEL_V21" ):SetMaxLine( 180 )

		//Informações Consolidadas das Bases de Cálculo do FGTS de Períodos Anteriores
		oModel:AddGrid( "MODEL_V22", "MODEL_V21", oStruV22 )
		oModel:GetModel( "MODEL_V22" ):SetUniqueLine( { "V22_IDTPVL" } )
		oModel:GetModel( "MODEL_V22" ):SetMaxLine( 11 )

		//Cálculo Consolidado dos Valores de FGTS a serem Depositados, Incidentes sobre a Remuneração do Período de Apuração e de Períodos Anteriores
		oModel:AddGrid( "MODEL_V23", "MODEL_V2Z", oStruV23 )
		oModel:GetModel( "MODEL_V23" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V23" ):SetUniqueLine( { "V23_IDTPDP" } )
		oModel:GetModel( "MODEL_V23" ):SetMaxLine( 20 )

		//Informações Referentes ao Cálculo dos Valores de FGTS de Períodos Anteriores
		oModel:AddGrid( "MODEL_V24", "MODEL_V2Z", oStruV24 )
		oModel:GetModel( "MODEL_V24" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V24" ):SetUniqueLine( { "V24_PERREF" } )
		oModel:GetModel( "MODEL_V24" ):SetMaxLine( 180 )

		//Cálculo Consolidado dos Valores de FGTS a serem Depositados, Incidentes sobre a Remuneração de Períodos Anteriores
		oModel:AddGrid( "MODEL_V25", "MODEL_V24", oStruV25 )
		oModel:GetModel( "MODEL_V25" ):SetUniqueLine( { "V25_IDTPDP" } )
		oModel:GetModel( "MODEL_V25" ):SetMaxLine( 10 )

	EndIf

	If lLaySimplif
		oModel:SetRelation("MODEL_V6N", {{"V6N_FILIAL", "xFilial('V6N')"}, {"V6N_ID", "V2Z_ID"}, {"V6N_VERSAO", "V2Z_VERSAO"}}, V6N->(IndexKey(1)))
		
		If TAFColumnPos("V20_TPLOT") .And. FWSIXUtil():ExistIndex("V20", "3")
			oModel:SetRelation("MODEL_V6O", {{"V6O_FILIAL", "xFilial('V6O')"}, {"V6O_ID", "V2Z_ID"}, {"V6O_VERSAO", "V2Z_VERSAO"}, {"V6O_ESTTP", "V6N_TPINSC"}, {"V6O_ESTNRI", "V6N_NRINSC"}}, V6O->(IndexKey(2)))
			oModel:SetRelation("MODEL_V20", {{"V20_FILIAL", "xFilial('V20')"}, {"V20_ID", "V2Z_ID"}, {"V20_VERSAO", "V2Z_VERSAO"}, {"V20_ESTTP", "V6N_TPINSC"}, {"V20_ESTNRI", "V6N_NRINSC"}, {"V20_CODLOT", "V6O_CODLOT"}, {"V20_TPLOT", "V6O_TPLOT"}, {"V20_TPINSC", "V6O_TPINSC"}, {"V20_NRINSC", "V6O_NRINSC"}}, V20->(IndexKey(3)))
			oModel:SetRelation("MODEL_V21", {{"V21_FILIAL", "xFilial('V21')"}, {"V21_ID", "V2Z_ID"}, {"V21_VERSAO", "V2Z_VERSAO"}, {"V21_ESTTP", "V6N_TPINSC"}, {"V21_ESTNRI", "V6N_NRINSC"}, {"V21_CODLOT", "V6O_CODLOT"}, {"V21_TPLOT", "V6O_TPLOT"}, {"V21_TPINSC", "V6O_TPINSC"}, {"V21_NRINSC", "V6O_NRINSC"}}, V21->( IndexKey(3)))
			oModel:SetRelation("MODEL_V22", {{"V22_FILIAL", "xFilial('V22')"}, {"V22_ID", "V2Z_ID"}, {"V22_VERSAO", "V2Z_VERSAO"}, {"V22_ESTTP", "V6N_TPINSC"}, {"V22_ESTNRI", "V6N_NRINSC"}, {"V22_CODLOT", "V6O_CODLOT"}, {"V22_TPLOT", "V6O_TPLOT"}, {"V22_TPINSC", "V6O_TPINSC"}, {"V22_NRINSC", "V6O_NRINSC"}	, {"V22_PERREF", "V21_PERREF"}, {"V22_TPCONV", "V21_TPCONV"}}, V22->(IndexKey(3)))
		Else
			oModel:SetRelation("MODEL_V6O", {{"V6O_FILIAL", "xFilial('V6O')"}, {"V6O_ID", "V2Z_ID"}, {"V6O_VERSAO", "V2Z_VERSAO"}, {"V6O_ESTTP"	, "V6N_TPINSC"}, {"V6O_ESTNRI", "V6N_NRINSC"}}	, V6O->(IndexKey(1)))
			oModel:SetRelation("MODEL_V20", {{"V20_FILIAL", "xFilial('V20')"}, {"V20_ID", "V2Z_ID"}, {"V20_VERSAO", "V2Z_VERSAO"}, {"V20_NRINSC", "V6O_NRINSC"}, {"V20_CODLOT", "V6O_CODLOT"}}	, V20->(IndexKey(2)))
			oModel:SetRelation("MODEL_V21", {{"V21_FILIAL", "xFilial('V21')"}, {"V21_ID", "V2Z_ID"}, {"V21_VERSAO", "V2Z_VERSAO"}, {"V21_NRINSC", "V6O_NRINSC"}, {"V21_CODLOT", "V6O_CODLOT"}}	, V21->(IndexKey(2)))
			oModel:SetRelation("MODEL_V22", {{"V22_FILIAL", "xFilial('V22')"}, {"V22_ID", "V2Z_ID"}, {"V22_VERSAO", "V2Z_VERSAO"}, {"V22_NRINSC", "V6O_NRINSC"}, {"V22_CODLOT", "V6O_CODLOT"}	, {"V22_PERREF", "V21_PERREF"}, {"V22_TPCONV", "V21_TPCONV"}}, V22->(IndexKey(2)))
		EndIf
	Else

		oModel:SetRelation( "MODEL_V20", { { "V20_FILIAL", "xFilial( 'V20' )" }, { "V20_ID", "V2Z_ID" }, { "V20_VERSAO", "V2Z_VERSAO" } }, V20->( IndexKey( 1 ) ) )
		oModel:SetRelation( "MODEL_V21", { { "V21_FILIAL", "xFilial( 'V21' )" }, { "V21_ID", "V2Z_ID" }, { "V21_VERSAO", "V2Z_VERSAO" } }, V21->( IndexKey( 1 ) ) )
		oModel:SetRelation( "MODEL_V22", { { "V22_FILIAL", "xFilial( 'V22' )" }, { "V22_ID", "V2Z_ID" }, { "V22_VERSAO", "V2Z_VERSAO" }, { "V22_PERREF", "V21_PERREF" } }, V22->( IndexKey( 1 ) ) )
		oModel:SetRelation( "MODEL_V23", { { "V23_FILIAL", "xFilial( 'V23' )" }, { "V23_ID", "V2Z_ID" }, { "V23_VERSAO", "V2Z_VERSAO" } }, V23->( IndexKey( 1 ) ) )
		oModel:SetRelation( "MODEL_V24", { { "V24_FILIAL", "xFilial( 'V24' )" }, { "V24_ID", "V2Z_ID" }, { "V24_VERSAO", "V2Z_VERSAO" } }, V24->( IndexKey( 1 ) ) )
		oModel:SetRelation( "MODEL_V25", { { "V25_FILIAL", "xFilial( 'V25' )" }, { "V25_ID", "V2Z_ID" }, { "V25_VERSAO", "V2Z_VERSAO" }, { "V25_PERREF", "V24_PERREF" } }, V25->( IndexKey( 1 ) ) )

	EndIf

	oModel:GetModel( "MODEL_V2Z" ):SetPrimaryKey( { "V2Z_PERAPU" } )

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@type			function
@description	Função genérica MVC da view.
@author			Ricardo Lovrenovic
@since			26/12/2018
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oStruV2Za	:=	Nil
	Local oStruV2Zb	:=	Nil
	Local oStruV6N	:=	Nil
	Local oStruV6O	:=	Nil
	Local oStruV20	:=	FWFormStruct( 2, "V20" )
	Local oStruV21	:=	FWFormStruct( 2, "V21" )
	Local oStruV22	:=	FWFormStruct( 2, "V22" )
	Local oStruV23	:=	FWFormStruct( 2, "V23" )
	Local oStruV24	:=	FWFormStruct( 2, "V24" )
	Local oStruV25	:=	FWFormStruct( 2, "V25" )
	Local oModel	:=	FWLoadModel( "TAFA521" )
	Local oView		:=	FWFormView():New()
	Local cCmpFil	:=	""

	If FWIsInCallStack("VldLayReg")
		lLaySimplif := Iif(Type("lLaySimV") == "U", lLaySimplif, lLaySimV)
	EndIf

	oView:SetModel( oModel )

	If lLaySimplif
		oView:SetContinuousForm(.T.)

		oStruV6N :=	FWFormStruct( 2, "V6N" )
		oStruV6O :=	FWFormStruct( 2, "V6O" )
	EndIf

	//Campos do Grupo Identificação do Evento de Retorno
	If !lLaySimplif
		cCmpFil := "V2Z_ID|V2Z_PERAPU|"
	Else
		cCmpFil := "V2Z_ID|V2Z_INDAPU|V2Z_PERAPU|"
	EndIf
	oStruV2Za := FWFormStruct( 2, "V2Z", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	//Campos do Grupo Informações Relativas ao FGTS
	cCmpFil := "V2Z_NRRECI|V2Z_EXFGTS|"
	oStruV2Zb := FWFormStruct( 2, "V2Z", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	/*--------------------------------------------------------------------------------------------
										Estrutura da View
	---------------------------------------------------------------------------------------------*/
	oView:AddField( "VIEW_V2Za", oStruV2Za, "MODEL_V2Z" )
	oView:EnableTitleView( "VIEW_V2Za", STR0007 ) //"Identificação do Evento de Retorno"

	oView:AddField( "VIEW_V2Zb", oStruV2Zb, "MODEL_V2Z" )
	oView:EnableTitleView( "VIEW_V2Zb", STR0008 ) //"Informações Relativas ao FGTS"

	If lLaySimplif

		oView:AddGrid( "VIEW_V6N", oStruV6N, "MODEL_V6N" )
		oView:EnableTitleView( "VIEW_V6N", STR0021 ) //"Identificação do estabelecimento ou obra de construção civil

		oView:AddGrid( "VIEW_V6O", oStruV6O, "MODEL_V6O" )
		oView:EnableTitleView( "VIEW_V6O", STR0022 ) //"Identificação da lotação tributária

		oView:AddGrid( "VIEW_V20", oStruV20, "MODEL_V20" )

		oView:AddGrid( "VIEW_V21", oStruV21, "MODEL_V21" )

		oView:AddGrid( "VIEW_V22", oStruV22, "MODEL_V22" )
		oView:EnableTitleView( "VIEW_V22", STR0009 ) //Informações consolidadas das bases de cálculo e valores do FGTS de períodos anteriores

	Else // Tratamento Simplificado 1.0

		oView:AddGrid( "VIEW_V20", oStruV20, "MODEL_V20" )

		oView:AddGrid( "VIEW_V21", oStruV21, "MODEL_V21" )

		oView:AddGrid( "VIEW_V22", oStruV22, "MODEL_V22" )
		oView:EnableTitleView( "VIEW_V22", STR0009 ) //Informações consolidadas das bases de cálculo e valores do FGTS de períodos anteriores

		oView:AddGrid( "VIEW_V23", oStruV23, "MODEL_V23" )

		oView:AddGrid( "VIEW_V24", oStruV24, "MODEL_V24" )

		oView:AddGrid( "VIEW_V25", oStruV25, "MODEL_V25" )
		oView:EnableTitleView( "VIEW_V25", STR0010 ) //"Cálculo Consolidado dos Valores de FGTS a serem Depositados, Incidentes sobre a Remuneração de Períodos Anteriores"

	EndIf

	/*-----------------------------------------------------------------------------------
									Estrutura do Folder
	-------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox( "PAINEL_SUPERIOR", 20 )
	oView:CreateHorizontalBox( "PAINEL_INTERMEDIARIO", 20 )

	oView:CreateHorizontalBox( "PAINEL_INFERIOR", 60 )
	oView:CreateFolder( "FOLDER_INFERIOR", "PAINEL_INFERIOR" )

	If lLaySimplif
	
		oView:AddSheet( "FOLDER_INFERIOR", "ABA01", STR0008 ) //Informações relativas ao FGTS

		oView:CreateHorizontalBox( "V6N", 20,,, "FOLDER_INFERIOR", "ABA01" )
		oView:CreateHorizontalBox( "V6O", 20,,, "FOLDER_INFERIOR", "ABA01" )
		
		oView:CreateHorizontalBox( "PAINEL_INFO_BASE_FGTS", 20,,, "FOLDER_INFERIOR", "ABA01" )
		oView:CreateFolder( "FOLDER_INFO_BASE_FGTS", "PAINEL_INFO_BASE_FGTS" )

		oView:AddSheet( "FOLDER_INFO_BASE_FGTS", "ABA01", STR0019 ) //"Informações Consolidadas das Bases de Cálculo do FGTS do Período de Apuração"

		oView:CreateHorizontalBox( "V20", 20,,, "FOLDER_INFO_BASE_FGTS", "ABA01" )

		oView:AddSheet( "FOLDER_INFO_BASE_FGTS", "ABA02", STR0020 ) //"Informações Referentes a Bases de Cálculo do FGTS de Períodos Anteriores"

		oView:CreateHorizontalBox( "V21", 20,,, "FOLDER_INFO_BASE_FGTS", "ABA02" )
		oView:CreateHorizontalBox( "V22", 20,,, "FOLDER_INFO_BASE_FGTS", "ABA02" )

	Else

		oView:AddSheet( "FOLDER_INFERIOR", "ABA01", STR0011 ) //"Informações Relativas a Base de Cálculo de FGTS"

		oView:CreateHorizontalBox( "PAINEL_INFO_BASE_FGTS", 100,,, "FOLDER_INFERIOR", "ABA01" )
		oView:CreateFolder( "FOLDER_INFO_BASE_FGTS", "PAINEL_INFO_BASE_FGTS" )

		oView:AddSheet( "FOLDER_INFO_BASE_FGTS", "ABA01", STR0012 ) //"Informações Consolidadas das Bases de Cálculo do FGTS do Período de Apuração"

		oView:CreateHorizontalBox( "V20", 100,,, "FOLDER_INFO_BASE_FGTS", "ABA01" )

		oView:AddSheet( "FOLDER_INFO_BASE_FGTS", "ABA02", STR0012 ) //"Informações Referentes a Bases de Cálculo do FGTS de Períodos Anteriores"

		oView:CreateHorizontalBox( "V21", 50,,, "FOLDER_INFO_BASE_FGTS", "ABA02" )
		oView:CreateHorizontalBox( "V22", 50,,, "FOLDER_INFO_BASE_FGTS", "ABA02" )

		oView:AddSheet( "FOLDER_INFERIOR", "ABA02", STR0014 ) //"Informações Relativas a Valores de FGTS"

		oView:CreateHorizontalBox( "PAINEL_INFO_VALOR_FGTS", 100,,, "FOLDER_INFERIOR", "ABA02" )
		oView:CreateFolder( "FOLDER_INFO_VALOR_FGTS", "PAINEL_INFO_VALOR_FGTS" )

		oView:AddSheet( "FOLDER_INFO_VALOR_FGTS", "ABA01", STR0015 ) //"Cálculo Consolidado dos Valores de FGTS a serem Depositados do Período de Apuração"

		oView:CreateHorizontalBox( "V23", 100,,, "FOLDER_INFO_VALOR_FGTS", "ABA01" )

		oView:AddSheet( "FOLDER_INFO_VALOR_FGTS", "ABA02", STR0016 ) //"Informações Referentes ao Cálculo dos Valores de FGTS de Períodos Anteriores"

		oView:CreateHorizontalBox( "V24", 50,,, "FOLDER_INFO_VALOR_FGTS", "ABA02" )
		oView:CreateHorizontalBox( "V25", 50,,, "FOLDER_INFO_VALOR_FGTS", "ABA02" )

	EndIf

	oView:SetOwnerView( "VIEW_V2Za", "PAINEL_SUPERIOR" )
	oView:SetOwnerView( "VIEW_V2Zb", "PAINEL_INTERMEDIARIO" )

	If lLaySimplif	

		oView:SetOwnerView( "VIEW_V6N", "V6N" )
		oView:SetOwnerView( "VIEW_V6O", "V6O" )
		oView:SetOwnerView( "VIEW_V20", "V20" )
		oView:SetOwnerView( "VIEW_V21", "V21" )
		oView:SetOwnerView( "VIEW_V22", "V22" )

	Else 

		oView:SetOwnerView( "VIEW_V20", "V20" )
		oView:SetOwnerView( "VIEW_V21", "V21" )
		oView:SetOwnerView( "VIEW_V22", "V22" )
		oView:SetOwnerView( "VIEW_V23", "V23" )
		oView:SetOwnerView( "VIEW_V24", "V24" )
		oView:SetOwnerView( "VIEW_V25", "V25" )

	EndIf

	oStruV2Za:RemoveField( "V2Z_ID" )

	If !lLaySimplif

		oStruV20:RemoveField( "V20_INDINC" )
		oStruV20:RemoveField( "V20_VRFGTS" )
		oStruV22:RemoveField( "V22_INDINE" )
		oStruV22:RemoveField( "V22_VRFGTE" )
		
	EndIf

Return( oView )

//---------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
@type			function
@description	Função de gravação dos dados, executada na confirmação do modelo.
@author			Ricardo Lovrenovic
@since			28/12/2018
@version		1.0
@param			oModel	-	Modelo de dados
/*/
//---------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local nOperation	:=	oModel:GetOperation()

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT

			oModel:LoadValue( "MODEL_V2Z", "V2Z_VERSAO", xFunGetVer() )

			FWFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE

			TAFAltStat( "V2Z", " " )

			FWFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_DELETE

			FWFormCommit( oModel )

		EndIf

	End Transaction

Return( .T. )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF521Grv
@type			function
@description	Função de integração dos dados para o evento S-5013.
@author			Ricardo Lovrenovic
@since			28/12/2018
@version		1.0
@param			cLayout	-	Nome do Layout que está sendo importado
@param			nOpc	-	Operação a ser executada ( 3 = Inclusão, 4 = Alteração, 5 = Exclusão )
@param			cFilEv	-	Filial do ERP para onde as informações devem ser importadas
@param			oXML	-	Objeto com o XML padronizado a ser importado
@return			lRet	-	Variável que indica se a importação foi realizada
@return			aIncons	-	Array com as inconsistências encontradas durante a importação
/*/
//---------------------------------------------------------------------
Function TAF521Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpEnv, cFilEnv, cXmlID, cEvtOri,lMigrador, lDepGPE, cKey, cMatrC9V, lLaySmpTot )

	Local oModel		:=	Nil
	Local cCmpsNoUpd	:=	"|V2Z_FILIAL|V2Z_ID|V2Z_VERSAO|V2Z_ATIVO|"
	Local cCabec		:=	"/eSocial/evtFGTS/"
	Local cInconMsg		:=	""
	Local cString		:=	""
	Local cRecibo		:=	""
	Local cPerRef		:=	""
	Local cFilBkp		:=	""
	Local cFilGrv		:=	""
	Local nI			:=	0
	Local nSeqErrGrv	:=	0
	Local dDtParam		:=	GetNewPar( "MV_TOTEXDT", SToD( "20991231" ) )
	Local dDtLegado		:=	SToD( "" )
	Local aIncons		:=	{}
	Local aRules		:=	{}
	Local aChave		:=	{}
	Local lRet			:=	.F.

	Private lVldModel	:=	.T. //Caso a chamada seja via integração, seto a variável de controle de validação como .T.
	Private oDados		:=	{}

	Default cLayout		:=	""
	Default nOpc		:=	1
	Default cFilEv		:=	""
	Default oXML		:=	Nil
	Default cOwner		:=  "" 
	Default cFilTran	:=  "" 
	Default cPredeces	:=  "" 
	Default nTafRecno	:=  0 
	Default cComplem	:=  ""  
	Default cGrpTran	:=  "" 
	Default cEmpEnv		:=  "" 
	Default cFilEnv		:=  "" 
	Default cXmlID		:=  "" 
	Default cEvtOri		:=  ""
	Default lMigrador	:= .F.
	Default lDepGPE		:= .F.
	Default cKey		:= ""
	Default cMatrC9V	:= ""

	If Type("lLaySmpTot") <> "L"
		lLaySmpTot	:= taflayEsoc("S_01_00_00")
	EndIf

	oDados := oXML

	If !TAFAlsInDic( "V2Z" )

		cString := STR0002 //"Ambiente desatualizado com a versão do programa existente no repositório de dados."
		cString += Chr( 13 ) + Chr( 10 )
		cString += Chr( 13 ) + Chr( 10 )
		cString += STR0003 //"Execute a atualização do dicionário do Layout 2.5 do eSocial por meio do compatibilizador UPDDISTR."

		aAdd( aIncons, cString )

		Return( { lRet, aIncons } )

	EndIf

	Begin Transaction

		cRecibo := FTAFGetVal( cCabec + "infoFGTS/nrRecArqBase", "C", .F.,, .T. )

		If SearchRec( cRecibo, @cFilGrv, @dDtLegado )
			cFilBkp := cFilAnt
			cFilAnt := cFilGrv
		EndIf

		cPeriodo := AllTrim(StrTran( FTAFGetVal( cCabec + "ideEvento/perApur", "C", .F.,, .T. ), "-", "" ))

		If Len(cPeriodo) == 6 // Caso o período esteja no formato AAAA/MM, grava no formato MM/AAAA para melhor experiência do usuário. Caso esteja no formato AAAA, será gravado da forma que veio no XML.
			cPeriodo := SubStr( cPeriodo, 5, 2 ) + SubStr( cPeriodo, 1, 4 )
		EndIf

		aAdd( aChave, { "C", "V2Z_PERAPU", cPeriodo, .T. } )

		//Função para validar se a operação desejada pode ser realizada
		If FTAFVldOpe( "V2Z", 2, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA521", cCmpsNoUpd )

			//Carrego array com os campos De/Para de gravação das informações
			aRules := TAF521Rul()

			//Quando se tratar de uma Exclusão Direta, apenas preciso realizar o Commit, não é necessária nenhuma manutenção nas informações
			If nOpc <> 5

				oModel:LoadValue( "MODEL_V2Z", "V2Z_FILIAL", V2Z->V2Z_FILIAL )
				oModel:LoadValue( "MODEL_V2Z", "V2Z_FILGRV", cFilAnt )

				If nOpc == 3
					oModel:LoadValue( "MODEL_V2Z", "V2Z_SITPAR", dDtParam )
				Else
					oModel:LoadValue( "MODEL_V2Z", "V2Z_SITPAR", dDtLegado )
				EndIf

				//Laço no aRules para gravar as informações
				For nI := 1 to Len( aRules )
					oModel:LoadValue( "MODEL_V2Z", aRules[nI,01], FTAFGetVal( aRules[nI,02], aRules[nI,03], aRules[nI,04], @aIncons, .F. ) )
				Next nI

				If lLaySmpTot

					/*----------------------------------------
					V6N - Identificação do estabelecimento ou obra de construção civil. 
					------------------------------------------*/
					nV6N := 1
					cV6NPath := cCabec + "infoFGTS/ideEstab[" + cValToChar( nV6N ) + "]"

					If nOpc == 4 .and. oDados:xPathHasNode( cV6NPath )

						For nI := 1 to oModel:GetModel( "MODEL_V6N" ):Length()
							oModel:GetModel( "MODEL_V6N" ):GoLine( nI )
							oModel:GetModel( "MODEL_V6N" ):DeleteLine()
						Next nI

					EndIf

					nV6N := 1

					While oDados:xPathHasNode( cV6NPath )

						If nOpc == 4 .or. nV6N > 1
							oModel:GetModel( "MODEL_V6N" ):LVALID := .T.
							oModel:GetModel( "MODEL_V6N" ):AddLine()
						EndIf

						If oDados:xPathHasNode( cV6NPath + "/tpInsc" )
							oModel:LoadValue( "MODEL_V6N", "V6N_TPINSC", FTAFGetVal( cV6NPath + "/tpInsc", "C", .F., @aIncons, .F. ) )
						EndIf

						If oDados:xPathHasNode( cV6NPath + "/nrInsc" )
							oModel:LoadValue( "MODEL_V6N", "V6N_NRINSC", FTAFGetVal( cV6NPath + "/nrInsc", "C", .F., @aIncons, .F. ) )
						EndIf

						/*----------------------------------------
						V6O - Identificação do estabelecimento ou obra de construção civil. 
						------------------------------------------*/
						nV6O := 1
						cV6OPath := cV6NPath + "/ideLotacao[" + cValToChar( nV6O ) + "]"

						If nOpc == 4 .and. oDados:xPathHasNode( cV6OPath )

							For nI := 1 to oModel:GetModel( "MODEL_V6O" ):Length()
								oModel:GetModel( "MODEL_V6O" ):GoLine( nI )
								oModel:GetModel( "MODEL_V6O" ):DeleteLine()
							Next nI

						EndIf

						nV6O := 1
						
						While oDados:xPathHasNode( cV6OPath )

							If nOpc == 4 .or. nV6O > 1
								oModel:GetModel( "MODEL_V6O" ):LVALID := .T.
								oModel:GetModel( "MODEL_V6O" ):AddLine()
							EndIf

							If oDados:xPathHasNode( cV6OPath + "/codLotacao" )
								oModel:LoadValue( "MODEL_V6O", "V6O_CODLOT", FGetIDInt( "codLotacao", "", cV6OPath + "/codLotacao",,,, @cInconMsg, @nSeqErrGrv ))
							EndIf

							If oDados:xPathHasNode( cV6OPath + "/tpLotacao" )
								oModel:LoadValue( "MODEL_V6O", "V6O_TPLOT", FGetIDInt( "tpLotacao", "", cV6OPath + "/tpLotacao",,,, @cInconMsg, @nSeqErrGrv ) )
							EndIf

							If oDados:xPathHasNode( cV6OPath + "/tpInsc" )
								oModel:LoadValue( "MODEL_V6O", "V6O_TPINSC", FTAFGetVal( cV6OPath + "/tpInsc", "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:xPathHasNode( cV6OPath + "/nrInsc" )
								oModel:LoadValue( "MODEL_V6O", "V6O_NRINSC", FTAFGetVal( cV6OPath + "/nrInsc", "C", .F., @aIncons, .F. ) )
							EndIf

							/*----------------------------------------
							V20 - Informações referentes a bases de cálculo e valores do FGTS no estabelecimento/lotação.
							------------------------------------------*/
							nV20 := 1
							cV20Path := cV6OPath + "/infoBaseFGTS/basePerApur[" + cValToChar( nV20 ) + "]"

							If nOpc == 4 .and. oDados:xPathHasNode( cV20Path )

								For nI := 1 to oModel:GetModel( "MODEL_V20" ):Length()
									oModel:GetModel( "MODEL_V20" ):GoLine( nI )
									oModel:GetModel( "MODEL_V20" ):DeleteLine()
								Next nI

							EndIf

							nV20 := 1

							While oDados:xPathHasNode( cV20Path )

								If nOpc == 4 .or. nV20 > 1
									oModel:GetModel( "MODEL_V20" ):LVALID := .T.
									oModel:GetModel( "MODEL_V20" ):AddLine()
								EndIf

								If oDados:xPathHasNode( cV20Path + "/tpValor" )
									oModel:LoadValue( "MODEL_V20", "V20_IDTPVL", FGetIDInt( "tpValorE", "", cV20Path + "/tpValor",,,, @cInconMsg, @nSeqErrGrv ) )
								EndIf

								If oDados:xPathHasNode( cV20Path + "/indIncid" )
									oModel:LoadValue( "MODEL_V20", "V20_INDINC", FTAFGetVal( cV20Path + "/indIncid", "C", .F., @aIncons, .F. ) )
								EndIf

								If oDados:xPathHasNode( cV20Path + "/baseFGTS" )
									oModel:LoadValue( "MODEL_V20", "V20_VLFGTS", FTAFGetVal( cV20Path + "/baseFGTS", "N", .F., @aIncons, .F. ) )
								EndIf

								If oDados:xPathHasNode( cV20Path + "/vrFGTS" )
									oModel:LoadValue( "MODEL_V20", "V20_VRFGTS", FTAFGetVal( cV20Path + "/vrFGTS", "N", .F., @aIncons, .F. ) )
								EndIf

								nV20 ++
								cV20Path := cV6OPath + "/infoBaseFGTS/basePerApur[" + cValToChar( nV20 ) + "]"
								
							EndDo	

							/*----------------------------------------
							V21 - Informações Referentes a Bases de Cálculo do FGTS de Períodos Anteriores
							------------------------------------------*/
							nV21 := 1
							cV21Path := cV6OPath + "/infoBaseFGTS/infoBasePerAntE[" + cValToChar( nV21 ) + "]"

							If nOpc == 4 .and. oDados:xPathHasNode( cV21Path )

								For nI := 1 to oModel:GetModel( "MODEL_V21" ):Length()
									oModel:GetModel( "MODEL_V21" ):GoLine( nI )
									oModel:GetModel( "MODEL_V21" ):DeleteLine()
								Next nI

							EndIf

							nV21 := 1

							While oDados:xPathHasNode( cV21Path )

								If nOpc == 4 .or. nV21 > 1
									oModel:GetModel( "MODEL_V21" ):LVALID := .T.
									oModel:GetModel( "MODEL_V21" ):AddLine()
								EndIf

								If oDados:xPathHasNode( cV21Path + "/perRef" )
									cPerRef := StrTran( FTAFGetVal( cV21Path + "/perRef", "C", .F., @aIncons, .F. ), "-", "" )
									cPerRef := SubStr( cPerRef, 5, 2 ) + SubStr( cPerRef, 1, 4 )
									oModel:LoadValue( "MODEL_V21", "V21_PERREF", cPerRef )
								EndIf

								If oDados:xPathHasNode( cV21Path + "/tpAcConv" )
									oModel:LoadValue( "MODEL_V21", "V21_TPCONV", FTAFGetVal( cV21Path + "/tpAcConv", "C", .F., @aIncons, .F. ) )
								EndIf

								/*----------------------------------------
								V22 - Informações Consolidadas das Bases de Cálculo do FGTS de Períodos Anteriores
								------------------------------------------*/
								nV22 := 1
								cV22Path := cV21Path + "/basePerAntE[" + cValToChar( nV22 ) + "]"

								If nOpc == 4 .and. oDados:xPathHasNode( cV22Path )

									For nI := 1 to oModel:GetModel( "MODEL_V22" ):Length()
										oModel:GetModel( "MODEL_V22" ):GoLine( nI )
										oModel:GetModel( "MODEL_V22" ):DeleteLine()
									Next nI

								EndIf

								nV22 := 1

								While oDados:xPathHasNode( cV22Path )

									If nOpc == 4 .or. nV22 > 1
										oModel:GetModel( "MODEL_V22" ):LVALID := .T.
										oModel:GetModel( "MODEL_V22" ):AddLine()
									EndIf

									If oDados:xPathHasNode( cV22Path + "/tpValorE" )
										oModel:LoadValue( "MODEL_V22", "V22_IDTPVL", FGetIDInt( "tpValorE", "", cV22Path + "/tpValorE",,,, @cInconMsg, @nSeqErrGrv ) )
									EndIf

									If oDados:xPathHasNode( cV22Path + "/indIncidE" )
										oModel:LoadValue( "MODEL_V22", "V22_INDINE", FTAFGetVal( cV22Path + "/indIncidE", "C", .F., @aIncons, .F. ) )
									EndIf

									If oDados:xPathHasNode( cV22Path + "/baseFGTSE" )
										oModel:LoadValue( "MODEL_V22", "V22_VLFGTS", FTAFGetVal( cV22Path + "/baseFGTSE", "N", .F., @aIncons, .F. ) )
									EndIf

									If oDados:xPathHasNode( cV22Path + "/vrFGTSE" )
										oModel:LoadValue( "MODEL_V22", "V22_VRFGTE", FTAFGetVal( cV22Path + "/vrFGTSE", "N", .F., @aIncons, .F. ) )
									EndIf

									nV22 ++
									cV22Path := cV21Path + "/basePerAntE[" + cValToChar( nV22 ) + "]"

								EndDo

								nV21 ++
								cV21Path := cV6OPath + "/infoBaseFGTS/infoBasePerAntE[" + cValToChar( nV21 ) + "]"
								
							EndDo

							nV6O ++
							cV6OPath := cCabec + "infoFGTS/ideEstab[" + cValToChar( nV6N ) + "]/ideLotacao[" + cValToChar( nV6O ) + "]"

						EndDo

						nV6N ++
						cV6NPath := cCabec + "infoFGTS/ideEstab[" + cValToChar( nV6N ) + "]"

					EndDo

				Else

					/*----------------------------------------
					V20 - Informações Consolidadas das Bases de Cálculo do FGTS do Período de Apuração e de Períodos Anteriores
					------------------------------------------*/
					nV20 := 1
					cV20Path := cCabec + "infoFGTS/infoBaseFGTS/basePerApur[" + cValToChar( nV20 ) + "]"

					If nOpc == 4 .and. oDados:xPathHasNode( cV20Path )

						For nI := 1 to oModel:GetModel( "MODEL_V20" ):Length()
							oModel:GetModel( "MODEL_V20" ):GoLine( nI )
							oModel:GetModel( "MODEL_V20" ):DeleteLine()
						Next nI

					EndIf

					nV20 := 1

					While oDados:xPathHasNode( cV20Path )

						If nOpc == 4 .or. nV20 > 1
							oModel:GetModel( "MODEL_V20" ):LVALID := .T.
							oModel:GetModel( "MODEL_V20" ):AddLine()
						EndIf

						If oDados:xPathHasNode( cV20Path + "/tpValor" )
							oModel:LoadValue( "MODEL_V20", "V20_IDTPVL", FGetIDInt( "tpValorE", "", cV20Path + "/tpValor",,,, @cInconMsg, @nSeqErrGrv ) )
						EndIf

						If oDados:xPathHasNode( cV20Path + "/baseFGTS" )
							oModel:LoadValue( "MODEL_V20", "V20_VLFGTS", FTAFGetVal( cV20Path + "/baseFGTS", "N", .F., @aIncons, .F. ) )
						EndIf

						nV20 ++
						cV20Path := cCabec + "infoFGTS/infoBaseFGTS/basePerApur[" + cValToChar( nV20 ) + "]"

					EndDo

					/*----------------------------------------
					V21 - Informações Referentes a Bases de Cálculo do FGTS de Períodos Anteriores
					------------------------------------------*/
					nV21 := 1
					cV21Path := cCabec + "infoFGTS/infoBaseFGTS/infoBasePerAntE[" + cValToChar( nV21 ) + "]"

					If nOpc == 4 .and. oDados:xPathHasNode( cV21Path )

						For nI := 1 to oModel:GetModel( "MODEL_V21" ):Length()
							oModel:GetModel( "MODEL_V21" ):GoLine( nI )
							oModel:GetModel( "MODEL_V21" ):DeleteLine()
						Next nI

					EndIf

					nV21 := 1

					While oDados:xPathHasNode( cV21Path )

						If nOpc == 4 .or. nV21 > 1
							oModel:GetModel( "MODEL_V21" ):LVALID := .T.
							oModel:GetModel( "MODEL_V21" ):AddLine()
						EndIf

						If oDados:xPathHasNode( cV21Path + "/perRef" )
							cPerRef := StrTran( FTAFGetVal( cV21Path + "/perRef", "C", .F., @aIncons, .F. ), "-", "" )
							cPerRef := SubStr( cPerRef, 5, 2 ) + SubStr( cPerRef, 1, 4 )
							oModel:LoadValue( "MODEL_V21", "V21_PERREF", cPerRef )
						EndIf

						If TafColumnPos("V21_TPCONV")
							If oDados:xPathHasNode( cV21Path + "/tpAcConv" )
								oModel:LoadValue( "MODEL_V21", "V21_TPCONV", FTAFGetVal( cV21Path + "/tpAcConv", "C", .F., @aIncons, .F. ) )
							EndIf
						EndIf

						/*----------------------------------------
						V22 - Informações Consolidadas das Bases de Cálculo do FGTS de Períodos Anteriores
						------------------------------------------*/
						nV22 := 1
						cV22Path := cV21Path + "/basePerAntE[" + cValToChar( nV22 ) + "]"

						If nOpc == 4 .and. oDados:xPathHasNode( cV22Path )

							For nI := 1 to oModel:GetModel( "MODEL_V22" ):Length()
								oModel:GetModel( "MODEL_V22" ):GoLine( nI )
								oModel:GetModel( "MODEL_V22" ):DeleteLine()
							Next nI

						EndIf

						nV22 := 1

						While oDados:xPathHasNode( cV22Path )

							If nOpc == 4 .or. nV22 > 1
								oModel:GetModel( "MODEL_V22" ):LVALID := .T.
								oModel:GetModel( "MODEL_V22" ):AddLine()
							EndIf

							If oDados:xPathHasNode( cV22Path + "/tpValorE" )
								oModel:LoadValue( "MODEL_V22", "V22_IDTPVL", FGetIDInt( "tpValorE", "", cV22Path + "/tpValorE",,,, @cInconMsg, @nSeqErrGrv ) )
							EndIf

							If oDados:xPathHasNode( cV22Path + "/baseFGTSE" )
								oModel:LoadValue( "MODEL_V22", "V22_VLFGTS", FTAFGetVal( cV22Path + "/baseFGTSE", "N", .F., @aIncons, .F. ) )
							EndIf

							nV22 ++
							cV22Path := cV21Path + "/basePerAntE[" + cValToChar( nV22 ) + "]"

						EndDo

						nV21 ++
						cV21Path := cCabec + "infoFGTS/infoBaseFGTS/infoBasePerAntE[" + cValToChar( nV21 ) + "]"

					EndDo

					/*----------------------------------------
					V23 - Cálculo Consolidado dos Valores de FGTS a serem Depositados, Incidentes sobre a Remuneração do Período de Apuração e de Períodos Anteriores
					------------------------------------------*/
					nV23 := 1
					cV23Path := cCabec + "/infoFGTS/infoDpsFGTS/dpsPerApur[" + cValToChar( nV23 ) + "]"

					If nOpc == 4 .and. oDados:xPathHasNode( cV23Path )

						For nI := 1 to oModel:GetModel( "MODEL_V23" ):Length()
							oModel:GetModel( "MODEL_V23" ):GoLine( nI )
							oModel:GetModel( "MODEL_V23" ):DeleteLine()
						Next nI
					EndIf

					nV23 := 1

					While oDados:xPathHasNode( cV23Path )

						If nOpc == 4 .or. nV23 > 1
							oModel:GetModel( "MODEL_V23" ):LVALID := .T.
							oModel:GetModel( "MODEL_V23" ):AddLine()
						EndIf

						If oDados:xPathHasNode( cV23Path + "/tpDps" )
							oModel:LoadValue( "MODEL_V23", "V23_IDTPDP", FGetIDInt( "tpDpsE", "", cV23Path + "/tpDps",,,, @cInconMsg, @nSeqErrGrv ) )
						EndIf

						If oDados:xPathHasNode( cV23Path + "/vrFGTS" )
							oModel:LoadValue( "MODEL_V23", "V23_VLFGTS", FTAFGetVal( cV23Path + "/vrFGTS", "N", .F., @aIncons, .F. ) )
						EndIf

						nV23 ++
						cV23Path := cCabec + "/infoFGTS/infoDpsFGTS/dpsPerApur[" + cValToChar( nV23 ) + "]"

					EndDo

					/*----------------------------------------
					V24 - Informações Referentes ao Cálculo dos Valores de FGTS de Períodos Anteriores
					------------------------------------------*/
					nV24 := 1
					cV24Path := cCabec + "infoFGTS/infoDpsFGTS/infoDpsPerAntE[" + cValToChar( nV24 ) + "]"

					If nOpc == 4 .and. oDados:xPathHasNode( cV24Path )

						For nI := 1 to oModel:GetModel( "MODEL_V24" ):Length()
							oModel:GetModel( "MODEL_V24" ):GoLine( nI )
							oModel:GetModel( "MODEL_V24" ):DeleteLine()
						Next nI

					EndIf

					nV24 := 1

					While oDados:xPathHasNode( cV24Path )

						If nOpc == 4 .or. nV24 > 1
							oModel:GetModel( "MODEL_V24" ):LVALID := .T.
							oModel:GetModel( "MODEL_V24" ):AddLine()
						EndIf

						If oDados:xPathHasNode( cV24Path + "/perRef" )
							cPerRef := StrTran( FTAFGetVal( cV24Path + "/perRef", "C", .F., @aIncons, .F. ), "-", "" )
							cPerRef := SubStr( cPerRef, 5, 2 ) + SubStr( cPerRef, 1, 4 )
							oModel:LoadValue( "MODEL_V24", "V24_PERREF", cPerRef )
						EndIf

						If TafColumnPos("V24_TPCONV")
							If oDados:xPathHasNode( cV24Path + "/tpAcConv" )
								oModel:LoadValue( "MODEL_V24", "V24_TPCONV", FTAFGetVal( cV24Path + "/tpAcConv", "C", .F., @aIncons, .F. ) )
							EndIf
						EndIf

						/*----------------------------------------
						V25 - Cálculo Consolidado dos Valores de FGTS a serem Depositados, Incidentes sobre a Remuneração de Períodos Anteriores
						------------------------------------------*/
						nV25 := 1
						cV25Path := cV24Path + "/dpsPerAntE[" + cValToChar( nV25 ) + "]"

						If nOpc == 4 .and. oDados:xPathHasNode( cV25Path )

							For nI := 1 to oModel:GetModel( "MODEL_V25" ):Length()
								oModel:GetModel( "MODEL_V25" ):GoLine( nI )
								oModel:GetModel( "MODEL_V25" ):DeleteLine()
							Next nI

						EndIf

						nV25 := 1

						While oDados:xPathHasNode( cV25Path )

							If nOpc == 4 .or. nV25 > 1
								oModel:GetModel( "MODEL_V25" ):LVALID := .T.
								oModel:GetModel( "MODEL_V25" ):AddLine()
							EndIf

							If oDados:xPathHasNode( cV25Path + "/tpDpsE" )
								oModel:LoadValue( "MODEL_V25", "V25_IDTPDP", FGetIDInt( "tpDpsE", "", cV25Path + "/tpDpsE",,,, @cInconMsg, @nSeqErrGrv ) )
							EndIf

							If oDados:xPathHasNode( cV25Path + "/vrFGTSE" )
								oModel:LoadValue( "MODEL_V25", "V25_VLFGTS", FTAFGetVal( cV25Path + "/vrFGTSE", "N", .F., @aIncons, .F. ) )
							EndIf

							nV25 ++
							cV25Path := cV24Path + "/dpsPerAntE[" + cValToChar( nV25 ) + "]"

						EndDo

						nV24 ++
						cV24Path := cCabec + "infoFGTS/infoDpsFGTS/infoDpsPerAntE[" + cValToChar( nV24 ) + "]"

					EndDo

				EndIf

			EndIf	

		EndIf

		//Efetiva a operação desejada
		If Empty( cInconMsg )

			If TAFFormCommit( oModel )

				aAdd( aIncons, "ERRO19" )
				cString += "- Totalizador aIncons ERRO19 - " + Chr( 13 ) + Chr( 10 )
				TAFConOut( "- totalizador aIncons ERRO19 -" )

				For nI := 1 to Len( aIncons )
					If Len( aIncons[nI] ) >= 1
						cString += "- Totalizador aIncons - " + aIncons[nI] + Chr( 13 ) + Chr( 10 )
						TAFConOut( "- totalizador aIncons - " + aIncons[nI] + " - " )
					EndIf
				Next nI

			Else
				lRet := .T.
			EndIf

		Else

			aAdd( aIncons, cInconMsg )
			cString += "| Totalizador aIncons | " + cInconMsg + Chr( 13 ) + Chr( 10 )
			TAFConOut( "| Totalizador aIncons | " + cInconMsg )

			For nI := 1 to Len( aIncons )
				If Len( aIncons[nI] ) >= 1
					cString += "| Totalizador aIncons | " + aIncons[nI] + Chr( 13 ) + Chr( 10 )
					TAFConOut( "| Totalizador aIncons | " + aIncons[nI] + " | " )
				EndIf
			Next nI

		EndIf

		If !Empty( cString )
			MakeDir( GetSrvProfString( "rootpath", "" ) + "\profile\" )
			MemoWrite( GetSrvProfString( "rootpath", "" ) + "\profile\" + "logtot-" + StrTran( DToC( Date() ), "/", "" ) + "-" + StrTran( Time(), ":", "" ) + ".txt", cString )
		EndIf

		oModel:DeActivate()

		If !( Empty( cFilBkp ) )
			cFilAnt := cFilBkp
		EndIf

	End Transaction

	//Zerando os arrays e os objetos utilizados no processamento
	aSize( aRules, 0 )
	aRules := Nil

	aSize( aChave, 0 )
	aChave := Nil

	oModel := Nil

Return( { lRet, aIncons } )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF521Rul
@type			function
@description	Regras para gravação das informações do Evento S-5013 do eSocial
@author			Ricardo Lovrenovic
@since			28/12/2018
@version		1.0
@return			aRull	-	Regras para a gravação das informações
/*/
//---------------------------------------------------------------------
Static Function TAF521Rul()

	Local aRull		:= {}
	Local aIncons	:= {}
	Local cCabec	:= "/eSocial/evtFGTS/"
	Local cPeriodo	:= AllTrim(StrTran( FTAFGetVal( cCabec + "ideEvento/perApur", "C", .F.,@aIncons, .T. ), "-", "" ))

	If Len(cPeriodo) == 6 // Caso o período esteja no formato AAAA/MM, grava no formato MM/AAAA para melhor experiência do usuário. Caso esteja no formato AAAA, será gravado da forma que veio no XML.
		cPeriodo := SubStr( cPeriodo, 5, 2 ) + SubStr( cPeriodo, 1, 4 )
	EndIf

	If lLaySimplif
		aAdd( aRull, { "V2Z_INDAPU", FTAFGetVal( cCabec + "ideEvento/indApuracao"	, "C", .F.,@aIncons, .T. ), "C", .T. } )
	EndIf

	aAdd( aRull, { "V2Z_PERAPU", cPeriodo, "C", .T. } )
	aAdd( aRull, { "V2Z_NRRECI", FTAFGetVal( cCabec + "infoFGTS/nrRecArqBase"	, "C", .F.,@aIncons, .T. ), "C", .T. } )
	aAdd( aRull, { "V2Z_EXFGTS", FTAFGetVal( cCabec + "infoFGTS/indExistInfo"	, "C", .F.,@aIncons, .T. ), "C", .T. } )

Return( aRull )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF521Xml
@type			function
@description	Função de geração do XML para o Evento S-5013.
@author			Ricardo Lovrenovic
@since			28/12/2018
@version		1.0
@return			cXml	-	Estrutura do XML do Layout S-5013
/*/
//---------------------------------------------------------------------
Function TAF521Xml(cAlias as character, nRecno as numeric, nOpc as numeric, lJob as logical)

	Local aMensal    	as array
	Local cXml       	as character
	Local cXmIdeLot  	as character
	Local cXmlIfBsFG 	as character
	Local cXmlBsApur 	as character
	Local cXmlIfBsAn 	as character
	Local cXmlBsAntE 	as character
	Local cLayout    	as character
	Local cReg       	as character
	Local lSeekV20   	as logical
	Local lSeekV21   	as logical
	Local lSeekV23   	as logical
	Local lSeekV24   	as logical
	Local lTroca     	as logical
	Local nIndex     	as numeric
	Local nIndexV6O    	as numeric

	Default cAlias   	:= "V2Z"
	Default lJob   		:= .F.
	Default nRecno   	:= 0
	Default nOpc   		:= 0
	
	aMensal   	:= {}
	cXml      	:= ""
	cXmIdeLot 	:= ""
	cXmlIfBsFG	:= ""
	cXmlBsApur	:= ""
	cXmlIfBsAn	:= ""
	cXmlBsAntE	:= ""
	cLayout   	:= "5013"
	cReg      	:= "FGTS"
	lSeekV20  	:= .F.
	lSeekV21  	:= .F.
	lSeekV23  	:= .F.
	lSeekV24  	:= .F.
	lTroca    	:= VldLayReg(.F., V2Z->V2Z_INDAPU, "TAFA521", @lLaySimplif)
	nIndex    	:= 0
	nIndexV6O	:= 0

	cXml 		+= "<infoFGTS>"
	cXml 		+= xTafTag("nrRecArqBase", V2Z->V2Z_NRRECI,, .F.)
	cXml 		+= xTafTag("indExistInfo", V2Z->V2Z_EXFGTS,, .F.)

	If lLaySimplif
		V6N->(DBSetOrder(1))

		If V6N->(MsSeek(xFilial("V6N") + V2Z->(V2Z_ID + V2Z_VERSAO)))
			If TAFColumnPos("V20_TPLOT") .And. FWSIXUtil():ExistIndex("V20", "3")
				cV6O 		:= "V6O_ID + V6O_VERSAO + V6O_ESTTP + V6O_ESTNRI + V6O_CODLOT + V6O_TPLOT + V6O_TPINSC + V6O_NRINSC"
				cV20 		:= "V20_ID + V20_VERSAO + V20_ESTTP + V20_ESTNRI + V20_CODLOT + V20_TPLOT + V20_TPINSC + V20_NRINSC"
				cV21 		:= "V21_ID + V21_VERSAO + V21_ESTTP + V21_ESTNRI + V21_CODLOT + V21_TPLOT + V21_TPINSC + V21_NRINSC" 
				cV22 		:= "V22_ID + V22_VERSAO + V22_ESTTP + V22_ESTNRI + V22_CODLOT + V22_TPLOT + V22_TPINSC + V22_NRINSC + V22_PERREF + V22_TPCONV"
				nIndex 		:= 3
				nIndexV6O	:= 2
			Else
				cV6O 		:= "V6O_ID + V6O_VERSAO + V6O_NRINSC + V6O_CODLOT"
				cV20 		:= "V20_ID + V20_VERSAO + V20_NRINSC + V20_CODLOT"
				cV21 		:= "V21_ID + V21_VERSAO + V21_NRINSC + V21_CODLOT" 
				cV22 		:= "V22_ID + V22_VERSAO + V22_NRINSC + V22_CODLOT + V22_PERREF + V22_TPCONV" 
				nIndexV6O	:= 1
				nIndex 		:= 2
			EndIf

			V6O->(DBSetOrder(nIndexV6O))
			V20->(DBSetOrder(nIndex))
			V21->(DBSetOrder(nIndex))
			V22->(DBSetOrder(nIndex))

			While !V6N->(EOF()) .And. V6N->(V6N_FILIAL + V6N_ID + V6N_VERSAO) == xFilial("V6N") + V2Z->(V2Z_ID + V2Z_VERSAO)  
				cXmIdeLot := ""
				
				If V6O->(MsSeek(xFilial("V6O") + V6N->(V6N_ID + V6N_VERSAO + V6N_TPINSC + V6N_NRINSC)))
					While !V6O->(EOF()) .And. V6O->(V6O_FILIAL + V6O_ID + V6O_VERSAO + V6O_ESTTP + V6O_ESTNRI) == xFilial("V6O") + V6N->(V6N_ID + V6N_VERSAO + V6N_TPINSC + V6N_NRINSC)                                                                                     
						cXmlBsApur 	:= ""
						cXmlIfBsAn	:= ""
						cXmlIfBsFG	:= ""
						
						If V20->(MsSeek(xFilial("V20") + V6O->(&(cV6O))))
							While !V20->(EOF()) .And. V20->(V20_FILIAL + &(cV20)) == xFilial("V20") + V6O->(&(cV6O))                                                              
								xTafTagGroup("basePerApur"																						;
												, {	{"tpValor"	, Posicione("V26", 1, xFilial("V26") + V20->V20_IDTPVL, "V26_CODIGO")	,, .F.}	;
												,	{"indIncid"	, V20->V20_INDINC														,, .F.}	;
												,  	{"baseFGTS"	, V20->V20_VLFGTS														,, .F.}	;
												,  	{"vrFGTS"	, V20->V20_VRFGTS														,, .T.}};
												, @cXmlBsApur)

								V20->(DBSkip())
							EndDo
						EndIf                                                                                     

						If V21->(MsSeek(xFilial("V21") + V6O->(&(cV6O))))
							While !V21->(EOF()) .And. V21->(V21_FILIAL + &(cV21)) == xFilial("V21") + V6O->(&(cV6O))     
								cXmlBsAntE := ""
								
								If V22->(MsSeek(xFilial("V22") + V21->(&(cV21) + V21_PERREF + V21_TPCONV)))                                                                                           
									While !V22->(EOF()) .And. V22->(V22_FILIAL + &(cV22)) == xFilial("V22") + V21->(&(cV21) + V21_PERREF + V21_TPCONV)     
										cXmlBsAntE += "<basePerAntE>"
										cXmlBsAntE += xTafTag("tpValorE"	, Posicione("V26", 1, xFilial("V26") + V22->V22_IDTPVL, "V26_CODIGO")	,, .F.)
										cXmlBsAntE += xTafTag("indIncidE"	, V22->V22_INDINE 														,, .F.)
										cXmlBsAntE += xTafTag("baseFGTSE"	, V22->V22_VLFGTS 														,, .F.)
										cXmlBsAntE += xTafTag("vrFGTSE"		, V22->V22_VRFGTE 														,, .T.)	
										cXmlBsAntE += "</basePerAntE>"

										V22->(DBSkip())
									EndDo
								EndIf	

								xTafTagGroup("infoBasePerAntE";
												, {	{"perRef"	, SubStr(V21->V21_PERREF, 3, 4) + "-" + SubStr(V21->V21_PERREF, 1, 2)	,, .F.}	;
												, 	{"tpAcConv"	, V21->V21_TPCONV														,, .F.}}; 
												, @cXmlIfBsAn																					;
												, {	{"basePerAntE", cXmlBsAntE, 1}}																;
												, .F., .F.)

								V21->(DBSkip())
							EndDo
						EndIf

						xTafTagGroup("infoBaseFGTS",									; 
										, @cXmlIfBsFG									;
										, {	{ "basePerApur"		, cXmlBsApur	, 0 }	;
										, 	{ "infoBasePerAntE"	, cXmlIfBsAn	, 0 }}	;
										, .F., .T.)

						cXmIdeLot += "<ideLotacao>"
						cXmIdeLot += xTafTag("codLotacao"	, Posicione("C99", 1, xFilial("C99") + V6O->V6O_CODLOT	, "C99_CODIGO")	,, .F.)
						cXmIdeLot += xTafTag("tpLotacao"	, Posicione("C8F", 1, xFilial("C8F") + V6O->V6O_TPLOT	, "C8F_CODIGO")	,, .F.)
						cXmIdeLot += xTafTag("tpInsc"		, V6O->V6O_TPINSC														,, .T.)
						cXmIdeLot += xTafTag("nrInsc"		, V6O->V6O_NRINSC														,, .T.)				
						cXmIdeLot += cXmlIfBsFG
						cXmIdeLot += "</ideLotacao>"

						V6O->(DBSkip())
					EndDo
				EndIf

				xTafTagGroup("ideEstab"									;
								, {	{"tpInsc", V6N->V6N_TPINSC,, .F.}	;
								,  	{"nrInsc", V6N->V6N_NRINSC,, .F.}}	;
								, @cXml									;
								, {	{"ideLotacao", cXmIdeLot, 1}})	

				V6N->(DBSkip())
			EndDo

			V6O->(DBCloseArea())
			V20->(DBCloseArea())
			V21->(DBCloseArea())
			V22->(DBCloseArea())
		EndIf

		V6N->(DBCloseArea())
	Else
		V20->(DBSetOrder(1))
		V21->(DBSetOrder(1))
		V22->(DBSetOrder(1))
		V23->(DBSetOrder(1))
		V24->(DBSetOrder(1))
		V25->(DBSetOrder(1))

		lSeekV20 := V20->( MsSeek( xFilial( "V20" ) + V2Z->( V2Z_ID + V2Z_VERSAO ) ) )
		lSeekV21 := V21->( MsSeek( xFilial( "V21" ) + V2Z->( V2Z_ID + V2Z_VERSAO ) ) )

		If lSeekV20 .or. lSeekV21

			cXml += "<infoBaseFGTS>"

			If lSeeKV20

				While V20->( !Eof() ) .and. V20->( V20_FILIAL + V20_ID + V20_VERSAO ) == xFilial( "V20" ) + V2Z->( V2Z_ID + V2Z_VERSAO )

					cXml += "<basePerApur>"
					cXml += 	xTafTag( "tpValor", Posicione( "V26", 1, xFilial( "V26" ) + V20->V20_IDTPVL, "V26_CODIGO" ) )
					cXml += 	xTafTag( "baseFGTS", V20->V20_VLFGTS )
					cXml += "</basePerApur>"

					V20->( DBSkip() )

				EndDo

			EndIf

			If lSeeKV21

				While V21->( !Eof() ) .and. V21->( V21_FILIAL + V21_ID + V21_VERSAO ) == xFilial( "V21" ) + V2Z->( V2Z_ID + V2Z_VERSAO )

					cXml += "<infoBasePerAntE>"
					cXml += 	xTafTag( "perRef"	, SubStr( V21->V21_PERREF, 3, 4 ) + "-" + SubStr( V21->V21_PERREF, 1, 2 ) )

					If TafColumnPos("V21_TPCONV")
						cXml += 	xTafTag( "tpAcConv"	, V21->V21_TPCONV	 													  )
					EndIf


					If V22->( MsSeek( xFilial( "V22" ) + V21->( V21_ID + V21_VERSAO + V21_PERREF ) ) )

						While V22->( !Eof() ) .and. V22->( V22_FILIAL + V22_ID + V22_VERSAO + V22_PERREF ) == xFilial( "V22" ) + V21->( V21_ID + V21_VERSAO + V21_PERREF )

							cXml += "<basePerAntE>"
							cXml += 	xTafTag( "tpValorE", Posicione( "V26", 1, xFilial( "V26" ) + V22->V22_IDTPVL, "V26_CODIGO" ) )
							cXml += 	xTafTag( "baseFGTSE", V22->V22_VLFGTS )
							cXml += "</basePerAntE>"

							V22->( DBSkip() )

						EndDo

					EndIf

					cXml += "</infoBasePerAntE>"

					V21->( DBSkip() )

				EndDo

			EndIf

			cXml += "</infoBaseFGTS>"

		EndIf

		lSeekV23 := V23->( MsSeek( xFilial( "V23" ) + V2Z->( V2Z_ID + V2Z_VERSAO ) ) )
		lSeekV24 := V24->( MsSeek( xFilial( "V24" ) + V2Z->( V2Z_ID + V2Z_VERSAO ) ) )

		If ( lSeekV23 .or. lSeekV24 )

			cXml += "<infoDpsFGTS>"

			If lSeeKV23

				While V23->( !Eof() ) .and. V23->( V23_FILIAL + V23_ID + V23_VERSAO ) == xFilial( "V23" ) + V2Z->( V2Z_ID + V2Z_VERSAO )

					cXml += "<dpsPerApur>"
					cXml += 	xTafTag( "tpDps", Posicione( "V27", 1, xFilial( "V27" ) + V23->V23_IDTPDP, "V27_CODIGO" ) )
					cXml += 	xTafTag( "vrFGTS", V23->V23_VLFGTS )
					cXml += "</dpsPerApur>"

					V23->( DBSkip() )

				EndDo

			EndIf

			If lSeekV24

				While V24->( !Eof() ) .and. V24->( V24_FILIAL + V24_ID + V24_VERSAO ) == xFilial( "V24" ) + V2Z->( V2Z_ID + V2Z_VERSAO )

					cXml += "<infoDpsPerAntE>"
					cXml += 	xTafTag( "perRef"	, SubStr( V24->V24_PERREF, 3, 4 ) + "-" + SubStr( V24->V24_PERREF, 1, 2 ) )

					If TafColumnPos("V24_TPCONV	")
						cXml += 	xTafTag( "tpAcConv"	, V24->V24_TPCONV	 													  )
					EndIf

					If V25->( MsSeek( xFilial( "V25" ) + V24->( V24_ID + V24_VERSAO + V24_PERREF ) ) )

						While V25->( !Eof() ) .and. V25->( V25_FILIAL + V25_ID + V25_VERSAO + V25_PERREF ) == xFilial( "V25" ) + V24->( V24_ID + V24_VERSAO + V24_PERREF )

							cXml += "<dpsPerAntE>"
							cXml += 	xTafTag( "tpDpsE", Posicione( "V27", 1, xFilial( "V27" ) + V25->V25_IDTPDP, "V27_CODIGO" ) )
							cXml += 	xTafTag( "vrFGTSE", V25->V25_VLFGTS )
							cXml += "</dpsPerAntE>"

							V25->( DBSkip() )

						EndDo

					EndIf

					cXml += "</infoDpsPerAntE>"

					V24->( DBSkip() )

				EndDo

			EndIf

			cXml += "</infoDpsFGTS>"

		EndIf

		V20->(DBCloseArea())
		V21->(DBCloseArea())
		V22->(DBCloseArea())
		V23->(DBCloseArea())
		V24->(DBCloseArea())
		V25->(DBCloseArea())
	EndIf

	cXml += "</infoFGTS>"

	If lLaySimplif
		If V2Z->V2Z_INDAPU == "1"
			aAdd(aMensal, V2Z->V2Z_INDAPU)
			aAdd(aMensal, Substr(V2Z->V2Z_PERAPU, 3, 4) + "-" + Substr(V2Z->V2Z_PERAPU, 1, 2))
		ElseIf V2Z->V2Z_INDAPU == "2"
			aAdd(aMensal, V2Z->V2Z_INDAPU)
			aAdd(aMensal, Alltrim(V2Z->V2Z_PERAPU))
		Else

			aAdd(aMensal, "")

			If Len(AllTrim(V2Z->V2Z_PERAPU)) == 6
				aAdd( aMensal, SubStr( V2Z->V2Z_PERAPU, 3, 4 ) + "-" + SubStr( V2Z->V2Z_PERAPU, 1, 2 ) )
			Else
				aAdd( aMensal, V2Z->V2Z_PERAPU )
			EndIf

		EndIf
	Else
		If Len(AllTrim(V2Z->V2Z_PERAPU)) == 6
			aAdd( aMensal, SubStr( V2Z->V2Z_PERAPU, 3, 4 ) + "-" + SubStr( V2Z->V2Z_PERAPU, 1, 2 ) )
		Else
			aAdd( aMensal, V2Z->V2Z_PERAPU )
		EndIf
	EndIf

	cXml := xTafCabXml(cXml, "V2Z", cLayout, cReg, aMensal,,, lLaySimplif)

	If !lJob
		xTafGerXml(cXml, cLayout)
	EndIf

	If lTroca
		lLaySimplif := !lLaySimplif
	EndIf

Return cXml

//---------------------------------------------------------------------
/*/{Protheus.doc} SearchRec
@type			function
@description	Verifica a existência do Evento S-5013 a partir do Recibo.
@author			Ricardo Lovrenovic
@since			08/01/2018
@version		1.0
@param			cRecibo		-	Recibo do evento original
@param			cFilGrv		-	Filial da localização do Recibo ( Referência )
@param			dDtLegado	-	Data do parâmetro MV_TOTEXDT ( Referência )
@return			lRet		-	Indica se existe Evento S-5013 para o Recibo indicado
/*/
//---------------------------------------------------------------------
Static Function SearchRec( cRecibo, cFilGrv, dDtLegado )

	Local cAliasQry	:=	GetNextAlias()
	Local cQuery	:=	""
	Local lRet		:=	.F.

	cQuery := " SELECT V2Z.V2Z_FILGRV, V2Z.V2Z_SITPAR "
	cQuery += " FROM " + RetSqlName( "V2Z" ) + " V2Z "
	cQuery += " WHERE V2Z.V2Z_NRRECI = '" + cRecibo + "' "
	cQuery += " AND V2Z.V2Z_ATIVO = '1' "
	cQuery += " AND V2Z.D_E_L_E_T_ = '' "

	cQuery := ChangeQuery( cQuery )

	DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cAliasQry, .F., .T. )

	If ( cAliasQry )->( !Eof() )
		cFilGrv := ( cAliasQry )->V2Z_FILGRV
		dDtLegado := SToD( ( cAliasQry )->V2Z_SITPAR )
		lRet := .T.
	EndIf

	( cAliasQry )->( DBCloseArea() )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF521Valid
@type			function
@description	Validação dos campos para o cadastro de Informações do FGTS por Trabalhador - S-5013.
@author			Ricardo Lovrenovic
@since			03/01/2018
@version		1.0
@return			lRet	-	Indica se todas as condições foram respeitadas
/*/
//---------------------------------------------------------------------
Function TAF521Valid()

	Local cCampo	:=	SubStr( ReadVar(), At( ">", ReadVar() ) + 1 )
	Local lRet		:=	.T.

	If cCampo == "V22_IDTPVL"

		If Len( AllTrim( M->V22_IDTPVL ) ) > 2
			If !( AllTrim( Posicione( "V26", 1, xFilial( "V26" ) + M->V22_IDTPVL, "V26_CODIGO" ) ) $ "13|14|17|18|24|25|26|30|31|32|91" )
				Help( ,, "HELP",, STR0017, 1, 0 ) //"Tipo de Valor informado não permitido."
				lRet := .F.
			EndIf
		Else
			If !( AllTrim( M->V22_IDTPVL ) $ "13|14|17|18|24|25|26|30|31|32|91" )
				Help( ,, "HELP",, STR0017, 1, 0 ) //"Tipo de Valor informado não permitido."
				lRet := .F.
			EndIf
		EndIf

	ElseIf cCampo == "V25_IDTPDP"

		If Len( AllTrim( M->V25_IDTPDP ) ) > 2
			If !( AllTrim( Posicione( "V27", 1, xFilial( "V27" ) + M->V25_IDTPDP, "V27_CODIGO" ) ) $ "53|54|57|58|64|65|66|70|71|72" )
				Help( ,, "HELP",, STR0018, 1, 0 ) //"Tipo de Depósito informado não permitido."
				lRet := .F.
			EndIf
		Else
			If !( AllTrim( M->V25_IDTPDP ) $ "53|54|57|58|64|65|66|70|71|72" )
				Help( ,, "HELP",, STR0018, 1, 0 ) //"Tipo de Depósito informado não permitido."
				lRet := .F.
			EndIf
		EndIf

	EndIf

Return( lRet )


