#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA253.CH'

STATIC lLaySimplif := taflayEsoc("S_01_00_00")

//----------------------------------------------------------------------
/*/{Protheus.doc} TAFA253
Cadastro MVC para atender o registro S - 1005 (Tabela de Estabelecimentos, Obras ou Unidades de Órgãos Públicos) do e-Social.

@author Leandro Prado 
@since 26/08/2013
@version 1.0
/*/ 
//--------------------------------------------------------------------
Function TAFA253()

	Private oBrw := FWmBrowse():New()

	// Função que indica se o ambiente é válido para o eSocial 2.3
	If TafAtualizado()

		oBrw:SetDescription( STR0001 ) //Tabela de Estabelecimentos
		oBrw:SetAlias( 'C92' )
		oBrw:SetMenuDef( 'TAFA253' )
		oBrw:SetFilterDefault( "C92_ATIVO == '1' .Or. (C92_EVENTO == 'E' .And. C92_STATUS = '4' .And. C92_ATIVO = '2')" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )

		oBrw:AddLegend( "C92_EVENTO == 'I' ", "GREEN" , STR0006 ) //"Registro Incluído"
		oBrw:AddLegend( "C92_EVENTO == 'A' ", "YELLOW", STR0007 ) //"Registro Alterado"
		oBrw:AddLegend( "C92_EVENTO == 'E' .And. C92_STATUS <> '4' ", "RED"   , STR0008 ) //"Registro excluído não transmitido"
		oBrw:AddLegend( "C92_EVENTO == 'E' .And. C92_STATUS == '4' .And. C92_ATIVO = '2' ", "BLACK"   , STR0014 ) //"Registro excluído transmitido"

		oBrw:Activate()

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author Leandro Prado
@since 26/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao  := {}
	Local aRotina  := {}

	If FindFunction('TafXmlRet')
		Aadd( aFuncao, { "" , "TafxmlRet('TAF253Xml','1005','C92')" , "1" } )
	Else
		Aadd( aFuncao, { "" , "TAF253Xml" , "1" } )
	EndIf

	Aadd( aFuncao, { "" , "xFunHisAlt( 'C92', 'TAFA253',,,,'TAF253XML','1005'  )" , "3" } )
	aAdd( aFuncao, { "" , "TAFXmlLote( 'C92', 'S-1005' , 'evtTabEstab' , 'TAF253Xml',, oBrw )" , "5" } )
	Aadd( aFuncao, { "" , "xFunAltRec( 'C92' )" , "10" } )

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If lMenuDif
		ADD OPTION aRotina Title STR0009 Action 'VIEWDEF.TAFA253' OPERATION 2 ACCESS 0 //"Visualizar"
	Else
		aRotina	:=	xFunMnuTAF( "TAFA253" , , aFuncao )
	EndIf

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Leandro Prado
@since 26/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------     
Static Function ModelDef()

	Local oStruC92
	Local oStruT0Z
	Local oModel

	oStruC92	:= FWFormStruct( 1, 'C92' )// Cria a estrutura a ser usada no Modelo de Dados
	oStruT0Z	:= FWFormStruct( 1, 'T0Z' )
	
	If lLaySimplif
		oStruC92:RemoveField("C92_AJURAT")
		oStruC92:RemoveField("C92_REGPT")
		oStruC92:RemoveField("C92_CONTAP")
		oStruC92:RemoveField("C92_CTENTE")
		oStruC92:RemoveField("C92_CONPCD")
	EndIf

	oModel		:= MPFormModel():New("TAFA235",,,{|oModel| SaveModel(oModel)})

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruC92:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	EndIf

	// Adiciona ao modelo um componente de formulário
	oModel:AddFields( 'MODEL_C92', /*cOwner*/, oStruC92)
	oModel:GetModel( 'MODEL_C92' ):SetPrimaryKey({ 'C92_TPINSC' , 'C92_NRINSC' , 'C92_DTINI' , 'C92_DTFIN' })

	oModel:AddGrid( "MODEL_T0Z", "MODEL_C92", oStruT0Z )
	oModel:GetModel( "MODEL_T0Z" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_T0Z" ):SetUniqueLine( { "T0Z_CNPJEE"} )

	oModel:SetRelation( "MODEL_T0Z",{ { "T0Z_FILIAL", "xFilial('T0Z')" }, { "T0Z_ID", "C92_ID" }, { "T0Z_VERSAO", "C92_VERSAO" } },T0Z->( IndexKey( 1 ) ) )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Leandro Prado
@since 26/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel

	Local oStruC92
	Local oStruT0Z

	Local oView

	oModel		:= FWLoadModel( 'TAFA253' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado

	oStruC92	:= FWFormStruct( 2, 'C92' )// Cria a estrutura a ser usada na View
	oStruT0Z	:= FWFormStruct( 2, 'T0Z' )// Cria a estrutura a ser usada na View

	If lLaySimplif
		oStruC92:RemoveField("C92_AJURAT")
		oStruC92:RemoveField("C92_REGPT")
		oStruC92:RemoveField("C92_CONTAP")
		oStruC92:RemoveField("C92_CTENTE")
		oStruC92:RemoveField("C92_CONPCD")
	EndIf

	If !TAFNT0421(lLaySimplif) .And. TafColumnPos("C92_CNPJRE")
		oStruC92:RemoveField("C92_CNPJRE")
	EndIf

	oView		:= FWFormView():New()

	oView:SetModel( oModel )

	// Seto a ordem dos campos em tela
	oStruC92:SetProperty( "C92_TPINSC", MVC_VIEW_ORDEM, "04" )
	oStruC92:SetProperty( "C92_NRINSC", MVC_VIEW_ORDEM, "05" )
	oStruC92:SetProperty( "C92_DTINI" , MVC_VIEW_ORDEM, "06" )
	oStruC92:SetProperty( "C92_DTFIN" , MVC_VIEW_ORDEM, "07" )
	oStruC92:SetProperty( "C92_CNAE"  , MVC_VIEW_ORDEM, "08" )
	oStruC92:SetProperty( "C92_ALQRAT", MVC_VIEW_ORDEM, "09" )
	oStruC92:SetProperty( "C92_FAP"   , MVC_VIEW_ORDEM, "10" )

	IF !lLaySimplif

		oStruC92:SetProperty( "C92_AJURAT", MVC_VIEW_ORDEM, "11" )
		oStruC92:SetProperty( "C92_PRORAT", MVC_VIEW_ORDEM, "12" )
		oStruC92:SetProperty( "C92_DPRORA", MVC_VIEW_ORDEM, "13" )
		oStruC92:SetProperty( "C92_CODSUR", MVC_VIEW_ORDEM, "14" )
		oStruC92:SetProperty( "C92_PROFAP", MVC_VIEW_ORDEM, "15" )
		oStruC92:SetProperty( "C92_DPROFA", MVC_VIEW_ORDEM, "16" )
		oStruC92:SetProperty( "C92_CODSUF", MVC_VIEW_ORDEM, "17" )
		oStruC92:SetProperty( "C92_TPCAEP", MVC_VIEW_ORDEM, "18" )
		oStruC92:SetProperty( "C92_SUBPAT", MVC_VIEW_ORDEM, "19" )
		oStruC92:SetProperty( "C92_REGPT" , MVC_VIEW_ORDEM, "20" )
		oStruC92:SetProperty( "C92_CONTAP", MVC_VIEW_ORDEM, "21" )
		oStruC92:SetProperty( "C92_PROCAP", MVC_VIEW_ORDEM, "22" )
		oStruC92:SetProperty( "C92_DPROCA", MVC_VIEW_ORDEM, "23" )
		oStruC92:SetProperty( "C92_CTENTE", MVC_VIEW_ORDEM, "24" )
		oStruC92:SetProperty( "C92_CONPCD", MVC_VIEW_ORDEM, "25" )
		oStruC92:SetProperty( "C92_PROCPD", MVC_VIEW_ORDEM, "26" )
		oStruC92:SetProperty( "C92_DPRCPD", MVC_VIEW_ORDEM, "27" )
		oStruC92:SetProperty( "C92_INDOBR", MVC_VIEW_ORDEM, "28" )

	Else //Simplificação	
	
		oStruC92:SetProperty( "C92_PRORAT", MVC_VIEW_ORDEM, "11" )
		oStruC92:SetProperty( "C92_DPRORA", MVC_VIEW_ORDEM, "12" )
		oStruC92:SetProperty( "C92_CODSUR", MVC_VIEW_ORDEM, "13" )
		oStruC92:SetProperty( "C92_PROFAP", MVC_VIEW_ORDEM, "14" )
		oStruC92:SetProperty( "C92_DPROFA", MVC_VIEW_ORDEM, "15" )
		oStruC92:SetProperty( "C92_CODSUF", MVC_VIEW_ORDEM, "16" )
		oStruC92:SetProperty( "C92_TPCAEP", MVC_VIEW_ORDEM, "17" )
		oStruC92:SetProperty( "C92_SUBPAT", MVC_VIEW_ORDEM, "18" )
		oStruC92:SetProperty( "C92_PROCAP", MVC_VIEW_ORDEM, "19" )
		oStruC92:SetProperty( "C92_DPROCA", MVC_VIEW_ORDEM, "20" )
		oStruC92:SetProperty( "C92_PROCPD", MVC_VIEW_ORDEM, "21" )
		oStruC92:SetProperty( "C92_DPRCPD", MVC_VIEW_ORDEM, "22" )
		oStruC92:SetProperty( "C92_INDOBR", MVC_VIEW_ORDEM, "23" )

	EndIf

	If TAFNT0421(lLaySimplif) .And. TafColumnPos("C92_CNPJRE")
		oStruC92:SetProperty("C92_CNPJRE", MVC_VIEW_ORDEM, "24")
	EndIf

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruC92,"C92")
	EndIf

	oView:AddField( 'VIEW_C92', oStruC92, 'MODEL_C92' )
	oView:EnableTitleView( 'VIEW_C92',  STR0001 ) //Tabela de Estabelecimentos

	oView:AddGrid( 'VIEW_T0Z', oStruT0Z, 'MODEL_T0Z' )
	oView:EnableTitleView( 'VIEW_T0Z', STR0013 ) //Identificação das entidades educativas

	oView:CreateHorizontalBox( 'FIELDSC92', 70 )
	oView:CreateHorizontalBox( 'FIELDST0Z', 30 )

	oView:SetOwnerView( 'VIEW_C92', 'FIELDSC92' )
	oView:SetOwnerView( 'VIEW_T0Z', 'FIELDST0Z' )

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If !lMenuDif
		xFunRmFStr(@oStruC92, 'C92')
	EndIf

	If TafColumnPos( "C92_LOGOPE" )
		oStruC92:RemoveField( "C92_LOGOPE")
	EndIf

Return oView

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

	Local cVerAnt
	Local cProtocolo
	Local cEvento
	Local cVersao
	Local cChvRegAnt
	Local cLogOpe
	Local cLogOpeAnt
	Local nOperation
	Local nI
	Local nX
	Local aGrava
	Local aGravaT0Z
	Local oModelC92
	Local lRetorno
	Local oModelT0Z

	cVerAnt    := ""
	cProtocolo := ""
	cEvento    := ""
	cVersao    := ""
	cChvRegAnt := ""
	cLogOpe    := ""
	cLogOpeAnt := ""

	nOperation := oModel:GetOperation()
	nI         := 0
	nX         := 0
	aGrava     := {}
	oModelC92  := Nil
	lRetorno   := .T.
	aGravaT0Z	 := {}
	oModelT0Z	 := Nil

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT

			TafAjustID( "C92", oModel)

			oModel:LoadValue( "MODEL_C92", "C92_VERSAO", xFunGetVer() )

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_C92', 'C92_LOGOPE' , '2', '' )
			Endif

			FwFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE .or. nOperation == MODEL_OPERATION_DELETE

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			C92->( DbSetOrder( 5 ) )
			If C92->( MsSeek( xFilial( 'C92' ) + FwFldGet( "C92_ID" ) + '1' ) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o registro ja foi transmitido³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If C92->C92_STATUS == "4"

					If nOperation == MODEL_OPERATION_DELETE
						oModel:DeActivate()
						oModel:SetOperation( 4 )
						oModel:Activate()
					EndIf

					oModelT0Z := oModel:GetModel("MODEL_T0Z")
					oModelC92 := oModel:GetModel( "MODEL_C92" )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao anterior do registro para gravacao do rastro³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVerAnt    := oModelC92:GetValue( "C92_VERSAO" )
					cProtocolo := oModelC92:GetValue( "C92_PROTUL" )
					cEvento    := oModelC92:GetValue( "C92_EVENTO" )

					If TafColumnPos( "C92_LOGOPE" )
						cLogOpeAnt := oModelC92:GetValue( "C92_LOGOPE" )
					endif

					If nOperation == MODEL_OPERATION_DELETE .And. cEvento == "E"
						// Não é possível excluir um evento de exclusão já transmitido
						TAFMsgVldOp(oModel,"4")
						lRetorno := .F.
					Else

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Neste momento eu gravo as informacoes que foram carregadas na tela³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nI := 1 to Len( oModelC92:aDataModel[ 1 ] )
							aAdd( aGrava, { oModelC92:aDataModel[ 1, nI, 1 ], oModelC92:aDataModel[ 1, nI, 2 ] } )
						Next nI

						// --> Entidade Educativas
						For nX := 1 To oModelT0Z:Length()
							oModelT0Z:GoLine(nX)
							If !( oModelT0Z:IsEmpty() )
								If !( oModelT0Z:IsDeleted() )
									Aadd(aGravaT0Z, oModelT0Z:GetValue("T0Z_CNPJEE") )
								EndIf
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
						FAltRegAnt( 'C92', '2' ,.F.,FwFldGet("C92_DTFIN"),FwFldGet("C92_DTINI"),C92->C92_DTINI )

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Neste momento eu preciso setar a operacao do model como Inclusao³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						oModel:DeActivate()
						oModel:SetOperation( 3 )
						oModel:Activate()

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Neste momento eu realizo a inclusao do novo registro ja³
						//³contemplando as informacoes alteradas pelo usuario     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nI := 1 to Len( aGrava )
							oModel:LoadValue( "MODEL_C92", aGrava[ nI, 1 ], aGrava[ nI, 2 ] )
						Next nI

						//Necessário Abaixo do For Nao Retirar
						If Findfunction("TAFAltMan")
							TAFAltMan( 4 , 'Save' , oModel, 'MODEL_C92', 'C92_LOGOPE' , '' , cLogOpeAnt )
						EndIf

						// --> Entidade Educativas
						For nX := 1 To Len(aGravaT0Z)
							If nX > 1
								oModel:GetModel("MODEL_T0Z"):AddLine()
							EndIf

							oModel:LoadValue("MODEL_T0Z", "T0Z_CNPJEE", aGravaT0Z[nX] )
						Next nX

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Busco a versao que sera gravada³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cVersao := xFunGetVer()

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//|ATENCAO -> A alteracao destes campos deve sempre estar     |
						//|abaixo do Loop do For, pois devem substituir as informacoes|
						//|que foram armazenadas no Loop acima                        |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						oModel:LoadValue( "MODEL_C92", "C92_VERSAO", cVersao )
						oModel:LoadValue( "MODEL_C92", "C92_VERANT", cVerAnt )
						oModel:LoadValue( "MODEL_C92", "C92_PROTPN", cProtocolo )
						oModel:LoadValue( "MODEL_C92", "C92_PROTUL", "" )
						// Tratamento para limpar o ID unico do xml
						cAliasPai := "C92"
						If TAFColumnPos( cAliasPai+"_XMLID" )
							oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
						EndIf

						If nOperation == MODEL_OPERATION_DELETE
							oModel:LoadValue( "MODEL_C92", "C92_EVENTO", "E" )
						Else
							If cEvento == "E"
								oModel:LoadValue( "MODEL_C92", "C92_EVENTO", "I" )
							Else
								oModel:LoadValue( "MODEL_C92", "C92_EVENTO", "A" )
							EndIf
						EndIf
						FwFormCommit( oModel )

					Endif

				Elseif C92->C92_STATUS == "2"
					//Não é possível alterar um registro com aguardando validação
					TAFMsgVldOp(oModel,"2")
					lRetorno := .F.

				Else

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Caso o registro nao tenha sido transmitido ainda eu gravo sua chave³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cChvRegAnt := C92->( C92_ID + C92_VERANT )

					If TafColumnPos( "C92_LOGOPE" )
						cLogOpeAnt := C92->C92_LOGOPE
					endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³No caso de um evento de Exclusao de um registro com status 'Excluido' deve-se³
					//³perguntar ao usuario se ele realmente deseja realizar a inclusao.            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If C8V->C8V_EVENTO == "E"
						If nOperation == MODEL_OPERATION_DELETE
							If Aviso( xValStrEr("000754"), xValStrEr("000755"), { xValStrEr("000756"), xValStrEr("000757") }, 1 ) == 2 //##"Registro Excluído" ##"O Evento de exclusão não foi transmitido. Deseja realmente exclui-lo ou manter o evento de exclusão para transmissão posterior ?" ##"Excuir" ##"Manter"
								cChvRegAnt := ""
							EndIf
						Else
							oModel:LoadValue( "MODEL_C92", "C92_EVENTO", "A" )
						EndIf
					EndIf

					//Executo a operacao escolhida
					If !Empty( cChvRegAnt )
						//Funcao responsavel por setar o Status do registro para Branco
						TAFAltStat( "C92", " " )

						If nOperation == MODEL_OPERATION_UPDATE .And. Findfunction("TAFAltMan")
							TAFAltMan( 4 , 'Save' , oModel, 'MODEL_C92', 'C92_LOGOPE' , '' , cLogOpeAnt )
						EndIf

						FwFormCommit( oModel )

						//Caso a operacao seja uma exclusao
						If nOperation == MODEL_OPERATION_DELETE
							TAFRastro( "C92", 1, cChvRegAnt, .T. , , IIF(Type("oBrw") == "U", Nil, oBrw) )
						EndIf
					EndIf
				EndIf

			Elseif TafIndexInDic("C92", '9', .T.)

				C92->( DbSetOrder( 9 ) )
				If C92->( MsSeek( xFilial( 'C92' ) + FwFldGet('C92_ID')+ 'E42' ) )

					If nOperation == MODEL_OPERATION_DELETE
						// Não é possível excluir um evento de exclusão já transmitido
						TAFMsgVldOp(oModel,"4")
						lRetorno := .F.
					EndIf

				EndIF

			EndIf
		EndIf

	End Transaction

Return( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF253Grv
@type			function
@description	Função de gravação para atender o registro S-1005 ( Tabela de Estabelecimentos, Obras ou Unidades de Órgãos Públicos ).
@author			Felipe C. Seolin
@since			26/09/2013
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
Function TAF253Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

	Local lLaySimplif  := taflayEsoc("S_01_00_00")
	Local cTagOper     := ""
	Local cCmpsNoUpd   := "|C92_FILIAL|C92_ID|C92_VERSAO|C92_DTINI|C92_DTFIN|C92_VERANT|C92_PROTUL|C92_PROTPN|C92_EVENTO|C92_STATUS|C92_ATIVO|C92_CDFPAS|"
	Local cCmpsRemSimp := Iif( lLaySimplif, "|C92_AJURAT|C92_REGPT|C92_CONTAP|C92_CTENTE|C92_CONPCD|", "")
	Local cCabec       := "/eSocial/evtTabEstab/infoEstab"
	Local cValChv      := ""
	Local cNewDtIni    := ""
	Local cNewDtFin    := ""
	Local cEnter       := Chr( 13 ) + Chr( 10 )
	Local cMensagem    := ""
	Local cInconMsg    := ""
	Local cCodEvent    := Posicione( "C8E", 2, xFilial( "C8E" ) + "S-" + cLayout, "C8E->C8E_ID" )
	Local cChave       := ""
	Local cPerIni      := ""
	Local cPerFin      := ""
	Local cPerIniOri   := ""
	Local cLogOpeAnt   := ""
	Local nIndex       := 2
	Local nIndIDVer    := 1
	Local nI           := 0
	Local nT0Z         := 1
	Local nSeqErrGrv   := 0
	Local nTamTpInsc   := TamSX3( "C92_TPINSC" )[1]
	Local nTamNrInsc   := TamSX3( "C92_NRINSC" )[1]
	Local lRet         := .F.
	Local aIncons      := {}
	Local aRules       := {}
	Local aChave       := {}
	Local aNewData     := {Nil, Nil}
	Local oModel       := Nil
	Local lNewValid    := .F.

	Private oDados     := Nil
	Private lVldModel  := .T. //Caso a chamada seja via integração, seto a variável de controle de validação como .T.

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

	// Variável que indica se o ambiente é válido para o eSocial
	If !TafVldAmb("2")
		cMensagem := STR0011 + cEnter // #"Dicionário Incompatível"
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

		//Verificar se o tpInsc foi informado para a chave ( Obrigatorio ser informado )
		cValChv := FTafGetVal( cCabec + cTagOper + '/ideEstab/tpInsc', 'C', .F., @aIncons, .F., '', '' )
		If !Empty( cValChv )
			Aadd( aChave, { "C", "C92_TPINSC", cValChv, .T.} )
			nIndex := 6 //C92_FILIAL+ C92_TPINSC+ C92_NRINSC+C92_ATIVO
			cChave += Padr(cValChv,nTamTpInsc)
		EndIf

		//Verificar se o nrInsc foi informado para a chave ( Obrigatorio ser informado )
		cValChv := FTafGetVal( cCabec + cTagOper + '/ideEstab/nrInsc', 'C', .F., @aIncons, .F., '', '' )
		If !Empty( cValChv )
			Aadd( aChave, { "C", "C92_NRINSC", cValChv, .T. } )
			nIndex := 6 //C92_FILIAL+ C92_TPINSC+ C92_NRINSC+C92_ATIVO
			cChave += Padr(cValChv,nTamNrInsc)
		EndIf

		//Verificar se o iniValid foi informado para a chave
		cValChv := FTafGetVal( cCabec + cTagOper + '/ideEstab/iniValid', 'C', .F., @aIncons, .F., '', '' )
		cValChv := TAF253Format("C92_DTINI", cValChv)
		If !Empty( cValChv )
			Aadd( aChave, { "C", "C92_DTINI", cValChv, .T. } )
			nIndex := 7 //C92_FILIAL+C92_TPINSC+C92_NRINSC+C92_DTINI+C92_ATIVO
			cPerIni 	:= cValChv
			cPerIniOri	:= cValChv
		EndIf

		//Verificar se a data final foi informado para a chave( Se nao informado sera adotado vazio )
		cValChv := FTafGetVal( cCabec + cTagOper + '/ideEstab/fimValid', 'C', .F., @aIncons, .F., '', '' )
		cValChv := TAF253Format("C92_DTFIN", cValChv)
		If !Empty( cValChv )
			Aadd( aChave, { "C", "C92_DTFIN", cValChv, .T.} )
			nIndex := 2 //C92_FILIAL+ C92_TPINSC+ C92_NRINSC+C92_DTINI+C92_DTFIN+C92_ATIVO
			cPerFin := cValChv
		EndIf

		If nOpc == 4
			If oDados:XPathHasNode( cCabec + cTagOper + "/novaValidade/iniValid", 'C', .F., @aIncons, .F., '', ''  )
				cNewDtIni 	:= FTafGetVal( cCabec + cTagOper + "/novaValidade/iniValid", 'C', .F., @aIncons, .F., '', '' )
				cNewDtIni 	:= TAF253Format("C92_DTINI", cNewDtIni)
				cPerIni		:= cNewDtIni
				aNewData[1] := cNewDtIni
				lNewValid	:= .T.
			EndIf

			If oDados:XPathHasNode( cCabec + cTagOper + "/novaValidade/fimValid", 'C', .F., @aIncons, .F., '', ''  )
				cNewDtFin 	:= 	FTafGetVal( cCabec + cTagOper + "/novaValidade/fimValid", 'C', .F., @aIncons, .F., '', '' )
				cNewDtFin 	:= 	TAF253Format("C92_DTFIN", cNewDtFin)
				cPerFin 	:=	cNewDtFin
				aNewData[2] := cNewDtFin
				lNewValid	:= .T.
			EndIf
		EndIf

		//Valida as regras da nova validade
		If Empty(aIncons)
			VldEvTab( "C92", 7, cChave, cPerIni, cPerFin, 2, nOpc, @aIncons, cPerIniOri,,, lNewValid )
		EndIf

		If Empty(aIncons)

			Begin Transaction

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Funcao para validar se a operacao desejada pode ser realizada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If FTafVldOpe( "C92", nIndex, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA253", cCmpsNoUpd, nIndIDVer, .T., aNewData,,,, cCmpsRemSimp )

					If TafColumnPos( "C92_LOGOPE" )
						cLogOpeAnt := C92->C92_LOGOPE
					endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
					//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nOpc <> 5

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Carrego array com os campos De/Para de gravacao das informacoes³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aRules := TAF253Rul( cTagOper, @cInconMsg, @nSeqErrGrv, cCodEvent, cOwner )

						If TAFColumnPos( "C92_XMLID" )
							oModel:LoadValue( "MODEL_C92", "C92_XMLID", cXmlID )
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Rodo o aRules para gravar as informacoes³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nI := 1 to Len( aRules )
							oModel:LoadValue( "MODEL_C92", aRules[ nI, 01 ], FTafGetVal( aRules[ nI, 02 ], aRules[nI, 03], aRules[nI, 04], @aIncons, .F., ,aRules[ nI, 01 ] ) )
						Next nI

						If Findfunction("TAFAltMan")
							if nOpc == 3
								TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_C92', 'C92_LOGOPE' , '1', '' )
							elseif nOpc == 4
								TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_C92', 'C92_LOGOPE' , '', cLogOpeAnt )
							EndIf
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Quando se trata de uma alteracao deleto todas as linhas do Grid³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nOpc == 4
							For nI := 1 to oModel:GetModel("MODEL_T0Z" ):Length()
								oModel:GetModel( "MODEL_T0Z" ):GoLine( nI )
								oModel:GetModel( "MODEL_T0Z" ):DeleteLine()
							Next nI
						EndIf

						While oDados:XPathHasNode( cCabec + cTagOper + "/dadosEstab/infoTrab/infoApr/infoEntEduc[" + cValToChar( nT0Z ) + "]")
							If (nT0Z > 1) .or. (nOpc == 4)
								// Necessario atribuir lValid para que permita o Addline
								oModel:GetModel( "MODEL_T0Z" ):lValid := .T.
								oModel:GetModel( "MODEL_T0Z" ):AddLine()
							EndIf
							//Grava as informacoes
							oModel:LoadValue( "MODEL_T0Z", "T0Z_CNPJEE", FTafGetVal(cCabec + cTagOper + "/dadosEstab/infoTrab/infoApr/infoEntEduc[" + cValToChar( nT0Z ) + "]/nrInsc", "C", .F., @aIncons, .F. ) )
							nT0Z ++
						EndDo
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Efetiva a operacao desejada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Empty(cInconMsg)	.And. Empty(aIncons)
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

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Zerando os arrays e os Objetos utilizados no processamento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aSize( aRules, 0 )
		aRules := Nil

		aSize( aChave, 0 )
		aChave := Nil

	EndIf

Return{ lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF253Rul

Regras para gravacao das informacoes do registro S-1005 do E-Social

@Param
cTagOper - Tag de indicacao da operacao

@Return
aRull - Regras para a gravacao das informacoes

@author Felipe C. Seolin
@since 26/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF253Rul( cTagOper, cInconMsg, nSeqErrGrv, cCodEvent, cOwner  )

	Local aRull
	Local cCabec

	Default cTagOper		:= ""
	Default cInconMsg		:= ""
	Default nSeqErrGrv	:= 0
	Default cCodEvent		:= ""
	Default cOwner		:= ""

	aRull   := {}
	cCabec  := "/eSocial/evtTabEstab/infoEstab"

	If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/ideEstab/tpInsc"  ))
		aAdd( aRull, { "C92_TPINSC", cCabec + cTagOper + "/ideEstab/tpInsc"      , "C", .F. } ) //tpInscricao
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/ideEstab/nrInsc" ))
		aAdd( aRull, { "C92_NRINSC", cCabec + cTagOper + "/ideEstab/nrInsc"      , "C", .F. } ) //nrInscricao
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/dadosEstab/cnaePrep" ))
		aAdd( aRull, { "C92_CNAE"  , cCabec + cTagOper + "/dadosEstab/cnaePrep", "C", .F. } ) //cnaePrep
	EndIf

	If TAFNT0421(lLaySimplif) .And. TafColumnPos("C92_CNPJRE")
		If TafXNode(oDados, cCodEvent, cOwner, cCabec + cTagOper + "/dadosEstab/cnpjResp")
			aAdd(aRull, {"C92_CNPJRE", cCabec + cTagOper + "/dadosEstab/cnpjResp", "C", .F.})
		EndIf
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/dadosEstab/aliqGilrat/aliqRat" ))
		aAdd( aRull, { "C92_ALQRAT", cCabec + cTagOper + "/dadosEstab/aliqGilrat/aliqRat", "N", .F. } ) //aliqRat
	EndIf

	If !lLaySimplif //Simplificação
		If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/dadosEstab/aliqGilrat/aliqRatAjust" ))
			aAdd( aRull, { "C92_AJURAT", cCabec + cTagOper + "/dadosEstab/aliqGilrat/aliqRatAjust", "N", .F. } ) //aliqRatAjustada
		EndIf
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/dadosEstab/aliqGilrat/fap" ))
		aAdd( aRull, { "C92_FAP", cCabec + cTagOper + "/dadosEstab/aliqGilrat/fap", "N", .F. } ) //fap
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,(	cCabec + cTagOper + "/dadosEstab/infoObra/indSubstPatrObra"	))
		aAdd( aRull, { "C92_SUBPAT", cCabec + cTagOper + "/dadosEstab/infoObra/indSubstPatrObra", "C", .F. } ) //indSubstPatronalObra
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/dadosEstab/infoCaepf/tpCaepf" ))
		aAdd( aRull, { "C92_TPCAEP", cCabec + cTagOper + "/dadosEstab/infoCaepf/tpCaepf", "C", .F. } ) //indSubstPatronalObra
	EndIf

	If !lLaySimplif //Simplificação
		If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/dadosEstab/infoTrab/regPt"))
			aAdd( aRull, { "C92_REGPT", cCabec + cTagOper + "/dadosEstab/infoTrab/regPt", "C", .F. } ) //indSubstPatronalObra 
		EndIf
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/dadosEstab/aliqGilrat/procAdmJudRat/tpProc" )) .or. TafXNode( oDados , cCodEvent, cOwner,( cCabec + cTagOper + "/dadosEstab/aliqGilrat/procAdmJudRat/nrProc" ))
		aAdd( aRull, { "C92_PRORAT", FGetIdInt( "tpProc", "nrProc", cCabec + cTagOper + "/dadosEstab/aliqGilrat/procAdmJudRat/tpProc", ;
			cCabec + cTagOper + "/dadosEstab/aliqGilrat/procAdmJudRat/nrProc",,,@cInconMsg, @nSeqErrGrv ), "C", .T. } ) //procAdmJudRat
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,(cCabec + cTagOper + "/dadosEstab/aliqGilrat/procAdmJudRat/codSusp"))
		aAdd( aRull, { "C92_CODSUR", cCabec + cTagOper + "/dadosEstab/aliqGilrat/procAdmJudRat/codSusp", "C", .F. } ) //codSusp
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/dadosEstab/aliqGilrat/procAdmJudFap/tpProc" )) .or. TafXNode( oDados , cCodEvent, cOwner,( cCabec + cTagOper + "/dadosEstab/aliqGilrat/procAdmJudFap/nrProc" ))
		aAdd( aRull, { "C92_PROFAP", FGetIdInt( "tpProc", "nrProc", cCabec + cTagOper + "/dadosEstab/aliqGilrat/procAdmJudFap/tpProc",;
			cCabec + cTagOper + "/dadosEstab/aliqGilrat/procAdmJudFap/nrProc",,,@cInconMsg, @nSeqErrGrv), "C", .T. } ) //procAdmJudFap
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,(cCabec + cTagOper + "/dadosEstab/aliqGilrat/procAdmJudFap/codSusp"))
		aAdd( aRull, { "C92_CODSUF", cCabec + cTagOper + "/dadosEstab/aliqGilrat/procAdmJudFap/codSusp", "C", .F. } ) //codSusp
	EndIf

	If !lLaySimplif //Simplificação
		If TafXNode( oDados, cCodEvent, cOwner,(cCabec + cTagOper + "/dadosEstab/infoTrab/infoApr/contApr"))
			aAdd( aRull, { "C92_CONTAP", cCabec + cTagOper + "/dadosEstab/infoTrab/infoApr/contApr", "C", .F. } )
		EndIf
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,(cCabec + cTagOper + "/dadosEstab/infoTrab/infoApr/nrProcJud"))
		aAdd( aRull, { "C92_PROCAP", FGetIdInt("nrProcJ",,cCabec + cTagOper + "/dadosEstab/infoTrab/infoApr/nrProcJud"), "C", .T. } )
	EndIf

	If !lLaySimplif //Simplificação
		If TafXNode( oDados, cCodEvent, cOwner,(cCabec + cTagOper + "/dadosEstab/infoTrab/infoApr/contEntEd"))
			aAdd( aRull, { "C92_CTENTE",xFunTrcSN(TAFExisTag(cCabec + cTagOper + "/dadosEstab/infoTrab/infoApr/contEntEd"),2), "C", .T. } )
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner,(cCabec + cTagOper + "/dadosEstab/infoTrab/infoPCD/contPCD"))	
			aAdd( aRull, { "C92_CONPCD", cCabec + cTagOper + "/dadosEstab/infoTrab/infoPCD/contPCD", "C", .F. } )
		EndIf
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,(cCabec + cTagOper + "/dadosEstab/infoTrab/infoPCD/nrProcJud"))
		aAdd( aRull, { "C92_PROCPD", FGetIdInt("nrProcJ",,cCabec + cTagOper + "/dadosEstab/infoTrab/infoPCD/nrProcJud"), "C", .T. } )
	EndIf

Return aRull

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF253Format

Formata os campos do registro S-1005 do E-Social

@Param
cCampo 	  - Campo que deve ser formatado
cValorXml - Valor a ser formatado

@Return
cFormatValue - Valor já formatado

@author Anderson Costa
@since 09/12/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF253Format(cCampo, cValorXml)

	Local cFormatValue
	Local cRet

	cFormatValue	:= ""
	cRet			:= ""

	If (cCampo == 'C92_DTINI' .OR. cCampo == 'C92_DTFIN')
		cFormatValue := StrTran( StrTran( cValorXml, "-", "" ), "/", "")
		cRet := Substr(cFormatValue, 5, 2) + Substr(cFormatValue, 1, 4)
	Else
		cRet := cValorXml
	EndIf

Return( cRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF253Xml
Funcao de geracao do XML para atender o registro S-1005
Quando a rotina for chamada o registro deve estar posicionado

@Param:
cAlias - Alias da Tabela
nRecno - Recno do Registro corrente
nOpc   - Operacao a ser realizada
lJob   - Informa se foi chamado por Job
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@Return:
cXml - Estrutura do Xml do Layout S-1005

@author Felipe C. Seolin
@since 24/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF253Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

	Local cXml		   	:= ""
	Local cLayout 	   	:= "1005"
	Local cReg    	   	:= "TabEstab"
	Local cEvento 	   	:= ""
	Local cDtIni  	   	:= ""
	Local cDtFin  	   	:= ""
	Local cId 		   	:= ""
	Local cVerAnt 	   	:= ""
	Local cTpProc	   	:= ""
	Local cCNPJMatriz  	:= ""
	Local cXmlInfoApr  	:= ""
	Local cXmlInfoPCD  	:= ""
	Local cXmlProcJRat	:= ""
	Local cXmlProcJFap	:= ""
	Local cContEndEnt  	:= ""
	Local cInfoEntEduc 	:= ""
	Local cNrinsc		:= ""
	Local nRecnoSM0    	:= SM0->(Recno())
	Local lXmlVLd	   	:= IIF(FindFunction('TafXmlVLD'),TafXmlVLD('TAF253XML'),.T.)

	Default lJob 		:= .F.
	Default cSeqXml 	:= ""

	DBSelectArea("C1E")
	C1E->( DBSetOrder(3) )
	If C1E->( MSSeek( xFilial("C1E") + PadR( SM0->M0_CODFIL, TamSX3( "C1E_FILTAF" )[1] ) + "1" ) )
		If C1E->C1E_MATRIZ == .T.
			cCNPJMatriz := SM0->M0_CGC
		EndIf
	EndIf

	dbSelectArea("C1G")
	C1G->( DBSetOrder(8) )

	dbSelectArea("T5L")
	T5L->( DBSetOrder(1) )
	If lXmlVLd
		If C92->C92_EVENTO $ "I|A"

			If C92->C92_EVENTO == "A"
				cEvento := "alteracao"

				cId := C92->C92_ID
				cVerAnt := C92->C92_VERANT

				BeginSql alias 'C92TEMP'
				SELECT C92.C92_DTINI,C92.C92_DTFIN
				FROM %table:C92% C92
				WHERE C92.C92_FILIAL= %xfilial:C92% AND
				C92.C92_ID = %exp:cId% AND C92.C92_VERSAO = %exp:cVerAnt% AND 
				C92.%notDel%
				EndSql

				//***********************************************************************************
				//Tratamento do formato da data (C92_DTINI e C92_DTFIN) para geração do XML de acordo
				//com a nova fomulação do eSocial. Formato: AAAA-MM
				//***********************************************************************************
				cDtIni := Substr(('C92TEMP')->C92_DTINI,3,4) +"-"+ Substr(('C92TEMP')->C92_DTINI,1,2)
				If ! Empty(('C92TEMP')->C92_DTFIN)
					cDtFin := Substr(('C92TEMP')->C92_DTFIN,3,4) +"-"+ Substr(('C92TEMP')->C92_DTFIN,1,2)
				EndIf
				//-----------

				('C92TEMP')->( DbCloseArea() )
			Else
				cEvento := "inclusao"

				//***********************************************************************************
				//Tratamento do formato da data (C92_DTINI e C92_DTFIN) para geração do XML de acordo
				//com a nova fomulação do eSocial. Formato: AAAA-MM
				//***********************************************************************************
				cDtIni := Substr(C92->C92_DTINI,3,4) +"-"+ Substr(C92->C92_DTINI,1,2)
				If ! Empty(C92->C92_DTFIN)
					cDtFin := Substr(C92->C92_DTFIN,3,4) +"-"+ Substr(C92->C92_DTFIN,1,2)
				EndIF
				//-----------

			EndIf

			cXml +=			"<infoEstab>"
			cXml +=				"<" + cEvento + ">"
			cXml +=					"<ideEstab>"
			cXml +=						xTafTag("tpInsc",C92->C92_TPINSC)
			
			If lLaySimplif

				cNrinsc := SUBSTR(C92->C92_NRINSC, 1, (Tamsx3("C92_NRINSC")[1])-1) 
				cXml +=						xTafTag("nrInsc",alltrim(cNrinsc))

			Else

				cXml +=						xTafTag("nrInsc",C92->C92_NRINSC)

			EndIf

			cXml +=						xTafTag("iniValid",cDtIni)

			If !Empty(cDtFin)
				cXml +=				xTafTag("fimValid",cDtFin)
			EndIf

			cXml +=					"</ideEstab>"
			cXml +=					"<dadosEstab>"
			cXml +=							xTafTag("cnaePrep",C92->C92_CNAE)

			If TAFNT0421(lLaySimplif) .And. TafColumnPos("C92_CNPJRE")
				cXml +=	xTafTag("cnpjResp", C92->C92_CNPJRE,, .T.)
			EndIf

			//Inicio TAG aliqGilrat
			If !Empty(C92->C92_PRORAT)

				cTpProc	:= Posicione("C1G",8,xFilial("C1G")+C92->C92_PRORAT+"1","C1G_TPPROC")

				//Inverto os códigos para atender o layout do eSocial
				If !empty( cTpProc )
					cTpProc := Iif(alltrim(cTpProc) == "1", "2", Iif(alltrim(cTpProc) == "2", "1", cTpProc) )
				EndIf

				cXmlProcJRat += "<procAdmJudRat>"
				cXmlProcJRat += 	xTafTag("tpProc",cTpProc)
				cXmlProcJRat +=		xTafTag("nrProc", Alltrim(Posicione("C1G",8,xFilial("C1G")+C92->C92_PRORAT+"1","C1G_NUMPRO")))
				cXmlProcJRat +=		xTafTag("codSusp",Alltrim(C92->C92_CODSUR),,.T.)
				cXmlProcJRat += "</procAdmJudRat>"

			EndIf

			If 	!Empty(C92->C92_PROFAP)

				cTpProc	:= Posicione("C1G",8,xFilial("C1G")+C92->C92_PROFAP+"1","C1G_TPPROC")

				//Inverto os códigos para atender o layout do eSocial
				If !empty( cTpProc )
					cTpProc := Iif(alltrim(cTpProc) == "1", "2", Iif(alltrim(cTpProc) == "2", "1", cTpProc) )
				EndIf

				cXmlProcJFap += "<procAdmJudFap>"
				cXmlProcJFap +=		xTafTag("tpProc",cTpProc)
				cXmlProcJFap +=		xTafTag("nrProc", Alltrim(Posicione("C1G",8,xFilial("C1G")+C92->C92_PROFAP+"1","C1G_NUMPRO")))
				cXmlProcJFap +=		xTafTag("codSusp", Alltrim(C92->C92_CODSUF),,.T.)
				cXmlProcJFap += "</procAdmJudFap>"

			EndIf

			If lLaySimplif

				xTafTagGroup(	"aliqGilrat";
								,{{ "aliqRat"		, C92->C92_ALQRAT,								, lLaySimplif };
								, { "fap"			, C92->C92_FAP	 , PesqPict("C92","C92_FAP")	,.T. 		  }};
								,@cXml;
								,{{ "procAdmJudRat", cXmlProcJRat, 0 };
								, { "procAdmJudFap", cXmlProcJFap, 0}})

			Else

				xTafTagGroup(	"aliqGilrat";
								,{{ "aliqRat"		, C92->C92_ALQRAT,								, lLaySimplif };
								, { "fap"			, C92->C92_FAP	 , PesqPict("C92","C92_FAP")	,.T. 		  };
								, { "aliqRatAjust"	, C92->C92_AJURAT, PesqPict("C92","C92_AJURAT")	,.T. 		  }};
								,@cXml;
								,{{ "procAdmJudRat", cXmlProcJRat, 0 };
								, { "procAdmJudFap", cXmlProcJFap, 0}})

			EndIf

			If !Empty(C92->C92_TPCAEP)
				cXml +=	"<infoCaepf>"
				cXml +=		xTafTag("tpCaepf",C92->C92_TPCAEP)
				cXml +=	"</infoCaepf>"
			EndIf

			If !Empty(C92->C92_SUBPAT)
				cXml +=	"<infoObra>"
				cXml +=		xTafTag("indSubstPatrObra",C92->C92_SUBPAT)
				cXml +=	"</infoObra>"
			EndIf

			T0Z->( DBSetOrder( 1 ) )
			If T0Z->( MsSeek ( C92->C92_FILIAL + C92->C92_ID + C92->C92_VERSAO ) )
				While T0Z->( !Eof() ) .and. C92->C92_FILIAL + C92->(C92_ID + C92->C92_VERSAO) == T0Z->(T0Z_FILIAL + T0Z_ID + T0Z_VERSAO)

					cInfoEntEduc += "<infoEntEduc>"
					cInfoEntEduc +=		xTafTag( "nrInsc", T0Z->T0Z_CNPJEE )
					cInfoEntEduc += "</infoEntEduc>"
					T0Z->( DBSkip() )

				EndDo
			EndIf

			If lLaySimplif

				xTafTagGroup(	"infoApr";
								, {{"nrProcJud", AllTrim(Posicione("C1G",8,xFilial("C1G")+C92->C92_PROCAP+"1","C1G_NUMPRO")), ,.T.}};
								, @cXmlInfoApr;
								, {{"infoEntEduc",cInfoEntEduc,0}};
								,;
								, .T. )

				If Alltrim(cCNPJMatriz) == Alltrim(C92->C92_NRINSC)
					If !Empty(C92->C92_PROCPD)
						cXmlInfoPCD +=	"<infoPCD>"
						cXmlInfoPCD += 		xTafTag("nrProcJud",AllTrim(Posicione("C1G",8,xFilial("C1G")+C92->C92_PROCPD+"1","C1G_NUMPRO")),,.T.)
						cXmlInfoPCD +=	"</infoPCD>"
					EndIf
				EndIf

				xTafTagGroup("infoTrab";
							, ;
							, @cXml;
							, {{"infoApr",cXmlInfoApr,0};
							,  {"infoPCD",cXmlInfoPCD,0}};
							,.F.;
							,.T.)

			Else

				If C92->C92_CONTAP <> '0' .And. !Empty(C92->C92_CTENTE)
					cContEndEnt := xFunTrcSN(C92->C92_CTENTE,1)
				EndIf

				xTafTagGroup("infoApr";
					, {{"contApr"  , C92->C92_CONTAP, ,.F.};
					,  {"nrProcJud", AllTrim(Posicione("C1G",8,xFilial("C1G")+C92->C92_PROCAP+"1","C1G_NUMPRO")), ,.T.};
					,  {"contEntEd", cContEndEnt    , ,.T.}};
					, @cXmlInfoApr;
					, {{"infoEntEduc",cInfoEntEduc,0}};
					,;
					, .T.)

				If Alltrim(cCNPJMatriz) == Alltrim(C92->C92_NRINSC)
					If !Empty(C92->C92_CONPCD) .OR. !Empty(C92->C92_PROCPD)
						cXmlInfoPCD +=	"<infoPCD>"
						cXmlInfoPCD +=		xTafTag("contPCD",C92->C92_CONPCD)
						cXmlInfoPCD += 		xTafTag("nrProcJud",AllTrim(Posicione("C1G",8,xFilial("C1G")+C92->C92_PROCPD+"1","C1G_NUMPRO")),,.T.)
						cXmlInfoPCD +=	"</infoPCD>"
					EndIf
				EndIf

				xTafTagGroup("infoTrab"; 
					, {{"regPt",C92->C92_REGPT, ,.T.}};
					, @cXml;
					, {{"infoApr",cXmlInfoApr,0},{"infoPCD",cXmlInfoPCD,0}};
					, ;
					, .T.)

			EndIf

			cXml +=					"</dadosEstab>"

			If C92->C92_EVENTO == "A"
				If TafAtDtVld("C92", C92->C92_ID, C92->C92_DTINI, C92->C92_DTFIN, C92->C92_VERANT, .T.)
					cXml +=			"<novaValidade>"
					cXml +=				TafGetDtTab(C92->C92_DTINI,C92->C92_DTFIN)
					cXml +=			"</novaValidade>"
				EndIf
			EndIf

			cXml +=				"</" + cEvento + ">"
			cXml +=			"</infoEstab>"

		ElseIf C92->C92_EVENTO == "E"
			cXml +=			"<infoEstab>"
			cXml +=				"<exclusao>"
			cXml +=					"<ideEstab>"
			cXml +=						xTafTag("tpInsc",C92->C92_TPINSC)
			cXml +=						xTafTag("nrInsc",C92->C92_NRINSC)
			cXml +=						TafGetDtTab(C92->C92_DTINI,C92->C92_DTFIN)
			cXml +=					"</ideEstab>"
			cXml +=				"</exclusao>"
			cXml +=			"</infoEstab>"
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estrutura do cabecalho³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nRecnoSM0 > 0
			SM0->(dbGoto(nRecnoSM0))
		endif
		cXml := xTafCabXml(cXml,"C92",cLayout,cReg,,cSeqXml)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa gravacao do registro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lJob
			xTafGerXml(cXml,cLayout)
		EndIf
	EndIF
Return(cXml)


//-------------------------------------------------------------------
/*/{Protheus.doc} VldChvEst           
Função que chama a validação das regras inclusão e alteração de eventos de tabelas 
do e-social (VldEvTab), para a rotina de Estabelecimentos, Obras ou Unidades
de Órgãos Públicos

@Param
cCampo		- Campo posicionado na tela

@author Denis R. de Oliveira
@since 28/12/2017
@version 1.0

/*/                        	
//-------------------------------------------------------------------
Function VldChvEst( cCampo )

	Local lRet

	Default cCampo := ""

	lRet := .T.

	If cCampo == "C92_TPINSC"
		lRet	:= VldEvTab("C92",2,M->C92_TPINSC+FWFLDGET("C92_NRINSC"),FWFLDGET("C92_DTINI"),FWFLDGET("C92_DTFIN"),1)
	ElseIf cCampo == "C92_NRINSC"
		lRet 	:= VldEvTab("C92",2,FWFLDGET("C92_TPINSC")+M->C92_NRINSC,FWFLDGET("C92_DTINI"),FWFLDGET("C92_DTFIN"),1)
		If lRet .And. FWFLDGET("C92_TPINSC") $"1|2"
			If FWFLDGET("C92_TPINSC") == '1'		//CNPJ
				lRet := XFUNVldPJF( "" ,  2, .F. )
			ElseIf FWFLDGET("C92_TPINSC") == '2'	//CPF
				lRet := XFUNVldPJF( "" ,  1, .F. )
			EndIf
		EndIf
	ElseIf cCampo == "C92_DTINI"
		lRet	:= VldEvTab("C92",2,FWFLDGET("C92_TPINSC")+FWFLDGET("C92_NRINSC"),M->C92_DTINI,FWFLDGET("C92_DTFIN"),1)
	ElseIf cCampo == "C92_DTFIN"
		lRet	:= VldEvTab("C92",2,FWFLDGET("C92_TPINSC")+FWFLDGET("C92_NRINSC"),FWFLDGET("C92_DTINI"),M->C92_DTFIN,1)
	EndIf

Return lRet
