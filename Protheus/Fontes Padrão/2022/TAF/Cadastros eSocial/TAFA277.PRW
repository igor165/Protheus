#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA277.CH"

Static lLaySimplif := taflayEsoc("S_01_00_00")

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA277
Cadastro MVC de Trabalhadores Sem Vinculo de Emprego - Alteracao Contratual (S-2306)

@author Felipe C. Seolin
@since 25/10/2013
@version 1.0

/*/
//---------------------------------------------------------------------
Function TAFA277()

	cMensagem := "Essa rotina está inativa a partir de uma chamada de menu" + Chr(13) + Chr(10) // #"Dicionário Incompatível"
	cMensagem += "Por favor atualize o menu do TAF e utilize a nova rotina do Cadastro do Trabalhador"

	Aviso( "Rotina indisponível", cMensagem, { "Encerrar" }, 3 ) // #"Encerrar"

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Felipe C. Seolin
@since 26/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Felipe C. Seolin
@since 26/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStruT0F := FwFormStruct( 1, "T0F" )
	Local oModel   := MpFormModel():New( "TAFA277", ,{ |oModel| TAF277Chv( oModel ) }, { |oModel| SaveModel( oModel ) } )

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruT0F:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	EndIf

	//Remoção do GetSX8Num quando se tratar da Exclusão de um Evento Transmitido.
	//Necessário para não incrementar ID que não será utilizado.
	If Upper( ProcName( 2 ) ) == Upper( "GerarExclusao" )
		oStruT0F:SetProperty( "T0F_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )
	EndIf

	oModel:AddFields( "MODEL_T0F", /*cOwner*/, oStruT0F )

	oStruT0F:SetProperty( "T0F_CPF"		, MODEL_FIELD_NOUPD	, .T. )
	oStruT0F:SetProperty( "T0F_DTALT"	, MODEL_FIELD_OBRIGAT, .T. )
	If !lLaySimplif
		oStruT0F:SetProperty( "T0F_NIS"		, MODEL_FIELD_WHEN	, {||.F.})
		oStruT0F:SetProperty( "T0F_AREAES" 	, MODEL_FIELD_TAMANHO, 50)
		oStruT0F:SetProperty( "T0F_CATAV"	, MODEL_FIELD_OBRIGAT , .T.  )

		oModel:GetModel( "MODEL_T0F" ):SetPrimaryKey( { "T0F_CPF" }, { "T0F_DTALT" } )
	Else
		oStruT0F:SetProperty( "T0F_MATTSV"		, MODEL_FIELD_NOUPD	, .T. )
		oModel:GetModel( "MODEL_T0F" ):SetPrimaryKey( { "T0F_CPF" }, { "T0F_MATTSV" },{ "T0F_DTALT" }  )
		
	EndIf

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Felipe C. Seolin
@since 26/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel    := FWLoadModel( "TAFA277" )
	Local oView     := FWFormView():New()
	Local oStruT0F  := Nil
	Local oStruT0Fa := Nil 
	Local oStruT0Fb := Nil
	Local cCmpFil   := ""
	Local cCmpTSV1  := ""
	Local cCmpTSV2  := ""
	Local cCmpTSV3  := ""
	Local cCmpTSV4  := ""
	Local cCmpTSV5  := ""
	Local cCmpTSV6  := ""
	Local cCmpTSV7  := ""
	Local cCmpTSV8  := ""
	Local cCmpTSV9  := ""
	Local cCmpTSV10 := ""
	Local cCmpTrans := ""
	Local cCmpContr := ""
	Local nI        := 0
	Local aCmpGrp   := {}

	oView:SetModel( oModel )

	/*-----------------------------------------------------------------------------------
								Grupo de campos do Trabalhador
	-------------------------------------------------------------------------------------*/
	cCmpFil := "T0F_CPF|T0F_DTALT|"
	If !lLaySimplif
		cCmpFil += "T0F_NIS|"
	EndIf
	oStruT0F := FwFormStruct( 2, "T0F", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	cCmpTrans := "T0F_PROTUL|"
	oStruT0Fa := FwFormStruct( 2, "T0F",{|x| AllTrim( x ) + "|" $ cCmpTrans } )  

	oStruT0F:AddGroup( "GRP_DTALT", STR0023, "", 1 ) //"Identificação"

	aCmpGrp := StrToKarr( cCmpFil, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruT0F:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_DTALT" )
	Next nI

	/*-----------------------------------------------------------------------------------
						Grupo de campos das Informacoes Trabalhador Sem Vinculo
	-------------------------------------------------------------------------------------*/
	If !lLaySimplif
		cCmpTSV1 	:= "T0F_ID|T0F_DTALT|T0F_CPF|T0F_NOME|T0F_NIS|"
		cCmpTSV2 	:= "T0F_NATATV|T0F_CATAV|T0F_DCATAV|T0F_FUNCI|T0F_DFUNCI|T0F_CARCI|T0F_DCARCI|"
		cCmpTSV3 	:= "T0F_VLSLCI|T0F_UNSLCI|T0F_DSVRCI|"
		cCmpTSV4 	:= "T0F_NATEES|T0F_NIVEES|T0F_AREAES|T0F_NRAPES|T0F_VLBLES|T0F_DTTEES|"
		cCmpTSV5 	:= "T0F_CNPEES|T0F_NOMEES|T0F_LOGEES|T0F_NLGEES|T0F_BAREES|T0F_CEPES|T0F_MUNES|T0F_DMUNES|T0F_UFES|T0F_DUFES|"
		cCmpTSV6 	:= "T0F_CNPAES|T0F_NOMAES|T0F_LOGAES|T0F_NLGAES|T0F_BARAES|T0F_CEPAES|T0F_MUNAES|T0F_DMUNAE|T0F_UFAES|T0F_DUFAES|"
		cCmpTSV7 	:= "T0F_CPFCES|T0F_NOMCES|"
	Else
		cCmpTSV1 	:= "T0F_ID|T0F_MATTSV|T0F_DTALT|T0F_CPF|T0F_NOME|"
		cCmpTSV2 	:= "T0F_NATATV|T0F_CATAV|T0F_DCATAV|T0F_NMCARG|T0F_CBOCAR|T0F_NMFUNC|T0F_CBOFUN|"
		cCmpTSV3 	:= "T0F_VLSLCI|T0F_UNSLCI|T0F_DSCSAL|"
		cCmpTSV4 	:= "T0F_NATEES|T0F_NIVEES|T0F_AREAES|T0F_NRAPES|T0F_DTTEES|"
		cCmpTSV5 	:= "T0F_CNPEES|T0F_NOMEES|T0F_LOGEES|T0F_NLGEES|T0F_BAREES|T0F_CEPES|T0F_MUNES|T0F_DMUNES|T0F_UFES|T0F_DUFES|"
		cCmpTSV6 	:= "T0F_CNPAES|"
		cCmpTSV7 	:= "T0F_CPFCES|"
		cCmpTSV8 	:= "T0F_REGPRE|"
		cCmpTSV9 	:= "T0F_TPREGP|"
		cCmpTSV10 	:= "T0F_INDREM|T0F_TPRPRE|"
	EndIf

	If TafColumnPos("T0F_DTRANS")
		cCmpContr   := "T0F_DINSIS|T0F_DTRANS|T0F_HTRANS|T0F_DTRECP|T0F_HRRECP|"
		oStruT0Fb := FwFormStruct( 2, "T0F",{|x| AllTrim( x ) + "|" $ cCmpContr } ) //Campos do folder Info. Controle eSocial
	EndIf

	cCmpFil := cCmpTSV1 + cCmpTSV2 + cCmpTSV3 + cCmpTSV4 + cCmpTSV5 + cCmpTSV6 + cCmpTSV7 + cCmpTSV8 + cCmpTSV9 + cCmpTSV10
	oStruT0F := FwFormStruct( 2, "T0F", { |x| AllTrim( x ) + "|" $ cCmpFil } )

	oStruT0F:SetProperty( "T0F_UFES"  	, MVC_VIEW_ORDEM	, "27"  )
	oStruT0F:SetProperty( "T0F_DUFES" 	, MVC_VIEW_ORDEM	, "28"  )
	oStruT0F:SetProperty( "T0F_MUNES" 	, MVC_VIEW_ORDEM	, "29"  )
	oStruT0F:SetProperty( "T0F_DMUNES"	, MVC_VIEW_ORDEM	, "30"  )
	If !lLaySimplif
		oStruT0F:SetProperty( "T0F_UFAES" 	, MVC_VIEW_ORDEM	, "38"  )
		oStruT0F:SetProperty( "T0F_DUFAES"	, MVC_VIEW_ORDEM	, "39"  )
		oStruT0F:SetProperty( "T0F_MUNAES"	, MVC_VIEW_ORDEM	, "40"  )
		oStruT0F:SetProperty( "T0F_DMUNAE"	, MVC_VIEW_ORDEM	, "41"  )
	Else
		/* -- Desabilita edição dos descritivos dos CBOs (exclusivo simplificado) -- */
		oStruT0F:SetProperty( "T0F_NMCARG" , MVC_VIEW_CANCHANGE, .F.)
		oStruT0F:SetProperty( "T0F_NMFUNC" , MVC_VIEW_CANCHANGE, .F.)
	EndIf

	/*-----------------------------------------------------------------------------------
					Grupo de campos do Informacoes Trabalhador Sem Vinculo
	-------------------------------------------------------------------------------------*/
	oStruT0F:AddGroup( "GRP_TSV_01", STR0024, "", 1 ) //"Identificação do Trabalhador"
	oStruT0F:AddGroup( "GRP_TSV_02", STR0022, "", 1 ) //"Cargo e Função do trabalhador"
	oStruT0F:AddGroup( "GRP_TSV_03", STR0021, "", 1 ) //"Remuneracao"
	oStruT0F:AddGroup( "GRP_TSV_04", STR0006, "", 1 ) //"Dados do Estagiário"
	oStruT0F:AddGroup( "GRP_TSV_05", STR0007, "", 1 ) //"Instituição de Ensino"
	oStruT0F:AddGroup( "GRP_TSV_06", STR0008, "", 1 ) //"Agente de Integração"
	oStruT0F:AddGroup( "GRP_TSV_07", STR0009, "", 1 ) //"Supervisor do Estágio"
	oStruT0F:AddGroup( "GRP_TSV_08", STR0032, "", 1 ) //"Empresa de Origem do Dirigente Sindical"
	oStruT0F:AddGroup( "GRP_TSV_09", STR0033, "", 1 ) //"Informações Relativas ao Trabalhador Cedido"
	oStruT0F:AddGroup( "GRP_TSV_10", STR0034, "", 1 ) //"Informações Relativas a Servidor Público Exercente de Mandato Eletivo."

	aCmpGrp := StrToKArr( cCmpTSV1, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruT0F:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_TSV_01" )
	Next nI

	aCmpGrp := StrToKArr( cCmpTSV2, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruT0F:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_TSV_02" )
	Next nI

	aCmpGrp := StrToKArr( cCmpTSV3, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruT0F:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_TSV_03" )
	Next nI

	aCmpGrp := StrToKArr( cCmpTSV4, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruT0F:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_TSV_04" )
	Next nI

	aCmpGrp := StrToKArr( cCmpTSV5, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruT0F:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_TSV_05" )
	Next nI

	aCmpGrp := StrToKArr( cCmpTSV6, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruT0F:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_TSV_06" )
	Next nI

	aCmpGrp := StrToKArr( cCmpTSV7, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruT0F:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_TSV_07" )
	Next nI

	aCmpGrp := StrToKArr( cCmpTSV8, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruT0F:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_TSV_08" )
	Next nI

	aCmpGrp := StrToKArr( cCmpTSV9, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruT0F:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_TSV_09" )
	Next nI

	aCmpGrp := StrToKArr( cCmpTSV10, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruT0F:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_TSV_10" )
	Next nI

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruT0Fa,"T0F")
	EndIf

	/*-----------------------------------------------------------------------------------
								Esrutura da View
	-------------------------------------------------------------------------------------*/
	oView:AddField( "VIEW_T0F", oStruT0F, "MODEL_T0F" )
	oView:AddField( "VIEW_T0Fa", oStruT0Fa, "MODEL_T0F" )

	oView:EnableTitleView( 'VIEW_T0Fa', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"  

	If TafColumnPos("T0F_DTRANS")
		oView:AddField( "VIEW_T0Fb", oStruT0Fb, "MODEL_T0F" )
		oView:EnableTitleView( 'VIEW_T0Fb', TafNmFolder("recibo",2) )
	EndIf

	/*-----------------------------------------------------------------------------------
								Estrutura do Folder
	-------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox( "PAINEL_PRINCIPAL", 100 )
	oView:CreateFolder( "FOLDER_PRINCIPAL", "PAINEL_PRINCIPAL" )

	oView:AddSheet( "FOLDER_PRINCIPAL", "ABA01", "Sem Vínculo - Informações do Contrato" ) //"Sem Vínculo - Informações do Contrato"

	oView:CreateHorizontalBox( "T0F", 100, , , "FOLDER_PRINCIPAL" , "ABA01" )

	oView:AddSheet("FOLDER_PRINCIPAL","ABA02",TafNmFolder("recibo") )   //"Info. Controle eSocial"

	If TafColumnPos("T0F_DTRANS")
		oView:CreateHorizontalBox("T0Fa",20,,,"FOLDER_PRINCIPAL","ABA02")
		oView:CreateHorizontalBox("T0Fb",80,,,"FOLDER_PRINCIPAL","ABA02")
	Else
		oView:CreateHorizontalBox("T0Fa",100,,,"FOLDER_PRINCIPAL","ABA02")
	EndIf

	/*-----------------------------------------------------------------------------------
							Amarracao para exibicao das informacoes
	-------------------------------------------------------------------------------------*/
	oView:SetOwnerView( "VIEW_T0F" , "T0F" )
	oView:SetOwnerView( "VIEW_T0Fa", "T0Fa")

	If TafColumnPos("T0F_DTRANS")
		oView:SetOwnerView( "VIEW_T0Fb", "T0Fb" )
	EndIf

	///Tratamento para que alguns campos de controle interno não sejam exibidos na tela
	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	oStruT0F:RemoveField("T0F_VERANT")
	oStruT0F:RemoveField("T0F_PROTPN")

	// Auditoria LGPD
	IIf(FindFunction('FwPDLogUser'),FwPDLogUser('TAFA277'),Nil)  

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param oModel -> Modelo de dados

@Return .T.

@Author Felipe C. Seolin
@Since 26/10/2013
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local cLogOpeAnt	:= ""
	Local cChvRegAnt := ""
	Local aGravaT0F  := {}
	Local nOperation := oModel:GetOperation()
	Local oModelT0F  := oModel:GetModel( "MODEL_T0F" )
	Local lRetorno	:= .T.

	Default oModel	:= Nil

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		//Inclusao Manual do Evento
		If nOperation == MODEL_OPERATION_INSERT

		TafAjustID( "T0F", oModel)

			oModel:LoadValue( "MODEL_T0F", "T0F_ID", C9V->C9V_ID)
			oModel:LoadValue( "MODEL_T0F", "T0F_VERSAO", xFunGetVer() )

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_T0F', 'T0F_LOGOPE' , '2', '' )
			Endif

			T0F->( DBSetOrder( 2 ) )
			If T0F->( MsSeek( xFilial( "T0F" ) + T0F->T0F_ID + "1" + DTOS(T0F->T0F_DTALT)) )	
				If AllTrim(FwFldGet('T0F_EVENTO'))== "A"
					oModel:LoadValue( "MODEL_T0F", "T0F_VERANT", T0F->T0F_VERSAO )
					oModel:LoadValue( "MODEL_T0F", "T0F_PROTPN", T0F->T0F_PROTUL )
					
					FAltRegAnt( "T0F", "2" ) //Seto o registro corrente como Inativo	
				EndIf
			EndIf
			//Gravo alteração para o Extemporâneo
			If lGoExtemp
				TafGrvExt( oModel, 'MODEL_T0F', 'T0F' )	
			EndIf
			
			FwFormCommit( oModel )		
			
			//Volto a variavel para o valor original, aguardando a proxima operacao a ser realizada
			lExistAlt := .F.

		//Alteracao Mnual do evento
		ElseIf nOperation == MODEL_OPERATION_UPDATE 
		
			//Posicionando no registro para que nao ocorra erros durante o processo de validacao
			T0F->( DBSetOrder( 2 ) )
			If T0F->( MsSeek( xFilial( "T0F" ) + T0F->T0F_ID + "1" + DTOS(T0F->T0F_DTALT)) )

				//Verifica se o evento ja foi trasmitido ao RET
				If T0F->T0F_STATUS $ ( "4" )

					If TafColumnPos( "T0F_LOGOPE" )
						cLogOpeAnt := oModelT0F:GetValue( "T0F_LOGOPE" )
					endif

					//Funcao para carregar os valores correntes do cadastro				
					TAF277Carr( oModelT0F, @aGravaT0F )

					//Seto o registro corrente como Inativo
					FAltRegAnt( "T0F", "2" )

					//Esta funcao desativa o model corrente e inicia a operação de inclusao das operacoes realizadas
					TAF277Comm( oModel, oModelT0F, aGravaT0F )

					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T0F', 'T0F_LOGOPE' , '' , cLogOpeAnt )	
					EndIf

				ElseIf	T0F->T0F_STATUS == "2"                                                                 
					TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
					lRetorno:= .F.
				ElseIf T0F->T0F_STATUS == "6"                                                                                                                                                                                                                                                                                                                               
					TAFMsgVldOp(oModel,"6")//"Registro não pode ser alterado. Aguardando proc. Transm. evento de Exclusão S-3000"
					lRetorno:= .F.
				Elseif T0F->T0F_STATUS == "7"
					TAFMsgVldOp(oModel,"4")//"Registro não pode ser excluído, pois o evento de exclusão já se encontra base do RET" 
					lRetorno:= .F.
				EndIf
				If lRetorno == .T.
					If TafColumnPos( "T0F_LOGOPE" )
						cLogOpeAnt := T0F->T0F_LOGOPE
					endif

					//Gravo alteração para o Extemporâneo
					If lGoExtemp
						TafGrvExt( oModel, 'MODEL_T0F', 'T0F' )	
					EndIf

					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T0F', 'T0F_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					FwFormCommit( oModel )
					TAFAltStat( 'T0F', " " )
				Endif  
			EndIf
			
		//Exclusão Manual do Evento		
		ElseIf nOperation == MODEL_OPERATION_DELETE
			cChvRegAnt := T0F->(T0F_ID + T0F_VERANT)              
			If !Empty( cChvRegAnt ) 
				TAFAltStat( 'T0F', " " )
				FwFormCommit( oModel )				
				If nOperation == MODEL_OPERATION_DELETE
					If T0F->T0F_EVENTO == "A" .Or. T0F->T0F_EVENTO == "E"
						TAFRastro( 'T0F', 1, cChvRegAnt, .T. , , IIF(Type ("oBrw") == "U", Nil, oBrw ))
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

Return ( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF277Carr
Funcao que armazena nos arrays as informacoes correntes do cadastro

@Param
oModelT0F - Model da tabela T0F
aGravaT0F - Array que armazena as informacoes da tabela T0F

@Return .T.

@Author Felipe C. Seolin
@Since 03/02/2014
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAF277Carr( oModelT0F, aGravaT0F )

	Local nI := 0

	Default oModelT0F	:= Nil
	Default aGravaT0F	:= {}

	For nI := 1 to Len( oModelT0F:aDataModel[1] )
		aAdd( aGravaT0F, { oModelT0F:aDataModel[1,nI,1], oModelT0F:aDataModel[1,nI,2] } )
	Next nI

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF277Comm
Funcao que realiza a gravacao das informacoes

@Param

oModel    - Model que esta sendo editado
oModelT0F - Model da tabela T0F
aGravaT0F - Array que armazena as informações da tabela T0F
lFirsOpe  - Indica se a operacao que esta sendo realizada se refere a uma inclusao, neste caso os campos
			de controle de rastro nao devem ser gravados

@Return .T.

@Author Felipe C. Seolin
@Since 03/02/2014
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAF277Comm( oModel, oModelT0F, aGravaT0F, lExclu )

	Local cVersao    	:= ""
	Local cVerAnt    	:= ""
	Local cProtocolo 	:= ""
	Local cEvento    	:= ""
	Local nI         	:= 0

	Default oModel		:= Nil
	Default oModelT0F	:= Nil	
	Default aGravaT0F	:= {}
	Default lExclu		:= .F.

	oModel:DeActivate()
	oModel:SetOperation( 3 )
	oModel:Activate()

	For nI := 1 to Len( aGravaT0F )
		oModel:LoadValue( "MODEL_T0F", aGravaT0F[nI,1], aGravaT0F[nI,2] )
	Next nI

	cVersao 	:= xFunGetVer()

	cVerAnt   	:= T0F->T0F_VERSAO
	cProtocolo	:= T0F->T0F_PROTUL
	cEvento   	:= T0F->T0F_EVENTO

	oModel:LoadValue( "MODEL_T0F", "T0F_VERSAO", cVersao )
	oModel:LoadValue( "MODEL_T0F", "T0F_VERANT", cVerAnt )
	oModel:LoadValue( "MODEL_T0F", "T0F_PROTPN", cProtocolo )
	oModel:LoadValue( "MODEL_T0F", "T0F_PROTUL", "" )
	oModel:LoadValue( "MODEL_T0F", "T0F_STATUS", "" )
	// Tratamento para limpar o ID unico do xml
	cAliasPai := "T0F"
	If TAFColumnPos( cAliasPai+"_XMLID" )
		oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
	EndIf

	IF lExclu
		oModel:LoadValue( "MODEL_T0F", "T0F_EVENTO", "E" )
		oModel:LoadValue( "MODEL_T0F", "T0F_ATIVO", "1" )
	Else
		If cEvento == "I"
			oModel:LoadValue( "MODEL_T0F", "T0F_EVENTO", "A" )
		EndIf
	Endif

Return ( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} TAF277Grv
Funcao de gravacao para atender o registro S-2306

@Param:
cLayout - Nome do Layout que esta sendo enviado, existem situacoes onde o mesmo fonte
          alimenta mais de um regsitro do E-Social, para estes casos serao necessarios
          tratamentos de acordo com o layout que esta sendo enviado.
nOpc   -  Opcao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )
cFilEv -  Filial do ERP para onde as informacoes deverao ser importadas
oDados -  Objeto com as informacoes a serem manutenidas ( Outras Integracoes )

@Return
lRet    - Variavel que indica se a importacao foi realizada, ou seja, se as
		  informacoes foram gravadas no banco de dados
aIncons - Array com as inconsistencias encontradas durante a importacao

@author Felipe C. Seolin
@since 30/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF277Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

	Local cLogOpeAnt
	Local cCmpsNoUpd 	:= "|T0F_FILIAL|T0F_ID|T0F_VERSAO|T0F_VERANT|T0F_PROTUL|T0F_PROTPN|T0F_EVENTO|T0F_STATUS|T0F_ATIVO|"
	Local cCabecTrab 	:= "/eSocial/evtTSVAltContr/ideTrabSemVinculo"
	Local cCabecVinc 	:= "/eSocial/evtTSVAltContr/infoTSVAlteracao"
	Local cIdEvtTrb  	:= ""
	Local cEnter     	:= Chr(13) + Chr(10)
	Local cMensagem  	:= ""
	Local cInconMsg  	:= ""
	Local cFilC9V    	:= ""
	Local cFilT0F    	:= "" 
	Local cCodEvent  	:= Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")
	Local cChaveOri		:= ""
	Local cFilOri		:= ""
	Local cCM6ChvOri	:= ""
	Local cChvCPF		:= ""
	Local cChvMat		:= ""
	Local cChvC9V		:= ""
	Local cChvOri		:= ""
	Local nI         	:= 0
	Local nSeqErrGrv 	:= 0
	Local nIndChv    	:= 3
	Local nIndChvC9V   	:= IIF(lLaySimplif,20,4)
	Local lRet       	:= .F.
	Local lTransmit  	:= .F.
	Local lTransf		:= .F.
	Local lCUULimpAf	:= .F.
	Local aIncons    	:= {}
	Local aRulesCad  	:= {}
	Local aRulesTSV  	:= {}
	Local aChave     	:= {}
	Local aChaveC9V  	:= {}
	Local aChaveOri		:= {}
	Local aAreaAux		:= {}
	Local dData			:= CTOD("  /  /    ")	
	Local oModel     	:= Nil

	Private lVldModel	:= .T. 
	Private oDados   	:= Nil

	Default cLayout  	:= "2306"
	Default nOpc     	:= 1
	Default cFilEv   	:= ""
	Default oXML     	:= Nil
	Default cOwner		:= ""
	Default cFilTran	:= ""
	Default cPredeces	:=	""
	Default nTafRecno	:=	0
	Default cComplem	:=	""
	Default cGrpTran	:=	""
	Default cEmpOriGrp	:=	""
	Default cFilOriGrp	:=	""
	Default cXmlID		:=	""

	cLogOpeAnt := ""

	If !TafVldAmb("2")

		cMensagem := STR0030 + cEnter // #"Dicionário Incompatível"
		cMensagem += TafAmbInvMsg()

		Aadd(aIncons, cMensagem)

	Else
		
		oDados		:= oXML
		
		//Verifico se a integração é fruto de uma transferencia
		If !Empty(cFilTran) .And. TAFColumnPos( "C9V_IDTRAN" )

			cFilOri := FTafGetFil( cFilTran , @aIncons , "C9V" )

			If !Empty(cFilOri) //Indica se é um funcionario vindo de uma transferencia.
				lTransf := .T.
			Else	
				Aadd( aIncons, "Não foi encontrada no TAF uma filial de transferência correspondente a filial original enviada no registro.") 
			EndIf

		EndIf
		
		//Chave do Registro
		dDataAlt := StrTran(oDados:XPathGetNodeValue( cCabecVinc + "/dtAlteracao" ),"-","")
		dData := FTafGetVal( cCabecVinc + "/dtAlteracao", 'D', .F., @aIncons, .F., '', '' )
		cChvCPF := oDados:XPathGetNodeValue( cCabecTrab + "/cpfTrab" )
		
		If lLaySimplif
			cChvMat := oDados:XPathGetNodeValue( cCabecTrab + "/matricula") // Matricula
		
			//Chave do Registro
			aAdd( aChave, { "C", "T0F_CPF", cChvCPF, .T. } )
			aAdd( aChave, { "C", "T0F_MATTSV", cChvMat, .T. } )
			Aadd( aChave, { "D", "T0F_DTALT",STOD(dDataAlt),.T.} )

			cChave	:= cChvCPF + Padr(cChvMat,TamSX3("T0F_MATTSV")[1]) + dDataAlt
		Else
			//Chave do Registro
			aAdd( aChave, { "C", "T0F_CPF", cChvCPF, .T. } )
			Aadd( aChave, { "D", "T0F_DTALT",STOD(dDataAlt),.T.} )

			cChave	:= cChvCPF + dDataAlt
		EndIf

		aAreaC9V:= ( "C9V" )->( GetArea() )
		dbSelectArea("C9V")
		C9V->( DbSetOrder( nIndChvC9V ) ) 
		
		cFilC9V   	:= FTafGetFil( cFilEv , @aIncons , "C9V" )

		If !lLaySimplif
			aAdd( aChaveC9V, { cLayout, cFilC9V , Padr(cChvCPF, TamSX3("C9V_CPF")[1]) , "S2300" + "1"} ) //alterar2300	
			cChvC9V := aChaveC9V[1,2] + aChaveC9V[1,3] + aChaveC9V[1,4] 

			If lTransf
				aAdd( aChaveOri, { cLayout , cFilOri, Padr(cChvCPF, TamSX3("C9V_CPF")[1]) , "S2300" + '1'} ) //alterar2300
				cChvOri := aChaveOri[1,2] + aChaveOri[1,3] + aChaveOri[1,4]
			Endif	
		Else
			//Simplificado
			aAdd( aChaveC9V, { cLayout, cFilC9V , Padr(cChvCPF, TamSX3("C9V_CPF")[1]),Padr(cChvMat, TamSX3("C9V_MATTSV")[1]) , "S2300" + "1"} ) //alterar2300	
			cChvC9V := aChaveC9V[1,2] + aChaveC9V[1,3] + aChaveC9V[1,4] + aChaveC9V[1,5] 

			If lTransf
				aAdd( aChaveOri, { cLayout , cFilOri, Padr(cChvCPF, TamSX3("C9V_CPF")[1]) , Padr(cChvMat, TamSX3("C9V_MATTSV")[1]), "S2300" + '1'} ) //alterar2300
				cChvOri := aChaveOri[1,2] + aChaveOri[1,3] + aChaveOri[1,4] + aChaveOri[1,5] 
			Endif	
		EndIf
		//T0F_FILIAL+T0F_CPF+T0F_NOMEVE+T0F_ATIVO ou T0F_FILIAL+T0F_CPF+T0F_MATTSV+T0F_NOMEVE+T0F_ATIVO
		If !(('C9V')->( MsSeek( cChvC9V )))

			If !lTransf
				Aadd( aIncons, "000011")	//'Para a integração do evento de alteração S-2306 (Trabalhador Sem Vínculo - Alteração Contratual) ou 
											//término S-2399 (Trabalhador Sem Vínculo - Término), é necessário que exista o evento S-2300 (Trabalhador 
											//Sem Vínculo - Início) correspondente ao evento de alteração ou término do trabalhador sem vínculo.'
			ElseIf !(('C9V')->( MsSeek( cChvOri )))
				Aadd( aIncons, "O evento original correspondente a este Trabalhador não existe. Não será possível a integração do evento de transferência.") 
			ElseIf C9V->C9V_STATUS == "3"
				Aadd( aIncons, "000013") //'O evento de alteração ou término do trabalhador sem vínculo integrado, S-2305 (Trabalhador Sem Vínculo - Alteração Contratual) ou S-2399 (Trabalhador Sem Vínculo - Término), possui o evento pai S-2300 (Trabalhador Sem Vínculo - Início) rejeitado pelo Governo.'
			Elseif C9V->C9V_STATUS <> '4'
				Aadd( aIncons, "000023") //'O evento de alteração ou término do trabalhador sem vínculo integrado, S-2305 (Trabalhador Sem Vínculo - Alteração Contratual) ou S-2399 (Trabalhador Sem Vínculo - Término), possui o evento pai S-2300 (Trabalhador Sem Vínculo - Início) aguardando retorno do Governo.'
			Else
				cChaveOri := cChvOri
			EndIf

			If lTransf	

				// Avalia se o trabalhador tem afastamento pendente de transmissão, impossibilitando a transferência
				C9V->( MsSeek( cChvOri  ))
				aAreaAux := GetArea()
				DBSelectArea("CM6")
				CM6->(DBSetOrder(9)) //CM6_FILIAL+CM6_FUNC+CM6_ATIVO
				cCM6ChvOri := FTafGetFil( cFilTran , @aIncons , "CM6" ) + C9V->C9V_ID + '1'
				If CM6->(DBSeek(cCM6ChvOri))

					While CM6->(!EOF()) .And. CM6->(CM6_FILIAL+CM6_FUNC+CM6_ATIVO) == cCM6ChvOri

						If CM6->CM6_STATUS <> '4'
							Aadd( aIncons, "O evento original correspondente a este Trabalhador possui um afastamento pendente de tramissão. Não será possível a integração do evento de transferência.")
							Exit
						EndIf

						CM6->(DBSkip())
					EndDo

					// Caso tenha localizado evento de afastamento (CM6), os campos CUU_DTINIA e CUU_MOTVAF devem ser limpos na filial de destino, para possibilitar a inclusão de um inicio de afastamento
					lCUULimpAf := .T.

				EndIf
				RestArea(aAreaAux)

			EndIf

		Else

			If C9V->C9V_IDTRAN <> '' .AND. C9V_ATIVO == '2' .AND. lTransf
				cChaveOri := cChvOri
			EndIf

			If C9V->C9V_STATUS == "3"
				Aadd( aIncons, "000013") //'O evento de alteração ou término do trabalhador sem vínculo integrado, S-2305 (Trabalhador Sem Vínculo - Alteração Contratual) ou S-2399 (Trabalhador Sem Vínculo - Término), possui o evento pai S-2300 (Trabalhador Sem Vínculo - Início) rejeitado pelo Governo.'
			Elseif C9V->C9V_STATUS <> '4'
				Aadd( aIncons, "000023") //'O evento de alteração ou término do trabalhador sem vínculo integrado, S-2305 (Trabalhador Sem Vínculo - Alteração Contratual) ou S-2399 (Trabalhador Sem Vínculo - Término), possui o evento pai S-2300 (Trabalhador Sem Vínculo - Início) aguardando retorno do Governo.'
			EndIf

		EndIf

		cIdEvtTrb := C9V->C9V_ID
		
		RestArea( aAreaC9V )

		cFilT0F  	:= FTafGetFil( cFilEv , @aIncons , "T0F" ) 
		If lLaySimplif .And. !Empty(cChvMat)
			nIndChv := 6
		EndIf

		dbSelectArea("T0F")
		("T0F")->( DbSetOrder( nIndChv ) )
		If ("T0F")->( MsSeek( cFilT0F + cChave + '1' ) ) //Verifica se o evento ja existe na base
			nOpc := 4
			lTransmit 	:= IIF(T0F->T0F_STATUS == '4',.T.,.F.)
		EndIf

		If lTransf

			aCodFils :=	TAFCodFilErp()

			If (aScan(aCodFils,{|cFil|AllTrim(cFil) == AllTrim(cFilTran)})) > 0
				cIdTransf := C9V->C9V_ID
			Else 

				//------------------------------------------------------------------------------------------------------
				// Obtem o ID da C9V que será utilizado na T0F. Feito desta forma para nao gerar chave duplicada na C9V
				// e manter a funcionalidade dos locais onde o ID da C9V x T0F devem ser o mesmo (ex. Historico), porém
				// as tabelas deveriam ter seu ID independente e se relacionarem por chave de negocio (ex. CPF)
				//------------------------------------------------------------------------------------------------------
				cIdTransf := GetSx8Num("C9V","C9V_ID")

				// Avalia se o ID obtido já está em uso (problema no ambiente do cliente)
				If !TAFCheckID(cIdTransf,"C9V")
					RollBackSX8()
					AAdd(aIncons,"Controle de numeracao da tabela C9V incorreto. Necessário ajuste por meio do programa APCFG110 no módulo configurador.") //STR0045) //"Controle de numeracao da tabela C9V incorreto. Necessário ajuste por meio do programa APCFG110 no módulo configurador."
				EndIf
			EndIf 
		Endif

		Begin Transaction
			
			//Funcao para validar se a operacao desejada pode ser realizada
			If Empty(aIncons) .And. FTafVldOpe( "T0F", nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA277", cCmpsNoUpd )

				If TafColumnPos( "T0F_LOGOPE" )
					cLogOpeAnt := T0F->T0F_LOGOPE
				Endif

				//Carrego array com os campos De/Para de gravacao das informacoes ( Cadastrais )
				aRulesCad := FRulCad( cCabecTrab, cLayout, "T0F",, @cInconMsg, @nSeqErrGrv, lTransmit, oModel, aChaveC9V,, cCodEvent, cOwner )
		
				//Carrego array com os campos De/Para de gravacao das informacoes ( Sem Vinculo )
				aRulesTSV := FRulTSVin( cCabecVinc, cLayout, "T0F", @cInconMsg, @nSeqErrGrv, lTransmit, oModel, cCodEvent, cOwner, lTransf, cFilOri )
				
				//Quando se tratar de uma exclusao direta apenas preciso realizar
				//o Commit(), nao eh necessaria nenhuma manutencao nas informacoes
				If nOpc <> 5
		
					oModel:LoadValue( "MODEL_T0F", "T0F_FILIAL", cFilT0F )

					If FindFunction( "EvtExtemp" )
						If EvtExtemp("T0F",dData,cIdEvtTrb)
							oModel:LoadValue("MODEL_T0F", "T0F_STASEC", 'E')
						EndIf
					endIf

					//Carrego o ID com o ID do evento do trabalhador (S2300).
					If lTransf
						oModel:LoadValue( "MODEL_T0F", "T0F_ID", cIdTransf )
					Else
						oModel:LoadValue( "MODEL_T0F", "T0F_ID", cIdEvtTrb )
					EndIf

					If TAFColumnPos( "T0F_XMLID" )
						oModel:LoadValue( "MODEL_T0F", "T0F_XMLID", cXmlID )
					EndIf
								
					//Rodo o aRulesCad para gravar as informacoes cadastrais
					For nI := 1 to Len( aRulesCad )
						oModel:LoadValue( "MODEL_T0F", aRulesCad[nI,1], FTafGetVal( aRulesCad[nI,2], aRulesCad[nI,3], aRulesCad[nI,4], @aIncons, .F. ) )
					Next nI
		
					//Rodo o aRulesTSV para gravar as informacoes contratuais
					For nI := 1 to Len( aRulesTSV )
						oModel:LoadValue( "MODEL_T0F", aRulesTSV[nI,1], FTafGetVal( aRulesTSV[nI,2], aRulesTSV[nI,3], aRulesTSV[nI,4], @aIncons, .F. ) )
					Next nI

					If Findfunction("TAFAltMan")
						if nOpc == 3
							TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T0F', 'T0F_LOGOPE' , '1', '' )
						elseif nOpc == 4
							TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T0F', 'T0F_LOGOPE' , '', cLogOpeAnt )
						EndIf
					EndIf
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Efetiva a operacao desejada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
				If Empty(cInconMsg) .And. Empty(aIncons)
					If TafFormCommit ( oModel )	
						Aadd(aIncons, "ERRO19")
					Else
						lRet  := .T.
					End
			Else
					Aadd(aIncons, cInconMsg)
					DisarmTransaction()
			EndIf	
				
				//Inativa o evento original e copia os dados do Trabalhador na filial destino
				If lRet .And. lTransf .And. !Empty(cChaveOri)
					xTafTransf( cChaveOri, 4, cIdTransf, cFilOri, cFilC9V, aChaveC9V, , , lCUULimpAf )		
					ConfirmSX8()			
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
		
		aSize( aRulesTSV, 0 )
		aRulesTSV := Nil
		
		aSize( aChave, 0 )
		aChave := Nil
		
	EndIf

Return{ lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF277Xml
Funcao de geracao do XML para atender os registros S-2306.
Quando a rotina for chamada o registro deve estar posicionado.

@Param:
cAlias  - Alias da Tabela
nRecno  - Recno do Registro corrente
nOpc    - Operacao a ser realizada
lJob    - Informa se foi chamado por Job
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composição da chave ID do XML

@Return:
cXml - Estrutura do Xml do Layout S-2306

@author Felipe C. Seolin
@since 26/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF277Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

	Local cXml     	:= ""
	Local cReg     	:= "TSVAltContr"
	Local cLayout	:= "2306"
	Local cDtAlter 	:= ""
	Local cMatric	:= ""

	Default cAlias	:= ""
	Default nRecno	:= 1
	Default nOpc	:= 1
	Default lJob	:= .F.
	Default cSeqXml := ""


	DBSelectArea("T0F")
	DBSelectArea("C9V")
	T0F->( DBSetOrder( 1 ) )
	C9V->( DBSetOrder( 2 ) )

	cDtAlter := T0F->T0F_DTALT

	cXml += "<ideTrabSemVinculo>"
	cXml +=		xTafTag( "cpfTrab", T0F->T0F_CPF,,.F. )
	If !lLaySimplif
		cXml +=		xTafTag( "nisTrab", T0F->T0F_NIS,,.T.)
	EndIf

	// Inclusão Simplificação
	If lLaySimplif
		If C9V->( MSSeek( xFilial("C9V") + T0F->T0F_ID + "1" ) )
			cMatric	:= 	C9V->C9V_MATTSV
			cXml 	+=	xTafTag("matricula" ,	AllTrim(cMatric),, .T.)
		EndIf
	EndIf


	//Posiciono no vinculo referente ao trabalhador
	T0F->( MsSeek( xFilial("T0F") + T0F->( T0F_ID + T0F_VERSAO ) ) )

	DBSelectArea("C87")
	C87->( DBSetOrder( 1 ) )
	If ( lLaySimplif .And. Empty(cMatric) ) .Or. !lLaySimplif
		If C87->( MsSeek( xFilial("C87") +  T0F->T0F_CATAV ) )
			cXml +=	xTafTag( "codCateg", C87->C87_CODIGO,,.F. )
		Else
			cXml +=	xTafTag( "codCateg", "",,.F. )
		EndIf
	EndIf
	cXml += "</ideTrabSemVinculo>"
	cXml += "<infoTSVAlteracao>"
	cXml +=		xTafTag( "dtAlteracao", cDtAlter,,.F. )

	cXml += FGetSVinc( cLayout, "T0F" )

	//Estrutura do cabecalho
	cXml := xTafCabXml(cXml,cAlias,cLayout,cReg,,cSeqXml)

	//Executa gravacao do registro
	If !lJob
		xTafGerXml( cXml, cLayout )
	EndIf

Return( cXml )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF277Chv
Funcao apra validacao da chave unica do registro

@Param:
oModel - Model Utilizado

@Return:
lRet - Status da Validacao 

@author Felipe C. Seolin
@since 03/02/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF277Chv( oModel )

	Local nOperation	:= oModel:GetOperation()
	Local lRet      	:= .T.

	Default oModel	:= Nil

	//Apenas realizao a operação quando se tratar de uma operação de Inclusão
	If nOperation == MODEL_OPERATION_INSERT   
		lRet := xFunVldUni( "T0F", 3, T0F->T0F_CPF + DToS( FwFldGet( "T0F_DTALT" ) ) + "1" )
	EndIf

Return ( lRet )

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

	Local oModelT0F  := Nil
	Local aGravaT0F  := {}
	Local nOperation := 0

	Default oModel	:= Nil
	Default nRecno	:= 1
	Default lRotExc	:= .F.

	nOperation := oModel:GetOperation()

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		//Posiciona o item
		T0F->( Recno() )
											
		//Carrego a Estrutura dos Models a serem gravados
		oModelT0F := oModel:GetModel( "MODEL_T0F" )
						
		//Funcao para carregar os valores correntes do cadastro				
		TAF277Carr( oModelT0F, @aGravaT0F )

		//Seto o registro corrente como Inativo
		FAltRegAnt( "T0F", "2" )

		//Esta funcao desativa o model corrente e inicia a operação de inclusao das operacoes realizadas
		TAF277Comm( oModel, oModelT0F, aGravaT0F, .T. )   
		
		//Gravo alteração para o Extemporâneo
		If lGoExtemp
			TafGrvExt( oModel, 'MODEL_T0F', 'T0F' )	
		EndIf    
		
		FwFormCommit( oModel )
		TAFAltStat( 'T0F',"6" )
		
	End Transaction

Return ( .T. )

//---------------------------------------------------------------------
/*/{Protheus.doc} xTafTransf
Funcao que inativa o trabalhador original e grava o ID entre eles

@author aline.venancio
@since 07/07/2020
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function xTafTransf( cChaveOri, nIndPos, cIdTransf, cFilOri, cFilTaf, aChaveC9V, cRastro, lRotAjuste, lCUULimpAf)

	Local oModel	:= Nil
	Local aGrava     := {}
	Local aGravaT2F  := {}
	Local aGravaCUU  := {}
	Local aGravaT1U  := {}
	Local aGravaT3T  := {}

	//Carrego a Estrutura dos Models a serem gravados
	Local oModelC9V := Nil
	Local oModelT2F := Nil
	Local oModelCUU := Nil
	Local oModelS2205	:= Nil
	Local oModelT1U		:= Nil
	Local oModelT3T		:= Nil
	Local cIdTrabOri
	Local aAreaC9V := C9V->(GetArea())
	Local nPosId	:= 0	
	Local nPosFil   := 0
	Local lFoundC9V := .F. 
	Local cFilBkp   := cFilant
	Local nLastRecNo := 0

	Default cChaveOri  := ""
	Default nIndPos	   := 1
	Default cFilOri	   := ""
	Default cFilTaf	   := ""
	Default cRastro    := ""
	Default lRotAjuste := .F. 
	Default lCUULimpAf := .F.

	Begin Transaction

		// Registro Original
		("C9V")->( DbSetOrder( nIndPos ) )
		If ("C9V")->( MsSeek( cChaveOri) )
			
			cIdTrabOri	:= C9V->C9V_ID
			cFilAnt 	:= cFilOri

			//Clone do S-2300 Original
			oModel := FWLoadModel( 'TAFA279' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
		
			oModel:Activate()

			oModelC9V := oModel:GetModel( "MODEL_C9V" )
			oModelT2F := oModel:GetModel( "MODEL_T2F" )
			oModelCUU := oModel:GetModel( "MODEL_CUU" )
			
			//Armazeno as informações correntes do cadastro
			TAF279Carr( oModel, oModelC9V, oModelT2F, oModelCUU, @aGrava, @aGravaT2F, @aGravaCUU )

			nPosFil := aScan( aGrava , { | aX | AllTrim( aX[ 1 ] ) == "C9V_FILIAL" } )
			If nPosFil > 0 .And. !Empty(aGrava[nPosFil,2])
				aGrava[nPosFil,2] := cFilTaf		
			EndIf	
			
			nPosId := aScan( aGrava , { | aX | AllTrim( aX[ 1 ] ) == "C9V_ID" } )
			If nPosId > 0 .And. !Empty(aGrava[nPosId,2])
				aGrava[nPosId,2] := cIdTransf
			EndIf	

			nPosID := aScan( aGrava , { | aX | AllTrim( aX[ 1 ] ) == "C9V_IDTRAN" } )
			If nPosID > 0 
				//Quando envio o Rastro substituo o IDTRAN
				If Empty(cRastro)
					aGrava[nPosID,2] := cChaveOri	
				Else
					aGrava[nPosID,2] := cRastro 
				EndIf 	
			EndIf

			If lRotAjuste
				nPosId := aScan( aGrava , { | aX | AllTrim( aX[ 1 ] ) == "C9V_DINSIS" } )
				If nPosId > 0 .And. !Empty(aGrava[nPosId,2])
					aGrava[nPosId,2] := dDataBase 
				EndIf	
			EndIf 

			cFilant := cFilTaf

			//Carrego o modelo com as informações gravadas nos ARRAYs alimentados na função TAF279CARR 
			TAF279Comm( oModel, oModelC9V, oModelT2F, oModelCUU, aGrava, aGravaT2F, aGravaCUU )

			FwFormCommit( oModel ) 

			If lRotAjuste
				nLastRecno := C9V->(RecNo())
			EndIf
			
			cFilAnt := cFilBkp
			lFoundC9V := .T. 

		EndIf

		/*
		Alteração realizada para que, nos casos de se executarem uma transferência de um funcionário
		carregar tbm as alterações cadastrais que ocorreram antes da transferência.
		*/
		T1U->(DbSetOrder(2)) //T1U_FILIAL+T1U_ID+T1U_ATIVO+DTOS(T1U_DTALT)
		If lFoundC9V .And. T1U->( MsSeek(cFilOri+cIdTrabOri+"1") ) 

			cFilAnt := cFilOri

			//Clone do S-2300 Original
			oModelS2205 := FWLoadModel( 'TAFA275' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
		
			//oModel:SetOperation(4)
			oModelS2205:Activate()

			oModelT1U := oModelS2205:GetModel( "MODEL_T1U" )
			oModelT3T := oModelS2205:GetModel( "MODEL_T3T" )

			//Armazeno as informações correntes do cadastro
			TAF275Carr( oModelT1U, oModelT3T, @aGravaT1U, @aGravaT3T )

			nPosFil := aScan( aGravaT1U , { | aX | AllTrim( aX[ 1 ] ) == "T1U_FILIAL" } )
			If nPosFil > 0 .And. !Empty(aGravaT1U[nPosFil,2])
				aGravaT1U[nPosFil,2] := cFilTaf		
			EndIf	
			
			nPosId := aScan( aGravaT1U , { | aX | AllTrim( aX[ 1 ] ) == "T1U_ID" } )
			If nPosId > 0 .And. !Empty(aGravaT1U[nPosId,2])
				aGravaT1U[nPosId,2] := cIdTransf
			EndIf			

			cFilant := cFilBkp

			//Carrego o modelo com as informações gravadas nos ARRAYs alimentados na função TAF275CARR 
			TAF275Comm( oModelS2205, oModelT1U, oModelT3T, aGravaT1U, aGravaT3T )

			FwFormCommit( oModelS2205 ) 

		EndIf

		//Inativo o evento Original e gravo a chave DE PARA
		If ("C9V")->( MsSeek( cChaveOri) )	

			If !lRotAjuste //Rotina de Ajuste de Transferencia GPE x TAF

				RecLock("C9V",.F.)	
				If TafColumnPos( "C9V_DTTRAN" )
					C9V->C9V_DTTRAN := Date()
				Else 
					C9V->C9V_ATIVO := '2'
				EndIf 
				//No evento original gravo a chave do evento atual
				C9V->C9V_IDTRAN := aGrava[1,2] + aGrava[4,2] + 'S23001'
				("C9V")->(MsUnlock())
			EndIf
		Endif	

	End Transaction

	RestArea(aAreaC9V)

Return nLastRecno

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF279Carr
Função que armazena nos arrays as informações correntes do cadastro

@Param 

oModelC9V - Model da tabela C9V
aGrava    - Array que armazena as informações da tabela C9V

@Return .T.

@Author aline.venancio
@Since 07/07/2020
@Version 1.0
/*/
//-------------------------------------------------------------------

Static Function TAF279Carr( oModel, oModelC9V, oModelT2F, oModelCUU, aGrava, aGravaT2F, aGravaCUU, lCUULimpAf )
 
	Local nI := 0
		
	Default oModel	:= Nil
	Default oModelC9V	:= Nil
	Default oModelT2F	:= Nil
	Default oModelCUU	:= Nil
	Default aGrava	    := {}
	Default aGravaT2F	:= {}
	Default aGravaCUU	:= {}
	Default lCUULimpAf	:= .F.

	//******************
	//Dados do Trabalhor
	//******************                         
	For nI := 1 to Len( oModelC9V:aDataModel[ 1 ] )
		Aadd( aGrava, { oModelC9V:aDataModel[ 1, nI, 1 ], oModelC9V:aDataModel[ 1, nI, 2 ] } )
	Next nI
	//------------------
					
	//*******
	//Vinculo
	//*******
	For nI := 1 to Len( oModelCUU:aDataModel[ 1 ] )

		//--------------------------------------------------------------------------------------------------------------
		// Em caso de transferencia, se o trabalhador já possuir evento de afastamento (CM6), limpa os campos de inicio
		// no eSocial afastado, para nao ocorrer erro na filial destino, quando tentar incluir um inicio de afastamento
		//--------------------------------------------------------------------------------------------------------------
		If lCUULimpAf .And. oModelCUU:aDataModel[ 1, nI, 1 ] $ 'CUU_DTINIA|CUU_MOTVAF'
		
			Aadd( aGravaCUU, { oModelCUU:aDataModel[ 1, nI, 1 ], CriaVar(oModelCUU:aDataModel[ 1, nI, 1 ],.F.) } )
		Else
		
			Aadd( aGravaCUU, { oModelCUU:aDataModel[ 1, nI, 1 ], oModelCUU:aDataModel[ 1, nI, 2 ] } )
		EndIf

	Next nI
	//-------
					
	//***********
	//Dependentes
	//***********															
	For nI := 1 to oModel:GetModel( "MODEL_T2F" ):Length()
		oModel:GetModel( "MODEL_T2F" ):GoLine(nI)
			If !oModel:GetModel( 'MODEL_T2F' ):IsEmpty()
				If !oModel:GetModel( "MODEL_T2F" ):IsDeleted()
					aAdd(aGravaT2F,{oModelT2F:GetValue("T2F_IDDEP"),;
						oModelT2F:GetValue("T2F_TPDEP"),;
						oModelT2F:GetValue("T2F_NOMDEP"),;
						oModelT2F:GetValue("T2F_DTNASC"),;
						oModelT2F:GetValue("T2F_CPFDEP"),;
						oModelT2F:GetValue("T2F_DEPIRF"),;
						oModelT2F:GetValue("T2F_DEPSFA"),;       
						oModelT2F:GetValue("T2F_INCTRB")})
				EndIf
			EndIf
	Next nI
	//-----------
			       
Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF279Comm
Função que realiza a gravação das informações

@Param 

oModel    - Model que esta sendo editado
oModelC9V - Model da tabela C9V
aGrava    - Array que armazena as informações da tabela C9V
lFisrOpe  - Indica se a operação que esta sendo realizada se refere a uma inclusão, neste caso os campos
			 de controle de rastro não devem ser gravados 

@Return .T.

@Author aline.venancio
@Since 07/07/2020
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAF279Comm( oModel, oModelC9V, oModelT2F, oModelCUU, aGrava, aGravaT2F, aGravaCUU )

	Local nI 		 	:= 0

	Default oModel		:= Nil
	Default oModelC9V	:= Nil
	Default oModelT2F	:= Nil
	Default oModelCUU	:= Nil
	Default aGrava	    := {}
	Default aGravaT2F	:= {}
	Default aGravaCUU	:= {}

		
	/*----------------------------------------------------------
	Neste momento eu realizo a gravação de um novo registro idêntico
	ao original, apenas com as alterações nos campos modificados
	pelo usuário no cadastro
	-----------------------------------------------------------*/			
	oModel:DeActivate()
	oModel:SetOperation( 3 )
	oModel:Activate()

	//******************
	//Dados do Trabalhor
	//******************         		
	For nI := 1 to Len( aGrava )
		oModel:LoadValue( "MODEL_C9V", aGrava[ nI, 1 ], aGrava[ nI, 2 ] )
	Next nI

	//*******
	//Vinculo
	//*******
	For nI := 1 to Len( aGravaCUU )
		oModel:LoadValue( "MODEL_CUU", aGravaCUU[ nI, 1 ], aGravaCUU[ nI, 2 ] )
	Next nI
							
	//***********
	//Dependentes
	//***********				
	For nI := 1 to Len( aGravaT2F )
		If nI > 1
			oModel:GetModel( "MODEL_T2F" ):AddLine()
		EndIf
		oModel:LoadValue( "MODEL_T2F", "T2F_IDDEP" , aGravaT2F[nI][1] )
		oModel:LoadValue( "MODEL_T2F", "T2F_TPDEP" , aGravaT2F[nI][2] )
		oModel:LoadValue( "MODEL_T2F", "T2F_NOMDEP", aGravaT2F[nI][3] )
		oModel:LoadValue( "MODEL_T2F", "T2F_DTNASC", aGravaT2F[nI][4] )
		oModel:LoadValue( "MODEL_T2F", "T2F_CPFDEP", aGravaT2F[nI][5] )
		oModel:LoadValue( "MODEL_T2F", "T2F_DEPIRF", aGravaT2F[nI][6] )
		oModel:LoadValue( "MODEL_T2F", "T2F_DEPSFA", aGravaT2F[nI][7] )                                                                                                                           
		oModel:LoadValue( "MODEL_T2F", "T2F_INCTRB", aGravaT2F[nI][8] )
	Next nI
		            
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF275Carr
Função que armazena nos arrays as informações correntes do cadastro

@Param 

oModelT1U - Model da tabela T1U
oModelT3T - Model da tabela T3T
aGrava    - Array que armazena as informações da tabela T1U
aGravaT3T - Array que armazena as informações da tabela T3T

@Return .T.

@Author Rodrigo Aguilar
@Since 29/01/2014
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAF275Carr( oModelT1U, oModelT3T, aGravaT1U, aGravaT3T )
 
	Local nI := 0
													
	For nI := 1 to Len( oModelT1U:aDataModel[ 1 ] )
		Aadd( aGravaT1U, { oModelT1U:aDataModel[ 1, nI, 1 ], oModelT1U:aDataModel[ 1, nI, 2 ] } )
	Next nI
																																
	For nI := 1 to oModelT3T:Length()
		oModelT3T:GoLine(nI)
		If !oModelT3T:IsEmpty()
			If !oModelT3T:IsDeleted()
				aAdd( aGravaT3T,{ oModelT3T:GetValue( "T3T_IDDEP" ),;
									oModelT3T:GetValue("T3T_TPDEP") ,;
									oModelT3T:GetValue("T3T_NOMDEP"),;
									oModelT3T:GetValue("T3T_DTNASC"),;
									oModelT3T:GetValue("T3T_CPFDEP"),;
									oModelT3T:GetValue("T3T_DEPIRF"),;
									oModelT3T:GetValue("T3T_DEPSFA"),;
									oModelT3T:GetValue("T3T_INCTRB")})  
			EndIf              			                			                	
															
		Endif	
	Next nI				
                        
Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF275Comm
Função que realiza a gravação das informações

@Param 

oModel    - Model que esta sendo editado
oModelT1U - Model da tabela T1U
oModelT3T - Model da tabela T3T
aGrava    - Array que armazena as informações da tabela T1U
aGravaT3T - Array que armazena as informações da tabela T3T
lFisrOpe  - Indica se a operação que esta sendo realizada se refere a uma inclusão, neste caso os campos
			 de controle de rastro não devem ser gravados 

@Return .T.

@Author Rodrigo Aguilar
@Since 29/01/2014
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAF275Comm( oModel, oModelT1U, oModelT3T, aGrava, aGravaT3T, lExclu ) 

	Local nI := 0	

	Default	lExclu		:= .F.				

	//Apos deixar o registro corrente como inativo eu seto a operação de inclusão para o novo registro
	oModel:DeActivate()
	oModel:SetOperation( 3 )
	oModel:Activate()
		
	/*----------------------------------------------------------
	Neste momento eu realizo a gravação de um novo registro idêntico
	ao original, apenas com as alterações nos campos modificados
	pelo usuário no cadastro
	-----------------------------------------------------------*/					

	//Dados do Trabalhor         		
	For nI := 1 to Len( aGrava )
		oModel:LoadValue( "MODEL_T1U", aGrava[ nI, 1 ], aGrava[ nI, 2 ] )
	Next nI				

	//Dependentes
	For nI := 1 to Len( aGravaT3T )
		If nI > 1
			oModel:GetModel( "MODEL_T3T" ):AddLine()
		EndIf
		oModel:LoadValue( "MODEL_T3T", "T3T_IDDEP" , aGravaT3T[nI][1] )
		oModel:LoadValue( "MODEL_T3T", "T3T_TPDEP" , aGravaT3T[nI][2] )
		oModel:LoadValue( "MODEL_T3T", "T3T_NOMDEP", aGravaT3T[nI][3] )
		oModel:LoadValue( "MODEL_T3T", "T3T_DTNASC", aGravaT3T[nI][4] )
		oModel:LoadValue( "MODEL_T3T", "T3T_CPFDEP", aGravaT3T[nI][5] )
		oModel:LoadValue( "MODEL_T3T", "T3T_DEPIRF", aGravaT3T[nI][6] )
		oModel:LoadValue( "MODEL_T3T", "T3T_DEPSFA", aGravaT3T[nI][7] )
		oModel:LoadValue( "MODEL_T3T", "T3T_INCTRB", aGravaT3T[nI][8] )
	Next nI          
		                   
Return ( Nil )
