#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA593.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA593
Cadastro MVC de Cadastro de Benefício - Entes Públicos - Alteração - S-2416

@author Rodrigo Nicolino
@since 13/09/2021
@version 1.0    
/*/
//---------------------------------------------------------------------
Function TAFA593()

	Private oBrw := FwMBrowse():New()

	cMensagem := "Essa rotina está inativa a partir de uma chamada de menu" + Chr(13) + Chr(10) // #"Dicionário Incompatível"
	cMensagem += "Por favor atualize o menu do TAF e utilize a nova rotina do Cadastro do Trabalhador"

	Aviso( "Rotina indisponível", cMensagem, { "Encerrar" }, 3 ) // #"Encerrar"

Return ( Nil )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@Return Nil

@author Rodrigo Nicolino
@since 13/09/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStruV76 := FwFormStruct( 1, "V76")
	Local oModel	:= MpFormModel():New( "TAFA593",,,{ |oModel| SaveModel( oModel ) } )
	Local lWhen    := IiF(Type( "cOperEvnt" ) <> "U",cOperEvnt <> '1' ,.T.)

	lVldModel      := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruV76:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	EndIf

	oStruV76:SetProperty( "V76_CPFBEN"  ,MODEL_FIELD_WHEN,{|| lWhen })
	oStruV76:SetProperty( "V76_HRRECP"  ,MODEL_FIELD_WHEN,{|| .F. })
	oStruV76:SetProperty( "V76_DTRECP"  ,MODEL_FIELD_WHEN,{|| .F. })
	oStruV76:SetProperty( "V76_HTRANS"  ,MODEL_FIELD_WHEN,{|| .F. })
	oStruV76:SetProperty( "V76_DTTRAN"  ,MODEL_FIELD_WHEN,{|| .F. })
	oStruV76:SetProperty( "V76_DINSIS"  ,MODEL_FIELD_WHEN,{|| .F. })

	If Type('INCLUI') <> 'U'
		oStruV76:SetProperty( "V76_DALTBE"  ,MODEL_FIELD_WHEN,{|| INCLUI })
	EndIf

	oModel:AddFields('MODEL_V76', /*cOwner*/, oStruV76)
	oModel:GetModel('MODEL_V76'):SetPrimaryKey({'V76_FILIAL', 'V76_ID', 'V76_VERSAO', 'V76_CPFBEN','V76_ATIVO'})

Return (oModel)

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@Return Nil

@author  Silas Gomes
@since 15/09/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel		:= FWLoadModel( "TAFA593" )
	Local oView     	:= FWFormView():New()
	Local oStruV76a  	:= Nil
	Local oStruV76b  	:= Nil
	Local oStruV76c  	:= Nil
	Local oStruV76d  	:= Nil
	Local cCmpFila   	:= ''
	Local cCmpFilb   	:= ''
	Local cCmpFilc   	:= ''
	Local cCmpFild  	:= ''
	Local cCmpFile  	:= ''
	Local cCmpFilf  	:= ''
	Local cCmpFilg  	:= ''
	Local cCmpBena  	:= ''
	Local cCmpBenb  	:= ''
	Local cCmpBenc  	:= ''
	Local cCmpBend  	:= ''
	Local aCmpGrp		:= {}
	Local nI			:= 0

	oView:SetModel( oModel )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Campos do folder Informacoes da Monitoração da Saúde do Trabalhador        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCmpFila	:= 'V76_TRABAL|V76_DTRABA|V76_BENEF|V76_DBENEF|V76_CPFBEN|V76_NRBENF|'	//Identificação do beneficiário e do benefício
	cCmpFilb	:= 'V76_DALTBE|'														//Informações do benefício - Alteração
	cCmpFilc	:= 'V76_TPBENE|V76_DTPBEN|V76_TPPLAN|V76_DESC|V76_INDSUS|'				//Dados relativos ao benefício
	cCmpFild	:= 'V76_TPPENS|'														//Informações relativas à pensão por morte
	cCmpFile	:= 'V76_MTSUSP|V76_DSCSUS|'												//Informações referentes à suspensão do benefício
	cCmpFilf	:= 'V76_PROTUL|'														//Informações de identificação do evento
	cCmpFilg	:= 'V76_DINSIS|V76_DTTRAN|V76_HTRANS|V76_DTRECP|V76_HRRECP|'			//Dados transmissao

	cCmpBena	:= cCmpFila + cCmpFilb
	cCmpBenb	:= cCmpFilc + cCmpFild + cCmpFile
	cCmpBenc	:= cCmpFilf
	cCmpBend	:= cCmpFilg

	oStruV76a := FwFormStruct( 2, 'V76', {|x| AllTrim( x ) + "|" $ cCmpBena } )
	oStruV76b := FwFormStruct( 2, 'V76', {|x| AllTrim( x ) + "|" $ cCmpBenb } )
	oStruV76c := FwFormStruct( 2, 'V76', {|x| AllTrim( x ) + "|" $ cCmpBenc } )
	oStruV76d := FwFormStruct( 2, 'V76', {|x| AllTrim( x ) + "|" $ cCmpBend } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 				Grupo de campos do Benefíciario                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oStruV76b:AddGroup( "GRP_BENIFICIO_01", STR0001		, "", 1 )
	oStruV76b:AddGroup( "GRP_BENIFICIO_02", STR0002		, "", 1 )
	oStruV76b:AddGroup( "GRP_BENIFICIO_03", STR0003		, "", 1 )

	aCmpGrp := StrToKArr(cCmpFilc,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruV76b:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_BENIFICIO_01")
	Next nI

	aCmpGrp := StrToKArr(cCmpFild,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruV76b:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_BENIFICIO_02")
	Next nI

	aCmpGrp := StrToKArr(cCmpFile,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruV76b:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_BENIFICIO_03")
	Next nI

	oView:AddField( 'VIEW_V76a', oStruV76a, 'MODEL_V76')
	oView:AddField( 'VIEW_V76b', oStruV76b, 'MODEL_V76')
	oView:AddField( 'VIEW_V76c', oStruV76c, 'MODEL_V76' )
	oView:AddField( 'VIEW_V76d', oStruV76d, 'MODEL_V76' )

	oView:EnableTitleView( 'VIEW_V76a', STR0004				    ) //"Cadastro de Benefício - Entes Públicos - Alteração"
	oView:EnableTitleView( 'VIEW_V76b', STR0005  				) //"Informações do Benefício"
	oView:EnableTitleView( 'VIEW_V76c', TafNmFolder("recibo",1) )
	oView:EnableTitleView( 'VIEW_V76d', TafNmFolder("recibo",2) )

	TafAjustRecibo(oStruV76c,"V76")

	oView:CreateHorizontalBox( 'PAINEL_PRINCIPAL', 100 )
	oView:CreateFolder( 'FOLDER_PRINCIPAL', 'PAINEL_PRINCIPAL' )

	oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA01', STR0006 ) //"Informações do Registro"
	oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA02', STR0007 ) //"Info. Controle eSocial"

	oView:CreateHorizontalBox( 'V76a', 35,,, 'FOLDER_PRINCIPAL', 'ABA01' )
	oView:CreateHorizontalBox( 'V76b', 65,,, 'FOLDER_PRINCIPAL', 'ABA01' )
	oView:CreateHorizontalBox( 'V76c', 20,,, 'FOLDER_PRINCIPAL', 'ABA02' )
	oView:CreateHorizontalBox( 'V76d', 80,,, 'FOLDER_PRINCIPAL', 'ABA02' )

	oView:SetOwnerView( "VIEW_V76a", "V76a" )
	oView:SetOwnerView( "VIEW_V76b", "V76b" )
	oView:SetOwnerView( "VIEW_V76c", "V76c" )
	oView:SetOwnerView( "VIEW_V76d", "V76d" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param oModel -> Modelo de dados

@Return .T.

@author Silas Gomes
@since 16/09/2021
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
	Local oModelV76   := oModel:GetModel( 'MODEL_V76' )

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT

			oModel:LoadValue( 'MODEL_V76', 'V76_ID'		, V75->V75_ID 		)
			oModel:LoadValue( 'MODEL_V76', 'V76_VERSAO'	, xFunGetVer() 		)
			oModel:LoadValue( "MODEL_V76", "V76_NOMEVE"	, "S2416" 		 	)
			oModel:LoadValue( "MODEL_V76", "V76_CPFBEN"	, V75->V75_CPFBEN	)
			oModel:LoadValue( "MODEL_V76", "V76_NRBENF"	, V75->V75_NRBENF	)

			//Gravo alteração para o Extemporâneo
			If lGoExtemp
				TafGrvExt( oModel, 'MODEL_V76', 'V76' )
			EndIf

			If Findfunction("TAFAltMan")
				TAFAltMan( 3, 'Save', oModel, 'MODEL_V76', 'V76_LOGOPE', '2', '' )
			EndIf

			FwFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE

			V76->( DbSetOrder( 2 ) )

			If V76->V76_STATUS $ "4"

				cLogOpeAnt := oModelV76:GetValue( "V76_LOGOPE" )

				If lGoExtemp

					V76->( DbSetOrder( 2 ) )
					V76->( MsSeek( xFilial( 'V76' ) + FWFLDGET("V76_ID") + FWFLDGET("V76_VERSAO") +  '1' ) )

				EndIf

				cVerAnt 	:= oModelV76:GetValue( "V76_VERSAO" )
				cProtocolo	:= oModelV76:GetValue( "V76_PROTUL" )
				cEvento		:= oModelV76:GetValue( "V76_EVENTO" )

				For nlY := 1 To Len( oModelV76:aDataModel[ 1 ] )
					Aadd( aGrava, { oModelV76:aDataModel[ 1, nlY, 1 ], oModelV76:aDataModel[ 1, nlY, 2 ] } )
				Next

				oModel:DeActivate()
				oModel:SetOperation( 3 )
				oModel:Activate()

				For nlI := 1 To Len( aGrava )
					oModel:LoadValue( 'MODEL_V76', aGrava[ nlI, 1 ], aGrava[ nlI, 2] )
				Next

				FAltRegAnt( 'V76', '2' )

				TAFAltMan( 4, 'Save', oModel, 'MODEL_V76', 'V76_LOGOPE', '', cLogOpeAnt )
				lExecAltMan := .T.

				cVersao := xFunGetVer()

				oModel:LoadValue( 'MODEL_V76', 'V76_VERSAO', cVersao    )
				oModel:LoadValue( 'MODEL_V76', 'V76_VERANT', cVerAnt    )
				oModel:LoadValue( 'MODEL_V76', 'V76_PROTPN', cProtocolo )
				oModel:LoadValue( 'MODEL_V76', 'V76_EVENTO', "A"        )
				oModel:LoadValue( 'MODEL_V76', 'V76_PROTUL', ""         )

				If lGoExtemp
					TafGrvExt( oModel, 'MODEL_V76', 'V76' )
				EndIf

				FwFormCommit( oModel )
				TAFAltStat( 'V76', " " )

			ElseIf V76->V76_STATUS == ( "2" )

				TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
				lRetorno := .F.

			Else

				//Alteração Sem Transmissão
				If TafColumnPos( "V76_LOGOPE" )
					cLogOpeAnt := V76->V76_LOGOPE
				EndIf

				If lGoExtemp
					TafGrvExt( oModel, 'MODEL_V76', 'V76' )
				EndIf

				If !lExecAltMan
					TAFAltMan( 4, 'Save', oModel, 'MODEL_V76', 'V76_LOGOPE', '', cLogOpeAnt )
				EndIf

				FwFormCommit( oModel )
				TAFAltStat( "V76", " " )

			EndIf

		ElseIf nOperation == MODEL_OPERATION_DELETE

			TAFAltStat( 'V76', "" )
			FwFormCommit( oModel )

			If V76->V76_EVENTO == "A" .Or. V76->V76_EVENTO == "E"
				TAFRastro( 'V76', 2, V76->(V76_ID + V76_VERANT), .T., , IIF(Type("oBrw") == "U", Nil, oBrw) )
			EndIf

		EndIf

	End Transaction

	If !lRetorno
		oModel:SetErrorMessage(, , , , , cMsgErr, , , )
	EndIf

Return ( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF593Grv    
Funcao de gravacao para atender o registro S-2410

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

@author Silas Gomes
@since 22/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF593Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID, cEvtOri, lMigrador, lDepGPE, cKey, cMatrC9V, lLaySmpTot, lExclCMJ)

	Local aChave       := {}
	Local aIncons      := {}
	Local aRulesCad    := {}
	Local cCabecBen    := "/eSocial/evtCdBenAlt/ideBeneficio"
	Local cCmpsNoUpd   := "|V76_FILIAL|V76_ID|V76_VERSAO|V76_NOMEVE|V76_VERANT|V76_PROTUL|V76_PROTPN|V76_EVENTO|V76_STATUS|V76_ATIVO|"
	Local cCodEvent    := Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")
	Local cCPF         := ""
	Local cFilV76      := ""
	Local cInconMsg    := ""
	Local cLogOpeAnt   := ''
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
	Default cLayout    := "2416"
	Default cOwner     := ""
	Default cXmlID     := ""
	Default lDepGPE    := .F.
	Default lMigrador  := .F.
	Default nOpc       := 1
	Default oXML       := Nil

	cLogOpeAnt := ""

	If !TAFAlsInDic( "V76")

		cString := STR0008 //"Ambiente desatualizado com a versão do programa existente no repositório de dados."
		cString += Chr( 13 ) + Chr( 10 )
		cString += Chr( 13 ) + Chr( 10 )
		cString += STR0009 //"Execute a atualização do dicionário do Layout Simplificado do eSocial por meio do compatibilizador UPDDISTR."

		Aadd( aIcons, cString )

		Return( { lRet, aIcons } )

	EndIf

	cFilV76		:= FTafGetFil(cFilEv,@aIncons, "V76")

	oDados		:= oXml

	dDataAlt	:= STOD(StrTran(oDados:XPathGetNodeValue( "/eSocial/evtCdBenAlt/infoBenAlteracao/dtAltBeneficio" ),"-",""))
	cCPF 		:= oDados:XPathGetNodeValue( cCabecBen + "/cpfBenef" )
	cNrBen		:= Padr(oDados:XPathGetNodeValue( cCabecBen + "/nrBeneficio" ), Tamsx3("V76_NRBENF")[1])

	//Chave do Registro
	aAdd( aChave, {"C", "V76_CPFBEN",	cCPF		, .T. } )
	aAdd( aChave, {"C", "V76_NRBENF",	cNrBen		, .T. } )
	aAdd( aChave, {"D", "V76_DALTBE",	dDataAlt	, .T. } )

	cChave	:= Padr(      aChave[ 1, 3 ], Tamsx3( aChave[ 1, 2 ])[1] )
	cChave  += Padr( 	  aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1] )
	cChave  += Padr( DTOS(aChave[ 3, 3 ]),Tamsx3( aChave[ 3, 2 ])[1] )

	If oDados:XPathHasNode( "/eSocial/evtCdBenAlt/ideEvento/indRetif" )
		If FTafGetVal( "/eSocial/evtCdBenAlt/ideEvento/indRetif", "C", .F., @aIncons, .F. ) == '2'
			nOpc := 4
		EndIf
	EndIf

	DbSelectArea("V75")
	V75->( DbSetOrder( 5 ) ) //V75_FILIAL+V75_CPFBEN+V75_NRBENF+V75_ATIVO
	If !V75->( MsSeek( cFilV76 + cCPF + cNrBen + "1" ))

		Aadd( aIncons, STR0010 ) //"Para integração do evento S-2416 (Cadastro de Benefício - Entes Públicos - Alteração), é necessario que exista um evento S-2410 na base."

	Else

		If V75->V75_STATUS <> "4"
			If V75->V75_STATUS == "3"
				Aadd( aIncons, STR0011 ) //"O evento de  Cadastro de Benefício - Entes Públicos - Alteração integrado possui um evento PAI S-2410 inconsistente."
			Else
				Aadd( aIncons, STR0012 ) //"O evento de Cadastro de Benefício - Entes Públicos - Alteração integrado possui um evento PAI S-2410 não validado pelo RET."
			EndIf
		EndIf

		cId := V75->V75_ID

	EndIf

	//Funcao para validar se a operacao desejada pode ser realizada
	If Empty( aIncons ) .AND. FTafVldOpe( "V76", nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA593", cCmpsNoUpd )

		cLogOpeAnt := V76->V76_LOGOPE

		//Caso se trate de uma inclusao/retificação gravo o tipo do evento na tabela C9V
		oModel:LoadValue( "MODEL_V76", "V76_NOMEVE", "S2416" )

		//Carrego array com os campos De/Para de gravacao das informacoes ( Cadastrais )
		aRulesCad := Taf591RulCad( cCabecBen, cLayout, "V76", @cInconMsg, @nSeqErrGrv, lTransmit, oModel, cCodEvent, cOwner)

		//Quando se tratar de uma Exclusao direta apenas preciso realizar
		//o Commit(), nao eh necessaria nenhuma manutencao nas informacoes

		If nOpc <> 5

			oModel:LoadValue( "MODEL_V76", "V76_FILIAL"	, V75->V75_FILIAL	)
			oModel:LoadValue( "MODEL_V76", "V76_ID"		, V75->V75_ID  		)
			oModel:LoadValue( "MODEL_V76", "V76_BENEF"	, V75->V75_BENEF	)
			oModel:LoadValue( "MODEL_V76", "V76_TRABAL"	, V75->V75_TRABAL	)
			oModel:LoadValue( "MODEL_V76", "V76_XMLID"	, cXmlID 			)
			oModel:LoadValue( "MODEL_V76", "V76_TAFKEY"	, cKey  			)

			If FindFunction( "EvtExtemp" )
				If EvtExtemp("V76", dDataAlt, cId)
					oModel:LoadValue("MODEL_V76", "V76_STASEC", 'E')
				EndIf
			EndIf

			//Rodo o aRulesCad para gravar as informacoes
			For nI := 1 to Len( aRulesCad )
				cValorXml := FTafGetVal( aRulesCad[ nI, 02 ], aRulesCad[nI, 03], aRulesCad[nI, 04], @aIncons, .F. )
				oModel:LoadValue("MODEL_V76", aRulesCad[ nI, 01 ], cValorXml)
			Next nI

			If Findfunction("TAFAltMan")

				If nOpc == 3
					TAFAltMan( nOpc, 'Grv', oModel, 'MODEL_V76', 'V76_LOGOPE', '1', '' )
				ElseIf nOpc == 4
					TAFAltMan( nOpc, 'Grv', oModel, 'MODEL_V76', 'V76_LOGOPE', '1', '', cLogOpeAnt )
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
/*/{Protheus.doc} TAF593Xml

Funcao de geracao do XML para atender os registros S-2416.
Quando a rotina for chamada o registro deve estar posicionado.

@Param:
cAlias  - Alias da Tabela
nRecno  - Recno do Registro corrente
nOpc    - Operacao a ser realizada
lJob    - Informa se foi chamado por Job

@Return:
cXml - Estrutura do Xml do Layout S-2416

@author Silas Gomes
@since 21/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF593Xml( cAlias, nRecno, nOpc, lJob )

	Local cInfoMor := ""
	Local cInfoSus := ""
	Local cLayout  := "2416"
	Local cTagBen  := "CdBenAlt"
	Local cXml     := ""

	Default cAlias := "V76"
	Default lJob   := .F.
	Default nOpc   := 1
	Default nRecno := 1

	cXml += "<ideBeneficio>"
	cXml +=		xTafTag( "cpfBenef"		, (cAlias)->&( cAlias + "_CPFBEN" ) )
	cXml +=		xTafTag( "nrBeneficio"	, (cAlias)->&( cAlias + "_NRBENF" ) )
	cXml += "</ideBeneficio>"

	cXml += "<infoBenAlteracao>"
	cXml += 	xTafTag( "dtAltBeneficio"	, (cAlias)->&( cAlias + "_DALTBE" ) )

	xTafTagGroup("infoPenMorte";
		,{{"tpPenMorte"     ,   (cAlias)->&( cAlias + "_TPPENS" )	,,.F.,.T.}};
		,@cInfoMor)

	xTafTagGroup("suspensao";
		,{{"mtvSuspensao"     ,   (cAlias)->&( cAlias + "_MTSUSP" )	,,.F.,.T.};
		, {"dscSuspensao"     ,   (cAlias)->&( cAlias + "_DSCSUS" )	,,.T.,.T.}};
		,@cInfoSus)


	xTafTagGroup("dadosBeneficio";
		,{{"tpBeneficio"    ,   Posicione("V5Z",1,xFilial("V5Z") + (cAlias)->&( cAlias + "_TPBENE" ),"V5Z_CODIGO")	,,.F.,.T.};
		, {"tpPlanRP"	    ,   (cAlias)->&( cAlias + "_TPPLAN" )					                                ,,.F.,.T.};
		, {"dsc"            ,   FwCutOff((cAlias)->&( cAlias + "_DESC"   ), .T.)	                                ,,.T.,.F.};
		, {"indSuspensao"	,   FwCutOff((cAlias)->&( cAlias + "_INDSUS" ), .T.)	                                ,,.F.,.F.}};
		,@cXml;
		, {{"infoPenMorte"	,cInfoMor,0};
		, {"suspensao"		,cInfoSus,0}};
		,.T.;
		,.T.)

	cXml +=	"</infoBenAlteracao>

	//Estrutura do cabecalho
	cXml := xTafCabXml( cXml, cAlias, cLayout, cTagBen )

	//Executa gravacao do registro
	If !lJob
		xTafGerXml( cXml, cLayout )
	EndIf

Return( cXml )
