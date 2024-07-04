#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA520.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE ANALITICO_MATRICULA				1
#DEFINE ANALITICO_CATEGORIA				2
#DEFINE ANALITICO_TIPO_ESTABELECIMENTO	3
#DEFINE ANALITICO_ESTABELECIMENTO		4
#DEFINE ANALITICO_LOTACAO				5
#DEFINE ANALITICO_NATUREZA				6
#DEFINE ANALITICO_TIPO_RUBRICA			7
#DEFINE ANALITICO_INCIDENCIA_CP			8
#DEFINE ANALITICO_INCIDENCIA_IRRF		9
#DEFINE ANALITICO_INCIDENCIA_FGTS		10
#DEFINE ANALITICO_DECIMO_TERCEIRO		11
#DEFINE ANALITICO_TIPO_VALOR			12
#DEFINE ANALITICO_VALOR					13
#DEFINE ANALITICO_MOTIVO_DESLIGAMENTO	14
#DEFINE	ANALITICO_VALOR_DEP 		    16

Static oReport		:=	Nil
Static __lGrvRPT	:=	Nil
Static lLaySimplif  := taflayEsoc("S_01_00_00")

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA520
@type			function
@description	Informações do FGTS por Trabalhador - S-5003.
@author			Felipe C. Seolin
@since			26/12/2018
@version		1.0
/*/
//---------------------------------------------------------------------
Function TAFA520()

Local cMessage	:=	""
Local oDialog	:= Nil
Local oLayer	:= Nil
Local oPanel01	:= Nil
Local oPanel02	:= Nil
Local oBtFil	:= Nil
Local nTop		:= 0
Local nHeight	:= 0
Local nWidth	:= 0
Local aSize		:= FWGetDialogSize()
Local lFreeze	:= .T.
Local bFiltro	:= {|| FilCpfNome(oBrw, "V2P", "S-5003", 3, 'V2P_PERAPU') }
Local bGerXml	:= {|| TAF520Xml(), oBrw:Refresh(.T.) }
Local bHistAlt	:= {|| xNewHisAlt( 'V2P', 'TAFA520' ), oBrw:Refresh(.T.) }
Local bXmlLote	:= {|| TAFXmlLote( 'V2P', 'S-5003' , 'evtIrrfBenef' , 'TAF520Xml', ,oBrw ), oBrw:Refresh(.T.) }
Local bClose	:= {|| oDialog:End() }

Private oBrw := FwMBrowse():New()

If TafAtualizado()
	If FindFunction("FilCpfNome")

		/*----------------------------
		Construção do Painel Principal
		----------------------------*/

		oDialog := MsDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], "Cadastro de Imposto de Renda Retido na Fonte",,,,,,,,, .T.,,,, .F. )

		oLayer := FWLayer():New()

		oLayer:Init( oDialog, .F. )

		oLayer:AddLine( "LINE01", 100 )

		oLayer:AddCollumn( "BOX01",88,, "LINE01" )
		oLayer:AddCollumn( "BOX02",12,, "LINE01" )

		oLayer:AddWindow( "BOX01", "PANEL01", "Cadastro de Imposto de Renda Retido na Fonte", 100, .F.,,, "LINE01" )
		oLayer:AddWindow( "BOX02", "PANEL02", "Outras Ações"            , 100, .F.,,, "LINE01" )

		oPanel01 := oLayer:GetWinPanel( "BOX01", "PANEL01", "LINE01" )
		oPanel02 := oLayer:GetWinPanel( "BOX02", "PANEL02", "LINE01" )

		/*----------------------------------------------------------------
		Construção do Painel 01 - Browse do Cadastro De Imposto de Renda Retido na Fonte
		----------------------------------------------------------------*/
		oBrw:SetDescription( STR0001 ) //"Informações do FGTS por Trabalhador"
		oBrw:SetAlias("V2P")
		oBrw:SetMenuDef("TAFA520")
		oBrw:SetOwner( oPanel01 )
		oBrw:SetIniWindow(DbSetOrder(2))

		oBrw:SetFilterDefault( "V2P_ATIVO == '1'" )


		/*------------------------------------
		Construção do Painel 02 - Outras Ações
		------------------------------------*/

		nWidth := ( oPanel02:nClientWidth / 2 ) - 3
		nHeight := Int( ( oPanel02:nClientHeight / 2 ) / 10 ) - 5

		nTop := 5
		oBtFil := TButton():New( 005, 002, "Filtro CPF/Nome", oPanel02, bFiltro, nWidth, nHeight,,,, .T.,,,, { || lFreeze } )
		oBtFil:SetCSS(SetCssButton("11","#FFFFFF","#1DA2C3","#1DA2C3"))

		nTop += nHeight + 5
		TButton():New( nTop, 002, "Gerar Xml e-Social"  , oPanel02, bGerXml , nWidth, nHeight,,,, .T.,,,, { || lFreeze } )

		nTop += nHeight + 5
		TButton():New( nTop, 002, "Exibir Hist.Alt."    , oPanel02, bHistAlt, nWidth, nHeight,,,, .T.,,,, { || lFreeze } )

		nTop += nHeight + 5
		TButton():New( nTop, 002, "Gerar XML em Lote"   , oPanel02, bXmlLote, nWidth, nHeight,,,, .T.,,,, { || lFreeze } )

		nTop += nHeight + 5
		TButton():New( nTop, 002, "Fechar"              , oPanel02, bClose  , nWidth, nHeight,,,, .T.,,,, { || lFreeze } )

		/*-------------------
		Ativação da Interface
		-------------------*/

		oBrw:Activate()
		oDialog:Activate()


	Else

		If TAFAlsInDic( "V2P" )
			oBrowse:SetDescription( STR0001 ) //"Informações do FGTS por Trabalhador"
			oBrowse:SetAlias( "V2P" )
			oBrowse:SetMenuDef( "TAFA520" )
		
			oBrowse:SetFilterDefault( "V2P_ATIVO == '1'" )
		
			oBrowse:Activate()
		Else
			cMessage := STR0002 //"Ambiente desatualizado com a versão do programa existente no repositório de dados."
			cMessage += Chr( 13 ) + Chr( 10 )
			cMessage += Chr( 13 ) + Chr( 10 )
			cMessage += STR0003 //"Execute a atualização do dicionário do Layout 2.5 do eSocial por meio do compatibilizador UPDDISTR."
			Aviso( STR0004, cMessage, { STR0005 }, 2 ) //##"Dicionário Incompatível" ##"Encerrar"
		EndIf
		
	EndIf
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@type			function
@description	Função genérica MVC do menu.
@author			Felipe C. Seolin
@since			26/12/2018
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

Local aRotina	:=	{}
Local aFuncao	:=	{}

If FindFunction("FilCpfNome")
	ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.TAFA520' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE "Imprimir"	  ACTION 'VIEWDEF.TAFA520' OPERATION 8 ACCESS 0 //'Imprimir'
Else
	aAdd( aFuncao, { "", "TAF520Xml", "1" } )
	aAdd( aFuncao, { "", "xFunHisAlt( 'V2P', 'TAFA520' )", "3" } )
	aAdd( aFuncao, { "", "TAFXmlLote( 'V2P', 'S-5003', 'evtBasesFGTS', 'TAF520Xml' , , oBrowse )", "5" } )

	//Variável Private utilizada para controle do menu na chamada da View na operação de Histórico de Alterações
	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )
	
	If lMenuDif
		ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TAFA520" OPERATION 2 ACCESS 0 //"Visualizar"
	Else
		aRotina := xFunMnuTAF( "TAFA520",, aFuncao )
	EndIf
EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@type			function
@description	Função genérica MVC do modelo.
@author			Felipe C. Seolin
@since			26/12/2018
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

Local oStruV2P	:=	FWFormStruct( 1, "V2P" )
Local oStruV2Q	:=	FWFormStruct( 1, "V2Q" )
Local oStruV2R	:=	FWFormStruct( 1, "V2R" )
Local oStruV2S	:=	FWFormStruct( 1, "V2S" )
Local oStruV2T	:=	FWFormStruct( 1, "V2T" )
Local oStruV2U	:=	FWFormStruct( 1, "V2U" )
Local oStruV2V	:=	FWFormStruct( 1, "V2V" )
Local oStruV2W	:=	FWFormStruct( 1, "V2W" )
Local oStruV2X	:=	FWFormStruct( 1, "V2X" )
Local oStruV2Y	:=	FWFormStruct( 1, "V2Y" )
Local nIV2U     := 0
Local nIV2Y     := 0
Local oStruV6L	:= 	Iif(lLaySimplif, FWFormStruct( 1, "V6L" ), Nil) 
Local oStruV6P  := 	Iif(lLaySimplif, FwFormStruct( 1, "V6P" ), Nil) 
Local oStruV6Q  := 	Iif(lLaySimplif, FwFormStruct( 1, "V6Q" ), Nil) 
Local oModel	:=	MPFormModel():New( "TAFA520",,, { |oModel| SaveModel( oModel ) } )

//Variável Private utilizada para controle do modelo na operação de integração via TAFAINTEG
lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

If lVldModel
	oStruV2P:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
	oStruV2Q:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
	oStruV2R:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
	oStruV2S:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
	oStruV2T:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
	oStruV2U:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )

	If lLaySimplif
		oStruV6L:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
		oStruV6P:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
		oStruV6Q:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
	Else
		oStruV2V:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
		oStruV2W:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
		oStruV2X:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
		oStruV2Y:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
	EndIf
EndIf

oModel:AddFields( "MODEL_V2P", /*cOwner*/, oStruV2P )

//Identificação do Estabelecimento ou Obra de Construção Civil e da Respectiva Lotação Tributária
oModel:AddGrid( "MODEL_V2Q", "MODEL_V2P", oStruV2Q )
oModel:GetModel( "MODEL_V2Q" ):SetOptional( .T. )
oModel:GetModel( "MODEL_V2Q" ):SetUniqueLine( { "V2Q_TPINSC", "V2Q_NRINSC", "V2Q_CODLOT" } )

//Informações Relativas à Matrícula e Categoria do Trabalhador
oModel:AddGrid( "MODEL_V2R", "MODEL_V2Q", oStruV2R )
oModel:GetModel( "MODEL_V2R" ):SetOptional( .T. )
oModel:GetModel( "MODEL_V2R" ):SetUniqueLine( { "V2R_MATRIC", "V2R_CODCAT" } )
oModel:GetModel( "MODEL_V2R" ):SetMaxLine( 10 )

//Informações sobre Bases de Cálculo do FGTS Referentes à Remuneração do Período de Apuração e de Períodos Anteriores
oModel:AddGrid( "MODEL_V2S", "MODEL_V2R", oStruV2S )
oModel:GetModel( "MODEL_V2S" ):SetOptional( .T. )
oModel:GetModel( "MODEL_V2S" ):SetUniqueLine( Iif(lLaySimplif,{ "V2S_IDTPVL","V2S_INDINC" },{ "V2S_IDTPVL" }) )
oModel:GetModel( "MODEL_V2S" ):SetMaxLine( 21 )

//Informações Referentes a Bases de Cálculo do FGTS de Períodos Anteriores
oModel:AddGrid( "MODEL_V2T", "MODEL_V2R", oStruV2T )
oModel:GetModel( "MODEL_V2T" ):SetOptional( .T. )
oModel:GetModel( "MODEL_V2T" ):SetUniqueLine( { "V2T_PERREF","V2T_TPCONV" } )
oModel:GetModel( "MODEL_V2T" ):SetMaxLine( 180 )

//Informações sobre Bases de Cálculo do FGTS Referentes à Remuneração de Períodos Anteriores
oModel:AddGrid( "MODEL_V2U", "MODEL_V2T", oStruV2U )
oModel:GetModel( "MODEL_V2U" ):SetOptional( .T. )
oModel:GetModel( "MODEL_V2U" ):SetUniqueLine( Iif(lLaySimplif,{ "V2U_IDTPVL","V2U_INDINC" },{ "V2U_IDTPVL" } )  )
oModel:GetModel( "MODEL_V2U" ):SetMaxLine( 11 )

If lLaySimplif
	//Informações Relativas as Rubricas
	oModel:AddGrid( "MODEL_V6L", "MODEL_V2S", oStruV6L )
	oModel:GetModel( "MODEL_V6L" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_V6L" ):SetUniqueLine( { "V6L_CODRUB", "V6L_IDTABR" } )

	//Informações referentes a bases de cálculo e valores do FGTS de períodos anteriores
	oModel:AddGrid( "MODEL_V6P", "MODEL_V2U", oStruV6P )
	oModel:GetModel( "MODEL_V6P" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_V6P" ):SetUniqueLine( { "V6P_CODRUB", "V6P_IDTABR" } )

	//Identificação de processo - Incidência de FGTS
	oModel:AddGrid( "MODEL_V6Q", "MODEL_V6L", oStruV6Q )
	oModel:GetModel( "MODEL_V6Q" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_V6Q" ):SetUniqueLine( { "V6Q_NRPROC" } )
Else
	//Informações Relativas à Matrícula e Categoria do Trabalhador
	oModel:AddGrid( "MODEL_V2V", "MODEL_V2P", oStruV2V )
	oModel:GetModel( "MODEL_V2V" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_V2V" ):SetUniqueLine( { "V2V_MATRIC", "V2V_CODCAT" } )
	oModel:GetModel( "MODEL_V2V" ):SetMaxLine( 10 )

	//Cálculo dos Valores de FGTS a serem Depositados, Incidentes sobre a Remuneração do Período de Apuração e de Períodos Anteriores
	oModel:AddGrid( "MODEL_V2W", "MODEL_V2V", oStruV2W )
	oModel:GetModel( "MODEL_V2W" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_V2W" ):SetUniqueLine( { "V2W_IDTPDP" } )
	oModel:GetModel( "MODEL_V2W" ):SetMaxLine( 20 )

	//Informações Referentes ao Cálculo dos Valores de FGTS de Períodos Anteriores
	oModel:AddGrid( "MODEL_V2X", "MODEL_V2V", oStruV2X )
	oModel:GetModel( "MODEL_V2X" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_V2X" ):SetUniqueLine( { "V2X_PERREF","V2X_TPCONV" } )
	oModel:GetModel( "MODEL_V2X" ):SetMaxLine( 180 )

	//Cálculo dos Valores de FGTS a serem Depositados, Incidentes sobre a Remuneração de Períodos Anteriores
	oModel:AddGrid( "MODEL_V2Y", "MODEL_V2X", oStruV2Y )
	oModel:GetModel( "MODEL_V2Y" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_V2Y" ):SetUniqueLine( { "V2Y_IDTPDP" } )
	oModel:GetModel( "MODEL_V2Y" ):SetMaxLine( 10 )
EndIf

oModel:SetRelation( "MODEL_V2Q", { { "V2Q_FILIAL", "xFilial( 'V2Q' )" }, { "V2Q_ID", "V2P_ID" }, { "V2Q_VERSAO", "V2P_VERSAO" } }, V2Q->( IndexKey( 1 ) ) )
oModel:SetRelation( "MODEL_V2R", { { "V2R_FILIAL", "xFilial( 'V2R' )" }, { "V2R_ID", "V2P_ID" }, { "V2R_VERSAO", "V2P_VERSAO" }, { "V2R_TPINSC", "V2Q_TPINSC" }, { "V2R_NRINSC", "V2Q_NRINSC" }, { "V2R_CODLOT", "V2Q_CODLOT" } }, V2R->( IndexKey( 1 ) ) )
oModel:SetRelation( "MODEL_V2S", { { "V2S_FILIAL", "xFilial( 'V2S' )" }, { "V2S_ID", "V2P_ID" }, { "V2S_VERSAO", "V2P_VERSAO" }, { "V2S_TPINSC", "V2Q_TPINSC" }, { "V2S_NRINSC", "V2Q_NRINSC" }, { "V2S_CODLOT", "V2Q_CODLOT" }, { "V2S_MATRIC", "V2R_MATRIC" }, { "V2S_CODCAT", "V2R_CODCAT" } }, V2S->( IndexKey( 1 ) ) )
oModel:SetRelation( "MODEL_V2T", { { "V2T_FILIAL", "xFilial( 'V2T' )" }, { "V2T_ID", "V2P_ID" }, { "V2T_VERSAO", "V2P_VERSAO" }, { "V2T_TPINSC", "V2Q_TPINSC" }, { "V2T_NRINSC", "V2Q_NRINSC" }, { "V2T_CODLOT", "V2Q_CODLOT" }, { "V2T_MATRIC", "V2R_MATRIC" }, { "V2T_CODCAT", "V2R_CODCAT" } }, V2T->( IndexKey( 1 ) ) )

IIF(FWSIXUtil():ExistIndex( "V2U", "V2UI2", .T.),nIV2U := 2,nIV2U := 1)
oModel:SetRelation( "MODEL_V2U", { { "V2U_FILIAL", "xFilial( 'V2U' )" }, { "V2U_ID", "V2P_ID" }, { "V2U_VERSAO", "V2P_VERSAO" }, { "V2U_TPINSC", "V2Q_TPINSC" }, { "V2U_NRINSC", "V2Q_NRINSC" }, { "V2U_CODLOT", "V2Q_CODLOT" }, { "V2U_MATRIC", "V2R_MATRIC" }, { "V2U_CODCAT", "V2R_CODCAT" }, { "V2U_PERREF", "V2T_PERREF"},{"V2U_TPCONV","V2T_TPCONV"}  }, V2U->( IndexKey( nIV2U ) ) )


If lLaySimplif
	oModel:SetRelation( "MODEL_V6L", { { "V6L_FILIAL", "xFilial( 'V6L' )" }, { "V6L_ID", "V2P_ID" }, { "V6L_VERSAO", "V2P_VERSAO" }, { "V6L_TPINSC", "V2Q_TPINSC" }, { "V6L_NRINSC", "V2Q_NRINSC" }, { "V6L_CODLOT", "V2Q_CODLOT" }, { "V6L_MATRIC", "V2R_MATRIC" }, { "V6L_CODCAT", "V2R_CODCAT" },{"V6L_IDTPVL","V2S_IDTPVL"}, {"V6L_INDINC","V2S_INDINC"} }, V6L->( IndexKey( 1 ) ) )
	oModel:SetRelation( "MODEL_V6P", { { "V6P_FILIAL", "xFilial( 'V6P' )" }, { "V6P_ID", "V2P_ID" }, { "V6P_VERSAO", "V2P_VERSAO" }, { "V6P_TPINSC", "V2Q_TPINSC" }, { "V6P_NRINSC", "V2Q_NRINSC" }, { "V6P_CODLOT", "V2Q_CODLOT" }, { "V6P_MATRIC", "V2R_MATRIC" }, { "V6P_CODCAT", "V2R_CODCAT" },{"V6P_PERREF","V2T_PERREF"}, {"V6P_TPCONV","V2T_TPCONV"}, {"V6P_IDTPVL","V2U_IDTPVL"}, {"V6P_INDINC","V2U_INDINC"} }, V6P->( IndexKey( 1 ) ) )
	oModel:SetRelation( "MODEL_V6Q", { { "V6Q_FILIAL", "xFilial( 'V6Q' )" }, { "V6Q_ID", "V2P_ID" }, { "V6Q_VERSAO", "V2P_VERSAO" }, { "V6Q_TPINSC", "V2Q_TPINSC" }, { "V6Q_NRINSC", "V2Q_NRINSC" }, { "V6Q_CODLOT", "V2Q_CODLOT" }, { "V6Q_MATRIC", "V2R_MATRIC" }, { "V6Q_CODCAT", "V2R_CODCAT" },{"V6Q_IDTPVL","V2S_IDTPVL"}, {"V6Q_INDINC","V2S_INDINC"}, {"V6Q_CODRUB","V6L_CODRUB"}, {"V6Q_IDTABR","V6L_IDTABR"} }, V6Q->( IndexKey( 1 ) ) )
Else
	oModel:SetRelation( "MODEL_V2V", { { "V2V_FILIAL", "xFilial( 'V2V' )" }, { "V2V_ID", "V2P_ID" }, { "V2V_VERSAO", "V2P_VERSAO" } }, V2V->( IndexKey( 1 ) ) )
	oModel:SetRelation( "MODEL_V2W", { { "V2W_FILIAL", "xFilial( 'V2W' )" }, { "V2W_ID", "V2P_ID" }, { "V2W_VERSAO", "V2P_VERSAO" }, { "V2W_MATRIC", "V2V_MATRIC" }, { "V2W_CODCAT", "V2V_CODCAT" } }, V2W->( IndexKey( 1 ) ) )
	oModel:SetRelation( "MODEL_V2X", { { "V2X_FILIAL", "xFilial( 'V2X' )" }, { "V2X_ID", "V2P_ID" }, { "V2X_VERSAO", "V2P_VERSAO" }, { "V2X_MATRIC", "V2V_MATRIC" }, { "V2X_CODCAT", "V2V_CODCAT" } }, V2X->( IndexKey( 1 ) ) )
	IIF(FWSIXUtil():ExistIndex( "V2Y", "V2YI2", .T.),nIV2Y := 2, nIV2Y := 1)
	oModel:SetRelation( "MODEL_V2Y", { { "V2Y_FILIAL", "xFilial( 'V2Y' )" }, { "V2Y_ID", "V2P_ID" }, { "V2Y_VERSAO", "V2P_VERSAO" }, { "V2Y_MATRIC", "V2V_MATRIC" }, { "V2Y_CODCAT", "V2V_CODCAT" }, { "V2Y_PERREF", "V2X_PERREF" },{"V2Y_TPCONV","V2X_TPCONV"} }, V2Y->( IndexKey( nIV2Y ) ) )
EndIf

oModel:GetModel( "MODEL_V2P" ):SetPrimaryKey( { "V2P_PERAPU", "V2P_CPF", "V2P_IDEVEN" } )

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@type			function
@description	Função genérica MVC da view.
@author			Felipe C. Seolin
@since			26/12/2018
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

Local oStruV2Pa	:=	Nil
Local oStruV2Pb	:=	Nil
Local oStruV2Pc	:=	Nil
Local oStruV2Q	:=	FWFormStruct( 2, "V2Q" )
Local oStruV2R	:=	FWFormStruct( 2, "V2R" )
Local oStruV2S	:=	FWFormStruct( 2, "V2S" )
Local oStruV6L	:= 	Nil
Local oStruV6P	:=  Nil
Local oStruV6Q	:=  Nil
Local oStruV2T	:=	FWFormStruct( 2, "V2T" )
Local oStruV2U	:=	FWFormStruct( 2, "V2U" )
Local oStruV2V	:=	FWFormStruct( 2, "V2V" )
Local oStruV2W	:=	FWFormStruct( 2, "V2W" )
Local oStruV2X	:=	FWFormStruct( 2, "V2X" )
Local oStruV2Y	:=	FWFormStruct( 2, "V2Y" )
Local oModel	:=	FWLoadModel( "TAFA520" )
Local oView		:=	FWFormView():New()
Local cCmpFil	:=	""

oView:SetModel( oModel )

oView:SetContinuousForm(.T.)

//Campos do Grupo Informações Relativas ao FGTS
cCmpFil := "V2P_DTVENC|"

If TafColumnPos("V2P_CLATRI")
	cCmpFil += "V2P_CLATRI|V2P_DESCLA|
Endif

oStruV2Pc := FWFormStruct( 2, "V2P", { |x| AllTrim( x ) + "|" $ cCmpFil } )

If lLaySimplif
	cCmpFil := "V2P_ID|V2P_IDEVEN|V2P_DIDEVE|V2P_NRRECI|V2P_PERAPU|V2P_INDAPU|"
	oStruV2Pa := FWFormStruct( 2, "V2P", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	cCmpFil := "V2P_CPF|V2P_NOME|"
	oStruV2Pb := FWFormStruct( 2, "V2P", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	cCmpFil := "V2Q_TPINSC|V2Q_NRINSC|V2Q_CODLOT|V2Q_TPLOT|V2Q_DTPLOT|V2Q_TPINES|V2Q_NRINES|"
	oStruV2Q := FWFormStruct( 2, "V2Q", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	cCmpFil := "V2R_MATRIC|V2R_CODCAT|V2R_DCODCA|V2R_DTDESL|V2R_IDCMDE|V2R_DIDCME|V2R_DTTERM|V2R_IDCMDD|V2R_DIDCMD|V2R_CATORI|V2R_DCATOR|V2R_TPREG|V2R_REMSUC|V2R_SUCTPV|V2R_SUCINS|V2R_SUCMAT|V2R_SUCDTA|V2R_PROCJU|"
	oStruV2R := FWFormStruct( 2, "V2R", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	cCmpFil := "V2S_IDTPVL|V2S_DIDTPV|V2S_VLFGTS|V2S_INDINC|V2S_VLDPS|"
	oStruV2S := FWFormStruct( 2, "V2S", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	cCmpFil := "V2U_IDTPVL|V2U_DIDTPV|V2U_VLFGTS|V2U_INDINC|V2U_VLDPS|"
	oStruV2U := FWFormStruct( 2, "V2U", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	cCmpFil := "V6L_CODRUB|V6L_DCODRU|V6L_IDTABR|V6L_VLTOT|"
	oStruV6L := FWFormStruct( 2, "V6L", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	cCmpFil := "V6P_CODRUB|V6P_DCODRU|V6P_IDTABR|V6P_VLTOT|"
	oStruV6P := FWFormStruct( 2, "V6P", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	cCmpFil := "V6Q_NRPROC|"
	oStruV6Q := FWFormStruct( 2, "V6Q", { |x| AllTrim( x ) + "|" $ cCmpFil } )
Else
	cCmpFil := "V2P_ID|V2P_IDEVEN|V2P_DIDEVE|V2P_NRRECI|V2P_PERAPU|"
	oStruV2Pa := FWFormStruct( 2, "V2P", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	cCmpFil := "V2P_CPF|V2P_NIS|V2P_NOME|"
	oStruV2Pb := FWFormStruct( 2, "V2P", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	cCmpFil := "V2R_MATRIC|V2R_CODCAT|V2R_DCODCA|V2R_DTADMI|V2R_DTDESL|V2R_DTINIC|V2R_IDCMDE|V2R_DIDCME|V2R_DTTERM|V2R_IDCMDD|V2R_DIDCMD|"
	oStruV2R := FWFormStruct( 2, "V2R", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	cCmpFil := "V2Q_TPINSC|V2Q_NRINSC|V2Q_CODLOT|"
	oStruV2Q := FWFormStruct( 2, "V2Q", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	cCmpFil := "V2S_IDTPVL|V2S_DIDTPV|V2S_VLFGTS|"
	oStruV2S := FWFormStruct( 2, "V2S", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	cCmpFil := "V2U_IDTPVL|V2U_DIDTPV|V2U_VLFGTS|"
	oStruV2U := FWFormStruct( 2, "V2U", { |x| AllTrim( x ) + "|" $ cCmpFil } )
EndIf

/*--------------------------------------------------------------------------------------------
									Estrutura da View
---------------------------------------------------------------------------------------------*/

oView:AddField( "VIEW_V2Pa", oStruV2Pa, "MODEL_V2P" )
oView:EnableTitleView( "VIEW_V2Pa", STR0007 ) //"Identificação do Evento de Retorno"

oView:AddField( "VIEW_V2Pb", oStruV2Pb, "MODEL_V2P" )
oView:EnableTitleView( "VIEW_V2Pb", STR0008 ) //"Identificação do Trabalhador"

oView:AddField( "VIEW_V2Pc", oStruV2Pc, "MODEL_V2P" )
oView:EnableTitleView( "VIEW_V2Pc", STR0009 ) //"Informações Relativas ao FGTS"

oView:AddGrid( "VIEW_V2Q", oStruV2Q, "MODEL_V2Q" )
oView:EnableTitleView( "VIEW_V2Q", STR0010 ) //"Identificação do Estabelecimento ou Obra de Construção Civil e da Respectiva Lotação Tributária"

oView:AddGrid( "VIEW_V2R", oStruV2R, "MODEL_V2R" )
oView:EnableTitleView( "VIEW_V2R", STR0011 ) //"Informações Relativas à Matrícula e Categoria do Trabalhador"

oView:AddGrid( "VIEW_V2S", oStruV2S, "MODEL_V2S" )

oView:AddGrid( "VIEW_V2T", oStruV2T, "MODEL_V2T" )

oView:AddGrid( "VIEW_V2U", oStruV2U, "MODEL_V2U" )
oView:EnableTitleView( "VIEW_V2U", STR0012 ) //"Informações sobre Bases de Cálculo do FGTS Referentes à Remuneração de Períodos Anteriores"

If lLaySimplif
	oView:AddGrid( "VIEW_V6L", oStruV6L, "MODEL_V6L" )
	oView:EnableTitleView( "VIEW_V6L", STR0023 ) //"Detalhamento das Rubricas c/ Inc. de FGTS Suspensa"
	
	oView:AddGrid( "VIEW_V6P", oStruV6P, "MODEL_V6P" )
	oView:EnableTitleView( "VIEW_V6P", STR0023 ) //"Detalhamento das Rubricas c/ Inc. de FGTS Suspensa"

	oView:AddGrid( "VIEW_V6Q", oStruV6Q, "MODEL_V6Q" )
	oView:EnableTitleView( "VIEW_V6Q", STR0024 ) //"Identificação de processo - Incidência de FGTS"
Else
	oView:AddGrid( "VIEW_V2V", oStruV2V, "MODEL_V2V" )
	oView:EnableTitleView( "VIEW_V2V", STR0011 ) //"Informações Relativas à Matrícula e Categoria do Trabalhador"

	oView:AddGrid( "VIEW_V2W", oStruV2W, "MODEL_V2W" )

	oView:AddGrid( "VIEW_V2X", oStruV2X, "MODEL_V2X" )

	oView:AddGrid( "VIEW_V2Y", oStruV2Y, "MODEL_V2Y" )
	oView:EnableTitleView( "VIEW_V2Y", STR0013 ) //"Cálculo dos Valores de FGTS a serem Depositados, Incidentes sobre a Remuneração de Períodos Anteriores"
EndIf

/*-----------------------------------------------------------------------------------
								Estrutura do Folder
-------------------------------------------------------------------------------------*/

oView:CreateHorizontalBox( "PAINEL_PRINCIPAL", 100 )

oView:CreateFolder( "FOLDER_PRINCIPAL", "PAINEL_PRINCIPAL" )

oView:AddSheet( "FOLDER_PRINCIPAL", "ABA01", STR0001 ) //"Informações do FGTS por Trabalhador"

oView:CreateHorizontalBox( "V2Pa", 33,,, "FOLDER_PRINCIPAL", "ABA01" )
oView:CreateHorizontalBox( "V2Pb", 33,,, "FOLDER_PRINCIPAL", "ABA01" )
oView:CreateHorizontalBox( "V2Pc", 34,,, "FOLDER_PRINCIPAL", "ABA01" )

oView:AddSheet( "FOLDER_PRINCIPAL", "ABA02", STR0009 ) //"Informações Relativas ao FGTS"

oView:CreateHorizontalBox( "PAINEL_INFO_FGTS", 100,,, "FOLDER_PRINCIPAL", "ABA02" )
oView:CreateFolder( "FOLDER_INFO_FGTS", "PAINEL_INFO_FGTS" )

oView:AddSheet( "FOLDER_INFO_FGTS", "ABA01", STR0014 ) //"Informações Relativas a Base de Cálculo de FGTS"

oView:CreateHorizontalBox( "V2Q", 20,,, "FOLDER_INFO_FGTS", "ABA01" )
oView:CreateHorizontalBox( "V2R", 20,,, "FOLDER_INFO_FGTS", "ABA01" )

oView:CreateHorizontalBox( "PAINEL_INFO_BASE_FGTS", 60,,, "FOLDER_INFO_FGTS", "ABA01" )
oView:CreateFolder( "FOLDER_INFO_BASE_FGTS", "PAINEL_INFO_BASE_FGTS" )

oView:AddSheet( "FOLDER_INFO_BASE_FGTS", "ABA01", STR0015 ) //"Informações sobre Bases de Cálculo do FGTS do Período de Apuração"

oView:CreateHorizontalBox( "V2S", Iif(lLaySimplif,40,100),,, "FOLDER_INFO_BASE_FGTS", "ABA01" )

oView:CreateHorizontalBox( "V2T", Iif(lLaySimplif,32,50),,, "FOLDER_INFO_BASE_FGTS", "ABA02" )
oView:CreateHorizontalBox( "V2U", Iif(lLaySimplif,35,50),,, "FOLDER_INFO_BASE_FGTS", "ABA02" )


oView:AddSheet( "FOLDER_INFO_BASE_FGTS", "ABA02", STR0016 ) //"Informações Referentes a Bases de Cálculo do FGTS de Períodos Anteriores"

If lLaySimplif
	oView:CreateHorizontalBox( "PAINEL_INFO_RUB", 60,,, "FOLDER_INFO_BASE_FGTS", "ABA01" )
	oView:CreateFolder( "FOLDER_INFO_RUB", "PAINEL_INFO_RUB" )

	oView:AddSheet( "FOLDER_INFO_RUB", "ABA01", STR0023 ) //"Detalhamento das Rubricas c/ Inc. de FGTS Suspensa"
	oView:CreateHorizontalBox( "V6L", 60,,, "FOLDER_INFO_RUB", "ABA01" )

	oView:CreateHorizontalBox( "V6Q", 40,,,"FOLDER_INFO_RUB", "ABA01" )

	oView:CreateHorizontalBox( "PAINEL_INFO_RUBANT", 33,,, "FOLDER_INFO_BASE_FGTS", "ABA02" )
	oView:CreateFolder( "FOLDER_INFO_RUBANT", "PAINEL_INFO_RUBANT" )

	oView:AddSheet( "FOLDER_INFO_RUBANT", "ABA02", STR0023 ) //"Detalhamento das Rubricas c/ Inc. de FGTS Suspensa"
	oView:CreateHorizontalBox( "V6P", 100,,,"FOLDER_INFO_RUBANT", "ABA02" )
Else
	oView:AddSheet( "FOLDER_INFO_FGTS", "ABA02", STR0022 ) //"Informações Relativas a Valores de FGTS"

	oView:CreateHorizontalBox( "V2V", 30,,, "FOLDER_INFO_FGTS", "ABA02" )

	oView:CreateHorizontalBox( "PAINEL_INFO_DEPOSITO_FGTS", 70,,, "FOLDER_INFO_FGTS", "ABA02" )
	oView:CreateFolder( "FOLDER_INFO_DEPOSITO_FGTS", "PAINEL_INFO_DEPOSITO_FGTS" )

	oView:AddSheet( "FOLDER_INFO_DEPOSITO_FGTS", "ABA01", STR0017 ) //"Cálculo dos Valores de FGTS a serem Depositados do Período de Apuração"
	oView:CreateHorizontalBox( "V2W", 100,,, "FOLDER_INFO_DEPOSITO_FGTS", "ABA01" )

	oView:AddSheet( "FOLDER_INFO_DEPOSITO_FGTS", "ABA02", STR0018 ) //"Informações Referentes ao Cálculo dos Valores de FGTS de Períodos Anteriores"
	oView:CreateHorizontalBox( "V2X", 50,,, "FOLDER_INFO_DEPOSITO_FGTS", "ABA02" )
	oView:CreateHorizontalBox( "V2Y", 50,,, "FOLDER_INFO_DEPOSITO_FGTS", "ABA02" )
EndIf

oView:SetOwnerView( "VIEW_V2Pa", "V2Pa" )
oView:SetOwnerView( "VIEW_V2Pb", "V2Pb" )
oView:SetOwnerView( "VIEW_V2Pc", "V2Pc" )
oView:SetOwnerView( "VIEW_V2Q", "V2Q" )
oView:SetOwnerView( "VIEW_V2R", "V2R" )
oView:SetOwnerView( "VIEW_V2S", "V2S" )
oView:SetOwnerView( "VIEW_V2T", "V2T" )
oView:SetOwnerView( "VIEW_V2U", "V2U" )

If lLaySimplif
	oView:SetOwnerView( "VIEW_V6L", "V6L" )
	oView:SetOwnerView( "VIEW_V6P", "V6P" )
	oView:SetOwnerView( "VIEW_V6Q", "V6Q" )
Else
	oView:SetOwnerView( "VIEW_V2V", "V2V" )
	oView:SetOwnerView( "VIEW_V2W", "V2W" )
	oView:SetOwnerView( "VIEW_V2X", "V2X" )
	oView:SetOwnerView( "VIEW_V2Y", "V2Y" )
EndIf

oStruV2Pa:RemoveField( "V2P_ID" )

Return( oView )

//---------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
@type			function
@description	Função de gravação dos dados, executada na confirmação do modelo.
@author			Felipe C. Seolin
@since			28/12/2018
@version		1.0
@param			oModel	-	Modelo de dados
/*/
//---------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation	:=	oModel:GetOperation()

//Relatório de Conferência de Valores
Local oInfoRPT	:=	Nil
Local lInfoRPT	:=	.F.

Begin Transaction
	If nOperation == MODEL_OPERATION_INSERT
		oModel:LoadValue( "MODEL_V2P", "V2P_VERSAO", xFunGetVer() )

		FWFormCommit( oModel )
	ElseIf nOperation == MODEL_OPERATION_UPDATE
		TAFAltStat( "V2P", " " )

		FWFormCommit( oModel )
	ElseIf nOperation == MODEL_OPERATION_DELETE
		If __lGrvRPT == Nil
			TAF520Rpt() //Inicializa a variável static __lGrvRPT
		EndIf

		lInfoRPT := __lGrvRPT

		//Realiza a exclusão do registro da tabela do relatório
		If lInfoRPT
			If oReport == Nil
				oReport := TAFSocialReport():New()
			EndIf

			oInfoRPT := oReport:oVOReport
			oInfoRPT:SetIndApu( "1" )
			oInfoRPT:SetPeriodo( SubStr( V2P->V2P_PERAPU, 3, 4 ) + SubStr( V2P->V2P_PERAPU, 1, 2 ) )
			oInfoRPT:SetCPF( AllTrim( V2P->V2P_CPF ) )

			oReport:UpSert( Posicione( "C8E", 1, xFilial( "C8E", V2P->V2P_FILIAL ) + V2P->V2P_IDEVEN, "C8E_CODIGO" ), "5", xFilial( "V2P" ), oInfoRPT, .T. )
		EndIf

		FWFormCommit( oModel )
	EndIf
End Transaction

Return( .T. )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF520Grv
@type			function
@description	Função de integração dos dados para o evento S-5003.
@author			Felipe C. Seolin
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
Function TAF520Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpEnv, cFilEnv, cXmlID, cEvtOri,lMigrador,lDepGPE,cKey,cMatrC9V,lLaySmpTot )
Local oModel		:=	Nil
Local cCmpsNoUpd	:=	"|V2P_FILIAL|V2P_ID|V2P_VERSAO|V2P_ATIVO|"
Local cCabec		:=	"/eSocial/evtBasesFGTS/"
Local cInconMsg		:=	""
Local cString		:=	""
Local cRecibo		:=	""
Local cIDEvento		:=	""
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
Local lRet			:= .F.
Local cV6PCodR 		:= ""
Local cV6PTabR 		:= ""


//Relatório de Conferência de Valores
Local oInfoRPT		:=	Nil
Local cCPF			:=	""
Local nPosValores	:=	0
Local aAnalitico	:=	{}
Local lInfoRPT		:=	.F.

Local aV3NMotDes	:=  {}
Local nPosV3N		:=  0
Local nIdeLotacao	:= 0
Local cPathIdeLo	:= ""
Local cIndApur		:= ""
Local nIndV2P		:= 2

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
Default cMatrC9V	:= ""

If IsInCallStack("TafPrepInt")
	lLaySimplif := lLaySmpTot
EndIf	

oDados := oXML

If !TAFAlsInDic( "V2P" )
	cString := STR0002 //"Ambiente desatualizado com a versão do programa existente no repositório de dados."
	cString += Chr( 13 ) + Chr( 10 )
	cString += Chr( 13 ) + Chr( 10 )
	cString += STR0003 //"Execute a atualização do dicionário do Layout 2.5 do eSocial por meio do compatibilizador UPDDISTR."

	aAdd( aIncons, cString )

	Return( { lRet, aIncons } )
EndIf

If __lGrvRPT == Nil
	TAF520Rpt() //Inicializa a variável static __lGrvRPT
EndIf

lInfoRPT := __lGrvRPT

If lInfoRPT
	If oReport == Nil
		oReport := TAFSocialReport():New()
	EndIf
EndIf

Begin Transaction

	cRecibo := FTAFGetVal( cCabec + "ideEvento/nrRecArqBase", "C", .F.,, .T. )

	If lLaySimplif
		cIndApur 	:= FTAFGetVal( cCabec + "ideEvento/indApuracao", "C", .F.,, .T. )
		nIndV2P		:= 7
	EndIf

	If SearchRec( cRecibo, @cFilGrv, @dDtLegado )
		cFilBkp := cFilAnt
		cFilAnt := cFilGrv
	EndIf

	cPeriodo := AllTrim( StrTran( FTAFGetVal( cCabec + "ideEvento/perApur", "C", .F.,, .T. ), "-", "" ) )

	If Len( cPeriodo ) == 6 //Caso o período esteja no formato AAAA/MM, grava no formato MM/AAAA para melhor experiência do usuário. Caso esteja no formato AAAA, será gravado da forma que veio no XML.
		cPeriodo := SubStr( cPeriodo, 5, 2 ) + SubStr( cPeriodo, 1, 4 )
	EndIf

	cIDEvento := GetEvento( cEvtOri )
	
	aAdd( aChave, { "C", "V2P_IDEVEN", cIDEvento, .T. } )
	aAdd( aChave, { "C", "V2P_CPF", FTAFGetVal( cCabec + "ideTrabalhador/cpfTrab", "C", .F.,, .F. ), .T. } )
	If lLaySimplif
		aAdd( aChave, { "C", "V2P_INDAPU", StrTran( FTAFGetVal( cCabec + "ideEvento/indApuracao", "C", .F.,, .T. ), "-", "" ), .T. } )
	EndIf
	aAdd( aChave, { "C", "V2P_PERAPU", cPeriodo, .T. } )

	//Função para validar se a operação desejada pode ser realizada
	If FTAFVldOpe( "V2P", nIndV2P, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA520", cCmpsNoUpd )

		//Carrego array com os campos De/Para de gravação das informações
		aRules := TAF520Rul( cEvtOri )

		//Quando se tratar de uma Exclusão Direta, apenas preciso realizar o Commit, não é necessária nenhuma manutenção nas informações
		If nOpc <> 5
			oModel:LoadValue( "MODEL_V2P", "V2P_FILIAL", V2P->V2P_FILIAL )
			oModel:LoadValue( "MODEL_V2P", "V2P_FILGRV", cFilAnt )

			If nOpc == 3
				oModel:LoadValue( "MODEL_V2P", "V2P_SITPAR", dDtParam )
			Else
				oModel:LoadValue( "MODEL_V2P", "V2P_SITPAR", dDtLegado )
			EndIf

			//Laço no aRules para gravar as informações
			For nI := 1 to Len( aRules )
				oModel:LoadValue( "MODEL_V2P", aRules[nI,01], FTAFGetVal( aRules[nI,02], aRules[nI,03], aRules[nI,04], @aIncons, .F. ) )
			Next nI

			/*----------------------------------------
			V2Q - Identificação do Estabelecimento ou Obra de Construção Civil e da Respectiva Lotação Tributária
			------------------------------------------*/
			nV2Q := 1
			nLinhaV2Q := 0

			If lLaySimplif
				cV2QPath := cCabec + "infoFGTS/ideEstab[" + cValToChar( nV2Q ) + "]"
			Else
				cV2QPath := cCabec + "infoFGTS/ideEstabLot[" + cValToChar( nV2Q ) + "]"
			EndIf

			While oDados:xPathHasNode( cV2QPath )

				If lLaySimplif
					nIdeLotacao	:= 1
					cPathIdeLo	:= cV2QPath + "/ideLotacao[" + cValToChar(nIdeLotacao) + "]"

					While oDados:xPathHasNode( cPathIdeLo )
						nLinhaV2Q++

						If nOpc == 4 .Or. nLinhaV2Q > 1
							oModel:GetModel( "MODEL_V2Q" ):LVALID := .T.
							oModel:GetModel( "MODEL_V2Q" ):AddLine()
						EndIf

						If oDados:xPathHasNode( cV2QPath + "/tpInsc" )
							oModel:LoadValue( "MODEL_V2Q", "V2Q_TPINSC", FTAFGetVal( cV2QPath + "/tpInsc", "C", .F., @aIncons, .T. ) )
						EndIf

						If oDados:xPathHasNode( cV2QPath + "/nrInsc" )
							oModel:LoadValue( "MODEL_V2Q", "V2Q_NRINSC", FTAFGetVal( cV2QPath + "/nrInsc", "C", .F., @aIncons, .T. ) )
						EndIf

						If oDados:xPathHasNode( cPathIdeLo + "/codLotacao" )
							oModel:LoadValue( "MODEL_V2Q", "V2Q_CODLOT", PadR(FTAFGetVal( cPathIdeLo + "/codLotacao", "C", .F., @aIncons, .T. ),30) )
						EndIf

						If oDados:xPathHasNode( cPathIdeLo + "/tpLotacao" )
							oModel:LoadValue( "MODEL_V2Q", "V2Q_TPLOT", FGetIDInt( "tpLotacao", "", cPathIdeLo + "/tpLotacao",,,, @cInconMsg, @nSeqErrGrv ) )							
						EndIf

						If oDados:xPathHasNode( cPathIdeLo + "/tpInsc" )
							oModel:LoadValue( "MODEL_V2Q", "V2Q_TPINES", FTAFGetVal( cPathIdeLo + "/tpInsc", "C", .F., @aIncons, .T. ) )
						EndIf

						If oDados:xPathHasNode( cPathIdeLo + "/nrInsc" )
							oModel:LoadValue( "MODEL_V2Q", "V2Q_NRINES", FTAFGetVal( cPathIdeLo + "/nrInsc", "C", .F., @aIncons, .T. ) )
						EndIf

						/*----------------------------------------
						V2R - Informações Relativas à Matrícula e Categoria do Trabalhador
						------------------------------------------*/
						nV2R := 1
						cV2RPath := cPathIdeLo + "/infoTrabFGTS[" + cValToChar( nV2R ) + "]"

						nV2R := 1
						While oDados:xPathHasNode( cV2RPath )

							If nOpc == 4 .Or. nV2R > 1
								oModel:GetModel( "MODEL_V2R" ):LVALID := .T.
								oModel:GetModel( "MODEL_V2R" ):AddLine()
							EndIf

							If oDados:xPathHasNode( cV2RPath + "/matricula" )
								oModel:LoadValue( "MODEL_V2R", "V2R_MATRIC", FTAFGetVal( cV2RPath + "/matricula", "C", .F., @aIncons, .T. ) )
							EndIf

							If oDados:xPathHasNode( cV2RPath + "/codCateg" )
								oModel:LoadValue( "MODEL_V2R", "V2R_CODCAT", FGetIDInt( "codCateg", "", cV2RPath + "/codCateg",,,, @cInconMsg, @nSeqErrGrv ) )
							EndIf

							If oDados:xPathHasNode( cV2RPath + "/categOrig" )
								oModel:LoadValue( "MODEL_V2R", "V2R_CATORI", FGetIDInt( "categOrig", "", cV2RPath + "/categOrig",,,, @cInconMsg, @nSeqErrGrv ) )
							EndIf

							If oDados:xPathHasNode( cV2RPath + "/tpRegTrab" )
								oModel:LoadValue( "MODEL_V2R", "V2R_TPREG", FTAFGetVal( cV2RPath + "/tpRegTrab", "C", .F., @aIncons, .T. ) )
							EndIf

							If oDados:xPathHasNode( cV2RPath + "/remunSuc" )
								oModel:LoadValue( "MODEL_V2R", "V2R_REMSUC", FTAFGetVal( cV2RPath + "/remunSuc", "C", .F., @aIncons, .T. ) )
							EndIf

							If oDados:xPathHasNode( cV2RPath + "/dtDeslig" )
								oModel:LoadValue( "MODEL_V2R", "V2R_DTDESL", FTAFGetVal( cV2RPath + "/dtDeslig", "D", .F., @aIncons, .T. ) )
							EndIf

							If oDados:xPathHasNode( cV2RPath + "/mtvDeslig" )
								oModel:LoadValue( "MODEL_V2R", "V2R_IDCMDE", FGetIDInt( "mtvDeslig", "", cV2RPath + "/mtvDeslig",,,, @cInconMsg, @nSeqErrGrv ) )
							EndIf

							If oDados:xPathHasNode( cV2RPath + "/dtTerm" )
								oModel:LoadValue( "MODEL_V2R", "V2R_DTTERM", FTAFGetVal( cV2RPath + "/dtTerm", "D", .F., @aIncons, .T. ) )
							EndIf

							If oDados:xPathHasNode( cV2RPath + "/mtvDesligTSV" )
								oModel:LoadValue( "MODEL_V2R", "V2R_IDCMDD", FGetIDInt( "mtvDesligTSV", "", cV2RPath + "/mtvDesligTSV",,,, @cInconMsg, @nSeqErrGrv ) )
							EndIf

							nV2Rb := 1
							cV2RbPath := cV2RPath + "/sucessaoVinc[" + cValToChar( nV2Rb ) + "]"
							
							While oDados:xPathHasNode( cV2RbPath )
								If nOpc == 4 .Or. nV2Rb > 1
									oModel:GetModel( "MODEL_V2R" ):LVALID := .T.
									oModel:GetModel( "MODEL_V2R" ):AddLine()
								EndIf

								If oDados:xPathHasNode( cV2RbPath + "/tpInsc" )
									oModel:LoadValue( "MODEL_V2R", "V2R_SUCTPV", FTAFGetVal( cV2RbPath + "/tpInsc", "C", .F., @aIncons, .T. ) )
								EndIf

								If oDados:xPathHasNode( cV2RbPath + "/nrInsc" )
									oModel:LoadValue( "MODEL_V2R", "V2R_SUCINS", FTAFGetVal( cV2RbPath + "/nrInsc", "C", .F., @aIncons, .T. ) )
								EndIf

								If oDados:xPathHasNode( cV2RbPath + "/matricAnt" )
									oModel:LoadValue( "MODEL_V2R", "V2R_SUCMAT", FTAFGetVal( cV2RbPath + "/matricAnt", "C", .F., @aIncons, .T. ) )
								EndIf

								If oDados:xPathHasNode( cV2RbPath + "/dtAdm" )
									oModel:LoadValue( "MODEL_V2R", "V2R_SUCDTA", FTAFGetVal( cV2RbPath + "/dtAdm", "D", .F., @aIncons, .T. ) )
								EndIf

								nV2Rb ++
								cV2RbPath := cV2RPath + "/sucessaoVinc[" + cValToChar( nV2Rb ) + "]"
							EndDo

							aAdd( aV3NMotDes, { AllTrim( FTAFGetVal( cV2RPath + "/matricula", "C", .F.,, .F. ) ), ;
												AllTrim( FTAFGetVal( cV2RPath + "/codCateg", "C", .F.,, .F. ) ), ;
												AllTrim( FTAFGetVal( cV2RPath + "/mtvDeslig", "C", .F.,, .F. ) ) } )

							/*----------------------------------------
							V2S - Informações sobre Bases de Cálculo do FGTS Referentes à Remuneração do Período de Apuração e de Períodos Anteriores
							------------------------------------------*/
							nV2S := 1
							cV2SPath := cV2RPath + "/infoBaseFGTS/basePerApur[" + cValToChar( nV2S ) + "]"

							nV2S := 1
							While oDados:xPathHasNode( cV2SPath )

								If nOpc == 4 .Or. nV2S > 1
									oModel:GetModel( "MODEL_V2S" ):LVALID := .T.
									oModel:GetModel( "MODEL_V2S" ):AddLine()
								EndIf

								If oDados:xPathHasNode( cV2SPath + "/tpValor" )
									oModel:LoadValue( "MODEL_V2S", "V2S_IDTPVL", FGetIDInt( "tpValorE", "", cV2SPath + "/tpValor",,,, @cInconMsg, @nSeqErrGrv ) )
								EndIf

								If oDados:xPathHasNode( cV2SPath + "/indIncid" )
									oModel:LoadValue( "MODEL_V2S", "V2S_INDINC", FTAFGetVal( cV2SPath + "/indIncid", "C", .F., @aIncons, .F. ) )
								EndIf

								If oDados:xPathHasNode( cV2SPath + "/remFGTS" )
									oModel:LoadValue( "MODEL_V2S", "V2S_VLFGTS", FTAFGetVal( cV2SPath + "/remFGTS", "N", .F., @aIncons, .F. ) )
								EndIf

								If oDados:xPathHasNode( cV2SPath + "/dpsFGTS" )
									oModel:LoadValue( "MODEL_V2S", "V2S_VLDPS", FTAFGetVal( cV2SPath + "/dpsFGTS", "N", .F., @aIncons, .F. ) )
								EndIf

								/*----------------------------------------
								V6L - Detalhamento da(s) rubrica(s) com incidência de FGTS suspensa
								------------------------------------------*/
								nV6L := 1
								cV6LPath := cV2SPath + "/detRubrSusp[" + cValToChar( nV6L ) + "]"

								While oDados:xPathHasNode( cV6LPath )

									If nOpc == 4 .Or. nV6L > 1
										oModel:GetModel( "MODEL_V6L" ):LVALID := .T.
										oModel:GetModel( "MODEL_V6L" ):AddLine()
									EndIf

									cV6LTabR := FTafGetVal( cV6LPath + "/ideTabRubr", "C", .F., @aIncons, .F. )
									cV6LCodR := FGetIdInt( "codRubr", "ideTabRubr", FTafGetVal( cV6LPath + "/codRubr", "C", .F., @aIncons, .F. ),cV6LTabR,.F.,,@cInconMsg, @nSeqErrGrv,/*9*/,/*10*/,/*11*/,/*12*/,/*13*/,Iif( Len( cPeriodo ) <= 4, cPeriodo, SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) ))

									If oDados:xPathHasNode( cV6LPath + "/codRubr" )
										oModel:LoadValue( "MODEL_V6L", "V6L_CODRUB",cV6LCodR)
									EndIf

									If oDados:xPathHasNode( cV6LPath + "/ideTabRubr" )
										oModel:LoadValue( "MODEL_V6L", "V6L_IDTABR",cV6LTabR)
									EndIf

									If oDados:xPathHasNode( cV6LPath + "/vrRubr" )
										oModel:LoadValue( "MODEL_V6L", "V6L_VLTOT", FTAFGetVal( cV6LPath + "/vrRubr", "N", .F., @aIncons, .F. ) )
									EndIf

									/*----------------------------------------
									V6Q - "Identificação de processo - Incidência de FGTS"
									------------------------------------------*/
									nV6Q := 1
									cV6QPath := cV6LPath + "/ideProcessoFGTS[" + cValToChar( nV6Q ) + "]"

									While oDados:xPathHasNode( cV6QPath )

										If nOpc == 4 .Or. nV6Q > 1
											oModel:GetModel( "MODEL_V6Q" ):LVALID := .T.
											oModel:GetModel( "MODEL_V6Q" ):AddLine()
										EndIf

										If oDados:xPathHasNode( cV6QPath + "/nrProc" )
											oModel:LoadValue( "MODEL_V6Q", "V6Q_NRPROC", FTAFGetVal( cV6QPath + "/nrProc", "C", .F., @aIncons, .F. ))
										EndIf

										nV6Q ++
										cV6QPath := cV6LPath + "/ideProcessoFGTS[" + cValToChar( nV6Q ) + "]"
									EndDo


									nV6L ++
									cV6LPath := cV2SPath + "/detRubrSusp[" + cValToChar( nV6L ) + "]"
								EndDo

								If lInfoRPT
									aAdd( aAnalitico, Array( 16 ) )
									nPosValores := Len( aAnalitico )

									aAnalitico[nPosValores][ANALITICO_MATRICULA]			:=	AllTrim( FTAFGetVal( cV2RPath + "/matricula", "C", .F.,, .F. ) )
									aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:=	AllTrim( FTAFGetVal( cV2RPath + "/codCateg", "C", .F.,, .F. ) )
									aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:=	AllTrim( FTAFGetVal( cV2QPath + "/tpInsc", "C", .F.,, .F. ) )
									aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:=	AllTrim( FTAFGetVal( cV2QPath + "/nrInsc", "C", .F.,, .F. ) )
									aAnalitico[nPosValores][ANALITICO_LOTACAO]				:=	AllTrim( FTAFGetVal( cPathIdeLo + "/codLotacao", "C", .F.,, .F. ) )
									aAnalitico[nPosValores][ANALITICO_NATUREZA]				:=	""
									aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:=	""
									aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:=	""
									aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:=	""
									aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:=	""
									aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:=	""
									aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:=	AllTrim( FTAFGetVal( cV2SPath + "/tpValor", "C", .F.,, .F. ) )
									aAnalitico[nPosValores][ANALITICO_VALOR]				:=	FTAFGetVal( cV2SPath + "/remFGTS", "N", .F.,, .F. )
									aAnalitico[nPosValores][ANALITICO_MOTIVO_DESLIGAMENTO]	:=	AllTrim( FTAFGetVal( cV2RPath + "/mtvDeslig", "C", .F.,, .F. ) )

									If lLaySimplif
										aAnalitico[nPosValores][ANALITICO_VALOR_DEP]		:=	FTAFGetVal( cV2SPath + "/dpsFGTS", "N", .F.,, .F. )
									EndIf

								EndIf

								nV2S ++
								cV2SPath := cV2RPath + "/infoBaseFGTS/basePerApur[" + cValToChar( nV2S ) + "]"
							EndDo

							/*----------------------------------------
							V2T - Informações Referentes a Bases de Cálculo do FGTS de Períodos Anteriores
							------------------------------------------*/
							nV2T := 1
							cV2TPath := cV2RPath + "/infoBaseFGTS/infoBasePerAntE[" + cValToChar( nV2T ) + "]"

							nV2T := 1
							While oDados:xPathHasNode( cV2TPath )

								If nOpc == 4 .Or. nV2T > 1
									oModel:GetModel( "MODEL_V2T" ):LVALID := .T.
									oModel:GetModel( "MODEL_V2T" ):AddLine()
								EndIf

								If oDados:xPathHasNode( cV2TPath + "/perRef" )
									cPerRef := StrTran( FTAFGetVal( cV2TPath + "/perRef", "C", .F., @aIncons, .F. ), "-", "" )
									cPerRef := SubStr( cPerRef, 5, 2 ) + SubStr( cPerRef, 1, 4 )
									oModel:LoadValue( "MODEL_V2T", "V2T_PERREF", cPerRef )
								EndIf

								If oDados:xPathHasNode( cV2TPath + "/tpAcConv" )
									If TafColumnPos("V2T_TPCONV")
										oModel:LoadValue( "MODEL_V2T", "V2T_TPCONV", FTAFGetVal( cV2TPath + "/tpAcConv", "C", .F., @aIncons, .F. ) )
									EndIf
								EndIf

								/*----------------------------------------
								V2U - Informações sobre Bases de Cálculo do FGTS Referentes à Remuneração de Períodos Anteriores
								------------------------------------------*/
								nV2U := 1
								cV2UPath := cV2TPath + "/basePerAntE[" + cValToChar( nV2U ) + "]"

								nV2U := 1
								While oDados:xPathHasNode( cV2UPath )

									If nOpc == 4 .Or. nV2U > 1
										oModel:GetModel( "MODEL_V2U" ):LVALID := .T.
										oModel:GetModel( "MODEL_V2U" ):AddLine()
									EndIf

									If oDados:xPathHasNode( cV2UPath + "/tpValorE" )
										oModel:LoadValue( "MODEL_V2U", "V2U_IDTPVL", FGetIDInt( "tpValorE", "", cV2UPath + "/tpValorE",,,, @cInconMsg, @nSeqErrGrv ) )
									EndIf

									If oDados:xPathHasNode( cV2UPath + "/indIncidE" )
										oModel:LoadValue( "MODEL_V2U", "V2U_INDINC", FTAFGetVal( cV2UPath + "/indIncidE", "C", .F., @aIncons, .F. ) )
									EndIf

									If oDados:xPathHasNode( cV2UPath + "/remFGTSE" )
										oModel:LoadValue( "MODEL_V2U", "V2U_VLFGTS", FTAFGetVal( cV2UPath + "/remFGTSE", "N", .F., @aIncons, .F. ) )
									EndIf

									If oDados:xPathHasNode( cV2UPath + "/dpsFGTSE" )
										oModel:LoadValue( "MODEL_V2U", "V2U_VLDPS", FTAFGetVal( cV2UPath + "/dpsFGTSE", "N", .F., @aIncons, .F. ) )
									EndIf

									/*----------------------------------------
									V6P - Detalhamento da(s) rubrica(s) com incidência de FGTS suspensa Períodos Anteriores
									------------------------------------------*/
									nV6P := 1
									cV6PPath := cV2UPath + "/detRubrSusp[" + cValToChar( nV6P ) + "]"

									While oDados:xPathHasNode( cV6PPath )

										If nOpc == 4 .Or. nV6P > 1
											oModel:GetModel( "MODEL_V6P" ):LVALID := .T.
											oModel:GetModel( "MODEL_V6P" ):AddLine()
										EndIf
										
										cV6PTabR := FTafGetVal( cV6PPath + "/ideTabRubr", "C", .F., @aIncons, .F. )
										cV6PCodR := FGetIdInt( "codRubr", "ideTabRubr", FTafGetVal( cV6PPath + "/codRubr", "C", .F., @aIncons, .F. ),cV6PTabR,.F.,,@cInconMsg, @nSeqErrGrv,/*9*/,/*10*/,/*11*/,/*12*/,/*13*/,Iif( Len( cPeriodo ) <= 4, cPeriodo, SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) ))

										If oDados:xPathHasNode( cV6PPath + "/codRubr" )
											oModel:LoadValue( "MODEL_V6P", "V6P_CODRUB",cV6PCodR)
										EndIf

										If oDados:xPathHasNode( cV6PPath + "/ideTabRubr" )
											oModel:LoadValue( "MODEL_V6P", "V6P_IDTABR",cV6PTabR)
										EndIf

										If oDados:xPathHasNode( cV6PPath + "/vrRubr" )
											oModel:LoadValue( "MODEL_V6P", "V6P_VLTOT", FTAFGetVal( cV6PPath + "/vrRubr", "N", .F., @aIncons, .F. ) )
										EndIf

										nV6P ++
										cV6PPath := cV2UPath + "/detRubrSusp[" + cValToChar( nV6P ) + "]"
									EndDo

									If lInfoRPT
										aAdd( aAnalitico, Array( 16 ) )
										nPosValores := Len( aAnalitico )

										aAnalitico[nPosValores][ANALITICO_MATRICULA]			:=	AllTrim( FTAFGetVal( cV2RPath + "/matricula", "C", .F.,, .F. ) )
										aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:=	AllTrim( FTAFGetVal( cV2RPath + "/codCateg", "C", .F.,, .F. ) )
										aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:=	AllTrim( FTAFGetVal( cV2QPath + "/tpInsc", "C", .F.,, .F. ) )
										aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:=	AllTrim( FTAFGetVal( cV2QPath + "/nrInsc", "C", .F.,, .F. ) )
										aAnalitico[nPosValores][ANALITICO_LOTACAO]				:=	AllTrim( FTAFGetVal( cPathIdeLo + "/codLotacao", "C", .F.,, .F. ) )
										aAnalitico[nPosValores][ANALITICO_NATUREZA]				:=	""
										aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:=	""
										aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:=	""
										aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:=	""
										aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:=	""
										aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:=	""
										aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:=	AllTrim( FTAFGetVal( cV2UPath + "/tpValorE", "C", .F.,, .F. ) )
										aAnalitico[nPosValores][ANALITICO_VALOR]				:=	FTAFGetVal( cV2UPath + "/remFGTSE", "N", .F.,, .F. )
										aAnalitico[nPosValores][ANALITICO_MOTIVO_DESLIGAMENTO]	:=	AllTrim( FTAFGetVal( cV2RPath + "/mtvDeslig", "C", .F.,, .F. ) )

										If lLaySimplif
											aAnalitico[nPosValores][ANALITICO_VALOR_DEP]		:=	FTAFGetVal( cV2UPath + "/dpsFGTSE", "N", .F.,, .F. )
										EndIf 

									EndIf

									nV2U ++
									cV2UPath := cV2TPath + "/basePerAntE[" + cValToChar( nV2U ) + "]"
								EndDo

								nV2T ++
								cV2TPath := cV2RPath + "/infoBaseFGTS/infoBasePerAntE[" + cValToChar( nV2T ) + "]"
							EndDo

							nV2Rc := 1
							cV2RcPath := cV2RPath + "/procCS[" + cValToChar( nV2Rc ) + "]"
							While oDados:xPathHasNode( cV2RcPath )

								If oDados:xPathHasNode( cV2RcPath + "/nrProcJud" )
									oModel:LoadValue( "MODEL_V2R", "V2R_PROCJU", FTAFGetVal( cV2RcPath + "/nrProcJud", "C", .F., @aIncons, .T. ) )
								EndIf

								nV2Rc ++
								cV2RcPath := cV2RPath + "/procCS[" + cValToChar( nV2Rc ) + "]"
							EndDo

							nV2R ++
							cV2RPath := cPathIdeLo + "/infoTrabFGTS[" + cValToChar( nV2R ) + "]" // cV2QPath
						EndDo

						nIdeLotacao ++
						cPathIdeLo	:= cV2QPath + "/ideLotacao[" + cValToChar(nIdeLotacao) + "]"
					EndDo
				Else
					If nOpc == 4 .or. nV2Q > 1
						oModel:GetModel( "MODEL_V2Q" ):LVALID := .T.
						oModel:GetModel( "MODEL_V2Q" ):AddLine()
					EndIf

					If oDados:xPathHasNode( cV2QPath + "/tpInsc" )
						oModel:LoadValue( "MODEL_V2Q", "V2Q_TPINSC", FTAFGetVal( cV2QPath + "/tpInsc", "C", .F., @aIncons, .T. ) )
					EndIf

					If oDados:xPathHasNode( cV2QPath + "/nrInsc" )
						oModel:LoadValue( "MODEL_V2Q", "V2Q_NRINSC", FTAFGetVal( cV2QPath + "/nrInsc", "C", .F., @aIncons, .T. ) )
					EndIf

					If oDados:xPathHasNode( cV2QPath + "/codLotacao" )
						oModel:LoadValue( "MODEL_V2Q", "V2Q_CODLOT", FTAFGetVal( cV2QPath + "/codLotacao", "C", .F., @aIncons, .T. ) )
					EndIf

					/*----------------------------------------
					V2R - Informações Relativas à Matrícula e Categoria do Trabalhador
					------------------------------------------*/
					nV2R := 1
					cV2RPath := cV2QPath + "/infoTrabFGTS[" + cValToChar( nV2R ) + "]"
					If nOpc == 4 .and. oDados:xPathHasNode( cV2RPath )
						For nI := 1 to oModel:GetModel( "MODEL_V2R" ):Length()
							oModel:GetModel( "MODEL_V2R" ):GoLine( nI )
							oModel:GetModel( "MODEL_V2R" ):DeleteLine()
						Next nI
					EndIf

					nV2R := 1
					While oDados:xPathHasNode( cV2RPath )

						If nOpc == 4 .or. nV2R > 1
							oModel:GetModel( "MODEL_V2R" ):LVALID := .T.
							oModel:GetModel( "MODEL_V2R" ):AddLine()
						EndIf

						If oDados:xPathHasNode( cV2RPath + "/matricula" )
							oModel:LoadValue( "MODEL_V2R", "V2R_MATRIC", FTAFGetVal( cV2RPath + "/matricula", "C", .F., @aIncons, .T. ) )
						EndIf

						If oDados:xPathHasNode( cV2RPath + "/codCateg" )
							oModel:LoadValue( "MODEL_V2R", "V2R_CODCAT", FGetIDInt( "codCateg", "", cV2RPath + "/codCateg",,,, @cInconMsg, @nSeqErrGrv ) )
						EndIf

						If oDados:xPathHasNode( cV2RPath + "/dtAdm" )
							oModel:LoadValue( "MODEL_V2R", "V2R_DTADMI", FTAFGetVal( cV2RPath + "/dtAdm", "D", .F., @aIncons, .T. ) )
						EndIf

						If oDados:xPathHasNode( cV2RPath + "/dtDeslig" )
							oModel:LoadValue( "MODEL_V2R", "V2R_DTDESL", FTAFGetVal( cV2RPath + "/dtDeslig", "D", .F., @aIncons, .T. ) )
						EndIf

						If oDados:xPathHasNode( cV2RPath + "/dtInicio" )
							oModel:LoadValue( "MODEL_V2R", "V2R_DTINIC", FTAFGetVal( cV2RPath + "/dtInicio", "D", .F., @aIncons, .T. ) )
						EndIf

						If oDados:xPathHasNode( cV2RPath + "/mtvDeslig" )
							oModel:LoadValue( "MODEL_V2R", "V2R_IDCMDE", FGetIDInt( "mtvDeslig", "", cV2RPath + "/mtvDeslig",,,, @cInconMsg, @nSeqErrGrv ) )
						EndIf

						If oDados:xPathHasNode( cV2RPath + "/dtTerm" )
							oModel:LoadValue( "MODEL_V2R", "V2R_DTTERM", FTAFGetVal( cV2RPath + "/dtTerm", "D", .F., @aIncons, .T. ) )
						EndIf

						If oDados:xPathHasNode( cV2RPath + "/mtvDesligTSV" )
							oModel:LoadValue( "MODEL_V2R", "V2R_IDCMDD", FGetIDInt( "mtvDesligTSV", "", cV2RPath + "/mtvDesligTSV",,,, @cInconMsg, @nSeqErrGrv ) )
						EndIf

						aAdd( aV3NMotDes, { AllTrim( FTAFGetVal( cV2RPath + "/matricula", "C", .F.,, .F. ) ), ;
											AllTrim( FTAFGetVal( cV2RPath + "/codCateg", "C", .F.,, .F. ) ), ;
											AllTrim( FTAFGetVal( cV2RPath + "/mtvDeslig", "C", .F.,, .F. ) ) } )

						/*----------------------------------------
						V2S - Informações sobre Bases de Cálculo do FGTS Referentes à Remuneração do Período de Apuração e de Períodos Anteriores
						------------------------------------------*/
						nV2S := 1
						cV2SPath := cV2RPath + "/infoBaseFGTS/basePerApur[" + cValToChar( nV2S ) + "]"
						If nOpc == 4 .and. oDados:xPathHasNode( cV2SPath )
							For nI := 1 to oModel:GetModel( "MODEL_V2S" ):Length()
								oModel:GetModel( "MODEL_V2S" ):GoLine( nI )
								oModel:GetModel( "MODEL_V2S" ):DeleteLine()
							Next nI
						EndIf

						nV2S := 1
						While oDados:xPathHasNode( cV2SPath )

							If nOpc == 4 .or. nV2S > 1
								oModel:GetModel( "MODEL_V2S" ):LVALID := .T.
								oModel:GetModel( "MODEL_V2S" ):AddLine()
							EndIf

							If oDados:xPathHasNode( cV2SPath + "/tpValor" )
								oModel:LoadValue( "MODEL_V2S", "V2S_IDTPVL", FGetIDInt( "tpValorE", "", cV2SPath + "/tpValor",,,, @cInconMsg, @nSeqErrGrv ) )
							EndIf

							If oDados:xPathHasNode( cV2SPath + "/remFGTS" )
								oModel:LoadValue( "MODEL_V2S", "V2S_VLFGTS", FTAFGetVal( cV2SPath + "/remFGTS", "N", .F., @aIncons, .F. ) )
							EndIf

							If lInfoRPT
								aAdd( aAnalitico, Array( 16 ) )
								nPosValores := Len( aAnalitico )

								aAnalitico[nPosValores][ANALITICO_MATRICULA]			:=	AllTrim( FTAFGetVal( cV2RPath + "/matricula", "C", .F.,, .F. ) )
								aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:=	AllTrim( FTAFGetVal( cV2RPath + "/codCateg", "C", .F.,, .F. ) )
								aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:=	AllTrim( FTAFGetVal( cV2QPath + "/tpInsc", "C", .F.,, .F. ) )
								aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:=	AllTrim( FTAFGetVal( cV2QPath + "/nrInsc", "C", .F.,, .F. ) )
								aAnalitico[nPosValores][ANALITICO_LOTACAO]				:=	AllTrim( FTAFGetVal( cV2QPath + "/codLotacao", "C", .F.,, .F. ) )
								aAnalitico[nPosValores][ANALITICO_NATUREZA]				:=	""
								aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:=	""
								aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:=	""
								aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:=	""
								aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:=	""
								aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:=	""
								aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:=	AllTrim( FTAFGetVal( cV2SPath + "/tpValor", "C", .F.,, .F. ) )
								aAnalitico[nPosValores][ANALITICO_VALOR]				:=	FTAFGetVal( cV2SPath + "/remFGTS", "N", .F.,, .F. )
								aAnalitico[nPosValores][ANALITICO_MOTIVO_DESLIGAMENTO]	:=	AllTrim( FTAFGetVal( cV2RPath + "/mtvDeslig", "C", .F.,, .F. ) )

							EndIf

							nV2S ++
							cV2SPath := cV2RPath + "/infoBaseFGTS/basePerApur[" + cValToChar( nV2S ) + "]"
						EndDo

						/*----------------------------------------
						V2T - Informações Referentes a Bases de Cálculo do FGTS de Períodos Anteriores
						------------------------------------------*/
						nV2T := 1
						cV2TPath := cV2RPath + "/infoBaseFGTS/infoBasePerAntE[" + cValToChar( nV2T ) + "]"
						If nOpc == 4 .and. oDados:xPathHasNode( cV2TPath )
							For nI := 1 to oModel:GetModel( "MODEL_V2T" ):Length()
								oModel:GetModel( "MODEL_V2T" ):GoLine( nI )
								oModel:GetModel( "MODEL_V2T" ):DeleteLine()
							Next nI
						EndIf

						nV2T := 1
						While oDados:xPathHasNode( cV2TPath )

							If nOpc == 4 .or. nV2T > 1
								oModel:GetModel( "MODEL_V2T" ):LVALID := .T.
								oModel:GetModel( "MODEL_V2T" ):AddLine()
							EndIf

							If oDados:xPathHasNode( cV2TPath + "/perRef" )
								cPerRef := StrTran( FTAFGetVal( cV2TPath + "/perRef", "C", .F., @aIncons, .F. ), "-", "" )
								cPerRef := SubStr( cPerRef, 5, 2 ) + SubStr( cPerRef, 1, 4 )
								oModel:LoadValue( "MODEL_V2T", "V2T_PERREF", cPerRef )
							EndIf

							If oDados:xPathHasNode( cV2TPath + "/tpAcConv" )
								If TafColumnPos("V2T_TPCONV")
									oModel:LoadValue( "MODEL_V2T", "V2T_TPCONV", FTAFGetVal( cV2TPath + "/tpAcConv", "C", .F., @aIncons, .F. ) )
								EndIf
							EndIf

							/*----------------------------------------
							V2U - Informações sobre Bases de Cálculo do FGTS Referentes à Remuneração de Períodos Anteriores
							------------------------------------------*/
							nV2U := 1
							cV2UPath := cV2TPath + "/basePerAntE[" + cValToChar( nV2U ) + "]"
							If nOpc == 4 .and. oDados:xPathHasNode( cV2UPath )
								For nI := 1 to oModel:GetModel( "MODEL_V2U" ):Length()
									oModel:GetModel( "MODEL_V2U" ):GoLine( nI )
									oModel:GetModel( "MODEL_V2U" ):DeleteLine()
								Next nI
							EndIf

							nV2U := 1
							While oDados:xPathHasNode( cV2UPath )

								If nOpc == 4 .or. nV2U > 1
									oModel:GetModel( "MODEL_V2U" ):LVALID := .T.
									oModel:GetModel( "MODEL_V2U" ):AddLine()
								EndIf

								If oDados:xPathHasNode( cV2UPath + "/tpValorE" )
									oModel:LoadValue( "MODEL_V2U", "V2U_IDTPVL", FGetIDInt( "tpValorE", "", cV2UPath + "/tpValorE",,,, @cInconMsg, @nSeqErrGrv ) )
								EndIf

								If oDados:xPathHasNode( cV2UPath + "/remFGTSE" )
									oModel:LoadValue( "MODEL_V2U", "V2U_VLFGTS", FTAFGetVal( cV2UPath + "/remFGTSE", "N", .F., @aIncons, .F. ) )
								EndIf

								If lInfoRPT
									aAdd( aAnalitico, Array( 16 ) )
									nPosValores := Len( aAnalitico )

									aAnalitico[nPosValores][ANALITICO_MATRICULA]			:=	AllTrim( FTAFGetVal( cV2RPath + "/matricula", "C", .F.,, .F. ) )
									aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:=	AllTrim( FTAFGetVal( cV2RPath + "/codCateg", "C", .F.,, .F. ) )
									aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:=	AllTrim( FTAFGetVal( cV2QPath + "/tpInsc", "C", .F.,, .F. ) )
									aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:=	AllTrim( FTAFGetVal( cV2QPath + "/nrInsc", "C", .F.,, .F. ) )
									aAnalitico[nPosValores][ANALITICO_LOTACAO]				:=	AllTrim( FTAFGetVal( cV2QPath + "/codLotacao", "C", .F.,, .F. ) )
									aAnalitico[nPosValores][ANALITICO_NATUREZA]				:=	""
									aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:=	""
									aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:=	""
									aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:=	""
									aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:=	""
									aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:=	""
									aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:=	AllTrim( FTAFGetVal( cV2UPath + "/tpValorE", "C", .F.,, .F. ) )
									aAnalitico[nPosValores][ANALITICO_VALOR]				:=	FTAFGetVal( cV2UPath + "/remFGTSE", "N", .F.,, .F. )
									aAnalitico[nPosValores][ANALITICO_MOTIVO_DESLIGAMENTO]	:=	AllTrim( FTAFGetVal( cV2RPath + "/mtvDeslig", "C", .F.,, .F. ) )

								EndIf

								nV2U ++
								cV2UPath := cV2TPath + "/basePerAntE[" + cValToChar( nV2U ) + "]"
							EndDo

							nV2T ++
							cV2TPath := cV2RPath + "/infoBaseFGTS/infoBasePerAntE[" + cValToChar( nV2T ) + "]"
						EndDo

						nV2R ++
						cV2RPath := cV2QPath + "/infoTrabFGTS[" + cValToChar( nV2R ) + "]"
					EndDo
				EndIf

				nV2Q ++

				If lLaySimplif
					cV2QPath := cCabec + "infoFGTS/ideEstab[" + cValToChar( nV2Q ) + "]"
				Else
					cV2QPath := cCabec + "infoFGTS/ideEstabLot[" + cValToChar( nV2Q ) + "]"
				EndIf
			EndDo

			/*----------------------------------------
			V2V - Informações Relativas à Matrícula e Categoria do Trabalhador
			------------------------------------------*/
			If !lLaySimplif
				nV2V := 1
				cV2VPath := cCabec + "/infoFGTS/infoDpsFGTS/infoTrabDps[" + cValToChar( nV2V ) + "]"
				If nOpc == 4 .and. oDados:xPathHasNode( cV2VPath )
					For nI := 1 to oModel:GetModel( "MODEL_V2V" ):Length()
						oModel:GetModel( "MODEL_V2V" ):GoLine( nI )
						oModel:GetModel( "MODEL_V2V" ):DeleteLine()
					Next nI
				EndIf

				nV2V := 1
				While oDados:xPathHasNode( cV2VPath )

					If nOpc == 4 .or. nV2V > 1
						oModel:GetModel( "MODEL_V2V" ):LVALID := .T.
						oModel:GetModel( "MODEL_V2V" ):AddLine()
					EndIf

					If oDados:xPathHasNode( cV2VPath + "/matricula" )
						oModel:LoadValue( "MODEL_V2V", "V2V_MATRIC", FTAFGetVal( cV2VPath + "/matricula", "C", .F., @aIncons, .T. ) )
					EndIf

					If oDados:xPathHasNode( cV2VPath + "/codCateg" )
						oModel:LoadValue( "MODEL_V2V", "V2V_CODCAT", FGetIDInt( "codCateg", "", cV2VPath + "/codCateg",,,, @cInconMsg, @nSeqErrGrv ) )
					EndIf

					/*----------------------------------------
					V2W - Cálculo dos Valores de FGTS a serem Depositados, Incidentes sobre a Remuneração do Período de Apuração e de Períodos Anteriores
					------------------------------------------*/
					nV2W := 1
					cV2WPath := cV2VPath + "/dpsPerApur[" + cValToChar( nV2W ) + "]"
					If nOpc == 4 .and. oDados:xPathHasNode( cV2WPath )
						For nI := 1 to oModel:GetModel( "MODEL_V2W" ):Length()
							oModel:GetModel( "MODEL_V2W" ):GoLine( nI )
							oModel:GetModel( "MODEL_V2W" ):DeleteLine()
						Next nI
					EndIf

					nV2W := 1
					While oDados:xPathHasNode( cV2WPath )

						If nOpc == 4 .or. nV2W > 1
							oModel:GetModel( "MODEL_V2W" ):LVALID := .T.
							oModel:GetModel( "MODEL_V2W" ):AddLine()
						EndIf

						If oDados:xPathHasNode( cV2WPath + "/tpDps" )
							oModel:LoadValue( "MODEL_V2W", "V2W_IDTPDP", FGetIDInt( "tpDpsE", "", cV2WPath + "/tpDps",,,, @cInconMsg, @nSeqErrGrv ) )
						EndIf

						If oDados:xPathHasNode( cV2WPath + "/dpsFGTS" )
							oModel:LoadValue( "MODEL_V2W", "V2W_VLFGTS", FTAFGetVal( cV2WPath + "/dpsFGTS", "N", .F., @aIncons, .F. ) )
						EndIf

						If lInfoRPT
							aAdd( aAnalitico, Array( 14 ) )
							nPosValores := Len( aAnalitico )

							aAnalitico[nPosValores][ANALITICO_MATRICULA]			:=	AllTrim( FTAFGetVal( cV2VPath + "/matricula", "C", .F.,, .F. ) )
							aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:=	AllTrim( FTAFGetVal( cV2VPath + "/codCateg", "C", .F.,, .F. ) )
							aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:=	""
							aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:=	""
							aAnalitico[nPosValores][ANALITICO_LOTACAO]				:=	""
							aAnalitico[nPosValores][ANALITICO_NATUREZA]				:=	""
							aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:=	""
							aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:=	""
							aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:=	""
							aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:=	""
							aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:=	""
							aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:=	AllTrim( FTAFGetVal( cV2WPath + "/tpDps", "C", .F.,, .F. ) )
							aAnalitico[nPosValores][ANALITICO_VALOR]				:=	FTAFGetVal( cV2WPath + "/dpsFGTS", "N", .F.,, .F. )

							nPosV3N := aScan( aV3NMotDes, { |x| x[1]+x[2] == AllTrim( FTAFGetVal( cV2VPath + "/matricula", "C", .F.,, .F. ) ) +  AllTrim( FTAFGetVal( cV2VPath + "/codCateg", "C", .F.,, .F. ) ) } )
							If nPosV3N > 0
								aAnalitico[nPosValores][ANALITICO_MOTIVO_DESLIGAMENTO]	:=	aV3NMotDes[nPosV3N][3]
							Else
								aAnalitico[nPosValores][ANALITICO_MOTIVO_DESLIGAMENTO]	:=	""
							EndIf

						EndIf

						nV2W ++
						cV2WPath := cV2VPath + "/dpsPerApur[" + cValToChar( nV2W ) + "]"
					EndDo

					/*----------------------------------------
					V2X - Informações Referentes ao Cálculo dos Valores de FGTS de Períodos Anteriores
					------------------------------------------*/
					nV2X := 1
					cV2XPath := cV2VPath + "/infoDpsPerAntE[" + cValToChar( nV2X ) + "]"
					If nOpc == 4 .and. oDados:xPathHasNode( cV2XPath )
						For nI := 1 to oModel:GetModel( "MODEL_V2X" ):Length()
							oModel:GetModel( "MODEL_V2X" ):GoLine( nI )
							oModel:GetModel( "MODEL_V2X" ):DeleteLine()
						Next nI
					EndIf

					nV2X := 1
					While oDados:xPathHasNode( cV2XPath )

						If nOpc == 4 .or. nV2X > 1
							oModel:GetModel( "MODEL_V2X" ):LVALID := .T.
							oModel:GetModel( "MODEL_V2X" ):AddLine()
						EndIf

						If oDados:xPathHasNode( cV2XPath + "/perRef" )
							cPerRef := StrTran( FTAFGetVal( cV2XPath + "/perRef", "C", .F., @aIncons, .F. ), "-", "" )
							cPerRef := SubStr( cPerRef, 5, 2 ) + SubStr( cPerRef, 1, 4 )
							oModel:LoadValue( "MODEL_V2X", "V2X_PERREF", cPerRef )
						EndIf

						If oDados:xPathHasNode( cV2XPath + "/tpAcConv" )
							If TafColumnPos("V2X_TPCONV")
								oModel:LoadValue( "MODEL_V2X", "V2X_TPCONV", FTAFGetVal( cV2XPath + "/tpAcConv", "C", .F., @aIncons, .F. ) )
							EndIf
						EndIf

						/*----------------------------------------
						V2Y - Cálculo dos Valores de FGTS a serem Depositados, Incidentes sobre a Remuneração de Períodos Anteriores
						------------------------------------------*/
						nV2Y := 1
						cV2YPath := cV2XPath + "/dpsPerAntE[" + cValToChar( nV2Y ) + "]"
						If nOpc == 4 .and. oDados:xPathHasNode( cV2YPath )
							For nI := 1 to oModel:GetModel( "MODEL_V2Y" ):Length()
								oModel:GetModel( "MODEL_V2Y" ):GoLine( nI )
								oModel:GetModel( "MODEL_V2Y" ):DeleteLine()
							Next nI
						EndIf

						nV2Y := 1
						While oDados:xPathHasNode( cV2YPath )

							If nOpc == 4 .or. nV2Y > 1
								oModel:GetModel( "MODEL_V2Y" ):LVALID := .T.
								oModel:GetModel( "MODEL_V2Y" ):AddLine()
							EndIf

							If oDados:xPathHasNode( cV2YPath + "/tpDpsE" )
								oModel:LoadValue( "MODEL_V2Y", "V2Y_IDTPDP", FGetIDInt( "tpDpsE", "", cV2YPath + "/tpDpsE",,,, @cInconMsg, @nSeqErrGrv ) )
							EndIf

							If oDados:xPathHasNode( cV2YPath + "/dpsFGTSE" )
								oModel:LoadValue( "MODEL_V2Y", "V2Y_VLFGTS", FTAFGetVal( cV2YPath + "/dpsFGTSE", "N", .F., @aIncons, .F. ) )
							EndIf

							If lInfoRPT
								aAdd( aAnalitico, Array( 14 ) )
								nPosValores := Len( aAnalitico )

								aAnalitico[nPosValores][ANALITICO_MATRICULA]			:=	AllTrim( FTAFGetVal( cV2VPath + "/matricula", "C", .F.,, .F. ) )
								aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:=	AllTrim( FTAFGetVal( cV2VPath + "/codCateg", "C", .F.,, .F. ) )
								aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:=	""
								aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:=	""
								aAnalitico[nPosValores][ANALITICO_LOTACAO]				:=	""
								aAnalitico[nPosValores][ANALITICO_NATUREZA]				:=	""
								aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:=	""
								aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:=	""
								aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:=	""
								aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:=	""
								aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:=	""
								aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:=	AllTrim( FTAFGetVal( cV2YPath + "/tpDpsE", "C", .F.,, .F. ) )
								aAnalitico[nPosValores][ANALITICO_VALOR]				:=	FTAFGetVal( cV2YPath + "/dpsFGTSE", "N", .F.,, .F. )

								nPosV3N := aScan( aV3NMotDes, { |x| x[1]+x[2] == AllTrim( FTAFGetVal( cV2VPath + "/matricula", "C", .F.,, .F. ) ) +  AllTrim( FTAFGetVal( cV2VPath + "/codCateg", "C", .F.,, .F. ) ) } )
								If nPosV3N > 0
									aAnalitico[nPosValores][ANALITICO_MOTIVO_DESLIGAMENTO]	:=	aV3NMotDes[nPosV3N][3]
								Else
									aAnalitico[nPosValores][ANALITICO_MOTIVO_DESLIGAMENTO]	:=	""
								EndIf

							EndIf

							nV2Y ++
							cV2YPath := cV2XPath + "/dpsPerAntE[" + cValToChar( nV2Y ) + "]"
						EndDo

						nV2X ++
						cV2XPath := cV2VPath + "/infoDpsPerAntE[" + cValToChar( nV2X ) + "]"
					EndDo

					nV2V ++
					cV2VPath := cCabec + "/infoFGTS/infoDpsFGTS/infoTrabDps[" + cValToChar( nV2V ) + "]"
				EndDo
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

				If lRet .and. lInfoRPT
					cCPF := FTAFGetVal( cCabec + "ideTrabalhador/cpfTrab", "C", .F.,, .F. )

					oInfoRPT := oReport:oVOReport
					oInfoRPT:SetIndApu( Iif( Len( cPeriodo ) <= 4, "2", "1" ) )
					oInfoRPT:SetPeriodo( Iif( Len( cPeriodo ) <= 4, cPeriodo, SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) ))
					oInfoRPT:SetCPF( AllTrim( cCPF ) )
					oInfoRPT:SetNome( AllTrim( Posicione( "C9V", 3, xFilial( "C9V" ) + cCPF + "1", "C9V_NOME" ) ) )
					oInfoRPT:SetRecibo( AllTrim( cRecibo ) )
					oInfoRPT:SetAnalitico( aAnalitico )

					oReport:UpSert( cEvtOri, "5", xFilial( "V2P" ), oInfoRPT )
				EndIf
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
	EndIf

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
/*/{Protheus.doc} TAF520Rul
@type			function
@description	Regras para gravação das informações do Evento S-5003 do eSocial
@author			Felipe C. Seolin
@since			28/12/2018
@version		1.0
@return			aRull	-	Regras para a gravação das informações
/*/
//---------------------------------------------------------------------
Static Function TAF520Rul( cEvtOri )

Local aRull		:= {}
Local cCabec	:= "/eSocial/evtBasesFGTS/"
Local cIDEvento	:= GetEvento( cEvtOri )
Local cPeriodo	:= AllTrim( StrTran( FTAFGetVal( cCabec + "ideEvento/perApur", "C", .F.,, .T. ), "-", "" ) )
Local cCPF		:= FTAFGetVal( cCabec + "ideTrabalhador/cpfTrab", "C", .F.,, .T. )
Local cNome		:= Posicione( "C9V", 3, xFilial( "C9V" ) + cCPF + "1", "C9V_NOME" )
Local cClaTrib	:= FTAFGetVal(cCabec + "infoFGTS/classTrib", "C", .F.,, .F.)

If Len( cPeriodo ) == 6 // Caso o período esteja no formato AAAA/MM, grava no formato MM/AAAA para melhor experiência do usuário. Caso esteja no formato AAAA, será gravado da forma que veio no XML.
	cPeriodo := SubStr( cPeriodo, 5, 2 ) + SubStr( cPeriodo, 1, 4 )
EndIf

aAdd( aRull, { "V2P_IDEVEN", cIDEvento, "C", .T. } )
aAdd( aRull, { "V2P_PERAPU", cPeriodo , "C", .T. } )
aAdd( aRull, { "V2P_NRRECI", FTAFGetVal( cCabec + "ideEvento/nrRecArqBase", "C", .F.,, .T. ), "C", .T. } )
aAdd( aRull, { "V2P_CPF", cCPF, "C", .T. } )

If lLaySimplif
	aAdd( aRull, { "V2P_INDAPU", FTAFGetVal( cCabec + "ideEvento/indApuracao", "C", .F.,, .F. ), "C", .T. } )
Else
	aAdd( aRull, { "V2P_NIS", FTAFGetVal( cCabec + "ideTrabalhador/nisTrab", "C", .F.,, .F. ), "C", .T. } )
EndIf

aAdd( aRull, { "V2P_NOME", AllTrim( cNome ), "C", .T. } )
aAdd( aRull, { "V2P_DTVENC", FTAFGetVal( cCabec + "infoFGTS/dtVenc", "D", .F.,, .F. ), "D", .T. } )

If TafColumnPos("V2P_CLATRI")
	aAdd( aRull, { "V2P_CLATRI", Posicione("C8D", 2, xFilial("C8D") + cClaTrib, "C8D_ID"), "C", .T. } )
EndIf

Return( aRull )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF520Xml
@type			function
@description	Função de geração do XML para o Evento S-5003.
@author			Felipe C. Seolin
@since			28/12/2018
@version		1.0
@return			cXml	-	Estrutura do XML do Layout S-5003
/*/
//---------------------------------------------------------------------
Function TAF520Xml( cAlias, nRecno, nOpc, lJob )

	Local cXml		:=	""
	Local cLayout	:=	"5003"
	Local cReg		:=	"BasesFGTS"
	Local cIdeEstab	:= ""
	Local aMensal	:=	{}
	Local lSeekV2Q	:=	.F.
	Local lSeekV2S	:=	.F.
	Local lSeekV2T	:=	.F.
	Local lSeekV2V	:=	.F.
	Local lXmlVLd	:= IIF(FindFunction('TafXmlVLD'),TafXmlVLD('TAF520XML'),.T.)
	Local lIdeEstab	:= .T.
	Local cFilBkp   := cFilAnt

	Default cAlias	:=	"V2P"

	cFilAnt := V2P->V2P_FILIAL

	If lXmlVLd

		DBSelectArea( "V2Q" )
		V2Q->( DBSetOrder( 1 ) )

		DBSelectArea( "V2R" )
		V2R->( DBSetOrder( 1 ) )

		DBSelectArea( "V2S" )
		V2S->( DBSetOrder( 1 ) )

		DBSelectArea( "V2T" )
		V2T->( DBSetOrder( 1 ) )

		DBSelectArea( "V2U" )
		V2U->( DBSetOrder( 1 ) )

		If !lLaySimplif
			DBSelectArea( "V2V" )
			V2V->( DBSetOrder( 1 ) )

			DBSelectArea( "V2W" )
			V2W->( DBSetOrder( 1 ) )

			DBSelectArea( "V2X" )
			V2X->( DBSetOrder( 1 ) )

			DBSelectArea( "V2Y" )
			V2Y->( DBSetOrder( 1 ) )
		EndIf

		DBSelectArea( "C99" )
		C99->( DBSetOrder( 1 ) )

		DBSelectArea( "C8F" )	
		C8F->( DBSetOrder( 1 ) )

		If lLaySimplif
			DBSelectArea( "V6L" )
			V6L->( DBSetOrder( 1 ) )

			DBSelectArea( "C8R" )
			C8R->( DBSetOrder( 5 ) )

			DBSelectArea( "V6P" )
			V6P->( DBSetOrder( 1 ) )
		EndIf

		aAdd( aMensal, V2P->V2P_NRRECI )

		If lLaySimplif
			aAdd( aMensal, V2P->V2P_INDAPU )
		EndIf

		If Len(AllTrim(V2P->V2P_PERAPU)) == 6
			aAdd( aMensal, SubStr( V2P->V2P_PERAPU, 3, 4 ) + "-" + SubStr( V2P->V2P_PERAPU, 1, 2 ) )
		Else
			aAdd( aMensal, V2P->V2P_PERAPU )
		EndIf

		cXml += "<ideTrabalhador>"
		cXml += 	xTafTag( "cpfTrab", V2P->V2P_CPF )

		If !lLaySimplif
			cXml += 	xTafTag( "nisTrab", V2P->V2P_NIS,, .T. )
		EndIf

		cXml += "</ideTrabalhador>"

		lSeekV2Q := V2Q->( MsSeek( xFilial( "V2Q" ) + V2P->( V2P_ID + V2P_VERSAO ) ) )
		lSeekV2V := V2V->( MsSeek( xFilial( "V2V" ) + V2P->( V2P_ID + V2P_VERSAO ) ) )

		If lSeekV2Q .or. lSeekV2V

			cXml += "<infoFGTS>"
			cXml += xTafTag("dtVenc", V2P->V2P_DTVENC,, .T.)

			If TafColumnPos("V2P_CLATRI")
				cXml += xTafTag("classTrib", AllTrim(Posicione("C8D", 1, xFilial("C8D") + V2P->V2P_CLATRI, "C8D_CODIGO")),, .T.)
			EndIf
			
			If lSeekV2Q

				While V2Q->( !Eof() ) .and. V2Q->( V2Q_FILIAL + V2Q_ID + V2Q_VERSAO ) == xFilial( "V2Q" ) + V2P->( V2P_ID + V2P_VERSAO )

					If lLaySimplif

						lIdeEstab := .T.

						If Empty(cIdeEstab) 

							cIdeEstab	:= V2Q->V2Q_TPINSC + V2Q->V2Q_NRINSC

							cXml += "<ideEstab>"
							cXml += 	xTafTag( "tpInsc", V2Q->V2Q_TPINSC )
							cXml += 	xTafTag( "nrInsc", V2Q->V2Q_NRINSC )

						ElseIf cIdeEstab <> V2Q->V2Q_TPINSC + V2Q->V2Q_NRINSC

							cXml += "</ideEstab>"

							cXml += "<ideEstab>"
							cXml += 	xTafTag( "tpInsc", V2Q->V2Q_TPINSC )
							cXml += 	xTafTag( "nrInsc", V2Q->V2Q_NRINSC )

						EndIf

						cXml += "<ideLotacao>"
						cXml += 	xTafTag( "codLotacao"	, V2Q->V2Q_CODLOT,, .T. )
						cXml += 	xTafTag( "tpLotacao"	, POSICIONE("C8F",1, xFilial("C8F")+V2Q->V2Q_TPLOT,"C8F_CODIGO"),, .T.  )
						cXml += 	xTafTag( "tpInsc"		, V2Q->V2Q_TPINES,, .T. )
						cXml += 	xTafTag( "nrInsc"		, V2Q->V2Q_NRINES,, .T. )

						If V2R->( MsSeek( xFilial( "V2R" ) + V2Q->( V2Q_ID + V2Q_VERSAO + V2Q_TPINSC + V2Q_NRINSC + V2Q_CODLOT ) ) )
							
							While V2R->( !Eof() ) .and. V2R->( V2R_FILIAL + V2R_ID + V2R_VERSAO + V2R_TPINSC + V2R_NRINSC + V2R_CODLOT ) == xFilial( "V2R" ) + V2Q->( V2Q_ID + V2Q_VERSAO + V2Q_TPINSC + V2Q_NRINSC + V2Q_CODLOT )
								
								cXml += "<infoTrabFGTS>"
								cXml += 	xTafTag( "matricula", V2R->V2R_MATRIC,, .T. )
								cXml += 	xTafTag( "codCateg", Posicione( "C87", 1, xFilial( "C87" ) + V2R->V2R_CODCAT, "C87_CODIGO" ) )
								cXml += 	xTafTag( "categOrig",Posicione( "C87", 1, xFilial( "C87" ) + V2R->V2R_CATORI, "C87_CODIGO" ),, .T. )
								cXml += 	xTafTag( "tpRegTrab", V2R->V2R_TPREG,, .T. )
								cXml += 	xTafTag( "remunSuc", V2R->V2R_REMSUC,, .T. )
								cXml += 	xTafTag( "dtDeslig", V2R->V2R_DTDESL,, .T. )
								cXml += 	xTafTag( "mtvDeslig", Posicione( "C8O", 1, xFilial( "C8O" ) + V2R->V2R_IDCMDE, "C8O_CODIGO" ),, .T. )
								cXml += 	xTafTag( "dtTerm", V2R->V2R_DTTERM,, .T. )
								cXml += 	xTafTag( "mtvDesligTSV", Posicione( "CML", 1, xFilial( "CML" ) + V2R->V2R_IDCMDD, "CML_CODIGO" ),, .T. )

								If !Empty(V2R->V2R_SUCTPV)
									cXml += "<sucessaoVinc>"
										cXml += 	xTafTag( "tpInsc"		, V2R->V2R_SUCTPV)
										cXml += 	xTafTag( "nrInsc"		, V2R->V2R_SUCINS)
										cXml += 	xTafTag( "matricAnt"	, V2R->V2R_SUCMAT,, .T. )
										cXml += 	xTafTag( "dtAdm"		, V2R->V2R_SUCDTA)
									cXml += "</sucessaoVinc>"
								EndIf

								lSeekV2S := V2S->( MsSeek( xFilial( "V2S" ) + V2R->( V2R_ID + V2R_VERSAO + V2R_TPINSC + V2R_NRINSC + V2R_CODLOT + V2R_MATRIC + V2R_CODCAT ) ) )
								lSeekV2T := V2T->( MsSeek( xFilial( "V2T" ) + V2R->( V2R_ID + V2R_VERSAO + V2R_TPINSC + V2R_NRINSC + V2R_CODLOT + V2R_MATRIC + V2R_CODCAT ) ) )

								If lSeekV2S .or. lSeekV2T
									
									cXml += "<infoBaseFGTS>"

									If lSeeKV2S
										
										While V2S->( !Eof() ) .and. V2S->( V2S_FILIAL + V2S_ID + V2S_VERSAO + V2S_TPINSC + V2S_NRINSC + V2S_CODLOT + V2S_MATRIC + V2S_CODCAT ) == xFilial( "V2S" ) + V2R->( V2R_ID + V2R_VERSAO + V2R_TPINSC + V2R_NRINSC + V2R_CODLOT + V2R_MATRIC + V2R_CODCAT )
											
											cXml += "<basePerApur>"
											cXml += 	xTafTag( "tpValor", Posicione( "V26", 1, xFilial( "V26" ) + V2S->V2S_IDTPVL, "V26_CODIGO" ) )
											cXml += 	xTafTag( "indIncid", V2S->V2S_INDINC )
											cXml += 	xTafTag( "remFGTS", V2S->V2S_VLFGTS )
											cXml += 	xTafTag( "dpsFGTS", V2S->V2S_VLDPS,, .T. )

											lSeekV6L := V6L->( MsSeek( xFilial( "V6L" ) + V2S->(V2S_ID + V2S_VERSAO + V2S_TPINSC + V2S_NRINSC + V2S_CODLOT + V2S_MATRIC + V2S_CODCAT + V2S_IDTPVL + V2S_INDINC) ) )

											If lSeekV6L
												
												While V6L->( !EOF() .And. V6L->(V6L_FILIAL + V6L_ID + V6L_VERSAO + V6L_TPINSC + V6L_NRINSC + V6L_CODLOT + V6L_MATRIC + V6L_CODCAT + V6L_IDTPVL + V6L_INDINC) == V2S->( V2S_FILIAL + V2S_ID + V2S_VERSAO + V2S_TPINSC + V2S_NRINSC + V2S_CODLOT + V2S_MATRIC + V2S_CODCAT + V2S_IDTPVL + V2S_INDINC ) )
													
													cXml += "<detRubrSusp>"
													cXml += 	xTafTag( "codRubr", Posicione( "C8R", 5, xFilial( "C8R" ) + V6L->V6L_CODRUB + "1", "C8R_CODRUB" ) )
													cXml += 	xTafTag( "ideTabRubr", Posicione( "T3M", 1, xFilial( "T3M" ) + V6L->V6L_IDTABR, "T3M_CODERP" ) )
													cXml += 	xTafTag( "vrRubr", V6L->V6L_VLTOT )
													
													lSeekV6Q := V6Q->( MsSeek( xFilial( "V6Q" ) + AllTrim(V6L->(V6L_ID + V6L_VERSAO + V6L_TPINSC + V6L_NRINSC + V6L_CODLOT + V6L_MATRIC + V6L_CODCAT + V6L_IDTPVL + V6L_INDINC + V6L_CODRUB + V6L_IDTABR )  ) ) )

													If lSeekV6Q
														
														While V6Q->( !EOF() .And. V6Q->(V6Q_FILIAL + V6Q_ID + V6Q_VERSAO + V6Q_TPINSC + V6Q_NRINSC + V6Q_CODLOT + V6Q_MATRIC + V6Q_CODCAT + V6Q_IDTPVL + V6Q_INDINC + V6Q_CODRUB + V6Q_IDTABR) == AllTrim(V6L->(V6L_FILIAL + V6L_ID + V6L_VERSAO + V6L_TPINSC + V6L_NRINSC + V6L_CODLOT + V6L_MATRIC + V6L_CODCAT + V6L_IDTPVL + V6L_INDINC + V6L_CODRUB + V6L_IDTABR )) )
															
															cXml += "<ideProcessoFGTS>"
															cXML +=		xTafTag("nrProc", V6Q->V6Q_NRPROC)
															cXml += "</ideProcessoFGTS>"

															V6Q->(DbSkip())

														EndDo													
													EndIf
													
													cXml += "</detRubrSusp>"
													V6L->(DbSkip())

												EndDo

											EndIf

											cXml += "</basePerApur>"
											V2S->( DBSkip() )

										EndDo
									EndIf

									If lSeeKV2T
										
										While V2T->( !Eof() ) .and. V2T->( V2T_FILIAL + V2T_ID + V2T_VERSAO + V2T_TPINSC + V2T_NRINSC + V2T_CODLOT + V2T_MATRIC + V2T_CODCAT ) == xFilial( "V2T" ) + V2R->( V2R_ID + V2R_VERSAO + V2R_TPINSC + V2R_NRINSC + V2R_CODLOT + V2R_MATRIC + V2R_CODCAT )
											
											cXml += "<infoBasePerAntE>"
											cXml += 	xTafTag( "perRef", SubStr( V2T->V2T_PERREF, 3, 4 ) + "-" + SubStr( V2T->V2T_PERREF, 1, 2 ) )
											
											If TafColumnPos("V2T_TPCONV")
												cXml += 	xTaftag("tpAcConv",V2T->V2T_TPCONV)
											EndIf

											If V2U->( MsSeek( xFilial( "V2U" ) + V2T->( V2T_ID + V2T_VERSAO + V2T_TPINSC + V2T_NRINSC + V2T_CODLOT + V2T_MATRIC + V2T_CODCAT + V2T_PERREF ) ) )
												
												While V2U->( !Eof() ) .and. V2U->( V2U_FILIAL + V2U_ID + V2U_VERSAO + V2U_TPINSC + V2U_NRINSC + V2U_CODLOT + V2U_MATRIC + V2U_CODCAT + V2U_PERREF ) == xFilial( "V2U" ) + V2T->( V2T_ID + V2T_VERSAO + V2T_TPINSC + V2T_NRINSC + V2T_CODLOT + V2T_MATRIC + V2T_CODCAT + V2T_PERREF )
													
													cXml += "<basePerAntE>"
													cXml += 	xTafTag( "tpValorE", Posicione( "V26", 1, xFilial( "V26" ) + V2U->V2U_IDTPVL, "V26_CODIGO" ) )
													cXml += 	xTafTag( "indIncidE", V2U->V2U_INDINC )
													cXml += 	xTafTag( "remFGTSE", V2U->V2U_VLFGTS )
													cXml += 	xTafTag( "dpsFGTSE", V2U->V2U_VLDPS,, .T. )
		
													lSeekV6P := V6P->( MsSeek( xFilial( "V6P" ) + V2U->( V2U_ID + V2U_VERSAO + V2U_TPINSC + V2U_NRINSC + V2U_CODLOT + V2U_MATRIC + V2U_CODCAT + V2U_IDTPVL + V2U_PERREF + V2U_INDINC)) )

													If lSeekV6P
														
														While V6P->( !EOF() .And. V6P->(V6P_FILIAL + V6P_ID + V6P_VERSAO + V6P_TPINSC + V6P_NRINSC + V6P_CODLOT + V6P_MATRIC + V6P_CODCAT + V6P_IDTPVL + V6P_PERREF + V6P_INDINC) == V2U->( V2U_FILIAL + V2U_ID + V2U_VERSAO + V2U_TPINSC + V2U_NRINSC + V2U_CODLOT + V2U_MATRIC + V2U_CODCAT + V2U_IDTPVL + V2U_PERREF + V2U_INDINC) )
															cXml += "<detRubrSusp>"
															cXml += 	xTafTag( "codRubr", Posicione( "C8R", 5, xFilial( "C8R" ) + V6P->V6P_CODRUB + "1", "C8R_CODRUB" ) )
															cXml += 	xTafTag( "ideTabRubr", Posicione( "T3M", 1, xFilial( "T3M" ) + V6P->V6P_IDTABR, "T3M_CODERP" ) )
															cXml += 	xTafTag( "vrRubr", V6P->V6P_VLTOT )
															cXml += "</detRubrSusp>"

															V6P->(DbSkip())

														EndDo
													EndIf

													cXml += "</basePerAntE>"
													
													V2U->( DBSkip() )

												EndDo
											EndIf

											cXml += "</infoBasePerAntE>"

											V2T->( DBSkip() )

										EndDo
									EndIf

									cXml += "</infoBaseFGTS>"

								EndIf

								If !Empty(V2R->V2R_PROCJU)
									cXml += "<procCS>"
									cXml += 	xTafTag( "nrProcJud"		, V2R->V2R_PROCJU)
									cXml += "</procCS>"
								EndIf

								cXml += "</infoTrabFGTS>"

								V2R->( DBSkip() )

							EndDo
						EndIf

						cXml += "</ideLotacao>"

					Else

						cXml += "<ideEstabLot>"
						cXml += 	xTafTag( "tpInsc", V2Q->V2Q_TPINSC )
						cXml += 	xTafTag( "nrInsc", V2Q->V2Q_NRINSC )
						cXml += 	xTafTag( "codLotacao", V2Q->V2Q_CODLOT )

						If V2R->( MsSeek( xFilial( "V2R" ) + V2Q->( V2Q_ID + V2Q_VERSAO + V2Q_TPINSC + V2Q_NRINSC + V2Q_CODLOT ) ) )
							
							While V2R->( !Eof() ) .and. V2R->( V2R_FILIAL + V2R_ID + V2R_VERSAO + V2R_TPINSC + V2R_NRINSC + V2R_CODLOT ) == xFilial( "V2R" ) + V2Q->( V2Q_ID + V2Q_VERSAO + V2Q_TPINSC + V2Q_NRINSC + V2Q_CODLOT )
								
								cXml += "<infoTrabFGTS>"
								cXml += 	xTafTag( "matricula", V2R->V2R_MATRIC,, .T. )
								cXml += 	xTafTag( "codCateg", Posicione( "C87", 1, xFilial( "C87" ) + V2R->V2R_CODCAT, "C87_CODIGO" ) )
								cXml += 	xTafTag( "dtAdm", V2R->V2R_DTADMI,, .T. )
								cXml += 	xTafTag( "dtDeslig", V2R->V2R_DTDESL,, .T. )
								cXml += 	xTafTag( "dtInicio", V2R->V2R_DTINIC,, .T. )
								cXml += 	xTafTag( "mtvDeslig", Posicione( "C8O", 1, xFilial( "C8O" ) + V2R->V2R_IDCMDE, "C8O_CODIGO" ),, .T. )
								cXml += 	xTafTag( "dtTerm", V2R->V2R_DTTERM,, .T. )
								cXml += 	xTafTag( "mtvDesligTSV", Posicione( "CML", 1, xFilial( "CML" ) + V2R->V2R_IDCMDD, "CML_CODIGO" ),, .T. )

								lSeekV2S := V2S->( MsSeek( xFilial( "V2S" ) + V2R->( V2R_ID + V2R_VERSAO + V2R_TPINSC + V2R_NRINSC + V2R_CODLOT + V2R_MATRIC + V2R_CODCAT ) ) )
								lSeekV2T := V2T->( MsSeek( xFilial( "V2T" ) + V2R->( V2R_ID + V2R_VERSAO + V2R_TPINSC + V2R_NRINSC + V2R_CODLOT + V2R_MATRIC + V2R_CODCAT ) ) )

								If lSeekV2S .or. lSeekV2T

									cXml += "<infoBaseFGTS>"

									If lSeeKV2S

										While V2S->( !Eof() ) .and. V2S->( V2S_FILIAL + V2S_ID + V2S_VERSAO + V2S_TPINSC + V2S_NRINSC + V2S_CODLOT + V2S_MATRIC + V2S_CODCAT ) == xFilial( "V2S" ) + V2R->( V2R_ID + V2R_VERSAO + V2R_TPINSC + V2R_NRINSC + V2R_CODLOT + V2R_MATRIC + V2R_CODCAT )
											
											cXml += "<basePerApur>"
											cXml += 	xTafTag( "tpValor", Posicione( "V26", 1, xFilial( "V26" ) + V2S->V2S_IDTPVL, "V26_CODIGO" ) )
											cXml += 	xTafTag( "remFGTS", V2S->V2S_VLFGTS )
											cXml += "</basePerApur>"

											V2S->( DBSkip() )

										EndDo
									EndIf

									If lSeeKV2T
										
										While V2T->( !Eof() ) .and. V2T->( V2T_FILIAL + V2T_ID + V2T_VERSAO + V2T_TPINSC + V2T_NRINSC + V2T_CODLOT + V2T_MATRIC + V2T_CODCAT ) == xFilial( "V2T" ) + V2R->( V2R_ID + V2R_VERSAO + V2R_TPINSC + V2R_NRINSC + V2R_CODLOT + V2R_MATRIC + V2R_CODCAT )
											
											cXml += "<infoBasePerAntE>"
											cXml += 	xTafTag( "perRef", SubStr( V2T->V2T_PERREF, 3, 4 ) + "-" + SubStr( V2T->V2T_PERREF, 1, 2 ) )
											
											If TafColumnPos("V2T_TPCONV")
												cXml += 	xTaftag("tpAcConv",V2T->V2T_TPCONV)
											EndIf

											If V2U->( MsSeek( xFilial( "V2U" ) + V2T->( V2T_ID + V2T_VERSAO + V2T_TPINSC + V2T_NRINSC + V2T_CODLOT + V2T_MATRIC + V2T_CODCAT + V2T_PERREF ) ) )
												
												While V2U->( !Eof() ) .and. V2U->( V2U_FILIAL + V2U_ID + V2U_VERSAO + V2U_TPINSC + V2U_NRINSC + V2U_CODLOT + V2U_MATRIC + V2U_CODCAT + V2U_PERREF ) == xFilial( "V2U" ) + V2T->( V2T_ID + V2T_VERSAO + V2T_TPINSC + V2T_NRINSC + V2T_CODLOT + V2T_MATRIC + V2T_CODCAT + V2T_PERREF )
													
													cXml += "<basePerAntE>"
													cXml += 	xTafTag( "tpValorE", Posicione( "V26", 1, xFilial( "V26" ) + V2U->V2U_IDTPVL, "V26_CODIGO" ) )
													cXml += 	xTafTag( "remFGTSE", V2U->V2U_VLFGTS )
													cXml += "</basePerAntE>"

													V2U->( DBSkip() )

												EndDo
											EndIf

											cXml += "</infoBasePerAntE>"

											V2T->( DBSkip() )

										EndDo
									EndIf

									cXml += "</infoBaseFGTS>"

								EndIf

								cXml += "</infoTrabFGTS>"

								V2R->( DBSkip() )

							EndDo
						EndIf
					EndIf

					If !lLaySimplif 
						cXml += "</ideEstabLot>"
					EndIf

					V2Q->( DBSkip() )

				EndDo

				If lLaySimplif .And. lIdeEstab
					cXml += "</ideEstab>"
				EndIf

			EndIf

			If lSeekV2V .And. !lLaySimplif

				cXml += "<infoDpsFGTS>"

				While V2V->( !Eof() ) .and. V2V->( V2V_FILIAL + V2V_ID + V2V_VERSAO ) == xFilial( "V2V" ) + V2P->( V2P_ID + V2P_VERSAO )
					
					cXml += "<infoTrabDps>"
					cXml += 	xTafTag( "matricula", V2V->V2V_MATRIC,, .T. )
					cXml += 	xTafTag( "codCateg", Posicione( "C87", 1, xFilial( "C87" ) + V2V->V2V_CODCAT, "C87_CODIGO" ) )

					If V2W->( MsSeek( xFilial( "V2W" ) + V2V->( V2V_ID + V2V_VERSAO + V2V_MATRIC + V2V_CODCAT ) ) )
						
						While V2W->( !Eof() ) .and. V2W->( V2W_FILIAL + V2W_ID + V2W_VERSAO + V2W_MATRIC + V2W_CODCAT ) == xFilial( "V2W" ) + V2V->( V2V_ID + V2V_VERSAO + V2V_MATRIC + V2V_CODCAT )
							
							cXml += "<dpsPerApur>"
							cXml += 	xTafTag( "tpDps", Posicione( "V27", 1, xFilial( "V27" ) + V2W->V2W_IDTPDP, "V27_CODIGO" ) )
							cXml += 	xTafTag( "dpsFGTS", V2W->V2W_VLFGTS )
							cXml += "</dpsPerApur>"

							V2W->( DBSkip() )

						EndDo
					EndIf

					If V2X->( MsSeek( xFilial( "V2X" ) + V2V->( V2V_ID + V2V_VERSAO + V2V_MATRIC + V2V_CODCAT ) ) )
						
						While V2X->( !Eof() ) .and. V2X->( V2X_FILIAL + V2X_ID + V2X_VERSAO + V2X_MATRIC + V2X_CODCAT ) == xFilial( "V2X" ) + V2V->( V2V_ID + V2V_VERSAO + V2V_MATRIC + V2V_CODCAT )
							
							cXml += "<infoDpsPerAntE>"
							cXml += 	xTafTag( "perRef", SubStr( V2X->V2X_PERREF, 3, 4 ) + "-" + SubStr( V2X->V2X_PERREF, 1, 2 ) )
							
							If TafColumnPos("V2X_TPCONV")
								cXml += 	xTaftag("tpAcConv",V2X->V2X_TPCONV)
							EndIf

							If V2Y->( MsSeek( xFilial( "V2Y" ) + V2X->( V2X_ID + V2X_VERSAO + V2X_MATRIC + V2X_CODCAT + V2X_PERREF ) ) )
								While V2Y->( !Eof() ) .and. V2Y->( V2Y_FILIAL + V2Y_ID + V2Y_VERSAO + V2Y_MATRIC + V2Y_CODCAT + V2Y_PERREF ) == xFilial( "V2Y" ) + V2X->( V2X_ID + V2X_VERSAO + V2X_MATRIC + V2X_CODCAT + V2X_PERREF )
									
									cXml += "<dpsPerAntE>"
									cXml += 	xTafTag( "tpDpsE", Posicione( "V27", 1, xFilial( "V27" ) + V2Y->V2Y_IDTPDP, "V27_CODIGO" ) )
									cXml += 	xTafTag( "dpsFGTSE", V2Y->V2Y_VLFGTS )
									cXml += "</dpsPerAntE>"

									V2Y->( DBSkip() )

								EndDo
							EndIf

							cXml += "</infoDpsPerAntE>"

							V2X->( DBSkip() )
							
						EndDo
					EndIf

					cXml += "</infoTrabDps>"

					V2V->( DBSkip() )

				EndDo

				cXml += "</infoDpsFGTS>"

			EndIf

			cXml += "</infoFGTS>"

		EndIf

		V2Q->( DBCloseArea() )
		V2R->( DBCloseArea() )
		V2S->( DBCloseArea() )
		V2T->( DBCloseArea() )
		V2U->( DBCloseArea() )
		V2V->( DBCloseArea() )
		V2W->( DBCloseArea() )
		V2X->( DBCloseArea() )
		V2Y->( DBCloseArea() )

		//Estrutura do cabeçalho
		cXml := xTafCabXml( cXml, "V2P", cLayout, cReg, aMensal )

		//Executa a gravação do registro
		If !lJob
			xTafGerXml( cXml, cLayout )
		EndIf

	EndIf

	If !( Empty( cFilBkp ) )
		cFilAnt := cFilBkp
	EndIf

Return( cXml )
//---------------------------------------------------------------------
/*/{Protheus.doc} SearchRec
@type			function
@description	Verifica a existência do Evento S-5003 a partir do Recibo.
@author			Felipe C. Seolin
@since			08/01/2018
@version		1.0
@param			cRecibo		-	Recibo do evento original
@param			cFilGrv		-	Filial da localização do Recibo ( Referência )
@param			dDtLegado	-	Data do parâmetro MV_TOTEXDT ( Referência )
@return			lRet		-	Indica se existe Evento S-5003 para o Recibo indicado
/*/
//---------------------------------------------------------------------
Static Function SearchRec( cRecibo, cFilGrv, dDtLegado )

Local cAliasQry	:=	GetNextAlias()
Local cQuery	:=	""
Local lRet		:=	.F.

cQuery := "SELECT V2P.V2P_FILGRV, V2P.V2P_SITPAR "
cQuery += "FROM " + RetSqlName( "V2P" ) + " V2P "
cQuery += "WHERE V2P.V2P_NRRECI = '" + cRecibo + "' "
cQuery += "  AND V2P.V2P_ATIVO = '1' "
cQuery += "  AND V2P.D_E_L_E_T_ = '' "

cQuery := ChangeQuery( cQuery )

DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cAliasQry, .F., .T. )

If ( cAliasQry )->( !Eof() )
	cFilGrv := ( cAliasQry )->V2P_FILGRV
	dDtLegado := SToD( ( cAliasQry )->V2P_SITPAR )
	lRet := .T.
EndIf

( cAliasQry )->( DBCloseArea() )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetEvento
@type			function
@description	Busca o ID do Evento Original a partir do Recibo.
@author			Felipe C. Seolin
@since			04/01/2018
@version		1.0
@param			cRecibo	-	Recibo do evento original
@return			cEvento	-	Evento original
/*/
//---------------------------------------------------------------------
Static Function GetEvento( cEvtOri )

Local cEvento		:=	""
Local cEvtPermitido	:= "S-1200|S-2299|S-2399" + Iif(lLaySimplif,"|S-3000","")
Default cEvtOri 	:=  ""


If cEvtOri $ cEvtPermitido
	cEvento := Posicione( "C8E", 2, xFilial( "C8E" ) + cEvtOri, "C8E_ID" )
EndIf

Return( cEvento )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFAlw5003
@type			function
@description	Indica os Eventos permitidos para utilização do Evento S-5003.
@author			Felipe C. Seolin
@since			03/01/2018
@version		1.0
@return			cRet	-	Eventos permitidos para utilização do Evento S-5003
/*/
//---------------------------------------------------------------------
Function TAFAlw5003()

Local cRet	:=	"S-1200|S-2299|S-2399" + Iif(lLaySimplif,"|S-3000","")

Return( cRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFEvt5003
@type			function
@description	Verifica se o Evento pertence aos Eventos permitido pelo S-5003.
@author			Felipe C. Seolin
@since			03/01/2018
@version		1.0
@param			cEvento	-	Evento a ser verificado
@return			lRet	-	Indica se o Evento é permitido ao S-5003
/*/
//---------------------------------------------------------------------
Function TAFEvt5003( cEvento )

Local cAllowed	:=	TAFAlw5003()
Local lRet		:=	.F.

Default cEvento	:=	""

If "S-" $ cEvento
	lRet := cEvento $ cAllowed
Else
	lRet := Posicione( "C8E", 1, xFilial( "C8E" ) + cEvento, "C8E_CODIGO" ) $ cAllowed
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF520Valid
@type			function
@description	Validação dos campos para o cadastro de Informações do FGTS por Trabalhador - S-5003.
@author			Felipe C. Seolin
@since			03/01/2018
@version		1.0
@return			lRet	-	Indica se todas as condições foram respeitadas
/*/
//---------------------------------------------------------------------
Function TAF520Valid()

Local cCampo	:=	SubStr( ReadVar(), At( ">", ReadVar() ) + 1 )
Local lRet		:=	.T.

If cCampo == "V2P_IDEVEN"

	If !TAFEvt5003( M->V2P_IDEVEN )
		Help( ,, "HELP",, STR0019, 1, 0 ) //"O Evento informado não é um evento origem para o S-5003."
		lRet := .F.
	EndIf

ElseIf cCampo == "V2U_IDTPVL"

	If Len( AllTrim( M->V2U_IDTPVL ) ) > 2
		If !( AllTrim( Posicione( "V26", 1, xFilial( "V26" ) + M->V2U_IDTPVL, "V26_CODIGO" ) ) $ "13|14|17|18|24|25|26|30|31|32|43|44|48|49|50|91" )
			Help( ,, "HELP",, STR0020, 1, 0 ) //"Tipo de Valor informado não permitido."
			lRet := .F.
		EndIf
	Else
		If !( AllTrim( M->V2U_IDTPVL ) $ "13|14|17|18|24|25|26|30|31|32|91" )
			Help( ,, "HELP",, STR0020, 1, 0 ) //"Tipo de Valor informado não permitido."
			lRet := .F.
		EndIf
	EndIf

ElseIf cCampo == "V2Y_IDTPDP"

	If Len( AllTrim( M->V2Y_IDTPDP ) ) > 2
		If !( AllTrim( Posicione( "V27", 1, xFilial( "V27" ) + M->V2Y_IDTPDP, "V27_CODIGO" ) ) $ "53|54|57|58|64|65|66|70|71|72" )
			Help( ,, "HELP",, STR0021, 1, 0 ) //"Tipo de Depósito informado não permitido."
			lRet := .F.
		EndIf
	Else
		If !( AllTrim( M->V2Y_IDTPDP ) $ "53|54|57|58|64|65|66|70|71|72" )
			Help( ,, "HELP",, STR0021, 1, 0 ) //"Tipo de Depósito informado não permitido."
			lRet := .F.
		EndIf
	EndIf

EndIf

Return( lRet )

//--------------------------------------------------------------------
/*/{Protheus.doc} SetCssButton

Cria objeto TButton utilizando CSS

@author Eduardo Sukeda
@since 22/03/2019
@version 1.0

@param cTamFonte - Tamanho da Fonte
@param cFontColor - Cor da Fonte
@param cBackColor - Cor de Fundo do Botão
@param cBorderColor - Cor da Borda

@return cCss
/*/
//--------------------------------------------------------------------
Static Function SetCssButton(cTamFonte,cFontColor,cBackColor,cBorderColor)

Local cCSS := ""

cCSS := "QPushButton{ background-color: " + cBackColor + "; "
cCSS += "border: none; "
cCSS += "font: bold; "
cCSS += "color: " + cFontColor + ";" 
cCSS += "padding: 2px 5px;" 
cCSS += "text-align: center; "
cCSS += "text-decoration: none; "
cCSS += "display: inline-block; "
cCSS += "font-size: " + cTamFonte + "px; "
cCSS += "border: 1px solid " + cBorderColor + "; "
cCSS += "border-radius: 3px "
cCSS += "}"

Return cCSS

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF520Rpt
@type			function
@description	Inicializa a variável static __lGrvRPT
@author			Felipe C. Seolin
@since			23/05/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function TAF520Rpt()

__lGrvRPT := TAFAlsInDic( "V3N" )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF520DIC
@type			function
@description	Função genérica chamada do dicionário de dados
@author			totvs
@since			08/03/2021
@version		1.0
/*/
//---------------------------------------------------------------------
Function TAF520DIC(cField)
Local cRet	:= ""

Default cField := ""

If lLaySimplif
	If cField == 'V2Q_DTPLOT'
		cRet := Posicione("C8F",1, xFilial("C8F")+V2Q->V2Q_TPLOT,"C8F_CODIGO + ' - ' +C8F_DESCRI")

	ElseIf cField == 'V2R_DCATOR'
		cRet := Posicione("C87",1,xFilial("C87")+V2R->V2R_CATORI,"C87_CODIGO+' – '+C87_DESCRI")    

	ElseIf cField == 'V6L_DCODRU'
		cRet := Posicione("C8R",1,xFilial("C8R")+V6L->V6L_CODRUB,"AllTrim(C8R_CODRUB)+' – '+AllTrim(C8R_DESRUB)")  

	ElseIf cField == 'V6P_DCODRU'
		cRet := Posicione("C8R",1,xFilial("C8R")+V6P->V6P_CODRUB,"AllTrim(C8R_CODRUB)+' – '+AllTrim(C8R_DESRUB)")  
	EndIf
EndIf

Return cRet
