#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA484.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA484
Cadastro MVC de Convocação para Trabalho Intermitente S-2260
 
@author José Rimarachín Díaz
@since 31/10/2017
@version 1.0
/*/
//--------------------------------------------------------------------
Function TAFA484()

	Private oBrw := FwMBrowse():New()

	If FindFunction("TAFDesEven")
		TAFDesEven()
	EndIf

	// Função que indica se o ambiente é válido para o eSocial 2.3
	If TafAtualizado()

		oBrw:SetDescription(STR0001) //"Convocação para Trabalho Intermitente"
		oBrw:SetAlias("T87")
		oBrw:SetMenuDef("TAFA484")

		If FindFunction('TAFSetFilter')
			oBrw:SetFilterDefault(TAFBrwSetFilter("T87","TAFA484","S-2260"))
		Else
			oBrw:SetFilterDefault( "T87_ATIVO == '1'" ) //Filtro para que apenas os registros ativos sejam exibidos (1 = Ativo, 2 = Inativo)
		EndIf

		TafLegend(2,"T87",@oBrw)
		oBrw:Activate()

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author José Rimarachín Díaz
@since 31/10/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao := {}
	Local aRotina := {}

	If FindFunction('TafXmlRet')
		Aadd( aFuncao, { "" , "TafxmlRet('TAF484Xml','2260','T87')" , "1" } )
	Else
		Aadd( aFuncao, { "" , "TAF484Xml" , "1" } )
	EndIf 

	//Chamo a Browse do Histórico
	If FindFunction( "xNewHisAlt" )
		Aadd( aFuncao, { "" , "xNewHisAlt( 'T87', 'TAFA484' ,,,,,,'2260','TAF484Xml' )" , "3" } )
	Else
		Aadd( aFuncao, { "" , "xFunHisAlt( 'T87', 'TAFA484' ,,,, 'TAF484XML','2260'  )" , "3" } )
	EndIf

	Aadd( aFuncao, { "" , "TAFXmlLote( 'T87', 'S-2260' , 'evtConvInterm' , 'TAF484Xml',, oBrw )" , "5" } )
	Aadd( aFuncao, { "" , "xFunAltRec( 'T87' )" , "10" } )

	lMenuDIf := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDIf )

	If lMenuDif .Or. ViewEvent('S-2260')
		ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.TAFA484' OPERATION 2 ACCESS 0 //"Visualizar"
		
		// Menu dos extemporâneos
		If  !ViewEvent('S-2260') .AND. FindFunction( "xNewHisAlt" ) .AND. FindFunction( "xTafExtmp" ) .And. xTafExtmp()
			aRotina	:= xMnuExtmp( "TAFA484", "T87" )
		EndIf
		
	Else
		aRotina	:=	xFunMnuTAF( "TAFA484" , , aFuncao)
	EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author José Rimarachín Díaz
@since 31/10/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStruT87 := FwFormStruct(1,"T87")
	Local oModel   := MpFormModel():New("TAFA484",,,{|oModel| SaveModel(oModel)})

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruT87:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	EndIf

	oModel:AddFields("MODEL_T87",/*cOwner*/,oStruT87)
	oModel:GetModel("MODEL_T87"):SetPrimaryKey({"T87_TRABAL","T87_CONVOC"}) //Definiçao da chave primaria/modelo

Return(oModel)

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author José Rimarachín Díaz
@since 31/10/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel    := FWLoadModel("TAFA484")
	Local oStruT87a := Nil
	Local oStruT87b := Nil
	Local oStruT87c := Nil
	Local oStruT87d := Nil
	Local oStruT87e := Nil
	Local oStruT87f := Nil
	Local oStruT87g := Nil
	Local oView     := FWFormView():New()
	Local nI        := 0
	Local aCmpGrp   := {}
	Local cCmpFil   := ""
	Local cGrupo1   := ""
	Local cGrupo2   := ""
	Local cGrupo3   := ""
	Local cGrupo4   := ""
	Local cGrupo5   := ""
	Local cGrupo6   := ""

	oView:SetModel(oModel)

	//"Informações de Identificação do Trabalhador e do Vínculo"
	cGrupo1  := 'T87_ID|T87_VERSAO|T87_VERANT|T87_PROTPN|T87_EVENTO|T87_ATIVO|T87_TRABAL|T87_DTRABA|'
	cCmpFil   := cGrupo1 
	oStruT87a := FwFormStruct( 2, 'T87', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	//"Informações da convocação para trabalho intermitente"
	cGrupo2  := 'T87_CONVOC|T87_DTINIP|T87_DTFIMP|'
	If TafLayESoc("02_04_02") .or. TafLayESoc("02_05_00")
		cGrupo2 += 'T87_DTPREV|'
	EndIf
	cCmpFil   := cGrupo2 
	oStruT87b := FwFormStruct( 2, 'T87', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	//"Informações da(s) jornada(s) diária(s) da prestação de trabalho intermitente"
	cGrupo3  := 'T87_CODHOR|T87_DCODHO|T87_DTPJOR|'
	cCmpFil   := cGrupo3 
	oStruT87c := FwFormStruct( 2, 'T87', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	//"Informações do local da prestação de trabalho intermitente"
	cGrupo4  := 'T87_LOCTRB|'
	cCmpFil   := cGrupo4 
	oStruT87d := FwFormStruct( 2, 'T87', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	//"Informações do local de trabalho intermitente"
	cGrupo5  := 'T87_UF|T87_DUF|T87_MUN|T87_DMUN|T87_TPLOGR|T87_DTPLOG|T87_LOGRAD|T87_NRLOG|T87_COMLOG|T87_BAIRRO|T87_CEP|'
	cCmpFil   := cGrupo5 
	oStruT87e := FwFormStruct( 2, 'T87', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	//"Protocolo de Transmissão"
	cGrupo6 := 'T87_PROTUL|'	
	cCmpFil   := cGrupo6
	oStruT87f := FwFormStruct( 2, 'T87', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	If TafColumnPos('T87_DTRANS')
		cCmpFil := 'T87_DINSIS|T87_DTRANS|T87_HTRANS|T87_DTRECP|T87_HRRECP|'
		oStruT87g := FwFormStruct( 2, 'T87', {|x| AllTrim( x ) + "|" $ cCmpFil } )
	EndIf

	/*--------------------------------------------------------------------------------------------
			Grupo de campos da Convocação para Trabalho Intermitente
	---------------------------------------------------------------------------------------------*/
	oStruT87a:AddGroup( "GRP_IDENTIFICACAO", STR0007, "", 1 ) //"Informações de Identificação do Trabalhador e do Vínculo" 

	aCmpGrp := StrToKArr(cGrupo1,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruT87a:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_IDENTIFICACAO")
	Next nI

	oStruT87b:AddGroup( "GRP_CONVOCACAO", STR0008, "", 1 ) //"Informações da convocação para trabalho intermitente"

	aCmpGrp := StrToKArr(cGrupo2,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruT87b:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_CONVOCACAO")
	Next nI

	oStruT87c:AddGroup( "GRP_JORNADA", STR0009, "", 1 ) //"Informações da(s) jornada(s) diária(s) da prestação de trabalho intermitente"

	aCmpGrp := StrToKArr(cGrupo3,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruT87c:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_JORNADA")
	Next nI

	oStruT87d:AddGroup( "GRP_LOCALP", STR0010, "", 1 ) //"Informações do local da prestação de trabalho intermitente"

	aCmpGrp := StrToKArr(cGrupo4,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruT87d:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_LOCALP")
	Next nI

	oStruT87e:AddGroup( "GRP_LOCALT", STR0011, "", 1 ) //"Informações do local de trabalho intermitente"

	aCmpGrp := StrToKArr(cGrupo5,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruT87e:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_LOCALT")
	Next nI

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruT87f,"T87")
	EndIf

	/*--------------------------------------------------------------------------------------------
											Esrutura da View
	---------------------------------------------------------------------------------------------*/
	oView:AddField( 'VIEW_T87a', oStruT87a, 'MODEL_T87' )
	oView:AddField( 'VIEW_T87b', oStruT87b, 'MODEL_T87' )
	oView:AddField( 'VIEW_T87c', oStruT87c, 'MODEL_T87' )
	oView:AddField( 'VIEW_T87d', oStruT87d, 'MODEL_T87' )
	oView:AddField( 'VIEW_T87e', oStruT87e, 'MODEL_T87' )
	oView:AddField( 'VIEW_T87f', oStruT87f, 'MODEL_T87' )

	If FindFunction("TafNmFolder")
		oView:EnableTitleView( 'VIEW_T87f', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"  
	EndIf 

	If TafColumnPos('T87_DTRANS')
		oView:AddField( 'VIEW_T87g', oStruT87g, 'MODEL_T87' )
		oView:EnableTitleView( 'VIEW_T87g', TafNmFolder("recibo",2) )
	EndIf

	/*--------------------------------------------------------------------------------------------
										Estrutura do Folder
	---------------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox("PAINEL_SUPERIOR",100)
	oView:CreateFolder("FOLDER_SUPERIOR","PAINEL_SUPERIOR")

	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0001 )   //"Convocação para Trabalho Intermitente"

	If FindFunction("TafNmFolder")
		oView:AddSheet( 'FOLDER_SUPERIOR', "ABA02", TafNmFolder("recibo") )   //"Numero do Recibo"
	Else
		oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0012 )   //Protocolo de transmissão
	EndIf 

	oView:CreateHorizontalBox( 'T87a',  015,,, 'FOLDER_SUPERIOR', 'ABA01' )
	oView:CreateHorizontalBox( 'T87b',  015,,, 'FOLDER_SUPERIOR', 'ABA01' )
	oView:CreateHorizontalBox( 'T87c',  015,,, 'FOLDER_SUPERIOR', 'ABA01' )
	oView:CreateHorizontalBox( 'T87d',  010,,, 'FOLDER_SUPERIOR', 'ABA01' )
	oView:CreateHorizontalBox( 'T87e',  045,,, 'FOLDER_SUPERIOR', 'ABA01' )
	If TafColumnPos('T87_DTRANS')
		oView:CreateHorizontalBox( 'T87f',  20,,, 'FOLDER_SUPERIOR', 'ABA02' ) 
		oView:CreateHorizontalBox( 'T87g',  80,,, 'FOLDER_SUPERIOR', 'ABA02' ) 
	Else
		oView:CreateHorizontalBox( 'T87f',  100,,, 'FOLDER_SUPERIOR', 'ABA02' ) // folder do _PROTUL
	EndIf

	oView:SetOwnerView( "VIEW_T87a", "T87a")
	oView:SetOwnerView( "VIEW_T87b", "T87b")
	oView:SetOwnerView( "VIEW_T87c", "T87c")
	oView:SetOwnerView( "VIEW_T87d", "T87d")
	oView:SetOwnerView( "VIEW_T87e", "T87e")
	oView:SetOwnerView( "VIEW_T87f", "T87f")
	If TafColumnPos('T87_DTRANS')
		oView:SetOwnerView( "VIEW_T87g", "T87g")
	EndIf

	lMenuDIf := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDIf )

	oStruT87a:RemoveField( "T87_ID" )

	If !lMenuDif
		xFunRmFStr(@oStruT87a, 'T87')
		xFunRmFStr(@oStruT87b, 'T87')
		xFunRmFStr(@oStruT87c, 'T87')
		xFunRmFStr(@oStruT87d, 'T87')
		xFunRmFStr(@oStruT87e, 'T87')
		xFunRmFStr(@oStruT87f, 'T87')
		
	EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author José Rimarachín Díaz
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
	Local oModelT87  := Nil

	Default oModel   := Nil

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT

			TafAjustID( "T87", oModel)

			oModel:LoadValue( 'MODEL_T87', 'T87_VERSAO', xFunGetVer() )

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_T87', 'T87_LOGOPE' , '2', '' )
			Endif

			FwFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			T87->( DbSetOrder( 4 ) )
			If lGoExtemp .OR. T87->( MsSeek( xFilial( 'T87' ) + M->T87_ID + '1' ) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o registro ja foi transmitido com sucesso    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If T87->T87_STATUS ==  "4"

					oModelT87 := oModel:GetModel( 'MODEL_T87' )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao anterior do registro para gravacao do rastro³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVerAnt    	:= oModelT87:GetValue( "T87_VERSAO" )
					cProtocolo 	:= oModelT87:GetValue( "T87_PROTUL" )
					cEvento		:= oModelT87:GetValue( "T87_EVENTO" )

					If TafColumnPos( "T87_LOGOPE" )
						cLogOpeAnt := oModelT87:GetValue( "T87_LOGOPE" )
					endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu gravo as informacoes que foram carregadas       ³
					//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
					//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
					//³nao devem ser consideradas neste momento                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nlI := 1 to Len( oModelT87:aDataModel[ 1 ] )
						Aadd( aGrava, { oModelT87:aDataModel[ 1, nlI, 1 ], oModelT87:aDataModel[ 1, nlI, 2 ] } )
					Next nlI

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seto o campo como Inativo e gravo a versao do novo registro³
					//³no registro anterior                                       ³
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FAltRegAnt( 'T87', '2' )	

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
						oModel:LoadValue( 'MODEL_T87', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
					Next

					//Necessário Abaixo do For Nao Retirar
					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T87', 'T87_LOGOPE' , '' , cLogOpeAnt )
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
					oModel:LoadValue( 'MODEL_T87', 'T87_VERSAO', cVersao )
					oModel:LoadValue( 'MODEL_T87', 'T87_VERANT', cVerAnt )
					oModel:LoadValue( 'MODEL_T87', 'T87_PROTPN', cProtocolo )
					oModel:LoadValue( 'MODEL_T87', 'T87_PROTUL', "" )  

					oModel:LoadValue( "MODEL_T87", "T87_EVENTO", "A" )
					// Tratamento para limpar o ID unico do xml
					cAliasPai := "T87"
					If TAFColumnPos( cAliasPai+"_XMLID" )
						oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					EndIf

					//Gravo alteração para o Extemporâneo
					If lGoExtemp
						TafGrvExt( oModel, 'MODEL_T87', 'T87' )			
					Endif	

					FwFormCommit( oModel )
					TAFAltStat( 'T87', " " )

				ElseIf	T87->T87_STATUS == "2"
					TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
					lRetorno:= .F.
				ElseIf T87->T87_STATUS == "6"
					TAFMsgVldOp(oModel,"6")//"Registro não pode ser alterado. Aguardando proc. Transm. evento de Exclusão S-3000"
					lRetorno:= .F.
				ElseIf T87->T87_STATUS == "7"
					TAFMsgVldOp(oModel,"7") //"Registro não pode ser alterado, pois o evento já se encontra na base do RET"
					lRetorno:= .F.
				Else
					If TafColumnPos( "T87_LOGOPE" )
						cLogOpeAnt := T87->T87_LOGOPE
					endif

					//Gravo alteração para o Extemporâneo
					If lGoExtemp
						TafGrvExt( oModel, 'MODEL_T87', 'T87' )			
					Endif

					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T87', 'T87_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					FwFormCommit( oModel )
					TAFAltStat( 'T87', " " )
				EndIf
			EndIf

		//Exclusão Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_DELETE

			cChvRegAnt := T87->(T87_ID + T87_VERANT)

			If !Empty( T87->T87_VERANT )
				
				TAFAltStat( 'T87', " " )
				FwFormCommit( oModel )
				
				If T87->T87_EVENTO == "A" .Or. T87->T87_EVENTO == "E"
					TAFRastro( 'T87', 1, cChvRegAnt, .T. , , IIF(Type("oBrw") == "U", Nil, oBrw) )
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
/*/{Protheus.doc} TAF484Xml
Funcao de geracao do XML para atender o registro S-2260
Quando a rotina for chamada o registro deve estar posicionado

@Param:
cAlias - Alias da Tabela
nRecno - Recno do Registro corrente
nOpc   - Operacao a ser realizada
lJob   - Informa se foi chamado por Job

@Return:
cXml - Estrutura do Xml do Layout S-2260


@author José Rimarachín Díaz
@since 06/11/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF484Xml(cAlias,nRecno,nOpc,lJob,lAutomato,cFile)

	Local cXml        := ""
	Local cLayout     := "2260"
	Local cReg        := "ConvInterm"
	Local lXmlVLd     := IIF(FindFunction( 'TafXmlVLD' ),TafXmlVLD( 'TAF484XML' ),.T.)

	Default cAlias    := "T87"
	Default lJob      := .F.
	Default nRecno    := 1
	Default nOpc      := 1
	Default lAutomato := .F.
	Default cFile     := ""

	DBSelectArea("C9V")
	C9V->(DBSetOrder(2))

	If lXmlVLd
		cXml +=	"<ideVinculo>"

		If C9V->( MSSeek( xFilial("C9V") + T87->T87_TRABAL + "1" ) )
			cXml +=	xTafTag("cpfTrab"		,C9V->C9V_CPF)
			cXml +=	xTafTag("nisTrab"		,C9V->C9V_NIS)
			cXml +=	xTafTag("matricula"	,C9V->C9V_MATRIC)
		EndIf

		cXml +=	"</ideVinculo>"

		cXml +=	"<infoConvInterm>"
		cXml +=		xTafTag("codConv"	 	,T87->T87_CONVOC)
		cXml +=		xTafTag("dtInicio"	,T87->T87_DTINIP)
		cXml +=		xTafTag("dtFim"	 	,T87->T87_DTFIMP)
		If TafLayESoc("02_04_02") .or. TafLayESoc("02_05_00")
			cXml +=	xTafTag("dtPrevPgto"	,T87->T87_DTPREV)
		EndIf

		cXml +=		"<jornada>"
		cXml += 			xTafTag("codHorContrat",POSICIONE("C90",1, xFilial("C90")+T87->T87_CODHOR,"C90_CODIGO"),,.T.)
		cXml += 			xTafTag("dscJornada",T87->T87_DTPJOR,,.T.)
		cXml +=		"</jornada>"

		cXml +=		"<localTrab>"
		cXml +=			xTafTag("indLocal",T87->T87_LOCTRB)

		//A função FwCutOff, é usada para tratamento de caractere especial

		cUf		:= posicione( "C09" , 3 , xFilial( "C09" ) + T87->T87_UF , "C09_CODIGO" )
		cMun	:= posicione( "C07" , 3 , xFilial( "C07" ) + T87->T87_MUN , "C07_CODIGO" )

		xTafTagGroup("localTrabInterm"	,{{"tpLograd"		,Posicione("C06",3,xFilial("C06")+T87->T87_TPLOGR,"C06_CESOCI")		,,.F.};
											, {"dscLograd"	,SubStr(FwCutOff(T87->T87_LOGRAD, .T.), 1, 100)						,,.F.};
											, {"nrLograd"	,T87->T87_NRLOG 													,,.F.};
											, {"complem"	,FwCutOff(T87->T87_COMLOG, .T.)										,,.T.};
											, {"bairro"		,FwCutOff(T87->T87_BAIRRO, .T.)										,,.T.};
											, {"cep"		,T87->T87_CEP														,,.F.};
											, {"codMunic"	,cUf + cMun															,,.F.};
											, {"uf"			,POSICIONE("C09",3, xFilial("C09")+T87->T87_UF,"C09_UF")			,,.F.}};
											, @cXml)
			
		cXml +=		"</localTrab>"
			
		cXml +=	"</infoConvInterm>"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estrutura do cabecalho³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cXml := xTafCabXml(cXml,"T87",cLayout,cReg)

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
/*/{Protheus.doc} TAF484Grv
Funcao de gravacao para atender o registro S-2260

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

@author José Rimarachín Díaz
@since 06/11/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF484Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

	Local cCmpsNoUpd   := "|T87_FILIAL|T87_ID|T87_VERSAO|T87_VERANT|T87_PROTPN|T87_EVENTO|T87_STATUS|T87_ATIVO|"
	Local cChave       := ""
	Local cInconMsg    := ""
	Local cCodEvent    := Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")
	Local nlI          := 0
	Local nSeqErrGrv   := 0
	Local lRet         := .F.
	Local aIncons      := {}
	Local aRules       := {}
	Local aChave       := {}
	Local oModel       := Nil

	Private lVldModel  := .T. //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.
	Private oDados     := oXML

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

	Aadd( aChave, { "C", "T87_TRABAL", FGetIdInt("cpfTrab", "matricula","/eSocial/evtConvInterm/ideVinculo/cpfTrab",;
		"/eSocial/evtConvInterm/ideVinculo/matricula"), .T. } )
	cChave := 	AllTrim(aChave[1,3]) + Space(TamSX3("T87_TRABAL")[1] - Len(aChave[1,3]))

	Aadd( aChave, { "C", "T87_CONVOC", FTafGetVal( "/eSocial/evtConvInterm/infoConvInterm/codConv", "C", .F., @aIncons, .F. ), .T.}  )

	cChave 	+= 	AllTrim(aChave[2,3]) + Space(TamSX3("T87_CONVOC")[1] - Len(aChave[2,3]))
	nIndice 	:= 2

	//Verifica se o evento ja existe na base
	DbSelectArea("T87")
	T87->(DbSetOrder(2))
	If (T87->(DbSeek(xFilial("T87") + cChave + "1")))
		If !(T87->T87_STATUS $ "2|4|9")
			nOpc := 4
		Endif
	Endif

	Begin Transaction

		//Funcao para validar se a operacao desejada pode ser realizada
		If FTafVldOpe( 'T87', nIndice, @nOpc, cFilEv, @aIncons, aChave, @oModel, 'TAFA484', cCmpsNoUpd,1 )

			If TafColumnPos( "T87_LOGOPE" )
				cLogOpeAnt := T87->T87_LOGOPE
			endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrego array com os campos De/Para de gravacao das informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aRules := TAF484Rul( cLayout, @cInconMsg, @nSeqErrGrv, cCodEvent, cOwner )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
			//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpc <> 5
				oModel:LoadValue( "MODEL_T87", "T87_FILIAL", T87->T87_FILIAL )

				If TAFColumnPos( "T87_XMLID" )
					oModel:LoadValue( "MODEL_T87", "T87_XMLID", cXmlID )
				EndIf			

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Rodo o aRules para gravar as informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nlI := 1 To Len( aRules )
					oModel:LoadValue( "MODEL_T87", aRules[ nlI, 01 ], FTafGetVal( aRules[ nlI, 02 ], aRules[nlI, 03], aRules[nlI, 04], @aIncons, .F. ) )
				Next

				If Findfunction("TAFAltMan")
					if nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T87', 'T87_LOGOPE' , '1', '' )
					elseif nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T87', 'T87_LOGOPE' , '', cLogOpeAnt )
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
/*/{Protheus.doc} TAF484Rul
Regras para gravacao das informacoes do registro S-2260

@Param
nOper      - Operacao a ser realizada ( 3 = Inclusao / 4 = Alteracao / 5 = Exclusao )

@Return
aRull  - Regras para a gravacao das informacoes

@author José Rimarachín Díaz
@since 31/102017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF484Rul( cTagOper, cInconMsg, nSeqErrGrv, cCodEvent, cOwner )

	Local aRull        := {}

	Default cTagOper   := ""
	Default cInconMsg  := ""
	Default nSeqErrGrv := 0
	Default cCodEvent  := ""
	Default cOwner     := ""

	// Campos da tabela T87
	If TafXNode( oDados, cCodEvent, cOwner,("matricula","/eSocial/evtConvInterm/ideVinculo/cpfTrab") ) .or. TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/ideVinculo/matricula") )
		Aadd( aRull, { "T87_TRABAL", FGetIdInt( "cpfTrab","matricula","/eSocial/evtConvInterm/ideVinculo/cpfTrab",;
			"/eSocial/evtConvInterm/ideVinculo/matricula",,,@cInconMsg, @nSeqErrGrv), "C", .T. } ) 					
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/infoConvInterm/codConv") )
		Aadd( aRull, { "T87_CONVOC", "/eSocial/evtConvInterm/infoConvInterm/codConv", "C", .F. } )											
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/infoConvInterm/dtInicio") )
		Aadd( aRull, { "T87_DTINIP", "/eSocial/evtConvInterm/infoConvInterm/dtInicio", "D", .F. } )									
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/infoConvInterm/dtFim") )
		Aadd( aRull, { "T87_DTFIMP", "/eSocial/evtConvInterm/infoConvInterm/dtFim", "D", .F. } )									
	EndIf

	If TafLayESoc("02_04_02") .or. TafLayESoc("02_05_00")
		If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/infoConvInterm/dtPrevPgto") )
			Aadd( aRull, { "T87_DTPREV", "/eSocial/evtConvInterm/infoConvInterm/dtPrevPgto", "D", .F. } )									
		EndIf
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/infoConvInterm/jornada/codHorContrat") )
		Aadd( aRull, { "T87_CODHOR", FGetIdInt( "codHorContrat", "", "/eSocial/evtConvInterm/infoConvInterm/jornada/codHorContrat",,,,@cInconMsg, @nSeqErrGrv), "C", .T. } )											
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/infoConvInterm/jornada/dscJornada") )
		Aadd( aRull, { "T87_DTPJOR",  "/eSocial/evtConvInterm/infoConvInterm/jornada/dscJornada", "C", .F. } )									
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/infoConvInterm/localTrab/indLocal") )
		Aadd( aRull, { "T87_LOCTRB",  "/eSocial/evtConvInterm/infoConvInterm/localTrab/indLocal", "C", .F. } )									
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/tpLograd") )
		aAdd( aRull, { "T87_TPLOGR", FGetIdInt( "tpLograd", "","/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/tpLograd",,,,@cInconMsg, @nSeqErrGrv ), "C", .T. } ) 							
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/dscLograd") )
		Aadd( aRull, { "T87_LOGRAD",  "/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/dscLograd", "C", .F. } )									
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/nrLograd") )
		Aadd( aRull, { "T87_NRLOG",  "/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/nrLograd", "C", .F. } )									
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/complem") )
		Aadd( aRull, { "T87_COMLOG",  "/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/complem", "C", .F. } )									
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/bairro") )
		Aadd( aRull, { "T87_BAIRRO",  "/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/bairro", "C", .F. } )									
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("evtConvInterm","/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/cep") )
		Aadd( aRull, { "T87_CEP",  "/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/cep", "C", .F. } )									
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("evtConvInterm","/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/uf") )
		Aadd( aRull,  { "T87_UF", FGetIdInt( "uf", "", "/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/uf",,,,@cInconMsg, @nSeqErrGrv) , "C", .T. } ) 									
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/codMunic") )
		Aadd( aRull, {"T87_MUN", +; 
					FGetIdInt( "codMunic", "uf", +; 
					"/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/uf", +; 
					"/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/codMunic",,,@cInconMsg, @nSeqErrGrv), "C", .T. } )								
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
	Local oModelT87  := Nil

	Default oModel   := Nil
	Default nRecno   := 0
	Default lRotExc  := .F.

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		//Posiciona o item
		("T87")->( DBGoTo( nRecno ) )

		oModelT87	:= oModel:GetModel( 'MODEL_T87' )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco a versao anterior do registro para gravacao do rastro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVerAnt   	:= oModelT87:GetValue( "T87_VERSAO" )
		cProtocolo	:= oModelT87:GetValue( "T87_PROTUL" )
		cEvento	:= oModelT87:GetValue( "T87_EVENTO" )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Neste momento eu gravo as informacoes que foram carregadas       ³
		//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
		//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
		//³nao devem ser consideradas neste momento                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nlI := 1 To 1
			For nlY := 1 To Len( oModelT87:aDataModel[ nlI ] )
				Aadd( aGrava, { oModelT87:aDataModel[ nlI, nlY, 1 ], oModelT87:aDataModel[ nlI, nlY, 2 ] } )
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
		FAltRegAnt( 'T87', '2' )

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
			oModel:LoadValue( 'MODEL_T87', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
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
		oModel:LoadValue( 'MODEL_T87', 'T87_VERSAO', cVersao )
		oModel:LoadValue( 'MODEL_T87', 'T87_VERANT', cVerAnt )
		oModel:LoadValue( 'MODEL_T87', 'T87_PROTPN', cProtocolo )
		oModel:LoadValue( 'MODEL_T87', 'T87_PROTUL', "" )

		/*---------------------------------------------------------
		Tratamento para que caso o Evento Anterior fosse de exclusão
		seta-se o novo evento como uma "nova inclusão", caso contrário o
		evento passar a ser uma alteração
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_T87", "T87_EVENTO", "E" )
		oModel:LoadValue( "MODEL_T87", "T87_ATIVO" , "1" )

		//Gravo alteração para o Extemporâneo
		If lGoExtemp
			TafGrvExt( oModel, 'MODEL_T87', 'T87' )	
		EndIf

		FwFormCommit( oModel )	
		TAFAltStat( 'T87',"6" )

	End Transaction

Return ( .T. )
