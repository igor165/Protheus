#INCLUDE  "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA050.CH"

Static lEsocial 	:= .F.
Static aAltEsoc 	:= {}
Static lLaySimplif	:= Nil
Static lSimplBeta 	:= Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA050

Complemento do Cadastro de Estabelecimentos (S-1000)
Cadastro de Inscrição do Estabelecimento Substituto

@author Marcio Nunes
@since 16/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA050( lLoad )

	Private oBrw		:= Nil

	oBrw	:=	FWmBrowse():New()

	oBrw:SetDescription( STR0001 ) //Complemento do Cadastro de Estabelecimentos
	oBrw:SetAlias( "C1E" )
	oBrw:SetMenuDef( "TAFA050" )
	oBrw:SetFilterDefault( "C1E_ATIVO == '1' .Or. (C1E_EVENTO == 'E' .And. C1E_STATUS = '4' .And. C1E_ATIVO = '2')" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )
	oBrw:AddLegend( "C1E_EVENTO == 'I' ", "GREEN" , STR0046 ) //"Registro Incluído"
	oBrw:AddLegend( "C1E_EVENTO == 'A' ", "YELLOW", STR0047 ) //"Registro Alterado"
	oBrw:AddLegend( "C1E_EVENTO == 'E' .And. C1E_STATUS <> '4' ", "RED"   , STR0048 ) //"Registro excluído não transmitido"
	oBrw:AddLegend( "C1E_EVENTO == 'E' .And. C1E_STATUS == '4' .And. C1E_ATIVO = '2' ", "BLACK", STR0049 ) //"Registro excluído transmitido"

	oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Marcio Nunes
@since 16/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao	:=	{}
	Local aRotina	:=	{}

	//Reseto a variavel estatica
	If ValType(aAltEsoc) <> Nil
		aAltEsoc := {}
	EndIf
	If FindFunction('TafXmlRet')
		aFuncao := {	{ "","TafxmlRet('TAF050Xml','1000','C1E')", "1" },;
			{ "", "xFunHisAlt( 'C1E', 'TAFA050',,,,'TAF050XML','1000' )", "3" },;
			{ "", "TAFXmlLote( 'C1E', 'S-1000', 'evtInfoEmpregador', 'TAF050Xml' )", "5" },;
			{ STR0030, "MsgRun( '" + STR0036 + "', '" + STR0030 + "', { || A050Am1x1() } )",, 3 },; //##"Processando..." ##"Amarração Automática 1 x 1"
		{ "", "xFunAltRec( 'C1E' )" , "10" } }
	Else
		aFuncao := {	{ "","TAF050Xml", "1" },;
			{ "", "xFunHisAlt( 'C1E', 'TAFA050',,,,'TAF050XML','1000' )", "3" },;
			{ "", "TAFXmlLote( 'C1E', 'S-1000', 'evtInfoEmpregador', 'TAF050Xml' )", "5" },;
			{ STR0030, "MsgRun( '" + STR0036 + "', '" + STR0030 + "', { || A050Am1x1() } )",, 3 },; //##"Processando..." ##"Amarração Automática 1 x 1"
		{ "", "xFunAltRec( 'C1E' )" , "10" } }
	EndIf
	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If lMenuDif
		ADD OPTION aRotina Title STR0031 Action "VIEWDEF.TAFA050" OPERATION 2 ACCESS 0 //"Visualizar"
	Else
		aRotina := xFunMnuTAF( "TAFA050",, aFuncao )
	EndIf

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marcio Nunes
@since 16/07/2012
@version 1.0
/*/

//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruC1E		:= Nil
	Local oStruC1F		:= Nil
	Local oStruV81		:= Nil
	Local oStruCR9		:= Nil
	Local oStruCRM		:= Nil
	Local oStruCUW		:= Nil
	Local oStruCZR		:= Nil
	Local oModel		:= Nil
	Local aTrigger		:= {}
	Local aCpoEsoc		:= {}
	Local aArea 		:= GetArea()
	Local aRemoveC1E	:= {}
	Local aRemoveCRM	:= {}
	Local cValid 		:= ""
	Local nX			:= 0
	Local nY			:= 0
	Local bValid 		:= {||}
	Local aUniqCUW		:= {}
	Local lCUWCnpj		:= TAFColumnPos('CUW_CNPJ')
	Local cTpInscr  	:= SM0->M0_TPINSC
	LocaL nICUW         := 0
	LocaL nICR9         := 0
	LocaL nICZR         := 0

	oStruC1E	:=	FWFormStruct( 1, "C1E" )
	oStruC1F	:=	FWFormStruct( 1, "C1F" )
	if TAFAlsInDic( "V81" ) ; oStruV81	:=	FWFormStruct( 1, "V81" ); endif
	oStruCR9	:=	FWFormStruct( 1, "CR9" )
	oStruCRM	:=	FWFormStruct( 1, "CRM" )
	oStruCUW	:=	FWFormStruct( 1, "CUW" )
	oStruCZR	:=	FWFormStruct( 1, "CZR" )

	If isVersionCompatible("S_01_00_00")
		oStruC1E:RemoveField("C1E_NOMCNT")
		AADD(aRemoveC1E, "C1E_NOMCNT")
		oStruC1E:RemoveField("C1E_CPFCNT")
		AADD(aRemoveC1E, "C1E_CPFCNT")
		oStruC1E:RemoveField("C1E_EMAIL")
		AADD(aRemoveC1E, "C1E_EMAIL")
		oStruC1E:RemoveField("C1E_DDDFON")
		AADD(aRemoveC1E, "C1E_DDDFON")
		oStruC1E:RemoveField("C1E_FONCNT")
		AADD(aRemoveC1E, "C1E_FONCNT")
		oStruC1E:RemoveField("C1E_DDDCEL")
		AADD(aRemoveC1E, "C1E_DDDCEL")
		oStruC1E:RemoveField("C1E_CELCNT")
		AADD(aRemoveC1E, "C1E_CELCNT")		
		oStruC1E:RemoveField("C1E_INDETT")
		AADD(aRemoveC1E, "C1E_INDETT")
		oStruC1E:RemoveField("C1E_NRETT")
		AADD(aRemoveC1E, "C1E_NRETT")
		oStruC1E:RemoveField("C1E_ENTEDU")
		AADD(aRemoveC1E, "C1E_ENTEDU")		
		oStruC1E:RemoveField("C1E_SITESP")
		AADD(aRemoveC1E, "C1E_SITESP")
		oStruC1E:RemoveField("C1E_SITPF")
		AADD(aRemoveC1E, "C1E_SITPF")
	EndIf

	If !isVersionCompatible("S_01_00_00") .And. TafColumnPos("C1E_DTTRSO")
		oStruC1E:RemoveField("C1E_DTTRSO")
		AAdd(aRemoveC1E, "C1E_DTTRSO")
	EndIf

	If !isVersionCompatible("S_01_01_00",, .T.) .And. TafColumnPos("C1E_PISCOF")
		oStruC1E:RemoveField("C1E_PISCOF")
		AAdd(aRemoveC1E, "C1E_PISCOF")
	EndIf

	oModel		:=	MPFormModel():New( "TAFA050",, { |oModel| ValidModel( oModel ) }, { |oModel| SaveModel( oModel ) } )

	lVldModel	:= Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruC1E:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	EndIf

	oStruC1E:SetProperty( "C1E_FILTAF", MODEL_FIELD_VALID, {|| TafVldMatz()} )

	//Verifico se os campos a seguir fazem parte do layout do eSocial
	aCpoEsoc	:= TAFDePara("S1000")

	For nX := 1 To Len(aRemoveC1E)

		For nY := 1 To Len(aCpoEsoc[1])

			nPosDel	:=	aScan( aCpoEsoc , { | aX | AllTrim( aCpoEsoc[1][nY][4] ) == aRemoveC1E[nX] } )
			If nPosDel > 0
				aDel( aCpoEsoc[1] , nY )
				aSize( aCpoEsoc[1] , Len( aCpoEsoc[1] ) - 1 )
				Exit
			EndIf

		Next

	Next

	If isVersionCompatible("S_01_00_00")

		For nX := 1 To Len(aRemoveCRM)

			For nY := 1 To Len(aCpoEsoc[1])

				nPosDel	:=	aScan( aCpoEsoc , { | aX | AllTrim( aCpoEsoc[1][nY][4] ) == aRemoveCRM[nX] } )
				If nPosDel > 0
					aDel( aCpoEsoc[1] , nY )
					aSize( aCpoEsoc[1] , Len( aCpoEsoc[1] ) - 1 )
					Exit
				EndIf

			Next

		Next

	EndIf

	aadd(aUniqCUW,'CUW_CODSCP')
	if lCUWCnpj
		aadd(aUniqCUW,'CUW_CNPJ')
	endif

	//Abro a tabela SX3
	OpenSxs(,,.F.,.F.,cEmpAnt,"SX3TMP","SX3")
	SX3TMP->( dbSelectArea("SX3TMP") )
	SX3TMP->( dbSetOrder(2) )

	For nX := 1 to Len(aCpoEsoc)

		For nY := 1 to len(aCpoEsoc[nX])

			//Posiciono campo a campo que foi retornado da função TAFDEPARA
			If SX3TMP->( DbSeek(aCpoEsoc[nX,nY,4]) )

				//Verifico se o campo é USADO
				If X3Uso( Posicione( "SX3", 2, aCpoEsoc[nX,nY,4] , "X3_USADO" ))

					//Retorno o conteudo do X3_VALID
					cValid := Replace(Alltrim(GetSx3Cache(aCpoEsoc[nX,nY,4],"X3_VALID")),'"', "'")

					//Caso tenha conteudo no campo X3_VALID, aglutino a nova função ao conteudo, senao, somente a adiciono.
					If Empty(AllTrim(cValid))
						cValid := "TAFCpoEsoc('" +aCpoEsoc[nX,nY,4]+ "')"
					Else
						cValid += " .And. TAFCpoEsoc('" +aCpoEsoc[nX,nY,4]+ "')"
					EndIf

					bValid := FWBuildFeature( STRUCT_FEATURE_VALID, cValid )

					//Altero o SetProperty dos campos referentes ao eSocial, adicionando a nova função validadora
					If aCpoEsoc[nX,nY,5] == "C1E"
						oStruC1E:SetProperty( aCpoEsoc[nX,nY,4] , MODEL_FIELD_VALID , bValid )
					ElseIf !isVersionCompatible("S_01_00_00")
						oStruCRM:SetProperty( aCpoEsoc[nX,nY,4] , MODEL_FIELD_VALID , bValid )
					EndIf
				EndIf
			EndIf
		Next nY
	Next nX

	SX3TMP->( dbCloseArea() )

	RestArea(aArea)

	//Campo é obrigatório porém na C1E não pode receber obrigatoriedade
	If !isVersionCompatible("S_01_00_00")
		If TAFColumnPos("C1E_ENTEDU")
			oStruC1E:SetProperty( "C1E_ENTEDU", MODEL_FIELD_OBRIGAT,.F.)
		EndIf
	EndIf

	//modifico o X3_RELACAO do campo C1E_NRINSC quando o dicionario estiver desatualizado.
	If cTpInscr == 1
		oStruC1E:SetProperty( "C1E_NRINSC" , MODEL_FIELD_INIT , { || Posicione("SM0",1,SM0->M0_CODIGO + C1E->C1E_FILTAF,"M0_CEI") } )
	Else
		oStruC1E:SetProperty( "C1E_NRINSC" , MODEL_FIELD_INIT , { || Posicione("SM0",1,SM0->M0_CODIGO + C1E->C1E_FILTAF,"M0_CGC") } )
	EndIf

	//crio um gatilho para o campo C1E_FILTAF quando o dicionario estiver desatualizado.
	If AllTrim( getSX3Cache( 'C1E_FILTAF' , 'X3_TRIGGER' ) ) <> 'S'
		aTrigger := FwStruTrigger( 'C1E_FILTAF' , 'C1E_NRINSC' , 'SM0->M0_CGC', .T., 'SM0', 1, 'SM0->M0_CODIGO + M->C1E_FILTAF' )
		oStruC1E:AddTrigger( aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4] )
	EndIf

	oModel:AddFields( 'MODEL_C1E', /*cOwner*/, oStruC1E )
	oModel:GetModel( 'MODEL_C1E' ):SetPrimaryKey( { "C1E_CODFIL" } )

	oModel:AddGrid( 'MODEL_CR9', 'MODEL_C1E', oStruCR9 )
	oModel:GetModel( 'MODEL_CR9' ):SetOptional( .T. )
	oModel:GetModel( 'MODEL_CR9' ):SetUniqueLine( { 'CR9_CODFIL' } )

	oModel:AddGrid( 'MODEL_C1F', 'MODEL_C1E', oStruC1F )
	oModel:GetModel( 'MODEL_C1F' ):SetOptional( .T. )
	oModel:GetModel( 'MODEL_C1F' ):SetUniqueLine( { 'C1F_UFST', 'C1F_IEST' , 'C1F_VALIDA' } )
	if TAFAlsInDic( "V81" )
		oModel:AddGrid( 'MODEL_V81', 'MODEL_C1E', oStruV81 )
		oModel:GetModel( 'MODEL_V81' ):SetOptional( .T. )
		oModel:GetModel( 'MODEL_V81' ):SetUniqueLine( { 'V81_UF', 'V81_CODMUN' } )
	endif

	oModel:AddGrid( 'MODEL_CUW', 'MODEL_C1E', oStruCUW )
	oModel:GetModel( 'MODEL_CUW' ):SetOptional( .T. )
	oModel:GetModel( 'MODEL_CUW' ):SetUniqueLine( aUniqCUW )

	oModel:AddGrid( 'MODEL_CZR', 'MODEL_C1E', oStruCZR )
	oModel:GetModel( 'MODEL_CZR' ):SetOptional( .T. )
	oModel:GetModel( 'MODEL_CZR' ):SetUniqueLine( { 'CZR_IDOBRI' } )

	
	oModel:AddGrid( 'MODEL_CRM', 'MODEL_C1E', oStruCRM )
	oModel:GetModel( 'MODEL_CRM' ):SetOptional( .T. )
	oModel:GetModel( 'MODEL_CRM' ):SetUniqueLine( { 'CRM_CNPJ' } )
	oModel:SetRelation( 'MODEL_CRM', { { 'CRM_FILIAL', 'xFilial( "CRM" )' }, { 'CRM_ID', "C1E_ID" }, { 'CRM_VERSAO', "C1E_VERSAO" } }, CRM->( IndexKey( 1 ) ) )
	
	IIF(FWSIXUtil():ExistIndex( "C1F", "2"), nIC1E := 2, nIC1E := 1)
	oModel:SetRelation( 'MODEL_C1F', { { 'C1F_FILIAL', 'xFilial( "C1F" )' }, { 'C1F_ID', "C1E_ID" }, { 'C1F_VERSAO', "C1E_VERSAO" }, { 'C1F_ATIVO', "C1E_ATIVO" } }, C1F->( IndexKey( nIC1E ) ) )
	if TAFAlsInDic( "V81" )
		IIF(FWSIXUtil():ExistIndex( "V81", "2"), nIC1E := 2, nIC1E := 1)
		oModel:SetRelation( 'MODEL_V81', { { 'V81_FILIAL', 'xFilial( "V81" )' }, { 'V81_ID', "C1E_ID" }, { 'V81_VERSAO', "C1E_VERSAO" }, { 'V81_ATIVO', "C1E_ATIVO" } }, V81->( IndexKey( nIC1E ) ) )
	endif

	IIF(FWSIXUtil():ExistIndex( "CUW", "4"), nICUW := 4, nICUW := 1)
	oModel:SetRelation( 'MODEL_CUW', { { 'CUW_FILIAL', 'xFilial( "CUW" )' }, { 'CUW_ID', "C1E_ID" }, { 'CUW_VERSAO', "C1E_VERSAO" }, { 'CUW_ATIVO', "C1E_ATIVO" } }, CUW->( IndexKey( nICUW ) ) )

	IIF(FWSIXUtil():ExistIndex( "CR9", "4"), nICR9 := 4, nICR9 := 1)
	oModel:SetRelation( 'MODEL_CR9', { { 'CR9_FILIAL', 'xFilial( "CR9" )' }, { 'CR9_ID', "C1E_ID" }, { 'CR9_VERSAO', "C1E_VERSAO" }, { 'CR9_ATIVO', "C1E_ATIVO" } }, CR9->( IndexKey( nICR9 ) ) )

	IIF(FWSIXUtil():ExistIndex( "CZR", "3"), nICZR := 4, nICZR := 1)
	oModel:SetRelation( 'MODEL_CZR', { { 'CZR_FILIAL', 'xFilial( "CZR" )' }, { 'CZR_ID', "C1E_ID" }, { 'CZR_VERSAO', "C1E_VERSAO" }, { 'CZR_ATIVO', "C1E_ATIVO" } }, CZR->( IndexKey( nICZR ) ) )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Marcio Nunes
@since 16/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel		:= Nil
	Local oStruC1E	    := Nil
	Local oStruC1F	    := Nil
	Local oStruC1Ea    	:= Nil
	Local oStruC1Eb    	:= Nil
	Local oStruC1Ed	    := Nil
	Local oStruC1Ee    	:= Nil
	Local oStruC1Eg	    := Nil
	Local oStruC1Eh     := Nil
	Local oStruC1Ei     := Nil
	Local oStruC1Ej	    := Nil
	Local oStruC1Ek	    := Nil
	Local oStruC1El	    := Nil
	Local oStruCUW	    := Nil
	Local oStruCR9	    := Nil
	Local oStruCRM	    := Nil
	Local oStruCZR	    := Nil
	Local oView		    := Nil
	Local cCmpFil	    := ""
	Local lFieldNrInsc	:= .F.
	Local lReinf1F		:= TAFColumnPos( "C1E_INDDES") .And. TAFColumnPos( "C1E_PRDRUR")
	Local cGrpCT1		:= ""
	Local cGrpCT2		:= ""
	Local lNewContato	:= .F.

	oModel		:=	FWLoadModel( "TAFA050" )

	oStruC1E	:=	FWFormStruct( 2, "C1E" )
	oStruC1F	:=	FWFormStruct( 2, "C1F" )
	oStruCUW	:=	FWFormStruct( 2, "CUW" )
	oStruCR9	:=	FWFormStruct( 2, "CR9" )
	oStruCRM	:=	FWFormStruct( 2, "CRM" )
	oStruCZR	:=	FWFormStruct( 2, "CZR" )
	if TAFAlsInDic( "V81" ) ; oStruV81	:=	FWFormStruct( 2, "V81" ); endif

	oView		:=	FWFormView():New()

	oStruC1E:RemoveField( "C1E_IDTENT" )
	oStruC1E:RemoveField( "C1E_MTBRUB" )

	If TafColumnPos( "C1E_LOGOPE" )
		oStruC1E:RemoveField( "C1E_LOGOPE" )
	EndIf

	oStruCR9:RemoveField( "CR9_VERSAO" )
	oStruCR9:RemoveField( "CR9_ATIVO" )
	oStruC1F:RemoveField( "C1F_ATIVO" )
	if TAFAlsInDic( "V81" )
		oStruV81:RemoveField( "V81_ID" )
		oStruV81:RemoveField( "V81_ATIVO" )
		oStruV81:RemoveField( "V81_VERSAO" )
	endif
	oStruCUW:RemoveField( "CUW_ATIVO" )
	oStruCZR:RemoveField( "CZR_ID" )
	oStruCZR:RemoveField( "CZR_IDOBRI" )
	oStruCZR:RemoveField( "CZR_ATIVO" )

	oView:SetModel( oModel )

	If !isVersionCompatible("S_01_00_00")
		cCmpFil := "C1E_ID|C1E_VERSAO|C1E_FILTAF|C1E_CODFIL|C1E_CODFEB|C1E_DTINI|C1E_DTFIN|C1E_NOME|C1E_CLAFIS|C1E_DCLAFI|C1E_NATJUR|C1E_DNATJU|C1E_INCOOP|C1E_INCONS|C1E_DESFOL|C1E_REGELT|C1E_ISEMUL|C1E_INDETT|C1E_NRETT|C1E_CRT|C1E_VERANT|C1E_CDINAN|"
	Else
		cCmpFil := "C1E_ID|C1E_VERSAO|C1E_FILTAF|C1E_CODFIL|C1E_CODFEB|C1E_DTINI|C1E_DTFIN|C1E_NOME|C1E_CLAFIS|C1E_DCLAFI|C1E_NATJUR|C1E_DNATJU|C1E_INCOOP|C1E_INCONS|C1E_DESFOL|C1E_REGELT|C1E_CPNJER|C1E_ISEMUL|C1E_CRT|C1E_VERANT|C1E_CDINAN|"
	EndIf

	If isVersionCompatible("S_01_00_00") .And. TafColumnPos("C1E_DTTRSO")
		cCmpFil += "C1E_DTTRSO|"
	EndIf

	If isVersionCompatible("S_01_01_00",, .T.) .And. TafColumnPos("C1E_PISCOF")
		cCmpFil += "C1E_PISCOF|"
	EndIf

	If TAFColumnPos( "C1E_PORTE" )
		cCmpFil += "C1E_PORTE|"
	EndIf

	If TAFColumnPos( "C1E_MATRIZ" )
		cCmpFil += "C1E_MATRIZ|"
	EndIf

	//GetSx3Cache no campo C1E_NRINSC pois é um campo virtual, portanto não posso usar TAFColumnPos
	If GetSx3Cache("C1E_NRINSC","X3_TAMANHO") <> Nil
		cCmpFil += "C1E_NRINSC|"
		lFieldNrInsc := .T.
	EndIf

	If !isVersionCompatible("S_01_00_00")
		If TAFColumnPos( "C1E_ENTEDU" )
			cCmpFil += "C1E_ENTEDU|"
		EndIf
	EndIf

	If TAFColumnPos( "C1E_SEGMEN" )
		cCmpFil += "C1E_SEGMEN|"
	EndIf

	If TAFColumnPos( "C1E_INDCP" )
		cCmpFil += "C1E_INDCP|"
	EndIf

	oStruC1Ea := FWFormStruct( 2, "C1E", { |x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Informações do Estabelecimento

	If TAFColumnPos( "C1E_MATRIZ" )
		oStruC1Ea:SetProperty( "C1E_MATRIZ", MVC_VIEW_ORDEM, "06" )
	EndIf

	If TAFColumnPos( "C1E_INDCP" )
		oStruC1Ea:SetProperty( "C1E_INDCP", MVC_VIEW_ORDEM, "52" )
	EndIf

	If lFieldNrInsc
		oStruC1Ea:SetProperty( "C1E_NRINSC", MVC_VIEW_ORDEM, "07" )
	EndIf

	If (TAFColumnPos("C1E_REMAIL")) ;
			.And. (TAFColumnPos("C1E_RNOMEC")) 	;
			.And. (TAFColumnPos("C1E_RCPFC")) 	;
			.And. (TAFColumnPos("C1E_RDDDFO")) 	;
			.And. (TAFColumnPos("C1E_RFONEC"))	;
			.And. (TAFColumnPos("C1E_RDDDCE"))	;
			.And. (TAFColumnPos("C1E_RCELC"))
		lNewContato := .T.

		If !isVersionCompatible("S_01_00_00")
			cGrpCT1 	:= 'C1E_NOMCNT|C1E_CPFCNT|C1E_DDDFON|C1E_FONCNT|C1E_DDDCEL|C1E_CELCNT|C1E_EMAIL|'
			oStruC1Ex := FwFormStruct( 2, 'C1E', {|x| AllTrim( x ) + "|" $ cGrpCT1 } ) //Campos do folder Contato do Estabelecimento
			oView:AddField( "VIEW_C1EX", oStruC1Ex, "MODEL_C1E" )
			oView:EnableTitleView( "VIEW_C1EX", STR0044 ) //"Contatos e-Social"
		EndIf

		cGrpCT2 	:= 'C1E_REMAIL|C1E_RNOMEC|C1E_RCPFC|C1E_RDDDFO|C1E_RFONEC|C1E_RDDDCE|C1E_RCELC|'
		oStruC1Ex := FwFormStruct( 2, 'C1E', {|x| AllTrim( x ) + "|" $ cGrpCT2 } ) //Campos do folder Contato do Estabelecimento
		oView:AddField( "VIEW_C1EW", oStruC1Ex, "MODEL_C1E" )
		oView:EnableTitleView( "VIEW_C1EW", STR0045  ) //"Contatos Reinf"
	Else
		lNewContato := .F.
		cCmpFil := 'C1E_NOMCNT|C1E_CPFCNT|C1E_DDDFON|C1E_FONCNT|C1E_DDDCEL|C1E_CELCNT|C1E_EMAIL|'
		oStruC1Eb := FwFormStruct( 2, 'C1E', {|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Contato do Estabelecimento
		oView:AddField( 'VIEW_C1Eb', oStruC1Eb, 'MODEL_C1E' )
	EndIf

	cCmpFil := 'C1E_SIGMIN|C1E_NRCERT|C1E_DTEMCE|C1E_DTVCCE|C1E_NRPRRE|C1E_DTPRRE|C1E_DTDOU|C1E_PAGDOU|'
	oStruC1Ed := FwFormStruct( 2, 'C1E', {|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Dados de Isencao

	cCmpFil := 'C1E_SIAFI|C1E_EFR|C1E_CPNJER|C1E_NMENTE|C1E_UF|C1E_DUF|C1E_CODMUN|C1E_DCODMU|C1E_RPPS|C1E_SUBTET|C1E_VLRSUB|'
	oStruC1Eh := FwFormStruct( 2, 'C1E', {|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Informações de Órgãos Públicos

	If !isVersionCompatible("S_01_00_00")
		cCmpFil := 'C1E_SITESP|C1E_SITPF|'
		oStruC1Ee := FwFormStruct( 2, 'C1E', {|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Informações Complementares
	EndIf

	cCmpFil := 'C1E_PROTUL|'
	oStruC1Eg := FwFormStruct( 2, 'C1E', {|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Recibo de Transmissão

	If TafColumnPos("C1E_DTRANS")
		cCmpFil := "C1E_DINSIS|C1E_DTRANS|C1E_HTRANS|C1E_DTRECP|C1E_HRRECP|"
		oStruC1El := FwFormStruct( 2, 'C1E', {|x| AllTrim( x ) + "|" $ cCmpFil } )
	EndIf

	If TAFColumnPos( "C1E_CNPJTR" )
		cCmpFil := 'C1E_CNPJTR|C1E_NRCPF|'
		oStruC1Ej := FwFormStruct( 2, 'C1E', {|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do Outras informações
	EndIf

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruC1Eg,"C1E")
	EndIf

	If lReinf1F // Reinf Fase 1
		cCmpFil := 'C1E_INDESC|C1E_INDDES|C1E_INDPJ|C1E_INIPER|C1E_FINPER|C1E_ASSDES|'
		If TAFColumnPos( "C1E_CAEPFR" )
			cCmpFil += 'C1E_CAEPFR|'
		EndIf
		oStruC1Ek := FwFormStruct( 2, 'C1E', {|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder REINF
	
		cCmpFil := 'C1E_PRDRUR|C1E_PAA|'
		oStruC1Ei := FwFormStruct( 2, 'C1E', {|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Produtor Rural
	EndIf

	oView:AddField( 'VIEW_C1Ea', oStruC1Ea, 'MODEL_C1E' )
	oView:AddField( 'VIEW_C1Ed', oStruC1Ed, 'MODEL_C1E' )

	If !isVersionCompatible("S_01_00_00")
		oView:AddField( 'VIEW_C1Ee', oStruC1Ee, 'MODEL_C1E' )
	EndIf

	oView:AddField( 'VIEW_C1Eg', oStruC1Eg, 'MODEL_C1E' )
	oView:EnableTitleView( 'VIEW_C1Eg', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"

	If TafColumnPos("C1E_DTRANS")
		oView:AddField( 'VIEW_C1El', oStruC1El, 'MODEL_C1E' )
		oView:EnableTitleView( 'VIEW_C1El', TafNmFolder("recibo",2) )
	EndIf

	oView:AddField( 'VIEW_C1Eh', oStruC1Eh, 'MODEL_C1E' )


	If TAFColumnPos( "C1E_CNPJTR" )
		oView:AddField( 'VIEW_C1Ej', oStruC1Ej, 'MODEL_C1E' )
	EndIf

	If lReinf1F // Reinf Fase 1
		oView:AddField( 'VIEW_C1Ek', oStruC1Ek, 'MODEL_C1E' )

		oView:AddField( 'VIEW_C1Ei', oStruC1Ei, 'MODEL_C1E' )
	EndIf

	oView:AddGrid( 'VIEW_C1F', oStruC1F, 'MODEL_C1F' )
	oView:EnableTitleView( 'VIEW_C1F', STR0002 ) //Cadastro de Inscrição do Estabelecimento Substituto

	if TAFAlsInDic( "V81" )
		oView:AddGrid( 'VIEW_V81', oStruV81, 'MODEL_V81' )
		oView:EnableTitleView( 'VIEW_V81', "DIPAM.B 2.6 (Rateio por Municípios)")
	endif

	oView:AddGrid( 'VIEW_CUW', oStruCUW, 'MODEL_CUW' )
	oView:EnableTitleView( 'VIEW_CUW', "SCP" ) //SCP

	oView:AddGrid( 'VIEW_CRM', oStruCRM, 'MODEL_CRM' )
	oView:EnableTitleView( 'VIEW_CRM', STR0011 ) //Informações da Software House	

	oView:CreateHorizontalBox( 'PAINEL_ABAS', 100 )

	oView:CreateFolder( 'FOLDER_GERAL', 'PAINEL_ABAS' )

	oView:AddSheet( 'FOLDER_GERAL', 'ABA01', STR0003 ) //"Complemento do Estabelecimento"
	oView:AddSheet( 'FOLDER_GERAL', 'ABA02', STR0004 ) //"e-Social"

	If FindFunction("TafNmFolder")
		oView:AddSheet( 'FOLDER_GERAL', "ABA03", TafNmFolder("recibo") )   //"Numero do Recibo"
	Else
		oView:AddSheet( 'FOLDER_GERAL', 'ABA03', STR0021 ) //"Protocolo de Transmissão"
	EndIf

	//Aba01
	if TAFAlsInDic( "V81" )
		oView:CreateHorizontalBox( 'PAINEL_FOLDER1_SUPERIOR' , 40,,, 'FOLDER_GERAL', 'ABA01' )
		oView:CreateHorizontalBox( 'PAINEL_FOLDER1_INFERIOR2', 20,,, 'FOLDER_GERAL', 'ABA01' )
		oView:CreateHorizontalBox( 'PAINEL_FOLDER1_INFERIOR3', 20,,, 'FOLDER_GERAL', 'ABA01' )
		oView:CreateHorizontalBox( 'PAINEL_FOLDER1_INFERIOR4', 20,,, 'FOLDER_GERAL', 'ABA01' )
	else
		oView:CreateHorizontalBox( 'PAINEL_FOLDER1_SUPERIOR' , 45,,, 'FOLDER_GERAL', 'ABA01' )
		oView:CreateHorizontalBox( 'PAINEL_FOLDER1_INFERIOR2', 27,,, 'FOLDER_GERAL', 'ABA01' )
		oView:CreateHorizontalBox( 'PAINEL_FOLDER1_INFERIOR3', 28,,, 'FOLDER_GERAL', 'ABA01' )
	endif

	oView:CreateFolder( 'FOLDER1', 'PAINEL_FOLDER1_SUPERIOR' )

	oView:AddSheet( 'FOLDER1', 'ABA01', STR0005 ) //"Informações do Estabelecimento"
	oView:CreateHorizontalBox( 'C1Ea', 100,,, 'FOLDER1', 'ABA01' )

	If lNewContato
		oView:AddSheet( 'FOLDER1', 'ABA02', STR0006 ) //"Contato do Estabelecimento"
		If !isVersionCompatible("S_01_00_00")
			oView:CreateHorizontalBox( 'C1Ex', 050,,, 'FOLDER1', 'ABA02' )
			oView:CreateHorizontalBox( 'C1Ew', 050,,, 'FOLDER1', 'ABA02' )
		Else
			oView:CreateHorizontalBox( 'C1Ew', 050,,, 'FOLDER1', 'ABA02' )
		EndIf
	Else
		oView:AddSheet( 'FOLDER1', 'ABA02', STR0006 ) //"Contato do Estabelecimento"
		oView:CreateHorizontalBox( 'C1Eb', 100,,, 'FOLDER1', 'ABA02' )
	EndIf
	oView:AddSheet( 'FOLDER1', 'ABA06', STR0012 ) //"Outras Filiais"
	oView:CreateHorizontalBox( 'CR9', 100,,, 'FOLDER1', 'ABA06' )

	oView:AddSheet( 'FOLDER1', 'ABA07', STR0022 ) //"Obrigações Fiscais"
	oView:CreateHorizontalBox( 'CZR', 100,,, 'FOLDER1', 'ABA07' )

	If TAFColumnPos( "C1E_CNPJTR" )
		oView:AddSheet( 'FOLDER1', 'ABA08', STR0040 ) //"Informações do Estabelecimento"
		oView:CreateHorizontalBox( 'C1Ej', 100,,, 'FOLDER1', 'ABA08' )

	EndIf

	//Aba02
	oView:CreateHorizontalBox( 'PAINEL_FOLDER2', 100,,, 'FOLDER_GERAL', 'ABA02' )
	oView:CreateFolder( 'FOLDER2', 'PAINEL_FOLDER2' )

	oView:AddSheet( 'FOLDER2', 'ABA02', STR0008 ) //"Dados de Isenção"
	oView:CreateHorizontalBox( 'C1Ed', 100,,, 'FOLDER2', 'ABA02' )

	oView:AddSheet( 'FOLDER2', 'ABA03', STR0037 ) //"Informações de Órgãos Públicos"
	oView:CreateHorizontalBox( 'C1Eh', 100,,, 'FOLDER2', 'ABA03' )

	oView:AddSheet( 'FOLDER2', 'ABA04', STR0011 ) //"Informações da Software House"
	oView:CreateHorizontalBox( 'CRM', 100,,,  'FOLDER2', 'ABA04' )

	If !isVersionCompatible("S_01_00_00")
		oView:AddSheet( 'FOLDER2', 'ABA05', STR0017 ) //"Informações Complementares"
		oView:CreateHorizontalBox( 'C1Ee', 100,,, 'FOLDER2', 'ABA05' )
	EndIf

	If lReinf1F // Reinf Fase 1
		oView:AddSheet( 'FOLDER2', 'ABA06', "Reinf" )
		oView:CreateHorizontalBox( 'C1Ek', 100,,, 'FOLDER2', 'ABA06' )

		oView:AddSheet( 'FOLDER2', 'ABA07', "Informação de Produtor Rural" )
		oView:CreateHorizontalBox( 'C1Ei', 100,,, 'FOLDER2', 'ABA07' )
	EndIf

	//Aba03
	If TafColumnPos("C1E_DTRANS")
		oView:CreateHorizontalBox( 'C1Eg', 20,,, 'FOLDER_GERAL', 'ABA03' )
		oView:CreateHorizontalBox( 'C1El', 80,,, 'FOLDER_GERAL', 'ABA03' )
	Else
		oView:CreateHorizontalBox( 'C1Eg', 100,,, 'FOLDER_GERAL', 'ABA03' )
	EndIf

	//Aba06
	oView:AddGrid( 'VIEW_CR9', oStruCR9, 'MODEL_CR9' )

	//Aba07
	oView:AddGrid( 'VIEW_CZR', oStruCZR, 'MODEL_CZR' )

	oView:SetOwnerView( 'VIEW_C1Ea' , 'C1Ea')
	oView:SetOwnerView( 'VIEW_C1Ed' , 'C1Ed')
	oView:SetOwnerView( 'VIEW_C1Eg' , 'C1Eg')
	oView:SetOwnerView( 'VIEW_C1Eh' , 'C1Eh')
	If TafColumnPos("C1E_DTRANS")
		oView:SetOwnerView( 'VIEW_C1El' , 'C1El')
	EndIf
	oView:SetOwnerView( 'VIEW_CRM'  , 'CRM')

	If !isVersionCompatible("S_01_00_00")
		oView:SetOwnerView( 'VIEW_C1Ee' , 'C1Ee')		
	EndIf

	oView:SetOwnerView( 'VIEW_CZR'  , 'CZR')
	oView:SetOwnerView( 'VIEW_CR9'  , 'CR9')

	//oView:SetOwnerView( 'VIEW_CR9' , 'PAINEL_FOLDER1_INFERIOR1' )
	if TAFAlsInDic( "V81" )
		oView:SetOwnerView( 'VIEW_C1F' , 'PAINEL_FOLDER1_INFERIOR2' )
		oView:SetOwnerView( 'VIEW_V81' , 'PAINEL_FOLDER1_INFERIOR3' )
		oView:SetOwnerView( 'VIEW_CUW' , 'PAINEL_FOLDER1_INFERIOR4' )
	else
		oView:SetOwnerView( 'VIEW_C1F' , 'PAINEL_FOLDER1_INFERIOR2' )
		oView:SetOwnerView( 'VIEW_CUW' , 'PAINEL_FOLDER1_INFERIOR3' )
	endif
	//oView:SetOwnerView( 'VIEW_CZR' , 'PAINEL_FOLDER1_INFERIOR4' )

	If lNewContato
		If !isVersionCompatible("S_01_00_00")
			oView:SetOwnerView( 'VIEW_C1EX' , 'C1Ex')
			oView:SetOwnerView( 'VIEW_C1EW' , 'C1Ew')
		Else
			oView:SetOwnerView( 'VIEW_C1EW' , 'C1Ew')
		EndIf
	Else
		oView:SetOwnerView( 'VIEW_C1Eb' , 'C1Eb')
	EndIf

	If TAFColumnPos( "C1E_CNPJTR" )
		oView:SetOwnerView( 'VIEW_C1Ej' , 'C1Ej')
	EndIf
	If lReinf1F // Reinf Fase 1
		oView:SetOwnerView( 'VIEW_C1Ek' , 'C1Ek')

		oView:SetOwnerView( 'VIEW_C1Ei' , 'C1Ei')
	EndIf

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If !lMenuDif
		xFunRmFStr( oStruC1Ea, "C1E" )
	EndIf

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF050Grv
@type			function
@description	Função de gravação para atender o registro S-1000 ( Informações do Estabelecimento ).
@author			Rodrigo Aguilar
@since			23/09/2013
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
Function TAF050Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

	Local oModel			:=	Nil
	Local cCmpsNoUpd	:=	"|C1E_FILIAL|C1E_ID|C1E_VERSAO|C1E_FILTAF|C1E_CODFIL|C1E_DTINI|C1E_DTFIN|C1E_VERANT|C1E_PROTPN|C1E_EVENTO|C1E_STATUS|C1E_ATIVO|C1E_CNAE|C1E_ALIRAT|C1E_FAP|C1E_AJURAT|C1E_PRFRAT|C1E_DTCRPP|C1E_DTERPP|C1E_FAXCNT|C1E_LEIRPP|C1E_PRFFAP|C1E_SOCOST|C1E_UF|C1E_CODMUN|"
	Local cCabec			:=	"/eSocial/evtInfoEmpregador/infoEmpregador"
	Local cCRMPath		:=	""
	Local cInconMsg		:=	""
	Local cEnter		:=	Chr( 13 ) + Chr( 10 )
	Local cDataIni		:=	""
	Local cDataFim		:=	""
	Local cCodEvent		:=	Posicione( "C8E", 2, xFilial( "C8E" ) + "S-" + cLayout, "C8E->C8E_ID" )
	Local cChave		:=	""
	Local cPerIni		:=	""
	Local cPerFin		:=	""
	Local cPerIniOri	:=	""
	Local nlI			:=	0
	Local nlJ			:=	0
	Local nSeqErrGrv	:=	0
	Local nIndex		:=	7
	Local nTamCod		:=	TamSX3( "C1E_CODFIL" )[1]
	Local aIncons		:=	{}
	Local aRules		:=	{}
	Local aChave		:=	{}
	Local aTel			:=	{}
	Local aNewData		:=	{ Nil, Nil }
	Local lRet			:=	.F.
	Local cLogOpeAnt	:=	""
	Local cMensagem		:=	""
	Local lIncAlt			:= .F. // Inclusão == true | Alteração == false
	Local cNovaData		:= ""

	Private oDados			:=	Nil
	Private lVldModel		:=	.T.  //Caso a chamada seja via integração, seto a variável de controle de validação como .T.


	Default cLayout 		:= ""
	Default nOpc			:=	1
	Default cFilEv			:=	""
	Default oXML			:=	Nil
	Default cOwner			:=	""
	Default cFilTran		:=	""
	Default cPredeces		:=	""
	Default cComplem		:=	""
	Default cGrpTran		:=	""
	Default cEmpOriGrp	:=	""
	Default cFilOriGrp	:=	""
	Default cXmlID			:=	""

	oDados := oXML
	cChave := PadR( cFilEv, nTamCod )

	// Variável que indica se o ambiente é válido para o eSocial
	If !TafVldAmb("2")
		cMensagem := STR0025 + cEnter // #"Dicionário Incompatível"
		cMensagem += TafAmbInvMsg()

		Aadd(aIncons, cMensagem)

	Else
		//Para o cadastro de complemento de empresa a chave de busca
		//de informacoes na tabela eh o codigo da filial, nao se considera a
		//data inicial e final constante no layout do E-Social
		Aadd( aChave, { "C", "C1E_CODFIL", cFilEv, .T. } )

		//Para o registro S-1000 nao existe o conceito de inclusao, o usuario
		//deve incluir manualmente um cadastro na tabela de complemento de
		//empresa onde indica a relacao De/Para das informacoes, abaixo eu indico
		//qual sera as TAGS que serao utilizadas para busca das informacoes
		If nOpc == 3
			cTagOper := "/inclusao"
		ElseIf nOpc == 4
			cTagOper := "/alteracao"
		ElseIf nOpc == 5
			cTagOper := "/exclusao"
		EndIf

		If nOpc == 4

			If oDados:XPathHasNode( cCabec + cTagOper + "/novaValidade/iniValid", 'C', .F., @aIncons, .F., '', ''  )
				cDataIni := FTafGetVal( cCabec + cTagOper + "/novaValidade/iniValid", 'C', .F., @aIncons, .F., '', '' )
				cDataIni := TAF050Format(cDataIni)
			EndIf

			If oDados:XPathHasNode( cCabec + cTagOper + "/novaValidade/fimValid"   )
				cDataFim := FTafGetVal( cCabec + cTagOper + "/novaValidade/fimValid", 'C', .F., @aIncons, .F., '', '' )
				cDataFim := TAF050Format(cDataFim)
			EndIf

		EndIf

		If Empty(AllTrim(cDataIni))
			If oDados:XPathHasNode( cCabec + cTagOper + "/idePeriodo/iniValid"   )
				cDataIni	:= FTafGetVal( cCabec + cTagOper + "/idePeriodo/iniValid", 'C', .F., @aIncons, .F., '', '' )
				cDataIni 	:= TAF050Format(cDataIni)
				cPerIni	:= cDataIni
				cPerIniOri	:= cDataIni
			EndIf

			If oDados:XPathHasNode( cCabec + cTagOper + "/idePeriodo/fimValid"   )
				cDataFim 	:= FTafGetVal( cCabec + cTagOper + "/idePeriodo/fimValid", 'C', .F., @aIncons, .F., '', '' )
				cDataFim 	:= TAF050Format(cDataFim)
				cPerFin	:= cDataFim
			EndIf
		EndIf

		If nOpc == 4
			If oDados:XPathHasNode( cCabec + cTagOper + "/novaValidade/iniValid", 'C', .F., @aIncons, .F., '', ''  )
				cDataIni	:= FTafGetVal( cCabec + cTagOper + "/novaValidade/iniValid", 'C', .F., @aIncons, .F., '', '' )
				cDataIni 	:= TAF050Format(cDataIni)
				cPerIni		:= cDataIni
				aNewData[1]	:= cDataIni
			EndIf

			If oDados:XPathHasNode( cCabec + cTagOper + "/novaValidade/fimValid"   )
				cDataFim	:= FTafGetVal( cCabec + cTagOper + "/novaValidade/fimValid", 'C', .F., @aIncons, .F., '', '' )
				cDataFim 	:= TAF050Format(cDataFim)
				cPerFin		:= cDataFim
				aNewData[2]	:= cDataFim
			EndIf

		EndIf

		//Regra de Nova validade não aplica em S-1000
		//Valida as regras da nova validade não se aplica para o S-1000
		/*If Empty(aIncons)
		VldEvTab( "C1E", 9, cChave, cPerIni, cPerFin, 2, nOpc,@aIncons, cPerIniOri )
	EndIf*/

		C1E->(DBSetOrder())
	If C1E->( MsSeek( xFilial("C1E") + cChave + "1" ))
		If C1E->C1E_STATUS = '4'
				nOpc := 4
		EndIf
	EndIf

	If oDados:XPathHasNode(cCabec + "/alteracao")
		If oDados:XPathHasNode( cCabec + "/alteracao/novaValidade/iniValid")
				cNovaData := FTafGetVal( cCabec + cTagOper + "/novaValidade/iniValid", 'C', .F., @aIncons, .F., '', '' )
				lIncAlt := .F.
		EndIf
	ElseIf oDados:XPathHasNode(cCabec + "/inclusao")
			lIncAlt := .T.
	EndIf

	Begin Transaction

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Funcao para validar se a operacao desejada pode ser realizada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FTafVldOpe( 'C1E',nIndex, @nOpc, cFilEv, @aIncons, aChave, @oModel, 'TAFA050', cCmpsNoUpd, 2, .T., aNewData )

			If TafColumnPos( "C1E_LOGOPE" )
					cLogOpeAnt := C1E->C1E_LOGOPE
			endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
				//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpc <> 5

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Carrego array com os campos De/Para de gravacao das informacoes³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aRules := TAF050Rul( cTagOper, @cInconMsg, @nSeqErrGrv, cCodEvent, cOwner )

					oModel:LoadValue( "MODEL_C1E", "C1E_FILTAF", C1E->C1E_FILTAF )
					oModel:LoadValue( "MODEL_C1E", "C1E_CODFIL", C1E->C1E_CODFIL )
					oModel:LoadValue( "MODEL_C1E", "C1E_MATRIZ", C1E->C1E_MATRIZ )

				If !Empty(cDataIni)
						oModel:LoadValue( "MODEL_C1E", "C1E_DTINI", cDataIni )
				EndIf

				If !Empty(cDataFim)
						oModel:LoadValue( "MODEL_C1E", "C1E_DTFIN", cDataFim )
				EndIf

				If TAFColumnPos( "C1E_XMLID" )
						oModel:LoadValue( "MODEL_C1E", "C1E_XMLID", cXmlID )
				EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Rodo o aRules para gravar as informacoes³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nlI := 1 To Len( aRules )
						oModel:LoadValue( "MODEL_C1E", aRules[ nlI, 01 ], FTafGetVal( aRules[ nlI, 02 ], aRules[nlI, 03], aRules[nlI, 04], @aIncons, .F., ,aRules[ nlI, 01 ] ) )
				Next

				If Findfunction("TAFAltMan")
					if nOpc == 3
							TafAltMan( nOpc , 'Grv' , oModel, 'MODEL_C1E', 'C1E_LOGOPE' , '1', '' )
					elseif nOpc == 4
							TafAltMan( nOpc , 'Grv' , oModel, 'MODEL_C1E', 'C1E_LOGOPE' , '', cLogOpeAnt )
					EndIf
				endif

				/*----------------------------------------------------------
				Informações do registro Filho CRM
				----------------------------------------------------------*/
				//Quando se trata de uma alteracao, deleto todas as linhas do Grid
			
				cCRMPath := cCabec + cTagOper + "/infoCadastro/softwareHouse[1]"				

				If nOpc == 4 .And. !isVersionCompatible("S_01_00_00")
					For nlJ := 1 to oModel:GetModel( "MODEL_CRM" ):Length()
							oModel:GetModel( "MODEL_CRM" ):GoLine(nlJ)
							oModel:GetModel( "MODEL_CRM" ):DeleteLine()
					Next nlJ
				EndIf

				//Rodo o XML parseado para gravar as novas informacoes no GRID
				If !isVersionCompatible("S_01_00_00")
					nlJ := 1
					While oDados:XPathHasNode(cCabec + cTagOper + "/infoCadastro/softwareHouse[" + cValToChar(nlJ)+ "]" )

						If nOpc == 4 .or. nlJ > 1
									oModel:GetModel( "MODEL_CRM" ):lValid:= .T.
									oModel:GetModel( "MODEL_CRM" ):AddLine()
						EndIf

						If oDados:XPathHasNode( cCabec + cTagOper + "/infoCadastro/softwareHouse[" + cValToChar(nlJ)+ "]/cnpjSoftHouse" )
									oModel:LoadValue( "MODEL_CRM", "CRM_CNPJ"  , FTafGetVal( cCabec + cTagOper + "/infoCadastro/softwareHouse[" + cValToChar(nlJ)+ "]/cnpjSoftHouse"	, "C", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode( cCabec + cTagOper + "/infoCadastro/softwareHouse[" + cValToChar(nlJ)+ "]/nmRazao"  )
									oModel:LoadValue( "MODEL_CRM", "CRM_NOME"  , FTafGetVal( cCabec + cTagOper + "/infoCadastro/softwareHouse[" + cValToChar(nlJ)+ "]/nmRazao"      	, "C", .F., @aIncons, .F. ) )
						EndIF

						If oDados:XPathHasNode( cCabec + cTagOper + "/infoCadastro/softwareHouse[" + cValToChar(nlJ)+ "]/nmCont"  )
									oModel:LoadValue( "MODEL_CRM", "CRM_CONTAT", FTafGetVal( cCabec + cTagOper + "/infoCadastro/softwareHouse[" + cValToChar(nlJ)+ "]/nmCont"     		, "C", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode( cCabec + cTagOper + "/infoCadastro/softwareHouse[" + cValToChar(nlJ)+ "]/telefone"  )
									aTel := TafNormTelES(FTafGetVal( cCabec + cTagOper + "/infoCadastro/softwareHouse[" + cValToChar(nlJ)+ "]/telefone" , "C", .F., @aIncons, .F. ))

									oModel:LoadValue( "MODEL_CRM", "CRM_DDD"   , FTafGetVal( aTel[1], "C", .T., @aIncons, .F. ) )
									oModel:LoadValue( "MODEL_CRM", "CRM_FONE"  , FTafGetVal( aTel[2], "C", .T., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode( cCabec + cTagOper + "/infoCadastro/softwareHouse[" + cValToChar(nlJ)+ "]/email"  )
									oModel:LoadValue( "MODEL_CRM", "CRM_MAIL"  , FTafGetVal( cCabec + cTagOper + "/infoCadastro/softwareHouse[" + cValToChar(nlJ)+ "]/email"              , "C", .F., @aIncons, .F. ) )
						EndIf

								nlJ ++
					EndDo
				EndIf
				
				// Em caso de alteração que envolva a data, transforma o evento em uma "inclusao"
				If nOpc == 4
					If !lIncAlt .And. !Empty(cNovaData)
						If oModel:GetModel("MODEL_C1E"):GetValue( "C1E_DTINI" ) <> SubStr(cNovaData,6,2) + SubStr(cNovaData,1,4)
								oModel:LoadValue('MODEL_C1E', 'C1E_EVENTO', "I")
						Else
								oModel:LoadValue('MODEL_C1E', 'C1E_EVENTO', "A")
						EndIf
					ElseIf lIncAlt
							oModel:LoadValue('MODEL_C1E', 'C1E_EVENTO', "I")
					EndIf
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
					DisarmTransaction()
			EndIf

				oModel:DeActivate()
			If FindFunction('TafClearModel')
					TafClearModel(oModel)
			EndIf
		EndIf

	End Transaction

		//Zerando os arrays e os Objetos utilizados no processamento
		aSize( aRules, 0 )
		aRules     := Nil

		aSize( aChave, 0 )
		aChave     := Nil

EndIf

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF050Rul
Regras para gravacao das informacoes do registro S-1000 do E-Social

@Param
cTagOper - Qual a estrutura de Tags que serao lidas para
gravacao das informacoes

@Return
aRull  - Regras para a gravacao das informacoes

@author Rodrigo Aguilar
@since 23/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF050Rul( cTagOper, cInconMsg, nSeqErrGrv, cCodEvent, cOwner )

	Local cCabec		:= "/eSocial/evtInfoEmpregador/infoEmpregador"
	Local aRull		    := {}
	Local aTel			:= {}
	Local lEmpty        := .F.
	Local cVerSchema	:= SuperGetMv('MV_TAFVLES',.F.,"02_04_02")

	Default cTagOper    := ""
	Default cInconMsg   := ""
	Default nSeqErrGrv  := 0
	Default cCodEvent   := ""
	Default cOwner      := ""

	//Campos apenas para inclusao / alteracao
	If cTagOper ==  "/inclusao" .OR. cTagOper ==  "/alteracao"

		If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/classTrib" ) )
			Aadd( aRull, { "C1E_CLAFIS", FGetIdInt( "classTrib", , cCabec + cTagOper + "/infoCadastro/classTrib",,,,@cInconMsg, @nSeqErrGrv), "C", .T. } ) //classTrib
		EndIf

		If !isVersionCompatible("S_01_00_00")
			If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/natJurid" ) )
				Aadd( aRull, { "C1E_NATJUR", FGetIdInt( "natJuridica", , cCabec + cTagOper + "/infoCadastro/natJurid",,,,@cInconMsg, @nSeqErrGrv), "C", .T. } ) //natJurid
			EndIf

			If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/nmRazao" ) )
				Aadd( aRull, { "C1E_NOME"  , cCabec + cTagOper + "/infoCadastro/nmRazao", "C", .F. } ) //nmRazao"
			EndIf

		EndIf

		If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/indCoop" ) )
			Aadd( aRull, { "C1E_INCOOP", cCabec + cTagOper + "/infoCadastro/indCoop", "C", .F. } ) //indCoop
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/indConstr" ) )
			Aadd( aRull, { "C1E_INCONS", cCabec + cTagOper + "/infoCadastro/indConstr", "C", .F. } ) //indConstr
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/indDesFolha" ) )
			Aadd( aRull, { "C1E_DESFOL", cCabec + cTagOper + "/infoCadastro/indDesFolha", "C", .F. } ) //indDesFolha
		EndIf

		If cVerSchema >= "02_05_00"
			If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/indOpcCP" ) )
				Aadd( aRull, { "C1E_INDCP", cCabec + cTagOper + "/infoCadastro/indOpcCP", "C", .F. } ) //indOpcCP
			EndIf
			If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/indPorte" ) )
				Aadd( aRull, { "C1E_PORTE", cCabec + cTagOper + "/infoCadastro/indPorte", "C", .F. } ) //indPorte
			EndIf
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/indOptRegEletron" ) )
			Aadd( aRull, { "C1E_REGELT", cCabec + cTagOper + "/infoCadastro/indOptRegEletron", "C", .F. } ) //indOptRegEletron
		EndIf

		If isVersionCompatible("S_01_00_00")
			If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/cnpjEFR" ) )
				Aadd( aRull, { "C1E_CPNJER", cCabec + cTagOper + "/infoCadastro/cnpjEFR", "C", .F. } ) //cnpjEFR
			EndIf
		EndIf

		If isVersionCompatible("S_01_00_00") .And. TafColumnPos("C1E_DTTRSO")
			If TafXNode(oDados, cCodEvent, cOwner, cCabec + cTagOper + "/infoCadastro/dtTrans11096")
				Aadd(aRull, {"C1E_DTTRSO", cCabec + cTagOper + "/infoCadastro/dtTrans11096", "D", .F.})
			EndIf
		EndIf

		If isVersionCompatible("S_01_01_00",, .T.) .And. TafColumnPos("C1E_PISCOF")
			If TafXNode(oDados, cCodEvent, cOwner, cCabec + cTagOper + "/infoCadastro/indTribFolhaPisCofins")
				Aadd(aRull, {"C1E_PISCOF", xFunTrcSN(TAFExisTag(cCabec + cTagOper + "/infoCadastro/indTribFolhaPisCofins"), 5), "C", .T.})
			EndIf
		EndIf

		If !isVersionCompatible("S_01_00_00")
			If TAFColumnPos("C1E_ENTEDU") .And. TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/indEntEd" ) )
				Aadd( aRull, { "C1E_ENTEDU", xFunTrcSN(TAFExisTag(cCabec + cTagOper + "/infoCadastro/indEntEd"),4), "C", .T. } ) //indEntEd
			Endif

			If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/indEtt" ) )
				Aadd( aRull, { "C1E_INDETT", xFunTrcSN(TAFExisTag(cCabec + cTagOper + "/infoCadastro/indEtt"),2), "C", .T. } ) //indConstr
			EndIf

			If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/nrRegEtt" )	)
				Aadd( aRull, { "C1E_NRETT", cCabec + cTagOper + "/infoCadastro/nrRegEtt", "C", .F. } ) //indDesFolha
			EndIf
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/dadosIsencao/ideMinLei" ) )
			Aadd( aRull, { "C1E_SIGMIN", cCabec + cTagOper + "/infoCadastro/dadosIsencao/ideMinLei", "C", .F. } ) //ideMinLei
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner,(  cCabec + cTagOper + "/infoCadastro/dadosIsencao/nrCertif" ) )
			Aadd( aRull, { "C1E_NRCERT", cCabec + cTagOper + "/infoCadastro/dadosIsencao/nrCertif", "C", .F. } ) //nrCertif
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/dadosIsencao/dtEmisCertif" ) )
			Aadd( aRull, { "C1E_DTEMCE", cCabec + cTagOper + "/infoCadastro/dadosIsencao/dtEmisCertif", "D", .F. } ) //dtEmisCertif
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/dadosIsencao/dtVencCertif" ) )
			Aadd( aRull, { "C1E_DTVCCE", cCabec + cTagOper + "/infoCadastro/dadosIsencao/dtVencCertif", "D", .F. } ) //dtVencCertif
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/dadosIsencao/nrProtRenov" ) )
			Aadd( aRull, { "C1E_NRPRRE", cCabec + cTagOper + "/infoCadastro/dadosIsencao/nrProtRenov", "C", .F. } ) //nrProtRenov
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/dadosIsencao/dtProtRenov" ) )
			Aadd( aRull, { "C1E_DTPRRE", cCabec + cTagOper + "/infoCadastro/dadosIsencao/dtProtRenov", "D", .F. } ) //dtProtRenov
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/dadosIsencao/dtDou" ) )
			Aadd( aRull, { "C1E_DTDOU ", cCabec + cTagOper + "/infoCadastro/dadosIsencao/dtDou", "D", .F. } ) //dtDou
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/dadosIsencao/pagDou" ) )
			Aadd( aRull, { "C1E_PAGDOU", cCabec + cTagOper + "/infoCadastro/dadosIsencao/pagDou", "C", .F. } ) //pagDou
		EndIf

		If !isVersionCompatible("S_01_00_00")
			If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/contato/nmCtt" ) )
				Aadd( aRull, { "C1E_NOMCNT", cCabec + cTagOper + "/infoCadastro/contato/nmCtt", "C", .F. } ) //nmCtt
			EndIf

			If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/contato/cpfCtt" ) )
				Aadd( aRull, { "C1E_CPFCNT", cCabec + cTagOper + "/infoCadastro/contato/cpfCtt", "C", .F. } ) //cpfCtt
			EndIf

			If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/contato/foneFixo" ) )
				aTel := TafNormTelES(FTafGetVal( cCabec + cTagOper + "/infoCadastro/contato/foneFixo" , "C", .F., @cInconMsg, .F. ) )

				Aadd( aRull, { "C1E_DDDFON", aTel[1], "C", .T. } ) //foneFixo
				Aadd( aRull, { "C1E_FONCNT", aTel[2], "C", .T. } ) //foneFixo
			EndiF

			If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/contato/foneCel" ) )
				aTel := TafNormTelES(FTafGetVal( cCabec + cTagOper + "/infoCadastro/contato/foneCel" , "C", .F., @cInconMsg, .F. ) )

				Aadd( aRull, { "C1E_DDDCEL", aTel[1], "C", .T. } ) //foneCel
				Aadd( aRull, { "C1E_CELCNT", aTel[2], "C", .T. } ) //foneCel
			EndIf

			If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/contato/email" ) )
				Aadd( aRull, { "C1E_EMAIL" , cCabec + cTagOper + "/infoCadastro/contato/email", "C", .F. } ) //email
			EndIf

			If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/infoOP/nrSiafi" ) )
				Aadd( aRull, { "C1E_SIAFI", cCabec + cTagOper + "/infoCadastro/infoOP/nrSiafi", "C", .F. } ) //nrSiafi
			Endif

			If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/infoOP/infoEFR/ideEFR" ) ) //ideEFR"
				Aadd( aRull, { "C1E_EFR", +;
					xFunTrcSN( TAFExisTag( cCabec + cTagOper + "/infoCadastro/infoOP/infoEFR/ideEFR" ) ,2), "C", .T. } )
			Endif

			If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/infoOP/infoEFR/cnpjEFR" ) )
				Aadd( aRull, { "C1E_CPNJER", cCabec + cTagOper + "/infoCadastro/infoOP/infoEFR/cnpjEFR", "C", .F. } ) //cnpjEFR
			Endif

			If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/infoOP/infoEnte/nmEnte" )	)
				Aadd( aRull, { "C1E_NMENTE", cCabec + cTagOper + "/infoCadastro/infoOP/infoEnte/nmEnte", "C", .F. } ) //nmEnte
			Endif

			If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/infoOP/infoEnte/uf" ) )
				aAdd( aRull, { "C1E_UF", FGetIdInt( "uf", "",cCabec + cTagOper + "/infoCadastro/infoOP/infoEnte/uf",,,,@cInconMsg, @nSeqErrGrv,,, @lEmpty ), "C", .T. } ) //uf
			EndIf

			If !lEmpty
				If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/infoOP/infoEnte/uf") ) .OR. TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/infoOP/infoEnte/codMunic" ) )//codMunic
					aAdd( aRull, { "C1E_CODMUN", FGetIdInt( "codMunic", "uf", cCabec + cTagOper + "/infoCadastro/infoOP/infoEnte/uf",;
						cCabec + cTagOper + "/infoCadastro/infoOP/infoEnte/codMunic",,,@cInconMsg, @nSeqErrGrv), "C", .T. } )
				EndIf
			EndIf

			If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/infoOP/infoEnte/indRPPS" ) )	//indRPPS
				Aadd( aRull, { "C1E_RPPS", +;
					xFunTrcSN( TAFExisTag( cCabec + cTagOper + "/infoCadastro/infoOP/infoEnte/indRPPS" ) ,2), "C", .T. } )
			Endif

			If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/infoOP/infoEnte/subteto" ) )
				Aadd( aRull, { "C1E_SUBTET", cCabec + cTagOper + "/infoCadastro/infoOP/infoEnte/subteto", "C", .F. } ) //subteto
			Endif

			If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/infoOP/infoEnte/vrSubteto" ) )
				Aadd( aRull, { "C1E_VLRSUB", cCabec + cTagOper + "/infoCadastro/infoOP/infoEnte/vrSubteto", "N", .F. } ) //vrSubteto
			Endif

			If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/infoComplementares/situacaoPJ/indSitPJ" ) )
				Aadd( aRull, { "C1E_SITESP", cCabec + cTagOper + "/infoCadastro/infoComplementares/situacaoPJ/indSitPJ", "C", .F. } ) //indSitPJ
			EndIf

			If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/infoComplementares/situacaoPF/indSitPF" ) )
				Aadd( aRull, { "C1E_SITPF" , cCabec + cTagOper + "/infoCadastro/infoComplementares/situacaoPF/indSitPF", "C", .F. } ) //indSitPF
			EndIF

		EndIf

		If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/infoCadastro/infoOrgInternacional/indAcordoIsenMulta" ) )
			Aadd( aRull, { "C1E_ISEMUL", cCabec + cTagOper + "/infoCadastro/infoOrgInternacional/indAcordoIsenMulta", "C", .F. } ) //indAcordoIsenMulta
		EndIf

		If cTagOper ==  "/alteracao" .And. !Empty(C1E->C1E_CNPJTR)
			Aadd( aRull, { "C1E_CNPJTR" , C1E->C1E_CNPJTR, "C", .T.})
		EndIf

	EndIf

Return ( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Função de validação da inclusão dos dados, no momento da gravação do modelo.

@Param		oModel - Modelo de dados

@Return	lRet - Indica se o modelo é válido para gravação

@Author	Felipe C. Seolin
@Since		28/03/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ValidModel( oModel )

	Local oModelC1E	 := oModel:GetModel( "MODEL_C1E" )
	Local oModelCR9	 := oModel:GetModel( "MODEL_CR9" )
	Local cID		 := ""
	Local nOperation := oModel:GetOperation()
	Local aAreaCUW   := CUW->( GetArea() )
	Local lRet       := .T.

	Local lVldFils		:= .F.
	Local lChkFils	 	:= SuperGetMv("MV_TAFCFGE", .F., .F.)
	Local cC1ECod    	:= ""
	Local cC1EFil    	:= ""

	Local aChkC1EFils	:= {}
	Local aChkCR9Fils	:= {}
	Local aDuplic		:= {}
	Local cMsgHelp		:= ""

	Local nCR9
	Local nX

	Local lV81    := TAFAlsInDic( "V81" )
	Local nV81    := 0
	Local nAteV81 := 0
	Local nSumV81 := 0
	Local nLimit  := 100
	Local oMdlV81 := Nil

	If nOperation == MODEL_OPERATION_DELETE
		cID := oModelC1E:GetValue( "C1E_ID" )

		DBSelectArea( "CUW" )
		CUW->( DBSetOrder( 2 ) )
		If CUW->( MsSeek( xFilial( "CUW" ) + cID ) ) .and. CUW->CUW_ID <> cID
			lRet := .F.
			Help( ,, STR0028,, STR0029 + AllTrim( xFunID2Cd( CUW->CUW_ID, "C1E", 2 ) ), 1, 0 ) //##"Atenção!" ##"Esta Filial não pode ser excluída porque está relacionada como SCP da Filial"
		EndIf
	EndIf

	If nOperation == MODEL_OPERATION_INSERT
		lVldFils := .T.
	ElseIf nOperation == MODEL_OPERATION_UPDATE .And. !lChkFils
		lVldFils := .T.
	EndIf

	If lVldFils
		cID 	:= oModelC1E:GetValue( "C1E_ID" )
		cC1ECod := oModelC1E:GetValue( "C1E_CODFIL" )
		cC1EFil := oModelC1E:GetValue( "C1E_FILIAL" )

		aAdd( aChkC1EFils, AllTrim(cC1ECod) )

		For nCR9 := 1 To oModelCR9:Length()
			oModelCR9:GoLine(nCR9)
			If !oModelCR9:IsDeleted() .And. !oModelCR9:IsEmpty()
				aAdd( aChkCR9Fils, AllTrim(oModelCR9:GetValue("CR9_CODFIL")) )
			EndIf
		Next nCR9

		If !VldChkFils( cID, aChkC1EFils, aChkCR9Fils, .F., @aDuplic )[1]

			cMsgHelp := STR0051  + Chr(13) + Chr(10) + Chr(13) + Chr(10)

			If Len(aDuplic) > 0
				For nX := 1 To Len(aDuplic)
					cMsgHelp += "<b>" + aDuplic[nX] + "</b>" + Chr(13) + Chr(10)
				Next nX
			EndIf

			lRet := .F.
			Help( ,, STR0050,, cMsgHelp, 1, 0,,,,,,{ STR0052 } )
		EndIf
	EndIf

	if lRet .And. lV81
		nSumV81 := 0
		oMdlV81 := oModel:GetModel( 'MODEL_V81' )
		nAteV81 := oMdlV81:Length()

		For nV81 := 1 To nAteV81
			oMdlV81:GoLine(nV81)
			If !oMdlV81:IsDeleted() .And. !oMdlV81:IsEmpty()
				nSumV81 += oMdlV81:GetValue("V81_PERC")
				if nSumV81 <> nLimit
					lRet := .F.
				else
					lRet := .T.
				endif
			EndIf
		Next nV81
		if !lRet
			Help(,,STR0053,,STR0054,1,0,,,,,,{STR0055}) //"Atenção"##"A soma do rateio por municípios no DipamB 2.6 não é de 100%"##"Preencha corretamente o campo % Rateio"
		endif
	endif

	RestArea( aAreaCUW )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@Author Felipe C. Seolin
@Since 24/09/2013
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local cLogOpeAnt	:= ""
	Local cDataAtual	:= ""
	Local cIDCIE		:= ""

	Local cVerAnt    	:= ""
	Local cProtocolo 	:= ""
	Local cVersao    	:= ""
	Local cEvento	 	:= ""
	Local cChvRegAnt 	:= ""
	Local nOperation 	:= oModel:GetOperation()

	Local aGrava     	:= {}
	Local aGravaCRM  	:= {}
	Local aGravaCR9		:= {}
	Local aGravaCZR		:= {}
	Local aGravaCUW		:= {}
	Local aGravaC1F		:= {}
	Local aGravaV81		:= {}

	Local oModelC1E  	:= Nil
	Local oModelCRM  	:= Nil
	Local oModelCR9  	:= Nil

	Local nC1E			:= 0
	Local nCRM			:= 0
	Local nCR9			:= 0
	Local nCZR			:= 0
	Local nCUW			:= 0
	Local nC1F			:= 0
	Local nV81			:= 0

	Local nLinCRM		:= 0

	Local lRetorno	    := .T.
	Local lForceI       := .T.

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT

			TafAjustID( "C1E", oModel)

			oModel:LoadValue( 'MODEL_C1E', 'C1E_VERSAO', xFunGetVer() )

			If Findfunction("TAFAltMan")
				TafAltMan( 3 , 'Save' , oModel, 'MODEL_C1E', 'C1E_LOGOPE' , '2', '' )
			endif

			If FwFormCommit( oModel )
				grvWsST2Fils(oModel,nOperation)
			EndIf

		ElseIf nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			C1E->( DbSetOrder( 5 ) )
			If C1E->( MsSeek( xFilial( 'C1E' ) + FwFldGet('C1E_ID')+ '1' ) )

				cIDCIE := C1E->C1E_ID
				cDataAtual := C1E->C1E_DTINI

				If !lEsocial 

					oModelCRM := oModel:GetModel( 'MODEL_CRM' )

					For nLinCRM := 1 To oModel:GetModel( 'MODEL_CRM' ):Length()

						oModel:GetModel( 'MODEL_CRM' ):GoLine(nLinCRM)
						If	oModelCRM:IsUpdated(nLinCRM)
							lEsocial := .T.
						EndIf

					Next nLinCRM

				EndIf

				If !lEsocial .And. nOperation == MODEL_OPERATION_UPDATE

					If C1E->C1E_STATUS $ "013"
						TAFAltStat("C1E"," ")
					EndIf

					If TAFColumnPos("C1E_PROCID") .And. !isVersionCompatible("S_01_00_00")
						lAltReinf := TafAltReinf()
					Else
						lAltReinf := .F.
					EndIf

					If FwFormCommit(oModel)
						grvWsST2Fils(oModel,nOperation)
						If lAltReinf .And. FindFunction("TafEndGRV")
							TafEndGRV( "C1E","C1E_PROCID", "", C1E->(Recno())  )
						EndIf
					EndIf

				Else

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se o registro ja foi transmitido³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If C1E->C1E_STATUS == "4"

						oModelC1E := oModel:GetModel( 'MODEL_C1E' )					
						oModelCRM := oModel:GetModel( 'MODEL_CRM' )
						oModelCUW := oModel:GetModel( 'MODEL_CUW' )
						oModelCR9 := oModel:GetModel( 'MODEL_CR9' )
						oModelC1F := oModel:GetModel( 'MODEL_C1F' )
						if TAFAlsInDic( "V81" )
							oModelV81 := oModel:GetModel( 'MODEL_V81' )
						endif
						oModelCZR := oModel:GetModel( 'MODEL_CZR' )

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Busco a versao anterior do registro para gravacao do rastro³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cVerAnt    	:= oModelC1E:GetValue( "C1E_VERSAO" )
						cProtocolo	:= oModelC1E:GetValue( "C1E_PROTUL" )
						cEvento		:= oModelC1E:GetValue( "C1E_EVENTO" )

						If TafColumnPos( "C1E_LOGOPE" )
							cLogOpeAnt := oModelC1E:GetValue( "C1E_LOGOPE" )
						endif

						If nOperation == MODEL_OPERATION_DELETE .And. cEvento == "E"
							// Não é possível excluir um evento de exclusão já transmitido
							TAFMsgVldOp(oModel,"4")
							lRetorno := .F.
						Else

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Neste momento eu gravo as informacoes que foram carregadas na tela³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							For nC1E := 1 to Len( oModelC1E:aDataModel[ 1 ] )
								If oModelC1E:aDataModel[ 1, nC1E, 1 ] <> "C1E_XMLID"
									aAdd( aGrava, { oModelC1E:aDataModel[ 1, nC1E, 1 ], oModelC1E:aDataModel[ 1, nC1E, 2 ] } )
								EndIf
							Next nC1E

							
							For nCRM := 1 To oModel:GetModel( 'MODEL_CRM' ):Length()
								oModel:GetModel( 'MODEL_CRM' ):GoLine(nCRM)
								If !oModel:GetModel( 'MODEL_CRM' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_CRM' ):IsEmpty()
									aAdd(aGravaCRM,{oModelCRM:GetValue('CRM_CNPJ'),;
										oModelCRM:GetValue('CRM_NOME'),;
										oModelCRM:GetValue('CRM_CONTAT'),;
										oModelCRM:GetValue('CRM_DDD'),;
										oModelCRM:GetValue('CRM_FONE'),;
										oModelCRM:GetValue('CRM_MAIL')})
								EndIf
							Next nCRM
							

							For nCZR := 1 To oModel:GetModel( 'MODEL_CZR' ):Length()
								oModel:GetModel( 'MODEL_CZR' ):GoLine(nCZR)
								If !oModel:GetModel( 'MODEL_CZR' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_CZR' ):IsEmpty()
									aAdd(aGravaCZR,{oModelCZR:GetValue('CZR_ID'),;
										oModelCZR:GetValue('CZR_IDOBRI')})
								EndIf
							Next nCZR

							//TAFColumnPos( "C9V_IDTRAN" )
							For nCUW := 1 To oModel:GetModel( 'MODEL_CUW' ):Length()
								oModel:GetModel( 'MODEL_CUW' ):GoLine(nCUW)
								If !oModel:GetModel( 'MODEL_CUW' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_CUW' ):IsEmpty()
									If TAFColumnPos( "CUW_CNPJ" ) .AND.  TAFColumnPos( "CUW_NOMSCP" )
										aAdd(aGravaCUW,{oModelCUW:GetValue('CUW_CODSCP'),;
											oModelCUW:GetValue('CUW_INFCOM'),;
											oModelCUW:GetValue('CUW_CNPJ'),;
											oModelCUW:GetValue('CUW_NOMSCP')})
									Else
										aAdd(aGravaCUW,{oModelCUW:GetValue('CUW_CODSCP'),;
											oModelCUW:GetValue('CUW_INFCOM')})
									EndIf
								EndIf
							Next nCUW

							For nC1F := 1 To oModel:GetModel( 'MODEL_C1F' ):Length()
								oModel:GetModel( 'MODEL_C1F' ):GoLine(nC1F)
								If !oModel:GetModel( 'MODEL_C1F' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_C1F' ):IsEmpty()
									aAdd(aGravaC1F,{oModelC1F:GetValue('C1F_UFST'),;
										oModelC1F:GetValue('C1F_IEST'),;
										oModelC1F:GetValue('C1F_VALIDA')})

								EndIf
							Next nC1F
							if TAFAlsInDic( "V81" )
								For nV81 := 1 To oModel:GetModel( 'MODEL_V81' ):Length()
									oModel:GetModel( 'MODEL_V81' ):GoLine(nV81)
									If !oModel:GetModel( 'MODEL_V81' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_V81' ):IsEmpty()
										aAdd(aGravaV81,{oModelV81:GetValue('V81_UF'),;
														oModelV81:GetValue('V81_CODMUN'),;
														oModelV81:GetValue('V81_PERC')})
									EndIf
								Next nV81
							endif
							For nCR9 := 1 To oModel:GetModel( 'MODEL_CR9' ):Length()
								oModel:GetModel( 'MODEL_CR9' ):GoLine(nCR9)
								If !oModel:GetModel( 'MODEL_CR9' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_CR9' ):IsEmpty()
									aAdd(aGravaCR9,{oModelCR9:GetValue('CR9_CODFIL')})
								EndIf
							Next nCR9

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Seto o campo como Inativo e gravo a versao do novo registro³
							//³no registro anterior                                       ³
							//|                                                           |
							//|ATENCAO -> A alteracao destes campos deve sempre estar     |
							//|abaixo do Loop do For, pois devem substituir as informacoes|
							//|que foram armazenadas no Loop acima                        |
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							FAltRegAnt('C1E','2',.F.,FwFldGet("C1E_DTFIN"),FwFldGet("C1E_DTINI"),C1E->C1E_DTINI)

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Neste momento eu preciso setar a operacao do model³
							//³como Inclusao                                     ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							oModel:DeActivate()
							oModel:SetOperation( 3 )
							oModel:Activate()

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Neste momento o usuario ja fez as modificacoes que          ³
							//³precisava e as mesmas estao armazenadas em memoria, ou seja,³
							//³nao devem ser consideradas agora                            ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							For nC1E := 1 to Len( aGrava )
								oModel:LoadValue( "MODEL_C1E", aGrava[ nC1E, 1 ], aGrava[ nC1E, 2 ] )
							Next nC1E

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Neste momento eu realizo a inclusao do novo registro ja³
							//³contemplando as informacoes alteradas pelo usuario     ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							For nC1E := 1 to Len( aGrava )
								oModel:LoadValue( "MODEL_C1E", aGrava[ nC1E, 1 ], aGrava[ nC1E, 2 ] )
							Next nC1E

							//Necessário Abaixo do For Nao Retirar
							If Findfunction("TAFAltMan")
								TafAltMan( 4 , 'Save' , oModel, 'MODEL_C1E', 'C1E_LOGOPE' , '' , cLogOpeAnt )
							endif

							
							For nCRM := 1 To Len( aGravaCRM )
								If nCRM > 1
									oModel:GetModel( 'MODEL_CRM' ):AddLine()
								EndIf

								oModel:LoadValue( 'MODEL_CRM', 'CRM_CNPJ'  , aGravaCRM[nCRM][1] )
								oModel:LoadValue( 'MODEL_CRM', 'CRM_NOME'  , aGravaCRM[nCRM][2] )
								oModel:LoadValue( 'MODEL_CRM', 'CRM_CONTAT', aGravaCRM[nCRM][3] )
								oModel:LoadValue( 'MODEL_CRM', 'CRM_DDD'   , aGravaCRM[nCRM][4] )
								oModel:LoadValue( 'MODEL_CRM', 'CRM_FONE'  , aGravaCRM[nCRM][5] )
								oModel:LoadValue( 'MODEL_CRM', 'CRM_MAIL'  , aGravaCRM[nCRM][6] )

							Next nCRM
							

							For nCR9 := 1 To Len(aGravaCR9)
								If nCR9 > 1
									oModel:GetModel( 'MODEL_CR9' ):AddLine()
								EndIf
								oModel:LoadValue( 'MODEL_CR9', 'CR9_CODFIL'  , aGravaCR9[nCR9][1] )
							Next nCR9

							For nCZR := 1 To Len( aGravaCZR )
								If nCZR > 1
									oModel:GetModel( 'MODEL_CZR' ):AddLine()
								EndIf
								oModel:LoadValue( 'MODEL_CZR', 'CZR_ID'  	 	 , aGravaCZR[nCZR][1] )
								oModel:LoadValue( 'MODEL_CZR', 'CZR_IDOBRI'  	 , aGravaCZR[nCZR][2] )
							Next nCZR

							For nCUW := 1 To Len( aGravaCUW )
								If nCUW > 1
									oModel:GetModel( 'MODEL_CUW' ):AddLine()
								EndIf
								If TAFColumnPos( "CUW_CNPJ" ) .AND.  TAFColumnPos( "CUW_NOMSCP" )
									oModel:LoadValue( 'MODEL_CUW', 'CUW_CODSCP'  	 , aGravaCUW[nCUW][1] )
									oModel:LoadValue( 'MODEL_CUW', 'CUW_INFCOM'  	 , aGravaCUW[nCUW][2] )
									oModel:LoadValue( 'MODEL_CUW', 'CUW_CNPJ'  	 	 , aGravaCUW[nCUW][3] )
									oModel:LoadValue( 'MODEL_CUW', 'CUW_NOMSCP'  	 , aGravaCUW[nCUW][4] )
								Else
									oModel:LoadValue( 'MODEL_CUW', 'CUW_CODSCP'  	 	 , aGravaCUW[nCUW][1] )
									oModel:LoadValue( 'MODEL_CUW', 'CUW_INFCOM'  	 	 , aGravaCUW[nCUW][2] )
								EndIf
							Next nCUW

							For nC1F := 1 To Len( aGravaC1F )
								If nC1F > 1
									oModel:GetModel( 'MODEL_C1F' ):AddLine()
								EndIf
								oModel:LoadValue( 'MODEL_C1F', 'C1F_UFST'  	 	 , aGravaC1F[nC1F][1] )
								oModel:LoadValue( 'MODEL_C1F', 'C1F_IEST'  	 	 , aGravaC1F[nC1F][2] )
								oModel:LoadValue( 'MODEL_C1F', 'C1F_VALIDA'  	 , aGravaC1F[nC1F][3] )
							Next nC1F
							if TAFAlsInDic( "V81" )
								For nV81 := 1 To Len( aGravaV81 )
									If nV81 > 1
										oModel:GetModel( 'MODEL_V81' ):AddLine()
									EndIf
									oModel:LoadValue( 'MODEL_V81', 'V81_UF'  	 	, aGravaV81[nV81][1] )
									oModel:LoadValue( 'MODEL_V81', 'V81_CODMUN'  	, aGravaV81[nV81][2] )
									oModel:LoadValue( 'MODEL_V81', 'V81_PERC'  	 	, aGravaV81[nV81][3] )
								Next nV81
							endif
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Busco a versao que sera gravada³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cVersao := xFunGetVer()

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//|ATENCAO -> A alteracao destes campos deve sempre estar     |
							//|abaixo do Loop do For, pois devem substituir as informacoes|
							//|que foram armazenadas no Loop acima                        |
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							oModel:LoadValue( 'MODEL_C1E', 'C1E_VERSAO', cVersao )
							oModel:LoadValue( 'MODEL_C1E', 'C1E_VERANT', cVerAnt )
							oModel:LoadValue( 'MODEL_C1E', 'C1E_PROTPN', cProtocolo )
							oModel:LoadValue( 'MODEL_C1E', 'C1E_PROTUL', "" )

							If nOperation == MODEL_OPERATION_DELETE
								oModel:LoadValue( 'MODEL_C1E', 'C1E_EVENTO', "E" )
							ElseIf cEvento == "E" .Or. ( nOperation == MODEL_OPERATION_UPDATE .And. ( oModelC1E:GetValue( "C1E_DTINI" ) <> cDataAtual ) )
								If TAFVldAltD(cIDCIE,oModelC1E:GetValue( "C1E_DTINI" ))
									oModel:LoadValue( 'MODEL_C1E', 'C1E_EVENTO', "A" )
								Else
									oModel:LoadValue( 'MODEL_C1E', 'C1E_EVENTO', "I" )
								EndIf
							Else
								oModel:LoadValue( 'MODEL_C1E', 'C1E_EVENTO', "A" )
							EndIf

							If TAFColumnPos("C1E_PROCID") .And. !isVersionCompatible("S_01_00_00")
								lAltReinf := TafAltReinf()
							Else
								lAltReinf := .F.
							EndIf

							If FwFormCommit(oModel)
								grvWsST2Fils(oModel,nOperation)
								If lAltReinf .And. FindFunction("TafEndGRV")
									TafEndGRV( "C1E","C1E_PROCID", "", C1E->(Recno())  )
								EndIf
							EndIf

						EndIf

					ElseIf C1E->C1E_STATUS == "2"
						//Não é possível alterar um registro com aguardando validação
						TAFMsgVldOp(oModel,"2")
						lRetorno := .F.

					Else

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Caso o registro nao tenha sido transmitido ainda, gravo sua chave³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cChvRegAnt := C1E->( C1E_ID + C1E_VERANT )

						If TafColumnPos( "C1E_LOGOPE" )
							cLogOpeAnt := C1E->C1E_LOGOPE
						endif

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³No caso de um evento de Exclusao de um registro com status 'Excluido' deve-se³
						//³perguntar ao usuario se ele realmente deseja realizar a inclusao.            ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If C1E->C1E_EVENTO == "E"
							If nOperation == MODEL_OPERATION_DELETE
								If Aviso( xValStrEr("000754"), xValStrEr("000755"), { xValStrEr("000756"), xValStrEr("000757") }, 1 ) == 2 //##"Registro Excluído" ##"O Evento de exclusão não foi transmitido. Deseja realmente exclui-lo ou manter o evento de exclusão para transmissão posterior ?" ##"Excuir" ##"Manter"
									cChvRegAnt := ""
								EndIf
							Else
								oModel:LoadValue( "MODEL_C1E", "C1E_EVENTO", "A" )
							EndIf
						Else
							lForceI := .F.
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Executo a operacao escolhida³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty( cChvRegAnt )

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Funcao responsavel por setar o Status do registro para Branco³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							TAFAltStat( "C1E", " " )

							If nOperation == MODEL_OPERATION_UPDATE .And. Findfunction("TAFAltMan")
								TafAltMan( 4 , 'Save' , oModel, 'MODEL_C1E', 'C1E_LOGOPE' , '' , cLogOpeAnt )
							endif

							If FwFormCommit(oModel)
								grvWsST2Fils(oModel,nOperation,lForceI)
								If TAFColumnPos("C1E_PROCID") .And. FindFunction("TafEndGRV")
									TafEndGRV( "C1E","C1E_PROCID", "", C1E->(Recno())  )
								EndIf
							EndIf

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Caso a operacao seja uma exclusao...³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If nOperation == MODEL_OPERATION_DELETE

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³...de um registro com status de alterado/excluido³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If C1E->C1E_EVENTO == "A" .or. C1E->C1E_EVENTO == "E" .Or. ( C1E->C1E_EVENTO == "I" .And. !Empty(cChvRegAnt) )
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Funcao para setar o registro anterior como Ativo³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									TAFRastro( "C1E", 2, cChvRegAnt, .T. )
								EndIf

							EndIf

						EndIf

					EndIf

				EndIf

			ElseIf TafIndexInDic("C1E", 'A', .T.)

				C1E->( DbSetOrder( 10 ) )
				If C1E->( MsSeek( xFilial( 'C1E' ) + FwFldGet('C1E_ID')+ 'E42' ) )

					If nOperation == MODEL_OPERATION_DELETE
						// Não é possível excluir um evento de exclusão já transmitido
						TAFMsgVldOp(oModel,"4")
						lRetorno := .F.
					EndIf

				EndIf

			EndIf

		EndIf

		//Reseto a variavel
		lEsocial := .F.
		aAltEsoc := { }

	End Transaction

Return( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} grvWsST2Fils
Realiza manutenção no array de filias utilizado pelo WS

@author Evandro dos Santos Oliveira
@since 29/12/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function grvWsST2Fils(oModel,nOperation,lForceI)

	Local oModelCR9 := Nil
	Local oModelC1E := Nil
	Local cAuxFil	:= ""
	Local cGrpEmp	:= ""
	Local cUUIDFil  := "tafJobID"
	Local cChaveFil := "keyTafJob"
	Local nPosEmp	:= 0
	Local nPosFil	:= 0
	Local nCR9		:= 0
	Local nTamGrp	:= 0
	Local aEmpresas := {}
	Local lContinue := .T.

	Default lForceI := .F.

	oModelC1E	:= oModel:GetModel("MODEL_C1E")
	oModelCR9 	:= oModel:GetModel("MODEL_CR9")

	cAuxFil 	:= AllTrim(oModelC1E:GetValue("C1E_CODFIL"))
	cAuxFilTAF	:= AllTrim(oModelC1E:GetValue("C1E_FILTAF"))

	cGrpEmp  	:= FWCodEmp()

	If FindFunction("TAFGetDePara")
		If VarGetA(cUUIDFil,cChaveFil, @aEmpresas)
			nPosEmp := aScan(aEmpresas,{|cCodEmp|AllTrim(cCodEmp[1]) == AllTrim(cGrpEmp) })
			If nPosEmp > 0

				If !Empty(aEmpresas[nPosEmp][2])

					nTamGrp := Len(aEmpresas[nPosEmp][2])

					While lContinue
						nPosFil := aScan(aEmpresas[nPosEmp][2],{|cCodFil|AllTrim(cCodFil[2]) == cAuxFilTAF})
						If nPosFil > 0
							aDel(aEmpresas[nPosEmp][2],nPosFil)
							aSize(aEmpresas[nPosEmp][2],nTamGrp-1)
							nTamGrp := Len(aEmpresas[nPosEmp][2])
						Else
							lContinue := .F.
						EndIf
					EndDo

				EndIf

				If nOperation != MODEL_OPERATION_DELETE .Or. lForceI
					//aSize(aEmpresas[nPosEmp][2],0)

					If lForceI
						aAdd(aEmpresas[nPosEmp][2],{AllTrim(C1E->C1E_CODFIL),AllTrim(C1E->C1E_FILTAF)})
					Else
						aAdd(aEmpresas[nPosEmp][2],{AllTrim(cAuxFil),AllTrim(cAuxFilTAF)})
					EndIf

					For nCR9 := 1 To oModelCR9:Length()

						oModelCR9:GoLine(nCR9)
						If !oModelCR9:IsDeleted() .And. !oModelCR9:IsEmpty()

							cAuxFil := oModelCR9:GetValue('CR9_CODFIL')
							aAdd(aEmpresas[nPosEmp][2],{AllTrim(cAuxFil),AllTrim(cAuxFilTAF)})
						EndIf
					Next nCR9
				EndIf

			EndIf

			Iif (!VarSetAD(cUUIDFil,cChaveFil,aEmpresas),TAFConOut("Não foi possivel atualizar as Filiais de De/Para."), Nil)

		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF050Xml
Funcao de geracao do XML para atender o registro S-1000
Quando a rotina for chamada o registro deve estar posicionado

@Param:
cAlias - Alias corrente (Parametro padrao MVC)
nRecno - Recno corrente (Parametro padrao MVC)
nOpc   - Opcao selecionada (Parametro padrao MVC)
lJob   - Informa se foi chamado por Job
cSeqXml - Numero sequencial para composição da chave ID do XML

@Return:
cXml - Estrutura do Xml do Layout S-1000

@author Felipe C. Seolin
@since 18/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF050Xml( cAlias, nRecno, nOpc, lJob, lRemEmp,cSeqXml )

	Local cXml			:=	""
	Local cLayout		:=	"1000"
	Local cReg			:=	"InfoEmpregador"
	Local cEvento		:=	""
	Local cDtIni		:=	""
	Local cDtFin		:=	""
	Local cId			:=	""
	Local cVerAnt		:=	""
	Local cCodMun		:=	""
	Local cXmlIERF		:=	""
	Local cXmlIEnt		:=	""
	Local cNatJurid		:=	""
	Local nRecnoSM0     := SM0->(Recno())
	Local lXmlVLd		:= IIF(FindFunction('TafXmlVLD'),TafXmlVLD('TAF050XML'),.T.)

	Default lJob		:= .F.
	Default lRemEmp		:=  .F.
	Default cSeqXml 	:= ""
	Default nOpc		:=	2

	DBSelectArea("CRM")
	CRM->(DBSetOrder(1))
	If  lXmlVLd
		If C1E->C1E_EVENTO $ "I|A"
			If C1E->C1E_EVENTO == "A"
				cEvento := "alteracao"
				cId := C1E->C1E_ID
				cVerAnt := C1E->C1E_VERANT

				BeginSql alias 'C1ETEMP'
					SELECT C1E.C1E_DTINI,C1E.C1E_DTFIN
					FROM %table:C1E% C1E
					WHERE C1E.C1E_FILIAL= %xfilial:C1E% AND
					C1E.C1E_ID = %exp:cId% AND C1E.C1E_VERSAO = %exp:cVerAnt% AND
					C1E.%notDel%
				EndSql

				cDtIni := Iif(Empty(('C1ETEMP')->C1E_DTINI), "", Substr(('C1ETEMP')->C1E_DTINI,3,4) +"-"+ Substr(('C1ETEMP')->C1E_DTINI,1,2))	//Faço o Iif pois se a data estiver vazia a string recebia '  -  '
				cDtFin := Iif(Empty(('C1ETEMP')->C1E_DTFIN), "", Substr(('C1ETEMP')->C1E_DTFIN,3,4) +"-"+ Substr(('C1ETEMP')->C1E_DTFIN,1,2)) //Faço o Iif pois se a data estiver vazia a string recebia '  -  '

				('C1ETEMP')->( DbCloseArea() )
			Else
				cEvento := "inclusao"
				cDtIni	:= Iif(Empty(C1E->C1E_DTINI), "", Substr(C1E->C1E_DTINI,3,4) +"-"+ Substr(C1E->C1E_DTINI,1,2))	//Faço o Iif pois se a data estiver vazia a string recebia '  -  '
				cDtFin	:= Iif(Empty(C1E->C1E_DTFIN), "", Substr(C1E->C1E_DTFIN,3,4) +"-"+ Substr(C1E->C1E_DTFIN,1,2)) //Faço o Iif pois se a data estiver vazia a string recebia '  -  '
			EndIf

			cXml +=			"<infoEmpregador>"
			cXml +=				"<" + cEvento + ">"
			cXml +=					"<idePeriodo>"
			cXml +=						xTafTag("iniValid",cDtIni)
			If ! Empty(cDtFin)
				cXml +=					xTafTag("fimValid",cDtFin,,.T.)
			EndIf
			cXml +=					"</idePeriodo>"
			cXml +=					"<infoCadastro>"

			If !isVersionCompatible("S_01_00_00")
				If !lRemEmp
					cXml +=						xTafTag("nmRazao",SubStr(C1E->C1E_NOME,1,100),,)
					cXml +=						xTafTag("classTrib",Posicione("C8D",1,xFilial("C8D") + C1E->C1E_CLAFIS,"C8D_CODIGO"))
				Else
					cXml +=						xTafTag("nmRazao","RemoverEmpregadorDaBaseDeDadosDaProducaoRestrita")
					cXml +=						xTafTag("classTrib","00")
				EndIf
			Else
				If !lRemEmp
					cXml +=						xTafTag("classTrib",Posicione("C8D",1,xFilial("C8D") + C1E->C1E_CLAFIS,"C8D_CODIGO"))
				Else
					cXml +=						xTafTag("classTrib","00")
				EndIf
			EndIf



			If !isVersionCompatible("S_01_00_00")
				cNatJurid := Posicione("C8P",1,xFilial("C8P") + C1E->C1E_NATJUR,"C8P_CODIGO")
				cXml +=						xTafTag("natJurid", cNatJurid,,.T.)
			EndIf

			cXml +=						xTafTag("indCoop",C1E->C1E_INCOOP,,.T.)
			cXml +=						xTafTag("indConstr",C1E->C1E_INCONS,,.T.)
			cXml +=						xTafTag("indDesFolha",C1E->C1E_DESFOL)
			cXml +=					xTafTag("indOpcCP",C1E->C1E_INDCP,,.T.)
			cXml +=					xTafTag("indPorte",C1E->C1E_PORTE,,.T.)

			cXml +=						xTafTag("indOptRegEletron",C1E->C1E_REGELT)

			If !isVersionCompatible("S_01_00_00")
				If TAFColumnPos("C1E_ENTEDU")
					cXml +=					xTafTag("indEntEd",xFunTrcSN(C1E->C1E_ENTEDU,3),,.T.)
				Endif

				If !empty(C1E->C1E_INDETT)
					cXml +=						xTafTag("indEtt",xFunTrcSN(C1E->C1E_INDETT,1),,)
					cXml +=						xTafTag("nrRegEtt",C1E->C1E_NRETT,,.T.)
				EndIF
			Else
				cXml += xTafTag("cnpjEFR", C1E->C1E_CPNJER,, .T.)
			EndIf

			If isVersionCompatible("S_01_00_00") .And. TafColumnPos("C1E_DTTRSO")
				cXml += xTafTag("dtTrans11096", C1E->C1E_DTTRSO,, .T.)
			EndIf

			If isVersionCompatible("S_01_01_00",, .T.) .And. TafColumnPos("C1E_PISCOF")
				cXml += xTafTag("indTribFolhaPisCofins", xFunTrcSN(C1E->C1E_PISCOF, 6),, .T.)
			EndIf

			If ! Empty(C1E->C1E_SIGMIN) .or. ! Empty(C1E->C1E_NRCERT) .or. ! Empty(C1E->C1E_DTEMCE) .or. ! Empty(C1E->C1E_DTVCCE) .or. ! Empty(C1E->C1E_NRPRRE) .or. ! Empty(C1E->C1E_DTPRRE) .or. ! Empty(C1E->C1E_DTDOU) .or. ! Empty(C1E->C1E_PAGDOU)
				cXml +=						"<dadosIsencao>"
				cXml +=							xTafTag("ideMinLei",C1E->C1E_SIGMIN)
				cXml +=							xTafTag("nrCertif",C1E->C1E_NRCERT)
				cXml +=							xTafTag("dtEmisCertif",C1E->C1E_DTEMCE)
				cXml +=							xTafTag("dtVencCertif",C1E->C1E_DTVCCE)
				If ! Empty(C1E->C1E_NRPRRE)
					cXml +=						xTafTag("nrProtRenov",C1E->C1E_NRPRRE)
				EndIf
				If ! Empty(C1E->C1E_DTPRRE)
					cXml +=						xTafTag("dtProtRenov",C1E->C1E_DTPRRE)
				EndIf
				If ! Empty(C1E->C1E_DTDOU)
					cXml +=						xTafTag("dtDou",C1E->C1E_DTDOU)
				EndIf
				If ! Empty(C1E->C1E_PAGDOU)
					cXml +=						xTafTag("pagDou",C1E->C1E_PAGDOU)
				EndIf
				cXml +=						"</dadosIsencao>"
			EndIf

			If !isVersionCompatible("S_01_00_00")
				xTafTagGroup("contato", {;
					{"nmCtt"   , C1E->C1E_NOMCNT, ,.F.};
					,  {"cpfCtt"  , C1E->C1E_CPFCNT, ,.F.};
					,  {"foneFixo", Alltrim(C1E->C1E_DDDFON) + Alltrim(C1E->C1E_FONCNT), ,.T.};
					,  {"foneCel" , Alltrim(C1E->C1E_DDDCEL) + Alltrim(C1E->C1E_CELCNT), ,.T.};
					,  {"email"   , C1E->C1E_EMAIL, ,.T.};
					};
					, @cXml )
			EndIf

			cCodMun := Posicione("C07",3, xFilial("C07")+C1E->C1E_CODMUN,"C07_CODIGO")

			If !isVersionCompatible("S_01_00_00")
				xTafTagGroup("infoEFR"			,{{"ideEFR"		,xFunTrcSN(C1E->C1E_EFR,1)									,,.T.};
					, {"cnpjEFR"		,C1E->C1E_CPNJER												,,.F.}};
					, @cXmlIERF)

				xTafTagGroup("infoEnte"			,{{"nmEnte"		,C1E->C1E_NMENTE													,,.T.};
					, {"uf"			,Posicione("C09",3,xFilial("C09")+C1E->C1E_UF,"C09_UF")		,,.T.};
					, {"codMunic"		,IIf(!Empty(cCodMun),C09->C09_CODIGO + cCodMun,"")			,,.F.};
					, {"indRPPS"		,xFunTrcSN(C1E->C1E_RPPS,1)										,,.T.};
					, {"subteto"		,C1E->C1E_SUBTET													,,.T.};
					, {"vrSubteto"	,C1E->C1E_VLRSUB, "@E 999,999,999,999.99"						,,.T.}};
					, @cXmlIEnt)

				xTafTagGroup( "infoOP", { { "nrSiafi", C1E->C1E_SIAFI,, .F. } }, @cXml, { { "infoEFR", cXmlIERF, 0 }, { "infoEnte", cXmlIEnt, 0 } },, .T. )

			EndIf

			If !Empty(C1E->C1E_ISEMUL) .And. IIf(!isVersionCompatible("S_01_00_00"), Substr(cNatJurid, 1, 1) == "5", .T.)
				cXml +=						"<infoOrgInternacional>"
				cXml +=							xTafTag("indAcordoIsenMulta",C1E->C1E_ISEMUL)
				cXml +=						"</infoOrgInternacional>"
			EndIf

			If !isVersionCompatible("S_01_00_00")

				If CRM->(MsSeek(xFilial("CRM") + (cAlias)->( &( cAlias + "_ID") + &( cAlias + "_VERSAO" ) ) ) )

					While CRM->(!Eof()) .and. CRM->(CRM_FILIAL + CRM_ID + CRM_VERSAO) == xFilial("CRM") + (cAlias)->( &( cAlias + "_ID" ) + &( cAlias + "_VERSAO" ) )
						cXml +=				"<softwareHouse>"
						cXml +=					xTafTag("cnpjSoftHouse",CRM->CRM_CNPJ)
						cXml +=					xTafTag("nmRazao",SubStr(CRM->CRM_NOME,1,100),,.T.)
						cXml +=					xTafTag("nmCont",CRM->CRM_CONTAT)
						cXml +=					xTafTag("telefone",Alltrim(CRM->CRM_DDD) + Alltrim(CRM->CRM_FONE))
						cXml +=					xTafTag("email",CRM->CRM_MAIL,,.T.)
						cXml +=				"</softwareHouse>"

						CRM->(DBSkip())
					EndDo

				EndIf

				If !Empty(C1E->C1E_SITESP) .Or. !Empty(C1E->C1E_SITPF)
					cXml +=						"<infoComplementares>"
					If ! Empty(C1E->C1E_SITESP)
						cXml +=							"<situacaoPJ>"
						cXml +=								xTafTag("indSitPJ",C1E->C1E_SITESP)
						cXml +=							"</situacaoPJ>"
					EndIf

					If ! Empty(C1E->C1E_SITPF)
						cXml +=							"<situacaoPF>"
						cXml +=								xTafTag("indSitPF",C1E->C1E_SITPF)
						cXml +=							"</situacaoPF>"
					EndIf
					cXml +=						"</infoComplementares>"
				EndIf

			EndIf

			cXml +=					"</infoCadastro>"

			If C1E->C1E_EVENTO == "A"
				cXml +=			"<novaValidade>"
				cXml +=				TafGetDtTab(C1E->C1E_DTINI,C1E->C1E_DTFIN)
				cXml +=			"</novaValidade>"
			EndIf

			cXml +=				"</" + cEvento + ">"
			cXml +=			"</infoEmpregador>"

		ElseIf C1E->C1E_EVENTO == "E"
			cXml +=			"<infoEmpregador>"
			cXml +=				"<exclusao>"
			cXml +=					"<idePeriodo>"
			cXml += 					TafGetDtTab(C1E->C1E_DTINI,C1E->C1E_DTFIN)
			cXml +=					"</idePeriodo>"
			cXml +=				"</exclusao>"
			cXml +=			"</infoEmpregador>"
		EndIf

		//Estrutura do cabecalho
		If nRecnoSM0 > 0
			SM0->(dbGoto(nRecnoSM0))
		endif
		cXml := xTafCabXml(cXml,"C1E",cLayout,cReg,,cSeqXml)

		//Executa gravacao do registro
		If !lJob
			xTafGerXml(cXml,cLayout)
		EndIf
	EndIf

Return(cXml)

//-------------------------------------------------------------------
/*/{Protheus.doc} TafVldMatz

Função para validar se a Filial pode ser configurada como Matriz.

@Author	David Costa
@Since		16/02/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TafVldMatz()

	Local cLogErro  := ""
	Local oModel    := Nil

	If M->C1E_MATRIZ
		VldMatriz( M->C1E_FILTAF, @cLogErro )

		If !Empty( cLogErro )
			oModel := FwModelActive()

			MsgAlert( xValStrEr( cLogErro ), STR0028 ) // "Atenção!"

			If oModel:IsActive()
				oModel:LoadValue( "MODEL_C1E", "C1E_MATRIZ", .F. )
			EndIf
		EndIf
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} VldMatriz

Função interna para validar se a Filial pode ser configurada como Matriz.

@Param	cCodFilial	- Código da Filial que será validada
cLogErro	- Log de erros da validação

@Author	David Costa
@Since		23/02/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function VldMatriz( cCodFilial, cLogErro )

	Local lMatriz      := .T.
	Local aInfoMatriz  := {}

	//Verifica se a Filial é uma SCP
	If FilialSCP( cCodFilial, cCodFilial )
		lMatriz := .F.
		cLogErro := "000893" //"Esta filial é uma SCP e por isso não pode ser parametrizada como matriz."
	Else
		aInfoMatriz := TAFGFilMatriz()
		If Len(aInfoMatriz) > 0
			lMatriz := .F.
			cLogErro := "000894" //"Já existe uma Filial cadastrada como Matriz e só é permitida uma Filial Matriz por empresa."
		EndIf
	EndIf

Return( lMatriz )

//-------------------------------------------------------------------
/*/{Protheus.doc} TafVldSCP

Função para validar se a Filial pode ser configurada como SCP.

@Author	David Costa
@Since		17/02/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TafVldSCP()

	Local cLogErro  := ""
	Local lSCP      := .T.

	If !Empty( M->CUW_CODSCP )
		lSCP := VldFilSCP( M->C1E_ID, M->CUW_CODSCP, @cLogErro )
		If !Empty( cLogErro )
			MsgAlert( xValStrEr( cLogErro ), STR0028 ) //"Atenção!"
		EndIf
	EndIf

Return( lSCP )

//-------------------------------------------------------------------
/*/{Protheus.doc} VldFilSCP

Função interna para validar se a Filial pode ser configurada como SCP.

@Param	cCodFilial	- Código da Filial Ostensiva
cCodFilSCP	- Código da Filial SCP
cLogErro	- Log de erros da validação

@Author	David Costa
@Since		24/02/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function VldFilSCP( cCodFilial, cCodFilSCP, cLogErro )

	Local lScp			:= .T.
	Local lMesmaEmp		:= .T.
	Local lSCPMatriz	:= .F.

	Default cCodFilial	:= ""
	Default cCodFilSCP	:= ""
	Default cLogErro	:= ""

	If cCodFilSCP == cCodFilial
		lSCP := .F.
		cLogErro := "000898" //"Esta filial não pode ser associada como SCP dela mesma."
	ElseIf FilialSCP( cCodFilSCP, cCodFilial )
		lSCP := .F.
		cLogErro := "000895" //"Esta filial já está configurada como SCP de outra filial."
	ElseIf FilOstensi( cCodFilSCP )
		lSCP := .F.
		cLogErro := "000899" //"Uma filial sócio ostensivo não pode ser associada como filial SCP."
	ElseIf FilialSCP( cCodFilial, cCodFilial )
		lSCP := .F.
		cLogErro := "000900" //"Uma filial SCP não pode ser sócio ostensivo de outra filial SCP."
	Else
		VldEmpMatz( cCodFilial, cCodFilSCP, @lMesmaEmp, @lSCPMatriz )

		If !lMesmaEmp
			lSCP := .F.
			cLogErro := "000896" //"A filial SCP precisa ser da mesma empresa da filial do sócio ostensivo."
		ElseIf lSCPMatriz
			lSCP := .F.
			cLogErro := "000897" //"A filial matriz não pode ser relacionada como SCP."
		EndIf
	EndIf

Return( lSCP )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCodEmp
Retorna o código da Empresa da Filial.

@Param		cCodFilial - Código da Filial

@Return	cEmp - Código da Empresa

@Author	David Costa
@Since		17/02/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function GetCodEmp( cCodFilial )

	Local cEmp	:=	""

	DBSelectArea( "XX8" )
	XX8->( DBSetOrder( 1 ) )
	XX8->( DBGoTop() )
	While XX8->( !Eof() )
		If StrTran( XX8->( XX8_EMPR + XX8_UNID + XX8_CODIGO ), " ", "" ) == StrTran( cCodFilial, " ", "" )
			cEmp := AllTrim( XX8->XX8_EMPR )
			Exit
		EndIf
		XX8->( DBSkip() )
	EndDo

Return( cEmp )

//-------------------------------------------------------------------
/*/{Protheus.doc} FilialSCP
Verifica se a Filial é uma SCP.

@Param	cCodFilSCP	- Código da Filial SCP
cCodFilial	- Código da Filial Ostensiva

@Author	David Costa
@Since		17/02/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Function FilialSCP( cCodFilSCP, cCodFilial )

	Local cAliasQry     := GetNextAlias()
	Local cSelect		:= ""
	Local cFrom         := ""
	Local cWhere		:= ""
	Local lSCP			:= .F.

	Default cCodFilSCP  := ""
	Default cCodFilial  := Space( 1 )

	cSelect	:= " CUW_CODSCP "

	cFrom		:= RetSqlName( "CUW" ) + " CUW "

	cWhere		:= "    CUW_CODSCP = '" + cCodFilSCP + "' "
	cWhere		+= "AND CUW.D_E_L_E_T_ = '' "
	cWhere		+= "AND CUW_ID <> '" + cCodFilial + "' "

	cSelect	:= "%" + cSelect + "%"
	cFrom		:= "%" + cFrom + "%"
	cWhere		:= "%" + cWhere + "%"

	BeginSql Alias cAliasQry
		SELECT
		%Exp:cSelect%
		FROM
		%Exp:cFrom%
		WHERE
		%Exp:cWhere%
	EndSql

	//-------------------------------------------------------
	DBSelectArea( cAliasQry )
	While ( cAliasQry )->( !Eof() )
		lSCP := .T.
		Exit
	EndDo
	( cAliasQry )->( DBCloseArea() )

Return( lSCP )

//-------------------------------------------------------------------
/*/{Protheus.doc} VldEmpMatz
Valida se a Filial é da mesma empresa e se a SCP é Matriz.

@Param	cCodFilial	- Código da Filial
cCodFilSCP	- Código da Filial SCP
lMesmaEmp	- Retorna .T. se as Filiais forem da mesma Empresa
lSCPMatriz	- Retorna .T. se a SCP for uma Filial Matriz

@Author	David Costa
@Since		02/03/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function VldEmpMatz( cCodFilial, cCodFilSCP, lMesmaEmp, lSCPMatriz )

	Local cAliasQry := GetNextAlias()
	Local cSelect   := ""
	Local cFrom     := ""
	Local cWhere    := ""

	Default cCodFilial 	:= ""
	Default cCodFilSCP	:= ""
	Default lMesmaEmp	:= .F.
	Default lSCPMatriz	:= .F.

	cSelect	:= " C1E.C1E_FILTAF FIL_OSTENS, C1E2.C1E_FILTAF FIL_SCP, C1E2.C1E_MATRIZ SCP_MATRIZ "

	cFrom		:= RetSqlName( "C1E" ) + " C1E, " + RetSqlName( "C1E" ) + " C1E2 "

	cWhere		:= "    C1E.C1E_ID = '" + cCodFilial + "' "
	cWhere		+= "AND C1E.D_E_L_E_T_ = '' "
	cWhere		+= "AND C1E2.C1E_ID = '" + cCodFilSCP + "' "
	cWhere		+= "AND C1E2.D_E_L_E_T_ = '' "

	cSelect	:= "%" + cSelect + "%"
	cFrom		:= "%" + cFrom + "%"
	cWhere		:= "%" + cWhere + "%"

	BeginSql Alias cAliasQry
		SELECT
		%Exp:cSelect%
		FROM
		%Exp:cFrom%
		WHERE
		%Exp:cWhere%
	EndSql

	DBSelectArea( cAliasQry )

	While ( cAliasQry )->( !Eof() )
		//Valida se as Filiais são da mesma Empresa
		lMesmaEmp := Iif( ( GetCodEmp( ( cAliasQry )->FIL_OSTENS ) == GetCodEmp( ( cAliasQry )->FIL_SCP ) ), .T., .F. )

		//Valida se a Filial SCP é uma Filial Matriz
		lSCPMatriz := Iif( ( ( cAliasQry )->SCP_MATRIZ $ "T" ), .T., .F. )

		( cAliasQry )->( DBSkip() )
	EndDo

	( cAliasQry )->( DBCloseArea() )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} FilOstensi
Verifica se a Filial é uma Filial Sócio Ostensivo.

@Param cCodFilial - Código da Filial Ostensiva

@Author	David Costa
@Since		02/03/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FilOstensi( cCodFilial )

	Local cAliasQry    := GetNextAlias()
	Local cSelect      := ""
	Local cFrom        := ""
	Local cWhere       := ""
	Local lOstensivo   := .F.

	Default cCodFilial := ""

	cSelect	:= " CUW_CODSCP "

	cFrom		:= RetSqlName( "CUW" ) + " CUW "

	cWhere		:= "    CUW.D_E_L_E_T_ = '' "
	cWhere		+= "AND CUW_ID = '" + cCodFilial + "' "

	cSelect	:= "%" + cSelect + "%"
	cFrom		:= "%" + cFrom + "%"
	cWhere		:= "%" + cWhere + "%"

	BeginSql Alias cAliasQry
		SELECT
		%Exp:cSelect%
		FROM
		%Exp:cFrom%
		WHERE
		%Exp:cWhere%
	EndSql

	//-------------------------------------------------------
	DBSelectArea( cAliasQry )
	While ( cAliasQry )->( !Eof() )
		lOstensivo := .T.
		Exit
	EndDo
	( cAliasQry )->( DBCloseArea() )

Return( lOstensivo )

//-------------------------------------------------------------------
/*/{Protheus.doc} A050Am1x1
Descrição da função...

@Author	Gustavo G. Rueda
@Since		05/09/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Function A050Am1x1( cAlias, nRecno, nOpc, lAutomato, lSubstituir )

	Local nX			:=	0
	Local aSM0			:=	{}
	Local aGrvC1E		:=	{}
	Local lInsert		:=	.T.

	Default cAlias		:=	""
	Default nRecno		:=	0
	Default nOpc		:=	0
	Default lAutomato	:=	.F.
	Default lSubstituir	:=	.F.

	If lAutomato .or. MsgYesNo( STR0032, STR0033 ) //##"Confirma o processamento automático de amarração 1 x 1 das Filiais desta Empresa para o TAF?" ##"Confirmação..."
		DBSelectArea( "C1E" )
		DBSetOrder( 3 )

		aSM0 := FWLoadSM0( .T. )

		For nX := 1 to Len( aSM0 )
			lInsert := .T.

			If aSM0[nX,SM0_GRPEMP] == cEmpAnt .and. aSM0[nX,SM0_USEROK] .and. ( ValType( aSM0[nX,SM0_EMPOK] ) == "U" .or. aSM0[nX,SM0_EMPOK] )
				If C1E->( MsSeek( xFilial( "C1E" ) + PadR( aSM0[nX,SM0_CODFIL], FWGETTAMFILIAL ) ) )
					If !lAutomato
						If C1E->C1E_STATUS $ '2|4' //Não permite amarração
							MessageBox(STR0042 + " [" + cEmpAnt + " / " + aSM0[nX,SM0_CODFIL] + "]; " + STR0043, STR0041, 16 )//"Não possível executar amarração 1 x 1 para registro já transmitidos!  A operação para " será cancelada. " Transmitido E-Social""
							lInsert := .F.
						Else
							If MsgYesNo( STR0034 + " [" + cEmpAnt + " / " + aSM0[nX,SM0_CODFIL] + "]; " + STR0035, STR0033 ) //##"Já existe um complemento para a Empresa/Filial" ##"Deseja realmente substituir as informações já cadastradas? Será criado um novo registro com o mínimo de informações em substituição a este!" ##"Confirmação..."
								RecLock( "C1E", .F. )
								C1E->( DBDelete(), MsUnLock(), DBCommit() )
							Else
								lInsert := .F.
							EndIf
						EndIf
					Else
						If lSubstituir
							RecLock( "C1E", .F. )
							C1E->( DBDelete(), MsUnLock(), DBCommit() )
						Else
							lInsert := .F.
						EndIf
					EndIf
				EndIf

				If lInsert
					aGrvC1E :=	{{ "C1E_FILTAF", aSM0[nX,SM0_CODFIL] },;
						{ "C1E_CODFIL", cEmpAnt + aSM0[nX,SM0_CODFIL] },;
						{ "C1E_VERSAO", xFunGetVer() }}
					A050Insert( .F., "", "", "", { aGrvC1E } )
				EndIf
			EndIf
		Next nX
	EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} A050Insert
Função utilizada para INSERT na C1E via Model.

@Param	lJob		-	Flag de chamada via JOB
cEmp		-	Código da Empresa
cFil		-	Código da Filial
cSemaforo	-	Semáforo para tratar acesso exclusivo ao ambiente
aGrv		-	Array com as informações a serem inseridas

@Author	Gustavo G. Rueda
@Since		05/09/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Function A050Insert( lJob, cEmp, cFil, cSemaforo, aGrv )

	Local oModelC1E	    := Nil
	Local nX			:= 0
	Local nY			:= 0
	Local nErase		:= 0
	Local nHandle		:= 0

	Default lJob		:= .F.
	Default cEmp		:= ""
	Default cFil		:= ""
	Default cSemaforo	:= ""
	Default aGrv		:= {}

	If lJob

		TAFConOut( "TAFA050:A050Insert(I): " + DToS( Date() ) + " " + Time() + " -> " + "Processando atualização <Amarração dos Estabelecimentos> [ " + cEmp + "/" + cFil + " ]" )

		If File( cSemaforo )
			FErase( cSemaforo )
		EndIf

		nHandle := FCreate( cSemaforo )

		//Redefino o ambiente para a empresa passada como parâmetro
		RPCClearEnv()
		RPCSetType( 3 )
		RPCSetEnv( cEmp, cFil,,, "TAF" )

		For nX := 1 To Len(aGrv)
			RecLock("C1E",.T.)
			C1E->C1E_FILIAL := xFilial("C1E")
			C1E->C1E_ID		:= taf050getId()
			C1E->C1E_VERSAO := xFunGetVer()
			C1E->C1E_ATIVO  := "1"
			C1E->C1E_EVENTO := "I"
			For nY := 1 to Len(aGrv[nX])
				C1E->&(aGrv[nX,nY,1]) := aGrv[nX,nY,2]
			Next nY
			C1E->(MsUnLock())
		Next nX

		FClose( nHandle )
		nErase := FErase( cSemaforo )
		TAFConOut( "TAFA050:A050Insert(F): " + DToS( Date() ) + " " + Time() + " -> " + "Processando atualização <Amarração dos Estabelecimentos> [ " + cEmp + "/" + cFil + " ] - (" + StrZero( Len( aGrv ), 3 ) + ") REGISTROS" )
	Else

		//Essa função faz o cache do modelo e verifica se o numerador(Id) ja não existe na base
		FCModelInt( "C1E", "TAFA050", @oModelC1E, MODEL_OPERATION_INSERT )
		For nX := 1 to Len( aGrv )
			For nY := 1 to Len( aGrv[nX] )
				oModelC1E:LoadValue( "MODEL_C1E", aGrv[nX,nY,1], aGrv[nX,nY,2] )
			Next nY
		Next nX

		FWFormCommit( oModelC1E )
		oModelC1E:DeActivate()
	EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} taf050getId
Gera um novo numerado verificando se o mesmo ja nao existe na tabela

@Return cIdAux - Novo Id

@author Evandro dos Santos
@since 29/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function taf050getId()

	Local cIdAux := ""

	cIdAux := GetSx8Num("C1E","C1E_ID")

	While !TAFCheckID(cIdAux,"C1E")

		TafConOut("Id " + cIdAux + " ja existente na tabela C1E. Será realizado uma nova requisicao de numeração. ")
		C1E->(ConfirmSX8())
		cIdAux := GetSx8Num("C1E","C1E_ID")
	EndDo

Return cIdAux

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF050Format
Formata os campos de data ini e fim do registro S-1000

@Param cValorXml - Valor a ser formatado
@Return cFormatValue - Valor já formatado

@author Evandro dos Santos
@since 12/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAF050Format(cValorXml)

	Local cFormatValue, cRet := ''

	cFormatValue := StrTran( StrTran( cValorXml, "-", "" ), "/", "")
	cRet := Substr(cFormatValue, 5, 2) + Substr(cFormatValue, 1,4)

Return( cRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TafCpoEsoc

Indica se um campo pertencente ao escopo do eSocial foi alterado

@Param
@Return lRet

@author Fabio V Santana
@since 23/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function TafCpoEsoc( cCampo )

	Local oModel	:=	FWModelActive() //Recuperando o modelo ativo da interface
	Local oModelC1E	:=	oModel:GetModel( "MODEL_C1E" )
	Local nPos		:= 	0

	//Verifico se o campo foi alterado para um conteúdo diferente do que já estava gravado
	If SubStr( cCampo, 1, 3 ) == "C1E" .and. &( "C1E->" + cCampo ) <> oModelC1E:GetValue( cCampo )
		//Adiciono cada campo somente uma vez no array de verificação
		If aScan( aAltEsoc, { |x| x[3] == cCampo } ) == 0
			aAdd( aAltEsoc, { &( "C1E->" + cCampo ), oModelC1E:GetValue( cCampo ), cCampo } )
			lEsocial := .T.
		EndIf
	Else
		//Caso o conteúdo do campo seja igual ao que esta gravado,
		//significa que o usuário voltou o campo para o conteúdo original.
		//Neste caso, retiro o campo em questão do array de verificação
		nPos := aScan( aAltEsoc, { |x| x[3] == cCampo } )
		If nPos > 0
			aDel( aAltEsoc, nPos )
			aSize( aAltEsoc, Len( aAltEsoc ) - 1 )
		EndIf

		//Caso não haja nenhuma alteração no que diz respeito ao esocial, reseto a variável de controle
		If Len( aAltEsoc ) == 0
			lEsocial := .F.
		EndIf
	EndIf

Return( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} VldnrEtt
Validações referente a tag nrRegEtt registro S-1000 e-social

@Param
@Return lRet

@author Henrique Pereira
@since 23/11/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function VldnrEtt(nOpc, cC1EINDETT, cC1ENRETT, cLogErro)

	Local lRet 			:= .T.
	Local oTmpModel 		:= Nil
	Local oTmpModC1E 		:= Nil

	Default cC1EINDETT	:= ""
	Default cC1ENRETT		:= ""
	Default nOpc			:= 0

	If nOpc == 1
		If cC1EINDETT = "1"
			If Empty(cC1ENRETT)
				lRet := .F.
				cLogErro := "001074" //Preenchimento obrigatório se {indEtt} = [S]. Não pode ser informado nos demais casos.
			ElseIf !isNumeric(cC1ENRETT)
				lRet := .F.
				cLogErro := "001075"  // Apenas números são aceitos {1234567890}
			EndIf
		ElseIf cC1EINDETT = "2" .And. !Empty(cC1ENRETT)
			lRet := .F.
			cLogErro := "001076" //Preenchimento obrigatório se {indEtt} = [S]. Não pode ser informado nos demais casos.
		EndIf
	ElseIf nOpc == 2
		oTmpModel 	:= FWModelActive()
		oTmpModC1E 	:= oTmpModel:GetModel( 'MODEL_C1E' )
		If !isNumeric(oTmpModC1E:GetValue("C1E_NRETT"))
			lRet := .F.
			Help( ,,STR0038,, STR0039,1,0 ) // "Erro: Nr. Reg. ETT - C1E_RETT"  | "Apenas números são aceitos {1234567890}"
		EndIf
	EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TafCpoEsoc
Indica se um campo pertencente ao escopo do eSocial foi alterado

@Param
@Return lRet

@author Fabio V Santana
@since 23/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function TafAltReinf()

	Local oModel    	:= FWModelActive()
	Local oModelC1E 	:= oModel:GetModel( 'MODEL_C1E' )
	Local nX			:= 0
	Local lRet 			:= .F.
	Local aAltReinf		:= {}
	Local aCampos 		:= {}

	If FindFunction("TafR1000Cpo")

		aInfo		:= TafR1000Cpo()
		aCampos 	:= aInfo[02]

		For Nx := 1 To Len( aCampos )
			cCampo := AllTrim( aCampos[Nx] )
			If Substr(cCampo,1,3) == 'C1E' .And. TafColumnPos( cCampo )

				uVal1 := &(M->cCampo)
				uVal2 := oModelC1E:GetValue( cCampo )

				If uVal1 <> uVal2
					lRet := .T.
					AADD( aAltReinf, { cCampo, AllToChar( uVal1 ) , AllToChar( uVal2 ) })
				EndIf
			EndIf
		Next
	Else
		lRet := .T.
	EndIf

	
	If !lRet
		oModelCRM := oModel:GetModel( 'MODEL_CRM' )
		For nX := 1 To oModel:GetModel( 'MODEL_CRM' ):Length()
			oModel:GetModel( 'MODEL_CRM' ):GoLine(nX)
			If oModelCRM:IsUpdated(nX) .Or. oModelCRM:IsDeleted(nX)
				lRet := .T.
			EndIf
		Next
	Endif

	

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCpoSCP
Verifica se determinados campos da SCP podem ou não ser editados.

@Param
@Return lRet

@author Carlos Eduardo N. da Silva
@since 16/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function Tafa050SCP()
	Local lRet 		:= .t.
	Local oModel	:= FWModelActive()
	Local cCpoEdit	:= SubStr(ReadVar(),4)

	if cCpoEdit == 'CUW_CODSCP'
		lRet := empty(oModel:GetValue('MODEL_CUW','CUW_CNPJ'))
	elseif cCpoEdit $ 'CUW_CNPJ|CUW_NOMSCP'
		lRet := empty(oModel:GetValue('MODEL_CUW','CUW_CODSCP'))
	endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFVldAltD
Valida se existe a mesma data em algum registro inativo

@author		Bruno de Oliveira
@since		30/10/2019
@version	1.0
@Param		cIDCIE		, caracter	, ID do CIE
@Param		cDataAtual	, caracter	, Data atual
@Return		lRet
/*/
//-------------------------------------------------------------------
Function TAFVldAltD(cIDCIE,cDataAtual)

	Local lRet    := .F.
	Local cQry    := ""
	Local cTabCIE := GetNextAlias()

	cQry := "SELECT * FROM " + RetSqlName("C1E") + " "
	cQry += "WHERE C1E_ID = '" + cIDCIE + "' "
	cQry += "AND C1E_DTINI = '" + cDataAtual + "' "
	cQry += "AND C1E_ATIVO = '2' "
	cQry += "AND D_E_L_E_T_ = ' ' "

	cQry := ChangeQuery(cQry)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cTabCIE,.T.,.T.)

	While (cTabCIE)->(!EOF())

		lRet := .T.

		(cTabCIE)->(DbSkip())
	End

	(cTabCIE)->(DbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getVersionEsocial
Retorna se a versão 

@author		Evandro dos Santos Oliveira
@since		15/02/2021
@version	1.0
@Return		lLaySimplif - Versão do Esocial
@Obs: Essa função foi criada por que o TAFA050 é executado via Job pelo 
TAFINIT (criação do de/para), neste contexto não se pode chamar um parâmetro
na criação de uma  variável static pois o sistema irá tentar carrega-la antes 
do ambiente estar preparado.
/*/
//-------------------------------------------------------------------
Static Function isVersionCompatible(cVersion, lForce, lCompare)

	Local lRet			as logical 

	Default cVersion 	:= ""
	Default lForce 		:= .F.
	Default lCompare	:= .F.
	
	lRet := .F.

	If cVersion $ "S_01_01_00"
		If lSimplBeta == Nil 
			lSimplBeta := TAFLayESoc(cVersion, lForce, lCompare)
		EndIf

		lRet := lSimplBeta
	Else
		If lLaySimplif == Nil 
			lLaySimplif := TAFLayESoc(cVersion, lForce, lCompare)
		EndIf

		lRet := lLaySimplif
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF050ClassTrib
Retorna se a classificação tributária

@author		Verônica Almeida - Aline Venâncio
@since		06/04/2024
@version	1.0
@Return		cClassTrib - Classificação Tributária
@Obs: Essa função foi criada para que o RH/GPE consiga ter o retorno da 
classificação tributária pelo complemento de empresas (S-1000).
/*/
//-------------------------------------------------------------------

Function TAF050ClassTrib(cCodFil,cErr)
	Local cClassTrib	:= ''
	Local aC1EArea		:= {}
	Local lArea			:= Select('C1E') > 0
	Local cClaFis		:= ''

	Default cCodFil		:= ''
	Default cErr		:= ''

	If Empty(cCodFil)
		cErr := I18N(STR0056,{'[C1EERR001]'}) //--"#1 O parâmetro cCodFil é obrigatório."   
	Else
		
		If lArea
			aC1EArea := C1E->(GetArea())
		EndIf

		cCodFil := PadR(cCodFil,TamSX3('C1E_CODFIL')[1])
		C1E->(DbSetOrder(7))	//C1E_FILIAL+C1E_CODFIL+C1E_ATIVO

		If C1E->(MsSeek(xFilial('C1E') + cCodFil + '1'))
			cClaFis	:= C1E->C1E_CLAFIS

			If !Empty(cClaFis)
				cClassTrib := Posicione('C8D',1,xFilial('C8D') + cClaFis,'C8D_CODIGO')

				If Empty(cClassTrib)
					cErr := I18N(STR0057,{'[C1EERR003]',AllTrim(cClaFis)}) //--#1 O ID encontrado (#2) não corresponde a um código válido da tabela 08 do eSocial (tabela TAF C8D).
				EndIf
			EndIf
			
		Else
			cErr := I18N(STR0058,{'[C1EERR002]',AllTrim(cCodFil)}) //--#1 O valor passado na variável cCodFil (#2) não foi localizado.
		EndIf

		If lArea
			RestArea(aC1EArea)
		EndIf

	EndIf
Return cClassTrib




