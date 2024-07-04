#include "TAFA272.CH"
#include "PROTHEUS.CH"
#include "FWMVCDEF.CH"

//A quantidade de Produtores Rurais foi limitada, pois apesar do layout do governo apontar que podem ser enviados 9999 Produtores, o RET retorna erro ao enviar mais de 4500 produtores rurais.
#DEFINE  QTDMAX_PRODRURAIS 14999  

Static __lLay0205	:= TafLayESoc("02_05_00")
Static __lV2O		:= TAFAlsInDic("V2O")

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA272
Cadastro de Outras Informacoes - Aquisicao de Producao

@author Daniel Magalhaes
@since 15/10/2013
@version MP11.8, MP12
/*/
//-------------------------------------------------------------------
Function TAFA272()

	Private oBrw := FWmBrowse():New()

	If FindFunction("TAFDesEven")
		TAFDesEven()
	EndIf

	oBrw:SetDescription(STR0001) //"Outras Informa��es - Aquisi��o de Produ��o"
	oBrw:SetAlias( "CMR" )
	oBrw:SetCacheView(.F.) // Faz com que sempre passe pelo viewdef;
	oBrw:SetMenuDef( "TAFA272" )
	oBrw:SetFilterDefault( "CMR_ATIVO == '1' .Or. (CMR_EVENTO == 'E' .And. CMR_ATIVO == '2')" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )
	oBrw:SetChgAll(.F.)

	TafLegend(2,"CMR",@oBrw) //Trata as Legendas de Inclus�o - Altera��o - Exclus�o

	oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Daniel Magalhaes
@since 15/10/2013
@version MP11.8, MP12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao
	Local aRotina

	aFuncao := {}
	aRotina := {}

	Aadd( aFuncao, { "" , "TafxmlRet('TAF272Xml','1250','CMR')" 							, "1" } )
	Aadd( aFuncao, { "" , "xFunAltRec( 'CMR' )" 											, "10"} )
	Aadd( aFuncao, { "" , "xNewHisAlt( 'CMR', 'TAFA272' ,,,,,,'1250','TAF272Xml'  )" 		, "3" } ) //Chamo a Browse do Hist�rico
	Aadd( aFuncao, { "" , "TAFXmlLote( 'CMR', 'S-1250' , 'evtAqProd' , 'TAF272Xml',, oBrw )", "5" } )

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If lMenuDif .Or. ViewEvent('S-1250')

		ADD OPTION aRotina Title STR0010 Action 'VIEWDEF.TAFA272' OPERATION 2 ACCESS 0 //"Visualizar"

		If !ViewEvent('S-1250')
			aRotina	:= xMnuExtmp( "TAFA272", "CMR", .F. ) // Menu dos extempor�neos
		EndIf
		
	Else
		aRotina	:=	xFunMnuTAF( "TAFA272" , , aFuncao)
	EndIf

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel, Objeto do Modelo MVC

@author Daniel Magalhaes
@since 15/10/2013
@version MP11.8, MP12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruCMR  := FWFormStruct( 1, 'CMR' )
	Local oStruCMT  := FWFormStruct( 1, 'CMT' )
	Local oStruCMU  := FWFormStruct( 1, 'CMU' )
	Local oStruT1Z  := FWFormStruct( 1, 'T1Z' )
	Local oStruCMV  := Nil
	Local oStruV2O  := Nil

	Local oModel
	local lHabilita := SUPERGETMV("MV_TAFCNPJ", .F., .F.)

	oModel := MPFormModel():New( 'TAFA272' ,,,{|oModel| SaveModel(oModel)})

	If __lLay0205 .And. __lV2O
		oStruV2O := FWFormStruct( 1, 'V2O' )
	Else
		oStruCMV := FWFormStruct( 1, 'CMV' )
	EndIf

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruCMR:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruCMT:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruCMU:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })	
		oStruT1Z:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		If __lLay0205 .And. __lV2O
			oStruV2O:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		Else
			oStruCMV:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		EndIf
	EndIf

	//Remo��o do GetSX8Num quando se tratar da Exclus�o de um Evento Transmitido.
	//Necess�rio para n�o incrementar ID que n�o ser� utilizado.
	If Upper( ProcName( 2 ) ) == Upper( "GerarExclusao" )
		oStruCMR:SetProperty( "CMR_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )
	EndIf

	//Modelo de indicador de apuracao
	oModel:AddFields('MODEL_CMR', /*cOwner*/, oStruCMR)
	oModel:GetModel('MODEL_CMR'):SetPrimaryKey({'CMR_FILIAL', 'CMR_ID', 'CMR_VERSAO'})

	//-- Inicializa o campo de acordo com a C1E
	oStruCMR:SetProperty( 'CMR_TPINSC' , MODEL_FIELD_INIT ,{| oModel | XGetTPInsc() })										   
	oStruCMR:SetProperty( 'CMR_INSCES' , MODEL_FIELD_INIT ,{| oModel | XGetInsc() 	})

	If !lHabilita
		
		//-- desabilita os campos abaixo
		oStruCMR:SetProperty( "CMR_TPINSC",MODEL_FIELD_WHEN,{|| .F. })
		oStruCMR:SetProperty( "CMR_INSCES",MODEL_FIELD_WHEN,{|| .F. })															

		oStruCMR:SetProperty( "CMR_INSCES"   , MVC_VIEW_ORDEM    , "17"  )
		oStruCMR:SetProperty( "CMR_TPINSC"   , MVC_VIEW_ORDEM    , "18"  )
		
	EndIf
	//Modelo de Tipo de Aquisicao
	oModel:AddGrid('MODEL_CMT', 'MODEL_CMR', oStruCMT)
	oModel:GetModel('MODEL_CMT'):SetOptional(.T.)
	oModel:GetModel('MODEL_CMT'):SetUniqueLine({'CMT_INDAQU'})
	oModel:GetModel('MODEL_CMT'):SetMaxLine(6)

	//Modelo de Id Produtor
	oModel:AddGrid('MODEL_CMU', 'MODEL_CMT', oStruCMU)
	oModel:GetModel('MODEL_CMU'):SetOptional(.T.)
	oModel:GetModel('MODEL_CMU'):SetUniqueLine({'CMU_INSCPR'})
	oModel:GetModel('MODEL_CMU'):SetMaxLine(9999)


	//Modelo de Processo Judicial de Produtor
	oModel:AddGrid('MODEL_T1Z', 'MODEL_CMU', oStruT1Z)
	oModel:GetModel('MODEL_T1Z'):SetOptional(.T.)
	oModel:GetModel('MODEL_T1Z'):SetUniqueLine({'T1Z_IDPROC'})
	oModel:GetModel('MODEL_T1Z'):SetMaxLine(9999)

	If __lLay0205 .And. __lV2O
		//Modelo de Processo Judicial de Aquisi��o
		oModel:AddGrid('MODEL_V2O', 'MODEL_CMT', oStruV2O)
		oModel:GetModel('MODEL_V2O'):SetOptional(.T.)
		oModel:GetModel('MODEL_V2O'):SetUniqueLine({'V2O_IDPROC'})
		oModel:GetModel('MODEL_V2O'):SetMaxLine(9999)
	Else
		//Modelo de Notas fiscais
		oModel:AddGrid('MODEL_CMV', 'MODEL_CMU', oStruCMV)
		oModel:GetModel('MODEL_CMV'):SetOptional(.T.)
		oModel:GetModel('MODEL_CMV'):SetUniqueLine({'CMV_SERIE', 'CMV_NUMDOC'})
		oModel:GetModel('MODEL_CMV'):SetMaxLine(9999)
	EndIf

	oModel:SetRelation('MODEL_CMT', {{'CMT_FILIAL' , 'xFilial( "CMT" )'}, {'CMT_ID' , 'CMR_ID'}, {'CMT_VERSAO' , 'CMR_VERSAO'}}, CMT->(IndexKey(1)))
	oModel:SetRelation('MODEL_CMU', {{'CMU_FILIAL' , 'xFilial( "CMU" )'}, {'CMU_ID' , 'CMR_ID'}, {'CMU_VERSAO' , 'CMR_VERSAO'}, {'CMU_INDAQU' , 'CMT_INDAQU'}}, CMU->(IndexKey(1)))
	oModel:SetRelation('MODEL_T1Z', {{'T1Z_FILIAL' , 'xFilial( "T1Z" )'}, {'T1Z_ID' , 'CMR_ID'}, {'T1Z_VERSAO' , 'CMR_VERSAO'}, {'T1Z_INDAQU' , 'CMT_INDAQU'}, {'T1Z_INSCPR' , 'CMU_INSCPR'}}, T1Z->(IndexKey(1)))

	If __lLay0205 .And. __lV2O
		oModel:SetRelation('MODEL_V2O', {{'V2O_FILIAL' , 'xFilial( "V2O" )'}, {'V2O_ID' , 'CMR_ID'}, {'V2O_VERSAO' , 'CMR_VERSAO'}, {'V2O_INDAQU' , 'CMT_INDAQU'}}, V2O->(IndexKey(1)))
	Else
		oModel:SetRelation('MODEL_CMV', {{'CMV_FILIAL' , 'xFilial( "CMV" )'}, {'CMV_ID' , 'CMR_ID'}, {'CMV_VERSAO' , 'CMR_VERSAO'}, {'CMV_INDAQU' , 'CMT_INDAQU'}, {'CMV_INSCPR' , 'CMU_INSCPR'}}, CMV->(IndexKey(1)))
	EndIf

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView, Objeto da View MVC

@author Daniel Magalhaes
@since 15/10/2013
@version MP11.8, MP12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel    := FWLoadModel( 'TAFA272' )
	Local oStruCMRa := Nil
	Local oStruCMRb := Nil
	Local oStruCMRc	:= Nil
	Local oStruCMT  := FWFormStruct( 2, 'CMT' )
	Local oStruCMU  := FWFormStruct( 2, 'CMU' )
	Local oStruCMV  := Nil
	Local oStruT1Z  := FWFormStruct( 2, 'T1Z' )
	Local oStruV2O  := Nil
	Local oView     := FWFormView():New()
	Local cCmpFil   := ''
	Local nI        := 0
	Local aCmpGrp   := {}
	Local cGrpCom1  := ""
	Local cGrpCom2  := ""

	oView:SetModel( oModel )
	oView:SetContinuousForm(.T.)

	//Informa��es de Apura��o
	cGrpCom1  := 'CMR_ID|CMR_VERSAO|CMR_VERANT|CMR_PROTPN|CMR_EVENTO|CMR_ATIVO|CMR_INDAPU|CMR_PERAPU|CMR_TPINSC|CMR_INSCES|'
	cCmpFil   := cGrpCom1
	oStruCMRa := FwFormStruct( 2, 'CMR', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	//"Protocolo de Transmiss�o"
	cGrpCom2 := 'CMR_PROTUL|'
	cCmpFil   := cGrpCom2
	oStruCMRb := FwFormStruct( 2, 'CMR', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	If TafColumnPos("CMR_DTRANS")
		cCmpFil := "CMR_DINSIS|CMR_DTRANS|CMR_HTRANS|CMR_DTRECP|CMR_HRRECP|"
		oStruCMRc := FwFormStruct( 2, 'CMR', {|x| AllTrim( x ) + "|" $ cCmpFil } )
	EndIf
															
	//Processo Judicial de Aquisi��o
	If __lLay0205 .And. __lV2O
		oStruV2O  := FWFormStruct( 2, 'V2O' )
	Else 
		oStruCMV  := FWFormStruct( 2, 'CMV' )
	EndIf

	/*-----------------------------------------------------------------------------------
					Grupo de campos da Aquisi��o de Produ��o Rural
	-------------------------------------------------------------------------------------*/
	oStruCMRa:AddGroup( "GRP_AQUISICAO", STR0002, "", 1 ) //Informa��es de Apura��o

	aCmpGrp := StrToKArr(cGrpCom1,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruCMRa:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_AQUISICAO")
	Next nI

	/*--------------------------------------------------------------------------------------------
										Esrutura da View
	---------------------------------------------------------------------------------------------*/
	oView:AddField( 'VIEW_CMRa', oStruCMRa, 'MODEL_CMR' )
	oView:AddField( 'VIEW_CMRb', oStruCMRb, 'MODEL_CMR' )

	oView:AddGrid(  'VIEW_CMT', oStruCMT, 'MODEL_CMT' )
	oView:EnableTitleView( 'VIEW_CMT', STR0004 ) //"Tipo de Aquisi��o"

	oView:AddGrid(  'VIEW_CMU', oStruCMU, 'MODEL_CMU' )
	oView:EnableTitleView( 'VIEW_CMU', STR0005 ) //"Produtor"

	oView:AddGrid(  'VIEW_T1Z', oStruT1Z, 'MODEL_T1Z' )
	oView:EnableTitleView( 'VIEW_T1Z', STR0019 ) //"Processo Judicial"

	If __lLay0205 .And. __lV2O
		oView:AddGrid(  'VIEW_V2O', oStruV2O, 'MODEL_V2O' )
		oView:EnableTitleView( 'VIEW_V2O', STR0019 ) //"Processo Judicial de Aquisi��o"
	Else
		oView:AddGrid(  'VIEW_CMV', oStruCMV, 'MODEL_CMV' )
		oView:EnableTitleView( 'VIEW_CMV', STR0006 ) //"Notas Fiscais"
	EndIf

	If TafColumnPos("CMR_PROTUL")
		oView:EnableTitleView('VIEW_CMRb',TafNmFolder("recibo",1)) // "Recibo da �ltima Transmiss�o"
	EndIf
	If TafColumnPos("CMR_DTRANS")
		oView:AddField( 'VIEW_CMRc', oStruCMRc, 'MODEL_CMR' )
		oView:EnableTitleView('VIEW_CMRc',TafNmFolder("recibo",2))
	EndIf

	/*-----------------------------------------------------------------------------------
									Estrutura do Folder
	-------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox("PAINEL_SUPERIOR",100)
	oView:CreateFolder("FOLDER_SUPERIOR","PAINEL_SUPERIOR")

	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0002 )   //"Informa��o de Aquisi��o de Produ��o Rural"
	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0021 )   //"Protocolo de Transmiss�o"

	If __lLay0205 .And. __lV2O	
		
		oView:CreateHorizontalBox( 'CMRa',  010,,, 'FOLDER_SUPERIOR', 'ABA01' )
		oView:CreateHorizontalBox( 'CMT' ,  030,,, 'FOLDER_SUPERIOR', 'ABA01' )	
		If TafColumnPos("CMR_DTRANS")
			oView:CreateHorizontalBox( 'CMRb',  20,,, 'FOLDER_SUPERIOR', 'ABA02' )
			oView:CreateHorizontalBox( 'CMRc',  80,,, 'FOLDER_SUPERIOR', 'ABA02' )
		Else
			oView:CreateHorizontalBox( 'CMRb',  100,,, 'FOLDER_SUPERIOR', 'ABA02' )
		EndIf
		
		oView:CreateHorizontalBox("PAINEL_INFOPROD",060,,,"FOLDER_SUPERIOR","ABA01")
		oView:CreateFolder( 'FOLDER_INFOPROD', 'PAINEL_INFOPROD' )
		oView:AddSheet( 'FOLDER_INFOPROD', 'ABA01', STR0027 ) //"Informa��o de Aquisi��o"
		oView:AddSheet( 'FOLDER_INFOPROD', 'ABA02', STR0026 ) //"Informa��es de Produtores"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         

		oView:CreateHorizontalBox ( 'V2O', 100,,, 'FOLDER_INFOPROD'  , 'ABA01' )
		oView:CreateHorizontalBox ( 'CMU', 050,,, 'FOLDER_INFOPROD'  , 'ABA02' )
		oView:CreateHorizontalBox ( 'T1Z', 050,,, 'FOLDER_INFOPROD'  , 'ABA02' )
		
	Else

		oView:CreateHorizontalBox( 'CMRa',  015,,, 'FOLDER_SUPERIOR', 'ABA01' )
		oView:CreateHorizontalBox( 'CMT' ,  025,,, 'FOLDER_SUPERIOR', 'ABA01' )
		oView:CreateHorizontalBox( 'CMU' ,  030,,, 'FOLDER_SUPERIOR', 'ABA01' )

		If TafColumnPos("CMR_DTRANS")
			oView:CreateHorizontalBox( 'CMRb',  20,,, 'FOLDER_SUPERIOR', 'ABA02' )
			oView:CreateHorizontalBox( 'CMRc',  80,,, 'FOLDER_SUPERIOR', 'ABA02' )
		Else
			oView:CreateHorizontalBox( 'CMRb',  100,,, 'FOLDER_SUPERIOR', 'ABA02' )
		EndIf
		
		oView:CreateHorizontalBox("PAINEL_INFOPROD",30,,,"FOLDER_SUPERIOR","ABA01")
		oView:CreateFolder( 'FOLDER_INFOPROD', 'PAINEL_INFOPROD' )
		oView:AddSheet( 'FOLDER_INFOPROD', 'ABA01', STR0006 ) //"Notas Fiscais"
		oView:AddSheet( 'FOLDER_INFOPROD', 'ABA02', STR0019 ) //"Processo Judicial"

		oView:CreateHorizontalBox ( 'CMV', 100,,, 'FOLDER_INFOPROD'  , 'ABA01' )
		oView:CreateHorizontalBox ( 'T1Z', 100,,, 'FOLDER_INFOPROD'  , 'ABA02' )
		
	EndIf

	oView:SetOwnerView( "VIEW_CMRa", "CMRa")
	oView:SetOwnerView( "VIEW_CMRb", "CMRb")
	If TafColumnPos("CMR_DTRANS")
		oView:SetOwnerView( "VIEW_CMRc", "CMRc")
	EndIf
	oView:SetOwnerView( "VIEW_CMT",  "CMT" )
	oView:SetOwnerView( 'VIEW_CMU' , "CMU" )
	oView:SetOwnerView( "VIEW_T1Z",  "T1Z" )

	If __lLay0205 .And. __lV2O
		oView:SetOwnerView( "VIEW_V2O",  "V2O" )
	Else
		oView:SetOwnerView( "VIEW_CMV",  "CMV" )
	EndIf

	//Processar Dados Automaticamente
	If !FindFunction("ImpDataNF")
		oView:AddUserButton( STR0025, 'CLIPS', {|oView| ImportDataNF(oModel) } ) //"Buscar Docs Fiscais"  
	EndIf

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If !lMenuDif .OR. ( FindFunction( "xTafExtmp" ) .And. xTafExtmp() )
		xFunRmFStr(@oStruCMRa, 'CMR')
		oStruT1Z:RemoveField('T1Z_IDSUSP')
		If	__lLay0205 .And. __lV2O
			oStruV2O:RemoveField('V2O_IDSUSP')
		EndIf	
	EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel, object, Modelo de dados
@return logic, Sempre .T.

@author Daniel Magalhaes
@since 15/10/2013
@version MP11.8, MP12
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

	Local cVerAnt    := ""
	Local cProtocolo := ""
	Local cVersao    := ""
	Local cEvento    := ""
	Local cChvRegAnt := ""
	Local cId        := ""
	Local cLogOpeAnt := ""
	Local nOperation := oModel:GetOperation()
	Local nlI        := 0
	Local nlY        := 0
	Local nCMT       := 0
	Local nCMU       := 0
	Local nCMUAdd    := 0
	Local nCMV       := 0
	Local nCMVAdd    := 0
	Local nT1Z       := 0
	Local nT1ZAdd    := 0
	Local nV2O       := 0
	Local nV2OAdd    := 0
	Local aGravaCMR  := {}
	Local aGravaCMT  := {}
	Local aGravaCMU  := {}
	Local aGravaCMV  := {}
	Local aGravaT1Z  := {}
	Local aGravaV2O  := {}
	Local oModelCMR  := Nil
	Local oModelCMT  := Nil
	Local oModelCMU  := Nil
	Local oModelCMV  := Nil
	Local oModelT1Z  := Nil
	Local oModelV2O  := Nil
	Local lRetorno   := .T.

	Begin Transaction

		//Inclusao Manual do Evento
		If nOperation == MODEL_OPERATION_INSERT
			
			TafAjustID(�"CMR", oModel)
			
			oModel:LoadValue( 'MODEL_CMR', 'CMR_VERSAO', xFunGetVer() )

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_CMR', 'CMR_LOGOPE' , '2', '' )
			Endif

			FwFormCommit( oModel )

		//Altera��o Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_UPDATE

			//�����������������������������������������������������������������Ŀ
			//�Seek para posicionar no registro antes de realizar as validacoes,�
			//�visto que quando nao esta pocisionado nao eh possivel analisar   �
			//�os campos nao usados como _STATUS                                �
			//�������������������������������������������������������������������
			CMR->( DbSetOrder( 3 ) )
			cId := oModel:GetValue('MODEL_CMR', "CMR_ID")
			If CMR->( MsSeek( xFilial( 'CMR' ) + cId + '1' ) )

				//��������������������������������Ŀ
				//�Se o registro ja foi transmitido�
				//����������������������������������
				If CMR->CMR_STATUS $ ( "4" )

					oModelCMR := oModel:GetModel( 'MODEL_CMR' )
					oModelCMT := oModel:GetModel( 'MODEL_CMT' )
					oModelCMU := oModel:GetModel( 'MODEL_CMU' )				
					oModelT1Z := oModel:GetModel( 'MODEL_T1Z' )
					If __lLay0205 .And. __lV2O
						oModelV2O := oModel:GetModel( 'MODEL_V2O' )
					Else
						oModelCMV := oModel:GetModel( 'MODEL_CMV' )
					EndIf
					//�����������������������������������������������������������Ŀ
					//�Busco a versao anterior do registro para gravacao do rastro�
					//�������������������������������������������������������������
					cVerAnt    := oModelCMR:GetValue( "CMR_VERSAO" )
					cProtocolo := oModelCMR:GetValue( "CMR_PROTUL" )
					cEvento    := oModelCMR:GetValue( "CMR_EVENTO" )

					If TafColumnPos( "CMR_LOGOPE" )
						cLogOpeAnt := oModelCMR:GetValue( "CMR_LOGOPE" )
					Endif

					//�����������������������������������������������������������������Ŀ
					//�Neste momento eu gravo as informacoes que foram carregadas       �
					//�na tela, pois neste momento o usuario ja fez as modificacoes que �
					//�precisava e as mesmas estao armazenadas em memoria, ou seja,     �
					//�nao devem ser consideradas neste momento                         �
					//�������������������������������������������������������������������
					For nlI := 1 To 1
						For nlY := 1 To Len( oModelCMR:aDataModel[ nlI ] )
							Aadd( aGravaCMR, { oModelCMR:aDataModel[ nlI, nlY, 1 ], oModelCMR:aDataModel[ nlI, nlY, 2 ] } )
						Next
					Next

					For nCMT := 1 To oModel:GetModel( 'MODEL_CMT' ):Length()
						oModel:GetModel( 'MODEL_CMT' ):GoLine(nCMT)

						If !oModel:GetModel( 'MODEL_CMT' ):IsDeleted()
								aAdd (aGravaCMT ,{oModelCMT:GetValue("CMT_INDAQU"),;
												oModelCMT:GetValue("CMT_VLAQUI")} )

							For nCMU := 1 To oModel:GetModel( 'MODEL_CMU' ):Length()
								oModel:GetModel( 'MODEL_CMU' ):GoLine(nCMU)

								If !oModel:GetModel( 'MODEL_CMU' ):IsDeleted()
										aAdd (aGravaCMU ,{oModelCMT:GetValue("CMT_INDAQU"),;
														oModelCMU:GetValue("CMU_TPINSC"),;
														oModelCMU:GetValue("CMU_INSCPR"),;
														oModelCMU:GetValue("CMU_VLBRUT"),;
														oModelCMU:GetValue("CMU_VLCONT"),;
														oModelCMU:GetValue("CMU_VLGILR"),;
														oModelCMU:GetValue("CMU_VLSENA")} )
										If __lLay0205 .And. TafColumnPos("CMU_INDCP")
											aAdd(aGravaCMU[Len(aGravaCMU)] ,oModelCMU:GetValue("CMU_INDCP"))
										EndIf
									
									If !__lLay0205
										If !oModel:GetModel( 'MODEL_CMV' ):IsEmpty()
											For nCMV := 1 To oModel:GetModel( 'MODEL_CMV' ):Length()
												oModel:GetModel( 'MODEL_CMV' ):GoLine(nCMV)
			
												If !oModel:GetModel( 'MODEL_CMV' ):IsDeleted()
													aAdd (aGravaCMV ,{oModelCMT:GetValue("CMT_INDAQU"),;
																	oModelCMU:GetValue("CMU_INSCPR"),;
																	oModelCMV:GetValue("CMV_SERIE"),;
																	oModelCMV:GetValue("CMV_NUMDOC"),;
																	oModelCMV:GetValue("CMV_DTEMIS"),;
																	oModelCMV:GetValue("CMV_VLBRUT"),;
																	oModelCMV:GetValue("CMV_VLCONT"),;
																	oModelCMV:GetValue("CMV_VLGILR"),;
																	oModelCMV:GetValue("CMV_VLSENA")} )
												EndIf
			
											Next // Fim - CMV
										EndIf
									EndIf
									
									If !oModel:GetModel( 'MODEL_T1Z' ):IsEmpty()
										
										//Grava T1Z
										For nT1Z := 1 To oModel:GetModel( 'MODEL_T1Z' ):Length()
											oModel:GetModel( 'MODEL_T1Z' ):Goline(nT1Z)

											If !oModel:GetModel( 'MODEL_T1Z' ):IsDeleted()
											aAdd (aGravaT1Z ,{	oModelCMT:GetValue("CMT_INDAQU"),;
																oModelCMU:GetValue("CMU_INSCPR"),;
																oModelT1Z:GetValue("T1Z_IDPROC"),;
																oModelT1Z:GetValue("T1Z_CODSUS"),;
																oModelT1Z:GetValue("T1Z_VLRPRV"),;
																oModelT1Z:GetValue("T1Z_VLRRAT"),;
																oModelT1Z:GetValue("T1Z_VLRSEN")} )
											EndIf

										Next // Fim - T1Z
									EndIf
								EndIf
							Next // Fim - CMU
							
							If __lLay0205 .And. __lV2O
								//Grava V2O
								If !oModel:GetModel( 'MODEL_V2O' ):IsEmpty()
									For nV2O := 1 To oModel:GetModel( 'MODEL_V2O' ):Length()
										oModel:GetModel( 'MODEL_V2O' ):Goline(nV2O)
										If !oModel:GetModel( 'MODEL_V2O' ):IsDeleted()
											aAdd (aGravaV2O ,{	oModelCMT:GetValue("CMT_INDAQU"),;
																oModelV2O:GetValue("V2O_INSCPR"),;
																oModelV2O:GetValue("V2O_IDPROC"),;
																oModelV2O:GetValue("V2O_CODSUS"),;
																oModelV2O:GetValue("V2O_VLRPRV"),;
																oModelV2O:GetValue("V2O_VLRRAT"),;
																oModelV2O:GetValue("V2O_VLRSEN")} )
										EndIf						
									Next // Fim - V2O
								EndIf
							EndIf
						EndIf
					Next // Fim - CMT


					//�����������������������������������������������������������Ŀ
					//�Seto o campo como Inativo e gravo a versao do novo registro�
					//�no registro anterior                                       �
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//�������������������������������������������������������������
					FAltRegAnt( 'CMR', '2' )

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
					For nlI := 1 To Len( aGravaCMR )
						oModel:LoadValue( 'MODEL_CMR', aGravaCMR[ nlI, 1 ], aGravaCMR[ nlI, 2 ] )
					Next

					//Necess�rio Abaixo do For Nao Retirar
					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_CMR', 'CMR_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					For nCMT := 1 To Len( aGravaCMT )
						oModel:GetModel( 'MODEL_CMT' ):LVALID	:= .T.

						If nCMT > 1
							oModel:GetModel( 'MODEL_CMT' ):AddLine()
						EndIf

						oModel:LoadValue( "MODEL_CMT", "CMT_INDAQU", aGravaCMT[nCMT][1] )
						oModel:LoadValue( "MODEL_CMT", "CMT_VLAQUI", aGravaCMT[nCMT][2] )

						nCMUAdd := 1
						For nCMU := 1 To Len( aGravaCMU )
							// Grava apenas o CMU pertencente ao CMT
							If aGravaCMU[nCMU][1] == aGravaCMT[nCMT][1]
								oModel:GetModel( 'MODEL_CMU' ):LVALID	:= .T.

								If nCMUAdd > 1
									oModel:GetModel( 'MODEL_CMU' ):AddLine()
								EndIf
									oModel:LoadValue( "MODEL_CMU", "CMU_TPINSC", aGravaCMU[nCMU][2] )
									oModel:LoadValue( "MODEL_CMU", "CMU_INSCPR", aGravaCMU[nCMU][3] )
									oModel:LoadValue( "MODEL_CMU", "CMU_VLBRUT", aGravaCMU[nCMU][4] )
									oModel:LoadValue( "MODEL_CMU", "CMU_VLCONT", aGravaCMU[nCMU][5] )
									oModel:LoadValue( "MODEL_CMU", "CMU_VLGILR", aGravaCMU[nCMU][6] )
									oModel:LoadValue( "MODEL_CMU", "CMU_VLSENA", aGravaCMU[nCMU][7] )
									If __lLay0205 .And. TafColumnPos("CMU_INDCP")
										oModel:LoadValue( "MODEL_CMU", "CMU_INDCP" , aGravaCMU[nCMU][8] )
									EndIf
									
									If !__lLay0205
										nCMVAdd := 1
										For nCMV := 1 To Len( aGravaCMV )
											// Grava apenas o CMV pertencente ao CMU
											If  aGravaCMV[nCMV][1] == aGravaCMT[nCMT][1] .And. aGravaCMV[nCMV][2] == aGravaCMU[nCMU][3]
												oModel:GetModel( 'MODEL_CMV' ):LVALID	:= .T.
		
												If nCMVAdd > 1
													oModel:GetModel( 'MODEL_CMV' ):AddLine()
												EndIf
													oModel:LoadValue( "MODEL_CMV", "CMV_SERIE", aGravaCMV[nCMV][3] )
													oModel:LoadValue( "MODEL_CMV", "CMV_NUMDOC", aGravaCMV[nCMV][4] )
													oModel:LoadValue( "MODEL_CMV", "CMV_DTEMIS", aGravaCMV[nCMV][5] )
													oModel:LoadValue( "MODEL_CMV", "CMV_VLBRUT", aGravaCMV[nCMV][6] )
													oModel:LoadValue( "MODEL_CMV", "CMV_VLCONT", aGravaCMV[nCMV][7] )
													oModel:LoadValue( "MODEL_CMV", "CMV_VLGILR", aGravaCMV[nCMV][8] )
													oModel:LoadValue( "MODEL_CMV", "CMV_VLSENA", aGravaCMV[nCMV][9] )
		
												nCMVAdd++
											EndIf
										Next // Fim - CMV
									EndIf    

									nT1ZAdd := 1
									For nT1Z := 1 To Len( aGravaT1Z )
										// Grava apenas o T1Z pertencente ao CMU
										If aGravaT1Z[nT1Z][1] == aGravaCMT[nCMT][1] .And. aGravaT1Z[nT1Z][2] == aGravaCMU[nCMU][3]
											oModel:GetModel( 'MODEL_T1Z' ):LVALID	:= .T.

											If nT1ZAdd > 1
												oModel:GetModel( 'MODEL_T1Z' ):AddLine()
											EndIf
												oModel:LoadValue( "MODEL_T1Z", "T1Z_IDPROC", aGravaT1Z[nT1Z][3] )
												oModel:LoadValue( "MODEL_T1Z", "T1Z_CODSUS", aGravaT1Z[nT1Z][4] )
												oModel:LoadValue( "MODEL_T1Z", "T1Z_VLRPRV", aGravaT1Z[nT1Z][5] )
												oModel:LoadValue( "MODEL_T1Z", "T1Z_VLRRAT", aGravaT1Z[nT1Z][6] )
												oModel:LoadValue( "MODEL_T1Z", "T1Z_VLRSEN", aGravaT1Z[nT1Z][7] )

											nT1ZAdd++
										EndIf
									Next // Fim - T1Z

								nCMUAdd++
							EndIf
						Next // Fim - CMU
					
					If __lLay0205 .And. __lV2O
							nV2OAdd := 1
							For nV2O := 1 To Len( aGravaV2O )
								// Grava apenas o V2O pertencente ao CMT
								If aGravaV2O[nV2O][1] == aGravaCMT[nCMT][1] 
									oModel:GetModel( 'MODEL_V2O' ):LVALID	:= .T.
		
									If nV2OAdd > 1
										oModel:GetModel( 'MODEL_V2O' ):AddLine()
									EndIf
										oModel:LoadValue( "MODEL_V2O", "V2O_IDPROC", aGravaV2O[nV2O][3] )
										oModel:LoadValue( "MODEL_V2O", "V2O_CODSUS", aGravaV2O[nV2O][4] )
										oModel:LoadValue( "MODEL_V2O", "V2O_VLRPRV", aGravaV2O[nV2O][5] )
										oModel:LoadValue( "MODEL_V2O", "V2O_VLRRAT", aGravaV2O[nV2O][6] )
										oModel:LoadValue( "MODEL_V2O", "V2O_VLRSEN", aGravaV2O[nV2O][7] )
		
									nV2OAdd++
								EndIf
							Next // Fim - V2O
						EndIf 
					Next // Fim - CMT

					//�������������������������������Ŀ
					//�Busco a versao que sera gravada�
					//���������������������������������
					cVersao := xFunGetVer()

					//�����������������������������������������������������������Ŀ
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//�������������������������������������������������������������
					oModel:LoadValue( 'MODEL_CMR', 'CMR_VERSAO', cVersao )
					oModel:LoadValue( 'MODEL_CMR', 'CMR_VERANT', cVerAnt )
					oModel:LoadValue( 'MODEL_CMR', 'CMR_PROTPN', cProtocolo )
					oModel:LoadValue( 'MODEL_CMR', 'CMR_PROTUL', "" )
					oModel:LoadValue( "MODEL_CMR", "CMR_EVENTO", "A" )

					// Tratamento para limpar o ID unico do xml
					cAliasPai := "CMR"
					If TAFColumnPos( cAliasPai+"_XMLID" )
						oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					EndIf

					FwFormCommit( oModel )
					
					TAFAltStat( 'CMR', " " )

				ElseIf	CMR->CMR_STATUS == "2"
					TAFMsgVldOp(oModel,"2")//"Registro n�o pode ser alterado. Aguardando processo da transmiss�o."
					lRetorno:= .F.
				ElseIf CMR->CMR_STATUS == "6"
					TAFMsgVldOp(oModel,"6")//"Registro n�o pode ser alterado. Aguardando proc. Transm. evento de Exclus�o S-3000"
					lRetorno:= .F.
				ElseIf CMR->CMR_STATUS == "7"
					TAFMsgVldOp(oModel,"7") //"Registro n�o pode ser alterado, pois o evento j� se encontra na base do RET"
					lRetorno:= .F.
				Else
					If TafColumnPos( "CMR_LOGOPE" )
						cLogOpeAnt := CMR->CMR_LOGOPE
					EndIf

					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_CMR', 'CMR_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					FwFormCommit( oModel )
					TAFAltStat( 'CMR', " " )
				EndIf
			EndIf
			//Exclus�o Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_DELETE

			cChvRegAnt := CMR->(CMR_ID + CMR_VERANT)

			TAFAltStat( 'CMR', " " )
			FwFormCommit( oModel )

			If CMR->CMR_EVENTO == "A" .Or. CMR->CMR_EVENTO == "E"
				TAFRastro( 'CMR', 1, cChvRegAnt, .T., , IIF(Type("oBrw") == "U", Nil, oBrw) )
			EndIf

		EndIf
		
	End Transaction

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF272Xml
Funcao de geracao do XML para atender o registro S-1250
Quando a rotina for chamada o registro deve estar posicionado

@param cAlias, character, Alias corrente (Parametro padrao MVC)
@param nRecno, numeric,   Recno corrente (Parametro padrao MVC)
@param nOpc,   numeric,   Opcao selecionada (Parametro padrao MVC)
@param lJob,   logic,     Informa se foi chamado por Job
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composi��o da chave ID do XML

@return cXml, Estrutura do Xml do Layout S-1250

@author Daniel Magalhaes
@since 22/10/2013
@version MP11.8, MP12
/*/
//-------------------------------------------------------------------
Function TAF272Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

	Local cXml      := ""
	Local cLayout   := "1250"
	Local cReg      := "AqProd"
	Local cInfEvt   := ""
	Local cIndRet   := ""
	Local cNrRec    := ""
	Local cIndApu   := ""
	Local cPerApur  := ""
	Local cCMRKey   := ""
	Local cCMTKey   := ""
	Local cCMUKey   := ""
	Local aMensal   := {}
	Local lXmlVLd   := IIF(FindFunction( 'TafXmlVLD' ),TafXmlVLD( 'TAF272XML' ),.T.)

	Default lJob    := .F.
	Default cSeqXml := ""

	cInfEvt := CMR->CMR_VERSAO

	If CMR->CMR_EVENTO == "A"
		cIndRet := "2"
		cNrRec  := CMR->CMR_PROTPN
	Else
		cIndRet := "1"
	EndIf

	cIndApu := CMR->CMR_INDAPU
	If lXmlVLd
		If CMR->CMR_INDAPU == '1'
			aAdd(aMensal, CMR->CMR_INDAPU)
			If Len(Alltrim(CMR->CMR_PERAPU)) <= 4
				AADD(aMensal,CMR->CMR_PERAPU)
			Else
				AADD(aMensal,substr(CMR->CMR_PERAPU, 1, 4) + '-' + substr(CMR->CMR_PERAPU, 5, 2) )
			EndIf
		EndIf

		cPerApur := CMR->CMR_PERAPU

		cXml += "<infoAquisProd>"

		CMT->( DbSetOrder(1) )
		CMU->( DbSetOrder(1) )
		CMV->( DbSetOrder(1) )
		C1G->( DbSetOrder(8) )

		cCMRKey := CMR->CMR_FILIAL + CMR->CMR_ID + CMR->CMR_VERSAO

		cXml +=   "<ideEstabAdquir>"
		cXml +=	    xTafTag("tpInscAdq",CMR->CMR_TPINSC)
		cXml +=	    xTafTag("nrInscAdq",CMR->CMR_INSCES)

		//����������������������������Ŀ
		//�INICIO CMT - <tpAquis>�
		//������������������������������
		If CMT->( MsSeek( xFilial("CMT") + CMR->CMR_ID + CMR->CMR_VERSAO ) )

			Do While !CMT->( Eof() ) .And. Alltrim(cCMRKey) == Alltrim(CMT->CMT_FILIAL + CMT->CMT_ID + CMT->CMT_VERSAO)

				If __lLay0205
					cXml +=     "<tpAquis"
					cXml +=       xTafTag("indAquis"     ,CMT->CMT_INDAQU,,,,,.T.)
					cXml +=       xTafTag("vlrTotAquis"  ,CMT->CMT_VLAQUI,PesqPict("CMT","CMT_VLAQUI"),,,,.T.)
					cXml +=     ">"
				Else
					cXml +=     "<tpAquis>"
					cXml +=       xTafTag("indAquis"     ,CMT->CMT_INDAQU)
					cXml +=       xTafTag("vlrTotAquis"  ,CMT->CMT_VLAQUI,PesqPict("CMT","CMT_VLAQUI"))
				EndIf

				//��������������������������Ŀ
				//�INICIO CMU - <ideProdutor>�
				//����������������������������
				If CMU->( MsSeek( xFilial("CMU") + CMT->CMT_ID + CMT->CMT_VERSAO + CMT->CMT_INDAQU ) )
					cCMTKey := CMT->CMT_FILIAL + CMT->CMT_ID + CMT->CMT_VERSAO + CMT->CMT_INDAQU

					Do While !CMU->( Eof() ) .And. Alltrim(cCMTKey) == Alltrim(CMU->CMU_FILIAL + CMU->CMU_ID + CMU->CMU_VERSAO + CMU->CMU_INDAQU)

						If __lLay0205 .And. TafColumnPos("CMU_INDCP")

							cXml +=       "<ideProdutor"
							cXml +=         xTafTag("tpInscProd"	,CMU->CMU_TPINSC,,,,,.T.)
							cXml +=         xTafTag("nrInscProd"	,CMU->CMU_INSCPR,,,,,.T.)
							cXml +=         xTafTag("vlrBruto"		,CMU->CMU_VLBRUT,PesqPict("CMU","CMU_VLBRUT"),,,,.T.)
							cXml +=         xTafTag("vrCPDescPR"	,CMU->CMU_VLCONT,PesqPict("CMU","CMU_VLCONT"),,,.T.,.T.)
							cXml +=         xTafTag("vrRatDescPR"	,CMU->CMU_VLGILR,PesqPict("CMU","CMU_VLGILR"),,,.T.,.T.)
							cXml +=         xTafTag("vrSenarDesc"	,CMU->CMU_VLSENA,PesqPict("CMU","CMU_VLSENA"),,,.T.,.T.)
							cXml += 		xTafTag("indOpcCP"		,CMU->CMU_INDCP,PesqPict("CMU","CMU_INDCP"),,,,.T.)
							cXml +=       ">
						Else
							cXml +=       "<ideProdutor>"
							cXml +=         xTafTag("tpInscProd"	,CMU->CMU_TPINSC)
							cXml +=         xTafTag("nrInscProd"	,CMU->CMU_INSCPR)
							cXml +=         xTafTag("vlrBruto"		,CMU->CMU_VLBRUT,PesqPict("CMU","CMU_VLBRUT"))
							cXml +=         xTafTag("vrCPDescPR"	,CMU->CMU_VLCONT,PesqPict("CMU","CMU_VLCONT"),,,.T.)
							cXml +=         xTafTag("vrRatDescPR"	,CMU->CMU_VLGILR,PesqPict("CMU","CMU_VLGILR"),,,.T.)
							cXml +=         xTafTag("vrSenarDesc"	,CMU->CMU_VLSENA,PesqPict("CMU","CMU_VLSENA"),,,.T.)
						EndIf
						//���������������������������Ŀ
						//�INICIO CMV - <nfs>�
						//�����������������������������
						If !__lLay0205 .Or. (CMU->CMU_TPINSC == '1' .And. cPerApur < "201901")
							If CMT->CMT_INDAQU $ '3|6'
								If CMV->( MsSeek( xFilial( "CMV" ) + CMU->CMU_ID + CMU->CMU_VERSAO + CMU->CMU_INDAQU + CMU->CMU_INSCPR) )
									cCMUKey := CMU->CMU_FILIAL + CMU->CMU_ID + CMU->CMU_VERSAO + CMU->CMU_INDAQU + CMU->CMU_INSCPR
			
									Do While !CMV->( Eof() ) .And. Alltrim(cCMUKey) == Alltrim(CMV->CMV_FILIAL + CMV->CMV_ID + CMV->CMV_VERSAO + CMV->CMV_INDAQU + CMV->CMV_INSCPR)
			
										cXml +=         "<nfs>"
										cXml +=           xTafTag("serie"         ,CMV->CMV_SERIE,,.T.)
										cXml +=           xTafTag("nrDocto"       ,CMV->CMV_NUMDOC)
										cXml +=           xTafTag("dtEmisNF"      ,CMV->CMV_DTEMIS,PesqPict("CMV","CMV_DTEMIS"))
										cXml +=           xTafTag("vlrBruto"      ,CMV->CMV_VLBRUT,PesqPict("CMV","CMV_VLBRUT"))
										cXml +=           xTafTag("vrCPDescPR"	  	,CMV->CMV_VLCONT,PesqPict("CMV","CMV_VLCONT"),,,.T.)
										cXml +=           xTafTag("vrRatDescPR"   ,CMV->CMV_VLGILR,PesqPict("CMV","CMV_VLGILR"),,,.T.)
										cXml +=           xTafTag("vrSenarDesc"   ,CMV->CMV_VLSENA,PesqPict("CMV","CMV_VLSENA"),,,.T.)
										cXml +=         "</nfs>"
			
										CMV->( DbSkip() )
									EndDo
								EndIf
							EndIf
						EndIf
						//�������Ŀ
						//�FIM CMV�
						//���������

						//���������������������������Ŀ
						//�INICIO T1Z - <Processo Judicial>�
						//�����������������������������
						If T1Z->( MsSeek( xFilial( "T1Z" ) + CMU->CMU_ID + CMU->CMU_VERSAO + CMU->CMU_INDAQU + CMU->CMU_INSCPR ) )
							cCMUKey := CMU->CMU_FILIAL + CMU->CMU_ID + CMU->CMU_VERSAO + CMU->CMU_INDAQU + CMU->CMU_INSCPR

							Do While !T1Z->( Eof() ) .And. Alltrim(cCMUKey) == Alltrim(T1Z->T1Z_FILIAL + T1Z->T1Z_ID + T1Z->T1Z_VERSAO + T1Z->T1Z_INDAQU + T1Z->T1Z_INSCPR)

								If __lLay0205

									cXml +=         "<infoProcJud"
									cXml +=           xTafTag("nrProcJud" 		,POSICIONE("C1G",3, xFilial("C1G")+T1Z->T1Z_IDPROC,"C1G_NUMPRO"),,,,,.T.)

									cCodSusp    := Posicione("T5L",1,xFilial("T5L")+T1Z->T1Z_IDSUSP,"T5L_CODSUS",,,,.T.)
									If !Empty(cCodSusp)
										cXml += xTafTag("codSusp", Alltrim(cCodSusp),,,,,.T.)
									EndIf

									cXml +=           xTafTag("vrCPNRet"		,T1Z->T1Z_VLRPRV,PesqPict("T1Z","T1Z_VLRPRV"), , ,.T. , .T.)
									cXml +=           xTafTag("vrRatNRet"		,T1Z->T1Z_VLRRAT,PesqPict("T1Z","T1Z_VLRRAT"), , ,.T., .T.)
									cXml +=           xTafTag("vrSenarNRet"	,T1Z->T1Z_VLRSEN,PesqPict("T1Z","T1Z_VLRSEN"), , ,.T. , .T.)
									cXml +=         "/>"

								Else
									cXml +=         "<infoProcJud>"
									cXml +=           xTafTag("nrProcJud" 		,POSICIONE("C1G",3, xFilial("C1G")+T1Z->T1Z_IDPROC,"C1G_NUMPRO"))

									cCodSusp    := Posicione("T5L",1,xFilial("T5L")+T1Z->T1Z_IDSUSP,"T5L_CODSUS")
									If !Empty(cCodSusp)
										cXml += xTafTag("codSusp", Alltrim(cCodSusp))
									EndIf

									cXml +=           xTafTag("vrCPNRet"		,T1Z->T1Z_VLRPRV,PesqPict("T1Z","T1Z_VLRPRV"), , , .T.)
									cXml +=           xTafTag("vrRatNRet"		,T1Z->T1Z_VLRRAT,PesqPict("T1Z","T1Z_VLRRAT"), , , .T.)
									cXml +=           xTafTag("vrSenarNRet"	,T1Z->T1Z_VLRSEN,PesqPict("T1Z","T1Z_VLRSEN"), , , .T.)
									cXml +=         "</infoProcJud>"
								EndIf
								T1Z->( DbSkip() )
							EndDo

						EndIf
						//�������Ŀ
						//�FIM T1Z�
						//���������
						cXml += "</ideProdutor>"

						CMU->( DbSkip() )
					EndDo

				EndIf
				
				//���������������������������Ŀ
				//�INICIO V2O - <Processo Judicial de Aquisi��o>�
				//�����������������������������
				If __lLay0205 .And. __lV2O
					If V2O->( MsSeek( xFilial( "V2O" ) + CMT->CMT_ID + CMT->CMT_VERSAO + CMT->CMT_INDAQU ) )
						
						cCMTKey := CMT->CMT_FILIAL + CMT->CMT_ID + CMT->CMT_VERSAO + CMT->CMT_INDAQU
			
						Do While !V2O->( Eof() ) .And. Alltrim(cCMTKey) == Alltrim(V2O->V2O_FILIAL + V2O->V2O_ID + V2O->V2O_VERSAO + V2O->V2O_INDAQU)
							cXml += "<infoProcJ"
								cXml +=  xTafTag("nrProcJud" 		,POSICIONE("C1G",3, xFilial("C1G")+V2O->V2O_IDPROC,"C1G_NUMPRO"), , , , , .T.)
				
								cCodSusp := Posicione("T5L",1,xFilial("T5L")+V2O->V2O_IDSUSP,"T5L_CODSUS")
								If !Empty(cCodSusp)
								cXml += xTafTag("codSusp", Alltrim(cCodSusp), , , , ,.T.)
							EndIf
				
								cXml += xTafTag("vrCPNRet"		,V2O->V2O_VLRPRV,PesqPict("V2O","V2O_VLRPRV"), , , , .T.)
								cXml += xTafTag("vrRatNRet"		,V2O->V2O_VLRRAT,PesqPict("V2O","V2O_VLRRAT"), , , , .T.)
								cXml += xTafTag("vrSenarNRet"	,V2O->V2O_VLRSEN,PesqPict("V2O","V2O_VLRSEN"), , , , .T.)		
							cXml += "/>" 
							
							V2O->( DbSkip() )
						EndDo
					EndIf
				EndIf
				//�������Ŀ
				//�FIM CMU�
				//���������
				cXml += "</tpAquis>"

				CMT->( DbSkip() )
			EndDo

		EndIf
		//�������Ŀ
		//�FIM CMT�
		//���������

		cXml += 	"</ideEstabAdquir>"
		cXml += "</infoAquisProd>"

		//����������������������Ŀ
		//�Estrutura do cabecalho�
		//������������������������
		cXml := xTafCabXml( cXml, "CMR", cLayout, cReg, aMensal,cSeqXml)


		//����������������������������Ŀ
		//�Executa gravacao do registro�
		//������������������������������
		If !lJob
			xTafGerXml( cXml, cLayout )
		EndIf

	EndIf

Return cXml

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF272Grv
@type			function
@description	Fun��o de grava��o para atender o registro S-1250 ( Outras Informa��es - Aquisi��o de Produ��o ).
@author			Daniel Magalhaes
@since			22/10/2013
@version		1.0
@param			cLayout		-	Nome do Layout que est� sendo enviado
@param			nOpc		-	Op��o a ser realizada ( 3 = Inclus�o, 4 = Altera��o, 5 = Exclus�o )
@param			cFilEv		-	Filial do ERP para onde as informa��es dever�o ser importadas
@param			oXML		-	Objeto com as informa��es a serem manutenidas ( Outras Integra��es )
@param			cOwner
@param			cFilTran
@param			cPredeces
@param			nTafRecno
@param			cComplem
@param			cGrpTran
@param			cEmpOriGrp
@param			cFilOriGrp
@param			cXmlID		-	Atributo Id, �nico para o XML do eSocial. Utilizado para importa��o de dados de clientes migrando para o TAF
@return			lRet		-	Vari�vel que indica se a importa��o foi realizada, ou seja, se as informa��es foram gravadas no banco de dados
@param			aIncons		-	Array com as inconsist�ncias encontradas durante a importa��o
/*/
//-------------------------------------------------------------------
Function TAF272Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

	Local oModel       := Nil
	Local cInfEvento   := "/eSocial/evtAqProd/infoAquisProd/"
	Local cCmpsNoUpd   := "|CMR_FILIAL|CMR_ID|CMR_VERSAO|CMR_VERANT|CMR_PROTUL|CMR_PROTPN|CMR_EVENTO|CMR_STATUS|CMR_ATIVO|"
	Local cCMTPath     := ""
	Local cCMUPath     := ""
	Local cCMVPath     := ""
	Local cT1ZPath     := ""
	Local cChave       := ""
	Local cInconMsg    := ""
	Local cIdProc      := ""
	Local cCodEvent    := Posicione( "C8E", 2, xFilial( "C8E" ) + "S-" + cLayout, "C8E->C8E_ID" )
	Local cPeriodo     := ""
	Local cLogOpeAnt   := ""
	Local nCMT         := 0
	Local nCMU         := 0
	Local nCMV         := 0
	Local nT1Z         := 0
	Local nV2O         := 0
	Local nSeqErrGrv   := 0
	Local nlI          := 0
	Local nPosTpInsc   := 0
	Local nPosInsc     := 0
	Local aArea        := GetArea()
	Local aIncons      := {}
	Local aRules       := {}
	Local aChave       := {}
	Local lRet         := .F.
	Local cIndAqu      := ""
	Local cVlrAquis    := ""
	Local nProdutores  := 0
	Local cInscAtu     := ""
	Local aInscProd    := {}

	Private lVldModel  := .T. //Caso a chamada seja via integra��o, seto a vari�vel de controle de valida��o como .T.
	Private oDados     := Nil

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

	oDados := oXML
	cPeriodo := FTAFGetVal( "/eSocial/evtAqProd/ideEvento/perApur", "C", .F., @aIncons, .F. )

	Aadd( aChave, {"C", "CMR_INDAPU", FTafGetVal( "/eSocial/evtAqProd/ideEvento/indApuracao", "C", .F., @aIncons, .F. )  , .T.} )
	cChave += Padr( aChave[ 1, 3 ], Tamsx3( aChave[ 1, 2 ])[1])

	If At("-", cPeriodo) > 0
		Aadd( aChave, {"C", "CMR_PERAPU", StrTran(cPeriodo, "-", "" ),.T.} )
		cChave += Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1])
	Else
		Aadd( aChave, {"C", "CMR_PERAPU", cPeriodo  , .T.} )
		cChave += Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1])
	EndIf

	Aadd( aChave, {"C", "CMR_TPINSC", FTafGetVal( "/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/tpInscAdq", "C", .F., @aIncons, .F. )  , .T.} )
	cChave += Padr( aChave[ 3, 3 ], Tamsx3( aChave[ 3, 2 ])[1])

	Aadd( aChave, {"C", "CMR_INSCES", FTafGetVal( "/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/nrInscAdq", "C", .F., @aIncons, .F. )  , .T.} )
	cChave += Padr( aChave[ 4, 3 ], Tamsx3( aChave[ 4, 2 ])[1])

	//Verifica se o evento ja existe na base
	("CMR")->( DbSetOrder( 2 ) )
	If !Empty(cPredeces) .And. ValType(nTafRecno) == "N" .And. nTafRecno > 0
		CMR->(DbGoto(nTafRecno))
	ElseIf ("CMR")->( MsSeek( xFilial("CMR") + cChave + '1' ) ) .And. FTafGetVal( "/eSocial/evtAqProd/ideEvento/indRetif", "C", .F., @aIncons, .F. ) == "2" 
		nOpc := 4
	EndIf

	Begin Transaction

		//���������������������������������������������������������������Ŀ
		//�Carrego array com os campos De/Para de gravacao das informacoes�
		//�����������������������������������������������������������������
		aRules 	:= TAF272Rul( cCodEvent, cOwner )

		//�������������������������������������������������������������Ŀ
		//�Funcao para validar se a operacao desejada pode ser realizada�
		//���������������������������������������������������������������
		If FTafVldOpe( 'CMR', 2, @nOpc, cFilEv, @aIncons, aChave, @oModel, 'TAFA272', cCmpsNoUpd , , , , , nTafRecno )

			If TafColumnPos( "CMR_LOGOPE" )
				cLogOpeAnt := CMR->CMR_LOGOPE
			endif

			//����������������������������������������������������������������Ŀ
			//�Quando se tratar de uma Exclusao direta apenas preciso realizar �
			//�o Commit(), nao eh necessaria nenhuma manutencao nas informacoes�
			//������������������������������������������������������������������
			If nOpc <> 5

				oModel:LoadValue( "MODEL_CMR", "CMR_FILIAL", CMR->CMR_FILIAL )

				If TAFColumnPos( "CMR_XMLID" )
					oModel:LoadValue( "MODEL_CMR", "CMR_XMLID", cXmlID )
				EndIf

				// Verifica se a inscri��o informada existe no s-1005
				nPosTpInsc 	:= aScan( aRules, { |x| x[1] == "CMR_TPINSC" } )
				nPosInsc 	:= aScan( aRules, { |x| x[1] == "CMR_INSCES" } )

				cTpInsc		:= FTafGetVal( aRules[ nPosTpInsc, 02 ], aRules[nPosTpInsc, 03], aRules[nPosTpInsc, 04], @aIncons, .F. )
				cInsc		:= FTafGetVal( aRules[ nPosInsc, 02 ], aRules[nPosInsc, 03], aRules[nPosInsc, 04], @aIncons, .F. )

				C92->( DbSetOrder( 6 ) )
				If !C92->( MsSeek( xFilial( "C92" ) + cTpInsc + PadR( cInsc, TamSX3( "CMR_INSCES" )[1] ) + "1" ) )
					cInconMsg := "Registro n�o encontrado em S-1005"
				Else

					//����������������������������������������Ŀ
					//�Rodo o aRules para gravar as informacoes�
					//������������������������������������������
					For nlI := 1 To Len( aRules )
						oModel:LoadValue( "MODEL_CMR", aRules[ nlI, 01 ], FTafGetVal( aRules[ nlI, 02 ], aRules[nlI, 03], aRules[nlI, 04], @aIncons, .F. ) )
					Next

					If Findfunction("TAFAltMan")
						if nOpc == 3
							TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_CMR', 'CMR_LOGOPE' , '1', '' )
						elseif nOpc == 4
							TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_CMR', 'CMR_LOGOPE' , '', cLogOpeAnt )
						EndIf
					EndIf

					//#################################################
					//����������������������������Ŀ
					//�INICIO CMT - <tpAquis>�
					//������������������������������
					//Quando se trata de uma alteracao, deleto todas as linhas do Grid
					If nOpc == 4
						For nCMT := 1 to oModel:GetModel( "MODEL_CMT" ):Length()
							oModel:GetModel( "MODEL_CMT" ):GoLine(nCMT)
							oModel:GetModel( "MODEL_CMT" ):DeleteLine()
						Next nCMT
					EndIf

					nCMT := 1
					cCMTPath := cInfEvento + "ideEstabAdquir/tpAquis[" + cValToChar(nCMT) + "]"
					
					While oDados:XPathHasNode( cCMTPath )

						If TafLayESoc("02_05_00")
							nCMU := 1
							cCMUPath := cCMTPath + "/ideProdutor[" + cValToChar(nCMU) + "]"
							
							aInscProd := {}
							
							nProdutores += oDados:XPathChildCount(cCMTPath)
											
							If nProdutores > QTDMAX_PRODRURAIS
								cInconMsg := "Por limita��es do governo, n�o � poss�vel enviar um evento S-1250 com mais de " + AllTrim(Str(QTDMAX_PRODRURAIS)) + " produtores rurais, apesar do layout permitir 9999 produtores. Aconselha-se que seja feita a quebra desse evento em 2, para que a transmiss�o seja feita com sucesso."
								Exit
							EndIf

							While oDados:XPathHasNode( cCMUPath )

								cInscAtu := FTafGetVal( cCMUPath, "C", .F., @aIncons, .T.,,,,,.T., "nrInscProd")
								If aScan(aInscProd, cInscAtu) > 0
									cInconMsg := "Este XML cont�m CPF/CNPJ de produtor duplicados. Elimine as duplicidades no XML e tente integrar novamente."
									Exit
								Else		 
									aAdd(aInscProd, cInscAtu)
								EndIf
								
								nCMU++
								cCMUPath := cCMTPath + "/ideProdutor[" + cValToChar(nCMU) + "]"
							EndDo
						EndIf

						If Empty(cInconMsg)

							If nOpc == 4 .Or. nCMT > 1
								// Informa que a linha est� v�lida para que seja inclu�da uma nova linha
								oModel:GetModel( "MODEL_CMT" ):LVALID := .T.
								// Inclui uma linha a cada volta do la�o
								oModel:GetModel( "MODEL_CMT" ):AddLine()
							EndIf

							// Grava dados no model
							If __lLay0205
								If 	oDados:XPathHasAtt(cCMTPath)
									cIndAqu := oDados:xPathGetAtt( cCMTPath , "indAquis" )
									If cIndAqu <> ""
										oModel:LoadValue( "MODEL_CMT", "CMT_INDAQU", FTafGetVal( cCMTPath, "C", .F., @aIncons, .T.,,,,,.T., "indAquis") )
									EndIf
								EndIf
							Else
								If oDados:XPathHasNode(cCMTPath + "/indAquis")
									oModel:LoadValue( "MODEL_CMT", "CMT_INDAQU", FTafGetVal( cCMTPath + "/indAquis"     , "C", .F., @aIncons, .T. ) )
								EndIf
							EndIf
							
							If __lLay0205
								If oDados:XPathHasAtt(cCMTPath)
									cVlrAquis := oDados:xPathGetAtt( cCMTPath , "vlrTotAquis" )
									If cVlrAquis <> ""
										oModel:LoadValue( "MODEL_CMT", "CMT_VLAQUI", FTafGetVal( cCMTPath, "N", .F., @aIncons, .T.,,,,,.T., "vlrTotAquis") )
									EndIf
								EndIf
							Else
								If oDados:XPathHasNode(cCMTPath + "/vlrTotAquis")
									oModel:LoadValue( "MODEL_CMT", "CMT_VLAQUI", FTafGetVal( cCMTPath + "/vlrTotAquis"	 , "N", .F., @aIncons, .T. ) )
								EndIf
							EndIf

							//#################################################
							//��������������������������Ŀ
							//�INICIO CMU - <ideProdutor>�
							//����������������������������
							//Quando se trata de uma alteracao, deleto todas as linhas do Grid
							If nOpc == 4
								For nCMU := 1 to oModel:GetModel( "MODEL_CMU" ):Length()
									oModel:GetModel( "MODEL_CMU" ):GoLine(nCMU)
									oModel:GetModel( "MODEL_CMU" ):DeleteLine()
								Next nCMU
							EndIf

							nCMU := 1
							cCMUPath := cCMTPath + "/ideProdutor[" + cValToChar(nCMU) + "]"
							While oDados:XPathHasNode( cCMUPath )

								If nOpc == 4 .Or. nCMU > 1
									// Informa que a linha est� v�lida para que seja inclu�da uma nova linha
									oModel:GetModel( "MODEL_CMU" ):LVALID := .T.
									// Inclui uma linha a cada volta do la�o
									oModel:GetModel( "MODEL_CMU" ):AddLine()
								EndIf

								// Grava dados no model
								If __lLay0205
									If oDados:XPathHasAtt(cCMUPath)
										cTpInscProd := oDados:xPathGetAtt( cCMUPath , "tpInscProd" )
										If cTpInscProd <> "" 
											oModel:LoadValue( "MODEL_CMU", "CMU_TPINSC", FTafGetVal( cCMUPath, "C", .F., @aIncons, .T.,,,,,.T., "tpInscProd") )
										EndIf
									EndIf
								Else
									If oDados:XPathHasNode(cCMUPath + "/tpInscProd")
										oModel:LoadValue( "MODEL_CMU", "CMU_TPINSC", FTafGetVal( cCMUPath + "/tpInscProd"     , "C", .F., @aIncons, .T. ) )
									EndIf
								EndIf

								If __lLay0205
									If oDados:XPathHasAtt(cCMUPath)
										cNrInscProd := oDados:xPathGetAtt( cCMUPath , "nrInscProd" )
										If cNrInscProd <> ""
											oModel:LoadValue( "MODEL_CMU", "CMU_INSCPR", FTafGetVal( cCMUPath, "C", .F., @aIncons, .T.,,,,,.T., "nrInscProd") )
										EndIf
									EndIf
								Else
									If oDados:XPathHasNode(cCMUPath + "/nrInscProd")
										oModel:LoadValue( "MODEL_CMU", "CMU_INSCPR", FTafGetVal( cCMUPath + "/nrInscProd"     , "C", .F., @aIncons, .T. ) )
									EndIf
								EndIf

								If __lLay0205
									If oDados:XPathHasAtt(cCMUPath)
										cVlrBrut := oDados:xPathGetAtt( cCMUPath , "vlrBruto" )
										If cVlrBrut <> ""
											oModel:LoadValue( "MODEL_CMU", "CMU_VLBRUT", FTafGetVal( cCMUPath, "N", .F., @aIncons, .T.,,,,,.T., "vlrBruto") )
										EndIf
									EndIf
								Else
									If oDados:XPathHasNode(cCMUPath + "/vlrBruto")
										oModel:LoadValue( "MODEL_CMU", "CMU_VLBRUT", FTafGetVal( cCMUPath + "/vlrBruto"       , "N", .F., @aIncons, .T. ) )
									EndIf
								EndIf

								If __lLay0205
									If oDados:XPathHasAtt(cCMUPath)
										cVrCPDdesc := oDados:xPathGetAtt( cCMUPath , "vrCPDescPR" )
										If cVrCPDdesc <> ""
											oModel:LoadValue( "MODEL_CMU", "CMU_VLCONT", FTafGetVal( cCMUPath, "N", .F., @aIncons, .T.,,,,,.T., "vrCPDescPR") )
										EndIf
									EndIf
								Else
									If oDados:XPathHasNode(cCMUPath + "/vrCPDescPR")
										oModel:LoadValue( "MODEL_CMU", "CMU_VLCONT", FTafGetVal( cCMUPath + "/vrCPDescPR"	  , "N", .F., @aIncons, .T. ) )
									EndIf
								EndIf

								If __lLay0205
									If oDados:XPathHasAtt(cCMUPath)
										cVrRatDesc := oDados:xPathGetAtt( cCMUPath , "vrRatDescPR" )
										If cVrRatDesc <> ""
											oModel:LoadValue( "MODEL_CMU", "CMU_VLGILR", FTafGetVal( cCMUPath, "N", .F., @aIncons, .T.,,,,,.T., "vrRatDescPR") )
										EndIf
									EndIf
								Else
									If oDados:XPathHasNode(cCMUPath + "/vrRatDescPR")
										oModel:LoadValue( "MODEL_CMU", "CMU_VLGILR", FTafGetVal( cCMUPath + "/vrRatDescPR" 	  , "N", .F., @aIncons, .T. ) )
									EndIf
								EndIf

								If __lLay0205
									If oDados:XPathHasAtt(cCMUPath)
										cVrSenarDesc := oDados:xPathGetAtt( cCMUPath , "vrSenarDesc" )
										If cVrSenarDesc <> ""
											oModel:LoadValue( "MODEL_CMU", "CMU_VLSENA", FTafGetVal( cCMUPath, "N", .F., @aIncons, .T.,,,,,.T., "vrSenarDesc") )
										EndIf
									EndIf
								Else
									If oDados:XPathHasNode(cCMUPath + "/vrSenarDesc")
										oModel:LoadValue( "MODEL_CMU", "CMU_VLSENA", FTafGetVal( cCMUPath + "/vrSenarDesc"    , "N", .F., @aIncons, .T. ) )
									EndIf
								EndIf
								
								If __lLay0205 .And. TafColumnPos("CMU_INDCP")

									If oDados:XPathHasAtt(cCMUPath)
										cIndOpcCP := oDados:xPathGetAtt( cCMUPath , "indOpcCP" )
										If cIndOpcCP <> ""
											oModel:LoadValue( "MODEL_CMU", "CMU_INDCP", cIndOpcCP )
										EndIf
									EndIf
										/*oDados:XPathHasNode(cCMUPath + "/indOpcCP")
										oModel:LoadValue( "MODEL_CMU", "CMU_INDCP", FTafGetVal( cCMUPath + "/indOpcCP"    , "N", .F., @aIncons, .T. ) )*/
								EndIf
								
								//#################################################
								//���������������������������Ŀ
								//�INICIO CMV - <nfs>�
								//�����������������������������
								//Quando se trata de uma alteracao, deleto todas as linhas do Grid
								If !__lLay0205
									If nOpc == 4
										For nCMV := 1 to oModel:GetModel( "MODEL_CMV" ):Length()
											oModel:GetModel( "MODEL_CMV" ):GoLine(nCMV)
											oModel:GetModel( "MODEL_CMV" ):DeleteLine()
										Next nCMV
									EndIf

									nCMV := 1
									cCMVPath := cCMUPath + "/nfs[" + cValToChar(nCMV) + "]"
									While oDados:XPathHasNode( cCMVPath )

										If nOpc == 4 .Or. nCMV > 1
											// Informa que a linha est� v�lida para que seja inclu�da uma nova linha
											oModel:GetModel( "MODEL_CMV" ):LVALID := .T.
											// Inclui uma linha a cada volta do la�o
											oModel:GetModel( "MODEL_CMV" ):AddLine()
										EndIf

										// Grava dados no model
										If oDados:XPathHasNode(cCMVPath + "/serie")
											oModel:LoadValue( "MODEL_CMV", "CMV_SERIE ", FTafGetVal( cCMVPath + "/serie"           	, "C", .F., @aIncons, .T. ) )
										EndIf
										If oDados:XPathHasNode(cCMVPath + "/nrDocto")
											oModel:LoadValue( "MODEL_CMV", "CMV_NUMDOC", FTafGetVal( cCMVPath + "/nrDocto"        	, "C", .F., @aIncons, .T. ) )
										EndIf
										If oDados:XPathHasNode(cCMVPath + "/dtEmisNF")
											oModel:LoadValue( "MODEL_CMV", "CMV_DTEMIS", FTafGetVal( cCMVPath + "/dtEmisNF"     	, "D", .F., @aIncons, .T. ) )
										EndIf
										If oDados:XPathHasNode(cCMVPath + "/vlrBruto")
											oModel:LoadValue( "MODEL_CMV", "CMV_VLBRUT", FTafGetVal( cCMVPath + "/vlrBruto"     	, "N", .F., @aIncons, .T. ) )
										EndIf
										If oDados:XPathHasNode(cCMVPath + "/vrCPDescPR")
											oModel:LoadValue( "MODEL_CMV", "CMV_VLCONT", FTafGetVal( cCMVPath + "/vrCPDescPR"		, "N", .F., @aIncons, .T. ) )
										EndIf
										If oDados:XPathHasNode(cCMVPath + "/vrRatDescPR")
											oModel:LoadValue( "MODEL_CMV", "CMV_VLGILR", FTafGetVal( cCMVPath + "/vrRatDescPR"		, "N", .F., @aIncons, .T. ) )
										EndIf
										If oDados:XPathHasNode(cCMVPath + "/vrSenarDesc")
											oModel:LoadValue( "MODEL_CMV", "CMV_VLSENA", FTafGetVal( cCMVPath + "/vrSenarDesc"  	, "N", .F., @aIncons, .T. ) )
										EndIf

										nCMV++
										cCMVPath := cCMUPath + "/nfs[" + cValToChar(nCMV) + "]"
									EndDo
								EndIf

								//#################################################
								//���������������������������Ŀ
								//�INICIO T1Z - <infoProcJud>�
								//�����������������������������
								//Quando se trata de uma alteracao, deleto todas as linhas do Grid
								If nOpc == 4
									For nT1Z := 1 to oModel:GetModel( "MODEL_T1Z" ):Length()
										oModel:GetModel( "MODEL_T1Z" ):GoLine(nT1Z)
										oModel:GetModel( "MODEL_T1Z" ):DeleteLine()
									Next nT1Z
								EndIf

								nT1Z := 1
								cT1ZPath := cCMUPath + "/infoProcJud[" + cValToChar(nT1Z) + "]"
								While oDados:XPathHasNode( cT1ZPath )

									If nOpc == 4 .Or. nT1Z > 1
										// Informa que a linha est� v�lida para que seja inclu�da uma nova linha
										oModel:GetModel( "MODEL_T1Z" ):LVALID := .T.
										// Inclui uma linha a cada volta do la�o
										oModel:GetModel( "MODEL_T1Z" ):AddLine()
									EndIf

									// Grava dados no model
									If __lLay0205
										If oDados:XPathHasAtt(cT1ZPath)
											cIdProc := oDados:xPathGetAtt( cT1ZPath , "nrProcJud" )
											cIdProc := FGetIdInt( "", "nrProcJud",,cT1ZPath ,,,@cInconMsg, @nSeqErrGrv,,,,,,, .T.)
											If cIdProc <> "" 
												oModel:LoadValue( "MODEL_T1Z", "T1Z_IDPROC", cIdProc )
											EndIf
										EndIf
									Else
										If oDados:XPathHasNode(cT1ZPath + "/nrProcJud")
											cIdProc := FGetIdInt( "", "nrProcJud",,  cT1ZPath + "/nrProcJud",,,@cInconMsg, @nSeqErrGrv)
											oModel:LoadValue( "MODEL_T1Z", "T1Z_IDPROC", cIdProc)
										EndIf
									EndIf

									If __lLay0205
										If oDados:XPathHasAtt(cT1ZPath)
											cCodSusp := oDados:xPathGetAtt( cT1ZPath , "codSusp" ) 
											cCodSusp := FGetIdInt("codSusp",,cT1ZPath,cIdProc,,,@cInconMsg, @nSeqErrGrv,,,,,,cPeriodo, .T.)
											If cCodSusp <> ""
												oModel:LoadValue( "MODEL_T1Z", "T1Z_IDSUSP", cCodSusp )
											EndIf
										EndIf
									Else
										If oDados:XPathHasNode(cT1ZPath + "/codSusp")
											oModel:LoadValue( "MODEL_T1Z", "T1Z_IDSUSP", FGetIdInt( "codSusp","",FTafGetVal(cT1ZPath + "/codSusp", "C", .F., @aIncons, .F., '', '' ), cIdProc, .F.,, @cInconMsg, @nSeqErrGrv ) )
										EndIf
									EndIf

									If __lLay0205
										If oDados:XPathHasAtt(cT1ZPath)
											cVrCPNRet := oDados:xPathGetAtt( cT1ZPath , "vrCPNRet" )
											If cVrCPNRet <> ""
												oModel:LoadValue( "MODEL_T1Z", "T1Z_VLRPRV", FTafGetVal( cT1ZPath, "N", .F., @aIncons, .T.,,,,,.T., "vrCPNRet") )
											EndIf
										EndIf
									Else
										If oDados:XPathHasNode(cT1ZPath + "/vrCPNRet")
											oModel:LoadValue( "MODEL_T1Z", "T1Z_VLRPRV", FTafGetVal( cT1ZPath + "/vrCPNRet"          , "N", .F., @aIncons, .T. ) )
										EndIf
									EndIf

									If __lLay0205
										If oDados:XPathHasAtt(cT1ZPath)
											cVrRatNRet := oDados:xPathGetAtt( cT1ZPath , "vrRatNRet" )
											If cVrRatNRet <> ""
												oModel:LoadValue( "MODEL_T1Z", "T1Z_VLRRAT", FTafGetVal( cT1ZPath, "N", .F., @aIncons, .T.,,,,,.T., "vrRatNRet") )
											EndIf
										EndIf
									Else
										If oDados:XPathHasNode(cT1ZPath + "/vrRatNRet")
											oModel:LoadValue( "MODEL_T1Z", "T1Z_VLRRAT", FTafGetVal( cT1ZPath + "/vrRatNRet"         , "N", .F., @aIncons, .T. ) )
										EndIf
									EndIf

									If __lLay0205
										If oDados:XPathHasAtt(cT1ZPath)
											cVrSenarNRet := oDados:xPathGetAtt( cT1ZPath , "vrSenarNRet" )
											If cVrSenarNRet <> ""
												oModel:LoadValue( "MODEL_T1Z", "T1Z_VLRSEN", FTafGetVal( cT1ZPath, "N", .F., @aIncons, .T.,,,,,.T., "vrSenarNRet") )
											EndIf
										EndIf
									Else
										If oDados:XPathHasNode(cT1ZPath + "/vrSenarNRet")
											oModel:LoadValue( "MODEL_T1Z", "T1Z_VLRSEN", FTafGetVal( cT1ZPath + "/vrSenarNRet"     	 , "N", .F., @aIncons, .T. ) )
										EndIf
									EndIf

									nT1Z++
									cT1ZPath := cCMUPath + "/infoProcJud[" + cValToChar(nT1Z) + "]"
								EndDo

								nCMU++
								cCMUPath := cCMTPath + "/ideProdutor[" + cValToChar(nCMU) + "]"
							EndDo
							
							//#################################################
							//���������������������������Ŀ 
							//�INICIO V2O - <infoProcJ>�
							//�����������������������������
							//Quando se trata de uma alteracao, deleto todas as linhas do Grid
							If __lLay0205 .And. __lV2O
								If nOpc == 4
									For nV2O := 1 to oModel:GetModel( "MODEL_V2O" ):Length()
										oModel:GetModel( "MODEL_V2O" ):GoLine(nV2O)
										oModel:GetModel( "MODEL_V2O" ):DeleteLine()
									Next nV2O
								EndIf
			
								nV2O := 1
								cV2OPath := cCMTPath + "/infoProcJ[" + cValToChar(nV2O) + "]"
								While oDados:XPathHasNode( cV2OPath )
			
									If nOpc == 4 .Or. nV2O > 1
										// Informa que a linha est� v�lida para que seja inclu�da uma nova linha
										oModel:GetModel( "MODEL_V2O" ):LVALID := .T.
										// Inclui uma linha a cada volta do la�o
										oModel:GetModel( "MODEL_V2O" ):AddLine()
									EndIf
			
									// Grava dados no model

									If oDados:XPathHasAtt(cV2OPath)
										cIdProcV2O := oDados:xPathGetAtt( cV2OPath , "nrProcJud" )
										cIdProcV2O := FGetIdInt( "", "nrProcJud",,cV2OPath ,,,@cInconMsg, @nSeqErrGrv,,,,,,, .T.)
										If cIdProcV2O <> "" 
											oModel:LoadValue( "MODEL_V2O", "V2O_IDPROC", cIdProcV2O )
										EndIf
									EndIf

									If oDados:XPathHasAtt(cV2OPath)
										cCodSuspV2O := oDados:xPathGetAtt( cV2OPath , "codSusp" )
										cCodSuspV2O := FGetIdInt("codSusp",,cV2OPath,cIdProcV2O,,,@cInconMsg, @nSeqErrGrv,,,,,,cPeriodo, .T.)
										If cCodSuspV2O <> "" 
											oModel:LoadValue( "MODEL_V2O", "V2O_IDSUSP", cCodSuspV2O )
										EndIf
									EndIf

									If oDados:XPathHasAtt(cV2OPath)
										cVrCPNRetV2O := oDados:xPathGetAtt( cV2OPath , "vrCPNRet" )
										If cVrCPNRetV2O <> ""
											oModel:LoadValue( "MODEL_V2O", "V2O_VLRPRV", FTafGetVal( cV2OPath, "N", .F., @aIncons, .T.,,,,,.T., "vrCPNRet") )
										EndIf
									EndIf

									If oDados:XPathHasAtt(cV2OPath)
										cVrRatNRetV2O := oDados:xPathGetAtt( cV2OPath , "vrRatNRet" )
										If cVrRatNRetV2O <> ""
											oModel:LoadValue( "MODEL_V2O", "V2O_VLRRAT", FTafGetVal( cV2OPath, "N", .F., @aIncons, .T.,,,,,.T., "vrRatNRet") )
										EndIf
									EndIf

									If oDados:XPathHasAtt(cV2OPath)
										cVrSenarNRetV2O := oDados:xPathGetAtt( cV2OPath , "vrSenarNRet" )
										If cVrSenarNRetV2O <> ""
											oModel:LoadValue( "MODEL_V2O", "V2O_VLRSEN", FTafGetVal( cV2OPath, "N", .F., @aIncons, .T.,,,,,.T., "vrSenarNRet") ) 
										EndIf
									EndIf

									/*If oDados:XPathHasNode(cV2OPath + "/nrProcJud")
										cIdProc := FGetIdInt( "", "nrProcJud",,  cV2OPath + "/nrProcJud",,,@cInconMsg, @nSeqErrGrv)
										oModel:LoadValue( "MODEL_V2O", "V2O_IDPROC", cIdProc)
									EndIf

									If oDados:XPathHasNode(cV2OPath + "/codSusp")
										oModel:LoadValue( "MODEL_V2O", "V2O_IDSUSP", FGetIdInt( "codSusp","",FTafGetVal(cV2OPath + "/codSusp", "C", .F., @aIncons, .F., '', '' ), cIdProc, .F.,, @cInconMsg, @nSeqErrGrv ) )
									EndIf
									If oDados:XPathHasNode(cV2OPath + "/vrCPNRet")
										oModel:LoadValue( "MODEL_V2O", "V2O_VLRPRV", FTafGetVal( cV2OPath + "/vrCPNRet"          , "N", .F., @aIncons, .T. ) )
									EndIf
									If oDados:XPathHasNode(cV2OPath + "/vrRatNRet")
										oModel:LoadValue( "MODEL_V2O", "V2O_VLRRAT", FTafGetVal( cV2OPath + "/vrRatNRet"         , "N", .F., @aIncons, .T. ) )
									EndIf
									If oDados:XPathHasNode(cV2OPath + "/vrSenarNRet")
										oModel:LoadValue( "MODEL_V2O", "V2O_VLRSEN", FTafGetVal( cV2OPath + "/vrSenarNRet"     	 , "N", .F., @aIncons, .T. ) )
									EndIf*/
			
									nV2O++
									cV2OPath := cCMTPath + "/infoProcJ[" + cValToChar(nV2O) + "]"
								EndDo
							EndIf // Fim V2O
						EndIf

						nCMT++
						cCMTPath := cInfEvento + "ideEstabAdquir/tpAquis[" + cValToChar(nCMT) + "]"
				
					EndDo
				EndIF
			EndIf

			//���������������������������Ŀ
			//�Efetiva a operacao desejada�
			//�����������������������������
			If Empty(cInconMsg)
				If TafFormCommit( oModel ) .And. Empty(aIncons)
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

	//����������������������������������������������������������Ŀ
	//�Zerando os arrays e os Objetos utilizados no processamento�
	//������������������������������������������������������������
	aSize( aRules, 0 )
	aRules := Nil

	aSize( aChave, 0 )
	aChave := Nil

	RestArea( aArea )

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF274Rul
Regras para gravacao das informacoes do registro S-1400 do E-Social

@Return
aRull  - Regras para a gravacao das informacoes

@author Anderson Costa
@since 27/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF272Rul( cCodEvent, cOwner )

	Local aRull
	Local cPeriodo

	Default cCodEvent := ""
	Default cOwner    := ""

	aRull             := {}
	cPeriodo          := ""

	//**********************************
	//eSocial/evtComProd/ideEvento/
	//**********************************
	If TafXNode( oDados, cCodEvent, cOwner, ( "/eSocial/evtAqProd/ideEvento/indApuracao" ) )
		Aadd( aRull, { "CMR_INDAPU", "/eSocial/evtAqProd/ideEvento/indApuracao", "C", .F. } )		//indApuracao
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner, ( "/eSocial/evtAqProd/ideEvento/perApur" ) )
		cPeriodo := FTafGetVal("/eSocial/evtAqProd/ideEvento/perApur", "C", .F.,, .F. )
		If At("-", cPeriodo) > 0
			Aadd( aRull, {"CMR_PERAPU", StrTran(cPeriodo, "-", "" ) ,"C",.T.} )
		Else
			Aadd( aRull, {"CMR_PERAPU", cPeriodo ,"C", .T.} )
		EndIf
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner, ( "/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/tpInscAdq" ) )
		Aadd( aRull, { "CMR_TPINSC", "/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/tpInscAdq", "C", .F. } )	//nrInscEstabRural
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner, ( "/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/tpInscAdq" ) )
		Aadd( aRull, { "CMR_INSCES", "/eSocial/evtAqProd/infoAquisProd/ideEstabAdquir/nrInscAdq", "C", .F. } )	//nrInscEstabRural
	EndIF

Return ( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclus�o do evento (S-3000)

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function � chamada pelo TafIntegraESocial

@Return .T.

@author Daniel Schmidt
@since 29/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )

	Local cVerAnt    := ""
	Local cProtocolo := ""
	Local cVersao    := ""
	Local cEvento    := ""
	Local nlI        := 0
	Local nlY        := 0
	Local nCMU       := 0
	Local nCMV       := 0
	Local nCMT       := 0
	Local nT1Z       := 0
	Local nV2O       := 0
	Local aGravaCMU  := {}
	Local aGravaCMT  := {}
	Local aGravaCMR  := {}
	Local aGravaCMV  := {}
	Local aGravaT1Z  := {}
	Local aGravaV2O  := {}
	Local oModelCMR  := Nil
	Local oModelCMT  := Nil
	Local oModelCMU  := Nil
	Local oModelCMV  := Nil
	Local oModelT1Z  := Nil
	Local oModelV2O  := Nil

	Begin Transaction

		//Posiciona o item
		("CMR")->( DBGoTo( nRecno ) )

		oModelCMR := oModel:GetModel( 'MODEL_CMR' )
		oModelCMT := oModel:GetModel( 'MODEL_CMT' )
		oModelCMU := oModel:GetModel( 'MODEL_CMU' )	
		oModelT1Z := oModel:GetModel( 'MODEL_T1Z' )
		If __lLay0205 .And. __lV2O
			oModelV2O := oModel:GetModel( 'MODEL_V2O' )
		Else
			oModelCMV := oModel:GetModel( 'MODEL_CMV' )
		EndIf

		//�����������������������������������������������������������Ŀ
		//�Busco a versao anterior do registro para gravacao do rastro�
		//�������������������������������������������������������������
		cVerAnt    := oModelCMR:GetValue( "CMR_VERSAO" )
		cProtocolo := oModelCMR:GetValue( "CMR_PROTUL" )
		cEvento    := oModelCMR:GetValue( "CMR_EVENTO" )

		//�����������������������������������������������������������������Ŀ
		//�Neste momento eu gravo as informacoes que foram carregadas       �
		//�na tela, pois neste momento o usuario ja fez as modificacoes que �
		//�precisava e as mesmas estao armazenadas em memoria, ou seja,     �
		//�nao devem ser consideradas neste momento                         �
		//�������������������������������������������������������������������
		For nlI := 1 To 1
			For nlY := 1 To Len( oModelCMR:aDataModel[ nlI ] )
				Aadd( aGravaCMR, { oModelCMR:aDataModel[ nlI, nlY, 1 ], oModelCMR:aDataModel[ nlI, nlY, 2 ] } )
			Next
		Next

		For nCMT := 1 To oModel:GetModel( 'MODEL_CMT' ):Length()
			oModel:GetModel( 'MODEL_CMT' ):GoLine(nCMT)

			If !oModel:GetModel( 'MODEL_CMT' ):IsDeleted()
					aAdd (aGravaCMT ,{oModelCMT:GetValue("CMT_INDAQU"),;
									oModelCMT:GetValue("CMT_VLAQUI")} )

				For nCMU := 1 To oModel:GetModel( 'MODEL_CMU' ):Length()
					oModel:GetModel( 'MODEL_CMU' ):GoLine(nCMU)

					If !oModel:GetModel( 'MODEL_CMU' ):IsDeleted()
							aAdd (aGravaCMU ,{oModelCMT:GetValue("CMT_INDAQU"),;
											oModelCMU:GetValue("CMU_TPINSC"),;
											oModelCMU:GetValue("CMU_INSCPR"),;
											oModelCMU:GetValue("CMU_VLBRUT"),;
											oModelCMU:GetValue("CMU_VLCONT"),;
											oModelCMU:GetValue("CMU_VLGILR"),;
											oModelCMU:GetValue("CMU_VLSENA")} )
							If __lLay0205 .And. TafColumnPos("CMU_INDCP")
								aAdd (aGravaCMU[Len(aGravaCMU)] ,oModelCMU:GetValue("CMU_INDCP"))
							EndIf

						If !__lLay0205

							If !oModel:GetModel( 'MODEL_CMV' ):IsEmpty()
								For nCMV := 1 To oModel:GetModel( 'MODEL_CMV' ):Length()
									oModel:GetModel( 'MODEL_CMV' ):GoLine(nCMV)

									If !oModel:GetModel( 'MODEL_CMV' ):IsDeleted()
										aAdd (aGravaCMV ,{oModelCMT:GetValue("CMT_INDAQU"),;
														oModelCMU:GetValue("CMU_INSCPR"),;
														oModelCMV:GetValue("CMV_SERIE"),;
														oModelCMV:GetValue("CMV_NUMDOC"),;
														oModelCMV:GetValue("CMV_DTEMIS"),;
														oModelCMV:GetValue("CMV_VLBRUT"),;
														oModelCMV:GetValue("CMV_VLCONT"),;
														oModelCMV:GetValue("CMV_VLGILR"),;
														oModelCMV:GetValue("CMV_VLSENA")} )
									EndIf

								Next // Fim - CMV
							EndIf

						EndIf
						
						If !oModel:GetModel( 'MODEL_T1Z' ):IsEmpty()
							
							//Grava T1Z
							For nT1Z := 1 To oModel:GetModel( 'MODEL_T1Z' ):Length()
								oModel:GetModel( 'MODEL_T1Z' ):Goline(nT1Z)

								If !oModel:GetModel( 'MODEL_T1Z' ):IsDeleted()
								aAdd (aGravaT1Z ,{	oModelCMT:GetValue("CMT_INDAQU"),;
													oModelCMU:GetValue("CMU_INSCPR"),;
													oModelT1Z:GetValue("T1Z_IDPROC"),;
													oModelT1Z:GetValue("T1Z_CODSUS"),;
													oModelT1Z:GetValue("T1Z_VLRPRV"),;
													oModelT1Z:GetValue("T1Z_VLRRAT"),;
													oModelT1Z:GetValue("T1Z_VLRSEN")} )
								EndIf
							Next // Fim - T1Z
							
						EndIf

					EndIf
				Next // Fim - CMU
				
				//Grava V2O
				If __lLay0205 .And. __lV2O
					If !oModel:GetModel( 'MODEL_V2O' ):IsEmpty()
						For nV2O := 1 To oModel:GetModel( 'MODEL_V2O' ):Length()
							oModel:GetModel( 'MODEL_V2O' ):Goline(nV2O)
			
							If !oModel:GetModel( 'MODEL_V2O' ):IsDeleted()
							aAdd (aGravaV2O ,{	oModelCMT:GetValue("CMT_INDAQU"),;
												oModelV2O:GetValue("V2O_INSCPR"),;
												oModelV2O:GetValue("V2O_IDPROC"),;
												oModelV2O:GetValue("V2O_CODSUS"),;
												oModelV2O:GetValue("V2O_VLRPRV"),;
												oModelV2O:GetValue("V2O_VLRRAT"),;
												oModelV2O:GetValue("V2O_VLRSEN")} )
							EndIf
						Next // Fim - V2O
					EndIf
				EndIf
				
			EndIf		
		Next // Fim - CMT

		//�����������������������������������������������������������Ŀ
		//�Seto o campo como Inativo e gravo a versao do novo registro�
		//�no registro anterior                                       �
		//|                                                           |
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//�������������������������������������������������������������
		FAltRegAnt( 'CMR', '2' )

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
		For nlI := 1 To Len( aGravaCMR )
			oModel:LoadValue( 'MODEL_CMR', aGravaCMR[ nlI, 1 ], aGravaCMR[ nlI, 2 ] )
		Next

		For nCMT := 1 To Len( aGravaCMT )
			oModel:GetModel( 'MODEL_CMT' ):LVALID	:= .T.

			If nCMT > 1
				oModel:GetModel( 'MODEL_CMT' ):AddLine()
			EndIf

			oModel:LoadValue( "MODEL_CMT", "CMT_INDAQU", aGravaCMT[nCMT][1] )
			oModel:LoadValue( "MODEL_CMT", "CMT_VLAQUI", aGravaCMT[nCMT][2] )

			nCMUAdd := 1
			For nCMU := 1 To Len( aGravaCMU )
				// Grava apenas o CMU pertencente ao CMT
				If aGravaCMU[nCMU][1] == aGravaCMT[nCMT][1]
					oModel:GetModel( 'MODEL_CMU' ):LVALID	:= .T.

					If nCMUAdd > 1
						oModel:GetModel( 'MODEL_CMU' ):AddLine()
					EndIf
						oModel:LoadValue( "MODEL_CMU", "CMU_TPINSC", aGravaCMU[nCMU][2] )
						oModel:LoadValue( "MODEL_CMU", "CMU_INSCPR", aGravaCMU[nCMU][3] )
						oModel:LoadValue( "MODEL_CMU", "CMU_VLBRUT", aGravaCMU[nCMU][4] )
						oModel:LoadValue( "MODEL_CMU", "CMU_VLCONT", aGravaCMU[nCMU][5] )
						oModel:LoadValue( "MODEL_CMU", "CMU_VLGILR", aGravaCMU[nCMU][6] )
						oModel:LoadValue( "MODEL_CMU", "CMU_VLSENA", aGravaCMU[nCMU][7] )
						If __lLay0205 .And. TafColumnPos("CMU_INDCP")
							oModel:LoadValue( "MODEL_CMU", "CMU_INDCP", aGravaCMU[nCMU][8] )
						EndIf
						
						If !__lLay0205
							nCMVAdd := 1
							For nCMV := 1 To Len( aGravaCMV )
								// Grava apenas o CMV pertencente ao CMU
								If  aGravaCMV[nCMV][1] == aGravaCMT[nCMT][1] .And. aGravaCMV[nCMV][2] == aGravaCMU[nCMU][3]
									oModel:GetModel( 'MODEL_CMV' ):LVALID	:= .T.
		
									If nCMVAdd > 1
										oModel:GetModel( 'MODEL_CMV' ):AddLine()
									EndIf
										oModel:LoadValue( "MODEL_CMV", "CMV_SERIE", aGravaCMV[nCMV][3] )
										oModel:LoadValue( "MODEL_CMV", "CMV_NUMDOC", aGravaCMV[nCMV][4] )
										oModel:LoadValue( "MODEL_CMV", "CMV_DTEMIS", aGravaCMV[nCMV][5] )
										oModel:LoadValue( "MODEL_CMV", "CMV_VLBRUT", aGravaCMV[nCMV][6] )
										oModel:LoadValue( "MODEL_CMV", "CMV_VLCONT", aGravaCMV[nCMV][7] )
										oModel:LoadValue( "MODEL_CMV", "CMV_VLGILR", aGravaCMV[nCMV][8] )
										oModel:LoadValue( "MODEL_CMV", "CMV_VLSENA", aGravaCMV[nCMV][9] )
		
									nCMVAdd++
								EndIf
							Next // Fim - CMV
						EndIf

						nT1ZAdd := 1
						For nT1Z := 1 To Len( aGravaT1Z )
							// Grava apenas o T1Z pertencente ao CMU
							If aGravaT1Z[nT1Z][1] == aGravaCMT[nCMT][1] .And. aGravaT1Z[nT1Z][2] == aGravaCMU[nCMU][3]
								oModel:GetModel( 'MODEL_T1Z' ):LVALID	:= .T.

								If nT1ZAdd > 1
									oModel:GetModel( 'MODEL_T1Z' ):AddLine()
								EndIf
									oModel:LoadValue( "MODEL_T1Z", "T1Z_IDPROC", aGravaT1Z[nT1Z][3] )
									oModel:LoadValue( "MODEL_T1Z", "T1Z_CODSUS", aGravaT1Z[nT1Z][4] )
									oModel:LoadValue( "MODEL_T1Z", "T1Z_VLRPRV", aGravaT1Z[nT1Z][5] )
									oModel:LoadValue( "MODEL_T1Z", "T1Z_VLRRAT", aGravaT1Z[nT1Z][6] )
									oModel:LoadValue( "MODEL_T1Z", "T1Z_VLRSEN", aGravaT1Z[nT1Z][7] )

								nT1ZAdd++
							EndIf
						Next // Fim - T1Z

					nCMUAdd++
				EndIf
			Next // Fim - CMU
			
			If __lLay0205 .And. __lV2O
				nV2OAdd := 1
				For nV2O := 1 To Len( aGravaV2O )
					// Grava apenas o V2O pertencente ao CMT
					If aGravaV2O[nV2O][1] == aGravaCMT[nCMT][1] 
						oModel:GetModel( 'MODEL_V2O' ):LVALID	:= .T.
		
						If nV2OAdd > 1
							oModel:GetModel( 'MODEL_V2O' ):AddLine()
						EndIf
							oModel:LoadValue( "MODEL_V2O", "V2O_IDPROC", aGravaV2O[nV2O][3] )
							oModel:LoadValue( "MODEL_V2O", "V2O_CODSUS", aGravaV2O[nV2O][4] )
							oModel:LoadValue( "MODEL_V2O", "V2O_VLRPRV", aGravaV2O[nV2O][5] )
							oModel:LoadValue( "MODEL_V2O", "V2O_VLRRAT", aGravaV2O[nV2O][6] )
							oModel:LoadValue( "MODEL_V2O", "V2O_VLRSEN", aGravaV2O[nV2O][7] )
		
						nV2OAdd++
					EndIf
				Next // Fim - V2O
			EndIf
			
		Next // Fim - CMT

		//�������������������������������Ŀ
		//�Busco a versao que sera gravada�
		//���������������������������������
		cVersao := xFunGetVer()

		//�����������������������������������������������������������Ŀ
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//�������������������������������������������������������������
		oModel:LoadValue( 'MODEL_CMR', 'CMR_VERSAO', cVersao )
		oModel:LoadValue( 'MODEL_CMR', 'CMR_VERANT', cVerAnt )
		oModel:LoadValue( 'MODEL_CMR', 'CMR_PROTPN', cProtocolo )
		oModel:LoadValue( 'MODEL_CMR', 'CMR_PROTUL', "" )

		/*---------------------------------------------------------
		Tratamento para que caso o Evento Anterior fosse de exclus�o
		seta-se o novo evento como uma "nova inclus�o", caso contr�rio o
		evento passar a ser uma altera��o
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_CMR", "CMR_EVENTO", "E" )
		oModel:LoadValue( "MODEL_CMR", "CMR_ATIVO", "1" )

		FwFormCommit( oModel )
		TAFAltStat( 'CMR',"6" )

	End Transaction

Return ( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpDataNF
Fun��o respons�vel por realizar importa��o de Notas Fiscais para
Consumidor / Comerciante Rural.
Eventos : S-2150

@author Ricardo
@since 23/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function ImpDataNF()

	Local cIndApu   := ""
	Local cPerApur  := ""   //oModel:GetModel('MODEL_CMR'):GetValue("CMR_PERAPU") -- Remodelando 
	Local aPerg     := {}
	Local aPergRets := {}
	Local lContinua := .F.

	aAdd(aPerg, {2, "Ind Per�odo de Apura��o", "1", {"1 - Mensal"}, 50, ".T.", .T. })
	aAdd(aPerg, {1, "Per�odo de Apura��o",Space(06),"@R 9999-99", ".T.",,, 50, .T.})

	lContinua := ParamBox(aPerg, "Filtros", @aPergRets)

	If lContinua

		cIndApu     := SubStr(aPergRets[1],1,1)
		cPerApur    := aPergRets[2]

		If !Empty(cPerApur)

			FwMsgRun(, { || ImportDocs(cPerApur, cIndApu) }, "Gerando evento(s) S-1250...", "Aguarde")
					
			MsgAlert(STR0023)//"Processo de Importa��o de Notas Fiscais Conclu�do"
		Else
			MsgAlert(STR0024)//" Informar o periodo para importa��o das Notas Fiscais( Per.Apura��o )"
		EndIf

	EndIf

Return(.T.)

/*/{Protheus.doc} ImportDocs
Rotina para carregar as grids do evento S-1250 de acordo com o novo layout 2.5 do E-Social
@type  Function
@author Diego Santos
@since 17-07-2019
@version 1.0
@param cPerApur, character, Per�odo de Apura��o
@return Nil
/*/
Function ImportDocs(cPerApur, cIndApu)

	Local cTemp      := GetNextAlias()
	Local cQuery     := ""
	Local cTipoDoc   := ""
	Local cNumeDoc   := ""
	Local cSubStr    := IIF(TcGetDb() $ "ORACLE|DB2", "SUBSTR", "SUBSTRING")
	Local lIncrPrCMU := .F.
	Local nCMU       := 1
	Local nCMT       := 1
	Local cTpInsc	 := ""
	Local cInscEs	 := ""
	Local cPAA       := ""
	Local oMod1250   := Nil
	Local oModCMT    := Nil
	Local oModCMR    := Nil
	Local oModCMU    := Nil
	Local oModT1Z    := Nil
	Local oModV2O    := Nil

	Default cPerApur := ""

	cQuery := "SELECT C1H.C1H_FILIAL,"

	If TAFColumnPos("C1H_PAA")
		cQuery +=   " C1H.C1H_PAA," // Criar Campo na Totvs - ATUSX
	EndIf

	cQuery +=       " C1H.C1H_INDCP,"
	cQuery +=       " C1H.C1H_CNPJ,"
	cQuery +=       " C1H.C1H_CPF,"
	cQuery +=       " C1H.C1H_ID,"
	cQuery +=       " C30.C30_INDISE,"
	cQuery +=       " SUM(C30.C30_VLOPER) AS VLTOT,"

	cQuery +=	 "( SELECT SUM(C35.C35_VALOR) "
	cQuery += 	" FROM " + RetSqlName( 'C35' ) + " C35"
	cQuery += " INNER JOIN " + RetSqlName( 'C20' ) + " C20"
	cQuery +=    " ON C20.C20_CHVNF = C35.C35_CHVNF "
	cQuery += " WHERE C35.C35_FILIAL = '" + xFilial('C35') + "'"
	cQuery +=   " AND C35.C35_CODTRI = '000013'"
	cQuery +=   " AND " + cSubStr + "(C20.C20_DTDOC,1,6) >= '" + cPerApur + "'"
	cQuery +=   " AND " + cSubStr + "(C20.C20_DTDOC,1,6) <= '" + cPerApur + "'"
	cQuery +=   " AND C20.C20_CODPAR = C1H.C1H_ID"
	cQuery +=   " AND (C20.C20_CODSIT <> '000003' AND C20.C20_CODSIT <> '000004' AND C20.C20_CODSIT <> '000005' AND C20.C20_CODSIT <> '000006') " //Canceladas/Inutilizadas
	cQuery +=   " AND C20.C20_INDOPE = '0'" //Entrada
	cQuery +=   " AND C35.D_E_L_E_T_ <> '*')"
	cQuery +=  " AS CONTPR,"

	cQuery +=	 "( SELECT SUM(C35.C35_VALOR) "
	cQuery += 	" FROM " + RetSqlName( 'C35' ) + " C35"
	cQuery += " INNER JOIN " + RetSqlName( 'C20' ) + " C20"
	cQuery +=    " ON C20.C20_CHVNF = C35.C35_CHVNF "
	cQuery += " WHERE C35.C35_FILIAL = '" + xFilial('C35') + "'"
	cQuery +=   " AND C35.C35_CODTRI = '000024'"
	cQuery +=   " AND " + cSubStr + "(C20.C20_DTDOC,1,6) >= '" + cPerApur + "'"
	cQuery +=   " AND " + cSubStr + "(C20.C20_DTDOC,1,6) <= '" + cPerApur + "'"
	cQuery +=   " AND C20.C20_CODPAR = C1H.C1H_ID"
	cQuery +=   " AND (C20.C20_CODSIT <> '000003' AND C20.C20_CODSIT <> '000004' AND C20.C20_CODSIT <> '000005' AND C20.C20_CODSIT <> '000006') " //Canceladas/Inutilizadas
	cQuery +=   " AND C20.C20_INDOPE = '0'" //Entrada
	cQuery +=   " AND C35.D_E_L_E_T_ <> '*')"
	cQuery +=  " AS GILRAT,"

	cQuery +=	 "( SELECT SUM(C35.C35_VALOR) "
	cQuery += 	" FROM " + RetSqlName( 'C35' ) + " C35"
	cQuery += " INNER JOIN " + RetSqlName( 'C20' ) + " C20"
	cQuery +=    " ON C20.C20_CHVNF = C35.C35_CHVNF "
	cQuery += " WHERE C35.C35_FILIAL = '" + xFilial('C35') + "'"
	cQuery +=   " AND C35.C35_CODTRI = '000025'"
	cQuery +=   " AND " + cSubStr + "(C20.C20_DTDOC,1,6) >= '" + cPerApur + "'"
	cQuery +=   " AND " + cSubStr + "(C20.C20_DTDOC,1,6) <= '" + cPerApur + "'"
	cQuery +=   " AND C20.C20_CODPAR = C1H.C1H_ID"
	cQuery +=   " AND (C20.C20_CODSIT <> '000003' AND C20.C20_CODSIT <> '000004' AND C20.C20_CODSIT <> '000005' AND C20.C20_CODSIT <> '000006') " //Canceladas/Inutilizadas
	cQuery +=   " AND C20.C20_INDOPE = '0'" //Entrada
	cQuery +=   " AND C35.D_E_L_E_T_ <> '*')"
	cQuery +=  " AS SENAR"

	cQuery +=  " FROM " + RetSqlName( 'C20' ) + " C20"
	cQuery += " INNER JOIN " + RetSqlName( 'C1H' ) + " C1H"
	cQuery +=    " ON C1H.C1H_FILIAL = '" + xFilial('C1H') + "'"
	cQuery +=  	" AND C1H.C1H_ID     = C20.C20_CODPAR"
	cQuery += 	" AND C1H.C1H_RAMO   = '4'"
	cQuery += 	" AND C1H.D_E_L_E_T_ <> '*' "

	cQuery += 	"INNER JOIN " + RetSqlName( 'C30' ) + " C30 "
	cQuery += 	"    ON C30.C30_FILIAL = '" + xFilial('C30') + "' "
	cQuery += 	"       AND C30.C30_CHVNF = C20.C20_CHVNF "
	cQuery += 	"       AND C30.D_E_L_E_T_ <> '*'"

	cQuery += " WHERE C20.C20_FILIAL = '" + xFilial('C20') + "'"
	cQuery +=   " AND C20.C20_INDOPE = '0'" //Entrada
	cQuery +=   " AND " + cSubStr + "(C20.C20_DTDOC,1,6) >= '" + cPerApur + "'"
	cQuery +=   " AND " + cSubStr + "(C20.C20_DTDOC,1,6) <= '" + cPerApur + "'"
	cQuery +=   " AND (C20.C20_CODSIT <> '000003' AND C20.C20_CODSIT <> '000004' AND C20.C20_CODSIT <> '000005' AND C20.C20_CODSIT <> '000006') " //Canceladas/Inutilizadas
	cQuery +=   " AND C20.D_E_L_E_T_ <> '*' "
	cQuery +=   " AND EXISTS (SELECT 1"
	cQuery +=                 " FROM " + RetSqlName('C35') + " C35"
	cQuery +=                " WHERE C35.C35_FILIAL = '" + xFilial('C35') + "'"
	cQuery +=                  " AND C30.C30_CHVNF  = C35.C35_CHVNF"
	cQuery +=                  " AND C30.C30_NUMITE  = C35.C35_NUMITE"
	cQuery +=                  " AND C35.C35_CODTRI IN ('000013','000024','000025')"
	cQuery +=                  " AND C35.D_E_L_E_T_ <> '*' )"

	cQuery +=   " AND NOT EXISTS (SELECT * FROM  " + RetSqlName('CMU') + " CMU"
	cQuery +=                   " INNER JOIN " + RetSqlName('CMR') + " CMR"
	cQuery +=                   " ON    CMR.CMR_FILIAL = '" + xFilial('CMR') + "' "
	cQuery +=                   " AND   CMR.CMR_PERAPU = '" + cPerApur + "'"
	cQuery +=                   " AND   CMR.CMR_ID = CMU.CMU_ID"
	cQuery +=                   " AND   CMR.CMR_EVENTO <> 'E'"
	cQuery +=                   " AND   CMR.CMR_ATIVO  = '1'"
	cQuery +=                   " AND   CMR.D_E_L_E_T_ = ''"
	cQuery +=                   " WHERE CMU.CMU_FILIAL = '" + xFilial('CMU') + "' "
	cQuery +=                   " AND   CMU.D_E_L_E_T_ = ''"
	cQuery +=                   " AND  (CMU.CMU_INSCPR = C1H_CPF OR CMU.CMU_INSCPR = C1H_CNPJ))"

	cQuery += " GROUP BY C1H.C1H_FILIAL,"

	If TAFColumnPos("C1H_PAA")
		cQuery += " C1H.C1H_PAA," // Criar Campo na Totvs - ATUSX
	EndIf

	cQuery +=          " C1H.C1H_INDCP,"
	cQuery +=          " C1H.C1H_CNPJ,"
	cQuery +=          " C1H.C1H_CPF,"
	cQuery +=          " C1H.C1H_ID,"
	cQuery +=          " C30.C30_INDISE, "
	cQuery +=          " C20.C20_CODPAR "

	// Executa a Query.
	DBUseArea( .T., "TOPCONN", TCGenQry( ,, ChangeQuery( cQuery ) ), cTemp, .F., .T. )

	If (cTemp)->(!Eof())

		Begin Transaction

			While ( cTemp )->( !Eof() )

				If (cTemp)->CONTPR > 0 .Or. (cTemp)->GILRAT > 0 .Or. (cTemp)->SENAR > 0

					If ValType(oMod1250) == "U" .Or. nCMU > QTDMAX_PRODRURAIS

						If ValType(oMod1250) <> "U"
							nCMU := 1
							nCMT := 1
							FwFormCommit(oMod1250)
							oMod1250:DeActivate()
						EndIf

						oMod1250   := FwLoadModel("TAFA272")
						oModCMT    := oMod1250:GetModel( 'MODEL_CMT' )
						oModCMR    := oMod1250:GetModel( 'MODEL_CMR' )
						oModCMU    := oMod1250:GetModel( 'MODEL_CMU' )
						oModT1Z    := oMod1250:GetModel( 'MODEL_T1Z' )   
						oModV2O    := oMod1250:GetModel( 'MODEL_V2O' )

						oMod1250:SetOperation( 3 )
						oMod1250:Activate()
						oMod1250:LoadValue( "MODEL_CMR", "CMR_VERSAO"   , xFunGetVer() )
						oMod1250:LoadValue( "MODEL_CMR", "CMR_INDAPU"   , cIndApu )
						oMod1250:LoadValue( "MODEL_CMR", "CMR_PERAPU"   , cPerApur )
					EndIf

					cTpInsc := oMod1250:GetModel( 'MODEL_CMR' ):GetValue("CMR_TPINSC")
					cInscEs := oMod1250:GetModel( 'MODEL_CMR' ):GetValue("CMR_INSCES")

					cPAA := RetPAA(cInscEs,cTpInsc)

					cTipoPart   := ""
					cTipoDoc	:= ""

					If Empty((cTemp)->C1H_CPF) .AND. !Empty((cTemp)->C1H_CNPJ)
						
						//-- Pessoa jur�dica
						If TAFColumnPos("C1E_PAA")
							If cPAA == '1' .AND. (cTemp)->C30_INDISE <> "1"
								cTipoPart   := "3"
								cNumeDoc    := (cTemp)->C1H_CNPJ	
								cTipoDoc    := "1"	
							Else
								If (cTemp)->C30_INDISE == "1" .AND. (cPAA == "1")
									cTipoPart := "6"
									cNumeDoc  := (cTemp)->C1H_CNPJ
									cTipoDoc := "1"	
								EndIf	
							EndIf
						Else	
							cTipoPart := "3"
							cNumeDoc  := (cTemp)->C1H_CNPJ
							cTipoDoc := "1"		
						EndIf

					Else
					
						//-- Produtor pessoa f�sica
						If cPAA == "1" .AND. (cTemp)->C30_INDISE <> "1"
							cTipoPart := "2"
							cNumeDoc  := (cTemp)->C1H_CPF
							cTipoDoc := "2"
						Else
							cTipoPart := "1"
							cNumeDoc  := (cTemp)->C1H_CPF
							cTipoDoc := "2"			
						EndIf		

						If (cTemp)->C30_INDISE == "1"  .AND. cPAA <> "1" 
							cTipoPart := "4"
							cNumeDoc  := (cTemp)->C1H_CPF
							cTipoDoc := "2"			
						EndIf

						If (cTemp)->C30_INDISE == "1" .AND. (cPAA == "1") 
							cTipoPart := "5"
							cNumeDoc  := (cTemp)->C1H_CPF
							cTipoDoc := "2"						
						EndIf

					EndIf 

					If !Empty(cTipoPart)

						If !oMod1250:GetModel( 'MODEL_CMT' ):SeekLine( { { "CMT_INDAQU", cTipoPart } }, .F., .T. ) .AND. nCMT > 1
							oMod1250:GetModel( 'MODEL_CMT' ):AddLine()
							oMod1250:LoadValue( "MODEL_CMT", "CMT_INDAQU", cTipoPart )
						Else
							oMod1250:LoadValue( "MODEL_CMT", "CMT_INDAQU", cTipoPart )
						EndIf
						
						oMod1250:GetModel( 'MODEL_CMT' ):SeekLine( { { "CMT_INDAQU", cTipoPart } }, .F., .T. )
						oMod1250:LoadValue( "MODEL_CMT", "CMT_VLAQUI", oMod1250:GetValue( "MODEL_CMT", "CMT_VLAQUI") + (cTemp)->VLTOT )

						lIncrPrCMU := .F.
						If oMod1250:GetModel( 'MODEL_CMU' ):SeekLine( { { "CMU_INSCPR", cNumeDoc } }, .F., .T. )
							lIncrPrCMU := .T.
						EndIf

						If !oMod1250:GetModel( 'MODEL_CMU' ):IsEmpty() .AND. !lIncrPrCMU
							oMod1250:GetModel( 'MODEL_CMU' ):AddLine()
						EndIf

						oMod1250:LoadValue( "MODEL_CMU", "CMU_TPINSC", cTipoDoc )
						oMod1250:LoadValue( "MODEL_CMU", "CMU_INSCPR", cNumeDoc )
						oMod1250:LoadValue( "MODEL_CMU", "CMU_VLBRUT", oMod1250:GetValue( "MODEL_CMU", "CMU_VLBRUT") + (cTemp)->VLTOT )
						oMod1250:LoadValue( "MODEL_CMU", "CMU_VLCONT", oMod1250:GetValue( "MODEL_CMU", "CMU_VLCONT") + (cTemp)->CONTPR )
						oMod1250:LoadValue( "MODEL_CMU", "CMU_VLGILR", oMod1250:GetValue( "MODEL_CMU", "CMU_VLGILR") + (cTemp)->GILRAT)
						oMod1250:LoadValue( "MODEL_CMU", "CMU_VLSENA", oMod1250:GetValue( "MODEL_CMU", "CMU_VLSENA") + (cTemp)->SENAR)
						
						If TAFColumnPos("C1H_INDCP")
							oMod1250:LoadValue( "MODEL_CMU", "CMU_INDCP", (cTemp)->C1H_INDCP)
						EndIf
						
					EndIf

					nCMT++		
					nCMU++       

				EndIf

				( cTemp )->( dbSkip() )

			End

			//Ultimo commit ap�s terminar o processo
			FwFormCommit(oMod1250)
			oMod1250:DeActivate()

			(cTemp)->( DBCloseArea() )

		End Transaction

	EndIf

	FwMsgRun(, { || ImpRelS1250(cPerApur, cIndApu, cInscEs, cTpInsc) }, "Gerando relat�rio de notas do(s) evento(s) S-1250...", "Aguarde")

Return(Nil)

/*/{Protheus.doc} ImpRelS1250
Relat�rio de impress�o das notas importadas para o(s)
evento(s) S-1250 gerados atrav�s da rotina de Busca Docs Fiscais
@type  Function
@author Diego Santos
@since 18-07-2019
@version 1.0
@param aCgc, array, arrays com os CPF/CNPJ contidos no evento S-1250
@param cPerApur, character, Periodo de Apura��o na qual os eventos foram gerados
@param cIndApu, character, Indicativo de periodo de apura��o Ex.: Mensal, Anual.
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function ImpRelS1250(cPerApur, cIndApu, cInsc, cTpInsc)

	Local cTemp      := GetNextAlias()
	Local cQuery     := ""
	Local cSubStr    := IIF(TcGetDb() $ "ORACLE|DB2", "SUBSTR", "SUBSTRING")
	Local cTipoDoc   := ""
	Local cTipoPart  := ""
	Local cNumeDoc   := ""
	Local nCont      := 1
	Local cDefPath   := GetSrvProfString( "StartPath", "\system\" )
	Local cPAA       := ""
	Local cDscTpPart := ""
	Local oExcel     := FWMSExcel():New()
	Local oExcelApp  := Nil
	Local cData      := DToS( MsDate() )
	Local cArquivo   := "REL_S-1250_" + cPerApur + "_" + cIndApu + "_" + cData + "_" + StrTran( Time(), ":", "" ) + ".XLS" //
	Local cAba       := "Periodo_" + cPerApur + "_" + cInsc
	Local cTabela    := "Aquisi��o PAA"
	Local nValAqPJ   := 0
	Local nValAqPF   := 0
	Local nValCPJ    := 0
	Local nValGPJ    := 0
	Local nValSPJ    := 0
	Local nValCPF    := 0
	Local nValGPF    := 0
	Local nValSPF    := 0
	Local aNotasPF   := {}
	Local aNotasPJ   := {}
	Local nPosDoc    := 0

	cQuery := "SELECT C20.C20_FILIAL,"
	cQuery +=       " C20.C20_CHVNF,"
	cQuery +=       " C20.C20_SERIE,"
	cQuery +=       " C20.C20_NUMDOC,"
	cQuery +=       " C20.C20_DTDOC,"
	cQuery +=       " C30.C30_INDISE,"
	cQuery +=       " C20.C20_DTES,"
	cQuery +=       " C30.C30_VLOPER,"
	cQuery +=       " (SELECT SUM(TRIB.C35_VALOR) FROM " + RetSqlName( 'C35' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND TRIB.C35_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_ <> '*' AND C3S.C3S_CODIGO='13' AND TRIB.C35_FILIAL=C20.C20_FILIAL AND TRIB.C35_CHVNF=C20.C20_CHVNF AND TRIB.C35_NUMITE=C30.C30_NUMITE AND TRIB.D_E_L_E_T_ <> '*') CONTPR,"
	cQuery +=       " (SELECT SUM(TRIB.C35_VALOR) FROM " + RetSqlName( 'C35' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND TRIB.C35_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_ <> '*' AND C3S.C3S_CODIGO='24' AND TRIB.C35_FILIAL=C20.C20_FILIAL AND TRIB.C35_CHVNF=C20.C20_CHVNF AND TRIB.C35_NUMITE=C30.C30_NUMITE AND TRIB.D_E_L_E_T_ <> '*') GILRAT,"
	cQuery +=       " (SELECT SUM(TRIB.C35_VALOR) FROM " + RetSqlName( 'C35' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND TRIB.C35_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_ <> '*' AND C3S.C3S_CODIGO='25' AND TRIB.C35_FILIAL=C20.C20_FILIAL AND TRIB.C35_CHVNF=C20.C20_CHVNF AND TRIB.C35_NUMITE=C30.C30_NUMITE AND TRIB.D_E_L_E_T_ <> '*') SENAR,"
	cQuery +=       " C1H.C1H_CNPJ,"
	cQuery +=       " C1H.C1H_CPF"

	If TAFColumnPos("C1H_PAA")
		cQuery +=  ", C1H.C1H_PAA"
	EndIf

	cQuery +=  " FROM " + RetSqlName( 'C20' ) + " C20"
	cQuery += " INNER JOIN " + RetSqlName( 'C1H' ) + " C1H"
	cQuery +=    " ON C1H.C1H_FILIAL = '" + xFilial('C1H') + "'"
	cQuery +=   " AND C1H.C1H_ID     = C20.C20_CODPAR"
	cQuery +=   " AND C1H.C1H_RAMO   = '4'"
	cQuery +=   " AND C1H.D_E_L_E_T_ <> '*' "

	cQuery += 	"INNER JOIN " + RetSqlName( 'C30' ) + " C30 "
	cQuery += 	"    ON C30.C30_FILIAL = '" + xFilial('C30') + "' "
	cQuery += 	"       AND C30.C30_CHVNF = C20.C20_CHVNF "
	cQuery += 	"       AND C30.D_E_L_E_T_ <> '*' "

	cQuery += " WHERE C20.C20_FILIAL = '" + xFilial('C20') + "'"
	cQuery +=   " AND C20.C20_INDOPE = '0' " //Entrada
	cQuery +=   " AND " + cSubStr + "(C20.C20_DTDOC,1,6) >= '" + cPerApur + "'"
	cQuery +=   " AND " + cSubStr + "(C20.C20_DTDOC,1,6) <= '" + cPerApur + "'"
	cQuery +=   " AND (C20.C20_CODSIT <> '000003' AND C20.C20_CODSIT <> '000004' AND C20.C20_CODSIT <> '000005' AND C20.C20_CODSIT <> '000006') " //Canceladas/Denegadas/Inutilizadas
	cQuery += 	" AND C20.D_E_L_E_T_ <> '*'"
	cQuery +=   " AND EXISTS (SELECT 1"
	cQuery +=                 " FROM " + RetSqlName('C35') + " C35"
	cQuery +=                " WHERE C35.C35_FILIAL = '" + xFilial('C35') + "'"
	cQuery +=                  " AND C20.C20_CHVNF  = C35.C35_CHVNF"
	cQuery +=                  " AND C35.C35_CODTRI IN ('000013','000024','000025')"
	cQuery +=                  " AND C35.D_E_L_E_T_ <> '*' )"

	// Executa a Query.
	DBUseArea( .T., "TOPCONN", TCGenQry( ,, ChangeQuery( cQuery ) ), cTemp, .F., .T. )

	cPath := cGetFile( "Diret�rio" + "|*.*", "Procurar", 0,, .T., GETF_LOCALHARD + GETF_RETDIRECTORY, .T., )
	If Empty( cPath )
		MsgAlert( "Diret�rio n�o selecionado!" )
	Else
		If (cTemp)->(!Eof())

			While (cTemp)->(!Eof())

				cDscTpPart := ""

				If (cTemp)->CONTPR > 0 .Or. (cTemp)->GILRAT > 0 .Or. (cTemp)->SENAR > 0

					cPAA := RetPAA(cInsc,cTpInsc)

					cTipoPart   := ""
					cTipoDoc	:= ""

					If Empty((cTemp)->C1H_CPF) .AND. !Empty((cTemp)->C1H_CNPJ)
						
						//-- Pessoa jur�dica
						If TAFColumnPos("C1E_PAA")
							If cPAA == '1' .AND. (cTemp)->C30_INDISE <> "1"
								cTipoPart   := "3"
								cNumeDoc    := (cTemp)->C1H_CNPJ	
								cTipoDoc    := "1"	
							Else
								If (cTemp)->C30_INDISE == "1" .AND. (cPAA == "1")
									cTipoPart := "6"
									cNumeDoc  := (cTemp)->C1H_CNPJ
									cTipoDoc := "1"	
								EndIf	
							EndIf
						Else	
							cTipoPart := "3"
							cNumeDoc  := (cTemp)->C1H_CNPJ
							cTipoDoc := "1"		
						EndIf

					Else
					
						//-- Produtor pessoa f�sica
						If cPAA == "1" .AND. (cTemp)->C30_INDISE <> "1"
							cTipoPart := "2"
							cNumeDoc  := (cTemp)->C1H_CPF
							cTipoDoc := "2"
						Else
							cTipoPart := "1"
							cNumeDoc  := (cTemp)->C1H_CPF
							cTipoDoc := "2"			
						EndIf		

						If (cTemp)->C30_INDISE == "1"  .AND. cPAA <> "1" 
							cTipoPart := "4"
							cNumeDoc  := (cTemp)->C1H_CPF
							cTipoDoc := "2"			
						EndIf

						If (cTemp)->C30_INDISE == "1" .AND. (cPAA == "1") 
							cTipoPart := "5"
							cNumeDoc  := (cTemp)->C1H_CPF
							cTipoDoc := "2"						
						EndIf

					EndIf
					
					If !Empty(cTipoPart)

						cDscTpPart := X3COMBO("CMT_INDAQU",cTipoPart)

						If !Empty((cTemp)->C1H_CPF)
							nValAqPF += (cTemp)->(C30_VLOPER)
							nValCPF  += (cTemp)->(CONTPR)
							nValGPF  += (cTemp)->(GILRAT)
							nValSPF  += (cTemp)->(SENAR)
							nPosDoc := aScan(aNotasPF, {|aX| Alltrim(aX[1]+aX[3])==Alltrim((cTemp)->(C1H_CPF+C20_NUMDOC))})
							If nPosDoc == 0
								aAdd(aNotasPF, {    (cTemp)->C1H_CPF,;
													(cTemp)->C20_NUMDOC,;
													(cTemp)->C20_SERIE ,; 
													DtoC(StoD((cTemp)->C20_DTDOC)),; 
													(cTemp)->CONTPR,; 
													(cTemp)->GILRAT,; 
													(cTemp)->SENAR,; 
													(cTemp)->(C30_VLOPER),;
													cDscTpPart } )
							Else
								aNotasPF[nPosDoc][Len(aNotasPF[nPosDoc])-3] += (cTemp)->CONTPR 
								aNotasPF[nPosDoc][Len(aNotasPF[nPosDoc])-2] += (cTemp)->GILRAT
								aNotasPF[nPosDoc][Len(aNotasPF[nPosDoc])-1] += (cTemp)->SENAR
								aNotasPF[nPosDoc][Len(aNotasPF[nPosDoc])]   += (cTemp)->(C30_VLOPER)
							EndIf
							nPosDoc := 0
						ElseIf !Empty((cTemp)->C1H_CNPJ)
							nValAqPJ += (cTemp)->(C30_VLOPER)
							nValCPJ  += (cTemp)->(CONTPR)
							nValGPJ  += (cTemp)->(GILRAT)
							nValSPJ  += (cTemp)->(SENAR)
							nPosDoc := aScan(aNotasPJ, {|aX| Alltrim(aX[1]+aX[3])==Alltrim((cTemp)->(C1H_CNPJ+C20_NUMDOC))})
							If nPosDoc == 0
								aAdd(aNotasPJ, {    (cTemp)->C1H_CNPJ,; 
													(cTemp)->C20_NUMDOC,; 
													(cTemp)->C20_SERIE, ;
													DtoC(StoD((cTemp)->C20_DTDOC)),;
													(cTemp)->CONTPR,; 
													(cTemp)->GILRAT,; 
													(cTemp)->SENAR,; 
													(cTemp)->(C30_VLOPER),;
													cDscTpPart } )
							Else
								aNotasPJ[nPosDoc][Len(aNotasPJ[nPosDoc])-3] += (cTemp)->CONTPR 
								aNotasPJ[nPosDoc][Len(aNotasPJ[nPosDoc])-2] += (cTemp)->GILRAT
								aNotasPJ[nPosDoc][Len(aNotasPJ[nPosDoc])-1] += (cTemp)->SENAR
								aNotasPJ[nPosDoc][Len(aNotasPJ[nPosDoc])]   += (cTemp)->(C30_VLOPER)
							EndIf
							nPosDoc := 0                
						EndIf

					EndIf

				EndIf
				(cTemp)->(DbSkip())
			End

			oExcel:AddWorkSheet( cAba )
			oExcel:AddTable( cAba, cTabela )

			oExcel:AddColumn( cAba, cTabela, "Tipo Aquisi��o PAA"           , 1, 1, .F. )
			oExcel:AddColumn( cAba, cTabela, "CNPJ/ CPF"                    , 1, 1, .F. )
			oExcel:AddColumn( cAba, cTabela, "N�mero do Documento"          , 1, 1, .F. )
			oExcel:AddColumn( cAba, cTabela, "S�rie do Documento"           , 1, 1, .F. )
			oExcel:AddColumn( cAba, cTabela, "Data de Emiss�o"              , 1, 1, .F. )

			oExcel:AddColumn( cAba, cTabela, "Valor Contr"                  , 1, 2, .F. )        
			oExcel:AddColumn( cAba, cTabela, "Valor GilRat"                 , 1, 2, .F. )
			oExcel:AddColumn( cAba, cTabela, "Valor Senar"                  , 1, 2, .F. )
			oExcel:AddColumn( cAba, cTabela, "Valor Bruto do Documento"     , 1, 2, .F. )

			For nCont := 1 To Len(aNotasPJ)

				oExcel:AddRow(	cAba,;
								cTabela,;
								{	aNotasPJ[nCont][9],; //"Aquisi��o produtor rural PJ por Entidade PAA - Produ��o Isenta (Lei 13.606/2018)",;
									aNotasPJ[nCont][1],;
									aNotasPJ[nCont][2],;
									aNotasPJ[nCont][3],;
									aNotasPJ[nCont][4],;
									aNotasPJ[nCont][5],;
									aNotasPJ[nCont][6],;
									aNotasPJ[nCont][7],;
									aNotasPJ[nCont][8] })        						

			Next nCont

			For nCont := 1 To Len(aNotasPF)

				oExcel:AddRow(	cAba,;
								cTabela,;
								{	aNotasPF[nCont][9],; //"Aquisi��o produtor rural PF por entidade PAA - Produ��o Isenta (Lei 13.606/2018)",;
									aNotasPF[nCont][1],;
									aNotasPF[nCont][2],;
									aNotasPF[nCont][3],;
									aNotasPF[nCont][4],;
									aNotasPF[nCont][5],;
									aNotasPF[nCont][6],;
									aNotasPF[nCont][7],;
									aNotasPF[nCont][8]})        						

			Next nCont

			oExcel:AddRow( cAba,;
						cTabela,;
						{    "Total Aquisi��o PJ",;
								"",;
								"",;
								"",;
								"",;
								nValCPJ,;
								nValGPJ,;
								nValSPJ,;
								nValAqPJ})

			oExcel:AddRow( cAba,;
						cTabela,;
						{    "Total Aquisi��o PF",;
								"",;
								"",;
								"",;
								"",;
								nValCPF,;
								nValGPF,;
								nValSPF,;
								nValAqPF})

			If !Empty( oExcel:aWorkSheet )
				oExcel:Activate()
				oExcel:GetXMLFile( cArquivo )

				__CopyFile( cDefPath + cArquivo, cPath + cArquivo )

				If ApOleClient( "MSExcel" )
					oExcelApp := MsExcel():New()
					oExcelApp:WorkBooks:Open( cPath + cArquivo ) //Abre a planilha
					oExcelApp:SetVisible( .T. )
				EndIf

			EndIf
		EndIf
	EndIf

	(cTemp)->(DbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ImportCMV

Fun��o respons�vel por realizar importa��o de Notas Fiscais para
Consumidor / Comerciante Rural.
Eventos : S-2150 e S-2160

@author Ricardo
@since 09/10/2017(aCgc, cPerApur, cIndApu)

version 
//-------------------------------------------------------------------*/
Static Function ImportCMV(oModel, cPerApur, cXTipo)

	Local cTemp      := GetNextAlias()
	Local cQuery     := ""
	Local cSubStr    := IIF(TcGetDb() $ "ORACLE|DB2", "SUBSTR", "SUBSTRING")
	Local cTipoDoc   := ""
	Local cNumeDoc   := ""
	Local lIncrPrCMV := .F.
	Local cTpInsc    := ""
	Local cInscEs    := ""
	Local cPAA       := ""

	Default cPerApur := ""

	cQuery := "SELECT C20.C20_FILIAL,"
	cQuery +=       " C20.C20_CHVNF,"
	cQuery +=       " C20.C20_SERIE,"
	cQuery +=       " C20.C20_NUMDOC,"
	cQuery +=       " C20.C20_DTDOC,"
	cQuery +=       " C30.C30_INDISE,"
	cQuery +=       " C20.C20_DTES,"
	cQuery +=       " C30.C30_VLOPER,"
	cQuery +=       " (SELECT SUM(TRIB.C35_VALOR) FROM " + RetSqlName( 'C35' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND TRIB.C35_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_ <> '*' AND C3S.C3S_CODIGO='13' AND TRIB.C35_FILIAL=C20.C20_FILIAL AND TRIB.C35_CHVNF=C20.C20_CHVNF AND TRIB.C35_NUMITE=C30.C30_NUMITE AND TRIB.D_E_L_E_T_ <> '*') CONTPR,"
	cQuery +=       " (SELECT SUM(TRIB.C35_VALOR) FROM " + RetSqlName( 'C35' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND TRIB.C35_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_ <> '*' AND C3S.C3S_CODIGO='24' AND TRIB.C35_FILIAL=C20.C20_FILIAL AND TRIB.C35_CHVNF=C20.C20_CHVNF AND TRIB.C35_NUMITE=C30.C30_NUMITE AND TRIB.D_E_L_E_T_ <> '*') GILRAT,"
	cQuery +=       " (SELECT SUM(TRIB.C35_VALOR) FROM " + RetSqlName( 'C35' ) + " TRIB, " + RetSqlName( 'C3S' ) + " C3S WHERE C3S.C3S_FILIAL='" + xFilial('C3S') + "' AND TRIB.C35_CODTRI=C3S.C3S_ID AND C3S.D_E_L_E_T_ <> '*' AND C3S.C3S_CODIGO='25' AND TRIB.C35_FILIAL=C20.C20_FILIAL AND TRIB.C35_CHVNF=C20.C20_CHVNF AND TRIB.C35_NUMITE=C30.C30_NUMITE AND TRIB.D_E_L_E_T_ <> '*') SENAR,"
	cQuery +=       " C1H.C1H_CNPJ,"
	cQuery +=       " C1H.C1H_CPF"

	If TAFColumnPos("C1H_PAA")
		cQuery +=  ", C1H.C1H_PAA"
	EndIf

	cQuery +=  " FROM " + RetSqlName( 'C20' ) + " C20"
	cQuery += " INNER JOIN " + RetSqlName( 'C1H' ) + " C1H"
	cQuery +=    " ON C1H.C1H_FILIAL = '" + xFilial('C1H') + "'"
	cQuery +=   " AND C1H.C1H_ID     = C20.C20_CODPAR"
	cQuery +=   " AND C1H.C1H_RAMO   = '4'"
	cQuery +=   " AND C1H.D_E_L_E_T_ <> '*' "

	cQuery += 	"INNER JOIN " + RetSqlName( 'C30' ) + " C30 "
	cQuery += 	"    ON C30.C30_FILIAL = '" + xFilial('C30') + "' "
	cQuery += 	"       AND C30.C30_CHVNF = C20.C20_CHVNF "
	cQuery += 	"       AND C30.D_E_L_E_T_ <> '*' "

	cQuery += " WHERE C20.C20_FILIAL = '" + xFilial('C20') + "'"
	cQuery +=   " AND C20.C20_INDOPE = '0' " //Entrada
	cQuery +=   " AND " + cSubStr + "(C20.C20_DTDOC,1,6) >= '" + cPerApur + "'"
	cQuery +=   " AND " + cSubStr + "(C20.C20_DTDOC,1,6) <= '" + cPerApur + "'"
	cQuery +=   " AND (C20.C20_CODSIT <> '000003' AND C20.C20_CODSIT <> '000004' AND C20.C20_CODSIT <> '000005' AND C20.C20_CODSIT <> '000006') " //Canceladas/Denegadas/Inutilizadas
	cQuery += 	" AND C20.D_E_L_E_T_ <> '*'"
	cQuery +=   " AND EXISTS (SELECT 1"
	cQuery +=                 " FROM " + RetSqlName('C35') + " C35"
	cQuery +=                " WHERE C35.C35_FILIAL = '" + xFilial('C35') + "'"
	cQuery +=                  " AND C20.C20_CHVNF  = C35.C35_CHVNF"
	cQuery +=                  " AND C35.C35_CODTRI IN ('000013','000024','000025')"
	cQuery +=                  " AND C35.D_E_L_E_T_ <> '*' )"

	// Executa a Query.
	DBUseArea( .T., "TOPCONN", TCGenQry( ,, ChangeQuery( cQuery ) ), cTemp, .F., .T. )

	While ( cTemp )->( !Eof() )

		If (cTemp)->CONTPR > 0 .Or. (cTemp)->GILRAT > 0 .Or. (cTemp)->SENAR > 0

			//-- se o adquirinte est� enquadrado no PAA
			cTpInsc := oModel:GetModel( 'MODEL_CMR' ):GetValue("CMR_TPINSC")
			cInscEs := oModel:GetModel( 'MODEL_CMR' ):GetValue("CMR_INSCES")
			
			cPAA := RetPAA(cInscEs,cTpInsc) 

			cTipoPart := ""
			If Empty((cTemp)->C1H_CPF) .AND. !Empty((cTemp)->C1H_CNPJ)
				
				//-- Pessoa jur�dica
				If TAFColumnPos("C1E_PAA")
					If cPAA == '1' .AND. (cTemp)->C30_INDISE <> "1"
						cTipoPart := "3"
						cNumeDoc  := (cTemp)->C1H_CNPJ	
						cTipoDoc := "1"	
					Else
						If (cTemp)->C30_INDISE == "1" .AND. (cPAA == "1")
							cTipoPart := "6"
							cNumeDoc  := (cTemp)->C1H_CNPJ		
						EndIf
					EndIf	
				Else
					If (cTemp)->C30_INDISE == "1" .AND. (cPAA == "1")
						cTipoPart := "6"	
						cNumeDoc  := (cTemp)->C1H_CNPJ	
					EndIf
				EndIf

			Else
			
				//-- Produtor pessoa f�sica
				If cPAA == "1" .AND. (cTemp)->C30_INDISE <> "1"
					cTipoPart := "2"
					cNumeDoc  := (cTemp)->C1H_CPF
				Else
					cTipoPart := "1"
					cNumeDoc  := (cTemp)->C1H_CPF			
				EndIf		

				If (cTemp)->C30_INDISE == "1"  .AND. cPAA <> "1" 
					cTipoPart := "4"	
				EndIf

				If (cTemp)->C30_INDISE == "1" .AND. (cPAA == "1") 
					cTipoPart := "5"	
				EndIf

			EndIf 


			If !Empty(cTipoPart) //.AND. (cXTipo == cTipoPart)

				oModel:GetModel( 'MODEL_CMT' ):SeekLine( { { "CMT_INDAQU", cTipoPart  } }, .F., .T. )
				oModel:GetModel( 'MODEL_CMU' ):SeekLine( { { "CMU_INSCPR", cNumeDoc } }, .F., .T. )

				lIncrPrCMV := .F.
				If oModel:GetModel( 'MODEL_CMV' ):SeekLine( { { "CMV_SERIE", ALLTRIM((cTemp)->C20_SERIE) },{ "CMV_NUMDOC", ALLTRIM((cTemp)->C20_NUMDOC) } }, .F., .T. )
					lIncrPrCMV := .T.
				EndIf

				If !oModel:GetModel( 'MODEL_CMV' ):IsEmpty() .AND. !lIncrPrCMV
					oModel:GetModel( 'MODEL_CMV' ):AddLine()
				EndIf

				oModel:LoadValue( "MODEL_CMV", "CMV_SERIE",  ALLTRIM((cTemp)->C20_SERIE))
				oModel:LoadValue( "MODEL_CMV", "CMV_NUMDOC", ALLTRIM((cTemp)->C20_NUMDOC))
				oModel:LoadValue( "MODEL_CMV", "CMV_DTEMIS", STOD((cTemp)->C20_DTDOC))
				oModel:LoadValue( "MODEL_CMV", "CMV_VLBRUT", oModel:GetValue( "MODEL_CMV", "CMV_VLBRUT") + (cTemp)->C30_VLOPER )
				oModel:LoadValue( "MODEL_CMV", "CMV_VLCONT", oModel:GetValue( "MODEL_CMV", "CMV_VLCONT") + (cTemp)->CONTPR )
				oModel:LoadValue( "MODEL_CMV", "CMV_VLGILR", oModel:GetValue( "MODEL_CMV", "CMV_VLGILR") + (cTemp)->GILRAT )
				oModel:LoadValue( "MODEL_CMV", "CMV_VLSENA", oModel:GetValue( "MODEL_CMV", "CMV_VLSENA") + (cTemp)->SENAR )
			EndIf
		EndIf

		( cTemp )->( dbSkip() )

	Enddo

	(cTemp)->( DBCloseArea() )
	oModel:GetModel( 'MODEL_CMT' ):GoLine( 1 )
	oModel:GetModel( 'MODEL_CMU' ):GoLine( 1 )
	oModel:GetModel( 'MODEL_CMV' ):GoLine( 1 )

Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} XGetTPInsc

Fun��o respons�vel por retornar o TIPO da inscri��o para a filial logada no sistema CNPJ/CAEPF.

@author Robson Santos
@since 14/02/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function XGetTPInsc()

	Local cRetTPInsc := ""
	Local aArea      := GetArea()
	Local nTamFil    := TamSX3( "C1E_FILTAF" )[1]

	//-- Posiciona na C1E de acordo com a filial corrente

	dbSelectArea("C1E")
	C1E->(dbSetOrder(3))
	If C1E->(MSSeek(XFilial("C1E")+PadR(SM0->M0_CODFIL, nTamFil)+"1"))
		If TAFColumnPos("C1E_NRCPF") .AND. !Empty(C1E->C1E_NRCPF)
			cRetTPInsc := "3"
		Else
			cRetTPInsc := "1"
		EndIf
	EndIf

	RestArea(aArea)

Return cRetTPInsc

//-------------------------------------------------------------------
/*/{Protheus.doc} XGetInsc

Fun��o respons�vel por retornar o N�MERO da inscri��o para a filial logada no sistema CNPJ/CAEPF.

@author Robson Santos
@since 14/02/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function XGetInsc()

	Local cRetInsc := ""
	Local aArea    := GetArea()
	Local nTamFil  := TamSX3( "C1E_FILTAF" )[1]
						
	//-- Posiciona na C1E de acordo com a filial corrente
	dbSelectArea("C1E")
	C1E->(dbSetOrder(3))

	If C1E->(MSSeek(XFilial("C1E")+PadR(SM0->M0_CODFIL, nTamFil)+"1"))
		If TAFColumnPos("C1E_NRCPF") .AND. !Empty(C1E->C1E_NRCPF)
			cRetInsc := C1E->C1E_NRCPF
		Else
			cRetInsc := SM0->M0_CGC
		EndIf
	EndIf

	RestArea(aArea)

Return cRetInsc

//-------------------------------------------------------------------
/*/{Protheus.doc} RetPAA

Fun��o respons�vel por retornar o conteudo do campo PAA 
da tabela C1E de acordo com a raiz do CNPJ.

cInsc: CNPJ do estabelcimento

@author Robson Santos
@since 30/05/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetPAA(cInsc, cTpInsc)

	Local cPAA 		:= ""
	Local aAreaSM0	:= SM0->(GetArea())
	Local aAreaC1E	:= C1E->(GetArea())
	Local nTamFil	:= TamSX3( "C1E_FILTAF" )[1]
	Local lAchou	:= .F.

	//-- Posiciona na SM0 com a raiz do CNPJ do estabelecimento
	dbSelectArea("SM0")
	SM0->(dbGoTop())

	//-- CNPJ
	If cTpInsc == '1'

		While !SM0->(Eof()) .And. !lAchou
			If !Empty(cInsc)
				If AllTrim(SM0->M0_CGC) == AllTrim(cInsc)

					lAchou	:= .T.
					cPAA 	:= Posicione("C1E", 3, XFilial("C1E")+PadR(SM0->M0_CODFIL, nTamFil)+"1", "C1E_PAA" )

				EndIf
			EndIf
			SM0->(DbSkip())
		EndDo

	//-- CAEPF	
	ElseIf cTpInsc == '3'

		dbSelectArea("C1E")
		C1E->(dbGoTop())

		While !C1E->(Eof()) .And. !lAchou
			If !Empty(cInsc)
				If SubStr(AllTrim(C1E->C1E_NRCPF), 1, 9) == SubStr(AllTrim(cInsc),1,9)
					lAchou	:= .T.
					cPAA := C1E->C1E_PAA
				EndIf
			EndIf
			C1E->(DbSkip())
		EndDo

	EndIf

	RestArea(aAreaC1E)
	RestArea(aAreaSM0)

Return cPAA
