#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA416.CH"

Static lLaySimplif	:= TafLayESoc("S_01_00_00")
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA416
Reabertura dos Eventos Periódicos (S-1298)

@author Paulo Santana	
@since 04/01/2016
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA416()

	Private oBrw  := FWmBrowse():New()

	oBrw:SetDescription(STR0001)    //"Reabertura dos Eventos Periódicos"
	oBrw:SetAlias( 'T1S')
	oBrw:SetMenuDef( 'TAFA416' )

	If FindFunction('TAFSetFilter')
		oBrw:SetFilterDefault(TAFBrwSetFilter("T1S","TAFA416","S-1298"))
	Else
		oBrw:SetFilterDefault( "T1S_ATIVO == '1'" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )
	EndIf

	TafLegend(2,"T1S",@oBrw)
	oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Paulo Santana	
@since 04/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao := {}
	Local aRotina := {}

	Aadd( aFuncao, { "" , "TafxmlRet('TAF416Xml','1298','T1S')" 									, "1" } )
	Aadd( aFuncao, { "" , "xFunHisAlt( 'T1S', 'TAFA416' ,,,, 'TAF416XML','1298' )" 					, "3" } )
	Aadd( aFuncao, { "" , "TAFXmlLote( 'T1S', 'S-1298' , 'evtReabreEvPer' , 'TAF416Xml',, oBrw )" 	, "5" } )
	Aadd( aFuncao, { "" , "xFunAltRec( 'T1S' )" 													, "10" } )

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If lMenuDif
		ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA416' OPERATION 2 ACCESS 0
	Else
		aRotina	:=	xFunMnuTAF( "TAFA416" , , aFuncao)
	EndIf

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Paulo Santana	
@since 04/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruT1S
	Local oModel

	oStruT1S  :=  FWFormStruct( 1, 'T1S' )
	oModel    :=  MPFormModel():New( 'TAFA416' ,,,{|oModel| SaveModel(oModel)})

	If TafColumnPos("T1S_TPGUIA") .AND. !lLaySimplif 
		oStruT1S:RemoveField( "T1S_TPGUIA" )
	EndIf

	oModel:AddFields('MODEL_T1S', /*cOwner*/, oStruT1S)

	oModel:GetModel('MODEL_T1S'):SetPrimaryKey({'T1S_FILIAL', 'T1S_ID', 'T1S_VERSAO'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Paulo Santana	
@since 04/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel
	Local oStruT1S
	Local oView
	Local cCmpFil	:= ""
	Local cGrpTra1 	:= ""
	Local cGrpTra2	:= ""
	Local cGrpTra3	:= ""
	Local aCmpGrp 	:= {}
	Local nI		:= 0

	oModel   := FWLoadModel( 'TAFA416' )
	oView    := FWFormView():New()

	oView:SetModel( oModel )

	cGrpTra1 := "T1S_INDAPU|T1S_PERAPU|T1S_TPGUIA|"

	cGrpTra2 := "T1S_PROTUL|"
	If TafColumnPos("T1S_DTRANS")
		cGrpTra3 := "T1S_DINSIS|T1S_DTRANS|T1S_HTRANS|T1S_DTRECP|T1S_HRRECP|"
	EndIf

	cCmpFil := cGrpTra1 + cGrpTra2 + cGrpTra3

	oStruT1S := FwFormStruct( 2, "T1S",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruT1S,"T1S")
	EndIf

	If TafColumnPos("T1S_TPGUIA") .AND. !lLaySimplif 
		oStruT1S:RemoveField( "T1S_TPGUIA" )
	EndIf

	If TafColumnPos("T1S_DTRANS")
		oStruT1S:AddGroup( "GRP_TRABALHADOR_01", TafNmFolder("recibo",1), "", 1 ) //Recibo da última Transmissão
		oStruT1S:AddGroup( "GRP_TRABALHADOR_02", TafNmFolder("recibo",2), "", 1 ) //Informações de Controle eSocial

		oStruT1S:SetProperty(Strtran(cGrpTra2,"|",""),MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_01")
		
		aCmpGrp := StrToKArr(cGrpTra3,"|")
		For nI := 1 to Len(aCmpGrp)
			oStruT1S:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_02")
		Next nI
	EndIf                 

	oView:AddField( 'VIEW_T1S', oStruT1S, 'MODEL_T1S' )
	oView:EnableTitleView( 'VIEW_T1S', STR0001)//"Reabertura dos Eventos Periódicos"

	oView:CreateHorizontalBox( 'FIELDST1S', 100)  

	oView:SetOwnerView( 'VIEW_T1S', 'FIELDST1S' )

	xFunRmFStr(oStruT1S, 'T1S')//Retira campos de controle da visualização da tela

	If TafColumnPos( "T1S_LOGOPE" )
		oStruT1S:RemoveField( "T1S_LOGOPE" )
	EndIf

Return oView

//-------------------------------------------------------------------	
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo	

@author Paulo Santana	
@since 04/01/2016
@version 1.0
		
@param  oModel - Modelo de dados
@return .T.
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

	Local nOperation
	Local oModelT1S
	Local cVerAnt
	Local cProtocolo
	Local cVersao
	Local cEvento
	Local cChvRegAnt
	Local cLogOpe
	Local cLogOpeAnt
	Local nX,nY
	Local aGrava
	Local lRetorno

	nOperation := oModel:GetOperation()
	oModelT1S  := oModel:GetModel("MODEL_T1S")
	cVerAnt    := ""
	cProtocolo := ""
	cVersao    := ""
	cEvento    := ""
	cChvRegAnt := ""
	cLogOpe    := ""
	cLogOpeAnt := ""
	nX         := 0
	nY         := 0
	aGrava     := {}
	lRetorno   := .T.

	Begin Transaction	

		If nOperation == MODEL_OPERATION_INSERT

			TafAjustID( "T1S", oModel)

			oModel:LoadValue( 'MODEL_T1S', 'T1S_VERSAO', xFunGetVer() )

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_T1S', 'T1S_LOGOPE' , '2', '' )
			Endif

			FwFormCommit( oModel ) 
		
		ElseIf nOperation == MODEL_OPERATION_UPDATE
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seek para posicionar no registro antes de realizar as validacoes,³
		//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
		//³os campos nao usados como _STATUS                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		T1S->( DbSetOrder( 3 ) )
		If T1S->( MsSeek( xFilial( 'T1S' ) + FwFldGet("T1S_ID") + '1' ) )
					
			If T1S->T1S_STATUS == "4"
					
				oModelT1S := oModel:GetModel( 'MODEL_T1S' )  
							
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Busco a versao anterior do registro para gravacao do rastro³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cVerAnt   	:= oModelT1S:GetValue( "T1S_VERSAO" )				
				cProtocolo	:= oModelT1S:GetValue( "T1S_PROTUL" )
				cEvento		:= oModelT1S:GetValue( "T1S_EVENTO" )

				If TafColumnPos( "T1S_LOGOPE" )
					cLogOpeAnt := oModelT1S:GetValue( "T1S_LOGOPE" )
				endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Neste momento eu gravo as informacoes que foram carregadas    ³
				//³na tela, pois o usuario ja fez as modificacoes que precisava  ³
				//³mesmas estao armazenadas em memoria, ou seja, nao devem ser   ³
				//³consideradas agora.					                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nX := 1 To 1
					For nY := 1 To Len( oModelT1S:aDataModel[ nX ] )			
						Aadd( aGrava, { oModelT1S:aDataModel[ nX, nY, 1 ], oModelT1S:aDataModel[ nX, nY, 2 ] } )									
					Next
				Next  
							
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Seto o campo como Inativo e gravo a versao do novo registro³
				//³no registro anterior                                       ³ 
				//|                                                           |
				//|ATENCAO -> A alteracao destes campos deve sempre estar     |
				//|abaixo do Loop do For, pois devem substituir as informacoes|
				//|que foram armazenadas no Loop acima                        |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FAltRegAnt( 'T1S', '2' ) 
							
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
					oModel:LoadValue( 'MODEL_T1S', aGrava[ nX, 1 ], aGrava[ nX, 2 ] )
				Next

				//Necessário Abaixo do For Nao Retirar
				If Findfunction("TAFAltMan")
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T1S', 'T1S_LOGOPE' , '' , cLogOpeAnt )
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
				oModel:LoadValue( 'MODEL_T1S', 'T1S_VERSAO', cVersao )
				oModel:LoadValue( 'MODEL_T1S', 'T1S_VERANT', cVerAnt )
				oModel:LoadValue( 'MODEL_T1S', 'T1S_PROTPN', cProtocolo )
				oModel:LoadValue( 'MODEL_T1S', 'T1S_PROTUL', "" )		
				oModel:LoadValue( 'MODEL_T1S', 'T1S_EVENTO', "A" )
				// Tratamento para limpar o ID unico do xml
				cAliasPai := "T1S"

				If TAFColumnPos( cAliasPai+"_XMLID" )
					oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
				EndIf

				FwFormCommit( oModel )
				TAFAltStat( 'T1S', " " )

			ElseIf T1S->T1S_STATUS == "2"

				TAFMsgVldOp( oModel, "2" )//"Registro não pode ser alterado. Aguardando processo da transmissão."
				lRetorno := .F.

			Else

				//alteração sem transmissão
				If TafColumnPos( "T1S_LOGOPE" )
					cLogOpeAnt := T1S->T1S_LOGOPE
				endif

				If Findfunction("TAFAltMan")
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T1S', 'T1S_LOGOPE' , '' , cLogOpeAnt )
				EndIf
				FwFormCommit( oModel )
				TAFAltStat( 'T1S', " " )

			EndIf
		EndIf
			
		//Exclusão Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_DELETE

			If T1S->T1S_STATUS == "4"

				oModel:SetErrorMessage(, , , , , xValStrEr("000783"), , , ) //"Registro não pode ser excluído, pois o evento já se encontra base do RET"  
				lRetorno := .F.
			
			Else
		
				cChvRegAnt := T1S->(T1S_ID + T1S_VERANT)  	  

				TAFAltStat( 'T1S', " " )
				FwFormCommit( oModel )

				If T1S->T1S_EVENTO == "A" .Or. T1S->T1S_EVENTO == "E"
					TAFRastro( 'T1S', 1, cChvRegAnt, .T. , , IIF(Type("oBrw") == "U", Nil, oBrw) )
				EndIf

			EndIf

		EndIf 

	End Transaction     

Return ( lRetorno )	 
	
//-------------------------------------------------------------------	
/*/{Protheus.doc} TAF416Xml
Retorna o Xml do Registro Posicionado 
	
@author Evandro dos Santos Oliveira
@since 28/10/2013
@version 1.0
		
@Param:
lJob - Informa se foi chamado por Job

@return
cXml - Estrutura do Xml do Layout S-1298 
/*/
//-------------------------------------------------------------------
Function TAF416Xml(cAlias,nRecno,nOpc,lJob)

	Local cXml
	Local cLayout
	Local cReg
	Local aMensal

	cXml    := ""
	cLayout := "1298"
	cReg	:= "ReabreEvPer"

	If !lLaySimplif
		If T1S->T1S_INDAPU == '1'
			aMensal := {T1S->T1S_INDAPU,substr(T1S->T1S_PERAPU,1,4) + "-" + substr(T1S->T1S_PERAPU,5,2)}
		Else
			aMensal := {T1S->T1S_INDAPU,substr(T1S->T1S_PERAPU,1,4)}
		EndIf
	Else
		If T1S->T1S_INDAPU == '1'
			aMensal := {T1S->T1S_INDAPU,substr(T1S->T1S_PERAPU,1,4) + "-" + substr(T1S->T1S_PERAPU,5,2),T1S->T1S_TPGUIA}
		Else
			aMensal := {T1S->T1S_INDAPU,substr(T1S->T1S_PERAPU,1,4),T1S->T1S_TPGUIA}
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Estrutura do cabecalho³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cXml := xTafCabXml(cXml,"T1S", cLayout,cReg, aMensal)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa gravacao do registro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lJob
		xTafGerXml(cXml,cLayout)
	EndIf
	
Return(cXml)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF416Grv
@type			function
@description	
@author			Evandro dos Santos Oliveira
@since			25/10/2013
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
Function TAF416Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

	Local cLogOpeAnt   := ""
	Local cCmpsNoUpd   := "|T1S_FILIAL|T1S_ID|T1S_VERSAO|T1S_VERANT|T1S_PROTUL|T1S_PROTPN|T1S_EVENTO|T1S_STATUS|T1S_ATIVO|"
	Local cCabec       := "/eSocial/evtReabreEvPer"
	Local lRet         := .F.
	Local aIncons      := {}
	Local aChave       := {}
	Local oModel       := Nil
	Local IndApu       := ""
	Local PerApu       := ""
	Local cIndGuia     := ""
	Local nInd         := 2
 
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

	oDados := oXML

	If lLaySimplif

		nInd := 4

	EndIf
	
	If nOpc <> 5

		Aadd( aChave, { "C", "T1S_INDAPU"	, cCabec + "/ideEvento/indApuracao", .F. } )
		aAdd( aChave, { "C", "T1S_PERAPU", StrTran(FTafGetVal( cCabec + "/ideEvento/perApur", "C", .F., @aIncons, .F. ),"-",""), .T. } )
		
		If lLaySimplif			
			aAdd( aChave, { "C", "T1S_TPGUIA", cCabec + "/ideEvento/indGuia", .F. } )
		EndIf
		
		//Verifica se o evento ja existe na base
		IndApu		:= FTafGetVal( aChave[ 01, 03 ], aChave[01, 01], aChave[01, 04], @aIncons, .F. )
		PerApu		:= aChave[ 02, 03 ]
		
		If lLaySimplif	
			cIndGuia	:= FTafGetVal( aChave[ 03, 03 ], aChave[03, 01], aChave[03, 04], @aIncons, .F. )
		EndIf

		If !lLaySimplif

			("T1S")->( DbSetOrder( 2 ) )
			If ("T1S")->( MsSeek( xFilial("T1S") + IndApu + PadR(PerApu, GetSx3Cache("T1S_PERAPU", "X3_TAMANHO")) + "1" ) )
				nOpc := 4
			EndIf

		Else

			("T1S")->( DbSetOrder( 4 ) )
			If ("T1S")->( MsSeek( xFilial("T1S") + IndApu + PadR(PerApu, GetSx3Cache("T1S_PERAPU", "X3_TAMANHO")) + PadR(cIndGuia, GetSx3Cache("T1S_TPGUIA", "X3_TAMANHO")) + "1" ) )
				nOpc := 4
			EndIf

		EndIf

		Begin Transaction 

			If FTafVldOpe( "T1S", nInd, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA416", cCmpsNoUpd )

				If TafColumnPos( "T1S_LOGOPE" )
					cLogOpeAnt := T1S->T1S_LOGOPE
				EndIf
				
				oModel:LoadValue( "MODEL_T1S", "T1S_FILIAL", T1S->T1S_FILIAL )															
				oModel:LoadValue( "MODEL_T1S", "T1S_INDAPU", IndApu )
				oModel:LoadValue( "MODEL_T1S", "T1S_PERAPU", PerApu )

				If lLaySimplif
					oModel:LoadValue( "MODEL_T1S", "T1S_TPGUIA", cIndGuia )
				EndIf

				If TAFColumnPos( "T1S_XMLID" )
					oModel:LoadValue( "MODEL_T1S", "T1S_XMLID", cXmlID )
				EndIf

				If Findfunction("TAFAltMan")

					If nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T1S', 'T1S_LOGOPE' , '1', '' )
					ElseIf nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T1S', 'T1S_LOGOPE' , '', cLogOpeAnt )
					EndIf

				EndIf

				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Efetiva a operacao desejada³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				If Empty(aIncons)
					FWFormCommit( oModel )
					lRet := .T.
				EndIf
				
				oModel:DeActivate()
				If FindFunction('TafClearModel')
					TafClearModel(oModel)
				EndIf
		
			EndIf

		End Transaction	

	EndIf

Return { lRet, aIncons }
