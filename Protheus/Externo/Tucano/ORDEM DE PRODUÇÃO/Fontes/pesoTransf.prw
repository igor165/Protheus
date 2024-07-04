#INCLUDE "FWBROWSE.CH"
#Include 'FWMVCDef.ch'
#Include 'FWEditPanel.CH'
#Include "TOTVS.CH"

Static cDescription := "Registro de Pesagem Transferência ou Entrada"

User Function PESOTRANSF()
	Private oBrowse := FWMBrowse():New()
	Private aSeek 	:= {}

	oBrowse:SetDescription(cDescription)
	oBrowse:SetAlias("ZA0")
	oBrowse:SetMenuDef("PESOTRANSF")
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetDBFFilter(.T.)

	// Ativa a oBrowse
	oBrowse:Activate()

Return Nil


Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Incluir' 			ACTION 'ViewDEF.PESOTRANSF' 	 OPERATION MODEL_OPERATION_INSERT   ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar' 			ACTION 'ViewDEF.PESOTRANSF' 	 OPERATION MODEL_OPERATION_UPDATE   ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' 		ACTION 'ViewDEF.PESOTRANSF' 	 OPERATION MODEL_OPERATION_VIEW   	ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir' 			ACTION 'ViewDEF.PESOTRANSF' 	 OPERATION MODEL_OPERATION_DELETE   ACCESS 0
	ADD OPTION aRotina TITLE 'Pesquisar'  		ACTION 'PesqBrw'        	 	 OPERATION 1                      	ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Impromir Ticket'  ACTION 'U_ImpMotT'        	 	 OPERATION 1                      	ACCESS 0 //OPERATION 1

Return aRotina

Static Function ModelDef()
	Local oModel  := MPFormModel():New("MDLPESOTRANSF")
	Local oStrZA0 := FWFormStruct(1, 'ZA0')

	oStrZA0:AddTrigger("ZA0_LJFOR","ZA0_FORDES",{|| .T.},;
		{ |oModel| Left(AllTrim(Posicione("SA2",1,FWxFilial("SA2") + oModel:GetValue('ZA0_FORNEC')+oModel:GetValue('ZA0_LJFOR'),"A2_NOME" )),TamSx3("ZA0_FORDES")[01] ) } )

	oStrZA0:AddTrigger("ZA0_LJCLI","ZA0_DESCLI",{|| .T.},;
		{ |oModel| Left( AllTrim(Posicione("SA1",1,FWxFilial("SA1") + oModel:GetValue('ZA0_CLIENT')+oModel:GetValue('ZA0_LJCLI'),"A1_NOME" )) ,TamSx3("ZA0_DESCLI")[01] )} )

	oStrZA0:AddTrigger("ZA0_LJCLI","ZA0_FILDES",{ |  | .T.},{ |oModel| oModel:GetValue('ZA0_LJCLI')  } )

	oStrZA0:AddTrigger("ZA0_PESO2","ZA0_TARA",{ | oModel | oModel:GetValue('ZA0_PESO1') > 0 .And. oModel:GetValue('ZA0_PESO2') > 0},;
		{ |oModel| IIF( oModel:GetValue('ZA0_PESO1') > oModel:GetValue('ZA0_PESO2') ,;
		oModel:GetValue('ZA0_PESO1') -  oModel:GetValue('ZA0_PESO2'),;
		oModel:GetValue('ZA0_PESO2') - oModel:GetValue('ZA0_PESO1') )  } )

	oStrZA0:AddTrigger("ZA0_PESO1","ZA0_DTHRP1",{ |  | .T.},{ |oModel| Left(FWTimeStamp(2),TamSx3("ZA0_DTHRP1")[01]) } )
	oStrZA0:AddTrigger("ZA0_PESO2","ZA0_DTHRP2",{ |  | .T.},{ |oModel| Left(FWTimeStamp(2),TamSx3("ZA0_DTHRP2")[01]) } )

	oStrZA0:AddTrigger("ZA0_PESO1","ZA0_PEMAN1",{ |  | .T.},{ || "M"} )
	oStrZA0:AddTrigger("ZA0_PESO2","ZA0_PEMAN2",{ |  | .T.},{ || "M"} )

	oStrZA0:SetProperty("ZA0_FORNEC",MODEL_FIELD_WHEN, {|| .F. })
	oStrZA0:SetProperty("ZA0_LJFOR" ,MODEL_FIELD_WHEN, {|| .F. })
	oStrZA0:SetProperty("ZA0_CLIENT",MODEL_FIELD_WHEN, {|| .F. })
	oStrZA0:SetProperty("ZA0_LJCLI" ,MODEL_FIELD_WHEN, {|| .F. })
	oStrZA0:SetProperty("ZA0_FORDES",MODEL_FIELD_WHEN, {|| .F. })
	oStrZA0:SetProperty("ZA0_DESCLI",MODEL_FIELD_WHEN, {|| .F. })
	oStrZA0:SetProperty("ZA0_DOC"	,MODEL_FIELD_WHEN, {|| .F. })
	oStrZA0:SetProperty("ZA0_SERIE"	,MODEL_FIELD_WHEN, {|| .F. })
	oStrZA0:SetProperty("ZA0_CODPRD",MODEL_FIELD_WHEN, {|| .F. })
	oStrZA0:SetProperty("ZA0_DESPRD",MODEL_FIELD_WHEN, {|| .F. })

	oModel:AddFields("FORMCAB", /*cOwner*/, oStrZA0, /*/bPre/*/)

	oModel:SetPrimaryKey({"ZA0_FILIAL","ZA0_TIPO" ,"ZA0_CHVNFE"})
	oModel:SetDescription(cDescription)

Return oModel

Static Function ViewDef()
	Local oModel 	:= ModelDef()
	Local oView  	:= FWFormView():New()
	Local oStrZA0 	:= FWFormStruct(2, 'ZA0')

	oView:SetModel(oModel)
	oView:AddField("VIEW_CAB", oStrZA0,"FORMCAB")

	//Habilitando título
	oView:EnableTitleView('VIEW_CAB', cDescription)
	oView:AddUserButton( "Balança - (10)" , 'CLIPS', 	{ || AtBalanca(FwModelActive(),FWViewActive()) },"",VK_F10 )
	oView:SetFieldAction("ZA0_CHVNFE" ,{ |oView, cIDView, cField, xValue| preencheAuto(oView, cIDView, cField, xValue) } )

Return oView


Static Function AtBalanca(oModel,oView)
	Local oMdlCab	      	:= oModel:GetModel('FORMCAB')
	Local nOpc				as numeric
	Local _nPesoLido		as numeric
	Local lPesagManu        := .F.
	// Local nPeso				:= 0
	Local nPeso1            := oMdlCab:GetValue('ZA0_PESO1')
	Local nPeso2            := oMdlCab:GetValue('ZA0_PESO2')
	Local aParBal           := AGRX003E( .t., 'OGA050001' )

	if Len(aParBal) > 1 .And. !Empty(aParBal[01])
		if oMdlCab:GetValue('ZA0_PESO1')  == 0
			nOpc := 1
		Elseif oMdlCab:GetValue('ZA0_PESO2')  == 0
			nOpc := 2
		Else
			if MsgYesNo('Peso e tara do caminhão preenchidos, deseja informar o peso do caminhão novamente?')
				nOpc := 1
			Else
				nOpc := 2
			Endif
		Endif

		AGRX003A( @_nPesoLido,.T., aParBal, /*cMask*/,@lPesagManu, nPeso1, nPeso2, nOpc )

		IF _nPesoLido > 0
			if nOpc == 1
				oMdlCab:SetValue('ZA0_PESO1' ,	_nPesoLido ) //SZIPE1 //nOpc ==1
				oMdlCab:SetValue('ZA0_DTHRP1',	FWTimeStamp(2)) //SZIPE1 //nOpc ==1
				if ZA0->(FieldPos("ZA0_PEMAN1"))
					oMdlCab:LoadValue('ZA0_PEMAN1',	iif(lPesagManu,"M","A")) //SZIPE1 //nOpc ==1
				EndIf
			Elseif nOpc == 2
				oMdlCab:SetValue('ZA0_PESO2' ,_nPesoLido )  //SZIPES //nOpc ==2
				oMdlCab:SetValue('ZA0_DTHRP2',	FWTimeStamp(2)) //SZIPE1 //nOpc ==1
				if ZA0->(FieldPos("ZA0_PEMAN2"))
					oMdlCab:LoadValue('ZA0_PEMAN2',	iif(lPesagManu,"M","A")) //SZIPE1 //nOpc ==1
				EndIf
			Endif

			//Peso Liquido
			IF oMdlCab:GetValue('ZA0_PESO1') > oMdlCab:GetValue('ZA0_PESO2')
				nTara := oMdlCab:GetValue('ZA0_PESO1') - oMdlCab:GetValue('ZA0_PESO2')
			Else
				nTara := oMdlCab:GetValue('ZA0_PESO2') - oMdlCab:GetValue('ZA0_PESO1')
			EndIf

			oMdlCab:SetValue('ZA0_TARA',nTara )
		ELSE
			MsgAlert('Peso retornado da balança inválido.')
		EndIF
	EndIF

	oView:Refresh()
Return

Static Function preencheAuto(oView, cIDView, cField, xValue)
	Local oModel	:= FWModelActive()
	Local oMdlCab	:= oModel:GetModel('FORMCAB')
	Local oStrZA0	:= oMdlCab:GetStruct()
	Local cQuery	as character
	Local nRecno	as numeric

	if !Empty(xValue)
		if oMdlCab:GetValue("ZA0_TIPO") == "T"
			cQuery := " SELECT TOP 1 D2.R_E_C_N_O_  as RECNO "
			cQuery += " FROM " + RetSqlName("SF2") + " F2 "
			cQuery += " 	INNER JOIN " + RetSqlName("SD2") + " D2 ON D2.D_E_L_E_T_ =' '  "
			cQuery += " 		AND F2_FILIAL 	= D2_FILIAL "
			cQuery += " 		AND F2_DOC 		= D2_DOC "
			cQuery += " 		AND F2_SERIE 	= D2_SERIE "
			cQuery += " 		AND F2_CLIENTE 	= D2_CLIENTE "
			cQuery += " 		AND F2_LOJA 	= D2_LOJA "
			cQuery += " WHERE F2.D_E_L_E_T_ =' ' "
			cQuery += " AND F2_FILIAL = "  +ValToSql(FWxFilial("SF2"))
			cQuery += " AND F2_CHVNFE = "  +ValToSql(xValue)
			cQuery := ChangeQuery(cQuery)
			nRecno := MpSysExecScalar(cQuery, "RECNO")

			IF nRecno > 0
				oStrZA0:SetProperty("ZA0_CODPRD",MODEL_FIELD_WHEN, {|| .T. })
				oStrZA0:SetProperty("ZA0_DESPRD",MODEL_FIELD_WHEN, {|| .T. })
				oStrZA0:SetProperty("ZA0_DOC"	,MODEL_FIELD_WHEN, {|| .T. })
				oStrZA0:SetProperty("ZA0_SERIE"	,MODEL_FIELD_WHEN, {|| .T. })
				oStrZA0:SetProperty("ZA0_CLIENT",MODEL_FIELD_WHEN, {|| .T. })
				oStrZA0:SetProperty("ZA0_LJCLI"	,MODEL_FIELD_WHEN, {|| .T. })

				SD2->(DbGoTo(nRecno))
				oMdlCab:SetValue('ZA0_CODPRD',SD2->D2_COD )
				oMdlCab:SetValue('ZA0_DESPRD',AllTrim(Posicione("SB1",1,FwxFilial("SB1")+SD2->D2_COD,"B1_DESC")) )
				oMdlCab:SetValue('ZA0_DOC'	 ,SD2->D2_DOC )
				oMdlCab:SetValue('ZA0_SERIE' ,SD2->D2_SERIE )
				oMdlCab:SetValue('ZA0_CLIENT',SD2->D2_CLIENTE )
				oMdlCab:SetValue('ZA0_LJCLI' ,SD2->D2_LOJA )
				oMdlCab:SetValue('ZA0_QNTNF' ,SD2->D2_QUANT )

				oStrZA0:SetProperty("ZA0_CODPRD",MODEL_FIELD_WHEN, {|| .F. })
				oStrZA0:SetProperty("ZA0_DESPRD",MODEL_FIELD_WHEN, {|| .F. })
				oStrZA0:SetProperty("ZA0_DOC"	,MODEL_FIELD_WHEN, {|| .F. })
				oStrZA0:SetProperty("ZA0_SERIE"	,MODEL_FIELD_WHEN, {|| .F. })
				oStrZA0:SetProperty("ZA0_CLIENT",MODEL_FIELD_WHEN, {|| .F. })
				oStrZA0:SetProperty("ZA0_LJCLI"	,MODEL_FIELD_WHEN, {|| .F. })

			Else
				MsgStop("Nota de saída não encontrada com a chave "+xValue)
			EndIf
		Else
			cQuery := " SELECT TOP 1 D1.R_E_C_N_O_  as RECNO "
			cQuery += " FROM " + RetSqlName("SF1") + " F1 "
			cQuery += " 	INNER JOIN " + RetSqlName("SD1") + " D1 ON D1.D_E_L_E_T_ =' '  "
			cQuery += " 		AND F1_FILIAL 	= D1_FILIAL "
			cQuery += " 		AND F1_DOC 		= D1_DOC "
			cQuery += " 		AND F1_SERIE 	= D1_SERIE "
			cQuery += " 		AND F1_FORNECE 	= D1_FORNECE "
			cQuery += " 		AND F1_LOJA 	= D1_LOJA "
			cQuery += " AND F1_FILIAL = "  +ValToSql(FWxFilial("SF1"))
			cQuery += " WHERE F1.D_E_L_E_T_ =' ' "
			cQuery += " AND F1_CHVNFE = "  +ValToSql(xValue)
			cQuery := ChangeQuery(cQuery)
			nRecno := MpSysExecScalar(cQuery, "RECNO")

			IF nRecno > 0
				oStrZA0:SetProperty('ZA0_CODPRD',MODEL_FIELD_WHEN, {|| .T. })
				oStrZA0:SetProperty('ZA0_DESPRD',MODEL_FIELD_WHEN, {|| .T. })
				oStrZA0:SetProperty('ZA0_DOC'	,MODEL_FIELD_WHEN, {|| .T. })
				oStrZA0:SetProperty('ZA0_SERIE' ,MODEL_FIELD_WHEN, {|| .T. })
				oStrZA0:SetProperty('ZA0_FORNEC',MODEL_FIELD_WHEN, {|| .T. })
				oStrZA0:SetProperty('ZA0_LJFOR' ,MODEL_FIELD_WHEN, {|| .T. })

				SD1->(DbGoTo(nRecno))
				oMdlCab:SetValue('ZA0_CODPRD',SD1->D1_COD )
				oMdlCab:SetValue('ZA0_DESPRD',AllTrim(Posicione("SB1",1,FwxFilial("SB1")+SD1->D1_COD,"B1_DESC" )) )
				oMdlCab:SetValue('ZA0_DOC'	 ,SD1->D1_DOC )
				oMdlCab:SetValue('ZA0_SERIE' ,SD1->D1_SERIE )
				oMdlCab:SetValue('ZA0_FORNEC',SD1->D1_FORNECE )
				oMdlCab:SetValue('ZA0_LJFOR' ,SD1->D1_LOJA )
				oMdlCab:SetValue('ZA0_QNTNF' ,SD1->D1_QUANT )

				oStrZA0:SetProperty('ZA0_CODPRD',MODEL_FIELD_WHEN, {|| .F. })
				oStrZA0:SetProperty('ZA0_DESPRD',MODEL_FIELD_WHEN, {|| .F. })
				oStrZA0:SetProperty('ZA0_DOC'	,MODEL_FIELD_WHEN, {|| .F. })
				oStrZA0:SetProperty('ZA0_SERIE' ,MODEL_FIELD_WHEN, {|| .F. })
				oStrZA0:SetProperty('ZA0_FORNEC',MODEL_FIELD_WHEN, {|| .F. })
				oStrZA0:SetProperty('ZA0_LJFOR' ,MODEL_FIELD_WHEN, {|| .F. })
			Else
				MsgStop("Nota de entrada não encontrada com a chave "+xValue)
			EndIf

		EndIf
	EndIF

	if oView  != Nil .And. oView:IsActive()
		oView:Refresh()
	EndIf

Return
//51230400014282151072559250000093321629665364
//51230415043391000107550010002003541215353858 - entrada
