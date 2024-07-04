#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA276.CH"
#INCLUDE "TOPCONN.CH"

Static 	lLaySimplif := taflayEsoc("S_01_00_00")


//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA276
Cadastro MVC de Alteração Contratual(S-2206) do eSocial

@author Felipe C. Seolin / Rodrigo Aguilar
@since 29/01/2014
@version 1.0

/*/
//---------------------------------------------------------------------
Function TAFA276()

	cMensagem := "Essa rotina está inativa a partir de uma chamada de menu" + Chr(13) + Chr(10) // #"Dicionário Incompatível"
	cMensagem += "Por favor atualize o menu do TAF e utilize a nova rotina do Cadastro do Trabalhador"

	Aviso( "Rotina indisponível", cMensagem, { "Encerrar" }, 3 ) // #"Encerrar"
	
Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Felipe C. Seolin / Rodrigo Aguilar
@since 29/01/2014
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
@since 29/01/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStruT1V := FwFormStruct( 1, "T1V" )
	Local oStruT3U := FwFormStruct( 1, "T3U" )
	Local oStruT79 := FwFormStruct( 1, "T79" )
	Local oStruT91 := FwFormStruct( 1, "T91" )
	Local oStruV91 := IIF( TAFAlsInDic("V91"), FwFormStruct( 1, "V91"), Nil)

	Local oModel   := MpFormModel():New( "TAFA276",,{ |oModel| TAF276Chv( oModel ) },{ |oModel| SaveModel( oModel ) } )

	If lLaySimplif
		oStruT1V:RemoveField("T1V_CODCGO")
		oStruT1V:RemoveField("T1V_DCODCG")
		oStruT1V:RemoveField("T1V_CODFUN")
		oStruT1V:RemoveField("T1V_DCODFU")
		oStruT1V:RemoveField("T1V_CODCAR")
		oStruT1V:RemoveField("T1V_DESCAR")
		oStruT1V:RemoveField("T1V_DTINGC")
		oStruT1V:RemoveField("T1V_NIS")
		oStruT1V:RemoveField("T1V_DTPJOR")
		oStruT1V:RemoveField("T1V_DESSVR")
	Else
		oStruT1V:RemoveField("T1V_CODTRE")
		oStruT1V:RemoveField("T1V_DSCTRE")
		oStruT1V:RemoveField("T1V_TERGPS")
		oStruT1V:RemoveField("T1V_ABOPER")
		oStruT1V:RemoveField("T1V_NMCARG")
		oStruT1V:RemoveField("T1V_CBOCAR")
		oStruT1V:RemoveField("T1V_NMFUNC")
		oStruT1V:RemoveField("T1V_CBOFUN")
		oStruT1V:RemoveField("T1V_ACCARG")
		oStruT1V:RemoveField("T1V_HRSNOT")
		oStruT1V:RemoveField("T1V_DSCJOR")
		oStruT1V:RemoveField("T1V_DSCSAL")
		oStruT1V:RemoveField("T1V_DCBOCG")
		oStruT1V:RemoveField("T1V_DCBOFC")
	EndIf

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruT1V:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT3U:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT79:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT91:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	EndIf

	oModel:AddFields( "MODEL_T1V",/*cOwner*/, oStruT1V )

	oModel:AddGrid( "MODEL_T3U", "MODEL_T1V", oStruT3U )
	oModel:GetModel( "MODEL_T3U" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_T3U" ):SetUniqueLine( { "T3U_CODDIA","T3U_CODHOR" } )
	oModel:GetModel( "MODEL_T3U" ):SetMaxLine(99)

	oModel:AddGrid( "MODEL_T79", "MODEL_T1V", oStruT79 )
	oModel:GetModel( "MODEL_T79" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_T79" ):SetUniqueLine( { "T79_CNPJSD" } )
	oModel:GetModel( "MODEL_T79" ):SetMaxLine(2)

	oModel:AddGrid( "MODEL_T91", "MODEL_T1V", oStruT91 )
	oModel:GetModel( "MODEL_T91" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_T91" ):SetUniqueLine( { "T91_CODOBS" } )
	oModel:GetModel( "MODEL_T91" ):SetMaxLine(99)

	If lLaySimplif .And. oStruV91 != Nil
		oModel:AddGrid( "MODEL_V91", "MODEL_T1V", oStruV91 )
		oModel:GetModel( "MODEL_V91" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V91" ):SetUniqueLine( { "V91_CODTRE" } )
		oModel:GetModel( "MODEL_V91" ):SetMaxLine(99)
	EndIf

	oModel:SetRelation( "MODEL_T3U",{ { "T3U_FILIAL", "xFilial('T3U')" }, { "T3U_ID", "T1V_ID" }, { "T3U_VERSAO", "T1V_VERSAO" } },T3U->( IndexKey( 1 ) ) )
	oModel:SetRelation( "MODEL_T79",{ { "T79_FILIAL", "xFilial('T79')" }, { "T79_ID", "T1V_ID" }, { "T79_VERSAO", "T1V_VERSAO" } },T79->( IndexKey( 1 ) ) )
	oModel:SetRelation( "MODEL_T91",{ { "T91_FILIAL", "xFilial('T91')" }, { "T91_ID", "T1V_ID" }, { "T91_VERSAO", "T1V_VERSAO" } },T91->( IndexKey( 1 ) ) )
	
	If lLaySimplif .AND. TAFAlsInDic( "V91" )
		oModel:SetRelation( "MODEL_V91",{ { "V91_FILIAL", "xFilial('V91')" }, { "V91_ID", "T1V_ID" }, { "V91_VERSAO", "T1V_VERSAO" } },V91->( IndexKey( 1 ) ) )
	EndIf
	
	oModel:GetModel("MODEL_T1V"):SetPrimaryKey( { "T1V_ID" }, { "T1V_VERSAO" } )

	oStruT1V:SetProperty( 'T1V_VLSLFX',MODEL_FIELD_OBRIGAT,.F.)

	If lLaySimplif
		oStruT1V:SetProperty( 'T1V_UNSLFX',MODEL_FIELD_OBRIGAT,.F.)
		oStruT1V:SetProperty( 'T1V_TPCONT',MODEL_FIELD_OBRIGAT,.F.)
	EndIf

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Felipe C. Seolin / Rodrigo Aguilar
@since 29/01/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local cGrpVinc1 	:= ""
	Local cGrpVinc2 	:= ""
	Local cGrpVinc3 	:= ""
	Local cGrpVinc4 	:= ""
	Local cGrpVinc5 	:= ""
	Local cGrpVinc6 	:= ""
	Local cGrpVinc7 	:= ""
	Local cGrpVinc8 	:= ""
	Local cGrpVinc9 	:= ""
	Local cGrpVinc10	:= ""
	Local cGrpVinc11	:= ""
	Local cGrpVinc12	:= ""
	Local cGrpVinc13	:= ""
	Local cGrpVinc14	:= ""
	Local cCmpTrans 	:= ""
	Local oModel    	:= FWLoadModel( "TAFA276" )
	Local oView     	:= FWFormView():New()
	Local oStruT1V		:= FwFormStruct( 2, "T1V" )
	Local oStruT1Va		:= Nil
	Local oStruT1Vb		:= Nil
	Local oStruT3U		:= FWFormStruct( 2, "T3U" )
	Local oStruT79		:= FWFormStruct( 2, "T79" )
	Local oStruT91		:= FWFormStruct( 2, "T91" )
	Local oStruV91		:= IIF( TAFAlsInDic("V91"), FwFormStruct( 2, "V91" ), Nil)

	Local nI     		:= 0
	Local aCmpGrp		:= {}

	
	// Tratamento para a simplificação do e-Social
	If lLaySimplif
		oStruT1V:RemoveField("T1V_CODCGO")
		oStruT1V:RemoveField("T1V_DCODCG")
		oStruT1V:RemoveField("T1V_CODFUN")
		oStruT1V:RemoveField("T1V_DCODFU")
		oStruT1V:RemoveField("T1V_CODCAR")
		oStruT1V:RemoveField("T1V_DESCAR")
		oStruT1V:RemoveField("T1V_DTINGC")
		oStruT1V:RemoveField("T1V_NIS")
		oStruT1V:RemoveField("T1V_DTPJOR")
		oStruT1V:RemoveField("T1V_DESSVR")
		oStruT1V:RemoveField("T1V_MTVALT")
	Else
		oStruT1V:RemoveField("T1V_CODTRE")
		oStruT1V:RemoveField("T1V_DSCTRE")
		oStruT1V:RemoveField("T1V_TERGPS")
		oStruT1V:RemoveField("T1V_ABOPER")
		oStruT1V:RemoveField("T1V_NMCARG")
		oStruT1V:RemoveField("T1V_CBOCAR")
		oStruT1V:RemoveField("T1V_NMFUNC")
		oStruT1V:RemoveField("T1V_CBOFUN")
		oStruT1V:RemoveField("T1V_ACCARG")
		oStruT1V:RemoveField("T1V_HRSNOT")
		oStruT1V:RemoveField("T1V_DSCJOR")
		oStruT1V:RemoveField("T1V_DSCSAL")
		oStruT1V:RemoveField("T1V_DCBOCG")
		oStruT1V:RemoveField("T1V_DCBOFC")
	EndIf

	If TafColumnPos("T1V_DTRANS")
		oStruT1V:RemoveField("T1V_DINSIS")
		oStruT1V:RemoveField("T1V_DTRANS")
		oStruT1V:RemoveField("T1V_HTRANS")
		oStruT1V:RemoveField("T1V_DTRECP")
		oStruT1V:RemoveField("T1V_HRRECP")
	EndIf

	If lLaySimplif .AND. TAFAlsInDic( "V91" )
    	oStruT1V:RemoveField("T1V_CODTRE") 
    	oStruT1V:RemoveField("T1V_DSCTRE")
	EndIf

	oView:SetModel( oModel )

	cGrpVinc2 	:= "T1V_TPREGP|"
	cGrpVinc3 	:= "T1V_TPREGJ|T1V_NATATV|T1V_DATAB|T1V_CNPJCP|"
	cGrpVinc4	:= "T1V_JUSTPR|"
	cGrpVinc5	:= "T1V_TPINAP|T1V_NRINAP|"

	If lLaySimplif
		cGrpVinc1	:= "T1V_ID|T1V_CPF|T1V_MATRIC|T1V_NOME|T1V_DTALT|T1V_DTEF|T1V_DESALT|"
		cGrpVinc6 	:= "T1V_TPLASM|T1V_TERGPS|T1V_ABOPER|"
		cGrpVinc7 	:= "T1V_NMCARG|T1V_CBOCAR|T1V_DCBOCG|T1V_NMFUNC|T1V_CBOFUN|T1V_DCBOFC|T1V_ACCARG|T1V_CODCAT|T1V_DCODCA|"
		cGrpVinc8 	:= "T1V_VLSLFX|T1V_UNSLFX|T1V_DSCSAL|"
		cGrpVinc12	:= "T1V_QTDHJS|T1V_TPJORN|T1V_TMPARC|T1V_HRSNOT|T1V_DSCJOR|"

		If !TAFAlsInDic( "V91" )
			cGrpVinc14	:= "T1V_CODTRE|T1V_DSCTRE|"
		EndIf
		
	Else
		cGrpVinc1	:= "T1V_ID|T1V_CPF|T1V_MATRIC|T1V_NOME|T1V_NIS|T1V_DTALT|T1V_DTEF|T1V_DESALT|"
		cGrpVinc6 	:= "T1V_TPLASM|"
		cGrpVinc7 	:= "T1V_CODCGO|T1V_DCODCG|T1V_CODFUN|T1V_DCODFU|T1V_CODCAT|T1V_DCODCA|T1V_CODCAR|T1V_DESCAR|T1V_DTINGC|"
		cGrpVinc8 	:= "T1V_VLSLFX|T1V_UNSLFX|T1V_DESSVR|"
		cGrpVinc12	:= "T1V_QTDHJS|T1V_TPJORN|T1V_DTPJOR|T1V_TMPARC|"
		cGrpVinc14	:= "T1V_MTVALT|"
	EndIf

	If (TafLayESoc("02_05_00") .OR. lLaySimplif) .And. TafColumnPos("T1V_OBJDET")
		cGrpVinc9 	:= "T1V_TPCONT|T1V_DTTERM|T1V_OBJDET|"
	Else
		cGrpVinc9 	:= "T1V_TPCONT|T1V_DTTERM|"
	EndIf

	cGrpVinc10	:= "T1V_TPINSC|T1V_NRINSC|T1V_DESLOT|"
	cGrpVinc11	:= "T1V_TPLOGD|T1V_DSCTPL|T1V_DELOGD|T1V_NRLOGD|T1V_COMLGD|T1V_BAIRTD|T1V_CEPLTD|T1V_CMUNTD|T1V_DSCMTD|T1V_UFTRBD|T1V_DUFTRD|"
	cGrpVinc13	:= "T1V_ALVJUD|T1V_DALVJU|"
	cCmpTrans	:= "T1V_PROTUL|

	oStruT1Va	:= FwFormStruct( 2, "T1V",{|x| AllTrim( x ) + "|" $ cCmpTrans } )
	If TafColumnPos("T1V_DTRANS")
		cCmpFil   := "T1V_DINSIS|T1V_DTRANS|T1V_HTRANS|T1V_DTRECP|T1V_HRRECP|"
		oStruT1Vb := FwFormStruct( 2, "T1V",{|x| AllTrim( x ) + "|" $ cCmpFil } ) //Campos do folder Info. Controle eSocial
	EndIf

	oStruT1V:AddGroup( "GRP_VINCULO_01", STR0014, "", 1 ) //"Identificação do Trabalhador"
	oStruT1V:AddGroup( "GRP_VINCULO_02", STR0019, "", 1 ) //"Informações do Trabalhador e do Vínculo"
	oStruT1V:AddGroup( "GRP_VINCULO_03", STR0031, "", 1 ) //"Informações de Trabalhador Celetista"
	oStruT1V:AddGroup( "GRP_VINCULO_04", STR0041, "", 1 ) //"Dados sobre Trabalho Temporário"
	oStruT1V:AddGroup( "GRP_VINCULO_05", STR0042, "", 1 ) //"Informações do Empregador Contratante de Aprendiz"
	oStruT1V:AddGroup( "GRP_VINCULO_06", STR0039, "", 1 ) //"Informações do Trabalhador Estatuario"
	oStruT1V:AddGroup( "GRP_VINCULO_07", STR0032, "", 1 ) //"Informações do Contrato de Trabalho"
	oStruT1V:AddGroup( "GRP_VINCULO_08", STR0016, "", 1 ) //"Remuneração"
	oStruT1V:AddGroup( "GRP_VINCULO_09", STR0015, "", 1 ) //"Duração"
	oStruT1V:AddGroup( "GRP_VINCULO_10", STR0018, "", 1 ) //"Informações do Local de Trabalho"
	oStruT1V:AddGroup( "GRP_VINCULO_11", STR0030, "", 1 ) //"Informações do Local de Trabalho Doméstico"
	oStruT1V:AddGroup( "GRP_VINCULO_12", STR0021, "", 1 ) //"Informações do Horário Contratual do Trabalhador"
	oStruT1V:AddGroup( "GRP_VINCULO_13", STR0034, "", 1 ) //"Informações do Alvará Judicial"
	
	If !lLaySimplif
		oStruT1V:AddGroup( "GRP_VINCULO_14", STR0040, "", 1 ) //"Alterações inerentes ao servidor público"
	Else
		oStruT1V:AddGroup( "GRP_VINCULO_14", STR0046, "", 1 ) //"Treinamentos, capacitações, exercícios simulados, autorizações ou outras anotações"
	EndIf

	aCmpGrp := StrToKarr( cGrpVinc1, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruT1V:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_VINCULO_01" )
	Next nI

	aCmpGrp := StrToKarr( cGrpVinc2, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruT1V:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_VINCULO_02" )
	Next nI

	aCmpGrp := StrToKarr( cGrpVinc3, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruT1V:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_VINCULO_03" )
	Next nI

	aCmpGrp := StrToKarr( cGrpVinc4, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruT1V:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_VINCULO_04" )
	Next nI

	aCmpGrp := StrToKarr( cGrpVinc5, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruT1V:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_VINCULO_05" )
	Next nI

	aCmpGrp := StrToKarr( cGrpVinc6, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruT1V:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_VINCULO_06" )
	Next nI

	aCmpGrp := StrToKarr( cGrpVinc7, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruT1V:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_VINCULO_07" )
	Next nI

	aCmpGrp := StrToKarr( cGrpVinc8, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruT1V:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_VINCULO_08" )
	Next nI

	aCmpGrp := StrToKarr( cGrpVinc9, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruT1V:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_VINCULO_09" )
	Next nI

	aCmpGrp := StrToKarr( cGrpVinc10, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruT1V:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_VINCULO_10" )
	Next nI

	aCmpGrp := StrToKarr( cGrpVinc11, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruT1V:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_VINCULO_11" )
	Next nI

	aCmpGrp := StrToKarr( cGrpVinc12, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruT1V:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_VINCULO_12" )
	Next nI

	aCmpGrp := StrToKarr( cGrpVinc13, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruT1V:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_VINCULO_13" )
	Next nI

	aCmpGrp := StrToKarr( cGrpVinc14, "|" )
	For nI := 1 to Len( aCmpGrp )
		oStruT1V:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_VINCULO_14" )
	Next nI

	If lLaySimplif
		oStruT1V:SetProperty( "T1V_NMCARG", MVC_VIEW_ORDEM, "19" )
		oStruT1V:SetProperty( "T1V_CBOCAR", MVC_VIEW_ORDEM, "20" )
		oStruT1V:SetProperty( "T1V_DCBOCG", MVC_VIEW_ORDEM, "21" )
		oStruT1V:SetProperty( "T1V_NMFUNC", MVC_VIEW_ORDEM, "22" )
		oStruT1V:SetProperty( "T1V_CBOFUN", MVC_VIEW_ORDEM, "23" )
		oStruT1V:SetProperty( "T1V_DCBOFC", MVC_VIEW_ORDEM, "24" )
		oStruT1V:SetProperty( "T1V_ACCARG", MVC_VIEW_ORDEM, "25" )
		oStruT1V:SetProperty( "T1V_CODCAT", MVC_VIEW_ORDEM, "26" )
		oStruT1V:SetProperty( "T1V_DCODCA", MVC_VIEW_ORDEM, "27" )
	EndIf

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruT1Va,"T1V")
	EndIf

	oView:AddField( "VIEW_T1V" , oStruT1V , "MODEL_T1V" )

	oView:AddField( "VIEW_T1Va", oStruT1Va, "MODEL_T1V" )
	If TafColumnPos("T1U_PROTUL")
		oView:EnableTitleView( 'VIEW_T1Va', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"
	EndIf
	If TafColumnPos("T1U_DTRANS")
		oView:AddField( "VIEW_T1Vb", oStruT1Vb, "MODEL_T1V" )		
		oView:EnableTitleView( 'VIEW_T1Vb', TafNmFolder("recibo",2) ) // "Recibo da última Transmissão"
	EndIf

	If !lLaySimplif
		oView:AddGrid	( "VIEW_T3U" , oStruT3U , "MODEL_T3U" )
		oView:AddGrid	( "VIEW_T79" , oStruT79 , "MODEL_T79" )
	Else
		IIF( oStruV91 != Nil, oView:AddGrid( "VIEW_V91" , oStruV91 , "MODEL_V91" ), Nil)
	EndIf	
	oView:AddGrid	( "VIEW_T91" , oStruT91 , "MODEL_T91" )

	oStruT91:RemoveField("T91_NOMEVE")
	oView:AddIncrementField( "VIEW_T91", "T91_CODOBS" )

	oView:CreateHorizontalBox( "PAINEL_PRINCIPAL", 100 )
	oView:CreateFolder( "FOLDER_PRINCIPAL", "PAINEL_PRINCIPAL" )

	oView:AddSheet( "FOLDER_PRINCIPAL", "ABA01", STR0019 ) //"Vínculo - Informações do Contrato "
	oView:CreateHorizontalBox( "T1V", 70, , , "FOLDER_PRINCIPAL" , "ABA01" )

	oView:CreateHorizontalBox( "GRIDS", 30, , , "FOLDER_PRINCIPAL", "ABA01" )
	oView:CreateFolder( "FOLDER_PRINCIPAL_VINCULO" , "GRIDS" )

	If !lLaySimplif
		oView:AddSheet( "FOLDER_PRINCIPAL_VINCULO", 'ABA02', STR0035 ) //"Informações Diárias do Horário Contratual"
		oView:CreateHorizontalBox( 'T3U', 100,,, "FOLDER_PRINCIPAL_VINCULO", 'ABA02' )

		oView:AddSheet( "FOLDER_PRINCIPAL_VINCULO", 'ABA03', STR0043 ) //"Filiação Sindical do Trabalhador"
		oView:CreateHorizontalBox( 'T79', 100,,, "FOLDER_PRINCIPAL_VINCULO", 'ABA03' )
	Else
		oView:AddSheet( "FOLDER_PRINCIPAL_VINCULO", 'ABA03', STR0046 ) //"Capacitação e Treinamentos"
		oView:CreateHorizontalBox( 'V91', 100,,, "FOLDER_PRINCIPAL_VINCULO", 'ABA03' )
	EndIf
	oView:AddSheet( "FOLDER_PRINCIPAL_VINCULO", 'ABA04', STR0044 ) //"Observações do Contrato de Trabalho"
	oView:CreateHorizontalBox( 'T91', 100,,, "FOLDER_PRINCIPAL_VINCULO", 'ABA04' )

	// Após a exibição da view, o NIS é atualizado S-2206
	If !lLaySimplif
		If FindFunction("TafNmFolder")
			oView:AddSheet( "FOLDER_PRINCIPAL", "ABA02", TafNmFolder("recibo"))
		Else
			oView:AddSheet( "FOLDER_PRINCIPAL", "ABA02", "Protocolo de Transmissão" ) //"Protocolo de Transmissão"
		Endif

		oView:SetAfterViewActivate( {|oView| GetUltNis( oView ) } )
		If TafColumnPos("T1U_DTRANS")
			oView:CreateHorizontalBox( "T1Va", 20, , , "FOLDER_PRINCIPAL" , "ABA02" )
			oView:CreateHorizontalBox( "T1Vb", 80, , , "FOLDER_PRINCIPAL" , "ABA02" )
		Else
			oView:CreateHorizontalBox( "T1Va", 100, , , "FOLDER_PRINCIPAL" , "ABA02" )
		EndIf
	Else
		oView:AddSheet( "FOLDER_PRINCIPAL", "ABA04", "Protocolo de Transmissão" )

		If TafColumnPos("T1U_DTRANS")
			oView:CreateHorizontalBox( "T1Va", 20, , , "FOLDER_PRINCIPAL" , "ABA04" )
			oView:CreateHorizontalBox( "T1Vb", 80, , , "FOLDER_PRINCIPAL" , "ABA04" )
		Else
			oView:CreateHorizontalBox( "T1Va", 100, , , "FOLDER_PRINCIPAL" , "ABA04" )
		EndIf
	Endif

	oView:SetOwnerView( "VIEW_T1V" , "T1V" )
	oView:SetOwnerView( "VIEW_T1Va", "T1Va")
	If TafColumnPos("T1U_DTRANS")
		oView:SetOwnerView( "VIEW_T1Vb", "T1Vb")
	EndIf
	If !lLaySimplif
		oView:SetOwnerView( "VIEW_T3U" , "T3U" )
		oView:SetOwnerView( "VIEW_T79" , "T79" )
	Else
		oView:SetOwnerView( "VIEW_V91" , "V91" )
	EndIf	
	oView:SetOwnerView( "VIEW_T91" , "T91" )

	xFunRmFStr( @oStruT1V, "T1V" )

	oStruT1V:RemoveField("T1V_STATUS")
	oStruT1V:RemoveField("T1V_PROTUL")

	If TafColumnPos( "T1V_LOGOPE" )
		oStruT1V:RemoveField( "T1V_LOGOPE" )
	EndIf

	oStruT3U:RemoveField("T3U_NOMEVE")

	// Auditoria LGPD
	IIf(FindFunction('FwPDLogUser'),FwPDLogUser('TAFA276'),Nil)

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetUltNis
Atualiza o model com o último NIS do funcionário, após a criação da view.

@Param oView -> Objeto da view

@Return Nil

@Author Leandro F. Dourado
@Since 08/03/2019
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetUltNis( oView )

	If oView:GetModel():GetOperation() <> MODEL_OPERATION_DELETE
		If IsInCallStack("TAFA421")
			FwFldPut("T1V_NIS",TAF250Nis( C9V->C9V_FILIAL, C9V->C9V_ID, C9V->C9V_NIS, IIF(!Empty(T1V->T1V_DTALT),Dtos(T1V->T1V_DTALT), "") ),,,,.T.)
		Else
			FwFldPut("T1V_NIS",TAF250Nis( T1V->T1V_FILIAL, T1V->T1V_ID, T1V->T1V_NIS, IIF(!Empty(T1V->T1V_DTALT),Dtos(T1V->T1V_DTALT), "") ),,,,.T.)
		EndIf
		oView:Refresh()
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param oModel -> Modelo de dados

@Return .T.

@Author Felipe C. Seolin / Rodrigo Aguilar
@Since 29/01/2014
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local cChvRegAnt	:= ""
	Local cLogOpeAnt	:= ""
	Local aGravaT1V		:= {}
	Local aGravaT3U 	:= {}
	Local aGravaT79 	:= {}
	Local aGravaT91 	:= {}
	Local aGravaV91 	:= {}

	Local nOperation	:= oModel:GetOperation()

	Local oModelT1V 	:= oModel:GetModel( "MODEL_T1V" )
	Local oModelT3U 	:= oModel:GetModel( "MODEL_T3U" )
	Local oModelT79 	:= oModel:GetModel( "MODEL_T79" )
	Local oModelT91 	:= oModel:GetModel( "MODEL_T91" )
	Local oModelV91 	:= oModel:GetModel( "MODEL_V91" )

	Local lRetorno	:= .T.

	Default oModel	:= Nil

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT

			TafAjustID( "T1V", oModel)

			oModel:LoadValue( "MODEL_T1V", "T1V_ID", C9V->C9V_ID)
			oModel:LoadValue( "MODEL_T1V", "T1V_VERSAO", xFunGetVer() )

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_T1V', 'T1V_LOGOPE' , '2', '' )
			Endif

			T1V->( DBSetOrder( 2 ) ) //T1V_FILIAL+T1V_ID+T1V_ATIVO+DTOS(T1V_DTALT)+DTOS(T1V_DTEF)
			If T1V->( MsSeek( xFilial( "T1V" ) + T1V->T1V_ID + "1" + DTOS(T1V->T1V_DTALT) + DTOS(T1V->T1V_DTEF) ) )
				If T1V->T1V_EVENTO == 'E' .And. T1V->T1V_STATUS == "7"
					FAltRegAnt( "T1V", "2" ) //Seto o registro corrente como Inativo

				ElseIf AllTrim(FwFldGet('T1V_EVENTO')) == "A"

					oModel:LoadValue( "MODEL_T1V", "T1V_VERANT", T1V->T1V_VERSAO )
					oModel:LoadValue( "MODEL_T1V", "T1V_PROTPN", T1V->T1V_PROTUL )

					FAltRegAnt( "T1V", "2" ) //Seto o registro corrente como Inativo
				EndIf
			EndIf

			//Gravo alteração para o Extemporâneo
			If lGoExtemp
				TafGrvExt( oModel, 'MODEL_T1V', 'T1V' )
			EndIf

			FwFormCommit( oModel )

			//Alteração ou exclusão Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_UPDATE

			T1V->( DBSetOrder( 1 ) ) //T1V_FILIAL+T1V_ID+T1V_ATIVO+DTOS(T1V_DTALT)+DTOS(T1V_DTEF)
			If T1V->( MsSeek( xFilial( "T1V" ) + M->T1V_ID + M->T1V_VERSAO + "1"  ) )

				//Verifica se o evento ja foi trasmitido ao RET
				If T1V->T1V_STATUS $ ( "4" )

					If TafColumnPos( "T1V_LOGOPE" )
						cLogOpeAnt := oModelT1V:GetValue( "T1V_LOGOPE" )
					endif

					//Função para carregar os valores correntes do cadastro
					TAF276Carr( oModelT1V, oModelT3U, oModelT79, oModelT91, @aGravaT1V, @aGravaT3U, @aGravaT79, @aGravaT91, oModelV91, @aGravaV91  )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seto o campo do registro anterior como Inativo             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FAltRegAnt( "T1V", "2" )

					//Esta função desativa o model corrente e inicia a operação de Inclusão das operações realizadas
					TAF276Comm( oModel, oModelT1V, oModelT3U, oModelT79, oModelT91, aGravaT1V, aGravaT3U, aGravaT79, aGravaT91,, oModelV91, @aGravaV91 )

					//Gravo alteração para o Extemporâneo
					If lGoExtemp
						TafGrvExt( oModel, 'MODEL_T1V', 'T1V' )
					EndIf

					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T1V', 'T1V_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					FwFormCommit( oModel )

				ElseIf T1V->T1V_STATUS == ( "2" )
					TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
					lRetorno := .F.
				ElseIf T1V->T1V_STATUS == ( "6" )
					TAFMsgVldOp(oModel,"6")//"Registro não pode ser alterado. Aguardando proc. Transm. evento de Exclusão S-3000"
					lRetorno := .F.
				Elseif T1V->T1V_STATUS == ( "7" )
					TAFMsgVldOp(oModel,"7")//"Registro não pode ser excluído, pois o evento de exclusão já se encontra base do RET"
					lRetorno := .F.
				Else
					If TafColumnPos( "T1V_LOGOPE" )
						cLogOpeAnt := T1V->T1V_LOGOPE
					endif

					//Gravo alteração para o Extemporâneo
					If lGoExtemp
						TafGrvExt( oModel, 'MODEL_T1V', 'T1V' )
					EndIf

					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T1V', 'T1V_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					FwFormCommit( oModel )
					TAFAltStat( 'T1V', " " )
				EndIf
			EndIf

		ElseIf nOperation == MODEL_OPERATION_DELETE

			cChvRegAnt := T1V->(T1V_ID + T1V_VERANT)

			If !Empty( cChvRegAnt )
				TAFAltStat( 'T1V', " " )
				FwFormCommit( oModel )
				If nOperation == MODEL_OPERATION_DELETE
					If T1V->T1V_EVENTO == "A" .Or. T1V->T1V_EVENTO == "E" .Or. !Empty(T1V->T1V_PROTPN)
						TAFRastro( 'T1V', 1, cChvRegAnt, .T.,,IIF(Type("oBrw") == "U", Nil, oBrw))
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
/*/{Protheus.doc} TAF276Carr
Função que armazena nos arrays as informações correntes do cadastro

@Param 

oModelT1V - Model da tabela T1V
oModelT3U - Model da tabela T3U
aGravaT1V - Array que armazena as informações da tabela T1V
aGravaT3U - Array que armazena as informações da tabela T3U
aGravaT79 - Array que armazena as informações da tabela T79
aGravaT91 - Array que armazena as informações da tabela T91

@Return .T.

@Author Rodrigo Aguilar
@Since 29/01/2014
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAF276Carr( oModelT1V, oModelT3U, oModelT79, oModelT91, aGravaT1V, aGravaT3U, aGravaT79, aGravaT91, oModelV91, aGravaV91 )

	Local nI := 0

	Default oModelT1V := Nil
	Default oModelT3U := Nil
	Default oModelT79 := Nil
	Default oModelT91 := Nil
	Default oModelV91 := Nil

	Default aGravaT1V := {}
	Default aGravaT3U := {}
	Default aGravaT79 := {}
	Default aGravaT91 := {}
	Default aGravaV91 := {}

	For nI := 1 to Len( oModelT1V:aDataModel[ 1 ] )
		Aadd( aGravaT1V, { oModelT1V:aDataModel[ 1, nI, 1 ], oModelT1V:aDataModel[ 1, nI, 2 ] } )
	Next nI

	For nI := 1 to oModelT3U:Length()
		oModelT3U:GoLine(nI)

		If !oModelT3U:IsDeleted()
			aAdd( aGravaT3U,{ oModelT3U:GetValue( "T3U_CODDIA" ),;
				oModelT3U:GetValue( "T3U_CODHOR" ) } )
		EndIf
	Next nI

	For nI := 1 to oModelT79:Length()
		oModelT79:GoLine(nI)

		If !oModelT79:IsDeleted()
			aAdd( aGravaT79,{ oModelT79:GetValue( "T79_CNPJSD" )} )
		EndIf
	Next nI

	For nI := 1 to oModelT91:Length()
		oModelT91:GoLine(nI)

		If !oModelT91:IsDeleted()
			aAdd( aGravaT91,{ oModelT91:GetValue( "T91_CODOBS" ),;
				oModelT91:GetValue( "T91_OBSERV")})

		EndIf
	Next nI

	If lLaySimplif .And. oModelV91 != Nil
		For nI := 1 to oModelV91:Length()
			oModelV91:GoLine(nI)
			If !oModelV91:IsDeleted()
				aAdd( aGravaV91,{ oModelV91:GetValue( "V91_CODTRE" )})
			EndIf
		Next nI
	EndIf

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF276Comm
Função que realiza a gravação das informações

@Param 

oModel    - Model que esta sendo editado
oModelT1V - Model da tabela T1V
oModelT3U - Model da tabela T3U
oModelT79 - Model da tabela T79
oModelT91 - Model da tabela T91

aGravaT1V - Array que armazena as informações da tabela T1V
aGravaT3U - Array que armazena as informações da tabela T3U
aGravaT79 - Array que armazena as informações da tabela T79
aGravaT91 - Array que armazena as informações da tabela T91

lFisrOpe  - Indica se a operação que esta sendo realizada se refere a uma inclusão, neste caso os campos
			 de controle de rastro não devem ser gravados 

@Return .T.

@Author Rodrigo Aguilar
@Since 29/01/2014
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAF276Comm( oModel, oModelT1V, oModelT3U, oModelT79, oModelT91, aGravaT1V, aGravaT3U, aGravaT79, aGravaT91, lExclu, oModelV91, aGravaV91)

	Local cVersao	:= ""
	Local cVerAnt	:= ""
	Local cProtocolo:= ""
	Local cEvento	:= ""
	Local cAliasPai := ""

	Local nI		:= 0

	Default oModel		:= Nil
	Default oModelT1V	:= Nil
	Default oModelT3U	:= Nil
	Default oModelT79	:= Nil
	Default oModelT91	:= Nil
	Default oModelV91	:= Nil

	Default aGravaT1V	:= {}
	Default aGravaT3U	:= {}
	Default aGravaT79	:= {}
	Default aGravaT91	:= {}
	Default aGravaV91	:= {}

	Default lExclu	:= .F.

	oModel:DeActivate()
	oModel:SetOperation( 3 )
	oModel:Activate()

	For nI := 1 to Len( aGravaT1V )
		oModel:LoadValue( "MODEL_T1V", aGravaT1V[ nI, 1 ], aGravaT1V[ nI, 2 ] )
	Next nI

	For nI := 1 to Len( aGravaT3U )
		If nI > 1
			oModelT3U:AddLine()
		EndIf
		oModel:LoadValue( "MODEL_T3U", "T3U_CODDIA" , aGravaT3U[nI][1] )
		oModel:LoadValue( "MODEL_T3U", "T3U_CODHOR" , aGravaT3U[nI][2] )
	Next nI

	For nI := 1 to Len( aGravaT79 )
		If nI > 1
			oModelT79:AddLine()
		EndIf
		oModel:LoadValue( "MODEL_T79", "T79_CNPJSD" , aGravaT79[nI][1] )
	Next nI

	For nI := 1 to Len( aGravaT91 )
		If nI > 1
			oModelT91:AddLine()
		EndIf
		oModel:LoadValue( "MODEL_T91", "T91_CODOBS" , aGravaT91[nI][1] )
		oModel:LoadValue( "MODEL_T91", "T91_OBSERV" , aGravaT91[nI][2] )
	Next nI

	If lLaySimplif .And. oModelV91 != Nil
		For nI := 1 to Len( aGravaV91 )
			If nI > 1
				oModelV91:AddLine()
			EndIf
			oModel:LoadValue( "MODEL_V91", "V91_CODTRE" , aGravaV91[nI][1] )
		Next nI
	EndIf

	cVersao := xFunGetVer()

	cVerAnt    := T1V->T1V_VERSAO
	cProtocolo := T1V->T1V_PROTUL
	cEvento    := T1V->T1V_EVENTO

	oModel:LoadValue( "MODEL_T1V", "T1V_VERSAO", cVersao )
	oModel:LoadValue( "MODEL_T1V", "T1V_VERANT", cVerAnt )
	oModel:LoadValue( "MODEL_T1V", "T1V_PROTPN", cProtocolo )
	oModel:LoadValue( "MODEL_T1V", "T1V_PROTUL", "" )
	oModel:LoadValue( "MODEL_T1V", "T1V_STATUS", "" )

	// Tratamento para limpar o ID unico do xml
	cAliasPai := "T1V"
	If TAFColumnPos( cAliasPai+"_XMLID" )
		oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
	EndIf

	IF lExclu
		oModel:LoadValue( "MODEL_T1V", "T1V_EVENTO", "E" )
		oModel:LoadValue( "MODEL_T1V", "T1V_ATIVO", "1" )
	Else
		If cEvento == "I"
			oModel:LoadValue( "MODEL_T1V", "T1V_EVENTO", "A" )
		EndIf
	Endif

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF276Grv

Funcao de gravacao para atender o registro S-2206

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

@author Felipe C. Seolin / Rodrigo Aguilar
@since 30/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF276Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID  )

	Local cCmpsNoUpd	:= "|T1V_FILIAL|T1V_ID|T1V_VERSAO|T1V_VERANT|T1V_PROTUL|T1V_PROTPN|T1V_EVENTO|T1V_STATUS|T1V_ATIVO|"
	Local cCabecTrab	:= "/eSocial/evtAltContratual/ideVinculo"
	Local cCabecVinc	:= IIf(!lLaySimplif,"/eSocial/evtAltContratual/altContratual","/eSocial/evtAltContratual/altContratual/vinculo")
	Local cCpf     		:= ""
	Local cMatric   	:= ""
	Local cChave   		:= ""
	Local cEnter    	:= Chr(13) + Chr(10)
	Local cMensagem 	:= ""
	Local cInconMsg 	:= ""
	Local cFilC9V		:= ""
	Local cIdEvtTrb 	:= ""
	Local cCodEvent		:= Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")
	Local cIdTransf  	:= ""
	Local cChaveOri		:= ""
	Local cFilOri		:= ""
	Local cLogOpeAnt	:= ""
	Local cCM6ChvOri	:= ""
	Local cCabecAltC    := IIf(lLaySimplif,"/eSocial/evtAltContratual/altContratual","")
	Local cV91Path   	:= ""

	Local nI			:= 0
	Local nJ    		:= 0
	Local nX    		:= 0
	Local nSeqErrGrv	:= 0
	Local nT3U     		:= 0
	Local nT79    		:= 0
	Local nT91     		:= 0
	Local nV91     		:= 0
	Local nTamModel		:= 0
	Local nLinha		:= 0
	Local nIndChv		:= 10

	Local lRet      	:= .F.
	Local lTransmit		:= .F.
	Local lDelLine 		:= .F.
	Local lEmpty   		:= .F.
	Local lAddline		:= .T.
	Local lTransf		:= .F.
	Local lCUPLimpAf	:= .F.

	Local aIncons  		:= {}
	Local aRulesCad 	:= {}
	Local aRulesVin 	:= {}
	Local aChave    	:= {}
	Local aChaveC9V 	:= {}
	Local aAreaC9V 		:= {}
	Local aChaveOri  	:= {}
	Local aAreaAux		:= {}
	Local aCodFils		:= {}
	Local cCpfXml		:= ()
	local dDataAlt      := CTOD("  /  /    ")

	Local oModel   	:= Nil

	Private lVldModel	:= .T.
	Private oDados   	:= Nil

	Default cLayout  	:= "2206"
	Default nOpc     	:= 1
	Default cFilEv   	:= ""
	Default oXML     	:= Nil
	Default cOwner  	:= ""
	Default cFilTran	:= ""
	Default cPredeces	:=	""
	Default nTafRecno	:=	0
	Default cComplem	:=	""
	Default cGrpTran	:=	""
	Default cEmpOriGrp	:=	""
	Default cFilOriGrp	:=	""
	Default cXmlID		:=	""


	If !TafVldAmb("2")
		cMensagem := STR0037 + cEnter // #"Dicionário Incompatível"
		cMensagem += TafAmbInvMsg()

		Aadd(aIncons, cMensagem)

	Else

		oDados := oXML

		If nOpc == 3
			cTagOper := "/inclusao"
		ElseIf nOpc == 4
			cTagOper := "/alteracao"
		ElseIf nOpc == 5
			cTagOper := "/exclusao"
		EndIf

		//Verifico se a integração é fruto de uma transferencia
		If !Empty(cFilTran) .And. TAFColumnPos( "C9V_IDTRAN" )
			cFilOri := FTafGetFil( cFilTran , @aIncons , "C9V" )

			//Indica se é um funcionario vindo de uma transferencia.
			If !Empty(cFilOri) .OR. (Len(cFilOri) == GetSX3Cache("C9V_FILIAL", "X3_TAMANHO") .AND. FWModeAccess("C9V") == "C")
				lTransf := .T.
			Else
				Aadd( aIncons, "Não foi encontrada no TAF uma filial de transferência correspondente a filial original enviada no registro.")
				lAltPend := .T.
			EndIf

		EndIf

		cCpf    := FTafGetVal( cCabecTrab + "/cpfTrab"  , 'C', .F., @aIncons, .F., '', '' )
		cMatric := FTafGetVal( cCabecTrab + "/matricula", 'C', .F., @aIncons, .F., '', '' )

		If !lLaySimplif
			dDataAlt := FTafGetVal( cCabecVinc + "/dtAlteracao", 'D', .F., @aIncons, .F., '', '' )
		Else
			dDataAlt := FTafGetVal( cCabecAltC + "/dtAlteracao", 'D', .F., @aIncons, .F., '', '' )
		EndIf

		//Chave do Registro
		aAdd( aChave, { "C", "T1V_CPF"   , cCpf, .T. } )
		aAdd( aChave, { "C", "T1V_MATRIC", cMatric, .T. } )

		If !lLaySimplif
			Aadd( aChave, { "D", "T1V_DTALT" , FTafGetVal( cCabecVinc + "/dtAlteracao", 'D', .F., @aIncons, .F., '', '' ), .T.} )
			Aadd( aChave, { "D", "T1V_DTEF"  , FTafGetVal( cCabecVinc + "/dtEf", 'D', .F., @aIncons, .F., '', '' ), .T.} )
		Else
			Aadd( aChave, { "D", "T1V_DTALT" , FTafGetVal( cCabecAltC + "/dtAlteracao", 'D', .F., @aIncons, .F., '', '' ), .T.} )
			Aadd( aChave, { "D", "T1V_DTEF"  , FTafGetVal( cCabecAltC + "/dtEf", 'D', .F., @aIncons, .F., '', '' ), .T.} )
		EndIF

		cChave	:= Padr( aChave[ 1, 3 ], Tamsx3( aChave[ 1, 2 ])[1] ) + Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1] ) + DTOS( aChave[ 3, 3 ]) + DTOS( aChave[ 4, 3 ])

		//Verifica se o evento ja existe na base
		dbSelectArea("T1V")
		("T1V")->( DbSetOrder( 3 ) )
		If ("T1V")->( MsSeek( FTafGetFil( cFilEv , @aIncons , "T1V" ) + cChave + '1') )
			nOpc := 4
			lTransmit := IIF(T1V->T1V_STATUS == '4',.T.,.F.)
		ElseIf ("T1V")->( MsSeek(FTafGetFil( cFilEv , @aIncons , "T1V" ) + cChave + '2' ) )
			If RetIna06('T1V',cChave, 3)
				nOpc := 4
				lTransmit 	:= IIF(T1V->T1V_STATUS == '4',.T.,.F.)
			EndIf
		EndIf

		aAreaC9V:= ( "C9V" )->( GetArea() )
		dbSelectArea("C9V")

		//C9V_FILIAL+C9V_CPF+C9V_MATRIC+C9V_NOMEVE+C9V_ATIVO
		C9V->( DbSetOrder( nIndChv ) )

		cFilC9V := FTafGetFil( cFilEv , @aIncons , "C9V" )
		aAdd( aChaveC9V, { cLayout , cFilC9V, Padr(cCpf, TamSX3("C9V_CPF")[1]) , Padr(cMatric, TamSX3("C9V_MATRIC")[1]) , "" , "S2200" + '1'} ) //alterar2200

		If lTransf
			aAdd( aChaveOri, { cLayout , cFilOri, Padr(cCpf, TamSX3("C9V_CPF")[1]) , Padr(cMatric, TamSX3("C9V_MATRIC")[1]) , "" , "S2200" + '1'} ) //alterar2200
		Endif

		cCpfXml := aChaveC9V[ 1, 3 ] //Obtendo o CPF do XML Importado

		If !(C9V->( MsSeek( aChaveC9V[ 1, 2 ] + aChaveC9V[ 1, 3 ] + aChaveC9V[ 1, 4 ] + aChaveC9V[ 1, 5 ] )) .or.;
				C9V->( MsSeek( aChaveC9V[ 1, 2 ] + aChaveC9V[ 1, 3 ] + aChaveC9V[ 1, 4 ] + aChaveC9V[ 1, 6 ] )))

			If !lTransf
				Aadd( aIncons, "000010")	//'Para a integração dos eventos de alteração S-2205 (Alteração de Dados Cadastrais do Trabalhador) ou
				//S-2206 (Alteração de Contrato de Trabalho), é necessário que exista o evento S-2200 (Admissão de Trabalhador)
				//correspondente ao evento de alteração do trabalhador.'
			ElseIf  !(C9V->( MsSeek( aChaveOri[ 1, 2 ] + aChaveOri[ 1, 3 ] + aChaveOri[ 1, 4 ] + aChaveOri[ 1, 6 ] )))
				Aadd( aIncons, "O evento original correspondente a este Trabalhador não existe. Não será possível a integração do evento de transferência.")
			ElseIf C9V->C9V_STATUS <> '4'
				Aadd( aIncons, "O evento original correspondente a este Trabalhador não foi transmitido. Não será possível a integração do evento de transferência.")
			Else
				cChaveOri := aChaveOri[ 1, 2 ] + aChaveOri[ 1, 3 ] + aChaveOri[ 1, 4 ] + aChaveOri[ 1, 6 ]
			EndIf

			If lTransf
				//---------------------------------------------------------------------------------------------------
				// Avalia se o trabalhador tem afastamento pendente de transmissão, impossibilitando a transferência
				//---------------------------------------------------------------------------------------------------
				C9V->( MsSeek( aChaveOri[ 1, 2 ] + aChaveOri[ 1, 3 ] + aChaveOri[ 1, 4 ] + aChaveOri[ 1, 6 ] ))
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

					//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					// Caso tenha localizado evento de afastamento (CM6), os campos CUP_DTINIA e CUP_MOTVAF devem ser limpos na filial de destino, para possibilitar a inclusão de um inicio de afastamento
					//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					lCUPLimpAf := .T.

				EndIf
				RestArea(aAreaAux)
			EndIf

		Else
			IF TAFColumnPos( "C9V_IDTRAN" )
				IF C9V->C9V_IDTRAN<>'' .AND. C9V_ATIVO=='2' .AND. lTransf
					cChaveOri := aChaveOri[ 1, 2 ] + aChaveOri[ 1, 3 ] + aChaveOri[ 1, 4 ] + aChaveOri[ 1, 6 ]
				ENDIF
			ENDIF
			If C9V->C9V_STATUS == "3"
				Aadd( aIncons, "000012") 	//'O evento de alteração do trabalhador integrado, S-2205 (Alteração de Dados Cadastrais do Trabalhador)
				//ou S-2206 (Alteração de Contrato de Trabalho), possui um evento pai S-2200 (Admissão de Trabalhador)
				//com inconsistência ou não validado pelo RET.'

			Elseif C9V->C9V_STATUS <> '4'
				Aadd( aIncons, "000024") 	//'O evento de alteração do trabalhador integrado, S-2205 (Alteração de Dados Cadastrais do Trabalhador)
				//ou S-2206 (Alteração de Contrato de Trabalho), S-2200 (Admissão de Trabalhador) com inconsistência ou
				//não validado pelo RET.'
			EndIf

		EndIf

		If lTransf

			aCodFils :=	TAFCodFilErp()

			If (aScan(aCodFils,{|cFil|AllTrim(cFil) == AllTrim(cFilTran)})) > 0

				//Posicione("C9V",3,xFilial("C9V")+cCpfXml+"1","C9V_ID")
				cIdTransf := C9V->C9V_ID
			Else

				//------------------------------------------------------------------------------------------------------
				// Obtem o ID da C9V que será utilizado na T1V. Feito desta forma para nao gerar chave duplicada na C9V
				// e manter a funcionalidade dos locais onde o ID da C9V x T1V devem ser o mesmo (ex. Historico), porém
				// as tabelas deveriam ter seu ID independente e se relacionarem por chave de negocio (ex. CPF)
				//------------------------------------------------------------------------------------------------------
				cIdTransf := GetSx8Num("C9V","C9V_ID")

				//------------------------------------------------------------------------
				// Avalia se o ID obtido já está em uso (problema no ambiente do cliente)
				//------------------------------------------------------------------------
				If !TAFCheckID(cIdTransf,"C9V")
					RollBackSX8()
					AAdd(aIncons,STR0045) //"Controle de numeracao da tabela C9V incorreto. Necessário ajuste por meio do programa APCFG110 no módulo configurador."
				EndIf
			EndIf

		Else
			cIdEvtTrb := C9V->C9V_ID
		EndIf

		RestArea( aAreaC9V )

		Begin Transaction

			//Funcao para validar se a operacao desejada pode ser realizada
			If Empty(aIncons) .And. FTafVldOpe( "T1V", 3, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA276", cCmpsNoUpd )

				T1V->( DBSetOrder( 2 ) )
				If T1V->( MsSeek( xFilial( "T1V" ) + cIdEvtTrb + "1" + DTOS( aChave[ 3, 3 ]) + DTOS( aChave[ 4, 3 ])) )

					If T1V->T1V_STATUS == "4" .AND. !Empty(T1V->T1V_PROTUL)
						oModel:LoadValue( "MODEL_T1V", "T1V_VERANT", T1V->T1V_VERSAO )
						oModel:LoadValue( "MODEL_T1V", "T1V_PROTPN", T1V->T1V_PROTUL )

						FAltRegAnt( "T1V", "2" ) //Seto o registro corrente como Inativo
					EndIf
				EndIf

				If TafColumnPos( "T1V_LOGOPE" )
					cLogOpeAnt := T1V->T1V_LOGOPE
				endif


				//Carrego array com os campos De/Para de gravacao das informacoes ( Cadastrais )
				aRulesCad := FRulCad( cCabecTrab, cLayout, "T1V", cCabecVinc, @cInconMsg, @nSeqErrGrv, lTransmit, oModel, aChaveC9V, aIncons, cCodEvent, cOwner, aChaveOri )

				//Carrego array com os campos De/Para de gravacao das informacoes ( Vínculo )
				aRulesVin := FRulVinc( cCabecVinc, cLayout, "T1V", @cInconMsg, @nSeqErrGrv, lTransmit, oModel, cCodEvent, cOwner )

				//Quando se tratar de uma Exclusao direta apenas preciso realizar
				//o Commit(), nao eh necessaria nenhuma manutencao nas informacoes
				If nOpc <> 5

					oModel:LoadValue( "MODEL_T1V", "T1V_FILIAL", xFilial("T1V"))

					If FindFunction( "EvtExtemp" )
						If EvtExtemp("T1V",dDataAlt,cIdEvtTrb)
							oModel:LoadValue("MODEL_T1V", "T1V_STASEC", 'E')
						EndIf
					endIf

					If TAFColumnPos( "T1V_XMLID" )
						oModel:LoadValue( "MODEL_T1V", "T1V_XMLID", cXmlID )
					EndIf

					//Carrego o ID com o ID do evento do trabalhador (S2200).
					If lTransf
						oModel:LoadValue( "MODEL_T1V", "T1V_ID", cIdTransf )
					Else
						oModel:LoadValue( "MODEL_T1V", "T1V_ID", cIdEvtTrb )
					EndIf

					//Rodo o aRulesCad para gravar as informacoes
					For nI := 1 to Len( aRulesCad )
						oModel:LoadValue( "MODEL_T1V", aRulesCad[ nI, 01 ], FTafGetVal( aRulesCad[ nI, 02 ], aRulesCad[nI, 03], aRulesCad[nI, 04], @aIncons, .F. ) )
					Next nI

					For nI := 1 to Len( aRulesVin )

						If aRulesVin[ nI, 01 ] == 'T1V_OBJDET'
							oModel:LoadValue( "MODEL_T1V", aRulesVin[ nI, 01 ], SubStr(AllTrim(FTafGetVal( aRulesVin[ nI, 02 ], aRulesVin[nI, 03], aRulesVin[nI, 04], @aIncons, .F. )),1,TamSX3('T1V_OBJDET')[1]) )
						ElseIf lLaySimplif .AND. aRulesVin[ nI, 01 ] $ 'T1V_CODTRE|T1V_CBOCAR|T1V_CBOFUN'
						 	oModel:LoadValue( "MODEL_T1V", aRulesVin[ nI, 01 ], aRulesVin[ nI, 02 ] )
						Else
							oModel:LoadValue( "MODEL_T1V", aRulesVin[ nI, 01 ], FTafGetVal( aRulesVin[ nI, 02 ], aRulesVin[nI, 03], aRulesVin[nI, 04], @aIncons, .F. ) )
						EndIf
					Next nI

					If Findfunction("TAFAltMan")
						if nOpc == 3
							TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T1V', 'T1V_LOGOPE' , '1', '' )
						elseif nOpc == 4
							TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T1V', 'T1V_LOGOPE' , '', cLogOpeAnt )
						EndIf
					EndIf

					//***********
					//Hora Contratual
					//***********
					cT3UPath := cCabecVinc + "/infoContrato/horContratual/horario"

					//Recebo o tamanho do modelo
					nTamModel 	:= oModel:GetModel( "MODEL_T3U" ):Length()
					lAddLine 	:= .T.

					//Quando se trata de uma alteracao, deleto todas as linhas do Grid ( Hora Contratual )
					If nOpc == 4 .AND. TafXNode( oDados, cCodEvent, cOwner, (cT3UPath + "[1]/dia"), cT3UPath + "/dia" ) .AND. ;
							TafXNode( oDados, cCodEvent, cOwner, (cT3UPath + "[1]/codHorContrat"), cT3UPath + "/codHorContrat" )

						For nJ := 1 to nTamModel
							oModel:GetModel( "MODEL_T3U" ):GoLine(nJ)
							oModel:GetModel( "MODEL_T3U" ):DeleteLine()
						Next nJ
					Else
						lAddLine := .F.
					EndIf

					If !lLaySimplif
						//Rodo o XML parseado para gravar as novas informacoes no GRID ( Hora Contratual )
						nT3U	:= 1
						While oDados:XPathHasNode( cCabecVinc + "/infoContrato/horContratual/horario[" + cValToChar(nT3U)+ "]" ) .OR. ( nT3U <= nTamModel .AND. !lAddLine )

							If ( nOpc == 3 .And. nT3U > 1 .And. oDados:XPathHasNode( cT3UPath + "[" + cValToChar(nT3U)+ "]" ) ) .OR. ( oDados:XPathHasNode( cT3UPath + "[" + cValToChar(nT3U)+ "]" ) .And. lAddLine )
								oModel:GetModel( "MODEL_T3U" ):lValid:= .T.
								oModel:GetModel( "MODEL_T3U" ):AddLine()

							EndIf

							If TafXNode( oDados, cCodEvent, cOwner, (cT3UPath + "[" + cValToChar(nT3U) + "]/dia"), cT3UPath + "/dia" )
								oModel:LoadValue( "MODEL_T3U", "T3U_CODDIA", FTafGetVal( cCabecVinc + "/infoContrato/horContratual/horario[" + cValToChar(nT3U) + "]/dia", "C", .F., @aIncons, .F., '', '',, @lEmpty ) )
								lDelLine := Iif(lEmpty,.T.,lDelLine)
							EndIf

							If TafXNode( oDados, cCodEvent, cOwner, (cT3UPath + "[" + cValToChar(nT3U) + "]/codHorContrat"), cT3UPath + "/codHorContrat" ) .AND. !lDelLine
								oModel:LoadValue( "MODEL_T3U", "T3U_CODHOR" , FGetIdInt( "codHorContrat", "", cCabecVinc + "/infoContrato/horContratual/horario[" + cValToChar(nT3U) + "]/codHorContrat",,,,@cInconMsg, @nSeqErrGrv,,, @lEmpty ) )
								lDelLine := Iif(lEmpty,.T.,lDelLine)
							EndIf

							//Deleto a linha do modelo caso um campo chave seja excluído
							If lDelLine

								nLinha := Iif(!lAddLine, nT3U, nTamModel+nT3U)

								oModel:GetModel( 'MODEL_T3U' ):GoLine(nLinha)
								oModel:GetModel( 'MODEL_T3U' ):DeleteLine()

								lDelLine := .F.

							EndIf

							nT3U++
						EndDo
						//---------
					
					
						//***********
						//Checando filiação sindical
						//***********
						cT79Path := cCabecVinc + "/infoContrato/filiacaoSindical"

						//Recebo o tamanho do modelo
						nTamModel	:= oModel:GetModel( "MODEL_T79" ):Length()
						lAddLine 	:= .T.

						//Quando se trata de uma alteracao, deleto todas as linhas do Grid ( Filiação Sindical)
						If nOpc == 4 .AND. TafXNode( oDados, cCodEvent, cOwner, ( cT79Path + "[1]/cnpjSindTrab"), cT79Path + "/cnpjSindTrab" )
							For nJ := 1 to nTamModel
								oModel:GetModel( "MODEL_T79" ):GoLine(nJ)
								oModel:GetModel( "MODEL_T79" ):DeleteLine()
							Next nJ
						Else
							lAddLine := .F.
						EndIf

						//Rodo o XML parseado para gravar as novas informacoes no GRID ( Trabalhador Substituido )
						nT79	:= 1
						While oDados:XPathHasNode( cT79Path +"[" + cValToChar(nT79)+ "]" ) .OR. ( nT79 <= nTamModel .AND. !lAddLine )

							If ( nOpc == 3 .And. nT79 > 1 .And. oDados:XPathHasNode( cT79Path + "[" + cValToChar(nT79) + "]" ) ) .OR. ( oDados:XPathHasNode( cT79Path + "[" + cValToChar(nT79) + "]" ) .And. lAddLine )

								oModel:GetModel( "MODEL_T79" ):lValid:= .T.
								oModel:GetModel( "MODEL_T79" ):AddLine()

							EndIf

							If TafXNode( oDados, cCodEvent, cOwner, ( cT79Path + "[" + cValToChar(nT79) + "]/cnpjSindTrab"), cT79Path + "/cnpjSindTrab" )
								oModel:LoadValue( "MODEL_T79", "T79_CNPJSD", FTafGetVal( cT79Path + "[" + cValToChar(nT79) + "]/cnpjSindTrab", "C", .F., @aIncons, .F., '', '',, @lEmpty ) )
								lDelLine := Iif(lEmpty,.T.,lDelLine)
							EndIf

							//Deleto a linha do modelo caso um campo chave seja excluído
							If lDelLine

								nLinha := Iif(!lAddLine, nT79, nTamModel+nT79)

								oModel:GetModel( 'MODEL_T79' ):GoLine(nLinha)
								oModel:GetModel( 'MODEL_T79' ):DeleteLine()

								lDelLine := .F.

							EndIf

							nT79++
						EndDo
					EndIf
				EndIf

				If lLaySimplif .And. TAFAlsInDic("V91")
					//***********************************
					//Capacitação e Treinamentos
					//***********************************
					cV91Path := cCabecVinc + "/infoContrato/treiCap"

					//Recebo o tamanho do modelo
					nTamModel 	:= oModel:GetModel( "MODEL_V91" ):Length()
					lAddLine 	:= .T.

					//Quando se trata de uma alteracao, deleto todas as linhas do Grid ( Observações do contrato de trabalho )
					If nOpc == 4 .and. TafXNode( oDados, cCodEvent, cOwner, (cV91Path + "[1]/codTreiCap" ), cV91Path + "/codTreiCap" )
						For nX := 1 to nTamModel
							oModel:GetModel( "MODEL_V91" ):GoLine(nX)
							oModel:GetModel( "MODEL_V91" ):DeleteLine()
						Next nX
					Else
						lAddLine := .F.
					EndIf

					//Rodo o XML parseado para gravar as novas informacoes no GRID ( Observações do contrato de trabalho )
					nV91  	:= 1
					While oDados:XPathHasNode( cV91Path + "[" + cValToChar(nV91)+ "]" ) .OR. ( nV91 <= nTamModel .AND. !lAddLine )

						If ( nOpc == 3 .And. nV91 > 1 .And. oDados:XPathHasNode( cV91Path + "[" + cValToChar(nV91) + "]" ) ) .OR. ( oDados:XPathHasNode( cV91Path + "[" + cValToChar(nV91) + "]" ) .And. lAddLine )					
							oModel:GetModel( "MODEL_V91" ):lValid:= .T.
							oModel:GetModel( "MODEL_V91" ):AddLine()						
						EndIf

						If TafXNode( oDados, cCodEvent, cOwner, (cV91Path +"[" + cValToChar(nV91) + "]/codTreiCap" ), cV91Path + "/codTreiCap" )
							oModel:LoadValue( "MODEL_V91", "V91_CODTRE", FGetIdInt( "codTreiCap", "", cV91Path +"[" + cValToChar(nV91) + "]/codTreiCap",,,,@cInconMsg, @nSeqErrGrv,,, @lEmpty) )
							lDelLine := Iif(lEmpty,.T.,lDelLine)
						EndIf

						//Deleto a linha do modelo caso um campo chave seja excluído
						If lDelLine							
							nLinha := Iif(!lAddLine, nV91, nTamModel+nV91)	

							oModel:GetModel( 'MODEL_V91' ):GoLine(nLinha) 
							oModel:GetModel( 'MODEL_V91' ):DeleteLine()							
							lDelLine := .F.						
						EndIf					
							
						nV91++
					EndDo

				EndIf
				//***********************************
				//Observações do contrato de trabalho
				//***********************************
				cT91Path := cCabecVinc + "/infoContrato/observacoes"

				//Recebo o tamanho do modelo
				nTamModel 	:= oModel:GetModel( "MODEL_T91" ):Length()
				lAddLine 	:= .T.

				//Quando se trata de uma alteracao, deleto todas as linhas do Grid ( Observações do contrato de trabalho )
				If nOpc == 4 .and. TafXNode( oDados, cCodEvent, cOwner, (cT91Path + "[1]/observacao" ), cT91Path + "/observacao" )
					For nX := 1 to nTamModel
						oModel:GetModel( "MODEL_T91" ):GoLine(nX)
						oModel:GetModel( "MODEL_T91" ):DeleteLine()
					Next nX
				Else
					lAddLine := .F.
				EndIf

				//Rodo o XML parseado para gravar as novas informacoes no GRID ( Observações do contrato de trabalho )
				nT91  	:= 1
				While oDados:XPathHasNode( cT91Path + "[" + cValToChar(nT91)+ "]" ) .OR. ( nT91 <= nTamModel .AND. !lAddLine )

					If ( nOpc == 3 .And. nT91 > 1 .And. oDados:XPathHasNode( cT91Path + "[" + cValToChar(nT91) + "]" ) ) .OR. ( oDados:XPathHasNode( cT91Path + "[" + cValToChar(nT91) + "]" ) .And. lAddLine )

						oModel:GetModel( "MODEL_T91" ):lValid:= .T.
						oModel:GetModel( "MODEL_T91" ):AddLine()

					EndIf

					If TafXNode( oDados, cCodEvent, cOwner, (cT91Path +"[" + cValToChar(nT91) + "]/observacao" ), cT91Path + "/observacao" )
						oModel:LoadValue( "MODEL_T91", "T91_CODOBS", StrZero(nT91,6) )
						oModel:LoadValue( "MODEL_T91", "T91_OBSERV", FTafGetVal( cCabecVinc + "/infoContrato/observacoes[" + cValToChar(nT91) + "]/observacao", "C", .F., @aIncons, .F., '', '',, @lEmpty ) )
						lDelLine := Iif(lEmpty,.T.,lDelLine)
					EndIf

					//Deleto a linha do modelo caso um campo chave seja excluído
					If lDelLine

						nLinha := Iif(!lAddLine, nT91, nTamModel+nT91)

						oModel:GetModel( 'MODEL_T91' ):GoLine(nLinha)
						oModel:GetModel( 'MODEL_T91' ):DeleteLine()

						lDelLine := .F.

					EndIf

					nT91++
				EndDo

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Efetiva a operacao desejada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Empty(cInconMsg) .And. Empty(aIncons)
					If TafFormCommit( oModel )
						Aadd(aIncons, "ERRO19")
					Else
						lRet  := .T.
					EndIf
				Else
					Aadd (aIncons, cInconMsg)
					DisarmTransaction()
				EndIf

				//Inativa o evento original e copia os dados do Trabalhador na filial destino
				If lRet .And. lTransf .And. !Empty(cChaveOri)
					xTafTransf( cChaveOri, nIndChv, cIdTransf, cFilOri, cFilC9V, aChaveC9V, , , lCUPLimpAf )
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

		aSize( aRulesVin, 0 )
		aRulesVin := Nil

		aSize( aChave, 0 )
		aChave := Nil

		oModel := Nil

	Endif

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF276Xml
Funcao de geracao do XML para atender o registro S-2206.
Quando a rotina for chamada o registro deve estar posicionado.

@Param:
cAlias  - Alias da Tabela
nRecno  - Recno do Registro corrente
nOpc    - Operacao a ser realizada
lJob    - Informa se foi chamado por Job

@Return:
cXml - Estrutura do Xml do Layout S-2206

@author Felipe C. Seolin / Rodrigo Aguilar
@since 29/01/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF276Xml( cAlias, nRecno, nOpc, lJob )

	Local cXml    		:= ""
	Local cReg			:= "AltContratual"
	Local cLayout		:= "2206"
	Local cAliasHora	:= "T3U"
	Local cAliasSind	:= "T79"
	Local cAliasObs		:= "T91"
	Local cAliasCap	 	:= "V91"
	Local aAreaC9V		:= C9V->(GetArea())

	Local cIDC9V := ""

	Default nRecno:= 0
	Default nOpc	:= 0
	Default lJob	:= .F.


	If cAlias == "T1V" .And. nRecno > 0
		T1V->(DbGoto( nRecno ) )
		cIDC9V   := T1V->T1V_ID

		C9V->(DbSetOrder(3))
		C9V->(DbSeek( T1V->T1V_FILIAL + T1V->T1V_CPF + '1' ))

		cXml += FGetVinc( cLayout, "T1V", cAliasHora, cAliasSind, cAliasObs, cIDC9V, cAliasCap )
		cXml := xTafCabXml( cXml, "T1V", cLayout, cReg )

		If !lJob
			xTafGerXml( cXml, cLayout )
		EndIf
	Endif

	RestArea(aAreaC9V)

Return( cXml )

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
Static Function GerarEvtExc( oModel, nRecno, lRotExc  )

	Local aGravaT1V 	:= {}
	Local aGravaT3U 	:= {}
	Local aGravaT79 	:= {}
	Local aGravaT91 	:= {}
	Local aGravaV91 	:= {}

	Local oModelT1V 	:= Nil
	Local oModelT3U 	:= Nil
	Local oModelT79 	:= Nil
	Local oModelT91 	:= Nil
	Local oModelV91 	:= Nil

	Default oModel	:= Nil
	Default nRecno	:= 1
	Default lRotExc	:= .F.

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		//Posiciona o item
		T1V->( dbGoTo(nRecno) )

		//Carrego a Estrutura dos Models a serem gravados
		oModelT1V := oModel:GetModel( "MODEL_T1V" )
		oModelT3U := oModel:GetModel( "MODEL_T3U" )
		oModelT79 := oModel:GetModel( "MODEL_T79" )
		oModelT91 := oModel:GetModel( "MODEL_T91" )
		
		If lLaySimplif 
			oModelV91 := oModel:GetModel( "MODEL_V91" )
		EndIf

		//Função para carregar os valores correntes do cadastro
		TAF276Carr( oModelT1V, oModelT3U, oModelT79, oModelT91, @aGravaT1V, @aGravaT3U, @aGravaT79, @aGravaT91, oModelV91, @aGravaV91 )

		//Seto o Registro corrente como Inativo
		FAltRegAnt( "T1V", "2" )

		//Esta função desativa o model corrente e inicia a operação de Inclusão das operações realizadas
		TAF276Comm( oModel, oModelT1V, oModelT3U, oModelT79, oModelT91, aGravaT1V, aGravaT3U, aGravaT79, aGravaT91, .T., oModelV91, @aGravaV91 )

		//Gravo alteração para o Extemporâneo
		If lGoExtemp
			TafGrvExt( oModel, 'MODEL_T1V', 'T1V' )
		EndIf

		FwFormCommit( oModel )
		TAFAltStat( 'T1V', "6" )

	End Transaction

Return ( .T. )
//-------------------------------------------------------------------
/*/{Protheus.doc} TAF276Chv

@Param  oModel  -> Modelo de dados

@Return .T.

@Since 30/06/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAF276Chv( oModel )

	Local nOperation	:= oModel:GetOperation()
	Local lRet 		:= .T.

	Default oModel := Nil

	//Apenas realizao a operação quando se tratar de uma operação de Inclusão
	If nOperation == MODEL_OPERATION_INSERT
		lRet := xFunVldUni( "T1V",3, FwFldGet( "T1V_CPF" ) + FwFldGet( "T1V_MATRIC" ) + DToS( FwFldGet( "T1V_DTALT" ) ) + DToS( FwFldGet( "T1V_DTEF" ) ) + "1" )
	EndIf

Return ( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} tafTrasfFunc
Funcao que inativa o trabalhador original e grava o ID entre eles

@author evandro.oliveira
@since 11/12/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Function tafTrasfFunc(cChaveOri, nIndPos, cIdTransf, cFilOri, cFilTaf, aChaveC9V,cRastro,lRotAjuste)
Return xTafTransf(cChaveOri, nIndPos, cIdTransf, cFilOri, cFilTaf, aChaveC9V,cRastro,lRotAjuste)

//---------------------------------------------------------------------
/*/{Protheus.doc} xTafTransf
Funcao que inativa o trabalhador original e grava o ID entre eles

@author fabio.santana
@since 23/04/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function xTafTransf( cChaveOri, nIndPos, cIdTransf, cFilOri, cFilTaf, aChaveC9V,cRastro,lRotAjuste,lCUPLimpAf)

	Local oModel		:= Nil

	Local aGrava     := {}
	Local aGravaCUP  := {}
	Local aGravaC9Y  := {}
	Local aGravaCRQ  := {}
	Local aGravaT3L  := {}
	Local aGravaT80  := {}
	Local aGravaT90  := {}

	Local aGravaT1U  := {}
	Local aGravaT3T  := {}

	//Carrego a Estrutura dos Models a serem gravados
	Local oModelC9V := Nil
	Local oModelCUP := Nil
	Local oModelC9Y := Nil
	Local oModelCRQ := Nil
	Local oModelT3L := Nil
	Local oModelT80 := Nil
	Local oModelT90 := Nil

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
	Default lCUPLimpAf := .F.

	Begin Transaction

		// Registro Original
		("C9V")->( DbSetOrder( nIndPos ) )
		If ("C9V")->( MsSeek( cChaveOri) )

			cIdTrabOri	:= C9V->C9V_ID
			cFilAnt 	:= cFilOri

			//Clone do S-2200 Original
			oModel := FWLoadModel( 'TAFA278' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado

			//oModel:SetOperation(4)
			oModel:Activate()

			oModelC9V := oModel:GetModel( "MODEL_C9V" )
			oModelCUP := oModel:GetModel( "MODEL_CUP" )
			oModelC9Y := oModel:GetModel( "MODEL_C9Y" )
			oModelCRQ := oModel:GetModel( "MODEL_CRQ" )
			oModelT3L := oModel:GetModel( "MODEL_T3L" )
			oModelT80 := oModel:GetModel( "MODEL_T80" )
			oModelT90 := oModel:GetModel( "MODEL_T90" )

			//Armazeno as informações correntes do cadastro
			TAF278Carr( oModel, oModelC9V, oModelCUP, oModelC9Y, oModelCRQ, oModelT3L, oModelT80, oModelT90, @aGrava, @aGravaCUP, @aGravaC9Y, @aGravaCRQ, @aGravaT3L, @aGravaT80, @aGravaT90, lCUPLimpAf )

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

			//Carrego o modelo com as informações gravadas nos ARRAYs alimentados na função TAF278CARR
			TAF278Comm( oModel, oModelC9V, oModelCUP, oModelC9Y, oModelCRQ, oModelT3L, oModelT80, oModelT90, aGrava, aGravaCUP, aGravaC9Y, aGravaCRQ, aGravaT3L, aGravaT80, aGravaT90 )

			FwFormCommit( oModel )

			If lRotAjuste
				nLastRecno := C9V->(RecNo())
			EndIf
			cFilAnt := cFilBkp
			lFoundC9V := .T.

		EndIf

		/*
		DSERTAF1-9429
		Alteração realizada para que, nos casos de se executarem uma transferência de um funcionário
		carregar tbm as alterações cadastrais que ocorreram antes da transferência.
		*/
		T1U->(DbSetOrder(2)) //T1U_FILIAL+T1U_ID+T1U_ATIVO+DTOS(T1U_DTALT)
		If lFoundC9V .And. T1U->( MsSeek(cFilOri+cIdTrabOri+"1") )

			cFilAnt := cFilOri

			//Clone do S-2200 Original
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
				C9V->C9V_IDTRAN := aGrava[1,2] + aGrava[4,2] + aGrava[5,2] + 'S22001'
				("C9V")->(MsUnlock())
			EndIf
		Endif

	End Transaction

	RestArea(aAreaC9V)

Return nLastRecno

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF278Carr
Função que armazena nos arrays as informações correntes do cadastro

@Param 

oModelC9V - Model da tabela C9V
oModelC9Y - Model da tabela C9Y
aGrava    - Array que armazena as informações da tabela C9V
aGravaC9Y - Array que armazena as informações da tabela C9Y

@Return .T.

@Author Rodrigo Aguilar
@Since 29/01/2014
@Version 1.0
/*/
//-------------------------------------------------------------------

Static Function TAF278Carr( oModel, oModelC9V, oModelCUP, oModelC9Y, oModelCRQ, oModelT3L, oModelT80, oModelT90, aGrava, aGravaCUP, aGravaC9Y, aGravaCRQ, aGravaT3L, aGravaT80, aGravaT90, lCUPLimpAf )

	Local nI := 0

	Default oModel	:= Nil
	Default oModelC9V	:= Nil
	Default oModelCUP	:= Nil
	Default oModelC9Y	:= Nil
	Default oModelCRQ	:= Nil
	Default oModelT3L	:= Nil
	Default oModelT80	:= Nil
	Default oModelT90	:= Nil

	Default aGrava	    := {}
	Default aGravaCUP	:= {}
	Default aGravaC9Y	:= {}
	Default aGravaCRQ	:= {}
	Default aGravaT3L	:= {}
	Default aGravaT80	:= {}
	Default aGravaT90	:= {}

	Default lCUPLimpAf	:= .F.

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
	For nI := 1 to Len( oModelCUP:aDataModel[ 1 ] )

		//--------------------------------------------------------------------------------------------------------------
		// Em caso de transferencia, se o trabalhador já possuir evento de afastamento (CM6), limpa os campos de inicio
		// no eSocial afastado, para nao ocorrer erro na filial destino, quando tentar incluir um inicio de afastamento
		//--------------------------------------------------------------------------------------------------------------
		If lCUPLimpAf .And. oModelCUP:aDataModel[ 1, nI, 1 ] $ 'CUP_DTINIA|CUP_MOTVAF'

			Aadd( aGravaCUP, { oModelCUP:aDataModel[ 1, nI, 1 ], CriaVar(oModelCUP:aDataModel[ 1, nI, 1 ],.F.) } )
		Else

			Aadd( aGravaCUP, { oModelCUP:aDataModel[ 1, nI, 1 ], oModelCUP:aDataModel[ 1, nI, 2 ] } )
		EndIf

	Next nI
	//-------

	//***********
	//Dependentes
	//***********
	For nI := 1 to oModel:GetModel( "MODEL_C9Y" ):Length()
		oModel:GetModel( "MODEL_C9Y" ):GoLine(nI)
		If !oModel:GetModel( 'MODEL_C9Y' ):IsEmpty()
			If !oModel:GetModel( "MODEL_C9Y" ):IsDeleted()
				aAdd(aGravaC9Y,{oModelC9Y:GetValue("C9Y_IDDEP"),;
					oModelC9Y:GetValue("C9Y_TPDEP"),;
					oModelC9Y:GetValue("C9Y_NOMDEP"),;
					oModelC9Y:GetValue("C9Y_DTNASC"),;
					oModelC9Y:GetValue("C9Y_CPFDEP"),;
					oModelC9Y:GetValue("C9Y_DEPIRF"),;
					oModelC9Y:GetValue("C9Y_DEPSFA"),;
					oModelC9Y:GetValue("C9Y_INCTRB")})
			EndIf
		EndIf
	Next nI
	//-----------

	//*****************
	//Horario Contratual
	//*****************
	For nI := 1 to oModel:GetModel( "MODEL_CRQ" ):Length()
		oModel:GetModel( "MODEL_CRQ" ):GoLine(nI)
		If !oModel:GetModel( "MODEL_CRQ" ):IsDeleted()
			aAdd(aGravaCRQ,{oModelCRQ:GetValue("CRQ_CODDIA"),;
				oModelCRQ:GetValue("CRQ_CODHOR")})
		EndIf
	Next nI
	//-----------------

	//***********************
	//Trabalhador Substituido
	//***********************
	For nI := 1 to oModel:GetModel( "MODEL_T3L" ):Length()
		oModel:GetModel( "MODEL_T3L" ):GoLine(nI)
		If !oModel:GetModel( "MODEL_T3L" ):IsDeleted()
			aAdd(aGravaT3L,{oModelT3L:GetValue("T3L_CPF")})
		EndIf
	Next nI
	//----------------------

	//*********************************
	//Filiação Sindical do Trabalhador
	//*********************************
	For nI := 1 to oModel:GetModel( "MODEL_T80" ):Length()
		oModel:GetModel( "MODEL_T80" ):GoLine(nI)
		If !oModel:GetModel( "MODEL_T80" ):IsDeleted()
			aAdd(aGravaT80,{oModelT80:GetValue("T80_CNPJSD")})
		EndIf
	Next nI
	//----------------------

	//************************************
	//Observações do contrato de trabalho
	//************************************
	For nI := 1 to oModel:GetModel( "MODEL_T90" ):Length()
		oModel:GetModel( "MODEL_T90" ):GoLine(nI)
		If !oModel:GetModel( "MODEL_T90" ):IsDeleted()
			aAdd(aGravaT90,{oModelT90:GetValue("T90_CODOBS"),;
				oModelT90:GetValue("T90_OBSERV")})
		EndIf
	Next nI
	//----------------------

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF278Comm
Função que realiza a gravação das informações

@Param 

oModel    - Model que esta sendo editado
oModelC9V - Model da tabela C9V
oModelC9Y - Model da tabela C9Y
aGrava    - Array que armazena as informações da tabela C9V
aGravaC9Y - Array que armazena as informações da tabela C9Y
lFisrOpe  - Indica se a operação que esta sendo realizada se refere a uma inclusão, neste caso os campos
			 de controle de rastro não devem ser gravados 

@Return .T.

@Author Rodrigo Aguilar
@Since 29/01/2014
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAF278Comm( oModel, oModelC9V, oModelCUP, oModelC9Y, oModelCRQ, oModelT3L, oModelT80, oModelT90, aGrava, aGravaCUP, aGravaC9Y, aGravaCRQ, aGravaT3L, aGravaT80, aGravaT90 )

	Local nI 		 	:= 0

	Default oModel		:= Nil
	Default oModelC9V	:= Nil
	Default oModelCUP	:= Nil
	Default oModelC9Y	:= Nil
	Default oModelCRQ	:= Nil
	Default oModelT3L	:= Nil
	Default oModelT80	:= Nil
	Default oModelT90	:= Nil

	Default aGrava	    := {}
	Default aGravaCUP	:= {}
	Default aGravaC9Y	:= {}
	Default aGravaCRQ	:= {}
	Default aGravaT3L	:= {}
	Default aGravaT80	:= {}
	Default aGravaT90	:= {}


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
	For nI := 1 to Len( aGravaCUP )
		oModel:LoadValue( "MODEL_CUP", aGravaCUP[ nI, 1 ], aGravaCUP[ nI, 2 ] )
	Next nI

	//***********
	//Dependentes
	//***********
	For nI := 1 to Len( aGravaC9Y )
		If nI > 1
			oModel:GetModel( "MODEL_C9Y" ):AddLine()
		EndIf
		oModel:LoadValue( "MODEL_C9Y", "C9Y_IDDEP" , aGravaC9Y[nI][1] )
		oModel:LoadValue( "MODEL_C9Y", "C9Y_TPDEP" , aGravaC9Y[nI][2] )
		oModel:LoadValue( "MODEL_C9Y", "C9Y_NOMDEP", aGravaC9Y[nI][3] )
		oModel:LoadValue( "MODEL_C9Y", "C9Y_DTNASC", aGravaC9Y[nI][4] )
		oModel:LoadValue( "MODEL_C9Y", "C9Y_CPFDEP", aGravaC9Y[nI][5] )
		oModel:LoadValue( "MODEL_C9Y", "C9Y_DEPIRF", aGravaC9Y[nI][6] )
		oModel:LoadValue( "MODEL_C9Y", "C9Y_DEPSFA", aGravaC9Y[nI][7] )
		oModel:LoadValue( "MODEL_C9Y", "C9Y_INCTRB", aGravaC9Y[nI][8] )
	Next nI

	//*****************
	//Horario Contratual
	//*****************
	For nI := 1 to Len( aGravaCRQ )
		If nI > 1
			oModel:GetModel( "MODEL_CRQ" ):AddLine()
		EndIf
		oModel:LoadValue( "MODEL_CRQ", "CRQ_CODDIA" , aGravaCRQ[nI][1] )
		oModel:LoadValue( "MODEL_CRQ", "CRQ_CODHOR" , aGravaCRQ[nI][2] )
	Next nI

	//***********************
	//Trabalhador Substituido
	//***********************
	For nI := 1 to Len( aGravaT3L )
		If nI > 1
			oModel:GetModel( "MODEL_T3L" ):AddLine()
		EndIf
		oModel:LoadValue( "MODEL_T3L", "T3L_CPF" , aGravaT3L[nI][1] )
	Next nI

	//********************************
	//Filiação Sindical do Trabalhador
	//********************************
	For nI := 1 to Len( aGravaT80 )
		If nI > 1
			oModel:GetModel( "MODEL_T80" ):AddLine()
		EndIf
		oModel:LoadValue( "MODEL_T80", "T80_CNPJSD" , aGravaT80[nI][1] )
	Next nI
	//----------------------

	//***********************************
	//Observações do contrato de trabalho
	//***********************************
	For nI := 1 to Len( aGravaT90 )
		If nI > 1
			oModel:GetModel( "MODEL_T90" ):AddLine()
		EndIf
		oModel:LoadValue( "MODEL_T90", "T90_CODOBS" , aGravaT90[nI][1] )
		oModel:LoadValue( "MODEL_T90", "T90_OBSERV" , aGravaT90[nI][2] )
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

/*Esta função estava sendo chamada pelo TAFLOAD e foi criada para um ajuste 
de legado pontual, a mesma está sendo excluida e para não gerar um error.log
estamos mantendo a mesma vazia, na virada de release esta função deverá
ser apagada por conta dos débitos técnicos.
*/
Function Ajstaf2206()
Return Nil
//----------------------------------------------------------------------
/*/{Protheus.doc} RetIna06
Posiciona no último registro Inativo de alteração para o evento 2206 
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
Static Function RetIna06(cAlias,cChave,nInd)

	Local lReturn 	:= .F.
	Local nRecno	:= 0

	Default lTrans	:= .F. // indica se deve procurar um registro transmitido

	dbSelectArea(cAlias)
	(cAlias)->(dbSetorder(nInd)) // FILIAL + ID + ATIVO + DTALT
	(cAlias)->(dbGoTop())

	If (cAlias)->(msSeek(xFilial(cAlias) + cChave))

		While (cAlias)->(!Eof()) .And. (cAlias)->&(cAlias + "_CPF") + (cAlias)->&(cAlias + "_MATRIC") + DTOS((cAlias)->&(cAlias + "_DTALT")) + DTOS((cAlias)->&(cAlias + "_DTEF"))  == cChave

			If (cAlias)->&(cAlias + "_EVENTO") $ 'I|A'
				nRecno := (cAlias)->(Recno())
				(cAlias)->(dbSkip())
            Else 
                If (cAlias)->&(cAlias + "_EVENTO") == 'E'
                    nRecno := 0 // Se o ultimo registro for de exclusão não devemos voltar o status para 1
                EndIf 
				(cAlias)->(dbSkip())
			EndIf
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
