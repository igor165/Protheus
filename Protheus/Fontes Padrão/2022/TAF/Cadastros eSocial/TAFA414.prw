#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA414.CH"

Static lLaySimplif	:= TafLayESoc("S_01_00_00")

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA414
Cadastro MVC dos  Comercialização Prod. Rural PF - S-1260

@author Daniel Schmidt
@since 11/01/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA414()

	Local cTpInscr := SM0->M0_TPINSC
	Local nTamFil  := TamSX3( "C1E_FILTAF" )[1]

	Private oBrw   := FWmBrowse():New()

	oBrw:SetDescription( STR0001 )	//"Comercialização da Produção Rural Pessoa Física"
	oBrw:SetAlias( 'T1M')
	oBrw:SetMenuDef( 'TAFA414' )

	If FindFunction('TAFSetFilter')
		oBrw:SetFilterDefault(TAFBrwSetFilter("T1M","TAFA414","S-1260"))
	Else
		oBrw:SetFilterDefault( "T1M_ATIVO == '1'" )
	EndIf

	dbSelectArea("C1E")
	C1E->(dbSetOrder(3))

	If C1E->(MSSeek(XFilial("C1E")+PadR(SM0->M0_CODFIL, nTamFil)+"1"))
		If cTpInscr != 3 .AND. Empty(C1E->C1E_NRCPF)
			Help( ,, "HELP",, "Prezado cliente o tipo de inscrição que esta usando é diferente do esperado pela rotina! Favor preencher o campo CPF do produtor no complemento cadastral.", 1, 0 )
			lRet := .F.
		EndIF
	EndIf

	C1E->(DbCloseArea())
	TafLegend(2,"T1M",@oBrw)
	oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Daniel Schmidt
@since 11/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao := {} 
	Local aRotina := {} 	

	Aadd( aFuncao, { "" , "TafxmlRet('TAF414Xml','1260','T1M')" 								, "1" } )
	Aadd( aFuncao, { "" , "xFunAltRec( 'T1M' )" 												, "10"} )
	Aadd( aFuncao, { "" , "xNewHisAlt( 'T1M', 'TAFA414' ,,,,,,'1260','TAF414Xml' )" 			, "3" } )
	Aadd( aFuncao, { "" , "TAFXmlLote( 'T1M', 'S-1260' , 'evtComProd' , 'TAF414Xml',, oBrw )" 	, "5" } )

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If lMenuDif
		ADD OPTION aRotina Title "Visualizar"	Action 'VIEWDEF.TAFA414' OPERATION 2 ACCESS 0
		aRotina	:= xMnuExtmp( "TAFA414", "T1M", .F. )
	Else
		aRotina	:=	xFunMnuTAF( "TAFA414" , , aFuncao)
	EndIf

Return (aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Daniel Schmidt
@since 11/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruT1M  := FWFormStruct( 1, 'T1M' )
	Local oStruT1N  := FWFormStruct( 1, 'T1N' )
	Local oStruT1O  := FWFormStruct( 1, 'T1O' )
	Local oStruT1P  := FWFormStruct( 1, 'T1P' )
	Local oStruT6B  := FWFormStruct( 1, 'T6B' ) 
	Local oModel	:= MPFormModel():New( 'TAFA414' ,,,{|oModel| SaveModel(oModel)})	

	//Remoção do GetSX8Num quando se tratar da Exclusão de um Evento Transmitido.
	//Necessário para não incrementar ID que não será utilizado.
	If Upper( ProcName( 2 ) ) == Upper( "GerarExclusao" )
		oStruT1M:SetProperty( "T1M_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )
	EndIf

	//T1M – Info. Comercialização Produção
	oModel:AddFields('MODEL_T1M', /*cOwner*/, oStruT1M)
	oModel:GetModel('MODEL_T1M'):SetPrimaryKey({'T1M_FILIAL', 'T1M_ID', 'T1M_VERSAO'})

	//T1N – Tipo de Comercialização
	oModel:AddGrid('MODEL_T1N', 'MODEL_T1M', oStruT1N)
	oModel:GetModel('MODEL_T1N'):SetOptional(.T.)
	oModel:GetModel('MODEL_T1N'):SetUniqueLine({'T1N_INDCOM'})
	oModel:GetModel('MODEL_T1N'):SetMaxLine(5)

	//T1O – Ident. Adquirentes da Produção
	oModel:AddGrid('MODEL_T1O', 'MODEL_T1N', oStruT1O)
	oModel:GetModel('MODEL_T1O'):SetOptional(.T.)
	oModel:GetModel('MODEL_T1O'):SetUniqueLine({'T1O_TPINSA', 'T1O_NRINSA'})
	oModel:GetModel('MODEL_T1O'):SetMaxLine(9999)

	//T1P – Info. Proc. Judiciais Incid. Comer.
	oModel:AddGrid('MODEL_T1P', 'MODEL_T1N', oStruT1P)
	oModel:GetModel('MODEL_T1P'):SetOptional(.T.)
	oModel:GetModel('MODEL_T1P'):SetUniqueLine({'T1P_IDPROC'})
	oModel:GetModel('MODEL_T1P'):SetMaxLine(10)

	//Modelo de Notas fiscais
	oModel:AddGrid('MODEL_T6B', 'MODEL_T1O', oStruT6B)
	oModel:GetModel('MODEL_T6B'):SetOptional(.T.)
	oModel:GetModel('MODEL_T6B'):SetUniqueLine({'T6B_SERIE', 'T6B_NUMDOC'})
	oModel:GetModel('MODEL_T6B'):SetMaxLine(9999)

	oStruT6B:SetProperty( 'T6B_VLCONT', MODEL_FIELD_OBRIGAT , .F. )
	oStruT6B:SetProperty( 'T6B_VLGILR', MODEL_FIELD_OBRIGAT , .F. )
	oStruT6B:SetProperty( 'T6B_VLSENA', MODEL_FIELD_OBRIGAT , .F. )

	oModel:SetRelation("MODEL_T1N",{ {"T1N_FILIAL","xFilial('T1N')"}, {"T1N_ID","T1M_ID"}, {"T1N_VERSAO","T1M_VERSAO"} , {"T1N_IDESTA","T1M_IDESTA"}}, T1N->(IndexKey(1)) )
	oModel:SetRelation("MODEL_T1O",{ {"T1O_FILIAL","xFilial('T1O')"}, {"T1O_ID","T1M_ID"}, {"T1O_VERSAO","T1M_VERSAO"} , {"T1O_IDESTA","T1M_IDESTA"}, {"T1O_INDCOM","T1N_INDCOM"} }, T1O->(IndexKey(1)) )
	oModel:SetRelation("MODEL_T1P",{ {"T1P_FILIAL","xFilial('T1P')"}, {"T1P_ID","T1M_ID"}, {"T1P_VERSAO","T1M_VERSAO"} , {"T1P_IDESTA","T1M_IDESTA"}, {"T1P_INDCOM","T1N_INDCOM"} }, T1P->(IndexKey(1)) )
	oModel:SetRelation('MODEL_T6B',{ {'T6B_FILIAL',"xFilial('T6B')"}, {'T6B_ID','T1M_ID'}, {'T6B_VERSAO','T1M_VERSAO'} , {"T6B_IDESTA","T1M_IDESTA"}, {"T6B_INDCOM","T1N_INDCOM"},{'T6B_TPINSA','T1O_TPINSA'},{'T6B_NRINSA','T1O_NRINSA'}}, T6B->(IndexKey(1)))

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Daniel Schmidt
@since 11/01/2016
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   	:= FWLoadModel( 'TAFA414' )   	
	Local oStruT1Ma	:= Nil
	Local oStruT1Mb	:= Nil	 
	Local oStruT1Mc	:= Nil
	Local oStruT1N	:= FWFormStruct( 2, 'T1N' )
	Local oStruT1O	:= FWFormStruct( 2, 'T1O' )
	Local oStruT1P	:= FWFormStruct( 2, 'T1P' )
	Local oStruT6B  := FWFormStruct( 2, 'T6B' )	 
	Local oView		:= FWFormView():New()		 
	Local cCmpFil  	:= ''  	 
	Local nI       	:= 0       	 
	Local aCmpGrp  	:= {}  	 
	Local cGrpCom1 	:= ""
	Local cGrpCom2 	:= ""
	Local cGrpCom3	:= ""	 

	oView:SetModel( oModel )
	oView:SetContinuousForm(.T.)

	//Informações de Apuração/Identificação do Estabelecimento que Comercializou a Produção
	If !lLaySimplif
		cGrpCom1  := 'T1M_ID|T1M_VERSAO|T1M_VERANT|T1M_PROTPN|T1M_EVENTO|T1M_ATIVO|T1M_INDAPU|T1M_PERAPU|'
	Else
		cGrpCom1  := 'T1M_ID|T1M_VERSAO|T1M_VERANT|T1M_PROTPN|T1M_EVENTO|T1M_ATIVO|T1M_PERAPU|T1M_TPGUIA|'
	EndIf

	cGrpCom2  := 'T1M_IDESTA|T1M_NRCAEP|'
	cCmpFil   := cGrpCom1 + cGrpCom2
	oStruT1Ma := FwFormStruct( 2, 'T1M', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	//"Protocolo de Transmissão"
	cGrpCom3 := 'T1M_PROTUL|'
	cCmpFil   := cGrpCom3
	oStruT1Mb := FwFormStruct( 2, 'T1M', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	If TafColumnPos("T1M_DTRANS")
		cCmpFil := "T1M_DINSIS|T1M_DTRANS|T1M_HTRANS|T1M_DTRECP|T1M_HRRECP|"
		oStruT1Mc := FwFormStruct( 2, 'T1M', {|x| AllTrim( x ) + "|" $ cCmpFil } )
	EndIf

	/*-----------------------------------------------------------------------------------
					Grupo de campos da Comercialização de Produção
	-------------------------------------------------------------------------------------*/
	oStruT1Ma:AddGroup( "GRP_COMERCIALIZACAO_01", STR0005, "", 1 ) //Informações de Apuração
	oStruT1Ma:AddGroup( "GRP_COMERCIALIZACAO_02", STR0006, "", 1 ) //Identificação do Estabelecimento que Comercializou a Produção

	aCmpGrp := StrToKArr(cGrpCom1,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruT1Ma:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_COMERCIALIZACAO_01")
	Next nI

	aCmpGrp := StrToKArr(cGrpCom2,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruT1Ma:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_COMERCIALIZACAO_02")
	Next nI

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruT1Mb,"T1M")
	EndIf

	/*--------------------------------------------------------------------------------------------
										Esrutura da View
	---------------------------------------------------------------------------------------------*/
	oView:AddField( "VIEW_T1Ma", oStruT1Ma, "MODEL_T1M" )

	oView:AddField( "VIEW_T1Mb", oStruT1Mb, "MODEL_T1M" )

	If TafColumnPos("T1M_PROTUL")
		oView:EnableTitleView( 'VIEW_T1Mb', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"
	EndIf
	If TafColumnPos("T1M_DTRANS")
		oView:AddField( "VIEW_T1Mc", oStruT1Mc, "MODEL_T1M" )
		oView:EnableTitleView( 'VIEW_T1Mc', TafNmFolder("recibo",2) ) 
	EndIf
	
	oView:AddGrid( "VIEW_T1N", oStruT1N, "MODEL_T1N" )
	oView:EnableTitleView("MODEL_T1N",STR0007) //"Total da Comercialização por Tipo de Comercialização"

	oView:AddGrid( "VIEW_T1O", oStruT1O, "MODEL_T1O" )
	oView:AddGrid( "VIEW_T1P", oStruT1P, "MODEL_T1P" )
	oView:AddGrid( "VIEW_T6B", oStruT6B, 'MODEL_T6B' )

	/*-----------------------------------------------------------------------------------
									Estrutura do Folder
	-------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
	oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

	//////////////////////////////////////////////////////////////////////////////////

	oView:AddSheet("FOLDER_PRINCIPAL","ABA01",STR0010) //"Info. Comercialização Produção"
	oView:CreateHorizontalBox("T1Ma",20,,,"FOLDER_PRINCIPAL","ABA01") //Informações de Apuração/Identificação do Estabelecimento que Comercializou a Produção
	oView:CreateHorizontalBox("T1N" ,30,,,"FOLDER_PRINCIPAL","ABA01") //Total da Comercialização por Tipo de Comercialização

	oView:CreateHorizontalBox("PAINEL_TPCOM",50,,,"FOLDER_PRINCIPAL","ABA01")
	oView:CreateFolder( 'FOLDER_TPCOM', 'PAINEL_TPCOM' )
	oView:AddSheet( 'FOLDER_TPCOM', 'ABA01', STR0008 ) //"Identificação dos Adquirentes da Produção"
	oView:AddSheet( 'FOLDER_TPCOM', 'ABA02', STR0009 ) //"Informações de Processos Judiciais"
	oView:CreateHorizontalBox ( 'T1O', 50,,, 'FOLDER_TPCOM'  , 'ABA01' )
	oView:CreateHorizontalBox ( 'T1P', 100,,, 'FOLDER_TPCOM'  , 'ABA02' )

	oView:CreateHorizontalBox("PAINEL_NF",50,,,"FOLDER_TPCOM","ABA01")
	oView:CreateFolder( 'FOLDER_NF', 'PAINEL_NF' )
	oView:AddSheet( 'FOLDER_NF', 'ABA01', STR0013 ) //"Notas Fiscais"
	oView:CreateHorizontalBox ( 'T6B', 100,,, 'FOLDER_NF'  , 'ABA01' )

	If FindFunction("TafNmFolder")
		oView:AddSheet("FOLDER_PRINCIPAL","ABA02",TafNmFolder("recibo") ) //"Numero do Recibo"
	Else
		oView:AddSheet("FOLDER_PRINCIPAL","ABA02",STR0012) //"Protocolo de Transmissão"
	EndIf

	If TafColumnPos("T1M_DTRANS")
		oView:CreateHorizontalBox("T1Mb",20,,,"FOLDER_PRINCIPAL","ABA02")
		oView:CreateHorizontalBox("T1Mc",80,,,"FOLDER_PRINCIPAL","ABA02")
	Else
		oView:CreateHorizontalBox("T1Mb",100,,,"FOLDER_PRINCIPAL","ABA02")
	EndIf

	/*-----------------------------------------------------------------------------------
								Amarração para exibição das informações
	-------------------------------------------------------------------------------------*/
	oView:SetOwnerView( "VIEW_T1Ma", "T1Ma")
	oView:SetOwnerView( "VIEW_T1Mb", "T1Mb")
	If TafColumnPos("T1M_DTRANS")
		oView:SetOwnerView( "VIEW_T1Mc", "T1Mc")
	EndIf
	oView:SetOwnerView( "VIEW_T1N",  "T1N" )
	oView:SetOwnerView( "VIEW_T1O",  "T1O" )
	oView:SetOwnerView( "VIEW_T1P",  "T1P" )
	oView:SetOwnerView( "VIEW_T6B",  "T6B" )

	//Processar Dados Automáticamente
	oView:AddUserButton( STR0017, 'CLIPS', {|oView| ImportDataNF(oModel) } ) //"Buscar Docs Fiscais"

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If !lMenuDif .OR. ( FindFunction( "xTafExtmp" ) .And. xTafExtmp() )
		xFunRmFStr(@oStruT1Ma,"T1M")
		oStruT1P:RemoveField('T1P_IDSUSP')
	EndIf

Return (oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Daniel Schmidt
@since 11/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local cVerAnt    	 
	Local cProtocolo	 
	Local cVersao    	 
	Local cEvento	 	 
	Local cChvRegAnt	 
	Local cLogOpe		 
	Local cLogOpeAnt	 
	Local nOperation	 
	Local nI			 
	Local nT1N			 
	Local nT1O			 
	Local nT1P			 
	Local nT6B			 
	Local aGrava		 
	Local aGravaT1M	 
	Local aGravaT1N 	 
	Local aGravaT1O	 
	Local aGravaT1P	 
	Local aGravaT6B	 
	Local oModelT1M 	 
	Local oModelT1N 	 
	Local oModelT1O 	 
	Local oModelT1P 	 
	Local oModelT6B 	 
	Local lRetorno	 

	cVerAnt    := ""
	cProtocolo := ""
	cVersao    := ""
	cEvento    := ""
	cChvRegAnt := ""
	cLogOpe    := ""
	cLogOpeAnt := ""
	nOperation := oModel:GetOperation()
	nI         := 0
	nT1N       := 0
	nT1O       := 0
	nT1P       := 0
	nT6B       := 0
	aGrava     := {}
	aGravaT1M  := {}
	aGravaT1N  := {}
	aGravaT1O  := {}
	aGravaT1P  := {}
	aGravaT6B  := {}
	oModelT1M  := Nil
	oModelT1N  := Nil
	oModelT1O  := Nil
	oModelT1P  := Nil
	oModelT6B  := Nil
	lRetorno   := .T.

	Begin Transaction

		//Inclusao Manual do Evento
		If nOperation == MODEL_OPERATION_INSERT

			TafAjustID( "T1M", oModel)
			
			oModel:LoadValue( "MODEL_T1M", "T1M_VERSAO", xFunGetVer() )

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_T1M', 'T1M_LOGOPE' , '2', '' )
			Endif

			FwFormCommit( oModel )

		//Alteração Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_UPDATE

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta pocisionado nao eh possivel analisar  	 ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//Posicionando no registro para que nao ocorra erros duranteo processo de validação
			//T1M_FILIAL+T1M_ID+T1M_ATIVO
			T1M->( DbSetOrder( 4 ) )
			If T1M->( MsSeek( xFilial( 'T1M' ) + T1M->T1M_ID + '1' ) )

				//Verifica se o evento ja foi trasmitido ao RET
				If T1M->T1M_STATUS $ ( "4" )

					//Carrego a Estrutura dos Models a serem gravados
					oModelT1M := oModel:GetModel( "MODEL_T1M" )
					oModelT1N := oModel:GetModel( "MODEL_T1N" )
					oModelT1O := oModel:GetModel( "MODEL_T1O" )
					oModelT1P := oModel:GetModel( "MODEL_T1P" )
					oModelT6B := oModel:GetModel( "MODEL_T6B" )


					//Guardo as informações do registro corrente para rastro do registro
					cVerAnt   	:= oModelT1M:GetValue( "T1M_VERSAO" )
					cProtocolo	:= oModelT1M:GetValue( "T1M_PROTUL" )
					cEvento		:= oModelT1M:GetValue( "T1M_EVENTO" )

					If TafColumnPos( "T1M_LOGOPE" )
						cLogOpeAnt := oModelT1M:GetValue( "T1M_LOGOPE" )
					endif

					//Armazeno as informações correntes do cadastro( Depois da alteração do Usuário )

					//***********
					//Informação da Comercialização de Produção
					//***********
					For nI := 1 to Len( oModelT1M:aDataModel[ 1 ] )
						Aadd( aGrava, { oModelT1M:aDataModel[ 1, nI, 1 ], oModelT1M:aDataModel[ 1, nI, 2 ] } )
					Next nI
					//------------------

					//***********
					//Tipo de Comercialização
					//***********
					For nT1N := 1 to oModel:GetModel( "MODEL_T1N" ):Length()
						oModel:GetModel( "MODEL_T1N" ):GoLine(nT1N)
						If !oModel:GetModel( 'MODEL_T1N' ):IsEmpty()
							If !oModel:GetModel( "MODEL_T1N" ):IsDeleted()
								aAdd(aGravaT1N,{oModelT1N:GetValue("T1N_INDCOM"),;
												oModelT1N:GetValue("T1N_VLRTOT")})

								//***********
								//Identificação dos Adquirentes da Produção
								//***********
								For nT1O := 1 to oModel:GetModel( "MODEL_T1O" ):Length()
									oModel:GetModel( "MODEL_T1O" ):GoLine(nT1O)
									If !oModel:GetModel( 'MODEL_T1O' ):IsEmpty()
										If !oModel:GetModel( "MODEL_T1O" ):IsDeleted()
											aAdd(aGravaT1O,{oModelT1N:GetValue("T1N_INDCOM"),;
															oModelT1O:GetValue("T1O_TPINSA"),;
															oModelT1O:GetValue("T1O_NRINSA"),;
															oModelT1O:GetValue("T1O_VLRCOM")})


											For nT6B := 1 To oModel:GetModel( 'MODEL_T6B' ):Length()
												oModel:GetModel( 'MODEL_T6B' ):GoLine(nT6B)

												If !oModel:GetModel( 'MODEL_T6B' ):IsDeleted()
													aAdd (aGravaT6B ,{ oModelT1N:GetValue("T1N_INDCOM"),;
																	oModelT1O:GetValue("T1O_TPINSA"),;
																	oModelT1O:GetValue("T1O_NRINSA"),;
																	oModelT6B:GetValue("T6B_SERIE"),;
																	oModelT6B:GetValue("T6B_NUMDOC"),;
																	oModelT6B:GetValue("T6B_DTEMIS"),;
																	oModelT6B:GetValue("T6B_VLBRUT"),;
																	oModelT6B:GetValue("T6B_VLCONT"),;
																	oModelT6B:GetValue("T6B_VLGILR"),;
																	oModelT6B:GetValue("T6B_VLSENA")} )
												EndIf
											Next nT6B
										EndIf
									EndIf
								Next nT1O
								//-----------
								//***********
								//Informações de Processos Judiciais
								//***********
								For nT1P := 1 to oModel:GetModel( "MODEL_T1P" ):Length()
									oModel:GetModel( "MODEL_T1P" ):GoLine(nT1P)
									If !oModel:GetModel( 'MODEL_T1P' ):IsEmpty()
										If !oModel:GetModel( 'MODEL_T1P' ):IsDeleted()
											aAdd(aGravaT1P,{oModelT1N:GetValue("T1N_INDCOM"),;
															oModelT1P:GetValue("T1P_IDPROC"),;
															oModelT1P:GetValue("T1P_VLRPRV"),;
															oModelT1P:GetValue("T1P_VLRRAT"),;
															oModelT1P:GetValue("T1P_VLRSEN")})
										EndIf
									EndIf
								Next nT1P
								//-----------

							EndIf
						EndIf
					Next nT1N
					//-----------

					/*----------------------------------------------------------
					Seto o campo como Inativo e gravo a versao do novo registro
					no registro anterior

					ATENCAO -> A alteracao destes campos deve sempre estar
					abaixo do Loop do For, pois devem substituir as informacoes
					que foram armazenadas no Loop acima
					-----------------------------------------------------------*/
					FAltRegAnt( "T1M", "2" )

					/*----------------------------------------------------------
					Apos deixar o registro corrente como inativo eu seto a
					operação de inclusão para o novo registro
					-----------------------------------------------------------*/
					oModel:DeActivate()
					oModel:SetOperation( 3 )
					oModel:Activate()

					/*----------------------------------------------------------
					Neste momento eu realizo a gravação de um novo registro idêntico
					ao original, apenas com as alterações nos campos modificados
					pelo usuário no cadastro
					-----------------------------------------------------------*/
					//***********
					//Informação da Comercialização de Produção
					//***********
					For nI := 1 to Len( aGrava )
						oModel:LoadValue( "MODEL_T1M", aGrava[ nI, 1 ], aGrava[ nI, 2 ] )
					Next nI

					//Necessário Abaixo do For Nao Retirar
					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T1M', 'T1M_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					//***********
					//Tipo de Comercialização
					//***********
					For nT1N := 1 to Len( aGravaT1N )
						If nT1N > 1
							oModel:GetModel( "MODEL_T1N" ):AddLine()
						EndIf
						oModel:LoadValue( "MODEL_T1N", "T1N_INDCOM" , aGravaT1N[nT1N][1] )
						oModel:LoadValue( "MODEL_T1N", "T1N_VLRTOT" , aGravaT1N[nT1N][2] )
						//***********
						//Identificação dos Adquirentes da Produção
						//***********
						For nT1O := 1 to Len( aGravaT1O )

							If  aGravaT1N[nT1N][1] == aGravaT1O[nT1O][1]

								If nT1O > 1
									oModel:GetModel( "MODEL_T1O" ):AddLine()
								EndIf
								
								oModel:LoadValue( "MODEL_T1O", "T1O_TPINSA" , aGravaT1O[nT1O][2] )
								oModel:LoadValue( "MODEL_T1O", "T1O_NRINSA" , aGravaT1O[nT1O][3] )
								oModel:LoadValue( "MODEL_T1O", "T1O_VLRCOM" , aGravaT1O[nT1O][4] )

								For nT6B := 1 To Len( aGravaT6B )
									If aGravaT1N[nT1N][1] == aGravaT6B[nT6B][1] .AND. aGravaT1O[nT1O][2] == aGravaT6B[nT6B][2] .AND. aGravaT1O[nT1O][3] == aGravaT6B[nT6B][3]

										If nT6B > 1
											oModel:GetModel( 'MODEL_T6B' ):AddLine()
										EndIf
										oModel:LoadValue( "MODEL_T6B", "T6B_SERIE",  aGravaT6B[nT6B][4] )
										oModel:LoadValue( "MODEL_T6B", "T6B_NUMDOC", aGravaT6B[nT6B][5] )
										oModel:LoadValue( "MODEL_T6B", "T6B_DTEMIS", aGravaT6B[nT6B][6] )
										oModel:LoadValue( "MODEL_T6B", "T6B_VLBRUT", aGravaT6B[nT6B][7] )
										oModel:LoadValue( "MODEL_T6B", "T6B_VLCONT", aGravaT6B[nT6B][8] )
										oModel:LoadValue( "MODEL_T6B", "T6B_VLGILR", aGravaT6B[nT6B][9] )
										oModel:LoadValue( "MODEL_T6B", "T6B_VLSENA", aGravaT6B[nT6B][10] )
									EndIf

								Next nT6B
							EndIf
						Next nT1O

						//***********
						//Informações de Processos Judiciais
						//***********
						For nT1P := 1 to Len( aGravaT1P )
							If  aGravaT1N[nT1N][1] == aGravaT1P[nT1P][1]
								oModel:GetModel( 'MODEL_T1P' ):LVALID	:= .T.

								If nT1P > 1
									oModel:GetModel( "MODEL_T1P" ):AddLine()
								EndIf
								oModel:LoadValue( "MODEL_T1P", "T1P_IDPROC",	aGravaT1P[nT1P][2] )
								oModel:LoadValue( "MODEL_T1P", "T1P_VLRPRV",	aGravaT1P[nT1P][3] )
								oModel:LoadValue( "MODEL_T1P", "T1P_VLRRAT",	aGravaT1P[nT1P][4] )
								oModel:LoadValue( "MODEL_T1P", "T1P_VLRSEN",	aGravaT1P[nT1P][5] )
							EndIf
						Next nT1P

				Next nT1N

					//Busco a nova versao do registro
					cVersao := xFunGetVer()

					/*---------------------------------------------------------
					ATENCAO -> A alteracao destes campos deve sempre estar
					abaixo do Loop do For, pois devem substituir as informacoes
					que foram armazenadas no Loop acima
					-----------------------------------------------------------*/
					oModel:LoadValue( "MODEL_T1M", "T1M_VERSAO", cVersao )
					oModel:LoadValue( "MODEL_T1M", "T1M_VERANT", cVerAnt )
					oModel:LoadValue( "MODEL_T1M", "T1M_PROTPN", cProtocolo )
					oModel:LoadValue( "MODEL_T1M", "T1M_PROTUL", "" )
					oModel:LoadValue( "MODEL_T1M", "T1M_EVENTO", "A" )

					// Tratamento para limpar o ID unico do xml
					cAliasPai := "T1M"
					If TAFColumnPos( cAliasPai+"_XMLID" )
						oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					EndIf

					FwFormCommit( oModel )
					TAFAltStat( 'T1M', " " )

				ElseIf	T1M->T1M_STATUS == "2"

					TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
					lRetorno:= .F.

				ElseIf T1M->T1M_STATUS == "6"

					TAFMsgVldOp(oModel,"6")//"Registro não pode ser alterado. Aguardando proc. Transm. evento de Exclusão S-3000"
					lRetorno:= .F.

				Elseif T1M->T1M_STATUS == "7"

					TAFMsgVldOp(oModel,"7") //"Registro não pode ser alterado, pois o evento já se encontra na base do RET"
					lRetorno:= .F.

				Else

					//alteração sem transmissão
					If TafColumnPos( "T1M_LOGOPE" )
						cLogOpeAnt := T1M->T1M_LOGOPE
					EndIf

					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T1M', 'T1M_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					FwFormCommit( oModel )
					TAFAltStat( 'T1M', " " )
				EndIf
			EndIf

		//Exclusão Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_DELETE

			cChvRegAnt := T1M->(T1M_ID + T1M_VERANT)

			TAFAltStat( 'T1M', " " )
			FwFormCommit( oModel )

			If T1M->T1M_EVENTO == "A" .Or. T1M->T1M_EVENTO == "E"
				TAFRastro( 'T1M', 1, cChvRegAnt, .T. , , IIF(Type("oBrw") == "U", Nil, oBrw) )
			EndIf
			
		EndIf

	End Transaction

	If !lRetorno
		// Define a mensagem de erro que será exibida após o Return do SaveModel
		TAFMsgDel(oModel,.T.)
	EndIf

Return (lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF414Grv
@type			function
@description	Função de gravação para atender o registro S-1260.
@author			Daniel Schmidt
@since			11/01/2016
@version		1.0
@param			cLayout		-	Nome do Layout que está sendo enviado
@param			nOpc		-	Opção a ser realizada ( 3 = Inclusão, 4 = Alteração, 5 = Exclusão )
@param			cFilEv		-	Filial do ERP para onde as informações deverão ser importadas
@param			oXML		-	Objeto com as informações a serem manutenidas ( Outras Integrações )
@param			cOwner
@param			cFilTran
@param			cPredeces
@param			nTafRecno
@param			cComplem
@param			cGrpTran
@param			cEmpOriGrp
@param			cFilOriGrp
@param			cXmlID		-	Atributo Id, único para o XML do eSocial. Utilizado para importação de dados de clientes migrando para o TAF
@return			lRet		-	Variável que indica se a importação foi realizada, ou seja, se as informações foram gravadas no banco de dados
@param			aIncons		-	Array com as inconsistências encontradas durante a importação
/*/
//-------------------------------------------------------------------
Function TAF414Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

	Local cCmpsNoUpd	:=	"|T1M_FILIAL|T1M_ID|T1M_VERSAO|T1M_VERANT|T1M_PROTUL|T1M_PROTPN|T1M_EVENTO|T1M_STATUS|T1M_ATIVO|"
	Local cCabec		:=	"/eSocial/evtComProd/infoComProd/ideEstabel"
	Local cT1NPath		:=	""
	Local cT1OPath		:=	""
	Local cT1PPath		:=	""
	Local cT6BPath		:=	""
	Local cPeriodo		:=	""
	Local cChave		:=	""
	Local cInconMsg		:=	""
	Local cCodEvent		:=	Posicione( "C8E", 2, xFilial( "C8E" ) + "S-" + cLayout, "C8E->C8E_ID" )
	Local nI			:=	0
	Local nJ			:=	0
	Local nT1N			:=	0
	Local nT1O			:=	0
	Local nT1P			:=	0
	Local nT6B			:=	0
	Local nSeqErrGrv	:=	0
	Local lRet			:=	.F.
	Local aIncons		:=	{}
	Local aRulesCad		:=	{}
	Local aChave		:=	{}
	Local oModel		:=	Nil
	Local cIndGuia      := ""
	Local nIndChv		:=	Iif(!lLaySimplif, 2, 5)

	Private lVldModel	:=	.T. //Caso a chamada seja via integração, seto a variável de controle de validação como .T.
	Private oDados		:=	oXML

	Default cLayout		:=	"1260"
	Default nOpc		:=	1
	Default cFilEv		:=	""
	Default oXML		:=	Nil
	Default cOwner		:=	""
	Default cFilTran	:=	""
	Default cPredeces	:=	""
	Default nTafRecno	:=	0
	Default cComplem	:=	""
	Default cGrpTran	:=	""
	Default cEmpOriGrp	:=	""
	Default cFilOriGrp	:=	""
	Default cXmlID		:=	""

	//Chave do Registro
	cPeriodo  := FTafGetVal( "/eSocial/evtComProd/ideEvento/perApur", "C", .F., @aIncons, .F. )

	If lLaySimplif
		cIndGuia	:= FTafGetVal( "/eSocial/evtComProd/ideEvento/indGuia", "C", .F., @aIncons, .F. )
	EndIf

	If !lLaySimplif
		Aadd( aChave, {"C", "T1M_INDAPU", FTafGetVal( "/eSocial/evtComProd/ideEvento/indApuracao", "C", .F., @aIncons, .F. )  , .T.} )
		cChave += Padr( aChave[ 1, 3 ], Tamsx3( aChave[ 1, 2 ])[1])

		If At("-", cPeriodo) > 0
			Aadd( aChave, {"C", "T1M_PERAPU", StrTran(cPeriodo, "-", "" ),.T.} )
			cChave += Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1])
		Else
			Aadd( aChave, {"C", "T1M_PERAPU", cPeriodo  , .T.} )
			cChave += Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1])
		EndIf
	Else

		aAdd( aChave, { "C", "T1M_TPGUIA", cIndGuia, .T. } )
		cChave += Padr( aChave[ 1, 3 ], Tamsx3( aChave[ 1, 2 ])[1])

		If At("-", cPeriodo) > 0
			Aadd( aChave, {"C", "T1M_PERAPU", StrTran(cPeriodo, "-", "" ),.T.} )
			cChave += Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1])
		EndIf

	EndIf
	aAdd( aChave, { "C", "T1M_IDESTA", FGetIdInt( "nrInscEstabRural","",cCabec + "/nrInscEstabRural") , .T. } )
	cChave += Padr( aChave[ 3, 3 ], Tamsx3( aChave[ 3, 2 ])[1])

	//Verifica se o evento ja existe na base
	("T1M")->( DbSetOrder( nIndChv ) )
	If ("T1M")->( MsSeek( xFilial("T1M") + cChave + '1' ) )
		nOpc := 4
	EndIf

	Begin Transaction

		//Funcao para validar se a operacao desejada pode ser realizada
		If FTafVldOpe( "T1M", nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA414", cCmpsNoUpd , , , , )

			If TafColumnPos( "T1M_LOGOPE" )
				cLogOpeAnt := T1M->T1M_LOGOPE
			endif

			//Carrego array com os campos De/Para de gravacao das informacoes ( Cadastrais )
			aRulesCad := TAF414Rul( cCabec, @cInconMsg, @nSeqErrGrv, cCodEvent, cOwner )

			//Quando se tratar de uma Exclusao direta apenas preciso realizar
			//o Commit(), nao eh necessaria nenhuma manutencao nas informacoes
			If nOpc <> 5

				oModel:LoadValue( "MODEL_T1M", "T1M_FILIAL", T1M->T1M_FILIAL )

				If TAFColumnPos( "T1M_XMLID" )
					oModel:LoadValue( "MODEL_T1M", "T1M_XMLID", cXmlID )
				EndIf

				//Rodo o aRulesCad para gravar as informacoes
				For nI := 1 to Len( aRulesCad )
					oModel:LoadValue( "MODEL_T1M", aRulesCad[ nI, 01 ], FTafGetVal( aRulesCad[ nI, 02 ], aRulesCad[nI, 03], aRulesCad[nI, 04], @aIncons, .F. ) )
				Next nI

				If Findfunction("TAFAltMan")
					if nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T1M', 'T1M_LOGOPE' , '1', '' )
					elseif nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T1M', 'T1M_LOGOPE' , '', cLogOpeAnt )
					EndIf
				EndIf

				//***********
				//eSocial/evtComProd/infoComProd/ideEstabel/tpComerc
				//***********
				nT1N := 1
				cT1NPath := cCabec + "/tpComerc[" + CVALTOCHAR(nT1N) + "]"

				If nOpc == 4
					For nJ := 1 to oModel:GetModel( "MODEL_T1N" ):Length()
						oModel:GetModel( "MODEL_T1N" ):GoLine(nJ)
						oModel:GetModel( "MODEL_T1N" ):DeleteLine()
					Next nJ
				EndIf

				//Rodo o XML parseado para gravar as novas informacoes no GRID ( Cadastro de Dependentes )
				nT1N := 1
				While oDados:XPathHasNode(cT1NPath)

					If nOpc == 4 .or. nT1N > 1
						oModel:GetModel( "MODEL_T1N" ):lValid:= .T.
						oModel:GetModel( "MODEL_T1N" ):AddLine()
					EndIf

					if oDados:XPathHasNode(cT1NPath +"/indComerc")
						oModel:LoadValue( "MODEL_T1N", "T1N_INDCOM", FGetIdInt( "indComerc", "", cT1NPath +"/indComerc",,,,@cInconMsg, @nSeqErrGrv))
					EndIf

					if oDados:XPathHasNode(cT1NPath + "/vrTotCom")
						oModel:LoadValue( "MODEL_T1N", "T1N_VLRTOT", FTafGetVal( cT1NPath + "/vrTotCom",  "N", .F., @aIncons, .F. ) )
					EndIf

					//----------
					//***********
					//eSocial/evtComProd/infoComProd/ideEstabel/tpComerc/ideAdquir
					//***********
					nT1O 	 := 1
					cT1OPath := cT1NPath + "/ideAdquir[" + CVALTOCHAR(nT1O) + "]"

					If nOpc == 4
						For nJ := 1 to oModel:GetModel( "MODEL_T1O" ):Length()
							oModel:GetModel( "MODEL_T1O" ):GoLine(nJ)
							oModel:GetModel( "MODEL_T1O" ):DeleteLine()
						Next nJ
					EndIf

					nT1O := 1
					While oDados:XPathHasNode(cT1OPath)

						If nOpc == 4 .or. nT1O > 1
							oModel:GetModel( "MODEL_T1O" ):lValid:= .T.
							oModel:GetModel( "MODEL_T1O" ):AddLine()
						EndIf

						if oDados:XPathHasNode(cT1OPath + "/tpInsc")
							oModel:LoadValue( "MODEL_T1O", "T1O_TPINSA", FTafGetVal( cT1OPath + "/tpInsc",		"C", .F., @aIncons, .F. ) )
						EndIf
						if oDados:XPathHasNode(cT1OPath + "/nrInsc")
							oModel:LoadValue( "MODEL_T1O", "T1O_NRINSA", FTafGetVal( cT1OPath + "/nrInsc",  	"C", .F., @aIncons, .F. ) )
						EndIf

						if oDados:XPathHasNode(cT1OPath + "/vrComerc")
							oModel:LoadValue( "MODEL_T1O", "T1O_VLRCOM", FTafGetVal( cT1OPath + "/vrComerc",	"N", .F., @aIncons, .F. ) )
						EndIf


						//----------
						//***********
						//eSocial/evtComProd/infoComProd/ideEstabel/tpComerc/ideAdquir/nfs
						//***********
						nT6B := 1
						cT6BPath := cT1OPath + "/nfs[" + CVALTOCHAR(nT6B) + "]"

						//Deleta as linhas existentes se for alteracao
						If nOpc == 4
							For nJ := 1 to oModel:GetModel( 'MODEL_T6B' ):Length()
								oModel:GetModel( 'MODEL_T6B' ):GoLine(nJ)
								oModel:GetModel( 'MODEL_T6B' ):DeleteLine()
							Next nJ
						EndIf

						While oDados:XPathHasNode( cT6BPath)
							If nOpc == 4 .Or. nT6B > 1
								oModel:GetModel( "MODEL_T6B" ):LVALID := .T.
								oModel:GetModel( "MODEL_T6B" ):AddLine()
							EndIf

							// Grava dados no model
							If oDados:XPathHasNode(cT6BPath + "/serie")
								oModel:LoadValue( "MODEL_T6B", "T6B_SERIE ", FTafGetVal( cT6BPath  + "/serie"           	, "C", .F., @aIncons, .T. ) )
							EndIf

							If oDados:XPathHasNode(cT6BPath + "/nrDocto")
								oModel:LoadValue( "MODEL_T6B", "T6B_NUMDOC", FTafGetVal( cT6BPath  + "/nrDocto"        		, "C", .F., @aIncons, .T. ) )
							EndIf

							If oDados:XPathHasNode(cT6BPath + "/dtEmisNF")
								oModel:LoadValue( "MODEL_T6B", "T6B_DTEMIS", FTafGetVal( cT6BPath  + "/dtEmisNF"     		, "D", .F., @aIncons, .T. ) )
							EndIf

							If oDados:XPathHasNode(cT6BPath + "/vlrBruto")
								oModel:LoadValue( "MODEL_T6B", "T6B_VLBRUT", FTafGetVal( cT6BPath  + "/vlrBruto"     		, "N", .F., @aIncons, .T. ) )
							EndIf

							If oDados:XPathHasNode(cT6BPath + "/vrCPDescPR")
								oModel:LoadValue( "MODEL_T6B", "T6B_VLCONT", FTafGetVal( cT6BPath  + "/vrCPDescPR"			, "N", .F., @aIncons, .T. ) )
							EndIf

							If oDados:XPathHasNode(cT6BPath + "/vrRatDescPR")
								oModel:LoadValue( "MODEL_T6B", "T6B_VLGILR", FTafGetVal( cT6BPath  + "/vrRatDescPR"			, "N", .F., @aIncons, .T. ) )
							EndIf

							If oDados:XPathHasNode(cT6BPath + "/vrSenarDesc")
								oModel:LoadValue( "MODEL_T6B", "T6B_VLSENA", FTafGetVal( cT6BPath  + "/vrSenarDesc"  		, "N", .F., @aIncons, .T. ) )
							EndIf

							nT6B++
							cT6BPath := cT1OPath + "/nfs[" + CVALTOCHAR(nT6B) + "]"
						EndDo

						nT1O++
						cT1OPath := cT1NPath + "/ideAdquir[" + CVALTOCHAR(nT1O) + "]"
					EndDo

					//----------
					//***********
					//eSocial/evtComProd/infoComProd/ideEstabel/tpComerc/infoProcJud
					//***********
					nT1P := 1
					cT1PPath := cT1NPath + "/infoProcJud[" + CVALTOCHAR(nT1P) + "]"

					If nOpc == 4
						For nJ := 1 to oModel:GetModel( "MODEL_T1P" ):Length()
							oModel:GetModel( "MODEL_T1P" ):GoLine(nJ)
							oModel:GetModel( "MODEL_T1P" ):DeleteLine()
						Next nJ
					EndIf

					nT1P := 1
					While oDados:XPathHasNode(cT1PPath)

						If nOpc == 4 .or. nT1P > 1
							oModel:GetModel( "MODEL_T1P" ):lValid:= .T.
							oModel:GetModel( "MODEL_T1P" ):AddLine()
						EndIf

						If oDados:XPathHasNode(cT1PPath + "/tpProc") .or. oDados:XPathHasNode(cT1PPath +"/nrProc")
							cIdProc := FGetIdInt("nrProc" , "tpProc", cT1PPath + "/tpProc", cT1PPath +"/nrProc",,,@cInconMsg, @nSeqErrGrv)
							oModel:LoadValue( "MODEL_T1P", "T1P_IDPROC",	cIdProc )
						EndIf

						if !Empty(cIdProc)
							If oDados:XPathHasNode(cT1PPath + "/codSusp" )
								oModel:LoadValue("MODEL_T1P", "T1P_IDSUSP", 	FGetIdInt( "codSusp","", FTafGetVal( cT1PPath + "/codSusp", "C", .F., @aIncons, .F. ),cIdProc,.F.,,@cInconMsg, @nSeqErrGrv) )
							EndIf
						Endif

						If oDados:XPathHasNode(cT1PPath + "/vrCPSusp")
							oModel:LoadValue( "MODEL_T1P", "T1P_VLRPRV", 	FTafGetVal( cT1PPath + "/vrCPSusp",	  "N", .F., @aIncons, .F.	) )
						EndIf

						if oDados:XPathHasNode(cT1PPath + "/vrRatSusp")
							oModel:LoadValue( "MODEL_T1P", "T1P_VLRRAT",	FTafGetVal( cT1PPath + "/vrRatSusp", 	  "N", .F., @aIncons, .F.	) )
						EndIf

						if oDados:XPathHasNode(cT1PPath + "/vrSenarSusp")
							oModel:LoadValue( "MODEL_T1P", "T1P_VLRSEN", 	FTafGetVal( cT1PPath + "/vrSenarSusp",  "N", .F., @aIncons, .F.	) )
						EndIf

						nT1P++
						cT1PPath := cT1NPath + "/infoProcJud[" + CVALTOCHAR(nT1P)  +"]"
					EndDo

					nT1N++
					cT1NPath := cCabec + "/tpComerc[" + CVALTOCHAR(nT1N) + "]"
				EndDo

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
			If FindFunction('TafClearModel')
				TafClearModel(oModel)
			EndIf

		EndIf
	End Transaction

	//Zerando os arrays e os Objetos utilizados no processamento
	aSize( aRulesCad, 0 )
	aRulesCad := Nil

	aSize( aChave, 0 )
	aChave	:= Nil

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF414Rul
Regras para gravacao das informacoes do registro S-1260

@Param
nOper      - Operacao a ser realizada ( 3 = Inclusao / 4 = Alteracao / 5 = Exclusao )

@Return
aRull  - Regras para a gravacao das informacoes

@author Daniel Schmidt
@since 11/01/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF414Rul( cCabec, cInconMsg, nSeqErrGrv, cCodEvent, cOwner )

	Local cPeriodo     := ""
	Local aRull        := {}

	Default cCabec     := ""
	Default cInconMsg  := ""
	Default nSeqErrGrv := 0
	Default cCodEvent  := ""
	Default cOwner     := ""

	cCabec			   := "/eSocial/evtComProd/infoComProd/ideEstabel"

	//**********************************
	//eSocial/evtComProd/ideEvento/
	//**********************************

	If !lLaySimplif
		If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtComProd/ideEvento/indApuracao" ) )
			Aadd( aRull, { "T1M_INDAPU", "/eSocial/evtComProd/ideEvento/indApuracao", 		"C",  .F. } )	//indApuracao
		EndIf
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtComProd/ideEvento/perApur" ) )
		cPeriodo 	:= FTafGetVal("/eSocial/evtComProd/ideEvento/perApur", "C", .F.,, .F. )

		If At("-", cPeriodo) > 0
			Aadd( aRull, {"T1M_PERAPU", StrTran(cPeriodo, "-", "" ), "C", .T.} )
		Else
			Aadd( aRull, {"T1M_PERAPU", cPeriodo, "C", .T.} )
		EndIf
	EndIf

	If lLaySimplif
		If oDados:XPathHasNode("/eSocial/evtComProd/ideEvento/indGuia")                         
			Aadd( aRull, { "T1M_TPGUIA",  "/eSocial/evtComProd/ideEvento/indGuia", "C", .F. } )			
		Endif
	EndIf
	//----------------------------------

	//**********************************
	//eSocial/evtComProd/infoComProd/ideEstabel
	//**********************************
	If TafXNode( oDados, cCodEvent, cOwner,( cCabec + "/nrInscEstabRural" ) )
		Aadd( aRull,{"T1M_IDESTA", FGetIdInt( "nrInscEstabRural","",cCabec + "/nrInscEstabRural",,,,@cInconMsg, @nSeqErrGrv),"C", .T.} ) //nrInscEstabRural
	EndIf

Return ( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF414Xml
Retorna o Xml do Registro Posicionado

@author Daniel Schmidt
@since 11/01/2016
@version 1.0

@Param:
lJob - Informa se foi chamado por Job
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@return
cXml - Estrutura do Xml do Layout S-1260
/*/
//-------------------------------------------------------------------
Function TAF414Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

	Local cXml    	:= ""
	Local cXmlNfs	:= ""
	Local cTpProc  	:= ""
	Local cInCome	:= ""
	Local cLayout 	:= "1260"
	Local cReg    	:= "ComProd"
	Local aMensal	:= {}
	Local lXmlVLd   := FindFunction( 'TafXmlVLD' ) .and. Tafxmlvld( 'TAF414XML' )

	Default lJob    := .F.
	Default cAlias  := "T1M"
	Default nRecno  := 1
	Default nOpc    := 1
	Default cSeqXml := ""

	DBSelectArea("T1N")
	T1N->(DBSetOrder(1))

	DBSelectArea("T1O")
	T1O->(DBSetOrder(1))

	DBSelectArea("T6B")
	T6B->(DBSetOrder(1))

	DBSelectArea("T1P")
	T1P->(DBSetOrder(1))

	If lXmlVLd

		If T1M->T1M_INDAPU == '1'

			aAdd(aMensal, T1M->T1M_INDAPU)

			If Len(Alltrim(T1M->T1M_PERAPU)) <= 4
				AADD(aMensal,T1M->T1M_PERAPU)
			Else
				AADD(aMensal,substr(T1M->T1M_PERAPU, 1, 4) + '-' + substr(T1M->T1M_PERAPU, 5, 2) )
			EndIf

		EndIf

		cXml +=		"<infoComProd>"
		cXml +=			"<ideEstabel>"
		cXml +=				xTafTag("nrInscEstabRural",Posicione("C92",5,xFilial("C92") + T1M->T1M_IDESTA + '1',"C92_NRINSC"))

		If T1N->( MsSeek( xFilial( "T1N" ) + ('T1M')->( &( "T1M_ID") + &( "T1M_VERSAO" ) + &( "T1M_IDESTA" ) ) ) )

			While T1N->(!Eof()) .And. T1N->( T1N_FILIAL + T1N_ID + T1N_VERSAO + T1N_IDESTA ) == xFilial( "T1N" ) + ('T1M')->( &( "T1M_ID") + &( "T1M_VERSAO" ) + &( "T1M_IDESTA" ) )
				
				cXml +=			"<tpComerc>"
				cXml +=				xTafTag("indComerc"	,Posicione("T1T",1,xFilial("T1T") + T1N->T1N_INDCOM, "T1T_CODIGO") )
				cXml +=				xTafTag("vrTotCom"	,T1N->T1N_VLRTOT, PesqPict("T1N","T1N_VLRTOT") )

				cInCome := Posicione("T1T",1,xFilial("T1T") + T1N->T1N_INDCOM, "T1T_CODIGO")

				If T1O->( MsSeek( xFilial( "T1O" ) + ('T1N')->( &( "T1N_ID") + &( "T1N_VERSAO" ) + &( "T1N_IDESTA" ) + &( "T1N_INDCOM" ) ) ) )
					
					While T1O->(!Eof()) .And. T1O->( T1O_FILIAL + T1O_ID + T1O_VERSAO + T1O_IDESTA + T1O_INDCOM ) == xFilial( "T1O" ) + ('T1N')->( &( "T1N_ID") + &( "T1N_VERSAO" ) + &( "T1N_IDESTA" ) + &( "T1N_INDCOM" )  )

						If T6B->( MsSeek( xFilial( "T6B" ) +  T1O->(T1O_ID + T1O_VERSAO + T1O_IDESTA + T1O_INDCOM + T1O_TPINSA + T1O_NRINSA ) ) )
							
							Do While !T6B->( Eof() ) .And. T1O->(T1O_ID + T1O_VERSAO + T1O_IDESTA + T1O_INDCOM + T1O_TPINSA + T1O_NRINSA) == T6B->(T6B_ID + T6B_VERSAO + T6B_IDESTA + T6B_INDCOM + T6B_TPINSA + T6B_NRINSA)

								cXmlNfs +=        "<nfs>"
								cXmlNfs +=          xTafTag("serie"         , T6B->T6B_SERIE 									,							  ,.T.	)
								cXmlNfs +=          xTafTag("nrDocto"       , T6B->T6B_NUMDOC																		)
								cXmlNfs +=          xTafTag("dtEmisNF"      , T6B->T6B_DTEMIS																		)
								cXmlNfs +=          xTafTag("vlrBruto"      , T6B->T6B_VLBRUT									, PesqPict("T6B","T6B_VLBRUT")		)
								cXmlNfs +=			xTafTag("vrCPDescPR"	, Iif(Empty(T6B->T6B_VLCONT), "0", T6B->T6B_VLCONT)	, PesqPict("T6B","T6B_VLCONT")		)
								cXmlNfs +=			xTafTag("vrRatDescPR"	, Iif(Empty(T6B->T6B_VLGILR), "0", T6B->T6B_VLGILR)	, PesqPict("T6B","T6B_VLGILR")		)
								cXmlNfs +=			xTafTag("vrSenarDesc"	, Iif(Empty(T6B->T6B_VLSENA), "0", T6B->T6B_VLSENA)	, PesqPict("T6B","T6B_VLSENA")		)
								cXmlNfs +=        "</nfs>"

								T6B->( DbSkip() )
								
							EndDo

						EndIf

						If !cInCome $ "2|9"

							xTafTagGroup("ideAdquir"	,{{"tpInsc"		,T1O->T1O_TPINSA,,.F.};
														, {"nrInsc"		,T1O->T1O_NRINSA,,.F.};
														, {"vrComerc"	,T1O->T1O_VLRCOM,PesqPict("T1O","T1O_VLRCOM"),.F.}};
														, @cXml;
														,{{"nfs",cXmlNfs,0}})

						EndIf

						cXmlNfs := ""

						T1O->(DBSkip())

					EndDo

				EndIf

				If T1P->( MsSeek( xFilial( "T1P" ) + ('T1N')->( &( "T1N_ID") + &( "T1N_VERSAO" ) + &( "T1N_IDESTA" ) + &( "T1N_INDCOM" ) ) ) )
					
					While T1P->(!Eof()) .And. T1P->( T1P_FILIAL + T1P_ID + T1P_VERSAO + T1P_IDESTA + T1P_INDCOM ) == xFilial( "T1P" ) + ('T1N')->( &( "T1N_ID") + &( "T1N_VERSAO" ) + &( "T1N_IDESTA" ) + &( "T1N_INDCOM" ) )
						
						cXml +=			"<infoProcJud>"

						//Inverto os códigos para atender o layout do eSocial
						cTpProc := Posicione("C1G",8,xFilial("C1G") + T1P->T1P_IDPROC,"C1G_TPPROC")

						If !Empty( cTpProc )
							cTpProc := Iif(Alltrim(cTpProc) == "1", "2", Iif(Alltrim(cTpProc) == "2", "1", cTpProc) )
						EndIf

						cXml +=				xTafTag("tpProc",		cTpProc )
						cXml +=				xTafTag("nrProc",		Posicione("C1G",8,xFilial("C1G") + T1P->T1P_IDPROC,"C1G_NUMPRO") )

							cCodSusp  	:= Posicione("T5L",1,xFilial("T5L")+T1P->T1P_IDSUSP,"T5L_CODSUS")

							If !Empty(cCodSusp)
								cXml += xTafTag("codSusp", Alltrim(cCodSusp))
							EndIf

							cXml +=				xTafTag("vrCPSusp"	, T1P->T1P_VLRPRV , PesqPict("T1P","T1P_VLRPRV"),,.T.)
							cXml +=				xTafTag("vrRatSusp"	, T1P->T1P_VLRRAT , PesqPict("T1P","T1P_VLRRAT"),,.T.)
							cXml +=				xTafTag("vrSenarSusp", T1P->T1P_VLRSEN , PesqPict("T1P","T1P_VLRSEN"),,.T.)
							cXml +=			"</infoProcJud>"

							T1P->(DBSkip())
					EndDo

				EndIf

				cXml +=			"</tpComerc>"

				T1N->(DBSkip())

			EndDo

		EndIf

		T1N->(DbCloseArea())

		cXml +=			"</ideEstabel>"
		cXml +=		"</infoComProd>"

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Estrutura do cabecalho³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		cXml := xTafCabXml(cXml,"T1M",cLayout,cReg,aMensal,cSeqXml)

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Executa gravacao do registro³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
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

@author Daniel Schmidt
@since 11/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )

	Local cVerAnt    	 
	Local cProtocolo 	 
	Local cVersao    	 
	Local cChvRegAnt 	 
	Local cEvento	 	 
	Local cId		 	 

	Local nOperation 	 
	Local nI         	 
	Local nT1N		 	 
	Local nT1O		 	 
	Local nT1P		 	 
	Local nT6B		 	 

	Local aCampos    	 
	Local aGrava     	 
	Local aGravaT1N  	 
	Local aGravaT1O  	 
	Local aGravaT1P  	 
	Local aGravaT6B  	 

	Local oModelT1M  	 
	Local oModelT1N  	 
	Local oModelT1O  	 
	Local oModelT1P  	 
	Local oModelT6B  	 

	cVerAnt    := ""
	cProtocolo := ""
	cVersao    := ""
	cChvRegAnt := ""
	cEvento    := ""
	cId        := ""
	nOperation := oModel:GetOperation()
	nI         := 0
	nT1N       := 0
	nT1O       := 0
	nT1P       := 0
	nT6B       := 0
	aCampos    := {}
	aGrava     := {}
	aGravaT1N  := {}
	aGravaT1O  := {}
	aGravaT1P  := {}
	aGravaT6B  := {}
	oModelT1M  := Nil
	oModelT1N  := Nil
	oModelT1O  := Nil
	oModelT1P  := Nil
	oModelT6B  := Nil

	Begin Transaction

		//Posiciona o item
		("T1M")->( DBGoTo( nRecno ) )

		//Carrego a Estrutura dos Models a serem gravados
		oModelT1M := oModel:GetModel( "MODEL_T1M" )
		oModelT1N := oModel:GetModel( "MODEL_T1N" )
		oModelT1O := oModel:GetModel( "MODEL_T1O" )
		oModelT1P := oModel:GetModel( "MODEL_T1P" )
		oModelT6B := oModel:GetModel( "MODEL_T6B" )


		//Guardo as informações do registro corrente para rastro do registro
		cVerAnt   	:= oModelT1M:GetValue( "T1M_VERSAO" )
		cProtocolo	:= oModelT1M:GetValue( "T1M_PROTUL" )
		cEvento	:= oModelT1M:GetValue( "T1M_EVENTO" )

		//Armazeno as informações correntes do cadastro( Depois da alteração do Usuário )

		//***********
		//Informação da Comercialização de Produção
		//***********
		For nI := 1 to Len( oModelT1M:aDataModel[ 1 ] )
			Aadd( aGrava, { oModelT1M:aDataModel[ 1, nI, 1 ], oModelT1M:aDataModel[ 1, nI, 2 ] } )
		Next nI
		//------------------

		//***********
		//Tipo de Comercialização
		//***********
		//***********
		For nT1N := 1 to oModel:GetModel( "MODEL_T1N" ):Length()
			oModel:GetModel( "MODEL_T1N" ):GoLine(nT1N)
			If !oModel:GetModel( 'MODEL_T1N' ):IsEmpty()
				If !oModel:GetModel( "MODEL_T1N" ):IsDeleted()
					aAdd(aGravaT1N,{oModelT1N:GetValue("T1N_INDCOM"),;
									oModelT1N:GetValue("T1N_VLRTOT")})

					//***********
					//Identificação dos Adquirentes da Produção
					//***********
					For nT1O := 1 to oModel:GetModel( "MODEL_T1O" ):Length()
						oModel:GetModel( "MODEL_T1O" ):GoLine(nT1O)
						If !oModel:GetModel( 'MODEL_T1O' ):IsEmpty()
							If !oModel:GetModel( "MODEL_T1O" ):IsDeleted()
								aAdd(aGravaT1O,{oModelT1N:GetValue("T1N_INDCOM"),;
												oModelT1O:GetValue("T1O_TPINSA"),;
												oModelT1O:GetValue("T1O_NRINSA"),;
												oModelT1O:GetValue("T1O_VLRCOM")})


								For nT6B := 1 To oModel:GetModel( 'MODEL_T6B' ):Length()
									oModel:GetModel( 'MODEL_T6B' ):GoLine(nT6B)

									If !oModel:GetModel( 'MODEL_T6B' ):IsDeleted()
										aAdd (aGravaT6B ,{ oModelT1N:GetValue("T1N_INDCOM"),;
														oModelT1O:GetValue("T1O_TPINSA"),;
														oModelT1O:GetValue("T1O_NRINSA"),;
														oModelT6B:GetValue("T6B_SERIE"),;
														oModelT6B:GetValue("T6B_NUMDOC"),;
														oModelT6B:GetValue("T6B_DTEMIS"),;
														oModelT6B:GetValue("T6B_VLBRUT"),;
														oModelT6B:GetValue("T6B_VLCONT"),;
														oModelT6B:GetValue("T6B_VLGILR"),;
														oModelT6B:GetValue("T6B_VLSENA")} )
									EndIf
								Next nT6B
							EndIf
						EndIf
					Next nT1O
					//-----------
					//***********
					//Informações de Processos Judiciais
					//***********
					For nT1P := 1 to oModel:GetModel( "MODEL_T1P" ):Length()
						oModel:GetModel( "MODEL_T1P" ):GoLine(nT1P)
						If !oModel:GetModel( 'MODEL_T1P' ):IsEmpty()
							If !oModel:GetModel( 'MODEL_T1P' ):IsDeleted()
								aAdd(aGravaT1P,{oModelT1N:GetValue("T1N_INDCOM"),;
												oModelT1P:GetValue("T1P_IDPROC"),;
												oModelT1P:GetValue("T1P_VLRPRV"),;
												oModelT1P:GetValue("T1P_VLRRAT"),;
												oModelT1P:GetValue("T1P_VLRSEN")})
							EndIf
						EndIf
					Next nT1P
					//-----------

				EndIf
			EndIf
		Next nT1N
		//-----------

		/*----------------------------------------------------------
		Seto o campo como Inativo e gravo a versao do novo registro
		no registro anterior

		ATENCAO -> A alteracao destes campos deve sempre estar
		abaixo do Loop do For, pois devem substituir as informacoes
		que foram armazenadas no Loop acima
		-----------------------------------------------------------*/
		FAltRegAnt( "T1M", "2" )

		/*----------------------------------------------------------
		Apos deixar o registro corrente como inativo eu seto a
		operação de inclusão para o novo registro
		-----------------------------------------------------------*/
		oModel:DeActivate()
		oModel:SetOperation( 3 )
		oModel:Activate()

		/*----------------------------------------------------------
		Neste momento eu realizo a gravação de um novo registro idêntico
		ao original, apenas com as alterações nos campos modificados
		pelo usuário no cadastro
		-----------------------------------------------------------*/
		//***********
		//Informação da Comercialização de Produção
		//***********
		For nI := 1 to Len( aGrava )
			oModel:LoadValue( "MODEL_T1M", aGrava[ nI, 1 ], aGrava[ nI, 2 ] )
		Next nI

		//***********
		//Tipo de Comercialização
		//***********
		For nT1N := 1 to Len( aGravaT1N )
			If nT1N > 1
				oModel:GetModel( "MODEL_T1N" ):AddLine()
			EndIf
			oModel:LoadValue( "MODEL_T1N", "T1N_INDCOM" , aGravaT1N[nT1N][1] )
			oModel:LoadValue( "MODEL_T1N", "T1N_VLRTOT" , aGravaT1N[nT1N][2] )

			//***********
			//Identificação dos Adquirentes da Produção
			//***********
			For nT1O := 1 to Len( aGravaT1O )
				If  aGravaT1N[nT1N][1] == aGravaT1O[nT1O][1]
					If nT1O > 1
						oModel:GetModel( "MODEL_T1O" ):AddLine()
					EndIf
					oModel:LoadValue( "MODEL_T1O", "T1O_TPINSA" , aGravaT1O[nT1O][2] )
					oModel:LoadValue( "MODEL_T1O", "T1O_NRINSA" , aGravaT1O[nT1O][3] )
					oModel:LoadValue( "MODEL_T1O", "T1O_VLRCOM" , aGravaT1O[nT1O][4] )

					For nT6B := 1 To Len( aGravaT6B )
						If aGravaT1N[nT1N][1] == aGravaT6B[nT6B][1] .AND. aGravaT1O[nT1O][2] == aGravaT6B[nT6B][2] .AND. aGravaT1O[nT1O][3] == aGravaT6B[nT6B][3]

							If nT6B > 1
								oModel:GetModel( 'MODEL_T6B' ):AddLine()
							EndIf
							oModel:LoadValue( "MODEL_T6B", "T6B_SERIE",  aGravaT6B[nT6B][4] )
							oModel:LoadValue( "MODEL_T6B", "T6B_NUMDOC", aGravaT6B[nT6B][5] )
							oModel:LoadValue( "MODEL_T6B", "T6B_DTEMIS", aGravaT6B[nT6B][6] )
							oModel:LoadValue( "MODEL_T6B", "T6B_VLBRUT", aGravaT6B[nT6B][7] )
							oModel:LoadValue( "MODEL_T6B", "T6B_VLCONT", aGravaT6B[nT6B][8] )
							oModel:LoadValue( "MODEL_T6B", "T6B_VLGILR", aGravaT6B[nT6B][9] )
							oModel:LoadValue( "MODEL_T6B", "T6B_VLSENA", aGravaT6B[nT6B][10] )
						EndIf

					Next nT6B
				EndIf
			Next nT1O

			//***********
			//Informações de Processos Judiciais
			//***********
			For nT1P := 1 to Len( aGravaT1P )
				If  aGravaT1N[nT1N][1] == aGravaT1P[nT1P][1]
					oModel:GetModel( 'MODEL_T1P' ):LVALID	:= .T.

					If nT1P > 1
						oModel:GetModel( "MODEL_T1P" ):AddLine()
					EndIf
					oModel:LoadValue( "MODEL_T1P", "T1P_IDPROC",	aGravaT1P[nT1P][2] )
					oModel:LoadValue( "MODEL_T1P", "T1P_VLRPRV",	aGravaT1P[nT1P][3] )
					oModel:LoadValue( "MODEL_T1P", "T1P_VLRRAT",	aGravaT1P[nT1P][4] )
					oModel:LoadValue( "MODEL_T1P", "T1P_VLRSEN",	aGravaT1P[nT1P][5] )
				EndIf
			Next nT1P

		Next nT1N

		//Busco a nova versao do registro
		cVersao := xFunGetVer()

		/*---------------------------------------------------------
		ATENCAO -> A alteracao destes campos deve sempre estar
		abaixo do Loop do For, pois devem substituir as informacoes
		que foram armazenadas no Loop acima
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_T1M", "T1M_VERSAO", cVersao )
		oModel:LoadValue( "MODEL_T1M", "T1M_VERANT", cVerAnt )
		oModel:LoadValue( "MODEL_T1M", "T1M_PROTPN", cProtocolo )
		oModel:LoadValue( "MODEL_T1M", "T1M_PROTUL", "" )

		/*---------------------------------------------------------
		Tratamento para que caso o Evento Anterior fosse de exclusão
		seta-se o novo evento como uma "nova inclusão", caso contrário o
		evento passar a ser uma alteração
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_T1M", "T1M_EVENTO","E" )
		oModel:LoadValue( "MODEL_T1M", "T1M_ATIVO", "1" )

		FwFormCommit( oModel )
		TAFAltStat( 'T1M',"6" )

	End Transaction

Return ( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} ImportDataNF

Função responsável por realizar importação de Notas Fiscais para
Consumidor / Comerciante Rural.
Eventos : S-1260

@author Rodrigo Nicolino/Jose Riquelmo
@since 28/04/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function ImportDataNF(oModel)

	Local aParamsGRAT       := {}
	Local aT1N              := {}
	Local aT1O              := {}
	Local aT6B              := {}
	Local cBusca            := ""
	Local cIndCom           := ""
	Local cIndCom2          := ""
	Local cIndCom3          := ""
	Local cIndCom7          := ""
	Local cIndCom8          := ""
	Local cIndCom9          := ""
	Local cIndComAnt        := ""
	Local cNrInsc           := ""
	Local cNrInscAnt        := ""
	Local cParamGilRat      := ""
	Local cPerApur          := ""
	Local cPerGilRat        := ""
	Local cQuery            := ""
	Local cSubStr           := ""
	Local cTemp             := GetNextAlias()
	Local cTpCAEPF          := ""
	Local cTpInsc           := ""
	Local cTpInscAnt        := ""
	Local cTpInscr          := ""
	Local lCalcGilRat       := .F.
	Local lComerExterior    := .F.
	Local lComerIsenta      := .F.
	Local lEstabProdRural   := .F.
	Local lEstabSegEspecial := .F.
	Local lPartPAA          := .F.
	Local lPartPF           := .F.
	Local lPartPJ           := .F.
	Local lPartProdRural    := .F.
	Local n                 := 1
	Local nAliqCP           := 0
	Local nAliqGilRat       := 0
	Local nAliqRat          := 0
	Local nT1N              := 1
	Local nT1O              := 1
	Local NT6B              := 1
	Local nValTotT1O        := 0
	Local nVlrCom2          := 0
	Local nVlrCom3          := 0
	Local nVlrCom7          := 0
	Local nVlrCom8          := 0
	Local nVlrCom9          := 0
	Local nVlrCP            := 0
	Local nVlrRAT           := 0
	Local oModelT1N         := Nil
	Local oModelT1O         := Nil
	Local oModelT6B         := Nil
	Local x                 := 1
	Local y                 := 1

	If !TafColumnPos("AI0_CPFRUR")
		MsgAlert("O campo AI0_CPFRUR não existe na base de dados, a falta dele pode ocasionar diferença nos valores apresentados")
	EndIf

	cBusca := BuscaDocs()

	cSubStr		 := Iif(TcGetDb() $ "ORACLE|DB2", "SUBSTR", "SUBSTRING")

	//Carrega variáveis para localizar CGC no Sigamat e posicionar.
	oModelCMR	:= oModel:GetModel( 'MODEL_T1M' )							// Model infos do Estabelecimento
	cPerApur	:= oModelCMR:GetValue("T1M_PERAPU")							// Periodo de apuração
	cCGC		:= AllTrim(oModelCMR:GetValue("T1M_NRCAEP"))				// Numero do Doc do Estabelecimento no Model
	cIdEstab	:= AllTrim(oModelCMR:GetValue("T1M_IDESTA"))				// Id do Estabelecimento do Model
	cTpInscr 	:= POSICIONE("C92",5, xFilial("C92") + cIdEstab + "1","C92_TPINSC") // Solicita o tipo do produtor no S-1005

	If !Empty(cTpInscr) .and. cTpInscr != "3"
		MsgAlert("O Estabeleciomento Selecionado deve ser obrigatoriamente do tipo 3-CAEPF")
		Return 
	EndIf

	cParamGilRat := SuperGetMv('MV_TAFCALG',.F.,"199901;1.2;0.1") 
	aParamsGRAT  := StrToKArr(cParamGilRat,";")

	If ValType(aParamsGRAT) == "A" .And. Len(aParamsGRAT) == 3

		cPerGilRat 	:= aParamsGRAT[1]
		nAliqRat 	:= Val(aParamsGRAT[3])
		nAliqCP	   	:= Val(aParamsGRAT[2])
		nAliqGilRat := nAliqRat + nAliqCP	
		lCalcGilRat	:= cPerApur <= cPerGilRat

	EndIf 

	If !Empty(cPerApur) .And. !Empty(cIdEstab)

		oModelT1N := oModel:GetModel( 'MODEL_T1N' )
		oModelT1O := oModel:GetModel( 'MODEL_T1O' )
		oModelT6B := oModel:GetModel( 'MODEL_T6B' )

		cQuery	:=	" SELECT C20.C20_FILIAL AS FILIAL "
		cQuery	+=	" ,C1H.C1H_CNPJ 		AS PART_CNPJ "
		cQuery	+=	" ,C1H.C1H_CPF 		  	AS PART_CPF "
		cQuery	+=	" ,C1H.C1H_PAA 		  	AS PART_PAA "
		cQuery	+=	" ,C1H.C1H_PPES 	  	AS PART_TIPO "
		cQuery	+=	" ,C1H.C1H_RAMO 	  	AS PART_RAMO "
		cQuery	+=	" ,SUM(C20.C20_VLDOC) 	AS VALTOT "
		cQuery	+=	" ,C20.C20_SERIE	  	AS SERIE "
		cQuery	+=	" ,C20.C20_NUMDOC     	AS NUMDOC "
		cQuery	+=	" ,C20.C20_DTDOC	  	AS DATA_DOC "
		
		cQuery	+=	" ,CASE WHEN (" + querySomaTrib("24") + ") IS NULL THEN 0 "
		cQuery	+=	" 		ELSE (" + querySomaTrib("24") + ") "
		cQuery	+=	" END AS GILRAT "
		cQuery	+=	" ,CASE WHEN (" + querySomaTrib("25") + ") IS NULL THEN 0 "
		cQuery	+=	" 	   	ELSE (" + querySomaTrib("25") + ") "
		cQuery	+=	" END AS SENAR "
		cQuery	+=	" ,CASE WHEN (" + querySomaTrib("13") + ") IS NULL THEN 0 "
		cQuery	+=	" 	   	ELSE (" + querySomaTrib("13") + ") "
		cQuery	+=	" END AS PREVID "	

		cQuery	+=	" ,(SELECT COUNT(*) "
		cQuery	+=	" FROM " + RetsqlName("C30") + " C30 "
		cQuery	+=	" INNER JOIN " + RetSqlName("C0Y") + " ON C30_CFOP = C0Y_ID "
		cQuery	+=	" WHERE C30_FILIAL = C20.C20_FILIAL "
		cQuery	+=	" AND C30_CHVNF = C20.C20_CHVNF "
		cQuery	+=	" AND " + cSubStr + "(C0Y_CODIGO,1,1) = '7' "
		cQuery	+=	" AND C30.D_E_L_E_T_ = '') NF_EXTERIOR "

		cQuery	+=	" ,(SELECT COUNT(*) "
		cQuery	+=	" FROM " + RetsqlName("C30") + " C30 " 
		cQuery	+=	" WHERE C30_FILIAL = C20.C20_FILIAL "
		cQuery	+=	" AND C30_CHVNF = C20.C20_CHVNF "
		cQuery	+=	" AND C30_INDISE = '1' "
		cQuery	+=	" AND C30.D_E_L_E_T_ = '') COM_ISENTA "	

		cQuery	+=	" FROM " + RetSqlName( 'C20' ) + " C20 "
		cQuery	+=	" INNER JOIN " + RetSqlName( 'C1H' ) + " C1H "
		cQuery	+=	" ON (C1H.C1H_FILIAL = '" + xFilial('C1H') + "' "
		cQuery	+=	" AND C1H.C1H_ID = C20.C20_CODPAR "
		cQuery	+=	" AND C1H.D_E_L_E_T_ = '') "

		cQuery	+=	" WHERE C20.C20_FILIAL = '" + xFilial('C20') + "' "
		cQuery	+=	" AND C20.C20_INDOPE ='1' "

		cQuery  +=  " AND " + cSubStr + "(C20.C20_DTDOC,1,6) = '" + cPerApur + "'"
		
		cQuery	+=	" AND (C20.C20_CODSIT <> '000003' AND C20.C20_CODSIT <> '000004' AND C20.C20_CODSIT <> '000005' AND C20.C20_CODSIT <> '000006') "
		cQuery	+=	" AND C20.D_E_L_E_T_ = '' "

		cQuery +=   " AND EXISTS (SELECT 1 "
		cQuery +=   " FROM " + RetSqlName('C35') + " C35"
		cQuery +=	" INNER JOIN " + RetSqlName( 'C3S' ) + " C3S "
		cQuery +=	" ON  C35.C35_CODTRI = C3S.C3S_ID "
		cQuery +=	" AND C35.D_E_L_E_T_ = '' "
		cQuery +=   " WHERE  C35.C35_FILIAL = C20.C20_FILIAL " 
		cQuery +=	" AND C35.C35_CHVNF = C20.C20_CHVNF "
		cQuery +=   " AND C3S.C3S_CODIGO IN ('13','24','25')) " 

		cQuery	+=	" GROUP BY C20.C20_FILIAL, C1H.C1H_CNPJ, C1H.C1H_CPF, C1H.C1H_PAA, C1H.C1H_PPES, C1H.C1H_RAMO, C20.C20_CHVNF, C20.C20_SERIE, C20.C20_NUMDOC, C20.C20_DTDOC  "
		
		cQuery	+=	" UNION ALL "

		cQuery	+=	" SELECT  LEM_FILIAL 	AS FILIAL "
		cQuery	+=	" ,C1H.C1H_CNPJ			AS PART_CNPJ "
		cQuery	+=	" ,C1H.C1H_CPF			AS PART_CPF "
		cQuery	+=	" ,C1H.C1H_PAA			AS PART_PAA "
		cQuery	+=	" ,C1H.C1H_PPES			AS PART_TIPO "
		cQuery	+=	" ,C1H.C1H_RAMO			AS PART_RAMO "
		cQuery	+=	" ,LEM_VLBRUT			AS VALTOT "
		cQuery	+=	" ,LEM_PREFIX			AS SERIE "
		cQuery	+=	" ,LEM_NUMERO			AS NUMDOC "
		cQuery	+=	" ,LEM_DTEMIS			AS DATA_DOC "
		cQuery	+=	" ,LEM_VLRCP			AS GILRAT "
		cQuery	+=	" ,LEM_VLRGIL			AS SENAR "
		cQuery	+=	" ,LEM_VLRSEN			AS PREVID "
		cQuery	+=	" ,(SELECT COUNT(*) "
		cQuery	+=	" FROM " + RetSqlName("C08") + " C08 " 
		cQuery	+=	" WHERE C08.C08_ID = C1H.C1H_CODPAI "
		cQuery	+=	" AND C08.C08_CODIGO != '01058' "
		cQuery	+=	" AND C08.D_E_L_E_T_ = ' ') AS NF_EXTERIOR "
		cQuery	+=	" ,0				AS COM_ISENTA "
		cQuery	+=	" FROM " + RetSqlName("LEM") + " LEM "
		cQuery	+=	" INNER JOIN " + RetSqlName("C1H") + " C1H ON C1H.C1H_FILIAL = '" + xFilial("C1H") + "' "
		cQuery	+=	" AND C1H.C1H_ID = LEM.LEM_IDPART "
		cQuery	+=	" AND C1H.D_E_L_E_T_ = '' "
		cQuery	+=	" WHERE "
		cQuery	+=	" LEM.LEM_FILIAL = '" + xFilial("LEM") + "'" 
		cQuery	+=	" AND LEM.LEM_DOCORI = ' '
		cQuery	+=	" AND " + cSubStr + "(LEM_DTEMIS,1,6) = '" + cPerApur + "'"
		cQuery	+=	" AND LEM.D_E_L_E_T_ = ' ' "
		cQuery	+=	" AND LEM.LEM_VLRCP > 0 "
		cQuery	+=	" AND LEM.LEM_VLRGIL > 0 "
		cQuery	+=	" AND LEM.LEM_VLRSEN > 0 "
		cQuery	+=	" ORDER BY FILIAL "
		cQuery	+=	" ,PART_CNPJ "
		cQuery	+=	" ,PART_CPF "

		// Executa a Query.
		DBUseArea( .T., "TOPCONN", TCGenQry( ,, ChangeQuery( cQuery ) ), cTemp, .F., .T. )

		While ( cTemp )->( !Eof() )

			/*
			2 - Comercialização da Produção efetuada diretamente no varejo a consumidor final ou a outro produtor rural pessoa física por Produtor Rural Pessoa Física, inclusive por Segurado Especial ou por Pessoa Física não produtor rural;
			3 - Comercialização da Produção por Prod. Rural PF/Seg. Especial - Vendas a PJ (exceto Entidade inscrita no Programa de Aquisição de Alimentos - PAA) ou a Intermediário PF;
			7 - Comercialização da Produção Isenta de acordo com a Lei nº 13.606/2018;
			8 - Comercialização da Produção da Pessoa Física/Segurado Especial para Entidade inscrita no Programa de Aquisição de Alimentos - PAA;
			9 - Comercialização da Produção no Mercado Externo.
			*/

			lPartProdRural 	:= (cTemp)->PART_RAMO == "4" //Participante Produtor Rural 
			lPartPF			:= (cTemp)->PART_TIPO == "1" //Participante Pessoa Fisica
			lPartPJ			:= (cTemp)->PART_TIPO == "2" //Participante Pessoa Juridica
			lPartPAA		:= (cTemp)->PART_PAA  == "1" //Participante PAA
			lComerExterior	:= (cTemp)->NF_EXTERIOR > 0  //Comercialização para o Mercado Externo
			lComerIsenta	:= (cTemp)->COM_ISENTA  > 0  //Comercializac?a?o da produc?a?o isenta de acordo com a Lei 13.606/2018
			
			lEstabProdRural   := cTpCAEPF == "2"  	
			lEstabSegEspecial := cTpCAEPF == "3"

			Do Case
				Case lComerExterior
					cIndCom9	:= Posicione("T1T", 2, xFilial("T1T") + "9", "T1T_ID")
					nVlrCom9	:= nVlrCom9 + (cTemp)->VALTOT	
					cIndCom     := cIndCom9
				Case lComerIsenta
					cIndCom7	:= Posicione("T1T", 2, xFilial("T1T") + "7", "T1T_ID")
					nVlrCom7	:= nVlrCom7 + (cTemp)->VALTOT
					cIndCom		:= cIndCom7 
				Case lPartPAA
					cIndCom8	:= Posicione("T1T", 2, xFilial("T1T") + "8", "T1T_ID")
					nVlrCom8	:= nVlrCom8 + (cTemp)->VALTOT
					cIndCom   	:= cIndCom8
				Case !lPartPAA .And. lPartPJ
					cIndCom3	:= Posicione("T1T", 2, xFilial("T1T") + "3", "T1T_ID")
					nVlrCom3	:= nVlrCom3 + (cTemp)->VALTOT	
					cIndCom   	:= cIndCom3
				Case lPartProdRural .Or. lPartPF
					cIndCom2	:= Posicione("T1T", 2, xFilial("T1T") + "2", "T1T_ID")
					nVlrCom2	:= nVlrCom2 + (cTemp)->VALTOT
					cIndCom   	:= cIndCom2	
			End Case

			//Grava T1O
			If !Empty((cTemp)->PART_CNPJ) .And. !lPartPF
				cTpInsc := "1"
				cNrInsc := (cTemp)->PART_CNPJ
			Else
				cTpInsc := "2"
				cNrInsc := (cTemp)->PART_CPF
			EndIf

			If cNrInscAnt <> cNrInsc

				If Empty(cNrInscAnt)

					cIndComAnt	:= cIndCom
					cTpInscAnt	:= cTpInsc
					cNrInscAnt  := cNrInsc
					nValTotT1O 	:= (cTemp)->VALTOT

				Else

					aAdd(aT1O, {cIndComAnt, cTpInscAnt, cNrInscAnt, nValTotT1O})
					cIndComAnt	:= cIndCom
					cTpInscAnt	:= cTpInsc
					cNrInscAnt  := cNrInsc
					nValTotT1O 	:= (cTemp)->VALTOT

				EndIf

			Else
				nValTotT1O := nValTotT1O + (cTemp)->VALTOT
			EndIf

			nVlrRAT := 0
			nVlrCP  := 0		

			//Realiza o rateio do valor referente ao GilRat de o periodo de apuração for menor ou igual ao valor 
			//do parâmetro MV_TAFCALG 

			//Mesmo com a configuração do parâmetro a rotina só faz o rateio se o valor do GILRAT for referente 
			//a aliquota de 1.3% (pode mudar de acordo com o parâmetro) e o imposto de contribuição previdênciária
			//for igual a 0, nesta situação o valor da contribuição previdenciaria está incluido no valor do GilRat. 

			If lCalcGilRat
				If (Round((cTemp)->VALTOT * nAliqGilRat / 100,2) == Round((cTemp)->GILRAT,2) .And. (cTemp)->PREVID == 0)
					nVlrRAT	   := Round((cTemp)->VALTOT * nAliqRat / 100,2) 
					nVlrCP	   := Round((cTemp)->VALTOT * nAliqCP  / 100,2) 
				EndIf 
			EndIf 

			If nVlrRAT == 0
				nVlrRAT	   := (cTemp)->GILRAT
				nVlrCP	   := (cTemp)->PREVID
			EndIf 

			//GRAVA T6B
			aAdd(aT6B,{	 cIndCom;
						,cTpInsc;
						,cNrInsc;
						,Alltrim((cTemp)->SERIE);
						,Alltrim((cTemp)->NUMDOC);
						,SToD((cTemp)->DATA_DOC);
						,(cTemp)->VALTOT;
						,nVlrRAT;
						,(cTemp)->SENAR;
						,nVlrCP})

			( cTemp )->( dbSkip() )

		EndDo

		aAdd(aT1O, {cIndComAnt, cTpInscAnt, cNrInscAnt, nValTotT1O})

		aT1N := {}

		If !Empty(cIndCom2)
			aAdd(aT1N, {cIndCom2, nVlrCom2})	
		EndIf
		
		If !Empty(cIndCom3)
			aAdd(aT1N, {cIndCom3, nVlrCom3})		
		EndIf
		
		If !Empty(cIndCom8)
			aAdd(aT1N, {cIndCom8, nVlrCom8})	
		EndIf
		
		If !Empty(cIndCom9)
			aAdd(aT1N, {cIndCom9, nVlrCom9})	
		EndIf	
		
		If !Empty(cIndCom7)
			aAdd(aT1N, {cIndCom7, nVlrCom7})		
		EndIf

		For n := 1 To Len(aT1N)

			If nT1N > 1
				oModel:GetModel( 'MODEL_T1N' ):AddLine()
			EndIf

			oModel:LoadValue( "MODEL_T1N", "T1N_INDCOM", aT1N[n,1] 	)
			oModel:LoadValue( "MODEL_T1N", "T1N_VLRTOT", aT1N[n,2]	)

			cCpoAtu := "T1N_INDCOM"

			If !(aT1N[n,1] $ "000001|000004") .And. !(cBusca $ "0|1")

				For x := 1 To Len(aT1O)

					If aT1N[n,1] == aT1O[x,1]

						If nT1O > 1
							oModel:GetModel( 'MODEL_T1O' ):AddLine()
						EndIf

						oModel:LoadValue( "MODEL_T1O", "T1O_TPINSA", aT1O[x,02]	)
						oModel:LoadValue( "MODEL_T1O", "T1O_NRINSA", aT1O[x,03]	)
						oModel:LoadValue( "MODEL_T1O", "T1O_VLRCOM", aT1O[x,04]	)

						For y := 1 To Len(aT6B)
						
							If aT1O[x,3] == aT6B[y,3]

								If nT6B > 1
									oModel:GetModel( 'MODEL_T6B' ):AddLine()
								EndIf

								oModel:LoadValue( "MODEL_T6B", "T6B_SERIE" , aT6B[y,04]	)
								oModel:LoadValue( "MODEL_T6B", "T6B_NUMDOC", aT6B[y,05]	)
								oModel:LoadValue( "MODEL_T6B", "T6B_DTEMIS", aT6B[y,06]	)
								oModel:LoadValue( "MODEL_T6B", "T6B_VLBRUT", aT6B[y,07]	)
								oModel:LoadValue( "MODEL_T6B", "T6B_VLCONT", aT6B[y,10]	)
								oModel:LoadValue( "MODEL_T6B", "T6B_VLGILR", aT6B[y,08]	)
								oModel:LoadValue( "MODEL_T6B", "T6B_VLSENA", aT6B[y,09]	)

								nT6B++

							EndIf
							
						Next
						
						nT6B := 1
						nT1O++

					EndIf

				Next

				nT1O := 1

			EndIf

			nT1N++

		Next

		(cTemp)->( DBCloseArea() )
		oModel:GetModel( 'MODEL_T1N' ):GoLine( 1 )
		oModel:GetModel( 'MODEL_T1O' ):GoLine( 1 )
		oModel:GetModel( 'MODEL_T6B' ):GoLine( 1 )

		MsgAlert(STR0015)//"Processo de Importação de Notas Fiscais Concluído"

	ElseIf Empty(cPerApur)

		MsgAlert(STR0016)//"Informar o periodo para importação das Notas Fiscais( Per.Apuração )"

	ElseIf Empty(cIdEstab)

		MsgAlert(STR0018)//"Informar o código do estabelecimento que comercializou a produção( Id. Estab.)"

	EndIf

Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} querySomaTrib

Retorna query responsavel por somar os tributos de um documento
fiscal

@author Evandro dos Santos Oliveira
@since 27/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function querySomaTrib(cCodTrib)

	Local cQuery := ""

	cQuery	+=	" SELECT SUM(TRIB.C35_VALOR) "
	cQuery	+=	" FROM " + RetSqlName( 'C3S' ) + " C3S," + RetSqlName( 'C35' ) + " TRIB"
	cQuery	+=	" WHERE TRIB.C35_CODTRI = C3S.C3S_ID "
	cQuery	+=	" AND TRIB.C35_FILIAL = C20.C20_FILIAL "
	cQuery	+=	" AND TRIB.C35_CHVNF = C20.C20_CHVNF "
	cQuery	+=	" AND TRIB.D_E_L_E_T_ = '' "
	cQuery	+=	" AND C3S.C3S_FILIAL = '" + xFilial('C3S') + "' "
	cQuery	+=	" AND C3S.D_E_L_E_T_ = '' "
	cQuery	+=	" AND C3S.C3S_CODIGO = '" + cCodTrib + "'" 
	
Return cQuery 

//-------------------------------------------------------------------
/*/{Protheus.doc} SearchSM0

Função responsável por localizar Código de Empresa e Filial do CGC
selecionado

Eventos : S-2150 e S-2160

@author Ricardo
@since 09/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function SearchSM0(cCGC)

	Local lOk
	Local aRet
	Local aAreaSM0

	Default cCGC := ""

	aAreaSM0 := {}
	aAreaSM0 := SM0->( getArea() )

	lOk	:= .F.
	aRet := {}

	If !EMPTY(cCGC)
		//Procura Empresa/Filial com as informações passadas no Model T1M
		SM0->(DBGOTOP())

		While !SM0->(Eof()) .And. !lOk
			If !Empty(cCGC)
				If AllTrim(SM0->M0_CGC) == AllTrim(cCGC)

					lOk	:= .T.
					aadd(aRet,{SM0->M0_CODIGO,SM0->M0_CODFIL})

				EndIf
			EndIf
			SM0->(DbSkip())
		EndDo
	EndIf

	RestArea( aAreaSM0 )

Return(aRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} BuscaDocs
ComboBox para perguntar se a busca por documentos será somente de 
totalização ou de totalização mais as notas fiscais

@Return	cRet	- Valor selecionado no combo

@Author	Rodrigo Nicolino
@Since		16/02/2022
/@Version	1.0
//*/
//---------------------------------------------------------------------
Static Function BuscaDocs()

	Local aModelos    := {"", "Somente Totalização", "Totalização + NFs"}
	Local bClose      := {||}
	Local cCombo      := ""
	Local cRet        := ""
	Local cTitModelo  := "Buscar Docs"
	Local lCheck      := .F.
	Local nAltura     := 180
	Local nAlturaBox  := 0
	Local nLargura    := 300
	Local nLarguraBox := 0
	Local nLarguraSay := 0
	Local nPosIni     := 0
	Local nTop        := 0
	Local oDlg        := Nil
	Local oFont       := Nil
	Local oProfile    := Nil

	oFont := TFont():New( "Arial",, -11 )

	oDlg := MsDialog():New( 0, 0, nAltura, nLargura, "Parâmetros",,,,,,,,, .T. ) //"Parâmetros"

	bClose := { || ( SetProfile( oProfile, lCheck, MV_PAR01 ), oDlg:End() ) }

	oProfile := FWProfile():New()
	oProfile:SetUser( RetCodUsr() )
	oProfile:SetProgram(FunName())
	oProfile:SetTask( "BSCDOCS" )
	oProfile:Load()

	nAlturaBox := ( nAltura - 60 ) / 2
	nLarguraBox := ( nLargura - 20 ) / 2

	@10,10 to nAlturaBox,nLarguraBox of oDlg Pixel

	MV_PAR01 := oProfile:GetStringProfile()

	nLarguraSay := nLarguraBox - 30
	nTop := 20
	TComboBox():New( nTop, 20, { |x| If( PCount() == 0, MV_PAR01, MV_PAR01 := x ) }, aModelos, 65, 10, oDlg,, { || (lCheck := .T., oDlg:Refresh()) },,,, .T.,,,,,,,,,cCombo, cTitModelo, 1, oFont )
	nTop += 10

	nPosIni := ( ( nLargura - 20 ) / 2 ) - 32

	SButton():New( nAlturaBox + 10, nPosIni, 1, bClose, oDlg )

	oDlg:Activate( ,,,.T. )

	If Empty(MV_PAR01)
		cRet := "0"
	ElseIf MV_PAR01 == "Somente Totalização"
		cRet := "1"
	ElseIf MV_PAR01 == "Totalização + NFs"
		cRet := "2"
	EndIf

Return(cRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} SetProfile
@type			function
@description	Atualiza o arquivo de profile.
@author			Rodrigo Nicolino
@since			16/02/2022
@param			oProfile	-	Objeto referente ao arquivo de profile
@param			lCheck		-	Indica se a opção para não exibir nos próximos 7 dias foi marcada
/*/
//---------------------------------------------------------------------
Static Function SetProfile( oProfile, lCheck, cParam )

	Local cSetting	:=	""

	If lCheck
		cSetting := cParam
		oProfile:SetStringProfile( cSetting )
		oProfile:Save()
	EndIf

Return()
