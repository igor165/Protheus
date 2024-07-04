#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA595.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA595
Cadastro MVC de Cadastro de Benefício - Entes Públicos - Término S-2420

@Return Nil

@author Fabio Mendonça
@since 21/09/2021
@version 1.0    
/*/
//---------------------------------------------------------------------
Function TAFA595()

	Private oBrw := FwMBrowse():New()

	cMensagem := "Essa rotina está inativa a partir de uma chamada de menu" + Chr(13) + Chr(10) // #"Dicionário Incompatível"
	cMensagem += "Por favor atualize o menu do TAF e utilize a nova rotina do Cadastro do Trabalhador"

	Aviso( "Rotina indisponível", cMensagem, { "Encerrar" }, 3 ) // #"Encerrar"

Return ( Nil )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@Return oModel

@author Fabio Mendonça
@since 21/09/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStruV78 := FwFormStruct( 1, "V78")
	Local oModel   := MpFormModel():New("TAFA595", , , { |oModel| SaveModel( oModel ) })

	lVldModel      := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruV78:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	EndIf

	oStruV78:SetProperty( "V78_HRRECP"  	,MODEL_FIELD_WHEN	,	{|| .F. })
	oStruV78:SetProperty( "V78_DTRECP"  	,MODEL_FIELD_WHEN	,	{|| .F. })
	oStruV78:SetProperty( "V78_HTRANS"  	,MODEL_FIELD_WHEN	,	{|| .F. })
	oStruV78:SetProperty( "V78_DTTRAN"  	,MODEL_FIELD_WHEN	,	{|| .F. })
	oStruV78:SetProperty( "V78_DINSIS"  	,MODEL_FIELD_WHEN	,	{|| .F. })

	oModel:AddFields('MODEL_V78', /*cOwner*/, oStruV78)
	oModel:GetModel('MODEL_V78'):SetPrimaryKey({'V78_FILIAL', 'V78_ID', 'V78_VERSAO', 'V78_CPFBEN','V78_ATIVO'})

Return (oModel)

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@Return oView

@author Fabio Mendonça
@since 21/09/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel    := FWLoadModel( "TAFA595" )
	Local oView     := FWFormView():New()
	Local oStruV78a := Nil
	Local oStruV78b := Nil
	Local oStruV78c := Nil
	Local oStruV78d := Nil
	Local cCmpFila  := ''
	Local cCmpFilb  := ''
	Local cCmpFilc  := ''
	Local cCmpFild  := ''
	Local cCmpBena  := ''
	Local cCmpBenb  := ''
	Local cCmpBenc  := ''
	Local cCmpBend  := ''
	Local aCmpGrp   := {}
	Local nI        := 0

	oView:SetModel( oModel )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Campos da View do Evento S-2420									       	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCmpFila	:= 'V78_BENEF|V78_DBENEF|V78_CPFBEN|V78_NRBENF|V78_TRABAL|V78_DTRABA|'	//Identificação do beneficiário e do benefício
	cCmpFilb	:= 'V78_DTTERM|V78_MTVTER|V78_DMTVTE|V78_CNPJO|V78_NEWCPF|'				//Informações da cessação do benefício.
	cCmpFilc	:= 'V78_PROTUL|'														//Informações de identificação do evento
	cCmpFild	:= 'V78_DINSIS|V78_DTTRAN|V78_HTRANS|V78_DTRECP|V78_HRRECP|'			//Dados transmissao

	cCmpBena	:= cCmpFila
	cCmpBenb	:= cCmpFilb
	cCmpBenc	:= cCmpFilc
	cCmpBend	:= cCmpFild

	oStruV78a := FwFormStruct( 2, 'V78', {|x| AllTrim( x ) + "|" $ cCmpBena } )
	oStruV78b := FwFormStruct( 2, 'V78', {|x| AllTrim( x ) + "|" $ cCmpBenb } )
	oStruV78c := FwFormStruct( 2, 'V78', {|x| AllTrim( x ) + "|" $ cCmpBenc } )
	oStruV78d := FwFormStruct( 2, 'V78', {|x| AllTrim( x ) + "|" $ cCmpBend } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 				Grupo de campos do Benefíciario                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oStruV78b:AddGroup( "GRP_BENEFICIO_01", STR0001	, "", 1 ) //"Informações da cessação do benefício."

	aCmpGrp := StrToKArr(cCmpFilb,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruV78b:SetProperty(aCmpGrp[nI],	MVC_VIEW_GROUP_NUMBER,	"GRP_BENEFICIO_01")
	Next nI

	oView:AddField( 'VIEW_V78a', oStruV78a,	'MODEL_V78')
	oView:AddField( 'VIEW_V78b', oStruV78b, 'MODEL_V78')
	oView:AddField( 'VIEW_V78c', oStruV78c, 'MODEL_V78' )
	oView:AddField( 'VIEW_V78d', oStruV78d, 'MODEL_V78' )

	oView:EnableTitleView( 'VIEW_V78a', STR0002 ) 	//"Informações do Beneficiário"
	oView:EnableTitleView( 'VIEW_V78b', STR0003 )	//"Informações do Benefício"
	oView:EnableTitleView( 'VIEW_V78c', TafNmFolder("recibo",1) )
	oView:EnableTitleView( 'VIEW_V78d', TafNmFolder("recibo",2) )

	TafAjustRecibo(oStruV78c,	"V78")

	oView:CreateHorizontalBox( 'PAINEL_PRINCIPAL', 100 )
	oView:CreateFolder( 'FOLDER_PRINCIPAL', 'PAINEL_PRINCIPAL' )

	oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA01', STR0004 ) 	//"Informações do Registro"
	oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA02', STR0005 ) 	//"Info. Controle eSocial"

	oView:CreateHorizontalBox( 'V78a', 20,,, 'FOLDER_PRINCIPAL', 'ABA01' )
	oView:CreateHorizontalBox( 'V78b', 80,,, 'FOLDER_PRINCIPAL', 'ABA01' )
	oView:CreateHorizontalBox( 'V78c', 20,,, 'FOLDER_PRINCIPAL', 'ABA02' )
	oView:CreateHorizontalBox( 'V78d', 80,,, 'FOLDER_PRINCIPAL', 'ABA02' )

	oView:SetOwnerView( "VIEW_V78a", "V78a" )
	oView:SetOwnerView( "VIEW_V78b", "V78b" )
	oView:SetOwnerView( "VIEW_V78c", "V78c" )
	oView:SetOwnerView( "VIEW_V78d", "V78d" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param oModel -> Modelo de dados

@Return lRetorno

@author Fabio Mendonça
@since 21/09/2021
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
	Local oModelV78   := Nil

	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT

			oModel:LoadValue( "MODEL_V78", "V78_ID"	   , V75->V75_ID	 )
			oModel:LoadValue( "MODEL_V78", "V78_VERSAO", xFunGetVer()	 )
			oModel:LoadValue( "MODEL_V78", "V78_NOMEVE", "S2420"		 )
			oModel:LoadValue( "MODEL_V78", "V78_BENEF" , V75->V75_BENEF  )
			oModel:LoadValue( "MODEL_V78", "V78_CPFBEN", V75->V75_CPFBEN )
			oModel:LoadValue( "MODEL_V78", "V78_TRABAL", V75->V75_TRABAL )
			oModel:LoadValue( "MODEL_V78", "V78_MATRIC", V75->V75_MATRIC )
			oModel:LoadValue( "MODEL_V78", "V78_NRBENF", V75->V75_NRBENF )

			//Gravo alteração para o Extemporâneo
			If lGoExtemp
				TafGrvExt( oModel, "MODEL_V78", "V78" )
			EndIf

			If Findfunction("TAFAltMan")
				TAFAltMan( 3, 'Save', oModel, 'MODEL_V78', 'V78_LOGOPE', '2', '' )
			EndIf

			FwFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE

			V78->( DbSetOrder( 1 ) )

			cLogOpeAnt := V78->V78_LOGOPE

			If V78->V78_STATUS $ "4"

				oModelV78 := oModel:GetModel( 'MODEL_V78' )

				cVerAnt 	:= oModelV78:GetValue( "V78_VERSAO" )
				cProtocolo	:= oModelV78:GetValue( "V78_PROTUL" )
				cEvento		:= oModelV78:GetValue( "V78_EVENTO" )

				For nlY := 1 To Len( oModelV78:aDataModel[ 1 ] )
					Aadd( aGrava, { oModelV78:aDataModel[ 1, nlY, 1 ], oModelV78:aDataModel[ 1, nlY, 2 ] } )
				Next

				FAltRegAnt( 'V78', '2' )

				oModel:DeActivate()
				oModel:SetOperation( 3 )
				oModel:Activate()

				For nlI := 1 To Len( aGrava )
					oModel:LoadValue( 'MODEL_V78', aGrava[ nlI, 1 ], aGrava[ nlI, 2] )
				Next

				TAFAltMan( 4, 'Save', oModel, 'MODEL_V78', 'V78_LOGOPE', '', cLogOpeAnt )
				lExecAltMan := .T.

				cVersao := xFunGetVer()

				oModel:LoadValue( 'MODEL_V78', 'V78_VERSAO', cVersao    )
				oModel:LoadValue( 'MODEL_V78', 'V78_VERANT', cVerAnt    )
				oModel:LoadValue( 'MODEL_V78', 'V78_PROTPN', cProtocolo )
				oModel:LoadValue( 'MODEL_V78', 'V78_EVENTO', "A"        )
				oModel:LoadValue( 'MODEL_V78', 'V78_PROTUL', ""         )

				If lGoExtemp
					TafGrvExt( oModel, "MODEL_V78", "V78" )
				EndIf

				FwFormCommit( oModel )
				TAFAltStat( 'V78', " " )

			ElseIf V78->V78_STATUS == ( "2" )

				TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
				lRetorno := .F.

			Else

				//Alteração Sem Transmissão
				If TafColumnPos( "V78_LOGOPE" )
					cLogOpeAnt := V78->V78_LOGOPE
				EndIf

				If lGoExtemp
					TafGrvExt( oModel, "MODEL_V78", "V78" )
				EndIf

			EndIf

			If lRetorno

				TAFAltMan( 4 , 'Save' , oModel, 'MODEL_V78', 'V78_LOGOPE' , '' , cLogOpeAnt )
				FwFormCommit( oModel )
				TAFAltStat( "V78", " " )

			EndIf

		ElseIf nOperation == MODEL_OPERATION_DELETE

			TAFAltStat( 'V78', "" )
			FwFormCommit( oModel )

			If V78->V78_EVENTO == "A" .Or. V78->V78_EVENTO == "E"
				TAFRastro( 'V78', 2, V78->(V78_ID + V78_VERANT), .T., , IIF(Type("oBrw") == "U", Nil, oBrw) )
			EndIf

		EndIf

	End Transaction

	If !lRetorno
		oModel:SetErrorMessage(, , , , , cMsgErr, , , )
	EndIf

Return ( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF595Grv    
Funcao de gravacao para atender o registro S-2420

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

@author Fabio Mendonça
@since 21/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF595Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID, cEvtOri, lMigrador, lDepGPE, cKey, cMatrC9V, lLaySmpTot, lExclCMJ, oTransf)

	Local cLogOpeAnt 	:= ''
	Local cCmpsNoUpd 	:= "|V78_FILIAL|V78_ID|V78_VERSAO|V78_NOMEVE|V78_VERANT|V78_PROTUL|V78_PROTPN|V78_EVENTO|V78_STATUS|V78_ATIVO|"
	Local nI        	:= 0
	Local nIndChv   	:= 3
	Local nSeqErrGrv	:= 0
	Local lRet      	:= .F.
	Local aIncons    	:= {}
	Local aRulesCad  	:= {}
	Local aChave     	:= {}
	Local oModel     	:= Nil
	Local cNrBen		:= ""
	Local cCabecBen 	:= "/eSocial/evtCdBenTerm/ideBeneficio"
	Local cCPF       	:= ""
	Local cInconMsg  	:= ""
	Local cFilV78    	:= ""
	Local cValorXml  	:= ""
	Local cCodEvent  	:= Posicione("C8E", 2, xFilial("C8E")+"S-"+cLayout, "C8E->C8E_ID")
	Local dDataTerm		:= CTOD("  /  /    ")
	Local lTransmit		:= .F.
	Local xChkDupl		:= {}

	Private lVldModel	:= .T. //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.
	Private oDados  	:= {}

	Default cKey        := ""
	Default cLayout  	:= "2420"
	Default nOpc    	:= 1
	Default cFilEv  	:= ""
	Default oXML    	:= Nil
	Default cOwner  	:= ""
	Default cFilTran	:= ""
	Default cGrpTran	:= ""
	Default cEmpOriGrp	:= ""
	Default cFilOriGrp	:= ""
	Default cXmlID		:= ""
	Default lMigrador	:= .F.
	Default lDepGPE		:= .F.
	Default cEvtOri		:= ""

	cLogOpeAnt := ""

	If !TAFAlsInDic("V78")

		cString := STR0006 //"Ambiente desatualizado com a versão do programa existente no repositório de dados."
		cString += Chr( 13 ) + Chr( 10 )
		cString += Chr( 13 ) + Chr( 10 )
		cString += STR0007 //"Execute a atualização do dicionário do Layout Simplificado do eSocial por meio do compatibilizador UPDDISTR."

		Aadd( aIcons, cString )

		Return( { lRet, aIcons } )

	EndIf

	cFilV78		:= FTafGetFil(cFilEv,@aIncons, "V78")

	oDados		:= oXml

	dDataTerm	:= STOD( StrTran( oDados:XPathGetNodeValue( "/eSocial/evtCdBenTerm/infoBenTermino/dtTermBeneficio" ), "-", "" ))
	cCPF 		:= oDados:XPathGetNodeValue( cCabecBen + "/cpfBenef" )
	cNrBen		:= Padr( oDados:XPathGetNodeValue( cCabecBen + "/nrBeneficio" ), Tamsx3("V78_NRBENF")[1] )

	//Chave do Registro
	aAdd( aChave, {"C", "V78_CPFBEN",	cCPF		, .T. } )
	aAdd( aChave, {"C", "V78_NRBENF",	cNrBen		, .T. } )
	aAdd( aChave, {"D", "V78_DTTERM",	dDataTerm	, .T. } )

	cChave	:= Padr(      aChave[ 1, 3 ], Tamsx3( aChave[ 1, 2 ])[1] )
	cChave  += Padr( 	  aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1] )
	cChave  += Padr( DTOS(aChave[ 3, 3 ]),Tamsx3( aChave[ 3, 2 ])[1] )

	If oDados:XPathHasNode( "/eSocial/evtCdBenTerm/ideEvento/indRetif" )
		If FTafGetVal( "/eSocial/evtCdBenTerm/ideEvento/indRetif", "C", .F., @aIncons, .F. ) == '2'
			nOpc 	:= 4
		EndIf
	EndIf

	DbSelectArea("V75")
	V75->( DbSetOrder( 5 ) ) //V75_FILIAL+V75_CPFBEN+V75_NRBENF+V75_ATIVO
	If !V75->( MsSeek( cFilV78 + cCPF + cNrBen + "1" ))

		Aadd( aIncons, STR0008 ) //"Para integração do evento S-2420 (Cadastro de Benefício - Entes Públicos - Término), é necessario que exista um evento S-2410 na base."

	Else

		If V75->V75_STATUS <> "4"
			If V75->V75_STATUS == "3"
				Aadd( aIncons, STR0009) //"O evento de  Cadastro de Benefício - Entes Públicos - Alteração integrado possui um evento PAI S-2410 inconsistente."
			Else
				Aadd( aIncons, STR0010) //"O evento de Cadastro de Benefício - Entes Públicos - Alteração integrado possui um evento PAI S-2410 não validado pelo RET."
			EndIf
		EndIf

		cId := V75->V75_ID

	EndIf

	//Funcao para validar se a operacao desejada pode ser realizada
	If Empty( aIncons ) .AND. FTafVldOpe( "V78", nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA595", cCmpsNoUpd )

		cLogOpeAnt := V78->V78_LOGOPE

		//Caso se trate de uma inclusao/retificação gravo o tipo do evento
		oModel:LoadValue( "MODEL_V78", "V78_NOMEVE", "S2420" )

		//Carrego array com os campos De/Para de gravacao das informacoes ( Cadastrais )
		aRulesCad := Taf591RulCad( cCabecBen, cLayout, "V78", @cInconMsg, @nSeqErrGrv, lTransmit, oModel, cCodEvent, cOwner)

		//Quando se tratar de uma Exclusao direta apenas preciso realizar
		//o Commit(), nao eh necessaria nenhuma manutencao nas informacoes
		If nOpc <> 5

			oModel:LoadValue( "MODEL_V78", "V78_FILIAL"	, V75->V75_FILIAL	)
			oModel:LoadValue( "MODEL_V78", "V78_ID"		, V75->V75_ID  		)
			oModel:LoadValue( "MODEL_V78", "V78_BENEF"	, V75->V75_BENEF	)
			oModel:LoadValue( "MODEL_V78", "V78_TRABAL"	, V75->V75_TRABAL	)
			oModel:LoadValue( "MODEL_V78", "V78_XMLID"	, cXmlID 			)
			oModel:LoadValue( "MODEL_V78", "V78_TAFKEY"	, cKey  			)

			If FindFunction( "EvtExtemp" )
				If EvtExtemp("V78", dDataTerm, cId)
					oModel:LoadValue("MODEL_V78", "V78_STASEC", 'E')
				EndIf
			EndIf

			//Rodo o aRulesCad para gravar as informacoes
			For nI := 1 to Len( aRulesCad )
				cValorXml := FTafGetVal( aRulesCad[ nI, 02 ], aRulesCad[nI, 03], aRulesCad[nI, 04], @aIncons, .F. )
				oModel:LoadValue("MODEL_V78", aRulesCad[ nI, 01 ], cValorXml)
			Next nI

			If Findfunction("TAFAltMan")
				If nOpc == 3
					TAFAltMan( nOpc, 'Grv', oModel, 'MODEL_V78', 'V78_LOGOPE', '1', '' )
				ElseIf nOpc == 4
					TAFAltMan( nOpc, 'Grv', oModel, 'MODEL_V78', 'V78_LOGOPE', '1', '', cLogOpeAnt )
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
/*/{Protheus.doc} TAF595Xml

Funcao de geracao do XML para atender os registros S-2420.
Quando a rotina for chamada o registro deve estar posicionado.

@Param:
cAlias  - Alias da Tabela
nRecno  - Recno do Registro corrente
nOpc    - Operacao a ser realizada
lJob    - Informa se foi chamado por Job

@Return:
cXml - Estrutura do Xml do Layout S-2420

@author Fabio Mendonça
@since 21/09/2021
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF595Xml( cAlias, nRecno, nOpc, lJob )

	Local cXml      := ""
	Local cLayout   := "2420"
	Local cTagBen	:= "CdBenTerm"

	Default cAlias	:= "V78"
	Default nRecno	:= 1
	Default nOpc	:= 1
	Default lJob	:=.F.

	cXml += "<ideBeneficio>"
	cXml +=		xTafTag( "cpfBenef"		, (cAlias)->&( cAlias + "_CPFBEN" ) )
	cXml +=		xTafTag( "nrBeneficio"	, (cAlias)->&( cAlias + "_NRBENF" ) )
	cXml += "</ideBeneficio>"

	cXml += "<infoBenTermino>"
	cXml += 	xTafTag( "dtTermBeneficio", (cAlias)->&( cAlias + "_DTTERM" )													  					)
	cXml += 	xTafTag( "mtvTermino"	  , AllTrim( Posicione( "T5H", 1, xFilial("T5H") + (cAlias)->&(cAlias + "_MTVTER"), "T5H_CODIGO" ) ) 		)
	cXml += 	xTafTag( "cnpjOrgaoSuc"	  , (cAlias)->&( cAlias + "_CNPJO " )													 			 , , .T.)
	cXml += 	xTafTag( "novoCPF"		  , (cAlias)->&( cAlias + "_NEWCPF" )													  			 , , .T.)
	cXml +=	"</infoBenTermino>

	//Estrutura do cabecalho
	cXml := xTafCabXml( cXml, cAlias, cLayout, cTagBen )

	//Executa gravacao do registro
	If !lJob
		xTafGerXml( cXml, cLayout )
	EndIf

Return( cXml )
