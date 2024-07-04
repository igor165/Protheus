#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA467.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA467

Cadastro MVC de Tabela de Carreiras do eSocial

@author Vitor Siqueira
@since 12/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA467()

	Private	oBrw := FWmBrowse():New()

	If FindFunction("TAFDesEven")
		TAFDesEven()
	EndIf

	If TAFAlsInDic("T5K")
		oBrw:SetDescription(STR0001) //"Cadastro de Tabela de Carreiras Públicas"
		oBrw:SetAlias("T5K")
		oBrw:SetMenuDef("TAFA467")
		oBrw:SetFilterDefault( "T5K_ATIVO == '1' .Or. (T5K_EVENTO == 'E' .And. T5K_STATUS = '4' .And. T5K_ATIVO = '2')" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )

		oBrw:AddLegend( "T5K_EVENTO == 'I' ", "GREEN" , STR0006 ) //"Registro Incluído"
		oBrw:AddLegend( "T5K_EVENTO == 'A' ", "YELLOW", STR0007 ) //"Registro Alterado"
		oBrw:AddLegend( "T5K_EVENTO == 'E' .And. T5K_STATUS <> '4' ", "RED"   , STR0008 ) //"Registro excluído não transmitido"
		oBrw:AddLegend( "T5K_EVENTO == 'E' .And. T5K_STATUS == '4' .And. T5K_ATIVO = '2' ", "BLACK"   , STR0012 ) //"Registro excluído transmitido"

		oBrw:Activate()
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Vitor Siqueira
@since 12/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao := {}
	Local aRotina := {}

	If FindFunction('TafXmlRet')
		aFuncao := { 	{ "" , "TafxmlRet('TAF467Xml','1035','T5K')" , "1" },;
						{ "" , "xFunHisAlt( 'T5K', 'TAFA467' ,,,, 'TAF467XML','1035' )", "3" } ,;
						{ "" , "TAFXmlLote( 'T5K', 'S-1035' , 'evtTabCarreira' , 'TAF467Xml',, oBrw )" , "5" },;
						{ "" , "xFunAltRec( 'T5K' )" , "10" } }
	Else 
		aFuncao := { 	{ "" , "TAF467Xml" , "1" },;
						{ "" , "xFunHisAlt( 'T5K', 'TAFA467' ,,,, 'TAF467XML','1035'  )", "3" } ,;
						{ "" , "TAFXmlLote( 'T5K', 'S-1035' , 'evtTabCarreira' , 'TAF467Xml',, oBrw )" , "5" },;
						{ "" , "xFunAltRec( 'T5K' )" , "10" } }
	EndIf 


	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If lMenuDif .Or. ViewEvent('S-1035')
		ADD OPTION aRotina Title STR0009 Action 'VIEWDEF.TAFA467' OPERATION 2 ACCESS 0 //"Visualizar"
	Else
		aRotina	:=	xFunMnuTAF( "TAFA467" , , aFuncao)
	EndIf

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Vitor Siqueira
@since 12/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruT5K  := FwFormStruct(1,"T5K")
	Local oModel    := MPFormModel():New("TAFA467",,,{|oModel| SaveModel(oModel)})

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruT5K:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	EndIf

	oModel:AddFields("MODEL_T5K",/*cOwner*/,oStruT5K)

	oModel:GetModel("MODEL_T5K" ):SetPrimaryKey({"T5K_CODIGO","T5K_DTINI","T5K_DTFIN"})
	
Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Vitor Siqueira
@since 12/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   := FwLoadModel("TAFA467")
	Local oStruT5K := FwFormStruct(2,"T5K")
	Local oView    := FwFormView():New()

	oView:SetModel(oModel)
	oView:AddField("VIEW_T5K",oStruT5K,"MODEL_T5K")
	oView:EnableTitleView("VIEW_T5K", STR0001 )


	oView:CreateHorizontalBox("FIELDST5K",100)
	oView:SetOwnerView("VIEW_T5K","FIELDST5K")

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruT5K,"T5K")
	EndIf

	/*-----------------------------------------------------------------------------------
	Esconde campos de controle interno
	-------------------------------------------------------------------------------------*/
	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If !lMenuDif
		xFunRmFStr(@oStruT5K,"T5K")
	EndIf

	If TafColumnPos( "T5K_LOGOPE" )
		oStruT5K:RemoveField( "T5K_LOGOPE")
	EndIf

Return(oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel

Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@Author Vitor Siqueira
@Since 12/01/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local cLogOpe		
	Local cLogOpeAnt	
	Local cVerAnt		:= ""
	Local cProtocolo	:= ""
	Local cEvento		:= ""
	Local cVersao		:= ""
	Local cChvRegAnt	:= ""
	Local nOperation	:= oModel:GetOperation()
	Local nT5K			:= 0
	Local aGrava		:= {}
	Local oModelT5K		:= Nil
	Local lRetorno		:= .T.

	cLogOpe    := ""
	cLogOpeAnt := ""

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT
		
			TafAjustID( "T5K", oModel) 
		
			oModel:LoadValue( "MODEL_T5K", "T5K_VERSAO", xFunGetVer() )

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_T5K', 'T5K_LOGOPE' , '2', '' )
			Endif
		
			FwFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE .or. nOperation == MODEL_OPERATION_DELETE

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta posicionado nao eh possivel analisar   ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			T5K->( DbSetOrder( 5 ) )
			If T5K->( MsSeek( xFilial( 'T5K' ) + FwFldGet('T5K_ID') + '1' ) )
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o registro ja foi transmitido³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If T5K->T5K_STATUS == "4" 
		
					oModelT5K := oModel:GetModel( "MODEL_T5K" )
		
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao anterior do registro para gravacao do rastro³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVerAnt    := oModelT5K:GetValue( "T5K_VERSAO" )
					cProtocolo := oModelT5K:GetValue( "T5K_PROTUL" )
					cEvento    := oModelT5K:GetValue( "T5K_EVENTO" )

					If TafColumnPos( "T5K_LOGOPE" )
						cLogOpeAnt := oModelT5K:GetValue( "T5K_LOGOPE" )
					endif

					If nOperation == MODEL_OPERATION_DELETE .And. cEvento == "E" 
						// Não é possível excluir um evento de exclusão já transmitido
						TAFMsgVldOp(oModel,"4")
						lRetorno := .F.
					Else
		
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Neste momento eu gravo as informacoes que foram carregadas na tela³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nT5K := 1 to Len( oModelT5K:aDataModel[ 1 ] )
							aAdd( aGrava, { oModelT5K:aDataModel[ 1, nT5K, 1 ], oModelT5K:aDataModel[ 1, nT5K, 2 ] } )
						Next nT5K

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Seto o campo como Inativo e gravo a versao do novo registro³
						//³no registro anterior                                       ³
						//|                                                           |
						//|ATENCAO -> A alteracao destes campos deve sempre estar     |
						//|abaixo do Loop do For, pois devem substituir as informacoes|
						//|que foram armazenadas no Loop acima                        |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						FAltRegAnt( 'T5K', '2' ,.F.,FwFldGet("T5K_DTFIN"),FwFldGet("T5K_DTINI"),T5K->T5K_DTINI )
			
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Neste momento eu preciso setar a operacao do model como Inclusao³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						oModel:DeActivate()
						oModel:SetOperation( 3 )
						oModel:Activate()
			
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Neste momento o usuario ja fez as modificacoes que          ³
						//³precisava e as mesmas estao armazenadas em memoria, ou seja,³
						//³nao devem ser consideradas agora                            ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

						For nT5K := 1 to Len( aGrava )
							oModel:LoadValue( "MODEL_T5K", aGrava[ nT5K, 1 ], aGrava[ nT5K, 2 ] )
						Next nT5K

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Neste momento eu realizo a inclusao do novo registro ja³
						//³contemplando as informacoes alteradas pelo usuario     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nT5K := 1 to Len( aGrava )
							oModel:LoadValue( "MODEL_T5K", aGrava[ nT5K, 1 ], aGrava[ nT5K, 2 ] )
						Next nT5K

						//Necessário Abaixo do For Nao Retirar
						If Findfunction("TAFAltMan")
							TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T5K', 'T5K_LOGOPE' , '' , cLogOpeAnt )
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
						oModel:LoadValue( "MODEL_T5K", "T5K_VERSAO", cVersao )
						oModel:LoadValue( "MODEL_T5K", "T5K_VERANT", cVerAnt )
						oModel:LoadValue( "MODEL_T5K", "T5K_PROTPN", cProtocolo )
						oModel:LoadValue( "MODEL_T5K", "T5K_PROTUL", "" )
						// Tratamento para limpar o ID unico do xml
						cAliasPai := "T5K"
						If TAFColumnPos( cAliasPai+"_XMLID" )
							oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
						EndIf

						
						If nOperation == MODEL_OPERATION_DELETE
							oModel:LoadValue( 'MODEL_T5K', 'T5K_EVENTO', "E" )
						ElseIf cEvento == "E"
							oModel:LoadValue( 'MODEL_T5K', 'T5K_EVENTO', "I" )
						Else
							oModel:LoadValue( 'MODEL_T5K', 'T5K_EVENTO', "A" )
						EndIf

						FwFormCommit( oModel )
					EndIf
				
				Elseif T5K->T5K_STATUS == "2"
					//Não é possível alterar um registro com aguardando validação
					TAFMsgVldOp(oModel,"2")
					lRetorno := .F. 			
				
				Else
		
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Caso o registro nao tenha sido transmitido ainda, gravo sua chave³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cChvRegAnt := T5K->( T5K_ID + T5K_VERANT )

					If TafColumnPos( "T5K_LOGOPE" )
						cLogOpeAnt := T5K->T5K_LOGOPE
					endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³No caso de um evento de Exclusao deve-se perguntar ao usuario se ele realmente deseja realizar a exclusao.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If T5K->T5K_EVENTO == "E"
						If nOperation == MODEL_OPERATION_DELETE
							If Aviso( xValStrEr("000754"), xValStrEr("000755"), { xValStrEr("000756"), xValStrEr("000757") }, 1 ) == 2 //##"Registro Excluído" ##"O Evento de exclusão não foi transmitido. Deseja realmente exclui-lo ou manter o evento de exclusão para transmissão posterior ?" ##"Excuir" ##"Manter"
									cChvRegAnt := ""
							EndIf
						Else
							oModel:LoadValue( "MODEL_T5K", "T5K_EVENTO", "A" )
						EndIf
					EndIf
		
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Executo a operacao escolhida³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty( cChvRegAnt )
		
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Funcao responsavel por setar o Status do registro para Branco³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						TAFAltStat( "T5K", " " )

						If nOperation == MODEL_OPERATION_UPDATE .And. Findfunction("TAFAltMan")
							TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T5K', 'T5K_LOGOPE' , '' , cLogOpeAnt )
						EndIf

						FwFormCommit( oModel )
		
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Caso a operacao seja uma exclusao...³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nOperation == MODEL_OPERATION_DELETE
							//Funcao para setar o registro anterior como Ativo
							TAFRastro( "T5K", 1, cChvRegAnt, .T. , , IIF(Type("oBrw") == "U", Nil, oBrw) )
						EndIf
		
					EndIf
		
				EndIf 
			Elseif TafIndexInDic("T5K", 8, .T.)

				T5K->( DbSetOrder( 8 ) )
				If T5K->( MsSeek( xFilial( 'T5K' ) + FwFldGet('T5K_ID')+ 'E42' ) ) 

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
/*/{Protheus.doc} TAF467Grv
@type			function
@description	Função de gravação para atender o registro S-1035 ( Tabela de Carreiras ).
@author			Vitor Siqueira
@since			12/01/2017
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
Function TAF467Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

	Local cLogOpeAnt	:=	""
	Local cCabec		:=	"/eSocial/evtTabCarreira/infoCarreira"
	Local cCmpsNoUpd	:=	"|T5K_FILIAL|T5K_ID|T5K_VERSAO|T5K_DTINI|T5K_DTFIN|T5K_VERANT|T5K_PROTUL|T5K_PROTPN|T5K_EVENTO|T5K_STATUS|T5K_ATIVO|"
	Local cValChv		:=	""
	Local cNewDtIni		:=	""
	Local cNewDtFin		:=	""
	Local cValorXml		:=	""
	Local cInconMsg		:=	""
	Local cCodEvent		:=	Posicione( "C8E", 2, xFilial( "C8E" ) + "S-" + cLayout, "C8E->C8E_ID" )
	Local cChave		:=	""
	Local cPerIni		:=	""
	Local cPerFin		:=	""
	Local cPerIniOri	:=	""
	Local nIndChv		:=	2
	Local nIndIDVer		:=	1
	Local nlI			:=	0
	Local nSeqErrGrv	:=	0
	Local nTamCod		:=	TamSX3( "T5K_CODIGO" )[1]
	Local lRet			:=	.F.
	Local aIncons		:=	{}
	Local aRules		:=	{}
	Local aChave		:=	{}
	Local aNewData		:=	{ Nil, Nil }
	Local oModel		:=	Nil
	Local lNewValid		:= .F.

	Private lVldModel	:=	.T. //Caso a chamada seja via integração, seto a variável de controle de validação como .T.
	Private oDados		:=	Nil

	Default cLayout		:=	""
	Default nOpc		:=	1
	Default cFilEv		:=	""
	Default oXML		:=	Nil
	Default cOwner		:=	""
	Default cFilTran	:=	""
	Default cPredeces	:=	""
	Default nTafRecno	:=	0
	Default cComplem	:=	""
	Default cGrpTran	:=	""
	Default cEmpOriGrp	:=	""
	Default cFilOriGrp	:=	""
	Default cXmlID		:=	""		

	oDados := oXML

	If nOpc == 3
		cTagOper := "/inclusao"  
	ElseIf nOpc == 4        
		cTagOper := "/alteracao"    
	ElseIf nOpc == 5
		cTagOper := "/exclusao"     
	EndIf

	//Verificar se o codigo foi informado para a chave ( Obrigatorio ser informado )
	cValChv := FTafGetVal( cCabec + cTagOper + "/ideCarreira/codCarreira", 'C', .F., @aIncons, .F., '', '' )
	If !Empty( cValChv )
		Aadd( aChave, { "C", "T5K_CODIGO", cValChv, .T.} )
		nIndChv := 4
		cChave += Padr(cValChv,nTamCod)
	EndIf	

	//Verificar se a data inicial foi informado para a chave( Se nao informado sera adotada a database internamente )
	cValChv := FTafGetVal( cCabec + cTagOper + "/ideCarreira/iniValid", 'C', .F., @aIncons, .F., '', '' )
	cValChv := TAF467Format("T5K_DTINI", cValChv)
	If !Empty( cValChv )
		Aadd( aChave, { "C", "T5K_DTINI", cValChv, .T. } )
		nIndChv := 6
		cPerIni := cValChv
		cPerIniOri := cValChv
	EndIf

	//Verificar se a data final foi informado para a chave( Se nao informado sera adotado vazio )
	cValChv := FTafGetVal( cCabec + cTagOper + "/ideCarreira/fimValid", 'C', .F., @aIncons, .F., '', '' )
	cValChv := TAF467Format("T5K_DTFIN", cValChv)
	If !Empty(cValChv)		
		Aadd( aChave, { "C", "T5K_DTFIN", cValChv, .T.} )
		nIndChv := 2
		cPerFin := cValChv
	EndIf

	If nOpc == 4	
		If oDados:XPathHasNode( cCabec + cTagOper + "/novaValidade/iniValid", 'C', .F., @aIncons, .F., '', ''  )
			cNewDtIni 	:= TAF467Format("T5K_DTINI", FTafGetVal( cCabec + cTagOper + "/novaValidade/iniValid", 'C', .F., @aIncons, .F., '', '' ))	
			aNewData[1] := cNewDtIni
			cPerIni 	:= cNewDtIni
			lNewValid	:= .T.
		EndIf

		If oDados:XPathHasNode( cCabec + cTagOper + "/novaValidade/fimValid", 'C', .F., @aIncons, .F., '', ''  )
			cNewDtFin 	:= TAF467Format("T5K_DTFIN", FTafGetVal( cCabec + cTagOper + "/novaValidade/fimValid", 'C', .F., @aIncons, .F., '', '' ))
			aNewData[2] := cNewDtFin
			cPerFin		:= cNewDtFin
			lNewValid	:= .T.
		EndIf
	EndIf

	//Valida as regras da nova validade	
	If Empty(aIncons)
		VldEvTab( "T5K", 6, cChave, cPerIni, cPerFin, 2, nOpc,@aIncons, cPerIniOri,,, lNewValid )
	EndIf

	If Empty(aIncons)

		Begin Transaction											
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Funcao para validar se a operacao desejada pode ser realizada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If FTafVldOpe( "T5K", nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA467", cCmpsNoUpd, nIndIDVer, .T., aNewData )

				If TafColumnPos( "T5K_LOGOPE" )
					cLogOpeAnt := T5K->T5K_LOGOPE
				endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
				//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nOpc <> 5 
		
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Carrego array com os campos De/Para de gravacao das informacoes³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aRules := TAF467Rul( cTagOper, @cInconMsg, @nSeqErrGrv, cCodEvent, cOwner )
		
					oModel:LoadValue( "MODEL_T5K", "T5K_FILIAL", T5K->T5K_FILIAL )

					If TAFColumnPos( "T5K_XMLID" )
						oModel:LoadValue( "MODEL_T5K", "T5K_XMLID", cXmlID )
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Rodo o aRules para gravar as informacoes³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nlI := 1 To Len( aRules )                 					
						cValorXml := FTafGetVal( aRules[ nlI, 02 ], aRules[nlI, 03], aRules[nlI, 04], @aIncons, .F., , aRules[ nlI, 01 ] )
						oModel:LoadValue( "MODEL_T5K", aRules[ nlI, 01 ], cValorXml )
					Next

					If Findfunction("TAFAltMan")
						if nOpc == 3
							TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T5K', 'T5K_LOGOPE' , '1', '' )
						elseif nOpc == 4
							TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T5K', 'T5K_LOGOPE' , '', cLogOpeAnt )
						EndIf
					EndIf				
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
	aRules     := Nil

	aSize( aChave, 0 ) 
	aChave     := Nil

	oModel     := Nil
   
Return { lRet, aIncons } 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF467Rul

Regras para gravacao das informacoes do registro S-1035 do E-Social

@Param
cTagOper - Tag de indicacao da operacao

@Return
aRull - Regras para a gravacao das informacoes

@author Vitor Siqueira
@since 12/01/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF467Rul( cTagOper, cInconMsg, nSeqErrGrv, cCodEvent, cOwner )

	Local aRull  := {}
	Local cCabec := "/eSocial/evtTabCarreira/infoCarreira"

	Default cTagOper		:= ""
	Default cInconMsg		:= ""
	Default nSeqErrGrv	:= 0
	Default cCodEvent		:= ""
	Default cOwner		:= ""

	if TafXNode(oDados , cCodEvent, cOwner,( cCabec + cTagOper + "/ideCarreira/codCarreira"))
		aAdd( aRull, { "T5K_CODIGO", cCabec + cTagOper + "/ideCarreira/codCarreira", "C", .F., 'T5K' } ) 		//codCarreira
	EndIf

	if TafXNode(oDados , cCodEvent, cOwner,(cCabec + cTagOper + "/dadosCarreira/dscCarreira"))
		aAdd( aRull, { "T5K_DESCRI", cCabec + cTagOper + "/dadosCarreira/dscCarreira", "C", .F., 'T5K' } ) 		//dscCarreira
	EndIf

	if TafXNode(oDados , cCodEvent, cOwner,(cCabec + cTagOper + "/dadosCarreira/leiCarr"))
		aAdd( aRull, { "T5K_LEICAR", cCabec + cTagOper + "/dadosCarreira/leiCarr", "C", .F., 'T5K' } ) 			//leiCarr
	EndIf

	if TafXNode(oDados , cCodEvent, cOwner,(cCabec + cTagOper + "/dadosCarreira/dtLeiCarr"))
		aAdd( aRull, { "T5K_DTLEI", cCabec + cTagOper + "/dadosCarreira/dtLeiCarr", "D", .F., 'T5K' } ) 		//dtLeiCarr
	EndIf

	if TafXNode(oDados , cCodEvent, cOwner,(cCabec + cTagOper + "/dadosCarreira/sitCarr"))
		aAdd( aRull, { "T5K_SITCAR", cCabec + cTagOper + "/dadosCarreira/sitCarr", "C", .F., 'T5K' } ) 			//sitCarr
	EndIf
							
Return( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF467Format

Formata os campos do registro S-1035 do E-Social

@Param
cCampo 	  - Campo que deve ser formatado
cValorXml - Valor a ser formatado

@Return
cFormatValue - Valor já formatado

@author Vitor Siqueira
@since 12/01/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF467Format(cCampo, cValorXml)

	Local cFormatValue, cRet := ''

	If (cCampo == 'T5K_DTINI' .OR. cCampo == 'T5K_DTFIN')
		cFormatValue := StrTran( StrTran( cValorXml, "-", "" ), "/", "")
		cRet := Substr(cFormatValue, 5, 2) + Substr(cFormatValue, 1,4)
	Else
		cRet := cValorXml
	EndIf

Return( cRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF467Xml

Funcao de geracao do XML para atender o registro S-1035
Quando a rotina for chamada o registro deve estar posicionado

@Param:
cAlias - Alias da Tabela
nRecno - Recno do Registro corrente
nOpc   - Operacao a ser realizada
lJob   - Informa se foi chamado por Job
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@Return:
cXml - Estrutura do Xml do Layout S-1035

@author Vitor Siqueira
@since 12/01/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF467Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

	Local cXml     := ""
	Local cLayout  := "1035"
	Local cReg     := "TabCarreira"
	Local cEvento  := ""
	Local cDtIni   := ""
	Local cDtFin   := ""
	Local cId 	   := ""
	Local cVerAnt  := ""

	Default lJob := .F.
	Default cSeqXml := ""

	If T5K->T5K_EVENTO $ "I|A"

		If T5K->T5K_EVENTO == "A"
			cEvento := "alteracao"

			cId := T5K->T5K_ID 
			cVerAnt := T5K->T5K_VERANT
			
			BeginSql alias 'T5KTEMP'
				SELECT T5K.T5K_DTINI,T5K.T5K_DTFIN
				FROM %table:T5K% T5K
				WHERE T5K.T5K_FILIAL= %xfilial:T5K% AND
				T5K.T5K_ID = %exp:cId% AND T5K.T5K_VERSAO = %exp:cVerAnt% AND 
				T5K.%notDel%
			EndSql  
			
			//***********************************************************************************
			//Tratamento do formato da data (T5K_DTINI e T5K_DTFIN) para geração do XML de acordo 
			//com a nova fomulação do eSocial. Formato: AAAA-MM 
			//***********************************************************************************
			cDtIni := Substr(('T5KTEMP')->T5K_DTINI,3,4) +"-"+ Substr(('T5KTEMP')->T5K_DTINI,1,2)
			
			If ! Empty(('T5KTEMP')->T5K_DTFIN)
				cDtFin := Substr(('T5KTEMP')->T5K_DTFIN,3,4) +"-"+ Substr(('T5KTEMP')->T5K_DTFIN,1,2)
			EndIF
			//-----------

			
			('T5KTEMP')->( DbCloseArea() )

		Else
			cEvento := "inclusao"

		
			//***********************************************************************************
			//Tratamento do formato da data (T5K_DTINI e T5K_DTFIN) para geração do XML de acordo 
			//com a nova fomulação do eSocial. Formato: AAAA-MM 
			//***********************************************************************************
			cDtIni := Substr(T5K->T5K_DTINI,3,4) +"-"+ Substr(T5K->T5K_DTINI,1,2)
			
			if ! Empty(T5K->T5K_DTFIN)
				cDtFin := Substr(T5K->T5K_DTFIN,3,4) +"-"+ Substr(T5K->T5K_DTFIN,1,2)
			EndIF
			//-----------
			
		EndIf

		cXml +=			"<infoCarreira>"
		cXml +=				"<" + cEvento + ">"
		cXml +=					"<ideCarreira>"
		cXml +=						xTafTag("codCarreira",T5K->T5K_CODIGO)
		cXml +=						xTafTag("iniValid",cDtIni)
		cXml +=						xTafTag("fimValid",cDtFin,,.T.)

		cXml +=					"</ideCarreira>"
		cXml +=					"<dadosCarreira>"
		cXml +=						xTafTag("dscCarreira",T5K->T5K_DESCRI)
		cXml +=						xTafTag("leiCarr"    ,T5K->T5K_LEICAR,,.T.)
		cXml +=						xTafTag("dtLeiCarr"  ,T5K->T5K_DTLEI)
		cXml +=						xTafTag("sitCarr"    ,T5K->T5K_SITCAR)
		cXml +=					"</dadosCarreira>"

		If T5K->T5K_EVENTO == "A"
			If TafAtDtVld("T5K", T5K->T5K_ID, T5K->T5K_DTINI, T5K->T5K_DTFIN, T5K->T5K_VERANT, .T.)
				cXml +=				"<novaValidade>"
				cXml +=					TafGetDtTab( T5K->T5K_DTINI, T5K->T5K_DTFIN )
				cXml +=				"</novaValidade>"
			EndIf
		EndIf

		cXml +=				"</" + cEvento + ">"
		cXml +=			"</infoCarreira>"

	ElseIf T5K->T5K_EVENTO == "E"

		cXml +=			"<infoCarreira>"
		cXml +=				"<exclusao>"
		cXml +=					"<ideCarreira>"
		cXml +=						xTafTag("codCarreira",T5K->T5K_CODIGO)
		cXml +=						TafGetDtTab( T5K->T5K_DTINI, T5K->T5K_DTFIN )
		cXml +=					"</ideCarreira>"
		cXml +=				"</exclusao>"
		cXml +=			"</infoCarreira>"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Estrutura do cabecalho³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cXml := xTafCabXml(cXml,"T5K",cLayout,cReg,,cSeqXml)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa gravacao do registro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lJob
		xTafGerXml(cXml,cLayout)
	EndIf

Return(cXml)
