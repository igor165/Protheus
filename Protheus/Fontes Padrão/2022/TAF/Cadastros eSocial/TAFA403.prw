#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA403.CH"

STATIC lLaySimplif := taflayEsoc("S_01_00_00")

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA403
Cadastro de Admissão Preliminar (S-2190)

@author Vitor Henrique
@since 23/10/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA403()

	Private oBrw := FWmBrowse():New()

	If TafAtualizado()

		If FindFunction("TAFSetEpoch")
			TAFSetEpoch()
		EndIf

		oBrw:SetDescription(STR0001) //"Admissão Preliminar"
		oBrw:SetAlias("T3A")
		oBrw:SetMenuDef("TAFA403")

		If FindFunction("TAFSetFilter")
			oBrw:SetFilterDefault(TAFBrwSetFilter("T3A", "TAFA403", "S-2190"))
		Else
			oBrw:SetFilterDefault("T3A_ATIVO == '1'") //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )
		EndIf

		TafLegend(2, "T3A", @oBrw)

		oBrw:Activate()

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Vitor Henrique
@since 23/10/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao := {}
	Local aRotina := {}

	If FindFunction('TafXmlRet')
		Aadd( aFuncao, { "" , "TafxmlRet('TAF403Xml','2190','T3A')" 									, "1" } )
	Else
		Aadd( aFuncao, { "" , "TAF403Xml" 									, "1" } )
	EndIf

	aAdd( aFuncao, { "" , "TAFXmlLote( 'T3A', 'S-2190' , 'evtAdmPrelim' , 'TAF403Xml',, oBrw )" 	, "5" } )

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	Aadd( aFuncao, { "" , "xFunAltRec( 'T3A' )" , "10" } )

	If lMenuDif

		ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA403' OPERATION 2 ACCESS 0

		// Menu dos extemporâneos
		If FindFunction( "xNewHisAlt" ) .AND. FindFunction( "xTafExtmp" ) .And. xTafExtmp()
			aRotina	:= xMnuExtmp( "TAFA403", "T3A" )
		EndIf

	Else
		aRotina	:=	xFunMnuTAF( "TAFA403" , , aFuncao)
	EndIf

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Vitor Henrique
@since 23/10/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruT3A 	:= FWFormStruct( 1, 'T3A' )
	Local oModel   	:= MPFormModel():New( 'TAFA403' , , , {|oModel| SaveModel( oModel ) } )

	lVldModel 	:= Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If !lLaySimplif

		oStruT3A:RemoveField( "T3A_MATRIC" )
		oStruT3A:RemoveField( "T3A_CODCAT" )
		oStruT3A:RemoveField( "T3A_NATATV" )
		oStruT3A:RemoveField( "T3A_CODCBO" )
		oStruT3A:RemoveField( "T3A_VLSLFX" )
		oStruT3A:RemoveField( "T3A_UNSLFX" )
		oStruT3A:RemoveField( "T3A_TPCONT" )
		oStruT3A:RemoveField( "T3A_DTTERM" )
		oStruT3A:RemoveField( "T3A_DCODCB" )
		oStruT3A:RemoveField( "T3A_DCATEG" )

	Else

		oStruT3A:SetProperty("T3A_MATRIC", MODEL_FIELD_OBRIGAT , .T.  )
		oStruT3A:SetProperty("T3A_CODCAT", MODEL_FIELD_OBRIGAT , .T.  )

	EndIf

	If lVldModel
		oStruT3A:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	EndIf

	//Remoção do GetSX8Num quando se tratar da Exclusão de um Evento Transmitido.
	//Necessário para não incrementar ID que não será utilizado.
	If Upper( ProcName( 2 ) ) == Upper( "GerarExclusao" )
		oStruT3A:SetProperty( "T3A_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )
	EndIf

	oModel:AddFields('MODEL_T3A', /*cOwner*/, oStruT3A)
	oModel:GetModel('MODEL_T3A'):SetPrimaryKey({'T3A_FILIAL', 'T3A_CPF', 'T3A_DTADMI'})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Vitor Henrique
@since 23/10/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   := FWLoadModel( 'TAFA403' )
	Local oView    := FWFormView():New()
	Local cCmpFil  := ""
	Local cGrpTra1 := ""
	Local cGrpTra2 := ""
	Local cGrpTra3 := ""
	Local cGrpTra4 := ""
	Local aCmpGrp  := {}
	Local nI	   := 0

	oView:SetModel( oModel )

	If !lLaySimplif

		cGrpTra1	:= "T3A_CPF|T3A_DTNASC|T3A_DTADMI|"

	Else

		cGrpTra1	:= "T3A_CPF|T3A_DTNASC|T3A_DTADMI|T3A_MATRIC|T3A_CODCAT|T3A_DCATEG|T3A_NATATV|"
		cGrpTra2	:= "T3A_CODCBO|T3A_DCODCB|T3A_VLSLFX|T3A_UNSLFX|T3A_TPCONT|T3A_DTTERM|"

	EndIf

	cGrpTra3	:= "T3A_PROTUL|"

	If TafColumnPos("T3A_DTRANS")
		cGrpTra4 += "T3A_DINSIS|T3A_DTRANS|T3A_HTRANS|T3A_DTRECP|T3A_HRRECP|"		
	EndIf

	cCmpFil := cGrpTra1 + cGrpTra2 + cGrpTra3 + cGrpTra4

	oStruT3A := FwFormStruct( 2, "T3A",{ |x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Informacoes do Trabalhador

	If lLaySimplif

		oStruT3A:AddGroup( "GRP_TRABALHADOR_01", STR0018, "", 1 ) //Informações DO Registro
		oStruT3A:AddGroup( "GRP_TRABALHADOR_02", STR0019, "", 1 ) //Informações CTPS Digital

		aCmpGrp := StrToKArr(cGrpTra1,"|")
		For nI := 1 to Len(aCmpGrp)
			oStruT3A:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_01")
		Next nI


		aCmpGrp := StrToKArr(cGrpTra2,"|")
		For nI := 1 to Len(aCmpGrp)
			oStruT3A:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_02")
		Next nI

	EndIf

	If TafColumnPos("T3A_DTRANS")
		oStruT3A:AddGroup( "GRP_TRABALHADOR_03", TafNmFolder("recibo",1), "", 1 ) //Recibo da última Transmissão
		oStruT3A:AddGroup( "GRP_TRABALHADOR_04", TafNmFolder("recibo",2), "", 1 ) //Informações de Controle eSocial

		oStruT3A:SetProperty(Strtran(cGrpTra3,"|",""),MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_03")
		
		aCmpGrp := StrToKArr(cGrpTra4,"|")
		For nI := 1 to Len(aCmpGrp)
			oStruT3A:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_04")
		Next nI
	EndIf

	oView:AddField( 'VIEW_T3A', oStruT3A, 'MODEL_T3A' )

	oView:EnableTitleView( 'VIEW_T3A', STR0001 )    //"Admissão Preliminar"
	oView:CreateHorizontalBox( 'FIELDST3A', 100 )
	oView:SetOwnerView( 'VIEW_T3A', 'FIELDST3A' )

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruT3A,"T3A")
	EndIf

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If !lMenuDif .OR. ( FindFunction( "xTafExtmp" ) .And. xTafExtmp() )
		xFunRmFStr(@oStruT3A, 'T3A')
	EndIf

	oStruT3A:RemoveField( "T3A_ID"     )
	oStruT3A:RemoveField( "T3A_LOGOPE" )

	//Tratamento para novo layout simplificdo do E-Social S-1.0
	If !lLaySimplif

		oStruT3A:RemoveField( "T3A_MATRIC" )
		oStruT3A:RemoveField( "T3A_CODCAT" )
		oStruT3A:RemoveField( "T3A_NATATV" )
		oStruT3A:RemoveField( "T3A_CODCBO" )
		oStruT3A:RemoveField( "T3A_VLSLFX" )
		oStruT3A:RemoveField( "T3A_UNSLFX" )
		oStruT3A:RemoveField( "T3A_TPCONT" )
		oStruT3A:RemoveField( "T3A_DTTERM" )
		oStruT3A:RemoveField( "T3A_DCODCB" )
		oStruT3A:RemoveField( "T3A_DCATEG" )

	EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF403Grv
Funcao de gravacao para atender o registro S-2190 (Tabela de Admissão Preliminar)

@parametros:
cLayout - Nome do Layout que esta sendo enviado, existem situacoes onde o mesmo fonte
          alimenta mais de um regsitro do E-Social, para estes casos serao necessarios
          tratamentos de acordo com o layout que esta sendo enviado.
nOpc   -  Opcao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )
cFilEv -  Filial do ERP para onde as informacoes deverao ser importadas
oXML   -  Objeto com as informacoes a serem manutenidas ( Outras Integracoes )

@Return
lRet    - Variavel que indica se a importacao foi realizada, ou seja, se as
		  informacoes foram gravadas no banco de dados
aIncons - Array com as inconsistencias encontradas durante a importacao 

@author Vitor Henrique
@since 04/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF403Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID ) //Function TAF403Grv( cLayout, nOpc, cFilEv, oXML )

	Local cTagOper     := ""
	Local cCabec       := "/eSocial/evtAdmPrelim/infoRegPrelim"
	Local cCmpsNoUpd   := "|T3A_FILIAL|T3A_ID|T3A_VERSAO|T3A_VERANT|T3A_PROTUL|T3A_PROTPN|T3A_STATUS|T3A_ATIVO|"
	Local cValChv      := ""
	Local cNewDtIni    := ""
	Local cNewDtFin    := ""
	Local cValorXml    := ""
	Local cChave       := ""
	Local cInconMsg    := ""
	Local nIndChv      := 2
	Local nIndIDVer    := 1
	Local nI           := 0
	Local lRet         := .F.
	Local aIncons      := {}
	Local aRules       := {}
	Local aChave       := {}
	Local aArea        := GetArea()
	Local oModel       := Nil

	Private oDados     := oXML
	Private lVldModel  := .T. //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.

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

	cTagOper   := ""
	cCabec     := "/eSocial/evtAdmPrelim/infoRegPrelim"
	cCmpsNoUpd := "|T3A_FILIAL|T3A_ID|T3A_VERSAO|T3A_VERANT|T3A_PROTUL|T3A_PROTPN|T3A_STATUS|T3A_ATIVO|"
	cValChv    := ""
	cNewDtIni  := ""
	cNewDtFin  := ""
	cValorXml  := ""
	cChave     := ""
	cInconMsg  := ""
	cLogOpeAnt := ""

	nIndChv    := 2
	nIndIDVer  := 1
	nI         := 0

	lRet       := .F.

	aIncons    := {}
	aRules     := {}
	aChave     := {}
	aArea      := GetArea()

	oModel     := Nil

	oDados     := oXML
	lVldModel  := .T. //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.

	/*---------------------------------------------------------
	Verificar se o cpf foi informado para a chave
	---------------------------------------------------------*/
	cValChv := FTafGetVal( cCabec + "/cpfTrab", 'C', .F., @aIncons, .F., '', '' )

	If !Empty( cValChv )
		Aadd( aChave, { "C", "T3A_CPF", cValChv, .T.} )
		cChave	+= Padr( cValChv, Tamsx3( aChave[ 1, 2 ])[1] )
	EndIf

	If lLaySimplif

		/*---------------------------------------------------------
		Verificar se a matricula foi informada para a chave
		---------------------------------------------------------*/
		cValChv := FTafGetVal( cCabec + "/matricula", 'C', .F., @aIncons, .F., '', '' )

		If !Empty( cValChv )
			Aadd( aChave, { "C", "T3A_MATRIC", cValChv, .T.} )
			cChave	+= Padr( cValChv, Tamsx3( aChave[ 2, 2 ])[1] )
		EndIf

	Else

		/*---------------------------------------------------------
		Verificar se a data de admissao foi informada para a chave
		---------------------------------------------------------*/
		cValChv := FTafGetVal( cCabec + "/dtAdm", 'C', .F., @aIncons, .F., '', '' )
		cValChv := StrTran( cValChv, "-", "" )
		cValChv := Substr(cValChv, 1, 4) + Substr(cValChv, 5,2) + Substr(cValChv, 7,2)

		If !Empty( cValChv )
			Aadd( aChave, { "C", "T3A_DTADMI", cValChv, .T. } )
			cChave += Padr( cValChv, Tamsx3( aChave[ 2, 2 ])[1] )
			nIndChv := 2 //T3A_FILIAL+T3A_CPF+DTOS(T3A_DTADMI)+T3A_ATIVO 
		EndIf

	EndIf

	//Muda o indice, caso seja o layout simplificdo 
	If lLaySimplif

		nIndChv := 5 //T3A_FILIAL+T3A_CPF+T3A_MATRIC+DTOS(T3A_DTADMI)+T3A_ATIVO 

	EndIf

	/*---------------------------------------------------------
	Verifica se o evento não foi transmitido
	---------------------------------------------------------*/
	DbSelectArea("T3A")	
	T3A->(DbSetOrder(nIndChv)) //T3A_FILIAL+T3A_CPF+DTOS(T3A_DTADMI)+T3A_ATIVO 
	If T3A->( MsSeek(FTafGetFil(cFilEv,@aIncons,"T3A") + cChave + '1' ) )
	
		If !T3A->T3A_STATUS $ ( "2|4|6" )
	
			nOpc := 4
	
		EndIf

	EndIf

	RestArea(aArea)

	Begin Transaction

		//---------------------------------------------------------------
		//Funcao para validar se a operacao desejada pode ser realizada
		//---------------------------------------------------------------
		If FTafVldOpe( "T3A", nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA403", cCmpsNoUpd, nIndIDVer, .F. )

			If TafColumnPos( "T3A_LOGOPE" )
				cLogOpeAnt := T3A->T3A_LOGOPE
			EndIf

			/*---------------------------------------------------------
			/Quando se tratar de uma Exclusao direta apenas preciso
			realizar o Commit(), nao eh necessaria nenhuma manutencao
			nas informacoes
			---------------------------------------------------------*/
			If nOpc <> 5

				/*---------------------------------------------------------
				Carrego array com os campos De/Para de gravacao das informacoes
				---------------------------------------------------------*/
				aRules := TAF403Rul( cTagOper )

				oModel:LoadValue( "MODEL_T3A", "T3A_FILIAL", xFilial("T3A"))

				/*Implementação para o projeto de migração TAF x Smart E-Social e Outros Softwares x TAF*/ 

				If TAFColumnPos( "T3A_XMLID" )
					oModel:LoadValue( "MODEL_T3A", "T3A_XMLID", cXmlID )
				EndIf

				/*---------------------------------------------------------
				Rodo o aRules para gravar as informacoes
				---------------------------------------------------------*/
				For nI := 1 To Len( aRules )

					cValorXml := FTafGetVal( aRules[ nI, 02 ], aRules[nI, 03], aRules[nI, 04], @aIncons, .F., , aRules[ nI, 01 ] )
					oModel:LoadValue("MODEL_T3A", aRules[ nI, 01 ], cValorXml)

				Next

				If Findfunction("TAFAltMan")
					If nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T3A', 'T3A_LOGOPE' , '1', '' )
					ElseIf nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T3A', 'T3A_LOGOPE' , '', cLogOpeAnt )
					EndIf
				EndIf
			EndIf

			/*---------------------------------------------------------
			Efetiva a operacao desejada
			---------------------------------------------------------*/
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

	/*---------------------------------------------------------
	Zerando os arrays e os Objetos utilizados no processamento
	---------------------------------------------------------*/
	aSize( aRules, 0 )
	aRules     := Nil

	aSize( aChave, 0 )

	aChave     := Nil

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF403Rul
Regras para gravacao das informacoes do evento (S-2190)

@Param
cTagOper - Qual a estrutura de Tags que serao lidas para
gravacao das informacoes

@Return
aRull  - Regras para a gravacao das informacoes

@author Vitor Henrique
@since 23/10/2015
@version 1.0

/*/
//-------------------------------------------------------------------

Static Function TAF403Rul( cTagOper )

	Local aRull  := {}
	Local cCabec := "/eSocial/evtAdmPrelim/infoRegPrelim"

	If oDados:XPathHasNode(cCabec + "/cpfTrab")
		aAdd( aRull, { "T3A_CPF"    , cCabec + "/cpfTrab"   , "C", .F. } ) 		//codFuncao
	EndIf

	If oDados:XPathHasNode(cCabec + "/dtNascto")
		aAdd( aRull, { "T3A_DTNASC" , cCabec + "/dtNascto"  , "D", .F. } ) 		//iniValid
	EndIf

	If oDados:XPathHasNode(cCabec + "/dtAdm")
		aAdd( aRull, { "T3A_DTADMI" , cCabec + "/dtAdm"     , "D", .F. } ) 		//fimValid
	EndIf

	// Controle de Versão Simplificada do E-Social Versão S-1.0
	If lLaySimplif

		If oDados:XPathHasNode(cCabec + "/matricula")
			aAdd( aRull, { "T3A_MATRIC"    , cCabec + "/matricula"   , "C", .F. } ) 		///matricula
		EndIf

		If oDados:XPathHasNode(cCabec + "/codCateg")
			aAdd( aRull, { "T3A_CODCAT"		, FGetIdInt( "codCateg", , cCabec + "/codCateg" ,,,,,), "C", .T., 'C87' } )  //codCateg
		EndIf

		If oDados:XPathHasNode(cCabec + "/natAtividade")
			aAdd( aRull, { "T3A_NATATV"    , cCabec + "/natAtividade"   , "C", .F. } ) 		//natAtividade
		EndIf

		/*infoRegCTPS*/
		If oDados:XPathHasNode(cCabec + "/infoRegCTPS/CBOCargo")
			aAdd( aRull, { "T3A_CODCBO"		, FGetIdInt( "codCBO", , cCabec + "/infoRegCTPS/CBOCargo",,,,, ), "C", .T.} )  //codCBO
		EndIf

		If oDados:XPathHasNode(cCabec + "/infoRegCTPS/vrSalFx")
			aAdd( aRull, { "T3A_VLSLFX"    , cCabec + "/infoRegCTPS/vrSalFx"   , "N", .F. } ) 		//vrSalFx
		EndIf

		If oDados:XPathHasNode(cCabec + "/infoRegCTPS/undSalFixo")
			aAdd( aRull, { "T3A_UNSLFX"    , cCabec + "/infoRegCTPS/undSalFixo"   , "C", .F. } ) 	//undSalFixo
		EndIf

		If oDados:XPathHasNode(cCabec + "/infoRegCTPS/tpContr")
			aAdd( aRull, { "T3A_TPCONT"    , cCabec + "/infoRegCTPS/tpContr"   , "C", .F. } ) 		//tpContr
		EndIf

		If oDados:XPathHasNode(cCabec + "/infoRegCTPS/dtTerm")
			aAdd( aRull, { "T3A_DTTERM"    , cCabec + "/infoRegCTPS/dtTerm"   , "D", .F. } ) 		//dtTerm
		EndIf

	EndIf

Return( aRull )

//-------------------------------------------------------------------
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

	Local cVerAnt     := ""
	Local cProtocolo  := ""
	Local cVersao     := ""
	Local cEvento     := ""
	Local cChvRegAnt  := ""
	Local cLogOpeAnt  := ""
	Local cAliasQry   := GetNextAlias()
	Local nOperation  := oModel:GetOperation()
	Local nlI         := 0
	Local nlY         := 0
	Local lRetorno    := .T.
	Local lExecAltMan := .F.
	Local aGrava      := {}
	Local aCampos     := {}
	Local oModelT3A   := Nil

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT

			TafAjustID( "T3A", oModel)

			oModel:LoadValue( 'MODEL_T3A', 'T3A_VERSAO', xFunGetVer() )

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_T3A', 'T3A_LOGOPE' , '2', '' )
			Endif

			FwFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE

			/*---------------------------------------------------------
			Seek para posicionar no registro antes de realizar as
			validacoes visto que quando nao esta pocisionado nao eh
			possivel analisar os campos nao usados como _STATUS
			---------------------------------------------------------*/
			T3A->( DbSetOrder( 3 ) )
			If T3A->( MsSeek( xFilial( 'T3A' ) + FwFldGet('T3A_ID') + '1' ) )

				If TafColumnPos( "T3A_LOGOPE" )
						cLogOpeAnt := T3A->T3A_LOGOPE
				EndIf

				If lLaySimplif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se o registro ja foi transmitido³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If T3A->T3A_STATUS $ ( "4" )

						oModelT3A := oModel:GetModel( 'MODEL_T3A' )

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Busco a versao anterior do registro para gravacao do rastro³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cVerAnt    := oModelT3A:GetValue( "T3A_VERSAO" )
						cProtocolo := oModelT3A:GetValue( "T3A_PROTUL" )
						cEvento    := oModelT3A:GetValue( "T3A_EVENTO" )

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Neste momento eu gravo as informacoes que foram carregadas       ³
						//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
						//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
						//³nao devem ser consideradas neste momento                         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nlI := 1 To 1
							For nlY := 1 To Len( oModelT3A:aDataModel[ nlI ] )
									Aadd( aGrava, { oModelT3A:aDataModel[ nlI, nlY, 1 ], oModelT3A:aDataModel[ nlI, nlY, 2 ] } )
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
						FAltRegAnt( 'T3A', '2' )

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
								oModel:LoadValue( 'MODEL_T3A', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
						Next

							//Necessário Abaixo do For Nao Retirar
						If Findfunction("TAFAltMan")
								TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T3A', 'T3A_LOGOPE' , '' , cLogOpeAnt )
								lExecAltMan := .T.
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
						oModel:LoadValue( 'MODEL_T3A', 'T3A_VERSAO', cVersao )
						oModel:LoadValue( 'MODEL_T3A', 'T3A_VERANT', cVerAnt )
						oModel:LoadValue( 'MODEL_T3A', 'T3A_PROTPN', cProtocolo )
						oModel:LoadValue( 'MODEL_T3A', 'T3A_EVENTO', "A" )
						oModel:LoadValue( 'MODEL_T3A', 'T3A_PROTUL', "" )

					EndIf

				EndIf

				If !lExecAltMan
					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T3A', 'T3A_LOGOPE' , '' , cLogOpeAnt )
					EndIf
				EndIf

				//Gravo a alteração
				FwFormCommit( oModel )
				TAFAltStat( 'T3A', " " )

			EndIf

		ElseIf nOperation == MODEL_OPERATION_DELETE

			oModel:DeActivate()
			oModel:SetOperation( 5 )
			oModel:Activate()

			FwFormCommit( oModel )

		EndIf

	End Transaction

Return ( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF403Xml
Funcao de geracao do XML para atender o registro S-1040
Quando a rotina for chamada o registro deve estar posicionado

@Param:
cAlias - Alias corrente (Parametro padrao MVC)
nRecno - Recno corrente (Parametro padrao MVC)
nOpc   - Opcao selecionada (Parametro padrao MVC)
lJob   - Informa se foi chamado por Job
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@Return:
cXml - Estrutura do Xml do Layout S-1040

@author Vitor Henrique
@since 04/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF403Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

	Local cXml      := ""
	Local cLayout   := "2190"
	Local cReg      := "AdmPrelim"
	Local cId       := ""
	Local cVerAnt   := ""
	Local aAreaT3A  := {}
	Local lXmlVLd   := IIF(FindFunction( 'TafXmlVLD' ),TafXmlVLD( 'TAF403XML' ),.T.)
	
	Default lJob    := .F.
	Default cSeqXml := ""

	If lXmlVLd

		aAreaT3A := {}

		cXml +=			"<infoRegPrelim>"

		cXml +=				xTafTag("cpfTrab" ,T3A->T3A_CPF,, .F.)
		cXml +=				xTafTag("dtNascto",T3A->T3A_DTNASC,, .F.)
		cXml +=				xTafTag("dtAdm"   ,T3A->T3A_DTADMI,, .F.)

		If lLaySimplif

			cCodCat := 			AllTrim(POSICIONE("C87" ,1, xFilial("C87")+T3A->T3A_CODCAT,"C87_CODIGO"))

			cXml +=				xTafTag("matricula"		,T3A->T3A_MATRIC,, .F. )
			cXml +=				xTafTag("codCateg"		,cCodCat,, .F.)
			cXml +=				xTafTag("natAtividade"	,T3A->T3A_NATATV,, .T. )

			
			xTafTagGroup("infoRegCTPS"	,{{"CBOCargo"	,Posicione( "C8Z", 1, xFilial( "C8Z" ) + T3A->T3A_CODCBO, "C8Z_CODIGO"),,.F.};
										, {"vrSalFx" 	,IIF(T3A->T3A_UNSLFX == "7","0", T3A->T3A_VLSLFX), PesqPict("T3A","T3A_VLSLFX"),.F.};
										, {"undSalFixo" ,T3A->T3A_UNSLFX,,.F.};
										, {"tpContr" 	,T3A->T3A_TPCONT,,.F.};
										, {"dtTerm" 	,T3A->T3A_DTTERM,,Iif(T3A->T3A_TPCONT == "2",.F.,.T.)}};
										, @cXml)			

		EndIf

		cXml +=			"</infoRegPrelim>"

		/*---------------------------------------------------------
		Estrutura do cabecalho
		---------------------------------------------------------*/
		cXml := xTafCabXml(cXml,"T3A",cLayout,cReg,,cSeqXml)

		/*---------------------------------------------------------
		Executa gravacao do registro
		---------------------------------------------------------*/
		If !lJob
			xTafGerXml(cXml,cLayout)
		EndIf

	EndIf

Return(cXml)

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclusão do evento (S-3000)

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function é chamada pelo TafIntegraESocial

@Return .T.

@Author Vitor Henrique Ferreira
@Since 30/06/2015
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
	Local nOperation := oModel:GetOperation()
	Local nlY        := 0
	Local nlI        := 0
	Local aCampos    := {}
	Local aGrava     := {}
	Local aGravaT3A  := {}
	Local oModelT3A  := Nil

	Begin Transaction

		/*---------------------------------------------------------
		Posiciona o item
		---------------------------------------------------------*/
		("T3A")->( DBGoTo( nRecno ) )
		
		oModelT3A	:= oModel:GetModel( 'MODEL_T3A' )
											
		/*---------------------------------------------------------
		Busco a versao anterior do registro para gravacao do rastro
		---------------------------------------------------------*/
		cVerAnt   	:= oModelT3A:GetValue( "T3A_VERSAO" )
		cProtocolo	:= oModelT3A:GetValue( "T3A_PROTUL" )
		cEvento	:= oModelT3A:GetValue( "T3A_EVENTO" )
														
		/*---------------------------------------------------------
		Neste momento eu gravo as informacoes que foram carregadas
		na tela, pois neste momento o usuario ja fez as modificacoes
		que precisava e as mesmas estao armazenadas em memoria,
		ou seja, nao devem ser consideradas neste momento
		---------------------------------------------------------*/
		For nlI := 1 To 1
			For nlY := 1 To Len( oModelT3A:aDataModel[ nlI ] )
				Aadd( aGrava, { oModelT3A:aDataModel[ nlI, nlY, 1 ], oModelT3A:aDataModel[ nlI, nlY, 2 ] } )
			Next
		Next
																																								
		/*---------------------------------------------------------
		Seto o campo como Inativo e gravo a versao do novo registro
		no registro anterior
		ATENCAO -> A alteracao destes campos deve sempre estar
		abaixo do Loop do For, pois devem substituir as informacoes
		que foram armazenadas no Loop acima
		---------------------------------------------------------*/
		FAltRegAnt( 'T3A', '2' )

		/*---------------------------------------------------------
		Neste momento eu preciso setar a operacao do modeL como
		Inclusao
		---------------------------------------------------------*/
		oModel:DeActivate()
		oModel:SetOperation( 3 )
		oModel:Activate()
						
		/*---------------------------------------------------------
		Neste momento eu realizo a inclusao do novo registro ja
		contemplando as informacoes alteradas pelo usuario
		---------------------------------------------------------*/
		For nlI := 1 To Len( aGrava )
			oModel:LoadValue( 'MODEL_T3A', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
		Next
			
		/*---------------------------------------------------------
		Busco a nova versao do registro
		---------------------------------------------------------*/
		cVersao := xFunGetVer()
		
		/*---------------------------------------------------------
		ATENCAO -> A alteracao destes campos deve sempre estar     
		abaixo do Loop do For, pois devem substituir as informacoes
		que foram armazenadas no Loop acima                        
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_T3A", "T3A_VERSAO", cVersao )
		oModel:LoadValue( "MODEL_T3A", "T3A_VERANT", cVerAnt )
		oModel:LoadValue( "MODEL_T3A", "T3A_PROTPN", cProtocolo )
		oModel:LoadValue( "MODEL_T3A", "T3A_PROTUL", "" )
		
		// Tratamento para limpar o ID unico do xml
		cAliasPai := "T3A"
		
		If TAFColumnPos( cAliasPai+"_XMLID" )
			oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
		EndIf
		
		/*---------------------------------------------------------
		Tratamento para que caso o Evento Anterior fosse de exclusão
		seta-se o novo evento como uma "nova inclusão", caso contrário o
		evento passar a ser uma alteração
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_T3A", "T3A_EVENTO", "E" )
		oModel:LoadValue( "MODEL_T3A", "T3A_ATIVO", "1" )		
		
		FwFormCommit( oModel )
		TAFAltStat( 'T3A',"6" )
	
	End Transaction
	
Return ( .T. )
//-------------------------------------------------------------------
