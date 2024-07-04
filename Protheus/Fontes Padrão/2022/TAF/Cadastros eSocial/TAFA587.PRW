#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA587.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA587
Funcao generica MVC do model - S-2231 Cessão/Exercício em Outro Órgão
@author Lucas A. dos Passos, Veronica de Almeida
@since 24/08/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA587()

	Local aLegend		:= {}
	Local aOnlyFields	:= {'V72_FILIAL', 'V72_FUNC', 'V72_DFUNC', 'V72_CPFV','V72_MATV', 'V72_DTINIC','V72_DTTERM','V72_RESPRE', 'V72_CNPJCE', 'V72_RESPRE'}
	Private oBrw 		:= FWmBrowse():New()
	Private cEvtPosic	:= ""

	If TAFAtualizado( .T. ,'TAFA587' )

		If FindFunction("FilCpfNome") .And. !FwIsInCallStack("TAFPNFUNC") .AND. !FwIsInCallStack("TAFMONTES")

			aAdd(aLegend, {"V72_EVENTO  == 'E' .AND. V72_STATUS == '6' 	", "ORANGE" , STR0003} ) //"Aguardando Retorna da Exclusão"
			aAdd(aLegend, {"V72_EVENTO  == 'E' .AND. V72_STATUS <> '6' 	", "RED" 	, STR0004} ) //"Cessão Excluída"
			aAdd(aLegend, {"V72_EVENTO  == 'A' 	", "WHITE" 	, STR0005} ) //"Cessão Retificada"
			aAdd(aLegend, {"EMPTY(V72_DTINIC) 	", "BLACK" 	, STR0006} ) //"Término da Cessão"
			aAdd(aLegend, {"EMPTY(V72_DTTERM) 	", "GREEN" 	, STR0002} ) //"Início da Cessão"

			TafNewBrowse( "S-2231","V72_DTINIC","V72_DTTERM",2, STR0001, , 2, 2, aLegend ) //"Cessão/Exercício em outro Órgão"

		EndIf

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu
@author Lucas A. dos Passos, Veronica de Almeida
@since 24/08/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aFuncao := {}
	Local aRotina := {}

	If FindFunction("FilCpfNome") .And. !FwIsInCallStack("TAFPNFUNC") .AND. !FwIsInCallStack("TAFMONTES")

		ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.TAFA587"			OPERATION 2 ACCESS 0 //'Visualizar'
		ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.TAFA587"			OPERATION 3 ACCESS 0 //'Incluir'
		ADD OPTION aRotina TITLE STR0009 ACTION "xTafAlt('V72', 0 , 1)"     OPERATION 4 ACCESS 0 //'Alterar'
		ADD OPTION aRotina TITLE STR0010 ACTION "VIEWDEF.TAFA587"			OPERATION 8 ACCESS 0 //'Imprimir'

	Else

		Aadd( aFuncao, { "" , "TAF587Xml" , "1" } )
		Aadd( aFuncao, { "" , "xFunAltRec( 'V72' )" , "10" } )
		Aadd( aFuncao, { "" , "xNewHisAlt( 'V72', 'TAFA587' )" , "3" } )
		Aadd( aFuncao, { "" , "StaticCall(TAFA587,PreXmlLote)" , "5" } )

		lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

		If lMenuDif
			ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA587' OPERATION 2 ACCESS 0

			// Menu dos extemporâneos
			If FindFunction( "xNewHisAlt" ) .AND. FindFunction( "xTafExtmp" ) .And. xTafExtmp()
				aRotina	:= xMnuExtmp( "TAFA587", "V72" )
			EndIf

		Else
			aRotina	:=	xFunMnuTAF( "TAFA587" , , aFuncao)
		EndIf
	EndIf

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC com o modelo
@author Lucas A. dos Passos, Veronica de Almeida
@since 24/08/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStruV72  := FwFormStruct(1,"V72")
	Local oModel    := MpFormModel():New("TAFA587",,{ |oModel| ValidModel( oModel ) }, { |oModel| SaveModel( oModel ) })
	Local lWhen			:= IIF(Type( "cOperEvnt" ) <> "U",cOperEvnt <> '1',.T.)

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruV72:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	EndIf

	oStruV72:SetProperty( "V72_FUNC"  	,MODEL_FIELD_WHEN,{|| lWhen })
	oStruV72:SetProperty( "V72_DTINIC"  ,MODEL_FIELD_WHEN,{|| lWhen .And. Empty(FWFldGet( "V72_DTTERM" )) })
	oStruV72:SetProperty( "V72_DTTERM"  ,MODEL_FIELD_WHEN,{|| Empty(FWFldGet( "V72_DTINIC" )) })
	oStruV72:SetProperty( "V72_INIKEY"  ,MODEL_FIELD_WHEN,{|| .F. })
	oStruV72:SetProperty( "V72_HRRECP"  ,MODEL_FIELD_WHEN,{|| .F. })
	oStruV72:SetProperty( "V72_DTRECP"  ,MODEL_FIELD_WHEN,{|| .F. })
	oStruV72:SetProperty( "V72_HTRANS"  ,MODEL_FIELD_WHEN,{|| .F. })
	oStruV72:SetProperty( "V72_DTRANS"  ,MODEL_FIELD_WHEN,{|| .F. })
	oStruV72:SetProperty( "V72_DINSIS"  ,MODEL_FIELD_WHEN,{|| .F. })

	oModel:AddFields('MODEL_V72', /*cOwner*/, oStruV72)
	oModel:GetModel('MODEL_V72'):SetPrimaryKey({'V72_FILIAL', 'V72_FUNC', 'V72_DTINIC', 'V72_DTTERM','V72_ATIVO'})

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc}ViewDef
Funcao generica MVC do View
@author Lucas A. dos Passos, Veronica de Almeida
@since 24/08/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel		:= FWLoadModel( 'TAFA587' )
	Local oStruV72a  	:= Nil
	Local oStruV72b  	:= Nil
	Local oStruV72c  	:= Nil
	Local oView     	:= FWFormView():New()
	Local cCmpFila   	:= ''
	Local cCmpFilb   	:= ''
	Local cCmpFilc   	:= ''

	oView:SetModel( oModel )

	// Campos do folder Informacoes da Monitoração da Saúde do Trabalhador
	cCmpFila   := 'V72_CNPJCE|V72_FUNC|V72_CPFV|V72_DFUNC|V72_MATV|V72_DTINIC|V72_DTTERM|V72_RESPRE|V72_CNPJCE|V72_RESPRE|'
	cCmpFilb   := 'V72_PROTUL|'
	cCmpFilc   := 'V72_DINSIS|V72_DTRANS|V72_HTRANS|V72_DTRECP|V72_HRRECP|V72_INIKEY|'

	oStruV72a := FwFormStruct( 2, 'V72', {|x| AllTrim( x ) + "|" $ cCmpFila } )
	oStruV72b := FwFormStruct( 2, 'V72', {|x| AllTrim( x ) + "|" $ cCmpFilb } )
	oStruV72c := FwFormStruct( 2, 'V72', {|x| AllTrim( x ) + "|" $ cCmpFilc } )

	oView:AddField( 'VIEW_V72a', oStruV72a, 'MODEL_V72')
	oView:AddField( 'VIEW_V72b', oStruV72b, 'MODEL_V72' )
	oView:AddField( 'VIEW_V72c', oStruV72c, 'MODEL_V72' )

	oView:EnableTitleView( 'VIEW_V72a', STR0001 ) //"Cessão/Exercício em outro Órgão"
	oView:EnableTitleView( 'VIEW_V72b', TafNmFolder("recibo",1) )
	oView:EnableTitleView( 'VIEW_V72c', TafNmFolder("recibo",2) )

	TafAjustRecibo(oStruV72b,"V72")

	oView:CreateHorizontalBox( 'PAINEL_PRINCIPAL', 100 )
	oView:CreateFolder( 'FOLDER_PRINCIPAL', 'PAINEL_PRINCIPAL' )

	oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA01', STR0011 ) //"Informações do Registro"
	oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA02', STR0012 ) //"Info. Controle eSocial"

	oView:CreateHorizontalBox( 'V72a', 100,,, 'FOLDER_PRINCIPAL', 'ABA01' )
	oView:CreateHorizontalBox( 'V72b',  20,,, 'FOLDER_PRINCIPAL', 'ABA02' )
	oView:CreateHorizontalBox( 'V72c',  80,,, 'FOLDER_PRINCIPAL', 'ABA02' )

	oView:SetOwnerView( "VIEW_V72a", "V72a" )
	oView:SetOwnerView( "VIEW_V72b", "V72b" )
	oView:SetOwnerView( "VIEW_V72c", "V72c" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc}SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo
@author Lucas A. dos Passos, Veronica de Almeida
@since 24/08/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)
	Local cLogOpeAnt 	:= ""
	Local cVersao		:= ""
	Local cVerAnt    	:= ""
	Local cProtocolo 	:= ""
	Local cEvento    	:= ""
	Local cMsgErr		:= ""
	Local nlI			:= 0
	Local nlY			:= 0
	Local lRetorno 		:= .T.
	Local lExecAltMan	:= .F.
	Local aGrava		:= {}
	Local nOperation 	:= oModel:GetOperation()
	Local oModelV72 	:= Nil

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT

			oModel:LoadValue( 'MODEL_V72', 'V72_VERSAO', xFunGetVer() )

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_V72', 'V72_LOGOPE' , '2', '' )
			EndIf

			FwFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE

			V72->( DbSetOrder( 1 ) )
			If V72->( MsSeek( xFilial( 'V72' ) + FWFLDGET("V72_ID") + FWFLDGET("V72_VERSAO") +  '1' ) )

				If TafColumnPos( "V72_LOGOPE" )
					cLogOpeAnt := V72->V72_LOGOPE
				EndIf

				If V72->V72_STATUS $ "4"
					oModelV72 := oModel:GetModel( 'MODEL_V72' )

					cVerAnt    := oModelV72:GetValue( "V72_VERSAO" )
					cProtocolo := oModelV72:GetValue( "V72_PROTUL" )
					cEvento    := oModelV72:GetValue( "V72_EVENTO" )

					For nlY := 1 To Len( oModelV72:aDataModel[ 1 ] )
						Aadd( aGrava, { oModelV72:aDataModel[ 1, nlY, 1 ], oModelV72:aDataModel[ 1, nlY, 2 ] } )
					Next

					FAltRegAnt( 'V72', '2' )

					oModel:DeActivate()
					oModel:SetOperation( 3 )
					oModel:Activate()

					For nlI := 1 To Len( aGrava )
						oModel:LoadValue( 'MODEL_V72', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
					Next

					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_V72', 'V72_LOGOPE' , '' , cLogOpeAnt )
					lExecAltMan := .T.

					cVersao := xFunGetVer()

					oModel:LoadValue( 'MODEL_V72', 'V72_VERSAO', cVersao )
					oModel:LoadValue( 'MODEL_V72', 'V72_VERANT', cVerAnt )
					oModel:LoadValue( 'MODEL_V72', 'V72_PROTPN', cProtocolo )
					oModel:LoadValue( 'MODEL_V72', 'V72_EVENTO', "A" )
					oModel:LoadValue( 'MODEL_V72', 'V72_PROTUL', "" )

					If !lExecAltMan
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_V72', 'V72_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					FwFormCommit( oModel )
					TAFAltStat( 'V72', " " )

				ElseIf V72->V72_STATUS == ( "2" )
					TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
					lRetorno := .F.
				Else
					//Alteração Sem Transmissão
					If TafColumnPos( "V72_LOGOPE" )
						cLogOpeAnt := V72->V72_LOGOPE
					EndIf
				EndIf

				If lRetorno
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_V72', 'V72_LOGOPE' , '' , cLogOpeAnt )

					FwFormCommit( oModel )
					TAFAltStat( "V72", " " )
				EndIf
			EndIf
		ElseIf nOperation == MODEL_OPERATION_DELETE

			cChvRegAnt := V72->(V72_ID + V72_VERANT)

			If !Empty( cChvRegAnt )
				TAFAltStat( 'V72', " " )
				FwFormCommit( oModel )

				If nOperation == MODEL_OPERATION_DELETE
					If V72->V72_EVENTO == "A" .Or. V72->V72_EVENTO == "E"
						TAFRastro( 'V72', 1, cChvRegAnt, .T., , IIF(Type("oBrw") == "U", Nil, oBrw) )
					EndIf
				EndIf
			Else
				oModel:DeActivate()
				oModel:SetOperation( 5 )
				oModel:Activate()
				FwFormCommit( oModel )
			EndIf
		EndIf
	End Transaction

	If !lRetorno
		oModel:SetErrorMessage(, , , , , cMsgErr, , , )
	EndIf

Return ( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc}ValidModel
Funcao de validação do Model
@author Lucas A. dos Passos, Veronica de Almeida
@since 24/08/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidModel( oModel )
	Local oModelV72  :=	Nil
	Local nOperation :=	Nil
	Local cFunc      := ""
	Local cDtInic  	 := ""
	Local cDtTerm  	 := ""
	Local cCNPJCe	 := ""
	Local cRespRe	 := ""
	Local cMsgErr	 := ""
	Local aAreaV72   := V72->( GetArea() )
	Local lRet       := .T.
	Local cAlias     := GetNextAlias()

	Default oModel   := Nil

	oModelV72        := oModel:GetModel( "MODEL_V72" )
	nOperation       := oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
		cFunc 	:= oModelV72:GetValue( "V72_FUNC" )
		cDtInic	:= oModelV72:GetValue( "V72_DTINIC" )
		cDtTerm	:= oModelV72:GetValue( "V72_DTTERM" )
		cCNPJCe	:= oModelV72:GetValue( "V72_CNPJCE" )
		cRespRe	:= oModelV72:GetValue( "V72_RESPRE" )

		If Empty(cDtInic) .And. Empty(cDtTerm)
			cMsgErr := STR0013 //"Obrigatório informar Data de Início ou Data de Término."
			lRet := .F.
		EndIf

		If lRet .And. (!Empty(cDtInic) .And. !Empty(cDtTerm))
			cMsgErr := STR0014 //"Não é possível informar Data Início e Data de Término no mesmo registro."
			lRet := .F.
		EndIf

		If lRet .And. (!Empty(cDtInic) .And. ( Empty(cCNPJCe) .Or. Empty(cRespRe) ))
			cMsgErr := STR0015 //"CNPJ Empreg e Info Remun são obrigatórios quando informada a Data de Início."
			lRet := .F.
		EndIf

		If lRet .And. (!Empty(cDtTerm) .And. ( !Empty(cCNPJCe) .Or. !Empty(cRespRe) ))
			cMsgErr := STR0021 //"CNPJ Empreg e Info Remun não devem ser informadas para um evento de Término."
			lRet := .F.
		EndIf

		If lRet .And. nOperation == MODEL_OPERATION_INSERT
			BeginSql Alias cAlias
			SELECT V72.R_E_C_N_O_
			FROM %Table:V72% V72
			WHERE V72_FILIAL  = %xFilial:V72%
				AND V72_FUNC = %Exp:cFunc%
				AND V72_DTINIC = %Exp:cDtInic%
				AND V72_DTTERM = %Exp:cDtTerm%
				AND V72.%NotDel%
			EndSql

			If ((cAlias)->(!Eof()))
				cMsgErr := STR0016 //"Já existe um registro com a chave informada. Verifique os campos: Trabalhador e Data Início ou Término."
				lRet := .F.
			EndIf

			(cAlias)->(DbCloseArea())
		EndIf
	EndIf

	If !lRet
		oModel:SetErrorMessage(, , , , ,cMsgErr, , , )
	EndIf

	RestArea( aAreaV72 )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF587Xml
Função de geração do XML para o Evento S-2231
@author Lucas A. dos Passos, Veronica de Almeida
@since 24/08/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF587Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)
	Local cXml		:=	""
	Local cLayout	:=	"2231"
	Local cReg		:= "Cessao"
	Local cFilBkp	:= cFilAnt
	Local lXmlVLd	:= IIF(FindFunction('TafXmlVLD'),TafXmlVLD('TAF587XML'),.T.)

	Default cAlias	:=	"V72"
	Default cSeqXml := ""

	If IsInCallStack("TafNewBrowse") .And. ( V72->V72_FILIAL <> cFilAnt )
		cFilAnt := V72->V72_FILIAL
	EndIf

	DBSelectArea( "V72" )
	V72->( DBSetOrder( 1 ) )

	C9V->( DBSetOrder( 2 ) )
	If lXmlVLd
		If C9V->( MsSeek( xFilial("C9V") + V72->V72_FUNC + "1" ) )
			cXml := "<ideVinculo>"
			cXml += 	xTafTag( "cpfTrab"	, C9V->C9V_CPF		 	)
			cXml += 	xTafTag( "matricula"	, C9V->C9V_MATRIC	,,.T.	)
			cXml += "</ideVinculo>"
		EndIf

		cXml += "<infoCessao>"

		xTafTagGroup( "iniCessao"	, {	{ "dtIniCessao"	,V72->V72_DTINIC ,, .F. };
			,	{ "cnpjCess"	,V72->V72_CNPJCE ,, .F. };
			,   { "respRemun"	, xFunTrcSN(V72->V72_RESPRE, 1),, .F. }};
			, @cXml )

		xTafTagGroup( "fimCessao"	, {{ "dtTermCessao"	,V72->V72_DTTERM ,, .F. }}, @cXml )

		cXml += "</infoCessao>"

		//Estrutura do cabeçalho
		cXml := xTafCabXml(cXml,"V72",cLayout,cReg,,cSeqXml)

		//Executa a gravação do registro
		If !lJob
			xTafGerXml( cXml, cLayout )
		EndIf
	Endif

	cFilAnt := cFilBkp

Return( cXml )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF587Rul
Função auxiliar para integração do xml
@author Lucas A. dos Passos, Veronica de Almeida
@since 24/08/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAF587Rul( cLayout, cInconMsg, nSeqErrGrv, cCodEvent, cOwner, cPredeces)
	Local aRull			:= {}
	Local aFunc			:= {}
	Local aIncons		:= {}
	Local cCabecInfoCe	:= "/eSocial/evtCessao/infoCessao"
	Local cCabecIdeVinc	:= "/eSocial/evtCessao/ideVinculo"
	Local cRespRemun	:= ""

	Default cInconMsg	:= ""
	Default nSeqErrGrv	:= 0
	Default oModel		:= Nil
	Default cCodEvent	:= ""
	Default cOwner		:= ""
	Default cPredeces	:= ""

	//Dados do Trabalhador - cpfTrab / matricula
	aFunc := TAFIdFunc(FTafGetVal( cCabecIdeVinc + "/cpfTrab", "C", .F.,, .F. ), FTafGetVal( cCabecIdeVinc + "/matricula", "C", .F.,, .F. ), @cInconMsg, @nSeqErrGrv)
	Aadd(aRull, {"V72_FUNC", aFunc[1]																															, "C", .T.})

	//Dados do início de Cessão - dtIniCessao 
	If TafXNode( oDados , cCodEvent, cOwner, ( cCabecInfoCe + "/iniCessao/dtIniCessao" ))
		Aadd( aRull, { "V72_DTINIC", cCabecInfoCe + "/iniCessao/dtIniCessao", "D", .F. } )
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner, ( cCabecInfoCe + "/iniCessao/cnpjCess"))
		Aadd( aRull, {"V72_CNPJCE", cCabecInfoCe + "/iniCessao/cnpjCess", "C", .F. } )
	EndIf

	cRespRemun := FTafGetVal( cCabecInfoCe + "/iniCessao/respRemun","C", .F., aIncons, .F.)

	If TafXNode( oDados, cCodEvent, cOwner, ( cCabecInfoCe + "/iniCessao/respRemun"))
		Aadd( aRull, {"V72_RESPRE", IIF(cRespRemun == "S","1","2"), "C", .T. } )
	EndIf

	//Dados do término de Cessão - dtTermCessao
	If TafXNode( oDados, cCodEvent, cOwner, (cCabecInfoAf + "/fimCessao/dtTermCessao"))
		Aadd( aRull, {"V72_DTTERM", cCabecInfoAf + "/fimCessao/dtTermCessao", "D", .F. } )
	EndIf

	If !Empty(cPredeces)
		Aadd( aRull, {"V72_INIKEY", AllTrim(cPredeces), "C", .T. } )
	EndIf

Return ( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF587grv
Funcao de gravacao para atender o registro S-2231.
@author Lucas A. dos Passos, Veronica de Almeida
@since 24/08/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF587Grv( cLayout, nOpc, cFilEv, oXML, cOwner , cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID, cEvtOri, lMigrador, lDepGPE, cKey )
	Local cCmpsNoUpd	:= "|V72_FILIAL|V72_ID|V72_VERSAO|V72_VERANT|V72_PROTPN|V72_EVENTO|V72_STATUS|V72_ATIVO|"
	Local cChave	 	:= ""
	Local cInconMsg 	:= ""
	Local cCodEvent		:= Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")
	Local cCabecInfoCe	:= "/eSocial/evtCessao/infoCessao"
	Local cCabecIdeVinc	:= "/eSocial/evtCessao/ideVinculo"
	Local cCabecIdeEve  := "/eSocial/evtCessao/ideEvento"
	Local nlI       	:= 0
	Local nSeqErrGrv	:= 0
	Local nRecnoReg		:= 0
	Local lRet 			:= .F.
	Local aIncons		:= {}
	Local aRules 		:= {}
	Local aChave  		:= {}
	Local oModel  		:= Nil
	Local cLogOpeAnt 	:= ""
	Local cIniCessao	:= ""
	Local cTermiCessao 	:= ""

	Private lVldModel	:= .T. //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.
	Private oDados    	:= Nil

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
	Default cKey		:=  ""
	Default cEvtOri		:=	""
	Default lMigrador	:=	""
	Default lDepGPE		:=	""

	oDados 	:= oXML

	cIniCessao         	:= FTafGetVal( cCabecInfoCe + "/iniCessao/dtIniCessao", "D", .F., @aIncons, .F. )
	cTermiCessao        := FTafGetVal( cCabecInfoCe + "/fimCessao/dtTermCessao", "D", .F., @aIncons, .F. )

	If !TAFAlsInDic( "V72" )
		cString := STR0018 //"Ambiente desatualizado com a versão do programa existente no repositório de dados."
		cString += Chr( 13 ) + Chr( 10 )
		cString += Chr( 13 ) + Chr( 10 )
		cString += STR0017 //"Execute a atualização do dicionário do Layout Simplificado do eSocial por meio do compatibilizador UPDDISTR."

		aAdd( aIncons, cString )

		Return( { lRet, aIncons } )
	EndIf

	//------------------------------------------------------------------
	// Verifico se a operação que o usuário enviou no XML é retificação
	//------------------------------------------------------------------
	If oDados:XPathHasNode( cCabecIdeEve + "/indRetif" )
		If FTafGetVal( cCabecIdeEve + "/indRetif", "C", .F., @aIncons, .F. ) == '2'
			nOpc := 4
		EndIf
	EndIf

	//-----------------------------------------------------------------
	//Se o evento possui dtIniCessao e dtTermCessao preechido
	//-----------------------------------------------------------------
	If !Empty(cIniCessao) .And. !Empty(cTermiCessao)
		Aadd( aIncons,STR0014) //"Não é possível informar Data Início e Data de Término no mesmo registro."
	EndIf

	// Verifica se é alteração do término pelo tafkey
	If !Empty(cTermiCessao) .And. nOpc == 4
		If Empty(cPredeces)
			Aadd( aIncons, STR0022 ) // Alteração/Retificação não processada pois não foi informado o registro predecessor
		Else
			nRecnoReg := GetRecnoTermino(@cPredeces, @aIncons)
		EndIf
	EndIf
	
	If !Empty( FTafGetVal( cCabecIdeVinc +"/cpfTrab", "C", .F., @aIncons, .F. ) )
		aFunc 	:= TAFIdFunc(FTafGetVal( cCabecIdeVinc + "/cpfTrab", "C", .F., @aIncons, .F. ), FTafGetVal( cCabecIdeVinc + "/matricula", "C", .F., @aIncons, .F. ), @cInconMsg, @nSeqErrGrv)
		cIdFunc := aFunc[1]

		//--------------------------------------------
		//Caso o trabalhador não exista na base do TAF
		//--------------------------------------------
		If Empty( cIdFunc )
			If !Empty(cInconMsg)
				Aadd( aIncons, cInconMsg ) // Grava na TAFXERP a mensagem de inconsistência retornada pelo FGetIdInt
			Else
				Aadd( aIncons, STR0019 ) // "O trabalhador enviado nesse afastamento não existe na base de dados do TAF."
			EndIf
			Return { .F., aIncons }
		EndIf

	//------------------------------------------------------------------------------------------------------------------
	//Caso esteja vazia não foi enviada a TAG refente a chave única do evento ( CPF ), sendo assim rejeito a integração
	//------------------------------------------------------------------------------------------------------------------
	Else
		Aadd( aIncons, STR0020 ) // "Não é possível realizar a integração pois não foi enviado o CPF do trabalhador ao qual se refere o afastamento na TAG <cpfTrab >."
		Return { .F., aIncons }

	EndIf

	Aadd( aChave, { "C", "V72_FUNC", FGetIdInt("cpfTrab", "matricula",  cCabecIdeVinc + "/cpfTrab",;
		cCabecIdeVinc + "/matricula"), .T. } )
	cChave := 	aChave[1,3]

	Aadd( aChave, { "D", "V72_DTINIC", FTafGetVal( cCabecInfoCe + "/iniCessao/dtIniCessao", "D", .F., @aIncons, .F. ), .T.}  )
	cChave 	+= 	DTOS(aChave[2,3])

	Aadd( aChave, { "D", "V72_DTTERM", FTafGetVal( cCabecInfoCe + "/fimCessao/dtTermCessao", "D", .F., @aIncons, .F. ), .T.}  )
	cChave 	+= 	DTOS(aChave[3,3])
	nIndice 	:= 2

	Begin Transaction

		//Funcao para validar se a operacao desejada pode ser realizada
		If FTafVldOpe( 'V72', nIndice, @nOpc, cFilEv, @aIncons, aChave, @oModel, 'TAFA587', cCmpsNoUpd,1 ,/*11*/,/*12*/,/*13*/,nRecnoReg)
			cLogOpeAnt := V72->V72_LOGOPE

			// Carrego array com os campos De/Para de gravacao das informacoes
			aRules := TAF587Rul( cLayout, @cInconMsg, @nSeqErrGrv, cCodEvent, cOwner, cPredeces )

			// Quando se tratar de uma Exclusao direta apenas preciso realizar
			// o Commit(), nao eh necessaria nenhuma manutencao nas informacoes
			If nOpc <> 5
				oModel:LoadValue( "MODEL_V72", "V72_FILIAL", V72->V72_FILIAL )
				oModel:LoadValue( "MODEL_V72", "V72_XMLID", cXmlID )
				oModel:LoadValue( "MODEL_V72", "V72_TAFKEY", cKey  )

				// Rodo o aRules para gravar as informacoes
				For nlI := 1 To Len( aRules )
					oModel:LoadValue( "MODEL_V72", aRules[ nlI, 01 ], FTafGetVal( aRules[ nlI, 02 ], aRules[nlI, 03], aRules[nlI, 04], @aIncons, .F. ) )
				Next

				If Findfunction("TAFAltMan")
					If nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_V72', 'V72_LOGOPE' , '1', '' )
					ElseIf nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_V72', 'V72_LOGOPE' , '', cLogOpeAnt )
					EndIf
				EndIf
			EndIf

			// Efetiva a operacao desejada
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

	// Zerando os arrays e os Objetos utilizados no processamento
	aSize( aRules, 0 )
	aRules	:= Nil

	aSize( aChave, 0 )
	aChave	:= Nil
	oModel	:= Nil

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao de gravacao do evento de exclusão
@author Lucas A. dos Passos, Veronica de Almeida
@since 24/08/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )
	Local cVerAnt    := ""
	Local cProtocolo := ""
	Local cVersao    := ""
	Local cEvento    := ""
	Local nlY        := 0
	Local nlI        := 0
	Local aGrava     := {}
	Local oModelV72  := Nil

	Default oModel   := Nil
	Default nRecno   := 1
	Default lRotExc  := .F.

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	//Abro as tabelas
	dbSelectArea("V72")

	Begin Transaction

		//Posiciona o item
		("V72")->( DBGoTo( nRecno ) )

		oModelV72 := oModel:GetModel( 'MODEL_V72' )

		// Busco a versao anterior do registro para gravacao do rastro
		cVerAnt		:= oModelV72:GetValue( "V72_VERSAO" )
		cProtocolo	:= oModelV72:GetValue( "V72_PROTUL" )
		cEvento		:= oModelV72:GetValue( "V72_EVENTO" )

		// Neste momento eu gravo as informacoes que foram carregadas
		// na tela, pois neste momento o usuario ja fez as modificacoes que
		// precisava e as mesmas estao armazenadas em memoria, ou seja,
		// nao devem ser consideradas neste momento
		For nlY := 1 To Len( oModelV72:aDataModel[ 1 ] )
			Aadd( aGrava, { oModelV72:aDataModel[ 1, nlY, 1 ], oModelV72:aDataModel[ 1, nlY, 2 ] } )
		Next

		// Seto o campo como Inativo e gravo a versao do novo registro
		// no registro anterior
		FAltRegAnt( 'V72', '2' )

		// Neste momento eu preciso setar a operacao do model como Inclusao
		oModel:DeActivate()
		oModel:SetOperation( 3 )
		oModel:Activate()

		// Neste momento eu realizo a inclusao do novo registro ja
		// contemplando as informacoes alteradas pelo usuario
		For nlI := 1 To Len( aGrava )
			oModel:LoadValue( 'MODEL_V72', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
		Next

		//Busco a nova versao do registro
		cVersao := xFunGetVer()

		/*---------------------------------------------------------
		ATENCAO -> A alteracao destes campos deve sempre estar
		abaixo do Loop do For, pois devem substituir as informacoes
		que foram armazenadas no Loop acima
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_V72", "V72_VERSAO", cVersao )
		oModel:LoadValue( "MODEL_V72", "V72_VERANT", cVerAnt )
		oModel:LoadValue( "MODEL_V72", "V72_PROTPN", cProtocolo )
		oModel:LoadValue( "MODEL_V72", "V72_PROTUL", "" )

		/*---------------------------------------------------------
		Tratamento para que caso o Evento Anterior fosse de exclusão
		seta-se o novo evento como uma "nova inclusão", caso contrário o
		evento passar a ser uma alteração
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_V72", "V72_EVENTO", "E" )
		oModel:LoadValue( "MODEL_V72", "V72_ATIVO" , "1" )

		FwFormCommit( oModel )
		TAFAltStat( 'V72',"6" )

	End Transaction

Return ( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetRecnoTermino
Funcao que retorna o Recno e V72_INIKEY do Término alterado/retificado
@author Lucas A. dos Passos, Veronica de Almeida
@since 26/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetRecnoTermino(cPredeces, aIncons)
	Local nRet		:= 0
	Local cAlias	:= GetNextAlias()
	Local lExisTerm := .F.

	cPredeces := PadR(AllTrim(cPredeces),TamSx3('V72_TAFKEY')[1])

	BeginSql Alias cAlias
		SELECT R_E_C_N_O_ AS V72_RECNO, V72_INIKEY, V72_DTINIC, V72_DTTERM
		FROM %Table:V72% V72
		WHERE V72_FILIAL = %xFilial:V72%
		  AND V72.%NotDel%
			AND V72_TAFKEY = %Exp:cPredeces%
			AND V72_ATIVO = '1'
	EndSql

	If (cAlias)->(!EOF())
		While (cAlias)->(!EOF())

			If !Empty((cAlias)->V72_DTTERM)
				lExisTerm	:= .T.
				cPredeces	:= (cAlias)->V72_INIKEY
				nRet		:= (cAlias)->V72_RECNO
			EndIf

			(cAlias)->(DbSkip())
		EndDo
	EndIf

	If !lExisTerm
		Aadd( aIncons,I18N(STR0023,{AllTrim(cPredeces)})) //"Predecessor informado não foi localizado."
	EndIf

	(cAlias)->(DbCloseArea())
Return nRet
