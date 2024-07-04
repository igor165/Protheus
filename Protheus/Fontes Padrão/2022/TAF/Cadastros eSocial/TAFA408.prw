#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA408.CH'

STATIC lLaySimplif	:= taflayEsoc("S_01_00_00")

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA408
Contratação de Trabalhador Avulso - S-1270

@author Vitor Siqueira
@since 02/02/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA408()

	Private	oBrw

	oBrw := BrowseDef()

	oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse Def para seguir padrão MVC

@author Andrews Egas
@since 19/09/2018
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function BrowseDef()

	Local oBrowse
	oBrowse	:=  FWmBrowse():New()

	oBrowse:SetDescription(STR0001)    //"Contratação de Trabalhador Avulso"
	oBrowse:SetAlias( 'T2A')
	oBrowse:SetMenuDef( 'TAFA408' )

	If FindFunction('TAFSetFilter')
		oBrowse:SetFilterDefault(TAFBrwSetFilter("T2A","TAFA408","S-1270"))
	Else
		oBrowse:SetFilterDefault( "T2A_ATIVO == '1'" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )
	EndIf
	TafLegend(2,"T2A",@oBrowse)

Return oBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Vitor Siqueira
@since 02/02/2016
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()

	Local aRotina := {}
	Local aFuncao := {}

	Aadd( aFuncao, { "" , "TafxmlRet('TAF408Xml','1270','T2A')" 									, "1" } )
	Aadd( aFuncao, { "" , "xFunAltRec( 'T2A' )" 													, "10"} )
	Aadd( aFuncao, { "" , "xNewHisAlt( 'T2A', 'TAFA408' ,,,,,,'1270','TAF408Xml' )" 				, "3" } )
	Aadd( aFuncao, { "" , "TAFXmlLote( 'T2A', 'S-1270' , 'evtContratAvNP' , 'TAF408Xml',, oBrw )" 	, "5" } )

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If lMenuDif
		ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA408' OPERATION 2 ACCESS 0	
		aRotina	:= xMnuExtmp( "TAFA408", "T2A", .F. )
	Else
		aRotina	:=	xFunMnuTAF( "TAFA408" , , aFuncao)
	EndIf          
                                                           
Return( aRotina )   

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Vitor Siqueira
@since 02/02/2016
@version 1.0

/*/
//-------------------------------------------------------------------     
Static Function ModelDef()	

	Local oStruT2A
	Local oStruT1Y
	Local oModel

	oStruT2A := FWFormStruct( 1, 'T2A' )
	oStruT1Y := FWFormStruct( 1, 'T1Y' )

	If !lLaySimplif
		oStruT2A:RemoveField('T2A_TPGUIA')
	Else
		oStruT2A:SetProperty( 'T2A_TPGUIA' , MODEL_FIELD_OBRIGAT,.F.)
	EndIf 

	oModel := MPFormModel():New('TAFA408',,,{|oModel| SaveModel(oModel)} )

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruT2A:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT1Y:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
	EndIf

	oStruT1Y:SetProperty( 'T1Y_VBCP15' , MODEL_FIELD_OBRIGAT,.F.)
	oStruT1Y:SetProperty( 'T1Y_VBCP20' , MODEL_FIELD_OBRIGAT,.F.)
	oStruT1Y:SetProperty( 'T1Y_VBCP25' , MODEL_FIELD_OBRIGAT,.F.)
	oStruT1Y:SetProperty( 'T1Y_VBCP15' , MODEL_FIELD_OBRIGAT,.F.)
	oStruT1Y:SetProperty( 'T1Y_VLBCCP' , MODEL_FIELD_OBRIGAT,.F.)
	oStruT1Y:SetProperty( 'T1Y_VBCP13' , MODEL_FIELD_OBRIGAT,.F.)
	oStruT1Y:SetProperty( 'T1Y_VLBCFG' , MODEL_FIELD_OBRIGAT,.F.)
	oStruT1Y:SetProperty( 'T1Y_VLRDES' , MODEL_FIELD_OBRIGAT,.F.)

	//Remoção do GetSX8Num quando se tratar da Exclusão de um Evento Transmitido.
	//Necessário para não incrementar ID que não será utilizado.
	If Upper( ProcName( 2 ) ) == Upper( "GerarExclusao" )
		oStruT2A:SetProperty( "T2A_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )
	EndIf

	oModel:AddFields('MODEL_T2A', /*cOwner*/, oStruT2A)
	oModel:GetModel('MODEL_T2A'):SetPrimaryKey({'T2A_FILIAL', 'T2A_ID', 'T2A_VERSAO'})

	// INFORMAÇÕES DA REMUNERAÇÃO DO TRABALHADOR
	oModel:AddGrid("MODEL_T1Y","MODEL_T2A",oStruT1Y)
	oModel:GetModel("MODEL_T1Y"):SetOptional(.T.)
	oModel:GetModel("MODEL_T1Y"):SetUniqueLine({"T1Y_ESTABE"})

	// RELATIONS 
	oModel:SetRelation("MODEL_T1Y", {{"T1Y_FILIAL","xFilial('T1Y')"}, {"T1Y_ID","T2A_ID"}, {"T1Y_VERSAO","T2A_VERSAO"}},T1Y->(IndexKey(1)) )

Return oModel             

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Vitor Siqueira
@since 02/02/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oStruT2Aa := Nil
	Local oStruT2Ab := Nil
	Local oStruT2Ac	:= Nil
	Local oModel	
	Local oStruT2A	
	Local oStruT1Y	
	Local oView		
	Local cCmpFil	

	oModel		:= FWLoadModel( 'TAFA408' )
	oStruT2A	:= FWFormStruct( 2, 'T2A' )
	oStruT1Y	:= FWFormStruct( 2, 'T1Y' )
	oView		:= FWFormView():New()
	cCmpFil		:= ''

	oView:SetModel( oModel )

	// Campos do folder Informacoes da Contratação

	If !lLaySimplif
		cCmpFil := 'T2A_ID|T2A_INDAPU|T2A_PERAPU|'
	Else 
		cCmpFil := 'T2A_ID|T2A_PERAPU|T2A_TPGUIA|'
	EndIf 

	oStruT2Aa := FwFormStruct( 2, 'T2A', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	// Campos do folder do número do ultimo protocolo
	cCmpFil := 'T2A_PROTUL|
	oStruT2Ab := FwFormStruct( 2, 'T2A', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	If TafColumnPos("T2A_DTRANS")
		cCmpFil := "T2A_DINSIS|T2A_DTRANS|T2A_HTRANS|T2A_DTRECP|T2A_HRRECP|"
		oStruT2Ac := FwFormStruct( 2, 'T2A', {|x| AllTrim( x ) + "|" $ cCmpFil } )
	EndIf

	If FindFunction('TafAjustRecibo')
		TafAjustRecibo(oStruT2Ab,"T2A")
	EndIf
	/*--------------------------------------------------------------------------------------------
										Esrutura da View
	---------------------------------------------------------------------------------------------*/
	oView:AddField( 'VIEW_T2Aa', oStruT2Aa, 'MODEL_T2A' )
	oView:EnableTitleView( 'VIEW_T2Aa', STR0004 ) //Informações da Contratação

	oView:AddField( 'VIEW_T2Ab', oStruT2Ab, 'MODEL_T2A' )

	If TafColumnPos("T2A_PROTUL")	
		oView:EnableTitleView( 'VIEW_T2Ab', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"  
	EndIf 
	If TafColumnPos("T2A_DTRANS")
		oView:AddField( 'VIEW_T2Ac', oStruT2Ac, 'MODEL_T2A' )
		oView:EnableTitleView( 'VIEW_T2Ac', TafNmFolder("recibo",2) )
	EndIf

	oView:AddGrid("VIEW_T1Y",oStruT1Y,"MODEL_T1Y")
	oView:EnableTitleView("VIEW_T1Y",STR0003) //Remuneração do Trabalhador


	/*-----------------------------------------------------------------------------------
									Estrutura do Folder
	-------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox( 'PAINEL_SUPERIOR', 100 )

	oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL_SUPERIOR' )

	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0004 )   //"Informações da Folha"

	If FindFunction('TafNmFolder')	
		oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', TafNmFolder("recibo") )   //"Numero do Recibo"
	Else
		oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0005 )   //"Protocolo de Transmissão"
	EndIf 

	oView:CreateHorizontalBox( 'T2Aa',  016,,, 'FOLDER_SUPERIOR', 'ABA01' )
	oView:CreateHorizontalBox( 'T1Y' ,  084,,, 'FOLDER_SUPERIOR', 'ABA01' )

	If TafColumnPos("T2A_DTRANS")
		oView:CreateHorizontalBox( 'T2Ab',  20,,, 'FOLDER_SUPERIOR', 'ABA02' )
		oView:CreateHorizontalBox( 'T2Ac',  80,,, 'FOLDER_SUPERIOR', 'ABA02' )
	Else
		oView:CreateHorizontalBox( 'T2Ab',  100,,, 'FOLDER_SUPERIOR', 'ABA02' )
	EndIf

	oView:SetOwnerView('VIEW_T2Aa', 'T2Aa' )
	oView:SetOwnerView('VIEW_T2Ab', 'T2Ab' )
	If TafColumnPos("T2A_DTRANS")
		oView:SetOwnerView('VIEW_T2Ac', 'T2Ac' )
	EndIf
	oView:SetOwnerView("VIEW_T1Y","T1Y")

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If !lMenuDif
		xFunRmFStr(@oStruT2Aa, 'T2A')
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

	Local cVerAnt    := ""
	Local cProtocolo := ""
	Local cVersao    := ""
	Local cEvento    := ""
	Local cLogOpe    := ""
	Local cLogOpeAnt := ""
	Local nOperation
	Local nT2A
	Local nT1Y
	Local nT1YAdd
	Local nLE1Add
	Local aGrava
	Local aGravaT1Y
	Local oModelT2A
	Local oModelT1Y
	Local lRetorno

	cVerAnt    := ""
	cProtocolo := ""
	cVersao    := ""
	cEvento    := ""
	cLogOpe    := ""
	cLogOpeAnt := ""
	nOperation := oModel:GetOperation()
	nT2A       := 0
	nT1Y       := 0
	nT1YAdd    := 0
	nLE1Add    := 0
	aGrava     := {}
	aGravaT1Y  := {}
	oModelT2A  := Nil
	oModelT1Y  := Nil
	lRetorno   := .T.

	Begin Transaction 
		
		If nOperation == MODEL_OPERATION_INSERT

			TafAjustID( "T2A", oModel)
			
			oModel:LoadValue( 'MODEL_T2A', 'T2A_VERSAO', xFunGetVer() )

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_T2A', 'T2A_LOGOPE' , '2', '' )
			Endif

			FwFormCommit( oModel )  
			
		ElseIf nOperation == MODEL_OPERATION_UPDATE 

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			T2A->( DbSetOrder( 4 ) )
			If T2A->( MsSeek( xFilial( 'T2A' ) + FwFldGet('T2A_ID')+ '1' ) )
							
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o registro ja foi transmitido³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If T2A->T2A_STATUS $ ( "4" ) 
									
					oModelT2A := oModel:GetModel( 'MODEL_T2A' ) 
					oModelT1Y := oModel:GetModel( 'MODEL_T1Y' ) 
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao anterior do registro para gravacao do rastro³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVerAnt   	:= oModelT2A:GetValue( "T2A_VERSAO" )				
					cProtocolo	:= oModelT2A:GetValue( "T2A_PROTUL" )				
					cEvento	:= oModelT2A:GetValue( "T2A_EVENTO" )

					If TafColumnPos( "T2A_LOGOPE" )
						cLogOpeAnt := oModelT2A:GetValue( "T2A_LOGOPE" )
					endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu gravo as informacoes que foram carregadas na tela³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nT2A := 1 to Len( oModelT2A:aDataModel[ 1 ] )
						aAdd( aGrava, { oModelT2A:aDataModel[ 1, nT2A, 1 ], oModelT2A:aDataModel[ 1, nT2A, 2 ] } )
					Next nT2A	       						
					
					//Posicionando no registro
					DBSelectArea("T1Y")
					DBSetOrder(1)
					/*------------------------------------------
						T1Y - Remuneração do Trabalhador
					--------------------------------------------*/
					If T1Y->(MsSeek(xFilial("T1Y")+T2A->(T2A_ID + T2A_VERSAO) ) )
						For nT1Y := 1 to oModel:GetModel( "MODEL_T1Y" ):Length()
							oModel:GetModel( "MODEL_T1Y" ):GoLine(nT1Y)
							
							If !oModel:GetModel( "MODEL_T1Y" ):IsDeleted()
								aAdd (aGravaT1Y ,{oModelT1Y:GetValue('T1Y_ESTABE'),;
												oModelT1Y:GetValue('T1Y_LOTACA'),;
												oModelT1Y:GetValue('T1Y_VLBCCP'),;
												oModelT1Y:GetValue('T1Y_VBCP15'),;
												oModelT1Y:GetValue('T1Y_VBCP20'),;							 				  
												oModelT1Y:GetValue('T1Y_VBCP25'),;
												oModelT1Y:GetValue('T1Y_VBCP13'),;
												oModelT1Y:GetValue('T1Y_VLBCFG'),;
												oModelT1Y:GetValue('T1Y_VLRDES')})
									
							EndIf
						Next nT1Y
					EndIf
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seto o campo como Inativo e gravo a versao do novo registro³
					//³no registro anterior                                       ³
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FAltRegAnt( 'T2A', '2' )	
			
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
					For nT2A := 1 to Len( aGrava )
						oModel:LoadValue( "MODEL_T2A", aGrava[ nT2A, 1 ], aGrava[ nT2A, 2 ] )
					Next nT2A

					//Necessário Abaixo do For Nao Retirar
					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T2A', 'T2A_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					/*------------------------------------------
						T1Y - Remuneração do Trabalhador
					--------------------------------------------*/
					For nT1Y := 1 to Len( aGravaT1Y )
									
						oModel:GetModel( 'MODEL_T1Y' ):LVALID	:= .T.
						
						If nT1Y > 1
							oModel:GetModel( "MODEL_T1Y" ):AddLine()
						EndIf
						
						oModel:LoadValue( "MODEL_T1Y", "T1Y_ESTABE", aGravaT1Y[nT1Y][1] )
						oModel:LoadValue( "MODEL_T1Y", "T1Y_LOTACA", aGravaT1Y[nT1Y][2] )
						oModel:LoadValue( "MODEL_T1Y", "T1Y_VLBCCP", aGravaT1Y[nT1Y][3] )
						oModel:LoadValue( "MODEL_T1Y", "T1Y_VBCP15", aGravaT1Y[nT1Y][4] )
						oModel:LoadValue( "MODEL_T1Y", "T1Y_VBCP20", aGravaT1Y[nT1Y][5] )
						oModel:LoadValue( "MODEL_T1Y", "T1Y_VBCP25", aGravaT1Y[nT1Y][6] )
						oModel:LoadValue( "MODEL_T1Y", "T1Y_VBCP13", aGravaT1Y[nT1Y][7] )
						oModel:LoadValue( "MODEL_T1Y", "T1Y_VLBCFG", aGravaT1Y[nT1Y][8] )
						oModel:LoadValue( "MODEL_T1Y", "T1Y_VLRDES", aGravaT1Y[nT1Y][9] )
						
				
					Next nT1Y
						
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao que sera gravada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVersao := xFunGetVer()		 
													
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿		
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		                                                                      				         
					oModel:LoadValue( 'MODEL_T2A', 'T2A_VERSAO', cVersao )
					oModel:LoadValue( 'MODEL_T2A', 'T2A_VERANT', cVerAnt )
					oModel:LoadValue( 'MODEL_T2A', 'T2A_PROTPN', cProtocolo )
					oModel:LoadValue( 'MODEL_T2A', 'T2A_PROTUL', "" )
					oModel:LoadValue( 'MODEL_T2A', 'T2A_EVENTO', "A" )
					
					// Tratamento para limpar o ID unico do xml
					cAliasPai := "T2A"
					If TAFColumnPos( cAliasPai+"_XMLID" )
						oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					EndIf
					
					FwFormCommit( oModel )
					TAFAltStat( 'T2A', " " ) 
						
				ElseIf	T2A->T2A_STATUS == "2"                                                                 
					TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
					lRetorno:= .F.
				ElseIf T2A->T2A_STATUS == "6"                                                                                                                                                                                                                                                                        
					TAFMsgVldOp(oModel,"6")//"Registro não pode ser alterado. Aguardando proc. Transm. evento de Exclusão S-3000"
					lRetorno:= .F.
				Elseif T2A->T2A_STATUS == "7"
					TAFMsgVldOp(oModel,"7") //"Registro não pode ser alterado, pois o evento já se encontra na base do RET"  
					lRetorno:= .F.
				Else
					If TafColumnPos( "T2A_LOGOPE" )
						cLogOpeAnt := T2A->T2A_LOGOPE
					EndIf

					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T2A', 'T2A_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					FwFormCommit( oModel )
					TAFAltStat( 'T2A', " " )  
				EndIf
			EndIf

		ElseIf nOperation == MODEL_OPERATION_DELETE 
		
			oModel:DeActivate()
			oModel:SetOperation( 5 ) 	
			oModel:Activate()
			FwFormCommit( oModel )
					
		EndIf
							
	End Transaction        	
				
	If !lRetorno 
		// Define a mensagem de erro que será exibida após o Return do SaveModel
		TAFMsgDel(oModel,.T.)
	EndIf

Return( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF408Xml
Funcao de geracao do XML para atender o registro S-1270
Quando a rotina for chamada o registro deve estar posicionado

@Param:
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@Return:
cXml - Estrutura do Xml do Layout S-1270

@author Vitor Siqueira
@since 20/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF408Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

	Local cXml
	Local cLayout
	Local cEvento
	Local cReg
	Local cInfEvt
	Local cId
	Local cVerAnt
	Local aMensal
	Local lXmlVLd   := IIF(FindFunction( 'TafXmlVLD' ),TafXmlVLD( 'TAF408XML' ),.T.)

	Default cSeqXml := ""

	cXml    := ""
	cLayout := "1270"
	cEvento := ""
	cReg    := "ContratAvNP"
	cInfEvt := T2A->T2A_VERSAO
	cId     := ""
	cVerAnt := ""
	aMensal := {}

	If lXmlVLd
		If T2A->T2A_EVENTO $ "I|A"
			
			AADD(aMensal,T2A->T2A_INDAPU) 
			
			If Len(Alltrim(T2A->T2A_PERAPU)) <= 4
				AADD(aMensal,T2A->T2A_PERAPU)  
			Else
				AADD(aMensal,substr(T2A->T2A_PERAPU, 1, 4) + '-' + substr(T2A->T2A_PERAPU, 5, 2) )
			EndIf 
										
					
			T1Y->( DbSetOrder( 1 ) )
			If T1Y->( MsSeek ( xFilial("T1Y")+T2A->(T2A_ID+T2A_VERSAO) ))    				
				While !T1Y->(Eof()) .And. AllTrim(T2A->(T2A_ID+T2A_VERSAO)) == AllTrim(T1Y->(T1Y_ID+T1Y_VERSAO))
					
					cXml +=	"<remunAvNP>"
					cXml +=		xTafTag("tpInsc"      ,POSICIONE("C92",1, xFilial("C92")+T1Y->T1Y_ESTABE,"C92_TPINSC"))
					

					If lLaySimplif
						cNrinsc := Alltrim(POSICIONE("C92",1, xFilial("C92")+T1Y->T1Y_ESTABE,"C92_NRINSC"))
						cXml +=		xTafTag("nrInsc"      ,SubStr(cNrinsc,1,14))
					Else 
						cXml +=		xTafTag("nrInsc"      ,POSICIONE("C92",1, xFilial("C92")+T1Y->T1Y_ESTABE,"C92_NRINSC")) 
					EndIf

					cXml +=		xTafTag("codLotacao"  ,POSICIONE("C99",1, xFilial("C99")+T1Y->T1Y_LOTACA,"C99_CODIGO"))
					cXml +=		xTafTag("vrBcCp00"	  ,T1Y->T1Y_VLBCCP, PesqPict("T1Y","T1Y_VLBCCP"),,,.T.)
					cXml +=		xTafTag("vrBcCp15"	  ,T1Y->T1Y_VBCP15, PesqPict("T1Y","T1Y_VBCP15"),,,.T.)
					cXml +=		xTafTag("vrBcCp20"	  ,T1Y->T1Y_VBCP20, PesqPict("T1Y","T1Y_VBCP20"),,,.T.)		
					cXml +=		xTafTag("vrBcCp25"	  ,T1Y->T1Y_VBCP25, PesqPict("T1Y","T1Y_VBCP25"),,,.T.)
					cXml +=		xTafTag("vrBcCp13"	  ,T1Y->T1Y_VBCP13, PesqPict("T1Y","T1Y_VBCP13"),,,.T.)
					cXml +=		xTafTag("vrBcFgts"	  ,T1Y->T1Y_VLBCFG, PesqPict("T1Y","T1Y_VLBCFG"),,,.T.)
					cXml +=		xTafTag("vrDescCP"	  ,T1Y->T1Y_VLRDES, PesqPict("T1Y","T1Y_VLRDES"),,,.T.)

					cXml +=	"</remunAvNP>"
					T1Y->(DbSkip())
				EndDo 	       	      
			EndIf 
								
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estrutura do cabecalho³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cXml := xTafCabXml(cXml,"T2A", cLayout,cReg, aMensal,cSeqXml)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa gravacao do registro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lJob
			xTafGerXml(cXml,cLayout)
		EndIf

	EndIf

Return(cXml)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF408Grv
@type			function
@description	Função de gravação para atender o registro S-1270.
@author			Vitor Siqueira
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
Function TAF408Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

	Local cCmpsNoUpd   := "|T2A_FILIAL|T2A_ID|T2A_VERANT|T2A_PROTUL|T2A_PROTPN|T2A_EVENTO|T2A_STATUS|T2A_ATIVO|"
	Local cChave       := ""
	Local cInconMsg    := ""
	Local cCodEvent    := Posicione( "C8E", 2, xFilial( "C8E" ) + "S-" + cLayout, "C8E->C8E_ID" )
	Local cLogOpeAnt   := ""
	Local nlI          := 0
	Local nlJ          := 0
	Local nT1Y         := 0
	Local nSeqErrGrv   := 0
	Local lRet         := .F.
	Local aIncons      := {}
	Local aRules       := {}
	Local aChave       := {}
	Local oModel       := Nil

	Private lVldModel  := .T. //Caso a chamada seja via integração, seto a variável de controle de validação como .T.
	Private oDados     := {}

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

	oDados := oXML

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chave do registro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cPeriodo  := FTafGetVal( "/eSocial/evtContratAvNP/ideEvento/perApur", "C", .F., @aIncons, .F. )

	If !lLaySimplif  
		Aadd( aChave, {"C", "T2A_INDAPU", FTafGetVal( "/eSocial/evtContratAvNP/ideEvento/indApuracao", "C", .F., @aIncons, .F. )  , .T.} ) 
		cChave += Padr( aChave[ 1, 3 ], Tamsx3( aChave[ 1, 2 ])[1])
	Else 
		Aadd( aChave, {"C", "T2A_TPGUIA", FTafGetVal( "/eSocial/evtContratAvNP/ideEvento/indGuia", "C", .F., @aIncons, .F. )  , .T.} ) 
		cChave += Padr( aChave[ 1, 3 ], Tamsx3( aChave[ 1, 2 ])[1])
	EndIf 

	If At("-", cPeriodo) > 0
		Aadd( aChave, {"C", "T2A_PERAPU", StrTran(cPeriodo, "-", "" ),.T.} )
		cChave += Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1])	
	Else
		Aadd( aChave, {"C", "T2A_PERAPU", cPeriodo  , .T.} ) 
		cChave += Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1])		
	EndIf

	//Verifica se o evento ja existe na base
	("T2A")->( DbSetOrder( 2 ) )
	If ("T2A")->( MsSeek( xFilial("T2A") + cChave +'1' ) )
		If !T2A->T2A_STATUS $ ( "2|4|6|" )
			nOpc := 4
		EndIf
	EndIf

	Begin Transaction	
		
		//Funcao para validar se a operacao desejada pode ser realizada
		If FTafVldOpe( 'T2A', 2, @nOpc, cFilEv, @aIncons, aChave, @oModel, 'TAFA408', cCmpsNoUpd )	

			If TafColumnPos( "T2A_LOGOPE" )
				cLogOpeAnt := T2A->T2A_LOGOPE
			endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
			//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpc <> 5

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Carrego array com os campos De/Para de gravacao das informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRules := TAF408Rul( cCodEvent, cOwner )

				oModel:LoadValue( "MODEL_T2A", "T2A_FILIAL", T2A->T2A_FILIAL )															

				If TAFColumnPos( "T2A_XMLID" )
					oModel:LoadValue( "MODEL_T2A", "T2A_XMLID", cXmlID )
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Rodo o aRules para gravar as informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nlI := 1 To Len( aRules )                 					
					oModel:LoadValue( "MODEL_T2A", aRules[ nlI, 01 ], FTafGetVal( aRules[ nlI, 02 ], aRules[nlI, 03], aRules[nlI, 04], @aIncons, .F., ,aRules[ nlI, 01 ] ) )
				Next

				If Findfunction("TAFAltMan")
					if nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T2A', 'T2A_LOGOPE' , '1', '' )
					elseif nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T2A', 'T2A_LOGOPE' , '', cLogOpeAnt )
					EndIf
				EndIf

				/*------------------------------------------
					T1Y - Remuneração do Trabalhador
				--------------------------------------------*/				
				nT1Y := 1
				cT1YPath := "/eSocial/evtContratAvNP/remunAvNP[" + CVALTOCHAR(nT1Y) + "]"
				
				If nOpc == 4
					For nlJ := 1 to oModel:GetModel( 'MODEL_T1Y' ):Length()
						oModel:GetModel( 'MODEL_T1Y' ):GoLine(nlJ)
						oModel:GetModel( 'MODEL_T1Y' ):DeleteLine()
					Next nlJ
				EndIf
				
				nT1Y := 1
				While oDados:XPathHasNode(cT1YPath) 
				
					oModel:GetModel( 'MODEL_T1Y' ):LVALID	:= .T.					

					If nOpc == 4 .Or. nT1Y > 1
						oModel:GetModel( 'MODEL_T1Y' ):AddLine()
					EndIf			
					
					If oDados:XPathHasNode(cT1YPath + "/tpInsc") .AND. oDados:XPathHasNode(cT1YPath + "/nrInsc")
						oModel:LoadValue( "MODEL_T1Y", "T1Y_ESTABE", FGetIdInt( "nrInsc", "tpInsc", cT1YPath + "/tpInsc" , cT1YPath + "/nrInsc",,,@cInconMsg, @nSeqErrGrv))
					EndIf
					If oDados:XPathHasNode(cT1YPath + "/codLotacao")
						oModel:LoadValue( "MODEL_T1Y", "T1Y_LOTACA", FGetIdInt( "codLotacao", "", cT1YPath + "/codLotacao" ,,,,@cInconMsg, @nSeqErrGrv))
					EndIf
					If oDados:XPathHasNode(cT1YPath + "/vrBcCp00")
						oModel:LoadValue( "MODEL_T1Y", "T1Y_VLBCCP", FTafGetVal( cT1YPath + "/vrBcCp00", "N", .F., @aIncons, .F. ) )
					EndIf
					If oDados:XPathHasNode(cT1YPath + "/vrBcCp15")
						oModel:LoadValue( "MODEL_T1Y", "T1Y_VBCP15", FTafGetVal( cT1YPath + "/vrBcCp15", "N", .F., @aIncons, .F. ) )
					EndIf
					If oDados:XPathHasNode(cT1YPath + "/vrBcCp20")
						oModel:LoadValue( "MODEL_T1Y", "T1Y_VBCP20", FTafGetVal( cT1YPath + "/vrBcCp20", "N", .F., @aIncons, .F. ) )	
					EndIf
					If oDados:XPathHasNode(cT1YPath + "/vrBcCp25")
						oModel:LoadValue( "MODEL_T1Y", "T1Y_VBCP25", FTafGetVal( cT1YPath + "/vrBcCp25", "N", .F., @aIncons, .F. ) )
					EndIf
					If oDados:XPathHasNode(cT1YPath + "/vrBcCp13")
						oModel:LoadValue( "MODEL_T1Y", "T1Y_VBCP13", FTafGetVal( cT1YPath + "/vrBcCp13", "N", .F., @aIncons, .F. ) )
					EndIf
					If oDados:XPathHasNode(cT1YPath + "/vrBcFgts")
						oModel:LoadValue( "MODEL_T1Y", "T1Y_VLBCFG", FTafGetVal( cT1YPath + "/vrBcFgts", "N", .F., @aIncons, .F. ) )
					EndIf
					If oDados:XPathHasNode(cT1YPath + "/vrDescCP")
						oModel:LoadValue( "MODEL_T1Y", "T1Y_VLRDES", FTafGetVal( cT1YPath + "/vrDescCP", "N", .F., @aIncons, .F. ) )
					EndIf
					
					nT1Y++
					cT1YPath := "/eSocial/evtContratAvNP/remunAvNP[" + CVALTOCHAR(nT1Y) + "]"
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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Zerando os arrays e os Objetos utilizados no processamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize( aRules, 0 ) 
	aRules     := Nil

	aSize( aChave, 0 ) 
	aChave     := Nil    

Return { lRet, aIncons } 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF408Rul           
Regras para gravacao das informacoes do registro S-1270 do E-Social

@Return	
aRull  - Regras para a gravacao das informacoes


@author Vitor Siqueira
@since 26/09/2013
@version 1.0

/*/                        	
//-------------------------------------------------------------------
Static Function TAF408Rul( cCodEvent, cOwner )
                                 
	Local aRull
	Local cPeriodo    := ""

	Default cCodEvent := ""
	Default cOwner    := ""
									
	aRull             := {}
	cPeriodo          := ""

	If !lLaySimplif
		If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtContratAvNP/ideEvento/indApuracao" ) )
			Aadd( aRull, {"T2A_INDAPU", "/eSocial/evtContratAvNP/ideEvento/indApuracao","C",.F.} ) 
		EndIf
	Else
		If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtContratAvNP/ideEvento/indGuia" ) )
			Aadd( aRull, {"T2A_TPGUIA", "/eSocial/evtContratAvNP/ideEvento/indGuia","C",.F.} ) 
		EndIf 
	EndIf 

	If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtContratAvNP/ideEvento/perApur" ) )

		cPeriodo := FTafGetVal("/eSocial/evtContratAvNP/ideEvento/perApur", "C", .F.,, .F. )
		
		If At("-", cPeriodo) > 0
			Aadd( aRull, {"T2A_PERAPU", StrTran(cPeriodo, "-", "" ) ,"C",.T.} )	
		Else
			Aadd( aRull, {"T2A_PERAPU", cPeriodo ,"C", .T.} )		
		EndIf 
	EndIf     

Return ( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclusão do evento (S-3000)

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function é chamada pelo TafIntegraESocial

@Return .T.

@Author Vitor Henrique Ferreira
@Since 11/01/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )

	Local cVerAnt    := ""
	Local cProtocolo := ""
	Local cVersao    := ""
	Local cChvRegAnt := ""
	Local cEvento    := ""
	Local cId        := ""
	Local nOperation
	Local nlI
	Local nlY
	Local nT2A
	Local nT1Y
	Local nT1YAdd
	Local aGrava
	Local aGravaT1Y
	Local oModelT2A
	Local oModelT03

	cVerAnt    := ""
	cProtocolo := ""
	cVersao    := ""
	cChvRegAnt := ""
	cEvento    := ""
	cId        := ""
	nOperation := oModel:GetOperation()
	nlI        := 0
	nlY        := 0
	nT2A       := 0
	nT1Y       := 0
	nT1YAdd    := 0
	aGrava     := {}
	aGravaT1Y  := {}
	oModelT2A  := Nil
	oModelT03  := Nil

	Begin Transaction

		//Posiciona o item
		("T2A")->( DBGoTo( nRecno ) )

		oModelT2A 	:= oModel:GetModel( 'MODEL_T2A' )
		oModelT1X	:= oModel:GetModel( 'MODEL_T1X' )
		oModelT1Y 	:= oModel:GetModel( 'MODEL_T1Y' )
							
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco a versao anterior do registro para gravacao do rastro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVerAnt   	:= oModelT2A:GetValue( "T2A_VERSAO" )
		cProtocolo	:= oModelT2A:GetValue( "T2A_PROTUL" )
		cEvento	:= oModelT2A:GetValue( "T2A_EVENTO" )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Neste momento eu gravo as informacoes que foram carregadas       ³
		//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
		//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
		//³nao devem ser consideradas neste momento                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nT2A := 1 to Len( oModelT2A:aDataModel[ 1 ] )
			aAdd( aGrava, { oModelT2A:aDataModel[ 1, nT2A, 1 ], oModelT2A:aDataModel[ 1, nT2A, 2 ] } )
		Next nT2A

		//Posicionando no registro
		DBSelectArea("T1Y")
		DBSetOrder(1)
		/*------------------------------------------
			T1Y - Remuneração do Trabalhador
		--------------------------------------------*/
		If T1Y->(MsSeek(xFilial("T1Y")+T2A->(T2A_ID + T2A_VERSAO) ) )
			For nT1Y := 1 to oModel:GetModel( "MODEL_T1Y" ):Length()
				oModel:GetModel( "MODEL_T1Y" ):GoLine(nT1Y)
			
				If !oModel:GetModel( "MODEL_T1Y" ):IsDeleted()
					aAdd (aGravaT1Y ,{oModelT1Y:GetValue('T1Y_ESTABE'),;
						oModelT1Y:GetValue('T1Y_LOTACA'),;
						oModelT1Y:GetValue('T1Y_VLBCCP'),;
						oModelT1Y:GetValue('T1Y_VBCP15'),;
						oModelT1Y:GetValue('T1Y_VBCP20'),;
						oModelT1Y:GetValue('T1Y_VBCP25'),;
						oModelT1Y:GetValue('T1Y_VBCP13'),;
						oModelT1Y:GetValue('T1Y_VLBCFG'),;
						oModelT1Y:GetValue('T1Y_VLRDES')})
								
				EndIf
			Next nT1Y
		EndIf
					
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seto o campo como Inativo e gravo a versao do novo registro³
		//³no registro anterior                                       ³ 
		//|                                                           |
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FAltRegAnt( 'T2A', '2' )

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
		For nT2A := 1 to Len( aGrava )
			oModel:LoadValue( "MODEL_T2A", aGrava[ nT2A, 1 ], aGrava[ nT2A, 2 ] )
		Next nT2A
		
		/*------------------------------------------
			T1Y - Remuneração do Trabalhador
		--------------------------------------------*/
		For nT1Y := 1 to Len( aGravaT1Y )
					
			oModel:GetModel( 'MODEL_T1Y' ):LVALID	:= .T.
		
			If nT1Y > 1
				oModel:GetModel( "MODEL_T1Y" ):AddLine()
			EndIf
			
			oModel:LoadValue( "MODEL_T1Y", "T1Y_ESTABE", aGravaT1Y[nT1Y][1] )
			oModel:LoadValue( "MODEL_T1Y", "T1Y_LOTACA", aGravaT1Y[nT1Y][2] )
			oModel:LoadValue( "MODEL_T1Y", "T1Y_VLBCCP", aGravaT1Y[nT1Y][3] )
			oModel:LoadValue( "MODEL_T1Y", "T1Y_VBCP15", aGravaT1Y[nT1Y][4] )
			oModel:LoadValue( "MODEL_T1Y", "T1Y_VBCP20", aGravaT1Y[nT1Y][5] )
			oModel:LoadValue( "MODEL_T1Y", "T1Y_VBCP25", aGravaT1Y[nT1Y][6] )
			oModel:LoadValue( "MODEL_T1Y", "T1Y_VBCP13", aGravaT1Y[nT1Y][7] )
			oModel:LoadValue( "MODEL_T1Y", "T1Y_VLBCFG", aGravaT1Y[nT1Y][8] )
			oModel:LoadValue( "MODEL_T1Y", "T1Y_VLRDES", aGravaT1Y[nT1Y][9] )

		Next nT1Y
																				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco a versao que sera gravada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVersao := xFunGetVer()

		/*---------------------------------------------------------
		ATENCAO -> A alteracao destes campos deve sempre estar     
		abaixo do Loop do For, pois devem substituir as informacoes
		que foram armazenadas no Loop acima                        
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_T2A", "T2A_VERSAO", cVersao )
		oModel:LoadValue( "MODEL_T2A", "T2A_VERANT", cVerAnt )
		oModel:LoadValue( 'MODEL_T2A', 'T2A_PROTPN', cProtocolo )
		oModel:LoadValue( 'MODEL_T2A', 'T2A_PROTUL', "" )

		/*---------------------------------------------------------
		Tratamento para que caso o Evento Anterior fosse de exclusão
		seta-se o novo evento como uma "nova inclusão", caso contrário o
		evento passar a ser uma alteração
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_T2A", "T2A_EVENTO", "E" )
		oModel:LoadValue( "MODEL_T2A", "T2A_ATIVO", "1" )

		FwFormCommit( oModel )
		TAFAltStat( 'T2A',"6" )

	End Transaction

Return ( .T. )
