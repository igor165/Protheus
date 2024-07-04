#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA246.CH'

Static 	lLaySimplif := taflayEsoc("S_01_00_00")

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA246
Tabela de Lotações - S-1020

@author Leandro Prado
@since 23/08/2013
@version 1.0
/*/ 
//------------------------------------------------------------------
Function TAFA246()

	Local cTitulo
	Local cMensagem

	cTitulo		:= ""
	cMensagem	:= ""

	Private oBrw := FWmBrowse():New()

	// Função que indica se o ambiente é válido para o eSocial 2.3
	If TafAtualizado()

		oBrw:SetDescription( STR0001 ) //Tabela de Lotações
		oBrw:SetAlias( 'C99')
		oBrw:SetMenuDef( 'TAFA246' )
		oBrw:SetFilterDefault( "C99_ATIVO == '1' .Or. (C99_EVENTO == 'E' .And. C99_STATUS = '4' .And. C99_ATIVO = '2')" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )

		oBrw:AddLegend( "C99_EVENTO == 'I' ", "GREEN" , STR0006 ) //"Registro Incluído"
		oBrw:AddLegend( "C99_EVENTO == 'A' ", "YELLOW", STR0007 ) //"Registro Alterado"
		oBrw:AddLegend( "C99_EVENTO == 'E' .And. C99_STATUS <> '4' ", "RED"   , STR0008 ) //"Registro excluído não transmitido"
		oBrw:AddLegend( "C99_EVENTO == 'E' .And. C99_STATUS == '4' .And. C99_ATIVO = '2' ", "BLACK"   , STR0013 ) //"Registro excluído transmitido"

		oBrw:Activate()

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Leandro Prado
@since 23/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()

	Local aFuncao
	Local aRotina

	aFuncao := {}
	aRotina := {}

	If FindFunction('TafxmlRet')
		Aadd( aFuncao, { "" , "TafxmlRet('TAF246Xml','1020','C99')" , "1" } )
	Else
		Aadd( aFuncao, { "" , "TAF246Xml" , "1" } )
	EndIf

	Aadd( aFuncao, { "" , "xFunHisAlt( 'C99', 'TAFA246',,,,'TAF246XML','1020'  )" , "3" } )
	Aadd( aFuncao, { "" , "TAFXmlLote( 'C99', 'S-1020' , 'evtTabLotacao' , 'TAF246Xml',, oBrw )" , "5" } )
	Aadd( aFuncao, { "" , "xFunAltRec( 'C99' )" , "10" } )

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If lMenuDif
		ADD OPTION aRotina Title STR0009 Action 'VIEWDEF.TAFA246' OPERATION 2 ACCESS 0 //"Visualizar"
	Else
		aRotina	:=	xFunMnuTAF( "TAFA246" , , aFuncao)
	EndIf

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Leandro Prado
@since 23/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------     
Static Function ModelDef()

	Local oStruC99
	Local oStruT03
	Local oModel

	oStruC99	:= FWFormStruct( 1, 'C99' )// Cria a estrutura a ser usada no Modelo de Dados
	oStruT03	:= FWFormStruct( 1, 'T03' )// Cria a estrutura a ser usada no Modelo de Dados
	oModel		:= MPFormModel():New('TAFA246',,,{|oModel| SaveModel(oModel)} )

	If !lLaySimplif
		oStruC99:RemoveField( "C99_ALQRAT" )
		oStruC99:RemoveField( "C99_FAP" )
	EndIf

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruC99:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	EndIf

	// Adiciona ao modelo um componente de formulário
	oModel:AddFields( 'MODEL_C99', /*cOwner*/, oStruC99)
	oModel:AddGrid("MODEL_T03","MODEL_C99",oStruT03)

	oModel:GetModel("MODEL_T03"):SetOptional(.T.)

	oModel:GetModel("MODEL_T03"):SetUniqueLine({"T03_FPAS","T03_IDPROC", "T03_IDSUSP"})

	oModel:SetRelation("MODEL_T03",{ {"T03_FILIAL","xFilial('T03')"}, {"T03_ID","C99_ID"}, {"T03_VERSAO","C99_VERSAO"} },T03->(IndexKey(1)) )

	oModel:GetModel( 'MODEL_C99' ):SetPrimaryKey( { 'C99_FILIAL', 'C99_CODIGO' , 'C99_DTINI', 'C99_DTFIN' } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Leandro Prado
@since 23/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel
	Local oStruC99
	Local oStruT03
	Local oView

	oModel		:= FWLoadModel( 'TAFA246' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
	oStruC99	:= FWFormStruct( 2, 'C99' )// Cria a estrutura a ser usada na View
	oStruT03	:= FWFormStruct( 2, 'T03' )// Cria a estrutura a ser usada na View
	oView		:= FWFormView():New()

	oStruC99 :RemoveField("C99_DESCRI")

	If !lLaySimplif

		oStruC99 :RemoveField("C99_ALQRAT")
		oStruC99 :RemoveField("C99_FAP")

	EndIf

	oView:SetModel( oModel )

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruC99,"C99")
	EndIf

	oView:AddField( 'VIEW_C99', oStruC99, 'MODEL_C99' )
	oView:EnableTitleView( 'VIEW_C99',  STR0001 ) //Tabela de Lotações

	oView:AddGrid("VIEW_T03",oStruT03,"MODEL_T03")
	oView:EnableTitleView("VIEW_T03",STR0010) //"Processos Judiciais Terceiros"

	oView:CreateHorizontalBox( 'FIELDSC99',50 )
	oView:CreateHorizontalBox("T03",50)

	oView:SetOwnerView('VIEW_C99', 'FIELDSC99' )
	oView:SetOwnerView("VIEW_T03","T03")

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If !lMenuDif

		oStruT03:RemoveField('T03_IDSUSP')
		xFunRmFStr(@oStruC99, 'C99')

	EndIf

	If TafColumnPos( "C99_LOGOPE" )
		oStruC99:RemoveField( "C99_LOGOPE")
	EndIf

Return oView
///-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@Author Vitor Henrique Ferreira
@Since 04/10/2013
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

	Local cVerAnt
	Local cProtocolo
	Local cVersao
	Local cEvento
	Local cChvRegAnt
	Local cLogOpe
	Local cLogOpeAnt
	Local nOperation
	Local nC99
	Local nT03
	Local aGrava
	Local aGravaT03
	Local oModelC99
	Local oModelT03
	Local lRetorno

	cVerAnt		:= ""
	cProtocolo	:= ""
	cVersao		:= ""
	cEvento		:= ""
	cChvRegAnt	:= ""
	cLogOpe    	:= ""
	cLogOpeAnt 	:= ""
	nOperation	:= oModel:GetOperation()

	nC99		:= 0
	nT03		:= 0

	aGrava		:= {}
	aGravaT03	:= {}

	oModelC99	:= Nil
	oModelT03	:= Nil

	lRetorno	:= .T.

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT

			TafAjustID( "C99", oModel)

			oModel:LoadValue( 'MODEL_C99', 'C99_VERSAO', xFunGetVer() )

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_C99', 'C99_LOGOPE' , '2', '' )
			endif

			FwFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			C99->( DbSetOrder( 4 ) )
			If C99->( MsSeek( xFilial( 'C99' ) + FwFldGet('C99_ID')+ '1' ) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o registro ja foi transmitido³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If C99->C99_STATUS == "4"

					oModelC99 := oModel:GetModel( 'MODEL_C99' )
					oModelT03 := oModel:GetModel( 'MODEL_T03' )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao anterior do registro para gravacao do rastro³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVerAnt    	:= oModelC99:GetValue( "C99_VERSAO" )
					cProtocolo	:= oModelC99:GetValue( "C99_PROTUL" )
					cEvento	 	:= oModelC99:GetValue( "C99_EVENTO" )

					If TafColumnPos( "C99_LOGOPE" )
						cLogOpeAnt := oModelC99:GetValue( "C99_LOGOPE" )
					endif

					If nOperation == MODEL_OPERATION_DELETE .And. cEvento == "E"
						// Não é possível excluir um evento de exclusão já transmitido
						TAFMsgVldOp(oModel,"4")
						lRetorno := .F.
					Else

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Neste momento eu gravo as informacoes que foram carregadas na tela³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nC99 := 1 to Len( oModelC99:aDataModel[ 1 ] )
							aAdd( aGrava, { oModelC99:aDataModel[ 1, nC99, 1 ], oModelC99:aDataModel[ 1, nC99, 2 ] } )
						Next nC99

						If !(oModel:GetModel('MODEL_T03'):IsEmpty() )
							For nT03 := 1 to oModel:GetModel( "MODEL_T03" ):Length()
								oModel:GetModel( "MODEL_T03" ):GoLine( nT03 )
								If !oModel:GetModel( "MODEL_T03" ):IsDeleted()
									aAdd( aGravaT03, {	oModelT03:GetValue( "T03_FPAS" ),;
										oModelT03:GetValue( "T03_IDPROC" ),;
										oModelT03:GetValue( "T03_IDSUSP" ) } )
								EndIf
							Next nT03
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Seto o campo como Inativo e gravo a versao do novo registro³
						//³no registro anterior                                       ³
						//|                                                           |
						//|ATENCAO -> A alteracao destes campos deve sempre estar     |
						//|abaixo do Loop do For, pois devem substituir as informacoes|
						//|que foram armazenadas no Loop acima                        |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						FAltRegAnt( 'C99', '2' ,.F.,FwFldGet("C99_DTFIN"),FwFldGet("C99_DTINI"),C99->C99_DTINI )

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
						For nC99 := 1 to Len( aGrava )
							oModel:LoadValue( "MODEL_C99", aGrava[ nC99, 1 ], aGrava[ nC99, 2 ] )
						Next nC99

						//Necessário Abaixo do For Nao Retirar
						If Findfunction("TAFAltMan")
							TAFAltMan( 4 , 'Save' , oModel, 'MODEL_C99', 'C99_LOGOPE' , '' , cLogOpeAnt )
						endif

						For nT03 := 1 to Len( aGravaT03 )
							If nT03 > 1
								oModel:GetModel( "MODEL_T03" ):AddLine()
							EndIf

							oModel:LoadValue( "MODEL_T03", "T03_FPAS", aGravaT03[nT03][1] )
							oModel:LoadValue( "MODEL_T03", "T03_IDPROC", aGravaT03[nT03][2] )
							oModel:LoadValue( "MODEL_T03", "T03_IDSUSP", aGravaT03[nT03][3] )
						Next nT03

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Busco a versao que sera gravada³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cVersao := xFunGetVer()

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//|ATENCAO -> A alteracao destes campos deve sempre estar     |
						//|abaixo do Loop do For, pois devem substituir as informacoes|
						//|que foram armazenadas no Loop acima                        |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						oModel:LoadValue( 'MODEL_C99', 'C99_VERSAO', cVersao )
						oModel:LoadValue( 'MODEL_C99', 'C99_VERANT', cVerAnt )
						oModel:LoadValue( 'MODEL_C99', 'C99_PROTPN', cProtocolo )
						oModel:LoadValue( 'MODEL_C99', 'C99_PROTUL', "" )
						// Tratamento para limpar o ID unico do xml
						cAliasPai := "C99"
						If TAFColumnPos( cAliasPai+"_XMLID" )
							oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
						EndIf

						If nOperation == MODEL_OPERATION_DELETE
							oModel:LoadValue( 'MODEL_C99', 'C99_EVENTO', "E" )
						ElseIf cEvento == "E"
							oModel:LoadValue( 'MODEL_C99', 'C99_EVENTO', "I" )
						Else
							oModel:LoadValue( 'MODEL_C99', 'C99_EVENTO', "A" )
						EndIf
						FwFormCommit( oModel )
					EndIF

				Elseif C99->C99_STATUS == "2"
					//Não é possível alterar um registro com aguardando validação
					TAFMsgVldOp(oModel,"2")
					lRetorno := .F.

				Else

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Caso o registro nao tenha sido transmitido ainda, gravo sua chave³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cChvRegAnt := C99->( C99_ID + C99_VERANT )

					If TafColumnPos( "C99_LOGOPE" )
						cLogOpeAnt := C99->C99_LOGOPE
					endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³No caso de um evento de Exclusao de um registro com status 'Excluido' deve-se³
					//³perguntar ao usuario se ele realmente deseja realizar a inclusao.            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If C99->C99_EVENTO == "E"
						If nOperation == MODEL_OPERATION_DELETE
							If Aviso( xValStrEr("000754"), xValStrEr("000755"), { xValStrEr("000756"), xValStrEr("000757") }, 1 ) == 2 //##"Registro Excluído" ##"O Evento de exclusão não foi transmitido. Deseja realmente exclui-lo ou manter o evento de exclusão para transmissão posterior ?" ##"Excuir" ##"Manter"
								cChvRegAnt := ""
							EndIf
						Else
							oModel:LoadValue( "MODEL_C99", "C99_EVENTO", "A" )
						EndIf
					EndIf

					//Executo a operacao escolhida
					If !Empty( cChvRegAnt )
						//Funcao responsavel por setar o Status do registro para Branco
						TAFAltStat( "C99", " " )

						If nOperation == MODEL_OPERATION_UPDATE .And. Findfunction("TAFAltMan")
							TAFAltMan( 4 , 'Save' , oModel, 'MODEL_C99', 'C99_LOGOPE' , '' , cLogOpeAnt )
						endif

						FwFormCommit( oModel )

						//Caso a operacao seja uma exclusao
						If nOperation == MODEL_OPERATION_DELETE
							//Funcao para setar o registro anterior como Ativo
							TAFRastro( "C99", 1, cChvRegAnt, .T. , , IIF(Type("oBrw") == "U", Nil, oBrw) )
						EndIf
					EndIf
				EndIf

			ElseIf TafIndexInDic("C99", 8, .T.)

				C99->( DbSetOrder( 8 ) )
				If C99->( MsSeek( xFilial( 'C99' ) + FwFldGet('C99_ID')+ 'E42' ) )

					If nOperation == MODEL_OPERATION_DELETE
						// Não é possível excluir um evento de exclusão já transmitido
						TAFMsgVldOp(oModel,"4")
						lRetorno := .F.
					EndIf

				EndIF

			EndIf

		EndIf
	End Transaction

Return ( lRetorno )
//-------------------------------------------------------------------
/*/{Protheus.doc} TAF246Xml
Funcao de geracao do XML para atender o registro S-1020
Quando a rotina for chamada o registro deve estar posicionado

@Param:
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@Return:
cXml - Estrutura do Xml do Layout S-1000

@author Leandro Prado
@since 20/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF246Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

	Local cXml
	Local cLayout
	Local cEvento
	Local cReg
	Local cDtIni
	Local cDtFin
	Local cRecno
	Local cId
	Local cVerAnt
	Local cCodSusp
	Local lFindProc
	Local nRecnoSM0 := SM0->(Recno())
	Local lXmlVLd	:= IIF(FindFunction('TafXmlVLD'),TafXmlVLD('TAF246XML'),.T.)

	Default cSeqXml := ""

	cXml      := ""
	cLayout   := "1020"
	cEvento   := ""
	cReg      := "TabLotacao"
	cDtIni    := ""
	cDtFin    := ""
	cRecno    := ""
	cId       := ""
	cVerAnt   := ""
	cCodSusp  := ""
	lFindProc := .F.

	dbSelectArea("C1G")
	C1G->( DBSetOrder(8) )

	dbSelectArea("T5L")
	T5L->( DBSetOrder(1) )

	If lXmlVLd

		If C99->C99_EVENTO $ "I|A"

			If C99->C99_EVENTO == "A"

				cEvento := "alteracao"

				cId := C99->C99_ID
				cVerAnt := C99->C99_VERANT

				BeginSql alias 'C99TEMP'
				SELECT C99.C99_DTINI,C99.C99_DTFIN
				FROM %table:C99% C99
				WHERE C99.C99_FILIAL= %xfilial:C99% AND
				C99.C99_ID = %exp:cId% AND C99.C99_VERSAO = %exp:cVerAnt% AND 
				C99.%notDel%
				EndSql
				cDtIni := ('C99TEMP')->C99_DTINI
				cDtFIN := ('C99TEMP')->C99_DTFIN

				('C99TEMP')->( DbCloseArea() )

			Else
				cEvento := "inclusao"
				cDtIni  := C99->C99_DTINI
				cDtFin	:= C99->C99_DTFIN
			EndIf

			cXml +=			"<infoLotacao>"
			cXml +=				"<" + cEvento + ">"
			cXml +=					"<ideLotacao>"
			cXml +=						xTafTag("codLotacao",C99->C99_CODIGO)
			cXml +=	 					TafGetDtTab(cDtIni,cDtFin)
			cXml +=					"</ideLotacao>"
			cXml +=					"<dadosLotacao>"
			cXml +=						xTafTag("tpLotacao",POSICIONE("C8F",1, xFilial("C8F")+C99->C99_TPLOT ,"C8F_CODIGO") )
			cXml +=						xTafTag("tpInsc",C99->C99_TPINES,,.T.)
			cXml +=						xTafTag("nrInsc",alltrim(SUBSTR(C99->C99_NRINES, 1,14)),,.T.)
			cXml +=						"<fpasLotacao>"
			cXml +=							xTafTag("fpas"    ,POSICIONE("C8A",1, xFilial("C8A")+C99->C99_FPAS   ,"C8A_CDFPAS"))
			cXml +=							xTafTag("codTercs",POSICIONE("C8A",1, xFilial("C8A")+C99->C99_CODTER ,"C8A_CODTER"))
			cXml +=							xTafTag("codTercsSusp",C99->C99_TERSUS,,.T.)

			("T03")->( DbSetOrder( 1 ) )
			If ("T03")->( DbSeek ( xFilial("T03")+C99->C99_ID+C99->C99_VERSAO) )

				cXml +=  "<infoProcJudTerceiros>"

				dbSelectArea("C1G")
				C1G->(dbSetOrder(8))

				While T03->( !Eof()) .And. (xFilial("T03")+T03->T03_ID+T03->T03_VERSAO == xFilial("C99")+C99->C99_ID+C99->C99_VERSAO)

					lFindProc := C1G->(MsSeek(xFilial("C1G") + T03->T03_IDPROC + "1"))
					cCodSusp    := Posicione("T5L",1,xFilial("T5L")+T03->T03_IDSUSP,"T5L_CODSUS")

					cXml += "<procJudTerceiro>"
					cXml +=	xTafTag("codTerc"  , POSICIONE("C8A",1, xFilial("C8A")+T03->T03_FPAS ,"C8A_CODTER"))
					cXml +=	xTafTag("nrProcJud", iif( lFindProc, C1G->C1G_NUMPRO, '' ) )
					cXml +=	xTafTag("codSusp", Alltrim(cCodSusp),,.T.)
					cXml += "</procJudTerceiro>"

					T03->( dbSkip() )
				EndDo

				cXml += "</infoProcJudTerceiros>"

			EndIf

			cXml += "</fpasLotacao>"

			If !lLaySimplif

				xTafTagGroup("infoEmprParcial"	,{{"tpInscContrat"	,C99->C99_TPINCT	,,.F.};
					, {"nrInscContrat"	,C99->C99_NRINCT	,,.F.};
					, {"tpInscProp"		,C99->C99_TPINPR	,,.F.};
					, {"nrInscProp"		,C99->C99_NRINPR	,,.F.}};
					, @cXml)

			Else

				xTafTagGroup("infoEmprParcial"	,{{"tpInscContrat"	,C99->C99_TPINCT	,,.F.};
					, {"nrInscContrat"	,C99->C99_NRINCT	,,.F.};
					, {"tpInscProp"		,C99->C99_TPINPR	,,.T.};
					, {"nrInscProp"		,C99->C99_NRINPR	,,.T.}};
					, @cXml)

				xTafTagGroup("dadosOpPort";
					,{{"aliqRat", C99->C99_ALQRAT	,,.F.};
					, {"fap"	, C99->C99_FAP		,,.F.}};
					,@cXml)

			EndIf

			cXml += "</dadosLotacao>"

			If C99->C99_EVENTO == "A"
				If TAFAtDtVld( "C99", C99->C99_ID, C99->C99_DTINI, C99->C99_DTFIN, C99->C99_VERANT, .T. )
					cXml +=	"<novaValidade>"
					cXml +=		TAFGetDtTab( C99->C99_DTINI, C99->C99_DTFIN )
					cXml +=	"</novaValidade>"
				EndIf
			EndIf

			cXml += "</" + cEvento + ">"
			cXml += "</infoLotacao>"

		ElseIf C99->C99_EVENTO == "E"
			cXml += "<infoLotacao>"
			cXml +=		"<exclusao>"
			cXml +=			"<ideLotacao>"
			cXml +=				xTafTag("codLotacao",C99->C99_CODIGO)
			cXml += 			TafGetDtTab(C99->C99_DTINI,C99->C99_DTFIN)
			cXml +=			"</ideLotacao>"
			cXml +=		"</exclusao>"
			cXml += "</infoLotacao>"

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estrutura do cabecalho³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nRecnoSM0 > 0
			SM0->(dbGoto(nRecnoSM0))
		Endif

		cXml := xTafCabXml(cXml,"C99", cLayout,cReg, ,cSeqXml)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa gravacao do registro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lJob
			xTafGerXml(cXml,cLayout)
		EndIf
	EndIF

Return(cXml)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF246Grv
@type			function
@description	Função de gravação para atender o registro S-1020.
@author			Leandro Prado
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
Function TAF246Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

	Local cCmpsNoUpd   := "|C99_FILIAL|C99_ID|C99_VERSAO|C99_DTINI|C99_DTFIN|C99_VERANT|C99_PROTUL|C99_PROTPN|C99_EVENTO|C99_STATUS|C99_ATIVO|C99_DESCRI|C99_TPLOGR|C99_DESLOG|C99_NUMLOG|C99_COMLOG|C99_BAIRRO|C99_CEP|C99_UF|C99_DUF|C99_CODMUN|C99_DCODMU|"
	Local cCabec       := "/eSocial/evtTabLotacao/infoLotacao"
	Local cValChv      := ""
	Local cNewDtIni    := ""
	Local cNewDtFin    := ""
	Local cEnter       := Chr( 13 ) + Chr( 10 )
	Local cMensagem    := ""
	Local cInconMsg    := ""
	Local cIdProc      := ""
	Local cT03Path     := ""
	Local cCodEvent    := Posicione( "C8E", 2, xFilial( "C8E" ) + "S-" + cLayout, "C8E->C8E_ID" )
	Local cChave       := ""
	Local cPerIni      := ""
	Local cPerFin      := ""
	Local cPerIniOri   := ""
	Local cLogOpeAnt   := ""
	Local nIndChv      := 2
	Local nIndIDVer    := 1
	Local nlI          := 0
	Local nlJ          := 0
	Local nSeqErrGrv   := 0
	Local nTamCod      := TamSX3( "C99_CODIGO" )[1]
	Local lRet         := .F.
	Local aIncons      := {}
	Local aRules       := {}
	Local aChave       := {}
	Local aNewData     :={Nil, Nil}
	Local oModel       := Nil
	Local lNewValid    := .F.

	Private lVldModel  := .T. //Caso a chamada seja via integração, seto a variável de controle de validação como .T.
	Private oDados     := Nil

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

		If !lLaySimplif
			cCmpsNoUpd += "C99_ALQRAT|C99_FAP|"
		EndIf
		//Verificar se o codigo foi informado para a chave ( Obrigatorio ser informado )
		cValChv := FTafGetVal( cCabec + cTagOper + "/ideLotacao/codLotacao", 'C', .F., @aIncons, .F., '', '' )
		If !Empty( cValChv )
			Aadd( aChave, { "C", "C99_CODIGO", cValChv, .T.} )
			nIndChv := 5
			cChave		:= Padr(cValChv,nTamCod)
		EndIf

		//Verificar se a data inicial foi informado para a chave( Se nao informado sera adotada a database internamente )
		cValChv := FTafGetVal( cCabec + cTagOper + "/ideLotacao/iniValid", 'C', .F., @aIncons, .F., '', '' )
		cValChv := StrTran( cValChv, "-", "" )
		cValChv := Substr(cValChv, 5, 2) + Substr(cValChv, 1,4)
		If !Empty( cValChv )
			Aadd( aChave, { "C", "C99_DTINI", cValChv, .T. } )
			nIndChv := 6
			cPerIni	:= cValChv
			cPerIniOri	:= cValChv
		EndIf

		//Verificar se a data final foi informado para a chave( Se nao informado sera adotado vazio )
		cValChv := FTafGetVal( cCabec + cTagOper + "/ideLotacao/fimValid", 'C', .F., @aIncons, .F., '', '' )
		cValChv := StrTran( cValChv, "-", "" )
		cValChv := Substr(cValChv, 5, 2) + Substr(cValChv, 1,4)
		If !Empty( cValChv )
			Aadd( aChave, { "C", "C99_DTFIN", cValChv, .T.} )
			nIndChv := 2
			cPerFin	:= cValChv
		EndIf

		If nOpc == 4
			If oDados:XPathHasNode( cCabec + cTagOper + "/novaValidade/iniValid", 'C', .F., @aIncons, .F., '', ''  )
				cNewDtIni 	:= FTafGetVal( cCabec + cTagOper + "/novaValidade/iniValid", 'C', .F., @aIncons, .F., '', '' )
				aNewData[1] := SubStr( cNewDtIni, 6, 2 ) + SubStr( cNewDtIni, 1, 4 )
				cPerIni		:= cNewDtIni
				lNewValid	:= .T.
			EndIf

			If oDados:XPathHasNode( cCabec + cTagOper + "/novaValidade/fimValid", 'C', .F., @aIncons, .F., '', ''  )
				cNewDtFin 	:= FTafGetVal( cCabec + cTagOper + "/novaValidade/fimValid", 'C', .F., @aIncons, .F., '', '' )
				aNewData[2] := SubStr( cNewDtFin, 6, 2 ) + SubStr( cNewDtFin, 1, 4 )
				cPerFin		:= cNewDtFin
				lNewValid	:= .T.
			EndIf
		EndIf

		//Valida as regras da nova validade
		If Empty(aIncons)
			VldEvTab( "C99", 6, cChave, cPerIni, cPerFin, 2, nOpc, @aIncons, cPerIniOri,,, lNewValid )
		EndIf

		If Empty(aIncons)
			Begin Transaction

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Funcao para validar se a operacao desejada pode ser realizada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If FTafVldOpe( "C99", nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA246", cCmpsNoUpd, nIndIDVer, .T., aNewData )

					If TafColumnPos( "C99_LOGOPE" )
						cLogOpeAnt := C99->C99_LOGOPE
					endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
					//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nOpc <> 5

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Carrego array com os campos De/Para de gravacao das informacoes³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aRules := TAF246Rul( cTagOper, @cInconMsg, @nSeqErrGrv, cCodEvent, cOwner )

						oModel:LoadValue( "MODEL_C99", "C99_FILIAL", C99->C99_FILIAL )

						If TAFColumnPos( "C99_XMLID" )
							oModel:LoadValue( "MODEL_C99", "C99_XMLID", cXmlID )
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Rodo o aRules para gravar as informacoes³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nlI := 1 To Len( aRules )
							oModel:LoadValue( "MODEL_C99", aRules[ nlI, 01 ], FTafGetVal( aRules[ nlI, 02 ], aRules[nlI, 03], aRules[nlI, 04], @aIncons, .F., ,aRules[ nlI, 01 ] ) )
						Next

						If Findfunction("TAFAltMan")
							if nOpc == 3
								TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_C99', 'C99_LOGOPE' , '1', '' )
							elseif nOpc == 4
								TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_C99', 'C99_LOGOPE' , '', cLogOpeAnt )
							EndIf
						endif

					/*----------------------------------------------------------
							Informações do registro Filho T03
					----------------------------------------------------------*/
					//Quando se trata de uma alteracao, deleto todas as linhas do Grid
					cT03Path := cCabec + cTagOper + "/dadosLotacao/infoEmprParcial[1]"
		
						If nOpc == 4
							For nlJ := 1 to oModel:GetModel( "MODEL_T03" ):Length()
							oModel:GetModel( "MODEL_T03" ):GoLine(nlJ)
							oModel:GetModel( "MODEL_T03" ):DeleteLine()
							Next nlJ
						EndIf
		
					//Rodo o XML parseado para gravar as novas informacoes no GRID
					nlJ := 1
						While oDados:XPathHasNode(cCabec + cTagOper + "/dadosLotacao/fpasLotacao/infoProcJudTerceiros/procJudTerceiro[" + cValToChar(nlJ)+ "]" )
		
							If nOpc == 4 .or. nlJ > 1
							oModel:GetModel( "MODEL_T03" ):lValid:= .T.
							oModel:GetModel( "MODEL_T03" ):AddLine()
							EndIf
						
						cT03Path := cCabec + cTagOper +   "/dadosLotacao/fpasLotacao/infoProcJudTerceiros/procJudTerceiro[" + cValToChar(nlJ)+ "]"
						
							If oDados:XPathHasNode(cT03Path + "/codTerc")
								oModel:LoadValue( "MODEL_T03", "T03_FPAS"  , FGetIdInt( "codTerc",,cT03Path + "/codTerc",,,,@cInconMsg, @nSeqErrGrv)) //codTercs
							EndIF
						
							If oDados:XPathHasNode(cT03Path + "/nrProcJud")
								cIdProc := FGetIdInt( "", "nrProcJud",,cT03Path + "/nrProcJud",,,@cInconMsg, @nSeqErrGrv)
								oModel:LoadValue("MODEL_T03", "T03_IDPROC", cIdProc )					
							EndIf
						
							If !Empty(cIdProc)
								If oDados:XPathHasNode(cT03Path + "/codSusp" )
								oModel:LoadValue("MODEL_T03", "T03_IDSUSP", FGetIdInt( "codSusp","",FTafGetVal( cT03Path + "/codSusp", "C", .F., @aIncons, .F. ),cIdProc,.F.,,@cInconMsg, @nSeqErrGrv) )							
								EndIf
							EndIf
											
						nlJ ++
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
		
		EndIf
			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Zerando os arrays e os Objetos utilizados no processamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize( aRules, 0 ) 
	aRules	:= Nil
	
	aSize( aChave, 0 ) 
	aChave	:= Nil   
		 
	EndIf

Return { lRet, aIncons } 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF246Rul           

Regras para gravacao das informacoes do registro S-1020 do E-Social

@Param
nOper      - Operacao a ser realizada ( 3 = Inclusao / 4 = Alteracao / 5 = Exclusao )

@Return	
aRull  - Regras para a gravacao das informacoes


@author Leandro Prado
@since 26/09/2013
@version 1.0

/*/                        	
//-------------------------------------------------------------------
Static Function TAF246Rul( cTagOper, cInconMsg, nSeqErrGrv, cCodEvent, cOwner )

	Local aRull
	Local lIncAlt
	Local cCabec

	Default cTagOper   := ""
	Default cInconMsg  := ""
	Default nSeqErrGrv := 0
	Default cCodEvent  := ""
	Default cOwner     := ""

	aRull       := {}
	lIncAlt     := .F.
	cCabec      := "/eSocial/evtTabLotacao/infoLotacao"


	If cTagOper ==  "/inclusao" .OR. cTagOper ==  "/alteracao"

		If TafXNode(oDados , cCodEvent, cOwner,(cCabec + cTagOper + "/ideLotacao/codLotacao"))
			Aadd( aRull, { "C99_CODIGO", cCabec + cTagOper + "/ideLotacao/codLotacao"							     , "C", .F. } ) //codLotacao
		EndIf

		If TafXNode(oDados , cCodEvent, cOwner,(cCabec + cTagOper +"/dadosLotacao/tpLotacao"))
			Aadd( aRull, { "C99_TPLOT",  FGetIdInt( "tpLotacao", ,cCabec + cTagOper +"/dadosLotacao/tpLotacao",,,,@cInconMsg, @nSeqErrGrv) , "C", .T. } ) //tpLotacao
		EndIf

		If TafXNode(oDados , cCodEvent, cOwner,( cCabec + cTagOper + "/dadosLotacao/tpInsc"	))
			Aadd( aRull, { "C99_TPINES", cCabec + cTagOper + "/dadosLotacao/tpInsc"								  , "C", .F. } ) //tpInsc
		EndIf

		If TafXNode(oDados , cCodEvent, cOwner,(	cCabec + cTagOper + "/dadosLotacao/nrInsc"))
			Aadd( aRull, { "C99_NRINES", cCabec + cTagOper + "/dadosLotacao/nrInsc"								  , "C", .F. } ) //nrInsc
		EndIf

		If TafXNode(oDados , cCodEvent, cOwner,(cCabec + cTagOper + "/dadosLotacao/fpasLotacao/fpas")) .or. TafXNode(oDados , cCodEvent, cOwner,(cCabec + cTagOper  + "/dadosLotacao/fpasLotacao/codTercs"))
			Aadd( aRull, {"C99_FPAS",  +;
				FGetIdInt( "fpas", "codTerceiros",+;
				cCabec + cTagOper + "/dadosLotacao/fpasLotacao/fpas", +;
				cCabec + cTagOper + "/dadosLotacao/fpasLotacao/codTercs",,,@cInconMsg, @nSeqErrGrv)	      , "C", .T. } ) //fpas
		EndIf

		If TafXNode(oDados , cCodEvent, cOwner,(cCabec + cTagOper + "/dadosLotacao/fpasLotacao/codTercs"))
			Aadd( aRull, {"C99_CODTER",FGetIdInt( "codTerc", ,	cCabec + cTagOper  +;
				"/dadosLotacao/fpasLotacao/codTercs",,,,@cInconMsg, @nSeqErrGrv)     , "C", .T. } ) //codTercs
		EndIf

		If TafXNode(oDados , cCodEvent, cOwner,(cCabec + cTagOper + "/dadosLotacao/fpasLotacao/codTercsSusp"))
			Aadd( aRull, { "C99_TERSUS", cCabec + cTagOper + "/dadosLotacao/fpasLotacao/codTercsSusp"           , "C", .F. } ) //codTercsSusp
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner,(cCabec + cTagOper + "/dadosLotacao/infoEmprParcial/tpInscContrat"))
			Aadd( aRull, { "C99_TPINCT", cCabec + cTagOper + "/dadosLotacao/infoEmprParcial/tpInscContrat"      , "C", .F. } ) //tpInscContrat
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner,(cCabec + cTagOper + "/dadosLotacao/infoEmprParcial/nrInscContrat" ))
			Aadd( aRull, { "C99_NRINCT", cCabec + cTagOper + "/dadosLotacao/infoEmprParcial/nrInscContrat"      , "C", .F. } ) //nrInscContrat
		EndIf

		If TafXNode(oDados , cCodEvent, cOwner,(cCabec + cTagOper + "/dadosLotacao/infoEmprParcial/tpInscProp" ))
			Aadd( aRull, { "C99_TPINPR", cCabec + cTagOper + "/dadosLotacao/infoEmprParcial/tpInscProp"         , "C", .F. } ) //tpInscProp
		EndIf

		If TafXNode(oDados , cCodEvent, cOwner,(cCabec + cTagOper + "/dadosLotacao/infoEmprParcial/nrInscProp"  ))
			Aadd( aRull, { "C99_NRINPR", cCabec + cTagOper + "/dadosLotacao/infoEmprParcial/nrInscProp"         , "C", .F. } ) //nrInscProp
		EndIf

		If lLaySimplif

			If TafXNode(oDados , cCodEvent, cOwner,(cCabec + cTagOper + "/dadosLotacao/dadosOpPort/aliqRat" ))
				Aadd( aRull, { "C99_ALQRAT", cCabec + cTagOper + "/dadosLotacao/dadosOpPort/aliqRat"         , "N", .F. } ) //aliqRat
			EndIf

			If TafXNode(oDados , cCodEvent, cOwner,(cCabec + cTagOper + "/dadosLotacao/dadosOpPort/fap"  ))
				Aadd( aRull, { "C99_FAP", cCabec + cTagOper + "/dadosLotacao/dadosOpPort/fap"         , "N", .F. } ) //fap
			EndIf

		EndIf

	EndIf

Return ( aRull )

