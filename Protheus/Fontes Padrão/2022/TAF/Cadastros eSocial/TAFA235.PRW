#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA235.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA235

Cadastro MVC de Tabela de Cargos do eSocial

@author Felipe C. Seolin
@since 19/08/2013
@version 1.0
/*/
//------------------------------------------------------------------
Function TAFA235()

	Private oBrw := FwMBrowse():New()
	
	If FindFunction("TAFDesEven")
		TAFDesEven()
	EndIf

	oBrw:SetDescription(STR0001) //"Cadastro de Tabelas de Cargos"
	oBrw:SetAlias( 'C8V')
	oBrw:SetMenuDef( 'TAFA235' )
	oBrw:SetFilterDefault( "C8V_ATIVO == '1' .Or. (C8V_EVENTO == 'E' .And. C8V_STATUS = '4' .And. C8V_ATIVO = '2')" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )

	oBrw:AddLegend( "C8V_EVENTO == 'I' ", "GREEN" , STR0006 ) //"Registro Incluído"
	oBrw:AddLegend( "C8V_EVENTO == 'A' ", "YELLOW", STR0007 ) //"Registro Alterado"
	oBrw:AddLegend( "C8V_EVENTO == 'E' .And. C8V_STATUS <> '4' ", "RED"   , STR0008 ) //"Registro excluído não transmitido"
	oBrw:AddLegend( "C8V_EVENTO == 'E' .And. C8V_STATUS == '4' .And. C8V_ATIVO = '2' ", "BLACK"   , STR0014 ) //"Registro excluído não transmitido"

	oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Felipe C. Seolin
@since 19/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}
If FindFunction('TafXmlRet') 
	aFuncao := { 	{ "" , "TafxmlRet('TAF235Xml','1030','C8V')" , "1" },;
					{ "" , "xFunHisAlt( 'C8V', 'TAFA235',,,,'TAF235XML','1030' )", "3" } ,;
					{ "" , "TAFXmlLote( 'C8V', 'S-1030' , 'evtTabCargo' , 'TAF235Xml',, oBrw )" , "5" },;
					{ "" , "xFunAltRec( 'C8V' )" , "10" } }
Else
	aFuncao := { 	{ "" , "TAF235Xml" , "1" },;
					{ "" , "xFunHisAlt( 'C8V', 'TAFA235',,,,'TAF235XML','1030' )", "3" } ,;
					{ "" , "TAFXmlLote( 'C8V', 'S-1030' , 'evtTabCargo' , 'TAF235Xml',, oBrw )" , "5" },;
					{ "" , "xFunAltRec( 'C8V' )" , "10" } }
EndIf


lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif .Or. ViewEvent('S-1030')
	ADD OPTION aRotina Title STR0009 Action 'VIEWDEF.TAFA235' OPERATION 2 ACCESS 0 //"Visualizar"
Else
	aRotina	:=	xFunMnuTAF( "TAFA235" , , aFuncao)
EndIf

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Felipe C. Seolin
@since 19/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruC8V  := FwFormStruct(1,"C8V")
Local oStruT10  := FwFormStruct(1,"T10") // Cargos e Empregos Públicos 
Local oStruT11  := FwFormStruct(1,"T11") // Lei que criou/extingiu/reestruturou o cargos 

Local oModel    := MPFormModel():New("TAFA235",,,{|oModel| SaveModel(oModel)})

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

If lVldModel
	oStruC8V:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
EndIf

oModel:AddFields("MODEL_C8V",/*cOwner*/,oStruC8V)

oModel:AddGrid("MODEL_T10", "MODEL_C8V", oStruT10)
oModel:GetModel( "MODEL_T10" ):SetOptional( .T. )
oModel:GetModel( "MODEL_T10" ):SetUniqueLine( { "T10_ACUMCG" } )

oModel:AddGrid("MODEL_T11", "MODEL_T10", oStruT11)
oModel:GetModel( "MODEL_T11" ):SetOptional( .T. )
oModel:GetModel( "MODEL_T11" ):SetUniqueLine( { "T11_NRLEI" } )

oModel:GetModel("MODEL_C8V" ):SetPrimaryKey({"C8V_CODIGO","C8V_DTINI","C8V_DTFIN"})

oModel:SetRelation("MODEL_T10", { { "T10_FILIAL", 'xFilial( "T10" )' }, { 'T10_ID' , "C8V_ID" }, { "T10_VERSAO" , "C8V_VERSAO" } }, T10->(IndexKey( 1 )))
oModel:SetRelation("MODEL_T11", { { "T11_FILIAL", 'xFilial( "T11" )' }, { 'T11_ID' , "C8V_ID" }, { "T11_VERSAO" , "C8V_VERSAO" }, { "T11_ACUMCG" , "T10_ACUMCG" } }, T11->(IndexKey( 1 )))
	
Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Felipe C. Seolin
@since 19/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel("TAFA235")
Local oStruC8V := FwFormStruct(2,"C8V")
Local oStruT10 := FwFormStruct(2,"T10")
Local oStruT11 := FwFormStruct(2,"T11")
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_C8V",oStruC8V,"MODEL_C8V")
oView:EnableTitleView("VIEW_C8V", STR0001 )

If FindFunction("TafAjustRecibo")
	TafAjustRecibo(oStruC8V,"C8V")
EndIf

oView:AddGrid ("VIEW_T10", oStruT10,"MODEL_T10")
oView:EnableTitleView("VIEW_T10", STR0010)	//Cargos e Empregos Públicos
oModel:GetModel("MODEL_T10"):SetNoInsertLine(.T.)

oView:AddGrid ("VIEW_T11", oStruT11,"MODEL_T11")
oView:EnableTitleView("VIEW_T11", STR0011)	//Lei que criou/extingiu/reestruturou o cargos 
oModel:GetModel("MODEL_T11"):SetNoInsertLine(.T.)

oView:CreateHorizontalBox("FIELDSC8V",44)

oView:CreateHorizontalBox("GRIDT10",28)
oView:CreateHorizontalBox("GRIDT11",28)

oView:SetOwnerView("VIEW_C8V","FIELDSC8V")

oView:SetOwnerView("VIEW_T10","GRIDT10")
oView:SetOwnerView("VIEW_T11","GRIDT11")

/*-----------------------------------------------------------------------------------
Esconde campos de controle interno
-------------------------------------------------------------------------------------*/
oStruT10:RemoveField('T10_ID')
oStruT11:RemoveField('T11_ID')

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If !lMenuDif
	xFunRmFStr(@oStruC8V,"C8V")
EndIf

If TafColumnPos( "C8V_LOGOPE" )
	oStruC8V:RemoveField( "C8V_LOGOPE" )
EndIf

Return(oView)

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

Local cLogOpe		
Local cLogOpeAnt	
Local cVerAnt			:= ""
Local cProtocolo		:= ""
Local cEvento			:= ""
Local cVersao			:= ""
Local cChvRegAnt		:= ""
Local nOperation		:= oModel:GetOperation()
Local nC8V, nT10, nT11	:= 0
Local aGrava			:= {}
Local aGravaT10		:= {}
Local aGravaT11		:= {}
Local oModelC8V		:= Nil
Local oModelT10		:= Nil
Local oModelT11		:= Nil
Local lRetorno		:= .T.

cLogOpe		:= ""
cLogOpeAnt	:= ""

Begin Transaction

	If nOperation == MODEL_OPERATION_INSERT
	
		TafAjustID( "C8V", oModel) 
		
		oModel:LoadValue( "MODEL_C8V", "C8V_VERSAO", xFunGetVer() )
		
		If Findfunction("TAFAltMan")
			TafAltMan( 3 , 'Save' , oModel, 'MODEL_C8V', 'C8V_LOGOPE' , '2', '' )
		endif

		FwFormCommit( oModel )

	ElseIf nOperation == MODEL_OPERATION_UPDATE .or. nOperation == MODEL_OPERATION_DELETE

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seek para posicionar no registro antes de realizar as validacoes,³
		//³visto que quando nao esta posicionado nao eh possivel analisar   ³
		//³os campos nao usados como _STATUS                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    C8V->( DbSetOrder( 4 ) )
	    If C8V->( MsSeek( xFilial( 'C8V' ) + FwFldGet('C8V_ID') + '1' ) )
	    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o registro ja foi transmitido³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If C8V->C8V_STATUS == "4"
	
				oModelC8V := oModel:GetModel( "MODEL_C8V" )
				oModelT10 := oModel:GetModel( "MODEL_T10" )
				oModelT11 := oModel:GetModel( "MODEL_T11" )
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Busco a versao anterior do registro para gravacao do rastro³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cVerAnt    := oModelC8V:GetValue( "C8V_VERSAO" )
				cProtocolo := oModelC8V:GetValue( "C8V_PROTUL" )
				cEvento    := oModelC8V:GetValue( "C8V_EVENTO" )

				If TafColumnPos( "C8V_LOGOPE" )
					cLogOpeAnt := oModelC8V:GetValue( "C8V_LOGOPE" )	
				endif

				If nOperation == MODEL_OPERATION_DELETE .And. cEvento == "E" 
					// Não é possível excluir um evento de exclusão já transmitido
					TAFMsgVldOp(oModel,"4")
					lRetorno := .F.
				Else
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu gravo as informacoes que foram carregadas na tela³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nC8V := 1 to Len( oModelC8V:aDataModel[ 1 ] )
						aAdd( aGrava, { oModelC8V:aDataModel[ 1, nC8V, 1 ], oModelC8V:aDataModel[ 1, nC8V, 2 ] } )
					Next nC8V
					
					If !oModel:GetModel( 'MODEL_T10' ):IsEmpty()
						For nT10 := 1 To oModel:GetModel( 'MODEL_T10' ):Length()
							oModel:GetModel( 'MODEL_T10' ):GoLine(nT10)
							If !oModel:GetModel( 'MODEL_T10' ):IsDeleted()
								aAdd (aGravaT10 ,{oModelT10:GetValue('T10_ACUMCG');
												, oModelT10:GetValue('T10_CONESP');
												, oModelT10:GetValue('T10_DEDEXC')} )
												
								If !oModel:GetModel( 'MODEL_T11' ):IsEmpty()
									For nT11 := 1 To oModel:GetModel( 'MODEL_T11' ):Length()
										oModel:GetModel( 'MODEL_T11' ):GoLine(nT11)
										If !oModel:GetModel( 'MODEL_T11' ):IsDeleted()
											aAdd (aGravaT11 	,{oModelT10:GetValue('T10_ACUMCG');
																, oModelT11:GetValue('T11_NRLEI');
																, oModelT11:GetValue('T11_DTLEI');
																, oModelT11:GetValue('T11_SITCGO')} )
										EndIf
									Next nT11
								EndIf
							EndIf
						Next nT10
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seto o campo como Inativo e gravo a versao do novo registro³
					//³no registro anterior                                       ³
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FAltRegAnt( 'C8V', '2' ,.F.,FwFldGet("C8V_DTFIN"),FwFldGet("C8V_DTINI"),C8V->C8V_DTINI )
		
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

					For nC8V := 1 to Len( aGrava )
						oModel:LoadValue( "MODEL_C8V", aGrava[ nC8V, 1 ], aGrava[ nC8V, 2 ] )
					Next nC8V				


					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu realizo a inclusao do novo registro ja³
					//³contemplando as informacoes alteradas pelo usuario     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nC8V := 1 to Len( aGrava )
						oModel:LoadValue( "MODEL_C8V", aGrava[ nC8V, 1 ], aGrava[ nC8V, 2 ] )
					Next nC8V

					//Necessário Abaixo do For Nao Retirar
					If Findfunction("TAFAltMan")
						TafAltMan( 4 , 'Save' , oModel, 'MODEL_C8V', 'C8V_LOGOPE' , '' , cLogOpeAnt )			
					endif
		
					For nT10 := 1 To Len( aGravaT10 )
						If nT10 > 1
							oModel:GetModel( 'MODEL_T10' ):AddLine()
						EndIf

						oModel:LoadValue( "MODEL_T10", "T10_ACUMCG", aGravaT10[nT10][1] )
						oModel:LoadValue( "MODEL_T10", "T10_CONESP", aGravaT10[nT10][2] )
						oModel:LoadValue( "MODEL_T10", "T10_DEDEXC", aGravaT10[nT10][3] )

						nAddT10 := 1
						For nT11 := 1 To Len( aGravaT11 )  
							If aGravaT10[nT10][1] == aGravaT11[nT11][1]
								If nAddT10 > 1
									oModel:GetModel( 'MODEL_T11' ):AddLine()
								EndIf

								oModel:LoadValue( "MODEL_T11", "T11_NRLEI", aGravaT11[nT11][2] )
								oModel:LoadValue( "MODEL_T11", "T11_DTLEI", aGravaT11[nT11][3] )
								oModel:LoadValue( "MODEL_T11", "T11_SITCGO", aGravaT11[nT11][4] )

								nAddT10++ 
							EndIf
		            	Next nT11	
		            Next nT10	

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao que sera gravada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVersao := xFunGetVer()
		
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oModel:LoadValue( "MODEL_C8V", "C8V_VERSAO", cVersao )
					oModel:LoadValue( "MODEL_C8V", "C8V_VERANT", cVerAnt )
					oModel:LoadValue( "MODEL_C8V", "C8V_PROTPN", cProtocolo )
					oModel:LoadValue( "MODEL_C8V", "C8V_PROTUL", "" )
					// Tratamento para limpar o ID unico do xml
					cAliasPai := "C8V"
					If TAFColumnPos( cAliasPai+"_XMLID" )
						oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					EndIf

					
					If nOperation == MODEL_OPERATION_DELETE
						oModel:LoadValue( 'MODEL_C8V', 'C8V_EVENTO', "E" )
					ElseIf cEvento == "E"
						oModel:LoadValue( 'MODEL_C8V', 'C8V_EVENTO', "I" )
					Else
						oModel:LoadValue( 'MODEL_C8V', 'C8V_EVENTO', "A" )	
					EndIf

					FwFormCommit( oModel )
				EndIf
			
			Elseif C8V->C8V_STATUS == "2"
				//Não é possível alterar um registro com aguardando validação
				TAFMsgVldOp(oModel,"2")
				lRetorno := .F. 
					
			Else
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso o registro nao tenha sido transmitido ainda, gravo sua chave³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cChvRegAnt := C8V->( C8V_ID + C8V_VERANT )

				If TafColumnPos( "C8V_LOGOPE" )
					cLogOpeAnt := C8V->C8V_LOGOPE
				endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³No caso de um evento de Exclusao deve-se perguntar ao usuario se ele realmente deseja realizar a exclusao.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If C8V->C8V_EVENTO == "E"
					If nOperation == MODEL_OPERATION_DELETE
						If Aviso( xValStrEr("000754"), xValStrEr("000755"), { xValStrEr("000756"), xValStrEr("000757") }, 1 ) == 2 //##"Registro Excluído" ##"O Evento de exclusão não foi transmitido. Deseja realmente exclui-lo ou manter o evento de exclusão para transmissão posterior ?" ##"Excuir" ##"Manter"
								cChvRegAnt := ""
						EndIf
					Else
						oModel:LoadValue( "MODEL_C8V", "C8V_EVENTO", "A" )
					EndIf
				EndIf
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Executo a operacao escolhida³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty( cChvRegAnt )
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Funcao responsavel por setar o Status do registro para Branco³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					TAFAltStat( "C8V", " " )

					If nOperation == MODEL_OPERATION_UPDATE .And. Findfunction("TAFAltMan")
						TafAltMan( 4 , 'Save' , oModel, 'MODEL_C8V', 'C8V_LOGOPE' , '' , cLogOpeAnt )
					endif

					FwFormCommit( oModel )
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Caso a operacao seja uma exclusao...³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nOperation == MODEL_OPERATION_DELETE
						//Funcao para setar o registro anterior como Ativo
						TAFRastro( "C8V", 1, cChvRegAnt, .T. , , IIF(Type("oBrw") == "U", Nil, oBrw) ) 
					EndIf
	
				EndIf
	
			EndIf 
		Elseif TafIndexInDic("C8V", 7, .T.)

			C8V->( DbSetOrder( 7 ) )
	    	If C8V->( MsSeek( xFilial( 'C8V' ) + FwFldGet('C8V_ID')+ 'E42' ) ) 

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
/*/{Protheus.doc} TAF235Grv
@type			function
@description	Função de gravação para atender o registro S-1030 ( Tabela de Cargos ).
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
Function TAF235Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

Local cLogOpeAnt	:=	""
Local cTagOper		:=	""
Local cCmpsNoUpd	:=	"|C8V_FILIAL|C8V_ID|C8V_VERSAO|C8V_DTINI|C8V_DTFIN|C8V_VERANT|C8V_PROTUL|C8V_PROTPN|C8V_EVENTO|C8V_STATUS|C8V_ATIVO|"
Local cCabec		:=	"/eSocial/evtTabCargo/infoCargo"
Local cValChv		:=	""
Local cNewDtIni		:=	""
Local cNewDtFin		:=	""
Local cInconMsg		:=	""
Local cValorXml		:=	""
Local cCodEvent		:=	Posicione( "C8E", 2, xFilial( "C8E" ) + "S-" + cLayout, "C8E->C8E_ID" )
Local cChave		:=	""
Local cPerIni		:=	""
Local cPerFin		:=	""
Local cPerIniOri	:=	""
Local nIndChv		:=	2
Local nIndIDVer		:=	1
Local nI			:=	0
Local nT10			:=	0
Local nT11			:=	0
Local nSeqErrGrv	:=	0
Local nTamCod		:=	TamSX3( "C8V_CODIGO" )[1]
Local lRet			:=	.F.
Local aIncons		:=	{}
Local aRules		:=	{}
Local aChave		:=	{}
Local aNewData		:=	{ Nil, Nil }
Local oModel		:=	Nil
Local lNewValid		:= .F.

Private oDados		:=	Nil
Private lVldModel	:=	.T. //Caso a chamada seja via integração, seto a variável de controle de validação como .T.

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
cValChv := FTafGetVal( cCabec + cTagOper + "/ideCargo/codCargo", 'C', .F., @aIncons, .F., '', '' )
If !Empty( cValChv )
	aAdd( aChave, { "C", "C8V_CODIGO", cValChv, .T.} )
	nIndChv := 5
	cChave += Padr(cValChv,nTamCod)
EndIf

//Verificar se a data inicial foi informado para a chave( Se nao informado sera adotada a database internamente )
cValChv := FTafGetVal( cCabec + cTagOper + "/ideCargo/iniValid", 'C', .F., @aIncons, .F., '', '' )
cValChv := TAF235Format("C8V_DTINI", cValChv)
If !Empty( cValChv )
	aAdd( aChave, { "C", "C8V_DTINI", cValChv, .T. } )
	nIndChv := 6
	cPerIni := cValChv
	cPerIniOri := cValChv
EndIf

//Verificar se a data final foi informado para a chave( Se nao informado sera adotado vazio )
cValChv := FTafGetVal( cCabec + cTagOper + "/ideCargo/fimValid", 'C', .F., @aIncons, .F., '', '' )
cValChv := TAF235Format("C8V_DTFIN", cValChv)
If !Empty( cValChv )
	aAdd( aChave, { "C", "C8V_DTFIN", cValChv, .T.} )
	nIndChv := 2
	cPerFin := cValChv
EndIf

If nOpc == 4
	If oDados:XPathHasNode( cCabec + cTagOper + "/novaValidade/iniValid", 'C', .F., @aIncons, .F., '', ''  )
		cNewDtIni	:= TAF235Format("C8V_DTINI", FTafGetVal( cCabec + cTagOper + "/novaValidade/iniValid", 'C', .F., @aIncons, .F., '', '' ))		
		aNewData[1] := cNewDtIni
		cPerIni		:= cNewDtIni
		lNewValid	:= .T.
	EndIf
	
	If oDados:XPathHasNode( cCabec + cTagOper + "/novaValidade/fimValid", 'C', .F., @aIncons, .F., '', ''  )
		cNewDtFin 	:= TAF235Format("C8V_DTFIN", FTafGetVal( cCabec + cTagOper + "/novaValidade/fimValid", 'C', .F., @aIncons, .F., '', '' ))		
		aNewData[2] := cNewDtFin
		cPerFin		:= cNewDtFin
		lNewValid	:= .T.
	EndIf			
EndIf

//Valida as regras da nova validade
If Empty(aIncons)
	VldEvTab( "C8V", 6, cChave, cPerIni, cPerFin, 2, nOpc,@aIncons, cPerIniOri, ,, lNewValid )
EndIf

If Empty(aIncons)
	
	Begin Transaction
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao para validar se a operacao desejada pode ser realizada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FTafVldOpe( "C8V", nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA235", cCmpsNoUpd, nIndIDVer, .T., aNewData )

			If TafColumnPos( "C8V_LOGOPE" )
				cLogOpeAnt := C8V->C8V_LOGOPE
			endif
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
			//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpc <> 5
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Carrego array com os campos De/Para de gravacao das informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRules := TAF235Rul(cTagOper, @cInconMsg, @nSeqErrGrv, cCodEvent, cOwner )
	
				oModel:LoadValue( "MODEL_C8V", "C8V_FILIAL", xFilial("C8V") )

				If TAFColumnPos( "C8V_XMLID" )
					oModel:LoadValue( "MODEL_C8V", "C8V_XMLID", cXmlID )
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Rodo o aRules para gravar as informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nI := 1 to Len( aRules )
				 	cValorXml := FTafGetVal( aRules[ nI, 02 ], aRules[nI, 03], aRules[nI, 04], @aIncons, .F., , aRules[ nI, 01 ] )
				 	oModel:LoadValue( "MODEL_C8V", aRules[ nI, 01 ], cValorXml)
				Next nI

				If Findfunction("TAFAltMan")
					if nOpc == 3
						TafAltMan( nOpc , 'Grv' , oModel, 'MODEL_C8V', 'C8V_LOGOPE' , '1', '' )
					elseif nOpc == 4
						TafAltMan( nOpc , 'Grv' , oModel, 'MODEL_C8V', 'C8V_LOGOPE' , '', cLogOpeAnt )
					EndIf
				endif

	 			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				// Cargo Publico 
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//Quando se trata de uma alteracao, deleto todas as linhas do Grid
			   	If nOpc == 4
					For nT10 := 1 to oModel:GetModel( 'MODEL_T10' ):Length()
						oModel:GetModel( 'MODEL_T10' ):GoLine(nT10)
						oModel:GetModel( 'MODEL_T10' ):DeleteLine()
					Next nT10
			 	EndIf
			 	
			 	//Rodo o XML parseado para gravar as novas informacoes no GRID
			  	nT10 := 1
			  	While oDados:XPathHasNode(cCabec + cTagOper + "/dadosCargo/cargoPublico[" + CVALTOCHAR(nT10)+ "]")
			  	  	If nOpc == 4 .Or. nT10 > 1
			  	  		oModel:GetModel( 'MODEL_T10' ):LVALID	:= .T.
						oModel:GetModel( 'MODEL_T10' ):AddLine()
		   	   		EndIf
		   	   		
		   	   		if oDados:XPathHasNode(cCabec + cTagOper + "/dadosCargo/cargoPublico[" + CVALTOCHAR(nT10)+ "]/acumCargo")
						oModel:LoadValue( "MODEL_T10", "T10_ACUMCG", FTafGetVal(cCabec + cTagOper + "/dadosCargo/cargoPublico[" + CVALTOCHAR(nT10)+ "]/acumCargo"  , "C", .F., @aIncons, .F. ))
					EndIf
					
					if oDados:XPathHasNode(cCabec + cTagOper + "/dadosCargo/cargoPublico[" + CVALTOCHAR(nT10)+ "]/contagemEsp")
						oModel:LoadValue( "MODEL_T10", "T10_CONESP", FTafGetVal(cCabec + cTagOper + "/dadosCargo/cargoPublico[" + CVALTOCHAR(nT10)+ "]/contagemEsp", "C", .F., @aIncons, .F. ))
					EndIf
					
					if oDados:XPathHasNode(cCabec + cTagOper + "/dadosCargo/cargoPublico[" + CVALTOCHAR(nT10)+ "]/dedicExcl")
						oModel:LoadValue( "MODEL_T10", "T10_DEDEXC", xFunTrcSN(FTafGetVal(cCabec + cTagOper + "/dadosCargo/cargoPublico[" + CVALTOCHAR(nT10)+ "]/dedicExcl"  , "C", .F., @aIncons, .F. ),2))
					EndIf
		 			
		 			//ÚÄÄÄÄÄÄÄÄÄÄ¿
					// Lei Cargo 
					//ÀÄÄÄÄÄÄÄÄÄÄÙ
					//Quando se trata de uma alteracao, deleto todas as linhas do Grid
				   	If nOpc == 4
						For nT11 := 1 to oModel:GetModel( 'MODEL_T11' ):Length()
							oModel:GetModel( 'MODEL_T11' ):GoLine(nT11)
							oModel:GetModel( 'MODEL_T11' ):DeleteLine()
						Next nT11
				 	EndIf
	
				 	//Rodo o XML parseado para gravar as novas informacoes no GRID
				  	nT11 := 1
					While oDados:XPathHasNode(cCabec + cTagOper + "/dadosCargo/cargoPublico[" + CVALTOCHAR(nT11)+ "]/leiCargo[" + CVALTOCHAR(nT11)+ "]")
						If nOpc == 4 .Or. nT11 > 1
							oModel:GetModel( 'MODEL_T11' ):LVALID := .T.
							oModel:GetModel( 'MODEL_T11' ):AddLine()
		    			EndIf
						
						if oDados:XPathHasNode(cCabec + cTagOper + "/dadosCargo/cargoPublico[" + CVALTOCHAR(nT11)+ "]/leiCargo[" + CVALTOCHAR(nT11)+ "]/nrLei")
							oModel:LoadValue( "MODEL_T11", "T11_NRLEI", FTafGetVal(cCabec + cTagOper + "/dadosCargo/cargoPublico[" + CVALTOCHAR(nT11)+ "]/leiCargo[" + CVALTOCHAR(nT11)+ "]/nrLei"   , "C" , .F., @aIncons, .F. ))
						EndIf
						
						if oDados:XPathHasNode(cCabec + cTagOper + "/dadosCargo/cargoPublico[" + CVALTOCHAR(nT11)+ "]/leiCargo[" + CVALTOCHAR(nT11)+ "]/dtLei"  )
							oModel:LoadValue( "MODEL_T11", "T11_DTLEI", FTafGetVal(cCabec + cTagOper + "/dadosCargo/cargoPublico[" + CVALTOCHAR(nT11)+ "]/leiCargo[" + CVALTOCHAR(nT11)+ "]/dtLei"   , "D" , .F., @aIncons, .F. ))
						EndIF
						
						if oDados:XPathHasNode(cCabec + cTagOper + "/dadosCargo/cargoPublico[" + CVALTOCHAR(nT11)+ "]/leiCargo[" + CVALTOCHAR(nT11)+ "]/sitCargo")
							oModel:LoadValue( "MODEL_T11", "T11_SITCGO", FTafGetVal(cCabec + cTagOper + "/dadosCargo/cargoPublico[" + CVALTOCHAR(nT11)+ "]/leiCargo[" + CVALTOCHAR(nT11)+ "]/sitCargo", "C", .F., @aIncons, .F. ))
						EndIf
						
						nT11++
					EndDo
	
					nT10++
		 		EndDo
			EndIf
	
			///ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
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
aRules := Nil

aSize( aChave, 0 )
aChave := Nil

Return{ lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF235Rul
Regras para gravacao das informacoes do registro S-1030 do E-Social

@Param
cTagOper - Tag de indicacao da operacao

@Return
aRull - Regras para a gravacao das informacoes

@author Felipe C. Seolin
@since 26/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF235Rul( cTagOper, cInconMsg, nSeqErrGrv, cCodEvent, cOwner )

Local aRull  := {}
Local cCabec := "/eSocial/evtTabCargo/infoCargo"

Default cTagOper		:= ""
Default cInconMsg		:= ""
Default nSeqErrGrv	:= 0
Default cCodEvent		:= ""
Default cOwner		:= ""

If TafXNode( oDados, cCodEvent, cOwner,( cCabec + cTagOper + "/ideCargo/codCargo" ) )
	aAdd( aRull, { "C8V_CODIGO", cCabec + cTagOper + "/ideCargo/codCargo", "C", .F., 'C8V' } ) //codCargo
EndIf

If TafXNode( oDados, cCodEvent, cOwner,(cCabec + cTagOper + "/dadosCargo/nmCargo" ) )
	aAdd( aRull, { "C8V_DESCRI", cCabec + cTagOper + "/dadosCargo/nmCargo", "C", .F., 'C8V' } ) //nmCargo
EndIf

If TafXNode( oDados, cCodEvent, cOwner,(cCabec + cTagOper + "/dadosCargo/codCBO" ) )
	aAdd( aRull, { "C8V_CODCBO", FGetIdInt( "codCBO", , cCabec + cTagOper + "/dadosCargo/codCBO",,,,@cInconMsg, @nSeqErrGrv ), "C", .T., 'C8V' } )	//codCBO
EndIf
							
Return( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF235Format

Formata os campos do registro S-1030 do E-Social

@Param
cCampo 	  - Campo que deve ser formatado
cValorXml - Valor a ser formatado

@Return
cFormatValue - Valor já formatado

@author Vitor Siqueira
@since 07/10/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF235Format(cCampo, cValorXml)

Local cFormatValue, cRet := ''

If (cCampo == 'C8V_DTINI' .OR. cCampo == 'C8V_DTFIN')
	cFormatValue := StrTran( StrTran( cValorXml, "-", "" ), "/", "")
	cRet := Substr(cFormatValue, 5, 2) + Substr(cFormatValue, 1,4)
Else
	cRet := cValorXml
EndIf

Return( cRet )

//-------------------------------------------------------------------


/*/{Protheus.doc} TAF235Xml

Funcao de geracao do XML para atender o registro S-1030
Quando a rotina for chamada o registro deve estar posicionado

@Param:
cAlias - Alias da Tabela
nRecno - Recno do Registro corrente
nOpc   - Operacao a ser realizada
lJob   - Informa se foi chamado por Job
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@Return:
cXml - Estrutura do Xml do Layout S-1030

@author Felipe C. Seolin
@since 23/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF235Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

Local cXml     := ""
Local cLayout  := "1030"
Local cReg     := "TabCargo"
Local cEvento  := ""
Local cDtIni   := ""
Local cDtFin   := ""
Local cId := ""
Local cVerAnt := ""
Local nRecnoSM0 := SM0->(Recno())

Default lJob := .F.
Default cSeqXml := ""

If C8V->C8V_EVENTO $ "I|A"

	If C8V->C8V_EVENTO == "A"
		cEvento := "alteracao"


		cId := C8V->C8V_ID 
		cVerAnt := C8V->C8V_VERANT
		
		BeginSql alias 'C8VTEMP'
			SELECT C8V.C8V_DTINI,C8V.C8V_DTFIN
			FROM %table:C8V% C8V
			WHERE C8V.C8V_FILIAL= %xfilial:C8V% AND
			C8V.C8V_ID = %exp:cId% AND C8V.C8V_VERSAO = %exp:cVerAnt% AND 
			C8V.%notDel%
		EndSql  
		
		//***********************************************************************************
		//Tratamento do formato da data (C8V_DTINI e C8V_DTFIN) para geração do XML de acordo 
		//com a nova fomulação do eSocial. Formato: AAAA-MM 
		//***********************************************************************************
		cDtIni := Substr(('C8VTEMP')->C8V_DTINI,3,4) +"-"+ Substr(('C8VTEMP')->C8V_DTINI,1,2)
		
		If ! Empty(('C8VTEMP')->C8V_DTFIN)
			cDtFin := Substr(('C8VTEMP')->C8V_DTFIN,3,4) +"-"+ Substr(('C8VTEMP')->C8V_DTFIN,1,2)
		EndIF
		//-----------

		
		('C8VTEMP')->( DbCloseArea() )

	Else
		cEvento := "inclusao"

	
		//***********************************************************************************
		//Tratamento do formato da data (C8V_DTINI e C8V_DTFIN) para geração do XML de acordo 
		//com a nova fomulação do eSocial. Formato: AAAA-MM 
		//***********************************************************************************
		cDtIni := Substr(C8V->C8V_DTINI,3,4) +"-"+ Substr(C8V->C8V_DTINI,1,2)
		
		if ! Empty(C8V->C8V_DTFIN)
			cDtFin := Substr(C8V->C8V_DTFIN,3,4) +"-"+ Substr(C8V->C8V_DTFIN,1,2)
		EndIF
		//-----------
		
	EndIf

	cXml +=			"<infoCargo>"
	cXml +=				"<" + cEvento + ">"
	cXml +=					"<ideCargo>"
	cXml +=						xTafTag("codCargo",C8V->C8V_CODIGO)
	cXml +=						xTafTag("iniValid",cDtIni)
	cXml +=						xTafTag("fimValid",cDtFin,,.T.)
	cXml +=					"</ideCargo>"
	cXml +=					"<dadosCargo>"
	cXml +=						xTafTag("nmCargo",C8V->C8V_DESCRI)
	cXml +=						xTafTag("codCBO",Posicione("C8Z",1,xFilial("C8Z")+C8V->C8V_CODCBO,"C8Z_CODIGO"))
	
	T10->(DbSetOrder(1))
	If T10->(MsSeek(xFilial("T10") + C8V->C8V_ID + C8V->C8V_VERSAO))	

		cXml +=						"<cargoPublico>"
		cXml +=							xTafTag("acumCargo",T10->T10_ACUMCG)
		cXml +=							xTafTag("contagemEsp",T10->T10_CONESP)
		cXml +=							xTafTag("dedicExcl",xFunTrcSN(T10->T10_DEDEXC,1))
		T11->(DbSetOrder(1))
		If T11->(MsSeek(xFilial("T11") + T10->T10_ID + T10->T10_VERSAO + T10->T10_ACUMCG))	
			cXml +=							"<leiCargo>"
			cXml +=								xTafTag("nrLei",T11->T11_NRLEI)
			cXml +=								xTafTag("dtLei",T11->T11_DTLEI)	
			cXml +=								xTafTag("sitCargo",T11->T11_SITCGO)
			cXml +=							"</leiCargo>"
		EndIf
	
		cXml +=						"</cargoPublico>"
	EndIf
	
	cXml +=					"</dadosCargo>"

	If C8V->C8V_EVENTO == "A"
		If TafAtDtVld("C8V", C8V->C8V_ID, C8V->C8V_DTINI, C8V->C8V_DTFIN, C8V->C8V_VERANT)
			cXml +=				"<novaValidade>"
			cXml +=					TafGetDtTab(C8V->C8V_DTINI,C8V->C8V_DTFIN)
			cXml +=				"</novaValidade>"
		EndIf
	EndIf

	cXml +=				"</" + cEvento + ">"
	cXml +=			"</infoCargo>"

ElseIf C8V->C8V_EVENTO == "E"



	cXml +=			"<infoCargo>"
	cXml +=				"<exclusao>"
	cXml +=					"<ideCargo>"
	cXml +=						xTafTag("codCargo",C8V->C8V_CODIGO)
	cxml += 					TafGetDtTab(C8V->C8V_DTINI,C8V->C8V_DTFIN)
	cXml +=					"</ideCargo>"
	cXml +=				"</exclusao>"
	cXml +=			"</infoCargo>"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do cabecalho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nRecnoSM0 > 0
	SM0->(dbGoto(nRecnoSM0))
endif
cXml := xTafCabXml(cXml,"C8V",cLayout,cReg,,cSeqXml)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa gravacao do registro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	xTafGerXml(cXml,cLayout)
EndIf

Return(cXml)
