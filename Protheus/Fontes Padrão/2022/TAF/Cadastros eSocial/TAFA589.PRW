#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA589.CH"

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAFA589
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function TAFA589()

	Private oBrw := FwMBrowse():New()

	cMensagem := STR0001 + Chr(13) + Chr(10) // #"Dicionário Incompatível"
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

	Local oModel     := MpFormModel():New( "TAFA589", , {|oModel| ValidModel( oModel ) }, { |oModel| SaveModel( oModel ) } )
	Local oStruV73   := FwFormStruct(1,"V73")
	Local oStruV74   := FwFormStruct(1,"V74")

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruV73:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	EndIf

	oStruV73:SetProperty("V73_CPFBEN",MODEL_FIELD_OBRIGAT,.T.)
	oStruV73:SetProperty("V73_NOMEB", MODEL_FIELD_OBRIGAT,.T.)

	oStruV73:SetProperty("V73_DTNASC",MODEL_FIELD_OBRIGAT,.T.)
	oStruV73:SetProperty("V73_DTINIC",MODEL_FIELD_OBRIGAT,.T.)
	oStruV73:SetProperty("V73_RACA"  ,MODEL_FIELD_OBRIGAT,.T.)
	oStruV73:SetProperty("V73_INCFIS",MODEL_FIELD_OBRIGAT,.T.)

	oStruV73:SetProperty( "V73_CPFBEN"  	,MODEL_FIELD_WHEN,{ |oModel| oModel:GetOperation() == 3 } )
	oStruV73:SetProperty( "V73_DTRANS"  	,MODEL_FIELD_WHEN,{ || .F. } )

	oModel:AddFields('MODEL_V73', /*cOwner*/, oStruV73)
	oModel:GetModel('MODEL_V73'):SetPrimaryKey({'V73_FILIAL', 'V73_CPFBEN','V73_ATIVO'})

	oModel:AddGrid( "MODEL_V74", "MODEL_V73", oStruV74 )
	oModel:GetModel( "MODEL_V74" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_V74" ):SetUniqueLine( { "V74_TPDEP","V74_DTNASC","V74_NMDEP" } )
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
	Local oModel	:= FWLoadModel( 'TAFA589' )
	Local oStruV73a := Nil
	Local oStruV73b := Nil
	Local oStruV73c := Nil
	Local oStruv74	:= FWFormStruct( 2, 'V74' )
	Local oView     := FWFormView():New()
	Local cCmpFila  := ''
	Local cCmpFila1 := ''
	Local cCmpFila2 := ''
	Local cCmpFila3 := ''
	Local cCmpFilb  := ''
	Local cCmpFilc  := ''
	Local aCmpGrp   := {}
	Local nI        := 0

	oView:SetModel( oModel )

	// Campos do folder Informacoes da Monitoração da Saúde do Trabalhador
	cCmpFila1   := 'V73_CPFBEN|V73_NOMEB|V73_DTNASC|V73_DTINIC|V73_SEXO|V73_RACA|V73_ESTCIV|V73_INCFIS|V73_DTINCF|'
	cCmpFila2   := 'V73_TPLOG|V73_DTPLOG|V73_DLOG|V73_NUMLOG|V73_COMLOG|V73_CEP|V73_CODMUN|V73_DCODMU|V73_UF|V73_DUF|V73_BAIRRO|'
	cCmpFila3   := 'V73_PAISRE|V73_DPAISR|V73_DSCLOG|V73_NRLOGR|V73_LOGRAD|V73_DISTRI|V73_NMCIDE|V73_CODPOS|'
	cCmpFilb    := 'V73_PROTUL|'
	cCmpFilc    := 'V73_DINSIS|V73_DTRANS|V73_HTRANS|V73_DTRECP|V73_HRRECP|'

	cCmpFila := cCmpFila1 + cCmpFila2 + cCmpFila3

	oStruV73a := FwFormStruct( 2, 'V73', {|x| AllTrim( x ) + "|" $ cCmpFila } )
	oStruV73b := FwFormStruct( 2, 'V73', {|x| AllTrim( x ) + "|" $ cCmpFilb } )
	oStruV73c := FwFormStruct( 2, 'V73', {|x| AllTrim( x ) + "|" $ cCmpFilc } )

	oStruV73a:AddGroup("GRP_BENEFICIARIO"	, STR0005		    , "", 1 ) //"Informações do Benefíciario"
	oStruV73a:AddGroup("GRP_ENDERECO"	    , STR0006	    	, "", 1 ) //"Informações de Endereço Brasil"
	oStruV73a:AddGroup("GRP_ENDERECOE"	  , STR0007	    	, "", 1 ) //"Informações de Endereço Exterior"

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

	/*-----------------------------------------------------------------------------------
								Removendo Campos da View
	-------------------------------------------------------------------------------------*/
	oStruV74:RemoveField('V74_ID')
	oStruV74:RemoveField('V74_VERSAO')
	oStruV74:RemoveField('V74_NOMEVE')
	oStruV74:RemoveField('V74_FILIAL')

	oView:EnableTitleView( 'VIEW_V73a', STR0008 ) //"Cadastro de Beneficiário - Entes Públicos - Início"
	oView:EnableTitleView( 'VIEW_V73b', TafNmFolder("recibo",1) )
	oView:EnableTitleView( 'VIEW_V73c', TafNmFolder("recibo",2) )

	TafAjustRecibo(oStruV73b,"V73")

	oView:CreateHorizontalBox( 'PAINEL_PRINCIPAL', 100 )
	oView:CreateFolder( 'FOLDER_PRINCIPAL', 'PAINEL_PRINCIPAL' )

	oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA01', STR0009 ) //"Informações do Registro"
	oView:CreateHorizontalBox( 'V73a' ,  70,,, 'FOLDER_PRINCIPAL', 'ABA01' )
	oView:CreateHorizontalBox( 'V74f' , 30,,, 'FOLDER_PRINCIPAL', 'ABA01' )
	oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA02', STR0010 ) //"Info. Controle eSocial"

	oView:CreateHorizontalBox( 'V73b',  20,,,'FOLDER_PRINCIPAL' , 'ABA02' )
	oView:CreateHorizontalBox( 'V73c',  80,,,'FOLDER_PRINCIPAL' , 'ABA02' )

	oView:SetOwnerView( "VIEW_V73a", "V73a" )
	oView:SetOwnerView( "VIEW_V73b", "V73b" )
	oView:SetOwnerView( "VIEW_V73c", "V73c" )

	// Grid
	oView:CreateFolder( "FOLDER_V74","V74f" )
	oView:AddSheet( "FOLDER_V74","ABA01",STR0011 ) // Dependentes 
	
	oView:CreateHorizontalBox( 'V74' , 100,,, 'FOLDER_V74', 'ABA01' )
	oView:AddGrid(  "VIEW_V74", oStruV74, "MODEL_V74" )

	oView:AddIncrementField( "VIEW_V74", "V74_IDDEP" )
	oView:SetOwnerView( "VIEW_V74" , "V74"  )
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
	Local aAreaV73   	:= V73->( GetArea() )
	Local lRet       	:= .T.
	Local cAlias     	:= GetNextAlias()

	Default oModel   	:= Nil

	oModelV73	:= oModel:GetModel( "MODEL_V73" )
	nOperation	:= oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
		cCPFBen 	:= oModelV73:GetValue( "V73_CPFBEN" )

		If lRet .And. nOperation == MODEL_OPERATION_INSERT
			BeginSql Alias cAlias
			SELECT V73.R_E_C_N_O_
			FROM %Table:V73% V73
			WHERE V73_FILIAL  = %xFilial:V73%
				AND V73_CPFBEN = %Exp:cCPFBen%
				AND V73_NOMEVE = 'S2400'
				AND V73_ATIVO = '1'
				AND V73_STATUS <> '6'
				AND V73.%NotDel%
			EndSql

			If ((cAlias)->(!Eof()))
				cMsgErr := STR0012 //"Já existe um registro para o CPF informado"
				lRet := .F.
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
	Local cChvRegAnt := ""
	Local lRetorno   := .T.
	Local nOperation := oModel:GetOperation()
	Local oModelV73  := oModel:GetModel( "MODEL_V73" )
	Local oModelV74  := oModel:GetModel( "MODEL_V74" )

  	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

    Begin Transaction
		If nOperation == MODEL_OPERATION_INSERT

			TafAjustID( "V73", oModel)

			oModel:LoadValue( "MODEL_V73", "V73_VERSAO", xFunGetVer() )
			oModel:LoadValue( 'MODEL_V73', 'V73_NOMEVE', 'S2400' )
			oModel:LoadValue( "MODEL_V73", "V73_DINSIS", dDataBase )

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_V73', 'V73_LOGOPE' , '2', '' )
			Endif

			FwFormCommit( oModel )

		//Alteração ou exclusão Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_UPDATE

			If	V73->V73_STATUS == "4"
				If TafColumnPos( "V73_LOGOPE" )
					cLogOpeAnt := oModelV73:GetValue( "V73_LOGOPE" )
					oModel:LoadValue( 'MODEL_V73', 'V73_NOMEVE', 'S2400' )
				endif

				oModel:LoadValue( "MODEL_V73", "V73_DINSIS", dDataBase )

				//Função para carregar os valores correntes do cadastro
				TAF589Carr(oModelV73, oModelV74, @aGravaV73, @aGravaV74 )

				//Seto o campo do registro anterior como Inativo
				FAltRegAnt( "V73", "2" )

				//Esta função desativa o model corrente e inicia a operação de Inclusão das operações realizadas
				TAF589Comm( oModel, oModelV73, oModelV74, aGravaV73, aGravaV74 )

				If Findfunction("TAFAltMan")
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_V73', 'V73_LOGOPE' , '' , cLogOpeAnt )
				EndIf

				//Gravo alteração para o Extemporâneo
				If lGoExtemp
					TafGrvExt( oModel, 'MODEL_V73', 'V73' )
				EndIf
									 
				FwFormCommit( oModel )

			ElseIf	V73->V73_STATUS == "2"
				TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
				lRetorno:= .F.
			ElseIf V73->V73_STATUS == "6"
				TAFMsgVldOp(oModel,"6")//"Registro não pode ser alterado. Aguardando proc. Transm. evento de Exclusão S-3000"
				lRetorno:= .F.
			Elseif V73->V73_STATUS == "7"
				TAFMsgVldOp(oModel,"7") //"Registro não pode ser alterado, pois o evento já se encontra na base do RET"
				lRetorno:= .F.
			Else

				If TafColumnPos( "V73_LOGOPE" )
					cLogOpeAnt := V73->V73_LOGOPE
				endif

				//Gravo alteração para o Extemporâneo
				If lGoExtemp
					TafGrvExt( oModel, 'MODEL_V73', 'V73' )
				EndIf

				If Findfunction("TAFAltMan")
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_V73', 'V73_LOGOPE' , '' , cLogOpeAnt )
				EndIf

				FwFormCommit( oModel )
				TAFAltStat( 'V73', " " )
			EndIf

		//Exclusão Manual do Evento S-2400
		ElseIf nOperation == MODEL_OPERATION_DELETE

			cChvRegAnt := V73->(V73_ID + V73_VERANT)

			TAFAltStat( 'V73', " " )
			FwFormCommit( oModel )

			If V73->V73_EVENTO == "A" .Or. V73->V73_EVENTO == "E"
				TAFRastro( 'V73', 1, cChvRegAnt, .T., , IIF(Type ("oBrw") == "U", Nil, oBrw ))
			EndIf

		EndIf

	End Transaction
								
Return ( lRetorno )

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF589Carr
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Static Function TAF589Carr(oModelV73, oModelV74, aGravaV73, aGravaV74 )

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
/*/{Protheus.doc} TAF589Comm
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Static Function TAF589Comm( oModel, oModelV73, oModelV74, aGrava, aGravaV74, lExclu )

	Local cVersao    	:= ""
	Local nI 		 	:= 0
	Local cVerAnt    	:= ""
	Local cProtocolo 	:= ""
	Local cEvento    	:= ""

	Default	lExclu	 	:= .F.

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
	//Dados do Trabalhor
	For nI := 1 to Len( aGrava )
		oModel:LoadValue( "MODEL_V73", aGrava[ nI, 1 ], aGrava[ nI, 2 ] )
	Next nI
								
	//Dependentes
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
	cVersao 		:= xFunGetVer()
	cVerAnt    	:= V73->V73_VERSAO
	cProtocolo 	:= V73->V73_PROTUL
	cEvento    	:= V73->V73_EVENTO

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
/*/{Protheus.doc} TAF589Xml
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function TAF589Xml( cAlias, nRecno, nOpc, lJob )

	Local cXml      := ""
	Local cReg      := "CdBenefIn"
	Local cLayout   := "2400"
	Local cAliasDep := "V74"

	Default lJob  	:= .F.
	Default nRecno  :=  1

	cXml += TAF588GetBenXml( cLayout, cAlias, cAliasDep, nRecno )

	//Estrutura do cabecalho
	cXml := xTafCabXml( cXml, "V73", cLayout, cReg )

	//Executa gravacao do registro
	If !lJob
		xTafGerXml( cXml, cLayout )
	EndIf

Return( cXml ) 

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF589Grv
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function TAF589Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID, cEvtOri, lMigrador, lDepGPE,cKey,cMatrC9V,lLaySmpTot,lExclCMJ)

	Local cLogOpeAnt 	:= '' 
	Local cCmpsNoUpd 	:= "|V73_FILIAL|V73_ID|V73_VERSAO|V73_NOMEVE|V73_VERANT|V73_PROTUL|V73_PROTPN|V73_EVENTO|V73_STATUS|V73_ATIVO|"
	Local nI        	:= 0
	Local nJ        	:= 0
	Local nIndChv   	:= 3
	Local nSeqErrGrv	:= 0
	Local aIncons    	:= {}
	Local aRulesCad  	:= {}
	Local aChave     	:= {}
	Local oModel     	:= Nil
	Local cCabecTrab 	:= "/eSocial/evtCdBenefIn/beneficiario"
	Local cV74Path   	:= ""
	Local cCPF       	:= ""
	Local cInconMsg  	:= ""
	Local cFilV73    	:= ""
	Local cValorXml  	:= ""
	Local cCodEvent  	:= Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")
	Local nV74 		    := 0
	Local nTamModel 	:= 0
	Local nLinha		:= 0
	Local lAltPend   	:= .F.
	Local lRet      	:= .F.
	Local lDelLine  	:= .F. 
	Local lEmpty    	:= .F.
	Local lAddLine		:= .T.
	Local xChkDupl		:= {}

	Private lVldModel	:= .T. //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.
	Private oDados  	:= {}

	Default cKey        := ""
	Default cLayout  	:= "2400"
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

	cLogOpeAnt := ""

	If !TAFAlsInDic( "V73" )
		cString := STR0013 //"Ambiente desatualizado com a versão do programa existente no repositório de dados."
		cString += Chr( 13 ) + Chr( 10 )
		cString += Chr( 13 ) + Chr( 10 )
		cString += STR0014 //"Execute a atualização do dicionário do Layout Simplificado do eSocial por meio do compatibilizador UPDDISTR."

		aAdd( aIncons, cString )

		Return( { lRet, aIncons } )
	EndIf

	cFilV73  	:= FTafGetFil(cFilEv,@aIncons,"V73")
			
	oDados	:= oXML
	
	If oDados:XPathHasNode( "/eSocial/evtCdBenefIn/ideEvento/indRetif" )
		If FTafGetVal( "/eSocial/evtCdBenefIn/ideEvento/indRetif", "C", .F., @aIncons, .F. ) == '2'
			nOpc := 4
		EndIf
	EndIf

	If oDados:XPathHasNode( cCabecTrab + "/cpfBenef"  )
		cCPF	:= oDados:XPathGetNodeValue( cCabecTrab + "/cpfBenef" )
	EndIf
		
	//Chave do Registro
	aAdd( aChave, {"C", "V73_CPFBEN", cCPF, .T. } )
	aAdd( aChave, {"C", "V73_NOMEVE", "S2400", .T. } )
		
	cChave	:= Padr( aChave[ 1, 3 ], Tamsx3( aChave[ 1, 2 ])[1] ) + Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1] )

	V73->( DbSetOrder( nIndChv ) ) //V73_FILIAL+V73_CPFBEN+V73_NOMEVE+V73_ATIVO
	If ("V73")->( MsSeek( cFilV73 + cChave + '1' ) )
		If ExistS2405(.T.,V73->V73_FILIAL,V73->V73_ID,.T.)
			If V73->V73_STATUS <> '4'
				Aadd( aIncons, "000025") //"NÃ£o Ã© permitido a integraÃ§Ã£o deste evento, enquanto outro tiver pendente de transmissÃ£o."
				lAltPend := .T.
			Endif
		EndIf						
	EndIf

	//Continua o processo de integraÃ§Ã£o apenas se nÃ£o houver nenhum evento de alteraÃ§Ã£o pendente
	If !lAltPend
							
		//Funcao para validar se a operacao desejada pode ser realizada
		If FTafVldOpe( "V73", nIndChv, @nOpc,cFilEv, @aIncons, aChave, @oModel, "TAFA589", cCmpsNoUpd )

			cLogOpeAnt := V73->V73_LOGOPE
		
			//Caso se trate de uma inclusao/retificaÃ§Ã£o gravo o tipo do evento na tabela C9V
			oModel:LoadValue( "MODEL_V73", "V73_NOMEVE", "S2400" )
			
			//Carrego array com os campos De/Para de gravacao das informacoes ( Cadastrais )
			aRulesCad := Taf588RulCad( cCabecTrab, cLayout, "V73", @cInconMsg, @nSeqErrGrv, cOwner )

			//Quando se tratar de uma Exclusao direta apenas preciso realizar
			//o Commit(), nao eh necessaria nenhuma manutencao nas informacoes
			If nOpc <> 5
					
				oModel:LoadValue( "MODEL_V73", "V73_FILIAL", V73->V73_FILIAL )
				oModel:LoadValue( "MODEL_V73", "V73_XMLID", cXmlID )
				oModel:LoadValue( "MODEL_V73", "V73_TAFKEY ", cKey  )
	
				//Rodo o aRulesCad para gravar as informacoes
				For nI := 1 to Len( aRulesCad )
					cValorXml := FTafGetVal( aRulesCad[ nI, 02 ], aRulesCad[nI, 03], aRulesCad[nI, 04], @aIncons, .F. )

					oModel:LoadValue("MODEL_V73", aRulesCad[ nI, 01 ], cValorXml)							 
				Next nI

				If Findfunction("TAFAltMan")
					if nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_V73', 'V73_LOGOPE' , '1', '' )
					elseif nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_V73', 'V73_LOGOPE' , '', cLogOpeAnt )
					EndIf
				EndIf
					
				//***********
				//Dependentes
				//***********
				cV74Path 	:= cCabecTrab + "/dependente"
					
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
				While oDados:XPathHasNode( cCabecTrab + "/dependente[" + cValToChar(nV74)+ "]" ) .OR. ( nV74 <= nTamModel .AND. !lAddLine ) 
					
					If ( nOpc == 3 .And. nV74 > 1 .And. oDados:XPathHasNode( cV74Path + "[" + cValToChar(nV74)+ "]" ) ) .OR. ( oDados:XPathHasNode( cV74Path + "[" + cValToChar(nV74)+ "]" ) .And. lAddLine )
						
						oModel:GetModel( "MODEL_V74" ):lValid:= .T.
						oModel:GetModel( "MODEL_V74" ):AddLine()
					
					EndIf						
					
					If TafXNode( oDados, cCodEvent, cOwner, (cV74Path + "[" + cValToChar(nV74) + "]/tpDep"), cV74Path + "/tpDep")	
						oModel:LoadValue( "MODEL_V74", "V74_IDDEP", StrZero(nV74,6) )
						oModel:LoadValue( "MODEL_V74", "V74_TPDEP", FGetIdInt( "tpDep", "", cCabecTrab + "/dependente[" + cValToChar(nV74) + "]/tpDep" ,,,,@cInconMsg, @nSeqErrGrv,,, @lEmpty ) )
						lDelLine := Iif(lEmpty,.T.,lDelLine)
					EndIf

					If TafXNode( oDados, cCodEvent, cOwner, (cV74Path + "[" + cValToChar(nV74) + "]/sexoDep"), cV74Path + "/sexoDep")	
						oModel:LoadValue( "MODEL_V74", "V74_SEXDEP", FTafGetVal( cCabecTrab + "/dependente[" + cValToChar(nV74) + "]/sexoDep"  , "C", .F., @aIncons, .F., '', '' ) )
						lDelLine := Iif(lEmpty,.T.,lDelLine)
					EndIf
							
					If TafXNode( oDados, cCodEvent, cOwner, (cV74Path + "[" + cValToChar(nV74) + "]/nmDep"), cV74Path + "/nmDep") .AND. !lDelLine
						oModel:LoadValue("MODEL_V74", "V74_NMDEP", FTafGetVal( cCabecTrab + "/dependente[" + cValToChar(nV74) + "]/nmDep", "C", .F., @aIncons, .F., '', '',, @lEmpty ) )
						lDelLine := Iif(lEmpty,.T.,lDelLine)
					EndIf
							
					If TafXNode( oDados, cCodEvent, cOwner, (cV74Path + "[" + cValToChar(nV74) + "]/dtNascto"), cV74Path + "/dtNascto") .AND. !lDelLine
						oModel:LoadValue( "MODEL_V74", "V74_DTNASC", FTafGetVal( cCabecTrab + "/dependente[" + cValToChar(nV74) + "]/dtNascto", "D", .F., @aIncons, .F., '' ,'',, @lEmpty ) )
						lDelLine := Iif(lEmpty,.T.,lDelLine)
					EndIf
					
					//Verifico se foi enviado as TAGs no XML
					If oDados:XPathHasNode( cV74Path + "[" + cValToChar(nV74)+ "]" ) .AND. !lDelLine
							
						If TafXNode( oDados, cCodEvent, cOwner, (cV74Path + "[" + cValToChar(nV74) + "]/cpfDep"), cV74Path + "/cpfDep" )
							oModel:LoadValue( "MODEL_V74", "V74_CPFDEP", FTafGetVal( cCabecTrab + "/dependente[" + cValToChar(nV74) + "]/cpfDep"  , "C", .F., @aIncons, .F., '', '' ) )
						EndIf
								
						If TafXNode( oDados, cCodEvent, cOwner, (cV74Path + "[" + cValToChar(nV74) + "]/depIRRF"), cV74Path + "/depIRRF" )
							oModel:LoadValue( "MODEL_V74", "V74_DEPIRF", FTafGetVal( xFunTrcSN( TAFExisTag( cCabecTrab + "/dependente[" + cValToChar(nV74) + "]/depIRRF" ),2 ), "C", .T., @aIncons, .F., '', '' ) )
						EndIf
								
						If TafXNode( oDados, cCodEvent, cOwner, (cV74Path + "[" + cValToChar(nV74) + "]/incFisMen"), cV74Path + "/incFisMen" )
							oModel:LoadValue( "MODEL_V74", "V74_INCFIS", FTafGetVal( xFunTrcSN( TAFExisTag( cCabecTrab + "/dependente[" + cValToChar(nV74) + "]/incFisMen" ),2 ), "C", .T., @aIncons, .F., '', '' ) )
						EndIf
					
					EndIf
								
					//Deleto a linha do modelo caso um campo chave seja excluÃ­do
					If lDelLine
						
						nLinha := Iif(!lAddLine, nV74, nTamModel+nV74)		
						
						oModel:GetModel( 'MODEL_V74' ):GoLine(nLinha) 
						oModel:GetModel( 'MODEL_V74' ):DeleteLine()
						
						lDelLine := .F.
					EndIf
						
					nV74++
				EndDo
			
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
		
	EndIf

Return { lRet, aIncons }

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

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		//Posiciona o item
		V73->( dbGoto(nRecno) )

		//Carrego a Estrutura dos Models a serem gravados
		oModelV73 := oModel:GetModel( "MODEL_V73" )
		oModelV74 := oModel:GetModel( "MODEL_V74" )

		//Função para carregar os valores correntes do cadastro
		TAF589Carr( oModelV73, oModelV74, @aGravaV73, @aGravaV74 )

		//Seto o Registro corrente como Inativo
		FAltRegAnt( "V73", "2" )

		//Esta função desativa o model corrente e inicia a operação de Inclusão das operações realizadas
		TAF589Comm( oModel, oModelV73, oModelV74, aGravaV73, aGravaV74, .T. )

		//Gravo alteração para o Extemporâneo
		If lGoExtemp
			TafGrvExt( oModel, 'MODEL_V73', 'V73' )
		EndIf

		FwFormCommit( oModel )
		TAFAltStat( 'V73', "6" )

	End Transaction

Return ( .T. )
