#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA528.CH"
#INCLUDE "TOPCONN.CH"

Static __lLay0205	:= TafLayESoc("02_05_00")

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA528
@type			function
@description	Exame Toxicológico do Motorista Profissional - S-2221.
@author		Karyna Martins
@since			21/01/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Function TAFA528()
	
	Private cNomEve	:= "S2221"
	Private oBrowse	:= FWMBrowse():New()

	If FindFunction("TAFDesEven")
		TAFDesEven()
	EndIf

	If TAFAlsInDic( "V3B" )
	
		If !__lLay0205
	
			cMessage := STR0009 //"Este evento só pode ser transmitido na versão 2.5 e parametro MV_TAFVLES está configurado com uma versão anterior."
			cMessage += Chr( 13 ) + Chr( 10 )	
			cMessage += STR0010 // "Verifique."
			Aviso( STR0011, cMessage, { STR0005 }, 2 ) //##"Atenção!" ##"Encerrar"
	
		Else

			oBrowse:SetDescription( STR0001 ) //"Exame Toxicológico do Motorista Profissional"
			oBrowse:SetAlias( 'V3B' )
			oBrowse:SetMenuDef( "TAFA528" )
			oBrowse:SetFilterDefault(TAFBrwSetFilter("V3B","TAFA258","S-2210"))

			TafLegend(2,"V3B",@oBrowse)
			oBrowse:Activate()

		EndIf	
	
	Else
		cMessage := STR0002 //"Ambiente desatualizado com a versão do programa existente no repositório de dados."
		cMessage += Chr( 13 ) + Chr( 10 )
		cMessage += Chr( 13 ) + Chr( 10 )
		cMessage += STR0003 //"Execute a atualização do dicionário do Layout 2.5 do eSocial por meio do compatibilizador UPDDISTR."
		Aviso( STR0004, cMessage, { STR0005 }, 2 ) //##"Dicionário Incompatível" ##"Encerrar"
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@type			function
@description	Função genérica MVC do menu.
@author		Karyna Martins
@since			21/01/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina	:=	{}
	Local aFuncao	:=	{}

	If FindFunction('TafXmlRet')
		aAdd( aFuncao, { "", "TafxmlRet('TAF528Xml','2221','V3B')"						, "1" } )
	Else
		aAdd( aFuncao, { "", "TAF528Xml"												, "1" } )
	EndIf

	aAdd( aFuncao, { "", "xFunHisAlt( 'V3B', 'TAFA528' ,,,, 'TAF528XML','2221' )"			, "3" } )
	aAdd( aFuncao, { "", "TAFXmlLote( 'V3B', 'S-2221', 'evtToxic', 'TAF528Xml',, oBrowse )"	, "5" } )

	//Variável Private utilizada para controle do menu na chamada da View na operação de Histórico de Alterações
	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If lMenuDif .Or. ViewEvent('S-2221')
		ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TAFA528" OPERATION 2 ACCESS 0 //"Visualizar"
	Else
		aRotina := xFunMnuTAF( "TAFA528",, aFuncao )
	EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@type			function
@description	Função genérica MVC do modelo.
@author		Karyna Martins
@since			21/01/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStruV3B	:=	FWFormStruct( 1, "V3B" )
	Local oModel	:=	MpFormModel():New("TAFA528",,,{|oModel| SaveModel(oModel)})

	//Variável Private utilizada para controle do modelo na operação de integração via TAFAINTEG
	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruV3B:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
	EndIf

	oStruV3B:SetProperty( 'V3B_INDREC', MODEL_FIELD_OBRIGAT , .T. ) //Conforme o layout 2.5 do eSocial, esse campo é de preenchimento obrigatório.
	oStruV3B:SetProperty( "V3B_FUNC"  , MODEL_FIELD_NOUPD   , .T. )

	oModel:AddFields('MODEL_V3B', /*cOwner*/, oStruV3B)
	oModel:GetModel('MODEL_V3B'):SetPrimaryKey({'V3B_FILIAL', 'V3B_FUNC', 'V3B_DTEXAM'})

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@type			function
@description	Função genérica MVC da view.
@author		Karyna Martins
@since			21/01/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel		:=	FWLoadModel( "TAFA528" )
	Local oStruV3Ba	:=	Nil
	Local oStruV3Bb	:=	Nil
	Local oStruV3Bc	:=	Nil
	Local oStruV3Bd	:= Nil
	Local oStruV3Be	:= Nil
	Local oView		:=	FWFormView():New()
	Local cCmpFil		:=	""

	oView:SetModel( oModel ) 

	//Principal
	cCmpFil := "V3B_ID|"
	oStruV3Ba := FWFormStruct( 2, "V3B", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	//Campos do Grupo Vinculo
	cCmpFil := "V3B_FUNC|V3B_DFUNC|V3B_CPF|V3B_NIS|V3B_MATRIC|V3B_CODCAT|"
	oStruV3Bb := FWFormStruct( 2, "V3B", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	//Campos do Grupo Toxicologico
	cCmpFil := "V3B_DTEXAM|V3B_CNPJLA|V3B_CODSEX|V3B_CODMED|V3B_DCODME|V3B_INDREC|"
	oStruV3Bc := FWFormStruct( 2, "V3B", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	//Campo do Numero do Recibo"
	cCmpFil := "V3B_PROTUL|"
	oStruV3Bd := FWFormStruct( 2, "V3B", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	If TafColumnPos("V3B_DTRANS")
		cCmpFil := "V3B_DINSIS|V3B_DTRANS|V3B_HTRANS|V3B_DTRECP|V3B_HRRECP|"
		oStruV3Be := FWFormStruct( 2, "V3B", { |x| AllTrim( x ) + "|" $ cCmpFil } )
	EndIf


	/*--------------------------------------------------------------------------------------------
										Estrutura da View
	---------------------------------------------------------------------------------------------*/

	oView:AddField( "VIEW_V3Ba", oStruV3Ba, "MODEL_V3B" )

	oView:AddField( "VIEW_V3Bb", oStruV3Bb, "MODEL_V3B" )
	oView:EnableTitleView( "VIEW_V3Bb", STR0007 ) //"Vinculo"

	oView:AddField( "VIEW_V3Bc", oStruV3Bc, "MODEL_V3B" )
	oView:EnableTitleView( "VIEW_V3Bc", STR0008 ) //"Toxicologico"

	oView:AddField( "VIEW_V3Bd", oStruV3Bd, "MODEL_V3B" )
	oView:EnableTitleView( 'VIEW_V3Bd',  TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"  
	If TafColumnPos("V3B_DTRANS")
		oView:AddField( "VIEW_V3Be", oStruV3Be, "MODEL_V3B" )
		oView:EnableTitleView( 'VIEW_V3Be',  TafNmFolder("recibo",2) )
	EndIf

	/*--------------------------------------------------------------------------------------------
								Ordem na Tela e Insere uma linha
	---------------------------------------------------------------------------------------------*/
	oStruV3Bb:SetProperty( "V3B_FUNC" 	, MVC_VIEW_ORDEM	, "01"	)
	oStruV3Bb:SetProperty( "V3B_DFUNC"	, MVC_VIEW_ORDEM	, "02"	)
	oStruV3Bb:SetProperty( "V3B_CPF" 	, MVC_VIEW_ORDEM	, "03"	)
	oStruV3Bb:SetProperty( "V3B_NIS" 	, MVC_VIEW_ORDEM	, "04"	)
	oStruV3Bb:SetProperty( "V3B_MATRIC", MVC_VIEW_ORDEM	, "05"	)
	oStruV3Bb:SetProperty( "V3B_CODCAT", MVC_VIEW_ORDEM	, "06"	)

	oStruV3Bc:SetProperty( "V3B_INDREC" 	, MVC_VIEW_ORDEM	, "01"	)
	oStruV3Bc:SetProperty( "V3B_DTEXAM" 	, MVC_VIEW_ORDEM	, "02"	)
	oStruV3Bc:SetProperty( "V3B_CNPJLA" 	, MVC_VIEW_ORDEM	, "03"	)
	oStruV3Bc:SetProperty( "V3B_CODSEX" 	, MVC_VIEW_ORDEM	, "04"	)
	oStruV3Bc:SetProperty( "V3B_CODMED" 	, MVC_VIEW_ORDEM	, "05"	)
	oStruV3Bc:SetProperty( "V3B_DCODME" 	, MVC_VIEW_ORDEM	, "06"	)

	oStruV3Bc:SetProperty( "V3B_CODSEX" 	, MVC_VIEW_INSERTLINE, .T.)

	oStruV3Bb:SetProperty( "V3B_CODCAT"     , MVC_VIEW_TITULO 	, "Cod. Categoria"	)

		
	/*-----------------------------------------------------------------------------------
									Estrutura do Folder
	-------------------------------------------------------------------------------------*/

	oView:CreateHorizontalBox( "PAINEL_PRINCIPAL", 100 )

	oView:CreateFolder( "FOLDER_PRINCIPAL", "PAINEL_PRINCIPAL" )

	oView:AddSheet( "FOLDER_PRINCIPAL", "ABA01", STR0001 ) //"Exame Toxicológico do Motorista Profissional"
	oView:CreateHorizontalBox( "V3Ba", 15,,, "FOLDER_PRINCIPAL", "ABA01" )
	oView:CreateHorizontalBox( "V3Bb", 35,,, "FOLDER_PRINCIPAL", "ABA01" )
	oView:CreateHorizontalBox( "V3Bc", 50,,, "FOLDER_PRINCIPAL", "ABA01" )

	oView:AddSheet( "FOLDER_PRINCIPAL", "ABA02", TafNmFolder("recibo",1) ) //"Exame Toxicológico do Motorista Profissional"
	If TafColumnPos("V3B_DTRANS")
		oView:CreateHorizontalBox( "V3Bd", 20,,, "FOLDER_PRINCIPAL", "ABA02" )
		oView:CreateHorizontalBox( "V3Be", 80,,, "FOLDER_PRINCIPAL", "ABA02" )
	Else
		oView:CreateHorizontalBox( "V3Bd", 100,,, "FOLDER_PRINCIPAL", "ABA02" )
	EndIf

	oView:SetOwnerView( "VIEW_V3Ba", "V3Ba" )
	oView:SetOwnerView( "VIEW_V3Bb", "V3Bb" )
	oView:SetOwnerView( "VIEW_V3Bc", "V3Bc" )
	oView:SetOwnerView( "VIEW_V3Bd", "V3Bd" )
	If TafColumnPos("V3B_DTRANS")
		oView:SetOwnerView( "VIEW_V3Be", "V3Be" )
	EndIf

Return( oView )

//---------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
@type			function
@description	Função de gravação dos dados, executada na confirmação do modelo.
@author		Karyna Martins
@since			21/01/2019
@version		1.0
@param			oModel	-	Modelo de dados
/*/
//---------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local cVerAnt   	:= ""
	Local cProtocolo	:= ""
	Local cVersao   	:= ""
	Local cChvRegAnt	:= ""
	Local cEvento		:= ""
	Local nOperation	:= oModel:GetOperation()
	Local nlI   	    := 0
	Local lRetorno	    := .T.
	Local aGrava    	:= {}
	Local oModelV3B  	:= Nil

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT

			oModel:LoadValue( "MODEL_V3B", "V3B_VERSAO", xFunGetVer() )
			TAFAltMan( 3 , 'Save' , oModel, 'MODEL_V3B', 'V3B_LOGOPE' , '2', '' )
			FWFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE 

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta pocisionado nao eh possivel analisar   ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			V3B->( DbSetOrder( 3 ) )
			If V3B->( MsSeek( xFilial( 'V3B' ) + M->V3B_ID + '1' ) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o registro ja foi transmitido com sucesso    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If V3B->V3B_STATUS ==  "4"

					oModelV3B := oModel:GetModel( 'MODEL_V3B' )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao anterior do registro para gravacao do rastro³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVerAnt    	:= oModelV3B:GetValue( "V3B_VERSAO" )
					cProtocolo 	:= oModelV3B:GetValue( "V3B_PROTUL" )
					cEvento		:= oModelV3B:GetValue( "V3B_EVENTO" )
					cLogOpeAnt  := oModelV3B:GetValue( "V3B_LOGOPE" )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu gravo as informacoes que foram carregadas       ³
					//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
					//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
					//³nao devem ser consideradas neste momento                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nlI := 1 to Len( oModelV3B:aDataModel[ 1 ] )
						Aadd( aGrava, { oModelV3B:aDataModel[ 1, nlI, 1 ], oModelV3B:aDataModel[ 1, nlI, 2 ] } )
					Next nlI

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seto o campo como Inativo e gravo a versao do novo registro³
					//³no registro anterior                                       ³
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FAltRegAnt( 'V3B', '2' )	

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
						oModel:LoadValue( 'MODEL_V3B', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
					Next

					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_V3B', 'V3B_LOGOPE' , '' , cLogOpeAnt )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao que sera gravada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVersao := xFunGetVer()

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oModel:LoadValue( 'MODEL_V3B', 'V3B_VERSAO', cVersao )
					oModel:LoadValue( 'MODEL_V3B', 'V3B_VERANT', cVerAnt )
					oModel:LoadValue( 'MODEL_V3B', 'V3B_PROTPN', cProtocolo )
					oModel:LoadValue( 'MODEL_V3B', 'V3B_PROTUL', "" )  

					oModel:LoadValue( "MODEL_V3B", "V3B_EVENTO", "A" )
					// Tratamento para limpar o ID unico do xml
					cAliasPai := "V3B"
					oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					
					FwFormCommit( oModel )
					TAFAltStat( 'V3B', " " )

				ElseIf	V3B->V3B_STATUS == "2"
					TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
					lRetorno:= .F.
				ElseIf V3B->V3B_STATUS == "6"
					TAFMsgVldOp(oModel,"6")//"Registro não pode ser alterado. Aguardando proc. Transm. evento de Exclusão S-3000"
					lRetorno:= .F.
				ElseIf V3B->V3B_STATUS == "7"
					TAFMsgVldOp(oModel,"7") //"Registro não pode ser alterado, pois o evento já se encontra na base do RET"
					lRetorno:= .F.
				Else
		
					cLogOpeAnt := V3B->V3B_LOGOPE
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_V3B', 'V3B_LOGOPE' , '' , cLogOpeAnt )

					FwFormCommit( oModel )
					TAFAltStat( 'V3B', " " )
				EndIf
			EndIf

		//Exclusão Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_DELETE

			cChvRegAnt := V3B->(V3B_ID + V3B_VERANT)

			If !Empty( V3B->V3B_VERANT )
				
				TAFAltStat( 'V3B', " " )
				FwFormCommit( oModel )
				
				If V3B->V3B_EVENTO == "A" .Or. V3B->V3B_EVENTO == "E"
					TAFRastro( 'V3B', 1, cChvRegAnt, .T. , , IIF(Type("oBrw") == "U", Nil, oBrw) )
				EndIf

			Else

				oModel:DeActivate()
				oModel:SetOperation( 5 )
				oModel:Activate()
				FwFormCommit( oModel )

			EndIf

		EndIf

	End Transaction

Return(lRetorno)
 
//---------------------------------------------------------------------
/*/{Protheus.doc} TAF520Grv
@type			function
@description	Função de integração dos dados para o evento S-2221.
@author		Karyna Martins
@since			21/01/2019
@version		1.0
@param			cLayout	-	Nome do Layout que está sendo importado
@param			nOpc	-	Operação a ser executada ( 3 = Inclusão, 4 = Alteração, 5 = Exclusão )
@param			cFilEv	-	Filial do ERP para onde as informações devem ser importadas
@param			oXML	-	Objeto com o XML padronizado a ser importado
@return		lRet	-	Variável que indica se a importação foi realizada
@return		aIncons	-	Array com as inconsistências encontradas durante a importação
/*/
//---------------------------------------------------------------------
Function TAF528Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp,cXmlID )

	Local cCmpsNoUpd	:= "|V3B_FILIAL|V3B_ID|V3B_VERSAO|V3B_CPF|V3B_NIS|V3B_MATRIC|V3B_CODCAT|V3B_DTEXAM|V3B_CNPJLA|V3B_CODSEX|V3B_CODMED|V3B_ATIVO|V3B_INDREC|V3B_EVENTO|V3B_PROTPN|V3B_DCODME|V3B_PROTUL|"
	Local oModel		:=	Nil
	Local cCabec		:=	"/eSocial/evtToxic/"
	Local cInconMsg		:=	""
	Local cString		:=	""
	Local cRecibo		:=	""
	Local cIdTrab		:=  ""
	Local cCpf          :=  ""
	Local cMatricula    :=  ""
	Local cCodCateg     :=  ""
	Local dDtExam       :=  Ctod("")
	Local cPeriodo      :=  ""
	Local cCodEvent		:=  Posicione( "V3B", 2, xFilial( "V3B" ) + "S-" + cLayout, "V3B->V3B_ID" )
	Local nI			:=	0
	Local nSeqErrGrv	:=	0
	Local aIncons		:=	{}
	Local aRules		:=	{}
	Local aChave		:=	{}
	Local lRet			:=	.F.
	Local cLogOpeAnt	:=  ""

	Private lVldModel	:=	.T. //Caso a chamada seja via integração, seto a variável de controle de validação como .T.
	Private oDados		:=	{}

	Default cLayout		:=	""
	Default nOpc		:=	1
	Default cFilEv		:=	""
	Default oXML		:=	Nil
	Default cOwner		:= ""
	Default cFilTran	:= ""
	Default cPredeces	:= ""
	Default cComplem	:= ""
	Default cXmlID		:=	""
	Default cGrpTran	:= ""
	Default cEmpOriGrp	:= ""
	Default cFilOriGrp	:= ""
	Default nTafRecno	:= 0

	oDados := oXML

	If !TAFAlsInDic( "V3B" )
		cString := STR0002 //"Ambiente desatualizado com a versão do programa existente no repositório de dados."
		cString += Chr( 13 ) + Chr( 10 )
		cString += Chr( 13 ) + Chr( 10 )
		cString += STR0003 //"Execute a atualização do dicionário do Layout 2.5 do eSocial por meio do compatibilizador UPDDISTR."

		aAdd( aIncons, cString )

		Return( { lRet, aIncons } )
	EndIf

	Begin Transaction

		cRecibo    := FTAFGetVal( cCabec + "ideEvento/nrRecibo"  ,"C", .F., @aIncons, .F. )
		cCpf	   := FTAFGetVal( cCabec + "ideVinculo/cpfTrab"  ,"C", .F., @aIncons, .F. )
		cMatricula := FTAFGetVal( cCabec + "ideVinculo/matricula","C", .F., @aIncons, .F. )
		cCodCateg  := FTAFGetVal( cCabec + "ideVinculo/codCateg" ,"C", .F., @aIncons, .F. )
		dDtExam    := FTAFGetVal( cCabec + "toxicologico/dtExame"	, "D", .F.,, .F. )
		cPeriodo   := SubStr(DtoS(dDtExam),1,4) + SubStr(DtoS(dDtExam),5,2)
		
		If !Empty(cMatricula)
			cIdTrab := FGetIdInt("cpfTrab","matricula",cCabec + "ideVinculo/cpfTrab",cCabec + "ideVinculo/matricula",.T.,,@cInconMsg, @nSeqErrGrv,'codCateg',cCabec + "ideVinculo/codCateg")
		Else
			cIdTrab := TAFGetIdFunc( cCpf, cPeriodo, dDtExam, "cpfTrab", cCabec + "ideVinculo/cpfTrab", , , cCodCateg  )
		Endif
		
		aAdd( aChave, { "C", "V3B_FUNC"		, cIdTrab , .T. } )
		aAdd( aChave, { "D", "V3B_DTEXAM"	, dDtExam , .T. } )
		
		//Função para validar se a operação desejada pode ser realizada
		If FTAFVldOpe( "V3B", 5, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA528", cCmpsNoUpd )

			cLogOpeAnt := V3B->V3B_LOGOPE

			//Carrego array com os campos De/Para de gravação das informações
			aRules := TAF528Rul(cLayout, @cInconMsg, @nSeqErrGrv, cCodEvent, cOwner, cIdTrab)

			//Quando se tratar de uma Exclusão Direta, apenas preciso realizar o Commit, não é necessária nenhuma manutenção nas informações
			If nOpc <> 5

				oModel:LoadValue( "MODEL_V3B", "V3B_FILIAL", V3B->V3B_FILIAL )			
				oModel:LoadValue( "MODEL_V3B", "V3B_XMLID", cXmlID )

				//Laço no aRules para gravar as informações
				For nI := 1 to Len( aRules )
					oModel:LoadValue( "MODEL_V3B", aRules[nI,01], FTAFGetVal( aRules[nI,02], aRules[nI,03], aRules[nI,04], @aIncons, .F. ) )
				Next nI

				If nOpc == 3
					TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_V3B', 'V3B_LOGOPE' , '1', '' )
				Elseif nOpc == 4
					TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_V3B', 'V3B_LOGOPE' , '', cLogOpeAnt )
				EndIf

			EndIf		

			If !Empty( cString )
				MakeDir( GetSrvProfString( "rootpath", "" ) + "\profile\" )
				MemoWrite( GetSrvProfString( "rootpath", "" ) + "\profile\" + "logtot-" + StrTran( DToC( Date() ), "/", "" ) + "-" + StrTran( Time(), ":", "" ) + ".txt", cString )
			EndIf
			
		
			If Empty(cInconMsg)
				If TafFormCommit( oModel )
					Aadd(aIncons, "ERRO19")
				Else
					lRet := .T.
				EndIf
			Else
				Aadd(aIncons, cInconMsg)
			EndIf
			
			
			oModel:DeActivate()
		EndIf

	End Transaction

	//Zerando os arrays e os objetos utilizados no processamento
	aSize( aRules, 0 )
	aRules := Nil

	aSize( aChave, 0 )
	aChave := Nil

	oModel := Nil

Return( { lRet, aIncons } )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF520Rul
@type			function
@description	Regras para gravação das informações do Evento S-2221 do eSocial

@param cIdTrab - Id do Trabalhador

@author		Karyna Martins
@since			21/01/2019
@version		1.0
@return			aRull	-	Regras para a gravação das informações
/*/
//---------------------------------------------------------------------
Static Function TAF528Rul(cTagOper, cInconMsg, nSeqErrGrv, cCodEvent, cOwner,cIdTrab)

	Local cCabec		:=	"/eSocial/evtToxic/"
	Local cRecusa		:= ""
	Local aRull			:= {}
	Local aInfComp		:= {}
	Local aIncons		:= {}

	Default cTagOper	:= ""
	Default cInconMsg	:= ""
	Default nSeqErrGrv	:= 0
	Default cCodEvent	:= ""
	Default cOwner		:= ""


	aAdd( aRull, { "V3B_FUNC"	, cIdTrab								, "C", .T. } )
	aAdd( aRull, { "V3B_CPF"	, cCabec + "ideVinculo/cpfTrab"			, "C", .F. } )

	aAdd( aRull, { "V3B_NIS"	, cCabec + "ideVinculo/nisTrab"			, "C", .F. } )
	aAdd( aRull, { "V3B_MATRIC"	, cCabec + "ideVinculo/matricula"		, "C", .F. } )
	aAdd( aRull, { "V3B_CODCAT"	, cCabec + "ideVinculo/codCateg"		, "C", .F. } )

	aAdd( aRull, { "V3B_DTEXAM"	, cCabec + "toxicologico/dtExame"		, "D", .F. } )
	aAdd( aRull, { "V3B_CNPJLA"	, cCabec + "toxicologico/cnpjLab"		, "C", .F. } )
	aAdd( aRull, { "V3B_CODSEX"	, cCabec + "toxicologico/codSeqExame"	, "C", .F. } )

	cRecusa := FTafGetVal( cCabec + "toxicologico/indRecusa","C", .F., aIncons, .F.)

	aAdd( aRull, { "V3B_INDREC"	, IIF(cRecusa=="S","1","2")	, "C", .T. } )

	//Preenchendo array com informações que deverão ser gravadas caso não encontre o médico.
	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/toxicologico/ufCRM"))
		Aadd( aInfComp,{'CM7_NRIUF',FGetIdInt( "uf", "", +;
						cCabec + "/toxicologico/ufCRM",,,,@cInconMsg, @nSeqErrGrv)}) 
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/toxicologico/nmMed"))		
		Aadd( aInfComp,{'CM7_NOME',;
				FTafGetVal( cCabec + "/toxicologico/nmMed",;
				"C", .F., aIncons, .F.)}) 
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabec + "/toxicologico/nrCRM"))		 
		Aadd( aInfComp,{'CM7_NRIOC',;
				FTafGetVal( cCabec + "/toxicologico/nrCRM",;
				"C", .F., aIncons, .F.)}) 
	EndIf

	//Fim do preenchimento do array auxiliar. 	
	aAdd( aRull, { "V3B_CODMED"	, FGetIdInt( "nrOC", "", cCabec + "/toxicologico/nrCRM",,,aInfComp,@cInconMsg, @nSeqErrGrv)	, "C", .T. } ) //Codigo do Medico	

Return( aRull )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF528Xml
@type			function
@description	Função de geração do XML para o Evento S-2221.
@author			Karyna Martins
@since			21/01/2019
@version		1.0

@param
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@return			cXml	-	Estrutura do XML do Layout S-2221
/*/
//---------------------------------------------------------------------
Function TAF528Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

	Local cXml		:=	""
	Local cLayout	:=	"2221"
	Local aMensal	:=	{}
	Local cReg		:= "Toxic"
	Local cCodCat	:= ""
	Local cIdCateg	:= ""
	Local lXmlVLd	:= IIF(FindFunction('TafXmlVLD'),TafXmlVLD('TAF528XML'),.T.)

	Default cAlias	:=	"V3B"
	Default cSeqXml := ""

	DBSelectArea( "V3B" )
	V3B->( DBSetOrder( 1 ) )

	
	C9V->( DBSetOrder( 2 ) )
	If lXmlVLd                                                                                                                             
																																	
		If C9V->( MsSeek( xFilial("C9V") + V3B->V3B_FUNC + "1" ) )	
				cXml := "<ideVinculo>"
				cXml += 	xTafTag( "cpfTrab"	, C9V->C9V_CPF		 	)
				cXml += 	xTafTag( "nisTrab"	, C9V->C9V_NIS 	,,.T.	)
				cXml += 	xTafTag( "matricula"	, C9V->C9V_MATRIC	,,.T.	)
				
				If C9V->C9V_NOMEVE == "S2300"
					cIdCateg := C9V->C9V_CATCI
					If !Empty( cIdCateg )
						cCodCat := Posicione("C87",1,xFilial("C87") + cIdCateg, "C87_CODIGO")
					EndIf
					cXml += 	xTafTag( "codCateg"	, cCodCat	,,.T.	)
				EndIf
				
				cXml += "</ideVinculo>"	
		EndIf

		cXml += "<toxicologico>"
			cXml += 	xTafTag( "dtExame"		, V3B->V3B_DTEXAM 		)
			cXml += 	xTafTag( "cnpjLab"		, V3B->V3B_CNPJLA	,,.T.	)
			cXml += 	xTafTag( "codSeqExame"	, V3B->V3B_CODSEX	,,.T.	)
			
			DBSelectArea("CM7")  
			CM7	->(DBSetOrder(1))
			If CM7->(MsSeek(xFilial('CM7')+V3B->V3B_CODMED))		
				cXml +=	xTafTag("nmMed"		, CM7->CM7_NOME														,,.T.) 
				cXml += 	xTafTag("nrCRM"		, CM7->CM7_NRIOC														,,.T.)  
				cXml +=	xTafTag("ufCRM"		, POSICIONE("C09",3, xFilial("C09")+CM7->CM7_NRIUF ,"C09_UF")	,,.T.)
			EndIf

			If !Empty(V3B->V3B_INDREC)
				cXml += 	xTafTag( "indRecusa"	, IIF(V3B->V3B_INDREC=='1','S','N'))
			EndIf
		cXml += "</toxicologico>"

		//Estrutura do cabeçalho
		cXml := xTafCabXml(cXml,"V3B",cLayout,cReg,aMensal,cSeqXml)

		//Executa a gravação do registro
		If !lJob
			xTafGerXml( cXml, cLayout )
		EndIf
	Endif

Return( cXml )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF528Trg
@type			function
@description	Gatilho para o campo 
@author		Karyna Martins
@since			21/01/2019
@version		1.0
@return		cRet	-	Indica o código de categoria
/*/
//---------------------------------------------------------------------
Function TAF528Trg()

	Local cRet := ""

	C9V->( DbSetOrder( 2 ) )
	If C9V->( MsSeek ( xFilial("C9V") + M->V3B_FUNC + "1") )
		cRet := Posicione("CUP",1,xFilial("CUP") + C9V->(C9V_ID + C9V_VERSAO), "CUP_CODCAT")
	EndIf

Return cRet

//---------------------------------------------------------------------
//---------------------------------------------------------------------
Static Function TAF528Func(cCabec)

	Local cCPF 	:= ""
	Local cMatric	:= ""
	Local cNomeEv	:= ""
	Local cId 		:= ""

	cCPF 		:=	FTAFGetVal( cCabec + "ideVinculo/cpfTrab"		, "C", .F.,, .F. )
	cMatric 	:=	FTAFGetVal( cCabec + "ideVinculo/matricula"	, "C", .F.,, .F. )

	// Se possui matrícula, procura um trabalhador com vínculo(S2200); se não, 
	//	procura um S2300
	cNomeEv := IIF(Empty(cMatric),"S2300","S2200")

	cId := Posicione("C9V",4,xFilial("C9V")+ cCPF  + cNomeEv + "1","C9V_ID") //C9V_FILIAL+C9V_CPF+C9V_NOMEVE+C9V_ATIVO

Return cId

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
	Local oModelV3B  := Nil

	Default oModel   := Nil
	Default nRecno   := 0
	Default lRotExc  := .F.

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		//Posiciona o item
		("V3B")->( DBGoTo( nRecno ) )

		oModelV3B	:= oModel:GetModel( 'MODEL_V3B' )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco a versao anterior do registro para gravacao do rastro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVerAnt   	:= oModelV3B:GetValue( "V3B_VERSAO" )
		cProtocolo	:= oModelV3B:GetValue( "V3B_PROTUL" )
		cEvento	:= oModelV3B:GetValue( "V3B_EVENTO" )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Neste momento eu gravo as informacoes que foram carregadas       ³
		//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
		//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
		//³nao devem ser consideradas neste momento                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nlI := 1 To 1
			For nlY := 1 To Len( oModelV3B:aDataModel[ nlI ] )
				Aadd( aGrava, { oModelV3B:aDataModel[ nlI, nlY, 1 ], oModelV3B:aDataModel[ nlI, nlY, 2 ] } )
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
		FAltRegAnt( 'V3B', '2' )

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
			oModel:LoadValue( 'MODEL_V3B', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
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
		oModel:LoadValue( 'MODEL_V3B', 'V3B_VERSAO', cVersao )
		oModel:LoadValue( 'MODEL_V3B', 'V3B_VERANT', cVerAnt )
		oModel:LoadValue( 'MODEL_V3B', 'V3B_PROTPN', cProtocolo )
		oModel:LoadValue( 'MODEL_V3B', 'V3B_PROTUL', "" )

		/*---------------------------------------------------------
		Tratamento para que caso o Evento Anterior fosse de exclusão
		seta-se o novo evento como uma "nova inclusão", caso contrário o
		evento passar a ser uma alteração
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_V3B", "V3B_EVENTO", "E" )
		oModel:LoadValue( "MODEL_V3B", "V3B_ATIVO" , "1" )

		//Gravo alteração para o Extemporâneo
		If lGoExtemp
			TafGrvExt( oModel, 'MODEL_V3B', 'V3B' )	
		EndIf

		FwFormCommit( oModel )	
		TAFAltStat( 'V3B',"6" )

	End Transaction

Return ( .T. )
