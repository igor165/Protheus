#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA529.CH"

Static __lLay0205	:= TafLayESoc("02_05_00")
Static __cTafAmb	:= SuperGetMv('MV_TAFAMBE')

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA529
Cadastro MVC de Convocação para Trabalho Intermitente S-2245
 
@author Ricardo Lovrenovic
@since 28/01/2018
@version 1.0
/*/
//--------------------------------------------------------------------
Function TAFA529()

	Private oBrw := FwMBrowse():New()

	If FindFunction("TAFDesEven")
		TAFDesEven()
	EndIf

	// Função que indica se o ambiente é válido para o eSocial 2.5
	If TAFAlsInDic( "V3C" )

		If !__lLay0205

			cMessage :="Este evento só pode ser transmitido na versão 2.5 e parametro MV_TAFVLES está configurado com uma versão anterior." //"Este evento só pode ser transmitido na versão 2.5 e parametro MV_TAFVLES está configurado com uma versão anterior."
			cMessage += Chr( 13 ) + Chr( 10 )	
			cMessage += "Verifique." // "Verifique."
			Aviso( "Atenção!", cMessage, { "Encerrar" }, 2 ) //##"Atenção!" ##"Encerrar"
			
		Else

			oBrw:SetDescription(STR0001)  //Treinamentos, Capacitações, Exercícios Simulados e Outras Anotações 
			oBrw:SetAlias("V3C")
			oBrw:SetMenuDef("TAFA529")

			If FindFunction('TAFSetFilter')
				oBrw:SetFilterDefault(TAFBrwSetFilter("V3C","TAFA529","S-2245"))
			Else
				oBrw:SetFilterDefault( "V3C_ATIVO == '1'" ) //Filtro para que apenas os registros ativos sejam exibidos (1 = Ativo, 2 = Inativo)
			EndIf

			TafLegend(2,"V3C",@oBrw)
			oBrw:Activate()

		EndIf
		
	Else

		cMessage := "Ambiente desatualizado com a versão do programa existente no repositório de dados."  //"Ambiente desatualizado com a versão do programa existente no repositório de dados."
		cMessage += Chr( 13 ) + Chr( 10 )	   
		cMessage += Chr( 13 ) + Chr( 10 )	  
		cMessage += "Execute a atualização do dicionário do Layout 2.5 do eSocial por meio do compatibilizador UPDDISTR." //"Execute a atualização do dicionário do Layout 2.5 do eSocial por meio do compatibilizador UPDDISTR."
		Aviso( "Dicionário Incompatível", cMessage, { "Encerrar" }, 2 ) //##"Dicionário Incompatível" ##"Encerrar"
	
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Ricardo Lovrenovic
@since 28/01/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao := {}
	Local aRotina := {}

	If FindFunction('TafXmlRet')
		Aadd( aFuncao, { "" , "TafxmlRet('TAF529Xml','2245','V3C')" , "1" } )
	Else
		Aadd( aFuncao, { "" , "TAF529Xml" , "1" } )
	EndIf

	//Chamo a Browse do Histórico
	If FindFunction( "xNewHisAlt" ) 
		Aadd( aFuncao, { "" , "xNewHisAlt( 'V3C', 'TAFA529' ,,,,,,'2245','TAF529Xml' )" , "3" } )
	Else
		Aadd( aFuncao, { "" , "xFunHisAlt( 'V3C', 'TAFA529' ,,,, 'TAF529XML','2245' )" , "3" } )
	EndIf

	Aadd( aFuncao, { "" , "TAFXmlLote( 'V3C', 'S-2245' , 'TreiCap' , 'TAF529Xml',, oBrw )" , "5" } )
	Aadd( aFuncao, { "" , "xFunAltRec( 'V3C' )" , "10" } )

	lMenuDIf := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDIf )

	If lMenuDif .Or. ViewEvent('S-2245')
		ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.TAFA529' OPERATION 2 ACCESS 0 //"Visualizar"
		
		// Menu dos extemporâneos
		If !ViewEvent('S-2245') .AND. FindFunction( "xNewHisAlt" ) .AND. FindFunction( "xTafExtmp" ) .And. xTafExtmp()
			aRotina	:= xMnuExtmp( "TAFA529", "V3C" )
		EndIf
		
	Else
		aRotina	:=	xFunMnuTAF( "TAFA529" , , aFuncao)
	EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Ricardo Lovrenovic
@since 28/01/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStruV3C := FwFormStruct(1,"V3C")
	Local oStruV3G := FwFormStruct(1,"V3G")

	Local oModel   := MpFormModel():New("TAFA529",,,{|oModel| SaveModel(oModel)})

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruV3C:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruV3G:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	EndIf

	// Campos chave que não podem ser alterados após uma inclusão.
	oStruV3C:SetProperty("V3C_FUNC"  , MODEL_FIELD_NOUPD, .T.)
	oStruV3C:SetProperty("V3C_CODTCA", MODEL_FIELD_NOUPD, .T.)

	oModel:AddFields("MODEL_V3C",/*cOwner*/,oStruV3C)

	oModel:AddGrid("MODEL_V3G", "MODEL_V3C", oStruV3G)
	oModel:GetModel( "MODEL_V3G" ):SetUniqueLine({"V3G_CPF"},{|| IIF(Empty(FwFldGet("V3G_CPF")),.T.,.F.) })
	oModel:GetModel( "MODEL_V3G" ):SetMaxLine(99)
	oModel:GetModel( "MODEL_V3G" ):SetOptional( .T. )

	oModel:SetRelation( "MODEL_V3G" , { { "V3G_FILIAL", "xFilial('V3G')" }, { "V3G_ID", "V3C_ID" }, { "V3G_VERSAO", "V3C_VERSAO" } },V3G->(IndexKey(1) ) )


	oModel:GetModel("MODEL_V3C"):SetPrimaryKey({"V3C_ID"}) //Definiçao da chave primaria/modelo

Return(oModel)

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Ricardo Lovrenovic
@since 28/01/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel    := FWLoadModel("TAFA529")
	Local oStruV3Ca := Nil
	Local oStruV3Cb := Nil
	Local oStruV3Cc := Nil
	Local oStruV3G  := FWFormStruct( 2, "V3G" )
	Local oStruV3Cf := Nil
	Local oStruV3Cg := Nil
	Local oView     := FWFormView():New()
	Local nI        := 0
	Local aCmpGrp   := {}
	Local cCmpFil   := ""
	Local cGrupo1   := ""
	Local cGrupo2   := ""
	Local cGrupo3   := ""
	Local cGrupo6   := ""

	oView:SetModel(oModel)
	oView:SetContinuousForm(.T.)

	//"Informações de Identificação do Trabalhador e do Vínculo"
	cGrupo1  := 'V3C_ID|V3C_VERSAO|V3C_VERANT|V3C_PROTPN|V3C_EVENTO|V3C_ATIVO|V3C_FUNC|V3C_DFUNC|'
	cCmpFil   := cGrupo1 
	oStruV3Ca := FwFormStruct( 2, 'V3C', {|x| AllTrim( x ) + "|" $ cCmpFil } )
	//oStruV3Ca:SetProperty( "V3C_FUNC" , MVC_VIEW_LOOKUP , "C9V" )

	//Treinamentos, Capacitações e Exercícios Simulados Específicos para Trabalho. 
	cGrupo2  := 'V3C_CODTCA|V3C_DESTCA|V3C_OBSTCA|'
	cCmpFil   := cGrupo2 
	oStruV3Cb := FwFormStruct( 2, 'V3C', {|x| AllTrim( x ) + "|" $ cCmpFil } )
	oStruV3Cb:SetProperty("V3C_DESTCA", MVC_VIEW_ORDEM, "08"	)

	//Informações complementares referentes ao treinamento/capacitação/exercício simulado. 
	cGrupo3  := 'V3C_DTTCAP|V3C_DUTCAP|V3C_MODTCA|V3C_TPTCAP|'

	If TafColumnPos("V3C_TREANT") .And. ((Date() >= Ctod("25/04/2019") .and. __cTafAmb == '2') .or. (Date() >= Ctod("10/07/2019") .and. __cTafAmb == '1'))
		cGrupo3 += 'V3C_TREANT|'
	EndIf

	cCmpFil   := cGrupo3 
	oStruV3Cc := FwFormStruct( 2, 'V3C', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	//"Protocolo de Transmissão"
	cGrupo6 := 'V3C_PROTUL|'
	cCmpFil   := cGrupo6
	oStruV3Cf := FwFormStruct( 2, 'V3C', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	If TafColumnPos("V3C_DTRANS")
		cCmpFil := "V3C_DINSIS|V3C_DTRANS|V3C_HTRANS|V3C_DTRECP|V3C_HRRECP|"
		oStruV3Cg := FwFormStruct( 2, 'V3C', {|x| AllTrim( x ) + "|" $ cCmpFil } )
	EndIf

	/*--------------------------------------------------------------------------------------------
			Grupo de campos da Convocação para Trabalho Intermitente
	---------------------------------------------------------------------------------------------*/
	oStruV3Ca:AddGroup( "GRP_IDENTIFICACAO", STR0007, "", 1 ) //"Informações de Identificação do Trabalhador e do Vínculo" 

	aCmpGrp := StrToKArr(cGrupo1,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruV3Ca:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_IDENTIFICACAO")
	Next nI

	oStruV3Cb:AddGroup( "GRP_TREINO", STR0008, "", 1 ) //"Treinamentos, Capacitações e Exercícios Simulados Específicos para Trabalho."

	aCmpGrp := StrToKArr(cGrupo2,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruV3Cb:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TREINO")
	Next nI

	oStruV3Cc:AddGroup( "GRP_INFOCOMPL", STR0009, "", 1 ) //"Informações complementares referentes ao treinamento/capacitação/exercício simulado."

	aCmpGrp := StrToKArr(cGrupo3,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruV3Cc:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_INFOCOMPL")
	Next nI

	oStruV3G:AddGroup( "GRP_RESPONSA", STR0010, "", 1 ) //"Informações relativas ao profissional responsável pelo treinamento/capacitação/exercício simulado"
	//aCmpGrp := StrToKArr(cGrupo4,"|")
	//For nI := 1 to Len(aCmpGrp)
	//	oStruV3G:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_RESPONSA")
	//Next nI

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruV3Cf,"V3C")
	EndIf

	/*--------------------------------------------------------------------------------------------
											Esrutura da View
	---------------------------------------------------------------------------------------------*/
	oView:AddField( 'VIEW_V3Ca' , oStruV3Ca,    'MODEL_V3C' )

	oView:AddField( 'VIEW_V3Cb' , oStruV3Cb,    'MODEL_V3C' )

	oView:AddField( 'VIEW_V3Cc' , oStruV3Cc,    'MODEL_V3C' )

	oView:AddField( 'VIEW_V3Cf' , oStruV3Cf,    'MODEL_V3C' )

	oView:AddGrid ( 'VIEW_V3G'	, oStruV3G ,    'MODEL_V3G' )
	oView:EnableTitleView("VIEW_V3G",STR0010)

	oView:EnableTitleView( 'VIEW_V3Cf', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"  
	If TafColumnPos("V3C_DTRANS")
		oView:AddField( 'VIEW_V3Cg' , oStruV3Cg,    'MODEL_V3C' )
		oView:EnableTitleView( 'VIEW_V3Cg', TafNmFolder("recibo",2) ) 
	EndIf

	/*--------------------------------------------------------------------------------------------
										Estrutura do Folder
	---------------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox("PAINEL_SUPERIOR",100)
	oView:CreateFolder("FOLDER_SUPERIOR","PAINEL_SUPERIOR")

	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0001 )  

	If FindFunction("TafNmFolder")
		oView:AddSheet( 'FOLDER_SUPERIOR', "ABA02", TafNmFolder("recibo") )   //"Numero do Recibo"
	Else
		oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0012 )   //Protocolo de transmissão
	EndIf 

	oView:CreateHorizontalBox( 'V3Ca',  015,,, 'FOLDER_SUPERIOR', 'ABA01' )
	oView:CreateHorizontalBox( 'V3Cb',  015,,, 'FOLDER_SUPERIOR', 'ABA01' )
	oView:CreateHorizontalBox( 'V3Cc',  015,,, 'FOLDER_SUPERIOR', 'ABA01' )
	oView:CreateHorizontalBox( 'V3G' ,  010,,, 'FOLDER_SUPERIOR', 'ABA01' )

	If TafColumnPos("V3C_DTRANS")
		oView:CreateHorizontalBox( 'V3Cf',  20,,, 'FOLDER_SUPERIOR', 'ABA02' )
		oView:CreateHorizontalBox( 'V3Cg',  80,,, 'FOLDER_SUPERIOR', 'ABA02' )
	Else
		oView:CreateHorizontalBox( 'V3Cf',  100,,, 'FOLDER_SUPERIOR', 'ABA02' ) // folder do _PROTUL
	EndIf

	oView:SetOwnerView( "VIEW_V3Ca", "V3Ca")
	oView:SetOwnerView( "VIEW_V3Cb", "V3Cb")
	oView:SetOwnerView( "VIEW_V3Cc", "V3Cc")
	oView:SetOwnerView( "VIEW_V3G",  "V3G")
	oView:SetOwnerView( "VIEW_V3Cf", "V3Cf")
	If TafColumnPos("V3C_DTRANS")
		oView:SetOwnerView( "VIEW_V3Cg", "V3Cg")
	EndIf

	lMenuDIf := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDIf )

	oStruV3Ca:RemoveField( "V3C_ID" )

	If !lMenuDif
		xFunRmFStr(@oStruV3Ca, 'V3C')
		xFunRmFStr(@oStruV3Cb, 'V3C')
		xFunRmFStr(@oStruV3Cc, 'V3C')
		xFunRmFStr(@oStruV3G,  'V3G')
		xFunRmFStr(@oStruV3Cf, 'V3C')
	EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Ricardo Lovrenovic
@since 09/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

	Local cVerAnt    := ""
	Local cProtocolo := ""
	Local cVersao    := ""
	Local cChvRegAnt := ""
	Local cEvento    := ""
	Local nOperation := oModel:GetOperation()
	Local nlI        := 0
	Local lRetorno   := .T.
	Local aGrava     := {}
	Local oModelV3C  := Nil

	Default oModel   := Nil

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT

		TafAjustID( "V3C", oModel)

			oModel:LoadValue( 'MODEL_V3C', 'V3C_VERSAO', xFunGetVer() )

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_V3C', 'V3C_LOGOPE' , '2', '' )
			Endif

			FwFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			V3C->( DbSetOrder( 3 ) )
			If lGoExtemp .OR. V3C->( MsSeek( xFilial( 'V3C' ) + M->V3C_ID + '1' ) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o registro ja foi transmitido com sucesso    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If V3C->V3C_STATUS ==  "4"

					oModelV3C := oModel:GetModel( 'MODEL_V3C' )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao anterior do registro para gravacao do rastro³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVerAnt    	:= oModelV3C:GetValue( "V3C_VERSAO" )
					cProtocolo 	:= oModelV3C:GetValue( "V3C_PROTUL" )
					cEvento		:= oModelV3C:GetValue( "V3C_EVENTO" )

					If TafColumnPos( "V3C_LOGOPE" )
						cLogOpeAnt := oModelV3C:GetValue( "V3C_LOGOPE" )
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu gravo as informacoes que foram carregadas       ³
					//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
					//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
					//³nao devem ser consideradas neste momento                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nlI := 1 to Len( oModelV3C:aDataModel[ 1 ] )
						Aadd( aGrava, { oModelV3C:aDataModel[ 1, nlI, 1 ], oModelV3C:aDataModel[ 1, nlI, 2 ] } )
					Next nlI

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seto o campo como Inativo e gravo a versao do novo registro³
					//³no registro anterior                                       ³
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FAltRegAnt( 'V3C', '2' )	

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
						oModel:LoadValue( 'MODEL_V3C', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
					Next

					//Necessário Abaixo do For Nao Retirar
					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_V3C', 'V3C_LOGOPE' , '' , cLogOpeAnt )
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
					oModel:LoadValue( 'MODEL_V3C', 'V3C_VERSAO', cVersao )
					oModel:LoadValue( 'MODEL_V3C', 'V3C_VERANT', cVerAnt )
					oModel:LoadValue( 'MODEL_V3C', 'V3C_PROTPN', cProtocolo )
					oModel:LoadValue( 'MODEL_V3C', 'V3C_PROTUL', "" )  

					oModel:LoadValue( "MODEL_V3C", "V3C_EVENTO", "A" )
					// Tratamento para limpar o ID unico do xml
					cAliasPai := "V3C"
					If TAFColumnPos( cAliasPai+"_XMLID" )
						oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					EndIf

					//Gravo alteração para o Extemporâneo
					If lGoExtemp
						TafGrvExt( oModel, 'MODEL_V3C', 'V3C' )			
					Endif	

					FwFormCommit( oModel )
					TAFAltStat( 'V3C', " " )

				ElseIf	V3C->V3C_STATUS == "2"
					TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
					lRetorno:= .F.
				ElseIf V3C->V3C_STATUS == "6"
					TAFMsgVldOp(oModel,"6")//"Registro não pode ser alterado. Aguardando proc. Transm. evento de Exclusão S-3000"
					lRetorno:= .F.
				ElseIf V3C->V3C_STATUS == "7"
					TAFMsgVldOp(oModel,"7") //"Registro não pode ser alterado, pois o evento já se encontra na base do RET"
					lRetorno:= .F.
				Else
					If TafColumnPos( "V3C_LOGOPE" )
						cLogOpeAnt := V3C->V3C_LOGOPE
					endif

					//Gravo alteração para o Extemporâneo
					If lGoExtemp
						TafGrvExt( oModel, 'MODEL_V3C', 'V3C' )			
					Endif

					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_V3C', 'V3C_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					FwFormCommit( oModel )
					TAFAltStat( 'V3C', " " )
				EndIf
			EndIf

		//Exclusão Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_DELETE

			cChvRegAnt := V3C->(V3C_ID + V3C_VERANT)

			If !Empty( V3C->V3C_VERANT )
				
				TAFAltStat( 'V3C', " " )
				FwFormCommit( oModel )
				
				If V3C->V3C_EVENTO == "A" .Or. V3C->V3C_EVENTO == "E"
					TAFRastro( 'V3C', 1, cChvRegAnt, .T. , , IIF(Type("oBrw") == "U", Nil, oBrw) )
				EndIf

			Else

				oModel:DeActivate()
				oModel:SetOperation( 5 )
				oModel:Activate()
				FwFormCommit( oModel )

			EndIf

		EndIf

	End Transaction

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF529Xml
Funcao de geracao do XML para atender o registro S-2245
Quando a rotina for chamada o registro deve estar posicionado

@Param:
cAlias - Alias da Tabela
nRecno - Recno do Registro corrente
nOpc   - Operacao a ser realizada
lJob   - Informa se foi chamado por Job

@Return:
cXml - Estrutura do Xml do Layout S-2245

@author Ricardo Lovrenovic
@since 06/11/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF529Xml(cAlias,nRecno,nOpc,lJob,lAutomato,cFile)

	Local cXml         := ""
	Local cXmlProfResp := ""
	Local cLayout      := "2245"
	Local cReg         := "TreiCap"
	Local cIdCateg     := ""
	Local cCodCat      := ""
	Local lXmlVLd      := IIF(FindFunction( 'TafXmlVLD' ),TafXmlVLD( 'TAF529XML' ),.T.)

	Default cAlias     := "V3C"
	Default lJob       := .F.
	Default nRecno     := 1
	Default nOpc       := 1
	Default lAutomato  := .F.
	Default cFile      := ""

	DBSelectArea("C9V")
	C9V->(DBSetOrder(2))
	If lXmlVld

		cXml +=	"<ideVinculo>"

		If C9V->( MSSeek( xFilial("C9V") + V3C->V3C_FUNC + "1" ) )
			cXml +=	xTafTag("cpfTrab"		,C9V->C9V_CPF	)
			cXml +=	xTafTag("nisTrab"		,C9V->C9V_NIS,,.T.	)
			If !Empty(C9V->C9V_MATRIC)
				cXml +=	xTafTag("matricula"		,C9V->C9V_MATRIC)
			EndIf
			
			//If C9V->C9V_NOMEVE == "S2200"
			//	cIdCateg := Posicione("CUP",1,xFilial("CUP") + C9V->(C9V_ID + C9V_VERSAO), "CUP_CODCAT")
			
			If C9V->C9V_NOMEVE == "S2300"
				cIdCateg := C9V->C9V_CATCI
				If !Empty( cIdCateg )
					cCodCat := Posicione("C87",1,xFilial("C87") + cIdCateg, "C87_CODIGO")
				EndIf
				cXml +=	xTafTag("codCateg",cCodCat)
			EndIf
			

		EndIf

		cXml +=	"</ideVinculo>"

		cXml +=	"<treiCap>"
		cXml +=		xTafTag("codTreiCap",AllTrim(Posicione("V2M",1,xFilial("V2M") + V3C->V3C_CODTCA, "V2M_CODIGO")))
		cXml +=		xTafTag("obsTreiCap",AllTrim(V3C->V3C_OBSTCA),,.T.	)

		If V3G->(MsSeek(xFilial('V3C')+V3C->V3C_ID+V3C->V3C_VERSAO) )

			While V3G->(!Eof()) .and. ((xFilial('V3G')+V3G->V3G_ID+V3G->V3G_VERSAO) == (xFilial('V3C')+V3C->V3C_ID+V3C->V3C_VERSAO))
				xTafTagGroup("ideProfResp"			,{{"cpfProf"	,V3G->V3G_CPF,,.T.  };
													, {"nmProf"		,V3G->V3G_NOME,,.T.	};
													, {"tpProf"		,V3G->V3G_TPPROF	};
													, {"formProf"	,V3G->V3G_FORMPR	};
													, {"codCBO"		, Posicione( "C8Z", 1, xFilial( "C8Z" ) + V3G->V3G_CODCBO, "C8Z_CODIGO" ),, .F. };
													, {"nacProf"	,V3G->V3G_NACPRO	}};
													, @cXmlProfResp)

				V3G->(DBSkip())
			EndDo

		EndIf

		xTafTagGroup("infoComplem"	,{{"dtTreiCap"	,V3C->V3C_DTTCAP,,.T. } ;
									, {"durTreiCap"	,V3C->V3C_DUTCAP,,.T. } ;
									, {"modTreiCap"	,V3C->V3C_MODTCA,,.T. } ;
									, {"tpTreiCap"	,V3C->V3C_TPTCAP,,.T. } ;
									, {"indTreinAnt",V3C->V3C_TREANT,,.T. }};
									, @cXml, { { "ideProfResp", cXmlProfResp, 0 }})

		cXml +=	"</treiCap>"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estrutura do cabecalho³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cXml := xTafCabXml(cXml,"V3C",cLayout,cReg)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa gravacao do registro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If !lJob
			If lAutomato
				xTafGerXml( cXml, cLayout,,, .F.,, @cFile )
			Else
				xTafGerXml( cXml, cLayout )
			EndIf
		EndIf
	EndIf

Return(cXml)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF529Grv
Funcao de gravacao para atender o registro S-2245

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

@author Ricardo Lovrenovic
@since 06/11/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF529Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

	Local cCmpsNoUpd	:= "|V3C_FILIAL|V3C_ID|V3C_VERSAO|V3C_VERANT|V3C_PROTPN|V3C_EVENTO|V3C_STATUS|V3C_ATIVO|"
	Local cChave	 	:= ""
	Local cInconMsg 	:= ""
	Local cCodEvent 	:= Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")
	Local cV3GPath		:=  ""
	Local cCabec		:=	"/eSocial/evtTreiCap/"
	Local cCodTca		:= ""
	Local cIdFunc		:= ""
	Local nlI        	:= 0
	Local nIG			:= 0
	Local nSeqErrGrv	:= 0
	Local lRet 			:= .F.
	Local aIncons		:= {}
	Local aRules 		:= {}
	Local aChave  		:= {}
	Local oModel  		:= Nil

	Private lVldModel	:= .T.		//Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.
	Private oDados 		:= oXML

	Default cLayout		:= ""
	Default nOpc 		:= 1
	Default cFilEv 		:= ""
	Default oXML		:= Nil
	Default cOwner		:= ""
	Default cFilTran	:=	""
	Default cPredeces	:=	""
	Default nTafRecno	:=	0
	Default cComplem	:=	""
	Default cGrpTran	:=	""
	Default cEmpOriGrp	:=	""
	Default cFilOriGrp	:=	""
	Default cXmlID		:=	""

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtTreiCap/ideVinculo/matricula") ) .And. !Empty(FTafGetVal( "/eSocial/evtTreiCap/ideVinculo/matricula", "C", .F., , .F. ))
		cIdFunc := FGetIdInt( "cpfTrab","matricula","/eSocial/evtTreiCap/ideVinculo/cpfTrab","/eSocial/evtTreiCap/ideVinculo/matricula",,,@cInconMsg, @nSeqErrGrv)
	ElseIf TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtTreiCap/ideVinculo/cpfTrab") )
		If !Empty(FTafGetVal( "/eSocial/evtTreiCap/ideVinculo/codCateg", "C", .F., , .F. ))
			cIdFunc := FGetIdInt( "cpfTrab",,"/eSocial/evtTreiCap/ideVinculo/cpfTrab",,,,@cInconMsg, @nSeqErrGrv,"codCateg","/eSocial/evtTreiCap/ideVinculo/codCateg")
		Else
			cIdFunc := FGetIdInt( "cpfTrab",,"/eSocial/evtTreiCap/ideVinculo/cpfTrab",,,,@cInconMsg, @nSeqErrGrv)
		EndIf
	EndIf

	If oDados:XPathHasNode("/eSocial/evtTreiCap/treiCap/codTreiCap")
		cCodTca := FGetIdInt( "codTreiCap", "", FTafGetVal( "/eSocial/evtTreiCap/treiCap/codTreiCap", "C", .F., @aIncons, .F. ), , .F.,,@cInconMsg, @nSeqErrGrv)
	EndIf

	Aadd( aChave, { "C", "V3C_CODTCA"  	, cCodTca, .T. } ) 
	Aadd( aChave, { "C", "V3C_FUNC"		, cIdFunc, .T. } )

	cChave	:= Padr( cCodTca, Tamsx3( aChave[ 1, 2 ])[1] ) + Padr( cIdFunc, Tamsx3( aChave[ 2, 2 ])[1] )

	//Verifica se o evento ja existe na base
	DbSelectArea("V3C")
	V3C->(DbSetOrder(2))
	If (V3C->(DbSeek(xFilial("V3C") + cChave + "1")))
		If !(V3C->V3C_STATUS $ "2|4|9")
			nOpc := 4
		Endif
	Endif

	Begin Transaction

		//Funcao para validar se a operacao desejada pode ser realizada
		If FTafVldOpe( 'V3C', 2, @nOpc, cFilEv, @aIncons, aChave, @oModel, 'TAFA529', cCmpsNoUpd,1 )

			If TafColumnPos( "V3C_LOGOPE" )
				cLogOpeAnt := V3C->V3C_LOGOPE
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrego array com os campos De/Para de gravacao das informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aRules := TAF529Rul( cLayout, @cInconMsg, @nSeqErrGrv, cCodEvent, cOwner )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
			//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpc <> 5
				
				oModel:LoadValue( "MODEL_V3C", "V3C_FILIAL", V3C->V3C_FILIAL )

				oModel:LoadValue( "MODEL_V3C", "V3C_XMLID" , cXmlID  )
				
				oModel:LoadValue( "MODEL_V3C", "V3C_CODTCA", cCodTca )
				
				oModel:LoadValue( "MODEL_V3C", "V3C_FUNC"  , cIdFunc )
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Rodo o aRules para gravar as informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nlI := 1 To Len( aRules )
					oModel:LoadValue( "MODEL_V3C", aRules[ nlI, 01 ], FTafGetVal( aRules[ nlI, 02 ], aRules[nlI, 03], aRules[nlI, 04], @aIncons, .F. ) )
				Next

				If Findfunction("TAFAltMan")
					if nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_V3C', 'V3C_LOGOPE' , '1', '' )
					elseif nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_V3C', 'V3C_LOGOPE' , '', cLogOpeAnt )
					EndIf
				EndIf

				nV3G := 1
				cV3GPath := cCabec + "treiCap/infoComplem/ideProfResp[" + cValToChar( nV3G ) + "]"
				
				If nOpc == 4
					For nIG := 1 to oModel:GetModel( "MODEL_V3G" ):Length()
						oModel:GetModel( "MODEL_V3G" ):GoLine( nIG )
						oModel:GetModel( "MODEL_V3G" ):DeleteLine()
					Next nIG
				EndIf

				
				While oDados:xPathHasNode( cV3GPath )
					If nOpc == 4 .or. nV3G > 1
						oModel:GetModel( "MODEL_V3G" ):LVALID := .T.
						oModel:GetModel( "MODEL_V3G" ):AddLine()
					EndIf

					//cpfProf
					If oDados:xPathHasNode( cV3GPath + "/cpfProf" )
						oModel:LoadValue( "MODEL_V3G", "V3G_CPF", FTAFGetVal( cV3GPath + "/cpfProf", "C", .F., @aIncons, .F. ) )
					EndIf

					//nmProf
					If oDados:xPathHasNode( cV3GPath + "/nmProf" )
						oModel:LoadValue( "MODEL_V3G", "V3G_NOME", FTAFGetVal( cV3GPath + "/nmProf", "C", .F., @aIncons, .F. ) )
					EndIf

					//tpProf
					If oDados:xPathHasNode( cV3GPath + "/tpProf" )
						oModel:LoadValue( "MODEL_V3G", "V3G_TPPROF", FTAFGetVal( cV3GPath + "/tpProf", "C", .F., @aIncons, .F. ) )
					EndIf

					//formProf
					If oDados:xPathHasNode( cV3GPath + "/formProf" )
						oModel:LoadValue( "MODEL_V3G", "V3G_FORMPR", FTAFGetVal( cV3GPath + "/formProf", "C", .F., @aIncons, .F. ) )
					EndIf

					//codCBO
					If oDados:xPathHasNode( cV3GPath + "/codCBO" )
						oModel:LoadValue( "MODEL_V3G", "V3G_CODCBO" , FGetIdInt( "codCBO", "",  cV3GPath + "/codCBO",,,,@cInconMsg, @nSeqErrGrv))
					EndIf

					//nacProf
					If oDados:xPathHasNode( cV3GPath + "/nacProf" )
						oModel:LoadValue( "MODEL_V3G", "V3G_NACPRO", FTAFGetVal( cV3GPath + "/nacProf", "C", .F., @aIncons, .F. ) )
					EndIf

					nV3G ++
					cV3GPath := cCabec + "treiCap/infoComplem/ideProfResp[" + cValToChar( nV3G ) + "]"
				
				EndDo

			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetiva a operacao desejada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(cInconMsg)
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
		EndIf

	End Transaction

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Zerando os arrays e os Objetos utilizados no processamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize( aRules, 0 )
	aRules	:= Nil

	aSize( aChave, 0 )
	aChave	:= Nil
	oModel	:= Nil

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF529Rul
Regras para gravacao das informacoes do registro S-2245

@Param
nOper      - Operacao a ser realizada ( 3 = Inclusao / 4 = Alteracao / 5 = Exclusao )

@Return
aRull  - Regras para a gravacao das informacoes

@author Ricardo Lovrenovic
@since 31/102017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF529Rul( cTagOper, cInconMsg, nSeqErrGrv, cCodEvent, cOwner )

	Local aRull			:= {} 

	Default cTagOper 	:= ""
	Default cInconMsg  	:= ""
	Default nSeqErrGrv 	:= 0
	Default cCodEvent	:= ""
	Default cOwner		:= ""

	// Campos da tabela V3C
	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtTreiCap/treiCap/obsTreiCap") )
		Aadd( aRull, { "V3C_OBSTCA", "/eSocial/evtTreiCap/treiCap/obsTreiCap", "C", .F. } )							
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtTreiCap/treiCap/infoComplem/dtTreiCap") )
		Aadd( aRull, { "V3C_DTTCAP", "/eSocial/evtTreiCap/treiCap/infoComplem/dtTreiCap", "D", .F. } )									
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtTreiCap/treiCap/infoComplem/durTreiCap") )
		Aadd( aRull, { "V3C_DUTCAP", "/eSocial/evtTreiCap/treiCap/infoComplem/durTreiCap", "N", .F. } )									
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtTreiCap/treiCap/infoComplem/modTreiCap") )
		Aadd( aRull, { "V3C_MODTCA", "/eSocial/evtTreiCap/treiCap/infoComplem/modTreiCap", "C", .F. } )											
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtTreiCap/treiCap/infoComplem/tpTreiCap") )
		Aadd( aRull, { "V3C_TPTCAP",  "/eSocial/evtTreiCap/treiCap/infoComplem/tpTreiCap", "C", .F. } )									
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtTreiCap/treiCap/infoComplem/indTreinAnt") )
		Aadd( aRull, { "V3C_TREANT",  "/eSocial/evtTreiCap/treiCap/infoComplem/indTreinAnt", "C", .F. } )									
	EndIf

Return ( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclusão do evento (S-3000)

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function é chamada pelo TafIntegraESocial

@Return .T.

@author denis.oliveira
@since 29/06/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )

	Local cVerAnt    := ""
	Local cProtocolo := ""
	Local cVersao    := ""
	Local cEvento    := ""
	Local nlI        := 0
	Local nlY        := 0
	Local aGrava     := {}
	Local oModelV3C  := Nil

	Default oModel   := Nil
	Default nRecno   := 0
	Default lRotExc  := .F.

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		//Posiciona o item
		("V3C")->( DBGoTo( nRecno ) )

		oModelV3C	:= oModel:GetModel( 'MODEL_V3C' )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco a versao anterior do registro para gravacao do rastro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVerAnt   	:= oModelV3C:GetValue( "V3C_VERSAO" )
		cProtocolo	:= oModelV3C:GetValue( "V3C_PROTUL" )
		cEvento	:= oModelV3C:GetValue( "V3C_EVENTO" )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Neste momento eu gravo as informacoes que foram carregadas       ³
		//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
		//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
		//³nao devem ser consideradas neste momento                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nlI := 1 To 1
			For nlY := 1 To Len( oModelV3C:aDataModel[ nlI ] )
				Aadd( aGrava, { oModelV3C:aDataModel[ nlI, nlY, 1 ], oModelV3C:aDataModel[ nlI, nlY, 2 ] } )
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
		FAltRegAnt( 'V3C', '2' )

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
			oModel:LoadValue( 'MODEL_V3C', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
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
		oModel:LoadValue( 'MODEL_V3C', 'V3C_VERSAO', cVersao )
		oModel:LoadValue( 'MODEL_V3C', 'V3C_VERANT', cVerAnt )
		oModel:LoadValue( 'MODEL_V3C', 'V3C_PROTPN', cProtocolo )
		oModel:LoadValue( 'MODEL_V3C', 'V3C_PROTUL', "" )

		/*---------------------------------------------------------
		Tratamento para que caso o Evento Anterior fosse de exclusão
		seta-se o novo evento como uma "nova inclusão", caso contrário o
		evento passar a ser uma alteração
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_V3C", "V3C_EVENTO", "E" )
		oModel:LoadValue( "MODEL_V3C", "V3C_ATIVO" , "1" )

		//Gravo alteração para o Extemporâneo
		If lGoExtemp
			TafGrvExt( oModel, 'MODEL_V3C', 'V3C' )	
		EndIf

		FwFormCommit( oModel )	
		TAFAltStat( 'V3C',"6" )

	End Transaction

Return ( .T. )
