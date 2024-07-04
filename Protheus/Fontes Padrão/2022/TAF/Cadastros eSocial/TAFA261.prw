#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA261.CH"

Static lLaySimplif := taflayEsoc("S_01_00_00")

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA261
Afastamento Temporario (S-2230)

Evento foi reescrito após alinhamento de comportamento com todas as linha de produto TOTVS
que integram com o TAF, atenção na manutenção!

@Author Rodrigo Aguilar
@since 27/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA261()

	Local aCamposCM6  := xFunGetSX3( 'CM6' , 'CM6_NISV' ,.T.)
	Local aOnlyFields := {}
	Local aLegend     := {}
	Local nI          := 0

	Private cNomEve   := "S2230"
	Private oBrw      := FWmBrowse():New()

	// Preenchendo array com Nomes de Campos de todos os campos usados da tabela CM6
	For nI := 1 to Len( aCamposCM6 )
		AAdd( aOnlyFields, aCamposCM6[nI][2] )	
	Next nI

	// Tratamento para simplificação do e-Social
	If !lLaySimplif

		aAdd(aOnlyFields, 'CM6_NISV')

	EndIf

	If FindFunction("FilCpfNome") .And. GetSx3Cache("CM6_CPFV","X3_CONTEXT") == "V" .AND. !FwIsInCallStack("TAFPNFUNC") .AND. !FwIsInCallStack("TAFMONTES")
		
		aAdd(aLegend, {"CM6_XMLREC  == 'COMP'  .AND. CM6_EVENTO  != 'E' .AND. CM6_EVENTO != 'R'	"	, "BROWN" 	, 'Afastamento Completo (Início e Término)' } )
		aAdd(aLegend, {"CM6_EVENTO  == 'I' 	"														, "GREEN" 	, 'Início do Afastamento'} )
		aAdd(aLegend, {"CM6_EVENTO  == 'R' 	"														, "WHITE" 	, 'Afastamento Retificado'} )
		aAdd(aLegend, {"CM6_EVENTO  == 'F' 	"														, "BLACK" 	, 'Término do Afastamento'} )
		aAdd(aLegend, {"CM6_EVENTO  == 'E' .AND. CM6_STATUS == '6' 	"								, "ORANGE" 	, "Aguardando Retorno da Exclusão"} ) //"Aguardando Retorna da Exclusão"
		aAdd(aLegend, {"CM6_EVENTO  == 'E' 	"														, "RED" 	, 'Afastamento Excluído'} )

		TafNewBrowse( "S-2230","CM6_DTAFAS", "CM6_DTFAFA",2, STR0001, aOnlyFields, 2, 7, aLegend ) //Afastamento Temporario

	Else
		//------------------------------------------------------------
		// Função que indica se o ambiente é válido para o eSocial 2.3
		//------------------------------------------------------------
		If TafAtualizado()
		
			//------------------------------------------------------------------------------------------
			//Verifico se o dicionário do cliente está compatível com a versão de repositório que possui
			//------------------------------------------------------------------------------------------
			If TAFAlsInDic( "T6M" )
		
				oBrw:SetDescription( STR0001 )  			//Afastamento Temporario
				oBrw:SetAlias( 'CM6' )
				oBrw:SetMenuDef( 'TAFA261' )
				oBrw:SetCacheView( .F. )
				oBrw:DisableDetails()
		
				If FindFunction('TAFSetFilter')
					oBrw:SetFilterDefault(TAFBrwSetFilter("CM6","TAFA261","S-2230"))
				Else
					oBrw:SetFilterDefault( "CM6_ATIVO == '1'" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )
				EndIf
		
				If TafColumnPos( "CM6_XMLREC" )
					oBrw:AddLegend( "CM6_XMLREC  == 'COMP'  .AND. CM6_EVENTO  != 'E'	", "BROWN" 	, 'Afastamento Completo (Início e Término)' )
				EndIf
				oBrw:AddLegend( "CM6_EVENTO  == 'I' 	", "GREEN" 	, 'Início do Afastamento'  )
				oBrw:AddLegend( "CM6_EVENTO  == 'R' 	", "WHITE" 	, 'Afastamento Retificado' )
				oBrw:AddLegend( "CM6_EVENTO  == 'F' 	", "BLACK" 	, 'Término do Afastamento' )
				oBrw:AddLegend( "CM6_EVENTO  == 'E' 	", "RED" 	, 'Afastamento Excluído'   )
		
				oBrw:Activate()
		
			Else
				Aviso( STR0013, TafAmbInvMsg(), { STR0014 }, 2 ) //##"Dicionário Incompatível" ##"Encerrar"
		
			EndIf
		
		EndIf

	EndIf
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Rodrig Aguilar
@since 27/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao		:= {}
	Local aRotina 		:= {}
	Local aRotAfa 		:= Nil
	Local cFunName		:= FunName()
	Local lAltFunName	:= .F.

	If FindFunction("FilCpfNome") .And. GetSx3Cache("CM6_CPFV","X3_CONTEXT") == "V" .AND. !FwIsInCallStack("TAFPNFUNC") .AND. !FwIsInCallStack("TAFMONTES")

		aRotAfa := Array(2,4)

		aRotAfa[1] := {"Retificar / Alterar Evento", "xTafAlt('CM6', 0 , 1)", 0, 4}	
		aRotAfa[2] := {"Término do Afastamento"	   , "xTafAlt('CM6', 0 , 3)", 0, 4}

		ADD OPTION aRotina TITLE "Visualizar" ACTION "TAFA261Op('1')"   OPERATION 2 ACCESS 0 //'Visualizar'
		ADD OPTION aRotina TITLE "Incluir"    ACTION 'VIEWDEF.TAFA261'  OPERATION 3 ACCESS 0 //'Incluir'
		ADD OPTION aRotina TITLE "Alterar"    ACTION aRotAfa 			OPERATION 4 ACCESS 0 //'Alterar'
		ADD OPTION aRotina TITLE "Imprimir"	  ACTION 'VIEWDEF.TAFA261'	OPERATION 8 ACCESS 0 //'Imprimir'

	Else

		Aadd( aFuncao, { "" , "TAFA261Op('2')"      , "1"  } )
		Aadd( aFuncao, { "" , "TAFA261Op('3')"      , "2"  } )
		Aadd( aFuncao, { "" , "xFunAltRec( 'CM6' )" , "10" } )
		
		// Como a MenuDef é chamada em rotinas de FrameWork e o TAF "customiza" ela, força o nome do menu chamador, para que o comportamento seja idêntico em ambas chamadas.
		If !FWIsInCallStack( "TAFA261" )
			lAltFunName := .T.
			SetFunName( "TAFA261" )
		EndIf
		
		//Chamo a Browse do Histórico
		If FindFunction( "xFunNewHis" )
			Aadd( aFuncao, { "" , "xNewHisAlt( 'CM6', 'TAFA261' )" , "3" } )
		Else
			Aadd( aFuncao, { "" , "xFunHisAlt( 'CM6', 'TAFA261' )" , "3" } )
		EndIf
		
		Aadd( aFuncao, { "" , "TAFXmlLote( 'CM6', 'S-2230' , 'evtAfastTemp' , 'TAF261Xml' )" , "5" } )
		
		lMenuDIf := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDIf )
		
		If lMenuDif
			ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA261' OPERATION 2 ACCESS 0
		
			// Menu dos extemporâneos
			If FindFunction( "xFunNewHis" ) .AND. FindFunction( "xTafExtmp" ) .And. xTafExtmp()
				aRotina	:= xMnuExtmp( "TAFA261", "CM6" )
			EndIf
		Else
			aRotina	:=	xFunMnuTAF( "TAFA261" , , aFuncao, ,STR0009,,STR0011) //"Retificar Evento" "Término do Afastamento"
		EndIf
		
		// Restaura o valor inicial do FunName() caso tenha sido alterada
		If lAltFunName
			SetFunName(cFunName)
		EndIf
		
	EndIf

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rodrigo Aguilar
@since 27/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruCM6 	:= FWFormStruct( 1, 'CM6' )
	Local oStruT6M 	:= Iif(!lLaySimplif, FWFormStruct( 1, 'T6M' ), Nil) // Tratamento para simplificação do e-Social
	Local oModel   	:= MPFormModel():New( 'TAFA261',, { |oModel| ValidModel( oModel ) }, { |oModel| SaveModel( oModel ) } )

	Local bValidCM6	:=	{ |oModelCM6, cAction, cIDField, xValue| ValidCM6( oModelCM6, cAction, cIDField, xValue ) }

	// Tratamento para simplificação do e-Social
	If !lLaySimplif

		oStruCM6:RemoveField("CM6_PERINI")
		oStruCM6:RemoveField("CM6_PERFIM")
		oStruCM6:RemoveField("CM6_REMCAR")
		oStruCM6:RemoveField("CM6_CNPJME")

	EndIf

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel

		oStruCM6:SetProperty( "*", MODEL_FIELD_VALID, )

		// Tratamento para simplificação do e-Social
		If !lLaySimplif

			oStruT6M:SetProperty( "*", MODEL_FIELD_VALID, )

		EndIf

	EndIf

	If Type( "cOperEvnt" ) <> "U"

		If cOperEvnt == '3'

			oStruCM6:SetProperty( "CM6_FUNC"  ,MODEL_FIELD_WHEN,{|| .F. })
			oStruCM6:SetProperty( "CM6_DFUNC" ,MODEL_FIELD_WHEN,{|| .F. })
			oStruCM6:SetProperty( "CM6_DTAFAS",MODEL_FIELD_WHEN,{|| .F. })
			oStruCM6:SetProperty( "CM6_MOTVAF",MODEL_FIELD_WHEN,{|| .F. })
			oStruCM6:SetProperty( "CM6_DMOTVA",MODEL_FIELD_WHEN,{|| .F. })
			oStruCM6:SetProperty( "CM6_INFMTV",MODEL_FIELD_WHEN,{|| .F. })
			oStruCM6:SetProperty( "CM6_TPACID",MODEL_FIELD_WHEN,{|| .F. })
			oStruCM6:SetProperty( "CM6_OBSERV",MODEL_FIELD_WHEN,{|| .F. })
			oStruCM6:SetProperty( "CM6_CNPJCE",MODEL_FIELD_WHEN,{|| .F. })
			oStruCM6:SetProperty( "CM6_INFOCE",MODEL_FIELD_WHEN,{|| .F. })
			oStruCM6:SetProperty( "CM6_CNPJSD",MODEL_FIELD_WHEN,{|| .F. })
			oStruCM6:SetProperty( "CM6_INFOSD",MODEL_FIELD_WHEN,{|| .F. })
			oStruCM6:SetProperty( "CM6_ORIRET",MODEL_FIELD_WHEN,{|| .F. })
			oStruCM6:SetProperty( "CM6_IDPROC",MODEL_FIELD_WHEN,{|| .F. })
			oStruCM6:SetProperty( "CM6_DPROCJ",MODEL_FIELD_WHEN,{|| .F. })
			
			// Tratamento para simplificação do e-Social
			If !lLaySimplif

				oStruT6M:SetProperty( "T6M_CODCID",MODEL_FIELD_WHEN,{|| .F. })
				oStruT6M:SetProperty( "T6M_DIASAF",MODEL_FIELD_WHEN,{|| .F. })
				oStruT6M:SetProperty( "T6M_IDPROF",MODEL_FIELD_WHEN,{|| .F. })
			
			Else

				oStruCM6:SetProperty( "CM6_PERINI",MODEL_FIELD_WHEN,{|| .F. })
				oStruCM6:SetProperty( "CM6_PERFIM",MODEL_FIELD_WHEN,{|| .F. })
				oStruCM6:SetProperty( "CM6_REMCAR",MODEL_FIELD_WHEN,{|| .F. })
				oStruCM6:SetProperty( "CM6_CNPJME",MODEL_FIELD_WHEN,{|| .F. })

			EndIf

		EndIf

	EndIf

	//Remoção do GetSX8Num quando se tratar da Exclusão de um Evento Transmitido.
	//Necessário para não incrementar ID que não será utilizado.
	If Upper( ProcName( 2 ) ) == Upper( "GerarExclusao" )
		oStruCM6:SetProperty( "CM6_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )
	EndIf

	//--------------------------------------
	// Informações do afastamento temporário
	//--------------------------------------
	oModel:AddFields('MODEL_CM6', /*cOwner*/, oStruCM6, bValidCM6)

	// Tratamento para simplificação do e-Social
	If !lLaySimplif

		//---------------
		// Info Atestado
		//---------------
		oModel:AddGrid('MODEL_T6M', 'MODEL_CM6', oStruT6M)
		oModel:GetModel('MODEL_T6M'):SetOptional(.T.)
		oModel:GetModel('MODEL_T6M'):SetUniqueLine({'T6M_SEQUEN'})
		oModel:GetModel('MODEL_T6M'):SetMaxLine(9)

	EndIf
	//------------
	//Primary Key
	//------------
	oModel:GetModel('MODEL_CM6'):SetPrimaryKey({'CM6_FILIAL', 'CM6_FUNC', 'CM6_DTAFAS'})

	// Tratamento para simplificação do e-Social
	If !lLaySimplif

		//----------
		//Relations
		//----------
		oModel:SetRelation('MODEL_T6M', {{'T6M_FILIAL','xFilial("T6M")'}, {'T6M_ID','CM6_ID'}, {'T6M_VERSAO','CM6_VERSAO'}}, T6M->(IndexKey(1)))

	EndIf

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rodrigo Aguilar
@since 27/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   	:= FwLoadModel("TAFA261")
	Local oStruCM6a := Nil
	Local oStruCM6b	:= Nil
	Local oStruCM6c	:= Nil
	Local oStruT6M	:= Iif(!lLaySimplif, FWFormStruct( 2, 'T6M' ), Nil) // Tratamento para simplificação do e-Social
	Local oView    	:= FWFormView():New()

	Local cCmpFil	:= ""
	Local cCmpTrans	:= ""
	Local cVinculo	:= ""
	Local cIniAfast	:= ""
	Local cInfoFer	:= ""
	Local cInfoCess	:= ""
	Local cMandSind	:= ""
	Local cManElet	:= ""
	Local cInfoRet	:= ""
	Local cFimAfast	:= ""

	Local nI		:= 0
	Local aCmpGrp	:= {}

	oView:SetModel( oModel )

	//--------------------------------------------
	// Campos do folder Informacoes do Afastamento
	//--------------------------------------------
	cVinculo	:= 'CM6_ID|CM6_FUNC|CM6_DFUNC|'
	cIniAfast	:= 'CM6_DTAFAS|CM6_MOTVAF|CM6_DMOTVA|CM6_INFMTV|CM6_TPACID|CM6_OBSERV|'

	// Tratamento para simplificação do e-Social
	If lLaySimplif

		cInfoFer	:= 'CM6_PERINI|CM6_PERFIM|'
		cManElet	:= 'CM6_REMCAR|CM6_CNPJME|'

	EndIf

	cInfoCess	:= 'CM6_CNPJCE|CM6_INFOCE|'
	cMandSind	:= 'CM6_CNPJSD|CM6_INFOSD|'
	cInfoRet	:= 'CM6_ORIRET|CM6_IDPROC|CM6_DPROCJ|'
	cFimAfast	:= 'CM6_DTFAFA|'

	cCmpFil		:= cVinculo + cIniAfast + cInfoFer + cInfoCess + cMandSind + cManElet + cInfoRet + cFimAfast
	oStruCM6a	:= FwFormStruct( 2, "CM6",{|x| AllTrim( x ) + "|" $ cCmpFil } )

	// Tratamento para simplificação do e-Social
	If !lLaySimplif

		oStruCM6a:RemoveField("CM6_PERINI")
		oStruCM6a:RemoveField("CM6_PERFIM")
		oStruCM6a:RemoveField("CM6_REMCAR")
		oStruCM6a:RemoveField("CM6_CNPJME")

	EndIf

	//--------------------------
	// Ordem dos campos na tela
	//--------------------------
	oStruCM6a:SetProperty( "CM6_INFMTV"	, MVC_VIEW_ORDEM	, "09"	)
	oStruCM6a:SetProperty( "CM6_TPACID"	, MVC_VIEW_ORDEM	, "10"	)
	oStruCM6a:SetProperty( "CM6_OBSERV"	, MVC_VIEW_ORDEM	, "11"	)

	oStruCM6a:SetProperty( "CM6_CNPJCE"	, MVC_VIEW_ORDEM	, "17"	)
	oStruCM6a:SetProperty( "CM6_INFOCE"	, MVC_VIEW_ORDEM	, "18"	)

	oStruCM6a:SetProperty( "CM6_ORIRET"	, MVC_VIEW_ORDEM	, "31"	)
	oStruCM6a:SetProperty( "CM6_IDPROC"	, MVC_VIEW_ORDEM	, "32"	)
	oStruCM6a:SetProperty( "CM6_DPROCJ"	, MVC_VIEW_ORDEM	, "33"	)

	//-------------------------------------------
	// Campos do folder Protocolo de Transmissão
	//-------------------------------------------
	cCmpTrans	:= 'CM6_PROTUL|'
	oStruCM6b	:= FwFormStruct( 2, "CM6",{|x| AllTrim( x ) + "|" $ cCmpTrans } )

	If TafColumnPos("CM6_DTRANS")
		cCmpTrans := "CM6_DINSIS|CM6_DTRANS|CM6_HTRANS|CM6_DTRECP|CM6_HRRECP|"
		oStruCM6c	:= FwFormStruct( 2, "CM6",{|x| AllTrim( x ) + "|" $ cCmpTrans } )
	EndIf

	oStruCM6a:AddGroup( "GRP_AFAST_01", "", "", 1 )      //"Informações de Identificação do Trabalhador e do Vínculo"
	oStruCM6a:AddGroup( "GRP_AFAST_02", STR0018, "", 1 ) //"Informações do Afastamento Temporário - Início"

	// Tratamento para simplificação do e-Social
	If lLaySimplif

		oStruCM6a:AddGroup( "GRP_AFAST_03", STR0068, "", 1 ) //"Informações referentes ao período aquisitivo de férias"

	EndIf

	oStruCM6a:AddGroup( "GRP_AFAST_04", STR0019, "", 1 ) //"Afastamento por Cessão ou Requisição do Trabalhador"
	oStruCM6a:AddGroup( "GRP_AFAST_05", STR0020, "", 1 ) //"Afastamento para Exercício de Mandato Sindical"

	// Tratamento para simplificação do e-Social
	If lLaySimplif

		oStruCM6a:AddGroup( "GRP_AFAST_06", STR0069, "", 1 ) //"Afastamento para exercício de mandato eletivo"

	EndIf

	oStruCM6a:AddGroup( "GRP_AFAST_07", STR0021, "", 1 ) //"Informações de Retificação do Afastamento Temporário"
	oStruCM6a:AddGroup( "GRP_AFAST_08", STR0022, "", 1 ) //"Informações do Término do Afastamento"

	aCmpGrp := StrToKarr( cVinculo, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruCM6a:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_AFAST_01" )
	Next nI

	aCmpGrp := StrToKarr( cIniAfast, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruCM6a:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_AFAST_02" )
	Next nI

	aCmpGrp := StrToKarr( cInfoCess, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruCM6a:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_AFAST_04" )
	Next nI

	aCmpGrp := StrToKarr( cMandSind, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruCM6a:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_AFAST_05" )
	Next nI

	aCmpGrp := StrToKarr( cInfoRet, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruCM6a:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_AFAST_07" )
	Next nI

	aCmpGrp := StrToKarr( cFimAfast, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruCM6a:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_AFAST_08" )
	Next nI

	// Tratamento para simplificação do e-Social
	If lLaySimplif

		aCmpGrp := StrToKarr( cInfoFer, "|" )
		For nI := 1 to Len( aCmpGrp )
			oStruCM6a:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_AFAST_03" )
		Next nI

		aCmpGrp := StrToKarr( cManElet, "|" )
		For nI := 1 to Len( aCmpGrp )
			oStruCM6a:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_AFAST_06" )
		Next nI

	EndIf

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruCM6b,"CM6")
	EndIf

	/*----------------------------------------------------------------------------------
	Esrutura da View
	------------------------------------------------------------------------------------*/
	oView:AddField("VIEW_CM6a",oStruCM6a,"MODEL_CM6")
	oView:EnableTitleView("VIEW_CM6a",STR0005) //Afastamento Temporario

	oView:AddField("VIEW_CM6b",oStruCM6b,"MODEL_CM6")

	If TafColumnPos("CM6_PROTUL")
		oView:EnableTitleView( 'VIEW_CM6b', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"
	EndIf
	If TafColumnPos("CM6_DTRANS")
		oView:AddField("VIEW_CM6c",oStruCM6c,"MODEL_CM6")
		oView:EnableTitleView( 'VIEW_CM6c', TafNmFolder("recibo",2) )
	EndIf

	// Tratamento para simplificação do e-Social
	If !lLaySimplif

		oView:AddGrid( 'VIEW_T6M', oStruT6M, 'MODEL_T6M' )
		oView:EnableTitleView( 'VIEW_T6M',STR0015) //"Informações do Atestado"
		oView:AddIncrementField( 'VIEW_T6M', 'T6M_SEQUEN' ) 

	EndIf
	/*----------------------------------------------------------------------------------
	Estrutura do Folder
	------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox("PAINEL_CM6",100)

	oView:CreateFolder("FOLDER_CM6","PAINEL_CM6")

	oView:AddSheet( 'FOLDER_CM6', "ABA01", STR0005 ) //"Informações do Afastamento"
	oView:CreateHorizontalBox("PAINEL_CM6a", Iif(!lLaySimplif, 75, 100),,,"FOLDER_CM6","ABA01") // Tratamento para simplificação do e-Social

	// Tratamento para simplificação do e-Social
	If !lLaySimplif

		oView:CreateHorizontalBox("PAINEL_T6M" ,25,,,"FOLDER_CM6","ABA01")

	EndIf

	If FindFunction("TafNmFolder")
		oView:AddSheet( 'FOLDER_CM6', "ABA02", TafNmFolder("recibo") )   //"Numero do Recibo"
	Else
		oView:AddSheet( 'FOLDER_CM6', "ABA02", STR0008 ) //"Protocolo de Transmissão"
	EndIf

	If TafColumnPos("CM6_DTRANS")
		oView:CreateHorizontalBox("PAINEL_CM6b",20,,,"FOLDER_CM6","ABA02")
		oView:CreateHorizontalBox("PAINEL_CM6c",80,,,"FOLDER_CM6","ABA02")
	Else
		oView:CreateHorizontalBox("PAINEL_CM6b",100,,,"FOLDER_CM6","ABA02")
	EndIf

	/*----------------------------------------------------------------------------------
	Estrutura de Amarração
	------------------------------------------------------------------------------------*/
	oView:SetOwnerView("VIEW_CM6a","PAINEL_CM6a")

	// Tratamento para simplificação do e-Social
	If !lLaySimplif

		oView:SetOwnerView("VIEW_T6M" ,"PAINEL_T6M" )

	EndIf

	oView:SetOwnerView("VIEW_CM6b","PAINEL_CM6b")
	If TafColumnPos("CM6_DTRANS")
		oView:SetOwnerView("VIEW_CM6c","PAINEL_CM6c")
	EndIf

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If !lMenuDif
		xFunRmFStr(@oStruCM6a, 'CM6')
	EndIf

Return(oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@Author Rodrigo Aguilar
@Since 27/10/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local cLogOpeAnt	:= ""

	Local cVerAnt    	:= ""
	Local cProtocolo 	:= ""
	Local cVersao    	:= ""
	Local cChvRegAnt 	:= ""
	Local cEvento	 	:= ""
	Local cXmlRecib	    := ""

	Local nOperation 	:= oModel:GetOperation()
	Local nlI			:= 0
	Local nlY   		:= 0
	Local nT6M			:= 0

	Local aGrava     	:= {}
	Local aGravaT6M  	:= {}

	Local oModelCM6  	:= Nil
	Local oModelT6M  	:= Nil

	Local lReturn    	:= .T.

	Default oModel	    := Nil


	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	If Type("cOperEvnt") <> "U"
		If cOperEvnt == '1'
			If (CM6->CM6_STATUS == "4" .and. !Empty(CM6->CM6_PROTUL))
				cEvento := "R"
			Else
				cEvento := "I"
			EndIf
		Else
			cEvento := "F"
		EndIf
	EndIf

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT

			TafAjustID( "CM6", oModel)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifico se é um evento de Término³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oModelCM6	:=	oModel:GetModel( "MODEL_CM6" )

			If !Empty(oModelCM6:GetValue( "CM6_DTAFAS" )) .And. !Empty(oModelCM6:GetValue( "CM6_DTFAFA" ))
				cXmlRecib 	:= "COMP"
				cEvento 	:= "C"
			ElseIf !Empty(oModelCM6:GetValue( "CM6_DTAFAS" ))
				cXmlRecib 	:= "INIC"
				cEvento 	:= "I"
			ElseIf !Empty(oModelCM6:GetValue( "CM6_DTFAFA" ))
				cXmlRecib 	:= "TERM"
				cEvento	:= "F"
			EndIf

			oModel:LoadValue( 'MODEL_CM6', 'CM6_VERSAO', xFunGetVer() )

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_CM6', 'CM6_LOGOPE' , '2', '' )
			Endif

			If !Empty(cEvento)
				oModel:LoadValue( 'MODEL_CM6', 'CM6_EVENTO', cEvento )
			EndIf

			If TafColumnPos( "CM6_XMLREC" )
				oModel:LoadValue( 'MODEL_CM6', 'CM6_XMLREC', cXmlRecib )
			EndIf

			FwFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CM6->( DbSetOrder( 3 ) )
			If lGoExtemp .OR. CM6->( MsSeek( xFilial( 'CM6' ) + M->CM6_ID + '1' ) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o registro ja foi transmitido³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If CM6->CM6_STATUS $ ( "4" )

					oModelCM6 := oModel:GetModel( 'MODEL_CM6' )

					// Tratamento para simplificação do e-Social
					If !lLaySimplif
					
						oModelT6M := oModel:GetModel( 'MODEL_T6M' )

					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao anterior do registro para gravacao do rastro³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVerAnt   := oModelCM6:GetValue( "CM6_VERSAO" )
					cProtocolo:= oModelCM6:GetValue( "CM6_PROTUL" )

					If TafColumnPos( "CM6_LOGOPE" )
						cLogOpeAnt := oModelCM6:GetValue( "CM6_LOGOPE" )
					endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu gravo as informacoes que foram carregadas       ³
					//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
					//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
					//³nao devem ser consideradas neste momento                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nlI := 1 To 1
						For nlY := 1 To Len( oModelCM6:aDataModel[ nlI ] )
							Aadd( aGrava, { oModelCM6:aDataModel[ nlI, nlY, 1 ], oModelCM6:aDataModel[ nlI, nlY, 2 ] } )
						Next
					Next

					// Tratamento para simplificação do e-Social
					If !lLaySimplif

						/*------------------------------------------
						T6M - Informações do Atestado
						--------------------------------------------*/
						For nT6M := 1 To oModel:GetModel( 'MODEL_T6M' ):Length()
							oModel:GetModel( 'MODEL_T6M' ):GoLine(nT6M)

							If !oModel:GetModel( 'MODEL_T6M' ):IsDeleted()
								aAdd (aGravaT6M ,{oModelT6M:GetValue('T6M_SEQUEN'),;
									oModelT6M:GetValue('T6M_CODCID'),;
									oModelT6M:GetValue('T6M_DIASAF'),;
									oModelT6M:GetValue('T6M_IDPROF') })
							EndIf
						Next
					
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seto o campo como Inativo e gravo a versao do novo registro³
					//³no registro anterior                                       ³
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FAltRegAnt( 'CM6', '2' )

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
						oModel:LoadValue( 'MODEL_CM6', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
					Next

					//Necessário Abaixo do For Nao Retirar
					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_CM6', 'CM6_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					// Tratamento para simplificação do e-Social
					If !lLaySimplif

						/*------------------------------------------
						T6M - Informações do Atestado
						--------------------------------------------*/
						For nT6M := 1 To Len( aGravaT6M )
							If nT6M > 1
								oModel:GetModel( 'MODEL_T6M' ):AddLine()
							EndIf
							oModel:LoadValue( "MODEL_T6M", "T6M_SEQUEN" ,	aGravaT6M[nT6M][1] )
							oModel:LoadValue( "MODEL_T6M", "T6M_CODCID" ,	aGravaT6M[nT6M][2] )
							oModel:LoadValue( "MODEL_T6M", "T6M_DIASAF" ,	aGravaT6M[nT6M][3] )
							oModel:LoadValue( "MODEL_T6M", "T6M_IDPROF" ,	aGravaT6M[nT6M][4] )
						Next

					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao que sera gravada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVersao := xFunGetVer()

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oModel:LoadValue( 'MODEL_CM6', 'CM6_VERSAO', cVersao )
					oModel:LoadValue( 'MODEL_CM6', 'CM6_VERANT', cVerAnt )
					oModel:LoadValue( 'MODEL_CM6', 'CM6_PROTPN', cProtocolo )
					oModel:LoadValue( 'MODEL_CM6', 'CM6_PROTUL', "" )
					oModel:LoadValue( 'MODEL_CM6', 'CM6_EVENTO', cEvento )
					
					

					// Tratamento para limpar o ID unico do xml
					cAliasPai := "CM6"
					If TAFColumnPos( cAliasPai+"_XMLID" )
						oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					EndIf

				ElseIf	CM6->CM6_STATUS == ( "2" )
					TAFMsgVldOp( oModel, "2" )
					lReturn := .F.

				ElseIf CM6->CM6_STATUS == ( "6" )
					TAFMsgVldOp( oModel, "6" )
					lReturn := .F.

				ElseIf CM6->CM6_STATUS == ( "7" )
					TAFMsgVldOp( oModel, "7" )
					lReturn := .F.
				else
					//alteração sem transmissão
					If TafColumnPos( "CM6_LOGOPE" )
						cLogOpeAnt := CM6->CM6_LOGOPE
					endif
				EndIf

				If lReturn

					oModelCM6	:=	oModel:GetModel( "MODEL_CM6" )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Gravo o XML Recebido³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty(oModelCM6:GetValue( "CM6_DTAFAS" )) .And. !Empty(oModelCM6:GetValue( "CM6_DTFAFA" ))
						If CM6->CM6_STATUS == "4"
							cXmlRecib 	:= Iif(!cEvento == "F", "COMP", "TERM")
							cEvento 	:= Iif(!cEvento == "R", "C", cEvento)
						Else
							If !Empty(CM6->CM6_XMLREC)
								cXmlRecib   := CM6->CM6_XMLREC
								cEvento     := CM6->CM6_EVENTO
							Else
								cXmlRecib 	:= "COMP"
								cEvento 	:= "C"
							EndIf
						EndIf
					ElseIf !Empty(oModelCM6:GetValue( "CM6_DTAFAS" ))

						If CM6->CM6_STATUS == "4"
							cEvento := "R"
						EndIf

						cXmlRecib 	:= "INIC"
						cEvento 	:= Iif(!cEvento == "R", "I", cEvento)

					ElseIf !Empty(oModelCM6:GetValue( "CM6_DTFAFA" ))
						
						If CM6->CM6_STATUS == "4"
							cEvento := "R"
						EndIf

						cXmlRecib 	:= "TERM"
						cEvento 	:= Iif(!cEvento == "R", "F", cEvento)

					EndIf

					If TafColumnPos( "CM6_XMLREC" )
						oModel:LoadValue( 'MODEL_CM6', 'CM6_XMLREC', cXmlRecib )
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Gravo o tipo do evento³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oModel:LoadValue( 'MODEL_CM6', 'CM6_EVENTO', cEvento )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//Gravo alteração para o Extemporâneo
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lGoExtemp
						TafGrvExt( oModel, 'MODEL_CM6', 'CM6' )
					EndIf

					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_CM6', 'CM6_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					FwFormCommit( oModel )
					TAFAltStat( 'CM6', " " )

				EndIf

			EndIf

		ElseIf nOperation == MODEL_OPERATION_DELETE

			cChvRegAnt := CM6->(CM6_ID + CM6_VERANT)

			If !Empty( cChvRegAnt )
				TAFAltStat( 'CM6', " " )

				FwFormCommit( oModel )
				If nOperation == MODEL_OPERATION_DELETE
					If CM6->CM6_EVENTO $ "E|A|R|F"
						If Type("oBrw") == "U"
							oBrw := Nil
						endif	
						TAFRastro( 'CM6', 1, cChvRegAnt, .T.,,oBrw )
					EndIf
				EndIf

			Else
				oModel:DeActivate()
				oModel:SetOperation( 5 )
				oModel:Activate()

				FwFormCommit( oModel )
			EndIf

		EndIf

	End Transaction

Return ( lReturn )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF261Xml
Funcao de geracao do XML para atender o registro S-2230
Quando a rotina for chamada o registro deve estar posicionado

@Return:
cXml - Estrutura do Xml do Layout S-2230
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@author Rodrigo Aguilar
@since 29/10/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF261Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

	Local cLayout		:= "2230"
	Local cReg			:= "AfastTemp"
	Local cCodMotAfast  := ""
	Local cXml			:= ""
	Local cXmlEmi		:= ""
	Local cXmlAtes		:= ""
	Local cXmlPer		:= ""
	Local cXmlCes		:= ""
	Local cXmlMan		:= ""
	Local cXmlElet		:= ""
	Local cTpProc		:= ""
	Local cCodCateg		:= ""
	Local cNISFunc		:= ""
	Local dDtAfast		:= ""
	Local aAreaCM6		:= {}
	Local lTermAnt 		:= .F.
	Local lFimAfast		:= .F.
	Local lRegNovo 		:= .F.
	Local lInfAtest     := .F. //Indica se o grupo de tags InfoAtestado deverá ser gerado, mesmo se tiver com valor zerado.
	Local lNt1519       := FindFunction("TafNT1519") .And. TAFNT1519()
	Local cFilBkp       := cFilAnt
	Local lXmlVLd		:= IIF(FindFunction('TafXmlVLD'),TafXmlVLD('TAF261XML'),.T.)

	Default cAlias	    := ""
	Default nRecno	    := 1
	Default nOpc		:= 1
	Default lJob		:= .F.
	Default cSeqXml 	:= ""

	If lXmlVLd

		If IsInCallStack("TafNewBrowse") .And. ( CM6->CM6_FILIAL <> cFilAnt )
			cFilAnt := CM6->CM6_FILIAL
		EndIf

		//---------------------------------------
		//Posiciona no trabalhador do afastamento
		//---------------------------------------
		DbSelectArea("C9V")
		C9V->( DbSetOrder( 2 ) )
		C9V->( MsSeek ( xFilial("C9V") + CM6->CM6_FUNC + "1" ) )

		dDtAfast := DToS(CM6->CM6_DTAFAS)
		//----------------------------------
		//Somente gera a categoria para TSV
		//----------------------------------
		
		cCodMotAfast := Posicione( "C8N", 1, xFilial( "C8N" ) + CM6->CM6_MOTVAF, "C8N_CODIGO" )

		cXml +=		"<ideVinculo>"
		cXml += 			xTafTag("cpfTrab"  , C9V->C9V_CPF		,,.F.)

		// Tratamento para simplificação do e-Social
		If !lLaySimplif

			cNISFunc := TAF261Nis(C9V->C9V_FILIAL, C9V->C9V_ID, C9V->C9V_NIS, dDtAfast)
			
			cXml +=			xTafTag("nisTrab"  , cNISFunc			,,.T.)
		
		EndIf

		If C9V->C9V_NOMEVE == "S2200"
			cXml +=			xTafTag("matricula", C9V->C9V_MATRIC	,,.T.)
		Else	
			cXml +=			xTafTag("matricula", C9V->C9V_MATTSV	,,.T.)
		EndIf 	
		
		If C9V->C9V_NOMEVE == "S2300" .And. Empty( C9V->C9V_MATTSV )
			cCodCateg	:= Posicione( "C87", 1, xFilial("C87") + C9V->C9V_CATCI, "C87_CODIGO" )
			cXml +=		xTafTag("codCateg" , cCodCateg			,,.T.)
		EndIf
		
		cXml +=		"</ideVinculo>"
		cXml +=		"<infoAfastamento>"

		//-- Verifico se existe término para esse afastamento
		cId 		:= CM6->CM6_ID
		cVerant 	:= CM6->CM6_VERANT

		aAreaCM6	:= CM6->(GetArea())
		CM6->( DbSetOrder( 1 ) )
		If CM6->( MsSeek( xFilial( 'CM6' ) + cId + cVerant ) )
			lTermAnt := !Empty(CM6->CM6_DTFAFA)
		Else
			lRegNovo := .T.
		EndIf
		RestArea(aAreaCM6)

		lFimAfast := !lTermAnt .AND. !lRegNovo .AND. !Empty( CM6->CM6_DTFAFA )

		If !Empty( CM6->CM6_DTAFAS ) .AND. !lFimAfast
			
			// Tratamento para simplificação do e-Social
			If !lLaySimplif

				lInfAtest := cCodMotAfast $ "01|03|35" .And. !lNt1519 //A partir da NT 15/2019, essa regra se tornou obsoleta

				If T6M->(MsSeek(xFilial("T6M") + CM6->(CM6_ID+CM6_VERSAO)))

					While T6M->( !Eof()) .And. T6M->(T6M_FILIAL+T6M_ID+T6M_VERSAO) == xFilial("CM6")+CM6->(CM6_ID+CM6_VERSAO)

						CM7->( DbSetOrder( 1 ) )
						CM7->( MsSeek ( xFilial("CM7")+T6M->T6M_IDPROF) )

						xTafTagGroup("emitente"    , {{ "nmEmit",CM7->CM7_NOME												,,.F. };
												,  { "ideOC" ,CM7->CM7_IDEOC			                                   	,,.F. };
												,  {	"nrOc" ,CM7->CM7_NRIOC                                  			,,.F. };
												,  {	"ufOC" ,POSICIONE("C09",3, xFilial("C09")+CM7->CM7_NRIUF,"C09_UF")	,,.T. }};
												,  @cXmlEmi,,IIF(lNt1519,.F.,cCodMotAfast == "01"))

						xTafTagGroup("infoAtestado", {{ "codCID",StrTran(POSICIONE("CMM",1, xFilial("CMM")+T6M->T6M_CODCID,"CMM_CODIGO"),".",""),,.T. };
												,  { "qtdDiasAfast",T6M->T6M_DIASAF			                                  				,,lNt1519,,lInfAtest }};
												,  @cXmlAtes, { {"emitente", cXmlEmi, 0 } },lInfAtest)

						T6M->(DbSkip())

						//Zero as variaveis
						cXmlEmi 	:= ""

					EndDo

				ElseIf !lNt1519

					xTafTagGroup("emitente", {{ "nmEmit","",,.F. };
										,  { "ideOC" ,"",,.F. };
										,  {	"nrOc"  ,"",,.F. };
										,  {	"ufOC"  ,"",,.T. }};
										,  @cXmlEmi,,cCodMotAfast == "01")

					xTafTagGroup("infoAtestado", {{ "codCID"      ,"",,.T. };
											,  { "qtdDiasAfast",0 ,,!lNt1519,,lInfAtest }};
											,  @cXmlAtes, { {"emitente", cXmlEmi, 0 } },lInfAtest)
					
				EndIf

			EndIf
			
			// Tratamento para simplificação do e-Social
			If lLaySimplif
			
				xTafTagGroup("perAquis"		, {{ "dtInicio"		,CM6->CM6_PERINI									    ,,.F. };
												,  { "dtFim"		,CM6->CM6_PERFIM			                        ,,.T. }};
												,  @cXmlPer )
				
			EndIf

			xTafTagGroup("infoCessao"		, {{ "cnpjCess"		,CM6->CM6_CNPJCE									    ,,.F. };
												,  { "infOnus"		,CM6->CM6_INFOCE			                         ,,.F. }};
												,  @cXmlCes )

			xTafTagGroup("infoMandSind"		, {{ "cnpjSind"		,CM6->CM6_CNPJSD										,,.F. };
												,  { "infOnusRemun"	,CM6->CM6_INFOSD			                     	,,.F. }};
												,  @cXmlMan )

			// Tratamento para simplificação do e-Social
			If lLaySimplif

				xTafTagGroup("infoMandElet"		, {{ "cnpjMandElet"		,CM6->CM6_CNPJME										,,.F. };
													,  { "indRemunCargo"	,CM6->CM6_REMCAR			                     	,,.F. }};
													,  @cXmlElet )

			EndIf

			//Posiciono no processo judicial
			C1G->( DbSetOrder( 8 ) )
			C1G->(MsSeek(xFilial("C1G") + CM6->CM6_IDPROC + "1"))

			//Inverto os códigos para atender o layout do eSocial
			If !Empty( C1G->C1G_TPPROC )
				If Alltrim(C1G->C1G_TPPROC) == "1"
					cTpProc := "2"
				ElseIf Alltrim(C1G->C1G_TPPROC) == "2"
					cTpProc := "1"
				Else
					cTpProc := C1G->C1G_TPPROC
				EndIf
			EndIf

			// Tratamento para simplificação do e-Social
			If !lLaySimplif

				xTafTagGroup("iniAfastamento"	, {{ "dtIniAfast"			,CM6->CM6_DTAFAS	 								,,.F. };
													,  { "codMotAfast"		,cCodMotAfast			                        	,,.F. };
													,  { "infoMesmoMtv"		,xFunTrcSN(CM6->CM6_INFMTV,1)			          	,,.T. };
													,  { "tpAcidTransito"	,CM6->CM6_TPACID		                            ,,.T. };
													,  { "observacao"		,AllTrim(CM6->CM6_OBSERV)              				,,.T. }};
													,  @cXml, { {"infoAtestado", cXmlAtes, 0 }, {"infoCessao", cXmlCes, 0 }, {"infoMandSind", cXmlMan, 0 }} )

			Else

				xTafTagGroup("iniAfastamento"	, {{ "dtIniAfast"			,CM6->CM6_DTAFAS	 								,,.F. };
													,  { "codMotAfast"		,cCodMotAfast			                        	,,.F. };
													,  { "infoMesmoMtv"		,xFunTrcSN(CM6->CM6_INFMTV,1)			          	,,.T. };
													,  { "tpAcidTransito"	,CM6->CM6_TPACID		                            ,,.T. };
													,  { "observacao"		,AllTrim(CM6->CM6_OBSERV)             				,,.T. }};
													,  @cXml, { {"perAquis", cXmlPer, 0 }, {"infoCessao", cXmlCes, 0 }, {"infoMandSind", cXmlMan, 0 }, {"infoMandElet", cXmlElet, 0 }} )

			EndIf

			//Gero o grupo de TAG <infoRetif> somente para retificação
			If lTermAnt .OR. Empty(CM6->CM6_DTFAFA)

				xTafTagGroup("infoRetif"			, {{ "origRetif"		,CM6->CM6_ORIRET	,,.F. };
													,  { "tpProc"			,cTpProc			,,.T. };
													,  { "nrProc"			,C1G->C1G_NUMPRO	,,.T. }};
													,  @cXml)
			EndIf

		EndIf

		If !Empty( CM6->CM6_DTFAFA )
			cXml +=			"<fimAfastamento>"
			cXml +=				xTafTag("dtTermAfast"	,CM6->CM6_DTFAFA)
			cXml +=			"</fimAfastamento>"
		EndIf

		cXml +=		"</infoAfastamento>"

		//------------------------
		//³Estrutura do cabecalho
		//------------------------
		cXml := xTafCabXml(cXml,"CM6",cLayout,cReg,,cSeqXml)

		//------------------------------
		//³Executa gravacao do registro
		//------------------------------
		If !lJob
			xTafGerXml(cXml,cLayout)
		EndIf

		cFilAnt := cFilBkp

	EndIf

Return(cXml)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF261Grv
Funcao de gravacao para atender o registro S-2230

@parametros
cLayout - Nome do Layout que esta sendo enviado, existem situacoes onde o mesmo fonte
alimenta mais de um regsitro do E-Social, para estes casos serao necessarios
tratamentos de acordo com o layout que esta sendo enviado.
nOpc   -  Opcao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )
cFilEv -  Filial do ERP para onde as informacoes deverao ser importadas
oXML   -  Objeto com as informacoes a serem manutenidas ( Outras Integracoes )

@Return
lRet    - Variavel que indica se a importacao foi realizada, ou seja, se as
informacoes foram gravadas no banco de dados
aIncons - Array com as inconsistencias encontradas durante a importacao
lMigrador - Informa que a origem da chamada foi através do migrador.

@author Rodrigo Aguilar
@since 27/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF261Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID,cEvtOri,lMigrador  )

	Local nlI           := 0
	Local nJ            := 0
	Local nT6M          := 0
	Local nIndIDVer     := 2
	Local nIndChv       := 10
	Local nSeqErrGrv    := 0
	Local nCM6Recno     := 0
	Local nCM6RecRetif  := 0
	Local cLogOpeAnt    := ""
	Local cCabecInfoAf  := ""
	Local cCabecIdeVinc := ""
	Local cCmpsNoUpd    := "|CM6_FILIAL|CM6_ID|CM6_VERSAO|CM6_VERANT|CM6_PROTPN|CM6_EVENTO|CM6_STATUS|CM6_ATIVO|"
	Local cChave        := ""
	Local cIdFunc       := ""
	Local cEvento       := ""
	Local cInconMsg     := ""
	Local cT6MPath      := ""
	Local cXmlMotAfast  := ""
	Local cCm6MotAfast  := ""
	Local cCodEvent     := Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")
	Local cXmlRecib     := ""
	Local cWhere        := ""
	Local cIDRetif      := ""
	Local cAliasRetif   := ""
	Local cAliasQry     := ""
	Local cRecChv		:= ""
	Local cIniAfMotv    := ""
	Local cIniAfTpAc    := ""
	Local cIniAfIfMt    := ""
	Local cIniAfPJCE    := ""
	Local cIniAfIfCE    := ""
	Local cIniAfPJSD    := ""
	Local cIniAfIfSD    := ""
	Local cIniAfPJME    := ""
	Local cIniAfRCME    := ""
	Local aIncons       := {}
	Local aRules        := {}
	Local aChave        := {}
	Local aChvTermRetif := {}
	Local aAreaCM6      := {}
	Local aFunc			:= {}
	Local aAreaSIX      := SIX->(GetArea())
	Local lRet          := .F.
	Local lFindReg      := .F.
	Local lTrasmit      := .F.
	Local lRetif        := .F.
	Local lTermAfas     := .F.
	Local lGpeLegado    := .F.                                               // Indica se trata-se de uma integração de afastamento de um registro legado do GPE, onde o predecessor não era enviado
	Local lGPEST2       := FindFunction("TAFGetST2GPE") .And. TAFGetST2GPE()
	Local dDtIniAfs     := CTOD(" / / ")
	Local dIniAfPAPI	:= CTOD(" / / ")
	Local dIniAfPAPF	:= CTOD(" / / ")
	Local oModel        := Nil
	Local cAtivo		:= "1"

	Private lVldModel   := .T.
	Private oDados      := Nil

	Default cLayout     := ""
	Default nOpc        := 1
	Default cFilEv      := ""
	Default oXML        := Nil
	Default cOwner      := ""
	Default cFilTran    := ""
	Default cPredeces   := ""
	Default nTafRecno   := 0
	Default cComplem	:=	""
	Default cGrpTran	:=	""
	Default cEmpOriGrp	:=	""
	Default cFilOriGrp	:=	""
	Default cXmlID		:=	""
	Default cEvtOri	    :=  ""
	Default lMigrador	:= .F. 

	oDados              := oXML

	//Verifica a existência do novo indice
	if Empty(Posicione("SIX",1,"CM6" + "A", "CHAVE" )) //CM6 A CM6_FILIAL+CM6_FUNC+DTOS(CM6_DTAFAS)+CM6_XMLREC
		Aadd( aIncons, STR0061 ) //"Incompatibilidade de metadados no TAF. Favor atualizar o dicionário com o último diferencial disponível."
	EndIf

	RestArea( aAreaSIX )

	If Len(aIncons) > 0
		Return { .F., aIncons }
	EndIf

	//-------------------------------------------------------------
	//Monto o cabeçalho do evento para tratar os campos posteriores
	//-------------------------------------------------------------
	cCabecIdeVinc	:= "/eSocial/evtAfastTemp/ideVinculo"
	cCabecInfoAf	:= "/eSocial/evtAfastTemp/infoAfastamento"
	cCabecIdeEve	:= "/eSocial/evtAfastTemp/ideEvento"

	//A informação enviada em nrRecibo pode ser o protocolo do registro que deseja retificar ou
	//a chave do registro ( alternativa de integração do TAF com o ERP de origem não tem o protocolo )
	cRecChv  	:= oDados:XPathGetNodeValue( "/eSocial/evtAfastTemp/ideEvento/nrRecibo" )

	//--------------------------------------------------------------------------------------------------------------
	//Verifico quais são as informações recebidas no XML de Afastamento ( COMP=Completo, INIC=Início, TERM=Término )
	//--------------------------------------------------------------------------------------------------------------
	If oDados:XPathHasNode( cCabecInfoAf + "/iniAfastamento/dtIniAfast" ) .And. oDados:XPathHasNode( cCabecInfoAf + "/fimAfastamento/dtTermAfast" ) //Se for recebido o início e término no mesmo XML
		cXmlRecib := "COMP"
	ElseIf oDados:XPathHasNode( cCabecInfoAf + "/iniAfastamento/dtIniAfast" ) //Se for recebido início no XML
		cXmlRecib := "INIC"
	ElseIf oDados:XPathHasNode( cCabecInfoAf + "/fimAfastamento/dtTermAfast" ) //Se for recebido término no XML
		cXmlRecib := "TERM"
	EndIf

	If cXmlRecib == "TERM"
		If lMigrador
			nIndChv := 9
		Else 
			nIndChv			:= Iif( (IsInCallStack("GPEA240") .Or. IsInCallStack("GPEM026B")) .And. !lGPEST2 , 9, 10 )
		Endif 
	EndIf

	lGpeLegado := nIndChv == 9

	//------------------------------------------------------------------
	// Verifico se a operação que o usuário enviou no XML é retificação
	//------------------------------------------------------------------
	If oDados:XPathHasNode( cCabecIdeEve + "/indRetif" )
		If FTafGetVal( cCabecIdeEve + "/indRetif", "C", .F., @aIncons, .F. ) == '2'
			lRetif := .T.
		EndIf
	EndIf

	//---------------------------------------------------------------------------------------------------------------------------
	//Chave do registro - De acordo com o layout é somente o campo de CPF, sendo assim considero somente esse campo na integração
	//---------------------------------------------------------------------------------------------------------------------------
	If !Empty( FTafGetVal( cCabecIdeVinc +"/cpfTrab", "C", .F., @aIncons, .F. ) )

		aFunc 	:= TAFIdFunc(FTafGetVal( cCabecIdeVinc + "/cpfTrab", "C", .F., @aIncons, .F. ), FTafGetVal( cCabecIdeVinc + "/matricula", "C", .F., @aIncons, .F. ), @cInconMsg, @nSeqErrGrv)
		cIdFunc := aFunc[1]

		//--------------------------------------------
		//Caso o trabalhador não exista na base do TAF
		//--------------------------------------------
		If Empty( cIdFunc )
			If !Empty(cInconMsg)
				Aadd( aIncons, cInconMsg ) // Grava na TAFXERP a mensagem de inconsistência retornada pelo FGetIdInt
			Else
				Aadd( aIncons, STR0023   ) // "O trabalhador enviado nesse afastamento não existe na base de dados do TAF."
			EndIf
			Return { .F., aIncons }
		Endif

		If TrabIniAfa( cFilEv, cCabecIdeVinc, cPredeces, @aIncons, .F., lGpeLegado ) .and. TrabSemAfa( cIDFunc ) .And. cXmlRecib <> "TERM"
			aAdd( aIncons, "Esse trabalhador iniciou o esocial afastado, verifique o envio do término deste afastamento." )
			Return{ .F., aIncons }
		EndIf

		/*
		Caso o cliente tenha utilizado o migrador 
		para integrar o INICIO do Afastamento ao enviar o TERMINO por um novo ERP TOTVS
		não teremos o predecessor, portanto iremos entender que este Termino refere-se ao
		primeiro inicio ativo encontrado.
		*/
		If nTafRecno == 0
			nTafRecno := GetV2ARecno( FTafGetVal( cCabecIdeVinc + "/cpfTrab", "C", .F., @aIncons, .F. ), FTafGetVal( cCabecIdeVinc + "/matricula", "C", .F., @aIncons, .F. ))
			lGpeLegado := .T.			
		EndIf

		DbSelectArea("CM6")

		//Posiciono o registro para pegar a área
		aAreaCM6 := CM6->( GetArea() )
		
		If nTafRecno > 0 // Caso a integracao venha do GPE o nTafRecno virá em branco.
		
			//Posiciono na CM6 e pego a data de início
			CM6->(DBGoTo(nTafRecno))
		
			If lRetif .AND. Empty(cRecChv)

				nCM6RecRetif	:= nTafRecno
				cIDRetif		:= CM6->CM6_ID
				cIDFunc      	:= CM6->CM6_FUNC	
				cAliasRetif  	:= GetNextAlias()

				If cXmlRecib == "TERM"

					//tratamento para preencher o campo com o id do inicio do primeiro afastamento atvio
					BeginSql Alias cAliasRetif

						SELECT MAX(CM6.R_E_C_N_O_) RECNOCM6
							FROM %table:CM6% CM6
							WHERE CM6.CM6_FILIAL	= %xfilial:CM6% 
								AND	CM6.CM6_FUNC    = %exp:cIDFunc%
								AND CM6.CM6_XMLREC  = 'INIC'
								AND CM6.CM6_EVENTO	!= 'E'
								AND	CM6.%notDel%

					EndSql

				Else

					BeginSql Alias cAliasRetif

						SELECT MAX(CM6.R_E_C_N_O_) RECNOCM6
							FROM %table:CM6% CM6
							WHERE CM6.CM6_FILIAL	= %xfilial:CM6% 
								AND	CM6.CM6_ID      = %exp:cIDRetif%
								AND CM6.CM6_XMLREC  = %exp:cXmlRecib%
								AND CM6.CM6_EVENTO  != 'E'
								AND	CM6.%notDel%

					EndSql

				EndIf	

				(cAliasRetif)->(DbGoTop())
				
				If (cAliasRetif)->(!Eof())

					CM6->(DBGoTo((cAliasRetif)->RECNOCM6))

					dDtIniAfs	:= CM6->CM6_DTAFAS
					cAtivo 		:= CM6->CM6_ATIVO

				EndIf
				
				(cAliasRetif)->(DbCloseArea())

			Else

				dDtIniAfs	:= CM6->CM6_DTAFAS
				cAtivo		:= CM6->CM6_ATIVO

			EndIf
		
		ElseIf !Empty(cRecChv)

			CM6->(DBSetOrder(4)) // CM6_FILIAL+CM6_PROTUL+CM6_ATIVO     

			If CM6->(MsSeek(FTafGetFil(cFilEv, @aIncons, "CM6") + cRecChv))  

				dDtIniAfs := CM6->CM6_DTAFAS
				cAtivo := CM6->CM6_ATIVO

			EndIf

		Else

			If cXmlRecib == "TERM"

				cAliasRetif := GetNextAlias()

				BeginSql Alias cAliasRetif

					SELECT MAX(CM6.R_E_C_N_O_) RECNOCM6
						FROM %table:CM6% CM6
						WHERE CM6.CM6_FILIAL	= %xfilial:CM6% 
							AND	CM6.CM6_FUNC    = %exp:cIDFunc%
							AND CM6.CM6_XMLREC  = 'INIC'
							AND CM6.CM6_EVENTO	!= 'E'
							AND	CM6.%notDel%

				EndSql

				(cAliasRetif)->(DbGoTop())
				
				If (cAliasRetif)->(!Eof())

					CM6->(DBGoTo((cAliasRetif)->RECNOCM6))

					dDtIniAfs	:= CM6->CM6_DTAFAS
					cAtivo 		:= CM6->CM6_ATIVO

				EndIf
				
				(cAliasRetif)->(DbCloseArea())

			Else

				dDtIniAfs := FTafGetVal(cCabecInfoAf + "/iniAfastamento/dtIniAfast", "D", .F., @aIncons, .F.)

			EndIf	

		EndIf
		
		RestArea( aAreaCM6 )

		//Monto a chave do afastamento
		Aadd( aChave, { "C", "CM6_FUNC", cIdFunc, .T. } )
		If nIndChv <> 9 
			Aadd( aChave, { "D", "CM6_DTAFAS", dDtIniAfs, .T. } )
		EndIf
		
		cChave	:= Padr( cIdFunc,	 TamSX3( aChave[ 1, 2 ] )[1] )
		If  nIndChv <> 9 
			cChave	+= DTOS( dDtIniAfs )
		EndIf
		
	//------------------------------------------------------------------------------------------------------------------
	//Caso esteja vazia não foi enviada a TAG refente a chave única do evento ( CPF ), sendo assim rejeito a integração
	//------------------------------------------------------------------------------------------------------------------
	Else
		Aadd( aIncons, STR0024 ) // "Não é possível realizar a integração pois não foi enviado o CPF do trabalhador ao qual se refere o afastamento na TAG <cpfTrab >."
		Return { .F., aIncons }

	EndIf

	lFindReg   := .F. //Indica que já existe um afastamento prévio na base de dados do TAF
	lTrasmit   := .F. //Indica que o afastamento encontrado já foi transmitido para o Governo

	//----------------------------------------------------------------
	//Se for retificação, acrescento o campo XML recebido na chave
	//----------------------------------------------------------------
	If lRetif .Or. cXmlRecib == "COMP"
		If cXmlRecib == "TERM" .And. Empty(cRecChv)
			
			cChave        := cChave + "INIC"
			aChvTermRetif := aChave
			
			If TafColumnPos( "CM6_XMLREC" )
				Aadd( aChave       , { "C", "CM6_XMLREC", "INIC"    , .T. } )
				Aadd( aChvTermRetif, { "C", "CM6_XMLREC", cXmlRecib , .T. } )
			EndIf
			
		Else
			// Caso a retificação seja do registro de término, deverá ser posicionado no registro de início.
			cChave	:= cChave +  cXmlRecib
			If TafColumnPos( "CM6_XMLREC" )
				Aadd( aChave, { "C", "CM6_XMLREC", cXmlRecib, .T. } )
			EndIf
		EndIf
	else
		If cXmlRecib == "TERM" .And. Empty(cRecChv)
		
			If nIndChv <> 9
				cChave        := cChave + "INIC"
			EndIf
		
		EndIf
	EndIf

	//----------------------------------------------------------------
	//Verifico se já existe um evento para o trabalhador no TAF
	//----------------------------------------------------------------
	If cXmlRecib == "COMP" 
		CM6->( DbSetOrder( nIndChv ) )
		If CM6->( MsSeek( FTafGetFil( cFilEv , @aIncons , "CM6" ) + cChave + '1'  ) )

			lFindReg  	:= .T.
			lTrasmit	:= Iif( CM6->CM6_STATUS == '4', .T., .F. )

		EndIf

	Else
		If nIndChv == 9
			cChave := AllTrim(cChave)
		EndIf

		CM6->( DBSetOrder( nIndChv ) )

		If CM6->( MsSeek( FTafGetFil( cFilEv , @aIncons , "CM6" ) + cChave + cAtivo) ) .AND. CM6->CM6_EVENTO <> "E"

			//-----------------------------------------------------
			//Monto a chave de pesquisa
			//-----------------------------------------------------
			
			//PARA FAZER A  CHAVE DE UM EVENTO DE RETIFICAÇÃO DE TERMINO
			if lRetif == .T. .AND. cXmlRecib == "TERM"

					cWhere		:= "% CM6.D_E_L_E_T_ = '' "
					cWhere		+= " AND CM6.CM6_FILIAL = '" + xFilial( "CM6" ) + "' "
					cWhere      += " AND CM6.CM6_FUNC = '" + CM6->CM6_FUNC + "'"
					cWhere      += " AND CM6.CM6_EVENTO != 'E' "

			Else

				cWhere		:= "% CM6.D_E_L_E_T_ = '' "
				cWhere		+= " AND CM6.CM6_FILIAL = '" + xFilial( "CM6" ) + "' "
				cWhere      += " AND CM6.CM6_ID = '" + CM6->CM6_ID + "'"
				cWhere      += " AND (CM6.CM6_EVENTO != 'E' AND CM6.CM6_ATIVO != '2') " 

			EndIf

			If lRetif
				If TafColumnPos( "CM6_XMLREC" )
					cWhere      += " AND CM6.CM6_XMLREC = '" + cXmlRecib + "'"
				EndIf
			EndIf
			
			cWhere += "%"
			
			cAliasQry := GetNextAlias()
			
			BeginSql Alias cAliasQry
				SELECT MAX(CM6.R_E_C_N_O_) RECNOCM6
				FROM %table:CM6% CM6
				WHERE %EXP:cWhere%
			EndSql
			
			(cAliasQry)->(DbGoTop())
		
			If (cAliasQry)->(!Eof())
				lFindReg  	:= .T.
				nCM6Recno   := (cAliasQry)->RECNOCM6
				CM6->( DBGoTo( nCM6Recno ) )
				lTrasmit	:= Iif( CM6->CM6_STATUS == '4', .T., .F. )
				If !lTrasmit
					cIniAfMotv := CM6->CM6_MOTVAF
					cIniAfTpAc := CM6->CM6_TPACID
					cIniAfIfMt := CM6->CM6_INFMTV
					cIniAfPJCE := CM6->CM6_CNPJCE
					cIniAfIfCE := CM6->CM6_INFOCE
					cIniAfPJSD := CM6->CM6_CNPJSD
					cIniAfIfSD := CM6->CM6_INFOSD

					// Tratamento para simplificação do e-Social
					If lLaySimplif

						dIniAfPAPI := CM6->CM6_PERINI
						dIniAfPAPF := CM6->CM6_PERFIM
						cIniAfPJME := CM6->CM6_CNPJME
						cIniAfRCME := CM6->CM6_REMCAR

					EndIf

				EndIf
			EndIf
			
			(cAliasQry)->(DbCloseArea())

			If TafColumnPos( "CM6_XMLREC" )
				If (!lTrasmit .Or. lRetif) .AND. cXmlRecib == "TERM" .AND. CM6->CM6_XMLREC == "INIC"
					lTermAfas := .T.
				EndIf
			EndIf

		EndIf
	EndIf

	//------------------------------------------------------------
	//Cenário onde não existe um afastamento prévio na base do TAF
	//------------------------------------------------------------
	If !lFindReg

		Do Case

			Case lRetif //Se foi enviada uma retificação no XML
				If ( Empty(cPredeces) .AND. nTafRecno == 0 ) .OR. Empty(cRecChv)
					Aadd( aIncons, STR0064) //"Não foi possível realizar a integração desse afastamento pois o mesmo foi enviado como sendo uma retificação ( TAG <indRetif> igual a '2'  ) 
											// e não foi informado o predecessor ou o número do recibo do afastamento prévio desse trabalhador no TAF para ser retificado."
				Else
					Aadd( aIncons, STR0025) // "Não é possível realizar a integração desse afastamento pois o mesmo foi enviado como sendo uma retificação
											//( TAG <indRetif> igual a '2'  ) e não existe nenhum afastamento prévio desse trabalhador no TAF para ser retificado."
				EndIf

			Case oDados:XPathHasNode( cCabecInfoAf + "/iniAfastamento/dtIniAfast" ) .And. oDados:XPathHasNode( cCabecInfoAf + "/fimAfastamento/dtTermAfast" ) //Se for enviado início e término no mesmo XML
				cEvento := 'F'

				If oDados:XPathHasNode( cCabecInfoAf + "/infoRetif/origRetif" ) //Se for enviada a TAG de retificação junto com o início sem ser uma retificação
					Aadd( aIncons, STR0026) //"Foi enviado o grupo de TAG <infoRetif> (Informações de retificação do Afastamento Temporário), só é possível a integração dessa
											//informação quando estiver sendo retificado um afastamento já existente no TAF."

				EndIf

			Case oDados:XPathHasNode( cCabecInfoAf + "/iniAfastamento/dtIniAfast" ) //Se foram enviadas informações de início de um novo afastamento
				cEvento := 'I'

				If oDados:XPathHasNode( cCabecInfoAf + "/infoRetif/origRetif" ) //Se for enviada a TAG de retificação junto com o início sem ser uma retificação
					Aadd( aIncons, STR0026) //"Foi enviado o grupo de TAG <infoRetif> (Informações de retificação do Afastamento Temporário), só é possível a integração dessa
											//informação quando estiver sendo retificado um afastamento já existente no TAF."

				Else

					/*-----------------------------------------------------------------------------------------
					//Verifico se existe um trabalhador cadastrado no S-2200 com data de afastamento
					//preenchido, esse cenário se aplica para trabalhadores que já entraram no e-Social afastados
					/-------------------------------------------------------------------------------------------*/
					C9V->( dbSetOrder( 12 ) ) //C9V_FILIAL+C9V_CPF+C9V_MATRIC+C9V_ATIVO
					If !C9V->( MsSeek( FTafGetFil( cFilEv , @aIncons , "C9V" ) + Padr(Alltrim( FTafGetVal( cCabecIdeVinc + "/cpfTrab"  , "C", .F., @aIncons, .F. ) ), TamSX3("C9V_CPF")[1] ) + Padr(Alltrim( FTafGetVal( cCabecIdeVinc + "/matricula", "C", .F., @aIncons, .F. ) ), TamSX3("C9V_MATRIC")[1] ) + '1') )
						Aadd( aIncons, STR0028) //"Trabalhador não encontrado na base do TAF com o CPF informado."
					EndIf
					C9V->( dbSetOrder( 16 ) )

				EndIf

			Case oDados:XPathHasNode( cCabecInfoAf + "/infoRetif/origRetif" ) //Se foi enviada apenas a TAG referente a retificação do motivo de afastamento

				/*---------------------------------------------------------------------------------------------------------------------------
				//Esse grupo de informações <infoRetif > somente pode ser enviado junto com o grupo <iniAfastamento>, sendo assim, caso entre
				//nesse CASE significa que a TAG <iniAfastamento> não foi enviada e assim a integração não poderá ser realizada
				/-----------------------------------------------------------------------------------------------------------------------------*/
				Aadd( aIncons, STR0029) //"Foi enviada somente a TAG <infoRetif>, para que uma retificação dessa natureza seja aceita
											//é necessário que o grupo de <iniAfastamento> também seja enviado na mensagem."

			Case oDados:XPathHasNode( cCabecInfoAf + "/fimAfastamento/dtTermAfast" ) //Se foi enviada apenas a TAG referente ao término do afastamento

				cEvento := 'F'

				TrabIniAfa( cFilEv, cCabecIdeVinc, cPredeces, @aIncons, .T., lGpeLegado )

		EndCase

		//-----------------------------------------------------------------------------------------------------------------------------
		//Se não encontrou nenhum problema nas validações acima eu realizo a operação de incluir um novo registro na base, independente
		//do cenário que entrou nas regras acima , como não existe registro prévio de afastamento no TAF a operação a ser realizada
		//deve ser uma inclusão
		//-----------------------------------------------------------------------------------------------------------------------------
		If Empty( aIncons )
			nOpc := 3
		EndIf

	//--------------------------------------------------------
	//Cenário onde existe um afastamento prévio na base do TAF
	//--------------------------------------------------------
	Else

		Do Case

			Case lRetif //Se foi enviada uma retificação no XML

				If oDados:XPathHasNode( cCabecInfoAf + "/infoRetif/origRetif" ) //Se for enviada a TAG de retificação do motivo

					//------------------------------------------------------------------------------------------------------------
					//De acordo com o MOS do e-Social essa TAG só pode ser enviada quando for alterado o motivo de afastamento do
					//código 01 para 03 e vice-versa
					//------------------------------------------------------------------------------------------------------------
					If oDados:XPathHasNode( cCabecInfoAf + "/iniAfastamento/codMotAfast" )

						cXmlMotAfast := Alltrim( FTafGetVal( cCabecInfoAf + "/iniAfastamento/codMotAfast", "C", .F., @aIncons, .F. ) )  //Motivo enviado no XML
						cCm6MotAfast := Alltrim( Posicione( "C8N", 1, xFilial("C8N") + CM6->CM6_MOTVAF, "C8N_CODIGO" ) ) 				//Motivo atual do afastamento

						If !( ( cXmlMotAfast == '01' .And. cCm6MotAfast == '03' ) .Or. ( cXmlMotAfast == '03' .And. cCm6MotAfast == '01' ) )
							Aadd( aIncons, STR0032) //"Somente deve ser enviada a TAG <infoRetif> quando o motivo de afastamento for alterado de 01 para
													//03 ou vice-versa, por não ser o caso desse afastamento o mesmo não pode ser integrado com o TAF."

						EndIf

					Else
						Aadd( aIncons, STR0033) //"A TAG <infoRetif> somente deve ser enviada quando também existir a TAG <codMotAfast> no mesmo XML
												//identificando o novo código de motivo de afastamento."

					EndIf

				EndIf

				//---------------------------------------------------------------------------------------
				//Se o evento vigente no TAF já estiver sido transmitido ao Governo eu faço a retificação,
				//caso contrário eu apenas faço a alteração no TAF mantendo o status atual
				//---------------------------------------------------------------------------------------
				If lTrasmit
					cEvento := 'R'

				ElseIf cXmlRecib == "TERM"
					cEvento := 'F'
				Else
					cEvento := CM6->CM6_EVENTO //Mantenho o evento corrente na base do TAF apenas alterando as informações de acordo com o XML enviado

				EndIf

			Case oDados:XPathHasNode( cCabecInfoAf + "/iniAfastamento/dtIniAfast" ) .And. oDados:XPathHasNode( cCabecInfoAf + "/fimAfastamento/dtTermAfast" ) //Se for enviado início e término no mesmo XML
				cEvento := 'F'

				//-----------------------------------------------------------------
				//Se o evento vigente no TAF já estiver sido transmitido ao Governo
				//-----------------------------------------------------------------
				If lTrasmit
					If oDados:XPathHasNode( cCabecInfoAf + "/infoRetif/origRetif" ) //Se for enviada a TAG de retificação junto com o início sem ser uma retificação
						Aadd( aIncons, STR0034) //"Foi enviada a TAG de retificação do motivo de afastamento <infoRetif>, só é possível a integração dessa
												//informação quando estiver sendo retificado um afastamento já existente no TAF."
					Else
						Aadd( aIncons, STR0062) //"Esse afastamento já foi integrado ao TAF e transmitido ao governo. Caso deseje retificá-lo, favor enviar TAG de retificação <indRetif> igual a 2."
					EndIf
				Endif

			Case oDados:XPathHasNode( cCabecInfoAf + "/iniAfastamento/dtIniAfast" ) //Se foram enviadas informações de início de um novo afastamento
			
				//-----------------------------------------------------------------
				//Se o evento vigente no TAF já existir na base de dados
				//-----------------------------------------------------------------
				If lTrasmit .AND. oDados:XPathHasNode( cCabecInfoAf + "/infoRetif/origRetif" ) //Se for enviada a TAG de retificação junto com o início sem ser uma retificação
					Aadd( aIncons, STR0037) //"Foi enviada a TAG de retificação do motivo de afastamento <infoRetif>, só é possível a integração dessa
										//informação quando estiver sendo retificado um afastamento já existente no TAF."
				Endif

			Case oDados:XPathHasNode( cCabecInfoAf + "/infoRetif/origRetif" ) //Se foi enviada apenas a TAG referente a retificação do motivo de afastamento

				/*---------------------------------------------------------------------------------------------------------------------------
				//Esse grupo de informações <infoRetif > somente pode ser enviado junto com o grupo <iniAfastamento>, sendo assim, caso entre
				//nesse CASE significa que a TAG <iniAfastamento> não foi enviada e assim a integração não poderá ser realizada
				/-----------------------------------------------------------------------------------------------------------------------------*/
				Aadd( aIncons, STR0040) //"Foi enviada somente a TAG <infoRetif>, para que uma retificação dessa natureza seja aceita
										//é necessário que o grupo de <iniAfastamento> também seja enviado na mensagem."

			Case oDados:XPathHasNode( cCabecInfoAf + "/fimAfastamento/dtTermAfast" ) //Se foi enviada apenas a TAG referente ao término do afastamento

				If lFindReg .And. CM6->CM6_XMLREC == "TERM" 
					Aadd( aIncons, STR0063) 
				else

					cEvento := "F"

					TrabIniAfa( cFilEv, cCabecIdeVinc, cPredeces, @aIncons, .T., lGpeLegado )

				EndIF
		EndCase

		//-----------------------------------------------------------------------------------------------------------------------------
		//Se não encontrou nenhum problema nas validações acima eu realizo a operação de alterar o registro na base, independente
		//do cenário que entrou nas regras acima , eu sempre vou realizar a alteração de algum dado corrente
		//-----------------------------------------------------------------------------------------------------------------------------
		If Empty( aIncons )
			nOpc := 4
		EndIf

	EndIf

	Begin Transaction

		//---------------------------------------------------------------
		//Funcao para validar se a operacao desejada pode ser realizada
		//---------------------------------------------------------------
		If Empty( aIncons ) .And. FTafVldOpe( 'CM6', nIndChv, @nOpc, cFilEv, @aIncons, IIf( Len(aChvTermRetif) > 0, aChvTermRetif, aChave ), @oModel, 'TAFA261', cCmpsNoUpd, nIndIDVer, .F.,,, IIF(!Empty(nCM6RecRetif),nCM6RecRetif,nCM6Recno), lTermAfas )

			If TafColumnPos( "CM6_LOGOPE" )
				cLogOpeAnt := CM6->CM6_LOGOPE
			EndIf

			//--------------------------------------------------------------------------
			//Caso não tenha sido transmitido o registro anterior ao RET e está
			//sendo incluído um fim de afastamento, copia os campos do registro anterior
			//--------------------------------------------------------------------------
			If !lTrasmit .AND. lTermAfas
				oModel:LoadValue( "MODEL_CM6", "CM6_DTAFAS", dDtIniAfs  )
				oModel:LoadValue( "MODEL_CM6", "CM6_MOTVAF", cIniAfMotv )
				oModel:LoadValue( "MODEL_CM6", "CM6_TPACID", cIniAfTpAc )
				oModel:LoadValue( "MODEL_CM6", "CM6_INFMTV", cIniAfIfMt )			
				oModel:LoadValue( "MODEL_CM6", "CM6_CNPJCE", cIniAfPJCE )
				oModel:LoadValue( "MODEL_CM6", "CM6_INFOCE", cIniAfIfCE )
				oModel:LoadValue( "MODEL_CM6", "CM6_CNPJSD", cIniAfPJSD )
				oModel:LoadValue( "MODEL_CM6", "CM6_INFOSD", cIniAfIfSD )

				// Tratamento para simplificação do e-Social
				If lLaySimplif

					oModel:LoadValue( "MODEL_CM6", "CM6_PERINI", dIniAfPAPI )
					oModel:LoadValue( "MODEL_CM6", "CM6_PERFIM", dIniAfPAPF )
					oModel:LoadValue( "MODEL_CM6", "CM6_CNPJME", cIniAfPJME )
					oModel:LoadValue( "MODEL_CM6", "CM6_REMCAR", cIniAfRCME )

				EndIf

				cXmlRecib := "COMP"
			EndIf

				//-----------------------------------------------------------------
				//Carrego array com os campos De/Para de gravacao das informacoes
				//-----------------------------------------------------------------
				aRules := TAF261Rul( @cInconMsg, @nSeqErrGrv, @oModel, cCodEvent, cOwner )

				//-	------------------------------------------------------------------
				//Quando se tratar de uma Exclusao direta apenas preciso realizar
				//o Commit(), nao eh necessaria nenhuma manutencao nas informacoes
				//-------------------------------------------------------------------
				If nOpc <> 5

					CM7->( dbSetOrder ( 4 ) )

					oModel:LoadValue( "MODEL_CM6", "CM6_EVENTO", cEvento )
					If TafColumnPos( "CM6_XMLREC" )
						oModel:LoadValue( "MODEL_CM6", "CM6_XMLREC", cXmlRecib )
					EndIf

					If TAFColumnPos( "CM6_XMLID" )
						oModel:LoadValue( "MODEL_CM6", "CM6_XMLID", cXmlID )
					EndIf	

					//-------------------------------------------
					//Rodo o aRules para gravar as informacoes
					//-------------------------------------------
					For nlI := 1 To Len( aRules )
						oModel:LoadValue( "MODEL_CM6", aRules[ nlI, 01 ], FTafGetVal( aRules[ nlI, 02 ], aRules[nlI, 03], aRules[nlI, 04], @aIncons, .F. ) )
					Next

					If Findfunction("TAFAltMan")
						if nOpc == 3
							TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_CM6', 'CM6_LOGOPE' , '1', '' )
						elseif nOpc == 4
							TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_CM6', 'CM6_LOGOPE' , '', cLogOpeAnt )
						EndIf
					EndIf

					// Tratamento para simplificação do e-Social
					If !lLaySimplif
					
						//------------------------------
						//T6M - Informações do Atestado
						//------------------------------
						nT6M := 1
						cT6MPath := "/eSocial/evtAfastTemp/infoAfastamento/iniAfastamento/infoAtestado[" + CVALTOCHAR(nT6M) + "]"

						If nOpc == 4
							For nJ := 1 to oModel:GetModel( 'MODEL_T6M' ):Length()
								oModel:GetModel( 'MODEL_T6M' ):GoLine(nJ)
								oModel:GetModel( 'MODEL_T6M' ):DeleteLine()
							Next nJ
						EndIf

						While oDados:XPathHasNode(cT6MPath)

							oModel:GetModel( 'MODEL_T6M' ):LVALID	:= .T.

							If nOpc == 4 .Or. nT6M > 1
								oModel:GetModel( 'MODEL_T6M' ):AddLine()
							EndIf

							oModel:LoadValue( "MODEL_T6M", "T6M_SEQUEN", STRZERO(nT6M,3) )

							If oDados:XPathHasNode( cT6MPath + "/codCID" )
								oModel:LoadValue( "MODEL_T6M", "T6M_CODCID", FGetIdInt( "codCID" , "",  cT6MPath + "/codCID",,,,@cInconMsg, @nSeqErrGrv))
							EndIf

							If oDados:XPathHasNode( cT6MPath + "/qtdDiasAfast" )
								oModel:LoadValue( "MODEL_T6M", "T6M_DIASAF", FTafGetVal( cT6MPath + "/qtdDiasAfast", "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode( cT6MPath + "/emitente/nrOc" )

								aInfoComp := {}

								If oDados:XPathHasNode( cT6MPath + "/emitente/nmEmit" )
									Aadd( aInfoComp, { "CM7_NOME", FTafGetVal( cT6MPath + "/emitente/nmEmit", "C", .F., @aIncons, .F. ) } )
								EndIf

								If oDados:XPathHasNode( cT6MPath + "/emitente/ideOC" )
									Aadd( aInfoComp, { "CM7_IDEOC", FTafGetVal( cT6MPath + "/emitente/ideOC", "C", .F., @aIncons, .F. ) } )
								EndIf

								If oDados:XPathHasNode( cT6MPath + "/emitente/ufOC" )
									Aadd( aInfoComp, { "CM7_NRIUF", FGetIdInt( "uf" , "",  cT6MPath + "/emitente/ufOC",,,,@cInconMsg, @nSeqErrGrv) } )
								EndIf

								cNrIoc := oDados:XPathGetNodeValue( cT6MPath + "/emitente/nrOc" )

								//-------------------------------------------------------------------------------------------------------------------------
								//Tratamento para que quando ja exista o médico na base realize a alteração dos dados enviados e se não existir inclua como
								//um médico novo
								//-------------------------------------------------------------------------------------------------------------------------
								If !CM7->( MsSeek( xFilial( 'CM7' ) + cNrIoc ) )
									oModel:LoadValue( "MODEL_T6M", "T6M_IDPROF", FGetIdInt( "nrOc"	, "",  cNrIoc,,.F.,aInfoComp,@cInconMsg, @nSeqErrGrv ) )

								Else
									If RecLock( 'CM7', .F. )
										For nJ := 1 to len( aInfoComp )
											&('CM7->' + aInfoComp[nJ,1] ) := aInfoComp[nJ,2]
										Next

										CM7->( MsUnlock() )
									EndIf

									oModel:LoadValue( "MODEL_T6M", "T6M_IDPROF", CM7->CM7_ID )
								EndIf

							EndIf

							nT6M++
							cT6MPath := "/eSocial/evtAfastTemp/infoAfastamento/iniAfastamento/infoAtestado[" + CVALTOCHAR(nT6M) + "]"

						EndDo

					EndIf

				EndIf
			
			//-----------------------------
			//Efetiva a operacao desejada
			//-----------------------------
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

	//-----------------------------------------------------------
	//Zerando os arrays e os Objetos utilizados no processamento
	//-----------------------------------------------------------
	aSize( aRules, 0 )
	aRules     := Nil

	aSize( aChave, 0 )
	aChave     := Nil

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF261Rul
Regras para gravacao das informacoes do registro S-2320 do E-Social

@author Rodrigo Aguilar
@since 29/10/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF261Rul( cInconMsg, nSeqErrGrv, oModel, cCodEvent, cOwner )

	Local aRull			:= {}
	Local aFunc			:= {}
	Local cCabecInfoAf	:= "/eSocial/evtAfastTemp/infoAfastamento"
	Local cCabecIdeVinc	:= "/eSocial/evtAfastTemp/ideVinculo"

	Default cInconMsg	:= ""
	Default nSeqErrGrv	:= 0
	Default oModel		:= Nil
	Default cCodEvent	:= ""
	Default cOwner		:= ""

	//Dados do Trabalhador - cpfTrab / matricula
	aFunc := TAFIdFunc(FTafGetVal( cCabecIdeVinc + "/cpfTrab", "C", .F.,, .F. ), FTafGetVal( cCabecIdeVinc + "/matricula", "C", .F.,, .F. ), @cInconMsg, @nSeqErrGrv)
	Aadd(aRull, {"CM6_FUNC", aFunc[1], "C", .T.})

	//Dados do início do afastamento - dtIniAfast
	If TafXNode( oDados , cCodEvent, cOwner, ( cCabecInfoAf + "/iniAfastamento/dtIniAfast" ))
		Aadd( aRull, { "CM6_DTAFAS", cCabecInfoAf + "/iniAfastamento/dtIniAfast"																					, "D", .F. } )
	EndIf

	//Dados do início do afastamento - codMotAfast
	If TafXNode( oDados , cCodEvent, cOwner, (cCabecInfoAf   +"/iniAfastamento/codMotAfast"))
		Aadd( aRull, {"CM6_MOTVAF", FGetIdInt( "codMotAfastamento" , "", cCabecInfoAf   +"/iniAfastamento/codMotAfast",,,,@cInconMsg, @nSeqErrGrv ) 	,"C", .T.} )
	EndIf

	//Dados do início do afastamento - infoMesmoMtv
	If TafXNode( oDados, cCodEvent, cOwner, (cCabecInfoAf + "/iniAfastamento/infoMesmoMtv"))
		cInfMtv := oDados:XPathGetNodeValue( cCabecInfoAf + "/iniAfastamento/infoMesmoMtv" )
		Aadd( aRull, {"CM6_INFMTV", Iif( cInfMtv == 'N', '2', '1' ), "C", .T. } )
	EndIf

	//Dados do início do afastamento - tpAcidTransito
	If TafXNode( oDados, cCodEvent, cOwner, (cCabecInfoAf + "/iniAfastamento/tpAcidTransito"))
		Aadd( aRull, {"CM6_TPACID", cCabecInfoAf + "/iniAfastamento/tpAcidTransito"					    														, "C", .F. } )
	EndIf

	//Dados do início do afastamento - observacao
	If TafXNode( oDados, cCodEvent, cOwner, (cCabecInfoAf + "/iniAfastamento/observacao"))
		Aadd( aRull, {"CM6_OBSERV", cCabecInfoAf + "/iniAfastamento/observacao"																					, "C", .F. } )
	EndIf

	//Dados do início do afastamento - cnpjCess
	If TafXNode( oDados, cCodEvent, cOwner, ( cCabecInfoAf + "/iniAfastamento/infoCessao/cnpjCess"))
		Aadd( aRull, {"CM6_CNPJCE", cCabecInfoAf + "/iniAfastamento/infoCessao/cnpjCess"												   							, "C", .F. } )
	EndIf

	//Dados do início do afastamento - infOnus
	If TafXNode( oDados, cCodEvent, cOwner, (cCabecInfoAf + "/iniAfastamento/infoCessao/infOnus"))
		Aadd( aRull, {"CM6_INFOCE", cCabecInfoAf + "/iniAfastamento/infoCessao/infOnus"				   									   						, "C", .F. } )
	EndIf

	// Tratamento para simplificação do e-Social
	If lLaySimplif

		//Dados do início do afastamento - dtInicio
		If TafXNode( oDados, cCodEvent, cOwner, ( cCabecInfoAf + "/iniAfastamento/perAquis/dtInicio"))
			Aadd( aRull, {"CM6_PERINI", cCabecInfoAf + "/iniAfastamento/perAquis/dtInicio"												   							, "D", .F. } )
		EndIf

		//Dados do início do afastamento - dtFim
		If TafXNode( oDados, cCodEvent, cOwner, (cCabecInfoAf + "/iniAfastamento/perAquis/dtFim"))
			Aadd( aRull, {"CM6_PERFIM", cCabecInfoAf + "/iniAfastamento/perAquis/dtFim"				   									   						, "D", .F. } )
		EndIf

	EndIf

	//Dados do início do afastamento - cnpjSind
	If TafXNode( oDados, cCodEvent, cOwner, (cCabecInfoAf + "/iniAfastamento/infoMandSind/cnpjSind"))
		Aadd( aRull, {"CM6_CNPJSD", cCabecInfoAf + "/iniAfastamento/infoMandSind/cnpjSind"									   		 	   						, "C", .F. } )
	EndIf

	//Dados do início do afastamento - infOnusRemun
	If TafXNode( oDados, cCodEvent, cOwner, (cCabecInfoAf + "/iniAfastamento/infoMandSind/infOnusRemun"))
		Aadd( aRull, {"CM6_INFOSD", cCabecInfoAf + "/iniAfastamento/infoMandSind/infOnusRemun"										       					, "C", .F. } )
	EndIf

	// Tratamento para simplificação do e-Social
	If lLaySimplif

		//Dados do início do afastamento - cnpjMandElet
		If TafXNode( oDados, cCodEvent, cOwner, (cCabecInfoAf + "/iniAfastamento/infoMandElet/cnpjMandElet"))
			Aadd( aRull, {"CM6_CNPJME", cCabecInfoAf + "/iniAfastamento/infoMandElet/cnpjMandElet"									   		 	   						, "C", .F. } )
		EndIf

		//Dados do início do afastamento - indRemunCargo
		If TafXNode( oDados, cCodEvent, cOwner, (cCabecInfoAf + "/iniAfastamento/infoMandElet/indRemunCargo"))
			Aadd( aRull, {"CM6_REMCAR", cCabecInfoAf + "/iniAfastamento/infoMandElet/indRemunCargo"										       					, "C", .F. } )
		EndIf

	EndIf

	//Dados das informações do afastamento - origRetif
	If TafXNode( oDados, cCodEvent, cOwner, (cCabecInfoAf + "/infoRetif/origRetif"))
		Aadd( aRull, {"CM6_ORIRET", cCabecInfoAf + "/infoRetif/origRetif"									   		 	   							 				, "C", .F. } )
	EndIf

	//Dados das informações do afastamento - tpProc
	If TafXNode( oDados, cCodEvent, cOwner, (cCabecInfoAf + "/infoRetif/tpProc")) .OR. TafXNode( oDados , cCodEvent, cOwner, (cCabecInfoAf + "/infoRetif/nrProc"))
		Aadd( aRull, {"CM6_IDPROC", FGetIdInt("tpProc", "nrProc", cCabecInfoAf + "/infoRetif/tpProc", cCabecInfoAf + "/infoRetif/nrProc",,,@cInconMsg, @nSeqErrGrv),	"C", .T.} )
	EndIf

	//Dados do término do afastamento - dtTermAfast
	If TafXNode( oDados, cCodEvent, cOwner, (cCabecInfoAf + "/fimAfastamento/dtTermAfast"))
		Aadd( aRull, {"CM6_DTFAFA", cCabecInfoAf + "/fimAfastamento/dtTermAfast"																					, "D", .F. } )
	EndIf

Return ( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function é chamada pelo TafIntegraESocial

@Return .T.

@Author Vitor Henrique Ferreira
@Since 30/06/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )

	Local cVerAnt    := ""
	Local cProtocolo := ""
	Local cVersao    := ""
	Local cEvento    := ""
	Local nlY        := 0
	Local nlI        := 0
	Local nT6M       := 0
	Local aGrava     := {}
	Local aGravaT6M  := {}
	Local oModelCM6  := Nil
	Local oModelT6M  := Nil

	Default oModel   := Nil
	Default nRecno   := 1
	Default lRotExc  := .F.

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	//Abro as tabelas
	dbSelectArea("CM6")
	dbSelectArea("T6M")

	Begin Transaction

		//Posiciona o item
		("CM6")->( DBGoTo( nRecno ) )

		oModelCM6 := oModel:GetModel( 'MODEL_CM6' )
		
		// Tratamento para simplificação do e-Social
		If !lLaySimplif

			oModelT6M := oModel:GetModel( 'MODEL_T6M' )

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco a versao anterior do registro para gravacao do rastro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVerAnt	:= oModelCM6:GetValue( "CM6_VERSAO" )
		cProtocolo	:= oModelCM6:GetValue( "CM6_PROTUL" )
		cEvento	:= oModelCM6:GetValue( "CM6_EVENTO" )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Neste momento eu gravo as informacoes que foram carregadas       ³
		//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
		//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
		//³nao devem ser consideradas neste momento                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nlI := 1 To 1
			For nlY := 1 To Len( oModelCM6:aDataModel[ nlI ] )
				Aadd( aGrava, { oModelCM6:aDataModel[ nlI, nlY, 1 ], oModelCM6:aDataModel[ nlI, nlY, 2 ] } )
			Next
		Next

		// Tratamento para simplificação do e-Social
		If !lLaySimplif

			/*---------------------------------------------------------
			T6M - Informações do Atestado
			----------------------------------------------------------*/
			For nT6M := 1 To oModel:GetModel( 'MODEL_T6M' ):Length()
				oModel:GetModel( 'MODEL_T6M' ):GoLine(nT6M)

				If !oModel:GetModel( 'MODEL_T6M' ):IsDeleted()
					aAdd (aGravaT6M ,{oModelT6M:GetValue('T6M_SEQUEN'),;
						oModelT6M:GetValue('T6M_CODCID'),;
						oModelT6M:GetValue('T6M_DIASAF'),;
						oModelT6M:GetValue('T6M_IDPROF') })
				EndIf
			Next

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seto o campo como Inativo e gravo a versao do novo registro³
		//³no registro anterior                                       ³
		//|                                                           |
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FAltRegAnt( 'CM6', '2' )

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
			oModel:LoadValue( 'MODEL_CM6', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
		Next

		/*------------------------------------------
		T6M - Informações do Atestado
		--------------------------------------------*/
		For nT6M := 1 To Len( aGravaT6M )
			If nT6M > 1
				oModel:GetModel( 'MODEL_T6M' ):AddLine()
			EndIf
			oModel:LoadValue( "MODEL_T6M", "T6M_SEQUEN" ,	aGravaT6M[nT6M][1] )
			oModel:LoadValue( "MODEL_T6M", "T6M_CODCID" ,	aGravaT6M[nT6M][2] )
			oModel:LoadValue( "MODEL_T6M", "T6M_DIASAF" ,	aGravaT6M[nT6M][3] )
			oModel:LoadValue( "MODEL_T6M", "T6M_IDPROF" ,	aGravaT6M[nT6M][4] )
		Next

		//Busco a nova versao do registro
		cVersao := xFunGetVer()

		/*---------------------------------------------------------
		ATENCAO -> A alteracao destes campos deve sempre estar
		abaixo do Loop do For, pois devem substituir as informacoes
		que foram armazenadas no Loop acima
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_CM6", "CM6_VERSAO", cVersao )
		oModel:LoadValue( "MODEL_CM6", "CM6_VERANT", cVerAnt )
		oModel:LoadValue( "MODEL_CM6", "CM6_PROTPN", cProtocolo )
		oModel:LoadValue( "MODEL_CM6", "CM6_PROTUL", "" )

		/*---------------------------------------------------------
		Tratamento para que caso o Evento Anterior fosse de exclusão
		seta-se o novo evento como uma "nova inclusão", caso contrário o
		evento passar a ser uma alteração
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_CM6", "CM6_EVENTO", "E" )
		oModel:LoadValue( "MODEL_CM6", "CM6_ATIVO" , "1" )

		//Gravo alteração para o Extemporâneo
		If lGoExtemp
			TafGrvExt( oModel, 'MODEL_CM6', 'CM6' )
		EndIf

		FwFormCommit( oModel )
		TAFAltStat( 'CM6',"6" )

	End Transaction

Return ( .T. )

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidCM6
Validação das informações da grid referente a tabela
CM6, indicado pelos tributos da conta da parte B.

@Param		oModelCM6		- Objeto de modelo da tabela CM6
			nLine			- Linha posicionada referente ao objeto oModelCM6
			cAction		- Ação origem da causa da validação
			cIDField		- Campo posicionado referente ao objeto oModelCM6
			xValue			- Valor a ser inserido na ação
			xCurrentValue	- Valor contido no atualmente no campo

@Return	lRet		- Informa se a ação foi validada

@Author	Felipe C. Seolin
@Since		06/06/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ValidCM6( oModelCM6, cAction, cIDField, xValue )

	Local cLogErro    := ""
	Local cEvento     := ""
	Local cOriRet     := ""
	Local aAreaCM6    := CM6->( GetArea() )
	Local lRet        := .T.

	Default oModelCM6 := Nil
	Default cAction   := ""
	Default cIDField  := ""

	cEvento := Iif( Type("cOperEvnt") == "U", "U", cOperEvnt)

	If cAction == "SETVALUE"

		cOriRet	:= oModelCM6:GetValue( "CM6_ORIRET" )

		If cIDField $ "CM6_ORIRET|CM6_IDPROC" .AND. !Empty(xValue) .And. Empty(CM6->CM6_PROTUL) .And. CM6->CM6_STATUS <> "4" .And. CM6->CM6_EVENTO <> "R"
			If cEvento <> "1"
				cLogErro	:= STR0043 //"Foi informado um campo do grupo de TAGs <infoRetif> (Informações de retificação do Afastamento Temporário), esse campo deve ser informado "+;
									//"somente quando estiver sendo retificado um afastamento já existente no TAF."
				lRet	:= .F.
			EndIf
		EndIF

	EndIf

	If !Empty( cLogErro )
		Help( ,, STR0045,, cLogErro, 1, 0 ) //"Atenção"
	EndIf

	RestArea( aAreaCM6 )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Função de validação da inclusão dos dados, no momento da gravação do modelo.

@Param		oModel - Modelo de dados

@Return	lRet - Indica se o modelo é válido para gravação

@Author	Denis R. de Oliveira
@Since		10/11/2017
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ValidModel( oModel )

	Local oModelCM6  :=	Nil
	Local nOperation :=	Nil
	Local cID        := ""
	Local cDtIniAfa  := ""
	Local cDtFimAfa  := ""
	Local aAreaCM6   := CM6->( GetArea() )
	Local lRet       := .T.
	Local lFindReg   := .F.
	Local cQuery     := ""
	Local cTab       := GetNextAlias()

	Default oModel   := Nil

	oModelCM6        := oModel:GetModel( "MODEL_CM6" )
	nOperation       := oModel:GetOperation()

	CM6->( DbSetOrder( 9 ) )
	If CM6->( MsSeek( xFilial( "CM6" ) + oModelCM6:GetValue( "CM6_FUNC" ) + '1'  ) )
		lFindReg  	:= .T.
	EndIf

	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

		//Posiciono no vinculo referente ao trabalhador
		If Alltrim(C9V->C9V_NOMEVE) == "S2200"
			CUP->(DBSetOrder(1))
			CUP->( MsSeek( xFilial("CUP") + C9V->(C9V_ID + C9V_VERSAO) ) )

		ElseIf Alltrim(C9V->C9V_NOMEVE) == "S2300"
			CUU->(DBSetOrder(1))
			CUU->( MsSeek( xFilial("CUU") + C9V->(C9V_ID + C9V_VERSAO) ) )
		EndIf

		cID 		:= oModelCM6:GetValue( "CM6_FUNC" )
		cDtIniAfa	:= oModelCM6:GetValue( "CM6_DTAFAS" )
		cDtFimAfa	:= oModelCM6:GetValue( "CM6_DTFAFA" )
		
		If nOperation == MODEL_OPERATION_INSERT
		
			If (lRet)
				cQuery := "SELECT T0.R_E_C_N_O_" + CRLF
				cQuery += "FROM " + RetSQLName("CM6") + " T0" + CRLF
				cQuery += "WHERE T0.CM6_FILIAL = '" + xFilial("CM6") + "'" + CRLF
				cQuery += "	AND T0.CM6_FUNC = '" + cID + "'" + CRLF
				cQuery += "	AND T0.CM6_DTAFAS = '" + DToS(cDtIniAfa) + "'" + CRLF
				cQuery += "	AND T0.CM6_DTFAFA = '" + DToS(cDtFimAfa) + "'" + CRLF
				cQuery += "	AND T0.CM6_ATIVO = '1'" + CRLF
				cQuery += "	AND T0.D_E_L_E_T_ = ' '"

				cQuery := ChangeQuery( cQuery )
				cTab := MPSysOpenQuery(cQuery,cTab)
		
				If ((cTab)->(!Eof()))
					Help( ,,"TAFJAGRAVADO",,, 1, 0 )
					lRet := .F.
				Endif

				If Empty(cDtIniAfa) .And. Empty(cDtFimAfa)
					Help(, , STR0065, , STR0066, 1, 0, , , , , , {STR0067}) //-> STR0066: Atenção, você está tentando inserir um registro sem preencher algum campo data // STR0067: Preencha ao menos um dos campos de data.
					lRet := .F.
				EndIf 

				(cTab)->(DbCloseArea())
			Endif
		
		EndIf
		
	EndIf

	RestArea( aAreaCM6 )

Return( lRet )

//-----------------------------------------------------------------------
/*/{Protheus.doc} TAFA261Op
Verifica se existe uma termino de afastamento e posiciona no registro conforme a seleção
feita pelo usuario na tela

Como o Array aOpcoes é dinâmico utilizo a função TafRetOpc para definir
um número para	 cada uma das opções possíveis, retornando o número
correspondente a opção selecionada.

cOption -> Tipo de opção selecionada pelo usuário na tela
		   1 = Visualização
		   2 = Validação
		   3 = Geração de XML
/*/
//-----------------------------------------------------------------------
Function TAFA261Op(cOption)

	Local aAreaCM6 	:= CM6->(getArea())
	Local nCM6RecnoT	:= 0
	Local nCM6RecnoI	:= 0
	Local nOpcRet	   	:= 0
	Local cChave		:= ""
	Local cXmlRec 	:= ""
	Local cCM6FuncOri	:=	""

	Default cOption	:= ''

	If TafColumnPos( "CM6_XMLREC" )
		cXmlRec 	:= CM6->CM6_XMLREC
	EndIf

	If cXmlRec <> "COMP" .AND. cXmlRec <> ""

		cChave      := CM6->(CM6_FILIAL + CM6_FUNC + DTOS(CM6_DTAFAS))
		cXmlRec     := CM6->CM6_XMLREC
		cCM6FuncOri := CM6->CM6_FUNC
		nRecnoOri   := CM6->( Recno() )

		CM6->( DBCloseArea() )
		DBSelectArea( "CM6" )

		CM6->( DBSetOrder( 10 ) )
		CM6->(DbGoTop())

		//Se ja estou posicionado no inicio, só preciso buscar o término
		If cXmlRec == "INIC"

			//Guardo o recno do inicio
			nCM6RecnoI	:= nRecnoOri

			//Verifica as opções possíveis
			If CM6->( MsSeek( cChave + "TERM") )

				While CM6->(!Eof()) .And. cChave == CM6->(CM6_FILIAL + CM6_FUNC + DTOS(CM6_DTAFAS))

					If !Empty(CM6->CM6_DTFAFA) .AND. CM6->CM6_EVENTO == "F"
						nCM6RecnoT	:= CM6->( Recno() )
					EndIf

					CM6->(DbSkip())
				EndDo

			EndIf
		EndIf

		//Se ja estou posicionado no termino, só preciso buscar o inicio
		If cXmlRec == "TERM"
			//Guardo o recno do termino
			nCM6RecnoT	:= nRecnoOri

			If CM6->( MsSeek( cChave + "INIC") )

				While CM6->(!Eof()) .And. cChave == CM6->(CM6_FILIAL + CM6_FUNC + DTOS(CM6_DTAFAS))

					If Empty(CM6->CM6_DTFAFA) .AND.  CM6->CM6_EVENTO == "I" .AND. CM6->CM6_FUNC == cCM6FuncOri
						nCM6RecnoI	:= CM6->( Recno() )
					EndIf

					CM6->(DbSkip())
				EndDo

			EndIf
		EndIf

		//Se encontrar um término crio a tela
		If nCM6RecnoT <> 0 .AND. nCM6RecnoI <> 0
			nOpcRet := TAFA261Screen(cOption)
		EndIf

		If nOpcRet == 0  //Se não existir Termino

			//Retorno para a area corrente pois não existe registro de término
			RestArea(aAreaCM6)

		ElseIf nOpcRet == 1 //"Inicio de Afastamento"

			//Posiciono no Inicio de Afastamento
			CM6->( DBGoTo( nCM6RecnoI ) )

		ElseIf nOpcRet == 2 //"Término do Afastamento"

			//Posiciono no Término do Afastamento
			CM6->( DBGoTo( nCM6RecnoT ) )
		EndIf

	EndIf

	If cOption == '1' .AND. nOpcRet <> -1
		FWExecView(STR0059,"TAFA261", MODEL_OPERATION_VIEW,, {|| .T. } )
	ElseIf cOption == '2' .AND. nOpcRet <> -1 //Geração de XML
		TAF261Xml( "CM6", CM6->( Recno() ))
	EndIf

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} TAFA261Screen
Cria tela com opções em um Radio para o usuário selecionar
aOpcoes - Array com as opções que serão apresentadas para o usuário

@Param
cTpTela - Uitlizado para definir o tamanho e o formato da tela a ser construida
cTpOper -> Tipo de Tela que contém as opções.
	   1 -> VIS
	   2 -> VLD
	   3 -> XML

	  "" -> Inclusão do Evento do Trabalhador
cTitulo - Titulo da tela
cMens   - Mensagem da tela
@Author Vitor Siqueira
@Since 12/05/2018
@Version 1.0
/*/
//----------------------------------------------------------------------------
Static Function TAFA261Screen(cTpOper)

	Local oDlg			:= Nil
	Local oRadio		:= Nil
	Local oTBok		:= Nil
	Local oTBSair		:= Nil
	Local nOpc			:= 0
	Local nLinFrom  	:= 0
	Local nColFrom  	:= 0
	Local nLinBtOk  	:= 0
	Local nColBtOk  	:= 0
	Local nLinBtSair	:= 0
	Local nColBtSair	:= 0
	Local nLinToMult	:= 0
	Local nColToMult	:= 0
	Local nLinFrMult	:= 0
	Local nColFrMult	:= 0
	Local cTitulo	    := ""
	Local cMens		:= STR0055 //Selecione a operação desejada:
	Local aOpcoes		:= {}
	Local oFont1	  	:= TFont():New( "MS Sans SerIf",0,-14,,.F.,0,,700,.F.,.F.,,,,,, )
	Local oSay1		:= Nil

	Default cTpOper	:= '1'

	nLinTo     := 680
	nColTo     := 1192
	nLinFrom   := 428
	nColFrom   := 741
	nLinBtSair := 100
	nColBtSair := 130
	nLinBtOk   := 100
	nColBtOK   := 058
	nSayCol    := 055
	nLinToMult := 92
	nColToMult := 01
	nLinFrMult := 260
	nColFrMult := 52

	If cTpOper == '1'
		cTitulo	   := STR0059 //"Visualização do Registro"
		nOperation := MODEL_OPERATION_VIEW
	ElseIf cTpOper == '2'
		cTitulo	   := STR0058 //"Validação do Registro"
	ElseIf cTpOper == '3'
		cTitulo	   := STR0057 //"Geração do XML"
	EndIf

	aAdd(aOpcoes, STR0056) //"Início do Afastamento"
	aAdd(aOpcoes, STR0011) //"Término do Afastamento"

	//Monta a tela com as opções possíveis
	DEFINE DIALOG oDlg TITLE cTitulo FROM nLinFrom,nColFrom TO nLinTo,nColTo PIXEL

	oRadio := TRadMenu():New (30,25,aOpcoes,,oDlg,,,,,,,,150,32,,,,.T.)
	oRadio:bSetGet := {|u|Iif (PCount()==0,nOpc, nOpc := TAFA261ROpc(aOpcoes,u))}

	oSay1		:= TSay():New( 012,nSayCol,{||cMens},oDlg,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,168,010)
	oTBok		:= TButton():New( nLinBtOk  , nColBtOk, "Confirmar",oDlg,{||oDlg:End()},37,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTBSair	:= TButton():New( nLinBtSair, nColBtSair, "Sair",oDlg,{||nOpc:=-1,oDlg:End()}, 37,12,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE DIALOG oDlg CENTERED

Return nOpc

//----------------------------------------------------------------------
/*/{Protheus.doc} TAFA261ROpc
Retorna o número da opção selecionada pelo usuário

Como o Array aOpcoes é dinâmico utilizo a função TafRetOpc para definir
um número para	 cada uma das opções possíveis, retornando o número
correspondente a opção selecionada.

aOpcoes -> Array com as opções disponíveis na Tela
nOpc 	 -> Opção selecionada
cTpTela -> Tipo de Tela que contém as opções.
	   2 -> XML
	   3 -> VLD
	  "" -> Inclusão do Evento do Trabalhador
@Return nOpc

@Author Vitor Siqueira
@Since 12/05/2018
@Version 1.0
/*/
//-----------------------------------------------------------------------
Static Function TAFA261ROpc( aOpcoes, nOpc )

	Local nOpcRet 	:= -1
	Local cTpEvento	:= aOpcoes[nOpc]

	Default aOpcoes	:= {}
	Default nOpc	:= 1

	If cTpEvento $  "Início do Afastamento"  //Inicio de Afastamento Temporário
		nOpcRet := 1
	ElseIf cTpEvento $ "Término do Afastamento" //Término de Afastamento Temporário
		nOpcRet := 2
	EndIf

Return nOpcRet

//---------------------------------------------------------------------
/*/{Protheus.doc} TrabIniAfa
@type			function
@description	Rotina para verificar se o Trabalhador iniciou o eSocial afastado.
@param			cFilEv			-	Filial do ERP para onde as informações deverão ser importadas
@param			cCabecIdeVinc	-	Path do XML para o Identificador do Vínculo
@param			cPredeces		-	Recno do registro predecessor
@param			aIncons			-	Array com as inconsistências encontradas durante a importação ( Referência )
@param			lIncons			-	Indica se precisa alimentar array de inconsistências
@return			lRet			-	Indica se o trabalhador iniciou o eSocial afastado
@author			Felipe C. Seolin
@since			23/10/2018
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function TrabIniAfa( cFilEv, cCabecIdeVinc, cPredeces, aIncons, lIncons, lGpeLegado )

	Local aAreaC9V	   := C9V->( GetArea() )
	Local aAreaCUP	   := CUP->( GetArea() )
	Local aAreaCUU	   := CUU->( GetArea() )
	Local lRet		   := .F.
	Local aFunc		   := {}

	Default lGpeLegado := .F.

	aFunc := TAFIdFunc(FTafGetVal(cCabecIdeVinc + "/cpfTrab", "C", .F., @aIncons, .F.), FTafGetVal(cCabecIdeVinc + "/matricula", "C", .F., @aIncons, .F.))

	If !Empty(aFunc[1])
		If aFunc[2] == "S2300"
			CUU->(DBSetOrder(1))

			If CUU->(MsSeek(FTAFGetFil(cFilEv, @aIncons, "CUU") + aFunc[1] + aFunc[3]))
				lRet := !Empty(CUU->CUU_DTINIA)
			EndIf
		Else
			CUP->(DBSetOrder(1))

			If CUP->(MsSeek(FTAFGetFil(cFilEv, @aIncons, "CUP") + aFunc[1] + aFunc[3]))
				lRet := !Empty(CUP->CUP_DTINIA)
			EndIf
		EndIf

		If !lRet .AND. lIncons .AND. Empty(cPredeces) .AND. !lGpeLegado
			aAdd(aIncons, STR0054) // "O término de afastamento informado não possui o registro predecessor, essa informação é obrigatória para relacionar ao seu respectivo início de afastamento."
		EndIf
	Else
		If lIncons
			aAdd(aIncons, STR0028) // "Trabalhador não encontrado na base do TAF com o CPF informado."
		EndIf
	EndIf

	RestArea( aAreaC9V )
	RestArea( aAreaCUP )
	RestArea( aAreaCUU )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} TrabSemAfa
@type			function
@description	Rotina para verificar se o Trabalhador possui outro afastamento.
@param			cIDFunc	-	ID do Trabalhador
@return			lRet	-	Indica se o trabalhador possui outro afastamento
@author			Felipe C. Seolin
@since			23/10/2018
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function TrabSemAfa( cIDFunc )

	Local cAliasQry	:=	GetNextAlias()
	Local cSelect	:=	""
	Local cFrom		:=	""
	Local cWhere	:=	""
	Local lRet		:=	.T.

	cSelect := "CM6.CM6_ID "

	cFrom := RetSqlName( "CM6" ) + " CM6 "

	cWhere := "    CM6_FILIAL = '" + xFilial( "CM6" ) + "' "
	cWhere += "AND CM6_FUNC = '" + cIDFunc + "' "
	cWhere += "AND CM6_ATIVO = '1' "
	cWhere += "AND CM6_EVENTO <> 'E' "
	cWhere += "AND CM6.D_E_L_E_T_ = '' "

	cSelect	:= "%" + cSelect	+ "%"
	cFrom	:= "%" + cFrom		+ "%"
	cWhere	:= "%" + cWhere		+ "%"

	BeginSql Alias cAliasQry

		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%

	EndSql

	( cAliasQry )->( DBGoTop() )

	If ( cAliasQry )->( !Eof() )
		lRet := Empty( ( cAliasQry )->CM6_ID )
	EndIf

	( cAliasQry )->( DBCloseArea() )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF261Nis
Busca NIS do funcionário

@author  Eduardo Sukeda
@since   27/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF261Nis(cFilialC9V, cIdC9V, cNisC9V, cDtAfast)

	Local aArea		:= GetArea()
	Local cRetNIS   := "" 

	Default cDtAfast := ""

	If !Empty(cIdC9V)
		cRetNIS := TAF250Nis( cFilialC9V, cIDC9V, cNisC9V, cDtAfast )
	EndIf 

	RestArea(aArea)

Return cRetNIS

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
/*/{Protheus.doc} PreXmlLote
Função que chama a TAFXmlLote e limpa slRubERPPad

@author brunno.costa
@since 01/10/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function PreXmlLote()

    TAFXmlLote( 'CM6', 'S-2230' , 'evtTSVInicio' , 'TAF261Xml', ,oBrw )
    slRubERPPad := Nil  //Limpa variável no final do processo em lote

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} GetV2ARecno
Rotina que irá verificar se o inicio
do afastamento foi integrado via migrador.
@type  Static Function
@author Santos.diego
@since 13/09/2019
@version version
@param param, param_type, param_descr
@example
(examples)
@see (links_or_references)
/*/
//---------------------------------------------------------------------
Static Function GetV2ARecno(cCPF, cMatricula)

	Local nTafRecno := 0
	Local cQuery 	:= ""
	Local cAlsQry	:= GetNextAlias()
	Local nZ		:= 0
	Local cSGBD 	:= TCGetDB() //Banco de dados que esta sendo utilizado 
	Local cXMLErp	:= ""
	Local aV2AArea	:= V2A->(GetArea())

	cQuery += " SELECT V2A_CHVGOV, CM6.R_E_C_N_O_ CM6RECNO, V2A.R_E_C_N_O_ V2ARECNO FROM " + RetSqlName("V2A") + " V2A "
	cQuery += " LEFT JOIN " + RetSqlName("CM6") + " CM6 ON "
	cQuery += " V2A.V2A_CHVGOV = CM6.CM6_XMLID AND "
	cQuery += " V2A.V2A_RECIBO = CM6.CM6_PROTUL AND "
	cQuery += " CM6.D_E_L_E_T_ = ' '"
	cQuery += " WHERE"

	cQuery += " V2A.V2A_EVENTO = 'S-2230' AND "
	cQuery += " CM6.R_E_C_N_O_ IS NOT NULL AND "
	cQuery += " CM6.CM6_ATIVO = '1' AND "
	cQuery += " CM6.CM6_STATUS = '4' AND "
	cQuery += " CM6.CM6_PROTUL <> ' ' AND "
	cQuery += " CM6.CM6_XMLREC = 'INIC' "

	If AllTrim(cSGBD) == 'MSSQL' 
		cQuery += " AND ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), V2A_XMLERP)),'') LIKE '%"+ cCPF +"%' AND "
		cQuery += " ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), V2A_XMLERP)),'') LIKE '%"+ cMatricula +"%' "
	ElseIf Alltrim(cSGBD) $ 'ORACLE'
		cQuery += " AND UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(V2A_XMLERP,2000,1)) LIKE '%"+ cCPF +"%' AND "
		cQuery += " UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(V2A_XMLERP,2000,1)) LIKE '%"+ cMatricula +"%' "
	ElseIf Alltrim(cSGBD) $ 'POSTGRES'
		cQuery += " AND V2A_XMLERP LIKE '%"+ cCPF +"%' AND "
		cQuery += " V2A_XMLERP LIKE '%"+ cMatricula +"%' "
	EndIf

	DBUseArea( .T., "TOPCONN", TCGenQry( ,, ChangeQuery(cQuery) ), cAlsQry, .F., .T. )

	/*
	Tratamento será feito da seguinte forma:
		OBS: Caso a query retorne mais de um registro de INICIO de Afastamento Ativo
		não será possível para o produto precisar a qual inicio o termino enviado 
		se trata, desta forma será retornado o erro de predecessão afim de evitar 
		uma integração de Afastamentos incorretos.
	*/
	If !(AllTrim(cSGBD) $ "MSSQL|ORACLE|POSTGRES|")
		While (cAlsQry)->(!Eof())
			V2A->(DbGoTo((cAlsQry)->V2ARECNO))
			cXMLErp := V2A->V2A_XMLERP

			If (cCPF $ cXMLErp) .And. ( cMatricula $ cXMLErp)
				nTafRecno := (cAlsQry)->CM6RECNO
				Exit
			EndIf
			(cAlsQry)->(DbSkip())
		End	
	Else
		While (cAlsQry)->(!Eof())
			nZ++
			If nZ == 1
				nTafRecno := (cAlsQry)->CM6RECNO
			Else
				nTafRecno := 0
			EndIf
			(cAlsQry)->(DbSkip())
		End
	EndIf

	(cAlsQry)->(DbCloseArea())

	RestArea(aV2AArea)

Return nTafRecno
