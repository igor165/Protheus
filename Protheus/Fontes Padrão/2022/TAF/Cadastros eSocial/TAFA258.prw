#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA258.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA258
Monitoramento da Saúde do Trabalhador (S-2220)

@author Vitor Siqueira
@since 03/03/2016
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA258()

	Private cEvtPosic := ""
	Private oBrw      := FWmBrowse():New()

	// Função que indica se o ambiente é válido para o eSocial 2.3
	If TafAtualizado()

		oBrw:SetDescription(STR0001)    //"Monitoração da Saúde do Trabalhador"
		oBrw:SetAlias( 'C8B')
		oBrw:SetMenuDef( 'TAFA258' )

		If FindFunction('TAFSetFilter')
			oBrw:SetFilterDefault(TAFBrwSetFilter("C8B","TAFA258","S-2220"))
		Else
			oBrw:SetFilterDefault( "C8B_ATIVO == '1'" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )
		EndIf

		TafLegend(2,"C8B",@oBrw)

		oBrw:Activate()
		
	EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Vitor Siqueira
@since 03/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao	:= {}
	Local aRotina	:= {}

	If FindFunction('TafXmlRet')
		Aadd( aFuncao, { "" , "TafxmlRet('TAF258Xml','2220','C8B')" , "1" } )
	Else
		Aadd( aFuncao, { "" , "TAF258Xml" , "1" } )
	EndIf

	//Chamo a Browse do Histórico
	If FindFunction( "xNewHisAlt" )
		Aadd( aFuncao, { "" , "xNewHisAlt('C8B', 'TAFA258' ,,,,,,'2220','TAF258Xml' )" , "3" } )
	Else
		Aadd( aFuncao, { "" , "xFunHisAlt('C8B', 'TAFA258' ,,,, 'TAF258XML','2220' )" , "3" } )
	EndIf

	aAdd( aFuncao, { "" , "TAFXmlLote( 'C8B', 'S-2220' , 'evtMonit' , 'TAF258Xml',, oBrw )" , "5" } )
	Aadd( aFuncao, { "" , "xFunAltRec( 'C8B' )" , "10" } )

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If lMenuDif
		ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA258' OPERATION 2 ACCESS 0
	Else
		aRotina	:=	xFunMnuTAF( "TAFA258" , , aFuncao)
	EndIf

Return (aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Vitor Siqueira
@since 03/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel   := MPFormModel():New('TAFA258', , , {|oModel| SaveModel(oModel)})
	Local oStruC8B := FWFormStruct( 1, 'C8B' )
	Local oStruC9W := FWFormStruct( 1, 'C9W' )

	//Remoção do GetSX8Num quando se tratar da Exclusão de um Evento Transmitido.
	//Necessário para não incrementar ID que não será utilizado.
	If Upper( ProcName( 2 ) ) == Upper( "GerarExclusao" )
		oStruC8B:SetProperty( "C8B_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )
	EndIf

	oModel:AddFields('MODEL_C8B', /*cOwner*/, oStruC8B)
	oModel:GetModel('MODEL_C8B'):SetPrimaryKey({'C8B_FILIAL', 'C8B_ID', 'C8B_VERSAO'})

	oModel:AddGrid('MODEL_C9W', 'MODEL_C8B', oStruC9W)
	oModel:GetModel('MODEL_C9W'):SetUniqueLine({'C9W_DTEXAM', 'C9W_CODPRO'})

	//C8B
	oStruC8B:SetProperty( 'C8B_RESULT'  , MODEL_FIELD_OBRIGAT , .F.  )
	oStruC8B:SetProperty( 'C8B_TPEXAM'  , MODEL_FIELD_OBRIGAT , .T.  )
	oStruC8B:SetProperty( 'C8B_TPASO'   , MODEL_FIELD_OBRIGAT , .F.  )
	oStruC8B:SetProperty( 'C8B_CONTAT'  , MODEL_FIELD_OBRIGAT , .F.  )

	//C9W
	oStruC9W:SetProperty( 'C9W_INTERP'  , MODEL_FIELD_OBRIGAT , .F.  )
	oStruC9W:SetProperty( 'C9W_CRMUF'   , MODEL_FIELD_OBRIGAT , .F.  )
	oStruC9W:SetProperty( 'C9W_CRMRES'  , MODEL_FIELD_OBRIGAT , .F.  )
	oStruC9W:SetProperty( 'C9W_NISRES'  , MODEL_FIELD_OBRIGAT , .F.  )
	oStruC9W:SetProperty( 'C9W_DTFIMO'  , MODEL_FIELD_OBRIGAT , .F.  )
	oStruC9W:SetProperty( 'C9W_DTINMO'  , MODEL_FIELD_OBRIGAT , .F.  )
	oStruC9W:SetProperty( 'C9W_DCRMU'   , MODEL_FIELD_OBRIGAT , .F.  )

	oModel:SetRelation('MODEL_C9W', {{'C9W_FILIAL' , 'xFilial( "C9W" )'}, {'C9W_ID' , 'C8B_ID'}, {'C9W_VERSAO' , 'C8B_VERSAO'}}, C9W->(IndexKey(1)))

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Vitor Siqueira
@since 03/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel    := FWLoadModel( 'TAFA258' )
	Local oStruC9W  := FWFormStruct( 2, 'C9W' )
	Local oStruC8Ba := Nil
	Local oStruC8Bb := Nil
	Local oStruC8Bc	:= Nil
	Local oView     := FWFormView():New()
	Local cCmpFil   := ''
	Local lNewCmp	:= .F.

	oView:SetModel( oModel )

	// Campos do folder Informacoes da Monitoração da Saúde do Trabalhador
	cCmpFil   := 'C8B_FUNC|C8B_DFUNC|C8B_DTASO|C8B_RESULT|C8B_CPFRES|C8B_NOMRES|C8B_NRCRM|C8B_CRMUF|C8B_DCRMU|C8B_CODMED|C8B_TPEXAM|'

	oStruC8Ba := FwFormStruct( 2, 'C8B', {|x| AllTrim( x ) + "|" $ cCmpFil },.T., .T. )
	oStruC8Ba:SetProperty( "C8B_CPFRES"	, MVC_VIEW_ORDEM, "12" )
	oStruC8Ba:SetProperty( "C8B_NRCRM"	, MVC_VIEW_ORDEM, "13" )
	oStruC8Ba:SetProperty( "C8B_NOMRES"	, MVC_VIEW_ORDEM, "14" )
	oStruC8Ba:SetProperty( "C8B_CRMUF"  , MVC_VIEW_ORDEM, "15" )

	aAux := oStruC8Ba:GetFields()

	lNewCmp := Iif(AScan(aAux, {|x| AllTrim(Upper(x[1])) == "C8B_DCRMU"}), .T., .F.)

	If lNewCmp
		oStruC8Ba:SetProperty( "C8B_DCRMU"  , MVC_VIEW_ORDEM, "16" )
		lNewCmp := .T.
	EndIf

	// Campos do folder do número do ultimo protocolo
	cCmpFil   := 'C8B_PROTUL|'
	oStruC8Bb := FwFormStruct( 2, 'C8B', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	If TafColumnPos("C8B_DTRANS")
		cCmpFil := "C8B_DINSIS|C8B_DTRANS|C8B_HTRANS|C8B_DTRECP|C8B_HRRECP|"
		oStruC8Bc := FwFormStruct( 2, 'C8B', {|x| AllTrim( x ) + "|" $ cCmpFil } )
	EndIf

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruC8Bb,"C8B")
	EndIf

	oView:AddField( 'VIEW_C8Ba', oStruC8Ba, 'MODEL_C8B' )
	oView:EnableTitleView( 'VIEW_C8Ba', STR0001 ) //Atestado de Saúde Ocupacional
	oView:AddField( 'VIEW_C8Bb', oStruC8Bb, 'MODEL_C8B' )

	If TafColumnPos("C8B_PROTUL")
		oView:EnableTitleView( 'VIEW_C8Bb',  TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"
	EndIf
	If TafColumnPos("C8B_DTRANS")
		oView:AddField( 'VIEW_C8Bc', oStruC8Bc, 'MODEL_C8B' )
		oView:EnableTitleView( 'VIEW_C8Bc',  TafNmFolder("recibo",2) )
	EndIf

	oStruC8Ba:AddGroup( 'GRP_TRABALHADOR', "Informações de Identificação do Trabalhador e do Vínculo"   , '' , 1 )  //Informações de Identificação do Trabalhador e do Vínculo
	oStruC8Ba:AddGroup( 'GRP_EXAME'  	 , "Informações do exame médico ocupacional"   					, '' , 1 )	//DInformações do exame médico ocupacional
	oStruC8Ba:AddGroup( 'GRP_ASO'        , "Detalhamento das informações do ASO"   						, '' , 1 )	//Detalhamento das informações do ASO
	oStruC8Ba:AddGroup( 'GRP_MEDICO'     , "Informações sobre o médico emitente do ASO"   				, '' , 1 )	//Informações sobre o médico emitente do ASO
	oStruC8Ba:AddGroup( 'GRP_RESPMED'    , "Informações sobre o médico responsável/coordenador do PCMSO", '' , 1 )	//Informações sobre o médico responsável/coordenador do PCMSO
	
	oStruC8Ba:SetProperty( 'C8B_FUNC'   , MVC_VIEW_GROUP_NUMBER , 'GRP_TRABALHADOR'	)
	oStruC8Ba:SetProperty( 'C8B_DFUNC'  , MVC_VIEW_GROUP_NUMBER , 'GRP_TRABALHADOR'	)
	oStruC8Ba:SetProperty( 'C8B_TPEXAM' , MVC_VIEW_GROUP_NUMBER , 'GRP_EXAME'      	)
	oStruC8Ba:SetProperty( 'C8B_DTASO'  , MVC_VIEW_GROUP_NUMBER , 'GRP_ASO'		   	)
	oStruC8Ba:SetProperty( 'C8B_RESULT' , MVC_VIEW_GROUP_NUMBER , 'GRP_ASO'			)
	oStruC8Ba:SetProperty( 'C8B_CODMED' , MVC_VIEW_GROUP_NUMBER , 'GRP_MEDICO'		)
	oStruC8Ba:SetProperty( 'C8B_CPFRES' , MVC_VIEW_GROUP_NUMBER , 'GRP_RESPMED'		)
	oStruC8Ba:SetProperty( 'C8B_NOMRES' , MVC_VIEW_GROUP_NUMBER , 'GRP_RESPMED'		)
	oStruC8Ba:SetProperty( 'C8B_NRCRM'  , MVC_VIEW_GROUP_NUMBER , 'GRP_RESPMED'		)
	oStruC8Ba:SetProperty( 'C8B_CRMUF'  , MVC_VIEW_GROUP_NUMBER , 'GRP_RESPMED'		)

	If lNewCmp
		oStruC8Ba:SetProperty( 'C8B_DCRMU'  , MVC_VIEW_GROUP_NUMBER , 'GRP_RESPMED'		)
	EndIf

	//C9W
	oStruC9W:RemoveField( "C9W_INTERP" )
	oStruC9W:RemoveField( "C9W_CRMUF"  )
	oStruC9W:RemoveField( "C9W_CRMRES" )
	oStruC9W:RemoveField( "C9W_NISRES" )
	oStruC9W:RemoveField( "C9W_DTFIMO" )
	oStruC9W:RemoveField( "C9W_DTINMO" )
	oStruC9W:RemoveField( "C9W_DCRMU"  )

	oView:AddGrid( 'VIEW_C9W', oStruC9W, 'MODEL_C9W' )
	oView:EnableTitleView( 'VIEW_C9W', STR0002) //"Exames"
	oView:CreateFolder( 'PASTAS' )
	oView:AddSheet( 'PASTAS', 'ABA00', STR0001)//'Atestado de saúde Ocupacional'

	If FindFunction("TafNmFolder")
		oView:AddSheet( 'PASTAS', 'ABA01', TafNmFolder("recibo") )   //"Numero do Recibo"
	Else
		oView:AddSheet( 'PASTAS', 'ABA01', STR0013)//'Protocolo da última Transmissão'
	EndIf

	oView:CreateHorizontalBox( 'FIELDSC8Ba', 045,,,'PASTAS','ABA00')
	If TafColumnPos("C8B_DTRANS")
		oView:CreateHorizontalBox( 'FIELDSC8Bb', 20,,,'PASTAS','ABA01')
		oView:CreateHorizontalBox( 'FIELDSC8Bc', 80,,,'PASTAS','ABA01')
	Else
		oView:CreateHorizontalBox( 'FIELDSC8Bb', 100,,,'PASTAS','ABA01')
	EndIf

	oView:CreateHorizontalBox("PAINEL_INFERIOR",055,,,"PASTAS","ABA00")
	oView:CreateFolder( 'FOLDER_INFERIOR', 'PAINEL_INFERIOR' )
	oView:AddSheet( 'FOLDER_INFERIOR', 'ABA01', STR0002)//'Exames'

	oView:CreateHorizontalBox( 'GRIDC9W', 100,,,'FOLDER_INFERIOR','ABA01')

	oView:SetOwnerView( 'VIEW_C8Ba', 'FIELDSC8Ba' )
	oView:SetOwnerView( 'VIEW_C8Bb', 'FIELDSC8Bb' )
	If TafColumnPos("C8B_DTRANS")
		oView:SetOwnerView( 'VIEW_C8Bc', 'FIELDSC8Bc' )
	EndIf
	oView:SetOwnerView( 'VIEW_C9W', 'GRIDC9W' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Vitor Siqueira
@since 03/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

	Local nOperation	:= oModel:GetOperation()
	Local nX			:= 0
	Local nY			:= 0
	Local oModelC8B 	:= oModel:GetModel("MODEL_C8B")
	Local cVerAnt   	:= ""
	Local cProtocolo	:= ""
	Local cVersao   	:= ""
	Local cEvento		:= ""
	Local cChvRegAnt	:= ""
	Local aGrava	 	:= {}
	Local aGravaC9W		:= {}
	Local lRetorno  	:= .T.
	Local cLogOpeAnt	:= ""

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT

			TafAjustID( "C8B", oModel)

			oModel:LoadValue( 'MODEL_C8B', 'C8B_VERSAO', xFunGetVer() )

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_C8B', 'C8B_LOGOPE' , '2', '' )
			Endif

			FwFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			C8B->( DbSetOrder( 3 ) )
			If lGoExtemp .OR. C8B->( MsSeek( xFilial( 'C8B' ) + M->C8B_ID + '1' ) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o registro ja foi transmitido³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If C8B->C8B_STATUS $ ( "4" )

					oModelC8B := oModel:GetModel( 'MODEL_C8B' )
					oModelC9W := oModel:GetModel( 'MODEL_C9W' )

					//³Busco a versao anterior do registro para gravacao do rastro³
					cVerAnt   	:= oModelC8B:GetValue( "C8B_VERSAO" )
					cProtocolo	:= oModelC8B:GetValue( "C8B_PROTUL" )
					cEvento		:= oModelC8B:GetValue( "C8B_EVENTO" )

					If TafColumnPos( "C8B_LOGOPE" )
						cLogOpeAnt := oModelC8B:GetValue( "C8B_LOGOPE" )
					endif

					//³Neste momento eu gravo as informacoes que foram carregadas    ³
					//³na tela, pois o usuario ja fez as modificacoes que precisava  ³
					//³mesmas estao armazenadas em memoria, ou seja, nao devem ser   ³
					//³ consideradas agora.					                         ³
					For nX := 1 To 1
						For nY := 1 To Len( oModelC8B:aDataModel[ nX ] )
							Aadd( aGrava, { oModelC8B:aDataModel[ nX, nY, 1 ], oModelC8B:aDataModel[ nX, nY, 2 ] } )
						Next
					Next

					For nX := 1 To oModel:GetModel( 'MODEL_C9W' ):Length()
						oModel:GetModel( 'MODEL_C9W' ):GoLine(nX)

						If !oModel:GetModel( 'MODEL_C9W' ):IsDeleted()
							aAdd (aGravaC9W ,{oModelC9W:GetValue('C9W_DTEXAM'),;
								oModelC9W:GetValue('C9W_CODPRO'),;
								oModelC9W:GetValue('C9W_OBS'),;
								oModelC9W:GetValue('C9W_INTERP'),;
								oModelC9W:GetValue('C9W_ORDEXA'),;
								oModelC9W:GetValue('C9W_DTINMO'),;
								oModelC9W:GetValue('C9W_DTFIMO'),;
								oModelC9W:GetValue('C9W_INDRES'),;
								oModelC9W:GetValue('C9W_NISRES'),;
								oModelC9W:GetValue('C9W_CRMRES'),;
								oModelC9W:GetValue('C9W_CRMUF')} )
						EndIf
					Next nX

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seto o campo como Inativo e gravo a versao do novo registro³
					//³no registro anterior                                       ³
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FAltRegAnt( 'C8B', '2' )

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
					For nX := 1 To Len( aGrava )
						oModel:LoadValue( 'MODEL_C8B', aGrava[ nX, 1 ], aGrava[ nX, 2 ] )
					Next

					//Necessário Abaixo do For Nao Retirar
					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_C8B', 'C8B_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					For nX := 1 To Len( aGravaC9W )
						If nX > 1
							oModel:GetModel( 'MODEL_C9W' ):AddLine()
						EndIf
						oModel:LoadValue( "MODEL_C9W", "C9W_DTEXAM", 		aGravaC9W[nX][1] )
						oModel:LoadValue( "MODEL_C9W", "C9W_CODPRO", 		aGravaC9W[nX][2] )
						oModel:LoadValue( "MODEL_C9W", "C9W_OBS", 		aGravaC9W[nX][3] )
						oModel:LoadValue( "MODEL_C9W", "C9W_INTERP", 		aGravaC9W[nX][4] )
						oModel:LoadValue( "MODEL_C9W", "C9W_ORDEXA", 		aGravaC9W[nX][5] )
						oModel:LoadValue( "MODEL_C9W", "C9W_DTINMO", 		aGravaC9W[nX][6] )
						oModel:LoadValue( "MODEL_C9W", "C9W_DTFIMO", 		aGravaC9W[nX][7] )
						oModel:LoadValue( "MODEL_C9W", "C9W_INDRES", 		aGravaC9W[nX][8] )
						oModel:LoadValue( "MODEL_C9W", "C9W_NISRES", 		aGravaC9W[nX][9] )
						oModel:LoadValue( "MODEL_C9W", "C9W_CRMRES", 		aGravaC9W[nX][10] )
						oModel:LoadValue( "MODEL_C9W", "C9W_CRMUF", 		aGravaC9W[nX][11] )
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
					oModel:LoadValue( 'MODEL_C8B', 'C8B_VERSAO', cVersao )
					oModel:LoadValue( 'MODEL_C8B', 'C8B_VERANT', cVerAnt )
					oModel:LoadValue( 'MODEL_C8B', 'C8B_PROTPN', cProtocolo )
					oModel:LoadValue( 'MODEL_C8B', 'C8B_PROTUL', "" )
					oModel:LoadValue( 'MODEL_C8B', 'C8B_EVENTO', "A" )

					// Tratamento para limpar o ID unico do xml
					cAliasPai := "C8B"
					If TAFColumnPos( cAliasPai+"_XMLID" )
						oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					EndIf

					//Gravo alteração para o Extemporâneo
					If lGoExtemp
						TafGrvExt( oModel, 'MODEL_C8B', 'C8B' )
					Endif

					FwFormCommit( oModel )
					TAFAltStat( 'C8B', " " )

				ElseIf	C8B->C8B_STATUS == "2"
					TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
					lRetorno:= .F.
				ElseIf C8B->C8B_STATUS == "6"
					TAFMsgVldOp(oModel,"6")//"Registro não pode ser alterado. Aguardando proc. Transm. evento de Exclusão S-3000"
					lRetorno:= .F.
				Elseif C8B->C8B_STATUS == "7"
					TAFMsgVldOp(oModel,"7") //"Registro não pode ser alterado, pois o evento já se encontra na base do RET"
					lRetorno:= .F.
				Else
					//alteração sem transmissão

					If TafColumnPos( "C8B_LOGOPE" )
						cLogOpeAnt := oModelC8B:GetValue( "C8B_LOGOPE" )
					endif

					//Gravo alteração para o Extemporâneo
					If lGoExtemp
						TafGrvExt( oModel, 'MODEL_C8B', 'C8B' )
					Endif

					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_C8B', 'C8B_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					FwFormCommit( oModel )
					TAFAltStat( 'C8B', " " )
				EndIf
			EndIf
		ElseIf nOperation == MODEL_OPERATION_DELETE

			cChvRegAnt := C8B->(C8B_ID + C8B_VERANT)

			If !Empty( cChvRegAnt )
				TAFAltStat( 'C8B', " " )
				FwFormCommit( oModel )
				If nOperation == MODEL_OPERATION_DELETE
					If C8B->C8B_EVENTO == "A" .Or. C8B->C8B_EVENTO == "E"
						TAFRastro( 'C8B', 1, cChvRegAnt, .T., , IIF(Type ("oBrw") == "U", Nil, oBrw ))
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

	If !lRetorno
		// Define a mensagem de erro que será exibida após o Return do SaveModel
		TAFMsgDel(oModel,.T.)
	EndIf

Return( lRetorno )
//-------------------------------------------------------------------
/*/{Protheus.doc} TAF258Xml
@author Vitor Siqueira
@since 03/03/2016
@version 1.0
		
@Param:
lJob - Informa se foi chamado por Job
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@return
cXml - Estrutura do Xml do Layout S-2220 
/*/
//-------------------------------------------------------------------
Function TAF258Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

	Local cXml    	:= ""
	Local cLayout 	:= "2220"
	Local cReg    	:= "Monit"
	Local cIdCateg	:= ""
	Local cCodCat	:= ""
	Local cEvento	:= ""
	Local cMatric	:= ""
	Local cCateg	:= ""
	Local cMat		:= ""
	Local nIndex 	:= 2
	Local lXmlVLd	:= IIF(FindFunction('TafXmlVLD'),TafXmlVLD('TAF258XML'),.T.)

	Default lJob 	:= .F.
	Default cAlias 	:= "C8B"
	Default nRecno	:= 1
	Default nOpc	:= 1
	Default cSeqXml := ""

	If lXmlVLd

		cAlias := "C9V"
		cEvento := C8B->C8B_NOMEVE

		Do Case
		Case cEvento $ "S2190"
			cAlias 	:= "T3A"
			cMatric := "T3A_MATRIC"
			cCateg	:= "T3A_CODCAT"
			nIndex := 3

		Case cEvento $ "S2200"
			cMatric := "C9V_MATRIC"

		Case cEvento $ "S2300"
			cMatric := "C9V_MATTSV"
			cCateg	:= "C9V_CATCI"
		EndCase

		//ideVinculo
		DBSelectArea(cAlias)
		(cAlias)->(DBSetOrder(nIndex))
		(cAlias)->(MsSeek(C8B->C8B_FILIAL+C8B->C8B_FUNC+"1"))

		cXml +=		"<ideVinculo>"
		cXml +=	    xTafTag("cpfTrab",(cAlias)->&(cAlias + "_CPF"),,.F.)

		cMat := 	Posicione(cAlias, nIndex, C8B->C8B_FILIAL + C8B->C8B_FUNC + "1", cMatric)

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

		//exMedOcup
		cXml +=		"<exMedOcup>"
		cXml +=			xTafTag("tpExameOcup",C8B->C8B_TPEXAM,,.F.)

		//aso
		cXml +=			"<aso>"
		cXml +=				xTafTag("dtAso",C8B->C8B_DTASO,,.F.)
		cXml +=				xTafTag("resAso",C8B->C8B_RESULT,,.T.)

		//exame
		DBSelectArea("C9W")
		C9W	->(DBSetOrder(1))
		If C9W->(MsSeek(C8B->C8B_FILIAL+C8B->C8B_ID+C8B->C8B_VERSAO ))
			While C9W->(!Eof()) .And. C9W->C9W_ID == C8B->C8B_ID .And. C9W->C9W_VERSAO == C8B->C8B_VERSAO

				cXml +=				"<exame>"
				cXml +=					xTafTag("dtExm", C9W->C9W_DTEXAM,,.F.)
				cXml +=					xTafTag("procRealizado", AllTrim(Posicione("V2K",1,xFilial("V2K")+ C9W->C9W_CODPRO, "V2K_CODIGO")),,.F.)
				cXml +=					xTafTag("obsProc", FwNoAccent( StrTran( C9W->C9W_OBS, Chr(13) + Chr(10), " ")),,.T.)
				cXml +=					xTafTag("ordExame", C9W->C9W_ORDEXA,,.T.)
				cXml +=					xTafTag("indResult", C9W->C9W_INDRES,,.T.)
				cXml +=				"</exame>"

				C9W->(DbSkip())

			EndDo
		EndIf

		//medico
		DBSelectArea("CM7")
		CM7	->(DBSetOrder(1))
		CM7->(MsSeek(xFilial('CM7')+C8B->C8B_CODMED))
		cXml +=				"<medico>"
		cXml +=					xTafTag("nmMed", CM7->CM7_NOME,,.F.)
		cXml +=					xTafTag("nrCRM", CM7->CM7_NRIOC,,.F.)
		cXml +=					xTafTag("ufCRM", Posicione("C09",3, xFilial("C09")+CM7->CM7_NRIUF ,"C09_UF"),,.F.)
		cXml +=				"</medico>"
		cXml +=			"</aso>"

		If !Empty(C8B->C8B_NOMRES)
			//respMonit
			cXml +=			"<respMonit>"
			cXml +=					xTafTag("cpfResp",C8B->C8B_CPFRES,,.T.)
			cXml +=					xTafTag("nmResp",	C8B->C8B_NOMRES,,.F.)
			cXml +=					xTafTag("nrCRM", C8B->C8B_NRCRM,,.F. )
			cXml +=					xTafTag("ufCRM", Posicione("C09",3, xFilial("C09")+C8B->C8B_CRMUF ,"C09_UF"),,.F.)
			cXml +=			"</respMonit>"
		EndIf

		cXml +=		"</exMedOcup>"

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Estrutura do cabecalho³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		cXml := xTafCabXml(cXml,"C8B",cLayout,cReg,,cSeqXml)
			
		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Executa gravacao do registro³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If !lJob
			xTafGerXml(cXml,cLayout)
		EndIf

	EndIf

Return(cXml)

//-------------------------------------------------------------------	
/*/{Protheus.doc} TAF258Grv
Funcao de gravacao para atender o registro S-2220	
@author Vitor Siqueira
@since 03/03/2016
@version 1.0
		
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
/*/
//-------------------------------------------------------------------
Function TAF258Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

	Local cLogOpeAnt 	:= ""
	Local cCmpsNoUpd 	:= "|C8B_FILIAL|C8B_ID|C8B_VERSAO|C8B_VERANT|C8B_PROTUL|C8B_PROTPN|C8B_EVENTO|C8B_STATUS|C8B_ATIVO|"
	Local cCabec     	:= "/eSocial/evtMonit"
	Local cChave		:= ""
	Local cInconMsg   	:= ""
	Local cMat			:= ""
	Local cCPF			:= ""
	Local cCodEvent  	:= Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")
	Local lRet       	:= .F.
	Local aIncons    	:= {}
	Local aRules     	:= {}
	Local aChave     	:= {}
	Local aEvento		:= {}
	Local aCommit		:= {}
	Local oModel     	:= Nil
	Local nX			:= 0
	Local nJ			:= 0
	Local nSeqErrGrv  	:= 0

	Private oDados 		:= oXML
	Private lVldModel 	:= .T. //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.
		
	Default cLayout 	:= ""
	Default nOpc     	:= 1
	Default cFilEv   	:= ""
	Default oXML     	:= Nil
	Default cOwner		:= ""
	Default cFilTran	:= ""
	Default cPredeces	:=	""
	Default nTafRecno	:=	0
	Default cComplem	:=	""
	Default cGrpTran	:=	""
	Default cEmpOriGrp	:=	""
	Default cFilOriGrp	:=	""
	Default cXmlID		:=	""

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideVinculo/cpfTrab"))
		If TafXNode( oDados , cCodEvent, cOwner,( cCabec + "/ideVinculo/matricula" ))
			cMat 	:= FTafGetVal(cCabec + "/ideVinculo/matricula", "C", .F., @aIncons, .F.)
			cCPF 	:= FTafGetVal(cCabec + "/ideVinculo/cpfTrab", "C", .F., @aIncons, .F.)
			aEvento := TAFIdFunc(cCPF, cMat)

			aAdd( aChave, { "C", "C8B_FUNC"	, aEvento[1], .T. } )
		Else
			aAdd( aChave, { "C", "C8B_FUNC"	, FGetIdInt( "cpfTrab",, cCabec + "/ideVinculo/cpfTrab",,,, @cInconMsg, @nSeqErrGrv, "codCateg", cCabec + "/ideVinculo/codCateg" ) , .T. } )
		EndIf

		cChave += Padr( aChave[ 1, 3 ], Tamsx3( aChave[ 1, 2 ])[1])
	EndIf

	Aadd( aChave, { "C", "C8B_TPEXAM", FTafGetVal( cCabec +  "/exMedOcup/tpExameOcup", "C", .F., @aIncons, .F. ), .T. } )
		cChave += (aChave[ 2, 3 ])

	Aadd( aChave, { "D", "C8B_DTASO", FTafGetVal( cCabec +  "/exMedOcup/aso/dtAso", "D", .F., @aIncons, .F. ), .T. } )
		cChave +=  DTOS(aChave[ 3, 3 ])

	//Verifica se o evento ja existe na base
	("C8B")->( DbSetOrder( 2 ) )
	If ("C8B")->( MsSeek( xFilial("C8B") + cChave +'1' ) )
		If !C8B->C8B_STATUS $ ( "2|4|6|" )
			nOpc := 4
		EndIf
	EndIf
		
	Begin Transaction 

		//Funcao para validar se a operacao desejada pode ser realizada
		If FTafVldOpe( "C8B", 2, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA258", cCmpsNoUpd )

			If TafColumnPos( "C8B_LOGOPE" )
				cLogOpeAnt := C8B->C8B_LOGOPE
			endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
			//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpc <> 5
				
				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                                    
				³Carrego array com os campos De/Para de gravacao das informacoes  ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				aRules := TAF258Rul(@cInconMsg, @nSeqErrGrv, cCodEvent, cOwner, cLayout )
				oModel:LoadValue( "MODEL_C8B", "C8B_FILIAL", C8B->C8B_FILIAL )
				
				If TAFColumnPos( "C8B_XMLID" )
					oModel:LoadValue( "MODEL_C8B", "C8B_XMLID", cXmlID )
				EndIf															
								
				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Rodo o aRules para gravar as informacoes³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				For nX := 1 To Len( aRules )                 					
					oModel:LoadValue( "MODEL_C8B", aRules[ nX, 01 ], FTafGetVal( aRules[ nX, 02 ], aRules[nX, 03], aRules[nX, 04], @aIncons, .F. ) )
				Next

				oModel:LoadValue( "MODEL_C8B", "C8B_CRMUF", FGetIdInt( "ufCRM", "", cCabec + "/exMedOcup/respMonit/ufCRM",,,,@cInconMsg, @nSeqErrGrv) )

				If Findfunction("TAFAltMan")
					if nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_C8B', 'C8B_LOGOPE' , '1', '' )
					elseif nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_C8B', 'C8B_LOGOPE' , '', cLogOpeAnt )
					EndIf
				EndIf

				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Quando se trata de uma alteracao, deleto todas as linhas do Grid³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/				
				If nOpc == 4
					For nJ := 1 to oModel:GetModel( 'MODEL_C9W' ):Length()  
						oModel:GetModel( 'MODEL_C9W' ):GoLine(nJ)
						oModel:GetModel( 'MODEL_C9W' ):DeleteLine() 
					Next nJ
				EndIf      
		
				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Rodo o XML parseado para gravar as novas informacoes no GRID³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				nJ := 1
				
				While oDados:XPathHasNode(cCabec +  "/exMedOcup/aso/exame[" + CVALTOCHAR(nJ)+ "]" )			
					
					oModel:GetModel( 'MODEL_C9W' ):LVALID	:= .T.				
					If nOpc == 4 .Or. nJ > 1
						oModel:GetModel( 'MODEL_C9W' ):AddLine()
					EndIf	       
					oModel:LoadValue( "MODEL_C9W", "C9W_DTEXAM"		, FTafGetVal( cCabec + "/exMedOcup/aso/exame[" + CVALTOCHAR(nJ)+ "]/dtExm" 	        , "D", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_C9W", "C9W_CODPRO"		, FGetIdInt( "procRealizado", "", cCabec + "/exMedOcup/aso/exame[" + CVALTOCHAR(nJ)+ "]/procRealizado",,,,@cInconMsg, @nSeqErrGrv ) )
					oModel:LoadValue( "MODEL_C9W", "C9W_OBS"		, FTafGetVal( cCabec + "/exMedOcup/aso/exame[" + CVALTOCHAR(nJ)+ "]/obsProc"  	    , "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_C9W", "C9W_ORDEXA"		, FTafGetVal( cCabec + "/exMedOcup/aso/exame[" + CVALTOCHAR(nJ)+ "]/ordExame"  	    , "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_C9W", "C9W_INDRES"		, FTafGetVal( cCabec + "/exMedOcup/aso/exame[" + CVALTOCHAR(nJ)+ "]/indResult"  		, "C", .F., @aIncons, .F. ) )
						
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

	oModel     := Nil
	
Return { lRet, aIncons } 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF258Rul
Regras para gravacao das informacoes do registro S-2220 do E-Social
	
@author Vitor Siqueira
@since 03/03/2016
@version 1.0		

@return
aRull  - Regras para a gravacao das informacoes
/*/
//-------------------------------------------------------------------
Function TAF258Rul( cInconMsg, nSeqErrGrv, cCodEvent, cOwner, cLayout )

	Local aRull     	:= {}
	Local aIncons		:= {}
	Local aInfComp		:= {}
	Local aEvento		:= {}
	Local cCabec 		:= "/eSocial/evtMonit"
	Local cMat			:= ""
	Local cCPF			:= ""

	Default cInconMsg	:= ""
	Default nSeqErrGrv	:= 0
	Default cCodEvent	:= ""
	Default cOwner		:= ""

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/ideVinculo/cpfTrab"))
		If TafXNode( oDados , cCodEvent, cOwner,( cCabec + "/ideVinculo/matricula" ))
			cMat 	:= FTafGetVal(cCabec + "/ideVinculo/matricula", "C", .F., @aIncons, .F.)
			cCPF 	:= FTafGetVal(cCabec + "/ideVinculo/cpfTrab", "C", .F., @aIncons, .F.)
			aEvento := TAFIdFunc(cCPF, cMat, @cInconMsg, @nSeqErrGrv)

			aAdd( aRull, { "C8B_FUNC" 	 , aEvento[1] , "C", .T. } ) 
			aAdd( aRull, { "C8B_NOMEVE"  , aEvento[2] , "C", .T. } ) 
		Else
			aAdd( aRull, { "C8B_FUNC"  	, FGetIdInt( "cpfTrab",, cCabec + "/ideVinculo/cpfTrab",,,, @cInconMsg, @nSeqErrGrv, "codCateg", cCabec + "/ideVinculo/codCateg" )  , "C", .T. } )
			aAdd( aRull, { "C8B_NOMEVE" , "S2300" , "C", .T. } ) 
		EndIf
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/exMedOcup/tpExameOcup"))
		aAdd( aRull, { "C8B_TPEXAM"  , cCabec + "/exMedOcup/tpExameOcup"  , "C", .F. } ) //tpExameOcup
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/exMedOcup/aso/dtAso"))
		aAdd( aRull, { "C8B_DTASO" , cCabec + "/exMedOcup/aso/dtAso"							, "D", .F. } ) //dtAso
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/exMedOcup/aso/resAso"))
		aAdd( aRull, { "C8B_RESULT", cCabec + "/exMedOcup/aso/resAso"							, "C", .F. } ) //resAso				
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/exMedOcup/respMonit/cpfResp"))
		aAdd( aRull, { "C8B_CPFRES", cCabec + "/exMedOcup/respMonit/cpfResp"							, "C", .F. } ) //cpfResp							
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/exMedOcup/respMonit/nrCRM"))
		aAdd( aRull, { "C8B_NRCRM", cCabec + "/exMedOcup/respMonit/nrCRM"							, "C", .F. } ) //nrCRM							
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/exMedOcup/respMonit/nmResp"))
		aAdd( aRull, { "C8B_NOMRES", cCabec + "/exMedOcup/respMonit/nmResp"							, "C", .F. } ) //nmResp							
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/exMedOcup/aso/medico/nmMed"))		 
		Aadd( aInfComp,{'CM7_NOME', FTafGetVal( cCabec + "/exMedOcup/aso/medico/nmMed", "C", .F., aIncons, .F.)}) 
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/exMedOcup/aso/medico/nrCRM"))		 
		Aadd( aInfComp,{'CM7_NRIOC', FTafGetVal( cCabec + "/exMedOcup/aso/medico/nrCRM", "C", .F., aIncons, .F.)}) 
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/exMedOcup/aso/medico/ufCRM"))
		Aadd( aInfComp,{'CM7_NRIUF',FGetIdInt( "ufCRM", "", +;
						cCabec + "/exMedOcup/aso/medico/ufCRM",,,,@cInconMsg, @nSeqErrGrv)}) 
	EndIf

	aAdd( aRull, { "C8B_CODMED"	, FGetIdInt( "nrCRM", "", cCabec + "/exMedOcup/aso/medico/nrCRM",,,aInfComp,@cInconMsg, @nSeqErrGrv)	, "C", .T. } ) //Codigo do Medico	

Return(aRull)

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclusão do evento (S-3000)

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function é chamada pelo TafIntegraESocial

@Return .T.

@Author Vitor Henrique Ferreira
@Since 04/03/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )

	Local cVerAnt		:= ""
	Local cProtocolo	:= ""
	Local cVersao  		:= ""
	Local cEvento		:= ""
	Local nX			:= 0
	Local nC8B  		:= 0 
	Local aGrava    	:= {}
	Local aGravaC9W		:= {}
	Local oModelC8B		:= Nil

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	dbSelectArea("C8B")

	Begin Transaction

		//Posiciona o item
		("C8B")->( DBGoTo( nRecno ) )
		
		oModelC8B := oModel:GetModel( 'MODEL_C8B' )
		oModelC9W := oModel:GetModel( 'MODEL_C9W' ) 
		
		//³Busco a versao anterior do registro para gravacao do rastro³
		cVerAnt   	:= oModelC8B:GetValue( "C8B_VERSAO" )				
		cProtocolo	:= oModelC8B:GetValue( "C8B_PROTUL" )
		cEvento		:= oModelC8B:GetValue( "C8B_EVENTO" )   
		
		//³Neste momento eu gravo as informacoes que foram carregadas    ³
		//³na tela, pois o usuario ja fez as modificacoes que precisava  ³
		//³mesmas estao armazenadas em memoria, ou seja, nao devem ser   ³
		//³ consideradas agora.					                         ³
		For nC8B := 1 to Len( oModelC8B:aDataModel[ 1 ] )
			aAdd( aGrava, { oModelC8B:aDataModel[ 1, nC8B, 1 ], oModelC8B:aDataModel[ 1, nC8B, 2 ] } )
		Next nC8B	 
		
		If C9W->(MsSeek(xFilial("C9W")+C8B->(C8B_ID + C8B_VERSAO) ) )
			For nX := 1 To oModel:GetModel( 'MODEL_C9W' ):Length() 
				oModel:GetModel( 'MODEL_C9W' ):GoLine(nX)
				
				If !oModel:GetModel( 'MODEL_C9W' ):IsDeleted()								
					aAdd (aGravaC9W ,{oModelC9W:GetValue('C9W_DTEXAM'),oModelC9W:GetValue('C9W_CODPRO')} )
				EndIf					
			Next nX
		EndIf
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seto o campo como Inativo e gravo a versao do novo registro³
		//³no registro anterior                                       ³ 
		//|                                                           |
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FAltRegAnt( 'C8B', '2' ) 
		
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
		For nX := 1 To Len( aGrava )	
			oModel:LoadValue( 'MODEL_C8B', aGrava[ nX, 1 ], aGrava[ nX, 2 ] )
		Next        		
			
		For nX := 1 To Len( aGravaC9W )
			
			oModel:GetModel( 'MODEL_C9W' ):LVALID	:= .T.
			
			If nX > 1
				oModel:GetModel( 'MODEL_C9W' ):AddLine()
			EndIf
			oModel:LoadValue( "MODEL_C9W", "C9W_DTEXAM", 		aGravaC9W[nX][1] )
			oModel:LoadValue( "MODEL_C9W", "C9W_CODPRO", 		aGravaC9W[nX][2] )						
		Next 		
																					
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco a versao que sera gravada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVersao := xFunGetVer()
		
		/*---------------------------------------------------------
		ATENCAO -> A alteracao destes campos deve sempre estar     
		abaixo do Loop do For, pois devem substituir as informacoes
		que foram armazenadas no Loop acima                        
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_C8B", "C8B_VERSAO", cVersao )
		oModel:LoadValue( "MODEL_C8B", "C8B_VERANT", cVerAnt )
		oModel:LoadValue( "MODEL_C8B", "C8B_PROTPN", cProtocolo )
		
		
		/*---------------------------------------------------------
		Tratamento para que caso o Evento Anterior fosse de exclusão
		seta-se o novo evento como uma "nova inclusão", caso contrário o
		evento passar a ser uma alteração
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_C8B", "C8B_EVENTO", "E" )
		oModel:LoadValue( "MODEL_C8B", "C8B_ATIVO", "1" )
			
		//Gravo alteração para o Extemporâneo
		If lGoExtemp
			TafGrvExt( oModel, 'MODEL_C8B', 'C8B' )	
		EndIf
		
		FwFormCommit( oModel )
		TAFAltStat( 'C8B',"6" )
		
	End Transaction

Return ( .T. )
