#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA257.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA257
Comunicação de Acidente de Trabalho (S-2210)

@author Leandro Prado
@since 05/09/2013
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA257()

	Private oBrw 		:=  FWmBrowse():New()
	Private cEvtPosic 	:= ""

	// Função que indica se o ambiente é válido para o eSocial 2.3
	If TafAtualizado()

		oBrw:SetDescription(STR0001)	//"Comunicação de Acidente de Trabalho"
		oBrw:SetAlias( 'CM0')
		oBrw:SetMenuDef( 'TAFA257' )

		If FindFunction('TAFSetFilter')
			oBrw:SetFilterDefault(TAFBrwSetFilter("CM0","TAFA257","S-2210"))
		Else
			oBrw:SetFilterDefault( "CM0_ATIVO == '1'" )	//Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )
		EndIf

		TafLegend(2,"CM0",@oBrw)
		oBrw:Activate()

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Leandro Prado
@since 05/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	Local aFuncao := {}

	If FindFunction('TafXmlRet')
		Aadd( aFuncao, { "" , "TafxmlRet('TAF257Xml','2210','CM0')" , "1" } )
	Else
		Aadd( aFuncao, { "" , "TAF257Xml" , "1" } )
	EndIf

	//Chamo a Browse do Histórico
	If FindFunction( "xNewHisAlt" )
		Aadd( aFuncao, { "" , "xNewHisAlt('CM0', 'TAFA257' ,,,,,,'2210','TAF257Xml' )" , "3" } )
	Else
		Aadd( aFuncao, { "" , "xFunHisAlt('CM0', 'TAFA257' ,,,, 'TAF257XML','2210' )" , "3" } )
	EndIf

	aAdd( aFuncao, { "" , "TAFXmlLote( 'CM0', 'S-2210' , 'evtCAT' , 'TAF257Xml' )" , "5" } )
	Aadd( aFuncao, { "" , "xFunAltRec( 'CM0' )" , "10" } )

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If lMenuDif
		ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA257' OPERATION 2 ACCESS 0		

	Else
		aRotina	:=	xFunMnuTAF( "TAFA257" , , aFuncao)
	EndIf

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Leandro Prado
@since 05/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local aObsCAT	:= {}
	Local oStruCM0  := FWFormStruct(1, "CM0")
	Local oStruCM1  := FWFormStruct(1, "CM1")
	Local oStruCM2  := FWFormStruct(1, "CM2")
	Local oModel    := MPFormModel():New( 'TAFA257'  ,,,{|oModel| SaveModel(oModel)})
	Local nOperation := oModel:GetOperation()

	oStruCM0:RemoveField("CM0_DNRCAT")
	oStruCM0:RemoveField("CM0_DTCAT")	
	oStruCM0:RemoveField("CM0_TPREG")
	oStruCM0:RemoveField("CM0_DTPRE")
	oStruCM0:RemoveField("CM0_INSREG")
	oStruCM0:RemoveField("CM0_NRIREG")
	oStruCM0:RemoveField("CM0_DTPACI")
	oStruCM0:RemoveField("CM0_TPACID")
	oStruCM0:RemoveField("CM0_CODCAT")
	oStruCM0:RemoveField("CM0_DCATEG")

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruCM0:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	EndIf

	If TafColumnPos("CM0_OBSMEM")
		aObsCAT := ObsCAT(CM0->(Recno()), nOperation == MODEL_OPERATION_INSERT )
		
		If Empty(aObsCAT[2]) .And. !Empty(aObsCAT[1])
			If RecLock("CM0", .F.)
				CM0->CM0_OBSMEM := aObsCAT[1]

				CM0->(MsUnlock())
			EndIf
		EndIf
	EndIf

	//Remoção do GetSX8Num quando se tratar da Exclusão de um Evento Transmitido.
	//Necessário para não incrementar ID que não será utilizado.
	If Upper( ProcName( 2 ) ) == Upper( "GerarExclusao" )
		oStruCM0:SetProperty( "CM0_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )
	EndIf

	oModel:AddFields('MODEL_CM0', /*cOwner*/, oStruCM0)
	oModel:GetModel('MODEL_CM0'):SetPrimaryKey({'CM0_FILIAL', 'CM0_ID', 'CM0_VERSAO'})

	oModel:AddGrid('MODEL_CM1', 'MODEL_CM0', oStruCM1)
	oModel:AddGrid('MODEL_CM2', 'MODEL_CM0', oStruCM2)

	oModel:SetRelation('MODEL_CM1', {{'CM1_FILIAL' , 'xFilial( "CM1" )'}, {'CM1_ID' , 'CM0_ID'}, {'CM1_VERSAO' , 'CM0_VERSAO'}}, CM1->(IndexKey(1)))
	oModel:SetRelation('MODEL_CM2', {{'CM2_FILIAL' , 'xFilial( "CM2" )'}, {'CM2_ID' , 'CM0_ID'}, {'CM2_VERSAO' , 'CM0_VERSAO'}}, CM2->(IndexKey(1)))

	oStruCM0:SetProperty("CM0_HRTRAB",MODEL_FIELD_OBRIGAT,.F.)
	oStruCM0:SetProperty("CM0_INDOBI",MODEL_FIELD_OBRIGAT,.T.)
	oStruCM0:SetProperty("CM0_CODSIT",MODEL_FIELD_OBRIGAT,.T.)
	oStruCM0:SetProperty("CM0_DESLOG",MODEL_FIELD_OBRIGAT,.T.)
	oStruCM0:SetProperty("CM0_NRLOG" ,MODEL_FIELD_OBRIGAT,.T.)

	//Grupo atestado
	oStruCM0:SetProperty("CM0_DTATEN" ,MODEL_FIELD_OBRIGAT,.T.)
	oStruCM0:SetProperty("CM0_HRATEN" ,MODEL_FIELD_OBRIGAT,.T.)
	oStruCM0:SetProperty("CM0_INDINT" ,MODEL_FIELD_OBRIGAT,.T.)
	oStruCM0:SetProperty("CM0_DURTRA" ,MODEL_FIELD_OBRIGAT,.T.)
	oStruCM0:SetProperty("CM0_INDAFA" ,MODEL_FIELD_OBRIGAT,.T.)
	oStruCM0:SetProperty("CM0_NATLES" ,MODEL_FIELD_OBRIGAT,.T.)
	oStruCM0:SetProperty("CM0_CODCID" ,MODEL_FIELD_OBRIGAT,.T.)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Leandro Prado
@since 05/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local aCmpGrp   := {}
	Local aObsCAT	:= {}
	Local cCmpFil	:= ""
	Local cGrpTra1 	:= ""
	Local cGrpTra2	:= ""
	Local cGrpTra3	:= ""
	Local cGrpTra4	:= ""
	Local cGrpTra5	:= ""
	Local cGrpTra6	:= ""
	Local cGrpTra7	:= ""
	Local cGrpTra8	:= ""
	Local cGrpTra9	:= ""
	Local lObsCat	:= .T.
	Local nI        := 1
	Local oStruCM0  := Nil
	Local oModel    := FWLoadModel("TAFA257")
	Local oStruCM1  := FWFormStruct(2, "CM1")
	Local oStruCM2  := FWFormStruct(2, "CM2")
	Local oView     := FWFormView():New()
	Local nOperation := oModel:GetOperation()

	oView:SetModel( oModel )

	// Registrador CAT
	cGrpTra1  := 'CM0_ID|'
	
	// Grupo Atestado
	cGrpTra2  := 'CM0_TRABAL|CM0_DTRABA|CM0_DTACID|'

	If TafColumnPos("CM0_TIPACI")
		cGrpTra2  += 'CM0_TIPACI|'
	EndIf	

	cGrpTra2  += 'CM0_HRACID|CM0_HRTRAB|CM0_TPCAT|'
	cGrpTra2  += 'CM0_INDOBI|CM0_DTOBIT|CM0_COMPOL|CM0_CODSIT|CM0_DCODSI|CM0_INICAT|'

	If TafColumnPos("CM0_OBSMEM")
		aObsCAT := ObsCAT(CM0->(Recno()), nOperation == MODEL_OPERATION_INSERT )

		If Empty(aObsCAT[1]) .Or. !Empty(aObsCAT[2])
			cGrpTra2	+= "CM0_OBSMEM|"
			lObsCat		:= .F.
		EndIf
	EndIf

	If lObsCat
		cGrpTra2 += "CM0_OBSCAT|" 
	EndIf

	If TafColumnPos("CM0_ULTTRB")
		cGrpTra2 += "CM0_ULTTRB|CM0_HAFAS|" 
	EndIf

	// Local do Acidente
	cGrpTra3  := 'CM0_TPLOC|CM0_DESLOC|CM0_DESLOG|CM0_NRLOG|CM0_CODPAI|CM0_DCODPA|CM0_UF|CM0_DUF|CM0_CODMUN|'
	cGrpTra3  += 'CM0_DCODMU|CM0_CODPOS|'
	cGrpTra3  += 'CM0_TPLOGR|CM0_COMLOG|CM0_BAIRRO|CM0_CEP|CM0_INSACI|CM0_NRIACI|'

	// Atestado Médico
	cGrpTra4  := 'CM0_DTATEN|CM0_HRATEN|'
	cGrpTra4  += 'CM0_INDINT|CM0_DURTRA|CM0_INDAFA|CM0_NATLES|CM0_DNATLE|CM0_DESLES|CM0_DIAPRO|'
	cGrpTra4  += 'CM0_CODCID|CM0_DCODCI|CM0_OBSERV

	// Emitente	
	cGrpTra5 := 'CM0_CODCID|CM0_DCODCI|CM0_OBSERV|CM0_IDPROF|CM0_DIDPRO|'
	
	// Grupo Atestado
	cGrpTra6  := "CM0_ID|CM0_TRABAL|CM0_DTRABA|CM0_DTACID|CM0_HRACID|CM0_HRTRAB|CM0_TPCAT|CM0_INDOBI|CM0_COMPOL|CM0_CODSIT|CM0_DCODSI|CM0_INICAT|"
	
	// CAT Origem
	cGrpTra7  := "CM0_NRCAT|"
	
	// Campos do folder do número do ultimo protocolo
	cGrpTra8   := "CM0_PROTUL|"	

	If TafColumnPos("CM0_DTRANS")
		cGrpTra9 := "CM0_DINSIS|CM0_DTRANS|CM0_HTRANS|CM0_DTRECP|CM0_HRRECP|"
	EndIf
		
	cCmpFil := cGrpTra1 + cGrpTra2 + cGrpTra3 + cGrpTra4 + cGrpTra5 + cGrpTra6 + cGrpTra7 + cGrpTra8 + cGrpTra9
	oStruCM0 = FwFormStruct( 2, "CM0",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

	oStruCM0:AddGroup("GRP_REGISTRADOR"	, "Registrador CAT"		, "", 1 ) //"Registrador CAT"
	oStruCM0:AddGroup("GRP_CAT" 	 	, "CAT"					, "", 1 ) //"Grupo Atestado"
	oStruCM0:AddGroup("GRP_LOCAL"    	, "Local do Acidente"	, "", 1 ) //"Local do Acidente"
	oStruCM0:AddGroup("GRP_ATESTADO" 	, "Atestado Médico"  	, "", 1 ) //"Atestado Médico"
	oStruCM0:AddGroup("GRP_EMITENTE" 	, "Emitente"		  	, "", 1 ) //"Emitente"
	oStruCM0:AddGroup("GRP_CATORIGEM"	, "CAT Origem"			, "", 1 ) //"CAT Origem"
	oStruCM0:AddGroup( "GRP_RECIBO_01"	, TafNmFolder("recibo",1), "", 1 ) //Recibo da última Transmissão
	oStruCM0:AddGroup( "GRP_RECIBO_02", TafNmFolder("recibo",2), "", 1 ) //Informações de Controle eSocial
	
	TafAjustRecibo(oStruCM0,"CM0")
	
	// Registrador CAT
	aCmpGrp := StrToKArr(cGrpTra1,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCM0:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_REGISTRADOR")
	Next nI
	
	// Grupo Atestado
	aCmpGrp := StrToKArr(cGrpTra2,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCM0:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_CAT")
	Next nI
	
	// Local do Acidente
	aCmpGrp := StrToKArr(cGrpTra3,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCM0:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_LOCAL")
	Next nI

	// Atestado Médico
	aCmpGrp := StrToKArr(cGrpTra4,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCM0:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_ATESTADO")
	Next nI

	// Emitente
	aCmpGrp := StrToKArr(cGrpTra5,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCM0:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_EMITENTE")
	Next nI

	// Grupo Atestado
	aCmpGrp := StrToKArr(cGrpTra6,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCM0:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_CAT")
	Next nI

	// CAT Origem
	aCmpGrp := StrToKArr(cGrpTra7,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCM0:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_CATORIGEM")
	Next nI

	// Campos do folder do número do ultimo protocolo
	oStruCM0:SetProperty(Strtran(cGrpTra8,"|",""),MVC_VIEW_GROUP_NUMBER,"GRP_RECIBO_01")

	aCmpGrp := StrToKArr(cGrpTra9,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCM0:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_RECIBO_02")
	Next nI		
	
	oView:AddField( 'VIEW_CM0', oStruCM0, 'MODEL_CM0' )
	oView:EnableTitleView( 'VIEW_CM0', STR0001)//'Comunicação de Acidente de Trabalho'

	oView:AddGrid ( 'VIEW_CM1', oStruCM1, 'MODEL_CM1' )
	oView:GetModel('MODEL_CM1'):SetMaxLine(1)
	oView:EnableTitleView( 'VIEW_CM1', STR0002) //"Parte Atingida"

	oView:AddGrid ( 'VIEW_CM2', oStruCM2, 'MODEL_CM2' )
	oView:GetModel('MODEL_CM2'):SetMaxLine(1)
	oView:EnableTitleView( 'VIEW_CM2', STR0003)//'Agente Causador'

	oView:CreateFolder( 'PASTAS' )
	oView:AddSheet( 'PASTAS', 'ABA00', STR0001)//Comunicação de Acidente de Trabalhol'

	oView:CreateHorizontalBox( 'FIELDSCM0a', 065,,,'PASTAS','ABA00')

	oView:CreateHorizontalBox("PAINEL_INFERIOR",035,,,"PASTAS","ABA00")
	oView:CreateFolder( 'FOLDER_INFERIOR', 'PAINEL_INFERIOR' )

	oView:AddSheet( 'FOLDER_INFERIOR', 'ABA01', STR0002)//'Parte Atingida'
	oView:AddSheet( 'FOLDER_INFERIOR', 'ABA02', STR0003)//'Agente Causador'

	oView:CreateHorizontalBox( 'GRIDCM1', 100,,,'FOLDER_INFERIOR','ABA01')
	oView:CreateHorizontalBox( 'GRIDCM2', 100,,,'FOLDER_INFERIOR','ABA02')

	oView:SetOwnerView( 'VIEW_CM0', 'FIELDSCM0a' )
	oView:SetOwnerView( 'VIEW_CM1', 'GRIDCM1' )
	oView:SetOwnerView( 'VIEW_CM2', 'GRIDCM2' )

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	xFunRmFStr(oStruCM0, 'CM0')

	oStruCM0:SetProperty( "CM0_TPLOC" 	, MVC_VIEW_ORDEM		, "01"	)
	oStruCM0:SetProperty( "CM0_DESLOC"	, MVC_VIEW_ORDEM		, "02"	)
	oStruCM0:SetProperty( "CM0_CODPAI"	, MVC_VIEW_ORDEM		, "03"	)
	oStruCM0:SetProperty( "CM0_DCODPA"	, MVC_VIEW_ORDEM		, "04"	)
	oStruCM0:SetProperty( "CM0_CEP"		, MVC_VIEW_ORDEM		, "05"	)
	oStruCM0:SetProperty( "CM0_UF"		, MVC_VIEW_ORDEM		, "06"	)
	oStruCM0:SetProperty( "CM0_DUF"		, MVC_VIEW_ORDEM		, "07"	)
	oStruCM0:SetProperty( "CM0_CODMUN"	, MVC_VIEW_ORDEM		, "08"	)
	oStruCM0:SetProperty( "CM0_DCODMU"	, MVC_VIEW_ORDEM		, "09"	)
	oStruCM0:SetProperty( "CM0_BAIRRO"	, MVC_VIEW_ORDEM		, "10"	)
	oStruCM0:SetProperty( "CM0_TPLOGR"	, MVC_VIEW_ORDEM		, "11"	)
	oStruCM0:SetProperty( "CM0_DESLOG"	, MVC_VIEW_ORDEM		, "12"	)
	oStruCM0:SetProperty( "CM0_NRLOG" 	, MVC_VIEW_ORDEM		, "13"	)
	oStruCM0:SetProperty( "CM0_COMLOG"	, MVC_VIEW_ORDEM		, "14"	)
	oStruCM0:SetProperty( "CM0_INSACI"	, MVC_VIEW_ORDEM		, "15"	)
	oStruCM0:SetProperty( "CM0_NRIACI"	, MVC_VIEW_ORDEM		, "16"	)
	oStruCM0:SetProperty( "CM0_INSACI" 	, MVC_VIEW_INSERTLINE	, .T.	)

	oStruCM0:RemoveField( "CM0_LOGOPE" )
	oStruCM0:RemoveField("CM0_DNRCAT")
	oStruCM0:RemoveField("CM0_DTCAT")
	oStruCM0:RemoveField("CM0_TPREG")
	oStruCM0:RemoveField("CM0_DTPRE")
	oStruCM0:RemoveField("CM0_INSREG")
	oStruCM0:RemoveField("CM0_NRIREG")
	oStruCM0:RemoveField("CM0_DTPACI")
	oStruCM0:RemoveField("CM0_CNPJLO")
	oStruCM0:RemoveField("CM0_CODCAT")
	oStruCM0:RemoveField("CM0_DCATEG")
	oStruCM0:RemoveField('CM0_TPACID')
	oStruCM0:RemoveField('CM0_CODAMB')
	oStruCM0:RemoveField('CM0_CODCNE')
	oStruCM0:RemoveField('CM0_NOMEVE')
	
Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@Author Fabio V. Santana
@Since 08/10/2013
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local cLogOpeAnt := ""
	Local cVerAnt    := ""
	Local cProtocolo := ""
	Local cVersao    := ""
	Local cChvRegAnt := ""
	Local cEvento    := ""
	Local nOperation := oModel:GetOperation()
	Local nlI        := 0
	Local nlY        := 0
	Local aGrava     := {}
	Local aGravaCM1  := {}
	Local aGravaCM2  := {}
	Local oModelCM0  := Nil
	Local oModelCM1  := Nil
	Local oModelCM2  := Nil
	Local lRetorno   := .T.

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT

			TafAjustID( "CM0", oModel)

			oModel:LoadValue( 'MODEL_CM0', 'CM0_VERSAO', xFunGetVer() )

			TAFAltMan( 3 , 'Save' , oModel, 'MODEL_CM0', 'CM0_LOGOPE' , '2', '' )
			
			FwFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CM0->( DbSetOrder( 5 ) )
			If lGoExtemp .OR. CM0->( MsSeek( xFilial( 'CM0' ) + M->CM0_ID + '1' ) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o registro ja foi transmitido³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If CM0->CM0_STATUS $ ( "4" )

					oModelCM0 := oModel:GetModel( 'MODEL_CM0' )
					oModelCM1 := oModel:GetModel( 'MODEL_CM1' )
					oModelCM2 := oModel:GetModel( 'MODEL_CM2' )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao anterior do registro para gravacao do rastro³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVerAnt    := oModelCM0:GetValue( "CM0_VERSAO" )
					cProtocolo := oModelCM0:GetValue( "CM0_PROTUL" )
					cEvento	   := oModelCM0:GetValue( "CM0_EVENTO" )
					cLogOpeAnt := oModelCM0:GetValue( "CM0_LOGOPE" )
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu gravo as informacoes que foram carregadas       ³
					//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
					//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
					//³nao devem ser consideradas neste momento                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nlI := 1 To 1
						For nlY := 1 To Len( oModelCM0:aDataModel[ nlI ] )
							Aadd( aGrava, { oModelCM0:aDataModel[ nlI, nlY, 1 ], oModelCM0:aDataModel[ nlI, nlY, 2 ] } )
						Next
					Next

					For nlI := 1 To oModel:GetModel( 'MODEL_CM1' ):Length()

						oModel:GetModel( 'MODEL_CM1' ):GoLine(nlI)

						If !oModel:GetModel( 'MODEL_CM1' ):IsDeleted()
							aAdd (aGravaCM1 ,{oModelCM1:GetValue('CM1_CODPAR'),;
								oModelCM1:GetValue('CM1_LATERA')} )
						EndIf

					Next

					For nlI := 1 To oModel:GetModel( 'MODEL_CM2' ):Length()

						oModel:GetModel( 'MODEL_CM2' ):GoLine(nlI)

						If !oModel:GetModel( 'MODEL_CM2' ):IsDeleted()
							aAdd (aGravaCM2 ,{oModelCM2:GetValue('CM2_CODAGE')} )
						EndIf

					Next

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seto o campo como Inativo e gravo a versao do novo registro³
					//³no registro anterior                                       ³
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FAltRegAnt( 'CM0', '2' )

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
						oModel:LoadValue( 'MODEL_CM0', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
					Next

					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_CM0', 'CM0_LOGOPE' , '' , cLogOpeAnt )
					
					For nlI := 1 To Len( aGravaCM1 )

						If nlI > 1
							oModel:GetModel( 'MODEL_CM1' ):AddLine()
						EndIf
						oModel:LoadValue( "MODEL_CM1", "CM1_CODPAR", aGravaCM1[nlI][1] )
						oModel:LoadValue( "MODEL_CM1", "CM1_LATERA", aGravaCM1[nlI][2] )

					Next

					For nlI := 1 To Len( aGravaCM2 )

						If nlI > 1
							oModel:GetModel( 'MODEL_CM2' ):AddLine()
						EndIf
						oModel:LoadValue( "MODEL_CM2", "CM2_CODAGE", aGravaCM2[nlI][1] )

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
					oModel:LoadValue( 'MODEL_CM0', 'CM0_VERSAO', cVersao )
					oModel:LoadValue( 'MODEL_CM0', 'CM0_VERANT', cVerAnt )
					oModel:LoadValue( 'MODEL_CM0', 'CM0_PROTPN', cProtocolo )
					oModel:LoadValue( 'MODEL_CM0', 'CM0_PROTUL', "" )

					cAliasPai := "CM0"
					oModel:LoadValue( 'MODEL_'+ cAliasPai, cAliasPai + '_XMLID', "" )
					
					If nOperation == MODEL_OPERATION_DELETE
						oModel:LoadValue( 'MODEL_CM0', 'CM0_EVENTO', "E" )
					Else
						If cEvento == "E"
							oModel:LoadValue( 'MODEL_CM0', 'CM0_EVENTO', "I" )
						Else
							oModel:LoadValue( 'MODEL_CM0', 'CM0_EVENTO', "A" )
						EndIf
					EndIf

				ElseIf CM0->CM0_STATUS == ( "2" )
					TAFMsgVldOp( oModel, "2" )//"Registro não pode ser alterado. Aguardando processo da transmissão."
					lRetorno := .F.
				ElseIf CM0->CM0_STATUS == ( "6" )
					TAFMsgVldOp( oModel, "6" )//"Registro não pode ser alterado. Aguardando processo de transmissão do evento de Exclusão S-3000"
					lRetorno := .F.
				ElseIf CM0->CM0_STATUS == "7"
					TAFMsgVldOp( oModel, "7" )//"Registro não pode ser alterado, pois o evento de exclusão já se encontra na base do RET"
					lRetorno := .F.
				Else
					cLogOpeAnt := CM0->CM0_LOGOPE
					
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_CM0', 'CM0_LOGOPE' , '' , cLogOpeAnt )
					
					// Limpa campo de Status após alteração
					If RecLock( "CM0", .F. )
						CM0->CM0_STATUS := " "
						CM0->( MsUnlock() )
					EndIf

				EndIf

				If lRetorno

					//Gravo alteração para o Extemporâneo
					If lGoExtemp
						TafGrvExt( oModel, 'MODEL_CM0', 'CM0' )
					EndIf

					FwFormCommit( oModel )
				EndIf

			EndIf

		ElseIf nOperation == MODEL_OPERATION_DELETE

			cChvRegAnt := CM0->(CM0_ID + CM0_VERANT)

			TAFAltStat( 'CM0', " " )
			FwFormCommit( oModel )
			If CM0->CM0_EVENTO == "A" .Or. CM0->CM0_EVENTO == "E"
				TAFRastro( 'CM0', 1, cChvRegAnt, .T.,, IIF(Type ("oBrw") == "U", Nil, oBrw ))
			EndIf

		EndIf

	End Transaction

Return ( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF257Xml
Funcao de geracao do XML para atender o registro S-2210
Quando a rotina for chamada o registro deve estar posicionado

@Param:
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@Return:
cXml - Estrutura do Xml do Layout S-2210

@author Fabio V. Santana
@since 07/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF257Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

	Local cRegistrador 	:= {}
	Local aObsCAT 		:= {}
	Local cXmlEmi      	:= ""
	Local cXml         	:= ""
	Local cIdCateg     	:= ""
	Local cCodCat      	:= ""
	Local cMatric	   	:= ""
	Local cCateg	   	:= ""
	Local cLayout      	:= "2210"
	Local cReg         	:= "CAT"
	Local lXmlVLd      	:= IIf(FindFunction("TafXmlVLD"), TafXmlVLD("TAF257XML"), .T.)
	Local lObrigHrAcid 	:= .T.
	Local nIndex 	   	:= 2

	Default cSeqXml		:= ""
	Default cAlias 	   	:= "CM0"
	Default lJob       	:= .F.
	Default nRecno     	:= 0        

	If lXmlVLd

		cAlias := "C9V"
		cEvento := CM0->CM0_NOMEVE

		Do Case
			Case cEvento $ "S2190"
				cAlias 	:= "T3A"
				cMatric := "T3A_MATRIC"
				cCateg	:= "T3A_CODCAT"
				nIndex  := 3
				
			Case cEvento $ "S2200"
				cMatric := "C9V_MATRIC"

			Case cEvento $ "S2300"
				cMatric := "C9V_MATTSV"
				cCateg	:= "C9V_CATCI"
		EndCase

		If CM0->CM0_EVENTO $ "I|A"

			//ideVinculo
			DBSelectArea(cAlias)
			(cAlias)->(DBSetOrder(nIndex))
			(cAlias)->(MsSeek(CM0->CM0_FILIAL+CM0->CM0_TRABAL+"1"))
			
			cXml +=		"<ideVinculo>"
			cXml +=	 		xTafTag("cpfTrab",(cAlias)->&(cAlias + "_CPF"),,.F.)

			cMat := 	Posicione(cAlias, nIndex, CM0->CM0_FILIAL + CM0->CM0_TRABAL + "1", cMatric)
	
			If Empty(cMat) 

				cIdCateg := (cAlias)->&(cCateg)

				If !Empty( cIdCateg )
					cCodCat := Posicione("C87",1,xFilial("C87") + cIdCateg, "C87_CODIGO")
				EndIf

				cXml +=	xTafTag("codCateg", cCodCat,, .T.)

			Else
				cXml +=	xTafTag("matricula", cMat,, .T.)	
			EndIf

			cXml +=		"</ideVinculo>"

			cXml +=		"<cat>"
			cXml +=			xTafTag("dtAcid",CM0->CM0_DTACID,, .F.)			
			cXml +=			xTafTag("tpAcid",CM0->CM0_TIPACI,, .F.)
					
			If !CM0->CM0_TIPACI $ "1"
					lObrigHrAcid := .T.
			Else
				lObrigHrAcid := .F.
			EndIf
			
			cXml +=			xTafTag("hrAcid",StrTran(CM0->CM0_HRACID, ":", ""),,lObrigHrAcid)
			cXml +=			xTafTag("hrsTrabAntesAcid",StrTran(CM0->CM0_HRTRAB, ":", ""),,lObrigHrAcid)
			cXml +=			xTafTag("tpCat",CM0->CM0_TPCAT,, .F.)
			cXml +=			xTafTag("indCatObito",xFunTrcSN(CM0->CM0_INDOBI),, .F.)
			cXml +=			xTafTag("dtObito",CM0->CM0_DTOBIT,, .T. )
			cXml +=			xTafTag("indComunPolicia",xFunTrcSN(CM0->CM0_COMPOL),, .F.)
			cXml +=			xTafTag("codSitGeradora",POSICIONE("C8L",1, xFilial("C8L")+CM0->CM0_CODSIT ,"C8L_CODIGO"),, .F.)
			cXml +=			xTafTag("iniciatCAT",CM0->CM0_INICAT,, .F.)

			If TafColumnPos("CM0_OBSMEM") 
				aObsCAT := ObsCAT(CM0->(Recno()))

				If !Empty(aObsCAT[1]) .And. Empty(aObsCAT[2]) 
					cOBS := aObsCAT[1]
				Else 
					cOBS := aObsCAT[2] 
				EndIf
			Else
				cOBS := CM0->CM0_OBSCAT
			EndIf

			cXml +=			xTafTag("obsCAT", cOBS,, .T.)
			
			If TafColumnPos("CM0_ULTTRB")
				cXml += xTafTag("ultDiaTrab",CM0->CM0_ULTTRB,, .T.)
				cXml += xTafTag("houveAfast",CM0->CM0_HAFAS,, .T.)
			EndIf

			cXml +=			"<localAcidente>"
			cXml +=				xTafTag("tpLocal",CM0->CM0_TPLOC,, .F.)
			cXml +=				xTafTag("dscLocal",CM0->CM0_DESLOC,, .T. )
			cXml += 			xTafTag("tpLograd",Posicione("C06",3,xFilial("C06")+CM0->CM0_TPLOGR,"C06_CESOCI"),, .T.)
			cXml +=				xTafTag("dscLograd",CM0->CM0_DESLOG,, .F.)
			cXml +=				xTafTag("nrLograd",CM0->CM0_NRLOG,, .F. )
			cXml +=				xTafTag("complemento",CM0->CM0_COMLOG,, .T.)
			cXml += 			xTafTag("bairro",CM0->CM0_BAIRRO,, .T.)
			cXml += 			xTafTag("cep",CM0->CM0_CEP,, .T.)
			cXml +=				xTafTag("codMunic",Posicione("C09",3,xFilial("C09")+CM0->CM0_UF,"C09_CODIGO")+POSICIONE("C07",3, xFilial("C07")+CM0->CM0_CODMUN,"C07_CODIGO"),, .T. )
			cXml +=				xTafTag("uf",POSICIONE("C09",3, xFilial("C09")+CM0->CM0_UF,"C09_UF"),, .T. )
			cXml +=				xTafTag("pais",POSICIONE("C08",3, xFilial("C08")+CM0->CM0_CODPAI,"C08_PAISSX"),, .T. )
			cXml +=				xTafTag("codPostal",CM0->CM0_CODPOS,, .T. )

			xTafTagGroup( "ideLocalAcid"	, {	{ "tpInsc", CM0->CM0_INSACI,, .F. };
											,	{ "nrInsc", CM0->CM0_NRIACI,, .F. }};
											, @cXml,, .F.)			

			cXml +=			"</localAcidente>"

			CM1->( DbSetOrder( 1 ) )
			CM1->( MsSeek ( xFilial("CM1")+CM0->CM0_ID+CM0->CM0_VERSAO) )
			While !CM1->(Eof()) .And. CM0->(CM0_ID+CM0_VERSAO) == CM1->(CM1_ID+CM1_VERSAO)

				cXml +=			"<parteAtingida>"
				cXml +=				xTafTag("codParteAting",POSICIONE("C8I",1, xFilial("C8I")+CM1->CM1_CODPAR,"C8I_CODIGO"),, .F.)
				cXml +=				xTafTag("lateralidade",CM1->CM1_LATERA,, .F.)
				cXml +=			"</parteAtingida>"

				CM1->(DbSkip())

			EndDo

			CM2->( DbSetOrder( 1 ) )
			CM2->( MsSeek ( xFilial("CM2")+CM0->CM0_ID+CM0->CM0_VERSAO) )
			While !CM2->(Eof()) .And. CM0->(CM0_ID+CM0_VERSAO) == CM2->(CM2_ID+CM2_VERSAO)

				cXml +=			"<agenteCausador>"
				cXml +=				xTafTag("codAgntCausador",POSICIONE("C8J",1, xFilial("C8J")+CM2->CM2_CODAGE,"C8J_CODIGO"),, .F.)
				cXml +=			"</agenteCausador>"

				CM2->(DbSkip())

			EndDo

			CM7->( DbSetOrder( 1 ) )// No caso do Medico faço o seek para evitar que sejam efetuados mais de um posicione
			CM7->( MsSeek ( xFilial("CM7")+CM0->CM0_IDPROF) )

			xTafTagGroup("emitente", {	{"nmEmit"	, CM7->CM7_NOME													,, .F.},;
										{"ideOC"	, CM7->CM7_IDEOC												,, .F.},;
										{"nrOC" 	, CM7->CM7_NRIOC												,, .F.},;
										{"ufOC" 	, Posicione("C09", 3, xFilial("C09") + CM7->CM7_NRIUF, "C09_UF"),, .T.}},;
									@cXmlEmi,, .T.)

				//GRUPO NO LAYOUT CONSTA COMO NÃO OBRIGATORIO, POREM REALIZADOS TESTES NO RET FOI CONFIRMADO QUE ESTÝ COMO OBRIGATORIO
				xTafTagGroup("atestado",{ 	 { "dtAtendimento" 	,CM0->CM0_DTATEN				                                ,,.F. };
					,  {	"hrAtendimento" ,StrTran(CM0->CM0_HRATEN, ":", "")                                  				,,.F. };
					,  {	"indInternacao" ,xFunTrcSN(CM0->CM0_INDINT)                                         				,,.F. };
					,  {	"durTrat"       ,CM0->CM0_DURTRA                                                    				,,.F. };
					,  {	"indAfast"	    ,xFunTrcSN(CM0->CM0_INDAFA)                                        					,,.F. };
					,  {	"dscLesao"      ,POSICIONE("C8M",1, xFilial("C8M")+CM0->CM0_NATLES,"C8M_CODIGO")  					,,.F. };
					,  {	"dscCompLesao"  ,CM0->CM0_DESLES                                                   					,,.T. };
					,  {	"diagProvavel"  ,CM0->CM0_DIAPRO                                                    				,,.T. };
					,  {	"codCID"  	    ,StrTran(POSICIONE("CMM",1, xFilial("CMM")+CM0->CM0_CODCID,"CMM_CODIGO"), ".", "")  ,,.F. };
					,  {	"observacao"    ,CM0->CM0_OBSERV                                                    				,,.T. }};
					,  @cXml, { {"emitente", cXmlEmi, 1 } },.T.)

			If CM0->CM0_TPCAT $'2|3'

				xTafTagGroup("catOrigem";	
					,{{ "nrRecCatOrig", CM0->CM0_NRCAT,,.F.}};
					,@cXml)

			EndIf

			cXml +=	"</cat>"

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estrutura do cabecalho³

		cXml := xTafCabXml(cXml,"CM0", cLayout,cReg,,cSeqXml,cRegistrador)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa gravacao do registro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lJob
			xTafGerXml(cXml,cLayout)
		EndIf

	EndIf

Return(cXml)
//-------------------------------------------------------------------
/*/{Protheus.doc} TAF257Rul           

Regras para gravacao das informacoes do registro S-2210 do E-Social

@Param
nOper      - Operacao a ser realizada ( 3 = Inclusao / 4 = Alteracao / 5 = Exclusao )

@Return	
aRull  - Regras para a gravacao das informacoes


@author Fabio V. Santana
@since 07/10/2013
@version 1.0

/*/                        	
//-------------------------------------------------------------------
Static Function TAF257Rul( cInconMsg, nSeqErrGrv, cCodEvent, cOwner )

	Local aRull        := {}
	Local aInfComp     := {}
	Local aIncons      := {}
	Local cTpCat       := ""
	Local cLograd      := ""
	Local cTipacid 	   := ""
	Local cNrRecCat	   := ""
	Local cCabec 	   := "/eSocial/evtCAT"

	Default cInconMsg  := ""
	Default nSeqErrGrv := 0
	Default cCodEvent  := ""
	Default cOwner     := ""
		
	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideVinculo/cpfTrab"))

		If TafXNode( oDados , cCodEvent, cOwner,( cCabec + "/ideVinculo/matricula" ))

			cMat 	:= FTafGetVal(cCabec + "/ideVinculo/matricula", "C", .F., @aIncons, .F.)
			cCPF 	:= FTafGetVal(cCabec + "/ideVinculo/cpfTrab", "C", .F., @aIncons, .F.)
			aEvento := TAFIdFunc(cCPF, cMat)

			aAdd( aRull, { "CM0_TRABAL"  , aEvento[1] , "C", .T. } ) 
			aAdd( aRull, { "CM0_NOMEVE"  , aEvento[2] , "C", .T. } ) 

		Else

			aAdd( aRull, { "CM0_TRABAL"	, FGetIdInt( "cpfTrab",, cCabec + "/ideVinculo/cpfTrab",,,, @cInconMsg, @nSeqErrGrv, "codCateg", cCabec + "/ideVinculo/codCateg" )  , "C", .T. } )
			aAdd( aRull, { "CM0_NOMEVE" , "S2300" , "C", .T. } ) 

		EndIf

	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/dtAcid"))
		Aadd( aRull, {"CM0_DTACID", cCabec + "/cat/dtAcid","D", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/tpAcid"))
		cTipacid := FTAFGetVal( cCabec + "/cat/tpAcid"	, "C", .F.,aIncons, .F. )
		Aadd( aRull, {"CM0_TIPACI", cTipacid,"C", .T. } )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/hrAcid"))
		Aadd( aRull, {"CM0_HRACID", cCabec + "/cat/hrAcid","C", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/hrsTrabAntesAcid"))
		Aadd( aRull, {"CM0_HRTRAB", cCabec + "/cat/hrsTrabAntesAcid","C", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/tpCat"))
		Aadd( aRull, {"CM0_TPCAT", cCabec + "/cat/tpCat","C", .F.} )
		cTpCat := FTafGetVal( cCabec + "/cat/tpCat","C", .F., aIncons, .F.)
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, ( cCabec + "/cat/indCatObito"))
		Aadd( aRull, {"CM0_INDOBI", +;
			xFunTrcSN( TAFExisTag( cCabec + "/cat/indCatObito" ) ,2), "C", .T. } )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/dtObito"))
		Aadd( aRull, {"CM0_DTOBIT", cCabec + "/cat/dtObito","D", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/indComunPolicia"))
		Aadd( aRull, { "CM0_COMPOL", +;
			xFunTrcSN( TAFExisTag( cCabec + "/cat/indComunPolicia" ) ,2), "C", .T. } )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/codSitGeradora"))
		Aadd( aRull,  { "CM0_CODSIT", +;
			FGetIdInt( "codSitGeradora", "", +;
			cCabec + "/cat/codSitGeradora",,,,@cInconMsg, @nSeqErrGrv), "C", .T. } )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/iniciatCAT"))
		Aadd( aRull, {"CM0_INICAT", cCabec + "/cat/iniciatCAT","C", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/obsCAT"))
		Aadd( aRull, {IIf(TafColumnPos("CM0_OBSMEM"), "CM0_OBSMEM", "CM0_OBSCAT"), cCabec + "/cat/obsCAT","C", .F.} )
	EndIf

	If TafColumnPos("CM0_ULTTRB")
		If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/ultDiaTrab"))
			Aadd( aRull, {"CM0_ULTTRB", cCabec + "/cat/ultDiaTrab","D", .F.} )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/houveAfast"))
			Aadd( aRull, {"CM0_HAFAS", cCabec + "/cat/houveAfast","C", .F.} )
		EndIf
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/localAcidente/tpLocal"))
		Aadd( aRull, {"CM0_TPLOC", cCabec + "/cat/localAcidente/tpLocal","C", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/localAcidente/dscLocal"))
		Aadd( aRull, {"CM0_DESLOC", cCabec + "/cat/localAcidente/dscLocal","C", .F.} )
	Else
		Aadd( aRull, {"CM0_DESLOC", "","C", .T.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/localAcidente/tpLograd"))
		cLograd := FTAFGetVal( cCabec + "/cat/localAcidente/tpLograd"	, "C", .F.,, .F. )
		Aadd( aRull, {"CM0_TPLOGR", Posicione("C06",4,xFilial("C06")+cLograd,"C06_ID"),"C", .T.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/localAcidente/ideLocalAcid/tpInsc"))
		Aadd( aRull, {"CM0_INSACI", cCabec + "/cat/localAcidente/ideLocalAcid/tpInsc","C", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/localAcidente/ideLocalAcid/nrInsc"))
		Aadd( aRull, {"CM0_NRIACI", cCabec + "/cat/localAcidente/ideLocalAcid/nrInsc","C", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/localAcidente/dscLograd"))
		Aadd( aRull, {"CM0_DESLOG", cCabec + "/cat/localAcidente/dscLograd","C", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/localAcidente/nrLograd"))
		Aadd( aRull, {"CM0_NRLOG", cCabec + "/cat/localAcidente/nrLograd","C", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/localAcidente/complemento"))
		Aadd( aRull, {"CM0_COMLOG", cCabec + "/cat/localAcidente/complemento","C", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/localAcidente/bairro"))
		Aadd( aRull, {"CM0_BAIRRO", cCabec + "/cat/localAcidente/bairro","C", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/localAcidente/cep"))
		Aadd( aRull, {"CM0_CEP", cCabec + "/cat/localAcidente/cep","C", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/localAcidente/uf"))
		Aadd( aRull,  { "CM0_UF", +;
			FGetIdInt( "uf", "", +;
			cCabec + "/cat/localAcidente/uf",,,,@cInconMsg, @nSeqErrGrv) , "C", .T. } )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/localAcidente/codMunic"))
		Aadd( aRull, {"CM0_CODMUN", +;
			FGetIdInt( "codMunic", "uf", +;
			cCabec + "/cat/localAcidente/uf", +;
			cCabec + "/cat/localAcidente/codMunic",,,@cInconMsg, @nSeqErrGrv), "C", .T. } )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/localAcidente/pais"))
		Aadd( aRull, {"CM0_CODPAI", FGetIdInt( "codPais", "", cCabec + "/cat/localAcidente/pais",,,,@cInconMsg, @nSeqErrGrv), "C", .T. } )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/localAcidente/codPostal"))
		Aadd( aRull, {"CM0_CODPOS", cCabec + "/cat/localAcidente/codPostal","C", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/atestado/dtAtendimento"))
		Aadd( aRull, {"CM0_DTATEN", cCabec + "/cat/atestado/dtAtendimento","D", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/atestado/hrAtendimento"))
		Aadd( aRull, {"CM0_HRATEN", cCabec + "/cat/atestado/hrAtendimento","C", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/atestado/indInternacao"))
		Aadd( aRull, {"CM0_INDINT", +;
			xFunTrcSN( TAFExisTag( cCabec + "/cat/atestado/indInternacao" ) ,2),"C", .T.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/atestado/durTrat"))
		Aadd( aRull, {"CM0_DURTRA", cCabec + "/cat/atestado/durTrat","C", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/atestado/indAfast"))
		Aadd( aRull, {"CM0_INDAFA", +;
			xFunTrcSN( TAFExisTag( cCabec + "/cat/atestado/indAfast" ) ,2),"C", .T.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/atestado/dscLesao"))
		Aadd( aRull, {"CM0_NATLES", FGetIdInt( "dscLesao", "", cCabec + "/cat/atestado/dscLesao",,,,@cInconMsg, @nSeqErrGrv),"C", .T.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/atestado/dscCompLesao"))
		Aadd( aRull, {"CM0_DESLES", cCabec + "/cat/atestado/dscCompLesao","C", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/atestado/diagProvavel"))
		Aadd( aRull, {"CM0_DIAPRO", cCabec + "/cat/atestado/diagProvavel","C", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/atestado/codCID"))
		Aadd( aRull, {"CM0_CODCID", FGetIdInt( "codCID", "", cCabec + "/cat/atestado/codCID",,,,@cInconMsg, @nSeqErrGrv),"C", .T.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/atestado/observacao"))
		Aadd( aRull, {"CM0_OBSERV", cCabec + "/cat/atestado/observacao","C", .F.} )
	EndIf

	/*
	Cadastro do médico
	*/
	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/atestado/emitente/ufOC"))
		Aadd( aInfComp,{'CM7_NRIUF',FGetIdInt( "uf", "", +;
			cCabec + "/cat/atestado/emitente/ufOC",,,,@cInconMsg, @nSeqErrGrv)})
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/atestado/emitente/nmEmit"))
		Aadd( aInfComp,{'CM7_NOME',;
			FTafGetVal( cCabec + "/cat/atestado/emitente/nmEmit",;
			"C", .F., aIncons, .F.)})
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/atestado/emitente/ideOC"))
		Aadd( aInfComp,{'CM7_IDEOC',;
			FTafGetVal( cCabec + "/cat/atestado/emitente/ideOC",;
			"C", .F., aIncons, .F.)})
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/atestado/emitente/nrOC"))
		Aadd( aInfComp,{'CM7_NRIOC',;
			FTafGetVal( cCabec + "/cat/atestado/emitente/nrOC",;
			"C", .F., aIncons, .F.)})
	EndIf

	/*
	Cadastro do médico
	*/

	//Preenchendo array com informações que deverão ser gravadas caso não encontre o médico.
	//cNrOC:= FGetIdInt( "nrIOC", "", "/eSocial/evtCAT/cat/atestado/emitente/nrOc",,, aInfComp, @cInconMsg, @nSeqErrGrv)
	//Fim do preenchimento do array auxiliar.

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/atestado/emitente/nrOC"))
		Aadd( aRull, {"CM0_IDPROF", FGetIdInt( "nrOC", "", cCabec + "/cat/atestado/emitente/nrOC",,,aInfComp,@cInconMsg, @nSeqErrGrv), "C", .T. } )
	EndIf

	If FTafGetVal( cCabec + "/cat/tpCat","C", .F., , .F.) $ '2|3'

		If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/catOrigem/nrRecCatOrig"))

			// Preenche o registro que indica a CAT de origem, no caso de CAT de reabertura ou de comunicação de óbito
			cNrRecCat := TAFA257NrRec(cCabec + "/", cCodEvent, cOwner)
			
		EndIf

		Aadd( aRull, {"CM0_NRCAT", cNrRecCat ,"C", .T.} )

	EndIf

Return ( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF257Grv    
Funcao de gravacao para atender o registro S-2210

@parametros:                
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

@author Fabio V Santana
@since 26/09/2013	
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF257Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID, cEvtOri, lMigrador, lDepGPE, cKey )

	Local cLogOpeAnt   := ""
	Local cCmpsNoUpd   := "|CM0_FILIAL|CM0_ID|CM0_VERSAO|CM0_VERANT|CM0_PROTUL|CM0_PROTPN|CM0_EVENTO|CM0_STATUS|CM0_ATIVO|"
	Local cCabec       := "/eSocial/evtCAT"
	Local cInconMsg    := ""
	Local cCodEvent    := Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")
	Local cChave	   := ""
	Local cMat		   := ""
	Local cCPF		   := ""
	Local cNrRecCat	   := ""
	Local nlI          := 0
	Local nJ           := 0
	Local nSeqErrGrv   := 0
	Local nIndChv	   := 0
	Local lRet         := .F.
	Local aIncons      := {}
	Local aRules       := {}
	Local aChave       := {}
	Local aCommit	   := {}
	Local oModel       := Nil

	Private lVldModel  := .T. //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.
	Private oDados     := oXML

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
	Default lMigrador  := .F.
	Default lDepGPE    := .F.
	Default cKey       := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Controle se o evento é extemporâneo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	nIndChv := Iif(FTafGetVal( "/eSocial/evtCAT/cat/tpCat","C", .F., , .F.) $'2|3', 7, 4 ) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a Chave do registro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideVinculo/cpfTrab"))

		If TafXNode( oDados , cCodEvent, cOwner,( cCabec + "/ideVinculo/matricula" ))

			cMat 	:= FTafGetVal(cCabec + "/ideVinculo/matricula", "C", .F., @aIncons, .F.)
			cCPF 	:= FTafGetVal(cCabec + "/ideVinculo/cpfTrab", "C", .F., @aIncons, .F.)
			aEvento := TAFIdFunc(cCPF, cMat, @cInconMsg, @nSeqErrGrv)

			aAdd( aChave, { "C", "CM0_TRABAL"	, aEvento[1], .T. } )

		Else
			aAdd( aChave, { "C", "CM0_TRABAL"	, FGetIdInt( "cpfTrab",, cCabec + "/ideVinculo/cpfTrab",,,, @cInconMsg, @nSeqErrGrv, "codCateg", cCabec + "/ideVinculo/codCateg" ) , .T. } )
		EndIf

		cChave += Padr( aChave[ 1, 3 ], Tamsx3( aChave[ 1, 2 ])[1])

	EndIf

	Aadd( aChave, {"D", "CM0_DTACID", cCabec + "/cat/dtAcid"        , .F.	} )
	Aadd( aChave, {"C", "CM0_HRACID", cCabec + "/cat/hrAcid"        , .F.	} )
	Aadd( aChave, {"C", "CM0_TPCAT"	, cCabec + "/cat/tpCat"         , .F.	} )

	cChave	+= Padr( StrTran(FTafGetVal( "/eSocial/evtCAT/cat/dtAcid"	,'C',.F.,,.F.),"-","")	, Tamsx3( aChave[ 2, 2 ])[1] )
	cChave	+= Padr( FTafGetVal( "/eSocial/evtCAT/cat/hrAcid" 			,'C',.F.,,.F.)			, Tamsx3( aChave[ 3, 2 ])[1] )
	cChave	+= Padr( FTafGetVal( "/eSocial/evtCAT/cat/tpCat" 			,'C',.F.,,.F.)			, Tamsx3( aChave[ 4, 2 ])[1] )

	If FTafGetVal( cCabec + "/cat/tpCat","C", .F., , .F.) $ '2|3'

		If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/cat/catOrigem/nrRecCatOrig"))

			cNrRecCat := TAFA257NrRec(cCabec + "/",cCodEvent,cOwner)
		
		EndIf

		Aadd( aChave, {"C", "CM0_NRCAT", cNrRecCat, .T.	} )
		cChave	+= Padr( cNrRecCat , Tamsx3( aChave[ 5, 2 ])[1] )

	EndIf

	/*---------------------------------------------------------
	Verifica se o evento não foi transmitido
	---------------------------------------------------------*/
	DbSelectArea("CM0")	
	CM0->(DbSetOrder(nIndChv)) 
	If CM0->( MsSeek(FTafGetFil(cFilEv,@aIncons,"CM0") + cChave + '1' ) )
	
		If !CM0->CM0_STATUS $ ( "2|4|6" )
	
			nOpc := 4
	
		EndIf

	EndIf

	Begin Transaction

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao para validar se a operacao desejada pode ser realizada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FTafVldOpe( 'CM0', nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, 'TAFA257', cCmpsNoUpd,,,,, nTafRecno )

			cLogOpeAnt := CM0->CM0_LOGOPE

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrego array com os campos De/Para de gravacao das informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aRules := TAF257Rul(@cInconMsg, @nSeqErrGrv, cCodEvent, cOwner )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
			//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpc <> 5

				oModel:LoadValue( "MODEL_CM0", "CM0_FILIAL", CM0->CM0_FILIAL )
				oModel:LoadValue( "MODEL_CM0", "CM0_XMLID", cXmlID )
				oModel:LoadValue( "MODEL_CM0", "CM0_TAFKEY", cKey  )
					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Rodo o aRules para gravar as informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nlI := 1 To Len( aRules )
					oModel:LoadValue( "MODEL_CM0", aRules[ nlI, 01 ], FTafGetVal( aRules[ nlI, 02 ], aRules[nlI, 03], aRules[nlI, 04], @aIncons, .F. ) )
				Next

				if nOpc == 3
					TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_CM0', 'CM0_LOGOPE' , '1', '' )
				elseif nOpc == 4
					TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_CM0', 'CM0_LOGOPE' , '', cLogOpeAnt )
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Parte Atingida³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quando se trata de uma alteracao, deleto todas as linhas do Grid³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nOpc == 4
					For nJ := 1 to oModel:GetModel( 'MODEL_CM1' ):Length()
						oModel:GetModel( 'MODEL_CM1' ):GoLine(nJ)
						oModel:GetModel( 'MODEL_CM1' ):DeleteLine()
					Next nJ
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Rodo o XML parseado para gravar as novas informacoes no GRID³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nJ := 1

				While oDados:XPathHasNode( cCabec + "/cat/parteAtingida[" + CVALTOCHAR(nJ)+ "]" )

					oModel:GetModel( 'MODEL_CM1' ):LVALID	:= .T.

					If nOpc == 4 .Or. nJ > 1
						oModel:GetModel( 'MODEL_CM1' ):AddLine()
					EndIf

					If oDados:XPathHasNode( "/eSocial/evtCAT/cat/parteAtingida[" + CVALTOCHAR(nJ) + "]/codParteAting" )
						oModel:LoadValue( "MODEL_CM1", "CM1_CODPAR", FGetIdInt( "codParteAting", "", "/eSocial/evtCAT/cat/parteAtingida[" + CVALTOCHAR(nJ) + "]/codParteAting",,,,@cInconMsg, @nSeqErrGrv) )
					EndIf

					If oDados:XPathHasNode( "/eSocial/evtCAT/cat/parteAtingida[" + CVALTOCHAR(nJ) + "]/lateralidade" )
						oModel:LoadValue( "MODEL_CM1", "CM1_LATERA", FTafGetVal( "/eSocial/evtCAT/cat/parteAtingida[" + CVALTOCHAR(nJ) + "]/lateralidade", "C", .F., @aIncons, .F. ))
					EndIf

					nJ++

				EndDo

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Agente Causador³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quando se trata de uma alteracao, deleto todas as linhas do Grid³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nOpc == 4
					For nJ := 1 to oModel:GetModel( 'MODEL_CM2' ):Length()
						oModel:GetModel( 'MODEL_CM2' ):GoLine(nJ)
						oModel:GetModel( 'MODEL_CM2' ):DeleteLine()
					Next nJ
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Rodo o XML parseado para gravar as novas informacoes no GRID³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nJ := 1

				While oDados:XPathHasNode( cCabec + "/cat/agenteCausador[" + CVALTOCHAR(nJ)+ "]" )

					oModel:GetModel( 'MODEL_CM2' ):LVALID	:= .T.

					If nOpc == 4 .Or. nJ > 1
						oModel:GetModel( 'MODEL_CM2' ):AddLine()
					EndIf

					If oDados:XPathHasNode( cCabec + "/cat/agenteCausador[" + CVALTOCHAR(nJ) + "]/codAgntCausador" )
						oModel:LoadValue( "MODEL_CM2", "CM2_CODAGE", FGetIdInt( "codAgntCausador", "", "/eSocial/evtCAT/cat/agenteCausador[" + CVALTOCHAR(nJ) + "]/codAgntCausador",,,,@cInconMsg, @nSeqErrGrv) )
					EndIf

					nJ++

				EndDo

			EndIf

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
			TafClearModel(oModel)

		EndIf

	End Transaction

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Zerando os arrays e os Objetos utilizados no processamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize( aRules, 0 )
	aRules	:= Nil

	aSize( aChave, 0 )
	aChave	:= Nil

Return { lRet, aIncons }

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

	Local oModelCM0  := oModel:GetModel("MODEL_CM0")
	Local oModelCM1  := oModel:GetModel("MODEL_CM1")
	Local oModelCM2  := oModel:GetModel("MODEL_CM2")
	Local cVerAnt    := ""
	Local cProtocolo := ""
	Local cVersao    := ""
	Local cEvento    := ""
	Local nlI        := 0
	Local nlY        := 0
	Local aGrava     := {}
	Local aGravaCM1  := {}
	Local aGravaCM2  := {}

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	dbSelectArea("CM0")
	("CM0")->( DBGoTo( nRecno ) )

	Begin Transaction

		oModelCM0 := oModel:GetModel( 'MODEL_CM0' )
		oModelCM1 := oModel:GetModel( 'MODEL_CM1' )
		oModelCM2 := oModel:GetModel( 'MODEL_CM2' )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco a versao anterior do registro para gravacao do rastro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVerAnt   	:= oModelCM0:GetValue( "CM0_VERSAO" )
		cProtocolo	:= oModelCM0:GetValue( "CM0_PROTUL" )
		cEvento	    := oModelCM0:GetValue( "CM0_EVENTO" )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Neste momento eu gravo as informacoes que foram carregadas       ³
		//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
		//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
		//³nao devem ser consideradas neste momento                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nlI := 1 To 1
			For nlY := 1 To Len( oModelCM0:aDataModel[ nlI ] )
				Aadd( aGrava, { oModelCM0:aDataModel[ nlI, nlY, 1 ], oModelCM0:aDataModel[ nlI, nlY, 2 ] } )
			Next
		Next

		For nlI := 1 To oModel:GetModel( 'MODEL_CM1' ):Length()
			oModel:GetModel( 'MODEL_CM1' ):GoLine(nlI)

			If !oModel:GetModel( 'MODEL_CM1' ):IsDeleted()
				aAdd (aGravaCM1 ,{oModelCM1:GetValue('CM1_CODPAR')} )
			EndIf
		Next

		For nlI := 1 To oModel:GetModel( 'MODEL_CM2' ):Length()
			oModel:GetModel( 'MODEL_CM2' ):GoLine(nlI)

			If !oModel:GetModel( 'MODEL_CM2' ):IsDeleted()
				aAdd (aGravaCM2 ,{oModelCM2:GetValue('CM2_CODAGE')} )
			EndIf
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seto o campo como Inativo e gravo a versao do novo registro³
		//³no registro anterior                                       ³
		//|                                                           |
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FAltRegAnt( 'CM0', '2' )

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
			oModel:LoadValue( 'MODEL_CM0', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
		Next

		For nlI := 1 To Len( aGravaCM1 )
			If nlI > 1
				oModel:GetModel( 'MODEL_CM1' ):AddLine()
			EndIf
			oModel:LoadValue( "MODEL_CM1", "CM1_CODPAR", aGravaCM1[nlI][1] )
		Next

		For nlI := 1 To Len( aGravaCM2 )
			If nlI > 1
				oModel:GetModel( 'MODEL_CM2' ):AddLine()
			EndIf
			oModel:LoadValue( "MODEL_CM2", "CM2_CODAGE", aGravaCM2[nlI][1] )
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
		oModel:LoadValue( 'MODEL_CM0',  'CM0_VERSAO', cVersao )
		oModel:LoadValue( 'MODEL_CM0',  'CM0_VERANT', cVerAnt )
		oModel:LoadValue( 'MODEL_CM0',  'CM0_PROTPN', cProtocolo )
		oModel:LoadValue( 'MODEL_CM0',  'CM0_PROTUL', "" )

		/*---------------------------------------------------------
		Tratamento para que caso o Evento Anterior fosse de exclusão
		seta-se o novo evento como uma "nova inclusão", caso contrário o
		evento passar a ser uma alteração
		-----------------------------------------------------------*/
		oModel:LoadValue( 'MODEL_CM0', 'CM0_EVENTO', "E" )
		oModel:LoadValue( 'MODEL_CM0', 'CM0_ATIVO', "1" )

		//Gravo alteração para o Extemporâneo
		If lGoExtemp
			TafGrvExt( oModel, 'MODEL_CM0', 'CM0' )	
		EndIf

		FwFormCommit( oModel )
		TAFAltStat( 'CM0',"6" )
				
	End Transaction

Return .T.	

//-------------------------------------------------------------------
/*/{Protheus.doc} TafVDCAT
Rotina para validar a alteração da Data de acidente de Trabalho.

Caso houver evento de afastamento temporário por acidente de trabalho, 
a Data de Acidente somente poderá ser
retificada para uma data anterior à data de afastamento
 
REGRA_RETIFICA_DT_ACIDENTE

@Param		cIDTrab	-	Código do Trabalhador
			cDtaCid	-	Data de Acidente do Trabalhor
			lDic	-	Informa se é ou não Dicionário

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Mick William da Silva
@Since		25/02/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TafVDCAT( cIDTrab, cDtaCid, lDic )

	Local lRetorno := .T.

	Default lDic   := .F.

	lRetorno       := .T.

	dbSelectArea("CM6")
	DbSetOrder(2)

	If CM6->(MSSeek(xFilial("CM6") + cIDTrab))
		IF cDtaCid >= CM6->CM6_DTAFAS
			IF lDic == .T.
				MsgAlert("Existe um Evento de Afastamento Temporário com Data Anterior a Data de Acidente Informada.")
				lRetorno := .F.
			Else
				lRetorno := .F.
			EndIf
		EndIf
	EndIf

Return( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA257NrRec
Rotina para informar o número do recibo da CAT de origem.

@Param		cCabec		-	Arquivo de importação
			
@Return		cNrRecCat	-	Recibo da CAT de origem

@Author		Karyna R. M. Martins
@Since		20/02/2019
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function TAFA257NrRec(cCabec,cCodEvent,cOwner)

	Local aIncons      := {}
	Local cNrRecCat    := ""
	Local cIdFunc      := FGetIdInt("cpfTrab","", cCabec + "ideVinculo/cpfTrab")
	Local cTpCat       := FTafGetVal( cCabec + "cat/tpCat" ,"C", .F., aIncons, .F.)
	Local aCM0Area     := CM0->(GetArea())
	Local cSearch      := ""
	Local cQry         := ""
	Local cAliasQry    := GetNextAlias()
	Local cAliasTafKey := ""

	Default cCabec     := ""
	Default cCodEvent  := ""
	Default cOwner     := ""

	If cTpCat $ '2|3'

		cSearch := oDados:XPathGetNodeValue( cCabec + "cat/catOrigem/nrRecCatOrig")

		//Tratamento para quando enviarem o recibo
		CM0->(DbSetOrder(6))
		If CM0->(MsSeek( xFilial("CM0") + Padr(cSearch, TamSx3("CM0_PROTUL")[1]) + "1") )
			cNrRecCat := CM0->CM0_PROTUL
		Else

			//Tratamento realizado quando as linhas enviarem o TAFKEY

			cQry += "SELECT * FROM TAFXERP TAFXERP "
			cQry += "	WHERE TAFALIAS = 'CM0'"
			cQry += "   AND TAFXERP.TAFKEY IN ( '" + cSearch + "' ) "
			cQry += "   AND TAFXERP.TAFRECNO <> '0' "
			cQry += "   AND TAFXERP.D_E_L_E_T_ = '' "
			cQry += "   ORDER BY R_E_C_N_O_ DESC"

			cQry := ChangeQuery(cQry)

			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry ) , cAliasQry, .F., .T. )

			If (cAliasQry)->(!Eof())

				If !Empty((cAliasQry)->TAFALIAS)
					cAliasTafKey := (cAliasQry)->TAFALIAS
					(cAliasTafKey)->(dbGoTo((cAliasQry)->TAFRECNO))
					cNrRecCat := ( cAliasTafKey )->&( cAliasTafKey + "_PROTUL" )
				EndIf
				
			Else

				//Tratamento para o SIGAGPE
	            /*
	            Estrutura esperada no aSearch
	                1 - Cpf do Trabalhador
	                2 - Matricula
	                3 - Categoria
	                4 - Data do Acidente
	                5 - Hora do Acidente
	                6 - Tipo da Cat
	            */

				aSearch := Separa( cSearch, ";" )
				If Len(aSearch) == 6

					CM0->( DbSetOrder(4) )
					If CM0->(MSSeek(xFilial("CM0") + cIdFunc + aSearch[4] + aSearch[5] + aSearch[6] ))
						cNrRecCat := CM0->CM0_PROTUL
					EndIf

				EndIf

			EndIf

			(cAliasQry)->(DbCloseArea())

		EndIf

	EndIf

	RestArea(aCM0Area)

Return cNrRecCat

//---------------------------------------------------------------------
/*/{Protheus.doc} ConsultaCAT ou CATSearch
@type			function
@description	Executa a busca de tafkeys na tabela CM0 (Apenas GPE/MDT).
@author			Alexandre de Lima Santos / Karyna Rainho.
@since			25/03/2022
@param			aConsult	-	Array com filial, tafkey e chave de busca dos registros.
@return         aInfo - Array que retorna as informações com filial, tafkey, chave de busca e informações do registro.	
/*/
//---------------------------------------------------------------------
Function ConsultaCAT( aConsult as array )

Local aInfo 	as array
Local cFilcat   as character
Local cFilTaf   as character
Local cIdTrab   as character
Local cDtAcid   as character
Local cHrAcid   as character
Local cTpAcat   as character
Local cTafKey   as character
Local lPosic	as logical
Local lExistKey as logical
Local nCont 	as numeric
Local nTamFil   as numeric
Local nTamId    as numeric
Local nTamData  as numeric
Local nTamHr    as numeric
Local nTamTpCat as numeric
Local nTamKey   as numeric

Default aConsult := {}

aInfo  		:= {}
cFilcat   	:= ""
cFilTaf		:= ""
cIdTrab   	:= ""
cDtAcid   	:= ""
cHrAcid   	:= ""
cTpAcat   	:= ""
cTafKey   	:= "" 
lPosic		:= .F.
lExistKey 	:= TafColumnPos("CM0_TAFKEY")
nCont 		:= 0
nTamFil   	:= TamSx3("CM0_FILIAL")[1]
nTamId    	:= TamSx3("CM0_TRABAL")[1]
nTamData  	:= TamSx3("CM0_DTACID")[1]
nTamHr    	:= TamSx3("CM0_HRACID")[1]
nTamTpCat 	:= TamSx3("CM0_TPCAT")[1]
nTamKey   	:= Iif( lExistKey, TamSx3("CM0_TAFKEY")[1], 100)

For nCont := 1 to Len( aConsult )

	lPosic := .F.	

	If Len( aConsult[nCont] ) == 6

		cFilCat := Padr( aConsult[nCont][1], nTamFil )
		cFilTaf := FTafGetFil( cEmpAnt + cFilCat,,"CM0" )
		cTafKey := Padr( aConsult[nCont][2], nTamKey ) 		
		cIdTrab := Padr( aConsult[nCont][3], nTamId )
		cDtAcid := Padr( aConsult[nCont][4], nTamData )
		cHrAcid := Padr( aConsult[nCont][5], nTamHr )
		cTpAcat := Padr( aConsult[nCont][6], nTamTpCat )
			
		If lExistKey .And. !Empty(cTafKey)
			
			CM0->( DbSetOrder( 8 ) )
			
			If CM0->( dbSeek( cFilTaf + cTafKey + "1" ) )			
				lPosic := .T.		
				AADD( aInfo, { cFilcat, cTafKey, cIdTrab, cDtAcid, cHrAcid, cTpAcat, CM0->CM0_PROTUL, CM0->CM0_NRCAT, Dtos( CM0->CM0_DTRECP ), CM0->CM0_HRRECP } )					
			EndIf
		
		EndIf

		If !lPosic

			CM0->( DbSetOrder( 4 ) )

			If CM0->( dbSeek( cFilTaf + cIdTrab + cDtAcid + cHrAcid + cTpAcat + "1" ) )				
				AADD( aInfo, { cFilcat, cTafKey, cIdTrab, cDtAcid, cHrAcid, cTpAcat, CM0->CM0_PROTUL, CM0->CM0_NRCAT, dtos( CM0->CM0_DTRECP ), CM0->CM0_HRRECP } )	
			Else
				AADD( aInfo, { cFilcat, cTafKey, cIdTrab, cDtAcid, cHrAcid, cTpAcat, "", "", "", "" } )	
			EndIf		

		EndIf
			
	EndIf

Next	

Return aClone( aInfo )

//---------------------------------------------------------------------
/*/{Protheus.doc} ObsCAT
@type			static function
@description	Retorna os valores dos campos CM0_OBSCAT e CM0_OBSCAT
@author			Melkz Siqueira
@since			24/05/2022
@param			nRecno - R_E_C_N_O_ do registro posicionado na tabela CM0
@param			lInclui - Valida se é uma inclusão
@return         aObsCAT - Array contenedo os valores dos campos CM0_OBSCAT e CM0_OBSCAT
/*/
//---------------------------------------------------------------------
Static Function ObsCAT(nRecno, lInclui)
	
	Local aObsCAT	:= {"", ""}

	Default	lInclui	:= .F.
	Default	nRecno	:= 0 

	If !lInclui .And. TafColumnPos("CM0_OBSMEM") .And. nRecno != 0
		aObsCAT := {AllTrim(CM0->CM0_OBSCAT), AllTrim(CM0->CM0_OBSMEM)}
	EndIf

Return aObsCAT
