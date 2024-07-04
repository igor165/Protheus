#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA590.CH"

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAFA590
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function TAFA590()

	Private oBrw := FwMBrowse():New()

	cMensagem := STR0001 + Chr(13) + Chr(10) // #"Dicion·rio IncompatÌvel"
	cMensagem += STR0002

	Aviso( STR0003, cMensagem, { STR0004 }, 3 ) // #"Encerrar"
	
Return

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruV73  := FwFormStruct(1,"V73")
	Local oStruV74  := FwFormStruct(1,"V74")
	Local oModel    := MpFormModel():New("TAFA590",,{ |oModel| ValidModel( oModel ) }, { |oModel| SaveModel( oModel ) })

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruV73:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	EndIf

	oStruV73:SetProperty( "V73_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )

	oStruV73:SetProperty("V73_NOMEB" ,MODEL_FIELD_OBRIGAT,.T.)
	oStruV73:SetProperty("V73_SEXO"  ,MODEL_FIELD_OBRIGAT,.T.)
	oStruV73:SetProperty("V73_RACA"  ,MODEL_FIELD_OBRIGAT,.T.)
	oStruV73:SetProperty("V73_INCFIS",MODEL_FIELD_OBRIGAT,.T.)
	oStruV73:SetProperty("V73_DTALTE",MODEL_FIELD_OBRIGAT,.T.)

	oStruV73:SetProperty( "V73_CPFBEN" ,MODEL_FIELD_WHEN,{|| .F. })
	oStruV73:SetProperty( "V73_DTRANS" ,MODEL_FIELD_WHEN,{|| .F. })

	oModel:AddFields('MODEL_V73', /*cOwner*/, oStruV73)
	oModel:GetModel('MODEL_V73'):SetPrimaryKey({'V73_FILIAL', 'V73_CPF','V73_ATIVO'})

	oModel:AddGrid( "MODEL_V74", "MODEL_V73", oStruV74 )
	oModel:GetModel( "MODEL_V74" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_V74" ):SetUniqueLine( { "V74_TPDEP","V74_DTNASC","V74_NMDEP"  } )
	oModel:SetRelation( "MODEL_V74", { { "V74_FILIAL", "xFilial( 'V73' )" }, { "V74_ID", "V73_ID" }, { "V74_VERSAO","V73_VERSAO" }, { "V74_NOMEVE","V73_NOMEVE" } }, V74->( IndexKey( 1 ) ) )

Return(oModel)

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel		:= FWLoadModel( 'TAFA590' )
	Local oStruV73a  	:= Nil
	Local oStruV73b  	:= Nil
	Local oStruV73c  	:= Nil
	Local oStruv74		:= Nil
	Local oView     	:= FWFormView():New()
	Local cCmpFila   	:= ''
	Local cCmpFila1		:= ''
	Local cCmpFila2		:= ''
	Local cCmpFila3		:= ''
	Local cCmpFilb   	:= ''
	Local cCmpFilc   	:= ''
	Local aCmpGrp		:= {}
	Local nI			:= 0

	oView:SetModel( oModel )

	// Campos do folder Informacoes da MonitoraÁ„o da Sa˙de do Trabalhador
	cCmpFila1   := 'V73_CPFBEN|V73_NOMEB|V73_DTALTE|V73_SEXO|V73_RACA|V73_ESTCIV|V73_INCFIS|'
	cCmpFila2   := 'V73_TPLOG|V73_DTPLOG|V73_DLOG|V73_NUMLOG|V73_COMLOG|V73_CEP|V73_CODMUN|V73_DCODMU|V73_UF|V73_DUF|V73_BAIRRO|'
	cCmpFila3   := 'V73_PAISRE|V73_DPAISR|V73_DSCLOG|V73_NRLOGR|V73_LOGRAD|V73_DISTRI|V73_NMCIDE|V73_CODPOS|'
	cCmpFilb    := 'V73_PROTUL|'
	cCmpFilc    := 'V73_DINSIS|V73_DTRANS|V73_HTRANS|V73_DTRECP|V73_HRRECP|'

	cCmpFila := cCmpFila1 + cCmpFila2 + cCmpFila3

	oStruV73a := FwFormStruct( 2, 'V73', {|x| AllTrim( x ) + "|" $ cCmpFila } )
	oStruV73b := FwFormStruct( 2, 'V73', {|x| AllTrim( x ) + "|" $ cCmpFilb } )
	oStruV73c := FwFormStruct( 2, 'V73', {|x| AllTrim( x ) + "|" $ cCmpFilc } )

	oStruV73a:AddGroup("GRP_BENEFICIARIO"	, STR0005		    , "", 1 ) //"InformaÁıes do BenefÌciario"
	oStruV73a:AddGroup("GRP_ENDERECO"	    , STR0006	    	, "", 1 ) //"InformaÁıes de EndereÁo Brasil"
	oStruV73a:AddGroup("GRP_ENDERECOE"	  , STR0007	    	, "", 1 ) //"InformaÁıes de EndereÁo Exterior"

	oStruv74	:= FWFormStruct( 2, 'V74' )
	aCmpGrp := StrToKArr(cCmpFila1,"|")

	For nI := 1 to Len(aCmpGrp)
		oStruV73a:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_BENEFICIARIO")
	Next nI

	aCmpGrp := StrToKArr(cCmpFila2,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruV73a:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_ENDERECO")
	Next nI

	aCmpGrp := StrToKArr(cCmpFila3,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruV73a:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_ENDERECOE")
	Next nI

	oView:AddField( 'VIEW_V73a', oStruV73a, 'MODEL_V73')
	oView:AddField( 'VIEW_V73b', oStruV73b, 'MODEL_V73' )
	oView:AddField( 'VIEW_V73c', oStruV73c, 'MODEL_V73' )

	oView:EnableTitleView( 'VIEW_V73a', STR0008) //"Cadastro de Benefici·rio - Entes P˙blicos - AlteraÁ„o"
	oView:EnableTitleView( 'VIEW_V73b', TafNmFolder("recibo",1) )
	oView:EnableTitleView( 'VIEW_V73c', TafNmFolder("recibo",2) )

	TafAjustRecibo(oStruV73b,"V73")

	oView:CreateHorizontalBox( 'PAINEL_PRINCIPAL', 100 )
	oView:CreateFolder( 'FOLDER_PRINCIPAL', 'PAINEL_PRINCIPAL' )

	oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA01', "InformaÁıes do Registro" ) //"InformaÁıes do Registro"
	oView:CreateHorizontalBox( 'V73a' ,  70,,, 'FOLDER_PRINCIPAL', 'ABA01' )
	oView:CreateHorizontalBox( 'V74f' , 30,,, 'FOLDER_PRINCIPAL', 'ABA01' )
	oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA02', STR0009 ) //"Info. Controle eSocial"

	oView:CreateHorizontalBox( 'V73b',  20,,,'FOLDER_PRINCIPAL' , 'ABA02' )
	oView:CreateHorizontalBox( 'V73c',  80,,,'FOLDER_PRINCIPAL' , 'ABA02' )

	oView:SetOwnerView( "VIEW_V73a", "V73a" )
	oView:SetOwnerView( "VIEW_V73b", "V73b" )
	oView:SetOwnerView( "VIEW_V73c", "V73c" )

	// Grid
	oView:CreateFolder( "FOLDER_V74","V74f" )
	oView:AddSheet( "FOLDER_V74","ABA01",STR0010 ) // Dependentes

	oView:CreateHorizontalBox( 'V74' , 100,,, 'FOLDER_V74', 'ABA01' )
	oView:AddGrid(  "VIEW_V74", oStruV74, "MODEL_V74" )

	oView:AddIncrementField( "VIEW_V74", "V74_IDDEP" )

	oView:SetOwnerView( "VIEW_V74" , "V74"  )

	/*-----------------------------------------------------------------------------------
								Removendo Campos da View
	-------------------------------------------------------------------------------------*/
	oStruV74:RemoveField('V74_ID')
	oStruV74:RemoveField('V74_VERSAO')
	oStruV74:RemoveField('V74_NOMEVE')
	oStruV74:RemoveField('V74_FILIAL')
Return oView

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Static Function ValidModel( oModel )
	Local oModelV73  	:=	Nil
	Local nOperation 	:=	Nil
	Local cMsgErr	 	:= ""
	Local cCPFBen		:= ""
	Local cDtAlte		:= ""
	Local aAreaV73   	:= V73->( GetArea() )
	Local lRet       	:= .T.
	Local cAlias     	:= ""

	Default oModel   	:= Nil

	//Controle se o evento È extempor‚neo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	oModelV73	:= oModel:GetModel( "MODEL_V73" )
	nOperation	:= oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
		cAlias  := GetNextAlias()
		cCPFBen := oModelV73:GetValue( "V73_CPFBEN" )
		cDtAlte := DToS(oModelV73:GetValue( "V73_DTALTE" ))

		If lRet .And. nOperation == MODEL_OPERATION_INSERT
			BeginSql Alias cAlias
			SELECT V73_DTALTE
			FROM %Table:V73% V73
			WHERE V73_FILIAL  = %xFilial:V73%
				AND V73_CPFBEN = %Exp:cCPFBen%
				AND V73_NOMEVE = 'S2405'
				AND V73_ATIVO = '1'
				AND V73_STATUS <> '6'
				AND V73.%NotDel%
			EndSql

			If ((cAlias)->(!Eof()))
				// Verifica chave ˙nica

				While (cAlias)->(!Eof())
					If V73_DTALTE == cDtAlte
						cMsgErr := STR0011 //"J· existe um registro para o CPF e Data de AlteraÁ„o informados."
						lRet 		:= .F.
						Exit
					EndIf

					(cAlias)->(DbSkip())
				EndDo

				// Verifica extempor‚neo
				If lRet
					(cAlias)->(DbGoTop())

					If lGoExtemp
						lRet := .F.
					EndIf

					While (cAlias)->(!Eof())

						If V73_DTALTE > cDtAlte
							If lGoExtemp
								lRet 		:= .T.
							Else
								cMsgErr := STR0017 + CRLF + CRLF + STR0018 //"N„o pode ser incluÌda alteraÁ„o com data inferior a ultima alteraÁ„o." //"SoluÁ„o: Incluir alteraÁıes retroativas via extempor‚neo."
								lRet 		:= .F.
							EndIf

							Exit
						EndIf

						(cAlias)->(DbSkip())
					EndDo
				
					If lGoExtemp .And. !lRet
						cMsgErr := STR0019 + CRLF + CRLF + STR0020 //"N„o pode ser incluÌda alteraÁ„o com data posterior a ultima alteraÁ„o." //"SoluÁ„o: Incluir nova alteraÁ„o via tela de Cadastro de Benefici·rio."
					EndIf
				EndIf
			EndIf

			(cAlias)->(DbCloseArea())
		EndIf
	EndIf

	If !lRet
		oModel:SetErrorMessage(, , , , ,cMsgErr, , , )
	EndIf

	RestArea( aAreaV73 )
Return( lRet )


//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local aGravaV73  := {}
	Local aGravaV74  := {}
	Local cLogOpeAnt := ""
	Local lRetorno   := .T.
	Local nOperation := oModel:GetOperation()
	Local oModelV73  := oModel:GetModel( "MODEL_V73" )
	Local oModelV74  := oModel:GetModel( "MODEL_V74" )

  	//Controle se o evento È extempor‚neo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

 	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT

			TafAjustID( "V73", oModel)

			oModel:LoadValue( "MODEL_V73", "V73_ID", V73->V73_ID)
			oModel:LoadValue( "MODEL_V73", "V73_VERSAO", xFunGetVer() )
			oModel:LoadValue( 'MODEL_V73', 'V73_NOMEVE', 'S2405' )
			oModel:LoadValue( "MODEL_V73", "V73_DINSIS", dDataBase )

			V73->( DBSetOrder( 4 ) ) // V73_FILIAL+V73_ID+V73_ATIVO+DTOS(V73_DTALTE)
			If V73->( MsSeek( xFilial( "V73" ) + FwFldGet('V73_ID') + "1" + DToS(FwFldGet('V73_DTALTE'))) )

				If AllTrim(FwFldGet('V73_EVENTO')) == "A"
					oModel:LoadValue( "MODEL_V73", "V73_VERANT", V73->V73_VERSAO )
					oModel:LoadValue( "MODEL_V73", "V73_PROTPN", V73->V73_PROTUL )
					
					FAltRegAnt( "V73", "2" ) //Seto o registro corrente como Inativo
				EndIf
			EndIf

			//Gravo alteraÁ„o para o Extempor‚neo
			If lGoExtemp
				TafGrvExt( oModel, 'MODEL_V73', 'V73' )
			EndIf

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_V73', 'V73_LOGOPE' , '2', '' )
			Endif

			FwFormCommit( oModel )

		//AlteraÁ„o ou exclus„o Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_UPDATE

			If	V73->V73_STATUS == "4"

				oModel:LoadValue( "MODEL_V73", "V73_DINSIS", dDataBase )
				
				If TafColumnPos( "V73_LOGOPE" )
					cLogOpeAnt := oModelV73:GetValue( "V73_LOGOPE" )
				endif

				//FunÁ„o para carregar os valores correntes do cadastro
				TAF590Carr( oModelV73, oModelV74, @aGravaV73, @aGravaV74 )

				//Seto o campo do registro anterior como Inativo
				FAltRegAnt( "V73", "2" )

				//Esta funÁ„o desativa o model corrente e inicia a operaÁ„o de Inclus„o das operaÁıes realizadas
				TAF590Comm( oModel, oModelV73, oModelV74, aGravaV73, aGravaV74 )

				If Findfunction("TAFAltMan")
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_V73', 'V73_LOGOPE' , '' , cLogOpeAnt )
				EndIf

				//Gravo alteraÁ„o para o Extempor‚neo
				If lGoExtemp
					TafGrvExt( oModel, 'MODEL_V73', 'V73' )
				EndIf

				FwFormCommit( oModel )

			ElseIf	V73->V73_STATUS == "2"
				TAFMsgVldOp(oModel,"2")//"Registro n„o pode ser alterado. Aguardando processo da transmiss„o."
				lRetorno:= .F.
			ElseIf V73->V73_STATUS == "6"
				TAFMsgVldOp(oModel,"6")//"Registro n„o pode ser alterado. Aguardando proc. Transm. evento de Exclus„o S-3000"
				lRetorno:= .F.
			Elseif V73->V73_STATUS == "7"
				TAFMsgVldOp(oModel,"7") //"Registro n„o pode ser alterado, pois o evento j· se encontra na base do RET"
				lRetorno:= .F.
			Else

				If TafColumnPos( "V73_LOGOPE" )
					cLogOpeAnt := V73->V73_LOGOPE
				endif

				//Gravo alteraÁ„o para o Extempor‚neo
				If lGoExtemp
					TafGrvExt( oModel, 'MODEL_V73', 'V73' )
				EndIf

				If Findfunction("TAFAltMan")
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_V73', 'V73_LOGOPE' , '' , cLogOpeAnt )
				EndIf

				FwFormCommit( oModel )
				TAFAltStat( 'V73', " " )
			EndIf

		//Exclus„o Manual do Evento S-2405
		ElseIf nOperation == MODEL_OPERATION_DELETE

			TAFAltStat( 'V73', " " )
			FwFormCommit( oModel )
	
			If V73->V73_EVENTO == "A" .Or. V73->V73_EVENTO == "E"
				TAFRastro( 'V73', 1, V73->(V73_ID + V73_VERANT), .T., , IIF(Type ("oBrw") == "U", Nil, oBrw ))
			EndIf
		
		EndIf

	End Transaction

Return ( lRetorno )

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF590Carr
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Static Function TAF590Carr( oModelV73, oModelV74, aGravaV73, aGravaV74 )
	Local nI := 0

	For nI := 1 to Len( oModelV73:aDataModel[ 1 ] )
		Aadd( aGravaV73, { oModelV73:aDataModel[ 1, nI, 1 ], oModelV73:aDataModel[ 1, nI, 2 ] } )
	Next nI

	For nI := 1 to oModelV74:Length()
		oModelV74:GoLine(nI)
		If !oModelV74:IsEmpty()
			If !oModelV74:IsDeleted()
                aAdd( aGravaV74,{ oModelV74:GetValue( "V74_IDDEP" ),;
                                    oModelV74:GetValue("V74_TPDEP"),;
                                    oModelV74:GetValue("V74_NMDEP"),;
                                    oModelV74:GetValue("V74_DTNASC"),;
                                    oModelV74:GetValue("V74_CPFDEP"),;
                                    oModelV74:GetValue("V74_SEXDEP"),;
                                    oModelV74:GetValue("V74_DEPIRF"),;
                                    oModelV74:GetValue("V74_INCFIS")})
			EndIf
		Endif
	Next nI

Return ( Nil )

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF590Comm
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Static Function TAF590Comm( oModel, oModelV73, oModelV74, aGrava, aGravaV74, lExclu )
	Local cVersao    	:= ""
	Local nI 		 	:= 0
	Local cVerAnt    	:= ""
	Local cProtocolo 	:= ""
	Local cEvento    	:= ""

	Default	lExclu	 	:= .F.

	/*----------------------------------------------------------
	Apos deixar o registro corrente como inativo eu seto a 
	operaÁ„o de inclus„o para o novo registro
	-----------------------------------------------------------*/
	oModel:DeActivate()
	oModel:SetOperation( 3 )
	oModel:Activate()
		
	/*----------------------------------------------------------
	Neste momento eu realizo a gravaÁ„o de um novo registro idÍntico
	ao original, apenas com as alteraÁıes nos campos modificados
	pelo usu·rio no cadastro
	-----------------------------------------------------------*/					
	For nI := 1 to Len( aGrava )
		oModel:LoadValue( "MODEL_V73", aGrava[ nI, 1 ], aGrava[ nI, 2 ] )
	Next nI
								
	For nI := 1 to Len( aGravaV74 )
		If nI > 1
			oModel:GetModel( "MODEL_V74" ):AddLine()
		EndIf

		oModel:LoadValue( "MODEL_V74", "V74_IDDEP" , aGravaV74[nI][1] )
		oModel:LoadValue( "MODEL_V74", "V74_TPDEP" , aGravaV74[nI][2] )
		oModel:LoadValue( "MODEL_V74", "V74_NMDEP" , aGravaV74[nI][3] )
		oModel:LoadValue( "MODEL_V74", "V74_DTNASC", aGravaV74[nI][4] )
		oModel:LoadValue( "MODEL_V74", "V74_CPFDEP", aGravaV74[nI][5] )
		oModel:LoadValue( "MODEL_V74", "V74_SEXDEP", aGravaV74[nI][6] )
		oModel:LoadValue( "MODEL_V74", "V74_DEPIRF", aGravaV74[nI][7] )
		oModel:LoadValue( "MODEL_V74", "V74_INCFIS", aGravaV74[nI][8] )
	Next nI
							
	//Busco a nova versao do registro
	cVersao := xFunGetVer()

	cVerAnt    := V73->V73_VERSAO
	cProtocolo := V73->V73_PROTUL
	cEvento    := V73->V73_EVENTO

	oModel:LoadValue( "MODEL_V73", "V73_VERSAO", cVersao )
	oModel:LoadValue( "MODEL_V73", "V73_VERANT", cVerAnt )
	oModel:LoadValue( "MODEL_V73", "V73_PROTPN", cProtocolo )
	oModel:LoadValue( "MODEL_V73", "V73_PROTUL", "" )
	oModel:LoadValue( "MODEL_V73", "V73_STATUS", "" )
	
	// Tratamento para limpar o ID unico do xml
	cAliasPai := "V73"
	If TAFColumnPos( cAliasPai+"_XMLID" )
		oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
	EndIf

	IF lExclu
		oModel:LoadValue( "MODEL_V73", "V73_EVENTO", "E" )
		oModel:LoadValue( "MODEL_V73", "V73_ATIVO", "1" )
	Else
		If cEvento == "I"
			oModel:LoadValue( "MODEL_V73", "V73_EVENTO", "A" )
		EndIf
	EndIf
Return ( Nil )

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF590Xml
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function TAF590Xml( cAlias, nRecno, nOpc, lJob )
	Local cXml      := ""
	Local cReg      := "CdBenefAlt"
	Local cLayout   := "2405"
	Local cAliasDep := "V74"

	Default lJob    := .F.
	Default nRecno  := 1

	cXml += TAF588GetBenXml( cLayout, cAlias, cAliasDep, nRecno )

	//Estrutura do cabecalho
	cXml := xTafCabXml( cXml, "V73", cLayout, cReg )

	//Executa gravacao do registro
	If !lJob
		xTafGerXml( cXml, cLayout )
	EndIf
Return( cXml )

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )
	Local aGravaV73		:= {}
	Local aGravaV74		:= {}
	Local oModelV73  	:= Nil
	Local oModelV74  	:= Nil

	//Controle se o evento È extempor‚neo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		//Posiciona o item
		V73->( dbGoto(nRecno) )

		//Carrego a Estrutura dos Models a serem gravados
		oModelV73 := oModel:GetModel( "MODEL_V73" )
		oModelV74 := oModel:GetModel( "MODEL_V74" )

		//FunÁ„o para carregar os valores correntes do cadastro
		TAF590Carr( oModelV73, oModelV74, @aGravaV73, @aGravaV74 )

		//Seto o Registro corrente como Inativo
		FAltRegAnt( "V73", "2" )

		//Esta funÁ„o desativa o model corrente e inicia a operaÁ„o de Inclus„o das operaÁıes realizadas
		TAF590Comm( oModel, oModelV73, oModelV74, aGravaV73, aGravaV74, .T. )

		//Gravo alteraÁ„o para o Extempor‚neo
		If lGoExtemp
			TafGrvExt( oModel, 'MODEL_V73', 'V73' )
		EndIf

		FwFormCommit( oModel )
		TAFAltStat( 'V73', "6" )

	End Transaction
Return ( .T. )

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function TAF590Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID, cEvtOri, lMigrador, lDepGPE,cKey,cMatrC9V,lLaySmpTot,lExclCMJ)
	Local cLogOpeAnt 	:= '' 
	Local cCmpsNoUpd 	:= "|V73_FILIAL|V73_ID|V73_VERSAO|V73_NOMEVE|V73_VERANT|V73_PROTUL|V73_PROTPN|V73_EVENTO|V73_STATUS|V73_ATIVO|"
	Local nI        	:= 0
	Local nJ        	:= 0
	Local nIndChv   	:= 5
	Local nSeqErrGrv	:= 0
	Local aIncons    	:= {}
	Local aRulesCad  	:= {}
	Local aChave     	:= {}
	Local oModel     	:= Nil
	Local cCabecTrab 	:= "/eSocial/evtCdBenefAlt/ideBenef"
	Local cCabecAlte	:= "/eSocial/evtCdBenefAlt/alteracao/dadosBenef/"
	Local cV74Path   	:= ""
	Local cCPF       	:= ""
	Local cInconMsg  	:= ""
	Local cFilV73    	:= ""
	Local cValorXml  	:= ""
	Local cCodEvent  	:= Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")
	Local dDataAlt		:= CTOD("  /  /    ")
	Local nV74 		    := 0
	Local nTamModel 	:= 0
	Local nLinha		:= 0
	Local lRet      	:= .F.
	Local lDelLine  	:= .F. 
	Local lEmpty    	:= .F.
	Local lAddLine		:= .T.
	Local xChkDupl		:= {}

	Private lVldModel	:= .T. //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.
	Private oDados  	:= {}

	Default cKey		:= ""
	Default cLayout  	:= "2405"
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
	Default cPredeces	:= ""
	Default cComplem	:= ""
	Default nTafRecno	:= 0
	Default cMatrC9V	:= ""
	Default lLaySmpTot	:= .F.
	Default lExclCMJ	:= .F.

	cLogOpeAnt := ""

	If !TAFAlsInDic( "V73" )
		cString := STR0012 //"Ambiente desatualizado com a vers„o do programa existente no repositÛrio de dados."
		cString += Chr( 13 ) + Chr( 10 )
		cString += Chr( 13 ) + Chr( 10 )
		cString += STR0013 //"Execute a atualizaÁ„o do dicion·rio do Layout Simplificado do eSocial por meio do compatibilizador UPDDISTR."

		aAdd( aIncons, cString )

		Return( { lRet, aIncons } )
	EndIf

	cFilV73  	:= FTafGetFil(cFilEv,@aIncons,"V73")
	oDados		:= oXML
	
	dDataAlt	:= STOD(StrTran(oDados:XPathGetNodeValue( "/eSocial/evtCdBenefAlt/alteracao/dtAlteracao" ),"-",""))
	cCPF 			:= oDados:XPathGetNodeValue( cCabecTrab + "/cpfBenef" )
		
	//Chave do Registro
	aAdd( aChave, {"C", "V73_CPFBEN", cCPF, .T. } )
	aAdd( aChave, {"D", "V73_DTALTE",dDataAlt,.T.} )
	aAdd( aChave, {"C", "V73_NOMEVE", "S2405", .T. } )
		
	cChave	:= Padr(      aChave[ 1, 3 ], Tamsx3( aChave[ 1,2 ])[1]  ) 
	cChave  += Padr( DTOS(aChave[ 2, 3 ]),Tamsx3( aChave[ 2, 2 ])[1] )
	cChave  += Padr( 	  	aChave[ 3, 3 ], Tamsx3( aChave[ 3, 2 ])[1] )

	If oDados:XPathHasNode( "/eSocial/evtCdBenefAlt/ideEvento/indRetif" ) 
		If FTafGetVal( "/eSocial/evtCdBenefAlt/ideEvento/indRetif", "C", .F., @aIncons, .F. ) == '2'
			nOpc := 4
		EndIf
	EndIf

	V73->( DbSetOrder( 3 ) ) //V73_FILIAL+V73_CPFBEN+V73_NOMEVE+V73_ATIVO
	If !V73->( MsSeek( cFilV73 + cCPF + "S2400" + "1" ))
		Aadd( aIncons, STR0014) //"Para integraÁ„o do evento S-2405 (AlteraÁ„o de Dados Cadastrais do Benefici·rio), È necessario que exista um evento S-2400 na base."
	Else
		If V73->V73_STATUS <> "4"
			If V73->V73_STATUS == '3'
				Aadd( aIncons, STR0015) //"O evento de alteraÁ„o do Benefici·rio integrado possui um evento PAI S-2400 inconsistente."
			Else
				Aadd( aIncons, STR0016) //"O evento de alteraÁ„o do Benefici·rio integrado possui um evento PAI S-2400 n„o validado pelo RET."
			EndIf 
		EndIf 

		cIdBenf := V73->V73_ID
	EndIf
	
	//Funcao para validar se a operacao desejada pode ser realizada
	If Empty( aIncons ) .AND. FTafVldOpe( "V73", nIndChv, @nOpc,cFilEv, @aIncons, aChave, @oModel, "TAFA590", cCmpsNoUpd )

		V73->( DBSetOrder( 5 ) ) // V73_FILIAL+V73_CPFBEN+V73_DTALTE+V73_NOMEVE+V73_ATIVO
		If V73->( MsSeek( xFilial( "V73" ) + cChave + "1" ))

			If V73->V73_STATUS == "4" .AND. !Empty(V73->V73_PROTUL)
				oModel:LoadValue( "MODEL_V73", "V73_VERANT", V73->V73_VERSAO )
				oModel:LoadValue( "MODEL_V73", "V73_PROTPN", V73->V73_PROTUL )

				FAltRegAnt( "V73", "2" ) //Seto o registro corrente como Inativo
			EndIf
		EndIf

		cLogOpeAnt := V73->V73_LOGOPE
	
		//Caso se trate de uma inclusao/retifica√ß√£o gravo o tipo do evento na tabela C9V
		oModel:LoadValue( "MODEL_V73", "V73_NOMEVE", "S2405" )
		
		//Carrego array com os campos De/Para de gravacao das informacoes ( Cadastrais )
		aRulesCad := Taf588RulCad( cCabecTrab, cLayout, "V73", @cInconMsg, @nSeqErrGrv, cOwner )

		//Quando se tratar de uma Exclusao direta apenas preciso realizar
		//o Commit(), nao eh necessaria nenhuma manutencao nas informacoes

		If nOpc <> 5
			oModel:LoadValue( "MODEL_V73", "V73_FILIAL", V73->V73_FILIAL )
			oModel:LoadValue( "MODEL_V73", "V73_ID", cIdBenf )
			oModel:LoadValue( "MODEL_V73", "V73_XMLID", cXmlID )
			oModel:LoadValue( "MODEL_V73", "V73_TAFKEY ", cKey  )

			//Rodo o aRulesCad para gravar as informacoes
			For nI := 1 to Len( aRulesCad )
				cValorXml := FTafGetVal( aRulesCad[ nI, 02 ], aRulesCad[nI, 03], aRulesCad[nI, 04], @aIncons, .F. )

				oModel:LoadValue("MODEL_V73", aRulesCad[ nI, 01 ], cValorXml)							 
			Next nI

			If Findfunction("TAFAltMan")
				If nOpc == 3
					TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_V73', 'V73_LOGOPE' , '1', '' )
				ElseIf nOpc == 4
					TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_V73', 'V73_LOGOPE' , '', cLogOpeAnt )
				EndIf
			EndIf
				
			//Dependentes
			cV74Path 	:= cCabecAlte + "/dependente"
				
			//Recebo o tamanho do modelo
			nTamModel	:= oModel:GetModel( "MODEL_V74" ):Length()
			lAddLine 	:= .T.
				
			//Quando se trata de uma alteracao, deleto todas as linhas do Grid ( Dependentes )	
			If nOpc == 4 .and. TafXNode( oDados, cCodEvent, cOwner,(cV74Path + "[1]/tpDep"), cV74Path + "/tpDep" ) .AND. ;
								TafXNode( oDados, cCodEvent, cOwner,(cV74Path + "[1]/nmDep"), cV74Path + "/nmDep" ) .AND. ;
								TafXNode( oDados, cCodEvent, cOwner,(cV74Path + "[1]/dtNascto"), cV74Path + "/dtNascto" )
							
				For nJ := 1 to nTamModel
					oModel:GetModel( "MODEL_V74" ):GoLine(nJ)
					oModel:GetModel( "MODEL_V74" ):DeleteLine()
				Next nJ
			Else
				lAddLine := .F.
			EndIf		
	
			//Rodo o XML parseado para gravar as novas informacoes no GRID ( Dependentes )
			nV74	:= 1					
			While oDados:XPathHasNode( cCabecAlte + "/dependente[" + cValToChar(nV74)+ "]" ) .OR. ( nV74 <= nTamModel .AND. !lAddLine ) 
				
				If ( nOpc == 3 .And. nV74 > 1 .And. oDados:XPathHasNode( cV74Path + "[" + cValToChar(nV74)+ "]" ) ) .OR. ( oDados:XPathHasNode( cV74Path + "[" + cValToChar(nV74)+ "]" ) .And. lAddLine )
					oModel:GetModel( "MODEL_V74" ):lValid:= .T.
					oModel:GetModel( "MODEL_V74" ):AddLine()
				EndIf						
				
				If TafXNode( oDados, cCodEvent, cOwner, (cV74Path + "[" + cValToChar(nV74) + "]/tpDep"), cV74Path + "/tpDep")	
					oModel:LoadValue( "MODEL_V74", "V74_IDDEP", StrZero(nV74,6) )
					oModel:LoadValue( "MODEL_V74", "V74_TPDEP", FGetIdInt( "tpDep", "", cCabecAlte + "/dependente[" + cValToChar(nV74) + "]/tpDep" ,,,,@cInconMsg, @nSeqErrGrv,,, @lEmpty ) )
					lDelLine := Iif(lEmpty,.T.,lDelLine)
				EndIf

				If TafXNode( oDados, cCodEvent, cOwner, (cV74Path + "[" + cValToChar(nV74) + "]/sexoDep"), cV74Path + "/sexoDep")	
					oModel:LoadValue( "MODEL_V74", "V74_SEXDEP", FTafGetVal( cCabecAlte + "/dependente[" + cValToChar(nV74) + "]/sexoDep"  , "C", .F., @aIncons, .F., '', '' ) )
					lDelLine := Iif(lEmpty,.T.,lDelLine)
				EndIf
						
				If TafXNode( oDados, cCodEvent, cOwner, (cV74Path + "[" + cValToChar(nV74) + "]/nmDep"), cV74Path + "/nmDep") .AND. !lDelLine
					oModel:LoadValue("MODEL_V74", "V74_NMDEP", FTafGetVal( cCabecAlte + "/dependente[" + cValToChar(nV74) + "]/nmDep", "C", .F., @aIncons, .F., '', '',, @lEmpty ) )
					lDelLine := Iif(lEmpty,.T.,lDelLine)
				EndIf
						
				If TafXNode( oDados, cCodEvent, cOwner, (cV74Path + "[" + cValToChar(nV74) + "]/dtNascto"), cV74Path + "/dtNascto") .AND. !lDelLine
					oModel:LoadValue( "MODEL_V74", "V74_DTNASC", FTafGetVal( cCabecAlte + "/dependente[" + cValToChar(nV74) + "]/dtNascto", "D", .F., @aIncons, .F., '' ,'',, @lEmpty ) )
					lDelLine := Iif(lEmpty,.T.,lDelLine)
				EndIf
				
				//Verifico se foi enviado as TAGs no XML
				If oDados:XPathHasNode( cV74Path + "[" + cValToChar(nV74)+ "]" ) .AND. !lDelLine
						
					If TafXNode( oDados, cCodEvent, cOwner, (cV74Path + "[" + cValToChar(nV74) + "]/cpfDep"), cV74Path + "/cpfDep" )
						oModel:LoadValue( "MODEL_V74", "V74_CPFDEP", FTafGetVal( cCabecAlte + "/dependente[" + cValToChar(nV74) + "]/cpfDep"  , "C", .F., @aIncons, .F., '', '' ) )
					EndIf
							
					If TafXNode( oDados, cCodEvent, cOwner, (cV74Path + "[" + cValToChar(nV74) + "]/depIRRF"), cV74Path + "/depIRRF" )
						oModel:LoadValue( "MODEL_V74", "V74_DEPIRF", FTafGetVal( xFunTrcSN( TAFExisTag( cCabecAlte + "/dependente[" + cValToChar(nV74) + "]/depIRRF" ),2 ), "C", .T., @aIncons, .F., '', '' ) )
					EndIf
							
					If TafXNode( oDados, cCodEvent, cOwner, (cV74Path + "[" + cValToChar(nV74) + "]/incFisMen"), cV74Path + "/incFisMen" )
						oModel:LoadValue( "MODEL_V74", "V74_INCFIS", FTafGetVal( xFunTrcSN( TAFExisTag( cCabecAlte + "/dependente[" + cValToChar(nV74) + "]/incFisMen" ),2 ), "C", .T., @aIncons, .F., '', '' ) )
					EndIf
				EndIf
							
				//Deleto a linha do modelo caso um campo chave seja exclu√≠do
				If lDelLine
					
					nLinha := Iif(!lAddLine, nV74, nTamModel+nV74)		
					
					oModel:GetModel( 'MODEL_V74' ):GoLine(nLinha) 
					oModel:GetModel( 'MODEL_V74' ):DeleteLine()
					
					lDelLine := .F.
				EndIf
					
				nV74++
			EndDo
		
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

			oModel:DeActivate()
			If FindFunction('TafClearModel')
				TafClearModel(oModel)
			EndIf	
		EndIf

		//Zerando os arrays e os Objetos utilizados no processamento	
		aSize( aRulesCad, 0 )
		aRules := Nil
		
		aSize( aChave, 0 )
		aChave := Nil
	EndIf
Return { lRet, aIncons }
