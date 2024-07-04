#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA236.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA236

Cadastro de Funções

@author Anderson Costa
@since 20/08/2013
@version 1.0
/*/ 
//-------------------------------------------------------------------
Function TAFA236()

	Private oBrw := FWmBrowse():New()

	If FindFunction("TAFDesEven")
		TAFDesEven()
	EndIf

	oBrw:SetDescription(STR0001) //"Cadastro de Funções"
	oBrw:SetAlias( "C8X" )
	oBrw:SetMenuDef( "TAFA236" )
	oBrw:SetFilterDefault( "C8X_ATIVO == '1' .Or. (C8X_EVENTO == 'E' .And. C8X_STATUS = '4' .And. C8X_ATIVO = '2')" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )
	oBrw:AddLegend( "C8X_EVENTO == 'I' ", "GREEN" , STR0012 ) //"Registro Incluído"
	oBrw:AddLegend( "C8X_EVENTO == 'A' ", "YELLOW", STR0013 ) //"Registro Alterado"
	oBrw:AddLegend( "C8X_EVENTO == 'E' .And. C8X_STATUS <> '4' ", "RED"   , STR0014 ) //	
	oBrw:AddLegend( "C8X_EVENTO == 'E' .And. C8X_STATUS == '4' .And. C8X_ATIVO = '2' ", "BLACK"   , STR0015 ) //"Registro excluído não transmitido"

	oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Anderson Costa
@since 20/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aFuncao := {}
Local aRotina := {}
If FindFunction('TafXmlRet')
	Aadd( aFuncao, { "" , "TafxmlRet('TAF236Xml','1040','C8X')" , "1" } )
Else
	Aadd( aFuncao, { "" , "TAF236Xml" , "1" } )
EndIf
Aadd( aFuncao, { "" , "xFunHisAlt( 'C8X', 'TAFA236',,,,'TAF236XML','1040'  )" , "3" } )
aAdd( aFuncao, { "" , "TAFXmlLote( 'C8X', 'S-1040' , 'evtTabFuncao' , 'TAF236Xml',,oBrw )" , "5" } )
Aadd( aFuncao, { "" , "xFunAltRec( 'C8X' )" , "10" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif .Or. ViewEvent('S-1040')
	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA236' OPERATION 2 ACCESS 0
Else
	aRotina	:=	xFunMnuTAF( "TAFA236" , , aFuncao)
EndIf

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Anderson Costa
@since 20/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC8X := FWFormStruct( 1, 'C8X' )
Local oModel   := MPFormModel():New( 'TAFA236' , , , {|oModel| SaveModel( oModel ) } )

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

If lVldModel
	oStruC8X:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf

oModel:AddFields('MODEL_C8X', /*cOwner*/, oStruC8X)
oModel:GetModel('MODEL_C8X'):SetPrimaryKey({'C8X_FILIAL', 'C8X_CODIGO', 'C8X_DTINI', 'C8X_DTFIN'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Anderson Costa
@since 20/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel( 'TAFA236' )
Local oStruC8X := FWFormStruct( 2, 'C8X' )
Local oView    := FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C8X', oStruC8X, 'MODEL_C8X' )

oView:EnableTitleView( 'VIEW_C8X', STR0001 )    //"Cadastro de Funções"
oView:CreateHorizontalBox( 'FIELDSC8X', 100 )
oView:SetOwnerView( 'VIEW_C8X', 'FIELDSC8X' )

If FindFunction("TafAjustRecibo")
	TafAjustRecibo(oStruC8X,"C8X")
EndIf

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If !lMenuDif
	xFunRmFStr(@oStruC8X, 'C8X')
EndIf

If TafColumnPos( "C8X_LOGOPE" )
	oStruC8X:RemoveField( "C8X_LOGOPE" )
EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF236Grv
@type			function
@description	Função de gravação para atender o registro S-1040 ( Tabela de Funções ).
@author			Anderson Costa
@since			04/10/2013
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
Function TAF236Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

Local cLogOpeAnt	:=	""
Local cCabec		:=	"/eSocial/evtTabFuncao/infoFuncao"
Local cCmpsNoUpd	:=	"|C8X_FILIAL|C8X_ID|C8X_VERSAO|C8X_DTINI|C8X_DTFIN|C8X_VERANT|C8X_PROTUL|C8X_PROTPN|C8X_EVENTO|C8X_STATUS|C8X_ATIVO|"
Local cValChv		:=	""
Local cNewDtIni		:=	""
Local cNewDtFin		:=	""
Local cValorXml		:=	""
Local cInconMsg		:=	""
Local cCodEvent		:=	Posicione( "C8E", 2, xFilial( "C8E" ) + "S-" + cLayout, "C8E->C8E_ID" )
Local cChave		:=	""
Local cPerIniOri	:=	""
Local cPerFin		:=	""
Local nIndChv		:=	2
Local nIndIDVer		:=	1
Local nlI			:=	0
Local nSeqErrGrv	:=	0
Local nTamCod		:=	TamSX3( "C8X_CODIGO" )[1]
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
cValChv := FTafGetVal( cCabec + cTagOper + "/ideFuncao/codFuncao", 'C', .F., @aIncons, .F., '', '' )
If !Empty( cValChv )
	Aadd( aChave, { "C", "C8X_CODIGO", cValChv, .T.} )
	nIndChv := 4
	cChave += Padr(cValChv,nTamCod)
EndIf

//Verificar se a data inicial foi informado para a chave( Se nao informado sera adotada a database internamente )
cValChv := FTafGetVal( cCabec + cTagOper + "/ideFuncao/iniValid", 'C', .F., @aIncons, .F., '', '' )
cValChv := TAF236Format("C8X_DTINI", cValChv)
If !Empty( cValChv )
	Aadd( aChave, { "C", "C8X_DTINI", cValChv, .T. } )
	nIndChv := 5
	cPerIni := cValChv
	cPerIniOri := cValChv
EndIf

//Verificar se a data final foi informado para a chave( Se nao informado sera adotado vazio )
cValChv := FTafGetVal( cCabec + cTagOper + "/ideFuncao/fimValid", 'C', .F., @aIncons, .F., '', '' )
cValChv := TAF236Format("C8X_DTFIN", cValChv)
If !Empty( cValChv )
	Aadd( aChave, { "C", "C8X_DTFIN", cValChv, .T.} )
	nIndChv := 2
	cPerFin := cValChv 
EndIf

If nOpc == 4	
	If oDados:XPathHasNode( cCabec + cTagOper + "/novaValidade/iniValid", 'C', .F., @aIncons, .F., '', ''  )
		cNewDtIni 	:= TAF236Format("C8X_DTINI", FTafGetVal( cCabec + cTagOper + "/novaValidade/iniValid", 'C', .F., @aIncons, .F., '', '' ))	
		aNewData[1] := cNewDtIni
		lNewValid	:= .T.
	EndIf

	If oDados:XPathHasNode( cCabec + cTagOper + "/novaValidade/fimValid", 'C', .F., @aIncons, .F., '', ''  )
		cNewDtFin 	:= TAF236Format("C8X_DTFIN", FTafGetVal( cCabec + cTagOper + "/novaValidade/fimValid", 'C', .F., @aIncons, .F., '', '' ))
		aNewData[2] := cNewDtFin
		lNewValid	:= .T.
	EndIf
EndIf

//Valida as regras da nova validade
If Empty(aIncons)
	VldEvTab( "C8X", 5, cChave, cPerIni, cPerFin, 2, nOpc, @aIncons, cPerIniOri,,, lNewValid ) 
EndIf

If Empty(aIncons)

	Begin Transaction											
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao para validar se a operacao desejada pode ser realizada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FTafVldOpe( "C8X", nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA236", cCmpsNoUpd, nIndIDVer, .T., aNewData )

			If TafColumnPos( "C8X_LOGOPE" )
				cLogOpeAnt := C8X->C8X_LOGOPE
			endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
			//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpc <> 5 
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Carrego array com os campos De/Para de gravacao das informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRules := TAF236Rul( cTagOper, @cInconMsg, @nSeqErrGrv, cCodEvent, cOwner )
	
			   	oModel:LoadValue( "MODEL_C8X", "C8X_FILIAL", C8X->C8X_FILIAL )

				If TAFColumnPos( "C8X_XMLID" )
					oModel:LoadValue( "MODEL_C8X", "C8X_XMLID", cXmlID )
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Rodo o aRules para gravar as informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nlI := 1 To Len( aRules )                 					
				 	cValorXml := FTafGetVal( aRules[ nlI, 02 ], aRules[nlI, 03], aRules[nlI, 04], @aIncons, .F., , aRules[ nlI, 01 ] )
				 	oModel:LoadValue( "MODEL_C8X", aRules[ nlI, 01 ], cValorXml )
				Next			        							

				If Findfunction("TAFAltMan")
					if nOpc == 3
						TafAltMan( nOpc , 'Grv' , oModel, 'MODEL_C8X', 'C8X_LOGOPE' , '1', '' )
					elseif nOpc == 4
						TafAltMan( nOpc , 'Grv' , oModel, 'MODEL_C8X', 'C8X_LOGOPE' , '', cLogOpeAnt )
					EndIf
				endif
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
 
Return { lRet, aIncons } 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF236Rul           

Regras para gravacao das informacoes do registro S-1040 do E-Social

@Param
cTagOper - Tag de indicacao da operacao

@Return	
aRull  - Regras para a gravacao das informacoes

@author Anderson Costa
@since 04/10/2013
@version 1.0

/*/                        	
//-------------------------------------------------------------------
Static Function TAF236Rul( cTagOper, cInconMsg, nSeqErrGrv, cCodEvent, cOwner )

Local aRull  := {}
Local cCabec := "/eSocial/evtTabFuncao/infoFuncao"

Default cTagOper		:= ""
Default cInconMsg		:= ""
Default nSeqErrGrv	:= 0
Default cCodEvent		:= ""
Default cOwner		:= ""

if TafXNode(oDados , cCodEvent, cOwner,(cCabec + cTagOper + "/ideFuncao/codFuncao"))
	aAdd( aRull, { "C8X_CODIGO", cCabec + cTagOper + "/ideFuncao/codFuncao"   , "C", .F. } ) //codFuncao
EndIf

if TafXNode(oDados , cCodEvent, cOwner,(cCabec + cTagOper + "/dadosFuncao/dscFuncao"))
	aAdd( aRull, { "C8X_DESCRI", cCabec + cTagOper + "/dadosFuncao/dscFuncao", "C", .F. } ) //dscFuncao
EndIf

if TafXNode(oDados , cCodEvent, cOwner,(cCabec + cTagOper + "/dadosFuncao/codCBO"))
	aAdd( aRull, { "C8X_CODCBO", FGetIdInt( "codCBO", , cCabec + cTagOper + "/dadosFuncao/codCBO",,,,@cInconMsg, @nSeqErrGrv), "C", .T. } ) //codCBO
EndIf

Return( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF236Format

Formata os campos do registro S-1040 do E-Social

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
Static Function TAF236Format(cCampo, cValorXml)

Local cFormatValue, cRet := ''

If (cCampo == 'C8X_DTINI' .OR. cCampo == 'C8X_DTFIN')
	cFormatValue := StrTran( StrTran( cValorXml, "-", "" ), "/", "")
	cRet := Substr(cFormatValue, 5, 2) + Substr(cFormatValue, 1, 4)
Else
	cRet := cValorXml
EndIf

Return( cRet )

//-------------------------------------------------------------------
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
Static Function SaveModel( oModel )

Local cLogOpe		
Local cLogOpeAnt	
Local cVerAnt		:= ""
Local cProtocolo	:= ""
Local cEvento		:= ""
Local cVersao		:= ""
Local cChvRegAnt	:= ""
Local nOperation	:= oModel:GetOperation()
Local nC8X			:= 0
Local aGrava		:= {}
Local oModelC8X		:= Nil
Local lRetorno		:= .T.

cLogOpe		:= ""
cLogOpeAnt	:= ""

Begin Transaction

	If nOperation == MODEL_OPERATION_INSERT
	
		TafAjustID( "C8X", oModel)
	
		oModel:LoadValue( "MODEL_C8X", "C8X_VERSAO", xFunGetVer() )

		If Findfunction("TAFAltMan")
			TafAltMan( 3 , 'Save' , oModel, 'MODEL_C8X', 'C8X_LOGOPE' , '2', '' )
		endif

		FwFormCommit( oModel )

	ElseIf nOperation == MODEL_OPERATION_UPDATE .or. nOperation == MODEL_OPERATION_DELETE

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seek para posicionar no registro antes de realizar as validacoes,³
		//³visto que quando nao esta posicionado nao eh possivel analisar   ³
		//³os campos nao usados como _STATUS                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    C8X->( DbSetOrder( 3 ) )
	    If C8X->( MsSeek( xFilial( 'C8X' ) + FwFldGet('C8X_ID') + '1' ) )
	    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o registro ja foi transmitido³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If C8X->C8X_STATUS == "4" 
	
				oModelC8X := oModel:GetModel( "MODEL_C8X" )
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Busco a versao anterior do registro para gravacao do rastro³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cVerAnt    := oModelC8X:GetValue( "C8X_VERSAO" )
				cProtocolo := oModelC8X:GetValue( "C8X_PROTUL" )
				cEvento    := oModelC8X:GetValue( "C8X_EVENTO" )
		
				If TafColumnPos( "C8X_LOGOPE" )
					cLogOpeAnt := oModelC8X:GetValue( "C8X_LOGOPE" )	
				endif

				If nOperation == MODEL_OPERATION_DELETE .And. cEvento == "E" 
					// Não é possível excluir um evento de exclusão já transmitido
					TAFMsgVldOp(oModel,"4")
					lRetorno := .F.
				Else
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu gravo as informacoes que foram carregadas na tela³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nC8X := 1 to Len( oModelC8X:aDataModel[ 1 ] )
						aAdd( aGrava, { oModelC8X:aDataModel[ 1, nC8X, 1 ], oModelC8X:aDataModel[ 1, nC8X, 2 ] } )
					Next nC8X

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seto o campo como Inativo e gravo a versao do novo registro³
					//³no registro anterior                                       ³
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FAltRegAnt( 'C8X', '2' ,.F.,FwFldGet("C8X_DTFIN"),FwFldGet("C8X_DTINI"),C8X->C8X_DTINI )
		
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

					For nC8X := 1 to Len( aGrava )
						oModel:LoadValue( "MODEL_C8X", aGrava[ nC8X, 1 ], aGrava[ nC8X, 2 ] )
					Next nC8X

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu realizo a inclusao do novo registro ja³
					//³contemplando as informacoes alteradas pelo usuario     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nC8X := 1 to Len( aGrava )
						oModel:LoadValue( "MODEL_C8X", aGrava[ nC8X, 1 ], aGrava[ nC8X, 2 ] )
					Next nC8X
					
					//Necessário Abaixo do For Nao Retirar
					If Findfunction("TAFAltMan")
						TafAltMan( 4 , 'Save' , oModel, 'MODEL_C8X', 'C8X_LOGOPE' , '' , cLogOpeAnt )
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
					oModel:LoadValue( "MODEL_C8X", "C8X_VERSAO", cVersao )
					oModel:LoadValue( "MODEL_C8X", "C8X_VERANT", cVerAnt )
					oModel:LoadValue( "MODEL_C8X", "C8X_PROTPN", cProtocolo )
					oModel:LoadValue( "MODEL_C8X", "C8X_PROTUL", "" )
					// Tratamento para limpar o ID unico do xml
					cAliasPai := "C8X"
					If TAFColumnPos( cAliasPai+"_XMLID" )
						oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					EndIf

					If nOperation == MODEL_OPERATION_DELETE
						oModel:LoadValue( 'MODEL_C8X', 'C8X_EVENTO', "E" )
					ElseIf cEvento == "E"
						oModel:LoadValue( 'MODEL_C8X', 'C8X_EVENTO', "I" )
					Else
						oModel:LoadValue( 'MODEL_C8X', 'C8X_EVENTO', "A" )
					EndIf

					FwFormCommit( oModel )
				EndIf
			
			Elseif C8X->C8X_STATUS == "2"
				//Não é possível alterar um registro com aguardando validação
				TAFMsgVldOp(oModel,"2")
				lRetorno := .F. 			
			
			Else
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso o registro nao tenha sido transmitido ainda, gravo sua chave³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cChvRegAnt := C8X->( C8X_ID + C8X_VERANT )

				If TafColumnPos( "C8X_LOGOPE" )
					cLogOpeAnt := C8X->C8X_LOGOPE
				endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³No caso de um evento de Exclusao deve-se perguntar ao usuario se ele realmente deseja realizar a exclusao.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If C8X->C8X_EVENTO == "E"
					If nOperation == MODEL_OPERATION_DELETE
						If Aviso( xValStrEr("000754"), xValStrEr("000755"), { xValStrEr("000756"), xValStrEr("000757") }, 1 ) == 2 //##"Registro Excluído" ##"O Evento de exclusão não foi transmitido. Deseja realmente exclui-lo ou manter o evento de exclusão para transmissão posterior ?" ##"Excuir" ##"Manter"
								cChvRegAnt := ""
						EndIf
					Else
						oModel:LoadValue( "MODEL_C8X", "C8X_EVENTO", "A" )
					EndIf
				EndIf
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Executo a operacao escolhida³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty( cChvRegAnt )
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Funcao responsavel por setar o Status do registro para Branco³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					TAFAltStat( "C8X", " " )

					If nOperation == MODEL_OPERATION_UPDATE .And. Findfunction("TAFAltMan")
						TafAltMan( 4 , 'Save' , oModel, 'MODEL_C8X', 'C8X_LOGOPE' , '' , cLogOpeAnt )
					endif

					FwFormCommit( oModel )
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Caso a operacao seja uma exclusao...³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nOperation == MODEL_OPERATION_DELETE
						//Funcao para setar o registro anterior como Ativo
						TAFRastro( "C8X", 1, cChvRegAnt, .T. , , IIF(Type("oBrw") == "U", Nil, oBrw) )
					EndIf
	
				EndIf
	
			EndIf 
		Elseif TafIndexInDic("C8X", 6, .T.)

			C8X->( DbSetOrder( 6 ) )
	    	If C8X->( MsSeek( xFilial( 'C8X' ) + FwFldGet('C8X_ID')+ 'E42' ) ) 

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
/*/{Protheus.doc} TAF236Xml
Funcao de geracao do XML para atender o registro S-1040
Quando a rotina for chamada o registro deve estar posicionado

@Param:
cAlias - Alias corrente (Parametro padrao MVC)
nRecno - Recno corrente (Parametro padrao MVC)
nOpc   - Opcao selecionada (Parametro padrao MVC)
lJob   - Informa se foi chamado por Job
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@Return:
cXml - Estrutura do Xml do Layout S-1040

@author Anderson Costa
@since 04/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF236Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

Local cXml     := ""
Local cLayout  := "1040"
Local cReg     := "TabFuncao"
Local cEvento  := ""
Local cDtIni   := ""
Local cDtFin   := ""

Local cId := ""
Local cVerAnt := ""

Default lJob   := .F.
Default cSeqXml := ""

If C8X->C8X_EVENTO $ "I|A"

	If C8X->C8X_EVENTO == "A"
		cEvento := "alteracao"

		cId := C8X->C8X_ID 
		cVerAnt := C8X->C8X_VERANT
		
		BeginSql alias 'C8XTEMP'
			SELECT C8X.C8X_DTINI,C8X.C8X_DTFIN
			FROM %table:C8X% C8X
			WHERE C8X.C8X_FILIAL= %xfilial:C8X% AND
			C8X.C8X_ID = %exp:cId% AND C8X.C8X_VERSAO = %exp:cVerAnt% AND 
			C8X.%notDel%
		EndSql
		
		//***********************************************************************************
		//Tratamento do formato da data (C8X_DTINI e C8X_DTFIN) para geração do XML de acordo 
		//com a nova fomulação do eSocial. Formato: AAAA-MM 
		//***********************************************************************************
		cDtIni := Substr(('C8XTEMP')->C8X_DTINI,3,4) +"-"+ Substr(('C8XTEMP')->C8X_DTINI,1,2)
		
		If ! Empty(('C8XTEMP')->C8X_DTFIN)
			cDtFin := Substr(('C8XTEMP')->C8X_DTFIN,3,4) +"-"+ Substr(('C8XTEMP')->C8X_DTFIN,1,2)
		EndIF
		//-----------
		
		('C8XTEMP')->( DbCloseArea() )
	Else
		cEvento := "inclusao"

		//***********************************************************************************
		//Tratamento do formato da data (C8X_DTINI e C8X_DTFIN) para geração do XML de acordo 
		//com a nova fomulação do eSocial. Formato: AAAA-MM 
		//***********************************************************************************
		cDtIni := Substr(C8X->C8X_DTINI,3,4) +"-"+ Substr(C8X->C8X_DTINI,1,2)
		
		if ! Empty(C8X->C8X_DTFIN)
			cDtFin := Substr(C8X->C8X_DTFIN,3,4) +"-"+ Substr(C8X->C8X_DTFIN,1,2)
		EndIF
		//-----------
	EndIf

	cXml +=			"<infoFuncao>"
	cXml +=				"<" + cEvento + ">"
	cXml +=					"<ideFuncao>"
	cXml +=						xTafTag("codFuncao",C8X->C8X_CODIGO)
	cXml +=						xTafTag("iniValid",cDtIni)	
	cXml +=						xTafTag("fimValid",cDtFin,,.T.)
	cXml +=					"</ideFuncao>"
	cXml +=					"<dadosFuncao>"
	cXml +=						xTafTag("dscFuncao",FwCutOff(C8X->C8X_DESCRI, .T.))
	cXml +=						xTafTag("codCBO",Posicione("C8Z",1,xFilial("C8Z")+C8X->C8X_CODCBO,"C8Z_CODIGO"))
	cXml +=					"</dadosFuncao>"
	
	If C8X->C8X_EVENTO == "A"
		If TafAtDtVld("C8X", C8X->C8X_ID, C8X->C8X_DTINI, C8X->C8X_DTFIN, C8X->C8X_VERANT, .T.)
			cXml +=			"<novaValidade>"
			cXml +=				TafGetDtTab(C8X->C8X_DTINI,C8X->C8X_DTFIN)		
			cXml +=			"</novaValidade>"
		EndIf
	EndIf
	cXml +=				"</" + cEvento + ">"
	cXml +=			"</infoFuncao>"

ElseIf C8X->C8X_EVENTO == "E"
	cXml +=			"<infoFuncao>"
	cXml +=				"<exclusao>"
	cXml +=					"<ideFuncao>"
	cXml +=						xTafTag("codFuncao",C8X->C8X_CODIGO)
	cXml +=						TafGetDtTab(C8X->C8X_DTINI,C8X->C8X_DTFIN)
	cXml +=					"</ideFuncao>"
	cXml +=				"</exclusao>"
	cXml +=			"</infoFuncao>"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do cabecalho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cXml := xTafCabXml(cXml,"C8X",cLayout,cReg,,cSeqXml)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa gravacao do registro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	xTafGerXml(cXml,cLayout)
EndIf

Return(cXml)
