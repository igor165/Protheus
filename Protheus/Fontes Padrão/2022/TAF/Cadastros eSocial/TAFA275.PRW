#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA275.CH"

STATIC lLaySimplif := taflayEsoc("S_01_00_00")

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA275
Cadastro MVC de Alteracao de Dados Cadastrais(S-2205) do eSocial

@author Felipe C. Seolin / Rodrigo Aguilar   
@since 23/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFA275()

	cMensagem := STR0050  + Chr(13) + Chr(10) //"Essa rotina está inativa a partir de uma chamada de menu"  // #"Dicionário Incompatível"
	cMensagem += STR0051 //"Por favor atualize o menu do TAF e utilize a nova rotina do Cadastro do Trabalhador"

	Aviso( STR0052, cMensagem, { STR0045 }, 3 ) // "Rotina indisponível"#"Encerrar"

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Opções da Browse

@author Felipe C. Seolin / Rodrigo Aguilar
@since 23/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()
Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Felipe C. Seolin / Rodrigo Aguilar
@since 23/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStruT1U := FwFormStruct( 1, "T1U" )
	Local oStruT3T := FwFormStruct( 1, "T3T" )
	Local oModel   := MpFormModel():New( "TAFA275",,{ |oModel| TAF275Chv( oModel ) },{ |oModel| SaveModel( oModel ) } )

	If !lLaySimplif
		oStruT3T:RemoveField( "T3T_SEXDEP" )
	EndIf


	//Indica se o Model devera ser validado quando realizada operações
	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruT1U:SetProperty( "*", MODEL_FIELD_VALID, {|| .T. })
		oStruT3T:SetProperty( "*", MODEL_FIELD_VALID, {|| .T. })
	EndIf

	//Remoção da obrigatoriedade dos campos que não fazem parte da simplificação
	If !lLaySimplif
		oStruT1U:SetProperty("T1U_DTNASC", MODEL_FIELD_OBRIGAT , .T.  )
	EndIf

	//Remoção do GetSX8Num quando se tratar da Exclusão de um Evento Transmitido.
	//Necessário para não incrementar ID que não será utilizado.
	If Upper( ProcName( 2 ) ) == Upper( "GerarExclusao" )
		oStruT1U:SetProperty( "T1U_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )
	EndIf

	//T1U - Informações genéricas do funcionário
	oModel:AddFields( "MODEL_T1U", /*cOwner*/, oStruT1U )

	//T3T - Cadastro de Dependentes
	oModel:AddGrid( "MODEL_T3T", "MODEL_T1U", oStruT3T )
	oModel:GetModel( "MODEL_T3T" ):SetOptional( .T. )

	oModel:GetModel( "MODEL_T3T" ):SetUniqueLine( { "T3T_TPDEP","T3T_NOMDEP","T3T_DTNASC"} )

	oModel:SetRelation( "MODEL_T3T",{ { "T3T_FILIAL", "xFilial('T3T')" }, { "T3T_ID", "T1U_ID" }, { "T3T_VERSAO", "T1U_VERSAO" } },T3T->( IndexKey( 1 ) ) )

	oModel:GetModel("MODEL_T1U"):SetPrimaryKey( { "T1U_ID" }, { "T1U_VERSAO" } )

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View
( Esta View é utilizada quando a tabela T1U esta sem nenhuma inclusão de alteração )

@return oView - Objeto da View MVC

@author Felipe C. Seolin / Rodrigo Aguilar
@since 23/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local cCmpFil  	:= ""
	Local nI 	 	:= 0
	Local lSelFunc 	:= .F.
	Local lBtnOk   	:= .F.
	Local aCmpGrp  	:= {}
	Local oModel    := FWLoadModel( "TAFA275" )
	Local oView     := FWFormView():New()
	Local oStruT3T	:= FWFormStruct( 2, "T3T" )
	Local oStruT1Ua, oStruT1Ub, oStruT1Uc, oStruT1Ud, oStruT1Ue,oStruT1Uf := Nil

	//Seto o Model que será utilizado no processamento
	oView:SetModel( oModel )

	oView:SetCloseOnOk( { || .T. } )

	/*-----------------------------------------------------------------------------------
								Estrutura da View do Trabalhador
	-------------------------------------------------------------------------------------*/	
	If !lLaySimplif

		cGrpTra1  := "T1U_ID|T1U_NOME|T1U_CPF|T1U_NIS|T1U_SEXO|T1U_RCCOR|T1U_ESTCIV|T1U_GRINST|T1U_DGRINS|T1U_DTALT|T1U_NOMSOC|"
		cGrpTra2  := "T1U_NRCTPS|T1U_SERCTP|T1U_UFCTPS|T1U_DUFCTP|"
		cGrpTra3  := "T1U_NRRIC|T1U_OREMRI|T1U_DTEXRI|"
		cGrpTra4  := "T1U_NRRG|T1U_OREMRG|T1U_DTEMRG|"
		cGrpTra5  := "T1U_NRRNE|T1U_OREMRN|T1U_DTEMRN|"
		cGrpTra6  := "T1U_NUMOC|T1U_OREMOC|T1U_DTEXOC|T1U_DTVLOC|"
		cGrpTra7  := "T1U_NRCNH|T1U_DTEXCN|T1U_UFCNH|T1U_DUFCN|T1U_DTVLCN|T1U_DTPCNH|T1U_CATCNH|"

	Else

		cGrpTra1  := "T1U_ID|T1U_NOME|T1U_CPF|T1U_SEXO|T1U_RCCOR|T1U_ESTCIV|T1U_GRINST|T1U_DGRINS|T1U_DTALT|T1U_NOMSOC|T1U_PAINAC|"

	EndIf

	cGrpTra8  := "T1U_PAIS|T1U_DPAIS|T1U_UF|T1U_DUF|T1U_MUN|T1U_DMUN|T1U_NOMCID|T1U_TPLOGR|T1U_DTPLOG|T1U_LOGRAD|T1U_NRLOG|T1U_COMLOG|T1U_BAIRRO|T1U_CEP|"

	If !lLaySimplif
		cGrpTra9  := "T1U_APOSEN|"
		cGrpTra10 := "T1U_DTNASC|T1U_CODPAI|T1U_DCODPA|T1U_CODUF|T1U_DCODUF|T1U_CODMUN|T1U_DCODMU|T1U_PAINAC|T1U_DPAINA|T1U_NOMMAE|T1U_NOMPAI|"
	EndIf

	If !lLaySimplif
		cCmpFil   := cGrpTra1 + cGrpTra2 + cGrpTra3 + cGrpTra4 + cGrpTra5 + cGrpTra6 + cGrpTra7 + cGrpTra8 + cGrpTra9 + cGrpTra10
	Else
		cCmpFil   := cGrpTra1 + cGrpTra8
	EndIf

	oStruT1Ua := FwFormStruct( 2, "T1U",{ |x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Informacoes do Trabalhador

	If !lLaySimplif
		cCmpFil   := "T1U_DTCHEG|T1U_CCTRAE|T1U_DCONTE|T1U_CASBRA|T1U_FILBRA|"
	Else
		cCmpFil   := "T1U_TPRESI|T1U_CNDING|"
	EndIf
	oStruT1Ub := FwFormStruct( 2, "T1U",{|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Informacoes de Trabalhador Estrangeiro

	cCmpFil   := "T1U_DEFINT|T1U_DEFFIS|T1U_DEFMOT|T1U_DEFVIS|T1U_DEFAUD|T1U_REABIL|T1U_INFCOT|T1U_DEFMEN|T1U_OBSDEF|"
	oStruT1Uc := FwFormStruct( 2, "T1U",{|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Informacoes de Deficiencias

	If !lLaySimplif
		cCmpFil   := "T1U_DDDFPR|T1U_FONPRC|T1U_DDDFAL|T1U_FONALT|T1U_EMAILP|T1U_EMAILA|"
	Else
		cCmpFil   := "T1U_DDDFPR|T1U_FONPRC|T1U_EMAILP|"
	EndIf
	oStruT1Ud := FwFormStruct( 2, "T1U",{|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Informações de Contato

	cCmpFil   := "T1U_PROTUL|"
	oStruT1Ue := FwFormStruct( 2, "T1U",{|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Protocolo de Transmissão

	If TafColumnPos("T1U_DTRANS")
		cCmpFil   := "T1U_DINSIS|T1U_DTRANS|T1U_HTRANS|T1U_DTRECP|T1U_HRRECP|"
		oStruT1Uf := FwFormStruct( 2, "T1U",{|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Info. Controle eSocial
	EndIf

	/*-----------------------------------------------------------------------------------
								Grupo de campos do Trabalhador
	-------------------------------------------------------------------------------------*/
	oStruT1Ua:AddGroup( "GRP_TRABALHADOR_01", STR0013, "", 1 ) //Dados do Trabalhador

	If !lLaySimplif

		oStruT1Ua:AddGroup( "GRP_TRABALHADOR_02", STR0039, "", 1 ) //Informações da Carteira de Trabalho
		oStruT1Ua:AddGroup( "GRP_TRABALHADOR_03", STR0034, "", 1 ) //Informações do Documento Nacional de Identidade (DNI)
		oStruT1Ua:AddGroup( "GRP_TRABALHADOR_04", STR0035, "", 1 ) //Informações do Registro Geral (RG)
		oStruT1Ua:AddGroup( "GRP_TRABALHADOR_05", STR0036, "", 1 ) //Informações do Registro Nacional de Estrangeiro
		oStruT1Ua:AddGroup( "GRP_TRABALHADOR_06", STR0037, "", 1 ) //Informações do número de registro em Órgão de Classe (OC)
		oStruT1Ua:AddGroup( "GRP_TRABALHADOR_07", STR0038, "", 1 ) //Informações da Carteira Nacional de Habilitação (CNH)

	EndIf

	oStruT1Ua:AddGroup( "GRP_TRABALHADOR_08", STR0016, "", 1 ) //Endereço

	If !lLaySimplif

		oStruT1Ua:AddGroup( "GRP_TRABALHADOR_09", STR0032, "", 1 ) //Informações sobre Aposentadoria
		oStruT1Ua:AddGroup( "GRP_TRABALHADOR_10", STR0014, "", 1 ) //Informações de Nascimento do Trabalhador

	EndIf

	aCmpGrp := StrToKArr(cGrpTra1,"|")

	For nI := 1 to Len(aCmpGrp)
		oStruT1Ua:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_01")
	Next nI

	If !lLaySimplif

		aCmpGrp := StrToKArr(cGrpTra2,"|")

		For nI := 1 to Len(aCmpGrp)
			oStruT1Ua:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_02")
		Next nI

		aCmpGrp := StrToKArr(cGrpTra3,"|")

		For nI := 1 to Len(aCmpGrp)
			oStruT1Ua:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_03")
		Next nI

		aCmpGrp := StrToKArr(cGrpTra4,"|")

		For nI := 1 to Len(aCmpGrp)
			oStruT1Ua:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_04")
		Next nI

		aCmpGrp := StrToKArr(cGrpTra5,"|")

		For nI := 1 to Len(aCmpGrp)
			oStruT1Ua:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_05")
		Next nI

		aCmpGrp := StrToKArr(cGrpTra6,"|")

		For nI := 1 to Len(aCmpGrp)
			oStruT1Ua:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_06")
		Next nI

		aCmpGrp := StrToKArr(cGrpTra7,"|")

		For nI := 1 to Len(aCmpGrp)
			oStruT1Ua:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_07")
		Next nI

	EndIf

	aCmpGrp := StrToKArr(cGrpTra8,"|")

	For nI := 1 to Len(aCmpGrp)
		oStruT1Ua:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_08")
	Next nI

	If !lLaySimplif

		aCmpGrp := StrToKArr(cGrpTra9,"|")

		For nI := 1 to Len(aCmpGrp)
			oStruT1Ua:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_09")
		Next nI

		aCmpGrp := StrToKArr(cGrpTra10,"|")

		For nI := 1 to Len(aCmpGrp)
			oStruT1Ua:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_10")
		Next nI

	EndIf

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruT1Ue,"T1U")
	EndIf

	/*-----------------------------------------------------------------------------------
								Esrutura da View
	-------------------------------------------------------------------------------------*/
	oView:AddField( "VIEW_T1Ua", oStruT1Ua, "MODEL_T1U" )
	oView:AddField( "VIEW_T1Ub", oStruT1Ub, "MODEL_T1U" )
	oView:AddField( "VIEW_T1Uc", oStruT1Uc, "MODEL_T1U" )
	oView:AddField( "VIEW_T1Ud", oStruT1Ud, "MODEL_T1U" )
	oView:AddField( "VIEW_T1Ue", oStruT1Ue, "MODEL_T1U" )

	If TafColumnPos("T1U_PROTUL")
		oView:EnableTitleView( 'VIEW_T1Ue', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"  
	EndIf
	If TafColumnPos("T1U_DTRANS")
		oView:AddField( "VIEW_T1Uf", oStruT1Uf, "MODEL_T1U" )
		oView:EnableTitleView( 'VIEW_T1Uf', TafNmFolder("recibo",2) )
	EndIf

	oView:AddGrid( "VIEW_T3T", oStruT3T, "MODEL_T3T" )
	oView:AddIncrementField( "VIEW_T3T", "T3T_IDDEP" )

	/*-----------------------------------------------------------------------------------
								Estrutura do Folder
	-------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
	oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

	//////////////////////////////////////////////////////////////////////////////////

	oView:AddSheet("FOLDER_PRINCIPAL","ABA01",STR0019) //Trabalhador

	If FindFunction("TafNmFolder")
		oView:AddSheet("FOLDER_PRINCIPAL","ABA02",TafNmFolder("recibo") )   //"Numero do Recibo"
	Else
		oView:AddSheet("FOLDER_PRINCIPAL","ABA02",STR0033)//"Protocolo de Transmissão" 
	EndIf

	If TafColumnPos("T1U_DTRANS")
		oView:CreateHorizontalBox("T1Ue",20,,,"FOLDER_PRINCIPAL","ABA02")
		oView:CreateHorizontalBox("T1Uf",80,,,"FOLDER_PRINCIPAL","ABA02")
	Else
		oView:CreateHorizontalBox("T1Ue",100,,,"FOLDER_PRINCIPAL","ABA02")
	EndIf

	//////////////////////////////////////////////////////////////////////////////////

	oView:CreateHorizontalBox("PAINEL_TRABALHADOR",100,,,"FOLDER_PRINCIPAL","ABA01")
	oView:CreateFolder("TRABALHADOR","PAINEL_TRABALHADOR")

	oView:AddSheet("TRABALHADOR","ABA01",STR0020) //Informações do Trabalhador
	oView:CreateHorizontalBox("T1Ua",100,,,"TRABALHADOR","ABA01")

	oView:AddSheet("TRABALHADOR","ABA02",STR0021) //Informações de Trabalhador Estrangeiro
	oView:CreateHorizontalBox("T1Ub",100,,,"TRABALHADOR","ABA02")

	oView:AddSheet("TRABALHADOR","ABA03",STR0022) //Informações Deficiência
	oView:CreateHorizontalBox("T1Uc",100,,,"TRABALHADOR","ABA03")

	oView:AddSheet("TRABALHADOR","ABA04",STR0023) //Dependentes
	oView:CreateHorizontalBox("T3T" ,100,,,"TRABALHADOR","ABA04")

	oView:AddSheet("TRABALHADOR","ABA05",STR0017) //Informações de Contato
	oView:CreateHorizontalBox("T1Ud",100,,,"TRABALHADOR","ABA05")

		
	/*-----------------------------------------------------------------------------------
								Amarração para exibição das informações
	-------------------------------------------------------------------------------------*/
	oView:SetOwnerView( "VIEW_T1Ua", "T1Ua" )
	oView:SetOwnerView( "VIEW_T1Ub", "T1Ub" )
	oView:SetOwnerView( "VIEW_T1Uc", "T1Uc" )
	oView:SetOwnerView( "VIEW_T1Ud", "T1Ud" )
	oView:SetOwnerView( "VIEW_T1Ue", "T1Ue" )
	If TafColumnPos("T1U_DTRANS")
		oView:SetOwnerView( "VIEW_T1Uf", "T1Uf" )
	EndIf
	oView:SetOwnerView( "VIEW_T3T" , "T3T"  )


	/*-----------------------------------------------------------------------------------
								Removendo Campos da View
	-------------------------------------------------------------------------------------*/
	oStruT3T:RemoveField('T3T_ID')
	oStruT3T:RemoveField('T3T_VERSAO')

	If !lLaySimplif
		oStruT3T:RemoveField('T3T_SEXDEP')
	EndIf
	

	//Tratamento para que alguns campos de controle interno não sejam exibidos na tela
	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If !lMenuDif
		xFunRmFStr( @oStruT1Ua, "T1U" )
	EndIf

	// Auditoria LGPD
	IIf(FindFunction('FwPDLogUser'),FwPDLogUser('TAFA275'),Nil)  

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param oModel -> Modelo de dados

@Return ( .T. )

@Author Felipe C. Seolin / Rodrigo Aguilar
@Since 24/10/2013
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local cLogOpe	 := ""
	Local cLogOpeAnt := ""

	Local cChvRegAnt := ""

	Local nOperation := oModel:GetOperation()

	Local aGravaT1U  := {}
	Local aGravaT3T  := {}

	Local oModelT1U := oModel:GetModel( "MODEL_T1U" )
	Local oModelT3T := oModel:GetModel( "MODEL_T3T" )
	

	Local lRetorno	:= .T.

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

		

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT

			TafAjustID( "T1U", oModel)

			oModel:LoadValue( "MODEL_T1U", "T1U_ID", C9V->C9V_ID)
			oModel:LoadValue( "MODEL_T1U", "T1U_VERSAO", xFunGetVer() )

			T1U->( DBSetOrder( 2 ) )
			If T1U->( MsSeek( xFilial( "T1U" ) + FwFldGet('T1U_ID') + "1" + DToS(FwFldGet('T1U_DTALT'))) )


				If AllTrim(FwFldGet('T1V_EVENTO')) == "A"
					oModel:LoadValue( "MODEL_T1U", "T1U_VERANT", T1U->T1U_VERSAO )
					oModel:LoadValue( "MODEL_T1U", "T1U_PROTPN", T1U->T1U_PROTUL )

					FAltRegAnt( "T1U", "2" ) //Seto o registro corrente como Inativo
				EndIf
			EndIf

			//Gravo alteração para o Extemporâneo
			If lGoExtemp
				TafGrvExt( oModel, 'MODEL_T1U', 'T1U' )
			EndIf

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_T1U', 'T1U_LOGOPE' , '2', '' )
			Endif

			FwFormCommit( oModel )

			//Alteração ou exclusão Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_UPDATE

			If	T1U->T1U_STATUS == "4"

				If TafColumnPos( "T1U_LOGOPE" )
					cLogOpeAnt := oModelT1U:GetValue( "T1U_LOGOPE" )
				endif

				//Função para carregar os valores correntes do cadastro
				TAF275Carr( oModelT1U, oModelT3T, @aGravaT1U, @aGravaT3T )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Seto o campo do registro anterior como Inativo             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FAltRegAnt( "T1U", "2" )

				//Esta função desativa o model corrente e inicia a operação de Inclusão das operações realizadas
				TAF275Comm( oModel, oModelT1U, oModelT3T, aGravaT1U, aGravaT3T )

				If Findfunction("TAFAltMan")
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T1U', 'T1U_LOGOPE' , '' , cLogOpeAnt )
				EndIf

				//Gravo alteração para o Extemporâneo
				If lGoExtemp
					TafGrvExt( oModel, 'MODEL_T1U', 'T1U' )
				EndIf

				FwFormCommit( oModel )

			ElseIf	T1U->T1U_STATUS == "2"
				TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
				lRetorno:= .F.
			ElseIf T1U->T1U_STATUS == "6"
				TAFMsgVldOp(oModel,"6")//"Registro não pode ser alterado. Aguardando proc. Transm. evento de Exclusão S-3000"
				lRetorno:= .F.
			Elseif T1U->T1U_STATUS == "7"
				TAFMsgVldOp(oModel,"7") //"Registro não pode ser alterado, pois o evento já se encontra na base do RET"
				lRetorno:= .F.
			Else

				If TafColumnPos( "T1U_LOGOPE" )
					cLogOpeAnt := T1U->T1U_LOGOPE
				endif

				//Gravo alteração para o Extemporâneo
				If lGoExtemp
					TafGrvExt( oModel, 'MODEL_T1U', 'T1U' )
				EndIf

				If Findfunction("TAFAltMan")
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T1U', 'T1U_LOGOPE' , '' , cLogOpeAnt )
				EndIf

				FwFormCommit( oModel )
				TAFAltStat( 'T1U', " " )
			EndIf

		//Exclusão Manual do Evento S-2205
		ElseIf nOperation == MODEL_OPERATION_DELETE
			cChvRegAnt := T1U->(T1U_ID + T1U_VERANT)
			If !Empty( cChvRegAnt )
				TAFAltStat( 'T1U', " " )
				FwFormCommit( oModel )
				If nOperation == MODEL_OPERATION_DELETE
					If T1U->T1U_EVENTO == "A" .Or. T1U->T1U_EVENTO == "E"
						TAFRastro( 'T1U', 1, cChvRegAnt, .T., , IIF(Type ("oBrw") == "U", Nil, oBrw ))
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
				If lLaySimplif
					aAdd( aGravaT3T,{ oModelT3T:GetValue( "T3T_IDDEP" ),;
						oModelT3T:GetValue("T3T_TPDEP") ,;
						oModelT3T:GetValue("T3T_NOMDEP"),;
						oModelT3T:GetValue("T3T_DTNASC"),;
						oModelT3T:GetValue("T3T_CPFDEP"),;
						oModelT3T:GetValue("T3T_SEXDEP"),;
						oModelT3T:GetValue("T3T_DEPIRF"),;
						oModelT3T:GetValue("T3T_DEPSFA"),;
						oModelT3T:GetValue("T3T_INCTRB")})
				Else
					aAdd( aGravaT3T,{ oModelT3T:GetValue( "T3T_IDDEP" ),;
						oModelT3T:GetValue("T3T_TPDEP") ,;
						oModelT3T:GetValue("T3T_NOMDEP"),;
						oModelT3T:GetValue("T3T_DTNASC"),;
						oModelT3T:GetValue("T3T_CPFDEP"),;
						oModelT3T:GetValue("T3T_DEPIRF"),;
						oModelT3T:GetValue("T3T_DEPSFA"),;
						oModelT3T:GetValue("T3T_INCTRB")})
				EndIf
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

	Local cVersao    := ""
	Local nI 		 := 0
	Local cVerAnt    := ""
	Local cProtocolo := ""
	Local cEvento    := ""

	Default	lExclu	 := .F.

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
	//******************
	//Dados do Trabalhor
	//******************         		
		For nI := 1 to Len( aGrava )
		oModel:LoadValue( "MODEL_T1U", aGrava[ nI, 1 ], aGrava[ nI, 2 ] )
		Next nI
								
	//***********
	//Dependentes
	//***********				
	For nI := 1 to Len( aGravaT3T )
		If nI > 1
			oModel:GetModel( "MODEL_T3T" ):AddLine()
		EndIf

		If !lLaySimplif
			oModel:LoadValue( "MODEL_T3T", "T3T_IDDEP" , aGravaT3T[nI][1] )
			oModel:LoadValue( "MODEL_T3T", "T3T_TPDEP" , aGravaT3T[nI][2] )
			oModel:LoadValue( "MODEL_T3T", "T3T_NOMDEP", aGravaT3T[nI][3] )
			oModel:LoadValue( "MODEL_T3T", "T3T_DTNASC", aGravaT3T[nI][4] )
			oModel:LoadValue( "MODEL_T3T", "T3T_CPFDEP", aGravaT3T[nI][5] )
			oModel:LoadValue( "MODEL_T3T", "T3T_DEPIRF", aGravaT3T[nI][6] )
			oModel:LoadValue( "MODEL_T3T", "T3T_DEPSFA", aGravaT3T[nI][7] )
			oModel:LoadValue( "MODEL_T3T", "T3T_INCTRB", aGravaT3T[nI][8] )
		Else
			oModel:LoadValue( "MODEL_T3T", "T3T_IDDEP" , aGravaT3T[nI][1] )
			oModel:LoadValue( "MODEL_T3T", "T3T_TPDEP" , aGravaT3T[nI][2] )
			oModel:LoadValue( "MODEL_T3T", "T3T_NOMDEP", aGravaT3T[nI][3] )
			oModel:LoadValue( "MODEL_T3T", "T3T_DTNASC", aGravaT3T[nI][4] )
			oModel:LoadValue( "MODEL_T3T", "T3T_CPFDEP", aGravaT3T[nI][5] )
			oModel:LoadValue( "MODEL_T3T", "T3T_SEXDEP", aGravaT3T[nI][6] )
			oModel:LoadValue( "MODEL_T3T", "T3T_DEPIRF", aGravaT3T[nI][7] )
			oModel:LoadValue( "MODEL_T3T", "T3T_DEPSFA", aGravaT3T[nI][8] )
			oModel:LoadValue( "MODEL_T3T", "T3T_INCTRB", aGravaT3T[nI][9] )
		EndIf

	Next nI
							
	//Busco a nova versao do registro
	cVersao := xFunGetVer()

	cVerAnt    := T1U->T1U_VERSAO
	cProtocolo := T1U->T1U_PROTUL
	cEvento    := T1U->T1U_EVENTO

	oModel:LoadValue( "MODEL_T1U", "T1U_VERSAO", cVersao )
	oModel:LoadValue( "MODEL_T1U", "T1U_VERANT", cVerAnt )
	oModel:LoadValue( "MODEL_T1U", "T1U_PROTPN", cProtocolo )
	oModel:LoadValue( "MODEL_T1U", "T1U_PROTUL", "" )
	oModel:LoadValue( "MODEL_T1U", "T1U_STATUS", "" )

	// Tratamento para limpar o ID unico do xml
	cAliasPai := "T1U"
	If TAFColumnPos( cAliasPai+"_XMLID" )
		oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
	EndIf

	IF lExclu
		oModel:LoadValue( "MODEL_T1U", "T1U_EVENTO", "E" )
		oModel:LoadValue( "MODEL_T1U", "T1U_ATIVO", "1" )
	Else
		If cEvento == "I"
			oModel:LoadValue( "MODEL_T1U", "T1U_EVENTO", "A" )
		EndIf
	EndIf
				
Return ( Nil )
//-------------------------------------------------------------------
/*/{Protheus.doc} TAF275Grv    

Funcao de gravacao para atender o registro S-2205

@Param:
cLayout - Nome do Layout que esta sendo enviado, existem situacoes onde o mesmo fonte
          alimenta mais de um regsitro do E-Social, para estes casos serao necessarios
          tratamentos de acordo com o layout que esta sendo enviado.
nOpc   -  Opcao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )
cFilEv -  Filial do ERP para onde as informacoes deverao ser importadas
oXML	-  Objeto com as informacoes a serem manutenidas ( Outras Integracoes )

@Return
lRet    - Variavel que indica se a importacao foi realizada, ou seja, se as
		  informacoes foram gravadas no banco de dados
aIncons - Array com as inconsistencias encontradas durante a importacao

@author Felipe C. Seolin / Rodrigo Aguilar
@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF275Grv( cLayout, nOpc, cFilEv, oXML, cOwner , cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

	Local cLogOpeAnt    := ""
	Local cCmpsNoUpd	:= "|T1U_FILIAL|T1U_ID|T1U_VERSAO|T1U_VERANT|T1U_PROTUL|T1U_PROTPN|T1U_EVENTO|T1U_STATUS|T1U_ATIVO|"
	Local cCabec	  	:= "/eSocial/evtAltCadastral/alteracao/dadosTrabalhador"
	Local cT3TPath		:= ""
	Local cChvCPF 		:= ""
	Local cFilC9V	  	:= ""
	Local cEnter	  	:= Chr(13) + Chr(10)
	Local cMensagem 	:= ""
	Local cInconMsg 	:= ""
	Local cCodEvent 	:= Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")
	Local cChv2			:= ""
	Local cDtAnter		:= ""
	Local nI         	:= 0
	Local nJ         	:= 0
	Local nSeqErrGrv 	:= 0
	Local nT3T       	:= 0
	Local nTamModel		:= 0
	Local nLinha		:= 0
	Local dDataAlt		:= CTOD("  /  /    ")
	Local lRet       	:= .F.
	Local lTransmit		:= .F.
	Local lDelLine   	:= .F.
	Local lEmpty     	:= .F.
	Local lAddLine		:= .T.
	Local aIncons    	:= {}
	Local aRulesCad  	:= {}
	Local aChave    	:= {}
	Local aGravaT3T  	:= {}
	Local oModel     	:= Nil
	Local oModelT3T 	:= Nil

	Private lVldModel	:= .T. //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.
	Private oDados   	:= {}

	Default cLayout		:= "2205"
	Default nOpc    	:= 1
	Default cFilEv  	:= ""
	Default oXML    	:= Nil
	Default cOwner		:= ""
	Default cFilTran	:=	""
	Default cPredeces	:=	""
	Default nTafRecno	:=	0
	Default cComplem	:=	""
	Default cGrpTran	:=	""
	Default cEmpOriGrp	:=	""
	Default cFilOriGrp	:=	""
	Default cXmlID		:=	""

	If !TafVldAmb("2")

		cMensagem := STR0044 + cEnter // #"Dicionário Incompatível"
		cMensagem += TafAmbInvMsg()

		Aadd(aIncons, cMensagem)

	Else

		cFilC9V := FTafGetFil( cFilEv , @aIncons , "C9V" )
		oDados  := oXML

		dDataAlt:= STOD(StrTran(oDados:XPathGetNodeValue( "/eSocial/evtAltCadastral/alteracao/dtAlteracao" ),"-",""))
		cChvCPF := oDados:XPathGetNodeValue( "/eSocial/evtAltCadastral/ideTrabalhador/cpfTrab" )

		//Chave do Registro
		aAdd( aChave, { "C", "T1U_CPF", cChvCPF, .T. } )
		Aadd( aChave, { "D", "T1U_DTALT",dDataAlt,.T.} )

		cChave	:= Padr( aChave[ 1, 3 ], Tamsx3( aChave[ 1,2 ])[1] ) + Padr( DTOS(aChave[ 2, 3 ]), Tamsx3( aChave[ 2, 2 ])[1] )

		//Verifica se o evento ja existe na base
		dbSelectArea("T1U")
		("T1U")->( DbSetOrder( 4 ) )
		If ("T1U")->( MsSeek(FTafGetFil( cFilEv , @aIncons , "T1U" ) + cChave + '1' ) )
			nOpc := 4
			lTransmit 	:= IIF(T1U->T1U_STATUS == '4',.T.,.F.)
		ElseIf ("T1U")->( MsSeek(FTafGetFil( cFilEv , @aIncons , "T1U" ) + cChave + '2' ) )
			If RetIna05('T1U',cChave, 4)
				nOpc := 4
				lTransmit 	:= IIF(T1U->T1U_STATUS == '4',.T.,.F.)
			EndIf
		EndIf

		dbSelectArea("C9V")
		C9V->( DbSetOrder( 4 ) ) //C9V_FILIAL+C9V_CPF+C9V_NOMEVE+C9V_ATIVO

		If ( !C9V->( MsSeek( cFilC9V + cChvCPF + "S2200" + "1" ) ) .and. !C9V->( MsSeek( cFilC9V + cChvCPF + "S2300" + "1" ) ) )
			Aadd( aIncons, STR0046 + " " + STR0047 )
			//'Para a integração do evento do S-2205 (Alteração de Dados Cadastrais do Trabalhador), é necessário que '
			//'exista o evento S-2200 (Cadastramento Inicial do Vínculo e Admissão/Ingresso de Trabalhador) ou S-2300 '
			//'(Trabalhador Sem Vínculo de Emprego) correspondente ao mesmo na base de dados do TAF.'
			//'Para a integração do evento S-2206 (Alteração de Contrato de Trabalho), é necessário que exista o evento '
			//'S-2200 (Cadastramento Inicial do Vínculo e Admissão/Ingresso de Trabalhador) correspondente ao mesmo  na '
			//'base de dados do TAF.'
		Else
			If C9V->C9V_STATUS <> "4"
				if C9V->C9V_STATUS == '3'
					Aadd( aIncons, "000012") //'O evento de alteração do trabalhador integrado, S-2205 (Alteração de Dados Cadastrais do Trabalhador)
					//ou S-2206 (Alteração de Contrato de Trabalho), possui um evento pai S-2100 (Cadastramento Inicial do
					//Vínculo) ou S-2200 (Admissão de Trabalhador) com inconsistência ou não validado pelo RET.'

				else
					Aadd( aIncons, STR0048 + " " + STR0049)
					//'Caso a integração seja do evento S-2205 (Alteração de Dados Cadastrais do Trabalhador) existe um evento pai '
					//'S-2200 (Cadastramento Inicial do Vínculo e Admissão/Ingresso de Trabalhador) ou S-2300 '
					//'(Trabalhador Sem Vínculo de Emprego) com inconsistência ou não validado pelo RET. ''
					//'Caso a integração seja evento do evento S-2206 (Alteração de Contrato de Trabalho) existe um evento pai '
					//'S-2200 (Cadastramento Inicial do Vínculo e Admissão/Ingresso de Trabalhador) com inconsistência'
					//'ou não validado pelo RET. '
				endif
			EndIf
		EndIf

		cIdEvtTrb := TAFGetIdFunc( cChvCPF, SubStr(DToS(dDataAlt), 1, 6), dDataAlt, "cpfTrab", "/eSocial/evtAltCadastral/ideTrabalhador/cpfTrab")
		C9V->( dbSetOrder( 16 ) )

		Begin Transaction

			//Funcao para validar se a operacao desejada pode ser realizada
			If Empty( aIncons ) .AND. FTafVldOpe( "T1U", 4, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA275", cCmpsNoUpd )

				T1U->( DBSetOrder( 2 ) )
				If T1U->( MsSeek( xFilial( "T1U" ) + cIdEvtTrb + "1" + DTOS(aChave[ 2, 3 ]) ) )

					If T1U->T1U_STATUS == "4" .AND. !Empty(T1U->T1U_PROTUL)
						oModel:LoadValue( "MODEL_T1U", "T1U_VERANT", T1U->T1U_VERSAO )
						oModel:LoadValue( "MODEL_T1U", "T1U_PROTPN", T1U->T1U_PROTUL )

						FAltRegAnt( "T1U", "2" ) //Seto o registro corrente como Inativo
					EndIf
				EndIf

				If TafColumnPos( "T1U_LOGOPE" )
					cLogOpeAnt := T1U->T1U_LOGOPE
				endif

				//Carrego array com os campos De/Para de gravacao das informacoes ( Cadastrais )
				aRulesCad := FRulCad( cCabec    , cLayout, "T1U",            , @cInconMsg, @nSeqErrGrv, lTransmit, oModel , aChave, @aIncons, cCodEvent, cOwner )

				//Quando se tratar de uma Exclusao direta apenas preciso realizar
				//o Commit(), nao eh necessaria nenhuma manutencao nas informacoes
				If nOpc <> 5

					//Carrego o ID com o ID do evento do trabalhador (S2200).
					oModel:LoadValue( "MODEL_T1U", "T1U_ID", cIdEvtTrb )
					oModel:LoadValue( "MODEL_T1U", "T1U_FILIAL", T1U->T1U_FILIAL )

					If FindFunction( "EvtExtemp" )
						If EvtExtemp("T1U",dDataAlt,cIdEvtTrb)
							oModel:LoadValue("MODEL_T1U", "T1U_STASEC", 'E')
						EndIf
					endIf

					If TAFColumnPos( "T1U_XMLID" )
						oModel:LoadValue( "MODEL_T1U", "T1U_XMLID", cXmlID )
					EndIf

					//Rodo o aRulesCad para gravar as informacoes
					For nI := 1 to Len( aRulesCad )
						oModel:LoadValue( "MODEL_T1U", aRulesCad[ nI, 01 ], FTafGetVal( aRulesCad[ nI, 02 ], aRulesCad[nI, 03], aRulesCad[nI, 04], @aIncons, .F. ) )
					Next nI

					If Findfunction("TAFAltMan")
						if nOpc == 3
							TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T1U', 'T1U_LOGOPE' , '1', '' )
						elseif nOpc == 4
							TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T1U', 'T1U_LOGOPE' , '', cLogOpeAnt )
						EndIf
					EndIf

					//***********
					//Dependentes
					//***********
					cT3TPath	:= cCabec + "/dependente"

					//Recebo o tamanho do modelo
					nTamModel	:= oModel:GetModel( "MODEL_T3T" ):Length()
					lAddLine	:= .T.

					//Quando se trata de uma alteracao, deleto todas as linhas do Grid ( Dependentes )
					If nOpc == 4 .and. TafXNode( oDados, cCodEvent, cOwner,(cT3TPath + "[1]/tpDep"), cT3TPath + "/tpDep" ) .AND. ;
							TafXNode( oDados, cCodEvent, cOwner,(cT3TPath + "[1]/nmDep"), cT3TPath + "/nmDep" ) .AND. ;
							TafXNode( oDados, cCodEvent, cOwner,(cT3TPath + "[1]/dtNascto"), cT3TPath + "/dtNascto")

						For nJ := 1 to nTamModel
							oModel:GetModel( "MODEL_T3T" ):GoLine(nJ)
							oModel:GetModel( "MODEL_T3T" ):DeleteLine()
						Next nJ
					Else
						lAddLine := .F.
					EndIf

					//Rodo o XML parseado para gravar as novas informacoes no GRID ( Dependentes )
					nT3T	:= 1
					While oDados:XPathHasNode( cCabec + "/dependente[" + cValToChar(nT3T)+ "]" ) .OR. ( nT3T <= nTamModel .AND. !lAddLine )

						If ( nOpc == 3 .And. nT3T > 1 .And. oDados:XPathHasNode( cT3TPath + "[" + cValToChar(nT3T)+ "]" ) ) .OR. ( oDados:XPathHasNode( cT3TPath + "[" + cValToChar(nT3T)+ "]" ) .And. lAddLine )

							oModel:GetModel( "MODEL_T3T" ):lValid:= .T.
							oModel:GetModel( "MODEL_T3T" ):AddLine()

						EndIf

						If TafXNode( oDados, cCodEvent, cOwner, (cT3TPath + "[" + cValToChar(nT3T) + "]/tpDep"), cT3TPath + "/tpDep")
							oModel:LoadValue( "MODEL_T3T", "T3T_IDDEP", StrZero(nT3T,6) )
							oModel:LoadValue( "MODEL_T3T", "T3T_TPDEP", FGetIdInt( "tpDep", "", cCabec + "/dependente[" + cValToChar(nT3T) + "]/tpDep" ,,,,@cInconMsg, @nSeqErrGrv,,, @lEmpty ) )
							lDelLine := Iif(lEmpty,.T.,lDelLine)
						EndIf

						If TafXNode( oDados, cCodEvent, cOwner, (cT3TPath + "[" + cValToChar(nT3T) + "]/nmDep"), cT3TPath + "/nmDep") .AND. !lDelLine
							oModel:LoadValue("MODEL_T3T", "T3T_NOMDEP", FTafGetVal( cCabec + "/dependente[" + cValToChar(nT3T) + "]/nmDep", "C", .F., @aIncons, .F., '', '',, @lEmpty ) )
							lDelLine := Iif(lEmpty,.T.,lDelLine)
						EndIf

						If TafXNode( oDados, cCodEvent, cOwner, (cT3TPath + "[" + cValToChar(nT3T) + "]/dtNascto"), cT3TPath + "/dtNascto") .AND. !lDelLine
							oModel:LoadValue( "MODEL_T3T", "T3T_DTNASC", FTafGetVal( cCabec + "/dependente[" + cValToChar(nT3T) + "]/dtNascto", "D", .F., @aIncons, .F., '' ,'',, @lEmpty ) )
							lDelLine := Iif(lEmpty,.T.,lDelLine)
						EndIf

						//Verifico se foi enviado as TAGs no XML
						If oDados:XPathHasNode( cT3TPath + "[" + cValToChar(nT3T)+ "]" ) .AND. !lDelLine

							If TafXNode( oDados, cCodEvent, cOwner, (cT3TPath + "[" + cValToChar(nT3T) + "]/cpfDep"), cT3TPath + "/cpfDep" )
								oModel:LoadValue( "MODEL_T3T", "T3T_CPFDEP", FTafGetVal( cCabec + "/dependente[" + cValToChar(nT3T) + "]/cpfDep"  , "C", .F., @aIncons, .F., '', '' ) )
							EndIf

							If lLaySimplif
								If TafXNode( oDados, cCodEvent, cOwner, (cT3TPath + "[" + cValToChar(nT3T) + "]/sexoDep"), cT3TPath + "/sexoDep" )
									oModel:LoadValue( "MODEL_T3T", "T3T_SEXDEP", FTafGetVal( cCabec + "/dependente[" + cValToChar(nT3T) + "]/sexoDep"  , "C", .F., @aIncons, .F., '', '' ) )
								EndIf
							EndIf

							If TafXNode( oDados, cCodEvent, cOwner, (cT3TPath + "[" + cValToChar(nT3T) + "]/depIRRF"), cT3TPath + "/depIRRF" )
								oModel:LoadValue( "MODEL_T3T", "T3T_DEPIRF", FTafGetVal( xFunTrcSN( TAFExisTag( cCabec + "/dependente[" + cValToChar(nT3T) + "]/depIRRF" ),2 ), "C", .T., @aIncons, .F., '', '' ) )
							EndIf

							If TafXNode( oDados, cCodEvent, cOwner, (cT3TPath + "[" + cValToChar(nT3T) + "]/depSF"), cT3TPath + "/depSF" )
								oModel:LoadValue( "MODEL_T3T", "T3T_DEPSFA", FTafGetVal( xFunTrcSN( TAFExisTag( cCabec + "/dependente[" + cValToChar(nT3T) + "]/depSF" ),2 ), "C", .T., @aIncons, .F., '', '' ) )
							EndIf

							If TafXNode( oDados, cCodEvent, cOwner, (cT3TPath + "[" + cValToChar(nT3T) + "]/incTrab"), cT3TPath + "/incTrab" )
								oModel:LoadValue( "MODEL_T3T", "T3T_INCTRB", FTafGetVal( xFunTrcSN( TAFExisTag( cCabec + "/dependente[" + cValToChar(nT3T) + "]/incTrab" ),2 ), "C", .T., @aIncons, .F., '', '' ) )
							EndIf

						EndIf

						//Deleto a linha do modelo caso um campo chave seja excluído
						If lDelLine

							nLinha := Iif(!lAddLine, nT3T, nTamModel+nT3T)

							oModel:GetModel( 'MODEL_T3T' ):GoLine(nLinha)
							oModel:GetModel( 'MODEL_T3T' ):DeleteLine()

							lDelLine := .F.

						EndIf

						nT3T++

					EndDo

				EndIf

				///ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
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
		aChave := Nil

	Endif

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF275Xml
Funcao de geracao do XML para atender o registro S-2205.
Quando a rotina for chamada o registro deve estar posicionado.

@Param:
cAlias  - Alias da Tabela
nRecno  - Recno do Registro corrente
nOpc    - Operacao a ser realizada
lJob    - Informa se foi chamado por Job

@Return:
cXml - Estrutura do Xml do Layout S-2205

@author Felipe C. Seolin / Rodrigo Aguilar
@since 23/10/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF275Xml( cAlias, nRecno, nOpc, lJob )

	Local cXml      := ""
	Local cReg      := "AltCadastral"
	Local cLayout   := "2205"
	Local cAliasDep := "T3T"

	Default lJob  := .F.

	cXml += FGetCad( cLayout, cAlias, cAliasDep )

	//Estrutura do cabecalho
	cXml := xTafCabXml( cXml, "T1U", cLayout, cReg )

	//Executa gravacao do registro
	If !lJob
		xTafGerXml( cXml, cLayout )
	EndIf

Return( cXml )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF275Chv
Função apra validação da chave única do registro

@Param:
oModel - Model Utilizado

@Return:
lRet - Status da Validação 

@author Rodrigo Aguilar
@since 29/01/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF275Chv( oModel )

	Local nOperation := oModel:GetOperation()
	Local lRet       := .T.

//Apenas realizao a operação quando se tratar de uma operação de Inclusão
	If nOperation == MODEL_OPERATION_INSERT
		lRet := xFunVldUni( "T1U",4, FwFldGet( "T1U_CPF" ) + DToS( FwFldGet( "T1U_DTALT" ) ) + "1" )
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

	Local aAreaT1U  	:= {}
	Local aAreaT3T  	:= {}
	Local aGravaT1U		:= {}
	Local aGravaT3T		:= {}

	Local nOperation	:= oModel:GetOperation()

	Local oModelT1U  	:= Nil
	Local oModelT3T  	:= Nil

//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		//Posiciona o item
		T1U->( dbGoto(nRecno) )

		//Carrego a Estrutura dos Models a serem gravados
		oModelT1U := oModel:GetModel( "MODEL_T1U" )
		oModelT3T := oModel:GetModel( "MODEL_T3T" )

		//Função para carregar os valores correntes do cadastro
		TAF275Carr( oModelT1U, oModelT3T, @aGravaT1U, @aGravaT3T )

		//Seto o Registro corrente como Inativo
		FAltRegAnt( "T1U", "2" )

		//Esta função desativa o model corrente e inicia a operação de Inclusão das operações realizadas
		TAF275Comm( oModel, oModelT1U, oModelT3T, aGravaT1U, aGravaT3T, .T. )

		//Gravo alteração para o Extemporâneo
		If lGoExtemp
			TafGrvExt( oModel, 'MODEL_T1U', 'T1U' )
		EndIf

		FwFormCommit( oModel )
		TAFAltStat( 'T1U', "6" )

	End Transaction

Return ( .T. )

/*Esta função estava sendo chamada pelo TAFLOAD e foi criada para um ajuste 
de legado pontual, a mesma está sendo excluida e para não gerar um error.log
estamos mantendo a mesma vazia, na virada de release esta função deverá
ser apagada por conta dos débitos técnicos.
*/
Function Ajstaf2205()
Return Nil
//----------------------------------------------------------------------
/*/{Protheus.doc} RetIna05
Posiciona no último registro Inativo de alteração para o evento 2205 e 2206 
existente na chave

cAlias	-> cAlias da tabela que irá posicionar
cChave	-> Chave utilizada para posicionar
nInd	-> Número do Indice 

@Return .T. - Se encontrar o último evento de alteração inativo para o trabalhador
		.F. - Se não encontrar o último evento de alteração inativo para o trabalhador

@Author  Ricardo Lovrenovic

@Since 25/02/2016
@Version 1.0
/*/
//-----------------------------------------------------------------------
Static Function RetIna05(cAlias,cChave,nInd)

	Local lReturn 	:= .F.
	Local nRecno	:= 0

	Default lTrans	:= .F. // indica se deve procurar um registro transmitido

	dbSelectArea(cAlias)
	(cAlias)->(dbSetorder(nInd)) // FILIAL + ID + ATIVO + DTALT
	(cAlias)->(dbGoTop())

	If (cAlias)->(msSeek(xFilial(cAlias) + cChave))

		While (cAlias)->(!Eof()) .And. (cAlias)->&(cAlias + "_CPF") + DTOS((cAlias)->&(cAlias + "_DTALT"))  == cChave

			If (cAlias)->&(cAlias + "_EVENTO") == 'A'
				nRecno := (cAlias)->(Recno())
			ElseIf (cAlias)->&(cAlias + "_EVENTO") == 'E'
				nRecno := 0
			endIf
			
			(cAlias)->(dbSkip())
		Enddo

		//Caso ele consiga posicionar no registro correto, re-ativa o evento para continuar o mesmo padrão de retificação/alteração
		If nRecno > 0
			(cAlias)->(dbGoto(nRecno))
			If RecLock(cAlias,.F.)
				(cAlias)->&(cAlias + "_ATIVO") := "1"
				(cAlias)->(MsUnlock())
				lReturn := .T.
			EndIf
		EndIf

	EndIf

Return lReturn
