#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA528.CH"
#INCLUDE "TOPCONN.CH"

Static __lLay0205	:= TafLayESoc("02_05_00")

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA528
@type			function
@description	Exame Toxicol�gico do Motorista Profissional - S-2221.
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
	
			cMessage := STR0009 //"Este evento s� pode ser transmitido na vers�o 2.5 e parametro MV_TAFVLES est� configurado com uma vers�o anterior."
			cMessage += Chr( 13 ) + Chr( 10 )	
			cMessage += STR0010 // "Verifique."
			Aviso( STR0011, cMessage, { STR0005 }, 2 ) //##"Aten��o!" ##"Encerrar"
	
		Else

			oBrowse:SetDescription( STR0001 ) //"Exame Toxicol�gico do Motorista Profissional"
			oBrowse:SetAlias( 'V3B' )
			oBrowse:SetMenuDef( "TAFA528" )
			oBrowse:SetFilterDefault(TAFBrwSetFilter("V3B","TAFA258","S-2210"))

			TafLegend(2,"V3B",@oBrowse)
			oBrowse:Activate()

		EndIf	
	
	Else
		cMessage := STR0002 //"Ambiente desatualizado com a vers�o do programa existente no reposit�rio de dados."
		cMessage += Chr( 13 ) + Chr( 10 )
		cMessage += Chr( 13 ) + Chr( 10 )
		cMessage += STR0003 //"Execute a atualiza��o do dicion�rio do Layout 2.5 do eSocial por meio do compatibilizador UPDDISTR."
		Aviso( STR0004, cMessage, { STR0005 }, 2 ) //##"Dicion�rio Incompat�vel" ##"Encerrar"
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@type			function
@description	Fun��o gen�rica MVC do menu.
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

	//Vari�vel Private utilizada para controle do menu na chamada da View na opera��o de Hist�rico de Altera��es
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
@description	Fun��o gen�rica MVC do modelo.
@author		Karyna Martins
@since			21/01/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStruV3B	:=	FWFormStruct( 1, "V3B" )
	Local oModel	:=	MpFormModel():New("TAFA528",,,{|oModel| SaveModel(oModel)})

	//Vari�vel Private utilizada para controle do modelo na opera��o de integra��o via TAFAINTEG
	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruV3B:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
	EndIf

	oStruV3B:SetProperty( 'V3B_INDREC', MODEL_FIELD_OBRIGAT , .T. ) //Conforme o layout 2.5 do eSocial, esse campo � de preenchimento obrigat�rio.
	oStruV3B:SetProperty( "V3B_FUNC"  , MODEL_FIELD_NOUPD   , .T. )

	oModel:AddFields('MODEL_V3B', /*cOwner*/, oStruV3B)
	oModel:GetModel('MODEL_V3B'):SetPrimaryKey({'V3B_FILIAL', 'V3B_FUNC', 'V3B_DTEXAM'})

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@type			function
@description	Fun��o gen�rica MVC da view.
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
	oView:EnableTitleView( 'VIEW_V3Bd',  TafNmFolder("recibo",1) ) // "Recibo da �ltima Transmiss�o"  
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

	oView:AddSheet( "FOLDER_PRINCIPAL", "ABA01", STR0001 ) //"Exame Toxicol�gico do Motorista Profissional"
	oView:CreateHorizontalBox( "V3Ba", 15,,, "FOLDER_PRINCIPAL", "ABA01" )
	oView:CreateHorizontalBox( "V3Bb", 35,,, "FOLDER_PRINCIPAL", "ABA01" )
	oView:CreateHorizontalBox( "V3Bc", 50,,, "FOLDER_PRINCIPAL", "ABA01" )

	oView:AddSheet( "FOLDER_PRINCIPAL", "ABA02", TafNmFolder("recibo",1) ) //"Exame Toxicol�gico do Motorista Profissional"
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
@description	Fun��o de grava��o dos dados, executada na confirma��o do modelo.
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

			//�����������������������������������������������������������������Ŀ
			//�Seek para posicionar no registro antes de realizar as validacoes,�
			//�visto que quando nao esta pocisionado nao eh possivel analisar   �
			//�os campos nao usados como _STATUS                                �
			//�������������������������������������������������������������������
			V3B->( DbSetOrder( 3 ) )
			If V3B->( MsSeek( xFilial( 'V3B' ) + M->V3B_ID + '1' ) )

				//������������������������������������������������Ŀ
				//�Se o registro ja foi transmitido com sucesso    �
				//��������������������������������������������������
				If V3B->V3B_STATUS ==  "4"

					oModelV3B := oModel:GetModel( 'MODEL_V3B' )

					//�����������������������������������������������������������Ŀ
					//�Busco a versao anterior do registro para gravacao do rastro�
					//�������������������������������������������������������������
					cVerAnt    	:= oModelV3B:GetValue( "V3B_VERSAO" )
					cProtocolo 	:= oModelV3B:GetValue( "V3B_PROTUL" )
					cEvento		:= oModelV3B:GetValue( "V3B_EVENTO" )
					cLogOpeAnt  := oModelV3B:GetValue( "V3B_LOGOPE" )

					//�����������������������������������������������������������������Ŀ
					//�Neste momento eu gravo as informacoes que foram carregadas       �
					//�na tela, pois neste momento o usuario ja fez as modificacoes que �
					//�precisava e as mesmas estao armazenadas em memoria, ou seja,     �
					//�nao devem ser consideradas neste momento                         �
					//�������������������������������������������������������������������
					For nlI := 1 to Len( oModelV3B:aDataModel[ 1 ] )
						Aadd( aGrava, { oModelV3B:aDataModel[ 1, nlI, 1 ], oModelV3B:aDataModel[ 1, nlI, 2 ] } )
					Next nlI

					//�����������������������������������������������������������Ŀ
					//�Seto o campo como Inativo e gravo a versao do novo registro�
					//�no registro anterior                                       �
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//�������������������������������������������������������������
					FAltRegAnt( 'V3B', '2' )	

					//��������������������������������������������������Ŀ
					//�Neste momento eu preciso setar a operacao do model�
					//�como Inclusao                                     �
					//����������������������������������������������������
					oModel:DeActivate()
					oModel:SetOperation( 3 )
					oModel:Activate()

					//�������������������������������������������������������Ŀ
					//�Neste momento eu realizo a inclusao do novo registro ja�
					//�contemplando as informacoes alteradas pelo usuario     �
					//���������������������������������������������������������
					For nlI := 1 To Len( aGrava )
						oModel:LoadValue( 'MODEL_V3B', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
					Next

					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_V3B', 'V3B_LOGOPE' , '' , cLogOpeAnt )

					//�������������������������������Ŀ
					//�Busco a versao que sera gravada�
					//���������������������������������
					cVersao := xFunGetVer()

					//�����������������������������������������������������������Ŀ
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//�������������������������������������������������������������
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
					TAFMsgVldOp(oModel,"2")//"Registro n�o pode ser alterado. Aguardando processo da transmiss�o."
					lRetorno:= .F.
				ElseIf V3B->V3B_STATUS == "6"
					TAFMsgVldOp(oModel,"6")//"Registro n�o pode ser alterado. Aguardando proc. Transm. evento de Exclus�o S-3000"
					lRetorno:= .F.
				ElseIf V3B->V3B_STATUS == "7"
					TAFMsgVldOp(oModel,"7") //"Registro n�o pode ser alterado, pois o evento j� se encontra na base do RET"
					lRetorno:= .F.
				Else
		
					cLogOpeAnt := V3B->V3B_LOGOPE
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_V3B', 'V3B_LOGOPE' , '' , cLogOpeAnt )

					FwFormCommit( oModel )
					TAFAltStat( 'V3B', " " )
				EndIf
			EndIf

		//Exclus�o Manual do Evento
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
@description	Fun��o de integra��o dos dados para o evento S-2221.
@author		Karyna Martins
@since			21/01/2019
@version		1.0
@param			cLayout	-	Nome do Layout que est� sendo importado
@param			nOpc	-	Opera��o a ser executada ( 3 = Inclus�o, 4 = Altera��o, 5 = Exclus�o )
@param			cFilEv	-	Filial do ERP para onde as informa��es devem ser importadas
@param			oXML	-	Objeto com o XML padronizado a ser importado
@return		lRet	-	Vari�vel que indica se a importa��o foi realizada
@return		aIncons	-	Array com as inconsist�ncias encontradas durante a importa��o
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

	Private lVldModel	:=	.T. //Caso a chamada seja via integra��o, seto a vari�vel de controle de valida��o como .T.
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
		cString := STR0002 //"Ambiente desatualizado com a vers�o do programa existente no reposit�rio de dados."
		cString += Chr( 13 ) + Chr( 10 )
		cString += Chr( 13 ) + Chr( 10 )
		cString += STR0003 //"Execute a atualiza��o do dicion�rio do Layout 2.5 do eSocial por meio do compatibilizador UPDDISTR."

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
		
		//Fun��o para validar se a opera��o desejada pode ser realizada
		If FTAFVldOpe( "V3B", 5, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA528", cCmpsNoUpd )

			cLogOpeAnt := V3B->V3B_LOGOPE

			//Carrego array com os campos De/Para de grava��o das informa��es
			aRules := TAF528Rul(cLayout, @cInconMsg, @nSeqErrGrv, cCodEvent, cOwner, cIdTrab)

			//Quando se tratar de uma Exclus�o Direta, apenas preciso realizar o Commit, n�o � necess�ria nenhuma manuten��o nas informa��es
			If nOpc <> 5

				oModel:LoadValue( "MODEL_V3B", "V3B_FILIAL", V3B->V3B_FILIAL )			
				oModel:LoadValue( "MODEL_V3B", "V3B_XMLID", cXmlID )

				//La�o no aRules para gravar as informa��es
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
@description	Regras para grava��o das informa��es do Evento S-2221 do eSocial

@param cIdTrab - Id do Trabalhador

@author		Karyna Martins
@since			21/01/2019
@version		1.0
@return			aRull	-	Regras para a grava��o das informa��es
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

	//Preenchendo array com informa��es que dever�o ser gravadas caso n�o encontre o m�dico.
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
@description	Fun��o de gera��o do XML para o Evento S-2221.
@author			Karyna Martins
@since			21/01/2019
@version		1.0

@param
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composi��o da chave ID do XML

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

		//Estrutura do cabe�alho
		cXml := xTafCabXml(cXml,"V3B",cLayout,cReg,aMensal,cSeqXml)

		//Executa a grava��o do registro
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
@return		cRet	-	Indica o c�digo de categoria
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

	// Se possui matr�cula, procura um trabalhador com v�nculo(S2200); se n�o, 
	//	procura um S2300
	cNomeEv := IIF(Empty(cMatric),"S2300","S2200")

	cId := Posicione("C9V",4,xFilial("C9V")+ cCPF  + cNomeEv + "1","C9V_ID") //C9V_FILIAL+C9V_CPF+C9V_NOMEVE+C9V_ATIVO

Return cId

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclus�o do evento (S-3000)

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function � chamada pelo TafIntegraESocial

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

	//Controle se o evento � extempor�neo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		//Posiciona o item
		("V3B")->( DBGoTo( nRecno ) )

		oModelV3B	:= oModel:GetModel( 'MODEL_V3B' )

		//�����������������������������������������������������������Ŀ
		//�Busco a versao anterior do registro para gravacao do rastro�
		//�������������������������������������������������������������
		cVerAnt   	:= oModelV3B:GetValue( "V3B_VERSAO" )
		cProtocolo	:= oModelV3B:GetValue( "V3B_PROTUL" )
		cEvento	:= oModelV3B:GetValue( "V3B_EVENTO" )

		//�����������������������������������������������������������������Ŀ
		//�Neste momento eu gravo as informacoes que foram carregadas       �
		//�na tela, pois neste momento o usuario ja fez as modificacoes que �
		//�precisava e as mesmas estao armazenadas em memoria, ou seja,     �
		//�nao devem ser consideradas neste momento                         �
		//�������������������������������������������������������������������
		For nlI := 1 To 1
			For nlY := 1 To Len( oModelV3B:aDataModel[ nlI ] )
				Aadd( aGrava, { oModelV3B:aDataModel[ nlI, nlY, 1 ], oModelV3B:aDataModel[ nlI, nlY, 2 ] } )
			Next
		Next

		//�����������������������������������������������������������Ŀ
		//�Seto o campo como Inativo e gravo a versao do novo registro�
		//�no registro anterior                                       �
		//|                                                           |
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//�������������������������������������������������������������
		FAltRegAnt( 'V3B', '2' )

		//��������������������������������������������������Ŀ
		//�Neste momento eu preciso setar a operacao do model�
		//�como Inclusao                                     �
		//����������������������������������������������������
		oModel:DeActivate()
		oModel:SetOperation( 3 )
		oModel:Activate()

		//�������������������������������������������������������Ŀ
		//�Neste momento eu realizo a inclusao do novo registro ja�
		//�contemplando as informacoes alteradas pelo usuario     �
		//���������������������������������������������������������
		For nlI := 1 To Len( aGrava )
			oModel:LoadValue( 'MODEL_V3B', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
		Next

		//�������������������������������Ŀ
		//�Busco a versao que sera gravada�
		//���������������������������������
		cVersao := xFunGetVer()

		//�����������������������������������������������������������Ŀ
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//�������������������������������������������������������������
		oModel:LoadValue( 'MODEL_V3B', 'V3B_VERSAO', cVersao )
		oModel:LoadValue( 'MODEL_V3B', 'V3B_VERANT', cVerAnt )
		oModel:LoadValue( 'MODEL_V3B', 'V3B_PROTPN', cProtocolo )
		oModel:LoadValue( 'MODEL_V3B', 'V3B_PROTUL', "" )

		/*---------------------------------------------------------
		Tratamento para que caso o Evento Anterior fosse de exclus�o
		seta-se o novo evento como uma "nova inclus�o", caso contr�rio o
		evento passar a ser uma altera��o
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_V3B", "V3B_EVENTO", "E" )
		oModel:LoadValue( "MODEL_V3B", "V3B_ATIVO" , "1" )

		//Gravo altera��o para o Extempor�neo
		If lGoExtemp
			TafGrvExt( oModel, 'MODEL_V3B', 'V3B' )	
		EndIf

		FwFormCommit( oModel )	
		TAFAltStat( 'V3B',"6" )

	End Transaction

Return ( .T. )
