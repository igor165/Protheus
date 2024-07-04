#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static cTitulo := "Fechamento de Frete"
/*/{Protheus.doc} nomeFunction
    (long_description)
    @type  Function
    @author Igor Gomes Oliveira 
    @since 02/06/2023
    @version 1.0
    @param 
    @return 
    @example
    (examples)
    @see (links_or_references)
    /*/ 	
User Function VAFATI04()
	Local aArea		:= FWGetArea()
	Local oBrowse
	Private nTotEmb 	:= 0 //Total embarque
	Private nTotDes 	:= 0 //Total desembarque
	Private aCTE 		:= {}
	Private cArquivo 	:= "C:\TOTVS_RELATORIOS\"

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZFF")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()

    FWRestArea(aArea)
Return

Static Function ModelDef()
	Local oModel 		:= nil
	Local oCte 			:= FWFormStruct(1, 'TempCte')
	Local oStru   		:= FWFormStruct(1, 'ZFF')
	Local oGrid 		:= FWFormStruct(1, 'ZFF')
	Local bPos 			:= {|| U_FATI04S()}
	Local nI
	Local aGatilhos		:= {}
	Local aZFFRel		:= {}

	oCte := GetModelCte(oModel, oCte)

	aAdd(aGatilhos, FWStruTriggger( "CBC_LOJA"	,"CBC_NOME","SA2->A2_NOME"	,.T.,"SA2"	,1	,'FWxFilial("SA2")+M->CBC_FORNEC+M->CBC_LOJA',NIL,"01"))

    For nI := 1 To Len(aGatilhos)
        oCte:AddTrigger(  aGatilhos[nI][01],; //Campo Origem
                            aGatilhos[nI][02],; //Campo Destino
                            aGatilhos[nI][03],; //Bloco de código na validação da execução do gatilho
                            aGatilhos[nI][04])  //Bloco de código de execução do gatilho
    Next

	aGatilhos := {}
	//aAdd(aGatilhos, FWStruTriggger( "ZFF_FLOJA"	,"ZFF_MUN" ,"",.F.,"",	,'U_I04FMUN()',NIL,"02"))
	aAdd(aGatilhos, FWStruTriggger( "ZFF_FLOJA"	,"ZFF_MUN"    ,"SA1->A1_COD_MUN",.T.,"SA2"	,1	,'FWxFilial("SA2")+M->ZFF_FORNEC+M->ZFF_FLOJA',NIL,"02"))
	aAdd(aGatilhos, FWStruTriggger( "ZFF_FLOJA"	,"ZFF_EST"    ,"SA2->A2_EST"	,.T.,"SA2"	,1	,'FWxFilial("SA2")+M->ZFF_FORNEC+M->ZFF_FLOJA',NIL,"03"))
	aAdd(aGatilhos, FWStruTriggger( "ZFF_DLOJA"	,"ZFF_KM"     ,"U_I04DKM()"	 	,.F.,""		,NIL,NIL,"02"))
	aAdd(aGatilhos, FWStruTriggger( "ZFF_KM"	,"ZFF_VFRETE" ,"U_I04KMG()"	 	,.F.,""		,NIL,NIL,"02"))
	
	For nI := 1 To Len(aGatilhos)
        oStru:AddTrigger(  aGatilhos[nI][01],;  //Campo Origem
                            aGatilhos[nI][02],; //Campo Destino
                            aGatilhos[nI][03],; //Bloco de código na validação da execução do gatilho
                            aGatilhos[nI][04])  //Bloco de código de execução do gatilho
    Next

    oStru:SetProperty('ZFF_CONTRA'	, MODEL_FIELD_VALID	,   FwBuildFeature(STRUCT_FEATURE_VALID	, 'U_I04CTN()'))//Validação de Campo
    oStru:SetProperty('ZFF_COMBO'	, MODEL_FIELD_VALID	,   FwBuildFeature(STRUCT_FEATURE_VALID	, 'U_I04CTN()'))//Validação de Campo
    oStru:SetProperty('ZFF_NMUN'	, MODEL_FIELD_INIT	,   FwBuildFeature(STRUCT_FEATURE_INIPAD, 'Iif(!Inclui,Posicione("CC2",1,FWxFilial("CC2")+ZFF->ZFF_EST+ZFF->ZFF_MUN,"CC2_MUN"),"")'))//Iniciador de Campo
    
	oGrid:SetProperty('ZFF_ORIGEM'	, MODEL_FIELD_INIT	,   FwBuildFeature(STRUCT_FEATURE_INIPAD, 'U_I04INI()'))//Iniciador de Campo
    oGrid:SetProperty('ZFF_RLOJA'	, MODEL_FIELD_INIT	,   FwBuildFeature(STRUCT_FEATURE_INIPAD, 'U_I04INI()'))//Iniciador de Campo
    oGrid:SetProperty('ZFF_NORIG'	, MODEL_FIELD_INIT	,   FwBuildFeature(STRUCT_FEATURE_INIPAD, 'Iif(!Inclui,Posicione("SA2",1,FWxFilial("SA2")+ZFF->ZFF_ORIGEM+ZFF->ZFF_RLOJA,"A2_NOME"),"")'))//Iniciador de Campo
    oGrid:SetProperty('ZFF_KM'		, MODEL_FIELD_INIT	,   FwBuildFeature(STRUCT_FEATURE_INIPAD, 'U_I04INI()'))//Iniciador de Campo
    oGrid:SetProperty('ZFF_VFRETE'	, MODEL_FIELD_INIT	,   FwBuildFeature(STRUCT_FEATURE_INIPAD, 'U_I04INI()'))//Iniciador de Campo
    oGrid:SetProperty('ZFF_ADICIO'	, MODEL_FIELD_INIT	,   FwBuildFeature(STRUCT_FEATURE_INIPAD, 'U_I04INI()'))//Iniciador de Campo
    oGrid:SetProperty('ZFF_PEDAGI'	, MODEL_FIELD_INIT	,   FwBuildFeature(STRUCT_FEATURE_INIPAD, 'U_I04INI()'))//Iniciador de Campo
    oGrid:SetProperty('ZFF_ICMSF'	, MODEL_FIELD_INIT	,   FwBuildFeature(STRUCT_FEATURE_INIPAD, 'U_I04INI()'))//Iniciador de Campo
    oGrid:SetProperty('ZFF_VCOMP'	, MODEL_FIELD_INIT	,   FwBuildFeature(STRUCT_FEATURE_INIPAD, 'U_I04INI()'))//Iniciador de Campo
	
	Iif(!Inclui,Posicione('SA2',1,fwxFilial("SA2")+ZFF->ZFF_ORIGEM+ZFF->ZFF_RLOJA,'A2_NOME'),"")
	
	oModel := MPFormModel():New("FATI04M",,,bPos)

	oModel:AddFields("ZFFMASTER",/*cOwner*/  ,oStru, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)///* ,/*cOwner*/ ,oStPai  */ )
	oModel:AddGrid('ZFFDETAIL', 'ZFFMASTER'	, oGrid, /*bLinePre*/, /*bLinePos*/,/* bPre */,/* bPos */, /* {|| U_I04LOAD()} */)
	oModel:AddGrid('CTEDETAIL', 'ZFFDETAIL'	, oCte , /*bLinePre*/, /*bLinePos*/,/* bPre */,/* bPos */, {|| U_I04LOAD()})

	aAdd(aZFFRel, {'ZFF_FILIAL'	, 'Iif(!INCLUI, ZFF->ZFF_FILIAL	 , FWxFilial("ZMS"))'})
	aAdd(aZFFRel, {'ZFF_CODIGO' , 'Iif(!INCLUI, ZFF->ZFF_CODIGO	 , ZFF->ZFF_CODIGO)'})
	//aAdd(aZFFRel, {'ZFF_ITEM'	, 'Iif(!INCLUI, ZFF->ZFF_ITEM	 , ZFF->ZFF_ITEM)'})

	oModel:GetModel("ZFFMASTER"):SetFldNoCopy({'ZFF_FILIAL'	, 'ZFF_CODIGO', 'ZFF_ITEM'})

	oModel:SetRelation('ZFFDETAIL', aZFFRel, ZFF->(IndexKey(1)))

	oModel:SetPrimaryKey({})

	oModel:GetModel( "ZFFDETAIL" ):SetUniqueLine( { "ZFF_FILIAL","ZFF_CODIGO","ZFF_ITEM" } )

	//Setando outras informações do Modelo de Dados
	oModel:SetDescription("Dados do Cadastro "+cTitulo)
	oModel:GetModel("ZFFMASTER"):SetDescription("Formulário do Cadastro "+cTitulo)
	oModel:GetModel("ZFFDETAIL"):SetDescription("Grid do Cadastro "+cTitulo)
	oModel:GetModel("CTEDETAIL"):SetDescription("Grid do CTE ")
	oModel:GetModel('CTEDETAIL'):SetOptional(.T.)
Return oModel

Static Function ViewDef()
	Local oModel     	:= FWLoadModel("VAFATI04")
    Local oStru     	:= FWFormStruct(2, "ZFF" /* , {|cCampo| (AllTrim(cCampo) $ "ZFF_FILIAL|ZFF_CODIGO|ZFF_CONTRA|ZFF_FILCON|ZFF_FORNEC|ZFF_FLOJA|ZFF_FNOME|ZFF_DESTIN|ZFF_DLOJA|ZFF_NDEST|ZFF_MUN|ZFF_EST|ZFF_NMUN")} */ )
    Local oGrid     	:= FWFormStruct(2, "ZFF" /* , {|cCampo| !(AllTrim(cCampo) $ "ZFF_FILIAL|ZFF_CODIGO|ZFF_CONTRA|ZFF_FILCON|ZFF_FORNEC|ZFF_FLOJA|ZFF_FNOME|ZFF_DESTIN|ZFF_DLOJA|ZFF_NDEST|ZFF_MUN|ZFF_EST|ZFF_NMUN" )} */)
	Local oCte 			:= FWFormStruct(2, 'TempCte')
	Local oView
	Local nI 
	Local cStru 		:= "ZFF_FILIAL|ZFF_CODIGO|ZFF_COMBO|ZFF_CONTRA|ZFF_FILCON|ZFF_FORNEC|ZFF_FLOJA|ZFF_FNOME|ZFF_DESTIN|ZFF_DLOJA|ZFF_NDEST|ZFF_MUN|ZFF_EST|ZFF_NMUN"

	oCte := GetVGridCte(oModel, oCte)
	
	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_ZFF"	, oStru 		, "ZFFMASTER")
	oView:AddGrid("VIEW_GRID"	, oGrid 		, "ZFFDETAIL")
	oView:AddGrid("GRID_CTE" 	, oCte 			, "CTEDETAIL")
	
	oView:CreateHorizontalBox('CABEC', 30 )
	oView:CreateHorizontalBox('GRID' , 40 )
	oView:CreateHorizontalBox('RODAP', 30 )
	
	oView:CreateFolder('ABA01','CABEC')
	oView:CreateFolder('ABA02','GRID')
	oView:CreateFolder('ABA03','RODAP')

	oView:SetOwnerView("VIEW_ZFF"	 , "CABEC")
	oView:SetOwnerView("VIEW_GRID"	 , "GRID")
	oView:SetOwnerView("GRID_CTE"	 , "RODAP")
	
	oView:EnableTitleView('VIEW_ZFF' , cTitulo)
	oView:EnableTitleView('GRID_CTE' , "CTE")
	oView:EnableTitleView('VIEW_GRID', "Dados")
 	
	aFields   	:= OSTRU:AFIELDS
	
	aCampos := aClone(aFields)
	For nI := 1 to Len(aCampos)
		if !(aCampos[nI][1] $ cStru)
			oStru:RemoveField(aCampos[nI][1])
		endif
	Next Ni 
	For nI := 1 to Len(aCampos)
		if aCampos[nI][1] $ cStru /* .and. (aCampos[nI][1] != "ZFF_CODIGO") */
			oGrid:RemoveField(aCampos[nI][1])
		endif
	next nI
	
	oView:AddIncrementField( 'VIEW_GRID', 'ZFF_ITEM')
	
	oView:AddUserButton( 'Salvar Frete (F8)','', {|oView| SlvCont()} )

	oView:SetCloseOnOk( { |oView| .T. } )
Return oView

Static Function MenuDef()
	Local aRot := {}

	ADD OPTION aRot TITLE 'Visualizar' 			ACTION 'VIEWDEF.VAFATI04' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    			ACTION 'VIEWDEF.VAFATI04' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    			ACTION 'VIEWDEF.VAFATI04' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    			ACTION 'VIEWDEF.VAFATI04' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	ADD OPTION aRot TITLE 'Relatório'  			ACTION 'U_VACOMR13'		  OPERATION 6 					   ACCESS 0 //OPERATION 5
	ADD OPTION aRot TITLE 'Processar Fretes'  	ACTION 'U_FATI04P'		  OPERATION 6 					   ACCESS 0 //OPERATION 5
Return aRot

User Function FATI04M()
	Local aParam 	:= PARAMIXB
	Local xRet 		:= .T.
	Local oModel 	:= nil
	Local oCab		:= nil
	Local oObj 		:= ''
	Local cIdPonto 	:= ''
	Local cIdModel 	:= ''
	Local cIdIXB5	:= ''
	Local cIdIXB4	:= '' 

	If aParam <> NIL
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]

		if len(aParam) >= 4
			cIdIXB4  := aParam[4]
		endif 

		if len(aParam) >= 5
			cIdIXB5  := aParam[5]
		endif 

		if cIdPonto == 'FORMCOMMITTTSPRE'
			if nTotEmb < nTotDes
				MsgAlert("Quantidade total do Embarque menor que o Desembarque.", "Atenção...")
				xRet := .F.
			elseif nTotEmb > nTotDes
				MsgAlert("Quantidade total do Desembarque menor que o Embarque.", "Atenção...")
				xRet := .F.
			endif
		elseif cIdPonto == 'FORMPRE' .and. cIdModel == 'ZFFDETAIL' .and. cIdIXB5 = 'ADDLINE'
			oModel 	 	:= FwModelActivate()
			oCab 		:= oModel:GetModel("ZFFMASTER")
			oGrid 		:= oModel:GetModel("ZFFDETAIL")
		endif
	endif
Return xRet

Static Function GetModelCte(oModel, oCte)
	oCte:AddField('Item'		, 'Item'  		, 'CBC_ITEM' 	, 'C', 2					    , 0, /* Validação  */,,{},.F.,{|| U_I04INC()  }				,.F.,.F.,.T.,)
	oCte:AddField('Fornecedor'	, 'Fornecedor' 	, 'CBC_FORNEC'	, 'C', TamSX3("A2_COD")[1] 	  	, 0, /* Validação  */,,{},.F.,{|| U_I04IFOR("CBC_FORNEC") }	,.F.,.T.,.T.,)
	oCte:AddField('Loja'		, 'Loja'		, 'CBC_LOJA'	, 'C', TamSX3("A2_LOJA")[1]	  	, 0, /* Validação  */,,{},.F.,{|| U_I04IFOR("CBC_LOJA") }	,.F.,.T.,.T.,)
	oCte:AddField('Nome'		, 'Nome'		, 'CBC_NOME'	, 'C', TamSX3("A2_NOME")[1]	  	, 0, /* Validação  */,,{},.F.,{|| U_I04IFOR("CBC_NOME") }	,.F.,.F.,.T.,)
	oCte:AddField('Filial Doc'	, 'Filial Doc' 	, 'CBC_FILDOC'	, 'C', TamSX3("ZFI_FILDOC")[1] 	, 0, /* Validação  */,,{},.F.,{|| cRet := FWxFilial("ZFI")}	,.F.,.T.,.T.,)
	oCte:AddField('Doc' 		, 'Doc'   		, 'CBC_DOC'  	, 'C', TamSX3("F1_DOC")[1]    	, 0, {|| U_I04CTE()} ,,{},.F.,/* Iniciador Padrão */		,.F.,.T.,.T.,)
	oCte:AddField('Serie'		, 'Serie' 		, 'CBC_SERIE'	, 'C', TamSX3("F1_SERIE")[1]  	, 0, /* Validação  */,,{},.F.,/* Iniciador Padrão */		,.F.,.F.,.T.,)
	oCte:AddField('Valor'		, 'Valor' 		, 'CBC_VALOR'	, 'N', TamSX3("F1_VALBRUT")[1]	, 0, /* Validação  */,,{},.F.,/* Iniciador Padrão */		,.F.,.F.,.T.,)
	oCte:AddField('Codigo'		, 'Codigo' 		, 'CBC_CODIGO' 	, 'C', TamSX3("ZFF_CODIGO")[1]	, 0, /* Validação  */,,{},.F.,/* {|| U_I04INC()  }		 */	,.F.,.F.,.T.,)
	oCte:AddField('Item'		, 'Item'  		, 'CBC_ITEMF' 	, 'C', 2					    , 0, /* Validação  */,,{},.F.,/* {|| U_I04INC()  }	 */		,.F.,.F.,.T.,)
Return oCte

Static Function GetVGridCte(oModel, oCte)
	oCte:AddField('CBC_ITEM' 	, '1' , 'Item' 		, 'Item' 		,{}, 'C',""					,/* bPictVar */,/* cLookUp */,.F.,/* cFolder */,/* cGroup */,/* aComboValues */ {} ,/* nMaxLenCombo */,/* cIniBrow */,/* lVirtual */.T.,/* cPictVar */,/* lInsertLine */,/* nWidth */)
	oCte:AddField('CBC_FORNEC'	, '2' , 'Fornecedor', 'Fornecedor'	,{}, 'C',""					,/* bPictVar */,'SA2'		 ,.T.,/* cFolder */,/* cGroup */,/* aComboValues */ {} ,/* nMaxLenCombo */,/* cIniBrow */,/* lVirtual */.T.,/* cPictVar */,/* lInsertLine */,/* nWidth */)
	oCte:AddField('CBC_LOJA'	, '3' , 'Loja'		, 'Loja'		,{}, 'C',""					,/* bPictVar */,/* cLookUp */,.T.,/* cFolder */,/* cGroup */,/* aComboValues */ {} ,/* nMaxLenCombo */,/* cIniBrow */,/* lVirtual */.T.,/* cPictVar */,/* lInsertLine */,/* nWidth */)
	oCte:AddField('CBC_NOME'	, '4' , 'Nome'		, 'Nome'		,{}, 'C',""					,/* bPictVar */,/* cLookUp */,.F.,/* cFolder */,/* cGroup */,/* aComboValues */ {} ,/* nMaxLenCombo */,/* cIniBrow */,/* lVirtual */.T.,/* cPictVar */,/* lInsertLine */,/* nWidth */)
	oCte:AddField('CBC_FILDOC'	, '5' , 'Filial Doc', 'Filial Doc'	,{}, 'C',""					,/* bPictVar */,			 ,.T.,/* cFolder */,/* cGroup */,/* aComboValues */ {} ,/* nMaxLenCombo */,/* cIniBrow */,/* lVirtual */.T.,/* cPictVar */,/* lInsertLine */,/* nWidth */)
	oCte:AddField('CBC_DOC'  	, '6' , 'Doc'  		, 'Doc'  		,{}, 'C',""					,/* bPictVar */, 'SF1'		 ,.T.,/* cFolder */,/* cGroup */,/* aComboValues */ {} ,/* nMaxLenCombo */,/* cIniBrow */,/* lVirtual */.T.,/* cPictVar */,/* lInsertLine */,/* nWidth */)
	oCte:AddField('CBC_SERIE'	, '7' , 'Serie'		, 'Serie'		,{}, 'C',""					,/* bPictVar */,/* cLookUp */,.F.,/* cFolder */,/* cGroup */,/* aComboValues */ {} ,/* nMaxLenCombo */,/* cIniBrow */,/* lVirtual */.T.,/* cPictVar */,/* lInsertLine */,/* nWidth */)
	oCte:AddField('CBC_VALOR'	, '8' , 'Valor'		, 'Valor'		,{}, 'N',"@E 999,999.999"	,/* bPictVar */,/* cLookUp */,.F.,/* cFolder */,/* cGroup */,/* aComboValues */ {} ,/* nMaxLenCombo */,/* cIniBrow */,/* lVirtual */.T.,/* cPictVar */,/* lInsertLine */,/* nWidth */)
	oCte:AddField('CBC_CODIGO' 	, '9' , 'Codigo' 	, 'Codigo' 		,{}, 'C',""					,/* bPictVar */,/* cLookUp */,.F.,/* cFolder */,/* cGroup */,/* aComboValues */ {} ,/* nMaxLenCombo */,/* cIniBrow */,/* lVirtual */.T.,/* cPictVar */,/* lInsertLine */,/* nWidth */)
	oCte:AddField('CBC_ITEMF' 	, '10', 'Item' 		, 'Item' 		,{}, 'C',""					,/* bPictVar */,/* cLookUp */,.F.,/* cFolder */,/* cGroup */,/* aComboValues */ {} ,/* nMaxLenCombo */,/* cIniBrow */,/* lVirtual */.T.,/* cPictVar */,/* lInsertLine */,/* nWidth */)
Return oCte

//Validação dos campos ZFF_DATA e ZFF_DTDESE
User Function FAT04DT()
	Local oModel		:= FWModelActive()
	Local oGrid 		:= oModel:GetModel("ZFFDETAIL")
	Local lRet 			:= .T. 
	Local cCampo 		:= SubS( ReadVar(), At(">", ReadVar())+1 )
	Local cDt 			:= &(ReadVar())

	if cCampo == 'ZFF_DATA'
		if cDt > dDataBase
			lRet := .F.
			oModel:SetErrorMessage("","","","","Data Inválida", 'Data de Embarque não pode ser maior que a data atual!', "") 
		elseif !EMPTY(oGrid:GetValue("ZFF_DTDESE"))
			if cDt > oGrid:GetValue("ZFF_DTDESE")
				lRet := .F.
				oModel:SetErrorMessage("","","","","Data Inválida", 'Data de Embarque não pode ser maior que a data de desembarque!', "") 
			endif 
		endif
	else
		if cDt > dDataBase
			lRet := .F. 
			oModel:SetErrorMessage("","","","","Data Inválida", 'Data de Desembarque não pode ser maior que a data atual!', "")
		elseif !EMPTY(oGrid:GetValue("ZFF_DATA"))
			if cDt < oGrid:GetValue("ZFF_DATA")
				lRet := .F.
				oModel:SetErrorMessage("","","","","Data Inválida", 'Data de Desembarque não pode ser menor que a data de Embarque!', "") 
			endif 
		endif
	endif
Return lRet
//Carga do submodelo CTEDETAIL
User Function I04LOAD()
	Local oModel	:= FWModelActive()
	Local oStruct 	:= oModel:GetModel("ZFFMASTER")
	Local aArea		:= GetArea()
	Local aRet 		:= {}
	//Local nI 		:= 0
	Local cQry 		:= ''
	Local nValor	:= 0 
	cQry := " SELECT *  " + CRLF 
	cQry += " FROM "+RetSqlName("ZFI")+"  " + CRLF
	cQry += " WHERE ZFI_FILIAL 	= '"+FWxFilial("ZFI")+"' " + CRLF 
	cQry += " AND ZFI_CODIGO	= '"+oStruct:GetValue("ZFF_CODIGO")+"' " + CRLF 
	cQry += " AND D_E_L_E_T_	= '' " + CRLF

	mpSysOpenQuery(cQry,"TMP")

	DBSELECTAREA( "SF1" )
	DBSETORDER( 2 )
	
	while !TMP->(EOF())

		IF DbSeek(TMP->ZFI_FILDOC+;
			TMP->ZFI_FORNEC+;
			TMP->ZFI_LOJA+;
			TMP->ZFI_DOC )
			
			nValor := SF1->F1_VALBRUT
		else 
			nValor := 0 
		ENDIF
		aAdd(aRet,{Val(TMP->ZFI_ITEM),{	TMP->ZFI_ITEM,;
										TMP->ZFI_FORNEC,;
										TMP->ZFI_LOJA,;
										iif(!Empty(TMP->ZFI_FORNEC),Posicione("SA2",1,FwxFilial("SA2")+TMP->ZFI_FORNEC+TMP->ZFI_LOJA,"A2_NOME"),"")	,;
										TMP->ZFI_FILDOC,;
										TMP->ZFI_DOC,;
										TMP->ZFI_SERIE,;
										nValor,;
										TMP->ZFI_CODIGO,;
										TMP->ZFI_ZFFITE}})
		
		TMP->(DbSkip())
	end

	if Len(aRet) == 0
		aAdd(aRet,{1,{	'01',;
						oStruct:GetValue("ZFF_FORNEC"),;
						oStruct:GetValue("ZFF_FLOJA"),;
						Posicione("SA2",1,FwxFilial("SA2")+oStruct:GetValue("ZFF_FORNEC")+oStruct:GetValue("ZFF_FLOJA"),"A2_NOME"),;
						,;
						,;
						,;
						0,;
						"000000",;
						'01'}})
	endif
	SF1->(DBCLOSEAREA())
	TMP->(DBCLOSEAREA())
	RestArea(aArea)
Return aRet
//Validação dos campos ZFF_HREMB e ZFF_HRDESE
User Function FAT04HR()
	Local oModel		:= FWModelActive()
	Local oStruct 		:= oModel:GetModel("ZFFMASTER")
	Local lRet 			:= .T.
	Local cCampo 		:= SubStr(ReadVar(),4,len(ReadVar()))
	Local cHora			:= &(ReadVar())
	
	IF Left(cHora,2)>='00' .And. Left(cHora,2)<='24' .And. Right(cHora,2)>='00' .And. Right(cHora,2)<='59'
		if Left(cHora,2)<='24' .and. Right(cHora,2)=='00'
			if cCampo == "ZFF_HRDESE"
				IF oStruct:GetValue("ZFF_DATA") == oStruct:GetValue("ZFF_DTDESE")
					if Left(cHora,2) < Left(oStruct:GetValue("ZFF_HREMB"),2) // hora de Embarque maior que o desembarque com data no mesmo dia
						lRet := .F.
					elseif Left(cHora,2) == Left(oStruct:GetValue("ZFF_HREMB"),2) .and. Right(cHora,2) <= Right(oStruct:GetValue("ZFF_HREMB"),2) // hora de desembarque maior que o Embarque com data no mesmo dia
						lRet := .F.
					ENDIF
				ENDIF
			ELSEIF cCampo == "ZFF_HREMB"
				IF oStruct:GetValue("ZFF_DATA") == oStruct:GetValue("ZFF_DTDESE")
					if Left(cHora,2) > Left(oStruct:GetValue("ZFF_HRDESE"),2) // hora de Embarque maior que o desembarque com data no mesmo dia
						lRet := .F.
					elseif Left(cHora,2) == Left(oStruct:GetValue("ZFF_HRDESE"),2) .and. Right(cHora,2) >= Right(oStruct:GetValue("ZFF_HRDESE"),2) // hora de Embarque maior que o desembarque com data no mesmo dia
						lRet := .F.
					ENDIF
				ENDIF
			ENDIF
		ENDIF
	else
		lRet := .F.
	endif
Return lRet
User Function FATI04S()
	Local aArea 		:= GetArea()
	Local oModel		:= FWModelActive()
	Local oStruct		:= oModel:GetModel("ZFFMASTER")
	Local oGrid			:= oModel:GetModel("ZFFDETAIL")
	Local oCte			:= oModel:GetModel("CTEDETAIL")
	Local nOpc			:= oModel:GetOperation()
	Local lRet 			:= .T.
	Local nI,nX

	if nOpc == 3 .or. nOpc == 4 // ALTERAÇÃO E INCLUSÃO

		For nI := 1 to oGrid:GetQtdLine()
			oGrid:GoLine(nI)
			if oGrid:GetValue("ZFF_EMPE") +;
				oGrid:GetValue("ZFF_CAIDOS") +;
				oGrid:GetValue("ZFF_EMERGE") +;
				oGrid:GetValue("ZFF_MORTO") != oGrid:GetValue("ZFF_QTDE")
				
				oModel:SetErrorMessage("","","","","Quantidade Inválida", 'Quantidade de desembarque na linha '+oGrid:GetValue("ZFF_ITEM")+' não corresponde a quantidade total do embarque.', "") 
				lRet := .F.
			endif
		Next nI

		IF lRet
			DBSELECTAREA( "ZFF" )
			ZFF->(DBSETORDER(2))
			
			DBSELECTAREA( "ZFI" )
			ZFI->(DBSETORDER( 2 ))
			//ZFI_FILIAL+ZFI_CODIGO+ZFI_ITEM
		
			For nX := 1 to oGrid:GetQtdLine()
				oGrid:GoLine(nX)
				
				IF oGrid:IsDeleted()
					if ZFF->(DBSeek(FWxFilial("ZFF") + oStruct:GetValue("ZFF_CODIGO") +  oGrid:GetValue("ZFF_ITEM")))
						ZFF->(RECLOCK('ZFF',.F.))
							ZFF->(DbDelete())
						ZFF->(MSUNLOCK())
					endif
				ELSE 
					RECLOCK( "ZFF", lReclock := !(DBSEEK(FwxFilial("ZFF")+oStruct:GetValue("ZFF_CODIGO")+oGrid:GetValue("ZFF_ITEM"))) )
						ZFF->ZFF_FILIAL := FwxFilial("ZFF")
						ZFF->ZFF_COMBO := oStruct:GetValue("ZFF_COMBO")
						ZFF->ZFF_CODIGO := oStruct:GetValue("ZFF_CODIGO")
						ZFF->ZFF_CONTRA := oStruct:GetValue("ZFF_CONTRA")
						ZFF->ZFF_FILCON := oStruct:GetValue("ZFF_FILCON")
						ZFF->ZFF_FORNEC := oStruct:GetValue("ZFF_FORNEC")
						ZFF->ZFF_FLOJA 	:= oStruct:GetValue("ZFF_FLOJA")
						ZFF->ZFF_DESTIN := oStruct:GetValue("ZFF_DESTIN")
						ZFF->ZFF_DLOJA 	:= oStruct:GetValue("ZFF_DLOJA")
						ZFF->ZFF_MUN 	:= oStruct:GetValue("ZFF_MUN")
						ZFF->ZFF_EST 	:= oStruct:GetValue("ZFF_EST")
						ZFF->ZFF_ITEM 	:= oGrid:GetValue("ZFF_ITEM")
						ZFF->ZFF_PLCVL 	:= oGrid:GetValue("ZFF_PLCVL")
						ZFF->ZFF_ITEM 	:= oGrid:GetValue("ZFF_ITEM")
						ZFF->ZFF_ICTA1 	:= oGrid:GetValue("ZFF_ICTA1")
						ZFF->ZFF_PLCC1 	:= oGrid:GetValue("ZFF_PLCC1")
						ZFF->ZFF_ICTA2 	:= oGrid:GetValue("ZFF_ICTA2")
						ZFF->ZFF_PLCC2 	:= oGrid:GetValue("ZFF_PLCC2")
						ZFF->ZFF_ICTA3 	:= oGrid:GetValue("ZFF_ICTA3")
						ZFF->ZFF_NUMMIN := oGrid:GetValue("ZFF_NUMMIN")
						ZFF->ZFF_TIPVEI := oGrid:GetValue("ZFF_TIPVEI")
						ZFF->ZFF_MOTOR 	:= oGrid:GetValue("ZFF_MOTOR")
						ZFF->ZFF_ORIGEM := oGrid:GetValue("ZFF_ORIGEM")
						ZFF->ZFF_RLOJA 	:= oGrid:GetValue("ZFF_RLOJA")
						ZFF->ZFF_KM 	:= oGrid:GetValue("ZFF_KM")
						ZFF->ZFF_VFRETE := oGrid:GetValue("ZFF_VFRETE")
						ZFF->ZFF_VLKM 	:= oGrid:GetValue("ZFF_VLKM")
						ZFF->ZFF_ADICIO := oGrid:GetValue("ZFF_ADICIO")
						ZFF->ZFF_PEDAGI := oGrid:GetValue("ZFF_PEDAGI")
						ZFF->ZFF_ICMSF 	:= oGrid:GetValue("ZFF_ICMSF")
						ZFF->ZFF_VCOMP 	:= oGrid:GetValue("ZFF_VCOMP")
						ZFF->ZFF_QTDE 	:= oGrid:GetValue("ZFF_QTDE")
						ZFF->ZFF_DATA 	:= oGrid:GetValue("ZFF_DATA")
						ZFF->ZFF_ITEM 	:= oGrid:GetValue("ZFF_ITEM")
						ZFF->ZFF_HREMB 	:= oGrid:GetValue("ZFF_HREMB")
						ZFF->ZFF_BOIS 	:= oGrid:GetValue("ZFF_BOIS")
						ZFF->ZFF_VACAS 	:= oGrid:GetValue("ZFF_VACAS")
						ZFF->ZFF_BUFALO := oGrid:GetValue("ZFF_BUFALO")
						ZFF->ZFF_TOURO 	:= oGrid:GetValue("ZFF_TOURO")
						ZFF->ZFF_NOVILH := oGrid:GetValue("ZFF_NOVILH")
						ZFF->ZFF_DTDESE := oGrid:GetValue("ZFF_DTDESE")
						ZFF->ZFF_ITEM 	:= oGrid:GetValue("ZFF_ITEM")
						ZFF->ZFF_HRDESE := oGrid:GetValue("ZFF_HRDESE")
						ZFF->ZFF_EMPE 	:= oGrid:GetValue("ZFF_EMPE")
						ZFF->ZFF_CAIDOS := oGrid:GetValue("ZFF_CAIDOS")
						ZFF->ZFF_EMERGE := oGrid:GetValue("ZFF_EMERGE")
						ZFF->ZFF_MORTO 	:= oGrid:GetValue("ZFF_MORTO")
					ZFF->(MSUNLOCK())

					For nI := 1 to oCte:GetQtdLine()
						oCte:GoLine(nI)

						IF oCte:IsDeleted()
							if ZFI->(DBSeek(FWxFilial("ZFI") + oStruct:GetValue("ZFF_CODIGO") +  oCte:GetValue("CBC_ITEMF") +oCte:GetValue("CBC_ITEM")))
								ZFI->(RECLOCK('ZFI',.F.))
									ZFI->(DbDelete())
								ZFI->(MSUNLOCK())
							endif
						elseif !EMPTY(oCte:GetValue("CBC_DOC"))
							RecLock("ZFI", lRecLock := !DBSeek(FWxFilial("ZFI") + oStruct:GetValue("ZFF_CODIGO") +  oCte:GetValue("CBC_ITEMF") +oCte:GetValue("CBC_ITEM") ))
								ZFI->ZFI_FILIAL := FwXFilial("ZFI")
								ZFI->ZFI_CODIGO := oStruct:GetValue("ZFF_CODIGO")
								ZFI->ZFI_ITEM   := oCte:GetValue("CBC_ITEM")
								ZFI->ZFI_ZFFITE := oCte:GetValue("CBC_ITEMF")
								ZFI->ZFI_DOC 	:= oCte:GetValue("CBC_DOC")
								ZFI->ZFI_SERIE  := oCte:GetValue("CBC_SERIE")
								ZFI->ZFI_FILDOC := oCte:GetValue("CBC_FILDOC")
								ZFI->ZFI_PLACA  := oGrid:GetValue("ZFF_PLCVL")
								ZFI->ZFI_FORNEC := oCte:GetValue("CBC_FORNEC")
								ZFI->ZFI_LOJA  	:= oCte:GetValue("CBC_LOJA")
							ZFI->( MsUnlock() )
						endif 
						
					Next nI
				endif 
				ZFF->(MSUNLOCK())
			Next nX
			ZFI->(DBCLOSEAREA(  ))
		ENDIF
		
	elseif nOpc == 5 //DELETE

		DBSELECTAREA( "ZFI" )
		DBSETORDER( 2 )
		For nI := 1 to oCte:GetQtdLine()
			oCte:GoLine(nI)
			if ZFI->(DBSeek(FWxFilial("ZFI") + oStruct:GetValue("ZFF_CODIGO") + oCte:GetValue("CBC_ITEM")))
				ZFI->(RECLOCK('ZFI',.F.))
					ZFI->(DbDelete())
				ZFI->(MSUNLOCK())
			endif
		Next nI
		ZFI->(DBCLOSEAREA())

	endif
		//Se nÃ£o for inclusÃ£o, volta o INCLUI para .T. (bug ao utilizar a ExclusÃ£o, antes da InclusÃ£o)
	If nOpc != MODEL_OPERATION_INSERT
		INCLUI := .T.
	EndIf

	RestArea(aArea)
Return lRet
//Quantidade Embarque
User Function ATI04QT()
	Local oModel		:= FWModelActive()
	Local oGrid			:= oModel:GetModel("ZFFDETAIL")
	Local lRet 			:= .T.

	if &(ReadVar()) >= 0
		oGrid:SetValue("ZFF_QTDE",;
			oGrid:GetValue("ZFF_BOIS")  +;
			oGrid:GetValue("ZFF_VACAS") +;
			oGrid:GetValue("ZFF_BUFALO")+;
			oGrid:GetValue("ZFF_TOURO") +;
			oGrid:GetValue("ZFF_NOVILH"))
	else
		lRet := .F.
	endif
Return lRet
//Gatilho para preencher campos do frete, pega os dados do ultimo frete da placa informada e preenche os campos
User Function I04PLC()
	Local oModel	:= FWModelActive()
	Local oGrid		:= oModel:GetModel("ZFFDETAIL")
	Local aArea 	:= GetArea()
	Local cQry  	:= ''
	Local cRet 		:= ''

	cQry := " SELECT TOP 1 " +CRLF
	cQry += " * FROM "+RetSqlName("ZFF")+"" +CRLF
	cQry += " WHERE ZFF_PLCVL = '"+ALLTRIM(oGrid:GetValue("ZFF_PLCVL"))+"' " +CRLF
	cQry += " AND D_E_L_E_T_ = '' " +CRLF
	cQry += " ORDER BY R_E_C_N_O_ DESC " +CRLF

	mpSysOpenQuery(cQry,"TMP")

	if !TMP->(EOF())
		cRet := TMP->ZFF_PLCC1
		oGrid:SetValue("ZFF_PLCC2"  ,TMP->ZFF_PLCC2)
		oGrid:SetValue("ZFF_MOTOR " ,TMP->ZFF_MOTOR)
		oGrid:SetValue("ZFF_ORIGEM" ,TMP->ZFF_ORIGEM)
		oGrid:SetValue("ZFF_EST" 	,TMP->ZFF_EST)
		oGrid:SetValue("ZFF_RLOJA"  ,TMP->ZFF_RLOJA)
		oGrid:SetValue("ZFF_NORIG"  ,Posicione("SA2",1,FWXFILIAL("SA2") + TMP->ZFF_ORIGEM + TMP->ZFF_RLOJA,ALLTRIM("A2_NOME")))
		oGrid:SetValue("ZFF_TIPVEI" ,TMP->ZFF_TIPVEI)
	endif

	TMP->(DBCLOSEAREA())
	RestArea(aArea)
Return cRet
User Function I04DKM()

	Local aArea 	:= GetArea()
	Local oModel	:= FWModelActive()
	Local oStruct	:= oModel:GetModel("ZFFMASTER")
	Local nRet 		:= 0

	cQry := " SELECT TOP 1 " +CRLF
	cQry += " * FROM "+RetSqlName("ZFF")+"" +CRLF
	cQry += " WHERE ZFF_FORNEC = '"+ALLTRIM(oStruct:GetValue("ZFF_FORNEC"))+"' " +CRLF
	cQry += " AND ZFF_FLOJA = '"+ALLTRIM(oStruct:GetValue("ZFF_FLOJA"))+"' " +CRLF
	cQry += " AND ZFF_DESTIN = '"+ALLTRIM(oStruct:GetValue("ZFF_DESTIN"))+"' " +CRLF
	cQry += " AND ZFF_DLOJA = '"+ALLTRIM(oStruct:GetValue("ZFF_DLOJA"))+"' " +CRLF
	cQry += " AND D_E_L_E_T_ = '' " +CRLF
	cQry += " ORDER BY ZFF_PLCVL DESC  " +CRLF

	mpSysOpenQuery(cQry,"TMP")
	if !TMP->(EOF())
		nRet := TMP->ZFF_KM
	endif

	TMP->(DBCLOSEAREA())
	RestArea(aArea)
Return nRet 
//Gatilho para CTE e Valores
User Function I04CTE()
	Local aArea 		:= GetArea()
	Local oModel		:= FWModelActive()
	Local oStruct		:= oModel:GetModel("ZFFMASTER")
	Local oGrid 		:= oModel:GetModel("CTEDETAIL")
	Local nRet 			:= 0
	Local cCte  		:= StrZero( Val(&(ReadVar())),TamSx3("F1_DOC")[1])
	Local nI
	Local aSaveLines 	:= FWSaveRows()
	Local nSomaCte 		:= nSomaF := 0

	//F1_FILIAL+F1_FORNECE+F1_LOJA+F1_DOC

	DBSELECTAREA( "SF1" )
	DBSETORDER( 2 )

	if DbSeek(oGrid:GetValue("CBC_FILDOC")+;
		oGrid:GetValue("CBC_FORNEC")+;
		oGrid:GetValue("CBC_LOJA")+;
		cCte)
		
		nRet := SF1->F1_VALBRUT

		oGrid:SetValue("CBC_SERIE" ,SF1->F1_SERIE)
		oGrid:SetValue("CBC_VALOR" ,SF1->F1_VALBRUT)
		oGrid:LoadValue("CBC_DOC"  ,cCte)

		For nI := 1 to oGrid:GetQtdLine()
			oGrid:GoLine(nI)
			nSomaCte += oGrid:GetValue("CBC_VALOR")
		Next nI

		nSomaF := oStruct:GetValue("ZFF_VFRETE") +;
				oStruct:GetValue("ZFF_PEDAGI") +;
				oStruct:GetValue("ZFF_ADICIO") +;
				oStruct:GetValue("ZFF_ICMSF")

		oStruct:SetValue("ZFF_VCOMP",nSomaF - nSomaCte)
	else
		oModel:SetErrorMessage("","","","","Valor Invalido", 'CTE não existe para esse fornecedor!', "") 
	EndIf

	SF1->(DBCLOSEAREA())

	FWRestRows( aSaveLines )
	RestArea(aArea)
Return nRet
/* Iniciador para o campo CBC_FORNEC, CBC_LOJA E CBC_NOME na estrutura da GRID */
User Function I04IFOR(cCampo)
	Local oModel		:= FWModelActive()
	Local oStruct 		:= oModel:GetModel("ZFFMASTER")
	Local oGrid 		:= oModel:GetModel("CTEDETAIL")
	Local cRet 			:= ""
	
	if oGrid:GetQtdLine() == 0
		if !EMPTY(oStruct:GetValue("ZFF_FORNEC"))
			IF cCampo == 'CBC_FORNEC'	
				cRet := oStruct:GetValue("ZFF_FORNEC")
			elseif cCampo == 'CBC_LOJA'
				cRet := oStruct:GetValue("ZFF_FLOJA")
			else
				cRet := POSICIONE("SA2",1, FwXFilial("SA2")+oStruct:GetValue("ZFF_FORNEC")+oStruct:GetValue("ZFF_FLOJA "),"A2_NOME")
			endif
		endif
	else
		IF cCampo == 'CBC_FORNEC'	
			cRet := oGrid:GetValue("CBC_FORNEC")
		elseif cCampo == 'CBC_LOJA'
			cRet := oGrid:GetValue("CBC_LOJA")
		else
			cRet := POSICIONE("SA2",1, FwXFilial("SA2")+oGrid:GetValue("CBC_FORNEC")+oGrid:GetValue("CBC_LOJA"),"A2_NOME")
		endif 
	endif 
Return cRet
/* Incrementador para o campo item na grid */
User Function I04INC()
	Local oModel	 := FWModelActive()
	Local oCte 	 	 := oModel:GetModel("CTEDETAIL")
	Local cRet 		 := ""
	Local aSaveLines := FWSaveRows()	

	if oCte:GetQtdLine() == 0
		cRet := StrZero(oCte:GetQtdLine() + 1,2)
	else 
		cRet := StrZero(Val(oCte:GetValue("CBC_ITEM"))+1,2)
	endif 
	FWRestRows( aSaveLines )
Return cRet := StrZero(oCte:GetQtdLine() + 1,2)

/* Remover zeros a esquerda */
User Function zTiraZeros(cTexto)
    Local aArea     := GetArea()
    Local cRetorno  := ""
    Local lContinua := .T.
    Default cTexto  := ""
 
    //Pegando o texto atual
    cRetorno := Alltrim(cTexto)
 
    //Enquanto existir zeros a esquerda
    While lContinua
        //Se a priemira posição for diferente de 0 ou não existir mais texto de retorno, encerra o laço
        If SubStr(cRetorno, 1, 1) <> "0" .Or. Len(cRetorno) ==0
            lContinua := .f.
        EndIf
         
        //Se for continuar o processo, pega da próxima posição até o fim
        If lContinua
            cRetorno := Substr(cRetorno, 2, Len(cRetorno))
        EndIf
    EndDo
     
    RestArea(aArea)
Return cRetorno

User Function I04VMIN()
	Local aArea 	:= GetArea()
	Local oModel	:= FWModelActive()
	Local oGrid		:= oModel:GetModel("ZFFDETAIL")
	Local cQry 		:= ""
	Local lRet 		:= .T.
	
	cQry := "SELECT *  " + CRLF
	cQry += " FROM "+RetSqlName("ZFF")+" " + CRLF
	cQry += " WHERE ZFF_FILIAL = '"+FWxFilial("ZFF")+"' " + CRLF
	cQry += " AND ZFF_NUMMIN = '"+oGrid:GetValue("ZFF_NUMMIN")+"' " + CRLF
	cQry += " AND D_E_L_E_T_ = '' " + CRLF

	mpSysOpenQuery(cQry,"TMP")

	IF !TMP->(EOF())
		lRet := .F.
		oModel:SetErrorMessage("","","","","Valor Inválido", 'Minuta já está cadastrada no código: ' + TMP->ZFF_CODIGO + ', Para a placa: ' + TMP->ZFF_PLCVL, "") 
	ENDIF 

	TMP->(DBCLOSEAREA())
	RestArea(aArea)
Return lRet
/* Gatilho para o campo loja do Transportadora */  
User Function I04FORN()
	Local oModel	:= FWModelActive()
	Local oGrid		:= oModel:GetModel("ZFFDETAIL")
	Local oCTE 		:= oModel:GetModel("CTEDETAIL")
	Local cRet 		:= ''

	cRet := Posicione("SA2",1,FwXFilial("SA2")+oGrid:GetValue("ZFF_ORIGEM")+oGrid:GetValue("ZFF_RLOJA"),"A2_NOME")

	if oCTE:GetQtdLine() == 1
		if EMPTY(oCTE:GetValue("CBC_DOC"))
			oCTE:SetValue("CBC_ITEMF"	,oGrid:GetValue("ZFF_ITEM"))
			oCTE:SetValue("CBC_FORNEC"	,oGrid:GetValue("ZFF_ORIGEM"))
			oCTE:SetValue("CBC_LOJA"	,oGrid:GetValue("ZFF_RLOJA"))
			oCTE:SetValue("CBC_NOME"	,cRet)
		endif 
	endif 
Return  cRet
//Somar Valor de COmplemento
User Function I04VCOMP()
	Local oModel	:= FWModelActive()
	Local oGrid		:= oModel:GetModel("ZFFDETAIL")
	Local oCte 		:= oModel:GetModel("CTEDETAIL")
	Local nI 		:= 0
	Local nSomaCte  := nSomaF := nRet := 0
	
	if oGrid:GetValue("ZFF_ORIGEM") != '000025'
		For nI := 1 to oCte:GetQtdLine()
			oCte:GoLine(nI)
			nSomaCte += oCte:GetValue("CBC_VALOR")
		Next nI

		nSomaF := oGrid:GetValue("ZFF_VFRETE") +;
				oGrid:GetValue("ZFF_PEDAGI") +;
				oGrid:GetValue("ZFF_ADICIO") +;
				oGrid:GetValue("ZFF_ICMSF")
	endif 

Return nRet := nSomaF - nSomaCte
//Gatilho para pegar valor do frete
User Function I04KMG()

	Local oModel	:= FWModelActive()
	Local oGrid		:= oModel:GetModel("ZFFDETAIL")
	Local aArea 	:= GetArea()
	Local nRet 		:= 0
	Local cQry 		:= ""

	cQry := " SELECT * " + CRLF
	cQry += " FROM "+RetSqlName("ZFV")+" " + CRLF
	cQry += " WHERE ZFV_TIPVEI = '"+oGrid:GetValue("ZFF_TIPVEI")+"'" + CRLF
	cQry += " AND ZFV_DE <=  '"+iif(Empty(dToS(oGrid:GetValue("ZFF_DTDESE"))),dToS(dDataBase),dToS(oGrid:GetValue("ZFF_DTDESE")))+"'" + CRLF
	cQry += " AND ZFV_ATE >= '"+iif(Empty(dToS(oGrid:GetValue("ZFF_DTDESE"))),dToS(dDataBase),dToS(oGrid:GetValue("ZFF_DTDESE")))+"'" + CRLF
	cQry += " AND ZFV_KMDE <= "+Str(oGrid:GetValue("ZFF_KM"))+"" + CRLF
	cQry += " AND ZFV_KMATE >= "+Str(oGrid:GetValue("ZFF_KM"))+"" + CRLF
	cQry += " AND D_E_L_E_T_ = ''" + CRLF
	
	if cUserName == 'ioliveira'
		memowrite("C:\TOTVS_RELATORIOS\ZFV_ZFF_GATILHO.sql", cQry)
	endif

	MpSysOpenQuery(cQry, "TMP")

	IF !TMP->(EOF())
		if TMP->ZFV_TIPPAG == '2'
			nRet := TMP->ZFV_VLKM
		else
			nRet := TMP->ZFV_VLKM * oGrid:GetValue("ZFF_KM")
		EndIF
	else
		MSGALERT( "Não foi encontrado intervalo de pagamanto para este tipo de veiculo e data informada! "+ CRLF +;
				"Verifique a rotina U_VAFATI06() - Valores de Frete", "Atenção" )
	ENDIF

	RestArea(aArea)

Return nRet
User Function XMTA061()
	Local aRotBkp    As Array

	// Avalia se o aRotina existe
	If(Type('aRotina') == 'A')

		// Guarda o conteúdo atual do aRotina
		aRotBkp    := aClone(aRotina)

		// Limpa ou refaz o aRotina
		aRotina    := Nil

	EndIf

	U_VAFATI06()

	// Avalia se foi feito backup do aRotina
	If(ValType(aRotBkp) == 'A')
		aRotina    := aClone(aRotBkp)
	EndIf

Return

Static Function SlvCont()
	Local aArea  := FWGetArea()	
	Local oModel := FwModelActivate()
	Local oCab 	 := oModel:GetModel("ZFFMASTER")
	
	DBSelectArea("ZFF")
	ZFF->(DBSetOrder(1))

	IF !EMPTY( oCab:GetValue("ZFF_CONTRA") )
		RecLock("ZFF", lRecLock := !(DBSEEK(FwXFilial("ZFF") + oCab:GetValue("ZFF_CODIGO"))))
			ZFF->ZFF_FILIAL := FWxFilial("ZFF")
			ZFF->ZFF_CODIGO := oCab:GetValue("ZFF_CODIGO")
			ZFF->ZFF_CONTRA := oCab:GetValue("ZFF_CONTRA")
			ZFF->ZFF_FILCON := oCab:GetValue("ZFF_FILCON")
			ZFF->ZFF_FORNEC := oCab:GetValue("ZFF_FORNEC")
			ZFF->ZFF_FLOJA 	:= oCab:GetValue("ZFF_FLOJA ")
			ZFF->ZFF_MUN 	:= oCab:GetValue("ZFF_MUN")
			ZFF->ZFF_EST 	:= oCab:GetValue("ZFF_EST")
			ZFF->ZFF_DESTIN := oCab:GetValue("ZFF_DESTIN")
			ZFF->ZFF_DLOJA 	:= oCab:GetValue("ZFF_DLOJA")
		ZFF->(MSUNLOCK())
	ENDIF 
	FWRestArea(aArea)
Return 

User FUnction FATI04P()
	Local aArea 	:= FWGetArea()
	Local cPerg 	:= "FATI04P"
	Local cQry 		:= ''
	Local nVlrUnit  := 0

	GeraX1(cPerg)	

	If Pergunte(cPerg, .T.)

		U_PrintSX1(cPerg)
		
		cQry := " select ZFF_CODIGO, "+ CRLF
		cQry += " ZFF_FORNEC, "+ CRLF
		cQry += " ZFF_CONTRA,  "+ CRLF
		cQry += " ZFF_FILCON, "+ CRLF
		cQry += " SUM(ZFF_VFRETE) AS FRETE, "+ CRLF
		cQry += " SUM(ZFF_ADICIO) AS ADICIONAL, "+ CRLF
		cQry += " SUM(ZFF_PEDAGI) AS PEDAGIO "+ CRLF
		cQry += " from "+RetSqlName("ZFF")+" "+ CRLF
		cQry += " WHERE ZFF_FILIAL  BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+ CRLF
		cQry += " AND ZFF_FORNEC BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "+ CRLF
		cQry += " AND ZFF_DTDESE BETWEEN '"+dToS(MV_PAR05)+"' AND '"+dToS(MV_PAR06)+"'  "+ CRLF
		cQry += " AND D_E_L_E_T_ = ''  "+ CRLF
		cQry += " GROUP BY ZFF_CODIGO, ZFF_FORNEC,ZFF_CONTRA, ZFF_FILCON "+ CRLF
		
		MpSysOpenQry(cQry,"TMP")
		
		DBSelectArea("ZCC")
		ZCC->(DBSetOrder(2)) // ZCC_FILIAL + ZCC_CODIGO
		
		DBSelectArea("ZBC")
		ZBC->(DBSetOrder(4)) // ZBC_FILIAL + ZBC_CODIGO
		
		Begin Transaction
			While !TMP->(EOF())

				If ZCC->(DBSeek(TMP->ZFF_FILCON+TMP->ZFF_CONTRA))
					nVlrUnit := ( TMP->FRETE + TMP->ADICIONAL + TMP->PEDAGIO ) / ZCC->ZCC_QTTTAN

					if ZBC->(DBSeek(TMP->ZFF_FILCON+TMP->ZFF_CONTRA))
						
						WHILE ZBC->ZBC_CODIGO == TMP->ZFF_CONTRA
							RecLock("ZBC",.F.)
								ZBC->ZBC_VLFRPG := nVlrUnit * ZBC->ZBC_QUANT
							ZBC->(MsUnlock())

							ZBC->(DBSKIP())
						EndDO
					endif
				else
					ConOut( "Contrato: " +TMP->ZFF_CONTRA+ " não encontrado" )
				Endif
				TMP->(DBSkip())
			EndDo
		End Transaction

		ZBC->(DBCloseArea())
		ZCC->(DBCloseArea())
		TMP->(DBCloseArea())
	EndIf

	FwRestArea(aArea)
Return 

Static Function GeraX1(cPerg)
	Local _aArea	:= GetArea()
	Local aRegs     := {}
	Local nX		:= 0
	Local nPergs	:= 0
	Local j,i

	//Conta quantas perguntas existem ualmente.
	DbSelectArea('SX1')
	DbSetOrder(1)
	SX1->(DbGoTop())
	If SX1->(DbSeek(cPerg))
		While !SX1->(Eof()) .And. X1_GRUPO = cPerg
			nPergs++
			SX1->(DbSkip())
		EndDo
	EndIf

	aAdd(aRegs,{cPerg, "01", "Filial de?  		" , "", "", "MV_CH1", "C", TamSX3("ZFF_FILIAL")[1]  , TamSX3("ZFF_FILIAL")[2]  	, 0, "G", ""		, "MV_PAR01", "","","",""		,"",""   ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "02", "Filial Ate? 		" , "", "", "MV_CH2", "C", TamSX3("ZFF_FILIAL")[1]  , TamSX3("ZFF_FILIAL")[2]  	, 0, "G", "NaoVazio", "MV_PAR02", "","","","ZZZZZZZ","",""   ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "03", "Fornecedor de?  	" , "", "", "MV_CH3", "C", TamSX3("ZFF_FORNEC")[1]	, TamSX3("ZFF_FORNEC")[2]	, 0, "G", ""		, "MV_PAR03", "","","",""		,"",""   ,"","","","","","","","","","","","","","","","","","","SA2","","","","",""})
	aAdd(aRegs,{cPerg, "04", "Fornecedor Ate? 	" , "", "", "MV_CH4", "C", TamSX3("ZFF_FORNEC")[1] 	, TamSX3("ZFF_FORNEC")[2] 	, 0, "G", "NaoVazio", "MV_PAR04", "","","","ZZZZZZ"	,"",""   ,"","","","","","","","","","","","","","","","","","","SA2","","","","",""})
	aAdd(aRegs,{cPerg, "05", "Data De?    	  	" , "", "", "MV_CH5", "D", TamSX3("ZFF_DATA")[1]	, TamSX3("ZFF_DATA")[2]		, 0, "G", "NaoVazio", "MV_PAR05", "","","",""		,"",""   ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "06", "Data Ate?   	  	" , "", "", "MV_CH6", "D", TamSX3("ZFF_DATA")[1]	, TamSX3("ZFF_DATA")[2]		, 0, "G", "NaoVazio", "MV_PAR06", "","","",""		,"",""   ,"","","","","","","","","","","","","","","","","","","","","","","",""})

	//Se quantidade de perguntas for diferente, apago todas
	SX1->(DbGoTop())  
	If nPergs <> Len(aRegs)
		For nX:=1 To nPergs
			If SX1->(DbSeek(cPerg))		
				If RecLock('SX1',.F.)
					SX1->(DbDelete())
					SX1->(MsUnlock())
				EndIf
			EndIf
		Next nX
	EndIf

	// gravação das perguntas na tabela SX1
	If nPergs <> Len(aRegs)
		dbSelectArea("SX1")
		dbSetOrder(1)
		For i := 1 to Len(aRegs)
			If !dbSeek(cPerg+aRegs[i,2])
				RecLock("SX1",.T.)
					For j := 1 to FCount()
						If j <= Len(aRegs[i])
							FieldPut(j,aRegs[i,j])
						Endif
					Next j
				MsUnlock()
			EndIf
		Next i
	EndIf
	RestArea(_aArea)
Return nil

User Function I04CTN()
	Local oModel		:= FWModelActive()
	Local nOpc			:= oModel:GetOperation()
	Local oStru 		:= oModel:GetModel("ZFFMASTER")
	Local lRet 			:= .T. 
	Local cQry 

	if nOpc == 3
		IF ReadVar() $ "ZFF_CONTRA"
			if oStru:GetValue("ZFF_COMBO") == 'C'
				//cQry := "SELECT ZFF_CODIGO FROM "+RetSqlName("ZFF")+" " + CRLF
				//cQry += " WHERE ZFF_CONTRA = '"+ZCC_CODFOR+"'  " + CRLF
				//cQry += " AND D_E_L_E_T_ = '' " + CRLF
				//
				//MpSysOpenQry(cQry, "TMP")
				//	IF !TMP->(EOF())
				//		MSGALERT( "Contrato já vinculado ao frete: " + TMP->ZFF_CODIGO, "Atenção" )
				//		lRet := .f.
				//	ENDIF
				//TMP->(DBCLOSEAREA( ))
				//
				//if lRet 
				//	if Empty(oStruct:GetValue("ZFF_FORNEC"))
				//		oStruct:SetValue("ZFF_FORNEC", ZCC_CODFOR)
				//		oStruct:SetValue("ZFF_FLOJA",  ZCC_LOJFOR)
				//	endif
				//endif
			else 
				oModel:SetErrorMessage("","","","","Combo invalido", 'Campo combo não pode ser diferente de "C" !', "") 
				lRet := .F.
			endif
		ELSE
			if oStru:GetValue("ZFF_COMBO") == 'T'
				oStru:SetValue("ZFF_CONTRA", '')
				oStru:SetValue("ZFF_FILCON", '')
			endif 
			//if !Empty(oGrid:GetValue("ZFF_PLCVL"))
			//	oModel:SetErrorMessage("","","","","Combo invalidao", 'Campo combo não pode ser alterado, pois já tem registros cadastrados!', "") 
			//	lRet := .F.
			//endif
		endif
	else 
		oModel:SetErrorMessage("","","","","Campo invalido", 'Campo não pode ser alterado!', "") 
		lRet := .F.
	endif 
Return lRet 

User Function I04INI()
	Local cCampo  	:= Substr( ReadVar(), At('->', ReadVar())+2 )
	Local oModel 	:= FWModelActive()
	Local oGrid  	:= oModel:GetModel("ZFFDETAIL")
	Local cRet 		
	Local nLine 	:= oGrid:GetQtdLine()
	Local aSaveRows := FWSaveRows()


	if nLine > 0
		oGrid:GoLIne(nLine - 1)
		cRet := oGrid:GetValue(cCampo)
	else
		cRet := ""
	endif 

	FWRestRows(aSaveRows)
Return cRet
