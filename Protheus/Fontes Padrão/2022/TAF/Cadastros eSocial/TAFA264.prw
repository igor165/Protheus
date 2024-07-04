#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA264.CH"
#INCLUDE "TOPCONN.CH"

Static cXmlInteg as  character

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA264
Cadastro MVC de Condições Ambientais do Trabalho - Fatores de Risco (S-2240)

@author Mick William 
@since 15/03/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFA264()

	Private oBrw      as Object
	Private cEvtPosic as Character

	oBrw      := FwMBrowse():New()
	cEvtPosic := ""

	// Função que indica se o ambiente é válido para o eSocial 2.3
	If TafAtualizado() .And. TAF264Struct(.T.)

		oBrw:SetDescription( "Condições Ambientais do Trabalho - Fatores de Risco" ) //"Condições Ambientais do Trabalho - Fatores de Risco"
		oBrw:SetAlias( "CM9" )
		oBrw:SetMenuDef( "TAFA264" )
		
		If FindFunction('TAFSetFilter')
			oBrw:SetFilterDefault(TAFBrwSetFilter("CM9","TAFA264","S-2240"))
		Else
			oBrw:SetFilterDefault( "(CM9_ATIVO == '1')" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1 = Ativo, 2 = Inativo )
		EndIf
		
		//Por conta de condicionais na view, para este modelo não pode ter cache na mesma.
		oBrw:SetCacheView(.F.)
		
		TafLegend(3,"CM9",@oBrw)
		oBrw:Activate()

	EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Mick William
@since 15/03/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao as Array
	Local aRotina as Array

	aFuncao := {}
	aRotina := {}

	aAdd( aFuncao, { "" , "TafxmlRet('TAF264Xml','2240','CM9')"									, "1" } )
	Aadd( aFuncao, { "" , "xNewHisAlt( 'CM9', 'TAFA264' ,,,,,,'2240','TAF264Xml')" 				, "3" } ) //Chamo a Browse do Histórico
	Aadd( aFuncao, { "" , "TAFXmlLote( 'CM9', 'S-2240' , 'evtExpRisco' , 'TAF264Xml',, oBrw )" 	, "5" } )
	Aadd( aFuncao, { "" , "xFunAltRec( 'CM9' )" 												, "10"} )

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If lMenuDif
		ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.TAFA264' OPERATION 2 ACCESS 0 //"Visualizar"
	Else
		aRotina := xFunMnuTAF( "TAFA264" , , aFuncao)
	EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC
@author Mick William
@since 15/03/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local cEsocial   as Character
	Local oStruCM9   as Object
	Local oStruT3S   as Object
	Local oStruT0Q   as Object
	Local oStruCMA   as Object
	Local oStruLEA   as Object
	Local oStruCMB   as Object
	Local oStruV3E   as Object
	Local oModel     as Object
	Local nOperation as Numeric

	cEsocial := SuperGetMV("MV_TAFVLES")
	
	If Type( "INCLUI" ) == "U" .AND. Type( "ALTERA" ) == "U"
		INCLUI := .F.
		ALTERA := .T.
	EndIf
	
	oStruCM9   := FwFormStruct( 1, "CM9" )
	oStruT3S   := FwFormStruct( 1, "T3S" )
	oStruT0Q   := FwFormStruct( 1, "T0Q" )
	oStruCMA   := FwFormStruct( 1, "CMA" )
	oStruLEA   := FwFormStruct( 1, "LEA" )
	oStruCMB   := FwFormStruct( 1, "CMB" )
	oStruV3E   := FwFormStruct( 1, "V3E" )
	oModel     := MpFormModel():New("TAFA264", , , { |oModel| SaveModel( oModel ) })

	nOperation := oModel:GetOperation()

	If TafColumnPos("CM9_LAYOUT") .AND. FindFunction("TafNameEspace")
		If 	FWIsInCallStack("TAFPREPINT")
			cEsocial := Alltrim( TafNameEspace(cXmlInteg) )
		Else
			If !INCLUI .AND. !ALTERA
				cEsocial := AllTrim(CM9->CM9_LAYOUT)
			Else
				if TafLayESoc(AllTrim(CM9->CM9_LAYOUT),,.T.)
					cEsocial := SuperGetMV("MV_TAFVLES")
					cEsocial := IIf(cEsocial $ "S_01_00_00|S_01_01_00", cEsocial, "S_01_00_00")
				Else
					cEsocial := AllTrim(CM9->CM9_LAYOUT)
				EndIf
			EndIf	
		EndIf
	Else
		cEsocial := IIf(cEsocial $ "S_01_00_00|S_01_01_00", cEsocial, "S_01_00_00")
	EndIf

	oStruT3S:RemoveField('T3S_DTINI')
	oStruT3S:RemoveField('T3S_DTFIM')
	oStruT3S:RemoveField('T3S_NMRES')
	oStruT3S:RemoveField('T3S_NISRES')
	oStruT0Q:RemoveField('T0Q_CODAMB')
	oStruT0Q:RemoveField('T0Q_DATIVD')
	oStruT0Q:RemoveField('T0Q_DCODAM')
	oStruCMA:RemoveField("CMA_DSCFAT")
	oStruCMA:RemoveField("CMA_PERICU")
	oStruCMA:RemoveField("CMA_INSALU")
	oStruCMA:RemoveField("CMA_APOESP")
	oStruCMB:RemoveField("CMB_CODAMB")
	oStruCMB:RemoveField("CMB_CAEPI")
	oStruCMB:RemoveField("CMB_MEDPRT")
	oStruCMB:RemoveField("CMB_CNDFUN")
	oStruCMB:RemoveField("CMB_PRZVLD")
	oStruCMB:RemoveField("CMB_PERTRC")
	oStruCMB:RemoveField("CMB_HIGIEN")
	oStruCMB:RemoveField("CMB_USOINI")
	oStruCM9:RemoveField("CM9_METERG")
	oStruCMA:RemoveField("CMA_CODFAT")
	oStruCMA:RemoveField("CMA_DCODFA")
	oStruV3E:RemoveField("V3E_IDATV")
	oStruV3E:RemoveField("V3E_DESCAT")
	oStruV3E:RemoveField("V3E_VERSAO")
	oStruCMA:RemoveField("CMA_CODAMB")
	oStruLEA:RemoveField("LEA_CODAMB")
	oStruLEA:RemoveField("LEA_CODFAT")

	If TafColumnPos("LEA_EFIEPI")
		oStruCMB:RemoveField("CMB_EFIEPI")
	EndIf

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruCM9:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel } )
		oStruCMB:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel } )
		oStruT0Q:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel } )
	EndIf

	If CM9->CM9_STATUS == "4" .AND. nOperation == MODEL_OPERATION_UPDATE
		oStruCM9:SetProperty( "CM9_FUNC"  , MODEL_FIELD_NOUPD   , .T. )
		oStruCM9:SetProperty( "CM9_DTINI" , MODEL_FIELD_NOUPD   , .T. )
	EndIf

	oStruCMA:SetProperty( 'CMA_TPAVAL'  , MODEL_FIELD_OBRIGAT , .F.  )
	oStruCMB:SetProperty( 'CMB_DVAL'   	, MODEL_FIELD_OBRIGAT , .T.  )
	oStruT3S:SetProperty( 'T3S_NROC'  	, MODEL_FIELD_OBRIGAT , .F.  )

	//Remoção do GetSX8Num quando se tratar da Exclusão de um Evento Transmitido.
	//Necessário para não incrementar ID que não será utilizado.
	If Upper( ProcName( 2 ) ) == Upper( "GerarExclusao" )
		oStruCM9:SetProperty( "CM9_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )
	EndIf
	
	oModel:AddFields( "MODEL_CM9", /*cOwner*/, oStruCM9 )

	oModel:AddGrid("MODEL_T3S", "MODEL_CM9", oStruT3S)
	oModel:GetModel( "MODEL_T3S" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_T3S" ):SetUniqueLine({"T3S_NROC","T3S_UFOC", "T3S_CPFRES"})
	oModel:GetModel( 'MODEL_T3S' ):SetMaxLine(99)

	oModel:AddGrid("MODEL_T0Q", "MODEL_CM9", oStruT0Q)
	oModel:GetModel( "MODEL_T0Q" ):SetOptional( .T. )
	
	oModel:GetModel( "MODEL_T0Q" ):SetUniqueLine({"T0Q_TPINSC","T0Q_NRINSC"})
	oModel:GetModel( "MODEL_T0Q" ):SetMaxLine(9)

	oModel:AddGrid( "MODEL_CMA", "MODEL_CM9", oStruCMA )
	oModel:GetModel( "MODEL_CMA" ):SetOptional( .T. )

	If "CMA_DSAG" $ FWX2Unico( 'CMA') 
		oModel:GetModel( "MODEL_CMA" ):SetUniqueLine({"CMA_CODAG", "CMA_DSAG"})
	Else
		oModel:GetModel( "MODEL_CMA" ):SetUniqueLine({"CMA_CODAG"})
	EndIf

	oModel:GetModel( 'MODEL_CMA' ):SetMaxLine(999)

	oModel:AddGrid( "MODEL_LEA", "MODEL_CMA", oStruLEA )
	oModel:GetModel( "MODEL_LEA" ):SetOptional( .T. )

	If "LEA_DSAG" $ FWX2Unico( 'LEA')
		oModel:GetModel( "MODEL_LEA" ):SetUniqueLine( {"LEA_CODAG","LEA_DSAG" } )
	Else
		oModel:GetModel( "MODEL_LEA" ):SetUniqueLine( {"LEA_CODAG" } )
	EndIf
	
	oModel:GetModel( 'MODEL_LEA' ):SetMaxLine(1)

	oModel:AddGrid(  "MODEL_CMB", "MODEL_LEA", oStruCMB )
	oModel:GetModel( "MODEL_CMB" ):SetOptional( .T. )
	
	If cEsocial $ "S_01_01_00"
		oModel:GetModel( "MODEL_CMB" ):SetUniqueLine({"CMB_DVAL"})
	Else
		oModel:GetModel( "MODEL_CMB" ):SetUniqueLine({"CMB_DVAL", "CMB_IDDESC"})
	EndIf

	oModel:GetModel( 'MODEL_CMB' ):SetMaxLine(50)

	oModel:SetRelation( "MODEL_T3S" , { { "T3S_FILIAL", "xFilial('T3S')" }, { "T3S_ID", "CM9_ID" }, { "T3S_VERSAO", "CM9_VERSAO" } }, T3S->(IndexKey(1) ) )
	oModel:SetRelation( "MODEL_T0Q" , { { "T0Q_FILIAL", "xFilial('T0Q')" }, { "T0Q_ID", "CM9_ID" }, { "T0Q_VERSAO", "CM9_VERSAO" } }, T0Q->(IndexKey(1) ) )
	oModel:SetRelation( "MODEL_CMA" , { { "CMA_FILIAL", "xFilial('CMA')" }, { "CMA_ID", "CM9_ID" }, { "CMA_VERSAO", "CM9_VERSAO" } }, CMA->( IndexKey(1) ) )

	If TAFColumnPos("LEA_DSAG") .And. (FWIsInCallStack("TAFPREPINT") .Or. !TAF264DAG())
		oModel:SetRelation( "MODEL_LEA" , { { "LEA_FILIAL", "xFilial('LEA')" }, { "LEA_ID", "CM9_ID" }, { "LEA_VERSAO", "CM9_VERSAO" }, { "LEA_CODAG", "CMA_CODAG" }, {"LEA_DSAG","CMA_DSAG"} }, LEA->( IndexKey( 1 ) ) )
		oModel:SetRelation( "MODEL_CMB" , { { "CMB_FILIAL", "xFilial('CMB')" }, { "CMB_ID", "CM9_ID" }, { "CMB_VERSAO", "CM9_VERSAO" }, { "CMB_CODAGE", "CMA_CODAG" }, {"CMB_DSAG","CMA_DSAG"} }, CMB->( IndexKey( 1 ) ) )
		
	Else
		oModel:SetRelation( "MODEL_LEA" , { { "LEA_FILIAL", "xFilial('LEA')" }, { "LEA_ID", "CM9_ID" }, { "LEA_VERSAO", "CM9_VERSAO" }, { "LEA_CODAG", "CMA_CODAG" }}, LEA->( IndexKey( 1 ) ) )
		oModel:SetRelation( "MODEL_CMB" , { { "CMB_FILIAL", "xFilial('CMB')" }, { "CMB_ID", "CM9_ID" }, { "CMB_VERSAO", "CM9_VERSAO" }, { "CMB_CODAGE", "CMA_CODAG" }}, CMB->( IndexKey( 1 ) ) )

	EndIf	

	oStruCMA:SetProperty("CMA_CODAG",MODEL_FIELD_OBRIGAT,.T.)

	oModel:GetModel( "MODEL_CM9" ):SetPrimaryKey( { "CM9_FUNC" } )

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mick William
@since 15/03/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel    as Object
	Local oStruCM9  as Object
	Local oStruCM9p as Object
	Local oStruCM9q as Object
	Local oStruT3S  as Object
	Local oStruT0Q  as Object
	Local oStruCMA  as Object
	Local oStruLEA  as Object
	Local oStruCMB  as Object
	Local oStruV3E  as Object
	Local cCmpFil   as Character
	Local cEsocial  as Character
	Local lDescLeg  as Logical
	
	oModel    := FWLoadModel("TAFA264")
	oStruCM9  := Nil
	oStruCM9p := Nil
	oStruCM9q := Nil
	oStruT3S  := Nil
	oStruT0Q  := Nil
	oStruCMA  := Nil
	oStruLEA  := Nil
	oStruCMB  := Nil
	oStruV3E  := Nil
	cCmpFil   := ""
	cEsocial  := ""
	lDescLeg  := .F.
	
	If Type( "INCLUI" ) == "U" .AND. Type( "ALTERA" ) == "U"
		INCLUI := .F.
		ALTERA := .T.
	EndIf

	If TafColumnPos("CM9_LAYOUT") .AND. !INCLUI .AND. !ALTERA
		cEsocial := AllTrim(CM9->CM9_LAYOUT)
	Else
		cEsocial := SuperGetMV("MV_TAFVLES")
		cEsocial := IIf(cEsocial $ "S_01_00_00|S_01_01_00", cEsocial, "S_01_00_00")
	EndIf	

	oView		:= FWFormView():New()

	oView:SetModel( oModel )
	oView:SetContinuousForm()

	oStruT3S := FWFormStruct(2,"T3S")

	cCmpFil  	:= "CM9_ID|CM9_VERSAO|CM9_FUNC|CM9_DFUNC|CM9_DTINI|CM9_DTALT|CM9_DTFIM|CM9_STATUS|CM9_EVENTO|CM9_ATIVO|CM9_DATIVD|CM9_OBSCMP|CM9_NOMEVE|"

	oStruCM9 	:= FwFormStruct( 2, "CM9", { |x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos de Inclusão

	cCmpFil  	:= "CM9_PROTUL|"
	oStruCM9p 	:= FwFormStruct( 2, 'CM9', {|x| AllTrim( x ) + "|" $ cCmpFil } ) //Protocolo de Transmissão

	If TafColumnPos("CM9_DTRANS")
		cCmpFil := "CM9_DINSIS|CM9_DTRANS|CM9_HTRANS|CM9_DTRECP|CM9_HRRECP|"
		oStruCM9q 	:= FwFormStruct( 2, 'CM9', {|x| AllTrim( x ) + "|" $ cCmpFil } )
	EndIf

	If TAFColumnPos("T0Q_LAMB")
		cCmpFil		:="T0Q_LAMB|T0Q_DSETOR|T0Q_TPINSC|T0Q_NRINSC|"	
	EndIf

	oStruT0Q	:= FwFormStruct( 2, "T0Q", { |x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos da Aba 'Informações do ambiente do trabalho'

	cCmpFil  	:= "CMA_CODAG|CMA_INTCON|CMA_TECMED|CMA_UTLEPI|CMA_LIMTOL|CMA_UNMED|CMA_TPAVAL|"

	If TAF264DAG()
		cCmpFil += "CMA_DSAG|"
		lDescLeg := .T. 
	Else 
		cCmpFil += "CMA_DVAGNO|CMA_DAGNOC|"
	EndIf 

	oStruCMA 	:= FwFormStruct( 2, "CMA", { |x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do Aba Fatores de Riscos

	cCmpFil 	:= "LEA_UTZEPC|LEA_UTZEPI|LEA_EFIEPC|LEA_MEDPRT|LEA_CNDFUN|LEA_PRZVLD|LEA_PERTRC|LEA_HIGIEN|LEA_USOINI|"

	If TafColumnPos("LEA_EFIEPI")
		cCmpFil += "LEA_EFIEPI|"
	EndIf

	oStruLEA    := FwFormStruct( 2, "LEA", { |x| AllTrim( x ) + "|" $ cCmpFil } ) //Informações relativas ao IPI

	If TafColumnPos("CMB_DVAL")
		If TafColumnPos("LEA_EFIEPI")
			cCmpFil  	:= "CMB_IDDESC|CMB_DVAL|"
		Else
			cCmpFil  	:= "CMB_EFIEPI|CMB_IDDESC|CMB_DVAL|"
		EndIF
	EndIf

	oStruCMB 	:= FwFormStruct( 2, "CMB", { |x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do Aba Epis

	oStruV3E    := FwFormStruct( 2, "V3E" ) //Informações relativas ao IPI

	If lDescLeg
		oStruCMA:SetProperty("CMA_DSAG", MVC_VIEW_CANCHANGE, .T.)
	EndIf 

	oStruT3S:RemoveField('T3S_DTINI')
	oStruT3S:RemoveField('T3S_DTFIM')
	oStruT3S:RemoveField('T3S_NMRES')
	oStruT3S:RemoveField('T3S_NISRES')
	oStruT0Q:RemoveField('T0Q_CODAMB')
	oStruT0Q:RemoveField('T0Q_DCODAM')
	oStruT0Q:RemoveField('T0Q_DATIVD')
	oStruCMA:RemoveField("CMA_DSCFAT")
	oStruCMA:RemoveField("CMA_CODFAT")
	oStruCMA:RemoveField("CMA_DCODFA")
	oStruCMA:RemoveField("CMA_PERICU")
	oStruCMA:RemoveField("CMA_INSALU")
	oStruCMA:RemoveField("CMA_APOESP")
	oStruCMB:RemoveField("CMB_CODAMB")
	oStruCMB:RemoveField("CMB_CAEPI")
	oStruCMB:RemoveField("CMB_MEDPRT")
	oStruCMB:RemoveField("CMB_CNDFUN")
	oStruCMB:RemoveField("CMB_PRZVLD")
	oStruCMB:RemoveField("CMB_PERTRC")
	oStruCMB:RemoveField("CMB_HIGIEN")
	oStruCMB:RemoveField("CMB_USOINI")
	oStruCM9:RemoveField("CM9_METERG")
	oStruV3E:RemoveField("V3E_IDATV")
	oStruV3E:RemoveField("V3E_DESCAT")
	oStruV3E:RemoveField("V3E_VERSAO")
	oStruCMA:RemoveField("CMA_CODAMB")
	oStruLEA:RemoveField("LEA_CODAMB")
	oStruLEA:RemoveField("LEA_CODFAT")
	oStruCM9:RemoveField("CM9_NOMEVE")

	If cEsocial $ "S_01_01_00"
		oStruCMB:RemoveField("CMB_IDDESC")
	EndIf
	
	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruCM9p,"CM9")
	EndIf

	oView:AddField( "VIEW_CM9"	, oStruCM9	, "MODEL_CM9" )//"Condições Ambientais do Trabalho - Fatores de Risco"
	oView:AddField( 'VIEW_CM9p' , oStruCM9p	, 'MODEL_CM9' )//'Protocolo de Última Transmissão'

	If TafColumnPos("CM9_PROTUL")
		oView:EnableTitleView( 'VIEW_CM9p', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"  
	EndIf 

	If TafColumnPos("CM9_DTRANS")
		oView:AddField( 'VIEW_CM9q' , oStruCM9q	, 'MODEL_CM9' )
		oView:EnableTitleView( 'VIEW_CM9q', TafNmFolder("recibo",2) )
	EndIf

	oView:AddGrid( 'VIEW_T3S'	, oStruT3S 	, 'MODEL_T3S'  )//'Informações relativas ao responsável pelos registros ambientais'
	oView:AddGrid( 'VIEW_T0Q'	, oStruT0Q 	, 'MODEL_T0Q'  )//'Informações do ambiente do trabalho'
	oView:AddGrid( 'VIEW_CMA'	, oStruCMA 	, 'MODEL_CMA'  )//'Fatores de Riscos'
	oView:AddGrid( 'VIEW_LEA'  	, oStruLEA	, 'MODEL_LEA'  )//'Informações relativas ao EPI/EPC'
	oView:AddGrid( 'VIEW_CMB'  	, oStruCMB	, 'MODEL_CMB'  )//'EPI(s)'	

	//Painel Superior
	oView:CreateHorizontalBox( 'PAINEL_SUPERIOR', 100 )

	oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL_SUPERIOR' )

	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0014) //"Informações sobre o ambiente de trabalho e exposição a fatores de risco"
	oView:CreateHorizontalBox( 'PAINEL_01', 25,,, 'FOLDER_SUPERIOR', 'ABA01' )

	If FindFunction("TafNmFolder")
		oView:AddSheet( 'FOLDER_SUPERIOR', "ABA02", TafNmFolder("recibo") )   //"Numero do Recibo"
	Else
		oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0015 ) //"Protocolo"
	EndIf 

	If TafColumnPos("CM9_DTRANS")
		oView:CreateHorizontalBox( 'PAINEL_02', 20,,, 'FOLDER_SUPERIOR', 'ABA02' )
		oView:CreateHorizontalBox( 'PAINEL_03', 80,,, 'FOLDER_SUPERIOR', 'ABA02' )
	Else
		oView:CreateHorizontalBox( 'PAINEL_02', 100,,, 'FOLDER_SUPERIOR', 'ABA02' )
	EndIf

	//Painel Superior/Painel Inferior
	oView:CreateHorizontalBox( 'PAINEL_INFERIOR', 75,,, 'FOLDER_SUPERIOR', 'ABA01' ) 

	oView:CreateFolder( 'FOLDER_INFERIOR', 'PAINEL_INFERIOR' )

	oView:AddSheet( 'FOLDER_INFERIOR', 'ABA01', STR0016) //'Informações do ambiente do trabalho'
	oView:CreateHorizontalBox( 'GRIDC_01', 25,,, 'FOLDER_INFERIOR', 'ABA01' )

	oView:AddSheet( 'FOLDER_INFERIOR', 'ABA04', "Fator de Risco") //"Fator de Risco"

	oView:AddSheet( 'FOLDER_INFERIOR', 'ABA02', STR0017) //'Informações relativas ao responsável pelos registros ambientais'
	oView:CreateHorizontalBox( 'GRIDR_01', 100,,, 'FOLDER_INFERIOR', 'ABA02' )

	//Fator de Risco					
	oView:EnableTitleView('VIEW_CMA',STR0018)						
	oView:CreateHorizontalBox('GRIDC_02', 25,,, 'FOLDER_INFERIOR', 'ABA04' )	

	//Informações relativas ao EPI/EPC
	oView:EnableTitleView('VIEW_LEA',STR0019)
	oView:CreateHorizontalBox('GRIDC_03', 25,,, 'FOLDER_INFERIOR', 'ABA04' )	

	//Folder obrigatória para o sheet
	oView:EnableTitleView('VIEW_CMB',STR0011)
	oView:CreateHorizontalBox('GRIDC_04', 25,,, 'FOLDER_INFERIOR', 'ABA04' )

	oView:SetOwnerView( 'VIEW_CM9' 	, 'PAINEL_01')
	oView:SetOwnerView( 'VIEW_CM9p'	, 'PAINEL_02')
	
	If TafColumnPos("CM9_DTRANS")
		oView:SetOwnerView( 'VIEW_CM9q'	, 'PAINEL_03')
	EndIf
	
	oView:SetOwnerView( 'VIEW_T3S' 	, 'GRIDR_01' )
	oView:SetOwnerView( 'VIEW_T0Q' 	, 'GRIDC_01' )
	oView:SetOwnerView( 'VIEW_CMA' 	, 'GRIDC_02' )
	oView:SetOwnerView( 'VIEW_LEA' 	, 'GRIDC_03' )
	oView:SetOwnerView( 'VIEW_CMB' 	, 'GRIDC_04' )

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If !lMenuDif
		xFunRmFStr( @oStruCM9, "CM9" )
		xFunRmFStr( @oStruT0Q, "T0Q" )
		xFunRmFStr( @oStruCMA, "CMA" )
		xFunRmFStr( @oStruCMB, "CMB" ) 	
	EndIf

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no fin1al, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Mick William
@since 15/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local cVerAnt    as Character
	Local cProtocolo as Character
	Local cVersao    as Character
	Local cChvRegAnt as Character
	Local cLogOpeAnt as Character
	Local cEsocial   as Character
	Local nOperation as Numeric
	Local nI         as Numeric
	Local nlI        as Numeric
	Local nT0Q       as Numeric
	Local nT3S       as Numeric
	Local nCMA       as Numeric
	Local nCMAAdd    as Numeric
	Local nCMB       as Numeric
	Local nCMBAdd    as Numeric
	Local aGravaCM9  as Array
	Local aGravaT0Q  as Array
	Local aGravaCMA  as Array
	Local aGravaCMB  as Array
	Local aGravaLEA  as Array
	Local aGravaT3S  as Array
	Local oModelCM9  as Object
	Local oModelT0Q  as Object
	Local oModelCMA  as Object
	Local oModelLEA  as Object
	Local oModelCMB  as Object
	Local oModelT3S  as Object
	Local lRetorno   as Logical
	
	cVerAnt    := ""
	cProtocolo := ""
	cVersao    := ""
	cChvRegAnt := ""
	cLogOpeAnt := ""
	cEsocial := SuperGetMV("MV_TAFVLES")
	nOperation := oModel:GetOperation()
	nI         := 0
	nlI        := 0
	nT0Q       := 0
	nT3S       := 0
	nCMA       := 0
	nCMAAdd    := 0
	nCMB       := 0
	nCMBAdd    := 0
	aGravaCM9  := {}
	aGravaT0Q  := {}
	aGravaCMA  := {}
	aGravaCMB  := {}
	aGravaLEA  := {}
	aGravaT3S  := {}
	oModelCM9  := Nil
	oModelT0Q  := Nil
	oModelCMA  := Nil
	oModelLEA  := Nil
	oModelCMB  := Nil
	oModelT3S  := Nil
	lRetorno   := .T.
	
	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT

			TafAjustID( "CM9", oModel)

			oModel:LoadValue( "MODEL_CM9", "CM9_VERSAO", xFunGetVer() )
		
			If TafColumnPos("CM9_LAYOUT")
				oModel:LoadValue( "MODEL_CM9", "CM9_LAYOUT", IIf(cEsocial $ "S_01_00_00|S_01_01_00", cEsocial, "S_01_00_00"))
			EndIf

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_CM9', 'CM9_LOGOPE' , '2', '' )
			EndIf

			FwFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CM9->( DBSetOrder( 3 ) )
			If lGoExtemp .OR. CM9->( MsSeek( xFilial( "CM9" ) + CM9->CM9_ID + "1" ) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o registro ja foi transmitido³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If CM9->CM9_STATUS == "4"

					oModelCM9 := oModel:GetModel( "MODEL_CM9" )
					oModelT0Q := oModel:GetModel( "MODEL_T0Q" )
					oModelCMA := oModel:GetModel( "MODEL_CMA" )
					oModelLEA := oModel:GetModel( "MODEL_LEA" )
					oModelCMB := oModel:GetModel( "MODEL_CMB" )
					oModelT3S := oModel:GetModel( "MODEL_T3S" )	

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao anterior do registro para gravacao do rastro³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVerAnt    := oModelCM9:GetValue( "CM9_VERSAO" )
					cProtocolo := oModelCM9:GetValue( "CM9_PROTUL" )
					
					If TafColumnPos( "CM9_LOGOPE" )
						cLogOpeAnt := oModelCM9:GetValue( "CM9_LOGOPE" )	
					endif
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu gravo as informacoes que foram carregadas       ³
					//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
					//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
					//³nao devem ser consideradas neste momento                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu gravo as informacoes que foram carregadas       ³
					//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
					//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
					//³nao devem ser consideradas neste momento                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nI := 1 to Len( oModelCM9:aDataModel[ 1 ] )
						aAdd( aGravaCM9, { oModelCM9:aDataModel[ 1, nI, 1 ], oModelCM9:aDataModel[ 1, nI, 2 ] } )
					Next
					
					//T3S				  
					For nT3S := 1 To oModel:GetModel( 'MODEL_T3S' ):Length() 
						oModel:GetModel( 'MODEL_T3S' ):GoLine(nT3S)
						
						If !oModel:GetModel( 'MODEL_T3S' ):IsDeleted()
							aAdd( aGravaT3S, { 	oModelT3S:GetValue( "T3S_NROC"  	),;
												oModelT3S:GetValue( "T3S_UFOC"  	),;
												oModelT3S:GetValue( "T3S_CPFRES" 	),;
												oModelT3S:GetValue( "T3S_IDEOC"  	),;
												oModelT3S:GetValue( "T3S_DSCOC"  	)})
						EndIf	

					Next nT3S //Fim - T3S

					For nCMA := 1 To oModel:GetModel( 'MODEL_CMA' ):Length() 

						oModel:GetModel( 'MODEL_CMA' ):GoLine(nCMA)
								
						If !oModel:GetModel( 'MODEL_CMA' ):IsDeleted()     

							If !oModel:GetModel( 'MODEL_CMA' ):IsDeleted()

								aAdd( aGravaCMA, {  oModelCMA:GetValue( "CMA_CODAG"  ),;
													oModelCMA:GetValue( "CMA_INTCON" ),;
													oModelCMA:GetValue( "CMA_TECMED" ),;
													oModelCMA:GetValue( "CMA_LIMTOL" ),;
													oModelCMA:GetValue( "CMA_UNMED"  ),;
													oModelCMA:GetValue( "CMA_TPAVAL" ),;
													oModelCMA:GetValue( "CMA_DSAG"   ),;
													Iif(TafColumnPos("CMA_DAGNOC"),oModelCMA:GetValue( "CMA_DAGNOC" ),'')})
																	
							EndIf
			
							If !oModel:GetModel( 'MODEL_LEA' ):IsEmpty()
									
								oModel:GetModel( 'MODEL_LEA' ):GoLine()
				
								If !oModel:GetModel( 'MODEL_LEA' ):IsDeleted()

									If !TafColumnPos("LEA_EFIEPI")

										aAdd( aGravaLEA, { 	oModelCMA:GetValue( "CMA_CODAG"  ),;
															oModelLEA:GetValue( "LEA_UTZEPC" ),;
															oModelLEA:GetValue( "LEA_UTZEPI" ),;
															oModelLEA:GetValue( "LEA_EFIEPC" ),;
															oModelLEA:GetValue( "LEA_MEDPRT" ),;
															oModelLEA:GetValue( "LEA_CNDFUN" ),;
															oModelLEA:GetValue( "LEA_PRZVLD" ),;
															oModelLEA:GetValue( "LEA_PERTRC" ),;
															oModelLEA:GetValue( "LEA_HIGIEN" ),;
															oModelLEA:GetValue( "LEA_USOINI" )})
									Else

										aAdd( aGravaLEA, { 	oModelCMA:GetValue( "CMA_CODAG"  ),;
															oModelLEA:GetValue( "LEA_UTZEPC" ),;
															oModelLEA:GetValue( "LEA_UTZEPI" ),;
															oModelLEA:GetValue( "LEA_EFIEPC" ),;
															oModelLEA:GetValue( "LEA_MEDPRT" ),;
															oModelLEA:GetValue( "LEA_CNDFUN" ),;
															oModelLEA:GetValue( "LEA_PRZVLD" ),;
															oModelLEA:GetValue( "LEA_PERTRC" ),;
															oModelLEA:GetValue( "LEA_HIGIEN" ),;
															oModelLEA:GetValue( "LEA_USOINI" ),;
															oModelLEA:GetValue( "LEA_EFIEPI" )})
									
									EndIf

									//CMB		
									If !oModel:GetModel( 'MODEL_CMB' ):IsEmpty()

										For nCMB := 1 To oModel:GetModel( 'MODEL_CMB' ):Length() 

											oModel:GetModel( 'MODEL_CMB' ):GoLine(nCMB)

											If !oModel:GetModel( 'MODEL_CMB' ):IsDeleted()

												If !TafColumnPos("LEA_EFIEPI")

													aAdd (aGravaCMB ,{	oModelCMA:GetValue( "CMA_CODAG" ),;
																		oModelCMB:GetValue( "CMB_EFIEPI"),;
																		oModelCMB:GetValue( "CMB_IDDESC"),;
																		oModelCMB:GetValue( "CMB_DVAL"  )})

												Else

													aAdd (aGravaCMB ,{	oModelCMA:GetValue( "CMA_CODAG" ),;
																		oModelCMB:GetValue( "CMB_IDDESC"),;
																		oModelCMB:GetValue( "CMB_DVAL"  )})
												EndIf

											EndIf

										Next nCMB //Fim - CMB				
					
									EndIf						 
								EndIf
							EndIf
						EndIf
					
					Next nCMA //Fim - CMA
								
					For nT0Q := 1 To oModel:GetModel( 'MODEL_T0Q' ):Length()
						oModel:GetModel( 'MODEL_T0Q' ):Goline(nT0Q) 
			
						If !oModel:GetModel( 'MODEL_T0Q' ):IsDeleted()								
							aAdd( aGravaT0Q, {  oModelT0Q:GetValue( "T0Q_LAMB" ),;
												oModelT0Q:GetValue( "T0Q_DSETOR" ),;
												oModelT0Q:GetValue( "T0Q_TPINSC" ),;
												oModelT0Q:GetValue( "T0Q_NRINSC" )})
				
						EndIf
					Next nT0Q //Fim - T0Q	
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seto o campo como Inativo e gravo a versao do novo registro³
					//³no registro anterior                                       ³
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FAltRegAnt( "CM9", "2" )	

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
					For nlI := 1 To Len( aGravaCM9 )	
						oModel:LoadValue( 'MODEL_CM9', aGravaCM9[ nlI, 1 ], aGravaCM9[ nlI, 2 ] )
					Next  

					If  TafColumnPos("CM9_LAYOUT")
						oModel:LoadValue( "MODEL_CM9", "CM9_LAYOUT", IIf(cEsocial $ "S_01_00_00|S_01_01_00", cEsocial, "S_01_00_00"))
					EndIf 
					
					//Necessário Abaixo do For Nao Retirar
					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_CM9', 'CM9_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					For nT3S := 1 To Len( aGravaT3S )
						oModel:GetModel( 'MODEL_T3S' ):LVALID	:= .T.
			
						If nT3S > 1
							oModel:GetModel( 'MODEL_T3S' ):AddLine()
						EndIf				
											
						oModel:LoadValue( "MODEL_T3S", "T3S_NROC"  	, aGravaT3S[nT3S][1] ) 
						oModel:LoadValue( "MODEL_T3S", "T3S_UFOC"  	, aGravaT3S[nT3S][2] )
						oModel:LoadValue( "MODEL_T3S", "T3S_CPFRES"	, aGravaT3S[nT3S][3] )
						oModel:LoadValue( "MODEL_T3S", "T3S_IDEOC"  , aGravaT3S[nT3S][4] )
						oModel:LoadValue( "MODEL_T3S", "T3S_DSCOC"  , aGravaT3S[nT3S][5] )
								
					Next nT3S //Fim - T3S		
					
					For nT0Q := 1 To Len( aGravaT0Q )
						oModel:GetModel( 'MODEL_T0Q' ):LVALID	:= .T.
			
						If nT0Q > 1 
							oModel:GetModel( 'MODEL_T0Q' ):AddLine()
						EndIf

						oModel:LoadValue( "MODEL_T0Q", "T0Q_LAMB"  , aGravaT0Q[nT0Q][1] )
						oModel:LoadValue( "MODEL_T0Q", "T0Q_DSETOR", aGravaT0Q[nT0Q][2] )
						oModel:LoadValue( "MODEL_T0Q", "T0Q_TPINSC", aGravaT0Q[nT0Q][3] )
						oModel:LoadValue( "MODEL_T0Q", "T0Q_NRINSC", aGravaT0Q[nT0Q][4] )
			
					Next nT0Q //Fim - T0Q

					nCMAAdd := 1
					For nCMA := 1 To Len( aGravaCMA )
					
						oModel:GetModel( 'MODEL_CMA' ):LVALID	:= .T.
			
						If nCMAAdd > 1
							oModel:GetModel( 'MODEL_CMA' ):AddLine()
						EndIf
						
						oModel:LoadValue( "MODEL_CMA", "CMA_CODAG"	, aGravaCMA[nCMA][1] )
						oModel:LoadValue( "MODEL_CMA", "CMA_INTCON"	, aGravaCMA[nCMA][2] )
						oModel:LoadValue( "MODEL_CMA", "CMA_TECMED"	, aGravaCMA[nCMA][3] )
						oModel:LoadValue( "MODEL_CMA", "CMA_LIMTOL"	, aGravaCMA[nCMA][4] )
						oModel:LoadValue( "MODEL_CMA", "CMA_UNMED" 	, aGravaCMA[nCMA][5] )
						oModel:LoadValue( "MODEL_CMA", "CMA_TPAVAL"	, aGravaCMA[nCMA][6] )
						oModel:LoadValue( "MODEL_CMA", "CMA_DSAG"	, aGravaCMA[nCMA][7] )

						If TafColumnPos("CMA_DAGNOC")
							oModel:LoadValue( "MODEL_CMA", "CMA_DAGNOC"	, aGravaCMA[nCMA][8] )
						EndIf 	

						If Len(aGravaLEA) > 0 //Este modelo apesar de ser uma grid Ã© 0-1 no layout

							oModel:LoadValue( "MODEL_LEA", "LEA_UTZEPC", aGravaLEA[1][2] )
							oModel:LoadValue( "MODEL_LEA", "LEA_UTZEPI", aGravaLEA[1][3] )
							oModel:LoadValue( "MODEL_LEA", "LEA_EFIEPC", aGravaLEA[1][4] )
							oModel:LoadValue( "MODEL_LEA", "LEA_MEDPRT", aGravaLEA[1][5] )
							oModel:LoadValue( "MODEL_LEA", "LEA_CNDFUN", aGravaLEA[1][6] )
							oModel:LoadValue( "MODEL_LEA", "LEA_PRZVLD", aGravaLEA[1][7] )		
							oModel:LoadValue( "MODEL_LEA", "LEA_PERTRC", aGravaLEA[1][8] )
							oModel:LoadValue( "MODEL_LEA", "LEA_HIGIEN", aGravaLEA[1][9] )
							oModel:LoadValue( "MODEL_LEA", "LEA_USOINI", aGravaLEA[1][10])

							If TafColumnPos("LEA_EFIEPI")
								oModel:LoadValue( "MODEL_LEA", "LEA_EFIEPI", aGravaLEA[1][11])
							EndIf

							nCMBAdd := 1
							For nCMB := 1 To Len( aGravaCMB )
							
								If aGravaCMB[nCMB][1] == aGravaCMA[nCMA][1]
							
									oModel:GetModel( 'MODEL_CMB' ):LVALID	:= .T.
							
									If nCMBAdd > 1
										oModel:GetModel( 'MODEL_CMB' ):AddLine()
									EndIf
												
									If !TafColumnPos("LEA_EFIEPI")
										oModel:LoadValue( "MODEL_CMB", "CMB_EFIEPI", aGravaCMB[nCMB][2] )
										oModel:LoadValue( "MODEL_CMB", "CMB_IDDESC", aGravaCMB[nCMB][3]	)
										oModel:LoadValue( "MODEL_CMB", "CMB_DVAL"  , aGravaCMB[nCMB][4] )
									Else
										oModel:LoadValue( "MODEL_CMB", "CMB_IDDESC", aGravaCMB[nCMB][2]	)
										oModel:LoadValue( "MODEL_CMB", "CMB_DVAL"  , aGravaCMB[nCMB][3] )
									EndIf
													
									nCMBAdd++

								EndIf
					
							Next nCMB //Fim - CMB

						EndIf
			
						nCMAAdd++
					
					Next nCMA //Fim - CMA				
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao que sera gravada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVersao := xFunGetVer()
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oModel:LoadValue( "MODEL_CM9" , "CM9_VERSAO", cVersao    )
					oModel:LoadValue( "MODEL_CM9" , "CM9_VERANT", cVerAnt    )
					oModel:LoadValue( "MODEL_CM9" , "CM9_PROTPN", cProtocolo )
					oModel:LoadValue( "MODEL_CM9" , "CM9_PROTUL", ""         )
					oModel:LoadValue( 'MODEL_CM9' , 'CM9_EVENTO', "A" 		 )
					
					// Tratamento para limpar o ID unico do xml
					cAliasPai := "CM9"
					If TAFColumnPos( cAliasPai+"_XMLID" )
						oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					EndIf

				ElseIf CM9->CM9_STATUS == ( "2" )
					TAFMsgVldOp( oModel, "2" )//"Registro não pode ser alterado. Aguardando processo da transmissão."
					lRetorno := .F.
				Elseif CM9->CM9_STATUS == ( "6" )
					TAFMsgVldOp( oModel, "6" )//"Registro não pode ser alterado. Aguardando processo de transmissão do evento de Exclusão S-3000"
					lRetorno := .F.
				ElseIf CM9->CM9_STATUS == "7"
					TAFMsgVldOp( oModel, "7" )//"Registro não pode ser alterado, pois o evento de exclusão já se encontra na base do RET"
					lRetorno := .F.
				Else
					If TafColumnPos( "CM9_LOGOPE" )
						cLogOpeAnt := CM9->CM9_LOGOPE
					endif

					If TafColumnPos("CM9_LAYOUT")

						if AllTrim(CM9->CM9_LAYOUT) $ "S_01_00_00|S_01_01_00"
							cEsocial := AllTrim(CM9->CM9_LAYOUT)
						Else
							cEsocial := SuperGetMV("MV_TAFVLES")
						EndIf

						oModel:LoadValue( "MODEL_CM9", "CM9_LAYOUT", cEsocial )
					EndIf

					TAFAltStat( 'CM9', " " )

					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_CM9', 'CM9_LOGOPE' , '' , cLogOpeAnt )
					EndIf
				Endif
				
				If lRetorno
					
					//Gravo alteração para o Extemporâneo
					If lGoExtemp
						TafGrvExt( oModel, 'MODEL_CM9', 'CM9' )			
					Endif	
					
					FwFormCommit( oModel )
				EndIf			
			
			EndIf 
		ElseIf nOperation == MODEL_OPERATION_DELETE 

			cChvRegAnt := CM9->(CM9_ID + CM9_VERANT)              
												
			TAFAltStat( 'CM9', " " )
			FwFormCommit( oModel )				
			
			If CM9->CM9_EVENTO == "A" .Or. CM9->CM9_EVENTO == "E"
				TAFRastro( 'CM9', 1, cChvRegAnt, .T. , , IIF(Type("oBrw") == "U", Nil, oBrw) )
			EndIf
		
		EndIf  

	End Transaction

Return ( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF264Xml

Funcao de geracao do XML para atender o registro S-2240/S-2365
Quando a rotina for chamada o registro deve estar posicionado

@Param:
lJob - Informa se foi chamado por Job
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@Return:
cXml - Estrutura do Xml do Layout S-2240/S-2365
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@author Mick William
@since 15/03/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF264Xml(cAlias as Character, nRecno as Numeric, nOpc as Numeric, lJob as Logical, lRemEmp  as Logical, cSeqXml as Character)

	Local cXml       as Character
	Local cNomeEve   as Character
	Local cCodCateg  as Character
	Local cCodAux    as Character
	Local cDescAgNoc as Character
	Local cLayout    as Character
	Local cV5Yag     as Character
	Local cCmbIndex  as Character
	Local cEpcEpi	 as Character
	Local cEsocial   as character
	Local aDescAg    as Array
	Local lLegado	 as Logical
	Local lXmlVLd    as Logical
	
	Default lJob     := .F.
	Default cSeqXml  := ""

	cXml       := ""
	cNomeEve   := ""
	cCodCateg  := ""
	cCodAux    := ""
	cDescAgNoc := ""
	cLayout    := "2240"
	lXmlVLd    := IIF(FindFunction( 'TafXmlVLD' ),TafXmlVLD( 'TAF264XML' ),.T.)
	cV5Yag     := ""
	cCmbIndex  := ""
	cEpcEpi    := ""
	cEsocial   := SuperGetMV("MV_TAFVLES")
	aDescAg    := {}
	lLegado    := TAF264DAG()

	If lXmlVLd

		dbSelectArea("CMA")
		CMA->(DbSetOrder(1))

		dbSelectArea("LEA")
		LEA->(DbSetOrder(1))
								
		dbSelectArea("CMB")

		If tafcolumnpos("LEA_DSAG")
			CMB->(DbSetOrder(3) )
		Else
			CMB->(DbSetOrder(1) )
		EndIf

		dbSelectArea("V3E")
		V3E->( dbSetOrder(1) )

		cNomeEve  := CM9->CM9_NOMEVE

		If TafColumnPos("CM9_LAYOUT").AND.!Empty(Alltrim(CM9->CM9_LAYOUT))
			cEsocial  := Alltrim( CM9->CM9_LAYOUT )
		Else
			cEsocial  := IIf(cEsocial $ "S_01_00_00|S_01_01_00", cEsocial, "S_01_00_00")
		EndIf

		If cNomeEve <> "S2190" .OR. Empty(cNomeEve)
			cTable:= "C9V"
			C9V->( DBSetOrder( 2 ) )
		Else
			cTable:= "T3A"
			T3A->( DBSetOrder( 3 ) )
		EndIf

		(cTable)->( MsSeek( xFilial(cTable) + CM9->CM9_FUNC + "1" ) )

		cXml 	:= "<ideVinculo>"
		cXml 	+= 	xTafTag( "cpfTrab"	, (cTable)->&(cTable + "_CPF" ),, .F.)

		cMatric := MatricCM9(cNomeEve)

		If !Empty(cMatric)
			cXml += xTafTag( "matricula", cMatric,,.T. )
		Else
			cCodCateg	:= TAFGetValue( "C87", 1, xFilial("C87") + C9V->C9V_CATCI, "C87_CODIGO" )
			cXml 		+= xTafTag( "codCateg", cCodCateg,,.T. )
		EndIf

		cXml += "</ideVinculo>"
		
		cXml += "<infoExpRisco>"
		cXml +=		xTafTag( "dtIniCondicao", CM9->CM9_DTINI,, .F. )
		cXml +=		xTafTag( "dtFimCondicao", CM9->CM9_DTFIM,, .T. )

		dbSelectArea("T0Q")
		T0Q->(dBSetOrder( 1 ))	
		If T0Q->(MsSeek( xFilial("T0Q") + CM9->CM9_ID + CM9->CM9_VERSAO ))
					
			While T0Q->( !Eof() ) .and. T0Q->(T0Q_FILIAL + T0Q_ID + T0Q_VERSAO) == xFilial("T0Q") + CM9->(CM9_ID + CM9_VERSAO)

				InfoAmbTag(@cXml, T0Q->T0Q_LAMB, T0Q->T0Q_DSETOR, T0Q->T0Q_TPINSC, T0Q->T0Q_NRINSC)

				T0Q->( DBSkip() )
					
			EndDo

		Else

			InfoAmbTag(@cXml)

		EndIf

		cXml += 	"<infoAtiv>"
		cXml +=			xTafTag( "dscAtivDes", AllTrim(CM9->CM9_DATIVD),, .F.)
		cXml += 	"</infoAtiv>"

		If CMA->(MsSeek( xFilial("CMA") + CM9->(CM9_ID + CM9->CM9_VERSAO) ))

			While CMA->( !EOF() ) .And. CMA->(CMA_FILIAL + CMA_ID + CMA_VERSAO ) == xFilial("CMA") + CM9->(CM9_ID + CM9_VERSAO)

				cV5Yag := Posicione("V5Y", 1, xFilial("V5Y") + CMA->CMA_CODAG, "V5Y_CODIGO")

				If !Empty(CMA->CMA_DSAG)

					aDescAg := StrTokArr(CMA->CMA_DSAG,"|")

					If  TafColumnPos("CMA_DAGNOC") .And. (Len(aDescAg) == 3 .And. aDescAg[1] == "PK")
						cDescAgNoc :=  CMA_DAGNOC
					Else 
						//Código Legado 
						cCodAux := Alltrim(SubStr(CMA->CMA_DSAG,1,9))	

						If cCodAux == cV5Yag
							cDescAgNoc := Alltrim(SubStr(CMA->CMA_DSAG,11,TamSx3("CMA_DSAG")[1]))
						Else 
							cDescAgNoc := AllTrim(CMA->CMA_DSAG)
						EndIf 

					EndIf 

				EndIf

				If LEA->(MsSeek(xFilial("LEA")+CM9->(CM9_ID + CM9->CM9_VERSAO) + CMA->CMA_CODAG + IIF(tafcolumnpos("LEA_DSAG") .And. !lLegado,CMA->CMA_DSAG,'' )))
			
					While LEA->(!Eof()) .And. LEA->(LEA_FILIAL + LEA_ID + LEA_VERSAO + LEA_CODAG + IIF(tafcolumnpos("LEA_DSAG") .And. !lLegado,LEA_DSAG,'' )  ) == xFilial("CM9") + CM9->(CM9_ID + CM9_VERSAO) + CMA->CMA_CODAG +IIF(tafcolumnpos("LEA_DSAG") .And. !lLegado,CMA->CMA_DSAG,'' )	
						
						cEpcEpi := "<epcEpi>"
						cEpcEpi += xTafTag( "utilizEPC"	, LEA->LEA_UTZEPC 				,, .F.)
						cEpcEpi += xTafTag( "eficEpc" 	, xFunTrcSN(LEA->LEA_EFIEPC, 1)	,, .T.)
						cEpcEpi += xTafTag( "utilizEPI"	, LEA->LEA_UTZEPI 				,, .F.)
						
						If TAFColumnPos("LEA_EFIEPI")
							cEpcEpi +=	xTafTag( "eficEpi"			, xFunTrcSN(LEA->LEA_EFIEPI, 1),, .T. )
						EndIf
							
						If(tafcolumnpos("LEA_DSAG"))
							cCmbIndex := CM9->(CM9_ID + CM9->CM9_VERSAO) + CMA->(CMA_CODAG + CMA_DSAG)
						Else 
							cCmbIndex := CM9->(CM9_ID + CM9->CM9_VERSAO) + CMA->CMA_CODAG 
						EndIf

						If CMB->( MsSeek( xFilial("CMB") + cCmbIndex ))

							While CMB->( !Eof() ) .And. CMB->(CMB_FILIAL + CMB_ID + CMB_VERSAO + CMB_CODAGE + IIF(tafcolumnpos("LEA_DSAG"),CMB->CMB_DSAG,'' ) ) == ;
										xFilial("CM9") + CM9->(CM9_ID + CM9_VERSAO) + CMA->(CMA_CODAG +  IIF(tafcolumnpos("LEA_DSAG"),CMA->CMA_DSAG,'' ) )
								
								cEpcEpi += "<epi>"
								cEpcEpi +=		xTafTag( "docAval"			, GetDescEPI(CMB->CMB_DVAL)		,, .F.)

								If cEsocial $ "S_01_00_00"
									cEpcEpi +=		xTafTag( "dscEPI"			, GetDescEPI(CMB->CMB_IDDESC)	,, .T.)
								EndIf

								cEpcEpi += "</epi>"
									
								CMB->( DBSkip() )

							EndDo

						EndIf

						xTafTagGroup( "epiCompl"		, {	{ "medProtecao", xFunTrcSN(LEA->LEA_MEDPRT, 1)	,, .F. };
								,	{ "condFuncto"		, xFunTrcSN(LEA->LEA_CNDFUN, 1)						,, .F. };
								, 	{ "usoInint"		, xFunTrcSN(LEA->LEA_USOINI, 1)						,, .F. };
								, 	{ "przValid"		, xFunTrcSN(LEA->LEA_PRZVLD, 1)						,, .F. };
								, 	{ "periodicTroca"	, xFunTrcSN(LEA->LEA_PERTRC, 1)						,, .F. } ;
								, 	{ "higienizacao"	, xFunTrcSN(LEA->LEA_HIGIEN, 1)						,, .F. } };
								, @cEpcEpi )	
			
						cEpcEpi += "</epcEpi>"

						LEA->(dbSkip())
						
					EndDo

				EndIf

				AgNocTag(@cXml, cV5Yag, cDescAgNoc, CMA->CMA_TPAVAL, CMA->CMA_INTCON, CMA->CMA_LIMTOL;
					, AllTrim(TAFGetValue( "V3F", 1, xFilial("V3F") + CMA->CMA_UNMED, "V3F_CODIGO" ));
					, CMA->CMA_TECMED, cEpcEpi)

				CMA->(DbSkip() )

			EndDo

		Else
			
			AgNocTag(@cXml)
			
		EndIf
			
		dbSelectArea("T3S")
		T3S->(dBSetOrder( 1 ))
		If T3S->(MsSeek( xFilial("T3S") + CM9->CM9_ID + CM9->CM9_VERSAO ))

			While T3S->( !Eof() ) .and. T3S->(T3S_FILIAL + T3S_ID + T3S_VERSAO) == xFilial("T3S") + CM9->(CM9_ID + CM9_VERSAO)

				RespRegTag(@cXml, T3S->T3S_CPFRES, T3S->T3S_IDEOC, T3S->T3S_DSCOC, T3S->T3S_NROC, Posicione("C09", 3, xFilial("C09") + T3S->T3S_UFOC, "C09_UF"))

				T3S->(dbSkip())
				
			EndDo

		Else

			RespRegTag(@cXml)
			
		EndIf

		If !Empty( CM9->CM9_OBSCMP )
			cXml += "<obs>"

			If !Empty( CM9->CM9_OBSCMP )
				cXml += xTafTag( "obsCompl"	, CM9->CM9_OBSCMP,, .F. )
			EndIf

			cXml += "</obs>"
		EndIf

		cXml += "</infoExpRisco>"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estrutura do cabecalho³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cXml := xTafCabXml(cXml,"CM9",cLayout,"ExpRisco",,cSeqXml,,,cEsocial)

		cXml := FwNoAccent( FwCutOff( cXML, .T. ) )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa gravacao do registro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lJob
			xTafGerXml( cXml, cLayout )
		EndIf
	EndIf

return(cXml)

//-------------------------------------------------------------------
/*/{Protheus.doc} InfoAmbTag
Funcao para gera o grupo da tag infoAmb

@parametros:
cXml 	- corpo do XML 
cAmb   	- Ambiente de trabalho     
cSetor 	- Lugar Administrativo     
cTpInsc - Tipo de inscrição.       
cNrInsc - Nr. de inscriçao.        

@Return cXML

@author Rodrigo Nicolino
@since 26/08/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function InfoAmbTag(cXml as Character, cAmb as Character, cSetor as Character, cTpInsc as Character, cNrInsc as Character)
	
	Default cAmb	:= ""
	Default cSetor	:= ""
	Default cTpInsc	:= ""
	Default cNrInsc	:= ""

	xTafTagGroup( "infoAmb";
				, {	{ "localAmb", cAmb		,, .F. };
				,	{ "dscSetor", cSetor	,, .F. };
				, 	{ "tpInsc"	, cTpInsc	,, .F. };
				, 	{ "nrInsc"	, cNrInsc	,, .F. }};
				, @cXml;
				, ;
				, .T. )	

Return cXml

//-------------------------------------------------------------------
/*/{Protheus.doc} InfoAmbTag
Funcao para gera o grupo da tag agNoc

@parametros:
cXml 	- corpo do XML 
cAmb   	- Ambiente de trabalho     
cSetor 	- Lugar Administrativo     
cTpInsc - Tipo de inscrição.       
cNrInsc - Nr. de inscriçao.        

@Return cXML

@author Rodrigo Nicolino
@since 26/08/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function AgNocTag(cXml as Character, cCodAg as Character, cDscAg as Character, cTpAval as Character, nIntCon as Numeric, nLImTol as Numeric, cUnMed as Character, cTecMed as Character, cEpcEpi as Character)
	
	Default cCodAg	:= ""
	Default cDscAg	:= ""
	Default cTpAval	:= ""
	Default nIntCon	:= 0
	Default nLImTol	:= 0
	Default cUnMed	:= ""
	Default cTecMed	:= ""
	Default cEpcEpi	:= ""

	xTafTagGroup( "agNoc";
				, {	{ "codAgNoc"	, cCodAg	,					, .F. 							};
				,	{ "dscAgNoc"	, cDscAg	,					, .T. 							};
				, 	{ "tpAval"		, cTpAval	,					, .T. 							};
				, 	{ "intConc"		, nIntCon	, "@E 99999.9999"	, .T., , CMA->CMA_TPAVAL == "1"	};
				, 	{ "limTol"		, nLImTol	, "@E 99999.9999"	, .T. 							};
				, 	{ "unMed"		, cUnMed	, 					, .T. 							};
				, 	{ "tecMedicao"	, cTecMed	,					, .T. 							}};
				, @cXml;
				, {	{"epcEpi" , cEpcEpi ,0}};
				, .T. )	

Return cXml

//-------------------------------------------------------------------
/*/{Protheus.doc} InfoAmbTag
Funcao para gera o grupo da tag infoAmb

@parametros:
cXml 	- corpo do XML 
cAmb   	- Ambiente de trabalho     
cSetor 	- Lugar Administrativo     
cTpInsc - Tipo de inscrição.       
cNrInsc - Nr. de inscriçao.        

@Return cXML

@author Rodrigo Nicolino
@since 26/08/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function RespRegTag(cXml as Character, cCpfRes as Character, cIdOc as Character, cDscOc as Character, cNrOc as Character, cUfOC as Character)
	
	Default cCpfRes	:= ""
	Default cIdOc	:= ""
	Default cDscOc	:= ""
	Default cNrOc	:= ""
	Default cUfOC	:= ""

	xTafTagGroup( "respReg";
				, {	{ "cpfResp"	, cCpfRes	,, .F. };
				,	{ "ideOC"	, cIdOc		,, .T. };
				, 	{ "dscOC"	, cDscOc	,, .T. };
				, 	{ "nrOC"	, cNrOc		,, .T. };
				, 	{ "ufOC"	, cUfOC		,, .T. }};
				, @cXml;
				, ;
				, .T. )	

Return cXml

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF264Grv
Funcao de gravacao para atender o registro S-2240/2365

@parametros:
cLayout - Nome do Layout que esta sendo enviado, existem situacoes onde o mesmo fonte
					alimenta mais de um regsitro do E-Social, para estes casos serao necessarios
					tratamentos de acordo com o layout que esta sendo enviado.
nOpc   -  Opcao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )
cFilEv -  Filial do ERP para onde as informacoes deverao ser importadas
oDados -  Objeto com as informacoes a serem manutenidas ( Outras Integracoes )
cEsocial - Variavel de controle de layout para o eSocial

@Return
lRet    - Variavel que indica se a importacao foi realizada, ou seja, se as
			informacoes foram gravadas no banco de dados
aIncons - Array com as inconsistencias encontradas durante a importacao

@author Mick William
@since 15/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF264Grv( cLayout as Character, nOpc as Numeric, cFilEv as Character, oXML as Object, cOwner as Character, cFilTran as Character, cPredeces as Character, nTafRecno as Numeric, cComplem as Character, cGrpTran as Character, cEmpOriGrp as Character, cFilOriGrp as Character, cXmlID  as Character, cEvtOri as Character, lMigrador as Logical, lDepGPE as Logical, cKey as Character, cMatrC9V as Character, lLaySmpTot as Logical, lExclCMJ as Logical, oTransf as object, cXml as Character )

	Local cLogOpeAnt  as Character
	Local cCmpsNoUpd  as Character
	Local cCabec      as Character
	Local cIdFunc     as Character
	Local cDtInicio   as Character
	Local cExpRisco   as Character
	Local cInconMsg   as Character
	Local cPathLEA    as Character
	Local cCodEvent   as Character
	Local cCodAgNoc   as Character
	Local cIdCodAg    as Character
	Local cNomeEve    as Character
	Local cDescAgVal  as Character
	Local cEsocial	  as Character
	Local nCMA        as Numeric
	Local nCMB        as Numeric
	Local nT3S        as Numeric
	Local nI          as Numeric
	Local nJ          as Numeric
	Local nIndChv     as Numeric
	Local nSeqErrGrv  as Numeric
	Local nRecno      as Numeric
	Local lRet        as Logical
	Local lRetif      as Logical
	Local aIncons     as Array
	Local aRules      as Array
	Local aChave      as Array
	Local aCommit     as Array
	Local oModel      as Object
	
	Private lVldModel as Logical
	Private oDados    as Object

	Default cLayout    := ""
	Default cFilEv     := ""
	Default nOpc       := 1
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
	Default cKey 	   := "" 
	Default cMatrC9V   := "" 
	Default cEvtOri    := "" 
	Default cXml       := ""
	Default lMigrador  := .F.
	Default lDepGPE    := .F.
	Default lLaySmpTot := .F.
	Default lExclCMJ   := .F. 
	Default oTransf    := Nil
	

	cXmlInteg  := cXml
	cLogOpeAnt := ""
	cCmpsNoUpd := "|CM9_FILIAL|CM9_ID|CM9_VERSAO|CM9_DTINI|CM9_VERANT|CM9_PROTPN|CM9_EVENTO|CM9_STATUS|CM9_ATIVO|"
	cCabec     := "/eSocial/evtExpRisco/infoExpRisco"
	cIdFunc    := ""
	cDtInicio  := ""
	cExpRisco  := ""
	cInconMsg  := ""
	cPathLEA   := ""
	cCodEvent  := Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")
	cCodAgNoc  := ""
	cIdCodAg   := ""
	cNomeEve   := ""
	cDescAgVal := ""
	cEsocial   := ""
	nCMA       := 0
	nCMB       := 0
	nT3S       := 0
	nI         := 0
	nJ         := 0
	nIndChv    := 5
	nSeqErrGrv := 0
	nRecno     := CM9->(Recno())
	lRet       := .F.
	lRetif     := .F.
	aIncons    := {}
	aRules     := {}
	aChave     := {}
	aCommit    := {}
	oModel     := Nil
	lVldModel  := .T. //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.
	oDados     := oXML

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chave do registro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If TAF264Struct(.F.)

		If oDados:XPathHasNode("/eSocial/evtExpRisco/ideVinculo/cpfTrab")
			If oDados:XPathHasNode("/eSocial/evtExpRisco/ideVinculo/matricula")
				cMat 		:= FTafGetVal("/eSocial/evtExpRisco/ideVinculo/matricula", "C", .F., @aIncons, .F.)
				cCPF 		:= FTafGetVal("/eSocial/evtExpRisco/ideVinculo/cpfTrab", "C", .F., @aIncons, .F.)
				aEvento 	:= TAFIdFunc(cCPF, cMat, @cInconMsg, @nSeqErrGrv)
				cIdFunc 	:= aEvento[1]
				cNomeEve	:= aEvento[2]
			Else
				cIdFunc		:= FGetIdInt( "cpfTrab",, "/eSocial/evtExpRisco/ideVinculo/cpfTrab",,,, @cInconMsg, @nSeqErrGrv, "codCateg", "/eSocial/evtExpRisco/ideVinculo/codCateg" ) 
				cNomeEve 	:= "S2300"
			EndIf
		EndIf

		cDtInicio	:= FTafGetVal( cCabec + "/dtIniCondicao", 'C', .F., @aIncons, .F., '', '' )
		cDtInicio	:= StrTran( cDtInicio, "-", "" )

		Aadd( aChave, { "C", "CM9_FUNC"  , cIdFunc, .T.} ) 
		Aadd( aChave, { "C", "CM9_DTINI", cDtInicio, .T. } )

		cChave	:= Padr( cIdFunc, Tamsx3( aChave[ 1, 2 ])[1] ) + Padr( cDtInicio, Tamsx3( aChave[ 2, 2 ])[1] )

		//Verifica se o evento ja existe na base
		CM9->( DbSetOrder( 5 ) )
		If CM9->(MsSeek(FTafGetFil( cFilEv , @aIncons , "CM9" )+cChave+'1' ))
			nOpc 	:= 4

			If CM9->CM9_STATUS == "4"
				lRetif := .T.
			EndIf
			
		EndIf	

		If Empty(aIncons)

			CM9->(dBGoTo(nRecno))
			Begin Transaction
				
				//Funcao para validar se a operacao desejada pode ser realizada
				If FTafVldOpe( "CM9", nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA264", cCmpsNoUpd, 1, .F. )

					If TafColumnPos( "CM9_LOGOPE" )
						cLogOpeAnt := CM9->CM9_LOGOPE
					endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Carrego array com os campos De/Para de gravacao das informacoes³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aRules := TAF264Rul(cDtInicio,@cInconMsg, @nSeqErrGrv, cCodEvent, cOwner, cIdFunc )
			
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
					//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nOpc <> 5
						oModel:LoadValue( "MODEL_CM9", "CM9_FILIAL", CM9->CM9_FILIAL )
						
						If TAFColumnPos("CM9_LAYOUT") .AND. Findfunction("TafNameEspace")
							
							cEsocial := AllTrim(TafNameEspace(cXmlInteg))
							oModel:LoadValue( "MODEL_CM9", "CM9_LAYOUT",IIf(cEsocial $ "S_01_00_00|S_01_01_00", cEsocial, "S_01_00_00"))

						EndIf
						
						If TAFColumnPos( "CM9_XMLID" )
							oModel:LoadValue( "MODEL_CM9", "CM9_XMLID", cXmlID )
						EndIf

						oModel:LoadValue( "MODEL_CM9", "CM9_NOMEVE", cNomeEve )

						If TafColumnPos("CM0_ULTTRB") //Foi usado este campo para proteção, pois o campo CM9_DTFIM já existe na base, ele somente esta como não usado
							If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtExpRisco/infoExpRisco/dtFimCondicao") )
								oModel:LoadValue( "MODEL_CM9", "CM9_DTFIM", FTafGetVal( "/eSocial/evtExpRisco/infoExpRisco/dtFimCondicao", "D", .F., @aIncons, .F. ) )
							EndIf
						EndIf

						If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtExpRisco/infoExpRisco/infoAtiv/dscAtivDes") )
							oModel:LoadValue( "MODEL_CM9", "CM9_DATIVD", FTafGetVal( "/eSocial/evtExpRisco/infoExpRisco/infoAtiv/dscAtivDes", "C", .F., @aIncons, .F. ) )
						EndIf

						If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtExpRisco/infoExpRisco/obs/obsCompl") )
							oModel:LoadValue( "MODEL_CM9", "CM9_OBSCMP", FTafGetVal( "/eSocial/evtExpRisco/infoExpRisco/obs/obsCompl", "C", .F., @aIncons, .F. ) )
						EndIf
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Rodo o aRules para gravar as informacoes³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nI := 1 to Len( aRules )
							oModel:LoadValue( "MODEL_CM9", aRules[ nI, 01 ], FTafGetVal( aRules[ nI, 02 ], aRules[ nI, 03 ], aRules[ nI, 04 ], @aIncons, .F. ) )
						Next nI

						If Findfunction("TAFAltMan")
							if nOpc == 3
								TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_CM9', 'CM9_LOGOPE' , '1', '' )
							elseif nOpc == 4
								TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_CM9', 'CM9_LOGOPE' , '', cLogOpeAnt )
							EndIf
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Quando se trata de uma alteracao deleto todas as linhas do Grid³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nT0Q := 1
						cT0QPath := cCabec + cExpRisco + "/infoAmb[" + AllTrim(Str(nT0Q)) + "]"
						
						If nOpc == 4 		
							For nJ := 1 to oModel:GetModel( "MODEL_T0Q" ):Length()
								oModel:GetModel( "MODEL_T0Q" ):GoLine(nJ)
								oModel:GetModel( "MODEL_T0Q" ):DeleteLine()
							Next nJ
						EndIf
						
						While oDados:XPathHasNode(cT0QPath)

							oModel:GetModel( "MODEL_T0Q" ):lValid:= .T.	

							If nOpc == 4 .Or. nT0Q > 1
								oModel:GetModel( "MODEL_T0Q" ):AddLine()
							EndIf				
							
							If oDados:XPathHasNode(cT0QPath + "/localAmb")
								oModel:LoadValue( "MODEL_T0Q", "T0Q_LAMB", FTafGetVal( cT0QPath + "/localAmb" 	 , "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(cT0QPath + "/dscSetor")
								oModel:LoadValue( "MODEL_T0Q", "T0Q_DSETOR", FTafGetVal( cT0QPath + "/dscSetor" 	 , "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(cT0QPath + "/tpInsc")
								oModel:LoadValue( "MODEL_T0Q", "T0Q_TPINSC", FTafGetVal( cT0QPath + "/tpInsc" 	 , "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(cT0QPath + "/nrInsc")
								oModel:LoadValue( "MODEL_T0Q", "T0Q_NRINSC", FTafGetVal( cT0QPath + "/nrInsc" 	 , "C", .F., @aIncons, .F. ) )
							EndIf

							nT0Q++
							cT0QPath := cCabec + cExpRisco + "/infoAmb[" + AllTrim(Str(nT0Q)) + "]"
						EndDo

						nCMA := 1
						cCMAPath := cCabec + "/agNoc[" + AllTrim(Str(nCMA)) + "]"
						
						If nOpc == 4
							For nJ := 1 to oModel:GetModel( "MODEL_CMA" ):Length()
								oModel:GetModel( "MODEL_CMA" ):GoLine( nJ )
								oModel:GetModel( "MODEL_CMA" ):DeleteLine()
							Next nJ
						EndIf
		
						While oDados:XPathHasNode(cCMAPath)
								
							oModel:GetModel( "MODEL_CMA" ):lValid:= .T.
							If nOpc == 4 .Or. nCMA > 1
								oModel:GetModel( "MODEL_CMA" ):AddLine()
							EndIf				
													
							if oDados:XPathHasNode(cCMAPath +"/intConc")
								oModel:LoadValue( "MODEL_CMA", "CMA_INTCON", FTafGetVal( cCMAPath + "/intConc" 	 , "N", .F., @aIncons, .F. ) )
							EndIf
								
							if oDados:XPathHasNode( cCMAPath + "/tecMedicao")
								oModel:LoadValue( "MODEL_CMA", "CMA_TECMED", FTafGetVal( cCMAPath + "/tecMedicao", "C", .F., @aIncons, .F. ) )
							EndIf
								
								
							If oDados:XPathHasNode( cCMAPath + "/limTol")
								oModel:LoadValue( "MODEL_CMA", "CMA_LIMTOL", FTafGetVal( cCMAPath + "/limTol", "N", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode( cCMAPath + "/unMed")
								oModel:LoadValue( "MODEL_CMA", "CMA_UNMED", FGetIdInt( "unMed"	 , "", cCMAPath + "/unMed",,,,@cInconMsg, @nSeqErrGrv))
							EndIf

							If oDados:XPathHasNode( cCMAPath + "/tpAval")
								oModel:LoadValue( "MODEL_CMA", "CMA_TPAVAL", FTafGetVal( cCMAPath + "/tpAval", "C", .F., @aIncons, .F. ))
							EndIf

							If oDados:XPathHasNode( cCMAPath + "/codAgNoc")

								cCodAgNoc := AllTrim(FTafGetVal( cCMAPath + "/codAgNoc", "C", .F., @aIncons, .T. ))
								cIdCodAg := FGetIdInt( "codAgNoc", "",cCodAgNoc, , .F.,,@cInconMsg, @nSeqErrGrv)
								oModel:LoadValue( "MODEL_CMA", "CMA_CODAG", cIdCodAg )
							EndIf

							If oDados:XPathHasNode( cCMAPath + "/dscAgNoc")

								If TafColumnPos("CMA_DAGNOC")
									oModel:LoadValue( "MODEL_CMA", "CMA_DAGNOC", FTafGetVal( cCMAPath + "/dscAgNoc", "C", .F., @aIncons, .F. ))
								Else 
									//Se o campo CMA_DAGNOC existir o valor do campo CMA_DSAG será retornado pelo Inicializador padrão 
									cDescAgVal := SubStr(FTafGetVal( cCMAPath + "/dscAgNoc", "C", .F., @aIncons, .F. ),1,170)
									oModel:LoadValue( "MODEL_CMA", "CMA_DSAG", cDescAgVal)
								EndIf 	
							EndIf 

							cPathLEA := cCMAPath + "/epcEpi"
		
							If oModel:GetModel( "MODEL_LEA" ):Length() > 0
									
								oModel:GetModel( "MODEL_LEA" ):lValid:= .T.						
														
								If oDados:XPathHasNode(cPathLEA + "/utilizEPC")
									oModel:LoadValue( "MODEL_LEA", "LEA_UTZEPC" , FTafGetVal(cPathLEA + "/utilizEPC" , "C", .F., @aIncons, .F. ) )
								EndIf
								
								If oDados:XPathHasNode(cPathLEA + "/utilizEPI")
									oModel:LoadValue( "MODEL_LEA", "LEA_UTZEPI" , FTafGetVal(cPathLEA + "/utilizEPI" , "C", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode(cPathLEA + "/eficEpi") .AND. TAFColumnPos("LEA_EFIEPI")
									oModel:LoadValue( "MODEL_LEA", "LEA_EFIEPI", xFunTrcSN(FTafGetVal( cPathLEA + "/eficEpi" 	 	, "C", .F., @aIncons, .F. ),2) )
								EndIf

								If oDados:XPathHasNode(cPathLEA + "/eficEpc")
									oModel:LoadValue( "MODEL_LEA", "LEA_EFIEPC" , xFunTrcSN( FTafGetVal(cPathLEA + "/eficEpc" , "C", .F., @aIncons, .F. ), 2 ) )
								EndIf

								If oDados:XPathHasNode(cPathLEA + "/epiCompl/medProtecao" )
									oModel:LoadValue( "MODEL_LEA", "LEA_MEDPRT", xFunTrcSN(FTafGetVal( cPathLEA + "/epiCompl/medProtecao" 	, "C", .F., @aIncons, .F. ),2) )
								EndIf

								If oDados:XPathHasNode(cPathLEA + "/epiCompl/condFuncto" )
									oModel:LoadValue( "MODEL_LEA", "LEA_CNDFUN", xFunTrcSN(FTafGetVal( cPathLEA + "/epiCompl/condFuncto" 	, "C", .F., @aIncons, .F. ),2) )
								EndIf
									
								If oDados:XPathHasNode(cPathLEA + "/epiCompl/usoInint" )
									oModel:LoadValue( "MODEL_LEA", "LEA_USOINI", xFunTrcSN(FTafGetVal( cPathLEA + "/epiCompl/usoInint" 	, "C", .F., @aIncons, .F. ),2) )
								EndIf

								If oDados:XPathHasNode(cPathLEA + "/epiCompl/przValid"	)
									oModel:LoadValue( "MODEL_LEA", "LEA_PRZVLD", xFunTrcSN(FTafGetVal( cPathLEA + "/epiCompl/przValid"		, "C", .F., @aIncons, .F. ),2) )
								EndIf

								If oDados:XPathHasNode(cPathLEA + "/epiCompl/periodicTroca")
									oModel:LoadValue( "MODEL_LEA", "LEA_PERTRC", xFunTrcSN(FTafGetVal( cPathLEA + "/epiCompl/periodicTroca"	, "C", .F., @aIncons, .F. ),2) )
								EndIf

								If oDados:XPathHasNode(cPathLEA + "/epiCompl/higienizacao" )
									oModel:LoadValue( "MODEL_LEA", "LEA_HIGIEN", xFunTrcSN(FTafGetVal( cPathLEA + "/epiCompl/higienizacao"	, "C", .F., @aIncons, .F. ),2) )
								EndIf

								nCMB := 1

								cCMBPath 	:= cPathLEA + "/epi[" + AllTrim(Str(nCMB)) + "]"

								If nOpc == 4
									For nJ := 1 to oModel:GetModel( "MODEL_CMB" ):Length()
										oModel:GetModel( "MODEL_CMB" ):GoLine( nJ )
										oModel:GetModel( "MODEL_CMB" ):DeleteLine()
									Next nJ
								EndIf
													
								While oDados:XPathHasNode(cCMBPath)
									
									oModel:GetModel( "MODEL_CMB" ):lValid:= .T.
									If nOpc == 4 .Or. nCMB > 1
										oModel:GetModel( "MODEL_CMB" ):AddLine()
									EndIf				

									If oDados:XPathHasNode(cCMBPath + "/dscEPI")
										oModel:LoadValue( "MODEL_CMB", "CMB_IDDESC" , SetDescEPI( oModel:GetValue( "MODEL_CMB", "CMB_IDDESC" ), lRetif, FTafGetVal( cCMBPath + "/dscEPI", "C", .F., @aIncons, .F. ) ) )
									EndIf

									If oDados:XPathHasNode(cCMBPath + "/eficEpi") .AND. !TAFColumnPos("LEA_EFIEPI")
										oModel:LoadValue( "MODEL_CMB", "CMB_EFIEPI", xFunTrcSN(FTafGetVal( cCMBPath + "/eficEpi" 	 	, "C", .F., @aIncons, .F. ),2) )
									EndIf

									If oDados:XPathHasNode(cCMBPath + "/docAval" )
										oModel:LoadValue( "MODEL_CMB", "CMB_DVAL", SetDescEPI( oModel:GetValue( "MODEL_CMB", "CMB_DVAL" ), lRetif, FTafGetVal( cCMBPath + "/docAval", "C", .F., @aIncons, .T. ) ) )
									EndIf

									nCMB++

									cCMBPath	:= cPathLEA + "/epi[" + AllTrim(Str(nCMB)) + "]"

								EndDo	
									
							EndIf

							nCMA++

							cCMAPath := cCabec + "/agNoc[" + AllTrim(Str(nCMA)) + "]"

						EndDo

						nT3S := 1
						cT3SPath := cCabec + "/respReg[" + AllTrim(Str(nT3S)) + "]"				

						If nOpc == 4
							For nJ := 1 to oModel:GetModel( "MODEL_T3S" ):Length()
								oModel:GetModel( "MODEL_T3S" ):GoLine(nJ)
								oModel:GetModel( "MODEL_T3S" ):DeleteLine()
							Next nJ
						EndIf					
						
						While oDados:XPathHasNode(cT3SPath)

							oModel:GetModel( "MODEL_T3S" ):lValid:= .T.		
															
							If nOpc == 4 .Or. nT3S > 1					
								oModel:GetModel( "MODEL_T3S" ):AddLine()
							EndIf

							If oDados:XPathHasNode(cT3SPath + "/nrOC")
								oModel:LoadValue( "MODEL_T3S", "T3S_NROC", FTafGetVal( cT3SPath + "/nrOC", "C", .F., @aIncons, .F. ) )
							EndIf
													
							If oDados:XPathHasNode(cT3SPath + "/ufOC")
								oModel:LoadValue( "MODEL_T3S", "T3S_UFOC", FGetIdInt( "uf","", cT3SPath + "/ufOC",,,,@cInconMsg, @nSeqErrGrv) )
							EndIf
								
							If oDados:XPathHasNode(cT3SPath + "/cpfResp")
								oModel:LoadValue( "MODEL_T3S", "T3S_CPFRES", FTafGetVal( cT3SPath + "/cpfResp", "C", .F., @aIncons, .F. ) )
							EndIf
							
							If oDados:XPathHasNode(cT3SPath + "/ideOC")
								oModel:LoadValue( "MODEL_T3S", "T3S_IDEOC", FTafGetVal( cT3SPath + "/ideOC", "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(cT3SPath + "/dscOC")
								oModel:LoadValue( "MODEL_T3S", "T3S_DSCOC", FTafGetVal( cT3SPath + "/dscOC", "C", .F., @aIncons, .F. ) )
							EndIf

							nT3S++
					
							cT3SPath := cCabec + "/respReg[" + AllTrim(Str(nT3S)) + "]"

						EndDo

					Endif 
							
					///ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Efetiva a operacao desejada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Empty(cInconMsg)	.And. Empty(aIncons)
						aCommit := TafFormCommit(oModel, .T.)

						If aCommit[1]
							Aadd(aIncons, Iif(Empty(aCommit[3]), "ERRO19", aCommit[3]))
						Else
							lRet := .T.
						EndIf	 
					Else			
						Aadd(aIncons, cInconMsg)
						DisarmTransaction()	
					EndIf								 			   
					oModel:DeActivate()

				EndIf
			End Transaction
		EndIf
	Else
		Aadd(aIncons, STR0023)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Zerando os arrays e os Objetos utilizados no processamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize( aRules, 0 )
	aRules := Nil

	aSize( aChave, 0 )
	aChave := Nil

Return{ lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF264Rul

Regras para gravacao das informacoes do registro S-2240/2365

@Param
cCabec - Cabecalho do caminho do arquivo XML

@Return
aRull  - Regras para a gravacao das informacoes

@author Mick William
@since 15/03/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF264Rul(cDtInicio, cInconMsg, nSeqErrGrv, cCodEvent, cOwner, cIdFunc)

	Local aRull        := {}
	Local aIncons      := {}

	Default cIdFunc    := ""
	Default cDtInicio  := ""
	Default cInconMsg  := ""
	Default nSeqErrGrv := 0
	Default cCodEvent  := ""
	Default cOwner     := ""

	If TafXNode(oDados , cCodEvent, cOwner, "/eSocial/evtExpRisco/ideVinculo/cpfTrab")
		If TafXNode(oDados , cCodEvent, cOwner, "/eSocial/evtExpRisco/ideVinculo/matricula")
			cMat 	:= FTafGetVal("/eSocial/evtExpRisco/ideVinculo/matricula", "C", .F., @aIncons, .F.)
			cCPF 	:= FTafGetVal("/eSocial/evtExpRisco/ideVinculo/cpfTrab", "C", .F., @aIncons, .F.)
			aEvento := TAFIdFunc(cCPF, cMat, @cInconMsg, @nSeqErrGrv)

			aAdd( aRull, { "CM9_FUNC" 	 , aEvento[1] , "C", .T. } ) 
		Else
			aAdd( aRull, { "CM9_FUNC"  	, FGetIdInt( "cpfTrab",, "/eSocial/evtExpRisco/ideVinculo/cpfTrab",,,, @cInconMsg, @nSeqErrGrv, "codCateg", "/eSocial/evtExpRisco/ideVinculo/codCateg" )  , "C", .T. } )
		EndIf
	EndIf

	aAdd( aRull, { "CM9_DTINI", STOD(cDtInicio)	, "C", .T. } ) //dtIniCondicao

Return( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclusão do evento (S-3000)

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function é chamada pelo TafIntegraESocial

@Return .T.

@author Mick William
@since 15/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )

	Local cVerAnt    := ""
	Local cProtocolo := ""
	Local cVersao    := ""
	Local cEvento    := ""
	Local nlI        := 0
	Local nI         := 0
	Local nT0Q       := 0
	Local nT3S       := 0
	Local nCMA       := 0
	Local nCMAAdd    := 0
	Local nCMB       := 0
	Local nCMBAdd    := 0
	Local aGravaCM9  := {}
	Local aGravaT0Q  := {}
	Local aGravaCMA  := {}
	Local aGravaCMB  := {}
	Local aGravaLEA  := {}
	Local aGravaT3S  := {}
	Local oModelCM9  := Nil
	Local oModelT0Q  := Nil
	Local oModelCMA  := Nil
	Local oModelCMB  := Nil
	Local oModelLEA  := Nil
	Local oModelT3S  := Nil

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		//Posiciona o item
		dbSelectArea("CM9")
		CM9->( DBGoTo( nRecno ) )

		//Carrego a Estrutura dos Models a serem gravados	

		oModelCM9 := oModel:GetModel( "MODEL_CM9" )
		oModelT0Q := oModel:GetModel( "MODEL_T0Q" )
		oModelCMA := oModel:GetModel( "MODEL_CMA" )
		oModelCMB := oModel:GetModel( "MODEL_CMB" )
		oModelLEA := oModel:GetModel( "MODEL_LEA" )
		oModelT3S := oModel:GetModel( "MODEL_T3S" )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco a versao anterior do registro para gravacao do rastro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVerAnt    := oModelCM9:GetValue( "CM9_VERSAO" )
		cProtocolo := oModelCM9:GetValue( "CM9_PROTUL" )
		cEvento    := oModelCM9:GetValue( "CM9_EVENTO" )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Neste momento eu gravo as informacoes que foram carregadas       ³
		//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
		//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
		//³nao devem ser consideradas neste momento                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nI := 1 to Len( oModelCM9:aDataModel[ 1 ] )
			aAdd( aGravaCM9, { oModelCM9:aDataModel[ 1, nI, 1 ], oModelCM9:aDataModel[ 1, nI, 2 ] } )
		Next
					
		//T3S				  
		For nT3S := 1 To oModel:GetModel( 'MODEL_T3S' ):Length() 
			oModel:GetModel( 'MODEL_T3S' ):GoLine(nT3S)
						
			If !oModel:GetModel( 'MODEL_T3S' ):IsDeleted()

				aAdd( aGravaT3S, {  oModelT3S:GetValue( "T3S_NROC"  	),;
									oModelT3S:GetValue( "T3S_UFOC"  	),;
									oModelT3S:GetValue( "T3S_CPFRES"  	),;
									oModelT3S:GetValue( "T3S_IDEOC"  	),;
									oModelT3S:GetValue( "T3S_DSCOC"  	)})
			EndIf										
		Next nT3S //Fim - T3S

		//V3E
		For nCMA := 1 To oModel:GetModel( 'MODEL_CMA' ):Length() 

			oModel:GetModel( 'MODEL_CMA' ):GoLine(nCMA)

			If !oModel:GetModel( 'MODEL_CMA' ):IsDeleted()

				aAdd( aGravaCMA, {  oModelCMA:GetValue( "CMA_CODAG" ),;
									oModelCMA:GetValue( "CMA_INTCON" ),;
									oModelCMA:GetValue( "CMA_TECMED" ),;
									oModelCMA:GetValue( "CMA_LIMTOL" ),;
									oModelCMA:GetValue( "CMA_UNMED"  ),;
									oModelCMA:GetValue( "CMA_TPAVAL" )} )
											
					oModel:GetModel( 'MODEL_LEA' ):GoLine()
										
					If !oModel:GetModel( 'MODEL_LEA' ):IsDeleted()

						If !TafColumnPos("LEA_EFIEPI")

							aAdd( aGravaLEA, {	oModelCMA:GetValue( "CMA_CODAG"  ),;
												oModelLEA:GetValue( "LEA_UTZEPC" ),;
												oModelLEA:GetValue( "LEA_UTZEPI" ),;
												oModelLEA:GetValue( "LEA_EFIEPC" ),;
												oModelLEA:GetValue( "LEA_MEDPRT" ),;
												oModelLEA:GetValue( "LEA_CNDFUN" ),;
												oModelLEA:GetValue( "LEA_PRZVLD" ),;
												oModelLEA:GetValue( "LEA_PERTRC" ),;
												oModelLEA:GetValue( "LEA_HIGIEN" ),;
												oModelLEA:GetValue( "LEA_USOINI" )}) 

						Else

							aAdd( aGravaLEA, {	oModelCMA:GetValue( "CMA_CODAG"  ),;
												oModelLEA:GetValue( "LEA_UTZEPC" ),;
												oModelLEA:GetValue( "LEA_UTZEPI" ),;
												oModelLEA:GetValue( "LEA_EFIEPC" ),;
												oModelLEA:GetValue( "LEA_MEDPRT" ),;
												oModelLEA:GetValue( "LEA_CNDFUN" ),;
												oModelLEA:GetValue( "LEA_PRZVLD" ),;
												oModelLEA:GetValue( "LEA_PERTRC" ),;
												oModelLEA:GetValue( "LEA_HIGIEN" ),;
												oModelLEA:GetValue( "LEA_USOINI" ),;
												oModelLEA:GetValue( "LEA_EFIEPI" )}) 

						EndIf

						//CMB	
						If !oModel:GetModel( 'MODEL_CMB' ):IsEmpty()	

							For nCMB := 1 To oModel:GetModel( 'MODEL_CMB' ):Length() 

								oModel:GetModel( 'MODEL_CMB' ):GoLine(nCMB)
						
								If !oModel:GetModel( 'MODEL_CMB' ):IsDeleted()

									If !TafColumnPos("LEA_EFIEPI")

										aAdd (aGravaCMB ,{	oModelCMA:GetValue( "CMA_CODAG"	),;
															oModelCMB:GetValue( "CMB_EFIEPI"),;
															oModelCMB:GetValue( "CMB_IDDESC"),;
															oModelCMB:GetValue( "CMB_DVAL"	)})
									Else

										aAdd (aGravaCMB ,{	oModelCMA:GetValue( "CMA_CODAG"	),;
															oModelCMB:GetValue( "CMB_IDDESC"),;
															oModelCMB:GetValue( "CMB_DVAL"	)})
										
									EndIf
									
								EndIf

							Next nCMB //Fim - CMB

						EndIf
					EndIf 	
			EndIf

		Next nCMA //Fim - CMA
											
		For nT0Q := 1 To oModel:GetModel( 'MODEL_T0Q' ):Length()
			
			oModel:GetModel( 'MODEL_T0Q' ):Goline(nT0Q) 
		
			If !oModel:GetModel( 'MODEL_T0Q' ):IsDeleted()
											
				aAdd( aGravaT0Q, {  oModelT0Q:GetValue( "T0Q_LAMB" ) } )
			
			EndIf

		Next nT0Q //Fim - T0Q	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seto o campo como Inativo e gravo a versao do novo registro³
		//³no registro anterior                                       ³
		//|                                                           |
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FAltRegAnt( "CM9", "2" )

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
		For nlI := 1 To Len( aGravaCM9 )	
			oModel:LoadValue( 'MODEL_CM9', aGravaCM9[ nlI, 1 ], aGravaCM9[ nlI, 2 ] )
		Next  

		For nT3S := 1 To Len( aGravaT3S )
			oModel:GetModel( 'MODEL_T3S' ):LVALID	:= .T.
		
			If nT3S > 1
				oModel:GetModel( 'MODEL_T3S' ):AddLine()
			EndIf

			oModel:LoadValue( "MODEL_T3S", "T3S_NROC"  	, aGravaT3S[nT3S][1] ) 
			oModel:LoadValue( "MODEL_T3S", "T3S_UFOC"  	, aGravaT3S[nT3S][2] )
			oModel:LoadValue( "MODEL_T3S", "T3S_CPFRES"	, aGravaT3S[nT3S][3] )
			oModel:LoadValue( "MODEL_T3S", "T3S_IDEOC"  , aGravaT3S[nT3S][4] )
			oModel:LoadValue( "MODEL_T3S", "T3S_DSCOC"  , aGravaT3S[nT3S][5] )
								
		Next nT3S //Fim - T3S
						
		For nT0Q := 1 To Len( aGravaT0Q )
			oModel:GetModel( 'MODEL_T0Q' ):LVALID	:= .T.
			
			If nT0Q > 1
				oModel:GetModel( 'MODEL_T0Q' ):AddLine()
			EndIf

			oModel:LoadValue( "MODEL_T0Q", "T0Q_LAMB", aGravaT0Q[nT0Q][1] )
			
		Next nT0Q //Fim - T0Q

		nCMAAdd := 1
		For nCMA := 1 To Len( aGravaCMA )
			oModel:GetModel( 'MODEL_CMA' ):LVALID	:= .T.
			
			If nCMAAdd > 1
				oModel:GetModel( 'MODEL_CMA' ):AddLine()
			EndIf

			oModel:LoadValue( "MODEL_CMA", "CMA_CODAG",  aGravaCMA[nCMA][1] )
			oModel:LoadValue( "MODEL_CMA", "CMA_INTCON", aGravaCMA[nCMA][2] )
			oModel:LoadValue( "MODEL_CMA", "CMA_TECMED", aGravaCMA[nCMA][3] )
			oModel:LoadValue( "MODEL_CMA", "CMA_LIMTOL", aGravaCMA[nCMA][4] )
			oModel:LoadValue( "MODEL_CMA", "CMA_UNMED" , aGravaCMA[nCMA][5] )
			oModel:LoadValue( "MODEL_CMA", "CMA_TPAVAL", aGravaCMA[nCMA][6] )

			If Len(aGravaLEA) > 0 //Este modelo apesar de ser uma grid é 0-1 no layout

				oModel:GetModel( 'MODEL_LEA' ):LVALID	:= .T.
			
				oModel:LoadValue( "MODEL_LEA", "LEA_UTZEPC", aGravaLEA[1][2] )
				oModel:LoadValue( "MODEL_LEA", "LEA_UTZEPI", aGravaLEA[1][3] )
				oModel:LoadValue( "MODEL_LEA", "LEA_EFIEPC", aGravaLEA[1][4] )
				oModel:LoadValue( "MODEL_LEA", "LEA_MEDPRT", aGravaLEA[1][5] )
				oModel:LoadValue( "MODEL_LEA", "LEA_CNDFUN", aGravaLEA[1][6] )
				oModel:LoadValue( "MODEL_LEA", "LEA_PRZVLD", aGravaLEA[1][7] )		
				oModel:LoadValue( "MODEL_LEA", "LEA_PERTRC", aGravaLEA[1][8] )
				oModel:LoadValue( "MODEL_LEA", "LEA_HIGIEN", aGravaLEA[1][9] )
				oModel:LoadValue( "MODEL_LEA", "LEA_USOINI", aGravaLEA[1][10])

				If TafColumnPos("LEA_EFIEPI")
					oModel:LoadValue( "MODEL_LEA", "LEA_EFIEPI", aGravaLEA[1][11])
				EndIf

				nCMBAdd := 1
				For nCMB := 1 To Len( aGravaCMB )
					
					If aGravaCMB[nCMB][1] == aGravaCMA[nCMA][1]

						oModel:GetModel( 'MODEL_CMB' ):LVALID	:= .T.
					
						If nCMBAdd > 1
							oModel:GetModel( 'MODEL_CMB' ):AddLine()
						EndIf
						
						If !TafColumnPos("LEA_EFIEPI")
							oModel:LoadValue( "MODEL_CMB", "CMB_EFIEPI", aGravaCMB[nCMB][2] )
							oModel:LoadValue( "MODEL_CMB", "CMB_IDDESC", aGravaCMB[nCMB][3] )
							oModel:LoadValue( "MODEL_CMB",  "CMB_DVAL", aGravaCMB[nCMB][4])
						else
							oModel:LoadValue( "MODEL_CMB", "CMB_IDDESC", aGravaCMB[nCMB][2] )
							oModel:LoadValue( "MODEL_CMB",  "CMB_DVAL", aGravaCMB[nCMB][3])
						EndIf
								
						nCMBAdd++
					
					EndIf

				Next nCMB //Fim - CMB

			EndIf

			nCMAAdd++
					
		Next nCMA //Fim - CMA							

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco a versao que sera gravada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVersao := xFunGetVer()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oModel:LoadValue( "MODEL_CM9"	, "CM9_VERSAO", cVersao    )
		oModel:LoadValue( "MODEL_CM9"	, "CM9_VERANT", cVerAnt    )
		oModel:LoadValue( "MODEL_CM9"	, "CM9_PROTPN", cProtocolo )
		oModel:LoadValue( "MODEL_CM9"	, "CM9_PROTUL", ""         )
		
		/*---------------------------------------------------------
		Tratamento para que caso o Evento Anterior fosse de exclusão
		seta-se o novo evento como uma "nova inclusão", caso contrário o
		evento passar a ser uma alteração
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_CM9", "CM9_EVENTO", "E" )
		oModel:LoadValue( "MODEL_CM9", "CM9_ATIVO" , "1" )

		//Gravo alteração para o Extemporâneo
		If lGoExtemp
			TafGrvExt( oModel, 'MODEL_CM9', 'CM9' )	
		EndIf

		FwFormCommit( oModel )
		TAFAltStat( 'CM9',"6" )
		
	End Transaction

Return ( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDescEPI
Retorna a descrição do EPI
@author  Victor A. Barbosa

cIdDesc  - ID da descrição gravado na tabela CMB (Utilizado para retornar o conteúdo)

@since   28/01/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function GetDescEPI(cIDDesc)

	Local aArea    := GetArea()
	Local cDescRet := ""

	dbSelectArea("V3D")
	V3D->( dbSetOrder(1) )

	If V3D->( MsSeek( xFilial("V3D") + cIDDesc ) )
		cDescRet := V3D->V3D_DSCEPI 
	EndIf

	RestArea(aArea)

Return(cDescRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetDescEPI
Insere uma nova descrição de EPI
@author  Victor A. Barbosa

cIdDesc  - ID da descrição gravado na tabela CMB (Caso seja alteração)
cDescEPI - Descrição a ser gravado na tabela CMB

@since   28/01/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function SetDescEPI(cIdDesc, lRetif, cDescEPI)

	Local aArea     := GetArea()
	Local lLock     := .T.
	Local cIDV3D    := ""

	Default cIDDesc := ""
	Default cIdDesc := ""
	Default lRetif  := .F.

	dbSelectArea("V3D")
	V3D->( dbSetOrder(1) )

	If !Empty(cIDDesc) .And. !lRetif
		
		If V3D->( MsSeek( xFilial("V3D") + cIDDesc ) )
			lLock 	:= .F.
			cIDV3D 	:= cIDDesc
		EndIf

	Else

		// Busca a nova numeração	
		cIDV3D := GetSX8Num( "V3D", "V3D_ID" )

		While V3D->( MsSeek( xFilial("V3D") + cIDV3D ) )
			cIDV3D := GetSX8Num( "V3D", "V3D_ID" )
			ConfirmSX8()
		EndDo

	EndIf

	RecLock("V3D", lLock)
	V3D->V3D_FILIAL := xFilial("V3D")
	V3D->V3D_ID		:= cIDV3D
	V3D->V3D_DSCEPI	:= cDescEPI
	V3D->( MsUnlock() )

	V3D->( MsUnlock() )

	RestArea(aArea)

Return(cIDV3D)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF264Struct
Valida se o ambiente possui a estrutura correta
@author  Victor A. Barbosa
@since   31/01/2019
@version version
/*/
//-------------------------------------------------------------------
Static Function TAF264Struct(lViewHelp)

	Local lRet	:= .F.

	If TafColumnPos("V3D_ID") .And. TafColumnPos("CMB_IDDESC") .And. TafColumnPos("LEA_EFIEPC") .And. TafColumnPos("V3E_IDATV")
		lRet := .T.
	Else
		If lViewHelp
			MsgInfo( STR0023 , STR0024 ) //"O ambiente do TAF encontra-se desatualizado. Para utilização desta funcionalidade, será necessário executar o compatibilizador de dicionário de dados UPDDISTR disponível no portal do cliente do TAF."
										// "Ambiente Desatualizado!"
		EndIf
	EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCMP264
Função para validar o campo CMA_CODFAT
@author  jose.riquelmo	
@since   11/02/2021
@version version
/*/
//-------------------------------------------------------------------
Function VldCMP264( cCampo )

	Local cReturn := ""

	If cCampo == "CMA_CODFAT" 
		
		cReturn := ""  

	EndIf 

Return cReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} MatricCM9
description
@author  Alexandre de Lima S.
@since   11/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MatricCM9(cNomeEve)

	Local cMatric := ""

	If cNomeEve == "S2190"
		cMatric := T3A->T3A_MATRIC
	ElseIf C9V->C9V_NOMEVE == "S2300".And.!Empty(C9V->C9V_MATTSV)
		cMatric := C9V->C9V_MATTSV
	Else
		cMatric := C9V->C9V_MATRIC
	EndIf

Return cMatric

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF264DAG
Verificar se o campo Descricao de Agente Nocivo deve ser exibido
em modo de visualizacao ou alteracao utilizando o campo legado
(CMA_DSAG)

@author  Evandro S. Oliveira
@since   16/11/2021
@version 1.0
@return - Se o registro for legado retorna .T., caso contrario .F.
/*/
//-------------------------------------------------------------------
Static Function TAF264DAG() 

	Local aDescAg    := {}
	Local cQueryLeg  := ""
	Local lLegado    := .T.
	Local lDscVazio  := .T.
	Local aAreaCM9   := {}

	If !(TafColumnPos("CMA_DAGNOC"))
		Return .T.
	EndIf 

	//Chamadas do Monitor são sempre alterações ou visualuzações
	If !FWIsInCallStack("FESOCCALLV")
		//Se não for do monitor considero que a chamada foi do cadastro.
		If TYPE("INCLUI") <> "U" .and. INCLUI 
			Return .F.
		EndIf 
	EndIf 

	cQueryLeg := " SELECT CMA_DSAG, R_E_C_N_O_ RECNO "
	cQueryLeg += " FROM " + RetSqlName("CMA") 
	cQueryLeg += " WHERE CMA_FILIAL = '" + CM9->CM9_FILIAL + "'"
	cQueryLeg += " AND CMA_ID = '" + CM9->CM9_ID  + "'"
	cQueryLeg += " AND CMA_VERSAO = '" + CM9->CM9_VERSAO  + "'"

	TcQuery cQueryLeg New Alias "rsCMA"

	aAreaCM9 := CM9->(GetArea())

	While rsCMA->(!Eof())

		aDescAg := StrTokArr(AllTrim(rsCMA->CMA_DSAG),"|")  
		//Para registros novos é gravado uma String com 3 separadores "|" no campo  CMA_DSAG
		//O primeiro item do separador é a constante "PK"

		CMA->(dbGoTo(rsCMA->RECNO))

		If !Empty(CMA->CMA_DAGNOC) .Or. (Len(aDescAg) == 3 .And. aDescAg[1] == "PK")
			lLegado := .F.
			Exit
		EndIf 

		//Se o laço passar por todas as linhas e o campo CMA_DSAG estiver vazio em todas elas
		//o sistema não deve abrir a View em Modo legado 
		If Empty(rsCMA->CMA_DSAG) .And. lDscVazio
			lDscVazio := .F. 
		EndIf 

		rsCMA->(dbSkip())
	EndDo

	rsCMA->(dbCloseArea())

	RestArea(aAreaCM9)

	If !lDscVazio 
		lLegado := .F. 
	EndIf 

Return lLegado

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF264Dleg
Grava conteudo unico para o campo CMA_DSAG

@author  Evandro S. Oliveira
@since   16/11/2021
@version 1.0
@return  cDescAgVal - Unique Key 
/*/
//-------------------------------------------------------------------
Function TAF264Dleg()

	Local cDescAgVal := ""

	If TafColumnPos("CMA_DAGNOC")
		cDescAgVal := "PK|" + FWUUID("S2240") + "|" +  FWTimeStamp()
	EndIf 

Return cDescAgVal 
