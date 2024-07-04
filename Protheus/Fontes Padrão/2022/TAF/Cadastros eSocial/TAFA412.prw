#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA412.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA412
Cadastro MVC de Contribuição Sindical Patronal - S-1300
 
@author Daniel Schmidt 
@since 07/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA412()

	Private	oBrw := FWmBrowse():New()

	If FindFunction("TAFDesEven")
		TAFDesEven()
	EndIf

	oBrw:SetDescription( STR0001 )	//"Contribuição Sindical Patronal"
	oBrw:SetAlias( 'T3Z')
	oBrw:SetMenuDef( 'TAFA412' )	

	If FindFunction('TAFSetFilter')
		oBrw:SetFilterDefault(TAFBrwSetFilter("T3Z","TAFA412","S-1300"))
	Else
		oBrw:SetFilterDefault( "T3Z_ATIVO == '1'" )
	EndIf

	TafLegend(2,"T3Z",@oBrw)
	oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Daniel Schmidt 
@since 07/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao := {}
	Local aRotina := {}

	Aadd( aFuncao, { "" , "TafxmlRet('TAF412Xml','1300','T3Z')" 									, "1" } )
	Aadd( aFuncao, { "" , "xFunAltRec( 'T3Z' )" 													, "10"} )
	Aadd( aFuncao, { "" , "xNewHisAlt( 'T3Z', 'TAFA412' ,,,,,,'1300','TAF412Xml' )" 				, "3" } )
	Aadd( aFuncao, { "" , "TAFXmlLote( 'T3Z', 'S-1300' , 'evtContrSindPatr' , 'TAF412Xml',, oBrw )" , "5" } )

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If lMenuDif .Or. ViewEvent('S-1300')

		ADD OPTION aRotina Title STR0002 Action "VIEWDEF.TAFA412" OPERATION 2 ACCESS 0 //"Visualizar"

		If !ViewEvent('S-1300')    
			aRotina	:= xMnuExtmp( "TAFA412", "T3Z", .F. )
		EndIf
		
	Else
		aRotina := xFunMnuTAF( "TAFA412" , , aFuncao)
	EndIf

Return( aRotina )

//------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Daniel Schmidt 
@since 07/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruT3Z
	Local oStruT2L
	LocaL oModel

	oStruT3Z := FWFormStruct( 1, 'T3Z' )
	oStruT2L := FWFormStruct( 1, 'T2L' )
	oModel   := MPFormModel():New('TAFA412', , , {|oModel| SaveModel( oModel ) })

	//Remoção do GetSX8Num quando se tratar da Exclusão de um Evento Transmitido.
	//Necessário para não incrementar ID que não será utilizado.
	If Upper( ProcName( 2 ) ) == Upper( "GerarExclusao" )
		oStruT3Z:SetProperty( "T3Z_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )
	EndIf

	// Adiciona ao modelo um componente de formulário
	oModel:AddFields("MODEL_T3Z",/*cOwner*/,oStruT3Z)
	oModel:GetModel("MODEL_T3Z"):SetPrimaryKey({"T3Z_FILIAL","T3Z_ID","T3Z_VERSAO"})

	//Modelo de estabelecimento adquirente
	oModel:AddGrid('MODEL_T2L', 'MODEL_T3Z', oStruT2L)
	oModel:GetModel('MODEL_T2L'):SetOptional(.T.)
	oModel:GetModel('MODEL_T2L'):SetUniqueLine({'T2L_CNPJSD', 'T2L_TPCONT'})
	oModel:GetModel('MODEL_T2L'):SetMaxLine(999)

	oModel:SetRelation('MODEL_T2L', {{'T2L_FILIAL' , 'xFilial( "T2L" )'}, {'T2L_ID' , 'T3Z_ID'}, {'T2L_VERSAO' , 'T3Z_VERSAO'}, {'T2L_INDAPU' , 'T3Z_INDAPU'}, {'T2L_PERAPU' , 'T3Z_PERAPU'}}, T2L->(IndexKey(1)))

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Daniel Schmidt 
@since 07/01/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel             := FWLoadModel( 'TAFA412' )
	Local oStruT3Za          := Nil
	Local oStruT3Zb          := Nil
	Local oStruT3Zc          := Nil
	Local oStruT2L           := FWFormStruct( 2, 'T2L' )
	Local oView              := FWFormView():New()
	Local cCmpFil            := ''
	Local nI                 := 0
	Local aCmpGrp            := {}
	Local cGrpCom1, cGrpCom2 := ""

	oView:SetModel( oModel )

	//Informações de Apuração
	cGrpCom1  := 'T3Z_ID|T3Z_VERSAO|T3Z_VERANT|T3Z_PROTPN|T3Z_EVENTO|T3Z_ATIVO|T3Z_INDAPU|T3Z_PERAPU|'
	cCmpFil   := cGrpCom1 
	oStruT3Za := FwFormStruct( 2, 'T3Z', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	//"Protocolo de Transmissão"
	cGrpCom2 := 'T3Z_PROTUL|'
	cCmpFil   := cGrpCom2
	oStruT3Zb := FwFormStruct( 2, 'T3Z', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	If TafColumnPos("T3Z_DTRANS")
		cCmpFil := "T3Z_DINSIS|T3Z_DTRANS|T3Z_HTRANS|T3Z_DTRECP|T3Z_HRRECP|"
		oStruT3Zc := FwFormStruct( 2, 'T3Z', {|x| AllTrim( x ) + "|" $ cCmpFil } )
	EndIf

	/*-----------------------------------------------------------------------------------
					Grupo de campos da Aquisição de Produção Rural
	-------------------------------------------------------------------------------------*/
	oStruT3Za:AddGroup( "GRP_CONTRIBUICAO", STR0006, "", 1 ) //Informações de Apuração 

	aCmpGrp := StrToKArr(cGrpCom1,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruT3Za:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_CONTRIBUICAO")
	Next nI

	If FindFunction('TafAjustRecibo')
		TafAjustRecibo(oStruT3Zb,"T3Z")
	EndIf 

	/*--------------------------------------------------------------------------------------------
										Esrutura da View
	---------------------------------------------------------------------------------------------*/
	oView:AddField( 'VIEW_T3Za', oStruT3Za, 'MODEL_T3Z' )

	oView:AddField( 'VIEW_T3Zb', oStruT3Zb, 'MODEL_T3Z' )

	If FindFunction('TafNmFolder')	
		oView:EnableTitleView( 'VIEW_T3Zb', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"  
	Endif 
	If TafColumnPos("T3Z_DTRANS")
		oView:AddField( 'VIEW_T3Zc', oStruT3Zc, 'MODEL_T3Z' )
		oView:EnableTitleView( 'VIEW_T3Zc', TafNmFolder("recibo",2) )
	EndIf

	oView:AddGrid(  'VIEW_T2L', oStruT2L, 'MODEL_T2L' )
	oView:EnableTitleView( 'VIEW_T2L', STR0007 ) //"Estabelecimento Adquirinte"

	/*-----------------------------------------------------------------------------------
									Estrutura do Folder
	-------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox("PAINEL_SUPERIOR",100)
	oView:CreateFolder("FOLDER_SUPERIOR","PAINEL_SUPERIOR")

	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0001 )   //"Informação de Aquisição de Produção Rural"

	If FindFunction('TafNmFolder')	
		oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', TafNmFolder("recibo") )   //"Numero do Recibo"
	Else
		oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0005 )   //"Protocolo de Transmissão"
	EndIf 

	oView:CreateHorizontalBox( 'T3Za',  020,,, 'FOLDER_SUPERIOR', 'ABA01' )
	oView:CreateHorizontalBox( 'T2L' ,  080,,, 'FOLDER_SUPERIOR', 'ABA01' )
	If TafColumnPos("T3Z_DTRANS")
		oView:CreateHorizontalBox( 'T3Zb',  20,,, 'FOLDER_SUPERIOR', 'ABA02' )
		oView:CreateHorizontalBox( 'T3Zc',  80,,, 'FOLDER_SUPERIOR', 'ABA02' )
	Else
		oView:CreateHorizontalBox( 'T3Zb',  100,,, 'FOLDER_SUPERIOR', 'ABA02' )
	EndIf

	oView:SetOwnerView( "VIEW_T3Za", "T3Za")
	oView:SetOwnerView( "VIEW_T3Zb", "T3Zb")
	If TafColumnPos("T3Z_DTRANS")
		oView:SetOwnerView( "VIEW_T3Zc", "T3Zc")
	EndIf
	oView:SetOwnerView( "VIEW_T2L",  "T2L" )


	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If !lMenuDif
		xFunRmFStr(@oStruT3Za, 'T3Z')
	EndIf

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo
	
@Param  oModel -> Modelo de dados

@Return .T.

@author Daniel Schmidt 
@since 07/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )
	
	Local cVerAnt
	Local cProtocolo
	Local cVersao
	Local cChvRegAnt
	Local cEvento
	Local cLogOpe
	Local cLogOpeAnt
	Local nOperation
	Local nI
	Local nT2L
	Local aCampos
	Local aGrava
	Local aGravaT2L
	Local oModelT3Z
	Local oModelT2L
	Local lRetorno

	cVerAnt    := ""
	cProtocolo := ""
	cVersao    := ""
	cChvRegAnt := ""
	cEvento    := ""
	cLogOpe    := ""
	cLogOpeAnt := ""
	nOperation := oModel:GetOperation()
	nI         := 0
	nT2L       := 0
	aCampos    := {}
	aGrava     := {}
	aGravaT2L  := {}
	oModelT3Z  := Nil
	oModelT2L  := Nil
	lRetorno   := .T.

	Begin Transaction

		//Inclusao Manual do Evento
		If nOperation == MODEL_OPERATION_INSERT

		TafAjustID( "T3Z", oModel)

			oModel:LoadValue( "MODEL_T3Z", "T3Z_VERSAO", xFunGetVer() )

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_T3Z', 'T3Z_LOGOPE' , '2', '' )
			Endif

			FwFormCommit( oModel )

		//Alteração Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_UPDATE 

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//Posicionando no registro para que nao ocorra erros duranteo processo de validação
			T3Z->( DbSetOrder( 4 ) )
			If T3Z->( MsSeek( xFilial( 'T3Z' ) + T3Z->T3Z_ID + '1' ) )		
				
				//Verifica se o evento ja foi trasmitido ao RET
				If T3Z->T3Z_STATUS $ ( "4" )	    		
					
					//Carrego a Estrutura dos Models a serem gravados
					oModelT3Z := oModel:GetModel( "MODEL_T3Z" )
					oModelT2L := oModel:GetModel( "MODEL_T2L" )				
					
					//Guardo as informações do registro corrente para rastro do registro
					cVerAnt     	:= oModelT3Z:GetValue( "T3Z_VERSAO" )
					cProtocolo		:= oModelT3Z:GetValue( "T3Z_PROTUL" )
					cEvento		:= oModelT3Z:GetValue( "T3Z_EVENTO" )

					If TafColumnPos( "T3Z_LOGOPE" )
						cLogOpeAnt := oModelT3Z:GetValue( "T3Z_LOGOPE" )
					endif

					//Armazeno as informações correntes do cadastro( Depois da alteração do Usuário )
									
					For nI := 1 to Len( oModelT3Z:aDataModel[ 1 ] )
						Aadd( aGrava, { oModelT3Z:aDataModel[ 1, nI, 1 ], oModelT3Z:aDataModel[ 1, nI, 2 ] } )
					Next nI
					//------------------
								
					For nT2L := 1 To oModel:GetModel( 'MODEL_T2L' ):Length() 
						oModel:GetModel( 'MODEL_T2L' ):GoLine(nT2L)
												
						If !oModel:GetModel( 'MODEL_T2L' ):IsDeleted()
							aAdd (aGravaT2L ,{oModelT2L:GetValue("T2L_CNPJSD"),;
											oModelT2L:GetValue("T2L_TPCONT"),;
											oModelT2L:GetValue("T2L_VLRCS")} )
						EndIf
					Next 
		
					/*---------------------------------------------------------- 
					Seto o campo como Inativo e gravo a versao do novo registro
					no registro anterior                                       
							
					ATENCAO -> A alteracao destes campos deve sempre estar     
					abaixo do Loop do For, pois devem substituir as informacoes
					que foram armazenadas no Loop acima 
					-----------------------------------------------------------*/                        
					FAltRegAnt( "T3Z", "2" )	
		
					/*----------------------------------------------------------
					Apos deixar o registro corrente como inativo eu seto a 
					operação de inclusão para o novo registro
					-----------------------------------------------------------*/
					oModel:DeActivate()
					oModel:SetOperation( 3 )
					oModel:Activate()
		
					/*----------------------------------------------------------
					Neste momento eu realizo a gravação de um novo registro idêntico
					ao original, apenas com as alterações nos campos modificados
					pelo usuário no cadastro
					-----------------------------------------------------------*/			
					//******************
					//Apuração
					//******************         		
					For nI := 1 to Len( aGrava )
						oModel:LoadValue( "MODEL_T3Z", aGrava[ nI, 1 ], aGrava[ nI, 2 ] )
					Next nI

					//Necessário Abaixo do For Nao Retirar
					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T3Z', 'T3Z_LOGOPE' , '' , cLogOpeAnt )	
					EndIf

				For nT2L := 1 to Len( aGravaT2L )
						If nT2L > 1
							oModel:GetModel( "MODEL_T2L" ):AddLine()
						EndIf
						oModel:LoadValue( "MODEL_T2L", "T2L_CNPJSD" , aGravaT2L[nT2L][1] )
						oModel:LoadValue( "MODEL_T2L", "T2L_TPCONT" , aGravaT2L[nT2L][2] )
						oModel:LoadValue( "MODEL_T2L", "T2L_VLRCS"	, aGravaT2L[nT2L][3] )
					Next nT2L            
					
					//Busco a nova versao do registro
					cVersao := xFunGetVer()
		
					/*---------------------------------------------------------
					ATENCAO -> A alteracao destes campos deve sempre estar     
					abaixo do Loop do For, pois devem substituir as informacoes
					que foram armazenadas no Loop acima                        
					-----------------------------------------------------------*/
					oModel:LoadValue( "MODEL_T3Z", "T3Z_VERSAO", cVersao )
					oModel:LoadValue( "MODEL_T3Z", "T3Z_VERANT", cVerAnt )
					oModel:LoadValue( "MODEL_T3Z", "T3Z_PROTPN", cProtocolo )
					oModel:LoadValue( "MODEL_T3Z", "T3Z_PROTUL", "" )
					oModel:LoadValue( "MODEL_T3Z", "T3Z_EVENTO", "A" )
					
					// Tratamento para limpar o ID unico do xml
					cAliasPai := "T3Z"
					If TAFColumnPos( cAliasPai+"_XMLID" )
						oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					EndIf
					
					FwFormCommit( oModel )
					TAFAltStat( 'T3Z', " " )  

				ElseIf	T3Z->T3Z_STATUS == "2"    

					TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
					lRetorno:= .F.

				ElseIf T3Z->T3Z_STATUS == "6"  

					TAFMsgVldOp(oModel,"6")//"Registro não pode ser alterado. Aguardando proc. Transm. evento de Exclusão S-3000"
					lRetorno:= .F.

				Elseif T3Z->T3Z_STATUS == "7"

					TAFMsgVldOp(oModel,"7") //"Registro não pode ser alterado, pois o evento já se encontra na base do RET"  
					lRetorno:= .F.

				Else

					//Alteração Sem transmissão
					If TafColumnPos( "T3Z_LOGOPE" )
						cLogOpeAnt := T3Z->T3Z_LOGOPE
					EndIf

					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T3Z', 'T3Z_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					FwFormCommit( oModel )
					TAFAltStat( 'T3Z', " " )  

				EndIf
				
			EndIf
		
		//Exclusão Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_DELETE	  

			cChvRegAnt := T3Z->(T3Z_ID + T3Z_VERANT)              
												
			TAFAltStat( 'T3Z', " " )
			FwFormCommit( oModel )				
		
			If T3Z->T3Z_EVENTO == "A" .Or. T3Z->T3Z_EVENTO == "E"
				TAFRastro( 'T3Z', 1, cChvRegAnt, .T., , IIF(Type ("oBrw") == "U", Nil, oBrw ))
			EndIf

		EndIf
		
	End Transaction

Return ( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF412Grv
@type			function
@description	Função de gravação para atender o registro S-2100.
@author			Daniel Schmidt 
@since			07/01/2016
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
Function TAF412Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

	Local cCmpsNoUpd   := "|T3Z_FILIAL|T3Z_ID|T3Z_VERSAO|T3Z_VERANT|T3Z_PROTUL|T3Z_PROTPN|T3Z_EVENTO|T3Z_STATUS|T3Z_ATIVO|"
	Local cCabec       := "/eSocial/evtContrSindPatr"
	Local cPeriodo     := ""
	Local cChave       := ""
	Local cCodEvent    := Posicione( "C8E", 2, xFilial( "C8E" ) + "S-" + cLayout, "C8E->C8E_ID" )
	Local cLogOpeAnt   := ""
	Local nI           := 0
	Local nJ           := 0
	Local lRet         := .F.
	Local aIncons      := {}
	Local aRulesCad    := {}
	Local aChave       := {}
	Local oModel       := Nil

	Private lVldModel  := .T. //Caso a chamada seja via integração, seto a variável de controle de validação como .T.
	Private oDados     := oXML

	Default cLayout    := "1300"
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

	cPeriodo	:= FTafGetVal( cCabec + "/ideEvento/perApur", "C", .F., @aIncons, .F. )

	Aadd( aChave, {"C", "T3Z_INDAPU", FTafGetVal( cCabec + "/ideEvento/indApuracao", "C", .F., @aIncons, .F. )  , .T.} )
	cChave := Padr( aChave[ 1, 3 ], Tamsx3( aChave[ 1, 2 ])[1])
			
	
	If At("-", cPeriodo) > 0
		Aadd( aChave, {"C", "T3Z_PERAPU", StrTran(cPeriodo, "-", "" ),.T.} )
		cChave += Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1])
	Else
		Aadd( aChave, {"C", "T3Z_PERAPU", cPeriodo  , .T.} )
		cChave += Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1])
	EndIf
		
	//Verifica se o evento ja existe na base
	("T3Z")->( DbSetOrder( 2 ) )
	If ("T3Z")->( MsSeek( FTafGetFil( cFilEv , @aIncons , "T3Z" ) + cChave + '1' ) )
		If !T3Z->T3Z_STATUS $ ( "2|4|6|" )
			nOpc := 4
		EndIf
	EndIf
		
		
	Begin Transaction

		//Funcao para validar se a operacao desejada pode ser realizada
		If FTafVldOpe( "T3Z", 2, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA412", cCmpsNoUpd , , , , )

			If TafColumnPos( "T3Z_LOGOPE" )
				cLogOpeAnt := T3Z->T3Z_LOGOPE
			endif

			//Carrego array com os campos De/Para de gravacao das informacoes ( Cadastrais )
			aRulesCad := TAF412Rul( cCabec, cLayout, cCodEvent, cOwner )
					
							
			//Quando se tratar de uma Exclusao direta apenas preciso realizar
			//o Commit(), nao eh necessaria nenhuma manutencao nas informacoes
			If nOpc <> 5
					
				oModel:LoadValue( "MODEL_T3Z", "T3Z_FILIAL", T3Z->T3Z_FILIAL )

				If TAFColumnPos( "T3Z_XMLID" )
					oModel:LoadValue( "MODEL_T3Z", "T3Z_XMLID", cXmlID )
				EndIf

				//Rodo o aRulesCad para gravar as informacoes
				For nI := 1 to Len( aRulesCad )
					oModel:LoadValue( "MODEL_T3Z", aRulesCad[ nI, 01 ], FTafGetVal( aRulesCad[ nI, 02 ], aRulesCad[nI, 03], aRulesCad[nI, 04], @aIncons, .F. ) )
				Next nI

				If Findfunction("TAFAltMan")
					if nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T3Z', 'T3Z_LOGOPE' , '1', '' )
					elseif nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T3Z', 'T3Z_LOGOPE' , '', cLogOpeAnt )
					EndIf
				EndIf

				//Quando se trata de uma alteracao, deleto todas as linhas do Grid 		
				If nOpc == 4
					For nJ := 1 to oModel:GetModel( "MODEL_T2L" ):Length()
						oModel:GetModel( "MODEL_T2L" ):GoLine(nJ)
						oModel:GetModel( "MODEL_T2L" ):DeleteLine()
					Next nJ
				EndIf

				//Rodo o XML parseado para gravar as novas informacoes no GRID ( Cadastro de Dependentes )
				nJ := 1
				While oDados:XPathHasNode(cCabec + "/contribSind[" + cValToChar(nJ)+ "]" )
					
					If nOpc == 4 .or. nJ > 1
						oModel:GetModel( "MODEL_T2L" ):lValid:= .T.
						oModel:GetModel( "MODEL_T2L" ):AddLine()
					EndIf
							
					if oDados:XPathHasNode( cCabec + "/contribSind[" + cValToChar(nJ)+ "]/cnpjSindic")
						oModel:LoadValue( "MODEL_T2L", "T2L_CNPJSD" ,	FTafGetVal( cCabec + "/contribSind[" + cValToChar(nJ)+ "]/cnpjSindic",	  "C", .F., @aIncons, .F. ) )
					EndIf
					if oDados:XPathHasNode( cCabec + "/contribSind[" + cValToChar(nJ)+ "]/tpContribSind")
						oModel:LoadValue( "MODEL_T2L", "T2L_TPCONT",	FTafGetVal( cCabec + "/contribSind[" + cValToChar(nJ)+ "]/tpContribSind",	  "C", .F., @aIncons, .F. ) )
					EndIf
													
					If oDados:XPathHasNode( cCabec + "/contribSind[" + cValToChar(nJ)+ "]/vlrContribSind")
						oModel:LoadValue( "MODEL_T2L", "T2L_VLRCS",	FTafGetVal( cCabec + "/contribSind[" + cValToChar(nJ)+ "]/vlrContribSind",  "N", .F., @aIncons, .F. ) )
					Endif
							
					nJ ++
				EndDo
				//----------
																											
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetiva a operacao desejada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(aIncons)
				If TafFormCommit( oModel )
					Aadd(aIncons, "ERRO19")
				Else
					lRet := .T.
				EndIf
			Else			
				DisarmTransaction()	
			EndIf	

			oModel:DeActivate()
			If FindFunction('TafClearModel')
				TafClearModel(oModel)
			EndIf
		
		EndIf

	End Transaction
		
	//Zerando os arrays e os Objetos utilizados no processamento
	aSize( aRulesCad, 0 )
	aRulesCad := Nil
		
	aSize( aChave, 0 )
	aChave := Nil
	
Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF412Rul
Regras para gravacao das informacoes de trabalhador do cadastro dos registros S1300

@Param
aRull  - Regras para a gravacao das informacoes
cCabecTrab - Cabecalho de busca das informacoes no Xml
cLayout - Numero do evento do eSocial

@Return
aRull - Array com as regras do cadastro para integração

@author Daniel Schmidt 
@since 07/01/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF412Rul( cCabec, cLayout, cCodEvent, cOwner )

	Local aRull
	Local cPeriodo

	Default cCabec    := ""
	Default cLayout   := ""
	Default cCodEvent := ""
	Default cOwner    := ""

	aRull             := {}
	cPeriodo          := ""

	//**********************************
	//eSocial/evtContrSindPatr/ideEvento/
	//**********************************	
	If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtContrSindPatr/ideEvento/indApuracao" ) )
		Aadd( aRull, { "T3Z_INDAPU", "/eSocial/evtContrSindPatr/ideEvento/indApuracao", 		"C",  .F. } )		//indApuracao
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtContrSindPatr/ideEvento/perApur" ) )
		cPeriodo	:= FTafGetVal("/eSocial/evtContrSindPatr/ideEvento/perApur", "C", .F.,, .F. )
		
		If At("-", cPeriodo) > 0
			Aadd( aRull, {"T3Z_PERAPU", StrTran(cPeriodo, "-", "" ) ,"C",.T.} )	
		Else
			Aadd( aRull, {"T3Z_PERAPU", cPeriodo ,"C", .T.} )		
		EndIf
	EndIf

Return( aRull )

//-------------------------------------------------------------------	
/*/{Protheus.doc} TAF412Xml
Retorna o Xml do Registro Posicionado 
	
@author Daniel Schmidt 
@since 07/01/2016
@version 1.0
		
@Param:
lJob - Informa se foi chamado por Job
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@return
cXml - Estrutura do Xml do Layout S-1300

/*/
//-------------------------------------------------------------------
Function TAF412Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

	Local cXml
	Local cLayout
	Local cReg
	Local aMensal
	
	Default lJob    := .F.
	Default cAlias  := "T3Z"
	Default nRecno  := 1
	Default nOpc    := 1
	Default cSeqXml := ""
	
	cXml    := ""
	cLayout := "1300"
	cReg    := "ContrSindPatr"
	aMensal := {}

	AADD(aMensal,T3Z->T3Z_INDAPU) 
		
	If Len(Alltrim(T3Z->T3Z_PERAPU)) <= 4
		AADD(aMensal,T3Z->T3Z_PERAPU)  
	Else
		AADD(aMensal,substr(T3Z->T3Z_PERAPU, 1, 4) + '-' + substr(T3Z->T3Z_PERAPU, 5, 2) )
	EndIf 

	DBSelectArea( "T2L" )
	T2L->( DBSetOrder( 1 ))		
	If T2L->(MsSeek(xFilial("T2L") + T3Z->( T3Z_ID + T3Z_VERSAO ) ) )

		While T2L->(!Eof()) .and. T2L->(T2L_FILIAL + T2L_ID + T2L_VERSAO) == xFilial("T2L") + (cAlias)->( &( cAlias + "_ID" ) + &( cAlias + "_VERSAO" ) )
		
			cXml +=		"<contribSind>"	
			cXml +=			xTafTag("cnpjSindic", 		T2L->T2L_CNPJSD)
			cXml +=			xTafTag("tpContribSind", 	T2L->T2L_TPCONT)
			cXml +=			xTafTag("vlrContribSind",	T2L->T2L_VLRCS,PesqPict("T2L","T2L_VLRCS") )
			cXml +=		"</contribSind>"	

		T2L->(DBSkip())
	   EndDo

	EndIf

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³Estrutura do cabecalho³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	cXml := xTafCabXml(cXml,"T3Z",cLayout,cReg,aMensal,cSeqXml)
	
	T3Z->(DbCloseArea())
	
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³Executa gravacao do registro³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If !lJob
		xTafGerXml(cXml,cLayout)
	EndIf
	
Return(cXml)

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
Static Function GerarEvtExc( oModel, nRecno, lRotExc  )

	Local cVerAnt
	Local cProtocolo
	Local cVersao
	Local cChvRegAnt
	Local cEvento
	Local cId
	Local nOperation
	Local nI,nT2L
	Local aCampos
	Local aGrava
	Local aGravaT2L
	Local oModelT3Z
	Local oModelT2L

	cVerAnt    := ""
	cProtocolo := ""
	cVersao    := ""
	cChvRegAnt := ""
	cEvento    := ""
	cId        := ""
	nOperation := oModel:GetOperation()
	nI         := 0
	nT2L       := 0
	aCampos    := {}
	aGrava     := {}
	aGravaT2L  := {}
	oModelT3Z  := Nil
	oModelT2L  := Nil

	Begin Transaction

		//Posiciona o item
		("T3Z")->( DBGoTo( nRecno ) )
						
		//Carrego a Estrutura dos Models a serem gravados
		oModelT3Z 	:= oModel:GetModel( "MODEL_T3Z" )
		oModelT2L	:= oModel:GetModel( "MODEL_T2L" )				
					
		//Guardo as informações do registro corrente para rastro do registro
		cVerAnt   	:= oModelT3Z:GetValue( "T3Z_VERSAO" )
		cProtocolo	:= oModelT3Z:GetValue( "T3Z_PROTUL" )
		cEvento	:= oModelT3Z:GetValue( "T3Z_EVENTO" )
		
		//Armazeno as informações correntes do cadastro( Depois da alteração do Usuário )
											
		For nI := 1 to Len( oModelT3Z:aDataModel[ 1 ] )
				Aadd( aGrava, { oModelT3Z:aDataModel[ 1, nI, 1 ], oModelT3Z:aDataModel[ 1, nI, 2 ] } )
		Next nI
		//------------------				
					
		For nT2L := 1 To oModel:GetModel( 'MODEL_T2L' ):Length() 
			oModel:GetModel( 'MODEL_T2L' ):GoLine(nT2L)
										
			If !oModel:GetModel( 'MODEL_T2L' ):IsDeleted()
				aAdd (aGravaT2L ,{oModelT2L:GetValue("T2L_CNPJSD"),;
								oModelT2L:GetValue("T2L_TPCONT"),;
								oModelT2L:GetValue("T2L_VLRCS")} )
			EndIf
		Next 
		
		/*---------------------------------------------------------- 
		Seto o campo como Inativo e gravo a versao do novo registro
		no registro anterior                                       
					
		ATENCAO -> A alteracao destes campos deve sempre estar     
		abaixo do Loop do For, pois devem substituir as informacoes
		que foram armazenadas no Loop acima 
		-----------------------------------------------------------*/                        
		FAltRegAnt( "T3Z", "2" )
		
		/*----------------------------------------------------------
		Apos deixar o registro corrente como inativo eu seto a 
		operação de inclusão para o novo registro
		-----------------------------------------------------------*/
		oModel:DeActivate()
		oModel:SetOperation( 3 )
		oModel:Activate()
		
		/*----------------------------------------------------------
		Neste momento eu realizo a gravação de um novo registro idêntico
		ao original, apenas com as alterações nos campos modificados
		pelo usuário no cadastro
		-----------------------------------------------------------*/			
					
		For nI := 1 to Len( aGrava )
			oModel:LoadValue( "MODEL_T3Z", aGrava[ nI, 1 ], aGrava[ nI, 2 ] )
		Next nI        
						
		For nT2L := 1 to Len( aGravaT2L )
			If nT2L > 1
				oModel:GetModel( "MODEL_T2L" ):AddLine()
			EndIf
			oModel:LoadValue( "MODEL_T2L", "T2L_CNPJSD" , aGravaT2L[nT2L][1] )
			oModel:LoadValue( "MODEL_T2L", "T2L_TPCONT" , aGravaT2L[nT2L][2] )
			oModel:LoadValue( "MODEL_T2L", "T2L_VLRCS"  , aGravaT2L[nT2L][3] )
		Next nT2L            
		
		//Busco a nova versao do registro
		cVersao := xFunGetVer()
		
		/*---------------------------------------------------------
		ATENCAO -> A alteracao destes campos deve sempre estar     
		abaixo do Loop do For, pois devem substituir as informacoes
		que foram armazenadas no Loop acima                        
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_T3Z", "T3Z_VERSAO", cVersao )
		oModel:LoadValue( "MODEL_T3Z", "T3Z_VERANT", cVerAnt )
		oModel:LoadValue( "MODEL_T3Z", "T3Z_PROTPN", cProtocolo )
		oModel:LoadValue( "MODEL_T3Z", "T3Z_PROTUL", "" )
			
		/*---------------------------------------------------------
		Tratamento para que caso o Evento Anterior fosse de exclusão
		seta-se o novo evento como uma "nova inclusão", caso contrário o
		evento passar a ser uma alteração
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_T3Z", "T3Z_EVENTO", "E" )
		oModel:LoadValue( "MODEL_T3Z", "T3Z_ATIVO", "1" )

		FwFormCommit( oModel )
		TAFAltStat( 'T3Z',"6" )
		
	End Transaction

Return ( .T. )
