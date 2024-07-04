#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA594.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA594
Cadastro MVC de Cadastro de Benefício - Entes Públicos - Reativação S-2418

@author Aline Venâncio
@since 17/09/2021
@version 1.0    
/*/
//---------------------------------------------------------------------
Function TAFA594()

	Private oBrw := FwMBrowse():New()

	cMensagem := "Essa rotina está inativa a partir de uma chamada de menu" + Chr(13) + Chr(10) // #"Dicionário Incompatível"
	cMensagem += "Por favor atualize o menu do TAF e utilize a nova rotina do Cadastro do Trabalhador"

	Aviso( "Rotina indisponível", cMensagem, { "Encerrar" }, 3 ) // #"Encerrar"

Return ( Nil )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@Return Nil

@author Aline Venâncio
@since 17/09/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStruV77 := FwFormStruct( 1, "V77")
	Local oModel   := MpFormModel():New("TAFA594", , , { |oModel| SaveModel( oModel )})

	lVldModel      := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruV77:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	EndIf

	oStruV77:SetProperty( "V77_BENEF"   ,MODEL_FIELD_WHEN,{|| .F. })
	oStruV77:SetProperty( "V77_CPFBEN"  ,MODEL_FIELD_WHEN,{|| .F. })
	oStruV77:SetProperty( "V77_NRBENF"  ,MODEL_FIELD_WHEN,{|| .F. })

	oStruV77:SetProperty("V77_DTREAT"	,MODEL_FIELD_OBRIGAT,.T.)
	oStruV77:SetProperty("V77_DTEF"		,MODEL_FIELD_OBRIGAT,.T.)

	oStruV77:SetProperty( "V77_DTRECP"  ,MODEL_FIELD_WHEN,{|| .F. })
	oStruV77:SetProperty( "V77_HTRANS"  ,MODEL_FIELD_WHEN,{|| .F. })
	oStruV77:SetProperty( "V77_DTRANS"  ,MODEL_FIELD_WHEN,{|| .F. })
	oStruV77:SetProperty( "V77_DINSIS"  ,MODEL_FIELD_WHEN,{|| .F. })

	oModel:AddFields('MODEL_V77', /*cOwner*/, oStruV77)
	oModel:GetModel('MODEL_V77'):SetPrimaryKey({'V77_FILIAL','V77_ID','V77_VERSAO','V77_CPFBEN','V77_NRBENF','V77_ATIVO'})

Return (oModel)

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@Return Nil

@author Aline Venâncio
@since 17/09/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local cCmpFila  := ''
	Local cCmpFilb  := ''
	Local cCmpFilc  := ''
	Local cCmpFild  := ''
	Local oModel    := FWLoadModel( "TAFA594" )
	Local oStruV77a := Nil
	Local oStruV77b := Nil
	Local oStruV77c := Nil
	Local oStruV77d := Nil
	Local oView     := FWFormView():New()

	oView:SetModel( oModel )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Campos do folder Reativação do benefício - Entes Públicos                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCmpFila   := 'V77_BENEF|V77_DBENEF|V77_CPFBEN|V77_TRABAL|V77_DTRABA|V77_NRBENF|' 	//Identificação do beneficiário e do benefício
	cCmpFilb   := 'V77_DTREAT|V77_DTEF|'                                             	//Informações da reativação do benefício
	cCmpFilc   := 'V77_PROTUL|'                                                      	//Informações de identificação do evento
	cCmpFild   := 'V77_DINSIS|V77_DTRANS|V77_HTRANS|V77_DTRECP|V77_HRRECP|'          	//Dados transmissao

	oStruV77a := FwFormStruct( 2, 'V77', {|x| AllTrim( x ) + "|" $ cCmpFila } )
	oStruV77b := FwFormStruct( 2, 'V77', {|x| AllTrim( x ) + "|" $ cCmpFilb } )
	oStruV77c := FwFormStruct( 2, 'V77', {|x| AllTrim( x ) + "|" $ cCmpFilc } )
	oStruV77d := FwFormStruct( 2, 'V77', {|x| AllTrim( x ) + "|" $ cCmpFild } )

	oStruV77a:SetProperty( "V77_CPFBEN" 	, MVC_VIEW_INSERTLINE	, .T.	)
	oStruV77a:SetProperty( "V77_DTRABA" 	, MVC_VIEW_INSERTLINE	, .T.	)

	oView:AddField( 'VIEW_V77a', oStruV77a, 'MODEL_V77' )
	oView:AddField( 'VIEW_V77b', oStruV77b, 'MODEL_V77' )
	oView:AddField( 'VIEW_V77c', oStruV77c, 'MODEL_V77' )
	oView:AddField( 'VIEW_V77d', oStruV77d, 'MODEL_V77' )

	oView:EnableTitleView( 'VIEW_V77a', STR0001	) //"Informações do beneficiário"
	oView:EnableTitleView( 'VIEW_V77b', STR0002	) //"Informações do benefício"
	oView:EnableTitleView( 'VIEW_V77c', TafNmFolder("recibo",1) 		)
	oView:EnableTitleView( 'VIEW_V77d', TafNmFolder("recibo",2) 		)

	TafAjustRecibo(oStruV77c,"V77")

	oView:CreateHorizontalBox( 'PAINEL_PRINCIPAL', 100 )
	oView:CreateFolder( 'FOLDER_PRINCIPAL', 'PAINEL_PRINCIPAL' )

	oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA01', STR0003 ) //"Informações do Registro"
	oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA02', STR0004 ) //"Info. Controle eSocial"

	oView:CreateHorizontalBox( 'V77a', 35 ,,, 'FOLDER_PRINCIPAL', 'ABA01' )
	oView:CreateHorizontalBox( 'V77b', 65 ,,, 'FOLDER_PRINCIPAL', 'ABA01' )
	oView:CreateHorizontalBox( 'V77c', 20 ,,, 'FOLDER_PRINCIPAL', 'ABA02' )
	oView:CreateHorizontalBox( 'V77d', 80 ,,, 'FOLDER_PRINCIPAL', 'ABA02' )

	oView:SetOwnerView( "VIEW_V77a", "V77a" )
	oView:SetOwnerView( "VIEW_V77b", "V77b" )
	oView:SetOwnerView( "VIEW_V77c", "V77c" )
	oView:SetOwnerView( "VIEW_V77d", "V77d" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param oModel -> Modelo de dados

@Return .T.

@author Aline Venâncio
@since 17/09/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local lRetorno	  := .T.
	Local cLogOpeAnt  := ""
	Local cVersao     := ""
	Local cVerAnt     := ""
	Local cProtocolo  := ""
	Local cEvento     := ""
	Local cMsgErr     := ""
	Local nlI         := 0
	Local nlY         := 0
	Local lExecAltMan := .F.
	Local aGrava      := {}
	Local nOperation  := oModel:GetOperation()
	Local oModelV77   := Nil

	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT

			oModel:LoadValue( "MODEL_V77", "V77_ID"	   , V75->V75_ID	 )
			oModel:LoadValue( 'MODEL_V77', 'V77_VERSAO', xFunGetVer() 	 )
			oModel:LoadValue( "MODEL_V77", "V77_NOMEVE", "S2418" 		 )
			oModel:LoadValue( "MODEL_V77", "V77_CPFBEN", V75->V75_CPFBEN )
			oModel:LoadValue( "MODEL_V77", "V77_NRBENF", V75->V75_NRBENF )

			//Gravo alteração para o Extemporâneo
			If lGoExtemp
				TafGrvExt( oModel, 'MODEL_V77', 'V77' )
			EndIf

			If Findfunction("TAFAltMan")
				TAFAltMan( 3, 'Save', oModel, 'MODEL_V77', 'V77_LOGOPE', '2', '' )
			EndIf

			FwFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE

			V77->( DbSetOrder( 1 ) )

			cLogOpeAnt := V77->V77_LOGOPE

			If V77->V77_STATUS $ "4"

				oModelV77 := oModel:GetModel( 'MODEL_V77' )

				cVerAnt 	:= oModelV77:GetValue( "V77_VERSAO" )
				cProtocolo	:= oModelV77:GetValue( "V77_PROTUL" )
				cEvento		:= oModelV77:GetValue( "V77_EVENTO" )

				For nlY := 1 To Len( oModelV77:aDataModel[ 1 ] )
					Aadd( aGrava, { oModelV77:aDataModel[ 1, nlY, 1 ], oModelV77:aDataModel[ 1, nlY, 2 ] } )
				Next

				FAltRegAnt( 'V77', '2' )

				oModel:DeActivate()
				oModel:SetOperation( 3 )
				oModel:Activate()

				For nlI := 1 To Len( aGrava )
					oModel:LoadValue( 'MODEL_V77', aGrava[ nlI, 1 ], aGrava[ nlI, 2] )
				Next

				TAFAltMan( 4, 'Save', oModel, 'MODEL_V77', 'V77_LOGOPE', '', cLogOpeAnt )
				lExecAltMan := .T.

				cVersao := xFunGetVer()

				oModel:LoadValue( 'MODEL_V77', 'V77_VERSAO', cVersao    )
				oModel:LoadValue( 'MODEL_V77', 'V77_VERANT', cVerAnt    )
				oModel:LoadValue( 'MODEL_V77', 'V77_PROTPN', cProtocolo )
				oModel:LoadValue( 'MODEL_V77', 'V77_EVENTO', "A"        )
				oModel:LoadValue( 'MODEL_V77', 'V77_PROTUL', ""         )

				If lGoExtemp
					TafGrvExt( oModel, 'MODEL_V77', 'V77' )
				EndIf

				FwFormCommit( oModel )
				TAFAltStat( 'V77', " " )

			ElseIf V77->V77_STATUS == ( "2" )

				TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
				lRetorno := .F.

			Else
			
				//Alteração Sem Transmissão
				If TafColumnPos( "V77_LOGOPE" )
					cLogOpeAnt := V77->V77_LOGOPE
				EndIf

				If lGoExtemp
					TafGrvExt( oModel, 'MODEL_V77', 'V77' )
				EndIf

			EndIf

			If lRetorno

				TAFAltMan( 4 , 'Save' , oModel, 'MODEL_V77', 'V77_LOGOPE' , '' , cLogOpeAnt )
				FwFormCommit( oModel )
				TAFAltStat( "V77", " " )

			EndIf

		ElseIf nOperation == MODEL_OPERATION_DELETE

			TAFAltStat( 'V77' , "" )
			FwFormCommit( oModel )

			If V77->V77_EVENTO == "A" .Or. V77->V77_EVENTO == "E"
				TAFRastro( 'V77' , 2, V77->(V77_ID + V77_VERANT), .T., , IIF(Type("oBrw") == "U", Nil, oBrw) )
			EndIf
			
		EndIf

	End Transaction

	If !lRetorno
		oModel:SetErrorMessage(, , , , , cMsgErr, , , )
	EndIf

Return ( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF594Grv    
Funcao de gravacao para atender o registro S-2418

@Param:
cLayout -  Nome do Layout que esta sendo enviado, existem situacoes onde o mesmo fonte
            alimenta mais de um regsitro do E-Social, para estes casos serao necessarios
            tratamentos de acordo com o layout que esta sendo enviado.
            
nOpc    -  Opcao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )

cFilEv  -  Filial do ERP para onde as informacoes deverao ser importadas

oXML    -  Objeto com as informacoes a serem manutenidas ( Outras Integracoes )

@Return
lRet    - Variavel que indica se a importacao foi realizada, ou seja, se as
		  informacoes foram gravadas no banco de dados
		  
aIncons - Array com as inconsistencias encontradas durante a importacao

@author Aline Venâncio
@since 17/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF594Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID, cEvtOri, lMigrador, lDepGPE, cKey, cMatrC9V, lLaySmpTot, lExclCMJ, oTransf)

	Local aChave       := {}
	Local aIncons      := {}
	Local aRulesCad    := {}
	Local cCabecBen    := "/eSocial/evtReativBen/ideBeneficio"
	Local cCmpsNoUpd   := "|V77_FILIAL|V77_ID|V77_VERSAO|V77_NOMEVE|V77_VERANT|V77_PROTUL|V77_PROTPN|V77_EVENTO|V77_STATUS|V77_ATIVO|"
	Local cCodEvent    := Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")
	Local cCPF         := ""
	Local cFilV77      := ""
	Local cInconMsg    := ""
	Local cLogOpeAnt   := ""
	Local cNrBen       := ""
	Local cValorXml    := ""
	Local dDataAlt     := CTOD(" / / ")
	Local lRet         := .F.
	Local lTransmit    := .F.
	Local nI           := 0
	Local nIndChv      := 3
	Local nSeqErrGrv   := 0
	Local oModel       := Nil
	Local xChkDupl     := {}

	Private lVldModel  := .T. //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.
	Private oDados     := {}

	Default cEmpOriGrp := ""
	Default cEvtOri    := ""
	Default cFilEv     := ""
	Default cFilOriGrp := ""
	Default cFilTran   := ""
	Default cGrpTran   := ""
	Default cKey       := ""
	Default cLayout    := "2418"
	Default cOwner     := ""
	Default cXmlID     := ""
	Default lDepGPE    := .F.
	Default lMigrador  := .F.
	Default nOpc       := 1
	Default oXML       := Nil

	If !TAFAlsInDic( "V77")

		cString := STR0005 //"Ambiente desatualizado com a versão do programa existente no repositório de dados."
		cString += Chr( 13 ) + Chr( 10 )
		cString += Chr( 13 ) + Chr( 10 )
		cString += STR0006 //"Execute a atualização do dicionário do Layout Simplificado do eSocial por meio do compatibilizador UPDDISTR."

		Aadd( aIcons, cString )

		Return( { lRet, aIcons } )

	EndIf

	cFilV77		:= FTafGetFil(cFilEv,@aIncons, "V77")

	oDados		:= oXml

	dDataAlt	:= STOD(StrTran(oDados:XPathGetNodeValue( "/eSocial/evtReativBen/infoReativ/dtEfetReativ" ),"-",""))
	cCPF 		:= oDados:XPathGetNodeValue( cCabecBen + "/cpfBenef" )
	cNrBen		:= Padr(oDados:XPathGetNodeValue( cCabecBen + "/nrBeneficio" ), Tamsx3("V77_NRBENF")[1])

	//Chave do Registro
	aAdd( aChave, {"C", "V77_CPFBEN",	cCPF		, .T. } )
	aAdd( aChave, {"C", "V77_NRBENF",	cNrBen		, .T. } )
	aAdd( aChave, {"D", "V77_DTREAT",	dDataAlt	, .T. } )

	cChave	:= Padr(      aChave[ 1, 3 ], Tamsx3( aChave[ 1, 2 ])[1] )
	cChave  += Padr( 	  aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1] )
	cChave  += Padr( DTOS(aChave[ 3, 3 ]),Tamsx3( aChave[ 3, 2 ])[1] )

	If oDados:XPathHasNode( "/eSocial/evtReativBen/ideEvento/indRetif" )
		If FTafGetVal( "/eSocial/evtReativBen/ideEvento/indRetif", "C", .F., @aIncons, .F. ) == '2'
			nOpc 	:= 4
			nIndChv := 3
		EndIf
	EndIf

	DbSelectArea("V75")
	V75->( DbSetOrder( 5 ) ) //V75_FILIAL+V75_CPFBEN+V75_NRBENF+V75_ATIVO
	If !V75->( MsSeek( cFilV77 + cCPF + cNrBen + "1" ))

		Aadd( aIncons, STR0007 ) //"Para integração do evento S-2418 (Cadastro de Benefício - Entes Públicos - Alteração), é necessario que exista um evento S-2410 e S-2420 na base."

	Else

		If V75->V75_STATUS <> "4"
			If V75->V75_STATUS == "3"
				Aadd( aIncons, STR0008 ) //"O evento de  Cadastro de Benefício - Entes Públicos - Alteração integrado possui um evento PAI S-2410 inconsistente."
			Else
				Aadd( aIncons, STR0009 ) //"O evento de Cadastro de Benefício - Entes Públicos - Alteração integrado possui um evento PAI S-2410 não validado pelo RET."
			EndIf
		EndIf

		cId := V75->V75_ID

	EndIf

	//Funcao para validar se a operacao desejada pode ser realizada
	If Empty( aIncons ) .AND. FTafVldOpe( "V77", nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA594", cCmpsNoUpd )

		DbSelectArea("V77")
		V77->( DBSetOrder( 3 ) ) // V77_FILIAL+V77_CPFBEN+V77_NRBENF+V77_DREAT+V77_ATIVO
		If V77->( MsSeek( xFilial( "V77" ) + cChave + "1" ))

			If V77->V77_STATUS == "4" .AND. !Empty(V77->V77_PROTUL)

				oModel:LoadValue( "MODEL_V77", "V77_VERANT", V77->V77_VERSAO )
				oModel:LoadValue( "MODEL_V77", "V77_PROTPN", V77->V77_PROTUL )

				FAltRegAnt( "V77", "2") //Seto o registro corrente como Inativo

			EndIf
		EndIf

		cLogOpeAnt := V77->V77_LOGOPE

		//Caso se trate de uma inclusao/retificação gravo o tipo do evento na tabela C9V
		oModel:LoadValue( "MODEL_V77", "V77_NOMEVE", "S2418" )

		//Carrego array com os campos De/Para de gravacao das informacoes ( Cadastrais )
		aRulesCad := Taf591RulCad( cCabecBen, cLayout, "V77", @cInconMsg, @nSeqErrGrv, lTransmit, oModel, cCodEvent, cOwner)

		//Quando se tratar de uma Exclusao direta apenas preciso realizar
		//o Commit(), nao eh necessaria nenhuma manutencao nas informacoes

		If nOpc <> 5

			oModel:LoadValue( "MODEL_V77", "V77_FILIAL"	, V75->V75_FILIAL	)
			oModel:LoadValue( "MODEL_V77", "V77_ID"		, V75->V75_ID  		)
			oModel:LoadValue( "MODEL_V77", "V77_BENEF"	, V75->V75_BENEF	)
			oModel:LoadValue( "MODEL_V77", "V77_TRABAL"	, V75->V75_TRABAL	)
			oModel:LoadValue( "MODEL_V77", "V77_XMLID"	, cXmlID 			)
			oModel:LoadValue( "MODEL_V77", "V77_TAFKEY"	, cKey  			)

			If FindFunction( "EvtExtemp" )
				If EvtExtemp("V77", dDataAlt, cId)
					oModel:LoadValue("MODEL_V77", "V77_STASEC", 'E')
				EndIf
			EndIf

			//Rodo o aRulesCad para gravar as informacoes
			For nI := 1 to Len( aRulesCad )
				cValorXml := FTafGetVal( aRulesCad[ nI, 02 ], aRulesCad[nI, 03], aRulesCad[nI, 04], @aIncons, .F. )
				oModel:LoadValue("MODEL_V77", aRulesCad[ nI, 01 ], cValorXml)
			Next nI

			If Findfunction("TAFAltMan")
				If nOpc == 3
					TAFAltMan( nOpc, 'Grv', oModel, 'MODEL_V77', 'V77_LOGOPE', '1', '' )
				ElseIf nOpc == 4
					TAFAltMan( nOpc, 'Grv', oModel, 'MODEL_V77', 'V77_LOGOPE', '1', '', cLogOpeAnt )
				EndIf
			EndIf

		EndIf

		///Efetiva a operacao desejada
		If Empty(cInconMsg) .And. Empty(aIncons)

			xChkDupl := TafFormCommit( oModel, .T. )
			If ValType( xChkDupl ) == "A"
				If xChkDupl[1]
					Aadd(aIncons, "ERRO19" + "|" + xChkDupl[2] + "|" + xChkDupl[3])
				Else
					lRet := .T.
				EndIf
			ElseIf ValType( xChkDupl ) == "L"
				If xChkDupl
					Aadd(aIncons, "ERRO19" )
				Else
					lRet := .T.
				EndIf
			EndIf

		Else

			Aadd(aIncons, cInconMsg)

		EndIf

	EndIf

	//Zerando os arrays e os Objetos utilizados no processamento
	aSize( aRulesCad, 0 )
	aRules := Nil

	aSize( aChave, 0 )
	aChave := Nil

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF594Xml

Funcao de geracao do XML para atender os registros S-2410.
Quando a rotina for chamada o registro deve estar posicionado.

@Param:
cAlias  - Alias da Tabela
nRecno  - Recno do Registro corrente
nOpc    - Operacao a ser realizada
lJob    - Informa se foi chamado por Job

@Return:
cXml - Estrutura do Xml do Layout S-2418

@author Aline Venâncio
@since 17/09/2021
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF594Xml( cAlias, nRecno, nOpc, lJob )

	Local cLayout  := "2418"
	Local cTagRea  := "ReativBen"
	Local cXml     := ""

	Default cAlias := "V77"
	Default lJob   := .F.
	Default nRecno := 1

	cXml += "<ideBeneficio>"
	cXml +=		xTafTag( "cpfBenef"		, (cAlias)->&( cAlias + "_CPFBEN" ) )
	cXml +=		xTafTag( "nrBeneficio"	, (cAlias)->&( cAlias + "_NRBENF" ) )
	cXml += "</ideBeneficio>"

	cXml += "<infoReativ>"
	cXml += 	xTafTag( "dtEfetReativ"	, (cAlias)->&( cAlias + "_DTREAT" ) )
	cXml += 	xTafTag( "dtEfeito"		, (cAlias)->&( cAlias + "_DTEF" ) )
	cXml +=	"</infoReativ>

	//Estrutura do cabecalho
	cXml := xTafCabXml( cXml, cAlias, cLayout, cTagRea )

	//Executa gravacao do registro
	If !lJob
		xTafGerXml( cXml, cLayout )
	EndIf

Return( cXml )
