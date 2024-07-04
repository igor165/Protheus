#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TAFA470.CH"

Static lTAFCodRub  := FindFunction("TAFCodRub")
Static slRubERPPad := Nil
Static lSimplBeta  := TafLayESoc("S_01_01_00",, .T.)
Static __cPicVAdv  := Nil
Static __cPicVCus  := Nil
Static __cPicQRRA  := Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA470
Cadastro MVC para atender o registro S-1207 (Benefícios previdenciários - RPPS) do e-Social.

@author rodrigo.nicolino
@since 26/01/2022
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA470()
			
	Private oBrw    := FWmBrowse():New()
		
	If TAFAtualizado( .T., "TAFA470")

		oBrw:SetDescription( STR0019 ) // Benefícios - Entes Públicos
		oBrw:SetAlias( 'T62')
		oBrw:SetMenuDef( 'TAFA470' )
		oBrw:SetFilterDefault(TAFBrwSetFilter("T62","TAFA470","S-1207"))

		TafLegend(2,"T62",@oBrw)
		
		oBrw:Activate()

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef                                     
Funcao generica MVC com as opcoes de menu

@author rodrigo.nicolino
@since 26/01/2022
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()

	Local aFuncao := {}
	Local aRotina := {}

	Aadd( aFuncao, { "" , "TafxmlRet('TAF470Xml','1207','T62')" 								, "1" } )
	Aadd( aFuncao, { "" , "xFunHisAlt( 'T62', 'TAFA470' ,,,, 'TAF470XML','1207'  )" 			, "3" } )
	Aadd( aFuncao, { "" , "TAFXmlLote( 'T62', 'S-1207' , 'evtBenPrRP' , 'TAF470Xml',, oBrw )" 	, "5" } )
	Aadd( aFuncao, { "" , "xFunAltRec( 'T62' )" 												, "10"} )

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If lMenuDif
		ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA470' OPERATION 2 ACCESS 0
	Else
		aRotina	:=	xFunMnuTAF( "TAFA470" , , aFuncao)
	EndIf

Return( aRotina )      
//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author rodrigo.nicolino
@since 26/01/2022
@version 1.0

/*/
//-------------------------------------------------------------------     
Static Function ModelDef()	

	Local oModel  	as object
	Local oStruT62	as object
	Local oStruT63	as object
	Local oStruT6O	as object
	Local oStruV6V	as object
	Local oStruV6W	as object
	Local oStruV6X	as object
	Local oStruV6Y	as object
	Local oStruV9M	as object
	
	oStruV9M := Nil

	oStruT62 := FWFormStruct( 1, 'T62' ) // Cria a estrutura a ser usada no Modelo de Dados
	oStruT63 := FWFormStruct( 1, 'T63' )
	oStruT6O := FWFormStruct( 1, 'T6O' )
	oStruV6V := FWFormStruct( 1, 'V6V' )
	oStruV6W := FWFormStruct( 1, 'V6W' )
	oStruV6X := FWFormStruct( 1, 'V6X' )
	oStruV6Y := FWFormStruct( 1, 'V6Y' )

	If lSimplBeta .And. TafColumnPos("T63_INDRRA")
		oStruV9M := FWFormStruct( 1, 'V9M' )			
	EndIf

	oStruT62:RemoveField('T62_IDBENE')
	oStruT62:RemoveField('T62_TPBENE')
	oStruT63:RemoveField('T63_IDBENE')
	oStruT63:RemoveField('T63_TPBENE')
	oStruT6O:RemoveField('T6O_IDBENE')

	oModel	:= MPFormModel():New('TAFA470',,,{|oModel| SaveModel(oModel)} )

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel

		oStruT62:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })	
		oStruT63:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT6O:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })

		oStruV6V:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 
		oStruV6X:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruV6W:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruV6Y:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })		

	EndIf

	oStruT63:SetProperty( "T63_NUMBEN", MODEL_FIELD_INIT, {| oModel | ""})

	//Remoção do GetSX8Num quando se tratar da Exclusão de um Evento Transmitido.
	//Necessário para não incrementar ID que não será utilizado.
	If Upper( ProcName( 2 ) ) == Upper( "GerarExclusao" )
		oStruT62:SetProperty( "T62_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )
	EndIf

	// Adiciona ao modelo um componente de formulário
	oModel:AddFields( 'MODEL_T62', /*cOwner*/, oStruT62)

	// Define a chave única de gravação das informações
	oModel:GetModel( 'MODEL_T62' ):SetPrimaryKey( { 'T62_INDAPU', 'T62_PERAPU', 'T62_IDBEN' } )

	oModel:AddGrid('MODEL_T63', 'MODEL_T62',oStruT63)  
	oModel:GetModel('MODEL_T63'):SetOptional( .F. )
	oModel:GetModel('MODEL_T63'):SetUniqueLine({'T63_DEMPAG'})
	oModel:GetModel('MODEL_T63'):SetMaxLine(999)

	oModel:AddGrid('MODEL_V6V', 'MODEL_T63', oStruV6V)
	oModel:GetModel('MODEL_V6V'):SetOptional(.T.)
	oModel:GetModel('MODEL_V6V'):SetUniqueLine({'V6V_TPINSC', 'V6V_NRINSC'})
	oModel:GetModel('MODEL_V6V'):SetMaxLine(500)

	oModel:AddGrid('MODEL_T6O', 'MODEL_V6V', oStruT6O)
	oModel:GetModel('MODEL_T6O'):SetOptional(.T.)
	oModel:GetModel('MODEL_T6O'):SetUniqueLine({'T6O_IDRUBR'})
	oModel:GetModel('MODEL_T6O'):SetMaxLine(200)

	oModel:AddGrid('MODEL_V6W', 'MODEL_T63', oStruV6W)
	oModel:GetModel('MODEL_V6W'):SetOptional(.T.)
	oModel:GetModel('MODEL_V6W'):SetUniqueLine({'V6W_PERREF'})
	oModel:GetModel('MODEL_V6W'):SetMaxLine(180)

	oModel:AddGrid('MODEL_V6X', 'MODEL_V6W', oStruV6X)
	oModel:GetModel('MODEL_V6X'):SetOptional(.T.)
	oModel:GetModel('MODEL_V6X'):SetUniqueLine({'V6X_TPINSC', 'V6X_NRINSC'})
	oModel:GetModel('MODEL_V6X'):SetMaxLine(500)

	oModel:AddGrid('MODEL_V6Y', 'MODEL_V6X', oStruV6Y)
	oModel:GetModel('MODEL_V6Y'):SetOptional(.T.)
	oModel:GetModel('MODEL_V6Y'):SetUniqueLine({'V6Y_CODRUB'})
	oModel:GetModel('MODEL_V6Y'):SetMaxLine(200)

	If lSimplBeta .And. TafColumnPos("T63_INDRRA")
		//IDENTIFICAÇÃO DOS ADVOGADOS
		oModel:AddGrid( "MODEL_V9M", "MODEL_T63", oStruV9M )
		oModel:GetModel( "MODEL_V9M" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V9M" ):SetUniqueLine( { "V9M_TPINSC", "V9M_NRINSC"  } )
		oModel:GetModel( "MODEL_V9M" ):SetMaxLine( 99 )
	EndIf


	/*--------------------------------------------------------
		Abaixo realiza-se a amarração das tabelas
	----------------------------------------------------------*/
	oModel:SetRelation( 'MODEL_T63', {{'T63_FILIAL',"xFilial('T63')" }, {'T63_ID','T62_ID'}, {'T63_VERSAO','T62_VERSAO'}, {'T63_INDAPU','T62_INDAPU'}, {'T63_PERAPU','T62_PERAPU'}, {'T63_IDBEN ','T62_IDBEN '}}, T63->( IndexKey(4)))
	oModel:SetRelation( 'MODEL_V6V', {{'V6V_FILIAL',"xFilial('V6V')" }, {'V6V_ID','T62_ID'}, {'V6V_VERSAO','T62_VERSAO'}, {'V6V_INDAPU','T62_INDAPU'}, {'V6V_PERAPU','T62_PERAPU'}, {'V6V_IDBEN ','T62_IDBEN '}, {'V6V_DEMPAG','T63_DEMPAG'}}, V6V->( IndexKey(2)))
	oModel:SetRelation( 'MODEL_T6O', {{'T6O_FILIAL',"xFilial('T6O')" }, {'T6O_ID','T62_ID'}, {'T6O_VERSAO','T62_VERSAO'}, {'T6O_INDAPU','T62_INDAPU'}, {'T6O_PERAPU','T62_PERAPU'}, {'T6O_IDBEN ','T62_IDBEN '}, {'T6O_DEMPAG','T63_DEMPAG'}, {'T6O_TPINSC', 'V6V_TPINSC'}, {'T6O_NRINSC', 'V6V_NRINSC'} }, T6O->( IndexKey(2)))
	oModel:SetRelation( 'MODEL_V6W', {{'V6W_FILIAL',"xFilial('V6W')" }, {'V6W_ID','T62_ID'}, {'V6W_VERSAO','T62_VERSAO'}, {'V6W_INDAPU','T62_INDAPU'}, {'V6W_PERAPU','T62_PERAPU'}, {'V6W_IDBEN ','T62_IDBEN '}, {'V6W_DEMPAG','T63_DEMPAG'}}, V6W->( IndexKey(2)))
	oModel:SetRelation( 'MODEL_V6X', {{'V6X_FILIAL',"xFilial('V6X')" }, {'V6X_ID','T62_ID'}, {'V6X_VERSAO','T62_VERSAO'}, {'V6X_INDAPU','T62_INDAPU'}, {'V6X_PERAPU','T62_PERAPU'}, {'V6X_IDBEN ','T62_IDBEN '}, {'V6X_DEMPAG','T63_DEMPAG'}, {'V6X_PERREF', 'V6W_PERREF'}}, V6X->( IndexKey(2)))
	oModel:SetRelation( 'MODEL_V6Y', {{'V6Y_FILIAL',"xFilial('V6Y')" }, {'V6Y_ID','T62_ID'}, {'V6Y_VERSAO','T62_VERSAO'}, {'V6Y_INDAPU','T62_INDAPU'}, {'V6Y_PERAPU','T62_PERAPU'}, {'V6Y_IDBEN ','T62_IDBEN '}, {'V6Y_DEMPAG','T63_DEMPAG'}, {'V6Y_PERREF', 'V6W_PERREF'}, {'V6Y_TPINSC', 'V6X_TPINSC'}, {'V6Y_NRINSC', 'V6X_NRINSC'} }, V6Y->( IndexKey(2)))
	
	If lSimplBeta .And. TafColumnPos("T63_INDRRA")
		oModel:SetRelation('MODEL_V9M', {{'V9M_FILIAL' , 'xFilial( "V9M" )'}, {'V9M_ID' , 'T62_ID'}, {'V9M_VERSAO' , 'T62_VERSAO'}, {'V9M_INDAPU','T62_INDAPU'}, {'V9M_PERAPU','T62_PERAPU'}, {'V9M_IDBEN ','T62_IDBEN '}, {'V9M_DEMPAG','T63_DEMPAG'}}, V9M->(IndexKey(1)))
	EndIf

Return oModel             

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author rodrigo.nicolino
@since 26/01/2022
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local cCmpFila  as character
	Local cCmpFilb  as character
	Local cCmpFilc  as character
	Local cAbaApur	as character
	Local cAbaAnt   as character
	Local cAbaRRA 	as character	
	Local oModel    as object
	Local oStruT62a as object
	Local oStruT62b as object
	Local oStruT63  as object
	Local oStruT6O  as object
	Local oStruV6V  as object
	Local oStruV6W  as object
	Local oStruV6X  as object
	Local oStruV6Y  as object
	Local oStruV9M  as object	
	Local oView     as object
	
	oModel	 := FWLoadModel( 'TAFA470' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado

	oView	 := FWFormView():New()

	oView:SetModel( oModel )
	oView:SetContinuousForm()

	oStruT63 := FWFormStruct( 2, 'T63' )
	oStruT6O := FWFormStruct( 2, 'T6O' )
	oStruV6V := FWFormStruct( 2, "V6V" )
	oStruV6W :=	FWFormStruct( 2, "V6W" )
	oStruV6X := FWFormStruct( 2, "V6X" )
	oStruV6Y := FWFormStruct( 2, "V6Y" )
	
	oStruT63:RemoveField('T63_IDBENE' )
	oStruT63:RemoveField('T63_TPBENE' )
	oStruT63:RemoveField('T63_IDBEN'  ) 
	oStruT6O:RemoveField('T6O_IDBENE' )
	oStruT6O:RemoveField('T6O_IDBEN'  )
	oStruT6O:RemoveField('T6O_TABRUB' )
	oStruV6V:RemoveField('V6V_IDBEN'  ) 
	oStruV6V:RemoveField('V6V_TPINSC' )
	oStruV6W:RemoveField('V6W_IDBEN'  ) 
	oStruV6X:RemoveField('V6X_IDBEN'  ) 
	oStruV6X:RemoveField('V6X_TPINSC' )
	oStruV6Y:RemoveField('V6Y_IDBEN'  ) 
	oStruV6Y:RemoveField('V6Y_TABRUB' )

	If lSimplBeta .And. TafColumnPos("T63_INDRRA")
		cAbaApur  := "ABA02"
		cAbaAnt   := "ABA03"
		cAbaRRA   := "ABA01"
		oStruV9M  := FWFormStruct( 2, 'V9M' )

		oStruV9M:SetProperty( "V9M_TPINSC"	, MVC_VIEW_ORDEM , "01" )
		oStruV9M:SetProperty( "V9M_NRINSC"	, MVC_VIEW_ORDEM , "02" )
		oStruV9M:SetProperty( "V9M_VLRADV"	, MVC_VIEW_ORDEM , "03" )
	Else
		cAbaApur  := "ABA01"
		cAbaAnt   := "ABA02"
		cAbaRRA   := ""
		oStruV9M  := Nil

		If TafColumnPos("T63_INDRRA")
			oStruT63:RemoveField('T63_INDRRA' )
			oStruT63:RemoveField('T63_TPPRRA' )
			oStruT63:RemoveField('T63_NRPRRA' )
			oStruT63:RemoveField('T63_DESCRA' )
			oStruT63:RemoveField('T63_QTMRRA' )
			oStruT63:RemoveField('T63_VLRCUS' )
			oStruT63:RemoveField('T63_VLRADV' )
		EndIf

	EndIf	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Campos da View do Evento S-1207								       	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCmpFila	:= "T62_INDAPU|T62_PERAPU|T62_IDBEN|T62_NOMEB|T62_CPF|"			//Identificação do beneficiário
	cCmpFilb	:= "T62_PROTUL|"												//Informações de identificação do evento
	
	If TafColumnPos("T62_DTRANS")
		cCmpFilc	:= "T62_DINSIS|T62_DTTRAN|T62_HTRANS|T62_DTRECP|T62_HRRECP|"	//Dados transmissao
	EndIf

	oStruT62a := FwFormStruct( 2, 'T62', {|x| AllTrim( x ) + "|" $ cCmpFila } )
	oStruT62b := FwFormStruct( 2, 'T62', {|x| AllTrim( x ) + "|" $ cCmpFilb } )
	oStruT62c := FwFormStruct( 2, 'T62', {|x| AllTrim( x ) + "|" $ cCmpFilc } )

	TafAjustRecibo(oStruT62b,"T62")

	/*-------------------------------------------
				Esrutura da View
	---------------------------------------------*/
	// Cabeçalho
	oView:AddField( 'VIEW_T62a',oStruT62a, 'MODEL_T62' )
	oView:EnableTitleView( 'VIEW_T62a',  STR0019 ) //Benefícios - Entes Públicos

	oView:AddField( 'VIEW_T62b',oStruT62b, 'MODEL_T62' )
	oView:EnableTitleView( 'VIEW_T62b', TafNmFolder("recibo",1) ) //Recibo da última Transmissão

	oView:AddField( 'VIEW_T62c',oStruT62c, 'MODEL_T62' )
	oView:EnableTitleView( 'VIEW_T62c', TafNmFolder("recibo",2) ) //"Informações de Controle eSocial"

	// Grids
	oView:AddGrid( 'VIEW_T63', oStruT63, 'MODEL_T63' )
	oView:EnableTitleView( 'VIEW_T63',  STR0008 ) //Demonstrativos de Valores

	oView:AddGrid( 'VIEW_T6O', oStruT6O, 'MODEL_T6O' )
	oView:EnableTitleView( 'VIEW_T6O',  STR0009 ) //Detalhamento dos valores devidos ao beneficiário

	oView:AddGrid( 'VIEW_V6V', oStruV6V, 'MODEL_V6V' )
	oView:EnableTitleView( 'VIEW_V6V',  STR0012 ) //Informações de Estabelecimento

	oView:AddGrid( 'VIEW_V6W', oStruV6W, 'MODEL_V6W' )
	oView:EnableTitleView( 'VIEW_V6W',  STR0013 ) //Informações de Unidade do Órgão Público

	oView:AddGrid( 'VIEW_V6X', oStruV6X, 'MODEL_V6X' )
	oView:EnableTitleView( 'VIEW_V6X',  STR0012 ) //Informações de Estabelecimento

	oView:AddGrid( 'VIEW_V6Y', oStruV6Y, 'MODEL_V6Y' )
	oView:EnableTitleView( 'VIEW_V6Y',  STR0014 ) //Informações de Rubricas

	If lSimplBeta .And. TafColumnPos("T63_INDRRA")
		oView:AddGrid( 'VIEW_V9M', oStruV9M, 'MODEL_V9M' )
		oView:EnableTitleView("VIEW_V9M", STR0037) //"Identificação dos advogados"		
	EndIf

	/*-----------------------------------------
			Estrutura do Folder
	-------------------------------------------*/
	oView:CreateHorizontalBox( 'PAINEL_SUPERIOR', 100 )

	oView:CreateFolder( 'PASTAS', 'PAINEL_SUPERIOR' )
	oView:AddSheet( 'PASTAS', 'ABA00', STR0019) // Benefícios - Entes Públicos
	oView:AddSheet( 'PASTAS', 'ABA01', STR0024)	//Recibo da última Transmissã

	oView:CreateHorizontalBox( 'T62a'		, 030,,, 'PASTAS', 'ABA00' )
	oView:CreateHorizontalBox( 'GRIDT63'	, 030,,, 'PASTAS', 'ABA00' )
	oView:CreateHorizontalBox( 'T62b'		, 020,,, 'PASTAS', 'ABA01' )
	oView:CreateHorizontalBox( 'T62c'		, 020,,, 'PASTAS', 'ABA01' )

	oView:CreateHorizontalBox( "PAINEL_INFERIOR"	, 040,,, "PASTAS", "ABA00" )
	oView:CreateFolder( 'FOLDER_INFERIOR', 'PAINEL_INFERIOR' )

	If lSimplBeta .And. TafColumnPos("T63_INDRRA")
		oView:AddSheet( 'FOLDER_INFERIOR', cAbaRRA , STR0036 ) 		
		oView:CreateHorizontalBox( 'GRIDV9M'   ,   050,,, 'FOLDER_INFERIOR', cAbaRRA )
	EndIf

	oView:AddSheet( 'FOLDER_INFERIOR', cAbaApur, STR0010 ) //Informações no Periodo de Apuração
	oView:AddSheet( 'FOLDER_INFERIOR', cAbaAnt, STR0011 ) //Informações no Periodo Anterior
	
	oView:CreateHorizontalBox( 'GRIDV6V', 050,,, 'FOLDER_INFERIOR', cAbaApur )
	oView:CreateHorizontalBox( 'GRIDT6O', 050,,, 'FOLDER_INFERIOR', cAbaApur )

	oView:CreateHorizontalBox( 'GRIDV6W', 030,,, 'FOLDER_INFERIOR', cAbaAnt )
	oView:CreateHorizontalBox( 'GRIDV6X', 030,,, 'FOLDER_INFERIOR', cAbaAnt )
	oView:CreateHorizontalBox( 'GRIDV6Y', 040,,, 'FOLDER_INFERIOR', cAbaAnt )
	
	/*-----------------------------------------
	Amarração para exibição das informações
	-------------------------------------------*/
	oView:SetOwnerView( 'VIEW_T62a', 'T62a' )
	oView:SetOwnerView( 'VIEW_T62b', 'T62b' )
	oView:SetOwnerView( 'VIEW_T62c', 'T62c' )
	oView:SetOwnerView( 'VIEW_T63', 'GRIDT63' ) 
	oView:SetOwnerView( 'VIEW_T6O', 'GRIDT6O' ) 
	oView:SetOwnerView( 'VIEW_V6V', 'GRIDV6V' )
	oView:SetOwnerView( 'VIEW_V6W', 'GRIDV6W' )
	oView:SetOwnerView( 'VIEW_V6X', 'GRIDV6X' )
	oView:SetOwnerView( 'VIEW_V6Y', 'GRIDV6Y' )

	If lSimplBeta .And. TafColumnPos("T63_INDRRA")
		oView:SetOwnerView( 'VIEW_V9M' , 'GRIDV9M' )		
	EndIf

	oStruT6O:SetProperty( "T6O_IDRUBR"	, MVC_VIEW_ORDEM, "04" )
	oStruT6O:SetProperty( "T6O_DRUBR"	, MVC_VIEW_ORDEM, "05" )
	oStruT6O:SetProperty( "T6O_QTDRUB"	, MVC_VIEW_ORDEM, "06" )
	oStruT6O:SetProperty( "T6O_FATRUB"	, MVC_VIEW_ORDEM, "07" )
	oStruT6O:SetProperty( "T6O_VLRRUB"	, MVC_VIEW_ORDEM, "08" )
	oStruT6O:SetProperty( "T6O_APUIR"	, MVC_VIEW_ORDEM, "09" )

	oStruT62a:SetProperty( "T62_INDAPU"	, MVC_VIEW_ORDEM, "04" )
	oStruT62a:SetProperty( "T62_PERAPU"	, MVC_VIEW_ORDEM, "05" )
	oStruT62a:SetProperty( "T62_IDBEN"	, MVC_VIEW_ORDEM, "06" )
	oStruT62a:SetProperty( "T62_NOMEB"	, MVC_VIEW_ORDEM, "07" )
	oStruT62a:SetProperty( "T62_CPF"	, MVC_VIEW_ORDEM, "08" )

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If !lMenuDif
		
		xFunRmFStr(@oStruT62a, 'T62')
		xFunRmFStr(@oStruT62b, 'T62')		
		xFunRmFStr(@oStruT63 , 'T63')
		xFunRmFStr(@oStruT6O , 'T6O')
		xFunRmFStr(@oStruV6V , 'V6V')
		xFunRmFStr(@oStruV6W , 'V6W')
		xFunRmFStr(@oStruV6X , 'V6X')
		xFunRmFStr(@oStruV6Y , 'V6Y')		

	EndIf

	If TafColumnPos( "T62_LOGOPE" )
		oStruT62a:RemoveField( "T62_LOGOPE" )
	EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author rodrigo.nicolino
@since 26/01/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)
                     
	Local aGravaT62  as array
	Local aGravaT63  as array
	Local aGravaT6O  as array
	Local aGravaV6V  as array
	Local aGravaV6W  as array
	Local aGravaV6X  as array
	Local aGravaV6Y  as array
	Local aGravaV9M  as array
	Local cChvRegAnt as character
	Local cEvento    as character
	Local cLogOpeAnt as character
	Local cProtocolo as character
	Local cVerAnt    as character
	Local cVersao    as character
	Local lRetorno   as logical
	Local nlI        as numeric
	Local nlY        as numeric
	Local nOperation as numeric
	Local nT62       as numeric
	Local nT63       as numeric
	Local nT6O       as numeric
	Local nV6V       as numeric
	Local nV6W       as numeric
	Local nV6X       as numeric
	Local nV6Y       as numeric
	Local nV9M		 as numeric
	Local nV9MAdd	 as numeric
	Local oModelT62  as object
	Local oModelT63  as object
	Local oModelT6O  as object
	Local oModelV6V  as object
	Local oModelV6W  as object
	Local oModelV6X  as object
	Local oModelV6Y  as object
	Local oModelV9M  as object

	aGravaT62  := {}
	aGravaT63  := {}
	aGravaT6O  := {}
	aGravaV6V  := {}
	aGravaV6W  := {}
	aGravaV6X  := {}
	aGravaV6Y  := {}
	aGravaV9M  := {}
	cChvRegAnt := ""
	cEvento    := ""
	cLogOpeAnt := ""
	cProtocolo := ""
	cVerAnt    := ""
	cVersao    := ""
	lRetorno   := .T.
	nlI        := 0
	nlY        := 0
	nOperation := oModel:GetOperation()
	nT62       := 0
	nT63       := 0
	nT6O       := 0
	nV6V       := 0
	nV6W       := 0
	nV6X       := 0
	nV6Y       := 0
	nV9M       := 0
	nV9MAdd	   := 0
	oModelT62  := Nil
	oModelT63  := Nil
	oModelT6O  := Nil
	oModelV6V  := Nil
	oModelV6W  := Nil
	oModelV6X  := Nil
	oModelV6Y  := Nil
	oModelV9M  := Nil

	Begin Transaction 
		
		//Inclusao Manual do Evento
		If nOperation == MODEL_OPERATION_INSERT

			TafAjustID( "T62", oModel)
			
			oModel:LoadValue( 'MODEL_T62', 'T62_VERSAO', xFunGetVer() )
			oModel:LoadValue( 'MODEL_T62', 'T62_NOMEVE', "S1207" )

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_T62', 'T62_LOGOPE' , '2', '' )
			Endif

			FwFormCommit( oModel )

		//Alteração Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_UPDATE

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			T62->( DbSetOrder( 3 ) )
			If T62->( MsSeek( xFilial( 'T62' ) + FwFldGet('T62_ID')+ '1' ) )
									
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o registro ja foi transmitido³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If T62->T62_STATUS == "4" 
									
					oModelT62 := oModel:GetModel( 'MODEL_T62' )
					oModelT63 := oModel:GetModel( 'MODEL_T63' )
					oModelT6O := oModel:GetModel( 'MODEL_T6O' )
					oModelV6V := oModel:GetModel( 'MODEL_V6V' )
					oModelV6W := oModel:GetModel( 'MODEL_V6W' )
					oModelV6Y := oModel:GetModel( 'MODEL_V6Y' )
					oModelV6X := oModel:GetModel( 'MODEL_V6X' )

					If lSimplBeta .And. TafColumnPos("T63_INDRRA")
						oModelV9M := oModel:GetModel( 'MODEL_V9M' )
					EndIf
											
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao anterior do registro para gravacao do rastro³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVerAnt		:= oModelT62:GetValue( "T62_VERSAO" )
					cProtocolo	:= oModelT62:GetValue( "T62_PROTUL" )
					cEvento		:= oModelT62:GetValue( "T62_EVENTO" )

					If TafColumnPos( "T62_LOGOPE" )
						cLogOpeAnt := oModelT62:GetValue( "T62_LOGOPE" )
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu gravo as informacoes que foram carregadas       ³
					//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
					//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
					//³nao devem ser consideradas neste momento                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nlI := 1 To 1
						For nlY := 1 To Len( oModelT62:aDataModel[ nlI ] )			
							Aadd( aGravaT62, { oModelT62:aDataModel[ nlI, nlY, 1 ], oModelT62:aDataModel[ nlI, nlY, 2 ] } )									
						Next
					Next	       						
					
					If !oModel:GetModel( 'MODEL_T63' ):IsEmpty()

						For nT63 := 1 To oModel:GetModel( 'MODEL_T63' ):Length()

							oModel:GetModel( 'MODEL_T63' ):Goline(nT63) 
				
							If !oModel:GetModel( 'MODEL_T63' ):IsDeleted()	

								If lSimplBeta .And. TafColumnPos("T63_INDRRA")

									aAdd(aGravaT63, { oModelT62:GetValue('T62_INDAPU') + oModelT62:GetValue('T62_PERAPU') + oModelT62:GetValue('T62_CPF'),;												
													oModelT63:GetValue('T63_DEMPAG'),;
													oModelT63:GetValue('T63_NUMBEN'),;
													oModelT63:GetValue('T63_INDRRA'),;
													oModelT63:GetValue('T63_TPPRRA'),;
													oModelT63:GetValue('T63_NRPRRA'),;
													oModelT63:GetValue('T63_DESCRA'),;
													oModelT63:GetValue('T63_QTMRRA'),;
													oModelT63:GetValue('T63_VLRCUS'),;
													oModelT63:GetValue('T63_VLRADV')})

									/*------------------------------------------
										V9M - Informações de Valores Pagos
									--------------------------------------------*/
									For nV9M := 1 to oModel:GetModel( "MODEL_V9M" ):Length()

										oModel:GetModel( "MODEL_V9M" ):GoLine(nV9M)

										If !oModel:GetModel( 'MODEL_V9M' ):IsEmpty()

											If !oModel:GetModel( "MODEL_V9M" ):IsDeleted()

												aAdd (aGravaV9M ,{  oModelT62:GetValue('T62_INDAPU') + oModelT62:GetValue('T62_PERAPU') + oModelT63:GetValue('T63_DEMPAG'),;
																	oModelV9M:GetValue('V9M_TPINSC'),;
																	oModelV9M:GetValue('V9M_NRINSC'),;
																	oModelV9M:GetValue('V9M_VLRADV')})
											EndIf

										EndIf

									Next //nV9M	
								Else
									aAdd(aGravaT63, { oModelT62:GetValue('T62_INDAPU') + oModelT62:GetValue('T62_PERAPU') + oModelT62:GetValue('T62_CPF'),;												
													oModelT63:GetValue('T63_DEMPAG'),;
													oModelT63:GetValue('T63_NUMBEN')})
								EndIf

								If !oModel:GetModel( 'MODEL_V6V' ):IsEmpty() 

									For nV6V := 1 To oModel:GetModel( 'MODEL_V6V' ):Length()

										oModel:GetModel( 'MODEL_V6V' ):GoLine(nV6V)
									
										If !oModel:GetModel( 'MODEL_V6V' ):IsDeleted()

											aAdd(aGravaV6V, { oModelT62:GetValue('T62_INDAPU') + oModelT62:GetValue('T62_PERAPU') + oModelT63:GetValue('T63_DEMPAG'),;																													
																oModelV6V:GetValue('V6V_TPINSC'),;
																oModelV6V:GetValue('V6V_NRINSC')})

											If !oModel:GetModel( 'MODEL_T6O' ):IsEmpty()

												For nT6O := 1 To oModel:GetModel( 'MODEL_T6O' ):Length() 

													oModel:GetModel( 'MODEL_T6O' ):GoLine(nT6O)

													If !oModel:GetModel( 'MODEL_T6O' ):IsDeleted()

														aAdd(aGravaT6O, { oModelT62:GetValue('T62_INDAPU') + oModelT62:GetValue('T62_PERAPU') + oModelT63:GetValue('T63_DEMPAG') + oModelV6V:GetValue('V6V_TPINSC') + oModelV6V:GetValue('V6V_NRINSC'),;								  																																										
																			oModelT6O:GetValue('T6O_IDRUBR'),;
																			oModelT6O:GetValue('T6O_DRUBR '),;
																			oModelT6O:GetValue('T6O_TABRUB'),; 
																			oModelT6O:GetValue('T6O_QTDRUB'),; 
																			oModelT6O:GetValue('T6O_FATRUB'),; 
																			oModelT6O:GetValue('T6O_VLRRUB'),; 
																			oModelT6O:GetValue('T6O_APUIR')})	

													EndIf

												Next// FIM - T6O
												
											EndIf												
									
										EndIf											

									Next// FIM - V6V

								EndIf

								If !oModel:GetModel( 'MODEL_V6W' ):IsEmpty()

									For nV6W := 1 To oModel:GetModel( 'MODEL_V6W' ):Length()

										oModel:GetModel( 'MODEL_V6W' ):GoLine(nV6W)
										
										If !oModel:GetModel( 'MODEL_V6W' ):IsDeleted()

											aAdd(aGravaV6W, { oModelT62:GetValue('T62_INDAPU') + oModelT62:GetValue('T62_PERAPU') + oModelT63:GetValue('T63_DEMPAG'),;																
															  oModelV6W:GetValue('V6W_PERREF')})

											If !oModel:GetModel( 'MODEL_V6X' ):IsEmpty()

												For nV6X := 1 To oModel:GetModel( 'MODEL_V6X' ):Length()

													oModel:GetModel( 'MODEL_V6X' ):GoLine(nV6X)

													If !oModel:GetModel( 'MODEL_V6X' ):IsDeleted()

														aAdd(aGravaV6X, { oModelT62:GetValue('T62_INDAPU') + oModelT62:GetValue('T62_PERAPU') + oModelT63:GetValue('T63_DEMPAG') + oModelV6W:GetValue('V6W_PERREF'),;
																		  oModelV6X:GetValue('V6X_TPINSC'),;
																		  oModelV6X:GetValue('V6X_NRINSC')})

														If !oModel:GetModel( 'MODEL_V6Y' ):IsEmpty()

															For nV6Y := 1 To oModel:GetModel( 'MODEL_V6Y' ):Length()

																oModel:GetModel( 'MODEL_V6Y' ):GoLine(nV6Y)
																
																If !oModel:GetModel( 'MODEL_V6Y' ):IsDeleted()

																	aAdd(aGravaV6Y, { oModelT62:GetValue('T62_INDAPU') + oModelT62:GetValue('T62_PERAPU') + oModelT63:GetValue('T63_DEMPAG') + oModelV6W:GetValue('V6W_PERREF') + oModelV6X:GetValue('V6X_TPINSC') + oModelV6X:GetValue('V6X_NRINSC'),;												
																					  oModelV6Y:GetValue('V6Y_CODRUB'),;
																					  oModelV6Y:GetValue('V6Y_DCODRU'),;
																					  oModelV6Y:GetValue('V6Y_VRRUBR'),;
																					  oModelV6Y:GetValue('V6Y_TABRUB'),;
																					  oModelV6Y:GetValue('V6Y_QTDRUB'),;
																					  oModelV6Y:GetValue('V6Y_FATRUB'),;
																					 oModelV6Y:GetValue('V6Y_APURIR')})
																EndIf

															Next// FIM - V6Y

														EndIf																

													EndIf

												Next// FIM V6X

											EndIf

										EndIf

									Next// FIM - V6W
								
								EndIf

							EndIf
						
						Next // Fim - T63

					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seto o campo como Inativo e gravo a versao do novo registro³
					//³no registro anterior                                       ³ 
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FAltRegAnt( 'T62', '2' )
				
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
					For nT62 := 1 to Len( aGravaT62 )
							oModel:LoadValue( "MODEL_T62", aGravaT62[ nT62, 1 ], aGravaT62[ nT62, 2 ] )
					Next nT62

					//Necessário Abaixo do For Nao Retirar
					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T62', 'T62_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					For nT63 := 1 To Len( aGravaT63 )

						If aGravaT63[nT63][1] == aGravaT62[4][2] + aGravaT62[5][2] + aGravaT62[6][2]	

							oModel:GetModel( 'MODEL_T63' ):LVALID	:= .T.
				
							If nT63 > 1
								oModel:GetModel( 'MODEL_T63' ):AddLine()
							EndIf

							oModel:LoadValue( "MODEL_T63", "T63_DEMPAG", aGravaT63[nT63][2])
							oModel:LoadValue( "MODEL_T63", "T63_NUMBEN", aGravaT63[nT63][3])

							If lSimplBeta .And. TafColumnPos("T63_INDRRA")
								oModel:LoadValue( "MODEL_T63", "T63_INDRRA", aGravaT63[nT63][4] )
								oModel:LoadValue( "MODEL_T63", "T63_TPPRRA", aGravaT63[nT63][5] )
								oModel:LoadValue( "MODEL_T63", "T63_NRPRRA", aGravaT63[nT63][6] )
								oModel:LoadValue( "MODEL_T63", "T63_DESCRA", aGravaT63[nT63][7] )
								oModel:LoadValue( "MODEL_T63", "T63_QTMRRA", aGravaT63[nT63][8] )
								oModel:LoadValue( "MODEL_T63", "T63_VLRCUS", aGravaT63[nT63][9] )
								oModel:LoadValue( "MODEL_T63", "T63_VLRADV", aGravaT63[nT63][10] )

								/*------------------------------------------
								V9M - Identificação dos advogados   
								--------------------------------------------*/
								nV9MAdd := 1
								For nV9M := 1 to Len( aGravaV9M )

									If  aGravaV9M[nV9M][1] == aGravaT62[4][2] + aGravaT62[5][2] + aGravaT63[nT63][2]

										oModel:GetModel( 'MODEL_V9M' ):LVALID := .T.

										If nV9MAdd > 1
											oModel:GetModel( "MODEL_V9M" ):AddLine()
										EndIf

										oModel:LoadValue( "MODEL_V9M", "V9M_TPINSC", aGravaV9M[nV9M][2] )
										oModel:LoadValue( "MODEL_V9M", "V9M_NRINSC", aGravaV9M[nV9M][3] )
										oModel:LoadValue( "MODEL_V9M", "V9M_VLRADV", aGravaV9M[nV9M][4] )
									
										nV9MAdd++
									EndIf

								Next
							EndIf

							nV6VAdd := 1

							For nV6V := 1 To Len( aGravaV6V )

								If aGravaV6V[nV6V][1] == aGravaT62[4][2] + aGravaT62[5][2] + aGravaT63[nT63][2]

									oModel:GetModel( 'MODEL_V6V' ):LVALID	:= .T.
		
									If nV6VAdd > 1
										oModel:GetModel( 'MODEL_V6V' ):AddLine()
									EndIf							
							
									oModel:LoadValue( "MODEL_V6V", "V6V_TPINSC", aGravaV6V[nV6V][2] )
									oModel:LoadValue( "MODEL_V6V", "V6V_NRINSC", aGravaV6V[nV6V][3] )

									nT6OAdd := 1

									For nT6O := 1 To Len( aGravaT6O )

										// Grava apenas o T6O pertencente ao T63
										If aGravaT6O[nT6O][1] == aGravaT62[4][2] + aGravaT62[5][2] + aGravaT63[nT63][2] + aGravaV6V[nV6V][2] + aGravaV6V[nV6V][3]

											oModel:GetModel( 'MODEL_T6O' ):LVALID	:= .T.

											If nT6OAdd > 1
												oModel:GetModel( 'MODEL_T6O' ):AddLine()

											EndIf
										
											oModel:LoadValue( "MODEL_T6O", "T6O_IDRUBR", aGravaT6O[nT6O][2] )
											oModel:LoadValue( "MODEL_T6O", "T6O_DRUBR ", aGravaT6O[nT6O][3] )
											oModel:LoadValue( "MODEL_T6O", "T6O_TABRUB", aGravaT6O[nT6O][4] )
											oModel:LoadValue( "MODEL_T6O", "T6O_QTDRUB", aGravaT6O[nT6O][5] )
											oModel:LoadValue( "MODEL_T6O", "T6O_FATRUB", aGravaT6O[nT6O][6] )							
											oModel:LoadValue( "MODEL_T6O", "T6O_VLRRUB", aGravaT6O[nT6O][7] )						
											oModel:LoadValue( "MODEL_T6O", "T6O_APUIR ", aGravaT6O[nT6O][8] )						

											nT6OAdd++

										EndIf								

			        				Next // Fim - T6O
								
									nV6VAdd++	

								EndIf						

			        		Next // Fim - V6V
									
							nV6WAdd := 1

							For nV6W := 1 To Len( aGravaV6W )
														
								If aGravaV6W[nV6W][1] == aGravaT62[4][2] + aGravaT62[5][2] + aGravaT63[nT63][2]

									oModel:GetModel( 'MODEL_V6W' ):LVALID	:= .T.

									If nV6WAdd > 1
										oModel:GetModel( 'MODEL_V6W' ):AddLine()
									EndIf

									oModel:LoadValue( "MODEL_V6W", "V6W_PERREF", aGravaV6W[nV6W][2] )

									nV6XAdd := 1

									For nV6X := 1 To Len( aGravaV6X )	

										If aGravaV6X[nV6X][1] == aGravaT62[4][2] + aGravaT62[5][2] + aGravaT63[nT63][2] + aGravaV6W[nV6W][2]

											oModel:GetModel( 'MODEL_V6X' ):LVALID	:= .T.

											If nV6XAdd > 1
												oModel:GetModel( 'MODEL_V6X' ):AddLine()
											EndIf

											oModel:LoadValue( "MODEL_V6X", "V6X_TPINSC", aGravaV6X[nV6X][2] )						
											oModel:LoadValue( "MODEL_V6X", "V6X_NRINSC", aGravaV6X[nV6X][3] )	

											nV6YAdd := 1

											For nV6Y := 1 To Len(aGravaV6Y)

												If aGravaV6Y[nV6Y][1] == aGravaT62[4][2] + aGravaT62[5][2] + aGravaT63[nT63][2] + aGravaV6W[nV6W][2] + aGravaV6X[nV6X][2] + aGravaV6X[nV6X][3]	

													oModel:GetModel( 'MODEL_V6Y' ):LVALID := .T.

													If nV6YAdd > 1
														oModel:GetModel( 'MODEL_V6Y' ):AddLine()
													EndIf

													oModel:LoadValue( "MODEL_V6Y", "V6Y_CODRUB", aGravaV6Y[nV6Y][2] ) 
													oModel:LoadValue( "MODEL_V6Y", "V6Y_DCODRU", aGravaV6Y[nV6Y][3] ) 
													oModel:LoadValue( "MODEL_V6Y", "V6Y_VRRUBR", aGravaV6Y[nV6Y][4] ) 
													oModel:LoadValue( "MODEL_V6Y", "V6Y_TABRUB", aGravaV6Y[nV6Y][5] ) 
													oModel:LoadValue( "MODEL_V6Y", "V6Y_QTDRUB", aGravaV6Y[nV6Y][6] ) 
													oModel:LoadValue( "MODEL_V6Y", "V6Y_FATRUB", aGravaV6Y[nV6Y][7] ) 
													oModel:LoadValue( "MODEL_V6Y", "V6Y_APURIR", aGravaV6Y[nV6Y][8] ) 

													nV6YAdd++

												EndIf

											Next // Fim - V6Y

											nV6XAdd++

										EndIf								
									
			        				Next // Fim - V6X

									nV6WAdd++

								EndIf
							
			        		Next // Fim - V6W

						EndIf
					
					Next // Fim - T63
						
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao que sera gravada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVersao := xFunGetVer()		 
													
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿		
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		                                                                      				         
					oModel:LoadValue( 'MODEL_T62', 'T62_VERSAO', cVersao    )
					oModel:LoadValue( 'MODEL_T62', 'T62_VERANT', cVerAnt    )
					oModel:LoadValue( 'MODEL_T62', 'T62_PROTPN', cProtocolo )
					oModel:LoadValue( 'MODEL_T62', 'T62_PROTUL', ""         )
					oModel:LoadValue( "MODEL_T62", "T62_EVENTO", "A"        )

					// Tratamento para limpar o ID unico do xml
					cAliasPai := "T62"
					If TAFColumnPos( cAliasPai+"_XMLID" )
						oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					EndIf
					
					FwFormCommit( oModel )
					TAFAltStat( 'T62', " " ) 					

				ElseIf	T62->T62_STATUS == "2"     

					TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
					lRetorno:= .F.

				ElseIf T62->T62_STATUS == "6"     

					TAFMsgVldOp(oModel,"6")//"Registro não pode ser alterado. Aguardando proc. Transm. evento de Exclusão S-3000"
					lRetorno:= .F.

				Elseif T62->T62_STATUS == "7"

					TAFMsgVldOp(oModel,"7") //"Registro não pode ser alterado, pois o evento já se encontra na base do RET"  
					lRetorno:= .F.

				Else

					If TafColumnPos( "T62_LOGOPE" )
						cLogOpeAnt := T62->T62_LOGOPE
					EndIf

					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T62', 'T62_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					FwFormCommit( oModel )
					TAFAltStat( 'T62', " " )  

				EndIf

			EndIf

		//Exclusão Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_DELETE	  

			cChvRegAnt := T62->(T62_ID + T62_VERANT)  	  

			TAFAltStat( 'T62', " " )
			FwFormCommit( oModel )				

			If T62->T62_EVENTO == "A" .Or. T62->T62_EVENTO == "E"
				TAFRastro( 'T62', 1, cChvRegAnt, .T. , , IIF(Type("oBrw") == "U", Nil, oBrw) )
			EndIf

		EndIf

	End Transaction 

Return ( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF470Grv
@type			function
@description	Função de gravação para atender o registro S-1207.
@author 		rodrigo.nicolino
@since 			26/01/2022
@version		1.0
@param			cLayout		-	Nome do Layout que está sendo enviado
@param			nOpc		-	Opção a ser realizada ( 3 = Inclusão, 4 = Alteração, 5 = Exclusão )
@param			cFilEv		-	Filial do ERP para onde as informações deverão ser importadas
@param			oXML		-	Objeto com as informações a serem manutenidas ( Outras Integrações )
@param			cOwner
@param			cFilTran
@param			cPredeces
@param			nTafRecno
@param			cComplem
@param			cGrpTran
@param			cEmpOriGrp
@param			cFilOriGrp
@param			cXmlID		-	Atributo Id, único para o XML do eSocial. Utilizado para importação de dados de clientes migrando para o TAF
@return			lRet		-	Variável que indica se a importação foi realizada, ou seja, se as informações foram gravadas no banco de dados
@param			aIncons		-	Array com as inconsistências encontradas durante a importação
/*/
//-------------------------------------------------------------------
Function TAF470Grv( cLayout as character, nOpc as numeric, cFilEv as character, oXML as object, cOwner as character, cFilTran as character, cPredeces as character, nTafRecno as numeric, cComplem as character, cGrpTran as character, cEmpOriGrp as character, cFilOriGrp as character, cXmlID as character, cEvtOri as character, lMigrador as logical, lDepGPE as logical, cKey as character, cMatrC9V as character, lLaySmpTot as logical, lExclCMJ as logical, oTransf as object, cXml as character )

	Local aChave       as array
	Local aIncons      as array
	Local aRules       as array
	Local cBenf        as character
	Local cCabec       as character
	Local cChave       as character 
	Local cCmpsNoUpd   as character
	Local cCodEvent    as character
	Local cEnter       as character
	Local cIdeBenef    as character
	Local cInconMsg    as character 
	Local cItePath     as character 
	Local cLogOpeAnt   as character 
	Local cMensagem    as character 
	Local cPath1207    as character
	Local cPathPerAnt  as character 
	Local cPathPerApu  as character 
	Local cPeriodo     as character 
	Local cT63Path     as character 	
	Local cV9MPath	   as character
	Local lRet         as logical
	Local nIndChv      as numeric
	Local nIndIDVer    as numeric
	Local nlI          as numeric
	Local nlJ          as numeric
	Local nSeqErrGrv   as numeric
	Local nT6O         as numeric
	Local nV6V         as numeric
	Local nV6W         as numeric
	Local nV6X         as numeric
	Local nV6Y         as numeric
	Local nV9M         as numeric
	Local oModel       as object 

	Private lVldModel  := .T. //Caso a chamada seja via integração, seto a variável de controle de validação como .T.
	Private oDados     := Nil

	Default cComplem   := ""
	Default cEmpOriGrp := ""
	Default cFilEv     := ""
	Default cFilOriGrp := ""
	Default cFilTran   := ""
	Default cGrpTran   := ""
	Default cLayout    := ""
	Default cOwner     := ""
	Default cPredeces  := ""
	Default cXmlID     := ""
	Default cEvtOri    := ""
	Default cKey       := "" 
	Default cMatrC9V   := ""
	Default cXml       := ""
	Default nOpc       := 1
	Default nTafRecno  := 0
	Default oXML       := Nil
	Default oTransf    := Nil
	Default lMigrador  := .F.
	Default lDepGPE    := .F. 	 
	Default lLaySmpTot := .F. 
	Default lExclCMJ   := .F. 
		
	aChave       := {}
	aIncons      := {}
	aRules       := {}
	cBenf        := ""
	cCabec       := "/eSocial/evtBenPrRP"
	cChave       := ""
	cCmpsNoUpd   := "|T62_FILIAL|T62_ID|T62_VERSAO|T62_NOMEVE|T62_VERANT|T62_PROTPN|T62_EVENTO|T62_STATUS|T62_ATIVO|"
	cCodEvent    := Posicione( "C8E", 2, xFilial( "C8E" ) + "S-" + cLayout, "C8E->C8E_ID" )
	cEnter       := Chr( 13 ) + Chr( 10 )
	cIdeBenef    := "/ideBenef"
	cInconMsg    := ""
	cItePath     := ""
	cLogOpeAnt   := ""
	cMensagem    := ""
	cPath1207    := "/eSocial/evtBenPrRP"
	cPathPerAnt  := ""
	cPathPerApu  := ""
	cPeriodo     := ""
	cT63Path     := ""	
	cV9MPath	 := ""
	lRet         := .F.
	nIndChv      := 7
	nIndIDVer    := 1
	nlI          := 0
	nlJ          := 0
	nSeqErrGrv   := 0
	nT6O         := 0
	nV6V         := 0
	nV6W         := 0
	nV6X         := 0
	nV6Y         := 0
	nV9M		 := 0
	oModel       := Nil

	// Variável que indica se o ambiente é válido para o eSocial
	If !TafVldAmb("2") .And. !TafColumnPos("T62_IDBEN")

		cMensagem := STR0006 + cEnter // #"Dicionário Incompatível"
		cMensagem += TafAmbInvMsg()

		Aadd(aIncons, cMensagem)

	Else

		oDados := oXML
		
		cPeriodo  := FTafGetVal( cCabec + "/ideEvento/perApur", "C", .F., @aIncons, .F. )
		
		//indApuracao
		Aadd( aChave, {"C", "T62_INDAPU", FTafGetVal( cCabec + "/ideEvento/indApuracao", "C", .F., @aIncons, .F. )  , .T.} ) 
		cChave += Padr( aChave[ 1, 3 ], Tamsx3( aChave[ 1, 2 ])[1])
		
		//perApur
		If At("-", cPeriodo) > 0
			Aadd( aChave, {"C", "T62_PERAPU", StrTran(cPeriodo, "-", "" ),.T.} )
			cChave += Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1])	
		Else
			Aadd( aChave, {"C", "T62_PERAPU", cPeriodo  , .T.} ) 
			cChave += Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1])		
		EndIf
		
		cBenf := FGetIdInt( "cpfBenef", "", cPath1207 + cIdeBenef + "/cpfBenef",,,,@cInconMsg, @nSeqErrGrv,,,,,,,,,cLayout)
		
		If !Empty(cBenf) 
			Aadd( aChave, {"C", "T62_IDBEN", cBenf, .T.})
			cChave += Padr( aChave[ 3, 3 ], Tamsx3( aChave[ 3, 2 ])[1])
		EndIf
		
		//------------------------------------------------------------------
		// Verifico se a operação que o usuário enviou no XML é retificação
		//------------------------------------------------------------------
		If oDados:XPathHasNode( cPath1207 + "/ideEvento/indRetif" )
			If FTafGetVal( cPath1207 + "/ideEvento/indRetif", "C", .F., @aIncons, .F. ) == '2'
				nOpc := 4
			EndIf
		EndIf
		
		Begin Transaction	
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Funcao para validar se a operacao desejada pode ser realizada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If FTafVldOpe( "T62", nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA470", cCmpsNoUpd, nIndIDVer )

				If TafColumnPos( "T62_LOGOPE" )
					cLogOpeAnt := T62->T62_LOGOPE
				EndIf

				oModel:LoadValue( "MODEL_T62", "T62_NOMEVE", "S1207" )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Carrego array com os campos De/Para de gravacao das informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRules := TAF470Rul( cCodEvent, cOwner, cLayout )								                
																																												
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
				//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nOpc <> 5 

					oModel:LoadValue( "MODEL_T62", "T62_FILIAL", T62->T62_FILIAL )															

					If TAFColumnPos( "T62_XMLID" )
						oModel:LoadValue( "MODEL_T62", "T62_XMLID", cXmlID )
					EndIf					

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Rodo o aRules para gravar as informacoes³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nlI := 1 To Len( aRules )
						oModel:LoadValue( "MODEL_T62", aRules[ nlI, 01 ], FTafGetVal( aRules[ nlI, 02 ], aRules[nlI, 03], aRules[nlI, 04], @aIncons, .F. ) )
					Next

					If Findfunction("TAFAltMan")
						if nOpc == 3
							TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T62', 'T62_LOGOPE' , '1', '' )
						elseif nOpc == 4
							TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T62', 'T62_LOGOPE' , '', cLogOpeAnt )
						EndIf
					EndIf

					/*----------------------------------------------------------
								Informações do registro Filho T63
					----------------------------------------------------------*/
					//Deleto todas as linhas do Grid
					nlJ := 1
					cT63Path := cCabec + "/dmDev[" + cValToChar(nlJ)+ "]" 
		
					If nOpc == 4
						For nlJ := 1 to oModel:GetModel( "MODEL_T63" ):Length()
							oModel:GetModel( "MODEL_T63" ):GoLine(nlJ)
							oModel:GetModel( "MODEL_T63" ):DeleteLine()
						Next nlJ
					EndIf				
		
					//Rodo o XML parseado para gravar as novas informacoes no GRID
					nlJ := 1
					While oDados:XPathHasNode(cT63Path)
		
						If nOpc == 4 .or. nlJ > 1
							oModel:GetModel( "MODEL_T63" ):lValid:= .T.
							oModel:GetModel( "MODEL_T63" ):AddLine()
						EndIf
						
						If oDados:XPathHasNode(cT63Path + "/ideDmDev")
							oModel:LoadValue( "MODEL_T63", "T63_DEMPAG", encodeUtf8(FTafGetVal( cT63Path + "/ideDmDev", "C", .F., @aIncons, .F. ) ))
						EndIF

						If oDados:XPathHasNode(cT63Path + "/nrBeneficio")
							oModel:LoadValue( "MODEL_T63", "T63_NUMBEN", FTafGetVal( cT63Path + "/nrBeneficio", "C", .F., @aIncons, .F. ) )
						EndIF					
						
						If lSimplBeta .And. TafColumnPos("T63_INDRRA")					

							If oDados:XPathHasNode(	cT63Path + "/indRRA" )
								cIndRRA := FTafGetVal( cT63Path + "/indRRA", "C", .F., @aIncons, .F. )
								oModel:LoadValue( "MODEL_T63", "T63_INDRRA" , IIF( cIndRRA == "S", "1", "") )
							EndIf
							
							If oDados:XPathHasNode(	cT63Path + "/infoRRA/tpProcRRA" )
								oModel:LoadValue( "MODEL_T63", "T63_TPPRRA" , FTafGetVal( cT63Path + "/infoRRA/tpProcRRA", "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(	cT63Path + "/infoRRA/nrProcRRA" )
								oModel:LoadValue( "MODEL_T63", "T63_NRPRRA" , FTafGetVal( cT63Path + "/infoRRA/nrProcRRA", "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(	cT63Path + "/infoRRA/descRRA"  )
								oModel:LoadValue( "MODEL_T63", "T63_DESCRA" , FTafGetVal( cT63Path + "/infoRRA/descRRA", "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(	cT63Path + "/infoRRA/qtdMesesRRA" )
								oModel:LoadValue( "MODEL_T63", "T63_QTMRRA" , FTafGetVal( cT63Path + "/infoRRA/qtdMesesRRA", "N", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(	cT63Path + "/infoRRA/despProcJud/vlrDespCustas" )
								oModel:LoadValue( "MODEL_T63", "T63_VLRCUS" , FTafGetVal( cT63Path + "/infoRRA/despProcJud/vlrDespCustas", "N", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode(	cT63Path + "/infoRRA/despProcJud/ vlrDespAdvogados" )
								oModel:LoadValue( "MODEL_T63", "T63_VLRADV" , FTafGetVal( cT63Path + "/infoRRA/despProcJud/vlrDespAdvogados", "N", .F., @aIncons, .F. ) )
							EndIf

							/*---------------------------------------
							V9M - Identificação dos advogados
							----------------------------------------*/							
							nV9M:= 1
							cV9MPath := cT63Path + "/infoRRA/ideAdv[" + CVALTOCHAR(nV9M) + "]"

							If nOpc == 4
								For nV9M := 1 to oModel:GetModel( "MODEL_V9M" ):Length()
									oModel:GetModel( "MODEL_V9M" ):GoLine(nV9M)
									oModel:GetModel( "MODEL_V9M" ):DeleteLine()
								Next nV9M
							EndIf	

							nV9M:= 1
							While oDados:XPathHasNode(cV9MPath)

								oModel:GetModel("MODEL_V9M"):lValid:= .T.
								
								If nOpc == 4 .Or. nV9M > 1
									oModel:GetModel("MODEL_V9M"):AddLine()
								EndIf

								If oDados:XPathHasNode(	cV9MPath + "/tpInsc")
									oModel:LoadValue( "MODEL_V9M", "V9M_TPINSC"	, FTafGetVal( cV9MPath + "/tpInsc", "C", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode(	cV9MPath + "/nrInsc")
									oModel:LoadValue( "MODEL_V9M", "V9M_NRINSC"	, FTafGetVal( cV9MPath + "/nrInsc", "C", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode(	cV9MPath + "/vlrAdv")
									oModel:LoadValue( "MODEL_V9M", "V9M_VLRADV"	, FTafGetVal( cV9MPath + "/vlrAdv", "N", .F., @aIncons, .F. ) )
								EndIf

								nV9M++
								cV9MPath := cT63Path + "/infoRRA/ideAdv[" + CVALTOCHAR(nV9M) + "]"

							EndDo

						EndIf

						nV6V := 1
						cPathPerApu	:= cT63Path + "/infoPerApur/ideEstab[" + cValToChar(nV6V) +"]"
						While oDados:XPathHasNode(cPathPerApu)

							If XVldTNrIns("1", FTafGetVal( cPathPerApu + "/nrInsc", "C", .F., @aIncons, .F. ), .T.)

								oModel:GetModel("MODEL_V6V"):lValid:= .T.

								If nV6V > 1								
									oModel:GetModel("MODEL_V6V"):AddLine()

								EndIf						

								//ideEstab
								If oDados:XPathHasNode(cPathPerApu + "/tpInsc")	
									oModel:LoadValue( "MODEL_V6V", "V6V_TPINSC", FTafGetVal( cPathPerApu + "/tpInsc", "C", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode(cPathPerApu + "/nrInsc")	
									oModel:LoadValue( "MODEL_V6V", "V6V_NRINSC", FTafGetVal( cPathPerApu + "/nrInsc", "C", .F., @aIncons, .F. ) )
								EndIf
								
								nT6O := 1
								cItePath	:=	cPathPerApu + "/itensRemun[" + cValToChar(nT6O) + "]"

								If nOpc == 4
									For nT6O := 1 to oModel:GetModel( "MODEL_T6O" ):Length()
										oModel:GetModel( "MODEL_T6O" ):GoLine(nT6O)
										oModel:GetModel( "MODEL_T6O" ):DeleteLine()
									Next nT6O
								EndIf

								nT6O := 1
								While oDados:XPathHasNode(cItePath)

									If nOpc == 4 .OR. nT6O > 1
										oModel:GetModel("MODEL_T6O"):lValid:= .T.
										oModel:GetModel( "MODEL_T6O" ):AddLine()
									EndIf

									If oDados:XPathHasNode(	cItePath + "/ideTabRubr")
										cIdTabR := TAFIdTabRub( FTafGetVal( cItePath + "/ideTabRubr", "C", .F., @aIncons, .F. ) )
									Else
										cIdTabR := ""
									EndIf

									//itensRemun
									If oDados:XPathHasNode(cItePath + "/codRubr")
										oModel:LoadValue( "MODEL_T6O", "T6O_IDRUBR", FGetIdInt( "codRubr","ideTabRubr", FTafGetVal( cItePath + "/codRubr", "C", .F., @aIncons, .F. ), cIdTabR,.F.,,@cInconMsg, @nSeqErrGrv,/*9*/,/*10*/,/*11*/,/*12*/,/*13*/,StrTran(cPeriodo,"-","")))
									EndIf

									If oDados:XPathHasNode(cItePath + "/ideTabRubr")	
										oModel:LoadValue( "MODEL_T6O", "T6O_TABRUB", FTafGetVal( cItePath + "/ideTabRubr", "C", .F., @aIncons, .F. ) )
									EndIf

									If oDados:XPathHasNode(cItePath + "/qtdRubr")	
										oModel:LoadValue( "MODEL_T6O", "T6O_QTDRUB", FTafGetVal( cItePath + "/qtdRubr", "N", .F., @aIncons, .F. ) )
									EndIf

									If oDados:XPathHasNode(cItePath + "/fatorRubr")
										oModel:LoadValue( "MODEL_T6O", "T6O_FATRUB", FTafGetVal( cItePath + "/fatorRubr", "N", .F., @aIncons, .F. ) )
									EndIf

									If oDados:XPathHasNode(cItePath + "/vrRubr")	
										oModel:LoadValue( "MODEL_T6O", "T6O_VLRRUB", FTafGetVal( cItePath + "/vrRubr", "N", .F., @aIncons, .F. ) )
									EndIf

									If oDados:XPathHasNode(cItePath + "/indApurIR")	
										oModel:LoadValue( "MODEL_T6O", "T6O_APUIR", FTafGetVal( cItePath + "/indApurIR", "C", .F., @aIncons, .F. ) )
									EndIf

									nT6O ++
									cItePath := cPathPerApu + "/itensRemun[" + cValToChar(nT6O) + "]"

								EndDo

							EndIf

							nV6V ++
							cPathPerApu	:= cT63Path + "/infoPerApur/ideEstab[" + cValToChar(nV6V) +"]"

						EndDo						

						nV6W := 1
						cPathPerAnt	:= cT63Path + "/infoPerAnt/idePeriodo[" + cValToChar(nV6W) +"]"

						If nOpc == 4
							For nV6W := 1 to oModel:GetModel( "MODEL_V6W" ):Length()
									oModel:GetModel( "MODEL_V6W" ):GoLine(nV6W)
									oModel:GetModel( "MODEL_V6W" ):DeleteLine()
							Next nV6W
						EndIf

						nV6W := 1
						While oDados:XPathHasNode(cPathPerAnt)

							If nOpc == 4 .OR. nV6W > 1
								oModel:GetModel("MODEL_V6W"):lValid:= .T.
								oModel:GetModel("MODEL_V6W"):AddLine()
							EndIf

							//idePeriodo
							If oDados:XPathHasNode(cPathPerAnt + "/perRef")	
								oModel:LoadValue( "MODEL_V6W", "V6W_PERREF", StrTran(FTafGetVal( cPathPerAnt + "/perRef", "C", .F., @aIncons, .F. ),"-","" ))
							EndIf						

							nV6X := 1
							cIdePath	:=	cPathPerAnt + "/ideEstab[" + cValToChar(nV6X) + "]"

							If nOpc == 4
								For nV6X := 1 to oModel:GetModel( "MODEL_V6X" ):Length()
									oModel:GetModel( "MODEL_V6X" ):GoLine(nV6X)
									oModel:GetModel( "MODEL_V6X" ):DeleteLine()
								Next nV6X
							EndIf

							nV6X := 1
							While oDados:XPathHasNode(cIdePath)

								If XVldTNrIns("1", FTafGetVal( cIdePath + "/nrInsc", "C", .F., @aIncons, .F. ), .T.)

									If nOpc == 4 .OR. nV6X > 1
										oModel:GetModel("MODEL_V6X"):lValid:= .T.
										oModel:GetModel("MODEL_V6X"):AddLine()
									EndIf

									//ideEstab
									If oDados:XPathHasNode(cIdePath + "/tpInsc")	
										oModel:LoadValue( "MODEL_V6X", "V6X_TPINSC", FTafGetVal( cIdePath + "/tpInsc", "C", .F., @aIncons, .F. ) )
									EndIf

									If oDados:XPathHasNode(cIdePath + "/nrInsc")	
										oModel:LoadValue( "MODEL_V6X", "V6X_NRINSC", FTafGetVal( cIdePath + "/nrInsc", "C", .F., @aIncons, .F. ) )
									EndIf								
									
									nV6Y := 1
									cIteRemun	:=	cIdePath + "/itensRemun[" + cValToChar(nV6Y) + "]"

									If nOpc == 4
										For nV6Y := 1 to oModel:GetModel( "MODEL_V6Y" ):Length()
											oModel:GetModel( "MODEL_V6Y" ):GoLine(nV6Y)
											oModel:GetModel( "MODEL_V6Y" ):DeleteLine()
										Next nV6Y
									EndIf	
									
									nV6Y := 1
									While oDados:XPathHasNode(cIteRemun)

										If nOpc == 4 .OR. nV6Y > 1
											oModel:GetModel("MODEL_V6Y"):lValid:= .T.
											oModel:GetModel( "MODEL_V6Y" ):AddLine()
										EndIf

										If oDados:XPathHasNode(	cIteRemun + "/ideTabRubr")
											cIdTabR := TAFIdTabRub( FTafGetVal( cIteRemun + "/ideTabRubr", "C", .F., @aIncons, .F. ) )
										Else
											cIdTabR := ""
										EndIf

										//itensRemun
										If oDados:XPathHasNode(cIteRemun + "/codRubr")
											oModel:LoadValue( "MODEL_V6Y", "V6Y_CODRUB", FGetIdInt( "codRubr","ideTabRubr", FTafGetVal( cIteRemun + "/codRubr", "C", .F., @aIncons, .F. ), cIdTabR,.F.,,@cInconMsg, @nSeqErrGrv,/*9*/,/*10*/,/*11*/,/*12*/,/*13*/,StrTran(cPeriodo,"-","")))
										EndIf

										If oDados:XPathHasNode(cIteRemun + "/ideTabRubr")	
											oModel:LoadValue( "MODEL_V6Y", "V6Y_TABRUB", FTafGetVal( cIteRemun + "/ideTabRubr", "C", .F., @aIncons, .F. ) )
										EndIf

										If oDados:XPathHasNode(cIteRemun + "/qtdRubr")	
											oModel:LoadValue( "MODEL_V6Y", "V6Y_QTDRUB", FTafGetVal( cIteRemun + "/qtdRubr", "N", .F., @aIncons, .F. ) )
										EndIf

										If oDados:XPathHasNode(cIteRemun + "/fatorRubr")	
											oModel:LoadValue( "MODEL_V6Y", "V6Y_FATRUB", FTafGetVal( cIteRemun + "/fatorRubr", "N", .F., @aIncons, .F. ) )
										EndIf

										If oDados:XPathHasNode(cIteRemun + "/vrRubr")	
											oModel:LoadValue( "MODEL_V6Y", "V6Y_VRRUBR", FTafGetVal( cIteRemun + "/vrRubr", "N", .F., @aIncons, .F. ) )
										EndIf

										If oDados:XPathHasNode(cIteRemun + "/indApurIR")	
											oModel:LoadValue( "MODEL_V6Y", "V6Y_APURIR", FTafGetVal( cIteRemun + "/indApurIR", "C", .F., @aIncons, .F. ) )
										EndIf

										nV6Y ++
										cIteRemun := cIdePath + "/itensRemun[" + cValToChar(nV6Y) + "]"
									
									EndDo

								EndIf
								
								nV6X ++
								cIdePath := cPathPerAnt + "/ideEstab[" + cValToChar(nV6X) + "]"
							
							EndDo

							nV6W ++
							cPathPerAnt	:= cT63Path + "/infoPerAnt/idePeriodo[" + cValToChar(nV6W) +"]"

						EndDo			
												
						/*----------------------------------------------------------
								Informações do registro Filho T6O
						----------------------------------------------------------*/							
						nlJ ++
						cT63Path := cCabec + "/dmDev[" + cValToChar(nlJ)+ "]" 

					EndDo
								
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Efetiva a operacao desejada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Empty(cInconMsg) .And. Empty(aIncons)
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
																				
		End Transaction  	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Zerando os arrays e os Objetos utilizados no processamento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aSize( aRules, 0 ) 
		aRules     := Nil
		
		aSize( aChave, 0 ) 
		aChave     := Nil    	

	EndIf

Return { lRet, aIncons } 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF470Rul           
Regras para gravacao das informacoes do registro S-1207 do E-Social

@Param
nOper      - Operacao a ser realizada ( 3 = Inclusao / 4 = Alteracao / 5 = Exclusao )

@Return	
aRull  - Regras para a gravacao das informacoes


@author rodrigo.nicolino
@since 26/01/2022
@version 1.0
/*/                        	
//-------------------------------------------------------------------
Static Function TAF470Rul( cCodEvent, cOwner, cLayout )
                             
	Local aRull       := {}
	Local cCabec      := "/eSocial/evtBenPrRP"
	Local cPeriodo    := ""

	Default cCodEvent := ""
	Default cOwner    := ""

	//-- ideBenef
	If TafXNode( oDados, cCodEvent, cOwner,( cCabec + "/ideEvento/indApuracao" ) )
		Aadd( aRull, {"T62_INDAPU", cCabec + "/ideEvento/indApuracao","C",.F.} ) 	 	    
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,( cCabec + "/ideEvento/perApur" ) )
		cPeriodo	:= FTafGetVal( cCabec + "/ideEvento/perApur", "C", .F.,, .F. )

		If At("-", cPeriodo) > 0
			Aadd( aRull, {"T62_PERAPU", StrTran(cPeriodo, "-", "" ) ,"C",.T.} )	
		Else
			Aadd( aRull, {"T62_PERAPU", cPeriodo ,"C", .T.} )		
		EndIf     
	EndIf 

	If TafXNode( oDados, cCodEvent, cOwner,( cCabec + "/ideBenef/cpfBenef" ) )
		cBenf := FGetIdInt( "cpfBenef", "", cCabec + "/ideBenef/cpfBenef",,,,,,,,,,,,,,cLayout)
		aAdd( aRull, { "T62_IDBEN", cBenf, "C", .T. } ) //cpfBenef
		aAdd( aRull, { "T62_CPF", cCabec + "/ideBenef/cpfBenef", "C", .F. } ) //cpfBenef
	EndIf
                    
Return ( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF470Xml
Funcao de geracao do XML para atender o registro S-1207
Quando a rotina for chamada o registro deve estar posicionado

@Param:
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@Return:
cXml - Estrutura do Xml do Layout S-1000

@author denis.oliveira
@since 13/03/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF470Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

	Local aMensal    	as array
	Local cAnte      	as character
	Local cLayout    	as character
	Local cReg       	as character
	Local cRemun     	as character
	Local cXml       	as character
	Local cIndRRA		as character
	Local cXmlProcJud	as character
	Local cXmlIdeAdv	as character	
	Local lXmlVLd    	as logical
	Local lRubERPPad 	as logical
	Local lV9M			as logical
	Local nMVIDETABR 	as numeric
	
	Default cAlias   := ""
	Default cSeqXml  := ""
	Default lJob     := .F.
	Default nOpc     := 1
	Default nRecno   := 0

	aMensal    	:= {}
	cAnte      	:= ""
	cLayout    	:= "1207"
	cReg       	:= "BenPrRP"
	cRemun     	:= ""
	cXml       	:= ""
	cXmlProcJud	:= ""
	cXmlIdeAdv	:= ""
	cIndRRA		:= ""	
	lXmlVLd    	:= IIF(FindFunction( 'TafXmlVLD' ),TafXmlVLD( 'TAF470XML' ),.T.)
	lRubERPPad 	:= .T.
	lV9M		:= .T.
	nMVIDETABR 	:= SuperGetMV("MV_IDETABR",.F.,"0")

	//-- Abro as tabelas
	dbSelectArea("T5T")
	T5T->( DBSetOrder(1) )

	dbSelectArea("T5G")
	T5G->( DBSetOrder(1) )

	dbSelectArea("C8R")
	C8R->( DBSetOrder(1) )

	If lXmlVLd
		If  IsInCallStack("TAFA470") .AND. (IsInCalLStack("TAFXmlLote") .OR. IsInCallStack("TAF470Xml")) //Execução Manual
			If slRubERPPad == Nil
				lRubERPPad := nMVIDETABR == "1" .OR. (nMVIDETABR == "0" .and. ApMsgYesNo(STR0025 + CRLF + STR0026 + CRLF + STR0027, STR0028)) //"Deseja gerar o conteúdo da tag 'ideTabRubr' com o código padrão deste ERP ou conforme ERP de Origem?" , " - Sim para código padrão (T3M_ID)." , " - Não para conforme ERP de Origem (T3M_CODERP)." , "Conteúdo 'ideTabRubr' padrão?"
				If IsInCalLStack("TAFXmlLote")
					slRubERPPad	:= lRubERPPad
				EndIf
			Else
				lRubERPPad	:= slRubERPPad
			EndIf

		EndIf

		//*******************
		//-- ideBenef
		//*******************
		cXml +=			"<ideBenef>"
		cXml +=				xTafTag("cpfBenef"	,T62->T62_CPF)
		cXml +=			"</ideBenef>"

		//*******************
		//-- dmDev
		//*******************
		T63->( DBSetOrder( 4 ) )
		If T63->(MsSeek(xFilial("T63") + T62->(T62_ID + T62_VERSAO + T62_INDAPU + T62_PERAPU + T62_IDBEN)))

			While !T63->(Eof()) .And. AllTrim(T63->(T63_ID + T63_VERSAO + T63_INDAPU + T63_PERAPU + T63_IDBEN)) == AllTrim(T62->(T62_ID + T62_VERSAO + T62_INDAPU + T62_PERAPU + T62_IDBEN))
			
				cXml +=		"<dmDev>"
				
				cXml +=		encodeUtf8( xTafTag("ideDmDev",				T63->T63_DEMPAG,,.F.) )
				cXml += 	xTafTag("nrBeneficio", 			T63->T63_NUMBEN,,.F.)                                                                	                                               
				
				If lSimplBeta .And. TafColumnPos("T63_INDRRA") 							
					V9M->( DBSetOrder( 1 ) )

					lV9M 	    := .T.
					cXmlIdeAdv  := ""
					cXmlProcJud := ""

					cIndRRA := IIF( T63->T63_INDRRA=="1", "S", "" )
					
					cXml += xTafTag("indRRA", cIndRRA,, .T.)

					If cIndRRA == "S"

						If __cPicVAdv == Nil
							__cPicVAdv := PesqPict("T63", "T63_VLRADV")
							__cPicVCus := PesqPict("T63", "T63_VLRCUS")
							__cPicQRRA := PesqPict("T63", "T63_QTMRRA")									
						EndIf
						
						xTafTagGroup("despProcJud";	
							,{{"vlrDespCustas"		, T63->T63_VLRCUS, __cPicVCus, .F.};
							, {"vlrDespAdvogados"	, T63->T63_VLRADV, __cPicVAdv, .F.}};						
							, @cXmlProcJud)
						
						If V9M->(MsSeek(xFilial("V9M") + T63->(T63_ID + T63_VERSAO + T63_INDAPU + T63_PERAPU + T63_IDBEN + T63_DEMPAG))) 

							While lV9M
								
								xTafTagGroup("ideAdv";	
									,{{"tpInsc"	, V9M->V9M_TPINSC,			  , .F.};
									, {"nrInsc"	, V9M->V9M_NRINSC,			  , .F.};
									, {"vlrAdv"	, V9M->V9M_VLRADV, __cPicVAdv , .T.}};						
									, @cXmlIdeAdv)
								
								V9M->(DbSkip())
								lV9M := !V9M->(Eof()) .And. AllTrim(V9M->(V9M_ID + V9M_VERSAO + V9M_INDAPU + V9M_PERAPU + V9M_IDBEN + V9M_DEMPAG)) == AllTrim(T63->(T63_ID + T63_VERSAO + T63_INDAPU + T63_PERAPU + T63_IDBEN + T63_DEMPAG))
							
							EndDo

						EndIf
						
						xTafTagGroup("infoRRA";	
							,{{"tpProcRRA"		,T63->T63_TPPRRA ,			 , .F.};
							, {"nrProcRRA"		,T63->T63_NRPRRA ,			 , .T.};
							, {"descRRA"		,T63->T63_DESCRA ,			 , .F.};
							, {"qtdMesesRRA"	,T63->T63_QTMRRA , __cPicQRRA, .F.}};									
							, @cXml;
							, { { "despProcJud" , cXmlProcJud	 , 0 } ;
							, { "ideAdv"		, cXmlIdeAdv	 , 0 } },, .T.)

					EndIf

				EndIf

				V6V->( DBSetOrder( 2 ) )
				If V6V->(MsSeek(xFilial("V6V") + T63->(T63_ID + T63_VERSAO + T63_INDAPU + T63_PERAPU + T63_IDBEN + T63_DEMPAG))) 

					cXml +=		"<infoPerApur>"

					While !V6V->(EoF()) .And. AllTrim(V6V->(V6V_ID + V6V_VERSAO + V6V_INDAPU + V6V_PERAPU + V6V_IDBEN + V6V_DEMPAG)) == AllTrim(T63->(T63_ID + T63_VERSAO + T63_INDAPU + T63_PERAPU + T63_IDBEN + T63_DEMPAG))
						
						cRemun:= ""

						cXml +=			"<ideEstab>"
						cXml +=				xTafTag("tpInsc", 		V6V->V6V_TPINSC,,.F.)
						cXml +=				xTafTag("nrInsc", 		V6V->V6V_NRINSC,,.F.)


						T6O->( DBSetOrder( 2 ) )
						If T6O->(MsSeek(xFilial("T6O") + V6V->(V6V_ID + V6V_VERSAO + V6V_INDAPU + V6V_PERAPU + V6V_IDBEN + V6V_DEMPAG + V6V_TPINSC + V6V_NRINSC)))

							While !T6O->(EoF()) .And. AllTrim(T6O->(T6O_ID + T6O_VERSAO + T6O_INDAPU + T6O_PERAPU + T6O_IDBEN + T6O_DEMPAG + T6O_TPINSC + T6O_NRINSC)) == AllTrim(V6V->(V6V_ID + V6V_VERSAO + V6V_INDAPU + V6V_PERAPU + V6V_IDBEN + V6V_DEMPAG + V6V_TPINSC + V6V_NRINSC))
				
								xTafTagGroup("itensRemun";
											,{{ "codRubr",		Posicione("C8R",5,xFilial("C8R")+T6O->T6O_IDRUBR+"1","C8R_CODRUB"),,.F.};
											, { "ideTabRubr",	Posicione("T3M",1,xFilial("T3M") + C8R->C8R_IDTBRU, Iif(lRubERPPad, "T3M_ID","T3M_CODERP")),,.F. };
											, {	"qtdRubr",		T6O->T6O_QTDRUB                                  		,PesqPict("T6O","T6O_QTDRUB"),.T. };
											, {	"fatorRubr",	T6O->T6O_FATRUB											,PesqPict("T6O","T6O_FATRUB"),.T. };
											, {	"vrRubr",		T6O->T6O_VLRRUB											,PesqPict("T6O","T6O_VLRRUB"),.F. };
											, {	"indApurIR",	T6O->T6O_APUIR											,,.F. }};
											,@cRemun																	,,.F.)

								T6O->( dbSkip() )

							EndDo

						EndIf

						cXml += cRemun
						cXml +=			"</ideEstab>"

						V6V->( dbSkip() )	

					EndDo
					
					cXml +=		"</infoPerApur>"

				EndIf

				V6W->( DBSetOrder( 2 ) )                                                                                     

				If V6W->(MsSeek(xFilial("V6W") + T63->(T63_ID + T63_VERSAO + T63_INDAPU + T63_PERAPU + T63_IDBEN + T63_DEMPAG)))

					cXml +=		"<infoPerAnt>"

					While !V6W->(EoF()) .And. AllTrim(V6W->(V6W_ID + V6W_VERSAO + V6W_INDAPU + V6W_PERAPU + V6W_IDBEN + V6W_DEMPAG)) == AllTrim(T63->(T63_ID + T63_VERSAO + T63_INDAPU + T63_PERAPU + T63_IDBEN + T63_DEMPAG))

						cXml +=			"<idePeriodo>"
						cXml +=				xTafTag("perRef", 		AllTrim(Transform(V6W->V6W_PERREF, '@R 9999-99')))                                                                      

						V6X->( DBSetOrder( 2 ) )
						If V6X->(MsSeek(xFilial("V6X") + V6W->(V6W_ID + V6W_VERSAO + V6W_INDAPU + V6W_PERAPU + V6W_IDBEN + V6W_DEMPAG + V6W_PERREF) ))

							While !V6X->(EoF()) .And. AllTrim(V6X->(V6X_ID + V6X_VERSAO + V6X_INDAPU + V6X_PERAPU + V6X_IDBEN + V6X_DEMPAG + V6X_PERREF)) == AllTrim(V6W->(V6W_ID + V6W_VERSAO + V6W_INDAPU + V6W_PERAPU + V6W_IDBEN + V6W_DEMPAG + V6W_PERREF))

								cAnte:= ""
								cXml +=			"<ideEstab>"
								cXml +=				xTafTag("tpInsc",  		V6X->V6X_TPINSC,,.F.)
								cXml +=				xTafTag("nrInsc",  		V6X->V6X_NRINSC,,.F.)
                                                    

								V6Y->( DBSetOrder( 2 ) )
								If V6Y->(MsSeek(xFilial("V6Y") + V6X->(V6X_ID + V6X_VERSAO + V6X_INDAPU + V6X_PERAPU + V6X_IDBEN + V6X_DEMPAG + V6X_PERREF + V6X_TPINSC + V6X_NRINSC)))

									While !V6Y->(EoF()) .And. AllTrim(V6Y->(V6Y_ID + V6Y_VERSAO + V6Y_INDAPU + V6Y_PERAPU + V6Y_IDBEN + V6Y_DEMPAG + V6Y_PERREF + V6Y_TPINSC + V6Y_NRINSC)) == AllTrim(V6X->(V6X_ID + V6X_VERSAO + V6X_INDAPU + V6X_PERAPU + V6X_IDBEN + V6X_DEMPAG + V6X_PERREF + V6X_TPINSC + V6X_NRINSC))
				
										xTafTagGroup("itensRemun";
													,{{ "codRubr",		Posicione("C8R",5,xFilial("C8R")+V6Y->V6Y_CODRUB+"1","C8R_CODRUB"),,.F.};
													, { "ideTabRubr",	Posicione("T3M",1,xFilial("T3M") + C8R->C8R_IDTBRU, Iif(lRubERPPad, "T3M_ID","T3M_CODERP")),,.F. };
													, {	"qtdRubr",		V6Y->V6Y_QTDRUB                                 		,PesqPict("V6Y","V6Y_QTDRUB"),.T. };
													, {	"fatorRubr",	V6Y->V6Y_FATRUB 										,PesqPict("V6Y","V6Y_FATRUB"),.T. };
													, {	"vrRubr",		V6Y->V6Y_VRRUBR											,PesqPict("V6Y","V6Y_VRRUBR"),.F. };
													, {	"indApurIR",	V6Y->V6Y_APURIR											,,.F. }};
													,@cAnte																		,,.F.)

										V6Y->( dbSkip() )

									EndDo

								EndIf

								cXml += cAnte
								cXml +=			"</ideEstab>"								

								V6X->( dbSkip() )

							EndDo

						EndIf

						cXml += 		"</idePeriodo>"

						V6W->( dbSkip() )	

					EndDo

					cXml +=		"</infoPerAnt>"					

				EndIf

				cXml +=		"</dmDev>"
				
				T63->( dbSkip() )

			EndDo
			
		EndIf	

		//-- Gravo no array o indicativo e o período de apuração
		If T62->T62_INDAPU == '1' //Mensal	 

			aAdd(aMensal,T62->T62_INDAPU) 
			aAdd(aMensal,Substr(T62->T62_PERAPU, 1, 4) + '-' + Substr(T62->T62_PERAPU, 5, 2) )

		ElseIf T62->T62_INDAPU == '2' //Anual	
			
			aAdd(aMensal,T62->T62_INDAPU)  
			aAdd(aMensal,Alltrim(T62->T62_PERAPU))

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estrutura do cabecalho³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cXml := xTafCabXml(cXml,"T62", cLayout, cReg, aMensal,cSeqXml)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa gravacao do registro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lJob
			xTafGerXml(cXml,cLayout)
		EndIf
	EndIf

Return(cXml)

//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera o evento de exclusão do evento

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function é chamada pelo TafIntegraESocial

@Return .T.

@Author rodrigo.nicolino
@Since 26/01/2022
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc  )

	Local aGravaT62  as array
	Local aGravaT63  as array
	Local aGravaT6O  as array
	Local aGravaV6V  as array
	Local aGravaV6W  as array
	Local aGravaV6X  as array
	Local aGravaV6Y  as array
	Local aGravaV9M  as array
	Local cEvento    as character
	Local cProtocolo as character
	Local cVerAnt    as character
	Local cVersao    as character
	Local nlI        as numeric
	Local nlY        as numeric
	Local nT62       as numeric
	Local nT63       as numeric
	Local nT6O       as numeric
	Local nV6V       as numeric
	Local nV6W       as numeric
	Local nV6X       as numeric
	Local nV6Y       as numeric
	Local nV9M       as numeric
	Local oModelT62  as object
	Local oModelT63  as object
	Local oModelT6O  as object
	Local oModelV6V  as object
	Local oModelV6W  as object
	Local oModelV6X  as object
	Local oModelV6Y  as object
	Local oModelV9M  as object

	Default lRotExc  := Nil
	Default nRecno   := Nil
	Default oModel   := Nil

	aGravaT62  := {}
	aGravaT63  := {}
	aGravaT6O  := {}
	aGravaV6V  := {}
	aGravaV6W  := {}
	aGravaV6X  := {}
	aGravaV6Y  := {}
	aGravaV9M  := {}
	cEvento    := ""
	cProtocolo := ""
	cVerAnt    := ""
	cVersao    := ""
	nlI        := 0
	nlY        := 0
	nT62       := 0
	nT63       := 0
	nT6O       := 0
	nV6V       := 0
	nV6W       := 0
	nV6X       := 0
	nV6Y       := 0
	nV9M       := 0
	oModelT62  := Nil
	oModelT63  := Nil
	oModelT6O  := Nil
	oModelV6V  := Nil
	oModelV6W  := Nil
	oModelV6X  := Nil
	oModelV6Y  := Nil
	oModelV9M  := Nil

	Begin Transaction

		//Posiciona o item
		("T62")->( DBGoTo( nRecno ) )
				
		//Carrego a Estrutura dos Models a serem gravados
		oModelT62	:= oModel:GetModel( 'MODEL_T62' ) 
		oModelT63	:= oModel:GetModel( 'MODEL_T63' ) 
		oModelT6O	:= oModel:GetModel( 'MODEL_T6O' ) 
		oModelV6V	:= oModel:GetModel( 'MODEL_V6V' ) 
		oModelV6W	:= oModel:GetModel( 'MODEL_V6W' ) 
		oModelV6X	:= oModel:GetModel( 'MODEL_V6X' ) 
		oModelV6Y	:= oModel:GetModel( 'MODEL_V6Y' )

		If lSimplBeta .And. TafColumnPos("T63_INDRRA")
			oModelV9M	:= oModel:GetModel( 'MODEL_V9M' )
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco a versao anterior do registro para gravacao do rastro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVerAnt	:= oModelT62:GetValue( "T62_VERSAO" )				
		cProtocolo	:= oModelT62:GetValue( "T62_PROTUL" )				
		cEvento	:= oModelT62:GetValue( "T62_EVENTO" )	
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Neste momento eu gravo as informacoes que foram carregadas       ³
		//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
		//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
		//³nao devem ser consideradas neste momento                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nlI := 1 To 1
			For nlY := 1 To Len( oModelT62:aDataModel[ nlI ] )			
				Aadd( aGravaT62, { oModelT62:aDataModel[ nlI, nlY, 1 ], oModelT62:aDataModel[ nlI, nlY, 2 ] } )									
			Next
		Next	       						
					
		If !oModel:GetModel( 'MODEL_T63' ):IsEmpty()

			For nT63 := 1 To oModel:GetModel( 'MODEL_T63' ):Length()

				oModel:GetModel( 'MODEL_T63' ):Goline(nT63) 
				
				If !oModel:GetModel( 'MODEL_T63' ):IsDeleted()

					If lSimplBeta .And. TafColumnPos("T63_INDRRA")

						aAdd(aGravaT63, { oModelT62:GetValue('T62_INDAPU') + oModelT62:GetValue('T62_PERAPU') + oModelT62:GetValue('T62_CPF'),;												
										oModelT63:GetValue('T63_DEMPAG'),;
										oModelT63:GetValue('T63_NUMBEN'),;
										oModelT63:GetValue('T63_INDRRA'),;
										oModelT63:GetValue('T63_TPPRRA'),;
										oModelT63:GetValue('T63_NRPRRA'),;
										oModelT63:GetValue('T63_DESCRA'),;
										oModelT63:GetValue('T63_QTMRRA'),;
										oModelT63:GetValue('T63_VLRCUS'),;
										oModelT63:GetValue('T63_VLRADV')})

						/*------------------------------------------
							V9M - Informações de Valores Pagos
						--------------------------------------------*/
						For nV9M := 1 to oModel:GetModel( "MODEL_V9M" ):Length()

							oModel:GetModel( "MODEL_V9M" ):GoLine(nV9M)

							If !oModel:GetModel( 'MODEL_V9M' ):IsEmpty()

								If !oModel:GetModel( "MODEL_V9M" ):IsDeleted()

									aAdd (aGravaV9M ,{  oModelT62:GetValue('T62_INDAPU') + oModelT62:GetValue('T62_PERAPU') + oModelT63:GetValue('T63_DEMPAG'),;
														oModelV9M:GetValue('V9M_TPINSC'),;
														oModelV9M:GetValue('V9M_NRINSC'),;
														oModelV9M:GetValue('V9M_VLRADV')})
								EndIf

							EndIf

						Next //nV9M	

					Else
						aAdd(aGravaT63,{	oModelT62:GetValue('T62_INDAPU') + oModelT62:GetValue('T62_PERAPU') + oModelT62:GetValue('T62_CPF'),;
											oModelT63:GetValue('T63_DEMPAG'),;
											oModelT63:GetValue('T63_NUMBEN')})
					EndIf

					If !oModel:GetModel( 'MODEL_V6V' ):IsEmpty()

						For nV6V := 1 To oModel:GetModel( 'MODEL_V6V' ):Length()

							oModel:GetModel( 'MODEL_V6V' ):GoLine(nV6V)

							If !oModel:GetModel( 'MODEL_V6V' ):IsDeleted()

								aAdd(aGravaV6V,{	oModelT62:GetValue('T62_INDAPU') + oModelT62:GetValue('T62_PERAPU') + oModelT63:GetValue('T63_DEMPAG'),;
													oModelV6V:GetValue('V6V_TPINSC'),;
													oModelV6V:GetValue('V6V_NRINSC')})

								If !oModel:GetModel( 'MODEL_T6O' ):IsEmpty()

									For nT6O := 1 To oModel:GetModel( 'MODEL_T6O' ):Length() 

										oModel:GetModel( 'MODEL_T6O' ):GoLine(nT6O)

										If !oModel:GetModel( 'MODEL_T6O' ):IsDeleted()

											aAdd(aGravaT6O,{	oModelT62:GetValue('T62_INDAPU') + oModelT62:GetValue('T62_PERAPU') + oModelT63:GetValue('T63_DEMPAG') + oModelV6V:GetValue('V6V_TPINSC') + oModelV6V:GetValue('V6V_NRINSC'),;
																oModelT6O:GetValue('T6O_IDRUBR'),; 
																oModelT6O:GetValue('T6O_DRUBR '),; 
										                		oModelT6O:GetValue('T6O_VLRRUB'),; 
										                		oModelT6O:GetValue('T6O_TABRUB'),; 
										                		oModelT6O:GetValue('T6O_QTDRUB'),; 
										                		oModelT6O:GetValue('T6O_FATRUB'),; 
										                		oModelT6O:GetValue('T6O_APUIR')})
										
										EndIf

									Next// FIM - T6O
								EndIf		

							EndIf

						Next// FIM V6V

					EndIf

					If !oModel:GetModel( 'MODEL_V6W' ):IsEmpty()

						For nV6W := 1 To oModel:GetModel( 'MODEL_V6W' ):Length()

							oModel:GetModel( 'MODEL_V6W' ):GoLine(nV6W)
											
							If !oModel:GetModel( 'MODEL_V6W' ):IsDeleted()

								aAdd(aGravaV6W,{	oModelT62:GetValue('T62_INDAPU') + oModelT62:GetValue('T62_PERAPU') + oModelT63:GetValue('T63_DEMPAG'),;																
													oModelV6W:GetValue('V6W_PERREF')})

								If !oModel:GetModel( 'MODEL_V6X' ):IsEmpty()

									For nV6X := 1 To oModel:GetModel( 'MODEL_V6X' ):Length()

										oModel:GetModel( 'MODEL_V6X' ):GoLine(nV6X)

										If !oModel:GetModel( 'MODEL_V6X' ):IsDeleted()

											aAdd(aGravaV6X,{	oModelT62:GetValue('T62_INDAPU') + oModelT62:GetValue('T62_PERAPU') + oModelT63:GetValue('T63_DEMPAG') + oModelV6W:GetValue('V6W_PERREF'),;
																oModelV6X:GetValue('V6X_TPINSC'),;
																oModelV6X:GetValue('V6X_NRINSC')})

											If !oModel:GetModel( 'MODEL_V6Y' ):IsEmpty()

												For nV6Y := 1 To oModel:GetModel( 'MODEL_V6Y' ):Length()

													oModel:GetModel( 'MODEL_V6Y' ):GoLine(nV6Y)
																	
													If !oModel:GetModel( 'MODEL_V6Y' ):IsDeleted()

														aAdd(aGravaV6Y,{	oModelT62:GetValue('T62_INDAPU') + oModelT62:GetValue('T62_PERAPU') + oModelT63:GetValue('T63_DEMPAG') + oModelV6W:GetValue('V6W_PERREF') + oModelV6X:GetValue('V6X_TPINSC') + oModelV6X:GetValue('V6X_NRINSC'),;												
																			oModelV6Y:GetValue('V6Y_CODRUB'),;
																			oModelV6Y:GetValue('V6Y_DCODRU'),;
																			oModelV6Y:GetValue('V6Y_VRRUBR'),;
																			oModelV6Y:GetValue('V6Y_TABRUB'),;
																			oModelV6Y:GetValue('V6Y_QTDRUB'),;
																			oModelV6Y:GetValue('V6Y_FATRUB'),;
																			oModelV6Y:GetValue('V6Y_APURIR')})

													EndIf

												Next// FIM - V6Y

											EndIf																

										EndIf

									Next// FIM V6X

								EndIf

							EndIf

						Next// FIM - V6W

					EndIf

				EndIf
			
			Next // Fim - CMS

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seto o campo como Inativo e gravo a versao do novo registro³
		//³no registro anterior                                       ³
		//|                                                           |
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FAltRegAnt( 'T62', '2' )
				
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
		For nT62 := 1 to Len( aGravaT62 )
			oModel:LoadValue( "MODEL_T62", aGravaT62[ nT62, 1 ], aGravaT62[ nT62, 2 ] )
		Next nT62
						
		For nT63 := 1 To Len( aGravaT63 )

			If aGravaT63[nT63][1] == aGravaT62[4][2] + aGravaT62[5][2] + aGravaT62[6][2]

				oModel:GetModel( 'MODEL_T63' ):LVALID	:= .T.
				
				If nT63 > 1
					oModel:GetModel( 'MODEL_T63' ):AddLine()
				EndIf

				oModel:LoadValue( "MODEL_T63", "T63_DEMPAG", aGravaT63[nT63][2])
				oModel:LoadValue( "MODEL_T63", "T63_NUMBEN", aGravaT63[nT63][3])

				If lSimplBeta .And. TafColumnPos("T63_INDRRA")
					oModel:LoadValue( "MODEL_T63", "T63_INDRRA", aGravaT63[nT63][4] )
					oModel:LoadValue( "MODEL_T63", "T63_TPPRRA", aGravaT63[nT63][5] )
					oModel:LoadValue( "MODEL_T63", "T63_NRPRRA", aGravaT63[nT63][6] )
					oModel:LoadValue( "MODEL_T63", "T63_DESCRA", aGravaT63[nT63][7] )
					oModel:LoadValue( "MODEL_T63", "T63_QTMRRA", aGravaT63[nT63][8] )
					oModel:LoadValue( "MODEL_T63", "T63_VLRCUS", aGravaT63[nT63][9] )
					oModel:LoadValue( "MODEL_T63", "T63_VLRADV", aGravaT63[nT63][10] )

					/*------------------------------------------
					V9M - Identificação dos advogados   
					--------------------------------------------*/
					nV9MAdd := 1
					For nV9M := 1 to Len( aGravaV9M )

						If  aGravaV9M[nV9M][1] == aGravaT62[4][2] + aGravaT62[5][2] + aGravaT63[nT63][2]

							oModel:GetModel( 'MODEL_V9M' ):LVALID := .T.

							If nV9MAdd > 1
								oModel:GetModel( "MODEL_V9M" ):AddLine()
							EndIf

							oModel:LoadValue( "MODEL_V9M", "V9M_TPINSC", aGravaV9M[nV9M][2] )
							oModel:LoadValue( "MODEL_V9M", "V9M_NRINSC", aGravaV9M[nV9M][3] )
							oModel:LoadValue( "MODEL_V9M", "V9M_VLRADV", aGravaV9M[nV9M][4] )
						
							nV9MAdd++
						EndIf

					Next

				EndIf

				nV6VAdd := 1

				For nV6V := 1 To Len( aGravaV6V )

					If aGravaV6V[nV6V][1] == aGravaT62[4][2] + aGravaT62[5][2] + aGravaT63[nT63][2]

						oModel:GetModel( 'MODEL_V6V' ):LVALID := .T.

						If nV6VAdd > 1
							oModel:GetModel( 'MODEL_V6V' ):AddLine()
						EndIf

						oModel:LoadValue( "MODEL_V6V", "V6V_TPINSC", aGravaV6V[nV6V][2] )
						oModel:LoadValue( "MODEL_V6V", "V6V_NRINSC", aGravaV6V[nV6V][3] )

						nT6OAdd := 1

						For nT6O := 1 To Len( aGravaT6O )

							If aGravaT6O[nT6O][1] == aGravaT62[4][2] + aGravaT62[5][2] + aGravaT63[nT63][2] + aGravaV6V[nV6V][2] + aGravaV6V[nV6V][3]

								oModel:GetModel( 'MODEL_T6O' ):LVALID := .T.

								If nT6OAdd > 1
									oModel:GetModel( 'MODEL_T6O' ):AddLine()
								EndIf

								oModel:LoadValue( "MODEL_T6O", "T6O_IDRUBR", aGravaT6O[nT6O][2] )
								oModel:LoadValue( "MODEL_T6O", "T6O_DRUBR ", aGravaT6O[nT6O][3] )
								oModel:LoadValue( "MODEL_T6O", "T6O_VLRRUB", aGravaT6O[nT6O][4] )
								oModel:LoadValue( "MODEL_T6O", "T6O_TABRUB", aGravaT6O[nT6O][5] )
								oModel:LoadValue( "MODEL_T6O", "T6O_QTDRUB", aGravaT6O[nT6O][6] )							
								oModel:LoadValue( "MODEL_T6O", "T6O_FATRUB", aGravaT6O[nT6O][7] )						
								oModel:LoadValue( "MODEL_T6O", "T6O_APUIR ", aGravaT6O[nT6O][8] )

								nT6OAdd++

							EndIf

						Next// FIM - T6O

						nV6VAdd++

					EndIf			

				Next// FIM - V6V

				nV6WAdd := 1

				For nV6W := 1 To Len( aGravaV6W )	

					If aGravaV6W[nV6W][1] == aGravaT62[4][2] + aGravaT62[5][2] + aGravaT63[nT63][2]

						oModel:GetModel( 'MODEL_V6W' ):LVALID	:= .T.

						If nV6WAdd > 1
							oModel:GetModel( 'MODEL_V6W' ):AddLine()
						EndIf

						oModel:LoadValue( "MODEL_V6W", "V6W_PERREF", aGravaV6W[nV6W][2] )

						nV6XAdd := 1

						For nV6X := 1 To Len( aGravaV6X )	

							If aGravaV6X[nV6X][1] == aGravaT62[4][2] + aGravaT62[5][2] + aGravaT63[nT63][2] + aGravaV6W[nV6W][2]

								oModel:GetModel( 'MODEL_V6X' ):LVALID	:= .T.

								If nV6XAdd > 1
									oModel:GetModel( 'MODEL_V6X' ):AddLine()
								EndIf

								oModel:LoadValue( "MODEL_V6X", "V6X_TPINSC", aGravaV6X[nV6X][2] )						
								oModel:LoadValue( "MODEL_V6X", "V6X_NRINSC", aGravaV6X[nV6X][3] )	

								nV6YAdd := 1

								For nV6Y := 1 To Len(aGravaV6Y)

									If aGravaV6Y[nV6Y][1] == aGravaT62[4][2] + aGravaT62[5][2] + aGravaT63[nT63][2] + aGravaV6W[nV6W][2] + aGravaV6X[nV6X][2] + aGravaV6X[nV6X][3] 		

										oModel:GetModel( 'MODEL_V6Y' ):LVALID := .T.

										If nV6YAdd > 1
											oModel:GetModel( 'MODEL_V6Y' ):AddLine()
										EndIf

										oModel:LoadValue( "MODEL_V6Y", "V6Y_CODRUB", aGravaV6Y[nV6Y][2] ) 
										oModel:LoadValue( "MODEL_V6Y", "V6Y_DCODRU", aGravaV6Y[nV6Y][3] ) 
										oModel:LoadValue( "MODEL_V6Y", "V6Y_VRRUBR", aGravaV6Y[nV6Y][4] ) 
										oModel:LoadValue( "MODEL_V6Y", "V6Y_TABRUB", aGravaV6Y[nV6Y][5] ) 
										oModel:LoadValue( "MODEL_V6Y", "V6Y_QTDRUB", aGravaV6Y[nV6Y][6] ) 
										oModel:LoadValue( "MODEL_V6Y", "V6Y_FATRUB", aGravaV6Y[nV6Y][7] ) 
										oModel:LoadValue( "MODEL_V6Y", "V6Y_APURIR", aGravaV6Y[nV6Y][8] ) 

										nV6YAdd++

									EndIf

								Next // Fim - V6Y

								nV6XAdd++

							EndIf							

				        Next // Fim - V6X

						nV6WAdd++

					EndIf

				Next // Fim - V6W

			EndIf

		Next // Fim - T63

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco a versao que sera gravada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVersao := xFunGetVer()		 
											
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ		
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		                                                                      				         
		oModel:LoadValue( 'MODEL_T62', 'T62_VERSAO', cVersao	)  
		oModel:LoadValue( 'MODEL_T62', 'T62_VERANT', cVerAnt	)									          				    
		oModel:LoadValue( 'MODEL_T62', 'T62_PROTPN', cProtocolo )									          						
		oModel:LoadValue( "MODEL_T62", "T62_PROTUL", ""         )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|Tratamento para que caso o Evento Anterior fosse de exclusão	 	|
		//|seta-se o novo evento como uma "nova inclusão", caso contrário o 	|
		//|evento passar a ser uma alteração										|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		oModel:LoadValue( "MODEL_T62", "T62_EVENTO", "E" )
		oModel:LoadValue( "MODEL_T62", "T62_ATIVO" , "1" )
		
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		//³Gravo as informações e o status do registro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		FwFormCommit( oModel )
		TAFAltStat( 'T62',"6" )
			
	End Transaction

Return ( .T. )
