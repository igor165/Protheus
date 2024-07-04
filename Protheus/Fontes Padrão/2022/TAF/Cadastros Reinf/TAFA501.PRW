#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA501.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA501
Cadastro MVC do R-5001 - Tabela Espelho - Informações de bases e tributos por evento

@author Denis Souza
@since 22/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Function TAFA501()

	If TAFAlsInDic( "V0W" )
		BrowseDef()
	Else
		Aviso( STR0002, TafAmbInvMsg(), { STR0003 }, 3 ) //##"Dicionário Incompatível" ##"Encerrar"
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Função genérica MVC com as opções de menu

@author Denis Souza
@since 22/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aFuncao as array
Local aRotina as array

aFuncao := {}
aRotina := {}
/*
aAdd( aFuncao, { "", "TAF501Xml", "1" } )
aAdd( aFuncao, { "", "xFunNewHis( 'V0W', 'TAFA501' )", "3" } )
aAdd( aFuncao, { "", "TAFXmlLote( 'V0W', 'R-5001', 'TotalBasTrib', 'TAF501Xml', 5 )", "5" } )
*/
lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
//	ADD OPTION aRotina Title STR0004 	ACTION 'VIEWDEF.TAFA501' OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina Title STR0004  	ACTION 'Taf501View' OPERATION 2 ACCESS 0 //"Visualizar"
Else
//	ADD OPTION aRotina Title STR0004 	ACTION 'VIEWDEF.TAFA501' OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina Title STR0004  	ACTION 'Taf501View' OPERATION 2 ACCESS 0 //"Visualizar"
EndIf

Return (aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função genérica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis Souza
@since 22/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruV0W  as object
Local oStruV0X  as object
Local oStruV0Y  as object
Local oStruV0Z  as object
Local oStruV6B  as object
Local oModel	as object
Local lReinf15  as logical

lReinf15  := alltrim(StrTran( SuperGetMv('MV_TAFVLRE',.F.,'') ,'_','')) >= '10500' .and. TAFAlsInDic("V6B")
oStruV0W  := FWFormStruct( 1, 'V0W' )
oStruV0X  := FWFormStruct( 1, 'V0X' )
oStruV0Y  := FWFormStruct( 1, 'V0Y' )
oStruV0Z  := FWFormStruct( 1, 'V0Z' )

oModel    :=  MPFormModel():New( 'TAFA501' ,,,{|oModel| SaveModel(oModel)}) 

//V0W – Informações de Identificação do Evento
oModel:AddFields('MODEL_V0W', /*cOwner*/, oStruV0W)
oModel:GetModel( "MODEL_V0W" ):SetPrimaryKey( { "V0W_ID", "V0W_VERSAO" } )

//V0Y – Totalizador do evento R-2040 (RepAssocDesport)
oModel:AddGrid('MODEL_V0Y', 'MODEL_V0W', oStruV0Y)
oModel:GetModel('MODEL_V0Y'):SetUniqueLine({'V0Y_CNPJAD'})
oModel:GetModel('MODEL_V0Y'):SetOptional(.T.)

//V0X – Totalizador do evento R-2050 ((Comercialização da Produção PJ/Agroindústria))
oModel:AddGrid('MODEL_V0X', 'MODEL_V0W', oStruV0X)
oModel:GetModel('MODEL_V0X'):SetUniqueLine({'V0X_SEQUEN'})
oModel:GetModel('MODEL_V0X'):SetOptional(.T.)
//
//V0Z – Totalizador do evento R-2060 (CPRB)
oModel:AddGrid('MODEL_V0Z', 'MODEL_V0W', oStruV0Z)
oModel:GetModel('MODEL_V0Z'):SetOptional(.T.)
oModel:GetModel('MODEL_V0Z'):SetUniqueLine({'V0Z_CODREC'})
oModel:GetModel('MODEL_V0Z'):SetMaxLine(4)

//V6B – Totalizador do evento R-2055 (Aquisição Rural)
If lReinf15
	oStruV6B  := FWFormStruct( 1, 'V6B' )

	oModel:AddGrid('MODEL_V6B', 'MODEL_V0W', oStruV6B)
	oModel:GetModel('MODEL_V6B'):SetOptional(.T.)
	oModel:GetModel('MODEL_V6B'):SetUniqueLine({'V6B_CRAQUI'})
	oModel:GetModel('MODEL_V6B'):SetMaxLine(6)

	oModel:SetRelation("MODEL_V6B",{ {"V6B_FILIAL","xFilial('V6B')"}, {"V6B_ID","V0W_ID"}, {"V6B_VERSAO","V0W_VERSAO"}}	,V6B->(IndexKey(1)))
EndIf	

oModel:SetRelation("MODEL_V0X",{ {"V0X_FILIAL","xFilial('V0X')"}, {"V0X_ID","V0W_ID"}, {"V0X_VERSAO","V0W_VERSAO"}}	,V0X->(IndexKey(1)))
oModel:SetRelation("MODEL_V0Y",{ {"V0Y_FILIAL","xFilial('V0Y')"}, {"V0Y_ID","V0W_ID"}, {"V0Y_VERSAO","V0W_VERSAO"}}	,V0Y->(IndexKey(1)))
oModel:SetRelation("MODEL_V0Z",{ {"V0Z_FILIAL","xFilial('V0Z')"}, {"V0Z_ID","V0W_ID"}, {"V0Z_VERSAO","V0W_VERSAO"}}	,V0Z->(IndexKey(1)))

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Função genérica MVC do View

@return oView - Objeto da View MVC

@author Denis Souza
@since 22/03/2018
@version 1.0
/*/
//---------------------------------------------------------------------

Static Function ViewDef()

Local oModel   	As object
Local oStruV0Wa	As object
Local oStruV0Wb	As object
Local oStruV0X	As object
Local oStruV0Y	As object
Local oStruV0Z	As object
Local oStruV6B  As object
Local oView		As object
Local nI        As numeric
Local nViewOrd 	As numeric
Local aCmpGrp   As array
Local cCmpFil  	As Char
Local cGrpCom1	As Char
Local cGrpCom2	As Char
Local cGrpCom3	As Char
Local cGrpCom4	As Char
Local lNewView	As Logical
Local lIdeEstab As Logical  // tags de identificação do estabelecimento -> REINF v 1.4.0 ( tpInsc e nrInsc )
Local lCno 		As Logical
Local lLeiaute 	As Logical
Local lVSup132 	As Logical
Local lVSup151 	As Logical
Local lReinf15  as logical

lReinf15    := alltrim(StrTran( SuperGetMv('MV_TAFVLRE',.F.,'') ,'_','')) >= '10500' .and. TAFAlsInDic("V6B") 
nViewOrd	:= 0
lIdeEstab   := IIf( TafColumnPos( "V0W_TPINSE" ) .and. TafColumnPos( "V0W_NRINSE" ), .T., .F. )
lCno  		:= IIf( TafColumnPos( "V0W_CNOEST" ), .T., .F. )
lLeiaute	:= IIf( TafColumnPos( "V0W_LEIAUT" ), .T., .F. )
lVSup132	:= .F.
lVSup151	:= .F.

if lLeiaute .And. "1_04" $ V0W->V0W_LEIAUT
	lVSup132 := .T.
elseif lLeiaute .And. ( Empty( V0W->V0W_LEIAUT ) .Or. "1_03" $ V0W->V0W_LEIAUT )
	lVSup132 := .F.
elseif lLeiaute .And. lReinf15 .and. "1_05" $ V0W->V0W_LEIAUT	
	lVSup151 := .T.
	lVSup132 := .T.
elseif !lLeiaute
	lVSup132 := .F.
endif

lNewView	:= .T.
oModel   	:= FWLoadModel( 'TAFA501' )
oView		:= FWFormView():New()
oView:SetModel( oModel )

//oView:SetContinuousForm(.T.)

If lNewView
	If AllTrim( V0W->V0W_TPEVEN ) $ "2010|2020|2040|2030|2050|2055|2060|3010"
		// Cabeçalho comum aos Eventos

		cGrpCom1 := "V0W_PERAPU|V0W_VERSAO|V0W_CODRET|V0W_DTPROC|V0W_HRPROC|V0W_TPEVEN|V0W_IDEVEN|V0W_HASH|V0W_NRRECB|"

		If lVSup132 .and. lIdeEstab
			cGrpCom1 += "V0W_TPINSE|V0W_NRINSE|"
		EndIf

		oStruV0W01 := FwFormStruct( 2, 'V0W', {|x| AllTrim( x ) + "|" $ cGrpCom1 } )
		oView:AddField( "VIEW_V0W01", oStruV0W01, "MODEL_V0W" )
		oView:EnableTitleView( "VIEW_V0W01", "Informações do Retorno" )


		oView:CreateHorizontalBox( "PAINEL_SUPERIOR", 100 )
		oView:CreateFolder( "FOLDER_SUPERIOR", "PAINEL_SUPERIOR" )
		oView:AddSheet( "FOLDER_SUPERIOR", "ABA01", "Evento R-"+ V0W->V0W_TPEVEN )

		oView:CreateHorizontalBox( "FIELDSV0W01", 050,,, "FOLDER_SUPERIOR", "ABA01" )
		oView:SetOwnerView( "VIEW_V0W01", "FIELDSV0W01" )

		nViewOrd := 0
		oStruV0W01:SetProperty( "V0W_PERAPU"	, MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
		oStruV0W01:SetProperty( "V0W_TPEVEN"	, MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
		oStruV0W01:SetProperty( "V0W_DTPROC"	, MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
		oStruV0W01:SetProperty( "V0W_HRPROC"	, MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
		oStruV0W01:SetProperty( "V0W_VERSAO"	, MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
		oStruV0W01:SetProperty( "V0W_CODRET"	, MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
		oStruV0W01:SetProperty( "V0W_IDEVEN"	, MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
		oStruV0W01:SetProperty( "V0W_HASH"		, MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
		oStruV0W01:SetProperty( "V0W_NRRECB"	, MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )

		If lVSup132 .and. lIdeEstab
			oStruV0W01:SetProperty( "V0W_TPINSE", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
			oStruV0W01:SetProperty( "V0W_NRINSE", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
		EndIf

		IF "2010" $ V0W->V0W_TPEVEN

			If lVSup132 .and. lCno
				cGrpCom2 := "V0W_CNPJ10|V0W_CNOEST|V0W_CRTOM|V0W_VLTTBR|V0W_VLTTRP|V0W_VLTTNP|V0W_VLTTRA|V0W_VLTTNA|"
			else
				cGrpCom2 := "V0W_CNPJ10|V0W_CRTOM|V0W_VLTTBR|V0W_VLTTRP|V0W_VLTTNP|V0W_VLTTRA|V0W_VLTTNA|"
			EndIf

			oStruV0W02 := FwFormStruct( 2, 'V0W', {|x| AllTrim( x ) + "|" $ cGrpCom2 } )
			oView:AddField( "VIEW_V0W02", oStruV0W02, "MODEL_V0W" )
			oView:EnableTitleView( "VIEW_V0W02", "Informações do Evento R-"+ V0W->V0W_TPEVEN  ) 

			oView:CreateHorizontalBox( "FIELDSV0W02", 050,,, "FOLDER_SUPERIOR", "ABA01" )
			oView:SetOwnerView( "VIEW_V0W02", "FIELDSV0W02" )

			nViewOrd := 0
			oStruV0W02:SetProperty( "V0W_CNPJ10" , MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
			If lVSup132 .and. lCno
				oStruV0W02:SetProperty( "V0W_CNOEST" , MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
			endif
			oStruV0W02:SetProperty( "V0W_CRTOM"	 , MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
			oStruV0W02:SetProperty( "V0W_VLTTBR" , MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
			oStruV0W02:SetProperty( "V0W_VLTTRP" , MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
			oStruV0W02:SetProperty( "V0W_VLTTNP" , MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
			oStruV0W02:SetProperty( "V0W_VLTTRA" , MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
			oStruV0W02:SetProperty( "V0W_VLTTNA" , MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )

		ElseIf "2020" $ V0W->V0W_TPEVEN

			cGrpCom2  	:= "V0W_TPINST|V0W_NRINST|V0W_VLPTBR|V0W_VLPTRP|V0W_VLPTRA|V0W_VLPTNP|V0W_VLPTNA|"
			oStruV0W02 	:= FwFormStruct( 2, 'V0W', {|x| AllTrim( x ) + "|" $ cGrpCom2 } )
			oView:AddField( "VIEW_V0W02", oStruV0W02, "MODEL_V0W" )
			oView:EnableTitleView( "VIEW_V0W02", "Informações do Evento R-"+ V0W->V0W_TPEVEN  ) 

			oView:CreateHorizontalBox( "FIELDSV0W02", 050,,, "FOLDER_SUPERIOR", "ABA01" )
			oView:SetOwnerView( "VIEW_V0W02", "FIELDSV0W02" )

		ElseIf "2030" $ V0W->V0W_TPEVEN

/*
			cGrpCom2  	:= "V0W_VLCPAP|" //Atualizar
			oStruV0W02 	:= FwFormStruct( 2, 'V0W', {|x| AllTrim( x ) + "|" $ cGrpCom2 } )
			oView:AddField( "VIEW_V0W02", oStruV0W02, "MODEL_V0W" )
			oView:EnableTitleView( "VIEW_V0W02", "Informações do Evento R-"+ V0W->V0W_TPEVEN  ) 

			oView:CreateHorizontalBox( "FIELDSV0W02", 050,,, "FOLDER_SUPERIOR", "ABA01" )
			oView:SetOwnerView( "VIEW_V0W02", "FIELDSV0W02" )
*/
		ElseIf "2040" $ V0W->V0W_TPEVEN

			oStruV0Y	:= FWFormStruct( 2, 'V0Y' )
			
			oStruV0Y:RemoveField( "V0Y_ID" )
			oStruV0Y:RemoveField( "V0Y_VERSAO" )

			oView:AddGrid ( "VIEW_V0Y", oStruV0Y, "MODEL_V0Y" )
			oView:EnableTitleView( "VIEW_V0Y", "Informações do Evento R-"+ V0W->V0W_TPEVEN  ) 

			oView:CreateHorizontalBox( "FIELDSV0W02", 050,,, "FOLDER_SUPERIOR", "ABA01" )			
			oView:SetOwnerView( "VIEW_V0Y"	, "FIELDSV0W02" )
			
			nViewOrd := 0
			oStruV0Y:SetProperty( "V0Y_CNPJAD", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
			oStruV0Y:SetProperty( "V0Y_VLTREP", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
			oStruV0Y:SetProperty( "V0Y_VLTRET", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
			oStruV0Y:SetProperty( "V0Y_VLTNRT", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
		
		ElseIf "2050" $ V0W->V0W_TPEVEN

			oStruV0X	:= FWFormStruct( 2, 'V0X' )
			oStruV0X:RemoveField( "V0X_ID" )
			oStruV0X:RemoveField( "V0X_VERSAO" )
			oStruV0X:RemoveField( "V0X_TPOCOR" )
			oStruV0X:RemoveField( "V0X_LOCERR" )
			oStruV0X:RemoveField( "V0X_CODRES" )
			oStruV0X:RemoveField( "V0X_DSRESP" )
			oStruV0X:RemoveField( "V0X_SEQUEN" )
			oView:AddGrid("VIEW_V0X", oStruV0X, "MODEL_V0X")
			oView:AddIncrementField( 'VIEW_V0X', 'V0X_SEQUEN' ) 
			oView:EnableTitleView("VIEW_V0X", "Informações do Evento R-"+ V0W->V0W_TPEVEN) 

			oView:CreateHorizontalBox( "FIELDSV0W02", 050,,, "FOLDER_SUPERIOR", "ABA01" )
			oView:SetOwnerView( "VIEW_V0X", "FIELDSV0W02" )

		ElseIf lVSup151 .and. "2055" $ V0W->V0W_TPEVEN

			oStruV6B:= FWFormStruct( 2, 'V6B' )
			oStruV6B:RemoveField( "V6B_ID" )
			oStruV6B:RemoveField( "V6B_VERSAO" )
			oView:AddGrid("VIEW_V6B", oStruV6B, "MODEL_V6B")
			oView:EnableTitleView("VIEW_V6B", "Informações do Evento R-"+ V0W->V0W_TPEVEN) 

			oView:CreateHorizontalBox( "FIELDSV0W02", 050,,, "FOLDER_SUPERIOR", "ABA01" )
			oView:SetOwnerView( "VIEW_V6B", "FIELDSV0W02" )

		ElseIf "2060" $ V0W->V0W_TPEVEN

			oStruV0Z	:= FWFormStruct( 2, 'V0Z' )
			
			oStruV0Z:RemoveField( "V0Z_ID" )
			oStruV0Z:RemoveField( "V0Z_VERSAO" )
			oView:AddGrid ( "VIEW_V0Z", oStruV0Z, "MODEL_V0Z" )
			oView:EnableTitleView( "VIEW_V0Z", "Informações do Evento R-"+ V0W->V0W_TPEVEN  ) 

			oView:CreateHorizontalBox( "FIELDSV0W02", 050,,, "FOLDER_SUPERIOR", "ABA01" )			
			oView:SetOwnerView( "VIEW_V0Z"	, "FIELDSV0W02" )

		ElseIf "3010" $ V0W->V0W_TPEVEN
			
			cGrpCom2  	:= "V0W_VLRCTT|V0W_VLCPTT|V0W_CRESPE"
			oStruV0W02 	:= FwFormStruct( 2, 'V0W', {|x| AllTrim( x ) + "|" $ cGrpCom2 } )
			oView:AddField( "VIEW_V0W02", oStruV0W02, "MODEL_V0W" )
			oView:EnableTitleView( "VIEW_V0W02", "Informações do Evento R-"+ V0W->V0W_TPEVEN  ) 

			oView:CreateHorizontalBox( "FIELDSV0W02", 050,,, "FOLDER_SUPERIOR", "ABA01" )
			oView:SetOwnerView( "VIEW_V0W02", "FIELDSV0W02" )

		Else
			lNewView := .F.
		EndIf
	Else
		lNewView := .F.
	EndIf
EndIf

If !lNewView
	oStruV0Wa	:= Nil
	oStruV0Wb	:= Nil
	oStruV0X	:= FWFormStruct( 2, 'V0X' )
	oStruV0Y	:= FWFormStruct( 2, 'V0Y' )
	oStruV0Z	:= FWFormStruct( 2, 'V0Z' )
	If lReinf15
		oStruV6B	:= FWFormStruct( 2, 'V6B' )
	EndIf	

	cCmpFil  	:= ''
	nI        	:= 0

	aCmpGrp   	:= {}
	cGrpCom1  	:= ""
	cGrpCom2  	:= ""
	cGrpCom3	:= ""
	cGrpCom4	:= ""

	//Período Apuração  / Informações Recibo Retorno	
	If lVSup132 .and. lIdeEstab
		cGrpCom1  	:= "V0W_PERAPU|V0W_CODRET|V0W_DSCRET|V0W_PROTEN|V0W_DTPROC|V0W_HRPROC|V0W_TPEVEN|V0W_IDEVEN|V0W_HASH|V0W_NRRECB|V0W_TPINSE|V0W_NRINSE|"
	else
		cGrpCom1  	:= "V0W_PERAPU|V0W_CODRET|V0W_DSCRET|V0W_PROTEN|V0W_DTPROC|V0W_HRPROC|V0W_TPEVEN|V0W_IDEVEN|V0W_HASH|V0W_NRRECB|"
	EndIf

	//"Serviços Tomados Apuração R-2010"
	If lVSup132 .And. lCno
		cGrpCom2 := "V0W_CNPJ10|V0W_CNOEST|V0W_VLTTBR|V0W_VLTTRP|V0W_VLTTRA|V0W_VLTTNP|V0W_VLTTNA|"
	else
		cGrpCom2 := "V0W_CNPJ10|V0W_VLTTBR|V0W_VLTTRP|V0W_VLTTRA|V0W_VLTTNP|V0W_VLTTNA|"
	endif

	//"Serviços Prestados Apuração R-2020"
	cGrpCom3 	:= "V0W_TPINST|V0W_NRINST|V0W_VLPTBR|V0W_VLPTRP|V0W_VLPTRA|V0W_VLPTNP|V0W_VLPTNA|V0W_VLCPAP|V0W_VLRATA|V0W_VLSENA|V0W_VLCPSU|V0W_VLRATS|V0W_VLSENS|V0W_VLRCTT|V0W_VLCPTT|V0W_VLCPST|"

	cCmpFil   	:= cGrpCom1 + cGrpCom2 + cGrpCom3
	oStruV0Wa 	:= FwFormStruct( 2, 'V0W', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	//"Protocolo de Transmissão"
	cGrpCom4	:= 'V0W_PROTUL|'
	cCmpFil   	:= cGrpCom4
	oStruV0Wb 	:= FwFormStruct( 2, 'V0W', {|x| AllTrim( x ) + "|" $ cCmpFil } )
		
	/*-----------------------------------------------------------------------------------
	Grupo de campos
	-------------------------------------------------------------------------------------*/

	// V0Wa
	oStruV0Wa:AddGroup( "GRP_CAMPOS_01", STR0005, "", 1)	//"Período Apuração  / Informações Recibo Retorno"
	oStruV0Wa:AddGroup( "GRP_CAMPOS_02", STR0006, "", 1)	//"Serviços Tomados Apuração R-2010"
	oStruV0Wa:AddGroup( "GRP_CAMPOS_03", STR0007, "", 1)	//"Serviços Prestados Apuração R-2020"

	// V0WB
	oStruV0Wb:AddGroup( "GRP_CAMPOS_04", STR0008, "", 1) 	//"Protocolo de Transmissão"

	// V0Wa
	aCmpGrp := StrToKArr(cGrpCom1,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruV0Wa:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_CAMPOS_01")
	Next nI

	aCmpGrp := StrToKArr(cGrpCom2,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruV0Wa:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_CAMPOS_02")
	Next nI

	aCmpGrp := StrToKArr(cGrpCom3,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruV0Wa:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_CAMPOS_03")
	Next nI

	// V0WB
	aCmpGrp := StrToKArr(cGrpCom4,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruV0Wb:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_CAMPOS_04")
	Next nI

	/*--------------------------------------------------------------------------------------------
	Ordem Campos
	---------------------------------------------------------------------------------------------*/
	nViewOrd := 0
	oStruV0Wa:SetProperty( "V0W_PERAPU", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_CODRET", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_DSCRET", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_PROTEN", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_DTPROC", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_HRPROC", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_TPEVEN", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_IDEVEN", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_HASH"  , MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_NRRECB", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )

	If lVSup132 .and. lIdeEstab
		oStruV0Wa:SetProperty( "V0W_TPINSE", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
		oStruV0Wa:SetProperty( "V0W_NRINSE", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	EndIf

	oStruV0Wa:SetProperty( "V0W_CNPJ10", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )

	If lVSup132 .And. lCno
		oStruV0Wa:SetProperty( "V0W_CNOEST", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	endif

	oStruV0Wa:SetProperty( "V0W_VLTTBR", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_VLTTRP", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_VLTTRA", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_VLTTNP", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_VLTTNA", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_TPINST", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_NRINST", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_VLPTBR", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_VLPTRP", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_VLPTRA", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_VLPTNP", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_VLPTNA", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_VLCPAP", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_VLRATA", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_VLSENA", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_VLCPSU", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_VLRATS", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_VLSENS", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_VLRCTT", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_VLCPTT", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Wa:SetProperty( "V0W_VLCPST", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )

	nViewOrd := 0
	oStruV0X:SetProperty( "V0X_SEQUEN", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0X:SetProperty( "V0X_TPOCOR", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0X:SetProperty( "V0X_LOCERR", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0X:SetProperty( "V0X_CODRES", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0X:SetProperty( "V0X_DSRESP", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )

	nViewOrd := 0
	oStruV0Y:SetProperty( "V0Y_CNPJAD", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Y:SetProperty( "V0Y_VLTREP", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Y:SetProperty( "V0Y_VLTRET", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Y:SetProperty( "V0Y_VLTNRT", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )

	nViewOrd := 0
	oStruV0Z:SetProperty( "V0Z_CODREC", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Z:SetProperty( "V0Z_VLCPAT", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
	oStruV0Z:SetProperty( "V0Z_VLCSUS", MVC_VIEW_ORDEM, cValToChar(++nViewOrd) )
		
	/*--------------------------------------------------------------------------------------------
	Esrutura da View
	---------------------------------------------------------------------------------------------*/
	oView:AddField( "VIEW_V0Wa", oStruV0Wa, "MODEL_V0W" )
	oView:AddField( "VIEW_V0Wb", oStruV0Wb, "MODEL_V0W" )

	oView:AddGrid ( "VIEW_V0X", oStruV0X, "MODEL_V0X" )
	oView:AddIncrementField( 'VIEW_V0X', 'V0X_SEQUEN' ) 

	oView:AddGrid ( "VIEW_V0Y", oStruV0Y, "MODEL_V0Y" )

	oView:AddGrid ( "VIEW_V0Z", oStruV0Z, "MODEL_V0Z" )
	If lReinf15
		oView:AddGrid ( "VIEW_V6B", oStruV6B, "MODEL_V6B" )
	EndIf	

	/*-----------------------------------------------------------------------------------
	Estrutura do Folder
	-------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)

	oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

	oView:AddSheet("FOLDER_PRINCIPAL","ABA01","Evento R-"+ V0W->V0W_TPEVEN /*STR0009*/) 	//"Informações de bases e tributos por evento"
	oView:CreateHorizontalBox("V0Wa",70,,,"FOLDER_PRINCIPAL","ABA01") 

	oView:AddSheet("FOLDER_PRINCIPAL","ABA02",STR0010)	//"Recibo de Transmissão"
	oView:CreateHorizontalBox("V0Wb",70,,,'FOLDER_PRINCIPAL',"ABA02")

	oView:CreateHorizontalBox("PAINEL_TPCOM",30,,,"FOLDER_PRINCIPAL","ABA01")
	oView:CreateFolder( 'FOLDER_TPCOM', 'PAINEL_TPCOM' )

	oView:AddSheet( 'FOLDER_TPCOM', 'ABA01', STR0011)	//"Informações de ocorrências registradas"
	oView:CreateHorizontalBox ( 'V0X', 100,,, 'FOLDER_TPCOM'  , 'ABA01' )

	oView:AddSheet( 'FOLDER_TPCOM', 'ABA02', STR0012) 	//"Totalizador do evento R-2060 (CPRB)"
	oView:CreateHorizontalBox ( 'V0Y', 100,,, 'FOLDER_TPCOM'  , 'ABA02' )
	
	oView:AddSheet("FOLDER_TPCOM","ABA03", STR0013)		//"Totalizador do evento R-2040 (RepAssocDesport)"
	oView:CreateHorizontalBox("V0Z",100,,,"FOLDER_TPCOM","ABA03")

	If lReinf15
		oView:AddSheet( 'FOLDER_TPCOM', 'ABA04', STR0021) 	//Totalizador do evento R-2055 (RAquis)
		oView:CreateHorizontalBox ( 'V6B', 100,,, 'FOLDER_TPCOM'  , 'ABA04' )
		oView:SetOwnerView( "VIEW_V6B",  "V6B" )
	EndIf
	/*-----------------------------------------------------------------------------------
	Amarração para exibição das informações
	-------------------------------------------------------------------------------------*/
	oView:SetOwnerView( "VIEW_V0Wa", "V0Wa")
	oView:SetOwnerView( "VIEW_V0Wb", "V0Wb")
	oView:SetOwnerView( "VIEW_V0X",  "V0X" )
	oView:SetOwnerView( "VIEW_V0Y",  "V0Y" )
	oView:SetOwnerView( "VIEW_V0Z",  "V0Z" )

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If !lMenuDif
		xFunRmFStr(@oStruV0Wa,"V0W")
	EndIf

	/*-----------------------------------------------------------------------------------
	Remoção Campos
	-------------------------------------------------------------------------------------*/
	oStruV0Wa:RemoveField( "V0W_FILIAL" )
	oStruV0Wa:RemoveField( "V0W_ID" )
	oStruV0Wa:RemoveField( "V0W_STATUS" )
	oStruV0Wa:RemoveField( "V0W_VERSAO" )
	oStruV0Wa:RemoveField( "V0W_VERANT" )
	oStruV0Wa:RemoveField( "V0W_PROTPN" )
	oStruV0Wa:RemoveField( "V0W_EVENTO" )
	oStruV0Wa:RemoveField( "V0W_ATIVO" )

	oStruV0X:RemoveField( "V0X_ID" )
	oStruV0X:RemoveField( "V0X_VERSAO" )

	oStruV0Y:RemoveField( "V0Y_ID" )
	oStruV0Y:RemoveField( "V0Y_VERSAO" )

	oStruV0Z:RemoveField( "V0Z_ID" )
	oStruV0Z:RemoveField( "V0Z_VERSAO" )
	If lReinf15
		oStruV6B:RemoveField( "V6B_ID" )
		oStruV6B:RemoveField( "V6B_VERSAO" )
	EndIf	

EndIf

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Denis Souza
@since 22/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local nOperation	As Numeric
	Local lRetorno		As Logical

	nOperation	:= oModel:GetOperation()
	lRetorno	:= .T.

	FWFormCommit( oModel )

Return (lRetorno)



//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author Roberto Souza
@since 23/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()

	Local oBrw As object 

	If FunName() == "TAFXREINF"
		lMenuDif 	:= Iif( Type( "lMenuDif" ) == "U", .T., lMenuDif ) 
		cPerAReinf	:= Iif( Type( "cPerAReinf" ) == "U", "", cPerAReinf )

		cFiltro := "V0W_ATIVO == '1'" + IIf( !Empty(cPerAReinf) ," .AND. AllTrim(V0W_PERAPU) =='"+cPerAReinf+"'","" )
	Else
		cFiltro := "V0W_ATIVO == '1'"
	EndIf

	oBrw := FWmBrowse():New()
	oBrw:SetDescription( "R-5001 - "+STR0001 )	//"Informações de bases e tributos por evento"
	oBrw:SetAlias( 'V0W')
	oBrw:SetMenuDef( 'TAFA501' )	
	oBrw:SetFilterDefault( "V0W_ATIVO == '1'" )

	//DbSelectArea("V0W")
	//Set Filter TO &(cFiltro)
	
	oBrw:SetSeeAll( .F. )	
	TafLegend(2,"V0W",@oBrw)
	
	oBrw:Activate()

Return( oBrw )


//-------------------------------------------------------------------
/*/{Protheus.doc} Taf501View
Chamada para o View Dinamico por Evento

@author Roberto Souza
@since 28/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function Taf501View( cAlias, nRecno )

	Local nRet		as numeric
	Local oNewView	as object
	Local aArea 	as array
	
	nRet		:= 0
	oNewView	:= ViewDef()
	aArea 		:= GetArea()

	DbSelectArea( cAlias )
	( cAlias )->(DbGoTo( nRecno ))

	oExecView := FWViewExec():New()
	oExecView:setTitle("Evento R-"+ V0W->V0W_TPEVEN)
	oExecView:setOK( {|| .T. } )
	oExecView:setModal(.F.)               
	oExecView:setOperation(MODEL_OPERATION_VIEW)
	oExecView:setView( oNewView )
	oExecView:openView(.T.)

	RestArea( aArea )

Return( nRet )
