#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFA266.CH"

#DEFINE CRLF 							Chr(13) + Chr(10)
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

Static __cPicVAdv  := Nil
Static __cPicVCus  := Nil
Static __lGrvRPT   := Nil
Static slRubERPPad := Nil
Static cLayNmSpac  := Nil
Static lLaySimplif := TAFLayESoc(, .T.)
Static lSimplBeta  := TAFLayESoc("S_01_01_00", .T., .T.)
Static nTamCMDFunc := Nil
Static oReport     := Nil

//----------------------------------------------------------------------
/*/{Protheus.doc} TAFA266
Cadastro MVC de Desligamento - S-2299

@author Felipe C. Seolin
@since 16/09/2013
@version 1.0

/*/
//---------------------------------------------------------------------
Function TAFA266()

	Local aOnlyFields as Array

	Private cNomEve   as Character
	Private oBrw      as Object

	aOnlyFields := {}
	cNomEve     := "S2299"
	oBrw        := FWmBrowse():New()
	
	oBrw:SetCacheView(.F.)

	If !lLaySimplif
		aOnlyFields   := { 'CMD_FILIAL', 'CMD_ID', 'CMD_FUNC', 'CMD_MOTDES', 'CMD_DTDESL', 'CMD_INDPAG', 'CMD_TERAPI', 'CMD_NRATES', 'CMD_INDCUM', 'CMD_DINSIS', 'CMD_NOMEV', 'CMD_CPFV', 'CMD_NISV', 'CMD_MATV' }
	Else
		aOnlyFields   := { 'CMD_FILIAL', 'CMD_ID', 'CMD_FUNC', 'CMD_MOTDES', 'CMD_DTDESL', 'CMD_DTAVPR', 'CMD_INDPAG', 'CMD_TERAPI', 'CMD_DINSIS', 'CMD_NOMEV', 'CMD_CPFV', 'CMD_MATV' }
	EndIf

	If FindFunction("FilCpfNome") .AND. !FwIsInCallStack("TAFPNFUNC") .AND. !FwIsInCallStack("TAFMONTES")

		TafNewBrowse( "S-2299","CMD_DTDESL",,2, STR0001, aOnlyFields, 2, 2 ) //"Desligamento"

	Else

		// Função que indica se o ambiente é válido para o eSocial 2.3
		If TafAtualizado()

			oBrw:SetDescription(STR0001) //"Desligamento"
			oBrw:SetAlias("CMD")
			oBrw:SetMenuDef("TAFA266")

			If FindFunction('TAFSetFilter')
				oBrw:SetFilterDefault(TAFBrwSetFilter("CMD","TAFA266","S-2299"))
			Else
				oBrw:SetFilterDefault( "CMD_ATIVO == '1'" ) //Filtro para que apenas os registros ativos sejam exibidos (1 = Ativo, 2 = Inativo)
			EndIf

			TafLegend(2,"CMD",@oBrw)
			oBrw:Activate()

		EndIF

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Felipe C. Seolin
@since 16/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao as array
	Local aRotina as array

	aFuncao := {}
	aRotina := {}

	If FindFunction("FilCpfNome") .AND. !FwIsInCallStack("TAFPNFUNC") .AND. !FwIsInCallStack("TAFMONTES")

		ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.TAFA266' OPERATION 2 ACCESS 0 //'Visualizar'
		ADD OPTION aRotina TITLE "Incluir"    ACTION 'VIEWDEF.TAFA266' OPERATION 3 ACCESS 0 //'Incluir'
		ADD OPTION aRotina TITLE "Alterar"    ACTION 'VIEWDEF.TAFA266' OPERATION 4 ACCESS 0 //'Alterar'
		ADD OPTION aRotina TITLE "Imprimir"	  ACTION 'VIEWDEF.TAFA266' OPERATION 8 ACCESS 0 //'Imprimir'

	Else

		Aadd( aFuncao, { "" , "TAF266Xml" , "1" } )
		Aadd( aFuncao, { "" , "xFunAltRec( 'CMD' )" , "10" } )

		//Chamo a Browse do Histórico
		If FindFunction( "xNewHisAlt" )
			Aadd( aFuncao, { "" , "xNewHisAlt( 'CMD', 'TAFA266' )" , "3" } )
		Else
			Aadd( aFuncao, { "" , "xFunHisAlt( 'CMD', 'TAFA266' )" , "3" } )
		EndIf

		Aadd( aFuncao, { "" , "StaticCall(TAFA266,PreXmlLote)" , "5" } )

		lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

		If lMenuDif
			ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.TAFA266' OPERATION 2 ACCESS 0 //"Visualizar"

			// Menu dos extemporâneos
			If FindFunction( "xNewHisAlt" ) .AND. FindFunction( "xTafExtmp" ) .And. xTafExtmp()
				aRotina	:= xMnuExtmp( "TAFA266", "CMD" )
			Endif

		Else
			aRotina	:=	xFunMnuTAF( "TAFA266" , , aFuncao)
		EndIf

	EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função que chama a TAFXmlLote e limpa slRubERPPad

@author brunno.costa
@since 25/09/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function PreXmlLote()

	TAFXmlLote( 'CMD', 'S-2299' , 'evtDeslig' , 'TAF266Xml' )
	slRubERPPad := Nil	//Limpa variável no final do processo em lote

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Felipe C. Seolin
@since 16/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStruCMD as Object
	Local oStruT06 as Object
	Local oStruT3G as Object
	Local oStruT05 as Object
	Local oStruT15 as Object
	Local oStruT16 as Object
	Local oStruT5I as Object
	Local oStruT5J as Object
	Local oStruT5Q as Object
	Local oStruT5S as Object
	Local oStruT88 as Object
	Local oStruC9J as Object
	Local oStruT3H as Object
	Local oStruV1M as Object
	Local oStruV1N as Object
	Local oStruV6D as Object
	Local oStruV9N as object
	Local oModel   as Object

	oStruV6D := Nil
	oStruCMD := FWFormStruct( 1, "CMD" )
	oStruT06 := FWFormStruct( 1, "T06" )
	oStruT3G := FWFormStruct( 1, "T3G" )
	oStruT05 := FWFormStruct( 1, "T05" )
	oStruT15 := FWFormStruct( 1, "T15" )
	oStruT16 := FWFormStruct( 1, "T16" )
	oStruT5I := FWFormStruct( 1, "T5I" )
	oStruT5J := FWFormStruct( 1, "T5J" )
	oStruT5Q := FWFormStruct( 1, "T5Q" )
	oStruT5S := FWFormStruct( 1, "T5S" )
	oStruT88 := FWFormStruct( 1, "T88" )
	oStruC9J := FWFormStruct( 1, "C9J" )
	oStruT3H := FWFormStruct( 1, "T3H" )
	oStruV1M := FWFormStruct( 1, "V1M" )
	oStruV1N := FWFormStruct( 1, "V1N" )
	oStruV9N := Iif(lSimplBeta, FwFormStruct( 1, "V9N" ), Nil)
	oModel   := MPFormModel():New("TAFA266", , IIF(!lLaySimplif,{|oModel| ValidModel( oModel ) }, { || .T. }), { |oModel| SaveModel( oModel )})

	SetLayout()

	If lLaySimplif
		oStruV6D := FWFormStruct( 1, "V6D" )
		oStruCMD:RemoveField("CMD_NRATES")
		oStruCMD:RemoveField("CMD_INDCUM")
		oStruCMD:RemoveField("CMD_QTDDIA")
		oStruCMD:RemoveField("CMD_CNPJSU")
		oStruT5I:RemoveField("T5I_COMPAC")
		oStruT5I:RemoveField("T5I_DTEFAC")
		oStruT05:RemoveField("T05_QTDRUB")
		oStruT05:RemoveField("T05_VLRUNI")
		oStruT5S:RemoveField("T5S_QTDRUB")
		oStruT5S:RemoveField("T5S_VLRUNI")
		oStruT88:RemoveField("T88_IDCODC")
		If lSimplBeta
			oStruCMD:RemoveField("CMD_DTQUA")
		Else
			oStruCMD:RemoveField("CMD_INDREM")
			oStruCMD:RemoveField("CMD_DTFREM")
		EndIf
	Else
		oStruCMD:RemoveField("CMD_DTAVPR")
		oStruCMD:RemoveField("CMD_NRINSC")
		oStruCMD:RemoveField("CMD_INDGUI")
		oStruCMD:RemoveField("CMD_INDREM")
		oStruCMD:RemoveField("CMD_DTFREM")
		oStruT05:RemoveField("T05_SQTDRB")
		oStruT05:RemoveField("T05_APURIR")
		oStruT5S:RemoveField("T5S_SQTDRB")
		oStruT5S:RemoveField("T5S_APURIR")
	EndIf

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruCMD:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	EndIf

	oStruCMD:SetProperty("CMD_INDCSG", MODEL_FIELD_OBRIGAT, .F.)

	If lLaySimplif
		oStruCMD:SetProperty("CMD_PENALI", MODEL_FIELD_OBRIGAT, .F.)
		oStruV6D:SetProperty("V6D_DIA", MODEL_FIELD_VALID, {|oModel| lVldDiaTrb(oModel) })
	EndIf

	//Remoção do GetSX8Num quando se tratar da Exclusão de um Evento Transmitido.
	//Necessário para não incrementar ID que não será utilizado.
	If Upper( ProcName( 2 ) ) == Upper( "GerarExclusao" )
		oStruCMD:SetProperty( "CMD_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )
	EndIf

	//////////////////////////////Trabalhador/Desligamento
	oModel:AddFields( "MODEL_CMD", /*cOwner*/, oStruCMD, { |oModelCMD, cAction, cIDField, xValue| ValidCMD( oModelCMD, cAction, cIDField, xValue ) } )
	
	/////////////////////////Verbas Rescisão Contratual
	/////////////////Demonstrativos de Valores
	oModel:AddGrid("MODEL_T06", "MODEL_CMD", oStruT06 )
	oModel:GetModel( "MODEL_T06" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_T06" ):SetUniqueLine( { "T06_IDEDMD" } )
	oModel:GetModel( "MODEL_T06" ):SetMaxLine(50)

	////////////Periódo Apuração

	If lSimplBeta .And. TafColumnPos("T06_INDRRA")
		oModel:AddGrid("MODEL_V9N", "MODEL_T06", oStruV9N)
		oModel:GetModel( "MODEL_V9N" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V9N" ):SetUniqueLine( { "V9N_TPINSC", "V9N_NRINSC" } )
		oModel:GetModel('MODEL_V9N'):SetMaxLine(99)
	EndIf

	////////Estabelecimento/Lotação
	oModel:AddGrid("MODEL_T3G", "MODEL_T06", oStruT3G)
	oModel:GetModel( "MODEL_T3G" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_T3G" ):SetUniqueLine( { "T3G_ESTABE", "T3G_LOTTRB" } )
	oModel:GetModel( "MODEL_T3G" ):SetMaxLine(24)

	//////Detalhamento Verbas Rescisórias
	oModel:AddGrid("MODEL_T05", "MODEL_T3G", oStruT05)
	oModel:GetModel( "MODEL_T05" ):SetOptional( .T. )

	If TafColumnPos("T05_SEQUEN")
		oModel:GetModel( "MODEL_T05" ):SetUniqueLine( { "T05_CODRUB", "T05_SEQUEN" } )
	Else
		oModel:GetModel( "MODEL_T05" ):SetUniqueLine( { "T05_CODRUB" } )
	EndIf

	oModel:GetModel( "MODEL_T05" ):SetMaxLine(200)

	If !lLaySimplif
		//////Informações de Plano de Saude

		///Detalhamento das Operadoras
		oModel:AddGrid("MODEL_T15", "MODEL_T3G", oStruT15)
		oModel:GetModel( "MODEL_T15" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_T15" ):SetUniqueLine( { "T15_CNPJOP", "T15_REGANS" } )
		oModel:GetModel( "MODEL_T15" ):SetMaxLine(99)

		//Informações do Dependente
		oModel:AddGrid("MODEL_T16", "MODEL_T15", oStruT16)
		oModel:GetModel( "MODEL_T16" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_T16" ):SetUniqueLine( { "T16_DTNDEP", "T16_NOMDEP", "T16_TPDEP" } )
		oModel:GetModel( "MODEL_T16" ):SetMaxLine(99)
	EndIf

	////////////"Períodos Anteriores"

	////////Identificação ADC
	oModel:AddGrid("MODEL_T5I", "MODEL_T06", oStruT5I)
	oModel:GetModel( "MODEL_T5I" ):SetOptional( .T. )
	If  !lLaySimplif
		oModel:GetModel( "MODEL_T5I" ):SetUniqueLine( { "T5I_DTACCO","T5I_TPACCO","T5I_COMPAC","T5I_DTEFAC" } )
	Else
		oModel:GetModel( "MODEL_T5I" ):SetUniqueLine( { "T5I_DTACCO","T5I_TPACCO" } )
	EndIf
	oModel:GetModel("MODEL_T5I"):SetMaxLine(8)

	//////Identificação do Período
	oModel:AddGrid("MODEL_T5J", "MODEL_T5I", oStruT5J)
	oModel:GetModel( "MODEL_T5J" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_T5J" ):SetUniqueLine( { "T5J_PERREF" } )
	oModel:GetModel( "MODEL_T5J" ):SetMaxLine(180)

	////Estabelecimento/Lotação
	oModel:AddGrid("MODEL_T5Q", "MODEL_T5J", oStruT5Q)
	oModel:GetModel( "MODEL_T5Q" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_T5Q" ):SetUniqueLine( { "T5Q_ESTABE","T5Q_LOTTRB" } )
	oModel:GetModel( "MODEL_T5Q" ):SetMaxLine(24)

	//////Detalhamento Verbas Rescisórias
	oModel:AddGrid("MODEL_T5S", "MODEL_T5Q", oStruT5S)
	oModel:GetModel( "MODEL_T5S" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_T5S" ):SetUniqueLine( { "T5S_CODRUB" } )
	oModel:GetModel( "MODEL_T5S" ):SetMaxLine(200)

	If !lLaySimplif
		////////////Informações da convocação para trabalho intermitente
		oModel:AddGrid( "MODEL_T88", "MODEL_T06", oStruT88, { |oModelT88, nLine, cAction, cIDField, xValue, xCurrentValue| ValidT88( oModelT88, nLine, cAction, cIDField, xValue, xCurrentValue ) } )
		oModel:GetModel( "MODEL_T88" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_T88" ):SetUniqueLine( { "T88_CODCON" } )
		oModel:GetModel( "MODEL_T88" ):SetMaxLine( 99 )
	EndIf

	/////////////////Informação Multiplos Vinculos

	///////////Remuneração Outras Empresas
	oModel:AddGrid("MODEL_C9J", "MODEL_CMD", oStruC9J)
	oModel:GetModel( "MODEL_C9J" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_C9J" ):SetUniqueLine( { "C9J_TPINSC" , "C9J_NRINSC"} )
	oModel:GetModel("MODEL_C9J"):SetMaxLine(999) //Grupo {remunOutrEmpr} – alterada ocorrência.

	/////////////////Informações Processos Judiciais do Trabalhador
	oModel:AddGrid("MODEL_T3H", "MODEL_CMD", oStruT3H)
	oModel:GetModel( "MODEL_T3H" ):SetOptional( .T. )
	If !lLaySimplif
		oModel:GetModel( "MODEL_T3H" ):SetUniqueLine( { "T3H_TPTRIB" , "T3H_IDPROC" } )
	Else
		oModel:GetModel( "MODEL_T3H" ):SetUniqueLine( { "T3H_TPTRIB" , "T3H_IDPROC", "T3H_IDSUSP" } )
	EndIf
	oModel:GetModel( "MODEL_T3H" ):SetMaxLine(99)

	IF lLaySimplif
		/////////////////Informações relativas ao trabalho intermitente
		oModel:AddGrid("MODEL_V6D", "MODEL_CMD", oStruV6D)
		oModel:GetModel( "MODEL_V6D" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V6D" ):SetUniqueLine( { "V6D_DIA" } )
		oModel:GetModel( "MODEL_V6D" ):SetMaxLine(31)
	EndIf

	/////////////////Observações sobre o desligamento
	oModel:AddGrid("MODEL_V1M", "MODEL_CMD", oStruV1M)
	oModel:GetModel( "MODEL_V1M" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_V1M" ):SetUniqueLine( { "V1M_CODOBS" } )
	oModel:GetModel( "MODEL_V1M" ):SetMaxLine(99)
	
	/////////////////nformações sobre operação de crédito consignado com garantia de FGTS
	oModel:AddGrid("MODEL_V1N", "MODEL_CMD", oStruV1N)
	oModel:GetModel( "MODEL_V1N" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_V1N" ):SetUniqueLine( { "V1N_INSCSG" , "V1N_NRCONT" } )
	oModel:GetModel( "MODEL_V1N" ):SetMaxLine(99)

	oModel:SetRelation("MODEL_T06",{ {"T06_FILIAL","xFilial('T06')"}, {"T06_ID","CMD_ID"}, {"T06_VERSAO","CMD_VERSAO"} },T06->(IndexKey(1)) )
	oModel:SetRelation("MODEL_T3G",{ {"T3G_FILIAL","xFilial('T3G')"}, {"T3G_ID","CMD_ID"}, {"T3G_VERSAO","CMD_VERSAO"}, {"T3G_RECPAG","T06_IDEDMD"} },T3G->(IndexKey(1)) )
	
	If lSimplBeta .And. TafColumnPos("T06_INDRRA")
		oModel:SetRelation("MODEL_V9N",{ {"V9N_FILIAL","xFilial('V9N')"}, {"V9N_ID","CMD_ID"}, {"V9N_VERSAO","CMD_VERSAO"}, {"V9N_RECPAG","T06_IDEDMD"} },V9N->(IndexKey(1)))
	EndIf

	oModel:SetRelation("MODEL_T05",{ {"T05_FILIAL","xFilial('T05')"}, {"T05_ID","CMD_ID"}, {"T05_VERSAO","CMD_VERSAO"}, {"T05_RECPAG","T06_IDEDMD"}, {"T05_ESTABE","T3G_ESTABE"},{"T05_LOTTRB","T3G_LOTTRB"} },T05->(IndexKey(1)) )
	
	If !lLaySimplif
		oModel:SetRelation("MODEL_T15",{ {"T15_FILIAL","xFilial('T15')"}, {"T15_ID","CMD_ID"}, {"T15_VERSAO","CMD_VERSAO"}, {"T15_RECIBO","T06_IDEDMD"}, {"T15_ESTABE","T3G_ESTABE"},{"T15_LOTACA","T3G_LOTTRB"}}, T15->(IndexKey(1)))
		oModel:SetRelation("MODEL_T16",{ {"T16_FILIAL","xFilial('T16')"}, {"T16_ID","CMD_ID"}, {"T16_VERSAO","CMD_VERSAO"}, {"T16_RECIBO","T06_IDEDMD"}, {"T16_ESTABE","T3G_ESTABE"}, {"T16_LOTACA","T3G_LOTTRB"}, {'T16_CNPJOP','T15_CNPJOP'}, {'T16_REGANS','T15_REGANS'} }, T16->(IndexKey(1)))
	EndIf

	oModel:SetRelation("MODEL_T5I",{ {"T5I_FILIAL","xFilial('T5I')"}, {"T5I_ID","CMD_ID"}, {"T5I_VERSAO","CMD_VERSAO"}, {"T5I_IDEDMD","T06_IDEDMD"} },T5I->(IndexKey(1)) )
	oModel:SetRelation("MODEL_T5J",{ {"T5J_FILIAL","xFilial('T5J')"}, {"T5J_ID","CMD_ID"}, {"T5J_VERSAO","CMD_VERSAO"}, {"T5J_IDEDMD","T06_IDEDMD"}, {"T5J_DTACCO","T5I_DTACCO"}, {"T5J_TPACCO","T5I_TPACCO"} },T5J->(IndexKey(1)) )
	oModel:SetRelation("MODEL_T5Q",{ {"T5Q_FILIAL","xFilial('T5Q')"}, {"T5Q_ID","CMD_ID"}, {"T5Q_VERSAO","CMD_VERSAO"}, {"T5Q_IDEDMD","T06_IDEDMD"}, {"T5Q_DTACCO","T5I_DTACCO"}, {"T5Q_TPACCO","T5I_TPACCO"}, {"T5Q_PERREF","T5J_PERREF"} },T5Q->(IndexKey(1)) )
	oModel:SetRelation("MODEL_T5S",{ {"T5S_FILIAL","xFilial('T5S')"}, {"T5S_ID","CMD_ID"}, {"T5S_VERSAO","CMD_VERSAO"}, {"T5S_IDEDMD","T06_IDEDMD"}, {"T5S_DTACCO","T5I_DTACCO"}, {"T5S_TPACCO","T5I_TPACCO"}, {"T5S_PERREF","T5J_PERREF"}, {"T5S_ESTABE","T5Q_ESTABE"},{"T5S_LOTTRB","T5Q_LOTTRB"} },T5S->(IndexKey(1)) )

	If !lLaySimplif
		oModel:SetRelation("MODEL_T88",{ {"T88_FILIAL","xFilial('T88')"}, {"T88_ID","CMD_ID"}, {"T88_VERSAO","CMD_VERSAO"}, {"T88_IDEDMD","T06_IDEDMD"} }, T88->( IndexKey( 1 ) ) )
	EndIf

	oModel:SetRelation("MODEL_T3H",{ {"T3H_FILIAL","xFilial('T3H')"}, {"T3H_ID","CMD_ID"}, {"T3H_VERSAO","CMD_VERSAO"} },T3H->(IndexKey(1)) )
	oModel:SetRelation("MODEL_C9J",{ {"C9J_FILIAL","xFilial('C9J')"}, {"C9J_ID","CMD_ID"}, {"C9J_VERSAO","CMD_VERSAO"} },C9J->(IndexKey(1)) )

	If lLaySimplif
		oModel:SetRelation("MODEL_V6D",{ {"V6D_FILIAL","xFilial('V6D')"}, {"V6D_ID","CMD_ID"}, {"V6D_VERSAO","CMD_VERSAO"} },V6D->(IndexKey(1)) )
	EndIf

	oModel:SetRelation("MODEL_V1M",{ {"V1M_FILIAL","xFilial('V1M')"}, {"V1M_ID","CMD_ID"}, {"V1M_VERSAO","CMD_VERSAO"} },V1M->(IndexKey(1)) )
	oModel:SetRelation("MODEL_V1N",{ {"V1N_FILIAL","xFilial('V1N')"}, {"V1N_ID","CMD_ID"}, {"V1N_VERSAO","CMD_VERSAO"} },V1N->(IndexKey(1)) )

	oModel:GetModel("MODEL_CMD" ):SetPrimaryKey({"CMD_FUNC","CMD_MOTDES","CMD_DTDESL","CMD_INDPAG"})

Return(oModel)

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Felipe C. Seolin
@since 16/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local aCmpGrp   as Array
	Local cCmpFil   as Character
	Local cCmpFilp  as Character
	Local cCmpFild  as Character
	Local cCmpFils  as Character
	Local cCmpFilv  as Character
	Local cCmpFilq  as Character
	Local cCmpFilt  as Character
	Local cCmpFilh  as Character
	Local cCmpFilg  as Character
	Local nI        as Numeric
	Local oModel    as Object
	Local oStruCMD  as Object
	Local oStruCMDp as Object
	Local oStruCMDq as Object
	Local oStruCMDv as Object
	Local oStruT06  as Object
	Local oStruT3G  as Object
	Local oStruT05  as Object
	Local oStruT15  as Object
	Local oStruT16  as Object
	Local oStruT5I  as Object
	Local oStruT5J  as Object
	Local oStruT5Q  as Object
	Local oStruT5S  as Object
	Local oStruT88  as Object
	Local oStruC9J  as Object
	Local oStruT3H  as Object
	Local oStruV1M  as Object
	Local oStruV1N  as Object
	Local oStruV6D  as Object
	Local oStruV9N	as object
	Local oView     as Object

	aCmpGrp   := {}
	cCmpFil   := ""
	cCmpFilp  := ""
	cCmpFild  := ""
	cCmpFils  := ""
	cCmpFilv  := ""
	cCmpFilq  := ""
	cCmpFilt  := ""
	cCmpFilh  := ""
	cCmpFilg  := ""
	nI        := 0
	oStruCMDp := Nil
	oStruCMDq := Nil
	oStruCMDv := Nil
	oStruV6D  := Nil
	oModel    := FWLoadModel("TAFA266")
	oStruT06  := FWFormStruct(2,"T06")
	oStruT3G  := FWFormStruct(2,"T3G")
	oStruT05  := FWFormStruct(2,"T05")
	oStruT15  := FWFormStruct(2,"T15")
	oStruT16  := FWFormStruct(2,"T16")
	oStruT5I  := FwFormStruct(2,"T5I")
	oStruT5J  := FwFormStruct(2,"T5J")
	oStruT5Q  := FWFormStruct(2,"T5Q")
	oStruT5S  := FWFormStruct(2,"T5S")
	oStruT88  := FwFormStruct(2,"T88")
	oStruC9J  := FWFormStruct(2,"C9J")
	oStruT3H  := FWFormStruct(2,"T3H")
	oStruV1M  := FWFormStruct(2,"V1M")
	oStruV1N  := FWFormStruct(2,"V1N")
	oStruV9N  := Iif((lSimplBeta .And. TafColumnPos("T06_INDRRA")), FwFormStruct( 2, "V9N" ), Nil)
	oView     := FWFormView():New()

	If lLaySimplif
		oStruV6D := FWFormStruct(2,"V6D")		
		oStruT5I:RemoveField("T5I_COMPAC")
		oStruT5I:RemoveField("T5I_DTEFAC")
		oStruT05:RemoveField("T05_QTDRUB")
		oStruT05:RemoveField("T05_VLRUNI")
		oStruT5S:RemoveField("T5S_QTDRUB")
		oStruT5S:RemoveField("T5S_VLRUNI")
		oStruT88:RemoveField("T88_IDCODC")
		oStruV6D:RemoveField("V6D_ID")
		oStruV6D:RemoveField("V6D_VERSAO")
	Else
		oStruT05:RemoveField("T05_SQTDRB")
		oStruT05:RemoveField("T05_APURIR")
		oStruT5S:RemoveField("T5S_SQTDRB")
		oStruT5S:RemoveField("T5S_APURIR")

	EndIf

	If !lSimplBeta .And. TafColumnPos("T06_INDRRA")		
		oStruT06:RemoveField( "T06_INDRRA" )
		oStruT06:RemoveField( "T06_TPPRRA" )
		oStruT06:RemoveField( "T06_NRPRRA" )
		oStruT06:RemoveField( "T06_DESCRA" )
		oStruT06:RemoveField( "T06_QTMRRA" )
		oStruT06:RemoveField( "T06_VLRCUS" )
		oStruT06:RemoveField( "T06_VLRADV" )
	EndIf

	oView:SetModel(oModel)
	oView:SetContinuousForm(.T.)

	/*-----------------------------------------------------------------------------------
							Estrutura da View
	-------------------------------------------------------------------------------------*/
	If !lLaySimplif
		oStruT16:SetProperty( "T16_SEQUEN"	, MVC_VIEW_ORDEM, "05" )
		oStruT16:SetProperty( "T16_CPFDEP"	, MVC_VIEW_ORDEM, "06" )
		oStruT16:SetProperty( "T16_DTNDEP"	, MVC_VIEW_ORDEM, "07" )
		oStruT16:SetProperty( "T16_NOMDEP"	, MVC_VIEW_ORDEM, "08" )
		oStruT16:SetProperty( "T16_VPGDEP"	, MVC_VIEW_ORDEM, "10" )
		oStruT16:SetProperty( "T16_TPDEP"	, MVC_VIEW_ORDEM, "19" )
		oStruT16:SetProperty( "T16_DTPDE"	, MVC_VIEW_ORDEM, "20" )	
	Else
		oStruT05:SetProperty( "T05_SQTDRB"	, MVC_VIEW_ORDEM, "06" )
		oStruT5S:SetProperty( "T5S_SQTDRB"	, MVC_VIEW_ORDEM, "12" )
	EndIf

	//----------------------------Desligamento
	//Informações de Identificação do Trabalhador e do Vínculo
	cCmpFil  := "CMD_ID|CMD_VERSAO|CMD_FUNC|CMD_DFUNC|"

	//Informações Relativas ao Desligamento do Vínculo
	If !lLaySimplif
		cCmpFild := "CMD_MOTDES|CMD_DMOTDE|CMD_DTDESL|CMD_INDPAG|CMD_TERAPI|CMD_PENALI|CMD_PERALI|CMD_VLPALI|CMD_NRATES|CMD_NRPROC|CMD_INDCUM|CMD_QTDDIA|CMD_PROCCS|CMD_DPROCC|"
		cCmpFils := "CMD_TPINSC|CMD_CNPJSU|" //Sucessão do Vínculo Trabalhista
	Else
		cCmpFild := "CMD_MOTDES|CMD_DMOTDE|CMD_DTDESL|CMD_DTAVPR|CMD_INDPAG|CMD_TERAPI|CMD_PENALI|CMD_PERALI|CMD_VLPALI|CMD_NRPROC|"
		cCmpFils := "CMD_TPINSC|CMD_NRINSC|" //Sucessão do Vínculo Trabalhista
	EndIf

	If lSimplBeta .and. TafColumnPos("CMD_INDREM")
		cCmpFilq := "CMD_INDREM|CMD_DTFREM|"
	Else
		//Informações sobre a 'Quarentena' Remunerada de Trabalhador Desligado
		cCmpFilq := "CMD_DTQUA|"
	EndIf

	//Informações sobre a Transferência de Titularidade
	cCmpFilt := "CMD_CPFSUB|CMD_DTNSTI|"

	//Informações sobre a mudança de CPF.
	cCmpFilh := "CMD_NEWCPF|"

	If lLaySimplif
		cCmpFilg := "CMD_TPGUIA|"
		cCmpFil := cCmpFil + cCmpFild + cCmpFils + cCmpFilq + cCmpFilt + cCmpFilh + cCmpFilg
	Else
		cCmpFil := cCmpFil + cCmpFild + cCmpFils + cCmpFilq + cCmpFilt + cCmpFilh
	EndIf

	oStruCMD  := FwFormStruct(2,"CMD",{|x| AllTrim(x) + "|" $ cCmpFil } ) 	//Campos do folder Desligamento
	//------------------------------

	//----------------------------Verbas Rescisão Contratual
	//Informações Vínculos
	cCmpFilv := "CMD_INDMV|"
	oStruCMDv := FwFormStruct(2,"CMD",{|x| AllTrim(x) + "|" $ cCmpFilv } )  // Campos do folder Informação de Vínculos
	//----------------------------

	//----------------------------Protocolo
	cCmpFilp :=  "CMD_PROTUL|"	
	oStruCMDp := FWFormStruct(2,"CMD",{|x| AllTrim(x) + "|" $ cCmpFilp  } ) //Campo Protocolo - eSocial

	If TafColumnPos("CMD_DTRANS")
		cCmpFilp := "CMD_DINSIS|CMD_DTRANS|CMD_HTRANS|CMD_DTRECP|CMD_HRRECP|"
		oStruCMDq := FWFormStruct(2,"CMD",{|x| AllTrim(x) + "|" $ cCmpFilp  } )
	EndIf

	//----------------------------

	If lLaySimplif
		oStruCMD:RemoveField("CMD_NRATES")
		oStruCMD:RemoveField("CMD_INDCUM")
		oStruCMD:RemoveField("CMD_QTDDIA")
		oStruCMD:RemoveField("CMD_CNPJSU")

		oStruCMD:SetProperty( "CMD_DTAVPR"	, MVC_VIEW_ORDEM, "09" )
	Else
		oStruCMD:RemoveField("CMD_DTAVPR")
		oStruCMD:RemoveField("CMD_NRINSC")
		oStruCMD:RemoveField("CMD_INDGUI")
	EndIf

	/*-----------------------------------------------------------------------------------
							Grupo de campos do Trabalhador
	-------------------------------------------------------------------------------------*/
	oStruCMD:AddGroup("GRP_DESLIG_01", STR0023, "", 1 ) //"Informacoes Trabalhador"
	oStruCMD:AddGroup("GRP_DESLIG_02", STR0007, "", 1 ) //"Informacoes Desligamento"

	If lSimplBeta .and. TafColumnPos("CMD_INDREM")
		oStruCMD:AddGroup("GRP_DESLIG_03", STR0056, "", 1 ) //Informações sobre a quarentena remunerada ou outra situação de desligamento com data anterior
	Else
		oStruCMD:AddGroup("GRP_DESLIG_03", STR0020, "", 1 ) //"Informações de Quarentena"
	EndIf

	oStruCMD:AddGroup("GRP_DESLIG_04", STR0034, "", 1 ) //"Sucessão do Vínculo Trabalhista"
	oStruCMD:AddGroup("GRP_DESLIG_05", STR0043, "", 1 ) //"Transferência de Titularidade"
	oStruCMD:AddGroup("GRP_DESLIG_06", STR0051, "", 1 ) //"Mudança de CPF"

	If lLaySimplif
		oStruCMD:AddGroup("GRP_DESLIG_07", STR0055, "", 1 ) //"Indicativo tipo de Guia"
	EndIf

	aCmpGrp := StrToKArr(cCmpFil,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCMD:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_DESLIG_01")
	Next nI

	aCmpGrp := StrToKArr(cCmpFild,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCMD:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_DESLIG_02")
	Next nI

	aCmpGrp := StrToKArr(cCmpFilq,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCMD:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_DESLIG_03")
	Next nI

	aCmpGrp := StrToKArr(cCmpFils,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCMD:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_DESLIG_04")
	Next nI

	aCmpGrp := StrToKArr( cCmpFilt, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruCMD:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_DESLIG_05" )
	Next nI

	aCmpGrp := StrToKArr( cCmpFilh, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruCMD:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_DESLIG_06" )
	Next nI

	If lLaySimplif
		aCmpGrp := StrToKArr( cCmpFilg, "|" )
		For nI := 1 to Len( aCmpGrp )
			oStruCMD:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_DESLIG_07" )
		Next nI		
	EndIf

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruCMDp,"CMD")
	EndIf

	oStruCMD:SetProperty( "CMD_TPINSC"	, MVC_VIEW_ORDEM, "13" )

	//##########################Fields##########################
	oView:AddField( 'VIEW_CMD' , oStruCMD,  'MODEL_CMD' )
	oView:AddField( 'VIEW_CMDp', oStruCMDp, 'MODEL_CMD' )

	If TafColumnPos("CMD_PROTUL")
		oView:EnableTitleView( 'VIEW_CMDp', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"
	EndIf
	If TafColumnPos("CMD_DTRANS")
		oView:AddField( 'VIEW_CMDq', oStruCMDq, 'MODEL_CMD' )
		oView:EnableTitleView( 'VIEW_CMDq', TafNmFolder("recibo",2) ) 
	EndIf

	oView:AddField('VIEW_CMDv', oStruCMDv, 'MODEL_CMD' )

	//##########################Grids##########################
	oView:AddGrid( 'VIEW_T06' , oStruT06, 'MODEL_T06' )

	oView:AddGrid( 'VIEW_T3G' , oStruT3G, 'MODEL_T3G' )
	
	If lSimplBeta .And. TafColumnPos("T06_INDRRA")
		oView:AddGrid( 'VIEW_V9N' , oStruV9N, 'MODEL_V9N' ) // RRA
		oView:EnableTitleView("VIEW_V9N", STR0057) //"RRA
	EndIf

	oView:AddGrid( 'VIEW_T05' , oStruT05, 'MODEL_T05' )

	If TafColumnPos("T05_SEQUEN")
		oView:AddIncrementField( 'VIEW_T05', 'T05_SEQUEN' )
	EndIf

	If !lLaySimplif
		oView:AddGrid( 'VIEW_T15' , oStruT15, 'MODEL_T15' )
		oView:EnableTitleView("VIEW_T15", STR0040) //"Detalhamento das Operadoras"

		oView:AddGrid( 'VIEW_T16' , oStruT16, 'MODEL_T16' )
		oView:AddIncrementField( 'VIEW_T16', 'T16_SEQUEN' )
		oView:EnableTitleView("VIEW_T16", STR0033) //'Dependente do plano privado de saúde'
	EndIf

	oView:AddGrid( 'VIEW_T5I' , oStruT5I, 'MODEL_T5I' )
	oView:EnableTitleView("VIEW_T5I", STR0041) //"Identificação ADC"

	oView:AddGrid( 'VIEW_T5J' , oStruT5J, 'MODEL_T5J' )
	oView:EnableTitleView("VIEW_T5J", STR0042) //"Identificação do Período"

	oView:AddGrid( 'VIEW_T5Q' , oStruT5Q, 'MODEL_T5Q' )
	oView:EnableTitleView("VIEW_T5Q", STR0026) //"Estabelecimento/Lotação"

	oView:AddGrid( 'VIEW_T5S' , oStruT5S, 'MODEL_T5S' )
	oView:EnableTitleView("VIEW_T5S", STR0027) //Detalhamento Verbas Rescisórias

	If !lLaySimplif
		oView:AddGrid( "VIEW_T88" , oStruT88, "MODEL_T88" )
	EndIf

	oView:AddGrid( 'VIEW_C9J' , oStruC9J, 'MODEL_C9J' )
	oView:EnableTitleView("VIEW_C9J", STR0031) //"Remuneração Outras Empresas"

	oView:AddGrid( 'VIEW_T3H' , oStruT3H, 'MODEL_T3H' )

	If lLaySimplif
		oView:AddGrid( 'VIEW_V6D' , oStruV6D, 'MODEL_V6D' )
		oView:EnableTitleView("VIEW_V6D", STR0052 ) //"Informações relativas ao trabalho intermitente"
	EndIf

	oView:AddGrid( 'VIEW_V1M' , oStruV1M, 'MODEL_V1M' )
	oView:AddIncrementField( "VIEW_V1M", "V1M_CODOBS" )
	oView:EnableTitleView("VIEW_V1M", STR0049 ) //"Observações sobre o Desligamento"

	oView:AddGrid( 'VIEW_V1N' , oStruV1N, 'MODEL_V1N' )
	oView:EnableTitleView("VIEW_V1N", STR0050 ) //"Informações sobre operação de crédito consignado com garantia de FGTS"

	/*-----------------------------------------------------------------------------------
							Estrutura do Folder
	-------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox( 'PAINEL_PRINCIPAL', 100 )
	oView:CreateFolder( 'FOLDER_PRINCIPAL', 'PAINEL_PRINCIPAL' )

	//////////////////////////////Trabalhador/Desligamento
	oView:AddSheet("FOLDER_PRINCIPAL","ABA01","Informações")

	If !lLaySimplif
		oView:CreateHorizontalBox( 'CMD',56,,, 'FOLDER_PRINCIPAL', 'ABA01' )
		oView:CreateHorizontalBox( 'V1M',22,,, 'FOLDER_PRINCIPAL', 'ABA01' )
		oView:CreateHorizontalBox( 'V1N',22,,, 'FOLDER_PRINCIPAL', 'ABA01' )
	Else
		oView:CreateHorizontalBox( 'CMD',52,,, 'FOLDER_PRINCIPAL', 'ABA01' )
		oView:CreateHorizontalBox( 'V6D',16,,, 'FOLDER_PRINCIPAL', 'ABA01' )
		oView:CreateHorizontalBox( 'V1M',16,,, 'FOLDER_PRINCIPAL', 'ABA01' )
		oView:CreateHorizontalBox( 'V1N',16,,, 'FOLDER_PRINCIPAL', 'ABA01' )
	EndIf

	/////////////////////////Verbas Rescisão Contratual
	oView:AddSheet("FOLDER_PRINCIPAL","ABA02",STR0009) //"Verbas Rescisórias"

	oView:CreateHorizontalBox("GRIDS_VERBRESC",100,,,"FOLDER_PRINCIPAL","ABA02")
	oView:CreateFolder("FOLDER_GRIDS","GRIDS_VERBRESC")

	/////////////////Demonstrativos de Valores
	oView:AddSheet("FOLDER_GRIDS","ABA01",STR0035) //Demonstrativos de Valores
	oView:CreateHorizontalBox( 'T06', 15,,, 'FOLDER_GRIDS', 'ABA01' )

	oView:CreateHorizontalBox( 'PAINEL_PERIODOS' , 85,,, 'FOLDER_GRIDS', 'ABA01' )
	oView:CreateFolder("FOLDER_PERIODOS","PAINEL_PERIODOS")

	////////////RRA	
	If lSimplBeta .And. TafColumnPos("T06_INDRRA")
		oView:AddSheet( 'FOLDER_PERIODOS', "ABA003" , STR0058 ) 		
		oView:CreateHorizontalBox( 'V9N' ,   050,,, 'FOLDER_PERIODOS', 'ABA003' )
	EndIf

	////////////Período Apuração
	oView:AddSheet("FOLDER_PERIODOS","ABA01",STR0036) //"Período Apuração"

	////////Estabelecimento/Lotação
	oView:CreateHorizontalBox( 'PAINEL_ESTLOT', 100,,, 'FOLDER_PERIODOS', 'ABA01' )
	oView:CreateFolder("FOLDER_ESTLOT","PAINEL_ESTLOT")
	oView:AddSheet("FOLDER_ESTLOT","ABA01",STR0026) //"Estabelecimento/Lotação"
	oView:CreateHorizontalBox( 'T3G', 35,,, 'FOLDER_ESTLOT', 'ABA01' )

	oView:CreateHorizontalBox( 'GRIDS_ESTLOT', 65,,, 'FOLDER_ESTLOT', 'ABA01' )
	oView:CreateFolder("FOLDER_GRIDS_ESTLOT","GRIDS_ESTLOT")

	//////Detalhamento Verbas Rescisórias
	oView:AddSheet("FOLDER_GRIDS_ESTLOT","ABA01",STR0027) //Detalhamento Verbas Rescisórias
	oView:CreateHorizontalBox( 'T05', 100,,, 'FOLDER_GRIDS_ESTLOT', 'ABA01' )

	If !lLaySimplif
		//////Informações de Plano de Saude
		///Detalhamento das Operadoras
		oView:AddSheet("FOLDER_GRIDS_ESTLOT","ABA02",STR0032) //Plano de Saude
		oView:CreateHorizontalBox( 'T15', 50,,, 'FOLDER_GRIDS_ESTLOT', 'ABA02' )

		//Informações do Dependente
		oView:CreateHorizontalBox( 'T16', 50,,, 'FOLDER_GRIDS_ESTLOT', 'ABA02' )
	EndIf

	////////////"Períodos Anteriores"
	oView:AddSheet("FOLDER_PERIODOS","ABA02",STR0037) //"Periodo Apuração"

	////////Identificação ADC
	oView:CreateHorizontalBox( 'PAINEL_IDENTADC', 100,,, 'FOLDER_PERIODOS', 'ABA02' )
	oView:CreateFolder("FOLDER_IDENTADC","PAINEL_IDENTADC")
	oView:AddSheet("FOLDER_IDENTADC", "ABA01", STR0041) //"Identificação ADC"

	oView:CreateHorizontalBox( 'T5I', 25,,, 'FOLDER_IDENTADC', 'ABA01' )

	//////Identificação do Período
	oView:CreateHorizontalBox( 'T5J', 25,,, 'FOLDER_IDENTADC', 'ABA01' )

	////Estabelecimento/Lotação
	oView:CreateHorizontalBox( 'T5Q', 25,,, 'FOLDER_IDENTADC', 'ABA01' )

	//////Detalhamento Verbas Rescisórias
	oView:CreateHorizontalBox( 'T5S', 25,,, 'FOLDER_IDENTADC', 'ABA01' )

	If !lLaySimplif
		////////////Informações da convocação para trabalho intermitente
		oView:AddSheet( "FOLDER_PERIODOS", "ABA03", STR0045 ) //"Informações da convocação para trabalho intermitente"
		oView:CreateHorizontalBox( "T88", 100,,, "FOLDER_PERIODOS", "ABA03" )
	EndIf

	/////////////////Informação Multiploas Vinculos
	oView:AddSheet("FOLDER_GRIDS","ABA02",STR0030) //"Informação Multiploas Vinculos"
	oView:CreateHorizontalBox( 'CMDv', 12,,, 'FOLDER_GRIDS', 'ABA02' )
	oView:CreateHorizontalBox( 'C9J' , 88,,, 'FOLDER_GRIDS', 'ABA02' )

	/////////////////Informações Processos Judiciais do Trabalhador
	oView:AddSheet("FOLDER_GRIDS","ABA03",STR0025) //"Informações Processos Judiciais do Trabalhador"
	oView:CreateHorizontalBox( 'T3H' , 100,,, 'FOLDER_GRIDS', 'ABA03' )

	//##########################Protocolo##########################
	If FindFunction("TafNmFolder")
		oView:AddSheet("FOLDER_PRINCIPAL","ABA03",TafNmFolder("recibo"))
	Else
		oView:AddSheet("FOLDER_PRINCIPAL","ABA03",STR0022)
	EndIf

	If TafColumnPos("CMD_DTRANS")
		oView:CreateHorizontalBox("CMDp",20,,,"FOLDER_PRINCIPAL","ABA03")
		oView:CreateHorizontalBox("CMDq",80,,,"FOLDER_PRINCIPAL","ABA03")
	Else
		oView:CreateHorizontalBox("CMDp",100,,,"FOLDER_PRINCIPAL","ABA03")
	EndIf

	oView:SetOwnerView("VIEW_CMD" 	,"CMD"  )
	oView:SetOwnerView("VIEW_CMDp"	,"CMDp" )
	If TafColumnPos("CMD_DTRANS")
		oView:SetOwnerView("VIEW_CMDq"	,"CMDq" )
	EndIf
	oView:SetOwnerView("VIEW_CMDv"	,"CMDv" )
	oView:SetOwnerView("VIEW_T06" 	,"T06"  )
	oView:SetOwnerView("VIEW_T3G" 	,"T3G"  )
	If lSimplBeta .And. TafColumnPos("T06_INDRRA")
		oView:SetOwnerView( "VIEW_V9N"	, "V9N")
	EndIf
	oView:SetOwnerView("VIEW_T05" 	,"T05"  )

	If !lLaySimplif
		oView:SetOwnerView("VIEW_T15" 	,"T15"	 )
		oView:SetOwnerView("VIEW_T16" 	,"T16"	 )
		oView:SetOwnerView("VIEW_T88"	,"T88"  )
	EndIf

	oView:SetOwnerView("VIEW_T5I" 	,"T5I"  )
	oView:SetOwnerView("VIEW_T5J" 	,"T5J"  )
	oView:SetOwnerView("VIEW_T5Q"	,"T5Q"  )
	oView:SetOwnerView("VIEW_T5S"	,"T5S"  )
	oView:SetOwnerView("VIEW_C9J" 	,"C9J"  )
	oView:SetOwnerView("VIEW_T3H" 	,"T3H"  )

	If lLaySimplif
		oView:SetOwnerView("VIEW_V6D" 	,"V6D"  )
	EndIf

	oView:SetOwnerView("VIEW_V1M" 	,"V1M"  )
	oView:SetOwnerView("VIEW_V1N" 	,"V1N"  )

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If !lMenuDif

		xFunRmFStr(@oStruCMD,"CMD")

		oStruT3H:RemoveField('T3H_IDSUSP')
		oStruC9J:RemoveField('C9J_NOMEVE')
		oStruT3H:RemoveField('T3H_NOMEVE')
		oStruT15:RemoveField('T15_NOMEVE')
		oStruT16:RemoveField('T16_NOMEVE')
		oStruV1M:RemoveField('V1M_NOMEVE')
		oStruV1N:RemoveField('V1N_NOMEVE')

		If !lLaySimplif
			oStruT88:RemoveField('T88_IDCODC')
		EndIf

	EndIf

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param oModel -> Modelo de dados

@Return .T.

@Author Felipe C. Seolin
@Since 29/10/2013
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local oModelCMD  	as object
	Local oModelT06  	as object
	Local oModelT3G  	as object
	Local oModelT05  	as object
	Local oModelT15  	as object
	Local oModelT16  	as object
	Local oModelT5I  	as object
	Local oModelT5J  	as object
	Local oModelT5Q  	as object
	Local oModelT5S  	as object
	Local oModelT88  	as object
	Local oModelC9J  	as object
	Local oModelT3H  	as object
	Local oModelV1M  	as object
	Local oModelV1N  	as object
	Local oModelV9N		as object
	Local cVerAnt    	as character
	Local cProtocolo 	as character
	Local cVersao    	as character
	Local cChvRegAnt 	as character
	Local cEvento    	as character
	Local cLogOpeAnt 	as character
	Local nOperation 	as numeric
	Local nI         	as numeric
	Local nJ         	as numeric
	Local nK         	as numeric
	Local nL         	as numeric
	Local nlI        	as numeric
	Local nlY        	as numeric
	Local nT06       	as numeric
	Local nV9N			as numeric
	Local nT3G      	as numeric
	Local nT3GAdd   	as numeric
	Local nT05      	as numeric
	Local nT05Add   	as numeric
	Local nT15      	as numeric
	Local nT15Add   	as numeric
	Local nT16      	as numeric
	Local nT16Add   	as numeric
	Local nT5I      	as numeric
	Local nT5IAdd   	as numeric
	Local nT5J      	as numeric
	Local nT5JAdd   	as numeric
	Local nT5Q      	as numeric
	Local nT5QAdd   	as numeric
	Local nT5S      	as numeric
	Local nT5SAdd   	as numeric
	Local nT88      	as numeric
	Local nT88Add   	as numeric
	Local nC9J      	as numeric
	Local nT3H      	as numeric
	Local nV1M      	as numeric
	Local nV1N      	as numeric
	Local nV9NAdd		as numeric
	Local aGrava    	as array
	Local aGravaT06 	as array
	Local aGravaT3G 	as array
	Local aGravaT05 	as array
	Local aGravaT15 	as array
	Local aGravaT16 	as array
	Local aGravaT5I 	as array
	Local aGravaT5J 	as array
	Local aGravaT5Q 	as array
	Local aGravaT5S 	as array
	Local aGravaT88 	as array
	Local aGravaC9J 	as array
	Local aGravaT3H 	as array
	Local aGravaV1M 	as array
	Local aGravaV1N 	as array
	Local aGravaV9N		as array
	Local lRetorno  	as logical

	//Relatório de Conferência de Valores
	Local oInfoRPT		as object
	Local cPeriodo		as character
	Local cCPF    		as character
	Local cNome   		as character
	Local lInfoRPT		as logical

	oModelCMD 	:= Nil
	oModelT06 	:= Nil
	oModelT3G 	:= Nil
	oModelT05 	:= Nil
	oModelT15 	:= Nil
	oModelT16 	:= Nil
	oModelT5I 	:= Nil
	oModelT5J 	:= Nil
	oModelT5Q 	:= Nil
	oModelT5S 	:= Nil
	oModelT88 	:= Nil
	oModelC9J 	:= Nil
	oModelT3H 	:= Nil
	oModelV1M 	:= Nil
	oModelV1N 	:= Nil
	oModelV9N	:= Nil
	cVerAnt   	:= ""
	cProtocolo	:= ""
	cVersao   	:= ""
	cChvRegAnt	:= ""
	cEvento   	:= ""
	cLogOpeAnt	:= ""
	nOperation	:= oModel:GetOperation()
	nI        	:= 0
	nJ        	:= 0
	nK        	:= 0
	nL        	:= 0
	nlI       	:= 0
	nlY       	:= 0
	nT06      	:= 0
	nV9N		:= 0
	nT3G       	:= 0
	nT3GAdd    	:= 0
	nT05       	:= 0
	nT05Add    	:= 0
	nT15       	:= 0
	nT15Add    	:= 0
	nT16       	:= 0
	nT16Add    	:= 0
	nT5I       	:= 0
	nT5IAdd    	:= 0
	nT5J       	:= 0
	nT5JAdd    	:= 0
	nT5Q       	:= 0
	nT5QAdd    	:= 0
	nT5S       	:= 0
	nT5SAdd    	:= 0
	nT88       	:= 0
	nT88Add    	:= 0
	nC9J       	:= 0
	nT3H       	:= 0
	nV1M       	:= 0
	nV1N       	:= 0
	nV9NAdd		:= 0
	aGrava     	:= {}
	aGravaT06  	:= {}
	aGravaT3G  	:= {}
	aGravaT05  	:= {}
	aGravaT15  	:= {}
	aGravaT16  	:= {}
	aGravaT5I  	:= {}
	aGravaT5J  	:= {}
	aGravaT5Q  	:= {}
	aGravaT5S  	:= {}
	aGravaT88  	:= {}
	aGravaC9J  	:= {}
	aGravaT3H  	:= {}
	aGravaV1M  	:= {}
	aGravaV1N  	:= {}
	aGravaV9N	:= {}
	lRetorno   	:= .T.
	oInfoRPT   	:= Nil
	cPeriodo   	:= ""
	cCPF       	:= ""
	cNome      	:= ""
	lInfoRPT   	:= .F.

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		If __lGrvRPT == Nil
			TAF266Rpt() //Inicializa a variável static __lGrvRPT
		EndIf

		lInfoRPT := __lGrvRPT

		//Realiza a exclusão do registro da tabela do relatório
		If lInfoRPT
			cPeriodo	:=	SubStr( DToS( oModel:GetValue("MODEL_CMD","CMD_DTDESL") ), 1, 6 )
			cCPF		:=	GetADVFVal( "C9V", "C9V_CPF", xFilial( "C9V" ) + oModel:GetValue("MODEL_CMD","CMD_FUNC") + "1", 2, "", .T. )
			cNome		:=	GetADVFVal( "C9V", "C9V_NOME", xFilial( "C9V" ) + oModel:GetValue("MODEL_CMD","CMD_FUNC") + "1", 2, "", .T. )

			If oReport == Nil
				oReport := TAFSocialReport():New()
			EndIf

			oInfoRPT := oReport:oVOReport
			oInfoRPT:SetIndApu( "1" )
			oInfoRPT:SetPeriodo( cPeriodo )
			oInfoRPT:SetCPF( AllTrim( cCPF ) )
			oInfoRPT:SetNome( cNome )

		EndIf

		If nOperation == MODEL_OPERATION_INSERT

			TafAjustID( "CMD", oModel)

			oModel:LoadValue( "MODEL_CMD", "CMD_VERSAO", xFunGetVer() )

			If TafColumnPos("CMD_LAYOUT")
				oModel:LoadValue( "MODEL_CMD", "CMD_LAYOUT", SuperGetMV("MV_TAFVLES", .F., "S_01_00_00") )
			EndIf

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_CMD', 'CMD_LOGOPE' , '2', '' )
			Endif

			oModelT06 := oModel:GetModel( "MODEL_T06" )

			For nI := 1 to oModelT06:Length()
				oModelT06:GoLine( nI )

				If !oModelT06:IsEmpty() .and. !oModelT06:IsDeleted()
					oModelT3G := oModel:GetModel( "MODEL_T3G" )

					For nJ := 1 to oModelT3G:Length()
						oModelT3G:GoLine( nJ )

						If !oModelT3G:IsEmpty() .and. !oModelT3G:IsDeleted()
							If !lLaySimplif
								oModelT15 := oModel:GetModel( "MODEL_T15" )

								For nK := 1 to oModelT15:Length()
									oModelT15:GoLine( nK )

									If !oModelT15:IsEmpty() .and. !oModelT15:IsDeleted()
										oModelT15:LoadValue( "T15_NOMEVE", "S2299" )
									EndIf

									oModelT16 := oModel:GetModel( "MODEL_T16" )

									For nL := 1 to oModelT16:Length()
										oModelT16:GoLine( nL )

										If !oModelT16:IsEmpty() .and. !oModelT16:IsDeleted()
											oModelT16:LoadValue( "T16_NOMEVE", "S2299" )
										EndIf
									Next nL
								Next nK
							EndIf
						EndIf
					Next nJ
				EndIf
			Next nI

			oModelC9J := oModel:GetModel( "MODEL_C9J" )
			For nI := 1 to oModelC9J:Length()
				oModelC9J:GoLine( nI )
				If !oModelC9J:IsEmpty() .and. !oModelC9J:IsDeleted()
					oModelC9J:LoadValue( "C9J_NOMEVE", "S2299" )
				EndIf
			Next nI

			oModelT3H := oModel:GetModel( "MODEL_T3H" )
			For nI := 1 to oModelT3H:Length()
				oModelT3H:GoLine( nI )
				If !oModelT3H:IsEmpty() .and. !oModelT3H:IsDeleted()
					oModelT3H:LoadValue( "T3H_NOMEVE", "S2299" )
				EndIf
			Next nI

			oModelV1M := oModel:GetModel( "MODEL_V1M" )
			For nI := 1 to oModelV1M:Length()
				oModelV1M:GoLine( nI )
				If !oModelV1M:IsEmpty() .and. !oModelV1M:IsDeleted()
					oModelV1M:LoadValue( "V1M_NOMEVE", "S2299" )
				EndIf
			Next nI

			oModelV1N := oModel:GetModel( "MODEL_V1N" )
			For nI := 1 to oModelV1N:Length()
				oModelV1N:GoLine( nI )
				If !oModelV1N:IsEmpty() .and. !oModelV1N:IsDeleted()
					oModelV1N:LoadValue( "V1N_NOMEVE", "S2299" )
				EndIf
			Next nI

			If FWFormCommit( oModel )
				If lInfoRPT
					aAnalitico := LoadReportData(oModel, lInfoRPT)
					oInfoRPT:SetAnalitico(aAnalitico)
					oReport:UpSert( "S-2299", "2", xFilial( "CMD" ), oInfoRPT )
				EndIf
			EndIf

		ElseIf nOperation == MODEL_OPERATION_UPDATE

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CMD->( DbSetOrder( 3 ) )
			If lGoExtemp .OR. CMD->( MsSeek( xFilial( 'CMD' ) + M->CMD_ID + '1' ) )

				If Empty( CMD->CMD_STATUS )

					If TafColumnPos( "CMD_LOGOPE" )
						cLogOpeAnt :=  CMD->CMD_LOGOPE
					Endif

					If TafColumnPos("CMD_LAYOUT")
						oModel:LoadValue( "MODEL_CMD", "CMD_LAYOUT", SuperGetMV("MV_TAFVLES", .F., "S_01_00_00") )
					EndIf

					oModelT06 := oModel:GetModel( "MODEL_T06" )

					For nI := 1 to oModelT06:Length()
						oModelT06:GoLine( nI )

						If !oModelT06:IsEmpty() .and. !oModelT06:IsDeleted()
							oModelT3G := oModel:GetModel( "MODEL_T3G" )

							For nJ := 1 to oModelT3G:Length()
								oModelT3G:GoLine( nJ )

								If !oModelT3G:IsEmpty() .and. !oModelT3G:IsDeleted()
									If !lLaySimplif
										oModelT15 := oModel:GetModel( "MODEL_T15" )

										For nK := 1 to oModelT15:Length()
											oModelT15:GoLine( nK )

											If !oModelT15:IsEmpty() .and. !oModelT15:IsDeleted()
												oModelT15:LoadValue( "T15_NOMEVE", "S2299" )
											EndIf

											oModelT16 := oModel:GetModel( "MODEL_T16" )

											For nL := 1 to oModelT16:Length()
												oModelT16:GoLine( nL )

												If !oModelT16:IsEmpty() .and. !oModelT16:IsDeleted()
													oModelT16:LoadValue( "T16_NOMEVE", "S2299" )
												EndIf
											Next nL
										Next nK
									EndIf
								EndIf
							Next nJ
						EndIf
					Next nI

					oModelC9J := oModel:GetModel( "MODEL_C9J" )
					For nI := 1 to oModelC9J:Length()
						oModelC9J:GoLine( nI )
						If !oModelC9J:IsEmpty() .and. !oModelC9J:IsDeleted()
							oModelC9J:LoadValue( "C9J_NOMEVE", "S2299" )
						EndIf
					Next nI

					oModelT3H := oModel:GetModel( "MODEL_T3H" )
					For nI := 1 to oModelT3H:Length()
						oModelT3H:GoLine( nI )
						If !oModelT3H:IsEmpty() .and. !oModelT3H:IsDeleted()
							oModelT3H:LoadValue( "T3H_NOMEVE", "S2299" )
						EndIf
					Next nI

					oModelV1M := oModel:GetModel( "MODEL_V1M" )
					For nI := 1 to oModelV1M:Length()
						oModelV1M:GoLine( nI )
						If !oModelV1M:IsEmpty() .and. !oModelV1M:IsDeleted()
							oModelV1M:LoadValue( "V1M_NOMEVE", "S2299" )
						EndIf
					Next nI

					oModelV1N := oModel:GetModel( "MODEL_V1N" )
					For nI := 1 to oModelV1N:Length()
						oModelV1N:GoLine( nI )
						If !oModelV1N:IsEmpty() .and. !oModelV1N:IsDeleted()
							oModelV1N:LoadValue( "V1N_NOMEVE", "S2299" )
						EndIf
					Next nI

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se o registro ja foi transmitido³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ElseIf CMD->CMD_STATUS == "4"

					oModelCMD  := oModel:GetModel( "MODEL_CMD" )
					oModelT06  := oModel:GetModel( "MODEL_T06" )
					oModelT3G  := oModel:GetModel( "MODEL_T3G" )
					oModelT05  := oModel:GetModel( "MODEL_T05" )
					
					If lSimplBeta .And. TafColumnPos("T06_INDRRA")
						oModelV9N := oModel:GetModel("MODEL_V9N")
					EndIf

					If !lLaySimplif
						oModelT15  := oModel:GetModel( "MODEL_T15" )
						oModelT16  := oModel:GetModel( "MODEL_T16" )
						oModelT88  := oModel:GetModel( "MODEL_T88" )
					EndIf
					
					oModelT5I  := oModel:GetModel( "MODEL_T5I" )
					oModelT5J  := oModel:GetModel( "MODEL_T5J" )
					oModelT5Q  := oModel:GetModel( "MODEL_T5Q" )
					oModelT5S  := oModel:GetModel( "MODEL_T5S" )
					oModelC9J  := oModel:GetModel( "MODEL_C9J" )
					oModelT3H  := oModel:GetModel( "MODEL_T3H" )
					oModelV1M  := oModel:GetModel( "MODEL_V1M" )
					oModelV1N  := oModel:GetModel( "MODEL_V1N" )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao anterior do registro para gravacao do rastro³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVerAnt   	:= oModelCMD:GetValue( "CMD_VERSAO" )
					cProtocolo	:= oModelCMD:GetValue( "CMD_PROTUL" )
					cEvento		:= oModelCMD:GetValue( "CMD_EVENTO" )

					If TafColumnPos( "CMD_LOGOPE" )
						cLogOpeAnt := oModelCMD:GetValue( "CMD_LOGOPE" )
					EndIf

					If TafColumnPos("CMD_LAYOUT")
						oModel:LoadValue( "MODEL_CMD", "CMD_LAYOUT", SuperGetMV("MV_TAFVLES", .F., "S_01_00_00") )
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu gravo as informacoes que foram carregadas       ³
					//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
					//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
					//³nao devem ser consideradas neste momento                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nlI := 1 To 1
						For nlY := 1 To Len( oModelCMD:aDataModel[ nlI ] )
							Aadd( aGrava, { oModelCMD:aDataModel[ nlI, nlY, 1 ], oModelCMD:aDataModel[ nlI, nlY, 2 ] } )
						Next
					Next

					//T06
					If T06->(MsSeek(xFilial("T06") + CMD->(CMD_ID + CMD_VERSAO)))
						For nT06 := 1 To oModel:GetModel("MODEL_T06"):Length()
							oModel:GetModel("MODEL_T06"):GoLine(nT06)
							
							If !oModel:GetModel("MODEL_T06"):IsEmpty()
								If !oModel:GetModel("MODEL_T06"):IsDeleted()

									If lSimplBeta .And. TafColumnPos("T06_INDRRA")

										aAdd(aGravaT06 ,{oModelT06:GetValue("T06_IDEDMD"),;
														 oModelT06:GetValue('T06_INDRRA'),;
													 	 oModelT06:GetValue('T06_TPPRRA'),;
													 	 oModelT06:GetValue('T06_NRPRRA'),;
													 	 oModelT06:GetValue('T06_DESCRA'),;
													 	 oModelT06:GetValue('T06_QTMRRA'),;
													 	 oModelT06:GetValue('T06_VLRCUS'),;
														 oModelT06:GetValue('T06_VLRADV')})

										For nV9N := 1 To oModel:GetModel("MODEL_V9N"):Length()

											oModel:GetModel("MODEL_V9N"):GoLine(nV9N)

											If !oModel:GetModel("MODEL_V9N"):IsEmpty()

												If !oModel:GetModel("MODEL_V9N"):IsDeleted()
													aAdd(aGravaV9N, {	oModelT06:GetValue("T06_IDEDMD"),;														
																		oModelV9N:GetValue("V9N_TPINSC"),;
																		oModelV9N:GetValue("V9N_NRINSC"),;
																		oModelV9N:GetValue("V9N_VLRADV")	})
												EndIf
											EndIf
										Next

									else
										aAdd(aGravaT06, {oModelT06:GetValue("T06_IDEDMD")})
									EndIf

									//T3G
									For nT3G := 1 to oModel:GetModel( "MODEL_T3G" ):Length()
										oModel:GetModel( "MODEL_T3G" ):GoLine(nT3G)
										If !oModel:GetModel( 'MODEL_T3G' ):IsEmpty()
											If !oModel:GetModel( "MODEL_T3G" ):IsDeleted()
												aAdd (aGravaT3G ,{oModelT06:GetValue('T06_IDEDMD'),;
													oModelT3G:GetValue('T3G_ESTABE'),;
													oModelT3G:GetValue('T3G_LOTTRB'),;
													oModelT3G:GetValue('T3G_GRAUEX'),;
													oModelT3G:GetValue('T3G_INDCSU')})

												//T05
												For nT05 := 1 to oModel:GetModel( "MODEL_T05" ):Length()
													oModel:GetModel( "MODEL_T05" ):GoLine(nT05)
													If !oModel:GetModel( 'MODEL_T05' ):IsEmpty()
														If !oModel:GetModel( "MODEL_T05" ):IsDeleted()
															If !lLaySimplif
																aAdd (aGravaT05 ,{oModelT06:GetValue('T06_IDEDMD'),;
																				oModelT3G:GetValue('T3G_ESTABE'),;
																				oModelT3G:GetValue('T3G_LOTTRB'),;
																				oModelT05:GetValue('T05_CODRUB'),;
																				oModelT05:GetValue('T05_QTDRUB'),;
																				oModelT05:GetValue('T05_FATRUB'),;
																				oModelT05:GetValue('T05_VLRUNI'),;
																				oModelT05:GetValue('T05_VLRRUB')})
															Else
																aAdd (aGravaT05 ,{oModelT06:GetValue('T06_IDEDMD'),;
																				oModelT3G:GetValue('T3G_ESTABE'),;
																				oModelT3G:GetValue('T3G_LOTTRB'),;
																				oModelT05:GetValue('T05_CODRUB'),;
																				oModelT05:GetValue('T05_SQTDRB'),;
																				oModelT05:GetValue('T05_FATRUB'),;
																				oModelT05:GetValue('T05_VLRRUB'),;
																				oModelT05:GetValue('T05_APURIR')})
															EndIf
														EndIf
													EndIf
												Next nT05

												If !lLaySimplif
													//T15
													For nT15 := 1 to oModel:GetModel( "MODEL_T15" ):Length()
														oModel:GetModel( "MODEL_T15" ):GoLine(nT15)
														If !oModel:GetModel( 'MODEL_T15' ):IsEmpty()
															If !oModel:GetModel( "MODEL_T15" ):IsDeleted()
																aAdd (aGravaT15 ,{oModelT06:GetValue('T06_IDEDMD'),;
																	oModelT3G:GetValue('T3G_ESTABE'),;
																	oModelT3G:GetValue('T3G_LOTTRB'),;
																	oModelT15:GetValue('T15_CNPJOP'),;
																	oModelT15:GetValue('T15_REGANS'),;
																	oModelT15:GetValue('T15_VLPGTI')})

																//T16
																For nT16 := 1 to oModel:GetModel( "MODEL_T16" ):Length()
																	oModel:GetModel( "MODEL_T16" ):GoLine(nT16)
																	If !oModel:GetModel( 'MODEL_T16' ):IsEmpty()
																		If !oModel:GetModel( "MODEL_T16" ):IsDeleted()
																			aAdd (aGravaT16 ,{oModelT06:GetValue('T06_IDEDMD'),;
																				oModelT3G:GetValue('T3G_ESTABE'),;
																				oModelT3G:GetValue('T3G_LOTTRB'),;
																				oModelT15:GetValue('T15_CNPJOP'),;
																				oModelT15:GetValue('T15_REGANS'),;
																				oModelT16:GetValue('T16_SEQUEN'),;
																				oModelT16:GetValue('T16_CPFDEP'),;
																				oModelT16:GetValue('T16_DTNDEP'),;
																				oModelT16:GetValue('T16_NOMDEP'),;
																				oModelT16:GetValue('T16_VPGDEP'),;
																				oModelT16:GetValue('T16_TPDEP')})
																		EndIf
																	EndIf
																Next nT16
															EndIf
														EndIf
													Next nT15
												EndIf
											EndIf
										EndIf
									Next nT3G

									//T5I
									For nT5I := 1 To oModel:GetModel( 'MODEL_T5I' ):Length()
										oModel:GetModel( 'MODEL_T5I' ):GoLine(nT5I)
										If !oModel:GetModel( 'MODEL_T5I' ):IsDeleted()
											If !lLaySimplif
												aAdd (aGravaT5I ,{oModelT06:GetValue('T06_IDEDMD')	,;
																oModelT5I:GetValue('T5I_DTACCO')	,;
																oModelT5I:GetValue('T5I_TPACCO') 	,;
																oModelT5I:GetValue('T5I_DTEFAC')  ,;
																oModelT5I:GetValue('T5I_DSC')		,;
																oModelT5I:GetValue('T5I_COMPAC')  })
											Else
												aAdd (aGravaT5I ,{oModelT06:GetValue('T06_IDEDMD')	,;
																oModelT5I:GetValue('T5I_DTACCO')	,;
																oModelT5I:GetValue('T5I_TPACCO') 	,;
																oModelT5I:GetValue('T5I_DSC')  })										
											EndIf

											//T5J
											For nT5J := 1 to oModel:GetModel( "MODEL_T5J" ):Length()
												oModel:GetModel( "MODEL_T5J" ):GoLine(nT5J)
												If !oModel:GetModel( 'MODEL_T5J' ):IsEmpty()
													If !oModel:GetModel( "MODEL_T5J" ):IsDeleted()
														aAdd (aGravaT5J ,{oModelT06:GetValue('T06_IDEDMD')	,;
															oModelT5I:GetValue('T5I_DTACCO')	,;
															oModelT5I:GetValue('T5I_TPACCO') 	,;
															oModelT5J:GetValue('T5J_PERREF')  })

														//T5Q
														For nT5Q := 1 to oModel:GetModel( "MODEL_T5Q" ):Length()
															oModel:GetModel( "MODEL_T5Q" ):GoLine(nT5Q)
															If !oModel:GetModel( 'MODEL_T5Q' ):IsEmpty()
																If !oModel:GetModel( 'MODEL_T5Q' ):IsDeleted()
																	aAdd (aGravaT5Q ,{oModelT06:GetValue('T06_IDEDMD')	,;
																		oModelT5I:GetValue('T5I_DTACCO')	,;
																		oModelT5I:GetValue('T5I_TPACCO') 	,;
																		oModelT5J:GetValue('T5J_PERREF')	,;
																		oModelT5Q:GetValue('T5Q_ESTABE')	,;
																		oModelT5Q:GetValue('T5Q_LOTTRB')	,;
																		oModelT5Q:GetValue('T5Q_GRAUEX')	,;
																		oModelT5Q:GetValue('T5Q_INDCSU')	})

																	//T5S
																	For nT5S := 1 to oModel:GetModel( "MODEL_T5S" ):Length()
																		oModel:GetModel( "MODEL_T5S" ):GoLine(nT5S)
																		If !oModel:GetModel( 'MODEL_T5S' ):IsEmpty()
																			If !oModel:GetModel( "MODEL_T5S" ):IsDeleted()
																				If !lLaySimplif
																					aAdd (aGravaT5S ,{oModelT06:GetValue('T06_IDEDMD')	,;
																									oModelT5I:GetValue('T5I_DTACCO')	,;
																									oModelT5I:GetValue('T5I_TPACCO') 	,;
																									oModelT5J:GetValue('T5J_PERREF')	,;
																									oModelT5Q:GetValue('T5Q_ESTABE')	,;
																									oModelT5Q:GetValue('T5Q_LOTTRB')	,;
																									oModelT5S:GetValue('T5S_CODRUB')  ,;
																									oModelT5S:GetValue('T5S_QTDRUB')	,;
																									oModelT5S:GetValue('T5S_FATRUB')	,;
																									oModelT5S:GetValue('T5S_VLRUNI')	,;
																									oModelT5S:GetValue('T5S_VLRRUB')	})
																				Else
																					aAdd (aGravaT5S ,{oModelT06:GetValue('T06_IDEDMD')	,;
																									oModelT5I:GetValue('T5I_DTACCO')	,;
																									oModelT5I:GetValue('T5I_TPACCO') 	,;
																									oModelT5J:GetValue('T5J_PERREF')	,;
																									oModelT5Q:GetValue('T5Q_ESTABE')	,;
																									oModelT5Q:GetValue('T5Q_LOTTRB')	,;
																									oModelT5S:GetValue('T5S_CODRUB')  ,;
																									oModelT5S:GetValue('T5S_SQTDRB')	,;
																									oModelT5S:GetValue('T5S_FATRUB')	,;
																									oModelT5S:GetValue('T5S_VLRRUB')	,;
																									oModelT5S:GetValue('T5S_APURIR')	})
																				EndIf
																			EndIf
																		EndIf
																	Next nT5S
																EndIf
															EndIf
														Next nT5Q
													EndIf
												EndIf
											Next nT5J
										EndIf
									Next nT5I

									//T88
									If !lLaySimplif
										For nT88 := 1 to oModel:GetModel( "MODEL_T88" ):Length()
											oModel:GetModel( "MODEL_T88" ):GoLine( nT88 )
											If !oModel:GetModel( "MODEL_T88" ):IsEmpty() .and. !oModel:GetModel( "MODEL_T88" ):IsDeleted()
												aAdd( aGravaT88, {	oModelT06:GetValue( "T06_IDEDMD" ),;
													oModelT88:GetValue( "T88_IDCODC" ) } )
											EndIf
										Next nT88
									EndIf
								EndIf
							EndIf
						Next nT06
					EndIf

					//C9J
					For nC9J := 1 To oModel:GetModel( 'MODEL_C9J' ):Length()
						oModel:GetModel( 'MODEL_C9J' ):GoLine(nC9J)

						If !oModel:GetModel( 'MODEL_C9J' ):IsDeleted()
							aAdd (aGravaC9J,{	oModelC9J:GetValue('C9J_TPINSC')	,;
								oModelC9J:GetValue('C9J_NRINSC')	,;
								oModelC9J:GetValue('C9J_VLREMU')	,;
								oModelC9J:GetValue('C9J_CODCAT')	})
						EndIf
					Next nC9J

					For nT3H := 1 To oModel:GetModel( 'MODEL_T3H' ):Length()
						oModel:GetModel( 'MODEL_T3H' ):GoLine(nT3H)

						If !oModel:GetModel( 'MODEL_T3H' ):IsDeleted()
							aAdd (aGravaT3H ,{	oModelT3H:GetValue('T3H_TPTRIB') ,;
								oModelT3H:GetValue('T3H_IDPROC') ,;
								oModelT3H:GetValue('T3H_CODSUS') ,;
								oModelT3H:GetValue('T3H_IDSUSP') })
						EndIf
					Next nT3H

					For nV1M := 1 To oModel:GetModel( 'MODEL_V1M' ):Length()
						oModel:GetModel( 'MODEL_V1M' ):GoLine(nV1M)

						If !oModel:GetModel( 'MODEL_V1M' ):IsDeleted()
							aAdd (aGravaV1M ,{	oModelV1M:GetValue('V1M_CODOBS') ,;
								oModelV1M:GetValue('V1M_OBSERV') })
						EndIf
					Next nV1M

					For nV1N := 1 To oModel:GetModel( 'MODEL_V1N' ):Length()
						oModel:GetModel( 'MODEL_V1N' ):GoLine(nV1N)

						If !oModel:GetModel( 'MODEL_V1N' ):IsDeleted()
							aAdd (aGravaV1N ,{	oModelV1N:GetValue('V1N_INSCSG') ,;
								oModelV1N:GetValue('V1N_NRCONT') })
						EndIf
					Next nV1N

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seto o campo como Inativo e gravo a versao do novo registro³
					//³no registro anterior                                       ³
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FAltRegAnt( "CMD", "2" )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu preciso setar a operacao do model³
					//³como Inclusao                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oModel:DeActivate()
					oModel:SetOperation( 3 )
					oModel:Activate()

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu realizo a inclusao do novo registro ja³
					//³contemplando as informacoes alteradas pelo usuario     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nlI := 1 To Len( aGrava )
						oModel:LoadValue( 'MODEL_CMD', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
					Next

					//Necessário Abaixo do For Nao Retirar
					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_CMD', 'CMD_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					// T06
					For nT06 := 1 To Len(aGravaT06)
						oModel:GetModel("MODEL_T06"):lValid	:= .T.

						If nT06 > 1
							oModel:GetModel("MODEL_T06"):AddLine()
						EndIf

						oModel:LoadValue("MODEL_T06", "T06_IDEDMD", aGravaT06[nT06][1])

						If lSimplBeta .And. TafColumnPos("T06_INDRRA")
							oModel:LoadValue("MODEL_T06", "T06_INDRRA", aGravaT06[nT06][2])
							oModel:LoadValue("MODEL_T06", "T06_TPPRRA", aGravaT06[nT06][3])
							oModel:LoadValue("MODEL_T06", "T06_NRPRRA", aGravaT06[nT06][4])
							oModel:LoadValue("MODEL_T06", "T06_DESCRA", aGravaT06[nT06][5])
							oModel:LoadValue("MODEL_T06", "T06_QTMRRA", aGravaT06[nT06][6])
							oModel:LoadValue("MODEL_T06", "T06_VLRCUS", aGravaT06[nT06][7])
							oModel:LoadValue("MODEL_T06", "T06_VLRADV", aGravaT06[nT06][8])

							nV9NAdd := 1

							For nV9N := 1 To Len(aGravaV9N)
								If aGravaV9N[nV9N][1] == aGravaT06[nT06][1]
									oModel:GetModel("MODEL_V9N"):lValid := .T.

									If nV9NAdd > 1
										oModel:GetModel("MODEL_V9N"):AddLine()
									EndIf

									oModel:LoadValue("MODEL_V9N", "V9N_TPINSC", aGravaV9N[nV9N][2])
									oModel:LoadValue("MODEL_V9N", "V9N_NRINSC", aGravaV9N[nV9N][3])
									oModel:LoadValue("MODEL_V9N", "V9N_VLRADV", aGravaV9N[nV9N][4])

									nV9NAdd++
								EndIf
							Next
						EndIf

						//T3G
						nT3GAdd := 1
						For nT3G := 1 to Len( aGravaT3G )
							If  aGravaT3G[nT3G][1] == aGravaT06[nT06][1]
								oModel:GetModel( 'MODEL_T3G' ):LVALID := .T.

								If nT3GAdd > 1
									oModel:GetModel( "MODEL_T3G" ):AddLine()
								EndIf

								oModel:LoadValue( "MODEL_T3G", "T3G_ESTABE", aGravaT3G[nT3G][2] )
								oModel:LoadValue( "MODEL_T3G", "T3G_LOTTRB", aGravaT3G[nT3G][3] )
								oModel:LoadValue( "MODEL_T3G", "T3G_GRAUEX", aGravaT3G[nT3G][4] )
								oModel:LoadValue( "MODEL_T3G", "T3G_INDCSU", aGravaT3G[nT3G][5] )

								//T05
								nT05Add := 1
								For nT05 := 1 to Len( aGravaT05 )
									If  aGravaT05[nT05][1] == aGravaT3G[nT3G][1] .AND.;
										aGravaT05[nT05][2] == aGravaT3G[nT3G][2] .AND.;
										aGravaT05[nT05][3] == aGravaT3G[nT3G][3]

										oModel:GetModel( 'MODEL_T05' ):LVALID := .T.

										If nT05Add > 1
											oModel:GetModel( "MODEL_T05" ):AddLine()
										EndIf

										If !lLaySimplif
											oModel:LoadValue( "MODEL_T05", "T05_CODRUB", aGravaT05[nT05][4] )
											oModel:LoadValue( "MODEL_T05", "T05_QTDRUB", aGravaT05[nT05][5] )
											oModel:LoadValue( "MODEL_T05", "T05_FATRUB", aGravaT05[nT05][6] )
											oModel:LoadValue( "MODEL_T05", "T05_VLRUNI", aGravaT05[nT05][7] )
											oModel:LoadValue( "MODEL_T05", "T05_VLRRUB", aGravaT05[nT05][8] )
										Else
											oModel:LoadValue( "MODEL_T05", "T05_CODRUB", aGravaT05[nT05][4] )
											oModel:LoadValue( "MODEL_T05", "T05_SQTDRB", aGravaT05[nT05][5] )
											oModel:LoadValue( "MODEL_T05", "T05_FATRUB", aGravaT05[nT05][6] )
											oModel:LoadValue( "MODEL_T05", "T05_VLRRUB", aGravaT05[nT05][7] )
											oModel:LoadValue( "MODEL_T05", "T05_APURIR", aGravaT05[nT05][8] )
										EndIf

										nT05Add++
									EndIf
								Next nT05

								If !lLaySimplif
									//T15
									nT15Add := 1
									For nT15 := 1 to Len( aGravaT15 )
										If  aGravaT15[nT15][1] == aGravaT3G[nT3G][1] .AND.;
												aGravaT15[nT15][2] == aGravaT3G[nT3G][2] .AND.;
												aGravaT15[nT15][3] == aGravaT3G[nT3G][3]

											oModel:GetModel( 'MODEL_T15' ):LVALID := .T.

											If nT15Add > 1
												oModel:GetModel( "MODEL_T15" ):AddLine()
											EndIf

											oModel:LoadValue( "MODEL_T15", "T15_CNPJOP",	aGravaT15[nT15][4] )
											oModel:LoadValue( "MODEL_T15", "T15_REGANS",	aGravaT15[nT15][5] )
											oModel:LoadValue( "MODEL_T15", "T15_VLPGTI",	aGravaT15[nT15][6] )
											oModel:LoadValue( "MODEL_T15", "T15_NOMEVE" ,	"S2299" )

											//T16
											nT16Add := 1
											For nT16 := 1 to Len( aGravaT16 )
												If  aGravaT16[nT16][1] == aGravaT15[nT15][1] .AND.;
														aGravaT16[nT16][2] == aGravaT15[nT15][2] .AND.;
														aGravaT16[nT16][3] == aGravaT15[nT15][3] .AND.;
														aGravaT16[nT16][4] == aGravaT15[nT15][4] .AND.;
														aGravaT16[nT16][5] == aGravaT15[nT15][5]

													oModel:GetModel( 'MODEL_T16' ):LVALID := .T.

													If nT16Add > 1
														oModel:GetModel( "MODEL_T16" ):AddLine()
													EndIf

													oModel:LoadValue( "MODEL_T16", "T16_SEQUEN",	aGravaT16[nT16][6] )
													oModel:LoadValue( "MODEL_T16", "T16_CPFDEP",	aGravaT16[nT16][7] )
													oModel:LoadValue( "MODEL_T16", "T16_DTNDEP",	aGravaT16[nT16][8] )
													oModel:LoadValue( "MODEL_T16", "T16_NOMDEP",	aGravaT16[nT16][9] )
													oModel:LoadValue( "MODEL_T16", "T16_VPGDEP",	aGravaT16[nT16][10] )
													oModel:LoadValue( "MODEL_T16", "T16_TPDEP" ,	aGravaT16[nT16][11] )
													oModel:LoadValue( "MODEL_T16", "T16_NOMEVE" ,	"S2299" )

													nT16Add++
												EndIf
											Next nT16

											nT15Add++
										EndIf
									Next nT15
								EndIf
								
								nT3GAdd++
							EndIf
						Next nT3G

						//T5I
						nT5IAdd := 1
						For nT5I := 1 to Len( aGravaT5I )
							If  aGravaT5I[nT5I][1] == aGravaT06[nT06][1]
								oModel:GetModel( 'MODEL_T5I' ):LVALID	:= .T.

								If nT5IAdd > 1
									oModel:GetModel( "MODEL_T5I" ):AddLine()
								EndIf

								oModel:LoadValue( "MODEL_T5I", "T5I_DTACCO",	aGravaT5I[nT5I][2] )
								oModel:LoadValue( "MODEL_T5I", "T5I_TPACCO",	aGravaT5I[nT5I][3] )
								
								If !lLaySimplif
									oModel:LoadValue( "MODEL_T5I", "T5I_DTEFAC",	aGravaT5I[nT5I][4] )
									oModel:LoadValue( "MODEL_T5I", "T5I_DSC"   ,	aGravaT5I[nT5I][5] )
									oModel:LoadValue( "MODEL_T5I", "T5I_COMPAC",	aGravaT5I[nT5I][6] )
								Else
									oModel:LoadValue( "MODEL_T5I", "T5I_DSC"   ,	aGravaT5I[nT5I][4] )
								EndIf

								//T5J
								nT5JAdd := 1
								For nT5J := 1 to Len( aGravaT5J )
									If  aGravaT5J[nT5J][1] == aGravaT5I[nT5I][1] .AND.;
										aGravaT5J[nT5J][2] == aGravaT5I[nT5I][2] .AND.;
										aGravaT5J[nT5J][3] == aGravaT5I[nT5I][3]

										oModel:GetModel( 'MODEL_T5J' ):LVALID := .T.

										If nT5JAdd > 1
											oModel:GetModel( "MODEL_T5J" ):AddLine()
										EndIf

										oModel:LoadValue( "MODEL_T5J", "T5J_PERREF", aGravaT5J[nT5J][4] )

										//T5Q
										nT5QAdd := 1
										For nT5Q := 1 to Len( aGravaT5Q )
											If  aGravaT5Q[nT5Q][1] == aGravaT5J[nT5J][1] .AND.;
												aGravaT5Q[nT5Q][2] == aGravaT5J[nT5J][2] .AND.;
												aGravaT5Q[nT5Q][3] == aGravaT5J[nT5J][3] .AND.;
												aGravaT5Q[nT5Q][4] == aGravaT5J[nT5J][4]

												oModel:GetModel( 'MODEL_T5Q' ):LVALID := .T.

												If nT5QAdd > 1
													oModel:GetModel( "MODEL_T5Q" ):AddLine()
												EndIf

												oModel:LoadValue( "MODEL_T5Q", "T5Q_ESTABE",	aGravaT5Q[nT5Q][5] )
												oModel:LoadValue( "MODEL_T5Q", "T5Q_LOTTRB",	aGravaT5Q[nT5Q][6] )
												oModel:LoadValue( "MODEL_T5Q", "T5Q_GRAUEX",	aGravaT5Q[nT5Q][7] )
												oModel:LoadValue( "MODEL_T5Q", "T5Q_INDCSU",	aGravaT5Q[nT5Q][8] )

												//T5S
												nT5SAdd := 1
												For nT5S := 1 to Len( aGravaT5S )
													If  aGravaT5S[nT5S][1] == aGravaT5Q[nT5Q][1] .AND.;
															aGravaT5S[nT5S][2] == aGravaT5Q[nT5Q][2] .AND.;
															aGravaT5S[nT5S][3] == aGravaT5Q[nT5Q][3] .AND.;
															aGravaT5S[nT5S][4] == aGravaT5Q[nT5Q][4] .AND.;
															aGravaT5S[nT5S][5] == aGravaT5Q[nT5Q][5] .AND.;
															aGravaT5S[nT5S][6] == aGravaT5Q[nT5Q][6]

														oModel:GetModel( 'MODEL_T5S' ):LVALID := .T.

														If nT5SAdd > 1
															oModel:GetModel( "MODEL_T5S" ):AddLine()
														EndIf

														oModel:LoadValue( "MODEL_T5S", "T5S_CODRUB",	aGravaT5S[nT5S][7] )

														If !lLaySimplif
															oModel:LoadValue( "MODEL_T5S", "T5S_QTDRUB",	aGravaT5S[nT5S][8] )
															oModel:LoadValue( "MODEL_T5S", "T5S_FATRUB",    aGravaT5S[nT5S][9] )														
															oModel:LoadValue( "MODEL_T5S", "T5S_VLRUNI",    aGravaT5S[nT5S][10] )
															oModel:LoadValue( "MODEL_T5S", "T5S_VLRRUB",    aGravaT5S[nT5S][11] )
														Else
															oModel:LoadValue( "MODEL_T5S", "T5S_SQTDRB",	aGravaT5S[nT5S][8] )
															oModel:LoadValue( "MODEL_T5S", "T5S_FATRUB",    aGravaT5S[nT5S][9] )
															oModel:LoadValue( "MODEL_T5S", "T5S_VLRRUB",    aGravaT5S[nT5S][10] )
															oModel:LoadValue( "MODEL_T5S", "T5S_APURIR",    aGravaT5S[nT5S][11] )
														EndIf

														nT5SAdd++
													EndIf
												Next nT5S
											EndIf
										Next nT5Q

										nT5JAdd++
									EndIf
								Next nT5J

								nT5IAdd++
							EndIf
						Next nT5I

						//T88
						If !lLaySimplif
							nT88Add := 1
							For nT88 := 1 to Len( aGravaT88 )
								If aGravaT88[nT88][1] == aGravaT06[nT06][1]
									oModel:GetModel( "MODEL_T88" ):lValid := .T.

									If nT88Add > 1
										oModel:GetModel( "MODEL_T88" ):AddLine()
									EndIf

									oModel:LoadValue( "MODEL_T88", "T88_IDCODC", aGravaT88[nT88][2] )

									nT88Add ++
								EndIf
							Next nT88
						EndIf

					Next nT06

					For nlI := 1 To Len( aGravaC9J )
						If nlI > 1
							oModel:GetModel( 'MODEL_C9J' ):AddLine()
						EndIf
						oModel:LoadValue( "MODEL_C9J", "C9J_TPINSC" ,	aGravaC9J[nlI][1] )
						oModel:LoadValue( "MODEL_C9J", "C9J_NRINSC" ,	aGravaC9J[nlI][2] )
						oModel:LoadValue( "MODEL_C9J", "C9J_VLREMU" ,	aGravaC9J[nlI][3] )
						oModel:LoadValue( "MODEL_C9J", "C9J_CODCAT" ,	aGravaC9J[nlI][4] )
						oModel:LoadValue( "MODEL_C9J", "C9J_NOMEVE" ,	"S2299" )
					Next

					For nlI := 1 To Len( aGravaT3H )
						If nlI > 1
							oModel:GetModel( 'MODEL_T3H' ):AddLine()
						EndIf
						oModel:LoadValue( "MODEL_T3H", "T3H_TPTRIB" ,	aGravaT3H[nlI][1] )
						oModel:LoadValue( "MODEL_T3H", "T3H_IDPROC" ,	aGravaT3H[nlI][2] )
						oModel:LoadValue( "MODEL_T3H", "T3H_CODSUS" ,	aGravaT3H[nlI][3] )
						oModel:LoadValue( "MODEL_T3H", "T3H_IDSUSP" ,	aGravaT3H[nlI][4] )
						oModel:LoadValue( "MODEL_T3H", "T3H_NOMEVE" ,	"S2299" )
					Next

					For nlI := 1 To Len( aGravaV1M )
						If nlI > 1
							oModel:GetModel( 'MODEL_V1M' ):AddLine()
						EndIf
						oModel:LoadValue( "MODEL_V1M", "V1M_CODOBS" ,	aGravaV1M[nlI][1] )
						oModel:LoadValue( "MODEL_V1M", "V1M_OBSERV" ,	aGravaV1M[nlI][2] )
						oModel:LoadValue( "MODEL_V1M", "V1M_NOMEVE" ,	"S2299" )
					Next

					For nlI := 1 To Len( aGravaV1N )
						If nlI > 1
							oModel:GetModel( 'MODEL_V1N' ):AddLine()
						EndIf
						oModel:LoadValue( "MODEL_V1N", "V1N_INSCSG" ,	aGravaV1N[nlI][1] )
						oModel:LoadValue( "MODEL_V1N", "V1N_NRCONT" ,	aGravaV1N[nlI][2] )
						oModel:LoadValue( "MODEL_V1N", "V1N_NOMEVE" ,	"S2299" )
					Next

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao que sera gravada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVersao := xFunGetVer()

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oModel:LoadValue( "MODEL_CMD", "CMD_VERSAO", cVersao )
					oModel:LoadValue( "MODEL_CMD", "CMD_VERANT", cVerAnt )
					oModel:LoadValue( "MODEL_CMD", "CMD_PROTPN", cProtocolo )
					oModel:LoadValue( "MODEL_CMD", "CMD_PROTUL", "" )
					// Tratamento para limpar o ID unico do xml
					cAliasPai := "CMD"
					If TAFColumnPos( cAliasPai+"_XMLID" )
						oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					EndIf

					If nOperation == MODEL_OPERATION_DELETE
						oModel:LoadValue( "MODEL_CMD", "CMD_EVENTO", "E" )
					Else
						If cEvento == "E"
							oModel:LoadValue( "MODEL_CMD", "CMD_EVENTO", "I" )
						Else
							oModel:LoadValue( "MODEL_CMD", "CMD_EVENTO", "A" )
						EndIf
					Endif

				ElseIf CMD->CMD_STATUS == "2"
					TAFMsgVldOp( oModel, "2" )//"Registro não pode ser alterado. Aguardando processo da transmissão."
					lRetorno := .F.
				Elseif CMD->CMD_STATUS == "6"
					TAFMsgVldOp( oModel, "6" )//"Registro não pode ser alterado. Aguardando processo de transmissão do evento de Exclusão S-3000"
					lRetorno := .F.
				ElseIf CMD->CMD_STATUS == "7"
					TAFMsgVldOp( oModel, "7" )//"Registro não pode ser alterado, pois o evento de exclusão já se encontra na base do RET"
					lRetorno := .F.
				Else
					//alteração sem transmissão
					If TafColumnPos( "CMD_LOGOPE" )
						cLogOpeAnt := CMD->CMD_LOGOPE
					endif
				Endif

				If lRetorno

					//Gravo alteração para o Extemporâneo
					If lGoExtemp
						TafGrvExt( oModel, 'MODEL_CMD', 'CMD' )
					Endif

					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_CMD', 'CMD_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					If FwFormCommit( oModel )
						If lInfoRPT
							aAnalitico := LoadReportData(oModel, lInfoRPT)
							oInfoRPT:SetAnalitico(aAnalitico)
							oReport:UpSert( "S-2299", "2", xFilial( "CMD" ), oInfoRPT )
						EndIf
					EndIf
					TAFAltStat( "CMD", " " )
				Endif
			EndIf

		ElseIf nOperation == MODEL_OPERATION_DELETE

			cChvRegAnt := CMD->(CMD_ID + CMD_VERANT)
		
			TAFAltStat( 'CMD', " " )
			If FwFormCommit( oModel )
				If lInfoRPT
					oReport:UpSert( "S-2299", "2", xFilial( "CMD" ), oInfoRPT, .T. )
				EndIf
			EndIf
			
			If CMD->CMD_EVENTO == "A" .Or. CMD->CMD_EVENTO == "E"
				TAFRastro( 'CMD', 1, cChvRegAnt, .T., , IIF(Type ("oBrw") == "U", Nil, oBrw ))
			EndIf
				
		EndIf

	End Transaction

Return ( lRetorno )

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Validação dos dados, executado no momento da confirmação do modelo.

@Param	oModel	- Modelo de dados

@Return	lRet	- Indica se todas as condições foram respeitadas

@Author		Felipe C. Seolin
@Since		08/11/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ValidModel( oModel )

	Local oModelT06  := oModel:GetModel( "MODEL_T06" )
	Local oModelT88  := oModel:GetModel( "MODEL_T88" )
	Local cTrabal    := oModel:GetModel( "MODEL_CMD" ):GetValue( "CMD_FUNC" )
	Local cLogErro   := ""
	Local nOperation := oModel:GetOperation()
	Local nI         := 0
	Local nJ         := 0
	Local nLineT06   := oModelT06:GetLine()
	Local nLineT88   := oModelT88:GetLine()
	Local lRet       := .T.

	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE

		DBSelectArea( "T87" )
		T87->( DBSetOrder( 2 ) )

		For nI := 1 to oModelT06:Length()
			oModelT06:GoLine( nI )

			If lRet .and. !oModelT06:IsEmpty() .and. !oModelT06:IsDeleted()
				oModelT88 := oModel:GetModel( "MODEL_T88" )

				For nJ := 1 to oModelT88:Length()
					oModelT88:GoLine( nJ )

					If lRet .and. !oModelT88:IsEmpty() .and. !oModelT88:IsDeleted()
						If T87->( MsSeek( xFilial( "T87" ) + cTrabal + oModelT88:GetValue( "T88_CODCON", nJ ) + "1" ) )
							If T87->T87_ID <> oModelT88:GetValue( "T88_IDCODC", nJ )
								lRet := .F.
								cLogErro += STR0046 + CRLF //"Operação não permitida para garantir a consistência das Informações da Convocação para Trabalho Intermitente com o Trabalhador selecionado."
								Exit
							EndIf
						Else
							lRet := .F.
							cLogErro += STR0046 + CRLF //"Operação não permitida para garantir a consistência das Informações da Convocação para Trabalho Intermitente com o Trabalhador selecionado."
							Exit
						EndIf
					EndIf
				Next nJ
			EndIf
		Next nI

		oModelT06:GoLine( nLineT06 )
		oModelT88:GoLine( nLineT88 )

	EndIf

	If !Empty( cLogErro )
		Help( ,, "HELP",, cLogErro, 1, 0 )
	EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidCMD
Validação das informações do formulário referente
a tabela CMD, indicado pelo Desligamento.

@Param		oModelCMD	- Objeto de modelo da tabela CMD
			cAction		- Ação origem da causa da validação
			cIDField	- Campo posicionado referente ao objeto oModelCMD
			xValue		- Valor a ser inserido na ação

@Return		lRet		- Informa se a ação foi validada

@Author		Felipe C. Seolin
@Since		08/11/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ValidCMD( oModelCMD, cAction, cIDField, xValue )

	Local oModelT06	:=	oModelCMD:GetModel( "MODEL_T06" ):GetModel( "MODEL_T06" )
	Local oModelT88	:=	IIF(!lLaySimplif, oModelT06:GetModel( "MODEL_T88" ):GetModel( "MODEL_T88" ), Nil)
	Local nI		:=	0
	Local nJ		:=	0
	Local nLineT06	:=	oModelT06:GetLine()
	Local nLineT88	:=	IIF(!lLaySimplif, oModelT88:GetLine(), 0)
	Local lPerg     :=	.F.
	Local lOk     	:=	.F.
	Local lRet     	:=	.T.

	If cAction == "SETVALUE" .AND. !lLaySimplif

		If cIDField $ "CMD_FUNC" .and. oModelCMD:GetValue( "CMD_FUNC" ) <> xValue
			For nI := 1 to oModelT06:Length()
				oModelT06:GoLine( nI )

				If !oModelT06:IsEmpty() .and. !oModelT06:IsDeleted()
					oModelT88 := oModelT06:GetModel( "MODEL_T88" ):GetModel( "MODEL_T88" )

					For nJ := 1 to oModelT88:Length()
						oModelT88:GoLine( nJ )

						If !oModelT88:IsEmpty() .and. !oModelT88:IsDeleted()
							If !lPerg
								lOk := MsgYesNo( STR0047, STR0048 ) //##"Ao alterar o Trabalhador, será necessário informar novamente as Informações da(s) convocação(ões) de trabalho intermitente. Deseja apagar os itens já digitados?" ##"Alteração de Trabalhador"
								lPerg := .T.
							EndIf

							If lOk
								oModelT88:DeleteLine()
							EndIf
						EndIf
					Next nJ
				EndIf

			Next nI
		EndIf

	EndIf

	oModelT06:GoLine( nLineT06 )
	If !lLaySimplif
		oModelT88:GoLine( nLineT88 )
	EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidT88

Validação das informações da grid referente a tabela T88,
indicado pelas informações da convocação para trabalho intermitente.

@Param		oModelT88		- Objeto de modelo da tabela T88
			nLine			- Linha posicionada referente ao objeto oModelT88
			cAction			- Ação origem da causa da validação
			cIDField		- Campo posicionado referente ao objeto oModelT88
			xValue			- Valor a ser inserido na ação
			xCurrentValue	- Valor contido no atualmente no campo

@Return		lRet			- Informa se a ação foi validada

@Author		Felipe C. Seolin
@Since		08/11/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ValidT88( oModelT88, nLine, cAction, cIDField, xValue, xCurrentValue )

	Local oModelT06	:=	oModelT88:GetOwner()
	Local oModelCMD	:=	oModelT06:GetOwner()
	Local cLogErro	:=	""
	Local lRet		:=	.T.

	If cAction == "UNDELETE"
		DBSelectArea( "T87" )
		T87->( DBSetOrder( 2 ) )
		If T87->( MsSeek( xFilial( "T87" ) + oModelCMD:GetValue( "CMD_FUNC" ) + oModelT88:GetValue( "T88_CODCON", nLine ) + "1" ) )
			If T87->T87_ID <> oModelT88:GetValue( "T88_IDCODC", nLine )
				lRet := .F.
				cLogErro += STR0046 + CRLF //"Operação não permitida para garantir a consistência das Informações da Convocação para Trabalho Intermitente com o Trabalhador selecionado."
			EndIf
		Else
			lRet := .F.
			cLogErro += STR0046 + CRLF //"Operação não permitida para garantir a consistência das Informações da Convocação para Trabalho Intermitente com o Trabalhador selecionado."
		EndIf
	EndIf

	If !Empty( cLogErro )
		Help( ,, "HELP",, cLogErro, 1, 0 )
	EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF266Rul
Regras para gravacao das informacoes do registro S-2299 do E-Social

@Param

@Return
aRull - Regras para a gravacao das informacoes

@author Felipe C. Seolin
@since 29/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF266Rul( cInconMsg as Character, nSeqErrGrv as Numeric, cCodEvent as Character, cOwner as Character)

	Local aRull     as Array
	Local cCabec    as Character
	Local cIdMotDes as Character
	Local cIdFunc   as Character
	Local cDtDeslig as Character
	Local cDtAvPrev as Character
	Local cTagIGuia as Character

	Default cInconMsg  := ""
	Default nSeqErrGrv := 0
	Default cCodEvent  := ""
	Default cOwner     := ""

	aRull     := {}
	cCabec    := "/eSocial/evtDeslig/"
	cIdMotDes := FGetIdInt( "mtvDeslig" , "", cCabec + "infoDeslig/mtvDeslig",,,,@cInconMsg, @nSeqErrGrv )
	cIdFunc   := FGetIdInt( "cpfTrab" , "matricula", cCabec +"/ideVinculo/cpfTrab", cCabec + "/ideVinculo/matricula",,,@cInconMsg, @nSeqErrGrv)
	cDtDeslig := StoD( StrTran( AllTrim( oDados:xPathGetNodeValue( cCabec + "/infoDeslig/dtDeslig" ) ), "-", "" ) )
	cDtAvPrev := ""
	cTagIGuia := cCabec + "ideEvento/indGuia"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chave do registro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd( aRull, {"CMD_FUNC"  , cIdFunc  	, "C", .T.} )
	aAdd( aRull, {"CMD_MOTDES", cIdMotDes	, "C", .T.} )

	//Data do desligamento
	aAdd( aRull, {"CMD_DTDESL", cDtDeslig	, "D", .T.} )

	If lLaySimplif
		cDtAvPrev := StoD( StrTran( AllTrim( oDados:xPathGetNodeValue( cCabec + "/infoDeslig/dtAvPrv" ) ), "-", "" ) )
		aAdd( aRull, {"CMD_DTAVPR", cDtAvPrev	, "D", .T.} )

		If TafXNode( oDados , cCodEvent, cOwner, cTagIGuia)
			aAdd( aRull, {"CMD_TPGUIA", cTagIGuia, "C", .F.} )
		EndIf
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "infoDeslig/indPagtoAPI"))
		aAdd( aRull, {"CMD_INDPAG", xFunTrcSN( TAFExisTag( cCabec + "infoDeslig/indPagtoAPI" ) ,2) , "C", .T.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "infoDeslig/dtProjFimAPI"))
		aAdd( aRull, {"CMD_TERAPI", cCabec + "infoDeslig/dtProjFimAPI", "D", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "infoDeslig/pensAlim"  ))
		aAdd( aRull, {"CMD_PENALI", cCabec + "infoDeslig/pensAlim", "C", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "infoDeslig/percAliment"  ))
		aAdd( aRull, {"CMD_PERALI", cCabec + "infoDeslig/percAliment", "N", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "infoDeslig/vrAlim"  ))
		aAdd( aRull, {"CMD_VLPALI", cCabec + "infoDeslig/vrAlim", "N", .F.} )
	EndIf

	If !lLaySimplif
		If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "infoDeslig/nrCertObito"  ))
			aAdd( aRull, {"CMD_NRATES", cCabec + "infoDeslig/nrCertObito", "C", .F.} )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "infoDeslig/indCumprParc" ))
			aAdd( aRull, {"CMD_INDCUM", cCabec + "infoDeslig/indCumprParc", "C", .F.} )
		EndIf
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "infoDeslig/nrProcTrab" ))
		aAdd( aRull, {"CMD_NRPROC", cCabec + "infoDeslig/nrProcTrab", "C", .F.} )
	EndIf

	If !lLaySimplif
		If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "infoDeslig/qtdDiasInterm" ))
			aAdd( aRull, {"CMD_QTDDIA", cCabec + "infoDeslig/qtdDiasInterm", "C", .F.} )
		EndIf
	EndIf

	If !lLaySimplif
		If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "infoDeslig/sucessaoVinc/tpInscSuc"	))
			aAdd( aRull, {"CMD_TPINSC", cCabec + "infoDeslig/sucessaoVinc/tpInscSuc", "C", .F.} )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "infoDeslig/sucessaoVinc/cnpjSucessora"	))
			aAdd( aRull, {"CMD_CNPJSU", cCabec + "infoDeslig/sucessaoVinc/cnpjSucessora", "C", .F.} )
		EndIf
	Else
		If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "infoDeslig/sucessaoVinc/tpInsc"	))
			aAdd( aRull, {"CMD_TPINSC", cCabec + "infoDeslig/sucessaoVinc/tpInsc", "C", .F.} )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "infoDeslig/sucessaoVinc/nrInsc"	))
			aAdd( aRull, {"CMD_NRINSC", cCabec + "infoDeslig/sucessaoVinc/nrInsc", "C", .F.} )
		EndIf		
	EndIf

	If !lSimplBeta
		If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "infoDeslig/quarentena/dtFimQuar" ))
			aAdd( aRull, {"CMD_DTQUA" , cCabec + "infoDeslig/quarentena/dtFimQuar", "D", .F.} )
		EndIf
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "infoDeslig/transfTit/cpfSubstituto" ))
		aAdd( aRull, { "CMD_CPFSUB", cCabec + "infoDeslig/transfTit/cpfSubstituto", "C", .F. } )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "infoDeslig/transfTit/dtNascto" ))
		aAdd( aRull, { "CMD_DTNSTI", cCabec + "infoDeslig/transfTit/dtNascto", "D", .F. } )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "infoDeslig/mudancaCPF/novoCPF" ))
		aAdd( aRull, { "CMD_NEWCPF", cCabec + "infoDeslig/mudancaCPF/novoCPF", "C", .F. } )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "infoDeslig/verbasResc/procCS/nrProcJud" ))
		aAdd( aRull, { "CMD_PROCCS", FGetIdInt( "nrProcJ", , cCabec + "infoDeslig/verbasResc/procCS/nrProcJud",,,,@cInconMsg, @nSeqErrGrv), "C", .T. } )
	EndIf

	If lSimplBeta .and. TafColumnPos("CMD_INDREM")
		If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "infoDeslig/remunAposDeslig/indRemun" ))
			aAdd( aRull, { "CMD_INDREM", cCabec + "infoDeslig/remunAposDeslig/indRemun", "C", .F. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "infoDeslig/remunAposDeslig/dtFimRemun" ))
			aAdd( aRull, { "CMD_DTFREM", cCabec + "infoDeslig/remunAposDeslig/dtFimRemun", "D", .F. } )
		EndIf
	EndIf

Return( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF266Grv
Funcao de gravacao para atender o registro S-2299

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

@author Felipe C. Seolin
@since 29/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF266Grv( cLayout as Character, nOpc as Numeric, cFilEv as Character, oXML as Object, cOwner as Character,;
 					cFilTran as Character, cPredeces as Character, nTafRecno as Numeric, cComplem as Character, cGrpTran as Character,;
 					cEmpOriGrp as Character, cFilOriGrp as Character, cXmlID as Character, cEvtOri as character, lMigrador as logical,;
 					lDepGPE as logical, cKey as character, cMatrC9V as character, lLaySmpTot as logical, lExclCMJ as logical,;
					oTransf as object, cXML as character)

	Local cCmpsNoUpd  	as Character
	Local cCabec      	as Character
	Local cT06Path    	as Character
	Local cT3GPath    	as Character
	Local cT05Path    	as Character
	Local cT15Path    	as Character
	Local cT16Path    	as Character
	Local cT88Path    	as Character
	Local cC9JPath    	as Character
	Local cT3HPath    	as Character
	Local cV1MPath    	as Character
	Local cV1NPath    	as Character
	Local cIdFunc     	as Character
	Local cDtDeslig   	as Character
	Local cTagRecibo  	as Character
	Local cInconMsg   	as Character
	Local cIdProc     	as Character
	Local cCodEvent   	as Character
	Local cLogOpeAnt  	as Character
	Local cV6DPath    	as Character
	Local cV9NPath		as character
	Local nI          	as Numeric
	Local nJ          	as Numeric
	Local nT05        	as Numeric
	Local n3          	as Numeric
	Local nT06        	as Numeric
	Local nT3G        	as Numeric
	Local nT15        	as Numeric
	Local nT16        	as Numeric
	Local nT88        	as Numeric
	Local nC9J        	as Numeric
	Local nT3H        	as Numeric
	Local nV1M        	as Numeric
	Local nV1N        	as Numeric
	Local nSeqErrGrv  	as Numeric
	Local nV6D        	as Numeric
	Local nV9N			as numeric
	Local lRet    		as Logical
	Local aIncons 		as Array
	Local aRules  		as Array
	Local aChave  		as Array
	Local oModel  		as Object

	//Relatório de Conferência de Valores
	Local oInfoRPT   	as Object
	Local cNome      	as Character
	Local cMatric    	as Character
	Local cCodCat    	as Character
	Local cCodRubr   	as Character
	Local nPosValores	as Numeric
	Local aAnalitico 	as Array
	Local aRubrica   	as Array
	Local lInfoRPT   	as Logical
	Local nInd       	as Numeric

	Private lVldModel 	as Logical //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.
	Private oDados    	as Object

	Default cLayout    	:= ""
	Default nOpc       	:= 1
	Default cFilEv     	:= ""
	Default oXML       	:= Nil
	Default cOwner     	:= ""
	Default cFilTran   	:= ""
	Default cPredeces  	:= ""
	Default nTafRecno  	:= 0
	Default cComplem   	:= ""
	Default cGrpTran   	:= ""
	Default cEmpOriGrp 	:= ""
	Default cFilOriGrp 	:= ""
	Default cXmlID     	:= ""
	Default cEvtOri    	:= ""
	Default lMigrador  	:= ""
	Default lDepGPE    	:= ""
	Default cKey       	:= ""
	Default cMatrC9V   	:= ""
	Default lLaySmpTot 	:= ""
	Default lExclCMJ   	:= ""
	Default oTransf    	:= ""
	Default cXML       	:= ""

	cCmpsNoUpd         	:= "|CMD_FILIAL|CMD_ID|CMD_VERSAO|CMD_VERANT|CMD_PROTUL|CMD_PROTPN|CMD_EVENTO|CMD_STATUS|CMD_ATIVO|"
	cCabec             	:= "/eSocial/evtDeslig/"
	cT06Path           	:= ""
	cT3GPath           	:= ""
	cT05Path           	:= ""
	cT15Path           	:= ""
	cT16Path           	:= ""
	cT88Path           	:= ""
	cC9JPath           	:= ""
	cT3HPath           	:= ""
	cV1MPath           	:= ""
	cV1NPath           	:= ""
	cIdFunc            	:= ""
	cDtDeslig          	:= ""
	cTagRecibo         	:= cCabec + "ideEvento/nrRecibo"
	cInconMsg          	:= ""
	cIdProc            	:= ""
	cCodEvent          	:= Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")
	cLogOpeAnt         	:= ""
	cV6DPath           	:= ""
	cV9NPath			:= ""
	nI                 	:= 0
	nJ                 	:= 0
	nT05               	:= 0
	n3                 	:= 0
	nT06               	:= 0
	nT3G               	:= 0
	nT15               	:= 0
	nT16               	:= 0
	nT88               	:= 0
	nC9J               	:= 0
	nT3H               	:= 0
	nV1M               	:= 0
	nV1N               	:= 0
	nV9N				:= 0
	nSeqErrGrv         	:= 0
	nV6D               	:= 0
	lRet               	:= .F.
	aIncons            	:= {}
	aRules             	:= {}
	aChave             	:= {}
	xChkDupl           	:= {} //Necessário verificar como será a padronização dessa variavel em todos os fontes.
	oModel             	:= Nil
	oInfoRPT           	:= Nil
	cNome              	:= ""
	cMatric            	:= ""
	cCodCat            	:= ""
	cCodRubr           	:= ""
	nPosValores        	:= 0
	aAnalitico         	:= {}
	aRubrica           	:= {}
	lInfoRPT           	:= .F.
	nInd               	:= 0
	lVldModel          	:= .T. //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.
	oDados             	:= oXML

	If __lGrvRPT == Nil
		TAF266Rpt() //Inicializa a variável static __lGrvRPT
	EndIf

	lInfoRPT := __lGrvRPT

	If lInfoRPT
		If oReport == Nil
			oReport := TAFSocialReport():New()
		EndIf
	EndIf

	If oDados:XPathHasNode(  cCabec + "/infoDeslig/dtDeslig" )
		cDtDeslig := Alltrim( oDados:XPathGetNodeValue( cCabec + "/infoDeslig/dtDeslig" ) )
	EndIf

	//Utiliza a tag recibo como chave
	If oDados:XPathHasNode( cTagRecibo )
		cIdFunc := FGetIdInt( "cpfTrab/Recibo", "matricula/Recibo", cCabec + "ideEvento/nrRecibo", cCabec + "ideEvento/nrRecibo" )
	EndIf

	If Empty(cIdFunc)// .or. EMPTY(cDtDeslig)
		cIdFunc := FGetIdInt( "cpfTrab"	, "matricula", cCabec +"/ideVinculo/cpfTrab", cCabec + "/ideVinculo/matricula")
	EndIf

	If lInfoRPT
		cMatric := AllTrim( oDados:xPathGetNodeValue( cCabec + "/ideVinculo/matricula" ) )

		DBSelectArea( "C9V" )
		C9V->( DBSetOrder( 2 ) )
		If C9V->( MsSeek( xFilial( "C9V" ) + cIDFunc + "1" ) )
			cNome := C9V->C9V_NOME

			DBSelectArea( "CUP" )
			CUP->( DBSetOrder( 1 ) )
			If CUP->( MsSeek( xFilial( "CUP" ) + C9V->C9V_ID ) )
				DBSelectArea( "C87" )
				C87->( DBSetOrder( 1 ) )
				If C87->( MsSeek( xFilial( "C87" ) + AllTrim( CUP->CUP_CODCAT ) ) )
					cCodCat := C87->C87_CODIGO
				EndIf
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chave do registro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Verifica se o evento ja existe na base
	If nOpc == 4 

		nInd := 5
		aAdd( aChave, {"C", "CMD_FUNC"  ,cIdFunc                        , .T. } )
		("CMD")->( DbSetOrder( 5 ) )
		If ("CMD")->( MsSeek( xFilial("CMD") + cIdFunc + '1' ) )
			nOpc := 4
		EndIf

	ElseIf nOpc == 3 .OR. nOpc == 5 .OR. (cOwner == "GPE" .AND. nOpc == 3)

		nInd := 2
		aAdd( aChave, {"C", "CMD_FUNC"  ,cIdFunc                        , .T. } )
		aAdd( aChave, {"C", "CMD_DTDESL",StrTran(cDtDeslig, '-','')     , .T. } )
		//Verifica se o evento ja existe na base
		("CMD")->( DbSetOrder( 2 ) )
		If ("CMD")->( MsSeek( xFilial("CMD") + cIdFunc + StrTran(cDtDeslig, '-','') + '1' ) )
			nOpc := 4
		EndIf

	EndIf

	Begin Transaction

		If Findfunction("TafNameEspace")
			cLayNmSpac := TafNameEspace(cXML)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao para validar se a operacao desejada pode ser realizada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FTafVldOpe( "CMD", nInd, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA266", cCmpsNoUpd )

			If TafColumnPos( "CMD_LOGOPE" )
				cLogOpeAnt := CMD->CMD_LOGOPE
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrego array com os campos De/Para de gravacao das informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aRules := TAF266Rul(@cInconMsg, @nSeqErrGrv, cCodEvent, cOwner )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
			//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpc <> 5

				oModel:LoadValue( "MODEL_CMD", "CMD_FILIAL", CMD->CMD_FILIAL )

				If TAFColumnPos( "CMD_LAYOUT" )
					oModel:LoadValue( "MODEL_CMD", "CMD_LAYOUT", cLayNmSpac)
				EndIf

				If TAFColumnPos( "CMD_XMLID" )
					oModel:LoadValue( "MODEL_CMD", "CMD_XMLID", cXmlID )
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Rodo o aRules para gravar as informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nI := 1 to Len( aRules )
					oModel:LoadValue( "MODEL_CMD", aRules[ nI, 01 ], FTafGetVal( aRules[ nI, 02 ], aRules[nI, 03], aRules[nI, 04], @aIncons, .F. ) )
				Next nI

				If Findfunction("TAFAltMan")
					if nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_CMD', 'CMD_LOGOPE' , '1', '' )
					elseif nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_CMD', 'CMD_LOGOPE' , '', cLogOpeAnt )
					EndIf
				EndIf

				If lLaySimplif
					nV6D := 1
					cV6DPath := cCabec + "infoDeslig/infoInterm[" + AllTrim(Str(nV6D)) + "]"
					If nOpc == 4
						For nJ := 1 to oModel:GetModel( "MODEL_V6D" ):Length()
							oModel:GetModel( "MODEL_V6D" ):GoLine(nJ)
							oModel:GetModel( "MODEL_V6D" ):DeleteLine()
						Next nJ
					EndIf

					nV6D := 1
					While oDados:XPathHasNode(cV6DPath)

						If nOpc == 4 .Or. nV6D > 1
							oModel:GetModel( "MODEL_V6D" ):lValid:= .T.
							oModel:GetModel( "MODEL_V6D" ):AddLine()
						EndIf

						If oDados:XPathHasNode(cV6DPath + "/dia")
							oModel:LoadValue( "MODEL_V6D", "V6D_DIA", FTafGetVal( cV6DPath + "/dia"	, "C", .F., @aIncons, .F. ))
						EndIf

						nV6D++
						cV6DPath := cCabec + "infoDeslig/infoInterm[" + AllTrim(Str(nV6D)) + "]"

					EndDo

				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quando se trata de uma alteracao, deleto todas as linhas do Grid³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nT06 := 1
				cT06Path := cCabec + "infoDeslig/verbasResc/dmDev[" + AllTrim(Str(nT06)) + "]"

				If nOpc == 4
					For nJ := 1 to oModel:GetModel( "MODEL_T06" ):Length()
						oModel:GetModel( "MODEL_T06" ):GoLine(nJ)
						oModel:GetModel( "MODEL_T06" ):DeleteLine()
					Next nJ
				EndIf

				nT06 := 1
				While oDados:XPathHasNode(cT06Path)

					If nOpc == 4 .Or. nT06 > 1
						oModel:GetModel( "MODEL_T06" ):lValid:= .T.
						oModel:GetModel( "MODEL_T06" ):AddLine()
					EndIf

					if oDados:XPathHasNode(cT06Path + "/ideDmDev")
						oModel:LoadValue( "MODEL_T06", "T06_IDEDMD", FTafGetVal( cT06Path + "/ideDmDev", "C", .F., @aIncons, .F. ) )
					EndIF

					If lSimplBeta .And. TafColumnPos("T06_INDRRA")

						If oDados:XPathHasNode(cT06Path + "/indRRA")
							oModel:LoadValue( "MODEL_T06", "T06_INDRRA", xFunTrcSN( FTafGetVal( cT06Path + "/indRRA", "C", .F., @aIncons, .F. ), 5 ) )
	 					EndIf

						If oDados:XPathHasNode(cT06Path + "/infoRRA/tpProcRRA")
							oModel:LoadValue( "MODEL_T06", "T06_TPPRRA", FTafGetVal( cT06Path + "/infoRRA/tpProcRRA", "C", .F., @aIncons, .F. ) )
	 					EndIf

						If oDados:XPathHasNode(cT06Path + "/infoRRA/nrProcRRA")
							oModel:LoadValue( "MODEL_T06", "T06_NRPRRA", FTafGetVal( cT06Path + "/infoRRA/nrProcRRA", "C", .F., @aIncons, .F. ) )
	 					EndIf

						If oDados:XPathHasNode(cT06Path + "/infoRRA/descRRA")
							oModel:LoadValue( "MODEL_T06", "T06_DESCRA", FTafGetVal( cT06Path + "/infoRRA/descRRA", "C", .F., @aIncons, .F. ) )
	 					EndIf

						If oDados:XPathHasNode(cT06Path + "/infoRRA/qtdMesesRRA")
							oModel:LoadValue( "MODEL_T06", "T06_QTMRRA", FTafGetVal( cT06Path + "/infoRRA/qtdMesesRRA", "N", .F., @aIncons, .F. ) )
	 					EndIf

						If oDados:XPathHasNode(cT06Path + "/infoRRA/despProcJud/vlrDespCustas")
							oModel:LoadValue( "MODEL_T06", "T06_VLRCUS", FTafGetVal( cT06Path + "/infoRRA/despProcJud/vlrDespCustas", "N", .F., @aIncons, .F. ) )
	 					EndIf

						If oDados:XPathHasNode(cT06Path + "/infoRRA/despProcJud/vlrDespAdvogados")
							oModel:LoadValue( "MODEL_T06", "T06_VLRADV", FTafGetVal( cT06Path + "/infoRRA/despProcJud/vlrDespAdvogados", "N", .F., @aIncons, .F. ) )
	 					EndIf					

						nV9N := 1
						cV9NPath := cT06Path + "/infoRRA/ideAdv[" + Alltrim(Str(nV9N)) + "]"

						If nOpc == 4 
							For n3 := 1 to oModel:GetModel( "MODEL_V9N" ):Length()
								oModel:GetModel( "MODEL_V9N" ):GoLine(n3)
								oModel:GetModel( "MODEL_V9N" ):DeleteLine()
							Next
						EndIf T3I

						While oDados:XPathHasNode(cV9NPath)
							oModel:GetModel( "MODEL_V9N" ):lValid:= .T.

							If nOpc == 4 .Or. nV9N > 1
								oModel:GetModel( "MODEL_V9N" ):AddLine()
							EndIf

							If oDados:XPathHasNode(	cV9NPath + "/tpInsc" )
								oModel:LoadValue( "MODEL_V9N", "V9N_TPINSC", FTafGetVal( cV9NPath + "/tpInsc"	, "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(	cV9NPath + "/nrInsc" )
								oModel:LoadValue( "MODEL_V9N", "V9N_NRINSC", FTafGetVal( cV9NPath + "/nrInsc"	, "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(	cV9NPath + "/vlrAdv" )
								oModel:LoadValue( "MODEL_V9N", "V9N_VLRADV", FTafGetVal( cV9NPath + "/vlrAdv"	, "N", .F., @aIncons, .F. ) )
							EndIf

							nV9N++
							cV9NPath := cT06Path + "/infoRRA/ideAdv[" + AllTrim(Str(nV9N)) + "]"
						EndDo

					EndIF	
					
					nT3G := 1
					cT3GPath := cT06Path + "/infoPerApur/ideEstabLot[" + AllTrim(Str(nT3G)) + "]"

					If nOpc == 4
						For nJ := 1 to oModel:GetModel( "MODEL_T3G" ):Length()
							oModel:GetModel( "MODEL_T3G" ):GoLine(nJ)
							oModel:GetModel( "MODEL_T3G" ):DeleteLine()
						Next nJ
					EndIf

					nT3G := 1
					While oDados:XPathHasNode(cT3GPath)

						If nOpc == 4 .Or. nT3G > 1
							oModel:GetModel( "MODEL_T3G" ):lValid:= .T.
							oModel:GetModel( "MODEL_T3G" ):AddLine()
						EndIf

						if oDados:XPathHasNode(cT3GPath + "/codLotacao")
							oModel:LoadValue( "MODEL_T3G", "T3G_LOTTRB", FGetIdInt( "codLotacao", "", cT3GPath + "/codLotacao",,,,@cInconMsg, @nSeqErrGrv))
						EndIf
						if oDados:XPathHasNode(	cT3GPath + "/tpInsc" , cT3GPath + "/nrInsc" )
							oModel:LoadValue( "MODEL_T3G", "T3G_ESTABE", FGetIdInt( "tpInsc", "nrInsc", cT3GPath + "/tpInsc" , cT3GPath + "/nrInsc",,,@cInconMsg, @nSeqErrGrv) )
						EndIf
						if oDados:XPathHasNode(cT3GPath + "/infoAgNocivo/grauExp")
							oModel:LoadValue( "MODEL_T3G", "T3G_GRAUEX", FGetIdInt( "grauExp", "", cT3GPath + "/infoAgNocivo/grauExp",,,,@cInconMsg, @nSeqErrGrv))
						Endif
						if oDados:XPathHasNode(cT3GPath + "/infoSimples/indSimples")
							oModel:LoadValue( "MODEL_T3G", "T3G_INDCSU", FTafGetVal( cT3GPath + "/infoSimples/indSimples", "C", .F., @aIncons, .F. ) )
						EndIf

						nT05 := 1
						cT05Path := cT3GPath + "/detVerbas[" + AllTrim(Str(nT05)) + "]"

						If nOpc == 4
							For nJ := 1 to oModel:GetModel( "MODEL_T05" ):Length()
								oModel:GetModel( "MODEL_T05" ):GoLine(nJ)
								oModel:GetModel( "MODEL_T05" ):DeleteLine()
							Next nJ
						EndIf

						nT05 := 1
						While oDados:XPathHasNode(cT05Path)

							If nOpc == 4 .Or. nT05 > 1
								oModel:GetModel( "MODEL_T05" ):lValid:= .T.
								oModel:GetModel( "MODEL_T05" ):AddLine()
							EndIf

							If oDados:XPathHasNode(	cT05Path + "/ideTabRubr")

								cIdTabR := TAFIdTabRub( FTafGetVal( cT05Path + "/ideTabRubr", "C", .F., @aIncons, .F. ), "T3M", FTafGetVal( cT05Path + "/codRubr", "C", .F., @aIncons, .F. ), cT05Path, @cInconMsg, @nSeqErrGrv, @aIncons  )

							Else
								cIdTabR := ""

								//Gera mensagem de erro
								TAFMsgIncons( @cInconMsg, @nSeqErrGrv,,, .T., 'ideTabRubr', cIdTabR, '', , '', '' )
							EndIf

							If TafColumnPos("T05_SEQUEN")
								oModel:LoadValue( "MODEL_T05", "T05_SEQUEN", StrZero( nT05, 3 ) )
							EndIf

							If oDados:xPathHasNode( cT05Path + "/codRubr" )
								cCodRubr := FGetIDInt( "codRubr", "ideTabRubr", FTAFGetVal( cT05Path + "/codRubr", "C", .F., @aIncons, .F. ), cIDTabR, .F.,, @cInconMsg, @nSeqErrGrv, /*9*/, /*10*/, /*11*/, /*12*/, /*13*/, SubStr( StrTran( cDtDeslig, "-", "" ), 1, 6 ) )
								oModel:LoadValue( "MODEL_T05", "T05_CODRUB", cCodRubr )
							Else
								cCodRubr := ""
							EndIf

							if oDados:XPathHasNode(cT05Path + "/qtdRubr" )
								If !lLaySimplif
									oModel:LoadValue( "MODEL_T05", "T05_QTDRUB", FTafGetVal( cT05Path + "/qtdRubr"                              , "N", .F., @aIncons, .F. ) )
								Else
									oModel:LoadValue( "MODEL_T05", "T05_SQTDRB", FTafGetVal( cT05Path + "/qtdRubr"                              , "N", .F., @aIncons, .F. ) )
								EndIf
							EndIf

							if oDados:XPathHasNode(cT05Path + "/fatorRubr" )
								oModel:LoadValue( "MODEL_T05", "T05_FATRUB", FTafGetVal( cT05Path + "/fatorRubr"                            , "N", .F., @aIncons, .F. ) )
							EndIf

							If !lLaySimplif
								if oDados:XPathHasNode(cT05Path + "/vrUnit")
									oModel:LoadValue( "MODEL_T05", "T05_VLRUNI", FTafGetVal( cT05Path + "/vrUnit"                              	, "N", .F., @aIncons, .F. ) )
								EndIf
							EndIf

							if oDados:XPathHasNode(cT05Path + "/vrRubr"  )
								oModel:LoadValue( "MODEL_T05", "T05_VLRRUB", FTafGetVal( cT05Path + "/vrRubr"                               , "N", .F., @aIncons, .F. ) )
							EndIf

							If lLaySimplif
								if oDados:XPathHasNode(cT05Path + "/indApurIR"  )
									oModel:LoadValue( "MODEL_T05", "T05_APURIR", FTafGetVal( cT05Path + "/indApurIR"                               , "C", .F., @aIncons, .F. ) )
								EndIf
							EndIf

							If lInfoRPT
								aRubrica := oReport:GetRubrica( cCodRubr )

								aAdd( aAnalitico, Array( 16 ) )
								nPosValores := Len( aAnalitico )

								aAnalitico[nPosValores][ANALITICO_MATRICULA]			:=	AllTrim( cMatric )
								aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:=	AllTrim( cCodCat )
								aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:=	AllTrim( FTAFGetVal( cT3GPath + "/tpInsc", "C", .F.,, .F. ) )
								aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:=	AllTrim( FTAFGetVal( cT3GPath + "/nrInsc", "C", .F.,, .F. ) )
								aAnalitico[nPosValores][ANALITICO_LOTACAO]				:=	AllTrim( FTAFGetVal( cT3GPath + "/codLotacao", "C", .F.,, .F. ) )
								aAnalitico[nPosValores][ANALITICO_NATUREZA]				:=	AllTrim( aRubrica[1] ) //Natureza
								aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:=	AllTrim( aRubrica[2] ) //Tipo
								aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:=	AllTrim( aRubrica[3] ) //Incidência CP
								aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:=	AllTrim( aRubrica[4] ) //Incidência IRRF
								aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:=	AllTrim( aRubrica[5] ) //Incidência FGTS
								aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:=	""
								aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:=	""
								aAnalitico[nPosValores][ANALITICO_VALOR]				:=	FTafGetVal( cT05Path + "/vrRubr", "N", .F.,, .F. )
							EndIf

							nT05++
							cT05Path := cT3GPath + "/detVerbas[" + AllTrim(Str(nT05)) + "]"
						EndDo

						If !lLaySimplif
							nT15 := 1
							cT15Path := cT3GPath + "/infoSaudeColet/detOper[" + AllTrim(Str(nT15)) + "]"

							If nOpc == 4
								For nJ := 1 to oModel:GetModel( "MODEL_T15" ):Length()
									oModel:GetModel( "MODEL_T15" ):GoLine(nJ)
									oModel:GetModel( "MODEL_T15" ):DeleteLine()
								Next nJ
							EndIf

							nT15 := 1
							While oDados:XPathHasNode(cT15Path)

								If nOpc == 4 .Or. nT15 > 1
									oModel:GetModel( "MODEL_T15" ):lValid:= .T.
									oModel:GetModel( "MODEL_T15" ):AddLine()
								EndIf

								if oDados:XPathHasNode(cT15Path + "/cnpjOper")
									oModel:LoadValue( "MODEL_T15", "T15_CNPJOP", FTafGetVal( cT15Path + "/cnpjOper"  	, "C", .F., @aIncons, .F. ) )
								EndIf

								if oDados:XPathHasNode(cT15Path + "/regANS")
									oModel:LoadValue( "MODEL_T15", "T15_REGANS", FTafGetVal( cT15Path + "/regANS"  		, "C", .F., @aIncons, .F. ) )
								EndIf

								if oDados:XPathHasNode(cT15Path + "/vrPgTit")
									oModel:LoadValue( "MODEL_T15", "T15_VLPGTI", FTafGetVal( cT15Path + "/vrPgTit"  	, "N", .F., @aIncons, .F. ) )
								EndIf

								oModel:LoadValue( "MODEL_T15", "T15_NOMEVE","S2299")

								nT16 := 1
								cT16Path := cT15Path + "/detPlano[" + AllTrim(Str(nT16)) + "]"

								If nOpc == 4
									For nJ := 1 to oModel:GetModel( "MODEL_T16" ):Length()
										oModel:GetModel( "MODEL_T16" ):GoLine(nJ)
										oModel:GetModel( "MODEL_T16" ):DeleteLine()
									Next nJ
								EndIf

								nT16 := 1
								While oDados:XPathHasNode(cT16Path)

									If nOpc == 4 .Or. nT16 > 1
										oModel:GetModel( "MODEL_T16" ):lValid:= .T.
										oModel:GetModel( "MODEL_T16" ):AddLine()
									EndIf

									oModel:LoadValue( "MODEL_T16", "T16_SEQUEN", STRZERO(nT16,3) )

									If oDados:xPathHasNode( cT16Path + "/tpDep" )
										oModel:LoadValue( "MODEL_T16", "T16_TPDEP", FGetIdInt( "tpDep", "", cT16Path + "/tpDep",,,, @cInconMsg, @nSeqErrGrv ) )
									EndIf
									if oDados:XPathHasNode(cT16Path + "/cpfDep")
										oModel:LoadValue( "MODEL_T16", "T16_CPFDEP", FTafGetVal( cT16Path 	+ "/cpfDep" 	, "C", .F., @aIncons, .F. ) )
									EndIf
									if oDados:XPathHasNode(cT16Path + "/dtNascto")
										oModel:LoadValue( "MODEL_T16", "T16_DTNDEP", FTafGetVal( cT16Path 	+ "/dtNascto" , "D", .F., @aIncons, .F. ) )
									EndIf
									if oDados:XPathHasNode(cT16Path + "/nmDep")
										oModel:LoadValue( "MODEL_T16", "T16_NOMDEP", FTafGetVal( cT16Path 	+ "/nmDep" 	, "C", .F., @aIncons, .F. ) )
									EndIf
									if oDados:XPathHasNode(cT16Path + "/vlrPgDep")
										oModel:LoadValue( "MODEL_T16", "T16_VPGDEP", FTafGetVal( cT16Path 	+ "/vlrPgDep"	, "N", .F., @aIncons, .F. ) )
									EndIf
									oModel:LoadValue( "MODEL_T16", "T16_NOMEVE","S2299")

									nT16++
									cT16Path := cT15Path + "/detPlano[" + AllTrim(Str(nT16)) + "]"
								EndDo

								nT15++
								cT15Path := cT3GPath + "/infoSaudeColet/detOper[" + AllTrim(Str(nT15)) + "]"
							EndDo
						EndIf

						nT3G++
						cT3GPath := cT06Path + "/infoPerApur/ideEstabLot[" + AllTrim(Str(nT3G)) + "]"
					EndDo

					nT5I := 1
					cT5IPath := cT06Path + "/infoPerAnt/ideADC[" + AllTrim(Str(nT5I)) + "]"


					If nOpc == 4
						For nJ := 1 to oModel:GetModel( "MODEL_T5I" ):Length()
							oModel:GetModel( "MODEL_T5I" ):GoLine(nJ)
							oModel:GetModel( "MODEL_T5I" ):DeleteLine()
						Next nJ
					EndIf

					nT5I := 1
					While oDados:XPathHasNode(cT5IPath)

						If nOpc == 4 .Or. nT5I > 1
							oModel:GetModel( "MODEL_T5I" ):lValid:= .T.
							oModel:GetModel( "MODEL_T5I" ):AddLine()
						EndIf

						if oDados:XPathHasNode(cT5IPath + "/dtAcConv")
							oModel:LoadValue( "MODEL_T5I", "T5I_DTACCO", FTafGetVal( cT5IPath + "/dtAcConv", "D", .F., @aIncons, .F. ))
						EndIf

						if oDados:XPathHasNode(cT5IPath + "/tpAcConv")
							oModel:LoadValue( "MODEL_T5I", "T5I_TPACCO", changeAcConv(FTafGetVal( cT5IPath + "/tpAcConv", "C", .F., @aIncons, .F. ),2))
						EndIf

						If !lLaySimplif
							if oDados:XPathHasNode( cT5IPath + "/compAcConv")
								oModel:LoadValue( "MODEL_T5I", "T5I_COMPAC"	, StrTran(FTafGetVal( cT5IPath + "/compAcConv", "C", .F., @aIncons, .F. ), "-", "" ))
							EndIf

							if oDados:XPathHasNode(cT5IPath + "/dtEfAcConv")
								oModel:LoadValue( "MODEL_T5I", "T5I_DTEFAC", FTafGetVal( cT5IPath + "/dtEfAcConv", "D", .F., @aIncons, .F. ))
							EndIf
						EndIf

						if oDados:XPathHasNode(cT5IPath + "/dsc")
							oModel:LoadValue( "MODEL_T5I", "T5I_DSC", FTafGetVal( cT5IPath + "/dsc", "C", .F., @aIncons, .F. ))
						EndIf

						nT5J := 1
						cT5JPath := cT5IPath + "/idePeriodo[" + AllTrim(Str(nT5J)) + "]"

						If nOpc == 4
							For nJ := 1 to oModel:GetModel( "MODEL_T5J" ):Length()
								oModel:GetModel( "MODEL_T5J" ):GoLine(nJ)
								oModel:GetModel( "MODEL_T5J" ):DeleteLine()
							Next nJ

						EndIf

						nT5J := 1
						While oDados:XPathHasNode(cT5JPath)

							If nOpc == 4 .Or. nT5J > 1
								oModel:GetModel( "MODEL_T5J" ):lValid:= .T.
								oModel:GetModel( "MODEL_T5J" ):AddLine()
							EndIf


							if oDados:XPathHasNode(cT5JPath + "/perRef")
								oModel:LoadValue( "MODEL_T5J", "T5J_PERREF", Strtran(FTafGetVal( cT5JPath + "/perRef" , "C", .F., @aIncons, .F. ),"-",""))
							EndIf

							nT5Q := 1
							cT5QPath := cT5JPath + "/ideEstabLot[" + AllTrim(Str(nT5Q)) + "]"

							If nOpc == 4
								For nJ := 1 to oModel:GetModel( "MODEL_T5Q" ):Length()
									oModel:GetModel( "MODEL_T5Q" ):GoLine(nJ)
									oModel:GetModel( "MODEL_T5Q" ):DeleteLine()
								Next nJ
							EndIf

							nT5Q := 1
							While oDados:XPathHasNode(cT5QPath)

								If nOpc == 4 .Or. nT5Q > 1
									oModel:GetModel( "MODEL_T5Q" ):lValid:= .T.
									oModel:GetModel( "MODEL_T5Q" ):AddLine()
								EndIf

								if oDados:XPathHasNode(cT5QPath + "/codLotacao")
									oModel:LoadValue( "MODEL_T5Q", "T5Q_LOTTRB", FGetIdInt( "codLotacao", "", cT5QPath + "/codLotacao",,,,@cInconMsg, @nSeqErrGrv))
								EndIf
								if oDados:XPathHasNode(	cT5QPath + "/tpInsc" , cT5QPath + "/nrInsc" )
									oModel:LoadValue( "MODEL_T5Q", "T5Q_ESTABE", FGetIdInt( "tpInsc", "nrInsc", cT5QPath + "/tpInsc" , cT5QPath + "/nrInsc",,,@cInconMsg, @nSeqErrGrv) )
								EndIf
								if oDados:XPathHasNode(cT5QPath + "/infoAgNocivo/grauExp")
									oModel:LoadValue( "MODEL_T5Q", "T5Q_GRAUEX", FGetIdInt( "grauExp", "", cT5QPath + "/infoAgNocivo/grauExp",,,,@cInconMsg, @nSeqErrGrv))
								Endif
								if oDados:XPathHasNode(cT5QPath + "/infoSimples/indSimples")
									oModel:LoadValue( "MODEL_T5Q", "T5Q_INDCSU", FTafGetVal( cT5QPath + "/infoSimples/indSimples", "C", .F., @aIncons, .F. ) )
								EndIf

								nT5S := 1
								cT5SPath := cT5QPath + "/detVerbas[" + AllTrim(Str(nT5S)) + "]"

								If nOpc == 4
									For nJ := 1 to oModel:GetModel( "MODEL_T5S" ):Length()
										oModel:GetModel( "MODEL_T5S" ):GoLine(nJ)
										oModel:GetModel( "MODEL_T5S" ):DeleteLine()
									Next nJ
								EndIf

								nT5S := 1
								While oDados:XPathHasNode(cT5SPath)

									If nOpc == 4 .Or. nT5S > 1
										oModel:GetModel( "MODEL_T5S" ):lValid:= .T.
										oModel:GetModel( "MODEL_T5S" ):AddLine()
									EndIf

									If oDados:XPathHasNode(	cT5SPath + "/ideTabRubr")
										cIdTabR := TAFIdTabRub( FTafGetVal( cT5SPath + "/ideTabRubr", "C", .F., @aIncons, .F. ), "T3M", FTafGetVal( cT5SPath + "/codRubr", "C", .F., @aIncons, .F. ), cT5SPath, @cInconMsg, @nSeqErrGrv, @aIncons  )

									Else
										cIdTabR := ""

										//Gera mensagem de erro
										TAFMsgIncons( @cInconMsg, @nSeqErrGrv,,, .T., 'ideTabRubr', cIdTabR, '', , '', '' )
									EndIf

									If oDados:xPathHasNode( cT5SPath + "/codRubr" )
										cCodRubr := FGetIDInt( "codRubr", "ideTabRubr", FTAFGetVal( cT5SPath + "/codRubr", "C", .F., @aIncons, .F. ), cIDTabR, .F.,, @cInconMsg, @nSeqErrGrv, /*9*/, /*10*/, /*11*/, /*12*/, /*13*/, SubStr( StrTran( cDtDeslig, "-", "" ), 1, 6 ) )
										oModel:LoadValue( "MODEL_T5S", "T5S_CODRUB", cCodRubr )
									Else
										cCodRubr := ""
									EndIf

									if oDados:XPathHasNode(cT5SPath + "/qtdRubr" )
										If !lLaySimplif
											oModel:LoadValue( "MODEL_T5S", "T5S_QTDRUB", FTafGetVal( cT5SPath + "/qtdRubr"                              , "N", .F., @aIncons, .F. ) )
										Else
											oModel:LoadValue( "MODEL_T5S", "T5S_SQTDRB", FTafGetVal( cT5SPath + "/qtdRubr"                              , "N", .F., @aIncons, .F. ) )
										EndIf
									EndIf

									if oDados:XPathHasNode(cT5SPath + "/fatorRubr" )
										oModel:LoadValue( "MODEL_T5S", "T5S_FATRUB", FTafGetVal( cT5SPath + "/fatorRubr"                            , "N", .F., @aIncons, .F. ) )
									EndIf

									If !lLaySimplif
										if oDados:XPathHasNode(cT5SPath + "/vrUnit")
											oModel:LoadValue( "MODEL_T5S", "T5S_VLRUNI", FTafGetVal( cT5SPath + "/vrUnit"                              	, "N", .F., @aIncons, .F. ) )
										EndIf
									EndIf

									if oDados:XPathHasNode(cT5SPath + "/vrRubr"  )
										oModel:LoadValue( "MODEL_T5S", "T5S_VLRRUB", FTafGetVal( cT5SPath + "/vrRubr"                               , "N", .F., @aIncons, .F. ) )
									EndIf

									If lLaySimplif
										if oDados:XPathHasNode(cT5SPath + "/indApurIR"  )
											oModel:LoadValue( "MODEL_T5S", "T5S_APURIR", FTafGetVal( cT5SPath + "/indApurIR"                           , "C", .F., @aIncons, .F. ) )
										EndIf
									EndIf

									If lInfoRPT
										aRubrica := oReport:GetRubrica( cCodRubr )

										aAdd( aAnalitico, Array( 16 ) )
										nPosValores := Len( aAnalitico )

										aAnalitico[nPosValores][ANALITICO_MATRICULA]			:=	AllTrim( cMatric )
										aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:=	AllTrim( cCodCat )
										aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:=	AllTrim( FTAFGetVal( cT5QPath + "/tpInsc", "C", .F.,, .F. ) )
										aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:=	AllTrim( FTAFGetVal( cT5QPath + "/nrInsc", "C", .F.,, .F. ) )
										aAnalitico[nPosValores][ANALITICO_LOTACAO]				:=	AllTrim( FTAFGetVal( cT5QPath + "/codLotacao", "C", .F.,, .F. ) )
										aAnalitico[nPosValores][ANALITICO_NATUREZA]				:=	AllTrim( aRubrica[1] ) //Natureza
										aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:=	AllTrim( aRubrica[2] ) //Tipo
										aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:=	AllTrim( aRubrica[3] ) //Incidência CP
										aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:=	AllTrim( aRubrica[4] ) //Incidência IRRF
										aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:=	AllTrim( aRubrica[5] ) //Incidência FGTS
										aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:=	""
										aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:=	""
										aAnalitico[nPosValores][ANALITICO_VALOR]				:=	FTafGetVal( cT5SPath + "/vrRubr", "N", .F.,, .F. )
									EndIf

									nT5S ++
									cT5SPath := cT5QPath + "/detVerbas[" + AllTrim(Str(nT5S)) + "]"
								EndDo

								nT5Q++
								cT5QPath := cT5JPath + "/ideEstabLot[" + AllTrim(Str(nT5Q)) + "]"
							EndDo

							nT5J++
							cT5JPath := cT5IPath + "/idePeriodo[" + AllTrim(Str(nT5J)) + "]"
						EndDo

						nT5I++
						cT5IPath := cT06Path + "/infoPerAnt/ideADC[" + AllTrim(Str(nT5I)) + "]"
					EndDo

					If !lLaySimplif
						nT88 := 1
						cT88Path := cT06Path + "/infoTrabInterm[" + AllTrim( Str( nT88 ) ) + "]"

						If nOpc == 4
							For nJ := 1 to oModel:GetModel( "MODEL_T88" ):Length()
								oModel:GetModel( "MODEL_T88" ):GoLine( nJ )
								oModel:GetModel( "MODEL_T88" ):DeleteLine()
							Next nJ
						EndIf

						While oDados:xPathHasNode( cT88Path )
							If nOpc == 4 .or. nT88 > 1
								oModel:GetModel( "MODEL_T88" ):lValid := .T.
								oModel:GetModel( "MODEL_T88" ):AddLine()
							EndIf

							If oDados:xPathHasNode( cT88Path + "/codConv" )
								oModel:LoadValue( "MODEL_T88", "T88_IDCODC", FGetIdInt( "codConv", "", cIdFunc, FTafGetVal( cT88Path + "/codConv", "C", .F., @aIncons, .F. ),.F.,, @cInconMsg, @nSeqErrGrv ) )
							EndIf

							nT88 ++
							cT88Path := cT06Path + "/infoTrabInterm[" + AllTrim( Str( nT88 ) ) + "]"
						EndDo
					EndIf

					nT06++
					cT06Path := cCabec + "infoDeslig/verbasResc/dmDev[" + AllTrim(Str(nT06)) + "]"
				EndDo

				nT3H := 1
				cT3HPath := cCabec + "infoDeslig/verbasResc/procJudTrab[" + AllTrim(Str(nT3H)) + "]"

				If nOpc == 4
					For nJ := 1 to oModel:GetModel( "MODEL_T3H" ):Length()
						oModel:GetModel( "MODEL_T3H" ):GoLine(nJ)
						oModel:GetModel( "MODEL_T3H" ):DeleteLine()
					Next nJ
				EndIf

				nT3H := 1
				While oDados:XPathHasNode(cT3HPath)

					If nOpc == 4 .Or. nT3H > 1
						oModel:GetModel( "MODEL_T3H" ):lValid:= .T.
						oModel:GetModel( "MODEL_T3H" ):AddLine()
					EndIf
					if oDados:XPathHasNode(cT3HPath + "/tpTrib")
						oModel:LoadValue( "MODEL_T3H", "T3H_TPTRIB", FTafGetVal( cT3HPath + "/tpTrib"	 , "C", .F., @aIncons, .F. ) )
					EndIf

					If oDados:XPathHasNode(cT3HPath + "/nrProcJud")
						cIdProc := FGetIdInt( "nrProcJ", , cT3HPath + "/nrProcJud",,,,@cInconMsg, @nSeqErrGrv)
						oModel:LoadValue("MODEL_T3H", "T3H_IDPROC", cIdProc )
					EndIf

					If !Empty(cIdProc)
						If oDados:XPathHasNode(cT3HPath + "/codSusp" )
							oModel:LoadValue("MODEL_T3H", "T3H_IDSUSP", FGetIdInt( "codSusp","",FTafGetVal( cT3HPath + "/codSusp", "C", .F., @aIncons, .F. ),cIdProc,.F.,,@cInconMsg, @nSeqErrGrv) )
						EndIf
					EndIf

					oModel:LoadValue( "MODEL_T3H", "T3H_NOMEVE","S2299")

					nT3H++
					cT3HPath := cCabec + "infoDeslig/verbasResc/procJudTrab[" + AllTrim(Str(nT3H)) + "]"
				EndDo

				oModel:LoadValue("MODEL_CMD", "CMD_INDMV", FTafGetVal(cCabec + "infoDeslig/verbasResc/infoMV/indMV" , "C", .F., @aIncons, .F. ))

				nC9J := 1
				cC9JPath := cCabec + "infoDeslig/verbasResc/infoMV/remunOutrEmpr[" + AllTrim(Str(nC9J)) + "]"

				If nOpc == 4
					For n3 := 1 to oModel:GetModel( "MODEL_C9J" ):Length()
						oModel:GetModel( "MODEL_C9J" ):GoLine( n3 )
						oModel:GetModel( "MODEL_C9J" ):DeleteLine()
					Next n3
				EndIf

				//Rodo o XML parseado para gravar as novas informacoes no GRID ( Cadastro de Descrição da Atividade )
				nC9J := 1
				While oDados:XPathHasNode(cC9JPath)

					oModel:GetModel( "MODEL_C9J" ):lValid:= .T.

					If nOpc == 4 .or. nC9J > 1
						oModel:GetModel( "MODEL_C9J" ):AddLine()
					EndIf

					if oDados:XPathHasNode(cC9JPath + "/tpInsc")
						oModel:LoadValue( "MODEL_C9J", "C9J_TPINSC", FTafGetVal( cC9JPath + "/tpInsc"	, "C", .F., @aIncons, .F. ) )
					EndIf

					if oDados:XPathHasNode(cC9JPath + "/nrInsc")
						oModel:LoadValue( "MODEL_C9J", "C9J_NRINSC", FTafGetVal( cC9JPath + "/nrInsc"  ,"C", .F., @aIncons, .F. ) )
					EndIf

					if oDados:XPathHasNode(cC9JPath + "/codCateg")
						oModel:LoadValue( "MODEL_C9J", "C9J_CODCAT",  FGetIdInt( "codCateg", "", cC9JPath + "/codCateg",,,,@cInconMsg, @nSeqErrGrv ) )
					EndIf

					if oDados:XPathHasNode(cC9JPath + "/vlrRemunOE")
						oModel:LoadValue( "MODEL_C9J", "C9J_VLREMU", FTafGetVal( cC9JPath + "/vlrRemunOE","N", .F., @aIncons, .F. ) )
					EndIf

					oModel:LoadValue( "MODEL_C9J", "C9J_NOMEVE", "S2299" )

					nC9J++
					cC9JPath := cCabec + "infoDeslig/verbasResc/infoMV/remunOutrEmpr[" + AllTrim(Str(nC9J)) + "]"
				EndDo

				nV1M := 1
				cV1MPath := cCabec + "infoDeslig/observacoes[" + AllTrim(Str(nV1M)) + "]"

				If nOpc == 4
					For nJ := 1 to oModel:GetModel( "MODEL_V1M" ):Length()
						oModel:GetModel( "MODEL_V1M" ):GoLine(nJ)
						oModel:GetModel( "MODEL_V1M" ):DeleteLine()
					Next nJ
				EndIf

				//Rodo o XML parseado para gravar as novas informacoes no GRID ( Cadastro de Descrição da Atividade )
				nV1M := 1
				While oDados:XPathHasNode(cV1MPath)

					oModel:GetModel( "MODEL_V1M" ):lValid:= .T.

					If nOpc == 4 .or. nV1M > 1
						oModel:GetModel( "MODEL_V1M" ):AddLine()
					EndIf

					oModel:LoadValue( "MODEL_V1M", "V1M_CODOBS", STRZERO(nV1M,6)  )

					If oDados:XPathHasNode(cV1MPath + "/observacao")
						oModel:LoadValue( "MODEL_V1M", "V1M_OBSERV", FTafGetVal( cV1MPath + "/observacao"	, "C", .F., @aIncons, .F. ) )
					EndIf

					oModel:LoadValue( "MODEL_V1M", "V1M_NOMEVE", "S2299" )

					nV1M++
					cV1MPath := cCabec + "infoDeslig/observacoes[" + AllTrim(Str(nV1M)) + "]"
				EndDo

				nV1N := 1
				cV1NPath := cCabec + "infoDeslig/consigFGTS[" + AllTrim(Str(nV1N)) + "]"

				If nOpc == 4
					For nJ := 1 to oModel:GetModel( "MODEL_V1N" ):Length()
						oModel:GetModel( "MODEL_V1N" ):GoLine(nJ)
						oModel:GetModel( "MODEL_V1N" ):DeleteLine()
					Next nJ
				EndIf

				nV1N := 1
				While oDados:XPathHasNode(cV1NPath)

					oModel:GetModel( "MODEL_V1N" ):lValid:= .T.

					If nOpc == 4 .or. nV1N > 1
						oModel:GetModel( "MODEL_V1N" ):AddLine()
					EndIf

					If oDados:XPathHasNode(cV1NPath + "/insConsig")
						oModel:LoadValue( "MODEL_V1N", "V1N_INSCSG", FTafGetVal( cV1NPath + "/insConsig"	, "C", .F., @aIncons, .F. ) )
					EndIf

					If oDados:XPathHasNode(cV1NPath + "/nrContr")
						oModel:LoadValue( "MODEL_V1N", "V1N_NRCONT", FTafGetVal( cV1NPath + "/nrContr"	, "C", .F., @aIncons, .F. ) )
					EndIf

					oModel:LoadValue( "MODEL_V1N", "V1N_NOMEVE", "S2299" )

					nV1N++
					cV1NPath := cCabec + "infoDeslig/consigFGTS[" + AllTrim(Str(nV1N)) + "]"
				EndDo

			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetiva a operacao desejada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(cInconMsg) .And. Empty(aIncons)
				xChkDupl := TafFormCommit( oModel, .T. )
				If ValType( xChkDupl ) == "A"
					If xChkDupl[1]
						Aadd(aIncons, "ERRO19" + "|" + xChkDupl[2] + "|" + xChkDupl[3])
					Else
						lRet := .T.
					EndIf
				ElseIf ValType( xChkDupl ) == "L"
					If xChkDupl
						Aadd(aIncons, "ERRO19" )
					Else
						lRet := .T.
					EndIf
				EndIf

				If lRet .and. lInfoRPT
					oInfoRPT := oReport:oVOReport
					oInfoRPT:SetIndApu( "1" )
					oInfoRPT:SetPeriodo( SubStr( StrTran( cDtDeslig, "-", "" ), 1, 6 ) )
					oInfoRPT:SetCPF( AllTrim( FTAFGetVal( cCabec + "/ideVinculo/cpfTrab", "C", .F.,, .T. ) ) )
					oInfoRPT:SetNome( cNome )
					oInfoRPT:SetAnalitico( aAnalitico )

					oReport:UpSert( "S-2299", "1", xFilial( "CMD" ), oInfoRPT )

					oInfoRPT:SetIndApu( "1" )
					oInfoRPT:SetPeriodo( SubStr( StrTran( cDtDeslig, "-", "" ), 1, 6 ) )
					oInfoRPT:SetCPF( AllTrim( FTAFGetVal( cCabec + "/ideVinculo/cpfTrab", "C", .F.,, .T. ) ) )
					oInfoRPT:SetNome( cNome )
					oInfoRPT:SetAnalitico( aAnalitico )

					oReport:UpSert( "S-2299", "2", xFilial( "CMD" ), oInfoRPT )
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
/*/{Protheus.doc} TAF266Xml

Funcao de geracao do XML para atender o registro S-2299
Quando a rotina for chamada o registro deve estar posicionado

@Param:
cAlias		-	Alias da tabela
nRecno		-	Recno do registro corrente
nOpc		-	Operação a ser realizada
lJob		-	Informa se foi chamado por job
lRemEmp		-	Exclusivo do Evento S-1000
cSeqXml		-	Número sequencial para composição da chave ID do XML
lInfoRPT	-	Indica se a geração de XML deve gerar informações na tabela de relatório

@Return:
cXml - Estrutura do Xml do Layout S-2299

@author Felipe C. Seolin
@since 18/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF266Xml( cAlias as Character, nRecno as Numeric, nOpc as Numeric, lJob as Logical,; 
					lRemEmp as Logical, cSeqXml as Character, lInfoRPT as Logical)

	Local cXml        	as Character
	Local cLayout     	as Character
	Local cReg        	as Character
	Local cXmlIdeEst  	as Character
	Local cXmlDetVerb 	as Character
	Local cXmlDPlan   	as Character
	Local cXmlSaude   	as Character
	Local cXmlIdeABC  	as Character
	Local cXmlNocivo  	as Character
	Local cXmlISimp   	as Character
	Local cXmlProcJud 	as Character
	Local cXmlInfMV   	as Character
	Local cXmlIdePer  	as Character
	Local cXmlEstLot  	as Character
	Local cXmlDev     	as Character
	Local cXmlInterm  	as Character
	Local cPerRef     	as Character
	Local cXmlProccs  	as Character
	Local cNIS        	as Character
	Local cMVIDETABR  	as Character
	Local cEsocial    	as Character
	Local cXMLProJud	as character
	Local cXMLIdeAdv	as character
	Local lRubERPPad  	as Logical
	Local lXmlVLd     	as Logical

	//Relatório de Conferência de Valores
	Local oInfoRPT    	as Object
	Local cCPF        	as Character
	Local cNome       	as Character
	Local cMatric     	as Character
	Local cCodCat     	as Character
	Local aAnalitico  	as Array
	Local aRubrica    	as Array
	Local nPosValores 	as Numeric
	Local cFilBkp     	as Character

	Default cAlias   	:= ""
	Default nRecno   	:= 1
	Default nOpc     	:= 1
	Default lJob     	:= .F.
	Default lInfoRPT 	:= .F.

	cXml             	:= ""
	cLayout          	:= "2299"
	cReg             	:= "Deslig"
	cXmlIdeEst       	:= ""
	cXmlDetVerb      	:= ""
	cXmlDPlan        	:= ""
	cXmlSaude        	:= ""
	cXmlIdeABC       	:= ""
	cXmlNocivo       	:= ""
	cXmlISimp        	:= ""
	cXmlProcJud      	:= ""
	cXmlInfMV        	:= ""
	cXmlIdePer       	:= ""
	cXmlEstLot       	:= ""
	cXmlDev          	:= ""
	cXMLProJud			:= ""
	cXMLIdeAdv			:= ""
	cXmlInterm       	:= ""
	cPerRef          	:= ""
	cXmlProccs       	:= ""
	cNIS             	:= ""
	cMVIDETABR       	:= SuperGetMV("MV_IDETABR",.F.,"0")
	cEsocial         	:= SuperGetMV("MV_TAFVLES")
	lRubERPPad       	:= .T.
	lXmlVLd          	:= IIF(FindFunction( 'TafXmlVLD' ),TafXmlVLD( 'TAF266XML' ),.T.)
	oInfoRPT         	:= Nil
	cCPF             	:= ""
	cNome            	:= ""
	cMatric          	:= ""
	cCodCat          	:= ""
	aAnalitico       	:= {}
	aRubrica         	:= {}
	nPosValores      	:= 0
	cFilBkp          	:= cFilAnt

	If lXmlVLd
		If TAFColumnPos("CMD_LAYOUT") .And. !Empty(AllTrim(CMD->CMD_LAYOUT))
			cEsocial := AllTrim(CMD->CMD_LAYOUT)
		EndIf
		
		SetLayout()

		If IsInCallStack("TafNewBrowse") .And. ( CMD->CMD_FILIAL <> cFilAnt ).AND.!Empty(CMD->CMD_FILIAL)
			cFilAnt := CMD->CMD_FILIAL
		EndIf

		If IsInCallStack("TAFA266") .AND. (IsInCalLStack("TAFXmlLote") .OR. IsInCallStack("TAF266Xml"))	//Execução Manual
			If slRubERPPad == Nil
				lRubERPPad := cMVIDETABR == "1" .OR. (cMVIDETABR == "0" .and. ApMsgYesNo("Deseja gerar o conteúdo da tag 'ideTabRubr' com o código padrão deste ERP ou conforme ERP de Origem?"+CRLF+" - Sim para código padrão(C8R_IDTBRU)."+CRLF+" - Não para conforme ERP de Origem (T3M_CODERP).","Conteúdo 'ideTabRubr' padrão?"))
				If IsInCalLStack("TAFXmlLote")
					slRubERPPad	:= lRubERPPad
				EndIf
			Else
				lRubERPPad	:= slRubERPPad
			EndIf
		EndIf

		dBSelectArea("C9V")
		C9V->(dBSetOrder(2))

		dBSelectArea("T06")
		T06->(dBSetOrder(1))

		dBSelectArea("T3G")
		T3G->(dBSetOrder(1)) //T3G_FILIAL+T3G_ID+T3G_VERSAO+T3G_RECPAG+T3G_PERREF

		If lSimplBeta .And. TafColumnPos("T06_INDRRA")
			DBSelectArea("V9N")
			V9N->(DBSetOrder(1))
		EndIf

		dBSelectArea("T05")
		T05->(dBSetOrder(1)) //T05_FILIAL+T05_ID+T05_VERSAO+T05_RECPAG+T05_TPINSC+T05_NRINSC+T05_LOTTRB+T05_TPPER

		DBSelectArea("T15")
		T15->(DBSetOrder(1)) //T15_FILIAL+T15_ID+T15_VERSAO+T15_RECIBO+T15_ESTABE+T15_LOTACA+T15_CNPJOP+T15_REGANS

		DBSelectArea("T16")
		T16->(DBSetOrder(1)) //T16_FILIAL+T16_ID+T16_VERSAO+T16_RECIBO+T16_ESTABE+T16_LOTACA+T16_CNPJOP+T16_REGANS+T16_SEQUEN

		dBSelectArea("T5I")
		T5I->(dBSetOrder(1)) //T5I_FILIAL+T5I_ID+T5I_VERSAO+T5I_IDEDMD+DTOS(T5I_DTACCO)+T5I_TPACCO

		dBSelectArea("T5J")
		T5J->(dBSetOrder(1)) //T5J_FILIAL+T5J_ID+T5J_VERSAO+T5J_IDEDMD+DTOS(T5J_DTACCO)+T5J_TPACCO+T5J_PERREF

		dBSelectArea("T5Q")
		T5Q->(dBSetOrder(1)) //T3G_FILIAL+T3G_ID+T3G_VERSAO+T5Q_IDEDMD+DTOS(T3G_DTACCO)+T3G_TPACCO+T3G_PERREF+T3G_TPPER

		dBSelectArea("T5S")
		T5S->(dBSetOrder(1)) //T05_FILIAL+T05_ID+T05_VERSAO+T5S_IDEDMD+DTOS(T05_DTACCO)+T05_TPACCO+T05_PERREF+T05_TPINSC+T05_NRINSC+T05_LOTTRB+T05_TPPER

		DBSelectArea("T88")
		T88->(DBSetOrder(1)) //T88_FILIAL+T88_ID+T88_VERSAO+T88_IDEDMD+T88_IDCODC

		dBSelectArea("V1M")
		V1M->(dBSetOrder(1)) //V1M_FILIAL+V1M_ID+V1M_VERSAO+V1M_CODOBS

		DBSelectArea("V1N")
		V1N->(DBSetOrder(1)) //V1N_FILIAL+V1N_ID+V1N_VERSAO+V1N_INSCSG+V1N_NRCONT

		//Verifica se existe as classes necessárias para utilização do relatório persistido
		If lInfoRPT
			If __lGrvRPT == Nil
				TAF266Rpt() //Inicializa a variável static __lGrvRPT
			EndIf

			lInfoRPT := __lGrvRPT
		EndIf

		If lInfoRPT
			If oReport == Nil
				oReport := TAFSocialReport():New()
			EndIf
		EndIf

		cXml +=	"<ideVinculo>"

		If nTamCMDFunc == Nil
			nTamCMDFunc := GetSX3Cache("CMD_FUNC", "X3_TAMANHO")
		EndIf

		If C9V->( MSSeek( xFilial( "C9V" ) + PadR(CMD->CMD_FUNC, nTamCMDFunc) + "1" ) )

			If !lLaySimplif
				cNIS := TAF250Nis( C9V->C9V_FILIAL, C9V->C9V_ID, C9V->C9V_NIS, DToS( CMD->CMD_DTDESL ), C9V->C9V_NOMEVE )
			EndIf

			cXml +=	xTafTag( "cpfTrab", C9V->C9V_CPF )

			If !lLaySimplif
				cXml +=	xTafTag( "nisTrab", cNIS )
			EndIf

			cXml +=	xTafTag( "matricula", C9V->C9V_MATRIC )

			If lInfoRPT

				cCPF	:=	C9V->C9V_CPF
				cNome	:=	C9V->C9V_NOME
				cMatric	:=	C9V->C9V_MATRIC

				DBSelectArea( "CUP" )
				CUP->( DBSetOrder( 1 ) )
				If CUP->( MsSeek( xFilial( "CUP" ) + C9V->C9V_ID ) )

					DBSelectArea( "C87" )
					C87->( DBSetOrder( 1 ) )
					If C87->( MsSeek( xFilial( "C87" ) + AllTrim( CUP->CUP_CODCAT ) ) )
						cCodCat := C87->C87_CODIGO
					EndIf

				EndIf

			EndIf

		EndIf

		cXml +=	"</ideVinculo>"
		cXml +=	"<infoDeslig>"
		cXml +=		xTafTag("mtvDeslig",Posicione("C8O",1,xFilial("C8O") + CMD->CMD_MOTDES,"C8O_CODIGO"))
		cXml +=		xTafTag("dtDeslig",CMD->CMD_DTDESL)

		If lLaySimplif
			cXml +=		xTafTag("dtAvPrv", CMD->CMD_DTAVPR,, .T.)
		EndIf

		cXml +=		xTafTag("indPagtoAPI",xFunTrcSN(CMD->CMD_INDPAG))
		cXml +=		xTafTag("dtProjFimAPI",CMD->CMD_TERAPI,,.T.)

		If !lLaySimplif
			cXml +=		xTafTag("pensAlim",CMD->CMD_PENALI,,.F.)
		Else
			cXml +=		xTafTag("pensAlim",CMD->CMD_PENALI,,.T.)
		EndIf

		cXml +=		xTafTag("percAliment",CMD->CMD_PERALI,PesqPict("CMD","CMD_PERALI"),.T.)
		cXml +=		xTafTag("vrAlim",CMD->CMD_VLPALI,PesqPict("CMD","CMD_VLPALI"),Iif(CMD->CMD_PENALI $ "2|3", .F., .T.),,Iif(CMD->CMD_PENALI $ "2|3", .T., .F.))

		If !lLaySimplif
			cXml +=		xTafTag("nrCertObito",CMD->CMD_NRATES,,.T.)
		EndIf

		cXml +=		xTafTag("nrProcTrab",CMD->CMD_NRPROC,,.T.)

		If !lLaySimplif

			cXml +=		xTafTag("indCumprParc",CMD->CMD_INDCUM,,.T.)

		Else

			//V6D - Informações relativas ao trabalho intermitente *Start
			If V6D->( MsSeek( xFilial( "V6D" ) + CMD->( CMD_ID + CMD_VERSAO ) ) )

				While V6D->( !Eof() ) .and. V6D->( V6D_FILIAL + V6D_ID + V6D_VERSAO ) == xFilial( "V6D" ) + CMD->( CMD_ID + CMD_VERSAO ) .AND. !Empty(V6D->V6D_DIA)

					cXml +=	"<infoInterm>"
					cXml +=		xTafTag("dia", V6D->V6D_DIA,,.F.)
					cXml +=	"</infoInterm>"

					V6D->( DBSkip() )

				EndDo	

			EndIf

		EndIf

		If !lLaySimplif
			cXml +=	xTafTag("qtdDiasInterm",CMD->CMD_QTDDIA,,.T.)
		EndIf

		//V1M - *Start
		If V1M->( MsSeek( xFilial( "V1M" ) + CMD->( CMD_ID + CMD_VERSAO ) ) )

			While V1M->( !Eof() ) .and. V1M->( V1M_FILIAL + V1M_ID + V1M_VERSAO ) == xFilial( "V1M" ) + CMD->( CMD_ID + CMD_VERSAO ) .AND. !Empty(V1M->V1M_OBSERV)

				cXml +=	"<observacoes>"
				cXml +=		xTafTag("observacao", V1M->V1M_OBSERV)
				cXml +=	"</observacoes>"
				V1M->( DBSkip() )

			EndDo

		EndIf

		If !lLaySimplif

			If !Empty(CMD->CMD_TPINSC) .And. !Empty(CMD->CMD_CNPJSU)
				cXml +=		"<sucessaoVinc>"
				cXml +=			xTafTag("tpInscSuc",CMD->CMD_TPINSC)
				cXml +=			xTafTag("cnpjSucessora",CMD->CMD_CNPJSU)
				cXml +=		"</sucessaoVinc>"
			EndIf

		Else

			If !Empty(CMD->CMD_TPINSC) .And. !Empty(CMD->CMD_NRINSC)
				cXml +=		"<sucessaoVinc>"
				cXml +=			xTafTag("tpInsc",CMD->CMD_TPINSC,,.T.)
				cXml +=			xTafTag("nrInsc",CMD->CMD_NRINSC,,.T.)
				cXml +=		"</sucessaoVinc>"
			EndIf

		EndIf

		xTAFTagGroup( "transfTit";
					, {{ "cpfSubstituto", CMD->CMD_CPFSUB,, .F. };
					,  { "dtNascto", CMD->CMD_DTNSTI,, .F. } };
					, @cXml )


		xTAFTagGroup( "mudancaCPF ";
					, {{ "novoCPF ", CMD->CMD_NEWCPF,, .F. }};
					, @cXml )


		//T06 - * Start
		If T06->(MsSeek(xFilial("T06") + CMD->(CMD_ID + CMD_VERSAO)))

			While T06->(!Eof()) .and. T06->(T06_FILIAL + T06_ID + T06_VERSAO) == xFilial("T06") + CMD->(CMD_ID + CMD_VERSAO)

				cXmlDev += "<dmDev>"
				cXmlDev += xTafTag("ideDmDev", T06->T06_IDEDMD, PesqPict("T06", "T06_IDEDMD"))

				If lSimplBeta .And. TafColumnPos("T06_INDRRA")
					cXmlDev 	+= xTafTag("indRRA", xFunTrcSN(T06->T06_INDRRA, 6),, .T.)
					cXMLProJud 	:= ""

					xTafTagGroup("despProcJud";
								, {{"vlrDespCustas"		, T06->T06_VLRCUS, PesqPict("T06", "T06_VLRCUS"), .F.};
								,  {"vlrDespAdvogados"	, T06->T06_VLRADV, PesqPict("T06", "T06_VLRADV"), .F.}};
								, @cXMLProJud)

					If V9N->(MsSeek(xFilial("V9N") + T06->(T06_ID + T06_VERSAO + T06_IDEDMD)))
						cXMLIdeAdv := ""

						While !V9N->(EOF()) .And. V9N->(V9N_FILIAL + V9N_ID + V9N_VERSAO + V9N_RECPAG) == xFilial("V9N") + T06->(T06_ID + T06_VERSAO + T06_IDEDMD)

							xTafTagGroup("ideAdv";
										, {{"tpInsc", V9N->V9N_TPINSC, PesqPict("V9N", "V9N_TPINSC"), .F.};
										,  {"nrInsc", V9N->V9N_NRINSC, PesqPict("V9N", "V9N_NRINSC"), .F.};
										,  {"vlrAdv", V9N->V9N_VLRADV, PesqPict("V9N", "V9N_VLRADV"), .T.}};
										, @cXMLIdeAdv)

							V9N->(DBSkip())
						EndDo
					EndIf

					xTafTagGroup("infoRRA";
								, {	{"tpProcRRA"	, T06->T06_TPPRRA,, .F.};
								,	{"nrProcRRA"	, T06->T06_NRPRRA,, .T.};
								,	{"descRRA"		, T06->T06_DESCRA,, .F.};
								,	{"qtdMesesRRA"	, T06->T06_QTMRRA,, .F.}};
								, @cXmlDev;
								, {	{"despProcJud", cXMLProJud, 0};
								,	{"ideAdv", cXMLIdeAdv, 0}};
								, .F., .T.)
				EndIf	

				//T3G - *Start
				If T3G->(MsSeek(xFilial("T3G") + CMD->(CMD_ID + CMD_VERSAO) + T06->T06_IDEDMD ) )

					While T3G->(!Eof()) .and. T3G->(T3G_FILIAL+T3G_ID+T3G_VERSAO+T3G_RECPAG  ) == xFilial("T3G") + CMD->(CMD_ID + CMD_VERSAO) + T06->T06_IDEDMD

						//T05 - *Start
						IF T05->(MsSeek(xFilial("T05") + CMD->(CMD_ID + CMD_VERSAO) + T06->T06_IDEDMD + T3G->T3G_ESTABE + T3G->T3G_LOTTRB ))
							
							While T05->(!Eof()) .and. T05->(T05_FILIAL + T05_ID + T05_VERSAO + T05_RECPAG + T05_ESTABE + T05_LOTTRB ) == xFilial("T05") + T3G->(T3G_ID + T3G_VERSAO + T3G_RECPAG + T3G_ESTABE + T3G_LOTTRB )

								cXmlDetVerb +=	"<detVerbas>"
								cXmlDetVerb +=		xTafTag("codRubr",Posicione("C8R",5,xFilial("C8R") + ALLTRIM(T05->T05_CODRUB) + "1","C8R_CODRUB"),PesqPict("C8R","C8R_CODRUB"))

								If lRubERPPad
									cXmlDetVerb +=		xTafTag("ideTabRubr",Posicione("C8R",5,xFilial("C8R") + ALLTRIM(T05->T05_CODRUB) + "1","C8R_IDTBRU"),PesqPict("C8R","C8R_IDTBRU"))
								Else
									cXmlDetVerb +=		xTafTag("ideTabRubr",Posicione("T3M",1,xFilial("T3M")+Posicione("C8R",5,xFilial("C8R") + ALLTRIM(T05->T05_CODRUB) + "1","C8R_IDTBRU"),"T3M_CODERP"),PesqPict("T3M","T3M_CODERP"))
								EndIf

								If !lLaySimplif
									cXmlDetVerb +=		xTafTag("qtdRubr",T05->T05_QTDRUB,PesqPict("T05","T05_QTDRUB"),.T.,.T.)
								Else
									cXmlDetVerb +=		xTafTag("qtdRubr",T05->T05_SQTDRB,PesqPict("T05","T05_SQTDRB"),.T.,.T.)
								EndIf

								cXmlDetVerb +=		xTafTag("fatorRubr",T05->T05_FATRUB,PesqPict("T05","T05_FATRUB"),.T.,.T.)

								If !lLaySimplif
									cXmlDetVerb +=		xTafTag("vrUnit",T05->T05_VLRUNI,PesqPict("T05","T05_VLRUNI"),.T.,.T.)
								EndIf

								cXmlDetVerb +=		xTafTag("vrRubr",T05->T05_VLRRUB,PesqPict("T05","T05_VLRRUB"))

								If lLaySimplif
									cXmlDetVerb +=		xTafTag("indApurIR",T05->T05_APURIR,PesqPict("T05","T05_APURIR"),.T.,.T.)	
								EndIf

								cXmlDetVerb +=	"</detVerbas>"

								If lInfoRPT

									aRubrica := oReport:GetRubrica( T05->T05_CODRUB )

									aAdd( aAnalitico, Array( 16 ) )
									nPosValores := Len( aAnalitico )

									aAnalitico[nPosValores][ANALITICO_MATRICULA]			:=	AllTrim( cMatric )
									aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:=	AllTrim( cCodCat )
									aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:=	AllTrim( Posicione( "C92", 5, xFilial( "C92" ) + T3G->T3G_ESTABE + "1", "C92_TPINSC" ) )
									aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:=	AllTrim( Posicione( "C92", 5, xFilial( "C92" ) + T3G->T3G_ESTABE + "1", "C92_NRINSC" ) )
									aAnalitico[nPosValores][ANALITICO_LOTACAO]				:=	AllTrim( Posicione( "C99", 4, xFilial( "C99" ) + T3G->T3G_LOTTRB + "1", "C99_CODIGO" ) )
									aAnalitico[nPosValores][ANALITICO_NATUREZA]				:=	AllTrim( aRubrica[1] ) //Natureza
									aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:=	AllTrim( aRubrica[2] ) //Tipo
									aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:=	AllTrim( aRubrica[3] ) //Incidência CP
									aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:=	AllTrim( aRubrica[4] ) //Incidência IRRF
									aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:=	AllTrim( aRubrica[5] ) //Incidência FGTS
									aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:=	""
									aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:=	""
									aAnalitico[nPosValores][ANALITICO_VALOR]				:=	T05->T05_VLRRUB
								
								EndIf

								T05->(DBSkip())

							EndDo

						EndIf
						//-- T05 - *End
						
						If !lLaySimplif
							
							//T15 - * Start - T15_FILIAL, T15_ID, T15_VERSAO, T15_RECIBO, T15_ESTABE, T15_LOTACA, T15_CNPJOP, T15_REGANS
							If T15->( MsSeek( xFilial( "T15" ) + T3G->( T3G_ID + T3G_VERSAO + T3G_RECPAG + T3G_ESTABE + T3G_LOTTRB ) ) )
								
								While T15->( !Eof() ) .and. T15->( T15_FILIAL + T15_ID + T15_VERSAO + T15_RECIBO + T15_ESTABE + T15_LOTACA ) == xFilial( "T15" ) + T3G->( T3G_ID + T3G_VERSAO + T3G_RECPAG + T3G_ESTABE + T3G_LOTTRB )
									
									cXmlDPlan +=	"<detOper>"
									cXmlDPlan +=		xTafTag( "cnpjOper"	, T15->T15_CNPJOP, PesqPict( "T15", "T15_CNPJOP" ) )
									cXmlDPlan +=		xTafTag( "regANS"	, T15->T15_REGANS, PesqPict( "T15", "T15_REGANS" ) )
									cXmlDPlan +=		xTafTag( "vrPgTit"	, T15->T15_VLPGTI, PesqPict( "T15", "T15_VLPGTI" ),, .T.,.T. ) //ALTERADO PARA GERAR A TAG COM VALOR ZERADO

									//T16 - * Start - T16_FILIAL, T16_ID, T16_VERSAO, T16_RECIBO, T16_ESTABE, T16_LOTACA, T16_CNPJOP, T16_REGANS, T16_SEQUEN
									If T16->( MsSeek( xFilial( "T16" ) + T15->( T15_ID + T15_VERSAO + T15_RECIBO + T15_ESTABE + T15_LOTACA + T15_CNPJOP + T15_REGANS ) ) )
										
										While T16->( !Eof() ) .and. T16->( T16_FILIAL + T16_ID + T16_VERSAO + T16_RECIBO + T16_ESTABE + T16_LOTACA + T16_CNPJOP + T16_REGANS ) == xFilial( "T16" ) + T15->( T15_ID + T15_VERSAO + T15_RECIBO + T15_ESTABE + T15_LOTACA + T15_CNPJOP + T15_REGANS )
											
											cXmlDPlan +=	"<detPlano>"
											cXmlDPlan +=		xTafTag( "tpDep"	, Posicione( "CMI", 1, xFilial( "CMI" ) + T16->T16_TPDEP, "CMI_CODIGO" ) )
											cXmlDPlan +=		xTafTag( "cpfDep"	, T16->T16_CPFDEP,, .T. )
											cXmlDPlan +=		xTafTag( "nmDep"	, T16->T16_NOMDEP )
											cXmlDPlan +=		xTafTag( "dtNascto"	, T16->T16_DTNDEP )
											cXmlDPlan +=		xTafTag( "vlrPgDep"	, T16->T16_VPGDEP, PesqPict( "T16", "T16_VPGDEP" ),, .T.,.T.)
											cXmlDPlan +=	"</detPlano>"
											T16->( DBSkip() )
										
										EndDo
									
									EndIf
									//T16 - * End

									cXmlDPlan +=	"</detOper>"
									T15->( DBSkip() )
								
								EndDo
							
							EndIf
							//T15 - * End
						
						EndIf

						xTafTagGroup("infoAgNocivo";
									, {{"grauExp",Posicione("C88",1,xFilial("C88") + T3G->T3G_GRAUEX,"C88_CODIGO"),,.F.}};
									, @cXmlNocivo)

						xTafTagGroup("infoSimples";
									, {{"indSimples",T3G->T3G_INDCSU,,.F.}};
									, @cXmlISimp)

						If !lLaySimplif

							If !Empty(cXmlDPlan)
								cXmlSaude += "<infoSaudeColet>"
								cXmlSaude += 	cXmlDPlan
								cXmlSaude += "</infoSaudeColet>"
							EndIf
						
							xTafTagGroup("ideEstabLot";	
										, {{"tpInsc"	, POSICIONE("C92", 1, xFilial("C92")+T3G->T3G_ESTABE		,"C92_TPINSC"),,.F.};
										,  {"nrInsc"	, POSICIONE("C92", 1, xFilial("C92")+T3G->T3G_ESTABE		,"C92_NRINSC"),,.F.};
							            ,  {"codLotacao", Posicione("C99", 4, xFilial("C99")+T3G->T3G_LOTTRB + '1'	,"C99_CODIGO"),,.F.}};
							            , @cXmlIdeEst;
										, {{"detVerbas"		,cXmlDetVerb,1};
										,  {"infoSaudeColet",cXmlSaude	,0};
										,  {"infoAgNocivo"	,cXmlNocivo	,0};
										,  {"infoSimples"	,cXmlISimp	,0}} )
						Else

							xTafTagGroup("ideEstabLot";
										, {{"tpInsc"	,POSICIONE("C92", 1, xFilial("C92")+T3G->T3G_ESTABE			,"C92_TPINSC"),,.F.};
							            ,  {"nrInsc"	,POSICIONE("C92", 1, xFilial("C92")+T3G->T3G_ESTABE			,"C92_NRINSC"),,.F.};
							            ,  {"codLotacao",Posicione("C99", 4, xFilial("C99")+T3G->T3G_LOTTRB + '1'	,"C99_CODIGO"),,.F.}};
							            , @cXmlIdeEst;
										, {{"detVerbas"		,cXmlDetVerb,1};
										,  {"infoAgNocivo"	,cXmlNocivo	,0};
										,  {"infoSimples"	,cXmlISimp	,0}} )

						EndIf

						cXmlDPlan	:= ""
						cXmlDetVerb := ""
						cXmlSaude	:= ""
						cXmlNocivo	:= ""
						cXmlISimp	:= ""

						T3G->(DBSkip())

					EndDo

				EndIf
				//-- T3G -* End

				If !Empty(cXmlIdeEst)
					cXmlDev += "<infoPerApur>"
					cXmlDev += 	cXmlIdeEst
					cXmlDev += "</infoPerApur>"
				EndIf

				cXmlIdeEst		:= ""

				//T5I - *Start
				If T5I->(MsSeek(xFilial("T5I") + CMD->(CMD_ID + CMD_VERSAO) + T06->T06_IDEDMD))
					
					While T5I->(!Eof()) .and. T5I->(T5I_FILIAL + T5I_ID + T5I_VERSAO + T5I_IDEDMD) == xFilial("T3G") + CMD->(CMD_ID + CMD_VERSAO) + T06->T06_IDEDMD

						//T5J - * Start
						If T5J->(MsSeek(xFilial("T5J") + CMD->(CMD_ID + CMD_VERSAO) + T06->T06_IDEDMD + DTOS(T5I->T5I_DTACCO) + T5I->T5I_TPACCO))
							
							While T5J->(!Eof()) .and. T5J->( T5J_FILIAL + T5J_ID + T5J_VERSAO + T5J_IDEDMD + DTOS(T5J_DTACCO) + T5J_TPACCO ) == xFilial("T5J") + CMD->(CMD_ID + CMD_VERSAO) + T06->T06_IDEDMD + DTOS(T5I->T5I_DTACCO) + T5I->T5I_TPACCO

								//T5Q - *Start
								If T5Q->(MsSeek(xFilial("T5Q") + CMD->(CMD_ID+CMD_VERSAO) + T06->T06_IDEDMD + DTOS(T5I->T5I_DTACCO) + T5I->T5I_TPACCO + T5J->T5J_PERREF ))
									
									While T5Q->(!Eof()) .and. T5Q->(T5Q_FILIAL+T5Q_ID+T5Q_VERSAO+T5Q_IDEDMD+DTOS(T5Q_DTACCO)+T5Q_TPACCO+T5Q_PERREF) == xFilial("T5Q") + CMD->(CMD_ID+CMD_VERSAO) + T06->T06_IDEDMD + DTOS(T5I->T5I_DTACCO) + T5I->T5I_TPACCO + T5J->T5J_PERREF

										//T5S - *Start
										IF T5S->(MsSeek(xFilial("T5S") + CMD->(CMD_ID + CMD_VERSAO) + T06->T06_IDEDMD +  DTOS(T5I->T5I_DTACCO) + T5I->T5I_TPACCO + T5J->T5J_PERREF + T5Q->T5Q_ESTABE + T5Q->T5Q_LOTTRB))
											
											While T5S->(!Eof()) .and. T5S->(T5S_FILIAL+T5S_ID+T5S_VERSAO+T5S_IDEDMD+DTOS(T5S_DTACCO)+T5S_TPACCO+T5S_PERREF+T5S_ESTABE+T5S_LOTTRB) == xFilial("T5S") + CMD->(CMD_ID + CMD_VERSAO) + T06->T06_IDEDMD +  DTOS(T5I->T5I_DTACCO) + T5I->T5I_TPACCO + T5J->T5J_PERREF + T5Q->T5Q_ESTABE + T5Q->T5Q_LOTTRB

												cXmlDetVerb +=	"<detVerbas>"
												cXmlDetVerb += 		xTafTag("codRubr",Posicione("C8R",5,xFilial("C8R") + ALLTRIM(T5S->T5S_CODRUB) + "1","C8R_CODRUB"),PesqPict("C8R","C8R_CODRUB"))
												
												If lRubERPPad
													cXmlDetVerb +=		xTafTag("ideTabRubr",Posicione("C8R",5,xFilial("C8R") + ALLTRIM(T5S->T5S_CODRUB) + "1","C8R_IDTBRU"),PesqPict("C8R","C8R_IDTBRU"))
												Else
													cXmlDetVerb +=		xTafTag("ideTabRubr",Posicione("T3M",1,xFilial("T3M")+Posicione("C8R",5,xFilial("C8R") + ALLTRIM(T5S->T5S_CODRUB) + "1","C8R_IDTBRU"),"T3M_CODERP"),PesqPict("T3M","T3M_CODERP"))
												EndIf
												
												If !lLaySimplif
													cXmlDetVerb += 		xTafTag("qtdRubr",T5S->T5S_QTDRUB,PesqPict("T5S","T5S_QTDRUB"),.T.,.T.)
												Else
													cXmlDetVerb += 		xTafTag("qtdRubr",T5S->T5S_SQTDRB,PesqPict("T5S","T5S_SQTDRB"),.T.,.T.)
												EndIf
												
												cXmlDetVerb +=		xTafTag("fatorRubr",T5S->T5S_FATRUB,PesqPict("T5S","T5S_FATRUB"),.T.,.T.)
												
												If !lLaySimplif
													cXmlDetVerb += 		xTafTag("vrUnit",T5S->T5S_VLRUNI,PesqPict("T5S","T5S_VLRUNI"),.T.,.T.)
												EndIf
												
												cXmlDetVerb += 		xTafTag("vrRubr",T5S->T5S_VLRRUB,PesqPict("T5S","T5S_VLRRUB"))
												
												If lLaySimplif
													cXmlDetVerb +=		xTafTag("indApurIR",T5S->T5S_APURIR,PesqPict("T5S","T5S_APURIR"),.T.,.T.)	
												EndIf
												
												cXmlDetVerb +=	"</detVerbas>"

												If lInfoRPT

													aRubrica := oReport:GetRubrica( T5S->T5S_CODRUB )

													aAdd( aAnalitico, Array( 16 ) )
													nPosValores := Len( aAnalitico )

													aAnalitico[nPosValores][ANALITICO_MATRICULA]			:=	AllTrim( cMatric )
													aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:=	AllTrim( cCodCat )
													aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:=	AllTrim( Posicione( "C92", 5, xFilial( "C92" ) + T5Q->T5Q_ESTABE + "1", "C92_TPINSC" ) )
													aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:=	AllTrim( Posicione( "C92", 5, xFilial( "C92" ) + T5Q->T5Q_ESTABE + "1", "C92_NRINSC" ) )
													aAnalitico[nPosValores][ANALITICO_LOTACAO]				:=	AllTrim( Posicione( "C99", 4, xFilial( "C99" ) + T5Q->T5Q_LOTTRB + "1", "C99_CODIGO" ) )
													aAnalitico[nPosValores][ANALITICO_NATUREZA]				:=	AllTrim( aRubrica[1] ) //Natureza
													aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:=	AllTrim( aRubrica[2] ) //Tipo
													aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:=	AllTrim( aRubrica[3] ) //Incidência CP
													aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:=	AllTrim( aRubrica[4] ) //Incidência IRRF
													aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:=	AllTrim( aRubrica[5] ) //Incidência FGTS
													aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:=	""
													aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:=	""
													aAnalitico[nPosValores][ANALITICO_VALOR]				:=	T5S->T5S_VLRRUB
												
												EndIf

												T5S->(DBSkip())

											EndDo

										EndIf
										//-- T5S - *End

										xTafTagGroup("infoAgNocivo";
													, {{"grauExp",Posicione("C88",1,xFilial("C88") + T5Q->T5Q_GRAUEX,"C88_CODIGO"),,.F.}};
													, @cXmlNocivo)

										xTafTagGroup("infoSimples";
													, {{"indSimples",T5Q->T5Q_INDCSU,,.F.}};
													, @cXmlISimp)

										xTafTagGroup("ideEstabLot";
													, {{"tpInsc"	,POSICIONE("C92", 1, xFilial("C92")+T5Q->T5Q_ESTABE,"C92_TPINSC")		 ,,.F.};
													,  {"nrInsc"	,POSICIONE("C92", 1, xFilial("C92")+T5Q->T5Q_ESTABE,"C92_NRINSC")		 ,,.F.};
													,  {"codLotacao",Posicione("C99", 4, xFilial("C99") + T5Q->T5Q_LOTTRB + '1',"C99_CODIGO"),,.F.}};
													, @cXmlEstLot;
													, {{"detVerbas"		,cXmlDetVerb,1};
													,  {"infoAgNocivo"	,cXmlNocivo	,0};
													,  {"infoSimples"	,cXmlISimp	,0}} )

										cXmlDetVerb := ""
										cXmlNocivo  := ""
										cXmlISimp   := ""

										T5Q->(DBSkip())

									EndDo

								EndIf
								//-- T5Q - *End

								cPerRef := Substr(T5J->T5J_PERREF, 1, 4) + '-' +  Substr(T5J->T5J_PERREF, 5, 2)

								xTafTagGroup("idePeriodo";
											, {{"perRef",cPerRef,,.F.}};
											, @cXmlIdePer;
											, {{"ideEstabLot",cXmlEstLot,1}} )

								cXmlEstLot := ""

								T5J->(DBSkip())

							EndDo

						EndIf

						//-- T5J - *End
						If !lLaySimplif
							xTafTagGroup("ideADC";
										, {{"dtAcConv"	, T5I->T5I_DTACCO																						 ,,.F.};
							            ,  {"tpAcConv"	, changeAcConv(T5I->T5I_TPACCO,1)																		 ,,.F.};
							            ,  {"compAcConv", Iif( !Empty(T5I->T5I_COMPAC), substr(T5I->T5I_COMPAC, 1, 4) + '-' + substr(T5I->T5I_COMPAC, 5, 2), "" ),,.T.};
							            ,  {"dtEfAcConv", T5I->T5I_DTEFAC																						 ,,.T.};
							            ,  {"dsc"		, T5I->T5I_DSC																							 ,,.F.}};
							            , @cXmlIdeABC;
										, {{"detVerbas",cXmlIdePer,1}} )
						Else
							xTafTagGroup("ideADC";
										, {{"dtAcConv"	,T5I->T5I_DTACCO				,,!(changeAcConv(T5I->T5I_TPACCO,1) $ "A|B|C|D|E")};
							            ,  {"tpAcConv"	,changeAcConv(T5I->T5I_TPACCO,1),,.F.};
							            ,  {"dsc"		,T5I->T5I_DSC					,,.F.}};
							            , @cXmlIdeABC;
										, {{"detVerbas",cXmlIdePer,1}} )
						EndIf

						cXmlIdePer := ""

						T5I->(DBSkip())

					EndDo
					
				EndIf
				//-- T5I - *End

				If !Empty(cXmlIdeABC)
					cXmlDev += "<infoPerAnt>"
					cXmlDev += 	cXmlIdeABC
					cXmlDev += "</infoPerAnt>"
				EndIf

				cXmlIdeABC :=	""

				//T88 - *Start
				If !lLaySimplif

					If T88->( MsSeek( xFilial( "T88" ) + CMD->( CMD_ID + CMD_VERSAO ) + T06->T06_IDEDMD ) )

						While T88->( !Eof() ) .and. T88->( T88_FILIAL + T88_ID + T88_VERSAO + T88_IDEDMD  ) == xFilial( "T88" ) + CMD->( CMD_ID + CMD_VERSAO ) + T06->T06_IDEDMD
							
							cXmlInterm +=	"<infoTrabInterm>"
							cXmlInterm +=		xTafTag( "codConv", Posicione( "T87", 4, xFilial( "T87" ) + AllTrim( T88->T88_IDCODC ) + "1", "T87_CONVOC" ), PesqPict( "T87", "T87_CONVOC" ) )
							cXmlInterm +=	"</infoTrabInterm>"
							T88->( DBSkip() )

						EndDo

					EndIf
					
				EndIf
				//-- T88 -* End

				If !Empty( cXmlInterm )
					cXmlDev += cXmlInterm
				EndIf

				cXmlInterm := ""

				cXmlDev += "</dmDev>"

				T06->(DBSkip())

			EndDo

		EndIf
		//-- T06 - *End

		If T3H->(MsSeek(xFilial("T3H") + CMD->(CMD_ID + CMD_VERSAO)))
			
			While T3H->(!Eof()) .and. T3H->(T3H_FILIAL + T3H_ID + T3H_VERSAO) == xFilial("T3H") + CMD->(CMD_ID + CMD_VERSAO)
				
				If !lLaySimplif
					
					If !Empty(T3H->T3H_TPTRIB) .AND. !Empty(T3H->T3H_IDPROC)
						cXmlProcJud +=	"<procJudTrab>"
						cXmlProcJud +=		xTafTag("tpTrib",T3H->T3H_TPTRIB)
						cXmlProcJud +=		xTafTag("nrProcJud",Posicione("C1G",8,xFilial("C1G")+T3H->T3H_IDPROC+"1","C1G_NUMPRO"))

						cCodSusp    := Posicione("T5L",1,xFilial("T5L")+T3H->T3H_IDSUSP,"T5L_CODSUS")

						If !Empty(cCodSusp)
							cXmlProcJud += xTafTag("codSusp", Alltrim(cCodSusp))
						EndIf

						
						cXmlProcJud +=	"</procJudTrab>"
					
					EndIf
				
				Else
					
					If !Empty(T3H->T3H_TPTRIB) .AND. !Empty(T3H->T3H_IDPROC) .AND. !Empty(T3H->T3H_IDSUSP)

						cXmlProcJud +=	"<procJudTrab>"
						cXmlProcJud +=		xTafTag("tpTrib",T3H->T3H_TPTRIB,,.F.)
						cXmlProcJud +=		xTafTag("nrProcJud",Posicione("C1G",8,xFilial("C1G")+T3H->T3H_IDPROC+"1","C1G_NUMPRO"),,.F.)

						cCodSusp    := Posicione("T5L",1,xFilial("T5L")+T3H->T3H_IDSUSP,"T5L_CODSUS")

						cXmlProcJud += xTafTag("codSusp", Alltrim(cCodSusp),,.F.)
	
						cXmlProcJud +=	"</procJudTrab>"

					EndIf

				EndIf

				T3H->(DBSkip())

			EndDo

		EndIF

		If !Empty(CMD->CMD_INDMV)

			cXmlInfMV +=	"<infoMV>"
			cXmlInfMV +=		xTafTag("indMV",CMD->CMD_INDMV)

			dBSelectArea("C9J")
			C9J->(dBSetOrder(1))
			If C9J->(MsSeek(xFilial("C9J") + CMD->(CMD_ID + CMD_VERSAO)))

				While C9J->(!Eof()) .And. C9J->(C9J_FILIAL + C9J_ID + C9J_VERSAO) == xFilial("CMD") + CMD->(CMD_ID + CMD_VERSAO)

					cXmlInfMV	+=	"<remunOutrEmpr>"
					cXmlInfMV	+=		xTafTag("tpInsc"		,C9J->C9J_TPINSC,PesqPict("C9J","C9J_TPINSC"))
					cXmlInfMV	+=		xTafTag("nrInsc"		,C9J->C9J_NRINSC,PesqPict("C9J","C9J_NRINSC"))
					cXmlInfMV	+= 		xTafTag("codCateg"		,Posicione("C87",1,xFilial("C87") + C9J->C9J_CODCAT,"C87_CODIGO"))
					cXmlInfMV	+=		xTafTag("vlrRemunOE"	,C9J->C9J_VLREMU,PesqPict("C9J","C9J_VLREMU"),,.T.)
					cXmlInfMV	+=	"</remunOutrEmpr>"

					C9J->(DBSkip())

				EndDo

			EndIf

			cXmlInfMV +=	"</infoMV>"

		EndIf

		xTafTagGroup("procCS";
					, {{"nrProcJud",Posicione("C1G",8,xFilial("C1G")+CMD->CMD_PROCCS+"1","C1G_NUMPRO"),,.T.}};
					, @cXmlProccs)

		xTafTagGroup("verbasResc";
					, ;
					, @cXml;
					, {{"dmDev"			, cXmlDev		,1};
					,  {"procJudTrab"	, cXmlProcJud	,0};
					,  {"infoMV"		, cXmlInfMV		,0};
					,  {"procCS"		, cXmlProccs	,0}},,.T.)

		If lSimplBeta .and. TafColumnPos("CMD_INDREM")
			xTafTagGroup("remunAposDeslig";
						, {{"indRemun"		, CMD->CMD_INDREM,, .T.};
						,  {"dtFimRemun"	, CMD->CMD_DTFREM,, .F.}};
						, @cXml )
		Else
			xTafTagGroup("quarentena";
						, {{"dtFimQuar",CMD->CMD_DTQUA,,.F.}};
						, @cXml )			
		EndIf
		
		xTAFTagGroup( "consigFGTS";
					, {{"idConsig"	, xFunTrcSN(CMD->CMD_INDCSG,1)	,, .F. };
					,  {"insConsig"	, CMD->CMD_INSCSG				,, .T. };
					,  {"nrContr"	, CMD->CMD_NRCONT				,, .T. } };
					, @cXml )

		cXml +=	"</infoDeslig>"

		C9V->(DbCloseArea())
		T06->(DbCloseArea())
		T3G->(DbCloseArea())
		T05->(DbCloseArea())
		T15->(DbCloseArea())
		T16->(DbCloseArea())
		T5I->(DbCloseArea())
		T5J->(DbCloseArea())
		T5Q->(DbCloseArea())
		T5S->(DbCloseArea())
		T88->(DBCloseArea())
		If lSimplBeta .And. TafColumnPos("T06_INDRRA")
			DBSelectArea("V9N")
			V9N->(DBCloseArea())
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estrutura do cabecalho³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cXml := xTafCabXml(cXml, "CMD", cLayout, cReg,,,, lLaySimplif, cEsocial)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa gravacao do registro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lJob
			xTafGerXml(cXml,cLayout)
		EndIf

		If lInfoRPT
			If CMD->CMD_EVENTO $ "I|A"
				oInfoRPT := oReport:oVOReport
				oInfoRPT:SetIndApu( "1" )
				oInfoRPT:SetPeriodo( SubStr( DToS( CMD->CMD_DTDESL ), 1, 6 ) )
				oInfoRPT:SetCPF( AllTrim( cCPF ) )
				oInfoRPT:SetNome( AllTrim( cNome ) )
				oInfoRPT:SetAnalitico( aAnalitico )

				oReport:UpSert( "S-2299", "2", xFilial( "CMD" ), oInfoRPT )
			EndIf
		EndIf

		cFilAnt := cFilBkp

	EndIf

Return(cXml)

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclusão do evento (S-3000)

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function é chamada pelo TafIntegraESocial

@Return .T.

@Author Vitor Henrique Ferreira
@Since 30/06/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc(oModel as object, nRecno as numeric, lRotExc as logical)

	Local aGravaV9N		as array
	Local aGrava		as array
	Local aGravaT06		as array
	Local aGravaT3G		as array
	Local aGravaT05		as array
	Local aGravaT15		as array
	Local aGravaT16		as array
	Local aGravaT5I		as array
	Local aGravaT5J		as array
	Local aGravaT5Q		as array
	Local aGravaT5S		as array
	Local aGravaT88		as array
	Local aGravaC9J		as array
	Local aGravaT3H		as array
	Local cVerAnt		as character
	Local cProtocolo	as character
	Local cVersao		as character
	Local cEvento		as character
	Local nlI  			as numeric
	Local nlY  			as numeric
	Local nT06			as numeric
	Local nT3G			as numeric
	Local nT3GAdd 		as numeric
	Local nT05 			as numeric
	Local nT05Add 		as numeric
	Local nT15 			as numeric
	Local nT15Add 		as numeric
	Local nT16 			as numeric
	Local nT16Add 		as numeric
	Local nT5I 			as numeric
	Local nT5IAdd 		as numeric
	Local nT5J 			as numeric
	Local nT5JAdd 		as numeric
	Local nT5Q 			as numeric
	Local nT5QAdd 		as numeric
	Local nT5S 			as numeric
	Local nT5SAdd 		as numeric
	Local nT88 			as numeric
	Local nT88Add 		as numeric
	Local nC9J 			as numeric
	Local nT3H 			as numeric
	Local nV9N			as numeric
	Local nV9NAdd		as numeric
	Local oModelCMD		as object
	Local oModelT06		as object
	Local oModelV9N		as object
	Local oModelT3G		as object
	Local oModelT05		as object
	Local oModelT15		as object
	Local oModelT16		as object
	Local oModelT5I		as object
	Local oModelT5J		as object
	Local oModelT5Q		as object
	Local oModelT5S		as object
	Local oModelT88		as object
	Local oModelC9J		as object
	Local oModelT3H		as object

	aGravaV9N	:= {}
	aGrava		:= {}
	aGravaT06	:= {}
	aGravaT3G	:= {}
	aGravaT05	:= {}
	aGravaT15	:= {}
	aGravaT16	:= {}
	aGravaT5I	:= {}
	aGravaT5J	:= {}
	aGravaT5Q	:= {}
	aGravaT5S	:= {}
	aGravaT88	:= {}
	aGravaC9J	:= {}
	aGravaT3H	:= {}
	cVerAnt		:= ""
	cProtocolo	:= ""
	cVersao		:= ""
	cEvento		:= ""
	nlI  		:= 0
	nlY  		:= 0
	nT06		:= 0
	nT3G		:= 0
	nT3GAdd 	:= 0
	nT05 		:= 0
	nT05Add 	:= 0
	nT15 		:= 0
	nT15Add 	:= 0
	nT16 		:= 0
	nT16Add 	:= 0
	nT5I 		:= 0
	nT5IAdd 	:= 0
	nT5J 		:= 0
	nT5JAdd 	:= 0
	nT5Q 		:= 0
	nT5QAdd 	:= 0
	nT5S 		:= 0
	nT5SAdd 	:= 0
	nT88 		:= 0
	nT88Add 	:= 0
	nC9J 		:= 0
	nT3H 		:= 0
	nV9N		:= 0
	nV9NAdd		:= 0
	oModelCMD	:= Nil
	oModelT06	:= Nil
	oModelV9N	:= Nil
	oModelT3G	:= Nil
	oModelT05	:= Nil
	oModelT15	:= Nil
	oModelT16	:= Nil
	oModelT5I	:= Nil
	oModelT5J	:= Nil
	oModelT5Q	:= Nil
	oModelT5S	:= Nil
	oModelT88	:= Nil
	oModelC9J	:= Nil
	oModelT3H	:= Nil

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		//Posiciona o item
		dbSelectArea("CMD")
		("CMD")->( DBGoTo( nRecno ) )

		//Carrego a Estrutura dos Models a serem gravados
		oModelCMD  := oModel:GetModel( "MODEL_CMD" 	)
		oModelT06  := oModel:GetModel( "MODEL_T06" 	)
		oModelT3G  := oModel:GetModel( "MODEL_T3G" 	)
		oModelT05  := oModel:GetModel( "MODEL_T05" 	)

		If lSimplBeta .And. TafColumnPos("T06_INDRRA")
			oModelV9N := oModel:GetModel("MODEL_V9N")
		EndIf

		If !lLaySimplif
			oModelT15  := oModel:GetModel( "MODEL_T15" 	)
			oModelT16  := oModel:GetModel( "MODEL_T16"	)
			oModelT88  := oModel:GetModel( "MODEL_T88"	)
		EndIf

		oModelT5I  := oModel:GetModel( "MODEL_T5I"	)
		oModelT5J  := oModel:GetModel( "MODEL_T5J"	)
		oModelT5Q  := oModel:GetModel( "MODEL_T5Q" 	)
		oModelT5S  := oModel:GetModel( "MODEL_T5S" 	)
		oModelC9J  := oModel:GetModel( "MODEL_C9J"	)
		oModelT3H  := oModel:GetModel( "MODEL_T3H"	)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco a versao anterior do registro para gravacao do rastro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVerAnt   	:= oModelCMD:GetValue( "CMD_VERSAO" )
		cProtocolo	:= oModelCMD:GetValue( "CMD_PROTUL" )
		cEvento		:= oModelCMD:GetValue( "CMD_EVENTO" )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Neste momento eu gravo as informacoes que foram carregadas       ³
		//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
		//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
		//³nao devem ser consideradas neste momento                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		For nlI := 1 To 1
			For nlY := 1 To Len( oModelCMD:aDataModel[ nlI ] )
				Aadd( aGrava, { oModelCMD:aDataModel[ nlI, nlY, 1 ], oModelCMD:aDataModel[ nlI, nlY, 2 ] } )
			Next
		Next

		//T06
		If T06->(MsSeek(xFilial("T06") + CMD->(CMD_ID + CMD_VERSAO)))

			For nT06 := 1 To oModel:GetModel("MODEL_T06"):Length()

				oModel:GetModel("MODEL_T06"):GoLine(nT06)
				
				If !oModel:GetModel("MODEL_T06"):IsEmpty()

					If !oModel:GetModel("MODEL_T06"):IsDeleted()

						If lSimplBeta .And. TafColumnPos("T06_INDRRA")

							aAdd(aGravaT06 ,{oModelT06:GetValue("T06_IDEDMD"),;
											 oModelT06:GetValue('T06_INDRRA'),;
											 oModelT06:GetValue('T06_TPPRRA'),;
											 oModelT06:GetValue('T06_NRPRRA'),;
											 oModelT06:GetValue('T06_DESCRA'),;
											 oModelT06:GetValue('T06_QTMRRA'),;
											 oModelT06:GetValue('T06_VLRCUS'),;
											 oModelT06:GetValue('T06_VLRADV')})

							For nV9N := 1 To oModel:GetModel("MODEL_V9N"):Length()

								oModel:GetModel("MODEL_V9N"):GoLine(nV9N)

								If !oModel:GetModel("MODEL_V9N"):IsEmpty()

									If !oModel:GetModel("MODEL_V9N"):IsDeleted()

										aAdd(aGravaV9N, {	oModelT06:GetValue("T06_IDEDMD"),;
															oModelV9N:GetValue("V9N_TPINSC"),;
															oModelV9N:GetValue("V9N_NRINSC"),;
															oModelV9N:GetValue("V9N_VLRADV")	})
									EndIf
								EndIf
							Next
						Else 

							aAdd(aGravaT06, {oModelT06:GetValue("T06_IDEDMD")})

						EndIf

						//T3G
						For nT3G := 1 to oModel:GetModel( "MODEL_T3G" ):Length()

							oModel:GetModel( "MODEL_T3G" ):GoLine(nT3G)

							If !oModel:GetModel( 'MODEL_T3G' ):IsEmpty()

								If !oModel:GetModel( "MODEL_T3G" ):IsDeleted()

									aAdd (aGravaT3G ,{oModelT06:GetValue('T06_IDEDMD'),;
													  oModelT3G:GetValue('T3G_ESTABE'),;
													  oModelT3G:GetValue('T3G_LOTTRB'),;
													  oModelT3G:GetValue('T3G_GRAUEX'),;
													  oModelT3G:GetValue('T3G_INDCSU')})

									//T05
									For nT05 := 1 to oModel:GetModel( "MODEL_T05" ):Length()

										oModel:GetModel( "MODEL_T05" ):GoLine(nT05)

										If !oModel:GetModel( 'MODEL_T05' ):IsEmpty()

											If !oModel:GetModel( "MODEL_T05" ):IsDeleted()

												If !lLaySimplif

													aAdd (aGravaT05 ,{oModelT06:GetValue('T06_IDEDMD'),;
																	oModelT3G:GetValue('T3G_ESTABE'),;
																	oModelT3G:GetValue('T3G_LOTTRB'),;
																	oModelT05:GetValue('T05_CODRUB'),;
																	oModelT05:GetValue('T05_QTDRUB'),;
																	oModelT05:GetValue('T05_FATRUB'),;
																	oModelT05:GetValue('T05_VLRUNI'),;
																	oModelT05:GetValue('T05_VLRRUB')})
												Else

													aAdd (aGravaT05 ,{oModelT06:GetValue('T06_IDEDMD'),;
																	oModelT3G:GetValue('T3G_ESTABE'),;
																	oModelT3G:GetValue('T3G_LOTTRB'),;
																	oModelT05:GetValue('T05_CODRUB'),;
																	oModelT05:GetValue('T05_SQTDRB'),;
																	oModelT05:GetValue('T05_FATRUB'),;
																	oModelT05:GetValue('T05_VLRRUB'),;
																	oModelT05:GetValue('T05_APURIR')})
												EndIf

											EndIf

										EndIf

									Next nT05

									If !lLaySimplif

										//T15
										For nT15 := 1 to oModel:GetModel( "MODEL_T15" ):Length()

											oModel:GetModel( "MODEL_T15" ):GoLine(nT15)

											If !oModel:GetModel( 'MODEL_T15' ):IsEmpty()

												If !oModel:GetModel( "MODEL_T15" ):IsDeleted()
												
													aAdd (aGravaT15 ,{oModelT06:GetValue('T06_IDEDMD'),;
																	oModelT3G:GetValue('T3G_ESTABE'),;
																	oModelT3G:GetValue('T3G_LOTTRB'),;
																	oModelT15:GetValue('T15_CNPJOP'),;
																	oModelT15:GetValue('T15_REGANS'),;
																	oModelT15:GetValue('T15_VLPGTI')})

													//T16
													For nT16 := 1 to oModel:GetModel( "MODEL_T16" ):Length()

														oModel:GetModel( "MODEL_T16" ):GoLine(nT16)

														If !oModel:GetModel( 'MODEL_T16' ):IsEmpty()

															If !oModel:GetModel( "MODEL_T16" ):IsDeleted()

																aAdd (aGravaT16 ,{oModelT06:GetValue('T06_IDEDMD'),;
																				oModelT3G:GetValue('T3G_ESTABE'),;
																				oModelT3G:GetValue('T3G_LOTTRB'),;
																				oModelT15:GetValue('T15_CNPJOP'),;
																				oModelT15:GetValue('T15_REGANS'),;
																				oModelT16:GetValue('T16_SEQUEN'),;
																				oModelT16:GetValue('T16_CPFDEP'),;
																				oModelT16:GetValue('T16_DTNDEP'),;
																				oModelT16:GetValue('T16_NOMDEP'),;
																				oModelT16:GetValue('T16_VPGDEP'),;
																				oModelT16:GetValue('T16_TPDEP' )})
															EndIf

														EndIf

													Next nT16

												EndIf
											EndIf

										Next nT15

									EndIf
								EndIf
							EndIf

						Next nT3G

						//T5I
						For nT5I := 1 To oModel:GetModel( 'MODEL_T5I' ):Length()

							oModel:GetModel( 'MODEL_T5I' ):GoLine(nT5I)

							If !oModel:GetModel( 'MODEL_T5I' ):IsDeleted()

								If !lLaySimplif

									aAdd (aGravaT5I ,{oModelT06:GetValue('T06_IDEDMD'),;
													oModelT5I:GetValue('T5I_DTACCO'),;
													oModelT5I:GetValue('T5I_TPACCO'),;
													oModelT5I:GetValue('T5I_DTEFAC'),;
													oModelT5I:GetValue('T5I_DSC'	 ),;
													oModelT5I:GetValue('T5I_COMPAC')})
								Else

									aAdd (aGravaT5I ,{oModelT06:GetValue('T06_IDEDMD'),;
													oModelT5I:GetValue('T5I_DTACCO'),;
													oModelT5I:GetValue('T5I_TPACCO'),;
													oModelT5I:GetValue('T5I_DSC'	 )})

								EndIf

								//T5J
								For nT5J := 1 to oModel:GetModel( "MODEL_T5J" ):Length()

									oModel:GetModel( "MODEL_T5J" ):GoLine(nT5J)

									If !oModel:GetModel( 'MODEL_T5J' ):IsEmpty()

										If !oModel:GetModel( "MODEL_T5J" ):IsDeleted()

											aAdd (aGravaT5J ,{oModelT06:GetValue('T06_IDEDMD'),;
															oModelT5I:GetValue('T5I_DTACCO'),;
															oModelT5I:GetValue('T5I_TPACCO'),;
															oModelT5J:GetValue('T5J_PERREF')})

											//T5Q
											For nT5Q := 1 to oModel:GetModel( "MODEL_T5Q" ):Length()

												oModel:GetModel( "MODEL_T5Q" ):GoLine(nT5Q)

												If !oModel:GetModel( 'MODEL_T5Q' ):IsEmpty()

													If !oModel:GetModel( 'MODEL_T5Q' ):IsDeleted()

														aAdd (aGravaT5Q ,{oModelT06:GetValue('T06_IDEDMD'),;
																		oModelT5I:GetValue('T5I_DTACCO'),;
																		oModelT5I:GetValue('T5I_TPACCO'),;
																		oModelT5J:GetValue('T5J_PERREF'),;
																		oModelT5Q:GetValue('T5Q_ESTABE'),;
																		oModelT5Q:GetValue('T5Q_LOTTRB'),;
																		oModelT5Q:GetValue('T5Q_GRAUEX'),;
																		oModelT5Q:GetValue('T5Q_INDCSU')})

														//T5S
														For nT5S := 1 to oModel:GetModel( "MODEL_T5S" ):Length()

															oModel:GetModel( "MODEL_T5S" ):GoLine(nT5S)

															If !oModel:GetModel( 'MODEL_T5S' ):IsEmpty()

																If !oModel:GetModel( "MODEL_T5S" ):IsDeleted()

																	If !lLaySimplif

																		aAdd (aGravaT5S ,{oModelT06:GetValue('T06_IDEDMD'),;
																						oModelT5I:GetValue('T5I_DTACCO'),;
																						oModelT5I:GetValue('T5I_TPACCO'),;
																						oModelT5J:GetValue('T5J_PERREF'),;
																						oModelT5Q:GetValue('T5Q_ESTABE'),;
																						oModelT5Q:GetValue('T5Q_LOTTRB'),;
																						oModelT5S:GetValue('T5S_CODRUB'),;
																						oModelT5S:GetValue('T5S_QTDRUB'),;
																						oModelT5S:GetValue('T5S_FATRUB'),;
																						oModelT5S:GetValue('T5S_VLRUNI'),;
																						oModelT5S:GetValue('T5S_VLRRUB')})

																	Else

																		aAdd (aGravaT5S ,{oModelT06:GetValue('T06_IDEDMD'),;
																						oModelT5I:GetValue('T5I_DTACCO'),;
																						oModelT5I:GetValue('T5I_TPACCO'),;
																						oModelT5J:GetValue('T5J_PERREF'),;
																						oModelT5Q:GetValue('T5Q_ESTABE'),;
																						oModelT5Q:GetValue('T5Q_LOTTRB'),;
																						oModelT5S:GetValue('T5S_CODRUB'),;
																						oModelT5S:GetValue('T5S_SQTDRB'),;
																						oModelT5S:GetValue('T5S_FATRUB'),;
																						oModelT5S:GetValue('T5S_VLRRUB'),;
																						oModelT5S:GetValue('T5S_APURIR')})																
																	EndIf
																EndIf
															EndIf

														Next nT5S

													EndIf
												EndIf

											Next nT5Q

										EndIf
									EndIf

								Next nT5J

							EndIf

						Next nT5I

						//T88
						If !lLaySimplif

							For nT88 := 1 to oModel:GetModel( "MODEL_T88" ):Length()

								oModel:GetModel( "MODEL_T88" ):GoLine( nT88 )

								If !oModel:GetModel( "MODEL_T88" ):IsEmpty() .and. !oModel:GetModel( "MODEL_T88" ):IsDeleted()
									aAdd( aGravaT88, {	oModelT06:GetValue( "T06_IDEDMD" ),;
										oModelT88:GetValue( "T88_IDCODC" ) } )
								EndIf

							Next nT88

						EndIf
					EndIf
				EndIf
			Next nT06
		EndIf

		//C9J
		For nC9J := 1 To oModel:GetModel( 'MODEL_C9J' ):Length()

			oModel:GetModel( 'MODEL_C9J' ):GoLine(nC9J)

			If !oModel:GetModel( 'MODEL_C9J' ):IsDeleted()

				aAdd (aGravaC9J,{ oModelC9J:GetValue('C9J_TPINSC'),;
								  oModelC9J:GetValue('C9J_NRINSC'),;
								  oModelC9J:GetValue('C9J_VLREMU'),;
								  oModelC9J:GetValue('C9J_CODCAT')})
			EndIf

		Next nC9J

		For nT3H := 1 To oModel:GetModel( 'MODEL_T3H' ):Length()

			oModel:GetModel( 'MODEL_T3H' ):GoLine(nT3H)

			If !oModel:GetModel( 'MODEL_T3H' ):IsDeleted()

				aAdd (aGravaT3H ,{ oModelT3H:GetValue('T3H_TPTRIB'),;
								   oModelT3H:GetValue('T3H_IDPROC'),;
								   oModelT3H:GetValue('T3H_CODSUS'),;
								   oModelT3H:GetValue('T3H_IDSUSP')})
			EndIf

		Next nT3H

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seto o campo como Inativo e gravo a versao do novo registro³
		//³no registro anterior                                       ³
		//|                                                           |
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FAltRegAnt( "CMD", "2" )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Neste momento eu preciso setar a operacao do model³
		//³como Inclusao                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oModel:DeActivate()
		oModel:SetOperation( 3 )
		oModel:Activate()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Neste momento eu realizo a inclusao do novo registro ja³
		//³contemplando as informacoes alteradas pelo usuario     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nlI := 1 To Len( aGrava )
			oModel:LoadValue( 'MODEL_CMD', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
		Next

		// T06
		For nT06 := 1 To Len(aGravaT06)

			oModel:GetModel("MODEL_T06"):lValid	:= .T.

			If nT06 > 1
				oModel:GetModel("MODEL_T06"):AddLine()
			EndIf

			oModel:LoadValue("MODEL_T06", "T06_IDEDMD", aGravaT06[nT06][1])

			If lSimplBeta .And. TafColumnPos("T06_INDRRA")

				oModel:LoadValue("MODEL_T06", "T06_INDRRA", aGravaT06[nT06][2])
				oModel:LoadValue("MODEL_T06", "T06_TPPRRA", aGravaT06[nT06][3])
				oModel:LoadValue("MODEL_T06", "T06_NRPRRA", aGravaT06[nT06][4])
				oModel:LoadValue("MODEL_T06", "T06_DESCRA", aGravaT06[nT06][5])
				oModel:LoadValue("MODEL_T06", "T06_QTMRRA", aGravaT06[nT06][6])
				oModel:LoadValue("MODEL_T06", "T06_VLRCUS", aGravaT06[nT06][7])
				oModel:LoadValue("MODEL_T06", "T06_VLRADV", aGravaT06[nT06][8])

				nV9NAdd := 1

				For nV9N := 1 To Len(aGravaV9N)

					If aGravaV9N[nV9N][1] == aGravaT06[nT06][1]

						oModel:GetModel("MODEL_V9N"):lValid := .T.

						If nV9NAdd > 1
							oModel:GetModel("MODEL_V9N"):AddLine()
						EndIf

						oModel:LoadValue("MODEL_V9N", "V9N_TPINSC", aGravaV9N[nV9N][2])
						oModel:LoadValue("MODEL_V9N", "V9N_NRINSC", aGravaV9N[nV9N][3])
						oModel:LoadValue("MODEL_V9N", "V9N_VLRADV", aGravaV9N[nV9N][4])

						nV9NAdd++
					EndIf
				Next
			EndIf

			//T3G
			nT3GAdd := 1
			For nT3G := 1 to Len( aGravaT3G )

				If  aGravaT3G[nT3G][1] == aGravaT06[nT06][1]

					oModel:GetModel( 'MODEL_T3G' ):LVALID := .T.

					If nT3GAdd > 1
						oModel:GetModel( "MODEL_T3G" ):AddLine()
					EndIf

					oModel:LoadValue( "MODEL_T3G", "T3G_ESTABE", aGravaT3G[nT3G][2] )
					oModel:LoadValue( "MODEL_T3G", "T3G_LOTTRB", aGravaT3G[nT3G][3] )
					oModel:LoadValue( "MODEL_T3G", "T3G_GRAUEX", aGravaT3G[nT3G][4] )
					oModel:LoadValue( "MODEL_T3G", "T3G_INDCSU", aGravaT3G[nT3G][5] )

					//T05
					nT05Add := 1
					For nT05 := 1 to Len( aGravaT05 )

						If  aGravaT05[nT05][1] == aGravaT3G[nT3G][1] .AND.;
							aGravaT05[nT05][2] == aGravaT3G[nT3G][2] .AND.;
							aGravaT05[nT05][3] == aGravaT3G[nT3G][3]

							oModel:GetModel( 'MODEL_T05' ):LVALID := .T.

							If nT05Add > 1
								oModel:GetModel( "MODEL_T05" ):AddLine()
							EndIf
							
							If !lLaySimplif
								oModel:LoadValue( "MODEL_T05", "T05_CODRUB", aGravaT05[nT05][4] )
								oModel:LoadValue( "MODEL_T05", "T05_QTDRUB", aGravaT05[nT05][5] )
								oModel:LoadValue( "MODEL_T05", "T05_FATRUB", aGravaT05[nT05][6] )
								oModel:LoadValue( "MODEL_T05", "T05_VLRUNI", aGravaT05[nT05][7] )
								oModel:LoadValue( "MODEL_T05", "T05_VLRRUB", aGravaT05[nT05][8] )
							Else
								oModel:LoadValue( "MODEL_T05", "T05_CODRUB", aGravaT05[nT05][4] )
								oModel:LoadValue( "MODEL_T05", "T05_SQTDRB", aGravaT05[nT05][5] )
								oModel:LoadValue( "MODEL_T05", "T05_FATRUB", aGravaT05[nT05][6] )
								oModel:LoadValue( "MODEL_T05", "T05_VLRRUB", aGravaT05[nT05][7] )
								oModel:LoadValue( "MODEL_T05", "T05_APURIR", aGravaT05[nT05][8] )							
							EndIf

							nT05Add++

						EndIf

					Next nT05

					If !lLaySimplif

						//T15
						nT15Add := 1

						For nT15 := 1 to Len( aGravaT15 )

							If  aGravaT15[nT15][1] == aGravaT3G[nT3G][1] .AND.;
								aGravaT15[nT15][2] == aGravaT3G[nT3G][2] .AND.;
								aGravaT15[nT15][3] == aGravaT3G[nT3G][3]

								oModel:GetModel( 'MODEL_T15' ):LVALID := .T.

								If nT15Add > 1
									oModel:GetModel( "MODEL_T15" ):AddLine()
								EndIf

								oModel:LoadValue( "MODEL_T15", "T15_CNPJOP", aGravaT15[nT15][4] )
								oModel:LoadValue( "MODEL_T15", "T15_REGANS", aGravaT15[nT15][5] )
								oModel:LoadValue( "MODEL_T15", "T15_VLPGTI", aGravaT15[nT15][6] )
								oModel:LoadValue( "MODEL_T15", "T15_NOMEVE", "S2299" 			)

								//T16
								nT16Add := 1
								For nT16 := 1 to Len( aGravaT16 )

									If  aGravaT16[nT16][1] == aGravaT15[nT15][1] .AND.;
										aGravaT16[nT16][2] == aGravaT15[nT15][2] .AND.;
										aGravaT16[nT16][3] == aGravaT15[nT15][3] .AND.;
										aGravaT16[nT16][4] == aGravaT15[nT15][4] .AND.;
										aGravaT16[nT16][5] == aGravaT15[nT15][5]

										oModel:GetModel( 'MODEL_T16' ):LVALID := .T.

										If nT16Add > 1
											oModel:GetModel( "MODEL_T16" ):AddLine()
										EndIf

										oModel:LoadValue( "MODEL_T16", "T16_SEQUEN", aGravaT16[nT16][6] )
										oModel:LoadValue( "MODEL_T16", "T16_CPFDEP", aGravaT16[nT16][7] )
										oModel:LoadValue( "MODEL_T16", "T16_DTNDEP", aGravaT16[nT16][8] )
										oModel:LoadValue( "MODEL_T16", "T16_NOMDEP", aGravaT16[nT16][9] )
										oModel:LoadValue( "MODEL_T16", "T16_VPGDEP", aGravaT16[nT16][10])
										oModel:LoadValue( "MODEL_T16", "T16_TPDEP" , aGravaT16[nT16][11])
										oModel:LoadValue( "MODEL_T16", "T16_NOMEVE", "S2299" 			)

										nT16Add++

									EndIf

								Next nT16

								nT15Add++

							EndIf

						Next nT15

					EndIf

					nT3GAdd++

				EndIf

			Next nT3G

			//T5I
			nT5IAdd := 1
			For nT5I := 1 to Len( aGravaT5I )

				If  aGravaT5I[nT5I][1] == aGravaT06[nT06][1]

					oModel:GetModel( 'MODEL_T5I' ):LVALID	:= .T.

					If nT5IAdd > 1
						oModel:GetModel( "MODEL_T5I" ):AddLine()
					EndIf

					oModel:LoadValue( "MODEL_T5I", "T5I_DTACCO",	aGravaT5I[nT5I][2] )
					oModel:LoadValue( "MODEL_T5I", "T5I_TPACCO",	aGravaT5I[nT5I][3] )
					
					If !lLaySimplif
						oModel:LoadValue( "MODEL_T5I", "T5I_DTEFAC",	aGravaT5I[nT5I][4] )
						oModel:LoadValue( "MODEL_T5I", "T5I_DSC"   ,	aGravaT5I[nT5I][5] )
						oModel:LoadValue( "MODEL_T5I", "T5I_COMPAC",	aGravaT5I[nT5I][6] )
					Else
						oModel:LoadValue( "MODEL_T5I", "T5I_DSC"   ,	aGravaT5I[nT5I][4] )
					EndIf

					//T5J
					nT5JAdd := 1
					For nT5J := 1 to Len( aGravaT5J )

						If  aGravaT5J[nT5J][1] == aGravaT5I[nT5I][1] .AND.;
							aGravaT5J[nT5J][2] == aGravaT5I[nT5I][2] .AND.;
							aGravaT5J[nT5J][3] == aGravaT5I[nT5I][3]

							oModel:GetModel( 'MODEL_T5J' ):LVALID := .T.

							If nT5JAdd > 1
								oModel:GetModel( "MODEL_T5J" ):AddLine()
							EndIf

							oModel:LoadValue( "MODEL_T5J", "T5J_PERREF", aGravaT5J[nT5J][4] )

							//T5Q
							nT5QAdd := 1
							For nT5Q := 1 to Len( aGravaT5Q )

								If  aGravaT5Q[nT5Q][1] == aGravaT5J[nT5J][1] .AND.;
									aGravaT5Q[nT5Q][2] == aGravaT5J[nT5J][2] .AND.;
									aGravaT5Q[nT5Q][3] == aGravaT5J[nT5J][3] .AND.;
									aGravaT5Q[nT5Q][4] == aGravaT5J[nT5J][4]

									oModel:GetModel( 'MODEL_T5Q' ):LVALID := .T.

									If nT5QAdd > 1
										oModel:GetModel( "MODEL_T5Q" ):AddLine()
									EndIf

									oModel:LoadValue( "MODEL_T5Q", "T5Q_ESTABE",	aGravaT5Q[nT5Q][5] )
									oModel:LoadValue( "MODEL_T5Q", "T5Q_LOTTRB",	aGravaT5Q[nT5Q][6] )
									oModel:LoadValue( "MODEL_T5Q", "T5Q_GRAUEX",	aGravaT5Q[nT5Q][7] )
									oModel:LoadValue( "MODEL_T5Q", "T5Q_INDCSU",	aGravaT5Q[nT5Q][8] )

									//T5S
									nT5SAdd := 1
									For nT5S := 1 to Len( aGravaT5S )

										If  aGravaT5S[nT5S][1] == aGravaT5Q[nT5Q][1] .AND.;
											aGravaT5S[nT5S][2] == aGravaT5Q[nT5Q][2] .AND.;
											aGravaT5S[nT5S][3] == aGravaT5Q[nT5Q][3] .AND.;
											aGravaT5S[nT5S][4] == aGravaT5Q[nT5Q][4] .AND.;
											aGravaT5S[nT5S][5] == aGravaT5Q[nT5Q][5] .AND.;
											aGravaT5S[nT5S][6] == aGravaT5Q[nT5Q][6]

											oModel:GetModel( 'MODEL_T5S' ):LVALID := .T.

											If nT5SAdd > 1
												oModel:GetModel( "MODEL_T5S" ):AddLine()
											EndIf

											oModel:LoadValue( "MODEL_T5S", "T5S_CODRUB",	aGravaT5S[nT5S][7] )

											If !lLaySimplif
												oModel:LoadValue( "MODEL_T5S", "T5S_QTDRUB", aGravaT5S[nT5S][8] )
												oModel:LoadValue( "MODEL_T5S", "T5S_FATRUB", aGravaT5S[nT5S][9] )
												oModel:LoadValue( "MODEL_T5S", "T5S_VLRUNI", aGravaT5S[nT5S][10])
												oModel:LoadValue( "MODEL_T5S", "T5S_VLRRUB", aGravaT5S[nT5S][11])
											Else
												oModel:LoadValue( "MODEL_T5S", "T5S_SQTDRB", aGravaT5S[nT5S][8] )
												oModel:LoadValue( "MODEL_T5S", "T5S_FATRUB", aGravaT5S[nT5S][9] )											
												oModel:LoadValue( "MODEL_T5S", "T5S_VLRRUB", aGravaT5S[nT5S][10])
												oModel:LoadValue( "MODEL_T5S", "T5S_APURIR", aGravaT5S[nT5S][11])
											EndIf

											nT5SAdd++
										EndIf

									Next nT5S
								EndIf

							Next nT5Q

							nT5JAdd++
						EndIf

					Next nT5J

					nT5IAdd++
				EndIf

			Next nT5I

			//T88
			If !lLaySimplif

				nT88Add := 1

				For nT88 := 1 to Len( aGravaT88 )

					If aGravaT88[nT88][1] == aGravaT06[nT06][1]

						oModel:GetModel( "MODEL_T88" ):lValid := .T.

						If nT88Add > 1
							oModel:GetModel( "MODEL_T88" ):AddLine()
						EndIf

						oModel:LoadValue( "MODEL_T88", "T88_IDCODC", aGravaT88[nT88][2] )

						nT88Add ++

					EndIf

				Next nT88
			EndIf

		Next nT06

		For nlI := 1 To Len( aGravaC9J )

			If nlI > 1
				oModel:GetModel( 'MODEL_C9J' ):AddLine()
			EndIf

			oModel:LoadValue( "MODEL_C9J", "C9J_TPINSC" , aGravaC9J[nlI][1] )
			oModel:LoadValue( "MODEL_C9J", "C9J_NRINSC" , aGravaC9J[nlI][2] )
			oModel:LoadValue( "MODEL_C9J", "C9J_VLREMU" , aGravaC9J[nlI][3] )
			oModel:LoadValue( "MODEL_C9J", "C9J_CODCAT" , aGravaC9J[nlI][4] )
			oModel:LoadValue( "MODEL_C9J", "C9J_NOMEVE" , "S2299" 			)

		Next

		For nlI := 1 To Len( aGravaT3H )

			If nlI > 1
				oModel:GetModel( 'MODEL_T3H' ):AddLine()
			EndIf

			oModel:LoadValue( "MODEL_T3H", "T3H_TPTRIB" , aGravaT3H[nlI][1] )
			oModel:LoadValue( "MODEL_T3H", "T3H_IDPROC" , aGravaT3H[nlI][2] )
			oModel:LoadValue( "MODEL_T3H", "T3H_CODSUS" , aGravaT3H[nlI][3] )
			oModel:LoadValue( "MODEL_T3H", "T3H_IDSUSP" , aGravaT3H[nlI][4] )
			oModel:LoadValue( "MODEL_T3H", "T3H_NOMEVE" , "S2299" 			)

		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco a versao que sera gravada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVersao := xFunGetVer()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oModel:LoadValue( "MODEL_CMD", "CMD_VERSAO", cVersao 	)
		oModel:LoadValue( "MODEL_CMD", "CMD_VERANT", cVerAnt 	)
		oModel:LoadValue( "MODEL_CMD", "CMD_PROTPN", cProtocolo )
		oModel:LoadValue( "MODEL_CMD", "CMD_PROTUL", "" 		)

		/*---------------------------------------------------------
		Tratamento para que caso o Evento Anterior fosse de exclusão
		seta-se o novo evento como uma "nova inclusão", caso contrário o
		evento passar a ser uma alteração
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_CMD", "CMD_EVENTO", "E" )
		oModel:LoadValue( "MODEL_CMD", "CMD_ATIVO" , "1" )

		//Gravo alteração para o Extemporâneo
		If lGoExtemp
			TafGrvExt( oModel, 'MODEL_CMD', 'CMD' )
		EndIf

		FwFormCommit( oModel )
		TAFAltStat( 'CMD',"6" )

	End Transaction

Return ( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} changeAcCOnv
Realiza de/para do valor da tag tpAcConv

@Param  cVlrOri  -> Valor do campo
@Param  nTpTrc   -> Tipo de Troca

@Return .T.

@Author Evandro dos Santos Oliveira
@Since 16/06/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function changeAcConv(cVlrOri,nTpTrc)

	Local cRet := ""

	Default cVlrOri 	:= ""
	Default nTpTrc 	:= 1

	If !Empty( cVlrOri )
		Do Case
			Case nTpTrc == 1

				if cVlrOri == "1"
					cRet := "A"
				ElseIf cVlrOri == "2"
					cRet := "B"
				ElseIf cVlrOri == "3"
					cRet := "C"
				ElseIf cVlrOri == "4"
					cRet := "D"
				ElseIf cVlrOri == "5"
					cRet := "E"
				ElseIf cVlrOri == "6"
					cRet := "F"
				ElseIf cVlrOri == "7"
					cRet := "G"
				ElseIf cVlrOri == "8"
					cRet := "H"
				EndIf
			Case nTpTrc == 2

				if cVlrOri == "A"
					cRet := "1"
				ElseIf cVlrOri == "B"
					cRet := "2"
				ElseIf cVlrOri == "C"
					cRet := "3"
				ElseIf cVlrOri == "D"
					cRet := "4"
				ElseIf cVlrOri == "E"
					cRet := "5"
				ElseIf cVlrOri == "F"
					cRet := "6"
				ElseIf cVlrOri == "G"
					cRet := "7"
				ElseIf cVlrOri == "H"
					cRet := "8"
				EndIf
		EndCase
	EndIf

Return(cRet)

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
/*/{Protheus.doc} TAF266Rpt
@type			function
@description	Inicializa a variável static __lGrvRPT
@author			Felipe C. Seolin
@since			22/05/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function TAF266Rpt()

	__lGrvRPT := TAFAlsInDic( "V3N" )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} LoadReportData
@type			function
@description	Inicializa a variável static __lGrvRPT
@author			Diego Santos
@since			22/05/2019
@version		1.0
/*/
//---------------------------------------------------------------------

Static Function LoadReportData(oModel, lInfoRPT)

	Local aSaveLines  := FwSaveRows(oModel)
	Local aArea       := GetArea()
	Local oModelT06   := oModel:GetModel("MODEL_T06")
	Local nT06        := 1
	Local nT3G        := 1
	Local nT05        := 1
	Local nT5I        := 1
	Local nT5J        := 1
	Local nT5Q        := 1
	Local nT5S        := 1
	Local nPosValores := 1
	Local aAnalitico  := {}
	Local aRubrica    := {}
	Local cMatric     := ""
	Local cCodCat     := ""

	If nTamCMDFunc == Nil
		nTamCMDFunc := GetSX3Cache("CMD_FUNC", "X3_TAMANHO")
	EndIf

	C9V->( DBSetOrder( 2 ) )
	If C9V->( MSSeek( xFilial( "C9V" ) + PadR(oModel:GetValue("MODEL_CMD","CMD_FUNC"), nTamCMDFunc) + "1" ) )

		cMatric := C9V->C9V_MATRIC

		DBSelectArea( "CUP" )
		CUP->( DBSetOrder( 1 ) )
		If CUP->( MsSeek( xFilial( "CUP" ) + C9V->C9V_ID ) )
			DBSelectArea( "C87" )
			C87->( DBSetOrder( 1 ) )
			If C87->( MsSeek( xFilial( "C87" ) + AllTrim( CUP->CUP_CODCAT ) ) )
				cCodCat := C87->C87_CODIGO
			EndIf
		EndIf

		For nT06 := 1 To oModelT06:Length()

			oModelT06:GoLine( nT06 )

			If !oModelT06:IsEmpty() .And. !oModelT06:IsDeleted()

				//Parte 1 - Começo
				oModelT3G := oModel:GetModel("MODEL_T3G")

				For nT3G := 1 To oModelT3G:Length()

					oModelT3G:GoLine( nT3G )

					If !oModelT3G:IsEmpty() .And. !oModelT3G:IsDeleted()

						oModelT05 := oModel:GetModel("MODEL_T05")

						For nT05 := 1 To oModelT05:Length()

							oModelT05:GoLine( nT05 )

							If !oModelT05:IsEmpty() .And. !oModelT05:IsDeleted()

								If lInfoRPT

									aRubrica := oReport:GetRubrica( oModelT05:GetValue("T05_CODRUB") )

									aAdd( aAnalitico, Array( 16 ) )
									nPosValores := Len( aAnalitico )

									aAnalitico[nPosValores][ANALITICO_MATRICULA]			:=	AllTrim( cMatric )
									aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:=	AllTrim( cCodCat )
									aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:=	AllTrim( Posicione( "C92", 5, xFilial( "C92" ) + oModelT3G:GetValue("T3G_ESTABE") + "1", "C92_TPINSC" ) )
									aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:=	AllTrim( Posicione( "C92", 5, xFilial( "C92" ) + oModelT3G:GetValue("T3G_ESTABE") + "1", "C92_NRINSC" ) )
									aAnalitico[nPosValores][ANALITICO_LOTACAO]				:=	AllTrim( Posicione( "C99", 4, xFilial( "C99" ) + oModelT3G:GetValue("T3G_LOTTRB") + "1", "C99_CODIGO" ) )
									aAnalitico[nPosValores][ANALITICO_NATUREZA]				:=	AllTrim( aRubrica[1] ) //Natureza
									aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:=	AllTrim( aRubrica[2] ) //Tipo
									aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:=	AllTrim( aRubrica[3] ) //Incidência CP
									aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:=	AllTrim( aRubrica[4] ) //Incidência IRRF
									aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:=	AllTrim( aRubrica[5] ) //Incidência FGTS
									aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:=	""
									aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:=	""
									aAnalitico[nPosValores][ANALITICO_VALOR]				:=	oModelT05:GetValue("T05_VLRRUB")
								EndIf
							EndIf

						Next nT05

					EndIf

				Next nT3G
				//Parte 1 - Fim

				//Parte 2 - Começo
				oModelT5I := oModel:GetModel("MODEL_T5I")

				For nT5I := 1 To oModelT5I:Length()

					oModelT5I:GoLine(nT5I)

					If !oModelT5I:IsEmpty() .And. !oModelT5I:IsDeleted()

						oModelT5J := oModel:GetModel("MODEL_T5J")

						For nT5J := 1 To oModelT5J:Length()

							oModelT5J:GoLine( nT5J )

							If !oModelT5J:IsEmpty() .And. !oModelT5J:IsDeleted()

								oModelT5Q := oModel:GetModel("MODEL_T5Q")

								For nT5Q := 1 To oModelT5Q:Length()

									oModelT5Q:GoLine( nT5Q )

									If !oModelT5Q:IsEmpty() .And. !oModelT5Q:IsDeleted()

										oModelT5S := oModel:GetModel("MODEL_T5S")

										For nT5S := 1 To oModelT5S:Length()

											oModelT5S:GoLine( nT5S )

											If !oModelT5S:IsEmpty() .And. !oModelT5S:IsDeleted()

												If lInfoRPT

													aRubrica := oReport:GetRubrica( oModelT5S:GetValue("T5S_CODRUB") )

													aAdd( aAnalitico, Array( 16 ) )
													nPosValores := Len( aAnalitico )

													aAnalitico[nPosValores][ANALITICO_MATRICULA]			:=	AllTrim( cMatric )
													aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:=	AllTrim( cCodCat )
													aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:=	AllTrim( Posicione( "C92", 5, xFilial( "C92" ) + oModelT5Q:GetValue("T5Q_ESTABE") + "1", "C92_TPINSC" ) )
													aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:=	AllTrim( Posicione( "C92", 5, xFilial( "C92" ) + oModelT5Q:GetValue("T5Q_ESTABE") + "1", "C92_NRINSC" ) )
													aAnalitico[nPosValores][ANALITICO_LOTACAO]				:=	AllTrim( Posicione( "C99", 4, xFilial( "C99" ) + oModelT5Q:GetValue("T5Q_LOTTRB") + "1", "C99_CODIGO" ) )
													aAnalitico[nPosValores][ANALITICO_NATUREZA]				:=	AllTrim( aRubrica[1] ) //Natureza
													aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:=	AllTrim( aRubrica[2] ) //Tipo
													aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:=	AllTrim( aRubrica[3] ) //Incidência CP
													aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:=	AllTrim( aRubrica[4] ) //Incidência IRRF
													aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:=	AllTrim( aRubrica[5] ) //Incidência FGTS
													aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:=	""
													aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:=	""
													aAnalitico[nPosValores][ANALITICO_VALOR]				:=	oModelT5S:GetValue("T5S_VLRRUB")
												EndIf
											EndIf

										Next nT5S

									EndIf

								Next nT5Q

							EndIf

						Next nT5J

					EndIf

				Next nT5I
				//Parte 2 - Fim

			EndIf

		Next nT06

	Else
		TAFConOut("Funcionário não encontrado!!! V3N não será gravada")
	EndIf

	RestArea(aArea)
	FWRestRows( aSaveLines )

Return aAnalitico

//---------------------------------------------------------------------
/*/{Protheus.doc} lVldDiaTrb

@description	Valida o dia trabalhado para ser entre 1 e 0
@author			Bruno de Oliveira
@since			11/02/2021
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function lVldDiaTrb(oModel)

	Local oMdlV6D := oModel:GetModel("MODEL_V6D")
	Local nDia    := Val(oMdlV6D:GetValue("MODEL_V6D", "V6D_DIA" ))
	Local lRet    := .T.

	If !(nDia >= 1 .AND. nDia <= 31)
		Help( ,, STR0053,, STR0054, 1, 0 ) //"Atenção" # "Dia permitido entre 1 à 31" 
		lRet := .F.
	EndIf

Return lRet

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
	Local lTAF266Xml as logical
	Local lTAF266GRV as logical
	Local lXTAFVEXC  as logical

	cEsocial   := ""
	lOperation := .F.
	lTAF266Xml := FWIsInCallStack("TAF266Xml")
	lTAF266GRV := FWIsInCallStack("TAF266GRV")
	lXTAFVEXC  := FWIsInCallStack("XTAFVEXC")

	If lTAF266GRV
		cEsocial := cLayNmSpac
	Else
		If Type("INCLUI") != "U" .And. Type("ALTERA") != "U"
			lOperation := !INCLUI .And. !ALTERA
		EndIf

		If lTAF266Xml .Or. lOperation .Or. lXTAFVEXC
			If TAFColumnPos("CMD_LAYOUT")		
				cEsocial := CMD->CMD_LAYOUT
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
