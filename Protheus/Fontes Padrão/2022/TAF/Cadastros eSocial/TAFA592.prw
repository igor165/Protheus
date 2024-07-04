#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA592.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA592
Cadastro MVC de Cadastro de Benefício - Entes Públicos - Início - S-2410

@author Rodrigo Nicolino
@since 13/09/2021
@version 1.0    
/*/
//---------------------------------------------------------------------
Function TAFA592()

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

	Local oStruV75 := FwFormStruct( 1, "V75")
	Local oModel   := MpFormModel():New(  "TAFA592", , {|oModel| ValidModel( oModel ) }, { |oModel| SaveModel( oModel )} )
	Local lWhen    := IiF(Type( "cOperEvnt" ) <> "U",cOperEvnt <> '1' ,.T.)

	lVldModel      := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruV75:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	EndIf

	oStruV75:SetProperty( "V75_CPFBEN"  , MODEL_FIELD_WHEN, {|| lWhen }	)
	oStruV75:SetProperty( "V75_HRRECP"  , MODEL_FIELD_WHEN, {|| .F. }	)
	oStruV75:SetProperty( "V75_DTRECP"  , MODEL_FIELD_WHEN, {|| .F. }	)
	oStruV75:SetProperty( "V75_HTRANS"  , MODEL_FIELD_WHEN, {|| .F. }	)
	oStruV75:SetProperty( "V75_DTTRAN"  , MODEL_FIELD_WHEN, {|| .F. }	)
	oStruV75:SetProperty( "V75_DINSIS"  , MODEL_FIELD_WHEN, {|| .F. }	)

	//Remoção do GetSX8Num quando se tratar da Exclusão de um Evento Transmitido.
	//Necessário para não incrementar ID que não será utilizado.
	If Type( "INCLUI" ) <> "U"  .AND. !INCLUI
		oStruV75:SetProperty( "V75_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )
	EndiF

	oModel:AddFields('MODEL_V75', /*cOwner*/, oStruV75)

	oModel:GetModel('MODEL_V75'):SetPrimaryKey({'V75_FILIAL', 'V75_ID', 'V75_CPFBEN'})

Return (oModel)

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@Return Nil

@author Rodrigo Nicolino
@since 13/09/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel    := FWLoadModel( "TAFA592" )
	Local oView     := FWFormView():New()
	Local oStruV75a := Nil
	Local oStruV75b := Nil
	Local oStruV75c := Nil
	Local oStruV75d := Nil
	Local cCmpFila  := ""
	Local cCmpFilb  := ""
	Local cCmpFilc  := ""
	Local cCmpFild  := ""
	Local cCmpFile  := ""
	Local cCmpFilf  := ""
	Local cCmpFilg  := ""
	Local cCmpFilh  := ""
	Local cCmpFili  := ""
	Local aCmpGrp	:= {}
	Local nI		:= 0

	oView:SetModel( oModel )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                 Estrutura da View do Benificio - Incio                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCmpFila := "V75_TRABAL|V75_DTRABA|V75_BENEF|V75_DBENEF|V75_CPFBEN|V75_MATRIC|V75_CNPJDS|" 	//info beneficiario
	cCmpFilb := "V75_CADINI|V75_SITBEN|V75_DTINBE|V75_NRBENF|V75_DTPUBL|" 						//info benificio
	cCmpFilc := "V75_TPBENE|V75_DTPBEN|V75_TPPLAN|V75_DESC|V75_INDJUD|"							//dadosBeneficio
	cCmpFild := "V75_TPPENS|V75_CPFINS|V75_DTINST|" 											//pensao morte
	cCmpFile := "V75_CNPJEA|V75_NRBANT|V75_DTTRBE|V75_OBSVIN|" 									//Sucesso benificio
	cCmpFilf := "V75_CPFANT|V75_NRANTB|V75_DTACPF|V75_OBSCPF|" 									//mudanca CPF
	cCmpFilg := "V75_DTTERM|V75_MTVTER|V75_DMTVTE|" 											//termino
	cCmpFilh := "V75_PROTUL|" 																	//protocolo
	cCmpFili := "V75_DINSIS|V75_DTTRAN|V75_HTRANS|V75_DTRECP|V75_HRRECP|" 						//dados transmissao

	cCmpBena := cCmpFila
	cCmpBenb := cCmpFilb + cCmpFilc + cCmpFild + cCmpFile + cCmpFilf + cCmpFilg
	cCmpBenc := cCmpFilh
	cCmpBend := cCmpFili

	oStruV75a := FwFormStruct( 2, 'V75', {|x| AllTrim( x ) + "|" $ cCmpBena } )
	oStruV75b := FwFormStruct( 2, 'V75', {|x| AllTrim( x ) + "|" $ cCmpBenb } )
	oStruV75c := FwFormStruct( 2, 'V75', {|x| AllTrim( x ) + "|" $ cCmpBenc } )
	oStruV75d := FwFormStruct( 2, 'V75', {|x| AllTrim( x ) + "|" $ cCmpBend } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 				Grupo de campos do Trabalhador                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oStruV75b:AddGroup( "GRP_BENIFICIO_01", STR0001		, "", 1 ) //"Dados relativos ao benefício"
	oStruV75b:AddGroup( "GRP_BENIFICIO_02", STR0002		, "", 1 ) //"Informações relativas à pensão por morte"
	oStruV75b:AddGroup( "GRP_BENIFICIO_03", STR0003		, "", 1 ) //"Grupo de informações de transferência de benefício"
	oStruV75b:AddGroup( "GRP_BENIFICIO_04", STR0004		, "", 1 ) //"Informações de mudança de CPF do beneficiário"
	oStruV75b:AddGroup( "GRP_BENIFICIO_05", STR0005		, "", 1 ) //"Informações da cessação do benefício"

	aCmpGrp := StrToKArr(cCmpFilb + cCmpFilc,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruV75b:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_BENIFICIO_01")
	Next nI

	aCmpGrp := StrToKArr(cCmpFild,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruV75b:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_BENIFICIO_02")
	Next nI

	aCmpGrp := StrToKArr(cCmpFile,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruV75b:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_BENIFICIO_03")
	Next nI

	aCmpGrp := StrToKArr(cCmpFilf,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruV75b:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_BENIFICIO_04")
	Next nI

	aCmpGrp := StrToKArr(cCmpFilg,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruV75b:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_BENIFICIO_05")
	Next nI

	oView:AddField( 'VIEW_V75a', oStruV75a, 'MODEL_V75' )
	oView:AddField( 'VIEW_V75b', oStruV75b, 'MODEL_V75' )
	oView:AddField( 'VIEW_V75c', oStruV75c, 'MODEL_V75' )
	oView:AddField( 'VIEW_V75d', oStruV75d, 'MODEL_V75' )

	oView:EnableTitleView( 'VIEW_V75a', STR0006	) //"Informações do beneficiário"
	oView:EnableTitleView( 'VIEW_V75b', STR0007 ) //"Informações do Benefício"
	oView:EnableTitleView( 'VIEW_V75c', TafNmFolder("recibo",1) 		)
	oView:EnableTitleView( 'VIEW_V75d', TafNmFolder("recibo",2) 		)

	TafAjustRecibo(oStruV75c,"V75")

	oView:CreateHorizontalBox( 'PAINEL_PRINCIPAL', 100 )
	oView:CreateFolder( 'FOLDER_PRINCIPAL', 'PAINEL_PRINCIPAL' )

	oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA01', STR0008 ) //"Informações do Registro"
	oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA02', STR0009 ) //"Info. Controle eSocial"

	oView:CreateHorizontalBox( 'V75a', 20 ,,, 'FOLDER_PRINCIPAL', 'ABA01' )
	oView:CreateHorizontalBox( 'V75b', 80 ,,, 'FOLDER_PRINCIPAL', 'ABA01' )
	oView:CreateHorizontalBox( 'V75c', 20 ,,, 'FOLDER_PRINCIPAL', 'ABA02' )
	oView:CreateHorizontalBox( 'V75d', 80 ,,, 'FOLDER_PRINCIPAL', 'ABA02' )

	oView:SetOwnerView( "VIEW_V75a", "V75a" )
	oView:SetOwnerView( "VIEW_V75b", "V75b" )
	oView:SetOwnerView( "VIEW_V75c", "V75c" )
	oView:SetOwnerView( "VIEW_V75d", "V75d" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Funcao de validação dos dados, chamada no final, no momento da
confirmacao do modelo

@Param oModel -> Modelo de dados

@Return .T.

@author Rodrigo Nicolino
@since 13/09/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidModel( oModel )

	Local aAreaV75   := V75->( GetArea() )
	Local cAlias     := GetNextAlias()
	Local cCPFBen    := ""
	Local cMsgErr    := ""
	Local lRet       := .T.
	Local nOperation := Nil
	Local oModelV75  := Nil

	Default oModel   := Nil

	oModelV75        := oModel:GetModel( "MODEL_V75" )
	nOperation       := oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

		cCPFBen	:= oModelV75:GetValue( "V75_CPFBEN" )
		cNrBenf	:= oModelV75:GetValue( "V75_NRBENF" )

		If nOperation == MODEL_OPERATION_INSERT

			BeginSql Alias cAlias
			SELECT V75.R_E_C_N_O_
			FROM %Table:V75% V75
			WHERE V75_FILIAL  = %xFilial:V75%
				AND V75_CPFBEN = %Exp:cCPFBen%
				AND V75_NRBENF = %Exp:cNrBenf%
				AND V75_NOMEVE = 'S2410'
				AND V75_ATIVO = '1'
				AND V75_STATUS <> '6'
				AND V75.%NotDel%
			EndSql

			If ((cAlias)->(!Eof()))
				cMsgErr := STR0010 //"Já existe um registro para o CPF informado"
				lRet := .F.
			EndIf

			(cAlias)->(DbCloseArea())

		EndIf

	EndIf

	If !lRet
		oModel:SetErrorMessage(, , , , ,cMsgErr, , , )
	EndIf

	RestArea( aAreaV75 )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param oModel -> Modelo de dados

@Return .T.

@author Rodrigo Nicolino
@since 13/09/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local cLogOpeAnt  := ""
	Local cVersao     := ""
	Local cVerAnt     := ""
	Local cProtocolo  := ""
	Local cEvento     := ""
	Local cMsgErr     := ""
	Local nlI         := 0
	Local nlY         := 0
	Local lRetorno    := .T.
	Local lExecAltMan := .F.
	Local aGrava      := {}
	Local nOperation  := oModel:GetOperation()
	Local oModelV75   := Nil

	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT

			TafAjustID( "V75", oModel)

			oModel:LoadValue( 'MODEL_V75', 'V75_VERSAO', xFunGetVer() )
			oModel:LoadValue( "MODEL_V75", "V75_NOMEVE", "S2410" )

			//Gravo alteração para o Extemporâneo
			If lGoExtemp
				TafGrvExt( oModel, "MODEL_V75", "V75" )
			EndIf

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_V75', 'V75_LOGOPE' , '2', '' )
			EndIf

			FwFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE

			V75->( DbSetOrder( 1 ) )

			cLogOpeAnt := V75->V75_LOGOPE

			If V75->V75_STATUS $ "4"

				oModelV75 := oModel:GetModel( 'MODEL_V75' )

				cVerAnt    := oModelV75:GetValue( "V75_VERSAO" )
				cProtocolo := oModelV75:GetValue( "V75_PROTUL" )
				cEvento    := oModelV75:GetValue( "V75_EVENTO" )

				For nlY := 1 To Len( oModelV75:aDataModel[ 1 ] )
					Aadd( aGrava, { oModelV75:aDataModel[ 1, nlY, 1 ], oModelV75:aDataModel[ 1, nlY, 2 ] } )
				Next

				FAltRegAnt( 'V75', '2' )

				oModel:DeActivate()
				oModel:SetOperation( 3 )
				oModel:Activate()

				For nlI := 1 To Len( aGrava )
					oModel:LoadValue( 'MODEL_V75', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
				Next

				TAFAltMan( 4 , 'Save' , oModel, 'MODEL_V75', 'V75_LOGOPE' , '' , cLogOpeAnt )
				lExecAltMan := .T.

				cVersao := xFunGetVer()

				oModel:LoadValue( 'MODEL_V75', 'V75_VERSAO', cVersao 	)
				oModel:LoadValue( 'MODEL_V75', 'V75_VERANT', cVerAnt 	)
				oModel:LoadValue( 'MODEL_V75', 'V75_PROTPN', cProtocolo )
				oModel:LoadValue( 'MODEL_V75', 'V75_EVENTO', "A" 		)
				oModel:LoadValue( 'MODEL_V75', 'V75_PROTUL', "" 		)

				FwFormCommit( oModel )
				TAFAltStat( 'V75', " " )

			ElseIf V75->V75_STATUS == ( "2" )

				TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
				lRetorno := .F.

			Else

				//Alteração Sem Transmissão
				If TafColumnPos( "V75_LOGOPE" )
					cLogOpeAnt := V75->V75_LOGOPE
				EndIf

			EndIf

			If lRetorno

				TAFAltMan( 4 , 'Save' , oModel, 'MODEL_V75', 'V75_LOGOPE' , '' , cLogOpeAnt )
				FwFormCommit( oModel )
				TAFAltStat( "V75", " " )

			EndIf

		ElseIf nOperation == MODEL_OPERATION_DELETE

			TAFAltStat( 'V75', " " )
			FwFormCommit( oModel )

			If V75->V75_EVENTO == "A" .Or. V75->V75_EVENTO == "E"
				TAFRastro( 'V75', 2, V75->(V75_ID + V75_VERANT), .T., , IIF(Type("oBrw") == "U", Nil, oBrw) )
			EndIf

		EndIf

	End Transaction

	If !lRetorno
		oModel:SetErrorMessage(, , , , , cMsgErr, , , )
	EndIf

Return ( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF592Grv    
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

@author Rodrigo Nicolino
@since 13/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF592Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID, cEvtOri, lMigrador, lDepGPE, cKey, cMatrC9V, lLaySmpTot, lExclCMJ, oTransf)

	Local aChave       := {}
	Local aIncons      := {}
	Local aRulesCad    := {}
	Local cCabecBen    := "/eSocial/evtCdBenIn/beneficiario"
	Local cCabecInf    := "/eSocial/evtCdBenIn/infoBenInicio"
	Local cCmpsNoUpd   := "|V75_FILIAL|V75_ID|V75_VERSAO|V75_NOMEVE|V75_VERANT|V75_PROTUL|V75_PROTPN|V75_EVENTO|V75_STATUS|V75_ATIVO|"
	Local cCPF         := ""
	Local cFilV75      := ""
	Local cInconMsg    := ""
	Local cLogOpeAnt   := ''
	Local cNrBen       := ""
	Local lAltPend     := .F.
	Local lRet         := .F.
	Local nI           := 0
	Local nIndChv      := 5
	Local nSeqErrGrv   := 0
	Local oModel       := Nil

	Private oDados     := Nil

	Default cEmpOriGrp := ""
	Default cEvtOri    := ""
	Default cFilEv     := ""
	Default cFilOriGrp := ""
	Default cFilTran   := ""
	Default cGrpTran   := ""
	Default cKey       := ""
	Default cLayout    := "2410"
	Default cOwner     := ""
	Default cXmlID     := ""
	Default lDepGPE    := .F.
	Default lMigrador  := .F.
	Default nOpc       := 1
	Default oXML       := Nil

	If !TAFAlsInDic( "V75" )
		cString := STR0011 //"Ambiente desatualizado com a versão do programa existente no repositório de dados."
		cString += Chr( 13 ) + Chr( 10 )
		cString += Chr( 13 ) + Chr( 10 )
		cString += STR0012 //"Execute a atualização do dicionário do Layout Simplificado do eSocial por meio do compatibilizador UPDDISTR."

		aAdd( aIncons, cString )

		Return( { lRet, aIncons } )
	EndIf

	cFilV75  	:= FTafGetFil(cFilEv,@aIncons,"V75")

	oDados	:= oXML

	If oDados:XPathHasNode( "/eSocial/evtCdBenIn/ideEvento/indRetif" )
		If FTafGetVal( "/eSocial/evtCdBenIn/ideEvento/indRetif", "C", .F., @aIncons, .F. ) == '2'
			nOpc := 4
		EndIf
	EndIf

	If oDados:XPathHasNode( cCabecBen + "/cpfBenef"  )
		cCPF	:= oDados:XPathGetNodeValue( cCabecBen + "/cpfBenef" )
	EndIf

	If oDados:XPathHasNode( cCabecInf + "/nrBeneficio"  )
		cNrBen		:= Padr(oDados:XPathGetNodeValue( cCabecInf + "/nrBeneficio" ), Tamsx3("V75_NRBENF")[1])
	EndIf

	//Chave do Registro
	aAdd( aChave, {"C", "V75_CPFBEN",	cCPF		, .T. } )
	aAdd( aChave, {"C", "V75_NRBENF",	cNrBen		, .T. } )


	cChave	:= Padr( aChave[ 1, 3 ], Tamsx3( aChave[ 1, 2 ])[1] )
	cChave  += Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1] )

	V75->( DbSetOrder( 5 ) ) //V75_FILIAL+V75_CPFBEN+V75_NRBENF+V75_ATIVO
	If ("V75")->( MsSeek( cFilV75 + cChave + '1' ) )
		If ExistS2405(.T.,V75->V75_FILIAL,V75->V75_ID,.T.)
			If V75->V75_STATUS <> '4'
				Aadd( aIncons, STR0013) //"Não é permitido a integração deste evento, enquanto outro tiver pendente de transmissão."
				lAltPend := .T.
			Endif
		EndIf
	EndIf

	If !lAltPend

		Begin Transaction
			//Funcao para validar se a operacao desejada pode ser realizada
			If FTafVldOpe( "V75", nIndChv, @nOpc,cFilEv, @aIncons, aChave, @oModel, "TAFA592", cCmpsNoUpd )

				cLogOpeAnt := V75->V75_LOGOPE

				oModel:LoadValue( "MODEL_V75", "V75_NOMEVE", "S2410" )

				//Carrego array com os campos De/Para de gravacao das informacoes ( Cadastrais )
				aRulesCad := Taf591RulCad( cCabecBen, cLayout, "V75", @cInconMsg, @nSeqErrGrv, cOwner )

				//Quando se tratar de uma Exclusao direta apenas preciso realizar
				//o Commit(), nao eh necessaria nenhuma manutencao nas informacoes
				If nOpc <> 5

					oModel:LoadValue( "MODEL_V75", "V75_FILIAL", V75->V75_FILIAL )
					oModel:LoadValue( "MODEL_V75", "V75_XMLID", cXmlID )
					oModel:LoadValue( "MODEL_V75", "V75_TAFKEY ", cKey  )

					//Rodo o aRulesCad para gravar as informacoes
					For nI := 1 to Len( aRulesCad )
						cValorXml := FTafGetVal( aRulesCad[ nI, 02 ], aRulesCad[nI, 03], aRulesCad[nI, 04], @aIncons, .F. )

						oModel:LoadValue("MODEL_V75", aRulesCad[ nI, 01 ], cValorXml)
					Next nI

					If Findfunction("TAFAltMan")
						if nOpc == 3
							TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_V75', 'V75_LOGOPE' , '1', '' )
						elseif nOpc == 4
							TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_V75', 'V75_LOGOPE' , '', cLogOpeAnt )
						EndIf
					EndIf

					///**********************************************************
					///Efetiva a operacao desejada
					///**********************************************************
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

					oModel:DeActivate()
					If FindFunction('TafClearModel')
						TafClearModel(oModel)
					EndIf
				EndIf
			Endif

			//Zerando os arrays e os Objetos utilizados no processamento
			aSize( aRulesCad, 0 )
			aRules := Nil

			aSize( aChave, 0 )
			aChave := Nil

		End Transaction
	EndIf

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF592Xml

Funcao de geracao do XML para atender os registros S-2410.
Quando a rotina for chamada o registro deve estar posicionado.

@Param:
cAlias  - Alias da Tabela
nRecno  - Recno do Registro corrente
nOpc    - Operacao a ser realizada
lJob    - Informa se foi chamado por Job

@Return:
cXml - Estrutura do Xml do Layout S-2410

@author Rodrigo Nicolino
@since 13/09/2021
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF592Xml( cAlias, nRecno, nOpc, lJob )

	Local cXml      := ""
	Local cInstPen  := ""
	Local cInfoMor  := ""
	Local cLayout   := "2410"
	Local cReg      := "CdBenIn"
	Local lXmlVLd   := IIF(FindFunction( 'TafXmlVLD' ),TafXmlVLD( 'TAF592XML' ),.T.)

	Default cAlias  := "V75"
	Default cSeqXml := ""
	Default lJob	:=.F.

	DBSelectArea( "V75" )
	V75->( DBSetOrder( 2 ) )

	If lXmlVLd

		cXml := "<beneficiario>"
		cXml += 	xTafTag( "cpfBenef"		, V75_CPFBEN,,.F.	)
		cXml += 	xTafTag( "matricula"	, V75_MATRIC,,.T.	)
		cXml += 	xTafTag( "cnpjOrigem"	, V75_CNPJDS,,.T.	)
		cXml += "</beneficiario>"

		cXml += "<infoBenInicio>"
		cXml +=	 xTafTag("cadIni"				 ,xFunTrcSN(V75->V75_CADINI, 1)	,,.F. )
		cXml +=	 xTafTag("indSitBenef"		 	 ,V75->V75_SITBEN				,,.T.)
		cXml +=	 xTafTag("nrBeneficio"		 	 ,V75->V75_NRBENF				,,.F.)
		cXml +=	 xTafTag("dtIniBeneficio"		 ,V75->V75_DTINBE				,,.F.)
		cXml +=	 xTafTag("dtPublic"		 		 ,V75->V75_DTPUBL				,,.T.)

		xTafTagGroup("instPenMorte";
			,{{"cpfInst"     ,   V75->V75_CPFINS	,,.F.};
			, {"dtInst"      ,   V75->V75_DTINST	,,.F.}};
			,@cInstPen;
			,;
			,.F.;
			,.T.)

		xTafTagGroup("infoPenMorte";
			,{{"tpPenMorte"     ,V75->V75_TPPENS,,.F.}};
			,@cInfoMor;
			,{{"instPenMorte"	,cInstPen,0}};
			,.F.;
			,.T.)

		xTafTagGroup("dadosBeneficio";
			,{{"tpBeneficio"    ,   Posicione("V5Z",1,xFilial("V5Z") +V75->V75_TPBENE,"V5Z_CODIGO")	,,.F.};
			, {"tpPlanRP"	    ,   V75->V75_TPPLAN					                                ,,.F.};
			, {"dsc"            ,   FwCutOff(V75->V75_DESC)	                                		,,.T.};
			, {"indDecJud"	    ,   xFunTrcSN(V75->V75_INDJUD,1)	                            	,,.T.}};
			,@cXml;
			, {{"infoPenMorte"	,cInfoMor,0}};
			,.T.;
			,.T.)

		xTafTagGroup("sucessaoBenef";
			,{{"cnpjOrgaoAnt"		          ,V75->V75_CNPJEA ,,.F.};
			,{"nrBeneficioAnt"	              ,V75->V75_NRBANT ,,.F.};
			,{"dtTransf"		 	          ,V75->V75_DTTRBE ,,.F.};
			,{"observacao"		     ,FwCutOff(V75->V75_OBSVIN),,.T.}};
			,@cXml)

		xTafTagGroup("mudancaCPF";
			,{{"cpfAnt"		 	 		  ,V75->V75_CPFANT  ,,.F.};
			,{"nrBeneficioAnt"	          ,V75->V75_NRANTB  ,,.F.};
			,{"dtAltCPF"		 	      ,V75->V75_DTACPF  ,,.F.};
			,{"observacao"		 ,FwCutOff(V75->V75_OBSCPF) ,,.T.}};
			,@cXml)


		xTafTagGroup("infoBenTermino";
			,{{"dtTermBeneficio"	      ,V75->V75_DTTERM ,,.F.};
			,{"mtvTermino"		          ,Posicione("T5H", 1, xFilial("T5H") + V75->V75_MTVTER, "T5H_CODIGO" )  ,,.F.}};
			,@cXml)

		cXml += "</infoBenInicio>"

		//Estrutura do cabeçalho
		cXml := xTafCabXml(cXml,"V75",cLayout,cReg)

	EndIf

	//Executa a gravação do registro
	If !lJob
		xTafGerXml( cXml, cLayout )
	EndIf

Return( cXml )
